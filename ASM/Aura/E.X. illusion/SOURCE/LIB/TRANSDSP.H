	IFND	_TRANS_DSP
_TRANS_DSP		EQU		$0301

dsp_baseadr:	INLINE	"TRANSDSP.INC"

INIT_TRANS_DSP	EQU		dsp_baseadr
TRANS_DSP		EQU		dsp_baseadr+4

; Transformationsroutine (Initialisierung keine Parameter)
DT_TRANS_MODE	EQUR	d0
DT_OFF_SOURCE	EQUR	d1
DT_OFF_DESTIN	EQUR	d2
DT_PARABLOCK	EQUR	a6
	ENDIF