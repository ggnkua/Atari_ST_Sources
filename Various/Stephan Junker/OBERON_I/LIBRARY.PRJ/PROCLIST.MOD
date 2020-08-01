MODULE ProcList; (* SJ 7.12.94 *)

(*
 ProcList is a LinkedList extension used to store procedures without
 parameters. If other procedure types are desired, you can copy the
 contents of this module and replace the type Proc by another procedure
 type and change method Execute.
 *)


IMPORT
  S:=SYSTEM, LinkedList;



TYPE
  Proc* = PROCEDURE () : BOOLEAN;

  ElemDesc* = RECORD(LinkedList.ElemDesc)
    proc*: Proc;
  END;
  Element*  = POINTER TO ElemDesc;

  Desc* = RECORD(LinkedList.Desc)
  END;
  Ptr* = POINTER TO Desc;



PROCEDURE (VAR self: Desc) AddProc*(proc: Proc);
(*
 Add a procedure to the list.
 *)
  VAR
    e: Element;
 BEGIN
  NEW(e); e.proc := proc;
  self.Add(e);
 END AddProc;


PROCEDURE (VAR self: Desc) RemoveProc*(proc: Proc);
(*
 Remove a procedure from the list.
 *)

  PROCEDURE~ Remove(e: LinkedList.Element);
   BEGIN
    IF e(Element).proc = proc THEN
      self.Remove(e); RETURN^
    END;
   END Remove;

 BEGIN
  self.Do( Remove)
 END RemoveProc;


PROCEDURE (VAR self: Desc) Execute*;
(*
 Execute all procedures stored in the receiver. Execution stops if a
 procedure returns TRUE.
 *)

  PROCEDURE~ Exec(e: LinkedList.Element);
   BEGIN
    IF e(Element).proc() THEN RETURN^ END;
   END Exec;

 BEGIN
  self.Do( Exec)
 END Execute;


PROCEDURE (VAR self: Desc) RemoveBetween*(from, to: S.PTR);
(*
 Call this method if the code from from to to has been removed. It will
 remove all procedures in the receiver list which are inbetween those two
 addresses.
 *)

  PROCEDURE ~RemoveProcs(e: LinkedList.Element);
    VAR
      proc: Proc;
   BEGIN
    proc := e(Element).proc;
    IF (S.VAL( S.PTR, proc) >= from) & (S.VAL( S.PTR, proc) < to) THEN
      self.Remove(e);
    END;
   END RemoveProcs;

 BEGIN
  self.Do( RemoveProcs);
 END RemoveBetween;


END ProcList.