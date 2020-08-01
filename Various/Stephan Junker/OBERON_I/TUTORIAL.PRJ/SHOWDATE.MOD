MODULE ShowDate; (* SJ 9.11.94 *)

IMPORT
  IO, Sys, Task;


PROCEDURE Run*;
 BEGIN
  IO.WriteString( "ShowDate was compiled on the ");
  IO.WriteString( Sys.compDate);
  IO.WriteString( " at ");
  IO.WriteString( Sys.compTime);
  IO.WriteLn;
  IO.WriteString( "The stack size is ");
  IO.WriteInt( Sys.stackSize);
  IO.WriteLn;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END ShowDate.