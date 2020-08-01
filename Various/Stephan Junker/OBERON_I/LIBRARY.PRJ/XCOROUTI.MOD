MODULE XCoroutines; (* SJ 27.2.95 *)

(*
 Extended coroutine control.
 If a coroutine calls Task.Exit with -1 as parameter (severe error), it is
 removed from the list and execution transferred to the main routine.
 *)


IMPORT
  S:=SYSTEM, Coroutines, LinkedList, XBIOS, Task;



TYPE
  CoroutinePtr* = POINTER TO Coroutines.Coroutine;

  Coroutine* = POINTER TO RECORD(LinkedList.ElemDesc)
    coroutine: CoroutinePtr;
  END;


VAR
  main- : Coroutine;
  (*
   To be used by the main program as source when calling
   Coroutines.Transfer. main is not entered in the coroutine list.
   *)

  current-: Coroutine;
  (*
   A pointer to the currently active coroutine. To be used as source
   coroutine when calling Transfer.
   *)

  previous-: Coroutine;
  (*
   A pointer to the previously active coroutine. To be used as destination
   coroutine when calling Transfer if you want to transfer to the routine
   which called the current one.
   *)

  nextMain*: BOOLEAN;
  (*
   Usually false. If true, a call of Next will return main if the current
   coroutine is not main. This behaviour is set by LTL in order to execute
   only one coroutine in the timer event.
   *)

  lastNext: Coroutine;

  list: LinkedList.Desc;

  endTime, currTime: LONGINT;

  mainCoroutine: Coroutines.Coroutine;


(*$-k *)

PROCEDURE GetTime;
 BEGIN
  S.GET( 4BAH, currTime);
 END GetTime;

(*$+k *)


PROCEDURE Time(): LONGINT;
 BEGIN
  XBIOS.Supexec( GetTime);
  RETURN currTime;
 END Time;


PROCEDURE New*(body: Coroutines.Body; stackSize: LONGINT) : Coroutine;
(*
 Answer a new coroutine. The coroutine is added to the list.
 *)
  VAR
    coroutine: Coroutine;
 BEGIN
  NEW(coroutine); NEW(coroutine.coroutine);
  Coroutines.Init( body, stackSize, coroutine.coroutine^);
  list.Add(coroutine);
  RETURN coroutine;
 END New;


PROCEDURE Transfer*(from, to: Coroutine);
(*
 Transfer cpu access from coroutine from to coroutine to.
 *)
 BEGIN
  IF Time() > endTime THEN
    current := to; previous := from;
    Coroutines.Transfer(from.coroutine^, to.coroutine^);
  END;
 END Transfer;


PROCEDURE TransferTime*(from, to: Coroutine; time: LONGINT);
(*
 Transfer cpu access from coroutine from to coroutine to. Subsequent calls
 of Transfer or TransferTime will be ignored until time * 5ms has elapsed.
 *)
 BEGIN
  IF Time() > endTime THEN
    endTime := Time() + time;
    current := to; previous := from;
    Coroutines.Transfer(from.coroutine^, to.coroutine^);
  END;
 END TransferTime;


PROCEDURE ClearTime*;
(*
 Reset the timer so that the next transfer is executed.
 *)
 BEGIN
  endTime := 0;
 END ClearTime;


PROCEDURE Next*() : Coroutine;
(*
 Answer the next coroutine in the list or main if none.
 *)
  VAR
    next: Coroutine;
 BEGIN
  IF list.IsEmpty() THEN
    lastNext := NIL; RETURN main
  END;
  IF current = main THEN
    IF list.Includes(lastNext) THEN
      lastNext := lastNext.next;
    ELSE
      lastNext := list.root;
    END;
  ELSIF nextMain THEN
    RETURN main;
  ELSE
    lastNext := current.next;
  END;
  RETURN lastNext;
 END Next;


PROCEDURE Add*(VAR coroutine : Coroutines.Coroutine) : Coroutine;
(*
 Add a coroutine to the list. Answer the coroutine.
 *)
  VAR
    e: Coroutine;
 BEGIN
  NEW(e); e.coroutine := S.ADR( coroutine);
  list.Add(e);
  RETURN e;
 END Add;


PROCEDURE Remove*(coroutine: Coroutine);
(*
 Remove a coroutine from the list and dispose its stack memory. If the
 removed coroutine is the current one, Transfer is called to transfer
 operation to the next coroutine.
 *)
 BEGIN
  Coroutines.Dispose( coroutine.coroutine^);
  list.Remove( coroutine);
  IF coroutine = current THEN
    IF list.IsEmpty() THEN current := NIL END;
    ClearTime;
    Transfer( coroutine, Next());
  END;
 END Remove;


PROCEDURE RemoveProcs(from, to: S.PTR) : BOOLEAN;
  VAR
    remCurr: BOOLEAN;

  PROCEDURE ~RemoveProc(e: LinkedList.Element);
    VAR
      proc: S.PTR;
   BEGIN
    proc := e(Coroutine).coroutine.codeAddress;
    IF (S.VAL( S.PTR, proc) >= from) & (S.VAL( S.PTR, proc) < to) THEN
      IF e # current THEN Remove( e(Coroutine) )
      ELSE remCurr := TRUE
      END;
    END;
   END RemoveProc;

 BEGIN
  remCurr := FALSE;
  list.Do( RemoveProc);
  IF remCurr THEN Remove(current) END;
  RETURN TRUE
 END RemoveProcs;


PROCEDURE Exit;
 BEGIN
  IF (Task.retCode = -1) & (current # main) THEN
    list.Remove(current);
    Transfer(current, main);
  END;
 END Exit;


BEGIN
  list.Initialize;
  main := Add( mainCoroutine);
  list.Remove(main);
  current := main;
  Task.StoreExit(Exit);
  Task.StoreCodeRemoveProc( RemoveProcs);
END XCoroutines.