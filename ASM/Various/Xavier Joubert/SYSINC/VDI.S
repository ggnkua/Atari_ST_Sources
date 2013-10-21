;	Fonctions VDI

IMAGE_LEFT	equ	0
IMAGE_CENTER	equ	1
IMAGE_RIGHT	equ	2
IMAGE_TOP	equ	0
IMAGE_BOTTOM	equ	2

OTHER_COLOR	equ	-1

NOJUSTIFY	equ	0
JUSTIFY	equ	1

COLOR_REQUESTED	equ	0
COLOR_ACTUAL	equ	1

GDOS_NONE	equ	-2
GDOS_FNT	equ	'_FNT'
GDOS_FSM	equ	'_FSM'

LOCATOR	equ	1
VALUATOR	equ	2
CHOICE	equ	3
STRING	equ	4

DEV_INSTALLED	equ	1
DEV_MISSING	equ	0

OUTLINE_FONT	equ	1
BITMAP_FONT	equ	0

ALL_WHITE	equ	0
S_AND_D	equ	1
S_AND_NOTD	equ	2
S_ONLY	equ	3
NOTS_AND_D	equ	4
D_ONLY	equ	5
S_XOR_D	equ	6
S_OR_D	equ	7
NOT_SORD	equ	8
NOT_SXORD	equ	9
NOT_D	equ	10
S_OR_NOTD	equ	11
NOT_S	equ	12
NOTS_OR_D	equ	13
NOT_SANDD	equ	14
ALL_BLACK	equ	15

CLIP_OFF	equ	0
CLIP_ON	equ	1

FIS_HOLLOW	equ	0
FIS_SOLID	equ	1
FIS_PATTERN	equ	2
FIS_HATCH	equ	3
FIS_USER	equ	4

PERIMETER_OFF	equ	0
PERIMETER_ON	equ	1

SQUARE	equ	0
ARROWED	equ	1
ROUND	equ	2

SOLID	equ	0
LDASHED	equ	1
DOTTED	equ	2
DASHDOT	equ	3
DASH	equ	4
DASHDOTDOT	equ	5
USERLINE	equ	6

MRKR_DOT	equ	1
MRKR_PLUS	equ	2
MRKR_ASTERISK	equ	3
MRKR_BOX	equ	4
MRKR_CROSS	equ	5
MRKR_DIAMOND	equ	6

VA_TOP	equ	5
VA_ASCENT	equ	2
VA_HALF	equ	1
VA_BASE	equ	0
VA_DESCENT	equ	4
VA_BOTTOM	equ	3

HA_LEFTJUST	equ	0
HA_CENTJUST	equ	1
HA_RIGHTJUST	equ	2

THICKENED	equ	0
LIGHT	equ	1
SKEWED	equ	2
UNDERLINED	equ	3
;OUTLINED	equ	4
;SHADOWED	equ	5

SCREEN_ERROR	equ	1
NO_ERROR	equ	0
CHAR_NOT_FOUND	equ	1
FILE_READERR	equ	8
FILE_OPENERR	equ	9
BAD_FORMAT	equ	10
CACHE_FULL	equ	11
MISC_ERROR	equ	-1

TRACK_NONE	equ	0
TRACK_NORMAL	equ	1
TRACK_TIGHT	equ	2
TRACK_VERYTIGHT	equ	3

SCRATCH_BOTH	equ	0
SCRATCH_BITMAP	equ	1
SCRATCH_NONE	equ	2

MD_REPLACE	equ	1
MD_TRANS	equ	2
MD_XOR	equ	3
MD_ERASE	equ	4

;	Appel fonctions

	TEXT

VQ_GDOS	MACRO
	move	#-2,d0
	trap	#2
	ENDM

V_SET_APP_BUFF	MACRO	buf,nparagraphs
	move.l	\1,_intin+2*0
	move	\2,_intin+2*2
	VDI	#-1,#0,#2,#6
	ENDM

V_OPNWK	MACRO	work_in,handle,work_out
	move.l	\1,a0
	lea	_intin,a1
	moveq	#0,d0
_bcl_v_opnwk1\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_v_opnwk1\@
	move	\2,_contrl+2*6
	VDI	#1,#0,#11
	move.l	\3,a0
	lea	_intout,a1
	moveq	#44,d0
