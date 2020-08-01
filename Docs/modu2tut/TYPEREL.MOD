                                        (* Chapter 14 - Program 1 *)
MODULE TypeRel;

FROM InOut IMPORT WriteCard,WriteLn;

TYPE IntType  = ARRAY[1..10] OF INTEGER;
     CardType = ARRAY[81..90] OF CARDINAL;
     CharType = ARRAY[1..20] OF CHAR;

VAR  IntVars  : IntType;
     CardVars : CardType;
     CharVars : CharType;
     Index    : INTEGER;
     Count    : CARDINAL;

BEGIN

   Count := 10;
   Index := INTEGER(Count);
   FOR Count := 1 TO 10 DO
      IntVars[Count] := INTEGER(Count) + 64;
   END;
   CardVars[81] := CARDINAL(IntVars[1]);
   CardVars := CardType(IntVars);
   CharVars := CharType(CardVars);

   FOR Index := 81 TO 85 DO
      WriteCard(CardVars[Index],8);
   END;

   WriteLn;

   FOR Index := 1 TO 10 DO
      Count := ORD(CharVars[Index]);
      WriteCard(Count,4);
   END;

   WriteLn;

END TypeRel.
