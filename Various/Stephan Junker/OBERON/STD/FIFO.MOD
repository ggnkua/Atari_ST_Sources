MODULE Fifo;

(* if not more values are popped than pushed, the first element must not
   be initialized, else it should be initialized to NIL. Emptyness can be
   tested by comparison with NIL *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |23.1.93  |started
----------------------------------------------------------------------------
*)

IMPORT CDCL:=CircularDoubleChainedList;

TYPE list* = POINTER TO fifo;
     fifo  = RECORD (CDCL.elem)
               NumVal : INTEGER;
               Values : ARRAY 10 OF LONGINT
             END(*RECORD*);

PROCEDURE Push*(VAR List : list; Value : LONGINT);
 (* stores Value. If a long word is not enough, it may be interpreted as
    a pointer to values *)
  VAR e : list;
 BEGIN
  IF (List # NIL) AND (List.NumVal # 10) THEN
    List.Values[List.NumVal] := Value; INC(List.NumVal)
  ELSE
    NEW(e); e.Values[0] := Value; e.NumVal := 1; CDCL.Add(List,e);
  END(*IF*);
 END Push;

PROCEDURE Pop*(VAR List : list) : LONGINT;
 (* reads the value that was last pushed. If no value was pushed, the
    Debugger is called via HALT(9) *)
  VAR e : list;
 BEGIN
  IF List # NIL THEN
    e := List.Prev; DEC(e.NumVal);
    IF e.NumVal = 0 THEN CDCL.Extract(List,e) END;
    RETURN e.Values[e.NumVal];
  END(*IF*);
  HALT(9);
 END Pop;

BEGIN
END Fifo.
