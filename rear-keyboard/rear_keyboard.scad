// rear_keyboard_v3.scad — keywell rear Choc keyboard, Galaxy S24 Ultra
// Back view, phone landscape. X = long axis (0..162), Y = short axis.
// Y=0 = bottom edge (toward your lap). Y=79 = top edge where the thumbs sit.
// Z up = away from the phone's back glass. Camera is covered; no cutout.
//
// Hand-local frame (before placement):
//   +x = direction fingertips point (toward the other hand); curl keys are at -x, extend keys at +x
//   +y = toward the index finger
//   z=0 = well floor (top of the case's back plate)

part = "well";            // "well" (left hand only) | "thumb" (left cradle only) | "case" | "preview"

// ---------- phone / case ----------
phone     = [162.3, 79.0, 8.6];
clearance = 0.3;
wall      = 1.8;
lip       = 1.2;
corner_r  = 8;
bay_z     = 4;            // electronics layer between phone back and well floor
floor_t   = 1.3;          // well floor / back plate thickness

// ---------- switches ----------
plate_t      = 1.3;
cut          = 13.8;
cut_r        = 0.5;
kw           = 18;        // key plate footprint
kh           = 17;
switch_depth = 5.2;       // Choc v1 body below the plate
cav          = 15.4;      // clearance box under each key for the switch body
post_w       = 1.2;

// ---------- keywell geometry (TUNE after tape test) ----------
finger_pitch = 16;
reach_pitch  = 18;
col_R        = 45;        // column curvature radius; smaller = tighter curl
hand_angle   = 0;        // degrees the fingers point above horizontal
left_origin  = [36, 2];  // pinky home key position (phone coords)   // where the pinky home key lands (phone coords)
mirror_x     = phone[0] / 2;

// Columns, pinky first: [y, stagger_x, z_offset, rows]
//   rows: -1 = curl (toward the palm), 0 = home, 1 = extend (toward the other hand)
index_inner  = true;
cols = concat([
  [0 * finger_pitch, -12, 2.0, [-1, 0, 1]],   // pinky   (pulled back)
  [1 * finger_pitch,  -2, 0.5, [-1, 0, 1]],   // ring
  [2 * finger_pitch,   0, 0.0, [-1, 0, 1]],   // middle  (furthest forward)
  [3 * finger_pitch,  -7, 0.5, [-1, 0, 1]],   // index   (pulled back)
], index_inner ? [[4 * finger_pitch,  -7, 1.5, [-1, 0, 1]]] : []);   // index inner

// ---------- thumb bar on the top wall ----------
// Two keys in a line along the edge under a thumb lying along it:
//   far  = under the tip, near = under the pad's middle, both = flat press (combo).
// The two plates form a shallow V (thumb_v) so the curled tip finds the far key alone.
thumb_pitch  = 18;                 // far-to-near spacing along the edge
thumb_v      = 12;                 // angle between the two plates (0 = flat)
thumb_R      = (thumb_pitch / 2) / tan(thumb_v / 2);   // pivot radius so plates meet edge to edge
thumb_x      = 19;                 // centre of the pair from that hand's end: far (tip) key toward the corner, near key inboard
thumb_tilt   = 0;                  // key face tilt toward the back (0 = straight out of the edge)
thumb_stand  = 6;                  // press-key plate distance outside the case wall
thumb_z      = lip + phone[2] / 2; // bar centred on the phone's thickness

// ---------- electronics bays [x, y, w, h], in the bay layer ----------
nano_bay    = [64, 48, 34, 20];    // nice!nano 33.6 x 18
battery_bay = [64, 14, 36, 24];

// ---------- derived ----------
theta = 2 * asin(reach_pitch / (2 * col_R));   // degrees between keys on the arc

function has(c, r) = len(search(r, cols[c][3])) > 0;
function key(c, r) = let(col = cols[c], a = r * theta)
  [ col_R * sin(a) + col[1], col[0], col_R * (1 - cos(a)) + col[2] + switch_depth, a ];

TL = [-1,  1]; TR = [1,  1]; BL = [-1, -1]; BR = [1, -1];

