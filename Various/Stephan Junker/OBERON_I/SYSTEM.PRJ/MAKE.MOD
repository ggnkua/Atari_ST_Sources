MODULE Make;

(*
 Execute make as program
 *)

IMPORT
  OMake, Task;


BEGIN
  OMake.Make;
  Task.Exit( Task.retCode)
END Make.