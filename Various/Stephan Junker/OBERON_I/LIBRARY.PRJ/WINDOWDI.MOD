MODULE WindowDialog;


(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
S. Junker  |5.11.93  |correction for WinView
S. Junker  |17.12.94 |only used keyboard input consumed
----------------------------------------------------------------------------
*)


IMPORT
  S:=SYSTEM, Form, Objc, WinView, Wind, Str:=Strings, Evnt, VC:=VdiControl,
  VA:=VdiAttributes, VO:=VdiOutput, DCL, VI:=VDIInput, Graf;


CONST (* work bits *)
  DESELECT* = 0; EXITONLY* = 1; REDRAWOBJ* = 5; EXITDIALOG* = 6;
(* these bits determine what to do if an exit object is chosen :
   DESELECT  : deselect exit object before calling exit procedure (no redraw).
   EXITONLY  : no call of exit procedure, close window.
   REDRAWOBJ : redraw exit object after calling exit procedure.
   EXITDIALOG: close window after calling exit procedure.
*)
   SHIFT = 1;



TYPE Proc*     = PROCEDURE;
     ExitDesc  = RECORD(DCL.Element)
                   obj  : INTEGER;
                   proc : Proc;
                   work : SET;
                 END(*RECORD*);
     Exit      = POINTER TO ExitDesc;
     editpos   = POINTER TO RECORD(DCL.Element)
                   obj      : INTEGER;
                   Position : INTEGER;
                 END;
     Dialog*   = POINTER TO DialDesc;
     DialDesc* = RECORD (WinView.ViewDesc)
                   objTree- : S.PTR;
                   exits    : DCL.List;
                   EditPos  : DCL.List;
                   CurrEdOb : INTEGER;
                 END;



VAR exit*    : BOOLEAN;
    (* if an exit procedure sets 'Exit' to TRUE, Dialog.Do terminates *)
    exitBut* : INTEGER;
    (* contains the object number of the exit object *)

    Station,d: INTEGER;
    Workin   : VC.workin;
    Workout  : VC.workout;



PROCEDURE SearchEditObj( p : editpos; Obj : INTEGER; VAR e : editpos)
                        : BOOLEAN;
 BEGIN
  WHILE p # NIL DO
    IF p.obj = Obj THEN e := p; RETURN TRUE END;
    p := p.next;
  END;
  RETURN FALSE
 END SearchEditObj;


PROCEDURE SetCurrPos(d : Dialog; Obj,Pos : INTEGER);
  VAR edp : editpos;
 BEGIN
  IF SearchEditObj( d.EditPos.root, Obj, edp) THEN edp.Position := Pos END;
 END SetCurrPos;


PROCEDURE GetCurrPos(d : Dialog) : INTEGER;
  VAR edp : editpos;
 BEGIN
  IF SearchEditObj( d.EditPos.root, d.CurrEdOb, edp) THEN RETURN edp.Position END;
  RETURN 0
 END GetCurrPos;


PROCEDURE GetRealPos(d : Dialog; Pos : INTEGER) : INTEGER;
  (* returns the real position in the object *)
  VAR tep : Objc.tedinfoptr; tmp : Str.ptr; Real : INTEGER;
 BEGIN
  tep := Objc.GetSpec(d.objTree,d.CurrEdOb);
  tmp := tep.Template; Real := 0;
  LOOP
    IF tmp[Real] = 0X THEN EXIT
    ELSE
      IF tmp[Real] = "_" THEN DEC(Pos);
        IF Pos = -1 THEN EXIT END;
      END;
      INC(Real)
    END;
  END;
  RETURN Real
 END GetRealPos;


PROCEDURE CorrectCurPos(d : Dialog);
  VAR edp : editpos; tep : Objc.tedinfoptr; Len : INTEGER;
 BEGIN
  tep := Objc.GetSpec(d.objTree,d.CurrEdOb); Len := Str.Length(tep.Text^);
  IF GetCurrPos(d) > Len THEN SetCurrPos(d,d.CurrEdOb,Len) END;
 END CorrectCurPos;


