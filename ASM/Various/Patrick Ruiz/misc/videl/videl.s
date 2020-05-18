****************************************
***  Pilote de configuration video   ***
****************************************
; Routine relogeable
; Mode superviseur
; ParamŠtres sur la pile
; D0-D2/A0-A2 utilis‚s
; 2000 octets de libre … la suite.

	OUTPUT VIDEL.BIN

*EXIT				0

*INIT				1
;	 MyriadStructureAddress.L 0:Current

*PARTIAL INIT			2
;			     Type b0=MVID_BH-MVID_BL
;				  b1=MVID_HJ-MVID_LW
;				  b2=MPHY_C/MVID_RES12/MVID_CR0x-MVID_CRxx
;	 MyriadStructureAddress.L

MDESCRIPTION=0 Structure MYRIAD
MFIP_PROP   =MDESCRIPTION+34
MFIP_LIMG   =MFIP_PROP+4
MFIP_HIMG   =MFIP_LIMG+4
MFIP_NPTR   =MFIP_HIMG+4
MFIP_ICIN   =MFIP_NPTR+2
MFIP_NPCN   =MFIP_ICIN+2
MFIP_NPCI   =MFIP_NPCN+2
MPHY_X	    =MFIP_NPCI+2
MPHY_Y	    =MPHY_X+2
MPHY_W	    =MPHY_Y+2
MPHY_H	    =MPHY_W+2
MPHY_C	    =MPHY_H+2
MPHY_HFREQ  =MPHY_C+2
MPHY_VFREQ  =MPHY_HFREQ+2
MPHY_INTER  =MPHY_VFREQ+2
MPHY_DLINE  =MPHY_INTER+1
MPHY_FULLS  =MPHY_DLINE+1
MTOS_RES    =MPHY_FULLS+2
MVID_SYNC   =MTOS_RES+2
MVID_RES1   =MVID_SYNC+2
MVID_RES2   =MVID_RES1+2
MVID_RES12  =MVID_RES2+2
MVID_CO     =MVID_RES12+2
MVID_MODE   =MVID_CO+2
MVID_HHT    =MVID_MODE+2
MVID_HBB    =MVID_HHT+2
MVID_HBE    =MVID_HBB+2
MVID_HDB    =MVID_HBE+2
MVID_HDE    =MVID_HDB+2
MVID_HSS    =MVID_HDE+2
MVID_VFT    =MVID_HSS+2
MVID_VBB    =MVID_VFT+2
MVID_VBE    =MVID_VBB+2
MVID_VDB    =MVID_VBE+2
MVID_VDE    =MVID_VDB+2
MVID_VSS    =MVID_VDE+2
MVID_BH     =MVID_VSS+2
MVID_BM     =MVID_BH+2
MVID_BL     =MVID_BM+2
MVID_HJ     =MVID_BL+2
MVID_VJ     =MVID_HJ+2
MVID_LW     =MVID_VJ+2
MVID_CR00   =MVID_LW+2

VecteurVBL=$70

VIDEL:	MOVE	(SP,4),D0
	BMI.S	.x
	CMPI	#2,D0
	BHI.S	.x
	MOVE.B	INITInd(PC),D1
	BNE.S	.1
	CMPI	#1,D0
	BNE.S	.x
.1	LEA	TableFct(PC),A0
	MOVE	(A0,D0.W*2),D0
	LEA	EXIT(PC),A0
	JMP	(A0,D0)
.x	RTS

RVIDEL	ORI	#$700,SR
	MOVEM.L D0-D2/A0-A2,-(SP)
	LEA	MStructure0+MVID_SYNC(PC),A0
	MOVE	VID_SYNC,(A0)+
	MOVE	VID_RES1,(A0)+
	MOVE	VID_RES2,(A0)+
	ADDQ	#2,A0
	MOVE	VID_CO,(A0)+
	MOVE	VID_MODE,(A0)+
	MOVE	VID_HHT,(A0)+
	MOVE	VID_HBB,(A0)+
	MOVE	VID_HBE,(A0)+
	MOVE	VID_HDB,(A0)+
	MOVE	VID_HDE,(A0)+
	MOVE	VID_HSS,(A0)+
	MOVE	VID_VFT,(A0)+
	MOVE	VID_VBB,(A0)+
	MOVE	VID_VBE,(A0)+
	MOVE	VID_VDB,(A0)+
	MOVE	VID_VDE,(A0)+
	MOVE	VID_VSS,(A0)+
	MOVE	VID_BH,(A0)+
	MOVE	VID_BM,(A0)+
	MOVE	VID_BL,(A0)+
	MOVE	VID_HJ,(A0)+
	MOVE	VID_VJ,(A0)+
	MOVE	VID_LW,(A0)+
 ;les couleurs
	LEA	VID_CR00,A1
	MOVE	#256-1,D0