_bcl_v_opnwk2\@	move	(a1)+,(a0)+
	dbra	d0,_bcl_v_opnwk2\@
	lea	_ptsout,a1
	moveq	#12,d0
_bcl_v_opnwk3\@	move	(a1)+,(a0)+
	dbra	d0,_bcl_v_opnwk3\@
	ENDM

V_CLSWK	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#2,#0,#0
	ENDM

V_CLRWK	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#3,#0,#0
	ENDM

V_UPDWK	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#4,#0,#0
	ENDM

VQ_CHCELLS	MACRO	handle,rows,columns
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#1
	move	_intout+2*0,\2
	move	_intout+2*1,\3
	ENDM

V_EXIT_CUR	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#2
	ENDM

V_ENTER_CUR	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#3
	ENDM

V_CURUP	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#4
	ENDM

V_CURDOWN	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#5
	ENDM

V_CURRIGHT	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#6
	ENDM

V_CURLEFT	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#7
	ENDM

V_CURHOME	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#8
	ENDM

V_EEOS	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#9
	ENDM

V_EEOL	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#10
	ENDM

VS_CURADRESS	MACRO	handle,row,column
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#5,#0,#2,#11
	ENDM

V_CURTEXT	MACRO	handle,str
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_intin,a1
	jsr	_vdi_copystring
	VDI	#5,#0,d1,#12
	ENDM

V_RVON	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#13
	ENDM

V_RVOFF	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#14
	ENDM

VQ_CURADRESS	MACRO	handle,row,column
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#15
	move	_intout+2*0,\2
	move	_intout+2*1,\3
	ENDM

VQ_TABSTATUS	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#16
	ENDM

V_HARDCOPY	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#17
	ENDM

V_DSPCUR	MACRO	handle,x,y
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	VDI	#5,#0,#0,#18
	ENDM

V_RMCUR	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#19
	ENDM

V_FORM_ADV	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#20
	ENDM

V_OUTPUT_WINDOW	MACRO	handle,pxy
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#5,#2,#0,#21
	ENDM

V_CLEAR_DISP_LIST	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#22
	ENDM

V_BIT_IMAGE	MACRO	handle,fname,ratio,xscale,yscale,halign,valigne,pxy
	move	\1,_contrl+2*6
	move	\3,_intin+2*0
	move	\4,_intin+2*1
	move	\5,_intin+2*2
	move	\6,_intin+2*3
	move	\7,_intin+2*4
	move.l	\2,a0
	lea	_intin+2*5,a1
	jsr	_vdi_copystring
	move.l	\8,a0
	lea	_ptsin+2*0,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#5,#2,d1,#23
	ENDM

VQ_SCAN	MACRO	handle,grh,passes,alh,apage,div
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#24
	move	_intout+2*0,grh
	move	_intout+2*1,passes
	move	_intout+2*2,alh
	move	_intout+2*3,apage
	move	_intout+2*4,div
	ENDM

V_ALPHA_TEXT	MACRO	handle,str
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_intin+2*0,a1
	jsr	_vdi_copystring
	VDI	#5,#0,d1,#25
	ENDM

VS_PALETTE	MACRO	handle,mode
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#5,#0,#1,#60
	ENDM

VT_RESOLUTION	MACRO	handle,xres,yres,xout,yout
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#5,#0,#2,#81
	move	_intout+2*0,\4
	move	_intout+2*1,\5
	ENDM

VT_AXIS	MACRO	handle,xres,yres,xout,yout
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#5,#0,#2,#82
	move	_intout+2*0,\4
	move	_intout+2*1,\5
	ENDM

VT_ORIGIN	MACRO	handle,xorigin,yorigin
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#5,#0,#2,#83
	ENDM

VQ_TDIMENSIONS	MACRO	handle,xdim,ydim
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#84
	move	_intout+2*0,\2
	move	_intout+2*1,\3
	ENDM

VT_ALIGNMENT	MACRO	handle,dx,dy
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#5,#0,#2,#85
	ENDM

VQP_FILMS	MACRO	handle,films
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#91
	moveq	#125,d0
	move.l	\2,a0
	lea	_intout,a1
_bcl_vqpfilms\@	move.b	(a0)+,(a1)+
	dbra	d0,_bcl_vqpfilms\@
	ENDM

