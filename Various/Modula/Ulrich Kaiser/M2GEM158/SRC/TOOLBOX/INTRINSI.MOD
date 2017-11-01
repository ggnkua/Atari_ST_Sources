IMPLEMENTATION MODULE INTRINSIC;

(*
Procedures that should be intrinsic.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB IMPORT SIGNEDWORD,UNSIGNEDWORD,ANYWORD,ANYLONG,ANYTYPE,
                   ANYPOINTER;
FROM SYSTEM IMPORT WORD;
#if (defined TSM2_1) || (defined TSM2_2)
FROM Lib IMPORT AddAddr,SubAddr;
#elif (defined FTLM2)
FROM IntLogic IMPORT RS,LS;
#endif
CAST_IMPORT

#ifdef FTLM2
FROM SYSTEM IMPORT ADR;
#else
IMPORT SYSTEM;
#endif

#ifdef ANAM2
PROCEDURE LONG(AnyWord: ANYWORD): ANYLONG;

CONST D1 = 1;

BEGIN
  SYSTEM.SETREG(D1,AnyWord);
  SYSTEM.CODE(048C1H); (* ext.l d1 *)
  RETURN CAST(ANYLONG,SYSTEM.REGISTER(D1));
END LONG;

PROCEDURE SHORT(AnyLong: ANYLONG): ANYWORD;
BEGIN
  RETURN CAST(ANYWORD,AnyLong);
END SHORT;

#elif (defined LPRM2) || (defined SPCM2)
PROCEDURE LONG(AnyWord: ANYWORD): ANYLONG;
BEGIN
  RETURN SYSTEM.LONG(AnyWord);
END LONG;

PROCEDURE SHORT(AnyLong: ANYLONG): ANYWORD;
BEGIN
  RETURN SYSTEM.SHORT(AnyLong);
END SHORT;

#elif (defined HM2) || (defined XHM2)
PROCEDURE SHORT(AnyLong: ANYLONG): ANYWORD;

VAR Temp: SHORTCARD;

BEGIN
  Temp:= CARDINAL(AnyLong);
  RETURN ANYWORD(Temp);
END SHORT;

PROCEDURE LONG(AnyWord: ANYWORD): ANYLONG;

VAR Temp: INTEGER;

BEGIN
  Temp:= SHORTINT(AnyWord);
  (* ext.l Temp ? *)
  RETURN ANYLONG(Temp);
END LONG;

#elif (defined MSM2)
(*
PROCEDURE LONG(AnyWord: ANYWORD): ANYLONG;
BEGIN
  RETURN EXPAND(AnyWord);
END LONG;

PROCEDURE SHORT(AnyLong: ANYLONG): ANYWORD;
BEGIN
  RETURN SHORT(AnyLong);
END SHORT;
*)
#endif

#if (defined LPRM2) || (defined SPCM2)
(* department of dirty tricks...*)

PROCEDURE UNSIGNEDWORDOF(Anything: ARRAY OF ANYTYPE): UNSIGNEDWORD;

TYPE PUW = POINTER TO UNSIGNEDWORD;

VAR P: PUW;

BEGIN
  P:= SYSTEM.ADR(Anything[HIGH(Anything) - 1]);
  RETURN P^;
END UNSIGNEDWORDOF;

PROCEDURE SIGNEDWORDOF(Anything: ARRAY OF ANYTYPE): SIGNEDWORD;

TYPE PSW = POINTER TO SIGNEDWORD;

VAR P: PSW;

BEGIN
  P:= SYSTEM.ADR(Anything[HIGH(Anything) - 1]);
  RETURN P^;
END SIGNEDWORDOF;
#elif intel
(* department of dirty tricks...*)

PROCEDURE UNSIGNEDWORDOF(Anything: ARRAY OF ANYWORD): UNSIGNEDWORD;
BEGIN
   RETURN CAST(UNSIGNEDWORD,Anything[0]);
END UNSIGNEDWORDOF;

PROCEDURE SIGNEDWORDOF(Anything: ARRAY OF ANYWORD): SIGNEDWORD;
BEGIN
   RETURN CAST(SIGNEDWORD,Anything[0]);
END SIGNEDWORDOF;
#else
(* department of dirty tricks...*)

PROCEDURE UNSIGNEDWORDOF(Anything: ARRAY OF ANYWORD): UNSIGNEDWORD;
BEGIN
   RETURN CAST(UNSIGNEDWORD,Anything[HIGH(Anything)]);
END UNSIGNEDWORDOF;

PROCEDURE SIGNEDWORDOF(Anything: ARRAY OF ANYWORD): SIGNEDWORD;
BEGIN
   RETURN CAST(SIGNEDWORD,Anything[HIGH(Anything)]);
END SIGNEDWORDOF;
#endif

PROCEDURE SIZEOF(Anything: ARRAY OF ANYTYPE): CARDINAL;
BEGIN
  (* SIZE() is no persuasive function for SDSM2 or ANAM2 :-( *)
  RETURN HIGH(Anything) + 1;
END SIZEOF;

#ifdef FTLM2
PROCEDURE VOID(AnyWord: WORD);
#else
PROCEDURE VOID(AnyWord: SYSTEM.WORD);
#endif
BEGIN
  (* ignore argument *)
END VOID;

#if not ((defined TSM2_1) || (defined ISOM2))
PROCEDURE PTR(VAR AnyThing: ARRAY OF ANYTYPE): ANYPOINTER;
BEGIN
#ifdef FTLM2
  RETURN ADR(AnyThing);
#else
  RETURN SYSTEM.ADR(AnyThing);
#endif
END PTR;
#endif

#if (defined SPCM2) || (defined LPRM2)
PROCEDURE INCPTR(VAR Ptr: ANYPOINTER; Add: CARDINAL);
BEGIN
  Ptr:= CAST(LONGCARD,Ptr) + CAST(LONGCARD,Add);
END INCPTR;

PROCEDURE DECPTR(VAR Ptr: ANYPOINTER; Sub: CARDINAL);
BEGIN
  Ptr:= CAST(LONGCARD,Ptr) - CAST(LONGCARD,Sub);
END DECPTR;

#elif (defined HM2)
PROCEDURE INCPTR(VAR Ptr: ANYPOINTER; Add: CARDINAL);
BEGIN
  Ptr:= CAST(ANYPOINTER,CAST(CARDINAL,Ptr) + Add);
END INCPTR;

PROCEDURE DECPTR(VAR Ptr: ANYPOINTER; Sub: CARDINAL);
BEGIN
  Ptr:= CAST(ANYPOINTER,CAST(CARDINAL,Ptr) - Sub);
END DECPTR;

#elif (defined ANAM2) || (defined XAM2)  || (defined FSTM2) || \
      (defined LM2)   || (defined FTLM2) \

PROCEDURE INCPTR(VAR Ptr: ANYPOINTER; Add: CARDINAL);
BEGIN
  Ptr:= Ptr + Add;
END INCPTR;

PROCEDURE DECPTR(VAR Ptr: ANYPOINTER; Sub: CARDINAL);
BEGIN
  Ptr:= Ptr - Sub;
END DECPTR;

#elif (defined MM2)
PROCEDURE INCPTR(VAR Ptr: ANYPOINTER; Add: CARDINAL);
BEGIN
  Ptr:= Ptr + VAL(LONGCARD,Add); (* because of I- *)
END INCPTR;

PROCEDURE DECPTR(VAR Ptr: ANYPOINTER; Sub: CARDINAL);
BEGIN
  Ptr:= Ptr - VAL(LONGCARD,Sub); (* because of I- *)
END DECPTR;

#elif (defined TDIM2)
PROCEDURE INCPTR(VAR Ptr: ANYPOINTER; Add: CARDINAL);
BEGIN
  Ptr:= CAST(ANYPOINTER,LONGCARD(Ptr) + LONG(Add));
END INCPTR;

PROCEDURE DECPTR(VAR Ptr: ANYPOINTER; Sub: CARDINAL);
BEGIN
  Ptr:= CAST(ANYPOINTER,LONGCARD(Ptr) - LONG(Sub));
END DECPTR;

#elif (defined MSM2)
PROCEDURE INCPTR(VAR Ptr: ANYPOINTER; Add: CARDINAL);
BEGIN
  Ptr:= Ptr + EXPAND(Add);
END INCPTR;

PROCEDURE DECPTR(VAR Ptr: ANYPOINTER; Sub: CARDINAL);
BEGIN
  Ptr:= Ptr - EXPAND(Sub);
END DECPTR;
#endif

#if (defined HM2) || (defined XHM2)
(*$X- wichtig wegen fehlendem RETURN *)
#endif

(*
Amount > 0: <<
Amount < 0: >>
*)

PROCEDURE SHIFT(Word: ANYWORD; Amount: INTEGER): ANYWORD;

#ifdef MM2
TYPE WORDSET = SET OF SYSTEM.BITNUM[0..15];
#endif

BEGIN
#if (defined MM2)
  RETURN CAST(ANYWORD,SYSTEM.SHIFT(CAST(WORDSET,Word),Amount));

#elif (defined LPRM2) || (defined SPCM2)
  RETURN SYSTEM.SHIFT(Word,Amount);

#elif (defined ANAM2) || (defined XAM2) || (defined TDIM2)
  (* should better be LSH... *)
  RETURN CAST(ANYWORD,SYSTEM.ASH(CAST(INTEGER,Word),Amount));

#elif (defined TSM2_1) || (defined TSM2_2)
  IF Amount > 0 THEN
    RETURN (Word << WORD(Amount));
  ELSE
    RETURN (Word >> WORD(-Amount));
  END;

#elif (defined FTLM2)
  IF Amount > 0 THEN
    RETURN LS(Word,Amount);
  ELSE
    RETURN RS(Word,-Amount);
  END;
#elif (defined HM2) || (defined XHM2)
  IF Amount < 0 THEN
   (* Die Reihenfolge der LOAD-Operationen ist wichtig,
    * da fuer die Invertierung von <Amount> Register D0
    * verwendet wird.
    *)
    SYSTEM.LOAD(-Amount, 1);
    SYSTEM.LOAD(Word, 0);
    SYSTEM.CODE(0E268H); (* lsr.w D1,D0 *)
  ELSE
    SYSTEM.LOAD(Amount, 1);
    SYSTEM.LOAD(Word, 0);
    SYSTEM.CODE(0E368H); (* lsl.w D1,D0 *)
  END;
 (* kein RETURN noetig, da das Ergebnis bereits in Register D0 steht. *)
#else
  RETURN Word;
#endif
END SHIFT;
#if (defined HM2) || (defined XHM2)
(*$X=*)
#endif

END INTRINSIC.