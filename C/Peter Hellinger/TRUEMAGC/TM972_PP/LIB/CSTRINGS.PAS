UNIT CStrings;

INTERFACE

FUNCTION  StrLen     (CONST str: ARRAY OF CHAR): LONGINT;
FUNCTION  StrComp    (CONST str1, str2: ARRAY OF CHAR): INTEGER;
FUNCTION  StrLexComp (CONST str1, str2: ARRAY OF CHAR): INTEGER;
FUNCTION  StrLComp   (CONST str1, str2: ARRAY OF CHAR; maxLen: LONGINT): INTEGER;
FUNCTION  StrPas     (CONST str: ARRAY OF CHAR): String;
PROCEDURE StrC       (str: STRING; VAR cstr: ARRAY OF CHAR);
FUNCTION  StrPos     (CONST str1, str2: ARRAY OF CHAR): INTEGER;
FUNCTION  StrScan    (CONST str: ARRAY OF CHAR; c: Char): INTEGER;
FUNCTION  StrIPos    (CONST str1, str2: ARRAY OF CHAR; start: INTEGER): INTEGER;
FUNCTION  StrWPos    (CONST str1, str2: ARRAY OF CHAR; start: INTEGER; wild, joker: CHAR): INTEGER;
FUNCTION  StrMatch   (CONST str1, str2: ARRAY OF CHAR; wild, joker: CHAR): BOOLEAN;
PROCEDURE StrCopy    (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
PROCEDURE StrICopy   (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; start, len: INTEGER);
PROCEDURE StrPCopy   (VAR dest: ARRAY OF CHAR; CONST source: String);
PROCEDURE StrLCopy   (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxlen: LONGINT);
PROCEDURE StrCat     (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
PROCEDURE StrLCat    (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxLen: LONGINT);
PROCEDURE StrInsert  (CONST str1: ARRAY OF CHAR; VAR str2: ARRAY OF CHAR; start: INTEGER);
PROCEDURE StrDelete  (VAR str: ARRAY OF CHAR; start, len: INTEGER);
PROCEDURE StrLower   (VAR str: ARRAY OF CHAR);
PROCEDURE StrUpper   (VAR str: ARRAY OF CHAR);
FUNCTION  StrSimilar (CONST cs1, cs2: ARRAY OF CHAR): INTEGER;

FUNCTION Lexval (ch: CHAR): INTEGER;

IMPLEMENTATION

USES Basics;

{$I COMPOPT.INC}

FUNCTION  StrLen (CONST str: ARRAY OF CHAR): LONGINT;
VAR l: LONGINT;
BEGIN
 l:= 0;  WHILE str[l] > #0 DO INC (l);  StrLen:= l;
END (*StrLen*);

FUNCTION  StrComp (CONST str1, str2: ARRAY OF CHAR): INTEGER;
VAR l: LONGINT;
BEGIN
 StrComp:= 0;  l:= 0;
 WHILE (str1[l] <> #0) DO BEGIN
  IF (str2[l] = #0) OR (str1[l] < str2[l]) THEN BEGIN  StrComp:= -1;  EXIT;  END;
  IF str1[l] > str2[l] THEN BEGIN  StrComp:= 1;  EXIT;  END;
  INC (l);
 END;
 IF str2[l] <> #0 THEN StrComp:= 1;
END (*StrComp*);


CONST MaxLexval = 68;

TYPE  tLexvals = ARRAY [0..MaxLExval] OF CHAR;

CONST Lexvals: tLexvals = #0' AaŽ„BbCcDdEeFfGgHhIiJjKkLlMmNnOo™”PpQqRrSsžTtUuVvWwXxYyZz0123456789';

FUNCTION Lexval (ch: CHAR): INTEGER;
VAR i: INTEGER;
BEGIN
 FOR i:= 0 TO MaxLexval DO BEGIN
  IF ch = Lexvals[i] THEN BEGIN  Lexval:= i;  EXIT;  END;
 END;
 Lexval:= -1;
END (*Lexval*);

FUNCTION GetNum (CONST c: ARRAY OF CHAR; VAR l: LONGINT): LONGINT;
VAR y: LONGINT;
    err: INTEGER;
    s: STRING;
BEGIN
 s:= '';
 WHILE ((c[l] >= '0') AND (c[l] <= '9')) DO BEGIN  s:= s + c[l];  INC (l);  END;
 DEC (l);
 VAL (s, y, err);
 GetNum:= y;
END (*GetNum*);

FUNCTION  Upper (ch: CHAR): CHAR;
BEGIN
 CASE ch OF
  '„': ch:= 'Ž';
  '”': ch:= '™';
  '': ch:= 'š';
 END;
 Upper:= ch;
END (*Upper*);

FUNCTION  StrLexComp (CONST str1, str2: ARRAY OF CHAR): INTEGER;
VAR l1, l2, x, y: LONGINT;
    v1, v2: INTEGER;
BEGIN
 l1:= 0;  l2:= 0;
 y:= Max (StrLen (str1), StrLen (str2)) + 1;
 REPEAT
  v1:= Lexval (Upper (str1[l1]));
  v2:= Lexval (Upper (str2[l2]));
  IF (v1 > 58) AND (v2 > 58) THEN BEGIN
   v1:= GetNum (str1, l1);  (* Erste Zahl *)
   v2:= GetNum (str2, l2);  (* Zeite Zahl *)
  END;
  IF (v1 < v2) THEN  BEGIN  StrLexComp:= -1;  EXIT;  END;
  IF (v1 > v2) THEN  BEGIN  StrLexComp:=  1;  EXIT;  END;
  INC (l1);
  INC (l2);
 UNTIL l1 = y;
 StrLexComp:= 0;
END (*StrLexComp*);

FUNCTION  StrLComp  (CONST str1, str2: ARRAY OF CHAR; maxLen: LONGINT): INTEGER;
VAR l: LONGINT;
BEGIN
 StrLComp:= 0;  l:= 0;
 WHILE (str1[l] <> #0) AND (str2[l] <> #0) AND (l < maxLen) DO BEGIN
  IF str1[l] < str2[l] THEN BEGIN  StrLComp:= -1;  EXIT;  END;
  IF str1[l] > str2[l] THEN BEGIN  StrLComp:=  1;  EXIT;  END;
  INC (l);
 END;
END (*StrLComp*);

FUNCTION StrPas (CONST str: ARRAY OF CHAR): STRING;
VAR ps: STRING;
    i, l: LONGINT;
BEGIN
 CToPascalString (ps, @str);
 StrPas:= ps;
END (*StrPas*);

PROCEDURE StrC (str: STRING; VAR cstr: ARRAY OF CHAR);
BEGIN
 PascaltoCString (str, @cstr);
END (*StrC*);

FUNCTION StrPos (CONST str1, str2: ARRAY OF CHAR): INTEGER;
BEGIN
 StrPos:= StrIPos (str1, str2, 0);
END (*StrPos*);

FUNCTION  StrScan (CONST str: ARRAY OF CHAR; c: Char): INTEGER;
VAR l: INTEGER;
BEGIN
 l:= 0;  WHILE (str[l] > #0) AND (str[l] <> c) DO  INC (l); StrScan:= l;
END (*StrScan*);

FUNCTION  StrIPos (CONST str1, str2: ARRAY OF CHAR; start: INTEGER): INTEGER;
VAR s, l1, l2, j: INTEGER;
BEGIN
 StrIPos:= -1;
 l1:= StrLen (str1);
 l2:= StrLen (str2);
 IF (l1 > 0) AND (l2 > 0) THEN BEGIN
  s:= start;
  REPEAT (* 1 *)
   j:= 0;
   WHILE (str1[j] = str2[s+j]) AND (j < l1) DO BEGIN
    INC (j);  IF (j = l1) THEN BEGIN  StrIPos:= s;  EXIT;  END;
   END;
   INC (s);
  UNTIL s >= l2;
 END;
END (*StrIPos*);

PROCEDURE StrCopy (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
VAR l: LONGINT;
BEGIN
 l:= 0;
 WHILE (source[l] > #0) DO BEGIN
  dest[l]:= source[l];  INC (l);
 END;
 dest[l]:= #0;
END (*StrCopy*);

PROCEDURE StrICopy  (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; start, len: INTEGER);
VAR l: LONGINT;
BEGIN
 l:= 0;
 WHILE (source[l+start] > #0) AND (l < len) DO BEGIN
  dest[l]:= source[l+start];  INC (l);
 END;
 dest[l]:= #0;
END (*StrICopy*);

PROCEDURE StrLCopy (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxlen: LONGINT);
VAR l: LONGINT;
BEGIN
 l:= 0;
 WHILE (source[l] > #0) AND (l <= maxlen) DO BEGIN
  dest[l]:= source[l];  INC (l);
 END;
 dest[l]:= #0;
END (*StrLCopy*);

PROCEDURE StrPCopy (VAR dest: ARRAY OF CHAR; CONST source: String);
VAR c, p: LONGINT;
BEGIN
 PascalToCString (source, @dest);
END (*StrPCopy*);

PROCEDURE StrCat (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
VAR c, p: LONGINT;
BEGIN
 c:= StrLen (dest);  p:= 0;
 WHILE (source[p] > #0) DO BEGIN
  dest[c]:= source[p];  INC (c);  INC (p);
 END;
 dest[c]:= #0;
END (*StrCat*);

PROCEDURE StrLCat (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxLen: LONGINT);
VAR c, p: LONGINT;
BEGIN
 c:= StrLen (dest);  p:= 0;
 WHILE (source[p] > #0) AND (p < maxlen) DO BEGIN
  dest[c]:= source[p];  INC (c);  INC (p);
 END;
 dest[c]:= #0;
END (*StrLCat*);

PROCEDURE StrUpper (VAR str: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 i:= 0;
 WHILE str[i] > #0 DO BEGIN
  CASE str[i] OF
   'a'..'z': str[i]:= CHR (ORD (str[i]) - 32);
        '„': str[i]:= 'Ž';
        '”': str[i]:= '™';
        '': str[i]:= 'š';
   ELSE ;
  END;
  INC (i);
 END;
END (*StrUpper*);

PROCEDURE StrLower (VAR str: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 i:= 0;
 WHILE str[i] > #0 DO BEGIN
  CASE str[i] OF
   'A'..'Z': str[i]:= CHR (ORD (str[i]) + 32);
        'Ž': str[i]:= '„';
        '™': str[i]:= '”';
        'š': str[i]:= '';
   ELSE ;
  END;
  INC (i);
 END;   
END (*StrLower*);

FUNCTION StrWPos (CONST str1, str2: ARRAY OF CHAR;
                  start: INTEGER; wild, joker: CHAR): INTEGER;
VAR s, j, l1, l2: INTEGER;
BEGIN
 StrWPos:= -1;
 l1:= StrLen (str1);
 l2:= StrLen (str2);
 IF (l1 > 0) AND (l2 > 0) THEN BEGIN
  s:= start;
  REPEAT (* 1 *)
   j:= 0;
   WHILE ((str1[j] = str2[s+j]) OR (str1[j] = joker)) AND 
          (j < l1) DO BEGIN
    INC (j);
    IF (str1[j] = wild) OR (j >= l1) THEN BEGIN
     StrWPos:= s;  EXIT;
    END;
   END;
   INC (s);
  UNTIL s >= l2;
 END;
END (*StrWPos*);

FUNCTION StrMatch  (CONST str1, str2: ARRAY OF CHAR; wild, joker: CHAR): BOOLEAN;
VAR s, i, l1, l2: INTEGER;
BEGIN
 StrMatch:= TRUE;
 l1:= StrLen (str1);
 l2:= StrLen (str2);
 IF l1 < 1 THEN BEGIN  StrMatch:= FALSE;  EXIT;  END;
 FOR i:= 0 TO l1-1 DO BEGIN
  IF (str1[i] = wild) OR (i > l2) THEN  EXIT;
  IF (str1[i] <> str2[i]) AND (str1[i] <> joker) THEN  BEGIN 
   StrMatch:= FALSE;  EXIT;
  END;
 END;
END (*StrMatch*);

PROCEDURE StrInsert (CONST str1: ARRAY OF CHAR;
                     VAR str2: ARRAY OF CHAR; start: INTEGER);
VAR i, len: INTEGER;
BEGIN
 len:= StrLen (str1);
 Move (str2[start], str2[start+len], StrLen (str2) - start + 1);
 FOR i:= 0 TO len-1 DO str2[start+i]:= str1[i];
END (*StrInsert*);

PROCEDURE StrDelete (VAR str: ARRAY OF CHAR; start, len: INTEGER);
VAR i, j, l: INTEGER;
BEGIN
 l:= StrLen(str);
 IF len >= l THEN BEGIN 
  WHILE start <= l DO BEGIN  str[start]:= #0; INC (start);  END;
  EXIT;
 END;
 FOR i:= 1 TO len DO BEGIN
  j:= start;
  REPEAT
   str[j]:= str[j + 1];  INC (j);
  UNTIL str[j] = #0;
 END;
END (*StrDelete*);

FUNCTION StrSimilar (CONST cs1, cs2: ARRAY OF CHAR): INTEGER;
VAR treffer, p1, p2, l1, l2, pt, diff: INTEGER;
    s1, s2, hstr: STRING;
    test: ARRAY [1..255] OF BOOLEAN;
BEGIN
 s1:= StrPas (cs1);
 s2:= StrPas (cs2);
 IF Length(s1) < Length(s2) THEN BEGIN
  hstr:= s2;  s2:= s1;  s1:= hstr;
 END;
 l1:= Length (s1);
 l2:= Length (s2);
 p1:= 1;  p2:= 1;  treffer:= 0;
 diff:= Max (l1, l2) DIV 3 + ABS (l1 - l2);
 FOR pt:= 1 TO l1 DO  test[pt]:= FALSE;
 REPEAT
  IF NOT (test[p1]) THEN BEGIN
   IF (s1[p1] = s2[p2]) AND (ABS(p1-p2) <= diff) THEN BEGIN
    test[p1]:= TRUE;
    treffer:= Succ(treffer);
    p1:= Succ(p1);
    p2:= Succ(p2);
    IF p1 > l1 THEN p1:= 1;
   END ELSE BEGIN
    test[p1]:= FALSE;
    p1:= Succ(p1);
    IF p1 > Length(s1) THEN BEGIN
     WHILE (p1 > 1) AND NOT(test[p1]) DO  p1:= Pred(p1);
     p2:= Succ(p2)
    END;
   END;
  END ELSE BEGIN
   p1:= Succ(p1);
   IF p1 > Length(s1) THEN BEGIN
    REPEAT
     p1:= Pred(p1);
    UNTIL (p1 = 1) OR test[p1];
    p2:= Succ(p2)
   END;
  END;
 UNTIL p2 > Length(s2);
 StrSimilar:= 100 * treffer DIV l1;
END (*StrSimilar*);

END (*CStrings*).
