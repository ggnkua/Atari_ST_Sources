IMPLEMENTATION MODULE LongComplexMath;
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
(* 02-Nov-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

#if 0
#define __NO_EXCEPTIONS__
#endif

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHMEN:
   1) LowLong.radix = 2, d.h. LowLong.scale multipliziert mit bzw. dividiert
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

FROM LowLong IMPORT
(* CONST*) large,
(* PROC *) scale;

IMPORT LongSupport, LongMath, LongXMath;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if LONGREAL_var
VAR
  null  : LONGREAL;
  One   : LONGREAL;
  pi    : LONGREAL;
  pio2  : LONGREAL;
  pio4  : LONGREAL;
#else
CONST
  null  = LRC(0.0,0);
  One   = LRC(1.0,0);
  pi    = LRC(3.14159265358979323846264338327950288,0);  (* Pi *)
  pio2  = LRC(1.57079632679489661923132169163975144,0);  (* Pi/2 *)
  pio4  = LRC(0.78539816339744830961566084581987572,0);  (* Pi/4 *)
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
#endif

#ifndef __NO_EXCEPTIONS__
VAR
  longCMathSource : EXCEPTIONS.ExceptionSource;
#endif

TYPE
  ComplexExceptions = (
    zeroArgParameter,
    complexTanOverflow
  );

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#if !ISO_complex
PROCEDURE cequ ((* EIN/ -- *) z1 : LONGCOMPLEX;
                (* EIN/ -- *) z2 : LONGCOMPLEX ): BOOLEAN;
(* [Bron87], 3.4.2.1 (1) *)
BEGIN
 RETURN((RE(z1) = RE(z2)) & (IM(z1) = IM(z2)));
END cequ;

(*---------------------------------------------------------------------------*)

#if ISO_struct_return
PROCEDURE cneg ((* EIN/ -- *) z : LONGCOMPLEX ): LONGCOMPLEX;
BEGIN
 z.re := -RE(z);
 z.im := -IM(z);
 RETURN(z);
END cneg;

(*---------------------------------------------------------------------------*)

PROCEDURE CMPLX ((* EIN/ -- *) re : LONGREAL;
                 (* EIN/ -- *) im : LONGREAL ): LONGCOMPLEX;

VAR z : LONGCOMPLEX;

BEGIN
 z.re := re;
 z.im := im;
 RETURN(z);
END CMPLX;

(*---------------------------------------------------------------------------*)

PROCEDURE cadd ((* EIN/ -- *) z1 : LONGCOMPLEX;
                (* EIN/ -- *) z2 : LONGCOMPLEX ): LONGCOMPLEX;
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 z1.re := RE(z1) + RE(z2);
 z1.im := IM(z1) + IM(z2);
 RETURN(z1);
END cadd;

(*---------------------------------------------------------------------------*)

PROCEDURE csub ((* EIN/ -- *) z1 : LONGCOMPLEX;
                (* EIN/ -- *) z2 : LONGCOMPLEX ): LONGCOMPLEX;
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 z1.re := RE(z1) - RE(z2);
 z1.im := IM(z1) - IM(z2);
 RETURN(z1);
END csub;

(*---------------------------------------------------------------------------*)

PROCEDURE cmul ((* EIN/ -- *) z1 : LONGCOMPLEX;
                (* EIN/ -- *) z2 : LONGCOMPLEX ): LONGCOMPLEX;
(* [Abram70], 3.7.10; [Bron87], 3.4.2.1 (3) *)
BEGIN
 z1.re := RE(z1) * RE(z2) - IM(z1) * IM(z2);
 z1.im := RE(z1) * IM(z2) + IM(z1) * RE(z2);
 RETURN(z1);
END cmul;

(*---------------------------------------------------------------------------*)

