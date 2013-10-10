MODULE DecoDef;

(*
 * Decodiert Åbersetzte Definitions-Module.
 * Das gewÅnschte Modul wird in diesem Prg. mit dem File-Selektor ausgewÑhlt.
 *)

FROM SYSTEM IMPORT ADDRESS, BYTE;
FROM GEMEnv IMPORT InitGem, RC, DeviceHandle;
FROM EasyGEM1 IMPORT SelectMask, SelectFile;
FROM Strings IMPORT String, Append;
FROM ShellMsg IMPORT DefSfx;
FROM Files IMPORT File, Open, Access, Close;
FROM Binary IMPORT ReadBytes, FileSize;
FROM Storage IMPORT ALLOCATE;
FROM InOut IMPORT OpenInput, Read, Write, WriteLn, WriteString, WriteCard,
                WriteInt, WritePg, WriteHex, WriteLHex;

VAR defname: String;
    ok: BOOLEAN;
    f: File;
    len: LONGCARD;
    buf: ADDRESS;
    devHdl: DeviceHandle;
    ch: CHAR;
    strptr: POINTER TO String;
    c: CARDINAL;
    lc: LONGCARD;
    i: INTEGER;
    li: LONGINT;

PROCEDURE peek (ofs: LONGCARD; VAR data: ARRAY OF BYTE);
  VAR p: POINTER TO BYTE; n: CARDINAL;
  BEGIN
    p:= buf + ofs;
    FOR n:= 0 TO HIGH (data) DO
      data [n]:= p^;
      INC (p)
    END;
  END peek;
  
BEGIN
  InitGem (RC, devHdl, ok);
  IF ~ok THEN HALT END;
  
  (*
   * Def-Datei auswÑhlen
   *)
  SelectMask:= '*.';
  Append (DefSfx, SelectMask, ok);
  defname:= '';
  SelectFile ('WÑhle DEF-Datei', defname, ok);
  IF NOT ok THEN RETURN END;
  
  (*
   * Datei laden
   *)
  Open (f, defname, readOnly);
  len:= FileSize (f);
  ALLOCATE (buf, len);
  IF buf = NIL THEN
    WriteString ('Speicher reicht nicht!');
    Read (ch);
    RETURN
  END;
  ReadBytes (f, buf, len, len);
  Close (f);
  
  INC (buf, 8); (* Header "MM2Code" Åberspringen *)
  
  WriteString ('Modulname: ');
  peek (22, strptr);
  INC (strptr, LONGCARD(buf));
  WriteString (strptr^);
  WriteLn;
  WriteLn;
  
  WriteString ('Key: ');
  peek (4, lc);
  WriteLHex (lc, 9);
  WriteLn;
  
  WriteLn;
  WriteString ('Taste...');
  Read (ch)
END DecoDef.
