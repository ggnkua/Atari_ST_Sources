MODULE Math;

(*****************************************************************************)
(* Oakwood-compatible Math                                                   *)
(* --------------------------------------------------------------------------*)
(* Mathematische Funktionen fuer den Typ REAL.                               *)
(* Hinweise zur Implementierung finden sich in der Datei MATH_IMP.TXT.       *)
(* Die Approximationen sind auf IEEE single precision (> 7 Stellen           *)
(* Genauigkeit) ausgelegt.                                                   *)
(* --------------------------------------------------------------------------*)
(* 27-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHMEN:
   1) LowReal.radix = 2, d.h. LowReal.scale multipliziert mit bzw. dividiert
      durch Zweierpotenzen.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

IMPORT SYSTEM, Sys, Low:=LowReal, Support:=RealSupport;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  pi*  = 3.1415926535897932384626433832795028841972;
  e*   = 2.7182818284590452353602874713526624977572;

CONST
  pio2     = 1.57079632679489661923132169163975144;   (* pi/2 *)
  pio4     = 7.8539816339744830961566084581987572E-1; (* pi/4 *)
  pi2      = 6.28318530717958647692528676655900576;   (* 2*pi *)

  sqrt2    = 1.41421356237309504880168872420969808;   (* 2^(1/2) *)
  sqrt2o2  = 7.0710678118654752440084436210484904E-1; (* 2^(1/2)/2 *)

  ln2      = 6.9314718055994530941723212145817657E-1; (* logE(2)  *)
  lde      = 1.44269504088896340735992468100189213;   (* log2(e)  *)

  tan1pio8 = 4.1421356237309504880168872420969807E-1; (* tan(pi/8) *)
  tan3pio8 = 2.41421356237309504880168872420969807;   (* tan(3*pi/8) *)
  sinpio6  = 0.5;                                     (* sin(pi/6) *)


(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE trigon ((* EIN/ -- *)     x        : REAL;
                  (* EIN/ -- *)     sin      : BOOLEAN;
                  (* -- /AUS *) VAR quadrant : SHORTINT ) : REAL;

(*
 * -> Transformation des Argumentes auf [0, 2Pi]
 *
 *      sin/cos(x + k*2Pi) = sin/cos(x)
 *
 *      ([Hart68], 6.4.4, 6.4.5)
 *
 * -> Feststellen des Quadranten durch Vergleiche, Transformation auf
 *    [0, Pi/4] durch Subtraktionen
 *
 * -> Sinus   ist fuer [0, Pi/4] zustaendig
 *    Kosinus ist fuer [Pi/4, Pi/2] zustaendig
 *
 * -> 1. und 2. Glied der Reihenentwicklung von Sinus, Kosinus, falls
 *    x < 'SeriesExpSIN/COS'
 *
 *                   x^3
 *      sin(x) = x - ---  + Rest O(x^5)
 *                    6
 *
 *                   x^2
 *      cos(x) = 1 - ---  + Rest O(x^4)
 *                    2
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *
 *    sonst Approximation durch rationale Funktion
 *)
CONST SeriesExpSIN = 6.0E-2; (* = sqrt(sqrt(120.0*Eps)) *)
      SeriesExpCOS = 4.1E-2; (* = sqrt(sqrt(24.0*Eps))  *)

PROCEDURE SIN3060 ((* EIN/ -- *) x : REAL ): REAL;
(* 8.63 Stellen auf [0, Pi/4] *)
CONST P0 =  0.5281860134812E+2;
      P1 = -0.4644800481954E+1;
      P2 =  0.867545069521E-1;
      Q0 =  0.67250731777791E+2;

VAR xSqr : REAL;

BEGIN (* SIN3060 *)
 xSqr := x * x;

 RETURN(x *
         ((P2 * xSqr + P1) * xSqr + P0) /
         (                   xSqr + Q0)
        );
END SIN3060;

PROCEDURE COS3840 ((* EIN/ -- *) x : REAL ): REAL;
(* 7.54 Stellen auf [0, Pi/4] *)
CONST P0 =  0.4768729218663E+2;
      P1 = -0.1370800004765E+2;
      P2 =  0.447822343969E0;
      Q0 =  0.4768729082658E+2;

VAR xSqr : REAL;

BEGIN (* COS3840 *)
 xSqr := x * x;

 RETURN(((P2 * xSqr + P1) * xSqr + P0) /
        (                   xSqr + Q0)
        );
END COS3840;

BEGIN (* trigon *)
 quadrant := 0;
 IF x > pi2 THEN
   x := Support.fmod(x, pi2);
 END;
 IF x > pi THEN
   x := x - pi;
   quadrant := 2;
 END;
 IF x > pio2 THEN
   x   := x - pio2;
   sin := ~sin;
   INC(quadrant);
 END;
 IF x > pio4 THEN
   x   := pio2 - x;
   sin := ~sin;
 END;

 IF sin THEN
   IF x >= SeriesExpSIN THEN
     RETURN(SIN3060(x / pio4));
   ELSE
     RETURN(x - x * x * x / 6.0);
   END;
 ELSIF x >= SeriesExpCOS THEN
   RETURN(COS3840(x / pio4));
 ELSE
   RETURN(1.0 - Low.scale(x * x, -1));
 END;
END trigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *) x    : REAL;
                     (* EIN/ -- *) asin : BOOLEAN ): REAL;

