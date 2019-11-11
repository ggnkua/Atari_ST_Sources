* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*Copyright A.Tyler 1991	bss_05.s                                  *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Additional variables for Chapter 10
	include	bss_04.s	surface illumination vars.
	include	bss_03.s
* world frame variable
wncoords	ds.w	1	no. of vertices in world frame
*view frame variables
vtheta		ds.w	1	rotation of view frame about wx
vphi		ds.w	1	ditto			     wy	
vgamma		ds.w	1	ditto                        wz
Ovx		ds.w	1	view frame origin x  in world frame
Ovy		ds.w	1	ditto             y
Ovz		ds.w	1	ditto             z
* The general transform matrices
w_vmatx		ds.w	9	the matrix elements
tempmatx	ds.w	9	temporary store for matx products
* Variables for the intelligent keyboard
gem_joy		ds.l	1	store gem joystick handler
joy_data	ds.w	1	jostick direction/fire
gem_mse		ds.l	1	store gem mouse handler
mse_click	ds.w	1	click flag
mouse_dx	ds.w	1	x displacement since last
mouse_dy	ds.w	1	y ditto
* Dynamical variables
speed		ds.w	1
vtheta_inc	ds.w	1
vphi_inc	ds.w	1
vgamma_inc	ds.w	1
fire		ds.w	1	mse fire flag
shearflg	ds.w	1	shear flags
