(***************************************************************************)
(* GEM sample application                                                  *)
(* adapted from apskel.c by Ron Zdybl, Atari Corp.                         *)
(*                                                                         *)
(* UK 04/21/1996                                                           *)
(***************************************************************************)

MODULE XSample;

FROM AES        IMPORT Root,Nil,ObjectIndex,ObjectPtr,TreeIndex,
                       TreePtr,StringPtr,
                       ObjectState,Selected,State15,Checked,
                       HideTree,Key,SpecialKey,KLShift,KRShift,
                       MouseButton,MBLeft;
FROM ApplMgr    IMPORT ApplInit,ApplExit,ApplWrite;
FROM EvntMgr    IMPORT EvntEvent,MEvent,MuMesag,MuKeybd,MuButton,MuTimer,
                       Event,MessageBlock,ApMsg,ApTerm,ApDragDrop,
                       WMRedraw,WMNewTop,WMTopped,WMSized,WMMoved,WMFulled,
                       WMClosed,MnSelected,WMIconfy,WMUniconfy;
FROM ObjcMgr    IMPORT ObjcDraw,MaxDepth,ObjcOffset,ObjcFind,ObjcChange;
FROM FormMgr    IMPORT FmDStart,FmDGrow,FmDShrink,FmDFinish,FormDial,
                       FormCenter,FormDo;
FROM MenuMgr    IMPORT MenuICheck,MenuText,MenuTNormal,MenuRegister;
FROM GrafMgr    IMPORT GrafHandle,GrafMKState,GrafGrowBox,GrafShrinkBox;
FROM RsrcMgr    IMPORT RsrcLoad,RsrcFree,AddRsrcLoad,AddRsrcFree;
FROM WindMgr    IMPORT NoWindow,Desk,WindCreate,WindOpen,WindClose,
                       WindFind,WindDelete,WindCalc,WCBorder,WCWork,
                       Wind,Name,Close,Full,Move,Info,Size,HSlide,VSlide,
                       Small;
FROM ShelMgr    IMPORT ShelWrite;
FROM RcMgr      IMPORT GRect,GPnt,RcSnap,RcIntersect,RcEqual;

FROM ApplTool   IMPORT ApplSignal,ApSigInt,ApSigQuit,ApSigTerm;
FROM MenuTool   IMPORT ShowMenu,HideMenu,
                       NewMenuAction,DisposeMenuAction,MenuAction,
                       MenuKey;
FROM ObjcTool   IMPORT ObjectXYWH,INCLObjectState,EXCLObjectState,
                       INCLObjectFlags,EXCLObjectFlags,TreeWalk,
                       NewObjectCallback,DisposeObjectCallback,ObjectCall,
                       Indirect;
FROM FormTool   IMPORT OK,Alert,Mask,PopupAttach;
FROM RsrcTool   IMPORT GetTreePtr,GetFreeStringPtr;
FROM GrafTool   IMPORT ShowMouse,HideMouse,BusyMouse,MouseForm,FlatHand,
                       PointingHand,ArrowMouse,LastMouse,
                       HotRubberBox,HotDragBox,HotDragIcon;
FROM WindTool   IMPORT BeginUpdate,EndUpdate,
                       BeginMouseControl,EndMouseControl,
                       RedrawWindow;
FROM DeskTool   IMPORT OpenDesk,CloseDesk,DrawDeskObject;
FROM VDI        IMPORT XY,White,Black,Blue;
FROM VAttribute IMPORT VSFInterior,FISPattern,VSFStyle,VSFColor;
FROM VOutput    IMPORT VBar,VEllipse;
FROM VDITool    IMPORT OpenVirtualWorkstation,CloseVirtualWorkstation,
                       SetClip,GRectToArray;
FROM INTRINSIC  IMPORT VOID,PTR,UNSIGNEDWORDOF;
FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYWORD,UNSIGNEDLONG,NULL;

IMPORT AES,FlyingLook,SetObject,GetObject,WindSet,WindGet;

