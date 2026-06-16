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

/* [Render Mode] */
// Which configuration to render — in_use (phone + halves docked),
// transit (interlocked pocket brick), or right (single half).
render_mode = "in_use"; // ["in_use", "transit", "right"]

/* [Phone Body — S24U bare] */
// Bare S24U dimensions (mm) — only adjust if Samsung ever changes.
phone_len_bare = 162.3; // [150:0.1:175]
phone_wid_bare =  79.0; // [70:0.1:90]
phone_thk_bare =   8.6; // [6:0.1:12]

/* [Phone Case — Otterbox Commuter add] */
// Per-face add from the Commuter case. Bump these if you measure your
// case differently or swap to a thicker case (Defender etc).
case_add_xy   =  2.5; // [0:0.1:8]
case_add_z    =  2.2; // [0:0.1:8]

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

/* [Hand Placement] */
// Wrist anchor X — distance from cased-phone center to right wrist
// (mirrored for left). Higher = palm sits further outboard.
hand_anchor_x = 55;   // [30:0.5:80]
hand_anchor_y =  0;   // [-15:0.5:15]
// Home Z is the keywell's lowest point above the cradle back panel.
hand_anchor_z = phone_thk + case_back_thk_placeholder();
function case_back_thk_placeholder() = 2;

// Whole-hand tilt around X (lifts pinky or index side).
hand_tent_x   = 0;    // [-25:0.5:25]
// Whole-hand pitch around Y (tips top of column toward / away).
hand_pitch_y  = 4;    // [-15:0.5:20]

/* [Column Geometry] */
cols_per_hand = 5;   // [3:1:6]
rows_per_col  = 3;   // [2:1:4]

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
// Column arc: TOP angle (home -> fingertip row). Shallow bowl.
column_curvature_top    = 10;  // [4:0.5:25]
// Column arc: BOTTOM angle (home -> palm/trigger row). 80 = nearly
// perpendicular trigger-pull face.
column_curvature_bottom = 80;  // [10:1:90]

// Row arc — splay between adjacent columns (around Z, in-plane fan).
// Small here because columns ride the phone's narrow 79mm short axis.
row_curvature    = 4;     // deg per column-from-middle

// Per-column tunables. Squeezebox v2209 calls these "slots"; here
// they're arrays you edit and re-render. Indices: [pinky, ring,
// middle, idx_outer, idx_inner].

// Y position of each column relative to hand anchor (mm). Pinky on
// +Y (top edge), index columns on -Y (bottom edge). 18 mm pitch is
// the Choc standard — earlier value of 14-15 mm caused keycap overlap.
column_y_pos    = [ 36, 18,  0, -18, -36 ];

// Per-column palm-to-fingertip X stagger (mm). Negative = pulled
// toward fingertip (further -X for right hand). Middle is the
// reference (0); pinky/index shorter so they're pulled back.
column_x_stagger = [ 6,  2,  0,  3, 10 ];

// Per-column Z offset (mm). Middle highest because the middle finger
// is the longest; pinky/index drop.
column_z_offset  = [-2, -1,  0, -1, -3 ];

// Row pitch — arc-length between rows along column arc.
row_spacing      = 17; // [12:0.5:22]
row_radius_top    = row_spacing / (column_curvature_top * 3.14159265 / 180);

// Bottom-arc radius (set directly, not derived). Tighter = sharper
// trigger-pull, less Z lift. Loose = more dactyl-ish curve.
row_radius_bottom = 8; // [4:0.5:30]

/* [Switch + Plate] */
plate_thk     = 1.3; // [0.8:0.1:2.5]
choc_cutout   = 14;  // [13:0.1:16]
keycap_xy     = 18;  // [12:0.5:22]
keycap_h      = 4;   // [3:0.1:9]

/* [Thumb Cluster — 4-face cube] */
// 4 keys arranged on 4 of the 6 faces of a virtual cube around the
// thumb tip rest position. The thumb's natural motions reach each:
//   HOME    — bottom face of cube, parallel to screen (cap +Z normal).
//             Pressed by push-down.
//   +X face — pressed by thumb FLEXING back toward the palm.
//   +Y face — pressed by lateral tip motion toward pinky side.
//   -Y face — pressed by lateral tip motion toward index side.
// The -X face (away from palm) is unused — thumb shouldn't extend.
// The -Z face (below) is unused — no thumb reach from underneath.
//
// 3-vector anchor [x palm-side, y inboard, z above floor] in hand-local
// frame. Default places cluster INSIDE the shoulder wing.
thumb_anchor       = [ 30, -43, 0 ];
thumb_yaw_z        = -14; // [-45:1:45]
thumb_pitch_y      = 8;   // [-30:1:30]
// Cube edge must exceed a keycap (keycap_xy=18) plus wall, or the
// face keys overlap into a tangle. 22 gives ~2mm gap between caps.
thumb_cube_size    = 22;  // [16:0.5:32]  // edge length of the surrounding cube

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

