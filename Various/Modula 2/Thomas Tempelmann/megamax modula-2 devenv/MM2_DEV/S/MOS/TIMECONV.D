DEFINITION MODULE TimeConvert;

(*
 * Umwandlung von Datums- und Zeitangaben in Strings und umgekehrt.
 * Geeignet auch fÅr GEM-Ein-/Ausgabemasken.
 *)

FROM MOSGlobals IMPORT Time, Date;


PROCEDURE TimeToText ( s: Time; REF mask: ARRAY OF CHAR; VAR t: ARRAY OF CHAR );
  (*
   * Wandelt die Zeit 's' in den String 't'.
   * 't' muû mindestens so groû wie die Åbergebene Maske sein, sonst
   * tritt ein Laufzeitfehler auf! (Empfohlen werden mind. 12 Zeichen!)
   *
   * Die Form wird durch 'mask' bestimmt:
   *
   *   HH: Stundenzahl ("hh" lîscht fÅhrende Null)
   *   MM: Minutenzahl ("mm" lîscht fÅhrende Null)
   *   SS: Sekundenzahl ("ss" lîscht fÅhrende Null)
   *
   *   #E: AM/PM-Notierung (English) ("e" schreibt "am" bzw. "pm")
   *
   *   Beispiele fÅr:            >13 Uhr 50, 5s<     >2 Uhr 50, 10s<
   *    'hh:mm:ss'                '13:50:5'           '2:50:10'
   *    'HH:MM:SS'                '13:50:05'          '02:50:10'
   *    'hh:MM:SS'                '13:50:05'          '2:50:10'
   *    'hh:MM #e'                '1:50 pm'           '2:50 am'
   *    'hh Uhr mm'               '13 Uhr 5'          '2 Uhr 10'
   *
   *   FÅr GEM-Ausgabemasken kann z.B. "HHMMSS" Åbergeben werden (s. Modul
   *   'Timer' im UTILITY-Ordner).
   *
   * Ist 'mask' ein Leerstring, wird 'StdTimeMask' (in 'MOSConfig') verwendet.
   *)

PROCEDURE DateToText ( s: Date; REF mask: ARRAY OF CHAR; VAR d: ARRAY OF CHAR );
  (*
   * Wandelt Datum 's' in String 'd'.
   * 'd' muû mindestens so groû wie die Åbergebene Maske sein, sonst
   * tritt ein Laufzeitfehler auf! (Empfohlen werden mind. 12 Zeichen!)
   *
   * Die Form wird durch 'mask' bestimmt:
   *
   *   D: Tagesziffer  (d: wird gelîscht, wenn nicht auffÅllbar)
   *   Y: Jahresziffer (y: wird gelîscht, wenn nicht auffÅllbar)
   *   M: Monatsziffer (m: wird gelîscht, wenn nicht auffÅllbar)
   *   G: Monatsbuchstabe Deutsch
   *   F: Monatsbuchstabe FrÑnzîsisch
   *   E: Monatsbuchstabe English
   *   U: Benutzerdefinierter Monatsbuchstabe (s. 'MOSConfig.NameOfMonth')
   *   #E (Hinter Ziffern): s. Bsp. (#G, #F gehen z.Zt. nicht !)
   *
   *   Beispiele fÅr:                >13.5.1988<          >1.9.2002<
   *   'DD.MM.YY'                ->  '13.05.88'           '01.09.02'
   *   'mm-dd-yy'                ->  '5-13-88'            '9-1-2'
   *   'dd. GGG yyyy'            ->  '13. Mai 1988'       '1. Sep 2002'
   *   'yyyy, d#E of EEEEEEEEE'  ->  '1988, 13th of May'  '2002, 1st of September'
   *   'GGGGGGGGGGGG'            ->  'Mai'                'September'
   *
   *   FÅr GEM-Ausgabemasken kann z.B. "DDMMYY" Åbergeben werden (s. Modul
   *   'Timer' im UTILITY-Ordner).
   *
   * Ist 'mask' ein Leerstring, wird 'StdDateMask' (in 'MOSConfig') verwendet.
   *)

PROCEDURE TextToTime ( s: ARRAY OF CHAR; VAR d: Time; VAR valid: BOOLEAN );
  (*
   * Wandelt den Text 's' in die Zeit 't'.
   * 'valid' liefert TRUE, wenn die Zeitangabe gÅltig war.
   * Im Text 's' mÅssen die Stunden, Minuten und Sekunden (optional) durch
   * ein Satzzeichen o.Ñ. (keine Ziffern oder Buchstaben) getrennt sein.
   *
   * Beispiele:
   *  '13:30'  ->  13h 30m 0s  valid=TRUE
   *  '1530'   ->  15h 30m 0s  valid=TRUE
   *  '010203' ->  1h 2m 3s    valid=TRUE  (fÅr GEM-Eingabemasken!)
   *  '15000'  ->  15h 0m 0s   valid=TRUE  (und nicht etwa 1h 0m 0s!)
   *  '1 5.30' ->  1h 5m 30s   valid=TRUE
   *  '24.00'  ->  0h 0m 0s    valid=FALSE (Werte mÅssen zw. 0 und 23/59 liegen)
   *  '1pm'    ->  1h          valid=FALSE (String darf sonst nix enthalten)
   *)

PROCEDURE TextToDate ( s: ARRAY OF CHAR; exp: CARDINAL;
                       VAR d: Date; VAR valid: BOOLEAN );
  (*
   * Wandelt Text 's' in das Datum 'd'.
   *
   * 'valid' liefert TRUE, wenn die Datumsangabe gÅltig war, dabei werden
   * auch Daten wie der 30.2, der 31.4 oder der 29.2 in Nicht-Schaltjahren
   * (nach gregorianischem Kalender) zurÅckgewiesen.
   * Dazu gehîrt auch, daû nach der gÅltigen Datumsangabe keine weiteren
   * Zeichen folgen.
   *
   * Strings, wie "010490" werden auch korrekt ausgewertet, solange die
   * Reihenfolge mit 'exp' Åbereinstimmt. Dies ist besonders nÅtzlich
   * zum Auswerten von GEM-Eingabemasken fÅr das Daum (s. Modul 'Timer'
   * im UTILITY-Ordner).
   *
   * 'exp' bestimmt die zu erwartende Form des Datums:
   *   1: t-m-j
   *   2: m-t-j
   *   3: j-m-t
   *   4: j-t-m
   * Ist 'exp' Null, wird 'StdDateExp' (in 'MOSConfig') verwendet.
   *)

END TimeConvert.
