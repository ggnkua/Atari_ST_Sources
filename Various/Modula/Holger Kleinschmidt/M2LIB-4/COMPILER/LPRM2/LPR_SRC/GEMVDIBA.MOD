IMPLEMENTATION MODULE  GEMVDIbase;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul    hk , Feb-90                    *)
(*                                                                           *)
(*****************************************************************************)
(*                                                                           *)
(* Offsets der Variablen zur Modulbasis ( sedezimal ):                       *)
(*                                                                           *)
(*    contrl          -$ 34                                                  *)
(*    intin           -$134                                                  *)
(*    ptsin           -$234                                                  *)
(*    intout          -$334                                                  *)
(*    ptsout          -$434                                                  *)
(*    i               -$436                                                  *)
(*    h               -$438                                                  *)
(*    ADRintin        -$43C                                                  *)
(*    ADRptsin        -$440                                                  *)
(*    ADRintout       -$444                                                  *)
(*    ADRptsout       -$448                                                  *)
(*    ADRParams       -$44C                                                  *)
(*    parameterBlock  -$460                                                  *)
(*                                                                           *)
(*****************************************************************************)

FROM  SYSTEM  IMPORT  (* PROC *)  INLINE, SETREG, ADR;


CONST  d0    = 0;
       d1    = 1;

       VDIopcode = 115D;
       GEMtrap   = 4E42H;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE  CallVDI;

  BEGIN
    SETREG( d0, VDIopcode );
    SETREG( d1, ADRParams );

    INLINE( GEMtrap );
  END  CallVDI;

(*---------------------------------------------------------------------------*)

PROCEDURE  SetContrl ((* EIN/ -- *) c0,
                      (* EIN/ -- *) c1,
                      (* EIN/ -- *) c3,
                      (* EIN/ -- *) c5,
                      (* EIN/ -- *) c6 : INTEGER );

  BEGIN
    contrl[ 0 ] := c0;
    contrl[ 1 ] := c1;
    contrl[ 3 ] := c3;
    contrl[ 5 ] := c5;
    contrl[ 6 ] := c6;
  END  SetContrl;

(*---------------------------------------------------------------------------*)

PROCEDURE  CallVDI2 ((* EIN/ -- *) function : INTEGER;
                     (* EIN/ -- *) handle   : INTEGER );

  BEGIN
    contrl[ 0 ] := function;
    contrl[ 1 ] := 0;
    contrl[ 2 ] := 0;
    contrl[ 3 ] := 0;
    contrl[ 4 ] := 0;
    contrl[ 5 ] := 0;
    contrl[ 6 ] := handle;

    SETREG( d0, VDIopcode );
    SETREG( d1, ADRParams );

    INLINE( GEMtrap );
  END  CallVDI2;

(*---------------------------------------------------------------------------*)

PROCEDURE  CallVDI4 ((* EIN/ -- *) function : INTEGER;
                     (* EIN/ -- *) handle   : INTEGER;
                     (* EIN/ -- *) pts      : INTEGER;
                     (* EIN/ -- *) int      : INTEGER );

  BEGIN
    contrl[ 0 ] := function;
    contrl[ 1 ] := pts;
    contrl[ 2 ] := 0;
    contrl[ 3 ] := int;
    contrl[ 4 ] := 0;
    contrl[ 5 ] := 0;
    contrl[ 6 ] := handle;

    SETREG( d0, VDIopcode );
    SETREG( d1, ADRParams );

    INLINE( GEMtrap );
  END  CallVDI4;

(*---------------------------------------------------------------------------*)

PROCEDURE  CallVDI5 ((* EIN/ -- *) function,
                     (* EIN/ -- *) subfunction : INTEGER;
                     (* EIN/ -- *) handle      : INTEGER;
                     (* EIN/ -- *) pts         : INTEGER;
                     (* EIN/ -- *) int         : INTEGER );

  BEGIN
    contrl[ 0 ] := function;
    contrl[ 1 ] := pts;
    contrl[ 2 ] := 0;
    contrl[ 3 ] := int;
    contrl[ 4 ] := 0;
    contrl[ 5 ] := subfunction;
    contrl[ 6 ] := handle;

    SETREG( d0, VDIopcode );
    SETREG( d1, ADRParams );

    INLINE( GEMtrap );
  END  CallVDI5;

(*---------------------------------------------------------------------------*)

PROCEDURE  CopyInt ((* EIN/ -- *) VAR IntArray : ARRAY OF INTEGER;
                    (* EIN/ -- *)     length   : INTEGER          );

  VAR  idx : INTEGER;

  BEGIN
    FOR  idx := 0  TO  length - 1  DO
      intin[ idx ] := IntArray[ idx ];
    END;
  END  CopyInt;

(*---------------------------------------------------------------------------*)

PROCEDURE  CopyPxy ((* EIN/ -- *) VAR PxyArray : ARRAY OF INTEGER;
                    (* EIN/ -- *)     pts      : INTEGER          );

  VAR  idx : INTEGER;

  BEGIN
    FOR  idx := 0  TO  pts * 2 - 1  DO
      ptsin[ idx ] := PxyArray[ idx ];
    END;
  END  CopyPxy;

(*---------------------------------------------------------------------------*)


BEGIN (* GEMVDIbase *)

  ADRintin  := ADR( intin );
  ADRptsin  := ADR( ptsin );
  ADRintout := ADR( intout );
  ADRptsout := ADR( ptsout );

  parameterBlock[ 0 ] := ADR( contrl );
  parameterBlock[ 1 ] := ADRintin;
  parameterBlock[ 2 ] := ADRptsin;
  parameterBlock[ 3 ] := ADRintout;
  parameterBlock[ 4 ] := ADRptsout;

  ADRParams := ADR( parameterBlock );

END  GEMVDIbase.
