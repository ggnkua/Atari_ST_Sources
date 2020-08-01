MODULE StringDictionary;


(*
 Stores extensions of type ElementDesc in a hash table. The key to an
 element is a string. Several elements with the same key are stored in a
 linked list.
 *)


IMPORT
  S:=SYSTEM, Strings;


TYPE
  KeyPtr* = POINTER TO ARRAY 100 OF CHAR;

  Element = POINTER TO ElementDesc;
  ElementDesc* = RECORD (* for extension *)
    next*: Element;     (* use only if you know what you are doing! *)
    key* : KeyPtr;      (* dito *)
  END;

  ElementProc* = PROCEDURE (e: Element);

  Desc* = RECORD
    contents: POINTER TO ARRAY 30000 OF Element;
    length  : INTEGER;
    entries : INTEGER;
  END;
  Ptr* = POINTER TO Desc;


(*$-y *)

PROCEDURE (elem: Element) SetKey*(aKey: ARRAY OF CHAR);
(*
 Set the key of the receiver to aKey.
 *)
 BEGIN
  S.NEW(elem.key, Strings.Length(aKey)+1 );
  COPY(aKey, elem.key^);
 END SetKey;


PROCEDURE (elem: Element) Key*(VAR aKey: ARRAY OF CHAR);
(*
 Answer the key of the receiver.
 *)
 BEGIN
  COPY(elem.key^, aKey);
 END Key;


PROCEDURE (VAR dict: Desc) InitializeTo*(size: INTEGER);
(*
 Initialize the receiver to a dictionary with size number of element lists.
 size should be a prime number.
 *)
  VAR
    i: INTEGER;
 BEGIN
  S.NEW(dict.contents, LONG(size) * 4);
  FOR i := size-1 TO 0 BY -1 DO
    dict.contents[i] := NIL
  END;
  dict.length := size;
  dict.entries := 0;
 END InitializeTo;


PROCEDURE (VAR dict: Desc) Size*() : INTEGER;
(*
 Answer the number of elements stored in the receiver.
 *)
 BEGIN
  RETURN dict.entries;
 END Size;


PROCEDURE Hash(VAR aKey: ARRAY OF CHAR) : INTEGER;
  VAR
    i, answer: INTEGER;
 BEGIN
  i := 0;
  WHILE aKey[i] # 0X DO
    INC(answer, ORD(aKey[i]) * i);
    INC(i)
  END;
  RETURN answer;
 END Hash;


PROCEDURE SearchWithPrevious(
    VAR dict: Desc;
    VAR aKey: ARRAY OF CHAR;
    VAR prev, elem: Element) : BOOLEAN;
  VAR
    hash: INTEGER;
    e, p: Element;
 BEGIN
  hash := Hash(aKey) MOD dict.length;
  p := S.ADR( dict.contents[hash]);
  e := p.next;
  WHILE e # NIL DO
    IF e.key^ = aKey THEN
      prev := p; elem := e;
      RETURN TRUE
    END;
    p := e; e := e.next;
  END;
  prev := p;
  RETURN FALSE
 END SearchWithPrevious;


PROCEDURE (VAR dict: Desc) Add*(elem: Element);
(*
 Add elem to the receiver. If an element with the same key exists, it is
 replaced.
 *)
  VAR
    e, p: Element;
 BEGIN
  IF SearchWithPrevious(dict, elem.key^, p, e) THEN
    p.next := elem;
    elem.next := e.next;
  ELSE
    elem.next := NIL; p.next := elem;
    INC(dict.entries);
  END;
 END Add;


PROCEDURE (VAR dict: Desc) Remove*(aKey: ARRAY OF CHAR);
(*
 Remove the element with that key. Do nothing if the key is not found.
 *)
  VAR
    e, p: Element;
 BEGIN
  IF SearchWithPrevious(dict, aKey, p, e) THEN
    p.next := e.next;
    DEC(dict.entries);
    RETURN ;
  END;
 END Remove;


PROCEDURE (VAR dict: Desc) TestAt*(
  aKey: ARRAY OF CHAR;
  VAR elem: Element) : BOOLEAN;
(*
 Store the element stored for aKey in elem. Answer true if found.
 *)
  VAR
    hash: INTEGER;
    e: Element;
 BEGIN
  hash := Hash(aKey) MOD dict.length;
  e := dict.contents[hash];
  WHILE e # NIL DO
    IF e.key^ = aKey THEN
      elem := e;
      RETURN TRUE;
    END;
  END;
  RETURN FALSE
 END TestAt;


PROCEDURE (VAR dict: Desc) At*(aKey: ARRAY OF CHAR) : Element;
(*
 Answer the element stored for aKey. Abort with HALT if not found.
 *)
  VAR
    e: Element;
 BEGIN
  IF dict.TestAt(aKey, e) THEN RETURN e END;
  HALT(100);
 END At;


PROCEDURE (VAR dict: Desc) Do*(aBlock: ElementProc);
(*
 Call aBlock with every element in the receiver. The order is arbritrary.
 *)
  VAR
    i: INTEGER;
    e: Element;
 BEGIN
  FOR i := dict.length-1 TO 0 BY -1 DO
    e := dict.contents[i];
    WHILE e # NIL DO
      aBlock(e);
      e := e.next;
    END;
  END;
 END Do;


END StringDictionary.