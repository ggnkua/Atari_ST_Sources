		IFND	INIT_HLINES18	; HLines auf 8-Plane Screen.
INIT_HLINES18	EQU		$0111

.hl18_base:		INLINE	"HLINE_18.INC"

H18_FILL		EQU		.hl18_base		; HLines generieren.
H18_BUILD		EQU		.hl18_base+2	; Offsettabellen.

; H1_BUILD:
H18_LEFT		EQUR	a0		; Offsetarray links.
H18_RIGHT		EQUR	a1		;		"	  rechts.
		ENDIF