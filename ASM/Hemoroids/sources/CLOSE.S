	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	a7,old_sp+2
	lea	new_sp(pc),a7
	clr.b	$ffff8260.w

	move.l	$44e.w,a0
	lea	-32000(a0),a0
	move.l	a0,d0
	lea	160(a0),a0
	move.l	a0,screen
	move	#273,d7

clear	rept	28
	move.l	#$ffff0000,(a0)+
	clr.l	(a0)+
	endr
	lea	6(a0),a0

	dbf	d7,clear

	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep	d0,(a0)

	move	#$2700,sr

	move.l	#$00000777,$ffff8240.w
	move.l	#$00000000,$ffff8244.w
	move.l	#$00000000,$ffff8248.w
	move.l	#$00000000,$ffff824c.w
	move.l	#$00000000,$ffff8250.w
	move.l	#$00000000,$ffff8254.w
	move.l	#$00000000,$ffff8258.w
	move.l	#$00000000,$ffff825c.w

	move.b	$fffffa15.w,imra+3
	clr.b	$fffffa15.w
	move.l	$68.w,old_hbl+2
	move.l	$70.w,old_vbl+2

	lea	new_hbl(pc),a0
	move.L	a0,$68.w
	lea	new_vbl(pc),a0
	move.l	a0,$70.w

	move	#$2300,sr

wait_key	cmpi.b	#$b9,$fffffc02.w
	bne.s	wait_key
exit
	move	#$2700,sr

imra	move.b	#0,$fffffa15.w
old_hbl	move.l	#0,$68.w
old_vbl	move.l	#0,$70.w
old_sp	move.l	#0,a7

	move	#$0777,$ffff8240.w

	move	#$2300,sr

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

	ds.l	128
new_sp
table	dc.w	$0000,$8000,$c000,$e000
	dc.w	$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0
	dc.w	$fff0,$fff8,$fffc,$fffe
	dc.w	$7fff,$3fff,$1fff,$0fff
	dc.w	$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f
	dc.w	$0007,$0003,$0001,$0000

new_hbl	lea	line_counter(pc),a6
	subq	#1,(a6)
	rte

new_vbl	move	#$2700,sr
	move.l	#$0,$ffff8240.w

	lea	line_counter(pc),a6
	move	#$22,(a6)
	move	#$2100,sr

	lea	screen(pc),a2
	move.l	(a2),a2
;	lea	160(a2),a2
	lea	absciss(pc),a1
	lea	table(pc),a3

	move	(a1),d0
	subq	#2,d0
	cmpi	#448,d0
	blo.s	.okk
	bra	exit
.okk	move	d0,(a1)+
	move	d0,d1
	andi	#$fff0,d0
	andi	#$000f,d1
	lsr	d0
	lsl	d1
	move.l	a2,a0
	adda	d0,a0
	move	(a3,d1.w),(a0)
	andi	#$7fff,8(a0)

	move	(a1),d0
	addq	#2,d0
	cmpi	#448,d0
	blo.s	.okk2
	move	#448,d0
.okk2	move	d0,(a1)+
	move	d0,d1
	andi	#$fff0,d0
	andi	#$000f,d1
	lsr	d0
	lsl	d1
	move.l	a2,a0
	adda	d0,a0
	move	32(a3,d1.w),(a0)
	andi	#$fffe,-8(a0)

	lea	230(a2),a2

	move	#30,d7
.bzzzzz	move	(a1),d0
	subq	#2,d0
	cmpi	#448,d0
	blo.s	.ok
	moveq	#0,d0
.ok	move	d0,(a1)+
	move	d0,d1
	andi	#$fff0,d0
	andi	#$000f,d1
	lsr	d0
	lsl	d1
	move.l	a2,a0
	adda	d0,a0
	move	(a3,d1.w),(a0)
	andi	#$7fff,8(a0)

	move	(a1),d0
	addq	#2,d0
	cmpi	#448,d0
	blo.s	.ok2
	move	#448,d0
.ok2	move	d0,(a1)+
	move	d0,d1
	andi	#$fff0,d0
	andi	#$000f,d1
	lsr	d0
	lsl	d1
	move.l	a2,a0
	adda	d0,a0
	move	32(a3,d1.w),(a0)
	andi	#$fffe,-8(a0)

	lea	230(a2),a2

	dbf	d7,.bzzzzz
	
;	move	#$700,$ffff8240.w

	lea	line_counter(pc),a6
.wait_for_beg	tst	(a6)
	bne.S	.wait_for_beg

	move	#$2700,sr

	lea	.restore_stack(pc),a0
	move.l	a7,2(a0)

	lea	$ffff820a.w,a7
	lea	$56(a7),a6
	lea	$36(a7),a5
	moveq	#0,d7
	moveq	#2,d6

	rept	70
	nop
	endr

	move.b	d7,(a7)
	rept	10
	nop
	endr
	move.b	d6,(a7)

.screen_begin	move.b	-1(a7),d0
	beq.s	.screen_begin

	neg	d0
	lsl.l	d0,d0

	rept	66
	nop
	endr

	move	#$777,2(a5)

	move	#112,d5

