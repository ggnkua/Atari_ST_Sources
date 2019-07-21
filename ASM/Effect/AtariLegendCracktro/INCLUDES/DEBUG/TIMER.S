*********************************************
*  Mini-program to determine the number of  *
*        clockcycles a routine uses         *
*         by: Niclas Thisell / TCB          *
*********************************************

run_demo:

	; Define new screen
	SET_PHYSBASE $70000,screen_adr
	move.l	screen_adr,$44E.w

	lea	introtext,a0
	move.l	screen_adr,a1
	move.w	#0,d0	; x
	move.w	#0,d1	; y
	move.w	#1,d5	; color
	bsr	print_text

	bsr.s	clock_init_once

	move.w	#$765,PALETTE.w

loop:	bsr	vsync

	bsr.s	clock_init_vbl

	move	#$2700,sr

	lea	$FFFF8209.w,a0
	moveq	#0,d0
.wait:	move.b	(a0),d0
	beq.s	.wait
	not.w	d0
	lsr.w	d0,d0
	move.w	#128,d0
	sub.w	nopno(pc),d0
	add.w	d0,d0
	jmp	.jmpbase(pc,d0.w)
.jmpbase:	dcb.w	128,$4E71

	bsr	clock_routine

	move.b	$FFFF8209.w,d0
	move.b	$FFFF8207.w,d1
	move.b	$FFFF8205.w,d2
	move.b	$FFFF8209.w,d3
	sub.b	d0,d3
	cmp.b	#18,d3
	beq.s	.found_values
	addq.w	#5,nopno
	andi.w	#127,nopno
	beq.s	something_wrong_here
	move.w	#$765,PALETTE.w
	move	#$2300,sr
	bra	loop

.found_values:
	move.w	#$770,PALETTE.w
	move	#$2300,sr

	and.l	#$FF,d0
	and.l	#$FF,d1
	and.l	#$FF,d2
	lsl.w	#8,d2
	add.w	d1,d2
	lsl.l	#8,d2
	add.w	d0,d2
	sub.l	$44E.w,d2
	divu	#160,d2
	move.l	d2,d0
	mulu	#256,d0
	swap	d2
	add.w	d2,d0
	sub.w	nopno(pc),d0
	sub.w	nopno(pc),d0
	add.w	d0,d0
	sub.w	#232,d0
	bra.s	getouttahere

something_wrong_here:
	move.w	#10000,d0
.p:	addi.w	#$123,PALETTE.w
	dbra	d0,.p
	move.l	#99999,d0
	bra.s	getouttahere

nopno:	dc.w	0

getouttahere:
	move	#$2300,sr
	move.w	#$777,PALETTE.w

	lea	numbertext+5(pc),a0
	moveq	#5-1,d7
.decoutloop:
	divu	#10,d0
	swap	d0
	add.w	#"0",d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
	dbra	d7,.decoutloop

	lea	numbertext,a0
	move.l	screen_adr,a1
	move.w	#0,d0	; x
	move.w	#8,d1	; y
	move.w	#1,d5	; color
	bsr	print_text

	; Check keyboard 
.waitkey:	cmpi.b	#$39,KEYBOARD_DATA.w
	bne.s	.waitkey

	rts

introtext:	dc.b "YOUR ROUTINE TAKES ",0
numbertext:	dc.b "      CLOCKCYCLES. ",0
screen_adr:	dc.l 0