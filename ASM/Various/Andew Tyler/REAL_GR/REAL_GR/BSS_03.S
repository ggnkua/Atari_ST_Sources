* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*Copyright A.Tyler 1991	bss_03.s                                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include	bss_02.s
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
screen1		ds.l	1	where the screen1 address is stored
screen2		ds.l	1	ditto           2
scrn1_tbl	ds.l	200	table of row addresses for 1	
scrn2_tbl	ds.l	200	ditto                      2
screenflag	ds.w	1	0 to display screen1, 1 for screen2
stheta		ds.w	1	trig functions of the current angle
ctheta		ds.w	1
sphi		ds.w	1
cphi		ds.w	1
sgamma		ds.w	1
cgamma		ds.w	1
