;
; convertion d'un entier en une chaine de caracteres
; d0.w=valeur    a0=adresse de la chaine (3 octets.)
;
dec_asc	moveq #3,d1
decascs1	move.b #"0",(a0)+
	dbra d1,decascs1
	tst.l d0
	beq.s decascs2
div	moveq #0,d3
	moveq #10,d1
	divu d1,d0
	bvc.s result
	move.l d0,d2
	clr d0
	swap d0
	divu d1,d0
	move d0,d3
	move d2,d0
	divu d1,d0
result	move.l d0,d1
	swap d1
	swap d0
	move d3,d0
	swap d0
	add #"0",d1
	move.b d1,-(a0)
	tst.l d0
	bne.s div
decascs2	rts