(* Approximation fuer Arkussinus und Arkuskosinus
 *
 * -> Der Argumentbereich (Betrag) wird in zwei Bereiche geteilt:
 *
 *      1)   [0, sin(Pi/6)]
 *
 *      2)   (sin(Pi/6), sin(Pi/2)]
 *
 *      ([Hart68], TABLE 6.3)
 *
 *    Damit werden alle positive Werte von Null bis Eins durchlaufen
 *
 * -> Damit fuer beide Bereiche dieselbe Approximation verwendet werden
 *    kann, muessen die Bereiche auf das gleiche Intervall transformiert
 *    werden:
 *
 *      1)   Der erste Bereich bleibt und wird durch eine direkte
 *           Approximation berechnet, falls das Argument groesser
 *           gleich 'SeriesExpARCSIN' ist (Betrag); ansonsten wird das
 *           erste und zweite Glied der Reihenentwicklung nach Taylor
 *           genommen:
 *                             x^3
 *             arcsin(x) = x + ---  + Rest O(x^5)
 *                              6
 *
 *                         Pi       x^3
 *             arccos(x) = -- - x - ---  + Rest O(x^5)
 *                         2         6
 *
 *             ([Bron87], Tab. 1.1.3.2.)
 *
 *           Die Funktionen werden dann durch folgende Formeln
 *           berechnet:
 *
 *             arcsin(x) =  asinApprox(x)
 *
 *                         Pi
 *             arccos(x) = --  -  asinApprox(x)
 *                         2
 *
 *             ([Hart68], 6.5.9)
 *
 *      2)   Der zweite Bereich wird durch folgende Formel auf
 *           den Bereich
 *                         (sin(Pi/6), 0]
 *           transformiert:
 *                     ________
 *                    / 1 - |x|
 *             z := \/  -------
 *                        2
 *
 *             ([Hart68], 6.5.25)
 *
 *           Der Arkussinus wird dann nach folgender Formel berechnet:
 *
 *                                     Pi
 *             arcsin(x) = sign(x) * ( --  -  2 * asinApprox(z))
 *                                     2
 *
 *           Der Arkuskosinus wieder nach
 *
 *                          Pi
 *             arccos(x) =  --  -  arcsin(z)
 *                          2
 *
 * Da der Arkussinus/kosinus in der Naehe von |x| = 1 eine grosse Steigung
 * besitzt, machen sich Ungenauigkeiten im Argument, verstaerkt durch die
 * Subtraktion mit 1, also einer aehnlich grossen Zahl, unangenehm
 * bemerkbar.
 *)
CONST SeriesExpARCSIN = 3.5E-2; (* = sqrt(sqrt(40.0/3.0*Eps)) *)

VAR absX : REAL;
    neg  : BOOLEAN;

PROCEDURE ARCSN4693 ((* EIN/ -- *) x : REAL ): REAL;
(* 8.60 Stellen auf [ -sin(Pi/6), sin(Pi/6) ] *)
CONST P0 =  0.5603629044813127E+1;
      P1 = -0.46145309466645E+1;
      P2 =  0.49559947478731;
      Q0 =  0.5603629030606043E+1;
      Q1 = -0.554846659934668E+1;

VAR xSqr : REAL;

BEGIN (* ARCSN4693 *)
 xSqr := x * x;

 RETURN(x *
         ((P2 * xSqr + P1) * xSqr + P0) /
         ((     xSqr + Q1) * xSqr + Q0)
        );
END ARCSN4693;

BEGIN (* arcTrigon *)
 absX := ABS(x);
 neg  := x < 0.0;
 IF absX > 1.0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   IF asin THEN
     IF neg THEN
       RETURN(-pio2);
     ELSE
       RETURN(pio2);
     END;
   ELSE
     IF neg THEN
       RETURN(pi);
     ELSE
       RETURN(0.0);
     END;
   END;
 END;

 IF absX > sinpio6  THEN
   IF absX = 1.0 THEN
     x := 0.0;
   ELSE
     (* Je naeher <absX> an 1.0 liegt, desto mehr niederwertige Stellen
      * fehlen dem Argument an Genauigkeit, was durch die Differenz
      * dann leider sichtbar wird.
      *)
     x := Low.scale(ARCSN4693(sqrt(Low.scale(1.0 - absX, -1))), 1);
   END;
   IF asin THEN
     IF neg THEN
       RETURN(x - pio2);
     ELSE
       RETURN(pio2 - x);
     END;
   ELSE
     IF neg THEN
       RETURN(pi - x);
     ELSE
       RETURN(x);
     END;
   END;
 ELSE
   IF absX >= SeriesExpARCSIN THEN
     x := ARCSN4693(x);
   ELSE
     x := x + x * x * x / 6.0;
   END;
   IF asin THEN
     RETURN(x);
   ELSE
     RETURN(pio2 - x);
   END;
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation der nichtnegativen Wurzel von <x>.
   <x> muss groesser gleich Null sein.
 *)

