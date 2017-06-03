 ifnd GWVA_APP_OBJ_STACK_SIZE
  fail	; D‚finissez la taille de la pile !
  end
 endc

 ifnd GWVA_MAX_PATH_LENGTH
  fail	; D‚finissez la longeur max d'un pathname
  end
 endc

 ifnd GWVA_APP_DEP_LIB_VERSION
  fail	; D‚finissez la version des librairies
  end
 else
  ifne GWVA_APP_DEP_LIB_VERSION-4
   fail	; Procurez-vous une version 4.x.y Visual Assembleur
   end
  endc
 endc

 ifnd GWVA_APP_DEP_LIB_MAJOR
  fail	; D‚finissez le patchlevel majeur
  end
 else
  ifne GWVA_APP_DEP_LIB_MAJOR-0
   fail	; Procurez-vous une version 4.0.y Visual Assembleur
   end
  endc
 endc

 ifnd GWVA_APP_DEP_LIB_MINOR
  fail	; D‚finissez le patchlevel mineur
  end
 endc

 ifd MDL_GEM

  ifd MDL_TOS
   fail	; On ne peut pas mettre et MDL_GEM et MDL_TOS
   end
  endc

  ifd MDL_WIND
   ifnd GWVA_APP_OBJ_MAX_NUMBER_WIND
    fail	; D‚finissez le nombre maximal de fenˆtres pour votre application !
    end
   endc
  endc

  ifnd MDL_EVENTS

   ifd MDL_MENU
    fail	; MDL_MENU n‚cessite MDL_EVENTS
    end
   endc

   ifd MDL_WIND
    fail	; MDL_WIND n‚cessite MDL_EVENTS
    end
   endc

  endc

  ifnd MDL_WIND

   ifd MDL_WIND_TEXT
    fail	; MDL_WIND_TEXT n‚cessite MDL_WIND
    end
   endc

   ifd MDL_WIND_FORM
    fail	; MDL_WIND_FORM n‚cessite MDL_WIND
    end
   endc

   ifd MDL_WIND_IMG
    fail	; MDL_WIND_IMG n‚cessite MDL_WIND
    end
   endc

  endc

 else

  ifnd MDL_TOS
   fail	; Il faut imp‚rativement MDL_GEM ou MDL_TOS
   end
  endc

  ifd MDL_EVENTS
   fail	; MDL_TOS est incompatible avec MDL_EVENTS
   end
  endc

  ifd MDL_MENU
   fail	; MDL_TOS est incompatible avec MDL_MENU
   end
  endc

  ifd MDL_WIND
   fail	; MDL_TOS est incompatible avec MDL_WIND
   end
  endc

  ifd MDL_WIND_TEXT
   fail	; MDL_TOS est incompatible avec MDL_WIND_TEXT
   end
  endc

  ifd MDL_WIND_FORM
   fail	; MDL_TOS est incompatible avec MDL_WIND_FORM
   end
  endc

  ifd MDL_WIND_IMG
   fail	; MDL_TOS est incompatible avec MDL_WIND_IMG
   end
  endc

  ifd LIB_FILESELECTOR
   fail	; MDL_TOS est incompatible avec LIB_FILESELECTOR
   end
  endc

 endc

  ifd FORM_OBJ_PROGRESS
   ifnd LIB_DECI
    fail	; LIB_DECI est imp‚ratif pour l'obet PROGRESS
    end
   endc
  endc

  ifd LIB_XHDI_INFOPARTITION
   ifnd LIB_XHDI_INQTARGET
    fail	; LIB_XHDI_READWRITE est imp‚ratif pour la librairie LIB_XHDI_INFOPARTITION
    end
   endc

   ifnd LIB_XHDI_READWRITE
    fail	;  LIB_XHDI_READWRITE est imp‚ratif pour la librairie LIB_XHDI_INFOPARTITION
    end
   endc
  endc
*--------------------------------------------------------------------------*

	opt o+,ow-

	include constant.s
	include sys_def.s
	include guw_def.s
	include macros.s

	ifd MDL_GEM
	include gemmacro.i
	endc

*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*---------------------       DEBUT CODE VISUAL        ---------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*

VISUAL40_START:
	move.l a1,GWVA_APP_OBJ_PTR
	moveq #0,d1
	move.l a0,a5
	move.l a5,d0
	bne.s .acc
	moveq #1,d1
	move.l 4(a7),a5
	move.l a5,GWVA_APP_OBJ_BASE_PAGE
.acc:	move.w d1,GWVA_APP_OBJ_IS_ACC_PRG

	clr.w GWVA_APP_OBJ_CMD_LINE_SIZE	; 0 si acc
	lea GWVA_APP_OBJ_STACK,a7
	tst d1
	beq.s .pas_de_setblock_si_acc
	move.l 12(a5),d0
	add.l 20(a5),d0
	add.l 28(a5),d0
	add.l #$100,d0
	and.l #-2,d0
	addq.l #2,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	clr.w -(sp)
	appel dos,$4a,12
	clr d1
	add.b $80(a5),d1
	move.w d1,GWVA_APP_OBJ_CMD_LINE_SIZE
	lea $81(a5),a5
	move.l a5,GWVA_APP_OBJ_CMD_LINE_PTR
.pas_de_setblock_si_acc:

*--------------------------------------------------------------------------*

	ifd MDL_GEM
	appl_init
	tst d0
	bmi GWVA_APPL_INIT_FAILED

	graf_handle
	move.w d0,current_handle	; Desktop's VDI handle

	tst GWVA_APP_OBJ_IS_ACC_PRG
	beq.s .jump_vdi_inits_if_acc

	bsr GWVA_APP_OBJ_PRG_OPEN_VSTATION
	tst d7
	bmi GWVA_OPEN_WORKSTATION_FAILED

.jump_vdi_inits_if_acc:

	SUPEXEC GWVA_APP_OBJ_SEARCH_SYSTEM_COOKIES	; tos+s‚lectrix+copro+Mint

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_RSC_INFO(a0)
	beq .pas_de_ressource

	move.l GWVA_APP_OBJ_RSC_INFO(a0),a1
	btst #GWVA_APP_BIT_RSC_MULTI_RES,GWVA_APP_OBJ_FLAGS(a0)
	beq.s .un_seul_ressource

	moveq #1,d1		; est-on dans une r‚solution avec palette ?
	move.w GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d2
	lsl.w d2,d1
	move.w GWVA_APP_OBJ_VDI_WORKSTATION+13*2,d3
	cmp.w d3,d1
	beq.s .resolution_palette
	move.w #-1,d1	; pas de palette
.resolution_palette
	cmp.w #2,d1
	beq.s .color_2
	lea 4(a1),a1
	cmp.w #4,d1
	beq.s .color_4
	lea 4(a1),a1
	cmp.w #16,d1
	beq.s .color_16
	lea 4(a1),a1
	cmp.w #256,d1
	beq.s .color_256
	lea 4(a1),a1
.color_2:
.color_4:
.color_16:
.color_256:
	move.l (a1),a1
	cmp.l #0,a1
	beq.s .rsc_fail

.un_seul_ressource:

	btst #GWVA_APP_BIT_RSC_IN_MEM,GWVA_APP_OBJ_FLAGS(a0)
	bne.s .in_memory

	rsrc_load a1
	tst.w d0
	bne.s .rsc_loaded_ok

.rsc_fail:	lea GWVA_ALERT_NO_RSC,a0
	moveq #1,d0
	bsr ALERT_BOX
	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne GWVA_APP_RSC_LOAD_FAILED
	bra GWVA_INFINITE_LOOP

.in_memory:
	ifd MDL_RELOCATE_RSC
	move.l a1,a0
	bsr GWVA_RELOCATE_RSC
	tst d7
	bmi.s .rsc_fail
	endc

.pas_de_ressource:
.rsc_loaded_ok:

	ifd MDL_MENU
	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0)
	beq .pas_de_menu

	move.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0),a1
	move.w GWVA_MENU_STRUCT_INDEX(a1),d0
	lea GWVA_MENU_STRUCT_PTR(a1),a0	; ad. menu principal
	save.l a1
	bsr RETURN_TREE_OBJ_PTR
	load.l a0

	tst.l GWVA_MENU_STRUCT_LIST_ATTACH_PTR(a0)
	beq.s .pas_de_sous_menu

	move.l GWVA_MENU_STRUCT_LIST_ATTACH_PTR(a0),a0

.loop_ss_mn:tst.l (a0)
	move.l (a0),a1
	beq.s .fin_liste_ss_menu

	move GWVA_SUB_MENU_TREE(a1),d0
	clr d1
	save.l a0-a1
	bsr RETURN_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a3
	movem.l (sp),a0-a1

	lea GWVA_APP_OBJ_TMP_MENU_OBJ,a2
	move.l a3,mn_tree(a2)
	move.w GWVA_SUB_MENU_INDEX(a1),mn_menu(a2)
	move.w GWVA_SUB_MENU_WHICH_ALIGN(a1),mn_item(a2)
	move.w GWVA_SUB_MENU_SCROLL(a1),mn_scroll(a2)
	move.w #0,mn_keystate(a2)

	move GWVA_SUB_MENU_TREE_OBJ_ATTACHED(a1),d0
	clr d1
	bsr RETURN_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a2
	movem.l (sp),a0-a1

	menu_attach #1,a2,GWVA_SUB_MENU_OBJ_IDX_ATTACHED(a1),#GWVA_APP_OBJ_TMP_MENU_OBJ
	load.l a0-a1

	lea 4(a0),a0
	bra.s .loop_ss_mn

.fin_liste_ss_menu:
.pas_de_sous_menu:
.pas_de_menu:
	endc

	ifd MDL_WIND
	move #GWVA_APP_OBJ_MAX_NUMBER_WIND-1,d0
	lea GWVA_APP_OBJ_WIND_LIST,a0
.clr_list:	clr.l (a0)+
	dbf d0,.clr_list
	endc

	endc			; ifd MDL_GEM

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne.s .in_base_page_for_prg
	FSETDTA GWVA_APP_OBJ_DTA
.in_base_page_for_prg:

	lea GWVA_APP_OBJ_STARTED_PATH,a0
	bsr GWVA_APP_OBJ_STORE_CURRENT_PATH

