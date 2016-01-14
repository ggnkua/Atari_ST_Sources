	OPT	O+

	 SECTION TEXT


	LEA	4(A7),A5
	MOVE.L	(A5),A5
	MOVE.B	$80(A5),D0
	AND.L	#$FF,D0	
	LEA	$81(A5),A5	* DEBUT DU NOM DU PROGRAMME
	MOVE.L	A5,A6	* FIN
	ADD.L	D0,A6
	CLR.B	(A6)

	CLR.L	-(SP)
	MOVE.W	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	BSR	CLS

	PEA	COPYRIGHT
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.W	-(SP)
	MOVE.L	A5,-(SP)
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.W	D0,HANDLE
	BMI.S	ABORT

	PEA	TEXTE
	MOVE.L	#256*1024,-(SP)
	MOVE.W	HANDLE,-(SP)
	MOVE.W	#$3F,-(SP)
	TRAP	#1
	LEA	12(SP),SP

	MOVE.W	HANDLE,-(SP)
	MOVE.W	#$3E,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP

	BSR	CREATE_FONT
	BSR	PROGRAMME
	MOVE.W	#$2300,SR

ABORT:	PEA	TXT_END
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	MOVE.W	#32,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.W	-(SP)
	TRAP	#1

COPYRIGHT:	DC.B	27,"Y",42,32,"<LE LECTEUR> VERSION 1.0 (C)B.I.S./1993",13,10,0
	EVEN
TXT_END:	DC.B	7,27,"Y",42,32,"-=CODE BY FirSTE/MUSIC BY A FUTUR MEMBER=-",13,10,0
	EVEN

CREATE_FONT:	LEA	FONT,A6
	MOVE.W	#255,D7
.AFF:	PEA	RET
	MOVE.W	#9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.W	#255,D6
	SUB.W	D7,D6
	MOVE.W	D6,-(SP)
	MOVE.W	#5,-(SP)
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.L	$44E.W,A0
	MOVE.B	(A0),(A6)+
	MOVE.B	160(A0),(A6)+
	MOVE.B	320(A0),(A6)+
	MOVE.B	480(A0),(A6)+
	MOVE.B	640(A0),(A6)+
	MOVE.B	800(A0),(A6)+
	MOVE.B	960(A0),(A6)+
	MOVE.B	1120(A0),(A6)+
	DBRA.W	D7,.AFF
	RTS


PROGRAMME:
	LEA	OLD_SP(PC),A0
	LEA	NEW_SP(PC),A1
	MOVE.L	SP,(A0)
	MOVE.L	A1,SP
	BSR.S	SAVEVECTORS

	MOVE.L	#$777,$FFFF8240.W
	BSR	CREATE_FORMAT

	MOVE.W	#1,-(SP)
	PEA	MUSIC
	BSR	ROUTINE

	MOVE.L	#VBL,$70.W
	BSR	DISPLAY
	MOVE.L	#IT_NULL,$70.W

	CLR.W	-(SP)
	CLR.L	-(SP)
	BSR	ROUTINE

	BSR	CLS
	BSR	RESTOREVECTORS
	LEA	OLD_SP(PC),A0
	MOVE.L	(A0),SP
	RTS
SAVEVECTORS:
	LEA	SAVEALL(PC),A6
	LEA	$FFFF8240.W,A0
	LEA	OLDPAL(PC),A1
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,(A1)
	MOVE.W	#$2700,SR
	MOVE.B	$FFFF8260.W,(A6)+
	MOVE.B	$FFFF8201.W,(A6)+
	MOVE.B	$FFFF8203.W,(A6)+
	MOVE.B	$FFFFFA07.W,(A6)+
	MOVE.B	$FFFFFA09.W,(A6)+
	MOVE.B	$FFFFFA13.W,(A6)+
	MOVE.B	$FFFFFA15.W,(A6)+
	MOVE.B	$FFFFFA17.W,(A6)+
	MOVE.B	$FFFFFA19.W,(A6)+
	MOVE.B	$FFFFFA1B.W,(A6)+
	MOVE.L	$68.W,(A6)+
	MOVE.L	$70.W,(A6)+
	MOVE.L	$120.W,(A6)+
	MOVE.L	$134.W,(A6)+
	LEA	IT_NULL(PC),A0
	MOVE.L	A0,$70.W
	MOVEQ.W	#0,D0
	MOVE.B	D0,$FFFFFA07.W
	MOVE.B	D0,$FFFFFA09.W
	MOVE.B	D0,$FFFFFA13.W
	MOVE.B	D0,$FFFFFA15.W
	BCLR.B	#3,$FFFFFA17.W
	STOP	#$2300
	STOP	#$2300
	MOVE.B	#1,$FFFF8260.W
	MOVE.B	#$2,$FFFF820A.W
	RTS
