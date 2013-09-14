;+
; Macros to set up timeout counter and count down
;-

.macro	TMOUT	val,xreg
	move.l	\val,\xreg
.endm

.macro	CNTDN1	xreg,cont
.a\~:	cmp.b	#96,TCDR
	bge.s	.a\~
.b\~:	cmp.b	#96,TCDR
	blt.s	.b\~
	dbra	\xreg,\cont
.endm

.macro	CNTALL	xreg
.a\~:	cmp.b	#96,TCDR
	bge.s	.a\~
.b\~:	cmp.b	#96,TCDR
	blt.s	.b\~
	dbra	\xreg,.a\~
.endm
