IMPLEMENTATION MODULE ComplexMath;
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
(* 02-Nov-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

#if 0
#define __NO_EXCEPTIONS__
#endif

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHMEN:
   1) LowReal.radix = 2, d.h. LowReal.scale multipliziert mit bzw. dividiert
      durch Zweierpotenzen.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

#if !ISO_complex
#  define RE(_Z) _Z ## .re
#  define IM(_Z) _Z ## .im
#endif

VAL_INTRINSIC
CAST_IMPORT

#ifndef __NO_EXCEPTIONS__
IMPORT EXCEPTIONS;
#endif

#if (defined HM2) && (defined __LONG_REAL__)
FROM LowLong IMPORT
#else
FROM LowReal IMPORT
#endif
(* CONST*) large,
(* PROC *) scale;

IMPORT RealSupport, RealMath, RealXMath;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  pi   = 3.14159265358979323846264338327950288;   (* Pi *)
  pio2 = 1.57079632679489661923132169163975144;   (* Pi/2 *)
  pio4 = 7.8539816339744830961566084581987572E-1; (* Pi/4 *)

#ifndef __NO_EXCEPTIONS__
VAR
  cMathSource : EXCEPTIONS.ExceptionSource;
#endif

TYPE
  ComplexExceptions = (
    zeroArgParameter,
    complexTanOverflow
  );

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if !ISO_complex
PROCEDURE cequ ((* EIN/ -- *) z1 : COMPLEX;
                (* EIN/ -- *) z2 : COMPLEX ): BOOLEAN;
(* [Bron87], 3.4.2.1 (1) *)
BEGIN
 RETURN((RE(z1) = RE(z2)) & (IM(z1) = IM(z2)));
END cequ;

(*---------------------------------------------------------------------------*)

#if ISO_struct_return
PROCEDURE cneg ((* EIN/ -- *) z : COMPLEX ): COMPLEX;
BEGIN
 z.re := -RE(z);
 z.im := -IM(z);
 RETURN(z);
END cneg;

(*---------------------------------------------------------------------------*)

PROCEDURE CMPLX ((* EIN/ -- *) re : REAL;
                 (* EIN/ -- *) im : REAL ): COMPLEX;

VAR z : COMPLEX;

BEGIN
 z.re := re;
 z.im := im;
 RETURN(z);
END CMPLX;

(*---------------------------------------------------------------------------*)

PROCEDURE cadd ((* EIN/ -- *) z1 : COMPLEX;
                (* EIN/ -- *) z2 : COMPLEX ): COMPLEX;
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 z1.re := RE(z1) + RE(z2);
 z1.im := IM(z1) + IM(z2);
 RETURN(z1);
END cadd;

(*---------------------------------------------------------------------------*)

PROCEDURE csub ((* EIN/ -- *) z1 : COMPLEX;
                (* EIN/ -- *) z2 : COMPLEX ): COMPLEX;
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 z1.re := RE(z1) - RE(z2);
 z1.im := IM(z1) - IM(z2);
 RETURN(z1);
END csub;

(*---------------------------------------------------------------------------*)

PROCEDURE cmul ((* EIN/ -- *) z1 : COMPLEX;
                (* EIN/ -- *) z2 : COMPLEX ): COMPLEX;
(* [Abram70], 3.7.10; [Bron87], 3.4.2.1 (3) *)
BEGIN
 z1.re := RE(z1) * RE(z2) - IM(z1) * IM(z2);
 z1.im := RE(z1) * IM(z2) + IM(z1) * RE(z2);
 RETURN(z1);
END cmul;

(*---------------------------------------------------------------------------*)

PROCEDURE cdiv ((* EIN/ -- *) z1 : COMPLEX;
                (* EIN/ -- *) z2 : COMPLEX ): COMPLEX;

(* [Abram70], 3.7.13; [Bron87], 3.4.2.1 (4):
 *
 *                re(z1) * re(z2) + im(z1) * im(z2)
 *   re(z1/z2) := ---------------------------------
 *                      re(z2)^2 + im(z2)^2
 *
 *                im(z1) * re(z2) - re(z1) * im(z2)
 *   im(z1/z2) := ---------------------------------
 *                      re(z2)^2 + im(z2)^2
 *
 * Hierbei kann es leicht zum Ueberlauf kommen, obwohl das Ergebnis nicht
 * zu gross ist. Durch eine kleine Umformung laesst sich das vermeiden:
 *
 * Wenn re(z2) groesser als im(z2) ist, wird mit (1/re(z2)) / (1/re(z2))
 * erweitert, sonst mit (1/im(z2)) / (1/im(z2)), so dass spaeter die kleinere
 * durch die groessere Zahl geteilt wird.
 * Hier das Ergebnis fuer den ersten Fall, der zweite ist analog:
 *
 *                re(z1) + (im(z1) * im(z2)) / re(z2)
 *   re(z1/z2) := -----------------------------------
 *                   re(z2) + (im(z2)^2 / re(z2))
 *
 *                im(z1) - (re(z1) * im(z2)) / re(z2)
 *   im(z1/z2) := -----------------------------------
 *                   re(z2) + (im(z2)^2 / re(z2))
 *
 * [Eng88], S.283
 *)
