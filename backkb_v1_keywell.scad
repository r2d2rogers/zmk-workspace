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
render_mode = "in_use"; // ["in_use", "transit", "right", "clamp_phone", "clamp_tablet", "clamp_latch", "clamp_release", "slide_open", "slide_locked"]

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

/* [Thumb Cluster — 4-key cage on the TOP edge] */
// Per the grip reference (conv #119): the thumb lies along the TOP long
// edge. Motions and the key each reaches:
//   HOME   press toward the phone (-Y)         — cap +Y, at the edge
//   LEFT   rock perpendicular toward back (+Z) — cap +Z (cage wall)
//   RIGHT  rock perpendicular toward front (-Z)— cap -Z (cage wall)
//   4TH    extend along the long edge (-X)      — cap +Y, inboard
// The thumb sits on the +Y (outer) side and enters from +X (palm).
//
// Mounted in CRADLE frame on the shell's top edge (structural), not the
// hand keywell frame.
thumb_edge_x       = 60;  // [40:0.5:80]  // position along the top edge
thumb_edge_z       = 15;  // [0:0.5:28]   // height — sit as a tower on the edge
thumb_edge_yaw     = 0;   // [-45:1:45]   // cluster yaw to match grip
// TIGHT cage — the thumb stays PLANTED in the center and makes small
// tilts/presses to hit each surrounding key. Keep this small (sized to
// the thumb tip, not a keycap) so the keys surround the tip closely.
// The cage keys use a compact switch-sized plate (thumb_key_size), so a
// tight cube reads as 4 close keys, not the overlapping-keycap tangle.
thumb_cube_size    = 15;  // [10:0.5:24]  // tip-sized, NOT keycap-sized
thumb_key_size     = 12;  // [8:0.5:16]   // compact cage-key footprint

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
// Outer corner rounding of the half-shell (vertical edges).
corner_r_shell         = 3;   // [0:0.5:8]
// Y line where the +Y (top) edge OPENS above the cradle — full-height
// wall is kept on -Y (bottom) + both ends, open on +Y for thumb access.
// In transit the flip swaps it so the other half's wall covers it.
shell_y_open           = 30;  // [0:0.5:50]

/* [Shoulder Wing — thumb cluster home] */
// A small +X bump off the main cradle's outboard wall, sized to hold
// the thumb cage where the thumb naturally rests. The wing connects to
// the main shell at X=shell_x_outboard and extends OUTBOARD in +X +
// inboard in -Y. It has its own short keywell zone — paddles sit here,
// not inside the main keywell.
// Wing RETIRED — the thumb moved to the top edge (conv #119), so the
// +X shoulder bump is no longer needed. Set wing_x_extension = 0 to
// retract it; geometry is guarded on >0 so zero is safe.
wing_x_extension  = 0;    // [0:0.5:25]   how far +X past shell_x_outboard
wing_y_min        = -62;  // [-70:0.5:-25]
wing_y_max        = -25;  // [-45:0.5:0]
wing_z_top_extra  = 15;   // [0:0.5:25]
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

