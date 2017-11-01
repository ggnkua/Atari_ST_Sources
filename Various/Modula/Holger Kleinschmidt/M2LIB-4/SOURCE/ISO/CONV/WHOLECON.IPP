IMPLEMENTATION MODULE WholeConv;
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

(* Beispiel:

   Liefert Position des ersten Zeichens im String, das kein fuehrendes
   Leerzeichen ist, und die Position des ersten Zeichens, dass nicht mehr
   zur Repraesentation einer ganzen Zahl mit Vorzeichen gehoert:


   PROCEDURE FindInt(    str   : ARRAY OF CHAR;
                     VAR first : CARDINAL;
                     VAR next  : CARDINAL      );

   VAR
     ch    : CHAR;
     len   : CARDINAL;
     index : CARDINAL;
     state : ConvTypes.ScanState;
     class : ConvTypes.ScanClass;

   BEGIN
     len   := LENGTH(str);
     index := 0;
     first := len;
     state := WholeConv.ScanInt;
     LOOP
       IF index = len THEN
         ch := types.EOS;
       ELSE
         ch := str[index];
       END;
       state(ch, class, state)
       CASE class OF
         ConvTypes.padding:
        |ConvTypes.valid:
          IF index < first THEN
            first := index;
          END;
        |ConvTypes.invalid, ConvTypes.terminator:
          IF index < first THEN
            first := index;
          END;
          EXIT;
       END;
       INC(index);
     END;
     next := index;
   END FindInt;
*)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* CONST*) MINSIGNED,
(* TYPE *) UNSIGNEDWORD, UNSIGNED, SIGNED;
#if !ISO_recursive_proc_decl
FROM SYSTEM IMPORT ADR;
FROM PORTAB IMPORT ANYTYPE;
#endif

IMPORT ConvTypes, EXCEPTIONS;

FROM WConvBase IMPORT
(* PROC *) strToCard, strToInt;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if !ISO_recursive_proc_decl
TYPE
  ScanStatePtr = POINTER TO ConvTypes.ScanState;
#endif

VAR
  wholeConvSource : EXCEPTIONS.ExceptionSource;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if (defined HM2)
