                                         (* Chapter 6 - Program 1 *)
MODULE Arrays;

FROM InOut IMPORT WriteString, WriteCard, WriteLn;

VAR Index       : CARDINAL;
    Automobiles : ARRAY [1..12] OF CARDINAL;

BEGIN   (* main program *)
   FOR Index := 1 TO 12 DO
      Automobiles[Index] := Index + 10;
   END;
   Automobiles[7] := 54;  (* example, change one value of array *)
   WriteString("This is the first program with an array.");
   WriteLn;
   WriteLn;                       (* end of data initialization *)

   FOR Index := 1 TO 12 DO              (* display the data now *)
      WriteString("Automobile number");
      WriteCard(Index,3);
      WriteString(" has the value of");
      WriteCard(Automobiles[Index],3);
      WriteLn;
   END;
END Arrays.