(* Quadratwurzel
 *
 * -> Trennen von Mantisse 'm' und Exponent 'e' aus x = m * 2^e
 *
 *    Fuer geraden Exponenten gilt:
 *
 *      sqrt(x) = sqrt(m * 2^(2k)) = 2^k * sqrt(m),
 *
 *      mit: e = 2k; k = e / 2
 *
 *    Fuer ungeraden Exponenten gilt:
 *
 *      sqrt(x) = sqrt(m * 2^(2k + 1)) = 2^k * sqrt(2 * m),
 *
 *      mit: e = 2k + 1; k = (e - 1) / 2
 *
 *      Fuer ungerades positives 'e' wuerde auch e / 2 reichen, da
 *        (e - 1) / 2 = e / 2       , e >= 0,
 *      aber fuer ungerades negatives 'e' gilt
 *        (e - 1) / 2 = e / 2 - 1   , e < 0.
 *
 *      ([Hart68], 6.1.3)
 *
 *    Mit / ist der ISO-Teilungsoperator fuer ganze Zahlen gemeint;
 *    Nicht-ISO-Compiler benutzen dafuer DIV, der aber bei ISO-Compilern
 *    andere Werte fuer (ungerade) negative Zahlen liefert.
 *
 * -> initiale Approximation der Mantisse auf zwei Stellen Genauigkeit
 *    mit Polynom
 *
 *    Da die Approximation den gesamten Bereich vom kleinsten Wert von m
 *    bis zum groessten Wert von 2*m umfassen muss, wird die Mantisse
 *    auf den untersten Bereich des Approximationsintervalls transformiert,
 *    bevor sie evtl. mit Zwei multipliziert wird.
 *
 * -> zwei Iterationen der Mantisse nach Newton (``Heron`sche Formel''),
 *    da jede Iteration die Genauigkeit mindestens verdoppelt:
 *
 *                          f(y{n})
 *          y{n+1} = y{n} - --------    , f(y) = y^2 - x
 *                          f`(y{n})
 *
 *
 *                   1             x
 *     =>   y{n+1} = - * ( y{n} + ---- )
 *                   2            y{n}
 *
 *     ([Hart68], 6.1.5 - 6.1.7, TABLE 6.2)
 *
 *
 * Alternativ koennte der ungerade Exponent auch erst nach Berechnung der
 * Mantisse beruecksichtigt werden:
 *
 *    sqrt(x*2^(2k))   = sqrt(x) * 2^k
 *    sqrt(x*2^(2k+1)) = sqrt(x) * 2^k * 2^(sign(k)*1/2)
 *
 *  Vorteil: Es kann eine initiale Approximation fuer ein kleineres
 *           Intervall gewaehlt werden, was etwas Geschwindigkeit bringt,
 *           da sich der Grad des Polynoms um Eins verringert.
 * Nachteil: Durch die nachtraegliche Multiplikation mit einem "krummen"
 *           Wert kann sich die hohe Genauigkeit des Ergebnisses geringfuegig
 *           verschlechtern.
 *)
VAR e : INTEGER;
    i : SHORTINT;
    y : REAL;

PROCEDURE SQRT0071 ((* EIN/ -- *) x : REAL ): REAL;
(* 2.30 Stellen auf [0.25, 1] *)
CONST P0 =  0.2592768763E0;
      P1 =  0.1052021187E1;
      P2 = -0.3163221431E0;

BEGIN (* SQRT0071 *)
 RETURN((P2 * x + P1) * x + P0);
END SQRT0071;

BEGIN (* sqrt *)
 IF x <= 0.0 THEN
   IF x < 0.0 THEN
     (* <Definitionsbereich> *)
     HALT(Sys.REALERR);
     RETURN(0.0);
   END;
   RETURN(0.0);
 END;

 e := Low.exponent(x) + 2;
 x := Low.scale(Low.fraction(x), -2);

 (* 0.25 <= x < 0.5 *)

 IF ODD(e) THEN
   DEC(e);
   x := Low.scale(x, 1);
   (* 0.5 <= x < 1.0  *)
 END;
 (* 0.25 <= x < 1.0  *)

 y := SQRT0071(x);

 FOR i := 1 TO 2  DO
   (* 2 Iterationen: > 9 Stellen *)
   y := Low.scale(y + x / y, -1);
 END;

 IF e < 0 THEN
   e := -(-e DIV 2);
 ELSE
   e := e DIV 2;
 END;
 RETURN(Low.scale(y, e));
END sqrt;

(*---------------------------------------------------------------------------*)

PROCEDURE exp* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation der Potenzierung von <x> zur Eulerschen
   Konstanten e.
 *)

(* Potenz zur Basis Zwei
 *
 * -> Aufspaltung in ganzzahligen Anteil 'n' und gebrochenen Anteil 'f'
 *
 * -> Approximation des gebrochenen Anteils mit rationaler Funktion
 *
 * -> Zusammenbau des Ergebnisses nach:
 *
 *    2^x = 2^(n+f)
 *        = 2^n * 2^f                              ; 0  <= |f| <= 0.5
 *        = 2^n * 2^(f-sign(f)/2) * 2^(sign(f)/2)  ; 0.5 < |f| < 1
 *
 *    ([Hart68], 6.2.32 - 6.2.34)
 *
 * Da die Potenzfunktion fuer Argumente x > 1 eine grosse Steigung besitzt,
 * machen sich die Ungenauigkeiten grosser Argumente im Ergebnis umso
 * staerker bemerkbar. Wegen b^(-x) = 1/b^x gilt dies auch fuer |x| > 1.
 *)
VAR korr   : BOOLEAN;
    factor : REAL;
    f      : REAL;
    n      : INTEGER;

PROCEDURE EXPB1063 ((* EIN/ -- *) x : REAL ): REAL;
(* 10.03 Stellen auf [ -1/2, 1/2 ] *)
CONST P0 = 0.72152891511493E+1;
      P1 = 0.576900723731E-1;
      Q0 = 0.208189237930062E+2;

VAR xSqr, Px, Qx : REAL;

BEGIN (* EXPB1063 *)
 xSqr := x * x;
 Px   := x * (xSqr * P1 + P0);
 Qx   :=      xSqr      + Q0;

 RETURN((Qx + Px) / (Qx - Px));
END EXPB1063;

