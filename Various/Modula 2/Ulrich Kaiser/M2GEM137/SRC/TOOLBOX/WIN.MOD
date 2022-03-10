IMPLEMENTATION MODULE Win;

(*
Yet another window manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES        IMPORT Root,StringPtr,TreePtr,ObjectIndex;
FROM ApplMgr    IMPORT AddApplExit;
FROM FormMgr    IMPORT FormError,NoMemory;
FROM GrafMgr    IMPORT GrafGrowBox,GrafShrinkBox,GrafMoveBox;
FROM WindMgr    IMPORT NoWindow,Desk,WindCreate,WindOpen,WindClose,
                       WindFind,WindDelete,WindCalc,WCBorder,WCWork,
                       WindFlag,Name,Closer,Fuller,Move,Info,Size,
                       UpArrow,DnArrow,VSlide,LfArrow,RtArrow,HSlide;
FROM RcMgr      IMPORT GRect,GPnt,RcSnap,RcIntersect,RcEqual;

FROM GrafTool   IMPORT GetMouse;
FROM WindTool   IMPORT DrawProc;

FROM pSTORAGE   IMPORT ALLOCATE,DEALLOCATE,SIZETYPE;
FROM SYSTEM     IMPORT TSIZE;
FROM INTRINSIC  IMPORT VOID,PTR;
FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYPOINTER,NULL;

IMPORT SetObject,GetObject,WindSet,WindGet,DeskTool;

VAR VoidChar: ARRAY[0..0] OF CHAR;

    i: AESWins;

PROCEDURE Dummy(Window: Handle);
BEGIN
END Dummy;

PROCEDURE Create(Flags : Flag;
                 Type  : Classes;
                 Redraw: DrawProc): Handle;

VAR Window: Handle;
    Full  : GRect;

BEGIN
  WindGet.WorkXYWH(Desk,Full);
  Window:= WindCreate(Flags,Full);

  IF Window # NoWindow THEN
    ALLOCATE(List[Window],TSIZE(Rec));
    IF List[Window] = NIL THEN
      FormError(NoMemory);
      RETURN NoWindow;
    END;

    WITH List[Window]^ DO
      ClassType:= Type;

      IF Name IN Flags THEN
        WindSet.Name(Window,VoidChar);
        NamePtr:= PTR(VoidChar);
      END;

      IF Info IN Flags THEN
        WindSet.Info(Window,VoidChar);
        InfoPtr:= PTR(VoidChar);
      END;

      RedrawProc:= Redraw;
      CloseProc:= Dummy;

      Extension:= NIL;
    END;
  END;
  RETURN Window;
END Create;

PROCEDURE Open(Window: Handle; Full: GRect);

VAR Start: GRect;
    Pos  : GPnt;

BEGIN
  WITH Full DO
    IF (GW = 0) OR (GH = 0) THEN
      GetMouse(Pos);
      GX:= Pos.GX;
      GY:= Pos.GY;
      GW:= 250;
      GH:= 150;
    END;
    Start.GX:= GX;
    Start.GY:= GY;
    Start.GW:= 4;
    Start.GH:= 4;
  END;

  GrafGrowBox(Start,Full);
  WindOpen(Window,Full);
  IF List[Window]^.ClassType = Form THEN
    WindGet.WorkXYWH(Window,Full);
    SetObject.X(List[Window]^.FormTree,Root,Full.GX);
    SetObject.Y(List[Window]^.FormTree,Root,Full.GY);
  END;
END Open;

PROCEDURE Close(Window: Handle);

VAR Start: GRect;
    End  : GRect;

BEGIN
  List[Window]^.CloseProc(Window);

  WindGet.CurrXYWH(Window,Start);

  WITH Start DO
    End.GX:= GW DIV 2;
    End.GY:= GH DIV 2;
    End.GW:= 4;
    End.GH:= 4;
  END;

  WindClose(Window);
  GrafShrinkBox(End,Start);
END Close;

PROCEDURE Delete(Window: Handle);
BEGIN
  WITH List[Window]^ DO
    IF Extension # NIL THEN
      DEALLOCATE(Extension,Size);
    END;
  END;

  DEALLOCATE(List[Window],TSIZE(Rec)); (* sets to NIL *)
  WindDelete(Window);                  (* sets to -1  *)
END Delete;

PROCEDURE Shutdown;

VAR i: AESWins;

BEGIN
  FOR i:= 1 TO MaxAESWins DO
    IF List[i] # NIL THEN
      Close(i);
      Delete(i);
    END;
  END;
END Shutdown;

(**************************************************************************)

PROCEDURE OpenDesk(DeskTree: TreePtr; RootOb: ObjectIndex);
BEGIN
 ALLOCATE(List[Desk],TSIZE(Rec));
 WITH List[Desk]^ DO
   ClassType:= Form;
   FormTree:= DeskTree;
   Extension:= NIL;
 END;
 DeskTool.OpenDesk(DeskTree,RootOb);
END OpenDesk;

PROCEDURE CloseDesk;
BEGIN
  DEALLOCATE(List[Desk],TSIZE(Rec));
  DeskTool.CloseDesk;
END CloseDesk;

BEGIN
   FOR i:= Desk TO MaxAESWins DO
     List[i]:= NIL;
   END;

   VoidChar[0]:= 0C;

   AddApplExit(Shutdown);
END Win.