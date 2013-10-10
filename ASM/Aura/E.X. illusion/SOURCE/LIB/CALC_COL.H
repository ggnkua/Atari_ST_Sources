	IFND	_CALC_COL
_CALC_COL		EQU		$0112

cc_baseadr:		INLINE	"calc_col.inc"

CALC_PAL_VDI	EQU		cc_baseadr		; Farbverlauf berechnen
CALC_FADE_IN	EQU		cc_baseadr+4	; Fadein berechnen
CALC_FADE_OUT	EQU		cc_baseadr+8	; Fadeout berechnen
VDI_XGA			EQU		cc_baseadr+12	; VDI-Palette nach XGA-Palette
VDI_9800		EQU		cc_baseadr+16	;		"		"  Falcon-Pal.
VDI_8240		EQU		cc_baseadr+20	;		"		"  STE-Palette
CALC_PALS_VDI	EQU		cc_baseadr+24	; Mehrere VerlÑufe berechnen.
CONV_PALS		EQU		cc_baseadr+28	; Mehrere Paletten konvertieren.

; Alle Unterprogramme bis einschlieûlich VDI_8240
STARTCOL		EQUR	a0				; Startfarbe
ENDCOL			EQUR	a1				; Endfarbe
CALC_PAL		EQUR	a2				; Palettenbuffer
COLSTEPS		EQUR	d7				; Anzahl Farben (Schritte)
VDI_PAL			EQUR	a0
DEST_PAL		EQUR	a1

; CALC_PALS_VDI, CONV_PALS
FADE_OUT		EQU		-1				; Modes fÅr CALC_PALS_VDI
FADE_IN			EQU		1
TWO_COLS		EQU		0

_XGA			EQU		0				; Modes fÅr CONV_PALS
_9800			EQU		1
_8240			EQU		2

COL_LIST		EQUR	a0				; Farbenliste
COL_BUF			EQUR	a1				; Palettenbuffer
COL_POINTER		EQUR	a2				; Array fÅr Palettenadressen
COL_MODE		EQUR	d0				; Modus (0-2 Cols,<0=Fade aus,>0=F. in
COL_STEPS		EQUR	d1				; Anzahl Farben in der Palette
COL_ANZ			EQUR	d2				; Anzahl zu berechnende VerlÑufe
	ENDIF