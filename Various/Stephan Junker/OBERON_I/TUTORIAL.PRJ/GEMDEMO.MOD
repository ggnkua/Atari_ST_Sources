MODULE GemDemo;

(*
 Complete GEM application.
 *)

IMPORT
  S:=SYSTEM, GemApp, Model, WinView, Evnt, Graf, VC:=VDIControl,
  VA:=VDIAttributes, VO:=VDIOutput, Menus, Rsrc, Form, Objc, Sys,
  WDial:=WindowDialog, NumStr, Task;


CONST
    BOX        = 0; (* form/dialog *)
    OK         = 4; (* BUTTON in tree BOX *)
    INPUT1     = 5; (* BUTTON in tree BOX *)
    OUTPUT1    = 6; (* BUTTON in tree BOX *)

    MENU       = 1; (* menu *)
    DESK       = 3; (* TITLE in tree MENU *)
    FILE       = 4; (* TITLE in tree MENU *)
    WORK       = 5; (* TITLE in tree MENU *)
    INFO       = 8; (* STRING in tree MENU *)
    QUIT       = 17; (* STRING in tree MENU *)
    INPUT2     = 19; (* STRING in tree MENU *)
    OUTPUT2    = 20; (* STRING in tree MENU *)

    INPUTBOX   = 2; (* form/dialog *)
    CIRCLE     = 2; (* BUTTON in tree INPUTBOX *)
    RECT       = 3; (* BUTTON in tree INPUTBOX *)
    XPOS       = 4; (* FTEXT in tree INPUTBOX *)
    YPOS       = 5; (* FTEXT in tree INPUTBOX *)
    RADIUS     = 6; (* FTEXT in tree INPUTBOX *)
    WIDTH      = 7; (* FTEXT in tree INPUTBOX *)
    HEIGHT     = 8; (* FTEXT in tree INPUTBOX *)
    DRAW       = 9; (* BUTTON in tree INPUTBOX *)



TYPE
  Viewer    = POINTER TO ViewDesc;
  ViewDesc  = RECORD(WinView.ViewDesc)
              END;
  Object    = POINTER TO ObjDesc;
  ObjDesc   = RECORD
                next : Object;
                x,y  : INTEGER;
              END;
  Circle    = POINTER TO CircleDesc;
  CircleDesc= RECORD(ObjDesc)
                r : INTEGER;
              END;
  Rect      = POINTER TO RectDesc;
  RectDesc  = RECORD(ObjDesc)
                w,h  : INTEGER;
              END;
  MyModel   = POINTER TO ModelDesc;
  ModelDesc = RECORD(Model.Desc)
                objects : Object;
              END;


VAR
  infoDial,inputDial : WDial.Dialog;
  myModel : MyModel;
  Station : INTEGER;
  Workout : VC.workout;
  menu : Menus.Menu;


PROCEDURE(o : Object) Draw(v : Viewer);
 BEGIN
 END Draw;


PROCEDURE(c : Circle) Draw(v : Viewer);
 BEGIN
  VO.VArc( Station, v.x - SHORT( v.xOff) + c.x,
         v.y - SHORT( v.yOff) + c.y, c.r, 0, 3600 );
 END Draw;


PROCEDURE(r : Rect) Draw(v : Viewer);
  VAR Edges : ARRAY 10 OF INTEGER;
 BEGIN
  Edges[0] := v.x - SHORT( v.xOff) + r.x;
  Edges[1] := v.y - SHORT( v.yOff) + r.y;
  Edges[2] := Edges[0];
  Edges[3] := Edges[1] + r.h - 1;
  Edges[4] := Edges[0] + r.w - 1;
  Edges[5] := Edges[3];
  Edges[6] := Edges[4];
  Edges[7] := Edges[1];
  Edges[8] := Edges[0];
  Edges[9] := Edges[1];
  VO.VPline( Station, 5, Edges);
 END Draw;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR x2, y2 : INTEGER;
      obj : Object;
 BEGIN
  x2 := x+w-1; y2 := y+h-1;
  VC.VsClip( Station, TRUE, x, y, x2, y2);
  VO.VBar( Station, x, y, x2, y2 );
  obj := myModel.objects;
  WHILE obj # NIL DO
    obj.Draw(v); obj := obj.next;
  END;
 END Redraw;


PROCEDURE(m : MyModel) Init;
 BEGIN
  m.objects := NIL; m.Initialize^;
 END Init;


PROCEDURE ShowInfo;
 BEGIN
  infoDial.Open;
 END ShowInfo;


PROCEDURE Exit;
 BEGIN
  GemApp.exit := TRUE; (* die saubere Methode *)
 END Exit;


PROCEDURE OpenInput;
 BEGIN
  inputDial.Open;
 END OpenInput;


PROCEDURE SetDWH(v : Viewer);
  VAR obj : Object; maxX, maxY, dw, dh : INTEGER;
 BEGIN
  obj := myModel.objects;
  dw := SHORT(v.dw); dh := SHORT(v.dh);
  WHILE obj # NIL DO
    IF obj IS Rect THEN
      maxX := obj.x + obj(Rect).w;
      maxY := obj.y + obj(Rect).h;
    ELSE
      maxX := obj.x + obj(Circle).r;
      maxY := obj.y + obj(Circle).r;
    END;
    IF maxX > dw THEN dw := maxX END;
    IF maxY > dh THEN dh := maxY END;
    obj := obj.next;
  END;
  IF dw # v.dw THEN v.dw := dw; v.HSlider END;
  IF dh # v.dh THEN v.dh := dh; v.VSlider END;
 END SetDWH;


