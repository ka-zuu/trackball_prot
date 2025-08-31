// OpenSCAD Model for a Custom Trackball Mouse
//
// This file defines the parameters for the 3D model based on spec.md.
// The modeling will be done in separate modules.

//-------------------------------------------------
// 1. Global Parameters & Dimensions
//-------------------------------------------------

// Case dimensions
wall_thickness = 1.5;
screw_hole_diameter = 2;
screw_head_diameter = 4; // M2 screw head
screw_head_height = 2;   // M2 screw head

// Component clearance
clearance = 0.5;

//-------------------------------------------------
// 2. Component-specific Dimensions
//-------------------------------------------------

// PMW3360 Sensor Breakout Board
sensor_width = 20;
sensor_length = 20;
sensor_thickness = 2.5;

// RP2040 Zero Microcontroller
mcu_width = 18;
mcu_length = 23.5;
mcu_thickness = 3.2;

// Trackball
ball_diameter = 25;
bearing_diameter = 3;

// This value has been confirmed by the user.
bearing_holder_offset = 12;

// Buttons (6mm Tactile Switch)
button_body_size = 6;
button_body_height = 4.3;
button_plunger_size = 3.5;
button_hole_size = 7; // Hole in the case for the button

//-------------------------------------------------
// 3. Calculated Layout & Dimensions
//-------------------------------------------------

// A note on the coordinate system:
// The origin [0,0,0] is the center of the trackball sphere.
// The case is built around this central point.
// Z is the vertical axis. Y is front(-)/back(+). X is left(-)/right(+).

// Add padding around the components
padding = 5;

// Layout positions for components (center point of each component)
case_floor_z = -(ball_diameter / 2) - sensor_thickness - clearance;
mcu_pos = [0, -10 - clearance - mcu_length / 2, case_floor_z + mcu_thickness / 2];
sensor_pos = [0, 0, case_floor_z + sensor_thickness / 2];

// Determine overall internal dimensions from component layout
internal_width = (mcu_width) + (button_body_size * 2) + (padding * 4);
internal_length = (sensor_length/2) + mcu_length + padding * 2;
internal_height = -case_floor_z + wall_thickness;

// Total case dimensions
case_width = internal_width + 2 * wall_thickness;
case_length = internal_length + 2 * wall_thickness;
case_height = internal_height + wall_thickness;

// Screw pillar positions
pillar_x = internal_width / 2 - padding;
pillar_y = internal_length / 2 - padding;

// Button positions (for top case cutouts)
left_button_pos = [-mcu_width/2 - padding - button_body_size/2, mcu_pos[1] - mcu_length/4, 0];
center_button_pos = [-mcu_width/2 - padding - button_body_size/2, mcu_pos[1] + mcu_length/4, 0];
right_button_pos = [sensor_width/2 + padding + button_body_size/2, sensor_pos[1], 0];

// Top case height
top_case_height = ball_diameter/2 + wall_thickness;


//-------------------------------------------------
// 4. Main Modules
//-------------------------------------------------

module top_case() {
    difference() {
        // 1. Create the main block (shell)
        translate([-internal_width/2 - wall_thickness, -internal_length/2 - wall_thickness, 0])
        difference() {
            // Outer box
            cube([case_width, case_length, top_case_height]);
            // Inner hollow area
            translate([wall_thickness, wall_thickness, wall_thickness])
            cube([internal_width, internal_length, top_case_height]);
        }

        // 2. Create the main trackball opening
        translate([0,0,-1])
        cylinder(h = top_case_height + 2, d = ball_diameter - 1);

        // 3. Create button holes
        translate([left_button_pos[0], left_button_pos[1], -1])
        cube([button_hole_size, button_hole_size, top_case_height + 2], center=true);
        translate([center_button_pos[0], center_button_pos[1], -1])
        cube([button_hole_size, button_hole_size, top_case_height + 2], center=true);
        translate([right_button_pos[0], right_button_pos[1], -1])
        cube([button_hole_size, button_hole_size, top_case_height + 2], center=true);

        // 4. Create screw holes with counterbores
        translate([pillar_x, pillar_y, -1]) cylinder(h=top_case_height+2, d=screw_hole_diameter);
        translate([pillar_x, pillar_y, top_case_height - screw_head_height]) cylinder(h=screw_head_height+1, d=screw_head_diameter);
        translate([-pillar_x, pillar_y, -1]) cylinder(h=top_case_height+2, d=screw_hole_diameter);
        translate([-pillar_x, pillar_y, top_case_height - screw_head_height]) cylinder(h=screw_head_height+1, d=screw_head_diameter);
        translate([pillar_x, -pillar_y, -1]) cylinder(h=top_case_height+2, d=screw_hole_diameter);
        translate([pillar_x, -pillar_y, top_case_height - screw_head_height]) cylinder(h=screw_head_height+1, d=screw_head_diameter);
        translate([-pillar_x, -pillar_y, -1]) cylinder(h=top_case_height+2, d=screw_hole_diameter);
        translate([-pillar_x, -pillar_y, top_case_height - screw_head_height]) cylinder(h=screw_head_height+1, d=screw_head_diameter);
    }
}

