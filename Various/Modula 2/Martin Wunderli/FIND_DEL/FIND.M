(*****************************************************
 * TITEL      : Find                                 *
 * ZWECK      : Findet eine Datei auf dem Åber-      *
 *              gegebenen Laufwerk                   *
 * AUTOREN    : Martin Wunderli & Patrick Seemann    *
 * VERSION    : 1.0   											         *
 * SPRACHE    : MODULA-2 (MEGAMAX MODULA V1.0)       *
 *                        Compilerversion 3.6a       *
 *						  (c) 1992 MAXON Computer GmbH				 *
 *****************************************************)

(*$E MTP *)

MODULE Find;

FROM  ArgCV       IMPORT
  (* TYPES *) ArgStr, PtrArgStr,
  (* PROCS *) InitArgCV;

FROM  Directory   IMPORT
  (* TYPES *) FileAttr, FileAttrSet, DirEntry,
              DirQueryProc, Drive,
  (* PROCS *) DirQuery, Delete, DefaultDrive,
              StrToDrive, SetDefaultDrive;

FROM  FastStrings IMPORT
  (* PROCS *) Append, Assign, Length, Pos;
                         
FROM  Terminal    IMPORT
  (* PROCS *) WriteString, WriteLn, Read;

TYPE  str4          = ARRAY [0..3] OF CHAR;

VAR   Result        : INTEGER;
      Pattern, File : ArgStr;
      NewDrive      : str4;
      ArgC, i       : CARDINAL;
      ArgV          : ARRAY [0..2] OF PtrArgStr;
      AktDrive      : Drive;
      James         : CHAR;

(*****************************************************)

PROCEDURE TestIfFound ( (* in *) Pfad  : ARRAY OF CHAR;
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
                TestIfFound, Result);
    END (* IF *);
  ELSE
    IF (Pos (File, Entry.name) >= 0) THEN
      WriteString ("  Found: ");
      WriteString (Pfad);
      WriteString (Entry.name);
      WriteLn;
    END (* IF *);
  END (* IF *);
  RETURN TRUE
END TestIfFound;

(*****************************************************)

BEGIN
  NewDrive := "X:";
  Pattern := "\*.*";
  InitArgCV (ArgC, ArgV);
  IF ArgC = 3 THEN
    AktDrive := DefaultDrive();
    NewDrive[0] := CAP(ArgV[1]^[0]);
    SetDefaultDrive (StrToDrive (NewDrive));
    FOR i := 0 TO Length (ArgV[2]^) DO
      File [i] := CAP (ArgV[2]^[i]);
    END (* FOR i *);
    DirQuery (Pattern, FileAttrSet{subdirAttr},
              TestIfFound, Result);
    SetDefaultDrive (AktDrive);
  ELSE
    WriteString ("Usage: find <drive> <filename>");
    WriteLn;
  END (* IF *);
  WriteString ("Bitte Taste drÅcken!");
  Read (James);
END Find.
