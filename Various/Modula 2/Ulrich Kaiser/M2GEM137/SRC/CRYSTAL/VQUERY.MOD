IMPLEMENTATION MODULE VQuery;

(*
VDI Query Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI        IMPORT contrl,intin,ptsin,intout,ptsout,v,CallVDI,RGBList,
                       MaxInput,IntegerOutputRange,EOS,
                       XY,Integer,Point,ColorIntensity;
FROM VAttribute IMPORT WritingModes,LineTypes,LineEnds,MarkerTypes,
                       TextEffect,
                       HorizontalAlignments,VerticalAlignments,
                       Interiors;
FROM VInput     IMPORT Devices,InputModes;
#if ST
FROM VControl   IMPORT VQFSMGDOS,VQSpeedoGDOS;
#endif
FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYWORD,ANYPOINTER,
                       UNSIGNEDLONG,ANYTYPE;
FROM SYSTEM     IMPORT ADR;
CAST_IMPORT

PROCEDURE VQExtnd(    Handle : UNSIGNEDWORD;
                      Flag   : BOOLEAN;
                  VAR WorkOut: ARRAY OF UNSIGNEDWORD);
#if long
VAR i: [0..56];
#endif

BEGIN
#if long
  FOR i:= 0 TO 44 DO
    WorkOut[i]:= intout[i];
  END;
  FOR i:= 45 TO 56 DO
    WorkOut[i]:= ptsout[i - 45];
  END;
#else
  v.iooff:= ADR(WorkOut);
  v.pooff:= ADR(WorkOut[45]);
#endif
  intin[0]:= ORD(Flag);
  CallVDI(102,0,1,Handle);
#if not long
  v.iooff:= ADR(intout);
  v.pooff:= ADR(ptsout);
#endif
END VQExtnd;

PROCEDURE VQColor(    Handle: UNSIGNEDWORD;
                      Color : UNSIGNEDWORD;
                      Flag  : BOOLEAN;
                  VAR RGB   : RGBList): UNSIGNEDWORD;
BEGIN
  intin[0]:= ORD(Color);
  intin[1]:= ORD(Flag);
  CallVDI(26,0,2,Handle);
  WITH RGB DO
    Red:= intout[1];
    Green:= intout[2];
    Blue:= intout[3];
  END;
  RETURN intout[0];
END VQColor;

PROCEDURE VQLAttributes(    Handle: UNSIGNEDWORD;
                        VAR Attrib: ARRAY OF ANYTYPE);

VAR P: POINTER TO LineAttributes;

BEGIN
  CallVDI(35,0,0,Handle);
  P:= ADR(Attrib);
  WITH P^ DO
    Type:= VAL(LineTypes,intout[0]);
    Color:= intout[1];
    Mode:= VAL(WritingModes,intout[2]);
    Width:= ptsout[0];
    Begin:= LESquared;
    End:= LESquared;
    IF contrl.c[4] > 3 THEN
      Begin:= VAL(LineEnds,intout[3]);
      End:= VAL(LineEnds,intout[4]);
    END;
  END;
END VQLAttributes;

PROCEDURE VQMAttributes(    Handle: UNSIGNEDWORD;
                        VAR Attrib: ARRAY OF ANYTYPE);

VAR P: POINTER TO MarkerAttributes;

BEGIN
  CallVDI(36,0,0,Handle);
  P:= ADR(Attrib);
  WITH P^ DO
    Type:= VAL(MarkerTypes,intout[0]);
    Color:= intout[1];
    Mode:= VAL(WritingModes,intout[2]);
    Height:= ptsout[1];
    Width:= 1;
    IF contrl.c[4] > 3 THEN
      Width:= intout[3];
    END;
    IF ptsout[0] > 0 THEN
      Width:= ptsout[0];
    END;
  END;
END VQMAttributes;

PROCEDURE VQFAttributes(    Handle: UNSIGNEDWORD;
                        VAR Attrib: ARRAY OF ANYTYPE);

VAR P: POINTER TO FillAttributes;

BEGIN
  CallVDI(37,0,0,Handle);
  P:= ADR(Attrib);
  WITH P^ DO
    Interior:= VAL(Interiors,intout[0]);
    Color:= intout[1];
    Fill:= intout[2];
    Mode:= VAL(WritingModes,intout[3]);
    Perimeter:= intout[4] = 1;
  END;
END VQFAttributes;

PROCEDURE VQTAttributes(    Handle: UNSIGNEDWORD;
                        VAR Attrib: ARRAY OF ANYTYPE);

VAR P: POINTER TO TextAttributes;

BEGIN
  CallVDI(38,0,0,Handle);
  P:= ADR(Attrib);
  WITH P^ DO
    Font:= intout[0];
    Color:= intout[1];
    Rotation:= intout[2];
    Horizontal:= VAL(HorizontalAlignments,intout[3]);
    Vertical:= VAL(VerticalAlignments,intout[4]);
    Mode:= VAL(WritingModes,intout[5]);
    Width:= ptsout[0];
    Height:= ptsout[1];
    CellWidth:= ptsout[2];
    CellHeight:= ptsout[3];
  END;
END VQTAttributes;

PROCEDURE VQTExtent(    Handle: UNSIGNEDWORD;
                    VAR String: ARRAY OF CHAR;
                    VAR Extent: ARRAY OF XY);

VAR i: [0..MaxInput];
#if long
    j: [0..7];
#endif

BEGIN
  i:= 0;
  WHILE String[i] # EOS DO
    intin[i]:= ORD(String[i]);
    INC(i);
  END;
#if not long
  v.pooff:= ADR(Extent);
#endif
  CallVDI(116,0,i,Handle); (* (i - 1) + 1 = i *)
#if long
  FOR j:= 0 TO 7 DO
    Extent[j]:= ptsout[j];
  END;
#else
  v.pooff:= ADR(ptsout);
#endif
END VQTExtent;

PROCEDURE VQTWidth(    Handle     : UNSIGNEDWORD;
                       Char       : CHAR;
                   VAR CellWidth  : UNSIGNEDWORD;
                   VAR LeftOffset : UNSIGNEDWORD;
                   VAR RightOffset: UNSIGNEDWORD): SIGNEDWORD;
BEGIN
  intin[0]:= ORD(Char);
  CallVDI(117,0,1,Handle);
  CellWidth:= ptsout[0];
  LeftOffset:= ptsout[2];
  RightOffset:= ptsout[4];
  RETURN intout[0];
END VQTWidth;

PROCEDURE VQTName(   Handle: UNSIGNEDWORD;
                     FontNo: UNSIGNEDWORD;
                 VAR Name  : ARRAY OF CHAR;
                 VAR VecFnt: BOOLEAN): UNSIGNEDWORD;

VAR i: [0..31];

BEGIN
  intin[0]:= FontNo;
  CallVDI(130,0,1,Handle);

  FOR i:= 0 TO 31 DO
    Name[i]:= CHR(intout[i + 1]);
  END;
  Name[32]:= EOS;

#if ST
  VecFnt:= intout[33] = 1;
#else
  VecFnt:= FALSE;
#endif
  RETURN intout[0];
END VQTName;

PROCEDURE VQCellArray(    Handle   : UNSIGNEDWORD;
                      VAR PXY      : ARRAY OF XY;
                          RowLength: UNSIGNEDWORD;
                          NumRows  : UNSIGNEDWORD;
                      VAR ElUsed   : UNSIGNEDWORD;
                      VAR RowsUsed : UNSIGNEDWORD;
                      VAR Status   : BOOLEAN;
                      VAR ColArray : ARRAY OF ANYWORD);
#if long
VAR i: [0..3];
#endif

BEGIN
#if long
  FOR i:= 0 TO 3 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  v.iioff:= ADR(ColArray);
  contrl.c[7]:= RowLength;
  contrl.c[8]:= NumRows;
  CallVDI(27,2,0,Handle);
  ElUsed:= contrl.c[9];
  RowsUsed:= contrl.c[10];
  Status:= contrl.c[11] = 0;
#if not long
  v.pioff:= ADR(ptsin);
#endif
  v.iioff:= ADR(intout);
END VQCellArray;

PROCEDURE VQInMode(    Handle   : UNSIGNEDWORD;
                       DevType  : Devices;
                   VAR InputMode: InputModes);
BEGIN
  intin[0]:= ORD(DevType);
  CallVDI(115,0,1,Handle);
  InputMode:= VAL(InputModes,intout[0]);
END VQInMode;

PROCEDURE VQTFontInfo(    Handle   : UNSIGNEDWORD;
                      VAR LowADE   : UNSIGNEDWORD;
                      VAR HighADE  : UNSIGNEDWORD;
                      VAR Distances: ARRAY OF UNSIGNEDWORD;
                      VAR MaxWidth : UNSIGNEDWORD;
                      VAR Effects  : ARRAY OF UNSIGNEDWORD);
BEGIN
  CallVDI(131,0,0,Handle);
  LowADE:= intout[0];
  HighADE:= intout[1];
  MaxWidth:= ptsout[0];
  Distances[0]:= ptsout[1];
  Distances[1]:= ptsout[3];
  Distances[2]:= ptsout[5];
  Distances[3]:= ptsout[7];
  Distances[4]:= ptsout[9];
  Effects[0]:= ptsout[2];
  Effects[1]:= ptsout[4];
  Effects[2]:= ptsout[6];
END VQTFontInfo;

PROCEDURE VQTJustified(    Handle   : UNSIGNEDWORD;
                           X        : XY;
                           Y        : XY;
                       VAR String   : ARRAY OF CHAR;
                           Length   : UNSIGNEDWORD;
                           WordSpace: BOOLEAN;
                           CharSpace: BOOLEAN;
                       VAR Offsets  : ARRAY OF UNSIGNEDWORD);

VAR i,j: [0..(MaxInput + 1)];

BEGIN
  intin[0]:= ORD(WordSpace);
  intin[1]:= ORD(CharSpace);
  i:= 0;
  WHILE String[i] # EOS DO
    intin[i + 2]:= ORD(String[i]);
    INC(i);
  END;
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= Length;
  ptsin[3]:= 0;
#if not long
  v.pooff:= ADR(Offsets);
#endif
  CallVDI(132,2,i + 1,Handle); (* (i - 1) + 2 = i + 1 *)
#if long
  FOR j:= 0 TO (2 * i - 2) DO (* 2 * (i - 1) = 2 * i - 2 *)
    Offsets[j]:= ptsout[j];
  END;
#else
  v.pooff:= ADR(ptsout);
#endif
END VQTJustified;

PROCEDURE VQTAdvance(    Handle: UNSIGNEDWORD;
                         Ch    : CHAR;
                     VAR XAdv  : UNSIGNEDWORD;
                     VAR YAdv  : UNSIGNEDWORD;
                     VAR XRem  : UNSIGNEDWORD;
                     VAR YRem  : UNSIGNEDWORD);
BEGIN
#if ST
  IF VQFSMGDOS() THEN
    intin[0]:= ORD(Ch);
    CallVDI(247,0,1,Handle);
    XAdv:= ptsout[0];
    YAdv:= ptsout[1];
    XRem:= ptsout[2];
    YRem:= ptsout[3];
  END;
#else
  intout[0]:= 0; (* error *)
#endif
END VQTAdvance;

PROCEDURE VQTAdvance32(    Handle: UNSIGNEDWORD;
                           Ch    : CHAR;
                       VAR XAdv  : UNSIGNEDLONG;
                       VAR YAdv  : UNSIGNEDLONG);

VAR P: POINTER TO ARRAY[0..1] OF UNSIGNEDLONG;

BEGIN
#if ST
  IF VQFSMGDOS() THEN
    intin[0]:= ORD(Ch);
    CallVDI(247,0,1,Handle);
    P:= ADR(ptsout[4]);
    XAdv:= P^[0];
    YAdv:= P^[1];
  END;
#endif
END VQTAdvance32;

PROCEDURE VQTGetTable(    Handle: UNSIGNEDWORD;
                      VAR Map   : ANYPOINTER);
#if ST
VAR P: POINTER TO ANYPOINTER;
#endif

BEGIN
#if ST
  IF VQFSMGDOS() THEN
    CallVDI(254,0,0,Handle);
    P:= ADR(intout);
    Map:= P^;
  END;
#endif
END VQTGetTable;

PROCEDURE VQTCacheSize(    Handle: UNSIGNEDWORD;
                           Cache : UNSIGNEDWORD;
                       VAR Size  : UNSIGNEDLONG);
#if ST
VAR P: POINTER TO UNSIGNEDLONG;
#endif
BEGIN
#if ST
  IF VQFSMGDOS() THEN
    intin[0]:= Cache;
    CallVDI(255,0,1,Handle);
    P:= ADR(intout);
    Size:= P^;
  END;
#endif
END VQTCacheSize;

PROCEDURE VQTFExtent(    Handle: UNSIGNEDWORD;
                     VAR String: ARRAY OF CHAR;
                     VAR Extent: ARRAY OF XY);

VAR i: [0..MaxInput];
#if long
    j: [0..7];
#endif

BEGIN
  i:= 0;
  WHILE String[i] # EOS DO
    intin[i]:= ORD(String[i]);
    INC(i);
  END;
#if not long
  v.pooff:= ADR(Extent);
#endif
  CallVDI(240,0,i,Handle); (* (i - 1) + 1 = i *)
#if long
  FOR j:= 0 TO 7 DO
    Extent[j]:= ptsout[j];
  END;
#else
  v.pooff:= ADR(ptsout);
#endif
END VQTFExtent;

PROCEDURE VQTFontHeader(    Handle: UNSIGNEDWORD;
                        VAR Buffer: ARRAY OF ANYTYPE;
                        VAR Path  : ARRAY OF CHAR);

VAR P: POINTER TO ANYPOINTER;
    i: [0..128]; (* should be enough *)

BEGIN
#if ST
  IF VQSpeedoGDOS() THEN
    P:= ADR(intin);
    P^:= ADR(Buffer);
    CallVDI(232,0,2,Handle);
    FOR i:= 0 TO (contrl.c[4] - 1) DO
      Path[i]:= CHR(intout[i]);
    END;
    Path[contrl.c[4]]:= EOS;
  ELSE
    Path[0]:= EOS;
  END;
#else
  intout[0]:= 0; (* error *)
#endif
END VQTFontHeader;

PROCEDURE VQTTrackKern(    Handle: UNSIGNEDWORD;
                       VAR X     : UNSIGNEDLONG;
                       VAR Y     : UNSIGNEDLONG);

VAR P: POINTER TO ARRAY[0..1] OF UNSIGNEDLONG;

BEGIN
  CallVDI(234,0,0,Handle);
  P:= ADR(ptsout); (* st computer 8/93: intout !? *)
  X:= P^[0];
  Y:= P^[1];
END VQTTrackKern;

PROCEDURE VQTPairKern(    Handle: UNSIGNEDWORD;
                          Ch1   : CHAR;
                          Ch2   : CHAR;
                      VAR X     : UNSIGNEDLONG;
                      VAR Y     : UNSIGNEDLONG);

VAR P: POINTER TO ARRAY[0..1] OF UNSIGNEDLONG;

BEGIN
  intin[0]:= ORD(Ch1);
  intin[1]:= ORD(Ch2);
  CallVDI(235,0,2,Handle);
  P:= ADR(ptsout); (* st computer 8/93: intout !? *)
  X:= P^[0];
  Y:= P^[1];
END VQTPairKern;

PROCEDURE VGetBitmapInfo(    Handle: UNSIGNEDWORD;
                             Ch    : CHAR;
                         VAR AdvX  : UNSIGNEDLONG;
                         VAR AdvY  : UNSIGNEDLONG;
                         VAR XOff  : UNSIGNEDLONG;
                         VAR YOff  : UNSIGNEDLONG;
                         VAR Width : UNSIGNEDWORD;
                         VAR Height: UNSIGNEDWORD;
                         VAR Bitmap: ANYPOINTER);

VAR P: POINTER TO ARRAY[0..3] OF UNSIGNEDLONG;
    Q: POINTER TO ANYPOINTER;

BEGIN
  intin[0]:= ORD(Ch);
  CallVDI(239,0,1,Handle);
  Width:= intout[0];
  Height:= intout[1];
  P:= ADR(intout[2]);
  AdvX:= P^[0];
  AdvY:= P^[1];
  XOff:= P^[2];
  YOff:= P^[3];
  Q:= ADR(intout[10]);
  Bitmap:= Q^;
END VGetBitmapInfo;

END VQuery.
