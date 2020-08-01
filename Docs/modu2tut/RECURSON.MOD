                                         (* Chapter 5 - Program 7 *)
MODULE Recurson;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR Count : INTEGER;

PROCEDURE PrintAndDecrement(Index : INTEGER);
BEGIN
   WriteString("The value of the Index is");
   WriteInt(Index,5);
   WriteLn;
   Index := Index - 1;
   IF Index > 0 THEN
      PrintAndDecrement(Index);
   END;
END PrintAndDecrement;

BEGIN    (* Main program *)
   Count := 7;
   PrintAndDecrement(Count);
END Recurson.
