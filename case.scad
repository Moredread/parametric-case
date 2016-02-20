mode = 1; // 0 = Bottom, 1 = Top
arduino_type = 1; // 0 = Uno, 1 = Tiny

external_width = 9.0;
external_length = 7.0;
external_height = 3.0;
shell_thickness = 0.2;
holes_exterior_diameter = 1;
holes_interior_diameter = 0.35;
led_width = 5.1;
led_length = 1.93;
led_distance = 1.0;
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
    translate([shell_thickness, shell_thickness, shell_thickness]) {
        case_body([w,l,h], rounding);
    };
}

module case(width=external_width, length=external_length, height=external_height, shell_thickness=shell_thickness, holes_exterior_diameter=holes_exterior_diameter, holes_interior_diameter=holes_interior_diameter) {
    case_base_shape([width, length, height], shell_thickness,holes_interior_diameter, holes_exterior_diameter);
    translate([shell_thickness+0.05, 1.5])
    
    if(arduino_type == 0) {
        translate([shell_thickness+0.05, 1.5])
        arduino_uno_stubs(shell_thickness);
    }
    if(arduino_type == 1) {
        translate([shell_thickness+0.15, 1.5])
        arduino_tiny_stubs(shell_thickness);
    }    
};

module arduino_tiny_stubs(shell_thickness) {
    translate([0.00, 0])
    arduino_tiny_stub(shell_thickness);
    translate([4.00, 1.5])
    arduino_tiny_stub(shell_thickness);
    translate([0.00, 1.5])
    arduino_tiny_screw_stub(shell_thickness);
    translate([4.00, 0])
    arduino_tiny_screw_stub(shell_thickness);
};


module arduino_tiny_screw_stub(shell_thickness) {
    base_r = 0.3/2;
    plus_r = 0.1/2;
    base_h = 0.3;
    
    screw_stub(shell_thickness, base_r, plus_r, base_h);
};

module arduino_tiny_stub(shell_thickness) {
    base_r = 0.3/2;
    plus_r = 0.15/2;
    base_h = 0.3;
    plus_h = 0.2;
    
    stub(shell_thickness, base_r, plus_r, base_h, plus_h);
};


module arduino_uno_stubs(shell_thickness) {
    translate([1.40, 0.25])
    arduino_uno_stub(shell_thickness);
    translate([1.40+0.13+5.08, 0.25+0.51+2.79])
    arduino_uno_stub(shell_thickness);
    translate([1.40+0.13, 0.25+0.51+2.79+1.52])
    arduino_uno_screw_stub(shell_thickness);
    translate([1.40+0.13+5.08, 0.25+0.51])
    arduino_uno_screw_stub(shell_thickness);
};


module arduino_uno_screw_stub(shell_thickness) {
    base_r = 0.5/2;
    plus_r = 0.25/2;
    base_h = 0.4;
    
    screw_stub(shell_thickness, base_r, plus_r, base_h);
};

module arduino_uno_stub(shell_thickness) {
    base_r = 0.5/2;
    plus_r = 0.29/2;
    base_h = 0.4;
    plus_h = 0.25;
    
    stub(shell_thickness, base_r, plus_r, base_h, plus_h);
};

module stub(shell_thickness, base_r, plus_r, base_h, plus_h) {
    cylinder(h = shell_thickness+base_h, r = base_r);
    cylinder(h = shell_thickness+base_h+plus_h, r = plus_r);
};


module screw_stub(shell_thickness, base_r, plus_r, base_h) {
    difference() {
        cylinder(h = shell_thickness+base_h, r = base_r);
        cylinder(h = (shell_thickness+base_h)*3, r = plus_r, center=true);
    };
};

module led_hole(size) {
    width = size[0];
    length = size[1];
    height = size[2];
    
    translate([0, 0, -height*2])
    cube([width, length, height*4]);
}

module led_stubs(shell_thickness) {
    d = 0.2;
    offset_x = 0.22+d/2;
    offset_y = 0.15;
    translate([offset_x, -d])
    led_screw_stub(shell_thickness);
    translate([led_width - offset_x, -d])
    led_screw_stub(shell_thickness);
    translate([offset_x, led_length + d])
    led_screw_stub(shell_thickness);
    translate([led_width - offset_x, led_length + d])
    led_screw_stub(shell_thickness);
};

module led_screw_stub(shell_thickness) {
    base_r = 0.28/2;
    plus_r = 0.15/2;
    base_h = 0.8-0.1-shell_thickness;
    
    screw_stub(shell_thickness, base_r, plus_r, base_h);
};

module case_cover(width=external_width, length=external_length, height=external_height, shell_thickness=shell_thickness, holes_exterior_diameter=holes_exterior_diameter, holes_interior_diameter=holes_interior_diameter) {
    difference() {
        case_base_shape([width, length, shell_thickness], shell_thickness,holes_interior_diameter, holes_exterior_diameter, false);
        translate([external_width / 2 - led_width / 2, external_length / 2 - led_length - led_distance/2, ])
        led_hole([led_width, led_length, shell_thickness]);
        translate([external_width / 2 - led_width / 2, external_length / 2 + led_distance/2, ])
        led_hole([led_width, led_length, shell_thickness]);        
    };
    translate([external_width / 2 - led_width / 2, external_length / 2 - led_length - led_distance/2, ])
    led_stubs(shell_thickness);    
    translate([external_width / 2 - led_width / 2, external_length / 2 + led_distance/2, ])
    led_stubs(shell_thickness);
};

module main() {
    if(mode == 0) {
        case();
    } else {
        case_cover();
    };

};

main();