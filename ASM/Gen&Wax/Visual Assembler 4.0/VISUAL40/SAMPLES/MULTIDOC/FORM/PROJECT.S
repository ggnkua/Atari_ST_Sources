	output d:\assemble\visual40\samples\multidoc\form\project.acx

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
	; il permet d'ouvrir autant de fenˆtres formulaire que de m‚moire disponible

;---------------------------------------------------------------------------

my_inits:
	move #FORM_GENERATION1,d0
	move window_form_clone1_specs+GWVA_WFORM_OBJ_IS_CLONE_FORM,d1
	move.l #0,a0
	bsr GWVA_WFORM_OBJ_PRG_SAVE_FORM
	tst d7
	bmi.s .erreur	; annule l'ouverture si pas pu sauver
	move.l a0,sauve_etat_form1

	move #FORM_GENERATION2,d0
	move window_form_clone2_specs+GWVA_WFORM_OBJ_IS_CLONE_FORM,d1
	move.l #0,a0
	bsr GWVA_WFORM_OBJ_PRG_SAVE_FORM
	tst d7
	bmi.s .erreur2	; annule l'ouverture si pas pu sauver
	move.l a0,sauve_etat_form2

	clr.l pointeur_principal_clone_wind1
	clr.l pointeur_principal_clone_wind2

	rts

.erreur2:	MFREE sauve_etat_form1
.erreur:	bra routine_menu_quit

menu_information:
	lea objet_fenetre_info,a0
	bra GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND

acc_open:
menu_open1:	lea fenetre_form_clone1,a0
	move.l sauve_etat_form1,a1
	bra create_form

menu_open2:	lea fenetre_form_clone2,a0
	move.l sauve_etat_form2,a1
	bra create_form

routine_menu_quit:
app_term:
acc_close:
	tst GWVA_APP_OBJ_IS_ACC_PRG
	beq.s .acc

	MFREE sauve_etat_form1
	clr.l sauve_etat_form1
	MFREE sauve_etat_form2
	clr.l sauve_etat_form2

	bra VISUAL40_END

.acc:	rts

create_form:
	; a0 = ptr sur une structure de fenˆtre formulaire
	; a1 = ptr sur une sauvegarde d'un contenu de formulaire

	save.l a0-a1
	move.l #fin_fenetre_form_clone1-fenetre_form_clone1,d0
	MXALLOC #RAM_TT_ST,d0
	load.l a0-a1
	tst.l d0
	ble .err_malloc		; plus de m‚moire

	move.l d0,a2

	move.l #fin_fenetre_form_clone1-fenetre_form_clone1,d1
.copy:	move.b (a0)+,(a2)+
	subq.l #1,d1
	bne.s .copy

	move.l d0,a0

	add.l d0,GWVA_WIND_OBJ_NAME(a0)	; reloge
	add.l d0,GWVA_WIND_OBJ_SPEC_PTR(a0)
	move.l d0,GWVA_WIND_OBJ_USER_PTR1(a0)
	; sera lib‚r‚ automatiquement car on a mis le bit 10 des PROPERTIES

	save.l a0
	move.l a1,a0
	move.l #0,a1
	bsr GWVA_WFORM_OBJ_PRG_COPY_SAVED_FORM
	move.l a0,a2
	load.l a0
	tst d7
	bmi.s .erreur_copy

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l a2,GWVA_WFORM_OBJ_CLONE_FORM_SAVE(a1)

	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	; si la cr‚ation ‚choue ... la m‚moire a ‚t‚ lib‚r‚e
	; soit : CLONE_FORM_SAVE et USR_PTR1

	rts

.erreur_copy:
	MFREE GWVA_WIND_OBJ_USER_PTR1(a0)
.err_malloc:rts

	section DATA


	section BSS

sauve_etat_form1:	ds.l 1	; formulaire d'origine intact pour copie
sauve_etat_form2:	ds.l 1

pointeur_principal_clone_wind1:	ds.l 1	; No form actif
pointeur_principal_clone_wind2:	ds.l 1

 END
