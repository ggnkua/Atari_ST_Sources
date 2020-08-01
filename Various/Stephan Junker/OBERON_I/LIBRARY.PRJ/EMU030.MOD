MODULE Emu030; (* SJ 19.10.94 *)



VAR
  result-, result2- : LONGINT;



PROCEDURE MulsL*(src, dest: LONGINT);
 BEGIN
  ASSEMBLER

	MOVEM.L	D0-D2,-(SP)

	MOVE.L  src(A6),D1
	MOVE.L  dest(A6),D0

        TST.L   D0
        BPL     l1
        NEG.L   D0
        TST.L   D1
        BPL     l2
        NEG.L   D1
mulpos:	BSR     mul
        BRA	ende

l1:	TST.L   D1
        BPL     mulpos
        NEG.L   D1
l2:	BSR     mul
        BVS     ende
        NEG.L   D0
ende:
	MOVE.L	D0,result
	MOVEM.L	(SP)+,D0-D2
	RETURN

mul:	MOVE.W  D0,D2
        MULU    D1,D2   ; loD1 * loD0
        SWAP    D0
        TST.W   D0
        BEQ     d0word  ; hiD0 = 0  ->  hiD1 * loD0
        MULU    D1,D0   ; loD1 * hiD0
        SWAP    D0
        TST.W   D0
        BNE     over
        SWAP    D1
        TST.W   D1
        BNE     over    ; hiD1 # 0  -> overflow
        ADD.L   D2,D0
        BMI     over
        RTS
d0word:
	SWAP    D0
        SWAP    D1
        MULU    D1,D0   ; hiD1 * loD0
        SWAP    D0
        TST.W   D0
        BNE     over
        ADD.L   D2,D0
        BMI     over
        RTS
over:
	MOVEQ   #0,D0
        ORI     #2,CCR  ; Overflow-Bit setzen
        RTS

  END
 END MulsL;


PROCEDURE MuluL*(src, dest: LONGINT);
 BEGIN
  ASSEMBLER

	MOVEM.L	D0-D2,-(SP)

	MOVE.L  src(A6),D1
	MOVE.L  dest(A6),D0

        MOVE.W  D0,D2
        MULU    D1,D2   ; loD1 * loD0
        SWAP    D0
        TST.W   D0
        BEQ     d0word  ; hiD0 = 0  ->  hiD1 * loD0
        MULU    D1,D0   ; loD1 * hiD0
        SWAP    D0
        TST.W   D0
        BNE     over
        SWAP    D1
        TST.W   D1
        BNE     over    ; hiD1 # 0  -> overflow
        ADD.L   D2,D0
        BRA	res
d0word:
	SWAP    D0
        SWAP    D1
        MULU    D1,D0   ; hiD1 * loD0
        SWAP    D0
        TST.W   D0
        BNE     over
        ADD.L   D2,D0
        BRA	res

over:   MOVEQ   #0,D0
        ORI     #1,CCR  ; Carry-Bit setzen
res:
	MOVE.L	D0,result
	MOVEM.L	(SP)+,D0-D2

  END
 END MuluL;


PROCEDURE DivsL*(src, dest: LONGINT);
 BEGIN
  ASSEMBLER

	MOVEM.L	D0-D7,-(SP)
	MOVE.L  src(A6),D1
	MOVE.L  dest(A6),D0
	BSR     divs_l
	MOVEM.L	D0-D1,result
	MOVEM.L	(SP)+,D0-D7
	RETURN

divs_l*:
	CLR.B   D7
	TST.L   D0
	BPL     dls_0F
	BSET    #0,D7
	NEG.L   D0
dls_0F:	TST.L   D1
	BPL     dls_10
	BSET    #1,D7
	NEG.L   D1
dls_10:	MOVE.L  D1,D2
	MOVE.L  D0,D1
	CMP.L   #$FFFF,D2
	BHI     dlu_07
	CLR.W   D3
	DIVU    D2,D1
	BVC     dlu_06
	MOVE.W  D1,D4
	CLR.W   D1
	SWAP    D1
	DIVU    D2,D1
	MOVE.W  D1,D3
	MOVE.W  D4,D1
	DIVU    D2,D1
dlu_06:	SWAP    D3
	MOVE.W  D1,D3
	CLR.W   D1
	SWAP    D1
	BRA     dlu_0A
dlu_07:	CLR.L   D3
	MOVE.W  D1,D3
	SWAP    D3
	CLR.W   D1
	SWAP    D1
	MOVE.W  #$0F,D4
dlu_08:	LSL.L   #1,D3
	ROXL.L  #1,D1
	CMP.L   D2,D1
	BCS     dlu_09
	SUB.L   D2,D1
	ADDQ.W  #1,D3
dlu_09:	DBRA    D4,dlu_08
dlu_0A:	MOVE.L  D3,D0
	BTST    #0,D7
	BEQ     dls_11
	NEG.L   D1
dls_11:	BTST    #1,D7
	BEQ     dls_12
	NEG.L   D0
dls_12:	BTST    #0,D7
	BEQ     dls_13
	NEG.L   D0
dls_13:	RTS

  END
 END DivsL;


PROCEDURE DivuL*(src, dest: LONGINT);
 BEGIN
  HALT(21);
 END DivuL;


PROCEDURE MulslL*(src, dest, dest2: LONGINT);
 BEGIN
  HALT(21);
 END MulslL;


PROCEDURE MululL*(src, dest, dest2: LONGINT);
 BEGIN
  HALT(21);
 END MululL;


PROCEDURE DivslL*(src, dest, dest2: LONGINT);
 BEGIN
  ASSEMBLER

	MOVE.L	src(A6),-(SP)
	MOVE.L	dest2(A6),-(SP)
	BSR	DivsL
	ADDQ.L	#8,SP

  END;
 END DivslL;


PROCEDURE DivulL*(src, dest, dest2: LONGINT);
 BEGIN
  HALT(21);
 END DivulL;


END Emu030.
