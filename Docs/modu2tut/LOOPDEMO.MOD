                                         (* Chapter 4 - Program 1 *)
MODULE LoopDemo;

FROM InOut IMPORT WriteString, WriteInt, WriteLn, Write;

CONST Where = 11;

VAR  Index   : INTEGER;
     What    : INTEGER;
     Letter  : CHAR;

BEGIN

   WriteString("REPEAT loop     = ");
   Index := 0;
   REPEAT
     Index := Index + 1;
     WriteInt(Index,5);
   UNTIL Index = 5;          (* This can be any BOOLEAN expression *)
   WriteLn;

   WriteString("WHILE loop      = ");
   Index := 0;
   WHILE Index < 5 DO        (* This can be any BOOLEAN expression *)
      Index := Index + 1;
      WriteInt(Index,5);
   END;
   WriteLn;

   WriteString("First FOR loop  = ");
   FOR Index := 1 TO 5 DO
      WriteInt(Index,5);
   END;
   WriteLn;

   WriteString("Second FOR loop = ");
   FOR Index := 5 TO 25 BY 4 DO
      WriteInt(Index,5);
   END;
   WriteLn;

(* Note - The four loops above could use a CARDINAL type variable
          in place of the INTEGER type variable Index.  The next 2
          examples must use an INTEGER type variable because it
          must be capable of storing a negative value.            *)

   WriteString("Third FOR loop  = ");
   FOR Index := 5 TO -35 BY -7 DO
      WriteInt(Index,5);
   END;
   WriteLn;

   What := 16;
   FOR Index := (What - 21) TO (What * 2) BY Where DO
      WriteString("Fourth FOR loop = ");
      WriteInt(Index,5);
      WriteLn;
   END;

(* Note - The next two loops are demonstrations of using a CHAR
          type variable to index a FOR loop.                      *)

   FOR Letter := "A" TO 'Z' DO
      Write(Letter);
   END;
   WriteLn;

   FOR Letter := 'z' TO 'a' BY -1 DO
      Write(Letter);
   END;
   WriteLn;

(* Note - The following loop contains an EXIT which is a way to get
          out of the loop in the middle.                           *)

   Index := 1;
   LOOP
      WriteString("In the EXIT loop ");
      WriteInt(Index,5);
      IF Index = 5 THEN
         WriteLn;
         EXIT;
      END;
      WriteString("  We are still in the loop.");
      WriteLn;
      Index := Index + 1;
   END;

END LoopDemo.
