scrxbytes	equ	640
scrlines	equ	200

	INCLUDE	MKSIN3.I

	text

******** INITIALISING ********

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr

	move.l	#scrbuf,scr
	move.l	#scrbuf2,scr2
	move.l	#scrbuf3,scr3

	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w

	bsr	SAVEFV

	move.b	$ffff8006.w,d0		check da monitor-type
	andi.b	#%11000000,d0
	tst.b	d0
	beq	EXIT
	btst	#6,d0
	bne.s	rgb

	move.l	#fv_vga,a0
	bsr	SETFV
	bra.s	on

rgb	move.l	#fv_rgb,a0
	bsr	SETFV

on	lea	buf3d_adr,a0
	move.l	#buf_3d,(a0)+
	move.l	#buf_3d2,(a0)+
	move.l	#buf_3d3,(a0)+
	move.l	#buf_3d4,(a0)+
	move.l	#buf_3d5,(a0)+
	move.l	#buf_3d6,(a0)+
	move.l	#buf_3d7,(a0)+
	not.l	$ffff9800.w

******** MAIN LOOP ********

mainloop
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

;	not.l	$ffff9800.w

	moveq	#0,d6
	move.l	scr,a0
	move.l	buf3d_adr+(4*6),a2
	tst.l	(a2)
	beq.s	.nodrw
	bsr	PLOT_3DBUF
.nodrw	move.w	#%0101001010001010,d6
	move.l	scr,a0
	move.l	buf3d_adr+(4*4),a2
	tst.l	(a2)
	beq.s	.nodrw2
	bsr	PLOT_3DBUF
.nodrw2	move.w	#%1010110101010101,d6
	move.l	scr,a0
	move.l	buf3d_adr+(4*2),a2
	tst.l	(a2)
	beq.s	.nodraw
	bsr	PLOT_3DBUF
.nodraw	move.w	#-150,pos_z
	lea	funlogo_ini(pc),a1
;	lea	logo3d_ini(pc),a1
;	lea	fuji_ini(pc),a1
	lea	rot_tbl,a2
	addi.w	#22,(a2)
	addi.w	#17,2(a2)
	move.l	buf3d_adr,a0
	bsr	ROTATE_3DBUF
	move.l	buf3d_adr,a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	pos_z,d2
	bsr	POSITION_3DBUF
	move.l	buf3d_adr,a0
	bsr	PERSPECT_3DBUF
	moveq	#$ffffffff,d6
	move.l	scr,a0
	move.l	buf3d_adr,a2
	bsr	PLOT_3DBUF

;	sub.w	#10,pos_z
;	bmi.s	.ok
;	add.w	#10,pos_z

* Rotate buffer-addresses
	lea	buf3d_adr,a0
	lea	(a0),a6
	movem.l	(a0)+,d0-d5
	move.l	(a0)+,(a6)+
	movem.l	d0-d5,(a6)

;	not.l	$ffff9800.w

	move.l	$466.w,d0
.tst	move.l	$466.w,d1
	sub.l	d0,d1
	beq.s	.tst

* Swap screens and install swapped screenaddress
.ok	move.l	scr,d0
	move.l	scr2,scr
	move.l	d0,scr2
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w

	bra	mainloop

******** REINITIALISING ********

OUT	bsr	RESTOREFV

EXIT	not.l	$ffff9800.w

	move.l	oldvbl,$70.w

	move.l	oldscr,d7
	swap	d7
	move.b	d7,$ffff8201.w
	rol.l	#8,d7
	move.b	d7,$ffff8203.w
	rol.l	#8,d7
	andi.b	#%11111100,d7
	move.b	d7,$ffff820d.w

	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINES ********

SAVEFV	lea	fvbuf,a1
	move.l	#'FVD2',(a1)+	4 bytes header
	move.b	$ffff8006.w,(a1)+	monitor type
	move.b	$ffff820a.w,(a1)+	sync
	move.l	$ffff820e.w,(a1)+	offset & vwrap
	move.w	$ffff8266.w,(a1)+	spshift
	move.l	#$ff8282,a0	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a0
	bne	.loop1
	move.l	#$ff82a2,a0	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a0
	bne	.loop2
	move	$ffff82c2.w,(a1)+	video control
	move	$ffff82c0.w,(a1)+	video clock
	move.b	$ffff8260.w,(a1)+	shifter resolution
	move.b	$ffff820a.w,(a1)+	video sync mode
	rts

