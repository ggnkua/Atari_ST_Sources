IMPLEMENTATION MODULE FlyingLook;

(*
Implementation of Flying Look.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)
(*DRIVER*)

FROM AES        IMPORT Global,
                       Key,SpecialKey,KAlt,MouseButton,MBLeft,
                       GRect,GPnt,
                       ParmBlk,BitBlk,BitBlkPtr,
                       ObjectState,Checked,Selected,Normal,Outlined,Crossed,
                       Disabled,
                       ObjectFlags,ObjectFlag,
                       ObjectTypes,
                       Root,Nil,StringRange,String,StringPtr,Small,
                       TreePtr,TreeIndex,ObjectIndex,ObjectPtr,ObjectSpec;
FROM ApplMgr    IMPORT AddApplInit,AddApplExit;
FROM EvntMgr    IMPORT MuKeybd,MuButton,MuM1,MoEnter,MoExit,Event,
                       MEvent,evntevent;
FROM ObjcMgr    IMPORT ObjcChange,DrawDepth,MaxDepth,ObjcOffset,ObjcFind,
                       ObjcEdit,EdStart,EdInit,EdChar,EdEnd,
                       ObjcSysVar,BackgrCol,IndButCol,Ad3DValue;
FROM FormMgr    IMPORT FormError,NoMemory,FormKeybd,FormButton;
FROM GrafMgr    IMPORT GrafHandle,GrafDragBox;
FROM RsrcMgr    IMPORT RTree,RString,RsrcGAddr,AddRsrcLoad,AddRsrcFree;
FROM WindMgr    IMPORT Desk;
FROM VControl   IMPORT VSTLoadFonts,VSTUnloadFonts;
FROM VOutput    IMPORT XY,VRRecFl,VPLine,VGText;
FROM VAttribute IMPORT VSLType,LTSolid,VSLWidth,VSLColor,
                       VSWrMode,MdReplace,MdTrans,MdXOR,VSFColor,
                       VSFInterior,FISPattern,FISSolid,VSFStyle,
                       VSTEffects,TextEffect,Slanted,Underlined,
                       VSTHeight,VSTPoint,VSTFont;
FROM VRaster    IMPORT VRTCpyFm,MFDB;
FROM VQuery     IMPORT VQTAttributes,TextAttributes,VQTExtent,VQTFontInfo;
FROM VScreen    IMPORT VSound;

FROM AESTool    IMPORT NewObject,DisposeObject;
FROM ApplTool   IMPORT ApplGetInfo;
FROM ObjcTool   IMPORT EXCLObjectFlags,INCLObjectFlags,EXCLObjectState,
                       ObjectXYWH,TreeWalk;
FROM FormTool   IMPORT Mask,PopupDo,PopupAttach,PopupGAddr;
FROM GrafTool   IMPORT MouseForm,FlatHand,TextCursor,LastMouse,ArrowMouse,
                       GetMouse;
FROM WindTool   IMPORT BeginUpdate,EndUpdate,
                       BeginMouseControl,EndMouseControl;
FROM RsrcTool   IMPORT TransformBitBlock,GetFreeImagePtr,SpecialChar,
                       NumberOfTrees,TreeArray;
FROM VDITool    IMPORT OpenVirtualWorkstation,CloseVirtualWorkstation,
                       SetClip,GRectToArray,MoveScreen;

FROM PORTAB     IMPORT SIGNEDWORD,UNSIGNEDWORD,NULL;
FROM INTRINSIC  IMPORT PTR,VOID;
CAST_IMPORT

IMPORT AES,ObjcMgr,FormMgr,GetObject,SetObject,FormTool,WindGet;

CONST Menu      = 14; (* GTitle  *)
      Separator = 15; (* GString *)
      Checker   = 16; (* GString *)

      Mover     = 17; (* GIBox   *)
      Button    = 18; (* GButton or GText/GFText/GBoxText/GFBoxText *)
      Title     = 19; (* GString *)
      Grouper   = 20; (* GButton or GText/GFText/GBoxText/GFBoxText *)
      Helper    = 21;
      Popup     = 22;

      Listbox   = 25; (* listbox flag *)


    (*ValidChars   = 122;*)
    (*TheDesk      = 123;*)
      TheMenu      = 124;
      RadioButtons = 125;
      FlyingAlerts = 126;
      ScanCodes    = 127;

    (*Resvd128..Resvd255*)

VAR Handle: UNSIGNEDWORD;

    AlertTree: TreePtr;

    RButNorm: BitBlkPtr; (* normal rounded radio button   *)
    RButSel : BitBlkPtr; (* selected rounded radio button *)

    GrafCharWidth : UNSIGNEDWORD;
    GrafCharHeight: UNSIGNEDWORD; (* see TitleLine() *)
    GrafBoxWidth  : UNSIGNEDWORD;
    GrafBoxHeight : UNSIGNEDWORD;

    AESFontHeightIBM  : UNSIGNEDWORD;
    AESFontHeightSmall: UNSIGNEDWORD;
    AESFontIdIBM      : UNSIGNEDWORD;
    AESFontIdSmall    : UNSIGNEDWORD;
    AESFontTypeIBM    : UNSIGNEDWORD;
    AESFontTypeSmall  : UNSIGNEDWORD;
(*
    AESCharWidthIBM   : UNSIGNEDWORD:
    AESCharWidthSmall : UNSIGNEDWORD:
*)
    AESBackgrColor: UNSIGNEDWORD;
    AESIndButColor: UNSIGNEDWORD;
    AESHoriEnlarge: UNSIGNEDWORD;
    AESVertEnlarge: UNSIGNEDWORD;

    Has3D: UNSIGNEDWORD;

#if PCDOS || (GEMDOS && ABC)
    FirstCall: BOOLEAN;
#endif

PROCEDURE SetStateHiByte(Tree: TreePtr; Index: ObjectIndex; HiByte: StringRange);
BEGIN
#if not UNIX
  Tree^[Index].ObState:= Tree^[Index].ObState + CAST(ObjectState,VAL(UNSIGNEDWORD,HiByte * 256));
#else

#endif
END SetStateHiByte;

PROCEDURE GetStateHiByte(Tree: TreePtr; Index: ObjectIndex): StringRange;
BEGIN
#if not UNIX
  RETURN CAST(UNSIGNEDWORD,Tree^[Index].ObState) DIV 256;
#else

#endif
END GetStateHiByte;

