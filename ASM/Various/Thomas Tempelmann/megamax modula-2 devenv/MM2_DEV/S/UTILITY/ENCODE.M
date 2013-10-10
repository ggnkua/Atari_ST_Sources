MODULE Encode;

(* Komprimiert Dateien.
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
      dlen: LONGCARD;
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
    IF n # e.size THEN HALT END;
    Files.Close (f);
    str:= source;
    IF Compare ("MM2Comp", str^) = equal THEN
      WriteString (' ist bereits komprimiert!')
    ELSE
      ALLOCATE (dest, e.size+14L);  (* 8 Byte f. "MM2Comp" & 6 Byte Reserve *)
      str:= dest;
      str^:= "MM2Comp";
      str^[7]:= 0C;
      Compressions.Encode (0, source, e.size,
                           dest+8L, e.size+Compressions.DestOverhead, dlen);
      Files.Create (f, PathConc (destPath, e.name),
                    Files.writeOnly, Files.replaceOld);
      Binary.WriteBytes (f, dest, dlen + 8L);
      Files.Close (f);
      DEALLOCATE (dest, 0);
      IF Files.State (f) < 0 THEN ferror (f); RETURN FALSE END;
      (* Datum/Zeit der komprimierten Datei bernehmen *)
      Files.Open (f, PathConc (destPath, e.name), Files.readWrite);
      Files.SetDateTime (f, e.date, e.time);
      Files.Close (f);
      WriteString ('   ');
      WriteCard (100L * (dlen + 8L) DIV e.size, 3);
      Write ('%');
    END;
    DEALLOCATE (source, 0);
    RETURN TRUE
  END insFile;

PROCEDURE newFile;
  VAR s: FileStr; dummy: ARRAY [0..11] OF CHAR;
  BEGIN
    WriteString ('Name der zu komprimierenden Datei (Wildcards sind erlaubt, z.B "*.DEF")? ');
    WriteLn;
    s:= '';
    SelectFile ('', s, ok);
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
    IF r < 0 THEN error END
  END newFile;

BEGIN
  WriteLn ();
  WriteString (' Kodierer fr Megamax Modula-2');
  WriteLn ();
  WriteString (' Erstellt 8/1989 von Gabi Keller, Manuel Chakravarty & Thomas Tempelmann');
  WriteLn ();
  WriteLn ();
  newFile;
  wait;
END Encode.
