// Increase resolution.
//$fa = 1;
//$fs = 0.4;

include <duct_shape_inside.scad>
include <duct_shape_outside.scad>

face_length_mm = 63;
face_width_mm = 32;
face_height_mm = 7;

bracket_side_width_mm = 1;
bracket_bottom_thickness_mm = 1.5;
bracket_slot_height_mm = 3;
bracket_slot_length_mm = 52;
// there is a rounded part at 52 that goes to 59
slot_para_width_mm=face_width_mm-2*bracket_side_width_mm;
slot_para_height_mm=7;

bracket_upper_slot_width_mm = 5;
bracket_upper_slot_length_mm = 52;
// upper slot round goes to goes to 58
slot_para2_width_mm=face_width_mm-2*bracket_upper_slot_width_mm;
slot_para2_height_mm=6;

// Parameters for the air hole...
ah_width_mm = 15;
ah_end_radius_mm = ah_width_mm/2;
ah_length_mm = 40 - ah_width_mm; // 40 mm minus twice the radius of the end rounding
ah_length_offset_mm = 13 - 2; // moved down 2mm based on fit.

// Characteristics of the tube
hose_end_od_mm = 30;
hose_end_wall_mm = 2;
hose_end_taper_od_mm = 31;
h_conn_h_mm = 5;
h_conn_h2_mm = 30;
h_conn_id_mm = hose_end_taper_od_mm + .5;
h_conn_od_mm = h_conn_id_mm+hose_end_wall_mm+1;

module hose_connector() {
    union() {
        difference() {
            cylinder(h=h_conn_h_mm, d=h_conn_od_mm);
            translate([0, 0, -0.001])
                cylinder(h=h_conn_h_mm+0.002, 
                    d=hose_end_od_mm-hose_end_wall_mm);
        }
        translate([0, 0, h_conn_h_mm])
            difference() {
                cylinder(h=h_conn_h2_mm, d=h_conn_od_mm);
                translate([0, 0, -0.001])
                    cylinder(h=h_conn_h2_mm+0.002, d=h_conn_id_mm);
            }
    }
}
//translate([ah_end_radius_mm, ah_end_radius_mm, 10])
//hose_connector();

module bracket_slot() {
    union() {
        translate([slot_para_width_mm/2, bracket_slot_length_mm+slot_para_height_mm-0.001, 0])
            linear_extrude(bracket_slot_height_mm)
                projection(cut=true)
                    rotate([90, 90, 0])
                        paraboloid(slot_para_height_mm, 
                            (slot_para_width_mm/2)-slot_para_height_mm, fc=0);
        cube([face_width_mm-2*bracket_side_width_mm, 
            bracket_slot_length_mm, bracket_slot_height_mm]);
    }
}
//bracket_slot();

module bracket_upper_slot() {
    union() {
        translate([slot_para2_width_mm/2, bracket_upper_slot_length_mm+slot_para2_height_mm-0.001, 0])
            linear_extrude(face_height_mm)
                projection(cut=true)
                    rotate([90, 90, 0])
                        paraboloid(slot_para2_height_mm, 
                            (slot_para2_width_mm/2)-slot_para2_height_mm, fc=0);
        cube([face_width_mm-2*bracket_upper_slot_width_mm, 
            bracket_upper_slot_length_mm, face_height_mm]);
    }
}
//bracket_upper_slot();

module air_hole() {
    union() {
        translate([0, ah_end_radius_mm, 0])
            cube([ah_width_mm, ah_length_mm, face_height_mm]);
        translate([ah_end_radius_mm, ah_end_radius_mm, 0])
            cylinder(face_height_mm, r=ah_end_radius_mm);
        translate([ah_end_radius_mm, ah_length_mm+ah_end_radius_mm, 0])
            cylinder(face_height_mm, r=ah_end_radius_mm);
    }
}
//air_hole();

module _bh_top() {
    // Top down.
    translate([ah_end_radius_mm, ah_length_mm/2+ah_end_radius_mm, 0])
        cylinder(h=10, r1=ah_end_radius_mm+5, r2=(h_conn_od_mm/2)-3);
}

side_cone_upper_radius = (h_conn_od_mm-ah_length_mm)/2;
module _bh_bottom() {
    translate([ah_end_radius_mm, ah_end_radius_mm, 0])
        cylinder(h=10, r1=ah_end_radius_mm+1, r2=side_cone_upper_radius);
    translate([ah_end_radius_mm, ah_length_mm+ah_end_radius_mm, 0])
        cylinder(h=10, r1=ah_end_radius_mm+1, r2=side_cone_upper_radius);    
}