VQP_STATE	MACRO	handle,port,film,lightness,interlace,planes,indexes
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#92
	move	_intout+2*0,\2
	move	_intout+2*1,\3
	move	_intout+2*2,\4
	move	_intout+2*3,\5
	move	_intout+2*4,\6
	lea	_intout+2*5,a0
	move.l	\7,a1
	moveq	#7,d0
_bcl_vqpstate\@	move.l	(a0)+,(a1)+
	dbra	d0,_bcl_vqpstate\@
	ENDM

VSP_STATE	MACRO	handle,port,film,lightness,interlace,planes,indexes
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	move	\4,_intin+2*2
	move	\5,_intin+2*3
	move	\6,_intin+2*4
	lea	_intin+2*5,a1
	move.l	\7,a0
	moveq	#7,d0
_bcl_vststate\@	move.l	(a0)+,(a1)+
	dbra	d0,_bcl_vststate\@
	VDI	#5,#0,#20,#93
	ENDM

VSP_SAVE	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#94
	ENDM

VSP_MESSAGE	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#95
	ENDM

VQP_ERROR	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#5,#0,#0,#96
	ENDM

V_META_EXTENTS	MACRO	handle,xmin,ymin,xmax,ymax
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	move	\4,_ptsin+2*2
	move	\5,_ptsin+2*3
	VDI	#5,#2,#0,#98
	ENDM

V_WRITE_META	MACRO	handle,intin_len,intin,ptsin_len,ptsin
	move	\1,_contrl+2*6
	move.l	\3,a0
	lea	_intin,a0
	move	\2,d0
	subq	#1,d0
_bcl_wrmeta1\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_wrmeta1\@
	move.l	\5,a0
	lea	_ptsin,a0
	move	\4,d0
	subq	#1,d0
_bcl_wrmeta2\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_wrmeta2\@
	VDI	#5,\2,\4,#99
	ENDM

VM_PAGESIZE	MACRO	handle,pwidth,pheight
	move	\1,_contrl+2*6
	clr	_intin+2*0
	move	\2,_intin+2*1
	move	\3,_intin+2*2
	VDI	#5,#0,#2,#99
	ENDM

VM_COORDS	MACRO	handle,xmin,ymin,xmax,ymax
	move	\1,_contrl+2*6
	move	#1,_intin+2*0
	move	\2,_intin+2*1
	move	\3,_intin+2*2
	move	\4,_intin+2*3
	move	\5,_intin+2*4
	VDI	#5,#0,#5,#99
	ENDM

V_BEZ_QUAL	MACRO	handle,percent,actual
	move	\1,_contrl+2*6
	move	#32,_intin+2*0
	move	#1,_intin+2*1
	move	\2,_intin+2*2
	VDI	#5,#0,#3,#99
	move	_intin+2*0,\3
	ENDM

VM_FILENAME	MACRO	handle,fname
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_intin+2*0,a1
	jsr	_vdi_copystring
	VDI	#5,#0,d1,#100
	ENDM

V_FONTINIT	MACRO	fptr
	move.l	\1,_intin
	VDI	#5,#0,#2,#102
	ENDM

V_PGCOUNT	MACRO	handle,numcopies
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#5,#0,#1,#2000
	ENDM

V_PLINE	MACRO	handle,count,pxy
	move	\1,_contrl+2*6
	move.l	\3,a0
	lea	_ptsin,a1
	move	\2,d0
	subq	#1,d0
_bcl_vpline\@	move.l	(a0)+,(a1)+
	dbra	d0,_bcl_vpline\@
	VDI	#6,\2,#0
	ENDM

V_BEZ	MACRO	handle,count,pxy,bezarr,extent,totpts,totmoves
	movem.l	a2-a3,-(sp)
	move	\1,_contrl+2*6
	move.l	\3,a0
	move.l	\4,a2
	lea	_intin,a3
	lea	_ptsin,a1
	moveq	#0,d1
	move	\2,d0
	subq	#1,d0
_bcl_vbez1\@	move.b	(a2)+,d1
	move	d1,(a3)+
	move.l	(a0)+,(a1)+
	dbra	d0,_bcl_vbez1\@
	move	\2,d0
	addq	#1,d0
	asr	#1,d0
	VDI	#6,\2,d0,#13
	move	_intout+2*0,\6
	move	_intout+2*1,\7
	lea	_ptsout,a0
	move.l	\5,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l	(sp)+,a2-a3
	ENDM