(* resource indices created by Interface *)

CONST

    MENU     =   0;    (* Menuebaum *)
    TINFO    =   3;    (* TITLE in Baum MENU *)
    TFILE    =   4;    (* TITLE in Baum MENU *)
    TEDIT    =   5;    (* TITLE in Baum MENU *)
    TOPTION  =   6;    (* TITLE in Baum MENU *)
    IINFO    =   9;    (* STRING in Baum MENU *)
    INEW     =  18;    (* STRING in Baum MENU *)
    IOPEN    =  19;    (* STRING in Baum MENU *)
    ISAVE    =  21;    (* STRING in Baum MENU *)
    IQUIT    =  28;    (* STRING in Baum MENU *)
    IUNDO    =  30;    (* STRING in Baum MENU *)
    ICUT     =  32;    (* STRING in Baum MENU *)
    ICOPY    =  33;    (* STRING in Baum MENU *)
    IPASTE   =  34;    (* STRING in Baum MENU *)
    IDELETE  =  36;    (* STRING in Baum MENU *)
    IWARNING =  38;    (* STRING in Baum MENU *)
    IHELP    =  39;    (* STRING in Baum MENU *)
    IELL     =  41;    (* STRING in Baum MENU *)
    IRS232   =  42;    (* STRING in Baum MENU *)
    IFORMAT  =  43;    (* STRING in Baum MENU *)

    DESK     =   1;    (* Formular/Dialog *)
    DISKA    =   3;    (* ICON in Baum DESK *)
    DISKB    =   4;    (* ICON in Baum DESK *)
    FOLDER   =   5;    (* ICON in Baum DESK *)
    COLICON  =   6;    (* ICON in Baum DESK *)
    COLICON5 =   7;    (* IMAGE in Baum DESK *)
    COLICON7 =   8;    (* IMAGE in Baum DESK *)
    COLICON2 =   9;    (* IMAGE in Baum DESK *)
    COLICONF =  10;    (* IMAGE in Baum DESK *)
    COLICON6 =  11;    (* IMAGE in Baum DESK *)
    COLICONC =  12;    (* IMAGE in Baum DESK *)
    COLICON4 =  13;    (* IMAGE in Baum DESK *)
    COLICON3 =  14;    (* IMAGE in Baum DESK *)
    COLICONE =  15;    (* IMAGE in Baum DESK *)
    COLICON9 =  16;    (* IMAGE in Baum DESK *)
    COLICON8 =  17;    (* IMAGE in Baum DESK *)
    COLICONA =  18;    (* IMAGE in Baum DESK *)
    COLICOND =  19;    (* IMAGE in Baum DESK *)
    COLICONB =  20;    (* IMAGE in Baum DESK *)

    INFO     =   2;    (* Formular/Dialog *)
    INFOK    =   1;    (* BOXTEXT in Baum INFO *)
    INFTITLE =   4;    (* TEXT in Baum INFO *)

    SCANCODE =   3;    (* Formular/Dialog *)

    RADIOBUT =   4;    (* Formular/Dialog *)

    FLYINGAL =   5;    (* Formular/Dialog *)
    ALRTIMG0 =   1;    (* IMAGE in Baum FLYINGAL *)

    RS232    =   6;    (* Formular/Dialog *)
    RSOK     =   1;    (* BUTTON in Baum RS232 *)
    RSCANCEL =   2;    (* BOXTEXT in Baum RS232 *)
    RSTITLE  =  24;    (* STRING in Baum RS232 *)

    ELLEDIT  =   7;    (* Formular/Dialog *)
    ELLCANCL =   3;    (* BUTTON in Baum ELLEDIT *)
    ELLOK    =   4;    (* BUTTON in Baum ELLEDIT *)

    PGFORMAT =   8;    (* Formular/Dialog *)
    PGOK     =   2;    (* BUTTON in Baum PGFORMAT *)
    PGCANCEL =   3;    (* BUTTON in Baum PGFORMAT *)
    PGFORMATPARENT =   8;    (* BUTTON in Baum PGFORMAT *)
    PGOUTPUTTOPARENT =  15;    (* BUTTON in Baum PGFORMAT *)
    PGMSRUNITPARENT =  19;    (* BUTTON in Baum PGFORMAT *)

    FORMAT   =   9;    (* Formular/Dialog *)

    MSRUNIT  =  10;    (* Formular/Dialog *)

    OUTPUTTO =  11;    (* Formular/Dialog *)

    WNAME    =   0;    (* Freier String *)

    WINFO    =   1;    (* Freier String *)

    HELPON   =   2;    (* Freier String *)

    HELPOFF  =   3;    (* Freier String *)

    NOWIND   =   4;    (* Alert String *)

    NOVWORK  =   5;    (* Alert String *)

    QUIT     =   6;    (* Alert String *)

    DOUBLECL =   7;    (* Alert String *)

    DRAGDROP =   8;    (* Alert String *)

    CANCELSL =   9;    (* Alert String *)

