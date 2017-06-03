		*--------------------------*
GWVA_WIND_OBJ_PRG_RETURN_PTR_FROM_HANDLE:	; In d0=handle Out a0=ptr+d7

	tst d0
	bmi.s .bad_handle

	lea GWVA_APP_OBJ_WIND_LIST,a0
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d1
.search:	tst.l (a0)
	beq.s .no
	move.l (a0),a1
	cmp.w GWVA_WIND_OBJ_GEM_HANDLE(a1),d0
	beq.s .found
.no:	lea 4(a0),a0
	dbf d1,.search
.bad_handle:moveq #GWVA_ERROR_GENERIC,d7
	rts
.found:	move.l (a0),a0
	clr d7
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED:	; a0 = ptr

	tst GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi.s .no_exist

	clr d7			; d7=0 si existe
	rts

.no_exist:	moveq #GWVA_ERROR_GENERIC,d7	; d7=-1 sinon
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_TEST_IF_WIND_OPENED:	; a0=ptr

	tst GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi.s .no_exist

	btst #GWVA_WIN_BIT_OPEN,GWVA_WIND_OBJ_STATUS+1(a0)
	beq.s .fermee
	clr d7			; d7=0 si ouverte
	rts
.fermee:
.no_exist:
	moveq #GWVA_ERROR_GENERIC,d7	; d7=-1 si ferm‚e
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW:	; renvoie a0.l = ptr fenetre, d0.w = handle gem, d7.w = erreur

	wind_get #0,#WF_TOP		; donne la window top
	move.w int_out+1*2,d0
	bsr.s GWVA_WIND_OBJ_PRG_RETURN_PTR_FROM_HANDLE
	rts
		*--------------------------*
GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART:
; Entr‚  :	a0   : ptr
;	a1   : ptr liste obj/depth si d2=3
;	d0.w : num‚ro de l'objet (0 pour tout)
;	d1.w : profondeur du redraw (7 pour tout)
;	d2.w : -1=all wind 0=content 1=toolbar 2=menu 3=(a1)list of
;	       object/depth -1 to end, beware of GEM's msg buff max size
	save.l d0-d2/a1
	bsr.s GWVA_WIND_OBJ_PRG_TEST_IF_WIND_OPENED
	load.l d0-d2/a2
	tst d7
	bmi .fenetre_fermee

	moveq #16,d7
	move.w #WM_GWVA_REDRAW,d6	; messages perso. ; bit 14 pour ‚viter un message n‚gatif
	cmp.w #3,d2
	beq.s .liste_obj
	tst d0
	bne.s .pas_tout
	cmp.w #7,d1
	bne.s .pas_tout
	clr.l d7			; si c'est tout on envoie
	move.w #WM_REDRAW,d6		; un message normal
	bra.s .partiel
.liste_obj:	move.l a2,a3
	moveq #4,d3			; 2 tete + 2 fin
.count:	tst.w (a3)
	bmi.s .end
	addq #4,d3
	lea 2+2(a3),a3
	bra.s .count
.end:	add #15,d3
	and.w #$fff0,d3
	move d3,d7
.partiel:
.pas_tout:
; si d7=16 alors c'est un redraw partiel si d7=0 c'est un redraw total

	lea GWVA_APP_OBJ_MSG_EXT_BUF,a1
	move.w d6,(a1)+
	move.w global+_AESapid,(a1)+
	move.w d7,(a1)+
	move.w GWVA_WIND_OBJ_GEM_HANDLE(a0),(a1)+

	move.w GWVA_WIND_OBJ_INTERNAL_X(a0),(a1)+

	tst d2
	bmi.s .everything
	beq.s .contents_only

	cmp #1,d2
	beq.s .toolbar_only

	cmp #2,d2
	beq.s .menu_only

	cmp #3,d2
	beq.s .list_of_objects

	rts			; erreur

.everything:move GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d5
	add GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d5
	move.w GWVA_WIND_OBJ_INTERNAL_Y(a0),(a1)+
	sub d5,-2(a1)
	move.w GWVA_WIND_OBJ_INTERNAL_W(a0),(a1)+
	move.w GWVA_WIND_OBJ_INTERNAL_H(a0),(a1)+
	add d5,-2(a1)
	bra.s .send_msg

.contents_only:
	move.w GWVA_WIND_OBJ_INTERNAL_Y(a0),(a1)+
	move.w GWVA_WIND_OBJ_INTERNAL_W(a0),(a1)+
	move.w GWVA_WIND_OBJ_INTERNAL_H(a0),(a1)+
	bra.s .send_msg

.toolbar_only:
	move GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d5
	move.w GWVA_WIND_OBJ_INTERNAL_Y(a0),(a1)+
	sub d5,-2(a1)
	move.w GWVA_WIND_OBJ_INTERNAL_W(a0),(a1)+
	move.w d5,(a1)+
	bra.s .send_msg

.menu_only:
	move GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d5
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d5
	move.w GWVA_WIND_OBJ_INTERNAL_Y(a0),(a1)+
	sub d5,-2(a1)
	move.w GWVA_WIND_OBJ_INTERNAL_W(a0),(a1)+
	move.w GWVA_WIND_OBJ_MENU_HEIGHT(a0),(a1)+
	bra.s .send_msg

.list_of_objects:
	move.w GWVA_WIND_OBJ_INTERNAL_Y(a0),(a1)+
	move.w GWVA_WIND_OBJ_INTERNAL_W(a0),(a1)+
	move.w GWVA_WIND_OBJ_INTERNAL_H(a0),(a1)+
	clr.w (a1)+			; 0 : redraw content
.recop:	move.w (a2)+,(a1)+		; en 2 .w pour en mettre 63
	cmp.w #-1,-2(a1)
	beq.s .send_msg2
	move.w (a2)+,(a1)+
	bra.s .recop

.send_msg:	move.w d2,(a1)+
	move.w d0,(a1)+
	move.w d1,(a1)+
	move.w #-1,(a1)+		; pour ˆtre compatible !

.send_msg2:	add #16,d7			; les 16 incompressibles

	save.l a0
	appl_write global+_AESapid,d7,#GWVA_APP_OBJ_MSG_EXT_BUF
	load.l a0
	; pas de test d'erreur
.send_nothing:
.fenetre_fermee:
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_DELETE_ALL_WIND:		; delete qui ferme
	lea GWVA_APP_OBJ_WIND_LIST,a0
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0

.search:	tst.l (a0)
	beq.s .nothing
	save.l d0/a0
	move.l (a0),a0
	bsr.s GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	load.l d0/a0
.nothing:	lea 4(a0),a0
	dbf d0,.search
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND:		; a0=ptr sur structure
	tst.w GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi.s .deja_efface

	lea GWVA_APP_OBJ_WIND_LIST,a1
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.search:	tst.l (a1)
	beq.s .no
	move.l (a1),d1
	cmp.l a0,d1
	beq.s .moi
.no:	lea 4(a1),a1
	dbf d0,.search
	illegal
.moi:	clr.l (a1)			; me virer moi !

	bsr GWVA_WIND_OBJ_PRG_CLOSE_ONE_WIND

	move.w GWVA_WIND_OBJ_GEM_HANDLE(a0),d1
	move.w #-1,GWVA_WIND_OBJ_GEM_HANDLE(a0)

	save.w d1
	bsr.s GWVA_WIND_OBJ_PRG_UNALLOCATE_MEMORY
	load.w d1

	save.l a0
	wind_delete d1
	load.l a0

	rts

.deja_efface:
	move #GWVA_ERROR_GENERIC,d7
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_UNALLOCATE_MEMORY:	; a0=ptr sur structure

	save.l a0

	ifd MDL_WIND_FORM

	cmp #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_form

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	tst.w GWVA_WFORM_OBJ_IS_CLONE_FORM(a1)
	beq.s .not_a_clone

	clr.l ([GWVA_WFORM_OBJ_CLONE_MAIN_PTR,a1])
.not_a_clone:

	btst #GWVA_WIN_BIT_FREEFORM-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .no_free_form
	move.l GWVA_WFORM_OBJ_CLONE_FORM_SAVE(a1),d0
	beq.s .zero
	clr.l GWVA_WFORM_OBJ_CLONE_FORM_SAVE(a1)
	MFREE d0
	move.l (sp),a0
.zero:
.no_free_form:
.pas_form:

	endc

	ifd MDL_WIND_TEXT

	cmp #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .not_text
	move.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WTEXT_OBJ_MALOC),d0
	beq.s .not_text
	clr.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WTEXT_OBJ_MALOC)
	MFREE d0
	move.l (sp),a0
.not_text:
	endc

	ifd MDL_WIND_BITMAP

	cmp #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .not_bitmap
	btst #GWVA_WIN_BIT_FREEDATA-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .no_free_data_ptr
	move.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WBITM_OBJ_DATA_PTR),d0
	beq.s .zero1
	MFREE d0
.zero1:	move.l (sp),a0
	clr.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WBITM_OBJ_DATA_PTR)
.no_free_data_ptr:
	btst #GWVA_WIN_BIT_FREEPAL-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .no_free_pal_ptr
	move.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WBITM_OBJ_PAL_PTR),d0
	beq.s .zero2
	MFREE d0
.zero2:	move.l (sp),a0
	clr.l ([GWVA_WIND_OBJ_SPEC_PTR,a0],GWVA_WBITM_OBJ_PAL_PTR)
.no_free_pal_ptr:
.not_bitmap:
	endc

	; mettre la lib‚ration des user ptr1&2 aprŠs la lib‚ des autres
	; au cas o— la structure de fenˆtre serait justement ce Malloc

	clr.l d0
	btst #GWVA_WIN_BIT_FREEPTR1-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .no_free_ptr1
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),d0
	clr.l GWVA_WIND_OBJ_USER_PTR1(a0)
.no_free_ptr1:
	clr.l d1
	btst #GWVA_WIN_BIT_FREEPTR2-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .no_free_ptr2
	move.l GWVA_WIND_OBJ_USER_PTR2(a0),d1
	clr.l GWVA_WIND_OBJ_USER_PTR2(a0)
.no_free_ptr2:
	tst.l d0
	beq.s .zero3
	save.l d1
	MFREE d0
	load.l d1
.zero3:	tst.l d1
	beq.s .zero4
	MFREE d1
.zero4:
	load.l a0
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_CLOSE_ALL_WIND:
	lea GWVA_APP_OBJ_WIND_LIST,a0
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0

.search:	tst.l (a0)
	beq.s .nothing
	save.l d0/a0
	move.l (a0),a0
	bsr.s GWVA_WIND_OBJ_PRG_CLOSE_ONE_WIND
	load.l d0/a0
.nothing:	lea 4(a0),a0
	dbf d0,.search
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_CLOSE_ONE_WIND:		; a0=ptr sur structure
	tst.w GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi.s .rien

	bclr #GWVA_WIN_BIT_CURS,GWVA_WIND_OBJ_STATUS+1(a0)	; curseur effac‚
	bclr #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)	; la fenˆtre est non namifi‚e

	bclr #GWVA_WIN_BIT_OPEN,GWVA_WIND_OBJ_STATUS+1(a0)	; la fenˆtre est ferm‚e
	beq.s .deja_ferme

	btst #GWVA_WIN_BIT_COPYXY-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .pas_copy_pos
	move.l GWVA_WIND_OBJ_EXTERNAL_X(a0),GWVA_WIND_OBJ_FIRST_X(a0)
.pas_copy_pos:

	save.l a0
	wind_close <GWVA_WIND_OBJ_GEM_HANDLE(a0)>

	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE
	endc

	load.l a0

.rien:
.deja_ferme:
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_OPEN_ALL_WIND:
	lea GWVA_APP_OBJ_WIND_LIST,a0
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0

.search:	tst.l (a0)
	beq.s .nothing
	save.l d0/a0
	move.l (a0),a0
	bsr.s GWVA_WIND_OBJ_PRG_OPEN_ONE_WIND
	load.l d0/a0
.nothing:	lea 4(a0),a0
	dbf d0,.search
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND:	; a0 = ptr
	save.l a0
	bsr GWVA_APP_OBJ_CREATE_WINDOW
	load.l a0

	cmp.w #GWVA_ERROR_WIND_ALREADY_CREATED,d7
	beq.s .open_window

	tst d7
	bmi.s .no_create

.open_window:
	bsr.s GWVA_WIND_OBJ_PRG_OPEN_ONE_WIND

	cmp.w #GWVA_ERROR_WIND_USER_CANCEL_OPEN,d7
	bne.s .open_wasnt_user_cancelled
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
.open_wasnt_user_cancelled:

.no_create:	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_OPEN_ONE_WIND:		; a0 = ptr
	tst GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi .bad_handle

	bset #GWVA_WIN_BIT_OPEN,GWVA_WIND_OBJ_STATUS+1(a0)
	bne .deja_ouvert

	save.l a0
	move.w #WM_GWVA_OPENED+WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	tst d7
	bmi .erreur_user_cancelled
	v_hide_c
	move.l (sp),a0
	wind_open GWVA_WIND_OBJ_GEM_HANDLE(a0),GWVA_WIND_OBJ_EXTERNAL_X(a0),GWVA_WIND_OBJ_EXTERNAL_Y(a0),GWVA_WIND_OBJ_EXTERNAL_W(a0),GWVA_WIND_OBJ_EXTERNAL_H(a0)
	save.w d0
	v_show_c #0
	load.w d0
	load.l a0
	tst d0
	beq .erreur_open

	save.l a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_CURRXYWH	; get external size
	move.l (sp),a0
; si la taille externe affich‚e n'est pas celle qui a ‚t‚ demand‚e
	movem.w int_out+2,d0-d3

	bsr GWVA_WIND_OBJ_PRG_CALC_SIZE_WIND	; on force quand mˆme

	move.l (sp),a0
	move.w #WM_GWVA_OPENED+WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l a0

	tst GWVA_WIND_OBJ_TOPABLE_STATE(a0)		; untoppable ?
	ble.s .toppable

	lea GWVA_APP_OBJ_WIND_LIST,a1
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.search:	tst.l (a1)
	beq.s .rien_ici
	btst #GWVA_WIN_BIT_OPEN,(GWVA_WIND_OBJ_STATUS+1,[a1])	; est-elle ouverte ?
	beq.s .closed
	tst (GWVA_WIND_OBJ_TOPABLE_STATE,[a1])		; est-elle untoppable ?
	ble.s .there_is_one_toppable
.closed:
.rien_ici:	lea 4(a1),a1
	dbf d0,.search
	bra.s .fin

.there_is_one_toppable:
	lea GWVA_APP_OBJ_MSG_EXT_BUF,a2
	move.w #WM_TOPPED,(a2)+
	move.w global+_AESapid,(a2)+
	move.w #0,(a2)+
	move.w (GWVA_WIND_OBJ_GEM_HANDLE,[a1]),(a2)+
	clr.l (a2)+
	clr.l (a2)+
	save.l a0
	appl_write global+_AESapid,#16,#GWVA_APP_OBJ_MSG_EXT_BUF
	load.l a0
