IMPLEMENTATION MODULE VRaster;

(*
VDI Raster Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT contrl,intin,ptsin,intout,ptsout,v,vdi,CallVDI,
                   Integer,Point;
FROM PORTAB IMPORT UNSIGNEDWORD,ANYTYPE;
FROM SYSTEM IMPORT ADR;
CAST_IMPORT

PROCEDURE VROCpyFm(    Handle : UNSIGNEDWORD;
                       Mode   : RasterModes;
                   VAR PXY    : ARRAY OF XY;
                   VAR SrcMFDB: ARRAY OF ANYTYPE;
                   VAR DesMFDB: ARRAY OF ANYTYPE);
#if long
VAR i: [0..7];
#endif

BEGIN
  intin[0]:= ORD(Mode);
#if long
  FOR i:= 0 TO 7 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  WITH contrl.v DO
    a[0]:= 109;
    a[1]:= 4;
    a[3]:= 1;
    a[6]:= Handle;
    v1:= ADR(SrcMFDB);
    v2:= ADR(DesMFDB);
  END;
  vdi;
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VROCpyFm;

PROCEDURE VRTCpyFm(    Handle    : UNSIGNEDWORD;
                       Mode      : WritingModes;
                   VAR PXY       : ARRAY OF XY;
                   VAR SrcMFDB   : ARRAY OF ANYTYPE;
                   VAR DesMFDB   : ARRAY OF ANYTYPE;
                       PixelColor: UNSIGNEDWORD;
                       BackGround: UNSIGNEDWORD);
#if long
VAR i: [0..7];
#endif

BEGIN
  intin[0]:= ORD(Mode);
  intin[1]:= PixelColor;
  intin[2]:= BackGround;
  WITH contrl.v DO
    v1:= ADR(SrcMFDB);
    v2:= ADR(DesMFDB);
  END;
#if long
  FOR i:= 0 TO 7 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  CallVDI(121,4,3,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VRTCpyFm;

PROCEDURE VRTrnFm(    Handle : UNSIGNEDWORD;
                  VAR SrcMFDB: ARRAY OF ANYTYPE;
                  VAR DesMFDB: ARRAY OF ANYTYPE);
BEGIN
  WITH contrl.v DO
    v1:= ADR(SrcMFDB);
    v2:= ADR(DesMFDB);
  END;
  CallVDI(110,0,0,Handle);
END VRTrnFm;

PROCEDURE VGetPixel(    Handle: UNSIGNEDWORD;
                        X     : XY;
                        Y     : XY;
                    VAR Pel   : BOOLEAN;
                    VAR Index : UNSIGNEDWORD);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  CallVDI(105,1,0,Handle);
  Pel:= intout[0] = 0;
  Index:= intout[1];
END VGetPixel;

END VRaster.
