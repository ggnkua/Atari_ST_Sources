UNIT M_Trees;

INTERFACE

TYPE CompResult = (smaller, equal, bigger);
     CompProc =   FUNCTION (left, right: POINTER): CompResult;

FUNCTION NewTree (VAR tree: POINTER; comp: CompProc): BOOLEAN;
PROCEDURE DisposeTree (VAR tree: POINTER);
FUNCTION TreeEntries (tree: POINTER): LONGINT;
FUNCTION NilNode: POINTER;
FUNCTION InsertNode (tree: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
FUNCTION SearchNode (tree: POINTER; from: POINTER; info: POINTER; key: CompProc): POINTER;
PROCEDURE DeleteNode (tree: POINTER; VAR node: POINTER);
FUNCTION FirstNode (tree: POINTER): POINTER;
FUNCTION LastNode (tree: POINTER): POINTER;
FUNCTION NextNode (node: POINTER): POINTER;
FUNCTION PrevNode (node: POINTER): POINTER;
FUNCTION GetNode (node: POINTER; info: POINTER): BOOLEAN;

IMPLEMENTATION

CONST   cMax =  $07FFF;

TYPE    PtrINFO = ^INFO;
        INFO =   ARRAY [0..cMax] OF BYTE;

TYPE    PtrNODE = ^Node;
        Node =    RECORD
                   addr:  PtrINFO;
                   size:  INTEGER;
                   left:  PtrNODE;
                   right: PtrNODE;
                   back:  PtrNODE;
                  END;

TYPE    PtrTREE = ^Tree;
        Tree =    RECORD
                   root:  PtrNODE;
                   comp:  CompProc;
                   entry: LONGINT;
                  END;

FUNCTION NewTree (VAR tree: POINTER; comp: CompProc): BOOLEAN;
VAR t: PtrTREE;
BEGIN
 NewTree:= FALSE;
 GetMem (t, SIZEOF (t^));  IF t = NIL THEN  EXIT;
 t^.root:=  NIL;
 t^.comp:= comp;
 t^.entry:= 0;
 NewTree:= TRUE;
END (*NewTree*);

PROCEDURE DisposeTree (VAR tree: POINTER);
VAR p: PtrNODE;
    t: PtrTREE ABSOLUTE tree;
BEGIN
 IF t <> NIL THEN BEGIN
  WITH t^ DO BEGIN
   (* Wieso steht hier eigentlich nichts? *)
  END;
  FreeMem (t, SIZEOF(t^));  
 END;
END (*DisposeTree*);

FUNCTION TreeEntries (tree: POINTER): LONGINT;
VAR t: PtrTREE ABSOLUTE tree;
BEGIN
 IF tree = NIL THEN  TreeEntries:= 0
               ELSE  TreeEntries:= t^.entry;
END (*TreeEntries*);

FUNCTION NilNode (): POINTER;
BEGIN
 NilNode:= NIL;
END (*NilNode*);

FUNCTION InsertNode (tree: POINTER; info: POINTER; size: INTEGER): BOOLEAN;
VAR p, q, n: PtrNODE;
    t: PtrTREE ABSOLUTE tree;
    cmp: CompResult;
    dir:     (l, r);

 FUNCTION NewNode: PtrNODE;
 VAR t: PtrNODE;
 BEGIN
  NewNode:= NIL;
  GetMem (t, SIZEOF (Node));  IF t = NIL THEN  EXIT;
  t^.size:= size;
  t^.left:= NIL;
  t^.right:= NIL;
  t^.back:= NIL;
  GetMem (t^.addr,  t^.size);  
  IF t^.addr = NIL THEN BEGIN  FreeMem (t, SIZEOF (Node));  EXIT;  END;
  Move (info, t^.addr^, t^.size);
  NewNode:= t;
 END (*NewNode*);

BEGIN
 InsertNode:= FALSE;
 IF t = NIL THEN  EXIT;
 n:= NewNode;  IF n = NIL THEN  EXIT;
 WITH t^ DO BEGIN
  p:= root;  q:= p;
  WHILE p <> NIL DO BEGIN
   q:= p;
   cmp:= comp (n^.addr, p^.addr);
   CASE cmp OF
    smaller: BEGIN  dir:= l;  p:= p^.left;  END;
    bigger:  BEGIN  dir:= r;  p:= p^.right;  END;
    ELSE     EXIT; (* Element existiert bereits! *)
   END;
  END; (* WHILE *)
  n^.back:= q;
  IF q <> NIL THEN BEGIN
   IF dir = l THEN  q^.left:= n  ELSE  q^.right:= n;
  END ELSE BEGIN
   root:= n;
  END;
 END;
 INC (t^.entry);
 InsertNode:= TRUE;
END (*InsertNode*);

FUNCTION SearchNode (tree: POINTER; from: POINTER; info: POINTER;
                     key: CompProc): POINTER;
VAR ok: BOOLEAN;
    cmp: CompResult;
    p, q: PtrNODE;
    t: PtrTREE ABSOLUTE tree;
    f: PtrNODE ABSOLUTE from;
BEGIN
 SearchNode:= NIL;
 IF t = NIL THEN  EXIT;
 WITH t^ DO BEGIN
  IF f <> NIL THEN  p:= f  ELSE  p:= root;
  WHILE p <> NIL DO BEGIN
   cmp:= key (ADDR (info), p^.addr);
   CASE cmp OF
    equal:     BEGIN  SearchNode:= p;  EXIT; END;
    smaller:   p:= p^.left;
    bigger:    p:= p^.right;
    ELSE       (* WHAT else? *); 
   END;
  END; (* WHILE *)
 END; (* WITH *)
END (*SearchNode*);

PROCEDURE DeleteNode (tree: POINTER; VAR node: POINTER);
VAR q, p, t: PtrNODE;
    inf: PtrINFO;
    tr: PtrTREE ABSOLUTE tree;
    n: PtrNODE ABSOLUTE node;

 PROCEDURE Del (VAR x: PtrNODE);
 BEGIN
  FreeMem (x^.addr, x^.size);  
  FreeMem (x, SIZEOF (NODE));  
  x:= NIL;
 END (*Del*);

 PROCEDURE Putback (VAR x: PtrNODE; y: PtrNODE);
 BEGIN
  IF x^.back <> NIL THEN BEGIN
   WITH x^.back^ DO BEGIN
    IF left = x THEN  left:= y  ELSE  right:= y;
   END;
  END;
  IF y <> NIL THEN  y^.back:= x^.back;
 END (*Putback*);

BEGIN
 IF (tr = NIL) OR (n = NIL) THEN  EXIT;
 WITH tr^ DO BEGIN
  IF n^.left <> NIL THEN BEGIN
   p:= n;  q:= NIL;
   WHILE p <> NIL DO BEGIN  q:= p;  p:= p^.right;  END;
   t:= q^.left;
  END ELSE IF n^.right <> NIL THEN BEGIN
   p:= n;  q:= NIL;
   WHILE p <> NIL DO BEGIN  q:= p;  p:= p^.left;  END;
   t:= q^.right;
  END ELSE BEGIN
   q:= n;  t:= NIL;
  END;
  IF n = q THEN BEGIN
   IF n = root THEN  Del (root)
               ELSE  BEGIN Putback (n, NIL);  Del (n);  END;
  END ELSE BEGIN
   Putback (q, t);
   inf:= n^.addr;  n^.addr:= q^.addr;  q^.addr:= inf;
   Del (q);
  END;
 END;
 DEC (tr^.entry);
END (*DeleteNode*);

FUNCTION FirstNode (tree: POINTER): POINTER;
VAR p, q: PtrNODE;
    t: PtrTREE ABSOLUTE tree;
BEGIN
 FirstNode:= NIL;
 IF t = NIL THEN EXIT;
 p:= t^.root;  q:= NIL;
 WHILE p <> NIL DO BEGIN q:= p;  p:= p^.left;  END;
 FirstNode:= q;
END (*FirstNode*);

FUNCTION LastNode (tree: POINTER): POINTER;
VAR p, q: PtrNODE;
    t: PtrTREE ABSOLUTE tree;
BEGIN
 LastNode:= NIL;
 IF t = NIL THEN  EXIT;
 p:= t^.root;  q:= NIL;
 WHILE p <> NIL DO BEGIN  q:= p;  p:= p^.right;  END;
 LastNode:= q;
END (*LastNode*);

FUNCTION NextNode (node: POINTER): POINTER;
VAR p, q: PtrNODE;
    ok:   BOOLEAN;
    n: PtrNODE ABSOLUTE node;
BEGIN
 NextNode:= NIL;
 IF n = NIL THEN  EXIT;
 IF n^.right <> NIL THEN BEGIN
  p:= n^.right;  q:= NIL;
  WHILE p <> NIL DO BEGIN q:= p;  p:= p^.left;  END;
  NextNode:= q;  EXIT;
 END ELSE BEGIN
  p:= node;
  REPEAT
   q:= p;  p:= p^.back;
   IF p = NIL THEN  ok:= TRUE  ELSE  ok:= p^.left = q;
  UNTIL ok;
  NextNode:= p;
 END;
END (*NextNode*);

FUNCTION PrevNode (node: POINTER): POINTER;
VAR ok:   BOOLEAN;
    p, q: PtrNODE;
    n: PtrNODE ABSOLUTE node;
BEGIN
 PrevNode:= NIL;
 IF n = NIL THEN  EXIT;
 IF n^.left <> NIL THEN BEGIN
  p:= n^.left;  q:= NIL;
  WHILE p <> NIL DO BEGIN  q:= p;  p:= p^.right;  END;
  PrevNode:= q;  EXIT;
 END ELSE BEGIN
  p:= node;
  REPEAT
   q:= p;  p:= p^.back;
   IF p = NIL THEN  ok:= TRUE  ELSE  ok:= p^.right = q;
  UNTIL ok;
  PrevNode:= p;
 END;
END (*PrevNode*);

FUNCTION GetNode (node: POINTER; info: POINTER): BOOLEAN;
VAR n: PtrNODE ABSOLUTE node;
BEGIN
 GetNode:= FALSE;
 IF n = NIL THEN  EXIT;
 Move (n^.addr^, info, n^.size);
 GetNode:= TRUE;
END (*GetNode*);

END (*M_Trees*).
