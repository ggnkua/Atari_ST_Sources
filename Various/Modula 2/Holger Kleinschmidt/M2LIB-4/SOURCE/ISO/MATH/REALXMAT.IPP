IMPLEMENTATION MODULE RealXMath;
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
(* 29-Jul-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

#if 0
#define __NO_EXCEPTIONS__
#endif

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHMEN:
   1) LowLong.radix = 2, d.h. scale multipliziert mit bzw. dividiert
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

#if (defined HM2) && (defined __LONG_REAL__)
FROM LowLong IMPORT
#else
FROM LowReal IMPORT
#endif
(* CONST*) large,
(* PROC *) scale, exponent, fraction;

IMPORT RealSupport, RealMath;

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

CONST
  pi        = 3.14159265358979323846264338327950288;   (* pi *)
  pi2       = 6.28318530717958647692528676655900576;   (* 2*pi *)
  pio2      = 1.57079632679489661923132169163975144;   (* pi/2 *)
  pio180    = 1.745329251994329576923690768488612E-2;  (* pi/180 *)
  pio648000 = 4.848136811095359935899141023579E-6;     (* pi/648000 *)
  lge       = 4.3429448190325182765112891891660508E-1; (* log10(e) *)
  ln10      = 2.30258509299404568401799145468436421;   (* logE(10) *)

#ifndef __NO_EXCEPTIONS__
VAR
  realXMathSource : EXCEPTIONS.ExceptionSource;
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
 EXCEPTIONS.RAISE(realXMathSource, ORD(exc), msg);
#endif
END RAISEmathException;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRXMathException (): BOOLEAN;
BEGIN
#ifdef __NO_EXCEPTIONS__
 RETURN(FALSE);
#else
 RETURN(EXCEPTIONS.IsCurrentSource(realXMathSource));
#endif
END IsRXMathException;

(*---------------------------------------------------------------------------*)

PROCEDURE cbrt ((* EIN/ -- *) x : REAL ): REAL;

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
 * -> zwei Iterationen der Mantisse nach Newton, da jede Iteration die
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
    y     : REAL;
    neg   : BOOLEAN;
    range : UNSIGNEDWORD;

PROCEDURE CBRT0562 ((* EIN/ -- *) x : REAL ): REAL;
(* 2.29 Stellen auf [0.125, 1] *)
CONST P0 =  0.3408412E0;
      P1 =  0.14581194E1;
      P2 = -0.13859389E1;
      P3 =  0.59219321E0;

BEGIN (* CBRT0562 *)
 RETURN(((P3 * x + P2) * x + P1) * x + P0);
END CBRT0562;

BEGIN (* cbrt *)
 neg := FALSE;
 IF x <= 0.0 THEN
   IF x = 0.0 THEN
     RETURN(0.0);
   END;
   x   := -x;
   neg := TRUE;
 END;

#if (defined MM2)
 e := VAL(SIGNEDWORD,exponent(x) + 2);
 x := scale(fraction(x), -2);
#else
 e := VAL(SIGNEDWORD,exponent(x) + 3);
 x := scale(fraction(x), -3);
#endif
 (* 0.125 <= x < 0.25 *)

 range := ABS(e) MOD 3;
 IF range = 1 THEN
   DEC(e);
   x := scale(x, 1);
   (* 0.25 <= x < 0.5  *)
 ELSIF range = 2 THEN
   DEC(e, 2);
   x := scale(x, 2);
   (* 0.5 <= x < 1.0  *)
 END;
 (* 0.125 <= x < 1.0 *)

 y := CBRT0562(x);

 FOR i := 1 TO 2  DO
   (* 2 Iterationen: > 9 Stellen *)
   y := (scale(y, 1) + x / (y * y)) / 3.0;
 END;

 IF neg THEN
   y := -y;
 END;

 IF e < 0 THEN
   e := -VAL(SIGNEDWORD,CAST(UNSIGNEDWORD,-e) DIV 3);
 ELSE
   e := e DIV 3;
 END;
 RETURN(scale(y, e));
END cbrt;

(*---------------------------------------------------------------------------*)

