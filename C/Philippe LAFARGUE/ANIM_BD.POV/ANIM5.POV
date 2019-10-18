// Animation simple pour before dawn
// en 24 images

#declare Gen_Ambient = 0.2
#declare nb_images = 24.0

#declare White	=	color rgb <1.0,1.0,1.0>
#declare Blue	=	color rgb <0.0,0.0,1.0>
#declare Yellow = 	color rgb <1.0,1.0,0.0>

#declare f_sph = 
finish{	ambient Gen_Ambient
		phong 1.0 phong_size 100.0
}

/*
background { color rgb <1.0,1.0,1.0>	}
*/

#declare A = 360/nb_images
#declare B = 90/nb_images
#declare C = 180/nb_images

//	Une ‚toile … 6 pointes
#declare L = 0.3
#declare H = 1.5

#declare bi_cone = union{
	cone{	<0.0,0.0,0.0>, L, <0.0,H,0.0>, 0.0
	}
	cone{	<0.0,0.0,0.0>, L, <0.0,H,0.0>, 0.0
		rotate <180.0,0.0,0.0>
	}
}

union {
	object { bi_cone
		texture {
			pigment {	color White	}
			finish { f_sph }
		}
	}
	object { bi_cone
		texture {
			pigment {	color Yellow	}
			finish { f_sph }
		}
		rotate <90.0,0.0,0.0>
	}
	object { bi_cone
		texture {
			pigment {	color Blue	}
			finish { f_sph }
		}
		rotate <90.0,90.0,0.0>
	}
	rotate <0.0,clock*C,0.0>
	rotate <45.0,0.0,30>	
}

#declare vue_image = camera {
	location <0.0, 1.5, -5.0>
	direction <0.0, 0.0,  1.4>
	up  <0.0,  1.0,  0.0>
	right <1.3333, 0.0, 0.0>
	look_at <0.0, 0.0, 0.0>
}

camera { vue_image	}

// Eclairage

object {
	light_source {	<3.0, 5.0, -3.0>	color White	}
}