PROCEDURE DrawCursor(d : Dialog);
  (* draws the cursor in form of a line *)
  VAR xo,yo : INTEGER; Points : ARRAY 4 OF INTEGER;
 BEGIN
  IF d.CurrEdOb # -1 THEN CorrectCurPos(d);
    Objc.Offset(d.objTree,d.CurrEdOb,xo,yo);
    Points[0] := xo + GetRealPos(d, GetCurrPos(d) ) * 8;
    Points[1] := yo - 4;
    Points[2] := Points[0]; Points[3] := yo + 20;
    VI.VHideC(Station);
    VO.VPline(Station,2,Points);
    VI.VShowC(Station, TRUE);
  END;
 END DrawCursor;


PROCEDURE(d : Dialog) Redraw(x,y,w,h : INTEGER);
 BEGIN
  Objc.Draw(d.objTree,0,100,x,y,w,h);
  VC.VsClip(Station,TRUE,x,y,x + w - 1,y + h - 1);
  DrawCursor(d);
 END Redraw;


PROCEDURE(d : Dialog) SetCursor*(obj : INTEGER);
  (* sets the cursor in editable object obj *)
 BEGIN
  VC.VsClip(Station,FALSE,0,0,0,0);
  DrawCursor(d);
  d.CurrEdOb := obj; CorrectCurPos(d);
  DrawCursor(d);
 END SetCursor;


PROCEDURE(d : Dialog) RedrawObj*(object : INTEGER);
  (* redraws an objects and its children. *)
  VAR obj : Objc.ptr;
      x,y : INTEGER;
 BEGIN
  obj := Objc.GetPtr(d.objTree, object);
  Objc.Offset(d.objTree,object,x,y);
  d.UpdateRect(x,y,obj.W,obj.H);
 END RedrawObj;


PROCEDURE(d : Dialog) SetText*(obj : INTEGER; str : ARRAY OF CHAR);
  (* writes str into the text of object obj and redraws it if window is
     open *)
  VAR tep : Objc.tedinfoptr;
      edp : editpos;
 BEGIN
  tep := Objc.GetSpec(d.objTree,obj); COPY(str,tep.Text^);
  SetCurrPos(d, obj, Str.Length(str) );
  IF d.opened THEN d.RedrawObj(obj) END;
 END SetText;


PROCEDURE(d : Dialog) SetWork*(obj : INTEGER; proc : Proc;
                               WorkSet : SET);
 (* stores the work that will be done if object obj in viewer v is
    selected *)
  VAR e : Exit;
 BEGIN
  NEW(e); d.exits.Add(e); e.obj := obj;
  e.proc := proc; e.work := WorkSet;
 END SetWork;


PROCEDURE StoreEditPositions(objTree : LONGINT; Object,Root : INTEGER;
                             VAR List : DCL.List);
  (* stores the position of the cursor for every editable object, i.e.
     all objects of type FTEXT or FBOXTEXT. The initial position is after
     the last character *)
  VAR Obj : Objc.ptr;
      edp : editpos;
      tep : Objc.tedinfoptr;
 BEGIN
  REPEAT
    Obj := Objc.GetPtr(objTree,Object);
    IF (Obj.Type = Objc.FTEXT) OR (Obj.Type = Objc.FBOXTEXT) THEN
      NEW(edp);
      tep := Obj.ObSpec; edp.Position := Str.Length(tep.Text^);
      List.Add(edp); edp.obj := Object;
    END;
    IF Obj.Head # -1 THEN
      StoreEditPositions(objTree,Obj.Head,Object,List);
    END;
    Object := Obj.Next;
  UNTIL Object = Root;
 END StoreEditPositions;


