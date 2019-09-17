* an include file for inclusion when GEM calls are required

* the AES function id codes
APPL_INIT	equ	10
APPL_READ	equ	11
APPL_WRITE	equ	12
APPL_FIND	equ	13
APPL_TPLAY	equ	14
APPL_TRECORD	equ	15
APPL_EXIT	equ	19
EVNT_KEYBD	equ	20
EVNT_BUTTON	equ	21
EVNT_MOUSE	equ	22
EVNT_MESAG	equ	23
EVNT_TIMER	equ	24
EVNT_MULTI	equ	25
EVNT_DCLICK	equ	26
MENU_BAR	equ	30
MENU_ICHECK	equ	31
MENU_IENABLE	equ	32
MENU_TNORMAL	equ	33
MENU_TEXT	equ	34
MENU_REGISTER	equ	35
OBJC_ADD	equ	40
OBJC_DELETE	equ	41
OBJC_DRAW	equ	42
OBJC_FIND	equ	43
OBJC_OFFSET	equ	44
OBJC_ORDER	equ	45
OBJC_EDIT	equ	46
OBJC_CHANGE	equ	47
FORM_DO		equ	50
FORM_DIAL	equ	51
FORM_ALERT	equ	52
FORM_ERROR	equ	53
FORM_CENTER	equ	54
GRAF_RUBBERBOX 	equ	70
GRAF_DRAGBOX	equ	71
GRAF_MOVEBOX	equ	72
GRAF_GROWBOX	equ	73
GRAF_SHRINKBOX	equ	74
GRAF_WATCHBOX	equ	75
GRAF_SLIDEBOX	equ	76
GRAF_HANDLE	equ	77
GRAF_MOUSE	equ	78
GRAF_MKSTATE	equ	79
SCRP_READ	equ	80
SCRP_WRITE	equ	81
FSEL_INPUT	equ	90
WIND_CREATE	equ	100
WIND_OPEN	equ	101
WIND_CLOSE	equ	102
WIND_DELETE	equ	103
WIND_GET	equ	104
WIND_SET	equ	105
WIND_FIND	equ	106
WIND_UPDATE	equ	107
WIND_CALC	equ	108
RSRC_LOAD	equ	110
RSRC_FREE	equ	111
RSRC_GADDR	equ	112
RSRC_SADDR	equ	113
RSRC_OBFIX	equ	114
SHEL_READ	equ	120
SHEL_WRITE	equ	121
SHEL_FIND	equ	124
SHEL_ENVRN	equ	125

