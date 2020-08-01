MODULE Disassemble; (* Stephan Junker  19.12.93 *)


IMPORT
  S:=SYSTEM, Disass, CL:=CommandLine, IO, NumStr, Strings, File, Sys, Task;


VAR
  DisAd, Endad: S.PTR;
  Bytes, BPos : LONGINT;
  i : INTEGER;


PROCEDURE Run*;
 BEGIN
  IF CL.arg = NIL THEN
    IO.WriteString("Usage: Disassemble <address> [<bytes>]"); IO.WriteLn;
    IO.WriteString(" or    Disassemble -f filename [<begpos> [<bytes>]]"); IO.WriteLn;
  ELSE
    NumStr.OK := TRUE;
    IF CL.arg[0] = "-" THEN
      CL.Next;
      IF CL.arg = NIL THEN RETURN END;
      IF NOT File.Load(CL.arg^, 0, 0, DisAd, Bytes) THEN
        IO.WriteString(CL.arg^); IO.WriteString(" not found");
        IO.WriteLn;
        RETURN
      END;
      CL.Next;
      IF CL.arg # NIL THEN
        BPos := NumStr.ToLInt(16, CL.arg^);
        INC(DisAd, BPos); DEC(Bytes, BPos);
        CL.Next;
        IF CL.arg # NIL THEN
          Bytes := NumStr.ToLInt(16, CL.arg^);
        END;
      END;
    ELSE
      DisAd := NumStr.ToLInt(16, CL.arg^);
      IF NumStr.OK THEN
        CL.Next;
        IF CL.arg # NIL THEN
          Bytes := NumStr.ToLInt(16, CL.arg^);
        ELSE
          Bytes := 7FFFFFFH;
        END;
      END;
    END;
    IF NOT NumStr.OK THEN
      IO.WriteString("Numbers must be in hex without additional characters!");
      IO.WriteLn;
      RETURN
    END;
    Endad := DisAd + Bytes;
    REPEAT
      IO.WriteChar("$");
      IO.WriteFInt(DisAd, 16, IO.right, 8, "0");
      IO.WriteChar(" ");
      Disass.Do(DisAd);
      IO.WriteString(Disass.opcodeBuf^);
      FOR i := Strings.Length(Disass.opcodeBuf^) TO 7 DO
        IO.WriteChar(" ");
      END;
      IO.WriteString(Disass.eaBuf^);
      IO.WriteLn;
    UNTIL DisAd >= Endad;
  END;
 END Run;


BEGIN
  IF ~Sys.Loader THEN
    Run;
    Task.Exit(0);
  END;
END Disassemble.