*--------------------------------------------------------------------------*
	clr.w GWVA_APP_OBJ_RETURN_CODE
	move.l (GWVA_APP_OBJ_CUSTOM_INITS,[GWVA_APP_OBJ_PTR.l]),a1
	cmp.l #0,a1
	beq.s .pas_custom_inits
	move GWVA_APP_OBJ_CMD_LINE_SIZE,d0
	move.l GWVA_APP_OBJ_CMD_LINE_PTR,a0
	jsr (a1)
.pas_custom_inits:
*--------------------------------------------------------------------------*

	ifd MDL_GEM

	tst GWVA_APP_OBJ_IS_ACC_PRG
	bne.s .no_menu_register_if_prg

**** inits ACC

	menu_register global+_AESapid,<(GWVA_APP_OBJ_ACC_NAME,[GWVA_APP_OBJ_PTR.l])>
	move d0,GWVA_APP_OBJ_ACC_NUMBER
	bmi GWVA_INFINITE_LOOP

	menu_register #-1,<(GWVA_APP_OBJ_REG_NAME,[GWVA_APP_OBJ_PTR.l])>

	bra .saute_prg_inits_if_acc

.no_menu_register_if_prg:
	cmp #1,global+_AESnumapps
	beq.s .no_mint

**** inits MiNT

	menu_register global+_AESapid,<(GWVA_APP_OBJ_ACC_NAME,[GWVA_APP_OBJ_PTR.l])>
	shel_write #9,#1,#0,#0,#0	; re‡oit les messages MiNT

**** inits PRG

.no_mint:	menu_register #-1,<(GWVA_APP_OBJ_REG_NAME,[GWVA_APP_OBJ_PTR.l])>

	move.l GWVA_APP_OBJ_PTR,a0
	btst #GWVA_APP_BIT_BACKGROUND,GWVA_APP_OBJ_FLAGS(a0)
	beq .pas_de_background

	move GWVA_APP_OBJ_BACKGROUND_OBJ(a0),d0
	bsr RETURN_FORM_OBJ_SCULPTURE

	move.l GWVA_APP_OBJ_DESKTOP_X,ob_x(a0)
	add.w d0,ob_x(a0)
	add.w d1,ob_y(a0)
	move.l GWVA_APP_OBJ_DESKTOP_W,ob_width(a0)
	sub.w d0,ob_width(a0)
	sub.w d2,ob_width(a0)
	sub.w d1,ob_height(a0)
	sub.w d3,ob_height(a0)

	save.l a0
	move.l GWVA_APP_OBJ_PTR,a0
	btst #GWVA_APP_BIT_BACKGROUND_CENTER,GWVA_APP_OBJ_FLAGS(a0)
	beq.s .pas_centre_auto
	move GWVA_APP_OBJ_BACKGROUND_OBJ(a0),d0
	move #1,d1
	bsr RETURN_OBJ_IN_FORM_OBJ_PTR
	move.w GWVA_APP_OBJ_DESKTOP_W,d0
	sub.w ob_width(a1),d0
	bmi.s .no_x
	asr.w #1,d0
	add.w GWVA_APP_OBJ_DESKTOP_X,d0
	bmi.s .no_x
	move d0,ob_x(a1)
.no_x:	move.w GWVA_APP_OBJ_DESKTOP_H,d0
	sub.w ob_height(a1),d0
	bmi.s .no_y
	asr.w #1,d0
	add.w GWVA_APP_OBJ_DESKTOP_Y,d0
	bmi.s .no_y
	move d0,ob_y(a1)
.no_y:

.pas_centre_auto:
	load.l a0

	move.l a0,int_in+2*2
	clr.w int_in+4*2	; Num‚ro du 1er objet … redessiner
	wind_set #0,#WF_NEWDESK

	form_dial #3,#0,#0,#0,#0,GWVA_APP_OBJ_DESKTOP_X,GWVA_APP_OBJ_DESKTOP_Y,GWVA_APP_OBJ_DESKTOP_W,GWVA_APP_OBJ_DESKTOP_H

.pas_de_background:

	ifd MDL_MENU

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0)
	beq.s .pas_de_menu2
	move.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0),a1
	move.l GWVA_MENU_STRUCT_PTR(a1),a0
	bsr GWVA_SHOW_MENU
.pas_de_menu2:

	endc

.saute_prg_inits_if_acc:

	endc			; ifd MDL_GEM

*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*------------------    CODE SPECIFIQUE AUX EVENEMENTS   -------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*

	ifd MDL_EVENTS

	clr.w GWVA_APP_OBJ_EVENT_BITS

GWVA_MAIN_EVENTS_LOOP:
	tst.w GWVA_APP_OBJ_EVENT_BITS
	bne .old_evnt_waiting

	move.l GWVA_APP_OBJ_PTR,a0

	clr d0

	bset #EVNT_KEYBD,d0

	ifd MDL_WIND
	bset #EVNT_BUTTON,d0
	else
	tst.l GWVA_APP_OBJ_EVNT_BUTTON(a0)
	beq.s .pas_evnt_button
	bset #EVNT_BUTTON,d0
.pas_evnt_button:
	endc

	tst.l GWVA_APP_OBJ_EVNT_MOUSE1(a0)
	beq.s .pas_evnt_mouse1
	tst.l GWVA_APP_OBJ_M1W(a0)
	beq.s .pas_evnt_mouse1
	bset #EVNT_MOUSE1,d0
.pas_evnt_mouse1:
	tst.l GWVA_APP_OBJ_EVNT_MOUSE2(a0)
	beq.s .pas_evnt_mouse2
	tst.l GWVA_APP_OBJ_M2W(a0)
	beq.s .pas_evnt_mouse2
	bset #EVNT_MOUSE2,d0
.pas_evnt_mouse2:

	bset #EVNT_MESAG,d0

	tst.l GWVA_APP_OBJ_EVNT_TIMER(a0)
	beq.s .pas_evnt_timer
	tst.l GWVA_APP_OBJ_COUNT(a0)
	beq.s .pas_evnt_timer
	bset #EVNT_TIMER,d0
.pas_evnt_timer:

	move.w d0,GWVA_APP_OBJ_EVENT_BITS

	; #2,#3,#3
	evnt_multi d0,
&	#$102,#$3,#$0,
&	GWVA_APP_OBJ_M1FLAG(a0),GWVA_APP_OBJ_M1X(a0),GWVA_APP_OBJ_M1Y(a0),GWVA_APP_OBJ_M1W(a0),GWVA_APP_OBJ_M1H(a0),
&	GWVA_APP_OBJ_M2FLAG(a0),GWVA_APP_OBJ_M2X(a0),GWVA_APP_OBJ_M2Y(a0),GWVA_APP_OBJ_M2W(a0),GWVA_APP_OBJ_M2H(a0),
&	#GWVA_APP_OBJ_MSG_BUF,
&	GWVA_APP_OBJ_COUNT(a0)

	move.w d0,GWVA_APP_OBJ_EVENT_BITS

	move.l int_out+2,GWVA_APP_OBJ_EVNT_MULTI_MX
	move.l int_out+6,GWVA_APP_OBJ_EVNT_MULTI_MB
	move.l int_out+10,GWVA_APP_OBJ_EVNT_MULTI_KC

.old_evnt_waiting:
	move.w GWVA_APP_OBJ_EVENT_BITS,d0

; L'evnt_mesag doit etre trait‚ en premier car il peut informer d'un changement systeme
; dont il faut que les routines suivantes soient averties.

	btst #EVNT_MESAG,d0
	bne GWVA_APP_OBJ_PRG_EVNT_MESSAGE

	btst #EVNT_TIMER,d0
	bne.s GWVA_APP_OBJ_PRG_EVNT_TIMER

	btst #EVNT_BUTTON,d0
	bne GWVA_APP_OBJ_PRG_EVNT_BUTTON

	btst #EVNT_MOUSE1,d0
	bne GWVA_APP_OBJ_PRG_EVNT_MOUSE1

	btst #EVNT_MOUSE2,d0
	bne GWVA_APP_OBJ_PRG_EVNT_MOUSE2

	btst #EVNT_KEYBD,d0	; doit ˆtre aprŠs le button : car on transforme un evnt_keyb en evnt_but
	bne.s GWVA_APP_OBJ_PRG_EVNT_KEYBOARD

	illegal

*--------------------------------------------------------------------------*
GWVA_APP_OBJ_PRG_EVNT_TIMER:
	move #EVNT_TIMER,d7
	bsr GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_EVNT_TIMER(a0)
	beq GWVA_MAIN_EVENTS_LOOP

	jsr ([GWVA_APP_OBJ_EVNT_TIMER,a0])

	bra GWVA_MAIN_EVENTS_LOOP

*--------------------------------------------------------------------------*
GWVA_APP_OBJ_PRG_EVNT_KEYBOARD:
	move #EVNT_KEYBD,d7
	bsr GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT

	ifd MDL_MENU

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0)
	beq.s .no_menu

	move.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0),a0
	move GWVA_APP_OBJ_EVNT_MULTI_KC,d0
	move.w #2+1+1+4,d1
	bsr GWVA_EXEC_MENU_ROUTINE_FROM_KC
	tst d7
	beq GWVA_MAIN_EVENTS_LOOP

.no_menu:
	endc

	ifd MDL_WIND

	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi .the_top_windows_is_not_mine

	btst #GWVA_WIN_BIT_NAMIFIED,GWVA_WIND_OBJ_STATUS+1(a0)
	bne .window_namified

	tst.l GWVA_WIND_OBJ_KEY_TABLE(a0)
	beq.s .pas_de_table_de_touches
	save.l a0
	move.l GWVA_WIND_OBJ_KEY_TABLE(a0),a0
	move GWVA_APP_OBJ_EVNT_MULTI_KC,d0
	move #2+2+4,d1
	bsr GWVA_CONVERT_KC_IN_OBJECT_IDX
	move.l a0,a1
	load.l a0
	tst d7
	bmi.s .pas_trouve_dans_la_table
	move GWVA_APP_OBJ_EVNT_MULTI_KC,d0
	move GWVA_APP_OBJ_EVNT_MULTI_KS,d1
	move (a1),d2
	tst.l 2+2(a1)
	beq.s .no_jump
	jsr ([4,a1])