PROCEDURE Draw3DEff(VAR PB: ParmBlk): BOOLEAN; (* VAR for the sake of speed *)
BEGIN
  RETURN ((
           (AES.Version() >= 0340H) AND
           (AES.Version() <  1042H) AND
           (AES.Version() #  0399H)
           ) OR (Has3D = 1)
          ) AND
#if no_set_return
         (Fl3DBak IN CAST(ObjectFlag,GetObject.Flags(PB.PBTree,PB.PBObj)));
#else
         (Fl3DBak IN GetObject.Flags(PB.PBTree,PB.PBObj));
#endif
END Draw3DEff;

PROCEDURE DrawBox(X,Y,W,H: XY);

VAR PXY: ARRAY[0..9] OF XY;

BEGIN
  PXY[0]:= X;
  PXY[1]:= Y;

  PXY[2]:= PXY[0];
  PXY[3]:= Y + H - 1;

  PXY[4]:= X + W - 1;
  PXY[5]:= PXY[3];

  PXY[6]:= PXY[4];
  PXY[7]:= PXY[1];

  PXY[8]:= PXY[0];
  PXY[9]:= PXY[1];

  VPLine(Handle,5,PXY);
END DrawBox;

PROCEDURE ShortCutText(VAR PB: ParmBlk); (* VAR for the sake of speed *)

VAR Height     : UNSIGNEDWORD;
    CharWidth  : UNSIGNEDWORD;
    CharHeight : UNSIGNEDWORD;
    BoxWidth   : UNSIGNEDWORD;
    BoxHeight  : UNSIGNEDWORD;
    Offset     : SIGNEDWORD;
    CurrAttr   : TextAttributes;
    ShortCutPos: StringRange;
    Str        : String;
    i          : StringRange;
    PXY        : ARRAY[0..7] OF XY;
    minADE     : UNSIGNEDWORD;
    maxADE     : UNSIGNEDWORD;
    Distances  : ARRAY[0..4] OF UNSIGNEDWORD;
    MaxWidth   : UNSIGNEDWORD;
    Effects    : ARRAY[0..2] OF UNSIGNEDWORD;
    BoxSpec    : ObjectSpec;
    Text       : StringPtr;

BEGIN
  WITH PB DO
    CASE VAL(AES.ObjectTypes,GetObject.Extnd(PBTree,PBObj)) OF
      GText,GBoxText,GFText,GFBoxText:
#if no_set_return
        IF AES.Indirect IN CAST(ObjectFlag,GetObject.Flags(PBTree,PBObj)) THEN
#else
        IF AES.Indirect IN GetObject.Flags(PBTree,PBObj) THEN
#endif
          BoxSpec.TEdInfo:= PBTree^[PBObj].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm;
        ELSE
          BoxSpec.TEdInfo:= PBParm^.Parm;
        END;

        Text:= BoxSpec.TEdInfo^.TEPText;

        IF BoxSpec.TEdInfo^.TEFont = Small THEN
          VSTFont(Handle,AESFontIdSmall);
          Height:= VSTHeight(Handle,AESFontHeightSmall,CharWidth,CharHeight,BoxWidth,BoxHeight);
        ELSE (* IBM *)
          IF BoxSpec.TEdInfo^.TEFontId # 0 THEN
            VSTFont(Handle,BoxSpec.TEdInfo^.TEFontId);
          ELSE
            VSTFont(Handle,AESFontIdIBM);
          END;
          Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
          CharWidth:= GrafCharWidth; (* take the unproportional width *)
        END;
    | GButton,GString,GTitle:
#if no_set_return
        IF AES.Indirect IN CAST(ObjectFlag,GetObject.Flags(PBTree,PBObj)) THEN
#else
        IF AES.Indirect IN GetObject.Flags(PBTree,PBObj) THEN
#endif
          BoxSpec.String:= PBTree^[PBObj].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm;
        ELSE
          BoxSpec.String:= PBParm^.Parm;
        END;
        Text:= BoxSpec.String;
        VSTFont(Handle,AESFontIdIBM);
        Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
    ELSE
      ;
    END;

    VQTExtent(Handle,Text^,PXY);

    IF Crossed IN GetObject.State(PBTree,PBObj) THEN
      IF GrafBoxWidth >= 2 * GrafBoxHeight THEN
        Offset:= 2 * PBH + INT(CharWidth); (* ATARI medium ST res. *)
      ELSE
        Offset:= PBH + INT(CharWidth);
      END;
    ELSIF RButton IN GetObject.Flags(PBTree,PBObj) THEN
      IF GrafBoxWidth >= 2 * GrafBoxHeight THEN (* ATARI medium ST res. *)
        Offset:= INT(2 * RButNorm^.BIHL + CharWidth);
      ELSE
        Offset:= INT(RButNorm^.BIHL + CharWidth);
      END;
    ELSE (* MenuTitle, ShortCutButton *)
      Offset:= (PBW - INT(PXY[2])) DIV 2; (* center *)
    END;

    VQTAttributes(Handle,CurrAttr);
    VQTFontInfo(Handle,minADE,maxADE,Distances,MaxWidth,Effects);

    VSWrMode(Handle,MdTrans); (* for 3D-Look *)

    (*
      (PBH - INT(CurrAttr.CellHeight)) DIV 2 centers the text within PBH,
      Distances[4] is the distance between the upper edge of the cell
      and the base line
    *)

    VGText(Handle,
           PBX + Offset,
           PBY + (PBH - INT(CurrAttr.CellHeight)) DIV 2 + INT(Distances[4]),
           Text^);

    ShortCutPos:= GetStateHiByte(PBTree,PBObj);

    IF ShortCutPos > 0 THEN
      DEC(ShortCutPos);
      i:= 0;
      WHILE ShortCutPos > i DO
        Str[i]:= Text^[i];
        INC(i);
      END;
      Str[i]:= 0C;

      VQTExtent(Handle,Str,PXY); (* length of left string now in PXY[2] *)

      (* care for underlined SMALL font *)

      CASE VAL(AES.ObjectTypes,GetObject.Extnd(PBTree,PBObj)) OF
        GText,GBoxText,GFText,GFBoxText:
          IF BoxSpec.TEdInfo^.TEFont = Small THEN
            PXY[0]:= PBX + Offset + INT(PXY[2]);
            PXY[1]:= PBY +
                    (PBH - INT(CurrAttr.CellHeight)) DIV 2 + INT(Distances[4]) + 2;
            PXY[2]:= INT(PXY[0]) + INT(CurrAttr.CellWidth) - 1;
            PXY[3]:= PXY[1];
            VPLine(Handle,2,PXY);
            RETURN;
          END;
      ELSE
        ;
      END;

      Str[0]:= Text^[ShortCutPos];
      Str[1]:= 0C;

      VSTEffects(Handle,TextEffect{Underlined});
      VGText(Handle,
             PBX + Offset + INT(PXY[2]),
             PBY + (PBH - INT(CurrAttr.CellHeight)) DIV 2 + INT(Distances[4]),
             Str);
      VSTEffects(Handle,TextEffect{});
    END;
  END;
END ShortCutText;

(***************************************************************************)

PROCEDURE MovingCorner(VAR PB: ParmBlk): ObjectState;

CONST Margin = 3; (* documented by Tim Oren *)

VAR Info: GetObject.ColorInfo;
    Rect: POINTER TO GRect;
    PXY : ARRAY[0..5] OF XY;

BEGIN
  WITH PB DO

    (* make the corner quadratic here if you like *)

    Rect:= PTR(PBXC);
    SetClip(Handle,Rect^);

    GetObject.Color(PBTree,Root,Info);

    VSLColor(Handle,ORD(Info.InsideColor));
    DrawBox(PBX - 1,PBY - 2,PBW + 3,PBH + 3); (* draw white box *)

    VSLColor(Handle,ORD(Info.FrameColor)); (* black in b/w mode *)
    DrawBox(PBX - 2,PBY - 3,PBW + 5,PBH + 5); (* draw outlined *)
    DrawBox(PBX + 1,PBY,PBW - 1,PBH - 1);

    PXY[0]:= PBX - Margin + 1;
    PXY[1]:= PBY - Margin + 1;
    PXY[2]:= PBX + PBW + Margin - 1;
    PXY[3]:= PBY + PBH + Margin - 1;
    VPLine(Handle,2,PXY);

    RETURN Normal;
  END;
END MovingCorner;

PROCEDURE TitleLine(VAR PB: ParmBlk): ObjectState;

VAR Rect      : POINTER TO GRect;
    PXY       : ARRAY[0..7] OF XY;
    Extent    : UNSIGNEDWORD;
    BoxSpec   : ObjectSpec;
    Text      : StringPtr;
    Height    : UNSIGNEDWORD;
    CharWidth : UNSIGNEDWORD;
    CharHeight: UNSIGNEDWORD;
    BoxWidth  : UNSIGNEDWORD;
    BoxHeight : UNSIGNEDWORD;
    minADE    : UNSIGNEDWORD;
    maxADE    : UNSIGNEDWORD;
    Distances : ARRAY[0..4] OF UNSIGNEDWORD;
    MaxWidth  : UNSIGNEDWORD;
    Effects   : ARRAY[0..2] OF UNSIGNEDWORD;

BEGIN
  WITH PB DO
    CASE VAL(AES.ObjectTypes,GetObject.Extnd(PBTree,PBObj)) OF
      GText,GBoxText,GFText,GFBoxText:
        BoxSpec.TEdInfo:= PBParm^.Parm;
        Text:= BoxSpec.TEdInfo^.TEPText;

        IF BoxSpec.TEdInfo^.TEFont = Small THEN
          VSTFont(Handle,AESFontIdSmall);
          Height:= VSTHeight(Handle,AESFontHeightSmall,CharWidth,CharHeight,BoxWidth,BoxHeight);
        ELSE
          IF BoxSpec.TEdInfo^.TEFontId # 0 THEN
            VSTFont(Handle,BoxSpec.TEdInfo^.TEFontId);
          ELSE
            VSTFont(Handle,AESFontIdIBM);
          END;
          Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
        END;
    | GButton,GString:
        BoxSpec.String:= PBParm^.Parm;
        Text:= BoxSpec.String;
        VSTFont(Handle,AESFontIdIBM);
        Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
    ELSE
      ;
    END;

    VQTExtent(Handle,Text^,PXY);
    Extent:= PXY[2];

    Rect:= PTR(PBXC);
    SetClip(Handle,Rect^);

    VSWrMode(Handle,MdTrans); (* for 3D-Look *)

    VQTFontInfo(Handle,minADE,maxADE,Distances,MaxWidth,Effects);

    IF GrafCharHeight >= 16 THEN (* arbitrary limit *)
      VSLColor(Handle,ORD(AES.Black)); (* GStrings are always black *)
      PXY[0]:= PBX;
      PXY[1]:= PBY + INT(Distances[4] + Distances[0]) + 1;
      PXY[2]:= PBX + INT(Extent);
      PXY[3]:= PXY[1];
      VPLine(Handle,2,PXY);

      VGText(Handle,PBX,PBY + INT(Distances[4]),Text^);
    ELSE
      VSTEffects(Handle,TextEffect{Underlined});
      VGText(Handle,PBX,PBY + INT(Distances[4]),Text^);
      VSTEffects(Handle,TextEffect{});
    END;

    RETURN Normal;
  END;
END TitleLine;

PROCEDURE GroupBox(VAR PB: ParmBlk): ObjectState;

CONST Margin = 3; (* documented by Tim Oren *)

VAR Rect      : POINTER TO GRect;
    BoxSpec   : ObjectSpec;
    Text      : StringPtr;
    Height    : UNSIGNEDWORD;
    PXY       : ARRAY[0..7] OF XY;
    CharWidth : UNSIGNEDWORD;
    CharHeight: UNSIGNEDWORD;
    BoxWidth  : UNSIGNEDWORD;
    BoxHeight : UNSIGNEDWORD;
    minADE    : UNSIGNEDWORD;
    maxADE    : UNSIGNEDWORD;
    Distances : ARRAY[0..4] OF UNSIGNEDWORD;
    MaxWidth  : UNSIGNEDWORD;
    Effects   : ARRAY[0..2] OF UNSIGNEDWORD;

BEGIN
  WITH PB DO
    CASE VAL(AES.ObjectTypes,GetObject.Extnd(PBTree,PBObj)) OF
      GText,GBoxText,GFText,GFBoxText:
#if no_set_return
        IF AES.Indirect IN CAST(ObjectFlag,GetObject.Flags(PBTree,PBObj)) THEN
#else
        IF AES.Indirect IN GetObject.Flags(PBTree,PBObj) THEN
#endif
          BoxSpec.TEdInfo:= PBTree^[PBObj].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm;
        ELSE
          BoxSpec.TEdInfo:= PBParm^.Parm;
        END;

        Text:= BoxSpec.TEdInfo^.TEPText;
        IF BoxSpec.TEdInfo^.TEFont = Small THEN
          VSTFont(Handle,AESFontIdSmall);
          Height:= VSTHeight(Handle,AESFontHeightSmall,CharWidth,CharHeight,BoxWidth,BoxHeight);
        ELSE
          IF BoxSpec.TEdInfo^.TEFontId # 0 THEN
            VSTFont(Handle,BoxSpec.TEdInfo^.TEFontId);
          ELSE
            VSTFont(Handle,AESFontIdIBM);
          END;
          Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
        END;
    | GButton,GString:
#if no_set_return
        IF AES.Indirect IN CAST(ObjectFlag,GetObject.Flags(PBTree,PBObj)) THEN
#else
        IF AES.Indirect IN GetObject.Flags(PBTree,PBObj) THEN
#endif
          BoxSpec.String:= PBTree^[PBObj].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm;
        ELSE
          BoxSpec.String:= PBParm^.Parm;
        END;
        Text:= BoxSpec.String;
        VSTFont(Handle,AESFontIdIBM);
        Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
    ELSE
      ;
    END;

    Rect:= PTR(PBXC);
    SetClip(Handle,Rect^);

    VSWrMode(Handle,MdReplace);
    VSLColor(Handle,ORD(AES.Black));
    DrawBox(PBX,PBY,PBW,PBH);

    IF Draw3DEff(PB) THEN
      IF AESBackgrColor # ORD(AES.White) THEN
        VSLColor(Handle,ORD(AES.White));
        DrawBox(PBX + 1, PBY + 1,PBW,PBH);
      END;

      (* clear the room for the following text output *)
      VSLColor(Handle,AESBackgrColor);
      VQTExtent(Handle,Text^,PXY); (* PXY[2] contains text width *)

      PXY[0]:= PBX + INT(GrafCharWidth) + 1;
      PXY[1]:= PBY;
      PXY[2]:= PXY[0] + PXY[2] - 1;
      PXY[3]:= PXY[1];
      VPLine(Handle,2,PXY);
      INC(PXY[0]);
      INC(PXY[1]);
      INC(PXY[2]);
      INC(PXY[3]);
      VPLine(Handle,2,PXY);

      VSWrMode(Handle,MdTrans);
    ELSE
      VSWrMode(Handle,MdReplace);
    END;

    VQTFontInfo(Handle,minADE,maxADE,Distances,MaxWidth,Effects); (* new height *)
    VGText(Handle,PBX + INT(GrafCharWidth) + 1,
                  PBY + INT(Distances[3]) DIV 2,
                  Text^);

    RETURN Normal;
  END;
END GroupBox;

PROCEDURE CheckableItem(VAR PB: ParmBlk): ObjectState;

VAR Rect      : POINTER TO GRect;
    Item      : StringPtr;
    PXY       : ARRAY[0..3] OF XY;
    Height    : UNSIGNEDWORD;
    CharWidth : UNSIGNEDWORD;
    CharHeight: UNSIGNEDWORD;
    BoxWidth  : UNSIGNEDWORD;
    BoxHeight : UNSIGNEDWORD;
    minADE    : UNSIGNEDWORD;
    maxADE    : UNSIGNEDWORD;
    Distances : ARRAY[0..4] OF UNSIGNEDWORD;
    MaxWidth  : UNSIGNEDWORD;
    Effects   : ARRAY[0..2] OF UNSIGNEDWORD;

BEGIN
  WITH PB DO
    Rect:= PTR(PBX); (* do not use PBXC here *)
    SetClip(Handle,Rect^);

    VSTFont(Handle,AESFontIdIBM);
    Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);

    VQTFontInfo(Handle,minADE,maxADE,Distances,MaxWidth,Effects);

    Item:= CAST(StringPtr,PBParm^.Parm);

    IF NOT (Selected IN (PBCurrState / PBPrevState)) THEN (* ObjcDraw() call *)
      VSTEffects(Handle,TextEffect{Slanted});
      VGText(Handle,PBX,PBY + INT(Distances[4]),Item^);
      VSTEffects(Handle,TextEffect{});
    ELSE                                                  (* ObjcChange() call *)
      VSFColor(Handle,ORD(AES.Black));
      VSFInterior(Handle,FISSolid);
      Rect:= PTR(PBX);
      GRectToArray(Rect^,PXY);
      VSWrMode(Handle,MdXOR);
      VRRecFl(Handle,PXY);
      VSWrMode(Handle,MdReplace);
    END;

    RETURN PBCurrState - ObjectState{Selected};
  END;
