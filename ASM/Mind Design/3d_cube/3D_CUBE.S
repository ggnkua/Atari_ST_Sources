*	En liten rutin som visar hur man kan g”ra en 3D-cube med
*	Omegas polygonrutin....
*
*	K†d:
*		Polygonrutin av Omega
*		Cube k†d av Deez....
*

	opt	o+,ow-
start	clr.l	-(sp)			* Enter Supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,super
	bclr	#0,$484.w		* Get rid of the fuckin' keyclick
	dc.w	$a00a			* Hide mousepointer
	move.b	#$12,$fffc02

	move.l	#$3f0000,a1		* Erase both screens
	jsr	clr_scr
	move.l	#$3f8000,a1
	jsr	clr_scr

	move.w	#0,-(sp)
	move.l	#$3f0000,-(sp)
	move.l	#$3f0000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	movem.l	$ff8240,d0-d7		* Install new palette
	movem.l	d0-d7,oldpal
	clr.l	d0
	lea.l	ste_col,a0
	lea.l	palett,a1
	move.l	#$ff8240,a2
	move.w	#15,d7
.color_loop
	move.w	(a1)+,d0
	move.w	d0,d1
	move.w	d0,d2
	asr.w	#8,d0
	move.w	d0,d3
	asl.w	#4,d0
	asr.w	#4,d1
	sub.w	d0,d1
	and.w	#15,d2
	move.b	(a0,d3),d0
	ext.w	d0
	move.b	(a0,d1),d1
	ext.w	d1
	move.b	(a0,d2),d2
	ext.w	d2
	asl.w	#8,d0
	asl.w	#4,d1
	add.w	d2,d1
	add.w	d1,d0
	move.w	d0,(a2)+
	dbra	d7,.color_loop

	jsr	init_polygon_code

main	jsr	lines
	jsr	draw_polygon
	jsr	tst_scr
	jsr	waitvbl
	jsr	blitter_cls
	cmp.b	#1,$fffc02		* Somebody pressed <ESC>?
	bne	main			* If not so back to Main

restore	movem.l	oldpal,d0-d7		* Restore old palette
	movem.l	d0-d7,$ff8240
	move.b	#$8,$fffc02
	move.l	super,-(sp)		* Back into User mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			* Quit program
	trap	#1

*	Here are all the subroutines

swap1	move.w	#-1,-(sp)		* Swap screens
	move.l	#$3f8000,-(sp)
	move.l	#$3f0000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#$3f0000,screen
	rts

swap2	move.w	#-1,-(sp)		* Swap screens
	move.l	#$3f0000,-(sp)
	move.l	#$3f8000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#$3f8000,screen
	rts

tst_scr	cmpi.l	#$3f8000,screen
	bne.s	swp_2
	jsr	swap1
	rts
swp_2	jsr	swap2
	rts

waitvbl	move.w	#37,-(sp)		* Wait for Vertical Blank
	trap	#14
	addq.l	#2,sp
	rts

init_polygon_code
	lea.l	parameters,a0
	jsr	polygon_mupp
	move.l	a0,variabler
	move.l	a1,hoppa
	move.l	a2,hoppa3
	move.l	a3,hoppa4
	rts

draw_polygon
	jsr	draw_side1
	jsr	draw_side2
	jsr	draw_side3
	jsr	draw_side4
	jsr	draw_side5
	jsr	draw_side6
	rts

draw_side1
	move.l	variabler,a0
	lea.l	newco,a2
	move.w	#%1100000110,(a0)+
	move.w	#%0100000000,(a0)+
	move.l	(a2),(a0)+
	move.l	4(a2),(a0)+
	move.l	8(a2),(a0)+
	move.l	12(a2),(a0)+
	move.l	hoppa,a1
	jsr	(a1)
	rts

draw_side2
	move.l	variabler,a0
	lea.l	newco,a2
	move.w	#%1100000101,(a0)+
	move.w	#%0100000000,(a0)+
	move.l	16(a2),(a0)+
	move.l	20(a2),(a0)+
	move.l	24(a2),(a0)+
	move.l	28(a2),(a0)+
	move.l	hoppa,a1
	jsr	(a1)
	rts

