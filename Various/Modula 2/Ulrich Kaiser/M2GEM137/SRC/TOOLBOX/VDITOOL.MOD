IMPLEMENTATION MODULE VDITool;

(*
VDI Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES      IMPORT Global,IconBlkPtr,GRect;
FROM ApplMgr  IMPORT AddApplInit,AddApplExit;
FROM GrafMgr  IMPORT GrafHandle;
FROM VDI      IMPORT XY,contrl,intin,ptsin,v,ControlBlock,vdi,MFDB;
FROM VControl IMPORT RC,MaxWorkIn,MaxWorkOut,VOpnVWk,VClsVWk,VSClip;
FROM VRaster  IMPORT SOnly;
FROM PORTAB   IMPORT UNSIGNEDWORD,SIGNEDWORD,NULL;
FROM SYSTEM   IMPORT ADR;
CAST_IMPORT

VAR aeshandle    : UNSIGNEDWORD;
    ScreenControl: ControlBlock;

PROCEDURE GetAESHandle(): SIGNEDWORD;

VAR i: UNSIGNEDWORD;

BEGIN
  aeshandle:= GrafHandle(i,i,i,i);
  ScreenControl.v.a[6]:= aeshandle;
  RETURN Global.ApId; (* no error *)
END GetAESHandle;

PROCEDURE AESHandle(): UNSIGNEDWORD;
BEGIN
  RETURN aeshandle;
END AESHandle;

PROCEDURE OpenVirtualWorkstation(VAR Handle: UNSIGNEDWORD): BOOLEAN;

VAR WorkIn : ARRAY[0..(MaxWorkIn - 1)] OF UNSIGNEDWORD;
    WorkOut: ARRAY[0..(MaxWorkOut - 1)] OF UNSIGNEDWORD;
    i      : UNSIGNEDWORD;

BEGIN
  Handle:= AESHandle();

  FOR i:= 0 TO (MaxWorkIn - 1) DO
    WorkIn[i]:= 1;
  END;
  WorkIn[10]:= RC;

  VOpnVWk(WorkIn,Handle,WorkOut);
  RETURN Handle > 0;
END OpenVirtualWorkstation;

PROCEDURE OpenGlobalHandle(): SIGNEDWORD;
BEGIN
  IF OpenVirtualWorkstation(GlobalHandle) THEN
    RETURN Global.ApId; (* no error *)
  ELSE
    RETURN -1;
  END;
END OpenGlobalHandle;

PROCEDURE CloseVirtualWorkstation(VAR Handle: UNSIGNEDWORD);
BEGIN
  VClsVWk(Handle);
END CloseVirtualWorkstation;

PROCEDURE CloseGlobalHandle;
BEGIN
  CloseVirtualWorkstation(GlobalHandle);
END CloseGlobalHandle;

PROCEDURE GRectToArray(VAR Rect : GRect;
                       VAR Array: ARRAY (*[0..3]*) OF XY);
BEGIN
  WITH Rect DO
    Array[0]:= GX;
    Array[1]:= GY;
    Array[2]:= GX + GW - 1;
    Array[3]:= GY + GH - 1;
  END;
END GRectToArray;

PROCEDURE GBoxToArray(VAR Box  : GRect;
                      VAR Array: ARRAY (*[0..9]*) OF XY);
BEGIN
  WITH Box DO
    Array[0]:= GX;
    Array[1]:= GY;
    Array[2]:= GX + GW - 1;
    Array[3]:= GY;
    Array[4]:= Array[2];
    Array[5]:= GY + GH - 1;
    Array[6]:= GX;
    Array[7]:= Array[5];
    Array[8]:= Array[0];
    Array[9]:= Array[1];
  END;
END GBoxToArray;

PROCEDURE GIconToArray(    IconSpec: IconBlkPtr;
                           XOffset : SIGNEDWORD;
                           YOffset : SIGNEDWORD;
                       VAR Array   : ARRAY (*[0..17]*) OF XY);

BEGIN
  (*
    note: same access for CIconBlkPtr, because the first element of
    an CIconBlk is an IconBlk.
  *)

  WITH IconSpec^ DO
    Array[0]:= XOffset + IBXIcon;
    Array[1]:= YOffset + IBYIcon;

    Array[2]:= Array[0];
    Array[3]:= Array[1] + VAL(XY,IBHIcon) - 1;

    Array[4]:= XOffset + IBXText;
    Array[5]:= Array[3];

    Array[6]:= Array[4];
    Array[7]:= Array[3] + VAL(XY,IBHText);

    Array[8]:= XOffset + IBXText + IBWText - 1;
    Array[9]:= Array[7];

    Array[10]:= Array[8];
    Array[11]:= Array[3];

    Array[12]:= XOffset + IBXIcon + IBWIcon - 1;
    Array[13]:= Array[3];

    Array[14]:= Array[12];
    Array[15]:= Array[1];

    Array[16]:= Array[0];
    Array[17]:= Array[1];
   END;
END GIconToArray;

PROCEDURE SetClip(Handle: UNSIGNEDWORD; VAR Rect: GRect);

VAR PXY: ARRAY[0..3] OF XY;

BEGIN
  GRectToArray(Rect,PXY);
  VSClip(Handle,TRUE,PXY);
END SetClip;

VAR Source: MFDB;
    Destin: MFDB;

PROCEDURE MoveScreen(VAR From: GRect; VAR To: GRect);

(* optimized for the sake of speed *)

BEGIN
  intin[0]:= ORD(SOnly);
  WITH From DO
    ptsin[0]:= GX;
    ptsin[1]:= GY;
    ptsin[2]:= GX + GW - 1;
    ptsin[3]:= GY + GH - 1;
  END;
  WITH To DO
    ptsin[4]:= GX;
    ptsin[5]:= GY;
    ptsin[6]:= GX + GW - 1;
    ptsin[7]:= GY + GH - 1;
  END;
  v.pblock:= ADR(ScreenControl);
  vdi;
  v.pblock:= ADR(contrl);
END MoveScreen;

BEGIN
  GlobalHandle:= 0;
#if not proc_const
  OpenVWork:= OpenVirtualWorkstation;
  CloseVWork:= CloseVirtualWorkstation;
#endif
  AddApplInit(GetAESHandle);

  AddApplInit(OpenGlobalHandle);
  AddApplExit(CloseGlobalHandle);

  Source.FDAddr:= NULL;
  Destin.FDAddr:= NULL;

  WITH ScreenControl.v DO
    a[0]:= 109;
    a[1]:= 4;
    a[3]:= 1;
(*  a[6]:= AESHandle();*) (* s. AddApplInit(GetAESHandle) *)
    v1:= ADR(Source);
    v2:= ADR(Destin);
  END;
END VDITool.