IMPLEMENTATION MODULE FormTool;

(*
Form Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES       IMPORT Key,
                      Root,Nil,ObjectPtr,
                      TreePtr,TreeIndex,ObjectIndex,GPopup,
                      ObjectFlags,ObjectFlag,
                      ObjectState,Selected,Disabled,Outlined,
                      StringRange,Global;
FROM EvntMgr   IMPORT MuButton,MuM1,MuTimer,Event,MEvent,EvntEvent,
                      MoEnter,MoExit,MouseButton,MBLeft,EvntButton;
FROM ObjcMgr   IMPORT MaxDepth,ObjcDraw,ObjcFind,ObjcChange,ObjcOffset,
                      ObjcEdit,EditModes;
FROM FormMgr   IMPORT FormAlert,FormKeybd,FormButton;
FROM GrafMgr   IMPORT GrafMKState,SpecialKey,GrafMouse,MOn,MOff;
FROM RsrcMgr   IMPORT RTree,RString,RsrcGAddr;
FROM WindMgr   IMPORT Desk;
FROM RcMgr     IMPORT GRect,GPnt,RcConstrain;
FROM VRaster   IMPORT XY,MFDB,SOnly,VROCpyFm;
FROM ObjcTool  IMPORT EXCLObjectFlags,INCLObjectFlags,
                      INCLObjectState,EXCLObjectState,
                      IndirectObject,ObjectXYWH;
FROM GrafTool  IMPORT ArrowMouse,LastMouse;
FROM WindTool  IMPORT BeginUpdate,EndUpdate,
                      BeginMouseControl,EndMouseControl;
FROM VDITool   IMPORT AESHandle;
FROM PORTAB    IMPORT SIGNEDWORD,UNSIGNEDWORD,WORDSET,NULL,ANYPOINTER;
FROM INTRINSIC IMPORT VOID;
FROM pSTORAGE  IMPORT ALLOCATE,DEALLOCATE,SIZETYPE;
CAST_IMPORT

IMPORT FormMgr,GetObject,SetObject,WindGet;

PROCEDURE DoAlert(DefBut : UNSIGNEDWORD;
                  AlertNo: TreeIndex): UNSIGNEDWORD;

VAR AlertAddr: ANYPOINTER;

BEGIN
  IF RsrcGAddr(RString,AlertNo,AlertAddr) THEN
    RETURN FormAlert(DefBut,AlertAddr);
  ELSE
    RETURN 65535;
  END;
END DoAlert;

PROCEDURE Alert(AlertNo: TreeIndex);
BEGIN
  VOID(DoAlert(1,AlertNo));
END Alert;

PROCEDURE OK(AlertNo: TreeIndex): BOOLEAN;
BEGIN
  RETURN DoAlert(1,AlertNo) = 1;
END OK;

(**************************************************************************)

VAR Buffer: ANYPOINTER;

PROCEDURE FormDial(    Dial: FormDials;
                   VAR From: GRect;
                   VAR To  : GRect);

CONST WordWidth    = 16; (* word width in bits *)
      BytesPerWord = 2;  (* bytes per word     *)

VAR Size     : SIZETYPE;
    WdWidth  : XY;       (* wordwidth          *)
    PixPos   : XY;       (* pixel position     *)
    PXY      : ARRAY[0..7] OF XY;
    SrcMFDB  : MFDB;
    DstMFDB  : MFDB;
    Work     : GRect;

BEGIN
  WindGet.WorkXYWH(Desk,Work);

  WITH To DO
    IF (VAL(SIZETYPE,(GW DIV WordWidth + 2) * GH) >
        MAX(SIZETYPE) DIV VAL(SIZETYPE,Global.ApNPlanes)) OR
      (GH > Work.GH) OR
      (GW > Work.GW) THEN
      FormMgr.formdial(Dial,From,To);
      RETURN;
    END;

    Size:= VAL(SIZETYPE,(GW DIV WordWidth + 2) * GH) *
           VAL(SIZETYPE,Global.ApNPlanes) *
           VAL(SIZETYPE,BytesPerWord);


    WdWidth:= GW DIV WordWidth;
    PixPos:= GX MOD WordWidth;

    SrcMFDB.FDAddr:= NULL;

    WITH DstMFDB DO
      FDW:= GW;
      FDH:= GH;
      FDWdWidth:= WdWidth + 2;
      FDStand:= FALSE;
      FDNPlanes:= Global.ApNPlanes;
    END;

    CASE Dial OF
      FormMgr.FmDStart:
        ALLOCATE(Buffer,Size);
        IF Buffer # NIL THEN
          DstMFDB.FDAddr:= Buffer;
          PXY[0]:= GX;
          PXY[1]:= GY;
          PXY[2]:= GX + GW - 1;
          PXY[3]:= GY + GH - 1;
          PXY[4]:= PixPos;
          PXY[5]:= 0;
          PXY[6]:= GW + INT(PixPos) - 1;
          PXY[7]:= GH - 1;

          GrafMouse(MOff,NULL);
          VROCpyFm(AESHandle(),SOnly,PXY,SrcMFDB,DstMFDB);
          GrafMouse(MOn,NULL);
        ELSE
          FormMgr.formdial(FormMgr.FmDStart,From,To);
        END;
    | FormMgr.FmDFinish:
        IF Buffer # NIL THEN
          DstMFDB.FDAddr:= Buffer;
          PXY[0]:= PixPos;
          PXY[1]:= 0;
          PXY[2]:= GW + INT(PixPos) - 1;
          PXY[3]:= GH - 1;
          PXY[4]:= GX;
          PXY[5]:= GY;
          PXY[6]:= GX + GW - 1;
          PXY[7]:= GY + GH - 1;

          GrafMouse(MOff,NULL);
          VROCpyFm(AESHandle(),SOnly,PXY,DstMFDB,SrcMFDB);
          GrafMouse(MOn,NULL);
          DEALLOCATE(Buffer,Size);
        ELSE
          FormMgr.formdial(FormMgr.FmDFinish,From,To);
        END;
    ELSE
      FormMgr.formdial(Dial,From,To);
    END;
  END;
END FormDial;

PROCEDURE FormCenter(    Tree: TreePtr;
                     VAR Rect: GRect);

CONST Margin = 3; (* documented by Tim Oren *)

VAR Work      : GRect;
    Pnt       : GPnt;
    MouseState: MouseButton;
    KeyState  : SpecialKey;

BEGIN
  IF (GetObject.X(Tree,Root) = 0) AND (GetObject.Y(Tree,Root) = 0) THEN
    FormMgr.formcenter(Tree,Rect);
    GrafMKState(Pnt,MouseState,KeyState);
    WITH Pnt DO
      Rect.GX:= GX + 16;
      Rect.GY:= GY + 16;
      WindGet.WorkXYWH(Desk,Work);
      RcConstrain(Work,Rect);
      GX:= Rect.GX + Margin;
      GY:= Rect.GY + Margin;
    END;
    SetObject.Pnt(Tree,Root,Pnt);
  ELSE
    GetObject.Rect(Tree,Root,Rect);
    WITH Rect DO
      DEC(GX,Margin);
      DEC(GY,Margin);
      INC(GW,2 * Margin);
      INC(GH,2 * Margin);
    END;
  END;
END FormCenter;

PROCEDURE Mask(RetOb: SIGNEDWORD): ObjectIndex;
BEGIN
#ifdef FTLM2
  RETURN CAST(ObjectIndex,CAST(WORDSET,RetOb) - WORDSET{0});
#else
  RETURN CAST(ObjectIndex,CAST(WORDSET,RetOb) - WORDSET{15});
#endif
END Mask;

PROCEDURE DoubleClicked(VAR RetOb: SIGNEDWORD): BOOLEAN;

VAR DoubleClick: BOOLEAN;

BEGIN
  DoubleClick:= RetOb < 0;
#ifdef FTLM2
  RetOb:= CAST(SIGNEDWORD,CAST(WORDSET,RetOb) - WORDSET{0);
#else
  RetOb:= CAST(SIGNEDWORD,CAST(WORDSET,RetOb) - WORDSET{15});
#endif
  RETURN DoubleClick;
END DoubleClicked;

(*
TYPE FormProc = PROCEDURE(TreePtr,ObjectIndex): ObjectIndex;

PROCEDURE InstallFormProc(Proc: FormProc);

PROCEDURE StandardForm(    Caller : ObjectIndex;
                           TreeNo : ObjectIndex;
                       VAR StartOb: ObjectIndex): ObjectIndex;
*)

(*
PROCEDURE DoForm(VAR StartOb: ObjectIndex;
                     Proc   : FormProc;
                     TreeNo : TreeIndex;
                     Caller : ObjectIndex): ObjectIndex;

VAR CallerTree: TreePtr;
    Tree      : TreePtr;
    From      : GRect;
    To        : GRect;
    RetObj    : SIGNEDWORD;

BEGIN
  BeginUpdate;
  FormCenter(Tree,To);
  FormDial(FmDStart,To,To);
  IF Caller # Nil THEN
    RsrcGAddr(RTree,TreeNo,CallerTree);
    ObjcXYWH(CallerTree,Caller,From);
  ELSE
    XYWHToGRect(0,0,0,0,From);
  END;

  FormDial(FmDGrow,From,To);
  ObjcDraw(Tree,Root,MaxDepth,To);
  RetObj:= Proc(Tree,StartOb);
  ExclObjcState(Tree,RetObj,Selected);
  FormDial(FmDShrink,From,To);
  FormDial(FmDFinish,To,To);
  EndUpdate;
  RETURN RetObj;
END StandardForm;
*)

PROCEDURE PopupDo(Tree  : TreePtr;
                  Select: ObjectIndex): ObjectPtr;

CONST WordWidth    = 16; (* word width in bits *)
      BytesPerWord = 2;

VAR Size     : SIZETYPE;
    WdWidth  : XY;       (* word width     *)
    PixPos   : XY;       (* pixel position *)
    PXY      : ARRAY[0..7] OF XY;
    Screen   : MFDB;
    Buffer   : MFDB;
    Work     : GRect;

    Mouse    : GPnt;
    Button   : MouseButton;
    State    : SpecialKey;
    PopupBox : GRect;
    DeskRect : GRect;
    Item     : ObjectPtr;
    FoundItem: ObjectPtr;
    OldItem  : ObjectPtr;
    PopEvent : MEvent;
    MyEvent  : Event;


BEGIN
  GrafMKState(Mouse,Button,State);

  ObjectXYWH(Tree,Root,PopupBox);
  WindGet.WorkXYWH(Desk,DeskRect);
  (* shadowed... *)
  DEC(PopupBox.GX,2);
  DEC(PopupBox.GY,2);
  INC(PopupBox.GW,3 + 2);
  INC(PopupBox.GH,3 + 2);
  RcConstrain(DeskRect,PopupBox);
  SetObject.X(Tree,Root,PopupBox.GX + 2);
  SetObject.Y(Tree,Root,PopupBox.GY + 2);

  OldItem:= Nil;
  Item:= ObjcFind(Tree,Select,MaxDepth,Mouse);
  FoundItem:= Item;

  IF Item # Nil THEN
    IF (    Disabled   IN GetObject.State(Tree,Item)) OR
       (NOT(Selectable IN GetObject.Flags(Tree,Item))) THEN
      Item:= Nil;
    END;
    INCLObjectState(Tree,Item,Selected);
  END;

  WITH PopupBox DO
    Size:= VAL(SIZETYPE,(GW DIV WordWidth + 2) * GH) *
           VAL(SIZETYPE,Global.ApNPlanes) *
           VAL(SIZETYPE,BytesPerWord);

    WdWidth:= GW DIV WordWidth;
    PixPos:= GX MOD WordWidth;

    Screen.FDAddr:= NULL;

    WITH Buffer DO
      FDW:= GW;
      FDH:= GH;
      FDWdWidth:= WdWidth + 2;
      FDStand:= FALSE;
      FDNPlanes:= Global.ApNPlanes;
    END;
  END;

  BeginUpdate;
  BeginMouseControl; (* popups are modal *)

  ALLOCATE(Buffer.FDAddr,Size);
  IF Buffer.FDAddr # NIL THEN
    WITH PopupBox DO
      PXY[0]:= GX;
      PXY[1]:= GY;
      PXY[2]:= GX + GW - 1;
      PXY[3]:= GY + GH - 1;
      PXY[4]:= PixPos;
      PXY[5]:= 0;
      PXY[6]:= GW + INT(PixPos) - 1;
      PXY[7]:= GH - 1;
    END;
    GrafMouse(MOff,NULL);
    VROCpyFm(AESHandle(),SOnly,PXY,Screen,Buffer);
    GrafMouse(MOn,NULL);
  END;

  ObjcDraw(Tree,Root,2,DeskRect);

  ArrowMouse;

  WITH PopEvent DO
    EFlags:= Event{MuButton,MuM1};
    EBClk:= 1;
    EBMsk:= MouseButton{MBLeft};
    EBSt:= MouseButton{MBLeft} - Button;
  END;

  LOOP
    IF FoundItem # Nil THEN
      PopEvent.EM1Flags:= MoExit;
      ObjectXYWH(Tree,FoundItem,PopEvent.EM1);
    ELSE
      PopEvent.EM1Flags:= MoEnter;
      ObjectXYWH(Tree,Select,PopEvent.EM1);
    END;

    MyEvent:= EvntEvent(PopEvent);

    OldItem:= Item;
    Item:= ObjcFind(Tree,Select,MaxDepth,PopEvent.EMXY);
    FoundItem:= Item;

    IF Item # Nil THEN
      IF (    Disabled   IN GetObject.State(Tree,Item)) OR
         (NOT(Selectable IN GetObject.Flags(Tree,Item))) THEN
        Item:= Nil;
      END;
    END;

    IF OldItem # Item THEN
      IF OldItem # Nil THEN
        ObjcChange(Tree,OldItem,0,DeskRect,
                   GetObject.State(Tree,OldItem) / ObjectState{Selected},
                   TRUE);
      END;
      IF Item # Nil THEN
        ObjcChange(Tree,Item,0,DeskRect,
                   GetObject.State(Tree,Item) / ObjectState{Selected},
                   TRUE);
      END;
    END;

    IF (MuButton IN MyEvent) THEN
      EXIT;
    END;
  END; (* LOOP *)

  LastMouse;

  IF Buffer.FDAddr # NIL THEN
    WITH PopupBox DO
      PXY[0]:= PixPos;
      PXY[1]:= 0;
      PXY[2]:= GW + INT(PixPos) - 1;
      PXY[3]:= GH - 1;
      PXY[4]:= GX;
      PXY[5]:= GY;
      PXY[6]:= GX + GW - 1;
      PXY[7]:= GY + GH - 1;
    END;
    GrafMouse(MOff,NULL);
    VROCpyFm(AESHandle(),SOnly,PXY,Buffer,Screen);
    GrafMouse(MOn,NULL);
    DEALLOCATE(Buffer.FDAddr,Size);
  END;

  EndMouseControl;
  EndUpdate;

  IF Item # Nil THEN
    EXCLObjectState(Tree,Item,Selected);
  END;

  IF (MouseButton{MBLeft} - Button # MouseButton{}) THEN
    VOID(EvntButton(1,MouseButton{MBLeft},MouseButton{},Mouse,Button,State));
  END;

  RETURN Item;
END PopupDo;

(*
PROCEDURE PopupCallBack(Tree: TreePtr; Index: ObjectIndex);
BEGIN

END PopupCallBack;
*)

PROCEDURE PopupAttach(PopupTree : TreePtr;
                      ParentTree: TreePtr;
                      ParentOb  : ObjectIndex);

VAR XOff: SIGNEDWORD;
    YOff: SIGNEDWORD;

BEGIN
  ObjcOffset(ParentTree,ParentOb,XOff,YOff);
  SetObject.X(PopupTree,Root,XOff);
  SetObject.Y(PopupTree,Root,YOff);
  (*
  NewObjectCallback(ParentTree,ParentOb,PopupCallBack);
  *)
  SetObject.Extnd(ParentTree,ParentOb,ORD(GPopup));
  IndirectObject(ParentTree,ParentOb,PopupTree);
END PopupAttach;

PROCEDURE PopupGAddr(ParentTree: TreePtr; ParentOb: ObjectIndex): TreePtr;
BEGIN
  IF Indirect IN GetObject.Flags(ParentTree,ParentOb) THEN
    RETURN ParentTree^[ParentOb].ObSpec.Extension^.Parm;
  END;
END PopupGAddr;

(*
PROCEDURE PopupText(    PopupTree: TreePtr;
                        Item     : ObjectIndex;
                    VAR Text     : ARRAY OF CHAR);
BEGIN

END PopupText;

PROCEDURE PopupICheck(PopupTree: TreePtr;
                      Item     : ObjectIndex;
                      Check    : BOOLEAN);
BEGIN

END PopupICheck;

PROCEDURE PopupIEnable(PopupTree: TreePtr;
                       Item     : ObjectIndex;
                       Enable   : BOOLEAN);
BEGIN

END PopupIEnable;
*)

(*
PROCEDURE

VAR

BEGIN
  REPEAT
    Return:= Mask(FormDo(ParentTree,Start));

    IF GetObject.Extnd(ParentTree,Return) = Popup THEN
      ParentTree:=
      ObjcOffset(ParentTree,ParentOb,XOff,YOff);
      PopTree^[0].ObX:= XOff;
      PopTree^[0].ObY:= YOff;
      VOID(PopupDo(PopTree,0));
    END;
    ObjcOffset(ParentTree,Return,To.GX,To.GY);
    ObjcChange(ParentTree,Return,1,To,
               GetObject.State(ParentTree,Return) - ObjectState{Selected},
               TRUE);
    (*
      change text
    *)
  UNTIL GetObject.Extnd(Tree,Return) # Popup;
END;
*)

BEGIN
  Buffer:= NIL;
END FormTool.
