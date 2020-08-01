MODULE Convert;

(*
 Convert Oberon text files into plain ascii.
 *)


IMPORT
  S:=SYSTEM, Sys, IO, FB:=FileBuffer, Str:=Strings;


CONST
  linelen = 77;


PROCEDURE Dispose(f: FB.file);
  VAR
    adr: S.PTR;
 BEGIN
  S.GET( S.ADR( f.Pos) - 4, adr);
  S.DISPOSE( adr);
 END Dispose;


PROCEDURE Run*;
  VAR
    p : Str.ptr;
    rf,wf : FB.file; c : CHAR;
    Buffer : ARRAY 200 OF CHAR;
    i,Length : INTEGER;

  PROCEDURE WriteLine;
   BEGIN
    Buffer[i] := 0DX; Buffer[i+1] := 0AX; Buffer[i+2] := 0X;
    FB.WriteChars(wf,Buffer); i := 0; Length := 0;
   END WriteLine;

  PROCEDURE FormatLine;
    VAR
      j : INTEGER;
   BEGIN
    Buffer[i] := 0X;
    WHILE Length < linelen DO j := 0;
      WHILE (j < i) AND (Length < linelen) DO
        IF Buffer[j] = " " THEN Str.InsertC(" ",j,Buffer);
          INC(j); INC(i); INC(Length);
        END;
        INC(j);
      END;
    END;
   END FormatLine;

  PROCEDURE WriteChar;
    VAR
      End : INTEGER;
      s : ARRAY 100 OF CHAR;
   BEGIN
    IF c = 09X THEN
      c := " "; WriteChar; WriteChar;
      RETURN
    END;
    Buffer[i] := c; INC(i);
    IF c = 09X THEN INC(Length, 8 - S.ANL(Length,7) )
    ELSE INC(Length)
    END;
    IF Length >= linelen THEN
      Buffer[i] := 0X; End := i; i := Str.LPosC(" ",Buffer);
      IF i # -1 THEN
        Str.Excerpt(i+1,End,Buffer,s);
        DEC(Length, End - i); FormatLine;
        WriteLine; COPY(s,Buffer);
      END;
      i := Str.Length(Buffer);
      Length := i;
    END;
   END WriteChar;

 BEGIN
  IF Sys.Basepage.ComLen # 0 THEN
    p := S.ADR(Sys.Basepage.Command[0]);
    IF FB.Load(p^,rf) AND FB.Open(p^,10*1024,wf) THEN
      IO.WriteString( "Converting "); IO.WriteString( p^); IO.WriteLn;
      i := 0; Length := 0;
      REPEAT
        FB.ReadChar(rf,c);
        IF rf.Ok THEN
          IF c = 0X THEN FB.Seek(wf,FB.absbeg,0); i := 0; Length := 0;
          ELSIF c = 0DX THEN WriteLine
          ELSIF c # 1CX THEN WriteChar
          END;
        END;
      UNTIL NOT rf.Ok;
      IF i > 0 THEN WriteLine END;
      FB.Close(wf);
      Dispose(rf);
    ELSE
      IO.WriteString( "Could not find "); IO.WriteString( p^); IO.WriteLn;
    END;
  ELSE IO.WriteString("Usage : convert <filename>");
    IO.WriteLn;
  END;
 END Run;


END Convert.