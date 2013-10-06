* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*Copyright A.Tyler 1991	bss_01.s			          *
* A file of variables used in chapter 5.                          *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


* System variables
xbuf		ds.l	400	the buffer of x word pairs
phys_screen	ds.l	1	the address of the physical screen
log_screen	ds.l	1	the address of the logical screen
phys_tbl_y	ds.l	200	pointers to the row y's
hln_tbl		ds.w	256	the masks for filling words
screen		ds.l	1	address of current screen
* Polygon atributes
crds_in		ds.w	100	input coords. list (x1,y1,x2,y2....x1,y1)
crds_out	ds.w	100	output ditto
no_in		ds.w	1	input number of sides to polygon
no_out		ds.w	1	output ditto
colour		ds.w	20	list of polygon colours
xmax		ds.w	1	clip frame limit
xmin		ds.w	1	ditto
ymin		ds.w	1	ditto
ymax		ds.w	1	ditto
