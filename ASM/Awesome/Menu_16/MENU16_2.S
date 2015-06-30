; Awesome Menu 16 - Ripped by ??
; ------------------------------
;
; Stupid sod left the labels in, so what do you expect !!
;
; It still crashes when you press a key !!
;
; In case you're wondering what the occasional flickering is ... it is due
; to some bad vsync timing in the overscan routine.  What happens is that
; the monitor is switched to 70Hz for the scroller and not timed properly !
;
; Shoddy Workmanship = Ruthless ........ I'll leave that decision to you !


	text
begin
	movea.l	4(a7),a5
	lea	stack,a7
	move.l	12(a5),d0
	addi.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move.l	#$4a0000,-(a7)
	trap	#1
	lea	12(a7),a7

	clr.l	-(a7)		; into supervisor
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldsp

	move.w	$ffff8260.w,oldres	; store current resolution
	move.l	$44e.w,oldscr	; store current screen

	move.w	#0,-(a7)		; low resolution
	move.l	#$ffffffff,-(a7)
	move.l	#$ffffffff,-(a7)
	move.w	#5,-(a7)
	trap	#$e
	lea	12(a7),a7

	movem.l	$ffff8240.w,d0-d7	; store palette
	movem.l	d0-d7,oldpal

	jsr	democode		; run menu code

;
; When you press a key, it comes back here !
;
	move.b	#7,$484.w		; come back bell, all is forgiven

	move.w	oldres,-(a7)	; restore original screen
	move.l	oldscr,-(a7)
	move.l	oldscr,-(a7)
	move.w	#5,-(a7)
	trap	#$e
	lea	12(a7),a7

	movem.l	oldpal,d0-d7	; restore palette
	movem.l	d0-d7,$ffff8240.w

	move.l	oldsp,-(a7)	; user mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	file,d0		; file number pressed
	moveq	#0,d1
	move.w	d0,d1
	subq.w	#1,d1
	lsl.w	#2,d1		; multiply by 8
	lea	names,a0		; start of file-table in a0
	adda.l	d1,a0		; filename is (a0+d1*8)
	movea.l	(a0),a6

	pea	env		; p_exec the filename
	pea	env
	move.l	a6,-(a7)
	move.l	#$4b0000,-(a7)
	trap	#1
	lea	16(a7),a7

	clr.l	-(a7)		; and quit
	trap	#1

democode	movea.l	a7,a0
	lea	stack,a7
	move.l	(a0),-(a7)
	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	#l004d,d0
	andi.l	#$ffffff00,d0
	move.l	d0,stack
	addi.l	#$b140,d0
	andi.l	#$ffffff00,d0
	move.l	d0,screen2

	moveq	#1,d0
	jsr	music

	lea	screens,a0
	move.w	#$1607,d7
clr_scr	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d7,clr_scr

	jsr	create

	lea	awes_logo,a0
	movea.l	stack,a1
	movea.l	screen2,a2
	move.w	#$293,d7
logo_rout	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d7,logo_rout

	jsr	dotext
	jsr	hblon

mloop	move.b	$469.w,d0
vsync1	cmp.b	$469.w,d0
	beq.s	vsync1
	move.l	stack,d0
	move.l	screen2,stack
	move.l	d0,screen2
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	jsr	scroller
	move.b	$fffffc02.w,d0
	tst.b	d0
	beq.s	mloop
	subi.b	#1,d0
	cmpi.b	#1,d0
	bge.s	max
	bra	mloop
max	cmpi.b	#5,d0
	ble.s	oknum
	bra	mloop
oknum	move.b	d0,l0038

	jsr	hbloff

	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	movea.l	stack,a0
	move.w	#$1607,d7
clr_scr2	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d7,clr_scr2
	rts

hblon	move.w	#1,$4ee.w
	move.b	#$12,$fffffc02.w
	clr.b	$484.w
	lea	oldmfp,a0
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move	#$2700,sr
	move.l	#newvbl,$70.w
	move.l	#keyvec,$118.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	bset	#3,$fffffa17.w
	clr.b	$fffffa1b.w
	move	#$2300,sr
	rts

hbloff	move	#$2700,sr
	lea	oldmfp,a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa17.w
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move	#$2300,sr
l000b	btst	#0,$fffffc00.w
	beq.s	l000c
	move.b	$fffffc02.w,d0
	bra.s	l000b
l000c	move.b	#8,$fffffc02.w
	rts

newvbl	movem.l	a0-a6/d0-d7,-(a7)
	movem.l	logo_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$582,d0
