* SOURCE ASM 2, STOPPER LA MUSIQUE
*  … assembler sous MUSSTOP.INL
*            Code : Ric/NAOS

; Adresse du vecteur dans lequel
; a ‚t‚ plac‚e la musique
	MOVE.L	4(SP),A4

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,-(SP)
	
; REACTIVE CLIC CLAVIER
	OR.B	#1,$484.W

; DESINSTALLE LA MUSIQUE
; Supprime le player de la VBL_list
	CLR.L	(A4)
; Coupe le volume sur les 3 voies
; (No de reg. en $FFFF8800.W et
; 0 en $FFFF8802.W)
	MOVE.L	#$08000000,$FFFF8800.W
	MOVE.L	#$09000000,$FFFF8800.W
	MOVE.L	#$0A000000,$FFFF8800.W

	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
; RETOUR AU GFA PAR UN RTS
	RTS
