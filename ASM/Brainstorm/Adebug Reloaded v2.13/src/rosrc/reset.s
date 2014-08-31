	output	.ro

restore_all	move	#$2700,sr
;boum!
	move.b	$ffff8260.w,d7
	andi	#3,d7
	reset
	bsr	check_ram
;restore mfp
	bsr	re_synchro
	lea	$fffffa00.w,a0
	moveq	#0,d0
	movep.l	d0,1(a0)
	movep.l	d0,9(a0)
	movep.l	d0,$11(a0)
	move.b	#$48,$17(a0)
	bset	#2,3(a0)
	
	move.l	#$50ff0200,d0
	movep.l	d0,$21(a0)

	move.l	#$000051ff,d0
	movep.l	d0,$19(a0)

	move.l	#$001e6448,d0
	movep.l	d0,$11(a0)

	move.l	#$64000000,d0
	movep.l	d0,9(a0)

	move.l	#$7704001e,d0
	movep.l	d0,1(a0)

	move.b	$44f.w,$ffff8201.w
	move.b	$450.w,$ffff8203.w

	move.b	#2,$ffff820a.w
	move.b	#1,$ffff8260.w
;restore psg
	move.b	#7,$ffff8800.w
	move.b	#$c0,$ffff8802.w
	move.b	#$e,$ffff8800.w
	move.b	#7,$ffff8802.w
;restore colors
	lea	$ffff8240.w,a0
	moveq	#$f,d0
	moveq	#7,d1
.setcolors	ror	#4,d1
	move	d1,(a0)+
	dbf	d0,.setcolors
	move	#$777,$ffff8242.w
	clr	$43e.w
	move	#3,$440.w
	move	#$14,$442.w
	move	#1,$452.w
;restore acias
	move.b	#3,$fffffc04.w
	move.b	#$95,$fffffc04.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
	move.b	#$80,$fffffc02.w
	move.b	#1,$fffffc02.w
	move.b	#8,$fffffc02.w
	move.b	#$1a,$fffffc02.w
	sf	$ffff820d.w
	sf	$ffff8264.w
	move.b	d7,$ffff8260.w
	rts
re_synchro	lea	$ffff8260.w,a2
	clr.b	(a2)
	moveq	#1,d2
	lea	$fffffa21.w,a0
	lea	$fffffa1b.w,a1
	move.b	#$10,(a1)
	move.b	#$f0,(a0)
	move.b	#8,(a1)
wt1	cmp.b	(a0),d2
	bne.s	wt1
wt2	move.b	(a0),d4
	move	#$267,d3
wt3	cmp.b	(a0),d4
	bne.s	wt2
	dbf	d3,wt3
	move.b	#$10,(a1)
	move.b	#2,$ffff820a.W
	rts
check_ram	lea	$400000,a0
.check	move.l	-(a0),d0
	move.l	#'code',(a0)
	cmpi.l	#'code',(a0)+
	beq.s	top_of_ram
	sub.l	#$80000,a0
	bra.s	.check
top_of_ram	move.l	a0,$42e.w
	sub.l	#$8000,a0
	move.l	a0,$44e.w
	rts
