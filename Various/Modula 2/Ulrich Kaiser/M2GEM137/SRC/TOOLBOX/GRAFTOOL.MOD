IMPLEMENTATION MODULE GrafTool;

(*
Grafics Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES        IMPORT TreePtr,Selectable,Selected,ObjectState,Root,Nil,
                       ObjectPtr,ObjectIndex,IconBlkPtr;
FROM EvntMgr    IMPORT MEvent,EvntEvent,EvntMulti,evntevent,evntmulti,
                       MuButton,MuM1,MuTimer,Event,
                       MouseButton,MBLeft,MoExit;
FROM GrafMgr    IMPORT GrafMouse,MOn,MOff,UserDef,MFormPtr,MForm,
                       GrafRubberBox,GrafMKState,SpecialKey;
FROM ObjcMgr    IMPORT ObjcFind,ObjcChange;
FROM WindMgr    IMPORT WindUpdate,BegMCtrl,EndMCtrl,WindFind;
FROM RcMgr      IMPORT GRect,GPnt,RcConstrain,RcInside,Max,Min;
FROM VAttribute IMPORT VSWrMode,MdXOR,VSLColor,VSLUDSty,
                       VSLType,LTSolid,LTUserDef;
FROM VOutput    IMPORT XY,VPLine;
FROM ObjcTool   IMPORT DrawWindowObject,ObjectXYWH;
FROM VDITool    IMPORT OpenVWork,CloseVWork,GBoxToArray,GIconToArray;
FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD,NULL,WORDSET,ANYPOINTER;
FROM INTRINSIC  IMPORT INCPTR,PTR;
FROM pSTORAGE   IMPORT ALLOCATE,DEALLOCATE;
FROM SYSTEM     IMPORT TSIZE;
CAST_IMPORT

IMPORT VDI,SetObject,GetObject;

#if no_local_modules

#else
  MODULE MouseFormRoutines;

  IMPORT MFormPtr,MForm,UserDef,GrafMouse,NULL,
         MouseColors,MouseData,UNSIGNEDWORD,SIGNEDWORD,
         ALLOCATE,DEALLOCATE,MouseForms,TSIZE;

  EXPORT SetMouse,NewMouse,DisposeMouse,MouseForm,UserMouse,LastMouse;
#endif
  VAR ActualForm: UNSIGNEDWORD;
      LastForm  : UNSIGNEDWORD;

      ActualAddress: MFormPtr;
      LastAddress  : MFormPtr;

  PROCEDURE SetMouse(Number: UNSIGNEDWORD; Addr: MFormPtr);
  BEGIN
    LastForm:= ActualForm;
    LastAddress:= ActualAddress;

    ActualForm:= Number;
    ActualAddress:= Addr;

    IF (ActualForm # LastForm) OR (ActualAddress # LastAddress) THEN
      GrafMouse(Number,Addr);
    END;
  END SetMouse;

  PROCEDURE NewMouse(    XHotSpot  : UNSIGNEDWORD;
                         YHotSpot  : UNSIGNEDWORD;
                         ForeGround: MouseColors;
                         BackGround: MouseColors;
                     VAR Mask      : MouseData;
                     VAR Data      : MouseData): MFormPtr;

  VAR MyMouse: MFormPtr;
      i      : [0..15];

  BEGIN
    ALLOCATE(MyMouse,TSIZE(MForm));
    IF MyMouse # NIL THEN
      WITH MyMouse^ DO
        MFXHot:= XHotSpot;
        MFYHot:= YHotSpot;
        MFNPlanes:= 1;
        MFFG:= ForeGround;
        MFBG:= BackGround;
        FOR i:= 0 TO 15 DO
          MFMask[i]:= Mask[i];
          MFData[i]:= Data[i];
        END;
      END;
      SetMouse(UserDef,MyMouse);
    END;
    RETURN MyMouse;
  END NewMouse;

  PROCEDURE DisposeMouse(VAR Form: MFormPtr);
  BEGIN
    DEALLOCATE(Form,TSIZE(MForm));
  END DisposeMouse;

  PROCEDURE UserMouse(UserDefForm: MFormPtr);
  BEGIN
    SetMouse(UserDef,UserDefForm);
  END UserMouse;

  PROCEDURE MouseForm(Form: MouseForms);
  BEGIN
    SetMouse(ORD(Form),NULL);
  END MouseForm;

  PROCEDURE LastMouse;
  BEGIN
    SetMouse(LastForm,LastAddress);
  END LastMouse;
#if no_local_modules

#else
  BEGIN
    ActualAddress:= NULL;
    LastAddress:= NULL;

    ActualForm:= ORD(Arrow);
    LastForm:= ORD(Arrow);
  END MouseFormRoutines;

  MODULE ShowAndHideMouse;

  IMPORT GrafMouse,MOn,MOff,NULL;
  EXPORT ShowMouse,HideMouse;
#endif
  VAR Hidden: BOOLEAN;

  PROCEDURE ShowMouse;
  BEGIN
    IF Hidden THEN
      GrafMouse(MOn,NULL);
    END;
    Hidden:= FALSE;
  END ShowMouse;

  PROCEDURE HideMouse;
  BEGIN
    IF NOT Hidden THEN
      GrafMouse(MOff,NULL);
    END;
    Hidden:= TRUE;
  END HideMouse;
#if no_local_modules

#else
  BEGIN
    Hidden:= FALSE;
  END ShowAndHideMouse;

  MODULE BusyOrArrow;

  IMPORT BusyBee,Arrow,MouseForm;
  EXPORT BusyMouse,ArrowMouse;
#endif
  PROCEDURE BusyMouse;
  BEGIN
    MouseForm(BusyBee);
  END BusyMouse;

  PROCEDURE ArrowMouse;
  BEGIN
    MouseForm(Arrow);
  END ArrowMouse;
#if no_local_modules

#else
  END BusyOrArrow;
#endif

PROCEDURE GetMouse(VAR Pos: GPnt);

VAR MState: MouseButton;
    KState: SpecialKey;

BEGIN
  GrafMKState(Pos,MState,KState);
END GetMouse;

PROCEDURE RubberBox(Start: GPnt; VAR Box: GRect);
BEGIN
  Box.GX:= Start.GX;
  Box.GY:= Start.GY;

  MouseForm(PointingHand);
  GrafRubberBox(Start,-32767,-32767,Box.GW,Box.GH); (* works with PC-GEM too *)
  LastMouse;

  WITH Box DO
   IF GW < 0 THEN
     INC(GX,GW);
     GW:= -GW;
   END;
   IF GH < 0 THEN
     INC(GY,GH);
     GH:= -GH;
   END;
 END;
END RubberBox;

(*
PROCEDURE GrafRubberBox(VAR StartPos   : GPnt;
                            StartWidth : SIGNEDWORD;
                            StartHeight: SIGNEDWORD;
                        VAR LastWidth  : SIGNEDWORD;
                        VAR LastHeight : SIGNEDWORD);

VAR Box: GRect;

BEGIN
  RubberBox(StartPos,Box);
  StartPos.GX:= Box.GX;
  StartPos.GY:= Box.GY;
  LastWidth:= Box.GW;
  LastHeight:= Box.GH;
END GrafRubberBox;
*)

#if no_local_modules

#else
  MODULE Dragging;

  IMPORT TreePtr,Selectable,Selected,ObjectState,Root,Nil,ObjectPtr,
         ObjectIndex,IconBlkPtr,
         MEvent,EvntEvent,EvntMulti,MuButton,MuM1,MuTimer,Event,
         MouseButton,MBLeft,MoExit,evntevent,evntmulti,
         ObjcFind,ObjcChange,
         WindUpdate,BegMCtrl,EndMCtrl,WindFind,
         GRect,GPnt,RcConstrain,RcInside,Max,Min,
         VSWrMode,MdXOR,VSLColor,VSLUDSty,VSLType,LTSolid,LTUserDef,
         XY,VPLine,
         DrawWindowObject,ObjectXYWH,
         OpenVWork,CloseVWork,GBoxToArray,GIconToArray,
         UNSIGNEDWORD,SIGNEDWORD,WORDSET,ANYPOINTER,
         INCPTR,PTR,
#if (defined MM2) || (defined HM2) || (defined GPM2)
         CAST,
#endif
         ShowMouse,HideMouse,GetMouse,
         VDI,SetObject,GetObject;

  EXPORT HotDragBox,HotDragIcon;
#endif
  TYPE HoriTableArray = ARRAY[0..1] OF UNSIGNEDWORD;
       VertTableArray = ARRAY[0..3] OF UNSIGNEDWORD;
#if constructor
  CONST HoriTable = HoriTableArray{05555H,0AAAAH};
        VertTable = VertTableArray{05555H,0AAAAH,0AAAAH,05555H};
#else
  VAR HoriTable: HoriTableArray;
      VertTable: VertTableArray;
#endif
  PROCEDURE VDIXLine(Handle: UNSIGNEDWORD; PtsCount: UNSIGNEDWORD; VAR Points: ARRAY OF XY);

  VAR Style : UNSIGNEDWORD;
      i     : UNSIGNEDWORD;
      x     : UNSIGNEDWORD;
      LineXY: XY;
      Line  : ARRAY[0..3] OF XY;
      PLine : POINTER TO ARRAY[0..3] OF XY;
#ifdef MM2
      Index : WORDSET;
#endif

  BEGIN
    x:= 0;

    (*
    PLine:= PTR(Points);
    *)

    FOR i:= 1 TO (PtsCount - 1) DO
    (*IF PLine^[0] = PLine^[2] THEN*)
      IF Points[x] = Points[x+2] THEN
#ifdef HM2
        Style:= VertTable[CAST(UNSIGNEDWORD,VAL(WORDSET,ORD(ODD(Points[x]))) +
                                            VAL(WORDSET,(ORD(ODD(Points[x+1]))*2)))];
#elif (defined MM2)
        Index:= CAST(WORDSET,ORD(ODD(Points[x]))) +
                CAST(WORDSET,(ORD(ODD(Points[x+1]))*2));

        Style:= VertTable[CAST(UNSIGNEDWORD,Index)];
#else
        Style:= VertTable[CAST(UNSIGNEDWORD,CAST(WORDSET,ORD(ODD(Points[x]))) +
                                            CAST(WORDSET,(ORD(ODD(Points[x+1]))*2)))];
#endif
      ELSE
        IF Points[x] < Points[x+2] THEN
      (*IF PLine^[0] < PLine^[2] THEN*)
          Style:= HoriTable[ORD(ODD(Points[x+1]))];
        ELSE
          Style:= HoriTable[ORD(ODD(Points[x+3]))];
        END;
      END;

      VSLUDSty(Handle,Style);
      VSLType(Handle,LTUserDef);
      Line[0]:= Points[x];
      Line[1]:= Points[x+1];
      Line[2]:= Points[x+2];
      Line[3]:= Points[x+3];
      VPLine(Handle,2,Line);
    (*VPLine(Handle,2,Points^);*)
      INC(x,2); (*INCPTR(PLine,4 (* 2 * TSIZE(XY) *) );*)
    END;

    VSLType(Handle,LTSolid);
  END VDIXLine;

  PROCEDURE HotDragBox(VAR Pos  : GPnt;
                           Tree : TreePtr;
                           Ob   : ObjectIndex;
                           Limit: GRect): ObjectPtr;

  CONST DeltaX = 3; (* you may use 1 if you like *)
        DeltaY = 3; (* you may use 1 if you like *)

  VAR Handle : UNSIGNEDWORD;
      Window : SIGNEDWORD;
      PXY    : ARRAY[0..9] OF XY;
      Which  : Event;
      MyEvent: MEvent;
      Dummy  : BOOLEAN;
      Box    : GRect;
      OldXY  : GPnt;
      HotOb  : ObjectPtr;
      Return : ObjectPtr;

    PROCEDURE ToggleObject(Tree  : TreePtr;
                           Index : ObjectIndex);
                         (*Window: SIGNEDWORD);*)
    VAR Rect: GRect;

    BEGIN
      SetObject.State(Tree,
                      Index,
                      GetObject.State(Tree,Index) / ObjectState{Selected});
      DrawWindowObject(Window,Tree,Index);
    END ToggleObject;

  BEGIN
    HotOb:= Nil;

    ObjectXYWH(Tree,Ob,Box);

    IF OpenVWork(Handle) THEN
      VSWrMode(Handle,MdXOR);
      VSLColor(Handle,VDI.Black);

      Dummy:= WindUpdate(BegMCtrl);

      MyEvent.EMXY:= Pos; (* initialise with actual position *)

      Window:= WindFind(Pos);

      WITH OldXY DO
        GX:= Min(Box.GW,Max(0,MyEvent.EMXY.GX - Box.GX));
        GY:= Min(Box.GH,Max(0,MyEvent.EMXY.GY - Box.GY));
      END;

      WITH MyEvent DO
(*
        EFlags:= Event{MuButton,MuM1};
        EBClk:= 1;
        EBMsk:= MouseButton{MBLeft};
        EBSt:= MouseButton{};
        EM1Flags:= MoExit;
*)
        EM1.GX:= EMXY.GX;
        EM1.GY:= EMXY.GY;
        EM1.GW:= DeltaX;
        EM1.GH:= DeltaY;
      END;

      Which:= Event{MuM1}; (* initialise for first drawing *)

      REPEAT
        WITH Box DO
          GX:= MyEvent.EMXY.GX - OldXY.GX;
          GY:= MyEvent.EMXY.GY - OldXY.GY;
        END;

        RcConstrain(Limit,Box); (* lock into limit rect *)

        IF (MuM1 IN Which) THEN
          HideMouse;
          GBoxToArray(Box,PXY);
          VDIXLine(Handle,5,PXY);
          ShowMouse;
        END;

(*
        Which:= evntmulti(Event{MuButton,MuM1},
                          1,
                          MouseButton{MBLeft},
                          MouseButton{},
                          MoExit,
                          MyEvent.EM1,
                          MoExit,
                          MyEvent.EM2,
                          MyEvent.EMePBuf,
                          0,
                          0,
                          MyEvent.EMXY,
                          MyEvent.EMB,
                          MyEvent.EKS,
                          MyEvent.EKR,
                          MyEvent.EBR);
*)
        WITH MyEvent DO
          Which:= evntmulti(Event{MuButton,MuM1},
                            1,
                            MouseButton{MBLeft},
                            MouseButton{},
                            MoExit,
                            EM1,
                            MoExit,
                            EM2,
                            EMePBuf,
                            0,
                            0,
                            EMXY,EMB,EKS,EKR,EBR);
        END;

(*
  does not work with HM2 and TDIM2 - nobody knows why

        Which:= evntevent(MyEvent);
*)
        WITH MyEvent DO
          EM1.GX:= EMXY.GX;
          EM1.GY:= EMXY.GY;
        END;

        IF (MuM1 IN Which) THEN
          HideMouse;
          GBoxToArray(Box,PXY);
          VDIXLine(Handle,5,PXY);
          ShowMouse;
        END;

        IF NOT RcInside(MyEvent.EMXY,Limit) THEN
          Return:= Nil;
        ELSE
          Return:= ObjcFind(Tree,Root,1,MyEvent.EMXY);

          IF Return # Nil THEN
            IF NOT(Selectable IN GetObject.Flags(Tree,Return)) THEN
              Return:= Nil;
            END;
          END;
        END;

        IF Return # HotOb THEN

          IF (HotOb # Nil) THEN
            ToggleObject(Tree,HotOb);
          END;

          HotOb:= Return;

          IF (HotOb # Nil) THEN
            IF NOT(Selected IN GetObject.State(Tree,HotOb)) THEN
              ToggleObject(Tree,HotOb);
            END;
          END;

        END;

      UNTIL (MuButton IN Which); (* until button up *)

      Dummy:= WindUpdate(EndMCtrl); (* release mouse to GEM *)

      IF (HotOb # Nil) AND
          NOT(Selected IN GetObject.State(Tree,Return)) THEN
        ToggleObject(Tree,HotOb);
      END;

      IF NOT(MuM1 IN Which) THEN
        HideMouse;
        GBoxToArray(Box,PXY);
        VDIXLine(Handle,5,PXY);
        ShowMouse;
      END;

      Pos.GX:= Box.GX;
      Pos.GY:= Box.GY;

      CloseVWork(Handle);
    END;

    RETURN HotOb;
  END HotDragBox;

  PROCEDURE HotDragIcon(VAR Pos  : GPnt;
                            Tree : TreePtr;
                            Ob   : ObjectIndex;
                            Limit: GRect): ObjectPtr;

  CONST DeltaX = 3; (* you may use 1 if you like *)
        DeltaY = 3; (* you may use 1 if you like *)

  VAR Handle : UNSIGNEDWORD;
      Window : SIGNEDWORD;
      PXY    : ARRAY[0..17] OF XY;
      Which  : Event;
      MyEvent: MEvent;
      Dummy  : BOOLEAN;
      Box    : GRect;
      OldXY  : GPnt;
      HotOb  : ObjectPtr;
      Return : ObjectPtr;
      IconDes: ANYPOINTER;

    PROCEDURE ToggleObject(Tree  : TreePtr;
                           Index : ObjectIndex);
                         (*Window: SIGNEDWORD);*)
    VAR Rect: GRect;

    BEGIN
      SetObject.State(Tree,
                      Index,
                      GetObject.State(Tree,Index) / ObjectState{Selected});
      DrawWindowObject(Window,Tree,Index);
    END ToggleObject;

  BEGIN
    HotOb:= Nil;

    ObjectXYWH(Tree,Ob,Box);
    IconDes:= GetObject.Spec(Tree,Ob);

    IF OpenVWork(Handle) THEN
      VSWrMode(Handle,MdXOR);
      VSLColor(Handle,VDI.Black);

      Dummy:= WindUpdate(BegMCtrl);

      MyEvent.EMXY:= Pos; (* initialise with actual position *)

      Window:= WindFind(Pos);

      WITH OldXY DO
        GX:= Min(Box.GW,Max(0,MyEvent.EMXY.GX - Box.GX));
        GY:= Min(Box.GH,Max(0,MyEvent.EMXY.GY - Box.GY));
      END;

      WITH MyEvent DO
(*
        EFlags:= Event{MuButton,MuM1};
        EBClk:= 1;
        EBMsk:= MouseButton{MBLeft};
        EBSt:= MouseButton{};
        EM1Flags:= MoExit;
*)
        EM1.GX:= EMXY.GX;
        EM1.GY:= EMXY.GY;
        EM1.GW:= DeltaX;
        EM1.GH:= DeltaY;
      END;

      Which:= Event{MuM1}; (* initialise for first drawing *)

      REPEAT
        WITH Box DO
          GX:= MyEvent.EMXY.GX - OldXY.GX;
          GY:= MyEvent.EMXY.GY - OldXY.GY;
        END;

        RcConstrain(Limit,Box); (* lock into limit rect *)

        IF (MuM1 IN Which) THEN
          HideMouse;
          GIconToArray(IconDes,Box.GX,Box.GY,PXY);
          VDIXLine(Handle,9,PXY);
          ShowMouse;
        END;

(*
        Which:= evntmulti(Event{MuButton,MuM1},
                          1,
                          MouseButton{MBLeft},
                          MouseButton{},
                          MoExit,
                          MyEvent.EM1,
                          MoExit,
                          MyEvent.EM2,
                          MyEvent.EMePBuf,
                          0,
                          0,
                          MyEvent.EMXY,
                          MyEvent.EMB,
                          MyEvent.EKS,
                          MyEvent.EKR,
                          MyEvent.EBR);
*)
        WITH MyEvent DO
          Which:= evntmulti(Event{MuButton,MuM1},
                            1,
                            MouseButton{MBLeft},
                            MouseButton{},
                            MoExit,
                            EM1,
                            MoExit,
                            EM2,
                            EMePBuf,
                            0,
                            0,
                            EMXY,EMB,EKS,EKR,EBR);
        END;

(*
  does not work with HM2 and TDIM2 - nobody knows why

        Which:= evntevent(MyEvent);
*)
        WITH MyEvent DO
          EM1.GX:= EMXY.GX;
          EM1.GY:= EMXY.GY;
        END;

        IF (MuM1 IN Which) THEN
          HideMouse;
          GIconToArray(IconDes,Box.GX,Box.GY,PXY);
          VDIXLine(Handle,9,PXY);
          ShowMouse;
        END;

        IF NOT RcInside(MyEvent.EMXY,Limit) THEN
          Return:= Nil;
        ELSE
          Return:= ObjcFind(Tree,Root,1,MyEvent.EMXY);

          IF Return # Nil THEN
            IF NOT(Selectable IN GetObject.Flags(Tree,Return)) THEN
              Return:= Nil;
            END;
          END;
        END;

        IF Return # HotOb THEN

          IF (HotOb # Nil) THEN
            ToggleObject(Tree,HotOb);
          END;

          HotOb:= Return;

          IF (HotOb # Nil) THEN
            IF NOT(Selected IN GetObject.State(Tree,HotOb)) THEN
              ToggleObject(Tree,HotOb);
            END;
          END;

        END;

      UNTIL (MuButton IN Which); (* until button up *)

      Dummy:= WindUpdate(EndMCtrl); (* release mouse to GEM *)

      IF (HotOb # Nil) AND
          NOT(Selected IN GetObject.State(Tree,Return)) THEN
        ToggleObject(Tree,HotOb);
      END;

      IF NOT(MuM1 IN Which) THEN
        HideMouse;
        GIconToArray(IconDes,Box.GX,Box.GY,PXY);
        VDIXLine(Handle,9,PXY);
        ShowMouse;
      END;

      Pos.GX:= Box.GX;
      Pos.GY:= Box.GY;

      CloseVWork(Handle);
    END;

    RETURN HotOb;
  END HotDragIcon;

#if no_local_modules

#else
#if not constructor
  BEGIN
    HoriTable[0]:= 05555H;
    HoriTable[1]:= 0AAAAH;
    VertTable[0]:= 05555H;
    VertTable[1]:= 0AAAAH;
    VertTable[2]:= 0AAAAH;
    VertTable[3]:= 05555H;
#endif
  END Dragging;
#endif

#if no_local_modules
BEGIN
  (* from local module MouseFormRoutines *)

  ActualAddress:= NULL;
  LastAddress:= NULL;

  ActualForm:= ORD(Arrow);
  LastForm:= ORD(Arrow);

  (* from local module ShowAndHideMouse *)

  Hidden:= FALSE;

  (* from local module Dragging *)
#if not constructor
  HoriTable[0]:= 05555H;
  HoriTable[1]:= 0AAAAH;
  VertTable[0]:= 05555H;
  VertTable[1]:= 0AAAAH;
  VertTable[2]:= 0AAAAH;
  VertTable[3]:= 05555H;
#endif

#endif
END GrafTool.