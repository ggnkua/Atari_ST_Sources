MODULE LibManager;

(*
 * Erm”glicht Zugriff auf den Inhalt von Megamax Library-Dateien
 *
 * Erstellt Frhjahr/Sommer 1989 von Thomas Tempelmann      (Stand: 14.01.91)
 *
 *   Hier noch ein paar Anregungen fr lange Winterabende, an denen
 * sonst nix zu tun ist:
 *   - Mit dem Modul 'WindowLists' k”nnte die Anzeige und Auswahl der Dateien
 *     in der Library bersichtlicher gestaltet werden.
 *   - Das L”schen oder Anzeigen der Dateien in der Lib k”nnte mit der
 *     Funktion 'NameMatching' aus 'FileNames' auch ber sog. 'Wildcards'
 *     erm”glicht werden.
 *   Und wenn Sie tats„chlich solche oder andere Verbesserungen an den
 * Megamax-Hilfsprogrammen vorgenommen haben, schicken Sie sie uns doch
 * zurck. Wir wrden sie dann gerne durch unsere Versionen ersetzen.
 * Auch wenn es keine echten MEMOX-Beitr„ge w„ren, bieten wir Ihnen trotzdem
 * eine MEMOX-Disk im Tausch.
 *)

IMPORT GEMIO;
IMPORT VT52;
FROM EasyGEM1 IMPORT SelectFile, SelectMask;
FROM BinOps IMPORT LowerLCard;
IMPORT Clock, TimeConvert, MOSGlobals, Files, Binary;
FROM Directory IMPORT Delete, DirQuery, DirQueryProc, DirEntry, FileAttrSet,
        SetFileAttr;
FROM FileNames IMPORT FileName, FilePath, ConcatName, FileSuffix, ValidatePath;
FROM MOSGlobals IMPORT FileStr, PathStr, fNoMatchingFiles;
FROM InOut IMPORT Write, WriteString, WriteCard, WriteLn, Read, WritePg,
        ReadString, GotoXY;
IMPORT LibFiles;
FROM Strings IMPORT Assign, Space, Length, Empty, Append, String;
FROM FuncStrings IMPORT ConcStr;
FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

TYPE Cmd = (quit, open, list, add, remove, extract);
     Ascii = SET OF CHAR;

VAR ok: BOOLEAN;
    ch: CHAR;
    f: Files.File;
    path, libName: FileStr;
    lib: LibFiles.LibFile;
    r: INTEGER;
    all: BOOLEAN;
    count: CARDINAL;
    copybuffer: ARRAY [1..$2000] OF CARDINAL;


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
    WriteString ('Taste...');
    Read (c)
  END wait;

PROCEDURE weiter (): BOOLEAN;
  VAR c: CHAR;
  BEGIN
    WriteString ('Weiter? (J/N) ');
    RETURN yes ()
  END weiter;

PROCEDURE error (taste: BOOLEAN);
  VAR s: ARRAY [0..31] OF CHAR;
  BEGIN
    WriteLn;
    Files.GetStateMsg (r, s);
    WriteString ('Fehler: ');
    WriteString (s);
    WriteLn;
    IF taste THEN wait END;
    r:= 0
  END error;

PROCEDURE ferror (f: Files.File);
  BEGIN
    r:= Files.State (f);
    error (TRUE)
  END ferror;


PROCEDURE openLib;
  VAR s: FileStr;
  BEGIN
    WritePg;
    s:= '';
    ConcatName (SelectMask, 'M2L', SelectMask);
    SelectFile ('W„hle Library', s, ok);
    ConcatName (SelectMask, '*', SelectMask);
    IF NOT ok OR (LENGTH (FileName (s)) = 0) THEN RETURN END;
    IF LENGTH (FileSuffix (s)) = 0 THEN
      ConcatName (s, 'M2L', s)
    END;
    LibFiles.OpenLib (lib, s, r);
    IF (r = MOSGlobals.fPathNotFound) OR (r = MOSGlobals.fFileNotFound) THEN
      WriteLn;
      WriteString (
        'Library existiert nicht. Soll sie neu angelegt werden ? (J/N) ');
      IF yes () THEN
        LibFiles.CreateLib (s, r);
        IF r < 0 THEN
          libName:= '';
          error (TRUE);
          RETURN
        END;
        LibFiles.OpenLib (lib, s, r)
      END
    END;
    IF r < 0 THEN
      error (TRUE)
    ELSE
      libName:= s
    END;
    LibFiles.CloseLib (lib);
  END openLib;