V_PMARKER	MACRO	handle,count,pxy
	move	\1,_contrl+2*6
	move.l	\3,a0
	lea	_ptsin,a1
	move	\2,d0
	subq	#1,d0
.bcl_vpmarker	move.l	(a0)+,(a1)+
	dbra	d0,.bcl_vpmarker
	VDI	#7,\2,#0
	ENDM

V_GTEXT	MACRO	handle,x,y,str
	move	\1,_contrl+2*6
	move.l	\4,a0
	lea	_intin,a1
	jsr	_vdi_copystring
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	VDI	#8,#1,d1
	ENDM

V_FILLAREA	MACRO	handle,count,pxy
	move	\1,_contrl+2*6
	move	\2,d0
	move.l	\3,a0
	lea	_ptsin,a1
	subq	#1,d0
.bcl_vfillarea	move.l	(a0)+,(a1)+
	dbra	d0,.bcl_vfillarea
	VDI	#9,\2,#0
	ENDM

V_BEZ_FILL	MACRO
	ENDM

V_CELLARRAY	MACRO
	ENDM

V_BAR	MACRO	handle,pxy
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#11,#2,#0,#1
	ENDM

V_ARC	MACRO	handle,x,y,radius,startangle,endangle
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	clr.l	_ptsin+2*2
	clr.l	_ptsin+2*4
	move	\4,_ptsin+2*6
	clr	_ptsin+2*7
	move	\5,_intin+2*0
	move	\6,_intin+2*1
	VDI	#11,#4,#2,#2
	ENDM

V_PIESLICE	MACRO	handle,x,y,radius,startangle,endangle
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	clr.l	_ptsin+2*2
	clr.l	_ptsin+2*4
	move	\4,_ptsin+2*6
	clr	_ptsin+2*7
	move	\5,_intin+2*0
	move	\6,_intin+2*1
	VDI	#11,#4,#2,#3
	ENDM

V_CIRCLE	MACRO	handle,x,y,radius
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	clr.l	_ptsin+2*2
	move	\4,_ptsin+2*4
	clr	_ptsin+2*5
	VDI	#11,#3,#0,#4
	ENDM

V_ELLIPSE	MACRO	handle,x,y,xradius,yradius
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	move	\4,_ptsin+2*2
	move	\5,_ptsin+2*3
	VDI	#11,#2,#0,#5
	ENDM

V_ELLARC	MACRO	handle,x,y,xradius,yradius,startangle,endangle
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	move	\4,_ptsin+2*2
	move	\5,_ptsin+2*3
	move	\6,_intin+2*0
	move	\7,_intin+2*1
	VDI	#11,#2,#2,#6
	ENDM

V_ELLPIE	MACRO	handle,x,y,xradius,yradius,startangle,endangle
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	move	\4,_ptsin+2*2
	move	\5,_ptsin+2*3
	move	\6,_intin+2*0
	move	\7,_intin+2*1
	VDI	#11,#2,#2,#7
	ENDM

V_RBOX	MACRO	handle,pxy
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#11,#2,#0,#8
	ENDM

V_RFBOX	MACRO	handle,pxy
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#11,#2,#0,#9
	ENDM

V_JUSTIFIED	MACRO	handle,x,y,str,length,wflag,cflag
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	move	\5,_ptsin+2*2
	clr	_ptsin+2*3
	move	\6,_intin+2*0
	move	\7,_intin+2*1
	move.l	\4,a0
	lea	_intin+2*2,a1
	jsr	_vdi_copystring
	VDI	#11,#2,d1,#10
	ENDM

V_BEZ_OFF	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#11,#0,#0,#13
	ENDM

V_BEZ_ON	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#11,#1,#0,#13
	ENDM

VST_HEIGHT	MACRO	handle,height,wchar,hchar,wcell,hcell
	move	\1,_contrl+2*6
	clr	_ptsin+2*0
	move	\2,_ptsin+2*1
	VDI	#12,#1,#0
	move	_ptsout+2*0,\3
	move	_ptsout+2*1,\4
	move	_ptsout+2*2,\5
	move	_ptsout+2*3,\6
	ENDM

