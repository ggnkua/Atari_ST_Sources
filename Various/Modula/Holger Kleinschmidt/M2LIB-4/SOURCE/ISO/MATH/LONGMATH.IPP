IMPLEMENTATION MODULE LongMath;
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
   1) LowLong.radix = 2, d.h. LowLong.scale multipliziert mit bzw. dividiert
      durch Zweierpotenzen.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

VAL_INTRINSIC
CAST_IMPORT
INLINE_CODE_IMPORT


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

IMPORT LowLong, LongSupport;

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

VAR
#ifndef MM2
  fpu     : FPUInfo;
  hasFpu  : BOOLEAN;
#endif
  expfact : ARRAY [0..15] OF LONGREAL;

#if LONGREAL_var
VAR
  null     : LONGREAL; (* 0.0 *)
  half     : LONGREAL; (* 0.5 *)
  one      : LONGREAL; (* 1.0 *)
  three    : LONGREAL; (* 3.0 *)
  six      : LONGREAL; (* 6.0 *)

  pio2     : LONGREAL; (* pi/2 *)
  pio4     : LONGREAL; (* pi/4 *)
  pi2      : LONGREAL; (* 2*pi *)

  sqrt2    : LONGREAL; (* 2^(1/2) *)
  sqrt2o2  : LONGREAL; (* 2^(1/2)/2 *)

  ln2      : LONGREAL; (* logE(2)  *)
  lde      : LONGREAL; (* log2(e)  *)

  tan1pio8 : LONGREAL; (* tan(pi/8) *)
  tan3pio8 : LONGREAL; (* tan(3*pi/8) *)
  sinpio6  : LONGREAL; (* sin(pi/6) *)
#else
CONST
  null     = LRC(0.0,0);
  half     = LRC(0.5,0);
  one      = LRC(1.0,0);
  three    = LRC(3.0,0);
  six      = LRC(6.0,0);

  pio2     = LRC(1.57079632679489661923132169163975144,0);  (* pi/2 *)
  pio4     = LRC(0.78539816339744830961566084581987572,0);  (* pi/4 *)
  pi2      = LRC(6.28318530717958647692528676655900576,0);  (* 2*pi *)

  sqrt2    = LRC(1.41421356237309504880168872420969808,0);  (* 2^(1/2) *)
  sqrt2o2  = LRC(0.70710678118654752440084436210484904,0);  (* 2^(1/2)/2 *)

  ln2      = LRC(0.69314718055994530941723212145817657,0);  (* logE(2)  *)
  lde      = LRC(1.44269504088896340735992468100189213,0);  (* log2(e)  *)

  tan1pio8 = LRC(0.41421356237309504880168872420969807,0);  (* tan(pi/8) *)
  tan3pio8 = LRC(2.41421356237309504880168872420969807,0);  (* tan(3*pi/8) *)
  sinpio6  = LRC(0.5,0);                                    (* sin(pi/6) *)
#endif

#if LONGREAL_var
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

VAR
  sinC  : RECORD P0, P1, P2, P3, Q0, Q1, Q2 : LONGREAL; END;
  cosC  : RECORD P0, P1, P2, P3, Q0, Q1, Q2 : LONGREAL; END;
  asinC : RECORD P0, P1, P2, P3, P4, Q0, Q1, Q2, Q3, Q4 : LONGREAL; END;
  sqrtC : RECORD P0, P1, P2 : LONGREAL; END;
  expC  : RECORD P0, P1, Q0 : LONGREAL; END;
  lnC   : RECORD P0, P1, P2, Q0, Q1, Q2 : LONGREAL; END;
  tanC  : RECORD P0, P1, P2, P3, Q0, Q1, Q2, Q3 : LONGREAL; END;
  atanC : RECORD P0, P1, P2, P3, P4, Q0, Q1, Q2, Q3 : LONGREAL; END;

  SeriesExpSIN    : LONGREAL;
  SeriesExpCOS    : LONGREAL;
  SeriesExpTAN    : LONGREAL;
  SeriesExpARCSIN : LONGREAL;
  SeriesExpARCTAN : LONGREAL;
#endif

#ifndef __NO_EXCEPTIONS__
VAR
  longMathSource : EXCEPTIONS.ExceptionSource;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE RAISEmathException ((* EIN/ -- *)     exc : MathExceptions;
                              (* EIN/ -- *) REF msg : ARRAY OF CHAR );

BEGIN
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.RAISE(longMathSource, ORD(exc), msg);
#endif
END RAISEmathException;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRMathException (): BOOLEAN;
BEGIN
#ifdef __NO_EXCEPTIONS__
 RETURN(FALSE);
#else
 RETURN(EXCEPTIONS.IsCurrentSource(longMathSource));
#endif
END IsRMathException;

(*---------------------------------------------------------------------------*)

PROCEDURE trigon ((* EIN/ -- *)     x        : LONGREAL;
                  (* EIN/ -- *)     sin      : BOOLEAN;
                  (* -- /AUS *) VAR quadrant : UNSIGNEDWORD ) : LONGREAL;
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
#if !LONGREAL_var
CONST SeriesExpSIN = LRC(4.0,-4); (* = sqrt(sqrt(120.0*Eps)) *)
      SeriesExpCOS = LRC(2.7,-4); (* = sqrt(sqrt(24.0*Eps))  *)
#endif
PROCEDURE SIN3063 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.59 Stellen auf [0, Pi/4] *)
#if !LONGREAL_var
CONST P0 =        LRC(0.206643433369958582409167054,+7);
      P1 = (* - *)LRC(0.18160398797407332550219213,+6);
      P2 =        LRC(0.359993069496361883172836,+4);
      P3 = (* - *)LRC(0.2010748329458861571949,+2);
      Q0 =        LRC(0.263106591026476989637710307,+7);
      Q1 =        LRC(0.3927024277464900030883986,+5);
      Q2 =        LRC(0.27811919481083844087953,+3);
#endif
VAR xSqr : LONGREAL;

BEGIN (* SIN3063 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH sinC DO
#endif
 RETURN(x *
         (((-P3 * xSqr + P2) * xSqr - P1) * xSqr + P0) /
         (((      xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
#if LONGREAL_var
 END;
#endif
END SIN3063;

PROCEDURE COS3843 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 16.18 Stellen auf [0, Pi/4] *)
#if !LONGREAL_var
CONST P0 =        LRC(0.12905394659037374438571854,+7);
      P1 = (* - *)LRC(0.3745670391572320471032359,+6);
      P2 =        LRC(0.134323009865390842853673,+5);
      P3 = (* - *)LRC(0.112314508233409330923,+3);
      Q0 =        LRC(0.12905394659037373590295914,+7);
      Q1 =        LRC(0.234677731072458350524124,+5);
      Q2 =        LRC(0.2096951819672630628621,+3);
#endif
VAR xSqr : LONGREAL;

BEGIN (* COS3843 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH cosC DO
#endif
 RETURN((((-P3 * xSqr + P2) * xSqr - P1) * xSqr + P0) /
        (((      xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
#if LONGREAL_var
 END;
#endif
END COS3843;

BEGIN (* trigon *)
 quadrant := 0;
 IF x > pi2 THEN
   x := LongSupport.fmod(x, pi2);
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
     RETURN(x - x * x * x / six);
   END;
 ELSIF x >= SeriesExpCOS THEN
   RETURN(COS3843(x / pio4));
 ELSE
   RETURN(one - LowLong.scale(x * x, -1));
 END;
END trigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *)     x    : LONGREAL;
                     (* EIN/ -- *)     exc  : MathExceptions;
                     (* EIN/ -- *) REF msg  : ARRAY OF CHAR;
                     (* EIN/ -- *)     asin : BOOLEAN        ): LONGREAL;

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
#if !LONGREAL_var
CONST SeriesExpARCSIN = LRC(2.3,-4); (* = sqrt(sqrt(40.0/3.0*Eps)) *)
#endif
VAR absX : LONGREAL;
    neg  : BOOLEAN;

PROCEDURE ARCSN4698 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
 (* 17.31 Stellen auf [-sin(Pi/6), sin(Pi/6)] *)
#if !LONGREAL_var
CONST P0 = (* - *)LRC(0.128282549997869277323243486,+4);
      P1 =        LRC(0.27058673264340643538462677,+4);
      P2 = (* - *)LRC(0.19037559157507792669596123,+4);
      P3 =        LRC(0.499087473518143347562346,+3);
      P4 = (* - *)LRC(0.36148645680347523002109,+2);
      Q0 = (* - *)LRC(0.12828254999786927795016574,+4);
      Q1 =        LRC(0.29196715764305175556632146,+4);
      Q2 = (* - *)LRC(0.22941559326579784210521634,+4);
      Q3 =        LRC(0.719740422953630342673276,+3);
      Q4 = (* - *)LRC(0.75411436441961707886768,+2);
#endif
VAR xSqr : LONGREAL;

BEGIN (* ARCSN4698 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH asinC DO
#endif
 RETURN(x *
         ((((       -P4  * xSqr + P3) * xSqr - P2) * xSqr + P1) * xSqr - P0) /
         (((((xSqr - Q4) * xSqr + Q3) * xSqr - Q2) * xSqr + Q1) * xSqr - Q0)
        );
#if LONGREAL_var
 END;
#endif
END ARCSN4698;

BEGIN (* arcTrigon *)
 absX := ABS(x);
 neg  := x < null;
 IF absX > one THEN
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
       RETURN(null);
     END;
   END;
 END;

 IF absX > sinpio6  THEN
   IF absX = one THEN
     x := null;
   ELSE
     (* Je naeher <absX> an 1.0 liegt, desto mehr niederwertige Stellen
      * fehlen dem Argument an Genauigkeit, was durch die Differenz
      * dann leider sichtbar wird.
      *)
     x := LowLong.scale(ARCSN4698(sqrt(LowLong.scale(one - absX, -1))), 1);
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
     x := x + x * x * x / six;
   END;
   IF asin THEN
     RETURN(x);
   ELSE
     RETURN(pio2 - x);
   END;
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
VAR e : SIGNEDWORD;
    i : UNSIGNEDWORD;
    y : LONGREAL;

PROCEDURE SQRT0071 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 2.30 Stellen auf [0.25, 1] *)
#if !LONGREAL_var
CONST P0 =        LRC(0.2592768763,0);
      P1 =        LRC(0.1052021187,1);
      P2 = (* - *)LRC(0.3163221431,0);
#endif
BEGIN (* SQRT0071 *)
#if LONGREAL_var
 WITH sqrtC DO
#endif
 RETURN((-P2 * x + P1) * x + P0);
#if LONGREAL_var
 END;
#endif
END SQRT0071;

BEGIN (* sqrt *)
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fsqrt.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5404H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5404H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5404H,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF x <= null THEN
   IF x < null THEN
     (* <Definitionsbereich> *)
     RAISEmathException(negativeSqrtArg, "sqrt: argument < 0.0");
     RETURN(null);
   END;
   RETURN(null);
 END;

#if (defined MM2)
 e := VAL(SIGNEDWORD,LowLong.exponent(x) + 1);
 x := LowLong.scale(LowLong.fraction(x), -1);
#else
 e := VAL(SIGNEDWORD,LowLong.exponent(x) + 2);
 x := LowLong.scale(LowLong.fraction(x), -2);
#endif
 (* 0.25 <= x < 0.5 *)

 IF ODD(e) THEN
   DEC(e);
   x := LowLong.scale(x, 1);
   (* 0.5 <= x < 1.0  *)
 END;
 (* 0.25 <= x < 1.0  *)

 y := SQRT0071(x);

 FOR i := 1 TO 3  DO
   (* 3 Iterationen: > 18 Stellen *)
   y := LowLong.scale(y + x / y, -1);
 END;

 IF e < 0 THEN
   e := -VAL(SIGNEDWORD,CAST(UNSIGNEDWORD,-e) DIV 2);
 ELSE
   e := e DIV 2;
 END;
 RETURN(LowLong.scale(y, e));
#ifndef MM2
 END;
#endif
END sqrt;

(*---------------------------------------------------------------------------*)

PROCEDURE exp ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
VAR fidx : SIGNEDWORD;
    n    : INTEGER;
    f    : LONGREAL;

PROCEDURE EXPB1121 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 16.35 Stellen auf [0, 1/16] *)
#if !LONGREAL_var
CONST P0 = LRC(0.72135034108448192083,+1);
      P1 = LRC(0.57761135831801928,-1);
      Q0 = LRC(0.208137711965230361973,+2);
#endif
VAR xSqr : LONGREAL;
    Px   : LONGREAL;
    Qx   : LONGREAL;

BEGIN (* EXPB1121 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH expC DO
#endif
 Px   := x * (xSqr * P1 + P0);
 Qx   :=      xSqr      + Q0;
#if LONGREAL_var
 END;
#endif
 RETURN((Qx + Px) / (Qx - Px));
END EXPB1121;

BEGIN (* exp *)
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fetox.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5410H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5410H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5410H,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF x = null THEN
   RETURN(one);
 END;
 x := x * lde;

 n    := VAL(INTEGER,LongSupport.int(x));
 f    := LowLong.scale(LowLong.fractpart(x), 4);   (* f mod 16; /1 *)
 fidx := VAL(SIGNEDWORD,LongSupport.int(f));
 f    := LowLong.scale(LowLong.fractpart(f), -4);  (* f mod 16; /2 *)

 IF fidx < 0 THEN
   RETURN(LowLong.scale(EXPB1121(f) / expfact[-fidx], n));
 ELSE
   RETURN(LowLong.scale(EXPB1121(f) * expfact[fidx], n));
 END;
#ifndef MM2
 END;
#endif
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST P0 = (* - *) LRC(0.90174691662040536328986,+2);
      P1 =         LRC(0.934639006428585382474,+2);
      P2 = (* - *) LRC(0.1832787037221593212,+2);
      Q0 = (* - *) LRC(0.45087345831020305748486,+2);
      Q1 =         LRC(0.61761065598471302843,+2);
      Q2 = (* - *) LRC(0.20733487895513939345,+2);
#endif
VAR xSqr : LONGREAL;

BEGIN (* LOGE2704 *)
 x    := (x - one) / (x + one);
 xSqr := x * x;
#if LONGREAL_var
 WITH lnC DO
#endif
 RETURN(x *
         ((       -P2  * xSqr + P1) * xSqr - P0) /
         (((xSqr - Q2) * xSqr + Q1) * xSqr - Q0)
        );
#if LONGREAL_var
 END;
#endif
END LOGE2704;

BEGIN (* ln *)
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   flogn.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5414H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5414H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5414H,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF x <= null THEN
   (* <Definitionsbereich> *)
   RAISEmathException(nonpositiveLogArg, "ln: argument <= 0.0");
   RETURN(-LowLong.large);
 ELSIF x = one THEN
   RETURN(null);
 END;

 k := LowLong.exponent(x);
 x := LowLong.fraction(x);
#if (defined MM2)
 IF x < sqrt2o2 THEN
   x := LowLong.scale(x, 1);
   DEC(k); (* damit Produkt x*2^k gleich bleibt *)
 END;
#else
 IF x > sqrt2 THEN
   x := LowLong.scale(x, -1);
   INC(k); (* damit Produkt x*2^k gleich bleibt *)
 END;
#endif
 RETURN(LongSupport.real(VAL(SIGNED,k)) * ln2 + LOGE2704(x));
#ifndef MM2
 END;
#endif
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE sin ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

VAR neg      : BOOLEAN;
    quadrant : UNSIGNEDWORD;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fsin.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,540EH,000CH);
#elif (defined HM2)
   CODE(0F22EH,540EH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,540EH,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 neg := x < null;
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

PROCEDURE cos ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fcos.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,541DH,000CH);
#elif (defined HM2)
   CODE(0F22EH,541DH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,541DH,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
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

PROCEDURE tan ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST SeriesExpTAN = LRC(2.0,-4); (* = sqrt(sqrt(7.5*Eps)) *)
#endif
VAR neg : BOOLEAN;

PROCEDURE TAN4286 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 19.94 Stellen auf [0, Pi/4] *)
#if !LONGREAL_var
CONST P0 =        LRC(0.1088860043728168752138857983,+8);
      P1 = (* - *)LRC(0.8958884400676804108729639541,+6);
      P2 =        LRC(0.1418985425276177838800394831,+5);
      P3 = (* - *)LRC(0.45649319438665631873961137,+2);
      Q0 =        LRC(0.1386379666356762916533913361,+8);
      Q1 = (* - *)LRC(0.399130951803516515044342794,+7);
      Q2 =        LRC(0.1353827128051190938289294872,+6);
      Q3 = (* - *)LRC(0.1014656190252885338754401947,+4);
#endif
VAR xSqr : LONGREAL;

BEGIN (* TAN4286 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH tanC DO
#endif
 RETURN(x *
         (((       -P3  * xSqr + P2) * xSqr - P1) * xSqr + P0) /
         ((((xSqr - Q3) * xSqr + Q2) * xSqr - Q1) * xSqr + Q0)
        );
#if LONGREAL_var
 END;
#endif
END TAN4286;

BEGIN (* tan *)
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   ftan.d  x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,540FH,000CH);
#elif (defined HM2)
   CODE(0F22EH,540FH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,540FH,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 neg := x < null;
 IF neg THEN
   x := -x;
 END;

 IF x > pi THEN
   x := LongSupport.fmod(x, pi);
 END;
 IF x > pio2 THEN
   x   := pi - x;
   neg := ~neg;
 END;
 IF x > pio4 THEN
   x := (pio2 - x) / pio4;
   IF x = null THEN
     (* <Polstelle> *)
     (* Da sich <x> und 'pio2' um minimal E-16 unterscheiden
      * koennen, kann es nicht zu einem Ueberlauf kommen, weil
      * <x> lediglich zu nahe an Pi/2 ist.
      *)
     RAISEmathException(tanOverflow, "tan: argument is odd multiple of pi/2");
     IF neg THEN
       RETURN(-LowLong.large);
     ELSE
       RETURN(LowLong.large);
     END;
   ELSE
     x := one / TAN4286(x);
   END;
 ELSIF x >= SeriesExpTAN  THEN
   x := TAN4286(x / pio4);
 ELSE
   x := x + x * x * x / three;
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

PROCEDURE arcsin ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fasin.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,540CH,000CH);
#elif (defined HM2)
   CODE(0F22EH,540CH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,540CH,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
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

PROCEDURE arccos ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   facos.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,541CH,000CH);
#elif (defined HM2)
   CODE(0F22EH,541CH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,541CH,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
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

PROCEDURE arctan ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST SeriesExpARCTAN = LRC(1.8,-4); (* = sqrt(sqrt(5.0*Eps)) *)
#endif
VAR neg : BOOLEAN;

PROCEDURE ARCTN5076 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.55 Stellen auf [0, tan(Pi/8)] *)
#if !LONGREAL_var
CONST P0 = LRC(0.445413400592906803197511,+2);
      P1 = LRC(0.77477687719204208616481,+2);
      P2 = LRC(0.40969264832102256374186,+2);
      P3 = LRC(0.666057901700926265753,+1);
      P4 = LRC(0.1589740288482307048,+0);
      Q0 = LRC(0.445413400592906804445995,+2);
      Q1 = LRC(0.92324801072300974840693,+2);
      Q2 = LRC(0.62835930511032376833267,+2);
      Q3 = LRC(0.1550397755142198752523,+2);
#endif
VAR xSqr : LONGREAL;

BEGIN (* ARCTN5076 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH atanC DO
#endif
 RETURN(x *
         ((((P4 * xSqr + P3) * xSqr + P2) * xSqr + P1) * xSqr + P0) /
         ((((     xSqr + Q3) * xSqr + Q2) * xSqr + Q1) * xSqr + Q0)
        );
#if LONGREAL_var
 END;
#endif
END ARCTN5076;

BEGIN (* arctan *)
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fatan.d x(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,540AH,000CH);
#elif (defined HM2)
   CODE(0F22EH,540AH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,540AH,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 neg := x < null;
 IF neg THEN
   x := -x;
 END;

 IF x >= tan3pio8 THEN
   x := pio2 - ARCTN5076(one / x);
 ELSIF x > tan1pio8 THEN
   x := pio4 + ARCTN5076((x - one) / (x + one));
 ELSIF x >= SeriesExpARCTAN THEN
   x := ARCTN5076(x);
 ELSE
   x := x - x * x * x / three;
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

PROCEDURE power ((* EIN/ -- *) base     : LONGREAL;
                 (* EIN/ -- *) exponent : LONGREAL ): LONGREAL;

VAR neg   : BOOLEAN;
    whole : LONGREAL;

BEGIN
 neg := FALSE;
 IF base <= null THEN
   IF base < null THEN
     IF LongSupport.modf(exponent, whole) # null THEN
       (* <Definitionsbereich> : -base^exponent, exponent nicht ganzzahlig *)
       RAISEmathException(nonpositivePowerArg,
                          "pow: base < 0, exponent has fraction");
       RETURN(null);
     ELSE
       base := -base;
       neg  := ODD(LongSupport.int(whole));
     END;
   ELSIF exponent <= null THEN
     (* <Definitionsbereich> : 0^0 oder 0^(-exponent) *)
     RAISEmathException(nonpositivePowerArg, "pow: base = 0, exponent <= 0");
     RETURN(null);
   ELSE (* 0^exponent *)
     RETURN(null);
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

PROCEDURE round ((* EIN/ -- *) x : LONGREAL ): SIGNED;

VAR e : INTEGER;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 8
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 8
#endif

   fmove.d x(a6),fp0
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
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5400H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5400H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5400H,0008H);
#endif
   CODE(0F201H,0B000H);
   CODE(70CFH);
   CODE(0C081H);
   CODE(0F200H,9000H);
   CODE(0F200H,6000H);
   CODE(0F201H,9000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#ifdef MM2
 e := LowLong.exponent(x);
#else
 e := LowLong.exponent(x) + 1;
#endif
 IF e < 0 THEN
   RETURN(0);
 ELSIF e = 0 THEN
#ifdef MM2
   IF x < -0.5 THEN
#else
   IF x < -half THEN
#endif
     RETURN(-1);
   ELSIF x > half THEN
     RETURN(1);
   ELSE
     RETURN(0);
   END;
 END;
 x := LowLong.round(x, e);
#if (defined MM2)
 RETURN(VAL(SIGNED,x));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(TRUNCD(x));
#elif (defined HM2)
 IF x >= null THEN
   RETURN(VAL(SIGNED,TRUNC(x)));
 ELSE
   RETURN(-VAL(SIGNED,TRUNC(-x)));
 END;
#elif (defined TDIM2)
 IF x >= null THEN
   RETURN(SIGNED(TRUNCD(x)));
 ELSE
   RETURN(-SIGNED(TRUNCD(-x)));
 END;
#endif
(*
 RAISEmathException(roundArgMagnitude, "round: |argument| too big");
*)
#ifndef MM2
 END;
#endif
END round;

#if LONGREAL_var
(*---------------------------------------------------------------------------*)

PROCEDURE init;
BEGIN
 WITH cast DO
   lc1 := 000000000H; lc2 := 000000000H; null  := lr;
   lc1 := 03FE00000H; (* wie oben *)     half  := lr;
   sinpio6 := half; (* 5.00000000000000E-1 *)
   lc1 := 03FF00000H; (* wie oben *)     one   := lr;
   expfact[0] := lr; (* 1.0000000000000E+0 *)
   lc1 := 040080000H; (* wie oben *)     three := lr;
   lc1 := 040180000H; (* wie oben *)     six   := lr;

   lc1 := 04005BF0AH; lc2 := 08B145768H; exp1 := lr; (* 2.71828182845904E+0 *)
   lc1 := 0400921FBH; lc2 := 054442D17H; pi   := lr; (* 3.14159265358979E+0 *)
   lc1 := 0401921FBH; (* wie oben *)     pi2  := lr; (* 6.28318530717958E+0 *)
   lc1 := 03FF921FBH; (* wie oben *)     pio2 := lr; (* 1.57079632679489E+0 *)
   lc1 := 03FE921FBH; (* wie oben *)     pio4 := lr; (* 7.85398163397447E-1 *)

   lc1 := 03FF6A09EH; lc2 := 0667F3BCBH; sqrt2   := lr; (* 1.41421356237309E+0 *)
   expfact[8] := lr; (* 1.4142135623731E+0 *)
   lc1 := 03FE6A09EH; (* wie oben *)     sqrt2o2 := lr; (* 7.07106781186544E-1 *)

   lc1 := 03FE62E42H; lc2 := 0FEFA39EFH; ln2  := lr; (* 6.93147180559944E-1 *)
   lc1 := 03FF71547H; lc2 := 0652B82FDH; lde  := lr; (* 1.44269504088896E+0 *)

   lc1 := 03FDA8279H; lc2 := 099FCEF31H; tan1pio8 := lr; (* 4.14213562373094E-1 *)
   lc1 := 04003504FH; lc2 := 0333F9DE5H; tan3pio8 := lr; (* 2.41421356237309E+0 *)

   lc1 := 03F3A36E2H; lc2 := 0EB1C432DH; SeriesExpSIN    := lr; (* 4.00000000000000E-4 *)
   lc1 := 03F2A36E2H; (* wie oben *)     SeriesExpTAN    := lr; (* 1.99999999999999E-4 *)
   lc1 := 03F31B1D9H; lc2 := 02B7FE08BH; SeriesExpCOS    := lr; (* 2.70000000000000E-4 *)
   lc1 := 03F2E2584H; lc2 := 0F4C6E6DAH; SeriesExpARCSIN := lr; (* 2.29999999999999E-4 *)
   lc1 := 03F2797CCH; lc2 := 039FFD60FH; SeriesExpARCTAN := lr; (* 1.79999999999999E-4 *)

   WITH sinC DO
     lc1 := 0413F8802H; lc2 := 0556D5606H; P0 := lr; (* 2.06643433369958E+6 *)
     lc1 := 041062B1FH; lc2 := 0E75EF371H; P1 := lr; (* 1.81603987974073E+5 *)
     lc1 := 040AC1FDCH; lc2 := 0840CDE96H; P2 := lr; (* 3.59993069496361E+3 *)
     lc1 := 040341B84H; lc2 := 006731FDAH; P3 := lr; (* 2.01074832945886E+1 *)
     lc1 := 0414412CCH; lc2 := 0F4838E54H; Q0 := lr; (* 2.63106591026477E+6 *)
     lc1 := 040E32CC7H; lc2 := 0C4CF5738H; Q1 := lr; (* 3.92702427746489E+4 *)
     lc1 := 0407161E8H; lc2 := 038D16677H; Q2 := lr; (* 2.78119194810838E+2 *)
   END;
   WITH cosC DO
     lc1 := 04133B12BH; lc2 := 0774577A3H; P0 := lr; (* 1.2905394659037E+6 *)
     lc1 := 04116DC9CH; lc2 := 02818D55BH; P1 := lr; (* 3.7456703915723E+5 *)
     lc1 := 040CA3C26H; lc2 := 086BA16F3H; P2 := lr; (* 1.3432300986539E+4 *)
     lc1 := 0405C1420H; lc2 := 0E7243435H; P3 := lr; (* 1.1231450823341E+2 *)
     lc1 := 04133B12BH; lc2 := 0774577A2H; Q0 := lr; (* 1.2905394659037E+6 *)
     lc1 := 040D6EAF1H; lc2 := 07A96D049H; Q1 := lr; (* 2.3467773107246E+4 *)
     lc1 := 0406A363EH; lc2 := 0EE40C53DH; Q2 := lr; (* 2.0969518196726E+2 *)
   END;
   WITH asinC DO
     lc1 := 040940B4DH; lc2 := 04FDDCD55H; P0 := lr; (* 1.28282549997869E+3 *)
     lc1 := 040A523BCH; lc2 := 01235DA85H; P1 := lr; (* 2.70586732643406E+3 *)
     lc1 := 0409DBF06H; lc2 := 00EC75083H; P2 := lr; (* 1.90375591575078E+3 *)
     lc1 := 0407F3166H; lc2 := 04AA1BB0FH; P3 := lr; (* 4.99087473518142E+2 *)
     lc1 := 040421306H; lc2 := 0D257E463H; P4 := lr; (* 3.61486456803475E+1 *)
     lc1 := 040940B4DH; lc2 := 04FDDCD55H; Q0 := lr; (* 1.28282549997869E+3 *)
     lc1 := 040A6CF57H; lc2 := 0D8DDABABH; Q1 := lr; (* 2.91967157643051E+3 *)
     lc1 := 040A1EC4FH; lc2 := 0D667C4CAH; Q2 := lr; (* 2.29415593265798E+3 *)
     lc1 := 040867DECH; lc2 := 062DE9865H; Q3 := lr; (* 7.19740422953627E+2 *)
     lc1 := 04052DA54H; lc2 := 0F983A6EBH; Q4 := lr; (* 7.54114364419616E+1 *)
   END;
   WITH sqrtC DO
     lc1 := 03FD097FEH; lc2 := 00A145288H; P0 := lr; (* 2.59276876300000E-1 *)
     lc1 := 03FF0D514H; lc2 := 02B0DD35AH; P1 := lr; (* 1.05202118699999E+0 *)
     lc1 := 03FD43E9FH; lc2 := 03AE75E52H; P2 := lr; (* 3.16322143099999E-1 *)
   END;
   WITH expC DO
     lc1 := 0401CDAA0H; lc2 := 0A35CA6DCH; P0 := lr; (* 7.2135034108448E+0 *)
     lc1 := 03FAD92DEH; lc2 := 01AC13AF6H; P1 := lr; (* 5.7761135831802E-2 *)
     lc1 := 04034D053H; lc2 := 04F237E44H; Q0 := lr; (* 2.0813771196523E+1 *)
   END;
   WITH lnC DO
     lc1 := 040568B2EH; lc2 := 025EFD644H; P0 := lr; (* 9.0174691662040E+1 *)
     lc1 := 040575DB0H; lc2 := 08C526AECH; P1 := lr; (* 9.3463900642858E+1 *)
     lc1 := 0403253EFH; lc2 := 0500DFEA9H; P2 := lr; (* 1.8327870372216E+1 *)
     lc1 := 040468B2EH; lc2 := 025EFD649H; Q0 := lr; (* 4.5087345831020E+1 *)
     lc1 := 0404EE16AH; lc2 := 098F7C5BFH; Q1 := lr; (* 6.1761065598471E+1 *)
     lc1 := 04034BBC5H; lc2 := 0DCDB3E85H; Q2 := lr; (* 2.0733487895514E+1 *)
   END;
   WITH tanC DO
     lc1 := 04164C4B3H; lc2 := 00DFE3629H; P0 := lr; (* 1.08886004372817E+7 *)
     lc1 := 0412B5720H; lc2 := 0E1508D0EH; P1 := lr; (* 8.95888440067678E+5 *)
     lc1 := 040CBB6EDH; lc2 := 058278D2DH; P2 := lr; (* 1.41898542527618E+4 *)
     lc1 := 04046D31CH; lc2 := 0E63CDCECH; P3 := lr; (* 4.56493194386654E+1 *)
     lc1 := 0416A716EH; lc2 := 0953BF22DH; Q0 := lr; (* 1.38637966635676E+7 *)
     lc1 := 0414E7386H; lc2 := 0C24EF9EDH; Q1 := lr; (* 3.99130951803516E+6 *)
     lc1 := 0410086B5H; lc2 := 0B3D32B97H; Q2 := lr; (* 1.35382712805119E+5 *)
     lc1 := 0408FB53FH; lc2 := 0E0ACE0C3H; Q3 := lr; (* 1.01465619025288E+3 *)
   END;
   WITH atanC DO
     lc1 := 04046454AH; lc2 := 0A18D5587H; P0 := lr; (* 4.4541340059291E+1 *)
     lc1 := 040535E92H; lc2 := 06F82EBB4H; P1 := lr; (* 7.7477687719204E+1 *)
     lc1 := 040447C10H; lc2 := 0DEB98564H; P2 := lr; (* 4.0969264832102E+1 *)
     lc1 := 0401AA46EH; lc2 := 0D369EA18H; P3 := lr; (* 6.6605790170092E+0 *)
     lc1 := 03FC45942H; lc2 := 0CF688371H; P4 := lr; (* 1.5897402884823E-1 *)
     lc1 := 04046454AH; lc2 := 0A18D5587H; Q0 := lr; (* 4.4541340059291E+1 *)
     lc1 := 0405714C9H; lc2 := 08A6FCF41H; Q1 := lr; (* 9.2324801072301E+1 *)
     lc1 := 0404F6AFFH; lc2 := 0C55F4E69H; Q2 := lr; (* 6.2835930511032E+1 *)
     lc1 := 0402F0209H; lc2 := 0587A8D1AH; Q3 := lr; (* 1.5503977551422E+1 *)
   END;
   lc1 := 03FF0B558H; lc2 := 06CF9890FH; expfact[ 1] := lr; (* 1.0442737824274E+0 *)
   lc1 := 03FF172B8H; lc2 := 03C7D517AH; expfact[ 2] := lr; (* 1.0905077326653E+0 *)
   lc1 := 03FF2387AH; lc2 := 06E756237H; expfact[ 3] := lr; (* 1.1387886347567E+0 *)
   lc1 := 03FF306FEH; lc2 := 00A31B714H; expfact[ 4] := lr; (* 1.1892071150027E+0 *)
   lc1 := 03FF3DEA6H; lc2 := 04C123421H; expfact[ 5] := lr; (* 1.2418578120735E+0 *)
   lc1 := 03FF4BFDAH; lc2 := 0D5362A26H; expfact[ 6] := lr; (* 1.2968395546510E+0 *)
   lc1 := 03FF5AB07H; lc2 := 0DD485428H; expfact[ 7] := lr; (* 1.3542555469369E+0 *)
   lc1 := 03FF7A114H; lc2 := 073EB0185H; expfact[ 9] := lr; (* 1.4768261459395E+0 *)
   lc1 := 03FF8ACE5H; lc2 := 0422AA0DAH; expfact[10] := lr; (* 1.5422108254079E+0 *)
   lc1 := 03FF9C491H; lc2 := 082A3F08EH; expfact[11] := lr; (* 1.6104903319492E+0 *)
   lc1 := 03FFAE89FH; lc2 := 0995AD3ACH; expfact[12] := lr; (* 1.6817928305074E+0 *)
   lc1 := 03FFC199BH; lc2 := 0DD85529BH; expfact[13] := lr; (* 1.7562521603733E+0 *)
   lc1 := 03FFD5818H; lc2 := 0DCFBA485H; expfact[14] := lr; (* 1.8340080864093E+0 *)
   lc1 := 03FFEA4AFH; lc2 := 0A2A490D7H; expfact[15] := lr; (* 1.9152065613971E+0 *)
 END;
END init;
#endif

(*===========================================================================*)

BEGIN (* LongMath *)
#ifndef MM2
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
#endif
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.AllocateSource(longMathSource);
#endif
#if LONGREAL_var
 init;
#else
 (* 2^(0/16) .. 2^(15/16)
  *
  * Mit CLISP berechnet:
  *
  * (setf (long-float-digits) 96)
  * (with-open-file (out "expo.out" :direction :output)
  *   (dotimes (i 16) (print (expt 2.0l0 (/ i 16)) out)))
  *)
 expfact[ 0] := LRC(1.0,0);
 expfact[ 1] := LRC(1.04427378242741384032196647874,0);
 expfact[ 2] := LRC(1.09050773266525765920701065575,0);
 expfact[ 3] := LRC(1.13878863475669165370383028382,0);
 expfact[ 4] := LRC(1.18920711500272106671749997056,0);
 expfact[ 5] := LRC(1.2418578120734840485936774687,0);
 expfact[ 6] := LRC(1.29683955465100966593375411774,0);
 expfact[ 7] := LRC(1.3542555469368927282980147401,0);
 expfact[ 8] := LRC(1.4142135623730950488016887242,0);
 expfact[ 9] := LRC(1.47682614593949931138690748031,0);
 expfact[10] := LRC(1.542210825407940823612291862,0);
 expfact[11] := LRC(1.61049033194925430817952066727,0);
 expfact[12] := LRC(1.68179283050742908606225095245,0);
 expfact[13] := LRC(1.75625216037329948311216061926,0);
 expfact[14] := LRC(1.83400808640934246348708318943,0);
 expfact[15] := LRC(1.91520656139714729387261127015,0);
#endif
END LongMath.
