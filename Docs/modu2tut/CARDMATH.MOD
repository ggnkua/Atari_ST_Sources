                                         (* Chapter 3 - Program 3 *)
MODULE CardMath;

FROM InOut IMPORT WriteLn, WriteString, WriteCard;

VAR CardSum, CardDif, CardMul, CardDiv : CARDINAL;
    A, B, CardRem                      : CARDINAL;
    IntVar                             : INTEGER;

BEGIN
   A := 9;              (* Simple assignment                  *)
   B := A + 4;          (* Addition                           *)
   CardSum := A + B;    (* Addition                           *)
   CardDif := B - A;    (* Subtraction                        *)
   CardMul := A * B;    (* Multiplication                     *)
   CardDiv := B DIV A;  (* Integer division, the result is a
                          truncated integer number.          *)
   CardRem := B MOD A;  (* d is the remainder of the integer
                          division.                          *)
   A := (A + B) DIV (3*B + 7);  (* Composite math statement  *)

   WriteString("The cardinal values are ");
   WriteCard(CardSum,6);
   WriteCard(CardDif,6);
   WriteCard(CardMul,6);
   WriteCard(CardDiv,6);
   WriteCard(CardRem,6);
   WriteLn;

   IntVar := A;       (* INTEGER and CARDINAL are assignment  *)
   B := IntVar + 27;  (* compatible, but cannot be mixed in   *)
                      (* any expression.                      *)

   A := 125;          (* CARDINAL assignment                  *)
   B := A - 112;      (* CARDINAL math                        *)
(* B := 125 + (-112);    Illegal CARDINAL Math - see text     *)

   IntVar := 125 + (-112);       (* INTEGER math, OK here     *)

   INC(A);      (* This increments the value of A       *)
   DEC(A);      (* This decrements the value of A       *)
   INC(A,4);    (* This adds 4 to the value of A        *)
   DEC(A,6);    (* THis subtracts 6 from the value of A *)

   A := MIN(CARDINAL);  (* This produces the minimum CARDINAL *)
   B := MAX(CARDINAL);  (* This produces the maximum CARDINAL *)

END CardMath.
