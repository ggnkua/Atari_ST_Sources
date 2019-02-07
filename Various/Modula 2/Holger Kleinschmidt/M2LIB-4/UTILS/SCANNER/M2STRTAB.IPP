IMPLEMENTATION MODULE M2StrTable;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
(*$E+*)
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 28-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG;

FROM M2Syms IMPORT
(* TYPE *) Symbols;

FROM ADTBase IMPORT
(* TYPE *) CompareProc, ADTExceptions,
(* PROC *) RaiseADTException;

IMPORT RBTrees;

FROM types IMPORT
(* CONST*) EOS,
(* TYPE *) StrPtr, StrRange;

FROM blk IMPORT
(* PROC *) memmove;

FROM str IMPORT
(* PROC *) AssignCToM2, strcmp;

FROM mem IMPORT
(* PROC *) malloc, realloc;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  Blocks       = 500;
  MinTableSize = 4000;

TYPE
  StringRepresentation = RECORD
    idx : UNSIGNEDLONG;
    len : StrRange;
  END;

#ifdef TDIM2
  StrRepr = POINTER TO ADDRESS;
#else
  StrRepr = RBTrees.RBEntry;
#endif

VAR
  ReprTable    : RBTrees.RBTree;
  StrTable     : ADDRESS;
  StrTableNext : UNSIGNEDLONG;
  StrTableIdx  : UNSIGNEDLONG;
  StrTableSize : UNSIGNEDLONG;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE cmp ((* EIN/ -- *) e1 : ADDRESS;
               (* EIN/ -- *) e2 : ADDRESS ): INTEGER;

VAR r1 : POINTER TO StringRepresentation;
    r2 : POINTER TO StringRepresentation;

BEGIN
 r1 := e1;
 r2 := e2;
 RETURN(strcmp(ADDADR(StrTable, r1^.idx), ADDADR(StrTable, r2^.idx)));
END cmp;

(*---------------------------------------------------------------------------*)

PROCEDURE HasSymbol ((* EIN/ -- *) repr : StrRepr ): BOOLEAN;

VAR sym : Symbols;

BEGIN
 RBTrees.GetInfo(ReprTable, repr, sym);
 RETURN(sym <> ErrorSym);
END HasSymbol;

(*---------------------------------------------------------------------------*)

PROCEDURE SetSymbol ((* EIN/ -- *) repr : StrRepr;
                     (* EIN/ -- *) sym  : Symbols );

BEGIN
 RBTrees.SetInfo(ReprTable, sym, repr);
END SetSymbol;

(*---------------------------------------------------------------------------*)

PROCEDURE GetSymbol ((* EIN/ -- *)     repr : StrRepr;
                     (* EIN/ -- *) VAR sym  : Symbols );

BEGIN
 RBTrees.GetInfo(ReprTable, repr, sym);
END GetSymbol;

(*---------------------------------------------------------------------------*)

PROCEDURE GetStrRepr ((* EIN/ -- *)     repr : StrRepr;
                      (* -- /AUS *) VAR str  : ARRAY OF CHAR;
                      (* -- /AUS *) VAR done : BOOLEAN );

VAR key : StringRepresentation;

BEGIN
 RBTrees.GetKey(ReprTable, repr, key);
 AssignCToM2(ADDADR(StrTable, key.idx), 0, str);
 done := key.len <= VAL(StrRange,HIGH(str) + 1);
END GetStrRepr;

(*---------------------------------------------------------------------------*)

PROCEDURE StrReprLen ((* EIN/ -- *) repr : StrRepr ): CARDINAL;

VAR key : StringRepresentation;

BEGIN
 RBTrees.GetKey(ReprTable, repr, key);
 RETURN(VAL(CARDINAL,key.len));
END StrReprLen;

(*---------------------------------------------------------------------------*)

PROCEDURE EmptyStrRepr ((* -- /AUS *) VAR repr : StrRepr );
BEGIN
 repr := NIL;
END EmptyStrRepr;

(*---------------------------------------------------------------------------*)

