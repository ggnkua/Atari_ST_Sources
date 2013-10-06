* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*Copyright A.Tyler 1991	bss_02.s                                      *
* Variables locations used in chapter 6.                              *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* System variables
xbuf		ds.l	400	the buffer of x word pairs
phys_screen	ds.l	1	the address of the physical screen
phys_tbl_y	ds.l	200	pointers to the row y's
hln_tbl		ds.w	256	the masks for filling words
screen		ds.l	1	the current screen pointer
* Polygon atributes
crds_in		ds.w	100	input coords. list (x1,y1,x2,y2....x1,y1)
crds_out	ds.w	100	output ditto
no_in		ds.w	1	input number of sides to polygon
no_out		ds.w	1	output ditto
colour		ds.w	1	current polygon colour
xmax		ds.w	1	window limit
xmin		ds.w	1	ditto
ymin		ds.w	1	ditto
ymax		ds.w	1	ditto
* Screen lists
scoordsx	ds.w	100	x coordinates
scoordsy	ds.w	100	ditto   y
sedglst		ds.w	100	edge connections
snedges		ds.w	20	no. edges in each polygon
npoly		ds.w	1	no. polygons in this polyhedron
col_lst		ds.w	20	colours of polygons
* View frame lists
vcoordsx	ds.w	100	x coords
vcoordsy	ds.w	100	y coords
vcoordsz	ds.w	100	z coords
vncoords	ds.w	1	no. of vertices



	