PROCEDURE cdiv ((* EIN/ -- *) z1 : LONGCOMPLEX;
                (* EIN/ -- *) z2 : LONGCOMPLEX ): LONGCOMPLEX;

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
VAR tmp1 : LONGREAL;
    tmp2 : LONGREAL;

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
#else /* ISO_struct_return */
PROCEDURE cneg ((* EIN/ -- *)     z    : LONGCOMPLEX;
                (* -- /AUS *) VAR zneg : LONGCOMPLEX );
BEGIN
 zneg.re := -RE(z);
 zneg.im := -IM(z);
END cneg;

(*---------------------------------------------------------------------------*)

PROCEDURE CMPLX ((* EIN/ -- *)     re : LONGREAL;
                 (* EIN/ -- *)     im : LONGREAL;
                 (* -- /AUS *) VAR z  : LONGCOMPLEX );
BEGIN
 z.re := re;
 z.im := im;
END CMPLX;

(*---------------------------------------------------------------------------*)

PROCEDURE cadd ((* EIN/ -- *)     z1   : LONGCOMPLEX;
                (* EIN/ -- *)     z2   : LONGCOMPLEX;
                (* -- /AUS *) VAR zadd : LONGCOMPLEX );
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 zadd.re := RE(z1) + RE(z2);
 zadd.im := IM(z1) + IM(z2);
END cadd;

(*---------------------------------------------------------------------------*)

PROCEDURE csub ((* EIN/ -- *)     z1   : LONGCOMPLEX;
                (* EIN/ -- *)     z2   : LONGCOMPLEX;
                (* -- /AUS *) VAR zsub : LONGCOMPLEX );
(* [Bron87], 3.4.2.1 (2) *)
BEGIN
 zsub.re := RE(z1) - RE(z2);
 zsub.im := IM(z1) - IM(z2);
END csub;

(*---------------------------------------------------------------------------*)

PROCEDURE cmul ((* EIN/ -- *)     z1   : LONGCOMPLEX;
                (* EIN/ -- *)     z2   : LONGCOMPLEX;
                (* -- /AUS *) VAR zmul : LONGCOMPLEX );
(* [Abram70], 3.7.10; [Bron87], 3.4.2.1 (3) *)
BEGIN
 zmul.re := RE(z1) * RE(z2) - IM(z1) * IM(z2);
 zmul.im := RE(z1) * IM(z2) + IM(z1) * RE(z2);
END cmul;

(*---------------------------------------------------------------------------*)

PROCEDURE cdiv ((* EIN/ -- *)     z1   : LONGCOMPLEX;
                (* EIN/ -- *)     z2   : LONGCOMPLEX;
                (* -- /AUS *) VAR zdiv : LONGCOMPLEX );

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
VAR tmp1 : LONGREAL;
    tmp2 : LONGREAL;

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

PROCEDURE abs ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGREAL;
(* [Abram70], 3.7.3; [Bron87], 3.4.2.2 *)
BEGIN
 RETURN(LongXMath.hypot(RE(z), IM(z)));
END abs;

(*---------------------------------------------------------------------------*)

PROCEDURE arg ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGREAL;
(* [Bron87], 3.4.2.4 *)
BEGIN
 IF (RE(z) = null) & (IM(z) = null) THEN
#ifdef __NO_EXCEPTIONS__
   RETURN(null);
#else
   EXCEPTIONS.RAISE(longCMathSource, ORD(zeroArgParameter),
                    "arg: argument equals CMPLX(0.0, 0.0)");
#endif
 END;
 RETURN(LongXMath.arctan2(IM(z), RE(z)));
END arg;

(*---------------------------------------------------------------------------*)

#if ISO_struct_return
PROCEDURE conj ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
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

PROCEDURE power ((* EIN/ -- *) base     : LONGCOMPLEX;
                 (* EIN/ -- *) exponent : LONGREAL    ) : LONGCOMPLEX;
(* [Bron87], 3.4.2.5.4 *)
VAR absToX : LONGREAL;
    argX   : LONGREAL;

BEGIN
 absToX := LongMath.power(abs(base), exponent);
 argX   := exponent * arg(base);
