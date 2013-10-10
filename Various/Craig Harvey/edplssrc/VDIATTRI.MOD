IMPLEMENTATION MODULE VDIAttribs;

(* ----------------------------------------------------------------------------

             Modula-2 interface to GEM Virtual Device Interface


  Full documentation on the VDI is contained in the GEM VDI programmers manual

-----------------------------------------------------------------------------*)


(* ---------------------------------------------------------------------- *)
(* (c) Copyright 1986, 1987  Modula-2 Software Ltd.  All Rights Reserved. *)
(* ---------------------------------------------------------------------- *)
(* (c) Copyright 1986, 1987  TDI Software, Inc.      All Rights Reserved. *)
(* ---------------------------------------------------------------------- *)

(*$T-*)(*$S-*)

FROM GEMVDIbase IMPORT
     (* types *) VDIWorkInType,
                 VDIWorkOutType,
                 PxyArrayType,
                 BigPxyArrayType,
                 MouseArrayType,
                 SmallArrayType,
                 RGBArrayType,
                 TextAttrArrayType,
                 FontNameType,
                 DistanceArrayType,
                 FilmNameType,
                 FilmIndexType,

     (* procs *) CallVDI,
                 SetContrl,

     (* vars  *) contrl,
                 intin,
                 ptsin,
                 intout,
                 ptsout,
                 ADRintin,
                 ADRptsin,
                 ADRintout,
                 ADRptsout,
                 parameterBlock;

FROM SYSTEM IMPORT ADR, ADDRESS;

VAR i, h : INTEGER;

(* attribute functions *)

PROCEDURE SetWritingMode ( Handle, mode : INTEGER ) : INTEGER;

(* set mode used for subsequent drawing operations *)

