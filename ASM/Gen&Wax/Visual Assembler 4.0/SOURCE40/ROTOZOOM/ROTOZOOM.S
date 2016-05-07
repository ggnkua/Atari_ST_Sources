	output d:\assemble\sources.v40\rotozoom\rotozoom.acx

;OPT_FULL_PATHNAMES

	lea objet_application,a1

	include rotozoom.def
	include visual40.s
	include rotozoom.hs
	include rotozoom.obj

	comment HEAD=7
	section TEXT

*---------------------------------------------------------------------------

acc_open:
menu_open:	
	cmp.w #16,GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2
	bne.s .pas16bitpixel

	lea objet_fenetre1,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

.pas16bitpixel:
	move #ALERT_NOT_16BIT,d0
	move #1,d1
	bsr RSC_ALERT_BOX
	rts

info:	lea objet_fenetre3,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

routine_menu_quit:
app_term:
acc_close:
	; quoi qu'il arrive, il y a 1 delete all win

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne VISUAL40_END

	rts

*---------------------------------------------------------------------
event_timer_rotozoom:
	lea objet_fenetre2,a0
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_OPENED
	tst d7
	bmi.s .pas_de_fenetre

	bsr ROTOZOOM

*	lea objet_fenetre2,a0
*	move.w #0,d0
*	move.w #7,d1
*	move.w #0,d2
*	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

	lea objet_fenetre2,a0

	move #16,GWVA_APP_OBJ_MSG_BUF+2*2
	move.l GWVA_WIND_OBJ_INTERNAL_X(a0),GWVA_APP_OBJ_MSG_BUF+4*2
	move.l GWVA_WIND_OBJ_INTERNAL_W(a0),GWVA_APP_OBJ_MSG_BUF+6*2

	move #0,GWVA_APP_OBJ_MSG_EXT_BUF
	move #7,GWVA_APP_OBJ_MSG_EXT_BUF+2
	move #0,GWVA_APP_OBJ_MSG_EXT_BUF+4		; contents

	bsr GWVA_WIND_OBJ_PRG_WM_REDRAW
	rts

.pas_de_fenetre:
	move.l #2000,GWVA_APP_OBJ_COUNT+objet_application
	rts

*---------------------------------------------------------------------

wind1_bton_ok_click:

	move.w #FORM_SIZE_XY,d0
	move.w #FSXY_TEXT_WIDTH,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a0
	clr.b d0
	bsr DECI2VALUE
	move.w d1,roto_zoom_w

	move.w #FORM_SIZE_XY,d0
	move.w #FSXY_TEXT_HEIGHT,d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a0
	clr.b d0
	bsr DECI2VALUE
	move.w d1,roto_zoom_h

	lea objet_fenetre1,a0
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND

	lea objet_fenetre2,a0
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND

	lea objet_fenetre2,a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l roto_zoom_w,GWVA_WBITM_OBJ_IMG_WIDTH(a1)
	move.l roto_zoom_w,GWVA_WIND_OBJ_FIRST_W(a0)
	move.w roto_zoom_w,d0
	mulu roto_zoom_h,d0
	mulu.l #16,d0
	divu.l #8,d0	; taille du buffer en octet
	move.l d0,d1

	save.l d1/a0-a1
	MXALLOC #RAM_TT_ST,d0
	load.l d1/a0-a1
	tst.l d0
	ble.s .pas_de_memoire

	move.l d0,GWVA_WBITM_OBJ_DATA_PTR(a1)

	move.l d0,a2
.clear_buf:	clr.b (a2)+
	sub.l #1,d1
	bne.s .clear_buf

	lea objet_fenetre2,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	tst d7
	bpl.s .wind_created

	move.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WBITM_OBJ_DATA_PTR),d0
	MFREE d0

	rts

.wind_created:
	lea objet_fenetre2,a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l GWVA_WBITM_OBJ_DATA_PTR(a1),a0
	movem.w roto_zoom_w,d0/d1
	bsr ROTO_INIT

	move.l #1,GWVA_APP_OBJ_COUNT+objet_application

.pas_de_memoire:
	rts

*---------------------------------------------------------------------

wind1_bton_annule_click:
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	rts

*---------------------------------------------------------------------

	include visuroto.s

*---------------------------------------------------------------------

	section DATA


	section BSS

roto_zoom_w:	ds.w 1
roto_zoom_h:	ds.w 1

 END
