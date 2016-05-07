	output d:\assemble\sources.v40\wax_gifv\wax_gifv.acx

;OPT_FULL_PATHNAMES

	lea objet_application,a1

	include wax_gifv.def
	include visual40.s
	include wax_gifv.hs
	include wax_gifv.obj

	comment HEAD=7
	section TEXT

	; ce programme r‚pond aux quatre lois de l'ouverture :
	; 1) ligne de commande
	; 2) si pas de ligne de commande : s‚lecteur de fichiers
	;    et si annule, CTRL+O -> redemande
	; 3) en accessoire : un click appelle le s‚lecteur
	; 4) en accessoire, supporte le VA_START

*--------------------------------------------------------------------------*

my_inits:	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne.s .prg
	rts

.prg:	tst d0
	bne open_object		; cmd line present

acc_open:
menu_open:
	lea texte_gif,a0		; 35 chars max.
	lea mask_gif,a1		; 18 caracteres max
	move.l #0,a2
	bsr FILE_SELECTOR
	tst d0
	ble .annule

	move.l a2,a0
	bra.s open_object

.annule:	rts

info:	lea objet_fenetre0,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

routine_menu_quit:
app_term:
acc_close:
	; quoi qu'il arrive, il y a 1 delete all win

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne VISUAL40_END

	rts

other_message:
	cmp.w #VA_START,d0
	beq.s .va_start
	rts

.va_start:	move.l 6(a0),a0

	save.l a0
	bsr GWVA_APP_OBJ_PRG_ACC_OPEN_VSTATION
	load.l a0
	tst d7
	bge.s open_object

	rts	; pas b infinie si jamais 1 vstation se libŠre ?

*--------------------------------------------------------------------------*

open_object:		; ici : a0 pointeur sur un pathname !

	move.l a0,ptr_pathname

	move #RAM_TT_ST,d0
	bsr LOAD_FILE_IN_MEM
	tst.l d0
	ble erreur_load

	move.l a0,gif_loaded_address
	move.l d0,gif_loaded_length

	MXALLOC #RAM_TT_ST,#256*4
	tst.l d0
	ble err_malloc
	move.l d0,gif_palette

	MXALLOC #RAM_TT_ST,#200000	; 640*480+4096
	tst.l d0
	ble err_malloc
	move.l d0,strings

	move.l gif_loaded_length,d0
	bclr #0,d0
	MXALLOC #RAM_TT_ST,d0		; au header + palette prŠs
	tst.l d0
	ble err_malloc
	move.l d0,gif_buff
	add.l gif_loaded_length,d0
	move.l d0,fin_gif_buff

	graf_mouse #BUSY_BEE
	; d‚but du d‚codage

	move.l gif_loaded_address,a0

	clr.l d0
	bsr get_left
	bsr get_left
	bsr get_left
	cmp.l #'GIF',d0
	bne err_not_gif
	addq #3,a0

	bsr get_word
	move d0,gif_loaded_width
	bsr get_word
	move d0,gif_loaded_height

	move.b (a0)+,d0
	move.b d0,d1
	and.w #%111,d1
	add #1,d1
	move d1,gif_loaded_nb_planes
	moveq #1,d2
	lsl.w d1,d2
	move d2,gif_loaded_nb_colors
*	cmp.b #%111,d1		; no use of CR
*	bne err_not_256_coul
	btst #7,d0
	beq.s .not_global_coul
	bsr get_left		; backgroud coul
	bsr get_left		; 0.b
	bsr create_pal
	bra.s .continue
.not_global_coul:
	bsr get_left		; backgroud coul
	bsr get_left		; 0.b
.continue:

find_separator:
	cmp.b #',',(a0)+
	bne.s find_separator

	bsr get_word		; d‚calage du bord gauche
	bsr get_word		; d‚calage / haut

	bsr get_word
*	cmp.w #640,d0
*	bgt pas_640
*	move d0,gif_loaded_width
	bsr get_word
*	cmp.w #480,d0
*	bgt pas_480
*	move d0,gif_loaded_height

	move.b (a0)+,d0
	btst #7,d0
	beq.s .not_local		; ignore pixel
*	move.b d0,d1
*	and.b #%111,d1
*	cmp.b #%111,d1
*	bne err_not_256_coul
	btst #6,d0
	bne err_interlaced
	bsr create_pal
