                                         (* Chapter 4 - Program 3 *)
MODULE LoopIf;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR Index, Count, Dog : INTEGER;

BEGIN
   FOR Index := 1 TO 10 DO
      WriteString("Major loop");
      WriteInt(Index,3);
      IF Index < 7 THEN
         FOR Count := 15 TO (15 + Index) DO
            WriteString(' XXX');
         END;
         WriteLn;
      ELSE
         WriteString(' How many dogs?');
         FOR Dog := 1 TO 10 - Index DO
            WriteString("  too many");
         END;
         WriteLn;
      END;  (* ELSE part of IF statement *)

   END (* Major FOR loop *)
END LoopIf.
