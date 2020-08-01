MODULE LongStr;

(****************************************************************************)
(* 27-Okt-95, Holger Kleinschmidt                                           *)
(****************************************************************************)

(*============== IMPLEMENTIERUNGSHINWEIS ====================================*)
(* Fuer diese Implementierung gilt:                                          *)
(* Falls fuer die Zahl der signifikanten Stellen ('sigFigs') eine Null ange- *)
(* geben wird, werden 'FConvBase.DEFSIGFIGS' signifikante Stellen verwendet. *)
(* Falls der Real-Wert eine Darstellung von Unendlich ist, oder keine guel-  *)
(* tige Repraesentation ("FConvBase.checkReal()"), wird mit                  *)
(* "FConvBase.formToStr()" eine entsprechende Stringrepraesentation erzeugt. *)
(*===========================================================================*)

IMPORT Low:=LowLong, FConvBase, ConvTypes;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  strAllRight*    = ConvTypes.strAllRight;
  strOutOfRange*  = ConvTypes.strOutOfRange;
  strWrongFormat* = ConvTypes.strWrongFormat;
  strEmpty*       = ConvTypes.strEmpty;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE StrToReal* ((* EIN/ -- *)     str  : ARRAY OF CHAR;
                      (* -- /AUS *) VAR real : LONGREAL;
                      (* -- /AUS *) VAR res  : SHORTINT   );

(* Ignoriert fuehrende Leerzeichen in <str> und konvertiert den Rest
   des Strings in eine reelle Zahl mit Vorzeichen, falls dieser eine
   gueltige Repraesentation enthaelt. Die Repraesentation muss durch
   das Ende von <str> abgeschlossen sein, es duerfen keine weiteren
   Zeichen folgen.

   <res> liefert folgende Ergebnisse:

   'strAllRight':    <str> enthaelt eine gueltige Repraesentation einer reellen
                     Zahl mit Vorzeichen, und der Wert unter- oder
                     ueberschreitet nicht den Wertebereich von <real>. <real>
                     enthaelt den Wert.

   'strOutOfRange':  <str> enthaelt eine gueltige Repraesentation einer
                     reellen Zahl mit Vorzeichen, aber der Wert ueber- oder
                     unterschreitet den Wertebereich von <real>.
                     <real> enthaelt den maximal oder minimal moeglichen Wert,
                     je nach Vorzeichen.

   'strWrongFormat': <str> enthaelt noch Zeichen, die keine gueltige
                     Repraesentation einer reellen Zahl mit Vorzeichen bilden.
                     <real> ist undefiniert.

   'strEmpty':       <str> enthaelt keine weiteren Zeichen. <real> ist
                     undefiniert.
 *)

BEGIN
 real := FConvBase.strToReal(str,
                             Low.small,
                             FConvBase.MinLExp,
                             Low.large,
                             FConvBase.MaxLExp,
                             res);
END StrToReal;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToFloat* ((* EIN/ -- *)     real    : LONGREAL;
                        (* EIN/ -- *)     sigFigs : INTEGER;
                        (* -- /AUS *) VAR str     : ARRAY OF CHAR );

(* Wandelt <real> in eine Gleitkomma-Stringrepraesentation mit <sigFigs>
   signifikanten Stellen um, und kopiert das evtl. gekuerzte Resultat
   nach <str>.

   Es wird genau eine Ziffer vor dem Dezimalpunkt (falls vorhanden)
   geschrieben.
   Ein Vorzeichen wird nur bei negativem <real> geschrieben.
   Der Exponent mit Vorzeichen wird nur geschrieben, falls sein Wert
   nicht Null ist. Falls <sigFigs> = Null ist, wird ein Defaultwert
   eingesetzt. Falls es keine signifikanten Stellen hinter dem Dezimalpunkt
   gibt (sigFigs = 1), wird kein Dezimalpunkt geschrieben.

   Beispiele fuer die Ausgabe als Gleitkommazahl:

   <real>       3923009    39.23009   0.0003923009
   <sigFigs>
   1               4E+6        4E+1           4E-4
   2             3.9E+6      3.9E+1         3.9E-4
   5          3.9230E+6   3.9230E+1      3.9230E-4
 *)

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    form : SHORTINT;

BEGIN
 IF FConvBase.split(real, neg, real, exp, form) THEN
   FConvBase.floatToStr(neg, real, exp, FALSE, sigFigs, TRUE, str);
 ELSE
   FConvBase.formToStr(form, str);
 END;
END RealToFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToEng* ((* EIN/ -- *)     real    : LONGREAL;
                      (* EIN/ -- *)     sigFigs : INTEGER;
                      (* -- /AUS *) VAR str     : ARRAY OF CHAR );