#if ISO_complex
 RETURN(CMPLX(absToX * LongMath.cos(argX), absToX * LongMath.sin(argX)));
#else
 base.re := absToX * LongMath.cos(argX);
 base.im := absToX * LongMath.sin(argX);
 RETURN(base);
#endif
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
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

VAR addRoot : LONGREAL;
    subRoot : LONGREAL;
    negReal : BOOLEAN;
    negImag : BOOLEAN;

BEGIN
#if ISO_complex
 IF z = CMPLX(null, null) THEN
   RETURN(z);
 END;

 negReal := RE(z) < null;
 IF negReal THEN
   z := CMPLX(-RE(z), IM(z));
 END;
 negImag := IM(z) < null;
 IF negImag THEN
   z := CMPLX(RE(z), -IM(z));
 END;

 addRoot := LongMath.sqrt(scale(abs(z) + RE(z), -1));
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
 IF (RE(z) = null) & (IM(z) = null) THEN
   RETURN(z);
 END;

 negReal := RE(z) < null;
 IF negReal THEN
   z.re := -RE(z);
 END;
 negImag := IM(z) < null;
 IF negImag THEN
   z.im := -IM(z);
 END;

 addRoot := LongMath.sqrt(scale(abs(z) + RE(z), -1));
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

PROCEDURE exp ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
(* [Bron87], 3.4.4.2.1 *)
VAR eToReX : LONGREAL;

BEGIN
 eToReX := LongMath.exp(RE(z));

#if ISO_complex
 RETURN(CMPLX(eToReX * LongMath.cos(IM(z)), eToReX * LongMath.sin(IM(z))));
#else
 z.re := eToReX * LongMath.cos(IM(z));
 z.im := eToReX * LongMath.sin(IM(z));
 RETURN(z);
#endif
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
(* [Abram70], 4.1.2; [Bron87], 3.4.4.2.2 *)
#if !ISO_complex
VAR tmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 RETURN(CMPLX(LongMath.ln(abs(z)), arg(z)));
#else
 tmp  := LongMath.ln(abs(z));
 z.im := arg(z);
 z.re := tmp;
 RETURN(z);
#endif
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE sin ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
(* [Abram70], 4.3.55; [Bron87], Tab 3.7 *)
#if !ISO_complex
VAR tmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 RETURN(CMPLX(LongMath.sin(RE(z)) * LongXMath.cosh(IM(z)),
              LongMath.cos(RE(z)) * LongXMath.sinh(IM(z))));
#else
 tmp  := LongMath.sin(RE(z)) * LongXMath.cosh(IM(z));
 z.im := LongMath.cos(RE(z)) * LongXMath.sinh(IM(z));
 z.re := tmp;
 RETURN(z);
#endif
END sin;

(*---------------------------------------------------------------------------*)

PROCEDURE cos ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
(* [Abram70], 4.3.56; [Bron87], Tab 3.7 *)
#if !ISO_complex
VAR tmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 RETURN(CMPLX(LongMath.cos(RE(z)) * LongXMath.cosh(IM(z)),
              -LongMath.sin(RE(z)) * LongXMath.sinh(IM(z))));
#else
 tmp  := LongMath.cos(RE(z)) * LongXMath.cosh(IM(z));
 z.im := -LongMath.sin(RE(z)) * LongXMath.sinh(IM(z));
 z.re := tmp;
 RETURN(z);
#endif
END cos;

(*---------------------------------------------------------------------------*)

PROCEDURE tan ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
(* [Abram70], 4.3.57 *)
VAR divisor : LONGREAL;
#ifdef __NO_EXCEPTIONS__
    neg     : BOOLEAN;
    x       : LONGREAL;
#endif

BEGIN
#if ISO_complex
 z := CMPLX(scale(RE(z), 1), scale(IM(z), 1));
#else
 z.re := scale(RE(z), 1);
 z.im := scale(IM(z), 1);
