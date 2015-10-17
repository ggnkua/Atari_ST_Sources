MODULE HashTest;

FROM SYSTEM IMPORT TSIZE;
FROM Storage IMPORT ALLOCATE;
FROM Strings IMPORT StrEqual;

TYPE
  Str = ARRAY [0..5] OF CHAR;
  
  PtrItem = POINTER TO Item;
  
  Item = RECORD
    next: PtrItem;
    data: Str;
  END;
  
  HashIdx = [0..MAX(INTEGER)];
  
  PtrHashTbl = POINTER TO ARRAY HashIdx OF PtrItem;

VAR hashTblPtr: PtrHashTbl;
    hashTblSize: LONGCARD;

PROCEDURE Init (hashSize: CARDINAL): BOOLEAN;
  (* 'hashSize' sollte eine Primzahl sein *)
  VAR n: HashIdx;
  BEGIN
    hashTblSize:= hashSize;
    ALLOCATE (hashTblPtr, hashTblSize * TSIZE (PtrItem));
    IF hashTblPtr = NIL THEN
      RETURN FALSE
    END;
    FOR n:= 0 TO hashSize-1 DO
      hashTblPtr^[n]:= NIL
    END;
    RETURN TRUE
  END Init;

PROCEDURE hashValue (VAR s: ARRAY OF CHAR): HashIdx;
  VAR x: LONGCARD; n: CARDINAL; ch: CHAR;
  BEGIN
    x:= 0;
    n:= 0;
    LOOP
      ch:= s[n];
      IF ch = 0C THEN EXIT END;
      IF ch >= 'A' THEN DEC (ch, ORD('A')) END;
      x:= x * 26 + VAL (LONGCARD, ORD (ch));
      INC (n);
      IF n > HIGH (s) THEN EXIT END
    END;
    RETURN VAL (HashIdx, x MOD hashTblSize)
  END hashValue;

PROCEDURE Add (s: Str): BOOLEAN;
  VAR idx: HashIdx; item: PtrItem;
  BEGIN
    idx:= hashValue (s);
    item:= hashTblPtr^[idx];
    WHILE item # NIL DO
      IF StrEqual (item^.data, s) THEN
        RETURN FALSE
      END;
      item:= item^.next
    END;
    NEW (item);
    item^.next:= hashTblPtr^[idx];
    item^.data:= s;
    hashTblPtr^[idx]:= item;
    RETURN TRUE
  END Add;

BEGIN
  IF ~Init (2) THEN HALT END;
  IF ~Add ("AA") THEN HALT END;
  IF ~Add ("AB") THEN HALT END;
  IF ~Add ("AC") THEN HALT END;
  IF  Add ("AA") THEN HALT END;
  IF  Add ("AB") THEN HALT END;
  IF  Add ("AC") THEN HALT END;
  
END HashTest.

(* $FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8€$000005A3T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000005A3$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8$FFEC07E8„€€*)