PROCEDURE OpenOutput;
  VAR outWin  : Viewer;
 BEGIN
  NEW( outWin); outWin.Initialize;
  outWin.SetModel(myModel); SetDWH(outWin);
  outWin.SetTitle("Objektfenster");
  outWin.SetFullSize( 0, 19, Workout.MaxX - 1,
                      Workout.MaxY - 20);
  outWin.Open;
 END OpenOutput;


PROCEDURE(v : Viewer) Update( aspect : Model.Aspect);
 BEGIN
  v.Update^( aspect); SetDWH(v);
 END Update;


PROCEDURE EnterNewObject;
  VAR x,y : INTEGER; obj : Object;
      tep : Objc.tedinfoptr;
      rec: Rect; cir: Circle;
(* improved by Daniel Burckhardt *)
 BEGIN
  IF Objc.SELECTED IN
     Objc.GetState( inputDial.objTree, RECT) THEN
    NEW( rec );
    tep := Objc.GetSpec( inputDial.objTree, WIDTH);
    rec.w := NumStr.ToInt( 10, tep.Text^);
    tep := Objc.GetSpec( inputDial.objTree, HEIGHT);
    rec.h := NumStr.ToInt( 10, tep.Text^);
    obj := rec;
  ELSE
    NEW( cir );
    tep := Objc.GetSpec( inputDial.objTree, RADIUS);
    cir.r := NumStr.ToInt( 10, tep.Text^);
    obj := cir;
  END;
  tep := Objc.GetSpec( inputDial.objTree, XPOS);
  obj.x := NumStr.ToInt( 10, tep.Text^);
  tep := Objc.GetSpec( inputDial.objTree, YPOS);
  obj.y := NumStr.ToInt( 10, tep.Text^);
  obj.next := myModel.objects;
  myModel.objects := obj;
  myModel.Changed( NIL);
 END EnterNewObject;


PROCEDURE EnableCircle;
 BEGIN
  inputDial.SetCursor( XPOS);
  Objc.SetFlags( inputDial.objTree, WIDTH,
                 {Objc.EDITABLE, Objc.HIDDEN} );
  inputDial.RedrawObj( WIDTH);
  Objc.SetFlags( inputDial.objTree, HEIGHT,
                 {Objc.EDITABLE, Objc.HIDDEN} );
  inputDial.RedrawObj( HEIGHT);
  Objc.SetFlags( inputDial.objTree, RADIUS,
                 {Objc.EDITABLE} );
  inputDial.RedrawObj( RADIUS);
 END EnableCircle;


PROCEDURE EnableRect;
 BEGIN
  inputDial.SetCursor( XPOS);
  Objc.SetFlags( inputDial.objTree, RADIUS,
                {Objc.EDITABLE, Objc.HIDDEN} );
  inputDial.RedrawObj( RADIUS);
  Objc.SetFlags( inputDial.objTree, WIDTH,
                {Objc.EDITABLE} );
  inputDial.RedrawObj( WIDTH);
  Objc.SetFlags( inputDial.objTree, HEIGHT,
                {Objc.EDITABLE} );
  inputDial.RedrawObj( HEIGHT);
 END EnableRect;


PROCEDURE Init;
  VAR
    Workin  : VC.workin;
    d: INTEGER;
 BEGIN
  Graf.ChangeMouse( Graf.ARROW);
  IF NOT Rsrc.Load("GEMDEMO.RSC") THEN
    Task.Exit(-1)
  END;
  NEW(menu); menu.Init( Rsrc.GetAddr(MENU) );
  menu.Set( FILE, QUIT, Exit );
  menu.Set( DESK, INFO, ShowInfo );
  menu.Set( WORK, OUTPUT2, OpenOutput );
  menu.Set( WORK, INPUT2, OpenInput );
  Station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1;
  Workin.LineColor := 1; Workin.MarkType := 1;
  Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0;
  Workin.FillPat := 0; Workin.FillColor := 1;
  Workin.KoorType := 2;
  VC.VOpnvwk(Workin,Station,Workout);
  VA.VswrMode(Station,VA.REPLACE);
  VA.VsfPerimeter(Station,FALSE);
  NEW( myModel); myModel.Initialize;
  NEW( infoDial);
  infoDial.InitDialog( Rsrc.GetAddr(BOX) , 0, TRUE);
  infoDial.SetWork(OK, NIL, { WDial.DESELECT,
                              WDial.EXITONLY } );
  infoDial.SetWork(INPUT1, OpenInput,
             { WDial.DESELECT, WDial.REDRAWOBJ } );
  infoDial.SetWork(OUTPUT1, OpenOutput,
             { WDial.DESELECT, WDial.REDRAWOBJ } );
  infoDial.SetTitle("Information");
  NEW( inputDial);
  inputDial.InitDialog( Rsrc.GetAddr(INPUTBOX),
                       XPOS, TRUE);
  inputDial.SetWork(DRAW, EnterNewObject,
             { WDial.DESELECT, WDial.REDRAWOBJ } );
  inputDial.SetWork(CIRCLE, EnableCircle, {} );
  inputDial.SetWork(RECT, EnableRect, {} );
  inputDial.SetTitle("Neues Objekt");
  inputDial.SetText( XPOS, "");
  inputDial.SetText( YPOS, "");
  inputDial.SetText( WIDTH, "");
  inputDial.SetText( HEIGHT, "");
  inputDial.SetText( RADIUS, "");
  Objc.SetState( inputDial.objTree, RECT,
                 {Objc.SELECTED} );
 END Init;


PROCEDURE Run*;
 BEGIN
  Init; (* should only be needed once, WindowDialog doesn't work *)
  menu.Show;
  GemApp.Run;
 END Run;


BEGIN
  IF ~Sys.Loader THEN
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END GemDemo.
