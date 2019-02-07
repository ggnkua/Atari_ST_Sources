IMPLEMENTATION MODULE LongStr;
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
(* 27-Okt-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD;

IMPORT LowLong;

FROM FConvBase IMPORT
(* CONST*) MaxLExp, MinLExp,
(* TYPE *) ExpStr, SigFigStr, RealFormat,
(* PROC *) split, mantToStr, expLen, floatToStr, fixToStr, strToReal,
           formToStr;

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
                     (* -- /AUS *) VAR real : LONGREAL;
                     (* -- /AUS *) VAR res  : ConvResults   );
BEGIN
 real := strToReal(str, LowLong.small, MinLExp, LowLong.large, MaxLExp, res);
END StrToReal;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToFloat ((* EIN/ -- *)     real    : LONGREAL;
                       (* EIN/ -- *)     sigFigs : CARDINAL;
                       (* -- /AUS *) VAR str     : ARRAY OF CHAR );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    form : RealFormat;

BEGIN
 IF split(real, neg, real, exp, form) THEN
   floatToStr(neg, real, exp, FALSE, VAL(UNSIGNEDWORD,sigFigs), TRUE, str);
 ELSE
   formToStr(form, str);
 END;
END RealToFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToEng ((* EIN/ -- *)     real    : LONGREAL;
                     (* EIN/ -- *)     sigFigs : CARDINAL;
                     (* -- /AUS *) VAR str     : ARRAY OF CHAR );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    form : RealFormat;

BEGIN
 IF split(real, neg, real, exp, form) THEN
   floatToStr(neg, real, exp, TRUE, VAL(UNSIGNEDWORD,sigFigs), TRUE, str);
 ELSE
   formToStr(form, str);
 END;
END RealToEng;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToFixed ((* EIN/ -- *)     real   : LONGREAL;
                       (* EIN/ -- *)     places : INTEGER;
                       (* -- /AUS *) VAR str    : ARRAY OF CHAR );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    form : RealFormat;

BEGIN
 IF split(real, neg, real, exp, form) THEN
   fixToStr(neg, real, exp, VAL(SIGNEDWORD,places), TRUE, str);
 ELSE
   formToStr(form, str);
 END;
END RealToFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToStr ((* EIN/ -- *)     real : LONGREAL;
                     (* -- /AUS *) VAR str  : ARRAY OF CHAR );

VAR neg    : BOOLEAN;
    exp    : SIGNEDWORD;
    whole  : SIGNEDWORD;
    mant   : SigFigStr;
    digs   : UNSIGNEDWORD;
    needs  : SIGNEDWORD;
    form   : RealFormat;

BEGIN
 IF ~split(real, neg, real, exp, form) THEN
   formToStr(form, str);
   RETURN;
 END;
 IF exp >= 0 THEN
   whole := exp;
   IF real >= nine THEN
     (* Repraesentation kann durch Rundung ein Zeichen laenger werden,
      * bzw. die Exponentenlaenge kann sich aendern, wenn der Exponent
      * durch die Rundung von Null auf Eins geaendert wird.
      *)
     mantToStr(real, TRUE, -1, TRUE, whole, digs, mant);
   END;
   (* Anzahl der Vorkommastellen ist um Eins hoeher als der Exponent *)
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
   fixToStr(neg, real, exp, VAL(SIGNEDWORD,HIGH(str)) - needs, TRUE, str);
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
   floatToStr(neg, real, exp, FALSE, CAST(UNSIGNEDWORD,needs), TRUE, str);
 END;
END RealToStr;

#if (defined TDIM2) || (defined SPCM2)
(*===========================================================================*)

BEGIN (* LongStr *)
 WITH cast DO
   lc1 := 040220000H; lc2 := 0H; nine := lr;
 END;
#endif
END LongStr.