/* [Half-Cradle Walls] */
case_back_thk    = 2.0;  // [0.8:0.1:5]
case_wall_thk    = 2.5;  // [1:0.1:6]
case_rim_thk     = 2.5;  // [1:0.1:6]
cradle_lip_h     = 5;    // [0:0.5:12]
cradle_long_extent = 80; // [40:1:90]

shell_x_seam     = 3;                     // half of 7 mm seam gap
shell_x_outboard = phone_len/2 + case_wall_thk;
shell_center_x   = (shell_x_seam + shell_x_outboard) / 2;
// Y extent of the half-shell. Independent of phone_wid — sized to bound
// the keywell + a buffer. With the 4-paddle thumb cage fanning -Y, the
// extreme paddle caps reach Y ≈ -55. Shell to ±55 keeps them inside.
// Pinky side doesn't need this much but symmetric Y keeps the L/R mirror
// symmetric. Use Customizer sliders to scrub tighter.
shell_y_min      = -55; // [-65:0.5:-30]
shell_y_max      =  55; // [30:0.5:65]
shell_z_back     = phone_thk;

/* [L-Profile + Transit Interlock] */
// Height of keywell zone above back panel (tall zone of L-profile).
shell_z_top_extra      = 18;  // [10:0.5:30]
shell_z_top            = shell_z_back + case_back_thk + shell_z_top_extra;
// Height of the inboard short zone (just back panel + low shell).
shell_z_short_extra    = 2;   // [0:0.5:20]
shell_z_short_top      = shell_z_back + case_back_thk + shell_z_short_extra;
// X boundary between the short and tall zones (in cradle frame).
// Set well inboard of the leftmost keycap edge (middle-column top row
// reaches ~x=29 with the 10° top curl). Was 35; that clipped caps.
shell_x_step           = 25;  // [10:0.5:60]
// Transit X-shift for the flipped left half. Default 2*(step-seam)
// puts the tall zones at opposite X extremes — override to slide one
// half further in/out and see the interlock change.
transit_x_shift        = (shell_x_step - shell_x_seam) * 2;  // [0:0.5:120]
// Gap between mated faces in transit (mm).
transit_mate_gap       = 2;   // [0:0.1:8]

/* [Shoulder Wing — thumb cluster home] */
// A small +X bump off the main cradle's outboard wall, sized to hold
// the thumb cage where the thumb naturally rests. The wing connects to
// the main shell at X=shell_x_outboard and extends OUTBOARD in +X +
// inboard in -Y. It has its own short keywell zone — paddles sit here,
// not inside the main keywell.
wing_x_extension  = 12;   // [0:0.5:25]   how far +X past shell_x_outboard
wing_y_min        = -62;  // [-70:0.5:-25]
wing_y_max        = -25;  // [-45:0.5:0]
wing_z_top_extra  = 15;   // [0:0.5:25]   cube layout needs height for side keys
wing_z_top        = shell_z_back + case_back_thk + wing_z_top_extra;
wing_x_outboard   = shell_x_outboard + wing_x_extension;

/* [Magnets] */
magnet_d         = 6;    // [3:0.1:10]
magnet_h         = 2;    // [1:0.1:5]
magnet_pocket_d  = 6.2;  // [3:0.1:10]
magnet_pocket_h  = 2.1;  // [1:0.1:5]

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

/* [Palm Key — grip-activation dead-man switch] */
// NOT a normal keycode. Both palm keys (one per half) must be held for
// the board to go active — signals "gripped between two hands", blocks
// stray presses when stowed / one-handed. (See memory Item #1716.)
//
// Placement: INSET into the OUTBOARD END FACE (+X wall) of each half,
// cap facing +X. Pressed by the palm squeezing INWARD as the hands grip
// the device between them — the natural "I'm holding this" gesture.
// Cradle-frame Y/Z position on that wall.
palm_face_y      = 8;    // [-30:1:40]   // Y on the outboard wall
palm_face_z      = 20;   // [10:0.5:32]  // Z (height) on the outboard wall
palm_inset_xy    = 16;   // [10:0.5:24]  // recess pocket footprint
palm_inset_depth = 3;    // [1:0.5:8]    // recess depth into the wall