RESTOREVECTORS:
	MOVE.W	#$2700,SR
	MOVEQ.W	#0,D0
	MOVE.B	D0,$FFFFFA07.W
	MOVE.B	D0,$FFFFFA09.W
	MOVE.B	D0,$FFFFFA13.W
	MOVE.B	D0,$FFFFFA15.W
	LEA	IT_NULL(PC),A0
	MOVE.L	A0,$70.W
	LEA	SAVEALL(PC),A6
	STOP	#$2300
	STOP	#$2300
	MOVE.B	(A6)+,$FFFF8260.W
	MOVE.B	(A6)+,$FFFF8201.W
	MOVE.B	(A6)+,$FFFF8203.W
	MOVE.W	#$2700,SR
	MOVE.B	(A6)+,$FFFFFA07.W
	MOVE.B	(A6)+,$FFFFFA09.W
	MOVE.B	(A6)+,$FFFFFA13.W
	MOVE.B	(A6)+,$FFFFFA15.W
	MOVE.B	(A6)+,$FFFFFA17.W
	MOVE.B	(A6)+,$FFFFFA19.W
	MOVE.B	(A6)+,$FFFFFA1B.W
	MOVE.L	(A6)+,$68.W
	MOVE.L	(A6)+,$70.W
	MOVE.L	(A6)+,$120.W
	MOVE.L	(A6)+,$134.W
	LEA	OLDPAL(PC),A0
	LEA	$FFFF8240.W,A1
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,(A1)
KFLUSH:	BTST.B	#0,$FFFFFC00.W
	BEQ.S	KFOK
	MOVE.B	$FFFFFC02.W,D0
	BRA.S	KFLUSH
KFOK:	RTS
SAVEALL:	DS.L	510
NEW_SP:	DC.W	0
OLDPAL:	DS.W	16
OLD_SP:	DC.L	0
IT_NULL:	RTE

VBL:
	MOVEM.L	D0-A6,-(SP)
	CLR.W	$FFFF8240.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB1,$120.W
	BSET	#0,$FFFFFA07.W
	BSET	#0,$FFFFFA13.W
	MOVE.W	CURRENT,D0
	ADDQ.W	#1,D0
	MULU.W	#199,D0
	DIVU	LONG,D0
.0:	CMPI.W	#000,D0
	BNE.S	.200
	MOVE.W	#1,D0
.200:	CMPI.W	#200,D0
	BMI.S	.GO
	MOVE.W	#199,D0
.GO:	MOVE.B	D0,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BSR	ROUTINE+2
	MOVEM.L	(SP)+,D0-A6
	RTE

TB1:	MOVE.W	#$F00,$FFFF8240.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#TB2,$120.W
	MOVE.B	#1,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	RTE

TB2:	CLR.W	$FFFF8240.W
	CLR.B	$FFFFFA1B.W
	RTE

CREATE_FORMAT:	LEA	TEXTE,A0
	CLR.W	D7
	LEA	FORMAT,A1
	MOVE.L	A0,(A1)+
	MOVE.B	(A0),D0
	BEQ.S	.FIN
.SCAN:	CMPI.B	#13,D0
	BNE.S	.2
	CLR.B	-1(A0)
.2:	CMPI.B	#10,D0
	BNE.S	.3
	MOVE.L	A0,(A1)+
	CLR.B	-1(A0)
	ADDQ.W	#1,D7
.3:	MOVE.B	(A0)+,D0
	BNE.S	.SCAN
.FIN:	SUB.W	#24,D7
	MOVE.W	D7,LONG
	LEA	FIN_FORMAT,A0
.CLR:	CMP.L	A0,A1
	BEQ.S	.CONT
	CLR.L	(A1)+
	BRA.S	.CLR
.CONT:	RTS

DISPLAY:	LEA	CURRENT,A0
	CLR.W	(A0)
	BSR	CLS
	BSR	AFF_TXT
.KEY:	MOVE.B	$FFFFFC02.W,D0
	LEA	CURRENT,A0
.LINE_UP:	CMPI.B	#$48,D0
	BNE.S	.LINE_DOWN
	BSR	LDOWN
	MOVE.W	#27,D7
.LU:	STOP	#$2300
	SUBQ.W	#1,D7
	BEQ.S	.SPD_UP
	CMPI.B	#$48,$FFFFFC02.W
	BEQ.S	.LU
	BRA.S	.KEY
.SPD_UP:	BSR	LDOWN
	CMPI.B	#$48,$FFFFFC02.W
	BEQ.S	.SPD_UP
.LINE_DOWN:	CMPI.B	#$50,D0
	BNE.S	.DOWN
	BSR	LUP
	MOVE.W	#27,D7
.LD:	STOP	#$2300
	SUBQ.W	#1,D7
	BEQ.S	.SPD_DOWN
	CMPI.B	#$50,$FFFFFC02.W
	BEQ.S	.LD
	BRA.S	.KEY
.SPD_DOWN:	BSR.S	LUP
	CMPI.B	#$50,$FFFFFC02.W
	BEQ.S	.SPD_DOWN
.DOWN:	CMPI.B	#$4D,D0
	BNE.S	.UP
	ADD.W	#25+24,(A0)
	LEA	FORMAT,A1