#endif
 divisor := LongMath.cos(RE(z)) + LongXMath.cosh(IM(z));
 IF divisor = null THEN
   (* Kann nur auftreten, wenn IM(z) = 0.0, da cosh nur bei 0.0 gleich
    * 1.0 liefert, sonst eine groessere Zahl. Ausserdem liefert cos(2x)
    * -1.0, wenn x ein ungerades Vielfaches von pi/2 ist.
    *)
#ifdef __NO_EXCEPTIONS__
   (* Algorithmus wie bei Real-tan *)
   x   := RE(z);
   neg := x < null;
   IF neg THEN
     x := -x;
   END;
   IF x > pi THEN
     x := LongSupport.fmod(x, pi);
   END;
   IF x > pio2 THEN
     neg := ~neg;
   END;
#if ISO_complex
   IF neg THEN
     RETURN(CMPLX(-large, null));
   ELSE
     RETURN(CMPLX(large, null));
   END;
#else
   IF neg THEN
     z.re := -large;
   ELSE
     z.re := large;
   END;
   z.im := null;
   RETURN(z);
#endif
#else
   EXCEPTIONS.RAISE(longCMathSource, ORD(complexTanOverflow),
                    "tan: CMPLX(real, 0.0) is odd multiple of pi/2");
#endif
 ELSE
#if ISO_complex
   RETURN(CMPLX(LongMath.sin(RE(z)) / divisor, LongXMath.sinh(IM(z)) / divisor));
#else
   z.re := LongMath.sin(RE(z)) / divisor;
   z.im := LongXMath.sinh(IM(z)) / divisor;
   RETURN(z);
#endif
 END;
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *) z   : LONGCOMPLEX;
                     (* EIN/ -- *) sin : BOOLEAN     ): LONGCOMPLEX;

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

VAR tmp1 : LONGREAL;
    tmp2 : LONGREAL;
    tmp3 : LONGREAL;
    a    : LONGREAL;
    b    : LONGREAL;

BEGIN
 tmp1 := RE(z) + One;
 tmp2 := RE(z) - One;
 tmp3 := IM(z) * IM(z);

 tmp1 := LongMath.sqrt(tmp1 * tmp1 + tmp3);
 tmp2 := LongMath.sqrt(tmp2 * tmp2 + tmp3);

 a := scale(tmp1 + tmp2, -1);
 b := scale(tmp1 - tmp2, -1);

 tmp3 := LongMath.ln(a + LongMath.sqrt(a * a - One));
 IF IM(z) < null THEN
   tmp3 := -tmp3;
 END;

 IF sin THEN
#if ISO_complex
   RETURN(CMPLX(LongMath.arcsin(b), tmp3));
#else
   z.re := LongMath.arcsin(b);
   z.im := tmp3;
   RETURN(z);
#endif
 ELSE
#if ISO_complex
   RETURN(CMPLX(LongMath.arccos(b), -tmp3));
#else
   z.re := LongMath.arccos(b);
   z.im := -tmp3;
   RETURN(z);
#endif
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
BEGIN
 RETURN(arcTrigon(z, TRUE));
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;
BEGIN
 RETURN(arcTrigon(z, FALSE));
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

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
VAR tmp1 : LONGREAL;
    tmp2 : LONGREAL;
    tmp3 : LONGREAL;

BEGIN
 tmp1 := IM(z) + One;
 tmp2 := IM(z) - One;
 tmp3 := RE(z) * RE(z);

 tmp1 := scale(LongMath.ln((tmp3+tmp1*tmp1) / (tmp3+tmp2*tmp2)), -2);
 tmp2 := scale(LongXMath.arctan2(scale(RE(z), 1), One-tmp3-IM(z)*IM(z)), -1);

#if ISO_complex
 RETURN(CMPLX(tmp2, tmp1));
#else
 z.re := tmp2;
 z.im := tmp1;
 RETURN(z);
#endif
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE polarToComplex ((* EIN/ -- *) abs : LONGREAL;
                          (* EIN/ -- *) arg : LONGREAL ) : LONGCOMPLEX;