END CheckableItem;

PROCEDURE MenuTitle(VAR PB: ParmBlk): ObjectState;

VAR Rect: POINTER TO GRect;
    Fill: GRect;
    PXY : ARRAY[0..3] OF XY;

(*
  PROCEDURE Fill(Mode: WritingModes);
  BEGIN
    WITH Fill DO
      GX:= PBX + 1;
      GY:= PBY + 1;
      GW:= PBW - 2;
      GH:= PBH - 2;
    END;
    GRectToArray(Fill,PXY);
    VSWrMode(Handle,Mode);
    VRRecFl(Handle,PXY);
    VSWrMode(Handle,MdReplace);
  END;
*)

BEGIN
  WITH PB DO
    Rect:= PTR(PBX); (* do not use PBXC here *)
    SetClip(Handle,Rect^);

(* did not always work...

    IF NOT (Selected IN (PBCurrState / PBPrevState)) THEN (* ObjcDraw() call *)
      ShortCutText(PB);
    ELSE                                                  (* ObjcChange() call *)
      VSFColor(Handle,ORD(AES.Black));
      VSFInterior(Handle,FISSolid);
      WITH Fill DO
        GX:= PBX + 1;
        GY:= PBY + 1;
        GW:= PBW - 2;
        GH:= PBH - 2;
      END;
      GRectToArray(Fill,PXY);
      VSWrMode(Handle,MdXOR);
      VRRecFl(Handle,PXY);
      VSWrMode(Handle,MdReplace);
    END;

    RETURN PBCurrState - ObjectState{Selected};
*)
    VSFColor(Handle,ORD(AES.White));
    VSFInterior(Handle,FISSolid);

    WITH Fill DO
      GX:= PBX + 1;
      GY:= PBY + 1;
      GW:= PBW - 2;
      GH:= PBH - 2;
    END;
    GRectToArray(Fill,PXY);
  (*VSWrMode(Handle,MdReplace);*)
    VRRecFl(Handle,PXY);
  (*VSWrMode(Handle,MdReplace);*)

    ShortCutText(PB);

    IF Disabled IN PBCurrState THEN
      VSFColor(Handle,ORD(AES.Black));
      VSFInterior(Handle,FISPattern);
      VSFStyle(Handle,4);

    (*WITH Fill DO
        GX:= PBX + 1;
        GY:= PBY + 1;
        GW:= PBW - 2;
        GH:= PBH - 2;
      END;
      GRectToArray(Fill,PXY);*)
      VSWrMode(Handle,MdXOR);
      VRRecFl(Handle,PXY);
      VSWrMode(Handle,MdReplace);

      ShortCutText(PB);
      VSWrMode(Handle,MdXOR);
      VRRecFl(Handle,PXY);
      VSWrMode(Handle,MdReplace);
    END;

    IF Selected IN PBCurrState THEN
      VSFColor(Handle,ORD(AES.Black));
      VSFInterior(Handle,FISSolid);

    (*WITH Fill DO
        GX:= PBX + 1;
        GY:= PBY + 1;
        GW:= PBW - 2;
        GH:= PBH - 2;
      END;
      GRectToArray(Fill,PXY);*)
      VSWrMode(Handle,MdXOR);
      VRRecFl(Handle,PXY);
      VSWrMode(Handle,MdReplace);

    END;

    RETURN PBCurrState - ObjectState{Selected,Disabled};
  END;
