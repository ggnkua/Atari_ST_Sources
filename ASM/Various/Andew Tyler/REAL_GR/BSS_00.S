* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*Copyright A.Tyler 1991	bss_00.s                                  *
* A file of variables locations used in chapter 4.                *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


xbuf		ds.l	400	the buffer of x word pairs
phys_screen	ds.l	1	the address of the physical screen
log_screen	ds.l	1	the address of the logical screen
phys_tbl_y	ds.l	200	pointers to the row y's
hln_tbl		ds.w	256	the masks for filling words
screen		ds.l	1	the screen address
crds_in		ds.w	100	coords. list (x1,y1,x2,y2....x1,y1)
no_in		ds.w	1	number of sides to polygon
colour		ds.w	20	list of polygon colours

