;                ** LIFE 2D CCK V8 **
TURNOFFMFP:MACRO
       MOVE.W    #5,-(SP)
       MOVE.W    #26,-(SP)
       TRAP      #14
       ADDQ.L    #4,SP
       MOVE.W    #6,-(SP)
       MOVE.W    #26,-(SP)
       TRAP      #14
       ADDQ.L    #4,SP
       ENDM
TURNONMFP:MACRO
       MOVE.W    #5,-(SP)
       MOVE.W    #27,-(SP)
       TRAP      #14
       ADDQ.L    #4,SP
       MOVE.W    #6,-(SP)
       MOVE.W    #27,-(SP)
       TRAP      #14
       ADDQ.L    #4,SP
       ENDM
TESTCURSORKEYS:MACRO
       CMPI.B    #$48,INKEY
       BNE.S     MAC0
       SUBQ.B    #1,YCORD
       TST.B     YCORD
       BGE       MAC5
       CLR.B     YCORD
       BRA       MAC5
MAC0:  CMPI.B    #$50,INKEY
       BNE.S     MAC1
       ADDQ.B    #1,YCORD
       CMPI.B    #15,YCORD
       BLE       MAC5
       MOVE.B    #15,YCORD
       BRA       MAC5
MAC1:  CMPI.B    #$4B,INKEY
       BNE.S     MAC2
       SUBQ.B    #1,XCORD
       TST.B     XCORD
       BGE       MAC5
       CLR.B     XCORD
       BRA       MAC5
MAC2:  CMPI.B    #$4D,INKEY
       BNE.S     MAC3
       ADDQ.B    #1,XCORD
       CMPI.B    #19,XCORD
       BLE       MAC5
       MOVE.B    #19,XCORD
       BRA       MAC5
MAC3:  CMPI.B    #$52,INKEY
       BNE.S     MAC4
       CLR.W     D1
       CLR.W     D0
       MOVE.B    XCORD,D0
       MOVE.B    YCORD,D1
       MOVE.W    D1,D2
       LSL.W     #2,D2
       LSL.W     #4,D1
       ADD.W     D2,D1
       ADD.W     D0,D1
       LEA       LIFEMATRIX,A0
       MOVE.B    #1,(A0,D1)
       BRA.S     MAC5
MAC4:  CMPI.B    #$47,INKEY
       BNE.S     MAC5
       CLR.W     D1
       CLR.W     D0
       MOVE.B    XCORD,D0
       MOVE.B    YCORD,D1
       MOVE.W    D1,D2
       LSL.W     #2,D2
       LSL.W     #4,D1
       ADD.W     D2,D1
       ADD.W     D0,D1
       LEA       LIFEMATRIX,A0
       CLR.B     (A0,D1)
MAC5:  
	ENDM
TM1M1: MACRO
       ADD.B     -21(A0,D2),D3
       ENDM
T0M1:  MACRO
       ADD.B     -20(A0,D2),D3
       ENDM
TP1M1: MACRO
       ADD.B     -19(A0,D2),D3
       ENDM
TM10:  MACRO
       ADD.B     -1(A0,D2),D3
       ENDM
TP10:  MACRO
       ADD.B     1(A0,D2),D3
       ENDM
TM1P1: MACRO
       ADD.B     19(A0,D2),D3
       ENDM
T0P1:  MACRO
       ADD.B     20(A0,D2),D3
       ENDM
TP1P1: MACRO
       ADD.B     21(A0,D2),D3
       ENDM

LIFE2D:
 LEA SAMPLE,A2
AGAIN1:
 CMP.L #SMPSLUT,A2
 BEQ FIN
 MOVE.B (A2),D1
 AND.W #$00FF,D1        ;MASK OFF RUBBISH
 ADD.B #$80,D1          ;COMPLENT VALUE
 MOVE.B D1,(A2)+
 BRA AGAIN1
FIN:
       PEA       PROGRAMSTART
       MOVE.W    #38,-(SP)
       TRAP      #14
       ADDQ.L    #6,SP
       ILLEGAL
       CLR.W     -(SP)
       TRAP      #1
       DCB.W      1000,0

PROGRAMSTART:
       AND.B     #%11111110,$484  ;REMOVE KEYB. SOUND
       BSR       IKBDWS           ;MOUSE OFF
       BSR       FADEOUT
       BSR       LOWRES
       BSR       PAINT
       BSR       SETSND           ;SET UP SOUND REGISTERS
       TURNOFFMFP
       MOVE.W    #$2700,SR
       MOVE.L    $68,SHBL
       MOVE.L    #SAMPLAY,$68
       LEA       SCREG,A6
       LEA       COLORS1,A2
       BSR       FADEIN
       MOVE.L    $70,OLD
       MOVE.L    #VBL,$70
       MOVE.W    #$2100,SR
MAIN:  TST.B     VBLSTATE         ;MAIN LOOP
       BEQ.S     CHECK            ;CHECKS IF VBLSTATE
       BSR.S     VBLSET           ;IS SET AND RUNS VBLSET
       CLR.B     VBLSTATE         ;CLEAR VBLSTATE
