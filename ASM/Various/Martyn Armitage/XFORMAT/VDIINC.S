*********************************
* VDI subroutines and constants *
*********************************

* initialise the VDI parameter array
set_vdi_p	lea	vdi_params(a6),a0
		lea	contrl(a6),a1
		move.l	a1,(a0)+
		lea	intin(a6),a1
		move.l	a1,(a0)+
		lea	ptsin(a6),a1
		move.l	a1,(a0)+
		lea	intout(a6),a1
		move.l	a1,(a0)+
		lea	ptsout(a6),a1
		move.l	a1,(a0)
		rts

* call the vdi, with opcode in d0
* all other parameters must be set by caller
call_vdi	move.w	d0,contrl(a6)		store the op-code
		lea	vdi_params(a6),a1	addr of parameter block
		move.l	a1,d1			vdi parameter block
		move.w	#115,d0			the function code
		trap	#2
		rts

*************************
*     VDI WORKSPACE     *
*************************
vdi_params	rs.l	1
		rs.l	1
		rs.l	1
		rs.l	1
		rs.l	1

* now the arrays themselves

contrl		rs.w	20
intin		rs.w	30
ptsin		rs.w	30
intout		rs.w	45
ptsout		rs.w	12

* a macro to call a VDI function given as a parameter
vdi		macro
		move.w	#\1,d0		cant be Quick as some are>127
		bsr	call_vdi
		endm

* VDI function constants
V_OPENWK	equ	1		open workstation		
V_CLSWK		equ	2		close workstation
V_CLRWK		equ	3		clear workstation
V_UPDWK		equ	4		update workstation
V_ESCAPES	equ	5		various
V_PLINE		equ	6		polyline
V_PMARKER	equ	7		polymarker
V_GTEXT		equ	8		text
V_FILLAREA	equ	9		filled area
V_CALLARRAY	equ	10		call array
V_GDP		equ	11		bar,arc,pie,circle,ellipse,round rects, etc
VST_HEIGHT	equ	12		set character height
VST_ROTATION	equ	13		set character baseline vector
VS_COLOR	equ	14		set colour representation
VS_COLUR	equ	14		ditto
VSL_TYPE	equ	15		set polyline type
VSL_WIDTH	equ	16		set polyline width
VSL_COLOR	equ	17		set ployline colour
VSL_COLOUR	equ	17		ditto
VSM_TYPE	equ	18		set polymarker type
VSM_HEIGHT	equ	19		set polymarker height
VSM_COLOR	equ	20		set ploymarker colour
VSM_COLOUR	equ	20		ditto
VST_FONT	equ	21		set text face
VST_COLOR	equ	22		set text colour
VST_COLOUR	equ	22		ditto
VSF_INTERIOR	equ	23		set fill interior style
VSF_STYLE	equ	24		set fill style index
VSF_COLOR	equ	25		set fill colour index
VSF_COLOUR	equ	25		ditto
VQ_COLOR	equ	26		inquire colour representation
VQ_COLOUR	equ	26		ditto
VQ_CELLARRAY	equ	27		inquire cell array
VI_LOCATOR	equ	28		input locator, request/sample
VI_VALUATOR	equ	29		input valuator, request/sample
VI_CHOICE	equ	30		input choice, request/sample
VI_STRING	equ	31		input string, request/sample
VSWR_MODE	equ	32		set writing mode
VSIN_MODE	equ	33		set input mode
VQL_ATTRIBUTES	equ	35		inquire polyline attributes
VQM_ATTRIBUTES	equ	36		inquire plymarker attributes
VQF_ATTRIBUTES	equ	37		inquire fill area attributes
VQT_ATTRIBUTES	equ	38		inquire graphic text
VST_ALIGNMENT	equ	39		set text alignment
V_OPNVWK	equ	100		open virtual workstation
V_CLSVWK	equ	101		close virtual workstation
VQ_EXTND	equ	102		extended inquire
V_CONTOURFILL	equ	103		contour fill
VSF_PERIMETER	equ	104		set fill perimeter
V_GET_PIXEL	equ	105		get pixel
VST_EFFECTS	equ	106		set text effects
VST_POINT	equ	107		set character cell height
VSL_ENDS	equ	108		set polyline end markers
VRO_CPYFM	equ	109		copy rastor
VR_TRN_FM	equ	110		transform form
VSC_FORM	equ	111		set mouse form
VSF_UDPAT	equ	112		set user-defined fill pattern
VSL_UDSTY	equ	113		user defined line pattern
VR_RECFL	equ	114		fill rectangle
VQIN_MODE	equ	115		inquire input mode
VQT_EXTENT	equ	116		inquire text extent
VQT_WIDTH	equ	117		inquire char cell width
VEX_TIMV	equ	118		exchange timer interrupt vector
VST_LOAD_FONTS	equ	119		load fonts
VST_UNLOAD_FONTS	equ 	120	unload fonts
VRT_CPYFM	equ	121		copy rastor transparent
V_SHOW_C	equ	122		show cursor
V_HIDE_C	equ	123		hide cursor
VQ_MOUSE	equ	124		sample mouse button
VEX_BUTV	equ	125		exchange button change vector
VEX_MOTV	equ	126		exchange movement vector
VEX_CURV	equ	127		exchange cursor change vector
VQ_KEY_S	equ	128		sample keyboard state
VS_CLIP		equ	129		set clipping rectangle
VQT_NAME	equ	130		inquire face name and index
VQT_FONT_INFO	equ	131		inquire current face information