PROCEDURE showEntry ( f: LibFiles.LibEntry ): BOOLEAN;
  VAR s: String;
  BEGIN
    IF count = 0 THEN
      count:= 18;
      wait;
      WritePg
    END;
    DEC (count);
    WriteString (f.name);
    WriteString (Space (14-Length (f.name)));
    WriteCard (f.size,7);
    WriteString ('   ');
    TimeConvert.DateToText ( Clock.UnpackDate (f.date), '', s);
    WriteString (s);
    WriteString ('   ');
    TimeConvert.TimeToText ( Clock.UnpackTime (f.time), '', s);
    WriteString (s);
    WriteLn;
    RETURN TRUE
  END showEntry;

PROCEDURE showLib;
  BEGIN
    WritePg;
    count:= 18;
    LibFiles.OpenLib (lib, libName, r);
    IF r < 0 THEN error (TRUE); RETURN END;
    LibFiles.LibQuery (lib, showEntry, r);
    LibFiles.CloseLib (lib);
    WriteLn;
    IF r < 0 THEN error (TRUE) ELSE WriteLn; wait END
  END showLib;


PROCEDURE readEntry ( d: LibFiles.LibEntry ): BOOLEAN;
  VAR f: Files.File; rd,n: LONGCARD;
  BEGIN
    WriteLn;
    WriteString (d.name);
    WriteString (VT52.Seq[VT52.flush]);
    Files.Create (f, ConcStr (path, d.name),
                  Files.writeOnly, Files.noReplace);
    IF Files.State (f) = MOSGlobals.fFileExists THEN
      WriteString ('  -  Datei existiert schon ! šberschreiben ? (J/N) ');
      IF yes () THEN
        Files.Create (f, ConcStr (path, d.name), Files.writeOnly,
                Files.replaceOld);
      ELSE
        RETURN TRUE
      END
    END;
    IF Files.State (f) < 0 THEN
      ferror (f);
      RETURN FALSE
    END;
    Binary.Seek (lib.f, d.start, Binary.fromBegin);
    rd:= LowerLCard (SIZE (copybuffer), d.size);
    n:= d.size;
    REPEAT
      Binary.ReadBytes (lib.f, ADR (copybuffer), rd, rd);
      Binary.WriteBytes (f, ADR (copybuffer), rd);
      n:= n - rd;
      IF Files.State (f) < 0 THEN
        ferror (f); Files.Remove (f); RETURN FALSE
      END;
    UNTIL n = 0L;
    Files.Close (f);
    IF Files.State (f) < 0 THEN ferror (f); RETURN FALSE END;
    Files.Open (f, ConcStr (path, d.name), Files.readOnly);
    Files.SetDateTime (f, Clock.UnpackDate(d.date), Clock.UnpackTime(d.time));
    Files.Close (f);
    SetFileAttr (ConcStr (path, d.name), d.attr, r);
    RETURN TRUE
  END readEntry;

PROCEDURE readFile;
  VAR d: LibFiles.LibEntry; l,c: CHAR;
      s: FileStr;
  BEGIN
    WritePg;
    LibFiles.OpenLib (lib, libName, r);
    IF r < 0 THEN error (TRUE); RETURN END;
    WriteString ('Alle Dateien oder Eine ? (A/E) ');
    c:= get (Ascii{'A','E',33C});
    IF c=33C THEN LibFiles.CloseLib (lib); RETURN END;
    WriteLn;
    WriteLn;
    WriteString ('Ziel-Verzeichnis: ');
    s:= '';
    SelectFile ('Ziel-Verzeichnis?', s, ok);
    IF NOT ok THEN LibFiles.CloseLib (lib); RETURN END;
    Assign (FilePath (SelectMask), path, ok);
    WriteString (path);
    IF c = 'A' THEN
      LibFiles.LibQuery (lib, readEntry, r);
    ELSE
      WriteLn;
      WriteString ('Welche Datei aus der Library herauskopieren? ');
      ReadString (s);
      LibFiles.LookUp (lib, s, d, r);
      IF r >= 0 THEN
        IF readEntry (d) THEN END;
      END
    END;
    LibFiles.CloseLib (lib);
    IF r < 0 THEN error (TRUE) END;
  END readFile;


PROCEDURE delLib;
  BEGIN
    WriteLn;
    WriteString ('Library ist besch„digt und wird gel”scht.');
    Delete (libName, r);
    libName:= '';
    WriteLn;
    wait;
  END delLib;