l000e	dbf	d0,l000e
	clr.b	$ffff820a.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	#2,$ffff820a.w
	move	#$2700,sr
	move.w	#0,$ffff8240.w
	clr.b	$fffffa1b.w
	move.l	#hbl1,$120.w
	move.b	#$c0,$fffffa21.w
	move.b	#8,$fffffa1b.w
l000f	move.b	$ff8209.l,d0
	beq.s	l000f
	andi.w	#$3f,d0
	moveq	#$3f,d1
	sub.w	d0,d1
	lsl.w	d1,d0
	movea.l	palpos,a3

	rept	50
	nop
	endr

	lea	$ff8240.l,a0
	move.w	#$b8,d2
l0010	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	move.w	(a3)+,(a0)
	lea	718(a3),a3
	dbf	d2,l0010

	move.w	#0,(a0)
	addq.l	#4,palpos
	cmpi.l	#l004f,palpos
	blt.s	l0011
	move.l	#pal2,palpos
l0011	move	#$2300,sr
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	oldmfp,-(a7)
	rts

keyvec	move	#$2500,sr
	move.w	d0,-(a7)
	move.b	$fffffc00.w,d0
	btst	#7,d0
	beq.s	l0013
	move.b	$fffffc02.w,keypress
l0013	bclr	#6,$fffffa11.w
	move.w	(a7)+,d0
	rte

hbl1	movem.l	a0-a6/d0-d7,-(a7)
	move	#$2700,sr
	clr.b	$fffffa1b.w
	lea	blend,a6
	move.l	(a6)+,$ffff8240.w
	lea	$ff8209.l,a0
l0015	move.b	(a0),d0
	beq.s	l0015
	andi.w	#$3f,d0
	moveq	#$3f,d1
	sub.w	d0,d1
	lsl.w	d1,d0
	lea	$ffff8260.w,a0
	lea	$ffff820a.w,a1
	moveq	#0,d0
	moveq	#2,d1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.l	#$f,d2
l0016	move.b	d1,(a0)
	nop
	move.b	d0,(a0)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d0,(a1)
	move.b	d1,(a1)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d1,(a0)
	nop
	move.b	d0,(a0)
	nop
	nop
	nop
	nop
	nop
	move.l	(a6)+,$ffff8240.w
	dbf	d2,l0016
	lea	$ffff8240.w,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	jsr	music+34
	movem.l	(a7)+,a0-a6/d0-d7
	move	#$2300,sr
	bclr	#0,$fffffa0f.w
	rte

blend	dc.w	1,$111,2,$222,3,$333,4,$444,5,$555,6,$666,7,$777,7,$777
	dc.w	7,$777,7,$777,6,$666,5,$555,4,$444,3,$333,2,$222,1,$111
dotext	lea	text,a0
	movea.l	stack,a1
	lea	10560(a1),a1
	movea.l	screen2,a2
	lea	10560(a2),a2
l0019	movea.l	a1,a3
	movea.l	a2,a4
	move.w	#$13,d7
l001a	moveq	#0,d0
	move.b	(a0)+,d0
	subi.b	#$20,d0
	lsl.l	#5,d0
	lea	font,a5
	adda.l	d0,a5
	move.w	(a5),0(a3)
	move.w	(a5)+,0(a4)
	move.w	(a5),160(a3)
	move.w	(a5)+,160(a4)
	move.w	(a5),320(a3)
	move.w	(a5)+,320(a4)
	move.w	(a5),480(a3)
	move.w	(a5)+,480(a4)
	move.w	(a5),640(a3)
	move.w	(a5)+,640(a4)
	move.w	(a5),800(a3)
	move.w	(a5)+,800(a4)
	move.w	(a5),960(a3)
	move.w	(a5)+,960(a4)
	move.w	(a5),1120(a3)
	move.w	(a5)+,1120(a4)
	move.w	(a5),1280(a3)
	move.w	(a5)+,1280(a4)
	move.w	(a5),1440(a3)
	move.w	(a5)+,1440(a4)
	move.w	(a5),1600(a3)
	move.w	(a5)+,1600(a4)
	move.w	(a5),1760(a3)
	move.w	(a5)+,1760(a4)
	move.w	(a5),1920(a3)
	move.w	(a5)+,1920(a4)
	move.w	(a5),2080(a3)
	move.w	(a5)+,2080(a4)
	move.w	(a5),2240(a3)
	move.w	(a5)+,2240(a4)
	move.w	(a5),2400(a3)
	move.w	(a5)+,2400(a4)
	addq.l	#8,a3
	addq.l	#8,a4
	dbf	d7,l001a
	cmpi.b	#0,(a0)
	beq.s	l001b
	lea	2720(a1),a1
	lea	2720(a2),a2
	bra	l0019
