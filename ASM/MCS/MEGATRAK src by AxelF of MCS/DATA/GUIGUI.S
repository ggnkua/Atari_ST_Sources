MOD_BOX=0
MOD_HEXA=0
MOD_DECI=0
TCOLOR=0
	include guw_mac2.s
	*output d:\guigui.prg
	opt	D+

; Decompacteur GIF 87a
; (c) 2 / Novembre / 1993   Gen

	section TEXT
x_max_p=640
y_max_p=543
nb_bits_per_pix=8
nb_o_l=x_max_p*nb_bits_per_pix/8

debut:
*	set_gem
*	mouseoff
*	file_open	1,f_name
*	move.w	d0,fhandle
*	
*	supervisor
*
*	save_palettes
*	reserve_screens 0,res32020016vga
*
*	move.l ecrans,view
*	move.l ecrans+4,no_view

	lea image_pack,a0

next_img:
	bsr unpack_gif

	tst d0
	bmi.s pas_aff_img
	bsr give_palette
	bsr swap
	* wait
pas_aff_img:tst d1
	beq.s next_img

pas_affiche:
*	wait
*	move.l	view,a6
*	file_write	a6,#640*840,fhandle
*	file_close	fhandle
fin:
*	restore_screens
*	restore_palettes
*	user
*	mouseon
fini:
*	restore_gem

*******************************************************
swap:	*lea palette256,a2
	*move.w #256-1,d0
recop_pal:	*move.l (a0)+,(a2)+
	*dbf d0,recop_pal

	*move.l no_view,-(sp)
	*move.b 1(a7),$ffff8201
	*move.b 2(a7),$ffff8203
	*move.b 3(a7),$ffff820d
	*move.l (sp)+,a1
	*move.l view,no_view
	*move.l a1,view
	rts


***************************************************************************
* Routine de d‚compression GIF 87a. Taille maximum des images : 640*542,
* nombre de couleurs : 256
* unpack_gif : routine de d‚compatage proprement dite
*  ParamŠtres:	entr‚e - A0 = adresse du fichier
*		sortie - D0 = 0 image affichable, -1 non
*		       - D1 = 0 encore des images dans le fichier
*		             -1 plus d'image
* give_palette: renvoit dans a0 l'adresse de la palette
* ½ Gen 02/XI/93 
***************************************************************************

CONV_PC:	macro
	move.b (a0)+,\1
	rol.w #8,\1
	move.b (a0)+,\1
	rol.w #8,\1
	endm

unpack_gif:
	tst same_file
	beq.s first_image
	move.l save_ad_next,a0
	bra pas_color_global	; s'il y a plusieurs images dans le fichier

first_image:
; image GIF 87a ?

	cmp.l #'GIF8',(a0)+
	bne fin_ungif
	cmp.w #"7a",(a0)+
	bne fin_ungif

; ANALYSE DU SCREEN DESCRIPTOR
;-----------------------------
	moveq #0,d0
	moveq #0,d1
	CONV_PC d0		; largeur ‚cran
	CONV_PC d1		; hauteur ‚cran

; tient dans l'ecran ?
	cmp.w #x_max_p,d0
	bgt fin_ungif
	cmp.w #y_max_p,d1
	bgt fin_ungif

	movem.w d0/d1,info_screen

	move.b (a0)+,d2
	move.b d2,d3

; 256 couleurs ?
	and.w #$0007,d3	; nb de bits/pixel-1
	cmp.w #(1<<3)-1,d3	; < 256 couleurs ?
	blt fin_ungif

	add.l #2,a0		; passe

	move.w d3,nb_bits_pixel
	move.w d2,info1

	and.b #%10000000,d2
	beq.s pas_color_global

; CONSTRUCTION DE LA PALETTE GLOBALE
;-----------------------------------
	lea palette_globale,a1
	bsr construit_pal

pas_color_global:
	cmp.b #';',(a0)
	beq fin_depack_image

recherche_id:
	cmp.b #',',(a0)+
	beq.s found_id
	cmp.b #'!',-1(a0)
	bne.s recherche_id
	moveq #0,d3
	move.b (a0)+,d3
