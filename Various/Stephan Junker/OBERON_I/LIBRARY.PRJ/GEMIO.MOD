MODULE GEMIO; (* SJ 20.3.92 / 22.2.95 *)


IMPORT
  S:=SYSTEM, NStr:=NumStr, Str:=Strings, TermWin, Evnt, Task, IO,
  Redirect, GemApp;


CONST
  left* = 0; right* = 1; center* = 2; noadj* = 3; leftadd* = 4; rightadd* = 5;
  rshift = 0; lshift = 1;


TYPE
  Viewer = POINTER TO RECORD(TermWin.ViewDesc)
  END;


VAR
  viewer- : Viewer;

  Buffer : ARRAY 256 OF CHAR;
  BufOn,PrevBufOn,Wrap,PrevWrapMode : BOOLEAN;
  BufPos,PrevPos : INTEGER;
  KeyRead, waitingForKey : BOOLEAN;
  ascii : CHAR; shift : SET; scan : INTEGER;


(* ---------------------------- output ----------------------------------*)

PROCEDURE OutputBuffer*;
 BEGIN
  IF BufOn AND (Buffer[0] # 0X) THEN
    viewer.WriteString(Buffer); Buffer[0] := 0X; BufPos := 0
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
    IF BufPos = 255 THEN OutputBuffer END;
  ELSE viewer.WriteChar(c);
  END;
 END WriteChar;

PROCEDURE WriteString*(Output : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  IF BufOn THEN i := 0;
    WHILE Output[i] # 0X DO WriteChar(Output[i]); INC(i) END;
  ELSE viewer.WriteString(Output);
  END;
 END WriteString;

PROCEDURE^ KeyPressed*() : BOOLEAN;

PROCEDURE WriteLn*;
 BEGIN
  OutputBuffer; viewer.WriteLn;
 END WriteLn;

PROCEDURE WriteInt*(Value : LONGINT);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NStr.LIntTo(Value,10,s); WriteString(s);
 END WriteInt;

PROCEDURE WriteFInt*(Value : LONGINT; Base,Adj,Len : INTEGER; Fill : CHAR);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NStr.LIntTo(Value,Base,s); Str.Adjust(Adj,Len,Fill,s); WriteString(s);
 END WriteFInt;

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
  OutputBuffer; viewer.SetCursor(Col,Row);
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
 END WrapOn;

PROCEDURE WrapOff*;
 BEGIN
  PrevWrapMode := Wrap; Wrap := FALSE;
 END WrapOff;

PROCEDURE PrevWrap*;
 BEGIN
  IF PrevWrapMode THEN WrapOn ELSE WrapOff END;
 END PrevWrap;


(* ---------------------------- edit procedures -------------------------*)

PROCEDURE ClearHome*;
 BEGIN
  viewer.ClearHome;
  Buffer[0] := 0X; BufPos := 0;
 END ClearHome;

PROCEDURE ClearToEOL*;
 BEGIN
  OutputBuffer; viewer.ClearEOL;
 END ClearToEOL;

PROCEDURE ClearToEOS*;
  VAR CurAd : LONGINT;
 BEGIN
  OutputBuffer; viewer.ClearEOS;
 END ClearToEOS;

PROCEDURE CursorDown*;
 BEGIN
  OutputBuffer; viewer.SetCursor(viewer.curx, viewer.cury+1);
 END CursorDown;

PROCEDURE CursorUp*;
 BEGIN
  OutputBuffer; viewer.SetCursor(viewer.curx, viewer.cury-1);
 END CursorUp;

PROCEDURE CursorLeft*;
 BEGIN
  OutputBuffer; viewer.SetCursor(viewer.curx-1, viewer.cury);
 END CursorLeft;

PROCEDURE CursorRight*;
 BEGIN
  OutputBuffer; viewer.SetCursor(viewer.curx+1, viewer.cury);
 END CursorRight;

PROCEDURE SaveCursor*;
 BEGIN
  OutputBuffer; viewer.SaveCursor;
 END SaveCursor;

PROCEDURE RestoreCursor*;
 BEGIN
  OutputBuffer; viewer.RestoreCursor;
 END RestoreCursor;

(* ---------------------------- input -----------------------------------*)

PROCEDURE TestExit;
  VAR
    d : INTEGER;
    s : SET;
    msgBuf : Evnt.msgbuf;
 BEGIN
  IF KeyRead THEN
    IF (shift-{Evnt.CAPSLOCK} = {Evnt.CONTROL}) THEN
      IF scan = 2EH THEN Task.Exit(0) END; (* ^C *)
      IF scan = 1FH THEN (* ^S *)
        REPEAT
          waitingForKey := TRUE;
          GemApp.Run;
          waitingForKey := FALSE;
        UNTIL KeyRead & (shift = {Evnt.CONTROL}) & (scan = 10H);
        KeyRead := FALSE;
      END;
    END;
  END;
 END TestExit;


PROCEDURE KeyPressed*() : BOOLEAN;
  VAR d : INTEGER; s : SET; msgBuf : Evnt.msgbuf;
 BEGIN
  KeyRead := Evnt.KEYBOARD IN
     Evnt.Multi({Evnt.TIME, Evnt.KEYBOARD}, 1, {}, {}, 0,0,0,0,0, 0,0,0,0,0,
                 msgBuf, 0, d,d, s, shift, scan, ascii, d);
  TestExit;
  RETURN KeyRead
 END KeyPressed;


PROCEDURE (v : Viewer) HandleKeyEvent*(sh : SET;
                               sc : INTEGER; as : CHAR) : BOOLEAN;
 BEGIN
  IF waitingForKey THEN
    GemApp.exit := TRUE;
    shift := sh; scan := sc; ascii := as;
    KeyRead := TRUE;
    RETURN FALSE
  ELSE
    RETURN v.HandleKeyEvent^(sh,sc, as)
  END;
 END HandleKeyEvent;


PROCEDURE ReadKey*(VAR Shift : SET; VAR Scan : INTEGER; VAR Ascii : CHAR);
  VAR
    d : INTEGER;
    s : SET;
    msgBuf : Evnt.msgbuf;
 BEGIN
  viewer.CursorOn;
  OutputBuffer;
  REPEAT
    IF NOT KeyRead THEN
      waitingForKey := TRUE;
      GemApp.Run;
      waitingForKey := FALSE;
    END;
    TestExit;
  UNTIL KeyRead;
  KeyRead := FALSE;
  Scan := scan; Ascii := ascii; Shift := shift;
 END ReadKey;


PROCEDURE ReadChar*() : CHAR;
  VAR
    d : INTEGER;
    s : SET;
    char: CHAR;
 BEGIN
  ReadKey(s, d, char);
  IF char >= " " THEN WriteChar(char) END;
  RETURN char;
 END ReadChar;


PROCEDURE ReadString*(VAR Input : ARRAY OF CHAR);
  VAR shift : SET; scan : INTEGER; ascii : CHAR;
      line : ARRAY 256 OF CHAR; pos : INTEGER;
      p : Str.ptr;
 BEGIN
  pos := 0; line[0] := 0X;
  LOOP
    ReadKey(shift,scan,ascii);
    IF (ascii >= " ") THEN
      viewer.WriteChar(ascii);
      IF line[pos] = 0X THEN line[pos+1] := 0X END;
      line[pos] := ascii; INC(pos);
    ELSIF (scan = 72H) OR (scan = 1CH) THEN EXIT
    ELSIF scan = 0EH THEN (* backspace *)
      viewer.CursorOff;
      Str.Delete( pos-1, pos, line); DEC(pos);
      CursorLeft; SaveCursor;
      p := S.ADR( line[pos]); viewer.WriteString( p^);
      viewer.WriteChar(" ");
      RestoreCursor;
      viewer.CursorOn;
    ELSIF scan = 53H THEN (* delete *)
      viewer.CursorOff;
      Str.Delete( pos, pos+1, line); SaveCursor;
      p := S.ADR( line[pos]); viewer.WriteString( p^);
      viewer.WriteChar(" ");
      RestoreCursor;
      viewer.CursorOn;
    END
  END;
  COPY(line, Input);
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

BEGIN
  NEW(viewer); viewer.Initialize;
  Redirect( S.ADR( IO.OutputBuffer), S.ADR( OutputBuffer) );
  Redirect( S.ADR( IO.BufferOn), S.ADR( BufferOn) );
  Redirect( S.ADR( IO.BufferOff), S.ADR( BufferOff) );
  Redirect( S.ADR( IO.PrevOutMode), S.ADR( PrevOutMode) );
  Redirect( S.ADR( IO.WriteChar), S.ADR( WriteChar) );
  Redirect( S.ADR( IO.WriteString), S.ADR( WriteString) );
  Redirect( S.ADR( IO.KeyPressed), S.ADR( KeyPressed) );
  Redirect( S.ADR( IO.WriteLn), S.ADR( WriteLn) );
  Redirect( S.ADR( IO.WriteInt), S.ADR( WriteInt) );
  Redirect( S.ADR( IO.WriteFInt), S.ADR( WriteFInt) );
  Redirect( S.ADR( IO.WriteReal), S.ADR( WriteReal) );
  Redirect( S.ADR( IO.CursorOn), S.ADR( CursorOn) );
  Redirect( S.ADR( IO.CursorOff), S.ADR( CursorOff) );
  Redirect( S.ADR( IO.SetCursor), S.ADR( SetCursor) );
  Redirect( S.ADR( IO.SetBufPos), S.ADR( SetBufPos) );
  Redirect( S.ADR( IO.GetBufPos), S.ADR( GetBufPos) );
  Redirect( S.ADR( IO.PrevBufPos), S.ADR( PrevBufPos) );
  Redirect( S.ADR( IO.WrapOn), S.ADR( WrapOn) );
  Redirect( S.ADR( IO.WrapOff), S.ADR( WrapOff) );
  Redirect( S.ADR( IO.PrevWrap), S.ADR( PrevWrap) );
  Redirect( S.ADR( IO.ClearHome), S.ADR( ClearHome) );
  Redirect( S.ADR( IO.ClearToEOL), S.ADR( ClearToEOL) );
  Redirect( S.ADR( IO.ClearToEOS), S.ADR( ClearToEOS) );
  Redirect( S.ADR( IO.CursorDown), S.ADR( CursorDown) );
  Redirect( S.ADR( IO.CursorUp), S.ADR( CursorUp) );
  Redirect( S.ADR( IO.CursorLeft), S.ADR( CursorLeft) );
  Redirect( S.ADR( IO.CursorRight), S.ADR( CursorRight) );
  Redirect( S.ADR( IO.SaveCursor), S.ADR( SaveCursor) );
  Redirect( S.ADR( IO.RestoreCursor), S.ADR( RestoreCursor) );
  Redirect( S.ADR( IO.KeyPressed), S.ADR( KeyPressed) );
  Redirect( S.ADR( IO.ReadChar), S.ADR( ReadChar) );
  Redirect( S.ADR( IO.ReadKey), S.ADR( ReadKey) );
  Redirect( S.ADR( IO.ReadString), S.ADR( ReadString) );
  Redirect( S.ADR( IO.ReadInt), S.ADR( ReadInt) );
  Redirect( S.ADR( IO.ReadReal), S.ADR( ReadReal) );
END GEMIO.