RESTOREFV
	move.l	#fvbuf,a0
	bsr	SETFV
	rts

SETFV	cmp.l	#'FVD2',(a0)+	4 bytes header
	bne	.error

.ready	addq.l	#2,a0
	move.l	$70.w,-(sp)
	move	sr,-(sp)
	move.l	#.vbl,$70.w
	move	#$2300,sr

	move.l	$466.w,d0
.wait	cmp.l	$466.w,d0
	beq	.wait
	
	move.l	(a0)+,$ffff820e.w	offset & vwrap
	move.w	(a0)+,$ffff8266.w	spshift
	move.l	#$ff8282,a1	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a1
	bne	.loop1
	move.l	#$ff82a2,a1	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a1
	bne	.loop2
	move	(a0)+,$ffff82c2.w	video control
	move	(a0)+,$ffff82c0.w	video clock
	addq.l	#1,a0
	move.b	(a0)+,$ffff820a.w	video sync mode
	move	(sp)+,sr
	move.l	(sp)+,$70.w
	moveq	#0,d0
	rts
.error	moveq	#-1,d0
	rts
.wrongmon
	moveq	#-2,d0
	rts
.sm124	cmp.b	#0,(a0)
	bne	.wrongmon
	bra	.ready
.vga	cmp.b	#2,(a0)
	bne	.wrongmon
	bra	.ready
.vbl	addq.l	#1,$466.w
	rte

CLEAR_SCREEN
	move.l	scr,a0
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.w	#200-1,d7
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	add.l	#320*200*2,a0
.loop
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

* This routine is just a easy to calculate sinus-matrix thingy
* rotates around the z-axis and then around the y-axis.
* makes a rotated copy of the original...
* INPUT: a0: address of destination objectbuffer
*        a1: address of source objectbuffer
*        a2: address of rotation-array
ROTATE_3DBUF
* Get sine-values..
	lea	sine_tbl,a3
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a3,d0,d1,d2
	add.l	d1,d1
	add.l	d2,d2
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a3,d0,d3,d4
	add.l	d3,d3
	add.l	d4,d4
	move.l	a0,a6
	addq	#4,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	movea.w	d7,a5
	move.l	a1,a2
* Calculate the x-coordinates..
.xloop	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	addq	#2,a1
	move.w	(a1)+,d5
	ext.l	d5
	muls.l	d3,d5
	sub.l	d5,d0
	swap	d0
	move.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.xloop
* Calculate the y-coordinates..
	lea	6+2(a6),a0			* Get address of first y-coord
	move.l	d3,a3				* Backup
	move.l	d4,a4				* Backup
	muls.l	d1,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d1,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.yloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d2,d6
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.yloop
* Calculate the z-coordinates..
	lea	6+4(a6),a0			* Get address of first z-coord
	move.l	a3,d3
	move.l	a4,d4
	muls.l	d2,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d2,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.zloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d1,d6
	sub.l	d6,d5
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.zloop
	move.l	a1,(a6)				* Store address of object-polydata
	rts

* INPUT: a0: address of objectbuffer
POSITION_3DBUF
	addq	#4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

.2loop	add.w	d0,(a0)+
	add.w	d1,(a0)+
	add.w	d2,(a0)+
	dbra	d7,.2loop
	rts

* INPUT: a0: address of objectbuffer
PERSPECT_3DBUF
	addq	#4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

	move.l	#scrxbytes/4,d3
	move.l	#scrlines/2,d4
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			d0.w: scale factor

	movem.w	(a0),d1-d2
	asl.l	#8,d1
	asl.l	#8,d2
	divs.w	d0,d1			scale x-coordinate
	add.w	d3,d1			center x-coordinate
	move.w	d1,(a0)+
	divs.w	d0,d2			scale y-coordinate
	add.w	d4,d2			center y-coordinate
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
	rts

