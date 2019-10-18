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

#declare Grand_R = 1.0
#declare Petit_R = 0.25

#declare Tore = torus { Grand_R, Petit_R }

/*
background { color rgb <1.0,1.0,1.0>	}
*/

#declare C = 180/nb_images

// Trois tores imbriqu‚s perpendiculaires les uns aux autres
union{
	object{	Tore
		texture {
			pigment {	color Red	}
			finish { f_sph	}
		}
		bounded_by {box{<-(Grand_R+Petit_R+0.01),-(Petit_R+0.01),-(Grand_R+Petit_R+0.01)>,
						< (Grand_R+Petit_R+0.01), (Petit_R+0.01), (Grand_R+Petit_R+0.01)>}}
		rotate <90.0,0.0,0.0>
	}
	object{	Tore
		texture {
			pigment {	color White	}
			finish { f_sph	}
		}
		bounded_by {box{<-(Grand_R+Petit_R+0.01),-(Petit_R+0.01),-(Grand_R+Petit_R+0.01)>,
						< (Grand_R+Petit_R+0.01), (Petit_R+0.01), (Grand_R+Petit_R+0.01)>}}
		rotate <90.0,0.0,0.0>
		rotate <0.0,90.0,0.0>
	}
	object{	Tore
		texture {
			pigment {	color Pink	}
			finish { f_sph	}
		}
		bounded_by {box{<-(Grand_R+Petit_R+0.01),-(Petit_R+0.01),-(Grand_R+Petit_R+0.01)>,
						< (Grand_R+Petit_R+0.01), (Petit_R+0.01), (Grand_R+Petit_R+0.01)>}}
	}

	bounded_by{sphere{<0.0,0.0,0.0>,	Grand_R+Petit_R+0.01	}}
	rotate <0.0,clock*C,0.0>
	rotate <-50.0,20.0,0.0>
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