.CT0:	MOVE.W	(A0),D0
	AND.L	#$FFFF,D0
	LSL.L	#2,D0
	MOVE.L	(A1,D0),D1
	BNE.S	.CT1
	SUBQ.W	#1,(A0)
	BRA.S	.CT0
.CT1:	SUB.W	#24,(A0)
	BSR	AFF_TXT
.D:	CMPI.B	#$4D,$FFFFFC02.W
	BEQ.S	.D
	BRA	.KEY
.UP:	CMPI.B	#$4B,D0
	BNE.S	.ESC
	SUB.W	#25,(A0)
	BPL.S	.CT2
	CLR.W	(A0)
.CT2:	BSR	AFF_TXT
.U:	CMPI.B	#$4B,$FFFFFC02.W
	BEQ.S	.U
	BRA	.KEY
.ESC:	CMPI.B	#$39,D0
	BNE	.KEY
	RTS

LUP:	LEA	CURRENT,A0
	LEA	FORMAT,A1
	MOVE.W	(A0),D0
	ADD.W	#25,D0
	AND.L	#$FFFF,D0
	LSL.L	#2,D0
	MOVE.L	(A1,D0),D0
	BEQ	.FIN
	MOVE.L	$44E.W,A0
	LEA	8*160(A0),A1
	MOVE.W	#199-8,D0
.CP:	MOVE.W	(A1),(A0)
OFF SET 4
	REPT	39
	MOVE.W	OFF(A1),OFF(A0)
OFF SET OFF+4
	ENDR
	LEA	160(A0),A0
	LEA	160(A1),A1
	DBRA.W	D0,.CP
	MOVE.L	$44E.W,A0
	LEA	(((24*8))*160)(A0),A0
	BSR	CLS_LIN
	LEA	CURRENT,A0
	ADDQ.W	#1,(A0)
	MOVE.W	(A0),D0
	ADD.W	#24,D0
	AND.L	#$FFFF,D0
	LSL.L	#2,D0
	LEA	FORMAT,A0
	MOVE.L	(A0,D0),A0
	MOVE.L	$44E.W,A1
	LEA	(((24*8))*160)(A1),A1
	BSR	AFF_LINE
.FIN:	RTS

LDOWN:	LEA	CURRENT,A0
	LEA	FORMAT,A1
	MOVE.W	(A0),D0
	SUBQ.W	#1,D0
	AND.L	#$FFFF,D0
	LSL.L	#2,D0
	MOVE.L	(A1,D0),D0
	BEQ	.FIN
	MOVE.L	$44E.W,A0
	LEA	((24*8)-1)*160(A0),A0
	LEA	8*160(A0),A1
	MOVE.W	#199-8,D0
.CP:	MOVE.W	(A0),(A1)
OFF SET 4
	REPT	39
	MOVE.W	OFF(A0),OFF(A1)
OFF SET OFF+4
	ENDR
	LEA	-160(A0),A0
	LEA	-160(A1),A1
	DBRA.W	D0,.CP
	MOVE.L	$44E.W,A0
	BSR	CLS_LIN
	LEA	CURRENT,A0
	SUBQ.W	#1,(A0)
	MOVE.W	(A0),D0
	AND.L	#$FFFF,D0
	LSL.L	#2,D0
	LEA	FORMAT,A0
	MOVE.L	(A0,D0),A0
	MOVE.L	$44E.W,A1
	BSR.S	AFF_LINE
.FIN:	RTS

AFF_TXT:	BSR	SPD_CLS
	LEA	CURRENT,A0
	MOVE.W	(A0),D0
	AND.L	#$FFFF,D0
	LSL.L	#2,D0
	LEA	FORMAT,A2
	ADD.L	D0,A2
	MOVE.L	$44E.W,A1
	MOVE.W	#24,D0
.AFF:	MOVE.L	(A2)+,A0
	BSR.S	AFF_LINE
	LEA	160*8(A1),A1
	DBRA.W	D0,.AFF
	RTS

AFF_LINE:	MOVEM.L	D0-A6,-(SP)
	LEA	FONT,A2
.CONT:	MOVE.B	(A0)+,D0
	BEQ.S	.FIN
	AND.W	#$FF,D0
	LSL.W	#3,D0
	MOVE.B	(A2,D0.W),(A1)
	MOVE.B	1(A2,D0.W),160(A1)
	MOVE.B	2(A2,D0.W),320(A1)
	MOVE.B	3(A2,D0.W),480(A1)
	MOVE.B	4(A2,D0.W),640(A1)
	MOVE.B	5(A2,D0.W),800(A1)
	MOVE.B	6(A2,D0.W),960(A1)
	MOVE.B	7(A2,D0.W),1120(A1)
	MOVE.B	(A0)+,D0
	BEQ.S	.FIN
	AND.W	#$FF,D0
	LSL.W	#3,D0
	MOVE.B	(A2,D0.W),1(A1)
	MOVE.B	1(A2,D0.W),161(A1)
	MOVE.B	2(A2,D0.W),321(A1)
	MOVE.B	3(A2,D0.W),481(A1)
	MOVE.B	4(A2,D0.W),641(A1)
	MOVE.B	5(A2,D0.W),801(A1)
	MOVE.B	6(A2,D0.W),961(A1)
	MOVE.B	7(A2,D0.W),1121(A1)
	ADDQ.L	#4,A1
	BRA.S	.CONT