l001b	rts

text	dc.b	' COMPACT MENU NO.16 '
	dc.b	' ------------------ '
	dc.b	'1.WILD WHEELS       '
	dc.b	'2.MEAN MACHINE      '
	dc.b	'3.HEAD OVER HEELS   '
	dc.b	'4.SERENDIPITY       '
	dc.b	'5.MEDWAY PROTECTOR 4'
	dc.b	0,0
create	lea	wave,a5
	lea	cols,a1
	lea	pal2,a4
	move.w	#$18f,d7
l001e	moveq	#$a,d6
	movea.l	a1,a3
	movea.l	a5,a0
l001f	movea.l	a4,a2
	moveq	#0,d0
	move.w	(a0)+,d0
	lsr.w	#1,d0
	muls	#$320,d0
	adda.l	d0,a2
	adda.l	#$40,a0
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	move.w	(a3),(a2)
	move.w	(a3)+,800(a2)
	adda.l	#$640,a2
	dbf	d6,l001f
	adda.l	#8,a5
	addq.l	#2,a4
	cmpa.l	#wave2,a5
	blt.s	l0020
	lea	wave,a5
l0020	dbf	d7,l001e
	rts

wave	dc.w	$a0,$a0,$a2,$a4,$a4,$a6,$a8,$a8,$aa,$ac,$ac,$ae,$b0,$b2,$b2,$b4,$b6,$b6,$b8,$ba
	dc.w	$ba,$bc,$be,$be,$c0,$c2,$c2,$c4,$c6,$c8,$c8,$ca,$cc,$cc,$ce,$d0,$d0,$d2,$d4,$d4
	dc.w	$d6,$d8,$d8,$da,$da,$dc,$de,$de,$e0,$e2,$e2,$e4,$e6,$e6,$e8,$e8,$ea,$ec,$ec,$ee
	dc.w	$f0,$f0,$f2,$f2,$f4,$f4,$f6,$f8,$f8,$fa,$fa,$fc,$fe,$fe,$100,$100,$102,$102,$104,$104
	dc.w	$106,$106,$108,$10a,$10a,$10c,$10c,$10e,$10e,$110,$110,$112,$112,$114,$114,$114,$116,$116,$118,$118
	dc.w	$11a,$11a,$11c,$11c,$11e,$11e,$11e,$120,$120,$122,$122,$122,$124,$124,$126,$126,$126,$128,$128,$128
	dc.w	$12a,$12a,$12a,$12c,$12c,$12c,$12e,$12e,$12e,$130,$130,$130,$132,$132,$132,$132,$134,$134,$134,$134
	dc.w	$136,$136,$136,$136,$138,$138,$138,$138,$138,$13a,$13a,$13a,$13a,$13a,$13a,$13c,$13c,$13c,$13c,$13c
	dc.w	$13c,$13c,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e
	dc.w	$140,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13c
	dc.w	$13c,$13c,$13c,$13c,$13c,$13c,$13a,$13a,$13a,$13a,$13a,$13a,$138,$138,$138,$138,$138,$136,$136,$136
	dc.w	$136,$134,$134,$134,$134,$132,$132,$132,$132,$130,$130,$130,$12e,$12e,$12e,$12c,$12c,$12c,$12a,$12a
	dc.w	$12a,$128,$128,$128,$126,$126,$126,$124,$124,$122,$122,$122,$120,$120,$11e,$11e,$11e,$11c,$11c,$11a
	dc.w	$11a,$118,$118,$116,$116,$114,$114,$114,$112,$112,$110,$110,$10e,$10e,$10c,$10c,$10a,$10a,$108,$106
	dc.w	$106,$104,$104,$102,$102,$100,$100,$fe,$fe,$fc,$fa,$fa,$f8,$f8,$f6,$f4,$f4,$f2,$f2,$f0
	dc.w	$f0,$ee,$ec,$ec,$ea,$e8,$e8,$e6,$e6,$e4,$e2,$e2,$e0,$de,$de,$dc,$da,$da,$d8,$d8
	dc.w	$d6,$d4,$d4,$d2,$d0,$d0,$ce,$cc,$cc,$ca,$c8,$c8,$c6,$c4,$c2,$c2,$c0,$be,$be,$bc
	dc.w	$ba,$ba,$b8,$b6,$b6,$b4,$b2,$b2,$b0,$ae,$ac,$ac,$aa,$a8,$a8,$a6,$a4,$a4,$a2,$a0
	dc.w	$a0,$9e,$9c,$9a,$9a,$98,$96,$96,$94,$92,$92,$90,$8e,$8c,$8c,$8a,$88,$88,$86,$84
	dc.w	$84,$82,$80,$80,$7e,$7c,$7c,$7a,$78,$76,$76,$74,$72,$72,$70,$6e,$6e,$6c,$6a,$6a
	dc.w	$68,$66,$66,$64,$64,$62,$60,$60,$5e,$5c,$5c,$5a,$58,$58,$56,$56,$54,$52,$52,$50
	dc.w	$4e,$4e,$4c,$4c,$4a,$4a,$48,$46,$46,$44,$44,$42,$40,$40,$3e,$3e,$3c,$3c,$3a,$3a
	dc.w	$38,$38,$36,$34,$34,$32,$32,$30,$30,$2e,$2e,$2c,$2c,$2a,$2a,$2a,$28,$28,$26,$26
	dc.w	$24,$24,$22,$22,$20,$20,$20,$1e,$1e,$1c,$1c,$1c,$1a,$1a,$18,$18,$18,$16,$16,$16
	dc.w	$14,$14,$14,$12,$12,$12,$10,$10,$10,$e,$e,$e,$c,$c,$c,$c,$a,$a,$a,$a
	dc.w	8,8,8,8,6,6,6,6,6,4,4,4,4,4,4,2,2,2,2,2
	dc.w	2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
	dc.w	2,2,2,2,2,2,4,4,4,4,4,4,6,6,6,6,6,8,8,8
	dc.w	8,$a,$a,$a,$a,$c,$c,$c,$c,$e,$e,$e,$10,$10,$10,$12,$12,$12,$14,$14
	dc.w	$14,$16,$16,$16,$18,$18,$18,$1a,$1a,$1c,$1c,$1c,$1e,$1e,$20,$20,$20,$22,$22,$24
	dc.w	$24,$26,$26,$28,$28,$2a,$2a,$2a,$2c,$2c,$2e,$2e,$30,$30,$32,$32,$34,$34,$36,$38
	dc.w	$38,$3a,$3a,$3c,$3c,$3e,$3e,$40,$40,$42,$44,$44,$46,$46,$48,$4a,$4a,$4c,$4c,$4e
	dc.w	$4e,$50,$52,$52,$54,$56,$56,$58,$58,$5a,$5c,$5c,$5e,$60,$60,$62,$64,$64,$66,$66
	dc.w	$68,$6a,$6a,$6c,$6e,$6e,$70,$72,$72,$74,$76,$76,$78,$7a,$7c,$7c,$7e,$80,$80,$82
	dc.w	$84,$84,$86,$88,$88,$8a,$8c,$8c,$8e,$90,$92,$92,$94,$96,$96,$98,$9a,$9a,$9c,$9e
