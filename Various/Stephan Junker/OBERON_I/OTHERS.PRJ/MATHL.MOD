MODULE MathL;

(*****************************************************************************)
(* Oakwood-compatible MathL                                                  *)
(* --------------------------------------------------------------------------*)
(* Mathematische Funktionen fuer den Typ LONGREAL.                           *)
(* Hinweise zur Implementierung finden sich in der Datei MATH_IMP.TXT.       *)
(* Die Approximationen sind auf IEEE double precision (16 Stellen            *)
(* Genauigkeit) ausgelegt.                                                   *)
(* --------------------------------------------------------------------------*)
(* 21-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHMEN:
   1) LowLong.radix = 2, d.h. LowLong.scale multipliziert mit bzw. dividiert
      durch Zweierpotenzen.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

IMPORT SYSTEM, Sys, Low:=LowLong, Support:=LongSupport;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  pi*  = 3.1415926535897932384626433832795028841972D0;
  e*   = 2.7182818284590452353602874713526624977572D0;

CONST
  pio2     = 1.57079632679489661923132169163975144D0; (* pi/2 *)
  pio4     = 7.8539816339744830961566084581987572D-1; (* pi/4 *)
  pi2      = 6.28318530717958647692528676655900576D0; (* 2*pi *)

  sqrt2    = 1.41421356237309504880168872420969808D0; (* 2^(1/2) *)
  sqrt2o2  = 7.0710678118654752440084436210484904D-1; (* 2^(1/2)/2 *)

  ln2      = 6.9314718055994530941723212145817657D-1; (* logE(2)  *)
  lde      = 1.44269504088896340735992468100189213D0; (* log2(e)  *)

  tan1pio8 = 4.1421356237309504880168872420969807D-1; (* tan(pi/8) *)
  tan3pio8 = 2.41421356237309504880168872420969807D0; (* tan(3*pi/8) *)
  sinpio6  = 0.5;                                     (* sin(pi/6) *)

VAR
  expfact : ARRAY 16 OF LONGREAL;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE trigon ((* EIN/ -- *)     x        : LONGREAL;
                  (* EIN/ -- *)     sin      : BOOLEAN;
                  (* -- /AUS *) VAR quadrant : SHORTINT ) : LONGREAL;
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
CONST SeriesExpSIN = 4.0D-4; (* = sqrt(sqrt(120.0*Eps)) *)
      SeriesExpCOS = 2.7D-4; (* = sqrt(sqrt(24.0*Eps))  *)

PROCEDURE SIN3063 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.59 Stellen auf [0, Pi/4] *)
CONST P0 =  0.206643433369958582409167054D+7;
      P1 = -0.18160398797407332550219213D+6;
      P2 =  0.359993069496361883172836D+4;
      P3 = -0.2010748329458861571949D+2;
      Q0 =  0.263106591026476989637710307D+7;
      Q1 =  0.3927024277464900030883986D+5;
      Q2 =  0.27811919481083844087953D+3;

VAR xSqr : LONGREAL;

