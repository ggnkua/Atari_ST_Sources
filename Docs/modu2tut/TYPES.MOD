                                         (* Chapter 6 - Program 3 *)
MODULE Types;

TYPE  ArrayDef   = ARRAY[12..25] OF INTEGER;
      CharDef    = ARRAY[0..27] OF CHAR;
      RealArray  = ARRAY[-17..42] OF REAL;
      DogFood    = ARRAY[1..6] OF BOOLEAN;
      Airplane   = ARRAY[1..12] OF DogFood;
      Boat       = ARRAY[1..12],[1..6] OF BOOLEAN;

VAR   Index,Counter : CARDINAL;
      Stuff         : ArrayDef;
      Stuff2        : ArrayDef;
      Stuff3        : ARRAY[12..25] OF INTEGER;
      Puppies       : Airplane;
      Kitties       : Boat;

BEGIN
   FOR Index := 1 TO 12 DO
      FOR Counter := 1 TO 6 DO
         Puppies[Index,Counter] := TRUE;
         Kitties[Index,Counter] := NOT Puppies[Index,Counter];
      END;
   END;

   FOR Index := 12 TO 25 DO
      Stuff[Index] := Index*4 + 13;
   END;

   Stuff2 := Stuff;    (* all 14 values copied *)
(* Kitties := Puppies;    illegal, types are not compatible *)

END Types.