draw_side3
	move.l	variabler,a0
	lea.l	newco,a2
	move.w	#%1100000101,(a0)+
	move.w	#%1000000000,(a0)+
	move.l	(a2),(a0)+
	move.l	16(a2),(a0)+
	move.l	28(a2),(a0)+
	move.l	12(a2),(a0)+
	move.l	hoppa,a1
	jsr	(a1)
	rts

draw_side4
	move.l	variabler,a0
	lea.l	newco,a2
	move.w	#%1100000101,(a0)+
	move.w	#%1000000000,(a0)+
	move.l	4(a2),(a0)+
	move.l	8(a2),(a0)+
	move.l	24(a2),(a0)+
	move.l	20(a2),(a0)+
	move.l	hoppa,a1
	jsr	(a1)
	rts

draw_side5
	move.l	variabler,a0
	lea.l	newco,a2
	move.w	#%1100000101,(a0)+
	move.w	#%1100000000,(a0)+
	move.l	(a2),(a0)+
	move.l	4(a2),(a0)+
	move.l	20(a2),(a0)+
	move.l	16(a2),(a0)+
	move.l	hoppa,a1
	jsr	(a1)
	rts

draw_side6
	move.l	variabler,a0
	lea.l	newco,a2
	move.w	#%1100000101,(a0)+
	move.w	#%1100000000,(a0)+
	move.l	28(a2),(a0)+
	move.l	24(a2),(a0)+
	move.l	8(a2),(a0)+
	move.l	12(a2),(a0)+
	move.l	hoppa,a1
	jsr	(a1)
	rts

lines	add.w	#3*2,xang
	andi.w	#$3ff,xang
	add.w	#5*2,yang
	andi.w	#$3ff,yang
	add.w	#2*2,zang
	andi.w	#$3ff,zang

spinit	lea.l	sintab,a0
	move.l	a0,a3
	move.l	a0,a4
	add.w	xang,a0
	add.w	yang,a3
	add.w	zang,a4
	lea.l	coords,a1
	lea.l	newco,a2
	move.w	#8-1,d5
	move.w	#14,d7
next	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2

rot_x	move.w	d1,d3			* copy y
	move.w	d2,d4			* copy z
	muls.w	256(a0),d1		* y.cos
	muls.w	(a0),d4			* z.sin
	sub.l	d4,d1			* y.cos - z.sin
	asr.l	d7,d1			* new y --> d1
	muls.w	(a0),d3			* y.sin
	muls.w	256(a0),d2		* z.cos
	add.l	d3,d2			* y.sin + z.cos
	asr.l	d7,d2			* new z --> d2

rot_y	move.w	d0,d3			* copy x 
	move.w	d2,d4			* copy z
	muls.w	256(a3),d0		* x.cos
	muls.w	(a3),d4			* z.sin
	add.l	d4,d0			* x.cos + y.sin
	asr.l	d7,d0			* new x --> d0
	muls.w	(a3),d3			* x.sin
	muls.w	256(a3),d2		* z.cos
	sub.l	d3,d2			* z.cos - x.sin
	asr.l	d7,d2			* new z --> d2

rot_z	move.w	d0,d3			* copy x
	move.w	d1,d4			* copy z
	muls.w	256(a4),d0		* x.cos
	muls.w	(a4),d4			* y.sin
	sub.l	d4,d0			* x.cos - y.sin
	asr.l	d7,d0			* new x --> d0
	muls.w	(a4),d3			* x.sin
	muls.w	256(a4),d1		* y.cos
	add.l	d3,d1			* x.sin + y.cos
	asr.l	d7,d1			* new y --> d1

per	move.w	#1000,d3
	move.w	#2000,d4
	sub.l	d2,d3
	muls.w	d3,d0
	divs.w	d4,d0
	muls.w	d3,d1
	divs.w	d4,d1

	add.w	#100,d1			* Center Ypos
	add.w	#160,d0			* Center Xpos

	move.w	d0,(a2)+
	move.w	d1,(a2)+
	dbra	d5,next
	rts