PROCEDURE hypot ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) y : REAL ): REAL;

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

VAR hmax : REAL;
    hmin : REAL;
    tmp  : REAL;

BEGIN
 hmax := ABS(x);
 hmin := ABS(y);
 IF hmin > hmax THEN
   tmp  := hmax;
   hmax := hmin;
   hmin := tmp;
 END;
 IF hmax = 0.0 THEN
   RETURN(0.0);
 ELSE
   hmin := hmin / hmax;
   RETURN(hmax * RealMath.sqrt(1.0 + hmin * hmin));
 END;
END hypot;

(*---------------------------------------------------------------------------*)

PROCEDURE exp10 ((* EIN/ -- *) x : REAL ): REAL;
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
   ftentox.d x(a6),fp0
#else
   ftentox.s x(a6),fp0
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
   CODE(0F22EH,4412H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5412H,0008H);
#else
   CODE(0F22EH,4412H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4412H,0008H);
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
 RETURN(RealMath.exp(x * ln10));
#ifndef MM2
 END;
#endif
END exp10;

(*---------------------------------------------------------------------------*)

PROCEDURE powI ((* EIN/ -- *) base : REAL;
                (* EIN/ -- *) exp  : INTEGER ): REAL;

VAR res    : REAL;
    negExp : BOOLEAN;

BEGIN
 IF (exp <= 0) & (base = 0.0) THEN
   (* <Definitionsbereich> : 0^0 oder 0^(-exp) *)
   RAISEmathException(nonpositivePowerArg, "powI: base = 0, exp <= 0");
   RETURN(0.0);
 END;
 IF exp < 0 THEN
   IF exp # MIN(INTEGER) THEN
     exp := -exp;
   END;
   negExp := TRUE;
 ELSE
   negExp := FALSE;
 END;

 res := 1.0;
 LOOP
   IF ODD(exp) THEN
     res := res * base;
   END;

   exp := CAST(CARDINAL,exp) DIV 2;

   (* Durch die LOOP-Schleife mit der Moeglichkeit eines
    * 'Ausstiegs mittendrin' statt einer WHILE-Schleife
    * wird ein Ueberlauf bei der folgenden Multiplikation
    * verhindert, falls schon alles berechnet wurde.
    *)
   IF exp = 0 THEN
     EXIT;
   END;

   base := base * base;
 END; (* LOOP *)

 IF negExp THEN
   RETURN(1.0 / res);
 ELSE
   RETURN(res);
 END;
END powI;

(*---------------------------------------------------------------------------*)

PROCEDURE log10 ((* EIN/ -- *) x : REAL ): REAL;
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
   flog10.d x(a6),fp0
#else
   flog10.s x(a6),fp0
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
   CODE(0F22EH,4415H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5415H,0008H);
#else
   CODE(0F22EH,4415H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4415H,0008H);
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
   RAISEmathException(nonpositiveLogArg, "log10: argument <= 0.0");
   RETURN(-large);
 ELSIF x = 1.0 THEN
   RETURN(0.0);
 END;
 RETURN(RealMath.ln(x) * lge);
#ifndef MM2
 END;
#endif
END log10;

(*---------------------------------------------------------------------------*)

PROCEDURE log ((* EIN/ -- *) x    : REAL;
               (* EIN/ -- *) base : REAL ): REAL;
(* [Hart68], 6.3.3 *)
BEGIN
 IF base <= 0.0 THEN
   (* <Definitionsbereich> *)
   RAISEmathException(nonpositiveLogBase, "log: base <= 0.0");
   RETURN(0.0);
 END;
 IF x <= 0.0 THEN
   (* <Definitionsbereich> *)
   RAISEmathException(nonpositiveLogArg, "log: argument <= 0.0");
   RETURN(-large);
 ELSIF x = 1.0 THEN
   RETURN(0.0);
 END;
 RETURN(RealMath.ln(x) / RealMath.ln(base));
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan2 ((* EIN/ -- *) y : REAL;
                   (* EIN/ -- *) x : REAL ): REAL;

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
     RAISEmathException(zeroPhaseArg, "arctan2: x = 0, y = 0");
     RETURN(0.0);
   ELSIF y < 0.0 THEN
     RETURN(-pio2);
   ELSE
     RETURN(pio2);
   END;
 ELSIF ABS(x) < ABS(y) THEN
   angle := RealMath.arctan(x / y);
   IF y < 0.0 THEN
     RETURN(-pio2 - angle);  (* VI, VII *)
   ELSE
     RETURN(pio2 - angle);   (* II, III *)
   END;
 ELSE
   angle := RealMath.arctan(y / x);
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

