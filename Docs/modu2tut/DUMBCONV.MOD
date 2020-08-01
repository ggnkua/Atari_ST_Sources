                                        (* Chapter 4 - Program 5 *)
MODULE DumbConv;
FROM InOut IMPORT WriteString, WriteInt, WriteLn;
VAR a, b, c : INTEGER;
BEGIN
   WriteString("Farenheit to Centigrade temperature table");
   WriteLn;
   WriteLn;
   FOR a := -2 TO 12 DO
      b := 10 * a;
      c := 32 + b *9 DIV 5;
      WriteString("   C =");
      WriteInt(b,5);
      WriteString("     F =");
      WriteInt(c,5);
      IF b = 0 THEN
         WriteString("   Freezing point of water");
      END;
      IF b = 100 THEN
         WriteString("   Boiling point of water");
      END;
      WriteLn;
   END; (* of main loop *)

END DumbConv.
