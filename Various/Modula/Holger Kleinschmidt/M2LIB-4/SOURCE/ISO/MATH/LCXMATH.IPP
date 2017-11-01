IMPLEMENTATION MODULE LCXMath;
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

IMPORT LongMath, LongComplexMath;

#if !ISO_complex
FROM LongComplexMath IMPORT
(* TYPE *) LONGCOMPLEX;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if ISO_struct_return

PROCEDURE power ((* EIN/ -- *) z    : LONGCOMPLEX;
                 (* EIN/ -- *) base : LONGREAL    ) : LONGCOMPLEX;

(* [Bron87], 3.4.4.2.3; [Abram70], 4.2.7:
 *
 *   base^z = e^(z*ln(base)), Hauptzweig
 *)
BEGIN
 RETURN(LongComplexMath.exp(LongComplexMath.scalarMult(LongMath.ln(base), z)));
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE log ((* EIN/ -- *) z    : LONGCOMPLEX;
               (* EIN/ -- *) base : LONGREAL    ) : LONGCOMPLEX;

(* [Abram70], 4.1.18:
 *
 *   log[base](z) = ln(z) / ln(base), Hauptzweig
 *)
VAR rtmp : LONGREAL;
    ctmp : LONGCOMPLEX;

BEGIN
 rtmp := LongMath.ln(base);
 ctmp := LongComplexMath.ln(z);
#if ISO_complex
 RETURN(CMPLX(RE(ctmp) / rtmp, IM(ctmp) / rtmp));
#else
 ctmp.re := ctmp.re / rtmp;
 ctmp.im := ctmp.im / rtmp;
 RETURN(ctmp);
#endif
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

