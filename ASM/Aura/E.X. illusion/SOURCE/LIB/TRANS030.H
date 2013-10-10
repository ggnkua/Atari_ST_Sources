	IFND	TRANS030
TRANS030	EQU		-1

TRA_INIT	EQUR	a0		; Initialisierungstruktur
TRA_PROJEK	EQUR	a6		; Buffer fÅr projezierte Punkte
TRA_WINKEL	EQUR	a5		; Rotationswinkel
TRA_PUNKTE	EQUR	a6		; Urpunktstruktur

_TRANS		EQU		INC_TRANS	; Einsprungadressen
_TRA_INIT	EQU		INC_TRANS+4

INIT_TRA	MACRO
			lea		\1,TRA_INIT
			bsr.w	_TRA_INIT
			ENDM

TRANS		MACRO
			lea		\1,TRA_PROJEK
			lea		\2,TRA_WINKEL
			lea		\3,TRA_PUNKTE
			bsr.w	_TRANS
			ENDM

INC_TRANS:	INLINE	"TRANS030.INC"
	ENDIF