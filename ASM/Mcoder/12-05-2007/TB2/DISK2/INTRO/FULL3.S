; Fullscreen qui marche sur sur tout stf et STE!!!!!
;
; nb blocs pour remplir l'‚cran :
;	26*17
;
; soit 412*276
;
; 63480 octets pour un ‚cran
;
;JAUNE=0		;0=RASTERS JAUNES
;modulo=44
longueur=(63480+255)&-256
full0=$80000-longueur
hauteurscroll=75*8+276*2	;nb lignes verticalement+2 ‚crans

	opt	o+

DEC	equ	204

nnop	macro
	ifgt	\1
	WAIT	\1,d2
	elseif
	IFNE	\1
	fail
	ENDC
	endc
	endm
;
; optimisations :
;	0=rien
;	1=NOP
;	2=OR.L D0,D0
;	3->???=LSR.L #,D0
;
WAIT	MACRO

	iflt	\1-(8+2*64)/4		;8+2n

	ifle	\1-2
	ifeq	\1-1
	nop
	elseif
	or.l	d0,d0
	endc
	elseif
	moveq	#(\1-3)*2,\2
	lsr.l	\2,\2
	endc
	elseif

N3	SET	(\1-7)-((\1-7)/5)*5
BEST	SET	3
MIN	SET	N3		;RECORD A BATTRE

N2	SET	(\1-6)&3
	IFLE	N2-MIN
BEST	SET	2
MIN	SET	N2
	ENDC

N1	SET	(\1-5)-((\1-5)/3)*3
	IFLE	N1-MIN
BEST	SET	1
MIN	SET	N1
	ENDC

	IFEQ	BEST-1
	MOVEQ	#(\1-5)/3,\2
\@	DBRA	\2,\@
	IFNE	N1
	DCB.W	N1,$4E71
	ENDC
	ENDC

	IFEQ	BEST-2
	MOVEQ	#(\1-6)/4,\2
\@	NOP
	DBRA	\2,\@
	IFNE	N2
	DCB.W	N2,$4E71
	ENDC
	ENDC

	IFEQ	BEST-3
	MOVEQ	#(\1-7)/5,\2
\@	NOP
	NOP
	DBRA	\2,\@
	IFNE	N3
	DCB.W	N3,$4E71
	ENDC
	ENDC

	endc
	ENDM

fullscreen:
;
; affichage du motif en 3 plans
;
	lea	bloc(pc),a0
	lea	full0+DEC,a5

	moveq	#8-1,d0
cop1:
	move.l	(a0)+,d6
	move	(a0)+,d7
	swap	d7
	clr	d7

	moveq	#26-1,d1
cop2:
	move.l	a5,a3
	moveq	#17*2-1,d2
.cop
	movem.l	d6-d7,(a3)
	lea	230*8(a3),a3
	dbra	d2,.cop
	addq.l	#8,a5
	dbra	d1,cop2
	lea	230-26*8(a5),a5
	dbra	d0,cop1

	move	#$2700,sr
	clr.b	$fffffa1b.w

	move.b	#%00100000,$fffffa13.w

	move.l	#fullvbl,$70.w
	move.l	#fullhbl,$68.w
	move.l	#timera,basemfp+$34.w
	move	#$2300,sr

mainloop:
	bra.s	mainloop
fin:
	move	#$2700,sr
	clr.b	$fffffa13.w
	rts

timera:
	clr.b	$fffffa07.w
	move	#$2100,sr

	stop	#$2100		; Synchro HBL
	move	#$2700,sr

	movem.l	d0/d1/d2/d3/d7/a0/a1/a2/a3/a4/a5,-(sp)	;56+16 cycles

	lea	$ffff820a.w,a0	; Overscan haut
	lea	$ffff8260.w,a1
	moveq	#0,d0
	moveq	#2,d1
	nnop	83-4-8-2-2-2-4-2	;-5 a +8
	move.b	d0,(a0)
	nnop	16
	move.b	d1,(a0)

	nnop	21		; Synchro SHIFTER
	move.b	$ffff8209.w,d2
	neg.b	d2
	lsr	d2,d2
				; 1ere ligne de fullscreen
	nnop	41

	move.b	d0,(a0)
	move.b	d1,(a0)

	nnop	13

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nnop	12

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nop
	move	#211-1,d7

SCROLL:	MACRO
	nnop	\1
	move.b	d0,(a0)
	move.b	d1,(a0)
	nnop	13

	ifeq	\1-86

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	nnop	12

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)

	elseif

	move.b	d1,(a1)
	nop
	move.b	d0,(a1)
	move.b	d0,(a0)

	nnop	9

	move.b	d1,(a1)
	move.b	d1,(a0)
	move.b	d0,(a1)
	nnop	2

	endc

	ENDM

xfull1:
	SCROLL	86

	dbra	d7,xfull1

****************** Overscan bas pour tres anciens ST

	SCROLL	85

	moveq	#15-1,d7

xfull2:
	SCROLL	86

	dbra	d7,xfull2

****************** Overscan bas pour les autres STF/STE

	SCROLL	85

	moveq	#44-1,d7
xfull3:
	SCROLL	86

	dbra	d7,xfull3

	movem.l	(sp)+,d0/d1/d2/d3/d7/a0/a1/a2/a3/a4/a5
fullhbl:rte

fullvbl:
	clr.b	$fffffa19.w
	move.b	#$65,$fffffa1f.w	;valeur non exacte !!!
	move.b	#4,$fffffa19.w
	move.b	#%00100000,$fffffa07.w
	rte
bloc:
basemfp=$100
;	ds.b	1000
