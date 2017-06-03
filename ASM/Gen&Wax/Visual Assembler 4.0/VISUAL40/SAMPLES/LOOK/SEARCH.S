search_form:save.l a0

	move.l a0,a1
	move.l GWVA_WIND_OBJ_USER_PTR1(a1),a1	; structure look

	lea fenetre_search,a0
	move.l a1,GWVA_WIND_OBJ_USER_PTR2(a0)
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND

	load.l a0

	tst d7
	bmi.s .pas_ouverte

	save.l a0
	move.w #FORM_SEARCH,d0
	move.w #FSCHG_BTON_STOP,d1
	move.w #1,d2		; disable stop
	bsr GWVA_ENABLE_DISABLE_OBJECT
	load.l a0

	move.w #1,d2		; disable continue

	move.l a0,a1
	move.l GWVA_WIND_OBJ_USER_PTR1(a1),a1	; structure look
	tst.w longueur_chaine_search(a1)		; d‚j… eu une recherche ?
	beq.s .pas_de_continue
	clr.w d2
.pas_de_continue:
	save.l a0
	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_CONT,d1
	bsr GWVA_ENABLE_DISABLE_OBJECT
	load.l a0

	add.w #1,GWVA_WIND_OBJ_TOPABLE_STATE(a0)
	move.l a0,GWVA_WIND_OBJ_USER_PTR1+fenetre_search
.pas_ouverte:
	rts

continue_search_item:
	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a3	; structure look

	save.l a0-a3
	move.l buffer_length(a3),d0	; longueur buffer
	move.l d0,buffer_search_length(a3)
	bsr reserve_buffer
	load.l a0-a3
	tst d7
	bmi cancel_search
	move.l d0,ad_buffer_search(a3)

	move.l pos_curseur(a3),d0
	lsr.l #1,d0
	add.l #1,d0
	move.l d0,offset_search_fichier(a3)

	bra continue_search

search_item:
	save.l a0
	move.w #FORM_SEARCH,d0
	move.w #FSCH_TXT_ITEM,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	load.l a0

	move.l a1,a2
.calcul_longeur_chaine:
	tst.b (a2)+
	bne.s .calcul_longeur_chaine
	sub.l a1,a2
	move.w a2,d0
	sub.w #1,d0

	tst.w d0		; longueur nulle -> pas de recherche
	beq cancel_search

	cmp.b #'"',(a1)
	bne.s .chaine_hexa

	sub.w #1,d0
	beq cancel_search
	
	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a3	; structure look
	lea chaine_search(a3),a2
	lea 1(a1),a3

.recopie_chaine_car:
	move.b (a3)+,d1
	beq.s .fin_recopie_chaine_car
	move.b d1,(a2)+
	bra.s .recopie_chaine_car
.fin_recopie_chaine_car:

	lea -2(a3),a3
	cmp.b #'"',(a3)
	bne.s .longueur_bonne
	sub.w #1,d0
	beq cancel_search
.longueur_bonne:
	bra .recherche_chaine

.chaine_hexa:
	move.l a1,a2
.bon_digit_hexa:
	move.b (a2)+,d1
	beq.s .fin_de_chaine
	cmp.b #'0',d1
	blt .bad_hexa
	cmp.b #'9',d1
	ble.s .bon_digit_hexa
	or.b #$20,d1	; majuscules -> minuscules
	cmp.b #'a',d1
	blt .bad_hexa
	cmp.b #'f',d1
	ble.s .bon_digit_hexa

.bad_hexa:	move.w #ALERT_BAD_HEXA,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX

	rts

.fin_de_chaine:
	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a3	; structure look
	lea chaine_search(a3),a2
	move.l a1,a3

	btst #0,d0		; longueur impaire ?
	beq.s .paire

	move.b (a3)+,d1
	sub.b #'0',d1
	cmp.b #9,d1
	ble.s .number1
	or.b #$20,d1
	sub.b #'a'-'0'-$a,d1
.number1:	move.b d1,(a2)+
	add.w #1,d0

.paire:	moveq #0,d1
	moveq #0,d2

