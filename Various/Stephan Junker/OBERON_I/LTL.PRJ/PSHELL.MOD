MODULE PShell;


IMPORT
  S:=SYSTEM, Sys, IO:=GEMIO, TermWin, LTL, Task, GC, GemApp, Menus, Rsrc,
  Graf, Form, LTLHalt, LTLProgram, Time, VA;


CONST
    MENU       = 0; (* menu *)
    DESK       = 3; (* TITLE in tree MENU *)
    FILE       = 4; (* TITLE in tree MENU *)
    INFO       = 7; (* STRING in tree MENU *)
    QUIT       = 16; (* STRING in tree MENU *)


VAR
  menu- : Menus.Menu;



PROCEDURE Prompt;
 BEGIN
  IO.WriteChar( ">"); IO.viewer.SetEditStart;
 END Prompt;


PROCEDURE Unprompt;
 BEGIN
  IO.viewer.SetEditStart;
 END Unprompt;


PROCEDURE Call*(VAR string: ARRAY OF CHAR);
 BEGIN
  Task.Init;
  LTL.Call(string);
  Task.Exit(0);
 END Call;


PROCEDURE StringEntered(v: TermWin.Viewer; VAR string: ARRAY OF CHAR);
  VAR
    startTime: LONGINT;
 BEGIN
  IF string = "quit" THEN Task.Exit(0) END;
  Unprompt;
  startTime := Time.Get();
  Call(string);
  IF Time.Calc( startTime ) >= 2000 (* 2s *) THEN
    GC.Collect;
  END;
  Prompt;
 END StringEntered;


PROCEDURE Message() : BOOLEAN;
  VAR
    ptr: S.PTR;
    sp: POINTER TO ARRAY 100 OF CHAR;
 BEGIN
  IF GemApp.message[0] = VA.VASTART THEN
    ptr := GemApp.message[3] * 10000H + S.LONG( GemApp.message[4]);
    sp := ptr;
    IO.WriteString( sp^); IO.WriteLn;
    StringEntered( IO.viewer, sp^);
    RETURN TRUE
  END;
  RETURN FALSE;
 END Message;


PROCEDURE Run*;
 BEGIN
  Task.Init;
  GemApp.messageProcs.AddProc( Message);
  IO.viewer.StoreHandler(StringEntered);
  Prompt;
  GemApp.Run;
  Task.Exit(0);
 END Run;


PROCEDURE ShowInfo;
  VAR
    d: INTEGER;
 BEGIN
  d := Form.Alert( 1, "[0][Primitive shell|for STJ-Oberon-2|by Stephan Junker][Ok]");
 END ShowInfo;


PROCEDURE Exit;
 BEGIN
  GemApp.exit := TRUE;
 END Exit;


PROCEDURE Init;
 BEGIN
  Graf.ChangeMouse( Graf.ARROW);
  IF NOT Rsrc.Load("PSHELL.RSC") THEN
    Task.Exit(-1)
  END;
  NEW(menu); menu.Init( Rsrc.GetAddr(MENU) );
  menu.Set( FILE, QUIT, Exit );
  menu.Set( DESK, INFO, ShowInfo );
  menu.Show;
  Sys.Loader := TRUE;
  Run
 END Init;


BEGIN
  Init;
  Task.Exit(0);
END PShell.