****************************************
***   Peripheral   Pilot   Program   ***
****************************************
***		 VIDEO		     ***
****************************************
	OUTPUT	VIDEO.PPP
; Relative PC routine
; Supervisor mode
; Parameters on the stack
; D0-D2/A0-A2 used

*ENTER/EXIT			0
;		  MemoryAddress.L 2 KB

*SET				1
;			     Type	b0:PPP_VID_SYNC-PPP_VID_MODE
;					b1:PPP_VID_HHT-PPP_VID_HSS
;					b2:PPP_VID_VFT-PPP_VID_VSS
;					b3:PPP_VID_BH-PPP_VID_BL
;					b4:PPP_VID_HJ-PPP_VID_LW
;					b5:PPP_VID_CR
;					(PPP_VID_RES1 PPP_VID_RES2 PPP_RES12)
;					Type=0 wait VBL
;		PPPTableAddress.L

VBLVector=$70

; Memory (2 KB)
VBLVector0=0				;DS.L 1
PPPTable0=VBLVector+4			;DS.W 64+512
SETType=PPPTable0+128+1024		;DS.W 1
PPPTableAddress=SETType+2		;DS.L 1

; PPP Table
PPP_VID_SYNC	=0
PPP_VID_RES1	=PPP_VID_SYNC+2
PPP_VID_RES2	=PPP_VID_RES1+2
PPP_VID_RES12	=PPP_VID_RES2+2  ;Order for writing (0: VID_RES1/VID_RES2)
PPP_VID_CO	=PPP_VID_RES12+2
PPP_VID_MODE	=PPP_VID_CO+2
PPP_VID_HHT	=PPP_VID_MODE+2
PPP_VID_HBB	=PPP_VID_HHT+2
PPP_VID_HBE	=PPP_VID_HBB+2
PPP_VID_HDB	=PPP_VID_HBE+2
PPP_VID_HDE	=PPP_VID_HDB+2
PPP_VID_HSS	=PPP_VID_HDE+2
PPP_VID_VFT	=PPP_VID_HSS+2
PPP_VID_VBB	=PPP_VID_VFT+2
PPP_VID_VBE	=PPP_VID_VBB+2
PPP_VID_VDB	=PPP_VID_VBE+2
PPP_VID_VDE	=PPP_VID_VDB+2
PPP_VID_VSS	=PPP_VID_VDE+2
PPP_VID_BH	=PPP_VID_VSS+2
PPP_VID_BM	=PPP_VID_BH+2
PPP_VID_BL	=PPP_VID_BM+2
PPP_VID_HJ	=PPP_VID_BL+2
PPP_VID_VJ	=PPP_VID_HJ+2
PPP_VID_LW	=PPP_VID_VJ+2
PPP_VID_CR	=PPP_VID_LW+2

VIDEO:	LEA	(SP,4),A0
	MOVE	(A0)+,D0
	BMI.S	.x
	CMPI	#1,D0
	BHI.S	.x
	MOVE.B	INITInd(PC),D1
	BNE.S	.1
	TST	D0
	BNE.S	.x
.1	LEA	FunctionTable(PC),A1
	MOVE	(A1,D0.W*2),D0
	LEA	ENTER_EXIT(PC),A1
	JMP	(A1,D0) ;A0=Parameters
.x	RTS

ReadVIDEO:
	ORI	#$700,SR
	MOVEM.L D0-D2/A0-A2,-(SP)
 ;Compatibility bit for later
	PW	#-1
	XBIOS	88,4
	BTST	#7,D0
	SNE	D0
	EXT	D0
	MOVEA.L M_Address(PC),A2
	LEA	PPPTable0(A2),A0
	MOVE	VID_SYNC,(A0)+
