MODULE MathCom; (* SJ 9.4.93 / 19.8.94 *)


IMPORT
  Sys;


CONST
  pi*     = 3.1415926535897932384626434;
  twoopi* = 2.0 / pi;
  pio2*   = pi / 2.0;
  pio4*   = pi / 4.0;
  sqrt2*  = 1.4142135623730950488016887;


PROCEDURE frexp* (value: REAL; VAR exp: INTEGER): REAL;
  (* Returns the real mantissa x of value and an integer exp
     such that value = x * 2 ** exp *)
 BEGIN
  ASSEMBLER

                MOVE.W  12(A6),D2       ; Exponent
                ANDI.W  #$7F80,D2       ; extrahieren
                LSR.W   #7,D2
                SUBI.W  #$80,D2
                MOVEA.L 8(A6),A3        ; VAR exp
                MOVE.W  D2,(A3)         ; speichern
                MOVE.L  12(A6),D0       ; Value
                ANDI.L  #$807FFFFF,D0   ; ohne exp
                ORI.L   #$40000000,D0   ; exp = 0
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END frexp;


PROCEDURE ldexp* (value: REAL; exp: INTEGER): REAL;
  (* Returns value * 2 ** exp *)
 BEGIN
  ASSEMBLER

                MOVE.W  8(A6),D1        ;max := exp
                BEQ     le_retvalue     ;IF max # 0
                BPL     le_maxok        ; IF max < 0
                NEG.W   D1              ;  -max
le_maxok:                               ; END
                MOVE.L  #$40000000,D3   ; r := 2.0
                MOVEQ   #1,D2           ; i := 1
le_while:       CMP.W   D1,D2           ; WHILE i < max DO
                BGE     le_muldiv
                ADD.L   #$800000,D3     ;  r := r * 2.0
                ADDQ.W  #1,D2           ;  INC(i)
                BRA     le_while        ; END

le_muldiv:      TST.W   8(A6)           ; IF exp < 0
                BGE     le_mul
                FMOVE.S	value,FP0
                FDIV.S	D3,FP0		;  RETURN value / r
                UNLK    A6
                RTS

le_mul:         FMOVE.S	value,FP0
                FMUL.S	D3,FP0		; ELSE RETURN value * r
                UNLK    A6
                RTS                     ; END

le_retvalue:    MOVE.L  10(A6),D0       ;ELSE RETURN value
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END ldexp;


PROCEDURE modf* (value: REAL; VAR int: INTEGER): REAL;
  (* Returns the positive fractional part of value and (by int)
     the integer part *)
 BEGIN
  ASSEMBLER

                MOVE.L  12(A6),D3       ; Realzahl
                SMI     D2              ; neg
                LSL.L   #1,D3           ; Vorzeichen rausschieben
                ROL.L   #8,D3           ; Exponent nach unten
                CLR.W   D1
                MOVE.B  D3,D1           ; in D1
                MOVE.B  #1,D3
                ROR.L   #1,D3
                SUBI.W  #$7F,D1         ; Exponent - 7F
                BGE     ens_2           ; positiv ->
ens_1:          MOVEA.L 8(A6),A0
                CLR.W   (A0)            ; sonst kein Int
                MOVE.L  12(A6),D0       ; nur frac
                BRA     ens_ret
ens_2:          SUBI.W  #$1F,D1         ; - 1F
                NEG.W   D1
                BLT     RealErr         ; šberlauf ->
                SUBQ.W  #1,D1
                MOVEQ   #0,D0
                BRA     ens_dec
ens_3:          LSR.L   #1,D3
                ROXR.L  #1,D0           ; rausgeschobene Bits in D0
ens_dec:        DBRA    D1,ens_3
                TST.B   D2              ; neg ?
                BEQ     ens_ok
                NEG.L   D3              ; negieren
ens_ok:         MOVEA.L 8(A6),A0
                MOVE.W  D3,(A0)         ; speichern
                TST.L   D0              ; frac = 0 ?
                BEQ     ens_ret         ; ja ->
                MOVE.L  #$3F800000,D1   ; exp = 0
ens_shift:      SUB.L   #$800000,D1     ; exp-1
                LSL.L   #1,D0           ; 1 suchen
                BCC     ens_shift
                LSR.L   #8,D0
                LSR.L   #1,D0           ; richtige Position
                OR.L    D1,D0           ; exp drauf
ens_ret:        UNLK    A6
                RTS

RealErr:        MOVE.W  #Sys.REALERR,-(SP)
                JSR     Sys.halt
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END modf;


PROCEDURE sarctan* (arg: REAL): REAL;
  (* Reduces its positive argument to the range {0 .. 0.414}
     and calls xatan *)
 BEGIN
  ASSEMBLER

                BRA     sa_1

sa_sub:         LINK    A6,#-$04        ; lokal zu sarctan
                FMOVE.S	arg,FP0
                FMUL.S	FP0,FP0         ; Quadrat
                FMUL.S  #$41813AA7,FP0
                FMUL.S  -4(A6),FP0
                FADD.S  #$449020ED,FP0
                FMUL.S  -4(A6),FP0
                FADD.S  #$44DE8CFD,FP0
                FMUL.S  -4(A6),FP0
                FADD.S  #$4460324C,FP0
                FMOVE.S -4(A6),FP1
                FADD.S  #$426BD3F0,FP1
                FMUL.S  -4(A6),FP1
                FADD.S  #$440610FB,FP1
                FMUL.S  -4(A6),FP1
                FADD.S  #$44D0590E,FP1
                FMUL.S  -4(A6),FP1
                FADD.S  #$4501F558,FP1
                FMUL.S  -4(A6),FP1
                FADD.S  #$4460324C,FP1
                FDIV.S	FP1,FP0
                FMUL.S  8(A6),FP0
                UNLK    A6
                MOVEA.L (SP)+,A0
                ADDQ.W  #4,SP
                JMP     (A0)

sa_1:           FMOVE.S 8(A6),FP0     ; arg
                FCMP.S  #$3ED413CC,FP0
                FBGE    sa_2
                MOVE.L  8(A6),-(SP)
                BSR     sa_sub
                BRA     sa_4

sa_2:           FMOVE.S 8(A6),FP0     ; arg
                FCMP.S  #$401A827A,FP0
                FBLE    sa_3
                FMOVE.S #$3F800000,FP1
                FDIV.S  8(A6),FP1
                FMOVE.S	FP1,-(SP)
                BSR     sa_sub
                FMOVE.S #$3FC90FDA,FP1
                FSUB.S  FP0,FP1
                FMOVE.S	FP1,FP0
                BRA     sa_4

sa_3:           FMOVE.S 8(A6),FP0
                FSUB.S  #$3F800000,FP0
                FMOVE.S 8(A6),FP1
                FADD.S  #$3F800000,FP1
                FDIV.S	FP1,FP0
                FMOVE.S FP0,-(SP)
                BSR     sa_sub
                FADD.S  #$3F490FDA,FP0
sa_4:
                UNLK    A6
                RTS

  END(*ASSEMBLER*);
 END sarctan;

END MathCom.