PROCEDURE NextEditable(d : Dialog);
  (* searches the next object which is editable *)
  VAR Obj : Objc.ptr;
 BEGIN
  Obj := Objc.GetPtr(d.objTree,d.CurrEdOb);
  WHILE NOT (Objc.LASTOBJECT IN S.VAL(SET,LONG(Obj.Flags))) DO
    INC(Obj,24);
    IF (Objc.EDITABLE IN S.VAL(SET,LONG(Obj.Flags))) AND
       NOT (Objc.HIDDEN IN S.VAL(SET,LONG(Obj.Flags))) THEN
      d.CurrEdOb := SHORT(
         (S.VAL(LONGINT,Obj) - S.VAL( LONGINT, d.objTree)) DIV 24 );
      CorrectCurPos(d);
      RETURN
    END;
  END;
 END NextEditable;


PROCEDURE PrevEditable(d : Dialog);
  (* searches the next object which is editable *)
  VAR Obj : Objc.ptr;
 BEGIN
  Obj := Objc.GetPtr(d.objTree,d.CurrEdOb);
  WHILE S.VAL(LONGINT,Obj) # d.objTree DO
    DEC(Obj,24);
    IF (Objc.EDITABLE IN S.VAL(SET,LONG(Obj.Flags))) AND
       NOT (Objc.HIDDEN IN S.VAL(SET,LONG(Obj.Flags))) THEN
      d.CurrEdOb := SHORT(
         (S.VAL(LONGINT,Obj) - S.VAL( LONGINT, d.objTree)) DIV 24 );
      CorrectCurPos(d);
      RETURN
    END;
  END;
 END PrevEditable;


PROCEDURE FindDefault(objTree : LONGINT; Object,Root : INTEGER;
                      VAR Default : INTEGER) : BOOLEAN;
  (* searches a default button and returns its number in Default *)
  VAR Obj : Objc.ptr;
 BEGIN
  REPEAT
    Obj := Objc.GetPtr(objTree,Object);
    IF Objc.DEFAULT IN S.VAL(SET,LONG(Obj.Flags)) THEN
      Default := Object; RETURN TRUE;
    END;
    IF Obj.Head # -1 THEN
      IF FindDefault(objTree,Obj.Head,Object,Default) THEN RETURN TRUE END;
    END;
    Object := Obj.Next;
  UNTIL Object = Root;
  RETURN FALSE;
 END FindDefault;


PROCEDURE Select(d : Dialog; Object : INTEGER; NoDeselect : BOOLEAN);
  (* sets the state of Object to SELECTED and redraws it *)
  VAR State : SET;
 BEGIN
  State := Objc.GetState(d.objTree,Object);
  IF NoDeselect THEN INCL(State,Objc.SELECTED)
  ELSE State := State / {Objc.SELECTED}
  END;
  Objc.SetState(d.objTree,Object,State);
  d.RedrawObj(Object);
 END Select;


PROCEDURE Parent(objTree : LONGINT; Obj : Objc.ptr; Object : INTEGER) : BOOLEAN;
  (* returns TRUE if Obj is the parent object of Object *)
  VAR StartOb,Ob : INTEGER;
 BEGIN
  IF Obj.Head # -1 THEN
    Ob := Obj.Head; StartOb := Ob;
    REPEAT
      IF Ob = Object THEN RETURN TRUE END;
      Obj := Objc.GetPtr(objTree,Ob); Ob := Obj.Next;
    UNTIL Obj.Head = StartOb;
  END;
  RETURN FALSE;
 END Parent;


PROCEDURE DeselectRadio(d : Dialog; Object : INTEGER);
  (* deselects all radiobuttons on the same level as Object *)
  VAR Obj : Objc.ptr; StartOb,Ob : INTEGER;
 BEGIN
  Ob := Object;
  REPEAT
    Obj := Objc.GetPtr(d.objTree,Ob);
    IF Parent(d.objTree,Obj,Object) THEN Ob := Obj.Head;
    ELSIF (Objc.RADIOBUTTON IN S.VAL(SET,LONG(Obj.Flags))) AND
       (Objc.SELECTED IN S.VAL(SET, LONG(Obj.State) )) THEN
      Obj.State := S.VAL(INTEGER, S.VAL(SET,LONG(Obj.State)) - {Objc.SELECTED} );
      d.RedrawObj(Ob); RETURN
    ELSE Ob := Obj.Next
    END;
  UNTIL Ob = Object;
 END DeselectRadio;


