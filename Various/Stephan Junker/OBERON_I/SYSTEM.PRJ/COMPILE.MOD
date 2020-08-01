MODULE Compile;

(*
 Execute compiler as program.
 *)


IMPORT
  OComp, Task;


BEGIN
  OComp.Compile;
  Task.Exit( Task.retCode)
END Compile.