CHECK: CMPI.B    #$01,$FFFC02     ;CHECKS IF ESC IS
       BNE.S     MAIN             ;PRESSED
       MOVE.W    #$2700,SR
       MOVE.L    OLD,$70
       TURNONMFP
;       BSR       FADEOUT
       MOVE.L    SHBL,$68
       MOVE.W    #$2300,SR
       BSR       MOUSE            ;MOUSE ON
       BRA       EXIT
       RTS

VBL:   SUB.W     #$050,CCNTR
       MOVE.B    #1,VBLSTATE
       RTE

VBLSET:
       BSR       SPRITE
       TST.B     FLG
       BEQ.S     FLIP
       SUBQ.B    #1,FLG
       RTS
FLIP:  MOVE.B    #0,VBLSTATE
       MOVE.B    #1,FLG
       MOVEA.L   SCRST,A3
       MOVEA.L   SCREN,A4
       EXG.L     A3,A4
       MOVE.L    A3,SCRST
       MOVE.L    A4,SCREN
       TESTCURSORKEYS
       TST.B     STAGE
       BEQ.S     FLOP
       SUB.B     #1,STAGE
       BRA.S     NOTEQ
FLOP:  CMPI.B    #$39,INKEY
       BNE.S     NOTEQ
       BSR       PROCESSMATRIX
       MOVE.B    #3,STAGE
       BRA.S     VBLOUT
NOTEQ: BSR       SCREENUPDATE
       BSR       PRINTCURSOR
VBLOUT:NOP
WAIT:  TST.B     VBLSTATE
       BEQ.S     WAIT
       MOVE.B    SCRST+1,$FF8201
       MOVE.B    SCRST+2,$FF8203
       RTS

PRINTCURSOR:
       MOVEA.L   SCRST,A0
       CLR.W     D0
       CLR.W     D1
       MOVE.B    XCORD,D0
       MOVE.B    YCORD,D1
       MULU      #1920,D1
       LSL.W     #3,D0
       ADD.W     D1,D0
       ADD.W     D0,A0
       MOVEM.L   CURSOR,D0-D5
       AND.W     D0,166(A0)
       NOT.W     D0
       OR.W      D0,166(A0)
       SWAP      D0
       AND.W     D0,6(A0)
       NOT.W     D0
       OR.W      D0,6(A0)
       AND.W     D1,486(A0)
       NOT.W     D1
       OR.W      D1,486(A0)
       SWAP      D1
       AND.W     D1,326(A0)
       NOT.W     D1
       OR.W      D1,326(A0)
       AND.W     D2,806(A0)
       NOT.W     D2
       OR.W      D2,806(A0)
       SWAP      D2
       AND.W     D2,646(A0)
       NOT.W     D2
       OR.W      D2,646(A0)
       AND.W     D3,1126(A0)
       NOT.W     D3
       OR.W      D3,1126(A0)
       SWAP      D3
       AND.W     D3,966(A0)
       NOT.W     D3
       OR.W      D3,966(A0)
       AND.W     D4,1446(A0)
       NOT.W     D4
       OR.W      D4,1446(A0)
       SWAP      D4
       AND.W     D4,1286(A0)
       NOT.W     D4
       OR.W      D4,1286(A0)
       AND.W     D5,1766(A0)
       NOT.W     D5
       OR.W      D5,1766(A0)
       SWAP      D5
       AND.W     D5,1606(A0)
       NOT.W     D5
       OR.W      D5,1606(A0)
       RTS

PROCESSMATRIX:
       LEA       LIFEMATRIX,A0
       LEA       LIFEMATRIX2,A1
       MOVE.W    #7,D0
CPY0:  MOVEM.L   (A0)+,D1-D7/A2-A4
       MOVEM.L   D1-D7/A2-A4,(A1)
       ADD.W     #40,A1
       DBRA      D0,CPY0
       LEA       LIFEMATRIX,A0
       LEA       LIFEMATRIX2,A1
       MOVE.W    #15,D0      ;Y-COORD
PRO:   MOVE.W    #19,D1      ;X-COORD
PRO1:  MOVE.W    D0,D2
       MOVE.W    D0,D3
       LSL.W     #4,D2
       LSL.W     #2,D3
       ADD.W     D3,D2
       ADD.W     D1,D2
       CLR.W     D3
       TST.B     D0
       BEQ.S     Y_EQUALS_0
       CMPI.B    #15,D0
       BEQ.S     Y_EQUALS_15
       T0M1
       T0P1
       TST.B     D1
       BEQ.S     PRO2
       TM1M1
       TM10
       TM1P1
       CMPI.B    #19,D1
       BEQ.S     PRO3
PRO2:  TP1M1
       TP10
       TP1P1
