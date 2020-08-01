                                         (* Chapter 6 - Program 5 *)
MODULE ArayPass;

FROM InOut IMPORT WriteString, WriteCard, WriteLn;

TYPE OneArray = ARRAY[10..15] OF CARDINAL;
     TwoArray = ARRAY[-8..210] OF CARDINAL;

VAR  SizeOne : OneArray;
     SizeTwo : TwoArray;
     Index   : INTEGER;

(* **************************************************** AddNumbers *)
PROCEDURE AddNumbers(Donkey : OneArray);

VAR CountUp, Sum : CARDINAL;

BEGIN
   Sum := 0;
   FOR CountUp := 10 TO 15 DO
      Sum := Sum + Donkey[CountUp];
   END;
   WriteCard(Sum,5);
   WriteLn;
END AddNumbers;

(* ************************************************* GenAddNumbers *)
PROCEDURE GenAddNumbers(Donkey : ARRAY OF CARDINAL);

VAR CountUp, Sum : CARDINAL;

BEGIN
   Sum := 0;
   FOR CountUp := 0 TO HIGH(Donkey) DO
      Sum := Sum + Donkey[CountUp];
   END;
   WriteCard(Sum,5);
   WriteLn;
END GenAddNumbers;

BEGIN      (* *************************************** main program *)
   FOR Index := 10 TO 15 DO
      SizeOne[Index] := 10;
   END;

   FOR Index := 210 TO -8 BY -1 DO
      SizeTwo[Index] := 1;
   END;

   WriteString("The sum of the SizeOne numbers is");
   AddNumbers(SizeOne);

   WriteString("Gen sum of the SizeOne numbers is");
   GenAddNumbers(SizeOne);
   WriteString("Gen sum of the SizeTwo numbers is");
   GenAddNumbers(SizeTwo);

END ArayPass.
