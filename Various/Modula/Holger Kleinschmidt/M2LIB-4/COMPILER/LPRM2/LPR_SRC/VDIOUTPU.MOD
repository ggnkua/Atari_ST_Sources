IMPLEMENTATION MODULE  VDIOutputs;

(*****************************************************************************)
(*                                                                           *)
(* Rekompiliertes LPR-MODULA-Originalmodul   , hk 3'90                       *)
(*                                                                           *)
(*****************************************************************************)

FROM  GEMVDIbase  IMPORT  (* TYPE *) PxyArrayType,
                          (* VAR  *) intin, ptsin, contrl,
                          (* PROC *) CallVDI4, CallVDI5, CopyPxy, CopyInt;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE  PolyLine ((* EIN/ -- *)     Handle,
                     (* EIN/ -- *)     Count    : INTEGER;
                     (* EIN/ -- *) VAR PxyArray : ARRAY OF INTEGER );

  CONST polyline = 6;

  BEGIN
    CopyPxy( PxyArray, Count );
    CallVDI4( polyline, Handle, Count, 0 );
  END  PolyLine;

(*---------------------------------------------------------------------------*)

PROCEDURE  PolyMarker ((* EIN/ -- *)     Handle,
                       (* EIN/ -- *)     Count    : INTEGER;
                       (* EIN/ -- *) VAR PxyArray : ARRAY OF INTEGER );

  CONST polymarker = 7;

  BEGIN
    CopyPxy( PxyArray, Count );
    CallVDI4( polymarker, Handle, Count, 0 );
  END  PolyMarker;

(*---------------------------------------------------------------------------*)

PROCEDURE  GraphicText ((* EIN/ -- *)     Handle,
                        (* EIN/ -- *)     x, y   : INTEGER;
                        (* EIN/ -- *) VAR string : ARRAY OF CHAR );

  CONST text = 8;

  VAR maxIdx,
      idx    : INTEGER;

  BEGIN
    maxIdx := HIGH( string );
    IF  maxIdx > 126  THEN  maxIdx := 126  END;

    FOR  idx := 0  TO  maxIdx  DO
      intin[ idx ] := ORD( string[ idx ]);
    END;

    intin[ maxIdx + 1 ] := 0;

    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;

    CallVDI4( text, Handle, 1, maxIdx + 1 );
  END  GraphicText;

(*---------------------------------------------------------------------------*)

PROCEDURE  FillArea ((* EIN/ -- *)     Handle,
                     (* EIN/ -- *)     Count    : INTEGER;
                     (* EIN/ -- *) VAR PxyArray : ARRAY OF INTEGER );

  CONST filledarea = 9;

  BEGIN
    CopyPxy( PxyArray, Count );
    CallVDI4( filledarea, Handle, Count, 0 );
  END  FillArea;

(*---------------------------------------------------------------------------*)

PROCEDURE  CellArray ((* EIN/ -- *)     Handle   : INTEGER;
                      (* EIN/ -- *) VAR PxyArray : PxyArrayType;
                      (* EIN/ -- *)     RowLength,
                      (* EIN/ -- *)     ElUsed,
                      (* EIN/ -- *)     NumRows,
                      (* EIN/ -- *)     WrtMode  : INTEGER;
                      (* EIN/ -- *) VAR ColArray : ARRAY OF INTEGER );

  CONST cellarray = 10;

  BEGIN
    CopyPxy( PxyArray, 2 );
    CopyInt( ColArray, ElUsed * NumRows );

    contrl[  7 ] := RowLength;
    contrl[  8 ] := ElUsed;
    contrl[  9 ] := NumRows;
    contrl[ 10 ] := WrtMode;

    CallVDI4( cellarray, Handle, 2, ElUsed * NumRows );
  END  CellArray;

(*---------------------------------------------------------------------------*)

PROCEDURE  ContourFill ((* EIN/ -- *) Handle,
                        (* EIN/ -- *) x, y,
                        (* EIN/ -- *) index  : INTEGER );

  CONST contourfill = 103;

  BEGIN
    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;

    intin[ 0 ] := index;

    CallVDI4( contourfill, Handle, 1, 1 );
  END  ContourFill;

(*---------------------------------------------------------------------------*)

PROCEDURE  FillRectangle ((* EIN/ -- *)     Handle   : INTEGER;
                          (* EIN/ -- *) VAR PxyArray : PxyArrayType );

  CONST fillrectangle = 114;

  BEGIN
    CopyPxy( PxyArray, 2 );
    CallVDI4( fillrectangle, Handle, 2, 0 );
  END  FillRectangle;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawBar ((* EIN/ -- *)     Handle   : INTEGER;
                    (* EIN/ -- *) VAR PxyArray : PxyArrayType );

  CONST gdp = 11;
        bar =  1;

  BEGIN
    CopyPxy( PxyArray, 2 );
    CallVDI5( gdp, bar, Handle, 2, 0 );
  END  DrawBar;

(*---------------------------------------------------------------------------*)

PROCEDURE  InitPtsin7;

  VAR  idx : INTEGER;

  BEGIN
    idx := 0;
    WHILE  idx <= 7  DO
      ptsin[ idx ] := 0;
      INC( idx );
    END;
  END  InitPtsin7;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawArc ((* EIN/ -- *) Handle,
                    (* EIN/ -- *) x, y,
                    (* EIN/ -- *) Radius,
                    (* EIN/ -- *) BegAng,
                    (* EIN/ -- *) EndAng : INTEGER );

  CONST gdp = 11;
        arc =  2;

  BEGIN
    InitPtsin7;

    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 6 ] := Radius;

    intin[ 0 ] := BegAng;
    intin[ 1 ] := EndAng;

    CallVDI5( gdp, arc, Handle, 4, 2 );
  END  DrawArc;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawPieSlice ((* EIN/ -- *) Handle,
                         (* EIN/ -- *) x, y,
                         (* EIN/ -- *) Radius,
                         (* EIN/ -- *) BegAng,
                         (* EIN/ -- *) EndAng : INTEGER );

  CONST gdp = 11;
        pie =  3;

  BEGIN
    InitPtsin7;

    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 6 ] := Radius;

    intin[ 0 ] := BegAng;
    intin[ 1 ] := EndAng;

    CallVDI5( gdp, pie, Handle, 4, 2 );
  END  DrawPieSlice;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawCircle ((* EIN/ -- *) Handle,
                       (* EIN/ -- *) x, y,
                       (* EIN/ -- *) Radius : INTEGER );

  CONST gdp    = 11;
        circle =  4;

  BEGIN
    InitPtsin7;

    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 4 ] := Radius;

    CallVDI5( gdp, circle, Handle, 3, 0 );
  END  DrawCircle;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawEllipticalArc ((* EIN/ -- *) Handle,
                              (* EIN/ -- *) x, y,
                              (* EIN/ -- *) xRadius,
                              (* EIN/ -- *) yRadius,
                              (* EIN/ -- *) BegAng,
                              (* EIN/ -- *) EndAng : INTEGER );

  CONST gdp         = 11;
        ellipticarc =  6;

  BEGIN
    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 2 ] := xRadius;
    ptsin[ 3 ] := yRadius;

    intin[ 0 ] := BegAng;
    intin[ 1 ] := EndAng;

    CallVDI5( gdp, ellipticarc, Handle, 2, 2 );
  END  DrawEllipticalArc;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawEllipticalPie ((* EIN/ -- *) Handle,
                              (* EIN/ -- *) x, y,
                              (* EIN/ -- *) xRadius,
                              (* EIN/ -- *) yRadius,
                              (* EIN/ -- *) BegAng,
                              (* EIN/ -- *) EndAng : INTEGER );

  CONST gdp         = 11;
        ellipticpie =  6;

  BEGIN
    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 2 ] := xRadius;
    ptsin[ 3 ] := yRadius;

    intin[ 0 ] := BegAng;
    intin[ 1 ] := EndAng;

    CallVDI5( gdp, ellipticpie, Handle, 2, 2 );
  END  DrawEllipticalPie;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawEllipse ((* EIN/ -- *) Handle,
                        (* EIN/ -- *) x, y,
                        (* EIN/ -- *) xRadius,
                        (* EIN/ -- *) yRadius : INTEGER );

  CONST gdp     = 11;
        ellipse =  6;

  BEGIN
    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 2 ] := xRadius;
    ptsin[ 3 ] := yRadius;

    CallVDI5( gdp, ellipse, Handle, 2, 0 );
  END  DrawEllipse;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawRoundedBox ((* EIN/ -- *)     Handle   : INTEGER;
                           (* EIN/ -- *) VAR PxyArray : PxyArrayType );

  CONST gdp         = 11;
        roundedrect =  8;

  BEGIN
    CopyPxy( PxyArray, 2 );
    CallVDI5( gdp, roundedrect, Handle, 2, 0 );
  END  DrawRoundedBox;

