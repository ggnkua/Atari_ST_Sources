****************************************************************************
*       Petit Exemple de Communication 68030-DSP
*       Programme 68030     (Utilisez, de pr‚f‚rence, DEVPAC)
*       Par Axel F. (MCS)
*       Pour ST Magazine
* 
*       Greets to SIMPLET (ABSTRACT)
*          and to NULLOS  (DNT-CREW)
*
****************************************************************************

	MOVE.W	#$20,-(A7)
	TRAP #1
	MOVE.L	D0,PILE
****************************************************************************
* Envoie du programme DSP
****************************************************************************
	MOVE.W	#113,-(A7)	* DSP_RequestUniqueAbility
	TRAP	#14
	ADDQ.W	#2,A7           * en retour D0 contient le numero d'ability

	MOVE.W	D0,-(A7)
	MOVE.L	#(DSP_Code_Fin-DSP_Code_Debut)/3,-(A7)
	PEA	DSP_Code_Debut
	MOVE.W	#109,-(A7)	* Dsp_ExecProg
	TRAP	#14
	ADD.W	#12,A7

****************************************************************************
* Attend que le DSP soit pret … recevoir
****************************************************************************
Envoi_Au_DSP
	BTST.B	#1,$FFFFA202.W
	BEQ.S	Envoi_Au_DSP
	
****************************************************************************
* Envoie de la donn‚e
****************************************************************************
	MOVE.L	#87654321,$FFFFA204.W
	MOVEQ	#0,D0

****************************************************************************
* Attente d'un envoi du DSP
****************************************************************************
Re‡oit_Du_DSP
	BTST.B	#0,$FFFFA202.W
	BEQ.S	Re‡oit_Du_DSP

****************************************************************************
* Reception de la donn‚e dans D0
****************************************************************************
	MOVE.L	$FFFFA204.W,D0
	CMP.L	#12345678,D0
	BEQ.S	DSP_Ok

DSP_Error
	MOVEQ	#-1,D0
	BRA.S	FIN
	
DSP_Ok	MOVEQ	#0,D0

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
DSP_Code_Debut		IncBin	EX_DSP.P56
DSP_Code_Fin
*--------------------------------------------------------------------------		
