// =====================================================================
//  BACKKB v1 — sculpted keywell, dactyl-manuform style (orientation fix)
//
//  Iteration on v1 scaffold:
//   - columns now run along the phone SHORT axis (Y), as they should
//     for a landscape-grip with palms capping the short ends (the v0
//     premise). Previous scaffold ran columns along the long axis,
//     90° in-plane wrong.
//   - both halves rendered (right + mirrored left).
//   - phone hull with rounded corners + S24U camera bump as a real
//     spatial reference (not just a slab).
//   - parameter blocks borrow the Squeezebox v2209 philosophy: each
//     column has its own stagger entries you tune as if you were
//     repositioning physical magnetic slots.
//
//  Per side: 5 finger columns × 3 rows  +  2 thumb keys  +  1 palm key
//           = 18 keys/side, 36 total.
//
//  Status: SCAFFOLD. Parameter blocks + placement math + module stubs.
//  Switch cutouts and the sculpted shell are TODO and called out
//  inline. F5 preview shows layout; F6/STL is best for shape review.
//
//  Coordinate frame (phone landscape, screen up, user-facing):
//    +X = along phone long edge.    Right palm at +X, left palm at -X.
//    +Y = along phone short edge.   Top (far edge) at +Y; bottom (near
//                                   edge, by user) at -Y.
//    +Z = out from phone back, away from screen.
//    Origin = phone center, on the back surface.
//
//  Hand orientation:
//    Right hand: palm wraps the +X short end, fingers reach toward
//                phone center (-X). Pinky column on +Y (top edge),
//                index-inner column on -Y (bottom edge).
//    Left hand: mirrored across the YZ plane.
//
//  Units: mm. Author: scaffold for Rob, v1 iteration (Item #1691).
// =====================================================================

$fn = 48;

// ---------------------------------------------------------------------
//  PHONE BODY — S24 Ultra in Otterbox Commuter case (cradled object)
// ---------------------------------------------------------------------
// The backkb halves don't grip the phone directly; they cradle the
// already-cased phone. Sizes here are the OUTSIDE envelope of the
// Commuter case, not the bare phone. Adjust if you measure your
// case differently.
phone_len_bare = 162.3;
phone_wid_bare =  79.0;
phone_thk_bare =   8.6;

// Otterbox Commuter add (per face). Commuter is the "slim" tier; rough
// numbers from teardowns and pocket-feel measurements.
case_add_xy   =  2.5;     // each long/short edge adds ~2.5 mm
case_add_z    =  2.2;     // back of case adds ~2.2 mm; front lip a bit less

// Cased outer dims (what the cradle wraps around).
phone_len     = phone_len_bare + 2*case_add_xy;   // ~167.3
phone_wid     = phone_wid_bare + 2*case_add_xy;   //  ~84.0
phone_thk     = phone_thk_bare +   2*case_add_z;  //  ~13.0
corner_r      =  9.0;     // Commuter has bigger corner radii than bare phone

// Camera bump in landscape (visual reference; geometry-only, no cutout).
cam_w         = 40;
cam_h         = 62;
cam_thk       = 3.6;
cam_x         = -phone_len/2 + 8 + cam_w/2;
cam_y         =  phone_wid/2 - 8 - cam_h/2;

// ---------------------------------------------------------------------
//  HAND PLACEMENT
// ---------------------------------------------------------------------
// Right-hand wrist anchor — wrist sits just inboard of the right palm.
// Now measured from cased-phone center toward the right short end.
hand_anchor_x = 55;       // x of wrist (in cased-phone frame)
hand_anchor_y =  0;
// Home Z is the keywell's lowest point above the cradle back panel.
// case_back_thk sits between cased-phone back and the keywell floor.
hand_anchor_z = phone_thk + case_back_thk_placeholder();
// Placeholder hack: case_back_thk is defined later in the file (in the
// half-shell block) but hand_anchor_z needs it. Pin it here.
function case_back_thk_placeholder() = 2;

