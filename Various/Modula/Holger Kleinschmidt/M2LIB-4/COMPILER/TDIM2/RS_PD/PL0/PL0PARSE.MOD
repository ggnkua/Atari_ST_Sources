IMPLEMENTATION MODULE PL0Parser;
(*$S-,$T-,$Q+*)

FROM SYSTEM       IMPORT TSIZE;
FROM PL0Heap      IMPORT ResetHeap, ALLOCATE;
FROM TextWindows  IMPORT Window, Invert, WriteString, OpenTextWindow,
                         Write, WriteLn, WriteCard,  CloseTextWindow;
FROM PL0Scanner   IMPORT Symbol,sym,GetSym, id,num, Diff,KeepId,Mark, source;
FROM PL0Generator IMPORT Label, Gen, fixup;

CONST FF = 14c; WINTITLE = " PARSE ";

TYPE ObjectClass = (Const, Var, Proc, Header);
     ObjPtr = POINTER TO Object;
     Object = RECORD
       name: CARDINAL;
       next: ObjPtr;
       CASE kind: ObjectClass OF
       | Const : val: INTEGER;
       | Var   : vlev, vadr: CARDINAL;
       | Proc  : plev, padr, size: CARDINAL;
       | Header: last, down: ObjPtr;
       END; END;  

VAR  topScope, bottom, undef: ObjPtr;
     curlev: CARDINAL;
     win: Window;

PROCEDURE wL (VAR s: ARRAY OF CHAR);
 BEGIN WriteLn (win); WriteString (win, s) END wL;

PROCEDURE err (n: CARDINAL);
 BEGIN  noerr := FALSE; Mark (n);
   Invert (win, TRUE);  WriteCard (win, n,1);
   Invert (win, FALSE); END err;

PROCEDURE test (s: Symbol;  n: CARDINAL);
 BEGIN IF (sym <s) THEN err(n); REPEAT GetSym UNTIL (sym >=s) END END test;

