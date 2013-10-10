; Tests de vitesse d'intstructions
; Chaque instruction est test‚e 40000000 de fois.
; Dur‚e de la boucle : 8 cycles avec 68030 + cache
; Cycles pris par l'instruction : t*0.4-8

	TEXT

	move.l	#40000000,d0
looptst:
;
	moveq	#0,d1		; Instruction … tester
;
	subq.l	#1,d0
	bgt.s	looptst

	clr.w	-(sp)
	trap	#1
