MODULE IOForm;

IMPORT S:=SYSTEM,IO;

PROCEDURE Do* (Tree : LONGINT; Startob : INTEGER) : INTEGER;
 BEGIN
 END Do;

PROCEDURE Dial* (Type,Sx,Sy,Sw,Sh,Bx,By,Bw,Bh : INTEGER);
 BEGIN
 END Dial;

PROCEDURE FindBracket(VAR Text : ARRAY OF CHAR; No : INTEGER) : INTEGER;
  VAR Pos : INTEGER;
 BEGIN
  Pos := 0;
  REPEAT
    WHILE Text[Pos] # "[" DO INC(Pos) END;
    DEC(No); INC(Pos);
  UNTIL No = 0;
  RETURN Pos
 END FindBracket;

PROCEDURE GetIcon(VAR Text : ARRAY OF CHAR) : INTEGER;
  VAR i : INTEGER;
 BEGIN
  i := FindBracket(Text,1); RETURN ORD(Text[i]) - 30H
 END GetIcon;

PROCEDURE WriteAlert(VAR Text : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  i := FindBracket(Text,2);
  REPEAT
    IF Text[i] = "|" THEN IO.WriteLn; IO.WriteString("      ");
    ELSE IO.WriteChar(Text[i]);
    END;
    INC(i);
  UNTIL Text[i] = "]";
  IO.WriteLn;
 END WriteAlert;

PROCEDURE NumBut(VAR Text : ARRAY OF CHAR) : INTEGER;
  VAR i,Num : INTEGER;
 BEGIN
  i := FindBracket(Text,3); Num := 1;
  REPEAT
    IF Text[i] = "|" THEN INC(Num) END;
    INC(i);
  UNTIL Text[i] = "]";
  RETURN Num
 END NumBut;

PROCEDURE WriteButtons(VAR Text,Buts : ARRAY OF CHAR; defbut : INTEGER);
  VAR i,b : INTEGER;
 BEGIN
  i := 3;
  REPEAT DEC(i); Buts[i] := 0X UNTIL i = 0;
  i := FindBracket(Text,3); b := 0; IO.BufferOn;
  REPEAT
    IF b = defbut THEN IO.WriteChar("<") END;
    Buts[b] := CAP(Text[i]);
    IO.WriteChar("("); IO.WriteChar(Text[i]); IO.WriteChar(")");
    INC(i);
    WHILE (Text[i] # "|") AND (Text[i] # "]") DO
      IO.WriteChar(Text[i]); INC(i)
    END;
    IF b = defbut THEN IO.WriteChar(">") END;
    INC(b);
    IF Text[i] = "|" THEN IO.WriteChar(","); INC(i) END;
  UNTIL Text[i] = "]";
  IO.WriteString(" ? "); IO.PrevOutMode;
 END WriteButtons;

PROCEDURE Alert* (Defbut : INTEGER; Text : ARRAY OF CHAR) : INTEGER;
  VAR Icon,i : INTEGER; c : CHAR;
      Buts : ARRAY 3 OF CHAR;
 BEGIN
  IO.WriteLn;
  Icon := GetIcon(Text);
  CASE Icon OF
    1 : IO.WriteString("(!)   ") |
    2 : IO.WriteString("(?)   ") |
    3 : IO.WriteString("Stop: ")
    ELSE
  END;
  WriteAlert(Text);
  WriteButtons(Text,Buts,Defbut-1);
  LOOP c := CAP( IO.ReadChar() );
    IF (c = 0DX) AND (Defbut > 0) THEN
      IO.WriteLn;
      RETURN Defbut
    END;
    IF c # 0X THEN i := 0;
      REPEAT
        IF c = Buts[i] THEN IO.WriteLn; RETURN i + 1 END;
        INC(i)
      UNTIL i = 3;
    END;
  END;
 END Alert;

END IOForm.