PROCEDURE rectToPol ((* EIN/ -- *)     x      : REAL;
                     (* EIN/ -- *)     y      : REAL;
                     (* -- /AUS *) VAR radius : REAL;
                     (* -- /AUS *) VAR angle  : REAL );
(* [Hart68], 6.5.5 *)
BEGIN
 radius := hypot(x, y);
 angle  := arctan2(y, x);
 IF angle < 0.0 THEN
   angle := angle + pi2;
 END;
END rectToPol;

(*---------------------------------------------------------------------------*)

PROCEDURE polToRect ((* EIN/ -- *)     radius : REAL;
                     (* EIN/ -- *)     angle  : REAL;
                     (* -- /AUS *) VAR x      : REAL;
                     (* -- /AUS *) VAR y      : REAL );
(* [Hart68], 6.5.4, [Abram70], 3.7.2 *)
BEGIN
 x := radius * RealMath.cos(angle);
 y := radius * RealMath.sin(angle);
END polToRect;

(*---------------------------------------------------------------------------*)

PROCEDURE degToRad ((* EIN/ -- *) x : REAL ): REAL;
(* [Hart68], 6.4.31 *)
BEGIN
 RETURN(x * pio180);
END degToRad;

(*---------------------------------------------------------------------------*)

PROCEDURE radToDeg ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
 RETURN(x / pio180);
END radToDeg;

(*---------------------------------------------------------------------------*)

PROCEDURE secToRad ((* EIN/ -- *) deg : CARDINAL;
                    (* EIN/ -- *) min : CARDINAL;
                    (* EIN/ -- *) sec : REAL     ): REAL;
(* [Hart68], 6.4.30 *)
BEGIN
 RETURN((RealSupport.float(VAL(UNSIGNED,(deg * 60 + min) * 60)) + sec) * pio648000);
END secToRad;

(*---------------------------------------------------------------------------*)

PROCEDURE radToSec ((* EIN/ -- *)     rad : REAL;
                    (* -- /AUS *) VAR deg : CARDINAL;
                    (* -- /AUS *) VAR min : CARDINAL;
                    (* -- /AUS *) VAR sec : REAL     );

VAR wrad : CARDINAL;

BEGIN
 rad  := rad / pio648000;
 sec  := RealSupport.fmod(rad, 60.0);
 wrad := VAL(CARDINAL,RealSupport.trunc(rad / 60.0));
 min  := wrad MOD 60;
 deg  := wrad DIV 60;
END radToSec;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh ((* EIN/ -- *) x : REAL ): REAL;

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
   fsinh.d x(a6),fp0
#else
   fsinh.s x(a6),fp0
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
   CODE(0F22EH,4402H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5402H,0008H);
#else
   CODE(0F22EH,4402H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4402H,0008H);
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

 IF x > MAXfullSINH THEN
   x := scale(RealMath.exp(x), -1);
 ELSIF x > MAXaprxSINH THEN
   x := RealMath.exp(x);
   x := scale(x, -1) - 1.0 / scale(x, 1);
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
#ifndef MM2
 END;
#endif
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh ((* EIN/ -- *) x : REAL ): REAL;

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

VAR xSqr : REAL;

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
   fcosh.d x(a6),fp0
#else
   fcosh.s x(a6),fp0
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
   CODE(0F22EH,4419H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5419H,0008H);