/* [Hidden] */
// Anything below this group marker is hidden from the Customizer panel
// but still in scope for the program. Use to stash render constants.

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
// 4-key cube around the thumb tip. The thumb enters the cube from the
// palm/shoulder side (+X), so the +X face is OPEN (thumb shaft) and the
// top (+Z) is open too. The 4 keys are on the other faces, press
// surfaces facing INWARD — the thumb pushes OUTWARD against each:
//
//   HOME   at  (0,  0,  0)            cap normal +Z   push DOWN
//   -X     at  (-hc, 0, hc)           cap normal +X   PUSH forward (tip in)
//   +Y     at  (0,  hc, hc)           cap normal -Y   lateral toward pinky
//   -Y     at  (0, -hc, hc)           cap normal +Y   lateral toward index
//
// Open faces: +X (thumb entry, toward palm) and +Z (top). where
// hc = thumb_cube_size / 2.
module thumb_cluster_local() {
  hc = thumb_cube_size / 2;
  translate(thumb_anchor)
    rotate([0, thumb_pitch_y, thumb_yaw_z]) {
      // HOME — parallel to screen, no rotation
      translate([0, 0, 0])
        key_preview();
      // -X face — cap normal +X, pressed by thumb tip pushing forward
      translate([-hc, 0, hc])
        rotate([0, 90, 0])
          key_preview();
      // +Y face — cap normal -Y, pressed by lateral tip toward pinky
      translate([0, hc, hc])
        rotate([90, 0, 0])
          key_preview();
      // -Y face — cap normal +Y, pressed by lateral tip toward index
      translate([0, -hc, hc])
        rotate([-90, 0, 0])
          key_preview();
    }
}

// Palm key — grip-activation dead-man switch, INSET into the outboard
// END WALL (+X face), cap facing +X (pressed by inward palm squeeze).
// Rendered in CRADLE frame (structural, not part of the hand keywell).
// Recessed pocket rim (grey) + switch flush at the bottom (green).
module palm_activation_local() {
  translate([shell_x_outboard, palm_face_y, palm_face_z])
    rotate([0, 90, 0]) {            // local +Z -> world +X (into wall)
      // Recess rim — frame at the wall surface.
      color([0.6, 0.6, 0.65, 0.6])
        translate([0, 0, -palm_inset_depth/2])
          difference() {
            cube([palm_inset_xy + 4, palm_inset_xy + 4, palm_inset_depth],
                 center = true);
            cube([palm_inset_xy, palm_inset_xy, palm_inset_depth + 1],
                 center = true);
          }
      // Activation switch — flush at the bottom of the recess (green).
      color([0.3, 0.7, 0.4])
        translate([0, 0, -palm_inset_depth + plate_thk/2])
          cube([palm_inset_xy - 2, palm_inset_xy - 2, plate_thk],
               center = true);
    }
}

