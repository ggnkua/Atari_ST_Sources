                                         (* Chapter 4 - Program 2 *)
MODULE IfDemo;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR Index1 : INTEGER;

BEGIN

   FOR Index1 := 1 TO 8 DO
      IF Index1 < 4 THEN                   (* Simple IF statement *)
         WriteString("Index1 is less than 4.");
         WriteInt(Index1,4);
         WriteLn;
      END;  (* end of first IF statement *)

      IF Index1 = 5 THEN                   (* two way IF statement *)
         WriteString("Index1 is 5");
      ELSE
         WriteString("Index1 is not 5");
      END;  (* end of second IF statement *)
      WriteLn;

      IF Index1 = 2 THEN              (* multiple way IF statement *)
         WriteString("Index1 is 2");
      ELSIF Index1 = 6 THEN
         WriteString("Index1 is 6");
      ELSE
         WriteString("I really don't care what Index1 is");
      END;  (* end of third IF statement *)
      WriteLn;
   END;  (* of big FOR loop *)

END IfDemo.
