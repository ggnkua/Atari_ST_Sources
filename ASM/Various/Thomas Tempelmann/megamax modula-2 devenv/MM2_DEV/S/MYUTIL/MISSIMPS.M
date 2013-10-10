MODULE MissingIMPs;
(*$E MOS *)

(*
 * sieht sich IMP-Dir an und meldet, welche Module davon nicht in
 * der shell resident sind.
 * wird benîtigt, um IMP-Ordner auf WORK-Disk fÅr Tiny-Shell zu vervoll-
 * stÑndigen
 *)

FROM SYSTEM IMPORT ADR;
IMPORT GEMDOSIO;

FROM InOut IMPORT
  OpenOutput,
  WriteLn, WriteString, ReadString, Write, Read, WriteInt, BusyRead;

IMPORT ModBase;

FROM Files IMPORT GetStateMsg;

FROM Files IMPORT File, Access, Open, Close, Create, State,
        noReplace, GetDateTime, SetDateTime;

FROM MOSGlobals IMPORT fFileExists, Date, Time;

FROM Binary IMPORT FileSize, WriteBytes, ReadBytes;

FROM Directory IMPORT MakeFullPath, DirQuery, DirEntry,
        QueryFiles, QueryAll, subdirAttr, FileAttrSet;

FROM Strings IMPORT
  Space, Length, String, Concat, Empty;


PROCEDURE error (res: INTEGER);
  VAR s: String;
  BEGIN
    GetStateMsg (res, s);
    WriteString (s);
  END error;

VAR destPath: String;
buf: ARRAY [1..$8000] OF CARDINAL;

PROCEDURE delEntry (REF path: ARRAY OF CHAR; e: DirEntry): BOOLEAN;

  VAR res: INTEGER; p,p2: String; ok: BOOLEAN; ch: CHAR;
        resident: BOOLEAN;
        mname: String; ref: ModBase.ModRef;
        n: LONGCARD;
        dat2: Date; tim2: Time; fOld, fNew: File;
  
  BEGIN
    Concat (path, e.name, p, ok);
    Concat (destPath, e.name, p2, ok);
    WriteLn;
    WriteString (e.name);
    resident:= FALSE;
    IF ModBase.ModLoaded (e.name, FALSE, mname, ref) THEN
      IF ModBase.linked IN ref^.state THEN
        resident:= TRUE
      END
    END;
    IF resident THEN
    ELSE
      
      Open (fOld, p, readOnly);
      GetDateTime (fOld, dat2, tim2);
      IF State (fOld) < 0 THEN
        HALT
      END;
      Create (fNew, p2, writeOnly, noReplace);
      IF State (fNew) = fFileExists THEN
        WriteString (' exists');
      ELSIF State (fNew) < 0 THEN
        HALT
      ELSE
        LOOP
          ReadBytes (fOld, ADR (buf), SIZE (buf), n);
          IF n=0L THEN EXIT END;
          WriteBytes (fNew, ADR (buf), n)
        END;
        Close (fNew);
        Open (fNew, p2, writeOnly);
        SetDateTime (fNew, dat2, tim2);
        Close (fNew);
      END;
      Close (fOld);
      
    END;
    RETURN TRUE
  END delEntry;

VAR s: String;
    ch: CHAR;
    res: INTEGER;

BEGIN
  (*
  OpenOutput ('TXT');
  *)
  LOOP
    (*
    WriteString ('Dateien? ');
    ReadString (s);
    *)
    s:= 'j:\linker\sys\imp\*.imp';
    IF Empty (s) THEN EXIT END;
    (*
    WriteString ('Dest-Path? ');
    ReadString (destPath);
    *)
    destPath:= 'f:\tmp\imp\';
    DirQuery (s, FileAttrSet {}, delEntry, res);
    WriteLn;
    IF res < 0 THEN
      error (res);
      WriteLn
    END;
    WriteLn;
    EXIT
  END
END MissingIMPs.
