# Invitation card — image-generation prompt kit

Everything an image model needs to redraw this card freely: the exact palette, the
composition, the copy, and the things it must not do. `thirumalai-pooja-invitation.png`
in this folder is the HTML-rendered version — attach it as a style/layout reference
where the model accepts one.

---

## 1 · The palette

### Background — bright plum galaxy (the important part)

| Role | Hex | Notes |
|---|---|---|
| Base plum | `#7E3AA8` | the field the whole sky sits on |
| Deep plum (darkest allowed) | `#6C2F93` | never go darker than this — no black, no navy |
| Bright violet | `#A25EC4` | upper-left lift |
| Magenta plum | `#93409E` | lower-mid warmth |
| Light orchid | `#C173C9` | bottom / edge glow |
| Orchid nebula cloud | `#E69BE8` | soft cloud, ~60% opacity |
| Rose drift | `#FFA9C4` | lower-left cloud, ~50% |
| Lilac wash | `#CDA8FF` | lower-right cloud, ~55% |
| Warm core light | `#FFF0D6` → `#FFE2BE` | the one bright point, upper right |
| Gold dust | `#EAC56C` | drifting motes through the plum |
| Stars | `#FFFFFF`, `#FFEFC8` | fine, small, unevenly scattered |

**Brightness rule:** the sky reads as *daylight-side plum* — mid-to-high value, luminous,
like a nebula photographed in full light. No night sky, no black space, no deep indigo.

### Card surface — pearl glass, glossy

| Role | Hex |
|---|---|
| Pearl white | `#FFFDFC` |
| Pearl pink | `#FFF7FC` |
| Pearl mauve | `#FCEFFA` |
| Gold hairline | `#9A7526` |
| Gold mid | `#C79A3C` |
| Gold bright | `#EAC56C` |

The card is ~92% opaque glass: the plum galaxy glows faintly through its lower corners.
A soft white specular sweep runs diagonally from the top-left — a wet, varnished,
glossy finish, like a laminated print catching light.

### Ink and the two rays

| Role | Hex |
|---|---|
| Ink (headings) | `#3A123F` |
| Ink 2 (body) | `#5B2E63` |
| Ink 3 (sub-text) | `#7C5686` |
| Ink faint (labels) | `#9B7BA5` |
| Wine ray — the groom | `#7D1D32` · `#A32A48` · `#E85D75` |
| Gold ray — the bride | `#9A7526` · `#C79A3C` · `#EAC56C` |

The groom's name is lettered in the wine gradient, the bride's in the gold gradient,
the ampersand in gold. Two hairlines under the names — one wine, one gold — meet at a
small white glowing point.

### Type

Display / names: **Cormorant Garamond** (or EB Garamond, Playfair Display).
Body: **Inter**. Small caps labels: **Space Mono**, wide letter-spacing.

---

## 2 · Master prompt (text-capable models — Gemini 3 Pro Image, GPT Image, Ideogram, Firefly)

