;
; programme de calcul de remplissage optimal du disque
;
taillevoulue=512*10*82	;nb octets side 1

	lea	table(pc),a6
	moveq	#0,d7		;somme
	move.l	#taillevoulue,d6
	moveq	#0,d5
	lea	stack,a5

	bsr	recurs

	lea	table,a0
	moveq	#0,d0
addm:
	add.l	(a0)+,d0
	cmp.l	#fintable,a0
	blo.s	addm
	sub.l	d5,d0

	MOVE.L	D6,D1
	SUB.L	D0,D1
	illegal

recurs:
	cmp.l	#fintable,a6
	bhs.s	exit

	move.l	(a6)+,d0
	add.l	d7,d0

	cmp.l	d6,d0
	bhi	next

	move.l	d7,-(sp)

	move.l	d0,d7

	move.l	a6,-(a5)

	cmp.l	d5,d7
	bls.s	lower
	move.l	d7,d5
	bsr	printsol
lower:
	bsr	recurs
	move.l	(a5)+,a6
	sub.l	-4(a6),d7
	bmi	bug
	cmp.l	(sp)+,d7
	bne	bug

next:
	cmp.l	#fintable,a6
	blo.s	recurs
exit:	rts
bug:
	illegal
printsol:
	cmp.l	#stack,a5
	beq	bug
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d7,sum
depile:
	move.l	(a5)+,a0
	move.l	-(a0),d7
	bsr	decimal
	cmp.l	#stack,a5
	blo.s	depile

	move.l	sum,d7
	bsr	decimal

	move	#7,-(sp)
;	trap	#1
	addq	#2,sp
	bsr	cr
	movem.l	(sp)+,d0-d7/a0-a6
nostk:
	rts
sum:	dc.l	0

decimal:
	clr	-(sp)
deci1:
	divu	#10,d7
	swap	d7
	add	#'0',d7
	move	d7,-(sp)
	clr	d7
	swap	d7
	tst.l	d7
	bne.s	deci1

	move	(sp)+,d0
deci2:
	move	d0,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	move	(sp)+,d0
	bne.s	deci2
cr:
	move	#13,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp

	move	#10,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	rts
;
; les tailles des fichiers
;
table:
	DC.L	41992	;ATM
	DC.L	26076	;CYBERN
	DC.L	19454	;DEFCON4
	DC.L	21652	;EQUINOX
	DC.L	29640	;HARD_3D
	DC.L	149976	;KNUCKLE3
	DC.L	20468	;ORIGINAL
	DC.L	12750	;OUTLAWS
	DC.L	29600	;SILVERS
	DC.L	180394	;TBC
	DC.L	28712	;TMF
	DC.L	15786	;TSB
	DC.L	14254	;UTS
	DC.L	53072	;VOYAGERS
	DC.L	71552	;WALLS

fintable:
	dc.l	-1

	blk.l	100
stack:
	dc.l	-1