.not_local:
	move.b (a0)+,d0
	cmp.b #8,d0
	bne err_not_8_bits

	bsr prepare_lzh_buff		; default strings 0 to 255

	bsr make_gif_buff		; d0.l longeur buff

	MFREE gif_loaded_address	; plus besoin
	clr.l gif_loaded_address

	move gif_loaded_width,d0
	add #15,d0
	divu #16,d0
	mulu #16,d0			; multiple de 16
	mulu gif_loaded_nb_planes,d0
	divu #8,d0			; donc divisible par 8
	mulu gif_loaded_height,d0
	add.l #639+1+1024,d0
	MXALLOC #RAM_TT_ST,d0
	tst.l d0
	ble err_malloc
	move.l d0,gif_img

	bsr decompact_buff

	save.l a1
	
	MFREE strings
	clr.l strings
	move.l #1,d0
	bsr GWVA_APP_OBJ_PRG_WAIT_EVENTS

	MFREE gif_buff
	clr.l gif_buff
	load.l a1

	move.l gif_img,a0
	move.w gif_loaded_width,d0
	mulu gif_loaded_height,d0
	add.l d0,a0
	cmp.l a0,a1
	beq.s .no_error

	move #ALERT_UNPACK_ERR,d0
	move #1,d1
	bsr RSC_ALERT_BOX

.no_error
	move gif_loaded_width,d0
	add #15,d0
	divu #16,d0
	mulu #16,d0			; multiple de 16
	mulu gif_loaded_nb_planes,d0
	divu #8,d0			; donc divisible par 8
	move d0,gif_loaded_width_rounded_16
	mulu gif_loaded_height,d0
	MXALLOC #RAM_TT_ST,d0
	tst.l d0
	ble err_malloc
	move.l d0,gif_for_screen

	bsr put_in_screen_format

	MFREE gif_img
	clr.l gif_img

	tst d7
	bge.s .ok

	MFREE gif_for_screen
	clr.l gif_for_screen
	graf_mouse #ARROW
	rts
.ok:
	*---------

	move.l #fin_objet_fenetre_clone-objet_fenetre_clone,d0
	MXALLOC #RAM_TT_ST,d0
	tst.l d0
	ble err_malloc		; plus de m‚moire

	move.l d0,a1

	lea objet_fenetre_clone,a0
	move.l #fin_objet_fenetre_clone-objet_fenetre_clone,d1
.copy:	move.b (a0)+,(a1)+
	subq.l #1,d1
	bne.s .copy

	move.l d0,a0

	add.l d0,GWVA_WIND_OBJ_NAME(a0)	; reloge
	add.l d0,GWVA_WIND_OBJ_INFO(a0)
	add.l d0,GWVA_WIND_OBJ_SPEC_PTR(a0)
	move.l d0,GWVA_WIND_OBJ_USER_PTR1(a0)

	move gif_loaded_width,GWVA_WIND_OBJ_FIRST_W(a0)
	move gif_loaded_height,GWVA_WIND_OBJ_FIRST_H(a0)

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move gif_loaded_width,GWVA_WBITM_OBJ_IMG_WIDTH(a1)
	move gif_loaded_height,GWVA_WBITM_OBJ_IMG_HEIGHT(a1)
	move.l gif_for_screen,GWVA_WBITM_OBJ_DATA_PTR(a1)
	move.l gif_palette,GWVA_WBITM_OBJ_PAL_PTR(a1)
	move.w #8,GWVA_WBITM_OBJ_NBR_BITPLANES(a1)

	move.l ptr_pathname,a2
	move.l GWVA_WIND_OBJ_INFO(a0),a3
	COPY_STRING_0 a2,a3

	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	tst d7
	bge.s .opened_ok

	; si la cr‚ation ‚choue ... la m‚moire a ‚t‚ lib‚r‚e
	; soit : DATA_PTR, PAL_PTR et USR_PTR1

	move #ALERT_NO_MORE_WI,d0
	move #1,d1
	bsr RSC_ALERT_BOX

.opened_ok:
.no:
	graf_mouse #ARROW
	rts

*--------------------------------------------------------------------------*

get_left:	lsl.l #8,d0
	move.b (a0)+,d0
	rts

get_word:	move.b (a0)+,d1		; lsb (format PC de merde)
	move.b (a0)+,d0		; msb
	lsl.w #8,d0
	move.b d1,d0
	rts

*--------------------------------------------------------------------------*

create_pal:	move gif_loaded_nb_colors,d1
	subq #1,d1
	move.l gif_palette,a1
.make_rvb:	bsr.s get_left
	bsr.s get_left
*	lsl.l #8,d0
	bsr.s get_left
	move.l d0,(a1)+
	dbf d1,.make_rvb
	rts

*--------------------------------------------------------------------------*

prepare_lzh_buff:		; pr‚pare la table de pointeurs
	lea string_table,a2
	move.l strings,a3
	clr d0
	moveq #1,d1
