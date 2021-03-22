DEFINITION MODULE TermBase;

(* Grundmodul fÅr 'Terminal'.
 *
 * EnthÑlt Treibervariablen fÅr die Ein- und Ausgabe von Zeichen Åber
 * die Funktionen aus 'Terminal'.
 * Ein Grundtreiber ist bereits in dem Codeteil dieses Moduls enthalten
 * und wird standardmÑûig verwendet.
 *)


FROM SYSTEM IMPORT LONGWORD;

TYPE  BoolProc = PROCEDURE (): BOOLEAN;
      WriteProc= PROCEDURE (REF ARRAY OF CHAR);
      CardProc = PROCEDURE (): CARDINAL;
      LWProc   = PROCEDURE (): LONGWORD;

VAR   DoGetGSX : LWProc;    (* kein Echo! *)
      DoBusy   : BoolProc;
      DoWrite  : WriteProc;
      DoWriteCt: WriteProc;
      DoGetRows: CardProc;
      DoGetCols: CardProc;

PROCEDURE InitDisplay;
PROCEDURE InitKeyboard;

END TermBase.
