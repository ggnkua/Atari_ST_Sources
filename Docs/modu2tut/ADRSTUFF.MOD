                                        (* Chapter 14 - Program 3 *)
MODULE AdrStuff;

FROM InOut   IMPORT WriteInt, WriteLn;
FROM SYSTEM  IMPORT ADR, SIZE, TSIZE, ADDRESS;

TYPE IntArray = ARRAY[1..8] OF INTEGER;
     BigArray  = ARRAY[1..5] OF IntArray;

VAR  Stuff     : BigArray;
     NeatPoint : ADDRESS;
     IncreAmt  : CARDINAL;
     Index     : INTEGER;
     Count     : INTEGER;
     Amount    : INTEGER;

BEGIN
                              (* Load the array with nonsense data *)
   FOR Index := 1 TO 8 DO
      FOR Count := 1 TO 5 DO
         Stuff[Count][Index] := Index + 10 * Count;
      END;
   END;
                         (* Perform some simple pointer operations *)
   NeatPoint := ADR(Stuff[1][1]);
   Index := INTEGER(NeatPoint^);
   WriteInt(Index,6);
   IncreAmt := TSIZE(IntArray);
   NeatPoint := NeatPoint + IncreAmt;
   Index := INTEGER(NeatPoint^);
   WriteInt(Index,6);
   WriteLn;
                      (* Perform some pointer operations in a loop *)
   Count := INTEGER(TSIZE(BigArray)) DIV INTEGER(TSIZE(IntArray));
   FOR Index := 1 TO Count DO
      NeatPoint := ADR(Stuff[1][1]) +
                     CARDINAL((Index-1)*(INTEGER(TSIZE(IntArray))));
      Amount := INTEGER(NeatPoint^);
      WriteInt(Amount,6);
   END;

   IncreAmt := SIZE(Stuff);
   Count := INTEGER(SIZE(NeatPoint));

END AdrStuff.
