IMPLEMENTATION MODULE RealCtrl;
(*$N+,Y+,L-*)

(* fÅr spÑter...
PROCEDURE Long (sr: REAL; format: RealFormat): AnyReal;
PROCEDURE Short (longReal: AnyReal): REAL;
  (*
   * Konvertieren von REAL nach LONGREAL bzw. umgekehrt im angegebenen
   * Format (das Format wird beibehalten).
   *)
*)

FROM SYSTEM IMPORT ASSEMBLER;
IMPORT MOSCtrl;

PROCEDURE SmallREAL     (format: RealFormat): LONGREAL;
  BEGIN
    ASSEMBLER
        TST     -(A3)
        BNE     ieee
        MOVE.L  #$FE028000,(A3)+
        MOVE.L  #$00000000,(A3)+
        RTS
      ieee
        MOVE.L  #$36A00000,(A3)+
        MOVE.L  #$00000000,(A3)+
    END
  END SmallREAL;

PROCEDURE LargeREAL     (format: RealFormat): LONGREAL;
  BEGIN
    ASSEMBLER
        TST     -(A3)
        BNE     ieee
        MOVE.L  #$01FAFFFF,(A3)+
        MOVE.L  #$FF000000,(A3)+
        RTS
      ieee
        MOVE.L  #$47EFFFFF,(A3)+
        MOVE.L  #$E0000000,(A3)+
    END
  END LargeREAL;

PROCEDURE SmallLONGREAL (format: RealFormat): LONGREAL;
  BEGIN
    ASSEMBLER
        TST     -(A3)
        BNE     ieee
        MOVE.L  #$80628000,(A3)+
        MOVE.L  #$00000000,(A3)+
        RTS
      ieee
        MOVE.L  #$00000000,(A3)+
        MOVE.L  #$00000001,(A3)+
    END
  END SmallLONGREAL;

PROCEDURE LargeLONGREAL (format: RealFormat): LONGREAL;
  BEGIN
    ASSEMBLER
        TST     -(A3)
        BNE     ieee
        MOVE.L  #$7FC2FFFF,(A3)+
        MOVE.L  #$FFFFFFFF,(A3)+
        RTS
      ieee
        MOVE.L  #$7FEFFFFF,(A3)+
        MOVE.L  #$FFFFFFFF,(A3)+
    END
  END LargeLONGREAL;

PROCEDURE Conv (in: AnyReal; out: RealFormat): LONGREAL;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0        ; out-Format
        CMP.W   -(A3),D0        ; in-Format
        BEQ     ende            ; beide Formate sind schon gleich
        
        LEA     -8(A3),A0
        TST     D0
        BNE     toIEEE
        
        ; *** IEEE (A0) to MM2 (A0) ***
        ; Mantisse laden
        MOVE.L  (A0),D1
        MOVE.L  4(A0),D2
        ; Mantisse und Exp um 4 Bit runterschieben
        LSR.L   #1,D1
        ROXR.L  #1,D2
        LSR.L   #1,D1
        ROXR.L  #1,D2
        LSR.L   #1,D1
        ROXR.L  #1,D2
        LSR.L   #1,D1
        ROXR.L  #1,D2
        ; D1.W:D2.L enthalten die Mantisse
        
        MOVE.L  D1,D0
        SWAP    D0
        ANDI    #$07FF,D0
        ; D0 enthÑlt Exponenten + Bias 1023
        BEQ     denorm
        
        SUBI    #1023,D0        ; Bias vom Exp abziehen
        ; Bit 47 v. MM2-Real setzen und dafÅr Exp um Eins erhîhen
        LSR.W   #1,D1
        ROXR.L  #1,D2
        BSET    #15,D1
        ADDQ    #1,D0
      final
        LSL.W   #3,D0
        TST.W   (A0)            ; negativ?
        BPL     pos
        BSET    #0,D0
      pos
        BSET    #1,D0           ;non-zero Bit setzen
        SWAP    D0
        MOVE    D1,D0
        MOVE.L  D0,(A0)
        MOVE.L  D2,4(A0)
      ende
        RTS
        
      denorm
        ; prÅfen, ob Wert Null ist
        TST.W   D1
        BNE     notNull2
        TST.L   D2
        BNE     notNull
        
        ; Zahl ist Null
        CLR.L   (A0)
        CLR.L   4(A0)
        RTS
        
      notNull2
        BPL     notNull
        ; wenn D1 negativ, dann ist Zahl fÅr MM2-Format bereits normalisiert
        SUBI    #1023,D0        ; Bias vom Exp abziehen
        BRA     final
        
      notNull
        ; Zahl ist denormalisiert
      norm
        SUBQ    #1,D0
        LSL.L   #1,D2
        ROXL.W  #1,D1
        BCC     norm
        SUBI    #1023,D0        ; Bias vom Exp abziehen
        BRA     final
        
      toIEEE
        ; *** MM2 (A0) to IEEE (A0) ***
        ; liefert Infinity, wenn MM2-Wert zu groû ist
        MOVE.W  (A0),D0         ; Exp laden
        BEQ     isNull
        ASR     #3,D0
        MOVEQ   #0,D1
        MOVE.W  2(A0),D1
        MOVE.L  4(A0),D2
        
        ; Bias addieren
        ; (incl. dem angepaûten Exp-Offset fÅr's entfernte 0.5-Bit)
        ADDI    #1023-1,D0
        
        CMPI    #2048,D0
        BGE     overflow        ; wenn Exp grîûer als 1024 war, dann Overflow
        BCS     norm2           ; wenn Exp zw. -1023 und 1024 lag, dann ok
        CMPI    #-51,D0         ; kînnen wir Zahl denormalisieren?
        BLT     isNull          ; wenn Exp zu klein, dann Null liefern
        
        ; denormalisieren
      denorm2
        ADDQ    #1,D0
        BEQ     final2
        LSR.W   #1,D1
        ROXR.L  #1,D2
        BRA     denorm2
        
      norm2
        ; 0.5-Wert Bit rausschieben (Exp bereits angepaût)
        LSL.L   #1,D2
        ROXL.W  #1,D1
        
      final2
        SWAP    D0
        MOVE.W  D1,D0
        ; Mantisse und Exp um 4 Bit aufschieben
        LSL.L   #1,D2
        ROXL.L  #1,D0
        LSL.L   #1,D2
        ROXL.L  #1,D0
        LSL.L   #1,D2
        ROXL.L  #1,D0
        LSL.L   #1,D2
        ROXL.L  #1,D0
        ; Sign setzen
        BTST    #0,1(A0)
        BEQ     pos2
        BSET    #31,D0
      pos2
        MOVE.L  D0,(A0)
        MOVE.L  D2,4(A0)
        RTS
        
      overflow
        ; Infinity liefern
        MOVEQ   #0,D1
        MOVEQ   #0,D2
        MOVE    #2047,D0
        BRA     final2
        
      isNull
        CLR.L   (A0)
        CLR.L   4(A0)
    END
  END Conv;

BEGIN
  ASSEMBLER
        MOVEQ   #2,D1
        MOVE.W  MOSCtrl.RealMode,D0
        BEQ     ok
        LSR     #1,D0
        MOVE    D0,D1
    ok: MOVE.W  D1,UsedFormat
  END;
END RealCtrl.
