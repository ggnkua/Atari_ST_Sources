; picture of an icecream cone. 
;

IcePic.MEASURE_CPU:=	0
IcePic.NR_VBLS:=	1

;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	IcePic.mainloop
	dc.l	IcePic.init
	dc.l	IcePic.rt_init			; 2
	dc.l	IcePic.deinit
	dc.l	dummy				; 4
	dc.l	dummy				; 5
	dc.l	dummy				; 6
	dc.l	0

;- plugin routines ---------------------------------------------------------

IcePic.init:
	rts

IcePic.rt_init:
	rts

IcePic.deinit:
	rts

IcePic.mainloop:
	ifne	IcePic.MEASURE_CPU
	ifeq	testmode
	move.w	#$0400,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	sub.l	lastfrmcnt,d0
	subq.l	#2,d0
	bge.s	.clear_done
	lea	IcePic.pic+34,a1
	movea.l	scr,a0
	jsr	copy_stscreen
.clear_done:

	ifne	IcePic.MEASURE_CPU
	ifeq	testmode
	move.w	#$0600,$FFFF8240.w
	endc
	endc

	ifne	IcePic.MEASURE_CPU
	movea.l	scr,a0
	move.w	IcePic.measured_vbls,d0
	cmpi.w	#20,d0
	blo.s	.range_ok
	moveq	#20,d0
.range_ok:
	moveq	#-1,d1
	subq.w	#1,d0
	bmi.s	.end_paint_vbls
.paint_vbls_loop:
	movep.l	d1,(a0)
	addq	#8,a0
	dbf	d0,.paint_vbls_loop
.end_paint_vbls:
	clr.l	(a0)+
	clr.l	(a0)+
	endc

; swap screens..
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	ifeq	testmode
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	ifne	IcePic.MEASURE_CPU
	ifeq	testmode
	move.w	#$0000,$FFFF8240.w
	endc
	endc

	move.l	frmcnt,d0
	cmp.l	lastfrmcnt,d0
	bne.s	.end_pal
	move.l	#IcePic.init_pal,palirq
.end_pal:

; wait for vbl..
	move.w	IcePic.old_468(pc),d0
.vbl:	move.w	$0468.w,d1
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#IcePic.NR_VBLS,d1
	bcs.s	.vbl
	move.w	d2,IcePic.old_468
	move.w	d1,IcePic.measured_vbls
	rts

IcePic.measured_vbls:
	ds.w	1
IcePic.old_468:
	ds.w	1

;- event routines ----------------------------------------------------------


;- sub routines ------------------------------------------------------------

IcePic.init_pal:
	movem.l	IcePic.pic+2,d0-d7
	movem.l	d0-d7,$FFFF8240.w
	rts

;- data section ------------------------------------------------------------

	data

IcePic.pic:
	incbin	icey5.pi1

;- bss section -------------------------------------------------------------

	bss

