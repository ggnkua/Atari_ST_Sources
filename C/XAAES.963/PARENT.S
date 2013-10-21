*
* XaAES - XaAES Ain't the AES
*
* A multitasking AES replacement for MiNT
*

globl  get_parent

	text
get_parent:
	move.l	4(a7),a0
	move	8(a7),d0
	move 	d0,d2
	bgt.s	l2
	moveq	#-1,d0
	bra.s	lx

l1:	move 	d2,d0
	muls	#24,d0
	move 	0(a0,d0.l),d2
l2:	tst 	d2
	beq.s	l3
	move 	d2,d1
	muls	#24,d1
	move 	0(a0,d1.l),d0
	muls	#24,d0
	cmp 	4(a0,d0.l),d2
	bne.s	l1
l3:	move 	d2,d0
	muls	#24,d0
	move 	0(a0,d0.l),d0
lx:	rts
	end
