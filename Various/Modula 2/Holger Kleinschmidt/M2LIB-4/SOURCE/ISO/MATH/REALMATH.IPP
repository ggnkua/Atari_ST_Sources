IMPLEMENTATION MODULE RealMath;
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
(*****************************************************************************)
(* Allg. Hinweise zur Implementierung finden sich in der Datei MATH_IMP.TXT. *)
(* --------------------------------------------------------------------------*)
(* 27-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

#if 0
#define __NO_EXCEPTIONS__
#endif

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHMEN:
   1) LowReal.radix = 2, d.h. LowReal.scale multipliziert mit bzw. dividiert
      durch Zweierpotenzen.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

VAL_INTRINSIC
CAST_IMPORT
INLINE_CODE_IMPORT

#if (defined LPRM2) || (defined SPCM2)
FROM SYSTEM IMPORT LONG;
#endif
FROM PORTAB IMPORT
(* TYPE *) SIGNED, SIGNEDWORD, UNSIGNEDWORD;

#ifndef __NO_EXCEPTIONS__
IMPORT EXCEPTIONS;
#endif
#ifndef MM2
FROM DosSystem IMPORT
(* TYPE *) FPUInfo, FPUFlag, FPUType,
(* PROC *) GetFPU;
#endif

#if (defined HM2) && (defined __LONG_REAL__)
IMPORT LowLong; (* round *)
FROM LowLong IMPORT
#else
IMPORT LowReal; (* round *)
FROM LowReal IMPORT
#endif
(* CONST*) large,
(* PROC *) exponent, fraction, fractpart, intpart, scale;

IMPORT RealSupport;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  MathExceptions = (
    negativeSqrtArg,     (* x    <  0 *)
    nonpositiveLogArg,   (* x    <= 0 *)
    tanOverflow,         (* x    = odd multiple of pi/2 *)
    arcsinArgMagnitude,  (* |x|  >  1 *)
    arccosArgMagnitude,  (* |x|  >  1 *)
    nonpositivePowerArg, (* base <= 0 *)
    roundArgMagnitude
  );

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

#ifndef __NO_EXCEPTIONS__
VAR
  realMathSource : EXCEPTIONS.ExceptionSource;
#endif
#ifndef MM2
VAR
  fpu    : FPUInfo;
  hasFpu : BOOLEAN;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE RAISEmathException ((* EIN/ -- *)     exc : MathExceptions;
                              (* EIN/ -- *) REF msg : ARRAY OF CHAR );

BEGIN
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.RAISE(realMathSource, ORD(exc), msg);
#endif
END RAISEmathException;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRMathException (): BOOLEAN;
BEGIN
#ifdef __NO_EXCEPTIONS__
 RETURN(FALSE);
#else
 RETURN(EXCEPTIONS.IsCurrentSource(realMathSource));
#endif
END IsRMathException;

(*---------------------------------------------------------------------------*)

PROCEDURE trigon ((* EIN/ -- *)     x        : REAL;
                  (* EIN/ -- *)     sin      : BOOLEAN;
                  (* -- /AUS *) VAR quadrant : UNSIGNEDWORD ) : REAL;
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
   x := RealSupport.fmod(x, pi2);
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
   RETURN(1.0 - scale(x * x, -1));
 END;
END trigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *)     x    : REAL;
                     (* EIN/ -- *)     exc  : MathExceptions;
                     (* EIN/ -- *) REF msg  : ARRAY OF CHAR;
                     (* EIN/ -- *)     asin : BOOLEAN        ): REAL;

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
   RAISEmathException(exc, msg);
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
     x := scale(ARCSN4693(sqrt(scale(1.0 - absX, -1))), 1);
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

PROCEDURE sqrt ((* EIN/ -- *) x : REAL ): REAL;

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
VAR e : SIGNEDWORD;
    i : UNSIGNEDWORD;
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
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fsqrt.d x(a6),fp0
#else
   fsqrt.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4404H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5404H,0008H);