.no_jump:	bra GWVA_MAIN_EVENTS_LOOP
.pas_trouve_dans_la_table:
.pas_de_table_de_touches:

	; flŠches -> wind_arrowed

	cmp.w #GWVA_WIND_TYPE_TEXT,GWVA_WIND_OBJ_TYPE(a0)
	beq.s .window_texte

	cmp.w #GWVA_WIND_TYPE_BITMAP,GWVA_WIND_OBJ_TYPE(a0)
	bne.s .pas_window_bitmap


.window_texte:
	bftst GWVA_WIND_OBJ_FLAGS(a0){15-11:6}
	beq.s .got_no_slide_arrow

	move GWVA_APP_OBJ_EVNT_MULTI_KC,d1

	lea GWVA_WTEXT_OBJ_SHORTCUTS,a1
.search2:	tst.l (a1)
	bmi.s .no_window_shortcut
	move.w (a1),d2
	cmp.w d2,d1
	beq.s .window_key
	add.w #2+2,a1
	bra.s .search2

.window_key:lea GWVA_APP_OBJ_MSG_EXT_BUF,a2
	move.w #WM_ARROWED,(a2)+	; type de message
	move.w global+_AESapid,(a2)+
	clr.w (a2)+
	move.w GWVA_WIND_OBJ_GEM_HANDLE(a0),(a2)+
	move.w 2(a1),(a2)+
	appl_write global+_AESapid,#16,#GWVA_APP_OBJ_MSG_EXT_BUF

	bra GWVA_MAIN_EVENTS_LOOP

.no_window_shortcut:
.got_no_slide_arrow:
.pas_window_bitmap:

	ifd MDL_WIND_FORM

	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_window_formulaire

	bsr GWVA_WIND_OBJ_PRG_UPDATE_TOOLB_AND_FORM_POS

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	; recherche d'un ‚ventuel shortcut <-> click sur bouton
	save.l a0-a1
	lea GWVA_WFORM_OBJ_START_OBJ_LIST(a1),a0
	move GWVA_APP_OBJ_EVNT_MULTI_KC,d0
	move.w #2+1+1+2+4,d1
	bsr GWVA_CONVERT_KC_IN_OBJECT_IDX
	load.l a0-a1
	tst d7
	bmi.s .pas_trouve_shortcut

	save.l a0-a1
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),d0
	load.l a0-a1

	move.l int_out+2,GWVA_APP_OBJ_EVNT_MULTI_MX

	move.w #1,GWVA_APP_OBJ_EVNT_MULTI_MB	; bton gauche
	move.w #1,GWVA_APP_OBJ_EVNT_MULTI_MC	; 1 click

	bra GWVA_APP_OBJ_PRG_EVNT_BUTTON

.pas_trouve_shortcut:
	tst GWVA_WFORM_OBJ_FOCUSED_TXT(a1)
	bne.s .there_s_editable_texte

	save.l a0/a1
	form_keybd GWVA_WFORM_OBJ_FORM_PTR(a1),#0,#1,GWVA_APP_OBJ_EVNT_MULTI_KC
	load.l a0/a1

	tst d0		; 0 = bouton 'exit' default, 1 = pas de bouton en 'default'
	bne.s .continue

.use_the_same_kbd_routine:

	move.w int_out+1*2,d0	; default object
	move.w d0,d1
	mulu #L_OBJECT,d1
	add.l GWVA_WFORM_OBJ_FORM_PTR(a1),d1
	move.l d1,a2
	bclr #0,ob_state+1(a2)	; d‚s‚lection de l'objet

	save.l d0/a0-a1
	move.w #1,d1
	clr d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l d0/a0-a1

	move #GWVA_EVNT_CLICK,d7
	lea GWVA_WFORM_OBJ_START_OBJ_LIST(a1),a2
	bsr GWVA_WIND_OBJ_PRG_SEARCH_EVNT

	bra GWVA_MAIN_EVENTS_LOOP

.touche_intraitable:
.continue:
	bra .end_evnt_keyboard

.there_s_editable_texte:
	cmp.w #$0f09,GWVA_APP_OBJ_EVNT_MULTI_KC
	bne.s .pas_tab
	move GWVA_APP_OBJ_EVNT_MULTI_KS,d0
	and.w #%11,d0
	beq.s .pas_shift_tab
	move.w #$4800,GWVA_APP_OBJ_EVNT_MULTI_KC
	clr.w GWVA_APP_OBJ_EVNT_MULTI_KS
.pas_shift_tab:
.pas_tab:
	save.l a0/a1
	form_keybd GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),#1,GWVA_APP_OBJ_EVNT_MULTI_KC
	load.l a0/a1

	tst d0		; 0 = bouton 'exit' default, 1 = pas de bouton en 'default'
	beq .use_the_same_kbd_routine

	tst int_out+4	; a-t-il r‚ussi … la traiter ?
	bne .fkbd_pas_pu_traiter_touche

	move int_out+2,d0	; int_out+2 = new obj

	save.l d0/a0/a1

	; Patch pour le GEM qui renvoie new_obj =0 si press‚ enter
	; et pas de bouton default
	mulu #L_OBJECT,d0
	add.l GWVA_WFORM_OBJ_FORM_PTR(a1),d0
	move.l d0,a2
	btst #3,ob_flags+1(a2)	; ‚ditable ?
	beq.s .next_obj_pas_editable

	objc_edit GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),#0,GWVA_WFORM_OBJ_CURSOR_POS(a1),#3
	load.l d0/a0/a1
	move d0,GWVA_WFORM_OBJ_FOCUSED_TXT(a1)
	save.l a0/a1
	objc_edit GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),#0,GWVA_WFORM_OBJ_CURSOR_POS(a1),#1
	load.l a0/a1
	move int_out+2,GWVA_WFORM_OBJ_CURSOR_POS(a1)

.next_obj_pas_editable:
	bra GWVA_MAIN_EVENTS_LOOP

.fkbd_pas_pu_traiter_touche:
	save.l a0/a1
	objc_edit GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),int_out+4,GWVA_WFORM_OBJ_CURSOR_POS(a1),#2
	load.l a0/a1

	tst d0
	beq .touche_intraitable
	move int_out+1*2,GWVA_WFORM_OBJ_CURSOR_POS(a1)

	bra GWVA_MAIN_EVENTS_LOOP

.end_evnt_keyboard:
.pas_window_formulaire:

	endc			; ifd MDL_WIND_FORM

	bra.s .one_of_mine		; pour retourner : a0=ptr sur struct fenˆtre

.the_top_windows_is_not_mine:

	endc			; ifd MDL_WIND

	move.l #0,a0
.one_of_mine:

	move.l GWVA_APP_OBJ_PTR,a1
	tst.l GWVA_APP_OBJ_EVNT_KEYBD(a1)
	beq GWVA_MAIN_EVENTS_LOOP

	move.w GWVA_APP_OBJ_EVNT_MULTI_KC,d0
	jsr ([GWVA_APP_OBJ_EVNT_KEYBD,a1])	; d0=touche, a0=ptr fenˆtre ou 0

.window_namified:
	bra GWVA_MAIN_EVENTS_LOOP

*--------------------------------------------------------------------------*

	ifd MDL_WIND_FORM

GWVA_WIND_OBJ_PRG_SEARCH_EVNT:	; d0=No objet, d7=‚vŠnement, a2=ptr liste
.find:	tst.w 0*2(a2)
	bmi.s .fin_liste_obj
	cmp.w 0*2(a2),d0
	beq.s .obj_found
	lea 2+2+2+4(a2),a2
	bra.s .find
.fin_liste_obj:
	rts
.obj_found:	move.l 2+2+2(a2),a3	; ptr sur la structure de l'objet
	cmp.w #GWVA_FORM_WIND_OBJECT_TEXT,2+2(a2)
	beq.s .champs_de_texte
	cmp.w #GWVA_FORM_WIND_OBJECT_BUTTON,2+2(a2)
	beq.s .bouton
	; le menu popup et le radio-bouton n'apparaissent pas ici car
	; il n'y a qu'un seul type de message possible (changed)
	; et il est compris dans la structure
	rts
.champs_de_texte:
	lea GWVA_FORM_TXT_OBJ_START_EVNT_LIST(a3),a4
	bra.s .commun
.bouton:	lea GWVA_FORM_BTON_OBJ_START_EVNT_LIST(a3),a4

.commun:
.find_evnt:	tst.w 0*2(a4)
	bmi.s .fin_liste_evnt
	cmp.w 0*2(a4),d7
	beq.s .evnt_found
	lea 2+4(a4),a4
	bra.s .find_evnt
.fin_liste_evnt:
	rts
.evnt_found:jsr ([2,a4])
	rts
	endc

*--------------------------------------------------------------------------*
GWVA_APP_OBJ_PRG_EVNT_BUTTON:
	move #EVNT_BUTTON,d7
	bsr GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT

	btst #0,GWVA_APP_OBJ_EVNT_MULTI_MB+1
	beq .its_not_left_button

	ifd MDL_WIND

	wind_find GWVA_APP_OBJ_EVNT_MULTI_MX,GWVA_APP_OBJ_EVNT_MULTI_MY
	move d0,GWVA_APP_OBJ_TMP_WIND_HANDLE
	; si on a un click et non un evnt_top c'est qu'elle est top !
	; ce n'est pas vrai si sur un WIND_TOP on ne fait pas LE WIND_TOP
	; demand‚ par le GEM ... on a alors un click dans la fenˆtre derriŠre

	bsr GWVA_WIND_OBJ_PRG_RETURN_PTR_FROM_HANDLE

	tst d7
	bmi .pas_a_nous_la_fenetre

	bsr GWVA_WIND_OBJ_PRG_UPDATE_TOOLB_AND_FORM_POS

	ifd MDL_WIND_FORM

	; est-ce la toolbar ?

	btst #GWVA_WIN_BIT_ATOOLBAR,GWVA_WIND_OBJ_PROPERTIES+1(a0)
	beq.s .no_toolbar

	move.l GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR(a0),a1

	save.l a0-a1
	objc_find GWVA_WFORM_OBJ_FORM_PTR(a1),#0,#7,GWVA_APP_OBJ_EVNT_MULTI_MX,GWVA_APP_OBJ_EVNT_MULTI_MY
	load.l a0-a1

	tst d0
	bmi.s .not_in_toolbar
	move #1,d2			; redraw toolbar
	bra.s .traite_click_formulaire

