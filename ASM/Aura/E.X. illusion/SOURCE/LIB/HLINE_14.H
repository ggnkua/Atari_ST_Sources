		IFND	INIT_HLINES1	; HLines auf 4-Plane Screen.
INIT_HLINES1	EQU		$0111

.hl1_base:		INLINE	"HLINE_14.INC"

H1_FILL			EQU		.hl1_base		; HLines generieren.
H1_BUILD		EQU		.hl1_base+2		; Offsettabellen.

; H1_BUILD:
H1_LEFT			EQUR	a0		; Offsetarray links.
H1_RIGHT		EQUR	a1		;		"	  rechts.
		ENDIF