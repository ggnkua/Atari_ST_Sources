IMPLEMENTATION MODULE BinOps;
(*$Y+,R-,N+,L-*)

(*
  HigherCard, HigherLCard & HigherAddr liefern nun korrekte Ergebnisse
*)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS;

PROCEDURE LowerCard (a,b: CARDINAL): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.W  -(A3),D1
        CMP.W   D1,D0
        BLS.S   L
        MOVE    D1,D0
      L MOVE    D0,(A3)+
    END
  END LowerCard;

PROCEDURE LowerInt (a,b: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.W  -(A3),D1
        CMP.W   D1,D0
        BLE.S   L
        MOVE    D1,D0
      L MOVE    D0,(A3)+
    END
  END LowerInt;

PROCEDURE LowerLCard (a,b: LONGCARD): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        CMP.L   D1,D0
        BLS.S   L
        MOVE.L  D1,D0
      L MOVE.L  D0,(A3)+
    END
  END LowerLCard;

PROCEDURE LowerLInt (a,b: LONGINT): LONGINT;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        CMP.L   D1,D0
        BLE.S   L
        MOVE.L  D1,D0
      L MOVE.L  D0,(A3)+
    END
  END LowerLInt;

PROCEDURE LowerAddr (a,b: ADDRESS): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        CMP.L   D1,D0
        BLS.S   L
        MOVE.L  D1,D0
      L MOVE.L  D0,(A3)+
    END
  END LowerAddr;

PROCEDURE HigherCard (a,b: CARDINAL): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.W  -(A3),D1
        CMP.W   D1,D0
        BCC.S   H
        MOVE    D1,D0
      H MOVE    D0,(A3)+
    END
  END HigherCard;

PROCEDURE HigherInt (a,b: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.W  -(A3),D1
        CMP.W   D1,D0
        BGE.S   H
        MOVE    D1,D0
      H MOVE    D0,(A3)+
    END
  END HigherInt;

PROCEDURE HigherLCard (a,b: LONGCARD): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        CMP.L   D1,D0
        BCC.S   H
        MOVE.L  D1,D0
      H MOVE.L  D0,(A3)+
    END
  END HigherLCard;

PROCEDURE HigherLInt (a,b: LONGINT): LONGINT;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        CMP.L   D1,D0
        BGE.S   H
        MOVE.L  D1,D0
      H MOVE.L  D0,(A3)+
    END
  END HigherLInt;

PROCEDURE HigherAddr (a,b: ADDRESS): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        CMP.L   D1,D0
        BCC.S   H
        MOVE.L  D1,D0
      H MOVE.L  D0,(A3)+
    END
  END HigherAddr;

PROCEDURE SwitchCard (condition: BOOLEAN; true, false: CARDINAL): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0        ; false
        MOVE.W  -(A3),D1        ; true
        TST.W   -(A3)
        BEQ.S   F
        MOVE.W  D1,D0
      F MOVE.W  D0,(A3)+
    END
  END SwitchCard;

PROCEDURE SwitchInt (condition: BOOLEAN; true, false: INTEGER): INTEGER;
  BEGIN
    ASSEMBLER
        JMP     SwitchCard
    END
  END SwitchInt;

PROCEDURE SwitchLCard (condition: BOOLEAN; true, false: LONGCARD): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0        ; false
        MOVE.L  -(A3),D1        ; true
        TST.W   -(A3)
        BEQ.S   F
        MOVE.L  D1,D0
      F MOVE.L  D0,(A3)+
    END
  END SwitchLCard;

PROCEDURE SwitchLInt (condition: BOOLEAN; true, false: LONGINT): LONGINT;
  BEGIN
    ASSEMBLER
        JMP     SwitchLCard
    END
  END SwitchLInt;

PROCEDURE SwitchAddr (condition: BOOLEAN; true, false: ADDRESS): ADDRESS;
  BEGIN
    ASSEMBLER
        JMP     SwitchLCard
    END
  END SwitchAddr;

END BinOps.

(* $FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A$FFF6C35A€$00000025T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000BB0$00000DCC$00000E6A$00000DC6$00000E63$00000DAA$00000E48$000000AF$0000060C$000007F5$000009DE$00000083$00000039$000000A3$FFEE761E$00000025€€€*)
