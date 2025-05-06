
* AES Library Copyright (C) HiSoft 1988
* this MUST be assembled to either executable or GST linkable, NOT DRI code

* sets section order to TEXT,DATA,BSS

* 27.7.88	adjusted table and addr_in for TOS 1.04 calls
* 3.10.88	control made 5 words instead of 4!
* 14.12.90 noms des fonctions ajout‚s en face des opcodes
* et activation de FORM_KEYBD et FORM_BUTTON


	MODULE	LowLevelAES

	XDEF	CALL_AES,control,global,int_in,int_out
	XDEF	addr_in,addr_out,aes_params

	SECTION	TEXT
* call an AES routine
* in:	d0.w=AES function number
* out	d0.w=int_out value
* uses	d0-d2/a0-a2
* (assumes control4 needs to be zero)
CALL_AES	lea	control,a1
	move.w	d0,(a1)+			store the op code
	sub.w	#10,d0
	mulu	#3,d0			size is the priority, not speed
	lea	gem_ctrl_list,a0
	add.w	d0,a0			points to the entry
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)+		do control1
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control2
	move.b	(a0)+,d0
	move.w	d0,(a1)+		and control3
	clr.w	(a1)	assumes control4=0 (all except RSRC_GADDR)
	move.l	#aes_params,d1
	move.w	#200,d0		function number
	trap	#2
	move.w	int_out,d0		usually a returned value
	rts

	SECTION	DATA
* Table de pointeurs pour les tableaux AES
aes_params	dc.l	control,global,int_in,int_out,addr_in,addr_out

