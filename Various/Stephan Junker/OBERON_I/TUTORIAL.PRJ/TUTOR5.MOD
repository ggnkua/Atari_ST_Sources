MODULE Tutor5;

(*
 Dialog with user.
 *)

IMPORT
  S:=SYSTEM, GemApp, Menus, WinView, Model, VC:=VDIControl,
  VO:=VDIOutput, VA:=VDIAttributes, Form, Graf, Rsrc,
  WDial:=WindowDialog, Task, Sys;


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
  MyModel   = POINTER TO ModelDesc;
  ModelDesc = RECORD(Model.Desc)
              END;


VAR
  myModel : MyModel;
  Station : INTEGER;
  Workout : VC.workout;
  infoDial : WDial.Dialog;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR x2, y2 : INTEGER;
 BEGIN
  x2 := x+w-1; y2 := y+h-1;
  VC.VsClip( Station, TRUE, x, y, x2, y2);
  VO.VBar( Station, x, y, x2, y2 );
 END Redraw;


PROCEDURE OpenOutput;
  VAR outWin  : Viewer;
 BEGIN
  NEW( outWin); outWin.Initialize;
  outWin.model := myModel;
  outWin.SetTitle("Objektfenster");
  outWin.SetFullSize( 0, 19, Workout.MaxX - 1,
                      Workout.MaxY - 20);
  outWin.Open;
 END OpenOutput;


PROCEDURE ShowInfo;
 BEGIN
  infoDial.Open;
 END ShowInfo;


PROCEDURE Exit;
 BEGIN
  GemApp.exit := TRUE;
 END Exit;


PROCEDURE Run;
  VAR
    menu : Menus.Menu;
    Workin : VC.workin;
 BEGIN
  Graf.ChangeMouse( Graf.ARROW);
  IF NOT Rsrc.Load("GEMDEMO.RSC") THEN
    Task.Exit(0)
  END;
  NEW(menu); menu.Init( Rsrc.GetAddr(MENU) );
  menu.Set( FILE, QUIT, Exit );
  menu.Set( DESK, INFO, ShowInfo );
  menu.Set( WORK, OUTPUT2, OpenOutput );
  menu.Show;
  Station := 1;
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
  infoDial.SetWork(OUTPUT1, OpenOutput,
             { WDial.DESELECT, WDial.REDRAWOBJ } );
  infoDial.SetTitle("Information");
  GemApp.Run
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Tutor5.