VAR tmp1 : REAL;
    tmp2 : REAL;

BEGIN
 IF ABS(RE(z2)) > ABS(IM(z2)) THEN
   tmp1  := IM(z2) / RE(z2);
   tmp2  := tmp1 * IM(z2) + RE(z2);
   z2.re := (RE(z1) + tmp1 * IM(z1)) / tmp2;
   z2.im := (IM(z1) - tmp1 * RE(z1)) / tmp2;
 ELSE
   tmp1  := RE(z2) / IM(z2);
   tmp2  := tmp1 * RE(z2) + IM(z2);
   z2.re := (tmp1 * RE(z1) + IM(z1)) / tmp2;
   z2.im := (tmp1 * IM(z1) - RE(z1)) / tmp2;
 END;
 RETURN(z2);
END cdiv;

(*---------------------------------------------------------------------------*)
#else /* !ISO_struct_return */

PROCEDURE cneg ((* EIN/ -- *)     z    : COMPLEX;
                (* -- /AUS *) VAR zneg : COMPLEX );
BEGIN
 zneg.re := -RE(z);
 zneg.im := -IM(z);
END cneg;

(*---------------------------------------------------------------------------*)

PROCEDURE CMPLX ((* EIN/ -- *)     re : REAL;
                 (* EIN/ -- *)     im : REAL;
                 (* -- /AUS *) VAR z  : COMPLEX );
BEGIN
 z.re := re;
 z.im := im;
END CMPLX;

(*---------------------------------------------------------------------------*)

PROCEDURE cadd ((* EIN/ -- *)     z1   : COMPLEX;
                (* EIN/ -- *)     z2   : COMPLEX;
                (* -- /AUS *) VAR zadd : COMPLEX );
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 zadd.re := RE(z1) + RE(z2);
 zadd.im := IM(z1) + IM(z2);
END cadd;

(*---------------------------------------------------------------------------*)

PROCEDURE csub ((* EIN/ -- *)     z1   : COMPLEX;
                (* EIN/ -- *)     z2   : COMPLEX;
                (* -- /AUS *) VAR zsub : COMPLEX );
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 zsub.re := RE(z1) - RE(z2);
 zsub.im := IM(z1) - IM(z2);
END csub;

(*---------------------------------------------------------------------------*)

PROCEDURE cmul ((* EIN/ -- *)     z1   : COMPLEX;
                (* EIN/ -- *)     z2   : COMPLEX;
                (* -- /AUS *) VAR zmul : COMPLEX );
(* [Abram70], 3.7.10; [Bron87], 3.4.2.1 (3) *)
BEGIN
 zmul.re := RE(z1) * RE(z2) - IM(z1) * IM(z2);
 zmul.im := RE(z1) * IM(z2) + IM(z1) * RE(z2);
END cmul;

(*---------------------------------------------------------------------------*)

PROCEDURE cdiv ((* EIN/ -- *)     z1   : COMPLEX;
                (* EIN/ -- *)     z2   : COMPLEX;
                (* -- /AUS *) VAR zdiv : COMPLEX );

(* [Abram70], 3.7.13; [Bron87], 3.4.2.1 (4):
 *
 *                re(z1) * re(z2) + im(z1) * im(z2)
 *   re(z1/z2) := ---------------------------------
 *                      re(z2)^2 + im(z2)^2
 *
 *                im(z1) * re(z2) - re(z1) * im(z2)
 *   im(z1/z2) := ---------------------------------
 *                      re(z2)^2 + im(z2)^2
 *
 * Hierbei kann es leicht zum Ueberlauf kommen, obwohl das Ergebnis nicht
 * zu gross ist. Durch eine kleine Umformung laesst sich das vermeiden:
 *
 * Wenn re(z2) groesser als im(z2) ist, wird mit (1/re(z2)) / (1/re(z2))
 * erweitert, sonst mit (1/im(z2)) / (1/im(z2)), so dass spaeter die kleinere
 * durch die groessere Zahl geteilt wird.
 * Hier das Ergebnis fuer den ersten Fall, der zweite ist analog:
 *
 *                re(z1) + (im(z1) * im(z2)) / re(z2)
 *   re(z1/z2) := -----------------------------------
 *                   re(z2) + (im(z2)^2 / re(z2))
 *
 *                im(z1) - (re(z1) * im(z2)) / re(z2)
 *   im(z1/z2) := -----------------------------------
 *                   re(z2) + (im(z2)^2 / re(z2))
 *
 * [Eng88], S.283
 *)
VAR tmp1 : REAL;
    tmp2 : REAL;

BEGIN
 IF ABS(RE(z2)) > ABS(IM(z2)) THEN
   tmp1    := IM(z2) / RE(z2);
   tmp2    := tmp1 * IM(z2) + RE(z2);
   zdiv.re := (RE(z1) + tmp1 * IM(z1)) / tmp2;
   zdiv.im := (IM(z1) - tmp1 * RE(z1)) / tmp2;
 ELSE
   tmp1    := RE(z2) / IM(z2);
   tmp2    := tmp1 * RE(z2) + IM(z2);
   zdiv.re := (tmp1 * RE(z1) + IM(z1)) / tmp2;
   zdiv.im := (tmp1 * IM(z1) - RE(z1)) / tmp2;
 END;
