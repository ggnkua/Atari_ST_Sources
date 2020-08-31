; D‚compression Animator Pro FLC & FLI pour le format AVI
; Seb/The Removers

	MC68020
	
; en entr‚e :
; s_buffer, d_buffer, palette, multiple, largeur, hauteur

; A noter que la palette peut-ˆtre modifi‚e !!!

; a0 : adresse du buffer … d‚compresser
; a1 : adresse du buffer o— d‚compresser
; a2 : palette : conversion 256 couleurs -> True Color
; a3 : adresse d'un tableau contenant les multiples de la largeur d'une
; ligne en octets ( longs mots )
; a5 : adresse courante de l'endroit o— l'on d‚compresse
; d0 : nb chunks
; d1 : largeur de l'image
; d3 : hauteur/next

; les macros IMW et IML sont suppos‚es exister.

FLI_COLOR256:	equ	$0400
FLI_SS2:	equ	$0700
FLI_COLOR:	equ	$0b00
FLI_LC:		equ	$0c00
FLI_BLACK:	equ	$0d00
FLI_BRUN:	equ	$0f00
FLI_COPY:	equ	$1000
FLI_PSTAMP:	equ	$1200

decompresse_flc:
	addq.l	#4,a0		; saute size_frame
	cmp.w	#$FAF1,(a0)+	; v‚rification du format
	beq.s	*+4
	rts
	move.w	(a0)+,d0	; nombre de chunks
	IM.w	d0		; que l'on convertit
	addq.l	#8,a0
	subq.w	#1,d0
	bge.s	*+4
	rts
.traite_chunk:
	move.l	(a0)+,d2	; taille chunk
	IM.l	d2		; conversion
	move.w	(a0)+,d4	; type de chunk au format Intel
	lea	-6(a0,d2.l),a6	; offset chunk suivant ( th‚orique )
	cmp.w	#FLI_COLOR256,d4
	beq.s	.fli_color256
	cmp.w	#FLI_SS2,d4
	beq.s	.fli_ss2
	cmp.w	#FLI_COLOR,d4
	beq	.fli_color
	cmp.w	#FLI_LC,d4
	beq	.fli_lc
	cmp.w	#FLI_BLACK,d4
	beq	.fli_black
	cmp.w	#FLI_BRUN,d4
	beq	.fli_brun
	cmp.w	#FLI_COPY,d4
	beq	.fli_copy
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts

.fli_color256:
	move.w	(a0)+,d7
	IM.w	d7
	clr.w	d2
	subq.w	#1,d7
	blt.s	.end_fli_color256
..color256_packet:
	add.b	(a0)+,d2
	lea	(a2,d2.w*2),a5
	clr.w	d4
	move.b	(a0)+,d4
	subq.b	#1,d4		; astuce du format byte
	add.w	d4,d2
	addq.w	#1,d2
..color256_bcl:
	move.b	(a0)+,d5
	lsr.w	#3,d5
	bfins	d5,d6{16:5}
	move.b	(a0)+,d5
	lsr.w	#2,d5
	bfins	d5,d6{21:6}
	move.b	(a0)+,d5
	lsr.w	#3,d5
	bfins	d5,d6{27:5}
	move.w	d6,(a5)+
	dbf	d4,..color256_bcl	
	dbf	d7,..color256_packet
.end_fli_color256:
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts

.fli_ss2:
	move.w	(a0)+,d7	; nb de lignes
	lea	-2(a1,d1.w*2),a4; dernier octet de la ligne
	IM.w	d7		; on convertit
	move.l	a1,a5		; adresse dest
	bfins	d1,d1{0:16}	; on sauve d1
	bfins	d3,d3{0:16}	; on sauve d3
	subq.w	#1,d1		; on calcule le delta entre le premier
	clr.w	d4
	neg.w	d1		; pixel et le dernier de la ligne
	move.w	6(a3),d5
	clr.l	d6
	subq.w	#1,d7
.fli_ss2_bcl:
	move.w	(a0)+,d6	; mot de controle
	IM.w	d6		; conversion
	bmi.s	.fli_ss2_other	; test bit 15
