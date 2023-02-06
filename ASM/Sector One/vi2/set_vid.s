; Routine de g‚n‚ration de modes vid‚o capable de g‚n‚rer tout mode graphique autre
; que les modes compatibles ST basse et moyenne r‚solution (modes 4096 couleurs)
; ½ 1995-96 Zerkman / Trisomic Development

;ParamŠtres … fournir en entr‚e:
; a0 = adresse du tableau de mots d'entr‚e (structure VIDEO_MODE)
; a1 = adresse du tableau de mots de sortie (structure VIDEO_REGS je crois)

; entr‚e:
flags	equ	0
npix	equ	2
xres	equ	4
xdec	equ	6
nlin	equ	8
yres	equ	10
ydec	equ	12

; sortie:
s_hht	equ	0
s_hbb	equ	2
s_hbe	equ	4
s_hdb	equ	6
s_hde	equ	8
s_hss	equ	10
s_vft	equ	12
s_vbb	equ	14
s_vbe	equ	16
s_vdb	equ	18
s_vde	equ	20
s_vss	equ	22
s_rco	equ	24
s_vco	equ	26
s_width	equ	28
s_cmode	equ	30

;s_wrap	equ	28


;	export	genere_mode	; C'est pour Pure C, ca, on laisse courir !

*** D‚but de la routine de g‚n‚ration de modes vid‚o ***
	section	text

genere_mode:
	movem.l	d1-d7/a2,-(sp)
	movem.w	npix(a0),d0-d2	;d0 = npix
				;d1 = xres
				;d2 = xdec

	moveq	#1,d7		;pour diviser la nb de pixels par 2
	btst.b	#3,flags+1(a0)
	beq.s	pashaut
	moveq	#2,d7		;div par 4 parce qu'en haute rez les pixels sont doubl‚s
pashaut:
	lsr	d7,d0		;conversion pixels -> double pixels
	lsr	d7,d1
	lsr	d7,d2

	moveq	#$2f,d5
	move	flags(a0),d6
	and	#3<<2,d6
	bne.s	pas_basse
	moveq	#$17,d5		;on divise par 2 (basse r‚s.)
pas_basse:
	move	d0,d7
	subq	#1,d7
	move	d7,s_hht(a1)	;hht = npix/2 - 1
	sub	d5,d7
	move	d7,s_hss(a1)	;hss = npix/2 - $30

	move	d2,s_hbe(a1)	;hbe = xdec/2
	move	d2,d7
	sub	d0,d7
	move	d1,d6
	add	d6,d6
	add	d6,d7
	subq	#1,d7
	move	d7,s_hbb(a1)	;hbb = xdec/2 - npix/2 + xres - 1

	move	d2,d6
	add	d0,d6		;hbe + npix -> "a", hbb -> "b"

	move	flags(a0),d5
	lsr	#4,d5
	and	#7,d5		;log2 (Nombre de plans)

	move	xres(a0),d4
	lsl	d5,d4		;* nombre de bitplans
	lsr	#4,d4		;taille en mots et non en bits
	move	d4,s_width(a1)

	lea	decalages_tbl(pc,d5.w*8),a2
	bra.s	decal_fin

decalages_tbl:
	dc.b	$0,$0,$0,$0,$69,$41,$0,$0	;2 couleurs 32 MHz

	dc.b	$42,$22,$52,$22,$39,$9,0,0	;4 couleurs (faux)
	dc.b	$42,$22,$52,$22,$39,$9,0,0	;16 couleurs
	dc.b	$32,$12,$42,$12,$31,$9,0,0	;256 couleurs
	dc.b	$20,$0,$30,$0,0,0		;True Color
decal_fin:

	move	flags(a0),d3
	lsr	#2,d3
	and	#3,d3
	lea	(a2,d3.w*2),a2
	moveq	#0,d3
	moveq	#0,d4
	move.b	(a2)+,d3
	move.b	(a2),d4
	move	d4,d5
	or	d3,d5
	beq	error		;si les 2 octets sont nuls
	sub.w	d3,d6
	sub.w	d4,d7

	cmp	d6,d0		;a < npix/2 [/4] ?
	bpl.s	sup_eg
	sub	d0,d6
	subq	#1,d6
	bra.s	inf
sup_eg:	add.w	#$200,d6
inf:	move	d6,s_hdb(a1)

	bftst	flags(a0){9:3}
	bne.s	pas_mono

	move	d1,d6
*	lsr	d6
*	btst	#3,vmode+1(a0)
*	beq.s	pas_quadr
*	lsr	d6
*pas_quadr
	neg	d6
	and	#$1f,d6
	add	d6,d6
	add	d6,d7

pas_mono:
	move	d7,s_hde(a1)

	movem.w	nlin(a0),d0-d2

	add	d0,d0		;on compte ici en double lignes
	add	d1,d1
	add	d2,d2

	move	flags(a0),d4
	btst	#1,d4
	beq.s	non_entrelace
	lsr	d1		;yres / 2
non_entrelace:
	btst	#0,d4
	beq.s	simple_ligne
	add	d1,d1		;yres * 2
simple_ligne:

	moveq	#0,d5
	btst	#1,d4		;mode entrelac‚ ?
	beq.s	pas_entrelace
	moveq	#1,d5
pas_entrelace:
	move	d0,d3
	subq	#7,d3
	move	d3,s_vss(a1)

	addq	#6,d3
	sub	d5,d3
	move	d3,s_vft(a1)

	move	d2,d3		;ydec * 2
	sub	d5,d3
	addq	#1,d3
	move	d3,s_vbe(a1)
	move	d3,s_vdb(a1)
	add	d1,d3		;yres * 2
	move	d3,s_vde(a1)

*! 0, 1, ou 2 fois la ligne suivante ???
	add	d5,d3
	add	d5,d3
	move	d3,s_vbb(a1)

	move	d4,s_vco(a1)

	move	#$186,d5
	bfextu	flags(a0){7:2},d0	;mode 25 MHz ?
	beq.s	mhz_25
	move	#$182,d5
	IFD	DX3
	cmp	#2,d0		; Mode 40 MHz ?
	beq.s	mhz_25
	move	#$8186,d5	; Sinon c'est le mode 50 MHz
	ENDC
mhz_25:
	btst	#1,d4		;si entrelac‚
	beq.s	no_int
	bset	#3,d5
no_int:	move	d5,s_rco(a1)

	bfextu	flags(a0){9:3},d4
	move	coul_tbl(pc,d4.w*2),s_cmode(a1)

	moveq	#1,d0
exit:
	movem.l	(sp)+,d1-d7/a2
	rts
error:
	moveq	#0,d0
	bra.s	exit

coul_tbl:
	dc.w	$400,$0,$0,$10,$100