END MenuTitle;

PROCEDURE ItemSeparator(VAR PB: ParmBlk): ObjectState;

VAR Rect: POINTER TO GRect;
    PXY : ARRAY[0..3] OF XY;

BEGIN
  WITH PB DO
    Rect:= PTR(PBX); (* do not use PBXC here *)
    SetClip(Handle,Rect^);

    VSFColor(Handle,ORD(AES.Black)); (* GStrings are always black *)
    VSFInterior(Handle,FISPattern);
    VSFStyle(Handle,4);
    PXY[0]:= PBX;
    PXY[1]:= PBY + PBH DIV 2;
    PXY[2]:= PBX + PBW - 1;
    PXY[3]:= PXY[1] + 1;
    VRRecFl(Handle,PXY);

    RETURN Normal;
  END;
END ItemSeparator;

PROCEDURE CheckBox(VAR PB: ParmBlk): ObjectState;

VAR Rect : POINTER TO GRect;
    PXY  : ARRAY[0..9] OF XY;
    Width: SIGNEDWORD;

BEGIN
  WITH PB DO
    Rect:= PTR(PBXC);
    SetClip(Handle,Rect^);

    VSLColor(Handle,ORD(AES.Black));
    VSWrMode(Handle,MdTrans);

    IF GrafBoxWidth >= 2 * GrafBoxHeight THEN
      Width:= 2 * PBH; (* ATARI medium ST res. *)
    ELSE
      Width:= PBH;
    END;

    IF NOT (Selected IN (PBCurrState / PBPrevState)) THEN (* ObjcDraw() call *)
      IF Draw3DEff(PB) THEN
        PXY[0]:= PBX;
        PXY[1]:= PBY + PBH - 1;
        PXY[2]:= PBX + Width - 1;
        PXY[3]:= PXY[1];
        PXY[4]:= PXY[2];
        PXY[5]:= PBY;

        IF AESBackgrColor # ORD(AES.White) THEN
          VSLColor(Handle,ORD(AES.White));
        ELSE
          VSLColor(Handle,ORD(AES.Black));
        END;
        VPLine(Handle,3,PXY);

        PXY[0]:= PBX;
        PXY[1]:= PBY + PBH - 2;
        PXY[2]:= PBX;
        PXY[3]:= PBY;
        PXY[4]:= PBX + Width - 2;
        PXY[5]:= PBY;
        VSLColor(Handle,ORD(AES.Black));
        VPLine(Handle,3,PXY);
      ELSE
        PXY[0]:= PBX;
        PXY[1]:= PBY;
        PXY[2]:= PBX + Width - 1;
        PXY[3]:= PBY;
        PXY[4]:= PXY[2];
        PXY[5]:= PBY + PBH - 1;
        PXY[6]:= PBX;
        PXY[7]:= PXY[5];
        PXY[8]:= PBX;
        PXY[9]:= PBY;
        VPLine(Handle,5,PXY);
      END;

      ShortCutText(PB);
    END;

    IF Selected IN PBCurrState THEN (* ObjcChange() call *)
      VSLColor(Handle,ORD(AES.Black));
    ELSE
      IF Draw3DEff(PB) THEN
        VSLColor(Handle,AESBackgrColor);
      ELSE
        VSLColor(Handle,ORD(AES.White));
      END;
    END;

    (* draw a (inner) cross *)

    PXY[0]:= PBX + 1;
    PXY[1]:= PBY + 1;
    PXY[2]:= PBX + Width - 2;
    PXY[3]:= PBY + PBH - 2;
    VPLine(Handle,2,PXY);

    PXY[0]:= PBX + Width - 2;
    PXY[1]:= PBY + 1;
    PXY[2]:= PBX + 1;
    PXY[3]:= PBY + PBH - 2;
    VPLine(Handle,2,PXY);

    RETURN PBCurrState - ObjectState{Selected,Crossed};
  END;