.fli_ss2_packets:
	subq.w	#1,d6
	bmi.s	.fli_ss2_next_line
.fli_ss2_lot:
	move.b	(a0)+,d4
	lea	(a5,d4.w*2),a5
	clr.w	d3
	move.b	(a0)+,d3
	bpl.s	.fli_ss2_copy
.fli_ss2_unpack:
	neg.b	d3
	clr.l	d2
	move.w	(a0)+,d2
	ror.l	#8,d2
	move.w	(a2,d2.w*2),d2
	swap	d2
	ror.w	#8,d2
	move.w	(a2,d2.w*2),d2
	subq.w	#1,d3
.fli_ss2_unpack_bcl:
	move.l	d2,(a5)+
	dbf	d3,.fli_ss2_unpack_bcl
	dbf	d6,.fli_ss2_lot
.fli_ss2_next_line:
	add.w	d5,a4		; fin de ligne suivante
	lea	(a4,d1.w*2),a5	; d‚but de ligne suivante
	dbf	d7,.fli_ss2_bcl
	swap	d1		; on restaure d1
	swap	d3		; on restaure d3
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts
.fli_ss2_copy:
	subq.w	#1,d3
	clr.l	d2
.fli_ss2_copy_bcl:
	move.w	(a0)+,d2
	ror.l	#8,d2
	move.w	(a2,d2.w*2),(a5)+
	bfextu	d2{0:8},d2
	move.w	(a2,d2.w*2),(a5)+
	dbf	d3,.fli_ss2_copy_bcl
	dbf	d6,.fli_ss2_lot
	add.w	d5,a4		; fin de ligne suivante
	lea	(a4,d1.w*2),a5	; d‚but de ligne suivante
	dbf	d7,.fli_ss2_bcl
	swap	d1		; on restaure d1
	swap	d3		; on restaure d3
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts
.fli_ss2_other:	
	lsl.w	#2,d6		; test bit 14 et multiplication par 4 !!!
	bcs.s	.fli_ss2_skip	; s'il est mis -> skip
.fli_ss2_last:
	bfextu	d6{22:8},d6
	move.w	(a2,d6.w*2),(a4)
	bra	.fli_ss2_bcl
.fli_ss2_skip:
	bge.s	*+4
	neg.w	d6		; valeur absolue
	add.l	(a3,d6.w),a4	; astuce : d6 est d‚j… multipli‚ par 4
	lea	(a4,d1.w*2),a5	; sinon, il faudrait (a3,d6.w*4)
	bra	.fli_ss2_bcl

.fli_color:
	move.w	(a0)+,d7
	IM.w	d7
	clr.w	d2
	subq.w	#1,d7
	blt.s	.end_fli_color
..color_packet:
	add.b	(a0)+,d2
	lea	(a2,d2.w*2),a5
	clr.w	d4
	move.b	(a0)+,d4
	subq.b	#1,d4		; astuce du format byte 
	add.w	d4,d2
	addq.w	#1,d2
..color_bcl:
	move.b	(a0)+,d5
	lsr.w	d5
	bfins	d5,d6{16:5}
	move.b	(a0)+,d5
	bfins	d5,d6{21:6}
	move.b	(a0)+,d5
	lsr.w	d5
	bfins	d5,d6{27:5}
	move.w	d6,(a5)+
	dbf	d4,..color_bcl	
	dbf	d7,..color_packet
.end_fli_color:
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts

.fli_lc:
	move.l	a1,a5
	bfins	d1,d1{0:16}	; on sauve d1
	move.l	(a0)+,d7	; lit delta_y et le nb de lignes … d‚packer
	IM.l	d7
	add.l	(a3,d7.w*4),a5
	swap	d7
	subq.w	#1,d7
	blt.s	.end_fli_lc
	move.w	6(a3),d5		; largeur ligne en octets
	clr.w	d6
