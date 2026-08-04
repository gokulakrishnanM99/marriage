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
| `.nojekyll` | Tells GitHub Pages to serve files as-is (no Jekyll processing). |

## Notes

- **Fonts** are self-hosted (no Google CDN) so text loads instantly and reliably,
  including offline and on flaky mobile networks. Above-the-fold faces are preloaded.
- **Performance:** the fullscreen WebGL cosmos renders at 1× pixel ratio; the secondary
  canvases and timeline pulses only draw while near the viewport; the whole render loop
  pauses when the browser tab is hidden.
- **Wedding date** is the `WEDDING_DATE` constant in the `<script>` block (drives the
  countdown). Ceremony date/time/venue live in the invitation section.
