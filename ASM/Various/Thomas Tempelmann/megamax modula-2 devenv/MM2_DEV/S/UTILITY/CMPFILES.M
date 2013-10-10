MODULE CmpFiles;
(*$E MOS *)
IMPORT GEMDOSIO;

(*
 * Vergleicht die Dateien zweier Disk-Verzeichnisse, optional auch die
 * in deren Unterverzeichnissen.
 *
 * Das Programm kann ohne Argumentangabe gestartet werden. Dann wird
 * nach den beiden Pfaden gefragt.
 * Die Pfade kînnen auch als Argumente (in Command-Line) angegeben werden.
 * Dann kann optional noch irgendein Zeichen als drittes Wort angegeben
 * werden, damit auch die Unterverzeichnisse mitgeprÅft werden.
 *
 * Das Programm prÅft alle Dateien, die im zuerst angegebenen Verzeichnis
 * stehen. Diese Dateien werden dann im andern Pfad gesucht. Fehlt die
 * Datei dort, wird dies angezeigt ("Open error").
 * Sind die Dateien in beiden Verzeichnissen vorhanden, werden sie
 * verglichen. Sind sie verschieden lang, wird "Different sizes" angezeigt,
 * sind sie nicht identisch, wird "Not equal" ausgegeben.
 *)

FROM ArgCVIO IMPORT PtrArgStr, InitArgCV;

FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, Read, ReadString;

FROM Files IMPORT File, Access, Open, Close, State;

FROM Binary IMPORT FileSize, ReadBytes;

FROM Directory IMPORT MakeFullPath, DirQuery, DirEntry,
        QueryFiles, QueryAll, subdirAttr, FileAttrSet;

FROM FileNames IMPORT ValidatePath;

FROM Strings IMPORT String, Empty, Append, Assign, Length, Space, Upper, Concat;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, ASSEMBLER;

VAR subdirs, ok: BOOLEAN;
    res: INTEGER;
    destpath: String;
    f1, f2: File;
    buf1, buf2: ARRAY [1..8192] OF CARDINAL;


PROCEDURE equal (a,b: ADDRESS; n: LONGCARD): BOOLEAN;
  VAR r: BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  a(A6),A0
        MOVE.L  b(A6),A1
        MOVE.L  n(A6),D0
        MOVEQ   #0,D1
        BRA     l
     l2 SWAP    D0
     l1 CMPM.B  (A0)+,(A1)+
     l  DBNE    D0,l1
        BNE     f
        SWAP    D0
        DBRA    D0,l2
        MOVE.B  -1(A0),D0
        CMP.B   -1(A1),D0
     f  SEQ     D0
        ANDI    #1,D0
        MOVE    D0,r(A6)
    END;
    RETURN r
  END equal;

PROCEDURE error (s, m: ARRAY OF CHAR);
  BEGIN
    WriteLn;
    WriteString (s);
    WriteString (Space (60-INTEGER(Length(s))));
    Write (' ');
    WriteString (m)
  END error;

PROCEDURE checkFile (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR source, dest: String;
      n, n1: LONGCARD;

  BEGIN
    Concat (path, entry.name, source, ok);

    Open (f1, source, readOnly);
    IF State (f1) < 0 THEN
      error (source, 'Open error');
      RETURN TRUE
    END;
    
    Concat (destpath, entry.name, dest, ok);
    Open (f2, dest, readOnly);
    IF State (f2) < 0 THEN
      error (dest, 'Open error');
      Close (f1);
      RETURN TRUE
    END;
    
    IF FileSize (f1) <> FileSize (f2) THEN
      error (source, 'Different sizes');
      Close (f1);
      Close (f2);
      RETURN TRUE
    ELSE
      n:= SIZE (buf1);
      LOOP
        ReadBytes (f1, ADR (buf1), n, n1);
        ReadBytes (f2, ADR (buf2), n, n);
        IF n <> n1 THEN
          error (entry.name, 'Read error');
          Close (f1);
          Close (f2);
          RETURN TRUE
        ELSIF n=0L THEN
          EXIT
        ELSIF ~equal (ADR (buf1), ADR (buf2), n) THEN
          error (source, 'Not equal');
          Close (f1);
          Close (f2);
          RETURN TRUE
        END
      END;
    END;
(*
    WriteLn;
    WriteString ('OK: ');
    WriteString (path);
    WriteString (entry.name);
*)
    Close (f1);
    Close (f2);
    RETURN TRUE
  END checkFile;

PROCEDURE checkDir (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR lastpath, source: String;

  BEGIN
    IF subdirAttr IN entry.attr THEN
      IF entry.name[0] # '.' THEN
        Concat (path, entry.name, source, ok);
        WriteLn;
        WriteString ('// Path ');
        WriteString (source);
        Append ('\*.*', source, ok);
        lastpath:= destpath;
        Append (entry.name, destpath, ok);
        Append ('\', destpath, ok);
        DirQuery (source, QueryFiles, checkFile, res);
        Close (f1);
        Close (f2);
        DirQuery (source, QueryAll, checkDir, res);
        destpath:= lastpath;
        IF res < 0 THEN
          error (source, "Can't access subdir");
        END
      END
    END;
    RETURN TRUE
  END checkDir;

PROCEDURE checkRes (): BOOLEAN;
  VAR ch: CHAR;
  BEGIN
    IF res < 0 THEN
      WriteLn;
      WriteString ('Error #');
      WriteInt (res,0);
      WriteLn;
      Read (ch);
      RETURN TRUE
    END;
    RETURN FALSE
  END checkRes;

VAR     argv: ARRAY [0..3] OF PtrArgStr;
        argc: CARDINAL;
        n1: String;
        ch: CHAR;

BEGIN
  InitArgCV ( argc, argv );
  IF argc > 2 THEN
    Assign (argv[1]^, n1, ok);
    Assign (argv[2]^, destpath, ok);
    subdirs:= argc > 3
  ELSE
    WriteString ('First folder  ? ');
    ReadString (n1);
    IF Empty (n1) THEN RETURN END;
    WriteString ('Second folder ? ');
    ReadString (destpath);
    IF Empty (destpath) THEN RETURN END;
    subdirs:= TRUE
  END;
  
  ValidatePath (n1);
  ValidatePath (destpath);
  MakeFullPath (n1, res);
  IF checkRes () THEN RETURN END;
  MakeFullPath (destpath, res);
  IF checkRes () THEN RETURN END;
  WriteString ('// Path ');
  WriteString (n1);
  Append ('*.*', n1, ok);
  DirQuery (n1, QueryFiles, checkFile, res);
  IF checkRes () THEN RETURN END;
  Close (f1);
  Close (f2);
  IF subdirs THEN
    DirQuery (n1, QueryAll, checkDir, res);
    IF checkRes () THEN RETURN END;
  END;
  WriteLn;
  IF argc <= 2 THEN
    Read (ch)
  END
END CmpFiles.