.fin:
.toppable:
	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE	; sauve a0
	endc

	clr d7
	rts
.deja_ouvert:
	bsr GWVA_WIND_OBJ_PRG_TOP_ONE_WIND
	clr d7
	rts
.bad_handle:
	move #GWVA_ERROR_WIND_BAD_HANDLE,d7
	rts
.erreur_open:
	move #GWVA_ERROR_WIND_OPEN,d7
	rts
.erreur_user_cancelled:
	load.l a0
	bclr #GWVA_WIN_BIT_OPEN,GWVA_WIND_OBJ_STATUS+1(a0)
	move #GWVA_ERROR_WIND_USER_CANCEL_OPEN,d7
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_CALC_SIZE_WIND:		; a0=ptr structure d0,d1=X,Y externe d2,d3=W,H d‚sir‚s
; … partir d'un X,Y,W,H externe en pixels d‚sir‚ remet toutes les infos de la fenˆtre … jour
; ATTENTION : pas de v‚rification
; i.e : internal x,y,w,h et external x,y,w,h

; ATTENTION A LA CREATION DES FENETRES : ELLES DOIVENT AVOIR UNE TAILLE
; MINIMALE A L'OUVERTURE ; SINON LE GEM LES RESIZE AU PREMIER 'MOVE'

	save.l a0
	; ext -> int
	wind_calc #1,GWVA_WIND_OBJ_FLAGS(a0),d0,d1,d2,d3
	move.l (sp),a0

	movem.w int_out+2,d0-d3			; x,y,w,h

	; si toolbar
	add GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d1
	sub GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d3
	; si menu
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d1
	sub GWVA_WIND_OBJ_MENU_HEIGHT(a0),d3

	movem.w d0-d1,GWVA_WIND_OBJ_INTERNAL_X(a0)	; x,y

	ifd MDL_WIND_TEXT
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d2
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d2
	mulu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d2	; on enlŠve les demi-carac
	ext.l d3
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d3
	mulu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d3
.pas_texte:
	endc

	movem.w d2-d3,GWVA_WIND_OBJ_INTERNAL_W(a0)	; taille interne

	move.l (sp),a0
	; int -> externe


	; si toolbar
	sub GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d1
	add GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d3
	; si menu
	sub GWVA_WIND_OBJ_MENU_HEIGHT(a0),d1
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d3

	wind_calc #0,GWVA_WIND_OBJ_FLAGS(a0),d0,d1,d2,d3

	move.l (sp),a0
	move.l int_out+2,GWVA_WIND_OBJ_EXTERNAL_X(a0)	; nouvelle position externe
	move.l int_out+6,GWVA_WIND_OBJ_EXTERNAL_W(a0)	; nouvelle taille externe

	tst GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi.s .not_yet_created

	move.l GWVA_WIND_OBJ_EXTERNAL_X(a0),int_in+4
	move.l GWVA_WIND_OBJ_EXTERNAL_W(a0),int_in+8

	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)	; namified ?
	beq.s .pas_namifiee

	move.w GWVA_WIND_OBJ_INTERNAL_H(a0),d0
	add GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d0
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d0
	sub.w d0,int_in+10

.pas_namifiee:

	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_CURRXYWH
	move.l (sp),a0

.not_yet_created:

	bsr.s GWVA_WIND_OBJ_PRG_UPDATE_TOOLB_AND_FORM_POS

	load.l a0

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_UPDATE_TOOLB_AND_FORM_POS:	; a0=ptr fenetre

	btst #GWVA_WIN_BIT_ATOOLBAR,GWVA_WIND_OBJ_PROPERTIES+1(a0)
	beq.s .no_toolbar

	move.l (GWVA_WFORM_OBJ_FORM_PTR,[GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR,a0]),a2
	move.l GWVA_WIND_OBJ_INTERNAL_X(a0),ob_x(a2)	; positionne
	move (GWVA_WFORM_OBJ_L_SCULPT,[GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR,a0]),d0
	add d0,ob_x(a2)
	move (GWVA_WFORM_OBJ_H_SCULPT,[GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR,a0]),d0
	sub d0,ob_y(a2)
	move (GWVA_WFORM_OBJ_T_SCULPT,[GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR,a0]),d0
	add d0,ob_y(a2)
.no_toolbar:

	ifd MDL_WIND_FORM

	cmp #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_form

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	tst.w GWVA_WFORM_OBJ_IS_CLONE_FORM(a1)
	beq.s .not_a_clone

	move.l ([GWVA_WFORM_OBJ_CLONE_MAIN_PTR,a1]),a2	; forc‚ment mˆme famille
	cmp.l #0,a2
	beq.s .no_last_one_so_no_save

	cmp.l a2,a0
	beq.s .c_est_moi

	move.l GWVA_WIND_OBJ_SPEC_PTR(a2),a3

	save.l a0-a1
	move.w GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	move.w GWVA_WFORM_OBJ_IS_CLONE_FORM(a1),d1
	move.l GWVA_WFORM_OBJ_CLONE_FORM_SAVE(a3),a0
	bsr GWVA_WFORM_OBJ_PRG_SAVE_FORM
	load.l a0-a1

.no_last_one_so_no_save:

	save.l a0-a1
	move.w GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	move.w GWVA_WFORM_OBJ_IS_CLONE_FORM(a1),d1
	move.l GWVA_WFORM_OBJ_CLONE_FORM_SAVE(a1),a0
	bsr GWVA_WFORM_OBJ_PRG_RESTORE_FORM
	load.l a0-a1

	move.l a0,([GWVA_WFORM_OBJ_CLONE_MAIN_PTR,a1])

.c_est_moi:
.not_a_clone:

	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a2
	move.l GWVA_WIND_OBJ_INTERNAL_X(a0),ob_x(a2)	; positionne
	; pas de toolbar car les coords sont internes modifi‚es pour
	; tenir compte de la toolbar

	move.w GWVA_WFORM_OBJ_L_SCULPT(a1),d0
	add d0,ob_x(a2)
	move.w GWVA_WFORM_OBJ_T_SCULPT(a1),d0
	add d0,ob_y(a2)

.pas_form:
	endc
	rts

		*--------------------------*
GWVA_WIND_OBJ_PRG_ICONIFY_ONE_WIND:			; a0=ptr
	save.l a0
	movem.w GWVA_APP_OBJ_MSG_BUF+4*2,d0-d3	; x,y,w,h
	movem.w d0-d3,int_in+4
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_ICONIFY
	load.l a0
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_UNICONIFY_ONE_WIND:		; a0=ptr
	save.l a0
	movem.w GWVA_APP_OBJ_MSG_BUF+4*2,d0-d3	; x,y,w,h
	movem.w d0-d3,int_in+4
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_UNICONIFY
	load.l a0
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_BOTTOM_ONE_WIND:
	save.l a0
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_BOTTOM
	load.l a0
	bsr GWVA_WIND_OBJ_PRG_UNTOP_ONE_WIND
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_ONTOP_ONE_WIND:			; a0=ptr
	tst GWVA_WIND_OBJ_TOPABLE_STATE(a0)		; untoppable ?
	ble.s .toppable

; Une autre solution au problŠme des fenˆtres untopables :
;	save.l a0
;	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_BOTTOM
;	load.l a0

	lea GWVA_APP_OBJ_WIND_LIST,a1
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.search:	tst.l (a1)
	beq.s .rien_ici
	btst #GWVA_WIN_BIT_OPEN,(GWVA_WIND_OBJ_STATUS+1,[a1])	; est-elle ouverte ?
	beq.s .closed
	tst (GWVA_WIND_OBJ_TOPABLE_STATE,[a1])	; est-elle untoppable ?
	ble.s .there_is_one_toppable
.closed:
.rien_ici:	lea 4(a1),a1
	dbf d0,.search
	bra.s .fin

.there_is_one_toppable:
	lea GWVA_APP_OBJ_MSG_EXT_BUF,a2
	move.w #WM_TOPPED,(a2)+
	move.w global+_AESapid,(a2)+
	move.w #0,(a2)+
	move.w (GWVA_WIND_OBJ_GEM_HANDLE,[a1]),(a2)+
	clr.l (a2)+
	clr.l (a2)+
	save.l a0
	appl_write global+_AESapid,#16,#GWVA_APP_OBJ_MSG_EXT_BUF
	load.l a0
.fin:
.toppable:
	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE	; sauve a0
	endc

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_NEWTOP_ONE_WIND:			; a0=ptr
GWVA_WIND_OBJ_PRG_TOP_ONE_WIND:			; a0=ptr

	tst GWVA_WIND_OBJ_TOPABLE_STATE(a0)		; untoppable ?
	bgt.s .untoppable
					; un_untoppable ?
	blt.s .un_untoppable			; passe droit au cas oui il y aurait 2 un_untoppable

	lea GWVA_APP_OBJ_WIND_LIST,a1
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.search1:	tst.l (a1)
	beq.s .rien_ici
	move.l (a1),d1
	cmp.l a0,d1
	beq.s .pas_moi
	btst #GWVA_WIN_BIT_OPEN,(GWVA_WIND_OBJ_STATUS+1,[a1])	; est-elle ouverte ?
	beq.s .closed
	tst (GWVA_WIND_OBJ_TOPABLE_STATE,[a1])	; est-elle un_untoppable ?
	blt.s .there_is_one_ununtoppable
.closed:
.pas_moi:
.rien_ici:	lea 4(a1),a1
	dbf d0,.search1

.un_untoppable:
	save.l a0
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_TOP
	load.l a0

	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE	; sauve a0
	endc

.there_is_one_ununtoppable:
.untoppable:
	rts
		*--------------------------*

GWVA_WIND_OBJ_PRG_UNTOP_ONE_WIND:			; a0=ptr
	
	ifd MDL_WIND_BITMAP		; si un accessoire s'ouvre
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE	; sauve a0
	endc

	ifd MDL_WIND_FORM

	cmp #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_form

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	tst GWVA_WFORM_OBJ_FOCUSED_TXT(a1)
	beq.s .no_ed_txt

	bclr #GWVA_WIN_BIT_CURS,GWVA_WIND_OBJ_STATUS+1(a0)	; curseur effac‚

	move.w #0,d0
	move.w #7,d1
	clr d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
.no_ed_txt:
.pas_form:
	endc

	tst GWVA_WIND_OBJ_TOPABLE_STATE(a0)		; untoppable ?
	bge.s .detoppable

	save.l a0
	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	load.l a0
	tst d7
	bmi.s .the_top_windows_is_not_mine

	lea GWVA_APP_OBJ_MSG_EXT_BUF,a1
	move.w #WM_TOPPED,(a1)+
	move.w global+_AESapid,(a1)+
	move.w #0,(a1)+
	move.w GWVA_WIND_OBJ_GEM_HANDLE(a0),(a1)+
	clr.l (a1)+
	clr.l (a1)+
	save.l a0
	appl_write global+_AESapid,#16,#GWVA_APP_OBJ_MSG_EXT_BUF
	load.l a0

.the_top_windows_is_not_mine:
.detoppable:
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_FULL_ONE_WIND:			; a0=ptr

	ifd MDL_WIND_FORM

	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_window_form
	bra GWVA_WIND_OBJ_PRG_NAMIFY_UNAMIFY_ONE_WIND	; a0=ptr
.pas_window_form:

	endc

	btst #GWVA_WIN_BIT_FULL,GWVA_WIND_OBJ_STATUS+1(a0)
	bne.s .full

	bset #GWVA_WIN_BIT_FULL,GWVA_WIND_OBJ_STATUS+1(a0)	; full

	movem.w GWVA_APP_OBJ_DESKTOP_X,d0-d1	; position du bureau
	movem.w GWVA_WIND_OBJ_EXTERNAL_MAX_W(a0),d2-d3

	bra.s .end

.full:	bclr #GWVA_WIN_BIT_FULL,GWVA_WIND_OBJ_STATUS+1(a0)		; position pr‚c‚dente

	save.l a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_PREVXYWH
	load.l a0

	movem.w int_out+2,d0-d3			; x,y,w,h
	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)	; namified ?
	beq.s .pas_namifiee2

	add.w GWVA_WIND_OBJ_INTERNAL_H(a0),d3
	add GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d3
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d3

.pas_namifiee2:

.end:	bsr GWVA_WIND_OBJ_PRG_CALC_SIZE_WIND
	bsr GWVA_WIND_OBJ_PRG_CALC_SLIDES_SIZE
.fermee:	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_SIZE_ONE_WIND:			; a0=ptr
GWVA_WIND_OBJ_PRG_MOVE_ONE_WIND:			; a0=ptr

	bclr #GWVA_WIN_BIT_FULL,GWVA_WIND_OBJ_STATUS+1(a0)		; la fenˆtre n'est plus en full

	movem.w GWVA_APP_OBJ_MSG_BUF+4*2,d0-d3	; x,y,w,h

	cmp.w GWVA_WIND_OBJ_EXTERNAL_MAX_W(a0),d2
	ble.s .pas_trop_large
	move GWVA_WIND_OBJ_EXTERNAL_MAX_W(a0),d2
.pas_trop_large:
	cmp.w GWVA_WIND_OBJ_EXTERNAL_MAX_H(a0),d3
	ble.s .pas_trop_haut
	move GWVA_WIND_OBJ_EXTERNAL_MAX_H(a0),d3
.pas_trop_haut:

	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)	; namified ?
	beq.s .pas_namifiee
	move.w GWVA_WIND_OBJ_EXTERNAL_H(a0),d3		; pour qu'il calcule la taille interne normalement
.pas_namifiee:

	bsr GWVA_WIND_OBJ_PRG_CALC_SIZE_WIND
	bsr GWVA_WIND_OBJ_PRG_CALC_SLIDES_SIZE
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_CREATE_ONE_WIND:			; a0=ptr
	save.l a0
	move.w #WM_GWVA_NEWIND+WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l a0
	tst d7
	bmi.s .user_abord

	save.l a0
	wind_create GWVA_WIND_OBJ_FLAGS(a0),GWVA_WIND_OBJ_EXTERNAL_X(a0),GWVA_WIND_OBJ_EXTERNAL_Y(a0),GWVA_WIND_OBJ_EXTERNAL_W(a0),GWVA_WIND_OBJ_EXTERNAL_H(a0)
	load.l a0
	move d0,GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi .erreur_wind

	save.l a0
	move.w #WM_GWVA_NEWIND+WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l a0

	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_TITLE
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_INFO

	bsr GWVA_WIND_OBJ_PRG_CALC_SLIDES_SIZE
	; Pour avoir la bonne taille dŠs le d‚part
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_VSLIDE
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_HSLIDE

	clr d7
	rts

