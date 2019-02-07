MODULE MemoryDevice;

(* UK 14.7.93 *)

FROM ApplMgr    IMPORT ApplInit,ApplExit;
FROM EvntMgr    IMPORT EvntKeybd,ScanWord;
FROM FormMgr    IMPORT FormAlert;
FROM VDI        IMPORT XY,White,Black;
FROM VControl   IMPORT Memory,RC,MaxWorkIn,MaxWorkOut,
                       VOpnWk,VClsWk,VUpdWk,VClrWk,VSClip;
FROM VAttribute IMPORT VSFColor,VSFPerimeter;
FROM VOutput    IMPORT VCircle;
FROM VRaster    IMPORT MFDB,SOnly,VROCpyFm,VRTCpyFm,VRTrnFm,WritingModes;
FROM WindTool   IMPORT BeginUpdate,EndUpdate;
FROM GrafTool   IMPORT ShowMouse,HideMouse;
FROM VDITool    IMPORT OpenVWork,CloseVWork;
FROM PORTAB     IMPORT UNSIGNEDWORD,ANYPOINTER,NULL;
FROM INTRINSIC  IMPORT VOID,PTR;

CONST OffScreen = 90; (* reserviert fr OffScreen *)

PROCEDURE DoCopy(Work: UNSIGNEDWORD);

VAR ScreenHandle: UNSIGNEDWORD;
    MemoryHandle: UNSIGNEDWORD;
    i           : [0..(MaxWorkIn - 1)];
    WorkIn      : ARRAY[0..(MaxWorkIn - 1)] OF UNSIGNEDWORD;
    WorkOut     : ARRAY[0..(MaxWorkOut - 1)] OF UNSIGNEDWORD;
    PXY         : ARRAY[0..7] OF XY;
    Source      : MFDB;
    Destination : MFDB;
    Key         : ScanWord;
    Button      : UNSIGNEDWORD;
    AlertString : ARRAY[0..255] OF CHAR;

BEGIN
    BeginUpdate;
    IF OpenVWork(ScreenHandle) THEN

      FOR i:= 1 TO (MaxWorkIn - 1) DO
        WorkIn[i]:= 1;
      END;

      WorkIn[0]:= Work;
      WorkIn[10]:= RC;

      Source.FDAddr:= NULL; (* fr OffScreen *)
      Source.FDNPlanes:= 0; (* fr OffScreen *)

      (* ™ffne "Speicherbildschirm" mit 1280 x 960 Pixeln *)

      VOpnWk(WorkIn,1279,959,MemoryHandle,WorkOut,Source);

      IF MemoryHandle > 0 THEN
        VSClip(MemoryHandle,FALSE,PXY);
        VSFColor(MemoryHandle,Black);
        VSFPerimeter(MemoryHandle,TRUE);
        VCircle(MemoryHandle,50,50,50);

        WITH Source DO (* bei OffScreen kann dieser WITH Block entfallen *)
          FDW:= 1280;
          FDH:= 960;
          FDWdWidth:= 80; (* 1280 DIV 16 *)
          FDStand:= TRUE;
          FDNPlanes:= 1;
        END;

        Destination.FDAddr:= NULL;

        PXY[0]:= 0;
        PXY[1]:= 0;
        PXY[2]:= 99;
        PXY[3]:= 99;

        PXY[4]:= 0;
        PXY[5]:= 0;
        PXY[6]:= 99;
        PXY[7]:= 99;

        HideMouse;
        VSClip(ScreenHandle,FALSE,PXY);
        VRTCpyFm(ScreenHandle,MdReplace,PXY,Source,Destination,Black,White);
        VClsWk(MemoryHandle);
        ShowMouse;
      ELSE
        AlertString:= "[1][| Fehler! |][Abbruch]";
        Button:= FormAlert(1,PTR(AlertString));
      END;

      Key:= EvntKeybd();

      CloseVWork(ScreenHandle);
    END;
    EndUpdate;
END DoCopy;

BEGIN
  IF ApplInit() >= 0 THEN
    DoCopy(Memory);
    DoCopy(OffScreen);
    ApplExit;
  END;
END MemoryDevice.
