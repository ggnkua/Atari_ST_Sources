                                       (* Chapter 4 - Program 4 *)

(* This program is a good example of proper formatting, it is   *)
(* easy to read and very easy to understand.  It should be a    *)
(* snap to update a program that is well written like this. You *)
(* should begin to develop good formatting practice early in    *)
(* your programming career.                                     *)

MODULE TempConv;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR Count      : INTEGER;   (* a variable used for counting     *)
    Centigrade : INTEGER;   (* the temperature in centigrade    *)
    Farenheit  : INTEGER;   (* the temperature in farenheit     *)

BEGIN

   WriteString("Farenheit to Centigrade temperature table");
   WriteLn;
   WriteLn;

   FOR Count := -2 TO 12 DO
      Centigrade := 10 * Count;
      Farenheit := 32 + Centigrade *9 DIV 5;
      WriteString("   C =");
      WriteInt(Centigrade,5);
      WriteString("     F =");
      WriteInt(Farenheit,5);
      IF Centigrade = 0 THEN
         WriteString("   Freezing point of water");
      END;
      IF Centigrade = 100 THEN
         WriteString("   Boiling point of water");
      END;
      WriteLn;
   END; (* of main loop *)

END TempConv.
