                                         (* Chapter 3 - Program 1 *)
MODULE IntVar;

FROM InOut IMPORT WriteLn, WriteString, WriteInt;

VAR Count : INTEGER;  (* The sum of two variables *)
    x,y   : INTEGER;  (* The two variables to add *)

BEGIN

   x := 12;
   y := 13;
   Count := x + y;

          (* Assignments complete, now display the results *)

   WriteString("The value of x  =");
   WriteInt(x,3);
   WriteLn;
   WriteString("The value of y  =");
   WriteInt(y,4);
   WriteLn;
   WriteString("The sum of them =");
   WriteInt(Count,6);
   WriteLn;

   x := 0FFH;   (* This is the way to assign a hexadecimal number *)
   y := 177B;   (* This is the way to assign an octal number      *)

END IntVar.
