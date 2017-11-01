IMPLEMENTATION MODULE ApplTool;

(*
Application Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES        IMPORT IBM,Small,IntIn,IntOut,Addr,crystal,Version,
                       Nil,GString,Root,ObjectFlag,LastOb,ObjectState,Normal,
                       Object,Global,String,GBoxChar,GRect;
FROM ApplMgr    IMPORT ApplFind;
FROM GrafMgr    IMPORT GrafHandle,GrafMouse,MOn,MOff;
FROM ObjcMgr    IMPORT ObjcDraw;
FROM RsrcMgr    IMPORT RsrcObFix;
FROM WindTool   IMPORT BeginUpdate,EndUpdate;
FROM VDI        IMPORT XY;
FROM VControl   IMPORT MaxWorkOut;
FROM VAttribute IMPORT VSTFont,VSTPoint;
FROM VQuery     IMPORT VQExtnd,VQTAttributes,TextAttributes;
FROM VRaster    IMPORT VROCpyFm,SOnly,MFDB;
FROM VDITool    IMPORT AESHandle,GlobalHandle,OpenVWork,CloseVWork;
FROM PORTAB     IMPORT NULL,SIGNEDWORD,UNSIGNEDWORD,UNSIGNEDLONG,ANYPOINTER;
FROM INTRINSIC  IMPORT UNSIGNEDWORDOF;
FROM pSTORAGE   IMPORT ALLOCATE,DEALLOCATE,SIZETYPE;
FROM SYSTEM     IMPORT ADR;
AES_SYSTEM_IMPORT

#if ST
#warning ...using GetCookie, CookieVal,
#warning PrefLanguage, Language, signals,
#warning you need M2POSIX/M2LIB
FROM lib       IMPORT void,ptr;
FROM sig       IMPORT SIGTERM,SIGINT,SIGQUIT,SignalHandler,sigsetT,
                      sigaction,SaFlags,SigactionRec,sigemptyset;
FROM DosSystem IMPORT GetCookie,CookieVal,PrefLanguage,Language;
#endif

IMPORT SetObject,GetObject;

#if Seimet
CONST F13 = 00D000101H;

CONST F104 = 068020500H;

CONST F130 = 082010500H;
#endif

PROCEDURE ApplConv(Mode: SIGNEDWORD; Id: SIGNEDWORD): SIGNEDWORD;

VAR Temp: RECORD
            CASE: BOOLEAN OF
              TRUE:
                Array: ARRAY[0..1] OF SIGNEDWORD;
            ELSE
              P: ANYPOINTER;
            END;
          END;

BEGIN
  Temp.Array[0]:= Mode;
  Temp.Array[1]:= Id;
  Addr[0]:= Temp.P;
  IF (Version() >= 0400H) AND (Version() < 1042H) THEN
    crystal(13,0,1,1);
    RETURN IntOut[0];
  ELSE
    RETURN -1; (* error *)
  END;
END ApplConv;

PROCEDURE ApplGetInfo(    Type: UNSIGNEDWORD;
                      VAR Out1: UNSIGNEDWORD;
                      VAR Out2: UNSIGNEDWORD;
                      VAR Out3: UNSIGNEDWORD;
                      VAR Out4: UNSIGNEDWORD);

#if ST
VAR FindStr: ARRAY[0..8] OF CHAR;
    Ver    : UNSIGNEDWORD;
(*
  PROCEDURE VQMagX(): BOOLEAN;

  CONST MagX = 04D616758H;

  VAR Value: CookieVal;

  BEGIN
    IF GetCookie(MagX,Value) THEN
      RETURN TRUE;
    END;
    RETURN FALSE;
  END VQMagX;

  PROCEDURE VQWINX(): BOOLEAN;

  BEGIN
    WITH IntIn DO
      Array[0]:= 0;
      Array[1]:= 22360;
    END;
    IntOut[0]:= 0;
    crystal(104,2,5,0);
    RETURN IntOut[0] = 22360;
  END VQWINX;
*)
#endif

  PROCEDURE QueryAESFont(    Which : UNSIGNEDWORD;
                         VAR Font  : UNSIGNEDWORD;
                         VAR Height: UNSIGNEDWORD);

  (* st magazin 2/93 p. 65 *)

  CONST WordWidth    = 16; (* word width by bits *)
        BytesPerWord = 2;

  VAR Temp   : UNSIGNEDWORD; (* temporary workstation handle *)
      Attrib : TextAttributes;
      WorkOut: ARRAY[0..(MaxWorkOut - 1)] OF UNSIGNEDWORD;
      Buffer : MFDB;
      Screen : MFDB;
      Amount : SIZETYPE;
      PXY    : ARRAY[0..7] OF XY;
      Test   : Object;
      Rect   : GRect;
      GrWChar: UNSIGNEDWORD;
      GrHChar: UNSIGNEDWORD;
      WChar  : UNSIGNEDWORD;
      HChar  : UNSIGNEDWORD;
      Dummy  : UNSIGNEDWORD;
      Size   : UNSIGNEDWORD;
      Points : UNSIGNEDWORD;
(*    Text   : String;*)

  BEGIN
    WITH Test DO
      ObNext:= Nil; ObHead:= ObNext; ObTail:= ObHead;
      SetObject.Extnd(ADR(Test),Root,0); (* clear flag *)
(*    SetObject.Type(ADR(Test),Root,GString);*)
      SetObject.Type(ADR(Test),Root,GBoxChar);
      ObFlags:= ObjectFlag{LastOb};
      ObState:= Normal;
(*    Text:= " ";*)
(*    ObSpec.String:= ADR(Text);*)
      ObSpec.HexCode:= 020001100H; (* space char *)
      ObX:= 0;
      ObY:= 0;
      ObWidth:= 1;
      ObHeight:= 1;
    END;

    RsrcObFix(ADR(Test),Root);
    GetObject.Rect(ADR(Test),Root,Rect);

    GrafMouse(MOff,NIL);
    BeginUpdate;
    IF OpenVWork(Temp) THEN
      WITH Buffer DO
        FDW:= Rect.GW;
        FDH:= Rect.GH;
        FDWdWidth:= (FDW + 15) DIV WordWidth;
        FDStand:= FALSE;
        FDNPlanes:= Global.ApNPlanes;

        Amount:= VAL(SIZETYPE,FDWdWidth * BytesPerWord * FDH * FDNPlanes);

        ALLOCATE(FDAddr,Amount);
      END;

      IF Buffer.FDAddr # NIL THEN
        Screen.FDAddr:= NULL;

        WITH Rect DO
          PXY[0]:= GX;
          PXY[1]:= GY;
          PXY[2]:= GX + GW - 1;
          PXY[3]:= GY + GH - 1;

          PXY[4]:= 0;
          PXY[5]:= 0;
          PXY[6]:= GW - 1;
          PXY[7]:= GH - 1;
        END;

        VROCpyFm(Temp,SOnly,PXY,Screen,Buffer);
        ObjcDraw(ADR(Test),Root,1,Rect);
      END;

      VQTAttributes(GrafHandle(Dummy,Dummy,Dummy,Dummy),Attrib);

      IF Buffer.FDAddr # NIL THEN
        WITH Rect DO
          PXY[0]:= 0;
          PXY[1]:= 0;
          PXY[2]:= GW - 1;
          PXY[3]:= GH - 1;

          PXY[4]:= GX;
          PXY[5]:= GY;
          PXY[6]:= GX + GW - 1;
          PXY[7]:= GY + GH - 1;
        END;

        VROCpyFm(Temp,SOnly,PXY,Buffer,Screen);
        DEALLOCATE(Buffer.FDAddr,Amount);
      END;

      CloseVWork(Temp);
    END;
    EndUpdate;
    GrafMouse(MOn,NIL);

    Font:= Attrib.Font;

    CASE Which OF
      IBM:
        Height:= Attrib.Height;
    | Small:
        VQExtnd(GrafHandle(Dummy,Dummy,Dummy,Dummy),FALSE,WorkOut);
      (*Height:= WorkOut[46]; smallest height *)
        Height:= 4;
    ELSE
      ;
    END;
  END QueryAESFont;

(* alternativ:
  BEGIN
    IF OpenVWork(Temp) THEN
      VQTAttributes(GrafHandle(GrWChar,GrHChar,Dummy,Dummy),Attrib);
      Font:= Attrib.Font;
      VSTFont(Temp,Font);

      CASE Which OF
        IBM:
          Size:= 101;
          LOOP
            Points:= VSTPoint(Temp,Size,Dummy,Height,WChar,HChar);
            IF ((WChar <= GrWChar) AND (HChar <= GrHChar)) OR
               (Points > Size) THEN
              EXIT;
            END;
            Size:= Points - 1;
          END;
      | Small:
          Points:= VSTPoint(Temp,1,Dummy,Height,Dummy,Dummy);
      ELSE
        ;
      END;

      CloseVWork(Temp);
    END;
  END QueryAESFont;
*)

BEGIN
#if ST
  FindStr:= "?AGI";
(*FindStr:= "?AGI"+0C+0C+0C+0C+0C; ISOM2 *)
  (* fill it by 0C *)
  FindStr[4]:= 0C; FindStr[5]:= 0C; FindStr[6]:= 0C; FindStr[7]:= 0C;

  FindStr[8]:= 0C; (* end of C string *)

  IntOut[0]:= 0;

  Ver:= Version();
  IF Ver < 0400H THEN
    IF ApplFind(FindStr) = 0 THEN
      Ver:= 0400H; (* has ApplGetInfo *)
    END;
  END;

  IF (Ver >= 0400H) AND (Ver < 1042H) THEN
    IntIn.Array[0]:= Type;
    crystal(130,1,5,0);
    Out1:= IntOut[1];
    Out2:= IntOut[2];
    Out3:= IntOut[3];
    Out4:= IntOut[4];
  END;
  IF IntOut[0] = 1 THEN (* no error *)
    RETURN;
  ELSE (* ApplGetInfo failed, go on by emulation *)
#endif
    CASE Type OF
      0:
        QueryAESFont(IBM,Out2,Out1);
        Out3:= 0;
    | 1:
        QueryAESFont(Small,Out2,Out1);
        Out3:= 0;
    | 2:
        Out1:= 0;
        Out2:= 16;
        Out3:= 0;
        Out4:= 0;
        IntOut[0]:= 0;
    | 3:
#if ST
        CASE Language() OF
          lFRG,lSWG:
            Out1:= 1; (* german *)
        | lFRA,lSWF:
          (*Out1:= 3; (* french *) *)
            Out1:= 2; (* french *)
        | lSPA:
            Out1:= 4; (* spanish *)
        | lITA:
            Out1:= 5; (* italian *)
        | lSWE:
            Out1:= 6; (* swedish *)
        | lHOL:
            Out1:= 7; (* not yet defined: netherlands *)
        ELSE
          Out1:= 0; (* (american) english *)
        END;
#else
        Out1:= 0;
        Out2:= 0;
        Out3:= 0;
        Out4:= 0;
        IntOut[0]:= 0; (* error *)
#endif
    ELSE
      Out1:= 0;
      Out2:= 0;
      Out3:= 0;
      Out4:= 0;
      IntOut[0]:= 0; (* error *)
    END;
#if ST
  END;
#endif
END ApplGetInfo;

VAR sigint : BOOLEAN;
    sigquit: BOOLEAN;
    sigterm: BOOLEAN;

PROCEDURE ApplSignal(): ApSignals;
BEGIN
  IF sigint THEN
    sigint:= FALSE;
    RETURN ApSigInt;
  END;
  IF sigquit THEN
    sigquit:= FALSE;
    RETURN ApSigQuit;
  END;
  IF sigterm THEN
    sigterm:= FALSE;
    RETURN ApSigTerm;
  END;
  RETURN ApSigNull;
END ApplSignal;

#if ST
VAR new: SigactionRec;

#ifdef HM2
(*$E+,$K+*)
#endif
PROCEDURE sighandler(sig: UNSIGNEDLONG);
BEGIN
  CASE UNSIGNEDWORDOF(sig) OF
    SIGINT:
      sigint:= TRUE;
  | SIGQUIT:
      sigquit:= TRUE;
  | SIGTERM:
      sigterm:= TRUE;
  ELSE

  END;
END sighandler;
#ifdef HM2
(*$E=,$K-*)
#endif
#endif

BEGIN
  sigint := FALSE;
  sigquit:= FALSE;
  sigterm:= FALSE;

#if ST
  WITH new DO
    saHandler:= sighandler;
    saFlags:= SaFlags{};
    sigemptyset(saMask);
  END;

  void(sigaction(SIGINT,ptr(new),NULL));
  void(sigaction(SIGQUIT,ptr(new),NULL));
  void(sigaction(SIGTERM,ptr(new),NULL));
#endif
END ApplTool.
