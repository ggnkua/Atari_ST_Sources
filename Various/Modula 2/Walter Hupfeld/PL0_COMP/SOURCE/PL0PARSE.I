IMPLEMENTATION MODULE PL0Parser;

FROM SYSTEM IMPORT TSIZE;

FROM Storage IMPORT ALLOCATE(*, CreateHeap *);

FROM TextWindows IMPORT Window,WritePg;

FROM Windows IMPORT  OpenTextWindow, Write, WriteLn,
                     WriteCard, WriteString, Invert, CloseTextWindow;
                        
FROM PL0Scanner IMPORT Symbol, sym, id, num, Diff, KeepId, GetSym, Mark;

FROM PL0Generator IMPORT Label, Gen, fixup;


TYPE 
  ObjectClass = (Const, Var, Proc, Header);
  ObjPtr = POINTER TO Object;
  Object = RECORD
             name : CARDINAL;
             next : ObjPtr;
             CASE kind : ObjectClass OF
               Const  : val : INTEGER;                  |
               Var    : vlev, vadr : CARDINAL;          |
               Proc   : plev, padr, size : CARDINAL;    |
               Header : last, down : ObjPtr;            |
             END;
           END;  


VAR
  topScope, bottom,undef : ObjPtr;
  curlev : CARDINAL;
  win : Window;
  

PROCEDURE err(n : CARDINAL);
BEGIN
  noerr := FALSE; Mark(n);
  Invert(win,TRUE);
  WriteCard(win,n,1);
  Invert(win,FALSE);
END err;


(*  - neues Objekt einrichten
    - Fehlermeldung ausgeben, falls bereits ein Objekt mit diesem
      Namen definiert ist *)

PROCEDURE test(s:Symbol; n:CARDINAL);
BEGIN
  IF sym < s THEN err(n);
    REPEAT GetSym UNTIL sym >= s
  END
END test;



PROCEDURE NewObj(k : ObjectClass) : ObjPtr;
VAR
  obj : ObjPtr;
  
BEGIN
  obj := topScope^.next;
  WHILE obj # NIL DO
    IF Diff(id,obj^.name)=0 THEN
       err(25);
    END;
    obj := obj^.next;
  END;
  
  ALLOCATE(obj,TSIZE(Object));
  WITH obj^ DO
    name := id;
    kind := k;
    next := NIL;
  END; (* WITH *)
  
  KeepId;
  topScope^.last^.next := obj;
  topScope^.last := obj;
  RETURN obj;
END NewObj;


PROCEDURE find(id : CARDINAL) : ObjPtr;
VAR
  hd, obj : ObjPtr;
  
BEGIN
  hd := topScope;
  WHILE hd # NIL DO
    obj := hd^.next;
    WHILE obj # NIL DO
      IF Diff(id,obj^.name)=0 THEN RETURN obj;
      ELSE obj := obj^.next;
      END;
    END;
    hd := hd^.down;
  END;
  err(11); RETURN undef
END find;


PROCEDURE expression;
VAR
  addop : Symbol;
  
  
  PROCEDURE factor;
  VAR
    obj : ObjPtr;
    
  BEGIN
    WriteString(win,"factor");WriteLn(win);
    test(lparen,6);
    IF sym=ident THEN obj := find(id);
       WITH obj^ DO
         CASE kind OF
           Const :Gen(0,0,val) |
           Var   :Gen(2,curlev-vlev,vadr)   |    
           Proc  : err(21);      
         END;
       END; (* WITH *)
       GetSym;
    ELSIF sym=number THEN 
       Gen(0, 0, num); GetSym;
    ELSIF sym=lparen THEN
       GetSym; expression;
       IF sym=rparen THEN GetSym ELSE err(7) END
    ELSE err(8);
    END;
  END factor;
  
 
  PROCEDURE term;
  VAR
    mulop : Symbol;
    
  BEGIN
    WriteString(win,"term");
    WriteLn(win);
    factor;
    WHILE (times<=sym) AND (sym<=div) DO
      mulop := sym;
      GetSym;
      factor;
      IF mulop=times THEN Gen(1,0,4);
      ELSE  Gen(1,0,5);
      END
    END
  END term;
  
BEGIN
  WriteString(win,"expression");
  WriteLn(win);
  IF (plus<=sym) AND (sym<=minus) THEN
     addop := sym;
     GetSym;
     term;
     IF addop=minus THEN
        Gen(1,0,1);
     END;
  ELSE
     term; 
  END;
  
  WHILE (plus<=sym) AND (sym<=minus) DO
    addop := sym;
    GetSym;
    term;
    IF addop=plus THEN
       Gen(1,0,2);
    ELSE
       Gen(1,0,3);
    END;
  END;
END expression;


PROCEDURE condition;
VAR
  relop : Symbol;
  
BEGIN
  WriteString(win,"condition");
  WriteLn(win);
  IF sym=odd THEN
     GetSym;
     expression;
     Gen(1,0,6);
  ELSE
     expression;
     IF (eql<=sym) AND (sym<=geq) THEN
        relop := sym;
        GetSym;
        expression;
        CASE relop OF
          eql : Gen(1,0,8);     |
          neq : Gen(1,0,9);     |
          lss : Gen(1,0,10);    |
          geq : Gen(1,0,11);    |
          gtr : Gen(1,0,12);    |
          leq : Gen(1,0,13);    |
        END;
     ELSE
        err(20);
     END;
  END;
END condition;


PROCEDURE statement;
VAR
  obj : ObjPtr;
  L0, L1 : CARDINAL;
  
