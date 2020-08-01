MODULE DoubleChainedList;

(* DoubleChainedList implements a double pointer chained list, i.e.
   a list of records which have one pointer to the next and one to the
   previous element. The base type elem can be extended for all purposes.
   The process number and a user-defined handle is stored and both can be
   searched. Used in Wind,VdiControl etc. to store opened windows etc. *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |17.1.93  |started
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Error, Task;

TYPE elptr*  = POINTER TO elem;
     elem*   = RECORD
                 Next*,Prev* : elptr;
                 Handle*,Task* : INTEGER;
               END(*RECORD*);
     dproc*  = PROCEDURE (Elem : elptr);

PROCEDURE Add*(VAR List : elptr; Elem : elptr);
 (* adds an element at the beginning of List *)
 BEGIN
  IF List # NIL THEN List.Prev := Elem END;
  Elem.Next := List; Elem.Prev := NIL; List := Elem;
 END Add;

PROCEDURE Extract*(VAR List : elptr; Elem : elptr);
 (* extracts an element from List *)
 BEGIN
  IF Elem.Next # NIL THEN Elem.Next.Prev := Elem.Prev END;
  IF Elem.Prev # NIL THEN Elem.Prev.Next := Elem.Next
  ELSE List := Elem.Next END;
 END Extract;

PROCEDURE New*(VAR List : elptr; Elem : elptr; Handle : INTEGER);
 (* initialize Elem and add it to List *)
 BEGIN
  Elem.Handle := Handle; Elem.Task := Task.Current; Add(List,Elem);
 END New;

PROCEDURE Search*(List : elptr; Handle : INTEGER; VAR Elem : elptr) : BOOLEAN;
 (* search element with Handle. RETURN FALSE if not found *)
  VAR p : elptr;
 BEGIN
  p := List;
  WHILE p # NIL DO
    IF p.Handle = Handle THEN Elem := p; RETURN TRUE END;
    p := p.Next;
  END(*WHILE*);
  RETURN FALSE
 END Search;

PROCEDURE Find*(List : elptr; Handle : INTEGER; VAR Elem : elptr) : BOOLEAN;
 (* search element with Handle. RETURN FALSE if not found and show error *)
 BEGIN
  IF Search(List,Handle,Elem) THEN RETURN TRUE END;
  Error.NumOut(-100); RETURN FALSE
 END Find;

PROCEDURE Delete*(VAR List : elptr; Handle : INTEGER; VAR Elem : elptr) : BOOLEAN;
 (* extracts the first elements with handle Handle. FALSE is returned if
    no element has this handle. The extracted element is returned *)
 BEGIN
  IF Search(List,Handle,Elem) THEN Extract(List,Elem); RETURN TRUE END;
  RETURN FALSE
 END Delete;

PROCEDURE SearchTask*(List : elptr; Task : INTEGER; VAR Elem : elptr)
          : BOOLEAN;
 (* returns the first element with task Task. Returns FALSE if no task
    found *)
  VAR r : elptr;
 BEGIN
  r := List;
  WHILE r # NIL DO
    IF r.Task = Task THEN Elem := r; RETURN TRUE END;
    r := r.Next;
  END(*WHILE*);
  RETURN FALSE
 END SearchTask;

PROCEDURE DeleteTask*(VAR List : elptr; Task : INTEGER; Delete : dproc);
 (* runs through List, calls Delete on every element which has the task
    number Task and extracts the element. Delete may be NIL *)
  VAR p : elptr;
 BEGIN
  p := List;
  WHILE p # NIL DO
    IF p.Task = Task THEN
      IF Delete # NIL THEN Delete(p) END;
      Extract(List,p);
    END(*IF*);
    p := p.Next;
  END(*WHILE*);
 END DeleteTask;

END DoubleChainedList.
