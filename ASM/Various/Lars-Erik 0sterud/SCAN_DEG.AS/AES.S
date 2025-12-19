 OPT O+

;AES Macro library.  (C)-1990 by Terje Vernly
;BSS Section added by Lars-Erik ²sterud  1991

;AES
APPL_INIT	equ 10
APPL_READ	equ 11
APPL_WRITE	equ 12
APPL_FIND	equ 13
APPL_TPLAY	equ 14
APPL_TRECORD	equ 15
APPL_EXIT	equ 19
EVNT_KEYBD	equ 20
EVNT_BUTTON	equ 21
EVNT_MOUSE	equ 22
EVNT_MESAG	equ 23
EVNT_TIMER	equ 24
EVNT_MULTI	equ 25
EVNT_DCLICK	equ 26
MENU_BAR	equ 30
MENU_ICHECK	equ 31
MENU_IENABLE	equ 32
MENU_TNORMAL	equ 33
MENU_TEXT	equ 34
MENU_REGISTER	equ 35
OBJC_ADD	equ 40
OBJC_DELETE	equ 41
OBJC_DRAW	equ 42
OBJC_FIND	equ 43
OBJC_OFFSET	equ 44
OBJC_ORDER	equ 45
OBJC_EDIT	equ 46
OBJC_CHANGE	equ 47
FORM_DO		equ 50
FORM_DIAL	equ 51
FORM_ALERT	equ 52
FORM_ERROR	equ 53
FORM_CENTER	equ 54
GRAF_RUBBERBOX 	equ 70
GRAF_DRAGBOX	equ 71
GRAF_MOVEBOX	equ 72
GRAF_GROWBOX	equ 73
GRAF_SHRINKBOX	equ 74
GRAF_WATCHBOX	equ 75
GRAF_SLIDEBOX	equ 76
GRAF_HANDLE	equ 77
GRAF_MOUSE	equ 78
GRAF_MKSTATE	equ 79
SCRP_READ	equ 80
SCRP_WRITE	equ 81
FSEL_INPUT	equ 90
FSEL_EXINPUT	equ 91
WIND_CREATE	equ 100
WIND_OPEN	equ 101
WIND_CLOSE	equ 102
WIND_DELETE	equ 103
WIND_GET	equ 104
WIND_SET	equ 105
WIND_FIND	equ 106
WIND_UPDATE	equ 107
WIND_CALC	equ 108
RSRC_LOAD	equ 110
RSRC_FREE	equ 111
RSRC_GADDR	equ 112
RSRC_SADDR	equ 113
RSRC_OBFIX	equ 114
SHEL_READ	equ 120
SHEL_WRITE	equ 121
SHEL_FIND	equ 124
SHEL_ENVRN	equ 125

AES	MACRO
	MOVE.W	#\1,D0
	BSR	AES2
	ENDM

AES2	MOVE.W	D0,CONTRL
	SUB.W	#10,D0
	LSL.W	#2,D0
	LEA	AES_CTRL_LIST(PC),A0
	LEA	0(A0,D0.W),A0
	CLR.L	D0
	MOVE.B	(A0),D0
	MOVE.W	D0,CONTRL+2
	MOVE.B	1(A0),D0
	MOVE.W	D0,CONTRL+4
	MOVE.B	2(A0),D0
	MOVE.W	D0,CONTRL+6
	MOVE.B	3(A0),D0
	MOVE.W	D0,CONTRL+8

	MOVE.L	#AESPB,D1
	MOVE.W	#$C8,D0
	TRAP	#2
	RTS

INIT	MACRO
	MOVE.L	A7,A5
	LEA	STACK(PC),A7
	MOVE.L	4(A5),A5
	MOVE.L	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADD.L	#$100,D0
	MOVE.L	D0,-(SP)
	MOVE.L	A5,-(SP)
	MOVE.W	D0,-(SP)
	MOVE.W	#$4A,-(SP)
	TRAP	#1
	ADDA.L	#$C,SP
	AES	APPL_INIT
	MOVE.W	INT_OUT,APPID
	AES	GRAF_HANDLE
	MOVE.W	INT_OUT,GRHANDLE
	ENDM

INITACC	MACRO
	LEA	STACK(PC),A7
	AES	APPL_INIT
	MOVE.W	INT_OUT,APPID
	AES	GRAF_HANDLE
	MOVE.W	INT_OUT,GRHANDLE
	ENDM

