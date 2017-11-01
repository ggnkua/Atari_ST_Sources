IMPLEMENTATION MODULE pMATHLIB;

(*
Parts of a portable MathLib0 Module :-(

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB IMPORT SIGNEDWORD;

#if (defined HM2)   || (defined XHM2)  || (defined MM2)   || \
    (defined TDIM2) || (defined LPRM2) || (defined FTLM2)
IMPORT MathLib0;
#elif (defined SPCM2)
IMPORT MathLib;
#else
IMPORT MathLib0;
#endif

PROCEDURE sqrt(x: REAL): REAL;
BEGIN
#if (defined HM2) || (defined XHM2)
  RETURN MathLib0.Sqrt(x);
#elif (defined MM2)   || (defined TDIM2) || (defined LPRM2) || \
      (defined FTLM2)
  RETURN MathLib0.sqrt(x);
#elif (defined SPCM2)
  RETURN MathLib.sqrt(x);
#else
  RETURN MathLib0.sqrt(x);
#endif
END sqrt;

PROCEDURE wordtoreal(x: SIGNEDWORD): REAL;
BEGIN
#if (defined HM2) || (defined XHM2)
  RETURN MathLib0.Real(x);
#elif (defined MM2)   || (defined TDIM2) || (defined LPRM2) || \
      (defined FTLM2)
  RETURN MathLib0.real(x);
#elif (defined SPCM2)
  RETURN MathLib.real(x);
#else
  RETURN MathLib0.real(x);
#endif
(*
  RETURN FLOAT(x);
  *)
END wordtoreal;

PROCEDURE realtoword(x: REAL): SIGNEDWORD;
BEGIN
#if (defined HM2) || (defined XHM2)
  RETURN MathLib0.Entier(x);
#elif (defined MM2)   || (defined TDIM2) || (defined LPRM2) || \
      (defined FTLM2)
  RETURN MathLib0.entier(x);
#elif (defined SPCM2)
  RETURN MathLib.entier(x);
#else
  RETURN MathLib0.entier(x);
#endif
END realtoword;

END pMATHLIB.