BEGIN (* SIN3063 *)
 xSqr := x * x;

 RETURN(x *
         (((P3 * xSqr + P2) * xSqr + P1) * xSqr + P0) /
         (((     xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
END SIN3063;

(*---------------------------------------------------------------------------*)

PROCEDURE COS3843 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 16.18 Stellen auf [0, Pi/4] *)
CONST P0 =  0.12905394659037374438571854D+7;
      P1 = -0.3745670391572320471032359D+6;
      P2 =  0.134323009865390842853673D+5;
      P3 = -0.112314508233409330923D+3;
      Q0 =  0.12905394659037373590295914D+7;
      Q1 =  0.234677731072458350524124D+5;
      Q2 =  0.2096951819672630628621D+3;

VAR xSqr : LONGREAL;

BEGIN (* COS3844 *)
 xSqr := x * x;

 RETURN((((P3 * xSqr + P2) * xSqr + P1) * xSqr + P0) /
        (((     xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
END COS3843;

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
     RETURN(SIN3063(x / pio4));
   ELSE
     RETURN(x - x * x * x / 6.0D0);
   END;
 ELSIF x >= SeriesExpCOS THEN
   RETURN(COS3843(x / pio4));
 ELSE
   RETURN(1.0D0 - Low.scale(x * x, -1));
 END;
END trigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *) x    : LONGREAL;
                     (* EIN/ -- *) asin : BOOLEAN ): LONGREAL;

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
CONST SeriesExpARCSIN = 2.3D-4; (* = sqrt(sqrt(40.0/3.0*Eps)) *)

VAR absX : LONGREAL;
    neg  : BOOLEAN;

PROCEDURE ARCSN4698 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.31 Stellen auf [-sin(Pi/6), sin(Pi/6)] *)
CONST P0 = -0.128282549997869277323243486D+4;
      P1 =  0.27058673264340643538462677D+4;
      P2 = -0.19037559157507792669596123D+4;
      P3 =  0.499087473518143347562346D+3;
      P4 = -0.36148645680347523002109D+2;
      Q0 = -0.12828254999786927795016574D+4;
      Q1 =  0.29196715764305175556632146D+4;
      Q2 = -0.22941559326579784210521634D+4;
      Q3 =  0.719740422953630342673276D+3;
      Q4 = -0.75411436441961707886768D+2;

VAR xSqr : LONGREAL;

BEGIN (* ARCSN4698 *)
  xSqr := x * x;

 RETURN(x *
         ((((        P4  * xSqr + P3) * xSqr + P2) * xSqr + P1) * xSqr + P0) /
         (((((xSqr + Q4) * xSqr + Q3) * xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
END ARCSN4698;

BEGIN (* arcTrigon *)
 absX := ABS(x);
 neg  := x < 0.0D0;
 IF absX > 1.0D0 THEN
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
       RETURN(0.0D0);
     END;
   END;
 END;

 IF absX > sinpio6  THEN
   IF absX = 1.0D0 THEN
     x := 0.0D0;
   ELSE
     (* Je naeher <absX> an 1.0 liegt, desto mehr niederwertige Stellen
      * fehlen dem Argument an Genauigkeit, was durch die Differenz
      * dann leider sichtbar wird.
      *)
     x := Low.scale(ARCSN4698(sqrt(Low.scale(1.0D0 - absX, -1))), 1);
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
     x := ARCSN4698(x);
   ELSE
     x := x + x * x * x / 6.0D0;
   END;
   IF asin THEN
     RETURN(x);
   ELSE
     RETURN(pio2 - x);
   END;
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
 * -> drei Iterationen der Mantisse nach Newton (``Heron`sche Formel''),
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
    y : LONGREAL;

PROCEDURE SQRT0071 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 2.30 Stellen auf [0.25, 1] *)
CONST P0 =  0.2592768763D0;
      P1 =  0.1052021187D1;
      P2 = -0.3163221431D0;

BEGIN (* SQRT0071 *)
 RETURN((P2 * x + P1) * x + P0);
END SQRT0071;

BEGIN (* sqrt *)
 IF x <= 0.0D0 THEN
   IF x < 0.0D0 THEN
     (* <Definitionsbereich> *)
     HALT(Sys.REALERR);
     RETURN(0.0D0);
   END;
   RETURN(0.0D0);
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

 FOR i := 1 TO 3  DO
   (* 3 Iterationen: > 18 Stellen *)
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

PROCEDURE exp* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
 *    2^x = 2^(n + f)
 *        = 2^(n + f0 + (f - f0))     ; f0     = f mod 16
 *        = 2^n * 2^f0 * 2^(f - f0)   ; f - f0 = i/16, 0<=i<16
 *
 *    Fuer 2^f0 wird dann eine Approximation verwendet, waehrend die
 *    16 moeglichen Werte fuer 2^(f0 - f) in einer Tabelle gespeichert
 *    werden koennen.
 *
 *    ([Hart68], 6.2.32 - 6.2.34)
 *
 * Da die Potenzfunktion fuer Argumente x > 1 eine grosse Steigung besitzt,
 * machen sich die Ungenauigkeiten grosser Argumente im Ergebnis umso
 * staerker bemerkbar. Wegen b^(-x) = 1/b^x gilt dies auch fuer |x| > 1.
 *)
VAR fidx : INTEGER;
    n    : INTEGER;
    f    : LONGREAL;

PROCEDURE EXPB1121 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 16.35 Stellen auf [0, 1/16] *)
CONST P0 = 0.72135034108448192083D+1;
      P1 = 0.57761135831801928D-1;
      Q0 = 0.208137711965230361973D+2;

VAR xSqr : LONGREAL;
    Px   : LONGREAL;
    Qx   : LONGREAL;

BEGIN (* EXPB1121 *)
 xSqr := x * x;

 Px   := x * (xSqr * P1 + P0);
 Qx   :=      xSqr      + Q0;

 RETURN((Qx + Px) / (Qx - Px));
END EXPB1121;

BEGIN (* exp *)
 IF x = 0.0D0 THEN
   RETURN(1.0D0);
 END;
 x := x * lde;

 n    := SHORT(SYSTEM.TRUNC(x));
 f    := Low.scale(Low.fractpart(x), 4);   (* f mod 16; /1 *)
 fidx := SHORT(SYSTEM.TRUNC(f));
 f    := Low.scale(Low.fractpart(f), -4);  (* f mod 16; /2 *)

 IF fidx < 0 THEN
   RETURN(Low.scale(EXPB1121(f) / expfact[-fidx], n));
 ELSE
   RETURN(Low.scale(EXPB1121(f) * expfact[fidx], n));
 END;
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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

PROCEDURE LOGE2704 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 16.65 Stellen auf [1/sqrt(2), sqrt(2)] *)
CONST P0 = -0.90174691662040536328986D+2;
      P1 =  0.934639006428585382474D+2;
      P2 = -0.1832787037221593212D+2;
      Q0 = -0.45087345831020305748486D+2;
      Q1 =  0.61761065598471302843D+2;
      Q2 = -0.20733487895513939345D+2;

VAR xSqr : LONGREAL;

BEGIN (* LOGE2704 *)
 x    := (x - 1.0D0) / (x + 1.0D0);
 xSqr := x * x;

 RETURN(x *
         ((        P2  * xSqr + P1) * xSqr + P0) /
         (((xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
END LOGE2704;

BEGIN (* ln *)
 IF x <= 0.0D0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(-Low.large);
 ELSIF x = 1.0D0 THEN
   RETURN(0.0D0);
 END;

 k := Low.exponent(x);
 x := Low.fraction(x);

 IF x > sqrt2 THEN
   x := Low.scale(x, -1);
   INC(k); (* damit Produkt x*2^k gleich bleibt *)
 END;

 RETURN(k * ln2 + LOGE2704(x));
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE power* ((* EIN/ -- *) x    : LONGREAL;
                  (* EIN/ -- *) base : LONGREAL ): LONGREAL;

(* Liefert eine Approximation der Potenzierung von <x> zur Basis <base>.
   Falls <base> kleiner Null ist, muss <x> eine ganze Zahl sein.
   Falls <base> gleich Null ist, muss <x> groesser Null sein.
 *)

VAR neg   : BOOLEAN;
    whole : LONGREAL;

BEGIN
 neg := FALSE;
 IF base <= 0.0D0 THEN
   IF base < 0.0D0 THEN
     IF Support.modf(x, whole) # 0.0D0 THEN
       (* <Definitionsbereich> : -base^x, x nicht ganzzahlig *)
       HALT(Sys.REALERR);
       RETURN(0.0D0);
     ELSE
       base := -base;
       neg  := ODD(SYSTEM.TRUNC(whole));
     END;
   ELSIF x <= 0.0D0 THEN
     (* <Definitionsbereich> : 0^0 oder 0^(-x) *)
     HALT(Sys.REALERR);
     RETURN(0.0D0);
   ELSE (* 0^exp *)
     RETURN(0.0D0);
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

PROCEDURE log* ((* EIN/ -- *) x    : LONGREAL;
                (* EIN/ -- *) base : LONGREAL ): LONGREAL;

(* Liefert eine Approximation des Logarithmus von <x> zur Basis <base>.
   <x> und <base> muessen groesser Null sein.
 *)

(* [Hart68], 6.3.3 *)
BEGIN
 IF base <= 0.0D0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(0.0D0);
 END;
 IF x <= 0.0D0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(-Low.large);
 ELSIF x = 1.0D0 THEN
   RETURN(0.0D0);
 END;
 RETURN(ln(x) / ln(base));
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE round* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

(* Liefert den ganzzahligen Wert, der am naechsten an <x> liegt. Falls
   <x> genau zwischen zwei ganzzahligen Werten liegt, wird zur naechsten
   geraden Zahl gerundet.
 *)

VAR e : INTEGER;

BEGIN
 e := Low.exponent(x) + 1;

 IF e < 0 THEN
   RETURN(0.0D0);
 ELSIF e = 0 THEN
   IF x < -0.5D0 THEN
     RETURN(-1.0D0);
   ELSIF x > 0.5D0 THEN
     RETURN(1.0D0);
   ELSE
     RETURN(0.0D0);
   END;
 END;

 RETURN(Low.round(x, e));
END round;

(*---------------------------------------------------------------------------*)

PROCEDURE sin* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

(* Liefert eine Approximation des Sinus von <x>. *)

VAR neg      : BOOLEAN;
    quadrant : SHORTINT;

BEGIN
 neg := x < 0.0D0;
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

PROCEDURE cos* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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

PROCEDURE tan* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
CONST SeriesExpTAN = 2.0D-4; (* = sqrt(sqrt(7.5*Eps)) *)

VAR neg : BOOLEAN;

PROCEDURE TAN4286 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 19.94 Stellen auf [0, Pi/4] *)
CONST P0 =  0.1088860043728168752138857983D+8;
      P1 = -0.8958884400676804108729639541D+6;
      P2 =  0.1418985425276177838800394831D+5;
      P3 = -0.45649319438665631873961137D+2;
      Q0 =  0.1386379666356762916533913361D+8;
      Q1 = -0.399130951803516515044342794D+7;
      Q2 =  0.1353827128051190938289294872D+6;
      Q3 = -0.1014656190252885338754401947D+4;

VAR xSqr : LONGREAL;

BEGIN (* TAN4286 *)
 xSqr := x * x;

 RETURN(x *
         (((        P3  * xSqr + P2) * xSqr + P1) * xSqr + P0) /
         ((((xSqr + Q3) * xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
END TAN4286;

BEGIN (* tan *)
 neg := x < 0.0D0;
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
   IF x = 0.0D0 THEN
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
     x := 1.0D0 / TAN4286(x);
   END;
 ELSIF x >= SeriesExpTAN  THEN
   x := TAN4286(x / pio4);
 ELSE
   x := x + x * x * x / 3.0D0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

(* Liefert eine Approximation des Arcussinus von <x>.
   Der Wertebereich ist: (-pi/2, pi/2].
   |<x>| muss kleiner gleich Eins sein.
 *)

BEGIN
 RETURN(arcTrigon(x, TRUE));
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

(* Liefert eine Approximation des Arcuskosinus von <x>.
   Der Wertebereich ist: [0, pi].
   |<x>| muss kleiner gleich Eins sein.
 *)

BEGIN
 RETURN(arcTrigon(x, FALSE));
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
CONST SeriesExpARCTAN = 1.8D-4; (* = sqrt(sqrt(5.0*Eps)) *)

VAR neg : BOOLEAN;

PROCEDURE ARCTN5076 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.55 Stellen auf [0, tan(Pi/8)] *)
CONST P0 = 0.445413400592906803197511D+2;
      P1 = 0.77477687719204208616481D+2;
      P2 = 0.40969264832102256374186D+2;
      P3 = 0.666057901700926265753D+1;
      P4 = 0.1589740288482307048D+0;
      Q0 = 0.445413400592906804445995D+2;
      Q1 = 0.92324801072300974840693D+2;
      Q2 = 0.62835930511032376833267D+2;
      Q3 = 0.1550397755142198752523D+2;

VAR xSqr : LONGREAL;

BEGIN (* ARCTN5076 *)
 xSqr := x * x;

 RETURN(x *
         ((((P4 * xSqr + P3) * xSqr + P2) * xSqr + P1) * xSqr + P0) /
         ((((     xSqr + Q3) * xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
END ARCTN5076;

BEGIN (* arctan *)
 neg := x < 0.0D0;
 IF neg THEN
   x := -x;
 END;

 IF x >= tan3pio8 THEN
   x := pio2 - ARCTN5076(1.0D0 / x);
 ELSIF x > tan1pio8 THEN
   x := pio4 + ARCTN5076((x - 1.0D0) / (x + 1.0D0));
 ELSIF x >= SeriesExpARCTAN THEN
   x := ARCTN5076(x);
 ELSE
   x := x - x * x * x / 3.0D0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan2* ((* EIN/ -- *) y : LONGREAL;
                    (* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
VAR angle : LONGREAL;

BEGIN
 IF x = 0.0D0 THEN
   IF y = 0.0D0 THEN
     HALT(Sys.REALERR);
     RETURN(0.0D0);
   ELSIF y < 0.0D0 THEN
     RETURN(-pio2);
   ELSE
     RETURN(pio2);
   END;
 ELSIF ABS(x) < ABS(y) THEN
   angle := arctan(x / y);
   IF y < 0.0D0 THEN
     RETURN(-pio2 - angle);  (* VI, VII *)
   ELSE
     RETURN(pio2 - angle);   (* II, III *)
   END;
 ELSE
   angle := arctan(y / x);
   IF x < 0.0D0 THEN
     IF y < 0.0D0 THEN
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

PROCEDURE sinh* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
 *    x < 1 gegen 1 geht, wodurch die Subtraktion zweier aehnlich grosser
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
  MAXfullSINH   = 20.0D0;
  MAXaprxSINH   = 0.5D0;
  SeriesExpSINH = 4.0D-4; (* = sqrt(sqrt(120.0*Eps)) *)

VAR neg : BOOLEAN;

PROCEDURE SINH2028 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.10 Stellen auf [0, 1/2] *)
CONST P0 = -0.1102208280604367809653D+3;
      P1 = -0.1737013801007254553629D+2;
      P2 = -0.7518402338487383016651D0;
      P3 = -0.1353587838210377975368D-1;
      P4 = -0.105327911468759765298D-3;
      Q0 = -0.1102208280604367800981D+3;

VAR xSqr : LONGREAL;

BEGIN (* SINH2028 *)
 xSqr := x * x;

 RETURN(x *
         ((((P4 * xSqr + P3) * xSqr + P2) * xSqr + P1) * xSqr + P0) /
         (                                               xSqr + Q0)
        );
END SINH2028;

BEGIN (* sinh *)
 neg := x < 0.0D0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXfullSINH THEN
   x := Low.scale(exp(x), -1);
 ELSIF x > MAXaprxSINH THEN
   x := exp(x);
   x := Low.scale(x, -1) - 1.0D0 / Low.scale(x, 1);
 ELSIF x >= SeriesExpSINH THEN
   x := SINH2028(x);
 ELSE
   x := x + x * x * x / 6.0D0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
  MAXfullCOSH   =  20.0D0;
  SeriesExpCOSH =  7.3D-3; (* = cbrt(sqrt(720.0*Eps)) *)

VAR xSqr: LONGREAL;

BEGIN
 x := ABS(x);

 IF x > MAXfullCOSH THEN
   RETURN(Low.scale(exp(x), -1));
 ELSIF x >= SeriesExpCOSH THEN
   x := exp(x);
   RETURN(Low.scale(x, -1) + 1.0D0 / Low.scale(x, 1));
 ELSE
   xSqr := x * x;
   RETURN(1.0D0 + Low.scale(xSqr, -1) + xSqr * xSqr / 24.0D0);
 END;
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
 * -> Ist das Argument dagegen hinreichend klein, wird eine Polynom-
 *    approximation verwendet, da die Exponentialfunktion fuer Argumente
 *    x < 1 gegen 1 geht, wodurch die Subtraktion zweier aehnlich grosser
 *    Zahlen zur Stellenausloeschung fuehren wuerde. Es wird dabei eine
 *    Approximation fuer e^x - 1 benutzt:
 *
 *                    EXPEC1801(2*x)
 *      tanh(x)  =  ------------------  , SeriesExpTANH <= x <= MAXaprxTANH
 *                  2 + EXPEC1801(2*x)
 *
 *      ([Hart68], 6.2.28)
 *
 * -> Ist das Argument sehr klein, werden die ersten drei Glieder der
 *    Taylor-Reihenentwicklung genommen:
 *
 *                        x^3     2*x^5
 *      tanh(x)  =  x  -  ---  +  -----  +  O(x^7)  ,  x < SeriesExpTANH
 *                         3        15
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
CONST
  MAXcalcTANH   = 22.0D0;
  MAXaprxTANH   = 0.1D0;
  SeriesExpTANH = 4.0D-3; (* = cbrt(sqrt(315.0/17.0*Eps)) *)

VAR neg  : BOOLEAN;
    y    : LONGREAL;
    xSqr : LONGREAL;
    xCub : LONGREAL;

PROCEDURE EXPEC1801 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* e^x - 1, 17.49 Stellen auf [0, 0.1] *)
CONST P0 = 0.8400668525364832394067033D+3;
      P1 = 0.2000111415899645689354D+2;
      Q0 = 0.16801337050729664841446817D+4;
      Q1 = 0.18001337040739002280539D+3;

VAR xSqr, Px : LONGREAL;

BEGIN (* EXPEC1801 *)
 xSqr := x * x;
 Px   := x * (P1 * xSqr + P0 );

 RETURN(Low.scale(Px, 1) / ((xSqr + Q1) * xSqr + Q0  - Px));
END EXPEC1801;

BEGIN (* tanh *)
 neg := x < 0.0D0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXcalcTANH THEN
   x := 1.0D0;
 ELSIF x > MAXaprxTANH THEN
   x := exp(x);
   y := 1.0D0 / x;
   x := (x - y) / (x + y);
 ELSIF x >= SeriesExpTANH THEN
   x := EXPEC1801(Low.scale(x, 1));
   x := x / (2.0D0 + x);
 ELSE
   xSqr := x * x;
   xCub := x * xSqr;
   x    := x - xCub / 3.0D0 + Low.scale(xSqr * xCub, 1) / 15.0D0;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
  MAXfullARSINH   = 5.0D9;
  SeriesExpARSINH = 4.2D-3; (* = cbrt(sqrt(28.0*Eps)) *)

VAR neg  : BOOLEAN;
    xSqr : LONGREAL;
    xCub : LONGREAL;

BEGIN
 neg := x < 0.0D0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXfullARSINH THEN
   x := ln(Low.scale(x, 1));
 ELSIF x >= SeriesExpARSINH THEN
   x := ln(x + sqrt(x * x + 1.0D0));
 ELSE
   xSqr := x * x;
   xCub := xSqr * x;
   x    := x - xCub / 6.0D0 + 7.5D-2 * xCub * xSqr
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
  MAXfullARCOSH = 5.0D9;

BEGIN
 IF x < 1.0D0 THEN
   (* <Definitionsbereich> *)
   HALT(Sys.REALERR);
   RETURN(0.0D0);
 ELSIF x > MAXfullARCOSH THEN
   RETURN(ln(Low.scale(x, 1)));
 ELSE
   RETURN(ln(x + sqrt(x * x - 1.0D0)));
 END;
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh* ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
  SeriesExpARTANH = 3.4D-3; (* = cbrt(sqrt(7.0*Eps)) *)

VAR neg  : BOOLEAN;
    y    : LONGREAL;
    xSqr : LONGREAL;
    xCub : LONGREAL;

BEGIN
 neg := x < 0.0D0;
 IF neg THEN
   x := -x;
 END;
 y := 1.0D0 - x;

 IF y <= 0.0D0 THEN
   (* <Definitionsbereich> *)
   (* Zu einem Ueberlauf bei der spaeteren Division kann es nicht
    * kommen, da sich <x> und 1.0 um minimal 1E-16 unterscheiden koennen.
    *)
   HALT(Sys.REALERR);
   IF neg THEN
     RETURN(-Low.large);
   ELSE
     RETURN(Low.large);
   END;
 ELSIF x >= SeriesExpARTANH THEN
   x := Low.scale(ln((1.0D0 + x) / y), -1);
 ELSE
   xSqr := x * x;
   xCub := xSqr * x;
   x    := x + xCub / 3.0D0 + 0.2D0 * xCub * xSqr
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arctanh;

BEGIN (* MathL *)
 (* 2^(0/16) .. 2^(15/16) *)
 expfact[ 0] := 1.0D0;
 expfact[ 1] := 1.04427378242741384032196647874D0;
 expfact[ 2] := 1.09050773266525765920701065575D0;
 expfact[ 3] := 1.13878863475669165370383028382D0;
 expfact[ 4] := 1.18920711500272106671749997056D0;
 expfact[ 5] := 1.2418578120734840485936774687D0;
 expfact[ 6] := 1.29683955465100966593375411774D0;
 expfact[ 7] := 1.3542555469368927282980147401D0;
 expfact[ 8] := 1.4142135623730950488016887242D0;
 expfact[ 9] := 1.47682614593949931138690748031D0;
 expfact[10] := 1.542210825407940823612291862D0;
 expfact[11] := 1.61049033194925430817952066727D0;
 expfact[12] := 1.68179283050742908606225095245D0;
 expfact[13] := 1.75625216037329948311216061926D0;
 expfact[14] := 1.83400808640934246348708318943D0;
 expfact[15] := 1.91520656139714729387261127015D0;
END MathL.

