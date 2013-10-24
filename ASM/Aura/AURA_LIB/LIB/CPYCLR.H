	IFND  _BMP_ROUT
_BMP_ROUT	EQU	$0100

_bmp_rout_base:
			INLINE	"bmp_rout.inc"

CLR_MEM		EQU		_bmp_rout_base
CPY_MEM		EQU		_bmp_rout_base+2
FILL_MEM	EQU		_bmp_rout_base+4

; CLR_MEM, CPY_MEM
CLR_START	EQUR	a0
CLR_END		EQUR	a1

; FILL_MEM, CPY_MEM
BMP_SOURCE	EQUR	a0
BMP_DESTIN	EQUR	a1
BMP_DESTEND	EQUR	a2
BMP_SIZE	EQUR	d0
	ENDIF