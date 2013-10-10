DEFINITION MODULE Terminal;

(*
 * Dieses Modul stellt Funktionen zur Ausgabe auf den Bildschirm bzw. Eingabe
 * von der Tastatur zur VerfÅgung.
 *
 * Sollen Zahlen ein- oder ausgegeben werden, sind dazu die hiesigen Proze-
 * duren 'ReadString' und 'WriteString' sowie die String-Umwandlungsfunktio-
 * nen des Moduls 'StrConv' zu benutzen.
 *
 * Zur Ein-/Ausgabe werden normalerweise die BIOS-Funktionen des Atari be-
 * nutzt, die standardmÑûig auf die Treibervariablen in 'TermBase' zugewiesen
 * sind.
 * Deshalb sind auch die VT-52 Steuerzeichen verwendbar. Z.B. wird der Bild-
 * schirm mit den Aufrufen 'Write (33C) (* ESC *); Write ("S")' gelîscht
 * (siehe auch Funktion 'WritePg' und Modul 'VT52').
 *
 * Zu Beginn wird der Cursor einmalig ausgeschaltet.
 * Die Funktionen 'Read', 'ReadString', 'ReadToken' und 'ReadLine' schalten
 * den Cursor bei Erwarten eines Zeichens ein und am Ende wieder aus, die
 * anderen Funktionen verÑndern den Cursorstatus nicht.
 *)

FROM SYSTEM IMPORT LONGWORD;

FROM MOSGlobals IMPORT Key;


VAR  Done: BOOLEAN;
      (*
       * Ist FALSE nach Aufrufen der String-Eingabefunktionen (Read...,
       * Edit...), wenn Undo gedrÅckt wurde.
       * Hat keine Wirkung bei Einzel-Eingaben, wie Read, BusyRead, usw.
       *)


PROCEDURE NumRows (): CARDINAL;
  (*
   * Liefert Zeilenanzahl (normalerweise 25)
   *)

PROCEDURE NumCols (): CARDINAL;
  (*
   * Liefert Spaltenanzahl (normalerweise entweder 80 oder 40)
   *)


(*
 *       Ausgabe-Funktionen
 *       ------------------
 *)

PROCEDURE Write (ch: CHAR);
  (* Ausgabe eines Zeichens, Controlzeichen werden ausgewertet. *)

PROCEDURE WriteString (REF str: ARRAY OF CHAR);
  (* Ausgabe eines Strings, Controlzeichen werden ausgewertet. *)

PROCEDURE WriteCtrl (ch: CHAR);
  (* Ausgabe eines Zeichens, Controlzeichen werden angezeigt. *)

PROCEDURE WriteCtrlString (REF str: ARRAY OF CHAR);
  (* Ausgabe eines Strings, Controlzeichen werden angezeigt. *)

PROCEDURE WriteLn;
  (* Ausgabe eines CR / LF. (Sprung in nÑchste Zeile) *)

PROCEDURE WritePg;
  (* Lîscht Bildschirm. *)

PROCEDURE GotoXY (col, row: CARDINAL);
  (*
   * Setzt Cursor auf Spalte 'col', Zeile 'row'.
   * Links oben ist (0,0). Wenn 'row' oder 'col' auûerhalb des Bildschirms
   * liegen, ist die Positionierung undefiniert.
   *)

PROCEDURE GotoRowCol (row, col: CARDINAL);
  (*
   * Setzt Cursor auf Spalte 'col', Zeile 'row'.
   * Links oben ist (0,0). Wenn 'row' oder 'col' auûerhalb des Bildschirms
   * liegen, ist die Positionierung undefiniert.
   *)


(*
 *       Eingabe-Funktionen
 *       ------------------
 *
 * Es gibt grundsÑtzlich zwei verschiedene Eingabeverfahren:
 * Gepuffert und ungepuffert.
 * <Ungepuffert> bedeutet, daû bei einem Aufruf einer Read-Funktion
 * immer das Programmablauf gestoppt wird, damit der Anwender ein Zeichen
 * oder auch einen String eingeben kann.
 * Bei <gepufferter> Eingabe wird intern immer eine ganze Eingabezeile
 * gepuffert und dann werden bei Aufruf der Read-Funktionen so lange
 * die Zeichen und Strings aus diesem Puffer geholt, bis der Puffer
 * geleert ist. Erst dann wird der Programmlauf gestoppt, um die Eingabe
 * einer neuen Zeile zu ermîglichen.
 *
 * Nicht alle Read-Funktionen sind von dieser Pufferung berÅhrt:
 * 'ReadLine' liest sowieso immer eine ganze Zeile, sodaû der Puffer
 *   immer gleich wieder geleert wird.
 *)