END CheckBox;

PROCEDURE RadioButton(VAR PB: ParmBlk): ObjectState;

CONST BitsPerByte  = 8;
      BytesPerWord = 2;

VAR Rect  : POINTER TO GRect;
    Width : SIGNEDWORD;
    Src   : MFDB;
    Dst   : MFDB;
    PXY   : ARRAY[0..7] OF XY;
    BitImg: BitBlkPtr;

BEGIN
  WITH PB DO
    Rect:= PTR(PBXC);
    SetClip(Handle,Rect^);

    IF GrafBoxWidth >= 2 * GrafBoxHeight THEN (* ATARI medium ST res. *)
      Width:= 2 * RButNorm^.BIHL;
    ELSE
      Width:= RButNorm^.BIHL;
    END;

    IF Selected IN PBCurrState THEN
      BitImg:= RButSel;
    ELSE
      BitImg:= RButNorm;
    END;

    Dst.FDAddr:= NULL; (* destination:= screen *)

    WITH Src DO
      WITH BitImg^ DO
        FDAddr:= BIPData;
        FDW:= BIWB * BitsPerByte;
        FDH:= BIHL;
        FDWdWidth:= BIWB DIV BytesPerWord;
        FDStand:= FALSE;
        FDNPlanes:= 1;
      END;
    END;

    PXY[0]:= 0;
    PXY[1]:= 0;
    PXY[2]:= Src.FDW - 1;
    PXY[3]:= Src.FDH - 1;
    PXY[4]:= PBX;
    PXY[5]:= PBY + (PBH - INT(BitImg^.BIHL)) DIV 2; (* centered *)
    PXY[6]:= PXY[4] + PXY[2];
    PXY[7]:= PXY[5] + PXY[3];
 
    IF Draw3DEff(PB) THEN
      VRTCpyFm(Handle,MdReplace,PXY,Src,Dst,ORD(AES.Black),AESBackgrColor);
    ELSE (* no 3D effect *)
      VRTCpyFm(Handle,MdReplace,PXY,Src,Dst,ORD(AES.Black),ORD(AES.White));
    END;

    (* write text after raster copy *)
    ShortCutText(PB);

    RETURN PBCurrState - ObjectState{Selected};

  END;
END RadioButton;

PROCEDURE ShortCutButton(VAR PB: ParmBlk): ObjectState;

CONST inside = 1;

VAR outside: SIGNEDWORD;
    Rect   : POINTER TO GRect;
    Fill   : GRect;
    From   : GRect;
    To     : GRect;
    PXY    : ARRAY[0..5] OF XY;
    BoxSpec: ObjectSpec;

  PROCEDURE Activator(): BOOLEAN;
  BEGIN
    IF (
        (AES.Version() >= 0340H) AND
        (AES.Version() <  1042H) AND
        (AES.Version() #  0399H)
        ) OR (Has3D = 1) THEN
#if no_set_return
      RETURN CAST(ObjectFlag,GetObject.Flags(PB.PBTree,PB.PBObj)) *
             ObjectFlag{Fl3DBak,Fl3DInd} =
             ObjectFlag{Fl3DBak,Fl3DInd};
#else
      RETURN GetObject.Flags(PB.PBTree,PB.PBObj) *
             ObjectFlag{Fl3DBak,Fl3DInd} =
             ObjectFlag{Fl3DBak,Fl3DInd};
#endif
    END;
    RETURN FALSE;
  END Activator;

BEGIN
  WITH PB DO
    Rect:= PTR(PBXC);
    SetClip(Handle,Rect^);

    VSWrMode(Handle,MdReplace);

    IF NOT (Selected IN (PBCurrState / PBPrevState)) THEN (* ObjcDraw() call  *)
      VSLColor(Handle,ORD(AES.Black));

      outside:= 1; (* get it from BoxSpec.TEdInfo^.TEThickness *)

      CASE VAL(AES.ObjectTypes,GetObject.Extnd(PBTree,PBObj)) OF
        GBoxText,GFBoxText,GButton:
          IF Exit IN GetObject.Flags(PBTree,PBObj) THEN
            DrawBox(PBX -     outside,
                    PBY -     outside,
                    PBW + 2 * outside,
                    PBH + 2 * outside);
            INC(outside);
            DrawBox(PBX -     outside,
                    PBY -     outside,
                    PBW + 2 * outside,
                    PBH + 2 * outside);
          ELSE
            DrawBox(PBX -      outside - INT(AESHoriEnlarge),
                    PBY -      outside - INT(AESVertEnlarge),
                    PBW + 2 * (outside + INT(AESHoriEnlarge)),
                    PBH + 2 * (outside + INT(AESVertEnlarge)));
          END;

          IF Default IN GetObject.Flags(PBTree,PBObj) THEN
            INC(outside);
            DrawBox(PBX -     outside,
                    PBY -     outside,
                    PBW + 2 * outside,
                    PBH + 2 * outside);
          END;
      ELSE
        ;
      END;

(* this will be drawn by the AES

      outside:= 1;

      IF Activator() AND (Exit IN GetObject.Flags(PBTree,PBObj)) THEN
        PXY[0]:=    PBX -      outside + inside;
        PXY[1]:=   (PBY -      outside + inside)
                 + (PBH + 2 * (outside - inside))
                 -  1;

        PXY[2]:= PXY[0];
        PXY[3]:=    PBY -      outside + inside;

        PXY[4]:=   (PBX -      outside + inside)
                 + (PBW + 2 * (outside - inside))
                 - 1;
        PXY[5]:= PXY[3];

        VSLColor(Handle,ORD(AES.White));
        VPLine(Handle,3,PXY);
        INC(PXY[0]);
        PXY[2]:= PXY[4];
        PXY[3]:= PXY[1];
        INC(PXY[5]);
        VSLColor(Handle,ORD(AES.LBlack));
        VPLine(Handle,3,PXY);
      END;
*)

      IF Activator() THEN
        VSWrMode(Handle,MdReplace);
        VSFColor(Handle,AESIndButColor);
        VSFInterior(Handle,FISSolid);
        WITH Fill DO
          GX:= PBX + 1;
          GY:= PBY + 1;
          GW:= PBW - 2;
          GH:= PBH - 2;
        END;
        GRectToArray(Fill,PXY);
        VRRecFl(Handle,PXY);
      END;

      ShortCutText(PB);

    ELSE                                                  (* ObjcChange() call *)
      IF Activator() THEN
        IF (Selected IN PBPrevState) THEN
          outside:= 1;

          PXY[0]:=    PBX -      outside - INT(AESHoriEnlarge) + inside;
          PXY[1]:=   (PBY -      outside - INT(AESVertEnlarge) + inside)
                   + (PBH + 2 * (outside + INT(AESVertEnlarge) - inside))
                   -  1;

          PXY[2]:= PXY[0];
          PXY[3]:=    PBY -      outside - INT(AESVertEnlarge) + inside;

          PXY[4]:=   (PBX -      outside - INT(AESHoriEnlarge) + inside)
                   + (PBW + 2 * (outside + INT(AESHoriEnlarge) - inside))
                   - 1;
          PXY[5]:= PXY[3];

          VSWrMode(Handle,MdReplace);

          VSLColor(Handle,ORD(AES.White));
          VPLine(Handle,3,PXY);

          INC(PXY[0]);
          PXY[2]:= PXY[4];
          PXY[3]:= PXY[1];
          INC(PXY[5]);
          VSLColor(Handle,ORD(AES.LBlack));
          VPLine(Handle,3,PXY);

          VSFColor(Handle,AESIndButColor);
          VSFInterior(Handle,FISSolid);
          WITH Fill DO
            GX:= PBX (* + 1*);
            GY:= PBY (* + 1*);
            GW:= PBW (* - 2*);
            GH:= PBH (* - 2*);
          END;
          GRectToArray(Fill,PXY);
          VRRecFl(Handle,PXY);

          ShortCutText(PB);
        ELSE (* draw selected *)
          WITH From DO
            GX:= PBX + 1;
            GY:= PBY + 1;
            GW:= PBW - 2;
            GH:= PBH - 2;
          END;
          WITH To DO
            GX:= PBX + 2;
            GY:= PBY + 2;
            GW:= PBW - 5;
            GH:= PBH - 5;
          END;

          MoveScreen(Handle,From,To);

          outside:= 1;

          PXY[0]:=    PBX -      outside - INT(AESHoriEnlarge) + inside;
          PXY[1]:=   (PBY -      outside - INT(AESVertEnlarge) + inside)
                   + (PBH + 2 * (outside + INT(AESVertEnlarge) - inside))
                   -  1;

          PXY[2]:= PXY[0];
          PXY[3]:=    PBY -      outside - INT(AESVertEnlarge) + inside;

          PXY[4]:=   (PBX -      outside - INT(AESHoriEnlarge) + inside)
                   + (PBW + 2 * (outside + INT(AESHoriEnlarge) - inside))
                   - 1;
          PXY[5]:= PXY[3];

          VSLColor(Handle,ORD(AES.Black)); (* black here *)
          VPLine(Handle,3,PXY);

          PXY[2]:= PXY[4];
          PXY[3]:= PXY[1];

          VSLColor(Handle,ORD(AES.White));
          VSWrMode(Handle,MdReplace);
          VPLine(Handle,3,PXY);
        END;
      ELSE (* NOT Indicator(): draw invert rectangle *)
        VSFColor(Handle,ORD(AES.Black));
        VSFInterior(Handle,FISSolid);
        WITH Fill DO
          GX:= PBX;
          GY:= PBY;
          GW:= PBW;
          GH:= PBH;
        END;
        GRectToArray(Fill,PXY);
        VSWrMode(Handle,MdXOR);
        VRRecFl(Handle,PXY);
        VSWrMode(Handle,MdReplace);
      END;
    END;

    RETURN PBCurrState - ObjectState{Selected};
  END;
END ShortCutButton;

(***************************************************************************)

  PROCEDURE install(Tree: TreePtr; Index: ObjectIndex): BOOLEAN;

    PROCEDURE MakeShortCut(Tree: TreePtr; Index: ObjectIndex);

    VAR ButtonStr  : StringPtr;
        ShortCutStr: String;
        i,j        : StringRange;

    BEGIN
      ButtonStr:= GetObject.StringPtr(Tree,Index);

      IF ButtonStr # NIL THEN
        i:= 0; j:= 0;
        WHILE ButtonStr^[i] # 0C DO
          IF ButtonStr^[i] = "[" THEN
            INC(i); (* first inc to make the hi byte > 0 *)
            SetStateHiByte(Tree,Index,i);

            (* some space for the underlined character *)
            IF GetObject.Extnd(Tree,Index) = Button THEN
              IF NOT((Crossed IN GetObject.State(Tree,Index)) OR
                     (RButton IN GetObject.Flags(Tree,Index))
                    ) THEN
                DEC(Tree^[Index].ObY,1);
                INC(Tree^[Index].ObHeight,2);
              END;
            END;
          ELSE
            ShortCutStr[j]:= ButtonStr^[i]; (* copy string *)
            INC(i); INC(j);
          END;
        END;

        ShortCutStr[j]:= 0C;
        SetObject.String(Tree,Index,ShortCutStr); (* replace object string *)
      END;
    END MakeShortCut;

  BEGIN (* install *)
    (*
    SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));
    saves the old object type - the former extended object type will be
    lost
    *)
    CASE GetObject.Extnd(Tree,Index) OF
      Separator:
        (*
        assumption: the first separator (in the desk menu) has an
        extended object type.
        *)