.conversion_chaine_hexa:
	move.b (a3)+,d1
	beq.s .fin_conversion

	move.b (a3)+,d2
	sub.b #'0',d1
	sub.b #'0',d2
	cmp.b #9,d1
	ble.s .number2
	or.b #$20,d1
	sub.b #'a'-'0'-$a,d1
.number2:	cmp.b #9,d2
	ble.s .number3
	or.b #$20,d2
	sub.b #'a'-'0'-$a,d2
.number3:	mulu #$10,d1
	add.b d2,d1
	move.b d1,(a2)+
	bra.s .conversion_chaine_hexa
.fin_conversion:
	lsr.w #1,d0
.recherche_chaine:

	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a3	; structure look
	move.w d0,longueur_chaine_search(a3)

	save.l a0/a3
	move.l buffer_length(a3),d0	; longueur buffer
	move.l d0,buffer_search_length(a3)
	bsr reserve_buffer
	load.l a0/a3
	tst d7
	bmi cancel_search
	move.l d0,ad_buffer_search(a3)

	move.l pos_curseur(a3),d0
	lsr.l #1,d0
	move.l d0,offset_search_fichier(a3)

continue_search:
	save.l a0

	move.w #FORM_SEARCH,d0
	move.w #FSCHG_BTON_STOP,d1
	move.w #0,d2		; enable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_SEARCH,d1
	move.w #1,d2		; disable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_CONT,d1
	move.w #1,d2		; disable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.l #1,objet_application+GWVA_APP_OBJ_COUNT
	move.l #search_in_file,objet_application+GWVA_APP_OBJ_EVNT_TIMER

	load.l a0

	move.l a0,ad_fenetre_search(a3)

	move.w #0,d0
	moveq #7,d1
	moveq #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

	rts

search_in_file:
	move.l add_structure_wind_look,a1
	move.l ad_fenetre_search(a1),a0

	move.l table_obj(a1),a2
	lea struct_searching_slider-fenetre_search(a0),a3
	move.l offset_search_fichier(a1),d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_POS(a3)
	move.w f_num_line(a2),d0
	ext.l d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_SIZE(a3)

	save.l a0-a1
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l a3,a2
	bsr GWVA_SLIDER_OBJ_PRG_SET_SLIDER
	load.l a0-a1

	save.l a0
	bsr load_buffer_search
	load.l a0
	tst.w d7
	bne stop_searching

	move.l d0,d3

	move.l ad_buffer_search(a1),a3

	sub.l #1,d0
	bmi .fin_de_fichier

	lea chaine_search(a1),a4
	move.w longueur_chaine_search(a1),d2
	sub.w #1,d2

.compare1:	move.l a4,a2
	move.w d2,d1
.compare2:	sub.w #1,d0

	cmp.b (a2)+,(a3)+
	beq.s .comp_ok

	tst d0
	bpl.s .compare1

.fin_de_buffer:
	cmp.l buffer_search_length(a1),d3
	bne.s .fin_de_fichier

	move.l buffer_search_length(a1),d0
	add.l d0,offset_search_fichier(a1)
	rts

.comp_ok:	tst d0
	bmi.s .fin_de_buffer_a_cheval
	dbf d1,.compare2

; la comparaison des deux chaines est exacte
.comparaison_exacte:
	move.l a3,d0
	sub.l ad_buffer_search(a1),d0
	move.w longueur_chaine_search(a1),d1
	ext.l d1
	sub.l d1,d0
	bpl.s .sur_ce_buffer
	add.l buffer_search_length(a1),d0
.sur_ce_buffer:
	add.l offset_search_fichier(a1),d0

	add.l d0,d0
	sub.l pos_curseur(a1),d0

	move.w #0,d1
	save.l a0-a1
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a0	; pointeur fenetre qui a fait le search
	bsr update_position_curs
	load.l a0-a1

	bra stop_searching


