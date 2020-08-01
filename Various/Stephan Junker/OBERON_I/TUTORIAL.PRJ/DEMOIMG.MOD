MODULE DemoIMG;

(*
 * Demonstrates usage of IMGViewer. Terminate with control Q.
 *)


IMPORT
  IMGViewer, GemApp, Fsel, Sys, Task;


TYPE
  Viewer*   = POINTER TO ViewDesc;
  ViewDesc* = RECORD(IMGViewer.ViewDesc)
              END(*RECORD*);



PROCEDURE(v : Viewer) Close*();
(* also terminates the program *)
 BEGIN
  v.Close^;
  GemApp.exit := TRUE;
 END Close;


PROCEDURE Run*;
  VAR
    vi : Viewer;
    mi : IMGViewer.Model;
    path, name : ARRAY 80 OF CHAR;
 BEGIN
  path := "F:\TEX\*.IMG"; name := "";
  IF Fsel.ExInput(path, name, "IMG-Bild anzeigen") THEN
    NEW(mi); mi.Initialize; (* create model *)
    mi.Load( name);         (* load file *)
    NEW(vi); vi.Initialize;
    vi.SetModel(mi);        (* create viewer displaying mi *)
    vi.SetTitle( name);     (* title = file *)
    vi.Open;                (* open window *)
    GemApp.Run;
  END;
 END Run;


BEGIN
  IF ~Sys.Loader THEN
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END DemoIMG.
