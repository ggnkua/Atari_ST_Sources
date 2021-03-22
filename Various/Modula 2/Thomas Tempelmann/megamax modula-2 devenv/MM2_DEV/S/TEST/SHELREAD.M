MODULE SHELREAD;

(* Testet ShellRead-Funktion *)

(*$E MOS *)
IMPORT TOSIO;
FROM InOut IMPORT WriteString, Write, WriteLn, WriteCard, Read, ReadString,
        WriteHex;
IMPORT GEMEnv, AESMisc, Directory;

VAR s,s2: ARRAY [0..255] OF CHAR;
  handle: GEMEnv.DeviceHandle;
  ok: BOOLEAN;

PROCEDURE rd;
  BEGIN
    WriteString ('Current path: '); WriteString (Directory.DefaultPath()); WriteLn;
    AESMisc.ShellRead (s, s2);
    WriteString ('Cmd : '); WriteString (s); WriteLn;
    WriteString ('Tail: '); WriteString (s2); WriteLn;
  END rd;
  
VAR ch: CHAR;

BEGIN
  GEMEnv.InitGem (GEMEnv.RC, handle, ok);
  
  rd;
  
  WriteString ('ShellWrite (leaveAES, gemAppl, "BLA") -> should be ignored'); WriteLn;
  
  AESMisc.ShellWrite (AESMisc.leaveAES, AESMisc.graphicPrgm,
                      AESMisc.gemAppl, 'Bla', 'blu');
  rd;
  Read (ch)
END SHELREAD.
