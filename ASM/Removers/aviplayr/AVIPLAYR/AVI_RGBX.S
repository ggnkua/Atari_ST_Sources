; RGB 2/4/8/16/24 pour le format AVI
; Seb/The Removers

	MC68020

*********
* RGB 2 *
*********
; en entr‚e :
; s_buffer, d_buffer, palette, multiple, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( adresse courante )
; a2 : palette : conversion 256 couleurs -> True Color
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d0 : indice de boucle ( largeur )
; d1 : largeur de l'image
; d3 : hauteur/next
; d4 : index de couleur
; d5 : alignement

decompresse_rgb2:
	add.l	-4(a3,d2.w*4),a1; on commence en bas
	add.w	#15,d1		; on s'aligne au multiple de 16
	and.w	#$fff0,d1	; juste sup‚rieur
	move.w	d1,d3		; largeur
	add.w	6(a3),d3	; largeur d'une ligne
	add.w	d1,d3
	subq.w	#1,d2
	lsr.w	#3,d1
	move.w	(a2),d6
	subq.w	#1,d1
	swap	d1
	move.w	2(a2),d7
.bcl
	bfextu	d1{0:16},d0
.bcl2:
	move.b	(a0)+,d4
	REPT	8
	move.w	d6,d1
	lsl.b	d4
	bcc.s	*+4
	move.w	d7,d1
	move.w	d1,(a1)+
	ENDR
	dbf	d0,.bcl2
	sub.w	d3,a1
	dbf	d2,.bcl
	rts


*********
* RGB 4 *
*********
; en entr‚e :
; s_buffer, d_buffer, palette, multiple, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( adresse courante )
; a2 : palette : conversion 256 couleurs -> True Color
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d0 : indice de boucle ( largeur )
; d1 : largeur de l'image
; d3 : hauteur/next
; d4 : index de couleur
; d5 : alignement

decompresse_rgb4:
	add.l	-4(a3,d2.w*4),a1; on commence en bas
	add.w	#15,d1		; on s'aligne au multiple de 16
	and.w	#$fff0,d1	; juste sup‚rieur
	move.w	d1,d3		; largeur
	add.w	6(a3),d3	; largeur d'une ligne
	add.w	d1,d3
	subq.w	#1,d2
	lsr.w	d1
	clr.l	d4
	subq.w	#1,d1
.bcl
	move.w	d1,d0
.bcl2:
	move.b	(a0)+,d4
	ror.l	#4,d4
	move.w	(a2,d4.w*2),(a1)+
	bfextu	d4{0:4},d4
	move.w	(a2,d4.w*2),(a1)+
	dbf	d0,.bcl2
	sub.w	d3,a1
	dbf	d2,.bcl
	rts


*********
* RGB 8 *
*********
; en entr‚e :
; s_buffer, d_buffer, palette, multiple, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( adresse courante )
; a2 : palette : conversion 256 couleurs -> True Color
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d0 : indice de boucle ( largeur )
; d1 : largeur de l'image
; d3 : hauteur/next
; d4 : index de couleur
; d5 : alignement

decompresse_rgb8:
	add.l	-4(a3,d2.w*4),a1; on commence en bas
	addq.w	#3,d1
	and.w	#$fffc,d1
	move.w	d1,d3		; largeur
	add.w	6(a3),d3	; largeur d'une ligne
	add.w	d1,d3
	subq.w	#1,d2
	subq.w	#1,d1
	clr.w	d4
.bcl
	move.w	d1,d0
.bcl2:
	move.b	(a0)+,d4
	move.w	(a2,d4.w*2),(a1)+
	dbf	d0,.bcl2
	sub.w	d3,a1
	dbf	d2,.bcl
	rts

**********
* RGB 16 *
**********
; en entr‚e :
; s_buffer, d_buffer, convert, multiple, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( adresse courante )
; a2 : palette : conversion True Color 15 bits -> True Color 16 bits
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d0 : indice de boucle ( largeur )
; d1 : largeur de l'image
; d3 : hauteur/next
; d4 : couleur

decompresse_rgb16:
	add.l	-4(a3,d2.w*4),a1; on commence en bas
	move.w	d1,d3
	add.w	6(a3),d3	; largeur d'une ligne
	add.w	d1,d3
	subq.w	#1,d2
	subq.w	#1,d1
.bcl
	move.w	d1,d0
.bcl2:
	move.w	(a0)+,d4
	move.w	(a2,d4.w*2),(a1)+
	dbf	d0,.bcl2
	sub.w	d3,a1
	dbf	d2,.bcl
	rts

**********
* RGB 24 *
**********
; en entr‚e :
; s_buffer, d_buffer, multiple, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( adresse courante )
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d0 : indice de boucle ( largeur )
; d1 : largeur de l'image
; d3 : hauteur/next
; d4 : couleur

decompresse_rgb24:
	add.l	-4(a3,d2.w*4),a1; on commence en bas
	move.w	d1,d3
	add.w	6(a3),d3	; largeur d'une ligne
	move.w	d1,d5
	add.w	d1,d3
	add.w	d5,d5
	add.w	d1,d5		; d5=largeur*3
	and.w	#%11,d5
	neg.w	d5
	addq.w	#4,d5
	and.w	#%11,d5
	clr.w	d6
	subq.w	#1,d2
	subq.w	#1,d1
.bcl
	move.w	d1,d0
.bcl2:
	move.b	(a0)+,d4
	lsr.w	#3,d4
	bfins	d4,d6{27:5}
	move.b	(a0)+,d4
	lsr.w	#2,d4
	bfins	d4,d6{21:6}
	move.b	(a0)+,d4
	lsr.w	#3,d4
	bfins	d4,d6{16:5}
	move.w	d6,(a1)+
	dbf	d0,.bcl2
	add.w	d5,a0
	sub.w	d3,a1
	dbf	d2,.bcl
	rts

**********
* RGB 32 *
**********
; en entr‚e :
; s_buffer, d_buffer, multiple, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( adresse courante )
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; d0 : indice de boucle ( largeur )
; d1 : largeur de l'image
; d3 : hauteur/next
; d4 : couleur

decompresse_rgb32:
	add.l	-4(a3,d2.w*4),a1; on commence en bas
	move.w	d1,d3
	add.w	6(a3),d3	; largeur d'une ligne
	move.w	d1,d5
	add.w	d1,d3
	add.w	d5,d5
	add.w	d5,d5		; d5=largeur*4
	and.w	#%11,d5
	neg.w	d5
	addq.w	#4,d5
	and.w	#%11,d5
	clr.w	d6
	subq.w	#1,d2
	subq.w	#1,d1
.bcl
	move.w	d1,d0
.bcl2:
	move.b	(a0)+,d4
	lsr.w	#3,d4
	bfins	d4,d6{27:5}
	move.b	(a0)+,d4
	lsr.w	#2,d4
	bfins	d4,d6{21:6}
	move.b	(a0)+,d4
	lsr.w	#3,d4
	addq.w	#1,a0
	bfins	d4,d6{16:5}
	move.w	d6,(a1)+
	dbf	d0,.bcl2
	add.w	d5,a0
	sub.w	d3,a1
	dbf	d2,.bcl
	rts