END cdiv;

(*---------------------------------------------------------------------------*)
#endif /* ISO_struct_return */
#endif /* !ISO_complex */

PROCEDURE abs ((* EIN/ -- *) z : COMPLEX ) : REAL;
(* [Abram70], 3.7.3; [Bron87], 3.4.2.2 *)
BEGIN
 RETURN(RealXMath.hypot(RE(z), IM(z)));
END abs;

(*---------------------------------------------------------------------------*)

PROCEDURE arg ((* EIN/ -- *) z : COMPLEX ) : REAL;
(* [Bron87], 3.4.2.4 *)
BEGIN
 IF (RE(z) = 0.0) & (IM(z) = 0.0) THEN
#ifdef __NO_EXCEPTIONS__
   RETURN(0.0);
#else
   EXCEPTIONS.RAISE(cMathSource, ORD(zeroArgParameter),
                    "arg: argument equals CMPLX(0.0, 0.0)");
#endif
 END;
 RETURN(RealXMath.arctan2(IM(z), RE(z)));
END arg;

(*---------------------------------------------------------------------------*)

#if ISO_struct_return
PROCEDURE conj ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
(* [Bron87], 3.4.2.2 *)
BEGIN
#if ISO_complex
 RETURN(CMPLX(RE(z), -IM(z)));
#else
 z.im := -IM(z);
 RETURN(z);
#endif
END conj;

(*---------------------------------------------------------------------------*)

PROCEDURE power ((* EIN/ -- *) base     : COMPLEX;
                 (* EIN/ -- *) exponent : REAL    ) : COMPLEX;
(* [Bron87], 3.4.2.5.4 *)
VAR absToX : REAL;
    argX   : REAL;

BEGIN
 absToX := RealMath.power(abs(base), exponent);
 argX   := exponent * arg(base);
#if ISO_complex
 RETURN(CMPLX(absToX * RealMath.cos(argX), absToX * RealMath.sin(argX)));
#else
 base.re := absToX * RealMath.cos(argX);
 base.im := absToX * RealMath.sin(argX);
 RETURN(base);
#endif
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 3.7.27; [Bron87], Tab 3.7:
 *
 *                      ________________                   ________________
 *   sqrt(z) = cmplx( \/ 0.5*(|z|+re(z)) , sign(im(z)) * \/ 0.5*(|z|-re(z)) )
 *
 *
 *                                 ___________
 * Mit  z = x + i*y  und   |z| = \/ x^2 + y^2   ergibt sich fuer die Faktoren
 * unter der Wurzel:
 *
 *                             ___________
 *   Realteil:   |z|+re(z) = \/ x^2 + y^2  + |x|  , fuer  x >= 0
 *
 *                             ___________
 *                           \/ x^2 + y^2  - |x|  , fuer  x < 0
 *
 *                             ___________
 *   Imag.teil:  |z|-re(z) = \/ x^2 + y^2  - |x|  , fuer  x >= 0
 *
 *                             ___________
 *                           \/ x^2 + y^2  + |x|  , fuer  x < 0
 *
 *
 * Wenn x sehr viel groesser als y ist, kommt es bei der Subtraktion
 * zur Stellenausloeschung, da sich die Wurzel dann x annaehert.
 * Also wird der entsprechende Term so umgeformt, dass die gefaehrliche
 * Subtraktion nicht mehr auftritt:
 *
 *       ____________       Der Bruch wird mit -(y^2) erweitert.
 *      / |z| - |x|         Im Nenner wird zusaetzlich eine Null
 *     / ------------       " x^2 - x^2  =  0 " addiert, und mit
 *   \/       2             " x^2 - x^2 - y^2  =  x^2 - (x^2 + y^2) "
 *                          erhaelt man:
 *
 *         _________________________
 *        /  (|x| - |z|) * y^2           Im Nenner laesst sich die dritte
 *  =    / -------------------------     binomische Formel anwenden
 *     \/  2 * (x^2 - ( x^2 + y^2 ))     " a^2 - b^2  =  (a - b) * (a + b) "
 *                                       mit  a^2:=x^2  ,  b^2:=x^2 + y^2 :
 *
 *         _____________________________
 *        /    (|x| - |z|) * y^2
 *  =    / -----------------------------    Durch Kuerzen erhaelt man dann:
 *     \/  2 * (|x| - |z|) * (|x| + |z|)
 *
 *
 *         _________________
 *        /      y^2
 *  =    / -----------------             teilweises Wurzelziehen ergibt:
 *     \/    2 * (|x| + |z|)
 *
 *
 *           |y|
 *  =  __________________
 *       ________________
 *     \/ 2 * (|x| + |z|)
 *
 *
 *               |y|
 *  =  _________________________
 *       _______________________
 *     \/(4/4) * 2 * (|x| + |z|)
 *
 *              |y|
 *  =  ________________________   =: 'subRoot'
 *           __________________
 *     2 * \/ 0.5 * (|x| + |z|)
 *
 *         __________________
 * Mit   \/ 0.5 * (|x| + |z|)  =: 'addRoot'
 *
 *
 * gilt fuer die komplexe Wurzel:
 *
 *
 *
 *   sqrt(z) = cmplx(addRoot, sign(y) * subRoot)  , fuer  x >= 0
 *           = cmplx(subRoot, sign(y) * addRoot)  , fuer  x < 0
 *)

