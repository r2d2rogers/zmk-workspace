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
//  PHONE BODY — S24 Ultra reference
// ---------------------------------------------------------------------
phone_len     = 162.3;    // long edge
phone_wid     = 79.0;     // short edge
phone_thk     = 8.6;      // body thickness
corner_r      = 6.0;      // body corner radius

// Camera bump (S24U): in portrait the lenses are top-left; in landscape
// (long edge horizontal, with the user-near edge at -Y), that's the
// top-left back, i.e. roughly (-X, +Y) corner area.
cam_w         = 38;       // bump footprint width  (along X)
cam_h         = 60;       // bump footprint length (along Y)
cam_thk       = 3.6;      // bump rise above phone back
cam_x         = -phone_len/2 + 6 + cam_w/2;
cam_y         =  phone_wid/2 - 6 - cam_h/2;

// ---------------------------------------------------------------------
//  HAND PLACEMENT
// ---------------------------------------------------------------------
// Right-hand wrist anchor — wrist sits just inboard of the right palm.
// (Left-hand is generated via mirror() and inherits this offset.)
hand_anchor_x = 55;       // distance from phone center toward +X palm
hand_anchor_y =  0;       // centered in Y by default; nudge per finger
// Home Z is the keywell's lowest point. Dropped to 2 mm above phone
// back so the dock-mode rig fits a pocket-friendly half. With
// case_back_thk=1.5, leaves ~0.5 mm clearance from the phone-side
// case wall to the home plate.
hand_anchor_z = phone_thk + 2;

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
//  HALF-CASE SHELL — magnetic split-dock structure
// ---------------------------------------------------------------------
// Each half is a small case that:
//   (a) IN USE: docks magnetically to one phone short end, keywell
//       facing outward (+Z) so fingers can reach the keys.
//   (b) IN TRANSIT: detaches from phone and snaps face-to-face to the
//       other half. The two bowls mate at their rims, sandwiching
//       both keysets in a sealed cavity for pocket transport.
//
// Two magnet groups per half:
//   - DOCK magnets on the back panel (phone-facing) — grip phone
//     (or a thin steel back-plate / phone case insert).
//   - MATE magnets on the bowl RIM (other-half-facing) — snap halves
//     together face-to-face for transit, with reversed polarity vs
//     dock so the unit can't accidentally re-dock backwards.
//
// All shell geometry below is preview-grade only — real wall
// thicknesses + pocket sizes + retention features land in the
// shell-pass after geometry tune is locked.

case_back_thk    = 1.5;     // case wall against phone back (mm)
case_wall_thk    = 2.0;     // side walls of the half-shell
case_rim_thk     = 2.5;     // bowl-rim ridge thickness (mate face)

// Half-shell footprint (right hand, hand-local frame). Slightly larger
// than the keywell bounding so walls clear the keys.
shell_x_min      = -22;     // toward phone center (fingertip side)
shell_x_max      =  38;     // toward palm side
shell_y_min      = -45;     // bottom edge (index side)
shell_y_max      =  40;     // top edge (pinky side)
shell_z_top      =  22;     // outer top of the half-shell (above hand
                            // anchor) — pocket budget target.

// Magnets — 6 x 2 mm neodymium discs (small, cheap, strong enough for
// dock + mate retention at this scale).
magnet_d         = 6;
magnet_h         = 2;
magnet_pocket_d  = 6.2;     // slight clearance for press-fit + glue
magnet_pocket_h  = 2.1;

// Dock magnets — 4 along the phone-facing back panel of each half.
// Positions are in hand-local XY at z = back-panel mid-plane.
dock_magnets = [
  [ 28,  30, 0 ],  // outboard-top
  [ 28, -35, 0 ],  // outboard-bottom
  [ -10,  30, 0 ], // inboard-top
  [ -10, -35, 0 ], // inboard-bottom
];

// Mate magnets — 4 around the bowl rim, on the half-to-half face.
// Positions are along the keywell-rim trace, z at shell_z_top.
mate_magnets = [
  [ 30,  35, 0 ],
  [ 30, -40, 0 ],
  [ -18, 35, 0 ],
  [ -18,-40, 0 ],
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

// Half-shell sketch — outer case wall around the keywell with marked
// magnet pockets on (a) the phone-facing back, (b) the half-to-half
// mating rim. Preview-grade: real fillets/pocket retention added in
// the shell-pass.
module half_shell_local() {
  // Outer shell — boxy footprint, hollow inside.
  difference() {
    // Outer hull
    color([0.7, 0.7, 0.75, 0.45])
      translate([(shell_x_min + shell_x_max)/2,
                 (shell_y_min + shell_y_max)/2,
                 shell_z_top/2])
        cube([shell_x_max - shell_x_min,
              shell_y_max - shell_y_min,
              shell_z_top], center=true);
    // Inner cavity (subtract a slightly smaller box, leaving walls)
    translate([(shell_x_min + shell_x_max)/2,
               (shell_y_min + shell_y_max)/2,
               (case_back_thk + shell_z_top)/2 + 0.01])
      cube([shell_x_max - shell_x_min - 2*case_wall_thk,
            shell_y_max - shell_y_min - 2*case_wall_thk,
            shell_z_top - case_back_thk], center=true);
  }
  // Dock magnet pockets on the back panel (z ≈ 0..magnet_pocket_h)
  color([0.9, 0.3, 0.3])
    for (m = dock_magnets)
      translate([m[0], m[1], magnet_pocket_h/2])
        cylinder(h = magnet_pocket_h, d = magnet_pocket_d, center = true);
  // Mate magnet pockets on the bowl rim (z ≈ shell_z_top - magnet_pocket_h)
  color([0.3, 0.6, 0.9])
    for (m = mate_magnets)
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

// Right-hand half-shell anchored to phone (in-use position).
module hand_right_shell() {
  translate([hand_anchor_x, hand_anchor_y, phone_thk])
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

// Phone body — rounded-corner hull + camera bump silhouette.
// TODO: refine bump cluster (3 lens cylinders) when polish is wanted.
module phone_body() {
  color([0.18, 0.18, 0.20, 0.55]) {
    hull() {
      for (sx = [-1, 1])
        for (sy = [-1, 1])
          translate([sx * (phone_len/2 - corner_r),
                     sy * (phone_wid/2 - corner_r), 0])
            cylinder(h = phone_thk, r = corner_r);
    }
    // Camera bump
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
  phone_body();
  hand_right_shell();
  hand_right();
  hand_left_shell();
  hand_left();
} else if (render_mode == "transit") {
  // Right half: removed from its in-use hand_anchor position so it
  // sits centered at the world origin (the transit unit has no phone).
  translate([-hand_anchor_x, 0, -phone_thk]) {
    hand_right_shell();
    hand_right();
  }
  // Left half: same recentering, then flipped 180° around X so its
  // bowl opens DOWN, then lifted in Z to mate at the rim of the
  // right half.
  translate([0, 0, 2*shell_z_top + transit_mate_gap])
    rotate([180, 0, 0])
      translate([hand_anchor_x, 0, -phone_thk]) {
        hand_left_shell();
        hand_left();
      }
} else if (render_mode == "right") {
  hand_right_shell();
  hand_right();
}
