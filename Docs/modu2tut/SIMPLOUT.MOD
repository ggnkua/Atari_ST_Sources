                                         (* Chapter 8 - Program 1 *)
MODULE SimplOut;

FROM InOut IMPORT WriteString, WriteLn;         (* unqualified *)
IMPORT InOut;         (* This imports every procedure in InOut *)
IMPORT Terminal;   (* This imports every procedure in Terminal *)

VAR Index : CARDINAL;

BEGIN
   WriteString("This is from InOut, ");
   InOut.WriteString("and so is this.");
   Terminal.WriteLn;

   Terminal.WriteString("This is from Terminal, ");
   Terminal.WriteString('and so is this.');
   WriteLn;

   FOR Index := 1 TO 10 DO
      InOut.WriteCard(Index,5);
   END;
   InOut.WriteLn;
END SimplOut.
