IMPLEMENTATION MODULE ApplTool;

(*
Application Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES        IMPORT IBM,Small,IntIn,IntOut,Addr,crystal,Version,
                       Nil,GString,Root,ObjectFlag,LastOb,ObjectState,Normal,
                       Object,Global,String,GBoxChar,GRect;
FROM GrafMgr    IMPORT GrafHandle,GrafMouse,MOn,MOff;
FROM ObjcMgr    IMPORT ObjcDraw;
FROM RsrcMgr    IMPORT RsrcObFix;
FROM WindTool   IMPORT BeginUpdate,EndUpdate;
FROM VDI        IMPORT XY;
FROM VControl   IMPORT MaxWorkOut;
FROM VAttribute IMPORT VSTFont,VSTPoint;
FROM VQuery     IMPORT VQExtnd,VQTAttributes,TextAttributes;
FROM VRaster    IMPORT VROCpyFm,SOnly,MFDB;
FROM VDITool    IMPORT OpenVWork,CloseVWork;
FROM PORTAB     IMPORT NULL,SIGNEDWORD,UNSIGNEDWORD,UNSIGNEDLONG,ANYPOINTER;
FROM pSTORAGE   IMPORT ALLOCATE,DEALLOCATE,SIZETYPE;
FROM SYSTEM     IMPORT ADR;
AES_SYSTEM_IMPORT

#if ST
#warning ...using GetCookie, CookieVal
#warning ...using PrefLanguage, Language
#warning you need M2POSIX
FROM DosSystem IMPORT GetCookie,CookieVal,PrefLanguage,Language;
#endif

IMPORT MenuMgr,SetObject,GetObject;

#if ST
#ifdef MM2
IMPORT PrgCtrl;
#elif (defined HM2)
IMPORT TOS;
#elif (defined LPRM2)
#warning you need the module LPRTERMINATION from
#warning LPR_UTL?.ZOO
FROM LPRTERMINATION IMPORT IsAPP;
#elif (defined TDIM2)
#warning you need a special module,
#warning determining accessory execution,
#warning e.g. the modified GEMX by R.S.
#endif
#endif

#if Seimet
CONST F13 = 00D000101H;

CONST F104 = 068020500H;

CONST F130 = 082010500H;
#endif

PROCEDURE Accessory(): BOOLEAN;
BEGIN
#ifdef HM2
  RETURN NOT(TOS.IsApp);
#elif (defined LPRM2)
  RETURN NOT(IsAPP());
#elif (defined MM2)
  RETURN PrgCtrl.Accessory();
#elif (defined TDIM2)
  RETURN TRUE;
#else
  (*
  Normally, FALSE should be returned, because many compilers do not
  support accessories, but here, Accessory() may only be used to avoid
  conflicts, so return TRUE as default value.
  *)
  RETURN TRUE;
#endif
END Accessory;

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

CONST KAOS = 1042H;

#if ST
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
*)

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
      ObSpec.HexCode:= 020001100H;
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
        Height:= WorkOut[46]; (* smallest height *)
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
  IF ((Version() >= 0399H) AND (Version() < KAOS)) (*OR VQWINX()*) THEN
    IntIn.Array[0]:= Type;
    crystal(130,1,5,0);
    Out1:= IntOut[1];
    Out2:= IntOut[2];
    Out3:= IntOut[3];
    Out4:= IntOut[4];
  ELSE
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
            Out1:= 3; (* french *)
        | lSPA:
            Out1:= 4; (* spanish *)
        | lITA:
            Out1:= 5; (* italian *)
        ELSE
          Out1:= 0; (* (american) english *)
        END;
#else
        Out1:= 0;
        IntOut[0]:= 0;
#endif
    ELSE
      IntOut[0]:= 0;
    END;
#if ST
  END;
#endif
END ApplGetInfo;

BEGIN
  MenuMgr.Accessory:= Accessory();
END ApplTool.