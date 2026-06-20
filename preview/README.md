# backkb — preview gallery

Rendered previews for the back-of-phone keyboard (branch
`claude/backkb-shield-import`). Spire can't run a GL viewer, so PNGs are
software-rendered from the exported STLs (matplotlib); STLs are the real
geometry — download those to view/print.

Raw-link base (tap from phone):
`https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/`

---

## 👉 LATEST — look at these first

**Iteration: universal sprung corner clamp + dual-use transit latch** — commit `4a0d6c3`

1. **[backkb_v1_clamp_phone.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_clamp_phone.png)**
   — corner clamp gripping an S24U corner (thk 13, r 9).
2. **[backkb_v1_clamp_tablet.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_clamp_tablet.png)**
   — the *same* clamp on a ~10″ tablet corner (thk 7, r 8). Device-agnostic in one picture.
3. **[backkb_v1_clamp_latch.png](https://raw.githubusercontent.com/r2d2rogers/zmk-workspace/claude/backkb-shield-import/preview/backkb_v1_clamp_latch.png)**
   — transit latch: flexure catch seated in the opposing half's strike pocket.

**Open question:** unlock motion = squeeze-to-release (assumed); tablet center back-foot (TBD).

> Update this block at the top of every iteration so attention lands on the right images.

---

## Full index

### Corner clamp (current mechanism study)
- `backkb_v1_clamp_phone.png` / `.stl` — clamp on S24U corner.
- `backkb_v1_clamp_tablet.png` / `.stl` — clamp on tablet corner (same jaw).
- `backkb_v1_clamp_latch.png` / `.stl` — transit latch engaged in strike.

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
