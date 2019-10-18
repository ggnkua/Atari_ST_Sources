// Animation simple pour before dawn
// en 24 images

#declare Gen_Ambient = 0.2
#declare nb_images = 24.0


#declare White	=	color rgb <1.0,1.0,1.0>
#declare Red	= 	color rgb <1.0,0.0,0.0>
#declare Pink	=	color rgb <0.737255,0.560784,0.560784>

#declare f_sph = 
finish{	ambient Gen_Ambient
		phong 1.0 phong_size 100.0
}

/*
background { color rgb <1.0,1.0,1.0>	}
*/

#declare A = 360/nb_images

// Une sphŠre marbr‚e
sphere{	<0.0,0.0,0.0>	1.4
	texture{
		pigment{
			marble
			turbulence 1.8
			color_map 
			{	[0.0, 0.5   color Red
							color Pink ]
				[0.5, 1.001 color White
							color White ]
			}
		}
		finish{ f_sph	}
	}
	rotate <0.0,clock*A,0.0>
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
