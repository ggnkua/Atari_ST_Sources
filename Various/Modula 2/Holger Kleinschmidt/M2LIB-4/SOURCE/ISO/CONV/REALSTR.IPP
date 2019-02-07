IMPLEMENTATION MODULE RealStr;
__IMP_SWITCHES__
__DEBUG__
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
(* 27-Okt-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD;

#if (defined HM2) && (defined __LONG_REAL__)
IMPORT LowLong;
#else
IMPORT LowReal;
#endif

FROM FConvBase IMPORT
#if (defined HM2) && (defined __LONG_REAL__)
(* CONST*) MaxLExp, MinLExp,
(* TYPE *) ExpStr, SigFigStr, RealFormat,
(* PROC *) split, mantToStr, expLen, floatToStr, fixToStr, strToReal,
           formToStr, checkLReal;
#else
(* CONST*) MaxExp, MinExp,
(* TYPE *) ExpStr, SigFigStr, RealFormat,
(* PROC *) split, mantToStr, expLen, floatToStr, fixToStr, strToReal,
           formToStr, checkReal;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if (defined TDIM2) || (defined SPCM2)
VAR
  nine : LONGREAL; (* 9.0 *)

TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : LONGREAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

VAR
  cast : lrc;
#else
CONST
  nine  = LRC(9.0,0);
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE StrToReal ((* EIN/ -- *)     str  : ARRAY OF CHAR;
                     (* -- /AUS *) VAR real : REAL;
                     (* -- /AUS *) VAR res  : ConvResults   );

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 real := strToReal(str, LowLong.small, MinLExp, LowLong.large, MaxLExp, res);
#elif (defined TDIM2)
 real := SHORT(strToReal(str, LONG(LowReal.small), MinExp, LONG(LowReal.large), MaxExp, res));
#else
 real := strToReal(str, LowReal.small, MinExp, LowReal.large, MaxExp, res);
#endif
END StrToReal;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToFloat ((* EIN/ -- *)     real    : REAL;
                       (* EIN/ -- *)     sigFigs : CARDINAL;
                       (* -- /AUS *) VAR str     : ARRAY OF CHAR );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    long : LONGREAL;
    form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) &
#else
 IF checkReal(real, form) &
#endif
#ifdef TDIM2
    split(LONG(real), neg, long, exp, form)
#else
    split(real, neg, long, exp, form)
#endif
 THEN
#if (defined HM2) && (defined __LONG_REAL__)
   floatToStr(neg, long, exp, FALSE, VAL(UNSIGNEDWORD,sigFigs), TRUE, str);
#else
   floatToStr(neg, long, exp, FALSE, VAL(UNSIGNEDWORD,sigFigs), FALSE, str);
#endif
 ELSE
   formToStr(form, str);
 END;
END RealToFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToEng ((* EIN/ -- *)     real    : REAL;
                     (* EIN/ -- *)     sigFigs : CARDINAL;
                     (* -- /AUS *) VAR str     : ARRAY OF CHAR );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    long : LONGREAL;
    form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) &
#else
 IF checkReal(real, form) &
#endif
#ifdef TDIM2
    split(LONG(real), neg, long, exp, form)
#else
    split(real, neg, long, exp, form)
#endif
 THEN
#if (defined HM2) && (defined __LONG_REAL__)
   floatToStr(neg, long, exp, TRUE, VAL(UNSIGNEDWORD,sigFigs), TRUE, str);
#else
   floatToStr(neg, long, exp, TRUE, VAL(UNSIGNEDWORD,sigFigs), FALSE, str);
#endif
 ELSE
   formToStr(form, str);
 END;
END RealToEng;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToFixed ((* EIN/ -- *)     real   : REAL;
                       (* EIN/ -- *)     places : INTEGER;
                       (* -- /AUS *) VAR str    : ARRAY OF CHAR );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    long : LONGREAL;
    form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) &
#else
 IF checkReal(real, form) &
#endif
#ifdef TDIM2
    split(LONG(real), neg, long, exp, form)
#else
    split(real, neg, long, exp, form)
#endif
 THEN
#if (defined HM2) && (defined __LONG_REAL__)
   fixToStr(neg, long, exp, VAL(SIGNEDWORD,places), TRUE, str);