PRO3:  BRA.S     PRO7
Y_EQUALS_15:
       T0M1
       TST.B     D1
       BEQ.S     PRO4
       TM1M1
       TM10
       CMPI.B    #19,D1
       BEQ.S     PRO5
PRO4:  TP1M1
       TP10
PRO5:  BRA.S     PRO7
Y_EQUALS_0:
       T0P1
       TST.B     D1
       BEQ.S     PRO6
       TM10
       TM1P1
       CMPI.B    #19,D1
       BEQ.S     PRO7
PRO6:  TP10
       TP1P1
PRO7:  CMPI.B    #1,D3
       BGT.S     PRO8
       MOVE.B    #0,(A1,D2)
       BRA.S     PRO15
PRO8:  CMPI.B    #4,D3
       BLT.S     PRO9
       MOVE.B    #0,(A1,D2)
       BRA.S     PRO15
PRO9:  CMPI.B    #2,D3
       BEQ.S     PRO15
       MOVE.B    #1,(A1,D2)
PRO15: DBRA      D1,PRO1
       DBRA      D0,PRO
       LEA       LIFEMATRIX,A0
       LEA       LIFEMATRIX2,A1
       MOVE.W    #7,D0
CPY1:  MOVEM.L   (A1)+,D1-D7/A2-A4
       MOVEM.L   D1-D7/A2-A4,(A0)
       ADD.W     #40,A0
       DBRA      D0,CPY1
       RTS

SCREENUPDATE:
       LEA       LIFEMATRIX,A0
       LEA       BACTERIA,A1
       MOVEA.L   SCRST,A2
       ADDQ.W    #6,A2
       MOVE.W    #15,D2
BCT1:  MOVE.W    #19,D1
BCT:   TST.B     (A0)+
       BNE.S     PUTBCT
CLRBCT:CLR.W     D0
       MOVE.W    D0,(A2)
       MOVE.W    D0,160(A2)
       MOVE.W    D0,2*160(A2)
       MOVE.W    D0,3*160(A2)
       MOVE.W    D0,4*160(A2)
       MOVE.W    D0,5*160(A2)
       MOVE.W    D0,6*160(A2)
       MOVE.W    D0,7*160(A2)
       MOVE.W    D0,8*160(A2)
       MOVE.W    D0,9*160(A2)
       MOVE.W    D0,10*160(A2)
       MOVE.W    D0,11*160(A2)
       ADDQ.W    #8,A2
       DBRA      D1,BCT
       BRA.S     BCTQ
PUTBCT:MOVEM.L   (A1),D0/D3-D7
       MOVE.W    D0,160(A2)
       SWAP      D0
       MOVE.W    D0,(A2)
       MOVE.W    D3,3*160(A2)
       SWAP      D3
       MOVE.W    D3,2*160(A2)
       MOVE.W    D4,5*160(A2)
       SWAP      D4
       MOVE.W    D4,4*160(A2)
       MOVE.W    D5,7*160(A2)
       SWAP      D5
       MOVE.W    D5,6*160(A2)
       MOVE.W    D6,9*160(A2)
       SWAP      D6
       MOVE.W    D6,8*160(A2)
       MOVE.W    D7,11*160(A2)
       SWAP      D7
       MOVE.W    D7,10*160(A2)
       ADDQ.W    #8,A2
       DBRA      D1,BCT
BCTQ:  ADDA.W    #11*160,A2
       DBRA      D2,BCT1
       RTS

SPRITE:MOVEA.L   SCRST,A0    ;RESTORE BOTH SCREENS
       MOVEA.L   SCREN,A1
       LEA       PICTURE+128,A3
       MOVE.W    SAVLOC,D0
       CLR.W     D1
       MOVE.B    SAVLOC+2,D1
       ADD.W     D1,D0
       ADDA.W    D0,A0
       ADDA.W    D0,A1
       ADDA.W    D0,A3
       REPT 32
       MOVEM.W   (A3)+,D0-D7
       MOVEM.W   D0-D2,(A0)
       MOVEM.W   D0-D2,(A1)
       ADDQ.W    #8,A0
       ADDQ.W    #8,A1
       MOVEM.W   D4-D6,(A0)
       MOVEM.W   D4-D6,(A1)
       ADDQ.W    #8,A0
       ADDQ.W    #8,A1
       MOVEM.W   (A3)+,D0-D7
       MOVEM.W   D0-D2,(A0)
       MOVEM.W   D0-D2,(A1)
       ADDQ.W    #8,A0
       ADDQ.W    #8,A1
       MOVEM.W   D4-D6,(A0)
       MOVEM.W   D4-D6,(A1)
       ADD.W     #136,A0
       ADD.W     #136,A1
       ADD.W     #128,A3
       ENDR
OUTPUT:MOVEM.L   A5,-(SP)    ;PLACE SPRITE ON BOTH SCREENS
       MOVEA.L   SCRST,A0
       MOVEA.L   SCREN,A1
       LEA       DSPRT,A3
       TST.W     ITERA
       BNE.S     CL
       ADD.W     #4,SLF1+4
