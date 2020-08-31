; D‚compression RLE 8 pour le format AVI
; Seb/The Removers

	MC68020

; en entr‚e :
; s_buffer, d_buffer, palette, multiple, l_buffer, largeur, hauteur

; a0 : adresse du buffer … d‚compresser ( s_buffer )
; a1 : adresse du buffer o— d‚compresser ( d_buffer )
; a2 : palette : conversion 256 couleurs -> True Color
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; a4 : fin du buffer
; a5 : adresse courante de l'endroit o— l'on d‚compresse
; d0 : taille du buffer/couleur ( l_buffer )
; d1 : largeur de l'image/taille d'une ligne en octets
; d2 : -largeur
; d3 : hauteur/next
; d4 : mod
; d5 : opcode
; d6 : compteur
; d7 : xml ( x-largeur !! )

decompresse_rle8:
	lea	(a0,d0.l),a4	; fin du buffer source
	move.l	a1,a5
	add.w	d1,d1		; *2 pour le True Color
	add.l	-4(a3,d3.w*4),a5; on commence en bas
	move.w	d1,d2
	clr.w	d4
	clr.w	d7
	neg.w	d2		; -largeur
	clr.w	d5
	move.w	6(a3),d3	; next<-line_size
	move.w	d2,d7		; 0-largeur
	move.w	d3,d1
	sub.w	d2,d3
.decompresse:
	move.b	(a0)+,d4
	bne.s	.mod_diff_0
	move.b	(a0)+,d5
	bne.s	..op_diff_0
.mod_egal_0:
..op_egal_0:
	sub.w	d1,a5
	tst.w	d7		; largeur<x ??
	bgt.s	*+6		; oui, saute au move.w d2,d7
	sub.w	d7,a5		; non, on recule de x
	add.w	d2,a5		; -x=-(x-largeur)-largeur
	move.w	d2,d7
	cmp.l	a0,a4
	bgt.s	.decompresse
	rts
..op_diff_0:
	cmp.w	#2,d5		; test sur un mot pour ne pas ˆtre en sign‚
	beq.s	..op_egal_2
	blt.s	.fin_decompresse	; break
..op_other:
	move.w	d5,d6
	subq.w	#1,d6
	tst.w	d7
	ble.s	..copy
..copy_cr:
	sub.w	d3,a5		; remonte d'une ligne … gauche
	move.w	d2,d7		; r‚init xml
..copy:
	move.b	(a0)+,d4
	move.w	(a2,d4.w*2),(a5)+
	addq.w	#2,d7
	dbgt	d6,..copy
	dble	d6,..copy_cr
	and.w	#%1,d5
	add.w	d5,a0		; ajuste la parit‚ de s_buffer
	cmp.l	a0,a4
	bgt.s	.decompresse
	rts
..op_egal_2:	
	move.b	(a0)+,d4	; delta_x
	add.w	d4,d7
	lea	(a5,d4.w*2),a5
	add.w	d4,d7
	blt.s	..fin_0_2
	sub.w	d1,a5		; x-largeur=q*largeur+(r-largeur)
	add.w	d2,d7		; on recule de q lignes ( ajoute -largeur )
	bgt.s	*-4		; saute au sub.w d1,a5 ( d‚but division euclidienne )
	blt.s	..fin_0_2	; … cause du bgt, si r=0
	sub.w	d3,a5		; on doit encore retrancher largeur
	move.w	d2,d7		; pour revenir … 0-largeur
..fin_0_2:
	move.b	(a0)+,d4	; delta_y
	beq.s	*+6
	sub.l	(a3,d4.w*4),a5
	cmp.l	a0,a4
	bgt.s	.decompresse
	rts
.mod_diff_0:
	move.b	(a0)+,d5
	subq.w	#1,d4
	move.w	(a2,d5.w*2),d0
	tst.w	d7
	ble.s	..uni
..uni_cr:
	sub.w	d3,a5		; monte une ligne au dessus … gauche
	move.w	d2,d7		; r‚init xml	
..uni:
	move.w	d0,(a5)+
	addq.w	#2,d7
	dbgt	d4,..uni
	dble	d4,..uni_cr
..fin_uni:
	clr.w	d4
	cmp.l	a0,a4
	bgt	.decompresse
.fin_decompresse
	rts
