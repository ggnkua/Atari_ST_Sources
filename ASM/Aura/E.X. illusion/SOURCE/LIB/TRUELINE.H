	IFND	V_TRUELINE
V_TRUELINE	EQU		$0100

tl_baseadr:	INLINE	"trueline.inc"

TRUELINE		EQU		tl_baseadr			; Linienroutine
INIT_TRUELINE	EQU		tl_baseadr+4		; Initialisierung

; Initialisierung
CLIPP_X1	EQUR	d0		; Clippbox:	X-Koordinate linker Rand
CLIPP_X2	EQUR	d1		;			X-Koordinate rechter Rand
CLIPP_Y1	EQUR	d2		;			Y-Koordinate oberer Rand
CLIPP_Y2	EQUR	d3		;			Y-Koordinate unterer Rand
SCANLINEOFF	EQUR	a0		; Adresse Scanlineoffsettabelle

; Truelline
X1			EQUR	d0		; P1(x/y)
Y1			EQUR	d1
X2			EQUR	d2		; P2(x/y)
Y2			EQUR	d3
TL_COLOUR	EQUR	d4		; Farbe (16 Bit, 5:6:5)
TL_SCR_BASE	EQUR	a0		; Screenadresse
	ENDIF