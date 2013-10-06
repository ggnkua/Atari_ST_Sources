* misc routines
* by James Ingram, March 1994

inp:
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

get_yn:
	bsr	inp

	or.b	#$20,d0
	cmp.b	#"y",d0
	beq	.rts
	
	cmp.b	#"n",d0
	bne.s	get_yn

.rts:
	rts


get_inp:
	pea	(a0)
	move.w	#10,-(a7)
	trap	#1
	addq.l	#2,a7
	
	
	move.l	(a7)+,a0
	clr.b	2(a0,d0.w)

	rts


num_to_bin:
* converts string at a0 to binary number in d0
* d1 = 0 if OK or -1 if error

* check number is valid while converting!
	moveq	#0,d0
	moveq	#0,d2

.conv_loop:
	move.b	(a0)+,d2
	beq.s	.end


	sub.b	#"0",d2
	bmi.s	.invalid
	
	cmp.b	#10,d2
	bge.s	.invalid

* valid digit!
* multiply by 10
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d1,d1
	add.l	d1,d0

	add.l	d2,d0
	bra.s	.conv_loop

.invalid:
	moveq	#-1,d1
	rts

.end:
	moveq	#0,d1
	rts