VST_ROTATION	MACRO	handle,angle
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#13,#0,#1
	ENDM

VS_COLOR	MACRO	handle,color,rgb
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move.l	\3,a0
	lea	_intin+2*1,a1
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	VDI	#14,#0,#4
	ENDM

VSL_TYPE	MACRO	handle,type
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#15,#0,#1
	ENDM

VSL_WIDTH	MACRO	handle,width
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#16,#0,#1
	ENDM

VSL_COLOR	MACRO	handle,color
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#17,#0,#1
	ENDM

VSM_TYPE	MACRO	handle,type
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#18,#0,\2
	ENDM

VSM_HEIGHT	MACRO	handle,size
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#19,#0,#1
	ENDM

VSM_COLOR	MACRO	handle,color
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#20,#0,#1
	ENDM

VST_FONT	MACRO	handle,index
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#21,#0,#1
	ENDM

VST_COLOR	MACRO	handle,color
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#22,#0,#1
	ENDM

VSF_INTERIOR	MACRO	handle,interior
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#23,#0,\2
	ENDM

VSF_STYLE	MACRO	handle,style
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#24,#0,#1
	ENDM

VSF_COLOR	MACRO	handle,color
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#25,#0,#1
	ENDM

VQ_COLOR	MACRO	handle,index,flag,rgb
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#26,#0,#2
	lea	_intout,a0
	move.l	\4,a1
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	ENDM

VQ_CELLARRAY	MACRO
	ENDM

VRQ_LOCATOR	MACRO
	ENDM

VSM_LOCATOR	MACRO
	ENDM

VRQ_VALUATOR	MACRO
	ENDM

VSM_VALUATOR	MACRO
	ENDM

VRQ_CHOICE	MACRO
	ENDM

VSM_CHOICE	MACRO
	ENDM

VRQ_STRING	MACRO
	ENDM

VSM_STRING	MACRO
	ENDM

VSWR_MODE	MACRO	handle,mode
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#32,#0,#1
	ENDM

VSIN_MODE	MACRO	handle,device,mode
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#33,#0,#2
	ENDM

VQL_ATTRIBUTES	MACRO	handle,attr
	move	\1,_contrl+2*6
	VDI	#35,#0,#0
	lea	_intout,a0
	move.l	\2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDM

VQM_ATTRIBUTES	MACRO	handle,attr
	move	\1,_contrl+2*6
	VDI	#36,#0,#0
	lea	_intout,a0
	move.l	\2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	ENDM

VQF_ATTRIBUTES	MACRO	handle,attr
	move	\1,_contrl+2*6
	VDI	#37,#0,#0
	lea	_intout,a0
	move.l	\2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	ENDM

VQT_ATTRIBUTES	MACRO	handle,attr
	move	\1,_contrl+2*6
	VDI	#38,#0,#0
	lea	_intout,a0
	move.l	\2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDM

VST_ALIGNMENT	MACRO	handle,halign,valign,hout,vout
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#39,#0,#2
	move	_intout+2*0,\4
	move	_intout+2*1,\5
	ENDM

V_OPNVWK	MACRO	work_in,handle,work_out
	move	\2,_contrl+2*6
	move.l	\1,a0
	lea	_intin,a1
	moveq	#10,d0
_bcl_vopnvwk1\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vopnvwk1\@
	VDI	#100,#0,#11
	move	_contrl+2*6,\2
	lea	_intout,a0
	move.l	\3,a1
	moveq	#44,d0
_bcl_vopnvwk2\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vopnvwk2\@
	lea	_ptsout,a0
	moveq	#12,d0
_bcl_vopnvwk3\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vopnvwk3\@
	ENDM

V_CLSVWK	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#101,#0,#0
	ENDM

VQ_EXTND	MACRO	handle,mode,work_out
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#102,#0,#1
	move.l	\3,a1
	lea	_intout,a0
	move.l	\3,a1
	moveq	#44,d0
_bcl_vqextnd1\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vqextnd1\@
	lea	_ptsout,a0
	moveq	#12,d0
_bcl_vqextnd2\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vqextnd2\@
	ENDM

V_CONTOURFILL	MACRO	handle,x,y,color
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_ptsin+2*0
	move	\4,_ptsin+2*1
	VDI	#103,#0,#0
	ENDM

