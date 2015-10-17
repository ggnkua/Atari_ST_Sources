MODULE ShelTest;

(* Testet AESMisc-Funktionen *)

FROM InOut IMPORT WriteString, Write, WriteLn, WriteCard, Read, ReadString,
        WriteHex;

IMPORT GEMEnv, AESMisc, PrgCtrl;

VAR s,s2: ARRAY [0..255] OF CHAR;
  handle: GEMEnv.DeviceHandle;
  ok: BOOLEAN;


PROCEDURE fill (VAR s: ARRAY OF CHAR);
  VAR i: CARDINAL;
  BEGIN
    FOR i:= 0 TO HIGH (s) DO
      s[i]:= CHR(i)
    END
  END fill;

PROCEDURE chk (VAR s: ARRAY OF CHAR);
  VAR i: CARDINAL;
  BEGIN
    FOR i:= 0 TO HIGH (s) DO
      IF (s[i] = CHR(i)) AND (s[i+1] = CHR(i+1)) THEN
        WriteString ('Filled up to byte ');
        WriteCard (i,0);
        WriteLn;
        RETURN
      END
    END;
    WriteString ('Overflow!');
    HALT
  END chk;


VAR ch: CHAR;

BEGIN
  GEMEnv.InitGem (GEMEnv.RC, handle, ok);
  LOOP
    Read (ch);
    IF ch = 33C THEN EXIT END;
    IF PrgCtrl.Accessory () THEN
      WriteString ('ACC')
    ELSE
      WriteString ('PRG')
    END;
    WriteLn;
    WriteString ('Ap_ID: ');
    WriteHex (GEMEnv.ApplicationID(),5);
    WriteLn;
    WriteString ('GEMVersion: ');
    WriteHex (GEMEnv.GEMVersion(),5);
    WriteLn;
    WriteString ('Scrap Dir: ');
    fill (s);
    AESMisc.ReadScrapDir (s);
    WriteString (s);
    WriteLn;
    chk (s);
    fill (s);
    fill (s2);
    AESMisc.ShellRead (s, s2);
    WriteLn;
    WriteString ('CMD: ');
    WriteString (s);
    WriteLn;
    chk (s);
    WriteString ('TAIL: ');
    WriteString (s2);
    WriteLn;
    chk (s2);
    
    WriteString ('ShellWrite...');
    WriteLn;
    AESMisc.ShellWrite (AESMisc.leaveAES, AESMisc.graphicPrgm,
                        AESMisc.gemAppl, 'Bla', 'blu');
    AESMisc.ShellRead (s, s2);
    WriteString ('CMD: ');
    WriteString (s);
    WriteLn;
    WriteString ('TAIL: ');
    WriteString (s2);
    WriteLn;
    
    fill (s);
    WriteString ('PATH= ');
    AESMisc.ShellEnvironment ('PATH',s);
    WriteString (s);
    WriteLn;
    chk (s);
    
  END;
END ShelTest.