VAR addRoot : REAL;
    subRoot : REAL;
    negReal : BOOLEAN;
    negImag : BOOLEAN;

BEGIN
#if ISO_complex
 IF z = CMPLX(0.0, 0.0) THEN
   RETURN(z);
 END;

 negReal := RE(z) < 0.0;
 IF negReal THEN
   z := CMPLX(-RE(z), IM(z));
 END;
 negImag := IM(z) < 0.0;
 IF negImag THEN
   z := CMPLX(RE(z), -IM(z));
 END;

 addRoot := RealMath.sqrt(scale(abs(z) + RE(z), -1));
 subRoot := IM(z) / scale(addRoot, 1);

 IF negReal THEN
   z := CMPLX(subRoot, addRoot);
 ELSE
   z := CMPLX(addRoot, subRoot);
 END;

 IF negImag THEN
   RETURN(CMPLX(RE(z), -IM(z)));
 ELSE
   RETURN(z);
 END;
#else
 IF (RE(z) = 0.0) & (IM(z) = 0.0) THEN
   RETURN(z);
 END;

 negReal := RE(z) < 0.0;
 IF negReal THEN
   z.re := -RE(z);
 END;
 negImag := IM(z) < 0.0;
 IF negImag THEN
   z.im := -IM(z);
 END;

 addRoot := RealMath.sqrt(scale(abs(z) + RE(z), -1));
 subRoot := IM(z) / scale(addRoot, 1);
 IF negReal THEN
   z.re := subRoot;
   z.im := addRoot;
 ELSE
   z.re := addRoot;
   z.im := subRoot;
 END;

 IF negImag THEN
   z.im := -IM(z);
 END;
 RETURN(z);
#endif
END sqrt;

(*---------------------------------------------------------------------------*)

PROCEDURE exp ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
(* [Bron87], 3.4.4.2.1 *)
VAR eToReX : REAL;

BEGIN
 eToReX := RealMath.exp(RE(z));

#if ISO_complex
 RETURN(CMPLX(eToReX * RealMath.cos(IM(z)), eToReX * RealMath.sin(IM(z))));
#else
 z.re := eToReX * RealMath.cos(IM(z));
 z.im := eToReX * RealMath.sin(IM(z));
 RETURN(z);
#endif
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
(* [Abram70], 4.1.2; [Bron87], 3.4.4.2.2 *)
#if !ISO_complex
VAR tmp : REAL;
#endif
BEGIN
#if ISO_complex
 RETURN(CMPLX(RealMath.ln(abs(z)), arg(z)));
#else
 tmp  := RealMath.ln(abs(z));
 z.im := arg(z);
 z.re := tmp;
 RETURN(z);
#endif
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE sin ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
(* [Abram70], 4.3.55; [Bron87], Tab 3.7 *)
#if !ISO_complex
VAR tmp : REAL;
#endif
BEGIN
#if ISO_complex
 RETURN(CMPLX(RealMath.sin(RE(z)) * RealXMath.cosh(IM(z)),
              RealMath.cos(RE(z)) * RealXMath.sinh(IM(z))));
#else
 tmp  := RealMath.sin(RE(z)) * RealXMath.cosh(IM(z));
 z.im := RealMath.cos(RE(z)) * RealXMath.sinh(IM(z));
 z.re := tmp;
 RETURN(z);
#endif
END sin;

(*---------------------------------------------------------------------------*)

PROCEDURE cos ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
(* [Abram70], 4.3.56; [Bron87], Tab 3.7 *)
#if !ISO_complex
VAR tmp : REAL;
#endif
BEGIN
#if ISO_complex
 RETURN(CMPLX(RealMath.cos(RE(z)) * RealXMath.cosh(IM(z)),
              -RealMath.sin(RE(z)) * RealXMath.sinh(IM(z))));
#else
 tmp  := RealMath.cos(RE(z)) * RealXMath.cosh(IM(z));
 z.im := -RealMath.sin(RE(z)) * RealXMath.sinh(IM(z));
 z.re := tmp;
 RETURN(z);
#endif
END cos;

(*---------------------------------------------------------------------------*)

PROCEDURE tan ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
(* [Abram70], 4.3.57 *)
VAR divisor : REAL;
#ifdef __NO_EXCEPTIONS__
    neg     : BOOLEAN;
    x       : REAL;
#endif

BEGIN
#if ISO_complex
 z := CMPLX(scale(RE(z), 1), scale(IM(z), 1));
#else
 z.re := scale(RE(z), 1);
 z.im := scale(IM(z), 1);