* INPUT: a0: screenaddress
*        a2: objectaddress
*        d6.w: color
PLOT_3DBUF
	move.l	a0,a6
	move.l	(a2)+,a1
	addq.l	#2,a2
	move.l	a0,a6
	move.w	(a1)+,d7
	subq.w	#1,d7
	bpl.s	PLOT_LINES
	rts

* The lineroutine has NO CLIPPING!!!
* The only real possible optimisations are using dedicated loops for certain
* angles(moving two pixels(longword) in one go) and drawing the line from
* both sides.
* The average speed is now 850.000 pix/sec.
* INPUT: d6.w: color of line
*        d7.w: number of lines - 1
*        a0: screenaddress
*        a1: startaddress of line-buffer
*        a2: startaddress of points
PLOT_LINES
.plotlp	movem.w	(a1)+,d0/d2
	add.l	d0,d0
	move.l	d0,d1				* /
	add.l	d0,d0				* | mulu.w #6,d0
	add.l	d1,d0				* \
	add.l	d2,d2				* /
	move.l	d2,d3				* | mulu.w #6,d2
	add.l	d2,d2				* \
	add.l	d3,d2
	movem.w	(a2,d0.l),d0-d1
	movem.w	(a2,d2.l),d2-d3
	move.l	d2,d4
	move.l	d3,d5
	sub.w	d0,d2
	bpl.s	.ok
	neg.w	d2
.ok	sub.w	d1,d3
	bpl.s	.ok2
	neg.w	d3
.ok2	cmp.w	d2,d3
	bhi.s	.ver
	cmp.w	d0,d4
	bhs.s	.do2
	exg	d0,d4
	exg	d1,d5
.do2	moveq	#80,d2			\put #640
	lsl.w	#3,d2			/in d2.l
	sub.w	d0,d4
	sub.w	d1,d5
	bpl.s	.shit
	neg.w	d5
	neg.l	d2
.shit	add.l	d0,d0
	add.l	d0,a0
	mulu.w	#640,d1
	add.l	d1,a0
	swap	d5
	addq.w	#1,d4
	divu.w	d4,d5
	moveq	#0,d0
	subq.w	#1,d4
.lp2	add.w	d5,d0
	bcc.s	.mov
	adda.l	d2,a0
.mov	move.w	d6,(a0)+
	dbra	d4,.lp2
	bra.s	.toend

.ver	cmp.w	d0,d4
	bhs.s	.do
	exg	d0,d4
	exg	d1,d5
.do	moveq	#80,d2			\put #640
	lsl.w	#3,d2			/in d2.l
	sub.w	d0,d4
	sub.w	d1,d5
	bpl.s	.shitt
	neg.w	d5
	neg.l	d2
.shitt	add.l	d0,d0
	add.l	d0,a0
	mulu.w	#640,d1
	add.l	d1,a0
	swap	d4
	addq.w	#1,d5
	divu.w	d5,d4
	moveq	#0,d0
	subq.w	#1,d5
	swap	d4
	eor.w	d4,d4
	addx.l	d4,d0
.lp	move.w	d6,(a0,d0.w*2)
	addx.l	d4,d0
	adda.l	d2,a0
	dbra	d5,.lp

.toend	lea	(a6),a0
	dbra	d7,.plotlp
	rts

******** INTERRUPTS ********

NEWVBL	addq.l	#1,$466.w
	rte

******** DATA + RESERVES ********

fv_vga	incbin	c:\coding\falclib2\falclib5\vgatrue2.fv
fv_rgb	incbin	c:\coding\falclib2\falclib5\r3220_t5.fv

sine_tbl	
	INCLUDE	SINUS.S