.cr00	MOVE.L	(A1)+,(A0)+
	DBRA	D0,.cr00
	LEA	VID_CR0,A1
	MOVEQ	#16-1,D0
.cr0	MOVE	(A1)+,(A0)+
	DBRA	D0,.cr0
	MOVEM.L (SP)+,D0-D2/A0-A2
	ANDI	#$FBFF,SR
	MOVE.L	VecteurVBL0(PC),VecteurVBL
	JMP	([VecteurVBL])

WVIDEL	ORI	#$700,SR
	MOVEM.L D0-D2/A0-A2,-(SP)
	MOVEA.L VecteurMStructure(PC),A0
	ADDA	#MVID_SYNC,A0
	MOVE	(A0)+,VID_SYNC
	MOVE	(A0)+,D1
	MOVE	(A0)+,D2
	MOVE	(A0)+,D0
	LEA	VID_RES1,A1
	LEA	VID_RES2,A2
	TST	D0
	BEQ.S	.wr
	EXG	D1,D2
	EXG.L	A1,A2
.wr	MOVE	D1,(A1)
	MOVE	D2,(A2)
	MOVE	(A0)+,VID_CO
	MOVE	(A0)+,VID_MODE
	MOVE	(A0)+,VID_HHT
	MOVE	(A0)+,VID_HBB
	MOVE	(A0)+,VID_HBE
	MOVE	(A0)+,VID_HDB
	MOVE	(A0)+,VID_HDE
	MOVE	(A0)+,VID_HSS
	MOVE	(A0)+,VID_VFT
	MOVE	(A0)+,VID_VBB
	MOVE	(A0)+,VID_VBE
	MOVE	(A0)+,VID_VDB
	MOVE	(A0)+,VID_VDE
	MOVE	(A0)+,VID_VSS
	MOVE	(A0)+,VID_BH
	MOVE	(A0)+,VID_BM
	MOVE	(A0)+,VID_BL
	MOVE	(A0)+,VID_HJ
	MOVE	(A0)+,VID_VJ
	MOVE	(A0)+,VID_LW
	LEA	VID_CR00,A1
	MOVEA.L VecteurMStructure(PC),A2
	MOVE	MPHY_C(A2),D1
	LEA	TableBitCouleur(PC),A2
.2	MOVE	(A2)+,D2
	BMI.S	.x
	CMP	D1,D2
	BEQ.S	.1
	ADDQ	#2,A2
	BRA	.2
.1	MOVE	(A2),D1
	SUBQ	#1,D1
	SMI	D2 ;Les 2 tables de couleurs … faire
	BPL.S	.3
	MOVEQ	#0,D0
	MOVE	#256-1,D1
.3	TST	D0
	BNE.S	.stcol
.wfc	MOVE.L	(A0)+,(A1)+
	DBRA	D1,.wfc
	TST.B	D2
	BEQ.S	.x
	MOVEQ	#16-1,D1
.stcol	LEA	VID_CR0,A1
.wstc	MOVE	(A0)+,(A1)+
	DBRA	D1,.wstc
.x	MOVEM.L (SP)+,D0-D2/A0-A2
	ANDI	#$FBFF,SR
	MOVE.L	VecteurVBL0(PC),VecteurVBL
	JMP	([VecteurVBL])

INIT:	LEA	VecteurVBL0(PC),A0
	MOVE.L	VecteurVBL,(A0)
	MOVE.B	INITInd(PC),D0
	BNE.S	.SET
;Init VID_RES12
;  RES1   RES2 VID_RES12
;&$0100 &$0510
;     0      0	 BitComp
;	   <>0	       0
;   <>0      0	      -1
	PW	#-1
	PW	#88
	TRAP	#14
	ADDQ	#4,SP
	BTST	#7,D0
	SNE	D0
	EXT	D0
	LEA	MStructure0(PC),A0
	MOVE	VID_RES1,D1
	ANDI	#$0100,D1
	MOVE	VID_RES2,D2
	ANDI	#$0510,D2
	ADD	D2,D1
	BEQ.S	.res12
	TST	D2
	SEQ	D0
	EXT	D0
.res12	MOVE	D0,MVID_RES12(A0)
	LEA	VecteurVBL,A0
	LEA	RVIDEL(PC),A1
	MOVE.L	A1,(A0)
.rv	CMPA.L	(A0),A1
	BEQ	.rv
	LEA	INITInd(PC),A0
	ST	(A0)
