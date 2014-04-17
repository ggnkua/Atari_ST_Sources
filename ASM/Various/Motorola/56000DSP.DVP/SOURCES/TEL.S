	CLR.W	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP #1
	ADDQ.L	#4,SP
	MOVE.L	D0,PILE
	
	MOVE.L	#4096,-(SP)
	MOVE.W	#$48,-(SP)	; M_ALLOC
	TRAP	#1
	ADDQ.L	#6,SP
	TST.W	D0
	BEQ	DSP_ERROR
	MOVE.L	D0,PRG_DSP
	
	MOVE.W	#113,-(SP)	; DSP_RequestUniqueAbility
	TRAP	#14
	ADDQ.L	#2,SP	; en retour D0 contient le numero d'ability

	MOVE.L	PRG_DSP,-(SP)
	MOVE.W	D0,-(SP)
	PEA	DSP_DISC
	MOVE.W	#108,-(SP)	; Dsp_LoadProg
	TRAP	#14
	ADD.L	#12,SP
	
	CMP.W	#-1,D0
	BEQ	DSP_ERROR
	
	MOVE.W	#1,-(SP)
	MOVE.W	#1,-(SP)
	MOVE.W	#137,-(SP)	; DSPTRISTATE
	TRAP	#14
	ADD.L	#6,SP

	MOVE.W	#1,-(SP)
	MOVE.W	#1,-(SP)
	CLR.W	-(SP)
	MOVE.W	#2,-(SP)
	MOVE.W	#3,-(SP)
	MOVE.W	#139,-(SP)	; DEVCONNECT
	TRAP	#14
	ADD.L	#12,SP
	
	MOVE.W	#1,-(SP)
	MOVE.W	#1,-(SP)
	CLR.W	-(SP)
	MOVE.W	#8,-(SP)
	MOVE.W	#1,-(SP)
	MOVE.W	#139,-(SP)	; DEVCONNECT
	TRAP	#14
	ADD.L	#12,SP
	
	MOVE.W	#1,-(SP)
	MOVE.W	#132,-(SP)	; SETMODE
	TRAP	#14
	ADD.L	#4,SP
	
	CLR.L	-(SP)
	MOVE.W	#133,-(SP)	; SETTRACKS
	TRAP	#14
	ADD.L	#6,SP
	
	MOVE.W	#2,-(SP)
	MOVE.W	#4,-(SP)
	MOVE.W	#130,-(SP)	; SOUNDCMD
	TRAP	#14
	ADD.L	#6,SP
	
	MOVE.W	#0,-(SP)
	MOVE.W	#5,-(SP)
	MOVE.W	#130,-(SP)	; SOUNDCMD
	TRAP	#14
	ADD.L	#6,SP
	
	MOVE.L	PRG_DSP,-(SP)
	MOVE.W	#$49,-(SP)	; M_FREE
	TRAP	#1
	ADDQ.L	#6,SP


****************************************************************************
* Attend que le DSP soit pret … recevoir
****************************************************************************
;Envoi_Au_DSP
;	BTST.B	#1,$FFFFA202.W
;	BEQ.S	Envoi_Au_DSP
	
****************************************************************************
* Envoie de la donn‚e
****************************************************************************
;	MOVE.L	#87654321,$FFFFA204.W
;	MOVEQ	#0,D0

****************************************************************************
* Attente d'un envoi du DSP
****************************************************************************
;Re‡oit_Du_DSP
;	BTST.B	#0,$FFFFA202.W
;	BEQ.S	Re‡oit_Du_DSP

****************************************************************************
* Reception de la donn‚e dans D0
****************************************************************************
;	MOVE.L	$FFFFA204.W,D0
;	CMP.L	#12345678,D0
;	BEQ.S	DSP_OK

DSP_ERROR
	MOVEQ	#-1,D0
	BRA.S	FIN
	
DSP_OK	MOVEQ	#0,D0

****************************************************************************
* Fin de l'exemple
****************************************************************************
FIN	MOVE.L	PILE,-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	
	MOVE.L	#0,-(A7)
	TRAP	#1
	
PILE	DC.L	0	

*--------------------------------------------------------------------------		
DSP_DISC		DC.B	"E:\DSP\PHILX.LOD",0
		EVEN
PRG_DSP		DC.L	1
*--------------------------------------------------------------------------		
