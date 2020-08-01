MODULE WinDemo; (* SJ 4.12.94 *)

(*
 Demonstrates usage of module WinView.
 *)


IMPORT
  WinView, GemApp, Sys, Task;



PROCEDURE Run*;
  VAR
    v : WinView.Viewer;
 BEGIN
  NEW(v); v.Initialize;    (* create viewer *)
  v.SetTitle( "WinView demo");
  v.Open;                  (* open window *)
  GemApp.Run;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END WinDemo.