// Animation simple pour before dawn
// en 24 images

#declare Gen_Ambient = 0.2
#declare nb_images = 24.0

#declare White	=	color rgb <1,1,1>
#declare Blue	=	color rgb <0,0,1>
#declare Red	= 	color rgb <1,0,0>
#declare Yellow = 	color rgb <1,1,0>
#declare Pink	=	color rgb <0.737255,0.560784,0.560784>

#declare f_sph = 
finish{	ambient Gen_Ambient
		phong 1.0 phong_size 100.0

}


/*
// Juste pour tester si l'objet reste entour‚ d'un espace noir
	background { color rgb <1.0,1.0,1.0>	}
*/

#declare A = 360/nb_images
#declare B = 90/nb_images

//	La boule rouge fait un tour en nb_images images
//	La boule bleue tourne sur elle-meme (1/4 de tour)
//	Les deux petites boules jaunes et rose font un 1 tour en 36 images

sphere{
	<0.0,0.0,0.0>,	0.8
	texture{
		pigment{
			radial
			frequency	4.0
			color_map
			{	[0.0,0.5	color	Blue	color White ]
				[0.5,1.0	color	White	color Blue	]
			}
		}
		finish { f_sph	}
	}
	rotate <0.0,clock*B,0.0>
}
sphere{	<1.7,0.0,0.0>,	0.3
	texture{
		pigment {	color Red	}
		finish { f_sph	}
	}
	rotate <0.0,A*clock,0.0>
}
union{
	sphere{
		<0.0,1.1,0.0>,	0.2
		texture{
			pigment {	color Yellow	}
			finish { f_sph	}
		}
	}
	sphere{
		<0.0,-1.1,0.0>,	0.2
		texture{
			pigment {	color Pink	}
			finish { f_sph	}
		}
	}
	rotate <A*clock,0.0,0.0>
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
