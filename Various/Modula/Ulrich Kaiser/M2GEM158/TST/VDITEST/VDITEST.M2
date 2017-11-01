(***************************************************************************)
(* VDI Test Programm.                                                      *)
(* Zeichnet ein Haus und einen Text auf ein beliebiges AusgabegerÑt.       *)
(* Entnommen aus:                                                          *)
(* Geiû, Geiû: "Vom AnfÑnger zum GEM-Profi", Sybex-Verlag                  *)
(* 14/11/1993                                                              *)
(***************************************************************************)

MODULE VDITest;

FROM ApplMgr    IMPORT ApplInit,ApplExit;
FROM EvntMgr    IMPORT EvntKeybd;
FROM FormMgr    IMPORT FormAlert;
FROM GrafMgr    IMPORT GrafHandle,GrafMouse,MOn,MOff;
FROM VControl   IMPORT Screen,Plotter,Printer,Camera,Metafile,Memory,Image,
                       OWNoChange,RC,NDC,MaxWorkIn,MaxWorkOut,
                       VOpnVWk,VOpnWk,VSTLoadFonts,VSTUnloadFonts,
                       VClsVWk,VClsWk,VUpdWk,VClrWk,VSClip;
FROM VAttribute IMPORT MdTrans,VSWrMode,VSLColor,LTSolid,VSLType,
                       VSTColor,VSTFont,VSTEffects,Normal,
                       VSTAlignment,HorizontalAlignments,VerticalAlignments,
                       VSTPoint,VSTRotation;
FROM VOutput    IMPORT VPLine,VGText;
FROM VInput     IMPORT VHideC,VShowC,VRqString;
FROM VScreen    IMPORT VEnterCur,VCurHome,VExitCur,VCurText;
FROM VMetafile  IMPORT VMFileName,VMetaExtents,VMPageSize,VMCoords;
FROM PORTAB     IMPORT UNSIGNEDWORD,NULL,ANYPOINTER;
FROM INTRINSIC  IMPORT VOID,PTR;

IMPORT AES,VDI;

VAR WorkIn      : ARRAY[0..(MaxWorkIn - 1)] OF UNSIGNEDWORD;
    WorkOut     : ARRAY[0..(MaxWorkOut - 1)] OF UNSIGNEDWORD;
    VDIHandle   : UNSIGNEDWORD;
    ScreenHandle: UNSIGNEDWORD;
    FromDesktop : BOOLEAN;
    MetaName    : ARRAY[0..79] OF CHAR;
    MinX        : VDI.XY;
    MinY        : VDI.XY;
    MaxX        : VDI.XY;
    MaxY        : VDI.XY;
    ScreenW     : VDI.XY;
    ScreenH     : VDI.XY;
    MetaW       : VDI.XY;
    MetaH       : VDI.XY;

(***************************************************************************)

PROCEDURE Wait;

VAR EchoXY: ARRAY[0..1] OF VDI.XY;
    String: ARRAY[0..1] OF CHAR;

BEGIN
  EchoXY[0]:= 0;
  EchoXY[1]:= 0;

  IF FromDesktop THEN
    VOID(EvntKeybd());
  ELSE
    VRqString(ScreenHandle,1,FALSE,EchoXY,String);
  END;
END Wait;

(***************************************************************************)

PROCEDURE OpenWork(Device: UNSIGNEDWORD; Coord: UNSIGNEDWORD): BOOLEAN;

CONST MaxMemory = 32767; (* 512 kB (32768 * 16) *)
      FreeSpace = 4096;  (*  64 kB ( 4096 * 16) *)

VAR i     : UNSIGNEDWORD;
    Fonts : UNSIGNEDWORD;
    Clip  : ARRAY[0..3] OF VDI.XY;
    Buffer: VDI.MFDB;