wave2	dc.w	$a0,$a0,$a2,$a4,$a4,$a6,$a8,$a8,$aa,$ac,$ac,$ae,$b0,$b2,$b2,$b4,$b6,$b6,$b8,$ba
	dc.w	$ba,$bc,$be,$be,$c0,$c2,$c2,$c4,$c6,$c8,$c8,$ca,$cc,$cc,$ce,$d0,$d0,$d2,$d4,$d4
	dc.w	$d6,$d8,$d8,$da,$da,$dc,$de,$de,$e0,$e2,$e2,$e4,$e6,$e6,$e8,$e8,$ea,$ec,$ec,$ee
	dc.w	$f0,$f0,$f2,$f2,$f4,$f4,$f6,$f8,$f8,$fa,$fa,$fc,$fe,$fe,$100,$100,$102,$102,$104,$104
	dc.w	$106,$106,$108,$10a,$10a,$10c,$10c,$10e,$10e,$110,$110,$112,$112,$114,$114,$114,$116,$116,$118,$118
	dc.w	$11a,$11a,$11c,$11c,$11e,$11e,$11e,$120,$120,$122,$122,$122,$124,$124,$126,$126,$126,$128,$128,$128
	dc.w	$12a,$12a,$12a,$12c,$12c,$12c,$12e,$12e,$12e,$130,$130,$130,$132,$132,$132,$132,$134,$134,$134,$134
	dc.w	$136,$136,$136,$136,$138,$138,$138,$138,$138,$13a,$13a,$13a,$13a,$13a,$13a,$13c,$13c,$13c,$13c,$13c
	dc.w	$13c,$13c,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e
	dc.w	$140,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13e,$13c
	dc.w	$13c,$13c,$13c,$13c,$13c,$13c,$13a,$13a,$13a,$13a,$13a,$13a,$138,$138,$138,$138,$138,$136,$136,$136
	dc.w	$136,$134,$134,$134,$134,$132,$132,$132,$132,$130,$130,$130,$12e,$12e,$12e,$12c,$12c,$12c,$12a,$12a
	dc.w	$12a,$128,$128,$128,$126,$126,$126,$124,$124,$122,$122,$122,$120,$120,$11e,$11e,$11e,$11c,$11c,$11a
	dc.w	$11a,$118,$118,$116,$116,$114,$114,$114,$112,$112,$110,$110,$10e,$10e,$10c,$10c,$10a,$10a,$108,$106
	dc.w	$106,$104,$104,$102,$102,$100,$100,$fe,$fe,$fc,$fa,$fa,$f8,$f8,$f6,$f4,$f4,$f2,$f2,$f0
	dc.w	$f0,$ee,$ec,$ec,$ea,$e8,$e8,$e6,$e6,$e4,$e2,$e2,$e0,$de,$de,$dc,$da,$da,$d8,$d8
	dc.w	$d6,$d4,$d4,$d2,$d0,$d0,$ce,$cc,$cc,$ca,$c8,$c8,$c6,$c4,$c2,$c2,$c0,$be,$be,$bc
	dc.w	$ba,$ba,$b8,$b6,$b6,$b4,$b2,$b2,$b0,$ae,$ac,$ac,$aa,$a8,$a8,$a6,$a4,$a4,$a2,$a0
	dc.w	$a0,$9e,$9c,$9a,$9a,$98,$96,$96,$94,$92,$92,$90,$8e,$8c,$8c,$8a,$88,$88,$86,$84
	dc.w	$84,$82,$80,$80,$7e,$7c,$7c,$7a,$78,$76,$76,$74,$72,$72,$70,$6e,$6e,$6c,$6a,$6a
	dc.w	$68,$66,$66,$64,$64,$62,$60,$60,$5e,$5c,$5c,$5a,$58,$58,$56,$56,$54,$52,$52,$50
	dc.w	$4e,$4e,$4c,$4c,$4a,$4a,$48,$46,$46,$44,$44,$42,$40,$40,$3e,$3e,$3c,$3c,$3a,$3a
	dc.w	$38,$38,$36,$34,$34,$32,$32,$30,$30,$2e,$2e,$2c,$2c,$2a,$2a,$2a,$28,$28,$26,$26
	dc.w	$24,$24,$22,$22,$20,$20,$20,$1e,$1e,$1c,$1c,$1c,$1a,$1a,$18,$18,$18,$16,$16,$16
	dc.w	$14,$14,$14,$12,$12,$12,$10,$10,$10,$e,$e,$e,$c,$c,$c,$c,$a,$a,$a,$a
	dc.w	8,8,8,8,6,6,6,6,6,4,4,4,4,4,4,2,2,2,2,2
	dc.w	2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
	dc.w	2,2,2,2,2,2,4,4,4,4,4,4,6,6,6,6,6,8,8,8
	dc.w	8,$a,$a,$a,$a,$c,$c,$c,$c,$e,$e,$e,$10,$10,$10,$12,$12,$12,$14,$14
	dc.w	$14,$16,$16,$16,$18,$18,$18,$1a,$1a,$1c,$1c,$1c,$1e,$1e,$20,$20,$20,$22,$22,$24
	dc.w	$24,$26,$26,$28,$28,$2a,$2a,$2a,$2c,$2c,$2e,$2e,$30,$30,$32,$32,$34,$34,$36,$38
	dc.w	$38,$3a,$3a,$3c,$3c,$3e,$3e,$40,$40,$42,$44,$44,$46,$46,$48,$4a,$4a,$4c,$4c,$4e
	dc.w	$4e,$50,$52,$52,$54,$56,$56,$58,$58,$5a,$5c,$5c,$5e,$60,$60,$62,$64,$64,$66,$66
	dc.w	$68,$6a,$6a,$6c,$6e,$6e,$70,$72,$72,$74,$76,$76,$78,$7a,$7c,$7c,$7e,$80,$80,$82
	dc.w	$84,$84,$86,$88,$88,$8a,$8c,$8c,$8e,$90,$92,$92,$94,$96,$96,$98,$9a,$9a,$9c,$9e
