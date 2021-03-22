MODULE DoSysInfo;

FROM InOut IMPORT WriteString, WriteLn, Read, WriteCard, WriteHex;
FROM Clock IMPORT Date;
FROM TimeConvert IMPORT DateToText;
FROM SysInfo IMPORT GetTOSVersion, CPU, FPU, noFPU, internalFPU, externalFPU,
        FPUModel, Machine;
IMPORT GEMDOS, GEMEnv, AESMisc, PrgCtrl, Directory, PathEnv;


VAR
  v,r: CARDINAL; d: Date; s,s2: ARRAY [0..255] OF CHAR; ch: CHAR;
  handle: GEMEnv.DeviceHandle;
  ok: BOOLEAN;

BEGIN
  WriteString ('TOS ');
  GetTOSVersion (v,r,d);
  WriteCard (v,0);
  WriteString ('.');
  WriteCard (r,0);
  WriteString (' / ');
  DateToText (d, '', s);
  WriteString (s);
  WriteLn;
  WriteLn;
  WriteString ('GEMDOS-Version: ');
  GEMDOS.Version (v);
  WriteHex (v, 5);
  WriteLn;
  WriteLn;
  WriteString ('Machine: Atari ');
  CASE Machine () OF
    0: WriteString ('ST')|
    1: WriteString ('STE')|
    2: WriteString ('TT')|
  END;
  WriteLn;
  WriteLn;
  WriteString ('CPU: ');
  WriteCard (CPU (), 0);
  WriteLn;
  WriteString ('FPU: ');
  CASE FPU () OF
    noFPU:       WriteString ('not available')|
    internalFPU: WriteString ('internal (')|
    externalFPU: WriteString ('external (')
  END;
  CASE FPUModel () OF
    0: |
    1: WriteString ('68881)')|
    2: WriteString ('68882)')|
  END;
  WriteLn;
  GEMEnv.InitGem (GEMEnv.RC, handle, ok);
  IF NOT ok THEN WriteString ('Error on InitGEM!'); WriteLn END;
  WriteLn;
  (* Der 'HomePath' wird erst durch 'InitGem' gesetzt! *)
  WriteString ('HomePath: '); WriteString (PathEnv.HomePath); WriteLn;
  WriteString ('Current Path: '); WriteString (Directory.DefaultPath()); WriteLn;
  WriteLn;
  WriteString ('GEMVersion: ');
  WriteHex (GEMEnv.GEMVersion(),5);
  WriteLn;
  WriteString ('GEM Application-ID: ');
  WriteCard (GEMEnv.ApplicationID(),0);
  WriteLn;
  WriteLn;
  WriteString ('Scrap Dir: ');
  AESMisc.ReadScrapDir (s);
  IF GEMEnv.GemError () THEN WriteString ('Error!'); WriteLn END;
  WriteString (s);
  WriteLn;
  WriteLn;
  WriteString ('Searching for DOSYSINF.*...');
  s:= 'DOSYSINF.*';
  AESMisc.ShellFind (s);
  IF GEMEnv.GemError () THEN
    WriteString ('  Not found!');
  ELSE
    WriteString ('  Found ');
    WriteString (s);
  END;
  WriteLn;
  WriteLn;
  WriteString ('ShellRead...');
  WriteLn;
  AESMisc.ShellRead (s, s2);
  IF GEMEnv.GemError () THEN
    WriteString ('Error!')
  ELSE
    WriteString ('  cmd : ');
    WriteString (s);
    WriteLn;
    WriteString ('  tail: ');
    WriteString (s2);
  END;
  WriteLn;
  WriteString ('End of program.');
  WriteLn;
  Read (ch);
END DoSysInfo.
