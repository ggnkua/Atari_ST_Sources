DEFINITION MODULE A;

TYPE Enum = (one, two, three);
     Rec = RECORD e: Enum END;

END A.

MODULE B;

FROM A IMPORT Rec;
FROM A IMPORT one;
FROM A IMPORT two; (* hier darf kein Fehler kommen *)
(* hier muž ein Fehler kommen: *)
FROM A IMPORT Enum;

END B.