AES_CTRL_LIST
	dc.b 0,1,0,0	10
	dc.b 2,1,1,0	11
	dc.b 2,1,1,0	12
	dc.b 0,1,1,0	13
	dc.b 2,1,1,0	14
	dc.b 1,1,1,0	15
	dc.b 0,0,0,0	16*
	dc.b 0,0,0,0	17*
	dc.b 0,0,0,0	18*
	dc.b 0,1,0,0	19
	dc.b 0,1,0,0	20
	dc.b 3,5,0,0	21
	dc.b 5,5,0,0	22
	dc.b 0,1,1,0	23
	dc.b 2,1,0,0	24
	dc.b 16,7,1,0	25
	dc.b 2,1,0,0	26
	dc.b 0,0,0,0	27*
	dc.b 0,0,0,0	28*
	dc.b 0,0,0,0	29*
	dc.b 1,1,1,0	30
	dc.b 2,1,1,0	31
	dc.b 2,1,1,0	32
	dc.b 2,1,1,0	33
	dc.b 1,1,2,0	34
	dc.b 1,1,1,0	35
	dc.b 0,0,0,0	36*
	dc.b 0,0,0,0	37*
	dc.b 0,0,0,0	38*
	dc.b 0,0,0,0	39*
	dc.b 2,1,1,0	40
	dc.b 1,1,1,0	41
	dc.b 6,1,1,0	42
	dc.b 4,1,1,0	43
	dc.b 1,3,1,0	44
	dc.b 2,1,1,0	45
	dc.b 4,2,1,0	46
	dc.b 8,1,1,0	47
	dc.b 0,0,0,0	48*
	dc.b 0,0,0,0	49*
	dc.b 1,1,1,0	50
	dc.b 9,1,0,0	51
	dc.b 1,1,1,0	52
	dc.b 1,1,0,0	53
	dc.b 0,5,1,0	54
	dc.b 0,0,0,0	55*
	dc.b 0,0,0,0	56*
	dc.b 0,0,0,0	57*
	dc.b 0,0,0,0	58*
	dc.b 0,0,0,0	59*
	dc.b 0,0,0,0	60*
	dc.b 0,0,0,0	61*
	dc.b 0,0,0,0	62*
	dc.b 0,0,0,0	63*
	dc.b 0,0,0,0	64*
	dc.b 0,0,0,0	65*
	dc.b 0,0,0,0	66*
	dc.b 0,0,0,0	67*
	dc.b 0,0,0,0	68*
	dc.b 0,0,0,0	69*
	dc.b 4,3,0,0	70
	dc.b 8,3,0,0	71
	dc.b 6,1,0,0	72
	dc.b 8,1,0,0	73
	dc.b 8,1,0,0	74
	dc.b 4,1,1,0	75
	dc.b 3,1,1,0	76
	dc.b 0,5,0,0	77
	dc.b 1,1,1,0	78
	dc.b 0,5,0,0	79
	dc.b 0,1,1,0	80
	dc.b 0,1,1,0	81
	dc.b 0,0,0,0	82*
	dc.b 0,0,0,0	83*
	dc.b 0,0,0,0	84*
	dc.b 0,0,0,0	85*
	dc.b 0,0,0,0	86*
	dc.b 0,0,0,0	87*
	dc.b 0,0,0,0	88*
	dc.b 0,0,0,0	89*
	dc.b 0,2,2,0	90
	dc.b 0,2,3,0	91
	dc.b 0,0,0,0	92*
	dc.b 0,0,0,0	93*
	dc.b 0,0,0,0	94*
	dc.b 0,0,0,0	95*
	dc.b 0,0,0,0	96*
	dc.b 0,0,0,0	97*
	dc.b 0,0,0,0	98*
	dc.b 0,0,0,0	99*
	dc.b 5,1,0,0	100
	dc.b 5,1,0,0	101
	dc.b 1,1,0,0	102
	dc.b 1,1,0,0	103
	dc.b 2,5,0,0	104
	dc.b 6,1,0,0	105
	dc.b 2,1,0,0	106
	dc.b 1,1,0,0	107
	dc.b 6,5,0,0	108
	dc.b 0,0,0,0	109*
	dc.b 0,1,1,0	110
	dc.b 0,1,0,0	111
	dc.b 2,1,0,1	112 
	dc.b 2,1,1,0	113
	dc.b 1,1,1,0	114
	dc.b 0,0,0,0	115
	dc.b 0,0,0,0	116
	dc.b 0,0,0,0	117
	dc.b 0,0,0,0	118
	dc.b 0,0,0,0	119
	dc.b 0,1,2,0	120
	dc.b 3,1,2,0	121
	dc.b 0,0,0,0	122*
	dc.b 0,0,0,0	123*
	dc.b 0,1,1,0	124
	dc.b 0,1,3,0	125

	EVEN
	
;**************************************************************

AESPB		DC.L	CONTRL,GLOBAL,INT_IN,INT_OUT,ADDR_IN,ADDR_OUT

		SECTION	BSS

GRHANDLE	DS.W	1
APPID		DS.W	1

CONTRL		DS.W	11
GLOBAL		DS.W	15

INT_IN		DS.W	128
INT_OUT		DS.W	128
ADDR_IN		DS.W	128
ADDR_OUT	DS.W	128
		DS.L	100
STACK		DS.W	10

		SECTION	TEXT
