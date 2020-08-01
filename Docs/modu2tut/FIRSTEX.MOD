MODULE FirstEx;

FROM InOut IMPORT WriteLn, WriteString, WriteCard;

VAR Index : CARDINAL;

BEGIN

   WriteString("This is our first example program");
   WriteLn;
   WriteLn;
   FOR Index := 1 TO 12 DO
      WriteString("The value of the index is now ");
      WriteCard(Index,3);
      WriteLn;
   END

END FirstEx.