(* [Abram70], 3.7.2 *)
#if ISO_complex
VAR x : LONGREAL;
    y : LONGREAL;
#else
VAR z : LONGCOMPLEX;
#endif
BEGIN
#if ISO_complex
 LongXMath.polToRect(abs, arg, x, y);
 RETURN(CMPLX(x, y));
#else
 LongXMath.polToRect(abs, arg, z.re, z.im);
 RETURN(z);
#endif
END polarToComplex;

(*---------------------------------------------------------------------------*)

PROCEDURE scalarMult ((* EIN/ -- *) scalar : LONGREAL;
                      (* EIN/ -- *) z      : LONGCOMPLEX ): LONGCOMPLEX;
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

PROCEDURE conj ((* EIN/ -- *)     z     : LONGCOMPLEX;
                (* -- /AUS *) VAR zconj : LONGCOMPLEX );
BEGIN
 zconj.re := RE(z);
 zconj.im := -IM(z);
END conj;

(*---------------------------------------------------------------------------*)

PROCEDURE power ((* EIN/ -- *)     base     : LONGCOMPLEX;
                 (* EIN/ -- *)     exponent : LONGREAL;
                 (* -- /AUS *) VAR zpow     : LONGCOMPLEX );
(* [Bron87], 3.4.2.5.4 *)
VAR absToX : LONGREAL;
    argX   : LONGREAL;

BEGIN
 absToX  := LongMath.power(abs(base), exponent);
 argX    := exponent * arg(base);
 zpow.re := absToX * LongMath.cos(argX);
 zpow.im := absToX * LongMath.sin(argX);
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE sqrt ((* EIN/ -- *)     z     : LONGCOMPLEX;
                (* -- /AUS *) VAR zsqrt : LONGCOMPLEX );

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
 *       _____________      Der Bruch wird mit -(y^2) erweitert.
 *      / |z| - |x|         Im Nenner wird zusaetzlich eine Null
 *     / ------------       " x^2 - x^2  =  0 " addiert, und mit
 *   \/       2             " x^2 - x^2 - y^2  =  x^2 - (x^2 + y^2) "
 *                          erhaelt man:
 *
 *         ________________________
 *        /  (|x| - |z|) * y^2           Im Nenner laesst sich die dritte
 *  =    / -------------------------     binomische Formel anwenden
 *     \/  2 * (x^2 - ( x^2 + y^2 ))     " a^2 - b^2  =  (a - b) * (a + b) "
 *                                       mit  a^2:=x^2  ,  b^2:=x^2 + y^2 :
 *
 *         ________________________
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

VAR addRoot : LONGREAL;
    subRoot : LONGREAL;
    negReal : BOOLEAN;
    negImag : BOOLEAN;

BEGIN
 IF (RE(z) = null) & (IM(z) = null) THEN
   zsqrt := z;
   RETURN;
 END;

 negReal := RE(z) < null;
 IF negReal THEN
   z.re := -RE(z);
 END;
 negImag := IM(z) < null;
 IF negImag THEN
   z.im := -IM(z);
 END;

 addRoot := LongMath.sqrt(scale(abs(z) + RE(z), -1));
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

PROCEDURE exp ((* EIN/ -- *)     z    : LONGCOMPLEX;
               (* -- /AUS *) VAR zexp : LONGCOMPLEX );
(* [Bron87], 3.4.4.2.1 *)
VAR eToReX : LONGREAL;

BEGIN
 eToReX  := LongMath.exp(RE(z));

 zexp.re := eToReX * LongMath.cos(IM(z));
 zexp.im := eToReX * LongMath.sin(IM(z));
END exp;

(*---------------------------------------------------------------------------*)

PROCEDURE ln ((* EIN/ -- *)     z   : LONGCOMPLEX;
              (* -- /AUS *) VAR zln : LONGCOMPLEX );
(* [Abram70], 4.1.2; [Bron87], 3.4.4.2.2 *)
BEGIN
 zln.re := LongMath.ln(abs(z));
 zln.im := arg(z);
