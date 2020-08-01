MODULE Tutor1;

(*
 The simplest GEM application: Do nothing.
 You can terminate it by Control-Q.
 *)

IMPORT
  GemApp, Sys, Task;


PROCEDURE Run*;
 BEGIN
  GemApp.Run
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Tutor1.
