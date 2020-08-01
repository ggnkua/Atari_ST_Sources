MODULE DCL;

(* DCL (DoubleChainedList) implements a double pointer chained list, i.e.
   a list of records which have one pointer to the next and one to the
   previous element. The base type Element can be extended for all purposes.
*)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |17.1.93  |started
S. Junker  |31.8.93  |reduced to neccessary
S. Junker  |7.11.93  |TBPs
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM;


TYPE Elem*    = POINTER TO Element;
     Element* = RECORD
                  next*,prev* : Elem;
                END(*RECORD*);
     List*    = POINTER TO ListDesc;
     ListDesc*= RECORD
                  root* : Elem; (* first element in list *)
                  last* : Elem; (* last element in list *)
                END;


PROCEDURE(l : List) Init*();
  (* initializes a list of elements *)
 BEGIN
  l.root := NIL; l.last := NIL;
 END Init;


PROCEDURE(l : List) Add*(e : Elem);
  (* adds element e at the beginning of list l *)
 BEGIN
  IF l.root # NIL THEN l.root.prev := e
  ELSE l.last := e
  END;
  e.next := l.root; e.prev := NIL; l.root := e;
 END Add;


PROCEDURE(l : List) Append*(e : Elem);
  (* adds element e at the end of list l *)
 BEGIN
  IF l.last # NIL THEN l.last.next := e
  ELSE l.root := e
  END;
  e.prev := l.last; e.next := NIL; l.last := e;
 END Append;


PROCEDURE(l : List) Delete*(e : Elem);
  (* deletes element e in list l. The memory is not disposed! *)
 BEGIN
  IF e.next # NIL THEN e.next.prev := e.prev
  ELSE l.last := e.prev
  END;
  IF e.prev # NIL THEN e.prev.next := e.next
  ELSE l.root := e.next
  END;
 END Delete;


PROCEDURE(l : List) Insert*(next, e : Elem);
  (* inserts element e in list l in front of element next. This element
   * will become the next element of e. If next is NIL, e will become
   * the last element. This is done quicker with l.Append(e).
   * If next is equal to list.root, e will become the first element in
   * the list. This is done quicker with l.Add(e).
   *)
 BEGIN
  IF next = l.root THEN		(* at the beginning *)
    l.Add(e)
  ELSIF next = NIL THEN		(* at the end *)
    l.Append(e);
  ELSE				(* inbetween *)
    e.next := next; e.prev := next.prev;
    next.prev := e; e.prev.next := e;
  END;
 END Insert;


END DCL.
