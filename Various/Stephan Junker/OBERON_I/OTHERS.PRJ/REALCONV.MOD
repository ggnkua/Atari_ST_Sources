MODULE RealConv;

(****************************************************************************)
(* 27-Okt-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

(* "ScanReal()" bildet den Startzustand eines endlichen Automaten zur
   Erkennung von gueltigen Repraesentationen von reellen Zahlen.
   Beginnend mit <nextState> := ScanReal wird solange die Prozedur
   aufgerufen, deren Wert durch den letzten Aufruf <nextState> zugewiesen
   wurde, zusammen mit dem naechsten Eingabezeichen, bis der Wert von
   <chClass> 'terminator' oder 'invalid' ist.
   Moeglicherweise kann der Interpreter Zeichen, die als 'invalid' erkannt
   wurden, ignorieren, z.B. wenn bei einer interaktiven Eingabe nur gueltige
   Zeichen als Echo zurueckgeschrieben werden, um dem Benutzer eine Kontrolle
   zu geben.

   Beispiel:
   ---------
     ...
     idx   := 0;
     state := RealConv.ScanReal;
     LOOP
       state(str[idx], class, state)
       CASE class OF
         padding:
        |valid:
        |invalid, terminator:
          EXIT;
       END;
       INC(idx);
     END;
     ...

   Wenn die Eingabesequenz endet, bevor ein Zeichen als 'terminator'
   erkannt wurde, sollte das Stringendezeichen als letzte Eingabe fuer den
   Automaten benutzt werden. Wenn die bisherige Zeichensequenz eine gueltige
   Repraesentation darstellte, wird das Stringendezeichen als 'terminator'
   erkannt, sonst als 'invalid'.
 *)

IMPORT Sys, S:=SYSTEM, ConvTypes, Low:=LowReal, Conv:=FConvBase;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  strAllRight*    = ConvTypes.strAllRight;
  strOutOfRange*  = ConvTypes.strOutOfRange;
  strWrongFormat* = ConvTypes.strWrongFormat;
  strEmpty*       = ConvTypes.strEmpty;

CONST
  padding*    = ConvTypes.padding;
  valid*      = ConvTypes.valid;
  invalid*    = ConvTypes.invalid;
  terminator* = ConvTypes.terminator;

TYPE
  ScanStatePtr = POINTER TO RECORD
                              st : ConvTypes.ScanState;
                            END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Term ((* EIN/ -- *)     inputCh   : CHAR;
                (* -- /AUS *) VAR chClass   : SHORTINT;
                (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 chClass := terminator;
 stP     := S.VAL(ScanStatePtr,S.ADR(nextState));
 stP.st  := Term;
END Term;

(*---------------------------------------------------------------------------*)

PROCEDURE WE ((* EIN/ -- *)     inputCh   : CHAR;
              (* -- /AUS *) VAR chClass   : SHORTINT;
              (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := valid;
   stP.st  := WE;
 ELSE
   chClass := terminator;
   stP.st  := Term;
 END;
END WE;

(*---------------------------------------------------------------------------*)

PROCEDURE SE ((* EIN/ -- *)     inputCh   : CHAR;
              (* -- /AUS *) VAR chClass   : SHORTINT;
              (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := valid;
   stP.st  := WE;
 ELSE
   chClass := invalid;
   stP.st  := SE;
 END;
END SE;

(*---------------------------------------------------------------------------*)

PROCEDURE E ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : SHORTINT;
             (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 CASE inputCh OF
   '-','+' : chClass := valid;
             stP.st  := SE;
  |'0'..'9': chClass := valid;
             stP.st  := WE;
 ELSE        chClass := invalid;
             stP.st  := E;
 END;
END E;

(*---------------------------------------------------------------------------*)

PROCEDURE F ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : SHORTINT;
             (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 CASE inputCh OF
   '0'..'9': chClass := valid;
             stP.st  := F;
  |'E','e',
   'D','d' : chClass := valid;
             stP.st  := E;
 ELSE        chClass := terminator;
             stP.st  := Term;
 END;
END F;

(*---------------------------------------------------------------------------*)

PROCEDURE P ((* EIN/ -- *)     inputCh   : CHAR;
             (* -- /AUS *) VAR chClass   : SHORTINT;
             (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 CASE inputCh OF
   '0'..'9': chClass := valid;
             stP.st  := P;
  |'.'     : chClass := valid;
             stP.st  := F;
  |'E','e',
   'D','d' : chClass := valid;
             stP.st  := E;
 ELSE        chClass := terminator;
             stP.st  := Term;
 END;
END P;

(*---------------------------------------------------------------------------*)

PROCEDURE RS ((* EIN/ -- *)     inputCh   : CHAR;
              (* -- /AUS *) VAR chClass   : SHORTINT;
              (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 IF ('0' <= inputCh) & (inputCh <= '9') THEN
   chClass := valid;
   stP.st  := P;
 ELSE
   chClass := invalid;
   stP.st  := RS;
 END;
END RS;

(*---------------------------------------------------------------------------*)

PROCEDURE ScanReal* ((* EIN/ -- *)     inputCh   : CHAR;
                     (* -- /AUS *) VAR chClass   : SHORTINT;
                     (* -- /AUS *) VAR nextState : ARRAY OF S.BYTE );

VAR stP : ScanStatePtr;

BEGIN
 stP := S.VAL(ScanStatePtr,S.ADR(nextState));
 CASE inputCh OF
   ' '     : chClass := padding;
             stP.st  := ScanReal;
  |'-','+' : chClass := valid;
             stP.st  := RS;
  |'0'..'9': chClass := valid;
             stP.st  := P;
 ELSE        chClass := invalid;
             stP.st  := ScanReal;
 END;
END ScanReal;

(*---------------------------------------------------------------------------*)

PROCEDURE FormatReal* ((* EIN/ -- *) str : ARRAY OF CHAR ): SHORTINT;

(* Liefert das Format der Stringrepraesentation einer reellen Zahl mit
   Vorzeichen in <str>. Fuehrende Leerzeichen werden ignoriert, aber der
   gesamte Rest des Strings muss eine gueltige Repraesentation darstellen,
   die durch das Stringende abgeschlossen ist.


   'strAllRight':    <str> enthaelt eine gueltige Repraesentation einer
                     reellen Zahl mit Vorzeichen, und der Wert unter- oder
                     ueberschreitet nicht den moeglichen Wertebereich.

   'strOutOfRange':  <str> enthaelt eine gueltige Repraesentation einer
                     reellen Zahl mit Vorzeichen, aber der Wert
                     ueberschreitet den moeglichen Wertebereich.

   'strWrongFormat': <str> enthaelt zwar noch Zeichen, aber diese bilden keine
                     gueltige Repraesentation einer reellen Zahl mit
                     Vorzeichen.

   'strEmpty':       <str> enthaelt keine weiteren Zeichen ausser fuehrenden
                     Leerzeichen.
 *)

VAR res : SHORTINT;

BEGIN
 S.VOID(Conv.strToReal(str,
                       Low.small,
                       Conv.MinExp,
                       Low.large,
                       Conv.MaxExp,
                       res));
 RETURN(res);
END FormatReal;

(*---------------------------------------------------------------------------*)

PROCEDURE ValueReal* ((* EIN/ -- *) str : ARRAY OF CHAR ): REAL;

(* Wenn in <str> die gueltige Repraesentation einer reellen Zahl mit
   Vorzeichen steht, wird der entsprechende Wert zurueckgeliefert,
 *)

VAR res : SHORTINT;
    val : REAL;

BEGIN
 val := SHORT(Conv.strToReal(str,
                             Low.small,
                             Conv.MinExp,
                             Low.large,
                             Conv.MaxExp,
                             res));

 IF (res # ConvTypes.strAllRight) & (res # ConvTypes.strOutOfRange) THEN
   HALT(Sys.REALERR);
 ELSE
   RETURN(val);
 END;
END ValueReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthFloatReal* ((* EIN/ -- *) real    : REAL;
                            (* EIN/ -- *) sigFigs : INTEGER ): INTEGER;

(* Liefert die Anzahl der Zeichen, die fuer eine Gleitkomma-
   Stringrepraesentation von <real> mit <sigFigs> signifikanten Stellen
   noetig sind.
 *)
VAR form : SHORTINT;

BEGIN
 IF Conv.checkReal(real, form) THEN
   RETURN(Conv.FloatLength(real, FALSE, FALSE, sigFigs));
 ELSE
   RETURN(Conv.formLen(form));
 END;
END LengthFloatReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthEngReal* ((* EIN/ -- *) real    : REAL;
                          (* EIN/ -- *) sigFigs : INTEGER ): INTEGER;

(* Liefert die Anzahl der Zeichen, die fuer eine Gleitkomma-
   Stringrepraesentation von <real> mit <sigFigs> signifikanten Stellen
   noetig sind, wobei der Exponent ein ganzzahliges Vielfaches von drei ist.
 *)
VAR form : SHORTINT;

BEGIN
 IF Conv.checkReal(real, form) THEN
   RETURN(Conv.FloatLength(real, TRUE, FALSE, sigFigs));
 ELSE
   RETURN(Conv.formLen(form));
 END;
END LengthEngReal;

(*---------------------------------------------------------------------------*)

PROCEDURE LengthFixedReal* ((* EIN/ -- *) real  : REAL;
                            (* EIN/ -- *) place : INTEGER ): INTEGER;

(* Liefert die Anzahl der Zeichen, die fuer eine Fixpunkt-
   Stringrepraesentation von <real>, auf <place> Stellen bzgl. des Dezimal-
   punktes gerundet, noetig sind.
 *)
VAR form : SHORTINT;

BEGIN
 IF Conv.checkReal(real, form) THEN
   RETURN(Conv.FixLength(real, FALSE, place));
 ELSE
   RETURN(Conv.formLen(form));
 END;
END LengthFixedReal;

END RealConv.
