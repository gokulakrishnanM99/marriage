-- =====================================================================
--  Drop A Signal — the shared song wall
--
--  Run this once in the Supabase SQL editor (Dashboard → SQL Editor →
--  New query → paste → Run). It is safe to re-run: every statement is
--  idempotent.
--
--  Design in one line: a song exists only while at least one guest is
--  claiming it, and `songs.count` is simply how many guests claim it.
--  Every rule the page relies on is enforced here, in the database, so a
--  visitor poking at the public API cannot get around it.
-- =====================================================================

create extension if not exists pgcrypto;

-- =====================================================================
--  ▼▼▼  HOW MANY SONGS ONE GUEST MAY HOLD  —  CHANGE THE NUMBER HERE  ▼▼▼
-- =====================================================================
--  This is the only place the limit is written down. The trigger below
--  enforces it, and the page asks the database for it on load, so the
--  page and the rule can never drift apart.
--
--  To change it: edit the number, re-run this file in the Supabase SQL
--  editor, and reload the site. No code change, no redeploy.
-- =====================================================================
create or replace function public.max_picks() returns integer
  language sql immutable parallel safe as $$ select 3 $$;

grant execute on function public.max_picks() to anon, authenticated;

-- ---------------------------------------------------------------------
--  songs — one row per distinct song title
-- ---------------------------------------------------------------------
--  name_key is the case-insensitive, trim-insensitive form of the title.
--  It carries the unique index, so "Munbe Vaa" and "  munbe vaa  " are
--  the same song and the second guest boosts the count instead of
--  creating a duplicate row.
create table if not exists public.songs (
  id         uuid primary key default gen_random_uuid(),
  name       text        not null,
  name_key   text        generated always as (lower(btrim(name))) stored,
  count      integer     not null default 0,
  created_by text        not null,
  created_at timestamptz not null default now(),
  constraint songs_name_len check (char_length(btrim(name)) between 1 and 80)
);

create unique index if not exists songs_name_key_idx on public.songs (name_key);
create index        if not exists songs_order_idx    on public.songs (count desc, created_at asc);

-- ---------------------------------------------------------------------
--  song_claims — one row per (guest, song)
-- ---------------------------------------------------------------------
--  A "claim" is the single unit of guest intent. Dropping a new song and
--  boosting somebody else's song both create exactly one claim; the only
--  difference is `kind`, which the page uses to decide whether the row
--  gets a delete button or toggles on tap.
--
--  Because the two-picks-each rule counts claims, "2 new", "1 new +
--  1 boost" and "2 boosts" are automatically all legal, and nothing else
--  is. The primary key stops a guest claiming the same song twice.
--
--  device_id is a random id the browser generates and keeps in its own
--  localStorage — no accounts, no sign-in.
create table if not exists public.song_claims (
  song_id    uuid        not null references public.songs (id) on delete cascade,
  device_id  text        not null,
  kind       text        not null check (kind in ('new', 'boost')),
  created_at timestamptz not null default now(),
  primary key (song_id, device_id),
  constraint claims_device_len check (char_length(device_id) between 8 and 64)
);

--  Ordered by time so the page can tell a guest's 1st pick (gold outline)
--  from their 2nd (red outline).
create index if not exists song_claims_device_idx on public.song_claims (device_id, created_at);

-- ---------------------------------------------------------------------
--  songs.count follows the claims, always
-- ---------------------------------------------------------------------
--  Keeping the tally on the row (rather than counting on every read) lets
--  the page order by it in a single indexed query. When the last claim
--  goes, the song goes with it — that is what makes "remove my drop" and
--  "take my boost back" the same operation underneath.
create or replace function public.sync_song_count() returns trigger
language plpgsql as $$
declare
  v_song uuid;
  v_n    integer;
begin
  v_song := coalesce(new.song_id, old.song_id);
  select count(*) into v_n from public.song_claims where song_id = v_song;
  if v_n = 0 then
    delete from public.songs where id = v_song;
  else
    update public.songs set count = v_n where id = v_song;
  end if;
  return null;
end $$;

drop trigger if exists song_claims_count on public.song_claims;
create trigger song_claims_count
  after insert or delete on public.song_claims
  for each row execute function public.sync_song_count();