#if PCDOS
        IF FirstCall THEN
#elif (GEMDOS && ABC)
#warning ...taking care of ABC-GEM
        IF FirstCall AND (AES.Version() = 0220H) THEN
#endif
#if PCDOS || (GEMDOS && ABC)
          FirstCall:= FALSE;
          RETURN TRUE; (* continue *)
        ELSE
#endif
          SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

          RETURN NewObject(Tree,Index,ItemSeparator,GetObject.Spec(Tree,Index));
#if PCDOS || (GEMDOS && ABC)
        END;
#endif
    | Button:
        MakeShortCut(Tree,Index);
        SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

        IF RButton IN GetObject.Flags(Tree,Index) THEN
          (* todo: take care of distances here *)
          RETURN NewObject(Tree,Index,RadioButton,GetObject.Spec(Tree,Index));
        ELSIF Crossed IN GetObject.State(Tree,Index) THEN
          (* todo: take care of distances here *)
          RETURN NewObject(Tree,Index,CheckBox,GetObject.Spec(Tree,Index));
        ELSE
          RETURN NewObject(Tree,Index,ShortCutButton,GetObject.Spec(Tree,Index));
        END;
    | Mover:
#if (GEMDOS && ABC)
#warning ...taking care of ABC-GEM
        SetObject.State(Tree,Root,ObjectState{Outlined}); (* ...AùBùC-GEM *)
#endif
        SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

        RETURN NewObject(Tree,Index,MovingCorner,GetObject.Spec(Tree,Index));
    | Checker:
        SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

        RETURN NewObject(Tree,Index,CheckableItem,GetObject.Spec(Tree,Index));
    | Menu:
        MakeShortCut(Tree,Index);
        SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

        RETURN NewObject(Tree,Index,MenuTitle,GetObject.Spec(Tree,Index));
    | Title:
        SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

        RETURN NewObject(Tree,Index,TitleLine,GetObject.Spec(Tree,Index));
    | Grouper:
        SetObject.Extnd(Tree,Index,ORD(GetObject.Type(Tree,Index)));

        RETURN NewObject(Tree,Index,GroupBox,GetObject.Spec(Tree,Index));
    ELSE
      RETURN TRUE; (* continue *)
    END;

    RETURN TRUE; (* continue *)

  END install;

PROCEDURE Install(Tree: TreePtr);
BEGIN
  TreeWalk(Tree,Root,Nil,install);
END Install;

  PROCEDURE deinstall(Tree: TreePtr; Index: ObjectIndex): BOOLEAN;
  BEGIN
    IF GetObject.Type(Tree,Index) = GUserDef THEN
      DisposeObject(Tree,Index,VAL(ObjectTypes,GetObject.Extnd(Tree,Index)));
    END;

    RETURN TRUE; (* continue *)

  END deinstall;

PROCEDURE Deinstall(Tree: TreePtr);
BEGIN
  TreeWalk(Tree,Root,Nil,deinstall);
END Deinstall;

(***************************************************************************)

PROCEDURE ApplInit(): SIGNEDWORD;

CONST MaxMemory = 32767; (* 512 kB (32768 * 16) *)
      FreeSpace = 4096;  (*  64 kB ( 4096 * 16) *)

VAR Fonts: UNSIGNEDWORD;
    Dummy: UNSIGNEDWORD;

BEGIN
  IF OpenVirtualWorkstation(Handle) THEN
    VOID(GrafHandle(GrafCharWidth,GrafCharHeight,GrafBoxWidth,GrafBoxHeight));

    ApplGetInfo(0,AESFontHeightIBM,AESFontIdIBM,AESFontTypeIBM,Dummy);
