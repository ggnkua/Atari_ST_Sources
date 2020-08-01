MODULE IO;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |20.3.92  |started
S. Junker  |3.5.93   |compatibility with complex IO
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, NStr:=NumStr, Str:=Strings, GEMDOS, BIOS;

CONST
  left* = 0; right* = 1; center* = 2; noadj* = 3; leftadd* = 4; rightadd* = 5;
  rshift = 0; lshift = 1;

VAR
  Buffer : ARRAY 256 OF CHAR; 
  BufOn,PrevBufOn,Wrap,PrevWrapMode : BOOLEAN; 
  BufPos,PrevPos : INTEGER;


(* ---------------------------- output ----------------------------------*)

PROCEDURE OutputBuffer*;
 BEGIN
  IF BufOn AND (Buffer[0] # 0X) THEN 
    GEMDOS.Cconws(S.ADR(Buffer)); Buffer[0] := 0X; BufPos := 0 
  END;
 END OutputBuffer;
 
PROCEDURE BufferOn*;
 BEGIN
  PrevBufOn := BufOn; BufOn := TRUE;
 END BufferOn;
 
PROCEDURE BufferOff*;
 BEGIN
  PrevBufOn := BufOn; OutputBuffer; BufOn := FALSE;
 END BufferOff;
 
PROCEDURE PrevOutMode*;
 BEGIN
  IF BufOn AND NOT PrevBufOn THEN OutputBuffer END;
  BufOn := PrevBufOn;
 END PrevOutMode;
 
PROCEDURE WriteChar*(c : CHAR);
 BEGIN
  IF BufOn THEN
    IF Buffer[BufPos] = 0X THEN Buffer[BufPos+1] := 0X END;
    Buffer[BufPos] := c; INC(BufPos);
  ELSE GEMDOS.Cconout(ORD(c));
  END;
 END WriteChar;
 
PROCEDURE WriteString*(Output : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  IF BufOn THEN i := 0;
    WHILE Output[i] # 0X DO WriteChar(Output[i]); INC(i) END;
  ELSE GEMDOS.Cconws(S.ADR(Output));
  END;
 END WriteString;

PROCEDURE ClearToEOL*;
 BEGIN
  OutputBuffer; WriteChar(1BX); WriteChar("K");
 END ClearToEOL;
 
PROCEDURE WriteLn*;
 BEGIN
  ClearToEOL; GEMDOS.Cconout(0DH); GEMDOS.Cconout(0AH);
 END WriteLn;
 
PROCEDURE Return*;
 BEGIN
  OutputBuffer; GEMDOS.Cconout(0DH); GEMDOS.Cconout(0AH);
 END Return;
 
PROCEDURE WriteInt*(Value : LONGINT; Base,Adj,Len : INTEGER; Fill : CHAR);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NStr.LIntTo(Value,Base,s); Str.Adjust(Adj,Len,Fill,s); WriteString(s);
 END WriteInt;
 
PROCEDURE WriteReal*(Value : REAL; n,Adj,Len : INTEGER; Fill : CHAR);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NStr.RealTo(Value,n,s); Str.Adjust(Adj,Len,Fill,s); WriteString(s);
 END WriteReal;
 
(* ---------------------------- cursor ----------------------------------*)

PROCEDURE CursorOn*;
 BEGIN
  WriteChar(1BX); WriteChar("e");
 END CursorOn;
 
PROCEDURE CursorOff*;
 BEGIN
  WriteChar(1BX); WriteChar("f");
 END CursorOff;
 
PROCEDURE SetCursor*(Row,Col : INTEGER);
 BEGIN
  OutputBuffer;
  GEMDOS.Cconout(1BH); GEMDOS.Cconout(59H); 
  GEMDOS.Cconout(Row+20H); GEMDOS.Cconout(Col+20H);
 END SetCursor;
 
PROCEDURE SetBufPos*(Pos : INTEGER);
 BEGIN
  PrevPos := BufPos; BufPos := Pos;
 END SetBufPos;
 
PROCEDURE GetBufPos*() : INTEGER;
 BEGIN
  RETURN BufPos
 END GetBufPos;
 
PROCEDURE PrevBufPos*;
 BEGIN
  BufPos := PrevPos;
 END PrevBufPos;
 
PROCEDURE WrapOn*;
 BEGIN
  PrevWrapMode := Wrap; Wrap := TRUE;
  GEMDOS.Cconout(1BH); GEMDOS.Cconout(76H); 
 END WrapOn;
 
PROCEDURE WrapOff*;
 BEGIN
  PrevWrapMode := Wrap; Wrap := FALSE;
  GEMDOS.Cconout(1BH); GEMDOS.Cconout(77H); 
 END WrapOff;
 
PROCEDURE PrevWrap*;
 BEGIN
  IF PrevWrapMode THEN WrapOn ELSE WrapOff END;
 END PrevWrap;
 
 
(* ---------------------------- input -----------------------------------*)

PROCEDURE KeyPressed*() : BOOLEAN;
 BEGIN
  RETURN GEMDOS.Cconis() # 0
 END KeyPressed;
 
PROCEDURE ReadChar*() : CHAR;
 BEGIN
  OutputBuffer; RETURN CHR(GEMDOS.Cconin())
 END ReadChar;

PROCEDURE ReadKey*(VAR Shift : SET; VAR Scan : INTEGER; VAR Ascii : CHAR);
  VAR Key : LONGINT;
 BEGIN
  OutputBuffer;
  Key := GEMDOS.Crawcin(); Scan := SHORT(Key DIV 10000H); Ascii := CHR(Key);
  Shift := S.VAL(SET,BIOS.Kbshift(-1));
  IF rshift IN Shift THEN INCL(Shift,lshift) END;
  Shift := Shift - {0,4..31};
 END ReadKey;

PROCEDURE ReadString*(VAR Input : ARRAY OF CHAR);
  VAR s1 : ARRAY 256 OF CHAR;
      Len : SHORTINT;
      MaxLen : SHORTINT;
 BEGIN
  OutputBuffer;
  MaxLen := SHORT(LEN(Input) - 1);
  GEMDOS.Cconrs(S.ADR(MaxLen));
  COPY(s1,Input); Input[Len] := 0X;
 END ReadString;

PROCEDURE ReadInt*(Base : INTEGER; VAR Value : LONGINT) : BOOLEAN;
  VAR s : ARRAY 40 OF CHAR;
 BEGIN
  ReadString(s); Value := NStr.ToLInt(Base,s); RETURN NStr.OK;
 END ReadInt;
 
PROCEDURE ReadReal*(VAR Value : REAL) : BOOLEAN;
  VAR s : ARRAY 40 OF CHAR;
 BEGIN
  ReadString(s); Value := NStr.ToReal(s); RETURN NStr.OK;
 END ReadReal;

(* ---------------------------- edit procedures -------------------------*)

PROCEDURE ClearHome*;
 BEGIN
  WriteChar(1BX); WriteChar("E"); Buffer[0] := 0X; BufPos := 0;
 END ClearHome;

PROCEDURE ClearToEOS*;
  VAR CurAd : LONGINT;
 BEGIN
  OutputBuffer; WriteChar(1BX); WriteChar("J");
 END ClearToEOS;

PROCEDURE CursorDown*;
 BEGIN
  OutputBuffer; GEMDOS.Cconout(1BH); GEMDOS.Cconout(42H);
 END CursorDown;
  
PROCEDURE CursorUp*;
 BEGIN
  OutputBuffer; GEMDOS.Cconout(1BH); GEMDOS.Cconout(41H);
 END CursorUp;

PROCEDURE CursorLeft*;
 BEGIN
  OutputBuffer; GEMDOS.Cconout(1BH); GEMDOS.Cconout(44H);
 END CursorLeft;
  
PROCEDURE CursorRight*;
 BEGIN
  OutputBuffer; GEMDOS.Cconout(1BH); GEMDOS.Cconout(43H);
 END CursorRight;

END IO.