PROCEDURE insFile (REF path: ARRAY OF CHAR; e: DirEntry): BOOLEAN;

  VAR c: CHAR; dam: BOOLEAN;
      d: LibFiles.LibEntry;
      l, f: Files.File;
      n: LONGCARD;

  BEGIN
    WriteLn;
    WriteString (e.name);
    WriteString (VT52.Seq[VT52.flush]);
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
    WITH d DO
      name:= e.name;
      size:= e.size;
      attr:= e.attr;
      date:= Clock.PackDate (e.date);
      time:= Clock.PackTime (e.time);
    END;
    LibFiles.AddFile (libName, d, dam, r);
    IF r < 0 THEN
      error (FALSE); (* hier noch nicht auf Taste warten *)
      IF dam THEN
        delLib; (* wartet auf Taste *)
        RETURN FALSE
      END;
      RETURN weiter ()
    END;
    Files.Open (l, libName, Files.writeOnly);
    Binary.Seek (l, d.start, Binary.fromBegin);
    Files.Open (f, ConcStr (path, e.name), Files.readOnly);
    n:= SIZE (copybuffer);
    REPEAT
      Binary.ReadBytes (f, ADR (copybuffer), n, n);
      Binary.WriteBytes (l, ADR (copybuffer), n);
    UNTIL n = 0L;
    Files.Close (f);
    Files.Close (l);
    IF Files.State (l) < 0 THEN ferror (l); delLib; RETURN FALSE END;
    RETURN TRUE
  END insFile;

PROCEDURE newFile;
  VAR s: FileStr;
  BEGIN
    WritePg;
    WriteString ('Name der einzufgenden Datei(en) (auch Wildcards, z.B "*.DEF")? ');
    WriteString (VT52.Seq[VT52.flush]);
    WriteLn;
    s:= '';
    SelectFile ('W„hle Datei(en)', s, ok);
    IF NOT ok OR (LENGTH (FileName (s)) = 0) THEN RETURN END;
    all:= FALSE;
    DirQuery (s, FileAttrSet {}, insFile, r);
    IF r < 0 THEN
      error (TRUE)
    ELSIF r = fNoMatchingFiles THEN
      WriteLn;
      WriteString ('Keine passenden Dateien gefunden!');
      WriteLn;
      wait
    END
  END newFile;


PROCEDURE delFile;
  VAR s: FileStr; dam: BOOLEAN;
  BEGIN
    WritePg;
    WriteString ('Name der in der Library zu l”schenden Datei? ');
    ReadString (s);
    IF Empty (s) THEN RETURN END;
    LibFiles.RemoveFile (libName, s, dam, r);
    IF r < 0 THEN
      error (TRUE);
      IF dam THEN delLib END
    END
  END delFile;


PROCEDURE menu (onlyOpen: BOOLEAN);
  BEGIN
    WritePg;
    GotoXY (20, 1);
    WriteString ('Megamax Modula-2 Library Manager');
    GotoXY (0, 3);
    IF Empty (libName) THEN
      WriteString ('Noch keine Library gew„hlt');
    ELSE
      WriteString ('Aktuelle Library: ');
      WriteString (libName);
    END;
    GotoXY (0, 6);
    WriteString (' W - Library w„hlen / anlegen');
    WriteLn;
    IF NOT onlyOpen THEN
      WriteString (' I - Inhalt der Library zeigen');
      WriteLn;
      WriteString (' L - Eine Datei aus Library l”schen');
      WriteLn;
      WriteString (' E - Neue Datei(en) in Library einfgen');
      WriteLn;
      WriteString (' K - Datei(en) aus Library herauskopieren');
      WriteLn;
    END;
    WriteString (' Q - Ende');
  END menu;

PROCEDURE wahl (onlyOpen: BOOLEAN): Cmd;
  VAR c: CHAR; s: Ascii;
  BEGIN
    IF onlyOpen THEN
      s:= Ascii {'W','Q'};
    ELSE
      s:= Ascii {'W','I','E','L','K','Q'};
    END;
    GotoXY (0, 5);
    WriteString ('W„hle: ');
    CASE get (s) OF
      'W': RETURN open |
      'I': RETURN list |
      'E': RETURN add |
      'L': RETURN remove |
      'K': RETURN extract |
      'Q': RETURN quit
    END
  END wahl;

BEGIN
  SelectMask:= '*.*';
  WriteString (VT52.Seq[VT52.enhancedOn]); (* Global: schnelle Ausgaben *)
  LOOP
    menu (Empty (libName));
    CASE wahl (Empty (libName)) OF
      open: openLib |
      list: showLib |
      add: newFile |
      remove: delFile |
      extract: readFile |
      quit: EXIT
    END
  END
END LibManager.