PROCEDURE SearchExitObj( p : Exit; Obj : INTEGER; VAR e : Exit)
                        : BOOLEAN;
 BEGIN
  WHILE p # NIL DO
    IF p.obj = Obj THEN e := p; RETURN TRUE END;
    p := p.next;
  END;
  RETURN FALSE
 END SearchExitObj;


PROCEDURE ControlButton(d : Dialog; Object : INTEGER);
  (* selects the button Object, calls exit procedure etc. if said so *)
  VAR Obj : Objc.ptr;
      Flags,Work : SET;
      e : Exit;
 BEGIN
  exit := FALSE;
  Obj := Objc.GetPtr(d.objTree,Object);
  Flags := S.VAL(SET,LONG(Obj.Flags));
  IF Objc.SELECTABLE IN Flags THEN
    IF Objc.RADIOBUTTON IN Flags THEN DeselectRadio(d,Object) END;
    Select(d,Object,Objc.RADIOBUTTON IN Flags);
  END;
  IF Objc.EDITABLE IN Flags THEN
    VC.VsClip(Station,FALSE,0,0,0,0);
    DrawCursor(d);
    d.CurrEdOb := Object;
    CorrectCurPos(d);
    DrawCursor(d);
  END;
  IF (Objc.EXITDIAL IN Flags) OR (Objc.TOUCHEXIT IN Flags) THEN
    IF SearchExitObj(d.exits.root,Object,e) THEN Work := e.work;
    ELSE Work := {DESELECT,EXITONLY};
    END(*IF*);
    IF DESELECT IN Work THEN
      Objc.SetState(d.objTree,Object,
                    Objc.GetState(d.objTree,Object) - {Objc.SELECTED});
    END(*IF*);
    IF EXITONLY IN Work THEN d.Close
    ELSE exitBut := Object; e.proc;
      IF exit OR (EXITDIALOG IN Work) THEN d.Close
      ELSIF REDRAWOBJ IN Work THEN d.RedrawObj(Object)
      END(*IF*);
    END(*IF*);
  END;
 END ControlButton;


PROCEDURE RedrawEdit(d : Dialog; Pos : INTEGER);
  (* redraws an editable object starting at character position Pos *)
  VAR x,y,dx : INTEGER; Obj : Objc.ptr;
 BEGIN
  Objc.Offset(d.objTree,d.CurrEdOb,x,y);
  Obj := Objc.GetPtr(d.objTree,d.CurrEdOb);
  dx := GetRealPos(d,Pos) * 8;
  d.UpdateRect(x + dx,y,Obj.W - dx,Obj.H);
 END RedrawEdit;


PROCEDURE Letter(c : CHAR) : BOOLEAN;
  (* return TRUE if c is inbetween "A" and "Z" *)
 BEGIN
  RETURN (c >= "A") AND (c <= "Z")
 END Letter;


PROCEDURE Digit(c : CHAR) : BOOLEAN;
  (* return TRUE if c is inbetween "0" and "9" *)
 BEGIN
  RETURN (c >= "0") AND (c <= "9")
 END Digit;


PROCEDURE FileName(c : CHAR) : BOOLEAN;
  (* returns TRUE if c is a valid character for file names *)
 BEGIN
  RETURN Letter(c) OR Digit(c) OR (c = "*") OR (c = "?") OR (c = "_")
         OR (c = ".")
 END FileName;