#else
   fixToStr(neg, long, exp, VAL(SIGNEDWORD,places), FALSE, str);
#endif
 ELSE
   formToStr(form, str);
 END;
END RealToFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToStr ((* EIN/ -- *)     real : REAL;
                     (* -- /AUS *) VAR str  : ARRAY OF CHAR );

VAR neg    : BOOLEAN;
    exp    : SIGNEDWORD;
    whole  : SIGNEDWORD;
    mant   : SigFigStr;
    digs   : UNSIGNEDWORD;
    needs  : SIGNEDWORD;
    long   : LONGREAL;
    form   : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF ~checkLReal(real, form) OR
#else
 IF ~checkReal(real, form) OR
#endif
#ifdef TDIM2
    ~split(LONG(real), neg, long, exp, form)
#else
    ~split(real, neg, long, exp, form)
#endif
 THEN
   formToStr(form, str);
   RETURN;
 END;
 IF exp >= 0 THEN
   whole := exp;
   IF long >= nine THEN
     (* Repraesentation kann durch Rundung ein Zeichen laenger werden,
      * bzw. die Exponentenlaenge kann sich aendern, wenn der Exponent
      * durch die Rundung von bzw. auf Null geaendert wird.
      *)
#if (defined HM2) && (defined __LONG_REAL__)
     mantToStr(long, TRUE, -1, TRUE, whole, digs, mant);
#else
     mantToStr(long, TRUE, -1, FALSE, whole, digs, mant);
#endif
   END;
   (* Anzahl der Vorkommastellen ist um eins hoeher als der Exponent *)
   INC(whole);
 ELSE
   (* Immer Fixpunktdarstellung; genau eine Vorkommastelle,
    * auch bei Rundung: 0.xx bzw. 1.xx.
    *)
   whole := 1;
 END;
 (* Die Repraesentation braucht mindestens soviel Zeichen wie
  * Vorkommastellen.
  *)
 needs := whole;
 IF neg THEN
   (* Ein Zeichen mehr fuer Minuszeichen *)
   INC(needs);
 END;
 IF needs <= VAL(SIGNEDWORD,HIGH(str)) + 1 THEN
   (* Da die Feldbreite groesser als die benoetigte Mindestgroesse ist,
    * kann die Fixpunktdarstellung verwendet werden. Es wird auf die
    * angegebene Feldbreite mit dem Dezimalpunkt und Nachkommastellen
    * aufgefuellt.
    *)
#if (defined HM2) && (defined __LONG_REAL__)
   fixToStr(neg, long, exp, VAL(SIGNEDWORD,HIGH(str)) - needs, TRUE, str);
#else
   fixToStr(neg, long, exp, VAL(SIGNEDWORD,HIGH(str)) - needs, FALSE, str);
#endif
 ELSE
   (* Es werden mindestens die Vorkommastelle und der Exponent benoetigt *)
   needs := 1 + CAST(SIGNEDWORD,expLen(exp));
   IF neg THEN
     (* Platz fuer Minuszeichen *)
     INC(needs);
   END;
   IF VAL(SIGNEDWORD,HIGH(str)) <= needs THEN
     (* Mindestens die Vorkommastelle schreiben. Auch wenn noch Platz fuer
      * den Dezimalpunkt waere, wird nur die Vorkommastelle geschrieben.
      *)
     needs := 1;
   ELSE
     (* Noch soviele Nachkommastellen, dass der Platz einschliesslich
      * Vorkommastelle und Dezimalpunkt aufgefuellt wird.
      *)
     needs := VAL(SIGNEDWORD,HIGH(str)) - needs + 1;
   END;
#if (defined HM2) && (defined __LONG_REAL__)
   floatToStr(neg, long, exp, FALSE, CAST(UNSIGNEDWORD,needs), TRUE, str);
#else
   floatToStr(neg, long, exp, FALSE, CAST(UNSIGNEDWORD,needs), FALSE, str);
#endif
 END;
END RealToStr;

#if (defined TDIM2) || (defined SPCM2)
(*===========================================================================*)

BEGIN (* RealStr *)
 WITH cast DO
   lc1 := 040220000H; lc2 := 0H; nine := lr;
 END;
#endif
END RealStr.