CONST RscName   = "XSAMPLE.RSC";
      MyFeature = Wind{Name,Close,Full,Move,Info,Size,HSlide,VSlide,Small};

VAR ApplId: SIGNEDWORD;

    VirtScreen: UNSIGNEDWORD;

    Register: ARRAY[0..20] OF CHAR;

    MyMenu: TreePtr;
    MyDesk: TreePtr;
    MyName: StringPtr;
    MyInfo: StringPtr;

    HelpItem: StringPtr;

    MyWindow: SIGNEDWORD;

    Work: GRect;
    XEll: UNSIGNEDWORD;
    YEll: UNSIGNEDWORD;
    WEll: UNSIGNEDWORD;
    HEll: UNSIGNEDWORD;

    CharWidth : UNSIGNEDWORD;
    CharHeight: UNSIGNEDWORD;
    BoxWidth  : UNSIGNEDWORD;
    BoxHeight : UNSIGNEDWORD;
    MinWidth  : SIGNEDWORD;
    MinHeight : SIGNEDWORD;

PROCEDURE OpenWindow(VAR Window: SIGNEDWORD): BOOLEAN;

VAR Start: GRect;
    Full : GRect;

BEGIN
  WindGet.WorkXYWH(Desk,Full);
  Window:= WindCreate(MyFeature,Full);
  IF Window # NoWindow THEN

    MyName:= GetFreeStringPtr(WNAME);
    WindSet.Name(Window,MyName^);

    MyInfo:= GetFreeStringPtr(WINFO);
    WindSet.Info(Window,MyInfo^);

    WITH Full DO
      Start.GX:= GX + GW DIV 2;
      Start.GY:= GY + GH DIV 2;
      Start.GW:= BoxWidth;
      Start.GH:= BoxHeight;
    END;

    GrafGrowBox(Start,Full);
    WindOpen(Window,Full);
  END;
  RETURN Window # NoWindow;
END OpenWindow;

PROCEDURE CloseWindow(Window: SIGNEDWORD);

VAR Start: GRect;
    End  : GRect;
    Full : GRect;

BEGIN
  WindGet.CurrXYWH(Window,Start);
  WindGet.WorkXYWH(Desk,Full);

  WITH Full DO
    End.GX:= GW DIV 2;
    End.GY:= GH DIV 2;
    End.GW:= BoxWidth;
    End.GH:= BoxHeight;
  END;

  WindClose(Window);
  GrafShrinkBox(End,Start);
  WindDelete(Window);
END CloseWindow;

PROCEDURE DrawSample(Window: SIGNEDWORD; VAR Rect: GRect);

VAR Points: ARRAY[0..3] OF XY;
    Work  : GRect;

