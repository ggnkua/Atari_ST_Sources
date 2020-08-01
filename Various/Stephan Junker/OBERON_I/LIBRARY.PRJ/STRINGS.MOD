MODULE Strings; (* SJ 10.1.93 / 29.1.95 *)


IMPORT
  S:=SYSTEM;


CONST
  EOF* = 4X; LF* = 0AX; CR* = 0DX; ESC* = 1BX;
  left* = 0; right* = 1; center* = 2; noadj* = 3;
  leftadd* = 4; rightadd* = 5;


TYPE
  ptr* = POINTER TO ARRAY 128 OF CHAR;

(*$-y *)

PROCEDURE Length* (VAR str : ARRAY OF CHAR) : INTEGER;
(*
 Returns the length of str
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str[i] # 0X DO INC(i) END(*WHILE*);
  RETURN i
 END Length;


PROCEDURE AppendC* (c : CHAR; VAR str : ARRAY OF CHAR);
(*
 Append character c to str
 *)
  VAR
    i,j : INTEGER;
 BEGIN
  i := Length(str);
  IF i < LEN(str)-1 THEN
    str[i] := c; str[i+1] := 0X
  END(*IF*);
 END AppendC;


PROCEDURE Append* (str1 : ARRAY OF CHAR; VAR str2 : ARRAY OF CHAR);
(*
 Append str1 to str2
 *)
  VAR
    i,j : INTEGER;
 BEGIN
  i := Length(str2);
  j := 0;
  WHILE (str1[j] # 0X) & (i < LEN(str2)-1) DO
    str2[i] := str1[j]; INC(i); INC(j);
  END(*WHILE*);
  str2[i] := 0X
 END Append;


PROCEDURE Cap* (VAR c : CHAR);
(*
 converts c to its capital letter. German characters are converted too
 *)
 BEGIN
  CASE c OF
    "„": c := "Ž"
  | "”": c := "™"
  | "": c := "š"
  ELSE   c := CAP(c)
  END;
 END Cap;


PROCEDURE Caps* (VAR str : ARRAY OF CHAR);
(*
 converts a string to capital letters using Cap
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str[i] # 0X DO Cap(str[i]); INC(i) END(*WHILE*);
 END Caps;


PROCEDURE CAPs* (VAR str : ARRAY OF CHAR);
(*
 converts a string to capital letters using CAP. Is faster then Caps,
 but german characters are not converted
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str[i] # 0X DO str[i] := CAP(str[i]); INC(i) END(*WHILE*);
 END CAPs;


PROCEDURE Merge* (str1,str2 : ARRAY OF CHAR; VAR str3 : ARRAY OF CHAR);
(*
 merges the string str1 and str2 and copies them into str3
 *)
 BEGIN
  COPY(str1,str3); Append(str2,str3);
 END Merge;


PROCEDURE Delete* (bpos,epos : INTEGER; VAR str : ARRAY OF CHAR);
(*
 deletes characters from bpos (incl.) to epos (excl.) in str by copying
 the rest down to bpos
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := Length(str);
  IF (bpos <= epos) AND (epos <= i) THEN
    REPEAT
      str[bpos] := str[epos]; INC(bpos); INC(epos);
    UNTIL epos >= i;
    str[bpos] := 0X;
  END(*IF*);
 END Delete;


PROCEDURE Excerpt* (bpos,epos : INTEGER; VAR str1,str2 : ARRAY OF CHAR);
(*
 excerpts characters from bpos (incl.) to epos (excl.) in str1 and copies
 it into str2
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE (i < LEN(str2)-1) AND (str1[bpos] # 0X) AND (bpos < epos) DO
    str2[i] := str1[bpos]; INC(i); INC(bpos);
  END(*WHILE*);
  str2[i] := 0X;
 END Excerpt;


PROCEDURE ComparePos(VAR str1,str2 : ARRAY OF CHAR; pos : INTEGER) : BOOLEAN;
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str1[i] = str2[pos] DO
    INC(i); INC(pos);
    IF str1[i] = 0X THEN RETURN TRUE END(*IF*);
  END(*WHILE*);
  RETURN FALSE
 END ComparePos;


PROCEDURE FPos* (str1 : ARRAY OF CHAR; VAR str2 : ARRAY OF CHAR) : INTEGER;
(*
 returns the position of the first appearence of string str1 in str2.
 Returns -1 if not found
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE NOT ComparePos(str1,str2,i) DO
    INC(i);
    IF str2[i] = 0X THEN RETURN -1 END(*IF*);
  END(*WHILE*);
  RETURN i
 END FPos;


PROCEDURE FPosC* (c : CHAR; VAR str : ARRAY OF CHAR) : INTEGER;
(*
 returns the position of the first appearence of character c in str.
 Returns -1 if not found
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str[i] # c DO
    INC(i);
    IF str[i] = 0X THEN RETURN -1 END(*IF*);
  END(*WHILE*);
  RETURN i
 END FPosC;


PROCEDURE LPos* (str1 : ARRAY OF CHAR; VAR str2 : ARRAY OF CHAR) : INTEGER;
(*
 returns the position of the last appearence of string str1 in str2.
 Returns -1 if not found
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := Length(str2)-1;
  WHILE (i >= 0) AND NOT ComparePos(str1,str2,i) DO DEC(i) END(*WHILE*);
  RETURN i
 END LPos;


PROCEDURE LPosC* (c : CHAR; VAR str : ARRAY OF CHAR) : INTEGER;
(*
 returns the position of the last appearence of character c in str.
 Returns -1 if not found
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := Length(str)-1;
  WHILE (i >= 0) AND (str[i] # c) DO DEC(i) END(*WHILE*);
  RETURN i
 END LPosC;


PROCEDURE NPos* (bpos : INTEGER; str1 : ARRAY OF CHAR;
                 VAR str2 : ARRAY OF CHAR) : INTEGER;
(*
 returns the position of the next appearence of string str1 in str2.
 Search is started at bpos and continued to the end of str2. Returns -1
 if not found
 *)
 BEGIN
  WHILE NOT ComparePos(str1,str2,bpos) DO
    INC(bpos);
    IF str2[bpos] = 0X THEN RETURN -1 END(*IF*);
  END(*WHILE*);
  RETURN bpos
 END NPos;


PROCEDURE NPosC* (bpos : INTEGER; c : CHAR; VAR str : ARRAY OF CHAR)
                  : INTEGER;
(*
 returns the position of the next appearence of character c in str.
 Search is started at bpos and continued to the end of str. Returns -1
 if not found
 *)
 BEGIN
  WHILE str[bpos] # c DO
    INC(bpos);
    IF str[bpos] = 0X THEN RETURN -1 END(*IF*);
  END(*WHILE*);
  RETURN bpos
 END NPosC;


PROCEDURE Write2(VAR str1 : ARRAY OF CHAR; pos : INTEGER;
                 VAR str2 : ARRAY OF CHAR) : INTEGER;
  VAR
    i : INTEGER;
    e : BOOLEAN;
 BEGIN
  i := 0; e := FALSE;
  WHILE (str1[i] # 0X) & (pos < LEN(str2)-1) DO
    IF str2[pos] = 0X THEN e := TRUE END(*IF*);
    str2[pos] := str1[i]; INC(pos); INC(i);
  END(*WHILE*);
  IF e OR (pos >= LEN(str2)-1) THEN RETURN pos ELSE RETURN -1 END(*IF*);
 END Write2;


PROCEDURE Insert* (str1 : ARRAY OF CHAR; pos : INTEGER;
                   VAR str2 : ARRAY OF CHAR);
(*
 inserts str1 at pos in str2. str2 is copied towards the end to make
 space for str1
 *)
  VAR
    i,j : INTEGER;
 BEGIN
  i := Length(str2);
  j := i + Length(str1);
  WHILE i >= pos DO
    IF j < LEN(str2) THEN
      IF j = LEN(str2) - 1 THEN
        str2[j] := 0X
      ELSE
        str2[j] := str2[i];
      END;
    END;
    DEC( i); DEC( j);
  END;
  i := Write2(str1,pos,str2);
 END Insert;


PROCEDURE InsertC* (c : CHAR; pos : INTEGER; VAR str : ARRAY OF CHAR);
(*
 inserts character c at pos in str. str is copied towards the end to make
 space for c
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := Length(str);
  WHILE i >= pos DO
    IF i = LEN(str) - 1 THEN
      str[i] := 0X
    ELSE
      str[i+1] := str[i];
    END;
    DEC(i);
  END(*WHILE*);
  str[pos] := c;
 END InsertC;


PROCEDURE Write* (str1 : ARRAY OF CHAR; pos : INTEGER;
                  VAR str2 : ARRAY OF CHAR);
(*
 overwrites str2 at pos with str1. If a 0X is overwritten, it will be
 added at the end
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := Write2(str1,pos,str2);
  IF i # -1 THEN str2[i] := 0X END(*IF*);
 END Write;


PROCEDURE Adjust* (adj,len : INTEGER; fill : CHAR; VAR str : ARRAY OF CHAR);
(*
 formats a string. It is extended to length len filling in characters
 fill. adj determines wether str starts at the beginning (LEFT), center
 (CENTER) or at the end (RIGHT).
 *)
  VAR
    i,j : INTEGER;
    s : ARRAY 256 OF CHAR;
 BEGIN
  i := Length(str);
  IF (adj < noadj) AND (i < len) AND (len <= LEN(str)) OR
     (adj >= noadj) AND (len+i <= LEN(str)) THEN
    CASE adj OF
      left:
        WHILE (i < len) & (i < LEN(str) - 1) DO
          str[i] := fill; INC(i)
        END;
        str[i] := 0X
    | right:
        j := 0; DEC(len,i);
        WHILE j <= len DO s[j] := fill; INC(j) END(*FOR*);
        s[len] := 0X; Insert(s,0,str);
    | center:
        i := (len - i) DIV 2 + i;
        Adjust(right,i,fill,str); Adjust(left,len,fill,str);
    | leftadd:
        i := 0;
        WHILE i < len DO s[i] := fill; INC(i) END;
        s[i] := 0X; Insert(s,0,str);
    | rightadd:
        i := 0;
        WHILE i < len DO s[i] := fill; INC(i) END;
        s[i] := 0X; Append(s,str);
    | noadj:
    END;
  END(*IF*);
 END Adjust;


END Strings.