> A single-page luxury wedding invitation, A4 portrait (1:1.414), photorealistic glossy
> print finish.
>
> **Background:** a bright plum galaxy — a luminous nebula in daylight, not a night sky.
> Base plum `#7E3AA8` deepening only as far as `#6C2F93`, lifted with bright violet
> `#A25EC4`, magenta plum `#93409E` and light orchid `#C173C9` at the edges. Soft nebula
> clouds of orchid `#E69BE8` upper-left, rose `#FFA9C4` lower-left, lilac `#CDA8FF`
> lower-right. A warm cream-gold core of light `#FFF0D6` glowing in the upper right — one
> bright point. Fine white and warm-gold stars `#FFFFFF` / `#FFEFC8` scattered unevenly,
> a few four-point sparkles, gold dust `#EAC56C` drifting through. The whole sky is
> bright, airy and high-key — absolutely no black, no dark night sky, no deep navy.
>
> **The card:** centred on the sheet with an even margin of about 5%, a rounded-corner
> (18px radius) pearl-white glass panel — `#FFFDFC` to `#FFF7FC` to `#FCEFFA` — about 92%
> opaque, so the plum galaxy glows faintly through its lower corners. Thin gold hairline
> border `#9A7526`, and a second inner gold frame inset ~14px with small gold corner
> brackets. A soft diagonal specular highlight sweeps from the top-left across the panel —
> glossy, varnished, laminated. Gentle drop shadow onto the galaxy behind.
>
> **Layout, top to bottom, centred:**
> 1. A small gold-and-wine crest: two slender rays curving in from left and right and
>    meeting at a single glowing white point with a tiny gold four-point star above it.
> 2. Tiny wide-tracked mono caps, muted mauve: `YOU ARE INVITED TO THE WEDDING OF`
> 3. Very large elegant serif names on one line: **Thirumalai & Pooja** — "Thirumalai"
>    in a deep wine gradient `#5C1440`→`#A32A48`, "&" in italic gold, "Pooja" in a gold
>    gradient `#7A5416`→`#C79A3C`.
> 4. Two hairlines beneath, wine on the left and gold on the right, meeting at a small
>    glowing white bead.
> 5. Two columns split by a thin vertical gold rule:
>    - left — small caps `THE GROOM`, then `SON OF`, then serif: `Mr. T. Manimaran & Mrs. T. Lakshmi`
>    - right — small caps `THE BRIDE`, then `DAUGHTER OF`, then serif: `Mr. M. J. Murali Prasad & Mrs. T. N. Rajarajeswari`
> 6. A gold hairline divider with a small gold diamond at its centre.
> 7. Small caps line: `TOGETHER WITH THEIR FAMILIES, THEY WARMLY INVITE YOU`
> 8. Italic serif couplet, two lines, deep plum ink:
>    *"Two paths through life, each finding its own way, / yet converging at one bright point, on one beautiful day."*
> 9. A three-column band between two gold hairlines, each column with a small gold
>    line-icon above it:
>    - calendar icon — `RECEPTION` — **30th August 2026** — Sunday, 6:00 PM onwards
>    - clock icon — `WEDDING` — **31st August 2026** — Monday · Muhurtham 6:00 – 7:30 AM
>    - map-pin icon — `VENUE` — **Sri Venkatesh Mahal** — Pallavaram, Chennai
> 10. A delicate gold line-art South Indian mandapam: a domed arch on two slim pillars,
>     a kalash with a flame on top, a hanging toranam garland, and a lit diya glowing
>     beneath the dome.
> 11. A thin gold rule, then an italic serif line: *Two paths · one bright point · across the same sky*
>
> **Typography:** Cormorant Garamond for the names and headings, Inter for body lines,
> Space Mono for the wide-tracked small-caps labels. Ink `#3A123F`, body `#5B2E63`,
> sub-text `#7C5686`, labels `#9B7BA5`.
>
> **Mood:** cosmic but bright, refined, celestial-romantic, generous white space, precise
> alignment, editorial restraint. Every word spelled exactly as written.

**Avoid:** dark or black night sky, deep navy or midnight blue, heavy mandala clutter,
floral borders, peacocks, Ganesha figures, gold foil overload, drop-shadowed 3D text,
stock-photo couple images, watermarks, lens flare, cartoon style, misspelled text,
lorem ipsum, extra invented text.

---

## 3 · Midjourney / Sora-style short prompt

```
Luxury A4 wedding invitation card on a bright plum galaxy background, luminous daylight
nebula in violet and orchid #7E3AA8 #A25EC4 #C173C9 with rose #FFA9C4 and lilac #CDA8FF
clouds, warm cream-gold core light #FFF0D6, fine white and gold stars, no night sky ::
centred glossy pearl-white glass panel #FFFDFC with thin gold hairline frame #9A7526 and
soft diagonal specular sheen, deep plum ink #3A123F, elegant Cormorant Garamond serif
names in wine #A32A48 and gold #C79A3C, delicate gold line-art mandapam arch with kalash
and lit diya at the bottom, generous whitespace, editorial, celestial romantic, high-key,
print-quality --ar 1:1.414 --style raw --v 7
```

Negative: `--no black background, night sky, navy, dark, clutter, floral border, peacock,
3D text, watermark, couple photo`

---

## 4 · Background plate only (recommended for reliable text)

Image models still misspell names. The safest route is to generate only the sky, then set
the type over it in Canva/Figma/Illustrator using the palette above.

> A bright plum galaxy background, A4 portrait. A luminous nebula lit as if in daylight:
> base plum `#7E3AA8`, bright violet `#A25EC4`, magenta plum `#93409E`, light orchid
> `#C173C9` at the edges, soft clouds of orchid `#E69BE8`, rose `#FFA9C4` and lilac
> `#CDA8FF`, a warm cream-gold core of light `#FFF0D6` glowing in the upper right. Fine
> white and warm-gold stars, a few four-point sparkles, gold dust drifting through. Smooth
> gradients, subtle film grain, glossy varnished sheen. High-key and airy — no black, no
> night sky, no navy. The centre of the frame is calm and uncluttered, leaving room for
> text. No text, no logos, no people.

---

## 5 · Tuning knobs

- **Brighter still:** raise the base to `#8E4BAE` and the deep anchor to `#7A3AA0`; push
  the orchid and rose clouds to 70% opacity.
- **Richer / more saturated:** drop the base to `#6C2F93` and strengthen the magenta
  `#93409E`; keep the cream core so it never reads as night.
- **Warmer:** increase the gold dust `#EAC56C` and widen the cream core `#FFE2BE`.
- **Cooler:** lean on lilac `#CDA8FF` and violet `#A25EC4`, ease off the rose.
- **Other sizes:** `4:5` (1080×1350) for WhatsApp and Instagram, `1:1` for a profile-style
  card, `1:1.414` for A4 print. Ask for 300 dpi and 3–5 mm bleed when it is going to print.
