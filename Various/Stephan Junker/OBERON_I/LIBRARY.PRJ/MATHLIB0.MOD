MODULE MathLib0; (* SJ 9.4.93 / 19.8.94 *)


IMPORT
  Sys, MathCom;


PROCEDURE sqrt* (x: REAL): REAL;
  VAR
    a: ARRAY 20 OF SHORTINT;
 BEGIN
  ASSEMBLER

                BRA     T_187920

T_1878BC:       LINK    A6,#-$06
                MOVE.L  #$3F800000,-$06(A6)
                MOVE.W  #1,-$02(A6)
                MOVE.W  8(A6),-(SP)
T_1878D2:       MOVE.W  -$02(A6),D2
                CMP.W   (SP),D2
                BHI     T_187900
                FMOVE.S -$06(A6),FP0
                FMUL.S  #$40000000,FP0
                FMOVE.S FP0,-$06(A6)
                ADDQ.W  #1,-$02(A6)
                BCC     T_1878D2
T_187900:       ADDQ.L  #2,SP
                FMOVE.S -$06(A6),FP0
                UNLK    A6
                MOVEA.L (SP)+,A0
                ADDQ.L  #2,SP
                JMP     (A0)

T_187920:       FMOVE.S 8(A6),FP0
                FCMP.S  #0,FP0
                FBGE    T_187948
                MOVE.W  #Sys.REALERR,-(SP)
                JSR     Sys.halt
T_187948:       BNE     T_187970
                MOVEQ   #0,D0
                BRA     T_187B74
T_187970:       MOVE.L  8(A6),-(SP)
                PEA     -$0A(A6)
                JSR     MathCom.frexp
                ADDQ.W  #8,SP
                FMOVE.S FP0,-$04(A6)
T_187988:       FMOVE.S -$04(A6),FP0
                FCMP.S  #$3F000000,FP0
                FBGE    T_1879C8
                FMUL.S  #$40000000,FP0
                FMOVE.S FP0,-$04(A6)
                SUBQ.W  #1,-$0A(A6)
                BRA     T_187988
T_1879C8:       MOVE.W  -$0A(A6),D2
                ANDI.W  #1,D2
                TST.B   D2
                BEQ     T_1879F8
                FMOVE.S -$04(A6),FP0
                FMUL.S  #$40000000,FP0
                FMOVE.S FP0,-$04(A6)
                SUBQ.W  #1,-$0A(A6)
T_1879F8:       FMOVE.S #$3F800000,FP0
                FADD.S  -4(A6),FP0
                FMUL.S  #$3F000000,FP0
                FMOVE.S FP0,-$08(A6)
T_187A2E:       CMPI.W  #$3C,-$0A(A6)
                BLE     T_187A5E
                FMOVE.S -$08(A6),FP0
                FMUL.S  #$4E800000,FP0
                FMOVE.S FP0,-$08(A6)
                SUBI.W  #$3C,-$0A(A6)
                BRA     T_187A2E
T_187A5E:       CMPI.W  #-$3C,-$0A(A6)
                BGE     T_187A8E
                FMOVE.S -$08(A6),FP0
                FDIV.S  #$4E800000,FP0
                FMOVE.S FP0,-$08(A6)
                ADDI.W  #$3C,-$0A(A6)
                BRA     T_187A5E
T_187A8E:       TST.W   -$0A(A6)
                BLT     T_187ACC
                SUBQ.L  #4,SP
                MOVE.W  -$0A(A6),D2
                EXT.L   D2
                DIVS    #2,D2
                CHK     #$7FFF,D2
                MOVE.W  D2,-(SP)
                BSR     T_1878BC
                FMUL.S  -$08(A6),FP0
                FMOVE.S FP0,-$08(A6)
                BRA     T_187B00
T_187ACC:       SUBQ.L  #4,SP
                MOVE.W  -$0A(A6),D2
                EXT.L   D2
                DIVS    #2,D2
                NEG.W   D2
                CHK     #$7FFF,D2
                MOVE.W  D2,-(SP)
                BSR     T_1878BC
                FMOVE.S -$08(A6),FP1
                FDIV.S  FP0,FP1
                FMOVE.S FP1,-$08(A6)
T_187B00:       CLR.W   -$0C(A6)
T_187B04:       CMPI.W  #4,-$0C(A6)
                BHI     T_187B5E
                FMOVE.S 8(A6),FP0
                FDIV.S  -$08(A6),FP0
                FADD.S  -$08(A6),FP0
                FMUL.S  #$3F000000,FP0
                FMOVE.S FP0,-$08(A6)
                ADDQ.W  #1,-$0C(A6)
                BCC     T_187B04
