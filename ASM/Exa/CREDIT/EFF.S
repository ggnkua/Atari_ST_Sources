;	effacement
ecran1	equ	$300000
ecran2	equ	$300000+128000
debug	equ	0

	jmp	start_eff
	include	macro&co.s
	include	fal_rez2.s
start_eff
	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	init_trap
	bsr	init_ecran
	bsr	repli_ecrans

	ifeq	debug
	aset_screen	ecran
	aset_video	#4
	trap	#3
	endc

loop_start
	vsync
	lea	table(pc),a5
	bsr	go_effect

	add	#20,many_bloc
	cmp	#640-1,many_bloc
	ble.s	.end
	move	#640-1,many_bloc
.end
	cmp.b	#$39,$fffffc02.w
	bne.s	loop_start
	

	arestore_palette
	arestore_screen
	arestore_video
	trap	#3

	clr.l	-(sp)
	trap	#1



go_effect
	lea	carre(pc),a0
	movem.l	ecran(pc),a1-a2
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
	move	d4,d5
	and	#$1f,d5
	mulu	#20,d5
	lea	(a1,d5),a3	
	lea	(a2,d5),a4
	
	lsr	#5,d4	
	
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
	lea	(a4,d3.l),a6
	rept	5
	move.l	d0,(a6)+
	endr	
	dbf	d1,.loop
	rts
	





	



init_ecran
	ifeq	debug
	asave_palette
	asave_screen
	asave_video
	trap	#3
	endc
	rts


repli_ecrans
	movem.l	ecran,a0-a1
	move.l	#128000,d0
	move.l	#$140014,d1
.eff
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	subq.l	#4,d0
	bpl.s	.eff
	lea	carre(pc),a0
	move	#640-1,d6
.all_block
	move	#10,(a0)+
	dbf	d6,.all_block
	rts
	

	

	section	data

many_bloc	dc.w	1
ecran	dc.l	ecran1,ecran2
table	
	incbin	tablea.dat
	section	bss
carre	ds.w	1
	