	IFND	_TRANS_DSP
_TRANS_DSP		EQU		$0013

dsp_baseadr:	INLINE	"DSP3DSYS.INC"

INIT_TRANS_DSP	EQU		dsp_baseadr		; Installiert DSP
TRANS_DSP		EQU		dsp_baseadr+4	; Transformiert ohne Obj.handler
TRANS_WORLD		EQU		dsp_baseadr+8	; Transformation inkl. Obj.sort.
INIT_PARALLEL	EQU		dsp_baseadr+12	; Installiert Parallelprogramm
FIN_P_PRG		EQU		dsp_baseadr+16	; Beendet Parallelprg.

FINISH_FLAG		EQU		dsp_baseadr+20	; Parallelrout Finish-Flag.
PARALLEL_PRG	EQU		dsp_baseadr+22	; Parallelprogramm installiert ?

; INIT_TRANS_DSP:
DT_INST_ADS		EQUR	d0				; d0 = 0 : Komplettinstallation DSP.

; Transformationsroutine (Initialisierung keine Parameter)
DT_TRANS_MODE	EQUR	d0
DT_OFF_SOURCE	EQUR	d1
DT_OFF_DESTIN	EQUR	d2
DT_TRST_ALL		EQUR	d6
DT_PARABLOCK	EQUR	a6

DT_ANZ_FACES	EQUR	d7
DT_DEEPSORT		EQUR	a4
DT_POLYPOINT	EQUR	a5

; <GET_P_PARAS>
DT_ADR_P		EQUR	a6
	ENDIF