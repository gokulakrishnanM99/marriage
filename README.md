# Thirumalai & Pooja — Two Paths, One Sky

A cinematic, single-page wedding invitation. One light, sent through a double slit,
and two paths — a quantum engineer and a doctor — arriving at the same bright point.

Built as **one self-contained `index.html`**: all CSS, JS, WebGL, and SVG are inline,
with no build step. Fonts are the only external asset, and they are self-hosted.

## Run it locally

Open `index.html` in any modern browser, or serve the folder (recommended, matches hosting):

```bash
python -m http.server 4321
```

then open <http://localhost:4321>. Any current browser with WebGL works; without WebGL
the background falls back to a static gradient.

## Structure

| Path | Purpose |
|------|---------|
| `index.html` | The entire experience — the deliverable. |
| `fonts/` | Self-hosted **Cormorant Garamond**, **Inter**, **Space Mono** (WOFF2, latin subset). |
| `supabase/schema.sql` | Tables, rules and functions behind the shared song wall. Not served. |
| `.nojekyll` | Tells GitHub Pages to serve files as-is (no Jekyll processing). |

## Drop A Signal — the shared song wall

Guests name songs they want on the floor, and everyone sees the same list.
Each guest gets **two picks**: drop a new song, or tap one already up there to
add their weight to it, in any combination. Songs sort by how many guests are
behind them.

The page talks to a hosted Postgres (**Supabase**) directly over HTTPS, so the
site stays a plain static file and can keep living on GitHub Pages — there is no
server of ours anywhere.

**Switching it on**

1. Create a free Supabase project.
2. SQL Editor → paste `supabase/schema.sql` → Run.
3. Settings → API → copy the **Project URL** and the **anon / public** key.
4. In `index.html`, fill in `DJ_DB` (search for `var DJ_DB`).
5. Optional: add the same two values as the repo secrets `SUPABASE_URL` and
   `SUPABASE_ANON_KEY` so `.github/workflows/keepalive.yml` stops the free
   project pausing itself after a week of quiet.

Leave `DJ_DB` empty and the wall falls back to the browser's own storage, so the
page still works offline, opened straight from a file, or before the project
exists. Behaviour is identical either way — only the reach changes.

**Worth knowing**

- The anon key is public by design; it ships inside the page. Nothing is
  protected by hiding it — the row-level security policies and the two database
  functions in `schema.sql` are what actually enforce the rules.
- Guests are identified by a random id their browser keeps, not by an account.
  Clearing site data or switching phone earns a fresh pair of picks. Removing
  that loophole means asking guests to sign in, which the invitation shouldn't.
- Clearing the wall before the day: `truncate public.song_claims cascade;`

## Notes

- **Fonts** are self-hosted (no Google CDN) so text loads instantly and reliably,
  including offline and on flaky mobile networks. Above-the-fold faces are preloaded.
- **Performance:** the fullscreen WebGL cosmos renders at 1× pixel ratio; the secondary
  canvases and timeline pulses only draw while near the viewport; the whole render loop
  pauses when the browser tab is hidden.
- **Wedding date** is the `WEDDING_DATE` constant in the `<script>` block (drives the
  countdown). Ceremony date/time/venue live in the invitation section.