.not_in_toolbar:
.no_toolbar:

	cmp.w #GWVA_WIND_TYPE_FORM,GWVA_WIND_OBJ_TYPE(a0)
	bne .pas_fenetre_formulaire

	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1

	save.l a0-a1
	objc_find GWVA_WFORM_OBJ_FORM_PTR(a1),#0,#7,GWVA_APP_OBJ_EVNT_MULTI_MX,GWVA_APP_OBJ_EVNT_MULTI_MY
	load.l a0-a1

	tst d0
	bmi .pas_d_objet

	clr d2			; redraw contents

.traite_click_formulaire:
	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a2
	move d0,d3
	mulu #L_OBJECT,d3
	add.l d3,a2

	; on teste si je suis pas s‚lectable mais que mon pŠre le serait
	; et dans ce cas on fait comme si il avait cliqu‚ dans mon pŠre

	btst #0,ob_flags+1(a2)
	bne.s .je_suis_selectable

	save.l a0-a2/d0/d2
	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a0	; +d0 num obj
	bsr GWVA_FIND_FATHER_OBJECT
	move d0,d1
	move.l a0,a3
	load.l a0-a2/d0/d2
	tst d7
	bmi.s .click_in_root

	btst #0,ob_flags+1(a3)
	beq.s .je_suis_pas_selectable

	move d1,d0
	move.l a3,a2	; l'objet cliqu‚ devient le pŠre

.je_suis_pas_selectable:
.click_in_root:
.je_suis_selectable:
	move ob_state(a2),d3
	btst #3,d3
	bne .object_disabled

	btst #3,ob_flags+1(a2)	; ‚ditable ? G_FTEXT G_FBOXTEXT
	beq .pas_texte_editable

	; d0 : objet
	; d2 : quoi redressiner
	; d3 : ‚tat de l'objet avant modifs
	; a0 : window
	; a1 : ptr form struct
	; a2 : ptr objet cliqu‚
	save.l d0/d2/d3/a0-a2
	v_hide_c
	movem.l (sp),d0/d2/d3/a0-a2
	objc_edit GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),#0,GWVA_WFORM_OBJ_CURSOR_POS(a1),#3
	movem.l (sp),d0/d2/d3/a0-a2
	move d0,GWVA_WFORM_OBJ_FOCUSED_TXT(a1)
	objc_edit GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_WFORM_OBJ_FOCUSED_TXT(a1),#0,GWVA_WFORM_OBJ_CURSOR_POS(a1),#1
	movem.l (sp),d0/d2/d3/a0-a2
	move.w int_out+2,GWVA_WFORM_OBJ_CURSOR_POS(a1)
	v_show_c #1
	load.l d0/d2/d3/a0-a2

.pas_texte_editable:
	save.l d0/d2/d3/a0-a2
	form_button GWVA_WFORM_OBJ_FORM_PTR(a1),d0,GWVA_APP_OBJ_EVNT_MULTI_MC
	move d0,d1
	move.w int_out+2,d4		; *newobject : index de l'objet s'il est editable ou exit (bit 15 mis si double clic et touche-exit)
	load.l d0/d2/d3/a0-a2

	; il retourne un z‚ro si
	; bouton est exit avec le click relach‚ dans le bouton
	; bouton est touch_exit qqs la position de la souris au relachement

	tst d1
	bne.s .propriete_exit_non_activee

	; conditions de redessin ...

	btst #4,ob_flags+1(a2)
	bne.s .radio_no_redraw		; car radio bouton : le GEM
				; a d‚j… dessin‚ pour nous

	btst #0,ob_flags+1(a2)		; l'objet doit etre selectionable pour changer d'‚tat
	beq.s .no_selectable

	bclr #0,ob_state+1(a2)		; d‚s‚lection de l'objet
	beq.s .no_redraw_object		; car pas s‚lectionn‚

	move.w #1,d1
	; d2 est configur‚ !
	save.l d0/d3/a0-a2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l d0/d3/a0-a2
.no_redraw_object:
.no_selectable:

	bra.s .envoie_message		; de toute fa‡on

.radio_no_redraw:
.propriete_exit_non_activee:
	; soit radio juste s‚lectable
	; soit bouton juste selectable

	btst #0,ob_flags+1(a2)		; s‚lectionnable
	beq .pas_selectionable

	cmp ob_state(a2),d3
	beq .etat_inchange

	btst #4,ob_flags+1(a2)
	beq.s .bouton_normal

	; ici : radio-bouton

	save.l a0-a2/d0/d2/d3
	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a0	; +d0 num obj
	bsr GWVA_FIND_FATHER_OBJECT
	move d0,d1
	load.l a0-a2/d0/d2/d3
	swap d0	; on garde l'obj cliqu‚ mais on bosse avec le pŠre
	move d1,d0

.bouton_normal:
.envoie_message:

	; le dessin de l'objet a ‚t‚ modifi‚ car l'objet a chang‚ d'‚tat
	; il est peut-ˆtre radio sans rien ou juste selectable

	lea GWVA_WFORM_OBJ_START_OBJ_LIST(a1),a2

.do_research:
	tst (a2)
	bmi.s .fin_liste

	cmp.w 0*2(a2),d0
	beq.s .found_obj
	lea 2+2+2+4(a2),a2
	bra.s .do_research

.fin_liste:	bra .objet_clicke_non_trouve	; pas dans la liste

.found_obj:	move.l 2+2+2(a2),a3		; ptr sur la structure de l'objet
	cmp.w #GWVA_FORM_WIND_OBJECT_TEXT,2+2(a2)
	beq.s .champs_de_texte
	cmp.w #GWVA_FORM_WIND_OBJECT_BUTTON,2+2(a2)
	beq.s .bouton
	cmp.w #GWVA_FORM_WIND_OBJECT_MENU_POPUP,2+2(a2)
	beq.s .menu_popup
	cmp.w #GWVA_FORM_WIND_OBJECT_RADIO_BUTTON,2+2(a2)
	beq .radio_bouton

	ifd FORM_OBJ_SLIDER
	cmp.w #GWVA_FORM_WIND_OBJECT_SLIDER,2+2(a2)
	beq .slider_object
	endc

	bra GWVA_MAIN_EVENTS_LOOP

.champs_de_texte:
	; placer le curseur o— il faut

	bra.s .envoie_evnt_click_ou_dclick

.bouton:	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a4
	move d0,d3
	mulu #L_OBJECT,d3
	add d3,a4

	move.w ob_state(a4),d1
	move.w d1,GWVA_FORM_BTON_OBJ_STATE(a3)

	btst #2,ob_flags+1(a4)			; exit
	bne.s .envoie_evnt_click_ou_dclick
	btst #6,ob_flags+1(a4)			; touchexit
	bne.s .envoie_evnt_click_ou_dclick

	move #GWVA_EVNT_SELECTED,d7
	btst #0,ob_state+1(a4)
	bne.s .selected
	move #GWVA_EVNT_UNSELECTED,d7
.selected:	bra.s .evenement_search


.envoie_evnt_click_ou_dclick:
	move #GWVA_EVNT_CLICK,d7
	cmp.w #2,GWVA_APP_OBJ_EVNT_MULTI_MC
	bne.s .simple_click
	move #GWVA_EVNT_DCLICK,d7
.simple_click:
.evenement_search:
	lea GWVA_WFORM_OBJ_START_OBJ_LIST(a1),a2
	bsr GWVA_WIND_OBJ_PRG_SEARCH_EVNT

	bra GWVA_MAIN_EVENTS_LOOP

.menu_popup:save.l d0/a0-a3
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),d0
	load.l d0/a0-a3
	move.w int_out+2,d1	; position x
	move.w int_out+4,d2	; position y

	save.l d0-d2/a0-a3
	move.w GWVA_FORM_POP_OBJ_TREE_FORM(a3),d0
	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr RETURN_TREE_OBJ_PTR
	load.l d0-d2/a0-a3

	lea GWVA_WFORM_OBJ_TMP_POPUP_OBJ,a4
	move.l GWVA_APP_OBJ_TMP_ADD_TREE,mn_tree(a4)
	move.w GWVA_FORM_POP_OBJ_FORM_IDX(a3),mn_menu(a4)
	move.w GWVA_FORM_POP_OBJ_SELECTION(a3),mn_item(a4)
	clr.w mn_scroll(a4)
	clr.w mn_keystate(a4)

	move d2,d3
	move GWVA_FORM_POP_OBJ_SELECTION(a3),d2	; ancienne s‚lection
	save.l d0/d2/a0-a3
	menu_popup #GWVA_WFORM_OBJ_TMP_POPUP_OBJ,d1,d3,#GWVA_WFORM_OBJ_TMP_POPUP_OBJ
	move d0,d1
	load.l d0/d2/a0-a3

	cmp.w #1,d1
	bne.s .pas_de_retour_popup

	lea GWVA_WFORM_OBJ_TMP_POPUP_OBJ,a4

	cmp.w mn_item(a4),d2
	beq.s .meme_selection

	move.w mn_item(a4),GWVA_FORM_POP_OBJ_SELECTION(a3)

	save.l d0/d2/a0-a3
	move GWVA_FORM_POP_OBJ_TREE_FORM(a3),d0
	move.w mn_item(a4),d1
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a4
	load.l d0/d2/a0-a3

	save.l d0/d2/a0-a4
	move.w d0,d1
	move.w GWVA_WFORM_OBJ_FORM_IDX(a1),d0
	bsr RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR
	move.l a1,a5
	load.l d0/d2/a0-a4

	save.w d0
	clr.b d0
	COPY_STRING a4,a5
	load.w d0

	save.l d0/d2/a0-a3
	move.w #1,d1
	clr d2
	bsr GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART
	load.l d0/d2/a0-a3

	move.l GWVA_FORM_POP_OBJ_CHANGE_ROUTINE(a3),a4
	cmp.l #0,a4
	beq.s .pas_de_programme_associe

	move GWVA_FORM_POP_OBJ_SELECTION(a3),d1

	jsr (a4)

