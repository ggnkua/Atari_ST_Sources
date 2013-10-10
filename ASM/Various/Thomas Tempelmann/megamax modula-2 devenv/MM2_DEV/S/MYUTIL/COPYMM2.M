MODULE CopyMM2;

(*
 * 20.11.90: Kopiert auch, wenn Datum gleich, aber LÑnge ungleich
 * 07.12.90: énd. v. 20.11. wieder raus, da sonst schon komprimierte
 *           Dateien erneut kopiert werden.
 * 13.12.90: Tiny-Shell-Dateien M2B/M2P nicht kopiert
 * 25.02.91: kopiert nur Dateien mit gesetzten Archiv-Bit, lîscht dann das Bit.
 *)

IMPORT GEMDOSIO; (*$E MOS *)

FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, Read, ReadString,
        WritePg, CloseOutput, OpenOutput;

FROM Paths IMPORT SearchFile, ListPos;
FROM PathEnv IMPORT HomePath;

FROM ShellMsg IMPORT ShellPath, StdPaths;

FROM Files IMPORT File, Access, Open, Close, Create, State,
        replaceOld, GetDateTime, SetDateTime;

FROM MOSGlobals IMPORT Date, Time, PfxStr, SfxStr;

FROM Clock IMPORT PackDate, PackTime;

FROM Binary IMPORT FileSize, WriteBytes, ReadBytes;

FROM Directory IMPORT MakeFullPath, DirQuery, DirEntry, SetFileAttr,
        GetFileAttr, QueryFiles, QueryAll, FileAttr, FileAttrSet;

FROM FileNames IMPORT ValidatePath, FilePrefix, FileSuffix;

FROM Strings IMPORT String, StrEqual, Append, Assign, Length, Space, Upper,
        Concat;

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, ASSEMBLER;

VAR protToFile, clearArchivBit, fullCompare, checkOnly, subdirs, ok: BOOLEAN;
    reason: CHAR;
    res: INTEGER;
    fDest, fSrc: File;
    buf, buf2: ARRAY [1..$8000] OF CARDINAL;

PROCEDURE error (s, m: ARRAY OF CHAR);
  VAR ch: CHAR;
  BEGIN
    WriteLn;
    WriteString (s);
    Write (' ');
    WriteString (m);
    IF ~protToFile THEN
      Read (ch);
    END
  END error;

