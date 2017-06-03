	output d:\assemble\sources.v40\look\look.acx

*OPT_FULL_PATHNAMES
	lea objet_application,a1

	include look.def
	include visual40.s
	include look.hs
	include look.obj

	comment HEAD=7
	section TEXT

*--------------------------------------------------------------------------*
initialisation_app:
	clr.l add_structure_wind_look	; il faut effacer les bss non initialis‚s ...

	save.l d0/a0

	move.w #FORM_SEARCH,d0
	move.w #FSCH_TXT_ITEM,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	clr.b (a1)			; Par d‚faut pas de chaine de caractŠre

	load.l d0/a0

	tst GWVA_APP_OBJ_IS_ACC_PRG
	beq.s .pas_de_demarage_si_acc

	tst d0			; ligne de commande pr‚sente = a0.l : ptr sur le nom du fichier
	bne open_a_look_window

	bra menu_open_look

.pas_de_demarage_si_acc:
	rts

*--------------------------------------------------------------------------*

acc_open:	
menu_open_look:
	lea texte_selecteur_l,a0	; 35 chars max.
	lea mask_selecteur_l,a1		; 18 caracteres max
	lea 0,a2			; ancien pathname
	bsr FILE_SELECTOR
	tst d0
	beq.s .annule
	bmi.s .erreur_gemdos
; 	-> a0 : nom du fichier
;	-> a1 : drive:path\ du fichier
;	-> a2 : drive:path\filename.ext

	move.l a2,a0		; nom fichier
	bra open_a_look_window

.erreur_gemdos:
.annule:
	rts

	*-------------------------*
acc_close:
app_term:
menu_quit:
	bsr free_all_look_window

	bsr GWVA_WIND_OBJ_PRG_DELETE_ALL_WIND

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne VISUAL40_END

; les accesoires ne sortent pas
	rts

*--------------------------------------------------------------------------*

other_message:
	cmp.w #VA_START,d0
	beq.s .va_start
	rts

.va_start:	move.l 6(a0),a0	; a0 pointe sur le nom du fichier

	save.l a0
	bsr GWVA_APP_OBJ_PRG_ACC_OPEN_VSTATION	; on doit ouvrir la station virtuelle
	load.l a0
	tst d7
	bpl open_a_look_window

	rts

	*-------------------------*

event_keyboard:
; Traitement des touches pour l'‚dition des fichiers
; Est-ce que l'on a un fichier dans cette fenetre ?

	cmp.l #0,a0
	beq .pas_de_fenetre

	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1
	cmp.l #0,a1
	beq .pas_fenetre_edition

	tst.l ad_buffer_source(a1)	; ?PROT?
	beq .pas_de_fichier

	tst.w champ_edition(a1)
	bne.s .edition_ascii

; On test si la touche est un chiffre hexad‚cimal

	move d0,d1
	cmp.b #'0',d0
	blt .pas_affichable
	cmp.b #'f',d0
	bgt .pas_affichable

	cmp.b #'9',d0
	ble.s .number

	or.b #$20,d0	; minuscule
	cmp.b #'a',d0
	blt .pas_affichable
	cmp.b #'f',d0
	bgt .pas_affichable
.number:	; le caractere est un digit hexadecimal valide

	; d1 est un caractŠre valide pour l'hexa
	move d1,d0
	ext.w d0
	sub.w #'0',d0
	cmp.w #9,d0
	ble.s .hexa_number
	or.w #$20,d0
	sub.w #('a'-'0')-$0a,d0
.hexa_number:
.edition_ascii:
	bsr affiche_digit
.pas_affichable
.pas_de_fichier:
.pas_fenetre_edition:
.pas_de_fenetre:
	rts

*--------------------------------------------------------------------------*

menu_info:	lea fenetre_information,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

*--------------------------------------------------------------------------*
; Fenˆtre G‚n‚rale

curseur_droite:
	bsr deplacement_curseur
	move.l d3,d0
	move.w #0,d1
	bsr update_position_curs
	rts
curseur_gauche:
	bsr deplacement_curseur
	move.l d3,d0
	neg.l d0
	move.w #0,d1
	bsr update_position_curs
	rts
curseur_bas:
	bsr deplacement_curseur
	move.l d2,d0
	move.w #0,d1
	bsr update_position_curs
	rts
curseur_haut:
	bsr deplacement_curseur
	move.l d2,d0
	neg.l d0
	move.w #0,d1
	bsr update_position_curs
	rts

	*-------------------------*

