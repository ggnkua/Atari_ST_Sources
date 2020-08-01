                                         (* Chapter 5 - Program 4 *)
MODULE Proced4;

FROM InOut IMPORT WriteString, WriteCard, WriteLn;

VAR Count : CARDINAL;
    Index : CARDINAL;
    Other : CARDINAL;

PROCEDURE PrintSomeData;
VAR Count : CARDINAL;
    Apple : CARDINAL;
BEGIN
   Count := 7;
   Other := 12;
   Apple := 32;
   WriteString("In PrintSomeData the variables are");
   WriteCard(Index,5);
   WriteCard(Count,5);
   WriteCard(Other,5);
   WriteCard(Apple,5);
   WriteLn;
END PrintSomeData;

BEGIN    (* Main program *)
   FOR Index := 1 TO 3 DO
      Count := Index;
      Other := Index;
         WriteString("In Main Program the variables are ");
         WriteCard(Index,5);
         WriteCard(Count,5);
         WriteCard(Other,5);
         WriteLn;
      PrintSomeData;
         WriteString("In Main Program the variables are ");
         WriteCard(Index,5);
         WriteCard(Count,5);
         WriteCard(Other,5);
         WriteLn;
      WriteLn;
   END;  (* of FOR loop *)
END Proced4.
