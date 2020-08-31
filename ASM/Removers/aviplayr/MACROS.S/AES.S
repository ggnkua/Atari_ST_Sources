**************
* Macros AES *
**************

; Routine pour appeler l'AES et renvoyer Int_out(0) dans D0 + tableaux AES
	bra.s	end_aes_call
aes_call:
	move.l	d1,-(sp)
	move.l	#aes_table,d1
	move.w	#200,d0
	trap	#2
	move.w	int_out,d0
	move.l	(sp)+,d1
	RTS
end_aes_call
********************************
	DATA
aes_table
	dc.l	control,global,int_in,int_out,addr_in,addr_out
********************************
	BSS
	IFND	control
control
	ds.w	5
	ENDC
global
	ds.w	14
	IFND	int_in
int_in
	ds.w	16
	ENDC
	IFND	int_out
int_out
	ds.w	7
	ENDC
addr_in
	ds.l	3
addr_out
	ds.l	1
********************************
	TEXT

; Macro pour remplir Control() et appeler l'AES
Call_aes	macro
	move.w	\1,control
	move.w	\2,control+2
	move.w	\3,control+4
	move.w	\4,control+6
	move.w	\5,control+8
	jsr	aes_call
	endm

; Les macros AES d‚butent ici !!
Appl_init	macro
	Call_aes	#10,#0,#1,#0,#0
	endm
	
Appl_read	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	Call_aes	#11,#2,#1,#1,#0
	endm
	
Appl_write	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	Call_aes	#12,#2,#1,#1,#0
	endm
	
Appl_find	macro
	move.l	\1,addr_in
	Call_aes	#13,#0,#1,#1,#0
	endm
	
Appl_tplay	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#14,#2,#1,#1,#0
	endm
	
Appl_trecord	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#15,#1,#1,#1,#0
	endm
	
Appl_search	macro
	move.w	\1,int_in
	move.l	\2,addr_in
	Call_aes	#18,#1,#3,#1,#0
	endm
	
Appl_exit	macro
	Call_aes	#19,#0,#1,#0,#0
	endm
	
Evnt_keybd	macro
	Call_aes	#20,#0,#1,#0,#0
	endm
	
Evnt_button	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	Call_aes	#21,#3,#5,#0,#0
	endm
	
Evnt_mouse	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	Call_aes	#22,#5,#5,#0,#0
	endm
	
Evnt_mesag	macro
	move.l	\1,addr_in
	Call_aes	#23,#0,#1,#1,#0
	endm
	
Evnt_timer	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	Call_aes	#24,#2,#1,#0,#0
	endm
	
Evnt_multi	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	move.w	\9,int_in+16
	move.w	\A,int_in+18
	move.w	\B,int_in+20
	move.w	\C,int_in+22
	move.w	\D,int_in+24
	move.w	\E,int_in+26
	move.w	\G,int_in+28
	move.w	\H,int_in+30
	move.l	\F,addr_in
	Call_aes	#25,#16,#7,#1,#0
	endm
	
Evnt_dclick	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	Call_aes	#26,#2,#1,#0,#0
	endm

Menu_bar	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#30,#1,#1,#1,#0
	endm
	
Menu_icheck	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#31,#2,#1,#1,#0
	endm
	
Menu_ienable	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#32,#2,#1,#1,#0
	endm
	
Menu_tnormal	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#33,#2,#1,#1,#0
	endm
	
Menu_text	macro
	move.l	\1,addr_in
	move.l	\3,addr_in+4
	move.w	\2,int_in
	Call_aes	#34,#1,#1,#2,#0
	endm
	
Menu_register	macro
	move.w	\1,int_in
	move.l	\2,addr_in
	Call_aes	#35,#1,#1,#1,#0
	endm
	
Menu_popup	macro
	move.l	\1,addr_in
	move.l	\4,addr_in+4
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#36,#2,#1,#2,#0
	endm
	
Menu_attach	macro
	move.w	\1,int_in
	move.w	\3,int_in+2
	move.l	\2,addr_in
	move.l	\4,addr_in+4
	Call_aes	#37,#2,#1,#2,#0
	endm
	
Menu_istart	macro
	move.w	\1,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.l	\2,addr_in
	Call_aes	#38,#3,#1,#1,#0
	endm
	
Menu_setting	macro
	move.w	\1,int_in
	move.l	\2,addr_in
	Call_aes	#39,#1,#1,#1,#0
	endm

Objc_add	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#40,#2,#1,#1,#0
	endm
	
Objc_delete	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#41,#1,#1,#1,#0
	endm
	
Objc_draw	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	move.w	\6,int_in+8
	move.w	\7,int_in+10
	Call_aes	#42,#6,#1,#1,#0
	endm
	
Objc_find	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	Call_aes	#43,#4,#1,#1,#0
	endm
	
Objc_offset	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#44,#1,#3,#1,#0
	endm
	
Objc_order	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#45,#2,#1,#1,#0
	endm
	
Objc_edit	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	Call_aes	#46,#4,#2,#1,#0
	endm
	