.full1	nop
	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move	(a1),d0	;8
	subq	#2,d0	;4
	cmpi	#448,d0	;8
	blo.s	.ok3	;8
	moveq	#0,d0	;4
	bra.s	.ok4	;12
.ok3	nop
	nop
	nop
.ok4	move	d0,(a1)+	;8
	move	d0,d1	;4
	andi	#$fff0,d0	;8
	andi	#$000f,d1	;8
	lsr	d0	;8
	lsl	d1	;8
	move.l	a2,a0	;4
	adda	d0,a0	;8
	move	(a3,d1.w),(a0)	;20
	andi	#$7fff,8(a0)	;20

	move	(a1),d0	;8
	addq	#2,d0	;4
	cmpi	#448,d0	;8
	blo.s	.ok5	;8
	move	#448,d0	;4
	bra.s	.ok6	;12
.ok5	nop
	nop
	nop
	nop
.ok6	move	d0,(a1)+	;8
	move	d0,d1	;4
	andi	#$fff0,d0	;8
	andi	#$000f,d1	;8
	lsr	d0	;8
	lsl	d1	;8
	move.l	a2,a0	;4
	adda	d0,a0	;8
	move	32(a3,d1.w),(a0)	;20
	andi	#$fffe,-8(a0)	;20

	lea	230(a2),a2	;8

	move	(a1),d0	;8
	subq	#2,d0	;4
	cmpi	#448,d0	;8
	blo.s	.ok7	;8
	moveq	#0,d0	;4
	bra.s	.ok8	;12
.ok7	nop
	nop
	nop
.ok8	move	d0,(a1)+	;8
	move	d0,d1	;4
	andi	#$fff0,d0	;8

	move.b	d7,(a7)
	move.b	d6,(a7)

	andi	#$000f,d1	;8
	lsr	d0	;8
	lsl	d1	;8
	move.l	a2,a0	;4
	adda	d0,a0	;8

	nop
	nop
	nop
	nop

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move	(a3,d1.w),(a0)	;20
	andi	#$7fff,8(a0)	;20
	nop
	nop

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move	(a1),d0	;8
	addq	#2,d0	;4
	cmpi	#448,d0	;8
	blo.s	.ok9	;8
	move	#448,d0	;8
	bra.s	.ok10	;12
.ok9	nop
	nop
	nop
	nop
.ok10	move	d0,(a1)+	;8
	move	d0,d1	;4
	andi	#$fff0,d0	;8
	andi	#$000f,d1	;8
	lsr	d0	;8
	lsl	d1	;8
	move.l	a2,a0	;4
	adda	d0,a0	;8
	move	32(a3,d1.w),(a0)	;20
	andi	#$fffe,-8(a0)	;20

	lea	230(a2),a2	;8

	rept	51
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	8
	nop
	endr

	dbf	d5,.full1

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	89
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	12
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	89
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move.b	d7,(a7)

	rept	10
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move.b	d6,(a7)
	move	#15,d5

	rept	85
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	11
	nop
	endr

.full2	nop
	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move	(a1),d0	;8
	subq	#2,d0	;4
	cmpi	#448,d0	;8
	blo.s	.ok11	;8
	moveq	#0,d0	;4
	bra.s	.ok12	;12
.ok11	nop
	nop
	nop
.ok12	move	d0,(a1)+	;8
	move	d0,d1	;4
	andi	#$fff0,d0	;8
	andi	#$000f,d1	;8
	lsr	d0	;8
	lsl	d1	;8
	move.l	a2,a0	;4
	adda	d0,a0	;8
	move	(a3,d1.w),(a0)	;20
	andi	#$7fff,8(a0)	;20

	move	(a1),d0	;8
	addq	#2,d0	;4
	cmpi	#448,d0	;8
	blo.s	.ok13	;8
	move	#448,d0	;4
	bra.s	.ok14	;12
.ok13	nop
	nop
	nop
	nop
.ok14	move	d0,(a1)+	;8
	move	d0,d1	;4
	andi	#$fff0,d0	;8
	andi	#$000f,d1	;8
	lsr	d0	;8
	lsl	d1	;8
	move.l	a2,a0	;4
	adda	d0,a0	;8
	move	32(a3,d1.w),(a0)	;20
	andi	#$fffe,-8(a0)	;20

	lea	230(a2),a2	;8

	rept	16
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	8
	nop
	endr

	dbf	d5,.full2

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	89
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	move	#28,d5

	rept	10
	nop
	endr

.full3	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	89
	nop
	endr

	move.b	d7,(a7)
	move.b	d6,(a7)

	rept	13
	nop
	endr

	move.b	d6,(a6)
	nop
	move.b	d7,(a6)

	rept	9
	nop
	endr

	dbf	d5,.full3

.restore_stack	move.l	#0,a7

	move	#$2300,sr

	cmpi.b	#$b9,$fffffc02.w
	beq	exit

	rte

line_counter	dc.w	$22
screen	dc.l	0
absciss	incbin	a:\absciss.dat
	end