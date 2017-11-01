(***************************************************************************)
(* GEM sample application                                                  *)
(* adapted from apskel.c by Ron Zdybl, Atari Corp.                         *)
(*                                                                         *)
(* UK 08/08/1994                                                           *)
(***************************************************************************)

MODULE Sample;

FROM AES        IMPORT Root,ObjectIndex,TreeIndex,TreePtr,
                       StringPtr,ObjectState,Selected,Checked,State15;
FROM ApplMgr    IMPORT ApplInit,ApplExit,ApplWrite;
FROM EvntMgr    IMPORT EvntEvent,MEvent,MuMesag,Event,MessageBlock,
                       WMRedraw,WMNewTop,WMTopped,WMSized,WMMoved,
                       WMFulled,WMClosed,MnSelected;
FROM FormMgr    IMPORT FmDStart,FmDGrow,FmDShrink,FmDFinish,FormDial,
                       FormCenter,FormDo;
FROM ObjcMgr    IMPORT ObjcDraw,MaxDepth,ObjcOffset,ObjcFind,ObjcChange;
FROM MenuMgr    IMPORT MenuBar,MenuText,MenuTNormal,MenuICheck;
FROM GrafMgr    IMPORT GrafHandle,GrafGrowBox,GrafShrinkBox;
FROM RsrcMgr    IMPORT RsrcLoad,RsrcFree;
FROM WindMgr    IMPORT NoWindow,Desk,WindCreate,WindOpen,WindClose,
                       WindDelete,WindCalc,WCBorder,WCWork,
                       WindowFeature,WindowFeatures;
FROM RcMgr      IMPORT GRect,GPnt,RcIntersect,RcEqual;
FROM ObjcTool   IMPORT ObjectXYWH,INCLObjectState,EXCLObjectState;
FROM FormTool   IMPORT OK,Alert,Mask;
FROM RsrcTool   IMPORT GetTreePtr,GetStringPtr;
FROM GrafTool   IMPORT ShowMouse,HideMouse,BusyMouse,ArrowMouse;
FROM WindTool   IMPORT BeginUpdate,EndUpdate,
                       BeginMouseControl,EndMouseControl;
FROM VDI        IMPORT XY,White,Black;
FROM VAttribute IMPORT VSFInterior,FISPattern,VSFStyle,VSFColor;
FROM VOutput    IMPORT VBar,VEllipse;
FROM VDITool    IMPORT OpenVirtualWorkstation,CloseVirtualWorkstation,
                       SetClip,GRectToArray;
FROM INTRINSIC  IMPORT VOID,PTR;
FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYWORD;

IMPORT SetObject,GetObject,WindSet,WindGet;

(* Resource Indices *)

CONST

    MENU     =   0;    (* Menuebaum *)
    TINFO    =   3;    (* TITLE in Baum MENU *)
    TFILE    =   4;    (* TITLE in Baum MENU *)
    TEDIT    =   5;    (* TITLE in Baum MENU *)
    TOPTION  =   6;    (* TITLE in Baum MENU *)
    IINFO    =   9;    (* STRING in Baum MENU *)
    INEW     =  18;    (* STRING in Baum MENU *)
    IABORT   =  24;    (* STRING in Baum MENU *)
    IQUIT    =  27;    (* STRING in Baum MENU *)
    ICUT     =  31;    (* STRING in Baum MENU *)
    ICOPY    =  32;    (* STRING in Baum MENU *)
    IPASTE   =  33;    (* STRING in Baum MENU *)
    IWARNING =  37;    (* STRING in Baum MENU *)
    IHELP    =  38;    (* STRING in Baum MENU *)
    IOPTSAVE =  40;    (* STRING in Baum MENU *)

    INFO     =   1;    (* Formular/Dialog *)
    INFOK    =   1;    (* BUTTON in Baum INFO *)

    WNAME    =   0;    (* Freier String *)

    WINFO    =   1;    (* Freier String *)

    HELPON   =   2;    (* Freier String *)

    HELPOFF  =   3;    (* Freier String *)

    NOWIND   =   4;    (* Alert String *)

    NOVWORK  =   5;    (* Alert String *)

    QUIT     =   6;    (* Alert String *)

PROCEDURE MAIN;

CONST RscName   = "SAMPLE.RSC";
      MyFeature = WindowFeature{Name,Close,Full,Move,Info,Size};