close_fenetre_generale:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1	; pointeur structure look

	save.l a1
	move.w #2,d0		; par d‚faut No
	bsr save_buffer_if_changed
	load.l a1

	bsr free_a_look_window

	tst.l add_structure_wind_look
	beq menu_quit	; plus de fenetre -> on quitte (chaud : limite de l'appel recursif !!)
	rts

	*-------------------------*

affichage_curseur:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a2	; pointe la structure look
	cmp.l #0,a2		; ?PROT?
	beq .pas_redraw

	tst.l ad_buffer_source(a2)	; ?PROT?
	beq .pas_redraw

	move.l pos_curseur(a2),d1	; position curseur / debut fichier en quartet
	lsr.l #1,d1			; en octet
	sub.l offset_fichier(a2),d1	; pos. / debut buffer
	divu #8+8,d1		; n. de la ligne
	move.l table_obj(a2),a3
	add.w f_donnees_byte(a3),d1	; + n. premiere ligne

	save.l d1/a0-a2
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),d1
	load.l d1/a0-a2
	movem.w int_out+1*2,d4/d5	; position x,y de l'objet

	swap d1
	ext.l d1
	divu #8,d1		; -> 1ere ou 2eme partie de la ligne

	clr.w d3

	tst.w d1
	beq.s .premier_8

	move.w GWVA_APP_OBJ_CELL_WIDTH,d2
	move.w d2,d3
	mulu #8*3,d3	; 3 ascii pour un caractere : 00[ ]
	ext.l d2
	add.l d2,d3		; caracteres de passage entre 2 champs
	add.l d2,d3

.premier_8:	swap d1
	mulu #3,d1		; 3 ascii par octet
	move.l pos_curseur(a2),d0
	sub.l offset_fichier(a2),d0
	sub.l offset_fichier(a2),d0	; octet -> quartet
	divu #2,d0		; on passe la position octet
	swap d0
	add.w d0,d1
	mulu GWVA_APP_OBJ_CELL_WIDTH,d1
	add.w d1,d3		; position x/objet
	add.w d4,d3		; position x absolue

	move d5,d7
	move d3,d4
	move d3,d6
	add GWVA_APP_OBJ_CELL_WIDTH,d6
	add GWVA_APP_OBJ_CELL_HEIGHT,d7	; coin droit bas
	sub.w #1,d6
	sub.w #1,d7

	save.l a0-a2

	save.l a2
	save.w d4-d7
	vswr_mode #3	; mode XOR
	load.w d4-d7
	load.l a2

	cmp.w #0,champ_edition(a2)
	bne.s .pas_edition_champ_hexa

	vr_recfl d4,d5,d6,d7	; rectangle plein
	bra.s .comm1

.pas_edition_champ_hexa:
	save.w d4-d7
	vsf_interior #0	; pas de remplissage
	load.w d4-d7
	v_bar d4,d5,d6,d7	; rectangle avec bord
	vsf_interior #1	; remet le remplissage
.comm1:
	vswr_mode #1	; mode de remplacement

	load.l a0-a2

	move.l pos_curseur(a2),d1
	lsr.l #1,d1
	sub.l offset_fichier(a2),d1	; pos. / debut buffer
	divu #8+8,d1
	move.l table_obj(a2),a3
	add.w f_ascii_byte(a3),d1

	save.l d1/a0-a2
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),d1
	load.l d1/a0-a2
	movem.w int_out+1*2,d4/d5

	swap d1
	mulu GWVA_APP_OBJ_CELL_WIDTH,d1	; position x/objet
	add.w d4,d1			; position x absolue

	move.w d5,d7
	move.w d1,d4
	move.w d1,d6
	add GWVA_APP_OBJ_CELL_WIDTH,d6
	add GWVA_APP_OBJ_CELL_HEIGHT,d7	; coin droit bas
	sub.w #1,d6
	sub.w #1,d7

	save.l a0-a2

	save.l a2
	save.w d4-d7
	vswr_mode #3	; mode XOR
	load.w d4-d7
	load.l a2

	cmp.w #1,champ_edition(a2)
	bne.s .pas_edition_champ_ascii

	vr_recfl d4,d5,d6,d7
	bra.s .comm2
.pas_edition_champ_ascii:
	save.w d4-d7
	vsf_interior #0
	load.w d4-d7
	v_bar d4,d5,d6,d7
	vsf_interior #1
.comm2:
	vswr_mode #1

	load.l a0-a2

.pas_redraw:
	clr.w d7
	rts

	*-------------------------*

; Initialisation_fenetre : Initialise le contenu des champs graphiques de la fenˆtre
initialisation_fenetre:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1
	move.l table_obj(a1),a2

	move.l add_struct_form(a2),a3

; On recopie le nom dans les deux formulaires

	move.w GWVA_WFORM_OBJ_FORM_IDX(a3),d0
	move.w f_txt_name(a2),d1
	save.l a0-a3
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a4
	load.l a0-a3
	lea source_pathname(a1),a5
.rec:	tst.b (a5)+
	bne.s .rec
.rec2:	cmp.b #'\',-(a5)
	bne.s .rec2
	lea 1(a5),a5
	COPY_STRING_0 a5,a4