// Whole-hand tilt — fine adjustments after the per-column block is set
hand_tent_x   = 0;        // rotate around X (lifts pinky side or index)
hand_pitch_y  = 4;        // rotate around Y (tips top of column out)

// ---------------------------------------------------------------------
//  COLUMN GEOMETRY — dactyl-manuform parametric
// ---------------------------------------------------------------------
cols_per_hand = 5;        // pinky, ring, middle, idx_outer, idx_inner
rows_per_col  = 3;        // top / home / bottom

// Column arc — concave (pivot ABOVE home key). Home sits at the bottom
// of the bowl; both the fingertip-extended row (top) and the palm-tucked
// row (bottom) rise to meet the finger at its respective curl angle.
//
// The two arcs use SEPARATE radii so the bottom row can wrap tight
// without ballooning the keywell footprint. This is the trick for
// pocket-volume: keep the top arc shallow (broad sculpted bowl), but
// pivot the bottom row through a SHORT-radius arc so it ends up
// almost perpendicular to the phone back — a real trigger-pull face
// rather than a slightly-curved row.
column_curvature_top    = 10;   // deg between home and top (fingertip).
                                // Flattened from 16° — gives up some
                                // dactyl bowl-feel but saves ~1 mm Z
                                // for the pocket-depth budget.
column_curvature_bottom = 80;   // deg between home and bottom (palm).
                                // 80 ≈ nearly perpendicular; the row
                                // face points outward toward the palm,
                                // pressed by curling the finger back.

// Row arc — splay between adjacent columns (around Z, in-plane fan).
// Small here because columns ride the phone's narrow 79mm short axis.
row_curvature    = 4;     // deg per column-from-middle

// Per-column tunables. Squeezebox v2209 calls these "slots"; here
// they're arrays you edit and re-render. Indices: [pinky, ring,
// middle, idx_outer, idx_inner].

// Y position of each column relative to hand anchor (mm). Pinky on
// +Y (top edge), index columns on -Y (bottom edge).
column_y_pos    = [ 30, 15,  0, -14, -28 ];

// Per-column palm-to-fingertip X stagger (mm). Negative = pulled
// toward fingertip (further -X for right hand). Middle is the
// reference (0); pinky/index shorter so they're pulled back.
column_x_stagger = [ 6,  2,  0,  3, 10 ];

// Per-column Z offset (mm). Middle highest because the middle finger
// is the longest; pinky/index drop.
column_z_offset  = [-2, -1,  0, -1, -3 ];

// Row pitch (arc-length between rows along column arc).
row_spacing      = 17;

// Top-arc radius derived from arc-length so row spacing stays honest
// when you change column_curvature_top. The standard dactyl pivot.
row_radius_top    = row_spacing / (column_curvature_top * 3.14159265 / 180);

// Bottom-arc radius is set DIRECTLY (not derived) — kept short so the
// trigger-pull face stays close to home in X and Z while sweeping
// through the large column_curvature_bottom angle. Think of it as the
// rotation radius of the very last finger joint, not the whole finger.
// Tightened from 12 to 8 mm to pull the bottom-row cap-top down into
// the pocket-depth budget.
row_radius_bottom = 8;

// ---------------------------------------------------------------------
//  SWITCH + PLATE
// ---------------------------------------------------------------------
plate_thk     = 1.3;
choc_cutout   = 14;     // square plate cutout for Kailh Choc v1
keycap_xy     = 18;     // for clearance preview
keycap_h      = 4;      // choc, low profile

// ---------------------------------------------------------------------
//  THUMB CLUSTER — 2 keys per side, in hand-local frame
// ---------------------------------------------------------------------
// Right-hand thumb cluster sits outboard of index column, dropped down.
// Anchor is in the hand's local frame (post-anchor translate).
thumb_anchor  = [ 18, -36, -6 ];   // (x palm-side, y inboard, z down)
thumb_yaw_z   = -14;
thumb_pitch_y = 8;
thumb_spacing = 19;     // between the 2 thumb keys, along the cluster axis

