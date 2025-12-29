IMPLEMENTATION MODULE VokabelExport;
FROM Btree IMPORT DataType;
FROM InOut IMPORT WriteString, WriteInt, WriteLn,Write;
FROM pString IMPORT SLEN;
FROM GEMDOS IMPORT PrnOS;
FROM DruckTreiber IMPORT (*ConfigPrinter,*) PrintFormFeed, PrintSteuer,
			 PrintString, (*PrintString4, PrintChar,*)
			 SetLQ, PrintLn;
			
VAR L, PageLines : INTEGER;

PROCEDURE InitPrinter(Lines, Style :INTEGER; Nlq : BOOLEAN): BOOLEAN;
BEGIN
  PageLines := Lines;
  IF (PrnOS()) THEN
	  PrintSteuer(21H,-1); (* Drucker Reset *)
	  SetLQ(Nlq);
	  PrintSteuer(Style,-1);
	  PrintSteuer(1FH,-1); (* Horizontal Init. *)
	  PrintSteuer(20H,-1); (* Vertikal Init. *)
	  PrintSteuer(24H,Lines); (* Form length in lines *)
	  RETURN TRUE
  ELSE
	RETURN FALSE
  END(*IF*);		
END InitPrinter;

PROCEDURE PrintProc(Data : DataType);
VAR i : INTEGER;
BEGIN
  (*IF (PrnOS()) THEN*) (* Nur mit Endlospapier drucken !!!*)
   PrintSteuer(6,-1); (* bold on *)
   PrintString(Data.Inhalt[0]);
   PrintSteuer(7,-1); (* bold off *)
   FOR i:=1 TO HIGH(Data.Inhalt) DO
      IF SLEN(Data.Inhalt[i])>0 THEN
	PrintString(Data.Inhalt[i]);
	PrintLn;
      END(*IF*);
   END(*FOR*);
   PrintLn;
  (* L := L+1;
   IF L =PageLines THEN
      PrintLn;
      PrintFormFeed;
      L:=0;
   ELSE
      PrintLn;
   END(*IF*); *)
(*  END(*IF*); *)
END PrintProc;

PROCEDURE IdeaList(Data: DataType);
VAR i : INTEGER;
BEGIN
   Write(33C);Write('A'); (* Fett an *)
   WriteString(Data.Inhalt[0]);WriteString(', ');
   Write(33C);Write('@'); (* fett aus *)
   FOR i:=1 TO HIGH(Data.Inhalt) DO
       IF SLEN(Data.Inhalt[i])>0 THEN
	  WriteString(Data.Inhalt[i]);WriteString(', ');
       END(*IF*);
   END(*FOR*);
   WriteLn;
END IdeaList;

PROCEDURE StTrans(Data: DataType);
VAR i : INTEGER;
BEGIN
   WriteString(Data.Inhalt[0]);WriteString(' '); WriteLn;
   WriteString('0 ');WriteLn;
   FOR i:=1 TO HIGH(Data.Inhalt) DO
       IF SLEN(Data.Inhalt[i])>0 THEN
	  WriteString(Data.Inhalt[i]);WriteLn;
       END(*IF*);
   END(*FOR*);
   WriteString('-----'); WriteLn;
END StTrans;

PROCEDURE VocMan(Data: DataType);
VAR i : INTEGER;
BEGIN
   FOR i:=0 TO HIGH(Data.Inhalt) DO
       IF SLEN(Data.Inhalt[i])>0 THEN
	  IF i>0 THEN
	     WriteInt(i,1);
	  END(*IF*);
	  WriteString(Data.Inhalt[i]);(*WriteInt(i+1,1);*)
       END(*IF*);
   END(*FOR*);	
   WriteLn;
END VocMan;

BEGIN
PageLines :=0; L:=0;
END VokabelExport.
