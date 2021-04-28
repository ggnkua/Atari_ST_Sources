* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*	        	bss_01.s			          *
*          A file of variables used in Part 2.                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* Polygon atributes
crds_out	ds.w	100	list of clipped coords.
no_out		ds.w	1	of which there are this many
xmax		ds.w	1	clip frame limit
xmin		ds.w	1	ditto
ymin		ds.w	1	ditto
ymax		ds.w	1	ditto
* screen parameters
screen1		ds.l	1	location of screen 1
screen2		ds.l	2	ditto		   2
screenflag	ds.w	1	0 for screen1, 1 for screen2

	include	bss_00.s
