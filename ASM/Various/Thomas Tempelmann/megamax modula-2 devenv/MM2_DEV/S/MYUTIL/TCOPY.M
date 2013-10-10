MODULE TCopy; (*$ E MTP *)

(* Kopiert Dateien mit Erhalt des Datums und Backup/Update-Option *)
(* Subdirs werden mitkopiert *)

 *!!! achtung: l„uft noch nicht richtig: der zielpfad wird noch nicht
 *  beim rekursiven DirQuery angepažt!

FROM SYSTEM IMPORT ADR;

IMPORT GEMDOSIO;

FROM InOut IMPORT WriteLn, Read, WriteString;

FROM ArgCV IMPORT PtrArgStr, InitArgCV;

FROM Clock IMPORT Time, Date, PackTime, PackDate, UnpackTime, UnpackDate;

FROM Directory IMPORT GetDirEntry, DirQuery, FileAttrSet,
        FileAttr, SetFileAttr, DirEntry;

FROM Files IMPORT File, Open, Create, Access, ReplaceMode, GetStateMsg,
        State, Close, SetDateTime;

FROM Binary IMPORT ReadBytes, WriteBytes;

FROM Strings IMPORT String, Upper, Compare, Relation;

FROM FuncStrings IMPORT ConcStr;


VAR     backup, update: BOOLEAN;
        argv: ARRAY [0..3] OF PtrArgStr;
        argc: CARDINAL;
        buf: ARRAY [1..$4000] OF CARDINAL; (* 32 KB *)


PROCEDURE showErr ( i: INTEGER );
  VAR msg: ARRAY [0..31] OF CHAR;
  BEGIN
    WriteLn;
    WriteString ('Fehler: ');
    GetStateMsg ( i, msg );
    WriteString ( msg );
    WriteLn;
  END showErr;


PROCEDURE query ( REF path: ARRAY OF CHAR; entry: DirEntry ): BOOLEAN;
  VAR dname: String; exist: BOOLEAN; destentry: DirEntry;
      ch: CHAR; sf, df: File; n: LONGCARD; res: INTEGER;
  BEGIN
    IF (subdirAttr IN entry.attr) THEN
      IF entry.name [0] # '.' THEN
        DirQuery (ConcStr (path, '*.*'), FileAttrSet {}, query, res );
        IF res < 0 THEN showErr (res) END
      END
    ELSIF NOT (volLabelAttr IN entry.attr) THEN
      dname:= ConcStr (argv[2]^, entry.name);
      GetDirEntry (dname, destentry, res);
      exist:= res >= 0;
      IF ( backup AND NOT exist )
      OR NOT ( update OR backup )
      OR ( exist AND (   65636 * LONG(PackDate(entry.date))
                               + LONG(PackTime(entry.time))
                       > 65636 * LONG(PackDate(destentry.date))
                               + LONG(PackTime(destentry.time)) ) )
      THEN
        WriteString (dname);
        IF exist & NOT backup & NOT update THEN
          WriteString ('  existiert bereits. Ersetzen? (J/N) ');
          Read (ch);
          IF CAP (ch) # 'J' THEN
            RETURN TRUE
          END
        END;
        (* kopieren *)
        WriteLn;
        Open (sf, ConcStr (path, entry.name), readOnly);
        Create (df, dname, writeOnly, replaceOld);
        LOOP
          ReadBytes (sf, ADR (buf), SIZE (buf), n);
          IF n=0L THEN EXIT END;
          WriteBytes (df, ADR (buf), n)
        END;
        Close (df);
        IF State (df) < 0 THEN showErr ( State (df) ); RETURN TRUE END;
        Close (sf);
        Open (df, dname, readWrite);
        SetDateTime (df, entry.date, entry.time);
        Close (df);
        SetFileAttr (dname, entry.attr, res);
      END
    END;
    RETURN TRUE
  END query;


PROCEDURE usage;
  BEGIN
    WriteLn;
    WriteString ('Aufruf: TCOPY quellDateien zielPfad [-U|-B]');
    WriteLn;
    WriteString ('        Kopiert mit Beibehaltung des Datums.');
    WriteLn;
    WriteString ('        -U kopiert nur die Dateien, die auf Zielpfad neueren Datums sind.');
    WriteLn;
    WriteString ("        -B wie '-U', zus„tzlich Dateien, die auf Zielpfad nicht existieren.");
    WriteLn;
  END usage;


VAR     result: INTEGER;
        c: CHAR;

BEGIN
  InitArgCV ( argc, argv );
  IF argc > 2 THEN
    Upper ( argv[3]^ );
    IF Compare (argv[3]^, '-U') = equal THEN
      update:= TRUE
    ELSIF Compare (argv[3]^, '-B') = equal THEN
      backup:= TRUE
    END;
    DirQuery ( argv[1]^, FileAttrSet {}, query, result );
    IF result < 0 THEN showErr ( result ) END
  ELSE
    usage
  END;
END TCopy.

(* $FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$000006AB$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66$FFF8CD66€$00000088T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000008F0$FFEE94CA$000008B3$00000125$000000F6$00000088$FFEE94D8$FFEE94D8$00000626$000006A8$000001F1$000006C0$0000069E$000006E3$0000069F$000008B4˜€€*)
