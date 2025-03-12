	opt	o+,ow-
;
; registres d5,d6 et d7 libres !!!!
;
largeur = 224+16	;largeur normale+16 pixels en plus
hauteur = 176+16

maskgau1	equr	a0
maskdro1	equr	a1
maskgau2	equr	a2
maskdro2	equr	a3
source		equr	a5
dest		equr	a6
plans1		equr	d0
plans2		equr	d1
plans3		equr	d2
plans4		equr	d3
mask		equr	d4
;
; affichage de la colonne  d‚cal‚e
;
; 1) d‚calage de 0
;
	move.l	#$0FFF0FFF,maskdro1
	move.l	#$F000F000,maskgau1
	move.l	#$000F000F,maskdro2
	move.l	#$FFF0FFF0,maskgau2

	rept	16
;
; d‚calage de 0
;
	move.l	(source)+,d5
	move.l	(source)+,d6
	move.l	d5,(dest)+
	move.l	d6,(dest)
;
; d‚calage de 4
;
	lea	largeur*hauteur/2-4(dest),dest

	move.l	d5,plans1
	move.l	d6,plans2
	ror.l	#4,plans1
	ror.l	#4,plans2

	move.l	maskgau1,plans3
	and.l	plans1,plans3
	eor.l	plans3,plans1
	move.l	maskgau1,plans4
	and.l	plans2,plans4
	eor.l	plans4,plans2

	swap	plans3
	swap	plans4

	move.l	maskgau1,mask
	and.l	(dest)+,mask
	or.l	mask,plans1
	move.l	maskgau1,mask
	and.l	(dest)+,mask
	or.l	mask,plans2

	move.l	maskdro1,mask
	and.l	(dest)+,mask
	or.l	mask,plans3
	move.l	maskdro1,mask
	and.l	(dest)+,mask
	or.l	mask,plans4

	movem.l	plans1/plans2/plans3/plans4,-(dest)
;
; d‚calage de 8
;
	movep.l	-8(source),plans1
	movep.l	plans1,largeur*hauteur/2+1(dest)
	movep.l	-7(source),plans1
	movep.l	plans1,largeur*hauteur/2+8(dest)
;
; d‚calage de 12
;
	add.l	#2*largeur*hauteur/2,dest

	move.l	d5,plans1
	move.l	d6,plans2
	rol.l	#4,plans1
	rol.l	#4,plans2

	move.l	maskgau2,plans3
	and.l	plans1,plans3
	eor.l	plans3,plans1

	move.l	maskgau2,plans4
	and.l	plans2,plans4
	eor.l	plans4,plans2

	swap	plans1
	swap	plans2

	move.l	maskgau2,mask
	and.l	(dest)+,mask
	or.l	mask,plans1
	move.l	maskgau2,mask
	and.l	(dest)+,mask
	or.l	mask,plans2

	move.l	maskdro2,mask
	and.l	(dest)+,mask
	or.l	mask,plans3
	move.l	maskdro2,mask
	and.l	(dest)+,mask
	or.l	mask,plans4

	movem.l	plans1/plans2/plans3/plans4,-(dest)

	sub.l	#3*largeur*hauteur/2-largeur/2,dest
	endr
