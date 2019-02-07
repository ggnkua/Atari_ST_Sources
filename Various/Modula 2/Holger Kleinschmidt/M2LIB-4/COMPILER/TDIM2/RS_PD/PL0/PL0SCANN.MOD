IMPLEMENTATION MODULE PL0Scanner;
(*$S-,$T-,$Q+*)

FROM  Terminal    IMPORT BusyRead, Read;
FROM  FileSystem  IMPORT ReadChar;
FROM  TextWindows IMPORT Window, Invert, Write, OpenTextWindow,
                         WriteLn, WriteCard,   CloseTextWindow;

CONST maxCard = 177777B; bufLen = 1000; FF = 14c; WINTITLE = " PROGRAM ";

VAR   ch:      CHAR;                                (* last character read *)
      id0,id1: CARDINAL;                   (* indices to identifier buffer *)
      win:     Window;
      keyTab:  ARRAY [1..20] OF RECORD sym: Symbol; ind: CARDINAL END;
      K:       CARDINAL;                             (* number of keywords *)
      buf:     ARRAY [0..bufLen-1] OF CHAR;
     (* character buffer: identifiers are stored with leading length count.*)

PROCEDURE Mark (n: CARDINAL);
 BEGIN Invert (win, TRUE); WriteCard (win, n, 1);
       Invert (win, FALSE) END Mark;

PROCEDURE GetCh; BEGIN ReadChar (source, ch); Write (win, ch) END GetCh;

PROCEDURE Diff (u,v: CARDINAL): INTEGER;
 VAR   w: CARDINAL;
 BEGIN w := ORD (buf[u]);
  LOOP IF (w = 0) THEN RETURN 0 END;
    IF (buf[u] #buf[v]) THEN RETURN (INTEGER (buf[u]) -INTEGER (buf[v])) END;
    INC (u); INC (v); DEC (w); END; END Diff;

PROCEDURE KeepId; BEGIN id := id1 END KeepId;

PROCEDURE Identifier;
 VAR   k,l,m: CARDINAL; d: INTEGER;
 BEGIN id1 := id;
   IF (id1 < bufLen) THEN INC (id1) END;
   REPEAT IF (id1 < bufLen) THEN buf[id1] := ch; INC (id1) END;
      GetCh; UNTIL (ch< "0") OR ("9" <ch) & (CAP(ch) <"A") OR ("Z"< CAP(ch));
   buf[id] := CHR (id1-id) (*length!*);
   k := 1; l := K;
   REPEAT m := (k+l) DIV 2;
          d := Diff (id, keyTab[m].ind);
      IF (d <= 0) THEN l := m -1 END;
      IF (d >= 0) THEN k := m +1 END;
   UNTIL (k > l);
   IF (k > l+1) THEN sym := keyTab[m].sym ELSE sym := ident END;
   END Identifier;

PROCEDURE Number;
 VAR   i,j,k,d: CARDINAL; dig: ARRAY [0..31] OF CHAR;
 BEGIN i := 0; sym := number;
   REPEAT dig[i] := ch; INC (i); GetCh;
   UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch));
   j := 0; k := 0;
   REPEAT d := CARDINAL (dig[j]) - 60B;
     IF  (d < 10) & ((maxCard-d) DIV 10 >= k) THEN k := 10 *k +d;
     ELSE Mark (30); k := 0 END;
     INC (j); UNTIL (j = i);
   num := k; END Number;

PROCEDURE KeyStep;
   VAR  bs: BITSET; xch: CHAR;
 BEGIN  BusyRead (xch); IF (0c < xch) THEN Read (xch); RETURN END;
        (* ^ not working properly when DoRead is EventKeyboard. Therefore: *)
(* But better do this via Terminal.DoStatus in PL0 main program:
   LOOP bs := KBShiftS ();
     IF bs = { } THEN EXIT END;    (* No wait if keyboard state is cleared.*)
     IF bs = {4} THEN Read (xch); EXIT END; (* LOCK? can step by space bar.*)
     END;
*) END KeyStep;

PROCEDURE GetSym;
 PROCEDURE Comment;
  BEGIN GetCh; REPEAT WHILE (ch # "*") DO GetCh END; GetCh UNTIL (ch = ")");
        GetCh; END Comment;
 BEGIN  KeyStep;
   LOOP IF (ch <= " ") THEN IF (ch = 0c) THEN ch := " "; EXIT ELSE GetCh END;
     ELSIF (ch >= 177c) THEN GetCh;     (* ignore control characters etc.! *)
     ELSE EXIT END; END;
   CASE ch OF
   |" ": sym := eof; ch := 0c;
   |"A".."Z",
    "a".."z": Identifier;
   |"0".."9": Number;
   |"!": sym := write;  GetCh;
   |"#": sym := neq;    GetCh;
   |"(": GetCh; IF (ch = "*") THEN Comment; GetSym ELSE sym := lparen END;
   |")": sym := rparen; GetCh;
   |"*": sym := times;  GetCh;
   |"+": sym := plus;   GetCh;
   |",": sym := comma;  GetCh;
   |"-": sym := minus;  GetCh;
   |".": sym := period; GetCh;
   |"/": sym := div;    GetCh;
   |":": GetCh; IF (ch="=") THEN GetCh; sym := becomes ELSE sym := null END;
   |";": sym := semicolon; GetCh;
   |"<": GetCh; IF (ch="=") THEN GetCh; sym := leq ELSE sym := lss END;
   |"=": sym := eql; GetCh;
   |">": GetCh; IF (ch="=") THEN GetCh; sym := geq ELSE sym := gtr END;
   |"?": sym := read; GetCh;
   ELSE (* '['..'`', '{'..'~', '"','$','%','&',"'",'@', ... *)
         sym := null; GetCh END;
   END GetSym;

PROCEDURE OpenScanWindow;
 BEGIN OpenTextWindow (win, {0, 6,7, 8}, 007,021, 626,136, WINTITLE);
   END OpenScanWindow;

PROCEDURE InitScanner;
 BEGIN  ch := " ";
   IF   (0  = id0) THEN id0 := id;
   ELSE id := id0; Write (win, FF); WriteLn (win) END;
   END InitScanner;

PROCEDURE CloseScanner; BEGIN CloseTextWindow (win) END CloseScanner;

PROCEDURE EnterKW (sym: Symbol; name: ARRAY OF CHAR);
   VAR l,L : CARDINAL;
 BEGIN INC (K);
   keyTab[K].sym := sym;
   keyTab[K].ind := id;
   l := 0; L := HIGH (name);
   buf[id] := CHR (L+2);
   INC(id);
   WHILE (l <= L) DO buf[id] := name[l]; INC (id); INC (l) END;
   END EnterKW;

BEGIN K := 0; id := 0; id0 := 0;
   EnterKW (do,    "DO");
   EnterKW (if,    "IF");
   EnterKW (end,   "END");
   EnterKW (odd,   "ODD");
   EnterKW (var,   "VAR"); 
   EnterKW (call,  "CALL");
   EnterKW (then,  "THEN");
   EnterKW (begin, "BEGIN");
   EnterKW (const, "CONST");
   EnterKW (while, "WHILE");
   EnterKW (procedure, "PROCEDURE");
   END PL0Scanner .
