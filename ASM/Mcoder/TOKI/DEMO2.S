	output	a:\auto\toki.prg
;
; d‚mo de sprites
;
ecran0	equ	$78000
	opt	o+
;
; a0=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
CLIPPE2	MACRO

	moveq	#$f,d5
	and	d1,d5
	add	d3,d5

	moveq	#15,d7		;D7=$F (gain=4 cycles)
	add	d7,d5
	add	d7,d3
	not	d7		;D7=$FFF0 (gain=4 cycles)
	and	d7,d5
	and	d7,d3
	lsr	#1,d5		;d5=nb octets pour effacement
	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	A0=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	sub.l	a3,a3

	cmp	#200,d2
	blo.s	cliphau\@
	bge	retsp\@		;trop en bas
	neg	d2
	sub	d2,d4
	bls.s	retsp\@
	mulu	d3,d2
	add	d2,a0
	moveq	#0,d2		;d2=offset ‚cran
	bra.s	noclipbas\@
cliphau\@
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160(pc),a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#200,d0
	bls.s	noclipbas\@
	sub	d0,d4
noclipbas\@

	move	#160,a2
	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	a2,d1		;<160 ?
	blo.s	clipgau\@
	bge.s	retsp\@		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
	bls.s	retsp\@
	sub	d1,d5

	move	d1,a3
	add	a3,a0
	or.b	#$40,d0		;indique clipping … gauche
	bra.s	noclipdro\@
clipgau\@
	add	d1,d2		;offset Y
	add	d3,d1
	sub	a2,d1		;>nb plans dans une ligne ?
	blo.s	noclipdro\@
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	sub	d1,d5
	move	d1,a3
noclipdro\@
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d5=nb plans*8 … effacer
;	d4=nb lignes
;
	cmp	d3,d5
	bne.s	pacl\@
	btst	#6,d0
	bne.s	pacl\@
	tas	d0
pacl\@
	add	d5,d5

	move.l	screen,a1
	add	d2,a1

	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3

	LEA	newsprite(pc),a4
	jsr	(a4,d0.w)
retsp\@
	ENDM

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	lea	ecran0,sp
	move.l	#ecran0,screen
	move.l	#ecran0,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	jsr	debugger
	move.l	#vbl,$70.w


	move	#$2300,sr
	clr	sync
bc:	tst	sync
	beq.s	bc
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
boucle:
	move	sync,d0
1$	cmp	sync,d0
	beq.s	1$
;
; nouvelle routine de sprite d‚calant
;
; d0=num‚ro du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur

	addq	#7,$ffff8240.w
	move	#8,d1		;X
	move	#0,d2		;Y
	lea	toki,a0
	move	#128,d3
	move	#128,d4
	CLIPPE2
	clr	$ffff8240.w
	bra	boucle
vbl:
	addq	#1,sync
	rte
nbspr:	dc.w	0
sync:	dc.w	0
debugger:incbin	debugger.bin
palette:
	DC.W	$000,$600,$731,$752,$773,$006,$060,$630
	DC.W	$777,$555,$100,$200,$310,$420,$520,$740

newsprite
	INCBIN	SPRITE17.BIN
mul160
x	set	0
	rept	200
	dc.w	x
x	set	x+160
	endr
screen	dc.l	0

toki	dcb.w	128*128/4,-1
