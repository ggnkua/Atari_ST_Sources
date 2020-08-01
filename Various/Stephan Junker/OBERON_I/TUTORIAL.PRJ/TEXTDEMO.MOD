MODULE TextDemo;

(*
 * Kleines Modul zur Demonstration der Benutzung von TextViewer.
 * Zum Beendigen Control-Q drÅcken.
 *)


IMPORT
  TextViewer, GemApp, Fsel, Sys, Task;


PROCEDURE Run*;
  VAR
    v : TextViewer.Viewer;
    m : TextViewer.Model;
    path, name : ARRAY 80 OF CHAR;
 BEGIN
  path := "C:\"; name := "";
  IF Fsel.ExInput(path, name, "Asciitext anzeigen") THEN
    NEW(m); m.Initialize;	(* create model *)
    m.LoadText( name);		(* load text *)
    NEW(v); v.Initialize;	(* create viewer *)
    v.SetModel(m);		(* displaying m *)
    v.SetTitle( name);		(* title = file *)
    v.Open;			(* open window *)
    GemApp.Run;
  END;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END TextDemo.