.pas_de_programme_associe:
.meme_selection:
.pas_de_retour_popup:

	bra GWVA_MAIN_EVENTS_LOOP

.radio_bouton:
	swap d0
	move GWVA_FORM_RADIO_OBJ_SELECTION(a3),d1
	move d0,GWVA_FORM_RADIO_OBJ_SELECTION(a3)

	move.l GWVA_FORM_RADIO_OBJ_CHANGE_ROUTINE(a3),a4
	cmp.l #0,a4
	beq.s .pas_de_prg_associe_radio

	jsr (a4)

.pas_de_prg_associe_radio:

	bra GWVA_MAIN_EVENTS_LOOP

	ifd FORM_OBJ_SLIDER
.slider_object:
	cmp.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_FIDX(a3),d0
	beq.s .s_o_deplacement_page
	cmp.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_SIDX(a3),d0
	beq.s .s_o_deplacement_souris

	move.l #1,d1
	cmp.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_P1_IDX(a3),d0
	beq .s_o_deplacement_p1

	neg.l d1
	cmp.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_M1_IDX(a3),d0
	beq .s_o_deplacement_m1

	move.l GWVA_FORM_SLIDER_OBJ_SIZE(a3),d1
	sub.l #1,d1		; taille page = taille slider - 1
	cmp.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_P1P_IDX(a3),d0
	beq .s_o_deplacement_p1_page

	neg.l d1
	cmp.w GWVA_FORM_SLIDER_OBJ_GRAPHIC_M1P_IDX(a3),d0
	beq .s_o_deplacement_m1_page

	bra GWVA_MAIN_EVENTS_LOOP

.s_o_deplacement_page:
; Deplacement … droite si la souris est … droite du fils 
	save.l a0-a3
	objc_offset GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_FORM_SLIDER_OBJ_GRAPHIC_SIDX(a3)
	load.l a0-a3
	move.w int_out+2,d2	; position x

	move.l GWVA_FORM_SLIDER_OBJ_SIZE(a3),d1
	sub.l #1,d1		; taille page = taille slider - 1

	cmp.w GWVA_APP_OBJ_EVNT_MULTI_MX,d2
	blt.s .s_o_deplacement_p1_page

	neg.l d1
	cmp.w GWVA_APP_OBJ_EVNT_MULTI_MX,d2
	bgt.s .s_o_deplacement_m1_page

	bra GWVA_MAIN_EVENTS_LOOP

.s_o_deplacement_souris:
	save.l a0-a3
	graf_slidebox GWVA_WFORM_OBJ_FORM_PTR(a1),GWVA_FORM_SLIDER_OBJ_GRAPHIC_FIDX(a3),GWVA_FORM_SLIDER_OBJ_GRAPHIC_SIDX(a3),GWVA_FORM_SLIDER_OBJ_ORIENT(a3)
	load.l a0-a3

	move.l GWVA_FORM_SLIDER_OBJ_LENGTH(a3),d2
	sub.l GWVA_FORM_SLIDER_OBJ_SIZE(a3),d2
	bpl.s .s_o_positif
	moveq #0,d2
.s_o_positif:
	ext.l d0
	moveq #0,d3
	mulu.l d0,d3:d2
	divu.l #1000,d3:d2

	move.l d2,d1
	sub.l GWVA_FORM_SLIDER_OBJ_POS(a3),d1

	bra .s_o_deplacement_slider

.s_o_deplacement_slider:
.s_o_deplacement_m1_page:
.s_o_deplacement_p1_page:
.s_o_deplacement_p1:
.s_o_deplacement_m1:

	move.l GWVA_FORM_SLIDER_OBJ_LENGTH(a3),d3
	sub.l GWVA_FORM_SLIDER_OBJ_SIZE(a3),d3
	bpl.s .s_o_positif1
	moveq #0,d3
.s_o_positif1:

	move.l GWVA_FORM_SLIDER_OBJ_POS(a3),d2

	add.l d1,d2
	bge.s .s_o_positif2
	moveq #0,d2
.s_o_positif2:
	cmp.l d2,d3
	bge.s .s_o_val_deplacement_ok
	move.l d3,d2
.s_o_val_deplacement_ok:

	move.l d2,d1
	sub.l GWVA_FORM_SLIDER_OBJ_POS(a3),d1	; d1.l = 0 : pas de d‚placement physique
	
	move.l d2,GWVA_FORM_SLIDER_OBJ_POS(a3)

	save.l d1/a0-a3
	move.l a3,a2
	bsr GWVA_SLIDER_OBJ_PRG_SET_SLIDER
	load.l d1/a0-a3

	add.l d7,d1

	tst.l d1
	beq.s .s_o_pas_deplacement_slider

	move.l GWVA_FORM_SLIDER_OBJ_CHANGE_ROUTINE(a3),a4
	cmp.l #0,a4
	beq.s .s_o_pas_de_routine

	move.l GWVA_FORM_SLIDER_OBJ_POS(a3),d0	; d1.l d‚placement en ‚l‚ment
	jsr (a4)

.s_o_pas_de_routine:

.s_o_pas_deplacement_slider:
	bra GWVA_MAIN_EVENTS_LOOP

	endc

		*-----------------*
.objet_clicke_non_trouve:
	move.l GWVA_WFORM_OBJ_FORM_PTR(a1),a2
	move d0,d3
	mulu #L_OBJECT,d3
	add.l d3,a2
	
.etat_inchange:
.pas_selectionable:
.object_disabled:
	tst.l GWVA_WFORM_OBJ_CLICK_ROUTINE(a1)
	beq.s .pas_de_routine_click
	; a0 = pointe sur la fenˆtre formulaire
	; a1 = pointe sur la structure formulaire
	; a2 = pointeur sur la structure de l'objet click‚
	; d0 = num‚ro de l'objet
	; d1.w = object flags
	; d2.w = object state
	movem.w ob_flags(a2),d1-d2
	jsr ([GWVA_WFORM_OBJ_CLICK_ROUTINE,a1])
	bra GWVA_MAIN_EVENTS_LOOP

.pas_de_routine_click:

.pas_d_objet:	; dans ce cas on renvoie le click tout simplement
.pas_fenetre_formulaire:

	endc		; ifd MDL_WIND_FORM

	; pour les types 1,2 la routine suivante est suffisante

.pas_a_nous_la_fenetre:

	endc 			; ifd MDL_WIND

.its_not_left_button:

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_EVNT_BUTTON(a0)
	beq GWVA_MAIN_EVENTS_LOOP

	move.w GWVA_APP_OBJ_TMP_WIND_HANDLE,d0
	movem.w GWVA_APP_OBJ_EVNT_MULTI_MX,d1/d2
	move.w GWVA_APP_OBJ_EVNT_MULTI_MB,d3
	move.w GWVA_APP_OBJ_EVNT_MULTI_MC,d4

	jsr ([GWVA_APP_OBJ_EVNT_BUTTON,a0])

	bra GWVA_MAIN_EVENTS_LOOP

*--------------------------------------------------------------------------*
GWVA_APP_OBJ_PRG_EVNT_MOUSE1:
	move #EVNT_MOUSE1,d7
	bsr GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_EVNT_MOUSE1(a0)
	beq GWVA_MAIN_EVENTS_LOOP

	movem.w GWVA_APP_OBJ_EVNT_MULTI_MX,d0/d1
	move.w GWVA_APP_OBJ_EVNT_MULTI_MB,d2
	move.w GWVA_APP_OBJ_EVNT_MULTI_MC,d3

	jsr ([GWVA_APP_OBJ_EVNT_MOUSE1,a0])

	bra GWVA_MAIN_EVENTS_LOOP
*--------------------------------------------------------------------------*
GWVA_APP_OBJ_PRG_EVNT_MOUSE2:
	move #EVNT_MOUSE2,d7
	bsr GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_EVNT_MOUSE2(a0)
	beq GWVA_MAIN_EVENTS_LOOP

	movem.w GWVA_APP_OBJ_EVNT_MULTI_MX,d0/d1
	move.w GWVA_APP_OBJ_EVNT_MULTI_MB,d2
	move.w GWVA_APP_OBJ_EVNT_MULTI_MC,d3

	jsr ([GWVA_APP_OBJ_EVNT_MOUSE2,a0])

	bra GWVA_MAIN_EVENTS_LOOP
*--------------------------------------------------------------------------*
GWVA_APP_OBJ_PRG_EVNT_MESSAGE:
	move #EVNT_MESAG,d7
	bsr GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT

	tst.w GWVA_APP_OBJ_MSG_BUF+2*2	; message ‚tendu ? (+ de 16 octets)
	beq.s .pas_lecture_buffer_message_etendu

; Il faut absolument lire le reste du message s'il est pr‚sent ; sinon
; cela c‚e un faux ‚vŠnement MESSAGE GEM.
	appl_read global+_AESapid,GWVA_APP_OBJ_MSG_BUF+2*2,#GWVA_APP_OBJ_MSG_EXT_BUF
.pas_lecture_buffer_message_etendu:

	move.w GWVA_APP_OBJ_MSG_BUF,d0	; num‚ro message

	ifd MDL_WIND

	bclr #14,d0			; bit 14 : identificateur des messages perso.

	cmp.w #WM_REDRAW,d0
	blt.s .not_a_wind_message
	cmp.w #WM_ALLICONIFY,d0
	bgt.s .not_a_wind_message

	move GWVA_APP_OBJ_MSG_BUF+3*2,d0	; handle de la fenˆtre concern‚e
	bsr GWVA_WIND_OBJ_PRG_RETURN_PTR_FROM_HANDLE
		; retour : a0 : structure de la fenˆtre
	tst d7
	bmi .suite_event_message	; pas 1 fenˆtre … nous

	move GWVA_APP_OBJ_MSG_BUF,d0	; quelle action ?
	bclr #14,d0			; message perso.
	move d0,d1
	sub #WM_REDRAW,d1
	lsl.w #2,d1
	lea GWVA_WIND_OBJ_PRG_WM_JUMP_TAB,a1
	jsr ([a1,d1.w])		; action avec a0=ptr d0=msg

	bra .suite_event_message