find_end_ext:
	move.b (a0)+,d3
	beq.s recherche_id
	add.w d3,a0
	bra.s find_end_ext
	
found_id:	moveq #0,d3
	moveq #0,d4
	moveq #0,d5
	moveq #0,d6
	CONV_PC d3		; marge gauche
	CONV_PC d4		; marge haute
	CONV_PC d5		; largeur image
	CONV_PC d6		; hauteur image

	move.b (a0)+,d2
	move.w d2,info2

	movem.w d3/d4/d5/d6,info_image
	and.w #$f,d5
	bne.s fin_ungif

	move d2,d3
	and.b #%10000000,d3
	beq.s use_global_c

	lea palette_locale,a1
	move d2,d3
	and.w #$0007,d3
	bsr construit_pal

use_global_c:
	bsr unpack_lzw

	tst d0
	bmi.s probleme_depack

	bsr pc_atari
	clr d0
probleme_depack:
	moveq #0,d1
	move.w #-1,same_file
	move.l a0,save_ad_next
	rts
fin_depack_image:
fin_ungif:
	moveq #-1,d0
	moveq #-1,d1
	clr.w same_file
	rts

******************************************
give_palette:
	lea palette_globale,a0
	move info2,d0
	and.b #%10000000,d0
	beq.s global_c
	lea palette_locale,a0
global_c	rts

******************************************
* Convertion des images PC au format ATARI
******************************************
rock_roll:	macro
	rept 4
	roxl.l #2,\1	; bit 6 pixel n
	addx.l d3,d3
	roxl.l #2,\1	; bit 4 pixel n
	addx.l d2,d2
	roxl.l #2,\1	; bit 2 pixel n
	addx.l d1,d1
	roxl.l #2,\1	; bit 0 pixel n
	addx.l d0,d0
	endr
	endm

pc_atari:
	*lea	screen,a2
	*bsr	efface_ecran


	lea 	screen,a1
	lea	before,a2
	movem.w info_image,d0-d3
	mulu #nb_o_l,d1
	add.l d1,a2
; image cal‚ … gauche
; largeur multiple de 16
	move d2,d1
	sub.w #x_max_p,d1
	neg d1
	and.w #$fff0,d1
	move d1,a3
	move d3,d7		; hauteur image
	lsr.w #4,d2		; 16 pixels par 16
	subq #1,d2
	move d2,a4
	subq #1,d7

conv_image:
	save d7
	move a4,d6
conv_ligne:	save d6
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	movem.l (a1)+,d4/d5/d6/d7	; pixels 1,2,3,4
	; pixels 5,6,7,8
	; pixels 9,10,11,12
	; pixels 13,14,15,16

	rock_roll d4
	rock_roll d5
	rock_roll d6
	rock_roll d7
	rock_roll d4
	rock_roll d5
	rock_roll d6
	rock_roll d7

	movem.l d0/d1/d2/d3,(a2)
	add.w #4*4,a2
	load d6
	dbf d6,conv_ligne
	add.w a3,a2
	load d7
	dbf d7,conv_image
	rts

efface_ecran:
	move.l #nb_o_l*y_max_p/8-1,d7
eff_ecr:	clr.l (a2)+
	clr.l (a2)+
	dbf d7,eff_ecr
	rts
*************************************
* Depackage proprement dit.
*************************************
unpack_lzw:	moveq #0,d0
	move.b (a0)+,d0	; code size
	moveq #1,d1
	lsl.w d0,d1		; clear code
	move.w d1,d2
	addq #1,d2		; stop code
	move.w d2,d3
	addq #1,d3		; 1er code libre

	add.b #1,d0		; nbre de bits … prendre en compte

*	move.w d1,clear_code
	move.w d1,d4
*	move.w d2,stop_code
	move.w d2,d5
*	move.w d3,first_code
	move.w d3,d6
	add.w d1,d1
	move.w d1,last_code
	move.w d0,first_length

	bsr make_1_table

	lea putain_pc,a1

