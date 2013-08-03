*************************
*	           *
* AES Macro definitions *
*	           *
*************************

	SECTION	text

;--------------------------------------------------------------
; call the aes to perform the requested function
;--------------------------------------------------------------


call_aes	MACRO
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#aespb,d1
	move.w	#$c8,d0
	trap	#GEM
	move.w	d0,aesReturn
	movem.l	(sp)+,d0-d7/a0-a6
	ENDM


******************
* AES appl calls *
******************

;--------------------------------------------------------------
; appl_init()
;--------------------------------------------------------------
	
appl_init	MACRO
	move.l	#aes_10,aespb
	call_aes
	ENDM
	
;--------------------------------------------------------------
; appl_read()
;--------------------------------------------------------------
	
appl_read	MACRO
	move.l	#aes_11,aespb
	move.w	ap_id,intin
	move.w	\1,intin+2
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; appl_write()
;--------------------------------------------------------------

appl_write	MACRO
	move.l	#aes_12,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; appl_find()
;--------------------------------------------------------------

appl_find	MACRO
	move.l	#aes_13,aespb
	move.l	\1,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; appl_tplay()
;--------------------------------------------------------------

appl_tplay	MACRO
	move.l	#aes_14,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM

;--------------------------------------------------------------
; appl_trecord()
;--------------------------------------------------------------

appl_trecord	MACRO
	move.l	#aes_15,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM

;--------------------------------------------------------------
; appl_yield()
;--------------------------------------------------------------

appl_yield	MACRO
	move.l	#aes_17,aespb
	call_aes
	ENDM

;--------------------------------------------------------------
; appl_search()
;--------------------------------------------------------------
	
appl_search	MACRO
	move.l	#aes_18,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; appl_getinfo()
;--------------------------------------------------------------

appl_getinfo	MACRO
	move.l	#aes_130,aespb
	move.w	\1,intin
	call_aes
	ENDM	
	
;--------------------------------------------------------------
; appl_exit()
;--------------------------------------------------------------

appl_exit	MACRO
	move.l	#aes_19,aespb
	call_aes
	ENDM

*******************
* AES event calls *
*******************
	
;--------------------------------------------------------------
; evnt_keybd()
;--------------------------------------------------------------

evnt_keybd	MACRO
	move.l	#aes_20,aespb
	call_aes
	ENDM
	
;--------------------------------------------------------------
; evnt_button()
;--------------------------------------------------------------

evnt_button	MACRO
	move.l	#aes_21,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	call_aes
	ENDM
	
;--------------------------------------------------------------
; evnt_mouse()
;--------------------------------------------------------------

evnt_mouse	MACRO
	move.l	#aes_22,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	call_aes
	ENDM

;--------------------------------------------------------------
; evnt_mesag()
;--------------------------------------------------------------
	
evnt_mesag	MACRO
	move.l	#aes_23,aespb
	move.l	\1,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; evnt_timer()
;--------------------------------------------------------------

evnt_timer	MACRO
	move.l	#aes_24,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	call_aes
	ENDM
	
;--------------------------------------------------------------
; evnt_multi()
;--------------------------------------------------------------

evnt_multi	MACRO
	move.l	#aes_25,aespb
	call_aes
	ENDM
	
;--------------------------------------------------------------
; evnt_dclick()
;--------------------------------------------------------------

evnt_dclick	MACRO
	move.l	#aes_26,aespb
	move.w	\1,intin
	mmove.w	\2,intin+2
	call_aes
	ENDM


******************
* AES menu calls *
******************	
	
;--------------------------------------------------------------
; menu_bar()
;--------------------------------------------------------------

menu_bar	MACRO
	move.l	#aes_30,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_icheck()
;--------------------------------------------------------------

menu_icheck	MACRO
	move.l	#aes_31,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_ienable()
;--------------------------------------------------------------

menu_ienable	MACRO
	move.l	#aes_32,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_tnormal()
;--------------------------------------------------------------

menu_tnormal	MACRO
	move.l	#aes_33,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_text()
;--------------------------------------------------------------

menu_text	MACRO
	move.l	#aes_34,aespb
	move.w	\1,intin
	move.l	\2,addrin
	move.l	\3,addrin+4
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_register()
;--------------------------------------------------------------

menu_register	MACRO
	move.l	#aes_35,aespb
	move.w	ap_id,intin
	move.l	\1,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_popup()
