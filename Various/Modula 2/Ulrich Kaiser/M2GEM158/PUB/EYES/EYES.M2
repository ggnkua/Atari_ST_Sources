MODULE Eyes;

(*
This  is  a  simple  eyes  accessory.  It  has been written by means of the
crystal   library   (m2gem???.lzh).   This   library   may   be   found  at
atari.archive.umich.edu,     directory   programming,   or   uni-kl.de   or
cs.tu-berlin.de, directory pub/atari/Programming/Modula-2.

improvements:
- avoid mouse flacker

UK 08/14/95
*)

FROM ApplMgr    IMPORT ApplInit;
FROM MenuMgr    IMPORT MenuRegister;
FROM EvntMgr    IMPORT EvntEvent,MEvent,Event,MessageBlock,MuMesag,MuTimer,
                       WMRedraw,WMTopped,WMClosed,WMMoved,WMBottomed,
                       AcOpen,AcClose;
FROM WindMgr    IMPORT WindCreate,Wind,Name,Close,Move,
                       WindOpen,WindClose,WindDelete,NoWindow,Desk;
FROM RcMgr      IMPORT GRect,GPnt,RcIntersect;
FROM GrafTool   IMPORT ShowMouse,HideMouse,GetMouse;
FROM WindTool   IMPORT BeginUpdate,EndUpdate;
FROM VDI        IMPORT XY,White,Black;
FROM VOutput    IMPORT VRRecFl,VCircle,VEllipse;
FROM VAttribute IMPORT VSWrMode,MdReplace,
                       VSFColor,VSFPerimeter,VSFInterior,Interiors;
FROM VDITool    IMPORT SetClip,OpenVirtualWorkstation,CloseVirtualWorkstation,
                       GRectToArray;
FROM PORTAB     IMPORT SIGNEDWORD,UNSIGNEDWORD,UNSIGNEDLONG,SIGNEDLONG;
FROM INTRINSIC  IMPORT VOID,PTR;
FROM pMATHLIB   IMPORT sqrt,realtoword,wordtoreal;

IMPORT WindGet,WindSet;

TYPE RedrawFlags = (All,EyesOnly);

VAR ApplId   : SIGNEDWORD;
    MenuId   : SIGNEDWORD;
    AccName  : ARRAY[0..8] OF CHAR;
    WinName  : ARRAY[0..6] OF CHAR;
    MyBlock  : MEvent;
    MyEvent  : Event;
    MyMessage: MessageBlock;
    MyWindow : SIGNEDWORD;
    OldPos   : GPnt;
    LastRect : GRect;
    GC       : UNSIGNEDWORD;

PROCEDURE DrawEyes(Redraw: RedrawFlags);

VAR Work     : GRect;
    Rect     : GRect;
    MouseRect: GRect;
    MousePos : GPnt;
    Clip     : ARRAY[0..3] OF XY;
    Hidden   : BOOLEAN;

  PROCEDURE Pupils(MXY: GPnt;
                   OX : SIGNEDWORD;
                   OY : SIGNEDWORD);

  VAR X,Y,Z,F1,F2: REAL;

  BEGIN
    WITH Work DO
      X:= wordtoreal(MXY.GX - (GX + OX));
      Y:= wordtoreal(MXY.GY - (GY + OY));
      Z:= sqrt(X * X + Y * Y);

      IF Z # 0.0 THEN
        F1:= 9.0 * X / Z;
        F2:= 19.0 * Y / Z;
      ELSE
        F1:= 0.0;
        F2:= 0.0;
      END;

      VCircle(GC,GX + OX + realtoword(F1),GY + OY + realtoword(F2),10);
    END;
  END Pupils;

  PROCEDURE SetFill(Color    : UNSIGNEDWORD;
                    Perimeter: BOOLEAN;
                    Interior : Interiors);
  BEGIN
    VSFColor(GC,Color);
    VSFPerimeter(GC,Perimeter);
    VSFInterior(GC,Interior);
  END SetFill;

  PROCEDURE DrawPupils;
  BEGIN
    SetFill(White,FALSE,FISSolid);
    Pupils(OldPos,25,40);
    Pupils(OldPos,Work.GW - 25,40);
    SetFill(Black,FALSE,FISSolid);
    Pupils(MousePos,25,40);
    Pupils(MousePos,Work.GW - 25,40);
  END DrawPupils;

