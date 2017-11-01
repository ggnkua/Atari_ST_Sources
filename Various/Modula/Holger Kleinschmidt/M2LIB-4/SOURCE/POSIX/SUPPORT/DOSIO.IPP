IMPLEMENTATION MODULE DosIO;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(****************************************************************************)
(* 10-Aug-96, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) ANYLONG, SIGNEDLONG, UNSIGNEDLONG, SIGNEDWORD;

FROM types IMPORT
(* CONST*) CR, LF,
(* TYPE *) StrPtr, StrRange, sizeT;

FROM OSCALLS IMPORT
(* PROC *) Cconout, Cconws, Cconin;

FROM blk IMPORT
(* PROC *) memalloc, memdealloc;

FROM ISOStrings IMPORT
(* PROC *) Length;

FROM str IMPORT
(* PROC *) AssignM2ToC;

FROM lib IMPORT
(* PROC *) ltoa, ultoa;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Write (c : CHAR);
BEGIN
 Cconout(c);
END Write;

PROCEDURE WriteString (REF s : ARRAY OF CHAR);

VAR stack : ADDRESS;
    str   : StrPtr;
    msize : CARDINAL;

BEGIN
 msize := Length(s) + 1;
 memalloc(VAL(sizeT,msize), stack, str);
 AssignM2ToC(s, VAL(StrRange,msize), str);
 Cconws(str);
 memdealloc(stack);
END WriteString;

PROCEDURE WriteLn;
BEGIN
 Cconout(CR);
 Cconout(LF);
END WriteLn;

PROCEDURE WriteCard (card : UNSIGNEDLONG; width : CARDINAL);
VAR s : ARRAY [0..20] OF CHAR;
    i : SIGNEDWORD;
BEGIN
 ultoa(card, ADR(s), 10);
 FOR i := 1 TO VAL(SIGNEDWORD,width) - VAL(SIGNEDWORD,Length(s)) DO
   Cconout(' ');
 END;
 Cconws(ADR(s));
END WriteCard;

PROCEDURE WriteInt (int : SIGNEDLONG; width : CARDINAL);
VAR s : ARRAY [0..20] OF CHAR;
    i : SIGNEDWORD;
BEGIN
 ltoa(int, ADR(s), 10);
 FOR i := 1 TO VAL(SIGNEDWORD,width) - VAL(SIGNEDWORD,Length(s)) DO
   Cconout(' ');
 END;
 Cconws(ADR(s));
END WriteInt;

PROCEDURE WriteHex (val : ANYLONG; width : CARDINAL);
VAR s : ARRAY [0..20] OF CHAR;
    i : SIGNEDWORD;
BEGIN
 ultoa(CAST(UNSIGNEDLONG,val), ADR(s), 16);
 FOR i := 1 TO VAL(SIGNEDWORD,width) - VAL(SIGNEDWORD,Length(s)) DO
   Cconout(' ');
 END;
 Cconws(ADR(s));
END WriteHex;

PROCEDURE Read (VAR c : CHAR);
BEGIN
 c := CHR(VAL(CARDINAL,Cconin()));
END Read;

END DosIO.
