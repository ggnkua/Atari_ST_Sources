MODULE CmpMM2;

IMPORT TOSIO; (*$E MOS *)

FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, Read, ReadString;

IMPORT Paths, ShellMsg;

FROM Files IMPORT File, Access, Open, Close, State;

FROM Binary IMPORT FileSize, ReadBytes;

FROM Directory IMPORT MakeFullPath, ValidatePath, DirQuery, DirEntry,
        QueryFiles, QueryAll, subdirAttr, FileAttrSet;

FROM Strings IMPORT String, Empty, Append, Assign, Length, Space, Upper, Concat;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, ASSEMBLER;

VAR subdirs, ok: BOOLEAN;
    res: INTEGER;
    f1, f2: File;
    buf1, buf2: ARRAY [1..$8000] OF CARDINAL;
    line: CARDINAL;


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
  VAR ch: CHAR;
  BEGIN
    WriteLn;
    WriteString (s);
    WriteString (Space (60-INTEGER(Length(s))));
    Write (' ');
    WriteString (m);
    INC (line);
    IF line > 20 THEN
      Read (ch);
      line:= 1
    END;
  END error;

PROCEDURE checkFile (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR source, dest: String;
      n, n1: LONGCARD;
      first: BOOLEAN;
      paths: Paths.PathList;

  BEGIN
    Concat (path, entry.name, source, ok);
    IF subdirAttr IN entry.attr THEN
      IF entry.name[0] # '.' THEN
        Append ('\*.*', source, ok);
        DirQuery (source, QueryAll, checkFile, res);
        Close (f1);
        Close (f2);
        IF res < 0 THEN
          error (source, "Can't access subdir");
        END
      END
    ELSE
      paths:= Paths.StdPaths ();
      Paths.SearchFile (entry.name, paths, Paths.fromStart, ok, dest);
      first:= TRUE;
      WHILE ok DO
        Open (f1, source, readOnly);
        IF State (f1) < 0 THEN
          error (source, 'Open error');
          RETURN TRUE
        END;
        first:= FALSE;
        Open (f2, dest, readOnly);
        IF State (f2) < 0 THEN
          error (dest, 'Open error');
          Close (f1);
          RETURN TRUE
        END;
      
        IF FileSize (f1) <> FileSize (f2) THEN
          error (dest, 'Different sizes');
          Close (f1);
          Close (f2);
          RETURN TRUE
        ELSE
          n:= SIZE (buf1);
          LOOP
            ReadBytes (f1, ADR (buf1), n, n1);
            ReadBytes (f2, ADR (buf2), n, n);
            IF n <> n1 THEN
              error (dest, 'Read error');
              Close (f1);
              Close (f2);
              RETURN TRUE
            ELSIF n=0L THEN
              EXIT
            ELSIF ~equal (ADR (buf1), ADR (buf2), n) THEN
              error (dest, 'Not equal');
              Close (f1);
              Close (f2);
              RETURN TRUE
            END
          END;
        END;
        Close (f1);
        Close (f2);
        Paths.SearchFile (entry.name, paths, Paths.fromNext, ok, dest);
      END;
      IF first THEN
        error (source, 'Not found');
      END;
    END;
    RETURN TRUE
  END checkFile;

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

VAR     n1: String;
        ch: CHAR;

BEGIN
  Paths.SetHomePath (ShellMsg.HomePath);
  WriteString ('Compare MM2'); WriteLn;
  WriteLn;
  WriteString ('Compares all files on Disk in A: with same on StdPaths()');
  LOOP
    WriteLn;
    WriteLn;
    WriteString ('Insert next Disk and press <Return> (<Esc> to stop)...');
    REPEAT
      Read (ch);
      IF ch = 33C THEN EXIT END;
    UNTIL ch = 15C;
    WriteLn;
    line:= 1;
    DirQuery ('A:\*.*', QueryAll, checkFile, res);
    Close (f1);
    Close (f2);
    IF checkRes () THEN RETURN END;
  END
END CmpMM2.