.FIN:	MOVEM.L	(SP)+,D0-A6
	RTS

CLS:	MOVE.L	$44E.W,A0
	MOVE.W	#1999,D0
.CLR:	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	DBRA.W	D0,.CLR
	RTS

SPD_CLS:	MOVE.L	$44E.W,A0
	MOVE.W	#199,D0
.CLR:	CLR.W	(A0)
OFF SET 4
	REPT	39
	CLR.W	OFF(A0)
OFF SET OFF+4
	ENDR
	LEA	160(A0),A0
	DBRA.W	D0,.CLR
	RTS

CLS_LIN:	CLR.W	(A0)
OFF SET 4
	REPT	(8*40)-1
	CLR.W	OFF(A0)
OFF SET OFF+4
	ENDR
	
	RTS

ROUTINE:
*
* ACTIVE:
* -------
* MOVE.W  #PAR,-(SP) *0: STOP / 1: LOOP / 2:NOLOOP
* PEA     MODULE     *MODULE ADRESSE
* JSR ROUTINE
*
* VBL:
* ----
* JSR ROUTINE+2
*
* ROUTINE +9 : 0:STOP / 1:RUN
* ROUTINE +8 : VITESSE (-:RAPIDE/+:LENTE)
* ROUTINE +7 : VOLUME  (-:HAUT/+:BAS)
*
      BRA.S     L0004+1
      BRA.S	 L0009
L0000:DC.B      $FF,$FF 
L0001:DC.B      $FF 
L0002:DC.B      $00 
L0003:DC.B      $00 
L0004:DC.B      $00 
      MOVEM.L   A0-A6/D0-D7,-(A7) 
      LEA       L0064(PC),A1
      TST.W     68(A7)
      BNE.S       L0006 
      *CMPI.B    #$FF,23(A1) 
      *BEQ.S       L0008 
      BSR         L005E 
      BRA.S       L0008 
L0006:MOVEA.L   64(A7),A2 
      MOVE.L    A2,(A1) 
      MOVE.B    69(A7),4(A1)
      LEA       L0066(PC),A3
      CLR.L     (A3)
      LEA       L0067(PC),A3
      CLR.L     (A3)
      LEA       L0068(PC),A3
      CLR.L     (A3)
      LEA       L0063(PC),A3
      CLR.L     8(A3) 
      LEA       L0000(PC),A3
      MOVE.B    #1,5(A3)
      MOVE.B    12(A2),4(A3)
      CLR.W     18(A1)
      MOVE.L    A2,D1 
      ADD.L     (A2),D1 
      MOVE.L    D1,6(A1)
      MOVE.L    A2,D1 
      ADD.L     4(A2),D1
      MOVE.L    D1,10(A1) 
      MOVE.L    A2,D1 
      ADD.L     8(A2),D1
      MOVE.L    D1,14(A1) 
      MOVEQ     #0,D3 
      BSR       L005A 
      *CMPI.B    #$FF,23(A1) 
      *BNE       L0008
      *MOVE.B    #1,23(A1) 
      *MOVE.L    $114.W,38(A1) 
      *LEA       L0009(PC),A3
      *MOVE.L    A3,$114.W 
L0008:MOVEM.L   (A7)+,A0-A6/D0-D7 
      RTS 
L0009:*MOVE.L    L0065(PC),-(A7) 
      *MOVE      SR,-(A7)
      *ANDI.W    #$F4FF,SR 
      MOVEM.L   A1-A6/D1-D5,-(A7) 
      LEA       L0064(PC),A1
      *SUBQ.B    #1,36(A1) 
      *BCC       L0014 
      MOVE.B    #3,36(A1) 
      MOVE.B    L0004(PC),D1
      TST.B     D1
      BEQ       L0014 
      LEA       L0066(PC),A2
      SUBQ.B    #1,19(A1) 
      BCC.S       L0012 
      MOVE.B    L0003(PC),19(A1)
      MOVEQ     #0,D1 
L000A:SUBQ.B    #1,20(A1,D1.W)
      BPL.S       L0011 
      MOVE.W    D1,D2 
      ADD.W     D2,D2 
      ADD.W     D2,D2 
L000B:MOVEA.L   24(A1,D2.W),A3
L000C:MOVEQ     #0,D3 
      MOVE.B    (A3)+,D3
      CMPI.B    #$7F,D3 
      BNE.S       L000D 
      BSR       L0059 
      BRA.S     L000B 
L000D:BTST      #7,D3 
      BEQ.S       L000E 
      ANDI.B    #$7F,D3 
      MOVE.B    D3,20(A1,D1.W)
      BRA.S       L0010 