recop_all_block:
	moveq #0,d7
	move.b (a0)+,d7
	beq fin_recop_pc
	subq.w #1,d7

recop_pc:	move.b (a0)+,-(a1)
	dbf d7,recop_pc
	bra.s recop_all_block

fin_recop_pc:
	lea screen,a2
	lea table_ptrs,a3
	lea putain_pc,a1
	moveq #0,d1

	moveq #0,d2
	sub.l d0,d1
	bfextu (a1){d1:d0},d2

	cmp.w d5,d2		; stop code
	beq erreur		; premier caractŠre = STOP -> erreur

	cmp.w d4,d2		; clear code
	bne.s pas_raz1

raz_table:
	move first_length,d0
	moveq #1,d2
	lsl.w d0,d2
	move d2,last_code
	lsr.w #1,d2
	add.w #2,d2
	move d2,d6		; first_code

	sub.l d0,d1
	bfextu (a1){d1:d0},d2

; premier code dans la table
pas_raz1:	move.b ([a3,d2.w*4]),(a2)+

	move d2,d3

ungif_block:sub.l d0,d1
	bfextu (a1){d1:d0},d2

	cmp.w d5,d2			; stop code
	beq fin_unlzw

	cmp.w d4,d2			; clear code
	beq.s raz_table

	cmp.w d6,d2			; first_code
	bgt erreur
	bne pick_table

	move.l (a3,d3.w*4),a4		; debut chaine
	move.l 4(a3,d3.w*4),d7		; fin chaine
	sub.l a4,d7
	subq #1,d7
	move.b (a4),d3		; premier caractŠre
	move.l (a3,d2.w*4),a6		; nouvelle chaine
recop_strg:	move.b (a4),(a6)+		; construit nouvelle entr‚e
	move.b (a4)+,(a2)+		; depack
	dbf d7,recop_strg
	move.b d3,(a6)+
	move.b d3,(a2)+
	add.w #1,d6			; first_code

	cmp.w last_code,d6
	bne.s pas_chgt_bit

	cmp.w #12,d0
	bne pas_limit_bit
	subq.w #1,d6	; pour eviter des erreurs
	subq #1,d0
	lsr.w last_code

pas_limit_bit:
	addq #1,d0		; on lit 1 bit de plus
	lsl.w last_code

pas_chgt_bit:
	move.l a6,(a3,d6.w*4)	; stock nouvelle entr‚e
	move d2,d3
	bra ungif_block

pick_table:	move.l (a3,d2.w*4),a4
	move.l 4(a3,d2.w*4),d7
	sub.l a4,d7
	subq #1,d7
recop_strg3:move.b (a4)+,(a2)+
	dbf d7,recop_strg3

	move.l (a3,d3.w*4),a4		; debut chaine
	move.l 4(a3,d3.w*4),d7		; fin chaine
	move.l (a3,d6.w*4),a6		; nouvelle chaine
	sub.l a4,d7
	subq #1,d7
recop_strg2:move.b (a4)+,(a6)+		; construit nouvelle entr‚e
	dbf d7,recop_strg2
	move.b ([a3,d2.w*4]),(a6)+
	add.w #1,d6

	cmp.w last_code,d6
	bne.s pas_chgt_bit1

	cmp.w #12,d0
	bne pas_limit_bit1
	subq #1,d6
	subq #1,d0		; on reste sur 12 bits
	lsr.w last_code

pas_limit_bit1:
	addq #1,d0		; on lit 1 bit de plus
	lsl.w last_code

pas_chgt_bit1:
	move.l a6,(a3,d6.w*4)
	move d2,d3
	bra ungif_block
erreur:
fin_unlzw:	moveq #0,d0
	rts
*erreur:	moveq #-1,d0
	rts
*********************************************************************
make_1_table:
	save d0/d1/a5/a6
	lea table_ptrs,a5
	lea table_codes,a6

	move.w #256-1,d0
	moveq #0,d1

