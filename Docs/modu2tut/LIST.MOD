MODULE List;   (* Program to list Modula-2 source files with page  *)
               (* numbers and line numbers.                        *)

FROM FileSystem IMPORT Lookup, Close, File, ReadChar, Response,
                       WriteChar;
FROM Conversions IMPORT ConvertCardinal;
FROM TimeDate IMPORT GetTime, Time;
IMPORT ASCII;
IMPORT InOut;

TYPE BigString   = ARRAY[1..80] OF CHAR;
     SmallString = ARRAY[1..25] OF CHAR;

VAR InFile     : File;          (* The Input File record            *)
    Printer    : File;          (* The Printer File record          *)
    NameOfFile : SmallString;   (* Storage for the filename         *)
    InputLine  : BigString;     (* The Input line of characters     *)
    LineNumber : CARDINAL;      (* The current line number          *)
    LinesOnPage : CARDINAL;     (* Number of Lines on this page     *)
    PageNumber  : CARDINAL;     (* Page Number                      *)
    Index       : CARDINAL;     (* Used locally in several proc's   *)
    Year,Day,Month     : CARDINAL;
    Hour,Minute,Second : CARDINAL;
    GoodFile    : BOOLEAN;

(* ************************************************ WriteCharString *)
(* Since there is no WriteString procedure in the FileSystem        *)
(* module, this procedure does what it would do.  It outputs a      *)
(* string until it comes to the end of it or until it comes to a    *)
(* character 0.                                                     *)
PROCEDURE WriteCharString(CharString : ARRAY OF CHAR);
BEGIN
   Index := 0;
   LOOP
      IF Index > HIGH(CharString) THEN EXIT END; (* Max = 80 chars  *)
      IF CharString[Index] = 0C THEN EXIT END;   (* If a 0C is found*)
      WriteChar(Printer,CharString[Index]);
      INC(Index);
   END;
END WriteCharString;


(* ************************************************* WriteLnPrinter *)
(* Since there is no WriteLn procedure in the FileSystem module,    *)
(* procedure does its job.                                          *)
PROCEDURE WriteLnPrinter;
CONST CRLF = 12C;
BEGIN
   WriteChar(Printer,CRLF);
END WriteLnPrinter;


(* ************************************************* GetFileAndOpen *)
(* This procedure requests the filename, receives it, and opens the *)
(* source file for reading and printing.  It loops until a valid    *)
(* filename is found.                                               *)
PROCEDURE GetFileAndOpen(VAR GoodFile : BOOLEAN);
BEGIN
   InOut.WriteLn;
   InOut.WriteString("Name of file to print ---> ");
   InOut.ReadString(NameOfFile);
   Lookup(InFile,NameOfFile,FALSE);
   IF InFile.res = done THEN
      GoodFile := TRUE;
      Lookup(Printer,"PRN",TRUE);            (* open printer as a file *)
   ELSE
      GoodFile := FALSE;
      InOut.WriteString("   File doesn't exist");
      InOut.WriteLn;
   END;
END GetFileAndOpen;


(* ***************************************************** Initialize *)
(* This procedure initializes some of the counters.                 *)
PROCEDURE Initialize;
VAR PackedTime : Time;
BEGIN
   LineNumber := 1;
   LinesOnPage := 0;
   PageNumber := 1;
   GetTime(PackedTime);
   Day := PackedTime.day MOD 32;
   Month := PackedTime.day DIV 32;
   Month := Month MOD 16;
   Year := 1900 + PackedTime.day DIV 512;
   Hour := PackedTime.minute DIV 60;
   Minute := PackedTime.minute MOD 60;
   Second := PackedTime.millisec DIV 1000;
END Initialize;


(* *********************************************** PrintTimeAndDate *)
(* This procedure prints the time and date at the top of every page *)
PROCEDURE PrintTimeAndDate;
VAR OutChars : ARRAY[0..4] OF CHAR;
BEGIN
   WriteCharString("      ");
   ConvertCardinal(Hour,2,OutChars);
   WriteCharString(OutChars);
   WriteCharString(":");
   ConvertCardinal(Minute,2,OutChars);
   WriteCharString(OutChars);
   WriteCharString(":");
   ConvertCardinal(Second,2,OutChars);
   WriteCharString(OutChars);
   WriteCharString("  ");
   ConvertCardinal(Month,2,OutChars);
   WriteCharString(OutChars);
   WriteCharString("/");
   ConvertCardinal(Day,2,OutChars);
   WriteCharString(OutChars);
   WriteCharString("/");
   ConvertCardinal(Year,4,OutChars);
   WriteCharString(OutChars);
END PrintTimeAndDate;


(* *************************************************** OutputHeader *)
(* This procedure prints the filename at the top of each page along *)
(* with the page number.                                            *)
PROCEDURE OutputHeader;
VAR PageOut : ARRAY[1..4] OF CHAR;
BEGIN
   WriteCharString("   Filename --> ");
   WriteCharString(NameOfFile);
   WriteCharString("           ");
   PrintTimeAndDate;
   WriteCharString("   Page");
   ConvertCardinal(PageNumber,4,PageOut);
   WriteCharString(PageOut);
   WriteLnPrinter;
   WriteLnPrinter;
   INC(PageNumber);
END OutputHeader;


(* *************************************************** OutputFooter *)
(* This procedure outputs 8 blank lines at the bottom of each page. *)
PROCEDURE OutputFooter;
BEGIN
   FOR Index := 1 TO 8 DO
      WriteLnPrinter;
   END;
END OutputFooter;


(* ******************************************************* GetALine *)
(* This procedure inputs a line from the source file.  It quits when*)
(* it finds an end-of-line, an end-of-file, or after it gets 80     *)
(* characters.                                                      *)
PROCEDURE GetALine;
VAR LocalChar : CHAR;
BEGIN
   FOR Index := 1 TO 80 DO      (* clear the input area so that the *)
      InputLine[Index] := 0C;   (* search for 0C will work.         *)
   END;

   Index := 1;
   LOOP
      ReadChar(InFile,LocalChar);
      IF InFile.eof THEN EXIT END;
      InputLine[Index] := LocalChar;
      IF LocalChar = ASCII.EOL THEN EXIT END;
      INC(Index);
      IF Index = 81 THEN EXIT END;
   END;
END GetALine;


(* ***************************************************** OutputLine *)
(* Output a line of test with the line number in front of it, after *)
(* checking to see if the page is full.                             *)
PROCEDURE OutputLine;
VAR Count       : CARDINAL;
    CardOutArea : ARRAY[1..8] OF CHAR;
BEGIN
   INC(LinesOnPage);
   IF LinesOnPage > 56 THEN
      OutputFooter;
      OutputHeader;
      LinesOnPage := 1;
   END;
   ConvertCardinal(LineNumber,6,CardOutArea);
   INC(LineNumber);
   WriteCharString(CardOutArea);
   WriteCharString("  ");
   WriteCharString(InputLine);
END OutputLine;


(* *************************************************** SpacePaperUp *)
(* At the end of the listing, space the paper up so that a new page *)
(* is ready for the next listing.                                   *)
PROCEDURE SpacePaperUp;
VAR Count : CARDINAL;
BEGIN
   Count := 64 - LinesOnPage;
   FOR Index := 1 TO Count DO
      WriteLnPrinter;
   END;
   Close(InFile);
   Close(Printer);
END SpacePaperUp;


(* *************************************************** Main Program *)
(* This is nothing more than a big loop.  It needs no comment.      *)
BEGIN
   GetFileAndOpen(GoodFile);
   IF GoodFile THEN
      Initialize;
      OutputHeader;
      REPEAT
         GetALine;
         IF NOT InFile.eof THEN
            OutputLine;
         END;
      UNTIL InFile.eof;
      SpacePaperUp;
   END;
END List.
