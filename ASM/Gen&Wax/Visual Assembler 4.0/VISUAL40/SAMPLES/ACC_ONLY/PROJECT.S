	output d:\assemble\visual40\samples\acc_only\project.acc

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
	; Propri‚t‚ : ne marche uniquement qu'en accessoire
;---------------------------------------------------------------------------

my_inits:	move.w #ALERT_VA_COPYRIG,d0
	move #1,d1
	bsr RSC_ALERT_BOX

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne .no_app_run

	move.w #ALERT1,d0
	move #3,d1
	bsr RSC_ALERT_BOX
	rts

.no_app_run:move #ALERT_NO_APP_RUN,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	bra VISUAL40_END

acc_close:	rts

other_message:
	cmp.w #VA_START,d0
	beq.s .va_start
	rts

.va_start:	move.l 6(a0),a0

	save.l a0
	bsr GWVA_APP_OBJ_PRG_ACC_OPEN_VSTATION
	load.l a0
	tst d7
	bge.s acc_open
	rts

acc_open:	move.w #ALERT1,d0
	move #2,d1
	bsr RSC_ALERT_BOX
	rts

 END