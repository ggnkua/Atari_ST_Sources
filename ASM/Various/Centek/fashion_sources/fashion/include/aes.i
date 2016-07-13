* Macro library to call AES & VDI
* Copyright (c) HiSoft 1988

* 31.5.88	fixed appl_read,appl_write,graf_slidebox
* 2.6.88	fixed evnt_multi
* 11.9.88	v_contour_fill corrected (to v_contourfill)
* 25.10.89	vswr_mode fixed (intint typo), added TOS 1.4 AES calls
*		fsel_exinput, wind_new. Added shel_get/put
* 1.5.90	Added form_button/form_keybd

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
***********equ des messages******************
MN_SELECTED	equ	10
WM_REDRAW	equ	20
WM_TOPPED	equ	21
WM_CLOSED	equ	22
WM_FULLED	equ	23
WM_ARROWED	equ	24
WM_HSLID	equ	25
WM_VSLID	equ	26
WM_SIZED	equ	27
WM_MOVED	equ	28
WM_NEWTOP	equ	29
WM_UNTOPPED	equ	30
WM_ONTOP	equ	31
AC_OPEN		equ	40
AC_CLOSE	equ	41
AP_TERM		equ	50
AP_TFAIL	equ	51
SHUT_COMPLETED	equ	60
RESCH_COMPLETED	equ	61
AP_DRAGDROP	equ	63
SH_WDRAW	equ	72
CH_EXIT		equ	80
***********equ des evenement ARROWED******************
WA_UPPAGE	equ	0	; une page vers le haut
WA_DNPAGE	equ	1	; une page vers le bas
WA_UPLINE	equ	2	; ligne precedente
WA_DNLINE	equ	3	; ligne suivante
WA_LFPAGE	equ	4	; une page vers la gauche
WA_RTPAGE	equ	5	; une page vers la droite
WA_LFLINE	equ	6	; une colone vers la gauche
WA_RTLINE	equ	7	; une colone vers la droite
***********AES Macros******************
* macro to call a given AES routine
	XREF	CALL_AES,int_in,int_out,addr_in,addr_out
aes	macro	; aes_number
	move.l	#\1,d0
	jsr	CALL_AES
	endm
*	may need to change BSR CALL_AES to JSR for large programs

appl_init	macro
	aes	10
	endm

appl_read	macro	; id,length,buff
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	aes	11
	endm

appl_write	macro	; id,length,buffer
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	aes	12
	endm

appl_find	macro	; name
	move.l	\1,addr_in
	aes	13
	endm

appl_tplay	macro	; mem,num,scale
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	14
	endm

appl_trecord	macro	; mem,count
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	15
	endm

appl_exit	macro
	aes	19
	endm

evnt_keybd	macro
	aes	20
	endm

evnt_button	macro	; clicks,mask,state
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	aes	21
	endm

evnt_mouse	macro	; flags,x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	aes	22
	endm

evnt_mesag	macro	; buffer
	move.l	\1,addr_in
	aes	23
	endm

evnt_timer	macro	; longcount
	move.l	\1,d0
	swap	d0
	move.l	d0,int_in
	aes	24
	endm

evnt_multi	macro	; flags[,lots]
	move.w	\1,int_in
	IFNC	'\2',''
	move.w	\2,int_in+2
	ENDC
	IFNC	'\3',''
	move.w	\3,int_in+4
	ENDC
	IFNC	'\4',''
	move.w	\4,int_in+6
	ENDC
	IFNC	'\5',''
	move.w	\5,int_in+8
	ENDC
	IFNC	'\6',''
	move.w	\6,int_in+10
	ENDC
	IFNC	'\7',''
	move.w	\7,int_in+12
	ENDC
	IFNC	'\8',''
	move.w	\8,int_in+14
	ENDC
	IFNC	'\9',''
	move.w	\9,int_in+16
	ENDC
	IFNC	'\A',''
	move.w	\A,int_in+18
	ENDC
	IFNC	'\B',''
	move.w	\B,int_in+20
	ENDC
	IFNC	'\C',''
	move.w	\C,int_in+22
	ENDC
	IFNC	'\D',''
	move.w	\D,int_in+24
	ENDC
	IFNC	'\E',''
	move.w	\E,int_in+26
	ENDC
	IFNC	'\F',''
	move.l	\F,addr_in
	ENDC
	IFNC	'\G',''
	move.l	\G,d0
	swap	d0
	move.l	d0,int_in+28
	ENDC
	aes	25
	endm

evnt_dclick	macro	; new,getset
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	26
	endm

menu_bar	macro	; tree,show
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	30
	endm

menu_icheck	macro	; tree,item,check
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	31
	endm