// ---------------------------------------------------------------------
//  HALF-CASE CRADLE — wraps an Otterbox-cased phone, no case mods
// ---------------------------------------------------------------------
// Each half is a half-cradle around the already-cased phone:
//   (a) IN USE: halves clip onto opposite short ends of the cased
//       phone. Their INBOARD ends meet across the back at phone
//       center; SEAM magnets hold them clamped around the phone.
//       Keywell sits on the back panel facing the user (+Z).
//   (b) IN TRANSIT: halves detach from phone, flip, mate face-to-face
//       via RIM magnets on the keywell-bowl rim. Keys sealed inside
//       the joined cavity for pocket transport.
//
// Two magnet groups per half (different physical faces):
//   - SEAM magnets on the inboard (-X) wall — clamp halves around
//     phone in use AND maintain the cradle integrity.
//   - RIM magnets on the keywell-bowl top (+Z) face — snap halves
//     together face-to-face for transit (keys nested inside).
//
// Cradle wrap features:
//   - Back panel against cased phone back (case_back_thk)
//   - Outboard short-end wrap that reaches up onto the phone front
//     bezel by cradle_lip_h for retention
//   - Long-edge lips that grip the phone-case sides

case_back_thk    = 2.0;     // back wall against cased phone (mm)
case_wall_thk    = 2.5;     // side walls of the half-shell
case_rim_thk     = 2.5;     // bowl-rim ridge thickness
cradle_lip_h     = 5;       // lip wrap onto phone front bezel (retention)
cradle_long_extent = 80;    // each half reaches this far inboard from
                            // its outboard short end. 2 × 80 = 160 mm
                            // < phone_len 167 mm: leaves a small ~7 mm
                            // gap at center (room for seam magnets and
                            // a soft-feel separation strip).

// Half-shell footprint (right hand, in cased-phone frame).
// X: from phone center (seam) to outboard short end.
shell_x_seam     = 3;                     // half of 7 mm seam gap
shell_x_outboard = phone_len/2 + case_wall_thk;
shell_center_x   = (shell_x_seam + shell_x_outboard) / 2;
// Y: full cased-phone width (with wall on both long edges).
shell_y_min      = -phone_wid/2 - case_wall_thk;
shell_y_max      =  phone_wid/2 + case_wall_thk;
// Z: from phone-back (z=0 in cradle frame) up by back_thk + keywell.
shell_z_back     = phone_thk;             // top of cased-phone back
// 18 mm of keywell zone covers the bottom-row trigger cap (top at
// ~30.8 mm in cradle frame) with 2 mm clearance. Was 22 (placeholder).
shell_z_top      = shell_z_back + case_back_thk + 18;  // ~33 mm

// L-PROFILE — each half is asymmetric in side view:
//   Tall zone (outboard, contains keywell tower): z up to shell_z_top
//   Short zone (inboard, just back panel + low shell): z up to shell_z_short_top
// In transit, one half is X-shifted by transit_x_shift so its tall zone
// overlaps the OTHER half's short zone — towers sit at opposite X
// extremes, no tower-on-tower collision, transit Z stays low.
shell_x_step      = 35;                   // X boundary between short and
                                          // tall zones (just inboard of
                                          // the keywell's leftmost cap).
shell_z_short_top = shell_z_back + case_back_thk + 2;   // ~17 mm (low)
transit_x_shift   = (shell_x_step - shell_x_seam) * 2;  // 64 mm
                                          // shifts left half's tall zone
                                          // over right half's short zone.

// Magnets — 6 x 2 mm neodymium discs.
magnet_d         = 6;
magnet_h         = 2;
magnet_pocket_d  = 6.2;
magnet_pocket_h  = 2.1;

// SEAM magnets — along the inboard (-X) wall of each half. Polarity
// alternates per magnet so the two halves only mate in the correct
// orientation (N-S-N-S vs S-N-S-N).
seam_magnets = [
  [ 0, -30, phone_thk/2 ],
  [ 0, -10, phone_thk/2 ],
  [ 0,  10, phone_thk/2 ],
  [ 0,  30, phone_thk/2 ],
];