; Ainsi que la taille

	move.w GWVA_WFORM_OBJ_FORM_IDX(a3),d0
	move.w f_txt_lgth_hex(a2),d1
	save.l a0-a3
	save.l a1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	load.l a0
	move.b #'$',(a1)+
	move.l source_length(a0),d0
	move.l #32,d1
	bsr STOCK_HEXA
	load.l a0-a3

	move.w GWVA_WFORM_OBJ_FORM_IDX(a3),d0
	move.w f_txt_lgth_dec(a2),d1
	save.l a0-a3
	save.l a1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	load.l a0
	move.b #'#',(a1)+
	move.l source_length(a0),d0
	bsr STOCK_DECI
	load.l a0-a3

	save.l a0-a2
	lea source_pathname(a1),a2
	move.l a2,GWVA_WIND_OBJ_NAME(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_TITLE
	load.l a0-a2

	move.l add_struct_slide(a2),a3
	move.l source_length(a1),d0
	add.l #8+8-1,d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_LENGTH(a3)
	move.l offset_fichier(a1),d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_POS(a3)

	save.l a0-a2
	move.l add_struct_form(a2),a1
	move.l add_struct_slide(a2),a2
	bsr GWVA_SLIDER_OBJ_PRG_SET_SLIDER
	load.l a0-a2

	clr.w longueur_chaine_search(a1)
	clr.b chaine_search(a1)
	clr.l ad_buffer_search(a1)

	clr.w d7
	rts

	*-------------------------*

click_in_window:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1

	move.l table_obj(a1),a2
	
	move f_donnees_byte(a2),d1
	cmp.w d1,d0
	blt .pas_click_champ_curseur
	add.w f_num_line(a2),d1
	cmp.w d1,d0
	bge .pas_click_dans_donnees
; Click dans un champ donn‚e

	clr.w champ_edition(a1)

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a3

	save.l d0/a0-a3
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a3),d0
	load.l d0/a0-a3

	move.w int_out+1*2,d3
	sub.w GWVA_APP_OBJ_EVNT_MULTI_MX,d3
	neg.w d3			; position relative souris / objet

	clr d4
	move.w GWVA_APP_OBJ_CELL_WIDTH,d1
	mulu #8*3,d1

	cmp.w d1,d3
	blt.s .partie_gauche_donnees

	add.w GWVA_APP_OBJ_CELL_WIDTH,d1
	add.w GWVA_APP_OBJ_CELL_WIDTH,d1

	cmp.w d1,d3
	blt .au_milieu	; on est au milieu des deux champs de donnees

	move.w #8*2,d4	; d‚calage en quartet
	sub.w d1,d3

.partie_gauche_donnees:
	move.w GWVA_APP_OBJ_CELL_WIDTH,d1
	mulu #3,d1
	ext.l d3
	divu d1,d3
	move d3,d5
	add.w d5,d5			; numero quartet
	swap d3
	ext.l d3
	divu GWVA_APP_OBJ_CELL_WIDTH,d3
	cmp.w #2,d3
	blt.s .ok
	move.w #1,d3
.ok:	add.w d3,d5
	add.w d5,d4

	sub.w f_donnees_byte(a2),d0	; la ligne
	mulu #(8+8)*2,d0
	add.w d4,d0
	ext.l d0
	add.l offset_fichier(a1),d0
	add.l offset_fichier(a1),d0	; position en quartet
	sub.l pos_curseur(a1),d0
	moveq #0,d1
	bsr update_position_curs

.au_milieu:
	rts

.pas_click_dans_donnees:
	move f_ascii_byte(a2),d1
	cmp.w d1,d0
	blt .pas_click_champ_curseur
	add.w f_num_line(a2),d1
	cmp.w d1,d0
	bge .pas_click_dans_ascii

	move.w #1,champ_edition(a1)

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a3

	save.l d0/a0-a3
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a3),d0
	load.l d0/a0-a3

	move.w int_out+1*2,d3
	sub.w GWVA_APP_OBJ_EVNT_MULTI_MX,d3
	neg.w d3			; position relative souris / objet

	ext.l d3
	divu GWVA_APP_OBJ_CELL_WIDTH,d3
	move d3,d5
	add.w d5,d5			; numero quartet

	sub.w f_ascii_byte(a2),d0	; la ligne
	mulu #(8+8)*2,d0
	add.w d5,d0
	ext.l d0
	add.l offset_fichier(a1),d0
	add.l offset_fichier(a1),d0
	sub.l pos_curseur(a1),d0
	moveq #0,d1
	bsr update_position_curs
	rts
.pas_click_dans_ascii:
.pas_click_champ_curseur:
	rts

	*-------------------------*

size_changed:
	lea liste_obj_form_b,a2
	cmp.w #FS_BTON_BIG,d0
	beq.s .big
	lea liste_obj_form_s,a2
