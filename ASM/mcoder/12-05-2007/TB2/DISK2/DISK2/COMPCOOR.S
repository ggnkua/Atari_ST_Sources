load=$80000
save=$90000

	lea	load,a5
	lea	save,a6

	CLR	D0
	CLR	D1

bcl2:
	MOVE	(A5)+,D2
	MOVE	(A5)+,D3

	sub.b	D2,d0
	NEG.B	D0
	move.b	d0,(a6)+
	sub.b	D3,d1
	NEG.B	D1
	move.b	d1,(a6)+
	move.b	D2,d0
	move.b	D3,d1

	cmp.l	#LOAD+5120,a5
	blo.s	bcl2
	lea	save,a0
	move.l	a6,a1

;	lea	$90000+2,a2
;	lea	$a0000+2,a3
;o:	cmpm.b	(a2)+,(a3)+
;	beq.s	o


	illegal

erreur:
	illegal
