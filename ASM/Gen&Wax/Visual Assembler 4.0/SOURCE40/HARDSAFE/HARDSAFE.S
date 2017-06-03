	output d:\assemble\sources.v40\hardsafe\hardsafe.acx

*OPT_FULL_PATHNAMES

	lea objet_application,a1

	include hardsafe.def
	include visual40.s
	include hardsafe.hs
	include hardsafe.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Hard Disk Saver, GEM part
	; (c) Pierre LALOE 21 January 1996

	; en accessoire, supporte le VA_START
;---------------------------------------------------------------------------

my_inits:	save.l d0/a0
	bsr bton_active_changed	; charge la valeur du ressource
	load.l d0/a0

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne.s .prg
	rts

.prg:	tst d0
	beq.s .no_cmd_line

	cmp.l #'park',(a0)
	bne.s .pas_park
	move #1,you_must_park_and_quit
	bra.s .cmd_line_ok
.pas_park:

	cmp.l #'time',(a0)
	bne.s .pas_time
	lea 5(a0),a0
	clr.b d0
	bsr DECI2VALUE
	cmp.l #999,d1
	bgt.s .bad_cmd_line
	cmp.l #10,d1
	blt.s .bad_cmd_line
	move.l d1,valeur_timer
	bra.s .cmd_line_ok

.pas_time:
.bad_cmd_line
	move #ALERT_BAD_CMD_LN,d0
	move #1,d1
	bsr RSC_ALERT_BOX

.cmd_line_ok:
.no_cmd_line:

acc_open:
	bsr init_2ptrs

	tst.l XH_DRIVER_ROUTINE
	bne.s .xhdi_here
	bsr noxhdi_box
	bra bton_quit_clicked		; sort si pas de XHDI
.xhdi_here:

	tst.l pointeur_auto_prg
	bne.s .auto_here
	bsr noauto_box
	bra.s .cont
.auto_here:	move.l #10000,objet_application+GWVA_APP_OBJ_COUNT
.cont:

	cmp #1,you_must_park_and_quit
	bne.s .no_cmd_park		; cmd_line = 'park' ?

	bsr park_all_disks		; oui !
	bra bton_quit_clicked
.no_cmd_park:

	move #FORM_MAIN,d0		; si ligne de cmd l'a chang‚
	move #TEXTE_TIMER,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l valeur_timer,d0
	bsr STOCK_DECI

	lea objet_fenetre_main,a0
	bra GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND

			*******
other_message:
	cmp.w #VA_START,d0
	beq.s .va_start
	rts

.va_start:	move.l 6(a0),a0
	cmp.l #'park',(a0)
	beq park_all_disks

	cmp.l #'time',(a0)
	bne.s .pas_time
	lea 5(a0),a0
	clr.b d0
	bsr DECI2VALUE
	cmp.l #999,d1
	bgt.s .bad_cmd_line
	cmp.l #10,d1
	blt.s .bad_cmd_line
	move.l d1,valeur_timer
	rts

.pas_time:
.bad_cmd_line:
	move #ALERT_BAD_CMD_LN,d0
	move #1,d1
	bsr RSC_ALERT_BOX

	rts
*--------------------------------------------------------------------------*
app_term:
bton_quit_clicked:
event_window_main_closed:

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne VISUAL40_END

acc_close:	lea objet_fenetre_main,a0
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND	; pour l'acc
	rts
	
*--------------------------------------------------------------------------*
init_2ptrs:	bsr XH_LOCATE_DRIVER

	move.l #HDV_RW,GWVA_APP_OBJ_SEARCH_IN_OUT
	move.l #'HDSv',GWVA_APP_OBJ_SEARCH_IN_OUT+4
	SUPEXEC GWVA_APP_OBJ_SEARCH_ONE_XBRA

	clr.l pointeur_auto_prg
	tst.l GWVA_APP_OBJ_SEARCH_IN_OUT
	beq.s .resident_not_here

	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,a0
	move.l 2(a0),pointeur_auto_prg		; bra.s
	bra.s .resident_here

.resident_not_here:

.resident_here:
	rts

*--------------------------------------------------------------------------*
bton_active_changed:

	move #FORM_MAIN,d0
	move #TEXTE_TIMER,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a0
	clr.b d0
	bsr DECI2VALUE
	move.l d1,valeur_timer
	rts

*--------------------------------------------------------------------------*
bton_park_now_clicked:
park_all_disks:
	tst.l XH_DRIVER_ROUTINE
	beq .no_park

	graf_mouse #BUSY_BEE
	SUPEXEC park_all_disk_super
	graf_mouse #ARROW

.no_park:	rts

park_all_disk_super:
	clr d0			; XH_DEVICE_MAJOR

.do_park_all:
	save.w d0
	bsr stop_this_device
	load.w d0

	addq #1,d0
	cmp.w #8+8+2,d0
	bne.s .do_park_all

	rts
*--------------------------------------------------------------------------*

my_timer:	btst #0,struct_bton_active_timer+GWVA_FORM_BTON_OBJ_STATE+1
	beq.s .no_check

	tst.l XH_DRIVER_ROUTINE
	beq.s .no_check2

	tst.l pointeur_auto_prg
	beq.s .no_check2

	SUPEXEC check_and_park

.no_check:	rts

.no_check2:	bsr init_2ptrs

	tst.l XH_DRIVER_ROUTINE
	beq.s .never_come_back
	tst.l pointeur_auto_prg
	beq.s .never_come_back

	rts

.never_come_back:
	clr.l objet_application+GWVA_APP_OBJ_COUNT
	rts

			*******
check_and_park:
	move.l pointeur_auto_prg,a0

	clr d0

.redo:	move.l (a0)+,d1
	beq.s .next
	move.l cpt_200,d2
	sub.l d1,d2

	move.l valeur_timer,d1
	mulu.l #200,d1
	cmp.l d1,d2
	blt.s .next

	save.l d0/a0
	bsr stop_this_device
	load.l d0/a0

.next:	addq #1,d0
	cmp.w #8+8+2,d0
	bne.s .redo

	rts

*--------------------------------------------------------------------------*
stop_this_device:			; d0=device
	save.w d0

	clr.l XH_PRODUCTNAME
	clr.w XH_DEVICE_MINOR
	move.w d0,XH_DEVICE_MAJOR
	bsr XH_INQ_TARGET

	tst d0
	bmi.s .do_not_exist

	btst #0,XH_DEVICE_FLAGS+3
	beq.s .cannot_be_stopped
	btst #30-16-8,XH_DEVICE_FLAGS
	bne.s .already_stopped

	btst #1,XH_DEVICE_FLAGS+3
	beq.s .medium_non_removable
	btst #0,struct_bton_park_removable+GWVA_FORM_BTON_OBJ_STATE+1
	beq.s .do_not_park_removable
.medium_non_removable:

	load.w d0

	clr.w XH_DEVICE_MINOR
	clr.w XH_DEVICE_KEY
	move #1,XH_DO_STOP
	move.w d0,XH_DEVICE_MAJOR
	bra XH_STOP

.do_not_park_removable:
.do_not_exist:
.cannot_be_stopped:
.already_stopped:
	load.w d0
	rts
*--------------------------------------------------------------------------*
noxhdi_box:	move #ALERT_NO_XHDI,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	rts

noauto_box:	move #ALERT_NO_AUTOPRG,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	rts
*--------------------------------------------------------------------------*

	section BSS

valeur_timer:	ds.l 1	; parkage auto au bout de ... secondes

pointeur_auto_prg:	ds.l 1
you_must_park_and_quit:	ds.w 1		; 1=...

*--------------------------------------------------------------------------*

 END