.big:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1
	move.l f_buffer_length(a2),d0

	save.l a0-a2
	bsr reserve_buffer	; -> d0.l
	load.l a0-a2
	tst d7
	beq .ok_memoire

	rts

.ok_memoire:
	save.l a0-a2
	MFREE d0
	movem.l (sp),a0-a2
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	load.l a0-a2

	tst.l ad_buffer_source(a1)
	beq .buffer_vide

	save.l a0-a2
	move.w #2,d0		; par d‚faut No
	bsr save_buffer_if_changed
	movem.l (sp),a0-a2
	MFREE ad_buffer_source(a1)
	load.l a0-a2
	clr.l ad_buffer_source(a1)

.buffer_vide:
	move.l f_buffer_length(a2),d0
	save.l a0-a2
	bsr reserve_buffer	; -> d0.l
	load.l a0-a2
	tst d7
	bmi .erreur_memoire
	move.l d0,ad_buffer_source(a1)

	move.l f_buffer_length(a2),buffer_length(a1)
	move.w f_num_line(a2),buffer_num_line(a1)
	move.w f_size(a2),size_look(a1)
	move.l a2,table_obj(a1)

	save.l a0-a2
	bsr load_a_buffer
	load.l a0-a2
	tst d7
	bne .erreur_load

	move.l #-1,GWVA_WIND_OBJ_FIRST_X(a0)	; centre
	move.l add_struct_form(a2),GWVA_WIND_OBJ_SPEC_PTR(a0)

	move.l pos_curseur(a1),d0
	move.l offset_fichier(a1),d1
	add.l buffer_length(a1),d1
	add.l d1,d1
	cmp.l d0,d1
	bgt.s .curseur_dans_champ
	move.l d1,d0
	sub.l #(8+8)*2,d0	; position en derniŠre ligne
.curseur_dans_champ:

	save.l d0/a1
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	load.l d0/a1

	sub.l pos_curseur(a1),d0
	move.w #0,d1
	bsr update_position_curs
	tst d7
	bpl.s .ok_actualisation_text
	bsr update_text_dans_formulaire
.ok_actualisation_text:
	rts
.erreur_memoire:
.erreur_load:
	bsr free_a_look_window
	rts

	*-------------------------*

; Update_file : demande de sauvegarder le buffer actuel
update_file:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1

	tst.l ad_buffer_source(a1)
	beq .buffer_vide

	move.w changement_valeur(a1),-(sp)
	move.w #1,d0		; par d‚faut yes
	bsr save_buffer_if_changed
	load.w d0
	tst.w d7
	beq.s .sauvegarde
	move.w d0,changement_valeur(a1)	; si pas updat‚, on garde le chgt actif
.sauvegarde:
.buffer_vide:
	rts

	*-------------------------*

; Load_file  : charge un nouveau fichier dans la fenˆtre look actuelle
load_file:	save.l a0

	lea texte_selecteur_l,a0	; 35 chars max.
	lea mask_selecteur_l,a1		; 18 caracteres max
	lea 0,a2
	bsr FILE_SELECTOR

	load.l a0

	tst d0
	beq.s .annule
	bmi.s .erreur_gemdos
; 	-> a0 : nom du fichier
;	-> a1 : drive:path\ du fichier
;	-> a2 : drive:path\filename.ext

	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1
	move.l a2,a0		; nom fichier
	bra commun_open_a_file

.erreur_gemdos:
.annule:
	rts

	*-------------------------*

move_slider:
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1
	move.l d1,d0
	muls.l #(8+8)*2,d0	; taille d'un element = (8+8)*2 quartets
	move.w #1,d1
	bsr update_position_curs
	rts

*--------------------------------------------------------------------------*

; Sous Programme de la fenˆtre G‚n‚rale

deplacement_curseur:
	move.l #(8+8)*2,d2	; une ligne en quartet
	moveq #1,d3
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a1
	tst.w champ_edition(a1)
	beq.s .edition_hexa
	moveq #1*2,d3	; 2 quartets par 2 quartets en ASCII
.edition_hexa:
	rts

	*-------------------------*

; d0.l : deplacement sign‚ du curseur en quartet
; d1.w : 0, deplacement, 1 pas deplacement curseur
; a0.l : ptr struct fenetre
; a1.l : ptr struct look
update_position_curs:
	move.l pos_curseur(a1),d2
	add.l d0,d2
	bpl.s .position_positive
;	sub.l d0,d2
	moveq #0,d2
.position_positive:
	move.l source_length(a1),d3
	add.l d3,d3
	cmp.l d3,d2
	blt.s .position_inf
;	sub.l d0,d2
	move.l d3,d2
	sub.l #1*2,d2
