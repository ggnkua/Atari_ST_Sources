                                         (* Chapter 8 - Program 2 *)
MODULE SimplIn;

FROM InOut IMPORT WriteString, WriteCard, WriteLn, Write,
                  ReadString, ReadCard, Read, EOL;

VAR Count, Number : CARDINAL;
    List          : ARRAY[1..6] OF CARDINAL;
    StringOfData  : ARRAY[1..80] OF CHAR;
    Alpha         : CHAR;

BEGIN
                          (* Example of reading in a word at a time *)
   WriteString("Input three words of information.");
   WriteLn;
   FOR Count := 1 TO 3 DO                        (* Read 3 words in *)
      ReadString(StringOfData);
      WriteString("---->");
      WriteString(StringOfData);
      WriteLn;
   END;
                                    (* Example of character reading *)
   WriteLn;
   WriteString("Input 50 characters.");
   WriteLn;
   FOR Count := 1 TO 50 DO
      Read(Alpha);
      Write(Alpha);
   END;
   WriteLn;
                         (* Example of reading in a line at a time. *)
   WriteLn;
   WriteString("Input three lines of information.");
   WriteLn;
   FOR Count := 1 TO 3 DO                      (* count three lines *)
      Number := 1;
      REPEAT                (* repeat until an end-of-line is found *)
         Read(Alpha);
         Write(Alpha);
         IF Alpha <> EOL THEN
            StringOfData[Number] := Alpha;
            Number := Number + 1;
         END;
      UNTIL Alpha = EOL;
      StringOfData[Number] := 0C;        (* End of string indicator *)
      WriteString("---->");
      WriteString(StringOfData);
      WriteLn;
   END;
                          (* Example of reading CARDINAL numbers in *)
   WriteLn;
   WriteString("Enter 6 CARDINAL numbers.");
   WriteLn;
   FOR Count := 1 TO 6 DO
      ReadCard(List[Count]);
      WriteLn;                (* New line for separation of numbers *)
   END;
   WriteLn;
   FOR Count := 1 TO 6 DO             (* Now, write the numbers out *)
      WriteCard(List[Count],8);
   END;
   WriteLn;

END SimplIn.
