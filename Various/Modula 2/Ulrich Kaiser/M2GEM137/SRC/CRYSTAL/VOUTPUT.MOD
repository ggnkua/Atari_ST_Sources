IMPLEMENTATION MODULE VOutput;

(*
VDI Output Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT contrl,intin,intout,ptsin,ptsout,v,CallVDI,vdi,EOS,
                   Integer,IntegerInputRange,PointsInputRange,
                   MaxInput,MaxPoints;
FROM PORTAB IMPORT ANYWORD,ANYTYPE,ANYBYTE,UNSIGNEDWORD,WORDSET;
FROM SYSTEM IMPORT ADR;
CAST_IMPORT

PROCEDURE VPLine(    Handle: UNSIGNEDWORD;
                     Count : UNSIGNEDWORD;
                 VAR PXY   : ARRAY OF XY);
#if long
VAR i: [0..(MaxPoints - 1)];
#endif

BEGIN
#if long
  FOR i:= 0 TO (2 * Count - 1) DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  CallVDI(6,Count,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VPLine;

PROCEDURE VPMarker(    Handle: UNSIGNEDWORD;
                       Count : UNSIGNEDWORD;
                   VAR PXY   : ARRAY OF XY);
#if long
VAR i: [0..(MaxPoints - 1)];
#endif
BEGIN
#if long
  FOR i:= 0 TO (2 * Count - 1) DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  CallVDI(7,Count,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VPMarker;

PROCEDURE VGText(    Handle: UNSIGNEDWORD;
                     X     : XY;
                     Y     : XY;
                 VAR Text  : ARRAY OF CHAR);

VAR i: [0..MaxInput];

BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  i:= 0;
  WHILE Text[i] # EOS DO
    intin[i]:= ORD(Text[i]);
    INC(i);
  END;
  WITH contrl DO
    c[0]:= 8;
    c[1]:= 1;
    c[3]:= i; (* (i - 1) + 1 = i *)
    c[6]:= Handle;
  END;
  vdi;
END VGText;

PROCEDURE VEText(  Handle : UNSIGNEDWORD;
                     X      : XY;
                     Y      : XY;
                 VAR Text   : ARRAY OF CHAR;
                 VAR Offsets: ARRAY OF XY);

VAR i: [0..MaxInput - 1];

BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  i:= 0;
  WHILE Text[i] # EOS DO
    intin[i]:= ORD(Text[i]);
    ptsin[2 * i + 2]:= Offsets[2 * i];
    ptsin[2 * i + 3]:= Offsets[2 * i + 1];
    INC(i);
  END;
  contrl.c[5]:= 11;
  CallVDI(11,i + 1,i,Handle); (* (i + 1) - 1 + 1 = i + 1 *)
END VEText;

PROCEDURE VFillArea(    Handle: UNSIGNEDWORD;
                        Count : UNSIGNEDWORD;
                    VAR PXY   : ARRAY OF XY);
#if long
VAR i: [0..(MaxPoints - 1)];
#endif
BEGIN
#if long
  FOR i:= 0 TO (2 * Count - 1) DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  CallVDI(9,Count,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VFillArea;

PROCEDURE VCellArray(  Handle   : UNSIGNEDWORD;
                     VAR PXY      : ARRAY OF XY;
                         RowLength: UNSIGNEDWORD;
                         ElUsed   : UNSIGNEDWORD;
                         NumRows  : UNSIGNEDWORD;
                         WrtMode  : WritingModes;
                     VAR ColArray : ARRAY OF ANYWORD);
#if long
CONST Max = 512;

VAR i: [0..(Max - 1)];
#endif
BEGIN
#if long
  FOR i:= 0 TO (RowLength * NumRows) DO
    intin[i]:= ColArray[i];
  END;
  FOR i:= 0 TO 3 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.iioff:= ADR(ColArray);
  v.pioff:= ADR(PXY);
#endif
  WITH contrl DO
    c[7]:= RowLength;
    c[8]:= ElUsed;
    c[9]:= NumRows;
    c[10]:= ORD(WrtMode);
  END;
  CallVDI(10,2,RowLength * NumRows,Handle);
#if not long
  v.iioff:= ADR(intin);
  v.pioff:= ADR(ptsin);
#endif
END VCellArray;

PROCEDURE VContourFill(Handle: UNSIGNEDWORD;
                       X     : XY;
                       Y     : XY;
                       Index : UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  ptsin[0]:= X;
  ptsin[1]:= Y;
  CallVDI(103,1,1,Handle);
END VContourFill;

PROCEDURE VRRecFl(    Handle: UNSIGNEDWORD;
                  VAR PXY   : ARRAY OF XY);
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
  CallVDI(114,2,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VRRecFl;

PROCEDURE VBar(    Handle: UNSIGNEDWORD;
               VAR PXY   : ARRAY OF XY);
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
  contrl.c[5]:= 1;
  CallVDI(11,2,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VBar;

PROCEDURE VArc(Handle: UNSIGNEDWORD;
               X     : XY;
               Y     : XY;
               Radius: UNSIGNEDWORD;
               BegAng: UNSIGNEDWORD;
               EndAng: UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= 0;
  ptsin[3]:= 0;
  ptsin[4]:= 0;
  ptsin[5]:= 0;
  ptsin[6]:= Radius;
  ptsin[7]:= 0;
  intin[0]:= BegAng;
  intin[1]:= EndAng;
  contrl.c[5]:= 2;
  CallVDI(11,4,2,Handle);
END VArc;

PROCEDURE VPie(Handle: UNSIGNEDWORD;
               X     : XY;
               Y     : XY;
               Radius: UNSIGNEDWORD;
               BegAng: UNSIGNEDWORD;
               EndAng: UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= 0;
  ptsin[3]:= 0;
  ptsin[4]:= 0;
  ptsin[5]:= 0;
  ptsin[6]:= Radius;
  ptsin[7]:= 0;
  intin[0]:= BegAng;
  intin[1]:= EndAng;
  contrl.c[5]:= 3;
  CallVDI(11,4,2,Handle);
END VPie;

PROCEDURE VCircle(Handle: UNSIGNEDWORD;
                  X     : XY;
                  Y     : XY;
                  Radius: UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= 0;
  ptsin[3]:= 0;
  ptsin[4]:= Radius;
  ptsin[5]:= 0;
  contrl.c[5]:= 4;
  CallVDI(11,3,0,Handle);
END VCircle;

PROCEDURE VEllipse(Handle : UNSIGNEDWORD;
                   X      : XY;
                   Y      : XY;
                   XRadius: UNSIGNEDWORD;
                   YRadius: UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= XRadius;
  ptsin[3]:= YRadius;
  contrl.c[5]:= 5;
  CallVDI(11,2,0,Handle);
END VEllipse;

PROCEDURE VEllArc(Handle : UNSIGNEDWORD;
                  X    : XY;
                  Y    : XY;
                  XRadius: UNSIGNEDWORD;
                  YRadius: UNSIGNEDWORD;
                  BegAng : UNSIGNEDWORD;
                  EndAng : UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= XRadius;
  ptsin[3]:= YRadius;
  intin[0]:= BegAng;
  intin[1]:= EndAng;
  contrl.c[5]:= 6;
  CallVDI(11,2,2,Handle);
END VEllArc;

PROCEDURE VEllPie(Handle : UNSIGNEDWORD;
                  X    : XY;
                  Y    : XY;
                  XRadius: UNSIGNEDWORD;
                  YRadius: UNSIGNEDWORD;
                  BegAng : UNSIGNEDWORD;
                  EndAng : UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= XRadius;
  ptsin[3]:= YRadius;
  intin[0]:= BegAng;
  intin[1]:= EndAng;
  contrl.c[5]:= 7;
  CallVDI(11,2,2,Handle);
END VEllPie;

PROCEDURE VRBox(    Handle: UNSIGNEDWORD;
                VAR PXY   : ARRAY OF XY);
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
  contrl.c[5]:= 8;
  CallVDI(11,2,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VRBox;

PROCEDURE VRFBox(  Handle: UNSIGNEDWORD;
                 VAR PXY   : ARRAY OF XY);
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
  contrl.c[5]:= 9;
  CallVDI(11,2,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VRFBox;

PROCEDURE VJustified(  Handle    : UNSIGNEDWORD;
                         X         : XY;
                         Y         : XY;
                     VAR Text    : ARRAY OF CHAR;
                         TextLength: UNSIGNEDWORD;
                         WordSpace : BOOLEAN;
                         CharSpace : BOOLEAN;
                         CharInfo  : BOOLEAN;
                     VAR CharWidth : ARRAY OF UNSIGNEDWORD);

VAR i: [0..(MaxInput - 1)];

BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  ptsin[2]:= TextLength;
  ptsin[3]:= 0;
#if (defined SPCM2) || (defined LPRM2)
  intin[0]:= ORD(WordSpace);
  IF CharInfo THEN
    INCL(CAST(WORDSET,intin[0]),15);
  END;
  intin[1]:= ORD(CharSpace);
#else
  intin[0]:= 8000H * ORD(CharInfo) + ORD(WordSpace);
  intin[1]:= ORD(CharSpace);
#endif
  i:= 0;
  WHILE Text[i] # EOS DO
    intin[i + 2]:= ORD(Text[i]);
    INC(i);
  END;
#if not long
  v.iooff:= ADR(CharWidth);
#endif
  contrl.c[5]:= 10;
  CallVDI(11,2,i + 1,Handle);  (* (i - 1) + 2 = i + 1 *)
#if not long
  v.iooff:= ADR(intout);
#else
  WHILE i > 0 DO
    DEC(i);
    CharWidth[i]:= intout[i];
  END;
#endif
END VJustified;

PROCEDURE VBez(    Handle  : UNSIGNEDWORD;
                   Count   : UNSIGNEDWORD;
               VAR PXY     : ARRAY OF XY;
               VAR BezArray: ARRAY OF ANYBYTE;
               VAR Extent  : ARRAY OF XY;
               VAR NPoints : UNSIGNEDWORD;
               VAR NMove   : UNSIGNEDWORD);

VAR i        : [0..(MaxInput + 1)];
    ByteArray: ARRAY IntegerInputRange OF ANYBYTE;

BEGIN
  v.pioff:= ADR(PXY);
  v.iioff:= ADR(ByteArray);

  (* ByteArray        : [0] [1] [2] [3] [4] [5] *)
  (* := BezArray[0..4]: [1] [0] [3] [2] [?] [4] *)

  i:= 0;

  WHILE i < Count DO
    ByteArray[i + 1]:= BezArray[i];
    IF (i + 1) < Count THEN
      ByteArray[i]:= BezArray[i + 1];
    END;
    INC(i,2);
  END;

  v.pooff:= ADR(Extent);
  contrl.c[2]:= 2; (* ATARI docs say so *)
  contrl.c[4]:= 6; (* ATARI docs say so *)
  contrl.c[5]:= 13;
  CallVDI(6,Count,(Count + 1) DIV 2,Handle);
  v.pioff:= ADR(ptsin);
  v.iioff:= ADR(intin);
  v.pooff:= ADR(ptsout);
  NPoints:= intout[0];
  NMove:= intout[1];
END VBez;

PROCEDURE VBezFill(    Handle  : UNSIGNEDWORD;
                       Count   : UNSIGNEDWORD;
                   VAR PXY     : ARRAY OF XY;
                   VAR BezArray: ARRAY OF ANYBYTE;
                   VAR Extent  : ARRAY OF XY;
                   VAR NPoints : UNSIGNEDWORD;
                   VAR NMove   : UNSIGNEDWORD);

VAR i        : [0..(MaxInput + 1)];
    ByteArray: ARRAY IntegerInputRange OF ANYBYTE;

BEGIN
  v.pioff:= ADR(PXY);
  v.iioff:= ADR(ByteArray);

  (* ByteArray        : [0] [1] [2] [3] [4] [5] *)
  (* := BezArray[0..4]: [1] [0] [3] [2] [?] [4] *)

  i:= 0;

  WHILE i < Count DO
    ByteArray[i + 1]:= BezArray[i];
    IF (i + 1) < Count THEN
      ByteArray[i]:= BezArray[i + 1];
    END;
    INC(i,2);
  END;

  v.pooff:= ADR(Extent);
  contrl.c[2]:= 2;
  contrl.c[4]:= 6;
  contrl.c[5]:= 13;
  CallVDI(9,Count,(Count + 1) DIV 2,Handle);
  v.pioff:= ADR(ptsin);
  v.iioff:= ADR(intin);
  v.pooff:= ADR(ptsout);
  NPoints:= intout[0];
  NMove:= intout[1];
END VBezFill;

PROCEDURE VFText(    Handle: UNSIGNEDWORD;
                     X     : XY;
                     Y     : XY;
                 VAR Text  : ARRAY OF CHAR);

VAR i: [0..MaxInput];

BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  i:= 0;
  WHILE Text[i] # EOS DO
    intin[i]:= ORD(Text[i]);
    INC(i);
  END;
  WITH contrl DO
    c[0]:= 241;
    c[1]:= 1;
    c[3]:= i; (* (i - 1) + 1 = i *)
    c[6]:= Handle;
  END;
  vdi;
END VFText;

PROCEDURE VFTextOffset(    Handle: UNSIGNEDWORD;
                           X     : XY;
                           Y     : XY;
                       VAR Text  : ARRAY OF CHAR;
                       VAR Offset: ARRAY OF XY);

VAR i: [0..MaxInput];
    j: PointsInputRange;

BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;

  i:= 0;
  WHILE Text[i] # EOS DO
    intin[i]:= ORD(Text[i]);
    INC(i);
  END;

  FOR j:= 0 TO (2 * i - 1) DO
    ptsin[j + 2]:= Offset[j];
  END;

  WITH contrl DO
    c[0]:= 241; (* yes, 241! *)
    c[1]:= i + 1;
    c[3]:= i; (* (i - 1) + 1 = i *)
    c[6]:= Handle;
  END;
  vdi;
END VFTextOffset;

END VOutput.