PROCEDURE checkFile (REF path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

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
  
  PROCEDURE filesEqual (f1, f2: File): BOOLEAN;
    VAR n, n1: LONGCARD;
    BEGIN
      n:= SIZE (buf);
      LOOP
        ReadBytes (f1, ADR (buf), n, n1);
        ReadBytes (f2, ADR (buf2), n, n);
        IF n <> n1 THEN
          RETURN FALSE
        ELSIF n=0L THEN
          EXIT
        ELSIF ~equal (ADR (buf), ADR (buf2), n) THEN
          RETURN FALSE
        END
      END;
      RETURN TRUE
    END filesEqual;

  VAR dest, src: String;
      pref: PfxStr;
      sfx: SfxStr;
      n: LONGCARD;
      opened, mustcopy: BOOLEAN;
      dat2, date: Date;
      tim2, time: Time;
      attr: FileAttrSet;

  BEGIN
    reason:= "?";
    Concat (path, entry.name, dest, ok);
    IF subdirAttr IN entry.attr THEN
      IF entry.name[0] # '.' THEN
        pref:= FilePrefix (entry.name);
        IF StrEqual ('ST_FPU', pref)
        OR StrEqual ('TT_FPU', pref)
        OR StrEqual ('PACKER', pref)
        OR StrEqual ('MAXIDISK', pref)
        OR StrEqual ('ASM68020', pref)
        OR StrEqual ('TEMPLMON', pref) THEN
          (* diese Dateien nicht kopieren *)
          WriteLn;
          WriteString ('*** Ignoring ');
          WriteString (dest);
          WriteString ('\ ***');
          RETURN TRUE
        END;
        Append ('\*.*', dest, ok);
        DirQuery (dest, QueryAll, checkFile, res);
        Close (fDest);
        Close (fSrc);
        IF res < 0 THEN
          error (dest, "Can't access subdir");
        END
      END
    ELSE
      IF StrEqual ('MM2DEF.M2L', entry.name)
      OR StrEqual ('MOS_DEF.TOS', entry.name)
      OR StrEqual ('GEM_DEF.TOS', entry.name)
      OR StrEqual ('MOS.TOS', entry.name)
      OR StrEqual ('UTILITY.TOS', entry.name)
      OR StrEqual ('LIB_SRC.TOS', entry.name)
      OR StrEqual ('MOS_DEF.LZH', entry.name)
      OR StrEqual ('GEM_DEF.LZH', entry.name)
      OR StrEqual ('MOS.LZH', entry.name)
      OR StrEqual ('UTILITY.LZH', entry.name)
      OR StrEqual ('LIB_SRC.LZH', entry.name)
      OR StrEqual ('LIB_SRC.TXT', entry.name)
      OR StrEqual ('LHARC.TTP', entry.name)
      OR StrEqual ('MM2CL1.TOS', entry.name)
      OR StrEqual ('MM2CL2.TOS', entry.name)
      OR StrEqual ('TEXTE.TOS', entry.name)
      OR StrEqual ('TEXTE.LZH', entry.name)
      OR StrEqual ('XREF.TXT', entry.name)
      OR StrEqual ('HD_INST.PRG', entry.name)
      OR StrEqual ('NRSC_ASH.PRG', entry.name)
      OR StrEqual ('NRSC.RSC', entry.name)
      OR StrEqual ('HINWEIS.TXT', entry.name)
      OR StrEqual ('MM2TINYS.M2B', entry.name)
      OR StrEqual ('MM2TINYS.M2P', entry.name)
      OR StrEqual ('MM2SHELL.M2B', entry.name)
      OR StrEqual ('MM2SHELL.M2P', entry.name) THEN
        (* diese Dateien nicht kopieren *)
        WriteLn;
        WriteString ('*** Ignoring ');
        WriteString (dest);
        WriteString (' ***');
        RETURN TRUE
      END;
      SearchFile (entry.name, StdPaths, fromStart, ok, src);
      IF ok THEN
        GetFileAttr (src, attr, res);
        sfx:= FileSuffix (entry.name);
        opened:= FALSE;
        IF fullCompare
        OR StrEqual ('IMP', sfx)
        OR StrEqual ('MOD', sfx) THEN
          Open (fSrc, src, readOnly);
          IF State (fSrc) < 0 THEN error (src, 'Open error'); RETURN TRUE END;
          opened:= TRUE;
          Open (fDest, dest, readOnly);
          IF State (fDest) < 0 THEN error (dest, 'Open error'); RETURN TRUE END;
          GetDateTime (fSrc, date, time);
          GetDateTime (fDest, dat2, tim2);
          mustcopy:= FALSE;
          IF (PackDate (date) # PackDate (dat2))
          OR (PackTime (time) # PackTime (tim2)) THEN
            reason:= "T";
            mustcopy:= TRUE;
          ELSIF (FileSize (fSrc) # FileSize (fDest)) THEN
            reason:= "S";
            mustcopy:= TRUE;
          ELSIF fullCompare & ~filesEqual (fSrc, fDest) THEN
            reason:= "C";
            mustcopy:= TRUE;
          END;
          Close (fDest);
          IF NOT mustcopy THEN Close (fSrc) END;
        ELSE
          mustcopy:= archiveAttr IN attr;
          reason:= "A";
        END;
        IF ~mustcopy THEN
          IF clearArchivBit & (archiveAttr IN attr) THEN
            SetFileAttr (src, attr - FileAttrSet {archiveAttr}, res);
          END
        ELSE
          WriteLn;
          WriteString ('Update ');
          WriteString (dest);
          WriteString (Space (34-INTEGER(Length(dest))));
          WriteString (' from ');
          WriteString (src);
          WriteString (' (');
          Write (reason);
          Write (')');
          IF checkOnly THEN
            IF opened THEN Close (fSrc) END;
          ELSE
            IF ~opened THEN
              Open (fSrc, src, readOnly);
              IF State (fSrc) < 0 THEN error (src, 'Open error'); RETURN TRUE END;
            END;
            GetDateTime (fSrc, date, time);
            Create (fDest, dest, writeOnly, replaceOld);
            LOOP
              ReadBytes (fSrc, ADR (buf), SIZE (buf), n);
              IF n=0L THEN EXIT END;
              WriteBytes (fDest, ADR (buf), n)
            END;
            Close (fDest);
            IF State (fDest) < 0 THEN error (dest, 'Close error'); RETURN TRUE END;
            Open (fDest, dest, writeOnly);
            SetDateTime (fDest, date, time);
            Close (fDest);
            Close (fSrc);
            SetFileAttr (src, attr - FileAttrSet {archiveAttr}, res);
          END
        END
      ELSE
        error (src, 'Not found!');
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
      IF ~protToFile THEN
        Read (ch);
      END;
      RETURN TRUE
    END;
    RETURN FALSE
  END checkRes;

PROCEDURE Yes (): BOOLEAN;
  VAR ch: CHAR;
  BEGIN
    REPEAT
      Read (ch);
    UNTIL (CAP(ch) = 'J') OR (CAP(ch) = 'Y') OR (CAP(ch) = 'N');
    RETURN (CAP(ch) # 'N')
  END Yes;
  
VAR     n1: String;
        ch: CHAR;

BEGIN
  HomePath:= ShellPath;
  WriteString ('Copy MM2'); WriteLn;
  WriteString ('Updates all files on F:\MASTER\ from same on StdPaths()');
  WriteLn;
  WriteString ('>> Wurde auch der GME neu Åbersetzt?!');
  WriteLn;
  WriteLn;
  WriteString ('Dateiinhalt vergleichen (sonst nur Archivbit) (J/N)? ');
  fullCompare:= Yes ();
  WriteLn;
  WriteString ('Wirklich kopieren (sonst nur Vergleich) (J/N)? ');
  checkOnly:= NOT Yes ();
  IF fullCompare & checkOnly THEN
    WriteLn;
    WriteString ('Archiv-Bit bei identischen Dateien lîschen (J/N)? ');
    clearArchivBit:= Yes ();
  ELSE
    clearArchivBit:= FALSE
  END;
  WriteLn;
  WriteString ('Query J:\ (J/N)? ');
  IF Yes () THEN
    WriteLn;
    WriteString ('Protokollausgabe in Datei (J/N)? ');
    protToFile:= Yes ();
    WriteLn;
    IF protToFile THEN
      OpenOutput ("TXT");
    END;
    DirQuery ('J:\*.*', QueryAll, checkFile, res);
    Close (fDest);
    Close (fSrc);
    IF checkRes () THEN END;
  END;
  WriteLn;
  WriteLn;
  WriteString ('Nicht vergessen:');
  WriteLn;
  WriteLn;
  WriteString ('- ggf. DEF-Files in MM2DEF komprimieren und in Libary packen.'); WriteLn;
  WriteString ('- PRGs komprimieren, Fast-Bits wieder setzen.'); WriteLn;
  WriteString ('- ST_FPU und TT_FPU kopieren.'); WriteLn;
  WriteString ('- Files in SRC\ komprimieren.'); WriteLn;
  WriteString ('- LIB_SRC.TXT updaten.'); WriteLn;
  WriteString ('- PrÅfen, ob M2P-Datei noch korrektes Format hat.'); WriteLn;
  IF protToFile THEN
    protToFile:= FALSE;
    CloseOutput ();
  END;
  WriteLn;
  WriteString ('Fertig.');
  Read (ch);
END CopyMM2.