BEGIN
intin [0] := mode;
SetContrl (32, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetWritingMode;


PROCEDURE SetColour ( Handle, Index : INTEGER; RGBIn : PxyArrayType );

(* set colour representation *)

BEGIN
intin [0] := Index;
intin [1] := RGBIn [0]; intin [2] := RGBIn [1]; intin [3] := RGBIn [2];
SetContrl (14, 0, 4, 0, Handle);
CallVDI;
END SetColour;


PROCEDURE SetLineType ( Handle, style : INTEGER ) : INTEGER;

(* set polyline line type *)

BEGIN
intin [0] := style;
SetContrl (15, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetLineType;


PROCEDURE DefineLineStyle ( Handle, pattern : INTEGER );

(* Set user-defined line style pattern *)

BEGIN
intin [0] := pattern;
SetContrl (113, 0, 1, 0, Handle);
CallVDI;
END DefineLineStyle;


PROCEDURE SetLineWidth ( Handle, width : INTEGER ) : INTEGER;

(* Set polyline line width *)

BEGIN
ptsin [0] := width; ptsin [1] := 0;
SetContrl (16, 1, 0, 0, Handle);
CallVDI;
RETURN ptsout [0];
END SetLineWidth;


PROCEDURE SetLineColour ( Handle, ColourIndex : INTEGER ) : INTEGER;

(* sets colour index for subsequent polyline operations *)

BEGIN
intin [0] := ColourIndex;
SetContrl (17, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetLineColour;


PROCEDURE SetEndLineStyle ( Handle, BegStyle, EndStyle : INTEGER );

(* set polyline end styles *)

BEGIN
intin [0] := BegStyle;
intin [1] := EndStyle;
SetContrl (108, 0, 2, 0, Handle);
CallVDI;
END SetEndLineStyle;


PROCEDURE SetMarkerType ( Handle, symbol : INTEGER ) : INTEGER;

(* set polymarker type *)

BEGIN
intin [0] := symbol;
SetContrl (18, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetMarkerType;


PROCEDURE SetMarkerHeight ( Handle, height : INTEGER ) : INTEGER;

(* Set polymarker height *)

BEGIN
ptsin [0] := 0;
ptsin [1] := height;
SetContrl (19, 1, 0, 0, Handle);
CallVDI;
RETURN ptsout [1];
END SetMarkerHeight;


PROCEDURE SetMarkerColour ( Handle, ColourIndex : INTEGER ) : INTEGER;

(* set polymarker colour index *)

BEGIN
intin [0] := ColourIndex;
SetContrl (20, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetMarkerColour;


PROCEDURE SetAbsCharHeight (    Handle, height : INTEGER;
                                 VAR CharWidth, CharHeight,
                                     CellWidth, CellHeight : INTEGER );

(* Set character height, absolute mode *)

BEGIN
ptsin [0] := 0;
ptsin [1] := height;
SetContrl (12, 1, 0, 0, Handle);
CallVDI;
CharWidth  := ptsout [0];
CharHeight := ptsout [1];
CellWidth  := ptsout [2];
CellHeight := ptsout [3];
END SetAbsCharHeight;


PROCEDURE SetPointCharHeight (    Handle, point : INTEGER;
                              VAR CharWidth, CharHeight,
                                  CellWidth, CellHeight : INTEGER ) : INTEGER;

(* set character cell height, points mode *)

BEGIN
intin [0] := point;
SetContrl (107, 0, 1, 0, Handle);
CallVDI;
CharWidth  := ptsout [0];
CharHeight := ptsout [1];
CellWidth  := ptsout [2];
CellHeight := ptsout [3];
RETURN intout [0]; (* TDI had this as intout [1] !! *)
END SetPointCharHeight;


PROCEDURE SetRotation ( Handle, angle : INTEGER ) : INTEGER;

(* set character baseline vector *)

BEGIN
intin [0] := angle;
SetContrl (13, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetRotation;


PROCEDURE SetFont ( Handle, font : INTEGER ) : INTEGER;

(* Set text face *)

BEGIN
intin [0] := font;
SetContrl (21, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetFont;


PROCEDURE SetGraphicTextColour ( Handle, ColourIndex : INTEGER ) : INTEGER;

(* set graphic text colour index *)

BEGIN
intin [0] := ColourIndex;
SetContrl (22, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetGraphicTextColour;


PROCEDURE SetGraphicTextEffects ( Handle, Effect : INTEGER ) : INTEGER;

(* set graphic text special effects *)

BEGIN
intin [0] := Effect;
SetContrl (106, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetGraphicTextEffects;


PROCEDURE SetGraphicTextAlignment (    Handle, HorIn, VertIn : INTEGER;
                                   VAR HorOut, VertOut : INTEGER );

(* Set graphic text alignment *)

BEGIN
intin [0] := HorIn;
intin [1] := VertIn;
SetContrl (39, 0, 2, 0, Handle);
CallVDI;
HorOut := intout [0];
VertOut := intout [1];
END SetGraphicTextAlignment;


PROCEDURE SetFillInteriorStyle ( Handle, style : INTEGER ) : INTEGER;

(* set fill interior style *)

BEGIN
intin [0] := style;
SetContrl (23, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetFillInteriorStyle;


PROCEDURE SetFillStyle ( Handle, styleIndex : INTEGER ) : INTEGER;

(* Set fill style index *)

BEGIN
intin [0] := styleIndex;
SetContrl (24, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetFillStyle;


PROCEDURE SetFillColour ( Handle, colourIndex : INTEGER ) : INTEGER;

(* set fill colour index *)

BEGIN
intin [0] := colourIndex;
SetContrl (25, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetFillColour;


PROCEDURE SetFillPerimeterVisibility ( Handle, perVis : INTEGER ) : INTEGER;

(* set fill perimeter visibility *)

BEGIN
intin [0] := perVis;
SetContrl (104, 0, 1, 0, Handle);
CallVDI;
RETURN intout [0];
END SetFillPerimeterVisibility;


PROCEDURE DefineFillPattern (    Handle : INTEGER;
                             VAR pFillPatt : ARRAY OF INTEGER;
                                 planes : INTEGER );

(* Set user-defined fill pattern *)

BEGIN
SetContrl (112, 0, planes*16, 0, Handle);
parameterBlock [1] := ADR (pFillPatt);
CallVDI;
parameterBlock [1] := ADRintin;
END DefineFillPattern;

END VDIAttribs.
