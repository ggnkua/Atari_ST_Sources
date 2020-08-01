                                         (* Chapter 5 - Program 2 *)
MODULE Proced2;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR Stuff : INTEGER;
    Thing : INTEGER;

PROCEDURE PrintDataOut(Puppy : INTEGER);
BEGIN
   WriteString("The value of Puppy is     ");
   WriteInt(Puppy,5);
   WriteLn;
   Puppy := 12;
END PrintDataOut;

PROCEDURE PrintAndModify(VAR Cat : INTEGER);
BEGIN
   WriteString("The value of Cat is       ");
   WriteInt(Cat,5);
   WriteLn;
   Cat := 37;
END PrintAndModify;

BEGIN        (* Main program *)
   FOR Stuff := 3 TO 5 DO
      Thing := Stuff;
      PrintDataOut(Thing);
         WriteString("Back from print, data is  ");
         WriteInt(Thing,5);
         WriteLn;
      PrintAndModify(Thing);
         WriteString("Back from modify, data is ");
         WriteInt(Thing,5);
         WriteLn;
      PrintDataOut(Thing);
         WriteString("Back from print, data is  ");
         WriteInt(Thing,5);
         WriteLn;
         WriteLn;
   END;
END Proced2.