L000E:BTST      #6,D3 
      BEQ.S       L000F 
      ANDI.B    #$3F,D3 
      ADD.W     D3,D3 
      MOVEA.L   10(A1),A4 
      MOVE.W    0(A4,D3.W),D3 
      ADD.L     (A1),D3 
      MOVE.L    D3,(A2) 
      BRA.S     L000C 
L000F:CLR.B     20(A1,D1.W) 
      BSR.S       L0015 
      BTST      #7,(A3) 
      BNE.B     L000C 
L0010:MOVE.L    A3,24(A1,D2.W)
L0011:LEA       42(A2),A2 
      ADDQ.W    #1,D1 
      CMPI.W    #3,D1 
      BNE.B     L000A 
L0012:LEA       L0066(PC),A2
      LEA       L0063(PC),A1
      MOVEQ     #0,D3 
      MOVEQ     #0,D1 
L0013:BSR       L002A 
      LEA       42(A2),A2 
      ADDQ.W    #1,D1 
      CMPI.W    #3,D1 
      BNE.B     L0013 
      BSR       L005F 
L0014:MOVEM.L   (A7)+,A1-A6/D1-D5 
      RTS
L0015:LEA       L0063(PC),A5
      MOVEA.L   (A2),A4 
      CLR.L     4(A2) 
      CLR.L     18(A2)
      MOVE.W    D1,D4 
      ADDQ.W    #3,D4 
      BSET      D1,7(A5)
      BSET      D4,7(A5)
      MOVE.B    #$FF,22(A2) 
      BTST      #0,(A4) 
      BEQ.S       L0016 
      BCLR      D1,7(A5)
L0016:BTST      #1,(A4) 
      BEQ       L001D 
      BCLR      D4,7(A5)
      MOVE.B    20(A4),23(A2) 
      CMPI.B    #$FF,1(A4)
      BEQ.S       L001D 
      BTST      #2,(A4) 
      BEQ.S       L0017 
      MOVE.B    1(A4),22(A2)
      BRA.S       L001A 
L0017:MOVE.B    D3,D4 
      SUBI.B    #$3E,D4 
      NEG.B     D4
      LSR.B     #1,D4 
      ADD.B     1(A4),D4
      SUBI.B    #$F,D4
      BPL.S       L0018 
      CLR.B     D4
      BRA.S       L0019 
L0018:CMPI.B    #$1F,D4 
      BLE.S       L0019 
      MOVEQ     #$1F,D4 
L0019:MOVE.B    D4,22(A2) 
L001A:MOVE.B    26(A4),38(A2) 
      CLR.B     37(A2)
      MOVE.B    24(A4),39(A2) 
      MOVE.B    22(A4),41(A2) 
      MOVE.B    #1,40(A2) 
      MOVE.B    7(A4),D4
      LSR.B     #4,D4 
      CMPI.B    #3,D4 
      BNE.S       L001B 
      MOVE.B    22(A4),D5 
      ADD.B     D5,D5 
      MOVE.B    D5,40(A2) 
      BRA.S       L001D 
L001B:TST.B     23(A4)
      BNE.S       L001C 
      MOVE.B    #3,40(A2) 
L001C:CMPI.B    #1,D4 
      BNE.S       L001D 
      NEG.B     40(A2)
L001D:MOVE.B    12(A4),D4 
      LSR.B     #4,D4 
      MOVE.B    D4,7(A2)
      MOVE.B    10(A4),25(A2) 
      MOVE.B    7(A4),D4
      ANDI.B    #3,D4 
      CMPI.B    #3,D4 
      BNE.S       L001E 
      MOVE.B    9(A4),D5
      BRA.S       L001F 
L001E:MOVEQ     #1,D5 
      TST.B     8(A4) 
      BNE.S       L001F 
      MOVEQ     #2,D5 
L001F:MOVE.B    D5,26(A2) 
      NEG.B     D5
      MOVE.B    D5,24(A2) 
      CMPI.B    #1,D4 
      BNE.S       L0020 
      NEG.B     26(A2)
L0020:MOVE.B    13(A4),27(A2) 
      MOVEQ     #0,D5 
      MOVE.B    11(A4),D5 
      MOVE.W    D5,28(A2) 
      MOVE.B    7(A4),D4
      LSR.B     #2,D4 
      ANDI.B    #3,D4 
      CMPI.B    #3,D4 
      BNE.S       L0021 
      ADD.W     D5,D5 
      BRA.S       L0022 
L0021:MOVE.B    2(A4),D5
      ADDQ.W    #1,D5 
      CMPI.B    #1,D4 
      BNE.S       L0022 
      NEG.W     D5
L0022:MOVE.W    D5,30(A2) 
      MOVE.B    17(A4),36(A2) 
      MOVEQ     #0,D5 
      MOVE.B    16(A4),D5 
      ADDQ.W    #1,D5 
      CLR.W     32(A2)
      BTST      #6,(A4) 
      BNE.S       L0023 
      NEG.W     D5
      MOVE.W    14(A4),32(A2) 