SLF1:  LEA       STEPRATE-4,A5
       CMPI.W    #$FFFF,(A5)
       BNE.S     CL1
       MOVE.L    #STEPRATE,SLF1+2
       BRA.S     SLF1
CL1:   MOVE.W    2(A5),ITERA
       MOVE.B    1(A5),SLF2+3
       MOVE.B    (A5),SLF3+3
CL:    SUBQ.W    #1,ITERA
       MOVEM.L   LOCBUF,A4/A5
       CLR.W     D0
SLF2:  ADD.W     #10,A5
       MOVE.B    (A5),D0
       CMPI.B    #$FF,D0
       BNE.S     NEXT
       SUBA.W    #1000,A5
       MOVE.B    (A5),D0
NEXT:  LSR.B     #1,D0
       ADDI.B    #40,D0
       MULU      #160,D0
       MOVE.W    D0,SAVLOC
       ADDA.W    D0,A0
       ADDA.W    D0,A1
       CLR.W     D0
       CLR.W     D1
SLF3:  ADD.W     #10,A4
       MOVE.B    (A4),D0
       CMPI.B    #$FF,D0
       BNE.S     NEXT1
       SUBA.W    #1000,A4
       MOVE.B    (A4),D0
NEXT1: MOVEM.L   A4/A5,LOCBUF
       MOVE.B    D0,D1
       AND.B     #%00001111,D0
       LSL.W     #8,D0       ;DATA FRAME OFFSET
       ADDA.W    D0,A3
       AND.B     #%11110000,D1
       LSR.B     #1,D1       ;SCREEN BASE OFFSET
       MOVE.B    D1,SAVLOC+2
       ADDA.W    D1,A0
       ADDA.W    D1,A1
       REPT 16
       MOVEM.W   (A3)+,D0-D7
       OR.W    D0,(A0)+
       OR.W    D0,(A0)+
       OR.W    D0,(A0)+
       OR.W    D0,(A1)+
       OR.W    D0,(A1)+
       OR.W    D0,(A1)+
       ADDQ.W    #2,A0
       ADDQ.W    #2,A1
       OR.W    D1,(A0)+
       OR.W    D1,(A0)+
       OR.W    D1,(A0)+
       OR.W    D1,(A1)+
       OR.W    D1,(A1)+
       OR.W    D1,(A1)+
       ADDQ.W    #2,A0
       ADDQ.W    #2,A1
       OR.W    D2,(A0)+
       OR.W    D2,(A0)+
       OR.W    D2,(A0)+
       OR.W    D2,(A1)+
       OR.W    D2,(A1)+
       OR.W    D2,(A1)+
       ADDQ.W    #2,A0
       ADDQ.W    #2,A1
       OR.W    D3,(A0)+
       OR.W    D3,(A0)+
       OR.W    D3,(A0)+
       OR.W    D3,(A1)+
       OR.W    D3,(A1)+
       OR.W    D3,(A1)+
       ADD.W     #130,A0
       ADD.W     #130,A1
       OR.W    D4,(A0)+
       OR.W    D4,(A0)+
       OR.W    D4,(A0)+
       OR.W    D4,(A1)+
       OR.W    D4,(A1)+
       OR.W    D4,(A1)+
       ADDQ.W    #2,A0
       ADDQ.W    #2,A1
       OR.W    D5,(A0)+
       OR.W    D5,(A0)+
       OR.W    D5,(A0)+
       OR.W    D5,(A1)+
       OR.W    D5,(A1)+
       OR.W    D5,(A1)+
       ADDQ.W    #2,A0
       ADDQ.W    #2,A1
       OR.W    D6,(A0)+
       OR.W    D6,(A0)+
       OR.W    D6,(A0)+
       OR.W    D6,(A1)+
       OR.W    D6,(A1)+
       OR.W    D6,(A1)+
       ADDQ.W    #2,A0
       ADDQ.W    #2,A1
       OR.W    D7,(A0)+
       OR.W    D7,(A0)+
       OR.W    D7,(A0)+
       OR.W    D7,(A1)+
       OR.W    D7,(A1)+
       OR.W    D7,(A1)+
       ADD.W     #130,A0
       ADD.W     #130,A1
       ENDR
       MOVEM.L   (SP)+,A5
       RTS

FADEOUT:
       MOVE.W    #7,D4
OLE4:  MOVE.L    #$FF8240,A1
       BSR       BREAK
       MOVE.W    #15,D3
OLE:   MOVE.W    (A1),D1
       MOVE.W    D1,D2
       AND.W     #%011100000000,D1
       AND.W     #%000001110111,D2
       TST.W     D1
       BEQ.S     OLE1
       SUBI.W    #$100,D1
       OR.W      D1,D2
       MOVE.W    D2,(A1)
OLE1:  MOVE.W    (A1),D1
       MOVE.W    D1,D2
       AND.W     #%000001110000,D1
       AND.W     #%011100000111,D2
       TST.W     D1
       BEQ.S     OLE2
       SUBI.W    #$010,D1
       OR.W      D1,D2
       MOVE.W    D2,(A1)
