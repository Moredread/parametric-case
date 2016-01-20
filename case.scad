mode = 1; // 0 = Bottom, 1 = Top

external_width = 5.0;
external_length = 2.0;
external_height = 1.0;
shell_thickness = 0.2;
holes_exterior_diameter = .75;
holes_interior_diameter = 0.5;
$fn = 128;

module screw_hole(pos, height, inner_diameter, outer_diameter, center=false) {
    translate(pos) {
        difference() {
            cylinder(height, r = outer_diameter/2.0, center=center);
            cylinder(height*2+1, r = inner_diameter/2.0, center=true);
        }
    };
};

module screwholes(body_size, inner_diameter, outer_diameter, center=false) {
    width = body_size[0];
    length = body_size[1];
    height = body_size[2];    
    screw_hole([0,0,0], height, inner_diameter, outer_diameter, center=center);
    screw_hole([width,0,0], height, inner_diameter, outer_diameter, center=center);
    screw_hole([0,length,0], height, inner_diameter, outer_diameter, center=center);
    screw_hole([width,length,0], height, inner_diameter, outer_diameter, center=center);    
};

module case_base_shape(body_size, shell_thickness, holes_interior_diameter, holes_exterior_diameter, hollow=true) {
    width = body_size[0];
    length = body_size[1];
    height = body_size[2];
    union() {
        difference() {
            difference() {
                case_body([width, length, height]);
                if(hollow) {
                    case_inner_difference([width, length, height], shell_thickness);
                };
            }; 
            screwholes([width,length,height*2+1], 0, holes_exterior_diameter, center=true);
        };
        screwholes([width,length,height], holes_interior_diameter, holes_exterior_diameter);
    };
};

module case_body(size) {
    cube(size = size);    
}

module case_inner_difference(body_size, shell_thickness) {
    w = body_size[0] - 2*shell_thickness;
    l = body_size[1] - 2*shell_thickness;
    h = body_size[2] +   shell_thickness;
    translate([shell_thickness,shell_thickness,shell_thickness]) {
        cube([w,l,h]);
    };
}

module case(width=external_width, length=external_length, height=external_height, shell_thickness=shell_thickness, holes_exterior_diameter=holes_exterior_diameter, holes_interior_diameter=holes_interior_diameter) {
    case_base_shape([width, length, height], shell_thickness,holes_interior_diameter, holes_exterior_diameter);
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