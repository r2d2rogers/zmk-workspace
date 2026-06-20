# backkb — preview gallery

Rendered previews for the back-of-phone keyboard (branch
`claude/backkb-shield-import`). Spire can't run a GL viewer, so PNGs are
software-rendered from the exported STLs (matplotlib); STLs are the real
geometry — download those to view/print.

Raw-link base (tap from phone):
`https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/`

---

## 👉 LATEST — look at these first

**Iteration: clamp INTEGRATED into the halves (skirt removed)** — latest commit on branch

1. **[backkb_v1_inuse_corner.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_inuse_corner.png)**
   — IN USE: the right half's corner clamp wrapping the device's lower-outer corner. ✓ grips.
2. **[backkb_v1_in_use.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_in_use.png)**
   — IN USE plan: device held *between* the two halves, clamps at the two lower (-Y) corners.
3. **[backkb_v1_transit_side.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_transit_side.png)**
   — TRANSIT side: twist-and-stack with clamps. **Note:** the clamps land at diagonal-opposite corners and protrude → brick ~46 mm, not yet latched to each other.
4. **[backkb_v1_transit.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_transit.png)** — transit iso.

**Decision needed:** how the clamp rotates into transit — lock where it lands (diagonal strikes, accept corner bumps) vs reposition to meet vs fold away. Skirt is gone (`phone_skirt=false`).

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
