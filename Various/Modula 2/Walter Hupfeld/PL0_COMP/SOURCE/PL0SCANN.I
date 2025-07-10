IMPLEMENTATION MODULE PL0Scanner;

IMPORT Text;
FROM TextWindows IMPORT Window,WritePg,KeyPressed,BusyRead,Read;
FROM Windows    IMPORT OpenTextWindow, Write, WriteCard,
                 Invert, CloseTextWindow,WriteLn;
FROM Files IMPORT EOF;

CONST
  maxCard = 177777B;
  bufLen = 1000;
  
VAR
  ch : CHAR;
  id0, id1 : CARDINAL;
  win : Window;
  keyTab : ARRAY [1..20] OF RECORD
                              sym : Symbol;
                              ind : CARDINAL;
                            END;
  K : CARDINAL;
  buf : ARRAY [0..bufLen-1] OF CHAR;
  

PROCEDURE Mark(n : CARDINAL);
BEGIN
  Invert(win,TRUE);
  WriteCard(win,n,1);
  Invert(win,FALSE);
END Mark;


PROCEDURE GetCh;
BEGIN
      Text.Read(source,ch);
      IF Text.EOL(source) THEN WriteLn(win) END;
      IF ch=0C THEN ch:=" "  END; 
      IF EOF(source) THEN ch:=0C END;
      Write(win,ch);
END GetCh;


PROCEDURE Diff(u,v : CARDINAL) : INTEGER;
VAR
  w : CARDINAL;
  
BEGIN
  w := ORD(buf[u]);
  LOOP
    IF w=0 THEN 
       RETURN 0;
    ELSIF buf[u] # buf[v] THEN
       RETURN INTEGER(ORD(buf[u])) - INTEGER(ORD(buf[v]));
    ELSE
       INC(u);
       INC(v);
       DEC(w);
    END;
  END;
END Diff;


PROCEDURE KeepId;
BEGIN
  id := id1;
END KeepId;


PROCEDURE Identifier;
VAR
  k,l,m : CARDINAL;
  d : INTEGER;
  
BEGIN
  id1 := id;
  IF id1<bufLen THEN
     INC(id1);
  END;
  REPEAT
    IF id1<bufLen THEN
       buf[id1] := ch;
       INC(id1);
    END;
    GetCh;
  UNTIL (ch<"0") OR ("9"<ch) &
        (CAP(ch)<"A") OR ("Z"<CAP(ch));
  buf[id] := CHR(id1-id);
  k := 1;
  l := K;
  REPEAT 
    m := (k+l) DIV 2;
    d := Diff(id,keyTab[m].ind);
    IF d<=0 THEN
       l := m - 1;
    END;
    IF d>=0 THEN
       k := m + 1;
    END;
  UNTIL k>l;
  IF k>l+1 THEN
     sym := keyTab[m].sym;
  ELSE
     sym := ident;
  END;
END Identifier;


PROCEDURE Number;
VAR
  i,j,k,d : CARDINAL;
  dig : ARRAY [0..31] OF CHAR;
  
BEGIN
  sym := number;
  i := 0;
  REPEAT
    dig[i] := ch;
    INC(i);
    GetCh;
  UNTIL (ch<"0") OR ("9" < ch) & (CAP(ch)<"A") OR ("Z"<CAP(ch));
  j := 0;
  k := 0;
  REPEAT
    d := CARDINAL(ORD(dig[j])) - 60B;
    IF (d<10) AND ((maxCard-d) DIV 10 >=k) THEN 
       k := 10*k + d;
    ELSE
       Mark(30);
       k := 0;
    END;
    INC(j);
  UNTIL j=i;
  num := k;
END Number;


PROCEDURE GetSym;
VAR
  xch : CHAR;
  

  PROCEDURE Comment;
  BEGIN
    GetCh;
    REPEAT
      WHILE ch # "*" DO
        GetCh;
      END;
      GetCh;
    UNTIL ch = ")";
    GetCh;
  END Comment;
  

BEGIN
  (* IF KeyPressed() THEN Read(win,xch) END; *)
  LOOP
    IF ch<=" " THEN
       IF ch=0C THEN ch := " "; EXIT END;
       GetCh
    ELSIF ch>=177C THEN GetCh
    ELSE EXIT
    END;
  END;
  CASE ch OF
    " " : sym := eof; ch := 0C;         |
    "!" : sym := write; GetCh;          |
    '"' : sym := null; GetCh;           |
    "#" : sym := neq; GetCh;            |
    "$" : sym := null; GetCh;           |
    "%" : sym := null; GetCh;           |
    "&" : sym := null; GetCh;           |
    "'" : sym := null; GetCh;           |
    "(" : GetCh;
          IF ch="*" THEN
             Comment;
             GetSym;
          ELSE
             sym := lparen;
          END; |
    ")" : sym := rparen; GetCh;         |
    "*" : sym := times; GetCh;          |
    "+" : sym := plus; GetCh;           |
    "," : sym := comma; GetCh;          |
    "-" : sym := minus; GetCh;          |
    "." : sym := period; GetCh;         |
    "/" : sym := div; GetCh;            |
    "0".."9" : Number;                  |
    ":" : GetCh;    
          IF ch="=" THEN
             GetCh;
             sym := becomes;
          ELSE
             sym := null;
          END; |
    ";" : sym := semicolon; GetCh;      |
    "<" : GetCh;
          IF ch="=" THEN
             GetCh;
             sym := leq;
          ELSE
             sym := lss;
          END; |
    "=" : sym := eql; GetCh;            |
    ">" : GetCh;
          IF ch="=" THEN
             GetCh;
             sym := geq;
          ELSE
             sym := gtr;
          END; |
    "?" : sym := read; GetCh;           |
    "@" : sym := null; GetCh;           |
    "A".."Z" : Identifier;              |
    "a".."z" : Identifier;              |
    "{".."~" : sym := null; GetCh;      |
  ELSE
    sym := null;
    GetCh;
  END;
END GetSym;

PROCEDURE InitScanner;
BEGIN
  ch := " ";
  IF id0=0 THEN
     id0 := id;
  ELSE
     id := id0;
     WritePg(win);
  END;
END InitScanner;


PROCEDURE CloseScanner;
BEGIN
  CloseTextWindow(win);
END CloseScanner;


PROCEDURE EnterKW(sym : Symbol; name : ARRAY OF CHAR);
VAR
  l,L : CARDINAL;
  
BEGIN
  INC(K);
  keyTab[K].sym := sym;
  keyTab[K].ind := id;
  l := 0;
  L := HIGH(name);
  buf[id] := CHR(L+2);
  INC(id);
  WHILE l<=L DO
    buf[id] := name[l];
    INC(id);
    INC(l);
  END;
END EnterKW;


BEGIN
  K := 0;
  id := 0;
  id0 := 0;
  EnterKW(do,"DO");
  EnterKW(if,"IF");
  EnterKW(end,"END");
  EnterKW(odd,"ODD");
  EnterKW(var,"VAR"); 
  EnterKW(call,"CALL");
  EnterKW(then,"THEN");
  EnterKW(begin,"BEGIN");
  EnterKW(const,"CONST");
  EnterKW(while,"WHILE");
  EnterKW(procedure,"PROCEDURE");
  OpenTextWindow(win,27,3,52,8,"PROGRAM");
END PL0Scanner.


        