BEGIN
  SetClip(VirtScreen,Rect);
  VSFInterior(VirtScreen,FISPattern);
  VSFStyle(VirtScreen,8);
  VSFColor(VirtScreen,White);
  WindGet.WorkXYWH(Window,Work);
  GRectToArray(Work,Points);
  VBar(VirtScreen,Points);

  XEll:= Work.GX;
  YEll:= Work.GY;
  VSFInterior(VirtScreen,FISPattern);
  VSFStyle(VirtScreen,8);
  VSFColor(VirtScreen,Blue);
  VEllipse(VirtScreen,XEll + WEll DIV 2,
                      YEll + HEll DIV 2,
                      WEll DIV 2,
                      HEll DIV 2);
END DrawSample;

PROCEDURE DoRedraw(    Window: SIGNEDWORD;
                   VAR Clip  : GRect);
BEGIN
  RedrawWindow(Window,Clip,DrawSample);
END DoRedraw;

PROCEDURE DoSize(Window: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH Rect DO
    IF GW < MinWidth THEN
      GW:= MinWidth;
    END;
    IF GH < MinHeight THEN
      GH:= MinHeight;
    END;
  END;
  WindSet.CurrXYWH(Window,Rect);
END DoSize;

PROCEDURE DoFull(Window: SIGNEDWORD);

VAR Prev: GRect;
    Curr: GRect;
    Full: GRect;

BEGIN
  WindGet.FullXYWH(Window,Full);
  WindGet.CurrXYWH(Window,Curr);
  WindGet.PrevXYWH(Window,Prev);
  IF RcEqual(Curr,Full) THEN
    GrafShrinkBox(Prev,Full);
    WindSet.CurrXYWH(Window,Prev);
  ELSE
    GrafGrowBox(Curr,Full);
    WindSet.CurrXYWH(Window,Full);
  END;
END DoFull;

PROCEDURE DoClose(Window: SIGNEDWORD);

VAR MyMessage: MessageBlock;

BEGIN
  WITH MyMessage DO
    Type  := MnSelected;
    Id    := ApplId;
    Length:= 0;
    Title := TFILE;
    Item  := IQUIT;
  END;
  ApplWrite(ApplId,16,MyMessage);
END DoClose;

PROCEDURE DoForm(Menu  : TreePtr;
                 Title : ObjectIndex;
                 TreeNo: TreeIndex;
                 Start : ObjectIndex): ObjectIndex;

VAR Tree  : TreePtr;
    From  : GRect;
    To    : GRect;
    Return: SIGNEDWORD;

BEGIN
  ObjectXYWH(Menu,Title,From);
  Tree:= GetTreePtr(TreeNo);
  FormCenter(Tree,To);
  BeginUpdate;
  FormDial(FmDStart,To,To);
  FormDial(FmDGrow,From,To);
  ObjcDraw(Tree,Root,MaxDepth,To);
  Return:= Mask(FormDo(Tree,Start));

  (* using FlyingLook you have to call FormCenter() a second time! *)

  FormCenter(Tree,To);

  ObjcChange(Tree,Return,1,To,
             GetObject.State(Tree,Return) - ObjectState{Selected},FALSE);
  FormDial(FmDShrink,From,To);
  FormDial(FmDFinish,To,To);
  EndUpdate;
  RETURN Return;
END DoForm;

PROCEDURE DoInfo(Menu: TreePtr; Title: ObjectIndex);
BEGIN
  VOID(DoForm(Menu,Title,INFO,0));
END DoInfo;

PROCEDURE DoEllipse(Menu: TreePtr; Title: ObjectIndex);
BEGIN
  VOID(DoForm(Menu,Title,ELLEDIT,0));
END DoEllipse;

PROCEDURE DoRSCancel(Tree: TreePtr; Index: ObjectIndex);
BEGIN
  Alert(CANCELSL);
END DoRSCancel;

PROCEDURE DoRS232(Menu: TreePtr; Title: ObjectIndex);

VAR Ret: ObjectIndex;

BEGIN
  Ret:= DoForm(Menu,Title,RS232,0);
  IF Indirect(GetTreePtr(RS232),Ret) THEN
    ObjectCall(GetTreePtr(RS232),Ret);
  END;
END DoRS232;

PROCEDURE DoFormat(Menu: TreePtr; Title: ObjectIndex);
BEGIN
  VOID(DoForm(Menu,Title,PGFORMAT,0));
END DoFormat;

PROCEDURE ToggleHelp(Menu: TreePtr; Title: ObjectIndex);
BEGIN
  IF State15 IN GetObject.State(Menu,IHELP) THEN
    HelpItem:= GetFreeStringPtr(HELPOFF);
    EXCLObjectState(Menu,IHELP,State15);
  ELSE
    HelpItem:= GetFreeStringPtr(HELPON);
    INCLObjectState(Menu,IHELP,State15);
  END;
  MenuText(Menu,IHELP,HelpItem^);
END ToggleHelp;

PROCEDURE ToggleWarning(Menu: TreePtr; Title: ObjectIndex);
BEGIN
  MenuICheck(Menu,IWARNING,NOT(Checked IN GetObject.State(Menu,IWARNING)));
END ToggleWarning;

PROCEDURE DoNothing(Menu: TreePtr; Title: ObjectIndex);
BEGIN
END DoNothing;

PROCEDURE DoMenu(Title: ObjectIndex; Item: ObjectIndex);
BEGIN
  ArrowMouse;
  MenuAction(MyMenu,Title,Item);
  MenuTNormal(MyMenu,Title,TRUE);
END DoMenu;

PROCEDURE DeselectAll(Tree: TreePtr; Index: ObjectIndex): BOOLEAN;
BEGIN
  IF Selected IN GetObject.State(Tree,Index) THEN
    EXCLObjectState(Tree,Index,Selected);
    DrawDeskObject(Tree,Index);
  END;
  RETURN TRUE;
END DeselectAll;

PROCEDURE DoClick(Clicks: UNSIGNEDWORD; Pos: GPnt);

VAR MyIcon        : ObjectPtr;
    Index         : ObjectIndex;
    Dummy         : GPnt;
    Special       : SpecialKey;
    PressedButtons: MouseButton;
    Box           : GRect;
    Rect          : GRect;

  PROCEDURE MoveObject(Pos: GPnt; Tree: TreePtr; Ob: ObjectIndex);

  VAR DeskRect: GRect;
      OldPos  : GPnt;
      NewPos  : GPnt;

  BEGIN
    ObjcOffset(Tree,Ob,OldPos.GX,OldPos.GY);
    ObjectXYWH(Tree,Root,DeskRect);

    BeginUpdate;
    MouseForm(FlatHand);

    NewPos:= Pos;
    VOID(HotDragIcon(NewPos,Tree,Ob,DeskRect));

    LastMouse;
    EndUpdate;

    IF WindFind(NewPos) = Desk THEN
      INCLObjectFlags(Tree,Ob,HideTree);
      DrawDeskObject(Tree,Ob);
      SetObject.X(Tree,Ob,
                  RcSnap(GetObject.X(Tree,Ob) + NewPos.GX - OldPos.GX,80));
      SetObject.Y(Tree,Ob,
                  RcSnap(GetObject.Y(Tree,Ob) + NewPos.GY - OldPos.GY,48));
      EXCLObjectFlags(Tree,Ob,HideTree);
      DrawDeskObject(Tree,Ob);
    END;
  END MoveObject;

BEGIN
  BeginUpdate;
  BeginMouseControl;
  IF WindFind(Pos) = Desk THEN
    MyIcon:= ObjcFind(MyDesk,Root,1,Pos);

    IF Clicks = 2 THEN
      IF MyIcon >= DISKA THEN
        INCLObjectState(MyDesk,MyIcon,Selected);
        DrawDeskObject(MyDesk,MyIcon);
        Alert(DOUBLECL);
        EXCLObjectState(MyDesk,MyIcon,Selected);
        DrawDeskObject(MyDesk,MyIcon);
      END;
    ELSIF Clicks = 1 THEN
      GrafMKState(Dummy,PressedButtons,Special); (* button still pressed? *)

      IF MBLeft IN PressedButtons THEN (* left button pressed *)
        TreeWalk(MyDesk,DISKA,Nil,DeselectAll);
        IF MyIcon >= DISKA THEN (* pressed on an icon *)
          INCLObjectState(MyDesk,MyIcon,Selected);
          DrawDeskObject(MyDesk,MyIcon);
          MoveObject(Pos,MyDesk,MyIcon);
        ELSE                    (* pressed on the desk *)
          ObjectXYWH(MyDesk,Root,Rect);
          HotRubberBox(Pos,MyDesk,Rect);
        END;
      ELSE (* single click, but button no more pressed *)
        IF MyIcon >= DISKA THEN (* single click on an icon *)
          IF (SpecialKey{KLShift,KRShift} * Special # SpecialKey{}) THEN
            SetObject.State(MyDesk,
                            MyIcon,
                            GetObject.State(MyDesk,MyIcon) / ObjectState{Selected});
            DrawDeskObject(MyDesk,MyIcon);
          ELSE (* without shift *)
            IF NOT(Selected IN GetObject.State(MyDesk,MyIcon)) THEN
              TreeWalk(MyDesk,DISKA,Nil,DeselectAll);
              INCLObjectState(MyDesk,MyIcon,Selected);
              DrawDeskObject(MyDesk,MyIcon);
            END;
          END;
        ELSE                    (* single click on the desk *)
          TreeWalk(MyDesk,DISKA,Nil,DeselectAll);
        END;
      END;
    END;
  END;
  EndMouseControl;
  EndUpdate;
END DoClick;

PROCEDURE EventLoop;

VAR EventBlock: MEvent;
    MyEvent   : Event;
    MyMessage : MessageBlock;
    Clicks    : UNSIGNEDWORD;

BEGIN
  WITH EventBlock DO
    EFlags:= Event{MuMesag,MuKeybd,MuButton,MuTimer};
    EMePBuf:= PTR(MyMessage);
    EBClk:= 2;
    EBMsk:= MouseButton{MBLeft};
    EBSt:= MouseButton{MBLeft};
    ELoCount:= 750; (* wait for signal evaluation *)
    EHiCount:= 0;

    WITH MyMessage DO
      LOOP
        CASE ApplSignal() OF
          ApSigInt:
            IF OK(QUIT) THEN
              EXIT;
            END;
        | ApSigTerm:
            IF OK(QUIT) THEN
              EXIT;
            END;
        | ApSigQuit:
            IF OK(QUIT) THEN
              EXIT;
            END;
        ELSE
          ;
        END;

        MyEvent:= EvntEvent(EventBlock);

        IF MuMesag IN MyEvent THEN
          CASE Type OF
            WMRedraw:
              DoRedraw(Handle,Rect);
          | WMNewTop,WMTopped:
              WindSet.Top(Handle);
          | WMSized:
              DoSize(Handle,Rect);
          | WMMoved:
              WindSet.CurrXYWH(Handle,Rect);
          | WMFulled:
              DoFull(Handle);
          | WMClosed,ApTerm:
              DoClose(Handle);
          | WMIconfy:
              WindSet.Iconfy(Handle,Rect);
          | WMUniconfy:
              WindSet.Uniconfy(Handle,Rect);
          | MnSelected:
              IF Item = IQUIT THEN
                IF OK(QUIT) THEN
                  MenuTNormal(MyMenu,Title,TRUE);
                  EXIT;
                END;
                MenuTNormal(MyMenu,Title,TRUE);
              ELSE
                DoMenu(Title,Item);
              END;
          | ApDragDrop:
              Alert(DRAGDROP);
          ELSE
            ;
          END;
        END;

        IF MuButton IN MyEvent THEN
          DoClick(EBR,EMXY);
        END;

        IF MuKeybd IN MyEvent THEN
          IF NOT MenuKey(MyMenu,EKR,EKS) THEN
            ;
          END;
        END;

      END;
    END;
  END;
END EventLoop;

PROCEDURE RsrcLoadAction(Dummy: ARRAY OF CHAR): BOOLEAN;
BEGIN
  (* initialize menu actions *)

  MyMenu:= GetTreePtr(MENU);

  NewMenuAction(MyMenu,IINFO,DoInfo);
  NewMenuAction(MyMenu,IHELP,ToggleHelp);
  NewMenuAction(MyMenu,IELL,DoEllipse);
  NewMenuAction(MyMenu,IRS232,DoRS232);
  NewMenuAction(MyMenu,IFORMAT,DoFormat);
  NewMenuAction(MyMenu,IWARNING,ToggleWarning);
  NewMenuAction(MyMenu,IQUIT,DoNothing);

  (* initialize other callbacks *)

  NewObjectCallback(GetTreePtr(RS232),RSCANCEL,DoRSCancel);

  (* attach popups *)

  PopupAttach(GetTreePtr(FORMAT),GetTreePtr(PGFORMAT),PGFORMATPARENT);
  PopupAttach(GetTreePtr(MSRUNIT),GetTreePtr(PGFORMAT),PGMSRUNITPARENT);
  PopupAttach(GetTreePtr(OUTPUTTO),GetTreePtr(PGFORMAT),PGOUTPUTTOPARENT);

  RETURN TRUE;
END RsrcLoadAction;

PROCEDURE RsrcFreeAction;
BEGIN
  (* deinitialize menu actions *)

  MyMenu:= GetTreePtr(MENU);

  DisposeMenuAction(MyMenu,IINFO);
  DisposeMenuAction(MyMenu,IHELP);
  DisposeMenuAction(MyMenu,IELL);
  DisposeMenuAction(MyMenu,IRS232);
  DisposeMenuAction(MyMenu,IFORMAT);
  DisposeMenuAction(MyMenu,IWARNING);
  DisposeMenuAction(MyMenu,IQUIT);

  (* deinitialize other callbacks *)

  DisposeObjectCallback(GetTreePtr(RS232),RSCANCEL);

END RsrcFreeAction;

BEGIN
  ApplId:= ApplInit();

  IF ApplId >= 0 THEN
    BeginUpdate;
    BusyMouse;

    AddRsrcLoad(RsrcLoadAction);
    AddRsrcFree(RsrcFreeAction);

    IF RsrcLoad(RscName) THEN
      IF OpenVirtualWorkstation(VirtScreen) THEN

        Register:="  XSample";
        VOID(MenuRegister(ApplId,Register));

        MyMenu:= GetTreePtr(MENU);
        ShowMenu(MyMenu);

        MyDesk:= GetTreePtr(DESK);
        OpenDesk(MyDesk,Root);

        VOID(GrafHandle(CharWidth,CharHeight,BoxWidth,BoxHeight));
        MinWidth:= 2 * BoxWidth;
        MinHeight:= 2 * BoxHeight;

        IF OpenWindow(MyWindow) THEN
          ArrowMouse;
          EndUpdate;

          WindGet.WorkXYWH(MyWindow,Work);
          WITH Work DO
            XEll:= GX;
            YEll:= GY;
            WEll:= GW;
            HEll:= GH;
          END;
          IF AES.Version() >= 0400H THEN
            VOID(ShelWrite(9,0001H,0,NULL,NULL)); (* inform AES about ApTerm *)
          END;

          EventLoop;

          CloseWindow(MyWindow);
        ELSE
          Alert(NOWIND);
        END;

        CloseDesk;
        HideMenu(MyMenu);
        CloseVirtualWorkstation(VirtScreen);
      ELSE
        Alert(NOVWORK);
      END;

      RsrcFree;
    ELSE
      ArrowMouse;
      EndUpdate;
    END;
    ApplExit;
  END;
END XSample.