#else
   CODE(0F22EH,4419H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4419H,0008H);
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
 x := ABS(x);

 IF x > MAXfullCOSH THEN
   RETURN(scale(RealMath.exp(x), -1));
 ELSIF x >= SeriesExpCOSH THEN
   x := RealMath.exp(x);
   RETURN(scale(x, -1) + 1.0 / scale(x, 1));
 ELSE
   xSqr := x * x;
   RETURN(1.0 + scale(xSqr, -1) + xSqr * xSqr / 24.0);
 END;
#ifndef MM2
 END;
#endif
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh ((* EIN/ -- *) x : REAL ): REAL;

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
  MAXfullTANH   = 11.0;
  SeriesExpTANH = 1.1E-1; (* = cbrt(sqrt(315.0/17.0*Eps)) *)

VAR neg  : BOOLEAN;
    y    : REAL;
    xSqr : REAL;
    xCub : REAL;

BEGIN (* tanh *)
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
   ftanh.d x(a6),fp0
#else
   ftanh.s x(a6),fp0
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
   CODE(0F22EH,4409H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5409H,0008H);
#else
   CODE(0F22EH,4409H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4409H,0008H);
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

 IF x > MAXfullTANH THEN
   x := 1.0;
 ELSIF x >= SeriesExpTANH THEN
   x := RealMath.exp(x);
   y := 1.0 / x;
   x := (x - y) / (x + y);
 ELSE
   xSqr := x * x;
   xCub := x * xSqr;
   x    := x - xCub / 3.0 + scale(xSqr * xCub, 1) / 15.0;
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

PROCEDURE arcsinh ((* EIN/ -- *) x : REAL ): REAL;

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
CONST
  MAXfullARCSINH   = 5.0E+5;
  SeriesExpARCSINH = 1.2E-1; (* = cbrt(sqrt(28.0*EpsSHORT)) *)

VAR neg  : BOOLEAN;
    xSqr : REAL;
    xCub : REAL;

BEGIN
 neg := x < 0.0;
 IF neg THEN
   x := -x;
 END;

 IF x > MAXfullARCSINH THEN
   x := RealMath.ln(scale(x, 1));
 ELSIF x >= SeriesExpARCSINH THEN
   x := RealMath.ln(x + RealMath.sqrt(x * x + 1.0));
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

PROCEDURE arccosh ((* EIN/ -- *) x : REAL ): REAL;

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
  MAXfullARCCOSH = 5.0E+5;

BEGIN
 IF x < 1.0 THEN
   (* <Definitionsbereich> *)
   RAISEmathException(arccoshArgMagnitude, "arccosh: argument < 1.0");
   RETURN(0.0);
 ELSIF x > MAXfullARCCOSH THEN
   RETURN(RealMath.ln(scale(x, 1)));
 ELSE
   RETURN(RealMath.ln(x + RealMath.sqrt(x * x - 1.0)));
 END;
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh ((* EIN/ -- *) x : REAL ): REAL;

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
  SeriesExpARCTANH = 9.7E-2; (* = cbrt(sqrt(7.0*EpsSHORT)) *)

VAR neg  : BOOLEAN;
    y    : REAL;
    xSqr : REAL;
    xCub : REAL;

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
   fatanh.d x(a6),fp0
#else
   fatanh.s x(a6),fp0
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
   CODE(0F22EH,440DH,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,540DH,0008H);
#else
   CODE(0F22EH,440DH,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,440DH,0008H);
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
 y := 1.0 - x;

 IF y <= 0.0 THEN
   (* <Definitionsbereich> *)
   (* Zu einem Ueberlauf bei der spaeteren Division kann es nicht
    * kommen, da sich <x> und 1.0 um minimal 1E-8 unterscheiden koennen.
    *)
   RAISEmathException(arctanhArgMagnitude, "arctanh: |argument| >= 1.0");
   IF neg THEN
     RETURN(-large);
   ELSE
     RETURN(large);
   END;
 ELSIF x >= SeriesExpARCTANH THEN
   x := scale(RealMath.ln((1.0 + x) / y), -1);
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
#ifndef MM2
 END;
#endif
END arctanh;

(*===========================================================================*)

BEGIN (* RealXMath *)
#ifndef MM2
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
#endif
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.AllocateSource(realXMathSource);
#endif
END RealXMath.
