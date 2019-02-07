MODULE TestBezier;

(* Demo-Quelltext fÅr die Bearbeitung von Off-Screen-Bitmaps*)

FROM ApplMgr    IMPORT ApplInit,ApplExit;
FROM GrafMgr    IMPORT GrafHandle,GrafMouse,MOn,MOff;
FROM EvntMgr    IMPORT EvntKeybd;
FROM VDI        IMPORT XY,MFDB,Black,Green;
FROM VControl   IMPORT RC,VOpnVWk,VClsVWk,VOpnBm,VClsBm,VSClip,
                       VBezOn,VBezOff,VBezQual;
FROM VAttribute IMPORT VSFColor,VSFInterior,FISPattern,VSFStyle,
                       VSFPerimeter,VSWrMode,MdReplace;
FROM VOutput    IMPORT VGText,VBar,VBezFill;
FROM VRaster    IMPORT VROCpyFm,SOnly;
FROM PORTAB     IMPORT UNSIGNEDWORD,NULL,UNSIGNEDBYTE;
FROM INTRINSIC  IMPORT VOID;

(* Globale Variablen *)

VAR SHandle  : UNSIGNEDWORD;
    BHandle  : UNSIGNEDWORD;

    ScreenOut: ARRAY[0..127] OF UNSIGNEDWORD;
    BitmapOut: ARRAY[0..127] OF UNSIGNEDWORD;

    Screen   : MFDB;
    Bitmap   : MFDB;

    XYArr    : ARRAY[0..7] OF XY;

(* virtuelle Workstation îffnen *)

PROCEDURE OpenVWk(VAR WorkOut: ARRAY OF UNSIGNEDWORD): UNSIGNEDWORD;

VAR Count : [0..9];
    Dummy : UNSIGNEDWORD;
    Handle: UNSIGNEDWORD;
    WorkIn: ARRAY[0..10] OF UNSIGNEDWORD;

BEGIN
  Handle:= GrafHandle(Dummy,Dummy,Dummy,Dummy);

  FOR Count:= 0 TO 9 DO
    WorkIn[Count]:= 1;
  END;

  WorkIn[10]:= RC; (* Rasterkoordinaten *)

  VOpnVWk(WorkIn,Handle,WorkOut);

  RETURN Handle;
END OpenVWk;

(* Off-Screen-Bitmap îffnen *)

PROCEDURE OpenBitmap(    X      : UNSIGNEDWORD;
                         Y      : UNSIGNEDWORD;
                     VAR Bitmap : MFDB;
                     VAR WorkOut: ARRAY OF UNSIGNEDWORD): UNSIGNEDWORD;

VAR Count : [0..19];
    Dummy : UNSIGNEDWORD;
    Handle: UNSIGNEDWORD;
    WorkIn: ARRAY[0..19] OF UNSIGNEDWORD;

BEGIN
  Handle:= GrafHandle(Dummy,Dummy,Dummy,Dummy);

  FOR Count:= 0 TO 9 DO
    WorkIn[Count]:= 1;
  END;

  WorkIn[10]:= RC; (* Rasterkoordinaten *)

  WorkIn[11]:= X; (* Breite - 1 *)
  WorkIn[12]:= Y; (* Hîhe   - 1 *)

  WorkIn[13]:= 0; (* Pixelbreite und -Hîhe des Bildschirms Åbernehmen *)
  WorkIn[14]:= 0;

  FOR Count:= 15 TO 19 DO
    WorkIn[Count]:= 0;    (* reserviert *)
  END;

  VOpnBm(WorkIn,Bitmap,Handle,WorkOut);

  RETURN Handle;
END OpenBitmap;

(* Clipping fÅr den Bildschirm setzen *)

PROCEDURE ClipScreen;

VAR XYArr: ARRAY[0..3] OF XY;

BEGIN
  XYArr[0]:= 0;
  XYArr[1]:= 0;
  XYArr[2]:= ScreenOut[0];
  XYArr[3]:= ScreenOut[1];
  VSClip(SHandle,TRUE,XYArr); (* Clipping fÅr den Bildschirm *)
END ClipScreen;

(* Clipping fÅr die Bitmap setzen *)