.position_inf:

	cmp.l pos_curseur(a1),d2
	beq .pas_deplacement

	move.l pos_curseur(a1),d3
	move.l d2,pos_curseur(a1)

	tst.w d1
	bne.s .curs_fixe

	moveq #0,d0		; deplacement dans le fichier
	move.l offset_fichier(a1),d4
	add.l d4,d4
	cmp.l d4,d2
	bge.s .curs_sup_off

	move.l d4,d0
	sub.l d2,d0
	add.l #(8+8)*2-1,d0
	and.l #-(8+8)*2,d0	; on remonte d'une ligne dans le fichier
	neg.l d0
.curs_sup_off:
	add.l buffer_length(a1),d4
	add.l buffer_length(a1),d4
	cmp.l d4,d2
	blt.s .curs_dans_fenetre

	move.l d2,d0
	sub.l d4,d0
	add.l #(8+8)*2,d0
	and.l #-(8+8)*2,d0	; on descend d'une ligne dans le fichier

.curs_dans_fenetre:
.curs_fixe:
	save.l a0-a1/d2/d3
	bsr deplace_dans_fichier
	load.l a0-a1/d2/d3
	tst d7
	beq.s .deja_un_affichage

	lsr.l #1,d2			; en octet
	lsr.l #1,d3			; en octet
	and.l #-(8+8),d2
	and.l #-(8+8),d3
	sub.l offset_fichier(a1),d2
	sub.l offset_fichier(a1),d3	; pos. / debut buffer
	divu #8+8,d2
	divu #8+8,d3		; n. de la ligne
	move.w d2,d4
	move.w d3,d5
	move.l table_obj(a1),a2
	add.w f_donnees_byte(a2),d2
	add.w f_donnees_byte(a2),d3	; + n. premiere ligne
	add.w f_ascii_byte(a2),d4
	add.w f_ascii_byte(a2),d5

	lea liste_obj_redraw,a3
	move.w d3,(a3)+
	move.w #1,(a3)+
	move.w d5,(a3)+
	move.w #1,(a3)+
	move.w d2,(a3)+
	move.w #1,(a3)+
	move.w d4,(a3)+
	move.w #1,(a3)+
	move.w #-1,(a3)+

	cmp.w d2,d3
	bne.s .lignes_differentes
	move.w #-1,liste_obj_redraw+2*2*2
.lignes_differentes:

	save.l a0-a1
	lea liste_obj_redraw,a1
	move.w #3,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l a0-a1

.deja_un_affichage:
	move.l table_obj(a1),a2
	move.l add_struct_slide(a2),a3
	move.l offset_fichier(a1),d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_POS(a3)
	save.l a0-a1
	move.l add_struct_form(a2),a1
	move.l add_struct_slide(a2),a2
	bsr GWVA_SLIDER_OBJ_PRG_SET_SLIDER
	load.l a0-a1

	clr d7
	rts

.pas_deplacement:
	move.w #GWVA_ERROR_GENERIC,d7
	rts
 BSS
liste_obj_redraw:	ds.w 4*2+1
 TEXT

	*-------------------------*

affiche_digit:
	move.l ad_buffer_source(a1),a2

; positionnement au quartet
	move.l pos_curseur(a1),d1
	sub.l offset_fichier(a1),d1
	sub.l offset_fichier(a1),d1
	divu #2,d1			; en octet
	add.w d1,a2

	tst.w champ_edition(a1)
	bne.s .edition_ascii

	swap d1
	tst d1
	beq.s .quartet_haut
	and.b #$f0,(a2)
	or.b d0,(a2)
	moveq #1,d2
	bra.s .continue
.quartet_haut:
	and.b #$0f,(a2)
	lsl.b #4,d0
	or.b d0,(a2)
	moveq #1,d2
	bra.s .continue
.edition_ascii:
	move.b d0,(a2)
	moveq #1*2,d2

.continue:
	move.w #-1,changement_valeur(a1)

	move.l d2,d0
	move.w #0,d1

	bsr update_position_curs

	rts

	*-------------------------*

; a2 : structure du type formulaire
create_a_look_window:
	move.l add_structure_wind_look,a1
	cmp.l #0,a1
	bne .no_more_look_window

	save.l a2
	MXALLOC #RAM_TT_ST,#LONG_STR_LOOK
	load.l a2
	tst.l d0
	ble .pas_de_memoire

	move.l d0,add_structure_wind_look
	move.l d0,a1

	lea fenetre_generale,a0
	move.l a1,GWVA_WIND_OBJ_USER_PTR1(a0)
	move.l #-1,GWVA_WIND_OBJ_FIRST_X(a0)	; centre
	move.l a0,ptr_window(a1)
	clr.b source_pathname(a1)
	clr.l ad_buffer_source(a1)
	clr.w champ_edition(a1)		; edition sur le champ hexa
	clr.l ad_buffer_search(a1)
	move.l a2,table_obj(a1)
	move.l add_struct_form(a2),GWVA_WIND_OBJ_SPEC_PTR(a0)
	move.w f_size(a2),size_look(a1)
	move.l f_buffer_length(a2),buffer_length(a1)
	move.w f_num_line(a2),buffer_num_line(a1)

	clr d7
	rts

