                                         (* Chapter 3 - Program 2 *)
MODULE IntMath;

FROM InOut IMPORT WriteLn, WriteString, WriteInt;

VAR IntSum, IntDif, IntMul, IntDiv, IntRem : INTEGER;
    A, B                                   : INTEGER;

BEGIN
   A := 9;             (* Simple assignment                  *)
   B := A + 4;         (* Addition                           *)
   IntSum := A + B;    (* Addition                           *)
   IntDif := A - B;    (* Subtraction                        *)
   IntMul := A * B;    (* Multiplication                     *)
   IntDiv := B DIV A;  (* Integer division, the result is a
                          truncated integer number.          *)
   IntRem := B MOD A;  (* d is the remainder of the integer
                          division.                          *)
   A := (A + B) DIV (3*B + 7);  (* Composite math statement  *)

   WriteString("The integer values are ");
   WriteInt(IntSum,6);
   WriteInt(IntDif,6);
   WriteInt(IntMul,6);
   WriteInt(IntDiv,6);
   WriteInt(IntRem,6);
   WriteLn;

   INC(A);       (* This increments the value of A   *)
   DEC(A);       (* This decrements the value of A   *)
   INC(A,3);     (* This adds 3 to the value of A    *)
   DEC(A,7);     (* This reduces the value of A by 7 *)
   INC(A,B*2+4); (* A composite incrementing amount  *)

   A := MIN(INTEGER);  (* This produces the smallest INTEGER *)
   B := MAX(INTEGER);  (* This produces the largest INTEGER  *)

END IntMath.
