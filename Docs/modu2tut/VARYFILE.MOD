                                         (* Chapter 8 - Program 4 *)
MODULE VaryFile;

FROM FileSystem IMPORT Lookup, Close, File, Response, ReadChar;
FROM InOut      IMPORT Write, WriteString, ReadString, WriteLn;

VAR  NameOfFile : ARRAY[1..15] OF CHAR;
     InFile     : File;
     Character  : CHAR;

BEGIN
   REPEAT                  (* repeat until a good filename is found *)
      WriteLn;
      WriteString("Enter name of file to display ---> ");
      ReadString(NameOfFile);
      Lookup(InFile,NameOfFile,FALSE);
   UNTIL InFile.res = done;                  (* good filename found *)

   REPEAT       (* character read/display loop - quit at InFile.eof *)
      ReadChar(InFile,Character);
      IF NOT InFile.eof THEN
         Write(Character);
      END;
   UNTIL InFile.eof;                      (* quit when eof is found *)
   Close(InFile);

END VaryFile.