OLE2:  MOVE.W    (A1),D1
       MOVE.W    D1,D2
       AND.W     #%000000000111,D1
       AND.W     #%011101110000,D2
       TST.W     D1
       BEQ.S     OLE3
       SUBQ.W    #$001,D1
       OR.W      D1,D2
       MOVE.W    D2,(A1)
OLE3:  ADDQ.W    #2,A1
       DBRA      D3,OLE
       DBRA      D4,OLE4
       RTS

FADEIN:
       MOVE.W    #7,D4
OLE9:  BSR       BREAK
       MOVE.W    #15,D3
       MOVE.L    A2,A0
       MOVE.L    #$FF8240,A1
OLE8:  MOVE.W    (A0),D0
       AND.W     #%011100000000,D0
       MOVE.W    (A1),D1
       MOVE.W    D1,D2
       AND.W     #%011100000000,D1
       AND.W     #%000001110111,D2
       CMP.W     D0,D1
       BEQ.S     OLE5
       ADDI.W    #$100,D1
       OR.W      D1,D2
       MOVE.W    D2,(A1)
OLE5:  MOVE.W    (A0),D0
       AND.W     #%000001110000,D0
       MOVE.W    (A1),D1
       MOVE.W    D1,D2
       AND.W     #%000001110000,D1
       AND.W     #%011100000111,D2
       CMP.W     D0,D1
       BEQ.S     OLE6
       ADDI.W    #$010,D1
       OR.W      D1,D2
       MOVE.W    D2,(A1)
OLE6:  MOVE.W    (A0),D0
       AND.W     #%000000000111,D0
       MOVE.W    (A1),D1
       MOVE.W    D1,D2
       AND.W     #%000000000111,D1
       AND.W     #%011101110000,D2
       CMP.W     D0,D1
       BEQ.S     OLE7
       ADDQ.W    #$001,D1
       OR.W      D1,D2
       MOVE.W    D2,(A1)
OLE7:  ADDQ.W    #2,A1
       ADDQ.W    #2,A0
       DBRA      D3,OLE8
       DBRA      D4,OLE9
       RTS

PAINT:
       LEA       PICTURE+128,A0
       MOVEA.L   SCRST,A1
       MOVEA.L   SCREN,A2
       MOVE.W    #1599,D0
PINT1: MOVEM.L   (A0)+,D1-D5
       MOVEM.L   D1-D5,(A1)
       MOVEM.L   D1-D5,(A2)
       ADD.W     #20,A1
       ADD.W     #20,A2
       DBRA      D0,PINT1
       RTS

BREAK:
       MOVE.W    #1,D1
VS:    BSR.S     VSYNC
       DBRA      D1,VS
       RTS

VSYNC:
       MOVEM.L   A0/A1/D0-D2,BUFF
       MOVE.W    #37,-(SP)
       TRAP      #14
       ADDQ.L    #2,SP
       MOVEM.L   BUFF,A0/A1/D0-D2
       RTS

LOWRES:
       MOVE.W    #0,-(SP)
       MOVE.L   SCRST,-(SP)
       MOVE.L   SCRST,-(SP)
       MOVE.W    #5,-(SP)
       TRAP      #14
       ADD.L     #12,SP
       RTS

EXIT:
       MOVE.W    #1,-(SP)
       MOVE.L    XITSC,-(SP)
       MOVE.L    XITSC,-(SP)
       MOVE.W    #5,-(SP)
       TRAP      #14
       ADD.L     #12,SP
       LEA       COLORS2,A0
       BSR       PALETTE
       RTS
       ILLEGAL

PALETTE:
       MOVE.L    A0,-(SP)
       MOVE.W    #6,-(SP)
       TRAP      #14
       ADDQ.L    #6,SP
       RTS

IKBDWS:                      ;TURN MOUSE OFF
       MOVE.L    #MSTR1,-(SP)
       MOVE.W    #0,-(SP)
       MOVE.W    #25,-(SP)
       TRAP      #14
       ADDQ.L    #8,SP
       RTS

MOUSE:                       ;TURN MOUSE BACK ON
       MOVE.L    #MSTR,-(SP)
       MOVE.W    #0,-(SP)
       MOVE.W    #25,-(SP)
       TRAP      #14
       ADDQ.L    #8,SP
       RTS

NOTHING:
       RTE

NOPLAY:MOVE.L #SAMPLAY,$68
       RTE

SAMPLAY:
       MOVE.L    #NOPLAY,$68
       MOVEM.L   D7/A5,-(SP)
       LEA       SND_OUT,A5
       CLR.W     D7
SAMPK1:MOVE.B    SAMPLE,D7           ;READ FROM RAM
       LSL.W     #3,D7               ;DOUBLE LONG WORD OFFSET
       CMP.L     #SMPSLUT,SAMPK1+2  ;EXCEDED END STOP
       BGT.S     HLTREP             ;BRANCH IF SO