// Create a basic manifold that bridges between the air hole and the hose connector.
module basic_hole_to_hose_manifold_no() {
    difference() {
    union() {
        difference() {
            _bh_top();
            union() {
                translate([0, 0, 2]) _bh_top();
                translate([ah_end_radius_mm, ah_length_mm/2+ah_end_radius_mm, -1])
                    cylinder(h=11, r=ah_end_radius_mm+4);
            
            }
        }
        difference() {
            _bh_bottom();
            union() {
                translate([0, 0, -4]) _bh_bottom();
                translate([ah_end_radius_mm, ah_end_radius_mm, 0])
                    cylinder(h=11, r=side_cone_upper_radius-1);
                translate([ah_end_radius_mm, ah_length_mm+ah_end_radius_mm, 0])
                    cylinder(h=11, r=side_cone_upper_radius-1);
            }
        }
    }
    
    translate([0, 0, -.001])
        linear_extrude(11) {
            projection() {
                intersection() {
                    _bh_top();
                    _bh_bottom();
                }
            }
        }
    }
}
module basic_hole_to_hose_manifold() {
    translate([ah_end_radius_mm, ah_length_mm/2+ah_end_radius_mm, 0])
        rotate([0, 0, 90])
            difference() {
                funnel_pts_21_25_34_10();   
                translate([0, 0, -.5])
                    funnel_pts_15_25_28_11();
            }
}
//air_hole();
//translate([ah_end_radius_mm, ah_length_mm/2+ah_end_radius_mm, 9.99])
//    hose_connector();
//basic_hole_to_hose_manifold();

// This is the slotted bracket to attach to the sander.
module bracket() {
    difference() {
        cube([face_width_mm, face_length_mm, face_height_mm]);
        union() {
            translate([bracket_side_width_mm, -.001, bracket_bottom_thickness_mm])
                bracket_slot();
            translate([bracket_upper_slot_width_mm, -0.001, bracket_bottom_thickness_mm])
                bracket_upper_slot();
            translate([(face_width_mm-ah_width_mm)/2, ah_length_offset_mm, -.001])
                air_hole();
        }
    }
}
//bracket();

module full_part() {
    translate([(face_width_mm-ah_width_mm)/2, ah_length_offset_mm, 1.001])
    translate([ah_end_radius_mm, ah_end_radius_mm+ah_length_mm/2, 0]) 
    rotate([0, 180, 0])
    //ah_length_offset_mm
    translate([-ah_end_radius_mm, -ah_end_radius_mm-ah_length_mm/2, 0])
    union() {
        translate([ah_end_radius_mm, ah_length_mm/2+ah_end_radius_mm, 9.999])
            hose_connector();
        basic_hole_to_hose_manifold();
    }
    bracket();
}
full_part();

module support_arm() {
    support_arm_height_mm = 9+h_conn_h_mm+h_conn_h2_mm;
    support_arm_w_mm = 5;
    //(face_width_mm-ah_width_mm)/2
    translate([(face_width_mm-support_arm_w_mm)/2, face_length_mm-(ah_length_offset_mm+side_cone_upper_radius-1), -support_arm_height_mm+.001])
    cube([support_arm_w_mm, ah_length_offset_mm+side_cone_upper_radius-1, support_arm_height_mm]);
}
support_arm();

// https://www.thingiverse.com/thing:84564
//////////////////////////////////////////////////////////////////////////////////////////////
// Paraboloid module for OpenScad
//
// Copyright (C) 2013  Lochner, Juergen
// http://www.thingiverse.com/Ablapo/designs
//
// This program is free software. It is 
// licensed under the Attribution - Creative Commons license.
// http://creativecommons.org/licenses/by/3.0/
//////////////////////////////////////////////////////////////////////////////////////////////

module paraboloid (y=10, f=5, rfa=0, fc=1, detail=44){
	// y = height of paraboloid
	// f = focus distance 
	// fc : 1 = center paraboloid in focus point(x=0, y=f); 0 = center paraboloid on top (x=0, y=0)
	// rfa = radius of the focus area : 0 = point focus
	// detail = $fn of cone

	hi = (y+2*f)/sqrt(2);								// height and radius of the cone -> alpha = 45° -> sin(45°)=1/sqrt(2)
	x =2*f*sqrt(y/f);									// x  = half size of parabola
	
   translate([0,0,-f*fc])								// center on focus 
	rotate_extrude(convexity = 10,$fn=detail )		// extrude paraboild
	translate([rfa,0,0])								// translate for fokus area	 
	difference(){
		union(){											// adding square for focal area
			projection(cut = true)																			// reduce from 3D cone to 2D parabola
				translate([0,0,f*2]) rotate([45,0,0])													// rotate cone 45° and translate for cutting
				translate([0,0,-hi/2])cylinder(h= hi, r1=hi, r2=0, center=true, $fn=detail);   	// center cone on tip
			translate([-(rfa+x ),0]) square ([rfa+x , y ]);											// focal area square
		}
		translate([-(2*rfa+x ), -1/2]) square ([rfa+x ,y +1] ); 					// cut of half at rotation center 
	}
}
//paraboloid (y=50,f=10,rfa= 0,fc=1,detail=120);
