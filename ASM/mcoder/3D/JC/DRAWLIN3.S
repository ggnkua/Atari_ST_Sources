	opt	o+
	output	drawline.prg
nblig = 200
	offset	$800
pointsgauches:ds.w	nblig
pointsdroits:ds.w	nblig
	section	text
;
; entr‚e :
;	d0=X0
;	d1=Y0
;	d2=X1
;	d3=Y1
;
; registres utilis‚s :
;	a0=pointeur pour remplissage coordonn‚es
;	a1=adresse retour
;	d0=X0
;	d1=Y0
;	d2=X1
;	d3=Y1
;	d4=cumul
;	d5=partie entiŠre de la pente
;	d6=ymin
;	d7=ymax
;
onepoint:
	add	d1,d1
	move	d0,(a0,d1.w)
noline:	JMP	(a1)
drawline:
	cmp	d1,d3		;du haut vers le bas
	beq.s	noline		;pas 2 Y pareils !!!!
	lea	pointsdroits\W,a0
	bhs.s	1$
	exg	d0,d2
	exg	d1,d3
	lea	pointsgauches\W,a0
1$
	cmp	d6,d1
	bhs.s	.notmin
	move	d1,d6		;nouveau Y minimum
.notmin
	cmp	d7,d3
	bls.s	.notmax
	move	d3,d7		;nouveau Y maximum
.notmax
	sub	d1,d3
	beq.s	onepoint
;
; ici d1=Y haut
;     d3=nb pixels verticalement=pente en Y
;
; calcul des pointeurs pour ‚criture donn‚es
;
	add	d1,d1
	add	d1,a0

	move	d3,d1
	add	d1,d1

	add	d1,d1

	move	d3,d4
	lsr	#1,d4		;d4=cumul
	sub	d0,d2
;
; d0=X d‚part
; d2=delta X
; d3=delta Y
;
	bpl	pente_droite
pente_gauche
	neg	d2
	cmp	d2,d3
	bhs	dysupdx

DX3	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	subq	#1,d0
\@
	sub	d5,d0
	ENDM
;dx>dy
	ext.l	d2		;bit 15=0->cleare poids fort
	divu	d3,d2		;d2.h=reste
	move	d2,d5
	swap	d2		;nouveau deltax

	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdx3-x
x	set	x+12
	endr

	rept	nblig-1
	DX3
	ENDR
bdx3
	move	d0,(a0)+
	JMP	(a1)

DY3	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	subq	#1,d0
\@
	ENDM

dysupdx
	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdy3-x
x	set	x+10
	endr

	rept	nblig-1
	DY3
	ENDR
bdy3
	move	d0,(a0)+
	JMP	(a1)

DX1	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	addq	#1,d0
\@
	add	d5,d0
	ENDM

pente_droite
	cmp	d2,d3
	bhs	dysupdx2
;dx>dy
	ext.l	d2		;clear poids fort
	divu	d3,d2
	move	d2,d5
	swap	d2

	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdx1-x
x	set	x+12
	endr

	rept	nblig-1
	DX1
	ENDR
bdx1
	move	d0,(a0)+
	JMP	(a1)
dysupdx2

DY1	MACRO
	move	d0,(a0)+
	sub	d2,d4
	bhs.s	\@
	add	d3,d4
	addq	#1,d0
\@
	ENDM

	jmp	.letsgo(pc,d1.w)
.letsgo
x	set	0
	rept	nblig
	bra.w	bdy1-x
x	set	x+10
	endr

	rept	nblig-1
	DY1
	ENDR
bdy1
	move	d0,(a0)+
	JMP	(a1)
