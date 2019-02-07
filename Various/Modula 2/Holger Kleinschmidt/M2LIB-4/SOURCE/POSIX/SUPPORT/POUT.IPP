IMPLEMENTATION MODULE pOUT;
__IMP_SWITCHES__
#ifdef HM2
#ifdef __LONG_REAL__
(*$!r+: Modul muss mit $r- uebersetzt werden! *)
#else
(*$!r-: Modul muss mit $r+ uebersetzt werden! *)
#endif
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(****************************************************************************)
(* 27-Aug-96, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) ANYLONG, SIGNEDLONG, SIGNEDWORD, UNSIGNEDLONG;

FROM ISOStrings IMPORT
(* PROC *) Length;

FROM lib IMPORT
(* PROC *) ltoa, ultoa;

#if (defined LPRM2)
(* IO-Module von ST-C PD #285 *)
FROM InOut IMPORT Write, WriteString;
(* FROM LongInOut IMPORT WriteLongCard, WriteLongInt, WriteLongHex; *)
FROM RealInOut IMPORT WriteLongReal;
#elif (defined TDIM2)
FROM InOut IMPORT Write, WriteString;
(* FROM LongInOut IMPORT WriteLongCard, WriteLongInt, WriteLongHex; *)
FROM RealInOut IMPORT WriteLongReal;
#elif (defined SPCM2)
FROM InOut IMPORT Write,(* WriteLongcard, WriteLongint, WriteAddress, *)
                  WriteLongreal, WriteString;
#elif (defined MM2)
FROM InOut IMPORT Write, WriteString, (* WriteCard, WriteInt, WriteLHex,*) WriteFloat;
#elif (defined HM2)
FROM BufInOut IMPORT Write, WriteString (*, WriteCard, WriteInt, WriteNum *);
FROM BufRealInOut IMPORT WriteReal;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  rc = RECORD
    CASE : BOOLEAN OF
      FALSE : r  : REAL;
     |TRUE  : lc : LONGCARD;
    END;
  END;

TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : LONGREAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE PutInt (int : SIGNEDLONG; width : CARDINAL);
VAR s : ARRAY [0..20] OF CHAR;
    i : SIGNEDWORD;
BEGIN
 ltoa(int, ADR(s), 10);
 FOR i := 1 TO VAL(SIGNEDWORD,width) - VAL(SIGNEDWORD,Length(s)) DO
   Write(' ');
 END;
 WriteString(s);
(*
#if (defined LPRM2) || (defined TDIM2)
 WriteLongInt(int, width);
#elif (defined SPCM2)
 IF width = 0 THEN width := 1; END;
 WriteLongint(int, width);
#else
 WriteInt(int, width);
#endif
*)
END PutInt;

PROCEDURE PutCard (card : UNSIGNEDLONG; width : CARDINAL);
VAR s : ARRAY [0..20] OF CHAR;
    i : SIGNEDWORD;
BEGIN
 ultoa(card, ADR(s), 10);
 FOR i := 1 TO VAL(SIGNEDWORD,width) - VAL(SIGNEDWORD,Length(s)) DO
   Write(' ');
 END;
 WriteString(s);
(*
#if (defined LPRM2) || (defined TDIM2)
 WriteLongCard(card, width);
#elif (defined SPCM2)
 IF width = 0 THEN width := 1; END;
 WriteLongcard(card, width);
#else
 WriteCard(card, width);
#endif
*)
END PutCard;

PROCEDURE PutHex (val : ANYLONG; width : CARDINAL);
VAR s : ARRAY [0..20] OF CHAR;
    i : SIGNEDWORD;
BEGIN
 ultoa(CAST(UNSIGNEDLONG,val), ADR(s), 16);
 FOR i := 1 TO VAL(SIGNEDWORD,width) - VAL(SIGNEDWORD,Length(s)) DO
   Write(' ');
 END;
 WriteString(s);
(*
#if (defined LPRM2) || (defined TDIM2)
 WriteLongHex(CAST(LONGCARD,val), width);
#elif (defined SPCM2)
 IF width = 0 THEN width := 1; END;
 WriteAddress(val, width);
#elif (defined MM2)
 WriteLHex(val, width);
#elif (defined HM2)
 WriteNum(CAST(LONGCARD,val), 16, width);
#endif
*)
END PutHex;

PROCEDURE PutReal (real : REAL; width : CARDINAL);
#ifdef HM2
VAR a : CARDINAL;
    b : INTEGER;
BEGIN
 a := width;
 IF a > 22 THEN
   b := 16;
 ELSIF a > 7 THEN
   b := a - 7;
 ELSE
   b := 0;
 END;
 WriteReal(real, a, b, TRUE);
#elif (defined MM2)
VAR a : CARDINAL;
    b : CARDINAL;
BEGIN
 IF width > 23 THEN
   a := width;
   b := 15;
 ELSE
   a := 0;
   IF width > 9 THEN
     b := width - 9;
   ELSE
     b := 0;
   END;
 END;
 WriteFloat(real, a, b);
#elif (defined LPRM2)
BEGIN
 WriteLongReal(real, width);
#elif (defined SPCM2)
VAR a : INTEGER;
    b : INTEGER;
BEGIN
 a := width;
 IF a > 22 THEN
   b := -15;
 ELSIF a > 8 THEN
   b := -(a - 7);
 ELSE
   b := -1;
 END;
 WriteLongreal(real, a, b);
#elif (defined TDIM2)
VAR a:CARDINAL;
BEGIN
 IF width > 24 THEN
   FOR a := 0 TO width - 25 DO
     Write(' ');
   END;
 END;
 WriteLongReal(LONG(real), width);
#endif
END PutReal;

PROCEDURE PutRealHex (real : REAL; width : CARDINAL);
VAR cast : rc;
BEGIN
 cast.r := real;
 PutHex(cast.lc, width);
END PutRealHex;

PROCEDURE PutLReal (real : LONGREAL; width : CARDINAL);
#ifdef HM2
VAR a : CARDINAL;
    b : INTEGER;
BEGIN
 a := width;
 IF a > 22 THEN
   b := 16;
 ELSIF a > 7 THEN
   b := a - 7;
 ELSE
   b := 0;
 END;
 WriteReal(real, a, b, TRUE);
#elif (defined MM2)
VAR a : CARDINAL;
    b : CARDINAL;
BEGIN
 IF width > 23 THEN
   a := width;
   b := 15;
 ELSE
   a := 0;
   IF width > 9 THEN
     b := width - 9;
   ELSE
     b :=0;
   END;
 END;
 WriteFloat(real, a, b);
#elif (defined LPRM2)
BEGIN
 WriteLongReal(real, width);
#elif (defined SPCM2)
VAR a : INTEGER;
    b : INTEGER;
BEGIN
 a := width;
 IF a > 22 THEN
   b := -15;
 ELSIF a > 8 THEN
   b := -(a - 7);
 ELSE
   b := -1;
 END;
 WriteLongreal(real, a, b);
#elif (defined TDIM2)
VAR a : CARDINAL;
BEGIN
 IF width > 24 THEN
   FOR a := 0 TO width - 25 DO
     Write(' ');
   END;
 END;
 WriteLongReal(real, width);
#endif
END PutLReal;

PROCEDURE PutLRealHex (real : LONGREAL; width : CARDINAL);
VAR cast : lrc;
BEGIN
 cast.lr := real;
 PutHex(cast.lc1, width DIV 2); Write('|'); PutHex(cast.lc2, width DIV 2);
END PutLRealHex;

END pOUT.
