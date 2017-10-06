UNIT M_Stacks;

INTERFACE

FUNCTION NewStack (VAR st: POINTER): BOOLEAN;
PROCEDURE DisposeStack (VAR st: POINTER);
FUNCTION StackEmpty (st: POINTER): BOOLEAN;
FUNCTION StackEntries (st: POINTER): LONGINT;
FUNCTION Push (st: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
FUNCTION Pop (st: POINTER; info: POINTER; size: INTEGER): BOOLEAN;

IMPLEMENTATION

{$I COMPOPT.INC}

CONST   cMax =          $07FFF;

TYPE    PtrINFO =       ^InfoDescr;
        InfoDescr =     ARRAY [0..cMax] OF BYTE;

TYPE    PtrENTRY =      ^EntryDescr;
        EntryDescr =    RECORD
                         addr: PtrINFO;
                         size: INTEGER;
                         next: PtrENTRY;
                        END;

TYPE    PtrSTACK =      ^StackDescr;
        StackDescr =    RECORD
                         start: PtrENTRY;
                         entry: LONGINT;
                        END;

FUNCTION NewStack (VAR st: POINTER): BOOLEAN;
VAR s: PtrSTACK ABSOLUTE st;
BEGIN
 GetMem (s, SIZEOF (StackDescr));
 IF s = NIL THEN BEGIN NewStack:= FALSE; EXIT; END;
 s^.start:= NIL;
 s^.entry:= 0;
 NewStack:= TRUE;
END (*NewStack*);

PROCEDURE DisposeStack (VAR st: POINTER);
VAR p: PtrENTRY;
    s: PtrSTACK ABSOLUTE st;
BEGIN
 IF s <> NIL THEN BEGIN
  WITH s^ DO BEGIN
   WHILE start <> NIL DO BEGIN
    p:= start^.next;
    FreeMem (start^.addr, start^.size);
    FreeMem (start, SIZEOF (EntryDescr));
    start:= p;
   END;
  END;
  FreeMem (s, SIZEOF (StackDescr))
 END;
 st:= NIL;
END (*DisposeStack*);

FUNCTION StackEmpty (st: POINTER): BOOLEAN;
VAR s: PtrSTACK ABSOLUTE st;
BEGIN
 IF s = NIL THEN  StackEmpty:= TRUE
            ELSE  StackEmpty:= s^.start = NIL;
END (*StackEmpty*);

FUNCTION StackEntries (st: POINTER): LONGINT;
VAR s: PtrSTACK ABSOLUTE st;
BEGIN
 IF s = NIL THEN  StackEntries:= 0
            ELSE  StackEntries:= s^.entry;
END (*StackEntries*);

FUNCTION Push (st: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
VAR s: PtrSTACK ABSOLUTE st;
    p: PtrENTRY;
    x: PtrINFO;
BEGIN
 IF s <> NIL THEN BEGIN
  GetMem (p, SIZEOF (EntryDescr));
  IF p <> NIL THEN BEGIN
   p^.size:= size;
   GetMem (p^.addr, p^.size);
   IF p^.addr <> NIL THEN BEGIN
    x:= info;
    Move (x^, p^.addr^, p^.size);
    p^.next:= s^.start;
    s^.start:= p;
    INC (s^.entry);
    Push:= TRUE;
    EXIT;
   END;
  END;
 END;
 Push:= FALSE;
END (*Push*);

FUNCTION Pop (st: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
VAR s: PtrSTACK ABSOLUTE st;
    p: PtrENTRY;
    x: PtrINFO;
BEGIN
 IF s <> NIL THEN BEGIN
  WITH s^ DO BEGIN
   IF start <> NIL THEN BEGIN
    IF size >= start^.size THEN BEGIN
     x:= info;
     Move (start^.addr^, x^, start^.size);
     p:= start^.next;
     FreeMem (start^.addr, start^.size);
     FreeMem (start, SIZEOF (EntryDescr));
     start:= p;
     DEC (s^.entry);
     Pop:= TRUE;
     EXIT;
    END;
   END;
  END;
 END;
 Pop:= FALSE;
END (*Pop*);

END (*M_Stacks*).

