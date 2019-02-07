IMPLEMENTATION MODULE CXMath;
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

#if !ISO_complex
#  define RE(_Z) _Z ## .re
#  define IM(_Z) _Z ## .im
#endif

VAL_INTRINSIC
CAST_IMPORT

IMPORT RealMath, ComplexMath;

#if !ISO_complex
FROM ComplexMath IMPORT
(* TYPE *) COMPLEX;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if ISO_struct_return

PROCEDURE power ((* EIN/ -- *) z    : COMPLEX;
                 (* EIN/ -- *) base : REAL    ) : COMPLEX;

(* [Bron87], 3.4.4.2.3; [Abram70], 4.2.7:
 *
 *   base^z = e^(z*ln(base)), Hauptzweig
 *)
BEGIN
 RETURN(ComplexMath.exp(ComplexMath.scalarMult(RealMath.ln(base), z)));
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE log ((* EIN/ -- *) z    : COMPLEX;
               (* EIN/ -- *) base : REAL    ) : COMPLEX;

(* [Abram70], 4.1.18:
 *
 *   log[base](z) = ln(z) / ln(base), Hauptzweig
 *)
VAR rtmp : REAL;
    ctmp : COMPLEX;

BEGIN
 rtmp := RealMath.ln(base);
 ctmp := ComplexMath.ln(z);
#if ISO_complex
 RETURN(CMPLX(RE(ctmp) / rtmp, IM(ctmp) / rtmp));
#else
 ctmp.re := ctmp.re / rtmp;
 ctmp.im := ctmp.im / rtmp;
 RETURN(ctmp);
#endif
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.5.7; [Hart68], 6.2.7:
 *
 *   sinh(z) = -i * sin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : COMPLEX;
#if !ISO_complex
    rtmp : REAL;
#endif
BEGIN
#if ISO_complex
 ctmp := ComplexMath.sin(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := ComplexMath.sin(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.5.8; [Hart68], 6.2.7:
 *
 *   cosh(z) = cos(iz)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
#if !ISO_complex
VAR rtmp : REAL;
#endif
BEGIN
#if ISO_complex
 RETURN(ComplexMath.cos(CMPLX(-IM(z), RE(z)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;
 RETURN(ComplexMath.cos(z));
#endif
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.5.9; [Hart68], 6.2.7:
 *
 *   tanh(z) = -i * tan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : COMPLEX;
#if !ISO_complex
    rtmp : REAL;
#endif
BEGIN
#if ISO_complex
 ctmp := ComplexMath.tan(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := ComplexMath.tan(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.6.14:
 *
 *   arcsinh(z) = -i * arcsin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : COMPLEX;
#if !ISO_complex
    rtmp : REAL;
#endif
BEGIN
#if ISO_complex
 ctmp := ComplexMath.arcsin(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := ComplexMath.arcsin(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.6.15:
 *
 *   arccosh(z) = i * arccos(z)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
VAR ctmp : COMPLEX;
#if !ISO_complex
    rtmp : REAL;
#endif
BEGIN
 ctmp := ComplexMath.arccos(z);
#if ISO_complex
 RETURN(CMPLX(-IM(tmp), RE(tmp)));
#else
 rtmp    := ctmp.re;
 ctmp.re := -ctmp.im;
 ctmp.im := rtmp;
 RETURN(ctmp);
#endif
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh ((* EIN/ -- *) z : COMPLEX ) : COMPLEX;

(* [Abram70], 4.6.16:
 *
 *   arctanh(z) = -i * arctan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : COMPLEX;
#if !ISO_complex
    rtmp : REAL;
#endif
BEGIN
#if ISO_complex
 ctmp := ComplexMath.arctan(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := ComplexMath.arctan(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END arctanh;

#else /* ISO_struct_return */

PROCEDURE power ((* EIN/ -- *)     z    : COMPLEX;
                 (* EIN/ -- *)     base : REAL;
                 (* -- /AUS *) VAR zpow : COMPLEX );

(* [Bron87], 3.4.4.2.3; [Abram70], 4.2.7:
 *
 *   base^z = e^(z*ln(base)), Hauptzweig
 *)
BEGIN
 ComplexMath.scalarMult(RealMath.ln(base), z, z);
 ComplexMath.exp(z, zpow);
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE log ((* EIN/ -- *)     z    : COMPLEX;
               (* EIN/ -- *)     base : REAL;
               (* -- /AUS *) VAR zlog : COMPLEX );

(* [Abram70], 4.1.18:
 *
 *   log[base](z) = ln(z) / ln(base), Hauptzweig
 *)
VAR rtmp : REAL;

BEGIN
 rtmp := RealMath.ln(base);
 ComplexMath.ln(z, zlog);
 zlog.re := zlog.re / rtmp;
 zlog.im := zlog.im / rtmp;
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh ((* EIN/ -- *)     z     : COMPLEX;
                (* -- /AUS *) VAR zsinh : COMPLEX );

(* [Abram70], 4.5.7:
 *
 *   sinh(z) = -i * sin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : REAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ComplexMath.sin(z, zsinh);

 rtmp     := zsinh.re;
 zsinh.re := zsinh.im;
 zsinh.im := -rtmp;
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh ((* EIN/ -- *)     z     : COMPLEX;
                (* -- /AUS *) VAR zcosh : COMPLEX );

(* [Abram70], 4.5.8:
 *
 *   cosh(z) = cos(iz)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
VAR rtmp : REAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ComplexMath.cos(z, zcosh);
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh ((* EIN/ -- *)     z     : COMPLEX;
                (* -- /AUS *) VAR ztanh : COMPLEX );

(* [Abram70], 4.5.9:
 *
 *   tanh(z) = -i * tan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : REAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ComplexMath.tan(z, ztanh);

 rtmp     := ztanh.re;
 ztanh.re := ztanh.im;
 ztanh.im := -rtmp;
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh ((* EIN/ -- *)     z      : COMPLEX;
                   (* -- /AUS *) VAR zasinh : COMPLEX );

(* [Abram70], 4.6.14:
 *
 *   arcsinh(z) = -i * arcsin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : REAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ComplexMath.arcsin(z, zasinh);

 rtmp      := zasinh.re;
 zasinh.re := zasinh.im;
 zasinh.im := -rtmp;
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh ((* EIN/ -- *)     z      : COMPLEX;
                   (* -- /AUS *) VAR zacosh : COMPLEX );

(* [Abram70], 4.6.15:
 *
 *   arccosh(z) = i * arccos(z)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
VAR rtmp : REAL;

BEGIN
 ComplexMath.arccos(z, zacosh);

 rtmp      := zacosh.re;
 zacosh.re := -zacosh.im;
 zacosh.im := rtmp;
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh ((* EIN/ -- *)     z      : COMPLEX;
                   (* -- /AUS *) VAR zatanh : COMPLEX );

(* [Abram70], 4.6.16:
 *
 *   arctanh(z) = -i * arctan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : REAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ComplexMath.arctan(z, zatanh);

 rtmp      := zatanh.re;
 zatanh.re := zatanh.im;
 zatanh.im := -rtmp;
END arctanh;
#endif

END CXMath.
