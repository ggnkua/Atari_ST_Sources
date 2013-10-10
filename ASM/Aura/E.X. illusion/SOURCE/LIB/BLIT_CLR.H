	IFND	BLIT_CLR				; Nur einbinden, wenn es bisher noch
									; nicht eingebunden ist.
BLIT_CLR	EQU		$0100

BC_START	EQUR	a0
BC_END		EQUR	a1

BCLR		MACRO
			lea		\1,BC_START
			lea		\2,BC_END
			bsr.w	BLITTER_CLR
			ENDM

BLITTER_CLR:
			INLINE	"BLIT_CLR.INC"
	ENDIF