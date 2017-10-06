UNIT M_Lists;

INTERFACE

TYPE    CompResult =    (smaller, equal, bigger);
        CompProc =      FUNCTION (left, right: POINTER): CompResult;

FUNCTION NewList (VAR liste: POINTER; comp: CompProc): BOOLEAN;
PROCEDURE DisposeList (VAR liste: POINTER);
FUNCTION ListEntries (liste: POINTER): LONGINT;
FUNCTION NilEntry: POINTER;
FUNCTION InsertEntry (liste: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
FUNCTION SearchEntry (liste: POINTER; from: POINTER; info: POINTER; key: CompProc): POINTER;
PROCEDURE DeleteEntry (liste: POINTER; VAR entr: POINTER);
FUNCTION FirstEntry (liste: POINTER): POINTER;
FUNCTION LastEntry (liste: POINTER): POINTER;
FUNCTION NextEntry (entr: POINTER): POINTER;
FUNCTION PrevEntry (entr: POINTER): POINTER;
FUNCTION GetElement (entr: POINTER): POINTER;
FUNCTION GetEntry (entr: POINTER; info: POINTER; size: INTEGER): BOOLEAN;

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
                         last: PtrENTRY;
                        END;

TYPE    PtrLIST =       ^ListDescr;
        ListDescr =     RECORD
                         start: PtrENTRY;
                         ende:  PtrENTRY;
                         comp:  CompProc;
                         entry: LONGINT;
                        END;


FUNCTION NewList (VAR liste: POINTER; comp: CompProc): BOOLEAN;
VAR l: PtrLIST;
BEGIN
 liste:= NIL; NewList:= FALSE;
 GetMem (l, SIZEOF (ListDescr));
 IF l <> NIL THEN BEGIN
  l^.start:= NIL;
  l^.comp:= comp;
  l^.entry:= 0;
  liste:= l;
  NewList:= TRUE;
 END;
END (*NewList*);

PROCEDURE DisposeList (VAR liste: POINTER);
VAR l: PtrLIST;
    p: PtrENTRY;
BEGIN
 l:= liste;
 IF l <> NIL THEN BEGIN
  WITH l^ DO BEGIN
   WHILE start <> NIL DO BEGIN
    p:= start^.next;
    FreeMem (start^.addr, start^.size);
    FreeMem (start, SIZEOF (EntryDescr));
    start:= p;
   END;
  END;
  FreeMem (l, SIZEOF (ListDescr));
 END;
END (*DisposeList*);

FUNCTION NilEntry: POINTER;
BEGIN
 NilEntry:= NIL;
END (*NilEntry*);

FUNCTION InsertEntry (liste: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
VAR l: PtrLIST;
    s, t: PtrENTRY;
    x: PtrINFO;
    f: BOOLEAN;
    c: CompResult;
BEGIN
 l:= liste;  InsertEntry:= FALSE;
 IF l = NIL THEN BEGIN  EXIT;  END;
 GetMem (t, SIZEOF (EntryDescr));
 IF t = NIL THEN BEGIN  EXIT;  END;
 t^.size:= size;  t^.last:= NIL;  t^.next:= NIL;
 GetMem (t^.addr, t^.size);
 IF t^.addr = NIL THEN BEGIN
  FreeMem (t, SIZEOF (EntryDescr));
  EXIT;
 END;
 x:= info;  Move (x^, t^.addr^, t^.size);
 INC (l^.entry);  InsertEntry:= TRUE;
  
 (* Einsortieren *)
 s:= l^.start;
 IF s = NIL THEN BEGIN
  l^.start:= t;  l^.ende:= t;  EXIT;
 END;

 REPEAT
  f:= l^.comp (s^.addr, info) <> smaller;
  IF NOT f THEN BEGIN  s:= s^.next; END;
 UNTIL (s = NIL) OR f;

 t^.next:= s;
 IF s = NIL THEN BEGIN
  t^.last:= l^.ende;  l^.ende^.next:= t;  l^.ende:= t;  EXIT;
 END ELSE BEGIN
  IF s = l^.start THEN BEGIN
   l^.start:= t;  s^.last:= t; EXIT;
  END ELSE BEGIN
   t^.last:= s^.last;  s^.last^.next:= t;  s^.last:= t;
  END;
 END;
END (*InsertEntry*);

FUNCTION ListEntries (liste: POINTER): LONGINT;
VAR l: PtrLIST;
BEGIN
 l:= liste; 
 IF l = NIL THEN BEGIN  ListEntries:= 0;  END 
            ELSE BEGIN  ListEntries:= l^.entry; END;
END (*ListEntries*); 

FUNCTION SearchEntry (liste: POINTER; from: POINTER;
                      info: POINTER;  key: CompProc): POINTER;
VAR l: PtrLIST;
    f, s: PtrENTRY;
    b1, b2: BOOLEAN;
BEGIN
 l:= liste; 
 IF l <> NIL THEN BEGIN
  WITH l^ DO BEGIN
   s:= start;
   WHILE s <> NIL DO BEGIN
    IF key (s^.addr, info) = equal THEN BEGIN
     SearchEntry:= s;  EXIT;
    END;
    s:= s^.next;
   END;
  END;
 END;
 Searchentry:= NIL;
END (*SearchEntry*);

PROCEDURE DeleteEntry (liste: POINTER; VAR entr: POINTER);
VAR l: PtrLIST;
    e, t: PtrENTRY;
BEGIN
 l:= liste;  e:= entr;
 IF (l = NIL) OR (entr = NIL) THEN BEGIN  EXIT;  END;
 WITH l^ DO BEGIN
  IF e = start THEN BEGIN
   t:= start;  start:= start^.next;  start^.last:= NIL;
   IF start = NIL THEN BEGIN  ende:= NIL;  END;
   FreeMem (t^.addr, t^.size);  FreeMem (t, SIZEOF (EntryDescr));
   DEC (entry);
  END ELSE IF e = ende THEN BEGIN
   t:= ende;  ende:= ende^.last;  ende^.next:= NIL;
   FreeMem (t^.addr, t^.size);  FreeMem (t, SIZEOF (EntryDescr));
   DEC (entry);
  END ELSE BEGIN
   e^.next^.last:= e^.last;
   e^.last^.next:= e^.next;
   FreeMem (e^.addr, e^.size);  FreeMem (e, SIZEOF (EntryDescr));
   DEC (entry);
  END;
 END;
 entr:= NIL;
END (*DeleteEntry*);

FUNCTION FirstEntry (liste: POINTER): POINTER;
VAR l: PtrLIST;
BEGIN
 IF liste = NIL THEN BEGIN
  FirstEntry:= NIL;
 END ELSE BEGIN
  l:= liste;  FirstEntry:= l^.start;
 END;
END (*FirstEntry*);

FUNCTION LastEntry (liste: POINTER): POINTER;
VAR l: PtrLIST;
BEGIN
 IF liste = NIL THEN BEGIN
  LastEntry:= NIL;
 END ELSE BEGIN
  l:= liste;  LastEntry:= l^.ende;
 END;
END (*LastEntry*);

FUNCTION NextEntry (entr: POINTER): POINTER;
VAR e: PtrENTRY;
BEGIN
 IF entr = NIL THEN BEGIN
  NextEntry:= NIL;
 END ELSE BEGIN
  e:= entr;  NextEntry:= e^.next;
 END;
END (*NextEntry*);

FUNCTION PrevEntry (entr: POINTER): POINTER;
VAR e: PtrENTRY;
BEGIN
 IF entr = NIL THEN BEGIN
  PrevEntry:= NIL;
 END ELSE BEGIN
  e:= entr;  PrevEntry:= e^.last;
 END;
END (*PrevEntry*);


FUNCTION GetElement (entr: POINTER): POINTER;
VAR e: PtrENTRY;
BEGIN
 IF entr = NIL THEN BEGIN
  GetElement:= NIL;
 END ELSE BEGIN
  e:= entr;  GetElement:= e^.addr;
 END;
END (*GetElement*);

FUNCTION GetEntry (entr: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
VAR e: PtrENTRY;
    x: PtrINFO;
BEGIN
 e:= entr; x:= info;
 IF e <> NIL THEN BEGIN
  IF size >= e^.size THEN BEGIN
   Move (e^.addr^, x^, e^.size);
   GetEntry:= TRUE;
   EXIT;
  END;
 END;
 GetEntry:= FALSE;
END (*GetEntry*);

END (*mpLists*).

