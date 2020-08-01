MODULE FConvBase;

(*****************************************************************************)
(* 30-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

IMPORT SYSTEM, LowLong, ConvTypes;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  MAXLSIGFIGS* = 16; (* LONGREAL, IEEE double precision *)
  MAXSSIGFIGS* = 7;  (* REAL, IEEE single precision *)
  DEFSIGFIGS*  = 7;  (* Defaultwert, falls <sigFigs> = 0 *)
  MAXEXPFIGS*  = 10;
  MAXEXP*      = 310;
  MAXREAD*     = 255;
  MAXFORM*     = 4;

CONST
  MaxLExp* = 308;   (* Dezimalexponent von LowLong.large *)
  MinLExp* = -308;  (* -""- LowLong.small *)
  MaxExp*  = 38;    (* -""- LowReal.large *)
  MinExp*  = -38;   (* -""- LowReal.small *)

TYPE
  SigFigStr* = ARRAY MAXLSIGFIGS+2 OF CHAR;
  ExpStr*    = ARRAY MAXEXPFIGS+2 OF CHAR;
  ReadStr*   = ARRAY MAXREAD+2 OF CHAR; (* Max. String beim Einlesen *)
  FormStr*   = ARRAY MAXFORM+2 OF CHAR;

CONST
  mnull*  = 0; (* Negative Null *)
  pnull*  = 1; (* Null *)
  denorm* = 2; (* Wert unterhalb 'LowLong/Real.small' *)
  normal* = 3; (* Normaler Wert *)
  minf*   = 4; (* Darstellung von ``minus unendlich'' *)
  pinf*   = 5; (* Darstellung von ``plus unendlich'' *)
  nan*    = 6; (* Keine gueltige Darstellung (IEEE) *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* Mit diesen beiden Prozeduren kann die interne Real-Darstellung
   von <real> ueberprueft werden. Falls <format> <= 'normal', wird
   TRUE als Funktionswert geliefert, sonst FALSE.
 *)

PROCEDURE checkReal* ((* EIN/ -- *)     real   : REAL;
                      (* -- /AUS *) VAR format : SHORTINT ): BOOLEAN;

CONST
  ExpMask  = {23..30};
  MantMask = {0..22};

BEGIN
 IF SYSTEM.VAL(SET,real) * ExpMask = {} THEN
   IF SYSTEM.VAL(SET,real) * MantMask # {} THEN
     format := denorm;
   ELSIF SYSTEM.VAL(LONGINT,real) < 0 THEN
     format := mnull;
   ELSE
     format := pnull;
   END;
 ELSIF SYSTEM.VAL(SET,real) * ExpMask = ExpMask THEN
   IF SYSTEM.VAL(SET,real) * MantMask # {} THEN
     format := nan;
   ELSIF SYSTEM.VAL(LONGINT,real) < 0 THEN
     format := minf;
   ELSE
     format := pinf;
   END;
   RETURN(FALSE);
 ELSE
   format := normal;
 END;
 RETURN(TRUE);
END checkReal;

(*---------------------------------------------------------------------------*)

PROCEDURE checkLReal* ((* EIN/ -- *)     real   : LONGREAL;
                       (* -- /AUS *) VAR format : SHORTINT ): BOOLEAN;

TYPE
  RealCast = RECORD
    s1 : SET;
    s2 : SET;
  END;

CONST
  ExpMask  = {20..30};
  MantMask = {16..19};
  SignBit  = 31;

VAR
  cast : RealCast;

BEGIN
 cast := SYSTEM.VAL(RealCast,real);
 IF cast.s1 * ExpMask = {} THEN
   IF (cast.s1 * MantMask # {}) OR (cast.s2 # {}) THEN
     format := denorm;
   ELSIF SignBit IN cast.s1 THEN
     format := mnull;
   ELSE
     format := pnull;
   END;
 ELSIF cast.s1 * ExpMask = ExpMask THEN
   IF (cast.s1 * MantMask # {}) OR (cast.s2 # {}) THEN
     format := nan;
   ELSIF SignBit IN cast.s1 THEN
     format := minf;
   ELSE
     format := pinf;
   END;
   RETURN(FALSE);
 ELSE
   format := normal;
 END;
 RETURN(TRUE);
END checkLReal;

(*---------------------------------------------------------------------------*)

PROCEDURE formToStr* ((* EIN/ -- *)     form : SHORTINT;
                      (* -- /AUS *) VAR str  : ARRAY OF CHAR );

(* Falls <form> > 'normal' ist, enthaelt <str> eine Stringrepraesentation
   von <form>, sonst einen Leerstring.
 *)

VAR s : FormStr;

BEGIN
 CASE form OF
   minf : s := "-Inf";
  |pinf : s := "+Inf";
  |nan  : s := "NaN";
 ELSE     s := "";
 END;
 COPY(s, str);
END formToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE formLen* ((* EIN/ -- *) form : SHORTINT ): INTEGER;

(* Liefert die Laenge der Stringrepraesentation von <form> gemaess
   der Umsetzung mit "formToStr()".
 *)

BEGIN
 IF form <= normal THEN
   RETURN(0);
 ELSIF form = nan THEN
   RETURN(3); (* NaN *)
 ELSE
   RETURN(4); (* +/-Inf *)
 END;
END formLen;

(*---------------------------------------------------------------------------*)

PROCEDURE scale* ((* EIN/ -- *) x     : LONGREAL;
                  (* EIN/ -- *) shift : INTEGER ): LONGREAL;

(* Multipliziert <x> mit 10.0^<shift>. Dies entspricht einer Verschiebung
   von <x> um <shift> Dezimalstellen. Das interne Format von <x> muss
   <= 'normal' sein.

   Fuer die exakte Darstellung beliebiger Bitmuster <= 1.0E+22 wuerden
   mindestens 73 Mantissenbits benoetigt (log2(1.0E+22) ~ 73). Da aber bei
   Zehnerpotenzen die unteren Bits Null sind, kann 1.0E+22 noch mit
   'LowLong.places >= 52' Bits exakt dargestellt werden (nicht
   vorhandene Bits gelten als Nullbits). Die exakte Darstellung der
   Faktoren ist Voraussetzung fuer eine ``moeglichst genaue''
   Transformation von <x>.
 *)
BEGIN
 IF shift < 0 THEN
   (* Keine Multiplikation, da negative Zehnerpotenzen nicht
    * exakt darstellbar sind.
    *)
   WHILE shift <= -22 DO
     x := x / 1.0D22; INC(shift, 22);
   END;
   IF shift <= -16 THEN
     x := x / 1.0D16; INC(shift, 16);
   END;
   IF shift <= -8 THEN
     x := x / 1.0D8; INC(shift, 8);
   END;
   IF shift <= -4 THEN
     x := x / 1.0D4; INC(shift, 4);
   END;
   IF shift <= -2 THEN
     x := x / 1.0D2; INC(shift, 2);
   END;
   IF shift = -1 THEN
     x := x / 1.0D1;
   END;
 ELSE
   WHILE shift >= 22 DO
     x := x * 1.0D22; DEC(shift, 22);
   END;
   IF shift >= 16 THEN
     x := x * 1.0D16; DEC(shift, 16);
   END;
   IF shift >= 8 THEN
     x := x * 1.0D8; DEC(shift, 8);
   END;
   IF shift >= 4 THEN
     x := x * 1.0D4; DEC(shift, 4);
   END;
   IF shift >= 2 THEN
     x := x * 1.0D2; DEC(shift, 2);
   END;
   IF shift = 1 THEN
     x := x * 1.0D1;
   END;
 END;
 RETURN(x);
END scale;

(*---------------------------------------------------------------------------*)

PROCEDURE split* ((* EIN/ -- *)     val  : LONGREAL;
                  (* -- /AUS *) VAR neg  : BOOLEAN;
                  (* -- /AUS *) VAR norm : LONGREAL;
                  (* -- /AUS *) VAR exp  : INTEGER;
                  (* -- /AUS *) VAR form : SHORTINT ): BOOLEAN;

(* Spaltet <val> auf in das Vorzeichen (neg := val < 0.0), die normierte
   Mantisse im Bereich [1.0, 10.0) und den Exponenten zur Basis Zehn.
   Ausserdem wird in <form> das Format der internen Real-Darstellung
   von <val> geliefert. Falls <form> <= 'denorm', wird <val> als
   Null behandelt, falls <form> > 'normal', sind die Ausgabeparameter
   undefiniert, und es wird FALSE zurueckgeliefert.
 *)

VAR exp2 : INTEGER;

BEGIN
 IF ~checkLReal(val, form) THEN
   RETURN(FALSE);
 ELSIF form < normal THEN
   neg  := FALSE;
   norm := 0.0D0;
   exp  := 0;
   RETURN(TRUE);
 END;

 neg := val < 0.0D0;
 IF neg THEN
   val := -val;
 END;

 exp2 := LowLong.exponent(val);
 (* Zehnerexponent durch Zweierexponent annaehern:
    exp[10] = exp[2] * log10(2).
    19728.0 / 65536.0 ~ 0.30103 <=> log10(2).
  *)
 IF exp2 < 0 THEN
   exp2 := SHORT(-((-LONG(exp2) * 19728) DIV 65536));
 ELSE
   exp2 := SHORT((LONG(exp2) * 19728) DIV 65536);
 END;

 val := scale(val, -exp2);

 (* Jetzt exakt auf [1.0, 10.0) transformieren. Der Absolutwert des
    angenaeherten Zehnerexponenten kann hoechstens um Eins kleiner als
    der tatsaechliche Wert sein (Ganzzahlarithmetik - Rest fehlt, nicht
    beruecksichtigte Mantisse), aber nicht groesser.
  *)
 IF val >= 1.0D1 THEN
   val := val / 1.0D1; INC(exp2);
 ELSIF val < 1.0D0 THEN
   val := val * 1.0D1; DEC(exp2);
 END;
 norm := val;
 exp  := exp2;
 RETURN(TRUE);
END split;

(*---------------------------------------------------------------------------*)

PROCEDURE r2s ((* EIN/ -- *)     norm : LONGREAL;
               (* EIN/ -- *)     figs : INTEGER;
               (* EIN/AUS *) VAR str  : SigFigStr );

(* <norm> ist eine normierte Zahl im Bereich [1.0, 10.0). <str>
   muss vollstaendig mit '0' aufgefuellt sein und wird mit den
   ersten <figs> + 1 (Rundungsstelle) Ziffern von <norm> ueberschrieben.
 *)

BEGIN
 ASSEMBLER
; <norm> wird in eine Festkommazahl mit dem Dezimalkomma hinter dem
; obersten Byte umgewandelt. Der Wert der Vorkommastelle liegt
; zwischen 0 und 9.
; Die naechste Vorkommastelle wird jeweils durch Multiplikation
; (durch Addition ersetzt) des Nachkommateils mit 10 berechnet.

   MOVE.L  str,A0
   MOVE.W  figs,D4
   MOVEM.L norm,D0/D1

   MOVE.L  D0,D3        ; Exponent: 2^0 .. 2^3
   SWAP    D3           ;
   LSR.W   #4,D3        ;
   SUBI.W  #1023-4,D3   ; Shift: 4..7

   ANDI.L  #$000FFFFF,D0; Nur Mantissenbits
   BSET    #20,D0       ; implizite Eins

; Mantisse um Shift Bits nach links schieben, damit der Wert bzgl. des
; Dezimalkommas stimmt.

   LSL.L   D3,D0
   ROL.L   D3,D1

   SUBQ.W  #7,D3        ; Aus Shift eine Bitmaske berechnen
   NEG.W   D3           ;
   MOVEQ   #$7F,D2      ;
   LSR.W   D3,D2        ;

   MOVE.W  D2,D3        ;
   AND.B   D1,D2        ;
   OR.B    D2,D0        ;
   NOT.W   D3           ;
   AND.B   D3,D1        ;

convlp:
   MOVE.L  D1,D2        ; Mantisse = Null -> weitere Berechnung ueberfluessig
   OR.L    D0,D2        ;
   BEQ.B   end          ;

   ROL.L   #8,D0        ; Vorkommastelle rausziehen
   MOVE.B  D0,D2        ;
   LSR.L   #8,D0        ;
   ADDI.B  #'0',D2      ;
   MOVE.B  D2,(A0)+     ;

   ADD.L   D1,D1        ; Mantisse (Nachkommastellen) * 10
   ADDX.L  D0,D0        ;
   MOVE.L  D1,D3        ;
   MOVE.L  D0,D2        ;
   ADD.L   D1,D1        ;
   ADDX.L  D0,D0        ;
   ADD.L   D1,D1        ;
   ADDX.L  D0,D0        ;
   ADD.L   D3,D1        ;
   ADDX.L  D2,D0        ;
   DBRA    D4,convlp
end:
 END;
END r2s;

(*---------------------------------------------------------------------------*)

PROCEDURE mantToStr* ((* EIN/ -- *)     norm : LONGREAL;
                      (* EIN/ -- *)     fix  : BOOLEAN;
                      (* EIN/ -- *)     figs : INTEGER;
                      (* EIN/ -- *)     long : BOOLEAN;
                      (* EIN/AUS *) VAR exp  : INTEGER;
                      (* -- /AUS *) VAR digs : INTEGER;
                      (* -- /AUS *) VAR mant : SigFigStr );

(* Die Prozedur konvertiert eine reelle Zahl in eine bestimmte Anzahl
   von signifikanten Stellen als String in <mant>.

   <norm> ist eine (positive) normalisierte Mantisse im Bereich [1.0, 10.0)
   und <exp> der zugehoerige Exponent zur Basis Zehn, mit dem <norm>
   multipliziert werden muesste, um den eigentlichen Wert zu erhalten.

   <fix> = TRUE: <figs> bezeichnet die Anzahl der Stellen relativ zum
   Dezimalpunkt des eigtl. Wertes. Aus <exp> und <figs> wird die Anzahl
   der signifikanten Stellen berechnet; falls der resultierende Wert
   kleiner als Null ist, wird <digs> auf Null gesetzt, und <mant>
   enthaelt nur Nullen; falls der Wert gleich Null ist, wird <digs> auf
   Eins gesetzt und eine Stelle berechnet, die zur Rundung benutzt wird,
   um als erste Ziffer eine Null oder Eins zu erhalten.

   <fix> = FALSE: <figs> bezeichnet direkt die Anzahl der signifikanten
   Stellen (<figs> = 0  ==>  <figs> := DEFSIGFIGS).

   <digs> wird die Anzahl der signifikanten Stellen zugewiesen, die auf
   max. MAXLSIGFIGS Stellen begrenzt wird, wenn <long> TRUE ist, sonst
   auf MAXSSIGFIGS Stellen.

   Es werden <digs> + 1 Stellen zu einem String konvertiert und anschliessend
   wird auf <digs> Stellen gerundet und die Rundungsstelle auf '0' gesetzt.
   Falls beim Runden ein Ueberlauf auftritt, ist <mant> gleich "10000....",
   und <exp> wird um Eins erhoeht.

   Es wird mit '0' auf MAXLSIGFIGS + 1 Stellen aufgefuellt, falls die
   Anzahl der signifikanten Stellen geringer ist, so dass <mant> zum
   Schluss eine auf <digs> Stellen gerundete Darstellung von <norm>
   mit MAXLSIGFIGS + 1 Ziffern enthaelt.
 *)
VAR i : INTEGER;

BEGIN
 (* LEN(mant) - 1 = MAXLSIGFIGS + 1 '0'-en *)
 mant := "00000000000000000";

 IF norm = 0.0D0 THEN
   digs := 1;
   RETURN;
 END;

 IF fix THEN
   IF figs >= 0 THEN
     INC(figs, exp + 1);
   ELSE
     INC(figs, exp + 2);
   END;
 ELSIF figs = 0 THEN
   figs := DEFSIGFIGS;
 END;

 IF figs <= 0 THEN
   (* Kann nur bei Fixpunktdarstellung auftreten *)
   IF figs < 0 THEN
     (* Es gibt keine signifikanten Stellen, es muss nur ggf.
      * mit Nullen aufgefuellt werden.
      *)
     digs := 0;
     exp  := 0;
   ELSE (* figs = 0 *)
     (* Die einzige signifikante Stelle wird durch Rundung der
      * naechstkleineren Stelle zu Null oder Eins berechnet;
      *)
     IF norm >= 5.0D0 THEN
       mant[0] := '1';
       INC(exp);
     ELSE
       exp := 0;
     END;
     digs := 1;
   END;
   RETURN;
 END;

 (* Maximal sinnvoll zu berechnende Anzahl von Digits, der Rest wird
  * spaeter durch Nullen aufgefuellt.
  *)
 IF long & (figs > MAXLSIGFIGS) THEN
   figs := MAXLSIGFIGS;
 ELSIF ~long & (figs > MAXSSIGFIGS) THEN
   figs := MAXSSIGFIGS;
 END;
 digs := figs;

 r2s(norm, figs, mant);

 (* Rundung auf 'figs' Stellen *)
 IF mant[figs] >= '5' THEN
   i := figs - 1;
   WHILE (i >= 0) & (mant[i] = '9')  DO
     mant[i] := '0';
     DEC(i);
   END;
   IF i >= 0 THEN
     mant[i] := CHR(ORD(mant[i]) + 1);
   ELSE
     mant[0] := '1';
     INC(exp);
   END;
 END;
 mant[figs] := '0';
END mantToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE fixLen* ((* EIN/ -- *) neg    : BOOLEAN;
                   (* EIN/ -- *) exp    : INTEGER;
                   (* EIN/ -- *) places : INTEGER ): INTEGER;

(* Berechnet aus dem Vorzeichen <neg> und dem Dezimalexponenten einer
   Zahl die Anzahl von Zeichen, die fuer eine Repraesentation im
   Fixpunktformat durch "FixedToStr()" benoetigt werden. <places>
   bezeichnet dabei die Anzahl der bzgl. des Dezimalpunktes gerundeten
   Stellen.
   Es wird vorausgesetzt, dass evtl. Rundungskorrekturen bereits erfolgt
   sind.
 *)

VAR len : INTEGER;

BEGIN
 IF neg THEN
   len := 1; (* Minuszeichen *)
 ELSE
   len := 0; (* Kein Vorzeichen *)
 END;
 IF places < 0 THEN
   IF -places - 2 > exp THEN
     INC(len); (* Vorzeichen, Null *)
   ELSE
     INC(len, exp + 1);
     (* Vorzeichen, <exp>+1 Vorkommastellen *)
   END;
 ELSIF exp >= 0 THEN (* places >= 0 *)
   INC(len, exp + 2 + places);
   (* Vorzeichen, <exp>+1 Vorkommastellen, Dezimalpunkt, <places> Nachkommastellen *)
 ELSE (* exp < 0, places >= 0 *)
   INC(len, 2 + places);
   (* Vorzeichen, Vorkommanull, Dezimalpunkt, <places> Nachkommastellen *)
 END;
 RETURN(len);
END fixLen;

(*---------------------------------------------------------------------------*)

PROCEDURE FixLength* ((* EIN/ -- *) val    : LONGREAL;
                      (* EIN/ -- *) long   : BOOLEAN;
                      (* EIN/ -- *) places : INTEGER ): INTEGER;

(* Beruecksichtigt im Gegensatz zu "fixLen()" Rundung, ist aber
   langsamer.
 *)

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    digs : INTEGER;
    mant : SigFigStr;
    form : SHORTINT;
    len  : INTEGER;

BEGIN
 IF ~split(val, neg, val, exp, form) THEN
   RETURN(formLen(form));
 END;

 IF exp >= 0 THEN
   (* Nur bei Vorkommastellen Aenderung der Stellenzahl moeglich *)
   IF neg THEN
     len := 1; (* Minuszeichen *)
   ELSE
     len := 0; (* Kein Vorzeichen *)
   END;

   IF places < -exp - 2 THEN
     RETURN(len + 1); (* Vorzeichen, Null *)
   ELSIF places = -exp - 2 THEN
     IF val < 5.0D0 THEN
       RETURN(len + 1); (* Vorzeichen, Null *)
     ELSE
       RETURN(len + exp + 2);
       (* Vorzeichen, <exp>+2 Vorkommastellen (aufgerundet) *)
     END;
   ELSIF val >= 9.0D0 THEN (* places > -exp - 2 *)
     mantToStr(val, TRUE, places, long, exp, digs, mant);
   END;
 END;
 RETURN(fixLen(neg, exp, places));
END FixLength;

(*---------------------------------------------------------------------------*)

PROCEDURE adjustEng* ((* EIN/AUS *) VAR exp : INTEGER;
                      (* -- /AUS *) VAR pre : INTEGER );

(* Berechnet aus dem Dezimalexponenten <exp> die Anzahl der Vorkommastellen
   und den entsprechend nach unten korrigierten Exponenten fuer
   die technische Gleitpunktdarstellung.
 *)

BEGIN
 IF exp < 0 THEN
   pre := 2 - (-exp - 1) MOD 3;
 ELSE
   pre := exp MOD 3;
 END;
 DEC(exp, pre);
 INC(pre);
END adjustEng;

(*---------------------------------------------------------------------------*)

PROCEDURE expLen* ((* EIN/ -- *) exp : INTEGER ): INTEGER;

(* Liefert die Laenge der Stringdarstellung des Exponenten <exp>. *)

BEGIN
 exp := ABS(exp);
 IF exp = 0 THEN
   RETURN(0); (* Kein Exponent *)
 ELSIF exp >= 100 THEN
   RETURN(5); (* E, Vorzeichen, drei Stellen *)
 ELSIF exp >= 10 THEN
   RETURN(4); (* E, Vorzeichen, zwei Stellen *)
 ELSE
   RETURN(3); (* E, Vorzeichen, eine Stelle *)
 END;
END expLen;

(*---------------------------------------------------------------------------*)

PROCEDURE floatLen* ((* EIN/ -- *) neg  : BOOLEAN;
                     (* EIN/ -- *) eng  : BOOLEAN;
                     (* EIN/ -- *) exp  : INTEGER;
                     (* EIN/ -- *) figs : INTEGER ): INTEGER;

(* Berechnet aus dem Vorzeichen <neg> und dem Dezimalexponenten einer
   Zahl die Anzahl von Zeichen, die fuer eine Repraesentation im
   Gleitpunktformat durch "FloatToStr()" (<eng> = FALSE) bzw. "EngToStr()"
   (<eng> = TRUE) benoetigt werden. <figs> bezeichnet die Anzahl der
   signifikanten Stellen, falls <figs> <= 0, wird DEFSIGFIGS eingesetzt.
   Es wird vorausgesetzt, dass evtl. Rundungskorrekturen bereits erfolgt
   sind.
 *)

VAR len : INTEGER;
    pre : INTEGER;

BEGIN
 IF figs <= 0 THEN
   figs := DEFSIGFIGS;
 END;

 IF eng THEN
   adjustEng(exp, pre);
 ELSE
   pre := 1; (* Eine Vorkommastelle *)
 END;

 IF neg THEN
   len := 1; (* Minuszeichen *)
 ELSE
   len := 0; (* Kein Vorzeichen *)
 END;

 IF figs <= pre THEN
   INC(len, pre); (* <pre> Vorkommastellen, kein Dezimalpunkt *)
 ELSE
   INC(len, figs + 1); (* <figs> Stellen, Dezimalpunkt *)
 END;
 RETURN(len + expLen(exp));
END floatLen;

(*---------------------------------------------------------------------------*)

PROCEDURE FloatLength* ((* EIN/ -- *) val  : LONGREAL;
                        (* EIN/ -- *) eng  : BOOLEAN;
                        (* EIN/ -- *) long : BOOLEAN;
                        (* EIN/ -- *) figs : INTEGER ): INTEGER;

(* Beruecksichtigt im Gegensatz zu "floatLen()" Rundung, ist aber
   langsamer.
 *)

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    digs : INTEGER;
    mant : SigFigStr;
    form : SHORTINT;

BEGIN
 IF figs <= 0 THEN
   figs := DEFSIGFIGS;
 END;
 IF ~split(val, neg, val, exp, form) THEN
   RETURN(formLen(form));
 END;
 IF (val >= 9.0D0) & ((exp = 0) OR (exp = -1) OR eng) THEN
   (* Eine Aenderung der Stellenzahl durch (Auf)Rundung kann nur eintreten,
    * wenn die erste Ziffer eine 9 ist.
    * Bei wissenschaftlicher Darstellung kann sie ausserdem nur auftreten,
    * wenn der Exponent entweder verschwindet, weil er zu Null aufgerundet
    * wurde, oder wenn er erst durch die Rundung auftritt (vorher Null).
    * Bei technischer Darstellung kann sich die Zahl der Vorkommastellen bei
    * jeder Aufrundung aendern.
    *)
   mantToStr(val, FALSE, figs, long, exp, digs, mant);
 END;
 RETURN(floatLen(neg, eng, exp, figs));
END FloatLength;

(*---------------------------------------------------------------------------*)

PROCEDURE expToStr* ((* EIN/ -- *)     exp   : INTEGER;
                     (* -- /AUS *) VAR estr  : ExpStr;
                     (* -- /AUS *) VAR start : INTEGER );

(* Konvertiert den Wert <exp> zu einer Stringrepraesentation des
   Exponenten in der Form: 'E','-'|'+',digit,{digit}. Die Repraesentation
   beginnt bei <estr[start]> und endet mit dem Ende von <estr>, also
   <estr[MAXEXPFIGS]>.
 *)

VAR neg  : BOOLEAN;
    eidx : INTEGER;

BEGIN
 neg := exp < 0;
 IF neg THEN
   exp := -exp;
 END;
 estr[MAXEXPFIGS+1] := 0X;
 eidx := MAXEXPFIGS;
 REPEAT
   estr[eidx] := CHR(exp MOD 10 + ORD('0'));
   exp        := exp DIV 10;
   DEC(eidx);
 UNTIL exp = 0;
 IF neg THEN
   estr[eidx] := '-';
 ELSE
   estr[eidx] := '+';
 END;
 DEC(eidx);

 estr[eidx] := 'E';
 start      := eidx;
END expToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE floatToStr* ((* EIN/ -- *)     neg  : BOOLEAN;
                       (* EIN/ -- *)     norm : LONGREAL;
                       (* EIN/ -- *)     exp  : INTEGER;
                       (* EIN/ -- *)     eng  : BOOLEAN;
                       (* EIN/ -- *)     figs : INTEGER;
                       (* EIN/ -- *)     long : BOOLEAN;
                       (* -- /AUS *) VAR str  : ARRAY OF CHAR );
(* Aufruf:
 IF split(real, neg, norm, exp, form) THEN
   floatToStr(neg, norm, exp, FALSE/TRUE, figs, FALSE/TRUE, str);
 ELSE
   formToStr(form, str);
 END;
*)

VAR estr : ExpStr;
    pre  : INTEGER;
    sidx : INTEGER;
    midx : INTEGER;
    mant : SigFigStr;
    digs : INTEGER;

BEGIN
 IF figs <= 0 THEN
   figs := DEFSIGFIGS;
 END;
 mantToStr(norm, FALSE, figs, long, exp, digs, mant);

 (* Optionales Vorzeichen schreiben *)
 IF neg THEN
   str[0] := '-';
   sidx   := 1;
 ELSE
   sidx   := 0;
 END;

 (* Vorkommastellen schreiben *)
 IF eng THEN
   adjustEng(exp, pre);
 ELSE
   pre := 1;
 END;
 midx := 0;
 WHILE (sidx < LEN(str)-1) & (midx < pre) DO
   str[sidx] := mant[midx];
   INC(sidx);
   INC(midx);
 END;

 (* Optionalen Dezimalpunkt mit Nachkommastellen schreiben *)
 IF (figs > pre) & (sidx < LEN(str)-1) THEN
   str[sidx] := '.';
   INC(sidx);
   WHILE (sidx < LEN(str)-1) & (midx < digs) DO
     str[sidx] := mant[midx];
     INC(sidx);
     INC(midx);
   END;
   WHILE (sidx < LEN(str)-1) & (digs < figs) DO
     str[sidx] := '0';
     INC(sidx);
     INC(digs);
   END;
 END;

 (* Optionalen Exponenten schreiben *)
 IF exp # 0 THEN
   expToStr(exp, estr, pre);
   WHILE (sidx < LEN(str)-1) & (pre <= MAXEXPFIGS)  DO
     str[sidx] := estr[pre];
     INC(sidx);
     INC(pre);
   END;
 END;
 str[sidx] := 0X;
END floatToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE floatToStrETH* ((* EIN/ -- *)     neg  : BOOLEAN;
                          (* EIN/ -- *)     norm : LONGREAL;
                          (* EIN/ -- *)     exp  : INTEGER;
                          (* EIN/ -- *)     long : BOOLEAN;
                          (* -- /AUS *) VAR str  : ARRAY OF CHAR );
(* Aufruf:
 IF split(real, neg, norm, exp, form) THEN
   floatToStrETH(neg, norm, exp, FALSE/TRUE, str);
 ELSE
   formToStr(form, str);
 END;
*)

VAR tidx : INTEGER;
    midx : INTEGER;
    mant : SigFigStr;
    digs : INTEGER;
    tmp  : ARRAY 30 OF CHAR;

BEGIN
 mantToStr(norm, FALSE, MAXLSIGFIGS, long, exp, digs, mant);

 (* Ueberfluessige Nullen am Ende eliminieren, aber mind. zwei Stellen *)
 IF digs < 2 THEN
   digs := 1;
 ELSE
   DEC(digs);
   WHILE (digs >= 2) & (mant[digs] = '0') DO
     DEC(digs);
   END;
 END;

 (* Optionales Vorzeichen *)
 IF neg THEN
   tmp[0] := '-';
   tidx   := 1;
 ELSE
   tidx   := 0;
 END;

 (* Vorkommastelle *)
 tmp[tidx]   := mant[0];
 tmp[tidx+1] := '.';
 INC(tidx, 2);

 (* Nachkommastellen *)
 FOR midx := 1 TO digs DO
   tmp[tidx] := mant[midx];
   INC(tidx);
 END;

 (* Exponent *)
 tmp[tidx] := 'E'; INC(tidx);
 IF exp < 0 THEN
   exp := -exp;
   tmp[tidx] := '-';
 ELSE
   tmp[tidx] := '+';
 END;
 INC(tidx);
 IF long THEN
   tmp[tidx] := CHR(exp DIV 100 + ORD('0')); INC(tidx);
 END;
 tmp[tidx] := CHR((exp DIV 10) MOD 10 + ORD('0')); INC(tidx);
 tmp[tidx] := CHR(exp MOD 10 + ORD('0')); INC(tidx);
 tmp[tidx] := 0X;
 COPY(tmp, str);
END floatToStrETH;

(*---------------------------------------------------------------------------*)

PROCEDURE fixToStr* ((* EIN/ -- *)     neg    : BOOLEAN;
                     (* EIN/ -- *)     norm   : LONGREAL;
                     (* EIN/ -- *)     exp    : INTEGER;
                     (* EIN/ -- *)     places : INTEGER;
                     (* EIN/ -- *)     long   : BOOLEAN;
                     (* -- /AUS *) VAR str    : ARRAY OF CHAR );
(* Aufruf:
 IF split(real, neg, norm, exp, form) THEN
   fixToStr(neg, norm, exp, places, FALSE/TRUE, str);
 ELSE
   formToStr(form, str);
 END;
*)

VAR sidx : INTEGER;
    midx : INTEGER;
    mant : SigFigStr;
    digs : INTEGER;

BEGIN
 mantToStr(norm, TRUE, places, long, exp, digs, mant);

 (* Optionales Vorzeichen schreiben *)
 IF neg THEN
   str[0] := '-';
   sidx   := 1;
 ELSE
   sidx   := 0;
 END;

 midx := 0;
 IF exp < 0 THEN
(* [-]0.[000]xxxxx[000] *)
   IF sidx < LEN(str)-1 THEN
     str[sidx] := '0';
     INC(sidx);
     IF (places >= 0) & (sidx < LEN(str)-1) THEN
       str[sidx] := '.';
       INC(sidx);
       exp := -exp - 1;
       DEC(places, exp + digs);
       WHILE (sidx < LEN(str)-1) & (exp > 0) DO
         str[sidx] := '0';
         INC(sidx);
         DEC(exp);
       END;
       WHILE (sidx < LEN(str)-1) & (midx < digs) DO
         str[sidx] := mant[midx];
         INC(sidx);
         INC(midx);
       END;
       WHILE (sidx < LEN(str)-1) & (places > 0) DO
         str[sidx] := '0';
         INC(sidx);
         DEC(places);
       END;
     END;
   END;
 ELSE (* exp >= 0 *)
   IF places < 0 THEN
(* [-]xxx[000] *)
     WHILE (sidx < LEN(str)-1) & (midx < digs) DO
       str[sidx] := mant[midx];
       INC(sidx);
       INC(midx);
     END;
     DEC(exp, digs);
     WHILE (sidx < LEN(str)-1) & (exp >= 0) DO
       str[sidx] := '0';
       INC(sidx);
       DEC(exp);
     END;
   ELSE (* places >= 0, exp >= 0 *)
     IF exp + 1 >= digs THEN
(* [-]xxx[000[.[000]]] *)
       WHILE (sidx < LEN(str)-1) & (midx < digs) DO
         str[sidx] := mant[midx];
         INC(sidx);
         INC(midx);
       END;
       DEC(exp, digs);
       WHILE (sidx < LEN(str)-1) & (exp >= 0) DO
         str[sidx] := '0';
         INC(sidx);
         DEC(exp);
       END;
       IF sidx < LEN(str)-1 THEN
         str[sidx] := '.';
         INC(sidx);
         WHILE (sidx < LEN(str)-1) & (places > 0) DO
           str[sidx] := '0';
           INC(sidx);
           DEC(places);
         END;
       END;
     ELSE (* places >= 0, exp >= 0, exp < digs - 1 *)
(* [-]xxx.[xxx][000] *)
       WHILE (sidx < LEN(str)-1) & (midx <= exp) DO
         str[sidx] := mant[midx];
         INC(sidx);
         INC(midx);
       END;
       IF sidx < LEN(str)-1 THEN
         str[sidx] := '.';
         INC(sidx);
         exp := sidx;
         WHILE (sidx < LEN(str)-1) & (midx < digs) DO
           str[sidx] := mant[midx];
           INC(sidx);
           INC(midx);
         END;
         DEC(places, sidx - exp);
         WHILE (sidx < LEN(str)-1) & (places > 0) DO
           str[sidx] := '0';
           INC(sidx);
           DEC(places);
         END;
       END;
     END;
   END;
 END;
 str[sidx] := 0X;
END fixToStr;

(*---------------------------------------------------------------------------*)

PROCEDURE strToReal* ((* EIN/ -- *) VAR str    : ARRAY OF CHAR;
                      (* EIN/ -- *)     min    : LONGREAL;
                      (* EIN/ -- *)     minExp : INTEGER;
                      (* EIN/ -- *)     max    : LONGREAL;
                      (* EIN/ -- *)     maxExp : INTEGER;
                      (* -- /AUS *) VAR res    : SHORTINT ): LONGREAL;

VAR negMant  : BOOLEAN;
    ch       : CHAR;
    shift    : INTEGER;
    exp      : INTEGER;
    i        : INTEGER;
    sLen     : INTEGER;
    digits   : INTEGER;
    mant     : LONGREAL;
    maxTenth : LONGREAL;

 PROCEDURE LENGTH (VAR s : ARRAY OF CHAR): INTEGER;
 VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE s[i] # 0X DO
    INC(i);
  END;
  RETURN(i);
 END LENGTH;

PROCEDURE ParseSign ((* -- /AUS *) VAR neg : BOOLEAN ): BOOLEAN;
(* Ein optionales Vorzeichen wird ueberlesen und gemerkt.
 * Hinter dem Vorzeichen darf der String noch nicht zuende sein.
 *)
BEGIN
 neg := str[i] = '-';
 IF neg OR (str[i] = '+')  THEN
   INC(i);
   RETURN(i < sLen);
 ELSE
   RETURN(TRUE);
 END;
END ParseSign;

PROCEDURE ParseZeros;
(* Aufeinanderfolgende Nullen werden ueberlesen und mitgezaehlt *)
BEGIN
 WHILE (i < sLen) & (str[i] = '0') DO
   INC(i);
 END;
END ParseZeros;

PROCEDURE ParseDigits ((* EIN/AUS *) VAR mant : LONGREAL );
(* Ein optionaler Strom von Ziffern wird gelesen; die Ziffern werden
 * ihrer Wertigkeit entsprechend summiert, solange nicht die maximal
 * repraesentierbare Ziffernzahl ueberschritten wird (ansonsten wird
 * nur ueberlesen).
 *)
BEGIN
 WHILE (i < sLen) & ('0' <= str[i]) & (str[i] <= '9') DO
   IF digits <= MAXLSIGFIGS THEN
     mant := 1.0D1 * mant + (ORD(str[i]) - ORD('0'));
     INC(digits);
   END;
   INC(i);
 END;
END ParseDigits;

PROCEDURE ParseExponent ((* -- /AUS *) VAR exp : INTEGER ): BOOLEAN;
(* Ein optionaler Exponent wird gelesen und ausgewertet. Er darf ein
 * Vorzeichen haben und eine oder mehrere nachfolgende Ziffern.
 * Die Ziffern werden ihrer Wertigkeit entsprechend aufaddiert,
 * solange nicht der Maximalexponent ueberschritten wird; Zahlen,
 * die danach noch kommen, werden ueberlesen.
 *)
VAR negExp : BOOLEAN;
    e      : INTEGER;
    tmp    : INTEGER;

BEGIN
 e := 0;
 IF (i < sLen) & ((CAP(str[i]) = 'E') OR (CAP(str[i]) = 'D')) THEN
   INC(i);
   IF (i < sLen) & ParseSign(negExp) & ('0' <= str[i]) & (str[i] <= '9') THEN
     REPEAT
       IF e < MAXEXP THEN
         INC(e, e);
         tmp := e;
         INC(e, e);
         INC(e, e);
         INC(e, tmp);
         INC(e, ORD(str[i]) - ORD('0'));
       END;
       INC(i);
     UNTIL (i >= sLen) OR (str[i] < '0') OR (str[i] > '9');

     IF negExp THEN
       e := -e;
     END;
   ELSE
     exp := 0;
     RETURN(FALSE);
   END;
 END;
 exp := e;
 RETURN(TRUE);
END ParseExponent;

BEGIN (* strToReal *)
 sLen     := LENGTH(str);
 shift    := 0;
 digits   := 0;
 i        := 0;
 mant     := 0.0D0;
 maxTenth := max / 1.0D1;
 res      := ConvTypes.strWrongFormat;

 (* Fuehrende Leerzeichen ueberlesen *)
 WHILE (i < sLen) & (str[i] = ' ') DO
   INC(i);
 END;

 IF i >= sLen THEN
   (* String besteht nur aus Leerzeichen *)
   res := ConvTypes.strEmpty;
   RETURN(0.0D0);
 END;

 IF ~ParseSign(negMant) THEN
   (* Hinter einem Vorzeichen muss noch etwas folgen *)
   RETURN(0.0D0);
 END;

 ch := str[i];

 IF ('0' <= ch) & (ch <= '9') THEN
   (* Die Zahl beginnt mit Vorkommastellen. Zuerst werden fuehrende
    * Nullen einfach ueberlesen, da sie nichts zum Wert beitragen.
    * Dann folgen die echten Vorkommastellen, um deren Anzahl - 1
    * spaeter der Exponent korrigiert werden muss. Wenn ein
    * Dezimalpunkt existiert, muss zuerst geprueft werden, ob es
    * ueberhaupt gueltige (ungleich Null) Vorkommastellen gab;
    * wenn nicht, gibt die Anzahl der jetzt zu ueberlesenden, fuehrenden
    * Nachkommanullen die spaetere Exponentkorrektur an.
    * Ansonsten werden die optionalen echten Nachkommastellen, egal
    * ob Nullen oder nicht, verarbeitet.
    *)
   ParseZeros;
   shift := i;
   ParseDigits(mant);
   shift := i - shift - 1;

   IF i < sLen THEN
     IF str[i] = '.' THEN
       INC(i);
       IF shift < 0 THEN
         (* Keine Vorkommastellen ungleich Null *)
         shift := i;
         ParseZeros;
         DEC(shift, i + 1);
       END;
       ParseDigits(mant);
     END;
   END;
 ELSE
   (* Mit anderen Zeichen darf die Zahl nicht beginnen *)
   RETURN(0.0D0);
 END;

 IF ParseExponent(exp) & (i >= sLen) THEN
   (* Nach dem optionalen Exponenten muss der String beendet sein.
    * Je nach Entfernung der ersten zaehlenden Stelle vom Dezimalpunkt
    * muss der Exponent korrigiert werden.
    *)
   INC(exp, shift);

   (* Auf Ueberlauf testen. Entweder reicht der Exponent schon
    * aus, oder es wird bei einem Exponenten, der so gross ist wie der
    * maximale Exponent, mit einem Zehntel der Mantisse getestet, so dass
    * nicht schon beim Test das Malheur passiert.
    *)
   IF mant = 0.0D0 THEN
     res := ConvTypes.strAllRight;
   ELSIF (exp > maxExp)
      OR (exp = maxExp) & (scale(mant, exp - digits) > maxTenth)
   THEN
     res  := ConvTypes.strOutOfRange;
     mant := max;
   ELSE
     res  := ConvTypes.strAllRight;
     mant := scale(mant, exp - digits + 1);
   END;

   IF negMant THEN
     mant := -mant;
   END;
 END;
 RETURN(mant);
END strToReal;

END FConvBase.