blitter_cls
	move.w	#8,$ff8a20
	move.w	#0,$ff8a22
	move.w	#$ffff,$ff8a28
	move.w	#$ffff,$ff8a2a
	move.w	#$ffff,$ff8a2c
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.l	screen,$ff8a32
	move.b	#2,$ff8a3a
	move.b	#0,$ff8a3b
	move.b	#0,$ff8a3d
	move.w	#20*200,$ff8a36
	move.w	#1,$ff8a38
	move.b	#$c0,$ff8a3c

	move.w	#8,$ff8a20
	move.w	#0,$ff8a22
	move.w	#$ffff,$ff8a28
	move.w	#$ffff,$ff8a2a
	move.w	#$ffff,$ff8a2c
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.l	screen,$ff8a32
	addq.l	#2,$ff8a32
	move.b	#2,$ff8a3a
	move.b	#0,$ff8a3b
	move.b	#0,$ff8a3d
	move.w	#20*200,$ff8a36
	move.w	#1,$ff8a38
	move.b	#$c0,$ff8a3c
	rts

clr_scr	move.w	#40*200,d0		* Clear whole screen,
clr	clr.l	(a1)+			* all 4 bitplanes
	dbra	d0,clr
	rts

	section	data
super	dc.l	0
screen	dc.l	$3f0000
offset	dc.w	0
xang	dc.w	0
yang	dc.w	0
zang	dc.w	0
dist	dc.w	0
str_off	dc.l	0
ste_col	dc.b	$0,$8,$1,$9,$2,$A,$3,$B,$4,$C,$5,$D,$6,$E,$7,$F
palett	dc.w	$408,$666,$444,$333,$000,$000,$000,$000
	dc.w	$fff,$666,$444,$333,$fff,$fff,$fff,$fff