SAMBAC:ADD.W     D7,A5
       MOVE.L    (A5)+,D7      ;GET DATA #1
       MOVEP.L   D7,0(A6)      ;PLAY #1
       MOVE.W    (A5),D7       ;GET DATA #2
       MOVEP.W   D7,0(A6)      ;PLAY #2
       ADDQ.L    #1,SAMPK1+2
       MOVEM.L   (SP)+,D7/A5
       ADD.W     #$0010,CCNTR
       AND.W     #$0070,CCNTR
       DCB.W      16,$4E71
       MOVE.W    CCNTR,$FF8240
       RTE
HLTREP:MOVE.L    #SAMPLE,SAMPK1+2
       JMP       SAMBAC

; SET UP THE SOUND CHIP CHANNELS
SETSND:
       MOVE.B    #0,SCREG ;CHANNEL A
       MOVE.B    #0,SCDATA
       MOVE.B    #1,SCREG
       MOVE.B    #0,SCDATA
       MOVE.B    #2,SCREG ;CHANNEL B
       MOVE.B    #0,SCDATA
       MOVE.B    #3,SCREG
       MOVE.B    #0,SCDATA
       MOVE.B    #4,SCREG ;CHANNEL C
       MOVE.B    #0,SCDATA
       MOVE.B    #5,SCREG
       MOVE.B    #0,SCDATA
       MOVE.B    #7,SCREG ;SET UP CHANNEL MIXING & PORT 'A' I/O
       MOVE.B    #$FF,SCDATA
       MOVE.B    #8,SCREG ;SET ALL VOLUMES TO ZERO
       MOVE.B    #0,SCDATA
       MOVE.B    #9,SCREG
       MOVE.B    #0,SCDATA
       MOVE.B    #10,SCREG
       MOVE.B    #0,SCDATA
       RTS
       ILLEGAL

BACTERIA:
       DC.W      %0000000000000000
       DC.W      %0110000000001110
       DC.W      %0111000000110110
       DC.W      %0000101111100000
       DC.W      %0000110000011000
       DC.W      %0001001011001000
       DC.W      %0010011010000100
       DC.W      %0010000000100100
       DC.W      %0010011111101000
       DC.W      %0001000000010000
       DC.W      %0000111111100000
       DC.W      %0000000000000000

CURSOR:
       DC.W      %0111111111111110
       DC.W      %1011111111111101
       DC.W      %1101111111111011
       DC.W      %1110111111110111
       DC.W      %1111011111101111
       DC.W      %1111111111111111
       DC.W      %1111111111111111
       DC.W      %1111011111101111
       DC.W      %1110111111110111
       DC.W      %1101111111111011
       DC.W      %1011111111111101
       DC.W      %0111111111111110

LIFEMATRIX:
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       EVEN
LIFEMATRIX2:
       DCB.B      320,$0
Steprate:
       DC.B      5,5,$1,$90
       DC.B      6,4,$1,$90
       DC.B      7,3,$1,$90
       DC.B      6,4,$1,$90
       DC.B      5,5,$1,$90
       DC.B      4,6,$1,$90
       DC.W      $FFFF,$FFFF


PICTURE:INCBIN   A:\NEWLIFE2\life2d.NEO
DSPRT: INCBIN    A:\NEWLIFE2\life2d.DAT
INDATX:
INDATY:INCBIN    A:\NEWLIFE2\sindata.DAT
       DC.W      $FFFF,$FFFF,$FFFF,$FFFF,$FFFF
COLORS1: DC.W $000,$001,$002,$003,$004,$005,$006,$770
         DC.W $777,$777,$777,$777,$777,$777,$777,$770
COLORS2: DC.W $777,$700,$070,$000,$111,$222,$333,$444
         DC.W $555,$000,$001,$010,$100,$200,$020,$002
SCRST: DC.L $F0000
SCREN: DC.L $E8000
XITSC: DC.L $F8000

ITERA: DC.W      0
XCORD: DC.B      10
YCORD: DC.B      8
KEYPRESSED:DC.B  0
STAGE: DC.B      0
VBLSTATE: DC.W   0
OLD:   DC.L      0
BUFF:  DCB.L      16,0
MSTR1: DC.B      $12
MSTR:  DC.B      $08
FLG:   DC.W      0
CCNTR: DC.W      156
       EVEN

SAVLOC:DCB.W      3,0
TABBUFF:
       DCB.W      64,0
TABBUFF2:
       DCB.W      64,0
LOCBUF:DC.L      INDATX,INDATY
CHARBUFF:
       DCB.B      3072,0
SHBL:  DC.L      0
INKEY EQU $FFFC02

       EVEN