.create:	move.l a3,(a2)+
	move.l d1,(a2)+
	move.b d0,(a3)+
	addq #1,d0
	cmp #256,d0
	bne.s .create
	move.l #string_table+(256+2)*8,ptr_table
	move.l strings,a2
	add.w #256,a2
	move.l a2,ptr_strings
	move.w #256+2,current_max_code
	rts

*--------------------------------------------------------------------------*
make_gif_buff:
	clr.l d0			; compte longeur totale
	move.l fin_gif_buff,a1

.recomm:	moveq #0,d1
	move.b (a0)+,d1
	beq.s .finished
	subq #1,d1
	add.l d1,d0
.copy_cutted:move.b (a0)+,-(a1)		; recopie … l'envers
	dbf d1,.copy_cutted		; pour r‚cup‚rer les
	bra.s .recomm		; bits dans le bon sens
.finished:	rts

*--------------------------------------------------------------------------*
decompact_buff:
	move.l fin_gif_buff,a0
	move.l gif_img,a1
	lea string_table,a6
	clr.l d1
	clr.l d2

	move.l #0,d7		; offset in bits field
raz_code_send:
	move.l #9,d6		; code start size

find_1st:	sub.l d6,d7
	bfextu (a0){d7:d6},d1		; offset:length

	cmp.w #%100000000,d1
	beq.s find_1st		; on a d‚ja	fait un raz

	move.b ([a6,d1*8]),(a1)+	; 1er a une longeur de 1

all_bytes:	sub.l d6,d7
	bfextu (a0){d7:d6},d2		; offset:length

	cmp.w #%100000000,d2
	bne.s pas_raz
	bsr prepare_lzh_buff
	bra.s raz_code_send
pas_raz:
	cmp.w #%100000001,d2		; c'est un code compress‚
	beq finishes

	cmp current_max_code,d2
	blt.s cod_exists
	bgt errare_humanum

	; le code n'existe pas dans la table : on prend le vieux

	move.l (a6,d1*8),a2		; ad. chaine
	move.l 4(a6,d1*8),d3		; nb.

	move.l ptr_strings,a3		; <=> allocation dynamique
	move.l ptr_table,a4
	move.l a3,(a4)+
	addq.l #1,d3
	move.l d3,(a4)+
	move.l a4,ptr_table		; ad. dans table des strings

	subq #1+1,d3
copy_new2:	move.b (a2)+,(a3)+
	dbf d3,copy_new2		; copy old

	move.b ([a6,d1*8]),(a3)+	; copy 1st of old

	move.l a3,ptr_strings

	move current_max_code,d2	; ne sert plus
	move.w d2,d1		; old=new
	move d2,d0
	addq #1,d0
	move d0,current_max_code
	and d2,d0
	bne.s not_depass2
	addq.l #1,d6		; ruse des dieux pour trouver

	cmp.w #13,d6		; pas sur 13 bits SVP
	blt.s pas_coolax
	move.w #12,d6
pas_coolax:

not_depass2:			; le d‚passemnent du code bital

	move.l (a6,d2*8),a2		; ad. chaine
	move.l 4(a6,d2*8),d3		; nb.
	subq #1,d3
copy_string2:
	move.b (a2)+,(a1)+		; d‚pack
	dbf d3,copy_string2

	bra all_bytes

cod_exists:	; in the table

	move.l (a6,d2*8),a2		; ad. chaine
	move.l 4(a6,d2*8),d3		; nb.
	subq #1,d3
copy_string:
	move.b (a2)+,(a1)+		; d‚pack
	dbf d3,copy_string

	move.l (a6,d1*8),a2		; ad. chaine
	move.l 4(a6,d1*8),d3		; nb.

	move.l ptr_strings,a3		; <=> allocation dynamique
	move.l ptr_table,a4
	move.l a3,(a4)+
	addq #1,d3
	move.l d3,(a4)+
	move.l a4,ptr_table		; ad. dans table des strings

	subq #1+1,d3
copy_new:	move.b (a2)+,(a3)+
	dbf d3,copy_new		; copy old

	move.b ([a6,d2*8]),(a3)+	; copy 1st of new

	move.l a3,ptr_strings

	move.w d2,d1		; old=new
	move current_max_code,d2	; ne sert plus
	move d2,d0
	addq #1,d2
	and d2,d0
	bne.s not_depass
	addq.l #1,d6		; ruse des dieux pour trouver

	cmp.w #13,d6		; pas sur 13 bits SVP
	blt.s pas_coolax2
	move.w #12,d6
pas_coolax2:

not_depass:	move d2,current_max_code	; le d‚passemnent du code bital
	bra all_bytes

