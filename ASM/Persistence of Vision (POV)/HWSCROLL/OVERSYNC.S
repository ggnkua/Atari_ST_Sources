******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	YES

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC

****

*** OVERSCAN + HARDWARE SCROLLING
***		( 460 * 264 screen )
*** 		230 bytes per scanline
***		60720 bytes per screen
****


	move.b	#8,$fffffc02
	move.b	#$12,$fffffc02

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.b	$ffff8260,oldrez
	clr.b	$ffff8260

	movem.l	$ffff8240,d0-d7
	movem.l	d0-d7,oldpal
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp

	move.l	d0,oldscr

	move.l	#scr,d0
	addi.l	#256,d0
	andi.l	#$ffffff00,d0
	move.l	d0,screen
	move.l	d0,phy
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	add.l	#1696,screen

	move.l	screen,a0
	add.l	#130*230,a0	

	move.l	#pic+34,a1
	move.l	#199,d0
sloop	rept	20
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	endr

	lea	70(a0),a0
	dbf	d0,sloop

	move.w	#$2700,sr

	lea	$fffffa00,a0
	movep.w	7(a0),d0
	move.w	d0,mfp1
	movep.w	$13(a0),d0
	move.w	d0,mfp2
	move.w	#$0000,d0
	movep.w	d0,7(a0)

fl1	move.b	$fffffc02,d0
	btst	#0,$fffffc00
	bne	fl1

	move.l	$70,oldvbi
	move.l	$68,oldhbi
	move.l	#vbi,$70

	move.w	#$2300,sr
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240

loop	rept	12
	nop
	endr
	cmpi.b	#$39,$fffffc02
	bne	loop

	lea	$fffffa00,a0
	move.w	mfp1,d0
	movep.w	d0,7(a0)
	move.w	mfp2,d0
	movep.w	d0,$13(a0)
	move.l	oldvbi,$70
	move.l	oldhbi,$68

fl2	move.b	$fffffc02,d0
	btst	#0,$fffffc00
	bne	fl2

	move.w	#$777,$ffff8240
	move.b	#8,$fffffc02

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

	move.b	oldrez,$ffff8260

	move.w	#-1,-(sp)
	move.l	oldscr,-(sp)
	move.l	oldscr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240

	clr.w	-(sp)
	trap	#1

vbi	move.b	#0,$ffff8260
	move.l	#hbi,$68.w
	move	#33,hbi_cnt
	move	#$2100,sr
	move	#$2100,(sp)
	rte

hbi_cnt	dc.w	0

hbi	subq	#1,hbi_cnt
	beq	do_bords
	rte

do_bords
	move.l	#do_bord2,$68.w
	stop	#$2100
do_bord2
	move	#$2700,sr
	addq	#6,sp

hwstabp	lea	hwstab+2,a2
	lea	togl_ads,a3
	pea	return
	rept	7
	move	(a2)+,d2
	move.l	(a3,d2),-(sp)
	endr

	dcb.w	12,$4e71
	move.b	#0,$ffff820a.w	;TOP BORDER
	dcb.w	17,$4e71
	move.b	#2,$ffff820a.w
	move	#$8209,a0
	move	#$8260,a1	;8260

	move	#15,d1
bord_2	move.b	(a0),d0
	and	d1,d0
	beq.s	bord_2
	sub	d0,d1
	lsl	d1,d0
	dcb.w	88,$4e71
	moveq	#0,d0
	moveq	#2,d1
	lea	1(a0),a0
	rts

return	
	move.b	d1,(a1)
	dcb.w	2,$4e71
	move.b	d0,(a1)
	dcb.w	89,$4e71
	move.b	d0,(a0)
	move.b	d1,(a0)
	dcb.w	12,$4e71
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	dcb.w	12,$4e71
	move.b	d1,(a1)
	dcb.w	2,$4e71
	move.b	d0,(a1)

	rept	76
	nop
	endr

	movem.l	pic+2,d0-d7		set palette
	movem.l	d0-d7,$ffff8240.w
	moveq	#0,d0
	moveq	#2,d1
	move.l	#201,d4
