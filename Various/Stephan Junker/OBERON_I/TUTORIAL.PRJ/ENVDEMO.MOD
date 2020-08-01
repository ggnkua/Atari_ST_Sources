MODULE EnvDemo; (* SJ 16.12.94 *)

(*
 Enters the environment variables defined in OBERON.ENV in the environment
 and writes its contents onto IO.
 *)

(*$+x *)

IMPORT
  Sys, Task, StdPath, ObnEnv, IO, Strings;


PROCEDURE Write;
  VAR
    ptr: Strings.ptr;
 BEGIN
  ptr := Sys.Basepage.Env;
  WHILE ptr[0] # 0X DO
    IO.WriteString( ptr^); IO.WriteLn;
    INC(ptr, Strings.Length(ptr^) + 1);
  END;
 END Write;


PROCEDURE Run*;
 BEGIN
  IO.WriteString( "OBERON.ENV has to be in directory ");
  IO.WriteString( StdPath.stdPath);
  IO.WriteString( " to be found"); IO.WriteLn;
  Write;
 END Run;


BEGIN
  IF ~Sys.Loader THEN
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END EnvDemo.