cols	dc.w	$100,$201,$302,$403,$504,$605,$706,$706,$605,$504,$403,$302,$201,$100,1,2,$103,$204,$305,$406
	dc.w	$507,$507,$406,$305,$204,$103,2,1,1,2,3,4,5,6,7,7,6,5,4,3
	dc.w	2,1,1,2,$13,$24,$35,$46,$57,$57,$46,$35,$24,$13,2,1,$10,$21,$32,$43
	dc.w	$54,$65,$76,$76,$65,$54,$43,$32,$21,$10,$10,$20,$30,$41,$52,$63,$74,$74,$63,$52
	dc.w	$41,$30,$20,$10,$10,$20,$30,$40,$50,$60,$70,$70,$60,$50,$40,$30,$20,$10,0,$10
	dc.w	$120,$230,$340,$450,$560,$560,$450,$340,$230,$120,$10,0,$100,$210,$320,$430,$540,$650,$760,$760
	dc.w	$650,$540,$430,$320,$210,$100,$100,$200,$300,$410,$520,$630,$740,$740,$630,$520,$410,$300,$200,$100
	dc.w	$100,$200,$300,$400,$500,$600,$700,$700,$600,$500,$400,$300,$200,$100
palpos	dc.l	pal2
scroller	cmpi.w	#$f,ccnt
	blt.s	notnew
	jsr	newchar