(* [Abram70], 4.5.7; [Hart68], 6.2.7:
 *
 *   sinh(z) = -i * sin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : LONGCOMPLEX;
#if !ISO_complex
    rtmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 ctmp := LongComplexMath.sin(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := LongComplexMath.sin(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

(* [Abram70], 4.5.8; [Hart68], 6.2.7:
 *
 *   cosh(z) = cos(iz)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
#if !ISO_complex
VAR rtmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 RETURN(LongComplexMath.cos(CMPLX(-IM(z), RE(z)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;
 RETURN(LongComplexMath.cos(z));
#endif
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

(* [Abram70], 4.5.9; [Hart68], 6.2.7:
 *
 *   tanh(z) = -i * tan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : LONGCOMPLEX;
#if !ISO_complex
    rtmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 ctmp := LongComplexMath.tan(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := LongComplexMath.tan(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

(* [Abram70], 4.6.14:
 *
 *   arcsinh(z) = -i * arcsin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : LONGCOMPLEX;
#if !ISO_complex
    rtmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 ctmp := LongComplexMath.arcsin(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := LongComplexMath.arcsin(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

(* [Abram70], 4.6.15:
 *
 *   arccosh(z) = i * arccos(z)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
VAR ctmp : LONGCOMPLEX;
#if !ISO_complex
    rtmp : LONGREAL;
#endif
BEGIN
 ctmp := LongComplexMath.arccos(z);
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

PROCEDURE arctanh ((* EIN/ -- *) z : LONGCOMPLEX ) : LONGCOMPLEX;

(* [Abram70], 4.6.16:
 *
 *   arctanh(z) = -i * arctan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR ctmp : LONGCOMPLEX;
#if !ISO_complex
    rtmp : LONGREAL;
#endif
BEGIN
#if ISO_complex
 ctmp := LongComplexMath.arctan(CMPLX(-IM(z), RE(z));
 RETURN(CMPLX(IM(ctmp), -RE(ctmp)));
#else
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 ctmp := LongComplexMath.arctan(z);

 rtmp    := ctmp.re;
 ctmp.re := ctmp.im;
 ctmp.im := -rtmp;
 RETURN(ctmp);
#endif
END arctanh;

#else /* ISO_struct_return */

PROCEDURE power ((* EIN/ -- *)     z    : LONGCOMPLEX;
                 (* EIN/ -- *)     base : LONGREAL;
                 (* -- /AUS *) VAR zpow : LONGCOMPLEX );

(* [Bron87], 3.4.4.2.3; [Abram70], 4.2.7:
 *
 *   base^z = e^(z*ln(base)), Hauptzweig
 *)
BEGIN
 LongComplexMath.scalarMult(LongMath.ln(base), z, z);
 LongComplexMath.exp(z, zpow);
END power;

(*---------------------------------------------------------------------------*)

PROCEDURE log ((* EIN/ -- *)     z    : LONGCOMPLEX;
               (* EIN/ -- *)     base : LONGREAL;
               (* -- /AUS *) VAR zlog : LONGCOMPLEX );

(* [Abram70], 4.1.18:
 *
 *   log[base](z) = ln(z) / ln(base), Hauptzweig
 *)
VAR rtmp : LONGREAL;

BEGIN
 rtmp := LongMath.ln(base);
 LongComplexMath.ln(z, zlog);
 zlog.re := zlog.re / rtmp;
 zlog.im := zlog.im / rtmp;
END log;

(*---------------------------------------------------------------------------*)

PROCEDURE sinh ((* EIN/ -- *)     z     : LONGCOMPLEX;
                (* -- /AUS *) VAR zsinh : LONGCOMPLEX );

(* [Abram70], 4.5.7:
 *
 *   sinh(z) = -i * sin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : LONGREAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 LongComplexMath.sin(z, zsinh);

 rtmp     := zsinh.re;
 zsinh.re := zsinh.im;
 zsinh.im := -rtmp;
END sinh;

(*---------------------------------------------------------------------------*)

PROCEDURE cosh ((* EIN/ -- *)     z     : LONGCOMPLEX;
                (* -- /AUS *) VAR zcosh : LONGCOMPLEX );

(* [Abram70], 4.5.8:
 *
 *   cosh(z) = cos(iz)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
VAR rtmp : LONGREAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 LongComplexMath.cos(z, zcosh);
END cosh;

(*---------------------------------------------------------------------------*)

PROCEDURE tanh ((* EIN/ -- *)     z     : LONGCOMPLEX;
                (* -- /AUS *) VAR ztanh : LONGCOMPLEX );

(* [Abram70], 4.5.9:
 *
 *   tanh(z) = -i * tan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : LONGREAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 LongComplexMath.tan(z, ztanh);

 rtmp     := ztanh.re;
 ztanh.re := ztanh.im;
 ztanh.im := -rtmp;
END tanh;

(*---------------------------------------------------------------------------*)

PROCEDURE arcsinh ((* EIN/ -- *)     z      : LONGCOMPLEX;
                   (* -- /AUS *) VAR zasinh : LONGCOMPLEX );

(* [Abram70], 4.6.14:
 *
 *   arcsinh(z) = -i * arcsin(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : LONGREAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 LongComplexMath.arcsin(z, zasinh);

 rtmp      := zasinh.re;
 zasinh.re := zasinh.im;
 zasinh.im := -rtmp;
END arcsinh;

(*---------------------------------------------------------------------------*)

PROCEDURE arccosh ((* EIN/ -- *)     z      : LONGCOMPLEX;
                   (* -- /AUS *) VAR zacosh : LONGCOMPLEX );

(* [Abram70], 4.6.15:
 *
 *   arccosh(z) = i * arccos(z)
 *
 *   iz =  i(x + iy) = (-y + ix)
 *)
VAR rtmp : LONGREAL;

BEGIN
 LongComplexMath.arccos(z, zacosh);

 rtmp      := zacosh.re;
 zacosh.re := -zacosh.im;
 zacosh.im := rtmp;
END arccosh;

(*---------------------------------------------------------------------------*)

PROCEDURE arctanh ((* EIN/ -- *)     z      : LONGCOMPLEX;
                   (* -- /AUS *) VAR zatanh : LONGCOMPLEX );

(* [Abram70], 4.6.16:
 *
 *   arctanh(z) = -i * arctan(iz)
 *
 *    iz =  i(x + iy) = (-y + ix)
 *   -iz = -i(x + iy) = ( y - ix)
 *)
VAR rtmp : LONGREAL;

BEGIN
 rtmp := z.re;
 z.re := -z.im;
 z.im := rtmp;

 LongComplexMath.arctan(z, zatanh);

 rtmp      := zatanh.re;
 zatanh.re := zatanh.im;
 zatanh.im := -rtmp;
END arctanh;
#endif

END LCXMath.
