(*
 * PrÅft, ob das Enum-Elem korrekt importiert wird.
 *)

DEFINITION MODULE A;
TYPE SetGetMode = (setValue, getValue);
END A.

MODULE T;
FROM A IMPORT SetGetMode;
IMPORT A;
VAR mode: SetGetMode;
BEGIN
  mode:= getValue;
  mode:= A.getValue;
END T.

MODULE T;
IMPORT A;
FROM A IMPORT SetGetMode;
VAR mode: SetGetMode;
BEGIN
  mode:= A.getValue;
  mode:= getValue; (* alter Comp meldet "undekl. Bez." *)
END T.
