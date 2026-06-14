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
hand_anchor_z = phone_thk + 6;   // float keywell above phone back

// Whole-hand tilt — fine adjustments after the per-column block is set
hand_tent_x   = 0;        // rotate around X (lifts pinky side or index)
hand_pitch_y  = 4;        // rotate around Y (tips top of column out)

// ---------------------------------------------------------------------
//  COLUMN GEOMETRY — dactyl-manuform parametric
// ---------------------------------------------------------------------
cols_per_hand = 5;        // pinky, ring, middle, idx_outer, idx_inner
rows_per_col  = 3;        // top / home / bottom

// Column arc — rotation between successive rows around column pivot.
column_curvature = 16;    // deg

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

// Effective column-arc radius (mm). Derived from arc-length so spacing
// stays honest as you change column_curvature.
row_radius       = row_spacing / (column_curvature * 3.14159265 / 180);

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
// Columns step along Y; rows curl in the X-Z plane around a pivot
// row_radius below the home key. This is the standard dactyl-manuform
// column placement, rotated 90° from the v0 scaffold.
module place_key(col, row) {
  y_pos   = column_y_pos[col];
  x_stag  = column_x_stagger[col];
  z_off   = column_z_offset[col];
  row_rel = row - 1;        // 0=home, -1=top (fingertip), +1=bottom (palm)
  col_rel = col - 2;        // splay center = middle column

  translate([x_stag, y_pos, z_off])
    rotate([0, 0, row_curvature * col_rel])    // splay (in-plane fan)
      translate([0, 0, -row_radius])
        rotate([0, column_curvature * row_rel, 0])   // column curl
          translate([0, 0, row_radius])
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

// Mirror right hand across the YZ plane.
module hand_left() {
  mirror([1, 0, 0]) hand_right();
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
//  RENDER TARGETS — comment / uncomment to taste
// ---------------------------------------------------------------------

// FULL RIG — phone + both hand-halves (default for shape review)
phone_body();
hand_right();
hand_left();

// Single half — uncomment if you want to inspect the right hand alone
// phone_body();
// hand_right();

// Print target (right half only) — comment phone_body() above; render
// F6 to STL. Not meaningful until keywell shell + switch cutouts land.
// hand_right();
