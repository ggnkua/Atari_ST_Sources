MODULE Application; (* SJ 7.12.94 *)


IMPORT
  S:=SYSTEM, ProcList, Task;



VAR
  timerProcs-: ProcList.Desc;
  (*
   Add your procedures to timerProcs
   *)



PROCEDURE Run*;
(*
 Call all stored timerProcs. This is the dafault operation if a TOS
 application is executed. If GemApp is linked, Run will be redirected to
 GemApp.Run, so that the program will run under GEM.
 Run is an endless loop.
 *)
 BEGIN
  LOOP
    timerProcs.Execute;
  END;
 END Run;


PROCEDURE RemoveProcs(from, to: S.PTR) : BOOLEAN;
 BEGIN
  timerProcs.RemoveBetween( from, to);
  RETURN TRUE
 END RemoveProcs;


BEGIN
  timerProcs.Initialize;
  Task.StoreCodeRemoveProc( RemoveProcs);
END Application.