T_187B5E:       FMOVE.S -$08(A6),FP0
T_187B74:
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END sqrt;


PROCEDURE exp* (x: REAL): REAL;
  VAR
    a: ARRAY 20 OF SHORTINT;
 BEGIN
  ASSEMBLER

                FMOVE.S 8(A6),FP0
                FCMP.S  #0,FP0
                FBNE    T_187BB0
                FMOVE.S #$3F800000,FP0
                BRA     T_187E06
T_187BB0:       FCMP.S  #$C61C4000,FP0
                FBGE    T_187BD8
                FMOVE.S #0,FP0
                BRA     T_187E06
T_187BD8:       FCMP.S  #$461C4000,FP0
                FBLE    T_187C00
                MOVE.W  #Sys.REALERR,-(SP)
                JSR     Sys.halt
T_187C00:       FMUL.S  #$3FB8AA3C,FP0
                FMOVE.S FP0,8(A6)
                FMOVE.L FP0,D0
                MOVE.W  D0,-$02(A6)
                FMOVE.L D0,FP2
                FMOVE.S 8(A6),FP1
                FSUB.S  FP2,FP1
                FSUB.S  #$3F000000,FP1
                FMOVE.S FP1,-$06(A6)
                FMUL.S  FP1,FP1
                FMOVE.S FP1,-$0A(A6)
                FMUL.S  #$4272759B,FP1
                FADD.S  #$46EC9DF1,FP1
                FMUL.S  -$0A(A6),FP1
                FADD.S  #$49FDF400,FP1
                FMUL.S  -$06(A6),FP1
                FMOVE.S FP1,-$0E(A6)
                FMOVE.S -$0A(A6),FP2
                FADD.S  #$44DAA92F,FP2
                FMUL.S  -$0A(A6),FP2
                FADD.S  #$48A005A4,FP2
                FMUL.S  -$0A(A6),FP2
                FADD.S  #$4AB73040,FP2
                FMOVE.S FP2,-$12(A6)
                FADD.S  -$0E(A6),FP2
                FMUL.S  #$3FB504F3,FP2
                FMOVE.S -$12(A6),FP3
                FSUB.S  -$0E(A6),FP3
                FDIV.S  FP3,FP2
                FMOVE.S FP2,-(SP)
                MOVE.W  -$02(A6),-(SP)
                JSR     MathCom.ldexp
                ADDQ.L  #6,SP
T_187E06:
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END exp;


PROCEDURE ln* (x: REAL): REAL;
  VAR
    a: ARRAY 20 OF SHORTINT;
 BEGIN
  ASSEMBLER

                FMOVE.S 8(A6),FP0
                FCMP.S  #0,FP0
                FBGT    T_187E42
                MOVE.W  #Sys.REALERR,-(SP)
                JSR     Sys.halt
T_187E42:       FMOVE.S FP0,-(SP)
                PEA     -$06(A6)
                JSR     MathCom.frexp
                ADDQ.W  #8,SP
                FMOVE.S FP0,8(A6)
T_187E5A:       FMOVE.S 8(A6),FP0
                FCMP.S  #$3F3504F3,FP0
                FBGE    T_187E9A
                FMUL.S  #$40000000,FP0
                FMOVE.S FP0,8(A6)
                SUBQ.W  #1,-$06(A6)
                BRA     T_187E5A
T_187E9A:       FMOVE.S 8(A6),FP0
                FSUB.S  #$3F800000,FP0
                FMOVE.S 8(A6),FP1
                FADD.S  #$3F800000,FP1
                FDIV.S  FP1,FP0
                FMOVE.S FP0,8(A6)
                FMUL.S  FP0,FP0
                FMOVE.S FP0,-$04(A6)
                FMUL.S  #$3ED798C1,FP0
                FADD.S  #$C11A33FB,FP0
                FMUL.S  -$04(A6),FP0
                FADD.S  #$41F7A888,FP0
                FMUL.S  -$04(A6),FP0
                FADD.S  #$C1C01C7D,FP0
                FMOVE.S -$04(A6),FP1
                FADD.S  #$C10E93E7,FP1
                FMUL.S  -$04(A6),FP1
                FADD.S  #$419BD902,FP1
                FMUL.S  -$04(A6),FP1
                FADD.S  #$C1401C78,FP1
                FDIV.S  FP1,FP0
                FMUL.S  8(A6),FP0
                MOVE.W  -$06(A6),D0
                EXT.L   D0
                FMOVE.L D0,FP1
                FMUL.S  #$3F317217,FP1
                FADD.S  FP1,FP0
T_188086:
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END ln;


