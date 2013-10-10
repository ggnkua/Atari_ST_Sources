; Die Bezeichnungen entsprechen NICHT den Originalen von Chris.
; .BDCa

	IFND	_DSP_PAULA
_DSP_PAULA	EQU		$0230	; $250 buggy ?

pa_dsp_baseadr:	INLINE	"dsppaula.inc"

PAULA_INIT	EQU	pa_dsp_baseadr		; Init
PAULA_IRQ	EQU	pa_dsp_baseadr+4	; Playen
PAULA_EXIT	EQU	pa_dsp_baseadr+8	; Destallieren

; PAULA_INIT:
PA_MODUL	EQUR	a0		; Moduladresse
PA_TIMER_A	EQUR	a1		; Timer-A Adresse (bei Frqz == -1)
PA_PRESCALE	EQUR	d0		; Prescale
PA_ADS		EQUR	d1		; PD_ADS != 0 --> ADS installieren.
PA_VBL_FRQ	EQUR	d2		; VBL-Frequenz (== -1 --> Timer-A)
	ENDIF