;Init PPP_VID_RES12 and calculate PPP_VID_CR#
;PPP_VID_RES1&$0100  PPP_VID_RES2&$0510  CompBit  PPP_VID_RES12  PPP_VID_CR#
;		  0		      0        0	      0 	  16
;		  0		      0        1	     -1 	  16
;				  $0010 		      0 	 256
;				  $0100 		      0 	   1
;				  $0400 		      0 	   2
;	      $0100		      0 		     -1 	   4
	MOVE	VID_RES1,D1
	MOVE	D1,(A0)+
	MOVE	VID_RES2,D2
	MOVE	D2,(A0)+
	ANDI	#$0100,D1
	LSR	#8,D1
	ANDI	#$0510,D2
	OR	D2,D1	;%-----1-T---8---2 (4)
	BEQ.S	.res12
	TST	D2
	SEQ	D0
	EXT	D0
.res12	MOVE	D0,(A0)+
	LEA	ColorCountTable(PC),A1
	BFFFO	D1{21:11},D2
	SUBI	#21,D2
	MOVE	(A1,D2.W*2),D2
	SUBQ	#1,D2	;for later
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
	TST	D0
	BNE.S	.ST
	LEA	VID_CR00,A1
.cr00	MOVE.L	(A1)+,(A0)+
	DBRA	D2,.cr00
	BRA.S	.x
.ST	LEA	VID_CR0,A1
.cr0	MOVE	(A1)+,(A0)+
	DBRA	D2,.cr0
.x	MOVE.L	VBLVector0(A2),VBLVector
	MOVEM.L (SP)+,D0-D2/A0-A2
	ANDI	#$FBFF,SR
	JMP	([VBLVector])

WriteVIDEO:
	ORI	#$700,SR
	MOVEM.L D0-D2/A0-A3,-(SP)
	MOVEA.L M_Address(PC),A3
	MOVEA.L PPPTableAddress(A3),A0
	MOVE	SETType(A3),D2
	BEQ	.x
.tb0	LSR	#1,D2
	BCS.S	.b0
	ADDA	#PPP_VID_HHT-PPP_VID_SYNC,A0
	BRA.S	.tb1
.b0	MOVE	(A0)+,VID_SYNC
	MOVE	(A0)+,D0
	LEA	VID_RES1,A1
	MOVE	(A0)+,D1
	LEA	VID_RES2,A2
	TST	(A0)+
	BEQ.S	.res
	EXG	D0,D1
	EXG.L	A1,A2
.res	MOVE	D0,(A1)
	MOVE	D1,(A2)
	MOVE	(A0)+,VID_CO
	MOVE	(A0)+,VID_MODE
.tb1	LSR	#1,D2
	BCS.S	.b1
	ADDA	#PPP_VID_VFT-PPP_VID_HHT,A0
	BRA.S	.tb2
.b1	MOVE	(A0)+,VID_HHT
	MOVE	(A0)+,VID_HBB
	MOVE	(A0)+,VID_HBE
	MOVE	(A0)+,VID_HDB
	MOVE	(A0)+,VID_HDE
	MOVE	(A0)+,VID_HSS
.tb2	LSR	#1,D2
	BCS.S	.b2
	ADDA	#PPP_VID_BH-PPP_VID_VFT,A0
	BRA.S	.tb3
.b2	MOVE	(A0)+,VID_VFT
	MOVE	(A0)+,VID_VBB
	MOVE	(A0)+,VID_VBE
	MOVE	(A0)+,VID_VDB
	MOVE	(A0)+,VID_VDE
	MOVE	(A0)+,VID_VSS
.tb3	LSR	#1,D2
	BCS.S	.b3
	ADDA	#PPP_VID_HJ-PPP_VID_BH,A0
	BRA.S	.tb4
.b3	MOVE	(A0)+,VID_BH
	MOVE	(A0)+,VID_BM
	MOVE	(A0)+,VID_BL
.tb4	LSR	#1,D2
	BCS.S	.b4
	ADDA	#PPP_VID_CR-PPP_VID_HJ,A0
	BRA.S	.tb5