PROCEDURE Proc1;
  VAR
    dummy: ARRAY 9 OF INTEGER;
 BEGIN
  ASSEMBLER

                FMOVE.S 10(A6),FP0
                FCMP.S  #0,FP0
                FBGE    T_1875A0
                FNEG.S  FP0
                FMOVE.S FP0,10(A6)
                ADDQ.W  #2,8(A6)
T_1875A0:       FMUL.S  #$3F22F984,FP0
                FMOVE.S FP0,10(A6)
                FCMP.S  #$46FFF800,FP0
                FBLE    T_18764A
                FMOVE.S FP0,-(SP)
                PEA     -$0E(A6)
                JSR     MathCom.modf
                ADDQ.W  #8,SP
                FMOVE.S FP0,-$04(A6)
                MOVE.W  8(A6),D2
                ADD.W   D2,-$0E(A6)
                EXT.L   D2
                FMOVE.L D2,FP1
                FMUL.S  #$3E800000,FP1
                FMOVE.S FP1,-(SP)
                PEA     -$10(A6)
                JSR     MathCom.modf
                ADDQ.W  #8,SP
                FMOVE.S FP0,-$08(A6)
                MOVE.W  -$10(A6),D2
                ASL.W   #2,D2
                MOVE.W  -$0E(A6),D4
                SUB.W   D2,D4
                MOVE.W  D4,8(A6)
                BRA     T_18769C
T_18764A:       FMOVE.S 10(A6),FP0
                FMOVE.L FP0,D0
                MOVE.W  D0,-$12(A6)
                FMOVE.L D0,FP0
                FMOVE.S 10(A6),FP1
                FSUB.S  FP0,FP1
                FMOVE.S FP1,-$04(A6)
                MOVE.W  8(A6),D2
                ADD.W   -$12(A6),D2
                EXT.L   D2
                DIVS    #4,D2
                SWAP    D2
                MOVE.W  D2,8(A6)
T_18769C:       MOVE.W  8(A6),D2
                ANDI.W  #1,D2
                TST.B   D2
                BEQ     T_1876C8
                FMOVE.S #$3F800000,FP0
                FSUB.S  -4(A6),FP0
                FMOVE.S FP0,-$04(A6)
T_1876C8:       CMPI.W  #1,8(A6)
                BLE     T_1876E8
                FMOVE.S -$04(A6),FP0
                FNEG.S  FP0
                FMOVE.S FP0,-$04(A6)
T_1876E8:       FMOVE.S -4(A6),FP0
                FMUL.S  FP0,FP0
                FMOVE.S FP0,-$0C(A6)
                FMUL.S  #$4311F803,FP0
                FADD.S  #$C6585D15,FP0
                FMUL.S  -$0C(A6),FP0
                FADD.S  #$48D6E4E0,FP0
                FMUL.S  -$0C(A6),FP0
                FADD.S  #$CA96D878,FP0
                FMUL.S  -$0C(A6),FP0
                FADD.S  #$4B4F3258,FP0
                FMUL.S  -4(A6),FP0
                FMOVE.S -$0C(A6),FP1
                FADD.S  #$4304A745,FP1
                FMUL.S  -$0C(A6),FP1
                FADD.S  #$4613DC63,FP1
                FMUL.S  -$0C(A6),FP1
                FADD.S  #$48C74E66,FP1
                FMUL.S  -$0C(A6),FP1
                FADD.S  #$4B03E7CE,FP1
                FDIV.S  FP1,FP0

  END(*ASSEMBLER*);
 END Proc1;


PROCEDURE sin* (x: REAL): REAL;
 BEGIN
  ASSEMBLER

                MOVE.L  8(A6),-(SP)
                CLR.W   -(SP)
                BSR     Proc1
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END sin;


PROCEDURE cos* (x: REAL): REAL;
 BEGIN
  ASSEMBLER

                FMOVE.S 8(A6),FP0
                FCMP.S  #0,FP0
                FBGE    T_188100
                FNEG.S  FP0
T_188100:       FMOVE.S FP0,-(SP)
                MOVE.W  #1,-(SP)
                BSR     Proc1
                ADDQ.L  #6,SP
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END cos;


PROCEDURE arctan* (x: REAL): REAL;
 BEGIN
  ASSEMBLER

                FMOVE.S 8(A6),FP0
                FCMP.S  #0,FP0
                FBLE    T_18816E
                FMOVE.S FP0,-(SP)
                JSR     MathCom.sarctan
                ADDQ.W  #4,SP
                BRA     T_1881B0
T_18816E:       FNEG.S  FP0
                FMOVE.S FP0,-(SP)
                JSR     MathCom.sarctan
                ADDQ.L  #4,SP
                FNEG.S  FP0
T_1881B0:
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END arctan;


END MathLib0.