.no_more_look_window:
	clr.w d7
	rts

.pas_de_memoire:
	move.w #ALERT_MEM,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX
	move.w #GWVA_ERROR_MALLOC,d7
	rts

	*-------------------------*

open_a_look_window:
	save.l a0
	lea liste_obj_form_b,a2		; par d‚faut l'ouverture se fait sur le grand formulaire
	bsr create_a_look_window	; retour dans a1 de l'adresse de la structure look
	load.l a0
	tst d7
	bge.s commun_open_a_file
	rts

commun_open_a_file:
	bsr open_a_file
	tst d7
	bmi.s .erreur_open

	save.l a1
	move.l ptr_window(a1),a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	load.l a1
	tst d7
	bpl.s .creation_ok

	bsr free_a_look_window

.creation_ok:
.erreur_open:
	rts

 DATA
texte_selecteur_l:	dc.b 'Choose file to look & edit :',0
mask_selecteur_l:	dc.b '*.*',0
 TEXT
 
	*-------------------------*

free_all_look_window:
	move.l add_structure_wind_look,a1
	cmp.l #0,a1
	beq.s .pas_fenetre

	move.l ptr_window(a1),a0
	bra close_fenetre_generale

.pas_fenetre:
	rts
	
	*-------------------------*

free_a_look_window
	cmp.l #0,a1
	beq.s .nothing1

	tst.l ad_buffer_source(a1)
	beq .nothing2
	save.l a1
	MFREE ad_buffer_source(a1)
	load.l a1
	clr.l ad_buffer_source(a1)
.nothing2:
	tst.l ad_buffer_search(a1)
	beq .nothing3
	save.l a1
	MFREE ad_buffer_search(a1)
	load.l a1
	clr.l ad_buffer_search(a1)
.nothing3:
	move.l ptr_window(a1),a0
	save.l a1
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	load.l a1

	MFREE a1

	clr.l add_structure_wind_look

.nothing1:	rts

	*-------------------------*

	; a0 : ptr sur le nom du fichier, a1 : ptr structure look
open_a_file:
	tst.l ad_buffer_source(a1)
	beq .buffer_vide

	save.l a0/a1
	move.w #2,d0		; par d‚faut No
	bsr save_buffer_if_changed
	load.l a0/a1

	save.l a0
	bsr free_a_look_window
	lea liste_obj_form_b,a2
	bsr create_a_look_window
	load.l a0
	tst d7
	bmi .erreur

.buffer_vide:
	lea source_pathname(a1),a2
	COPY_STRING_0 a0,a2

	save.l a1
	lea source_pathname(a1),a0
	bsr GET_FILE_LENGTH
	load.l a1
	tst.l d0
	ble .erreur_fichier

	move.l d0,source_length(a1)

	save.l a1
	move.l buffer_length(a1),d0	; longueur buffer
	bsr reserve_buffer
	load.l a1
	tst d7
	bmi .erreur_memoire
	move.l d0,ad_buffer_source(a1)

	clr.l offset_fichier(a1)
	clr.l pos_curseur(a1)		; position dans le fichier
	clr.w changement_valeur(a1)

	save.l a1
	bsr load_a_buffer
	load.l a1
	tst d7
	bne .erreur_load

	moveq #0,d0
	save.l a1
	bsr deplace_dans_fichier
	load.l a1

	clr.w d7
.erreur:
.no_mem:	rts

.erreur_load:
.erreur_memoire:
	bsr free_a_look_window
	move.w #GWVA_ERROR_GENERIC,d7
	rts

.erreur_fichier:
	bsr free_a_look_window
	move.w #ALERT_OPEN_FILE,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX
	move.w #GWVA_ERROR_GENERIC,d7
	rts

	*-------------------------*

reserve_buffer:		; d0=longeur, a1 : pointeur structure
	save.l a1
	MXALLOC #3,d0		; TT -> ST
	load.l a1
	tst.l d0
	ble.s .errormem
	clr d7
	rts
.errormem:	move.w #ALERT_MEM,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX
	moveq #GWVA_ERROR_MALLOC,d7
	rts

	*-------------------------*