-- ---------------------------------------------------------------------
--  Picks per guest — enforced at the table, not just in the RPC, so a
--  visitor calling the REST API directly cannot get around it either.
--
--  The number itself lives in public.max_picks() at the top of this file.
-- ---------------------------------------------------------------------
create or replace function public.enforce_claim_limit() returns trigger
language plpgsql as $$
begin
  if (select count(*) from public.song_claims where device_id = new.device_id) >= public.max_picks() then
    raise exception 'claim_limit';
  end if;
  return new;
end $$;

drop trigger if exists song_claims_limit on public.song_claims;
create trigger song_claims_limit
  before insert on public.song_claims
  for each row execute function public.enforce_claim_limit();

-- ---------------------------------------------------------------------
--  claim_song — the only way in
-- ---------------------------------------------------------------------
--  Find-or-create the song, then claim it. Both happen in one statement,
--  so if the claim is refused (limit reached, already claimed) the song
--  row it might have just created is rolled back too — no orphans.
--
--  Two guests typing the same title at the same instant is handled by the
--  unique index: the loser of the race falls through to a plain lookup
--  and gets a 'boost' claim on the winner's row.
create or replace function public.claim_song(p_name text, p_device_id text)
returns table (song_id uuid, kind text)
language plpgsql security definer set search_path = public as $$
declare
  v_name text := btrim(p_name);
  v_id   uuid;
  v_kind text;
begin
  if char_length(v_name) < 1 or char_length(v_name) > 80 then
    raise exception 'bad_name';
  end if;
  if not (char_length(p_device_id) between 8 and 64) then
    raise exception 'bad_device';
  end if;

  select id into v_id from songs where name_key = lower(v_name);

  if v_id is null then
    insert into songs (name, created_by) values (v_name, p_device_id)
      on conflict (name_key) do nothing
      returning id into v_id;
    if v_id is null then                       -- lost the race; join their row
      select id into v_id from songs where name_key = lower(v_name);
      v_kind := 'boost';
    else
      v_kind := 'new';
    end if;
  else
    v_kind := 'boost';
  end if;

  if exists (select 1 from song_claims c where c.song_id = v_id and c.device_id = p_device_id) then
    raise exception 'already_claimed';
  end if;

  insert into song_claims (song_id, device_id, kind) values (v_id, p_device_id, v_kind);

  return query select v_id, v_kind;
end $$;

-- ---------------------------------------------------------------------
--  release_claim — remove my drop / take my boost back
-- ---------------------------------------------------------------------
--  Deletes only the caller's own claim. A song someone else has also
--  claimed survives, so removing your drop can never destroy another
--  guest's pick.
create or replace function public.release_claim(p_song_id uuid, p_device_id text)
returns boolean
language plpgsql security definer set search_path = public as $$
declare v_n integer;
begin
  delete from song_claims where song_id = p_song_id and device_id = p_device_id;
  get diagnostics v_n = row_count;
  return v_n > 0;
end $$;

-- ---------------------------------------------------------------------
--  Row level security
-- ---------------------------------------------------------------------
--  The anon key ships inside a public HTML page, so treat it as known to
--  everyone. Anonymous visitors get read-only access to the two tables
--  and may call the two functions — nothing else. Direct INSERT / UPDATE
--  / DELETE have no policy at all, which means they are denied.
alter table public.songs       enable row level security;
alter table public.song_claims enable row level security;

drop policy if exists "songs are public"  on public.songs;
drop policy if exists "claims are public" on public.song_claims;

create policy "songs are public"  on public.songs       for select to anon, authenticated using (true);
create policy "claims are public" on public.song_claims for select to anon, authenticated using (true);

revoke all on public.songs       from anon, authenticated;
revoke all on public.song_claims from anon, authenticated;

grant select on public.songs       to anon, authenticated;
grant select on public.song_claims to anon, authenticated;

grant execute on function public.claim_song(text, text)    to anon, authenticated;
grant execute on function public.release_claim(uuid, text) to anon, authenticated;

-- ---------------------------------------------------------------------
--  Housekeeping notes
-- ---------------------------------------------------------------------
--  · Clearing the wall before the wedding:  truncate public.song_claims
--    cascade;  (the songs delete themselves with their last claim)
--  · Removing one song by hand:             delete from public.songs
--    where name ilike '%…%';
--  · A free Supabase project pauses after ~7 days with no requests. The
--    .github/workflows/keepalive.yml action pings it every few days so it
--    is awake on the day.
