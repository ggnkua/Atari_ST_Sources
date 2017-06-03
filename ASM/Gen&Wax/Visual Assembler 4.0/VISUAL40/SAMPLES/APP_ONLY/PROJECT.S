	output d:\assemble\visual40\samples\app_only\project.app

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
	; Propri‚t‚ : ne marche uniquement qu'en programme
;---------------------------------------------------------------------------

my_inits:	tst GWVA_APP_OBJ_IS_ACC_PRG
	beq .no_acc_run

	rts

.no_acc_run:move #ALERT_NO_ACC_RUN,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	bra GWVA_INFINITE_LOOP

menu_information:
	lea objet_fenetre_info,a0
	bra GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND

routine_menu_quit:
app_term:
	bra VISUAL40_END

menu_open:	rts

 END
