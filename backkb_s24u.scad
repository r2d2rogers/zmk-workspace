// =====================================================================
//  BACK-OF-PHONE SPLIT KEYBOARD  —  Samsung Galaxy S24 Ultra
//  Landscape grip, palms cap both short ends, fingertips point inward.
//  4 fingers x 3 Choc keys per hand = 24 keys total.
//
//  Mount: rigid bridge back-panel with sprung end-caps (snap-grip).
//  Switches: Kailh Choc v1 (14x14 plate cutout, 1.3mm plate).
//
//  Author: generated for Rob.  Units: mm.  Render: F6 in OpenSCAD.
//  Tune the PARAMETERS block, then export each module to its own STL
//  (comment/uncomment the render targets at the very bottom).
// =====================================================================

$fn = 48;

// ---------------------------------------------------------------------
//  PARAMETERS  — edit these
// ---------------------------------------------------------------------

// --- Phone body (S24 Ultra, bare) ---
phone_len   = 162.3;   // long edge (landscape width of the rig)
phone_wid   = 79.0;    // short edge
phone_thk   = 8.6;     // body thickness
corner_r    = 6.0;     // body corner radius (approx)

// --- Fit clearance around the phone (raise if using a skin/case) ---
fit_gap     = 0.6;     // per-side gap, phone-to-plastic

// --- Bridge back-panel ---
panel_thk   = 2.4;     // rigid back plate thickness
wall        = 2.2;     // side wall thickness around the phone
lip         = 2.0;     // how far walls wrap onto the SCREEN side (retention)

// --- End caps / palm rests (the bits that pad the short ends) ---
endcap_len  = 26;      // length each palm pad adds beyond the phone end
endcap_flare= 6;       // extra width added at the palm for grip comfort
endcap_round= 10;      // outer rounding of the palm pad

// --- Camera-end handling ---
// On the S24U the lenses live at the top-left back. In landscape that
// whole zone sits under ONE palm pad. We just dome that pad outward so
// nothing presses the lenses.
cam_end_clear = 5.0;   // extra standoff over the camera-end palm pad

// --- Choc switch geometry ---
choc_cut    = 14.0;    // square plate cutout for Choc v1 (13.8-14.0)
choc_pitch_x= 18.0;    // spacing along the inward (typing) direction
choc_pitch_y= 18.5;    // spacing between finger columns (across phone_wid)
plate_thk   = 1.3;     // switch plate thickness (Choc spec)
keys_per_finger = 3;   // rows per finger, inward (per column)
fingers     = 4;       // index, middle, ring, pinky

// --- Per-finger COLUMN COUNT ---
// Index finger gets a 2nd column (the extra inner-reach column it can hit
// by stretching toward the phone center). 5 columns per hand total.
// Order: [index, middle, ring, pinky]
col_count   = [2, 1, 1, 1];
// For a finger with 2 columns, this is the y-offset (mm) of the 2nd
// column relative to the first. Positive = toward the phone center line
// (index reaches inward/up). Order matches col_count.
col2_yoff   = [-15.0, 0, 0, 0];   // index 2nd col sits 15mm "inboard"
col2_xoff   = [6.0, 0, 0, 0];     // and slightly further inward (reach)

// --- Column curve (fingertips arc inward as they curl) ---
// Per-finger inward offset of the key bank start, in mm, measured from
// the palm edge. Index reaches furthest (largest), pinky least.
// Order: [index, middle, ring, pinky]
col_reach   = [50, 53, 48, 40];
// Per-finger arc tilt (deg) applied to that finger's key strip.
col_tilt    = [8, 6, 4, 2];

// --- Electronics pocket (nice!nano + LiPo), centered on the panel ---
mcu_pocket_w = 20;     // nice!nano width-ish
mcu_pocket_l = 36;
mcu_pocket_d = 4.5;    // recess depth into panel underside
bat_pocket_w = 14;     // ~301230 LiPo
bat_pocket_l = 32;
bat_pocket_d = 3.5;

// --- Thumb keys (front edge, one per side) ---
thumb_keys  = true;
thumb_cut   = 14.0;

