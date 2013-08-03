;
; animation d'un ‚cran largeur*hauteur
;
	offset	$200
lastx:	ds.w	1
ptrbuf:	ds.l	1
	section	text

INITSCROLL:
	lea	bitmap,a0
	lea	endbitmap,a1
	move	#(largeur+16)*hauteur/2-1,d1
	moveq	#0,d0
clear_it:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	clear_it
	RTS

MOVESCROLL:
	clr	vitx
	clr	vity

	move.b	joystick1,d0
	btst	#2,d0
	bne.s	.gau
	tst.b	touches+$4b	;gauche
	beq.s	.notgau
.gau	move	#-4,vitx
.notgau
	btst	#3,d0
	bne.s	.dro
	tst.b	touches+$4d	;droite
	beq.s	.notdro
.dro	move	#4,vitx
.notdro
	btst	#0,d0
	bne.s	.hau
	tst.b	touches+$48	;haut
	beq.s	.nothau
.hau	move	#1,vity
.nothau
	btst	#1,d0
	bne.s	.bas
	tst.b	touches+$50	;bas
	beq.s	.notbas
.bas	move	#-1,vity
.notbas
	BSR	REFRESH

	move	vity,d0
	add	d0,coordy
	cmp	#hauteur-1,coordy
	bls.s	1$
	sgt	d0
	ext	d0
	and	#hauteur-1,d0
	move	d0,coordy
	neg	vity
1$

	move.l	ecran,a0
	lea	(hauteur-1)*160+largeur/2+24+12*160(a0),a0
	move.l	a0,usp

	move	#hauteur-1,d0
	sub	coordy,d0
	beq.s	.not1
	move.l	ptrbuf,a6		;base ptr=ptrbuf+(hauteur-hauteur)

	asl	#3,d0			;*24
	move	d0,d2
	add	d0,d0
	add	d2,d0

	lea	endscroller(pc),a0
	sub	d0,a0

	move.l	#.retour1,$10.w
	move	#$300,sr		;gain=8 cycles
	jmp	(a0)
.retour1:
	addq	#6,sp
.not1

	move	coordy,d0
	beq.s	.not2
	move.l	ptrbuf,a6		;base ptr=ptrbuf+(hauteur-hauteur)

	move	#hauteur-1,d1
	sub	d0,d1
	asl	#3,d0			;*24
	move	d0,d2
	add	d0,d0
	add	d2,d0

	lea	endscroller(pc),a0
	sub	d0,a0

	;mulu	#(largeur+16)/2,d1
	muls	#(largeur+16)/2,d1	;gain 4 cycles !!!!
	add.l	d1,a6

	move.l	#.retour2,$10.w
	move	#$300,sr		;gain=8 cycles
	jmp	(a0)
.retour2:
	addq	#6,sp
.not2
	RTS


coordy:	dc.w	0
vity:	dc.w	1

fastscroller
;
; la routine suivante fait 24 octets par ligne
;
x	set	hauteur*(largeur+16)/2
	rept	hauteur
x	set	x-(largeur+16)/2
	movem.l	x+56(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	movem.l	x(a6),d0-d7/a0-a5
	movem.l	d0-d7/a0-a5,-(a7)
	lea	-160+largeur/2(a7),a7
	endr
	illegal
endscroller


vitx:	dc.w	4
coordx:	dc.w	0
;
REFRESH:
	move	coordx,lastx

	move	vitx,d0
	add	d0,coordx
	cmp	#320-4,coordx
	bls.s	.noclipx
	sgt	d0
	ext	d0
	and	#320-4,d0
	move	d0,coordx
	neg	vitx
.noclipx

	moveq	#$f,d1
	and	coordx,d1		;d1=d‚calage
	lsr	#2,d1
	mulu	#bitmap1-bitmap0,d1

	moveq	#0,d0
	move	coordx,d0
	lsr	#4,d0			;coordx/16

	lea	blocks,a4
	add	d0,a4			;pointeur map

	asl	#3,d0			;*8
	lea	bitmap,a6
	add.l	d1,a6
	add	d0,a6
	move.l	a6,ptrbuf		;pointeur buffer

	move	coordx,d0
	sub	lastx,d0
	beq	samecoord

	bpl.	.right
	tst	d1		;shift=0 ?
	beq.s	.left
	subq	#8,a6
	bra.s	.left
.right
	lea	largeur/16(a4),a4
	lea	largeur/2(a6),a6
	tst	d1
	beq.s	.left
	subq	#8,a6
.left
	moveq	#$f,d1
	and	coordx,d1
	lsr	#1,d1

	MOVEQ	#(hauteur+16)/16-1,D7
	lea	shifter(pc),a2
	add	(a2,d1.w),a2

shifte	macro
	lea	\@(pc),a3
	jmp	(a2)
\@
	endm

x	set	0
	rept	(hauteur+16)/16

	MOVEQ	#0,D0
	MOVE.B	x(A4),D0
	ASL	#7,D0

	LEA	blocks+$DC,A5
	ADD	D0,A5		;a5=source bitmap
;
; d5-d7/a2-a4 non utilis‚s dans shift.bin
;
	shifte
x	set	x+20
	endr
samecoord:
	rts

PTR:	DC.L	0

	include	INCLUDES\kbd.s


shifter:incbin	INCLUDES\shift3.bin
blocks:	incbin	INCLUDES\VIGN.IMG

	section	bss
	ds.b	8
bitmap:
bitmap0:ds.b	(largeur+16)*(hauteur+17)/2		;d‚calage=0
bitmap1:ds.b	(largeur+16)*(hauteur+17)/2		;d‚calage=4
bitmap2:ds.b	(largeur+16)*(hauteur+17)/2		;d‚calage=8
bitmap3:ds.b	(largeur+16)*(hauteur+17)/2		;d‚calage=12
endbitmap:
