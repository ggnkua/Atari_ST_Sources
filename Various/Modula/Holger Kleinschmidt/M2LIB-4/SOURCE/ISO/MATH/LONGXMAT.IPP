IMPLEMENTATION MODULE LongXMath;
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
(* 29-Jul-96, Holger Kleinschmidt                                            *)
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

#ifndef __NO_EXCEPTIONS__
IMPORT EXCEPTIONS;
#endif
#ifndef MM2
FROM DosSystem IMPORT
(* TYPE *) FPUInfo, FPUFlag, FPUType,
(* PROC *) GetFPU;
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, SIGNEDWORD, UNSIGNEDWORD;

IMPORT LowLong, LongSupport, LongMath;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  MathExceptions = (
    nonpositiveLogArg,   (* x    <= 0 *)
    nonpositiveLogBase,  (* base <= 0 *)
    nonpositivePowerArg, (* base <= 0 *)
    arccoshArgMagnitude, (* x    <  1 *)
    arctanhArgMagnitude, (* |x|  >= 1 *)
    zeroPhaseArg         (* x = y = 0 *)
  );

#ifndef MM2
VAR
  fpu     : FPUInfo;
  hasFpu  : BOOLEAN;
#endif

#if LONGREAL_var
VAR
  null       : LONGREAL; (* 0.0 *)
  nullnull75 : LONGREAL; (* 0.075 *)
  null2      : LONGREAL; (* 0.2 *)
  half       : LONGREAL; (* 0.5 *)
  one        : LONGREAL; (* 1.0 *)
  two        : LONGREAL; (* 2.0 *)
  three      : LONGREAL; (* 3.0 *)
  six        : LONGREAL; (* 6.0 *)
  fifteen    : LONGREAL; (* 15.0 *)
  twentyfour : LONGREAL; (* 24.0 *)
  sixty      : LONGREAL; (* 60.0 *)
  ln10       : LONGREAL; (* logE(10) *)
  lge        : LONGREAL; (* log10(e) *)
  pi         : LONGREAL; (* pi *)
  pi2        : LONGREAL; (* 2*pi *)
  pio2       : LONGREAL; (* pi/2 *)
  pio180     : LONGREAL; (* pi/180 *)
  pio648000  : LONGREAL; (* pi/64800 *)
#else
CONST
  null       = LRC(0.0,0);
  nullnull75 = LRC(0.075,0);
  null2      = LRC(0.2,0);
  half       = LRC(0.5,0);
  one        = LRC(1.0,0);
  two        = LRC(2.0,0);
  three      = LRC(3.0,0);
  six        = LRC(6.0,0);
  fifteen    = LRC(15.0,0);
  twentyfour = LRC(24.0,0);
  sixty      = LRC(6.0,1);
  ln10       = LRC(2.30258509299404568401799145468436421,0); (* logE(10) *)
  lge        = LRC(4.3429448190325182765112891891660508,-1); (* log10(e) *)
  pi         = LRC(3.14159265358979323846264338327950288,0); (* pi *)
  pi2        = LRC(6.28318530717958647692528676655900576,0); (* 2*pi *)
  pio2       = LRC(1.57079632679489661923132169163975144,0); (* pi/2 *)
  pio180     = LRC(1.745329251994329576923690768488612,-2);  (* pi/180 *)
  pio648000  = LRC(4.848136811095359935899141023579,-6);     (* pi/648000 *)
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

  cbrtC : RECORD P0, P1, P2, P3 : LONGREAL; END;
  sinhC : RECORD P0, P1, P2, P3, P4, Q0 : LONGREAL; END;
  exp1C : RECORD P0, P1, Q0, Q1 : LONGREAL; END;

  SeriesExpSINH    : LONGREAL;
  SeriesExpCOSH    : LONGREAL;
  SeriesExpTANH    : LONGREAL;
  SeriesExpARCSINH : LONGREAL;
  SeriesExpARCTANH : LONGREAL;

  MAXfullSINH     : LONGREAL;
  MAXaprxSINH     : LONGREAL;
  MAXfullCOSH     : LONGREAL;
  MAXfullTANH     : LONGREAL;
  MAXaprxTANH     : LONGREAL;
  MAXfullARCSINH  : LONGREAL;
  MAXfullARCCOSH  : LONGREAL;
#endif

#ifndef __NO_EXCEPTIONS__
VAR
  longXMathSource : EXCEPTIONS.ExceptionSource;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE RAISEmathException ((* EIN/ -- *)     exc : MathExceptions;
                              (* EIN/ -- *) REF msg : ARRAY OF CHAR );

BEGIN
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.RAISE(longXMathSource, ORD(exc), msg);
#endif
END RAISEmathException;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRXMathException (): BOOLEAN;
BEGIN
#ifdef __NO_EXCEPTIONS__
 RETURN(FALSE);
#else
 RETURN(EXCEPTIONS.IsCurrentSource(longXMathSource));
#endif
END IsRXMathException;

(*---------------------------------------------------------------------------*)

PROCEDURE cbrt ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

(* Kubikwurzel
 * -> Negatives Argument beruecksichtigen:
 *
 *      cbrt(-x) = -cbrt(|x|)
 *
 * -> Trennen von Mantisse 'm' und Exponent 'e' aus x = m * 2^e
 *    Anpassung der Mantisse je nach Exponent
 *
 *    e mod 3 = 0:
 *
 *      cbrt(x) = cbrt(m * 2^(3k)) = 2^k * cbrt(m),
 *
 *      mit: e = 3k; k = e / 3
 *
 *    e mod 3 = 1:
 *
 *      cbrt(x) = cbrt(m * 2^(3k + 1)) = 2^k * cbrt(2 * m),
 *
 *      mit: e = 3k + 1; k = (e - 1) / 3
 *
 *    e mod 3 = 2:
 *
 *      cbrt(x) = cbrt(m * 2^(3k + 2)) = 2^k * cbrt(4 * m),
 *
 *      mit: e = 3k + 2; k = (e - 2) / 3
 *
 *    ([Hart68], 6.1.4)
 *
 *    Mit / ist der ISO-Teilungsoperator fuer ganze Zahlen gemeint;
 *    Nicht-ISO-Compiler benutzen dafuer DIV, der aber bei ISO-Compilern
 *    andere Werte fuer (ungerade) negative Zahlen liefert.
 *
 * -> initiale Approximation der Mantisse auf zwei Stellen Genauigkeit
 *    mit Polynom
 *
 *    Da die Approximation den gesamten Bereich vom kleinsten Wert von m
 *    bis zum groessten Wert von 4*m umfassen muss, wird die Mantisse
 *    auf den untersten Bereich des Approximationsintervalls transformiert,
 *    bevor sie evtl. mit Zwei oder Vier multipliziert wird.
 *
 * -> drei Iterationen der Mantisse nach Newton, da jede Iteration die
 *    Genauigkeit mindestens verdoppelt:
 *
 *                        f(y{n})
 *        y{n+1} = y{n} - --------    , f(y) = y^3 - x
 *                        f`(y{n})
 *
 *
 *                 1               x
 *    =>  y{n+1} = - * ( 2y{n} + ------  )
 *                 3             y^2{n}
 *
 *    ([Hart68], 6.1.5, 6.1.9, 6.1.10, TABLE 6.2)
 *
 *
 * Alternativ koennte der ungerade Exponent auch erst nach Berechnung der
 * Mantisse beruecksichtigt werden:
 *
 *     cbrt(x*2^(3k))   = cbrt(x) * 2^k
 *     cbrt(x*2^(3k+1)) = cbrt(x) * 2^k * 2^(sign(k)*1/3)
 *     cbrt(x*2^(3k+2)) = cbrt(x) * 2^k * 4^(sign(k)*1/3)
 *
 *  Vorteil: Es kann eine initiale Approximation fuer ein kleineres
 *           Intervall gewaehlt werden, was etwas Geschwindigkeit bringt,
 *           da sich der Grad des Polynoms um Eins verringert.
 * Nachteil: Durch die nachtraegliche Multiplikation mit einem "krummen"
 *           Wert kann sich die hohe Genauigkeit des Ergebnisses geringfuegig
 *           verschlechtern.
 *)
VAR e     : SIGNEDWORD;
    i     : UNSIGNEDWORD;
    y     : LONGREAL;
    neg   : BOOLEAN;
    range : UNSIGNEDWORD;

PROCEDURE CBRT0562 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 2.29 Stellen auf [0.125, 1] *)
#if !LONGREAL_var
CONST P0 =        LRC(0.3408412,0);
      P1 =        LRC(0.14581194,1);
      P2 = (* - *)LRC(0.13859389,1);
      P3 =        LRC(0.59219321,0);
#endif

BEGIN (* CBRT0562 *)
#if LONGREAL_var
 WITH cbrtC DO
#endif
 RETURN(((P3 * x - P2) * x + P1) * x + P0);
#if LONGREAL_var
 END;
#endif
END CBRT0562;

BEGIN (* cbrt *)
 neg := FALSE;
 IF x <= null THEN
   IF x = null THEN
     RETURN(null);
   END;
   x   := -x;
   neg := TRUE;
 END;

#if (defined MM2)
 e := VAL(SIGNEDWORD,LowLong.exponent(x) + 2);
 x := LowLong.scale(LowLong.fraction(x), -2);
#else
 e := VAL(SIGNEDWORD,LowLong.exponent(x) + 3);
 x := LowLong.scale(LowLong.fraction(x), -3);
#endif
 (* 0.125 <= x < 0.25 *)

 range := ABS(e) MOD 3;
 IF range = 1 THEN
   DEC(e);
   x := LowLong.scale(x, 1);
   (* 0.25 <= x < 0.5  *)
 ELSIF range = 2 THEN
   DEC(e, 2);
   x := LowLong.scale(x, 2);
   (* 0.5 <= x < 1.0  *)
 END;
 (* 0.125 <= x < 1.0 *)

 y := CBRT0562(x);

 FOR i := 1 TO 3  DO
   (* 3 Iterationen: > 18 Stellen *)
   y := (LowLong.scale(y, 1) + x / (y * y)) / three;
 END;

 IF neg THEN
   y := -y;
 END;

 IF e < 0 THEN
   e := -VAL(SIGNEDWORD,CAST(UNSIGNEDWORD,-e) DIV 3);
 ELSE
   e := e DIV 3;
 END;
 RETURN(LowLong.scale(y, e));
END cbrt;

(*---------------------------------------------------------------------------*)

PROCEDURE hypot ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) y : LONGREAL ): LONGREAL;

(*                  __________
 *   hypot(x,y) = \/ x^2 + y^2
 *
 * Hierbei kann es leicht zum Ueberlauf kommen, obwohl das Ergebnis nicht
 * zu gross ist. Durch eine kleine Umformung laesst sich das vermeiden:
 *
 *   hmin := min(|x|,|y|)
 *   hmax := max(|x|,|y|)
 *
 *                  _________________
 *   hypot(x,y) = \/ hmax^2 + hmin^2
 *
 *                    ______________________
 *                   /              hmin^2
 *              =   / hmax^2 * (1 + ------)
 *                \/                hmax^2
 *
 *                           ___________
 *                          /    hmin^2
 *              = hmax *   / 1 + ------    , hmax # 0
 *                       \/      hmax^2
 *
 * [Eng88], S.283
 *)

VAR hmax : LONGREAL;
    hmin : LONGREAL;
    tmp  : LONGREAL;

BEGIN
 hmax := ABS(x);
 hmin := ABS(y);
 IF hmin > hmax THEN
   tmp  := hmax;
   hmax := hmin;
   hmin := tmp;
 END;
 IF hmax = null THEN
   RETURN(null);
 ELSE
   hmin := hmin / hmax;
   RETURN(hmax * LongMath.sqrt(one + hmin * hmin));
 END;
END hypot;

(*---------------------------------------------------------------------------*)

PROCEDURE exp10 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
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

   ftentox.d x(a6),fp0
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
   CODE(0F22EH,5412H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5412H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5412H,0008H);
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
 RETURN(LongMath.exp(x * ln10));
#ifndef MM2
 END;
#endif
END exp10;

(*---------------------------------------------------------------------------*)

PROCEDURE powI ((* EIN/ -- *) base : LONGREAL;
                (* EIN/ -- *) exp  : INTEGER ): LONGREAL;

VAR res    : LONGREAL;
    negExp : BOOLEAN;

BEGIN
 IF (exp <= 0) & (base = null) THEN
   (* <Definitionsbereich> : 0^0 oder 0^(-exp) *)
   RAISEmathException(nonpositivePowerArg, "powI: base = 0, exp <= 0");
   RETURN(null);
 END;
 IF exp < 0 THEN
   IF exp # MIN(INTEGER) THEN
     exp := -exp;
   END;
   negExp := TRUE;
 ELSE
   negExp := FALSE;
 END;

 res := one;
 LOOP
   IF ODD(exp) THEN
     res := res * base;
   END;

   exp := CAST(CARDINAL,exp) DIV 2;

   (* Durch die LOOP-Schleife mit der Moeglichkeit eines
    * "Ausstiegs mittendrin" statt einer WHILE-Schleife
    * wird ein Ueberlauf bei der folgenden Multiplikation
    * verhindert, falls schon alles berechnet wurde.
    *)
   IF exp = 0 THEN
     EXIT;
   END;

   base := base * base;
 END; (* LOOP *)

 IF negExp THEN
   RETURN(one / res);
 ELSE
   RETURN(res);
 END;
END powI;

(*---------------------------------------------------------------------------*)

PROCEDURE log10 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
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

   flog10.d x(a6),fp0
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
   CODE(0F22EH,5415H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5415H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5415H,0008H);
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
   RAISEmathException(nonpositiveLogArg, "log10: argument <= 0.0");
   RETURN(-LowLong.large);
 ELSIF x = one THEN
   RETURN(null);
 END;
 RETURN(LongMath.ln(x) * lge);
#ifndef MM2
 END;
#endif
END log10;

(*---------------------------------------------------------------------------*)

PROCEDURE log ((* EIN/ -- *) x    : LONGREAL;
               (* EIN/ -- *) base : LONGREAL ): LONGREAL;
(* [Hart68], 6.3.3 *)
BEGIN
 IF base <= null THEN
   (* <Definitionsbereich> *)
   RAISEmathException(nonpositiveLogBase, "log: base <= 0.0");
   RETURN(null);
 END;
 IF x <= null THEN
   (* <Definitionsbereich> *)
   RAISEmathException(nonpositiveLogArg, "log: argument <= 0.0");
   RETURN(-LowLong.large);
 ELSIF x = one THEN
   RETURN(null);
 END;
 RETURN(LongMath.ln(x) / LongMath.ln(base));
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan2 ((* EIN/ -- *) y : LONGREAL;
                   (* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
 IF x = null THEN
   IF y = null THEN
     RAISEmathException(zeroPhaseArg, "arctan2: x = 0, y = 0");
     RETURN(null);
   ELSIF y < null THEN
     RETURN(-pio2);
   ELSE
     RETURN(pio2);
   END;
 ELSIF ABS(x) < ABS(y) THEN
   angle := LongMath.arctan(x / y);
   IF y < null THEN
     RETURN(-(pio2 + angle));  (* VI, VII *)
   ELSE
     RETURN(pio2 - angle);   (* II, III *)
   END;
 ELSE
   angle := LongMath.arctan(y / x);
   IF x < null THEN
     IF y < null THEN
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

PROCEDURE rectToPol ((* EIN/ -- *)     x      : LONGREAL;
                     (* EIN/ -- *)     y      : LONGREAL;
                     (* -- /AUS *) VAR radius : LONGREAL;
                     (* -- /AUS *) VAR angle  : LONGREAL );
(* [Hart68], 6.5.5 *)
BEGIN
 radius := hypot(x, y);
 angle  := arctan2(y, x);
 IF angle < null THEN
   angle := angle + pi2;
 END;
END rectToPol;

(*---------------------------------------------------------------------------*)

PROCEDURE polToRect ((* EIN/ -- *)     radius : LONGREAL;
                     (* EIN/ -- *)     angle  : LONGREAL;
                     (* -- /AUS *) VAR x      : LONGREAL;
                     (* -- /AUS *) VAR y      : LONGREAL );
(* [Hart68], 6.5.4, [Abram70], 3.7.2 *)
BEGIN
 x := radius * LongMath.cos(angle);
 y := radius * LongMath.sin(angle);
END polToRect;

(*---------------------------------------------------------------------------*)

PROCEDURE degToRad ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* [Hart68], 6.4.31 *)
BEGIN
 RETURN(x * pio180);
END degToRad;

(*---------------------------------------------------------------------------*)

PROCEDURE radToDeg ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
 RETURN(x / pio180);
END radToDeg;

(*---------------------------------------------------------------------------*)

PROCEDURE secToRad ((* EIN/ -- *) deg : CARDINAL;
                    (* EIN/ -- *) min : CARDINAL;
                    (* EIN/ -- *) sec : LONGREAL ): LONGREAL;
(* [Hart68], 6.4.30 *)
BEGIN
 RETURN((LongSupport.float(VAL(UNSIGNED,(deg * 60 + min) * 60)) + sec) * pio648000);
END secToRad;

(*---------------------------------------------------------------------------*)

PROCEDURE radToSec ((* EIN/ -- *)     rad : LONGREAL;
                    (* -- /AUS *) VAR deg : CARDINAL;
                    (* -- /AUS *) VAR min : CARDINAL;
                    (* -- /AUS *) VAR sec : LONGREAL );

VAR wrad : CARDINAL;

BEGIN
 rad  := rad / pio648000;
 sec  := LongSupport.fmod(rad, sixty);
 wrad := VAL(CARDINAL,LongSupport.trunc(rad / sixty));
 min  := wrad MOD 60;
 deg  := wrad DIV 60;
END radToSec;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST
  MAXfullSINH   = LRC(20.0,0);
  MAXaprxSINH   = LRC(0.5,0);
  SeriesExpSINH = LRC(4.0,-4); (* = sqrt(sqrt(120.0*Eps)) *)
#endif
VAR neg : BOOLEAN;

PROCEDURE SINH2028 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* 17.10 Stellen auf [0, 1/2] *)
#if !LONGREAL_var
CONST P0 = (* - *)LRC(0.1102208280604367809653,+3);
      P1 = (* - *)LRC(0.1737013801007254553629,+2);
      P2 = (* - *)LRC(0.7518402338487383016651,0);
      P3 = (* - *)LRC(0.1353587838210377975368,-1);
      P4 = (* - *)LRC(0.105327911468759765298,-3);
      Q0 = (* - *)LRC(0.1102208280604367800981,+3);
#endif
VAR xSqr : LONGREAL;

BEGIN (* SINH2028 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH sinhC DO
#endif
 RETURN(x *
         ((((-P4 * xSqr - P3) * xSqr - P2) * xSqr - P1) * xSqr - P0) /
         (                                                xSqr - Q0)
        );
#if LONGREAL_var
 END;
#endif
END SINH2028;

BEGIN (* sinh *)
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

   fsinh.d x(a6),fp0
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
   CODE(0F22EH,5402H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5402H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5402H,0008H);
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

 IF x > MAXfullSINH THEN
   x := LowLong.scale(LongMath.exp(x), -1);
 ELSIF x > MAXaprxSINH THEN
   x := LongMath.exp(x);
   x := LowLong.scale(x, -1) - one / LowLong.scale(x, 1);
 ELSIF x >= SeriesExpSINH THEN
   x := SINH2028(x);
 ELSE
   x := x + x * x * x / six;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
#ifndef MM2
 END;
#endif
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST
  MAXfullCOSH   = LRC(20.0,0);
  SeriesExpCOSH = LRC(7.3,-3); (* = cbrt(sqrt(720.0*Eps)) *)
#endif
VAR xSqr: LONGREAL;

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

   fcosh.d x(a6),fp0
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
   CODE(0F22EH,5419H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5419H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5419H,0008H);
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
 x := ABS(x);
 IF x > MAXfullCOSH THEN
   RETURN(LowLong.scale(LongMath.exp(x), -1));
 ELSIF x >= SeriesExpCOSH THEN
   x := LongMath.exp(x);
   RETURN(LowLong.scale(x, -1) + one / LowLong.scale(x, 1));
 ELSE
   xSqr := x * x;
   RETURN(one + LowLong.scale(xSqr, -1) + xSqr * xSqr / twentyfour);
 END;
#ifndef MM2
 END;
#endif
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST
  MAXfullTANH   = LRC(22.0,0);
  MAXaprxTANH   = LRC(0.1,0);
  SeriesExpTANH = LRC(4.0,-3); (* = cbrt(sqrt(315.0/17.0*Eps)) *)
#endif
VAR neg  : BOOLEAN;
    y    : LONGREAL;
    xSqr : LONGREAL;
    xCub : LONGREAL;

PROCEDURE EXPEC1801 ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
(* e^x - 1, 17.49 Stellen auf [0, 0.1] *)
#if !LONGREAL_var
CONST P0 = LRC(0.8400668525364832394067033,+3);
      P1 = LRC(0.2000111415899645689354,+2);
      Q0 = LRC(0.16801337050729664841446817,+4);
      Q1 = LRC(0.18001337040739002280539,+3);
#endif
VAR xSqr, Px : LONGREAL;

BEGIN (* EXPEC1801 *)
 xSqr := x * x;
#if LONGREAL_var
 WITH exp1C DO
#endif
 Px   := x * (P1 * xSqr + P0 );

 RETURN(LowLong.scale(Px, 1) / ((xSqr + Q1) * xSqr + Q0  - Px));
#if LONGREAL_var
 END;
#endif
END EXPEC1801;

BEGIN (* tanh *)
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

   ftanh.d x(a6),fp0
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
   CODE(0F22EH,5409H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5409H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5409H,0008H);
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

 IF x > MAXfullTANH THEN
   x := one;
 ELSIF x > MAXaprxTANH THEN
   x := LongMath.exp(x);
   y := one / x;
   x := (x - y) / (x + y);
 ELSIF x >= SeriesExpTANH THEN
   x := EXPEC1801(LowLong.scale(x, 1));
   x := x / (two + x);
 ELSE
   xSqr := x * x;
   xCub := x * xSqr;
   x    := x - xCub / three + LowLong.scale(xSqr * xCub, 1) / fifteen;
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
#ifndef MM2
 END;
#endif
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
 * -> Fuer kleine Argumente naehert sich der Ausdruck dem Term ln(1 + x), der
 *    sich wiederum x naehert. Da die gueltige Stellenzahl von x durch die
 *    Addition mit einer gegenueber x sehr grossen Zahl sinkt, werden die
 *    ersten drei Glieder der Taylor-Reihenentwicklung genommen:
 *
 *                           x^3     3*x^5
 *      arcsinh(x)  =  x  -  ---  +  -----  +  O(x^7)  ,  x < SeriesExpARCSINH
 *                            6        40
 *
 *      ([Bron87], Tab. 1.1.3.2.)
 *)
#if !LONGREAL_var
CONST
  MAXfullARCSINH   = LRC(5.0,9);
  SeriesExpARCSINH = LRC(4.2,-3); (* = cbrt(sqrt(28.0*Eps)) *)
#endif
VAR neg  : BOOLEAN;
    xSqr : LONGREAL;
    xCub : LONGREAL;

BEGIN
 neg := x < null;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXfullARCSINH THEN
   x := LongMath.ln(LowLong.scale(x, 1));
 ELSIF x >= SeriesExpARCSINH THEN
   x := LongMath.ln(x + LongMath.sqrt(x * x + one));
 ELSE
   xSqr := x * x;
   xCub := xSqr * x;
   x    := x - xCub / six + nullnull75 * xCub * xSqr
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST
  MAXfullARCCOSH = LRC(5.0,9);
#endif
BEGIN
 IF x < one THEN
   (* <Definitionsbereich> *)
   RAISEmathException(arccoshArgMagnitude, "arccosh: argument < 1.0");
   RETURN(null);
 ELSIF x > MAXfullARCCOSH THEN
   RETURN(LongMath.ln(LowLong.scale(x, 1)));
 ELSE
   RETURN(LongMath.ln(x + LongMath.sqrt(x * x - one)));
 END;
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh ((* EIN/ -- *) x : LONGREAL ): LONGREAL;

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
#if !LONGREAL_var
CONST
  SeriesExpARCTANH = LRC(3.4,-3); (* = cbrt(sqrt(7.0*Eps)) *)
#endif
VAR neg  : BOOLEAN;
    y    : LONGREAL;
    xSqr : LONGREAL;
    xCub : LONGREAL;

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

   fatanh.d x(a6),fp0
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
   CODE(0F22EH,540DH,000CH);
#elif (defined HM2)
   CODE(0F22EH,540DH,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,540DH,0008H);
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
 y := one - x;

 IF y <= null THEN
   (* <Definitionsbereich> *)
   (* Zu einem Ueberlauf bei der spaeteren Division kann es nicht
    * kommen, da sich <x> und 1.0 um minimal E-16 unterscheiden koennen.
    *)
   RAISEmathException(arctanhArgMagnitude, "arctanh: |argument| >= 1.0");
   IF neg THEN
     RETURN(-LowLong.large);
   ELSE
     RETURN(LowLong.large);
   END;
 ELSIF x >= SeriesExpARCTANH THEN
   x := LowLong.scale(LongMath.ln((one + x) / y), -1);
 ELSE
   xSqr := x * x;
   xCub := xSqr * x;
   x    := x + xCub / three + null2 * xCub * xSqr
 END;

 IF neg THEN
   RETURN(-x);
 ELSE
   RETURN(x);
 END;
#ifndef MM2
 END;
#endif
END arctanh;

#if LONGREAL_var
(*---------------------------------------------------------------------------*)

PROCEDURE init;
BEGIN
 WITH cast DO
   lc1 := 000000000H; lc2 := 000000000H; null            := lr;
   lc1 := 03FE00000H; (* wie oben *)     half            := lr;
   lc1 := 03FF00000H; (* wie oben *)     one             := lr;
   lc1 := 040000000H; (* wie oben *)     two             := lr;
   lc1 := 040080000H; (* wie oben *)     three           := lr;
   lc1 := 040180000H; (* wie oben *)     six             := lr;
   lc1 := 0402E0000H; (* wie oben *)     fifteen         := lr;
   lc1 := 040380000H; (* wie oben *)     twentyfour      := lr;
   lc1 := 0404E0000H;                    sixty           := lr;

   lc1 := 040340000H; (* wie oben *)     MAXfullSINH     := lr; (* 2.00000000000000E+1 *)
   lc1 := 03FE00000H; (* wie oben *)     MAXaprxSINH     := lr; (* 5.00000000000000E-1 *)
   lc1 := 040340000H; (* wie oben *)     MAXfullCOSH     := lr; (* 2.00000000000000E+1 *)
   lc1 := 040360000H; (* wie oben *)     MAXfullTANH     := lr; (* 2.20000000000000E+1 *)

   lc1 := 040026BB1H; lc2 := 0BBB55515H; ln10      := lr; (* 2.3025850929940E+0 *)
   lc1 := 03FDBCB7BH; lc2 := 01526E50CH; lge       := lr; (* 4.3429448190325E-1 *)
   lc1 := 0400921FBH; lc2 := 054442D17H; pi        := lr; (* 3.14159265358979E+0 *)
   lc1 := 03FF921FBH; (* wie oben *)     pio2      := lr; (* 1.57079632679489E+0 *)
   lc1 := 0401921FBH; (* wie oben *)     pi2       := lr; (* 6.28318530717958E+0 *)
   lc1 := 03F91DF46H; lc2 := 0A2529D37H; pio180    := lr; (* 1.7453292519943E-2 *)
   lc1 := 03ED455A5H; lc2 := 0B2FF8F9CH; pio648000 := lr; (* 4.8481368110954E-6 *)

   lc1 := 03FB33333H; lc2 := 033333333H; nullnull75       := lr;
   lc1 := 03FB99999H; lc2 := 09999999AH; MAXaprxTANH      := lr; (* 1.00000000000000E-1 *)
   lc1 := 03FC99999H; (* wie oben *)     null2            := lr;
   lc1 := 041F2A05FH; lc2 := 020000000H; MAXfullARCSINH   := lr; (* 5.00000000000000E+9 *)
              (* wie oben *)             MAXfullARCCOSH   := lr; (* 5.00000000000000E+9 *)
   lc1 := 03F3A36E2H; lc2 := 0EB1C432DH; SeriesExpSINH    := lr; (* 4.00000000000000E-4 *)
   lc1 := 03F7DE69AH; lc2 := 0D42C3C9FH; SeriesExpCOSH    := lr; (* 7.29999999999996E-3 *)
   lc1 := 03F70624DH; lc2 := 0D2F1A9FCH; SeriesExpTANH    := lr; (* 4.00000000000000E-3 *)
   lc1 := 03F713404H; lc2 := 0EA4A8C16H; SeriesExpARCSINH := lr; (* 4.19999999999999E-3 *)
   lc1 := 03F6BDA51H; lc2 := 019CE0760H; SeriesExpARCTANH := lr; (* 3.39999999999999E-3 *)

   WITH sinhC DO
     lc1 := 0405B8E22H; lc2 := 00C04675EH; P0 := lr; (* 1.10220828060437E+2 *)
     lc1 := 040315EC1H; lc2 := 05D5844A2H; P1 := lr; (* 1.73701380100725E+1 *)
     lc1 := 03FE80F13H; lc2 := 040065078H; P2 := lr; (* 7.51840233848736E-1 *)
     lc1 := 03F8BB8B2H; lc2 := 0D7CA4775H; P3 := lr; (* 1.35358783821037E-2 *)
     lc1 := 03F1B9C6FH; lc2 := 0BD8E9AD1H; P4 := lr; (* 1.05327911468759E-4 *)
     lc1 := 0405B8E22H; lc2 := 00C04675EH; Q0 := lr; (* 1.10220828060437E+2 *)
   END;
   WITH exp1C DO
     lc1 := 0408A4088H; lc2 := 0E9FB8ECCH; P0 := lr; (* 8.40066852536480E+2 *)
     lc1 := 040340049H; lc2 := 0047C73CBH; P1 := lr; (* 2.00011141589964E+1 *)
     lc1 := 0409A4088H; lc2 := 0E9FB8ECCH; Q0 := lr; (* 1.68013370507296E+3 *)
     lc1 := 04066806DH; lc2 := 087C6CF2EH; Q1 := lr; (* 1.80013370407390E+2 *)
   END;
   WITH cbrtC DO
     lc1 := 03FD5D057H; lc2 := 09BC84803H; P0 := lr; (* 3.4084120000000E-1 *)
     lc1 := 03FF75475H; lc2 := 0020A9C3BH; P1 := lr; (* 1.4581194000000E+0 *)
     lc1 := 03FF62CCEH; lc2 := 0449C1143H; P2 := lr; (* 1.3859389000000E+0 *)
     lc1 := 03FE2F33FH; lc2 := 02CBB9FD3H; P3 := lr; (* 5.9219321000000E-1 *)
   END;
 END;
END init;
#endif

(*===========================================================================*)

BEGIN (* LongXMath *)
#ifndef MM2
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
#endif
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.AllocateSource(longXMathSource);
#endif
#if LONGREAL_var
 init;
#endif
END LongXMath.