* Looks best at z_pos=-150
funlogo_ini
	dc.w	56

	dc.w	-120,-60,20
	dc.w	-60,-60,20
	dc.w	-60,-40,20
	dc.w	-100,-40,20
	dc.w	-100,-20,20
	dc.w	-80,-20,20
	dc.w	-80,0,20
	dc.w	-100,0,20
	dc.w	-100,40,20
	dc.w	-120,40,20
	dc.w	-120,-60,-20
	dc.w	-60,-60,-20
	dc.w	-60,-40,-20
	dc.w	-100,-40,-20
	dc.w	-100,-20,-20
	dc.w	-80,-20,-20
	dc.w	-80,0,-20
	dc.w	-100,0,-20
	dc.w	-100,40,-20
	dc.w	-120,40,-20

	dc.w	-40,-60,20
	dc.w	-20,-60,20
	dc.w	-20,20,20
	dc.w	20,20,20
	dc.w	20,-60,20
	dc.w	40,-60,20
	dc.w	40,40,20
	dc.w	-40,40,20
	dc.w	-40,-60,-20
	dc.w	-20,-60,-20
	dc.w	-20,20,-20
	dc.w	20,20,-20
	dc.w	20,-60,-20
	dc.w	40,-60,-20
	dc.w	40,40,-20
	dc.w	-40,40,-20

	dc.w	60,-60,20
	dc.w	80,-60,20
	dc.w	110,10,20
	dc.w	110,-60,20
	dc.w	130,-60,20
	dc.w	130,40,20
	dc.w	110,40,20
	dc.w	80,-30,20
	dc.w	80,40,20
	dc.w	60,40,20
	dc.w	60,-60,-20
	dc.w	80,-60,-20
	dc.w	110,10,-20
	dc.w	110,-60,-20
	dc.w	130,-60,-20
	dc.w	130,40,-20
	dc.w	110,40,-20
	dc.w	80,-30,-20
	dc.w	80,40,-20
	dc.w	60,40,-20

	dc.w	84

	dc.w	0,1
	dc.w	1,2
	dc.w	2,3
	dc.w	3,4
	dc.w	4,5
	dc.w	5,6
	dc.w	6,7
	dc.w	7,8
	dc.w	8,9
	dc.w	9,0
	dc.w	0,10
	dc.w	1,11
	dc.w	2,12
	dc.w	3,13
	dc.w	4,14
	dc.w	5,15
	dc.w	6,16
	dc.w	7,17
	dc.w	8,18
	dc.w	9,19
	dc.w	10,11
	dc.w	11,12
	dc.w	12,13
	dc.w	13,14
	dc.w	14,15
	dc.w	15,16
	dc.w	16,17
	dc.w	17,18
	dc.w	18,19
	dc.w	19,10

	dc.w	20,21
	dc.w	21,22
	dc.w	22,23
	dc.w	23,24
	dc.w	24,25
	dc.w	25,26
	dc.w	26,27
	dc.w	27,20
	dc.w	20,28
	dc.w	21,29
	dc.w	22,30
	dc.w	23,31
	dc.w	24,32
	dc.w	25,33
	dc.w	26,34
	dc.w	27,35
	dc.w	28,29
	dc.w	29,30
	dc.w	30,31
	dc.w	31,32
	dc.w	32,33
	dc.w	33,34
	dc.w	34,35
	dc.w	35,28

	dc.w	36,37
	dc.w	37,38
	dc.w	38,39
	dc.w	39,40
	dc.w	40,41
	dc.w	41,42
	dc.w	42,43
	dc.w	43,44
	dc.w	44,45
	dc.w	45,36
	dc.w	36,46
	dc.w	37,47
	dc.w	38,48
	dc.w	39,49
	dc.w	40,50
	dc.w	41,51
	dc.w	42,52
	dc.w	43,53
	dc.w	44,54
	dc.w	45,55
	dc.w	46,47
	dc.w	47,48
	dc.w	48,49
	dc.w	49,50
	dc.w	50,51
	dc.w	51,52
	dc.w	52,53
	dc.w	53,54
	dc.w	54,55
	dc.w	55,46