;--------------------------------------------------------------
	
menu_popup	MACRO
	move.l	#aes_36,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	move.l	\4,addrin+4
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_attach()
;--------------------------------------------------------------

menu_attach	MACRO
	move.l	#aes_37,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	move.l	\4,addrin+4
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_istart()
;--------------------------------------------------------------

menu_istart	MACRO
	move.l	#aes_38,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.l	\4,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; menu_settings()
;--------------------------------------------------------------

menu_settings	MACRO
	move.l	#aes_39,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
********************
* AES object calls *
********************

;--------------------------------------------------------------
; objc_add()
;--------------------------------------------------------------

objc_add	MACRO
	move.l	#aes_40,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_delete()
;--------------------------------------------------------------

objc_delete	MACRO
	move.l	#aes_41,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_draw()
;--------------------------------------------------------------

objc_draw	MACRO
	move.l	#aes_42,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	move.l	\7,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_find()
;--------------------------------------------------------------

objc_find	MACRO
	move.l	#aes_43,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.l	\5,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_offset()
;--------------------------------------------------------------

objc_offset	MACRO
	move.l	#aes_44,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_order()
;--------------------------------------------------------------

objc_order	MACRO
	move.l	#aes_45,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_edit()
;--------------------------------------------------------------

objc_edit	MACRO
	move.l	#aes_46,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.l	\5,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; objc_change()
;--------------------------------------------------------------

objc_change	MACRO
	move.l	#aes_47,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	move.w	\7,intin+12
	move.w	\8,intin+14
	move.l	\9,addrin
	call_aes
	ENDM

;--------------------------------------------------------------
; objc_sysvar()
;--------------------------------------------------------------

objc_sysvar	MACRO
	move.l	#aes_48,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	call_aes
	ENDM
	
******************
* AES form calls *
******************

;--------------------------------------------------------------
; form_do()
;--------------------------------------------------------------

form_do	MACRO
	move.l	#aes_50,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; form_dial()
;--------------------------------------------------------------
	
form_dial	MACRO
	move.l	#aes_51,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	move.w	\7,intin+12
	move.w	\8,intin+14
	move.w	\9,intin+16
	call_aes
	ENDM
	
;--------------------------------------------------------------
; form_alert()
;--------------------------------------------------------------
	
form_alert	MACRO
	move.l	#aes_52,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; form_error()
;--------------------------------------------------------------

form_error	MACRO
	move.l	#aes_53,aespb
	move.w	\1,intin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; form_center()
;--------------------------------------------------------------

form_center	MACRO
	move.l	#aes_54,aespb
	move.l	\1,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; form_keybd()
;--------------------------------------------------------------

form_keybd	MACRO
	move.l	#aes_55,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.l	\4,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; form_butn()
;--------------------------------------------------------------

form_butn	MACRO
	move.l	#aes_56,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
******************
* AES graf calls *
******************

;--------------------------------------------------------------
; graf_rubberbox()
;--------------------------------------------------------------

graf_rubberbox	MACRO
	move.l	#aes_70,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_dragbox()
;--------------------------------------------------------------

graf_dragbox	MACRO
	move.l	#aes_71,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	move.w	\7,intin+12
	move.w	\8,intin+14
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_movebox()
;--------------------------------------------------------------

graf_movebox	MACRO
	move.l	#aes_72,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_growbox()
;--------------------------------------------------------------

graf_growbox	MACRO
	move.l	#aes_73,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	move.w	\7,intin+12
	move.w	\8,intin+14
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_shrinkbox()
;--------------------------------------------------------------

graf_shrinkbox	MACRO
	move.l	#aes_74,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	move.w	\7,intin+12
	move.w	\8,intin+14
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_watchbox()
;--------------------------------------------------------------

graf_watchbox	MACRO
	move.l	#aes_75,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.l	\5,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_slidebox()
;--------------------------------------------------------------

graf_slidebox	MACRO
	move.l	#aes_76,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.l	\4,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_handle()
;--------------------------------------------------------------

graf_handle	MACRO
	move.l	#aes_77,aespb
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_mouse()
;--------------------------------------------------------------

graf_mouse	MACRO
	move.l	#aes_78,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; graf_mkstate()
;--------------------------------------------------------------

graf_mkstate	MACRO
	move.l	#aes_79,aespb
	call_aes
	ENDM
	
*******************
* AES scrap calls *
*******************

