; This file is part of XaAES
; a wrapper function for Pure C calling prog defs

	globl call_pdef

;			a0=APPBLK->ab_code, a1=&PARMBLK
call_pdef:
	movem.l	d2-d7/a2-a5,-(sp)	; + The Pure C's local variables
	move.l	a1,-(sp)		; progdefs are cdecl!!!
	jsr		(a0)
	addq.l	#4,sp
	movem.l	(sp)+,d2-d7/a2-a5
	rts
