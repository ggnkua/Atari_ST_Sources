* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 data_05.s                                      *
*	                                                                *
*	 Data for Chapter 10. An ST cube                                *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

my_datax	dc.w	100,100,0,0,85,85,15,15,75,75,65,65,50,50,40,40	
		dc.w	85,85,70,70,70,70,15,15
my_datay	dc.w	0,100,100,0,10,40,40,10,20,40,40,20
		dc.w	10,30,30,10,50,90,90,50,60,80,80,60
my_dataz	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
my_edglst	dc.w	0,1,2,3,0,4,5,6,7,4,8,9,10,11,8,12,13,14,15,12
		dc.w	16,17,18,19,16,20,21,22,23,20
my_nedges	dc.w	4,4,4,4,4,4
my_npoly	dc.w	6
nparts		dc.w	6
inst_angles	dc.w	0,0,0,90,0,0,180,0,0,270,0,0,0,270,0,0,90,0	
inst_disp	dc.w	0,0,0,0,100,0,0,100,100,0,0,100,100,0,0,0,0,100
my_xmin		dc.w	0
my_xmax		dc.w	319
my_ymin		dc.w	0
my_ymax		dc.w	199

ill_vecx	dc.w	0
ill_vecy	dc.w	-16384	light shining from +y to -y
ill_vecz	dc.w	0
vwpointz	dc.w	-100
illkey		dc.w	1
intr_col	dc.w	0,1,0,0,1,1	
xshear		dc.w	1,0,0,0,1,0,1,0,1	1 shear
yshear		dc.w	1,0,0,1,1,0,1,0,1	2 shear
zshear		dc.w	2,0,0,0,1,0,0,0,1	3 stretch
palette	dc.w	0,$557,$446,$336,$226,$225,$114,$113
	dc.w	$756,$745,$734,$723,$713,$702,$502,$401
