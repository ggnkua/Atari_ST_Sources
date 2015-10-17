DEFINITION MODULE MM2Comp2;

FROM SYSTEM IMPORT CompilerVersion;

CONST

    (* Konfigurations-Konstanten *)
    (* ------------------------- *)

      OldByteOrder = FALSE;   (* TRUE: Vars k”nnen auf ungeraden Adr. liegen *)
      BITSETfromSYSTEM = FALSE;

    (* ------------------------- *)


CONST
  D0 = 0;   D1 = 1;   D2 = 2;   D3 = 3;   D7 = 7;
  A0 = 8;   A1 = 9;   A2 = 10;  A3 = 11;  A4 = 12;  A5 = 13;  A6 = 14;  A7 = 15;
  F0 = 16;  F2 = 18;  F3 = 19;  F7 = 23;

TYPE

  RegType  = [D0..F7];
  RegSet   = SET OF RegType;

  VarType  = (dataVar, ptrVar, floatVar);

CONST
  dataRegs  = RegSet{D0..D2};
  addrRegs  = RegSet{A0..A2};
  floatRegs = RegSet{F0..F2};
  tempRegs  = RegSet{D0..D2,A0..A2,F0..F2};
  varRegs   = RegSet{D3..D7,A3..A7,F3..F7};
  anyDataReg = RegSet{D0..D7};
  anyAddrReg = RegSet{A0..A7};
  anyReg     = RegSet{D0..A7};

VAR freeRegs: RegSet;           (* z.Zt. belegte Regs *)
    filler1: CHAR;
VAR freeVarRegs:  RegSet;       (* proc-weit belegte Regs f. Reg-Vars *)
    filler2: CHAR;

PROCEDURE exclFromFreeRegs;
PROCEDURE inclInFreeRegs;

VAR
  InConstExpr: BOOLEAN;  (* TRUE -> no code is allowed (Constant expr.) *)
  SuppressCode: BOOLEAN; (* TRUE -> don't generate code (SIZE, IF TRUE OR...) *)
  RelocCount: LONGCARD;  (* wird bei jeder zu reloz. Adr. erh”ht *)

PROCEDURE expr;         (* Erg. auf A3-Stack *)

PROCEDURE constExpr;
  (* liefert nie ZZ, sondern reduzierten Wert *)

PROCEDURE constExprZZ;
  (* liefert auch ZZ *)

PROCEDURE boolExpr;
  (*
   * Legt alle Forward-Refs fr FALSE auf den Integer-Stack.
   * Deren Anzahl wird in D0.W geliefert.
   * Wenn Anzahl Null, dann ist BOOLEAN-Expr = TRUE und alle
   * weiteren ELSE-Zweige sind FALSE.
   * Wenn stattdessen SuppressCode = TRUE, dann ist Expr = FALSE
   * und Code-Erz. muž zum n„chsten ELSE/END wieder aktiviert werden.
   *)

PROCEDURE caseExpr; (* Erg. nach D0, Fehler, wenn nicht scalar *)

PROCEDURE pushExpr;
  (*
   * wertet Expr aus, legt sie auf den A3-Stack (D0 = 0) oder nach D0
   * (D0 = 1).
   * Dabei wird auf dem Integer-Stack der Ziel-Typ bergeben, auf den
   * geprft und ggf. angepažt wird.
   *)

PROCEDURE pushAdr;
  (*
   * wertet einen designator aus und legt seine Adr. auf den A3-Stack.
   * Sein Typ wird auf dem Integer-Stack zurckgegeben
   *)

PROCEDURE assign;

PROCEDURE adjustSubrange;
 (* von SetType (SYMBOL.ICL) aufgerufen *)

PROCEDURE aExcl;
PROCEDURE aIncl;

PROCEDURE aInc;
PROCEDURE aDec;

PROCEDURE aCallSys;
PROCEDURE aCallExt;

PROCEDURE aLoad;
PROCEDURE aStore;

PROCEDURE aFor;

PROCEDURE aWith;

PROCEDURE initBlock;
  (* Beginn des Blocks - hier werden die freien Regs initialisiert *)

PROCEDURE aBegin;
PROCEDURE aEnd;
  (* zeigen BEGIN und END eines Blocks an. Keine Schachtelung m”glich. *)

PROCEDURE saveVarRegs;
PROCEDURE restoreVarRegs;
  (* In D0 wird Reg-List bergeben *)

PROCEDURE getRegVar;
  (* In: D0.W: gewnschten Typ (Data/Addr/Float)
   * Out: D0.W: neg. -> kein Reg frei, sonst Reg-Nr und Flags *)

PROCEDURE discardA7;
  (* In: D0.L: A7Offset, auf den abgebaut werden soll *)

END MM2Comp2.