Objc_change	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	#0,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	Call_aes	#47,#8,#1,#1,#0
	endm
	
Objc_sysvar	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	Call_aes	#48,#4,#3,#0,#0
	endm
	
Form_do	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#50,#1,#1,#1,#0
	endm

Form_dial	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	move.w	\9,int_in+16
	Call_aes	#51,#9,#1,#0,#0
	endm
	
Form_alert	macro
	move.w	\1,int_in
	move.l	\2,addr_in
	Call_aes	#52,#1,#1,#1,#0
	endm
	
Form_error	macro
	move.w	\1,int_in
	Call_aes	#53,#1,#1,#0,#0
	endm
	
Form_center	macro
	move.l	\1,addr_in
	Call_aes	#54,#0,#5,#1,#0
	endm
	
Form_keybd	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	Call_aes	#55,#3,#3,#1,#0
	endm
	
Form_button	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	Call_aes	#56,#2,#2,#1,#0
	endm

Graf_rubberbox	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	Call_aes	#70,#4,#3,#0,#0
	endm
	
Graf_dragbox	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	Call_aes	#71,#8,#3,#0,#0
	endm
	
Graf_movebox	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	Call_aes	#72,#6,#1,#0,#0
	endm
	
Graf_growbox	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	Call_aes	#73,#8,#1,#0,#0
	endm
	
Graf_shrinkbox	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	Call_aes	#74,#8,#1,#0,#0
	endm
	
Graf_watchbox	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	Call_aes	#75,#3,#1,#1,#0
	endm
	
Graf_slidebox	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	Call_aes	#76,#3,#1,#1,#0
	endm
	
Graf_handle	macro
	Call_aes	#77,#0,#5,#0,#0
	endm
	
Graf_mouse	macro
	move.w	\1,int_in
	move.l	\2,addr_in
	Call_aes	#78,#1,#1,#1,#0
	endm
	
Graf_mkstate	macro
	Call_aes	#79,#0,#5,#0,#0
	endm
	
Scrp_read	macro
	move.l	\1,addr_in
	Call_aes	#80,#0,#1,#1,#0
	endm
	
Scrp_write	macro
	move.l	\1,addr_in
	Call_aes	#81,#0,#1,#1,#0
	endm

Fsel_input	macro
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	Call_aes	#90,#0,#2,#2,#0
	endm
	
Fsel_exinput	macro
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	move.l	\3,addr_in+8
	Call_aes	#91,#0,#2,#3,#0
	endm
	
Wind_create	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	Call_aes	#100,#5,#1,#0,#0
	endm
	
Wind_open	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	Call_aes	#101,#5,#1,#0,#0
	endm
	
Wind_close	macro
	move.w	\1,int_in
	Call_aes	#102,#1,#1,#0,#0
	endm
	
Wind_delete	macro
	move.w	\1,int_in
	Call_aes	#103,#1,#1,#0,#0
	endm
	
Wind_get	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	Call_aes	#104,#2,#5,#0,#0
	endm
	
Wind_set	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	Call_aes	#105,#6,#1,#0,#0
	endm
	
Wind_find	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	Call_aes	#106,#2,#1,#0,#0
	endm
	
Wind_update	macro
	move.w	\1,int_in
	Call_aes	#107,#1,#1,#0,#0
	endm
	
Wind_calc	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	Call_aes	#108,#6,#5,#0,#0
	endm
	
Wind_new	macro
	Call_aes	#109,#0,#1,#0,#0
	endm
	
Rsrc_load	macro
	move.l	\1,addr_in
	Call_aes	#110,#0,#1,#1,#0
	endm
	
Rsrc_free	macro
	Call_aes	#111,#0,#1,#0,#0
	endm
	
Rsrc_gaddr	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	Call_aes	#112,#2,#1,#0,#1
	endm
	
Rsrc_saddr	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	Call_aes	#113,#2,#1,#1,#0
	endm
	
Rsrc_obfix	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#114,#1,#1,#1,#0
	endm
	
Rsrc_rfix	macro
	move.l	\1,addr_in
	Call_aes	#115,#0,#1,#1,#0
	endm
	
Shel_read	macro
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	Call_aes	#120,#0,#1,#2,#0
	endm
	
Shel_write	macro
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.l	\4,addr_in
	move.l	\5,addr_in+4
	Call_aes	#121,#3,#1,#2,#0
	endm
	
Shel_get	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#122,#1,#1,#1,#0
	endm
	
Shel_put	macro
	move.l	\1,addr_in
	move.w	\2,int_in
	Call_aes	#123,#1,#1,#1,#0
	endm
	
Shel_find	macro
	move.l	\1,addr_in
	Call_aes	#124,#0,#1,#1,#0
	endm
	
Shel_envr	macro
	move.l	\1,addr_in
	Call_aes	#125,#0,#1,#1,#1
	endm
	
Appl_getinfo	macro
	move.w	\1,int_in
	Call_aes	#130,#1,#5,#0,#0
	endm
				