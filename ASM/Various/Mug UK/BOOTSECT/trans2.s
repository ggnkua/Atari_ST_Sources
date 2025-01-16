;
; Transbeauce II bootsector by Mr Bee/OVR
;
; Ripped & Encryption removed by MUG U.K(tm)
;

START	MOVEA.W   #$8200,A4 
	MOVEA.W   #$8240,A5 
	MOVE.L    (A4),-(A7)
	MOVE.B    $FFFFFA15.W,-(A7) 
	CLR.B     $FFFFFA15.W 

	MOVEA.L   A5,A0 	; blank out palette
	MOVEQ     #7,D0 
L0001	CLR.L     (A0)+ 
	DBF       D0,L0001

	PEA       BOOTMESS(PC)	; TEXT MESSAGE
	MOVE.W    #9,-(A7) 	;CCONWS 	; print it
	TRAP      #1
	ADDQ.W    #6,A7 

	MOVEQ     #2,D6 
	MOVEQ     #0,D5 
	MOVEA.L   $44E.W,A0 
	LEA       $30000,A1 
	MOVEQ     #7,D0 
L0003	MOVEQ     #$1B,D4 
L0004	MOVEQ     #$1B,D1 
	MOVE.L    #$70001,D3
	MOVE.L    D5,-(A7)
	MOVE.L    A0,-(A7)
L0005	MOVEQ     #7,D2 
L0006	MOVE.W    D6,(A1) 
	BTST      D2,(A0) 
	BEQ.B     L0007 
	MOVE.W    D5,(A1) 
L0007	ADDQ.W    #2,A1 
	DBF       D2,L0006
	ADDA.W    D3,A0 
	SWAP      D3
	ADDI.W    #$111,D5
	DBF       D1,L0005
	MOVEA.L   (A7)+,A0
	MOVE.L    (A7)+,D5
	ADDI.W    #$10,D5 
	DBF       D4,L0004
	ADDQ.W    #1,D5 
	LEA       160(A0),A0
	DBF       D0,L0003
	MOVE.L    #$20000,D0
	MOVEA.L   D0,A0 
	LSR.W     #8,D0 
	MOVE.L    D0,(A4) 
	MOVE.W    #$270F,D0 
L0008	CLR.L     (A0)+ 
	DBF       D0,L0008
	MOVEQ     #0,D7 
	MOVEQ     #1,D6 
	MOVEQ     #0,D3 
	MOVE.W    #$FF38,D4 

	MOVE.L    $70.W,-(A7) 
	MOVE.L    $68.W,-(A7) 
	LEA       NEW_70(PC),A0
	MOVE.L    A0,$70.W
	LEA       NEW_68(PC),A0
	MOVE.L    A0,$68.W
L0009	STOP      #$2300
	LEA       $30000,A6 
	ADD.W     D3,D4 
	TST.W     D3
	BEQ.B     L000A 
	CMP.W     #$28,D3 
	BEQ.B     L000A 
	CMP.W     #$FFD8,D3 
	BNE.B     L000B 
L000A	NEG.W     D3
	ADD.W     D3,D4 
L000B	ADDQ.W    #1,D3 
	MOVE.W    D4,D2 
	MOVEQ     #0,D5 
	ASR.W     #3,D2 
	BPL.B     L000C 
	SUB.W     D2,D5 
	MULS	#$1C0,D2
	SUBA.L    D2,A6 
	CLR.W     D2
L000C	MOVEQ     #1,D0 
	AND.W     D7,D0 
	EORI.W    #1,D0 
	MULU	#6,D0 
	STOP	#$2100
	MOVE      #$2300,SR 
	MOVEQ     #$50,D1 
	ADD.W     D0,D1 
	MOVEQ     #0,D0 
L000D	MOVE.B    $FFFF8209.W,D0
	BEQ.B     L000D 
	SUB.W     D0,D1 
	LSR.W     D1,D1 
	MOVEQ     #$15,D0 
L000E	DBF       D0,L000E
L000F	MOVEQ     #$28,D0 
L0010	DBF       D0,L0010
	DBF       D2,L000F
	MOVE.W    D7,D0 
	ANDI.W    #$FFFE,D0 
	ADDA.W    D0,A6 
	MOVE.W    #$C4,D0 
	SUB.W     D5,D0 
L0011	MOVEQ     #$13,D1 
L0012	MOVE.W    (A6)+,(A5)
	DBF       D1,L0012
	NOP 
	LEA       408(A6),A6
	DBF       D0,L0011
	CLR.W     (A5)
	ADD.W     D6,D7 
	BEQ.B     L0013 
	CMP.W     #$180,D7
	BNE.B     L0014 
L0013	NEG.W     D6
L0014	CMPI.B    #$39,$FFFFFC02.W
	BNE       L0009 
	MOVE.L    (A7)+,$68.W 
	MOVE.L    (A7)+,$70.W 
	MOVE.B    (A7)+,$FFFFFA15.W 
	MOVE.L    (A7)+,(A4)
	RTS

NEW_70	MOVEQ     #$21,D0 
L0016	STOP      #$2100
	DBF       D0,L0016
	MOVEQ     #$17,D0 
L0017	DBF       D0,L0017
	MOVE.B    #0,$FFFF820A.W
	MOVEQ     #6,D0 
L0018	DBF       D0,L0018
	MOVE.B    #2,$FFFF820A.W
NEW_68	RTE 

;	DC.B	'12345678901234567890123456',0
BOOTMESS	DC.B      ' A GIFT FROM MUG U.K',$bf,' !!!',0
	EVEN

BLANKS	DS.B	64