L0023:MOVE.W    D5,34(A2) 
      LEA       L0069(PC),A5
      BTST      #5,(A4) 
      BNE.S       L0024 
      ADDI.B    #$C,D3
L0024:ADD.W     D3,D3 
      MOVE.W    0(A5,D3.W),8(A2)
      MOVE.B    19(A4),20(A2) 
      MOVEA.L   A4,A6 
      ADDQ.L    #3,A6
      MOVEQ     #0,D4 
      MOVEQ     #0,D5 
L0025:MOVE.B    (A6)+,D5
      CMPI.B    #$FF,D5 
      BNE.S       L0026 
      MOVE.W    #$FF,10(A2,D4.W)
      TST.W     D4
      BEQ.S       L0029 
      BRA.S       L0028 
L0026:ADD.W     D5,D5 
      ADD.W     D3,D5 
      CMPI.W    #$A8,D5 
      BLE.S       L0027 
      MOVE.W    D3,D5 
L0027:MOVE.W    0(A5,D5.W),10(A2,D4.W)
      ADDQ.W    #2,D4 
      CMPI.B    #6,D4 
      BNE.B     L0025 
L0028:BTST      #7,(A4) 
      BEQ.S       L0029 
      MOVE.B    #2,18(A2) 
L0029:RTS 
L002A:TST.L     (A2)
      BEQ       L004A 
      MOVEA.L   (A2),A3 
      MOVE.W    D1,D2 
      ADD.W     D2,D2 
      SUBQ.B    #1,25(A2) 
      BHI.S       L002B 
      BSR       L0054 
L002B:SUBQ.B    #1,4(A2)
      BCC.S       L0031 
      MOVE.B    21(A3),4(A2)
L002C:MOVE.B    6(A2),D3
      MOVE.B    27(A3,D3.W),D3
      CMPI.B    #$FF,D3 
      BNE.S       L0030 
      SUBQ.B    #1,7(A2)
      BMI.S       L002F 
      MOVE.B    12(A3),D3 
      ANDI.B    #$F,D3
      ADD.B     D3,21(A2) 
      CLR.B     6(A2) 
      BTST      #1,(A3) 
      BEQ.S       L002D 
      ADDQ.W    #3,D1 
      BCLR      D1,7(A1)
      SUBQ.W    #3,D1 
      MOVE.B    20(A3),23(A2) 
L002D:CLR.W     32(A2)
      BTST      #6,(A3) 
      BNE.S       L002E 
      MOVE.W    14(A3),32(A2) 
L002E:CLR.B     37(A2)
      MOVE.B    19(A3),20(A2) 
      CLR.B     19(A2)
      BRA.S     L002C 
L002F:CLR.B     7(A2) 
      MOVE.B    #$FF,22(A2) 
      BRA.S      L0031 
L0030:MOVE.B    D3,5(A2)
      ADDQ.B    #1,6(A2)
L0031:MOVE.B    5(A2),D3
      TST.B     24(A2)
      BMI.S       L0032 
      SUB.B     24(A2),D3 
L0032:SUB.B     L0002(PC),D3
      SUB.B     21(A2),D3 
      BPL.S       L0033 
      MOVEQ     #0,D3 
L0033:MOVE.B    D3,8(A1,D1.W) 
      SUBQ.B    #1,27(A2) 
      BCC.S       L0034 
      BSR       L004E 
L0034:SUBQ.B    #1,19(A2) 
      BCC.S       L0039 
      MOVE.B    6(A3),19(A2)
      MOVE.B    18(A2),D3 
      MOVE.W    8(A2,D3.W),16(A2) 
      TST.B     19(A3)
      BEQ.S       L0036 
      TST.B     D3
      BEQ.S       L0035 
      SUBQ.B    #1,20(A2) 
L0035:TST.B     20(A2)
      BEQ.S       L0037 
L0036:ADDQ.B    #2,D3 
      ANDI.B    #7,D3 
      CMPI.W    #$FF,8(A2,D3.W) 
      BNE.S       L0038 
L0037:MOVEQ     #0,D3 
L0038:MOVE.B    D3,18(A2) 
L0039:MOVE.W    16(A2),D4 
      TST.B     36(A2)
      BGT.S       L003B 
      BTST      #3,(A3) 
      BNE.S       L003A 
      SUB.W     32(A2),D4 
      BRA.S      L003B 
L003A:ADD.W     32(A2),D4 
L003B:ADD.W     28(A2),D4 
      MOVE.B    11(A3),D3 
      SUB.W     D3,D4 
      BPL.S       L003C 
      MOVEQ     #0,D4 
      BRA.S      L003D 
L003C:CMPI.W    #$FFF,D4
      BLE.S       L003D 
      MOVE.W    #$FFF,D4
L003D:MOVE.W    D4,14(A1) 
      MOVE.B    D4,0(A1,D2.W) 
      MOVE.B    14(A1),1(A1,D2.W) 
      SUBQ.B    #1,36(A2) 
      BCC.S       L003E 
      BSR       L004B 
