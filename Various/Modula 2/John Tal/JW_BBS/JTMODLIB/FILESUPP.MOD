IMPLEMENTATION MODULE FileSupport;

FROM Network IMPORT File,Response,Lookup,Close,ReadChar,SetRead,
                    SetWrite,SetPos,WriteChar;

FROM Functions IMPORT RecHi,RecLo;
FROM ASCII     IMPORT lf,cr,sub;
FROM Strings   IMPORT Length;
FROM Environment IMPORT Pause;


PROCEDURE ReadString(VAR f: File; VAR Str: ARRAY OF CHAR);
VAR
  i: CARDINAL;
  ch: CHAR;
BEGIN
  i := 0;
  ch := ' ';
  ReadChar(f,ch);
  LOOP
    IF (ch = cr) OR (ch = sub) THEN EXIT; END;
    Str[i] := ch;
    INC(i);
    IF i = 255 THEN EXIT; END;
    ReadChar(f,ch);
  END;
  Str[i] := CHR(0);
  IF ch = sub THEN  f.eof := TRUE;  END;
  IF ch = cr  THEN  ReadChar(f,ch); END;  (* dump line-feed *)
END ReadString;

PROCEDURE WriteString(f: File; Str: ARRAY OF CHAR);
VAR
  i,l: CARDINAL;
BEGIN
  l := Length(Str);
  IF l > 0 THEN
    FOR i := 0 TO Length(Str)-1 DO
      WriteChar(f,Str[i]);
    END;
  END;
END WriteString;

PROCEDURE WriteLn(f: File);
BEGIN
  WriteChar(f,cr);
  WriteChar(f,lf);
END WriteLn;


PROCEDURE LookupWait(VAR f: File; fileName: ARRAY OF CHAR;
                         modeshar: ARRAY OF CHAR;  SecsToWait: CARDINAL);
CONST
 waitVal = 1.0;
VAR
 Waiting: BOOLEAN;
 waitCount,secs: CARDINAL;
 F: File;
BEGIN
  F := f;
  secs := SecsToWait;
  Waiting := TRUE;
  waitCount := 0;
  WHILE Waiting DO
    Lookup(F,fileName,modeshar);
    IF F.res = callerror THEN
      INC(waitCount);
      Pause(waitVal);
      IF waitCount > secs THEN
        Waiting := FALSE;
        f.res := notdone;
      END;
    ELSE
      f := F;
      Waiting := FALSE;
    END;
  END; (* while *)
END LookupWait;



END FileSupport.