#else
   CODE(0F22EH,4404H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4404H,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF x <= 0.0 THEN
   IF x < 0.0 THEN
     (* <Definitionsbereich> *)
     RAISEmathException(negativeSqrtArg, "sqrt: argument < 0.0");
     RETURN(0.0);
   END;
   RETURN(0.0);
 END;

#if (defined MM2)
 e := VAL(SIGNEDWORD,exponent(x) + 1);
 x := scale(fraction(x), -1);
#else
 e := VAL(SIGNEDWORD,exponent(x) + 2);
 x := scale(fraction(x), -2);
#endif
 (* 0.25 <= x < 0.5 *)

 IF ODD(e) THEN
   DEC(e);
   x := scale(x, 1);
   (* 0.5 <= x < 1.0  *)
 END;
 (* 0.25 <= x < 1.0  *)

 y := SQRT0071(x);

 FOR i := 1 TO 2  DO
   (* 2 Iterationen: > 9 Stellen *)
   y := scale(y + x / y, -1);
 END;

 IF e < 0 THEN
   e := -VAL(SIGNEDWORD,CAST(UNSIGNEDWORD,-e) DIV 2);
 ELSE
   e := e DIV 2;
 END;
 RETURN(scale(y, e));
#ifndef MM2
 END;
#endif
END sqrt;

(*---------------------------------------------------------------------------*)

PROCEDURE exp ((* EIN/ -- *) x : REAL ): REAL;

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
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fetox.d x(a6),fp0
#else
   fetox.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4410H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5410H,0008H);
#else
   CODE(0F22EH,4410H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4410H,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF x = 0.0 THEN
   RETURN(1.0);
 END;

 x := x * lde;
 f := fractpart(x);
 n := INT(RealSupport.int(x));

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
 RETURN(scale(x, n));
#ifndef MM2
 END;
#endif
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln ((* EIN/ -- *) x : REAL ): REAL;

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
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   flogn.d x(a6),fp0
#else
   flogn.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4414H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5414H,0008H);
#else
   CODE(0F22EH,4414H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4414H,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF x <= 0.0 THEN
   (* <Definitionsbereich> *)
   RAISEmathException(nonpositiveLogArg, "ln: argument <= 0.0");
   RETURN(-large);
 ELSIF x = 1.0 THEN
   RETURN(0.0);
 END;

 k := exponent(x);
 x := fraction(x);
#if (defined MM2)
 IF x < sqrt2o2 THEN
   x := scale(x, 1);
   DEC(k); (* damit Produkt x*2^k gleich bleibt *)
 END;
#else
 IF x > sqrt2 THEN
   x := scale(x, -1);
   INC(k); (* damit Produkt x*2^k gleich bleibt *)
 END;
#endif
 RETURN(RealSupport.real(VAL(SIGNED,k)) * ln2 + LOGE2701(x));
#ifndef MM2
 END;
#endif
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE sin ((* EIN/ -- *) x : REAL ): REAL;

VAR neg      : BOOLEAN;
    quadrant : UNSIGNEDWORD;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fsin.d x(a6),fp0
#else
   fsin.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,440EH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,540EH,0008H);
#else
   CODE(0F22EH,440EH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,440EH,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
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
#ifndef MM2
 END;
#endif
END sin;

(*---------------------------------------------------------------------------*)

PROCEDURE cos ((* EIN/ -- *) x : REAL ): REAL;

(* Extra Approximation statt sin(x + pi/2), damit die Genauigkeit
 * bei kleinen Argumenten erhalten bleibt.
 *)

VAR quadrant : UNSIGNEDWORD;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fcos.d x(a6),fp0
#else
   fcos.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,441DH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,541DH,0008H);
#else
   CODE(0F22EH,441DH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,441DH,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 x := trigon(ABS(x), FALSE, quadrant);

 IF (quadrant > 0) & (quadrant < 3) THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
#ifndef MM2
 END;
#endif
END cos;

(*---------------------------------------------------------------------------*)

PROCEDURE tan ((* EIN/ -- *) x : REAL ): REAL;

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
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   ftan.d x(a6),fp0
#else
   ftan.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,440FH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,540FH,0008H);
#else
   CODE(0F22EH,440FH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,440FH,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x > pi THEN
   x := RealSupport.fmod(x, pi);
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
     RAISEmathException(tanOverflow, "tan: argument is odd multiple of pi/2");
     IF neg THEN
       RETURN(-large);
     ELSE
       RETURN(large);
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
#ifndef MM2
 END;
#endif
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fasin.d x(a6),fp0
#else
   fasin.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,440CH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,540CH,0008H);
#else
   CODE(0F22EH,440CH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,440CH,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 RETURN(arcTrigon(x, arcsinArgMagnitude, "arcsin: |argument| > 1.0", TRUE));
#ifndef MM2
 END;
#endif
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   facos.d x(a6),fp0
#else
   facos.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,441CH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,541CH,0008H);
