	IFND	_MOUSE_SIMPLE
_MOUSE_SIMPLE	EQU		$0120

mausbase:		INLINE	"MOUSE.INC"

; Mausroutinen:
INSTALL_MOUSE	EQU		mausbase+0
DESTALL_MOUSE	EQU		mausbase+4
STOP_MOUSE		EQU		mausbase+8
GO_MOUSE		EQU		mausbase+12
VBL_MOUSE		EQU		mausbase+16

; Variablen (Koordinaten, Tasten, Buttons):
SCANCODE		EQU		mausbase+20
M_BUTTONS		EQU		mausbase+21
MX_ABS			EQU		mausbase+22		; Absolute Koordinaten (.w, *1)
MY_ABS			EQU		mausbase+24
MX_REL			EQU		mausbase+26		; Relative Mauskoordinaten
MY_REL			EQU		mausbase+28

; Installation:
MO_CLIPP_X1		EQUR	d0		; Clippbereich
MO_CLIPP_X2		EQUR	d1
MO_CLIPP_Y1		EQUR	d2
MO_CLIPP_Y2		EQUR	d3
MO_START_X		EQUR	d4		; Absolute Startkoord
MO_START_Y		EQUR	d5		; 			"
; Return:
MOUSE_BLK		EQUR	a0
	ENDIF

; *1 : Abs. Koord. „ndert sich nur, wenn sie im Clippbereich ist.
