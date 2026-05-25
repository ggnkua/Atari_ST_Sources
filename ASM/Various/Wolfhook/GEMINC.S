
********************
* GEM INCLUDE FILE *
********************

* Source code Copyright (C) 1985 HiSoft. All rights reserved.
* No part of this source may be reproduced, transmitted,
* transcribed, or stored in a retrieval system, or translated
* in any form or by any means without the prior written
* permission of HiSoft.

* HiSoft makes no representations or warranties with respect
* to the contents hereof and specifically disclaims any
* implied warranties or merchantability or fitness for any
* particular purpose.

* feel free to use any or all of the object code

* last changed: 20.1.87

*********************
* MACRO DEFINITIONS *
*********************


* a macro to initialise a program
do_start MACRO
	move.l a7,a5
	lea datastart(pc),a6		data pointer
	lea datalength+4000(a6),a7	my stack pointer
	move.l 4(a5),a5			base page
	move.l $c(a5),d0		text
	add.l $14(a5),d0		data
	add.l $1c(a5),d0		bss
	add.l #$100+datalength+4000,d0	base page length+data space
* firstly we have to give back the memory not required
	move.l d0,-(a7)			length to keep
	move.l a5,-(a7)			start address
	clr.w -(a7)			filler
	move.w #$4a,-(a7)
	trap #1				M_SHRINK
	lea 12(a7),a7
	ENDM

* a macro to call a VDI function given as a parameter
vdi	macro
	move.w #\1,d0		cant be Quick as some are>127
	bsr call_vdi
	endm

* a macro to call GEM function given as a parameter
gem	macro
	moveq #\1,d0		can be Quick as all are<128
	bsr call_gem
	endm



*********************************
* VDI SUBROUTINES AND CONSTANTS *
*********************************

* initialise the VDI parameter block
initvdipars
	lea vdipar(a6),a1
	lea contrl(a6),a0
	move.l a0,(a1)+
	lea intin(a6),a0
	move.l a0,(a1)+
	lea ptsin(a6),a0
	move.l a0,(a1)+
	lea intout(a6),a0
	move.l a0,(a1)+
	lea ptsout(a6),a0
	move.l a0,(a1)+
	rts

* call the vdi, with parameter in d0
* all other parameters have to be set by caller
call_vdi
	move.w d0,contrl(a6)		store the op-code
	lea vdipar(a6),a0
	move.l a0,d1			the parameter block
	moveq #115,d0			the function code
	trap #2
	rts


* VDI function constants
V_OPENWK	equ 1		open workstation		
V_CLSWK		equ 2		close workstation
V_CLRWK		equ 3		clear workstation
V_UPDWK		equ 4		update workstation
V_ESCAPES	equ 5		various
V_PLINE		equ 6		polyline
V_PMARKER	equ 7		polymarker
V_GTEXT		equ 8		text
V_FILLAREA	equ 9		filled area
V_CALLARRAY	equ 10		call array
V_GDP		equ 11		bar,arc,pie,circle,ellipse,round rects, etc
VST_HEIGHT	equ 12		set character height
VST_ROTATION	equ 13		set character baseline vector
VS_COLOR	equ 14		set colour representation
VSL_TYPE	equ 15		set polyline type
VSL_WIDTH	equ 16		set polyline width
VSL_COLOR	equ 17		set ployline colour
VSM_TYPE	equ 18		set polymarker type
VSM_HEIGHT	equ 19		set polymarker height
VSM_COLOR	equ 20		set ploymarker colour
VST_FONT	equ 21		set text face
VST_COLOR	equ 22		set text colour
VSF_INTERIOR	equ 23		set fill interior style
VSF_STYLE	equ 24		set fill style index
VSF_COLOR	equ 25		set fill colour index
VQ_COLOR	equ 26		inquire colour representation
VQ_CELLARRAY	equ 27		inquire cell array
VI_LOCATOR	equ 28		input locator, request/sample
VI_VALUATOR	equ 29		input valuator, request/sample
VI_CHOICE	equ 30		input choice, request/sample
VI_STRING	equ 31		input string, request/sample
VSWR_MODE	equ 32		set writing mode
VSIN_MODE	equ 33		set input mode

VQL_ATTRIBUTES	equ 35	inquire polyline attributes
VQM_ATTRIBUTES	equ 36	inquire plymarker attributes
VQF_ATTRIBUTES	equ 37	inquire fill area attributes
VQT_ATTRIBUTES	equ 38	inquire graphic text
VST_ALIGNMENT	equ 39	set text alignment