(*
    VSTFont(Handle,AESFontIdIBM);
    VOID(VSTHeight(Handle,AESFontHeightIBM,AESCharWidthIBM,Dummy,Dummy,Dummy));
*)
    ApplGetInfo(1,AESFontHeightSmall,AESFontIdSmall,AESFontTypeSmall,Dummy);
(*
    VSTFont(Handle,AESFontIdSmall);
    VOID(VSTHeight(Handle,AESFontHeightSmall,AESCharWidthSmall,Dummy,Dummy,Dummy));
*)
    ApplGetInfo(13,Has3D,Dummy,Dummy,Dummy);

    Fonts:= VSTLoadFonts(Handle,0,MaxMemory,FreeSpace);

    RETURN Global.ApId;
  ELSE
    FormError(NoMemory);
    RETURN -1;
  END;
END ApplInit;

PROCEDURE ApplExit;
BEGIN
  VSTUnloadFonts(Handle,0);        (* assumption: call ApplExit only if *)
  CloseVirtualWorkstation(Handle); (* ApplInit() was successfull        *)
END ApplExit;

PROCEDURE ObjcDraw(    PTree: TreePtr;
                       Start: ObjectIndex;
                       Depth: DrawDepth;
                   VAR Clip : GRect);

VAR Dummy: UNSIGNEDWORD;

BEGIN
  ObjcSysVar(FALSE,BackgrCol,0,0,AESBackgrColor,Dummy);
  ObjcSysVar(FALSE,IndButCol,0,0,AESIndButColor,Dummy);
  ObjcSysVar(FALSE,Ad3DValue,0,0,AESHoriEnlarge,AESVertEnlarge);
  ObjcMgr.objcdraw(PTree,Start,Depth,Clip);
END ObjcDraw;

(* new objc_edit() function ************************************************)

(*
PROCEDURE ObjcEdit(    PTree : TreePtr;
                       Index : ObjectIndex;
                       EdChar: Key;
                   VAR EdPos : StringRange;
                       EdKind: EditModes);

CONST ESCAPE     =
      DEL        =
      BACKSPACE  =
      RIGHT      =
      LEFT       =
      SHIFTRIGHT =
      SHIFTLEFT  =

(* should be found in the resource, s. AES 2.2 *)

  PROCEDURE IsValid9(): BOOLEAN; (* 9 *)

  PROCEDURE IsValidA(): BOOLEAN; (* A *)

  PROCEDURE IsValida(): BOOLEAN; (* a *)

  PROCEDURE IsValidN(): BOOLEAN; (* N *)

  PROCEDURE IsValidn(): BOOLEAN; (* n *)

  PROCEDURE IsValidP(): BOOLEAN; (* P *)

  PROCEDURE IsValidp(): BOOLEAN; (* p *)

  PROCEDURE IsValidF(): BOOLEAN; (* F *)

  PROCEDURE IsValidf(): BOOLEAN; (* f *)

BEGIN

END ObjcEdit;
*)

(* new form_do() function **************************************************)

  VAR ShortCutChar: CHAR;
      ShortCutOb  : ObjectIndex;

  PROCEDURE searchshortcut(Tree: TreePtr; Index: ObjectIndex): BOOLEAN;

  VAR Str        : StringPtr;
      Spec       : ObjectSpec;
      ShortCutPos: StringRange;
      Char       : CHAR;

  BEGIN
    CASE VAL(AES.ObjectTypes,GetObject.Extnd(Tree,Index)) OF
        GButton:
          IF GetObject.Type(Tree,Index) = GUserDef THEN
#if not UNIX
            IF Indirect IN Tree^[Index].ObFlags THEN
              Str:= Tree^[Index].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm;
            ELSE
              Str:= Tree^[Index].ObSpec.UserBlk^.UBParm^.Parm;
            END;
#else

#endif
          END;
    |  GText,GBoxText,GFText,GFBoxText:
          IF GetObject.Type(Tree,Index) = GUserDef THEN
#if not UNIX
            IF Indirect IN Tree^[Index].ObFlags THEN
              Spec.Address:= Tree^[Index].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm;
            ELSE
              Spec.Address:= Tree^[Index].ObSpec.UserBlk^.UBParm^.Parm;
            END;
#else

#endif
            Str:= Spec.TEdInfo^.TEPText;
          END;
    ELSE
        RETURN TRUE; (* continue *)
    END;

    ShortCutPos:= GetStateHiByte(Tree,Index);
    IF ShortCutPos > 0 THEN
      Char:= Str^[ShortCutPos - 1];
      IF CAP(Char) = CAP(ShortCutChar) THEN
        ShortCutOb:= Index;
        RETURN FALSE; (* break *)
      END;
    END;

    RETURN TRUE; (* continue *)
  END searchshortcut;

PROCEDURE formdo(Tree : TreePtr;
                 Start: ObjectIndex): SIGNEDWORD;

CONST LastEdit = Flag15; (* flag for last edit position *)

TYPE Directions = (FmDDeflt,FmDForward,FmDBackward);

VAR Index   : StringRange;
    EditOb  : ObjectPtr;
    NextOb  : ObjectPtr;
    CursorOb: ObjectPtr;
    Cont    : BOOLEAN;
    EventRec: MEvent;
    MyEvent : Event;

  PROCEDURE FindObject(Tree  : TreePtr;
                       Start : ObjectPtr;
                       Flag  : ObjectFlags;
                       Direct: Directions): ObjectIndex;

  VAR Index : ObjectPtr;
      ObFlag: ObjectFlag;
      i     : ObjectPtr;

  BEGIN
    Index:= Root;
    i:= 1;

    CASE Direct OF
      FmDBackward:
        i:= Nil;
        Index:= Start + i;
    | FmDForward:
        Index:= Start + i;
    | FmDDeflt:
        Flag:= Default;
    END;

    WHILE Index >= Root DO
      ObFlag:= GetObject.Flags(Tree,Index);
      IF Flag IN ObFlag THEN
        RETURN Index;
      END;
      IF LastOb IN ObFlag THEN
        Index:= Nil;
      ELSE
        Index:= Index + i;
      END;
    END;
    RETURN Start;
  END FindObject;

  PROCEDURE FirstObject(Tree : TreePtr;
                        Start: ObjectIndex): ObjectIndex;

  VAR Last: ObjectIndex;

  BEGIN
    IF Start = Root THEN (* first look for last edit position *)
      Last:= FindObject(Tree,Root,LastEdit,FmDForward);
      IF Last = Root THEN
        RETURN FindObject(Tree,Root,Editable,FmDForward);
      ELSE
        RETURN Last;
      END;
    ELSE
      RETURN Start;
    END;
  END FirstObject;