;--------------------------------------------------------------
; scrp_read()
;--------------------------------------------------------------

scrp_read	MACRO
	move.l	#aes_80,aespb
	move.l	\1,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; scrp_write()
;--------------------------------------------------------------

scrp_write	MACRO
	move.l	#aes_81,aespb
	move.l	\1,addrin
	call_aes
	ENDM

******************
* AES fsel calls *
******************
	
;--------------------------------------------------------------
; fsel_input()
;--------------------------------------------------------------

fsel_input	MACRO
	move.l	#aes_90,aespb
	move.l	\1,addrin
	move.l	\2,addrin+4
	call_aes
	move.w	aesReturn,d0
	ENDM
	
;--------------------------------------------------------------
; fsel_exinput()
;--------------------------------------------------------------
	
fsel_exinput	MACRO
	move.l	#aes_91,aespb
	move.l	\1,addrin
	move.l	\2,addrin+4
	move.l	\3,addrin+8
	call_aes
	move.w	aesReturn,d0
	ENDM	
	
******************
* AES wind calls *
******************

;--------------------------------------------------------------
; wind_create()
;--------------------------------------------------------------

wind_create	MACRO
	move.l	#aes_100,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_open()
;--------------------------------------------------------------

wind_open	MACRO
	move.l	#aes_101,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_close()
;--------------------------------------------------------------

wind_close	MACRO
	move.l	#aes_102,aespb
	move.w	\1,intin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_delete()
;--------------------------------------------------------------

wind_delete	MACRO
	move.l	#aes_103,aespb
	move.w	\1,intin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_get()
;--------------------------------------------------------------

wind_get	MACRO
	move.l	#aes_104,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_set()
;--------------------------------------------------------------

wind_set	MACRO
	move.l	#aes_105,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_find()
;--------------------------------------------------------------

wind_find	MACRO
	move.l	#aes_106,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_update()
;--------------------------------------------------------------
	
wind_update	MACRO
	move.l	#aes_107,aespb
	move.w	\1,intin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; wind_calc()
;--------------------------------------------------------------

wind_calc	MACRO
	move.l	#aes_108,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	move.w	\5,intin+8
	move.w	\6,intin+10
	call_aes
	ENDM

;--------------------------------------------------------------
; wind_new()
;--------------------------------------------------------------

wind_new	MACRO
	move.l	#aes_109,aespb
	call_aes
	ENDM	
	
**********************
* AES resource calls *
**********************
	
;--------------------------------------------------------------
; rsrc_load()
;--------------------------------------------------------------

rsrc_load	MACRO
	move.l	#aes_110,aespb
	move.l	\1,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; rsrc_free()
;--------------------------------------------------------------
	
rsrc_free	MACRO
	move.l	#aes_111,aespb
	call_aes
	ENDM
	
;--------------------------------------------------------------
; rsrc_gaddr()
;--------------------------------------------------------------
	
rsrc_gaddr	MACRO
	move.l	#aes_112,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	call_aes
	ENDM
	
;--------------------------------------------------------------
; rsrc_saddr()
;--------------------------------------------------------------
	
rsrc_saddr	MACRO
	move.l	#aes_113,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.l	\3,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; rsrc_obfix()
;--------------------------------------------------------------
	
rsrc_obfix	MACRO
	move.l	#aes_114,aespb
	move.w	\1,intin
	move.l	\2,addrin
	call_aes
	ENDM
	
;--------------------------------------------------------------
; rsrc_rcfix()
;--------------------------------------------------------------
	
rsrc_rcfix	MACRO
	move.l	#aes_115,aespb
	move.l	\1,addrin
	call_aes
	ENDM

*******************
* AES shell calls *
*******************
	
;--------------------------------------------------------------
; shel_read()
;--------------------------------------------------------------
	
shel_read	MACRO
	move.l	#aes_120,aespb
	move.l	\1,addrin
	move.l	\2,addrin+4
	call_aes
	ENDM

;--------------------------------------------------------------
; shel_write()
;--------------------------------------------------------------

shel_write	MACRO
	move.l	#aes_121,aespb
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.l	\4,addrin
	move.l	\5,addrin+4
	call_aes
	ENDM		
			
		
	SECTION	bss

contrl	ds.w	11
intin	ds.w	128
intout	ds.w	128
global	ds.w	15
addrin	ds.w	128
addrout	ds.w	128

	SECTION	data

