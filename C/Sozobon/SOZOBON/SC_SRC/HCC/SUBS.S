
	.globl _lclr
	.text
_lclr:
	link	a6,#0

	move.l	8(a6),a0
	move	12(a6),d0
	bra	L5
L4:
	clr.l	(a0)+
L5:
	dbf	d0,L4

	unlk	a6
	rts

	.globl _lcpy
	.text
_lcpy:
	link	a6,#0

	move.l	8(a6),a0
	move.l	12(a6),a1
	move	16(a6),d0
	bra	L8
L7:
	move.l	(a1)+,(a0)+
L8:
	dbf	d0,L7

	unlk	a6
	rts