BEGIN
  WriteString(win,"statement"); WriteLn(win);
  test(ident,10);
  IF sym=ident THEN
     obj := find(id); 
     IF obj^.kind # Var THEN err(12); obj:=NIL END;
     GetSym;
     IF sym=becomes THEN GetSym
     ELSIF sym = eql THEN err(13);GetSym
     ELSE err(13)
     END;
     expression;
     IF obj # NIL THEN
       Gen(3,curlev - obj^.vlev,obj^.vadr)   (* store *)
     END
  ELSIF sym=call THEN
     GetSym;
     IF sym=ident THEN
        obj := find(id); 
        IF obj^.kind = Proc THEN
          Gen(4, curlev - obj^.plev, obj^.padr)   (* call *)
        ELSE err(15)
        END;
        GetSym;
     ELSE err(14)
     END
  ELSIF sym=begin THEN GetSym;
    LOOP statement;
      IF sym=semicolon THEN GetSym
      ELSIF sym=end THEN GetSym; EXIT
      ELSIF sym < const THEN err(17)
      ELSE err(17); EXIT
      END
    END
  ELSIF sym=if THEN
     GetSym;
     condition;
     IF sym=then THEN GetSym ELSE err(16) END;
     L0:=Label(); Gen(7,0,0); statement; fixup(L0);
  ELSIF sym=while THEN L0:=Label();
     GetSym;  condition; L1:=Label(); Gen(7,0,0);
     IF sym=do THEN GetSym ELSE err(18) END;
     statement;Gen(6,0,L0); fixup(L1);
  ELSIF sym=read THEN
     GetSym;
     IF sym=ident THEN 
       obj := find(id);
       IF obj^.kind = Var THEN
         Gen(1,0,14); Gen(3, curlev - obj^.vlev, obj^.vadr)
       ELSE err(12)
       END
     ELSE err(14);
     END;
     GetSym
  ELSIF sym=write THEN
     GetSym; expression; Gen(1,0,15)
  END;
  test(ident,19)
END statement;


PROCEDURE block;
VAR
  adr : CARDINAL;
  L0 : CARDINAL;
  hd, obj : ObjPtr;
  
  
  PROCEDURE ConstDeclaration;
  VAR
    obj : ObjPtr;
    
  BEGIN
    WriteString(win,"ConstDeclaration");
    WriteLn(win);
    IF sym=ident THEN
       GetSym;
       IF (sym=eql) OR (sym=becomes) THEN
          IF sym=becomes THEN
             err(1);
          END;
          GetSym;
          IF sym=number THEN
             obj := NewObj(Const);
             obj^.val := num;
             GetSym;
          ELSE
             err(2);
          END;
       ELSE
          err(3);
       END;
    ELSE
       err(4);
    END;
  END ConstDeclaration;
  

  PROCEDURE VarDeclaration;
  VAR
    obj : ObjPtr;
    
  BEGIN
    WriteString(win,"VarDeclaration");
    WriteLn(win);
    IF sym=ident THEN
       obj := NewObj(Var); GetSym;
       obj^.vlev:= curlev; obj^.vadr:=adr; adr:=adr+1
    ELSE
       err(4);
    END;
  END VarDeclaration;
  

BEGIN
  WriteString(win,"block ");WriteLn(win);
  curlev:=curlev + 1; adr := 3;
  ALLOCATE(hd,TSIZE(Object));
  WITH hd^ DO
    kind := Header;
    next := NIL;
    last := hd;
    name := 0;
    down := topScope;
  END;
  topScope := hd;
  L0 := Label();
  Gen(6,0,0);
  IF sym=const THEN GetSym;
     LOOP 
       ConstDeclaration;
       IF sym=comma THEN GetSym;
       ELSIF sym=semicolon THEN  GetSym; EXIT
       ELSIF sym=ident THEN err(5)
       ELSE err(5); EXIT
       END
     END
  END;
  IF sym = var THEN GetSym;
    LOOP VarDeclaration;
      IF  sym = comma THEN GetSym
      ELSIF sym = semicolon THEN GetSym; EXIT
      ELSIF sym = ident THEN err(5)
      ELSE err(5); EXIT
      END
    END
  END;
  WHILE sym=procedure DO
    GetSym;
    IF sym=ident THEN GetSym ELSE err(4) END;
    obj := NewObj(Proc);
    obj^.plev := curlev;
    obj^.padr := Label();
    IF sym=semicolon THEN GetSym ELSE err(5) END;
    block;
    IF sym=semicolon THEN GetSym ELSE err(5) END;
  END;
  fixup(L0); Gen(5,0,adr);
  statement;
  Gen(1,0,0);
  topScope := topScope^.down; curlev:=curlev - 1
END block;


PROCEDURE Parse;
BEGIN
  noerr := TRUE;
  topScope := NIL;
  curlev := 0;
  WritePg(win);
(*  noerr := CreateHeap(100000,TRUE);*)
  GetSym;
  block;
  IF sym # period THEN
     err(9);
  END;
END Parse;


PROCEDURE EndParser;
BEGIN
  CloseTextWindow(win);
END EndParser;


BEGIN
  ALLOCATE(undef,TSIZE(Object));
  ALLOCATE(bottom,0);
  WITH undef^ DO
    name := 0;
    next := NIL;
    kind := Var;
    vlev := 0;
    vadr := 0;
  END; (* WITH *)
  OpenTextWindow(win,1,13,25,12,"PARSE");
END PL0Parser.