finishes:	rts

errare_humanum:
	rts

*--------------------------------------------------------------------------*
put_in_screen_format:
	move gif_loaded_nb_planes,d0
	cmp.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d0
	bne.s cannot_do

	move.l gif_for_screen,a0
	move.w gif_loaded_width_rounded_16,d0
	mulu gif_loaded_height,d0

.clrs:
	rept 4
	clr.l (a0)+
	endr
	sub.l #16,d0
	bne.s .clrs

	move.l gif_img,a0
	move.l gif_for_screen,a1
	move gif_loaded_height,d7
	subq #1,d7
ver:	move gif_loaded_width,d6

hor:	moveq #16-1,d5

	sub #16,d6
	bge.s .sup_16
	add d6,d5			; ruse !
.sup_16:
	move.w #%1000000000000000,d1		; motif
par_16:
	move.b (a0)+,d0
	move gif_loaded_nb_planes,d4
	subq #1,d4
planes:	lsl.b #1,d0				; lsl.b
	bcc.s clear
	or.w d1,(a1,d4*2)
clear:	dbf d4,planes

	lsr.w #1,d1
	dbf d5,par_16

	add.l #2*8,a1
	tst d6
	bgt hor

	dbf d7,ver
	clr d7
	rts

cannot_do:	moveq #-1,d7
	rts
*--------------------------------------------------------------------------*

erreur_load:graf_mouse #ARROW
	move #ALERT_FILE_NOTF,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	bra.s rends_mem

err_malloc:	graf_mouse #ARROW
	move #ALERT_NOT_ENOUGH,d0
	move #1,d1
	bsr RSC_ALERT_BOX

rends_mem:	MFREE gif_loaded_address
	clr.l gif_loaded_address

	MFREE strings
	clr.l strings

	MFREE gif_buff
	clr.l gif_buff

	MFREE gif_img
	clr.l gif_img

	MFREE gif_for_screen
	clr.l gif_for_screen

	MFREE gif_palette
	clr.l gif_palette

	rts

err_not_gif:
err_not_256_coul:
err_interlaced:
err_not_8_bits:
	graf_mouse #ARROW

	move #ALERT_NOT_GOOD_F,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	rts

*--------------------------------------------------------------------------*
menu_save_palette:

	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi .the_top_windows_is_not_mine

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap

	save.l a0
	lea texte_pal,a0		; 35 chars max.
	lea mask_pal,a1		; 18 caracteres max
	move.l #0,a2
	bsr FILE_SELECTOR
	load.l a0
	tst d0
	ble .annule

	save.l a0
	FILE_OPEN write,(a2),d7
	load.l a0
	tst d7
	bmi.s .bad_handle

	FWRITE <(GWVA_WBITM_OBJ_PAL_PTR,[GWVA_WIND_OBJ_SPEC_PTR,a0])>,#4*256,d7

	FCLOSE d7

.bad_handle:
.annule:
.pas_bitmap:
.the_top_windows_is_not_mine:
	rts
*--------------------------------------------------------------------------*

	section DATA

texte_gif:	dc.b 'Locate file to view : ',0
texte_pal:	dc.b 'File to save palette : ',0
mask_gif:	dc.b '*.GIF',0
mask_pal:	dc.b '*.PAL',0

*--------------------------------------------------------------------------*

	section BSS

gif_loaded_address:	ds.l 1
gif_loaded_length:	ds.l 1
gif_loaded_width:	ds.w 1
gif_loaded_width_rounded_16:ds.w 1
gif_loaded_height:	ds.w 1
gif_loaded_nb_colors:	ds.w 1
gif_loaded_nb_planes:	ds.w 1

gif_palette:	ds.l 1

	; pour le d‚compactage

string_table:	ds.l 2*4096		; maximum 12 bits

current_max_code:	ds.w 1

ptr_strings:	ds.l 1

ptr_table:		ds.l 1

strings:		ds.l 1
; ds.b 640*480+4096	; m‚moire dynamique ... 12 bits
; au pire : 256*1 + 2 + 3 + ... + (4096-256) = 256 + 3840*3841/2-1=7374975
; au max une image vide 640*480 … 1 ... 784 en incr‚ment de 1

gif_buff:		ds.l 1
;	ds.b 640*480	taille si packing nul : pour suret‚
;			buff remise … l'endroit code compact
fin_gif_buff:	ds.l 1

gif_img:		ds.l 1
; ds.b 640*480	; l… sera d‚compact‚e l'image
; ds.b 639+1024	; 639 : erreur Prism Paint

gif_for_screen:	ds.l 1
ptr_pathname:	ds.l 1
 END