menu_ienable	macro	; tree,item,enable
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	32
	endm

	rsreset
mn_set_display	rs.l	1
mn_set_drag	rs.l	1
mn_set_delay	rs.l	1
mn_set_speed	rs.l	1
mn_set_height	rs.w	1
sizeof_mn_set	rs.w	1

menu_settings	macro	; flag,set
	move.w	\1,int_in
	move.l	\2,addr_in
	aes	39
	endm

menu_tnormal	macro	; tree,title,normal
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	33
	endm

menu_text	macro	; tree,item,text
	move.l	\1,addr_in
	move.w	\2,int_in
	move.l	\3,addr_in+4
	aes	34
	endm

menu_register	macro	; id,string
	move.w	\1,int_in
	move.l	\2,addr_in
	aes	35
	endm

objc_add	macro	; tree,parent,child
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	40
	endm

objc_delete	macro	; tree,object
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	41
	endm

objc_draw	macro	; tree,startob,depth,x,y,w,h
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	move.w	\6,int_in+8
	move.w	\7,int_in+10
	aes	42
	endm

xobjc_draw	macro	; tree,startob,depth,x,y,w,h
	move.l	\1,_A_ADDRIN
	move.w	\2,_A_INTIN
	move.w	\3,_A_INTIN+2
	move.w	\4,_A_INTIN+4
	move.w	\5,_A_INTIN+6
	move.w	\6,_A_INTIN+8
	move.w	\7,_A_INTIN+10
	
	jsr		AesObjcDraw
	
	endm

objc_find	macro	; tree,startob,depth,x,y
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	aes	43
	endm

objc_offset	macro	; tree,object
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	44
	endm

objc_order	macro	; tree,object,newpos
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	45
	endm

objc_edit	macro	; tree,object,char,idx,kind
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	aes	46
	endm

objc_change	macro	; tree,object,x,y,w,h,new,redraw
	move.l	\1,addr_in
	move.w	\2,int_in
	clr.w	int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	47
	endm

form_do	macro	; tree,startob
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	50
	endm

form_dial	macro	; flag,x,y,w,h,x2,y2,w2,h2
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	IFNC	'\6',''
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	move.w	\9,int_in+16
	endc
	aes	51
	endm

form_alert	macro	; button,string
	move.w	\1,int_in
	move.l	\2,addr_in
	aes	52
	endm

form_error	macro	; errnum
	move.w	\1,int_in
	aes	53
	endm

form_center	macro	; tree
	move.l	\1,addr_in
	aes	54
	endm

form_keybd	macro	; form,obj,nxt_obj,thechar
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	aes	55
	endm

form_button	macro	; tree,object,clks
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	56
	endm

graf_rubberbox	macro	; x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	aes	70
	endm
	
graf_dragbox	macro	; w,h,x,y,bx,bh,bw,bh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	71
	endm

graf_movebox	macro	; w,h,x,y,dx,dy
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	aes	72
	endm

graf_growbox	macro	; x,y,w,h,fx,fy,fw,fh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	73
	endm

graf_shrinkbox	macro	; x,y,w,h,sx,sy,sw,sh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	74
	endm

graf_watchbox	macro	; tree,object,instate,outstate
	clr.w	int_in
	move.l	\1,addr_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	aes	75
	endm

graf_slidebox	macro	; tree,parent,obj,vh
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	aes	76
	endm

graf_handle	macro
	aes	77
	endm

ARROW		equ	0
TEXT_CRSR	equ	1
BUSY_B		equ	2
POINT_HAND	equ	3
FLAT_HAND	equ	4
THIN_CROSS	equ	5
THICK_CROSS	equ	6
OUTLN_CROSS	equ	7
USER_DEF	equ	255
M_OFF		equ	256
M_ON		equ	257
M_SAVE		equ	258
M_LAST		equ	259
M_RESTORE	equ	260

graf_mouse	macro	; num<,addr>
	move.w	\1,int_in
	IFNC	'\2',''
	move.l	\2,addr_in
	ENDC
	aes	78
	endm

graf_mkstate	macro
	aes	79
	endm

scrp_read	macro	; scrap
	move.l	\1,addr_in
	aes	80
	endm

scrp_write	macro	; scrap
	move.l	\1,addr_in
	aes	81
	endm

fsel_input	macro	; path,filename
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	aes	90
	endm

fsel_exinput	macro	; path,filename,label
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	move.l	\3,addr_in+8		; needs bigger addr_in than before!
	aes	91
	endm
	
wind_create	macro	; kind,x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	aes	100
	endm

wind_open	macro	; handle,x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	aes	101
	endm

wind_close	macro	; handle
	move.w	\1,int_in
	aes	102
	endm