// Half-cradle — wraps half the cased phone (one short end), provides
// the keywell mount surface, and exposes both magnet sets.
//
// In cradle frame: the cased phone sits at z = 0 .. phone_thk. The
// cradle's back panel sits at z = phone_thk .. phone_thk+case_back_thk.
// The keywell mounts above that.
module half_shell_local() {
  // Outer cradle hull — L-profile, then a SINGLE continuous L-shaped
  // cavity hollow (no internal partition between zones).
  //
  // Outer hull: union of the tall zone box (x_step..x_outboard, full
  // keywell height) and the short zone box (x_seam..x_step, low shell).
  // Cavity: ONE L-shape with two parts:
  //   - LOW part — runs the full length (seam to outboard) at z up to
  //     shell_z_short_top. Below that height the cavity is continuous;
  //     no inboard partition wall between zones.
  //   - HIGH part — only in the tall zone above shell_z_short_top.
  //     This part is inset by case_wall_thk on the inboard side, so the
  //     OUTER L-step face has a 2.5 mm wall behind it (the actual outer
  //     step skin) but only ABOVE shell_z_short_top.
  difference() {
    // Outer hull = tall + short + wing boxes booleaned together.
    union() {
      color([0.7, 0.7, 0.75, 0.45])
        translate([(shell_x_step + shell_x_outboard)/2,
                   (shell_y_min  + shell_y_max)/2,
                   shell_z_top / 2])
          cube([shell_x_outboard - shell_x_step,
                shell_y_max - shell_y_min,
                shell_z_top], center = true);
      color([0.7, 0.7, 0.75, 0.45])
        translate([(shell_x_seam + shell_x_step)/2,
                   (shell_y_min  + shell_y_max)/2,
                   shell_z_short_top / 2])
          cube([shell_x_step - shell_x_seam,
                shell_y_max - shell_y_min,
                shell_z_short_top], center = true);
      // Shoulder wing — small +X bump for the thumb cluster.
      color([0.75, 0.7, 0.7, 0.45])
        translate([(shell_x_outboard + wing_x_outboard)/2,
                   (wing_y_min + wing_y_max)/2,
                   wing_z_top / 2])
          cube([wing_x_outboard - shell_x_outboard,
                wing_y_max - wing_y_min,
                wing_z_top], center = true);
    }

    // Phone cavity — full L length (continuous across both zones).
    translate([(shell_x_seam + shell_x_outboard)/2,
               (shell_y_min + shell_y_max)/2,
               (phone_thk - cradle_lip_h) / 2])
      cube([shell_x_outboard - shell_x_seam + 1.0,
            phone_wid + 1.0,
            phone_thk - cradle_lip_h + 0.01], center = true);

    // Keywell cavity — LOW part (continuous across seam+tall at low z).
    // X spans the full L from seam-wall to outboard-wall inset.
    translate([(shell_x_seam + case_wall_thk + shell_x_outboard - case_wall_thk)/2,
               (shell_y_min + shell_y_max)/2,
               (phone_thk + case_back_thk + shell_z_short_top)/2])
      cube([shell_x_outboard - shell_x_seam - 2*case_wall_thk,
            (shell_y_max - shell_y_min) - 2*case_wall_thk,
             shell_z_short_top - phone_thk - case_back_thk + 0.01],
           center = true);

    // Keywell cavity — HIGH part (tall zone only, above short ceiling).
    // Inset case_wall_thk on inboard side so the outer L-step skin is
    // preserved above shell_z_short_top. Z range overlaps the low part
    // by 0.01 mm to ensure CSG joins them into one continuous cavity.
    translate([(shell_x_step + case_wall_thk + shell_x_outboard - case_wall_thk)/2,
               (shell_y_min + shell_y_max)/2,
               (shell_z_short_top + shell_z_top)/2 + 0.01])
      cube([shell_x_outboard - shell_x_step - 2*case_wall_thk,
            (shell_y_max - shell_y_min) - 2*case_wall_thk,
             shell_z_top - shell_z_short_top + 0.02],
           center = true);

    // Shoulder wing cavity — extends INBOARD into the main shell area
    // in the wing's Y range, so the cluster's caps can flow freely
    // between wing and main keywell without hitting an internal wall.
    // X starts at shell_x_step + case_wall_thk (same as main high cavity)
    // and ends at wing_x_outboard - case_wall_thk.
    translate([(shell_x_step + case_wall_thk + wing_x_outboard - case_wall_thk)/2,
               (wing_y_min + case_wall_thk + wing_y_max - case_wall_thk)/2,
               (phone_thk + case_back_thk + wing_z_top)/2])
      cube([wing_x_outboard - shell_x_step - 2*case_wall_thk,
            wing_y_max - wing_y_min - 2*case_wall_thk,
            wing_z_top - phone_thk - case_back_thk + 0.01],
           center = true);
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
// finger keywell + thumb in the hand-local frame. (Palm activation is
// in the SHELL, not the hand keywell — it's on the outboard end wall.)
module hand_right() {
  translate([hand_anchor_x, hand_anchor_y, hand_anchor_z])
    rotate([hand_tent_x, hand_pitch_y, 0]) {
      keywell_local();
      thumb_cluster_local();
    }
}

// Right-hand half-shell in cased-phone frame. The cradle's own origin
// is the seam plane (x=0), so we just call it directly; no
// hand_anchor offset (the keywell math inside still uses hand_anchor).
// Palm activation inset rides on the shell's outboard wall.
module hand_right_shell() {
  half_shell_local();
  palm_activation_local();
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
// (render_mode is also set as a Customizer dropdown at the top of the
// file — use the panel or the CLI -D flag; the editor-pane variable
// has been moved to the Customizer block.)
//
// transit_mate_gap also lives in the L-Profile group above.

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
