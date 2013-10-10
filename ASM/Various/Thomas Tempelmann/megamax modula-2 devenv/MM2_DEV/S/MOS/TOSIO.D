DEFINITION MODULE TOSIO;

(*
 * Konfiguriert den gesamten TOS-Bildschirm als Ausgabemedium fÅr die
 * Funktionen aus 'InOut'.
 *
 * Die Ein-/Ausgaben erfolgen durch Verwendung des 'Terminal'-Moduls
 * direkt Åber die BIOS-Routinen.
 * Stattdessen kann auch 'GEMDOSIO' verwendet werden, um die Ausgaben
 * Åber das GEMDOS zu leiten, sodaû Datei-Umlenkungen von auûen mîglich sind.
 *
 * Achtung: Wird dieses Modul statt 'GEMIO' eingebunden, dÅrfen keine
 * GEM-Funktionen verwendet werden !
 *
 * Das gelinkte Programm sollte als Dateiendung 'TOS' oder 'TTP' statt 'PRG'
 * erhalten.
 *
 * Sollen die InOut-Ausgaben eines Programms auch unter der Shell Åber
 * den TOS-Bildschirm gehen, so ist dies Modul dort direkt vor (!)
 * dem InOut-Modul zu importieren. Desweiteren ist die Endung des Moduls
 * durch Verwendung der $E-Compileroption auf "MOS" einzustellen.
 *
 * Beispiel:
 *
 *   MODULE Test; (*$E MOS *)
 *     IMPORT TOSIO;
 *     FROM InOut IMPORT Write, Read, WriteString;
 *   ... usw.
 *)

END TOSIO.
