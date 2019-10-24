; Donne la position d'une chaine dans une autre.

; a0 = adresse de la chaine
; a1 = adresse de la chaine recherch‚e

	globl Instr;

Instr:
	movem.l	a2/a3,-(sp)
	move.l	a0,a3
	move.l	a1,a2
Cmp:
	move.l	a2,a1
NextChar:
	move.b	(a1)+,d0
	beq.b	ok
	move.b	(a0)+,d1
	beq.b	fini
	cmp.b	d0,d1
	beq.b	NextChar
	bra		Cmp
	
fini:
	clr.l	d0
	bra		return
ok:
	move.l	a0,d0
	sub.l	a3,d0
	sub.l	a1,d0
	add.l	a2,d0
	addq.l	#2,d0
return:
	movem.l	(sp)+,a2/a3
	rts
	