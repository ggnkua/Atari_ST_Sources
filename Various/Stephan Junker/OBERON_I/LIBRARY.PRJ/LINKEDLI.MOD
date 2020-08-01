MODULE LinkedList;

(*
 LinkedList implements a list of elements which are connected by a pointer
 to the next and previous element. The last element is connected with the
 first.
 To store elements, you must extend ElemDesc to hold the data you desire.
 This is very time and space efficient, but not very flexible. Such
 elements can only be stored in one LinkedList.

 LinkedList is an advanced version of DCL. DCL will not be supported
 anymore.
 *)


TYPE
  Element*  = POINTER TO ElemDesc;
  ElemDesc* = RECORD
    next-, prev- : Element;
  END;

  Desc* = RECORD
    root- : Element; (* first element in list *)
  END;
  Ptr* = POINTER TO Desc;

  DoProc* = PROCEDURE (element: Element);



PROCEDURE (VAR self: Desc) Initialize*;
(*
 Initializes a list. The list is empty afterwards.
 *)
 BEGIN
  self.root := NIL;
 END Initialize;


PROCEDURE (VAR self: Desc) IsEmpty*() : BOOLEAN;
(*
 Answer TRUE if the list is empty.
 *)
 BEGIN
  RETURN self.root = NIL;
 END IsEmpty;


PROCEDURE (VAR self: Desc) First*() : Element;
(*
 Answer the first element in the list, NIL if empty.
 *)
 BEGIN
  RETURN self.root;
 END First;


PROCEDURE (VAR self: Desc) Last*() : Element;
(*
 Answer the last element in the list, NIL if empty.
 *)
 BEGIN
  IF self.root # NIL THEN
    RETURN self.root.prev;
  END;
  RETURN NIL
 END Last;


PROCEDURE (VAR self: Desc) Add*(e: Element);
(*
 Adds e at the end of the receiver.
 *)
 BEGIN
  IF self.root = NIL THEN
    e.next := e; e.prev := e; self.root := e;
  ELSE
    e.next := self.root; e.prev := self.root.prev;
    e.next.prev := e; e.prev.next := e;
  END;
 END Add;


PROCEDURE (VAR self: Desc) AddInFrontOf*(e, next: Element);
(*
 Add e to the linked list in front of next. If next is the root, e will
 become the root.
 *)
 BEGIN
  e.next := next; e.prev := next.prev;
  e.next.prev := e; e.prev.next := e;
  IF self.root = next THEN self.root := e END;
 END AddInFrontOf;


PROCEDURE (VAR self: Desc) AddBehind*(e, prev: Element);
(*
 Add e to the linked list behind prev.
 *)
 BEGIN
  e.next := prev.next; e.prev := prev;
  e.next.prev := e; e.prev.next := e;
 END AddBehind;


PROCEDURE (VAR self: Desc) MergeWith*(VAR aList: Desc);
(*
 Add all elements stored in aList to the receiver by merging the two lists.
 *)
  VAR
    last: Element;
 BEGIN
  last := self.root.prev;
  last.next := aList.root;
  aList.root.prev.next := self.root;
  self.root.prev := aList.root.prev;
  aList.root.prev := last;
 END MergeWith;


PROCEDURE (VAR self: Desc) Remove*(e: Element);
(*
 Remove e from the receiver list.
 *)
 BEGIN
  e.next.prev := e.prev; e.prev.next := e.next;
  IF self.root = e THEN self.root := e.next END;
  IF self.root = e THEN self.root := NIL END;
 END Remove;


PROCEDURE (VAR self: Desc) SetRoot*(e: Element);
(*
 Set e as root of the list. The other elements change position as well.
 *)
 BEGIN
  self.root := e
 END SetRoot;


PROCEDURE (VAR self: Desc) Insert*(e: Element);
(*
 Adds e at the beginnig of the receiver, so that it will become the first
 element.
 *)
 BEGIN
  self.Add(e);
  self.SetRoot(e);
 END Insert;


PROCEDURE (VAR self: Desc) MakeRoot*(e: Element);
(*
 Make e the root of the list. The other elements will keep there position.
 *)
 BEGIN
  self.Remove(e);
  self.Insert(e);
 END MakeRoot;


PROCEDURE (VAR self: Desc) Do*(aBlock: DoProc);
(*
 For each element in the receiver, evaluate aBlock with that element as
 the argument.
 *)
  VAR
    e: Element;
 BEGIN
  IF self.root # NIL THEN
    e := self.root;
    REPEAT
      aBlock(e); e := e.next;
    UNTIL (self.root = NIL) OR (e = self.root);
  END;
 END Do;


PROCEDURE (VAR self: Desc) ReverseDo*(aBlock: DoProc);
(*
 For each element in the receiver, evaluate aBlock with that element as
 the argument. Start with the last element.
 *)
  VAR
    e: Element;
 BEGIN
  IF self.root # NIL THEN
    e := self.root.prev;
    REPEAT
      aBlock(e);
      e := e.prev;
    UNTIL (self.root = NIL) OR (e = self.root.prev);
  END;
 END ReverseDo;


PROCEDURE (VAR self: Desc) Includes*(e: Element) : BOOLEAN;
(*
 Answer true if the receiver contains e.
 *)

  PROCEDURE~ Check(elem: Element);
   BEGIN
    IF e = elem THEN RETURN^ TRUE END;
   END Check;

 BEGIN
  self.Do( Check);
  RETURN FALSE
 END Includes;


END LinkedList.
