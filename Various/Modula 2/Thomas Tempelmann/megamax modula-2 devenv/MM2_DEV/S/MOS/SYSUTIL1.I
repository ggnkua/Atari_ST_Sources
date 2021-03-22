
IMPLEMENTATION MODULE SysUtil1;  (* V#0008 *)

(*
  25.10.88  cgr  Peeks und Pokes
  03.12.88  TT   Bit-Funktionen, Kosmetik
  13.06.90  TT   SysCtrl.EnterSupervisorMode-Aufrufe raus
  20.07.90  TT   ByteToBitset & BitsetToByte auf neue Sets angepaût
*)

(*$L-  global ! *)
(*$M-,N+*)
(*$Y+*)
FROM SYSTEM IMPORT ASSEMBLER;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

FROM SysUtil2 IMPORT EnterSupervisorMode, LeaveSupervisorMode;

(****************************************************************)
(*                          Super Pokes                         *)
(****************************************************************)

PROCEDURE SuperPoke (addr:ADDRESS; REF data:ARRAY OF BYTE);
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.W    -(A3),D0      ;  Anzahl der Bytes
      MOVE.L    -(A3),A1      ;  Adresse der Daten
      MOVE.L    -(A3),A0      ;  Adresse fÅr Poke
Schleife:
      MOVE.B    (A1)+,(A0)+        ; Daten kopieren
      DBF       D0,Schleife
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperPoke;

PROCEDURE FastSuperPoke(addr:ADDRESS; VAR data:ARRAY OF BYTE);
  BEGIN
    ASSEMBLER
        JMP     SuperPoke
    END;
  END FastSuperPoke;

(****************************************************************)

PROCEDURE SuperBPoke (addr:ADDRESS;Data:WORD);
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.W      -(A3),D0      ; Daten
      MOVE.L      -(A3),A0      ; Adresse fÅr Poke
      MOVE.B      D0,(A0)       ; Daten kopieren
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperBPoke;

(****************************************************************)

PROCEDURE SuperWPoke (addr:ADDRESS; Data:WORD);
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.W      -(A3),D0      ; Daten
      MOVE.L      -(A3),A0      ; Adresse fÅr Poke
      MOVE.W      D0,(A0)       ; Daten kopieren
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperWPoke;

(****************************************************************)

PROCEDURE SuperLPoke (addr:ADDRESS; Data:LONGWORD);
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.L      -(A3),D0      ; Daten
      MOVE.L      -(A3),A0      ; Adresse fÅr Poke
      MOVE.L      D0,(A0)       ; Daten kopieren
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperLPoke;

(****************************************************************)
(*                          Super Peeks                         *)
(****************************************************************)

PROCEDURE SuperPeek (addr:ADDRESS; VAR data:ARRAY OF BYTE);

  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.W      -(A3),D0      ;  Anzahl der Bytes
      MOVE.L      -(A3),A1      ;  Adresse der Daten
      MOVE.L      -(A3),A0      ;  Adresse fÅr Peek
Schleife:
      MOVE.B (A0)+,(A1)+        ; Daten kopieren
      DBF D0,Schleife
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperPeek;

(****************************************************************)

PROCEDURE SuperBPeek (addr:ADDRESS):CARDINAL;
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.L      -(A3),A0      ; Adresse fÅr Peek
      CLR.W       D0            ; D0 Lîschen
      MOVE.B      (A0),D0       ; Daten kopieren
      MOVE.W      D0,(A3)+      ; Datum zurÅckgeben
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperBPeek;

(****************************************************************)

PROCEDURE SuperWPeek (addr:ADDRESS):CARDINAL;
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.L      -(A3),A0      ; Adresse fÅr Peek
      MOVE.W      (A0),D0       ; Daten kopieren
      MOVE.W      D0,(A3)+      ; Datum zurÅckgeben
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperWPeek;

(****************************************************************)

PROCEDURE SuperLPeek (addr:ADDRESS):LONGCARD;
  BEGIN
    ASSEMBLER
      SUBQ.L    #4,A7
      MOVE.L    A7,(A3)+
      JSR       EnterSupervisorMode   ; Super Weise
      MOVE.L      -(A3),A0      ; Adresse fÅr Peek
      MOVE.L      (A0),D0       ; Daten kopieren
      MOVE.L      D0,(A3)+      ; Datum zurÅckgeben
      MOVE.L    A7,(A3)+
      JSR       LeaveSupervisorMode ; Ende der Weisheit ?
      ADDQ.L    #4,A7
    END;
  END SuperLPeek;
  
  
(****************************************************************)
(*                        Normale Pokes                         *)
(****************************************************************)

PROCEDURE FastPoke (addr:ADDRESS; VAR data:ARRAY OF BYTE);
  BEGIN
    ASSEMBLER
      MOVE.W      -(A3),D0      ;  Anzahl der Bytes
      MOVE.L      -(A3),A1      ;  Adresse der Daten
      MOVE.L      -(A3),A0      ;  Adresse fÅr Poke
Schleife:
      MOVE.B (A1)+,(A0)+        ; Daten kopieren
      DBF D0,Schleife
    END;
  END FastPoke;

PROCEDURE Poke (addr:ADDRESS; REF data:ARRAY OF BYTE);
  BEGIN
    ASSEMBLER
        JMP     FastPoke
    END;
  END Poke;

(****************************************************************)
  
PROCEDURE BPoke (addr:ADDRESS; Data:WORD);
  BEGIN
    ASSEMBLER
      MOVE.W      -(A3),D0      ; Daten
      MOVE.L      -(A3),A0      ; Adresse fÅr Poke
      MOVE.B      D0,(A0)       ; Daten kopieren
    END;
  END BPoke;

(****************************************************************)

PROCEDURE WPoke (addr:ADDRESS; Data:WORD);
  BEGIN
    ASSEMBLER
      MOVE.W      -(A3),D0      ; Daten
      MOVE.L      -(A3),A0      ; Adresse fÅr Poke
      MOVE.W      D0,(A0)       ; Daten kopieren
    END;
  END WPoke;

(****************************************************************)

PROCEDURE LPoke (addr:ADDRESS; Data:LONGWORD);
  BEGIN
    ASSEMBLER
      MOVE.L      -(A3),D0      ; Daten
      MOVE.L      -(A3),A0      ; Adresse fÅr Poke
      MOVE.L      D0,(A0)       ; Daten kopieren
    END;
  END LPoke;

(****************************************************************)
(*                        Normale Peeks                         *)
(****************************************************************)

PROCEDURE Peek (addr:ADDRESS;VAR data:ARRAY OF BYTE);
  BEGIN
    ASSEMBLER
      MOVE.W      -(A3),D0      ;  Anzahl der Bytes
      MOVE.L      -(A3),A1      ;  Adresse der Daten
      MOVE.L      -(A3),A0      ;  Adresse fÅr Peek
Schleife:
      MOVE.B (A0)+,(A1)+        ; Daten kopieren
      DBF D0,Schleife
    END;
  END Peek;

(****************************************************************)

PROCEDURE BPeek (addr:ADDRESS):CARDINAL;
  BEGIN
    ASSEMBLER
      MOVE.L      -(A3),A0      ; Adresse fÅr Peek
      CLR.W       D0            ; D0 Lîschen
      MOVE.B      (A0),D0       ; Daten kopieren
      MOVE.W      D0,(A3)+      ; Datum zurÅckgeben
    END;
  END BPeek;

(****************************************************************)

PROCEDURE WPeek (addr:ADDRESS):CARDINAL;
  BEGIN
    ASSEMBLER
      MOVE.L      -(A3),A0      ; Adresse fÅr Peek
      MOVE.W      (A0),D0       ; Daten kopieren
      MOVE.W      D0,(A3)+      ; Datum zurÅckgeben
    END;
  END WPeek;

(****************************************************************)

PROCEDURE LPeek (addr:ADDRESS):LONGCARD;
  BEGIN
    ASSEMBLER
      MOVE.L      -(A3),A0      ; Adresse fÅr Peek
      MOVE.L      (A0),D0       ; Daten kopieren
      MOVE.L      D0,(A3)+      ; Datum zurÅckgeben
    END;
  END LPeek;


(****************************************************************)
(*                      Bit - Funktionen                        *)
(****************************************************************)


PROCEDURE Bit ( addr: ADDRESS; no: BitRange ): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.B  (A0),D1
        BTST    D0,D1
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END Bit;

PROCEDURE BitSet ( addr: ADDRESS; no: BitRange );
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        BSET    D0,(A0)
    END
  END BitSet;

PROCEDURE BitClr ( addr: ADDRESS; no: BitRange );
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        BCLR    D0,(A0)
    END
  END BitClr;

PROCEDURE BitChg ( addr: ADDRESS; no: BitRange );
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        BCHG    D0,(A0)
    END
  END BitChg;


PROCEDURE SuperBit ( addr: ADDRESS; no: BitRange ): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     EnterSupervisorMode   ; Super Weise
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.B  (A0),D1
        BTST    D0,D1
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
        MOVE.L  A7,(A3)+
        JSR     LeaveSupervisorMode ; Ende der Weisheit ?
        ADDQ.L  #4,A7
    END
  END SuperBit;

PROCEDURE SuperBitSet ( addr: ADDRESS; no: BitRange );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     EnterSupervisorMode   ; Super Weise
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        BSET    D0,(A0)
        MOVE.L  A7,(A3)+
        JSR     LeaveSupervisorMode ; Ende der Weisheit ?
        ADDQ.L  #4,A7
    END
  END SuperBitSet;

PROCEDURE SuperBitClr ( addr: ADDRESS; no: BitRange );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     EnterSupervisorMode   ; Super Weise
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        BCLR    D0,(A0)
        MOVE.L  A7,(A3)+
        JSR     LeaveSupervisorMode ; Ende der Weisheit ?
        ADDQ.L  #4,A7
    END
  END SuperBitClr;

PROCEDURE SuperBitChg ( addr: ADDRESS; no: BitRange );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     EnterSupervisorMode   ; Super Weise
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A0
        BCHG    D0,(A0)
        MOVE.L  A7,(A3)+
        JSR     LeaveSupervisorMode ; Ende der Weisheit ?
        ADDQ.L  #4,A7
    END
  END SuperBitChg;


PROCEDURE ByteToBitset ( b: BYTE ): BITSET;
  BEGIN
    ASSEMBLER
        MOVEQ   #0,D0
        MOVE.B  -2(A3),D0
        MOVE.W  D0,-2(A3)
    END
  END ByteToBitset;

PROCEDURE BitsetToByte ( bs: BITSET ): BYTE;
  BEGIN
    ASSEMBLER
        MOVE.B  -1(A3),-2(A3)
    END
  END BitsetToByte;

END SysUtil1.
 
(* $FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$0000051E$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82$FFF1DF82Ä$00000102T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000000C1$00000102$00002CC7$FFE8D0B8$00000102$00002D4B$00000102$FFE8D0B8$00002CB6$00002C90$00002CB6$00002D48$00002C55$00002D48$00002D26$00002D30úÄÅ*)