#endif
 divisor := RealMath.cos(RE(z)) + RealXMath.cosh(IM(z));
 IF divisor = 0.0 THEN
   (* Kann nur auftreten, wenn IM(z) = 0.0, da cosh nur bei 0.0 gleich
    * 1.0 liefert, sonst eine groessere Zahl. Ausserdem liefert cos(2x)
    * -1.0, wenn x ein ungerades Vielfaches von pi/2 ist.
    *)
#ifdef __NO_EXCEPTIONS__
   (* Algorithmus wie bei Real-tan *)
   x   := RE(z);
   neg := x < 0.0;
   IF neg THEN
     x := -x;
   END;
   IF x > pi THEN
     x := RealSupport.fmod(x, pi);
   END;
   IF x > pio2 THEN
     neg := ~neg;
   END;
#if ISO_complex
   IF neg THEN
     RETURN(CMPLX(-large, 0.0));
   ELSE
     RETURN(CMPLX(large, 0.0));
   END;
#else
   IF neg THEN
     z.re := -large;
   ELSE
     z.re := large;
   END;
   z.im := 0.0;
   RETURN(z);
#endif
#else
   EXCEPTIONS.RAISE(cMathSource, ORD(complexTanOverflow),
                    "tan: CMPLX(real, 0.0) is odd multiple of pi/2");
#endif
 ELSE
#if ISO_complex
   RETURN(CMPLX(RealMath.sin(RE(z)) / divisor, RealXMath.sinh(IM(z)) / divisor));
#else
   z.re := RealMath.sin(RE(z)) / divisor;
   z.im := RealXMath.sinh(IM(z)) / divisor;
   RETURN(z);
#endif
 END;
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *) z   : COMPLEX;
                     (* EIN/ -- *) sin : BOOLEAN  ): COMPLEX;

(* [Abram70], 4.4.37, 4.4.38:
 *
 *
 *   z = x + iy
 *                _____________             _____________
 *   a := 0.5 * \/(x+1)^2 + y^2  +  0.5 * \/(x-1)^2 + y^2
 *
 *                _____________             _____________
 *   b := 0.5 * \/(x+1)^2 + y^2  -  0.5 * \/(x-1)^2 + y^2
 *
 *                                               _______
 *   arcsin(z) = arcsin(b) + sign(y) * iln(a + \/(a^2)-1 )
 *
 *                                               _______
 *   arccos(z) = arccos(b) - sign(y) * iln(a + \/(a^2)-1 )
 *)

VAR tmp1  : REAL;
    tmp2  : REAL;
    tmp3  : REAL;
    a     : REAL;
    b     : REAL;

BEGIN
 tmp1 := RE(z) + 1.0;
 tmp2 := RE(z) - 1.0;
 tmp3 := IM(z) * IM(z);

 tmp1 := RealMath.sqrt(tmp1 * tmp1 + tmp3);
 tmp2 := RealMath.sqrt(tmp2 * tmp2 + tmp3);

 a := scale(tmp1 + tmp2, -1);
 b := scale(tmp1 - tmp2, -1);

 tmp3 := RealMath.ln(a + RealMath.sqrt(a * a - 1.0));
 IF IM(z) < 0.0 THEN
   tmp3 := -tmp3;
 END;

 IF sin THEN
#if ISO_complex
   RETURN(CMPLX(RealMath.arcsin(b), tmp3));
#else
   z.re := RealMath.arcsin(b);
   z.im := tmp3;
   RETURN(z);
#endif
 ELSE
#if ISO_complex
   RETURN(CMPLX(RealMath.arccos(b), -tmp3));
#else
   z.re := RealMath.arccos(b);
   z.im := -tmp3;
   RETURN(z);
#endif
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
BEGIN
 RETURN(arcTrigon(z, TRUE));
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;
BEGIN
 RETURN(arcTrigon(z, FALSE));
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.4.39:
 *
 * z = x + iy
 *
 *                              2 * x          i       x^2 + (y+1)^2
 * arctan(z) = 0.5 * arctan( ------------- ) + - * ln( ------------- )
 *                           1 - x^2 - y^2     4       x^2 + (y-1)^2
 *
 *         z^2 # -1 => z # +/-i
 *
 * arctan(y / x) wird dabei durch arg(CMPLX(x, y)) ersetzt, um den
 * Bereich (-pi, pi] zu erhalten; ausserdem funktioniert arg(.) auch, wenn
 * der Nenner gleich Null ist.
 *)
VAR tmp1 : REAL;
    tmp2 : REAL;
    tmp3 : REAL;

BEGIN
 tmp1 := IM(z) + 1.0;
 tmp2 := IM(z) - 1.0;
 tmp3 := RE(z) * RE(z);

 tmp1 := scale(RealMath.ln((tmp3+tmp1*tmp1) / (tmp3+tmp2*tmp2)), -2);
 tmp2 := scale(RealXMath.arctan2(scale(RE(z), 1), 1.0-tmp3-IM(z)*IM(z)), -1);

#if ISO_complex
 RETURN(CMPLX(tmp2, tmp1));
