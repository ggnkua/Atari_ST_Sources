MODULE Stack;

(* if not more values are popped than pushed, the first element must not
   be initialized *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |23.1.93  |correction for Oberon
S. Junker  |2.5.93   |simplified
----------------------------------------------------------------------------
*)

IMPORT Task;

TYPE elem* = POINTER TO stk;
     stk   = RECORD
               Next   : elem;
               NumVal : INTEGER;
               Values : ARRAY 10 OF LONGINT
             END(*RECORD*);

PROCEDURE Push*(VAR First : elem; Value : LONGINT);
 (* stores Value. If a long word is not enough, it may be interpreted as
    a pointer to values *)
  VAR e : elem;
 BEGIN
  IF (First # NIL) AND (First.NumVal # 10) THEN
    First.Values[First.NumVal] := Value; INC(First.NumVal)
  ELSE NEW(e);
    e.Values[0] := Value; e.Next := First; e.NumVal := 1; First := e;
  END(*IF*);
 END Push;

PROCEDURE Pop*(VAR First : elem) : LONGINT;
 (* reads the value that was last pushed. If no value was pushed, 0 is
    returned *)
  VAR r : LONGINT; e,f : elem;
 BEGIN
  IF (First # NIL) AND (First.NumVal # 0) THEN
    DEC(First.NumVal);
    r := First.Values[First.NumVal];
    IF First.NumVal = 0 THEN f := First; e := f;
      WHILE e.Next # NIL DO e := e.Next END;
      e.Next := f; First := f.Next; f.Next := NIL;
    END;
    RETURN r
  END(*IF*); 
  RETURN 0;
 END Pop;

PROCEDURE Empty*(First : elem) : BOOLEAN;
 BEGIN
  RETURN (First = NIL) OR (First.NumVal = 0);
 END Empty;
 
END Stack.