V_OPNVWK	equ 100	open virtual workstation
V_CLSVWK	equ 101	close virtual workstation
VQ_EXTND	equ 102	extended inquire
V_CONTOURFILL	equ 103	contour fill
VSF_PERIMETER	equ 104	set fill perimeter
V_GET_PIXEL	equ 105	get pixel
VST_EFFECTS	equ 106	set text effects
VST_POINT	equ 107	set character cell height
VSL_ENDS	equ 108	set polyline end markers
VRO_CPYFM	equ 109	copy rastor
VR_TRN_FM	equ 110	transform form
VSC_FORM	equ 111	set mouse form
VSF_UDPAT	equ 112	set user-defined fill pattern
VSL_UDSTY	equ 113	user defined line pattern
VR_RECFL	equ 114	fill rectangle
VQIN_MODE	equ 115	inquire input mode
VQT_EXTENT	equ 116	inquire text extent
VQT_WIDTH	equ 117	inquire char cell width
VEX_TIMV	equ 118	exchange timer interrupt vector
VST_LOAD_FONTS	equ 119	load fonts
VST_UNLOAD_FONTS	equ 120	unload fonts
VRT_CPYFM	equ 121	copy rastor transparent
V_SHOW_C	equ 122	show cursor
V_HIDE_C	equ 123	hide cursor
VQ_MOUSE	equ 124	sample mouse button
VEX_BUTV	equ 125	exchange button change vector
VEX_MOTV	equ 126	exchange movement vector
VEX_CURV	equ 127	exchange cursor change vector
VQ_KEY_S	equ 128	sample keyboard state
VS_CLIP		equ 129	set clipping rectangle
VQT_NAME	equ 130	inquire face name and index
VQT_FONT_INFO	equ 131	inquire current face information


**********************************
* GEM AES ROUTINES AND CONSTANTS *
**********************************

* the AES functions
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
MENI_IENABLE	equ 32
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


* initialise the GEM array params[0..5]
initgempars
	lea params(a6),a1
	lea control(a6),a0
	move.l a0,(a1)+
	lea global(a6),a0
	clr.l 10(a0)			ap_ptree
	clr.l 14(a0)
	clr.l 18(a0)
	clr.l 22(a0)
	clr.l 26(a0)
	move.l a0,(a1)+
	lea int_in(a6),a0
	move.l a0,(a1)+
	lea int_out(a6),a0
	move.l a0,(a1)+
	lea addr_in(a6),a0
	move.l a0,(a1)+
	lea addr_out(a6),a0
	move.l a0,(a1)+
	rts


* call GEM function D0.W - all elements in control[1..4] are set
call_gem
	move.w d0,control(a6)		store the op code
	sub.w #10,d0
	mulu #3,d0			multiply by 3
	lea gem_ctrl_list(pc),a0
	add.w d0,a0			points to the entry
	moveq #0,d0
	move.b (a0)+,d0
	move.w d0,control+2(a6)		do control(1)
	move.b (a0)+,d0
	move.w d0,control+4(a6)		and control(2)
	move.b (a0)+,d0
	move.w d0,control+6(a6)		and control(3)
	clr.w control+8(a6)		control(4)=0
	cmp.w #RSRC_GADDR,control(a6)
	bne.s c6is0
* this is a special case which has control(4) as 1
	move.w #1,control+8(a6)
c6is0	lea params(a6),a0
	move.l a0,d1			the pointer
	move.w #200,d0			function number
	trap #2
	move.w int_out(a6),d0	usually a returned value
	rts

* this is the list of Control parameters for the AES calls
* contains control(1..3), comment is the function number
* (an asterisk indicates it is not defined)
gem_ctrl_list
	dc.b 0,1,0	10
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


***************************
*       WORKSPACE         *
* always addressed off A6 *
***************************

* this is the array of pointers to the rest of the AES arrays
params		rs.l 6
 	
* these are the arrays for AES
control		rs.w 5
global		rs.b 30
int_in		rs.w 16
int_out		rs.w 7
addr_in		rs.l 2
addr_out	rs.l 1


* these are the VDI arrays, starting with the parameter block
vdipar		rs.l 5

* now the arrays themselves
contrl		rs.w 12
intin		rs.w 30
ptsin		rs.w 30
intout		rs.w 45
ptsout		rs.w 12


