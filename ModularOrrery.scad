use <parametric_involute_gear_v5.0.scad>

//Kepler 10 
planet_sizes = [1.416, 2.227];
planet_periods= [0.837495, 3.29485];
planet_distances = [ 0.01684, 0.2407];

size_scale = 20;
length_scale = 2000;

shaft_seperation = 200;
vertical_gear_speration = 20;
ms_base_radius = 90;
ms_radius_inc  = 10;
ms_key_width   = 5;
ms_key_length  = 10;
ms_bore 		 = 30;
//Gears 
base_gear_no  = 40;

orrery_shaft_height= 200;

//planet shaft
ps_base_radius = 20;
ps_radius_inc  = 6;
ps_thickness   = 4;

function main_gears_bore_diameter(no,base_radius,radius_inc) = base_radius-(radius_inc*no);
function pair_pitch(base_gear_no, ratio, sep) = (1+ ratio)*base_gear_no/(2.0*sep);
function ps_cylinder_r(order_no) = (ps_base_radius+ order_no*ps_radius_inc);

module main_shaft_gears(planet_periods){


	no_planets = len(planet_periods);

	for(i = [0:1:no_planets-1]){
		translate([0,0,i*vertical_gear_speration]){

			gear(number_of_teeth = base_gear_no,
				diametral_pitch  = pair_pitch(base_gear_no, planet_periods[0]/planet_periods[i],shaft_seperation ),
				bore_diameter    = ms_bore,
		          gear_thickness   = vertical_gear_speration,
				rim_thickness = vertical_gear_speration,
				hub_thickness = vertical_gear_speration);
		}	

	}
}


module main_shaft(planet_sizes, planet_periods){
	start_height = 0;
	base_radius  = 90; 
	radius_inc   = 10;
	no_planets   = len(planet_sizes);
	core_gap     = 10;

	for( i = [1:1:no_planets] ){
		translate([0,0, (vertical_gear_speration*(i-1)) + start_height]){
			difference(){
				cylinder(r=main_gears_bore_diameter(i,ms_base_radius,ms_radius_inc)
					  , h=vertical_gear_speration);
				cylinder(r=core_gap, h=vertical_gear_speration);
			}
			translate([-ms_key_width/2,main_gears_bore_diameter(i,ms_base_radius,ms_radius_inc)-2,0]){
				cube([ms_key_width,ms_key_length-2,vertical_gear_speration]);
			}
		}
	}
}

module planet_arm(radius=40, thickness=5, length=100, height=100, planet_size=20){
	difference(){

		cylinder(r=radius+ps_thickness, h=10);
		cylinder(r=radius+ps_thickness-thickness, h=10);
	}
	translate([radius+ps_thickness-2,-5,0]){
		cube([length,10,10]);
		translate([length,0,0]){
			cube([10,10,height]);
			translate([5,5,height-5]){
				sphere(r=planet_size);
			}
		}
	}
	
	
}

module gear_pair(seperation, base_gear_no, ratio){
	new_gear_no = ratio *base_gear_no;
	pitch  = (base_gear_no + new_gear_no )/(2.0*seperation);
	gear(number_of_teeth = base_gear_no,
		diametral_pitch  = pitch,
		bore_diameter    = 10);

	translate([seperation,0,0]){
		gear(number_of_teeth = new_gear_no,
			diametral_pitch  = pitch,
			bore_diameter    = 10);
	}
}

module key_gear(ratio,size, key_size, thickness,midhole){
	difference(){
		gear (circular_pitch=1200,
					  gear_thickness = 10,
					  rim_thickness = 13,
					  hub_thickness = 15,
					  circles=0);

		union(){
			cylinder(r=midhole, h = thickness);
			translate([0, key_size, 0]){
				cube([key_size,key_size,thickness*2],center=true); 
			}
		}
	}
}




module spindle(height=100, base_radius=30, thickness=5){
	cylinder(center=false, r=thickness, h=height);
	cylinder(center=false,r=base_radius, h=3);
}

module planet_shaft(order_no, ratio, seperation, thickness){
	
	height = orrery_shaft_height/len(planet_sizes);
	
	difference(){
		union(){
			cylinder(h=height+ 40*(2-order_no), r =  ps_cylinder_r(order_no));
			gear(number_of_teeth = base_gear_no*ratio,
				diametral_pitch  = pair_pitch(base_gear_no, ratio,shaft_seperation ),
				bore_diameter    =  ps_cylinder_r(order_no)*2,
			    gear_thickness   = vertical_gear_speration,
				rim_thickness = vertical_gear_speration,
				hub_thickness = vertical_gear_speration);
		}
		echo("inner diameter", ps_cylinder_r(order_no), thickness);
		cylinder(h=height+ 400, r = ps_cylinder_r(order_no)-thickness);
	}
}

translate([shaft_seperation,0,0]){
	spindle(100,100,ms_bore/2);
	//main_shaft(planet_sizes, planet_periods);
	color("red"){
		main_shaft_gears(planet_periods);
	}
}


spindle(200,50, ps_cylinder_r(len(planet_periods)-1)-ps_thickness-8);
for(i = [0:len(planet_periods)-1]){
	translate([0,0,vertical_gear_speration*i]){
		planet_shaft(i, planet_periods[0]/planet_periods[i], 20, ps_thickness);
	}

	translate([0,0,vertical_gear_speration*i + orrery_shaft_height/len(planet_sizes)+ 40*(2-i) -20 ]){
		planet_arm( radius =ps_cylinder_r(i) , length= planet_distances[i]*length_scale, height=100, planet_size=planet_sizes[i]*size_scale);
	}	
}

			