// RIM magnets — around the keywell-bowl rim on the (+Z) face. Reversed
// polarity from SEAM magnets so a transit-mode mate can't accidentally
// drop into in-use mode if the halves are jostled with no phone.
rim_magnets = [
  [ 25,  35, 0 ],
  [ 25, -35, 0 ],
  [ -10, 35, 0 ],
  [ -10,-35, 0 ],
  [ shell_x_outboard - 10,  35, 0 ],
  [ shell_x_outboard - 10, -35, 0 ],
];

// ---------------------------------------------------------------------
//  PALM KEY — 1 per side, in hand-local frame
// ---------------------------------------------------------------------
// Behind the thumb cluster, low. Pressed by the heel of the thumb pad.
palm_anchor   = [ 32, -36, -12 ];
palm_yaw_z    = -8;
palm_pitch_y  = -10;

// ---------------------------------------------------------------------
//  MODULES — preview-grade. TODO markers mark real-build work.
// ---------------------------------------------------------------------

// Switch+keycap preview at origin. Single-color, no cutout.
// TODO: replace with real Choc v1 plate cutout module (14mm + 5
//       retention notches per Kailh datasheet, plate_thk=1.3).
module key_preview() {
  color([0.40, 0.50, 0.72])
    translate([0, 0, plate_thk/2])
    cube([keycap_xy, keycap_xy, plate_thk], center=true);
  color([0.55, 0.65, 0.88, 0.85])
    translate([0, 0, plate_thk + keycap_h/2])
    cube([keycap_xy - 2, keycap_xy - 2, keycap_h], center=true);
}

// Place one key at (col, row) in the hand-local frame.
//   col 0..4 (pinky → index_inner), row 0..2 (top → bottom)
//
// Different columns step along Y (5 fingers across the phone short
// axis). Within a column, the 3 rows arc along X (palm at +X for right
// hand, fingertip toward -X) — each column extends down the phone long
// axis. Curl is concave (pivot ABOVE home).
//
// Top arc: long radius (row_radius_top, ~61mm), shallow angle (16°).
//   → broad sculpted bowl, fingertip reaches into it.
// Bottom arc: SHORT radius (row_radius_bottom, ~12mm), large angle (80°).
//   → tight trigger-pull face, near-perpendicular to phone back,
//     pressed by curling the finger back toward the palm.
//
// The two arcs share the home key as their tangent point. There's a
// visible discontinuity at the seam (the column shell will need to
// blend the two via hull() at the shell-pass), but the seam is what
// gives us the depth budget: bottom row sits low/tucked instead of
// arcing up and out.
module place_key(col, row) {
  y_pos   = column_y_pos[col];
  x_stag  = column_x_stagger[col];
  z_off   = column_z_offset[col];
  row_rel = row - 1;        // 0=home, -1=top (fingertip), +1=bottom (palm)
  col_rel = col - 2;        // splay center = middle column

  // Select arc params per row half.
  curl_deg = row_rel == 0 ? 0
           : row_rel <  0 ? -column_curvature_top    * row_rel
                          : -column_curvature_bottom * row_rel;
  arc_r    = row_rel <= 0 ? row_radius_top : row_radius_bottom;

  translate([x_stag, y_pos, z_off])
    rotate([0, 0, row_curvature * col_rel])    // splay (in-plane fan)
      translate([0, 0, arc_r])                 // pivot ABOVE home key
        rotate([0, curl_deg, 0])               // concave column curl
          translate([0, 0, -arc_r])
            children();
}

// Finger keywell — right hand, in hand-local frame.
module keywell_local() {
  for (c = [0 : cols_per_hand - 1])
    for (r = [0 : rows_per_col - 1])
      place_key(c, r) key_preview();
}

// Thumb cluster — right hand, in hand-local frame.
module thumb_cluster_local() {
  translate(thumb_anchor)
    rotate([0, thumb_pitch_y, thumb_yaw_z])
      for (i = [0, 1])
        translate([0, i * thumb_spacing, 0])
          key_preview();
}