(* Verhaelt sich wie ein Aufruf von "RealToFloat()", ausser dass der
   Exponent ein Vielfaches von Drei ist, und dementsprechend ein bis
   drei Ziffern vor dem Dezimalpunkt stehen.

   Beispiele fuer die Ausgabe als technische Gleitkommazahl:

   <real>       3923009   39.23009   0.0003923009
   <sigFigs>
   1               4E+6         40         400E-6
   2             3.9E+6         39         390E-6
   5          3.9230E+6     39.230      392.30E-6
 *)

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    form : SHORTINT;

BEGIN
 IF FConvBase.split(real, neg, real, exp, form) THEN
   FConvBase.floatToStr(neg, real, exp, TRUE, sigFigs, TRUE, str);
 ELSE
   FConvBase.formToStr(form, str);
 END;
END RealToEng;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToFixed* ((* EIN/ -- *)     real   : LONGREAL;
                        (* EIN/ -- *)     places : INTEGER;
                        (* -- /AUS *) VAR str    : ARRAY OF CHAR );

(* Wandelt <real> in eine Fixpunkt-Stringrepraesentation um, die auf <places>
   Stellen bzgl. des Dezimalpunkts gerundet ist, und kopiert das evtl.
   gekuerzte Resultat nach <str>.

   Ein Vorzeichen wird nur bei negativem <real> geschrieben.
   Es wird mindestens eine Ziffer vor dem Dezimalpunkt (falls vorhanden)
   geschrieben. Wenn <places> negativ ist, wird kein Dezimalpunkt
   geschrieben.

   Beispiele fuer die Ausgabe als Fixpunktzahl:

   <real>        3923009   39.23009   0.0003923009
   <places>
   -5            3920000          0              0
   -2            3923010         40              0
   -1            3923009         39              0
    0           3923009.        39.             0.
    1          3923009.0       39.2            0.0
    4       3923009.0000    39.2301         0.0004
 *)

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    form : SHORTINT;

BEGIN
 IF FConvBase.split(real, neg, real, exp, form) THEN
   FConvBase.fixToStr(neg, real, exp, places, TRUE, str);
 ELSE
   FConvBase.formToStr(form, str);
 END;
END RealToFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE RealToStr* ((* EIN/ -- *)     real : LONGREAL;
                      (* -- /AUS *) VAR str  : ARRAY OF CHAR );

(* Falls in <str> Platz genug ist, wird <real> mit "RealToFixed()" in
   eine Fixpunktrepraesentation umgewandelt, wobei <places> so gewaehlt
   wird, dass <str> vollstaendig gefuellt wird; ansonsten wird mit
   "RealToFloat()" in eine Gleitkommarepraesentation umgewandelt, und das
   evtl. gekuerzte Resultat wird nach <str> kopiert. <sigFigs> wird so
   gewaehlt, dass <str> vollstaendig gefuellt wird.
 *)

VAR neg    : BOOLEAN;
    exp    : INTEGER;
    whole  : INTEGER;
    mant   : FConvBase.SigFigStr;
    digs   : INTEGER;
    needs  : INTEGER;
    form   : SHORTINT;

BEGIN
 IF ~FConvBase.split(real, neg, real, exp, form) THEN
   FConvBase.formToStr(form, str);
   RETURN;
 END;
 IF exp >= 0 THEN
   whole := exp;
   IF real >= 9.0D0 THEN
     (* Repraesentation kann durch Rundung ein Zeichen laenger werden,
      * bzw. die Exponentenlaenge kann sich aendern, wenn der Exponent
      * durch die Rundung von Null auf Eins geaendert wird.
      *)
     FConvBase.mantToStr(real, TRUE, -1, TRUE, whole, digs, mant);
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
 IF needs < LEN(str) THEN
   (* Da die Feldbreite groesser als die benoetigte Mindestgroesse ist,
    * kann die Fixpunktdarstellung verwendet werden. Es wird auf die
    * angegebene Feldbreite mit dem Dezimalpunkt und Nachkommastellen
    * aufgefuellt.
    *)
   FConvBase.fixToStr(neg, real, exp, SHORT(LEN(str)) - 2 - needs, TRUE, str);
 ELSE
   (* Es werden mindestens die Vorkommastelle und der Exponent benoetigt *)
   needs := 1 + FConvBase.expLen(exp);
   IF neg THEN
     (* Platz fuer Minuszeichen *)
     INC(needs);
   END;
   IF LEN(str) - 2 <= needs THEN
     (* Mindestens die Vorkommastelle schreiben. Auch wenn noch Platz fuer
      * den Dezimalpunkt waere, wird nur die Vorkommastelle geschrieben.
      *)
     needs := 1;
   ELSE
     (* Noch soviele Nachkommastellen, dass der Platz einschliesslich
      * Vorkommastelle und Dezimalpunkt aufgefuellt wird.
      *)
     needs := SHORT(LEN(str)) - needs - 1;
   END;
   FConvBase.floatToStr(neg, real, exp, FALSE, needs, TRUE, str);
 END;
END RealToStr;

END LongStr.