BEGIN (* exp *)
 IF x = 0.0 THEN
   RETURN(1.0);
 END;

 x := x * lde;
 f := Low.fractpart(x);
 n := SHORT(SYSTEM.TRUNC(x));

 korr := TRUE;
 IF f > 0.5 THEN
   f      := f - 0.5;
   factor := sqrt2;
 ELSIF f < -0.5 THEN
   f      := f + 0.5;
   factor := sqrt2o2;
 ELSE
   korr := FALSE;
 END;

 x := EXPB1063(f);

 IF korr THEN
   x := x * factor;
 END;
 RETURN(Low.scale(x, n));
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des natuerlichen Logarithmus von <x>.
   <x> muss groesser Null sein.
 *)

(* Logarithmus zur Basis E
 *
 * -> Aufspaltung in Mantisse 'x' und Exponent 'k'
 *
 * -> Approximation der Mantisse mit rationaler Funktion
 *
 * -> Zusammenbau des Ergebnisses nach:
 *
 *      ln(x*2^k) = ln(x) + k*ln(2)
 *
 *      ([Hart68], 4.2.6, 6.3.27)
 *)
VAR k : INTEGER;

PROCEDURE LOGE2701 ((* EIN/ -- *) x : REAL ): REAL;
(* 8.48 Stellen auf [ 1/sqrt(2), sqrt(2) ] *)
CONST P0 = -0.331355617479E+1;
      P1 =  0.89554061525;
      Q0 = -0.165677797691E+1;

VAR xSqr : REAL;

BEGIN (* LOGE2701 *)
 x    := (x - 1.0) / (x + 1.0);
 xSqr := x * x;

 RETURN(x *
         (P1 * xSqr + P0) /
         (     xSqr + Q0)
        );
END LOGE2701;

BEGIN (* ln *)
 IF x <= 0.0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(-Low.large);
 ELSIF x = 1.0 THEN
   RETURN(0.0);
 END;

 k := Low.exponent(x);
 x := Low.fraction(x);

 IF x > sqrt2 THEN
   x := Low.scale(x, -1);
   INC(k); (* damit Produkt x*2^k gleich bleibt *)
 END;

 RETURN(k * ln2 + LOGE2701(x));
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE power* ((* EIN/ -- *) x    : REAL;
                  (* EIN/ -- *) base : REAL ): REAL;

(* Liefert eine Approximation der Potenzierung von <x> zur Basis <base>.
   Falls <base> kleiner Null ist, muss <x> eine ganze Zahl sein.
   Falls <base> gleich Null ist, muss <x> groesser Null sein.
 *)

VAR neg   : BOOLEAN;
    whole : REAL;

BEGIN
 neg := FALSE;
 IF base <= 0.0 THEN
   IF base < 0.0 THEN
     IF Support.modf(x, whole) # 0.0 THEN
       (* <Definitionsbereich> : -base^x, x nicht ganzzahlig *)
       HALT(Sys.REALERR);
       RETURN(0.0);
     ELSE
       base := -base;
       neg  := ODD(SYSTEM.TRUNC(whole));
     END;
   ELSIF x <= 0.0 THEN
     (* <Definitionsbereich> : 0^0 oder 0^(-x) *)
     HALT(Sys.REALERR);
     RETURN(0.0);
   ELSE (* 0^exp *)
     RETURN(0.0);
   END;
 END;
 base := exp(x * ln(base));
 IF neg THEN
   RETURN(-base);
 ELSE
   RETURN(base);
 END;
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE log* ((* EIN/ -- *) x    : REAL;
                (* EIN/ -- *) base : REAL ): REAL;

(* Liefert eine Approximation des Logarithmus von <x> zur Basis <base>.
   <x> und <base> muessen groesser Null sein.
 *)

(* [Hart68], 6.3.3 *)
BEGIN
 IF base <= 0.0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(0.0);
 END;
 IF x <= 0.0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(-Low.large);
 ELSIF x = 1.0 THEN
   RETURN(0.0);
 END;
 RETURN(ln(x) / ln(base));
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE round* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert den ganzzahligen Wert, der am naechsten an <x> liegt. Falls
   <x> genau zwischen zwei ganzzahligen Werten liegt, wird zur naechsten
   geraden Zahl gerundet.
 *)

VAR e : INTEGER;

BEGIN
 e := Low.exponent(x) + 1;

 IF e < 0 THEN
   RETURN(0.0);
 ELSIF e = 0 THEN
   IF x < -0.5 THEN
     RETURN(-1.0);
   ELSIF x > 0.5 THEN
     RETURN(1.0);
   ELSE
     RETURN(0.0);
   END;
 END;

 RETURN(Low.round(x, e));
END round;

(*---------------------------------------------------------------------------*)

PROCEDURE sin* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Sinus von <x>. *)

VAR neg      : BOOLEAN;
    quadrant : SHORTINT;

BEGIN
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 x := trigon(x, TRUE, quadrant);

 IF quadrant >= 2 THEN
   neg := ~neg;
 END;
 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END sin;

(*---------------------------------------------------------------------------*)

PROCEDURE cos* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Kosinus von <x>. *)

(* Extra Approximation statt sin(x + pi/2), damit die Genauigkeit
 * bei kleinen Argumenten erhalten bleibt.
 *)

VAR quadrant : SHORTINT;

BEGIN
 x := trigon(ABS(x), FALSE, quadrant);

 IF (quadrant > 0) & (quadrant < 3) THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END cos;

(*---------------------------------------------------------------------------*)

PROCEDURE tan* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Tangens von <x>.
   <x> darf kein ungerades Vielfachen von Pi/2 sein.
 *)

