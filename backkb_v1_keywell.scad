// =====================================================================
//  BACKKB v1 — sculpted keywell, dactyl-manuform style
//
//  Same S24U-grip frame as v0; replaces the flat back panel with a
//  column-curved keywell, expanded thumb cluster, and a palm key.
//
//  Per side: 5 finger columns × 3 rows  +  2 thumb keys  +  1 palm key
//           = 18 keys/side, 36 total.
//  (v0 had 5×3 + 1 thumb = 16/side; v1 adds a second thumb + a palm.)
//
//  Status: SCAFFOLD. Parameter blocks + placement math + module stubs.
//  Switch cutouts and webbing are TODO and called out inline. Render
//  F5 (preview) for layout; F6/STL not meaningful until cutouts land.
//
//  Coordinate frame:
//    +X = along the phone's long edge (right-half is +X)
//    +Y = away from the user (toward camera bump on S24U)
//    +Z = away from the phone back (out toward fingertips)
//    Phone back sits at z=0. Keywell rises above it.
//
//  Units: mm. Author: scaffold for Rob (Item #1691 iteration).
// =====================================================================

$fn = 48;

// ---------------------------------------------------------------------
//  PHONE BODY — carry over from v0 (parameters only; module is stubbed)
// ---------------------------------------------------------------------
phone_len   = 162.3;
phone_wid   = 79.0;
phone_thk   = 8.6;
corner_r    = 6.0;
fit_gap     = 0.6;

// ---------------------------------------------------------------------
//  COLUMN GEOMETRY — dactyl-manuform parametric
// ---------------------------------------------------------------------

// 5 cols per hand: pinky, ring, middle, index-outer, index-inner.
cols_per_hand = 5;
rows_per_col  = 3;     // top / home / bottom

// Column arc — rotation between successive rows around the column's
// pivot (deg). 16-20 typical for dactyl-manuform; lower for shallower.
column_curvature   = 16;

// Row arc — horizontal splay across columns (deg per column).
// Small here because the columns ride the phone's narrow back; a
// large splay would walk off the phone edge.
row_curvature      = 4;

// Per-column Z offset (mm). Middle highest, index/pinky lower so they
// follow finger-length staggering when fingers curl around the phone.
// [pinky, ring, middle, idx_outer, idx_inner]
column_z_offsets = [ -2, -1,  0, -1, -3 ];

// Per-column Y stagger (mm). Middle furthest from spine; index curls
// inboard. Tune to fingertip natural rest positions on the phone back.
column_y_offsets = [ -4, -1,  0, -2, -6 ];

// X-spacing between adjacent columns (mm). Choc-friendly default.
column_spacing = 18;

// Row pitch (arc-length between rows on the column arc, mm).
row_spacing    = 17;

// Effective radius of the column arc. derived: arc-length = radius *
// angle_radians; back-solve for radius so the key spacing is honored.
row_radius     = row_spacing / (column_curvature * 3.14159265 / 180);

// Where the keywell sits relative to the phone back plane.
keywell_origin_z = phone_thk + 6;   // float keywell above phone back
keywell_origin_y = 8;               // forward of phone center
keywell_tent_deg = 6;               // tent the whole well slightly

// ---------------------------------------------------------------------
//  SWITCH + PLATE
// ---------------------------------------------------------------------
plate_thk      = 1.3;
choc_cutout    = 14;   // square plate cutout for Kailh Choc v1
keycap_xy      = 18;   // for clearance preview
keycap_h       = 4;    // choc keycap, low profile

// ---------------------------------------------------------------------
//  THUMB CLUSTER — 2 keys per side
// ---------------------------------------------------------------------
// Origin is given in keywell local frame, relative to the bottom-
// inboard finger column. Cluster fans inboard + downward.
thumb_origin   = [ -22, -32, -6 ];
thumb_yaw      = 18;
thumb_pitch    = 6;
thumb_spacing  = 19;   // between the 2 thumb keys

// ---------------------------------------------------------------------
//  PALM KEY — 1 per side
// ---------------------------------------------------------------------
// Pressed by the heel of the thumb / palm pad; behind the thumbs and
// lower so it doesn't get rolled accidentally.
palm_origin    = [ -10, -58, -12 ];
palm_yaw       = 0;
palm_pitch     = -10;

// ---------------------------------------------------------------------
//  MODULES — preview only. TODO markers mark real-build work.
// ---------------------------------------------------------------------

