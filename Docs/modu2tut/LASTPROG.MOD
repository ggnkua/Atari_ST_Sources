                                         (* Chapter 7 - Program 3 *)
MODULE LastProg;

FROM InOut IMPORT WriteString, WriteLn;

   PROCEDURE Dummy;
   BEGIN
   END Dummy;

VAR Index : CARDINAL;
TYPE Stuff = ARRAY[34..55] OF CHAR;

   PROCEDURE Smart;
   BEGIN
   END Smart;

CONST Number = 120;
TYPE  TypeOf = ARRAY[1..Number] OF Stuff;
CONST Neater = -345;
VAR   Count23 : TypeOf;
      Counter : INTEGER;

BEGIN
   WriteString("This is really a stupid program.");
   WriteLn;
END LastProg.
