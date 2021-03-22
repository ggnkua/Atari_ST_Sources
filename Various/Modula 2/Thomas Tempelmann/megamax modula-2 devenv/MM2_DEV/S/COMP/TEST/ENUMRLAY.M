DEFINITION MODULE A;

TYPE Enum = (one, two, three);
     UseEnum = RECORD e: Enum END;
END A.

DEFINITION MODULE B;

FROM A IMPORT UseEnum;

TYPE Rec = RECORD u: UseEnum END;

(* hier wird der Enum-Typ nur anonym verwendet/exportiert *)

END B.

MODULE C;

FROM B IMPORT Rec; (* der Enum-Typ wird anonym eingetragen *)
FROM A IMPORT Enum; (* ein Relay wird auf den vorher angelegten Enum erzeugt *)

CONST eins = one;  (* hier sind die Enum-Elems Åbers Relay sichtbar *)

MODULE LOCAL;

  IMPORT Enum; (* hier mÅssen die EnumElems Åber's Relay importiert werden *)

  CONST zwei = two; (* das muû klappen! *)

END LOCAL;

END C.
