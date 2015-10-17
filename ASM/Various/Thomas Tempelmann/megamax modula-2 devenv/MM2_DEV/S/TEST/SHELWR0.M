MODULE SHELWR0;

(* Testet ShellWrite-Funktion *)

(*$E MOS *)
IMPORT TOSIO;
FROM InOut IMPORT WriteString, Write, WriteLn, WriteCard, Read, ReadString,
        WriteHex;

IMPORT GEMEnv, AESMisc, PrgCtrl;

VAR s,s2: ARRAY [0..255] OF CHAR;
  handle: GEMEnv.DeviceHandle;
  ok: BOOLEAN;

PROCEDURE rd;
  BEGIN
    AESMisc.ShellRead (s, s2);
    WriteString ('CMD : '); WriteString (s); WriteLn;
    WriteString ('TAIL: '); WriteString (s2); WriteLn;
  END rd;
  
VAR ch: CHAR;

BEGIN
  GEMEnv.InitGem (GEMEnv.RC, handle, ok);
  
  rd;
  
  WriteString ('ShellWrite (noGemAppl)'); WriteLn;
  
  AESMisc.ShellWrite (AESMisc.startAppl, AESMisc.graphicPrgm,
                      AESMisc.noGemAppl, 'D:\GEP_ED.PRG', 'D:\DOC\TODO.TXT');
  rd;
  
  Read (ch)
END SHELWR0.