.fin_de_buffer_a_cheval:
	tst d1
	beq.s .comparaison_exacte

	cmp.l buffer_search_length(a1),d3
	bne.s .fin_de_fichier

	move.l buffer_search_length(a1),d0
	add.l d0,offset_search_fichier(a1)

	save.l a0
	bsr load_buffer_search
	load.l a0
	tst.w d7
	bne stop_searching
	
	move.l d0,d3

	move.l ad_buffer_search(a1),a3
	sub.w #1,d0
	bmi .fin_de_fichier

	dbf d1,.compare2	; au moins un tour
	illegal		; ne doit jamais sortir a ce niveau
	rts

.fin_de_fichier:
	save.l a0-a1
	move.w #ALERT_NO_MATCH,d0
	move.w #1,d1
	bsr RSC_ALERT_BOX
	load.l a0-a1

	bra stop_searching

load_buffer_search:
	save.l a1
	FILE_OPEN read,source_pathname(a1),d7
	load.l a1
	tst d7
	ble .erreur_open

	save.l a1
	FSEEK #0,d7,offset_search_fichier(a1)
	move.l (sp),a1
	FREAD ad_buffer_search(a1),buffer_search_length(a1),d7
	move.l (sp),a1

	save.l d0
	FCLOSE d7
	load.l d0

	load.l a1

	tst.l d0
	blt .erreur_read

	clr.w d7
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

cancel_search:
	save.l a0
	move.w #FORM_SEARCH,d0
	move.w #FSCHG_BTON_STOP,d1
	move.w #1,d2		; disable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_CONT,d1
	move.w #1,d2		; disable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_SEARCH,d1
	move.w #0,d2		; enable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.l #0,objet_application+GWVA_APP_OBJ_COUNT
	move.l #0,objet_application+GWVA_APP_OBJ_EVNT_TIMER
	load.l a0

	move.w #0,d0
	moveq #7,d1
	moveq #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a1	; structure look
	move.l ad_buffer_search(a1),d0
	clr.w longueur_chaine_search(a1)
	beq.s .not_searching
	clr.l ad_buffer_search(a1)
	save.l a0
	MFREE d0
	load.l a0
.not_searching:

	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a2
	sub.w #1,GWVA_WIND_OBJ_TOPABLE_STATE(a2)
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	rts

stop_searching:
	save.l a0
	move.w #FORM_SEARCH,d0
	move.w #FSCHG_BTON_STOP,d1
	move.w #1,d2		; disable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_SEARCH,d1
	move.w #0,d2		; enable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.w #FORM_SEARCH,d0
	move.w #FSCH_BTON_CONT,d1
	move.w #0,d2		; enable
	bsr GWVA_ENABLE_DISABLE_OBJECT

	move.l #0,objet_application+GWVA_APP_OBJ_COUNT
	move.l #0,objet_application+GWVA_APP_OBJ_EVNT_TIMER
	load.l a0

	save.l a0
	move.w #0,d0
	moveq #7,d1
	moveq #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l a0

	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a1	; structure look
	move.l offset_fichier(a1),offset_search_fichier(a1)
	move.l pos_curseur(a1),pos_search_curseur(a1)

	move.l table_obj(a1),a2
	lea struct_searching_slider-fenetre_search(a0),a3
	move.l offset_search_fichier(a1),d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_POS(a3)
	move.w f_num_line(a2),d0
	ext.l d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_SIZE(a3)

	save.l a0-a1
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l a3,a2
	bsr GWVA_SLIDER_OBJ_PRG_SET_SLIDER
	load.l a0-a1

	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a1	; structure look
	move.l ad_buffer_search(a1),d0
	clr.l ad_buffer_search(a1)
	MFREE d0

	rts

initialisation_fenetre_search:
	move.l GWVA_WIND_OBJ_USER_PTR2(a0),a1
	move.l table_obj(a1),a2

	lea struct_searching_slider-fenetre_search(a0),a3

	move.l source_length(a1),d0
	add.l #8+8-1,d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_LENGTH(a3)
	move.l offset_fichier(a1),d0
	divu.l #8+8,d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_POS(a3)

	move.w f_num_line(a2),d0
	ext.l d0
	move.l d0,GWVA_FORM_SLIDER_OBJ_SIZE(a3)

	save.l a0-a2
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l a3,a2
	bsr GWVA_SLIDER_OBJ_PRG_SET_SLIDER
	load.l a0-a2

	clr.w d7

	rts
