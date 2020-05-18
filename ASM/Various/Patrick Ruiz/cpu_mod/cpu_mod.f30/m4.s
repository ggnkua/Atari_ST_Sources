
TestM4:	XBIOS	114,2 Dsp_GetProgAbility
	LEA	MODX4V_Ind(PC),A0
	CMPI	#"M4",D0
	SEQ	(A0)
	RTS

MODX4V: ;Les paramŠtres 16b seront sur la pile
	MOVE.B	MODX4V_Ind(PC),D0
	BEQ.S	.x
	LEA	(SP,4),A0
	MOVE	(A0)+,D0
	CMP	.NumeroFonctionMaxi(PC),D0
	BHI.S	.x
	LEA	.TableNombreParam(PC),A1
	MOVE	(A1,D0*2),D1
	LEA	(A0,D1*2),A0
	SUBQ	#1,D1
	BMI.S	.hc
.param	MOVE	-(A0),D2
 ;Ecrire D2 dans le port Host
	LSL.L	#8,D2
	;Non h‚las ...
	;.ae	BTST	#1,DSP_ISR_IVR ;TD Empty
	;	BEQ	.ae
	MOVE.L	D2,DSP_TDH
	DBRA	D1,.param
.hc ;Host Command 10+
	LEA	DSP_ICR_CVR+1,A0
	;Non plus ...
	;.hcp	BTST	#7,(A0)
	;	BNE	.hcp
	MOVEQ	#%10001010,D1 ;HC 10+
	ADD	D0,D1
	MOVE.B	D1,(A0)
.x	RTS
.NumeroFonctionMaxi	DC.W 3
.TableNombreParam:	DC.W 0,2,1,1

InversionV0V1ParDef=(2<<15)/10 ;.2
InversionV2V3ParDef=(4<<15)/10 ;.4
InversionMono=(5<<15)/10       ;.5
