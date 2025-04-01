(*****************************************************
 * TITEL      : DelBak                               *
 * ZWECK      : L”scht Backup-Dateien                *
 * AUTOREN    : Martin Wunderli & Patrick Seemann    *
 * VERSION    : 1.0        											     *
 * SPRACHE    : MODULA-2 (MEGAMAX MODULA V1.0)       *
 *                        Compilerversion 3.6a       *
 * 						  (c) 1992 MAXON Computer GmbH				 *
 *****************************************************)

(*$E MTP *)

MODULE DelBak;

FROM  ArgCV       IMPORT
  (* TYPES *) ArgStr, PtrArgStr,
  (* PROCS *) InitArgCV;

FROM  Directory   IMPORT
  (* TYPES *) FileAttr, FileAttrSet, DirEntry,
              DirQueryProc, Drive,
  (* PROCS *) DirQuery, Delete, DefaultDrive,
              StrToDrive, SetDefaultDrive;

FROM  FastStrings IMPORT
  (* PROCS *) Append, Assign, Pos;
                         
FROM  Terminal    IMPORT
  (* PROCS *) WriteString, WriteLn, Write, Read;


TYPE  str4          = ARRAY [0..3] OF CHAR;

VAR   Result        : INTEGER;
      Pattern       : ArgStr;
      NewDrive,
      BAK, DUP, SBK : str4;
      James         : CHAR;
      ArgC          : CARDINAL;
      ArgV          : ARRAY [0..1] OF PtrArgStr;
      AktDrive      : Drive;

(*****************************************************)

PROCEDURE TestIfBAK ( (* in *) Pfad  : ARRAY OF CHAR;
                      (* in *) Entry : DirEntry): 
                                               BOOLEAN;

VAR NeuerPfad : ArgStr;

BEGIN
  IF (subdirAttr IN Entry.attr) THEN
    IF NOT(Entry.name[0] = ".") THEN
      Assign (Pfad, NeuerPfad);
      Append (Entry.name,NeuerPfad);
      Append (Pattern, NeuerPfad);   
      DirQuery (NeuerPfad,FileAttrSet{subdirAttr},
                TestIfBAK, Result);
    END (* IF *);
  ELSE
    IF (Pos (BAK,Entry.name) >= 0) OR
       (Pos (DUP,Entry.name) >= 0) OR
       (Pos (SBK,Entry.name) >= 0) THEN
      Write (" ");
      WriteString (Pfad);
      WriteString (Entry.name);
      WriteString ("    L”schen (_/N)? ");
      Read (James);
      IF CAP(James) <> "N" THEN
        Assign (Pfad, NeuerPfad);
        Append (Entry.name,NeuerPfad);
        Delete (NeuerPfad,Result);
      END (* IF *);
      WriteLn;
    END (* IF *);
  END (* IF *);
  RETURN TRUE
END TestIfBAK;

(*****************************************************)

BEGIN
  Pattern := "\*.*";
  NewDrive := "X:";
  BAK := ".BAK";
  DUP := ".DUP";
  SBK := ".SBK";
  InitArgCV (ArgC, ArgV);
  IF ArgC = 2 THEN
    AktDrive := DefaultDrive();
    NewDrive[0] := CAP(ArgV[1]^[0]);
    SetDefaultDrive (StrToDrive (NewDrive));
    DirQuery (Pattern, FileAttrSet{subdirAttr},
              TestIfBAK, Result);
    SetDefaultDrive (AktDrive);
  ELSE
    WriteString (" Usage: delbak <drive>");
    WriteLn;
  END (* IF *);
END DelBak.
