IMPLEMENTATION MODULE  VDIRasters;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul    hk, Feb-90                     *)
(*                                                                           *)
(*****************************************************************************)

FROM  SYSTEM      IMPORT  (* TYPE *) ADDRESS;

FROM  GEMVDIbase  IMPORT  (* TYPE *) BigPxyArrayType, SmallArrayType,
                          (* VAR  *) intin, ptsin, intout, contrl,
                          (* PROC *) CopyPxy, CallVDI4;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE SetSourceAndDestination ((* EIN/ -- *) psrcMFDB,
                                   (* EIN/ -- *) pdesMFDB : ADDRESS );

  VAR  adrint : RECORD
                  CASE :BOOLEAN OF
                    FALSE: MFDBadr    : ADDRESS;
                   |TRUE : int1, int2 : INTEGER;
                  END; (* CASE *)
                END;

  BEGIN
    adrint.MFDBadr := psrcMFDB;

    contrl[ 7 ] := adrint.int1;
    contrl[ 8 ] := adrint.int2;

    adrint.MFDBadr := pdesMFDB;

    contrl[ 9 ] := adrint.int1;
    contrl[10 ] := adrint.int2;
  END  SetSourceAndDestination;

(*===========================================================================*)

PROCEDURE  CopyRasterOpaque ((* EIN/ -- *)     Handle   : INTEGER;
                             (* EIN/ -- *)     WrMode   : INTEGER;
                             (* EIN/ -- *) VAR PxyArray : BigPxyArrayType;
                             (* EIN/ -- *)     psrcMFDB,
                             (* EIN/ -- *)     pdesMFDB : ADDRESS         );

  CONST  copyopaque = 109;

  BEGIN
    intin[ 0 ] := WrMode;

    CopyPxy( PxyArray, 4 );
    SetSourceAndDestination( psrcMFDB, pdesMFDB );

    CallVDI4( copyopaque, Handle, 4, 1 );
  END  CopyRasterOpaque;

(*---------------------------------------------------------------------------*)

PROCEDURE  CopyRasterTransparent((* EIN/ -- *)     Handle  : INTEGER;
                                 (* EIN/ -- *)     WrMode  : INTEGER;
                                 (* EIN/ -- *) VAR PxyArray: BigPxyArrayType;
                                 (* EIN/ -- *) VAR psrcMFDB: ADDRESS;
                                 (* EIN/ -- *) VAR pdesMFDB: ADDRESS;
                              (* EIN/ -- *) VAR colourIndex: SmallArrayType  );

  CONST  copytrans = 121;

  BEGIN
    intin[ 0 ] := WrMode;
    intin[ 1 ] := colourIndex[ 0 ];
    intin[ 2 ] := colourIndex[ 1 ];

    CopyPxy( PxyArray, 4 );
    SetSourceAndDestination( psrcMFDB, pdesMFDB );

    CallVDI4( copytrans, Handle, 4, 3 );
  END  CopyRasterTransparent;

(*---------------------------------------------------------------------------*)

PROCEDURE  TransformForm ((* EIN/ -- *) Handle   : INTEGER;
                          (* EIN/ -- *) psrcMFDB,
                          (* EIN/ -- *) pdesMFDB : ADDRESS );

  CONST  Transform = 110;

  BEGIN
    SetSourceAndDestination( psrcMFDB, pdesMFDB );

    CallVDI4( Transform, Handle, 0, 0 );
  END  TransformForm;

(*---------------------------------------------------------------------------*)

PROCEDURE  GetPixel ((* EIN/ -- *)     Handle : INTEGER;
                     (* EIN/ -- *)     x,
                     (* EIN/ -- *)     y      : INTEGER;
                     (* -- /AUS *) VAR pel    : INTEGER;
                     (* -- /AUS *) VAR index  : INTEGER );

  CONST  getpix = 105;

  BEGIN
    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;

    CallVDI4( getpix, Handle, 1, 0 );

    pel   := intout[ 0 ];
    index := intout[ 1 ];
  END  GetPixel;


END  VDIRasters.
