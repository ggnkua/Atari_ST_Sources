MODULE HD_INST;

(*
 * Kopiert alle Dateien beliebig vieler Disks in ein Verzeichnis.
 * Das Datum wird beibehalten, die Attribute werden jedoch nicht Åbertragen.
 * Doppelte oder bereits vorhandene Dateien werden nicht nochmal kopiert.
 *
 * Das Programm wird lediglich mit "M2Init" gelinkt!
 *
 * TT 01.10.89
 *)

IMPORT SimpleError, GEMDOSIO;

IMPORT VT52;

FROM Storage IMPORT MemAvail, ALLOCATE;

FROM MOSGlobals IMPORT fFileExists, Drive, Date, Time;

FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, Read, ReadString,
        WritePg, BusyRead, FlushKbd;

FROM Files IMPORT GetStateMsg, File, Access, Open, Close, Remove, State,
        ResetState, GetDateTime, SetDateTime, Create, ReplaceMode;

FROM Binary IMPORT FileSize, ReadBytes, WriteBytes;

FROM Directory IMPORT MakeFullPath, DirQuery, DirEntry, DefaultDrive,
        SetDefaultDrive, CreateDir, QueryFiles, QueryAll, subdirAttr,
        FileAttrSet, PathExists;

FROM FileNames IMPORT ValidatePath, SplitPath;

FROM Strings IMPORT String, Empty, Append, Assign, Length, Space, Upper, Concat;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

FROM EasyGEM0 IMPORT HideMouse, ShowMouse;
FROM EasyGEM1 IMPORT SelectMask, SelectFile;
FROM GEMEnv IMPORT RC, InitGem, DeviceHandle;


VAR subdirs, aborted, ok: BOOLEAN;
    res: INTEGER;
    name, destpath: String;
    f1, f2: File;
    buf: ADDRESS;
    buflen: LONGCARD;
    ch: CHAR;
    msg: String;

PROCEDURE showError (res: INTEGER);
  VAR msg: String;
  BEGIN
    WriteLn;
    WriteString ('******* Fehler beim Kopieren: ');
    GetStateMsg (res, msg);
    WriteString (msg);
    WriteString (' *******');
    WriteLn;
  END showError;

PROCEDURE error (VAR f: File; s: ARRAY OF CHAR): BOOLEAN;
  VAR  msg: String;
  BEGIN
    IF State (f) < 0 THEN
      WriteLn;
      WriteString ('****** ');
      WriteString (s);
      WriteString (': ');
      GetStateMsg (State (f), msg);
      WriteString (msg);
      WriteString (' ******');
      WriteLn;
      ResetState (f);
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  END error;