END ln;

(*---------------------------------------------------------------------------*)

PROCEDURE sin ((* EIN/ -- *)     z    : LONGCOMPLEX;
               (* -- /AUS *) VAR zsin : LONGCOMPLEX );
(* [Abram70], 4.3.55; [Bron87], Tab 3.7 *)
BEGIN
 zsin.re := LongMath.sin(RE(z)) * LongXMath.cosh(IM(z));
 zsin.im := LongMath.cos(RE(z)) * LongXMath.sinh(IM(z));
END sin;

(*---------------------------------------------------------------------------*)

PROCEDURE cos ((* EIN/ -- *)     z    : LONGCOMPLEX;
               (* -- /AUS *) VAR zcos : LONGCOMPLEX );
(* [Abram70], 4.3.56; [Bron87], Tab 3.7 *)
BEGIN
 zcos.re := LongMath.cos(RE(z)) * LongXMath.cosh(IM(z));
 zcos.im := -LongMath.sin(RE(z)) * LongXMath.sinh(IM(z));
END cos;

(*---------------------------------------------------------------------------*)

PROCEDURE tan ((* EIN/ -- *)     z    : LONGCOMPLEX;
               (* -- /AUS *) VAR ztan : LONGCOMPLEX );
(* [Abram70], 4.3.57 *)
VAR divisor : LONGREAL;
#ifdef __NO_EXCEPTIONS__
    neg     : BOOLEAN;
    x       : LONGREAL;
#endif

BEGIN
 z.re := scale(RE(z), 1);
 z.im := scale(IM(z), 1);

 divisor := LongMath.cos(RE(z)) + LongXMath.cosh(IM(z));
 IF divisor = null THEN
   (* Kann nur auftreten, wenn IM(z) = 0.0, da cosh nur bei 0.0 gleich
    * 1.0 liefert, sonst eine groessere Zahl. Ausserdem liefert cos(2x)
    * -1.0, wenn x ein ungerades Vielfaches von pi/2 ist.
    *)
#ifdef __NO_EXCEPTIONS__
   (* Algorithmus wie bei Real-tan *)
   x   := RE(z);
   neg := x < null;
   IF neg THEN
     x := -x;
   END;
   IF x > pi THEN
     x := LongSupport.fmod(x, pi);
   END;
   IF x > pio2 THEN
     neg := ~neg;
   END;
   IF neg THEN
     ztan.re := -large;
   ELSE
     ztan.re := large;
   END;
   ztan.im := null;
#else
   EXCEPTIONS.RAISE(longCMathSource, ORD(complexTanOverflow),
                    "tan: CMPLX(real, 0.0) is odd multiple of pi/2");
#endif
 ELSE
   ztan.re := LongMath.sin(RE(z)) / divisor;
   ztan.im := LongXMath.sinh(IM(z)) / divisor;
 END;
END tan;

(*---------------------------------------------------------------------------*)

PROCEDURE arcTrigon ((* EIN/ -- *)     z    : LONGCOMPLEX;
                     (* EIN/ -- *)     sin  : BOOLEAN;
                     (* -- /AUS *) VAR zarc : LONGCOMPLEX );

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

VAR tmp1 : LONGREAL;
    tmp2 : LONGREAL;
    tmp3 : LONGREAL;
    a    : LONGREAL;
    b    : LONGREAL;

BEGIN
 tmp1 := RE(z) + One;
 tmp2 := RE(z) - One;
 tmp3 := IM(z) * IM(z);

 tmp1 := LongMath.sqrt(tmp1 * tmp1 + tmp3);
 tmp2 := LongMath.sqrt(tmp2 * tmp2 + tmp3);

 a := scale(tmp1 + tmp2, -1);
 b := scale(tmp1 - tmp2, -1);

 tmp3 := LongMath.ln(a + LongMath.sqrt(a * a - One));
 IF IM(z) < null THEN
   tmp3 := -tmp3;
 END;

 IF sin THEN
   zarc.re := LongMath.arcsin(b);
   zarc.im := tmp3;
 ELSE
   zarc.re := LongMath.arccos(b);
   zarc.im := -tmp3;
 END;
