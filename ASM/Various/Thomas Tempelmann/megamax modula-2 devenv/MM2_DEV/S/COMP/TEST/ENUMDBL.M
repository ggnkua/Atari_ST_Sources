DEFINITION MODULE A;

TYPE Enum = (one, two, three);

END A.

MODULE B;

FROM A IMPORT one;
FROM A IMPORT two; (* hier darf kein Fehler kommen *)

TYPE Enum2 = (eins, zwei, drei);

MODULE Local;

  IMPORT eins;
  IMPORT zwei; (* hier darf kein Fehler kommen *)

END Local;

END B.