BEGIN
  IF ApplInit() < 0 THEN
    FromDesktop:= AES.Version() > 0; (* Aufruf vom Desktop aus? *)
    IF FromDesktop THEN
      RETURN FALSE; (* Aufruf vom Desktop nicht erfolgreich *)
    END;
  ELSE
    FromDesktop:= TRUE; (* ApplInit() erfolgreich *)
  END;

  FOR i:= 0 TO (MaxWorkIn - 1) DO
    WorkIn[i]:= 1;
  END;

  WorkIn[0]:= Device; (* device handle *)
  WorkIn[10]:= Coord; (* NDC/RC Koordinaten *)

  IF Device # Screen THEN    (* GEM/3 Erweiterungen *)
    WorkIn[11]:= OWNoChange; (* Paralleler oder serieller Port *)
    WorkIn[12]:= 0;          (* Port #0 *)
  END;

  IF Device = Screen THEN
    IF FromDesktop THEN
      VDIHandle:= GrafHandle(i,i,i,i);
      VOpnVWk(WorkIn,VDIHandle,WorkOut); (* virtuell îffnen *)
      GrafMouse(MOff,NULL);
    ELSE
      VOpnWk(WorkIn,0,0,VDIHandle,WorkOut,Buffer); (* physikalisch îffnen *)
      IF VDIHandle > 0 THEN
        VHideC(VDIHandle);
      END;
    END;

    IF Coord = RC THEN
      ScreenHandle:= VDIHandle;          (* merken *)

      ScreenW:= WorkOut[0];
      ScreenH:= WorkOut[1];
    END;
  ELSE
    Buffer.FDAddr:= NULL;
    Buffer.FDNPlanes:= 0;
    VOpnWk(WorkIn,1279,959,VDIHandle,WorkOut,Buffer); (* nicht Bildschirm *)
  END;

  IF VDIHandle > 0 THEN
    CASE Device OF
      Screen:
        IF Coord = RC THEN            (* Vorsichtsmaûnahme *)
          Clip[0]:= 0;
          Clip[1]:= 0;
          Clip[2]:= ScreenW;
          Clip[3]:= ScreenH;
          VSClip(ScreenHandle,TRUE,Clip);
        END;
        VClrWk(VDIHandle);            (* Bildschirm lîschen *)
    | Plotter,Printer,Camera:
        ;
    | Metafile:
        VMFileName(VDIHandle,MetaName);
    ELSE
      ;
    END;

    Fonts:= VSTLoadFonts(VDIHandle,0,MaxMemory,FreeSpace);
  END;
  RETURN VDIHandle > 0;
END OpenWork;

(***************************************************************************)

PROCEDURE CloseWork(Device: UNSIGNEDWORD; Coord: UNSIGNEDWORD);

VAR llx   : VDI.XY;
    lly   : VDI.XY;
    urx   : VDI.XY;
    ury   : VDI.XY;
    Buffer: VDI.MFDB;

BEGIN
  IF Device = Screen THEN
    Wait;
  END;

  IF FromDesktop AND (Device = Screen) THEN
    GrafMouse(MOn,NULL);
    VSTUnloadFonts(VDIHandle,0);
    VClsVWk(VDIHandle);
    ApplExit;
  ELSE
    CASE Device OF
      Screen:
        VShowC(VDIHandle,TRUE);
    | Metafile:
        IF Coord = NDC THEN
          llx:= 0;
          lly:= 0;
          urx:= MetaW;
          ury:= MetaH;
        ELSE           (* RC *)
          llx:= 0;
          lly:= MetaH;
          urx:= MetaW;
          ury:= 0;
        END;
        VMetaExtents(VDIHandle,MinX,MinY,MaxX,MaxY);
        VMPageSize(VDIHandle,1905,2540); (* letter size = 7,5 x 10.00 Zoll *)
        VMCoords(VDIHandle,llx,lly,urx,ury);
    ELSE
      Buffer.FDAddr:= NULL;
      VOID(VUpdWk(VDIHandle,Buffer));
    END;
    VSTUnloadFonts(VDIHandle,0);
    VClsWk(VDIHandle);
  END;
END CloseWork;

(***************************************************************************)

PROCEDURE House(Device: UNSIGNEDWORD; Coord: UNSIGNEDWORD);

CONST Swiss = 2;

VAR i    : UNSIGNEDWORD;
    pxy  : ARRAY[0..11] OF VDI.XY;
    Text : ARRAY[0..15] OF CHAR;
    HorAl: HorizontalAlignments;
    VerAl: VerticalAlignments;
    ErrorMessage: AES.String;

BEGIN
  IF OpenWork(Device,Coord) THEN
    IF Coord = NDC THEN
      pxy[0]:= 6000;
      pxy[1]:= 6000;
      pxy[2]:= 6000;
      pxy[3]:= 10000;
      pxy[4]:= 10000;
      pxy[5]:= 12000;
      pxy[6]:= 14000;
      pxy[7]:= 10000;
      pxy[8]:= 14000;
      pxy[9]:= 6000;
      pxy[10]:= 6000;
      pxy[11]:= 6000;

      IF Device = Metafile THEN
        MinX:= pxy[0];
        MinY:= pxy[1];
        MaxX:= pxy[6];
        MaxY:= pxy[5];

        MetaW:= 32766;
        MetaH:= 32766;
      END;
    ELSE (* RC *)
      pxy[0]:= 100;
      pxy[1]:= 200;
      pxy[2]:= 100;
      pxy[3]:= 100;
      pxy[4]:= 200;
      pxy[5]:= 50;
      pxy[6]:= 300;
      pxy[7]:= 100;
      pxy[8]:= 300;
      pxy[9]:= 200;
      pxy[10]:= 100;
      pxy[11]:= 200;

      IF Device = Metafile THEN
        MinX:= pxy[0];
        MinY:= pxy[5];
        MaxX:= pxy[6];
        MaxY:= pxy[1];

        MetaW:= ScreenW;
        MetaH:= ScreenH;
      END;
    END;

    VSWrMode(VDIHandle,MdTrans);
    VSLColor(VDIHandle,VDI.Red);
    VSLType(VDIHandle,LTSolid);
    VPLine(VDIHandle,6,pxy); (* Haus zeichnen *)

    VSTColor(VDIHandle,VDI.Green);
    VSTFont(VDIHandle,Swiss);
    VSTEffects(VDIHandle,Normal);
    VSTAlignment(VDIHandle,TALeft,TABottom,HorAl,VerAl);
    VOID(VSTPoint(VDIHandle,10,i,i,i,i));
    VSTRotation(VDIHandle,0);
    Text:= "VDI-Test HAUS";
    VGText(VDIHandle,pxy[0],pxy[1],Text);
    CloseWork(Device,Coord);
  ELSE
    IF FromDesktop THEN
      ErrorMessage:= "[3][| GerÑt nicht verfÅgbar. ][Abbruch]";
    (*ErrorMessage:= "[3][| Device not available. ][Cancel]";*)
      VOID(FormAlert(1,PTR(ErrorMessage)));
      ApplExit;
    ELSE
      IF ScreenHandle > 0 THEN
        ErrorMessage:= "GerÑt nicht verfÅgbar. Taste... ";
      (*ErrorMessage:= "Device not available. Hit any key...";*)
        VEnterCur(ScreenHandle);
        VCurHome(ScreenHandle);
        VCurText(ScreenHandle,ErrorMessage);
        Wait;
        VExitCur(ScreenHandle);
      END;
    END;
  END;
END House;

(***************************************************************************)

BEGIN
  House(Screen,RC);
  House(Screen,NDC);

  House(Plotter,RC);
  House(Plotter,NDC);

  House(Printer,RC);
  House(Printer,NDC);

  House(Printer + 1,RC); (* second printer *)
  House(Printer + 1,NDC);

  MetaName:= "HOUSERC.GEM";
  House(Metafile,RC);
  MetaName:= "HOUSENDC.GEM";
  House(Metafile,NDC);

  House(Camera,RC);
  House(Camera,NDC);

  House(Memory,RC);
  House(Memory,NDC);

  House(Image,RC);
  House(Image,NDC);
END VDITest.
