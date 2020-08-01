MODULE ChatIO; (* SJ 7.11.93 *)


IMPORT
  S:=SYSTEM, NStr:=NumStr, Str:=Strings, Evnt, Task, IO, Redirect;


CONST
  left* = 0; right* = 1; center* = 2; noadj* = 3; leftadd* = 4; rightadd* = 5;
  rshift = 0; lshift = 1;


CONST

(* LC_WRCHAR: Diese Nachricht schickt der Lader an Chatwin, um ein Zeichen
 * auf der Console auszugeben.
 *)
LCWRCHAR	= 6503H;
(*
 * Word[3] = Char
 *)

(* LC_WRSTR: Wird an Chatwin geschickt, um einen 0-terminierten String
 * auf dem Consolefenster auszugeben.
 *)
LCWRSTR		= 6504H;
(*
 * Word[1] = Oberes Wort des Zeigers auf den String, Null-terminiert
 * Word[2] = Unteres Wort des Zeigers auf den String
 *)

(* LC_OUTBUF: Weist Chatwin an, den Zeichenpuffer auf dem Consolerfenster
 * auszugeben.
 *)
LCOUTBUF	= 6505H;
(*
 *)


TYPE
  msg    = RECORD
             Type : INTEGER;
             Ptr  : S.PTR;
             Char : INTEGER;
           END;
  msgptr = POINTER TO msg;
  cproc* = PROCEDURE (Msg : msgptr);


VAR
  SendMsg* : cproc;


VAR
  Buffer : ARRAY 256 OF CHAR;
  BufOn,PrevBufOn,Wrap,PrevWrapMode : BOOLEAN;
  BufPos,PrevPos : INTEGER;

  KeyRead : BOOLEAN;
  ascii : CHAR; shift : SET; scan : INTEGER;


(* ------------------------ communication with Chatwin ------------------*)

PROCEDURE WrChar(c : CHAR);
  VAR Msg : msg;
 BEGIN
  Msg.Type := LCWRCHAR; Msg.Char := ORD( c); SendMsg( S.ADR( Msg));
 END WrChar;


PROCEDURE WrStr(VAR Str : ARRAY OF CHAR);
  VAR Msg : msg;
      i : INTEGER;
 BEGIN
  Msg.Type := LCWRSTR;
  Msg.Ptr := S.ADR( Str); SendMsg( S.ADR( Msg));
  Msg.Type := LCOUTBUF; SendMsg( S.ADR( Msg));
 END WrStr;


PROCEDURE OutBuf;
  VAR Msg : msg;
 BEGIN
  Msg.Type := LCOUTBUF; SendMsg( S.ADR( Msg));
 END OutBuf;

(* ---------------------------- output ----------------------------------*)