.SET	LEA	VecteurMStructure(PC),A0
	MOVE.L	(SP,6),(A0)
	BEQ.S	.x
	MOVEA.L (A0),A2
	LEA	VecteurVBL,A0
	LEA	WVIDEL(PC),A1
 ;Le mode 1 plan est rebelle
 ;Passons alors par un ‚tat interm‚diaire
 ;qui vide le tampon.
	BTST	#2,MVID_RES2(A2) ;1 plan ?
	BEQ.S	.wvid
	;Etat interm‚diaire
		BCLR	#2,MVID_RES2(A2)
		SUBQ	#1,MVID_HDB(A2)
		SUBQ	#5,MVID_HDE(A2)
		MOVE.L	A1,(A0)
.wv_		CMPA.L	(A0),A1
		BEQ	.wv_
	;Revenir au mode voulu
		BSET	#2,MVID_RES2(A2)
		ADDQ	#1,MVID_HDB(A2)
		ADDQ	#5,MVID_HDE(A2)
.wvid	MOVE.L	A1,(A0)
.wv	CMPA.L	(A0),A1
	BEQ	.wv
.x	RTS

EXIT:	PEA	MStructure0(PC)
	PW	#1
	BSR	VIDEL
	ADDQ	#6,SP
	LEA	INITInd(PC),A0
	SF	(A0)
	RTS

WVIDELPartial
	ORI	#$700,SR
	MOVEM.L D0-D2/A0-A2,-(SP)
	MOVEA.L VecteurMStructure(PC),A0
	ADDA	#MVID_BH,A0
	MOVE	INITType(PC),D0
	LSR	#1,D0
	BCS.S	.vidb
	ADDQ	#6,A0
	BRA.S	.tb1
.vidb	MOVE	(A0)+,VID_BH
	MOVE	(A0)+,VID_BM
	MOVE	(A0)+,VID_BL
.tb1	LSR	#1,D0
	BCS.S	.vidh
	ADDQ	#6,A0
	BRA.S	.tb2
.vidh	MOVE	(A0)+,VID_HJ
	MOVE	(A0)+,VID_VJ
	MOVE	(A0)+,VID_LW
.tb2	LSR	#1,D0
	BCC.S	.x
	LEA	VID_CR00,A1
	MOVEA.L VecteurMStructure(PC),A2
	MOVE	MVID_RES12(A2),D0
	MOVE	MPHY_C(A2),D1
	LEA	TableBitCouleur(PC),A2
.2	MOVE	(A2)+,D2
	BMI.S	.x
	CMP	D1,D2
	BEQ.S	.1
	ADDQ	#2,A2
	BRA	.2
.1	MOVE	(A2),D1
	SUBQ	#1,D1
	SMI	D2 ;Les 2 tables de couleurs … faire
	BPL.S	.3
	MOVEQ	#0,D0
	MOVE	#256-1,D1
.3	TST	D0
	BNE.S	.stcol
.wfc	MOVE.L	(A0)+,(A1)+
	DBRA	D1,.wfc
	TST.B	D2
	BEQ.S	.x
	MOVEQ	#16-1,D1
.stcol	LEA	VID_CR0,A1
.wstc	MOVE	(A0)+,(A1)+
	DBRA	D1,.wstc
.x	MOVEM.L (SP)+,D0-D2/A0-A2
	ANDI	#$FBFF,SR
	MOVE.L	VecteurVBL0(PC),VecteurVBL
	JMP	([VecteurVBL])

PARTIALINIT:
	LEA	VecteurVBL0(PC),A0
	MOVE.L	VecteurVBL,(A0)
	LEA	INITType(PC),A0
	MOVE	(SP,6),(A0)
	LEA	VecteurMStructure(PC),A0
	MOVE.L	(SP,8),(A0)
	LEA	VecteurVBL,A0
	LEA	WVIDELPartial(PC),A1
	MOVE.L	A1,(A0)
.wv	CMPA.L	(A0),A1
	BEQ	.wv
	RTS

	D_
INITInd DC.B 0
	EVEN

TableFct:
	DC.W	EXIT-EXIT
	DC.W	INIT-EXIT
	DC.W	PARTIALINIT-EXIT

TableBitCouleur:
	DC.W	0,-1
	DC.W	1,2
	DC.W	2,4
	DC.W	4,16
	DC.W	8,256
	DC.W	16,1
	DC.W	-1 Nil

	M_
VecteurVBL0	DS.L 1
VecteurMStructure	DS.L 1
MStructure0	DS.B 128
		DS.L 255
		DS.W 16
INITType	DS.W 1