#else
   CODE(0F22EH,441CH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,441CH,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 RETURN(arcTrigon(x, arccosArgMagnitude, "arccos: |argument| > 1.0", FALSE));
#ifndef MM2
 END;
#endif
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan ((* EIN/ -- *) x : REAL ): REAL;

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
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fatan.d x(a6),fp0
#else
   fatan.s x(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,440AH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,540AH,0008H);
#else
   CODE(0F22EH,440AH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,440AH,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
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
#ifndef MM2
 END;
#endif
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE power ((* EIN/ -- *) base     : REAL;
                 (* EIN/ -- *) exponent : REAL ): REAL;

VAR neg   : BOOLEAN;
    whole : REAL;

BEGIN
 neg := FALSE;
 IF base <= 0.0 THEN
   IF base < 0.0 THEN
     IF RealSupport.modf(exponent, whole) # 0.0 THEN
       (* <Definitionsbereich> : -base^exponent, exponent nicht ganzzahlig *)
       RAISEmathException(nonpositivePowerArg,
                          "pow: base < 0, exponent has fraction");
       RETURN(0.0);
     ELSE
       base := -base;
       neg  := ODD(RealSupport.int(whole));
     END;
   ELSIF exponent <= 0.0 THEN
     (* <Definitionsbereich> : 0^0 oder 0^(-exponent) *)
     RAISEmathException(nonpositivePowerArg, "pow: base = 0, exponent <= 0");
     RETURN(0.0);
   ELSE (* 0^exponent *)
     RETURN(0.0);
   END;
 END;
 base := exp(exponent * ln(base));
 IF neg THEN
   RETURN(-base);
 ELSE
   RETURN(base);
 END;
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE round ((* EIN/ -- *) x : REAL ): SIGNED;

VAR e : INTEGER;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fmove.d x(a6),fp0
#else
   fmove.s x(a6),fp0
#endif
   fmove.l fpcr,d1     ; alten Rundungsmodus holen und sichern
;   moveq   #$ff-$30,d0 ; Rundungsmodus loeschen (= Rundung auf naechste Zahl)
   moveq   #-$31,d0    ; Rundungsmodus loeschen (= Rundung auf naechste Zahl)
   and.l   d1,d0       ;
   fmove.l d0,fpcr     ; neuen Rundungsmodus setzen
   fmove.l fp0,d0      ; nach LONGINT wandeln
   fmove.l d1,fpcr     ; alten Rundungsmodus wiederherstellen
#if (defined LPRM2) || (defined SPCM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4400H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5400H,0008H);
#else
   CODE(0F22EH,4400H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4400H,0008H);
#endif
   CODE(0F201H,0B000H);
   CODE(70CFH);
   CODE(0C081H);
   CODE(0F200H,9000H);
   CODE(0F200H,6000H);
   CODE(0F201H,9000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#ifdef MM2
 e := exponent(x);
#else
 e := exponent(x) + 1;
#endif
 IF e < 0 THEN
   RETURN(0);
 ELSIF e = 0 THEN
   IF x < -0.5 THEN
     RETURN(-1);
   ELSIF x > 0.5 THEN
     RETURN(1);
   ELSE
     RETURN(0);
   END;
 END;
#if (defined HM2) && (defined __LONG_REAL__)
 x := LowLong.round(x, e);
#else
 x := LowReal.round(x, e);
#endif
#if (defined MM2)
 RETURN(VAL(SIGNED,x));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(TRUNCD(LONG(x)));
#elif (defined HM2)
 IF x >= 0.0 THEN
   RETURN(VAL(SIGNED,TRUNC(x)));
 ELSE
   RETURN(-VAL(SIGNED,TRUNC(-x)));
 END;
#elif (defined TDIM2)
 IF x >= 0.0 THEN
   RETURN(SIGNED(TRUNCD(LONG(x))));
 ELSE
   RETURN(-SIGNED(TRUNCD(-LONG(x))));
 END;
#endif
(*
 RAISEmathException(roundArgMagnitude, "round: |argument| too big");
*)
#ifndef MM2
 END;
#endif
END round;

(*===========================================================================*)

BEGIN (* RealMath *)
#ifndef MM2
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
#endif
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.AllocateSource(realMathSource);
#endif
END RealMath.
