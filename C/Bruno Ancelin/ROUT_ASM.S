	OUTPUT	F:\STMAG\GFA_C.5\ROUT_ASM.O
	XDEF	MULTIPLY

; Listing d'exemple d'int‚gration de routine ASM en C.
; Bruno "zebigbos" ANCELIN / PARX
; (c) STMAG 1995

MULTIPLY
	move.l	d1,-(sp)
	move.w	04+04(sp),d0	Valeur 1
	move.w	04+06(sp),d1	Valeur 2

; Multiplie et met dans D0
	muls.w	d1,d0
	
exit	move.l	(sp)+,d1
; Le r‚sultat sera lu dans D0, retour au C !
	rts