// --- Pointing devices (per side, on the front/side edge under thumb) ---
// Scroll wheel (rotary encoder): a slot for the wheel to protrude + a
// pocket for the EC11 body underneath.
wheel_enable   = true;
wheel_dia      = 20;     // exposed wheel diameter
wheel_thick    = 6;      // wheel rim thickness
wheel_slot_w   = 7;      // slot width the wheel pokes through
encoder_body   = 13;     // EC11 square body footprint
encoder_depth  = 5;      // recess depth under the plate

// Analog thumbstick (PSP-flat). Shallow pocket + top opening for the cap.
stick_enable   = true;
stick_pocket   = 16;     // square pocket for the module body
stick_depth    = 4.5;    // PSP-flat is shallow; console stick would need ~12
stick_cap_dia  = 11;     // opening for the slider/nub cap
stick_offset_y = 14;     // how far inboard from the side edge

// Where the pointer cluster sits along the phone's long edge (from center
// of each palm end, measured inward in mm). Both wheel + stick live here,
// wheel inboard (toward screen center), stick outboard (toward palm).
pointer_pos_x  = 30;

// --- Bank width allowance: extra width the key cluster needs beyond the
//     phone, now that the index finger has a 2nd inboard column ---
bank_extra_wid = 20;   // grows outer_wid so the 5th column has plate room

// ---------------------------------------------------------------------
//  DERIVED
// ---------------------------------------------------------------------
inner_len = phone_len + 2*fit_gap;
inner_wid = phone_wid + 2*fit_gap;
outer_len = inner_len + 2*wall + 2*endcap_len;
outer_wid = inner_wid + 2*wall + 2*endcap_flare + bank_extra_wid;

// helper: rounded rect prism
module rrect(l, w, h, r) {
    linear_extrude(h)
        offset(r) offset(-r)
            square([l, w], center=true);
}

// =====================================================================
//  MODULE: bridge back panel + walls + end-cap palm rests
// =====================================================================
module shell() {
    difference() {
        union() {
            // back panel
            translate([0,0,0])
                rrect(outer_len, outer_wid, panel_thk, endcap_round);

            // perimeter walls that wrap up the sides of the phone
            translate([0,0,panel_thk])
                difference() {
                    rrect(inner_len+2*wall, inner_wid+2*wall,
                          phone_thk+fit_gap+lip, corner_r+wall);
                    translate([0,0,-0.1])
                        rrect(inner_len, inner_wid,
                              phone_thk+fit_gap+lip+0.2, corner_r);
                }

            // retention lip: pull the wall top inward over the screen edge
            translate([0,0,panel_thk+phone_thk+fit_gap])
                difference() {
                    rrect(inner_len+2*wall, inner_wid+2*wall, lip,
                          corner_r+wall);
                    translate([0,0,-0.1])
                        rrect(inner_len-2*lip, inner_wid-2*lip, lip+0.2,
                              corner_r);
                }
        }

        // electronics pockets in the panel underside (open downward)
        translate([0, 0, -0.1]) {
            translate([-12,0,0])
                rrect(mcu_pocket_l, mcu_pocket_w, mcu_pocket_d+0.1, 2);
            translate([ 24,0,0])
                rrect(bat_pocket_l, bat_pocket_w, bat_pocket_d+0.1, 2);
        }

        // wire channel between pockets
        translate([0,0,-0.1])
            rrect(48, 4, 1.6, 1);
    }

    // camera-end dome standoff (LEFT palm here; flip if needed)
    translate([-(outer_len/2 - endcap_len/2), 0, panel_thk])
        rrect(endcap_len, outer_wid-2*endcap_round+8,
              cam_end_clear, endcap_round)
        ;
}

// =====================================================================
//  MODULE: one hand's key plate (4 fingers x 3 keys), column-curved
//  Placed as a raised plate on the back, switches snap UP from outside.
// =====================================================================
module hand_plate(mirror_hand=false) {
    // local coordinate: x = inward typing direction, y = finger columns
    mir = mirror_hand ? -1 : 1;

    // total columns across all fingers (index counts twice)
    total_cols = col_count[0]+col_count[1]+col_count[2]+col_count[3];

    // plate base spans the key bank footprint (account for index 2nd col
    // sticking inboard via col2_yoff)
    bank_x = keys_per_finger * choc_pitch_x + 6 + max(col2_xoff[0],0);
    bank_y = fingers * choc_pitch_y + 6 + abs(col2_yoff[0]) + 4;

