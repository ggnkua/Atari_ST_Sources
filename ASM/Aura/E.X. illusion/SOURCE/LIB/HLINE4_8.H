		IFND	INIT_HLINES8
INIT_HLINES8	EQU		$0200

		IFND	FEHLERKOR		; Wenn nicht schon durch "hlines4" eingeb.
FEHLERKOR		EQU		0		; Fehlerkorrektur (0=an) (ein "bne.s" / SHLine)

H16_X_MAX		EQU		320		; { NICHT OHNE NEUASSEMBLIERUNG ŽNDERBAR !
;H16_Y_MAX		EQU		240		; |
H16_X_AKT		EQU		320		; }
		ENDIF

.hl162_base:	INLINE	"HLINE4_8.INC"

H4_8_BUILD		EQU		.hl162_base		; HLines generieren.
H4_8_OFF_TAB	EQU		.hl162_base+4	; Offsettabellen.

				INCLUDE	"HLINE4.HH"		; Registerdefs kombiniert mit hlines4_8
		ENDIF
