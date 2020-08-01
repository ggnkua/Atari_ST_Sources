MODULE Skeleton;

(*
 Describes the basic structure of a program developped with STJ-Oberon-2
 V2.XX.

 Additional notes:
 - In V2.05, it is necessary to rebuild window dialogs whenever the
   application is executed. In future versions, this should be needed only
   once in the module initialization.
 *)


IMPORT
  Sys, GemApp, Task; (* for GEM applications only *)


PROCEDURE Run*;
(*
 The exported Run procedure is called whenever the module name is used as
 command without specifying a procedure name.
 Run executes the program.
 *)
 BEGIN
  (* ... *)
  GemApp.Run;   (* for GEM applications only *)
 END Run;


BEGIN
  (* Initialize your module here *)
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Skeleton.