# backkb — preview gallery

Rendered previews for the back-of-phone keyboard (branch
`claude/backkb-shield-import`). Spire can't run a GL viewer, so PNGs are
software-rendered from the exported STLs (matplotlib); STLs are the real
geometry — download those to view/print.

Raw-link base (tap from phone):
`https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/`

---

## 👉 LATEST — look at these first

**Iteration: Y-slide wiring → finding → slide-on retention SLEEVE** — latest commit on branch

**Finding:** after the twist, the two corner clamps land **maximally diagonal** — right clamp on the +X/−Y/**bottom** face, left clamp on the inboard/+Y/**top** face, ~40 mm apart in Z, each protruding into empty space. So a tongue-on-clamp-into-mating-half can't bridge them. A single Y-slide *sleeve* can, though:

1. **[backkb_v1_transit_sleeve.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_transit_sleeve.png)**
   — a retention SLEEVE slides on along +Y, wrapping the brick's X-Z cross-section. It covers **both** clamps (top + bottom faces) → flush, and **straps the two halves** together (can't separate in Z while on). A T-detent clicks it home = the slide-through lock. Both of Rob's clauses, one slide.

Slide-through mechanism study (unchanged, still valid): [slide_open](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_slide_open.png) / [slide_locked](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_slide_locked.png) — the T-slot that locks + flushes.

> Update this block at the top of every iteration so attention lands on the right images.

---

## Full index

### Corner clamp (current mechanism study)
- `backkb_v1_clamp_phone.png` / `.stl` — tuned jaw on S24U corner.
- `backkb_v1_clamp_tablet.png` / `.stl` — same jaw on tablet corner.
- `backkb_v1_clamp_latch.png` / `.stl` — transit latch ENGAGED (catch under strike ledge).
- `backkb_v1_clamp_release.png` / `.stl` — squeeze-to-release (latch wall tilted, catch clear).

### Keywell + transit (the half geometry)
- `backkb_v1_keywell.png` / `.stl` — sculpted dactyl keywell, both halves docked (in-use).
- `backkb_v1_transit.stl` — twist-and-stack pocket brick (telescoped channels).
- `backkb_v1_transit_side.png` — side section (look along Y): key sets interleaving, trigger keys 180-opposed.
- `backkb_v1_transit_end.png` — end section (look along X): pinky walls covering each other's open edge.
- `backkb_v1_thumb_cube.png` — 4-key thumb cage on the top edge.

### Print / sizing aids
- `bkb_sizing_template.pdf` — 1:1 printable plan-view sizing template.
- `bkb_sizing_template.py` — generator for the template.

### v0 (reference only — flat-back, superseded)
- `backkb_s24u.png` / `.stl` — original flat bridge-panel design. Kept for reference; not the current direction.

---

## How previews are made (for the next session)

- STL export: `openscad -o preview/<name>.stl -D 'render_mode="<mode>"' backkb_v1_keywell.scad`
  (the apt `/usr/bin/openscad` Qt build; nix-bundled GL segfaults — see memory Item #1690).
- PNG render: matplotlib `Poly3DCollection` from the ASCII STL, venv at `~/.cache/bkbviz`
  (`python3 -m venv --system-site-packages ~/.cache/bkbviz && pip install matplotlib`).
- Render modes: `in_use`, `transit`, `right`, `clamp_phone`, `clamp_tablet`, `clamp_latch`.