.erreur_wind:move #GWVA_ERROR_WIND_GEM_CREATE,d7
	rts
.user_abord:move #GWVA_ERROR_WIND_USER_CANCEL_CREATE,d7
	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_UPDATE_WIND_TITLE:		; a0=ptr
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	bmi.s .not_created

	btst #0,GWVA_WIND_OBJ_FLAGS+1(a0)		; titre/move ?
	beq.s .pas_de_titre
	move.l GWVA_WIND_OBJ_NAME(a0),d0
	beq.s .pas_de_titre
	move.l d0,int_in+4
	save.l a0
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_NAME
	load.l a0
.pas_de_titre:
.not_created:
	rts

GWVA_WIND_OBJ_PRG_UPDATE_WIND_INFO:			; a0=ptr
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	bmi.s .not_created

	btst #4,GWVA_WIND_OBJ_FLAGS+1(a0)		; ligne info ?
	beq.s .pas_d_info
	move.l GWVA_WIND_OBJ_INFO(a0),d0
	beq.s .pas_d_info
	move.l d0,int_in+4
	save.l a0
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_INFO
	load.l a0
.pas_d_info:
.not_created:
	rts

GWVA_WIND_OBJ_PRG_UPDATE_WIND_VSLIDE:		; a0=ptr
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	bmi.s .not_created

	btst #8-8,GWVA_WIND_OBJ_FLAGS(a0)		; slide vertical ?
	beq.s .pas_vslide
	save.l a0
	move.w GWVA_WIND_OBJ_SLIDER_V_POS(a0),int_in+4
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_VSLIDE	; position slide
	move.l (sp),a0
	move.w GWVA_WIND_OBJ_SLIDER_V_SIZE(a0),int_in+4
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_VSLSIZE
	load.l a0
.pas_vslide:
.not_created:
	rts

GWVA_WIND_OBJ_PRG_UPDATE_WIND_HSLIDE:		; a0=ptr
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	bmi.s .not_created

	btst #11-8,GWVA_WIND_OBJ_FLAGS(a0)		; slide horizontal
	beq.s .pas_hslide
	save.l a0
	move.w GWVA_WIND_OBJ_SLIDER_H_POS(a0),int_in+4
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_HSLIDE
	move.l (sp),a0
	move.w GWVA_WIND_OBJ_SLIDER_H_SIZE(a0),int_in+4
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_HSLSIZE
	load.l a0
.pas_hslide:
.not_created:
	rts

		*--------------------------*
GWVA_WIND_OBJ_PRG_CALC_SLIDES_SIZE:
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_HVSLIDE	; ici il faut forcer le r‚affichage
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE	; des slides car la fenˆtre peut avoir

	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_WHSLIDE	; chang‚ de taille
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),GWVA_WTEXT_OBJ_AFF_LIGNE(a1)	; peut ˆtre problŠme
	move.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),GWVA_WTEXT_OBJ_AFF_COLONNE(a1)	; plus tard
.pas_texte:
	endc

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_NAMIFY_UNAMIFY_ONE_WIND:	; a0=ptr Window should have no gadgets elsewhere than its title part
	bclr #GWVA_WIN_BIT_FULL,GWVA_WIND_OBJ_STATUS+1(a0)	; la fenˆtre n'est plus en full

	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)	; namified ?
	beq.s .pas_namifiee

	; on la d‚namifie
	bclr #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)
	save.l a0
	move.l GWVA_WIND_OBJ_EXTERNAL_X(a0),int_in+4
	move.l GWVA_WIND_OBJ_EXTERNAL_W(a0),int_in+8
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_CURRXYWH

	ifd MDL_WIND_BITMAP

	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi .the_top_windows_is_not_mine	

	move.l (sp),a0
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE
.the_top_windows_is_not_mine:
	endc

	load.l a0
	rts

.pas_namifiee:

	; on la namifie illico
	bset #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)

	bclr #GWVA_WIN_BIT_CURS,GWVA_WIND_OBJ_STATUS+1(a0)

	; int -> externe
	save.l a0
	move.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d0
	sub GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d0
	sub GWVA_WIND_OBJ_MENU_HEIGHT(a0),d0

	wind_calc #0,GWVA_WIND_OBJ_FLAGS(a0),GWVA_WIND_OBJ_INTERNAL_X(a0),d0,GWVA_WIND_OBJ_INTERNAL_W(a0),#0
	move.l (sp),a0
	move.l int_out+2,int_in+4
	move.l int_out+6,int_in+8
	wind_set GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_CURRXYWH

	ifd MDL_WIND_BITMAP

	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi .the_top_windows_is_not_mine2

	move.l (sp),a0
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE
.the_top_windows_is_not_mine2:
	endc

	load.l a0
	rts

****************************************************************************
GWVA_APP_OBJ_CREATE_WINDOW:			; a0=ptr strucutre

	tst GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bge.s .already_exist

	tst GWVA_WIND_OBJ_TYPE(a0)
	ble.s .bad_structure
	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bgt.s .bad_structure

	ifd MDL_WIND_BITMAP
	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap
	move.w (GWVA_WBITM_OBJ_NBR_BITPLANES,[GWVA_WIND_OBJ_SPEC_PTR,a0]),d0
	cmp.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d0
	bne.s .pas_le_meme_nb_coul
.pas_bitmap:
	endc

	ifnd MDL_WIND_CUSTOM
	cmp.w #GWVA_WIND_TYPE_CUSTOM,GWVA_WIND_OBJ_TYPE(a0)
	beq.s .include_non_fait
	endc
	ifnd MDL_WIND_TEXT
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	beq.s .include_non_fait
	endc
	ifnd MDL_WIND_FORM
	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	beq.s .include_non_fait
	btst #8-8,GWVA_WIND_OBJ_STATE(a0)
	bne.s .include_non_fait
	endc
	ifnd MDL_WIND_BITMAP
	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	beq.s .include_non_fait
	endc

	lea GWVA_APP_OBJ_WIND_LIST,a1		; pas d‚j… d‚finie ?
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.scan:	cmp.l (a1),a0
	beq.s .already_exist
	lea 4(a1),a1
	dbf d0,.scan

	lea GWVA_APP_OBJ_WIND_LIST,a1
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.scan2:	tst.l (a1)
	beq.s .found_place
	lea 4(a1),a1
	dbf d0,.scan2
	move #GWVA_ERROR_WIND_VA_BUFF_FULL,d7	; plus de place
	rts
.already_exist:
	move #GWVA_ERROR_WIND_ALREADY_CREATED,d7	; handle<>-1 ou existe d‚j…
	rts
.bad_structure
	move #GWVA_ERROR_WIND_BAD_STRUCTURE,d7	; mauvais type
	rts
.pas_le_meme_nb_coul:
	move #GWVA_ERROR_WIND_BAD_COLOR_NBR,d7	; mauvais type
	rts
.include_non_fait:
	move #GWVA_ERROR_WIND_BAD_INC_DEF,d7	; pas l'include correspondant
	rts

.found_place:
		*--------------------------*
	; on ne stocke pas a0 dans (a1) tout de suite

	; tous les state bits … 0
	and.b #%00000000,GWVA_WIND_OBJ_STATUS+1(a0)

	clr GWVA_WIND_OBJ_MENU_HEIGHT(a0)

	clr GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0)
	btst #GWVA_WIN_BIT_ATOOLBAR,GWVA_WIND_OBJ_PROPERTIES+1(a0)
	beq.s .no_toolbar1

	move.l GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR(a0),a1
	bsr .calc_sculpt_for_form
	move GWVA_WFORM_OBJ_H_SCULPT(a1),GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0)

	; Initialise la largeur de l'obj #0 de la toolbar … la largeur interne maximale de la fenˆtre
	move.l GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR(a0),a1
	move.w GWVA_APP_OBJ_DESKTOP_W,([GWVA_WFORM_OBJ_FORM_PTR,a1],ob_width)

.no_toolbar1:
		*--------------------------*
	; inits des valeurs W,H de d‚part et max si texte pour normaliser
	; premier x,y dans bureau ? add x_desk,y_desk if = 0

	movem.w GWVA_APP_OBJ_DESKTOP_X,d0-d3
	add.w d0,d2
	add.w d1,d3

	move GWVA_WIND_OBJ_FIRST_X(a0),d4
	bmi.s .centre_x
	cmp.w d0,d4
	blt.s .out_letf
	cmp.w d2,d4
	bge.s .out_right
	move.w d4,GWVA_WIND_OBJ_EXTERNAL_X(a0)
	bra.s .centre_x
.out_letf:
.out_right:	move d0,GWVA_WIND_OBJ_EXTERNAL_X(a0)

.centre_x:	move GWVA_WIND_OBJ_FIRST_Y(a0),d4
	cmp.w d1,d4
	blt.s .out_top
	cmp.w d3,d4
	bge.s .out_bottom
	move d4,GWVA_WIND_OBJ_EXTERNAL_Y(a0)
	bra.s .centre_y
.out_top:
.out_bottom:move d1,GWVA_WIND_OBJ_EXTERNAL_Y(a0)
.centre_y:

		*--------------------------*
	ifd MDL_WIND_FORM

	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)	; pas cette init pour moi
	beq .wind_form

	endc

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	save.l a0-a1
	vst_height GWVA_WTEXT_OBJ_FNT_SIZE(a1)	; pour r‚cup‚rer le tableau en sortie
	load.l a0-a1
	move.w ptsout+1*2,GWVA_WTEXT_OBJ_FNT_SIZE(a1)
	move.w ptsout+2*2,GWVA_WTEXT_OBJ_CELL_WIDTH(a1)
	move.w ptsout+3*2,GWVA_WTEXT_OBJ_CELL_HEIGHT(a1)

	movem.w GWVA_WTEXT_OBJ_NB_COLONNES(a1),d0-d1
	mulu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	mulu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	movem.w d0-d1,GWVA_WIND_OBJ_INTERNAL_MAX_W(a0)
	movem.w GWVA_WIND_OBJ_FIRST_W(a0),d0-d1
	mulu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	mulu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	movem.w d0-d1,GWVA_WIND_OBJ_INTERNAL_W(a0)
.pas_texte:
	endc

	; on v‚rifie la taille interne max donn‚e par le user
	; i.e. internal_max w,h
	; ext -> int du bureau
	save.l a0
	wind_calc #1,GWVA_WIND_OBJ_FLAGS(a0),GWVA_APP_OBJ_DESKTOP_X,GWVA_APP_OBJ_DESKTOP_Y,GWVA_APP_OBJ_DESKTOP_W,GWVA_APP_OBJ_DESKTOP_H
	load.l a0

	move int_out+6,d0	; w

	ifd MDL_WIND_TEXT
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte2

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d0
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0	; nombre entier de caracs
	mulu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
.pas_texte2:	
	endc

	move int_out+8,d1	; h

	sub GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d1
	sub GWVA_WIND_OBJ_MENU_HEIGHT(a0),d1

	ifd MDL_WIND_TEXT
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte3

	ext.l d1
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	mulu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
.pas_texte3:
	endc

	ifd MDL_WIND_CUSTOM
	cmp.w #GWVA_WIND_TYPE_CUSTOM,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_custom

	move.l GWVA_WIND_OBJ_FIRST_W(a0),GWVA_WIND_OBJ_INTERNAL_W(a0)
.pas_custom:
	endc

	ifd MDL_WIND_BITMAP
	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap2

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l GWVA_WBITM_OBJ_IMG_WIDTH(a1),GWVA_WIND_OBJ_INTERNAL_MAX_W(a0)
	move.l GWVA_WIND_OBJ_FIRST_W(a0),GWVA_WIND_OBJ_INTERNAL_W(a0)
	clr.l GWVA_WBITM_OBJ_AFF_DX(a1)
.pas_bitmap2:
	endc

	cmp.w GWVA_WIND_OBJ_INTERNAL_MAX_W(a0),d0
	bge.s .width_regular
	move.w d0,GWVA_WIND_OBJ_INTERNAL_MAX_W(a0)
.width_regular:
	cmp.w GWVA_WIND_OBJ_INTERNAL_MAX_H(a0),d1
	bge.s .height_regular
	move.w d1,GWVA_WIND_OBJ_INTERNAL_MAX_H(a0)
.height_regular:

	; on calcule la taille maxi
	; i.e. external max w,h
	save.l a0
	; int -> ext
	wind_calc #0,GWVA_WIND_OBJ_FLAGS(a0),#0,#0,GWVA_WIND_OBJ_INTERNAL_MAX_W(a0),GWVA_WIND_OBJ_INTERNAL_MAX_H(a0)
	load.l a0

	move.l int_out+6,GWVA_WIND_OBJ_EXTERNAL_MAX_W(a0)

	move GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d0
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d0
	add d0,GWVA_WIND_OBJ_EXTERNAL_MAX_H(a0)

	; on v‚rifie la taille d'ouverture interne donn‚e par le user
	; i.e internal first w,h
	move.w GWVA_WIND_OBJ_INTERNAL_MAX_W(a0),d0
	cmp.w GWVA_WIND_OBJ_INTERNAL_W(a0),d0
	bge.s .width_regular2
	move d0,GWVA_WIND_OBJ_INTERNAL_W(a0)
.width_regular2:
	move.w GWVA_WIND_OBJ_INTERNAL_MAX_H(a0),d0
	cmp.w GWVA_WIND_OBJ_INTERNAL_H(a0),d0
	bge.s .height_regular2
	move d0,GWVA_WIND_OBJ_INTERNAL_H(a0)
.height_regular2:

	; on calcule la taille externe d'ouverture pour sauter dans rout
	; int -> ext
	save.l a0
	wind_calc #0,GWVA_WIND_OBJ_FLAGS(a0),#0,#0,GWVA_WIND_OBJ_INTERNAL_W(a0),GWVA_WIND_OBJ_INTERNAL_H(a0)
	load.l a0

	movem.w GWVA_WIND_OBJ_EXTERNAL_X(a0),d0-d1
	movem.w int_out+6,d2-d3

	add GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d3
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d3

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	beq.s .additional_inits_wind_text

	endc

	bra .init_pour_tous
		*--------------------------*
	ifd MDL_WIND_TEXT

.additional_inits_wind_text:
	save.w d0-d3

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move.w GWVA_WTEXT_OBJ_NB_COLONNES(a1),d0
	mulu GWVA_WTEXT_OBJ_NB_LIGNES(a1),d0
	addq.l #1,d0			; +0 … la fin

	clr.l GWVA_WTEXT_OBJ_CUR_BUF_COL(a1)	; colonne 0, ligne 0 en ‚criture
	clr.l GWVA_WTEXT_OBJ_CUR_AFF_COL(a1)	; colonne 0, ligne 0 en affichage
	clr.l GWVA_WTEXT_OBJ_BUF_COLONNE(a1)	; colonne 0, ligne 0 en ‚criture
	clr.l GWVA_WTEXT_OBJ_AFF_COLONNE(a1)	; colonne 0, ligne 0 en affichage

	save.l d0/a0-a1
	MXALLOC #RAM_TT_ST,d0
	load.l d1/a0-a1
	tst.l d0
	ble.s .err_mem

	move.l d0,GWVA_WTEXT_OBJ_MALOC(a1)

	move.l d0,a2	; met des espaces dans le buffer
