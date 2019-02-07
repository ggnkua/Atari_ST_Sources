IMPLEMENTATION MODULE  VDIControls;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul    hk, Feb-90                     *)
(*                                                                           *)
(*****************************************************************************)

FROM  GEMVDIbase  IMPORT  (* TYPE *)  VDIWorkInType, VDIWorkOutType,
                                      PxyArrayType,
                          (* VAR  *)  intin, ptsin, intout, ptsout, contrl,
                          (* PROC *)  CallVDI2, CallVDI4;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE  OpenWorkstation ((* EIN/ -- *) VAR WorkIn  : VDIWorkInType;
                            (* -- /AUS *) VAR Handle  : INTEGER;
                            (* -- /AUS *) VAR WorkOut : VDIWorkOutType );

  CONST  OpenWorkSt = 1;

  VAR  idx : INTEGER;

  BEGIN
    idx := 0;
    WHILE  idx <= 10  DO
      intin[ idx ] := WorkIn[ idx ];
      INC( idx );
    END;

    CallVDI4( OpenWorkSt, Handle, 0, 11 );

    Handle := contrl[ 6 ];

    idx := 0;
    WHILE  idx <= 44  DO
      WorkOut[ idx ] := intout[ idx ];
      INC( idx );
    END;

    WHILE  idx <= 56  DO
      WorkOut[ idx ] := ptsout[ idx - 44 ];
      INC( idx );
    END;

  END  OpenWorkstation;

(*---------------------------------------------------------------------------*)

PROCEDURE  CloseWorkstation ((* EIN/ -- *) Handle : INTEGER );

  CONST  CloseWorkSt = 2;

  BEGIN
    CallVDI2( CloseWorkSt, Handle );
  END  CloseWorkstation;

(*---------------------------------------------------------------------------*)

PROCEDURE OpenVirtualWorkstation ((* EIN/ -- *) VAR WorkIn  : VDIWorkInType;
                                  (* EIN/AUS *) VAR Handle  : INTEGER;
                                  (* -- /AUS *) VAR WorkOut : VDIWorkOutType );

  CONST  OpenVirtWorkSt = 100;

  VAR  idx : INTEGER;

  BEGIN
    idx := 0;
    WHILE  idx <= 10  DO
      intin[ idx ] := WorkIn[ idx ];
      INC( idx );
    END;

    CallVDI4( OpenVirtWorkSt, Handle, 0, 11 );

    Handle := contrl[ 6 ];

    idx := 0;
    WHILE  idx <= 44  DO
      WorkOut[ idx ] := intout[ idx ];
      INC( idx );
    END;

    WHILE  idx <= 56  DO
      WorkOut[ idx ] := ptsout[ idx - 44 ];
      INC( idx );
    END;

  END  OpenVirtualWorkstation;

(*---------------------------------------------------------------------------*)

PROCEDURE  CloseVirtualWorkstation ((* EIN/ -- *) Handle : INTEGER );

  CONST  CloseVirtWorkSt = 101;

  BEGIN
    CallVDI2( CloseVirtWorkSt, Handle );
  END  CloseVirtualWorkstation;

(*---------------------------------------------------------------------------*)

PROCEDURE  ClearWorkstation ((* EIN/ -- *) Handle : INTEGER );

  CONST  ClearWorkSt = 3;

  BEGIN
    CallVDI2( ClearWorkSt, Handle );
  END  ClearWorkstation;

(*---------------------------------------------------------------------------*)

PROCEDURE  UpdateWorkstation ((* EIN/ -- *) Handle : INTEGER );

  CONST  UpdateWorkSt = 101;

  BEGIN
    CallVDI2( UpdateWorkSt, Handle );
  END  UpdateWorkstation;

(*---------------------------------------------------------------------------*)

PROCEDURE  LoadFonts ((* EIN/ -- *) Handle : INTEGER;
                      (* EIN/ -- *) Select : INTEGER ): INTEGER;

  CONST  LoadFont = 119;

  BEGIN
    CallVDI4( LoadFont, Handle, 0, 1 );

    RETURN( intout[ 0 ] );
  END  LoadFonts;

(*---------------------------------------------------------------------------*)

PROCEDURE  UnloadFonts ((* EIN/ -- *) Handle : INTEGER;
                           (* EIN/ -- *) Select : INTEGER );

  CONST  UnloadFont = 120;

  BEGIN
    intin[ 0 ] := Select;

    CallVDI4( UnloadFont, Handle, 0, 1 );
  END  UnloadFonts;

(*---------------------------------------------------------------------------*)

PROCEDURE  SetClipping ((* EIN/ -- *)     Handle   : INTEGER;
                        (* EIN/ -- *)     ClipFlag : INTEGER;
                        (* EIN/ -- *) VAR PxyArray : PxyArrayType );

  CONST  SetClip = 129;

  VAR  idx : INTEGER;

  BEGIN
    intin[ 0 ] := ClipFlag;

    idx := 0;
    WHILE  idx <= 3  DO
      ptsin[ idx ] := PxyArray[ idx ];
      INC( idx );
    END;

    CallVDI4( SetClip, Handle, 2, 1 );
  END  SetClipping;


END  VDIControls.
