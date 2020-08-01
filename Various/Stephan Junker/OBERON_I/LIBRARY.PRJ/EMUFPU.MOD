MODULE EmuFPU; (* SJ 19.10.94 *)


IMPORT
  SYSTEM, Sys;


TYPE
  FPnDef = INTEGER;
  Real   = LONGINT;
  LReal  = ARRAY 2 OF LONGINT;



VAR
  result-: LONGINT;  (* output of FMoveLFX (dest may be Dn) *)

  sregs: ARRAY 8 OF Real; sregvalid: ARRAY 8 OF BOOLEAN;
  lregs: ARRAY 8 OF LReal; lregvalid: ARRAY 8 OF BOOLEAN;



PROCEDURE FMoveSFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  sregs[dest] := sregs[src]; sregvalid[dest] := sregvalid[src];
  lregs[dest] := lregs[src]; lregvalid[dest] := lregvalid[src];
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveSFF;


PROCEDURE FMoveDFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  sregs[dest] := sregs[src]; sregvalid[dest] := sregvalid[src];
  lregs[dest] := lregs[src]; lregvalid[dest] := lregvalid[src];
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveDFF;


PROCEDURE FMoveSXF*(src: Real; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  sregs[dest] := src; sregvalid[dest] := TRUE;
  lregvalid[dest] := FALSE;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveSXF;


PROCEDURE FMoveDXF*(src: LReal; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  sregvalid[dest] := FALSE;
  lregs[dest] := src; lregvalid[dest] := TRUE;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveDXF;

(*
PROCEDURE LIntToReal(i : LONGINT) : Real;
 BEGIN
  ASSEMBLER
  MOVE.L  i(A6),D0
  TST.L   D0
  BEQ     fls_37
  SMI     D2
  BPL     fs_1
  NEG.L   D0
fs_1:  MOVE.W  #$9E,D1
  CMP.L   #$FFFF,D0
  BHI     fls_35
  SWAP    D0
  SUB.W   #$10,D1
fls_35:  CMP.L   #$FFFFFF,D0
  BHI     fls_36
  LSL.L   #8,D0
  SUBQ.W  #8,D1
fls_36:  LSL.L   #1,D0
  DBCS    D1,fls_36
  MOVE.B  D1,D0
  ROR.L   #8,D0
  LSR.W   #1,D2           ; Vorzeichen in X
  ROXR.L  #1,D0
fls_37:
  UNLK  A6
  RTS
  END
 END LIntToReal;
*)

PROCEDURE LIntToLReal(i: LONGINT; reg: FPnDef);
(* Neu: LONGINT -> LONGREAL *)
 BEGIN
  ASSEMBLER
        MOVEQ     #0,D0
        MOVE.L    #1023+21-16+31,D7 ; Bias + Bits in ob. Mant. + max. Exponent
        MOVE.L    i,D1
        BEQ.B     ende        ; B: Null bleibt Null
        BPL.B     tst16       ; B: positive Zahl
        BSET      #11,D7      ; neg. Vorzeichen setzen
        NEG.L     D1          ; Mantisse immer Absolutwert
tst16:
        CMPI.L    #$FFFF,D1
        BHI.B     tst24
        SWAP      D1
        SUBI.W    #16,D7
tst24:
        CMPI.L    #$FFFFFF,D1
        BHI.B     shift
        LSL.L     #8,D1
        SUBQ.W    #8,D7
shift:
        SWAP      D1
        MOVE.W    D1,D0
        CLR.W     D1
shleft:                       ; Normalisieren der Mantisse
        LSL.L     #1,D1       ;
        ROXL.L    #1,D0       ;
        SUBQ.W    #1,D7       ;
tstlp:
        BTST      #20,D0      ;
        BEQ.B     shleft      ;
        BCLR      #20,D0      ; impl. Eins loeschen
        LSL.W     #4,D7       ; Exponent in richtige Position
        SWAP      D7          ;
        OR.L      D7,D0       ; und setzen
ende:
        LEA     lregs,A0
        MOVE    reg,D5
        LSL     #3,D5
        MOVEM.L D0-D1,(A0,D5.W)
  END
 END LIntToLReal;

PROCEDURE FMoveLXF*(src: LONGINT; dest: FPnDef);
 BEGIN
  ASSEMBLER
        MOVEM.L D0-A5,-(SP)
  END;
  LIntToLReal(src, dest); sregvalid[dest] := FALSE;
  lregvalid[dest] := TRUE;
  ASSEMBLER
        MOVEM.L (SP)+,D0-A5
  END;
 END FMoveLXF;


PROCEDURE RealToLReal(reg: FPnDef);
 BEGIN
  ASSEMBLER
  MOVE  reg,D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0

flong:  MOVEQ   #0,D2
  MOVEQ   #0,D1
  TST.L   D0
  BPL     flg_A6
  BSET    #31,D2
flg_A6:  LSL.L   #1,D0
  ROL.L   #8,D0
  MOVE.B  D0,D2
  BNE     flg_A7
  MOVEQ   #0,D0
  BRA     flg_AB
flg_A7:  ADDI.W  #$0380,D2
  ASL.W   #4,D2
  BCLR    #31,D2
  BEQ     flg_A8
  BSET    #15,D2
flg_A8:  SWAP    D2
  MOVE.B  #0,D0
  MOVE.W  #$0C,D3
  BRA     flg_AA
flg_A9:  LSR.L   #1,D0
  ROXR.L  #1,D1
flg_AA:  DBRA    D3,flg_A9
  OR.L    D2,D0
flg_AB:  LEA  lregs,A0
  ADD  D5,D5
  MOVEM.L D0-D1,(A0,D5.W)
  MOVE  reg,D5
  LEA  lregvalid,A0
  MOVE.B  #1,(A0,D5)

  END
 END RealToLReal;


PROCEDURE LRealToReal(reg: FPnDef);
 BEGIN
  ASSEMBLER

        MOVE    reg,D5
        LSL     #3,D5
        LEA     lregs,A0
        MOVEM.L (A0,D5.W),D0-D1

        MOVEQ   #0,D2
        SWAP    D0             ; Exponent, Vorzeichen ins untere Wort
        MOVE.W  D0,D1          ; Vorzeichen in nicht ben. Mantisse aufbewahren
        SWAP    D1
        MOVE.W  #$7FF0,D2
        AND.W   D0,D2          ; d2 := Exponent
        ANDI.W  #$000F,D0      ; d0 : nur Mantisse
        SWAP    D0             ;
        SUBI.W  #$3800,D2      ; (1023-127)<<4 Differenz von LONGREAL- und REAL-Bias
        LSL.L   #3,D0          ; Mantisse 3 Bits nach links
        ROL.W   #3,D1          ; einschliesslich 3 Bit Uebertrag
        ANDI.B  #7,D1          ; von unterer Mantisse
        OR.B    D1,D0          ;
        TST.W   D1             ; muss aufgerundet werden ?
        BPL     tstexp         ; B: nein, Bit hinter Mantisse nicht gesetzt
        ADDQ.L  #1,D0          ; sonst Mantisse aufrunden
        BCLR    #23,D0         ; falls Mantisse $7FFFF war, Uebertrag loeschen
                               ; Mantisse ist dann Null, so dass nicht nach rechts
                               ; geschoben zu werden braucht
        BEQ     tstexp         ; B: kein Uebertrag
        ADDI.W  #$0010,D2      ; 1<<4 sonst als Ausgleich fuer das "Schieben",
                               ; Exponent um Eins erhoehen
tstexp:
        TST.W   D2             ; Exponent <= Null ?
        BLE     null           ; B: ja, zu klein fuer REAL
        CMPI.W  #$0FE0,D2      ; 254<<4
        BHI     ofl            ; B: zu gross fuer REAL
        LSL.W   #3,D2          ; Exponent in richtige Position
        SWAP    D2
        OR.L    D2,D0          ; im Ergebnis plazieren
        ADD.L   D0,D0
        ADD.L   D1,D1          ; Vorzeichen ins X/C-Bit
        ROXR.L  #1,D0          ; und ins Ergebnis
        BRA     ende
null:
        MOVEQ   #0,D0
        BRA     ende
ofl:
RealErr*:
        MOVE.W  #Sys.REALERR,-(SP)
        JSR     Sys.halt
        ADDQ.W  #2,SP
        BRA     skip

ende:
        LEA     sregs,A0
        LSR     #1,D5
        MOVE.L  D0,(A0,D5.W)
        MOVE    reg,D5
        LEA     sregvalid,A0
        MOVE.B  #1,(A0,D5)

skip:
  END
 END LRealToReal;

PROCEDURE FMoveSFX*(src: FPnDef; dest: SYSTEM.PTR);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~sregvalid[src] THEN LRealToReal(src) END;
  SYSTEM.PUT(dest, sregs[src]);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveSFX;


PROCEDURE FMoveDFX*(src: FPnDef; dest: SYSTEM.PTR);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[src] THEN RealToLReal(src) END;
  SYSTEM.PUT(dest, lregs[src]);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveDFX;


PROCEDURE TruncS(src: Real) : LONGINT;
 BEGIN
  ASSEMBLER

  MOVE.L  src,D0
  TST.L   D0              ; Positiv ?
  SMI     D2              ; ja   D2 = 0
trs_39:  LSL.L   #1,D0           ; Vorzeichen rausschieben
  ROL.L   #8,D0           ; Exponent nach unten
  CLR.W   D1
  MOVE.B  D0,D1           ; in D1
  MOVE.B  #1,D0
  ROR.L   #1,D0
  SUBI.W  #$7F,D1         ; Exponent - 7F
  BGE     trs_3B          ; positiv ->
trs_3A:  MOVEQ   #0,D0           ; sonst kein Int
  BRA     trs_3D
trs_3B:  SUBI.W  #$1F,D1         ; - 1F
  NEG.W   D1
  BLT     RealErr         ; šberlauf ->
trs_3C:  LSR.L   D1,D0
  TST.B   D2              ; negativ ?
  BEQ     trs_3D          ; nein ->
  NEG.L   D0              ; ja   negieren
trs_3D:
  UNLK  A6
  RTS

  END;
 END TruncS;


PROCEDURE TruncD(src: LReal) : LONGINT;
 BEGIN
  ASSEMBLER

        MOVEM.L src,D0-D1

        MOVE.L  D0,D2          ; d2 := Vorzeichen + Exponent
        SMI     D3             ; S: Zahl negativ, Vorzeichen merken
        SWAP    D2             ; Exponent als CARDINAL-Zahl
        LSR.W   #4,D2          ;
        ANDI.W  #$07FF,D2      ;
        SUBI.W  #1023,D2       ;
        BGE     tstofl         ; B: Zahl >= 1
        MOVEQ   #0,D0          ; Zahlen kleiner als Eins werden zu Null
        BRA     ende           ;
tstofl:
        ANDI.L  #$000FFFFF,D0  ; Mantisse isolieren
        CMPI.W  #31,D2         ; Zahl zu gross fuer LONGINT?
        BGT     RealErr        ; B: ja
        BLT     shift          ; B: auf keinen Fall, da < 2^31
        TST.B   D3             ; Exponent genau 2^31, Zahl negativ?
        BEQ     RealErr        ; B: nein, Zahl >= 2^31 nicht darstellbar
        TST.L   D0             ; |Zahl| <= 2^31+2^10 ?
        BNE     RealErr        ; B: nein
        CMPI.L  #$00200000,D1  ; |Zahl| < 2^31+1 ?
        BHS     RealErr        ; B: nein, nicht darstellbar
shift:
        BSET    #20,D0         ; implizite Eins setzen
        SUBI.W  #20,D2         ; wenn Zahl <= 2^20, direkt nach rechts schieben
        BGT     shiftleft      ; B: > 2^20
        NEG.W   D2             ;
        LSR.L   D2,D0          ;
        BRA     tstsign
leftlp:                        ; sonst nach links schieben
        ADD.L   D1,D1          ;
        ADDX.L  D0,D0          ;
shiftleft:                     ;
        DBRA    D2,leftlp      ;
tstsign:
        TST.B   D3             ; Zahl negativ?
        BEQ     ende           ; B: nein, positiv -> fertig
        NEG.L   D0             ; sonst negativ machen
ende:

        UNLK    A6
        RTS

  END
 END TruncD;


PROCEDURE FMoveLFX*(src: FPnDef);
  VAR
    li: LONGINT;
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF sregvalid[src] THEN li := TruncS( sregs[src])
  ELSE li := TruncD( lregs[src])
  END;
  result := li;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMoveLFX;


PROCEDURE MulReal(f1: Real; f2: FPnDef);
 BEGIN
  ASSEMBLER
  MOVE.W  f2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0
  MOVE.L  f1(A6),D1

  MOVE.L  D0,D4
  MOVE.L  D1,D6
  MOVE.L  D4,D7
  EOR.L   D6,D7
  SWAP    D4
  MOVE.W  D4,D5
  AND.W   #$7F80,D5
  BEQ     fms_24
  LSR.W   #7,D5
  AND.W   #$7F,D4
  OR.W    #$80,D4
  SWAP    D6
  MOVE.W  D6,D7
  AND.W   #$7F80,D7
  BEQ     fms_24
  LSR.W   #7,D7
  AND.W   #$7F,D6
  OR.W    #$80,D6
  ADD.W   D7,D5
  SUB.W   #$7E,D5
  BLT     fms_24
  MOVE.L  D4,D0
  SWAP    D0
  SWAP    D6
  MULU    D6,D0
  CLR.W   D0
  SWAP    D0
  MOVE.W  D4,D1
  MULU    D6,D1
  ADD.L   D1,D0
  MOVE.L  D4,D1
  SWAP    D1
  SWAP    D6
  MULU    D6,D1
  ADD.L   D1,D0
  MULU    D6,D4
  SWAP    D4
  ADD.L   D0,D4
  BMI     fms_22
  LSL.L   #1,D4
  SUBQ.W  #1,D5

fms_22:  ADD.L   #$80,D4
  BCC     fms_23
  ROXR.L  #1,D4
  ADDQ.W  #1,D5
fms_23:  TST.W   D5
  BMI     fms_24
  CMP.W   #$FF,D5
  BLT     fms_25
  BRA  RealErr
fms_24:  CLR.L   D4
  BRA     fms_26
fms_25:  LSL.L   #1,D4
  MOVE.B  D5,D4
  ROR.L   #8,D4
  ROXL.L  #1,D7
  ROXR.L  #1,D4
fms_26:  MOVE.L  D4,D0
fms_27:
  MOVE.W  f2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  D0,(A0,D5.W)

  END
 END MulReal;


PROCEDURE MulLReal(f1: LReal; f2: FPnDef);
 BEGIN
  ASSEMBLER
  MOVE  f2,D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVEM.L (A0,D5.W),D0-D1
  MOVEM.L f1(A6),D2-D3

  MOVE.L  D0,D4
  EOR.L   D2,D4
  MOVE.L  D0,D7
  MOVE.L  D2,D6
  CLR.W   D7
  SWAP    D7
  BEQ     fmd_5F
  CLR.W   D6
  SWAP    D6
  BEQ     fmd_5F
  TST.L   D4
  BPL     fmd_5A
  BSET    #31,D7
fmd_5A:  MOVE.L  #$0FFFFF,D5
  AND.L   D5,D0
  AND.L   D5,D2
  MOVEQ   #$14,D5
  BSET    D5,D0
  BSET    D5,D2
  ANDI.W  #$7FF0,D6
  ANDI.W  #$7FF0,D7
  SUBI.W  #$3FF0,D6
  ADD.W   D6,D7
  BVS     RealErr
  BLE     fmd_5F
  CMPI.L  #$100000,D0
  BNE     fmd_5C
  TST.L   D1
  BNE     fmd_5C
  MOVE.L  D2,D0
  MOVE.L  D3,D1
fmd_5B:  BRA     fmd_62
fmd_5C:  CMPI.L  #$100000,D2
  BNE     fmd_5D
  TST.L   D3
  BEQ     fmd_5B
fmd_5D:  MOVE.L  D7,-(SP)
  MOVEQ   #0,D5
  MOVEQ   #0,D7
  MOVE.W  D1,D6
  MULU    D3,D6
  MOVE.W  D5,D6
  SWAP    D6
  SWAP    D3
  MOVE.W  D1,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D1
  SWAP    D3
  MOVE.W  D1,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  MOVE.W  D6,-(SP)
  MOVE.W  D5,D6
  SWAP    D6
  MOVEQ   #0,D5
  MOVE.W  D0,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D3
  MOVE.W  D1,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D1
  MOVE.W  D1,D4
  MULU    D2,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  MOVE.W  D6,-(SP)
  MOVE.W  D5,D6
  SWAP    D6
  MOVEQ   #0,D5
  SWAP    D2
  MOVE.W  D1,D4
  MULU    D2,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D1
  SWAP    D2
  MOVE.W  D1,D4
  MULU    D2,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  MOVE.W  D0,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D0
  SWAP    D3
  MOVE.W  D0,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  MOVE.W  D6,-(SP)
  MOVE.W  D5,D6
  SWAP    D6
  MOVEQ   #0,D5
  SWAP    D3
  MOVE.W  D0,D4
  MULU    D3,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D0
  MOVE.W  D0,D4
  MULU    D2,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  SWAP    D2
  MOVE.W  D1,D4
  MULU    D2,D4
  ADD.L   D4,D6
  ADDX.W  D7,D5
  MOVE.W  D6,-(SP)
  MOVE.W  D5,D6
  SWAP    D6
  MOVEQ   #0,D5
  MOVE.W  D0,D4
  MULU    D2,D4
  ADD.L   D4,D6
  SWAP    D0
  SWAP    D2
  MOVE.W  D0,D4
  MULU    D2,D4
  ADD.L   D4,D6
  SWAP    D2
  MULU    D2,D0
  SWAP    D0
  ADD.L   D6,D0
  MOVEM.L (SP)+,D1-D2/D7
  MOVEQ   #4,D3
  MOVE.L  #-$10000000,D4
  BTST    #25,D0
  BEQ     fmd_5E
  ADDI.W  #$10,D7
  BMI     RealErr
  MOVEQ   #5,D3
  MOVE.L  #-$08000000,D4
fmd_5E:  ROR.L   D3,D0
  ROR.L   D3,D1
  LSR.L   D3,D2
  MOVE.L  D4,D5
  AND.L   D1,D5
  OR.L    D5,D2
  MOVE.L  D4,D5
  NOT.L   D5
  AND.L   D5,D1
  AND.L   D0,D4
  OR.L    D4,D1
  AND.L   D5,D0
  TST.L   D2
  BPL     fmd_62
  ADDQ.L  #1,D1
  BCC     fmd_61
  ADDQ.L  #1,D0
  CMPI.L  #$200000,D0
  BCS     fmd_62
  LSR.L   #1,D0
  ROXR.L  #1,D1
  ADDI.W  #$10,D7
  BPL     fmd_62
fmd_5F:  MOVEQ   #0,D0
  MOVEQ   #0,D1
  BRA     fmd_64
fmd_61:  CMPI.L  #-$80000000,D2
  BNE     fmd_62
  ANDI.B  #-2,D1
fmd_62:  ANDI.L  #$0FFFFF,D0
  SWAP    D7
  TST.W   D7
  BPL     fmd_63
  BSET    #31,D0
fmd_63:  CLR.W   D7
  OR.L    D7,D0
fmd_64:
  MOVE  f2,D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVEM.L D0-D1,(A0,D5.W)

  END
 END MulLReal;


PROCEDURE FMulSFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF sregvalid[src] THEN
    IF ~sregvalid[dest] THEN LRealToReal(dest) END;
    MulReal(sregs[src], dest);
  ELSIF sregvalid[dest] THEN
    LRealToReal(src);
    MulReal(sregs[src], dest);
  ELSE
    MulLReal(lregs[src], dest);
  END;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMulSFF;


PROCEDURE FMulDFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  IF ~lregvalid[src] THEN RealToLReal(src) END;
  MulLReal(lregs[src], dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMulDFF;


PROCEDURE FMulSXF*(src: Real; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~sregvalid[dest] THEN LRealToReal(dest) END;
  MulReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMulSXF;


PROCEDURE FMulDXF*(src: LReal; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  MulLReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FMulDXF;


PROCEDURE DivReal(d1: Real; d2 : FPnDef);
 BEGIN
  ASSEMBLER
  MOVE.L  d1(A6),D1
  MOVE.W  d2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0

  MOVE.L  D0,D4
  MOVE.L  D1,D6
  MOVE.L  D4,D7
  EOR.L   D6,D7
  LSL.L   #1,D6
  ROL.L   #8,D6
  CLR.W   D7
  MOVE.B  D6,D7
  BEQ     fds_2A
  MOVE.B  #1,D6
  ROR.L   #1,D6
  LSL.L   #1,D4
  ROL.L   #8,D4
  CLR.W   D5
  MOVE.B  D4,D5
  BEQ     fds_2B
  MOVE.B  #1,D4
  ROR.L   #1,D4
  SUB.W   D7,D5
  ADD.W   #$7F,D5
  SWAP    D6
  LSR.L   #1,D4
  DIVU    D6,D4
  MOVE.W  D4,D0
  CLR.W   D4
  DIVU    D6,D4
  SWAP    D4
  MOVE.W  D0,D4
  MOVE.L  D6,D0
  SWAP    D0
  MULU    D4,D0
  LSR.L   #1,D0
  DIVU    D6,D0
  AND.L   #$FFFF,D0
  LSL.L   #1,D0
  SWAP    D4
  SUB.L   D0,D4
  BMI     fds_28
  LSL.L   #1,D4
  SUBQ.W  #1,D5
fds_28:  ADD.L   #$80,D4
  BCC     fds_29
  ROXR.L  #1,D4
  ADDQ.W  #1,D5
fds_29:  TST.W   D5
  BMI     fds_2B
  CMP.W   #$FF,D5
  BLT     fds_2C
fds_2A:  BRA     RealErr
fds_2B:  CLR.L   D4
  BRA     fds_2D
fds_2C:  ROL.L   #1,D4
  MOVE.B  D5,D4
  ROR.L   #8,D4
  ROXL.L  #1,D7
  ROXR.L  #1,D4
fds_2D:  MOVE.L  D4,D0
fds_2E:
  MOVE.W  d2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  D0,(A0,D5.W)

  END
 END DivReal;


PROCEDURE DivLReal(d1: LReal; d2: FPnDef);
 BEGIN
(* Die Routine funktioniert im wesentlichen wie die schriftliche
 * Division mit Papier und Bleistift:
 *
 * Der Divisor wird mit dem Dividenden verglichen und soweit
 * nach rechts verschoben, bis er ohne Uebertrag vom Dividenden
 * subtrahiert werden kann. Fuer jedes Rechtsschieben wird im
 * Ergebnis eine Null notiert; kann er subtrahiert werden, wird
 * eine Eins notiert, denn entgegen der Division im Dezimalsystem,
 * bei der der Divisor bis zu neunmal im Dividenden enthalten sein
 * kann (Zahlenbasis minus Eins), ist dies im Binaersystem nur
 * einmal moeglich.
 * Dieses Verfahren wird fortgesetzt, bis die gewuenschte Anzahl
 * der Ergebnisbits berechnet ist (entgegen der Multiplikation
 * koennen die weiteren niederwertigen Bits keinen Uebertrag
 * erzeugen, so dass sie die Genauigkeit nicht beeinflussen):
 *
 * Fuer LONGREAL-Zahlen werden benoetigt:
 *
 *    52 Bit explizite Mantisse
 *  +  1 Bit implizite eins
 *  +  1 GUARD-Bit, fuer eine evtl. Normalisierung (Divisor > Dividend)
 *  +  1 ROUND-Bit, fuers Runden auf 1/2 LSB
 *  ----
 *  = 55 Bit
 *)

  ASSEMBLER
        MOVE.W  d2(A6),D5
        LSL     #3,D5
        LEA     lregs,A0
        MOVEM.L (A0,D5.W),D2-D3 ; D2/D3 := Dividend
        MOVEM.L d1(A6),D0-D1    ; D0/D1 := Divisor,

        SWAP    D0      ; Exponenten im unteren Wort fuer schnelleren
        SWAP    D2      ; Zugriff
        MOVE.W  D0,D6
        MOVE.W  D2,D7
        MOVE.W  #$7FF0,D4
        AND.W   D4,D6   ; D6 := Exponent des Divisors
        BEQ     RealErr ; B: Divisor Null = Division durch Null
        AND.W   D4,D7   ; D7 := Exponent des Dividenden
        BEQ     null    ; B: Dividend Null = Ergebnis Null
        SUB.W   D6,D7   ; Default-Exponent des Ergebnisses ist die
                        ; Differenz von Dividend- und Divisor-Exponent;
                        ; Das Ergebnis kann im Laufe der Berechnung um Eins
                        ; nach oben (falls Divisor > Dividend, und damit
                        ; eine Stelle verlorengeht), und/oder um Eins nach
                        ; unten korrigiert werden (falls bei der Rundung
                        ; ein Ueberlauf auftritt):
        ASR.W   #4,D7   ; Exponent als INTEGER, damit die Addition des
                        ; Bias keine negative Zahl geben kann
        ADDI.W  #1023,D7 ; durch die Differenz ist der Bias rausgefallen
        BVS     RealErr ; B: Exponent-Ueberlauf kann nicht weit genug
                        ; nach unten korrigiert werden
        BLT     ufl     ; B: Exponent-Unterlauf, kann nicht auf einen
                        ; gueltigen Exponenten korrigiert werden, ein
                        ; Exponent gleich Null kann aber evtl. noch auf
                        ; Eins korrigiert werden
        SWAP    D7      ; Vorzeichen des Ergebnisses im oberen Wort
        MOVE.W  D0,D7   ; von D7 merken
        EOR.W   D2,D7   ;
        SWAP    D7      ;
        MOVEQ   #$0F,D4 ; Exponent und Vorzeichen aus der Mantisse
        AND.W   D4,D2   ; loeschen
        AND.W   D4,D0   ;
        BNE     implEins ; B: Divisor keine Zweierpotenz
        SWAP    D0      ; restl. Mantisse auch testen
        TST.W   D0      ;
        BNE     implEins0 ; B: Divisor keine Zweierpotenz
        TST.L   D1      ; untere Mantisse des Divisors auch Null ?
        BNE     implEins ; B: nein, normale Division
        MOVE.L  D2,D5   ; Division durch eine Zweierpotenz ist lediglich
        MOVE.L  D3,D6   ; eine Subtraktion der Exponenten
        BRA               addexp

implEins0:
        SWAP    D0
implEins:
        MOVEQ   #$10,D4 ; implizite Eins setzen, damit beginnen beide
        OR.W    D4,D0   ; Mantissen mit einer Eins
        OR.W    D4,D2
        SWAP    D0      ; Mantissen wieder in richtige Position
        SWAP    D2      ;
        MOVEQ   #0,D5   ; alle Ergebnisbits loeschen
        MOVEQ   #0,D6   ;
        MOVEQ   #(52+1)+1+1-32-1,D4 ; erst mal die hoeherwertigen Bits
        BRA     tstgt

shifthi:
        ADD.L   D3,D3   ; Dividend eine Stelle nach links
        ADDX.L  D2,D2   ;
tstgt:
        CMP.L   D0,D2   ; obere Mant. Dividend >= obere Mant. Divisor ?
        DBCC    D4,shifthi ; B: nein, dann Dividend < Divisor
        BLO     lomant  ; B: alle Bits berechnet
        SUB.L   D1,D3   ; Dividend - Divisor
        SUBX.L  D0,D2   ;
        BLO     zurueckhi ; B: die untere Mant. des Divisors war groesser
                        ; also Subtraktion rueckgaengig machen
        BSET    D4,D5   ; Ergebnisbit setzen
        BRA     weiterhi ; und naechstes Bit berechnen
zurueckhi:
        ADD.L   D1,D3   ; irrtuemliche Subtraktion rueckgaengig machen
        ADDX.L  D0,D2   ;
weiterhi:
        DBRA    D4,shifthi ; B: noch nicht alle Bits berechnet

lomant:
        MOVEQ   #32-1,D4 ; die niederwertigen 32 Bits berechnen
shiftlo:                ; wie oben...
        ADD.L   D3,D3
        ADDX.L  D2,D2
        CMP.L   D0,D2
        DBCC    D4,shiftlo
        BLO     tstnorm
        SUB.L   D1,D3
        SUBX.L  D0,D2
        BLO     zuruecklo
        BSET    D4,D6
        BRA     weiterlo
zuruecklo:
        ADD.L   D1,D3
        ADDX.L  D0,D2
weiterlo:
        DBRA    D4,shiftlo

tstnorm:
        BTST    #22,D5  ; oberstes Bit der Mantisse gesetzt ?
        BNE     round   ; B: ja, Mantisse ist normalisiert
        ADD.L   D6,D6   ; sonst ist bei der Division eine Stelle verloren-
        ADDX.L  D5,D5   ; gegangen, GUARD-Bit wird jetzt unterstes Bit der
                        ; Mantisse, damit Mantisse wieder normalisiert
        SUBQ.W  #1,D7   ; das Links-Schieben der Mantisse muss durch
                        ; Verringern des Exponenten ausgeglichen werden

round:                  ; Runden der Mantisse auf naechstgelegene Zahl
                        ; durch Beruecksichtigung des Bits hinter dem
                        ; letzten Bit der Mantisse (= ROUND-Bit, falls
                        ; normalisiert werden musste, sonst = GUARD-Bit)
        MOVEQ   #0,D4   ; damit nur der evtl. Ueberlauf addiert wird
        ADDQ.L  #2,D6   ;
        ADDX.L  D4,D5   ;
        BTST    #23,D5  ; Ueberlauf beim Runden ?
        BEQ     mkreal  ; B: nein, ok
        LSR.L   #1,D5   ; sonst Mantisse eins nach rechts
        ROXR.L  #1,D6   ;
        ADDQ.W  #1,D7   ; und Exponent dafuer um Eins erhoehen
mkreal:
        LSR.L   #1,D5   ; Mantisse um 2 Bits in die richtige Position schieben
        ROXR.L  #1,D6   ; (GUARD- und ROUND-Bit, falls nicht normalisiert
        LSR.L   #1,D5   ; wurde,sonst ROUND-Bit und nachgeschobenes Null-Bit
        ROXR.L  #1,D6   ; entfernen)
        SWAP    D5      ; fuer Wort-Zugriff
        ANDI.W  #$000F,D5 ; implizite Eins loeschen
tstexp:
        TST.W   D7      ; Exponent-Unterlauf ?
        BLE     ufl     ; B: ja, Ergebnis ist Null
        CMPI.W  #$07FE,D7 ; Exponent-Ueberlauf ?
        BGT     RealErr ; B: ja, Meldung
addexp:
        LSL.W   #4,D7   ; Exponent in die richtige Position
        OR.W    D7,D5   ; und vor die Mantisse setzen
        SWAP    D5      ;
tstsign:
        TST.L   D7      ; Ergebnis-Vorzeichen setzen
        BPL     return  ;
        BSET    #31,D5  ;
return:
        MOVE.L  D5,D0
        MOVE.L  D6,D1
        BRA     ende

ufl:                    ; Unterlauf evtl. auch Meldung
null:                   ; nur bei Dividend = Null
        MOVEQ   #0,D5   ; bei Unterlauf oder Null-Dividend ist das Ergebnis
        MOVEQ   #0,D6   ; auch Null
        BRA     return

(* Nicht benutzt:
div0:
        DIVU    #0,D0   ; Bei Division durch Null auch eine entsprechende
                        ; Meldung
ofl:                    ; evtl. Meldung
maxreal:
        MOVE.L  #$7FEFFFFF,D5 ; bei Ueberlauf die groesste LONGREAL-Zahl
        MOVEQ   #$FF,D6 ; liefern (MAX(LONGREAL))
        BRA     tstsign
*)

ende:
        MOVE.W  d2(A6),D5
        LSL     #3,D5
        LEA     lregs,A0
        MOVEM.L D0-D1,(A0,D5.W)
  END
 END DivLReal;


PROCEDURE FDivSFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF sregvalid[src] THEN
    IF ~sregvalid[dest] THEN LRealToReal(dest) END;
    DivReal(sregs[src], dest);
  ELSIF sregvalid[dest] THEN
    LRealToReal(src);
    DivReal(sregs[src], dest);
  ELSE
    DivLReal(lregs[src], dest);
  END;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FDivSFF;


PROCEDURE FDivDFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  IF ~lregvalid[src] THEN RealToLReal(src) END;
  DivLReal(lregs[src], dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FDivDFF;


PROCEDURE FDivSXF*(src: Real; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~sregvalid[dest] THEN LRealToReal(dest) END;
  DivReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FDivSXF;


PROCEDURE FDivDXF*(src: LReal; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  DivLReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FDivDXF;


PROCEDURE AddReal(s1: Real; s2: FPnDef);
 BEGIN
  ASSEMBLER

  MOVE.W  s2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0
  MOVE.L  s1(A6),D1

fadd_s*:
  MOVE.L  D0,D4
  MOVE.L  D1,D6
  ROL.L   #1,D4
  ROL.L   #1,D6
  MOVE.L  D4,D0
  SUB.L   D6,D0
  BCC     fas_15
  EXG     D6,D4
fas_15:  MOVE.B  D4,D3
  AND.B   #1,D3
  BTST    #0,D0
  BEQ     fas_16
  BSET    #1,D3
fas_16:  ROL.L   #8,D4
  CLR.W   D5
  MOVE.B  D4,D5
  SNE     D4
  ROR.L   #1,D4
  CLR.B   D4
  ROL.L   #8,D6
  CLR.W   D7
  MOVE.B  D6,D7
  SNE     D6
  ROR.L   #1,D6
  CLR.B   D6
  MOVE.W  D5,D0
  SUB.W   D7,D0
  CMP.W   #$18,D0
  BHI     fas_1A
  LSR.L   D0,D6
  BTST    #1,D3
  BNE     fas_18
  ADD.L   D6,D4
  BCC     fas_17
  ROXR.L  #1,D4
  ADDQ.W  #1,D5
fas_17:  BRA     fas_1A
fas_18:  SUB.L   D6,D4
  BMI     fas_1A
  BEQ     fas_1A
  CMP.L   #$FFFF,D4
  BHI     fas_19
  SUB.W   #$10,D5
  SWAP    D4
  BMI     fas_1A
fas_19:  SUBQ.W  #1,D5
  LSL.L   #1,D4
  BPL     fas_19
fas_1A:  ADD.L   #$80,D4
  BCC     fas_1B
  ROXR.L  #1,D4
  ADDQ.W  #1,D5
fas_1B:  CLR.B   D4
  TST.L   D4
  BNE     fas_1C
  CLR.W   D5
fas_1C:  TST.W   D5
  BGT     fas_1D
  CLR.L   D4
  BRA     fas_1F
fas_1D:  CMP.W   #$FF,D5
  BGE     RealErr
fas_1E:  LSL.L   #1,D4
  MOVE.B  D5,D4
  ROR.L   #8,D4
  ROXR.B  #1,D3
  ROXR.L  #1,D4
fas_1F:  MOVE.L  D4,D0
fas_20:
  MOVE.W  s2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  D0,(A0,D5.W)

  END
 END AddReal;


PROCEDURE AddLReal(s1: LReal; s2 : FPnDef);
 BEGIN
  ASSEMBLER

  MOVE.W  s2(A6),D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVEM.L  (A0,D5.W),D0-D1
  MOVEM.L s1(A6),D2-D3

fadd_d*:
  MOVE.L  D0,D7
  MOVE.L  D2,D6
  CLR.W   D7
  SWAP    D7
  CLR.W   D6
  SWAP    D6
  MOVE.L  #$0FFFFF,D5
  AND.L   D5,D0
  AND.L   D5,D2
  MOVEQ   #$14,D5
  BSET    D5,D0
  BSET    D5,D2
  MOVEQ   #$0F,D5
  BCLR    D5,D7
  BEQ     fad_40
  NEG.L   D1
  NEGX.L  D0
fad_40:  BCLR    D5,D6
  BEQ     fad_41
  NEG.L   D3
  NEGX.L  D2
fad_41:  LSR.W   #4,D6
  BNE     fad_42
  MOVEQ   #0,D2
  MOVEQ   #0,D3
fad_42:  LSR.W   #4,D7
  BNE     fad_43
  MOVEQ   #0,D0
  MOVEQ   #0,D1
fad_43:  MOVE.W  D7,D4
  SUB.W   D6,D4
  BEQ     fad_4B
  BPL     fad_44
  NEG.W   D4
  EXG     D2,D0
  EXG     D3,D1
  EXG     D6,D7
fad_44:  MOVEQ   #0,D6
  CMPI.W  #$36,D4
  BLS     fad_46
  MOVE.L  D0,D4
  ANDI.L  #-$80000000,D4
  BPL     fad_45
  NEG.L   D6
  NEGX.L  D1
  NEGX.L  D0
fad_45:  BRA     fad_54
fad_46:  CMPI.W  #$20,D4
  BCS     fad_47
  SUBI.W  #$20,D4
  MOVE.L  D3,D6
  MOVE.L  D2,D3
  SMI     D2
  EXT.W   D2
  EXT.L   D2
fad_47:  CMPI.W  #$10,D4
  BCS     fad_48
  SUBI.W  #$10,D4
  MOVE.W  D3,D6
  MOVE.W  D2,D3
  SWAP    D6
  SWAP    D3
  SWAP    D2
  EXT.L   D2
fad_48:  CMPI.W  #8,D4
  BCS     fad_4A
  SUBQ.W  #8,D4
  MOVE.B  D3,D6
  MOVE.B  D2,D3
  ASR.L   #8,D2
  ROR.L   #8,D3
  ROR.L   #8,D6
  BRA     fad_4A
fad_49:  ASR.L   #1,D2
  ROXR.L  #1,D3
  ROXR.L  #1,D6
fad_4A:  DBRA    D4,fad_49
  BRA     fad_4C
fad_4B:  MOVEQ   #0,D6
fad_4C:  MOVEQ   #0,D4
  ADD.L   D3,D1
  ADDX.L  D2,D0
  BPL     fad_4D
  MOVE.L  #-$80000000,D4
  NEG.L   D6
  NEGX.L  D1
  NEGX.L  D0
fad_4D:  MOVE.L  D6,D2
  TST.L   D0
  BNE     fad_50
  MOVE.L  D1,D0
  BNE     fad_4E
  MOVE.L  D2,D0
  BEQ     fad_57
  SUBI.W  #$40,D7
  BRA     fad_4F
fad_4E:  SUBI.W  #$20,D7
  MOVE.L  D2,D1
fad_4F:  MOVEQ   #0,D2
fad_50:  CMPI.L  #$200000,D0
  BCS     fad_51
  LSR.L   #1,D0
  ROXR.L  #1,D1
  ROXR.L  #1,D2
  ADDQ.W  #1,D7
  BRA     fad_50
fad_51:  CMPI.L  #$100000,D0
  BCC     fad_52
  LSL.L   #1,D2
  ROXL.L  #1,D1
  ROXL.L  #1,D0
  SUBQ.W  #1,D7
  BRA     fad_51
fad_52:  TST.L   D2
  BPL     fad_54
  ADDQ.L  #1,D1
  BCC     fad_53
  ADDQ.L  #1,D0
  CMPI.L  #$200000,D0
  BCS     fad_54
  LSR.L   #1,D0
  ROXR.L  #1,D1
  ADDQ.W  #1,D7
  BRA     fad_54
fad_53:  CMPI.L  #-$80000000,D2
  BNE     fad_54
  ANDI.B  #-2,D1
fad_54:  BCLR    #20,D0
  BEQ     fad_57
  TST.W   D7
  BLS     fad_55
  CMPI.W  #$07FF,D7
  BCS     fad_56
  BRA     RealErr
fad_55:  MOVEQ   #0,D0
  MOVEQ   #0,D1
  BRA     fad_57
fad_56:  LSL.W   #4,D7
  SWAP    D7
  CLR.W   D7
  OR.L    D7,D0
  OR.L    D4,D0
fad_57:
  MOVE.W  s2(A6),D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVEM.L  D0-D1,(A0,D5.W)

  END
 END AddLReal;


PROCEDURE FAddSFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF sregvalid[src] THEN
    IF ~sregvalid[dest] THEN LRealToReal(dest) END;
    AddReal(sregs[src], dest);
  ELSIF sregvalid[dest] THEN
    LRealToReal(src);
    AddReal(sregs[src], dest);
  ELSE
    AddLReal(lregs[src], dest);
  END;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FAddSFF;


PROCEDURE FAddDFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  IF ~lregvalid[src] THEN RealToLReal(src) END;
  AddLReal(lregs[src], dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FAddDFF;


PROCEDURE FAddSXF*(src: Real; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~sregvalid[dest] THEN LRealToReal(dest) END;
  AddReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FAddSXF;


PROCEDURE FAddDXF*(src: LReal; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  AddLReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FAddDXF;


PROCEDURE SubReal(s1: Real; s2: FPnDef);
 BEGIN
  ASSEMBLER

  MOVE.W  s2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0
  MOVE.L  s1(A6),D1

  BCHG    #31,D1          ; Žndert Vorzeichen Minuend
  BRA     fadd_s          ; und addiert

  END
 END SubReal;


PROCEDURE SubLReal(s1: LReal; s2 : FPnDef);
 BEGIN
  ASSEMBLER

  MOVE.W  s2(A6),D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVEM.L  (A0,D5.W),D0-D1
  MOVEM.L s1(A6),D2-D3

  BCHG    #31,D2          ; Vorzeichen Minuend „ndern
  BRA     fadd_d

  END
 END SubLReal;


PROCEDURE FSubSFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF sregvalid[src] THEN
    IF ~sregvalid[dest] THEN LRealToReal(dest) END;
    SubReal(sregs[src], dest);
  ELSIF sregvalid[dest] THEN
    LRealToReal(src);
    SubReal(sregs[src], dest);
  ELSE
    SubLReal(lregs[src], dest);
  END;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FSubSFF;


PROCEDURE FSubDFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  IF ~lregvalid[src] THEN RealToLReal(src) END;
  SubLReal(lregs[src], dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FSubDFF;


PROCEDURE FSubSXF*(src: Real; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~sregvalid[dest] THEN LRealToReal(dest) END;
  SubReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FSubSXF;


PROCEDURE FSubDXF*(src: LReal; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  SubLReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FSubDXF;


PROCEDURE CmpReal(r1: Real; r2: FPnDef);
 BEGIN
  ASSEMBLER

  MOVE.W  r2(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D1
  MOVE.L  r1(A6),D0

  MOVE.L  D0,D2
  BPL     fcs_2F
  EORI.L  #$7FFFFFFF,D0
fcs_2F:  AND.L   #$7F800000,D2
  BNE     fcs_30
  CLR.L   D0
fcs_30:  MOVE.L  D1,D2
  BPL     fcs_31
  EORI.L  #$7FFFFFFF,D1
fcs_31:  AND.L   #$7F800000,D2
  BNE     fcs_32
  CLR.L   D1
fcs_32:  CMP.L   D0,D1

  END
 END CmpReal;


PROCEDURE CmpLReal(r1: LReal; r2: FPnDef); (* Bugfixed by H. Kleinschmidt *)
 BEGIN
  ASSEMBLER

  MOVE.W  r2(A6),D5
  LSL  #3,D5
  LEA  lregs,A0
; Register waren vertauscht
  MOVEM.L (A0,D5.W),D2-D3
  MOVEM.L r1(A6),D0-D1

  MOVE.L  D0,D4
  BPL  fcd_91
  EORI.L  #$7FFFFFFF,D0
  NOT.L  D1
fcd_91: ANDI.L  #$7FF00000,D4
  BNE  fcd_92
  CLR.L  D0
  CLR.L  D1
fcd_92: MOVE.L  D2,D4
  BPL  fcd_93
  EORI.L  #$7FFFFFFF,D2
  NOT.L  D3
fcd_93: ANDI.L  #$7FF00000,D4
  BNE  fcd_94
  CLR.L  D2
  CLR.L  D3
fcd_94: SUB.L  D0,D2
  BNE  fcd_95
  SUB.L  D1,D3

; Der Compiler baut hinter den Code fuer den Aufruf der Prozedur einen
; bedingten Sprung ein, der auf ein Ergebnis mit Zweierkomplement-
; Arithmetik abfragt (BLT, BLE, BGE, BGT), der zweite Teil der Mantisse
; hat aber kein Vorzeichen, so dass fuer diesen Teil auf einen
; Vergleich/Subtraktion vorzeichenloser Zahlen abgefragt werden muss
; (CARRY-Bit). Die folgenden Befehle uebernehmen also das
; Umwandeln des Ergebnisses einer UNSIGNED-Subtraktion (nur CARRY-Bit
; beachten) in ein Ergebnis fuer Zweierkomplement-Vergleich (das
; Ergebnis der Exclusiv-Oder-Verknuepfung von NEGATIVE und OVERFLOW
; muss gleich dem Ergebnis von CARRY sein).
;
; CARRY = 0  =>  NEGATIVE := 0, OVERFLOW := 0  <=> NEGATIVE xor OVERFLOW = 0
; CARRY = 1  =>  NEGATIVE := 1, OVERFLOW := 0  <=> NEGATIVE xor OVERFLOW = 1
;

; N- und V-Bit loeschen, C- und Z-Bit nicht beeinflussen !
  ANDI  #$FF-$08-$02,CCR
  BCC  fcd_95    ; B: second >= first
  MOVEQ  #-1,D3    ;    second <  first, NEGATIVE-Bit setzen,
        ;    Zahlen koennen nicht gleich sein, also ist
        ;    ZERO-Bit egal
fcd_95:

  END
 END CmpLReal;


PROCEDURE FCmpSFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF sregvalid[src] THEN
    IF ~sregvalid[dest] THEN LRealToReal(dest) END;
    CmpReal(sregs[src], dest);
  ELSIF sregvalid[dest] THEN
    LRealToReal(src);
    CmpReal(sregs[src], dest);
  ELSE
    CmpLReal(lregs[src], dest);
  END;
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FCmpSFF;


PROCEDURE FCmpDFF*(src, dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  IF ~lregvalid[src] THEN RealToLReal(src) END;
  CmpLReal(lregs[src], dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FCmpDFF;


PROCEDURE FCmpSXF*(src: Real; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~sregvalid[dest] THEN LRealToReal(dest) END;
  CmpReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FCmpSXF;


PROCEDURE FCmpDXF*(src: LReal; dest: FPnDef);
 BEGIN
  ASSEMBLER
    MOVEM.L  D0-A5,-(SP)
  END;
  IF ~lregvalid[dest] THEN RealToLReal(dest) END;
  CmpLReal(src, dest);
  ASSEMBLER
    MOVEM.L  (SP)+,D0-A5
  END;
 END FCmpDXF;


PROCEDURE FAbsSF*(dest: FPnDef);
 BEGIN
  ASSEMBLER

  MOVEM.L  D0-A5,-(SP)

  MOVE.W  dest(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0
  BCLR    #31,D0          ; Vorzeichen positiv
  MOVE.L  D0,(A0,D5.W)

  MOVEM.L  (SP)+,D0-A5

  END
 END FAbsSF;


PROCEDURE FAbsDF*(dest: FPnDef);
 BEGIN
  ASSEMBLER

  MOVEM.L  D0-A5,-(SP)

  MOVE.W  dest(A6),D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVE.L  (A0,D5.W),D0
  BCLR    #31,D0
  MOVE.L  D0,(A0,D5.W)

  MOVEM.L  (SP)+,D0-A5

  END
 END FAbsDF;


PROCEDURE FAbsSFF*(src, dest: FPnDef);
 BEGIN
  FMoveSFF(src, dest);
  FAbsSF(dest);
 END FAbsSFF;


PROCEDURE FAbsDFF*(src, dest: FPnDef);
 BEGIN
  FMoveDFF(src, dest);
  FAbsDF(dest);
 END FAbsDFF;


PROCEDURE FAbsSXF*(src: Real; dest: FPnDef);
 BEGIN
  FMoveSXF(src, dest);
  FAbsSF(dest);
 END FAbsSXF;


PROCEDURE FAbsDXF*(src: LReal; dest: FPnDef);
 BEGIN
  FMoveDXF(src, dest);
  FAbsDF(dest);
 END FAbsDXF;


PROCEDURE FNegSF*(dest: FPnDef);
 BEGIN
  ASSEMBLER

  MOVEM.L  D0-A5,-(SP)

  MOVE.W  dest(A6),D5
  LSL  #2,D5
  LEA  sregs,A0
  MOVE.L  (A0,D5.W),D0
  BCHG    #31,D0          ; Vorzeichen „ndern
  MOVE.L  D0,(A0,D5.W)

  MOVEM.L  (SP)+,D0-A5

  END
 END FNegSF;


PROCEDURE FNegDF*(dest: FPnDef);
 BEGIN
  ASSEMBLER

  MOVEM.L  D0-A5,-(SP)

  MOVE.W  dest(A6),D5
  LSL  #3,D5
  LEA  lregs,A0
  MOVE.L  (A0,D5.W),D0
  BCHG    #31,D0
  MOVE.L  D0,(A0,D5.W)

  MOVEM.L  (SP)+,D0-A5

  END
 END FNegDF;


PROCEDURE FNegSFF*(src, dest: FPnDef);
 BEGIN
  FMoveSFF(src, dest);
  FNegSF(dest);
 END FNegSFF;


PROCEDURE FNegDFF*(src, dest: FPnDef);
 BEGIN
  FMoveDFF(src, dest);
  FNegDF(dest);
 END FNegDFF;


PROCEDURE FNegSXF*(src: Real; dest: FPnDef);
 BEGIN
  FMoveSXF(src, dest);
  FNegSF(dest);
 END FNegSXF;


PROCEDURE FNegDXF*(src: LReal; dest: FPnDef);
 BEGIN
  FMoveDXF(src, dest);
  FNegDF(dest);
 END FNegDXF;


END EmuFPU.
