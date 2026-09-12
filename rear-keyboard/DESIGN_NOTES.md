# Rear-mounted Choc keywell for Galaxy S24 Ultra — design notes

Status: ergonomics draft, ready for first test prints. Sept 9–12, 2026.

## The idea

A 3D-printed case for the Galaxy S24 Ultra with a Kailh Choc v1 keywell on the back,
typed on while holding the phone landscape like a game controller. Palms cradle the ends,
four fingers curl onto the back, thumbs lie along the top edge. Bluetooth via nice!nano
running ZMK with urob-style home row mods. Camera is covered — it is not used with the
keyboard attached.

## Files

- `rear_keyboard.scad` — the whole design, parametric. `part` selects output:
  `well` (left keywell only), `thumb` (left thumb bar only), `case` (everything), `preview`.
- `rear_phone.keymap` — ZMK keymap, 34 keys, Colemak-DH, timeless home row mods.
- `renders/` — OpenSCAD previews of the current state.
- `reference_photos/` — the three grip photos the geometry was derived from.

## Decisions, in the order we made them

1. Keys on the phone, not the phone docked in front of a handheld. Prior art
   (AlphaGrip, TREWGrip, Grabshell) all went the docked route and all are bulky;
   RearType (MSR 2010) proved rear typing on the device itself works.
2. Grip is a controller grip. Finger columns run along the phone's long axis
   (curl toward the palm, extend toward the other hand); fingers stack along the
   short axis, pinky at the bottom edge, index and its inner column just under the
   thumb bar. No rotation of the block (`hand_angle = 0`); the diagonal comes from
   column stagger instead.
3. Keywell, not a flat plate. Each finger has a 3-key column on a 45 mm arc
   (curl / home / extend) with per-finger stagger and height offset, Dactyl-style
   corner-post webbing, skirts to the floor, switch cavities carved out.
4. Inner index column, three keys (curl / home / extend). 30 finger keys total.
5. Stagger follows the photo of the relaxed hand: middle furthest forward,
   ring −2, index −7 (reduced by a third from −10), pinky −12.
6. Thumbs: two Choc keys in a line along the top edge, near each corner, tip
   toward the corner. Far key (tip) ~10 mm from the end, near key 18 mm inboard.
   Plates form a 12° V so the curled tip finds the far key alone; a flat press
   hits both, which ZMK treats as a combo — three actions per thumb from two keys.
   Keys face straight out of the edge (`thumb_tilt = 0`). Bar is ~17 mm tall
   across the phone's thickness and ~13 mm proud of the edge including caps.
   Earlier cradle / roll-bar variants were rejected as too bulky.
7. Camera: covered, no cutout.

## Key parameters (top of the .scad)

| name | value | meaning |
|---|---|---|
| finger_pitch | 16 | spacing between finger columns |
| reach_pitch | 18 | curl / home / extend spacing along the arc |
| col_R | 45 | column curvature radius |
| hand_angle | 0 | rotation of the whole block |
| left_origin | [36, 2] | pinky home key, phone coords (x from the end, y from the bottom edge) |
| stagger (pinky→inner index) | −12, −2, 0, −7, −7 | column offset toward the other hand |
| z_offset | 2.0, 0.5, 0.0, 0.5, 1.5 | column height, builds the well across fingers |
| thumb_x | 19 | centre of the thumb pair from that hand's end |
| thumb_pitch / thumb_v | 18 / 12° | far–near spacing and V angle |
| thumb_tilt | 0 | key face tilt toward the back |
| bay_z | 4 | electronics layer between phone back and well floor |

Right hand is a mirror of the left. Expect to give it its own numbers after the tape test.

## Prior art

- RearType, Microsoft Research 2010 — keys on the back of a tablet, split QWERTY,
  thumbs on front for modifiers. 3×5 per hand worked; corner keys hardest; errors
  mostly off-by-one; 15 WPM after an hour, one participant 47. Suggested smaller keys.
- AlphaGrip AG-5 (2005), TREWGrip (2013), Grabshell (2023) — handheld bodies with
  rear keys and the device docked in front. Bulky; TREWGrip's Kickstarter failed;
  Grabshell ~950 g.
- REGAL — ZMK macropad for the back of a phone/tablet (DIY, same stack).
- Nobody has combined a keywell with rear typing. That's the experiment.

## Electronics plan

nice!nano v2 + ZMK, handwired with 1N4148 diodes (col2row), ~350 mAh LiPo in the
centre bay. Rows = curl/home/extend, columns = fingers per hand, plus thumbs:
about 11–12 GPIOs. PCB only after the handwired version has been typed on.

## Open items — settle with a test print, not more photos

- Tape test: mark curled and extended fingertip positions and both thumb
  positions (curled and flat). That gives stagger, curl radius, thumb pitch.
- Print `part = "well"` and `part = "thumb"` for the left hand; tape to the phone.
- Right hand: its own origin/stagger rather than the mirror.
- Perimeter skin around each well (switch cavities currently show through the outer skirts).
- Electronics pocket in the dead volume between the wells; `bay_z` may drop to 0.
- USB-C cutout position; ZMK "lock" combo so setting the phone down doesn't type.
- Keymap matrix renumbering once the key count is final.