wind_delete	macro	; handle
	move.w	\1,int_in
	aes	103
	endm

*** EQU pour wind_get ***
WF_WORKXYWH	equ	4	; position de la zone de travail
WF_CURRXYWH	equ	5	; position actuelle de la fenetre
WF_PREVXYWH	equ	6	; taille totale de la fenetre precedente
WF_FULLXYWH	equ	7	; position de la fenetre quand toppe
WF_HSLIDE	equ	8	; position du slider horisontal
WF_VSLIDE	equ	9	; idem vertical
WF_TOP		equ	10	; handle de la fenetre active
WF_FIRSTXYWH	equ	11	; premier rectangle de redraw
WF_NEXTXYWH	equ	12	; rectangles suivants
WF_HSLSLIDE	equ	15	; taille du slider horizontal
WF_VSLSLIDE	equ	16	; idem vertical
WF_SCREEN	equ	17	; adresse de la memoire tampon d'alert

wind_get	macro	; handle,field
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	104
	endm

*** EQU pour wind_set ***
WF_KIND		equ	1	; parametre de la fenetre
WF_NAME		equ	2	; enregistre le pointeur sur la chaine de titre
WF_INFO		equ	3	; idem pour le titre
;WF_CURRXYWH	equ	5	; positionne la fenetre
;WF_HSLIDE	equ	8	; positionne le slider horisontal
;WF_VSLIDE	equ	9	; idem vertical
;WF_TOP		equ	10	; place la fenetre au top
WF_NEWDESK	equ	14	; impose un nouvel arbre de fond dans le bureau
;WF_HSLSLIDE	equ	15	; taille du slider horizontal
;WF_VSLSLIDE	equ	16	; idem vertical

wind_set	macro	; handle,field
	move.w	\1,int_in
	move.w	\2,int_in+2
	IFNC	'\3',''
	move.w	\3,int_in+4
	ENDC
	IFNC	'\4',''
	move.w	\4,int_in+6
	ENDC
	IFNC	'\5',''
	move.w	\5,int_in+8
	ENDC
	IFNC	'\6',''
	move.w	\6,int_in+10
	ENDC
	aes	105
	endm

wind_set2	macro	; handle,field
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	105
	endm

wf_newdesk	macro	; handle,feild,tree_addr.l,first_objet,nbr_objet
	move.w	\1,int_in		; sous fonction de wind_set
	move.w	#14,int_in+2	; rajoute par ZIGOMA of ADRENALINE
	move.l	\3,int_in+4
	move.w	\4,int_in+8
	move.w	\5,int_in+10
	aes	105
	endm

wind_find	macro	; x,y
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	106
	endm

wind_update	macro	; begend
	move.w	\1,int_in
	aes	107
	endm

wind_calc	macro	; request,kind,inx,iny,inw,inh	; si request est a 0
	move.w	\1,int_in				; alors on demande les coordonnees
	move.w	\2,int_in+2				; exterieur a partir des coordonnes
	move.w	\3,int_in+4				; interieur
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	aes	108
	endm

wind_new	macro
	aes	109
	endm

rsrc_load	macro	; name
	move.l	\1,addr_in
	aes	110
	endm

rsrc_free	macro
	aes	111
	endm

rsrc_gaddr	macro	; type,index
	ifnd	int_in
	XREF	int_in
	endc
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	112
	endm

rsrc_saddr	macro	; type,index,saddr
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	aes	113
	endm

rsrc_obfix	macro	; tree,object
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	114
	endm

shel_read	macro	; command,shell
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	aes	120
	endm

shel_write	macro	; doex,sgr,scr,cmd,shell
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.l	\4,addr_in
	move.l	\5,addr_in+4
	aes	121
	endm

shel_get	macro	; buffer,length
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	122
	endm

shel_put	macro	; buffer,length
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	123
	endm

shel_find	macro	; buffer
	move.l	\1,addr_in
	aes	124
	endm

shel_envrn	macro	; value,string
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	aes	125
	endm

AES_LARGEFONT	equ	0
AES_SMALLFONT	equ	1
AES_SYSTEM	equ	2
AES_LANGUAGE	equ	3
AES_PROCESS	equ	4
AES_PCGEM	equ	5
AES_INQUIRE	equ	6
; pas de 7...
AES_MOUSE	equ	8
AES_MENU	equ	9
AES_SHELL	equ	10
AES_WINDOW	equ	11
AES_MESSAGE	equ	12
AES_OBJECT	equ	13
AES_FORM	equ	14
AES_GBOUND	equ	15
appl_getinfo	macro	; ap_gtype
	move.w	\1,int_in
	aes	130
	endm
*********** END OF AES *************