VAR ApplId    : SIGNEDWORD;
    VirtScreen: UNSIGNEDWORD;
    MyMenu    : TreePtr;
    MyName    : StringPtr;
    MyInfo    : StringPtr;
    HelpItem  : StringPtr;
    MyWindow  : SIGNEDWORD;
    Work      : GRect;
    XEll      : UNSIGNEDWORD;
    YEll      : UNSIGNEDWORD;
    WEll      : UNSIGNEDWORD;
    HEll      : UNSIGNEDWORD;
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

      MyName:= GetStringPtr(WNAME);
      WindSet.Name(Window,MyName^);

      MyInfo:= GetStringPtr(WINFO);
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

  PROCEDURE DoRedraw(Window: SIGNEDWORD; VAR Clip: GRect);

  VAR Rect: GRect;

    PROCEDURE DrawSample(Handle: UNSIGNEDWORD);

    VAR Points: ARRAY[0..3] OF XY;
        Work  : GRect;

    BEGIN
      VSFInterior(Handle,FISPattern);
      VSFStyle(Handle,8);
      VSFColor(Handle,White);
      WindGet.WorkXYWH(MyWindow,Work);
      GRectToArray(Work,Points);
      VBar(Handle,Points);

      XEll:= Work.GX;
      YEll:= Work.GY;
      VSFInterior(Handle,FISPattern);
      VSFStyle(Handle,8);
      VSFColor(Handle,Black);
      VEllipse(Handle,XEll + WEll DIV 2,YEll + HEll DIV 2,
                      WEll DIV 2,HEll DIV 2);
    END DrawSample;

  BEGIN
    HideMouse;
    BeginUpdate;

    WindGet.FirstXYWH(Window,Rect);

    WITH Rect DO
      WHILE (GW # 0) AND (GH # 0) DO
        IF RcIntersect(Clip,Rect) THEN
          SetClip(VirtScreen,Rect);
          DrawSample(VirtScreen);
        END;
        WindGet.NextXYWH(Window,Rect);
      END;
    END;

    EndUpdate;
    ShowMouse;
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

  PROCEDURE DoMenu(Title: ObjectIndex; Item: ObjectIndex);

  VAR Box : GRect;

    PROCEDURE DoForm(    TreeNo: TreeIndex;
                         Start : ObjectIndex;
                     VAR From  : GRect): ObjectIndex;

    VAR Tree  : TreePtr;
        To    : GRect;
        Return: SIGNEDWORD;

    BEGIN
      BeginUpdate;
      Tree:= GetTreePtr(TreeNo);
      FormCenter(Tree,To);
      FormDial(FmDStart,To,To);
      FormDial(FmDGrow,From,To);
      ObjcDraw(Tree,Root,MaxDepth,To);
      Return:= Mask(FormDo(Tree,Start));
      ObjcChange(Tree,Return,1,To,
                 GetObject.State(Tree,Return) - ObjectState{Selected},
                 FALSE);
      FormDial(FmDShrink,From,To);
      FormDial(FmDFinish,To,To);
      EndUpdate;
      RETURN Return;
    END DoForm;

  BEGIN
    ArrowMouse;
    CASE Title OF
      TINFO:
        CASE Item OF
          IINFO:
            ObjectXYWH(MyMenu,TINFO,Box);
            VOID(DoForm(INFO,0,Box));
        ELSE
          ;
        END;
    | TFILE:
        ;
    | TEDIT:
        ;
    | TOPTION:
        CASE Item OF
          IWARNING:
             MenuICheck(MyMenu,IWARNING,NOT(Checked IN GetObject.State(MyMenu,IWARNING)));
        | IHELP:
            IF State15 IN GetObject.State(MyMenu,IHELP) THEN
              HelpItem:= GetStringPtr(HELPOFF);
              EXCLObjectState(MyMenu,IHELP,State15);
            ELSE
              HelpItem:= GetStringPtr(HELPON);
              INCLObjectState(MyMenu,IHELP,State15);
            END;
            MenuText(MyMenu,IHELP,HelpItem^);
        ELSE
          ;
        END;
        ;
    ELSE
      ;
    END;
    MenuTNormal(MyMenu,Title,TRUE);
  END DoMenu;

  PROCEDURE EventLoop;

  VAR EventBlock: MEvent;
      MyEvent   : Event;
      MyMessage : MessageBlock;

  BEGIN
    WITH EventBlock DO
      EFlags:= Event{MuMesag};
      EMePBuf:= PTR(MyMessage);

      WITH MyMessage DO
        LOOP
          MyEvent:= EvntEvent(EventBlock);

          IF MuMesag IN MyEvent THEN
            CASE Type OF
              WMRedraw:
                DoRedraw(Handle,Rect);
            | WMNewTop:
                WindSet.Top(Handle);
            | WMTopped:
                WindSet.Top(Handle);
            | WMSized:
                DoSize(Handle,Rect);
            | WMMoved:
                WindSet.CurrXYWH(Handle,Rect);
            | WMFulled:
                DoFull(Handle);
            | WMClosed:
                DoClose(Handle);
            | MnSelected:
                IF Item = IQUIT THEN
                  IF OK(QUIT) THEN
                    EXIT;
                  END;
                ELSE
                  DoMenu(Title,Item);
                END;
            ELSE
              ;
            END;
          END;

        END;
      END;
    END;
  END EventLoop;

BEGIN
  ApplId:= ApplInit();

  IF ApplId < 0 THEN
    RETURN;
  END;

  BeginUpdate;
  BusyMouse;

  IF RsrcLoad(RscName) THEN
    IF OpenVirtualWorkstation(VirtScreen) THEN
      MyMenu:= GetTreePtr(MENU);
      VOID(MenuBar(MyMenu,1));

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

        EventLoop;

        CloseWindow(MyWindow);
      ELSE
        Alert(NOWIND);
      END;
      VOID(MenuBar(MyMenu,0));
      CloseVirtualWorkstation(VirtScreen);
    ELSE
      Alert(NOVWORK);
    END;
    RsrcFree;
  ELSE
    EndUpdate;
    ArrowMouse;
  END;
  ApplExit;
END MAIN;

BEGIN
  MAIN;
END Sample.