PROCEDURE ClipBitmap;

VAR XYArr: ARRAY[0..3] OF XY;

BEGIN
  XYArr[0]:= 0;
  XYArr[1]:= 0;
  XYArr[2]:= BitmapOut[0];
  XYArr[3]:= BitmapOut[1];
  VSClip(BHandle,TRUE,XYArr); (* Clipping fÅr die Bitmap *)
END ClipBitmap;

(* Auf der Off-Screen-Bitmap zeichnen *)

PROCEDURE Draw;

VAR BezArr  : ARRAY[0..511] OF UNSIGNEDBYTE;
    XYArr   : ARRAY[0..511] OF UNSIGNEDWORD;
    Extent  : ARRAY[0..3] OF XY;
    Actual  : UNSIGNEDWORD;
    TotPts  : UNSIGNEDWORD;
    TotMoves: UNSIGNEDWORD;
    Text    : ARRAY[0..5] OF CHAR;

BEGIN
  VSFColor(BHandle,Green);
  VSFInterior(BHandle,FISPattern);
  VSFStyle(BHandle,1);
  VSFPerimeter(BHandle,TRUE);
  VSWrMode(BHandle,MdReplace);

  XYArr[0]:= 0;
  XYArr[1]:= 0;
  XYArr[2]:= 250;
  XYArr[3]:= 250;
  VBar(BHandle,XYArr);

  VSFColor(BHandle,Black);
  VSFStyle(BHandle,3);
  VOID(VBezOn(BHandle));
  Actual:= VBezQual(BHandle,100);

  XYArr[0]:= 100;
  XYArr[1]:= 100;
  XYArr[2]:= 400;
  XYArr[3]:= 100;
  XYArr[4]:= 400;
  XYArr[5]:= 400;
  XYArr[6]:= 100;
  XYArr[7]:= 400;

  XYArr[8]:= 200;
  XYArr[9]:= 200;
  XYArr[10]:= 300;
  XYArr[11]:= 200;
  XYArr[12]:= 300;
  XYArr[13]:= 300;
  XYArr[14]:= 200;
  XYArr[15]:= 300;

  BezArr[0]:= 1;
  BezArr[1]:= 0;
  BezArr[2]:= 0;
  BezArr[3]:= 0;
  BezArr[4]:= 3;
  BezArr[5]:= 0;
  BezArr[6]:= 0;
  BezArr[7]:= 0;

  VBezFill(BHandle,8,XYArr,BezArr,Extent,TotPts,TotMoves);
  VBezOff(BHandle);

  Text:= "Text!";
  VGText(BHandle,50,50,Text);
END Draw;

BEGIN
  IF ApplInit() >= 0 THEN
    SHandle:= OpenVWk(ScreenOut);
    IF SHandle # 0 THEN
      Bitmap.FDAddr:= NULL; (* VDI alloziert Bitmap *)
      Bitmap.FDNPlanes:= 0; (* Planeanzahl wie Bildschirm *)

      BHandle:= OpenBitmap(799,607,Bitmap,BitmapOut);
      IF BHandle # 0 THEN
        ClipScreen; (* Clipping fÅr den Bildschirm setzen *)
        ClipBitmap; (* Clipping fÅr die Bitmap setzen     *)
        Draw;       (* auf der Off-Screen-Bitmap zeichnen *)

        (* und jetzt die Bitmap auf den Bildschirm kopieren... *)

        Screen.FDAddr:= NULL;

        XYArr[0]:= 0;
        XYArr[1]:= 0;
        XYArr[2]:= 799;
        XYArr[3]:= 607;
        XYArr[4]:= 100;
        XYArr[5]:= 100;
        XYArr[6]:= 899;
        XYArr[7]:= 707;

        GrafMouse(MOff,NIL);
        VROCpyFm(SHandle,SOnly,XYArr,Bitmap,Screen);
        GrafMouse(MOn,NIL);

        VOID(EvntKeybd());

        VClsBm(BHandle); (* Bitmap schlieûen *)
      END;

      VClsVWk(SHandle); (* virtuelle Workstation schlieûen *)

      ApplExit;
    END;
  END;
END TestBezier.
