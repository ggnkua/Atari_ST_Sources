	output d:\assemble\visual40\samples\multidoc\bitmap\project.acx

OPT_FULL_PATHNAMES
OPT_DEBUG

	lea objet_application,a1

	include project.def
	include visual40.s
	include project.hs
	include project.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Exemple de programme Visual Assembleur 4.0
	; Propri‚t‚ : marche aussi bien an accessoire qu'en programme

	; Exemple de multi-documents g‚r‚ automatiquement
	; il permet d'ouvrir autant de fenˆtres bitmap que de m‚moire disponible

	; ce programme r‚pond aux quatre lois de l'ouverture :
	; 1) ligne de commande
	; 2) si pas de ligne de commande : s‚lecteur de fichiers
	;    et si annule, CTRL+O -> redemande
	; 3) en accessoire : un click appelle le s‚lecteur
	; 4) en accessoire, supporte le VA_START
;---------------------------------------------------------------------------

my_inits:	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne.s .prg
	rts

.prg:	tst d0
	bne.s open_object		; cmd line present

acc_open:
menu_open:
	lea texte,a0		; 35 chars max.
	lea mask,a1			; 18 caracteres max
	lea 0,a2
	bsr FILE_SELECTOR
	tst d0
	ble .annule

	move.l a1,a0
	bra.s open_object

.annule:	rts

menu_information:
	lea objet_fenetre_info,a0
	bra GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND

routine_menu_quit:
app_term:
acc_close:
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
	bge open_object

	rts	; pas b infinie si jamais 1 vstation se libŠre ?

open_object:		; ici : a0 pointeur sur un pathname !

	; le programme ... de traitement et cr‚ation du bitmap
	; votre image finale doit ˆtre un malloc ainsi que sa palette
	; puis ...

	; pas de routine de fermeture de fenˆtre ni de lib‚ration de
	; m‚moire : tout est g‚r‚ en interne

	move.l a2,img_filename_ptr	; sauve pour plus tard

	; … vous d'initialiser les 5 lignes qui suivent ...
	move #640,img_width
	move #480,img_height
	move #8,img_nbr_bitplane
	; on va faire un dump graphique de la m‚moire ... tip top
	move.l #$200,img_pal_ptr
	move.l #$400,img_data_ptr

	; on faity un malloc de la taille d'une structure de fenˆtre
	; bitmap, on reloge et on recopie tout comme il faut dedans

	move.l #fin_objet_fenetre_clone-objet_fenetre_clone,d0
	MXALLOC #RAM_TT_ST,d0
	tst.l d0
	ble .err_malloc		; plus de m‚moire

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
	; sera lib‚r‚ automatiquement car on a mis le bit 10 des PROPERTIES

	move img_width,GWVA_WIND_OBJ_FIRST_W(a0)
	move img_height,GWVA_WIND_OBJ_FIRST_H(a0)

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move img_width,GWVA_WBITM_OBJ_IMG_WIDTH(a1)
	move img_height,GWVA_WBITM_OBJ_IMG_HEIGHT(a1)
	move.l img_data_ptr,GWVA_WBITM_OBJ_DATA_PTR(a1)
	move.l img_pal_ptr,GWVA_WBITM_OBJ_PAL_PTR(a1)
	move.w img_nbr_bitplane,GWVA_WBITM_OBJ_NBR_BITPLANES(a1)

	move.l img_filename_ptr,a2	; nom du fichier en info
	move.l GWVA_WIND_OBJ_INFO(a0),a3
	COPY_STRING_0 a2,a3

	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	; si la cr‚ation ‚choue ... la m‚moire a ‚t‚ lib‚r‚e
	; soit : DATA_PTR, PAL_PTR et USR_PTR1

.err_malloc:
	rts


	section DATA

texte:	dc.b 'Genuwax for the best : ',0
mask:	dc.b '*.S,*.BAK',0

	section BSS

img_width:		ds.w 1
img_height:		ds.w 1
img_nbr_bitplane:	ds.w 1
img_pal_ptr:	ds.l 1
img_data_ptr:	ds.l 1
img_filename_ptr:	ds.l 1

 END