PROCEDURE IsStrRepr ((* EIN/ -- *) repr : StrRepr ): BOOLEAN;
BEGIN
 RETURN(repr <> NIL);
END IsStrRepr;

(*---------------------------------------------------------------------------*)

PROCEDURE EnlargeStrTable;
(* Wenn der Platz in der Stringtabelle nicht mehr ausreicht, um <ch>
 * und ein abschliessendes 0C unterzubringen, eine doppelt so grosse
 * Tabelle anlegen und den Inhalt der alten Tabelle umkopieren.
 *)
BEGIN
 INC(StrTableSize, StrTableSize);
 StrTable := realloc(StrTable, StrTableSize);
 IF StrTable = NULL THEN
   RaiseADTException(noMem, "M2StrTable.EnlargeStrTable: No memory");
 END;
END EnlargeStrTable;

(*---------------------------------------------------------------------------*)

PROCEDURE NewStrRepr;
BEGIN
 StrTableIdx := StrTableNext;
END NewStrRepr;

(*---------------------------------------------------------------------------*)

PROCEDURE AddStrReprCh ((* EIN/ -- *) ch : CHAR );

VAR cp : POINTER TO CHAR;

BEGIN
 IF StrTableIdx + VAL(UNSIGNEDLONG,1) >= StrTableSize THEN
   EnlargeStrTable;
 END;
 cp  := ADDADR(StrTable, StrTableIdx);
 cp^ := ch;
 INC(StrTableIdx);
END AddStrReprCh;

(*---------------------------------------------------------------------------*)

PROCEDURE EndStrRepr ((* -- /AUS *) VAR repr : StrRepr );

VAR rep : StringRepresentation;
    sym : Symbols;
    cp  : POINTER TO CHAR;

BEGIN
 cp      := ADDADR(StrTable, StrTableIdx);
 cp^     := 0C;
 rep.idx := StrTableNext;
 rep.len := VAL(StrRange,DIFADR(StrTableIdx, StrTableNext));
 repr    := RBTrees.Lookup(ReprTable, rep);
 IF repr = NIL THEN
   sym  := ErrorSym;
   repr := RBTrees.Insert(ReprTable, rep, sym);
   IF repr = NIL THEN
     RaiseADTException(noMem, "M2StrTable.EndStrRepr: No memory");
   END;
   StrTableNext := StrTableIdx + VAL(UNSIGNEDLONG,1);
 END;
END EndStrRepr;

(*---------------------------------------------------------------------------*)

PROCEDURE CreateStrRepr ((* EIN/ -- *) REF str  : ARRAY OF CHAR;
                         (* EIN/ -- *)     sym  : Symbols;
                         (* -- /AUS *) VAR repr : StrRepr );

VAR i : UNSIGNEDWORD;

BEGIN
 NewStrRepr;
 i := 0;
 WHILE (i <= VAL(UNSIGNEDWORD,HIGH(str))) & (str[i] <> EOS) DO
   AddStrReprCh(str[i]);
   INC(i);
 END;
 EndStrRepr(repr);
 SetSymbol(repr, sym);
END CreateStrRepr;

(*
PROCEDURE PrintStrTable;

VAR i   : UNSIGNEDLONG;
    str : ARRAY [0..200] OF CHAR;

BEGIN
 i := 0;
 WHILE i < StrTableNext DO
   AssignCToM2(ADDADR(StrTable, i), 0, str);
   WriteString(str); WriteLn;
   INC(i, strlen(ADDADR(StrTable, i) + VAL(UNSIGNEDLONG,1)));
 END;
END PrintStrTable;
*)

(*===========================================================================*)

VAR done : BOOLEAN;

BEGIN (* M2StrTable *)
 RBTrees.Create(TSIZE(StringRepresentation), TSIZE(Symbols), Blocks, cmp, ReprTable, done);
 StrTable := malloc(MinTableSize);
 IF ~done OR (StrTable = NULL) THEN
   RaiseADTException(noMem, "M2StrTable: No memory for table");
 END;
 StrTableSize := MinTableSize;
 StrTableNext := 0;
 StrTableIdx  := 0;
END M2StrTable.
