DEFINITION MODULE A;

TYPE Enum = (one, two, three);

END A.

IMPLEMENTATION MODULE A;

CONST eins = one; zwei = two; drei = three;
TYPE T = Enum;

END A.

MODULE B;

(* hier muž ein Fehler kommen: *)
FROM A IMPORT Enum, three;

CONST drei = three; zwei = two; eins = one;

BEGIN
  IF FALSE THEN
    IF 1 DIV 0 =4 THEN
    END
  END;
END B.