BEGIN
  IF MyWindow = NoWindow THEN
    RETURN;
  END;

  (* initialisations for mouse hiding *)

  Hidden:= FALSE;
  MouseRect.GW:= 63; MouseRect.GH:= 31;

  BeginUpdate; (* lock screen *)

  WindGet.WorkXYWH(MyWindow,Work);
  WindGet.FirstXYWH(MyWindow,Rect);

  WHILE (Rect.GW > 0) AND (Rect.GH > 0) DO
    IF RcIntersect(Work,Rect) THEN
      SetClip(GC,Rect);
      IF Redraw = All THEN
        SetFill(White,FALSE,FISSolid);
        GRectToArray(Rect,Clip);
        HideMouse;
        VRRecFl(GC,Clip);
        SetFill(Black,TRUE,FISHollow);
        VEllipse(GC,Work.GX + 25,Work.GY + 40,20,35);
        VEllipse(GC,Work.GX + Work.GW - 25,Work.GY + 40,20,35);
        ShowMouse;
      END;

      GetMouse(MousePos);
      IF (MousePos.GX # OldPos.GX) OR (MousePos.GY # OldPos.GY) OR
         (Redraw = All) THEN
        MouseRect.GX:= MousePos.GX - 31; (* results < 0 do not seem to hurt *)
        MouseRect.GY:= MousePos.GY - 15;
        IF RcIntersect(MouseRect,Rect) THEN
          Hidden:= TRUE;
          HideMouse;
        END;
        DrawPupils;
        IF Hidden THEN
          ShowMouse;
          Hidden:= FALSE;
        END;
      END;

      WindGet.NextXYWH(MyWindow,Rect);
    END;
  END;

  EndUpdate; (* unlock screen *)

  OldPos:= MousePos;
END DrawEyes;

PROCEDURE DoRedraw(Handle: SIGNEDWORD);
BEGIN
  IF Handle = MyWindow THEN
    DrawEyes(All);
  END;
END DoRedraw;

PROCEDURE DoTopped(Handle: SIGNEDWORD);
BEGIN
  IF Handle = MyWindow THEN
    WindSet.Top(Handle);
  END;
END DoTopped;

PROCEDURE DoBottomed(Handle: SIGNEDWORD);
BEGIN
  IF Handle = MyWindow THEN
    WindSet.Bottom(Handle);
  END;
END DoBottomed;

PROCEDURE DoMoved(Handle: SIGNEDWORD; VAR Rectangle: GRect);
BEGIN
  IF Handle = MyWindow THEN
    WindSet.CurrXYWH(Handle,Rectangle);
    LastRect.GX:= Rectangle.GX;
    LastRect.GY:= Rectangle.GY;
    DrawEyes(All);
  END;
END DoMoved;

PROCEDURE DoClose(Handle: SIGNEDWORD);
BEGIN
  IF Handle = MyWindow THEN
    WindClose(Handle);
    WindDelete(Handle);
    MyWindow:= NoWindow;
    MyBlock.EFlags:= Event{MuMesag};
  END;
END DoClose;

PROCEDURE DoAcOpen(Id: SIGNEDWORD);

VAR Full: GRect;
    Pos : GPnt;

BEGIN
  IF (Id = MenuId) AND (GC > 0) THEN
    IF MyWindow # NoWindow THEN
      WindSet.Top(MyWindow);
    ELSE
      (*
      IF GC = 0 THEN
        BeginUpdate;
        IF NOT OpenVirtualWorkstation(GC) THEN
          EndUpdate;
          RETURN;
        END;
        EndUpdate;
        VSWrMode(GC,MdReplace);
      END;
      *)
      WindGet.WorkXYWH(Desk,Full);
      MyWindow:= WindCreate(Wind{Name,Close,Move},Full);

      IF MyWindow = NoWindow THEN
        (*
        IF GC > 0 THEN
          CloseVirtualWorkstation(GC); (* means GC:= 0 *)
        END;
        *)
        RETURN;
      END;

      WinName:= " Eyes ";
      WindSet.Name(MyWindow,WinName);

      IF LastRect.GY = -1 THEN
        GetMouse(Pos);
        LastRect.GX:= Pos.GX;
        LastRect.GY:= Pos.GY;
      END;

      LastRect.GW:= 100;
      LastRect.GH:= 100;

      WindOpen(MyWindow,LastRect);
    END;

    MyBlock.EFlags:= Event{MuMesag,MuTimer};
  END;
END DoAcOpen;

PROCEDURE DoAcClose(Id: SIGNEDWORD);
BEGIN
  IF Id = MenuId THEN
    (*
    IF GC > 0 THEN
      CloseVirtualWorkstation(GC); (* means GC:= 0 *)
    END;
    *)
    (* seems to be not necessary:
    WindClose(MyWindow);
    WindDelete(MyWindow);
    *)
    MyWindow:= NoWindow; (* for sake of safety *)
    MyBlock.EFlags:= Event{MuMesag};
  END;
END DoAcClose;

BEGIN
  ApplId:= ApplInit();

  IF ApplId >= 0 THEN
    AccName:= "  Eyes";
    MenuId:= MenuRegister(ApplId,AccName);

    GC:= 0;

    IF (MenuId >= 0) AND OpenVirtualWorkstation(GC) THEN
      MyWindow:= NoWindow;
      LastRect.GY:= -1;

      OldPos.GX:= -1;
      OldPos.GY:= -1;

      WITH MyBlock DO
        EFlags:= Event{MuMesag};
        EMePBuf:= PTR(MyMessage);
        ELoCount:= 100;
        EHiCount:= 0;
      END;

      WHILE TRUE DO
        MyEvent:= EvntEvent(MyBlock);

        IF MuMesag IN MyEvent THEN
          WITH MyMessage DO
            CASE Type OF
              WMRedraw:
                DoRedraw(Handle);
            | WMTopped:
                DoTopped(Handle);
            | WMBottomed:
                DoBottomed(Handle);
            | WMMoved:
                DoMoved(Handle,Rect);
            | WMClosed:
                DoClose(Handle);
            | AcOpen:
                DoAcOpen(OpenId);
            | AcClose:
                DoAcClose(CloseId);
            ELSE
              ;
            END;
          END;
        END;

        IF MuTimer IN MyEvent THEN
          DrawEyes(EyesOnly);
        END;

      END;
    ELSE
      WITH MyBlock DO
        EFlags:= Event{MuTimer};
        ETime:= MAX(UNSIGNEDLONG);
      END;

      WHILE TRUE DO
        VOID(EvntEvent(MyBlock));
      END;

    END;
  END;
END Eyes.
