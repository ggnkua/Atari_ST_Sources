DEFINITION MODULE VT52;

(*
 * Dies Modul definiert die VT-52 Codes als String-Konstante.
 *
 * In der AufzÑhlungs-Type 'Codes' werden alle vorhandenen VT-52 Codes
 * definiert. Zugriff auf die ihnen entsprechenden Strings mit der
 * ESC-Sequenz erhÑlt man Åber das 'Seq'-Feld.
 *
 * Zur Verwendung der Bezeichner dieses Moduls wird unqualifizierter
 * Import empfohlen.
 *
 * Beispiel:
 *
 *  IMPORT VT52;
 *  BEGIN
 *    WriteString ( VT52.Seq [VT52.clearScreen] )
 *
 * Es ginge auch:
 *
 *   IMPORT VT52;
 *   FROM VT52 IMPORT Codes;
 *   BEGIN
 *     WriteString ( VT52.Seq [clearScreen] )
 *)

FROM Characters IMPORT ESC, LF, CR;

TYPE Codes = (
  up, down, right, left,                   (* Bewegen Cursor auf Bildschirm *)
  moveUp,   (* Reverse LF: bewegt Cursor auf, am oberen Rand wird gescrollt *)
  moveDown,  (* Line Feed: bewegt Cursor ab, am unteren Rand wird gescrollt *)
  home,                                      (* Cursor in linke, obere Ecke *)
  firstCol,                                       (* Cursor an Zeilenbeginn *)
  gotoRowCol,       (* Cursor positionieren, es folgen CHR(Y+32), CHR(X+32) *)
  saveRowCol,                                   (* Speichert Cursorposition *)
  restoreRowCol,                            (* Stellt Cursorpos. wieder her *)
  clearScreen,                                  (* Lîscht ganzen Bildschirm *)
  clearEOS,                       (* Lîscht ganzen Bildschirm ab Cursorpos. *)
  clearEOL,                          (* Lîscht aktuelle Zeile ab Cursorpos. *)
  clearBOS,                  (* Lîscht ganzen Bildschirm bis vor Cursorpos. *)
  clearBOL,                     (* Lîscht aktuelle Zeile bis vor Cursorpos. *)
  clearLine,                                       (* Lîscht aktuelle Zeile *)
  insertLine,              (* FÅgt neue Zeile ein, restl. Zeilen nach unten *)
  deleteLine,             (* Entfernt akt. Zeile, rÅckt Rest von unten nach *)
  writingColor,       (* Schriftfarbe bestimmen, es folgt CHR (64+Farbwert) *)
  backgroundColor,(* Hintergrundfarbe bestimmen, es folgt CHR (64+Farbwert) *)
  cursorOn, cursorOff,                 (* Cursor sichtbar/unsichtbar machen *)
  reverseOn, reverseOff,                  (* Invertierte Schriftart ein/aus *)
  wrapOn,                   (* Neue Zeile beim öberschreiten vom Zeilenende *)
  wrapOff,             (* In Zeile verbleiben beim Erreichen vom Zeilenende *)
  enhancedOn,           (* Schnelle, gepufferte Ausgabe (siehe TextWindows) *)
  flush,          (* Gepufferte Zeichen sofort ausgeben (siehe TextWindows) *)
  enhancedOff );       (* Normale, ungepufferte Ausgabe (siehe TextWindows) *)


TYPE  SeqRange  = [MIN (Codes)..MAX (Codes)];

      SeqStr    = ARRAY [0..1] OF CHAR;
      ExtSeqStr = ARRAY [0..4] OF CHAR;

      SeqType   = ARRAY SeqRange OF SeqStr;

CONST Seq = SeqType { ESC+'A', ESC+'B', ESC+'C', ESC+'D', ESC+'I', LF,
                      ESC+'H', CR,      ESC+'Y', ESC+'j', ESC+'k', ESC+'E',
                      ESC+'J', ESC+'K', ESC+'d', ESC+'o', ESC+'l', ESC+'L',
                      ESC+'M', ESC+'b', ESC+'c', ESC+'e', ESC+'f', ESC+'p',
                      ESC+'q', ESC+'v', ESC+'w', ESC+5C,  ESC+20C, ESC+6C };

(*
 * Da die Sequenzen von 'gotoRowCol', 'backgroundColor' und 'writingColor'
 * noch zusÑtzlich Zeichen verlangen, werden zur Einfachheit hier noch
 * dafÅr speziell vorgesehene Funktionen bereitgestellt:
 *)

PROCEDURE GetGotoRowColSeq ( row, col: CARDINAL; VAR seq: ARRAY OF CHAR );
PROCEDURE GotoRowColSeq ( row, col: CARDINAL ): ExtSeqStr;
  (* Es werden 4 Zeichen in den String 'seq' geschrieben bzw. geliefert *)

PROCEDURE GetWritingColorSeq ( color: CARDINAL; VAR seq: ARRAY OF CHAR );
PROCEDURE WritingColorSeq ( color: CARDINAL ): ExtSeqStr;
  (* Es werden 3 Zeichen in den String 'seq' geschrieben bzw. geliefert *)

PROCEDURE GetBackgroundColorSeq ( color: CARDINAL; VAR seq: ARRAY OF CHAR );
PROCEDURE BackgroundColorSeq ( color: CARDINAL ): ExtSeqStr;
  (* Es werden 3 Zeichen in den String 'seq' geschrieben bzw. geliefert *)

END VT52.