sintab	dc.w	0,201,402,603,803,1004,1205,1405,1605
	dc.w	1805,2005,2204,2404,2602,2801,2998,3196,3393
	dc.w	3589,3785,3980,4175,4369,4563,4756,4948,5139
	dc.w	5329,5519,5708,5896,6083,6269,6455,6639,6822
	dc.w	7005,7186,7366,7545,7723,7900,8075,8249,8423
	dc.w	8594,8765,8934,9102,9268,9434,9597,9759,9920
	dc.w	10079,10237,10393,10548,10701,10853,11002,11150,11297
	dc.w	11442,11585,11726,11866,12003,12139,12273,12406,12536
	dc.w	12665,12791,12916,13038,13159,13278,13395,13510,13622
	dc.w	13733,13842,13948,14053,14155,14255,14353,14449,14543
	dc.w	14634,14723,14810,14895,14978,15058,15136,15212,15286
	dc.w	15357,15426,15492,15557,15618,15678,15735,15790,15842
	dc.w	15892,15940,15985,16028,16069,16107,16142,16175,16206
	dc.w	16234,16260,16284,16305,16323,16339,16353,16364,16372
	dc.w	16379,16382,16384,16382,16379,16372,16364,16353,16339
	dc.w	16323,16305,16284,16260,16234,16206,16175,16142,16107
	dc.w	16069,16028,15985,15940,15892,15842,15790,15735,15678
	dc.w	15618,15557,15492,15426,15357,15286,15212,15136,15058
	dc.w	14978,14895,14810,14723,14634,14543,14449,14353,14255
	dc.w	14155,14053,13948,13842,13733,13622,13510,13395,13278
	dc.w	13159,13038,12916,12791,12665,12536,12406,12273,12139
	dc.w	12003,11866,11726,11585,11442,11297,11150,11002,10853
	dc.w	10701,10548,10393,10237,10079,9920,9759,9597,9434
	dc.w	9268,9102,8934,8765,8594,8423,8249,8075,7900
	dc.w	7723,7545,7366,7186,7005,6822,6639,6455,6269
	dc.w	6083,5896,5708,5519,5329,5139,4948,4756,4563
	dc.w	4369,4175,3980,3785,3589,3393,3196,2998,2801
	dc.w	2602,2404,2204,2005,1805,1605,1405,1205,1004
	dc.w	803,603,402,201,0,-202,-403,-604,-804
	dc.w	-1005,-1206,-1406,-1606,-1806,-2006,-2205,-2405,-2603
	dc.w	-2802,-2999,-3197,-3394,-3590,-3786,-3981,-4176,-4370
	dc.w	-4564,-4757,-4949,-5140,-5330,-5520,-5709,-5897,-6084
	dc.w	-6270,-6456,-6640,-6823,-7006,-7187,-7367,-7546,-7724
	dc.w	-7901,-8076,-8250,-8424,-8595,-8766,-8935,-9103,-9269
	dc.w	-9435,-9598,-9760,-9921,-10080,-10238,-10394,-10549,-10702
	dc.w	-10854,-11003,-11151,-11298,-11443,-11586,-11727,-11867,-12004
	dc.w	-12140,-12274,-12407,-12537,-12666,-12792,-12917,-13039,-13160
	dc.w	-13279,-13396,-13511,-13623,-13734,-13843,-13949,-14054,-14156
	dc.w	-14256,-14354,-14450,-14544,-14635,-14724,-14811,-14896,-14979
	dc.w	-15059,-15137,-15213,-15287,-15358,-15427,-15493,-15558,-15619
	dc.w	-15679,-15736,-15791,-15843,-15893,-15941,-15986,-16029,-16070
	dc.w	-16108,-16143,-16176,-16207,-16235,-16261,-16285,-16306,-16324
	dc.w	-16340,-16354,-16365,-16373,-16380,-16383,-16384,-16383,-16380
	dc.w	-16373,-16365,-16354,-16340,-16324,-16306,-16285,-16261,-16235
	dc.w	-16207,-16176,-16143,-16108,-16070,-16029,-15986,-15941,-15893
	dc.w	-15843,-15791,-15736,-15679,-15619,-15558,-15493,-15427,-15358
	dc.w	-15287,-15213,-15137,-15059,-14979,-14896,-14811,-14724,-14635
	dc.w	-14544,-14450,-14354,-14256,-14156,-14054,-13949,-13843,-13734
	dc.w	-13623,-13511,-13396,-13279,-13160,-13039,-12917,-12792,-12666
	dc.w	-12537,-12407,-12274,-12140,-12004,-11867,-11727,-11586,-11443
	dc.w	-11298,-11151,-11003,-10854,-10702,-10549,-10394,-10238,-10080
	dc.w	-9921,-9760,-9598,-9435,-9269,-9103,-8935,-8766,-8595
	dc.w	-8424,-8250,-8076,-7901,-7724,-7546,-7367,-7187,-7006
	dc.w	-6823,-6640,-6456,-6270,-6084,-5897,-5709,-5520,-5330
	dc.w	-5140,-4949,-4757,-4564,-4370,-4176,-3981,-3786,-3590
	dc.w	-3394,-3197,-2999,-2802,-2603,-2405,-2205,-2006,-1806
	dc.w	-1606,-1406,-1206,-1005,-804,-604,-403,-202,0
	dc.w	201,402,603,803,1004,1205,1405,1605,1805
	dc.w	2005,2204,2404,2602,2801,2998,3196,3393,3589
	dc.w	3785,3980,4175,4369,4563,4756,4948,5139,5329
	dc.w	5519,5708,5896,6083,6269,6455,6639,6822,7005
	dc.w	7186,7366,7545,7723,7900,8075,8249,8423,8594
	dc.w	8765,8934,9102,9268,9434,9597,9759,9920,10079
	dc.w	10237,10393,10548,10701,10853,11002,11150,11297,11442
	dc.w	11585,11726,11866,12003,12139,12273,12406,12536,12665
	dc.w	12791,12916,13038,13159,13278,13395,13510,13622,13733
	dc.w	13842,13948,14053,14155,14255,14353,14449,14543,14634
	dc.w	14723,14810,14895,14978,15058,15136,15212,15286,15357
	dc.w	15426,15492,15557,15618,15678,15735,15790,15842,15892
	dc.w	15940,15985,16028,16069,16107,16142,16175,16206,16234
	dc.w	16260,16284,16305,16323,16339,16353,16364,16372,16379
	dc.w	16382,16384

coords	dc.w	-100,-100,100
	dc.w	100,-100,100
	dc.w	100,100,100
	dc.w	-100,100,100

	dc.w	-100,-100,-100
	dc.w	100,-100,-100
	dc.w	100,100,-100
	dc.w	-100,100,-100

variabler
	dc.l	0
hoppa	dc.l	0
hoppa3	dc.l	0
hoppa4	dc.l	0
parameters
	dc.w	0
	dc.l	buffert
	dc.l	screen
	dc.w	0,0,-1000
	dc.w	319,199,1000
polygon_mupp
	incbin	'poly.bin'		* Omegas polyrout... in bin form

	section	bss
	ds.l	4096
buffert	ds.l	131*256
oldpal	ds.l	8
newco	ds.l	1000
	end
