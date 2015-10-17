MODULE Decode;

(* Dekomprimiert Dateien.
 *
 * Eine komprimierte Datei hat folgenden Header:
 * 8 Zeichen: "MM2Comp"+0C
 * ...die komprimierten Daten
 *)

IMPORT GEMIO;
FROM EasyGEM1 IMPORT SelectFile;
FROM MOSGlobals IMPORT fNoMatchingFiles, PathStr, FileStr;
FROM BinOps IMPORT LowerLCard;
IMPORT Files, Binary;
FROM Directory IMPORT Delete, DirQuery, DirQueryProc, DirEntry, FileAttrSet,
        SetFileAttr;
FROM FileNames IMPORT SplitPath, PathConc;
FROM InOut IMPORT Write, WriteString, WriteCard, WriteLn, Read, WritePg,
        BusyRead, ReadString, GotoXY;
FROM Strings IMPORT Space, Length, Empty, Append, String, Compare, Relation;
FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
IMPORT Compressions;

TYPE Ascii = SET OF CHAR;

VAR ok: BOOLEAN;
    r: INTEGER;
    all: BOOLEAN;
    destPath: PathStr;


PROCEDURE get (a: Ascii): CHAR;
  VAR c: CHAR;
  BEGIN
    REPEAT
      Read (c);
      IF c >= ' ' THEN Write (CHR (8)) END;
      c:= CAP (c);
    UNTIL c IN a;
    RETURN c
  END get;

PROCEDURE yes (): BOOLEAN;
  BEGIN
    RETURN get (Ascii{'J','N'}) = 'J'
  END yes;

PROCEDURE wait;
  VAR c: CHAR;
  BEGIN
    WriteLn;
    WriteLn;
    WriteString ('Taste zum Beenden...');
    Read (c)
  END wait;

PROCEDURE error;
  VAR s: ARRAY [0..31] OF CHAR;
  BEGIN
    WriteLn;
    Files.GetStateMsg (r, s);
    WriteString ('Fehler: ');
    WriteString (s);
    WriteLn;
    r:= 0
  END error;

PROCEDURE ferror (f: Files.File);
  BEGIN
    r:= Files.State (f);
    error
  END ferror;

PROCEDURE insFile (REF path: ARRAY OF CHAR; e: DirEntry): BOOLEAN;

  VAR c: CHAR; dam: BOOLEAN;
      f: Files.File;
      n: LONGCARD;
      source, dest: ADDRESS;
      newlen, slen, dlen: LONGCARD;
      type: CARDINAL;
      str: POINTER TO ARRAY [0..7] OF CHAR;

  BEGIN
    WriteLn;
    WriteString (e.name);
    IF ~all THEN
      WriteString (' ? (Ja/Nein/Alle/Fertig) ');
      c:= get (Ascii{'J','N','A','F'});
      IF c='F' THEN
        RETURN FALSE
      ELSIF c='N' THEN
        RETURN TRUE
      ELSIF c='A' THEN
        all:= TRUE
      END
    END;
    ALLOCATE (source, e.size);
    Files.Open (f, PathConc (path, e.name), Files.readOnly);
    Binary.ReadBytes (f, source, e.size, n);
    IF e.size # n THEN HALT END;
    Files.Close (f);
    str:= source;
    IF Compare ("MM2Comp", str^) # equal THEN
      WriteString (' ist nicht komprimiert!')
    ELSE
      Compressions.GetInfo (source+8L, type, dlen);
      ALLOCATE (dest, dlen);
      IF dest = NIL THEN HALT END;
      DEC (n, 8);
      Compressions.Decode (source+8L, n, dest, dlen, ok);
      IF NOT ok THEN
        DEALLOCATE (dest, 0);
        WriteString ('  Fehler beim Dekodieren!');
        WriteLn;
        WriteString ('Weiter? (J/N) ');
        RETURN yes ()
      ELSE
        Files.Create (f, PathConc (destPath, e.name),
                         Files.writeOnly, Files.replaceOld);
        Binary.WriteBytes (f, dest, dlen);
        Files.Close (f);
        DEALLOCATE (dest, 0);
        (* Datum/Zeit der dekomprimierten Datei Åbernehmen *)
        Files.Open (f, PathConc (destPath, e.name), Files.readWrite);
        Files.SetDateTime (f, e.date, e.time);
        Files.Close (f);
        IF Files.State (f) < 0 THEN ferror (f); RETURN FALSE END;
        WriteString (' dekodiert');
      END;
    END;
    DEALLOCATE (source, 0);
    RETURN TRUE
  END insFile;

PROCEDURE newFile;
  VAR s: FileStr; dummy: ARRAY [0..11] OF CHAR;
  BEGIN
    WriteString ('Name der zu dekomprimierenden Datei (Wildcards sind erlaubt, z.B "*.DEF"):');
    WriteLn;
    s:= '';
    SelectFile ('Gepackte Datei(en)?', s, ok);
    IF NOT ok THEN RETURN END;
    WriteString (s);
    WriteLn;
    WriteLn;
    WriteString ('Ziel-Pfad: ');
    destPath:= '';
    SelectFile ('Ziel-Pfad?', destPath, ok);
    IF NOT ok THEN RETURN END;
    SplitPath (destPath, destPath, dummy);
    WriteString (destPath);
    all:= FALSE;
    DirQuery (s, FileAttrSet {}, insFile, r);
    IF r < 0 THEN
      error
    ELSIF r = fNoMatchingFiles THEN
      WriteLn;
      WriteString ('Keine passenden Dateien gefunden!');
      WriteLn;
    END
  END newFile;

BEGIN
  WriteLn ();
  WriteString (' Dekodierer fÅr Megamax Modula-2');
  WriteLn ();
  WriteString (' Erstellt 8/1989 von Gabi Keller, Manuel Chakravarty & Thomas Tempelmann');
  WriteLn ();
  WriteLn ();
  newFile;
  wait;
END Decode.