.fli_lc_bcl:
	lea	(a5),a4
	clr.w	d4
	move.b	(a0)+,d4
	subq.w	#1,d4
	bpl.s	.fli_lc_lot
	add.w	d5,a5
	dbf	d7,.fli_lc_bcl
	swap	d1		; on restaure d1
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts
.fli_lc_lot:
	clr.w	d2
	move.b	(a0)+,d2
	lea	(a4,d2.w*2),a4
	move.b	(a0)+,d2
	bmi.s	.fli_lc_unpack
.fli_lc_copy:
	subq.w	#1,d2
.fli_lc_copy_bcl:
	move.b	(a0)+,d6
	move.w	(a2,d6.w*2),(a4)+
	dbf	d2,.fli_lc_copy_bcl
	dbf	d4,.fli_lc_lot
	add.w	d5,a5
	dbf	d7,.fli_lc_bcl
	swap	d1		; on restaure d1
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts
.fli_lc_unpack:
	neg.b	d2
	subq.w	#1,d2
	move.b	(a0)+,d6
	move.w	(a2,d6.w*2),d1
.fli_lc_unpack_bcl:
	move.w	d1,(a4)+
	dbf	d2,.fli_lc_unpack_bcl
	dbf	d4,.fli_lc_lot
	add.w	d5,a5
	dbf	d7,.fli_lc_bcl	
.end_fli_lc:	
	swap	d1		; on restaure d1
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts

.fli_black:
	move.l	a1,a5
	move.w	d3,d4
	subq.w	#1,d4
	move.w	d1,d2
	subq.w	#1,d2
	move.w	6(a3),d5
	sub.w	d1,d5
	sub.w	d1,d5
	move.w	(a2),d7	; couleur 0
.fli_black_bcl:
	move.w	d2,d6
.fli_black_line:
	move.w	d7,(a5)+
	dbf	d6,.fli_black_line
	add.w	d5,a5
	dbf	d4,.fli_black_bcl
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts

.fli_brun:
	bfins	d3,d3{0:16}	; sauvons D3.w
	move.l	a1,a5
	subq.w	#1,d3		; nb de lignes
	clr.w	d7
	move.w	6(a3),d5
	sub.w	d1,d5
	sub.w	d1,d5
.fli_brun_bcl:
	move.w	d1,d6
	addq.w	#1,a0		; octet insignifiant avec le FLC
.fli_brun_lot:
	clr.w	d2
	move.b	(a0)+,d2	; code de controle
	bmi.s	.fli_brun_copy
.fli_brun_unpack:
	move.b	(a0)+,d7	; ici, motif uni
	move.w	(a2,d7.w*2),d4
	sub.w	d2,d6
	subq.w	#1,d2
.fli_brun_unpack_bcl:
	move.w	d4,(a5)+
	dbf	d2,.fli_brun_unpack_bcl
	tst.w	d6
	bgt.s	.fli_brun_lot
	add.w	d5,a5
	dbf	d3,.fli_brun_bcl
	swap	d3		; Restaure D3
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts
.fli_brun_copy:
	neg.b	d2		; et l…, on recopie bˆtement
	sub.w	d2,d6
	subq.w	#1,d2
.fli_brun_copy_bcl:
	move.b	(a0)+,d7
	move.w	(a2,d7.w*2),(a5)+
	dbf	d2,.fli_brun_copy_bcl
	tst.w	d6
	bgt.s	.fli_brun_lot
	add.w	d5,a5
	dbf	d3,.fli_brun_bcl		
	swap	d3		; Restaure D3
	lea	(a6),a0
	dbf	d0,.traite_chunk
	rts

.fli_copy:
	move.l	a1,a5
	move.w	d3,d4
	subq.w	#1,d4
	move.w	d1,d2
	subq.w	#1,d2
	move.w	6(a3),d5
	sub.w	d1,d5
	sub.w	d1,d5
	clr.w	d7
.fli_copy_bcl:
	move.w	d2,d6
.fli_copy_line:
	move.b	(a0)+,d7
	move.w	(a2,d7.w*2),(a5)+
	dbf	d6,.fli_copy_line
	add.w	d5,a5
	dbf	d4,.fli_copy_bcl
	lea	6(a6),a0
	dbf	d0,.traite_chunk
	rts