* Looks best at z_pos=-16
logo3d_ini
	dc.w	60

	dc.w	-80,-60,15
	dc.w	-50,-60,15
	dc.w	-20,-40,15
	dc.w	-20,-20,15
	dc.w	-35,0,15
	dc.w	-20,20,15
	dc.w	-20,40,15
	dc.w	-50,60,15
	dc.w	-80,60,15
	dc.w	-80,50,15
	dc.w	-60,50,15
	dc.w	-35,35,15			* 11
	dc.w	-35,22,15			* 12
	dc.w	-55,0,15
	dc.w	-35,-22,15			* 14
	dc.w	-35,-35,15			* 15
	dc.w	-60,-50,15
	dc.w	-80,-50,15
	dc.w	-80,-60,-15			* 18
	dc.w	-50,-60,-15
	dc.w	-20,-40,-15
	dc.w	-20,-20,-15
	dc.w	-35,0,-15
	dc.w	-20,20,-15
	dc.w	-20,40,-15
	dc.w	-50,60,-15
	dc.w	-80,60,-15
	dc.w	-80,50,-15
	dc.w	-60,50,-15
	dc.w	-35,35,-15			* 29
	dc.w	-35,22,-15
	dc.w	-55,0,-15
	dc.w	-35,-22,-15			* 32
	dc.w	-35,-35,-15
	dc.w	-60,-50,-15
	dc.w	-80,-50,-15
	dc.w	20,-60,15		32
	dc.w	60,-60,15
	dc.w	80,-40,15
	dc.w	80,40,15
	dc.w	60,60,15
	dc.w	20,60,15
	dc.w	35,-45,15		38
	dc.w	50,-45,15
	dc.w	65,-35,15
	dc.w	65,35,15
	dc.w	50,45,15
	dc.w	35,45,15
	dc.w	20,-60,-15		44
	dc.w	60,-60,-15
	dc.w	80,-40,-15
	dc.w	80,40,-15
	dc.w	60,60,-15
	dc.w	20,60,-15
	dc.w	35,-45,-15		50
	dc.w	50,-45,-15
	dc.w	65,-35,-15
	dc.w	65,35,-15
	dc.w	50,45,-15
	dc.w	35,45,-15

	dc.w	90				* Number of lines
* Front side of '3'
	dc.w	0,1
	dc.w	1,2
	dc.w	2,3
	dc.w	3,4
	dc.w	4,5
	dc.w	5,6
	dc.w	6,7
	dc.w	7,8
	dc.w	8,9
	dc.w	9,10
	dc.w	10,11
	dc.w	11,12
	dc.w	12,13
	dc.w	13,14
	dc.w	14,15
	dc.w	15,16
	dc.w	16,17
	dc.w	17,0
* Back side of '3'
	dc.w	18,19
	dc.w	19,20
	dc.w	20,21
	dc.w	21,22
	dc.w	22,23
	dc.w	23,24
	dc.w	24,25
	dc.w	25,26
	dc.w	26,27
	dc.w	27,28
	dc.w	28,29
	dc.w	29,30
	dc.w	30,31
	dc.w	31,32
	dc.w	32,33
	dc.w	33,34
	dc.w	34,35
	dc.w	35,18
* Lines connecting front and back of '3'
	dc.w	0,18
	dc.w	1,19
	dc.w	2,20
	dc.w	3,21
	dc.w	4,22
	dc.w	5,23
	dc.w	6,24
	dc.w	7,25
	dc.w	8,26
	dc.w	9,27
	dc.w	10,28
	dc.w	11,29
	dc.w	12,30
	dc.w	13,31
	dc.w	14,32
	dc.w	15,33
	dc.w	16,34
	dc.w	17,35
* Front of 'D'
	dc.w	36,37
	dc.w	37,38
	dc.w	38,39
	dc.w	39,40
	dc.w	40,41
	dc.w	41,36
	dc.w	42,43
	dc.w	43,44
	dc.w	44,45
	dc.w	45,46
	dc.w	46,47
	dc.w	47,42
* Back of 'D'
	dc.w	48,49
	dc.w	49,50
	dc.w	50,51
	dc.w	51,52
	dc.w	52,53
	dc.w	53,48
	dc.w	54,55
	dc.w	55,56
	dc.w	56,57
	dc.w	57,58
	dc.w	58,59
	dc.w	59,54
* Lines connecting back and front of 'D' toghether
	dc.w	36,48
	dc.w	37,49
	dc.w	38,50
	dc.w	39,51
	dc.w	40,52
	dc.w	41,53
	dc.w	42,54
	dc.w	43,55
	dc.w	44,56
	dc.w	45,57
	dc.w	46,58
	dc.w	47,59

