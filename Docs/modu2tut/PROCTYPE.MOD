                                         (* Chapter 13 - Program 5 *)
MODULE ProcType;

FROM InOut IMPORT WriteString, WriteLn;

VAR OutputStuff : PROCEDURE(ARRAY OF CHAR);
    VarLine     : ARRAY[0..50] OF CHAR;

     PROCEDURE WriteWithNote(InString : ARRAY OF CHAR);
     BEGIN
        WriteString("Written with a note ---> ");
        WriteString(InString);
        WriteLn;
     END WriteWithNote;

     PROCEDURE WriteWithComment(InputLine : ARRAY OF CHAR);
     BEGIN
        WriteString(InputLine);
        WriteString(" <--- Written with a comment");
        WriteLn;
     END WriteWithComment;

BEGIN
   VarLine := "This is a line of data.";
                                        (* This uses WriteWithNote *)
   OutputStuff := WriteWithNote;
   OutputStuff(VarLine);
   OutputStuff("Extra output ");
                                      (* This uses WiteWithComment *)
   OutputStuff := WriteWithComment;
   OutputStuff(VarLine);
                                          (* This uses WriteString *)
   OutputStuff := WriteString;
   OutputStuff(VarLine);
   OutputStuff(" End of the line");
   WriteLn;
               (* The Procedures can be used in normal fashion too *)
   WriteLn;
   WriteWithNote("This is straight output.");
   WriteWithComment("This too is straight output.");
   WriteString(VarLine);
END ProcType.