notnew	lea	charbuf,a3
	move.w	#1,d6
sloop	movea.l	a3,a0
	lea	scrolbuf,a1
	addq.w	#1,ccnt
	move.w	#$f,d7
scrolloo	lsl	(a0)+
	roxl	216(a1)
	roxl	208(a1)
	roxl	200(a1)
	roxl	192(a1)
	roxl	184(a1)
	roxl	176(a1)
	roxl	168(a1)
	roxl	160(a1)
	roxl	152(a1)
	roxl	144(a1)
	roxl	136(a1)
	roxl	128(a1)
	roxl	120(a1)
	roxl	112(a1)
	roxl	104(a1)
	roxl	96(a1)
	roxl	88(a1)
	roxl	80(a1)
	roxl	72(a1)
	roxl	64(a1)
	roxl	56(a1)
	roxl	48(a1)
	roxl	40(a1)
	roxl	32(a1)
	roxl	24(a1)
	roxl	16(a1)
	roxl	8(a1)
	roxl	0(a1)
	lea	224(a1),a1
	dbf	d7,scrolloo
	dbf	d6,sloop
	lea	scrolbuf,a0
	movea.l	screen2,a1
	lea	30880(a1),a1
	move.w	#$f,d7
l0029	move.w	0(a0),0(a1)
	move.w	8(a0),8(a1)
	move.w	16(a0),16(a1)
	move.w	24(a0),24(a1)
	move.w	32(a0),32(a1)
	move.w	40(a0),40(a1)
	move.w	48(a0),48(a1)
	move.w	56(a0),56(a1)
	move.w	64(a0),64(a1)
	move.w	72(a0),72(a1)
	move.w	80(a0),80(a1)
	move.w	88(a0),88(a1)
	move.w	96(a0),96(a1)
	move.w	104(a0),104(a1)
	move.w	112(a0),112(a1)
	move.w	120(a0),120(a1)
	move.w	128(a0),128(a1)
	move.w	136(a0),136(a1)
	move.w	144(a0),144(a1)
	move.w	152(a0),152(a1)
	move.w	160(a0),160(a1)
	move.w	168(a0),168(a1)
	move.w	176(a0),176(a1)
	move.w	184(a0),184(a1)
	move.w	192(a0),192(a1)
	move.w	200(a0),200(a1)
	move.w	208(a0),208(a1)
	move.w	216(a0),216(a1)
	lea	224(a0),a0
	lea	230(a1),a1
	dbf	d7,l0029
	rts

newchar	moveq	#0,d0
	movea.l	mpos,a0
	move.b	(a0)+,d0
	cmpi.b	#0,(a0)
	bne.s	notend
	movea.l	#message,a0
notend	move.l	a0,mpos
	clr.w	ccnt
	lea	font,a0
	lea	charbuf,a1
	subi.w	#$20,d0
	lsl.w	#5,d0
	adda.w	d0,a0
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	rts