.putspaces:	move.b #' ',(a2)+
	subq.l #1,d1
	bne.s .putspaces

	move.l d0,a2
	clr.b (a2)		; buffer vide

	load.w d0-d3
	bra .init_pour_tous	

.err_mem:	load.w d0-d3
	move #GWVA_ERROR_MALLOC,d7
	rts

	endc
		*--------------------------*
	ifd MDL_WIND_FORM

.wind_form:	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	save.l a0-a1
	move GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	lea GWVA_WFORM_OBJ_FORM_PTR(a1),a0
	bsr RETURN_TREE_OBJ_PTR
	load.l a0-a1

	move.w GWVA_WFORM_OBJ_FOCUSED_TXT(a1),d1
	beq.s .no_editable_txt
	save.l a0-a1
	move GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a0
	bsr GWVA_COUNT_BYTES_0
	load.l a0-a1
	move d0,GWVA_WFORM_OBJ_CURSOR_POS(a1)
.no_editable_txt:

	bsr .calc_sculpt_for_form
	move.l GWVA_WFORM_OBJ_W_SCULPT(a1),GWVA_WIND_OBJ_INTERNAL_MAX_W(a0)

	save.l a0-a1
	; int->externe
	wind_calc #0,GWVA_WIND_OBJ_FLAGS(a0),#0,#0,GWVA_WIND_OBJ_INTERNAL_MAX_W(a0),GWVA_WIND_OBJ_INTERNAL_MAX_H(a0)
	load.l a0-a1

	; taille max w,h externe
	move.l int_out+6,GWVA_WIND_OBJ_EXTERNAL_MAX_W(a0)

	move GWVA_WIND_OBJ_TOOLBAR_HEIGHT(a0),d0
	add GWVA_WIND_OBJ_MENU_HEIGHT(a0),d0
	add d0,GWVA_WIND_OBJ_EXTERNAL_MAX_H(a0)

	movem.w GWVA_WIND_OBJ_EXTERNAL_X(a0),d0-d1
	movem.w GWVA_WIND_OBJ_EXTERNAL_MAX_W(a0),d2-d3

	bra.s .init_pour_tous

	endc
		*--------------------------*
.init_pour_tous:		; d0-d3 x,y,w,h externe de cr‚ation
	tst GWVA_WIND_OBJ_FIRST_X(a0)
	bge.s .pas_centre_x
	move GWVA_APP_OBJ_DESKTOP_W,d4
	sub.w d2,d4
	bge.s .inf_larg_ecran
	move GWVA_APP_OBJ_DESKTOP_X,d0
	bra.s .pas_centre_x
.inf_larg_ecran:
	lsr #1,d4
	move d4,d0
	add GWVA_APP_OBJ_DESKTOP_X,d0
.pas_centre_x:
	tst GWVA_WIND_OBJ_FIRST_Y(a0)
	bge.s .pas_centre_y
	move GWVA_APP_OBJ_DESKTOP_H,d4
	sub.w d3,d4
	bge.s .inf_haut_ecran
	move GWVA_APP_OBJ_DESKTOP_Y,d1
	bra.s .pas_centre_y
.inf_haut_ecran:
	lsr #1,d4
	move d4,d1
	add GWVA_APP_OBJ_DESKTOP_Y,d1
.pas_centre_y:

	bsr GWVA_WIND_OBJ_PRG_CALC_SIZE_WIND

	bsr GWVA_WIND_OBJ_PRG_CREATE_ONE_WIND

	tst d7
	bmi.s .erreur_creation

	lea GWVA_APP_OBJ_WIND_LIST,a1
	move.w #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
.scan3:	tst.l (a1)
	beq.s .found_place2
	lea 4(a1),a1
	dbf d0,.scan3
	illegal
.found_place2:
	move.l a0,(a1)

	clr d7
	rts

.erreur_creation:
	save.w d7
	bsr GWVA_WIND_OBJ_PRG_UNALLOCATE_MEMORY
	load.w d7
	rts
			*-----------*
.calc_sculpt_for_form:
	save.l a0-a1
	move GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	lea GWVA_WFORM_OBJ_FORM_PTR(a1),a0
	bsr RETURN_TREE_OBJ_PTR
	move.l (a0),a2
	load.l a0-a1
	move.l ob_width(a2),GWVA_WFORM_OBJ_W_SCULPT(a1)
	save.l a0-a1
	move GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	bsr RETURN_FORM_OBJ_SCULPTURE
	load.l a0-a1
	move d0,GWVA_WFORM_OBJ_L_SCULPT(a1)
	move d1,GWVA_WFORM_OBJ_T_SCULPT(a1)
	move d2,GWVA_WFORM_OBJ_R_SCULPT(a1)
	move d3,GWVA_WFORM_OBJ_B_SCULPT(a1)
	movem.w GWVA_WFORM_OBJ_L_SCULPT(a1),d0-d3
	add d0,d2
	add.w d2,GWVA_WFORM_OBJ_W_SCULPT(a1)
	add d1,d3
	add.w d3,GWVA_WFORM_OBJ_H_SCULPT(a1)
	rts

****************************************************************************
* NE PAS UTILISER DEUX FOIS LE MEME OBJET POUR DEUX FENETRES DIFFERENTES.
* SINON PROBLEMES DE REDRAW AU MAUVAIS ENDROIT

GWVA_WIND_OBJ_PRG_WM_REDRAW:
	btst #GWVA_WIN_BIT_OPEN,GWVA_WIND_OBJ_STATUS+1(a0)	; fenˆtre ouverte ?
	beq .no_redraw_window

	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)	; namified ?
	bne .no_redraw_cause_namified

	; par d‚faut on r‚affiche tout
	move.w #0,GWVA_WIND_OBJ_FORM_NUM_OBJ_REDRAW
	move.w #7,GWVA_WIND_OBJ_FORM_DEPTH_OBJ_REDRAW
	move.w #-1,GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW	; all

	tst GWVA_APP_OBJ_MSG_BUF+2*2	; message ‚tendu ? (+ de 16 octets)
	beq.s .redraw_all

	move.w GWVA_APP_OBJ_MSG_EXT_BUF,GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW
	move.w GWVA_APP_OBJ_MSG_EXT_BUF+2,GWVA_WIND_OBJ_FORM_NUM_OBJ_REDRAW
	move.w GWVA_APP_OBJ_MSG_EXT_BUF+4,GWVA_WIND_OBJ_FORM_DEPTH_OBJ_REDRAW
.redraw_all:

	bsr GWVA_WIND_OBJ_PRG_UPDATE_TOOLB_AND_FORM_POS

	ifd MDL_WIND_TEXT		; AFFICHAGE TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_text1

	save.l a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	vst_height GWVA_WTEXT_OBJ_FNT_SIZE(a1)
	vst_alignment #0,#5		; aligne en haut … gauche
	load.l a0
.pas_text1:
	endc

	save.l a0
	wind_update #BEG_UPDATE
	load.l a0

	movem.w GWVA_APP_OBJ_MSG_BUF+4*2,d0-d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_BOX
	save.l a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_FIRSTXYWH
	load.l a0

.draw_all_rectangles:
	tst.l int_out+6		; largeur & hauteur nulle ?
	beq .no_more_rectangle

	movem.w int_out+2,d0-d3

; ---------- AFFICHAGE TOOLBAR ----------

	btst #GWVA_WIN_BIT_ATOOLBAR,GWVA_WIND_OBJ_PROPERTIES+1(a0)	; toolbar ?
	beq .no_toolbar

	lea GWVA_WIND_OBJ_REDRAW_BOX,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC
	tst d7
	bmi .pas_intersection		; pas d'intersection

	lea GWVA_APP_OBJ_DESKTOP_X,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC	; avec le bureau
	tst d7
	bmi .pas_intersection		; pas d'intersection

	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_CLIP	; x,y,w,h

	; redraw de la toolbar
	save.l a0
	v_hide_c
	movem.l (sp),a0
	tst GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW
	bmi.s .all
	cmp #1,GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW
	bne .pas_de_toolbar
	objc_draw <(GWVA_WFORM_OBJ_FORM_PTR,[GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR,a0])>,
&	GWVA_WIND_OBJ_FORM_NUM_OBJ_REDRAW,GWVA_WIND_OBJ_FORM_DEPTH_OBJ_REDRAW,GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6
	bra.s .done
.all:	objc_draw <(GWVA_WFORM_OBJ_FORM_PTR,[GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR,a0])>,
&	#0,#7,GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6
.done:
.pas_de_toolbar:
	v_show_c #1
	load.l a0
	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	; fin redraw toolbar
.no_toolbar:

	cmp #1,GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW
	beq .redraw_only_toolbar

	cmp.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1
	bge.s .not_in_toolbar
	move d1,d4
	sub GWVA_WIND_OBJ_INTERNAL_Y(a0),d4
	add d4,d3				; raccourci
	move GWVA_WIND_OBJ_INTERNAL_Y(a0),d1	; descend
.not_in_toolbar:

	lea GWVA_WIND_OBJ_REDRAW_BOX,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC
	tst d7
	bmi .pas_intersection		; pas d'intersection

	lea GWVA_APP_OBJ_DESKTOP_X,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC	; avec le bureau
	tst d7
	bmi .pas_intersection		; pas d'intersection

; ---------- AFFICHAGE TEXT ----------

	ifd MDL_WIND_TEXT		; AFFICHAGE TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_text2

	save.l a0

	add.w d0,d2
	subq #1,d2
	add.w d1,d3
	subq #1,d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_CLIP
	vs_clip #1,d0,d1,d2,d3		; clip on : x1,y1 -> x2,y2

	; aucun int‚ret de mettre une user routine WM_BEFORE ici
	; car de toute fa‡on on fait un rectangle blanc

	v_hide_c
	vswr_mode #MD_REPLACE
	vsf_color #0		; blanc
	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	v_bar d0,d1,d2,d3
	v_show_c #1
	load.l a0

	lea GWVA_WIND_OBJ_REDRAW_CLIP,a6
	bsr GWVA_WTEXT_OBJ_PRG_CALC_PARAM_TEXT
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d6

	cmp.w d6,d2
	bgt.s .pas_reaffich

	save.l d0-d6/a0
	v_hide_c
	load.l d0-d6/a0

	bsr GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW

	save.l a0
	v_show_c #1
	load.l a0

.pas_reaffich:
	save.l a0
	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	vs_clip #0,d0,d1,d2,d3
	load.l a0

.pas_text2:
	endc

; ---------- AFFICHAGE FORM ----------

	ifd MDL_WIND_FORM

	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_form2

	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_CLIP	; x,y,w,h

	save.l a0
	v_hide_c
	move.l (sp),a0

	tst.w GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW
	bge.s .not_all

	clr.w d0
	move.w #7,d1
	bsr .usr_bef_redraw_usr_aft
	bra .suite

.not_all:	lea GWVA_APP_OBJ_MSG_EXT_BUF+2,a2
.boucle_parse_all:
	cmp.w #-1,(a2)
	beq .fin_boucle
	save.l a0/a2
	movem.w (a2),d0/d1
	bsr .usr_bef_redraw_usr_aft
	load.l a0/a2
	lea 2*2(a2),a2
	bra.s .boucle_parse_all

.usr_bef_redraw_usr_aft:
	save.l a0

	; user routine
	save.w d0/d1

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	save.l d0/a0/a1
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),d0
	load.l d0/a0/a1
	tst.w d0
	bne.s .pas_objet_pere1		; On doit prendre en compte les sculptures de l'objet
	movem.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0-d3
	bra.s .com_form1
.pas_objet_pere1:
	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a2
	mulu #L_OBJECT,d0
	add.l d0,a2
	movem.w int_out+1*2,d0-d1
	movem.w ob_width(a2),d2-d3
.com_form1:
	lea GWVA_WIND_OBJ_REDRAW_CLIP,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC
	tst d7
	beq.s .inter	; pas d'intersection
	load.w d0/d1
	bra .pas_inter
.inter:
	add.w d0,d2
	add.w d1,d3
	sub.w #1,d2
	sub.w #1,d3
	save.l d0-d3/a0
	vs_clip #1,d0,d1,d2,d3
	load.l d0-d3/a0
	move #WM_BEFORE+WM_REDRAW,d4
	bsr GWVA_JUMP_TO_USER_REDRAW_ROUTINE

	save.w d7
	vs_clip #0,d0,d1,d2,d3
	load.w d7

	load.w d0/d1

	tst d7
	bmi .no_redraw

	move.l (sp),a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	save.w d0
	objc_draw GWVA_WFORM_OBJ_FORM_PTR(a1),d0,d1,GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6
	load.w d0

	move.l (sp),a0
.no_redraw:
	; user routine

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	save.l d0/a0/a1
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),d0
	load.l d0/a0/a1
	tst.w d0
	bne.s .pas_objet_pere2		; On doit prendre en compte les sculptures de l'objet
	movem.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0-d3
	bra.s .com_form2
.pas_objet_pere2:
	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a2
	mulu #L_OBJECT,d0
	add.l d0,a2
	movem.w int_out+1*2,d0-d1
	movem.w ob_width(a2),d2-d3
.com_form2:
	lea GWVA_WIND_OBJ_REDRAW_CLIP,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC
	tst d7
	bmi .pas_inter	; pas d'intersection

	add.w d0,d2
	add.w d1,d3
	sub.w #1,d2
	sub.w #1,d3
	save.l d0-d3/a0
	vs_clip #1,d0,d1,d2,d3
	load.l d0-d3/a0
	move #WM_AFTER+WM_REDRAW,d4
	bsr GWVA_JUMP_TO_USER_REDRAW_ROUTINE
.pas_inter:
	load.l a0
	rts

.fin_boucle:
.suite:
	v_show_c #1
	load.l a0

.pas_form2:
	endc

; ---------- AFFICHAGE CUSTOM ----------

	ifd MDL_WIND_CUSTOM

	cmp.w #GWVA_WIND_TYPE_CUSTOM,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_custom1

	save.l a0
	add.w d0,d2
	subq #1,d2
	add.w d1,d3
	subq #1,d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_CLIP	; x1,y1,x2,y2
	vs_clip #1,GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6
	v_hide_c

	move.l (sp),a0

	; user routine

	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	move #WM_BEFORE+WM_REDRAW,d4		; dŠs fois que
	bsr GWVA_JUMP_TO_USER_REDRAW_ROUTINE

	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	move #WM_AFTER+WM_REDRAW,d4		; ...
	bsr GWVA_JUMP_TO_USER_REDRAW_ROUTINE

	v_show_c #1
	vs_clip #0,GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6

	load.l a0
