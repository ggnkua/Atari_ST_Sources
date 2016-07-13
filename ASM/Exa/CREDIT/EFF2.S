;	effacement
debug	equ	0
	include	macro&co.s
	move.l	$42e,ecran
	sub.l	#128000,ecran
	aset_screen	ecran
	bsr	repli_ecrans
loop_start
	vsync
	lea	table(pc),a5
	bsr	go_effect

	add	#20,many_bloc
	cmp	#640-1,many_bloc
	ble.s	.end
	move	#640-1,many_bloc
.end
	tst.b	one
	bne.s	loop_start
	rts


go_effect
	sf	one
	lea	carre(pc),a0
	move.l	ecran(pc),a1
	moveq	#0,d0
	moveq	#0,d4
	move.w	many_bloc(pc),d1
.loop
	move	(a5)+,d4
	cmp	#$14<<5,d4
	bge.s	.loop
	subq	#1,(a0)+
	dbpl	d1,.loop
	bpl.s	.loop2
	rts
.loop2
	st	one
	move	d4,d5
	and	#$1f,d5
	mulu	#20,d5
	lea	(a1,d5),a3	
	lsr	#5,d4	
	moveq	#0,d2
	moveq	#0,d3
	move.w	-2(a0),d2
	mulu	#10,d4
	add.l	d4,d2
	lsl.l	#7,d2
	move.l	d2,d3
	lsl.l	#2,d3
	add.l	d2,d3
	lea	(a3,d3.l),a6
	rept	5
	move.l	d0,(a6)+
	endr	
	dbf	d1,.loop
	rts
	



repli_ecrans
	lea	carre(pc),a0
	move	#640-1,d6
.all_block
	move	#10,(a0)+
	dbf	d6,.all_block
	rts
	
	section	data
one		dc.w	0
many_bloc	dc.w	1
ecran	dc.l	0
table	
	incbin	tablea.dat
carre	ds.w	1
	