MODULE ErrorWin;


IMPORT
  S:=SYSTEM, TextViewer, Wind, NumStr, Str:=Strings, Db:=DbBase,
  Selected, Halt;


CONST
  TYPERR1   = 0; TYPERR2   = 1; NORET    = 2;  CASERR   = 3;
  REALERR   = 4; MEMERR    = 5; MEMDST   = 6;  INTER    = 7;
  BUSERR   = 10; ADDRERR  = 11; ILLEGAL  = 12; DIVZERO  = 13;
  INDEXERR = 14; OVERFLOW = 15; PRIVILEG = 16; TRACERR  = 17;


TYPE
  Viewer*   = POINTER TO ViewDesc;
  ViewDesc* = RECORD(TextViewer.ViewDesc)
              END(*RECORD*);


VAR
  x*,y*,w*,h* : INTEGER;
  text : ARRAY 400 OF CHAR; textx : INTEGER;


PROCEDURE WriteString(str : ARRAY OF CHAR);
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str[i] # 0X DO
    text[textx] := str[i]; INC(i); INC(textx)
  END;
 END WriteString;


PROCEDURE WriteChar(c : CHAR);
 BEGIN
  text[textx] := c; INC(textx)
 END WriteChar;


PROCEDURE WriteLn;
 BEGIN
  text[textx] := 0DX; INC(textx);
  text[textx] := 0AX; INC(textx);
 END WriteLn;


PROCEDURE WriteInt(Value : LONGINT);
  VAR s : ARRAY 10 OF CHAR;
 BEGIN
  NumStr.LIntTo(Value,10,s); WriteString(s);
 END WriteInt;


PROCEDURE WriteFInt(Value : LONGINT; Base,Adj,Len : INTEGER; Fill : CHAR);
  VAR s : ARRAY 10 OF CHAR;
 BEGIN
  NumStr.LCardTo(Value,Base,s); Str.Adjust(Adj,Len,Fill,s); WriteString(s);
 END WriteFInt;


PROCEDURE WriteReg(regChar : CHAR; regNo : INTEGER; value : LONGINT);
 BEGIN
  WriteChar(regChar);
  WriteChar( CHR(regNo + 30H) );
  WriteChar("=");
  WriteFInt(value, 16, 1, 8, "0");
  WriteChar(" ");
 END WriteReg;


PROCEDURE ShowException*() : Viewer;
  VAR v : Viewer;
      m : TextViewer.Model;
      mod, proc : ARRAY 24 OF CHAR;
      modOff, procOff : LONGINT;
      i : INTEGER;
 BEGIN
  textx := 0;
  CASE Halt.excType OF
    TYPERR1,TYPERR2: WriteString("Type check failed") |
    NORET : WriteString("Return statement missing") |
    CASERR : WriteString("Case selection failed") |
    REALERR : WriteString("Arithmetic error") |
    MEMERR : WriteString("Out of memory") |
    MEMDST : WriteString("Memory destroyed") |
    INTER: WriteString("Program interrupted") |
    BUSERR : WriteString("Bus error") |
    ADDRERR : WriteString("Address error") |
    ILLEGAL : WriteString("Illegal opcode") |
    DIVZERO : WriteString("Division by zero") |
    INDEXERR : WriteString("Index out of range") |
    OVERFLOW : WriteString("Overflow on TRAPV") |
    PRIVILEG : WriteString("Privilege violation") |
    TRACERR : WriteString("Trace abortion") |
    ELSE
      WriteString("Error #");
      WriteInt(Halt.excType);
  END;
  WriteLn;
  WriteString("Address: ");
  WriteFInt( Halt.excAddress, 16, 5, 1, "H");
  WriteLn;
  Db.GetModProc(Halt.excAddress, mod, proc, modOff, procOff);
  WriteString("Module: "); WriteString(mod);
  WriteLn;
  WriteString("Procedure: ");
  WriteString(proc);
  WriteString(" + "); WriteInt(procOff);
  WriteLn;
  FOR i := 0 TO 7 DO
    WriteReg("D", i, Halt.registers[i]);
    IF i = 3 THEN WriteLn END;
  END;
  WriteLn;
  FOR i := 8 TO 15 DO
    WriteReg("A", i-8, Halt.registers[i]);
    IF i = 11 THEN WriteLn END;
  END;
  WriteChar(0X);
  NEW(m); m.Initialize;
  m.SetText(S.ADR(text), textx);
  NEW(v); v.Initialize;
  v.SetModel(m);
  v.SetPos(x, y); v.SetSize(w, h);
  v.SetTitle("Art der Unterbrechung");
  v.Open;
  RETURN v;
 END ShowException;


PROCEDURE HexChar(c : CHAR) : BOOLEAN;
 BEGIN
  RETURN (c >= "0") AND (c <= "9") OR (c >= "A") AND (c <= "F");
 END HexChar;


PROCEDURE(v : Viewer) TextSelected(lineAd, selAd : S.PTR);
  VAR
    c : CHAR;
    s : ARRAY 10 OF CHAR;
    i : INTEGER;
 BEGIN
  S.GET(selAd, c);
  IF HexChar(c) THEN
    WHILE (selAd > lineAd) AND HexChar(c) DO
      DEC(selAd); S.GET(selAd, c);
    END;
    IF NOT HexChar(c) THEN INC(selAd) END;
    i := 0;
    S.GET(selAd, c);
    REPEAT
      s[i] := c; INC(i);
      INC(selAd); S.GET(selAd, c);
    UNTIL NOT HexChar(c);
    s[i] := 0X;
    Selected.addr := NumStr.ToLInt(16, s);
    Selected.disMenu.Show;
  END;
 END TextSelected;


BEGIN
  x := 0; y := 40; w := 50*8; h := 4*16;
END ErrorWin.