module bottom_case() {
    difference() {
        // 1. Main Block (outer shell with pillars)
        union() {
            // Base and walls
            translate([-internal_width/2 - wall_thickness, -internal_length/2 - wall_thickness, case_floor_z])
            cube([case_width, case_length, internal_height]);

            // Screw pillars
            translate([pillar_x, pillar_y, case_floor_z]) cylinder(h=internal_height, d=8);
            translate([-pillar_x, pillar_y, case_floor_z]) cylinder(h=internal_height, d=8);
            translate([pillar_x, -pillar_y, case_floor_z]) cylinder(h=internal_height, d=8);
            translate([-pillar_x, -pillar_y, case_floor_z]) cylinder(h=internal_height, d=8);
        }

        // 2. Subtract inner volume
        translate([-internal_width/2, -internal_length/2, case_floor_z + wall_thickness])
        cube([internal_width, internal_length, case_height]);

        // 3. Subtract trackball hole
        sphere(d = ball_diameter);

        // 4. Subtract bearing holes (3 holes at 120 degrees)
        for (i = [0, 1, 2]) {
            rotate([0, 0, i * 120]) {
                // Position the bearing to support the ball from below
                translate([bearing_holder_offset, 0, -ball_diameter/2 * cos(45)])
                sphere(d = bearing_diameter);
            }
        }

        // 5. Subtract component volumes for a snug fit
        // Sensor cutout
        translate([sensor_pos[0], sensor_pos[1], sensor_pos[2] - sensor_thickness/2 - clearance])
        cube([sensor_width, sensor_length, sensor_thickness + clearance*2], center=true);
        // MCU cutout
        translate([mcu_pos[0], mcu_pos[1], mcu_pos[2] - mcu_thickness/2 - clearance])
        cube([mcu_width, mcu_length, mcu_thickness + clearance*2], center=true);

        // 6. Subtract screw holes
        translate([pillar_x, pillar_y, case_floor_z - clearance]) cylinder(h=case_height, d=screw_hole_diameter);
        translate([-pillar_x, pillar_y, case_floor_z - clearance]) cylinder(h=case_height, d=screw_hole_diameter);
        translate([pillar_x, -pillar_y, case_floor_z - clearance]) cylinder(h=case_height, d=screw_hole_diameter);
        translate([-pillar_x, -pillar_y, case_floor_z - clearance]) cylinder(h=case_height, d=screw_hole_diameter);

        // 7. USB-C Port cutout for RP2040 Zero
        usb_cutout_width = 10;
        usb_cutout_height = 5;
        translate([mcu_pos[0] - usb_cutout_width/2, -internal_length/2 - wall_thickness - clearance, mcu_pos[2] - usb_cutout_height/2])
        cube([usb_cutout_width, wall_thickness + clearance*2, usb_cutout_height]);
    }
}

//-------------------------------------------------
// 5. Main execution
//-------------------------------------------------
// To render a part, define the 'part' variable, e.g., using the command line:
// openscad -o top_case.stl -D "part=\"top_case\"" trackball_mouse.scad
if (defined(part)) {
    if (part == "top_case") {
        top_case();
    } else if (part == "bottom_case") {
        bottom_case();
    }
} else {
    echo("No part selected for rendering. Define 'part' variable to 'top_case' or 'bottom_case'.");
}
