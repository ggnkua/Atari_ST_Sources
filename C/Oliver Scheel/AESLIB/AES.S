*******************************************************************************
*
*	New AES-Binding for Sozobon C
*
*	(c) 11/1989 by Oliver Scheel
*
*******************************************************************************
*
*	Exports:
*		int	aes()
*		void	crystal()
*		char	*ctrl_cnts	Attention! Four bytes each function!
*		int	control[]
*		int	global[]
*		int	int_in[]
*		int	int_out[]
*		long	addr_in[]
*		long	addr_out[]
*
*******************************************************************************

	.text

	.globl	_aes,_crystal,_ctrl_cnts
	.globl	_control,_global,_int_in,_int_out,_addr_in,_addr_out

*******************************************************************************
*	AES - Funktion
*******************************************************************************

_aes:
	move.l	sp,a5			* Stackpointer kopieren
	addq.l	#4,a5
	move.w	(a5)+,d0		* Opcode laden
	move.w	d0,_control+0		* --> control[0]
	subi.w	#10,d0			* (Opcode - 10) * 4
	mulu	#4,d0
	ext.l	d0
	add.l	#_ctrl_cnts,d0		* + Anfangsadresse der Tabelle
	move.l	d0,a2			* --> A3
	move.b	0(a2),d0		* Anzahl int_in Elemente holen
	ext.w	d0
	move.w	d0,_control+2		* --> control[1]
	beq	skip1			* Wenn keine da, weiter mit addr_in
	lea	_int_in,a4		* Anfangsadresse des int_in Arrays
	subq.w	#1,d0			* d0 = d0 - 1
loop1:	move.w	(a5)+,(a4)+		* Elemente vom Stack kopieren
	dbf	d0,loop1
skip1:	move.b	2(a2),d0		* Anzahl addr_in Elemente holen
	ext.w	d0
	move.w	d0,_control+6		* --> control[3]
	beq	skip2			* Wenn keine da, weiter mit ...
	lea	_addr_in,a4		* Anfangsadresse des addr_in Arrays
	subq.w	#1,d0			* d0 = d0 - 1
loop2:	move.l	(a5)+,(a4)+		* Elemente vom Stack kopieren
	dbf	d0,loop2
skip2:	move.b	1(a2),d0		* Anzahl int_out Elemente holen
	ext.w	d0
	move.w	d0,_control+4		* --> control[2]
	move.b	3(a2),d0		* Anzahl addr_out Elemente holen
	ext.w	d0
	move.w	d0,_control+8		* --> control[4]
	movem.l	a2/a5,-(sp)		* Register retten
	move.l	#aespb,-(sp)		* Anfangsadresse des AESPB
	bsr	_crystal		* _crystal aufrufen
	addq.l	#4,sp			* Stack korrigieren
	movem.l	(sp)+,a2/a5		* Register laden
	move.b	1(a2),d0		* Anzahl der int_out Elemente holen
	subq.w	#1,d0			* d0 = d0 - 1
	beq	skip3			* Wenn keine da, weiter mit addr_out
	lea	_int_out+2,a4		* Adresse von int_out[1] holen
	subq.w	#1,d0			* d0 = d0 - 1
loop3:	move.l	(a5)+,a3		* Adresse holen
	move.w	(a4)+,(a3)		* Werte schreiben
	dbf	d0,loop3
skip3:	move.b	3(a2),d0		* Anzahl der addr_out Elemente holen
	beq	skip4			* keins da, ueberspringen
	move.l	(a5)+,a4		* Adresse holen
	move.l	_addr_out,(a4)		* Wert schreiben
skip4:	move.w	_int_out,d0		* Rueckgabeparameter nach D0
	rts				* Tschuess

*******************************************************************************
*	_crystal
*******************************************************************************

_crystal:
	move.l	4(sp),d1
	move.w	#200,d0
	trap	#2
	rts

*******************************************************************************
*	_ctrl_cnts	VORSICHT: modifiziert, da 4 Werte pro Funktion !!!!
*******************************************************************************

	.data
		
