	output d:\assemble\sources.v40\hardsafe.2\hardsaf2.acx

*OPT_FULL_PATHNAMES

	lea objet_application,a1

	include hardsaf2.def
	include visual40.s
	include hardsaf2.hs
	include hardsaf2.obj

	comment HEAD=7
	section TEXT

;---------------------------------------------------------------------------
	; Hard Disk Saver II
	; (c) Pierre LALOE 3 February 1996

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
	bsr XH_LOCATE_DRIVER

	tst d7
	beq.s .xhdi_here
	bsr noxhdi_box
	bra bton_quit_clicked		; sort si pas de XHDI
.xhdi_here:

	SUPEXEC XH_GET_VERSION

	cmp.w #$0125,XH_RETURN_CODE
	bge.s .good_version

	bsr badver_box
	bra.s .no_timer

.good_version:
	move.l #10000,objet_application+GWVA_APP_OBJ_COUNT
.no_timer:

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
	beq.s .no_park

	graf_mouse #BUSY_BEE

	clr d0			; XH_DEVICE_MAJOR

.do_park_all:
	save.w d0
	bsr stop_this_device
	load.w d0

	addq #1,d0
	cmp.w #8+8+2,d0
	bne.s .do_park_all

	graf_mouse #ARROW

.no_park:	rts

*--------------------------------------------------------------------------*

my_timer:	btst #0,struct_bton_active_timer+GWVA_FORM_BTON_OBJ_STATE+1
	beq.s .no_check

	tst.l XH_DRIVER_ROUTINE
	beq.s .no_check2

	bsr check_and_park

.no_check:	rts

.no_check2:	bsr XH_LOCATE_DRIVER

	tst d7
	bmi.s .never_come_back

	rts

.never_come_back:
	clr.l objet_application+GWVA_APP_OBJ_COUNT
	rts

*--------------------------------------------------------------------------*

check_and_park:

	clr d0

.redo:	clr XH_DEVICE_MINOR
	move d0,XH_DEVICE_MAJOR
	save.w d0
	SUPEXEC XH_LAST_ACCESS
	load.w d0

	tst XH_RETURN_CODE
	bne.s .no_drive

	move.l XH_NB_MS,d2
	move.l valeur_timer,d1
	mulu.l #1000,d1
	cmp.l d1,d2
	blt.s .next

	save.w d0
	bsr stop_this_device
	load.w d0

.no_drive:
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
	SUPEXEC XH_INQ_TARGET

	tst XH_RETURN_CODE
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
	SUPEXEC XH_STOP
	rts

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

badver_box:	move #ALERT_BAD_VERSIO,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	rts
*--------------------------------------------------------------------------*

	section BSS

valeur_timer:	ds.l 1	; parkage auto au bout de ... secondes

you_must_park_and_quit:	ds.w 1		; 1=...

*--------------------------------------------------------------------------*

 END
