		IFND	INIT_HLINES4
INIT_HLINES4		EQU		$0102

; FEHLERKOR: Keine énderung ohne Neuassemblierung.
FEHLERKOR		EQU		0		; Fehlerkorrektur (0=an) (ein "bne.s" / SHLine)

H16_X_MAX		EQU		400		; { NICHT OHNE NEUASSEMBLIERUNG éNDERBAR !
H16_Y_MAX		EQU		280		; |
H16_X_AKT		EQU		320		; }

.hl16_base:		INLINE	"HLINE_4.INC"

H16_BUILD		EQU		.hl16_base		; HLines generieren.
H16_OFF_TAB		EQU		.hl16_base+4	; Offsettabellen.

; H16_BUILD:
H16_ROUTBUF		EQUR	a0		; Buffer fÅr HLine-Coder (16*260 Bytes)
H16_OFFBUF		EQUR	a1		; Adress- unf Planetab (16*16 Bytes)

; H16_OFF_TAB
H16_LOFF		EQUR	a0		; Linkes Offsetarray
H16_ROFF		EQUR	a1		; Rechtes	  "
H16_LINOFF		EQUR	a2		; Scanlineoffsettab.
		ENDIF