.pas_custom1:

	endc

; ---------- AFFICHAGE BITMAP ----------

	ifd MDL_WIND_BITMAP		; AFFICHAGE BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_bitmap

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d4
	cmp.w GWVA_WBITM_OBJ_NBR_BITPLANES(a1),d4
	bne .pas_le_meme_nb_plan

	save.l a0

	add.w d0,d2
	add.w d1,d3
	subq #1,d2
	subq #1,d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_CLIP	; x1,y1,x2,y2
	vs_clip #1,GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6
	v_hide_c

	move.l (sp),a0

	; user routine

	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	move #WM_BEFORE+WM_REDRAW,d4
	bsr GWVA_JUMP_TO_USER_REDRAW_ROUTINE
	tst d7
	bmi .zap_redraw

	move.l (sp),a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	lea GWVA_APP_MFDB_SRC,a2
	move.l GWVA_WBITM_OBJ_DATA_PTR(a1),(a2)+	; pointeur image
	move.l GWVA_WBITM_OBJ_IMG_WIDTH(a1),(a2)+	; largeur image pixel

	move.w GWVA_WBITM_OBJ_IMG_WIDTH(a1),d5
	add.w #15,d5
	ext.l d5
	divu #16,d5
	move.w d5,(a2)+			; largeur image en mots

	move.w #0,(a2)+			; device dependent

	move.w GWVA_WBITM_OBJ_NBR_BITPLANES(a1),(a2)+
	clr.w (a2)+				; reserv‚s
	clr.w (a2)+
	clr.w (a2)+

	clr.l GWVA_APP_MFDB_DEST

	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	sub.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0
	sub.w GWVA_WIND_OBJ_INTERNAL_X(a0),d2
	sub.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1
	sub.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d3
	add.w GWVA_WBITM_OBJ_AFF_DX(a1),d0
	add.w GWVA_WBITM_OBJ_AFF_DX(a1),d2
	add.w GWVA_WBITM_OBJ_AFF_DY(a1),d1
	add.w GWVA_WBITM_OBJ_AFF_DY(a1),d3
	movem.w d0-d3,ptsin

	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	movem.w d0-d3,ptsin+8

	vro_cpyfm #3,#GWVA_APP_MFDB_SRC,#GWVA_APP_MFDB_DEST	; REPLACE mode
	
.zap_redraw:
	move.l (sp),a0

	; user routine
	movem.w GWVA_WIND_OBJ_REDRAW_CLIP,d0-d3
	move #WM_AFTER+WM_REDRAW,d4
	bsr GWVA_JUMP_TO_USER_REDRAW_ROUTINE

	v_show_c #1
	vs_clip #0,#0,#0,#0,#0

	load.l a0

.pas_le_meme_nb_plan:
.pas_bitmap:
	endc


.redraw_only_toolbar:
.pas_intersection
	save.l a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_NEXTXYWH
	load.l a0
	bra .draw_all_rectangles

.no_more_rectangle:

	ifd MDL_WIND_FORM		; END REDRAW FORM

	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_form3

	save.l a0
	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	load.l a0
	cmp.w GWVA_WIND_OBJ_GEM_HANDLE(a0),d0
	bne .no_top

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	tst GWVA_WFORM_OBJ_FOCUSED_TXT(a1)
	beq .no_ed_txt

	btst #GWVA_WIN_BIT_CURS,GWVA_WIND_OBJ_STATUS+1(a0)
	bne.s .curseur_deja_affiche

	save.l a0-a1
	v_hide_c
	movem.l (sp),a0-a1
	move.w GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	move.w GWVA_WFORM_OBJ_FOCUSED_TXT(a1),d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a2
	movem.l (sp),a0-a1
	add.w GWVA_WFORM_OBJ_CURSOR_POS(a1),a2
	move.b (a2),d0
	clr.b (a2)		; pour forcer le GEM … mettre le curseur autre part qu'en fin de chaine
	save.l d0/a2
	objc_edit GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),#0,GWVA_WFORM_OBJ_CURSOR_POS(a1),#1
	load.l d0/a2
	move.b d0,(a2)
	movem.l (sp),a0-a1
	move.w int_out+2,GWVA_WFORM_OBJ_CURSOR_POS(a1)
	v_show_c #1
	load.l a0-a1

	bset #GWVA_WIN_BIT_CURS,GWVA_WIND_OBJ_STATUS+1(a0)

.curseur_deja_affiche:
.no_ed_txt:
.no_top:
.pas_form3:
	endc

	save.l a0
	wind_update #END_UPDATE
	load.l a0

.no_redraw_cause_namified:
.no_redraw_window:

	rts



		*-----------------------------*
	ifd MDL_WIND_TEXT

GWVA_WTEXT_OBJ_PRG_CALC_PARAM_TEXT:
	movem.w (a6),d0-d1		; x1,y1 clipping

	sub.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0
	sub.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d0
	ext.l d1
	divs GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	divs GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	muls GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	muls GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1	; d0-d1 multiple d'un caractŠre
	add.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0
	add.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1

	movem.w d0-d1,(a6)

	move.w 2(a6),d2			; y1 clipping
	sub.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d2	; position du rectangle de clipping
	ext.l d2 				; dans la fenˆtre
	divs GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d2
	add.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d2	; num de la ligne … afficher

	move.w (a6),d3			; x1 clipping
	sub.w GWVA_WIND_OBJ_INTERNAL_X(a0),d3	; position du rectangle de clipping
	ext.l d3				; dans la fenˆtre
	divs GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d3
	add.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d3	; num de la colone … afficher

	move.w 4(a6),d5
	sub.w (a6),d5
	add.w #1,d5			; dx
	ext.l d5
	divs GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d5
	moveq #1,d6
	swap d5
	tst d5
	bne.s .pas_nul2
	moveq #0,d6
.pas_nul2:	swap d5
	add.w d6,d5			; nb de colonne … afficher

	move.w 6(a6),d4
	sub.w 2(a6),d4
	add.w #1,d4			; dy
	ext.l d4
	divs GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d4
	moveq #1,d6
	swap d4
	tst d4
	bne.s .pas_nul3
	moveq #0,d6
.pas_nul3:	swap d4
	add.w d6,d4			; nb de ligne … afficher
	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW:	Affiche une partie du buffer dans la fenˆtre.
;	Entr‚es:	d0,d1	: (x,y) pour le d‚but du r‚affichage du texte
;		d2,d3	: (l,c) du buffer o— commence le r‚affichage
;		d4,d5	: nbre de (l,c) … afficher
;		d6	: limite texte = cur_buf_lign ou buf_ligne
;		a0	: ptr sur struc. de la fenˆtre
;	Sortie:
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.l GWVA_WTEXT_OBJ_MALOC(a1),a6	; ad du texte
	move d2,d7
	mulu GWVA_WTEXT_OBJ_NB_COLONNES(a1),d7
	add.l d7,a6
	add.w d3,a6			; pointe le d‚but du texte … afficher

	lea GWVA_WTEXT_OBJ_INTERMEDIAIRE,a5
	move.w d5,d7		; nbre de caractŠre … afficher
	subq #1,d7			; sur cette ligne
.rcp:	move.b (a6)+,(a5)+
	tst.b -1(a5)
	beq.s .fin_buffer
	dbf d7,.rcp
	clr.b (a5)+

.fin_buffer
	save.l d0-d6/a0/a1
	save.w d0-d1
	vst_color #1		; noir
	load.w d0-d1
	v_gtext d0,d1,#GWVA_WTEXT_OBJ_INTERMEDIAIRE
	load.l d0-d6/a0/a1

	add.w GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	addq #1,d2
	cmp.w d6,d2
	bgt.s .out			; fin buffer ?
	subq #1,d4			; fin fenˆtre ?
	bne.s GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW
.out:	rts

	endc
		*-----------------------------*
GWVA_WIND_OBJ_PRG_INTERSEC_REC:
	movem.w (a2),d4-d7
	add.w d5,d7		; y2
	add.w d4,d6		; x2
	add.w d1,d3		; y1
	add.w d0,d2		; x1

	cmp.w d7,d3
	ble.s .min1
	move.w d7,d3
.min1:	cmp.w d6,d2
	ble.s .min2
	move.w d6,d2
.min2:
	cmp.w d5,d1
	bge.s .max1
	move.w d5,d1
.max1:	cmp.w d4,d0
	bge.s .max2
	move.w d4,d0
.max2:
	sub.w d1,d3
	sub.w d0,d2

	moveq #GWVA_ERROR_GENERIC,d7

	tst d3
	ble.s .pb
	tst d2
	ble.s .pb
	clr d7
.pb:	rts

****************************************************************************
GWVA_WIND_OBJ_PRG_WM_TOPPED:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_TOP_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_CLOSED:

	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_CLOSE_ONE_WIND
	btst #GWVA_WIN_BIT_AUTODEL-8,GWVA_WIND_OBJ_PROPERTIES(a0)
	beq.s .pas_automatic_delete
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
.pas_automatic_delete:
	load.w d0

.no:	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_FULLED:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_FULL_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_ARROWED:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_texte

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_ARROWED_WINDOW_TEXT
	load.w d0

.pas_fenetre_texte:
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_bitmap

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_ARROWED_WINDOW_BITMAP
	load.w d0

.pas_fenetre_bitmap:
	endc

.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_HSLID:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_texte

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_HSLIDE_WINDOW_TEXT
	load.w d0
.pas_fenetre_texte:
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_bitmap

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_HSLIDE_WINDOW_BITMAP
	load.w d0
.pas_fenetre_bitmap:
	endc

.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_VSLID:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_texte

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_VSLIDE_WINDOW_TEXT
	load.w d0
.pas_fenetre_texte:
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_bitmap

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_VSLIDE_WINDOW_BITMAP
	load.w d0
.pas_fenetre_bitmap:
	endc

.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_SIZED:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_SIZE_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_MOVED:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_MOVE_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_NEWTOP:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_NEWTOP_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_UNTOPPED:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_UNTOP_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_ONTOP:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_ONTOP_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_BOTTOM:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_BOTTOM_ONE_WIND
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_ICONIFY:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_ICONIFY_ONE_WIND
	; exec rout
	; remettre l'ancienne palette si ordre ex‚cut‚ !
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_UNICONIFY:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	bsr GWVA_WIND_OBJ_PRG_UNICONIFY_ONE_WIND
	; exec rout
	; remettre l'ancienne palette si ordre ex‚cut‚ !
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_ALLICONIFY:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	; exec rout
	; remettre l'ancienne palette si ordre ex‚cut‚ !
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_WIND_OBJ_PRG_WM_TOOLBAR:
	save.l d0/a0
	add.w #WM_BEFORE,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE
	load.l d0/a0

	tst d7
	bmi.s .no

	save.w d0
	; exec rout
	load.w d0
.no:
	add.w #WM_AFTER,d0
	bsr GWVA_JUMP_TO_USER_EVENT_ROUTINE

	rts
		*--------------------------*
GWVA_JUMP_TO_USER_EVENT_ROUTINE:		; a0=ptr d0=Nr msg
	lea GWVA_WIND_OBJ_START_EVNT_LIST(a0),a2

.search:	tst.w (a2)
	bmi.s .not_found
	cmp.w (a2),d0
	beq.s .found
	lea 2+4(a2),a2
	bra.s .search

.not_found:	clr d7		; perform action !
	rts

.found:	lea GWVA_APP_OBJ_MSG_BUF,a1	; a1 = ptr msg_buff
	jsr ([a2,2])		; a0 = ptr fenetre

	; renvoie dans d7 s'il faut faire l'action (0=oui,-1=non)
	rts

		*--------------------------*

GWVA_JUMP_TO_USER_REDRAW_ROUTINE:
	clr d7

	lea GWVA_WIND_OBJ_START_EVNT_LIST(a0),a2
.search:	tst.w (a2)
	bmi.s .not_found
	cmp.w (a2),d4
	beq.s .found
	lea 2+4(a2),a2
	bra.s .search

.found:			; zone de clipping x1,y1,x2,y2 dans d0-d3
			; a0 = ptr fenetre
			; a1 = ptr spec fenetre
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	jsr ([a2,2])	; retour d7 important si WM_BEFORE

.not_found:	rts

****************************************************************************

	ifd MDL_WIND_BITMAP

GWVA_WIND_OBJ_PRG_ARROWED_WINDOW_BITMAP:		; d‚placements dans la fen‚tre ligne-colonne/page
	move GWVA_WIND_OBJ_INTERNAL_H(a0),d0
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d1

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move.w GWVA_APP_OBJ_MSG_BUF+4*2,d2	; action ?
	
	cmp.w #WA_UPPAGE,d2
	bne.s .pas_page_h
	sub.w d0,GWVA_WBITM_OBJ_AFF_DY(a1)
.pas_page_h:
	cmp.w #WA_DNPAGE,d2
	bne.s .pas_page_b
	add.w d0,GWVA_WBITM_OBJ_AFF_DY(a1)
.pas_page_b:
	cmp.w #WA_UPLINE,d2
	bne.s .pas_ligne_h
	sub.w #1,GWVA_WBITM_OBJ_AFF_DY(a1)
.pas_ligne_h:
	cmp.w #WA_DNLINE,d2
	bne.s .pas_ligne_b
	add.w #1,GWVA_WBITM_OBJ_AFF_DY(a1)
.pas_ligne_b:
	cmp.w #WA_LFPAGE,d2
	bne.s .pas_page_g
	sub.w d1,GWVA_WBITM_OBJ_AFF_DX(a1)
.pas_page_g:
	cmp.w #WA_RTPAGE,d2
	bne.s .pas_page_d
	add.w d1,GWVA_WBITM_OBJ_AFF_DX(a1)
.pas_page_d:
	cmp.w #WA_LFLINE,d2
	bne.s .pas_col_g
	sub.w #1,GWVA_WBITM_OBJ_AFF_DX(a1)
.pas_col_g:
	cmp.w #WA_RTLINE,d2
	bne.s .pas_col_d
	add.w #1,GWVA_WBITM_OBJ_AFF_DX(a1)
.pas_col_d:

	move GWVA_WBITM_OBJ_IMG_HEIGHT(a1),d2
	sub d0,d2
	cmp.w GWVA_WBITM_OBJ_AFF_DY(a1),d2	; d‚passement de la derniŠre ligne visible
	bge.s .ok2
	move d2,GWVA_WBITM_OBJ_AFF_DY(a1)
