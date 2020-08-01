MODULE FIFO; (* by Dirk Theisen (dirk_theisen@su.maus.de) *)

(* Generic FIFO module. *)
(* Please extend Elem.  *)


TYPE

   Elem*     = POINTER TO ElemDesc;

   ElemDesc* = RECORD
                 next-  : Elem;
               END;

   fifo*     = RECORD
                 top-   : Elem;
                 last-  : Elem;
               END;


  PROCEDURE (VAR queue: fifo) Init*();
   BEGIN
    queue.top := NIL; queue.last := NIL;
   END Init;

  PROCEDURE (VAR queue: fifo) Empty*(): BOOLEAN;
    (* Returns TRUE if the fifo is empty.
       You can also use fifo.top=NIL      *)
  BEGIN
    RETURN queue.top=NIL
  END Empty;


  PROCEDURE (VAR queue: fifo) Put* (e: Elem);
    (* inserts element e *)
  BEGIN
    e.next:=NIL;
    IF queue.top=NIL (*EMPTY*) THEN
      queue.top := e;
      queue.last  := e;
    ELSE
      queue.last.next := e;
      queue.last      := e;
    END;
  END Put;


  PROCEDURE (VAR queue: fifo) Get* (VAR e: Elem);
    (* removes top element e (NIL, if empty) *)
  BEGIN
    e:= queue.top;
    IF e # NIL THEN
      queue.top:=queue.top.next;
      IF queue.top = NIL THEN
        queue.last:=NIL;
      END(*IF*);
    END(*IF*);
  END Get;

END FIFO.