// ---------- primitives ----------
module switch_cut2d() {
  square(cut, center = true);
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx * cut / 2, sy * cut / 2]) circle(cut_r, $fn = 12);
}

module place_key(k) { translate([k[0], k[1], k[2]]) rotate([0, -k[3], 0]) children(); }

module post(c) {
  translate([c[0] * kw / 2 - post_w / 2 * (1 + c[0]), c[1] * kh / 2 - post_w / 2 * (1 + c[1]), 0])
    cube([post_w, post_w, plate_t]);
}
module posts(k, corners) { for (c = corners) place_key(k) post(c); }

module key_plate(k) {
  place_key(k) difference() {
    translate([-kw / 2, -kh / 2, 0]) cube([kw, kh, plate_t]);
    translate([0, 0, -1]) linear_extrude(plate_t + 2) switch_cut2d();
  }
}

module key_skirt(k) {
  hull() {
    posts(k, [TL, TR, BL, BR]);
    linear_extrude(0.01) projection() posts(k, [TL, TR, BL, BR]);
  }
}

module key_cavity(k) {
  place_key(k) translate([-cav / 2, -cav / 2, -switch_depth - 0.5]) cube([cav, cav, switch_depth + 0.5]);
}

// ---------- one hand's well, in hand-local frame ----------
module hand_well_solid() {
  for (c = [0 : len(cols) - 1]) for (r = cols[c][3]) {
    key_plate(key(c, r));
    key_skirt(key(c, r));
    // column web (along the arc)
    if (has(c, r + 1)) hull() { posts(key(c, r), [TR, BR]); posts(key(c, r + 1), [TL, BL]); }
    // row web (to next finger, +y)
    if (c + 1 < len(cols) && has(c + 1, r))
      hull() { posts(key(c, r), [TL, TR]); posts(key(c + 1, r), [BL, BR]); }
    // diagonal web
    if (c + 1 < len(cols) && has(c, r + 1) && has(c + 1, r) && has(c + 1, r + 1))
      hull() { posts(key(c, r), [TR]); posts(key(c, r + 1), [TL]);
               posts(key(c + 1, r), [BR]); posts(key(c + 1, r + 1), [BL]); }
  }
}

module hand_well() {
  difference() {
    hand_well_solid();
    for (c = [0 : len(cols) - 1]) for (r = cols[c][3]) {
      key_cavity(key(c, r));
      place_key(key(c, r)) translate([0, 0, -1]) linear_extrude(plate_t + 2) switch_cut2d();
    }
  }
}

// ---------- placement into phone coords ----------
module at_hand(right = false) {
  if (right) translate([mirror_x, 0, 0]) mirror([1, 0, 0]) translate([-mirror_x, 0, 0])
    translate(left_origin) rotate(hand_angle) children();
  else translate(left_origin) rotate(hand_angle) children();
}

module rrect(w, h, r) { offset(r) offset(-r) square([w, h]); }
module rect_cut2d(f) { translate([f[0], f[1]]) square([f[2], f[3]]); }

// Key frames for one thumb bar. Local z = key normal (out of the edge). index 0 = far, 1 = near.
module thumb_key_frame(right = false) {
  cx = right ? phone[0] - thumb_x : thumb_x;
  dir = right ? -1 : 1;                                 // toward that hand's end
  translate([cx, phone[1] + clearance + wall + thumb_stand, thumb_z])
    rotate([-90 + thumb_tilt, 0, 0])                    // normal = +Y rotated toward +Z (back)
      for (i = [0, 1]) let (a = (i == 0 ? -1 : 1) * dir * thumb_v / 2)
        translate([0, 0, thumb_R]) rotate([0, -a, 0]) translate([0, 0, -thumb_R]) children();
}