.ok2:
	tst GWVA_WBITM_OBJ_AFF_DY(a1)
	bpl.s .ok1
	clr GWVA_WBITM_OBJ_AFF_DY(a1)

.ok1:	move GWVA_WBITM_OBJ_IMG_WIDTH(a1),d2
	sub d1,d2
	cmp.w GWVA_WBITM_OBJ_AFF_DX(a1),d2
	bge.s .ok4
	move d2,GWVA_WBITM_OBJ_AFF_DX(a1)
.ok4:
	tst GWVA_WBITM_OBJ_AFF_DX(a1)
	bpl.s .ok3
	clr GWVA_WBITM_OBJ_AFF_DX(a1)
.ok3:
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE

	move.w #0,d0
	move.w #7,d1
	move.w #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

	rts

GWVA_WIND_OBJ_PRG_HSLIDE_WINDOW_BITMAP:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move GWVA_APP_OBJ_MSG_BUF+4*2,d1		; % du GEM
	move GWVA_WBITM_OBJ_IMG_WIDTH(a1),d2
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d3

	sub d3,d2
	mulu d2,d1
	divu #1000,d1
	move d1,GWVA_WBITM_OBJ_AFF_DX(a1)

	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE

	move.w #0,d0
	move.w #7,d1
	move.w #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	rts

GWVA_WIND_OBJ_PRG_VSLIDE_WINDOW_BITMAP:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move GWVA_APP_OBJ_MSG_BUF+4*2,d1		; % du GEM
	move GWVA_WBITM_OBJ_IMG_HEIGHT(a1),d2	; hauteur buffer
	move GWVA_WIND_OBJ_INTERNAL_H(a0),d3

	sub d3,d2
	mulu d2,d1
	divu #1000,d1
	move d1,GWVA_WBITM_OBJ_AFF_DY(a1)

	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE

	move.w #0,d0
	move.w #7,d1
	move.w #0,d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART

	rts

	endc

		*--------------------------*

	ifd MDL_WIND_TEXT

GWVA_WIND_OBJ_PRG_ARROWED_WINDOW_TEXT:		; d‚placements dans la fen‚tre ligne-colonne/page
	move GWVA_WIND_OBJ_INTERNAL_H(a0),d0
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d1

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
	move.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),GWVA_WTEXT_OBJ_AFF_COLONNE(a1)

	ext.l d0
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d0	; nb lignes … l'‚cran
	ext.l d1
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d1	; nb colonnes … l'‚cran

	move.w GWVA_APP_OBJ_MSG_BUF+4*2,d2	; action ?
	
	cmp.w #WA_UPPAGE,d2
	bne.s .pas_page_h
	sub.w d0,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
.pas_page_h:
	cmp.w #WA_DNPAGE,d2
	bne.s .pas_page_b
	add.w d0,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
.pas_page_b:
	cmp.w #WA_UPLINE,d2
	bne.s .pas_ligne_h
	sub.w #1,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
.pas_ligne_h:
	cmp.w #WA_DNLINE,d2
	bne.s .pas_ligne_b
	add.w #1,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
.pas_ligne_b:
	cmp.w #WA_LFPAGE,d2
	bne.s .pas_page_g
	sub.w d1,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
.pas_page_g:
	cmp.w #WA_RTPAGE,d2
	bne.s .pas_page_d
	add.w d1,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
.pas_page_d:
	cmp.w #WA_LFLINE,d2
	bne.s .pas_col_g
	sub.w #1,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
.pas_col_g:
	cmp.w #WA_RTLINE,d2
	bne.s .pas_col_d
	add.w #1,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
.pas_col_d:

	move GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d2
	add.w #1,d2		; num‚ro de ligne
	sub d0,d2
	cmp.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d2	; d‚passement de la derniŠre ligne visible
	bge.s .ok2
	move d2,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
.ok2:
	tst GWVA_WTEXT_OBJ_AFF_LIGNE(a1)
	bpl.s .ok1
	clr GWVA_WTEXT_OBJ_AFF_LIGNE(a1)

.ok1:	move GWVA_WTEXT_OBJ_NB_COLONNES(a1),d2
	sub d1,d2
	cmp.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d2
	bge.s .ok4
	move d2,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
.ok4:
	tst GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
	bpl.s .ok3
	clr GWVA_WTEXT_OBJ_AFF_COLONNE(a1)
.ok3:
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE2
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE2

	bsr GWVA_WTEXT_OBJ_PRG_SCROLL_WINDOW

	rts

GWVA_WIND_OBJ_PRG_HSLIDE_WINDOW_TEXT:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),GWVA_WTEXT_OBJ_AFF_COLONNE(a1)

	move GWVA_APP_OBJ_MSG_BUF+4*2,d1		; % du GEM
	move GWVA_WTEXT_OBJ_NB_COLONNES(a1),d2		; largeur buffer
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d3

	ext.l d3
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d3		; largeur fenˆtre

	sub d3,d2
	mulu d2,d1
	divu #1000,d1
	move d1,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)

	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE2

	bsr GWVA_WTEXT_OBJ_PRG_SCROLL_WINDOW
	rts

GWVA_WIND_OBJ_PRG_VSLIDE_WINDOW_TEXT:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),GWVA_WTEXT_OBJ_AFF_LIGNE(a1)

	move GWVA_APP_OBJ_MSG_BUF+4*2,d1		; % du GEM
	move GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d2	; hauteur buffer
	addq.w #1,d2
	move GWVA_WIND_OBJ_INTERNAL_H(a0),d3

	ext.l d3
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d3	; hauteur fenˆtre

	sub d3,d2
	mulu d2,d1
	divu #1000,d1
	move d1,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)

	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE2

	bsr GWVA_WTEXT_OBJ_PRG_SCROLL_WINDOW
	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_WRITE_IN_WINDOW: Affiche une chaine de caractŠre dans une fenˆtre.
;	Entr‚es:	a0	: ptr sur la structure de la fenˆtre
;		a1	: ptr sur le texte (termin‚ par 0)
;	Sortie:
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_WRITE_IN_WINDOW:
	bsr.s GWVA_WTEXT_OBJ_PRG_WRITE_IN_BUFFER
	bsr GWVA_WTEXT_OBJ_PRG_WRITE_BUFFER_IN_WINDOW
	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_WRITE_IN_BUFFER: Ecrit une chaine dans le buffer de la fenˆtre.
;	Entr‚es:	a0	: ptr sur la structure de la fenˆtre
;		a1	: ptr sur le texte (termin‚ par 0)
;	Sortie:
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_WRITE_IN_BUFFER:
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_une_fenetre_texte

	tst.w GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi .fenetre_non_initialisee

	move.l a1,a3
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move.w GWVA_WTEXT_OBJ_BUF_COLONNE(a1),d0	; colonne courante
	ext.l d0
	move.w GWVA_WTEXT_OBJ_BUF_LIGNE(a1),d1	; ligne courante
	ext.l d1
	move.l GWVA_WTEXT_OBJ_MALOC(a1),a2	; A2 pointe sur d‚but du buffer

	move GWVA_WTEXT_OBJ_NB_COLONNES(a1),d2	; largeur d'une ligne
	ext.l d2
	move GWVA_WTEXT_OBJ_NB_LIGNES(a1),d3	; hauteur fenˆtre
	ext.l d3

	move d1,d4
	mulu d2,d4
	add.l d0,d4
	lea 0(a2,d4.l),a2		; pointeur courant
	
.next_car:	move.b (a3)+,d4		; MODIF LE 06/06/95 par WAX
	tst.b d4			; lf rempli et retourne au d‚but
	beq.s .its_0		; rc descend d'une ligne et retourne au d‚but
	cmp.b #lf,d4
	beq .its_lf
	cmp.b #rc,d4
	beq .its_rc
	
	move.b d4,(a2)+
	addq.l #1,d0
	cmp.l d0,d2
	bgt.s .no_end_line
.desc1lign:	clr.l d0
	addq.l #1,d1
	cmp.l d1,d3
	bgt.s .no_end_buf
	subq.l #1,d1		; on remet … la derniŠre ligne
	subq.w #1,GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1)	; tout le texte remonte d'une ligne
	subq.w #1,GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1)

; debut du scroll d'une ligne du buffer
	move.l GWVA_WTEXT_OBJ_MALOC(a1),a4
	move d2,d7
	mulu d3,d7
	sub.l d2,d7
	beq.s .one_line
.remonte:	move.b (a4,d2.w),(a4)+
	subq.l #1,d7
	bne.s .remonte
.one_line:
	move d2,d7
	subq #1,d7
.put_spaces:move.b #' ',(a4)+
	dbf d7,.put_spaces
; fin du scroll d'une ligne du buffer

	sub.l d2,a2
.no_end_buf:
.no_end_line:
	bra.s .next_car

.its_0:	move.w d0,GWVA_WTEXT_OBJ_BUF_COLONNE(a1)
	move.w d1,GWVA_WTEXT_OBJ_BUF_LIGNE(a1)
	clr.b (a2)
	rts
.its_lf:	move d2,d7			; attention : le line-feed fait tout !
	sub d0,d7
	subq #1,d7
.cp:	move.b #' ',(a2)+
	dbf d7,.cp
	sub.l d2,a2
	clr.l d0
	bra .next_car

.its_rc:	sub.l d0,a2
	add.l d2,a2

	bra.s .desc1lign

.fenetre_non_initialisee:
.pas_une_fenetre_texte:
	move.w #GWVA_ERROR_GENERIC,d7
	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_WRITE_BUFFER_IN_WINDOW:	Ecrit le buffer dans la fenˆtre
;	Entr‚es:	a0	: ptr sur la structure de la fenˆtre
;	Sortie:
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_WRITE_BUFFER_IN_WINDOW:
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_une_fenetre_texte

	tst.w GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi .fenetre_non_initialisee

	btst #0,GWVA_WIND_OBJ_FLAGS(a0)	; bit 8 des attributs de la fenˆtre
	beq .colle		; slider vertical ? -> on colle auto.
	
	save.l a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_VSLIDE	; pos vslide
	load.l a0
	move.w int_out+2,d0
	save.l d0/a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_VSLSIZE
	load.l d0/a0
	move.w int_out+2,d1
	cmp.w #1000,d0
	beq.s .colle
	cmp.w #1000,d1
	bne.s .pas_colle

.colle:	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_BUF_LIGNE(a1),GWVA_WTEXT_OBJ_AFF_LIGNE(a1)

.pas_colle:
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE2	; il faut bien rectifier la position

	bsr.s GWVA_WTEXT_OBJ_PRG_SCROLL_WINDOW

	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_HVSLIDE
	rts

.fenetre_non_initialisee:
.pas_une_fenetre_texte:
	move.w #GWVA_ERROR_GENERIC,d7
	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_SCROLL_WINDOW:	Scroll le contenu de la fenˆtre.
;	Entr‚es:	a0	: ptr. sur struc. de la fenˆtre
;	Sortie:
;
; routine de scroll
;	Sortie:	d0,d1	: (x,y) pour le d‚but du r‚affichage du texte
;		d2,d3	: (l,c) du buffer o— commence le r‚affichage
;		d4,d5	: nbre de (l,c) … afficher
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_SCROLL_WINDOW:
	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_une_fenetre_texte

	tst.w GWVA_WIND_OBJ_GEM_HANDLE(a0)
	bmi .fenetre_non_initialisee

	btst #1,GWVA_WIND_OBJ_FLAGS+1(a0)	; fenˆtre ouverte ?
	beq .no_scroll_window

	save.l a0
	wind_update #BEG_UPDATE
	vst_alignment #0,#5		; aligne en haut … gauche (texte)
	move.l (sp),a0

	movem.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0-d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_BOX
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_FIRSTXYWH
	load.l a0

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_BUF_LIGNE(a1),d6
	sub.w GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d6	; nouvelles lignes … afficher ?
	move.w d6,GWVA_WIND_OBJ_NEW_TEXT_VAR
	move.w GWVA_WTEXT_OBJ_BUF_COLONNE(a1),d6
	sub.w GWVA_WTEXT_OBJ_CUR_BUF_COL(a1),d6
	move.w d6,GWVA_WIND_OBJ_NEW_TEXT_VAR+2

.scroll_all:
	tst.l int_out+6		; largeur & hauteur nulle ?
	beq .no_more_rectangle1

	movem.w int_out+2,d0-d3

	lea GWVA_WIND_OBJ_REDRAW_BOX,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC	; calcul intersection
	tst d7
	bmi .pas_intersec1		; pas d'intersection

	lea GWVA_APP_OBJ_DESKTOP_X,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC	; avec le bureau
	tst d7
	bmi .pas_intersec1		; pas d'intersection

	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_INTERSEC

	add.w d0,d2
	subq #1,d2
	add.w d1,d3
	subq #1,d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_CLIP
	save.l a0
	vs_clip #1,d0,d1,d2,d3		; clip on : x1,y1 -> x2,y2
	load.l a0

; Scrolling et r‚affichage du texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d6
	sub.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),d6	; d‚placement vertical ?
	beq.s .pas_scroll_vertical

	save.l d6/a0
	v_hide_c
	load.l d6/a0

	bsr GWVA_WTEXT_OBJ_PRG_SCROLL_VERT

	save.l d7/a0
	v_show_c #1
	load.l d7/a0

	tst d7
	bmi.s .pas_scroll_vertical

	lea GWVA_WIND_OBJ_REDRAW_BLANK,a6
	bsr GWVA_WTEXT_OBJ_PRG_CALC_PARAM_TEXT
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d6
	cmp.w d6,d2
	bgt.s .pas_scroll_vertical

	save.l d0-d6/a0
	v_hide_c
	load.l d0-d6/a0
	bsr GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW
	save.l a0
	v_show_c #1
	load.l a0

.pas_scroll_vertical:

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d6
	sub.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),d6	; d‚placement vertical ?
	beq.s .pas_scroll_horizontal

	save.l d6/a0
	v_hide_c
	load.l d6/a0

	bsr GWVA_WTEXT_OBJ_PRG_SCROLL_HORI

	save.l d7/a0
	v_show_c #1
	load.l d7/a0

	tst d7
	bmi.s .pas_scroll_horizontal

	lea GWVA_WIND_OBJ_REDRAW_BLANK,a6
	bsr GWVA_WTEXT_OBJ_PRG_CALC_PARAM_TEXT
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d6

	cmp.w d6,d2
	bgt.s .pas_scroll_horizontal

	save.l d0-d6/a0
	v_hide_c
	load.l d0-d6/a0
	bsr GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW

	save.l a0
	v_show_c #1
	load.l a0

.pas_scroll_horizontal:
	move.w GWVA_WIND_OBJ_NEW_TEXT_VAR,d6
	bne.s .nouvelles_lignes
	move.w GWVA_WIND_OBJ_NEW_TEXT_VAR+2,d6
	beq .pas_nouvelles_lignes
