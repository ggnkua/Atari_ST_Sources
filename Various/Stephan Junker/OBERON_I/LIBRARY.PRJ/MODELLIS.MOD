MODULE ModelList; (* SJ 5.2.95 *)

(*
 LinkedList of Model.Ptr's.
 Used e.g. by WinView.
 *)


IMPORT
  LinkedList, Model;


TYPE
  Desc* = RECORD(LinkedList.Desc)
  END;

  Element* = POINTER TO RECORD(LinkedList.ElemDesc)
    model-: Model.Ptr;
  END;

  DoProc* = PROCEDURE (m: Model.Ptr);



PROCEDURE AsElement*(m: Model.Ptr) : Element;
(*
 Answer an element storing m.
 *)
  VAR
    e: Element;
 BEGIN
  NEW(e); e.model := m;
  RETURN e;
 END AsElement;


PROCEDURE (VAR self: Desc) FirstModel*() : Model.Ptr;
(*
 Answer the first model in the list, NIL if empty.
 *)
  VAR
    answer: Element;
 BEGIN
  IF (answer := self.First()) = NIL THEN RETURN NIL END;
  RETURN answer(Element).model;
 END FirstModel;


PROCEDURE (VAR self: Desc) LastModel*() : Model.Ptr;
(*
 Answer the last element in the list, NIL if empty.
 *)
  VAR
    answer: Element;
 BEGIN
  IF (answer := self.Last()) = NIL THEN RETURN NIL END;
  RETURN answer(Element).model;
 END LastModel;


PROCEDURE (VAR self: Desc) AddModel*(m: Model.Ptr);
(*
 Add m to the receiver.
 *)
 BEGIN
  self.Add( AsElement(m) );
 END AddModel;


PROCEDURE (VAR self: Desc) RemoveModel*(m: Model.Ptr);
(*
 Remove m from the receiver. Do nothing if not found.
 *)

  PROCEDURE~ Remove(e: LinkedList.Element);
   BEGIN
    IF e(Element).model = m THEN
      self.Remove(e)
    END;
   END Remove;

 BEGIN
  self.Do( Remove);
 END RemoveModel;


PROCEDURE (VAR self: Desc) ModelsDo*(aBlock: DoProc);
(*
 Evaluate aBlock with every model stored in the receiver as argument.
 *)

  PROCEDURE~ Do(e: LinkedList.Element);
   BEGIN
    aBlock( e(Element).model);
   END Do;

 BEGIN
  self.Do( Do);
 END ModelsDo;


END ModelList.