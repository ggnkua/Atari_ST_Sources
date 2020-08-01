MODULE HelloWorld; (* SJ *)

(* demo module: writes "Hello world". Call it with LOAD.TTP or link it
   with TOS modules. Works with GEM modules as well. But be careful:
   Compilation must be done with TOS paths, because otherwise the use of
   module Event is entered in the object file (don't know why) and this
   module won't be found in TOS paths.
*)

IMPORT
  IO, Sys, Task;


PROCEDURE Run*;
  VAR
    c : CHAR;
 BEGIN
(*  IO.ClearHome;*)
  IO.WriteString("Hello world"); IO.WriteLn;
  IO.WriteString("Press any key ..."); IO.WriteLn;
  c := IO.ReadChar();
 END Run;


BEGIN
  IF ~Sys.Loader THEN
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END HelloWorld.