// RIM magnets — on the two TRANSIT contact surfaces. In transit the
// flipped+shifted left half lands its tall-zone bottom on the right
// half's SHORT-zone top (z=shell_z_short_top), and its short-zone on the
// right half's TALL-zone top (z=shell_z_top). Put magnets on both
// surfaces so the mated unit is held. [x, y, z] — z is the surface.
// Reversed polarity vs SEAM so a no-phone jostle can't re-dock in-use.
rim_magnets = [
  // short-zone top (inboard, low)
  [ 14,  35, shell_z_short_top ],
  [ 14, -35, shell_z_short_top ],
  // tall-zone top (outboard, high)
  [ 55,  35, shell_z_top ],
  [ 55, -35, shell_z_top ],
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

/* [Corner Clamp — universal sprung grip + transit latch] */
// The cradle is REPLACED by a sprung corner clamp at each half's
// outboard lower corner. It grips the device's lower-outer CORNER (two
// edges at once → self-centering on any rectangular device), so device
// size becomes spring travel, not a molded dimension. Phone and tablet
// corners are both ~90°, so the SAME jaw grips both — only the corner
// radius differs and the V-faces ride the straight edge just past it.
//
// DUAL USE (Rob, conv #119):
//   - IN USE  : flexure presses the device corner into the fixed V.
//   - IN TRANSIT: the same flexure's CATCH snaps into a STRIKE pocket on
//     the opposing half's shell, locking the brick. Squeezing the jaw
//     open (the device-insert motion) is ALSO the transit RELEASE.
//     [ASSUMPTION flagged to Rob: squeeze-to-release. If he wants a
//      separate tab / slide release, only the catch + slot change.]
clamp_jaw_depth   = 16;  // [8:0.5:30]  reach along each edge from corner
clamp_wall_thk    = 3.0; // [1.5:0.1:6] jaw wall thickness
clamp_lip_z       = 3.5; // [0:0.5:8]   lip onto device front face (Z grip)
clamp_height_z    = 11;  // [6:0.5:20]  jaw height spanning device thickness
clamp_chamfer     = 2.0; // [0:0.1:5]   lead-in chamfer on grip-wall top edge
clamp_squeeze_demo= 3.0; // [0:0.1:8]   latch-wall inward travel for release view
// Flexure (the spring). Thin cantilever on the long-edge arm; a slot
// behind it lets it deflect outward to admit the corner / release latch.
clamp_flex_thk    = 1.6; // [0.8:0.1:3] flexure wall (spring rate)
clamp_flex_len    = 20;  // [10:0.5:34] flexure cantilever length
clamp_flex_slot   = 2.0; // [1:0.1:5]   deflection slot width behind flexure
clamp_flex_travel = 2.5; // [0:0.1:6]   modeled outward deflection for demos
// Transit latch catch on the flexure exterior + its strike pocket.
clamp_catch_h     = 1.8; // [0:0.1:4]   catch bump protrusion
clamp_catch_len   = 6;   // [2:0.5:12]  catch bump length along edge
// Demo device sizes (corner grip render). [w_short, l_long, thk, corner_r]
demo_phone  = [ 84, 167, 13, 9 ];   // S24U in Otterbox (matches phone_*)
demo_tablet = [ 170, 250, 7, 8 ];   // ~10" tablet corner

// Skirt toggle. false (default) = the new direction: NO phone-cradle box;
// the half is just the keywell shell from the floor up, and the corner
// clamps + cross-tension hold the device (keywell underside = back-rest).
// true = keep the old z 0..floor cradle skirt for comparison.
phone_skirt = false;

/* [Slide-through Latch] */
// Transit lock (Rob): the halves SLIDE together and a T-slot tongue rides
// THROUGH a channel in the mating half, locking them in the transit
// position AND pulling the corner clamp FLUSH with the outer surface
// (instead of proud). The T (head wider than neck) means once slid in it
// can't pull straight out — only slide back. A detent holds it home.
sl_neck       = 3.0;  // [1:0.1:6]   neck opening height (z)
sl_head       = 6.0;  // [3:0.1:12]  head cavity height — T-lock, > neck
sl_neck_depth = 2.0;  // [1:0.1:5]   neck depth (x) before it widens
sl_depth      = 6.0;  // [3:0.1:12]  total slot depth into the wall (x)
sl_wall       = 2.5;  // [1:0.1:6]   wall material around the slot
sl_len        = 18;   // [8:0.5:34]  channel length along the slide axis (y)
sl_tongue_len = 14;   // [6:0.5:30]  tongue length (y)
sl_travel     = 14;   // [4:0.5:30]  how far it slides out (proud) when open
sl_clearance  = 0.3;  // [0:0.05:1]  tongue/channel print + visual clearance

/* [Hidden] */
// Anything below this group marker is hidden from the Customizer panel
// but still in scope for the program. Use to stash render constants.

// ---------------------------------------------------------------------
//  MODULES — preview-grade. TODO markers mark real-build work.
// ---------------------------------------------------------------------

// Switch + keycap preview. The plate (1.3mm) carries a real Choc v1
// 14mm square cutout with the two side retention notches; the keycap
// sits above it. Active surface is +Z. Origin is the plate top center.
module key_preview() {
  // Mounting plate with Choc cutout (14mm + 1mm notches each side).
  color([0.40, 0.50, 0.72])
    difference() {
      translate([0, 0, plate_thk/2])
        cube([keycap_xy, keycap_xy, plate_thk], center = true);
      // 14mm square switch hole
      translate([0, 0, plate_thk/2])
        cube([choc_cutout, choc_cutout, plate_thk + 1], center = true);
      // retention notches (Kailh Choc: 5mm wide x 1mm deep, both sides)
      for (sy = [-1, 1])
        translate([0, sy * (choc_cutout/2 + 0.5), plate_thk/2])
          cube([5, 1.2, plate_thk + 1], center = true);
    }
  // Keycap above the plate.
  color([0.55, 0.65, 0.88, 0.85])
    translate([0, 0, plate_thk + keycap_h/2])
      cube([keycap_xy - 2, keycap_xy - 2, keycap_h], center = true);
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

// Keycap only (no plate) — for rendering caps above the webbed plate.
module keycap_only() {
  color([0.55, 0.65, 0.88, 0.85])
    translate([0, 0, plate_thk + keycap_h/2])
      cube([keycap_xy - 2, keycap_xy - 2, keycap_h], center = true);
}

// Solid plate pad at a key (no cutout) — the hull unit for the web.
module web_pad() {
  translate([0, 0, plate_thk/2])
    cube([keycap_xy, keycap_xy, plate_thk], center = true);
}

// Sculpted keywell web — the dactyl-manuform body. Each key gets a
// plate pad; adjacent pads are hull()'d (down columns, across columns,
// and diagonally) into one continuous contoured surface that follows
// the column curl + splay. Choc cutouts are then subtracted per key.
// Parametric off place_key(), so it re-forms automatically when the
// column geometry is tuned.
module keywell_web() {
  difference() {
    union() {
      // down-column strips
      for (c = [0 : cols_per_hand - 1])
        for (r = [0 : rows_per_col - 2])
          hull() { place_key(c, r) web_pad(); place_key(c, r+1) web_pad(); }
      // across-column strips
      for (c = [0 : cols_per_hand - 2])
        for (r = [0 : rows_per_col - 1])
          hull() { place_key(c, r) web_pad(); place_key(c+1, r) web_pad(); }
      // diagonal fill (closes the 4-key gaps)
      for (c = [0 : cols_per_hand - 2])
        for (r = [0 : rows_per_col - 2])
          hull() {
            place_key(c,   r)   web_pad(); place_key(c+1, r)   web_pad();
            place_key(c,   r+1) web_pad(); place_key(c+1, r+1) web_pad();
          }
    }
    // switch cutouts
    for (c = [0 : cols_per_hand - 1])
      for (r = [0 : rows_per_col - 1])
        place_key(c, r)
          translate([0, 0, plate_thk/2])
            cube([choc_cutout, choc_cutout, plate_thk + 1], center = true);
  }
}

// Perimeter walls — drop a skirt from the outer ring of the web down to
// the cradle floor (hand-local z=0, since hand_anchor_z == cradle top).
// Each wall segment hulls two adjacent perimeter keys together with
// their projection() shadows on the floor — the shadow is true world-
// down (not the key's curled local frame), so walls fall straight even
// under the 80° trigger row. Interior stays hollow for switch bodies.
module keywell_walls() {
  // perimeter ring, ordered (top L→R, down index side, bottom R→L,
  // up pinky side). Built generically so it tracks cols/rows changes.
  ring = concat(
    [ for (c = [0 : cols_per_hand-1])        [c, 0] ],
    [ for (r = [1 : rows_per_col-1])         [cols_per_hand-1, r] ],
    [ for (c = [cols_per_hand-2 : -1 : 0])   [c, rows_per_col-1] ],
    [ for (r = [rows_per_col-2 : -1 : 1])    [0, r] ]
  );
  for (i = [0 : len(ring) - 1]) {
    a = ring[i];
    b = ring[(i + 1) % len(ring)];
    hull() {
      place_key(a[0], a[1]) web_pad();
      linear_extrude(0.6) projection() place_key(a[0], a[1]) web_pad();
      place_key(b[0], b[1]) web_pad();
      linear_extrude(0.6) projection() place_key(b[0], b[1]) web_pad();
    }
  }
}

// Finger keywell — right hand, in hand-local frame. Webbed plate body
// + perimeter walls down to the floor + keycaps on top.
module keywell_local() {
  color([0.40, 0.50, 0.72]) {
    keywell_web();
    keywell_walls();
  }
  for (c = [0 : cols_per_hand - 1])
    for (r = [0 : rows_per_col - 1])
      place_key(c, r) keycap_only();
}

// Thumb cluster — 4-key cage on the TOP edge, CRADLE frame.
// Thumb lies along the edge (axis ~ X), sits on the +Y outer side,
// enters from +X (palm). hc = thumb_cube_size / 2.
//
//   HOME   (0,  hc, 0)  rotate[-90,0,0] -> cap +Y  press toward phone (-Y)
//   LEFT   (0,  0, hc)  no rot          -> cap +Z  rock to back
//   RIGHT  (0,  0,-hc)  rotate[180,0,0] -> cap -Z  rock to front
//   4TH    (-hc,hc, 0)  rotate[-90,0,0] -> cap +Y  extend inboard along edge
// Compact cage key — a thin switch-sized plate (not an 18mm keycap),
// so the tight thumb cage reads as 4 close keys around the tip.
module thumb_key() {
  color([0.40, 0.50, 0.72])
    cube([thumb_key_size, thumb_key_size, plate_thk], center = true);
}

// Rounded box from corner coords — hull of 4 vertical cylinders. Used
// for the shell outer hull so vertical edges are filleted, not square.
module rbox(x0, x1, y0, y1, zh, r) {
  hull()
    for (sx = [x0 + r, x1 - r])
      for (sy = [y0 + r, y1 - r])
        translate([sx, sy, 0])
          cylinder(h = zh, r = r);
}

module thumb_cluster_local() {
  hc = thumb_cube_size / 2;
  // The thumb tip sits at the cage CENTER and makes small motions. The
  // 4 keys surround it on the faces it tilts/presses toward — it does
  // NOT travel along the edge between them.
  translate([thumb_edge_x, shell_y_max - case_wall_thk, thumb_edge_z])
    rotate([0, 0, thumb_edge_yaw]) {
      // HOME — press toward phone (-Y), key on the +Y inner face
      translate([0, hc, 0])
        rotate([-90, 0, 0])
          thumb_key();
      // LEFT cage — tilt to back (+Z)
      translate([0, 0, hc])
        thumb_key();
      // RIGHT cage — tilt to front (-Z)
      translate([0, 0, -hc])
        rotate([180, 0, 0])
          thumb_key();
      // 4TH — small extend inboard (-X)
      translate([-hc, 0, 0])
        rotate([0, 90, 0])
          thumb_key();
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
  // Outer hull: a single full-height box (rounded verticals). Walls are
  // kept full height on -Y (bottom) + both X ends; the +Y (top) edge is
  // OPENED above the cradle for thumb access. In transit the half is
  // flipped about X, which swaps the open +Y to -Y, so the OTHER half's
  // full -Y wall covers this half's opening → a sealed, fully-aligned
  // box with no overhang (no X-shift interlock needed).
  floor_z = phone_thk + case_back_thk;   // cradle top (keywell floor)
  // SKIRT-LESS by default: the shell starts at the keywell floor; the
  // phone is held by the corner clamps + cross-tension, not a box.
  z0 = phone_skirt ? 0 : floor_z;
  difference() {
    color([0.7, 0.7, 0.75, 0.45])
      translate([0, 0, z0])
        rbox(shell_x_seam, shell_x_outboard,
             shell_y_min, shell_y_max, shell_z_top - z0, corner_r_shell);

    // Phone cavity (only with the old skirt — where the cased phone sits).
    if (phone_skirt)
    translate([(shell_x_seam + shell_x_outboard)/2,
               (shell_y_min + shell_y_max)/2,
               (phone_thk - cradle_lip_h) / 2])
      cube([shell_x_outboard - shell_x_seam + 1.0,
            phone_wid + 1.0,
            phone_thk - cradle_lip_h + 0.01], center = true);

    // Keywell interior cavity — single box above the cradle, inset by
    // case_wall_thk so the perimeter walls remain.
    translate([(shell_x_seam + shell_x_outboard)/2,
               (shell_y_min + shell_y_max)/2,
               (floor_z + shell_z_top)/2 + 0.01])
      cube([shell_x_outboard - shell_x_seam - 2*case_wall_thk,
            (shell_y_max - shell_y_min) - 2*case_wall_thk,
             shell_z_top - floor_z], center = true);

    // OPEN the +Y edge above the cradle (thumb side). Removes the +Y
    // wall + any roof for Y > shell_y_open, leaving the -Y wall (and
    // both ends) full height.
    translate([(shell_x_seam + shell_x_outboard)/2,
               (shell_y_open + shell_y_max + 10)/2,
               (floor_z + shell_z_top + 10)/2])
      cube([shell_x_outboard - shell_x_seam + 2,
            shell_y_max + 10 - shell_y_open,
            shell_z_top + 10 - floor_z], center = true);
  }

  // SEAM magnet pockets — only with the old skirt (they lived in the
  // z 0..phone_thk wall the skirt provided). Clamp-grip replaces them.
  if (phone_skirt)
  color([0.9, 0.3, 0.3])
    for (m = seam_magnets)
      translate([shell_x_seam + magnet_pocket_h/2 - 0.05, m[1], m[2]])
        rotate([0, 90, 0])
          cylinder(h = magnet_pocket_h, d = magnet_pocket_d, center = true);

  // RIM magnet pockets — on the transit contact surfaces (per-magnet z).
  color([0.3, 0.6, 0.9])
    for (m = rim_magnets)
      translate([m[0], m[1], m[2] - magnet_pocket_h/2])
        cylinder(h = magnet_pocket_h, d = magnet_pocket_d, center = true);
}

// Apply hand anchor + whole-hand tilt around the wrist, then render
// finger keywell + thumb in the hand-local frame. (Palm activation is
// in the SHELL, not the hand keywell — it's on the outboard end wall.)
module hand_right() {
  translate([hand_anchor_x, hand_anchor_y, hand_anchor_z])
    rotate([hand_tent_x, hand_pitch_y, 0]) {
      keywell_local();
    }
}

// Right-hand half-shell in cased-phone frame. The cradle's own origin
// is the seam plane (x=0), so we just call it directly; no
// hand_anchor offset (the keywell math inside still uses hand_anchor).
// Palm activation inset + thumb cage ride on the shell (cradle frame).
module hand_right_shell() {
  half_shell_local();
  palm_activation_local();
  thumb_cluster_local();
  clamp_on_half();
}

// Place the corner clamp at THIS half's lower-outer corner (right-hand
// frame): the device's +X short-edge × -Y (near-user) corner. Local clamp
// frame has the device filling x<=0,y<=0 with the back at z=0; here the
// device back (keyboard side) is world z=phone_thk and the corner is at
// (+phone_len/2, -phone_wid/2). mirror([0,1,0]) turns the clamp's +Y
// outward face into the -Y (bottom) outward face. The LEFT half inherits
// the mirror via hand_left_shell, so the two clamps grip the device's two
// lower-outer corners; cross-tension along X clamps it between the halves.
module clamp_on_half(squeeze = 0) {
  translate([phone_len/2, -phone_wid/2, phone_thk])
    mirror([0, 1, 0])
      corner_clamp(squeeze);
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
//  CORNER CLAMP — universal sprung grip + transit latch (conv #119)
// ---------------------------------------------------------------------
// Local frame: the device's lower-outer corner sits at the origin. The
// device body fills x<=0, y<=0; its BACK face (keyboard side) is z=0 and
// its front/screen face is at z=-thk. The clamp is an L-bracket hugging
// the two outward faces (+X short-end face, +Y long-edge face) with a
// front lip for Z retention, plus a flexure tab on the outboard (+X)
// face carrying the transit catch. Cross-back tension (elastic/spring
// between halves) supplies the in-use grip force; the flexure handles
// thickness compliance + the transit latch.

module rrect_prism(w, l, t, r) {
  hull() for (sx = [-1,1]) for (sy = [-1,1])
    translate([sx*(w/2 - r), sy*(l/2 - r), 0]) cylinder(h = t, r = r);
}

// Demo device: rounded slab with its +X,+Y corner at the origin.
module demo_device_corner(dev) {
  w = dev[0]; l = dev[1]; t = dev[2]; r = dev[3];
  color([0.16, 0.16, 0.20, 0.45])
    translate([-w/2, -l/2, -t]) rrect_prism(w, l, t, r);
}

// Tuned corner clamp in local corner frame.
//   squeeze = inward (-X) travel of the latch wall's free end. 0 = relaxed
//             (catch engaged / gripping); >0 = squeezed (catch retracted →
//             device admits / transit releases).
//
// Anatomy (all parametric, [Corner Clamp] group):
//   - +Y long-edge grip wall, FIXED, lead-in chamfer on its top-inner edge.
//   - +X short-end wall is the LATCH FLEXURE — isolated from the corner
//     pier by a slot so its free (bottom) end bends -X. Carries the catch.
//   - corner pier + back tie join both walls to the keyboard half.
//   - sprung FRONT LIP-FINGER on the +Y wall: bottom cantilever reaching
//     inward (-Y) that presses the device front face → grips the 7–13 mm
//     thickness range. Lead-in ramp on its underside.
//   - CATCH on the latch wall's +X face: ramp on top (snaps over the strike
//     ledge when stacking), flat hook underneath (retains until squeezed).
module corner_clamp(squeeze = 0) {
  jd = clamp_jaw_depth; wt = clamp_wall_thk; hz = clamp_height_z;
  lip = clamp_lip_z; ch = clamp_chamfer; lw = clamp_flex_thk;
  sl = clamp_flex_slot;

  // ---- Fixed +Y long-edge grip wall (with top-inner lead-in chamfer) ----
  color([0.62, 0.64, 0.70])
    difference() {
      translate([-jd, 0, -hz]) cube([jd + wt, wt, hz]);
      // chamfer the inner-top edge (runs along X at y=0,z=0)
      translate([-jd - 1, 0, 0]) rotate([45, 0, 0])
        translate([0, -ch*0.71, -ch*0.71]) cube([jd + wt + 2, ch*1.42, ch*1.42]);
    }

  // ---- Corner pier + back tie (joins walls to the keyboard half) ----
  color([0.62, 0.64, 0.70]) {
    translate([0, 0, -hz]) cube([wt, wt, hz]);           // corner pier
    translate([-jd, -jd, 0]) cube([2*wt, 2*wt, wt]);      // L back tie near corner
  }

  // ---- Sprung FRONT LIP-FINGER on the +Y wall (Z / thickness grip) ----
  // Cantilever reaching inward at the jaw bottom; deflection slot is the
  // gap up to the wall above it. Lead-in ramp on the underside so the
  // device slides in over it.
  color([0.45, 0.70, 0.55])
    translate([-jd, -lip, -hz])
      difference() {
        cube([jd + wt, lip + wt, wt]);
        // underside lead-in ramp (inner edge, runs along X)
        translate([-1, -0.01, 0]) rotate([45, 0, 0])
          translate([0, -wt*0.6, -wt*0.6]) cube([jd + wt + 2, wt*1.2, wt*1.2]);
      }

  // ---- Latch flexure: the +X short-end wall, isolated by a slot ----
  // Anchored at the top (z≈0, keyboard side); free at the bottom. squeeze
  // skews its free end -X. Modeled as a hinge tilt about the top edge.
  flex_y0 = -jd + sl;                 // slot isolates it from the corner pier
  color([0.30, 0.55, 0.85])
    translate([0, flex_y0, 0])
      rotate([0, atan2(squeeze, hz), 0])    // tilt free end inward by `squeeze`
        translate([0, 0, -hz])
          cube([lw, (jd) - sl, hz]);

  // ---- Catch on the latch wall's +X face (ramp up / hook down) ----
  // Triangular prism along Y: base on the wall, ramp face up (insertion),
  // flat face down (retention). Sits near the free (lower) end.
  catch_z = -hz + hz*0.30;             // ~1/3 up from the bottom
  color([0.90, 0.45, 0.30])
    translate([0, flex_y0, 0])
      rotate([0, atan2(squeeze, hz), 0])
        translate([lw, (jd - sl - clamp_catch_len)/2 + 0.0, catch_z])
          rotate([-90, 0, 0])
            linear_extrude(height = clamp_catch_len)
              polygon([[0, 0], [clamp_catch_h, 0], [0, clamp_catch_h*1.8]]);
}

// Transit strike: the ledge/recess on the opposing half's shell that the
// catch hooks under. Shown for the latch demo; in the real build it's cut
// into half_shell_local's mating wall.
module transit_strike() {
  jd = clamp_jaw_depth; wt = clamp_wall_thk; hz = clamp_height_z;
  lw = clamp_flex_thk; sl = clamp_flex_slot;
  flex_y0 = -jd + sl;
  x0 = lw + clamp_catch_h;             // strike face just outboard of the catch
  catch_z = -hz + hz*0.30;
  color([0.66, 0.66, 0.72, 0.55])
    difference() {
      translate([x0, flex_y0, -hz]) cube([wt, jd - sl, hz]);
      // notch the catch hooks into (ledge at the catch's flat underside)
      translate([x0 - 0.01,
                 flex_y0 + (jd - sl - clamp_catch_len)/2 - 0.5,
                 catch_z - 0.4])
        cube([clamp_catch_h + 0.5, clamp_catch_len + 1.0, clamp_catch_h*1.8 + 0.8]);
    }
}

// ---------------------------------------------------------------------
//  SLIDE-THROUGH LATCH — transit lock that seats the clamp flush (study)
// ---------------------------------------------------------------------
// T-slot tongue (on one half's clamp) rides through a channel in the
// mating half. Slide along +Y to lock. T head > neck → no straight pull-out.

// 2D T-slot profile in the X/Z plane: narrow neck opening toward -X (entry),
// wider head deeper in +X. Extruded along Y to make tongue or channel.
module _tslot_2d() {
  nd = sl_neck_depth; dp = sl_depth; nk = sl_neck; hd = sl_head;
  polygon([[0,-nk/2],[nd,-nk/2],[nd,-hd/2],[dp,-hd/2],
           [dp,hd/2],[nd,hd/2],[nd,nk/2],[0,nk/2]]);
}

// pos: 1 = locked (tongue fully in, trailing face flush with the wall's
// y=0 face); 0 = open (tongue slid out -Y by sl_travel → proud).
module slide_latch(pos = 1) {
  H = sl_head + 2*sl_wall;
  // Mating wall (opposing half's shell); -X face at x=0, slot runs along Y.
  color([0.66, 0.66, 0.72, 0.55])
    difference() {
      translate([0, 0, -H/2]) cube([sl_depth + sl_wall, sl_len, H]);
      translate([0, -1, 0]) rotate([-90, 0, 0])
        linear_extrude(sl_len + 2) _tslot_2d();
    }
  // Tongue (the clamp's coupling) — slides in +Y; flush at pos=1. Inset by
  // a print clearance so it reads as a distinct part (and prints to fit).
  y0 = -(1 - pos) * sl_travel;
  color([0.30, 0.55, 0.85])
    translate([0, y0, 0]) rotate([-90, 0, 0])
      linear_extrude(sl_tongue_len) offset(r = -sl_clearance) _tslot_2d();
  // arrow note: at pos=0 the blue tongue protrudes past the wall (proud);
  // at pos=1 it is drawn fully inside the channel (flush + T-locked).
}

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
  // TWIST-AND-STACK (telescoping C-channels — NOT a fold).
  //
  // The two halves are a matched pair of C-channels: each has its full-
  // height wall on the pinky (-Y) edge and is OPEN on the thumb (+Y)
  // edge. The transit move is a TWIST about the long axis followed by a
  // slide-over, so the channels TELESCOPE into one box rather than being
  // held apart face-to-face.
  //
  //   1. TWIST — rotate the left half 180° about the long (X) axis. Its
  //      pinky wall swaps -Y -> +Y (so it now covers the right half's
  //      open +Y edge, and the right's -Y wall covers the left's now-open
  //      -Y edge). Its keys swing to point DOWN (-Z).
  //   2. MOVE OVER — slide +X by one half-width onto the right footprint.
  //      Because the left half is the mirror part, this shift lands its
  //      DEEP trigger zone (outboard) directly over the right half's
  //      SHALLOW fingertip zone and vice-versa — the depth L-profiles
  //      interlock automatically.
  //   3. TELESCOPE — drop it DOWN so the walls slide past each other on
  //      opposite Y edges and both key sets share ONE cavity. The trigger
  //      keys now oppose at 180° and nest into the other's shallow end
  //      instead of stacking tip-to-tip. z_shift puts the left floor just
  //      above the right rim; brick height ~= one channel, not two.
  //
  // (Old code lifted 2*shell_z_top — that held the channels fully apart,
  //  doubling thickness. That was the bug.)
  z_shift = shell_z_top + (phone_thk + case_back_thk) + transit_mate_gap;
  hand_right_shell();
  hand_right();
  translate([shell_x_seam + shell_x_outboard, 0, z_shift])
    rotate([180, 0, 0]) {
      hand_left_shell();
      hand_left();
    }
} else if (render_mode == "right") {
  hand_right_shell();
  hand_right();
} else if (render_mode == "clamp_phone") {
  // Universal corner clamp gripping an S24U-class corner.
  demo_device_corner(demo_phone);
  corner_clamp(0);
} else if (render_mode == "clamp_tablet") {
  // SAME clamp, ~10" tablet corner — shows the device-agnostic span.
  demo_device_corner(demo_tablet);
  corner_clamp(0);
} else if (render_mode == "clamp_release") {
  // Squeeze-to-release: latch wall tilted inward by clamp_squeeze_demo,
  // catch retracted clear of the strike. Same view as clamp_latch.
  corner_clamp(clamp_squeeze_demo);
  transit_strike();
} else if (render_mode == "clamp_latch") {
  // Transit latch ENGAGED (relaxed): catch hooked under the strike ledge.
  // Squeezing the latch wall inward (clamp_release mode) frees it.
  corner_clamp(0);
  transit_strike();
} else if (render_mode == "slide_open") {
  // Slide-through latch OPEN: tongue slid out (proud), about to slide in.
  slide_latch(0.0);
} else if (render_mode == "slide_locked") {
  // Slide-through latch LOCKED: tongue fully slid through → flush + T-locked.
  slide_latch(1.0);
}