mpos	dc.l	message
message	dc.b	"   WELCOME TO THIS DISK WHICH HOLDS THE "
	dc.b	"TITLE OF AWESOME MENU 16!   YOUR HOST FO"
	dc.b	"R THIS FULL OVERSCAN MENU IS RUTHLESS.  "
	dc.b	"  I WOULD LIKE TO DEDICATE THIS MUSIC TO"
	dc.b	" QUEERTRO OF COCKUP ORGASM, HEY THAT'S W"
	dc.b	"RONG, LET ME GET MY C.O. DICTIONARY...  "
	dc.b	"  AHA, SORRY IT IS ACTUALLY SUPPOSED TO "
	dc.b	"READ AS...  I WOULD LIKE TO DEDICATE THI"
	dc.b	"S MENU TO QUATTRO OF CLOCKWORK ORANGE BE"
	dc.b	"CAUSE HE KEEPS ON ASKING ME TO SEND HIM "
	dc.b	"SOME LAP MUSIC - WON'T YOUR 'ULTIMATE RI"
	dc.b	"PPER' HARDWARE CARTRIDGE LET YOU RIP IT "
	dc.b	"WITH IT'S BUILT IN MUSIC RIPPER, WHAT'S "
	dc.b	"THAT YOU DON'T KNOW HOW TO USE IT.   OH "
	dc.b	"DEAR, WELL JUST TO MAKE YOU HAPPY I WILL"
	dc.b	" PUT SOME LAP MUSIC FILES ON THE NEXT ME"
	dc.b	"NU (WITH REPLAY CODE OF COURSE, A BIT US"
	dc.b	"ELESS TO YOU OTHERWISE - DON'T YOU AGREE"
	dc.b	"!!!).  ONLY KIDDING QUATTRO.    OR WAS I"
	dc.b	"?   HO!  HO!  HO!      NOW ONTO THE MEMB"
	dc.b	"ERS OF AWESOME, I WOULD LIKE TO TAKE THI"
	dc.b	"S OPPORTUNITY TO LET ZELDA KNOW THAT AS "
	dc.b	"FROM THIS MENU HE IS NO LONGER A MEMBER "
	dc.b	"OF AWESOME.  DON'T TAKE IT PERSONALLY, 3"
	dc.b	" OTHERS WILL BE KICKED OUT SOON AS WELL!"
	dc.b	"    A BIG WELCOME TO OUR NEW MEMBER WHO "
	dc.b	"WILL BE GOING UNDER THE NAME OF 'DOMINIO"
	dc.b	"N'  HE IS A VERY GOOD CRACKER, CODER, FI"
	dc.b	"LER AND PACKER.   YOU CAN EXPECT TO SEE "
	dc.b	"LOTS OF HIS WORK ON FUTURE AWESOME MENUS"
	dc.b	"!!!   HE IS THE GUY WHO CODED THE POMPEY"
	dc.b	" PIRATES THE FULL SCREEN INTRO ON THEIR "
	dc.b	"MENU 88 AND THE CONTROLABLE SPACESHIP ON"
	dc.b	" THEIR MENU 91.   TECHNO WILL BE LEAVING"
	dc.b	" THE CREW OF HIS OWN ACCORD TOWARDS THE "
	dc.b	"END OF THE YEAR AND HE WILL BE GREATLY M"
	dc.b	"ISSED!     MEMBERS OF AWESOME NOW ARE:- "
	dc.b	" RUTHLESS, FROSTY, K-KLASS, DOMINION, TE"
	dc.b	"CHNO, THE BALD EAGLE, JOLLY ROGER, THE E"
	dc.b	"DITMAN, ONIXUS AND PHOENIX...    NOW YOU"
	dc.b	"R CHANCE TO JOIN ONE OF THE WORLDS BIGGE"
	dc.b	"ST CREWS...  YES, HERE IS YOUR CHANCE TO"
	dc.b	" JOIN AWESOME.  IF YOU CAN CRACK, FILE, "
	dc.b	"CODE, OWN A MODEM OR YOU FEEL YOU DO SOM"
	dc.b	"ETHING ELSE WHICH WOULD BE USEFUL TO US,"
	dc.b	" THEN PLEASE CONTACT US, DO NOT WRITE TO"
	dc.b	" OUR P.O. BOX IN ICELAND BUT WAIT FOR TH"
	dc.b	"E BRITISH P.O. BOX ADDRESS COMING SOON O"
	dc.b	"N A NEW AWESOME MENU!          CREDITS F"
	dc.b	"OR THIS MENU GOTO... CODING BY:- ECSTASY"
	dc.b	" OF THE REPLICANTS, G.F.X BY:- MAGNUM OF"
	dc.b	" TWB, AND MUSIC BY:- LAP....     RIGHT D"
	dc.b	"UDES, VERY QUICK 'WORD TO THE MOTHER' GR"
	dc.b	"EETS GOTO...   THE REST OF AWESOME, THE "
	dc.b	"REPLICANTS (CAMEO, COBRA, SNAKE, ECSTASY"
	dc.b	" AND ALL THE OTHERS), THE SYNDICATE - OU"
	dc.b	"R PARTNERS IN CRIME (FLOSSY AND BEAST, P"
	dc.b	"LEASE CALL ME FLOSSY!), THE REST OF E.S."
	dc.b	"C. (T.S.B. ESP. ZINE, I AM GLAD YOU ARE "
	dc.b	"BACK!), FUZION (KELLY-X, DOCNO AND DRAGO"
	dc.b	"N), THE SYNIX, HAL, EGB, MAGNUM, THE POM"
	dc.b	"PEY PIRATES (GENIE, YUM-YUM, PACMAN, LIT"
	dc.b	"TLE LULU AND MY NEW CONTACT SPARKY - NIC"
	dc.b	"E TALKING TO YOU DUDE!), SUPERIOR (WANDE"
	dc.b	"RER AND AXE), GRIFF, GINO, FACTORY (HIGH"
	dc.b	"LANDER AND SPY 3), LYNX (HEADHUNTER), N."
	dc.b	"P.G. (TGA), ORION (SPIFF), UNTOUCHABLES "
	dc.b	"(MATT AND TONY), QUATTRO, RIP (TITANIC T"
	dc.b	"ARZAN - WHAT HAS HAPPENED TO THE LETTERS"
	dc.b	"?), ELECTRONIC, PROWLER, THE SOURCE (KAL"
	dc.b	"AMAZOO AND MUG), EVIL FORCE (JASON ELITE"
	dc.b	"), THE RADICAL BANDITS (T H E  R U D E  "
	dc.b	"D U D E AND HIS SUPPLIER), FUTUR MINDS ("
	dc.b	"SKYLINE), THE AVENGER, BLOODANGEL, PEDRO"
	dc.b	", NOW 5 (FALCON), ANGELS OF MERCY (BUT E"
	dc.b	"SPECIALLY KIM), THE FOX, TEDDY, GEORGE, "
	dc.b	"NEW PIRATES, IMAGINA, EVOLOUTION (MONSTE"
	dc.b	"R BEETLE - HOPE YOU LIKE YOUR INTRO), TH"
	dc.b	"E P.H.F. CODERS FORM HULL (CODING FOR FU"
	dc.b	"N), ROBERTO FROM ITALY, H.A.C. (DOCTOR B"
	dc.b	"YTE), V MAX (THANX FOR GREET), JOBIL, NE"
	dc.b	"XT, STUART, JOKER AND TO ALL OTHERS THAT"
	dc.b	" I HAVE FORGOTTEN...   NO TIME FOR ANYMO"
	dc.b	"RE BULLSHIT SO UNTIL THE NEXT SAGA OF TH"
	dc.b	"E 'HOTEST SOFTWARE AROUND' RUTHLESS SUMM"
	dc.b	"ONS A WRAP.     LET'S WRAP DUDES!       "
	dc.b	'                  ',0,0
	dc.l	font
