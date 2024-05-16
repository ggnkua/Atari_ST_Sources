;
; COMPACTAGE D'OCTETS
;
; ENTREE :
;	D1.W=nb octets
;	A0=adresse source
;	A1=adresse destination
;
; SORTIE :
;	A0=adresse 1er octet n'ayant pu etre compact‚
;	A1=adresse fin des octets compact‚s
;
comp:
	subq	#1,d1
	blt.s	fini
	move.b	(a0)+,d0
	bra.s	entete
repeat:	move.b	-1(a0),d0
	sub	a0,d2
	addq	#1,d2
	move.b	d2,(a2)
entete:
	move	a0,d2
	move.l	a1,a2
	clr.b	(a1)+
	cmp.b	(a0),d0
	bne.s	copy
	cmp.b	1(a0),d0
	bne.s	copy
	bra.s	pareil
trans:	move.b	(a0)+,d0
	cmp.b	(a0),d0
	bne.s	copy
	cmp.b	1(a0),d0
	beq.s	change
copy:	move.b	d0,(a1)+
	dbra	d1,trans
	sub	a0,d2
	neg	d2
	move.b	d2,(a2)
	bra.s	fini
change:
	tst	d1
	beq.s	copy
	sub	a0,d2
	not	d2
	move.b	d2,(a2)
	move	a0,d2
	move.l	a1,a2
	clr.b	(a1)+
pareil:	move.b	d0,(a1)+
compar:	cmp.b	(a0)+,d0
	dbne	d1,compar
	beq.s	differe
	subq	#1,d1
	bge.s	repeat
differe:
	sub	a0,d2
	addq	#1,d2
	move.b	d2,(a2)
fini:
	rts
;
; DECOMPACTAGE D'OCTETS
;
; ENTREE :
;	A0=adresse source
;	A1=adresse destination
;	D2.W=nb octets du buffer de destination
;
; SORTIE :
;	A0=adresse 1er octet n'ayant pu etre d‚compact‚
;	A1=adresse fin du code d‚compact‚
;
decomp:
	ext.l	d2
	add.l	a1,d2
	bra.s	deco1
diff:	ext	d1
bytes:	move.b	(a0)+,(a1)+
	dbra	d1,bytes
deco1:	cmp.l	d2,a1
	bhs.s	fin
	move.b	(a0)+,d1
	bpl.s	diff
	neg.b	d1
	bvs.s	deco1
	ext	d1
	move.b	(a0)+,d0
fill:	move.b	d0,(a1)+
	dbra	d1,fill
	bra.s	deco1
fin:
	rts