#else
 z.re := tmp2;
 z.im := tmp1;
 RETURN(z);
#endif
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE polarToComplex ((* EIN/ -- *) abs : REAL;
                          (* EIN/ -- *) arg : REAL ) : COMPLEX;
(* [Abram70], 3.7.2 *)
#if ISO_complex
VAR x : REAL;
    y : REAL;
#else
VAR z : COMPLEX;
#endif
BEGIN
#if ISO_complex
 RealXMath.polToRect(abs, arg, x, y);
 RETURN(CMPLX(x, y));
#else
 RealXMath.polToRect(abs, arg, z.re, z.im);
 RETURN(z);
#endif
END polarToComplex;

(*---------------------------------------------------------------------------*)

PROCEDURE scalarMult ((* EIN/ -- *) scalar : REAL;
                      (* EIN/ -- *) z      : COMPLEX ): COMPLEX;
BEGIN
#if ISO_complex
 RETURN(CMPLX(RE(z) * scalar, IM(z) * scalar));
#else
 z.re := RE(z) * scalar;
 z.im := IM(z) * scalar;
 RETURN(z);
#endif
END scalarMult;

#else /* !ISO_struct-return */

PROCEDURE conj ((* EIN/ -- *)     z     : COMPLEX;
                (* -- /AUS *) VAR zconj : COMPLEX );
BEGIN
 zconj.re := RE(z);
 zconj.im := -IM(z);
END conj;

(*---------------------------------------------------------------------------*)

PROCEDURE power ((* EIN/ -- *)     base     : COMPLEX;
                 (* EIN/ -- *)     exponent : REAL;
                 (* -- /AUS *) VAR zpow     : COMPLEX );
(* [Bron87], 3.4.2.5.4 *)
VAR absToX : REAL;
    argX   : REAL;

BEGIN
 absToX  := RealMath.power(abs(base), exponent);
 argX    := exponent * arg(base);
 zpow.re := absToX * RealMath.cos(argX);
 zpow.im := absToX * RealMath.sin(argX);
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt ((* EIN/ -- *)     z     : COMPLEX;
                (* -- /AUS *) VAR zsqrt : COMPLEX );

(* [Abram70], 3.7.27; [Bron87], Tab 3.7:
 *
 *                      ________________                   ________________
 *   sqrt(z) = cmplx( \/ 0.5*(|z|+re(z)) , sign(im(z)) * \/ 0.5*(|z|-re(z)) )
 *
 *
 *                                 ___________
 * Mit  z = x + i*y  und   |z| = \/ x^2 + y^2   ergibt sich fuer die Faktoren
 * unter der Wurzel:
 *
 *                             ___________
 *   Realteil:   |z|+re(z) = \/ x^2 + y^2  + |x|  , fuer  x >= 0
 *
 *                             ___________
 *                           \/ x^2 + y^2  - |x|  , fuer  x < 0
 *
 *                             ___________
 *   Imag.teil:  |z|-re(z) = \/ x^2 + y^2  - |x|  , fuer  x >= 0
 *
 *                             ___________
 *                           \/ x^2 + y^2  + |x|  , fuer  x < 0
 *
 *
 * Wenn x sehr viel groesser als y ist, kommt es bei der Subtraktion
 * zur Stellenausloeschung, da sich die Wurzel dann x annaehert.
 * Also wird der entsprechende Term so umgeformt, dass die gefaehrliche
 * Subtraktion nicht mehr auftritt:
 *
 *       __________         Der Bruch wird mit -(y^2) erweitert.
 *      / |z| - |x|         Im Nenner wird zusaetzlich eine Null
 *     /  ---------         " x^2 - x^2  =  0 " addiert, und mit
 *   \/       2             " x^2 - x^2 - y^2  =  x^2 - (x^2 + y^2) "
 *                          erhaelt man:
 *
 *         _________________________
 *        /  (|x| - |z|) * y^2           Im Nenner laesst sich die dritte
 *  =    / -------------------------     binomische Formel anwenden
 *     \/  2 * (x^2 - ( x^2 + y^2 ))     " a^2 - b^2  =  (a - b) * (a + b) "
 *                                       mit  a^2:=x^2  ,  b^2:=x^2 + y^2 :
 *
 *         _____________________________
 *        /    (|x| - |z|) * y^2
 *  =    / -----------------------------    Durch Kuerzen erhaelt man dann:
 *     \/  2 * (|x| - |z|) * (|x| + |z|)
 *
 *
 *         _______________
 *        /     y^2
 *  =    / ---------------             teilweises Wurzelziehen ergibt:
 *     \/  2 * (|x| + |z|)
 *
 *
 *           |y|                         |y|
 *  =  __________________    =  ________________________   =: 'subRoot'
 *       ________________             __________________
 *     \/ 2 * (|x| + |z|)       2 * \/ 0.5 * (|x| + |z|)
 *
 *
 *         __________________
 * Mit   \/ 0.5 * (|x| + |z|)  =: 'addRoot'
 *
 *
 * gilt fuer die komplexe Wurzel:
 *
 *
 *
 *   sqrt(z) = cmplx(addRoot, sign(y) * subRoot)  , fuer  x >= 0
 *           = cmplx(subRoot, sign(y) * addRoot)  , fuer  x < 0
 *)

