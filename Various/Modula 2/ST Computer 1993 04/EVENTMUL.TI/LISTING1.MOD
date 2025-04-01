FROM SYSTEM IMPORT WORD, VAL;
...
  PROCEDURE and(a, b : WORD) : BOOLEAN;
   VAR c : BITSET;
    BEGIN
      c := VAL(BITSET, a) * VAL(BITSET, b);
      IF c <> 0 THEN RETURN TRUE ELSE RETURN FALSE;
    END and;
  ...