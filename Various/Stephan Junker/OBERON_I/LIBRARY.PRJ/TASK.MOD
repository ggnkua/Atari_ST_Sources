MODULE Task; (* Stephan Junker  29.3.93 / 12.11.93 / 25.11.94 *)

(*
 Task plays a key role in the OPE design. It is possible to mark the
 starting point of a task by Task.Init. It is then possible to terminate
 that task anywhere using Task.Exit. This procedure calls the procedures
 stored by Task.StoreExit which should clean up the global variables. It is
 important to set unused pointers to NIL, otherwise their memory will not
 be disposed. You could perform this by an explicit call of an exit
 procedure, but what if there was an exception and your module had to be
 terminated earlier? Therefore you should always link a procedure here.
 OPE will initialize a new task whenever a module is executed. A client
 module may use a new task if a breakdown should not terminate the whole
 program.
 A typical task call will look like this:

 PROCEDURE Run() : INTEGER;
  BEGIN
   Task.Init;
   DoIt;
   Task.Exit(0);
  END Run;

 Run will execute DoIt and return the task return value. If it is
 terminated correctly and Task.Exit(0) reached, the return value is 0. If
 there was an exception and DoIt was forced to terminate, the return value
 will be a negative value reflecting the kind of error. These values are
 identical to the TOS error values.
 Task.Run implements this kind of task call.
 *)


IMPORT
  S:=SYSTEM, GEMDOS, Sys, LinkedList;



TYPE
  Proc* = PROCEDURE;
  CodeRemovedProc* = PROCEDURE (from, to: S.PTR) : BOOLEAN;

  ProcElem = POINTER TO RECORD(LinkedList.ElemDesc)
    proc : Proc;
  END;

  CodeProcElem = POINTER TO RECORD(LinkedList.ElemDesc)
    proc : CodeRemovedProc;
  END;



VAR
  level* : INTEGER;
  retCode-: INTEGER;
  (*
   Contains the parameter of Exit when the exit procedures are called.
   *)

  ProcessA6 : ARRAY 10 OF LONGINT;
  initProcs, exitProcs, removeProcs : LinkedList.Desc;
  exiting: BOOLEAN;



PROCEDURE StoreInit*(proc: Proc);
(*
 Store a procedure to be called every time a new task is initialized.
 Then Task.level already contains the new level.
 *)
  VAR
    e: ProcElem;
 BEGIN
  NEW(e); e.proc := proc;
  initProcs.Add(e);
 END StoreInit;


PROCEDURE Init*;
(*
 Initialize a task. All procedures stored with StoreInit are called.
 *)
  VAR
    p: LONGINT;

  PROCEDURE~ Call(e: LinkedList.Element);
   BEGIN
    e(ProcElem).proc;
   END Call;

 BEGIN
  S.GETREG(14,p); S.GET( p, ProcessA6[level]); INC( level);
  initProcs.Do( Call);
 END Init;


PROCEDURE StoreExit*(proc : Proc);
(*
 stores a procedure to be called every time a task is terminated. Then
 Task.level still has the level of the task to be terminated.
 *)
  VAR
    e: ProcElem;
 BEGIN
  NEW(e); e.proc := proc;
  exitProcs.Add(e);
 END StoreExit;


PROCEDURE CallExitProc(e: LinkedList.Element);
  VAR
    prevHalt: Sys.haltproc;

  PROCEDURE~ ExitHalt(no: INTEGER);
   BEGIN
    RETURN^
   END ExitHalt;

 BEGIN
  prevHalt := Sys.Halt; Sys.Halt := ExitHalt;
  e(ProcElem).proc;
  Sys.Halt := prevHalt;
 END CallExitProc;

(*$-k no stack check: could be called after stack overflow *)

PROCEDURE Exit*(retcode: INTEGER);
(*
 Terminate a task. All procedures stored with StoreExit are called.
 Program execution is continued in the procedure that called the procedure
 which called Task.Init.
 retcode is returned to the calling task.
 *)
 BEGIN
  retCode := retcode;
  IF ~exiting THEN	(* no recursive exit *)
    exiting := TRUE;
    exitProcs.Do( CallExitProc);
    exiting := FALSE;
  END;
  DEC( level);
  IF level < 0 THEN GEMDOS.Pterm(retcode) END;
  S.PUTREG(8, ProcessA6[level]);
  ASSEMBLER
    MOVE.W retcode,D0
    MOVE.L A0,A6
  END;
 END Exit;

(*$+k *)

PROCEDURE Run*(proc: Proc) : INTEGER;
(*
 Calls proc in a new task and returns the task return value.
 *)
 BEGIN
  Init;
  proc;
  Exit(0);
 END Run;


PROCEDURE CallExits*;
(*
 Call the stored exit procedures.
 *)
 BEGIN
  exitProcs.Do( CallExitProc);
 END CallExits;


PROCEDURE StoreCodeRemoveProc*(proc: CodeRemovedProc);
(*
 Store proc in order to be called if code has been removed. The main
 function of such a procedure is to remove procedure variables. It will
 receive the start address of text segment and the end address of data
 segment as parameters. It must return true if the code may be removed
 physically.
 *)
  VAR
    e: CodeProcElem;
 BEGIN
  NEW(e); e.proc := proc;
  removeProcs.Add(e);
 END StoreCodeRemoveProc;


PROCEDURE CodeRemoved*(from, to: S.PTR) : BOOLEAN;
(*
 Called by LTL if it removed code. from is start address of text segment
 and to is end address of data segment. It answers true if all stored
 procedures answer true (= code may be removed).
 *)
  VAR
    remove: BOOLEAN;

  PROCEDURE ~CallRemoveProc(e: LinkedList.Element);
    VAR
      proc: CodeRemovedProc;
   BEGIN
    proc := e(CodeProcElem).proc;
    IF ~proc(from, to) THEN remove := FALSE END;
    IF (S.VAL( S.PTR, proc) >= from) & (S.VAL( S.PTR, proc) < to) THEN
      removeProcs.Remove(e);
    END;
   END CallRemoveProc;

  PROCEDURE ~RemoveInits(e: LinkedList.Element);
    VAR
      proc: Proc;
   BEGIN
    proc := e(ProcElem).proc;
    IF (S.VAL( S.PTR, proc) >= from) & (S.VAL( S.PTR, proc) < to) THEN
      initProcs.Remove(e);
    END;
   END RemoveInits;

  PROCEDURE ~RemoveExits(e: LinkedList.Element);
    VAR
      proc: Proc;
   BEGIN
    proc := e(ProcElem).proc;
    IF (S.VAL( S.PTR, proc) >= from) & (S.VAL( S.PTR, proc) < to) THEN
      exitProcs.Remove(e);
    END;
   END RemoveExits;

 BEGIN
  remove := TRUE;
  removeProcs.Do( CallRemoveProc);
  initProcs.Do( RemoveInits);
  exitProcs.Do( RemoveExits);
  RETURN remove;
 END CodeRemoved;


BEGIN
  initProcs.Initialize;
  exitProcs.Initialize;
  removeProcs.Initialize;
END Task.