VAR addRoot : REAL;
    subRoot : REAL;
    negReal : BOOLEAN;
    negImag : BOOLEAN;

BEGIN
 IF (RE(z) = 0.0) & (IM(z) = 0.0) THEN
   zsqrt := z;
   RETURN;
 END;

 negReal := RE(z) < 0.0;
 IF negReal THEN
   z.re := -RE(z);
 END;
 negImag := IM(z) < 0.0;
 IF negImag THEN
   z.im := -IM(z);
 END;

 addRoot := RealMath.sqrt(scale(abs(z) + RE(z), -1));
 subRoot := IM(z) / scale(addRoot, 1);
 IF negReal THEN
   zsqrt.re := subRoot;
   zsqrt.im := addRoot;
 ELSE
   zsqrt.re := addRoot;
   zsqrt.im := subRoot;
 END;

 IF negImag THEN
   zsqrt.im := -IM(zsqrt);
 END;
END sqrt;

(*---------------------------------------------------------------------------*)

PROCEDURE exp ((* EIN/ -- *)     z    : COMPLEX;
               (* -- /AUS *) VAR zexp : COMPLEX );
(* [Bron87], 3.4.4.2.1 *)
VAR eToReX : REAL;

BEGIN
 eToReX  := RealMath.exp(RE(z));

 zexp.re := eToReX * RealMath.cos(IM(z));
 zexp.im := eToReX * RealMath.sin(IM(z));
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln ((* EIN/ -- *)     z   : COMPLEX;
              (* -- /AUS *) VAR zln : COMPLEX );
(* [Abram70], 4.1.2; [Bron87], 3.4.4.2.2 *)
BEGIN
 zln.re := RealMath.ln(abs(z));
 zln.im := arg(z);
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE sin ((* EIN/ -- *)     z    : COMPLEX;
               (* -- /AUS *) VAR zsin : COMPLEX );
(* [Abram70], 4.3.55; [Bron87], Tab 3.7 *)
BEGIN
 zsin.re := RealMath.sin(RE(z)) * RealXMath.cosh(IM(z));
 zsin.im := RealMath.cos(RE(z)) * RealXMath.sinh(IM(z));
END sin;

(*---------------------------------------------------------------------------*)

PROCEDURE cos ((* EIN/ -- *)     z    : COMPLEX;
               (* -- /AUS *) VAR zcos : COMPLEX );
(* [Abram70], 4.3.56; [Bron87], Tab 3.7 *)
BEGIN
 zcos.re := RealMath.cos(RE(z)) * RealXMath.cosh(IM(z));
 zcos.im := -RealMath.sin(RE(z)) * RealXMath.sinh(IM(z));
END cos;

(*---------------------------------------------------------------------------*)

PROCEDURE tan ((* EIN/ -- *)     z    : COMPLEX;
               (* -- /AUS *) VAR ztan : COMPLEX );
(* [Abram70], 4.3.57 *)
VAR divisor : REAL;
#ifdef __NO_EXCEPTIONS__
    neg     : BOOLEAN;
    x       : REAL;
#endif

BEGIN
 z.re := scale(RE(z), 1);
 z.im := scale(IM(z), 1);

 divisor := RealMath.cos(RE(z)) + RealXMath.cosh(IM(z));
 IF divisor = 0.0 THEN
   (* Kann nur auftreten, wenn IM(z) = 0.0, da cosh nur bei 0.0 gleich
    * 1.0 liefert, sonst eine groessere Zahl. Ausserdem liefert cos(2x)
    * -1.0, wenn x ein ungerades Vielfaches von pi/2 ist.
    *)
#ifdef __NO_EXCEPTIONS__
   (* Algorithmus wie bei Real-tan *)
   x   := RE(z);
   neg := x < 0.0;
   IF neg THEN
     x := -x;
   END;
   IF x > pi THEN
     x := RealSupport.fmod(x, pi);
   END;
   IF x > pio2 THEN
     neg := ~neg;
   END;
   IF neg THEN
     ztan.re := -large;
   ELSE
     ztan.re := large;
   END;
   ztan.im := 0.0;
#else
   EXCEPTIONS.RAISE(cMathSource, ORD(complexTanOverflow),
                    "tan: CMPLX(real, 0.0) is odd multiple of pi/2");
#endif
 ELSE
   ztan.re := RealMath.sin(RE(z)) / divisor;
   ztan.im := RealXMath.sinh(IM(z)) / divisor;
 END;
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *)     z    : COMPLEX;
                     (* EIN/ -- *)     sin  : BOOLEAN;
                     (* -- /AUS *) VAR zarc : COMPLEX );