.not_a_wind_message:
	move.w GWVA_APP_OBJ_MSG_BUF,d0	; car on a bclr #14,d0

	endc

	ifd MDL_MENU
	cmp.w #MN_SELECTED,d0		; si on recoit l'‚vŠnement menu, c'est qu'il y a un menu en haut !
	bne.s .not_a_menu_message

	move GWVA_APP_OBJ_MSG_BUF+3*2,d0	; Top menu s‚lectionn‚

	save.w d0
	move.w GWVA_APP_OBJ_MSG_BUF+4*2,d0	; Menu Idx
	move.l GWVA_APP_OBJ_MSG_BUF+5*2,d1	; Tree ad.
	move.l ([GWVA_APP_OBJ_PTR.l],GWVA_APP_OBJ_MAIN_MENU_PTR),a0
	bsr GWVA_EXEC_MENU_ROUTINE_FROM_MENU_AD_AND_IDX
	load.w d0

	move.l GWVA_APP_OBJ_PTR,a0
	move.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0),a1
	menu_tnormal GWVA_MENU_STRUCT_PTR(a1),d0,#1	; menu en vid‚o normale
	bra.s .suite_event_message

.not_a_menu_message:
	endc

		*---------------------*

	lea GWVA_APP_OBJ_MSG_BUF,a0
	lea GWVA_APP_OBJ_MSG_EXT_BUF,a1

	cmp.w #AP_TERM,d0
	bne.s .pas_ap_term

	move.w GWVA_APP_OBJ_MSG_BUF+5*2,d1

.pas_ap_term:
	lea GWVA_APP_OBJ_EVNT_TABLE,a2
.scan:	tst (a2)
	bmi.s .other_message
	cmp.w (a2),d0
	beq.s .found
	lea 2+2(a2),a2
	bra.s .scan

.found:	move.w 2(a2),d2
	move.l ([GWVA_APP_OBJ_PTR.l],d2),a2

	cmp.w #AC_OPEN,d0
	beq .ac_open
	cmp.w #AC_CLOSE,d0
	beq .ac_close

	cmp.l #0,a2
	beq.s .suite_event_message

	jsr (a2)
	bra.s .suite_event_message

.other_message:
	move.l GWVA_APP_OBJ_PTR,a2
	tst.l GWVA_APP_OBJ_ALL_OTHER(a2)
	beq.s .suite_event_message

	move.l GWVA_APP_OBJ_ALL_OTHER(a2),a2
	jsr (a2)

.suite_event_message:
; On va tester s'il reste des messages a traiter dans la buffer.
; Pour sortir de l'evnt_multi, on utilise l'evenement timer
	evnt_multi #$10+$20,
&	#0,#0,#0,
&	#0,#0,#0,#0,#0,
&	#0,#0,#0,#0,#0,
&	#GWVA_APP_OBJ_MSG_BUF,
&	#1

	btst #EVNT_MESAG,d0
	bne GWVA_APP_OBJ_PRG_EVNT_MESSAGE	; il y a un message en attente -> on se rappelle

	bra GWVA_MAIN_EVENTS_LOOP


.ac_open:	move.w GWVA_APP_OBJ_ACC_NUMBER,d2
	cmp.w GWVA_APP_OBJ_MSG_BUF+4*2,d2
	bne .suite_event_message	; pas nous

	cmp.l #0,a2			; pas d'init VDI si pas de routine
	beq .suite_event_message

	save.l d0-d1/a0-a2
	bsr GWVA_APP_OBJ_PRG_ACC_OPEN_VSTATION
	load.l d0-d1/a0-a2
	tst d7
	bmi .suite_event_message	; pas b infinie si jamais 1 vstation se libŠre ?

	jsr (a2)

	bra .suite_event_message


.ac_close:	move.w GWVA_APP_OBJ_ACC_NUMBER,d2
	cmp.w GWVA_APP_OBJ_MSG_BUF+3*2,d2
	bne .suite_event_message	; pas nous

	cmp.l #0,a2
	beq.s .ferme_qd_meme

	jsr (a2)

.ferme_qd_meme:
	bsr GWVA_APP_OBJ_PRG_ACC_CLOSE_VSTATION

	bra .suite_event_message

*****************************************************************************
GWVA_APP_OBJ_PRG_CLEAR_EVNT_BIT:
	move.w GWVA_APP_OBJ_EVENT_BITS,d6
	bclr d7,d6
	move.w d6,GWVA_APP_OBJ_EVENT_BITS
	clr d0
	bset d7,d0
	rts

******************************************************************************

	ifd MDL_MENU
GWVA_MENU_OR_WIND_FORM
	else
		ifd MDL_WIND_FORM
GWVA_MENU_OR_WIND_FORM
		endc
	endc

	ifd GWVA_MENU_OR_WIND_FORM

GWVA_CONVERT_KC_IN_OBJECT_IDX:	; d0 : KC (scan code + ascii), a0 : adresse 1er objet dans la table de comparaison, d1=longeur de la structure
	move.b #%1000,d2	; masque pour les touches sp‚ciales
	tst.b d0
	bne.s .search_in_table
; Donc si l'ikbd.bas est non nul on se fout du shift car il est
; d‚j… compris dans le code : ex. ctrl+4=shift/ctrl+' <> ctrl+'
; Donc ‚vitez ctrl ou alt + touches qui varient avec le shift selon les pays autres que A-Z

	lsr.w #8,d0

	save.l d0-d1/a0
	pea -1
	pea -1
	pea -1
	appel xbios,$10,14
	move.l d0,a1
	load.l d0-d1/a0

	move.l (a1),a2	; table unshift‚e

	btst #0,GWVA_APP_OBJ_EVNT_MULTI_KS+1
	bne.s .shift
	btst #1,GWVA_APP_OBJ_EVNT_MULTI_KS+1
	beq.s .pas_shift
.shift:	
	move.l 4(a1),a2	; table shift‚e
.pas_shift:
	tst.b (a2,d0.w)
	beq.s .pas_ascii
	move.b (a2,d0.w),d0	; d0 = ascii du scan-code pour le pays en cours
	move.b #%1100,d2
	bra.s .search_in_table
.pas_ascii:	bset #7,d0
	move.b #%1111,d2
	bra.s .search_in_table

.search_in_table:
	tst.w (a0)		; d7 <>-1 OK
	bmi.s .finis
	cmp.b 3(a0),d0	; car dans 2(a0) : shortcut
	beq.s .compare_touches_speciales
.loop:	lea (a0,d1.w),a0
	bra.s .search_in_table
.compare_touches_speciales:
	move.b 2(a0),d3	; car dans 2(a0) : shortcut
	move.b GWVA_APP_OBJ_EVNT_MULTI_KS+1,d4
	move d3,d5
	and #%11,d5
	beq.s .pas_de_passe_droit
	move d4,d5
	and #%11,d5
	beq.s .pas_de_passe_droit
	and.b #%11111100,d2
.pas_de_passe_droit:
	and.b d2,d3
	and.b d2,d4
	cmp.b d3,d4
	bne.s .loop
	move.w (a0),d0	; car 0(a0) : c'est l'objet idx
	clr d7
	rts
.finis:	moveq #GWVA_ERROR_GENERIC,d7
	rts



GWVA_EXEC_MENU_ROUTINE_FROM_KC:
		; a0 : ptr sur une structure GWVA_MENU_STRUCT
		; d0.w : KC
		; d1.w : taille de la table de recherche (CONVERT_KC_IN_OBJECT_IDX)
	save.l d0-d1/a0
	lea GWVA_MENU_STRUCT_START_LIST(a0),a0
	bsr GWVA_CONVERT_KC_IN_OBJECT_IDX
	move.w d0,d2
	load.l d0-d1/a0
	tst d7
	bne.s .dans_sous_menu

	move d2,d0
	lea GWVA_MENU_STRUCT_START_LIST(a0),a0
	bra GWVA_EXEC_MENU_ROUTINE_FROM_MENU_IDX

.dans_sous_menu:
	move.l GWVA_MENU_STRUCT_LIST_ATTACH_PTR(a0),a1
	cmp.l #0,a1
	beq.s .pas_de_sous_menu

.recherche_sous_menu:
	move.l (a1)+,a0
	cmp.l #0,a0
	beq.s .pas_de_sous_menu

	save.l d0-d1/a0-a1
	lea GWVA_SUB_MENU_STRUCT_START_LIST(a0),a0
	bsr GWVA_CONVERT_KC_IN_OBJECT_IDX
	move.w d0,d2
	load.l d0-d1/a0-a1
	tst d7
	bne.s .recherche_sous_menu
	
	move d2,d0
	lea GWVA_SUB_MENU_STRUCT_START_LIST(a0),a0
	bra.s GWVA_EXEC_MENU_ROUTINE_FROM_MENU_IDX

.pas_de_sous_menu:
	moveq #GWVA_ERROR_GENERIC,d7
	rts


GWVA_EXEC_MENU_ROUTINE_FROM_MENU_AD_AND_IDX:
		; a0 : ptr sur une structure GWVA_MENU_STRUCT
		; d0.w : Index du menu
		; d1.l : Adresse du tree contenant le menu

	cmp.l (GWVA_MENU_STRUCT_PTR,a0),d1
	bne.s .in_a_sub_menu

	lea GWVA_MENU_STRUCT_START_LIST(a0),a0
	bra.s GWVA_EXEC_MENU_ROUTINE_FROM_MENU_IDX

.in_a_sub_menu:
	moveq #GWVA_ERROR_GENERIC,d7

	move.l GWVA_MENU_STRUCT_LIST_ATTACH_PTR(a0),a1
	cmp.l #0,a1
	beq.s .pas_de_sous_menu

.recherche_sous_menu:
	move.l (a1)+,a0
	cmp.l #0,a0
	beq.s .pas_de_sous_menu

	save.l d0-d1/a0-a1
	move.w GWVA_SUB_MENU_TREE(a0),d0
	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr RETURN_TREE_OBJ_PTR
	load.l d0-d1/a0-a1

	cmp.l GWVA_APP_OBJ_TMP_ADD_TREE,d1
	bne.s .recherche_sous_menu

	lea GWVA_SUB_MENU_STRUCT_START_LIST(a0),a0
	save.l d0-d1/a1
	bsr.s GWVA_EXEC_MENU_ROUTINE_FROM_MENU_IDX
	load.l d0-d1/a1
	tst d7
	bne.s .recherche_sous_menu