END arcTrigon;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsin ((* EIN/ -- *)     z     : LONGCOMPLEX;
                  (* -- /AUS *) VAR zasin : LONGCOMPLEX );
(* [Abram70], 4.4.37 *)
BEGIN
 arcTrigon(z, TRUE, zasin);
END arcsin;

(*---------------------------------------------------------------------------*)

PROCEDURE arccos ((* EIN/ -- *)     z     : LONGCOMPLEX;
                  (* -- /AUS *) VAR zacos : LONGCOMPLEX );
(* [Abram70], 4.4.38 *)
BEGIN
 arcTrigon(z, FALSE, zacos);
END arccos;

(*---------------------------------------------------------------------------*)

PROCEDURE arctan ((* EIN/ -- *)     z     : LONGCOMPLEX;
                  (* -- /AUS *) VAR zatan : LONGCOMPLEX );

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
VAR tmp1 : LONGREAL;
    tmp2 : LONGREAL;
    tmp3 : LONGREAL;

BEGIN
 tmp1 := IM(z) + One;
 tmp2 := IM(z) - One;
 tmp3 := RE(z) * RE(z);

 zatan.re := scale(LongXMath.arctan2(scale(RE(z), 1), One-tmp3-IM(z)*IM(z)), -1);
 zatan.im := scale(LongMath.ln((tmp3+tmp1*tmp1) / (tmp3+tmp2*tmp2)), -2);
END arctan;

(*---------------------------------------------------------------------------*)

PROCEDURE polarToComplex ((* EIN/ -- *)     abs : LONGREAL;
                          (* EIN/ -- *)     arg : LONGREAL;
                          (* -- /AUS *) VAR z   : LONGCOMPLEX );
(* [Abram70], 3.7.2 *)
BEGIN
 LongXMath.polToRect(abs, arg, z.re, z.im);
END polarToComplex;

(*---------------------------------------------------------------------------*)

PROCEDURE scalarMult ((* EIN/ -- *)     scalar : LONGREAL;
                      (* EIN/ -- *)     z      : LONGCOMPLEX;
                      (* -- /AUS *) VAR zscal  : LONGCOMPLEX );
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
 RETURN(EXCEPTIONS.IsCurrentSource(longCMathSource));
#endif
END IsCMathException;

#if !ISO_complex
(*---------------------------------------------------------------------------*)
#undef RE
#undef IM
PROCEDURE RE ((* EIN/ -- *) z : LONGCOMPLEX ): LONGREAL;
BEGIN
 RETURN(z.re);
END RE;

(*---------------------------------------------------------------------------*)

PROCEDURE IM ((* EIN/ -- *) z : LONGCOMPLEX ): LONGREAL;
BEGIN
 RETURN(z.im);
END IM;
#endif
(*===========================================================================*)

BEGIN (* LongComplexMath *)
#ifndef __NO_EXCEPTIONS__
 EXCEPTIONS.AllocateSource(longCMathSource);
#endif
#if LONGREAL_var
 WITH cast DO
   lc1 := 000000000H; lc2 := 000000000H; null  := lr;
   lc1 := 03FF00000H; (* wie oben *)     One   := lr;

   lc1 := 0400921FBH; lc2 := 054442D17H; pi   := lr; (* 3.14159265358979E+0 *)
   lc1 := 03FF921FBH; (* wie oben *)     pio2 := lr; (* 1.57079632679489E+0 *)
   lc1 := 03FE921FBH; (* wie oben *)     pio4 := lr; (* 7.85398163397447E-1 *)
 END;
#endif
#if !(ISO_value_constructor || ISO_complex)
  i.re    := null;
  i.im    := One;
  one.re  := One;
  one.im  := null;
  zero.re := null;
  zero.im := null;
#endif
END LongComplexMath.
