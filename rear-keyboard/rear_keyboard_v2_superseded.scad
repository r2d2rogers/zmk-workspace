// rear_keyboard_v2.scad — rotated-grip rear Choc keyboard, Galaxy S24 Ultra
// Back view, phone landscape. X = long axis (0..162), Y = short axis.
// Y=0 is the BOTTOM edge (nearest your lap), Y=79 is the TOP edge where the thumbs sit.
//
// Each hand is laid out in a local frame:
//   local +x = direction the fingertips point (toward the other hand)
//   local +y = toward the index finger
// then placed with hand_origin (pinky-side, palm end) and hand_angle.

part = "plate";                      // "plate" | "case" | "preview"

// ---------- phone ----------
phone     = [162.3, 79.0, 8.6];
clearance = 0.3;
wall      = 1.8;
lip       = 1.2;
corner_r  = 8;

// ---------- switches ----------
plate_t   = 1.3;
cut       = 13.8;
cut_r     = 0.5;
key_sq    = 15;                      // switch body, for preview only

// ---------- grip geometry (TUNE THESE after the tape test) ----------
finger_pitch = 17;                   // spacing between fingers (local y)
reach_pitch  = 18;                   // extend / home / curl spacing (local x)
hand_angle   = 32;                   // degrees the fingers point above horizontal
left_origin  = [14, 8];              // home key of the LEFT pinky, before rotation
// Column stagger per finger, index..pinky, in local x (positive = further inward)
stagger      = [10, 6, 2, -4];
rows_per_finger = [3, 3, 3, 2];      // pinky gets extend + home only

// Right hand: mirror of the left around the phone's X midline.
mirror_x = phone[0] / 2;

// ---------- thumb keys on the top wall (X positions along the edge) ----------
thumb_x_left  = [58, 76];
thumb_x_right = [phone[0] - 58, phone[0] - 76];
thumb_key_z   = 4.5;                 // switch center height above the phone back plane

// ---------- rear features [x, y, w, h] — MEASURE on your phone ----------
camera_cut  = [104, 44, 44, 22];     // lens row under the right hand
nano_bay    = [66, 46, 34, 20];      // nice!nano 33.6 x 18 mm
battery_bay = [64, 20, 36, 22];      // ~350 mAh LiPo

// ---------- derived ----------
// finger keys in hand-local coordinates: [x, y]
function hand_keys() = [
  for (f = [0 : 3])                              // 0 index .. 3 pinky
    for (r = [0 : rows_per_finger[f] - 1])       // 0 extend, 1 home, 2 curl
      [ (r - 1) * reach_pitch + stagger[f], (3 - f) * finger_pitch ]
];

function rot(p, a) = [ p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a) ];
function place_left(p)  = rot(p, hand_angle) + left_origin;
function place_right(p) = let(q = place_left(p)) [ 2 * mirror_x - q[0], q[1] ];

left_keys  = [ for (k = hand_keys()) concat(place_left(k),  [hand_angle]) ];
right_keys = [ for (k = hand_keys()) concat(place_right(k), [-hand_angle]) ];
finger_keys = concat(left_keys, right_keys);

echo(str("finger keys = ", len(finger_keys), "  thumbs = ", len(thumb_x_left) + len(thumb_x_right)));
for (k = finger_keys)
  assert(k[0] > 9 && k[0] < phone[0] - 9 && k[1] > 9 && k[1] < phone[1] - 9,
         str("key outside plate: ", k));

// ---------- 2D helpers ----------
module rrect(w, h, r) { offset(r) offset(-r) square([w, h]); }

module switch_cut2d() {
  square(cut, center = true);
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx * cut / 2, sy * cut / 2]) circle(cut_r, $fn = 12);
}

module finger_cuts2d() {
  for (k = finger_keys) translate([k[0], k[1]]) rotate(k[2]) switch_cut2d();
}

module rect_cut2d(f) { translate([f[0], f[1]]) square([f[2], f[3]]); }

module plate2d() {
  difference() {
    rrect(phone[0], phone[1], corner_r);
    finger_cuts2d();
    rect_cut2d(camera_cut);
  }
}

// ---------- parts ----------
module plate() { linear_extrude(plate_t) plate2d(); }

module thumb_wall_cuts(z0) {
  // Switch cutouts through the top wall, switch axis along -Y.
  for (x = concat(thumb_x_left, thumb_x_right))
    translate([x, phone[1] + clearance - 0.5, z0 + thumb_key_z])
      rotate([-90, 0, 0]) linear_extrude(wall + 1) switch_cut2d();
}

module case() {
  ow = phone[0] + 2 * (clearance + wall);
  oh = phone[1] + 2 * (clearance + wall);
  cavity_z = phone[2] + clearance;
  bay_z    = 5;
  total_z  = lip + cavity_z + bay_z + plate_t;
  wall_h   = 12;                       // extra top-wall height to house thumb switches

  difference() {
    union() {
      translate([-(clearance + wall), -(clearance + wall), 0])
        linear_extrude(total_z) rrect(ow, oh, corner_r + wall);
      // thickened top wall for thumb switches
      translate([20, phone[1] + clearance, 0]) cube([phone[0] - 40, wall + 6, lip + cavity_z + wall_h]);
    }
    // screen opening
    translate([lip, lip, -1])
      linear_extrude(lip + 1) rrect(phone[0] - 2 * lip, phone[1] - 2 * lip, corner_r);
    // phone pocket
    translate([-clearance, -clearance, lip])
      linear_extrude(cavity_z) rrect(phone[0] + 2 * clearance, phone[1] + 2 * clearance, corner_r);
    // electronics bays
    translate([0, 0, lip + cavity_z - 0.01]) linear_extrude(bay_z + 0.02) {
      rect_cut2d(nano_bay);
      rect_cut2d(battery_bay);
      rect_cut2d(camera_cut);
    }
    // switch cutouts + camera window through the plate layer
    translate([0, 0, lip + cavity_z + bay_z - 0.01]) linear_extrude(plate_t + 0.02) {
      finger_cuts2d();
      rect_cut2d(camera_cut);
    }
    // thumb switches through the top wall
    thumb_wall_cuts(lip + cavity_z);
    // USB-C: phone's bottom-in-portrait edge is one END in landscape — set which
    translate([-20, phone[1] / 2 - 7, lip + cavity_z / 2 - 2]) cube([40, 14, 4]);
  }
}

// ---------- output ----------
if (part == "plate") plate();
else if (part == "case") case();
else {
  color("silver") case();
  for (k = finger_keys) color("orange", 0.5)
    translate([k[0], k[1], 30]) rotate(k[2]) translate([-key_sq / 2, -key_sq / 2, 0]) cube([key_sq, key_sq, 8]);
  for (x = concat(thumb_x_left, thumb_x_right)) color("teal", 0.5)
    translate([x - key_sq / 2, phone[1] + clearance, 6]) cube([key_sq, 8, key_sq]);
}
