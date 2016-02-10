mode = 0; // 0 = Bottom, 1 = Top

external_width = 10.0;
external_length = 8.0;
external_height = 3.0;
shell_thickness = 0.2;
holes_exterior_diameter = 0.75;
holes_interior_diameter = 0.35;
$fn = 64;

module screw_hole(pos, height, inner_diameter, outer_diameter, center=false) {
    translate(pos) {
        difference() {
            cylinder(height, r = outer_diameter/2.0, center=center);
            cylinder(height*2+1, r = inner_diameter/2.0, center=true);
        }
    };
};

module screw_holes(body_size, inner_diameter, outer_diameter, center=false) {
    width = body_size[0];
    length = body_size[1];
    height = body_size[2];
    offset = outer_diameter/2;
    screw_hole([offset,offset,0], height, inner_diameter, outer_diameter, center=center);
    screw_hole([width-offset,offset,0], height, inner_diameter, outer_diameter, center=center);
    screw_hole([offset,length-offset,0], height, inner_diameter, outer_diameter, center=center);
    screw_hole([width-offset,length-offset,0], height, inner_diameter, outer_diameter, center=center);    
};

module case_base_shape(body_size, shell_thickness, holes_interior_diameter, holes_exterior_diameter, hollow=true) {
    width = body_size[0];
    length = body_size[1];
    height = body_size[2];
    union() {
        difference() {
            difference() {
                case_body(body_size, holes_exterior_diameter/2);
                if(hollow) {
                    case_inner_difference(body_size, shell_thickness, holes_exterior_diameter/2);
                };
            }; 
            screw_holes([width,length,height*2+1], 0, holes_exterior_diameter, center=true);
        };
        screw_holes([width,length,height], holes_interior_diameter, holes_exterior_diameter);
    };
};

module case_body(body_size, rounding) {
    width = body_size[0];
    length = body_size[1];
    height = body_size[2];
    linear_extrude(height=height) {
        hull() {
            translate([rounding, rounding, 0])
            circle(rounding);
            translate([width-rounding, rounding, 0])
            circle(rounding);
            translate([rounding, length-rounding, 0])
            circle(rounding);
            translate([width-rounding, length-rounding, 0])
            circle(rounding);            
        }
    }
}

module case_inner_difference(body_size, shell_thickness, rounding) {
    w = body_size[0] - 2*shell_thickness;
    l = body_size[1] - 2*shell_thickness;
    h = body_size[2] +   shell_thickness;
    translate([shell_thickness,shell_thickness,shell_thickness]) {
        case_body([w,l,h], rounding);
    };
}

module case(width=external_width, length=external_length, height=external_height, shell_thickness=shell_thickness, holes_exterior_diameter=holes_exterior_diameter, holes_interior_diameter=holes_interior_diameter) {
    case_base_shape([width, length, height], shell_thickness,holes_interior_diameter, holes_exterior_diameter);
    translate([2, 2])
    arduino_uno_stubs(shell_thickness);
};

module arduino_uno_stubs(shell_thickness) {
    r = 0.3/2;
    h = 0.4;

    translate([1.40, 0.25])
    stub(shell_thickness);
    translate([1.40+0.13+5.08, 0.25+0.51+2.79])
    stub(shell_thickness);
    translate([1.40+0.13, 0.25+0.51+2.79+1.52])
    screw_stub(shell_thickness);
    translate([1.40+0.13+5.08, 0.25+0.51])
    screw_stub(shell_thickness);
};

module stub(shell_thickness) {
    base_r = 0.5/2;
    plus_r = 0.29/2;
    base_h = 0.4;
    plus_h = 0.25;
    
    cylinder(h = shell_thickness+base_h, r = base_r);
    cylinder(h = shell_thickness+base_h+plus_h, r = plus_r);
};

module screw_stub(shell_thickness) {
    base_r = 0.5/2;
    plus_r = 0.25/2;
    base_h = 0.4;
    
    difference() {
        cylinder(h = shell_thickness+base_h, r = base_r);
        cylinder(h = (shell_thickness+base_h)*3, r = plus_r, center=true);
    };
};

module case_cover(width=external_width, length=external_length, height=external_height, shell_thickness=shell_thickness, holes_exterior_diameter=holes_exterior_diameter, holes_interior_diameter=holes_interior_diameter) {
    case_base_shape([width, length, shell_thickness], shell_thickness,holes_interior_diameter, holes_exterior_diameter, false);
};

module main() {
    if(mode == 0) {
        case();
    } else {
        case_cover();
    };

};

main();