* this is the list of Control parameters for the AES calls
* contains control(1..3), comment is the function number
* (an asterisk indicates it is not defined)
gem_list	dc.b 0,1,0	10
		dc.b 2,1,1	11
		dc.b 2,1,1	12
		dc.b 0,1,1	13
		dc.b 2,1,1	14
		dc.b 1,1,1	15
		dc.b 0,0,0	16*
		dc.b 0,0,0	17*
		dc.b 0,0,0	18*
		dc.b 0,1,0	19
		dc.b 0,1,0	20
		dc.b 3,5,0	21
		dc.b 5,5,0	22
		dc.b 0,1,1	23
		dc.b 2,1,0	24
		dc.b 16,7,1	25
		dc.b 2,1,0	26
		dc.b 0,0,0	27*
		dc.b 0,0,0	28*
		dc.b 0,0,0	29*
		dc.b 1,1,1	30
		dc.b 2,1,1	31
		dc.b 2,1,1	32
		dc.b 2,1,1	33
		dc.b 1,1,2	34
		dc.b 1,1,1	35
		dc.b 0,0,0	36*
		dc.b 0,0,0	37*
		dc.b 0,0,0	38*
		dc.b 0,0,0	39*
		dc.b 2,1,1	40
		dc.b 1,1,1	41
		dc.b 6,1,1	42
		dc.b 4,1,1	43
		dc.b 1,3,1	44
		dc.b 2,1,1	45
		dc.b 4,2,1	46
		dc.b 8,1,1	47
		dc.b 0,0,0	48*
		dc.b 0,0,0	49*
		dc.b 1,1,1	50
		dc.b 9,1,0	51
		dc.b 1,1,1	52
		dc.b 1,1,0	53
		dc.b 0,5,1	54
		dc.b 0,0,0	55*
		dc.b 0,0,0	56*
		dc.b 0,0,0	57*
		dc.b 0,0,0	58*
		dc.b 0,0,0	59*
		dc.b 0,0,0	60*
		dc.b 0,0,0	61*
		dc.b 0,0,0	62*
		dc.b 0,0,0	63*
		dc.b 0,0,0	64*
		dc.b 0,0,0	65*
		dc.b 0,0,0	66*
		dc.b 0,0,0	67*
		dc.b 0,0,0	68*
		dc.b 0,0,0	69*
		dc.b 4,3,0	70
		dc.b 8,3,0	71
		dc.b 6,1,0	72
		dc.b 8,1,0	73
		dc.b 8,1,0	74
		dc.b 4,1,1	75
		dc.b 3,1,1	76
		dc.b 0,5,0	77
		dc.b 1,1,1	78
		dc.b 0,5,0	79
		dc.b 0,1,1	80
		dc.b 0,1,1	81
		dc.b 0,0,0	82*
		dc.b 0,0,0	83*
		dc.b 0,0,0	84*
		dc.b 0,0,0	85*
		dc.b 0,0,0	86*
		dc.b 0,0,0	87*
		dc.b 0,0,0	88*
		dc.b 0,0,0	89*
		dc.b 0,2,2	90
		dc.b 0,0,0	91*
		dc.b 0,0,0	92*
		dc.b 0,0,0	93*
		dc.b 0,0,0	94*
		dc.b 0,0,0	95*
		dc.b 0,0,0	96*
		dc.b 0,0,0	97*
		dc.b 0,0,0	98*
		dc.b 0,0,0	99*
		dc.b 5,1,0	100
		dc.b 5,1,0	101
		dc.b 1,1,0	102
		dc.b 1,1,0	103
		dc.b 2,5,0	104
		dc.b 6,1,0	105
		dc.b 2,1,0	106
		dc.b 1,1,0	107
		dc.b 6,5,0	108
		dc.b 0,0,0	109*
		dc.b 0,1,1	110
		dc.b 0,1,0	111
		dc.b 2,1,0	112 ** Control(4)=1 **
		dc.b 2,1,1	113
		dc.b 1,1,1	114
		dc.b 0,0,0	115
		dc.b 0,0,0	116
		dc.b 0,0,0	117
		dc.b 0,0,0	118
		dc.b 0,0,0	119
		dc.b 0,1,2	120
		dc.b 3,1,2	121
		dc.b 0,0,0	122*
		dc.b 0,0,0	123*
		dc.b 0,1,1	124
		dc.b 0,1,3	125

******************************
* GEM routines and constants *
******************************

* a macro to call GEM function given as a parameter
gem		macro
		moveq	#\1,d0		can be Quick as all are<128
		bsr	call_gem
		endm

* initialise the GEM parameter array
set_gem_p	lea	gem_params(a6),a0
		lea	control(a6),a1
		move.l	a1,(a0)+
		lea	global_(a6),a1
		move.l	a1,(a0)+
		lea	int_in(a6),a1
		move.l	a1,(a0)+
		lea	int_out(a6),a1
		move.l	a1,(a0)+
		lea	addr_in(a6),a1
		move.l	a1,(a0)+
		lea	addr_out(a6),a1
		move.l	a1,(a0)
		rts

* call GEM function D0.W - all elements in control[1..4] are set
call_gem	clr.w	-(sp)			last param = 0
		cmp.w	#RSRC_GADDR,d0		is it RSRC_GADDR
		bne.s	call_gem1		no
		addq.w	#1,(sp)			last param = 1
call_gem1	lea	gem_list(pc),a0		address of table
		lea	control(a6),a1		control array
		move.w	d0,(a1)+		store the op code
		sub.w	#10,d0			subtract offset
		mulu	#3,d0			multiply by 3
		add.w	d0,a0			point to the entry
		moveq	#2,d1			init counter
call_gem2	clr.b	(a1)+			clear first byte
		move.b	(a0)+,(a1)+		move a byte
		dbra	d1,call_gem2		loop till done
		move.w	(sp)+,(a1)		pass last param
		lea	gem_params(a6),a1	address of param array
		move.l	a1,d1			address of param array
		move.w	#200,d0			function number
		trap	#2			go do it
		move.w	int_out(a6),d0		returned value (usually)
		rts

* this is the array of pointers to the rest of the AES arrays
gem_params	rs.l	1
		rs.l	1
		rs.l	1
		rs.l	1
		rs.l	1
		rs.l	1
 
* these are the arrays for AES
control		rs.w	5		5 words for control array
global_		rs.b	30		[ 30 bytes for global
int_in		rs.b	32		[ 32 bytes for intin
int_out		rs.w	7		14 bytes for intout
addr_in		rs.l	2		8 bytes for addrin	
addr_out	rs.l	1		4 bytes for addrout