make_table:	move.l a6,(a5)+
	move.b d1,(a6)+
	addq #1,d1
	dbf d0,make_table
	move.l a6,(a5)+	; $100
	move.l a6,(a5)+	; $101
	addq #2,a6		; premiŠre place dispo
	move.l a6,(a5)+	; $102 premier code dispo
	load d0/d1/a5/a6
	rts
*********************************************************************
construit_pal:
	moveq #1,d7
	add.w #1,d3
	lsl.w d3,d7
	subq #1,d7
convert_pal:
	move.b (a0)+,d3
	and.b #$fc,d3
	lsl.l #8,d3
	move.b (a0)+,d3
	and.b #$fc,d3
	lsl.l #8,d3
	lsl.l #8,d3
	move.b (a0)+,d3
	and.b #$fc,d3
	move.l d3,(a1)+
	dbf d7,convert_pal
	rts
*********************************************************************
 DATA
f_name	dc.b	'mgt.bin',0
	even
fhandle	dc.w	0
same_file:	dc.w 0
 BSS
save_ad_next:
	ds.l 1
view:	ds.l 1
no_view:	ds.l 1

nb_bits_pixel:
	ds.w 1
info1:	ds.w 1		; info screen descriptor
info2:	ds.w 1		; info image descriptor
info_screen:ds.w 2
info_image:	ds.w 4

*clear_code:	ds.w 1
*stop_code:	ds.w 1
*first_code:	ds.w 1
last_code:	ds.w 1
first_length:
	ds.w 1

	ds.b 640*542
putain_pc:	ds.w 1

palette_globale:
	ds.l 256
palette_locale:
	ds.l 256

table_ptrs:	ds.l 1<<12+2

table_codes:ds.b 256		; 256 couleurs max
	ds.b 1		; clear code
	ds.b 1		; end code
	ds.b	640*960+640*200

before	ds.b	1024
screen:	ds.b 	640*960+1024
fin_p:
 TEXT
;--------------------------
; Format image GIF 87a
;--------------------------
;--------------------------
; GIF signature = "GIF87a"
;--------------------------
; Screen descriptor
;--------------------------
; Global color map
;--------------------------
; ....
;--------------------------
; Image descriptor
;--------------------------
; Local color map
;--------------------------
; raster data
;--------------------------
; ....
;--------------------------
; GIF terminator = ";"
;--------------------------
;--------------------------

;--------------------------
; Screen descriptor
;--------------------------
; 7 6 5 4 3 2 1 0
;--------------------------
; Screen width (LSB-HSB)
;--------------------------
; Screen Height (LSB-HSB)
;--------------------------
;|M| cr  |0|pixel|
; M=1  > Global color map
; cr+1 = # bits of color resolution
; pixel+1 = # bits/pixel in image
;--------------------------
; Background  = color index of screen background
;--------------------------
; 0 0 0 0 0 0 0 0
;--------------------------

;--------------------------
; Global color map
;--------------------------
; Red color 0 (1 byte)
;--------------------------
; Green color 0
;--------------------------
; Blue color 0
;--------------------------
; Red color 1
;--------------------------

;--------------------------
; Image descriptor
;--------------------------
; 7 6 5 4 3 2 1 0
;--------------------------
; ',' = image separator
;--------------------------
; Image left (LSB-HSB)
;--------------------------
; Image top (LSB-HSB)
;--------------------------
; Image width (LSB-HSB)
;--------------------------
; Image height (LSB-HSB)
;--------------------------
;|M|I|0|0|0|pixel|
; M=0 use global color map (ignore pixel)
; I=1 image interlace ( see doc ...)
; pixel+1= # bits/pixel for this image
;--------------------------

;--------------------------
; Raster data
;--------------------------
; 7 6 5 4 3 2 1 0
;--------------------------
; Code size
;--------------------------
; ....
;--------------------------
; Block byte count
;--------------------------
; Data byte
;--------------------------
; ....
;--------------------------
; 0 0 0 0 0 0 0 0
;--------------------------
*********************************************************************
	section DATA
 even
image_pack:	incbin mgt4.gif

	section BSS
 even
	END