aespb	dc.l	contrl,global,intin,intout,addrin,addrout

aes_10	dc.w	10,0,1,0,0
aes_11	dc.w	11,2,1,1,0
aes_12	dc.w	12,2,1,1,0
aes_13	dc.w	13,0,1,1,0
aes_14	dc.w	14,2,1,1,0
aes_15	dc.w	15,1,1,1,0
aes_17	dc.w	17,0,1,0,0
aes_18	dc.w	18,1,3,1,0
aes_19	dc.w	19,0,1,0,0
aes_20	dc.w	20,0,1,0,0
aes_21	dc.w	21,3,5,0,0
aes_22	dc.w	22,5,5,0,0
aes_23	dc.w	23,0,1,1,0
aes_24	dc.w	24,2,1,0,0
aes_25	dc.w	25,16,7,1,0
aes_26	dc.w	26,2,1,0,0
aes_30	dc.w	30,1,1,1,0
aes_31	dc.w	31,2,1,1,0
aes_32	dc.w	32,2,1,1,0
aes_33	dc.w	33,2,1,1,0
aes_34	dc.w	34,1,1,2,0
aes_35	dc.w	35,1,1,1,0
aes_36	dc.w	36,2,1,2,0
aes_37	dc.w	37,2,1,2,0
aes_38	dc.w	38,3,1,1,0
aes_39	dc.w	39,1,1,1,0
aes_40	dc.w	40,2,1,1,0
aes_41	dc.w	41,1,1,1,0
aes_42	dc.w	42,6,1,1,0
aes_43	dc.w	43,4,1,1,0
aes_44	dc.w	44,1,3,1,0
aes_45	dc.w	45,2,1,1,0
aes_46	dc.w	46,4,2,1,0
aes_47	dc.w	47,8,1,1,0
aes_48	dc.w	48,4,3,0,0
aes_50	dc.w	50,1,1,1,0
aes_51	dc.w	51,9,1,0,0
aes_52	dc.w	52,1,1,1,0
aes_53	dc.w	53,1,1,0,0
aes_54	dc.w	54,0,5,1,0
aes_55	dc.w	55,3,3,1,0
aes_56	dc.w	56,2,2,1,0
aes_70	dc.w	70,4,3,0,0
aes_71	dc.w	71,8,3,0,0
aes_72	dc.w	72,6,1,0,0
aes_73	dc.w	73,8,1,0,0
aes_74	dc.w	74,8,1,0,0
aes_75	dc.w	75,4,1,1,0
aes_76	dc.w	76,3,1,1,0
aes_77	dc.w	77,0,5,0,0
aes_78	dc.w	78,1,1,1,0
aes_79	dc.w	79,0,5,0,0
aes_80	dc.w	80,0,1,1,0
aes_81	dc.w	81,0,1,1,0
aes_90	dc.w	90,0,2,2,0
aes_91	dc.w	91,0,2,3,0
aes_100	dc.w	100,5,1,0,0
aes_101	dc.w	101,5,1,0,0
aes_102	dc.w	102,1,1,0,0
aes_103	dc.w	103,1,1,0,0
aes_104	dc.w	104,6,5,0,0
aes_105	dc.w	105,6,1,0,0
aes_106	dc.w	106,2,1,0,0
aes_107	dc.w	107,1,1,0,0
aes_108	dc.w	108,6,5,0,0
aes_109	dc.w	109,0,0,0,0
aes_110	dc.w	110,0,1,1,0
aes_111	dc.w	111,0,1,0,0
aes_112	dc.w	112,2,1,0,0
aes_113	dc.w	113,2,1,1,0
aes_114	dc.w	114,1,1,1,0
aes_115	dc.w	115,0,1,1,0
aes_116	dc.w	116,0,0,0,0
aes_117	dc.w	117,0,0,0,0
aes_118	dc.w	118,0,0,0,0
aes_119	dc.w	119,0,0,0,0
aes_120	dc.w	120,0,1,2,0
aes_121	dc.w	121,3,1,2,0
aes_122	dc.w	122,1,1,1,0
aes_123	dc.w	123,1,1,1,0
aes_124	dc.w	124,0,1,1,0
aes_125	dc.w	125,0,1,3,0
aes_130	dc.w	130,1,5,0,0

	SECTION	bss

aesReturn	ds.w	1
ap_id	ds.w	1