(* Extra Berechnung des Tangens statt sin(x)/cos(x) wegen Geschwindigkeit
 *
 * -> Transformation des Argumentes auf [0, Pi]
 *
 *      tan(-x) = -tan(x)
 *      tan(x+k*Pi) = tan(x)
 *
 *      ([Hart68], 6.4.6)
 *
 * -> Feststellen des Quadranten durch Vergleiche, Transformation auf
 *    [0, Pi/4] durch Subtraktionen
 *
 *                      Pi                       Pi
 *      tan(x) = 1/tan( --  - x )    , falls x > --
 *                      2                        4
 *
 *      ([Hart68], 6.4.6)
 *
 * -> 1.& 2. Glied der Reihenentwicklung von Tangens, falls x < 'SeriesExpTAN'
 *
 *                   x^3
 *      tan(x) = x + --- + Rest O(x^5)
 *                    3
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *
 *    sonst Approximation durch rationale Funktion
 *
 * -> Vorzeichen entsprechend Quadranten
 *)
CONST SeriesExpTAN = 3.0E-2; (* = sqrt(sqrt(7.5*Eps)) *)

VAR neg : BOOLEAN;

PROCEDURE TAN4282 ((* EIN/ -- *) x : REAL ): REAL;
(* 7.85 Stellen auf [ 0, Pi/4 ] *)
CONST P0 =  0.21242445758263E+3;
      P1 = -0.1255329742424E+2;
      Q0 =  0.27046722349399E+3;
      Q1 = -0.7159606050466E+2;

VAR xSqr : REAL;

BEGIN (* TAN4282 *)
 xSqr := x * x;

 RETURN(x *
         (        P1  * xSqr + P0) /
         ((xSqr + Q1) * xSqr + Q0)
        );
END TAN4282;

BEGIN (* tan *)
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x > pi THEN
   x := Support.fmod(x, pi);
 END;
 IF x > pio2 THEN
   x   := pi - x;
   neg := ~neg;
 END;
 IF x > pio4 THEN
   x := (pio2 - x) / pio4;
   IF x = 0.0 THEN
     (* <Polstelle> *)
     (* Da sich <x> und 'pio2' um minimal E-8 unterscheiden
      * koennen, kann es nicht zu einem Ueberlauf kommen, weil
      * <x> lediglich zu nahe an Pi/2 ist.
      *)
     HALT(Sys.REALERR);
     IF neg THEN
       RETURN(-Low.large);
     ELSE
       RETURN(Low.large);
     END;
   ELSE
     x := 1.0 / TAN4282(x);
   END;
 ELSIF x >= SeriesExpTAN  THEN
   x := TAN4282(x / pio4);
 ELSE
   x := x + x * x * x / 3.0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Arcussinus von <x>.
   Der Wertebereich ist: (-pi/2, pi/2].
   |<x>| muss kleiner gleich Eins sein.
 *)

BEGIN
 RETURN(arcTrigon(x, TRUE));
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Arcuskosinus von <x>.
   Der Wertebereich ist: [0, pi].
   |<x>| muss kleiner gleich Eins sein.
 *)

BEGIN
 RETURN(arcTrigon(x, FALSE));
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Arcustangens von <x>.
   Der Wertebereich ist: (-pi/2, pi/2].
 *)

(* Berechnung des Arcustangens
 *
 * -> negative Argumente beruecksichtigen
 *
 *      arctan(-x) = -arctan(x)
 *
 *      ([Hart68], 6.5.21)
 *
 * -> Der positive Argumentbereich wird in drei Teile geteilt:
 *
 *      1)   [0, tan(Pi/8)]
 *
 *      2)   (tan(Pi/8), tan(3*Pi/8))
 *
 *      3)   [tan(3*Pi/8), tan(Pi/2))
 *
 *    Hiermit werden alle positiven Werte durchlaufen
 *
 * -> Damit fuer alle drei Bereiche dieselbe Approximation verwendet
 *    werden kann, muessen die verschiedenen Bereiche auf das gleiche
 *    Intervall transformiert werden (wegen Symmetrie auch negativ):
 *
 *      1)   der erste Bereich bleibt und wird durch direkte
 *           Approximation berechnet, falls das Argument groesser
 *           gleich 'SeriesExpARCTAN' ist; ansonsten werden das erste
 *           und zweite Glied der Reihenentwicklung nach Taylor genommen:
 *
 *                             x^3
 *             arctan(x) = x - ---  + Rest O(x^5)
 *                              3
 *
 *             ([Bron87], Tab. 1.1.3.2.)
 *
 *      2)   der zweite Bereich wird durch folgende Formel auf
 *           den Bereich
 *                         [-tan(Pi/8), tan(Pi/8)]
 *           transformiert:
 *
 *                                                 x - 1
 *             arctan(x) = arctan(1) + atanApprox( ----- )
 *                                                 1 + x
 *
 *             ([Hart68], 6.5.27 )
 *
 *      3)   der dritte Bereich wird durch die folgende Formel auf
 *           den Bereich
 *                         [tan(Pi/8), 0)
 *           transformiert:
 *
 *                           Pi                  1
 *             arctan(|x|) = --  -  atanApprox( --- )
 *                           2                  |x|
 *
 *             ([Hart68], 6.5.22)
 *
 *           wegen
 *
 *                  3           1
 *             tan( - Pi ) = --------
 *                  8        tan(Pi/8)
 *
 * -> Das Vorzeichen wird beruecksichtigt
 *)
CONST SeriesExpARCTAN = 2.7E-2; (* = sqrt(sqrt(5.0*Eps)) *)