.lp3	nop
	move.b	d1,(a1)
	nop
	nop
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	13
	nop
	endr

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	7
	nop
	endr
	dbf	d4,.lp3

	move.b	d1,(a1)	;Bottom bit
	moveq	#$d,d4
	nop
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	10
	nop
	endr
	move.b	d0,(a0)
	nop
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	11
	nop
	endr
	move.b	d1,(a1)
	move.b	d1,(a0)
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	13
	nop
	endr
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	10
	nop
	endr
.lp4	nop
	move.b	d1,(a1)
	nop
	nop
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	13
	nop
	endr
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	7
	nop
	endr
	dbf	d4,.lp4
	move.b	d1,(a1)
	moveq	#$21,d4
	nop
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)	
	move.b	d1,(a0)
	rept	10
	nop
	endr
	move.b	d0,(a0)
	nop
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	11
	nop
	endr
	move.b	d1,(a1)
	move.b	d1,(a0)
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	13
	nop
	endr
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	10
	nop
	endr
.lp5	nop
	move.b	d1,(a1)
	nop
	nop
	move.b	d0,(a1)
	rept	89
	nop
	endr
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	13
	nop
	endr
	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	rept	7
	nop
	endr
	dbf	d4,.lp5
;end
	move	#$8240,a2
	rept	8
	clr.l	(a2)+
	endr

	move.l	alt,d0
	add.l	d0,phy

	lea	hwstab(pc),a2
	move.l	phy(pc),d2
	move	d2,d3
	lsr.l	#8,d2
	and	#254,d3
	lsl	#3,d3
	lea	(a2,d3),a2
	add	(a2)+,d2
	move.l	a2,hwstabp+2
	move	#$8201,a2
	movep	d2,(a2)

	move.w	#$2300,(sp)
	rte

hwstab	incbin	hws7_wrd.dat

togl_ads
	dc.l	none,right,left,both,ntog1,ntog2

phy	dc.l	0

alt	dc.l	230	;offset to screen address

***** HARDWARE-SCROLL TOGGLES *****

none	dcb.w	124,$4e71
	rts

;	------------------------

right	dcb.w	95,$4e71

	move.b	d0,(a0)

	move.b	d1,(a0)

	dcb.w	12,$4e71

	move.b	d1,(a1)

	nop

	move.b	d0,(a1)

	dcb.w	8,$4e71

	rts

;	------------------------

left	move.b	d1,(a1)

	dcb.w	2,$4e71

	move.b	d0,(a1)

	dcb.w	88,$4e71

	move.b	d0,(a0)

	move.b	d1,(a0)

	dcb.w	13,$4e71

	move.b	d1,(a1)

	nop

	move.b	d0,(a1)

	dcb.w	8,$4e71

	rts

;	------------------------

both	move.b	d1,(a1)

	dcb.w	2,$4e71

	move.b	d0,(a1)

	dcb.w	89,$4e71

	move.b	d0,(a0)

	move.b	d1,(a0)

	dcb.w	12,$4e71

	move.b	d1,(a1)

	nop

	move.b	d0,(a1)

	dcb.w	8,$4e71

	rts

;	------------------------

ntog1	move.b	d1,(a1)

	dcb.w	2,$4e71

	move.b	d0,(a1)

	dcb.w	20,$4e71

	move.b	d1,(a1)

	dcb.w	18,$4e71

	move.b	d0,(a1)

	dcb.w	46,$4e71

	move.b	d0,(a0)

	move.b	d1,(a0)

	dcb.w	12,$4e71

	move.b	d1,(a1)

	nop

	move.b	d0,(a1)

	dcb.w	9,$4e71

	rts

;	------------------------

ntog2	dcb.w	26,$4e71

	move.b	d1,(a1)

	dcb.w	18,$4e71

	move.b	d0,(a1)

	dcb.w	46,$4e71

	move.b	d0,(a0)

	move.b	d1,(a0)

	dcb.w	12,$4e71

	move.b	d1,(a1)

	nop

	move.b	d0,(a1)

	dcb.w	9,$4e71

	rts

;	------------------------

	





	

screen	dc.l	0

oldscr	dc.l	0

oldrez	dc.w	0

mfp1	dc.w	0

mfp2	dc.w	0

oldhbi	ds.l	1

oldvbi	ds.l	1

oldpal	ds.w	16

black	ds.w	16



pic	incbin	h:\pics\oz\grn_man.pi1

	





scr	ds.b	60720+256	;Total Overscan screen memory

	


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
