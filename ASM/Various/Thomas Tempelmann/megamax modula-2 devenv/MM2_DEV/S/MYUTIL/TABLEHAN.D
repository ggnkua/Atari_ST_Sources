(*---------------------------------------------------------------------*)
(*---                     Modul TableHandler                        ---*)
(*---                    --------------------                       ---*)
(*---                                                               ---*)
(*---  Basismodul fuer XREF, aus 4th Edition WIRTH Seite 88         ---*)
(*---                                                               ---*)
(*--- Programmiersprache :  Megamax-Modula-2 fr Atari ST           ---*)
(*--- Implementation     :  Uwe A. Ruttkamp, 30.1.89                ---*)
(*--- Portierung         :  Thomas Tempelmann, 4.5.90               ---*)
(*---                                                               ---*)
(*---------------------------------------------------------------------*)

DEFINITION MODULE TableHandler;

CONST
  LineWidth  = 80;
  WordLength = 24;

TYPE
  Table;
  
VAR
  overflow: INTEGER;  (* >0 means table full *)

PROCEDURE InitTable (VAR t: Table);

PROCEDURE Record (t: Table; VAR x: ARRAY OF CHAR; n: INTEGER);
  (* enter x,n in table t; string x must end with a blank *)

PROCEDURE Tabulate (t: Table);

PROCEDURE FinishTable (VAR t: Table);

END TableHandler.