(* [Abram70], 4.4.37, 4.4.38:
 *
 *   z = x + iy
 *                _____________             _____________
 *   a := 0.5 * \/(x+1)^2 + y^2  +  0.5 * \/(x-1)^2 + y^2
 *
 *                _____________             _____________
 *   b := 0.5 * \/(x+1)^2 + y^2  -  0.5 * \/(x-1)^2 + y^2
 *
 *                                               _______
 *   arcsin(z) = arcsin(b) + sign(y) * iln(a + \/(a^2)-1 )
 *
 *                                               _______
 *   arccos(z) = arccos(b) - sign(y) * iln(a + \/(a^2)-1 )
 *)

VAR tmp1 : REAL;
    tmp2 : REAL;
    tmp3 : REAL;
    a    : REAL;
    b    : REAL;

BEGIN
 tmp1 := RE(z) + 1.0;
 tmp2 := RE(z) - 1.0;
 tmp3 := IM(z) * IM(z);

 tmp1 := RealMath.sqrt(tmp1 * tmp1 + tmp3);
 tmp2 := RealMath.sqrt(tmp2 * tmp2 + tmp3);

 a := scale(tmp1 + tmp2, -1);
 b := scale(tmp1 - tmp2, -1);

 tmp3 := RealMath.ln(a + RealMath.sqrt(a * a - 1.0));
 IF IM(z) < 0.0 THEN
   tmp3 := -tmp3;
 END;

 IF sin THEN
   zarc.re := RealMath.arcsin(b);
   zarc.im := tmp3;
 ELSE
   zarc.re := RealMath.arccos(b);
   zarc.im := -tmp3;
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin ((* EIN/ -- *)     z     : COMPLEX;
                  (* -- /AUS *) VAR zasin : COMPLEX );
(* [Abram70], 4.4.37 *)
BEGIN
 arcTrigon(z, TRUE, zasin);
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos ((* EIN/ -- *)     z     : COMPLEX;
                  (* -- /AUS *) VAR zacos : COMPLEX );
(* [Abram70], 4.4.38 *)
BEGIN
 arcTrigon(z, FALSE, zacos);
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan ((* EIN/ -- *)     z     : COMPLEX;
                  (* -- /AUS *) VAR zatan : COMPLEX );

(* [Abram70], 4.4.39:
 *
 * z = x + iy
 *
 *                              2 * x          i       x^2 + (y+1)^2
 * arctan(z) = 0.5 * arctan( ------------- ) + - * ln( ------------- )
 *                           1 - x^2 - y^2     4       x^2 + (y-1)^2
 *
 *         z^2 # -1 => z # +/-i
 *
 * arctan(y/x) wird dabei durch arctan2(y,x) ersetzt, um den
 * Bereich (-pi, pi] zu erhalten; ausserdem funktioniert arctan2 auch,
 * wenn der Nenner gleich Null ist.
 *)
VAR tmp1 : REAL;
    tmp2 : REAL;
    tmp3 : REAL;

BEGIN
 tmp1 := IM(z) + 1.0;
 tmp2 := IM(z) - 1.0;
 tmp3 := RE(z) * RE(z);

 zatan.re := scale(RealXMath.arctan2(scale(RE(z), 1), 1.0-tmp3-IM(z)*IM(z)), -1);
 zatan.im := scale(RealMath.ln((tmp3+tmp1*tmp1) / (tmp3+tmp2*tmp2)), -2);
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE polarToComplex ((* EIN/ -- *)     abs : REAL;
                          (* EIN/ -- *)     arg : REAL;
                          (* -- /AUS *) VAR z   : COMPLEX );
(* [Abram70], 3.7.2 *)
BEGIN
 RealXMath.polToRect(abs, arg, z.re, z.im);
END polarToComplex;

(*---------------------------------------------------------------------------*)

PROCEDURE scalarMult ((* EIN/ -- *)     scalar : REAL;
                      (* EIN/ -- *)     z      : COMPLEX;
                      (* -- /AUS *) VAR zscal  : COMPLEX );
BEGIN
 zscal.re := RE(z) * scalar;
 zscal.im := IM(z) * scalar;
END scalarMult;

(*---------------------------------------------------------------------------*)
#endif /* ISO_struct_return */

PROCEDURE IsCMathException(): BOOLEAN;
BEGIN
#ifdef __NO_EXCEPTIONS__
 RETURN(FALSE);
#else
 RETURN(EXCEPTIONS.IsCurrentSource(cMathSource));
#endif
END IsCMathException;

#if !ISO_complex
(*---------------------------------------------------------------------------*)
#undef RE
#undef IM
PROCEDURE RE ((* EIN/ -- *) z : COMPLEX ): REAL;
BEGIN
 RETURN(z.re);
END RE;

(*---------------------------------------------------------------------------*)

PROCEDURE IM ((* EIN/ -- *) z : COMPLEX ): REAL;
BEGIN
 RETURN(z.im);
END IM;
#endif
(*===========================================================================*)

BEGIN (* ComplexMath *)
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.AllocateSource(cMathSource);
#endif
#if !(ISO_value_constructor || ISO_complex)
  i.re    := 0.0;
  i.im    := 1.0;
  one.re  := 1.0;
  one.im  := 0.0;
  zero.re := 0.0;
  zero.im := 0.0;
#endif
END ComplexMath.