PROCEDURE OutputBuffer*;
 BEGIN
  IF BufOn AND (Buffer[0] # 0X) THEN
    WrStr( Buffer); Buffer[0] := 0X; BufPos := 0
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
  ELSE WrChar(c); OutBuf;
  END;
 END WriteChar;

PROCEDURE WriteString*(Output : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  IF BufOn THEN i := 0;
    WHILE Output[i] # 0X DO WriteChar(Output[i]); INC(i) END;
  ELSE WrStr(Output);
  END;
 END WriteString;

PROCEDURE^ KeyPressed*() : BOOLEAN;

PROCEDURE WriteLn*;
  VAR d : BOOLEAN;
 BEGIN
  OutputBuffer; WrChar(0DX); WrChar(0AX); OutBuf;
  d := KeyPressed(); (* for stop or exit *)
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
  OutputBuffer;
  WrChar(1BX); WrChar(59X);
  WrChar( CHR(Row+20H) ); WrChar( CHR(Col+20H) ); OutBuf;
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
  WrChar(1BX); WrChar(76X); OutBuf;
 END WrapOn;

PROCEDURE WrapOff*;
 BEGIN
  PrevWrapMode := Wrap; Wrap := FALSE;
  WrChar(1BX); WrChar(77X); OutBuf;
 END WrapOff;

PROCEDURE PrevWrap*;
 BEGIN
  IF PrevWrapMode THEN WrapOn ELSE WrapOff END;
 END PrevWrap;


(* ---------------------------- edit procedures -------------------------*)

PROCEDURE ClearHome*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar("E"); OutBuf;
 END ClearHome;

PROCEDURE ClearToEOL*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar("K"); OutBuf;
 END ClearToEOL;

PROCEDURE ClearToEOS*;
  VAR CurAd : LONGINT;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar("J"); OutBuf;
 END ClearToEOS;

PROCEDURE CursorDown*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar(42X); OutBuf;
 END CursorDown;

PROCEDURE CursorUp*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar(41X); OutBuf;
 END CursorUp;

PROCEDURE CursorLeft*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar(44X); OutBuf;
 END CursorLeft;

PROCEDURE CursorRight*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar(43X); OutBuf;
 END CursorRight;

PROCEDURE SaveCursor*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar("j"); OutBuf;
 END SaveCursor;

PROCEDURE RestoreCursor*;
 BEGIN
  OutputBuffer; WrChar(1BX); WrChar("k"); OutBuf;
 END RestoreCursor;

(* ---------------------------- input -----------------------------------*)

PROCEDURE TestExit;
  VAR d : INTEGER; s : SET; msgBuf : Evnt.msgbuf;
 BEGIN
  IF (shift-{Evnt.CAPSLOCK} = {Evnt.CONTROL}) THEN
    IF scan = 2EH THEN Task.Exit(0) END; (* ^C *)
    IF scan = 1FH THEN (* ^S *)
      REPEAT
        s := Evnt.Multi({Evnt.KEYBOARD}, 1, {}, {}, 0,0,0,0,0, 0,0,0,0,0,
                 msgBuf, 0, d,d, s, shift, scan, ascii, d);
      UNTIL (shift-{Evnt.CAPSLOCK} = {Evnt.CONTROL})
            AND ((scan = 10H) OR (scan = 2EH));
      IF scan = 2EH THEN Task.Exit(0) END; (* ^C *)
      KeyRead := FALSE;
    END;
  END;
 END TestExit;

PROCEDURE KeyPressed*() : BOOLEAN;
  VAR d : INTEGER; s : SET; msgBuf : Evnt.msgbuf;
 BEGIN
  KeyRead := Evnt.KEYBOARD IN
     Evnt.Multi({Evnt.TIME, Evnt.KEYBOARD}, 1, {}, {}, 0,0,0,0,0, 0,0,0,0,0,
                 msgBuf, 0, d,d, s, shift, scan, ascii, d);
  IF KeyRead THEN TestExit END;
  RETURN KeyRead
 END KeyPressed;

PROCEDURE ReadChar*() : CHAR;
  VAR d : INTEGER; s : SET; msgBuf : Evnt.msgbuf;
 BEGIN
  OutputBuffer;
  REPEAT
    IF NOT KeyRead THEN
      s := Evnt.Multi({Evnt.KEYBOARD}, 1, {}, {}, 0,0,0,0,0, 0,0,0,0,0,
                 msgBuf, 0, d,d, s, shift, scan, ascii, d);
      KeyRead := TRUE;
    END;
    TestExit;
  UNTIL KeyRead;
  KeyRead := FALSE;
  IF ascii >= " " THEN WriteChar(ascii) END;
  RETURN ascii;
 END ReadChar;

PROCEDURE ReadKey*(VAR Shift : SET; VAR Scan : INTEGER; VAR Ascii : CHAR);
  VAR d : INTEGER; s : SET; msgBuf : Evnt.msgbuf;
 BEGIN
  OutputBuffer;
  REPEAT
    IF NOT KeyRead THEN
      s := Evnt.Multi({Evnt.KEYBOARD}, 1, {}, {}, 0,0,0,0,0, 0,0,0,0,0,
                 msgBuf, 0, d,d, s, shift, scan, ascii, d);
      KeyRead := TRUE;
    END;
    TestExit;
  UNTIL KeyRead;
  KeyRead := FALSE;
  Scan := scan; Ascii := ascii; Shift := shift;
  IF rshift IN Shift THEN INCL(Shift,lshift) END;
  Shift := Shift - {rshift,4..31};
 END ReadKey;

PROCEDURE Edit(VAR sh : SET; VAR sc : INTEGER);
  VAR shift : SET; scan : INTEGER; ascii : CHAR;
 BEGIN
  LOOP ReadKey(shift,scan,ascii);
    IF (ascii >= " ") THEN WriteChar(ascii); OutputBuffer;
    ELSE
      IF scan = 72H THEN scan := 1CH END;
      EXIT
    END
  END;
  sh := shift; sc := scan;
 END Edit;

PROCEDURE ReadString*(VAR Input : ARRAY OF CHAR);
  VAR shift : SET; scan : INTEGER; ascii : CHAR;
      line : ARRAY 256 OF CHAR; pos : INTEGER;
      p : Str.ptr;
 BEGIN
  pos := 0; line[0] := 0X;
  LOOP ReadKey(shift,scan,ascii);
    IF (ascii >= " ") THEN WriteChar(ascii); OutputBuffer;
      IF line[pos] = 0X THEN line[pos+1] := 0X END;
      line[pos] := ascii; INC(pos);
    ELSIF (scan = 72H) OR (scan = 1CH) THEN EXIT
    ELSIF scan = 0EH THEN (* backspace *)
      Str.Delete( pos-1, pos, line); DEC(pos);
      CursorLeft; SaveCursor;
      p := S.ADR( line[pos]); WrStr( p^); WrChar(" ");
      RestoreCursor;
    ELSIF scan = 53H THEN (* delete *)
      Str.Delete( pos, pos+1, line); SaveCursor;
      p := S.ADR( line[pos]); WrStr( p^); WrChar(" ");
      RestoreCursor;
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
  BufOn := TRUE;
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
END ChatIO.
