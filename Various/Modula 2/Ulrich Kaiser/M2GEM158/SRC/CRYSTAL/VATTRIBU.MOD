IMPLEMENTATION MODULE VAttribute;

(*
VDI Attribute Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI      IMPORT intin,ptsin,intout,ptsout,v,CallVDI,vdi,Integer,Point;
#if ST
FROM VControl IMPORT VQFSMGDOS;
#endif
FROM PORTAB   IMPORT ANYWORD,UNSIGNEDWORD,SIGNEDWORD,ANYTYPE,UNSIGNEDLONG;
FROM SYSTEM   IMPORT ADR;
CAST_IMPORT

PROCEDURE VSWrMode(Handle: UNSIGNEDWORD;
                   Mode  : WritingModes);
BEGIN
  intin[0]:= ORD(Mode);
  CallVDI(32,0,1,Handle);
END VSWrMode;

PROCEDURE VSColor(Handle: UNSIGNEDWORD;
                  Index : UNSIGNEDWORD;
                  RGB   : RGBList);
BEGIN
  intin[0]:= Index;
  intin[1]:= RGB.Red;
  intin[2]:= RGB.Green;
  intin[3]:= RGB.Blue;
  CallVDI(14,0,4,Handle);
END VSColor;

PROCEDURE VSLType(Handle: UNSIGNEDWORD;
                  Style : LineTypes);
BEGIN
  intin[0]:= ORD(Style);
  CallVDI(15,0,1,Handle);
END VSLType;

PROCEDURE VSLUDSty(Handle : UNSIGNEDWORD;
                   Pattern: ANYWORD);
BEGIN
  intin[0]:= CAST(Integer,Pattern);
  CallVDI(113,0,1,Handle);
END VSLUDSty;

PROCEDURE VSLWidth(Handle: UNSIGNEDWORD;
                   Width : UNSIGNEDWORD);
BEGIN
  ptsin[0]:= Width;
  ptsin[1]:= 0;
  CallVDI(16,1,0,Handle);
END VSLWidth;

PROCEDURE VSLColor(Handle: UNSIGNEDWORD;
                   Index : UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  CallVDI(17,0,1,Handle);
END VSLColor;

PROCEDURE VSLEnds(Handle    : UNSIGNEDWORD;
                  BeginStyle: LineEnds;
                  EndStyle  : LineEnds);
BEGIN
  intin[0]:= ORD(BeginStyle);
  intin[1]:= ORD(EndStyle);
  CallVDI(108,0,2,Handle);
END VSLEnds;

PROCEDURE VSMType(Handle: UNSIGNEDWORD;
                  Symbol: MarkerTypes);
BEGIN
  intin[0]:= ORD(Symbol);
  CallVDI(18,0,1,Handle);
END VSMType;

PROCEDURE VSMHeight(Handle: UNSIGNEDWORD;
                    Height: UNSIGNEDWORD);
BEGIN
  ptsin[0]:= 0;
  ptsin[1]:= Height;
  CallVDI(19,1,0,Handle);
END VSMHeight;

PROCEDURE VSMColor(Handle: UNSIGNEDWORD;
                   Index : UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  CallVDI(20,0,1,Handle);
END VSMColor;

PROCEDURE VSTHeight(    Handle    : UNSIGNEDWORD;
                        Height    : UNSIGNEDWORD;
                    VAR CharWidth : UNSIGNEDWORD;
                    VAR CharHeight: UNSIGNEDWORD;
                    VAR CellWidth : UNSIGNEDWORD;
                    VAR CellHeight: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
  ptsin[0]:= 0;
  ptsin[1]:= Height;
  CallVDI(12,1,0,Handle);
  CharWidth := ptsout[0];
  CharHeight:= ptsout[1];
  CellWidth := ptsout[2];
  CellHeight:= ptsout[3];
  RETURN intout[0];
END VSTHeight;

PROCEDURE VSTPoint(    Handle    : UNSIGNEDWORD;
                       Points    : UNSIGNEDWORD;
                   VAR CharWidth : UNSIGNEDWORD;
                   VAR CharHeight: UNSIGNEDWORD;
                   VAR CellWidth : UNSIGNEDWORD;
                   VAR CellHeight: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
  intin[0]:= Points;
  CallVDI(107,0,1,Handle);
  CharWidth := ptsout[0];
  CharHeight:= ptsout[1];
  CellWidth := ptsout[2];
  CellHeight:= ptsout[3];
  RETURN intout[0];
END VSTPoint;

PROCEDURE VSTRotation(Handle: UNSIGNEDWORD;
                      Angle : UNSIGNEDWORD);
BEGIN
  intin[0]:= Angle;
  CallVDI(13,0,1,Handle);
END VSTRotation;

PROCEDURE VSTFont(Handle: UNSIGNEDWORD;
                  Font  : UNSIGNEDWORD);
BEGIN
  intin[0]:= Font;
  CallVDI(21,0,1,Handle);
END VSTFont;

PROCEDURE VSTColor(Handle: UNSIGNEDWORD;
                   Index : UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  CallVDI(22,0,1,Handle);
END VSTColor;

PROCEDURE VSTEffects(Handle: UNSIGNEDWORD;
                     Effect: TextEffect);
BEGIN
  intin[0]:= CAST(Integer,Effect);
  CallVDI(106,0,1,Handle);
END VSTEffects;

PROCEDURE VSTAlignment(    Handle : UNSIGNEDWORD;
                           HorIn  : HorizontalAlignments;
                           VertIn : VerticalAlignments;
                       VAR HorOut : HorizontalAlignments;
                       VAR VertOut: VerticalAlignments);
BEGIN
  intin[0]:= ORD(HorIn);
  intin[1]:= ORD(VertIn);
  CallVDI(39,0,2,Handle);
  HorOut:= VAL(HorizontalAlignments,intout[0]);
  VertOut:= VAL(VerticalAlignments,intout[1]);
END VSTAlignment;

PROCEDURE VSFInterior(Handle: UNSIGNEDWORD;
                      Style : Interiors);
BEGIN
  intin[0]:= ORD(Style);
  CallVDI(23,0,1,Handle);
END VSFInterior;

PROCEDURE VSFStyle(Handle: UNSIGNEDWORD;
                   Index : UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  CallVDI(24,0,1,Handle);
END VSFStyle;

PROCEDURE VSFColor(Handle: UNSIGNEDWORD;
                   Index : UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  CallVDI(25,0,1,Handle);
END VSFColor;

PROCEDURE VSFPerimeter(Handle: UNSIGNEDWORD;
                       Vis   : BOOLEAN);
BEGIN
  intin[0]:= ORD(Vis);
  CallVDI(104,0,1,Handle);
END VSFPerimeter;

PROCEDURE VSFUDPat(    Handle : UNSIGNEDWORD;
                   VAR FillPat: ARRAY OF ANYTYPE;
                       Planes : UNSIGNEDWORD);
BEGIN
  v.iioff:= ADR(FillPat);
  CallVDI(112,0,16 * Planes,Handle);
  v.iioff:= ADR(intin);
END VSFUDPat;

PROCEDURE VSGrayOverride(Handle : UNSIGNEDWORD;
                         GrayVal: UNSIGNEDWORD);
BEGIN
  intin[0]:= GrayVal;
  CallVDI(133,0,1,Handle);
END VSGrayOverride;

PROCEDURE VSTArbPt(    Handle    : UNSIGNEDWORD;
                       Point     : UNSIGNEDWORD;
                   VAR CharWidth : UNSIGNEDWORD;
                   VAR CharHeight: UNSIGNEDWORD;
                   VAR CellWidth : UNSIGNEDWORD;
                   VAR CellHeight: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
#if ST
  IF VQFSMGDOS() THEN
    intin[0]:= Point;
    CallVDI(246,0,1,Handle);
    CharWidth:= ptsout[0];
    CharHeight:= ptsout[1];
    CellWidth:= ptsout[2];
    CellHeight:= ptsout[3];
    RETURN intout[0];
  END;
#endif
  RETURN 0;
END VSTArbPt;

PROCEDURE VSTArbPt32(    Handle    : UNSIGNEDWORD;
                         Point     : UNSIGNEDLONG;
                     VAR CharWidth : UNSIGNEDWORD;
                     VAR CharHeight: UNSIGNEDWORD;
                     VAR CellWidth : UNSIGNEDWORD;
                     VAR CellHeight: UNSIGNEDWORD): UNSIGNEDLONG;

#if ST
VAR P: POINTER TO UNSIGNEDLONG;
#endif

BEGIN
#if ST
  IF VQFSMGDOS() THEN
    P:= ADR(intin);
    P^:= Point;
    CallVDI(246,0,2,Handle);
    CharWidth:= ptsout[0];
    CharHeight:= ptsout[1];
    CellWidth:= ptsout[2];
    CellHeight:= ptsout[3];
    P:= ADR(intout);
    RETURN P^;
  END;
#endif
  RETURN 0;
END VSTArbPt32;

PROCEDURE VSTSetSize(    Handle    : UNSIGNEDWORD;
                         Point     : UNSIGNEDWORD;
                     VAR CharWidth : UNSIGNEDWORD;
                     VAR CharHeight: UNSIGNEDWORD;
                     VAR CellWidth : UNSIGNEDWORD;
                     VAR CellHeight: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
#if ST
  IF VQFSMGDOS() THEN
    intin[0]:= Point;
    CallVDI(252,0,1,Handle);
    CharWidth:= ptsout[0];
    CharHeight:= ptsout[1];
    CellWidth:= ptsout[2];
    CellHeight:= ptsout[3];
    RETURN intout[0];
  END;
#endif
  RETURN 0;
END VSTSetSize;

PROCEDURE VSTSetSize32(    Handle    : UNSIGNEDWORD;
                           Point     : UNSIGNEDLONG;
                       VAR CharWidth : UNSIGNEDWORD;
                       VAR CharHeight: UNSIGNEDWORD;
                       VAR CellWidth : UNSIGNEDWORD;
                       VAR CellHeight: UNSIGNEDWORD): UNSIGNEDLONG;

#if ST
VAR P: POINTER TO UNSIGNEDLONG;
#endif

BEGIN
#if ST
  IF VQFSMGDOS() THEN
    P:= ADR(intin);
    P^:= Point;
    CallVDI(252,0,2,Handle);
    CharWidth:= ptsout[0];
    CharHeight:= ptsout[1];
    CellWidth:= ptsout[2];
    CellHeight:= ptsout[3];
    P:= ADR(intout);
    RETURN P^;
  END;
#endif
  RETURN 0;
END VSTSetSize32;

PROCEDURE VSTSkew(Handle: UNSIGNEDWORD;
                  Skew  : SIGNEDWORD): SIGNEDWORD;
BEGIN
#if ST
  IF VQFSMGDOS() THEN
    intin[0]:= Skew;
    CallVDI(253,0,1,Handle);
    RETURN intout[0];
  END;
#endif
  RETURN 0;
END VSTSkew;

PROCEDURE VSTKern(    Handle: UNSIGNEDWORD;
                      TMode : UNSIGNEDWORD;
                      PMode : BOOLEAN;
                  VAR Tracks: UNSIGNEDWORD;
                  VAR Pairs : UNSIGNEDWORD);
BEGIN
  intin[0]:= TMode;
  intin[1]:= ORD(PMode);
  CallVDI(237,0,2,Handle);
  Tracks:= intout[0];
  Pairs:= intout[1];
END VSTKern;

PROCEDURE VSTWidth(    Handle    : UNSIGNEDWORD;
                       Width     : UNSIGNEDWORD;
                   VAR CharWidth : UNSIGNEDWORD;
                   VAR CharHeight: UNSIGNEDWORD;
                   VAR CellWidth : UNSIGNEDWORD;
                   VAR CellHeight: UNSIGNEDWORD);
BEGIN
  ptsin[0]:= 0;
  ptsin[1]:= Width;
  CallVDI(231,1,2,Handle);
  CharWidth:= ptsout[0];
  CharHeight:= ptsout[1];
  CellWidth:= ptsout[2];
  CellHeight:= ptsout[3];
END VSTWidth;

END VAttribute.