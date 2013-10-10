		IFND	INIT_HLINES4
INIT_HLINES4	EQU		$0200

		IFND	FEHLERKOR
FEHLERKOR		EQU		0		; Fehlerkorrektur (0=an) (ein "bne.s" / SHLine)

H16_X_MAX		EQU		320		; { NICHT OHNE NEUASSEMBLIERUNG ŽNDERBAR !
;H16_Y_MAX		EQU		280		; |
H16_X_AKT		EQU		320		; }
		ENDIF

.hl16_base:		INLINE	"HLINE4_4.INC"

H4_4_BUILD		EQU		.hl16_base		; HLines generieren.
H4_4_OFF_TAB	EQU		.hl16_base+4	; Offsettabellen.

				INCLUDE	"HLINE4.HH"		; Registerdefs kombiniert mit hlines4_8
		ENDIF
