MODULE Items;  (* Stephan Junker *)


(* Items implements a double chained list in which the elements have a
 * unique identification, hence called itemId. You can add, search or
 * search and delete an item.
 * Type ItemDesc may be extended for additional item data.
 *)


IMPORT S:=SYSTEM, DCL;


TYPE
  Item*     = POINTER TO ItemDesc;
  ItemDesc* = RECORD(DCL.Element)
                itemId* : LONGINT;
              END;
  List*     = POINTER TO ListDesc;
  ListDesc* = RECORD(DCL.ListDesc)
              END;


PROCEDURE(l : List) AddItem*(i : Item; itemId : LONGINT);
  (* adds an item with id itemId to list l. *)
 BEGIN
  i.itemId := itemId;
  l.Add^(i);
 END AddItem;


PROCEDURE(l : List) Find*(itemId : LONGINT; VAR i : Item) : BOOLEAN;
  (* tries to find an item in list l with id itemId. Returns true if found *)
  VAR p : Item;
 BEGIN
  p := l.root;
  WHILE p # NIL DO
    IF p.itemId = itemId THEN i := p; RETURN TRUE END;
    p := p.next;
  END;
  RETURN FALSE
 END Find;


PROCEDURE(l : List) FindAndDelete*(itemId : LONGINT);
  (* deletes the item with id itemId in list l if found. Memory is disposed! *)
  VAR i : Item;
 BEGIN
  IF l.Find(itemId, i) THEN l.Delete(i); S.DISPOSE(i) END;
 END FindAndDelete;


END Items.