VSF_PERIMETER	MACRO	handle,flag
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#104,#0,#1
	ENDM

V_GET_PIXEL	MACRO	handle,x,y,pindex,vindex
	move	\1,_contrl+2*6
	move	\2,_ptsin+2*0
	move	\3,_ptsin+2*1
	VDI	#105,#1,#0
	move	_intout+2*0,\4
	move	_intout+2*1,\5
	ENDM

VST_EFFECTS	MACRO	handle,effects
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#106,#0,#1
	ENDM

VST_POINTS	MACRO	handle,point,wchar,hchar,wcell,hcell
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#107,#0,#1
	move	_ptsout+2*0,\3
	move	_ptsout+2*1,\4
	move	_ptsout+2*2,\5
	move	_ptsout+2*3,\6
	ENDM

VSL_ENDS	MACRO	handle,start,end
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move	\3,_intin+2*1
	VDI	#108,#0,#2
	ENDM

VRO_CPYFM	MACRO	handle,mode,pxy,src,dest
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move.l	\4,_contrl+2*7
	move.l	\5,_contrl+2*9
	VDI	#109,#4,#1
	lea	_intout,a0
	move.l	\3,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDM

VR_TRNFM	MACRO	handle,scr,dest
	move	\1,_contrl+2*6
	move.l	\2,_contrl+2*7
	move.l	\3,_contrl+2*9
	VDI	#110,#0,#0
	ENDM

VSC_FORM	MACRO	handle,newform
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_intin,a1
	moveq	#36,d0
_bcl_vscform\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vscform\@
	VDI	#111,#0,#37
	ENDM

VSF_UDPAT	MACRO	handle,pattern,planes
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_intin,a1
	move	\3,d1
	lsl	#4,d1
	move	d1,d0
	subq	#1,d0
_bcl_vsfudpat\@	move	(a0)+,(a1)+
	dbra	d0,_bcl_vsfudpat\@
	VDI	#112,#0,d1
	ENDM

VSL_UDSTY	MACRO	handle,pattern
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#113,#0,#1
	ENDM

VR_RECFL	MACRO	handle,pxy
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#113,#2,#0
	ENDM

VQIN_MODE	MACRO	handle,dev,mode
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#115,#0,#1
	move	_intout+2*0,\3
	ENDM

VQT_EXTENT	MACRO	handle,str,pts
	move	\1,_contrl+2*6
	move.l	\2,a0
	lea	_intin+2*0,a1
	jsr	_vdi_copystring
	VDI	#116,#0,d1
	lea	_ptsout+2*0,a0
	move.l	\3,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDM

VQT_WIDTH	MACRO	handle,wch,cellw,left,right
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#117,#0,#1
	move	_ptsout+2*0,\3
	move	_ptsout+2*2,\4
	move	_ptsout+2*4,\5
	ENDM

VEX_TIMV	MACRO	handle,timv,old_timv,mpt
	move	\1,_contrl+2*6
	move.l	\2,_contrl+2*7
	VDI	#118,#0,#0
	move.l	_contrl+2*9,\3
	move	_intout+2*0,\4
	ENDM

VST_LOAD_FONTS	MACRO	handle,rsrvd
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#119,#0,#1
	ENDM

VRT_CPYFM	MACRO	handle,mode,pxr,src,dest,colors
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move.l	\6,_intin+2*1
	move.l	\4,_contrl+2*7
	move.l	\5,_contrl+2*9
	VDI	#121,#4,#3
	move.l	\3,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	ENDM

V_SHOW_C	MACRO	handle,reset
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#122,#0,#1
	ENDM

V_HIDE_C	MACRO	handle
	move	\1,_contrl+2*6
	VDI	#123,#0,#0
	ENDM

VQ_MOUSE	MACRO	handle,mb,mx,my
	move	\1,_contrl+2*6
	VDI	#124,#0,#0
	move	_intout+2*0,\1
	move	_ptsout+2*0,\2
	move	_ptsout+2*1,\3
	ENDM

VEX_BUTV	MACRO	handle,butv,old_butv
	move	\1,_contrl+2*6
	move.l	\2,_contrl+2*7
	VDI	#125,#0,#0
	move.l	_contrl+2*9,\3
	ENDM