L003E:TST.B     20(A3)
      BEQ.S       L003F 
      SUBQ.B    #1,23(A2) 
      BCC.S       L003F 
      CLR.B     23(A2)
      ADDQ.B    #3,D1 
      BSET      D1,7(A1)
      SUBQ.B    #3,D1 
      BRA      L004A 
L003F:CMPI.B    #$FF,22(A2) 
      BEQ       L004A 
      SUBQ.B    #1,39(A2) 
      BHI.S       L0044 
      MOVE.B    24(A3),39(A2) 
      MOVE.B    41(A2),D3 
      MOVE.B    22(A3),D4 
      ADD.B     D4,D4 
      ADD.B     40(A2),D3 
      BPL.S       L0041 
      MOVE.B    7(A3),D5
      LSR.B     #4,D5 
      CMPI.B    #2,D5 
      BNE.S       L0040 
      MOVEQ     #0,D3 
      NEG.B     40(A2)
      BRA.S      L0041 
L0040:MOVE.B    D4,D3 
L0041:CMP.B     D4,D3 
      BLE.S       L0043 
      CMPI.B    #2,D5 
      BNE.S       L0042 
      MOVE.B    D4,D3 
      NEG.B     40(A2)
      BRA.S      L0043 
L0042:MOVEQ     #0,D3 
L0043:MOVE.B    D3,41(A2) 
L0044:MOVE.B    22(A2),D3 
      BTST      #4,(A3) 
      BEQ.S       L0045 
      ADD.B     37(A2),D3 
      BRA.S      L0046 
L0045:SUB.B     37(A2),D3 
L0046:ADD.B     41(A2),D3 
      SUB.B     22(A3),D3 
      BPL.S       L0047 
      MOVEQ     #0,D3 
L0047:CMPI.B    #$1F,D3 
      BLE.S       L0048 
      MOVE.B    #$1F,D3 
L0048:MOVE.B    D3,6(A1)
      SUBQ.B    #1,38(A2) 
      BCC.S       L004A 
      CLR.B     38(A2)
      MOVE.B    37(A2),D4 
      ADD.B     25(A3),D4 
      ADDQ.B    #1,D4 
      CMP.B     18(A3),D4 
      BLE.S       L0049 
      MOVE.B    18(A3),D4 
L0049:MOVE.B    D4,37(A2) 
L004A:RTS 
L004B:CLR.B     36(A2)
      MOVE.W    32(A2),D4 
      ADD.W     34(A2),D4 
      BPL.S       L004C 
      MOVEQ     #0,D4 
      BRA.S      L004D 
L004C:MOVE.W    14(A3),D5 
      CMP.W     D5,D4 
      BLE.S       L004D 
      MOVE.W    D5,D4 
L004D:MOVE.W    D4,32(A2) 
      RTS 
L004E:CLR.B     27(A2)
      MOVE.B    7(A3),D4
      LSR.B     #2,D4 
      ANDI.B    #3,D4 
      CMPI.B    #3,D4 
      BNE.S       L004F 
      MOVE.B    2(A3),27(A2)
L004F:MOVE.W    28(A2),D5 
      ADD.W     30(A2),D5 
      MOVE.B    11(A3),D3 
      ADD.W     D3,D3 
      CMP.W     D3,D5 
      BLE.S       L0051 
      CMPI.B    #2,D4 
      BNE.S       L0050 
      NEG.W     30(A2)
      MOVE.W    D3,D5 
      BRA.S      L0053 
L0050:MOVEQ     #0,D5 
L0051:TST.W     D5
      BPL.S       L0053 
      CMPI.B    #2,D4 
      BNE.S       L0052 
      NEG.W     30(A2)
      MOVEQ     #0,D5 
      BRA.S      L0053 
L0052:MOVE.W    D3,D5 
L0053:MOVE.W    D5,28(A2) 
      MOVEQ     #0,D3 
      RTS 
L0054:MOVE.B    8(A3),25(A2)
      MOVE.B    24(A2),D3 
      ADD.B     26(A2),D3 
      BPL.S       L0056 
      MOVE.B    7(A3),D4
      ANDI.B    #3,D4 
      CMPI.B    #2,D4 
      BNE.S       L0055 
      NEG.B     26(A2)
      NEG.B     D3
      BRA.S      L0056 
L0055:MOVE.B    9(A3),D3
L0056:CMP.B     9(A3),D3
      BLE.S       L0058 
      CMPI.B    #2,D4 
      BNE.S       L0057 
      NEG.B     26(A2)
      ADD.B     26(A2),D3 
      ADD.B     26(A2),D3 
      BRA.S      L0058 
L0057:MOVEQ     #0,D3 
L0058:MOVE.B    D3,24(A2) 
      MOVEQ     #0,D3 
      RTS 
L0059:MOVEQ     #0,D3 
      MOVE.B    5(A1),D3
      SUBQ.B    #1,18(A1) 
      BNE.S       L005D 
      ADDQ.B    #1,D3 