    // shift plate so the extra index column has material under it
    plate_yshift = mir * (col2_yoff[0]/2);

    difference() {
        // raised plate
        translate([0, plate_yshift, panel_thk])
            rrect(bank_x, bank_y, plate_thk+2, 3);

        // key cutouts, per finger, per column
        for (f = [0:fingers-1]) {
            yy = (f - (fingers-1)/2) * choc_pitch_y;
            tilt = col_tilt[f] * mir;
            reach0 = col_reach[0];
            dx = (col_reach[f] - reach0);

            // column 1 (always present)
            place_column(f, yy, dx, tilt, mir, 0, 0);

            // column 2 (only where col_count[f] == 2 — the index finger)
            if (col_count[f] == 2)
                place_column(f, yy, dx, tilt, mir,
                             col2_yoff[f], col2_xoff[f]);
        }
    }
}

// place one vertical strip of `keys_per_finger` Choc cutouts
module place_column(f, yy, dx, tilt, mir, yoff, xoff) {
    translate([(dx+xoff)*mir, yy + yoff*mir, panel_thk])
        rotate([0,0,tilt])
        for (k = [0:keys_per_finger-1]) {
            kx = (k - (keys_per_finger-1)/2) * choc_pitch_x;
            translate([kx*mir, 0, -0.1])
                rrect(choc_cut, choc_cut, plate_thk+2.4, 0.6);
        }
}

// =====================================================================
//  MODULE: thumb key pad on a front edge (optional)
// =====================================================================
module thumb_pad(side=1) {
    // sits at the lower-front corner; side=+1 right, -1 left
    x = side * (outer_len/2 - endcap_len - 6);
    translate([x, -(outer_wid/2 - 4), panel_thk])
        difference() {
            rrect(20, 16, plate_thk+2, 3);
            translate([0,0,-0.1])
                rrect(thumb_cut, thumb_cut, plate_thk+2.4, 0.6);
        }
}

// =====================================================================
//  MODULE: pointer cluster (scroll wheel + thumbstick) for one side
//  side = +1 (right end) or -1 (left end)
// =====================================================================
module pointer_cluster(side=1) {
    // sit on the front/side edge, under the thumb tip
    cx = side * (outer_len/2 - endcap_len - pointer_pos_x);
    cy = -(outer_wid/2 - stick_offset_y);   // toward the front edge

    // --- scroll wheel: slot through the panel + encoder body pocket ---
    if (wheel_enable) {
        // wheel slot (wheel pokes through here), inboard of the stick
        translate([cx, cy + 16, -0.1])
            rrect(wheel_dia+2, wheel_slot_w, panel_thk+0.2, 1);
        // encoder body recess underneath
        translate([cx, cy + 16, panel_thk - encoder_depth])
            rrect(encoder_body, encoder_body, encoder_depth+0.1, 1);
    }

    // --- thumbstick: shallow pocket + cap opening ---
    if (stick_enable) {
        // module body pocket (from underside)
        translate([cx, cy, panel_thk - stick_depth])
            rrect(stick_pocket, stick_pocket, stick_depth+0.1, 1.5);
        // cap opening through the top
        translate([cx, cy, -0.1])
            cylinder(h=panel_thk+0.2, d=stick_cap_dia);
    }
}

// =====================================================================
//  ASSEMBLY
// =====================================================================
module assembly() {
    difference() {
        union() {
            shell();

            hx = inner_len/2 - (keys_per_finger*choc_pitch_x)/2 - 4;
            translate([ hx, 0, 0]) hand_plate(mirror_hand=false);
            translate([-hx, 0, 0]) mirror([1,0,0]) hand_plate(mirror_hand=false);

            if (thumb_keys) {
                thumb_pad(side= 1);
                thumb_pad(side=-1);
            }
        }
        // subtract pointer pockets from the assembled body
        pointer_cluster(side= 1);
        pointer_cluster(side=-1);
    }
}

// ---------------------------------------------------------------------
//  RENDER TARGETS  — uncomment ONE for STL export
// ---------------------------------------------------------------------
assembly();
// shell();
// hand_plate();
// thumb_pad();
