MODULE ShowCommands;

(*
 Little demonstration of how to use the module CommandLine to get the
 command line parameters
 *)

IMPORT
  IO, CommandLine, Sys, Task;


PROCEDURE Run*;
 BEGIN
  IO.WriteString( "Command line arguments:"); IO.WriteLn;
  WHILE CommandLine.arg # NIL DO
    IO.WriteString( CommandLine.arg^); IO.WriteLn;
    CommandLine.Next;
  END;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END ShowCommands.