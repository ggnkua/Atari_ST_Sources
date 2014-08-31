rsc_obs	dc.w	13	* 14 objects in RSC *

menu1	dc.w	-1,1,4
	dc.w	25,0,0		*0*
	dc.l	0
	dc.w	0,0,80,25

	dc.w	4,2,2
	dc.w	20,0,0		*1*
	dc.l	$1100
	dc.w	0,0,80,$201

	dc.w	1,3,3
	dc.w	25,0,0		*2*
	dc.l	0
	dc.w	2,0,10,$301

	dc.w	2,-1,-1
	dc.w	32,0,0		*3*
	dc.l	text1
	dc.w	0,0,10,$301

	dc.w	0,5,5
	dc.w	25,0,0		*4*
	dc.l	0
	dc.w	0,$301,80,23

	dc.w	4,6,13
	dc.w	20,0,0		*5*
	dc.l	$FF1100
	dc.w	2,0,17,8

	dc.w	7,-1,-1
	dc.w	28,0,0		*6*
	dc.l	text2
	dc.w	0,0,17,1

	dc.w	8,-1,-1
	dc.w	28,0,8		*7*
	dc.l	text3
	dc.w	0,1,17,1

	dc.w	9,-1,-1
	dc.w	28,0,0		*8*
	dc.l	text4
	dc.w	0,2,17,1

	dc.w	10,-1,-1
	dc.w	28,0,0		*9*
	dc.l	text5
	dc.w	0,3,17,1

	dc.w	11,-1,-1
	dc.w	28,0,0		*10*
	dc.l	text6
	dc.w	0,4,17,1

	dc.w	12,-1,-1
	dc.w	28,0,0		*11*
	dc.l	text7
	dc.w	0,5,17,1

	dc.w	13,-1,-1
	dc.w	28,0,0		*12*
	dc.l	text8
	dc.w	0,6,17,1

	dc.w	5,-1,-1
	dc.w	28,32,0		*13*
	dc.l	text9
	dc.w	0,7,17,1

		* Text data *

text1	dc.b	' LedP_Tog',0
text2	dc.b	'  Information... ',0
text3	dc.b	'-----------------',0
text4	dc.b	'  Accessoire  1  ',0
text5	dc.b	'  Accessoire  2  ',0
text6	dc.b	'  Accessoire  3  ',0
text7	dc.b	'  Accessoire  4  ',0
text8	dc.b	'  Accessoire  5  ',0
text9	dc.b	'  Accessoire  6  ',0
null	dc.b	0,0
