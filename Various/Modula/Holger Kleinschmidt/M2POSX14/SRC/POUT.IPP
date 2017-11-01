IMPLEMENTATION MODULE pOUT;
__IMP_SWITCHES__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) ANYLONG, SIGNEDLONG, UNSIGNEDLONG;

#if (defined LPRM2) || (defined SPCM2) || (defined TDIM2)
FROM InOut IMPORT Write;
FROM LongInOut IMPORT WriteLongCard, WriteLongInt, WriteLongHex;
FROM RealInOut IMPORT WriteReal, WriteLongReal;
#elif (defined MM2)
FROM InOut IMPORT Write, WriteCard, WriteInt, WriteLHex, WriteFloat;
#elif (defined HM2)
FROM BufInOut IMPORT Write, WriteCard, WriteInt, WriteNum;
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
BEGIN
#if (defined LPRM2) || (defined SPCM2) || (defined TDIM2)
 WriteLongInt(int, width);
#else
 WriteInt(int, width);
#endif
END PutInt;

PROCEDURE PutCard (card : UNSIGNEDLONG; width : CARDINAL);
BEGIN
#if (defined LPRM2) || (defined SPCM2) || (defined TDIM2)
 WriteLongCard(card, width);
#else
 WriteCard(card, width);
#endif
END PutCard;

PROCEDURE PutHex (val : ANYLONG; width : CARDINAL);
BEGIN
#if (defined LPRM2) || (defined SPCM2) || (defined TDIM2)
 WriteLongHex(CAST(LONGCARD,val), width);
#elif (defined MM2)
 WriteLHex(val, width);
#elif (defined HM2)
 WriteNum(CAST(LONGCARD,val), 16, width);
#endif
END PutHex;

PROCEDURE PutReal (real : REAL; width : CARDINAL);
VAR a,b:CARDINAL;
BEGIN
#ifdef HM2
 IF width > 22 THEN
   a:=width;
   b:=16;
 ELSE
   a:=width;
   b:=width-7;
 END;
 WriteReal(real, a, b, TRUE);
#elif (defined MM2)
 IF width > 23 THEN
   a:=width;
   b:=15;
 ELSE
   a:=0;
   b:=width-9;
 END;
 WriteFloat(real, a, b);
#elif (defined LPRM2) || (defined SPCM2)
 WriteLongReal(real, width);
#elif (defined TDIM2)
 IF width > 24 THEN
   FOR a:=0 TO width-25 DO
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
VAR a,b:CARDINAL;
BEGIN
#ifdef HM2
 IF width > 22 THEN
   a:=width;
   b:=16;
 ELSE
   a:=width;
   b:=width-7;
 END;
 WriteReal(real, a, b, TRUE);
#elif (defined MM2)
 IF width > 23 THEN
   a:=width;
   b:=15;
 ELSE
   a:=0;
   b:=width-9;
 END;
 WriteFloat(real, a, b);
#elif (defined LPRM2) || (defined SPCM2)
 WriteLongReal(real, width);
#elif (defined TDIM2)
 IF width > 24 THEN
   FOR a:=0 TO width-25 DO
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