.nouvelles_lignes:

	bsr GWVA_WTEXT_OBJ_PRG_CALC_PARAM_TEXT2
	tst d7
	bmi.s .pas_nouvelles_lignes

	save.l d0-d5/a0
	v_hide_c
	load.l d0-d5/a0

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_BUF_LIGNE(a1),d6
	bsr GWVA_WTEXT_OBJ_PRG_WRITE_TEXT_IN_WINDOW

	save.l a0
	v_show_c #1
	load.l a0

.pas_nouvelles_lignes:
	save.l a0
	vs_clip #0,#0,#0,#0,#0		; vire le clipping
	load.l a0

.pas_intersec1:
	save.l a0
	wind_get GWVA_WIND_OBJ_GEM_HANDLE(a0),#WF_NEXTXYWH	; rectangle suivant
	load.l a0

	bra .scroll_all

.no_more_rectangle1:
	save.l a0
	wind_update #END_UPDATE
	load.l a0

.no_scroll_window:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_BUF_LIGNE(a1),GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1)
	move.w GWVA_WTEXT_OBJ_BUF_COLONNE(a1),GWVA_WTEXT_OBJ_CUR_BUF_COL(a1)

	move.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d0
	cmp.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),d0
	bne.s .yes
	tst GWVA_WIND_OBJ_NEW_TEXT_VAR
	beq.s .no1
.yes:	move.w d0,GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1)
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE
.no1:
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d0
	cmp.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),d0
	beq.s .no2
	move.w d0,GWVA_WTEXT_OBJ_CUR_AFF_COL(a1)
	bsr GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE
.no2:
	clr d7
	rts

.fenetre_non_initialisee:
.pas_une_fenetre_texte:
	move.w #GWVA_ERROR_GENERIC,d7
	rts

	;--------------------------------------

GWVA_WTEXT_OBJ_PRG_CALC_PARAM_TEXT2
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	moveq #0,d0
	sub.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d0
	muls GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	add.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0	; d0 = x1 bloc de text … afficher

	move.w GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d1
	sub.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d1
	muls GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	add.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1	; d1 = y1 bloc de text … afficher

	move.w GWVA_WTEXT_OBJ_NB_COLONNES(a1),d2
	mulu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d2	; d2 = dx bloc de text … afficher

	move.w GWVA_WTEXT_OBJ_BUF_LIGNE(a1),d3
	sub.w GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d3
	add.w #1,d3				; au moins une ligne
	muls GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d3	; d3 = dy bloc de text … afficher

	lea GWVA_WIND_OBJ_REDRAW_INTERSEC,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC	; calcul intersection
	tst d7
	bmi .pas_intersec		; pas d'intersection

	add.w d0,d2
	sub.w #1,d2
	add.w d1,d3
	sub.w #1,d3

	move d0,d6
	move d1,d7

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	sub.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0
	sub.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1
	ext.l d0
	ext.l d1
	divs GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	divs GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1
	muls GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0
	muls GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d1	; d0-d1 multiple d'un caractŠre
	add.w GWVA_WIND_OBJ_INTERNAL_X(a0),d0
	add.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d1

	move.w d2,d5
	move.w d7,d2
	sub.w GWVA_WIND_OBJ_INTERNAL_Y(a0),d2	; position du rectangle de clipping
	ext.l d2 				; dans la fenˆtre
	divs GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d2
	add.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d2	; num de la ligne … afficher

	move.w d3,d4
	move.w d6,d3
	sub.w GWVA_WIND_OBJ_INTERNAL_X(a0),d3	; position du rectangle de clipping
	ext.l d3				; dans la fenˆtre
	divs GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d3
	add.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d3	; num de la colone … afficher

	sub.w d6,d5
	add.w #1,d5			; dx
	ext.l d5
	divs GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d5
	moveq #1,d6
	swap d5
	tst d5
	bne.s .pas_nul
	moveq #0,d6
.pas_nul:	swap d5
	add.w d6,d5			; nb de colonne … afficher

	sub.w d7,d4
	add.w #1,d4			; dy
	ext.l d4
	divs GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d4
	moveq #1,d6
	swap d4
	tst d4
	bne.s .pas_nul1
	moveq #0,d6
.pas_nul1:	swap d4
	add.w d6,d4			; nb de ligne … afficher
	clr d7
.pas_intersec:
	rts

;---------------------------------------------------------------------------

GWVA_WTEXT_OBJ_PRG_SCROLL_VERT:
	move GWVA_WIND_OBJ_REDRAW_CLIP,d0		; d0 = x1 source, destination
	move GWVA_WIND_OBJ_REDRAW_CLIP+4,d2		; d2 = x2 source, destination

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	muls GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d6

	tst d6
	bmi .scroll_bas

	move GWVA_WIND_OBJ_REDRAW_CLIP+2,d1
	add.w d6,d1			; d1 = y1 source

	move GWVA_WIND_OBJ_REDRAW_CLIP+6,d3		; d3 = y2 source
	
	move GWVA_WIND_OBJ_REDRAW_CLIP+2,d4		; d4 = y1 destination
	move.w d3,d5
	sub.w d6,d5			; d5 = y2 destination

	move.w d0,GWVA_WIND_OBJ_REDRAW_BLANK
	move.w d5,GWVA_WIND_OBJ_REDRAW_BLANK+2
	add.w #1,GWVA_WIND_OBJ_REDRAW_BLANK+2
	move.w d2,GWVA_WIND_OBJ_REDRAW_BLANK+4
	move.w d3,GWVA_WIND_OBJ_REDRAW_BLANK+6

.scroll_vert_com:
	cmp.w d1,d3
	ble.s .sup1ecran

	clr.l GWVA_WTEXT_OBJ_DUMMY

	save.l a0
	lea ptsin,a1
	move.w d0,(a1)+
	move.w d1,(a1)+
	move.w d2,(a1)+
	move.w d3,(a1)+
	move.w d0,(a1)+
	move.w d4,(a1)+
	move.w d2,(a1)+
	move.w d5,(a1)+
	vro_cpyfm #3,#GWVA_WTEXT_OBJ_DUMMY,#GWVA_WTEXT_OBJ_DUMMY	; scroll
	load.l a0

.sup1ecran:	movem.w GWVA_WIND_OBJ_REDRAW_BLANK,d0-d3
	sub.w d0,d2
	add.w #1,d2
	sub.w d1,d3
	add.w #1,d3
	lea GWVA_WIND_OBJ_REDRAW_INTERSEC,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC
	tst d7
	bmi.s .no

	add.w d0,d2
	sub.w #1,d2
	add.w d1,d3
	sub.w #1,d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_BLANK

	save.l d0/d1/a0
	save.l d0-d3
	vsf_color #0		; blanc
	vswr_mode #MD_REPLACE		; mode remplacement
	load.l d0-d3
	v_bar d0,d1,d2,d3		; barre blanche
	load.l d0/d1/a0
	clr d7
.no:	rts

.scroll_bas:
	move GWVA_WIND_OBJ_REDRAW_CLIP+2,d1		; d1 = y1 source

	move GWVA_WIND_OBJ_REDRAW_CLIP+6,d3
	add.w d6,d3			; d6<0  d3 = y2 source

	move GWVA_WIND_OBJ_REDRAW_CLIP+2,d4
	sub.w d6,d4			; d4 = y1 destination
	move GWVA_WIND_OBJ_REDRAW_CLIP+6,d5	; d5 = y2 destination

	move.w d4,d7
	sub.w #1,d7			; pour le blank
	movem.w d0/d1/d2/d7,GWVA_WIND_OBJ_REDRAW_BLANK
	bra .scroll_vert_com

	;--------------------------------------

GWVA_WTEXT_OBJ_PRG_SCROLL_HORI:
	move GWVA_WIND_OBJ_REDRAW_CLIP+2,d1		; d1 = y1 source, destination
	move GWVA_WIND_OBJ_REDRAW_CLIP+6,d3		; d3 = y2 source, destination

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	muls GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d6

	tst d6
	bmi .scroll_droite

	move GWVA_WIND_OBJ_REDRAW_CLIP,d0
	add.w d6,d0			; d0 = x1 source

	move GWVA_WIND_OBJ_REDRAW_CLIP+4,d2	; d2 = x2 source

	move GWVA_WIND_OBJ_REDRAW_CLIP,d4	; d4 = x1 destination
	move.w d2,d5
	sub.w d6,d5			; d5 = x2 destination

	move.w d5,GWVA_WIND_OBJ_REDRAW_BLANK
	add.w #1,GWVA_WIND_OBJ_REDRAW_BLANK
	move.w d1,GWVA_WIND_OBJ_REDRAW_BLANK+2
	move.w d2,GWVA_WIND_OBJ_REDRAW_BLANK+4
	move.w d3,GWVA_WIND_OBJ_REDRAW_BLANK+6

.scroll_hori_com:
	cmp.w d0,d2
	ble.s .sup1ecran

	clr.l GWVA_WTEXT_OBJ_DUMMY
	
	save.l a0
	lea ptsin,a1
	move.w d0,(a1)+
	move.w d1,(a1)+
	move.w d2,(a1)+
	move.w d3,(a1)+
	move.w d4,(a1)+
	move.w d1,(a1)+
	move.w d5,(a1)+
	move.w d3,(a1)+
	vro_cpyfm #3,#GWVA_WTEXT_OBJ_DUMMY,#GWVA_WTEXT_OBJ_DUMMY	; scroll
	load.l a0

.sup1ecran:	movem.w GWVA_WIND_OBJ_REDRAW_BLANK,d0-d3
	sub.w d0,d2
	add.w #1,d2
	sub.w d1,d3
	add.w #1,d3
	lea GWVA_WIND_OBJ_REDRAW_INTERSEC,a2
	bsr GWVA_WIND_OBJ_PRG_INTERSEC_REC
	tst d7
	bmi.s .no

	add.w d0,d2
	sub.w #1,d2
	add.w d1,d3
	sub.w #1,d3
	movem.w d0-d3,GWVA_WIND_OBJ_REDRAW_BLANK

	save.l d0/d1/a0
	save.l d0-d3
	vsf_color #0		; blanc
	vswr_mode #MD_REPLACE		; mode remplacement
	load.l d0-d3
	v_bar d0,d1,d2,d3		; barre blanche
	load.l d0/d1/a0
	clr d7
.no:	rts
.scroll_droite:
	move GWVA_WIND_OBJ_REDRAW_CLIP,d0	; d0 = x1 source

	move GWVA_WIND_OBJ_REDRAW_CLIP+4,d2		; d2 = x2 source
	add.w d6,d2			; d6<0

	move GWVA_WIND_OBJ_REDRAW_CLIP,d4
	sub.w d6,d4			; d4 = x1 destination
	move GWVA_WIND_OBJ_REDRAW_CLIP+4,d5		; d5 = x2 destination

	move.w d0,GWVA_WIND_OBJ_REDRAW_BLANK
	move.w d1,GWVA_WIND_OBJ_REDRAW_BLANK+2
	move.w d4,GWVA_WIND_OBJ_REDRAW_BLANK+4
	sub.w #1,GWVA_WIND_OBJ_REDRAW_BLANK+4
	move.w d3,GWVA_WIND_OBJ_REDRAW_BLANK+6

	bra .scroll_hori_com

	endc

*----------------------------------------
; slider vertical
*----------------------------------------

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE:	Calcul la position du curseur ligne d'affichage, ainsi
;		que la position ‚ventuelle d'un slider vertical et l'affiche.
;	Entr‚es:	a0	: ptr sur struc. de la fenˆtre
;	Sortie:	
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE:
	move GWVA_WIND_OBJ_INTERNAL_H(a0),d2	; taille vertical interne de la fenˆtre

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)	; fenˆtre texte ?
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d2
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d2	; nb lignes pouvant ˆtre affich‚es dans la fenˆtre
					; de 1 … n
	move GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d1
	add.w #1,d1
	sub.w d2,d1		; d1 = num‚ro de 1er ligne de la fenˆtre
	move.w d1,d3
	cmp.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),d1	; on rectifie
	ble.s .min
	move.w GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1),d1
.min:	tst d1
	bpl.s .max
	clr d1
.max:	move.w d1,GWVA_WTEXT_OBJ_CUR_AFF_LIGN(a1)

	tst d3
	beq.s .zero

	mulu #1000,d1
	divs d3,d1		; position du slide
	tst d1
	bpl.s .pos
.zero:	clr d1
.pos:	cmp.w #1000,d1
	ble.s .inf
	move.w #1000,d1
.inf:
	move.w d1,GWVA_WIND_OBJ_SLIDER_V_POS(a0)

	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_VSLIDE
.pas_texte:
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
; ST MAG 79
	move GWVA_WBITM_OBJ_IMG_HEIGHT(a1),d1
	sub.w d2,d1		; d1 = htotal-hvue
	move.w d1,d3
	cmp.w GWVA_WBITM_OBJ_AFF_DY(a1),d1
	ble.s .min1
	move.w GWVA_WBITM_OBJ_AFF_DY(a1),d1
.min1:	; d1 = min(1er ligne,htotal-hvue)
	tst d1
	bpl.s .max1
	clr d1
.max1:	move.w d1,GWVA_WBITM_OBJ_AFF_DY(a1)	; d1 = 1er ligne vue

	tst d3
	beq.s .zero1

	mulu #1000,d1
	divs d3,d1		; position du slide
	tst d1
	bpl.s .pos1
.zero1:	clr d1
.pos1:	cmp.w #1000,d1
	ble.s .inf1
	move.w #1000,d1
.inf1:
	move.w d1,GWVA_WIND_OBJ_SLIDER_V_POS(a0)

	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_VSLIDE
.pas_bitmap:
	endc

	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_CALCULATE_HVSLIDE:	Calcul la taille du slider vertical, et l'affiche.
;	Entr‚es:	a0	: ptr. sur struc. de la fenˆtre
;	Sortie:
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_CALCULATE_HVSLIDE:
	move GWVA_WIND_OBJ_INTERNAL_H(a0),d0	; taille vertical interne de la fenˆtre

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d0
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d0	; nb lignes pouvant ˆtre affich‚es dans la fenˆtre
					; de 1 … n
	move GWVA_WTEXT_OBJ_CUR_BUF_LIGN(a1),d1
			; numero de la ligne en court d'‚criture = taille de
			; la page d‚ja ecrite; de 0 … n-1
	add #1,d1		; de 1 … n
	cmp.w d0,d1
	bgt.s .not_full	; tout est afficher dans la fenˆtre ?
	move #1000,d0
	bra.s .wind_pos