(*$E+*)
#endif
PROCEDURE Term ((* EIN/ -- *)     inputCh   : CHAR;
                (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
                (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
                (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
BEGIN
 chClass   := ConvTypes.terminator;
#if ISO_recursive_proc_decl
 nextState := Term;
#else
 stateP  := ADR(nextState);
 stateP^ := Term;
#endif
END Term;

(*---------------------------------------------------------------------------*)

PROCEDURE W ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
             (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
             (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
(* Repraesentation ist bei dem ersten Zeichen, das keine Ziffer ist, beendet *)
BEGIN
#if ISO_recursive_proc_decl
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass   := ConvTypes.valid;
   nextState := W;
 ELSE
   chClass   := ConvTypes.terminator;
   nextState := ScanInt;
 END;
#else
 stateP := ADR(nextState);
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := ConvTypes.valid;
   stateP^ := W;
 ELSE
   chClass := ConvTypes.terminator;
   stateP^ := ScanInt;
 END;
#endif
END W;

(*---------------------------------------------------------------------------*)

PROCEDURE S ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
             (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
             (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
(* Es wurde ein Vorzeichen erkannt, jetzt duerfen nur noch Ziffern folgen *)
BEGIN
#if ISO_recursive_proc_decl
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass   := ConvTypes.valid;
   nextState := W;
 ELSE
   chClass   := ConvTypes.invalid;
   nextState := S;
 END;
#else
 stateP := ADR(nextState);
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := ConvTypes.valid;
   stateP^ := W;
 ELSE
   chClass := ConvTypes.invalid;
   stateP^ := S;
 END;
#endif
END S;

(*---------------------------------------------------------------------------*)

PROCEDURE ScanInt ((* EIN/ -- *)     inputCh   : CHAR;
                   (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
                   (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
                   (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
(* Startzustand fuer das Erkennen von INTEGER-Repraesenationen *)
BEGIN
#if ISO_recursive_proc_decl
 CASE inputCh OF
   ' '     : chClass   := ConvTypes.padding;
             nextState := ScanInt;
  |'-','+' : chClass   := ConvTypes.valid;
             nextState := S;
  |'0'..'9': chClass   := ConvTypes.valid;
             nextState := W;
  ELSE       chClass   := ConvTypes.invalid;
             nextState := ScanInt;
 END;
#else
 stateP := ADR(nextState);
 CASE inputCh OF
   ' '     : chClass := ConvTypes.padding;
             stateP^ := ScanInt;
  |'-','+' : chClass := ConvTypes.valid;
             stateP^ := S;
  |'0'..'9': chClass := ConvTypes.valid;
             stateP^ := W;
  ELSE       chClass := ConvTypes.invalid;
             stateP^ := ScanInt;
 END;
#endif
END ScanInt;
#if (defined HM2)
(*$E=*)
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE FormatInt ((* EIN/ -- *) REF str : ARRAY OF CHAR ): ConvResults;

VAR res : ConvTypes.ConvResults;
    val : SIGNED;

BEGIN
 strToInt(str, val, res);
 RETURN(res);
END FormatInt;

(*---------------------------------------------------------------------------*)

PROCEDURE ValueInt ((* EIN/ -- *) REF str : ARRAY OF CHAR ): SIGNED;

VAR res : ConvTypes.ConvResults;
    val : SIGNED;

BEGIN
 strToInt(str, val, res);
 IF (res # ConvTypes.strAllRight) & (res # ConvTypes.strOutOfRange) THEN
   EXCEPTIONS.RAISE(wholeConvSource, ORD(res),
                    "WholeCon.ValueInt: invalid int format");
 ELSE
   RETURN(val);
 END;
END ValueInt;

(*---------------------------------------------------------------------------*)

PROCEDURE length ((* EIN/ -- *) val : UNSIGNED;
                  (* EIN/ -- *) len : UNSIGNEDWORD ): UNSIGNEDWORD;
BEGIN
(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   Falls 'UNSIGNED' groesser als 32 Bit ist,
   muessen entsprechend mehr Abfragen gemacht werden.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)
 IF val >= LC(100000) THEN
   val := val DIV LC(100000);
   INC(len, 5);
 END;
 IF val >= VAL(UNSIGNED,10000) THEN
   INC(len, 4);
 ELSIF val >= VAL(UNSIGNED,1000) THEN
   INC(len, 3);
 ELSIF val >= VAL(UNSIGNED,100) THEN
   INC(len, 2);
 ELSIF val >= VAL(UNSIGNED,10) THEN
   INC(len, 1);
 END;

 RETURN(len);
END length;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthInt ((* EIN/ -- *) int : SIGNED ): CARDINAL;
BEGIN
 IF int < VAL(SIGNED,0) THEN
   IF int # MINSIGNED THEN
     int := -int;
   END;
   RETURN(VAL(CARDINAL,length(CAST(UNSIGNED,int), 2)));
 ELSE
   RETURN(VAL(CARDINAL,length(CAST(UNSIGNED,int), 1)));
 END;
END LengthInt;

(*---------------------------------------------------------------------------*)
#if (defined HM2)
(*$E+*)
#endif
PROCEDURE ScanCard ((* EIN/ -- *)     inputCh   : CHAR;
                    (* -- /AUS *) VAR chClass   : ConvTypes.ScanClass;
#if ISO_recursive_proc_decl
                    (* -- /AUS *) VAR nextState : ConvTypes.ScanState );
#else
                    (* -- /AUS *) VAR nextState : ARRAY OF ANYTYPE    );

VAR __REG__ stateP : ScanStatePtr;
#endif
(* Startzustand fuer das Erkennen von CARDINAL-Repraesenationen *)
BEGIN
#if ISO_recursive_proc_decl
 CASE inputCh OF
   ' '    :  chClass   := ConvTypes.padding;
             nextState := ScanCard;
  |'0'..'9': chClass   := ConvTypes.valid;
             nextState := W;
  ELSE       chClass   := ConvTypes.invalid;
             nextState := ScanCard;
 END;
#else
 stateP := CAST(ScanStatePtr,ADR(nextState));
 CASE inputCh OF
   ' '    :  chClass := ConvTypes.padding;
             stateP^ := ScanCard;
  |'0'..'9': chClass := ConvTypes.valid;
             stateP^ := W;
  ELSE       chClass := ConvTypes.invalid;
             stateP^ := ScanCard;
 END;
#endif
END ScanCard;
#if (defined HM2)
(*$E=*)
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE FormatCard ((* EIN/ -- *) REF str : ARRAY OF CHAR ): ConvResults;

VAR val : UNSIGNED;
    res : ConvTypes.ConvResults;

BEGIN
 strToCard(str, val, res);
 RETURN(res);
END FormatCard;

(*---------------------------------------------------------------------------*)

PROCEDURE ValueCard ((* EIN/ -- *) REF str : ARRAY OF CHAR ): UNSIGNED;

VAR val : UNSIGNED;
    res : ConvTypes.ConvResults;

BEGIN
 strToCard(str, val, res);
 IF (res # ConvTypes.strAllRight) & (res # ConvTypes.strOutOfRange) THEN
   EXCEPTIONS.RAISE(wholeConvSource, ORD(res),
                    "WholeCon.ValueCard: invalid card format");
 ELSE
   RETURN(val);
 END;
END ValueCard;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthCard ((* EIN/ -- *) card : UNSIGNED ): CARDINAL;
BEGIN
 RETURN(VAL(CARDINAL,length(card, 1)));
END LengthCard;

(*---------------------------------------------------------------------------*)

PROCEDURE IsWholeConvException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(wholeConvSource));
END IsWholeConvException;

(*===========================================================================*)

BEGIN (* WholeConv *)
 EXCEPTIONS.AllocateSource(wholeConvSource);
END WholeConv.
