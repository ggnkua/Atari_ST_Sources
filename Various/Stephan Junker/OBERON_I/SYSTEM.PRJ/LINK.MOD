MODULE Link;

(*
 Execute linker as program.
 *)

IMPORT
  OLink, Task;


BEGIN
  OLink.Link;
  Task.Exit( Task.retCode)
END Link.