// Palm key — right hand, in hand-local frame.
module palm_key_local() {
  translate(palm_anchor)
    rotate([0, palm_pitch_y, palm_yaw_z])
      key_preview();
}

// Half-cradle — wraps half the cased phone (one short end), provides
// the keywell mount surface, and exposes both magnet sets.
//
// In cradle frame: the cased phone sits at z = 0 .. phone_thk. The
// cradle's back panel sits at z = phone_thk .. phone_thk+case_back_thk.
// The keywell mounts above that.
module half_shell_local() {
  // Outer cradle hull — L-profile.
  //   Short zone (x_seam .. x_step): low shell, height shell_z_short_top.
  //   Tall  zone (x_step .. x_outboard): full keywell tower, shell_z_top.
  // The two zones share the same back-panel cradle around the phone;
  // they differ only in how high the shell wall rises.
  difference() {
    // Tall zone — outboard, contains keywell tower.
    color([0.7, 0.7, 0.75, 0.45])
      translate([(shell_x_step + shell_x_outboard)/2,
                 (shell_y_min  + shell_y_max)/2,
                 shell_z_top / 2])
        cube([shell_x_outboard - shell_x_step,
              shell_y_max - shell_y_min,
              shell_z_top], center = true);
    // Subtract the cased-phone cavity in the tall zone.
    translate([(shell_x_step + shell_x_outboard)/2,
               (shell_y_min + shell_y_max)/2,
               (phone_thk - cradle_lip_h) / 2])
      cube([shell_x_outboard - shell_x_step + 0.5,
            phone_wid + 1.0,
            phone_thk - cradle_lip_h + 0.01], center = true);
    // Subtract the keywell interior above the back panel.
    translate([(shell_x_step + shell_x_outboard)/2,
               (shell_y_min + shell_y_max)/2,
               (phone_thk + case_back_thk + shell_z_top)/2 + 0.01])
      cube([(shell_x_outboard - shell_x_step) - 2*case_wall_thk,
            (shell_y_max - shell_y_min)       - 2*case_wall_thk,
             shell_z_top - phone_thk - case_back_thk], center = true);
  }

  // Short zone — inboard, just the back panel + low shell.
  difference() {
    color([0.7, 0.7, 0.75, 0.45])
      translate([(shell_x_seam + shell_x_step)/2,
                 (shell_y_min  + shell_y_max)/2,
                 shell_z_short_top / 2])
        cube([shell_x_step - shell_x_seam,
              shell_y_max - shell_y_min,
              shell_z_short_top], center = true);
    // Subtract the cased-phone cavity in the short zone.
    translate([(shell_x_seam + shell_x_step)/2,
               (shell_y_min + shell_y_max)/2,
               (phone_thk - cradle_lip_h) / 2])
      cube([shell_x_step - shell_x_seam + 0.5,
            phone_wid + 1.0,
            phone_thk - cradle_lip_h + 0.01], center = true);
  }

  // SEAM magnet pockets — on the inboard (-X) wall, perpendicular to X
  color([0.9, 0.3, 0.3])
    for (m = seam_magnets)
      translate([shell_x_seam + magnet_pocket_h/2 - 0.05, m[1], m[2]])
        rotate([0, 90, 0])
          cylinder(h = magnet_pocket_h, d = magnet_pocket_d, center = true);

  // RIM magnet pockets — on the keywell-bowl top (+Z), perpendicular to Z
  color([0.3, 0.6, 0.9])
    for (m = rim_magnets)
      translate([m[0], m[1], shell_z_top - magnet_pocket_h/2])
        cylinder(h = magnet_pocket_h, d = magnet_pocket_d, center = true);
}

// Apply hand anchor + whole-hand tilt around the wrist, then render
// finger keywell + thumb + palm in the hand-local frame.
module hand_right() {
  translate([hand_anchor_x, hand_anchor_y, hand_anchor_z])
    rotate([hand_tent_x, hand_pitch_y, 0]) {
      keywell_local();
      thumb_cluster_local();
      palm_key_local();
    }
}