.b4	MOVE	(A0)+,VID_HJ
	MOVE	(A0)+,VID_VJ
	MOVE	(A0)+,VID_LW
.tb5	LSR	#1,D2
	BCC.S	.x
.b5	MOVEA.L PPPTableAddress(A3),A1
	LEA	PPP_VID_RES1(A1),A1
	MOVE	(A1)+,D1
	MOVE	(A1)+,D2
	MOVE	(A1)+,D0
	ANDI	#$0100,D1
	LSR	#8,D1
	ANDI	#$0510,D2
	OR	D2,D1	;%-----1-T---8---2 (4)
	LEA	ColorCountTable(PC),A1
	BFFFO	D1{21:11},D2
	SUBI	#21,D2
	MOVE	(A1,D2.W*2),D2
	SUBQ	#1,D2
	TST	D0
	BNE.S	.ST
	LEA	VID_CR00,A1
.cr00	MOVE.L	(A0)+,(A1)+
	DBRA	D2,.cr00
	BRA.S	.x
.ST	LEA	VID_CR0,A1
.cr0	MOVE	(A0)+,(A1)+
	DBRA	D2,.cr0
.x	MOVE.L	VBLVector0(A3),VBLVector
	MOVEM.L (SP)+,D0-D2/A0-A3
	ANDI	#$FBFF,SR
	JMP	([VBLVector])

ENTER:	LEA	M_Address(PC),A1
	MOVE.L	(A0),A2
	MOVE.L	A2,(A1)
	LEA	VBLVector,A0
	MOVE.L	(A0),VBLVector0(A2)
	LEA	ReadVIDEO(PC),A1
	MOVE.L	A1,(A0)
.rv	CMPA.L	(A0),A1
	BEQ	.rv
	LEA	INITInd(PC),A0
	ST	(A0)
	RTS

EXIT:	MOVEA.L M_Address(PC),A2
	PEA	PPPTable0(A2)
	PW	#-1
	PW	#1
	BSR	VIDEO
	ADDQ	#8,SP
	LEA	INITInd(PC),A0
	SF	(A0)
	RTS

ENTER_EXIT:
	MOVE.B	INITInd(PC),D0
	BEQ	ENTER
	BRA	EXIT

SET:	MOVEA.L M_Address(PC),A2
	MOVE	(A0)+,SETType(A2)
	MOVE.L	(A0),PPPTableAddress(A2)
 ;WARNING: The 1 plane mode is rebel
 ;We need an intermediate state (for flushing VIDEL buffer ?)
	MOVEA.L (A0)+,A1
	BTST	#0,SETType+1(A2)
	BEQ.S	.set
	BTST	#2,PPP_VID_RES2(A1) ;1 plane ?
	BEQ.S	.set
	;Intermediate state
		BCLR	#2,PPP_VID_RES2(A1)
		SUBQ	#1,PPP_VID_HDB(A1)
		SUBQ	#5,PPP_VID_HDE(A1)
		LEA	VBLVector,A0
		LEA	WriteVIDEO(PC),A1
		MOVE.L	A1,(A0)
.wv_		CMPA.L	(A0),A1
		BEQ	.wv_
	;Back to the good state
		MOVEA.L PPPTableAddress(A2),A1
		BSET	#2,PPP_VID_RES2(A1)
		ADDQ	#1,PPP_VID_HDB(A1)
		ADDQ	#5,PPP_VID_HDE(A1)
.set	LEA	VBLVector,A0
	LEA	WriteVIDEO(PC),A1
	MOVE.L	A1,(A0)
.wv	CMPA.L	(A0),A1
	BEQ	.wv
.x	RTS

	_D
INITInd DC.B 0
	EVEN
FunctionTable:
	DC.W	ENTER_EXIT-ENTER_EXIT
	DC.W	SET-ENTER_EXIT
M_Address	DS.L	1
ColorCountTable:
	DC.W	2,0,1,0,0,0,256,0,0,0,4,16	;%1-T---8---2 (4)