; a1 : ptr struc look
; d0 : bouton par d‚faut
save_buffer_if_changed:
	tst.w changement_valeur(a1)
	beq .pas_de_chgt_valeur

	clr.w changement_valeur(a1)

	move.w d0,d1		; bouton par d‚faut
	move.w #ALERT_MOD_B,d0
	save.l a1
	bsr RSC_ALERT_BOX
	load.l a1
	cmp.w #2,d0
	beq .pas_de_sauvegarde

	save.l a1
	FILE_OPEN read_write,source_pathname(a1),d7
	load.l a1
	tst.w d7
	blt.s .pas_de_sauvegarde

	save.l a1
	FSEEK #0,d7,offset_fichier(a1)
	load.l a1
	tst.l d0
	blt.s .pas_de_sauvegarde

	save.l a1
	move.l source_length(a1),d1
	sub.l offset_fichier(a1),d1
	move.l buffer_length(a1),d0
	cmp.l d0,d1
	bge.s .longueur_suffisante
	move.l d1,d0
.longueur_suffisante:
	FWRITE ad_buffer_source(a1),d0,d7
	FCLOSE d7
	load.l a1

.pas_de_chgt_valeur:
	clr.w d7
	rts
.pas_de_sauvegarde:
	move.w #-1,d7
	rts

	*-------------------------*

load_a_buffer:
	save.l a1
	FILE_OPEN read,source_pathname(a1),d7
	load.l a1
	tst d7
	ble .erreur_open

	save.l a1
	FSEEK #0,d7,offset_fichier(a1)
	move.l (sp),a1
	FREAD ad_buffer_source(a1),buffer_length(a1),d7
	move.l (sp),a1

	save.l d0
	FCLOSE d7
	load.l d0

	load.l a1

	tst.l d0
	blt .erreur_read

	cmp.l buffer_length(a1),d0
	beq.s .buffer_plein

	move.l ad_buffer_source(a1),a0
	add.l d0,a0
	sub.l buffer_length(a1),d0
	neg.w d0
	sub.w #1,d0
.efface_buff:
	move.b #'_',(a0)+
	dbf d0,.efface_buff
.buffer_plein:
	clr d7
	rts
.erreur_open:
	save.l a1
	move.w #ALERT_OPEN_FILE,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX
	load.l a1

	move.w #GWVA_ERROR_GENERIC,d7
	rts

.erreur_read:
	save.l a1
	move.w #ALERT_READ_FILE,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX
	load.l a1

	move.w #GWVA_ERROR_GENERIC,d7
	rts

	*-------------------------*

deplace_dans_fichier:
	tst.l ad_buffer_source(a1)	; ?PROT?
	beq .pas_fichier

	tst.l d0
	beq .pas_bouge

	asr.l #1,d0		; quartet -> octet
	move.l offset_fichier(a1),d1
	add.l d0,d1
	bpl.s .offset_ok1
	clr.l d1
.offset_ok1:
	move.l source_length(a1),d2
	add.l #(8+8)-1,d2
	and.l #-(8+8),d2	; d2 : longueur du fichier en multiple de (8+8)
	move.l buffer_length(a1),d3
	sub.l d3,d2
	bpl.s .positif
	clr.l d2
.positif:	
	cmp.l d2,d1
	ble.s .offset_ok2
	move.l d2,d1
.offset_ok2:
	move.l ad_buffer_source(a1),a0

	cmp.l offset_fichier(a1),d1
	beq .pas_deplacement

	save.l d1/a1
	move.w #2,d0
	bsr save_buffer_if_changed
	load.l d1/a1

	move.l d1,offset_fichier(a1)

	save.l a1
	bsr load_a_buffer
	load.l a1
	tst d7
	bne .erreur_load

	bsr update_text_dans_formulaire

	move.l ptr_window(a1),a0
	move.l table_obj(a1),a2
	move.w f_redraw_obj_2(a2),d0	; move #FS_REDRAW_OBJ_2,d0
	moveq #2,d1
	moveq #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

	clr.w d7
	rts

.pas_bouge:	bsr update_text_dans_formulaire
	move.w #GWVA_ERROR_GENERIC,d7
	rts

.erreur_load:
.pas_deplacement:
.pas_fichier:
	move.w #GWVA_ERROR_GENERIC,d7
	rts

	*-------------------------*

update_text_dans_formulaire:
	move.l offset_fichier(a1),d6

	move.l table_obj(a1),a2
	move.w f_offset_byte(a2),d1	; move #FS_OFFSET_BYTE1,d1

	move.l ptr_window(a1),a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a2
	move.w GWVA_WFORM_OBJ_FORM_IDX(a2),d0

	move.w buffer_num_line(a1),d7
	sub.w #1,d7

	save.l a1

.recopy_offset:
	save.w d0-d1/d7

	save.l d6
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l (sp),d0
	move.l #32,d1
	bsr STOCK_HEXA
	load.l d6

	load.w d0-d1/d7

	add.w #1,d1
	add.l #(8+8),d6
	dbf d7,.recopy_offset

	load.l a1

	*-------*

	move.l ad_buffer_source(a1),a0

	move.l table_obj(a1),a2
	move.w f_donnees_byte(a2),d1	; move #FS_DONNEES_BYTE,d1

	move.l ptr_window(a1),a2
	move.l GWVA_WIND_OBJ_SPEC_PTR(a2),a3
	move.w GWVA_WFORM_OBJ_FORM_IDX(a3),d0

	move.w buffer_num_line(a1),d7
	sub.w #1,d7

	save.l a1