; Internal sound lookup table.
SND_OUT:
 dc.w $80c,$90b,$a09,0,$80c,$90b,$a09,0
 dc.w $80d,$908,$a08,0,$80b,$90b,$a0b,0
 dc.w $80d,$909,$a05,0,$80c,$90b,$a08,0
 dc.w $80d,$909,$a02,0,$80d,$908,$a06,0
 dc.w $80c,$90b,$a07,0,$80d,$907,$a07,0
 dc.w $80c,$90b,$a06,0,$80c,$90a,$a09,0
 dc.w $80b,$90b,$a0a,0,$80c,$90b,$a02,0
 dc.w $80c,$90b,$a00,0,$80c,$90a,$a08,0

 dc.w $80d,$906,$a04,0,$80d,$905,$a05,0
 dc.w $80d,$905,$a04,0,$80c,$909,$a09,0
 dc.w $80d,$904,$a03,0,$80b,$90b,$a09,0
 dc.w $80c,$90a,$a05,0,$80b,$90a,$a0a,0
 dc.w $80c,$909,$a08,0,$80b,$90b,$a08,0
 dc.w $80c,$90a,$a00,0,$80c,$90a,$a00,0
 dc.w $80c,$909,$a07,0,$80b,$90b,$a07,0
 dc.w $80c,$909,$a06,0,$80b,$90b,$a06,0

 dc.w $80b,$90a,$a09,0,$80b,$90b,$a05,0
 dc.w $80a,$90a,$a0a,0,$80b,$90b,$a02,0
 dc.w $80b,$90a,$a08,0,$80c,$907,$a07,0
 dc.w $80c,$908,$a04,0,$80c,$907,$a06,0
 dc.w $80b,$909,$a09,0,$80c,$906,$a06,0
 dc.w $80a,$90a,$a09,0,$80c,$907,$a03,0
 dc.w $80b,$90a,$a05,0,$80b,$909,$a08,0
 dc.w $80b,$90a,$a03,0,$80a,$90a,$a08,0

 dc.w $80b,$90a,$a00,0,$80b,$909,$a07,0
 dc.w $80b,$908,$a08,0,$80a,$90a,$a07,0
 dc.w $80a,$909,$a09,0,$80c,$901,$a01,0
 dc.w $80a,$90a,$a06,0,$80b,$908,$a07,0
 dc.w $80a,$90a,$a05,0,$80a,$909,$a08,0
 dc.w $80a,$90a,$a02,0,$80a,$90a,$a01,0
 dc.w $80a,$90a,$a00,0,$809,$909,$a09,0
 dc.w $80a,$908,$a08,0,$80b,$908,$a01,0

 dc.w $80a,$909,$a06,0,$80b,$907,$a04,0
 dc.w $80a,$909,$a05,0,$809,$909,$a08,0
 dc.w $80a,$909,$a03,0,$80a,$908,$a06,0
 dc.w $80a,$909,$a00,0,$809,$909,$a07,0
 dc.w $809,$908,$a08,0,$80a,$908,$a04,0
 dc.w $809,$909,$a06,0,$80a,$908,$a01,0
 dc.w $809,$909,$a05,0,$809,$908,$a07,0
 dc.w $808,$908,$a08,0,$809,$909,$a02,0

 dc.w $809,$908,$a06,0,$809,$909,$a00,0
 dc.w $809,$907,$a07,0,$808,$908,$a07,0
 dc.w $809,$907,$a06,0,$809,$908,$a02,0
 dc.w $808,$908,$a06,0,$809,$906,$a06,0
 dc.w $808,$907,$a07,0,$808,$908,$a04,0
 dc.w $808,$907,$a06,0,$808,$908,$a02,0
 dc.w $807,$907,$a07,0,$808,$906,$a06,0
 dc.w $808,$907,$a04,0,$807,$907,$a06,0

 dc.w $808,$906,$a05,0,$808,$906,$a04,0
 dc.w $807,$906,$a06,0,$807,$907,$a04,0
 dc.w $808,$905,$a04,0,$806,$906,$a06,0
 dc.w $807,$906,$a04,0,$807,$905,$a05,0
 dc.w $806,$906,$a05,0,$806,$906,$a04,0
 dc.w $806,$905,$a05,0,$806,$906,$a02,0
 dc.w $806,$905,$a04,0,$805,$905,$a05,0
 dc.w $806,$905,$a02,0,$805,$905,$a04,0

 dc.w $805,$904,$a04,0,$805,$905,$a02,0
 dc.w $804,$904,$a04,0,$804,$904,$a03,0
 dc.w $804,$904,$a02,0,$804,$903,$a03,0
 dc.w $803,$903,$a03,0,$803,$903,$a02,0
 dc.w $803,$902,$a02,0,$802,$902,$a02,0
 dc.w $802,$902,$a01,0,$801,$901,$a01,0
 dc.w $802,$901,$a00,0,$801,$901,$a00,0
 dc.w $801,$900,$a00,0,$800,$900,$a00,0

 dc.w $80e,$90d,$a0c,0,$80f,$903,$a00,0
 dc.w $80f,$903,$a00,0,$80f,$903,$a00,0
 dc.w $80f,$903,$a00,0,$80f,$903,$a00,0
 dc.w $80f,$903,$a00,0,$80e,$90d,$a0b,0
 dc.w $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
 dc.w $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
 dc.w $80e,$90d,$a0b,0,$80e,$90d,$a0b,0
 dc.w $80e,$90d,$a0a,0,$80e,$90d,$a0a,0

 dc.w $80e,$90d,$a0a,0,$80e,$90d,$a0a,0
 dc.w $80e,$90c,$a0c,0,$80e,$90d,$a00,0
 dc.w $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
 dc.w $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
 dc.w $80d,$90d,$a0d,0,$80d,$90d,$a0d,0
 dc.w $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
 dc.w $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
 dc.w $80e,$90c,$a0b,0,$80e,$90c,$a0b,0

 dc.w $80e,$90c,$a0b,0,$80e,$90c,$a0b,0
 dc.w $80e,$90c,$a0a,0,$80e,$90c,$a0a,0
 dc.w $80e,$90c,$a0a,0,$80e,$90c,$a0a,0
 dc.w $80d,$90d,$a0c,0,$80d,$90d,$a0c,0
 dc.w $80e,$90c,$a09,0,$80e,$90c,$a09,0
 dc.w $80e,$90c,$a05,0,$80e,$90c,$a00,0
 dc.w $80e,$90c,$a00,0,$80e,$90b,$a0b,0
 dc.w $80e,$90b,$a0b,0,$80e,$90b,$a0b,0

 dc.w $80e,$90b,$a0b,0,$80e,$90b,$a0a,0
 dc.w $80e,$90b,$a0a,0,$80e,$90b,$a0a,0
 dc.w $80d,$90d,$a0b,0,$80d,$90d,$a0b,0
 dc.w $80d,$90d,$a0b,0,$80e,$90b,$a09,0
 dc.w $80e,$90b,$a09,0,$80e,$90b,$a09,0
 dc.w $80d,$90c,$a0c,0,$80d,$90d,$a0a,0
 dc.w $80e,$90b,$a07,0,$80e,$90b,$a00,0
 dc.w $80e,$90b,$a00,0,$80d,$90d,$a09,0

 dc.w $80d,$90d,$a09,0,$80e,$90a,$a09,0
 dc.w $80d,$90d,$a08,0,$80d,$90d,$a07,0
 dc.w $80d,$90d,$a04,0,$80d,$90d,$a00,0
 dc.w $80e,$90a,$a04,0,$80e,$909,$a09,0
 dc.w $80e,$909,$a09,0,$80d,$90c,$a0b,0
 dc.w $80e,$909,$a08,0,$80e,$909,$a08,0
 dc.w $80e,$909,$a07,0,$80e,$908,$a08,0
 dc.w $80e,$909,$a01,0,$80c,$90c,$a0c,0

 dc.w $80d,$90c,$a0a,0,$80e,$908,$a06,0
 dc.w $80e,$907,$a07,0,$80e,$908,$a00,0
 dc.w $80e,$907,$a05,0,$80e,$906,$a06,0
 dc.w $80d,$90c,$a09,0,$80e,$905,$a05,0
 dc.w $80e,$904,$a04,0,$80d,$90c,$a08,0
 dc.w $80d,$90b,$a0b,0,$80e,$900,$a00,0
 dc.w $80d,$90c,$a06,0,$80d,$90c,$a05,0
 dc.w $80d,$90c,$a02,0,$80c,$90c,$a0b,0

 dc.w $80c,$90c,$a0b,0,$80d,$90b,$a0a,0
 dc.w $80d,$90b,$a0a,0,$80d,$90b,$a0a,0
 dc.w $80d,$90b,$a0a,0,$80c,$90c,$a0a,0
 dc.w $80c,$90c,$a0a,0,$80c,$90c,$a0a,0
 dc.w $80d,$90b,$a09,0,$80d,$90b,$a09,0
 dc.w $80d,$90a,$a0a,0,$80d,$90a,$a0a,0
 dc.w $80d,$90a,$a0a,0,$80c,$90c,$a09,0
 dc.w $80c,$90c,$a09,0,$80c,$90c,$a09,0

 dc.w $80d,$90b,$a06,0,$80c,$90b,$a0b,0
 dc.w $80c,$90c,$a08,0,$80d,$90b,$a00,0
 dc.w $80d,$90b,$a00,0,$80c,$90c,$a07,0
 dc.w $80c,$90c,$a06,0,$80c,$90c,$a05,0
 dc.w $80c,$90c,$a03,0,$80c,$90c,$a01,0
 dc.w $80c,$90b,$a0a,0,$80d,$90a,$a05,0
 dc.w $80d,$90a,$a04,0,$80d,$90a,$a02,0
 dc.w $80d,$909,$a08,0,$80d,$909,$a08,0
       EVEN
SCREG=$FF8800
SCDATA=$FF8802
SAMPEK: DC.L SAMPLE
SAMPLE: INCBIN A:\NEWLIFE2\AGGROMIX.SPL
SMPSLUT:
       END

?