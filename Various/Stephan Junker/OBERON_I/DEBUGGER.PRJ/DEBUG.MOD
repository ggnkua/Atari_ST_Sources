MODULE Debug;


IMPORT
  S:=SYSTEM, Form, ModList, GemApp, Graf, Wind, CallList, LTLHalt, Menus,
  Rsrc, Task, Variables, DbBase, Selected, ErrorWin;


CONST
  MENU       = 0; (* menu *)
  DESK       = 3; (* TITLE in tree MENU *)
  FILE       = 4; (* TITLE in tree MENU *)
  TOOLS      = 5; (* TITLE in tree MENU *)
  INFO       = 8; (* STRING in tree MENU *)
  QUIT       = 17; (* STRING in tree MENU *)
  CALLEXITS  = 19; (* STRING in tree MENU *)



VAR
  menu: Menus.Menu;
  modList : ModList.Viewer;
  callList: CallList.Viewer;
  errorWin: ErrorWin.Viewer;


PROCEDURE ShowInfo;
  VAR
    d : INTEGER;
 BEGIN
  d := Form.Alert(1, "[1][STJ-Debug V2.00 by Stephan Junker][Ok]");
 END ShowInfo;


PROCEDURE ExitDebug;
 BEGIN
  GemApp.exit := TRUE;
 END ExitDebug;


PROCEDURE CallExits;
 BEGIN
  Graf.NormalMouse;
  Wind.EndUpdate;
 END CallExits;


PROCEDURE Init;
 BEGIN
  DbBase.Init;
  Selected.Init;
  CallList.Init;
  Variables.Init;
 END Init;


PROCEDURE Exit;
 BEGIN
  Variables.Exit;
  CallList.Exit;
  Selected.Exit;
  DbBase.Exit;
  modList := NIL;
  callList := NIL;
 END Exit;


PROCEDURE Debug(address: S.PTR; contPossible: BOOLEAN);
 BEGIN
  Exit;
  IF (menu = NIL) & Rsrc.Load("DEBUG.RSC") THEN
    NEW(menu); menu.Init( Rsrc.GetAddr(MENU) );
    menu.Set( FILE, QUIT, ExitDebug );
    menu.Set( DESK, INFO, ShowInfo );
    menu.Set( TOOLS, CALLEXITS, CallExits );
  END;
  IF menu # NIL THEN menu.Show END;
  Init;
  errorWin := ErrorWin.ShowException();
  modList := ModList.NewViewer( ModList.BuildList() );
  callList := CallList.NewViewer( CallList.BuildList(address) );
  GemApp.Run;
  IF menu # NIL THEN Menus.Hide END;
  Exit;
  IF contPossible THEN
    IF Form.Alert(1, "[2][Continue?][Yes|No]") = 2 THEN Task.Exit(-1) END;
  ELSE
    Task.Exit(-1);
  END;
 END Debug;


PROCEDURE Run*;
 BEGIN
 END Run;


BEGIN
  LTLHalt.Debug := Debug;
END Debug.