// Right-hand half-shell in cased-phone frame. The cradle's own origin
// is the seam plane (x=0), so we just call it directly; no
// hand_anchor offset (the keywell math inside still uses hand_anchor).
module hand_right_shell() {
  half_shell_local();
}

// Mirror right hand across the YZ plane.
module hand_left() {
  mirror([1, 0, 0]) hand_right();
}

// Left-hand half-shell.
module hand_left_shell() {
  mirror([1, 0, 0]) hand_right_shell();
}

// Cased phone body — rounded-corner Otterbox Commuter envelope.
// Geometry-only (no cutouts), used as the cradled object for layout.
module phone_body() {
  color([0.18, 0.18, 0.20, 0.55]) {
    hull() {
      for (sx = [-1, 1])
        for (sy = [-1, 1])
          translate([sx * (phone_len/2 - corner_r),
                     sy * (phone_wid/2 - corner_r), 0])
            cylinder(h = phone_thk, r = corner_r);
    }
    // Camera bump silhouette on the back of the case.
    translate([cam_x, cam_y, phone_thk])
      hull() {
        for (sx = [-1, 1])
          for (sy = [-1, 1])
            translate([sx * (cam_w/2 - 3),
                       sy * (cam_h/2 - 3), 0])
              cylinder(h = cam_thk, r = 3);
      }
  }
}

// END CAPS / PALM RESTS — carry over conceptually from v0.
// TODO: refit endcap_len, endcap_flare, endcap_round around the
//       sculpted keywell silhouette. v0 caps assume a flat back-plane
//       neighbor; v1 keywell rises away from it so end caps need to
//       ramp up. Squeezebox's "sawtooth wall" + per-column tailored
//       height is one model for that ramp.

// KEYWELL SHELL — the sculpted body that makes a dactyl-manuform
// dactyl-manuform. TODO: stock approach — hull() between adjacent
// plate frames (col,row)↔(col+1,row), (col,row)↔(col,row+1), and the
// diagonal pairs. ~150 lines once parameters are dialed. Per
// Squeezebox's modular philosophy, also consider rendering each
// column as its own keywell module so per-finger geometry can be
// iterated without rebuilding the whole shell.

// SWITCH CUTOUTS — replace key_preview() with real plate-with-cutout
// once the per-column parameters are tuned to your fingertip rest.

// ---------------------------------------------------------------------
//  RENDER TARGETS — switch via render_mode (override on CLI with -D)
// ---------------------------------------------------------------------
//
// Modes:
//   "in_use"   — phone + both halves docked (default; ergonomic review)
//   "transit"  — two halves snapped face-to-face (pocket view)
//   "right"    — single right half (print target candidate)
//
// CLI override: openscad -D 'render_mode="transit"' -o out.stl file.scad

render_mode = "in_use";

// Gap between the two rim faces when mated face-to-face for transit.
transit_mate_gap = 2;

if (render_mode == "in_use") {
  // Cased phone in the middle; right cradle on +X half, left on -X.
  phone_body();
  hand_right_shell();
  hand_right();
  hand_left_shell();
  hand_left();
} else if (render_mode == "transit") {
  // No phone; halves face-to-face, mated at the keywell rim. Both
  // ASYMMETRIC INTERLOCK:
  //   Right half stays at its native cradle X (3..86), tall zone at +X.
  //   Left half is flipped 180° around X (bowls face each other) and
  //   X-shifted by +transit_x_shift so its tall zone now overlaps right
  //   half's SHORT zone — towers at opposite X extremes, no collision.
  //   Z lift = shell_z_top + shell_z_short_top + transit_mate_gap.
  //   That's enough clearance for right's tall zone (z=0..shell_z_top)
  //   under left's short zone (which after flip+lift starts at the
  //   lifted plane and extends down by shell_z_short_top).
  hand_right_shell();
  hand_right();
  translate([transit_x_shift,
             0,
             shell_z_top + shell_z_short_top + transit_mate_gap])
    rotate([180, 0, 0]) {
      hand_left_shell();
      hand_left();
    }
} else if (render_mode == "right") {
  hand_right_shell();
  hand_right();
}
