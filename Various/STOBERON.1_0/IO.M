MODULE IO;

(* Standard I/O routines *)

IMPORT TOS;

VAR err*: SHORTINT; (* =  0 => OK               *)
                    (* = -1 => String too long  *)
                    (* = -2 => Number too large *)
    echo*: BOOLEAN;
    
PROCEDURE Write*(ch: CHAR);
BEGIN TOS.BConOut(2, ch)
END Write;

PROCEDURE WriteString*(str: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE str[i] # 0X DO
    TOS.BConOut(2, str[i]); INC(i)
  END
END WriteString;

PROCEDURE WriteInt*(val: LONGINT; len: INTEGER);
  VAR i: INTEGER; signed: BOOLEAN; str: ARRAY 16 OF CHAR;
BEGIN
  i := 0; signed := FALSE;
  IF val < 0 THEN val := -val; DEC(len); signed := TRUE END;
  WHILE val # 0 DO
    str[i]:=CHR(SHORT(val MOD 10 + 30H)); val := val DIV 10; INC(i)
  END;
  IF i = 0 THEN str[i] := "0"; INC(i) END;
  WHILE len > i DO TOS.BConOut(2, " "); DEC(len) END;
  IF signed THEN TOS.BConOut(2, "-") END;
  WHILE i > 0 DO DEC(i); TOS.BConOut(2, str[i]) END
END WriteInt;

PROCEDURE WriteLn*;
BEGIN TOS.BConOut(2, 0DX); TOS.BConOut(2, 0AX)
END WriteLn;

(* ----------------------------------------------------------------------- *)

PROCEDURE Read*(VAR ch: CHAR);
BEGIN
  ch := CHR(SHORT(TOS.BConIn(2) MOD 256));
  IF echo THEN Write(ch) END
END Read;

PROCEDURE ReadString*(VAR str: ARRAY OF CHAR);
  VAR i: INTEGER; ch: CHAR;
BEGIN
  err := 0; i := 0;
  LOOP
    Read(ch);
    IF ch = 0DX THEN EXIT
    ELSIF (ch = 08X) & (i > 0) THEN
      DEC(i)
    ELSE
      str[i] := ch; INC(i);
      IF i = LEN(str) THEN (* string too long *) err := -1; DEC(i); EXIT END
    END
  END;
  str[i]:=0X
END ReadString;

PROCEDURE ReadInt*(VAR val: INTEGER);
  VAR str: ARRAY 30 OF CHAR; val1: LONGINT; signed: BOOLEAN; i: INTEGER;
BEGIN
  err := 0; val1 := 0;
  ReadString(str);
  i := 0;
  WHILE str[i] = " " DO INC(i) END;
  IF str[i] = "-" THEN signed := TRUE; INC(i) ELSE signed := FALSE END;
  WHILE (str[i] >= "0") & (str[i] <= "9") & (val1 <= 32768) DO
    val1 := val1 * 10 + (ORD(str[i]) - 30H); INC(i)
  END;
  IF (val1 > 32768) OR signed & (val1 > 32767) THEN
    (* overflow *)
    val := 0; err := -2
  ELSE
    val := SHORT(val1);
    IF signed THEN val := -val END
  END
END ReadInt;

PROCEDURE ReadLn*;
  VAR ch: CHAR;
BEGIN
  REPEAT Read(ch) UNTIL ch = 0DX
END ReadLn;

BEGIN echo := TRUE
END IO.