VAR neg : BOOLEAN;

PROCEDURE ARCTN5071 ((* EIN/ -- *) x : REAL ): REAL;
(* 7.54 Stellen auf [ 0, Tan(pi/8) ] *)
CONST P0 = 0.1265998609915E+2;
      P1 = 0.63691887127E+1;
      Q0 = 0.1265998646243E+2;
      Q1 = 0.105891113168E+2;

VAR xSqr : REAL;

BEGIN (* ARCTN5071 *)
 xSqr := x * x;

 RETURN(x *
         (        P1  * xSqr + P0) /
         ((xSqr + Q1) * xSqr + Q0)
        );
END ARCTN5071;

BEGIN (* arctan *)
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x >= tan3pio8 THEN
   x := pio2 - ARCTN5071(1.0 / x);
 ELSIF x > tan1pio8 THEN
   x := pio4 + ARCTN5071((x - 1.0) / (x + 1.0));
 ELSIF x >= SeriesExpARCTAN THEN
   x := ARCTN5071(x);
 ELSE
   x := x - x * x * x / 3.0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan2* ((* EIN/ -- *) y : REAL;
                    (* EIN/ -- *) x : REAL ): REAL;

(* Berechnet aus <x> und <y>, die Koordinaten in einem rechtwinkligen
   Koordinatensystem darstellen, den entsprechenden Winkel in einem
   Polarkoordinatensystem (bzgl. der positive x-Achse).
   Im wesentlichen wird dabei arctan(y / x) berechnet, der Wertebereich
   ist jedoch: (-pi, pi].
   <x> und <y> duerfen nicht beide gleichzeitig Null sein.

   Die Reihenfolge der Parameter ist zu beachten!
 *)

(*                  Y
 *                             angle = pi/4 ( x = y )
 *          \       ^       /
 *           \ III  |  II  /
 *            \     |     /
 *             \    |    /
 *        IV    \   |   /     I
 *               \  |  /
 *                \ | /
 *      -------------------------->  X
 *                / | \
 *               /  |  \
 *        V     /   |   \   VIII
 *             /    |    \
 *            /     |     \
 *           /  VI  | VII  \
 *          /       |       \
 *                             angle = -pi/4
 *
 * Damit das Argument fuer "arctan()" auf den Bereich [0, 1] beschraenkt
 * bleibt (wegen Genauigkeit), wird der Winkel wie folgt berechnet:
 *
 * angle := arctan(min(|x|, |y|) / max(|x|, |y|));
 *
 * Dieses Ergebnis wird dann noch durch Unterscheiden der Vorzeichen und
 * absoluten Groessen von Real- und Imaginaerteil in acht Oktanten unter-
 * teilt, um den Bereich (-pi, pi] zu erhalten.
 * (Siehe auch [Hart68], S.126.; [Bron87], 3.4.2.4)
 *
 *
 *     I: |x| >= |y|, x >= 0, y >= 0 :         arctan(y/x)
 *    II: |x| <  |y|, x >= 0, y >= 0 : pi/2  - arctan(x/y)
 *   III: |x| <  |y|, x <  0, y >= 0 : pi/2  - arctan(x/y)
 *    IV: |x| >= |y|, x <  0, y >= 0 : pi    + arctan(y/x)
 *     V: |x| >= |y|, x <  0, y <  0 : -pi   + arctan(y/x)
 *    VI: |x| <  |y|, x <  0, y <  0 : -pi/2 - arctan(x/y)
 *   VII: |x| <  |y|, x >= 0, y <  0 : -pi/2 - arctan(x/y)
 *  VIII: |x| >= |y|, x >= 0, y <  0 :         arctan(y/x)
 *)
VAR angle : REAL;

BEGIN
 IF x = 0.0 THEN
   IF y = 0.0 THEN
     HALT(Sys.REALERR);
     RETURN(0.0);
   ELSIF y < 0.0 THEN
     RETURN(-pio2);
   ELSE
     RETURN(pio2);
   END;
 ELSIF ABS(x) < ABS(y) THEN
   angle := arctan(x / y);
   IF y < 0.0 THEN
     RETURN(-pio2 - angle);  (* VI, VII *)
   ELSE
     RETURN(pio2 - angle);   (* II, III *)
   END;
 ELSE
   angle := arctan(y / x);
   IF x < 0.0 THEN
     IF y < 0.0 THEN
       RETURN(angle - pi);   (* V *)
     ELSE
       RETURN(angle + pi);   (* IV *)
     END;
   ELSE
     RETURN(angle);          (* I, VIII *)
   END;
 END;
END arctan2;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Sinus-Hyperbolicus von <x>. *)

