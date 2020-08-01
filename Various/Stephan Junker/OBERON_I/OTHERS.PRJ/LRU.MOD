MODULE LRU; (* OBERON-2 *)

(* generic LRU (least recently used) - lists *)

(*    7'93 by Dirk_Theisen@SU.maus.de       *)


CONST

  (* traverse modes *)

  mrufirst* = 0; lrufirst* = 1;


TYPE


  Elem*     = POINTER TO ElemDesc;

  ElemDesc* = RECORD
                  prev- : Elem; (* more often used *)
                  next- : Elem; (* less often used *)
                  used- : INTEGER;
                END;

  List*     = RECORD
                mru : Elem;
                lru : Elem;
              END;


  DoProc* = PROCEDURE(e:Elem): BOOLEAN;


  PROCEDURE (x:Elem) EqualTo* (y:Elem):BOOLEAN;  (* please override *)
  BEGIN
    HALT(101);
  END EqualTo;


  PROCEDURE (VAR list: List) Init*;
  BEGIN
    list.mru:=NIL;
    list.lru:=NIL;
  END Init;


  PROCEDURE Normalize(list: List);
  VAR e: Elem;
  BEGIN
    e:=list.mru;
    WHILE e # NIL DO
      e.used:=e.used DIV 64 (* faster *);
      e:=e.next;
    END(*WHILE*);
  END Normalize;


  PROCEDURE (VAR list: List) Use*(el:Elem);
  (* call this proc when Element el in LRU is used *)
  VAR
    ne : Elem;  (* previous element *)
  BEGIN
    INC(el.used);
    IF el.used=MAX(INTEGER) THEN
      Normalize(list);
    END(*IF*);
    ne := el.next;
    WHILE (ne # NIL) & (el.used>ne.used) DO
      (* move g upward in list-Elem *)
      (* i.e. swap ne and el *)
      el.next     :=ne.next;
      IF el.next # NIL THEN el.next.prev:=el
      ELSE list.lru := el
      END;
      ne.prev     :=el.prev;
      IF ne.prev # NIL THEN ne.prev.next:=ne
      ELSE list.mru := ne
      END;
      ne.next     :=el;
      el.prev     :=ne;
      ne := el.next;
    END;
  END Use;


  PROCEDURE (VAR list: List) Insert*(el: Elem);
  (* adds an element el to the end of LRU-List list. *)
  BEGIN
    el.next := NIL;
    el.prev := list.lru;
    el.used := 0;
    IF list.lru = NIL THEN list.mru := el
    ELSE list.lru.next:=el
    END;
    list.lru :=el;
  END Insert;


  PROCEDURE (VAR list:List) Delete* (el:Elem);
  (* removes element el from LRU-list LRU. *)
  BEGIN
    el.next.prev:=el.prev;
    el.prev.next:=el.next;
    IF list.mru=el THEN
      list.mru:=el.prev;
    ELSIF list.lru=el THEN
      list.lru:=el.prev;
    END(*IF*)
  END Delete;


  PROCEDURE (VAR list:List) Traverse*(mode:SHORTINT; more: DoProc);
  (* calls proc more for the least recently used elements of LRU list and
     stops if more returns FALSE *)
  VAR
    s : Elem;
  BEGIN
    CASE mode OF
      lrufirst: s:=list.lru;
         WHILE (s # NIL) & more(s) DO
           s:=s.prev;
         END(*WHILE*);
     |mrufirst: s:=list.mru;
         WHILE (s # NIL) & more(s) DO
           s:=s.next;
         END(*WHILE*);
    ELSE
      HALT(101);
    END(*CASE*);
  END Traverse;


  PROCEDURE (VAR list:List) Search* (x:Elem):Elem;
  (* searches fpr the element x in list using procedure EqualTo.
     MRU first. *)
  VAR s: Elem;
  BEGIN
    s:=list.mru;
    WHILE (s # NIL) & (~s.EqualTo(x)) DO
      s:=s.next;
    END(*WHILE*);
  END Search;


END LRU.