.not_full:	mulu #1000,d0	; non -> taille slide =
	divu d1,d0		; (ce que l'on voit) / (taille document) pour 1000
.wind_pos:
	move.w d0,GWVA_WIND_OBJ_SLIDER_V_SIZE(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_VSLIDE
.pas_texte
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move GWVA_WBITM_OBJ_IMG_HEIGHT(a1),d1
	cmp.w d0,d1
	bgt.s .not_full1	; tout est afficher dans la fenˆtre ?
	move #1000,d0
	bra.s .wind_pos1
.not_full1:	mulu #1000,d0	; non -> taille slide =
	divu d1,d0		; (ce que l'on voit) / (taille document) pour 1000
.wind_pos1:
	move.w d0,GWVA_WIND_OBJ_SLIDER_V_SIZE(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_VSLIDE
.pas_bitmap:
	endc

	rts

*----------------------------------------
; Slider horizontal
*----------------------------------------
;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_CALCULATE_WHSLIDE:	Calcul la taille du slider horizontal, et l'affiche.
;	Entr‚es:	a0	: ptr. sur struc. de la fenˆtre
;	Sortie:
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_CALCULATE_WHSLIDE:
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d0

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d0
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d0	; nb colonnes … l'‚cran

	move GWVA_WTEXT_OBJ_NB_COLONNES(a1),d1
	cmp.w d0,d1
	bgt .not_full
	move #1000,d0
	bra.s .wind_pos2
.not_full:	mulu #1000,d0
	divu d1,d0

.wind_pos2:	move.w d0,GWVA_WIND_OBJ_SLIDER_H_SIZE(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_HSLIDE

.pas_texte:
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move GWVA_WBITM_OBJ_IMG_WIDTH(a1),d1
	cmp.w d0,d1
	bgt .not_full1
	move #1000,d0
	bra.s .wind_pos1
.not_full1:	mulu #1000,d0
	divu d1,d0

.wind_pos1:	move.w d0,GWVA_WIND_OBJ_SLIDER_H_SIZE(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_HSLIDE

.pas_bitmap:
	endc

	rts


;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE:	Calcul la position du curseur colonne d'affichage, ainsi
;		que la position ‚ventuelle d'un slider horizontal
;		et l'affiche.
;	Entr‚es:	a0	: ptr sur struc. de la fenˆtre
;	Sortie:	
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE:
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d2

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d2
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d2	; nb colonnes … l'‚cran

	move GWVA_WTEXT_OBJ_NB_COLONNES(a1),d1
	sub.w d2,d1
	move.w d1,d3
	cmp.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),d1
	ble.s .min
	move.w GWVA_WTEXT_OBJ_CUR_AFF_COL(a1),d1
.min:	tst d1
	bpl.s .max
	clr d1
.max:	move.w d1,GWVA_WTEXT_OBJ_CUR_AFF_COL(a1)

	tst d3
	beq.s .zero

	mulu #1000,d1
	divs d3,d1
	tst d1
	bpl.s .pos
.zero:	clr d1
.pos:	cmp.w #1000,d1
	ble.s .inf
	move.w #1000,d1
.inf:

	move.w d1,GWVA_WIND_OBJ_SLIDER_H_POS(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_HSLIDE
.pas_texte:
	endc

	ifd MDL_WIND_BITMAP

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_bitmap

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	move GWVA_WBITM_OBJ_IMG_WIDTH(a1),d1
	sub.w d2,d1
	move.w d1,d3
	cmp.w GWVA_WBITM_OBJ_AFF_DX(a1),d1
	ble.s .min1
	move.w GWVA_WBITM_OBJ_AFF_DX(a1),d1
.min1:	tst d1
	bpl.s .max1
	clr d1
.max1:	move.w d1,GWVA_WBITM_OBJ_AFF_DX(a1)

	tst d3
	beq.s .zero1

	mulu #1000,d1
	divs d3,d1
	tst d1
	bpl.s .pos1
.zero1:	clr d1
.pos1:	cmp.w #1000,d1
	ble.s .inf1
	move.w #1000,d1
.inf1:

	move.w d1,GWVA_WIND_OBJ_SLIDER_H_POS(a0)
	bsr GWVA_WIND_OBJ_PRG_UPDATE_WIND_HSLIDE
.pas_bitmap:
	endc

	rts

;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE2:	Calcul la position du curseur colonne courant d'affichage
;	Entr‚es:	a0	: ptr sur struc. de la fenˆtre
;	Sortie:	
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_CALCULATE_PHSLIDE2:
	move GWVA_WIND_OBJ_INTERNAL_W(a0),d2

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d2
	divu GWVA_WTEXT_OBJ_CELL_WIDTH(a1),d2	; nb colonnes … l'‚cran

	move GWVA_WTEXT_OBJ_NB_COLONNES(a1),d1
	sub.w d2,d1
	move.w d1,d3
	cmp.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d1
	ble.s .min
	move.w GWVA_WTEXT_OBJ_AFF_COLONNE(a1),d1
.min:	tst d1
	bpl.s .max
	clr d1
.max:	move.w d1,GWVA_WTEXT_OBJ_AFF_COLONNE(a1)

.pas_texte:
	endc

	rts


;-----------------------------------------------------------------------------
; GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE2:	Calcul la position du curseur ligne d'affichage courant.
;	Entr‚es:	a0	: ptr sur struc. de la fenˆtre
;	Sortie:	
;-----------------------------------------------------------------------------
GWVA_WTEXT_OBJ_PRG_CALCULATE_PVSLIDE2:

	move GWVA_WIND_OBJ_INTERNAL_H(a0),d2	; hauteur interne de la fenˆtre sans la toolbar

	ifd MDL_WIND_TEXT

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)	; fenˆtre texte ?
	bne.s .pas_texte

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	ext.l d2
	divu GWVA_WTEXT_OBJ_CELL_HEIGHT(a1),d2	; nb lignes pouvant ˆtre affich‚es dans la fenˆtre
					; de 1 … n
	move GWVA_WTEXT_OBJ_BUF_LIGNE(a1),d1
	add.w #1,d1
	sub.w d2,d1				; d1 = num‚ro de 1er ligne de la fenˆtre
	move.w d1,d3
	cmp.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d1	; on rectifie
	ble.s .min
	move.w GWVA_WTEXT_OBJ_AFF_LIGNE(a1),d1
.min:	tst d1
	bpl.s .max
	clr d1
.max:	move.w d1,GWVA_WTEXT_OBJ_AFF_LIGNE(a1)

.pas_texte:
	endc

	rts

;-----------------------------------------------------------------------------

	ifd MDL_WIND_BITMAP

GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE:
	save.l a0

	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi .the_top_windows_is_not_mine

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .set_desk_pal

	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)
	bne .window_namified

	move.l (GWVA_WBITM_OBJ_PAL_PTR,[GWVA_WIND_OBJ_SPEC_PTR,a0]),d0
	beq.s .pas_de_palette

	moveq #1,d1		; est-on dans une r‚solution avec palette ?
	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d2
	lsl.w d2,d1
	cmp.w GWVA_APP_OBJ_VDI_WORKSTATION+13*2,d1
	bne.s .pas_resolution_palette

	move.l d0,-(sp)
	move GWVA_APP_OBJ_VDI_WORKSTATION+13*2,-(sp)
	clr -(sp)
	appel xbios,$5d,10	; set RGB palette

.pas_resolution_palette:
	load.l a0
	rts

.pas_de_palette:
.window_namified:
.set_desk_pal:
.the_top_windows_is_not_mine:
	bsr.s GWVA_WBITM_OBJ_PRG_RESET_DESK_PALETTE
	load.l a0
	rts

		*------------------*

GWVA_WBITM_OBJ_PRG_RESET_DESK_PALETTE:

	moveq #1,d0
	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d1
	lsl.w d1,d0
	cmp.w GWVA_APP_OBJ_VDI_WORKSTATION+13*2,d0
	bne.s .pas_de_palette

	save.l a0

	pea GWVA_APP_OBJ_SAVE_PALETTE
	move GWVA_APP_OBJ_VDI_WORKSTATION+13*2,-(sp)
	clr -(sp)
	appel xbios,$5d,10

	load.l a0
.pas_de_palette:
	rts

	endc

;-----------------------------------------------------------------------------

	ifd MDL_WIND_FORM

	ifd FORM_OBJ_PROGRESS

GWVA_PROGRESS_OBJ_PRG_SET_PERCENT:	; a0=ptr object, d0=percent
	move.w d0,GWVA_FORM_PROGRESS_OBJ_PERCENT(a0)
	rts

GWVA_PROGRESS_OBJ_PRG_UPDATE_PERCENT:	; a0=ptr fenˆtre, a1=ptr object, d0=percent, d1=0 si form 1=si toolbar
	cmp.w GWVA_FORM_PROGRESS_OBJ_PERCENT(a1),d0
	beq.s .no_change

	exg.l a0,a1
	bsr GWVA_PROGRESS_OBJ_PRG_SET_PERCENT
	exg.l a0,a1
	move d1,d0
	bra GWVA_PROGRESS_OBJ_PRG_PRINT_PERCENT

.no_change:	rts

GWVA_PROGRESS_OBJ_PRG_PRINT_PERCENT:	; a0=ptr fenˆtre, a1=ptr object, d0=0 si form 1=si toolbar

	tst d0
	beq.s .form
	move.l GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR(a0),a2
	bra.s .cont
.form:	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a2
.cont:

	save.l a0-a2/d0
	move.l #0,a3
	move.w GWVA_WFORM_OBJ_FORM_IDX(a2),d0
	beq.s .no
	move.w GWVA_FORM_PROGRESS_OBJ_TEXT_IDX(a1),d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a3
.no:	load.l a0-a2/d0

	move.l GWVA_WFORM_OBJ_FORM_PTR(a2),a2

	move.w GWVA_FORM_PROGRESS_OBJ_GRAPHIC_FIDX(a1),d1
	mulu #L_OBJECT,d1
	move.w GWVA_FORM_PROGRESS_OBJ_GRAPHIC_SIDX(a1),d2
	mulu #L_OBJECT,d2

	move GWVA_FORM_PROGRESS_OBJ_PERCENT(a1),d3
	tst d3
	bmi.s .infinite
	cmp.w #100,d3
	ble.s .correct

.infinite:	cmp.l #0,a3
	beq.s .notxt
	move.w #'oo',(a3)
	clr.b 2(a3)
.notxt:	tst d1
	beq.s .no_phix
	move ob_width(a2,d1.w),ob_width(a2,d2.w)
.no_phix:	bra.s .done

.correct:	tst d1
	beq.s .no_phix2
	mulu ob_width(a2,d1.w),d3
	divu #100,d3
	move d3,ob_width(a2,d2.w)
.no_phix2:

	cmp.l #0,a3
	beq.s .no_txt2
	save.l d0/a0-a1
	clr.l d0
	move GWVA_FORM_PROGRESS_OBJ_PERCENT(a1),d0
	move.l a3,a1
	bsr STOCK_DECI
	load.l d0/a0-a1
.no_txt2:
.done:
	; redraw

	move d0,d2

	move.w GWVA_FORM_PROGRESS_OBJ_TEXT_IDX(a1),d0
	beq.s .no_txt3
	moveq #7,d1
	save.l d2/a1
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l d2/a1
.no_txt3:
	move.w GWVA_FORM_PROGRESS_OBJ_GRAPHIC_FIDX(a1),d0
	beq.s .no_phix3
	moveq #7,d1
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
.no_phix3:
	rts

	endc

	ifd FORM_OBJ_SLIDER

GWVA_SLIDER_OBJ_PRG_SET_SLIDER:	; a0=ptr fenˆtre, a1=ptr formulaire, a2=ptr objet slider
			; Retour d7.l=deplacement silder eventuel (actualis‚)
	move.l GWVA_FORM_SLIDER_OBJ_POS(a2),d1

	move.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_SIDX(a2),d2
	mulu #L_OBJECT,d2
	add.l GWVA_WFORM_OBJ_FORM_PTR(a1),d2
	move.l d2,a4

	move.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_FIDX(a2),d2
	mulu #L_OBJECT,d2
	add.l GWVA_WFORM_OBJ_FORM_PTR(a1),d2
	move.l d2,a5

	move.w #ob_x,d2
	move.w #ob_width,d3
	tst.w GWVA_FORM_SLIDER_OBJ_ORIENT(a2)
	beq.s .s_o_horiz
	move.w #ob_y,d2
	move.w #ob_height,d3
.s_o_horiz:	
	move.w (a5,d3.w),d4		;  taille pŠre
	move.l GWVA_FORM_SLIDER_OBJ_LENGTH(a2),d5

	ext.l d4
	mulu.l GWVA_FORM_SLIDER_OBJ_SIZE(a2),d6:d4
	divu.l d5,d6:d4

	move.w d4,d0
	sub.w (a4,d3.w),d0		; d0.w = 0 : pas de changementde taille graphique

	move.w d4,(a4,d3.w)		; nouvelle taille graphique du fils

	move.w (a5,d3.w),d4		;  taille pŠre
	sub.w (a4,d3.w),d4		;- taille fils = deplacement relatif possible du fils dans le pŠre
	ble.s .s_o_pas_de_place

	move.l GWVA_FORM_SLIDER_OBJ_LENGTH(a2),d5
	sub.l GWVA_FORM_SLIDER_OBJ_SIZE(a2),d5
	ble.s .s_o_pas_de_place

	ext.l d4
	mulu.l GWVA_FORM_SLIDER_OBJ_POS(a2),d6:d4
	divu.l d5,d6:d4

	move.w d4,d3
	sub.w (a4,d2.w),d3		; d3.w = 0 : pas de d‚placement graphique

	move.w d4,(a4,d2.w)		; nouvelle position graphique du fils


	or.w d3,d0

.s_o_update_affichage:

	tst.w d0
	beq.s .s_o_pas_chgt_g_slider

	save.l d1/a0-a2
	move.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_FIDX(a2),d0
	move.w #6,d1

	move.w #0,d2	; dans le formulaire

	btst #GWVA_WIN_BIT_ATOOLBAR,GWVA_WIND_OBJ_PROPERTIES+1(a0)
	beq.s .s_o_pas_de_toolbar
	move.l GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR(a0),a4
	cmp.l a1,a4
	bne.s .s_o_pas_dans_toolbar
	move.w #1,d2
.s_o_pas_dans_toolbar:
.s_o_pas_de_toolbar:

	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l d1/a0-a2

.s_o_pas_chgt_g_slider:

	move.l GWVA_FORM_SLIDER_OBJ_POS(a2),d0
	move.l d0,d7
	sub.l d1,d7
	rts

.s_o_pas_de_place:
	move.w (a5,d3.w),d0
	sub.w (a4,d3.w),d0
	move.w (a5,d3.w),(a4,d3.w)	;  taille fils = taille pŠre
	clr.w (a4,d2.w)		;  pos fils = 0
	clr.l GWVA_FORM_SLIDER_OBJ_POS(a2)
	bra.s .s_o_update_affichage

	endc

	endc

;-----------------------------------------------------------------------------