(* Berechnung des Sinus Hyperbolicus
 *
 * -> Die Definition lautet:
 *
 *                  e^x - e^(-x)     e^x     1
 *      sinh(x)  =  ------------  =  --- - -----, MAXaprxSINH < x <= MAXfullSINH
 *                       2            2    2*e^x
 *
 *      sinh(-x) = -sinh(x)
 *
 *      ([Hart68], 6.2.2, 6.2.3; [Bron87], 2.5.2.3.1)
 *
 * -> Da der zweite Term fuer x > MAXfullSINH gegenueber dem ersten
 *    Term verschwindet (wegen der begrenzten Stellenzahl), vereinfacht
 *    sich die Formel in diesem Fall zu:
 *
 *                  e^x
 *      sinh(x)  =  ---  , x > MAXfullSINH
 *                   2
 *
 *      ([Hart68], 6.2.5)
 *
 * -> Ist das Argument dagegen hinreichend klein, wird eine Polynom-
 *    approximation verwendet, da die Exponentialfunktion fuer Argumente
 *    x < 1 gegen 1 geht, wodurch die Subtraktion zweier gleichgrosser
 *    Zahlen zur Stellenausloeschung fuehren wuerde:
 *
 *      sinh(x)  =  SINH2028(x)  , SeriesExpSINH <= x <= MAXaprxSINH
 *
 * -> Ist das Argument sehr klein, werden die ersten beiden Glieder der
 *    Taylor-Reihenentwicklung genommen:
 *
 *                        x^3
 *      sinh(x)  =  x  +  ---  + O(x^5)  ,  x < SeriesExpSINH
 *                         6
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
CONST
  MAXfullSINH   = 10.0;
  MAXaprxSINH   = 0.5;
  SeriesExpSINH = 6.0E-2; (* = sqrt(sqrt(120.0*Eps)) *)

VAR neg : BOOLEAN;

PROCEDURE SINH2022 ((* EIN/ -- *) x : REAL ): REAL;
(* 9.73 Stellen auf [ 0, 1/2 ] *)
CONST P0 =  0.54215740653694062E+3;
      P1 =  0.5725325949390867E+2;
      Q0 =  0.54215740663738235E+3;
      Q1 = -0.3310632117981726E+2;

VAR xSqr : REAL;

BEGIN (* SINH2022 *)
 xSqr := x * x;

 RETURN(x *
         (        P1  * xSqr + P0) /
         ((xSqr + Q1) * xSqr + Q0)
        );
END SINH2022;

BEGIN (* sinh *)
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXfullSINH THEN
   x := Low.scale(exp(x), -1);
 ELSIF x > MAXaprxSINH THEN
   x := exp(x);
   x := Low.scale(x, -1) - 1.0 / Low.scale(x, 1);
 ELSIF x >= SeriesExpSINH THEN
   x := SINH2022(x);
 ELSE
   x := x + x * x * x / 6.0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Kosinus-Hyperbolicus von <x>. *)

(* Berechnung des Cosinus Hyperbolicus
 *
 * -> Die Definition lautet:
 *
 *                 e^x + e^(-x)   e^x     1
 *      cosh(x)  = ------------ = --- + ----- , SeriesExpCOSH < x <= MAXfullCOSH
 *                      2          2    2*e^x
 *
 *      cosh(-x) = cosh(x)
 *
 *      ([Hart68], 6.2.2, 6.2.3; [Bron87], 2.5.2.3.1)
 *
 * -> Da der zweite Term fuer x > MAXfullCOSH gegenueber dem ersten
 *    Term verschwindet (wegen der begrenzten Stellenzahl), vereinfacht
 *    sich die Formel in diesem Fall zu:
 *
 *                  e^x
 *      cosh(x)  =  ---  , x > MAXfullCOSH
 *                   2
 *
 *      ([Hart68], 6.2.5)
 *
 * -> Ist das Argument sehr klein, werden die ersten drei Glieder der
 *    Taylor-Reihenentwicklung genommen:
 *
 *                        x^2    x^4
 *      cosh(x)  =  1  +  ---  + ---  +  O(x^6)  ,  x < SeriesExpCOSH
 *                         2      24
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
CONST
  MAXfullCOSH   = 10.0;
  SeriesExpCOSH = 2.1E-1; (* = cbrt(sqrt(720.0*Eps)) *)

VAR xSqr: REAL;

BEGIN
 x := ABS(x);

 IF x > MAXfullCOSH THEN
   RETURN(Low.scale(exp(x), -1));
 ELSIF x >= SeriesExpCOSH THEN
   x := exp(x);
   RETURN(Low.scale(x, -1) + 1.0 / Low.scale(x, 1));
 ELSE
   xSqr := x * x;
   RETURN(1.0 + Low.scale(xSqr, -1) + xSqr * xSqr / 24.0);
 END;
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Tangens-Hyperbolicus von <x>. *)

(* Berechnung des Tangens Hyperbolicus
 *
 * -> Die Definition lautet:
 *
 *                  e^x - e^(-x)
 *      tanh(x)  =  ------------  , MAXaprxTANH < x <= MAXfullTANH
 *                  e^x + e^(-x)
 *
 *      tanh(-x) = -tanh(x)
 *
 *      ([Hart68], 6.2.2, 6.2.3; [Bron87], 2.5.2.3.1)
 *
 * -> Da e^(-x) fuer x > MAXfullTANH gegenueber e^x verschwindet,
 *    (wegen der begrenzten Stellenzahl), stehen in Nenner und Zaehler
 *    die gleichen Werte (e^x), weswegen sich in diesem Fall die Berechnung
 *    eruebrigt:
 *
 *      tanh(x)  =  1  ,  x > MAXfullTANH
 *
 *      ([Hart68], 6.2.5)
 *
 * -> Ist das Argument sehr klein, werden die ersten drei Glieder der
 *    Taylor-Reihenentwicklung genommen, da die Exponentialfunktion fuer
 *    Argumente x < 1 gegen 1 geht, wodurch die Subtraktion zweier
 *    aehnlich grosser Zahlen zur Stellenausloeschung fuehren wuerde.
 *
 *                        x^3     2*x^5
 *      tanh(x)  =  x  -  ---  +  -----  +  O(x^7)  ,  x < SeriesExpTANH
 *                         3        15
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
CONST
  MAXcalcTANH   = 11.0;
  SeriesExpTANH = 1.1E-1; (* = cbrt(sqrt(315.0/17.0*Eps)) *)

VAR neg  : BOOLEAN;
    y    : REAL;
    xSqr : REAL;
    xCub : REAL;

BEGIN (* tanh *)
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXcalcTANH THEN
   x := 1.0;
 ELSIF x >= SeriesExpTANH THEN
   x := exp(x);
   y := 1.0 / x;
   x := (x - y) / (x + y);
 ELSE
   xSqr := x * x;
   xCub := x * xSqr;
   x    := x - xCub / 3.0 + Low.scale(xSqr * xCub, 1) / 15.0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Areasinus-Hyperbolicus von <x>. *)