* Listes des param‚tres … passer dans le tableau CONTROL
* pour les appels … l'AES (Control 1-3). En commentaire le
* num‚ro et le nom de la fonction. Un '*' indique que la
* fonction n'est pas d‚finit dans la biblioth‚que.
gem_ctrl_list
	dc.b	0,1,0	10	APPL_INIT
	dc.b	2,1,1	11	APPL_READ
	dc.b	2,1,1	12	APPL_WRITE
	dc.b	0,1,1	13	APPL_FIND
	dc.b	2,1,1	14	APPL_TPLAY
	dc.b	1,1,1	15	APPL_TRECORD
	dc.b	0,0,0	16*	
	dc.b	0,0,0	17*
	dc.b	0,0,0	18*
	dc.b	0,1,0	19	APPL_EXIT
	dc.b	0,1,0	20	EVNT_KEYBD
	dc.b	3,5,0	21	EVNT_BUTTON
	dc.b	5,5,0	22	EVNT_MOUSE
	dc.b	0,1,1	23	EVNT_MESAG
	dc.b	2,1,0	24	EVNT_TIMER
	dc.b	16,7,1	25	EVNT_MULTI
	dc.b	2,1,0	26	EVNT_DCLICK
	dc.b	0,0,0	27*	
	dc.b	0,0,0	28*
	dc.b	0,0,0	29*
	dc.b	1,1,1	30	MENU_BAR
	dc.b	2,1,1	31	MENU_ICHECK
	dc.b	2,1,1	32	MENU_IENABLE
	dc.b	2,1,1	33	MENU_TNORMAL
	dc.b	1,1,2	34	MENU_TEXT
	dc.b	1,1,1	35	MENU_REGISTER
	dc.b	0,0,0	36*
	dc.b	0,0,0	37*
	dc.b	0,0,0	38*
	dc.b	0,0,0	39*
	dc.b	2,1,1	40	OBJC_ADD
	dc.b	1,1,1	41	OBJC_DELETE
	dc.b	6,1,1	42	OBJC_DRAW
	dc.b	4,1,1	43	OBJC_FIND
	dc.b	1,3,1	44	OBJC_OFFSET
	dc.b	2,1,1	45	OBJC_ORDER
	dc.b	4,2,1	46	OBJC_EDIT
	dc.b	8,1,1	47	OBJC_CHANGE
	dc.b	0,0,0	48*	
	dc.b	0,0,0	49*
	dc.b	1,1,1	50	FORM_DO
	dc.b	9,1,0	51	FORM_DIAL
	dc.b	1,1,1	52	FORM_ALERTE
	dc.b	1,1,0	53	FORM_ERROR
	dc.b	0,5,1	54	FORM_CENTER
	dc.b	3,3,1	55	FORM_KEYBD
	dc.b	2,2,1	56	FORM_BUTTON
	dc.b	0,0,0	57*
	dc.b	0,0,0	58*
	dc.b	0,0,0	59*
	dc.b	0,0,0	60*
	dc.b	0,0,0	61*
	dc.b	0,0,0	62*
	dc.b	0,0,0	63*
	dc.b	0,0,0	64*
	dc.b	0,0,0	65*
	dc.b	0,0,0	66*
	dc.b	0,0,0	67*
	dc.b	0,0,0	68*
	dc.b	0,0,0	69*
	dc.b	4,3,0	70	GRAF_RUBBERBOX
	dc.b	8,3,0	71	GRAF_DRAGBOX
	dc.b	6,1,0	72	GRAF_MOVEBOX
	dc.b	8,1,0	73	GRAF_GROWBOX
	dc.b	8,1,0	74	GRAF_SHRINKBOX
	dc.b	4,1,1	75	GRAF_WATCHBOX
	dc.b	3,1,1	76	GRAF_SLIDEBOX
	dc.b	0,5,0	77	GRAF_HANDLE
	dc.b	1,1,1	78	GRAF_MOUSE
	dc.b	0,5,0	79	GRAF_MKSTATE
	dc.b	0,1,1	80	SCRP_READ
	dc.b	0,1,1	81	SCRP_WRITE
	dc.b	0,0,0	82*
	dc.b	0,0,0	83*
	dc.b	0,0,0	84*
	dc.b	0,0,0	85*
	dc.b	0,0,0	86*
	dc.b	0,0,0	87*
	dc.b	0,0,0	88*
	dc.b	0,0,0	89*
	dc.b	0,2,2	90	FSEL_INPUT
	dc.b	0,2,3	91	FSEL_EXINPUT
	dc.b	0,0,0	92*
	dc.b	0,0,0	93*
	dc.b	0,0,0	94*
	dc.b	0,0,0	95*
	dc.b	0,0,0	96*
	dc.b	0,0,0	97*
	dc.b	0,0,0	98*
	dc.b	0,0,0	99*
	dc.b	5,1,0	100	WIND_CREATE
	dc.b	5,1,0	101	WIND_OPEN
	dc.b	1,1,0	102	WIND_CLOSE
	dc.b	1,1,0	103	WIND_DELETE
	dc.b	2,5,0	104	WIND_GET
	dc.b	6,1,0	105	WIND_SET
	dc.b	2,1,0	106	WIND_FIND
	dc.b	1,1,0	107	WIND_UPDATE
	dc.b	6,5,0	108	WIND_CALC
	dc.b	0,0,0	109	WIND_NEW
	dc.b	0,1,1	110	RSRC_LOAD
	dc.b	0,1,0	111	RSRC_FREE
	dc.b	2,1,0	112 ** Control(4)=1 ** RSRC_GADDR
	dc.b	2,1,1	113	RSRC_SADDR
	dc.b	1,1,1	114	RSRC_OBFIX
	dc.b	0,0,0	115*	
	dc.b	0,0,0	116*
	dc.b	0,0,0	117*
	dc.b	0,0,0	118*
	dc.b	0,0,0	119*
	dc.b	0,1,2	120	SHEL_READ
	dc.b	3,1,2	121	SHEL_WRITE
	dc.b	1,1,1	122	SHEL_GET	
	dc.b	1,1,1	123	SHEL_PUT
	dc.b	0,1,1	124	SHEL_FIND
	dc.b	0,1,3	125	SHEL_ENVRN
	even

	SECTION	BSS
* these don't need initialising so can go in the BSS section
control		ds.w	5
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1


*********** END OF AES *****************

