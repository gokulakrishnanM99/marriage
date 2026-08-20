# Thirumalai & Pooja Prasad

It's an IIT Boy weds an AIIMS Girl  
Wedding - Aug 31, Reception Aug 30, Chennai 

Two Paths, One Sky

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

### Troubleshooting / Port Conflicts

If you see `PermissionError: [WinError 10013]` or `Address already in use`, port `4321` is currently occupied by another process.

**To free/close port 4321 on Windows:**

1. Find the Process ID (PID) using port 4321:
   ```cmd
   netstat -ano | findstr :4321
   ```
2. Kill the process:
   - **PowerShell:** `Stop-Process -Id <PID> -Force`
   - **CMD:** `taskkill /PID <PID> /F`

*(On macOS / Linux: `lsof -i :4321` then `kill -9 <PID>`)*

Alternatively, run the server on a different port:
```bash
python -m http.server 8080
```

## Structure

| Path | Purpose |
|------|---------|
| `index.html` | The entire experience — the deliverable. |
| `fonts/` | Self-hosted display and body faces (WOFF2, latin subset). |
| `gallery/` | The photographs, plus `opt/` — the small copies phones are served. |
| `gallery/build-variants.ps1` | Regenerates `gallery/opt/` after photos change. Not served. |
| `supabase/schema.sql` | Tables, rules and functions behind the shared song wall. Not served. |
| `.nojekyll` | Tells GitHub Pages to serve files as-is (no Jekyll processing). |

## Drop A Signal — the shared song wall

Guests name songs they want on the floor, and everyone sees the same list.
Each guest gets a fixed number of **picks** (currently three): drop a new song,
or tap one already up there to add their weight to it, in any combination.
Songs sort by how many guests are behind them.

**Changing how many picks each guest gets** — one number, one place:
`public.max_picks()` at the top of `supabase/schema.sql`. Edit it, re-run that
file in the Supabase SQL editor, reload the site. No code change and no
redeploy: the database enforces the rule, and the page asks the database what
it is, so the two can never drift apart. (`MAX_PICKS` in `index.html` is only
the offline fallback — keep it equal to the schema's number.)

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

## The convergence countdown

The card in the invitation section: two beams — one gold, one wine — closing on a
single bright point, with the days remaining above them.

### How far apart the beams sit

Days left is not something the eye should read linearly. Spread evenly across a
year the beams are all but touching a month out, and there is nothing left to
watch in the weeks that actually matter. So the approach is curved, and it has
**one dial** — `APPROACH_DAYS` in `index.html`:

```js
var APPROACH_DAYS = 8;
```

**Read it as: the two lights are half-way to meeting when this many days are
left.** At `8`, the half-closed look lands 8 days out.

- **Closer, sooner** — approaching earlier and more gently → **raise** it.
- **Wide apart for longer**, then rushing in at the end → **lower** it.

To predict any value: `gap ≈ daysLeft / (daysLeft + APPROACH_DAYS)`, where 1 is
fully apart and 0 is met. At the current setting:

| Days left | 90 | 30 | 14 | 8 | 3 | 1 | 0 |
|---|---|---|---|---|---|---|---|
| Apart | 94% | 81% | 65% | 51% | 28% | 11% | met |

Two secondary dials, if the whole thing should be wider or narrower regardless of
the date: the `0.94` in `beamGap()` is the maximum spread, and `half = W * 0.46`
in `drawConv()` is how much of the card's width the beams travel across. Leave
both alone for a normal adjustment.

The gap is computed on **fractional** days, so the final hours travel smoothly
into the muhurtham rather than jumping the last stretch at midnight. The card
still prints whole days.

### The bright point, and the arrival

The centre light is sized and lit by **how closed the beams are**, not by the
calendar — so it swells as they actually come in. (It used to follow the linear
year, which meant it reached ~96% of its size a month out and then grew by about
a pixel on the day itself.) On the day, two cream rings leave the bright point
and fade as they widen; they are skipped entirely under
`prefers-reduced-motion`, and cost nothing on any other day.

### Three states

The card knows the day can arrive and pass:

| When | Reads |
|------|-------|
| Before | *Until our two paths meet again* — **N** days |
| From the reception until 6h after the muhurtham | *The two paths meet* — **Today** |
| After that | *Two paths · one bright point* — **Married** |

### Previewing it

The arrival happens once, on one date, so there is a way to stand in front of it:

| URL | Shows |
|-----|-------|
| `?ccdays=3` | three days out |
| `?ccphase=today` | the day itself |
| `?ccphase=after` | the morning after |

Written after a `#` instead of a `?` these work identically and never leave the
browser, which is the easier one to thumb into a phone: `#ccphase=today`. They
only move what this one card displays — the invitation's real dates, the `.ics`
file and everything else are untouched.

## The gallery

Photographs live in `gallery/`. They are a mix of upright and wide, so each tile
keeps its own proportions rather than being cropped to a common shape, and the
columns pack around them (3 → 2 at 820px). Each frame starts as a blur of every
possible moment and collapses into focus on hover, on tap, or as it crosses the
centre of a phone screen.

**After adding or replacing a photo**, regenerate the small copies the page
serves to phones:

```bash
pwsh -File gallery/build-variants.ps1
```

That writes 400px and 760px versions into `gallery/opt/` using only the imaging
built into Windows — no toolchain to install — and never touches the originals.
Then add a line to `galleryData` in `index.html` with the file's real pixel
width and height (the script prints them) and an `alt` description. The
dimensions reserve each tile's space before the file arrives, so nothing below
jumps as the wall fills.

Everything is lazy-loaded and nothing is preloaded, so the gallery costs the
page nothing until a guest scrolls to it. A phone pulls ~196 KB for all five
frames against ~823 KB for the originals. **`gallery/opt/` must be committed** —
without it the site 404s on every photo.

## Notes

- **Fonts** are self-hosted (no Google CDN) so text loads instantly and reliably,
  including offline and on flaky mobile networks. Above-the-fold faces are preloaded.
- **Performance:** the fullscreen WebGL cosmos renders at 1× pixel ratio; the secondary
  canvases and timeline pulses only draw while near the viewport; the whole render loop
  pauses when the browser tab is hidden.
- **Dates** are the `WEDDING_DATE` and `RECEPTION_DATE` constants in the `<script>` block.
  Both are written with the `+05:30` offset spelled out, so the countdown and the `.ics`
  are the same instant on a phone set to any timezone. `WEDDING_DATE` drives the countdown;
  the Save-the-date button writes both events into one calendar file. The dates and times a
  guest reads are the three cells in the invitation section, and the venue link is `MAPS_URL`.
- **The convergence countdown** has its own section above. The progress bar under the
  beams is the linear one — `1 - daysLeft / PLAN_WINDOW` across a 365-day window — while
  the beams themselves follow the curve in `beamGap()`. They are deliberately different:
  the bar is how much of the wait is behind you, the beams are how near the two are.
- **The journey** opens with the diya centred on screen and closes with the mandapam
  centred on screen, on any aspect ratio — `travelFrom` / `travelTo` in `layoutJourney()`
  are derived from the two nodes' positions rather than from the track's edges.
