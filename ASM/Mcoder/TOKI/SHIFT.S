	opt	o+,ow-
;
; registres a2-a4,d5-d7 libres !!!!
;
largeur = 224+16	;largeur normale+16 pixels en plus
hauteur = 176+16
;largeur = 320
;hauteur = 200

maskgau	equr	a0
maskdro	equr	a1
source	equr	a5
dest	equr	a6
plans1	equr	d0
plans2	equr	d1
plans3	equr	d2
plans4	equr	d3
mask	equr	d4

next	macro
	lea	-16*8(source),source
	endm
;
; affichage de la colonne  d‚cal‚e
;
; 1) d‚calage de 0
;
x	set	0
	rept	16
	move.l	(source)+,x(dest)
	move.l	(source)+,x+4(dest)
x	set	x+largeur/2
	endr

	lea	largeur*hauteur/2(dest),dest
	next
;
; 2) d‚calage de 4
;
	move.l	#$0FFF0FFF,maskdro
	move.l	#$F000F000,maskgau

x	set	16
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
x	set	x-1
	ifne	x
	lea	largeur/2(dest),dest
	endc
	endr

;	lea	largeur*hauteur/2-largeur*15/2(dest),dest
	next
;
; 3) d‚calage de 8
;
;x	set	0
x	set	largeur*hauteur/2-largeur*15/2
y	set	0
	rept	16
	movep.l	y(source),plans1
	movep.l	plans1,x+1(dest)
	movep.l	y+1(source),plans1
	movep.l	plans1,x+8(dest)
x	set	x+largeur/2
y	set	y+2
	endr

;	lea	largeur*hauteur/2(dest),dest
	add.l	#largeur*hauteur/2*2-largeur*15/2,dest
	next
;
; 4) d‚calage de 12
;
	move.l	#$000F000F,maskdro
	move.l	#$FFF0FFF0,maskgau
x	set	16
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
x	set	x-1
	ifne	x
	lea	largeur/2(dest),dest
	endc
	endr
	add.l	#-3*largeur*hauteur/2-largeur*15/2+largeur/2*16,dest
