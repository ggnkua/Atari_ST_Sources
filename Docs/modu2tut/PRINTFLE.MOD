                                         (* Chapter 8 - Program 5 *)
MODULE PrintFle;

FROM FileSystem IMPORT Lookup, Close, File, Response, ReadChar,
                       WriteChar;
FROM InOut      IMPORT Write, WriteString, ReadString, WriteLn;

VAR  NameOfFile : ARRAY[1..15] OF CHAR;
     InFile     : File;
     OutFile    : File;
     CapFile    : File;
     PrtFile    : File;
     Character  : CHAR;

BEGIN
   REPEAT                  (* repeat until a good filename is found *)
      WriteLn;
      WriteString("Enter name of file to display,");
      WriteString(" store, and print ---> ");
      ReadString(NameOfFile);
      Lookup(InFile,NameOfFile,FALSE);
   UNTIL InFile.res = done;                  (* good filename found *)

   Lookup(OutFile,"ANYNAME.TXT",TRUE);
   Lookup(CapFile,"CAPSONLY.TXT",TRUE);
   Lookup(PrtFile,"PRN",TRUE);

   WriteLn;
   REPEAT       (* character read/display loop - quit at InFile.eof *)
      ReadChar(InFile,Character);
      IF NOT InFile.eof THEN
         Write(Character);
         WriteChar(OutFile,Character);
         WriteChar(CapFile,CAP(Character));
         WriteChar(PrtFile,Character);
      END;
   UNTIL InFile.eof;                      (* quit when eof is found *)
   Close(InFile);
   Close(OutFile);
   Close(CapFile);
   Close(PrtFile);

END PrintFle.
