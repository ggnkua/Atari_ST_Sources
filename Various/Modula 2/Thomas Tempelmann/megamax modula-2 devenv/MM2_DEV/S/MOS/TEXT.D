DEFINITION MODULE Text;

(*
 * Dieses Modul stellt die Funktionen zum textuellen Bearbeiten von Dateien
 * zur VerfÅgung.
 *)


FROM Files IMPORT File;


PROCEDURE Write (f: File; ch: CHAR);
  (* Schreibt ein Zeichen in die Datei. *)

PROCEDURE WriteString (f: File; REF str: ARRAY OF CHAR);
  (* Schreibt den String in die Datei. *)

PROCEDURE WriteLn (f: File);
  (* Schreibt ein CR (15C) und ein LF (12C) in die Datei. *)

PROCEDURE WritePg (f: File);
  (* Bildschirmlîschen bzw. Seitenvorschub (FF, 14C) *)



PROCEDURE EOL (f: File): BOOLEAN;
  (* Liefert TRUE, wenn ein Zeilenende (CR oder LF) beim Lesen aus der
   * Datei mittels 'Read...' erreicht wurde oder die Funktion 'EOF'
   * TRUE liefert.
   *)


PROCEDURE Read (f: File; VAR ch: CHAR);
  (* Holt ein Zeichen aus der Datei. Wenn die Datei nicht auf Disk o.Ñ.
   * erîffnet ist, wird solange gewartet, bis ein Zeichen zur VerfÅgung steht.
   * Wenn die Datei auf 'CON:' erîffnet ist, werden die eingegebenen Zeichen,
   * sofern sie keine Controlzeichen sind, auf dem Bildschirm ausgegeben.
   *)

PROCEDURE ReadFromLine (f: File; VAR str: ARRAY OF CHAR);
  (* Es wird zeichenweise aus der Datei gelesen, bis der String voll ist
   * oder das Zeilenende erreicht wird. Mit dem Backspace-Zeichen kann
   * das zuletzt eingegebene Zeichen wieder gelîscht werden.
   * Liefert die Funktion 'EOL' danach TRUE, wurde die Eingabe mit <Return>
   * (LF oder CR) beendet, ansonsten war der String vollstÑndig gefÅllt.
   * Bei Eingabe von Tastatur werden eingegebene Controlzeichen nicht
   * ausgegeben; nur bei der Return-Taste oder Ctrl-J wird CR/LF ausgegeben.
   *)

PROCEDURE ReadToken (f: File; VAR str: ARRAY OF CHAR);
  (* Es wird zeichenweise aus der Datei gelesen, bis der String voll ist,
   * das Zeilenende erreicht oder ein Trennzeichen eingelesen wird.
   * FÅhrende Trennzeichen vor einem Wort ('Token') werden zudem Åberlesen
   * und nicht in den String aufgenommen.
   * Diese Trennzeichen sind in MOSConfig.Separators definiert und
   * sind normalerweise alle Control- und das Space- (Leertaste) Zeichen.
   * Mit 'TermCH' kann das Trennzeichen ermittelt werden. Ist dieses
   * Zeichen kein 'Separator', wurde die Eingabe beendet, weil der
   * String vollgelesen war.
   *)

PROCEDURE TermCH (f: File): CHAR;
  (* Liefert das Trennzeichen, das die letzte Eingabe beendete. *)

PROCEDURE UndoRead (f: File);
  (* Die Funktion stellt das zuletzt gelesene Zeichen wieder zurÅck, sodaû
   * es beim nÑchsten Lesezugriff nochmal erhalten wird.
   * Keinesfalls darf die Funktion zweimal hintereinander aufgerufen werden,
   * ohne daû das zurÅckgestellte Zeichen zwischendurch gelesen wurde. In
   * diesem Fall wird eine sofortige Fehlermeldung ausgelîst.
   *)

PROCEDURE ReadLn (f: File);
  (* öberliest alle Zeichen bis zum Zeilenende (einschlieûlich), hîchstens
   * bis zum Dateiende.
   * Nach dem Aufruf liefert, sofern kein Fehler auftrat, die Funktion 'EOL'
   * FALSE. Erst ein folgender Aufruf von 'Read' oder 'ReadString' erkennt
   * einen evtl. direkt folgenden Zeilenbegrenzer.
   *)


PROCEDURE ReadBin (f: File; VAR ch: CHAR);
  (* Holt ein Zeichen aus der Datei. Entgegen 'Read' wird auch jedes erhal-
   * tene Controlzeichen zurÅckgeliefert, es werden also z.B. keine CR- und
   * LF-Zeichen unterdrÅckt.
   * Wenn die Datei auf 'CON:' erîffnet ist, werden die eingegebenen Zeichen,
   * sofern sie keine Controlzeichen sind, auf dem Bildschirm ausgegeben.
   *)


PROCEDURE ReadString (f: File; VAR str: ARRAY OF CHAR);
  (* Dies ist eine (ehemalige) miûlungene Mischung aus ReadFromLine
   * und ReadToken:
   * Sie liest alle Zeichen in den String ein, bis er voll ist oder
   * ein Control-Zeichen gelesen wird.
   * Im Gegensatz zu ReadToken werden also Leerzeichen mit in den
   * String aufgenommen.
   * Wir empfehlen, diese Funktion nicht mehr zu verwenden und stattdessen
   * entweder 'ReadFromLine' oder 'ReadToken' - je nach Bedarf, zu verwenden.
   *)

END Text.
