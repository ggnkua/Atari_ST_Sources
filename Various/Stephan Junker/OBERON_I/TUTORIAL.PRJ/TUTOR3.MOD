MODULE Tutor3;

(*
 Display a menu bar.
 *)

IMPORT
  S:=SYSTEM, GemApp, Graf, Rsrc, Form, Menus, Task, Sys;


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



PROCEDURE ShowInfo;
  VAR d : INTEGER;
 BEGIN
  d := Form.Alert(1, "[1][Tutor3 by Stephan Junker][Ok]");
 END ShowInfo;


PROCEDURE Exit;
 BEGIN
  GemApp.exit := TRUE;
 END Exit;


PROCEDURE Run*;
  VAR
    menu : Menus.Menu;
 BEGIN
  Graf.ChangeMouse( Graf.ARROW);
  IF NOT Rsrc.Load("GEMDEMO.RSC") THEN
    Task.Exit(0)
  END;
  NEW(menu); menu.Init( Rsrc.GetAddr(MENU) );
  menu.Set( FILE, QUIT, Exit );
  menu.Set( DESK, INFO, ShowInfo );
  menu.Show;
  GemApp.Run
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Tutor3.