(* Berechnung des Area Sinus Hyperbolicus
 *
 * -> Die Definition lautet:
 *
 *                               ________
 *      arcsinh(x)  =  ln( x + \/ x^2 + 1 ) , SeriesExpARCSINH <= x <= MAXfullARCSINH
 *
 *      arcsinh(-x) = -arcsinh(x)
 *
 *      ([Hart68], 6.3.4; [Bron87], 2.5.2.3.4)
 *
 * -> Fuer hinreichend grosse Argumente verschwindet wegen der begrenzten
 *    Stellenzahl die 1 gegenueber dem Quadrat des Argumentes, so dass gilt:
 *
 *      arcsinh(x)  =  ln(2*x) ,  x > MAXfullARCSINH
 *
 * -> Fuer kleine Argumente naehert sich der Ausdruck dem Term ln(1 + x). Da
 *    die gueltige Stellenzahl von x durch die Addition mit einer gegenueber
 *    x sehr grossen Zahl sinkt, werden die ersten drei Glieder der Taylor-
 *    Reihenentwicklung genommen:
 *
 *                           x^3     3*x^5
 *      arcsinh(x)  =  x  -  ---  +  -----  +  O(x^7)  ,  x < SeriesExpARCSINH
 *                            6        40
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
CONST
  MAXfullARSINH   = 5.0E+5;
  SeriesExpARSINH = 1.2E-1; (* = cbrt(sqrt(28.0*EpsSHORT)) *)

VAR neg  : BOOLEAN;
    xSqr : REAL;
    xCub : REAL;

BEGIN
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXfullARSINH THEN
   x := ln(Low.scale(x, 1));
 ELSIF x >= SeriesExpARSINH THEN
   x := ln(x + sqrt(x * x + 1.0));
 ELSE
   xSqr := x * x;
   xCub := xSqr * x;
   x    := x - xCub / 6.0 + 0.075 * xCub * xSqr
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Areakosinus-Hyperbolicus von <x>.
   <x> muss groesser gleich Eins sein.
 *)

(* Berechnung des Area Cosinus Hyperbolicus
 *
 * -> Die Definition lautet:
 *
 *                               ________
 *      arccosh(x)  =  ln( x + \/ x^2 - 1 ) ,  x <= MAXfullARCCOSH
 *
 *      ([Hart68], 6.3.4; [Bron87], 2.5.2.3.4)
 *
 * -> Fuer hinreichend grosse Argumente verschwindet wegen der begrenzten
 *    Stellenzahl die 1 gegenueber dem Quadrat des Argumentes, so dass gilt:
 *
 *      arccosh(x)  =  ln(2*x) ,  x > MAXfullARCCOSH
 *)
CONST
  MAXfullARCOSH = 5.0E+5;

BEGIN
 IF x < 1.0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(0.0);
 ELSIF x > MAXfullARCOSH THEN
   RETURN(ln(Low.scale(x, 1)));
 ELSE
   RETURN(ln(x + sqrt(x * x - 1.0)));
 END;
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh* ((* EIN/ -- *) x : REAL ): REAL;

(* Liefert eine Approximation des Areatangens-Hyperbolicus von <x>.
   |<x>| muss kleiner Eins sein.
 *)

(* Berechnung des Area Tangens Hyperbolicus
 *
 * -> Die Definition lautet:
 *
 *                     1       1 + x
 *      arctanh(x)  =  - * ln( ----- )  ,  x >= SeriesExpARCTANH
 *                     2       1 - x
 *
 *      arctanh(-x) = -arctanh(x)
 *
 *      ([Hart68], 6.3.5; [Bron87], 2.5.2.3.4)
 *
 * -> Fuer kleine Argumente werden die ersten drei Glieder der
 *    Taylor-Reihenentwicklung genommen:
 *
 *                           x^3     x^5
 *      arctanh(x)  =  x  +  ---  +  ---  +  O(x^7)  ,  x < SeriesExpARCTANH
 *                            3       5
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
CONST
  SeriesExpARTANH = 9.7E-2; (* = cbrt(sqrt(7.0*EpsSHORT)) *)

VAR neg  : BOOLEAN;
    y    : REAL;
    xSqr : REAL;
    xCub : REAL;

BEGIN
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;
 y := 1.0 - x;

 IF y <= 0.0 THEN
   (* <Definitionsbereich> *)
   (* Zu einem Ueberlauf bei der spaeteren Division kann es nicht
    * kommen, da sich <x> und 1.0 um minimal 1E-8 unterscheiden koennen.
    *)
   HALT(Sys.REALERR);
   IF neg THEN
     RETURN(-Low.large);
   ELSE
     RETURN(Low.large);
   END;
 ELSIF x >= SeriesExpARTANH THEN
   x := Low.scale(ln((1.0 + x) / y), -1);
 ELSE
   xSqr := x * x;
   xCub := xSqr * x;
   x    := x + xCub / 3.0 + 0.2 * xCub * xSqr
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arctanh;

END Math.

