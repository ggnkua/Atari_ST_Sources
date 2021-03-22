MODULE SHELWRIT;

(* Testet ShellWrite-Funktion *)

(*$E MOS *)
IMPORT TOSIO;
FROM InOut IMPORT WriteString, Write, WriteLn, WriteCard, Read, ReadString,
        WriteHex;

IMPORT GEMEnv, AESMisc, Directory;

VAR s,s2: ARRAY [0..255] OF CHAR;
  handle: GEMEnv.DeviceHandle;
  i: INTEGER;
  ok: BOOLEAN;

PROCEDURE rd;
  BEGIN
    WriteString ('Current path: '); WriteString (Directory.DefaultPath()); WriteLn;
    AESMisc.ShellRead (s, s2);
    WriteString ('Cmd: '); WriteString (s); WriteLn;
    WriteString ('Arg: '); WriteString (s2); WriteLn;
  END rd;
  
VAR ch: CHAR;

BEGIN
  GEMEnv.InitGem (GEMEnv.RC, handle, ok);
  
  rd;
  
  WriteString ('ShellWrite...'); WriteLn;
  REPEAT
    WriteString ('Path?'); ReadString (s);
    Directory.SetDefaultPath (s,i);
  UNTIL i >= 0;
  WriteString ('Cmd ?'); ReadString (s);
  WriteString ('Arg ?'); ReadString (s2);

  AESMisc.ShellWrite (AESMisc.startAppl, AESMisc.graphicPrgm,
                      AESMisc.gemAppl, s, s2);
  rd;
  Read (ch)
END SHELWRIT.