.pas_de_sous_menu:
	rts

GWVA_EXEC_MENU_ROUTINE_FROM_MENU_IDX:
		; a0 : ptr sur une structure _STRUCT_START_LIST
		; d0.w : Index du menu
	tst.w (a0)
	bmi.s .no_routine_found
	cmp.w (a0),d0
	beq.s .found
	lea 2+1+1+4(a0),a0
	bra.s GWVA_EXEC_MENU_ROUTINE_FROM_MENU_IDX
.found:	tst.l ([a0,2+1+1])
	beq.s .no_routine_found
	move.l a0,a1
	move GWVA_APP_OBJ_MSG_BUF+3*2,d0	; Top menu s‚lectionn‚
	move.w GWVA_APP_OBJ_MSG_BUF+4*2,d1	; Menu-item Idx
	move.w GWVA_APP_OBJ_MSG_BUF+7*2,d2	; Menu Idx
	move.l GWVA_APP_OBJ_MSG_BUF+5*2,a0	; Tree ad.
	jsr ([a1,2+1+1])		; 
	clr d7
	rts
.no_routine_found:
	moveq #GWVA_ERROR_GENERIC,d7
	rts

	endc

*--------------------------------------------------------------------------*

GWVA_INFINITE_LOOP:
	evnt_mesag #GWVA_APP_OBJ_MSG_BUF
	bra.s GWVA_INFINITE_LOOP

GWVA_APP_OBJ_PRG_WAIT_EVENTS:	; d0.l = timer en 1/1000 Šme de sec
; attends le temps apparti, si d0=1 : pause pour donner la main au gem le minimum vital

	evnt_timer d0

	rts

*--------------------------------------------------------------------------*

	endc		; MDL_EVENT

*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*---------------------     CODE DE SORTIE VISUAL    -----------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*


VISUAL40_END:
	SYNCHRO_GEM

	ifd MDL_GEM

	ifd MDL_WIND
	bsr GWVA_WIND_OBJ_PRG_DELETE_ALL_WIND
	endc

	tst.l global+_AESrscfile	; (?)
	ble.s .no_rsc_loaded

	ifd MDL_MENU
	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0)
	beq.s .pas_de_menu
	move.l GWVA_APP_OBJ_MAIN_MENU_PTR(a0),a1
	move.l GWVA_MENU_STRUCT_PTR(a1),a0
	bsr GWVA_HIDE_MENU
.pas_de_menu:
	endc

	move.l GWVA_APP_OBJ_PTR,a0
	btst #GWVA_APP_BIT_BACKGROUND,GWVA_APP_OBJ_FLAGS(a0)
	beq.s .pas_de_background
	clr.l int_in+4
	wind_set #0,#WF_NEWDESK
.pas_de_background:

	move.l GWVA_APP_OBJ_PTR,a0
	btst #GWVA_APP_BIT_RSC_IN_MEM,GWVA_APP_OBJ_FLAGS(a0)
	bne.s .rsc_in_mem_to_free
	rsrc_free
	bra.s .rsc_load_free
.rsc_in_mem_to_free:
	ifd MDL_RELOCATE_RSC
	tst.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN
	beq.s .pas_buffer_icones_couleurs
	MFREE GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN
	clr.l GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN
.pas_buffer_icones_couleurs:
	endc
.rsc_load_free:

.no_rsc_loaded:
GWVA_APP_RSC_LOAD_FAILED:

	graf_mouse	#0		; arrow please
	v_clsvwk			; then closing the virtual workstation

	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_RESET_DESK_PALETTE
	endc

GWVA_BRANCH_IF_OPEN_WORKSTATION_FAILED:
	appl_exit

GWVA_BRANCH_IF_APPL_INIT_FAILED:

	endc			; ifd MDL_GEM

	move.l GWVA_APP_OBJ_PTR,a0
	tst.l GWVA_APP_OBJ_TSR_SIZE(a0)
	bne.s .tsr

	move.w GWVA_APP_OBJ_RETURN_CODE,-(sp)
	appel dos,$4c,4		; Pterm

.tsr:	move.w GWVA_APP_OBJ_RETURN_CODE,-(sp)
	move.l GWVA_APP_OBJ_TSR_SIZE(a0),-(sp)
	appel dos,$31,8	; laisse le programme r‚sident

*--------------------------------------------------------------------------*

	ifd MDL_GEM

GWVA_APP_OBJ_PRG_ACC_OPEN_VSTATION:
	tst GWVA_APP_OBJ_ACC_STATE
	bne.s .deja_ouverte

	bsr.s GWVA_APP_OBJ_PRG_OPEN_VSTATION
	tst d7
	bmi.s .probleme
	move #1,GWVA_APP_OBJ_ACC_STATE

.probleme:
.deja_ouverte:
	rts

GWVA_APP_OBJ_PRG_ACC_CLOSE_VSTATION:
	tst GWVA_APP_OBJ_ACC_STATE
	beq.s .deja_fermee

	bsr GWVA_APP_OBJ_PRG_CLOSE_VSTATION
	clr GWVA_APP_OBJ_ACC_STATE

.deja_fermee:rts

GWVA_APP_OBJ_PRG_OPEN_VSTATION:
	lea intin,a0		; start by opening a virtual workstation
	moveq #10-1,d0
.fill:	move.w #1,(a0)+		; most params are 1
	dbf d0,.fill
	move.w #2,(a0)+		; use RC system

	appel xbios,$4,2
	add.w #2,d0
	move.w d0,intin		; Device identification number (dixit COMPENDIUM p 7.61)

	v_opnvwk			; open it
	tst.w current_handle
	beq .open_workstation_failed

	lea intout,a0
	lea GWVA_APP_OBJ_VDI_WORKSTATION,a1
	move.w #45-1,d0
.recopy_vdi_parameters1:
	move.w (a0)+,(a1)+
	dbf d0,.recopy_vdi_parameters1

	lea ptsout,a0
	move.w #12-1,d0
.recopy_vdi_parameters2:
	move.w (a0)+,(a1)+
	dbf d0,.recopy_vdi_parameters2

	vq_extnd #1

	lea intout,a0
	lea GWVA_APP_OBJ_VDI_WORKSTATION_EXTD,a1
	move.w #45-1,d0
.recopy_vdi_parameters3:
	move.w (a0)+,(a1)+
	dbf d0,.recopy_vdi_parameters3

	lea ptsout,a0
	move.w #12-1,d0
.recopy_vdi_parameters4:
	move.w (a0)+,(a1)+
	dbf d0,.recopy_vdi_parameters4

	vqt_attributes
	movem.w ptsout,d0-d3	; -> largeur/hauteur caractŠre et cellule
	movem.w d0-d3,GWVA_APP_OBJ_TEXT_WIDTH

	graf_mouse #0		; arrow please
	
	wind_get #0,#WF_WORKXYWH	; taille du bureau ?
	move.l int_out+2,GWVA_APP_OBJ_DESKTOP_X
	move.l int_out+6,GWVA_APP_OBJ_DESKTOP_W

	ifd MDL_WIND_BITMAP

	moveq #1,d0
	move GWVA_APP_OBJ_VDI_WORKSTATION_EXTD+4*2,d1
	lsl.w d1,d0
	cmp.w GWVA_APP_OBJ_VDI_WORKSTATION+13*2,d0
	bne.s .pas_de_palette

	pea GWVA_APP_OBJ_SAVE_PALETTE
	move GWVA_APP_OBJ_VDI_WORKSTATION+13*2,-(sp)
	clr -(sp)
	appel xbios,$5e,10
.pas_de_palette:

	endc			; ifd MDL_WIND_BITMAP

	clr d7
	rts

.open_workstation_failed:
	moveq #GWVA_ERROR_GENERIC,d7
	rts

GWVA_APP_OBJ_PRG_CLOSE_VSTATION:	; que pour les accessoires
	ifd MDL_WIND
	bsr GWVA_WIND_OBJ_PRG_DELETE_ALL_WIND
	endc			; ifd MDL_WIND

	graf_mouse	#0		; arrow please
	v_clsvwk			; then closing the virtual workstation

	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_RESET_DESK_PALETTE
	endc			; ifd MDL_WIND_BITMAP

	rts

GWVA_OPEN_WORKSTATION_FAILED:
	lea GWVA_ALERT_V_OPEN_FAILED,a0
	move #1,d0
	bsr ALERT_BOX
	bra GWVA_BRANCH_IF_OPEN_WORKSTATION_FAILED

GWVA_APPL_INIT_FAILED:
	lea GWVA_ALERT_AP_INIT_FAILED,a0
	move #1,d0
	bsr ALERT_BOX
	bra GWVA_BRANCH_IF_APPL_INIT_FAILED

	endc			; ifd MDL_GEM

*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*-------------------        FIN DU CODE VISUAL      -----------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*
*--------------------------------------------------------------------------*

	include library\library.s

	ifd MDL_RELOCATE_RSC
	include library\relocate.s
	endc

	ifd LIB_XHDI
	include library\xhdicall.s
	endc

	ifd LIB_RECURSIVE_FILE_SEARCH
	include library\filesrch.s
	endc

	ifd MDL_WIND

	ifd MDL_WIND_FORM
	include library\mltform.s
	endc

	include windows.s
	endc

	ifd MDL_GEM
	include aeslib.s
	include vdilib.s
 TEXT
	endc

*--------------------------------------------------------------------------*

	DATA

GWVA_APP_OBJ_EVNT_TABLE:
	dc.w AC_OPEN,GWVA_APP_OBJ_AC_OPEN
	dc.w AC_CLOSE,GWVA_APP_OBJ_AC_CLOSE
	dc.w AP_TERM,GWVA_APP_OBJ_AP_TERM
	dc.w AP_TFAIL,GWVA_APP_OBJ_AP_TFAIL
	dc.w SHUT_COMPLETED,GWVA_APP_OBJ_SHUT_COMPLETED
	dc.w RESCH_COMPLETED,GWVA_APP_OBJ_RESCH_COMPLETED
	dc.w AP_DRAGDROP,GWVA_APP_OBJ_AP_DRAG_DROP
	dc.w SH_WDRAW,GWVA_APP_OBJ_SH_WDRAW
	dc.w CH_EXIT,GWVA_APP_OBJ_CH_EXIT
	dc.w -1

