DEFINITION MODULE Gag;

(*
 * Importiertes Modul von "GagAcc"
 *)

EXPORT
  Box, Text, Foset, Btan, Btaus, Btfertig,
  Fttime, Ftpre;


CONST
  Box      =   0;  (* Formular/Dialog *)
  Text     =   1;  (* STRING in Baum BOX *)
  Foset    =   1;  (* Formular/Dialog *)
  Btan     =   2;  (* BUTTON in Baum FOSET *)
  Btaus    =   3;  (* BUTTON in Baum FOSET *)
  Btfertig =   5;  (* BUTTON in Baum FOSET *)
  Fttime   =   6;  (* FTEXT in Baum FOSET *)
  Ftpre    =   7;  (* FTEXT in Baum FOSET *)

END Gag.