PROCEDURE NewObj (k: ObjectClass): ObjPtr;
 (* Neues Objekt einrichten; *)
 (* Fehler melden, falls sein Name bereits definiert ist.*)
 VAR   obj: ObjPtr;
 BEGIN obj := topScope^.next;
   (* check for multiple definition *)
   WHILE (obj # NIL) DO IF (Diff (id, obj^.name) = 0) THEN err (25) END;
       obj:= obj^.next; END;
   (* now enter new object into list *)
   ALLOCATE (obj, TSIZE (Object));
   WITH obj^ DO name := id; kind := k; next := NIL END;
   KeepId;
   topScope^.last^.next := obj;
   topScope^.last := obj;
   RETURN obj; END NewObj;

PROCEDURE find (id: CARDINAL): ObjPtr;
 VAR   hd, obj: ObjPtr;
 BEGIN hd := topScope;
   WHILE (hd # NIL) DO obj := hd^.next;
     WHILE (obj # NIL) DO
       IF (Diff (id,obj^.name) = 0) THEN RETURN obj;
       ELSE  obj := obj^.next END; END (*W*);
     hd := hd^.down; END;
   err (11);
   RETURN undef; END find;

(*$S+*)

PROCEDURE expression;
  VAR addop: Symbol;
  PROCEDURE factor;
   VAR   obj: ObjPtr;
   BEGIN wL ("factor");
    test (lparen, 6);
    IF (sym = ident) THEN obj := find (id);
       WITH obj^ DO
         CASE kind OF
         | Const: Gen (0, 0, val);
         | Var  : Gen (2, curlev-vlev, vadr);
         | Proc : err (21);
         END; END (*W*);
       GetSym;
    ELSIF (sym = number) THEN Gen (0, 0, num); GetSym;
    ELSIF (sym = lparen) THEN GetSym; expression;
       IF (sym = rparen) THEN GetSym ELSE err (7) END;
    ELSE err (8) END; END factor;
  PROCEDURE term;
   VAR   mulop: Symbol;
   BEGIN wL ("term"); factor;
     WHILE (times <= sym) & (sym <= div) DO mulop := sym; GetSym; factor;
       IF (mulop = times) THEN Gen (1, 0, 4);
       ELSE Gen (1, 0, 5) END; END; END term;
 BEGIN wL ("expression");
   IF (plus <= sym) & (sym <= minus) THEN  addop := sym; GetSym; term;
     IF (addop = minus) THEN Gen (1, 0, 1) END;
   ELSE term END;
   WHILE (plus <= sym) & (sym <= minus) DO addop := sym; GetSym; term;
     IF (addop = plus) THEN Gen (1, 0, 2) ELSE Gen (1, 0, 3) END; END;
   END expression;

(*$S-*)

PROCEDURE condition;
 VAR   relop: Symbol;
 BEGIN wL ("condition");
  IF  (sym = odd) THEN GetSym; expression; Gen (1,0,6);
  ELSE expression;
    IF (eql <= sym) & (sym <= geq) THEN relop := sym; GetSym; expression;
       CASE relop OF
       | eql: Gen (1, 0,  8);
       | neq: Gen (1, 0,  9);
       | lss: Gen (1, 0, 10);
       | geq: Gen (1, 0, 11);
       | gtr: Gen (1, 0, 12);
       | leq: Gen (1, 0, 13);
       END;
    ELSE err (20) END; END;
  END condition;

PROCEDURE statement;
 VAR  obj: ObjPtr; L0,L1: CARDINAL;
 BEGIN wL ("statement");
  test (ident, 10);
  IF (sym = ident) THEN obj := find (id);
     IF (obj^.kind # Var) THEN err (12); obj := NIL END;
     GetSym;
     IF    (sym = becomes) THEN GetSym;
     ELSIF (sym = eql) THEN err (13); GetSym;
     ELSE  err (13) END;
     expression;
     IF (obj # NIL) THEN Gen (3, curlev-obj^.vlev,obj^.vadr) END; (* store *)
  ELSIF (sym = call) THEN GetSym;
     IF (sym = ident) THEN obj := find (id);
        IF (obj^.kind # Proc) THEN err (15);
        ELSE   Gen (4, curlev-obj^.plev, obj^.padr) END;           (* call *)
        GetSym;
     ELSE err (14) END;
  ELSIF (sym = begin) THEN GetSym;
     LOOP statement;
       IF    (sym = semicolon) THEN GetSym;
       ELSIF (sym =   end) THEN GetSym; EXIT;
       ELSIF (sym < const) THEN err (17);
       ELSE err (17); EXIT END; END;
  ELSIF (sym = if)    THEN GetSym; condition;
     IF (sym = then)  THEN GetSym ELSE err (16) END;
     L0 := Label (); Gen (7, 0, 0); statement; fixup (L0);
  ELSIF (sym = while) THEN L0 := Label ();
     GetSym; condition; L1 := Label (); Gen (7, 0, 0);
     IF (sym = do)    THEN GetSym ELSE err (18) END;
     statement; Gen (6, 0, L0); fixup (L1);
  ELSIF (sym = read)  THEN GetSym;
     IF (sym = ident) THEN obj := find (id);
        IF (obj^.kind # Var) THEN err (12);
        ELSE Gen (1, 0, 14); Gen (3, curlev-obj^.vlev, obj^.vadr) END;
     ELSE err (14) END;
     GetSym;
  ELSIF (sym = write) THEN GetSym; expression; Gen (1, 0, 15) END;
  test (ident, 19);
  END statement;

PROCEDURE block;
 VAR   adr, L0: CARDINAL;             (* data address & initial code index *)
       hd, obj: ObjPtr;
 PROCEDURE ConstDeclaration;
  VAR   obj: ObjPtr;
  BEGIN wL ("ConstDeclaration");
    IF (sym = ident) THEN GetSym;
       IF (sym = eql) OR (sym = becomes) THEN
          IF (sym = becomes) THEN err (1) END;
          GetSym;
          IF (sym #  number) THEN err (2);
          ELSE obj := NewObj (Const); obj^.val := num; GetSym END;
       ELSE err (3) END;
    ELSE err (4) END; END ConstDeclaration;
 PROCEDURE VarDeclaration;
 VAR   obj: ObjPtr;
 BEGIN wL ("VarDeclaration");
    IF (sym = ident) THEN obj := NewObj (Var); GetSym;
         obj^.vlev := curlev; obj^.vadr := adr; INC (adr);
    ELSE err (4) END; END VarDeclaration;
BEGIN wL ("block");
      INC (curlev); adr := 3;
   ALLOCATE (hd, TSIZE (Object));
   WITH hd^ DO
     kind := Header; next := NIL; last := hd; name :=0; down := topScope END;
   topScope := hd; L0 := Label (); Gen (6, 0, 0);                  (* jump *)
   IF (sym = const) THEN GetSym;
      LOOP ConstDeclaration;
        IF    (sym = comma) THEN GetSym;
        ELSIF (sym = semicolon) THEN GetSym; EXIT;
        ELSIF (sym = ident) THEN err (5);
        ELSE  err (5); EXIT END; END END;
   IF (sym = var) THEN GetSym;
      LOOP VarDeclaration;
        IF    (sym = comma) THEN GetSym;
        ELSIF (sym = semicolon) THEN GetSym; EXIT;
        ELSIF (sym = ident) THEN err (5);
        ELSE  err (5); EXIT END; END END;
   WHILE (sym =procedure) DO GetSym;
     IF  (sym =    ident) THEN GetSym ELSE err (4) END;
     obj := NewObj (Proc);
     obj^.plev := curlev;
     obj^.padr := Label ();
     IF (sym = semicolon) THEN GetSym ELSE err (5) END;
     block;
     IF (sym = semicolon) THEN GetSym ELSE err (5) END; END;
   fixup (L0); Gen (5, 0, adr);                                   (* enter *)
   statement;
   Gen (1, 0, 0);                                                (* return *)
   topScope := topScope^.down; DEC (curlev);
   END block;

PROCEDURE OpenParsWindow;
 BEGIN OpenTextWindow (win, {0, 6,7, 8}, 007,161, 204,155, WINTITLE);
   END OpenParsWindow;

PROCEDURE Parse;
 BEGIN noerr := TRUE; topScope := NIL; curlev := 0;
       ResetHeap (bottom);
       Write (win, FF);
   IF (source.hdl  > 5) THEN GetSym; block;
      IF (sym # period) THEN err (9) END; END; END Parse;

PROCEDURE EndParser; BEGIN CloseTextWindow (win) END EndParser;

BEGIN ALLOCATE (undef, TSIZE (Object));
      ALLOCATE (bottom, 0);
   WITH undef^ DO name :=0; next := NIL; kind := Var; vlev :=0; vadr :=0 END;
   END  PL0Parser  .