ccnt	dc.b	0,$19,0,0
charbuf	dcb.w	48
scrolbuf	dcb.w	2048

	data

music	incbin	'menu16.lap'
	even

picture	incbin	'awesome.pi1'
	even

logo_pal	equ	picture+2
awes_logo	equ	picture+34

font	incbin	'menu16.fon'
	even

env	dcb.w	2
file	dc.b	0
l0038	dc.b	0
names	dc.l	file1
	dc.l	file2
	dc.l	file3
	dc.l	file4
	dc.l	file5
	dc.l	file6
	dc.l	file7
	dc.l	file8
	dc.l	file9
file1	dc.b	'word.up'
file2	dc.b	'wheely.up'
file3	dc.b	'click'
file4	dc.b	'click'
file5	dc.b	'puke.up'
file6	dc.b	0
	dc.b	0
file7	dc.b	0
	dc.b	0
file8	dc.b	0
	dc.b	0
file9	dc.b	0
	dc.b	0
	bss
black	ds.b	32
keypress	ds.l	1
oldpal	ds.b	32
oldmfp	ds.b	32
oldsp	ds.l	1
oldscr	ds.l	1
oldres	ds.b	804
stack	ds.l	1
screen2	ds.l	1
screens	ds.b	256
l004d	ds.b	90240
pal2	ds.b	358
l004f	ds.b	204442
zuend	end