L005A:MOVEA.L   14(A1),A4 
      CMPI.B    #$FF,0(A4,D3.W) 
      BNE.S       L005C 
      CMPI.B    #1,4(A1)
      BEQ.S       L005B 
      ADDQ.L       #4,A7
      BSR.S       L005E 
      BRA      L0014 
L005B:MOVEQ     #0,D3 
L005C:MOVE.B    0(A4,D3.W),18(A1) 
      MOVE.B    D3,5(A1)
L005D:ADD.W     D3,D3 
      ADD.W     D3,D3 
      CLR.W     20(A1)
      CLR.B     22(A1)
      MOVEA.L   (A1),A4 
      MOVEA.L   6(A1),A5
      ADDA.W    0(A5,D3.W),A4 
      MOVEQ     #0,D4 
      MOVE.L    A4,24(A1) 
      MOVE.B    2(A5,D3.W),D4 
      ADDA.W    D4,A4 
      MOVE.L    A4,28(A1) 
      MOVE.B    3(A5,D3.W),D4 
      ADDA.W    D4,A4 
      MOVE.L    A4,32(A1) 
      RTS 
L005E:MOVE.B    #$FF,23(A1) 
      *MOVE.L    38(A1),$114.W 
      LEA       L0000(PC),A1
      CLR.B     5(A1) 
      LEA       L0063(PC),A1
      CLR.L     8(A1) 
L005F:MOVE.B    #7,$FF8800.L
      MOVE.B    $FF8800.L,D4
      MOVE.B    7(A1),D3
      MOVE.B    D3,D5 
      MOVE.B    L0001(PC),D2
      ANDI.B    #$3F,D2 
      AND.B     D2,D3 
      NOT.B     D2
      AND.B     D2,D4 
      OR.B      D4,D3 
      MOVE.B    D3,7(A1)
      MOVE.W    L0000(PC),D2
      LEA       14(A1),A1 
      MOVEQ     #$D,D1
L0060:BTST      D1,D2 
      BNE.S       L0061 
      SUBQ.W    #1,A1 
      BRA.S      L0062 
L0061:MOVE.B    D1,$FF8800.L
      MOVE.B    -(A1),$FF8802.L 
L0062:DBF       D1,L0060
      MOVE.B    D5,7(A1)
      RTS 
L0063:DCB.W     8,0 
L0064:DCB.W     11,0
      DC.B      $00,$FF,$00,$00,$00,$00,$00,$00 
      DCB.W     4,0 
L0065:DCB.W     2,0 
L0066:DCB.W     21,0
L0067:DCB.W     21,0
L0068:DCB.W     21,0
L0069:DC.B      $0E,$EC,$0E,$1A,$0D,'N',$0C,$8A 
      DC.B      $0B,$DB,$0B,'1',$0A,$8C,$09,$F8 
      DC.B      $09,'j',$08,$E0,$08,'b',$07,$E8 
      DC.B      $07,'w',$07,$0C,$06,$A7,$06,'G' 
      DC.B      $05,$ED,$05,$98,$05,'G',$04,$FC 
      DC.B      $04,$B4,$04,'p',$04,'1',$03,$F4 
      DC.B      $03,$BC,$03,$86,$03,'S',$03,'$' 
      DC.B      $02,$F6,$02,$CC,$02,$A4,$02,'~' 
      DC.B      $02,'Z',$02,'8',$02,$18,$01,$FA 
      DC.B      $01,$DE,$01,$C3,$01,$AA,$01,$92 
      DC.B      $01,'{',$01,'f',$01,'R',$01,'?' 
      DC.B      $01,'-',$01,$1C,$01,$0C,$00,$FD 
      DC.B      $00,$EF,$00,$E1,$00,$D5,$00,$C9 
      DC.B      $00,$BE,$00,$B3,$00,$A9,$00,$9F 
      DC.B      $00,$96,$00,$8E,$00,$86,$00,$7F 
      DC.B      $00,'w',$00,'q',$00,'j',$00,'d' 
      DC.B      $00,'_',$00,'Y',$00,'T',$00,'P' 
      DC.B      $00,'K',$00,'G',$00,'C',$00,'?' 
      DC.B      $00,';',$00,'9',$00,'5',$00,'2' 
      DC.B      $00,'0',$00,'-',$00,'*',$00,'(' 
      DC.B      $00,'&',$00,'#',$00,'!',$00,' ' 
      DC.B      $00,$1D,$00,$00,$00,$00,$00,$00 
      DC.B      $00,$00 

	 SECTION DATA
RET:	DC.B	27,"Y",32,32,0
MUSIC:	INCBIN	A:\FIRSTE\NOPSEUDO.MOD
	 SECTION BSS
HANDLE:	DS.W	1
CURRENT:	DS.W	1
LONG:	DS.W	1
FONT:	DS.B	256*8
FORMAT:	DS.L	65536
FIN_FORMAT:
TEXTE:	DS.B	256*1024
