                                         (* Chapter 3 - Program 7 *)
MODULE Transfer;

VAR Int1,  Int2  : INTEGER;
    Card1, Card2 : CARDINAL;
    Real1, Real2 : REAL;
    Char1, Char2 : CHAR;

BEGIN

   Int1  := 14;
   Int2  := 35;
   Card1 := Int1 + Int2 + 23;            (* assignment compatible *)
   Card2 := Card1 - 13 * 2 + CARDINAL(Int1);   (* mixed types     *)
   Card2 := Card1 - 13 * 2 + CARDINAL(Int1);   (* assignment comp *)
   Int1  := Int2 * INTEGER(Card1);

   Real1 := 12.0;
   Real2 := Real1 + FLOAT(Card2) * 1.112;     (* CARDINAL to REAL *)
   Real2 := Real2 + FLOAT(CARDINAL(Int1));    (* INTEGER to REAL  *)

(* Int1  := TRUNC(Real1) + Int2 * 3;         Incompatible error 1 *)
   Int1  := TRUNC(Real1) + CARDINAL(Int2) * 3;     (* error fixed *)
   Int1  := INTEGER(TRUNC(Real1)) + Int2 * 3;      (* error fixed *)

(* Card1 := TRUNC(Real1) + Int2 * 3;         Incompatible error 2 *)
   Card1 := INTEGER(TRUNC(Real1)) + Int2 * 3;      (* error fixed *)
   Card1 := TRUNC(Real1) + CARDINAL(Int2) *3;      (* error fixed *)

   Char1 := "A";
(* Int1  := ORD(Char1) + Int2;               Incompatible error 3 *)
   Int1  := INTEGER(ORD(Char1)) + Int2;            (* error fixed *)
   Int1  := ORD(Char1) + CARDINAL(Int2);           (* error fixed *)

   Card1 := ORD(Char1) + Card1;
   Real2 := FLOAT(ORD(Char1)) + 1.2345;

   Char1 := CHR(TRUNC(FLOAT(ORD(Char1))));      (* Sheer Nonsense *)

END Transfer.