_ctrl_cnts:
	.dc.b	0, 1, 0, 0	* appl_init
    	.dc.b	2, 1, 1, 0	* appl_read
    	.dc.b	2, 1, 1, 0	* appl_write
	.dc.b	0, 1, 1, 0	* appl_find
	.dc.b	2, 1, 1, 0	* appl_tplay
	.dc.b	1, 1, 1, 0	* appl_trecord
	.dc.b	2, 1, 0, 0	* appl_bvset (GEM 2.0)
	.dc.b	0, 1, 0, 0	* appl_yield (GEM 2.0)
	.dc.b	0, 0, 0, 0	* AES 18
	.dc.b	0, 1, 0, 0	* appl_exit
	.dc.b	0, 1, 0, 0	* evnt_keybd
	.dc.b	3, 5, 0, 0	* evnt_button
	.dc.b	5, 5, 0, 0	* evnt_mouse
	.dc.b	0, 1, 1, 0	* evnt_mesag
	.dc.b	2, 1, 0, 0	* evnt_timer
	.dc.b	16, 7, 1, 0	* evnt_multi
	.dc.b	2, 1, 0, 0	* evnt_dclicks
	.dc.b	0, 0, 0, 0	* AES 27
	.dc.b	0, 0, 0, 0	* AES 28
	.dc.b	0, 0, 0, 0	* AES 29
	.dc.b	1, 1, 1, 0	* menu_bar
	.dc.b	2, 1, 1, 0	* menu_icheck
	.dc.b	2, 1, 1, 0	* menu_ienable
	.dc.b	2, 1, 1, 0	* menu_tnormal
	.dc.b	1, 1, 2, 0	* menu_text
	.dc.b	1, 1, 1, 0	* menu_register
	.dc.b	1, 1, 0, 0	* menu_unregister (GEM 2.0)
	.dc.b	0, 0, 0, 0	* AES 37
	.dc.b	0, 0, 0, 0	* AES 38
	.dc.b	0, 0, 0, 0	* AES 39
	.dc.b	2, 1, 1, 0	* objc_add
	.dc.b	1, 1, 1, 0	* objc_delete
  	.dc.b	6, 1, 1, 0	* objc_draw
	.dc.b	4, 1, 1, 0	* objc_find
	.dc.b	1, 3, 1, 0	* objc_offset
	.dc.b	2, 1, 1, 0	* objc_order
	.dc.b	4, 2, 1, 0	* objc_edit
	.dc.b	8, 1, 1, 0	* objc_change
	.dc.b	0, 0, 0, 0	* AES 48
	.dc.b	0, 0, 0, 0	* AES 49
	.dc.b	1, 1, 1, 0	* form_do
	.dc.b	9, 1, 0, 0	* form_dial
	.dc.b	1, 1, 1, 0	* form_alert
	.dc.b	1, 1, 0, 0	* form_error
	.dc.b	0, 5, 1, 0	* form_center
	.dc.b	3, 3, 1, 0	* form_keybd
	.dc.b	2, 2, 1, 0	* form_button
	.dc.b	0, 0, 0, 0	* AES 57
	.dc.b	0, 0, 0, 0	* AES 58
	.dc.b	0, 0, 0, 0	* AES 59
	.dc.b	0, 0, 0, 0	* AES 60
	.dc.b	0, 0, 0, 0	* AES 61
	.dc.b	0, 0, 0, 0	* AES 62
	.dc.b	0, 0, 0, 0	* AES 63
	.dc.b	0, 0, 0, 0	* AES 64
	.dc.b	0, 0, 0, 0	* AES 65
	.dc.b	0, 0, 0, 0	* AES 66
	.dc.b	0, 0, 0, 0	* AES 67
	.dc.b	0, 0, 0, 0	* AES 68
	.dc.b	0, 0, 0, 0	* AES 69
	.dc.b	4, 3, 0, 0	* graf_rubberbox
	.dc.b	8, 3, 0, 0	* graf_dragbox
	.dc.b	6, 1, 0, 0	* graf_movebox
	.dc.b	8, 1, 0, 0	* graf_growbox
	.dc.b	8, 1, 0, 0	* graf_shrinkbox
	.dc.b	4, 1, 1, 0	* graf_watchbox
	.dc.b	3, 1, 1, 0	* graf_slidebox
	.dc.b	0, 5, 0, 0	* graf_handle
	.dc.b	1, 1, 1, 0	* graf_mouse
	.dc.b	0, 5, 0, 0	* graf_mkstate
	.dc.b	0, 1, 1, 0	* scrp_read
	.dc.b	0, 1, 1, 0	* scrp_write
	.dc.b	0, 1, 0, 0	* scrp_clear (GEM 2.0)
	.dc.b	0, 0, 0, 0	* AES 83
	.dc.b	0, 0, 0, 0	* AES 84
	.dc.b	0, 0, 0, 0	* AES 85
	.dc.b	0, 0, 0, 0	* AES 86
	.dc.b	0, 0, 0, 0	* AES 87
	.dc.b	0, 0, 0, 0	* AES 88
	.dc.b	0, 0, 0, 0	* AES 89
	.dc.b	0, 2, 2, 0	* fsel_input
	.dc.b	0, 2, 3, 0	* fsel_exinput (TOS 1.4)
	.dc.b	0, 0, 0, 0	* AES 92
	.dc.b	0, 0, 0, 0	* AES 93
	.dc.b	0, 0, 0, 0	* AES 94
	.dc.b	0, 0, 0, 0	* AES 95
	.dc.b	0, 0, 0, 0	* AES 96
	.dc.b	0, 0, 0, 0	* AES 97
	.dc.b	0, 0, 0, 0	* AES 98
	.dc.b	0, 0, 0, 0	* AES 99
	.dc.b	5, 1, 0, 0	* wind_create
	.dc.b	5, 1, 0, 0	* wind_open
	.dc.b	1, 1, 0, 0	* wind_close
	.dc.b	1, 1, 0, 0	* wind_delete
	.dc.b	2, 5, 0, 0	* wind_get
	.dc.b	6, 1, 0, 0	* wind_set
	.dc.b	2, 1, 0, 0	* wind_find
	.dc.b	1, 1, 0, 0	* wind_update
	.dc.b	6, 5, 0, 0	* wind_calc
	.dc.b	0, 0, 0, 0	* wind_new (TOS 1.4)
	.dc.b	0, 1, 1, 0	* rsrc_load
	.dc.b	0, 1, 0, 0	* rsrc_free
	.dc.b	2, 1, 0, 1	* rsrc_gaddr
	.dc.b	2, 1, 1, 0	* rsrc_saddr
	.dc.b	1, 1, 1, 0	* rsrc_obfix
	.dc.b	0, 0, 0, 0	* AES 115
	.dc.b	0, 0, 0, 0	* AES 116
	.dc.b	0, 0, 0, 0	* AES 117
	.dc.b	0, 0, 0, 0	* AES 118
	.dc.b	0, 0, 0, 0	* AES 119
	.dc.b	0, 1, 2, 0	* shel_read
	.dc.b	3, 1, 2, 0	* shel_write
	.dc.b	1, 1, 1, 0	* shel_get
	.dc.b	1, 1, 1, 0	* shel_put
	.dc.b	0, 1, 1, 0	* shel_find
	.dc.b	0, 1, 2, 0	* shel_envrn
	.dc.b	0, 1, 2, 0	* shel_rdef (GEM 2.0)
	.dc.b	0, 0, 2, 0	* shel_wdef (GEM 2.0)
	.dc.b	0, 0, 0, 0	* AES 128
	.dc.b	0, 0, 0, 0	* AES 129
	.dc.b	6, 6, 0, 0	* xgrf_stepcalc (GEM 2.0)
	.dc.b	9, 1, 0, 0	* xgrf_2box (GEM 2.0)

*******************************************************************************
*	AES Parameter Block
*******************************************************************************

aespb:
pctrl:
	.dc.l	_control
pglobl:
	.dc.l	_global
pintin:
	.dc.l	_int_in
pintout:
	.dc.l	_int_out
padrin:
	.dc.l	_addr_in
padrout:
	.dc.l	_addr_out

*******************************************************************************
*	Funktionswerte
*******************************************************************************

	.bss

_control:
	.ds.w	5
_global:
	.ds.w	15
_int_in:
	.ds.w	16
_int_out:
	.ds.w	7
_addr_in:
	.ds.l	2
_addr_out:
	.ds.l	1

	
	.end

