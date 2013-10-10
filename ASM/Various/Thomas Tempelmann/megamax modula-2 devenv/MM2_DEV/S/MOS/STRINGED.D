DEFINITION MODULE StringEditor;
(*$H+*)

(*
 * Bietet Basisfunktion zum Eingeben und éndern eines Strings Åber Tastatur.
 * Dieses Modul wird u.A. von den Read-Funktionen in Terminal und TextWindows
 * verwendet.
 *)


FROM MOSGlobals IMPORT Key;

TYPE

  Commands = (none, enter, abort, backspace, delete, insert,
              clrln, clreol, sol, eol, left, right,
              wdleft, wdright, delwdleft, delwdright);

  StdCmdProc = PROCEDURE  ( Key ): Commands;

  WrChProc  = PROCEDURE ( CHAR );
  WrStrProc = PROCEDURE ( REF ARRAY OF CHAR );
  CrsrProc  = PROCEDURE ( INTEGER );          (* Positiv: Cursor nach rechts *)
  RdProc    = PROCEDURE ( VAR Commands, VAR CHAR );            (* Kein Echo! *)


VAR StdCmd: StdCmdProc;
     (*
      * Diese Routine wird von den Read-Funktionen in Terminal & TextWindows
      * aufgerufen, um TastendrÅcke in Editierbefehle umzuwandeln.
      * StandardmÑûig ist die Funktion 'StdKeyCmd' (s.u.) darauf zugewiesen.
      *)


PROCEDURE Edit ( VAR s: ARRAY OF CHAR; ctrlAllowed: BOOLEAN;
                 write: WrChProc; writeString: WrStrProc;
                 moveCursor: CrsrProc; readCmd: RdProc );
  (*
   * LÑût Eingabe auf 's' zu.
   * Diese Routine wird von den Read-Funktionen in Terminal & TextWindows
   * aufgerufen, um eine Eingabe zu machen.
   *
   * 's' muû vorher initialiert sein (ggf. leeren!), ist er nicht leer,
   * wird dessen Inhalt zur Eingabe Åbernommen.
   *
   * 'ctrlAllowed': TRUE:  Auch Controlzeichen (CHR(1)-CHR(31)) kînnen
   *                       editiert werden.
   *
   * Die anzugebenden Routinen zur Ein-/Ausgabe (sie kînnen auch *lokale*
   * Prozeduren sein!):
   *   'write' gibt ein Zeichen aus (auch Control-Zeichen mÅssen ggf.
   *      als sichtbare Zeichen dargestellt werden!)
   *   'writeString' gibt einen lÑngeren String aus (auch Control-Zeichen!)
   *   'moveCursor' bewegt den Eingabecursor um die angegebene Anzahl nach
   *      rechts (positiver Wert) oder nach links.
   *   'readCmd' liest eine Taste ein und liefert dessen Zeichen und eine
   *      Interpretation als Befehl. Das eingegebene Zeichen darf dabei
   *      nicht ausgegeben werden!
   *)


PROCEDURE StdKeyCmd ( k: Key ): Commands;
  (*
   * Wertet den Åbergebenen Scan-Code mitsamt seines ASCII-Wertes aus
   * und liefert entsprechende Befehle ('ctrl' wird ignoriert):
   *
   *  Taste          Befehl
   *     Return         enter
   *     Enter          enter
   *     Undo           abort
   *     <-             left
   *     ->             right
   *     Insert         insert
   *     Backspace      backspace
   *     Delete         delete
   *     Esc            clrln
   *     Clr (S-Home)   clrln
   *     Home           clreol
   *     Shift <-       wdleft
   *     Shift ->       wdright
   *     Ctrl <-        sol
   *     Ctrl ->        eol
   *     Ctrl Delete    delwdright
   *                   (delwdleft wird nicht erkannt)
   *     ansonsten      none
   *)

PROCEDURE StdAscCmd ( k: Key ): Commands;
  (*
   * Wertet den Åbergebenen ASCII-Wertes in 'ch' aus und liefert entsprechende
   * Befehle ('ctrl' und 'scan' werden ignoriert):
   *
   *  Taste          Befehl
   *     CR, Ctrl-M     enter
   *     Ctrl-C         abort
   *     BS, Ctrl-H     backspace
   *     Ctrl-U         right
   *     DEL            delete
   *     TAB            eol
   *     ESC            clrln
   *     Ctrl-X         clrln
   *     ansonsten      none
   *)

PROCEDURE StdWSCmd ( k: Key ): Commands;
  (*
   * Wertet den Åbergebenen ASCII-Wertes in 'ch' nach Word-Star-Belegung
   * aus und liefert entsprechende Befehle ('ctrl' und 'scan' werden ignoriert):
   *
   *  Taste          Befehl
   *     CR, Ctrl-M     enter
   *     BS, Ctrl-H     backspace
   *     Ctrl-S         left
   *     Ctrl-D         right
   *     Ctrl-V         insert
   *     DEL            delete
   *     ESC            clrln
   *     Ctrl-A         sol
   *     Ctrl-F         eol
   *     Ctrl-T         delwdright
   *     Ctrl-C         abort
   *     ansonsten      none
   *)

END StringEditor.
