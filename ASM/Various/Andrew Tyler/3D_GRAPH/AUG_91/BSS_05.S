* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*Copyright A.Tyler 1991	bss_05.s                                  *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Additional variables for Part 6
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
* Dynamical variables
speed		ds.w	1
vtheta_inc	ds.w	1
vphi_inc	ds.w	1
vgamma_inc	ds.w	1
shearflg	ds.w	1	shear flags