VEX_MOTV	MACRO	handle,motv,old_motv
	move	\1,_contrl+2*6
	move.l	\2,_contrl+2*7
	VDI	#126,#0,#0
	move.l	_contrl+2*9,\3
	ENDM

VEX_CURV	MACRO	handle,curv,old_curv
	move	\1,_contrl+2*6
	move.l	\2,_contrl+2*7
	VDI	#127,#0,#0
	move.l	_contrl+2*9,\3
	ENDM

VQ_KEY_S	MACRO	handle,status
	move	\1,_contrl+2*6
	VDI	#128,#0,#0
	move	_intout+2*0,\2
	ENDM

VS_CLIP	MACRO	handle,flag,pxy
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	move.l	\3,a0
	lea	_ptsin,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	VDI	#129,#2,#1
	ENDM

VQT_NAME	MACRO	handle,index,fontname
	move	\1,_contrl+2*6
	move	\2,_intin+2*0
	VDI	#130,#0,#1
	lea	_intout+2*1,a0
	move.l	\3,a1
	moveq	#32,d0
_bcl_vqtname\@	move	(a0)+,d1
	move.b	d1,(a1)+
	dbra	d0,_bcl_vqtname\@
	ENDM

VQT_FONTINFO	MACRO	handle,first,last,dist,width,effects
	move	\1,_contrl+2*6
	VDI	#131,#0,#0
	move	_intout+2*0,\2
	move	_intout+2*1,\3
	move	_ptsout+2*0,\5
	move.l	\4,a0
	move	_ptsout+2*1,(a0)+
	move	_ptsout+2*3,(a0)+
	move	_ptsout+2*5,(a0)+
	move	_ptsout+2*7,(a0)+
	move.l	\6,a0
	move	_ptsout+2*2,(a0)+
	move	_ptsout+2*4,(a0)+
	move	_ptsout+2*6,(a0)+
	ENDM

VQT_FONTHEADER	MACRO
	ENDM

VQT_TRACKKERN	MACRO
	ENDM

VQT_PAIRKERN	MACRO
	ENDM

VST_CHARMAP	MACRO
	ENDM

VST_KERN	MACRO
	ENDM

V_GETBITMAP_INFO	MACRO
	ENDM

VQT_F_EXTENT	MACRO
	ENDM

VQT_F_EXTENT16	MACRO
	ENDM

V_FTEXT	MACRO
	ENDM

V_FTEXT16	MACRO
	ENDM

V_FTEXT_OFFSET	MACRO
	ENDM

V_FTEXT_OFFSET16	MACRO
	ENDM

V_KILLOUTLINE	MACRO
	ENDM

V_GETOUTLINE	MACRO
	ENDM

VST_SCRATCH	MACRO
	ENDM

VST_ERROR	MACRO
	ENDM

VST_ARBPT	MACRO
	ENDM

VST_ARBPT32	MACRO
	ENDM

VQT_ADVANCE	MACRO
	ENDM

VQT_ADVANCE32	MACRO
	ENDM

VQT_DEVINFO	MACRO
	ENDM

V_SAVECACHE	MACRO
	ENDM

V_LOADCACHE	MACRO
	ENDM

V_FLUSHCACHE	MACRO
	ENDM

VST_SETSIZE	MACRO
	ENDM

VST_SETSIZE32	MACRO
	ENDM

VST_SKEW	MACRO
	ENDM

VQT_GET_TABLE	MACRO
	ENDM

VQT_CACHE_SIZE	MACRO
	ENDM

VDI	MACRO
	move	\1,_contrl+2*0
	move	\2,_contrl+2*1
	move	\3,_contrl+2*3
	IFEQ	NARG-4
	move	\4,_contrl+2*5
	ENDC
	jsr	_call_vdi
	ENDM

	DATA

_call_vdi	move.l	#_vdipb,d1
	moveq.l	#115,d0
	trap	#2
	rts

_vdi_copystring	moveq	#0,d0
	moveq	#0,d1
_bcl_vcpystr	addq	#1,d1
	move.b	(a0)+,d0
	move	d0,(a1)+
	bne.s	_bcl_vcpystr
	rts

_vdipb	dc.l	_contrl,_intin,_ptsin,_intout,_ptsout

	BSS

_contrl	ds.w	12
_intin	ds.w	256
_ptsin	ds.w	256
_intout	ds.w	128
_ptsout	ds.w	256
