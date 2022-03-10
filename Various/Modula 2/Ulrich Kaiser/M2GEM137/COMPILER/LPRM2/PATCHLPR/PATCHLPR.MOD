MODULE PatchLPR;
(* Programm ist dafÅr gedacht, das leidige Patch-Problem
   mit dem LPR-Modula und der crystal-Bibliothek von Ulrich
   Kaiser 'endgÅltig' zu lîsen.
   Alle zu patchenden Dateien mÅssen sich im gleichen Ver-
   zeichnis wie das Programm befinden.
   Sprache: LPR-Modula-2
   Version: 16.07.93   16:48
   Autor  : Jîrg Kantel, (c) 1993
   Programm ist nur fÅr den Einsatz mit crystal
   gedacht und darf nur zusammen mit crystal
   unter den dort angegeben Konditionen weiter-
   gegeben werden.
*)

FROM FileSystem IMPORT Response, File, Lookup, Close, SetPos, WriteChar;
FROM Filename   IMPORT Extension, filespec, parse;
FROM InOut      IMPORT Read, ReadString, WriteString, WriteLn;

CONST maxpatch = 10;

TYPE PatchRecord = RECORD
                     Name      : filespec;
                     Numbers   : CARDINAL;
                     PAdr      : ARRAY [1..5] OF LONGINT;
                   END;

     ToPatch = ARRAY[1..maxpatch] OF PatchRecord;

VAR Patches     : ToPatch;
    InFile      : File;
    InName      : filespec;
    PatchAdr    : ARRAY[1..6] OF CHAR;
    position    : LONGINT;
    w           : CHAR;
    Weiter      : BOOLEAN;
    c           : CHAR;
    i, j        : CARDINAL;

PROCEDURE Initialize;
BEGIN

   Patches[1].Name    := 'AAS.SBM';
   Patches[1].Numbers := 1;
   Patches[1].PAdr[1] := 0BH;

   Patches[2].Name    := 'AAS.OBM';
   Patches[2].Numbers := 1;
   Patches[2].PAdr[1] := 6H;

   Patches[3].Name    := 'APPLICAT.OBM';
   Patches[3].Numbers := 1;
   Patches[3].PAdr[1] := 6CH;

   Patches[4].Name    := 'COMPILE.OBM';
   Patches[4].Numbers := 2;
   Patches[4].PAdr[1] := 15996H;
   Patches[4].PAdr[2] := 18A74H;

   Patches[5].Name    := 'DEBUG.OBM';
   Patches[5].Numbers := 3;
   Patches[5].PAdr[1] := 0DAH;
   Patches[5].PAdr[2] := 314EH;
   Patches[5].PAdr[3] := 578AH;

   Patches[6].Name    := 'LINKER.OBM';
   Patches[6].Numbers := 1;
   Patches[6].PAdr[1] := 6CH;

   Patches[7].Name    := 'M2EDITOR.OBM';
   Patches[7].Numbers := 4;
   Patches[7].PAdr[1] := 5DDCH;
   Patches[7].PAdr[2] := 746CH;
   Patches[7].PAdr[3] := 8434H;
   Patches[7].PAdr[4] := 0B294H;

   Patches[8].Name    := 'M2SHELL.OBM';
   Patches[8].Numbers := 5;
   Patches[8].PAdr[1] := 0C4H;
   Patches[8].PAdr[2] := 48BEH;
   Patches[8].PAdr[3] := 5118H;
   Patches[8].PAdr[4] := 80D8H;
   Patches[8].PAdr[5] := 8DA0H;

   Patches[9].Name    := 'WINDOWBA.OBM';
   Patches[9].Numbers := 1;
   Patches[9].PAdr[1] := 56H;

   Patches[10].Name    := 'FILENAME.OBM';
   Patches[10].Numbers := 1;
   Patches[10].PAdr[1] := 40H;

   (* Hier kînnen bei Bedarf weitere Patch-Adressen hin, dann
    * darf aber nicht vergessen werden, den Range von Patches
    * (maxpatch) in der Typ-Deklaration zu Ñndern.
    * So kann zum Beispiel der Eintrag fÅr GRAPHIC.OBM - ist in
    * Holgers Patchlist, aber nicht auf meiner LPR-Diskette -
    * wie folgt aussehen:
    * Patches[11].Name    := 'GRAPHIC.OBM';
    * Patches[11].Numbers := 1;
    * Patches[11].PAdr[1] := 56H;
    *)
END Initialize;

BEGIN
   Weiter := TRUE;
   Initialize;
   WriteString('Patch-Programm fÅr LPR-Modula-2 und crystal'); WriteLn;
   WriteString('        (c) 1993 by Jîrg Kantel            '); WriteLn;
   WriteString('--------------------------------------------'); WriteLn;
   WriteLn;
   WriteString('Sind alle Dateien im gleichen Unterverzeich-'); WriteLn;
   WriteString('nis wie dieses Programm?             (j/n): ');
   Read(c); WriteLn;
   IF (c <> 'j') THEN Weiter := FALSE; END;
   WHILE Weiter DO
      FOR i := 1 TO maxpatch DO
         WITH Patches[i] DO
            InName := Name;
            Lookup(InFile, InName, FALSE);
            IF (InFile.res = done) THEN
               WriteString('File-Name ');
               WriteString(InName);
               WriteString(' in Arbeit...');
               WriteLn;
               FOR j := 1 TO Numbers DO
                  position := PAdr[j];
                  SetPos(InFile, position);
                  w := 'A';
                  WriteChar(InFile, w);
                  INC(position);
                  WriteChar(InFile, w);
                  INC(position);
                  w := 'S';
                  WriteChar(InFile, w);
                  Close(InFile);
               END; (* FOR j *)
            ELSE
               WriteString('Datei ');
               WriteString(InName);
               WriteString(' nicht gefunden ...');
               WriteLn;
            END; (* IF *)
         END; (* WITH *)
      END; (* FOR i *)
      Weiter := FALSE;
   END; (* WHILE *)
END PatchLPR.