fuji_ini
	dc.w	44			Number of points in Fuji

	dc.w	-50,-60,10		0
	dc.w	-57,0,10
	dc.w	-70,30,10
	dc.w	-95,38,10		3

	dc.w	-10,-60,10		4
	dc.w	-10,60,10		5

	dc.w	50,-60,10		6
	dc.w	57,0,10
	dc.w	70,30,10
	dc.w	95,38,10		9

	dc.w	-30,-60,10		10
	dc.w	-35,0,10
	dc.w	-50,40,10
	dc.w	-65,52,10
	dc.w	-95,60,10		14

	dc.w	10,-60,10		15
	dc.w	10,60,10		16

	dc.w	30,-60,10		17
	dc.w	35,0,10
	dc.w	50,40,10
	dc.w	65,52,10
	dc.w	95,60,10		21

	dc.w	-50,-60,-10
	dc.w	-57,0,-10
	dc.w	-70,30,-10
	dc.w	-95,38,-10

	dc.w	-10,-60,-10
	dc.w	-10,60,-10

	dc.w	50,-60,-10
	dc.w	57,0,-10
	dc.w	70,30,-10
	dc.w	95,38,-10

	dc.w	-30,-60,-10
	dc.w	-35,0,-10
	dc.w	-50,40,-10
	dc.w	-65,52,-10
	dc.w	-95,60,-10

	dc.w	10,-60,-10
	dc.w	10,60,-10

	dc.w	30,-60,-10
	dc.w	35,0,-10
	dc.w	50,40,-10
	dc.w	65,52,-10
	dc.w	95,60,-10

	dc.w	56			number lines in Fuji

	dc.w	0,1
	dc.w	1,2
	dc.w	2,3

	dc.w	4,5

	dc.w	10,11
	dc.w	11,12
	dc.w	12,13
	dc.w	13,14

	dc.w	6,7
	dc.w	7,8
	dc.w	8,9

	dc.w	15,16

	dc.w	17,18
	dc.w	18,19
	dc.w	19,20
	dc.w	20,21

	dc.w	22+0,22+1
	dc.w	22+1,22+2
	dc.w	22+2,22+3

	dc.w	22+4,22+5

	dc.w	22+10,22+11
	dc.w	22+11,22+12
	dc.w	22+12,22+13
	dc.w	22+13,22+14

	dc.w	22+6,22+7
	dc.w	22+7,22+8
	dc.w	22+8,22+9

	dc.w	22+15,22+16

	dc.w	22+17,22+18
	dc.w	22+18,22+19
	dc.w	22+19,22+20
	dc.w	22+20,22+21

	dc.w	4,15
	dc.w	5,16
	dc.w	22+4,22+15
	dc.w	22+5,22+16
	dc.w	4,22+4
	dc.w	5,22+5
	dc.w	15,22+15
	dc.w	16,22+16

	dc.w	0,10
	dc.w	22+0,22+10
	dc.w	0,22+0
	dc.w	10,22+10
	dc.w	3,14
	dc.w	22+3,22+14
	dc.w	3,22+3
	dc.w	14,22+14

	dc.w	6,17
	dc.w	22+6,22+17
	dc.w	6,22+6
	dc.w	17,22+17
	dc.w	9,21
	dc.w	9+22,21+22
	dc.w	9,22+9
	dc.w	21,22+21

******** RESERVES ********

	bss
	even

*init-data

oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
fvbuf	ds.w	24

*scr-stuff

scr	ds.l	1
scr2	ds.l	1
scr3	ds.l	1
	ds.w	1
scrbuf	ds.w	320*200
scrbuf2	ds.w	320*200
scrbuf3	ds.w	320*200

*rotation_shit
rot_tbl	ds.w	3

*rest

pos_z	ds.w	1
color	ds.w	1

buf3d_adr
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
	ds.l	1
buf_3d	ds.w	500
buf_3d2	ds.w	500
buf_3d3	ds.w	500
buf_3d4	ds.w	500
buf_3d5	ds.w	500
buf_3d6	ds.w	500
buf_3d7	ds.w	500