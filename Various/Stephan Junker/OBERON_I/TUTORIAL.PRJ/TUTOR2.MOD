MODULE Tutor2;

(*
 Load a resource file.
 You can terminate it with Control-Q.
 *)

IMPORT
  GemApp, Graf, Rsrc, Task, Sys;


PROCEDURE Run*;
 BEGIN
  Graf.ChangeMouse( Graf.ARROW);
  IF NOT Rsrc.Load("GEMDEMO.RSC") THEN
    Task.Exit(0)
  END;
  GemApp.Run
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Tutor2.
