ACIA_ROUT: PART 
*********************************************************************** 
* KEYBOARD-ROUTINE * 
* VERSION 3.00+ * 
*---------------------------------------------------------------------* 
* X- UND Y-KOORDINATEN --> 'X_MAUS'.w und 'Y_MAUS'.w * 
* BORDERS --> 'X_MIN' , 'X_MAX', 'Y_MIN','Y_MAX'.w * 
* BUTTON --> 'BUTTON'.b * 
* ACCELERATION_TAB --> 'M_OFFSET'.w (16 w”rter lang !) * 
* KEY --> BSR'GET_KEY' --> D0.L (SCAN/ASCII) * 
* KEY REPEAT --> 'REPEAT'.w und 'REPEAT2'.w * 
* * 
* (C) cream 1991 

ACIA_IRQ: 
ACIA: MOVE #$2500,SR 
MOVEM.L D0-D2/A0-A1,-(SP) 
MOVEQ #0,D0 
LEA ACIA_REG(PC),A1 
ACIA_LOP: 
MOVE.B $FFFFFC02,D0 
TST.W 6(A1) 
BNE.S GET_X_Y 
CMP.B #$F8,D0 
BLT.S GET_X_Y 
CMP.B #$FB,D0 
BGT.S GET_X_Y 
MOVE.B D0,8(A1) 
ADDQ.W #1,6(A1) 
CLR.W 4(A1) 
ACIA_OVR: 
BTST #4,$FFFFFA01.w 
BEQ.S ACIA_LOP 
MOVEM.L (SP)+,D0-D2/A0-A1 
BCLR #6,$FFFFFA11 
RTE 

ACIA_VR2: MOVE.B D0,$0A(A1) 
BTST #4,$FFFFFA01 
BEQ.S ACIA_LOP 
MOVEM.L (SP)+,D0-D2/A0-A1 
BCLR #6,$FFFFFA11.w 
RTE 

GET_X_Y: TST.W 6(A1) 
BEQ.S ACIA_VR2 
ADDQ.W #1,4(A1) 
CMPI.W #2,4(A1) 
BNE.S GET_X 
TST.B D0 
BMI.S HOCH_Y 
ASL.W #1,D0 
MOVE.W 22(A1,D0.w),D2 
ADD.W D2,2(A1) 
DC.B $0C,$69 
Y_MAX: DC.B $00,$C7,$00,$02 
BLE.S B_DOWN 
SUB.W D2,2(A1) 
B_DOWN: 
CLR.L 4(A1) 
BRA.S ACIA_OVR 
HOCH_Y: MOVEQ #0,D1 
SUB.B D0,D1 
ASL.W #1,D1 
MOVE.W 22(A1,D1.w),D2 
SUB.W D2,2(A1) 
DC.B $0C,$69 
Y_MIN: DC.B $00,$00,$00,$02 
BGE.S B_UP 
ADD.W D2,2(A1) 
B_UP: 
CLR.L 4(A1) 
BRA ACIA_OVR 
GET_X: 
TST.B D0 
BMI.S LEFT_X 
ASL.W #1,D0 
MOVE.W 22(A1,D0.w),D2 
ADD.W D2,(A1) 
DC.B $0C,$51 
X_MAX: DC.B $01,$3F 
BLE.S B_RIGHT 
SUB.W D2,(A1) 
B_RIGHT: BRA ACIA_OVR 
LEFT_X: MOVEQ #$00,D1 
SUB.B D0,D1 
ASL.W #1,D1 
MOVE.W 22(A1,D1.w),D2 
SUB.W D2,(A1) 
DC.B $0C,$51 
X_MIN: DC.B $00,$00 
BGE.S B_LEFT 
ADD.W D2,(A1) 
B_LEFT: BRA ACIA_OVR 


GET_KEY: 
MOVEM.L D1-D3/A0,-(SP) 
MOVEQ #0,D0 
LEA ACIA_REG+$0A(PC),A0 
TST.W 2(A0) 
BNE.S COUNT 
AGAIN: 
MOVE.B (A0),D0 
NO_NEW: 
CMP.B (A0),D0 
BEQ.S NO_NEW 

NEW_ONE: MOVE.B (A0),D0 
MOVE.B D0,1(A0) 
MOVE.W #1,2(A0) 
MOVE.W 4(A0),D3 
AND.L #$FFFF,D3 
LSL.L #2,D3 
MOVE.L D3,8(A0) 
OUT_KEY: 
BTST #7,D0 
BNE.S AGAIN 
MOVE.B 48(A0,D0.w),D1 
SWAP D0 
MOVE.B D1,D0 
MOVEM.L (SP)+,D1-D3/A0 
RTS 
COUNT: 
MOVE.L 8(A0),D2 
C_LOOP: 
MOVE.B 1(A0),D1 
CMP.B (A0),D1 
BEQ.S OK 
BTST #7,(A0) 
BEQ.S NEW_ONE 
CLR.B (A0) 
CLR.W 2(A0) 
BRA.S AGAIN 
OK: 
SUBQ.L #1,D2 
BNE.S C_LOOP 
MOVE.W 6(A0),D3 
AND.L #$FFFF,D3 
MOVE.L D3,8(A0) 

MOVE.B (A0),D0 
BRA.S OUT_KEY 

ACIA_REG: 
X_MAUS: DC.W 0 
Y_MAUS: DC.W 0 
K_FLAG1: DC.W 0 
K_FLAG2: DC.W 0 
BUTTON: DC.W 0 
ACIA_KEY: DC.B 0 
KEY_BUFF: DC.B 0 
REPT: DC.W 0 
REPEAT: DC.W REP1 
REAPEAT2: DC.W REP2 
C_COUNT: DC.L 0 

M_OFFSET: DC.W 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 
SCAN_ASC: 
DC.B $00 
DC.B $1B,$31,$32,$33,$34,$35,$36,$37,$38,$39 ;$0A 
DC.B $30,$9E,$27,$08,$09,$71,$77,$65,$72,$74 ;$14 
DC.B $5A,$55,$49,$4F,$50,$9A,$2B,$0D,$00,$41 ;$1E 
DC.B $53,$44,$46,$47,$48,$4A,$4B,$4C,$99,$8E ;$28 
DC.B $00,$00,$00,$79,$78,$43,$56,$42,$4E,$4D ;$32 
DC.B $00,$00,$00,$00,$00,$00,$20,$00,$00,$00 ;$3C 
DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;$46 
DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;$50 
DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;$5A 
DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;$64 
DC.B $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;$6E 

EVEN 
************************************************************************** 

ENDPART 