// Switch+keycap preview block at origin. Single-color, no cutout.
// TODO: replace with real Choc v1 plate cutout module (14mm square
//       + 5 retention notches per Kailh datasheet, plate_thk=1.3).
module key_preview() {
  color([0.40, 0.50, 0.72])
    translate([0, 0, plate_thk/2])
    cube([keycap_xy, keycap_xy, plate_thk], center=true);
  color([0.55, 0.65, 0.88, 0.85])
    translate([0, 0, plate_thk + keycap_h/2])
    cube([keycap_xy - 2, keycap_xy - 2, keycap_h], center=true);
}

// Place one key in a column.
//   col       — 0..cols_per_hand-1, 0 = pinky, 4 = index-inner
//   row       — 0..rows_per_col-1,  0 = top, 1 = home, 2 = bottom
//
// Column curl: rotate the row around the column's pivot point
// (offset by row_radius below the key) by column_curvature * row_rel.
// Row curl: rotate the column around Y by row_curvature * col_rel
// (middle column is the splay center).
module place_key(col, row) {
  z_off  = column_z_offsets[col];
  y_off  = column_y_offsets[col];
  row_rel = row - 1;       // 0 = home, -1 = top, +1 = bottom
  col_rel = col - 2;       // 2 = middle column is the splay center

  translate([col * column_spacing, y_off, z_off])
    rotate([0, row_curvature * col_rel, 0])
      // pivot trick — translate down to pivot, rotate, translate back
      translate([0, 0, -row_radius])
        rotate([column_curvature * row_rel, 0, 0])
          translate([0, 0, row_radius])
            children();
}

// Right-hand finger keywell.
module keywell_right() {
  translate([-((cols_per_hand - 1) * column_spacing) / 2,
             keywell_origin_y,
             keywell_origin_z])
    rotate([0, keywell_tent_deg, 0])
      for (c = [0 : cols_per_hand - 1])
        for (r = [0 : rows_per_col - 1])
          place_key(c, r) key_preview();
}

// Right-hand thumb cluster.
module thumb_cluster_right() {
  translate([thumb_origin[0],
             keywell_origin_y + thumb_origin[1],
             keywell_origin_z + thumb_origin[2]])
    rotate([thumb_pitch, keywell_tent_deg, thumb_yaw])
      for (i = [0, 1])
        translate([i * thumb_spacing, 0, 0])
          key_preview();
}

// Right-hand palm key.
module palm_key_right() {
  translate([palm_origin[0],
             keywell_origin_y + palm_origin[1],
             keywell_origin_z + palm_origin[2]])
    rotate([palm_pitch, keywell_tent_deg, palm_yaw])
      key_preview();
}

// Phone body — rough preview for spatial reference. Stripped of
// rounded corners and camera bump for layout-only.
// TODO: lift the rounded-corner hull from v0 (backkb_s24u.scad).
module phone_body() {
  color([0.20, 0.20, 0.20, 0.45])
    translate([-phone_len/2, -phone_wid/2, 0])
    cube([phone_len, phone_wid, phone_thk]);
}

// END CAPS / PALM RESTS — carry over conceptually from v0.
// TODO: refit endcap_len, endcap_flare, endcap_round around the
//       sculpted keywell silhouette. v0 end caps assume a flat
//       back-plane neighbor; v1 keywell rises away from it, so the
//       end caps need to ramp up.

// KEYWELL SHELL (the sculpted body that gives dactyl-manuform its
// hand-fitting feel).
// TODO: stock dactyl approach — hull() between adjacent plate frames
//       (col,row) ↔ (col+1,row), (col,row) ↔ (col,row+1), and the
//       diagonal pairs. ~150 lines when filled in. Stubbed here so
//       the parameter block (curl/splay/offsets/tent) can be tuned
//       on key positions first; shell follows after.

// SWITCH CUTOUTS — replace key_preview() with real plate-with-cutout
// once the parametric block is dialed.

// ---------------------------------------------------------------------
//  RENDER TARGETS — comment / uncomment to taste
// ---------------------------------------------------------------------

// Right-half preview (default — solid keys for F5 layout review)
phone_body();
keywell_right();
thumb_cluster_right();
palm_key_right();

// Full rig — uncomment to mirror the left half
// mirror([1, 0, 0]) {
//   keywell_right();
//   thumb_cluster_right();
//   palm_key_right();
// }

// Print target — comment phone_body() above, render F6 (STL).
// Not meaningful until keywell shell + switch cutouts land.
