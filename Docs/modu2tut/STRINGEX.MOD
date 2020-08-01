                                         (* Chapter 6 - Program 6 *)
MODULE StringEx;

(* Note - The "Strings" procedures used here are not standard because
          there is no standard.  You may need to modify some or all
          of the string procedure calls to get them to work.  Consult
          the documentation for your compiler and library.         *)

FROM InOut   IMPORT WriteString, WriteInt, WriteLn;
FROM Strings IMPORT Assign, Concat;

TYPE SevenChar = ARRAY[0..6] OF CHAR;

VAR Horse : ARRAY[0..12] OF CHAR;
    Cow   : ARRAY[0..5] OF CHAR;
    S1    : SevenChar;
    S2    : SevenChar;
    Index : CARDINAL;

(* ******************************************************* Display *)
PROCEDURE Display(Stuff : ARRAY OF CHAR);
BEGIN
   WriteString("Array(");
   WriteString(Stuff);
   WriteString(") - ");
   FOR Index := 0 TO HIGH(Stuff) DO
      WriteInt(ORD(Stuff[Index]),4);
   END;
   WriteLn;
END Display;

(* ************************************************** main program *)
BEGIN
   Horse := "ABCDEFGHIJKL";           (* Copy constant to variable *)
   Display(Horse);

   Cow := "12345";
   Assign(Cow,Horse);               (* Assign variable to variable *)
   Display(Horse);

   S1 := "Neat";
   S2 := "Things";
   Concat(S1,S2,Horse);       (* Concatenate variables to variable *)
   Display(Horse);
   S1 := S2;                        (* Assign variable to variable *)

   Concat(Horse,Cow,Horse); (* Concatenate one variable to another *)
   Display(Horse);

   Concat(Cow,Horse,Horse);        (* Concatenate to the beginning *)
   Display(Horse);
END StringEx.
