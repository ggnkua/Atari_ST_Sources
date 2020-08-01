                                         (* Chapter 5 - Program 3 *)
MODULE Proced3;

FROM InOut IMPORT WriteString, WriteCard, WriteLn;

VAR Apple, Orange, Pear, Fruit : CARDINAL;

PROCEDURE AddTheFruit (Value1,Value2 : CARDINAL;  (* One-way *)
                       VAR Total     : CARDINAL;  (* Two-way *)
                       Value3        : CARDINAL); (* One-way *)
BEGIN
   Total := Value1 + Value2 + Value3;
END AddTheFruit;

BEGIN  (* Main Program *)
   Apple := 4;
   Orange := 7;
   Pear := 5;
   AddTheFruit(Apple,Pear,Fruit,Orange);
   WriteString("The total number of fruits is ");
   WriteCard(Fruit,5);
   WriteLn;
END Proced3.