BEGIN
  BeginMouseControl;

  NextOb:= FirstObject(Tree,Start);
  EditOb:= Root;

  WITH EventRec DO
    EFlags:= Event{MuKeybd,MuButton,MuM1};
    EBClk:= 2;
    EBMsk:= MouseButton{MBLeft};
    EBSt:= MouseButton{MBLeft};

    GetMouse(EventRec.EMXY);
    EM1Flags:= MoExit;
    EM1.GX:= EMXY.GX;
    EM1.GY:= EMXY.GY;
    EM1.GW:= 1;
    EM1.GH:= 1;

    Cont:= TRUE;

    WHILE Cont DO

      IF (NextOb # Root) AND (EditOb # NextOb) THEN
        EditOb:= NextOb;
        NextOb:= Root;
        ObjcEdit(Tree,EditOb,EKR,Index,EdInit);
        EXCLObjectFlags(Tree,EditOb,LastEdit);
      END;

      MyEvent:= evntevent(EventRec);

      IF MuM1 IN MyEvent THEN
        CursorOb:= ObjcFind(Tree,Root,2,EMXY);
        EM1.GX:= EMXY.GX;
        EM1.GY:= EMXY.GY;

        IF CursorOb # Nil THEN
          IF (Editable IN GetObject.Flags(Tree,CursorOb)) THEN
            MouseForm(TextCursor);
          ELSE
            ArrowMouse;
          END;
        END;
      END;

      IF MuKeybd IN MyEvent THEN
        Cont:= FormKeybd(Tree,EditOb,NextOb,EKR,NextOb,EKR);
        IF EKR.ScanCode # 0 THEN
          IF KAlt IN EKS THEN
            ShortCutOb:= Root;
            ShortCutChar:= SpecialChar(EKR);
            TreeWalk(Tree,Root,Nil,searchshortcut);
            Cont:= FormButton(Tree,ShortCutOb,1,NextOb); (* 1 click *)
          ELSE
            ObjcEdit(Tree,EditOb,EKR,Index,EdChar);
          END;
        END;
      END;

      IF MuButton IN MyEvent THEN
        NextOb:= ObjcFind(Tree,Root,MaxDepth,EMXY);
        IF NextOb = Nil THEN
          VSound(Handle,550,3); (* works fine with AùBùC-GEM and NVDI *)
          NextOb:= Root;
        ELSE
          Cont:= FormButton(Tree,NextOb,EBR,NextOb);
        END;
      END;

      IF (NOT Cont) OR ((NextOb # Root) AND (NextOb # EditOb)) THEN
        ObjcEdit(Tree,EditOb,EKR,Index,EdEnd);
      END;

    END;
  END;

  INCLObjectFlags(Tree,EditOb,LastEdit); (* mark last edit position *)

  EndMouseControl;

  RETURN NextOb;
END formdo;

PROCEDURE FormDo(Tree: TreePtr;
                 Start: ObjectIndex): SIGNEDWORD;

VAR Rect    : GRect;
    DeskRect: GRect;
    NewPos  : GPnt;
    Return  : SIGNEDWORD;
    ExitOb  : ObjectIndex;
    PopOb   : ObjectPtr;

  PROCEDURE Mover(Tree: TreePtr; Index: ObjectIndex): BOOLEAN;
  BEGIN
    RETURN (GetObject.Type(Tree,Index) = GUserDef) AND
           (TouchExit IN GetObject.Flags(Tree,Index)) AND
           (ObjectState{Outlined,Crossed} * GetObject.State(Tree,Index) =
            ObjectState{Outlined,Crossed});
  END Mover;

BEGIN
  REPEAT
    Return:= formdo(Tree,Start); (* save return value *)
    ExitOb:= Mask(Return); (* remove double click *)

    IF Mover(Tree,ExitOb) THEN
      FormMgr.FormCenter(Tree,Rect);
      FormMgr.FormDial(FormMgr.FmDFinish,Rect,Rect);

      BeginUpdate;
      BeginMouseControl;

      WindGet.WorkXYWH(Desk,DeskRect);

      MouseForm(FlatHand);
      GrafDragBox(Rect.GW,Rect.GH,Rect.GX,Rect.GY,DeskRect,NewPos);
      LastMouse;

      SetObject.X(Tree,Root,GetObject.X(Tree,Root) + NewPos.GX - Rect.GX);
      SetObject.Y(Tree,Root,GetObject.Y(Tree,Root) + NewPos.GY - Rect.GY);
      FormMgr.FormCenter(Tree,Rect);
      FormMgr.FormDial(FormMgr.FmDStart,Rect,Rect);
      ObjcMgr.ObjcDraw(Tree,Root,MaxDepth,Rect);

      EndMouseControl;
      EndUpdate;
    END;

    IF GetObject.Extnd(Tree,ExitOb) = ORD(GPopup) THEN
      PopupAttach(PopupGAddr(Tree,ExitOb),Tree,ExitOb);
      PopOb:= PopupDo(PopupGAddr(Tree,ExitOb),0);

      IF PopOb # Nil THEN
        SetObject.StringPtr(Tree,
                            ExitOb,
                            GetObject.StringPtr(PopupGAddr(Tree,ExitOb),PopOb));
      END;

      FormMgr.FormCenter(Tree,Rect);
      ObjcMgr.ObjcDraw(Tree,ExitOb,4,Rect);
    END;
  UNTIL NOT Mover(Tree,ExitOb) AND (GetObject.Extnd(Tree,ExitOb) # ORD(GPopup));

  RETURN Return;
END FormDo;

(***************************************************************************)

PROCEDURE RsrcLoad(Name: ARRAY OF CHAR): BOOLEAN;

VAR Tree      : TreeIndex;
    RadioTree : TreePtr;
    Radio     : ObjectIndex;
    Height    : UNSIGNEDWORD;
    CharWidth : UNSIGNEDWORD;
    CharHeight: UNSIGNEDWORD;
    BoxWidth  : UNSIGNEDWORD;
    BoxHeight : UNSIGNEDWORD;
    CurrAttr  : TextAttributes;

BEGIN
  RadioTree:= NULL;

  (* scan whole resource for some extended object types *)

  Tree:= NumberOfTrees();
  WHILE Tree > 0 DO
    DEC(Tree);
    IF GetObject.Extnd(TreeArray(Tree),Root) = RadioButtons THEN
      RadioTree:= TreeArray(Tree);
    ELSIF GetObject.Extnd(TreeArray(Tree),Root) = FlyingAlerts THEN
      AlertTree:= TreeArray(Tree);
    END;

    Install(TreeArray(Tree));
  END;

  Height:= VSTHeight(Handle,AESFontHeightIBM,CharWidth,CharHeight,BoxWidth,BoxHeight);
  VQTAttributes(Handle,CurrAttr); (* query font height *)
  WITH CurrAttr DO
    IF CellHeight < 9 THEN (* minimum *)
      Radio:= 1;
    ELSIF CellHeight > 20 THEN (* maximum *)
      Radio:= 23;
    ELSE
      Radio:= 2 * (CellHeight - 9) + 1;
    END;

    IF (GrafBoxWidth >= 2 * GrafBoxHeight) THEN (* ATARI medium ST res. *)
      Radio:= 27; (* preliminary *)
    END;
  END;
#if not UNIX
  IF RadioTree # NULL THEN
    RButNorm:= RadioTree^[Radio].ObSpec.BitBlk;
    RButSel:= RadioTree^[Radio + 1].ObSpec.BitBlk;
  END;
#else

#endif

  RETURN TRUE;
END RsrcLoad;

PROCEDURE RsrcFree;

VAR Tree: TreeIndex;

BEGIN
  Tree:= NumberOfTrees();
  WHILE Tree > 0 DO
    DEC(Tree);
    Deinstall(TreeArray(Tree));
  END;
END RsrcFree;

(* new form_alert() function ***********************************************)

(*
PROCEDURE FlyingAlert(DefBut  : UNSIGNEDWORD;
                      PAlrtStr: ANYPOINTER): UNSIGNEDWORD;
BEGIN

END FlyingAlert;
*)

BEGIN
  AddApplInit(ApplInit);
  AddApplExit(ApplExit);

  ObjcMgr.ObjcDraw:= ObjcDraw;
(*ObjcMgr.ObjcEdit:= ObjcEdit;*)

  FormMgr.FormDo:= FormDo;
  FormMgr.FormDial:= FormTool.FormDial;
  FormMgr.FormCenter:= FormTool.FormCenter;
(*FormMgr.FormAlert:= FlyingAlert;*)

  AddRsrcLoad(RsrcLoad);
  AddRsrcFree(RsrcFree);

#if PCDOS || (GEMDOS && ABC)
  FirstCall:= TRUE;
#endif
END FlyingLook.
