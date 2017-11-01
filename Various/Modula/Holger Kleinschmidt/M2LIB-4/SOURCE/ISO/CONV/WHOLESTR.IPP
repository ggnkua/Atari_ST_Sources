IMPLEMENTATION MODULE WholeStr;
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
(* 25-Mai-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'SIGNED' und 'UNSIGNED' koennen mittels CAST uminterpretiert
            werden, d.h. sie haben die gleiche Speichergroesse, oder CAST
            kann auch bei unterschiedlichen Groessen verwendet werden, und
            UNSIGNED ist groesser als SIGNED.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)


VAL_INTRINSIC
CAST_IMPORT


FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, UNSIGNED, SIGNED;

FROM WConvBase IMPORT
(* PROC *) strToCard, strToInt, valToStr;

(* Beispiel: Token, die keine gueltige Repraesentation darstellen, durch
   Text ersetzen:


   firstOnLine := TRUE;
   STextIO.ReadToken(inStr);
   WHILE SIOResult.ReadResult() # SIOResult.endOfInput DO
     WholeStr.StrToCard(inStr, inCard, inRes);
     CASE inRes OF
       ConvTypes.strAllRight..ConvTypes.strWrongFormat:
         IF firstOnLine THEN
           firstOnLine := FALSE;
         ELSE
           STextIO.WriteString(" ");
         END;
      |ConvTypes.strEmpty:
         firstOnLine := TRUE;
         STextIO.SkipLine;
     END;
     CASE inRes OF
       ConvTypes.strAllRight:
         STextIO.WriteString(inStr);
      |ConvTypes.strOutOfRange:
         STextIO.WriteString("out-of-range");
      |ConvTypes.strWrongFormat:
         STextIO.WriteString("wrong-format");
      |ConvTypes.strEmpty:
         STextIO.WriteLn;
     END;
     STextIO.ReadToken(inStr);
   END;
*)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE StrToInt ((* EIN/ -- *) REF str : ARRAY OF CHAR;
                    (* -- /AUS *) VAR int : SIGNED;
                    (* -- /AUS *) VAR res : ConvResults   );
BEGIN
 strToInt(str, int, res);
END StrToInt;

(*---------------------------------------------------------------------------*)

PROCEDURE IntToStr ((* EIN/ -- *)     int : SIGNED;
                    (* -- /AUS *) VAR str : ARRAY OF CHAR );

VAR len : UNSIGNEDWORD;

BEGIN
 valToStr(CAST(UNSIGNED,int), TRUE, len, str);
END IntToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE StrToCard ((* EIN/ -- *) REF str  : ARRAY OF CHAR;
                     (* -- /AUS *) VAR card : UNSIGNED;
                     (* -- /AUS *) VAR res  : ConvResults   );
BEGIN
 strToCard(str, card, res);
END StrToCard;

(*---------------------------------------------------------------------------*)

PROCEDURE CardToStr ((* EIN/ -- *)     card : UNSIGNED;
                     (* -- /AUS *) VAR str  : ARRAY OF CHAR );

VAR len : UNSIGNEDWORD;

BEGIN
 valToStr(card, FALSE, len, str);
END CardToStr;

END WholeStr.