PROCEDURE Read (VAR ch: CHAR);
  (*
   * Zeichen wird erwartet und wieder ausgegeben, falls es kein
   * Control-Zeichen ist.
   *)

PROCEDURE GetChar (VAR k: CHAR);
  (*
   * Liest Taste ohne Echo (keine Ausgabe des Zeichens)
   *)

PROCEDURE GetKey (VAR k: Key);
  (*
   * Liest Taste (kein Echo!) und liefert neben dem Zeichen-Wert auch
   * den Scancode (ggf. auch den Sondertastenstatus, falls Bit 3 in der
   * Systemvariablen 'conterm' (siehe Module 'KbdCtrl' & 'SysVars')
   * gesetzt ist).
   *)

PROCEDURE CondRead (VAR ch: CHAR; VAR success: BOOLEAN);
  (*
   * Falls Zeichen von Tastatur ansteht, wird es 'ch' zugewiesen und
   * 'success' liefert TRUE, ansonsten ist 'ch' = 0C und 'success' ist
   * FALSE. Kein Echo des eingegebenen Zeichens !
   *)

PROCEDURE BusyRead (VAR ch:CHAR);
  (*
   * Wenn Taste gedrÅckt, wird Zeichen in 'ch' geliefert, sonst wird 0C
   * in 'ch' geliefert.
   * Kein Echo des eingegebenen Zeichens !
   *)

PROCEDURE KeyPressed (): BOOLEAN;
  (* Liefert TRUE, wenn Taste gedrÅckt wurde. *)

PROCEDURE FlushKbd;
  (* Lîscht den Tastaturpuffer. *)


PROCEDURE UndoRead;
  (*
   * Auch "ReadAgain" in anderen Dialekten:
   * Das zuletzt gelesene Zeichen wird bei der nÑchsten Abfrage
   * nochmal geliefert.
   *)


PROCEDURE ReadLine (VAR str: ARRAY OF CHAR);
  (*
   * Ein String kann frei eingegeben werden. Ende durch Return bzw. Enter.
   * Abbruch mit Undo-Taste - dann wird ein Leerstring in 'str' geliefert
   * und 'Done' ist FALSE.
   * Es kînnen nur soviele Zeichen eingegeben werden, wie 'str' fassen kann.
   *)

PROCEDURE ReadCtrlLine (VAR str: ARRAY OF CHAR);
  (*
   * Wie ReadLine, es kînnen aber auch die Control-Zeichen eingegeben werden.
   *)

PROCEDURE EditLine (VAR str: ARRAY OF CHAR);
  (*
   * Wie ReadLine, jedoch muû 'str' schon beim Aufruf einen String
   * enthalten, der dann angezeigt und editiert werden kann.
   *)

PROCEDURE EditCtrlLine (VAR str: ARRAY OF CHAR);
  (*
   * Wie EditLine, es kînnen aber auch die Control-Zeichen editiert werden.
   *)

PROCEDURE ReadToken (VAR str: ARRAY OF CHAR);
  (*
   * Wie ReadLine, jedoch kann nur ein Wort ("Token") eingeben werden:
   * FÅhrende Leerzeichen (und Control-Zeichen) werden ignoriert,
   * nach Eingabe eines gÅltigen Zeichens wird beim nÑchsten Leer- oder
   * Control-Zeichen die Eingabe beendet.
   * Das Terminierungszeichen kann durch Aufrufe von
   *  'UndoRead' und 'Read' ermittelt werden.
   *)

PROCEDURE ReadString (VAR str: ARRAY OF CHAR);
  (*
   * Identisch mit 'ReadLine'.
   *)

END Terminal.
