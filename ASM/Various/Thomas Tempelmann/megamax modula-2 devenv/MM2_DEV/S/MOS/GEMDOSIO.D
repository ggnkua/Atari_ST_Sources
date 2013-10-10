DEFINITION MODULE GEMDOSIO;

(*
 * Konfiguriert den gesamten TOS-Bildschirm als Ausgabemedium fÅr die
 * Funktionen aus 'InOut'.
 *
 * Die Ein-/Ausgaben erfolgen durch Verwendung des 'Console'-Moduls
 * Åber die GEMDOS-Routinen, sodaû Datei-Umlenkungen, z.B. durch eine
 * Command-Shell, mîglich sind. Allerdings kînnen hiermit getriebene
 * InOut-Aufrufe durch DrÅcken von <Control-C> jederzeit zum Programm-
 * abbruch fÅhren.
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
 *     IMPORT GEMDOSIO;
 *     FROM InOut IMPORT Write, Read, WriteString;
 *   ... usw.
 *)

END GEMDOSIO.