.recopy_data:
	save.w d0-d1/d7

	save.l a0
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	load.l a0

	REPT 4
	move.l (a0)+,d0
	move.l #32,d1
	bsr STOCK_HEXA
	lea -1(a1),a1
	ENDR

	load.w d0-d1/d7
	add.w #1,d1
	dbf d7,.recopy_data

	load.l a1

	*------*

	move.l ad_buffer_source(a1),a0

	move.l table_obj(a1),a2
	move.w f_ascii_byte(a2),d1	; move #FS_ASCII_BYTE,d1

	move.l ptr_window(a1),a2
	move.l GWVA_WIND_OBJ_SPEC_PTR(a2),a3
	move.w GWVA_WFORM_OBJ_FORM_IDX(a3),d0

	move.w buffer_num_line(a1),d7
	sub.w #1,d7

	save.l a1
.recopy_ascii:
	save.w d0-d1/d7

	save.l a0
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	load.l a0

	move.w #8+8-1,d6
.line_ascii:
	move.b (a0)+,d0
	cmp.b #$20,d0
	bge.s .ascii_affichable
	move.b #'.',d0
.ascii_affichable:
	move.b d0,(a1)+
	dbf d6,.line_ascii

	load.w d0-d1/d7
	add.w #1,d1
	dbf d7,.recopy_ascii

	load.l a1

	rts

*--------------------------------------------------------------------------*
	include search.s
*--------------------------------------------------------------------------*
	include offset.s
*--------------------------------------------------------------------------*

 DATA
	rsreset
add_struct_form:	rs.l 1
add_struct_slide:	rs.l 1
f_redraw_obj_1:	rs.w 1
f_txt_name:		rs.w 1
f_txt_lgth_hex:	rs.w 1
f_txt_lgth_dec:	rs.w 1
f_redraw_obj_2:	rs.w 1
f_offset_byte:	rs.w 1
f_donnees_byte:	rs.w 1
f_ascii_byte:	rs.w 1
f_num_line:		rs.w 1
f_buffer_length:	rs.l 1
f_size:		rs.w 1

liste_obj_form_s:	dc.l spec_fenetre_generale_s
		dc.l struct_fs_slider
		dc.w FS_REDRAW_OBJ_1
		dc.w FS_TXT_NAME
		dc.w FS_TXT_LGTH_HEX
		dc.w FS_TXT_LGTH_DEC
		dc.w FS_REDRAW_OBJ_2
		dc.w FS_OFFSET_BYTE
		dc.w FS_DONNEES_BYTE
		dc.w FS_ASCII_BYTE
		dc.w 8
		dc.l (8+8)*8
		dc.w 0

liste_obj_form_b:	dc.l spec_fenetre_generale_b
		dc.l struct_fb_slider
		dc.w FB_REDRAW_OBJ_1
		dc.w FB_TXT_NAME
		dc.w FB_TXT_LGTH_HEX
		dc.w FB_TXT_LGTH_DEC
		dc.w FB_REDRAW_OBJ_2
		dc.w FB_OFFSET_BYTE
		dc.w FB_DONNEES_BYTE
		dc.w FB_ASCII_BYTE
		dc.w 16
		dc.l (8+8)*16
		dc.w 1

 BSS
add_structure_wind_look:	ds.l 1
			ds.w 1	; BUG de DEVPAC : le dernier BSS ne doit pas ˆtre un .l
	rsreset
ptr_window:		rs.l 1	; pointeur sur la str de la fenetre
source_pathname:	rs.b GWVA_MAX_PATH_LENGTH
source_length:	rs.l 1	; taille du fichier
ad_buffer_source:	rs.l 1
buffer_length:	rs.l 1
buffer_num_line:	rs.w 1
offset_fichier:	rs.l 1	; position actuelle de l'‚dition
pos_curseur:	rs.l 1	; position du curseur dans le fichier
changement_valeur:	rs.w 1
champ_edition:	rs.w 1	; 0 : edition hexa, 1 : edition ascii
size_look:		rs.w 1	; 0 : small, 1 : big
table_obj:		rs.l 1	; pointe sur la table d'objet correspondant a la taille

longueur_chaine_search:	rs.w 1
chaine_search:	rs.b 128
ad_buffer_search:	rs.l 1
ad_fenetre_search:	rs.l 1
buffer_search_length:	rs.l 1
offset_search_fichier:	rs.l 1
pos_search_curseur:	rs.l 1

LONG_STR_LOOK:	rs.w 0
; GWVA_WIND_OBJ_USER_PTR1 pointe sur cette structure

 END
