IMPLEMENTATION MODULE VPrinter;

(*
VDI Printer Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI      IMPORT contrl,intin,ptsin,intout,ptsout,v,vdi,CallVDI,
                     CallVDIEsc,CallEsc,EOS,XY,MaxInput,Integer;
FROM PORTAB   IMPORT UNSIGNEDWORD,SIGNEDWORD;
FROM SYSTEM   IMPORT ADR;
CAST_IMPORT

PROCEDURE VFormAdv(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(20,Handle);
END VFormAdv;

PROCEDURE VOutputWindow(    Handle: UNSIGNEDWORD;
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
  CallVDIEsc(21,2,0,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VOutputWindow;

PROCEDURE VClearDispList(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(22,Handle);
END VClearDispList;

PROCEDURE VBitImage(    Handle: UNSIGNEDWORD;
                    VAR Path  : ARRAY OF CHAR;
                        Aspect: BOOLEAN;
                        XScale: BOOLEAN;
                        YScale: BOOLEAN;
                        HAlign: HorizontalAlignments;
                        VAlign: VerticalAlignments;
                    VAR PXY   : ARRAY OF XY);

VAR i: [0..MaxInput];

BEGIN
#if long
  FOR i:= 0 TO 3 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  intin[0]:= ORD(Aspect);
  intin[1]:= ORD(XScale);
  intin[2]:= ORD(YScale);
  intin[3]:= ORD(HAlign);
  intin[4]:= ORD(VAlign);
  i:= 0;
  WHILE Path[i] # EOS DO
    intin[i + 5]:= ORD(Path[i]);
    INC(i);
  END;
  CallVDIEsc(23,2,i + 4,Handle); (* (i - 1) + 5 = i + 4 *)
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VBitImage;

PROCEDURE VXBitImage(    Handle    : UNSIGNEDWORD;
                     VAR Path      : ARRAY OF CHAR;
                         Aspect    : BOOLEAN;
                         XScale    : BOOLEAN;
                         YScale    : BOOLEAN;
                         HAlign    : HorizontalAlignments;
                         VAlign    : VerticalAlignments;
                         Rotate    : UNSIGNEDWORD;
                         BackGround: UNSIGNEDWORD;
                         ForeGround: UNSIGNEDWORD;
                     VAR PXY       : ARRAY OF XY);

VAR i: [0..MaxInput];

BEGIN
#if long
  FOR i:= 0 TO 3 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  intin[0]:= ORD(Aspect);
  intin[1]:= ORD(XScale);
  intin[2]:= ORD(YScale);
  intin[3]:= ORD(HAlign);
  intin[4]:= ORD(VAlign);
  intin[5]:= Rotate;
  intin[6]:= BackGround;
  intin[7]:= ForeGround;
  i:= 0;
  WHILE Path[i] # EOS DO
    intin[i + 8]:= ORD(Path[i]);
    INC(i);
  END;
  CallVDIEsc(23,2,i + 7,Handle); (* (i - 1) + 8 = i + 7 *)
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VXBitImage;

PROCEDURE VQScan(    Handle     : UNSIGNEDWORD;
                 VAR Slices     : UNSIGNEDWORD;
                 VAR PageHeight : UNSIGNEDWORD;
                 VAR SliceHeight: UNSIGNEDWORD;
                 VAR LinesPage  : UNSIGNEDWORD;
                 VAR DivFactor  : UNSIGNEDWORD);
BEGIN
  CallEsc(24,Handle);
  Slices:= intout[0];
  PageHeight:= intout[1];
  SliceHeight:= intout[2];
  LinesPage:= intout[3];
  DivFactor:= intout[4];
END VQScan;

PROCEDURE VAlphaText(    Handle: UNSIGNEDWORD;
                     VAR String: ARRAY OF CHAR);

VAR i: [0..MaxInput];

BEGIN
  i:= 0;
  WHILE String[i] # EOS DO
    intin[i]:= ORD(String[i]);
    INC(i);
  END;
  CallVDIEsc(25,0,i,Handle); (* i - 1 + 1 = i *)
END VAlphaText;

PROCEDURE VOrient(Handle: UNSIGNEDWORD;
                  Orient: Orientations);
BEGIN
  intin[0]:= ORD(Orient);
  CallVDIEsc(27,0,1,Handle);
END VOrient;

PROCEDURE VCopies(Handle: UNSIGNEDWORD;
                  Count : UNSIGNEDWORD);
BEGIN
  intin[0]:= Count;
  CallVDIEsc(28,0,1,Handle);
END VCopies;

PROCEDURE VTray(Handle: UNSIGNEDWORD;
                Tray  : SIGNEDWORD);
BEGIN
  intin[0]:= Tray;
  CallVDIEsc(29,0,1,Handle);
END VTray;

PROCEDURE VPSHalftone(Handle   : UNSIGNEDWORD;
                      Index    : UNSIGNEDWORD;
                      Angle    : UNSIGNEDWORD;
                      Frequency: UNSIGNEDWORD);
BEGIN
  intin[0]:= Index;
  intin[1]:= Angle;
  CallVDIEsc(32,0,1,Handle);
END VPSHalftone;

PROCEDURE VEscape2000(Handle: UNSIGNEDWORD;
                      Times : UNSIGNEDWORD);
BEGIN
  intin[0]:= Times;
  CallVDIEsc(2000,0,1,Handle);
END VEscape2000;

END VPrinter.
