DEFINITION MODULE Binary;

(*
 * Die Funktionen in diesem Modul dÅrfen nur auf Disk-Dateien angewandt
 * werden, die mit 'readOnly', 'writeOnly' oder 'readWrite' erîffnet wurden.
 *)

FROM Files IMPORT File;

FROM SYSTEM IMPORT BYTE, WORD, LONGWORD, ADDRESS;


TYPE    SeekMode = ( fromBegin, fromPos, fromEnd );


(*   Lese-Funktionen
 *   ---------------
 * Wird versucht, Åber das augenblickliche Ende hinaus Daten zu lesen,
 * wird die Funktion nicht ausgefÅhrt (der Dateizeiger bleibt unverÑndert)
 * und stattdessen der Fehler 'End of file' gesetzt.
 * Nur die Funktion 'ReadBytes' weicht davon ab (s.u.).
 *)

PROCEDURE ReadByte (f: File; VAR byte: BYTE);

PROCEDURE ReadWord (f: File; VAR word: WORD);

PROCEDURE ReadLong (f: File; VAR long: LONGWORD);

PROCEDURE ReadBlock (f: File; VAR block: ARRAY OF BYTE);
PROCEDURE ReadLargeBlock (f: File; VAR block: LONGARRAY OF BYTE);
  (* Wie 'ReadBlock', aber auch fÅr Daten > 64 KB *)

PROCEDURE ReadBytes (    f        : File;
                         addr     : ADDRESS; (* Adresse, an die geladen wird *)
                         bytes    : LONGCARD;
                     VAR bytesRead: LONGCARD);
(*
 * Diese Funktion liest hîchstens 'bytes' Bytes. Wird vorher das Ende der
 * Datei erreicht, werden entsprechend nur die vorhandenen Daten gelesen
 * und dann die Funktion ohne Fehler beendet.
 * 'bytesRead' enthÑlt hinterher die Anzahl der gelesenen Bytes. Der Wert
 * dieser Variablen liegt im Bereich [0..'bytes']. Es kann also auch vor-
 * kommen, daû Åberhaupt kein Byte gelesen wird !
 * Tritt ein Fehler beim Lesen auf, bleibt der Dateizeiger unverÑndert.
 *)


(*   Schreib-Funktionen
 *   ------------------
 * Als allgemeine Speicher-Funktionen kînnen in der Regel verwendet werden:
 * - 'WriteBlock' fÅr beliebige Daten (ganze Variablen)
 * - 'WriteBytes' fÅr Daten, von denen man die Adresse hat (z.B. mit ALLOCATE
 *   reserviert) oder bei denen man die genaue LÑnge selbst bestimmen mîchte.
 * - WriteByte/Word/Long sind alternativ zu WriteBlck verwendbar, wenn die
 *   Datengrîûe des Parameters mit der Variablen Åbereinstimmt.
 *)

PROCEDURE WriteByte (f: File; byte: BYTE);
PROCEDURE WriteWord (f: File; word: WORD);
PROCEDURE WriteLong (f: File; long: LONGWORD);

PROCEDURE WriteBlock (f: File; REF block: ARRAY OF BYTE);

PROCEDURE WriteLargeBlock (f: File; REF block: LONGARRAY OF BYTE);
  (* Wie 'WriteBlock', auch fÅr Daten > 64 KB *)

PROCEDURE WriteBytes (f: File; addr: ADDRESS; bytes: LONGCARD);
  (* Speichert die Daten ab Adresse 'addr' mit der LÑnge 'bytes' in Byte *)


PROCEDURE FileSize (f: File): LONGCARD;
  (*
   * Liefert aktuelle DateilÑnge in Bytes.
   *)

PROCEDURE FilePos (f: File): LONGCARD;
  (*
   * Liefert aktuelle Byteposition des Dateizeigers.
   *)

PROCEDURE Seek (f: File; offset : LONGINT; base: SeekMode);
  (*
   * Positioniert den Dateizeiger relativ...
   *  - zum Anfang der Datei, wenn 'base' = 'fromBegin' (offset nur positiv !),
   *  - zum Dateizeiger, wenn 'base' = 'fromPos' (offset pos. o. neg.),
   *  - zum Ende der Datei, wenn 'base' = 'fromEnd' (offset nur negativ !),
   *
   * Falls die neue Position hinter dem aktuellem Dateiende liegt, wird
   * die Datei entsprechend automatisch erweitert, sofern die Datei zum
   * Beschreiben erîffnet wurde. Die hinzugefÅgten Daten sind Åbrigens
   * undefiniert, also keine Null-Bytes!
   *)

END Binary.