GWVA_APP_OBJ_RETURN_CODE: dc.w -1

GWVA_ALERT_NO_RSC:	  dc.b '[3][ Ressource File | not found ][ Suspend ]',0
GWVA_ALERT_AP_INIT_FAILED:dc.b '[3][ AP Init failed | cannot run ][ Strange ]',0
GWVA_ALERT_V_OPEN_FAILED: dc.b '[3][ Could no open | virtual Workstation ][ Cancel ]',0

GWVA_APP_OBJ_COPYRIGHT_MESSAGE:	dc.b 'Written in Visual Assembler 4.0 ½ Gen & Wax 1996',0
GWVA_APP_OBJ_VISUAL_VERSION:	dc.b '4035',0
GWVA_APP_OBJ_REGISTER_STRING:	dc.b 'RN : UNREGISTERED version for FREEWARE programs',0
	; The label GWVA_APP_OBJ_REGISTER_MESSAGE must point on to a
	; string 'RN : ' followed by your full registration string
	; if you intend to earn money with your program (SHAREWARE or SOLD)

	; Le label GWVA_APP_OBJ_REGISTER_MESSAGE doit pointer sur une
	; chaine 'RN : ' suivie de votre num‚ro d'enregistrement complet
	; si vous diffusez un produit qui doit vous rapporter de l'argent
	; (SHAREWARE ou VENDU)
 even

	ifd MDL_WIND

GWVA_WTEXT_OBJ_SHORTCUTS:
	dc.w $48*256
	dc.w WA_UPLINE
	dc.w $50*256
	dc.w WA_DNLINE
	dc.w $4B*256
	dc.w WA_LFLINE
	dc.w $4D*256
	dc.w WA_RTLINE
	dc.w $48*256+'8'
	dc.w WA_UPPAGE
	dc.w $50*256+'2'
	dc.w WA_DNPAGE
	dc.w $4B*256+'4'
	dc.w WA_LFPAGE
	dc.w $4D*256+'6'
	dc.w WA_RTPAGE
	dc.l -1

GWVA_WIND_OBJ_PRG_WM_JUMP_TAB:
	dc.l GWVA_WIND_OBJ_PRG_WM_REDRAW
	dc.l GWVA_WIND_OBJ_PRG_WM_TOPPED
	dc.l GWVA_WIND_OBJ_PRG_WM_CLOSED
	dc.l GWVA_WIND_OBJ_PRG_WM_FULLED
	dc.l GWVA_WIND_OBJ_PRG_WM_ARROWED
	dc.l GWVA_WIND_OBJ_PRG_WM_HSLID
	dc.l GWVA_WIND_OBJ_PRG_WM_VSLID
	dc.l GWVA_WIND_OBJ_PRG_WM_SIZED
	dc.l GWVA_WIND_OBJ_PRG_WM_MOVED
	dc.l GWVA_WIND_OBJ_PRG_WM_NEWTOP		; 0
	dc.l GWVA_WIND_OBJ_PRG_WM_UNTOPPED
	dc.l GWVA_WIND_OBJ_PRG_WM_ONTOP
	dc.l 0
	dc.l GWVA_WIND_OBJ_PRG_WM_BOTTOM
	dc.l GWVA_WIND_OBJ_PRG_WM_ICONIFY
	dc.l GWVA_WIND_OBJ_PRG_WM_UNICONIFY
	dc.l GWVA_WIND_OBJ_PRG_WM_ALLICONIFY
	dc.l GWVA_WIND_OBJ_PRG_WM_TOOLBAR

	endc

*--------------------------------------------------------------------------*

	BSS
			ds.b GWVA_APP_OBJ_STACK_SIZE
GWVA_APP_OBJ_STACK:		ds.l 1
GWVA_APP_OBJ_PTR:		ds.l 1
GWVA_APP_OBJ_IS_ACC_PRG:	ds.w 1	; 0 : acc, 1 : app
GWVA_APP_OBJ_BASE_PAGE:		ds.l 1
GWVA_APP_OBJ_CMD_LINE_PTR:	ds.l 1
GWVA_APP_OBJ_CMD_LINE_SIZE:	ds.w 1
GWVA_APP_OBJ_DTA:		ds.b 44
GWVA_APP_OBJ_STARTED_PATH:	ds.b GWVA_MAX_PATH_LENGTH

GWVA_APP_OBJ_SEARCH_IN_OUT:		ds.l 2	; le paramŠtre pour la recherche COOKIE,XBRA
GWVA_APP_OBJ_COOKIE_COPRO:		ds.w 1	; 0=aucun 1=68881 2=68882
GWVA_APP_OBJ_COOKIE_TOS_VERSION:		ds.w 1	: ex. : $0404
GWVA_APP_OBJ_COOKIE_MINT:		ds.w 1	; 0 ou la version
GWVA_APP_OBJ_COOKIE_SELECTRIX_PTR:		ds.l 1	; Selctrix base adress (0 si pas s‚lectrix)
GWVA_APP_OBJ_COOKIE_SELECTRIX_COMM_WORD:	ds.l 1	; ad. du word communication
GWVA_APP_OBJ_COOKIE_SELECTRIX_OUT_COUNT:	ds.l 1	; ad. du compteur sortie
GWVA_APP_OBJ_COOKIE_SELECTRIX_OUT_PTR:	ds.l 1	; ad. du pointeur sortie

GWVA_OLD_SUPERVISOR_STACK:	ds.l 1	; pour macro SUPER

	ifd MDL_GEM

GWVA_APP_OBJ_ACC_NUMBER:	ds.w 1

	ifd MDL_RELOCATE_RSC
GWVA_APP_OBJ_ADD_MALLOC_RSC_ICN:	ds.l 2
	endc

GWVA_APP_OBJ_TEXT_WIDTH:	ds.w 1
GWVA_APP_OBJ_TEXT_HEIGTH:	ds.w 1
GWVA_APP_OBJ_CELL_WIDTH:	ds.w 1
GWVA_APP_OBJ_CELL_HEIGHT:	ds.w 1

GWVA_APP_OBJ_DESKTOP_X:		ds.w 1
GWVA_APP_OBJ_DESKTOP_Y:		ds.w 1
GWVA_APP_OBJ_DESKTOP_W:		ds.w 1
GWVA_APP_OBJ_DESKTOP_H:		ds.w 1

GWVA_APP_OBJ_TMP_ADD_TREE:	ds.l 1	; sert … plein de routine

GWVA_APP_OBJ_VDI_WORKSTATION:	ds.w 57
GWVA_APP_OBJ_VDI_WORKSTATION_EXTD:	ds.w 57

	ifd MDL_EVENTS

	ifd MDL_MENU

GWVA_APP_OBJ_TMP_MENU_OBJ:	ds.b LONG_STRUC_MENU

	endc

GWVA_APP_OBJ_TMP_WIND_HANDLE:	ds.w 1	; sert si event_button
GWVA_APP_OBJ_ACC_STATE:		ds.w 1	; 0=closed 1=opened

GWVA_APP_OBJ_EVENT_BITS:	ds.w 1
GWVA_APP_OBJ_EVNT_MULTI_MX:	ds.w 1	; position souris
GWVA_APP_OBJ_EVNT_MULTI_MY:	ds.w 1
GWVA_APP_OBJ_EVNT_MULTI_MB:	ds.w 1	; ‚tat des boutons souris
GWVA_APP_OBJ_EVNT_MULTI_KS:	ds.w 1	; ‚tat des touches sp‚ciales
GWVA_APP_OBJ_EVNT_MULTI_KC:	ds.w 1	; touche
GWVA_APP_OBJ_EVNT_MULTI_MC:	ds.w 1	; nbre de clik souris
GWVA_APP_OBJ_MSG_BUF:		ds.w 8	; pour event-multi
GWVA_APP_OBJ_MSG_EXT_BUF:	ds.b 256	; pour appl_read - appl_write

GWVA_APP_MFDB_SRC:		ds.l 1	; buffers pour vro_cpyfrm & vrt_ & vr_trnfm
			ds.w 8
GWVA_APP_MFDB_DEST:		ds.l 1
			ds.w 8

	ifd MDL_WIND

GWVA_APP_OBJ_WIND_LIST:		ds.l GWVA_APP_OBJ_MAX_NUMBER_WIND+1

GWVA_WIND_OBJ_REDRAW_BOX:	ds.w 4
GWVA_WIND_OBJ_REDRAW_CLIP:	ds.w 4

GWVA_WIND_OBJ_FORM_NUM_OBJ_REDRAW:	ds.w 1	; pour le redraw partiel
GWVA_WIND_OBJ_FORM_DEPTH_OBJ_REDRAW:ds.w 1
GWVA_WIND_OBJ_FORM_WHAT_OBJ_REDRAW:	ds.w 1	; -1=all wind, 0=contents, 1=toolbar, 2=menu

	ifd MDL_WIND_FORM

GWVA_WFORM_OBJ_TMP_POPUP_OBJ:	ds.b LONG_STRUC_MENU

	endc			; ifd MDL_WIND_FORM

	ifd MDL_WIND_TEXT

GWVA_WIND_OBJ_NEW_TEXT_VAR:	ds.w 2
GWVA_WIND_OBJ_REDRAW_INTERSEC:	ds.w 4
GWVA_WIND_OBJ_REDRAW_BLANK:	ds.w 4
GWVA_WTEXT_OBJ_DUMMY:		ds.l 1
GWVA_WTEXT_OBJ_INTERMEDIAIRE:	ds.b 256+1+1

	endc			; ifd MDL_WIND_TEXT

	ifd MDL_WIND_BITMAP

GWVA_APP_OBJ_SAVE_PALETTE:	ds.l 256

	endc			; ifd MDL_WIND_BITMAP

	endc			; ifd MDL_WIND

	endc			; ifd MDL_EVENTS

	endc			; ifd MDL_GEM

	TEXT

*--------------------------------------------------------------------------*
