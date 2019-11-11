* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*			bss_03.s				    *
* 		Additional variables for Part 4                     *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include	bss_02.s
	include bss_01.s
* Object frame variables
otheta		ds.w	1	the rotation of object coords about wx
ophi		ds.w	1	ditto				    wy	
ogamma		ds.w	1	ditto                               wz
ocoordsx	ds.w	200	vertex x coords
ocoordsy	ds.w	200	ditto  y
ocoordsz	ds.w	200	ditto  z
oncoords	ds.w	1	number
Oox		ds.w	1	object origin x coord.in world frame
Ooy		ds.w	1	ditto         y
Ooz		ds.w	1	ditto         z
* World frame variables
wcoordsx	ds.w	200
wcoordsy	ds.w	200
wcoordsz	ds.w	200
* Variables for the o_w transform
o_wmatx		ds.w	9	the matrix elements

* General
stheta		ds.w	1	trig functions of the current angle
ctheta		ds.w	1
sphi		ds.w	1
cphi		ds.w	1
sgamma		ds.w	1
cgamma		ds.w	1