PROCEDURE copyFile (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR lastpath, source, dest: String;
      n, n1: LONGCARD;
      d: Date; t: Time;

  BEGIN
    IF subdirAttr IN entry.attr THEN
      IF entry.name[0] # '.' THEN
        (* Ordner durchgehen *)
        Concat (path, entry.name, source, ok);
        Append ('\*.*', source, ok);
        lastpath:= destpath;
        Append (entry.name, destpath, ok);
        CreateDir (destpath, res); (* wenn schon existiert, Fehler ignorieren *)
        Append ('\', destpath, ok);
        DirQuery (source, QueryAll, copyFile, res);
        destpath:= lastpath;
        (* Falls Dateien noch offen, dann nun lîschen *)
        Remove (f1);
        Remove (f2);
        IF res < 0 THEN
          showError (res);
          aborted:= TRUE;
          RETURN FALSE
        ELSIF aborted THEN
          RETURN FALSE
        END
      END;
      RETURN TRUE
    ELSE
      (*
       * Wenn Fehler beim Lesen auftritt, wird mit dem nÑchsten File
       * weitergemacht, bei Fehlern beim Schreiben wird abgebrochen.
       *)
      Concat (path, entry.name, source, ok);
      Open (f1, source, readOnly);
      IF error (f1, source) THEN RETURN TRUE END;
      Concat (destpath, entry.name, dest, ok);
      Create (f2, dest, writeOnly, noReplace);
      IF State (f2) = fFileExists THEN
        (* existiert bereits *)
        Open (f2, dest, readOnly);
        IF FileSize (f1) <> FileSize (f2) THEN
          WriteLn;
          WriteString ('****** ');
          WriteString (dest);
          WriteString (': Verschiedene Dateien gleichen Namens ******');
          WriteLn;
          Close (f1);
          Close (f2);
          RETURN TRUE
        ELSE
          Close (f1);
          Close (f2);
          RETURN TRUE
        END
      ELSIF error (f2, dest) THEN
        aborted:= TRUE;
        RETURN FALSE
      ELSE
        n:= buflen;
        GetDateTime (f1, d, t);
        LOOP
          ReadBytes (f1, buf, n, n);
          IF error (f1, source) THEN RETURN TRUE END;
          IF n = 0L THEN EXIT END;
          WriteBytes (f2, buf, n);
          IF error (f2, dest) THEN aborted:= TRUE; RETURN FALSE END;
        END;
        Close (f2);
        Close (f1);
        Open (f2, dest, readOnly);
        SetDateTime (f2, d, t);
        Close (f2);
        RETURN TRUE
      END
    END
  END copyFile;

VAR dev: DeviceHandle;

BEGIN
  InitGem (RC, dev, ok);
  HideMouse;
  WritePg;
  WriteString ('Installation des Megamax Modula-2 auf Festplatte'); WriteLn;
  WriteLn;
  WriteString ('Gleich kînnen Sie den Ordner, in den das System kopiert werden soll,'); WriteLn;
  WriteString ('mit dem GEM-Datei-Selektor auswÑhlen. Klicken Sie dann auf OK.'); WriteLn;
  WriteString ('Ein Klick auf ABBRUCH bricht die Installation ab.'); WriteLn;
  WriteLn;
  WriteString ('Auf der Ziel-Partition mÅssen noch ca. 3.5 MB frei sein.'); WriteLn;
  WriteLn;
  WriteString ('DrÅcken Sie nun eine Taste, um das Ziel-Verzeichnis auszuwÑhlen...'); WriteLn;
  FlushKbd;
  Read (ch);

  SelectMask:= 'C:\';
  REPEAT
  
    name:= '';
    SelectFile ('WÑhle Ziel-Verzeichnis', name, ok);
    WritePg;
    IF NOT ok THEN RETURN END;
    SplitPath (name, destpath, name);
    MakeFullPath (destpath, res);
    
    IF name [0] # 0C THEN
      (* Verzeichnis anlegen *)
      WriteLn;
      WriteString ('Verzeichnis wird angelegt...');
      Append (name, destpath, ok);
      CreateDir (destpath, res);
      ValidatePath (destpath);
      WriteLn;
      IF res < 0 THEN
        WriteString ('Fehler beim Anlegen des Verzeichnisses: ');
        GetStateMsg (res, msg);
        WriteString (msg);
        WriteLn;
        WriteString ('Taste...');
        FlushKbd;
        Read (ch);
        WriteLn;
      END
    END;
    
  UNTIL PathExists (destpath);
  
  WriteLn;
  WriteString ('Der Ziel-Pfad ist: ');
  WriteString (destpath);
  WriteLn;
  WriteLn;

  buflen:= MemAvail () - $10000;
  ALLOCATE (buf, buflen);

  WriteString ('Zum Installieren mÅssen Sie im Folgenden die vier mitgelieferten'); WriteLn;
  WriteString ('Disketten (oder Kopien davon) in beliebiger Reihenfolge bei Aufforderung'); WriteLn;
  WriteString ('einlegen. Danach kînnen Sie den Vorgang abbrechen.'); WriteLn;
  WriteString ('Es schadet nichts, wenn Sie versehentlich dieselbe Diskette mehrmals kopieren!'); WriteLn;

  LOOP
    WriteLn;
    WriteString ('Legen Sie nun die nÑchste Diskette ein und drÅcken Sie dann >Return<'); WriteLn;
    WriteString ('Oder drÅcken Sie >Esc< zum Beenden.'); WriteLn;
    FlushKbd;
    WriteString (VT52.Seq [VT52.cursorOn]);
    REPEAT
      BusyRead (ch);
      IF ch = 33C THEN
        (* Programmende *)
        WriteString (VT52.Seq [VT52.cursorOff]);
        EXIT
      END;
    UNTIL ch = 15C;
    WriteString (VT52.Seq [VT52.cursorOff]);
    WriteLn;

    WriteString ('Diskette wird kopiert...');
    WriteLn;
    aborted:= FALSE;
    IF DefaultDrive () > drvB THEN
      (* wenn nicht von A: oder B: gestartet, dann A: als Source-LW nehmen *)
      SetDefaultDrive (drvA)
    END;
    DirQuery ('\*.*', QueryAll, copyFile, res);
    (* Falls Dateien noch offen, dann nun lîschen *)
    Remove (f1);
    Remove (f2);
    IF res < 0 THEN
      showError (res);
      aborted:= TRUE
    END;
    IF aborted THEN
      WriteString ('Kopiervorgang abgebrochen.');
      WriteLn;
    ELSE
      WriteLn;
      WriteString ('Kopiervorgang erfolgreich durchgefÅhrt.');
      WriteLn;
    END
  END;
END HD_INST.
