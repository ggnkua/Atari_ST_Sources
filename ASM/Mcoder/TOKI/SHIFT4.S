	opt	o+,ow-
;
; registres a2-a4,d5-d7 libres !!!!
;
; a3=adresse de retour
;
; entr‚e :
;	a0=$FFFF,$0FFF,$00FF,$000F
;	a1=$0000,$F000,$FF00,$FFF0
;
retour	macro
	jmp	(a3)
	endm

largeur = 224+16	;largeur normale+16 pixels en plus
hauteur = 176+16
;largeur = 320
;hauteur = 200

maskgau	equr	a1
maskdro	equr	a0
source	equr	a5
dest	equr	a6
plans1	equr	d0
plans2	equr	d1
plans3	equr	d2
plans4	equr	d3
mask	equr	d4

start:
	dc.w	shift0-start
	dc.w	shiftc-start
	dc.w	shift8-start
	dc.w	shift4-start
;
; affichage de la colonne  d‚cal‚e
;
; 1) d‚calage de 0
;
shift0
	dc.l	$FFFFFFFF
	dc.l	$00000000
	move.l	(source)+,(dest)+
	move.l	(source)+,(dest)+
x	set	largeur/2-8
	rept	16-1
	move.l	(source)+,x(dest)
	move.l	(source)+,x+4(dest)
x	set	x+largeur/2
	endr
	lea	largeur*16/2-8(dest),dest
	retour
;
; 2) d‚calage de 4
;
shift4
	dc.l	$0FFF0FFF
	dc.l	$F000F000
;	move.l	#$0FFF0FFF,maskdro
;	move.l	#$F000F000,maskgau

	rept	16
	move.l	(source)+,plans1
	move.l	(source)+,plans2
	ror.l	#4,plans1
	ror.l	#4,plans2

	move.l	maskgau,plans3
	and.l	plans1,plans3
	eor.l	plans3,plans1
	move.l	maskgau,plans4
	and.l	plans2,plans4
	eor.l	plans4,plans2

	swap	plans3
	swap	plans4

	move.l	maskgau,mask
	and.l	(dest)+,mask
	or.l	mask,plans1
	move.l	maskgau,mask
	and.l	(dest)+,mask
	or.l	mask,plans2

	move.l	maskdro,mask
	and.l	(dest)+,mask
	or.l	mask,plans3
	move.l	maskdro,mask
	and.l	(dest)+,mask
	or.l	mask,plans4

	movem.l	plans1/plans2/plans3/plans4,-(dest)
	lea	largeur/2(dest),dest
	endr
	retour
;
; 3) d‚calage de 8
;
shift8
	dc.l	$00FF00FF
	dc.l	$FF00FF00
x	set	0
y	set	0
	rept	16
	movep.l	y(source),plans1
	movep.l	plans1,x+1(dest)
	movep.l	y+1(source),plans1
	movep.l	plans1,x+8(dest)
x	set	x+largeur/2
y	set	y+8
	endr
	lea	largeur*16/2(dest),dest
	retour
;
; 4) d‚calage de 12
;
shiftc
	dc.l	$000F000F
	dc.l	$FFF0FFF0
;	move.l	#$000F000F,maskdro
;	move.l	#$FFF0FFF0,maskgau
	rept	16
	move.l	(source)+,plans1
	move.l	(source)+,plans2
	rol.l	#4,plans1
	rol.l	#4,plans2

	move.l	maskgau,plans3
	and.l	plans1,plans3
	eor.l	plans3,plans1

	move.l	maskgau,plans4
	and.l	plans2,plans4
	eor.l	plans4,plans2

	swap	plans1
	swap	plans2

	move.l	maskgau,mask
	and.l	(dest)+,mask
	or.l	mask,plans1
	move.l	maskgau,mask
	and.l	(dest)+,mask
	or.l	mask,plans2

	move.l	maskdro,mask
	and.l	(dest)+,mask
	or.l	mask,plans3
	move.l	maskdro,mask
	and.l	(dest)+,mask
	or.l	mask,plans4

	movem.l	plans1/plans2/plans3/plans4,-(dest)
	lea	largeur/2(dest),dest
	endr
	retour
