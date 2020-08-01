MODULE Dialogs;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Form, Graf, Objc, Wind, DCL;

CONST (* work bits *)
  DESELECT* = 0; EXITONLY* = 1; DELETEBOX* = 2; NEWBOX* = 3; REDRAWBOX* = 4;
  REDRAWOBJ* = 5; EXITDIALOG* = 6;
(* these bits determine what Dialog.Do should do before and after calling
   the exit procedure :
   DESELECT   : deselect object before call
   EXITONLY   : delete box and exit dialog before call
   DELETEBOX  : delete box before call
   NEWBOX     : delete box before call, redraw box after call
   REDRAWBOX  : redraw box after call
   REDRAWOBJ  : redraw exit object after call
   EXITDIALOG : delete box and exit dialog after call
*)

TYPE Proc*     = PROCEDURE;
     ExitDesc  = RECORD(DCL.Element)
                   obj  : INTEGER;
                   proc : Proc;
                   work : SET;
                 END(*RECORD*);
     Exit      = POINTER TO ExitDesc;
     Dialog*   = POINTER TO DialDesc;
     DialDesc* = RECORD
                   objTree- : S.PTR;
                   exits    : DCL.List;
                 END;

VAR
  x,y,w,h : INTEGER;


PROCEDURE(d : Dialog) Init*(objTree : S.PTR);
 BEGIN
  d.objTree := objTree;
  NEW( d.exits); d.exits.Init;
 END Init;


PROCEDURE(d : Dialog) Show*;
  (* displays the dialog box in the center of the screen. Ment for messages
     without interaction of the user. Window update is switched on *)
 BEGIN
  Form.Center(d.objTree,x,y,w,h);
  Form.Dial(Form.START,0,0,0,0,x,y,w,h);
  Wind.Update(Wind.BEGUPD);
  Graf.HideMouse; Objc.Draw(d.objTree,0,50,x,y,w,h); Graf.ShowMouse;
 END Show;


PROCEDURE(d : Dialog) Delete*;
  (* deletes the dialog box that was placed with Show. Window update is
     switched off. Must be called before using Show a second time *)
 BEGIN
  Wind.Update(Wind.ENDUPD);
  Form.Dial(Form.FINISH,0,0,0,0,x,y,w,h);
 END Delete;


PROCEDURE(d : Dialog) SetWork*(obj : INTEGER; proc : Proc;
                               workSet : SET);
 (* stores the work that will be done and the procedure called
    if object obj in dialog d is selected *)
  VAR e : Exit;
 BEGIN
  NEW( e); e.proc := proc; e.work := workSet; e.obj := obj;
  d.exits.Add(e);
 END SetWork;


PROCEDURE(d : Dialog) RedrawObj*(object : INTEGER);
  (* redraws an objects and its children. *)
  VAR obj : Objc.ptr;
      x,y : INTEGER;
 BEGIN
  obj := Objc.GetPtr(d.objTree, object);
  Objc.Offset(d.objTree,object,x,y);
  Graf.HideMouse;
  Objc.Draw(d.objTree,object,100,x,y,obj.W,obj.H);
  Graf.ShowMouse;
 END RedrawObj;


PROCEDURE(d : Dialog) SetText*(obj : INTEGER; str : ARRAY OF CHAR);
  (* writes str into the text of object obj and redraws it *)
  VAR tep : Objc.tedinfoptr;
 BEGIN
  tep := Objc.GetSpec(d.objTree,obj); COPY(str,tep.Text^);
  d.RedrawObj(obj);
 END SetText;


PROCEDURE SearchExit( list : DCL.List; obj : INTEGER; VAR e : Exit)
                      : BOOLEAN;
  VAR p : Exit;
 BEGIN
  p := list.root;
  WHILE p # NIL DO
    IF p.obj = obj THEN e := p; RETURN TRUE END;
    p := p.next;
  END;
  RETURN FALSE;
 END SearchExit;


PROCEDURE(d : Dialog) Do* (StartOb : INTEGER);
 (* dialog with user. StartOb is the object to start edt with. If an exit
    object is selected, the corresponding actions defined with Set are done.
    If nothing is set, the object is deselected, the box deleted and Do
    terminated *)
  VAR x,y,w,h : INTEGER;
      ExitBut : INTEGER;
      Index   : INTEGER;
      work    : SET;
      State   : SET;
      e       : Exit;
 BEGIN
  LOOP
    Form.Center(d.objTree,x,y,w,h);
    Form.Dial(Form.START,0,0,0,0,x,y,w,h);
    Wind.Update(Wind.BEGUPD);
    REPEAT
      Graf.HideMouse; Objc.Draw(d.objTree,0,50,x,y,w,h); Graf.ShowMouse;
      REPEAT
        ExitBut := Form.Do(d.objTree,StartOb);
        IF SearchExit(d.exits,ExitBut,e) THEN
          work := e.work;
        ELSE
          work := {DESELECT,EXITONLY,DELETEBOX};
        END(*IF*);
        IF DESELECT IN work THEN
          State := Objc.GetState(d.objTree,ExitBut);
          EXCL(State,Objc.SELECTED);
          Objc.SetState(d.objTree,ExitBut,State);
        END(*IF*);
        IF (DELETEBOX IN work) OR (EXITONLY IN work) OR (NEWBOX IN work) THEN
          Wind.Update(Wind.ENDUPD);
          Form.Dial(Form.FINISH,0,0,0,0,x,y,w,h);
          IF EXITONLY IN work THEN EXIT END(*IF*);
        END(*IF*);
        e.proc;
        IF EXITDIALOG IN work THEN
          IF NOT (DELETEBOX IN work) THEN
            Wind.Update(Wind.ENDUPD);
            Form.Dial(Form.FINISH,0,0,0,0,x,y,w,h);
          END(*IF*);
          EXIT
        END(*IF*);
        IF REDRAWOBJ IN work THEN
          Graf.HideMouse;
          Objc.Draw(d.objTree,ExitBut,1,x,y,w,h);
          Graf.ShowMouse;
        END(*IF*);
      UNTIL (REDRAWBOX IN work) OR (NEWBOX IN work);
    UNTIL NEWBOX IN work;
  END(*LOOP*);
 END Do;


PROCEDURE(d : Dialog) GetText*(obj : INTEGER; VAR str : ARRAY OF CHAR);
  (* reads str from the text of object obj *)
  VAR tep : Objc.tedinfoptr;
 BEGIN
  tep := Objc.GetSpec(d.objTree,obj); COPY(tep.Text^, str);
 END GetText;


END Dialogs.
