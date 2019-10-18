// Animation simple pour before dawn
// en 24 images

#declare Gen_Ambient = 0.2
#declare nb_images = 24.0

#declare White	=	color rgb <1.0,1.0,1.0>
#declare Blue	=	color rgb <0.0,0.0,1.0>
#declare Red	= 	color rgb <1.0,0.0,0.0>
#declare Yellow = 	color rgb <1.0,1.0,0.0>

#declare f_sph = 
finish{	ambient Gen_Ambient
		phong 1.0 phong_size 100.0
}

/*
background { color rgb <1.0,1.0,1.0>	}
*/

#declare A = 360/nb_images

// Un cube compos‚ de huit boules
#declare w = 0.6
#declare r = 0.4
union{
	union {
		sphere{	<w,w,-w>,	r
			texture{
				pigment {	color Blue	}
				finish { f_sph	}
			}
		}
		sphere{	<-w,w,-w>,	r
			texture{
				pigment {	color Yellow	}
				finish { f_sph	}
			}
		}
		sphere{	<w,w,w>,	r
			texture{
				pigment {	color Red	}
				finish { f_sph	}
			}
		}
		sphere{	<-w,w,w>,	r
			texture{
				pigment {	color White	}
				finish { f_sph	}
			}
		}
		bounded_by{box{<-(w+r),w-r,-(w+r)>,<w+r,w+r,w+r>}}
	}
	union {
		sphere{	<w,-w,-w>,	r
			texture{
				pigment {	color White	}
				finish { f_sph	}
			}
		}
		sphere{	<-w,-w,-w>,	r
			texture{
				pigment {	color Red	}
				finish { f_sph	}
			}
		}
		sphere{	<w,-w,w>,	r
			texture{
				pigment {	color Yellow	}
				finish { f_sph	}
			}
		}
		sphere{	<-w,-w,w>,	r
			texture{
				pigment {	color Blue	}
				finish { f_sph	}
			}
		}
		bounded_by{box{<-(w+r),-(w+r),-(w+r)>,<w+r,-(w-r),w+r>}}
	}
	rotate <0.0,clock*A,0.0>
	rotate <-20.0,0.0,0.0>
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