module thumb_cluster(right = false) {
  cx = right ? phone[0] - thumb_x : thumb_x;
  difference() {
    union() {
      // one solid box per key (plate + switch body); no hull, so the cradle stays concave
      thumb_key_frame(right) translate([-kw / 2, -kh / 2, -switch_depth - 1]) cube([kw, kh, switch_depth + plate_t + 1]);
      // neck: from the backs of the boxes to a foot on the top wall
      hull() {
        thumb_key_frame(right) translate([-kw / 2, -kh / 2, -switch_depth - 1]) cube([kw, kh, 1]);
        translate([cx - (right ? thumb_pitch + 12 : 12), phone[1] + clearance, 0]) cube([thumb_pitch + 24, wall, lip + phone[2] + clearance]);
      }
    }
    thumb_key_frame(right) {
      translate([-cav / 2, -cav / 2, -switch_depth - 0.5]) cube([cav, cav, switch_depth + 0.5]);
      translate([0, 0, -1]) linear_extrude(plate_t + 2) switch_cut2d();
    }
    // keep the cradle itself empty: nothing above any key plate
    hull() thumb_key_frame(right) for (d = [plate_t, plate_t + 40]) translate([-kw / 2, -kh / 2, d]) cube([kw, kh, 0.01]);
    // never intrude on the phone pocket
    translate([-clearance, -clearance, lip]) linear_extrude(phone[2] + clearance) rrect(phone[0] + 2 * clearance, phone[1] + 2 * clearance, corner_r);
  }
}

module wells() { at_hand(false) hand_well(); at_hand(true) hand_well(); }
// Back plate = phone outline hulled with the well footprints (controller-wing shape)
module back_plate2d() { hull() { rrect(phone[0], phone[1], corner_r); offset(3) projection() wells(); } }

module case() {
  ow = phone[0] + 2 * (clearance + wall);
  oh = phone[1] + 2 * (clearance + wall);
  cavity_z = phone[2] + clearance;
  floor_z  = lip + cavity_z + bay_z;        // top of the back plate = well floor

  difference() {
    union() {
      translate([-(clearance + wall), -(clearance + wall), 0])
        linear_extrude(floor_z) rrect(ow, oh, corner_r + wall);
      translate([0, 0, floor_z]) linear_extrude(floor_t) back_plate2d();
      translate([0, 0, floor_z + floor_t]) wells();
      thumb_cluster(false); thumb_cluster(true);
    }
    translate([lip, lip, -1]) linear_extrude(lip + 1) rrect(phone[0] - 2 * lip, phone[1] - 2 * lip, corner_r);
    translate([-clearance, -clearance, lip])
      linear_extrude(cavity_z) rrect(phone[0] + 2 * clearance, phone[1] + 2 * clearance, corner_r);
    translate([0, 0, lip + cavity_z - 0.01]) linear_extrude(bay_z + 0.02) { rect_cut2d(nano_bay); rect_cut2d(battery_bay); }
    translate([-20, phone[1] / 2 - 7, lip + cavity_z / 2 - 2]) cube([40, 14, 4]);   // USB-C, pick the end
  }
}

// ---------- output ----------
if (part == "well") {
  // left keywell on a small floor slab, ready to tape to the phone
  hand_well();
  translate([-14, -12, -floor_t]) cube([reach_pitch * 3 + 30, finger_pitch * (len(cols) - 1) + 24, floor_t]);
}
else if (part == "thumb") thumb_cluster(false);
else if (part == "case") case();
else {
  color("silver") case();
  cz = lip + phone[2] + clearance + bay_z + floor_t;
  for (right = [false, true]) at_hand(right)
    for (c = [0 : len(cols) - 1]) for (r = cols[c][3])
      color("orange", 0.5) translate([0, 0, cz]) place_key(key(c, r)) translate([-7.5, -7.5, plate_t]) cube([15, 15, 6]);
  for (right = [false, true]) color("teal", 0.6) thumb_key_frame(right) translate([-7.5, -7.5, plate_t]) cube([15, 15, 6]);
  // labels (left hand + thumb)
  names = ["pinky", "ring", "middle", "index", "index inner"];
  for (c = [0 : len(cols) - 1]) color("black")
    translate([left_origin[0] + cols[c][1] + 32, left_origin[1] + cols[c][0] - 2, cz + 20])
      linear_extrude(1) text(names[c], size = 5, font = "Liberation Sans:style=Bold");
  color("black") translate([thumb_x - 16, phone[1] + 18, cz + 20]) linear_extrude(1) text("thumb: far  near", size = 5, font = "Liberation Sans:style=Bold");
}