(*---------------------------------------------------------------------------*)

PROCEDURE  DrawRoundedFilledBox ((* EIN/ -- *)     Handle   : INTEGER;
                                 (* EIN/ -- *) VAR PxyArray : PxyArrayType );

  CONST gdp               = 11;
        filledroundedrect =  8;

  BEGIN
    CopyPxy( PxyArray, 2 );
    CallVDI5( gdp, filledroundedrect, Handle, 2, 0 );
  END  DrawRoundedFilledBox;

(*---------------------------------------------------------------------------*)

PROCEDURE  JustifiedText ((* EIN/ -- *)     Handle,
                          (* EIN/ -- *)     x, y      : INTEGER;
                          (* EIN/ -- *) VAR string    : ARRAY OF CHAR;
                          (* EIN/ -- *)     Length,
                          (* EIN/ -- *)     WordSpace,
                          (* EIN/ -- *)     CharSpace : INTEGER       );

  CONST gdp  = 11;
        text = 10;

  VAR maxIdx,
      idx    : INTEGER;

  BEGIN
    ptsin[ 0 ] := x;
    ptsin[ 1 ] := y;
    ptsin[ 2 ] := Length;

    intin[ 0 ] := WordSpace;
    intin[ 1 ] := CharSpace;

    maxIdx := HIGH( string );
    IF  maxIdx > 125  THEN  maxIdx := 125  END;

    FOR  idx := 2  TO  maxIdx + 2  DO
      intin[ idx ] := ORD( string[ idx ]);
    END;

    intin[ maxIdx + 3 ] := 0;

    CallVDI5( gdp, text, Handle, 2, 1 );
  END  JustifiedText;


END  VDIOutputs.