PROCEDURE MakeValid(VAR ValidStr : ARRAY OF CHAR; Pos : INTEGER;
                    VAR Ascii : CHAR) : BOOLEAN;
  (* tests if Ascii is a valid character, converts it to one if possible *)
  VAR c,Valid : CHAR; Len : INTEGER;
 BEGIN
  IF Ascii # 0X THEN c := CAP(Ascii); Len := Str.Length(ValidStr);
    IF Pos >= Len THEN Valid := ValidStr[Len-1] ELSE Valid := ValidStr[Pos] END;
    IF (Valid = "9") AND Digit(Ascii) OR (Valid = "a") AND Letter(c) OR
       (Valid = "N") AND (Letter(Ascii) OR Digit(c)) OR
       (Valid = "n") AND (Letter(c) OR Digit(c)) OR (Valid = "X") THEN
      RETURN TRUE
    ELSIF (Valid = "A") AND Letter(c) OR (Valid = "F") AND FileName(c) OR
          (CAP(Valid) = "P") AND (FileName(c) OR (c = ":") OR (c = "\")) THEN
      Ascii := c; RETURN TRUE
    END;
  END;
  RETURN FALSE;
 END MakeValid;


PROCEDURE TestJump(d : Dialog; Ascii : CHAR; VAR Template,Text : ARRAY OF CHAR;
                   VAR Pos : INTEGER) : BOOLEAN;
  (* if Ascii specifies a character which is not valid, but in Template, and after
     this character is space to edit, the cursor will be set after this character *)
  VAR p,i : INTEGER;
 BEGIN
  p := GetRealPos(d,Pos); i := 0;
  WHILE (Template[p] # 0X) AND (Template[p] # Ascii) DO
    IF Template[p] = "_" THEN INC(i) END;
    INC(p);
  END;
  IF (Template[p] # 0X) AND (Template[p+1] # 0X) AND (Template[p+1] = "_") THEN
    DrawCursor(d);
    WHILE i > 0 DO Text[Pos] := " "; INC(Pos); DEC(i); END;
    DrawCursor(d);
    RETURN TRUE
  END;
  RETURN FALSE
 END TestJump;


PROCEDURE(d : Dialog) HandleKeyEvent(Shift : SET; Scan : INTEGER;
                                     Ascii : CHAR) : BOOLEAN;
  (* edits editable strings *)
  VAR edp : editpos;
      Object,Pos,Len : INTEGER;
      exit : Exit;
      tep : Objc.tedinfoptr;
 BEGIN
   LOOP
    IF Scan = 1CH THEN (* return *)
      IF FindDefault(d.objTree,0,-1,Object) THEN
        ControlButton(d,Object);
      ELSE
        EXIT
      END
    ELSIF (d.CurrEdOb # -1) AND
          SearchEditObj(d.EditPos.root,d.CurrEdOb,edp) THEN
      Pos := edp.Position;
      tep := Objc.GetSpec(d.objTree,d.CurrEdOb);
      VC.VsClip(Station,FALSE,0,0,0,0);
      CASE Scan OF
      01H : (* escape *)
        DrawCursor(d);
        tep.Text^[0] := 0X; (* empty text *)
        edp.Position := 0; DrawCursor(d);
        RedrawEdit(d,0); |
      0EH : (* backspace *)
        IF Pos # 0 THEN DrawCursor(d);
          Str.Delete(Pos-1,Pos,tep.Text^); DEC(edp.Position);
          DrawCursor(d); RedrawEdit(d,edp.Position);
        END |
      53H : (* delete *)
        DrawCursor(d); Str.Delete(Pos,Pos+1,tep.Text^);
        DrawCursor(d); RedrawEdit(d,edp.Position) |
      4BH : (* cursor left *)
        IF Pos # 0 THEN DrawCursor(d);
          IF SHIFT IN Shift THEN edp.Position := 0 ELSE DEC(edp.Position) END;
          DrawCursor(d);
        END |
      4DH : (* cursor right *)
        Len := Str.Length(tep.Text^);
        IF Pos < Len THEN DrawCursor(d);
          IF SHIFT IN Shift THEN edp.Position := Len ELSE INC(edp.Position) END;
          DrawCursor(d);
        END |
      48H,50H,0FH : (* cursor up,down, Tab *)
        DrawCursor(d);
        IF Scan = 48H THEN PrevEditable(d) ELSE NextEditable(d) END;
        DrawCursor(d) |
      ELSE
        IF MakeValid(tep.Valid^,Pos,Ascii) THEN
          Len := Str.Length(tep.Text^);
          IF Pos = tep.TextLen - 1 THEN tep.Text[Len-1] := Ascii
          ELSE IF Len + 1 = tep.TextLen THEN tep.Text[Len-1] := 0X END;
            DrawCursor(d);
            Str.InsertC(Ascii,Pos,tep.Text^); INC(edp.Position);
            DrawCursor(d);
          END;
          RedrawEdit(d,edp.Position - 1);
        ELSIF NOT TestJump(d,Ascii,tep.Template^,tep.Text^,edp.Position) THEN
          EXIT
        END;
      END;
    ELSE
      EXIT
    END;
    RETURN TRUE
  END;
  RETURN d.HandleKeyEvent^(Shift,Scan, Ascii);
 END HandleKeyEvent;


PROCEDURE(d : Dialog) HandleButtonEvent(
  Buttons : SET;
  Mx,My,Clicks : INTEGER) : BOOLEAN;
(*
 selects buttons, calls exit procedures etc.
 *)
  VAR Object : INTEGER;
 BEGIN
  IF Buttons = {Evnt.LEFT} THEN
    Object := Objc.Find(d.objTree,0,100,Mx,My);
    IF Object # -1 THEN ControlButton(d,Object); RETURN TRUE END;
  END;
  RETURN FALSE
 END HandleButtonEvent;


PROCEDURE(d : Dialog) SetPos*(x,y : INTEGER);
  VAR Obj : Objc.ptr;
 BEGIN
  Obj := Objc.GetPtr(d.objTree,0);
  DEC( Obj.X, d.x - x);
  DEC( Obj.Y, d.y - y);
  d.SetPos^(x,y);
 END SetPos;


PROCEDURE(d : Dialog) InitDialog*(objTree : S.PTR; editStart : INTEGER;
                                  useCloser : BOOLEAN);
  (* initializes the dialog and the viewer it uses.
     Sets the object tree which contains the dialog box and centers it.
     If not desired, change the position using d.SetPos afterwards.
     editStart is the index of an editable object to start editing when
     first opening the dialog. If useCloser is true, the window will have
     a close button *)
  VAR x,y,w,h : INTEGER;
      Obj : Objc.ptr;
 BEGIN
  d.Initialize;
  NEW( d.exits); d.exits.Init;
  NEW( d.EditPos); d.EditPos.Init;
  d.objTree := objTree;
  Obj := objTree; (* first object *)
  IF Obj.Type = Objc.BOX THEN (* normally *)
    Obj.ObSpec := S.ANL( Obj.ObSpec, 0FFFFH);
  END;
  Form.Center(objTree,x,y,w,h);
  INC(x); INC(y); DEC(w,2); DEC(h,2);
  IF y < 20 THEN Obj := Objc.GetPtr(objTree,0);
    INC(Obj.Y,20 - y); y := 20;
  END;
  d.SetPos^(x,y); d.SetSize(w,h);
  IF Objc.EDITABLE IN Objc.GetFlags(objTree,editStart) THEN
    d.CurrEdOb := editStart;
    StoreEditPositions(objTree,0,-1,d.EditPos);
  ELSE d.CurrEdOb := -1;
  END;
  IF useCloser THEN d.SetElements( {Wind.TITLE,Wind.MOVER,Wind.CLOSER})
  ELSE d.SetElements( {Wind.TITLE,Wind.MOVER})
  END;
 END InitDialog;


PROCEDURE(d : Dialog) GetText*(obj : INTEGER; VAR str : ARRAY OF CHAR);
  (* reads str from the text of object obj *)
  VAR tep : Objc.tedinfoptr;
      edp : editpos;
 BEGIN
  tep := Objc.GetSpec(d.objTree,obj); COPY(tep.Text^, str);
 END GetText;


BEGIN
  Station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 1; Workin.FillPat := 0;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VC.VOpnvwk(Workin,Station,Workout);
  VA.VswrMode(Station,VA.EXOR);
  VA.VsfPerimeter(Station,FALSE);
END WindowDialog.
