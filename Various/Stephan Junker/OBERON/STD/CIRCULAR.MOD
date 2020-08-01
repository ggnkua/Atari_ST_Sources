MODULE CircularDCL;

(* CircularDoubleChainedList implements a double pointer chained list, i.e.
   a list of records which have one pointer to the next and one to the
   previous element. The base type elem can be extended for all purposes.
   The list is circular *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |17.1.93  |started
----------------------------------------------------------------------------
*)

TYPE elptr*  = POINTER TO elem;
     elem*   = RECORD
                 Next*,Prev* : elptr;
               END(*RECORD*);

PROCEDURE Add*(VAR List : elptr; Elem : elptr);
 (* adds an element at the beginning of List *)
 BEGIN
  IF List = NIL THEN List := Elem; Elem.Next := Elem; Elem.Prev := Elem;
  ELSE Elem.Next := List; Elem.Prev := List.Prev; List := Elem;
    Elem.Prev.Next := Elem; Elem.Next.Prev := Elem;
  END(*IF*);
 END Add;

PROCEDURE Extract*(VAR List : elptr; Elem : elptr);
 (* extracts an element from List *)
 BEGIN
  Elem.Prev.Next := Elem.Next; Elem.Next.Prev := Elem.Prev;
  IF List = Elem THEN
    IF Elem.Next = Elem THEN List := NIL; ELSE List := Elem.Next END;
  END(*IF*);
 END Extract;

END CircularDCL.
