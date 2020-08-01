MODULE MouseDemo; (* SJ 10.12.94 *)

(*
 Demonstrates how to use mouse events
 *)


IMPORT
  GemApp, WinView, IO, Task, Sys;


TYPE
  Viewer = POINTER TO RECORD(WinView.ViewDesc)
  END;


VAR
  v : Viewer;


PROCEDURE (v: Viewer) HandleMouseEvent*(mbut : SET; mx, my, clicks : INTEGER) : BOOLEAN;
  VAR
    row : INTEGER;
 BEGIN
  row := SHORT( (my - v.y + v.yOff) DIV 16);
  IO.WriteInt( row); IO.WriteChar( ",");
  IO.WriteInt( mx); IO.WriteChar( ",");
  IO.WriteInt( my); IO.WriteLn;
  RETURN TRUE
 END HandleMouseEvent;


PROCEDURE Run*;
 BEGIN
  NEW(v); v.Initialize;		(* create viewer *)
  v.SetTitle( "Mouse demo");
  v.Open;			(* open window *)
  GemApp.Run;
 END Run;


BEGIN
  IF ~Sys.Loader THEN
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END MouseDemo.