DEFINITION MODULE Files;

FROM MOSGlobals IMPORT Time, Date;

FROM FileBase IMPORT File0;

TYPE File = File0;

     Access = ( readOnly, writeOnly, readWrite,       (* BinÑrmodus *)
                readSeqTxt, writeSeqTxt, appendSeqTxt (* Textmodus  *) );

     ReplaceMode = ( noReplace, replaceOld );


PROCEDURE Init (VAR f: File);
  (*
   * Initialisiert eine File-Variable. Danach darf jede beliebige
   * Datei-Operation erfolgen, ohne daû mit undefinierten Ergebnissen
   * gerechnet werden muû (dies ist sonst nur bei Open & Create
   * gesichert).
   * Eine Fehler-/Statusabfrage mit 'State' liefert daraufhin
   * 'MOSGlobals.fFileNotOpen'.
   *)

PROCEDURE Open (VAR f       : File;
                REF fileName: ARRAY OF CHAR;
                    mode    : Access);
  (*
   * Wenn 'mode' = 'appendSeqTxt', dann wird, sofern die Datei auf Disk o.Ñ.
   * geîffnet wird, nicht ab Anfang der Datei Åberschrieben, sondern am Ende
   * angefÅgt.
   * Wenn ein Fehler auftritt, bleibt die Datei geschlossen und 'State'
   * liefert die Fehlernummer.
   *)

PROCEDURE Create (VAR f       : File;
                  REF fileName: ARRAY OF CHAR;
                      mode    : Access;
                      replMode: ReplaceMode);
  (*
   * Wenn 'replMode'='noReplace', wird ein Fehler geliefert, wenn schon
   * eine Datei unter dem Namen existiert.
   * Wenn 'replMode'='replaceOld', wird, falls 'mode'='writeSeqTxt', eine
   * schon vorhandene Datei gelîscht, wenn 'mode'='appendSeqTxt', wird, wenn
   * schon eine Datei existiert, diese nicht gelîscht sondern die Daten
   * angehÑngt.
   * Wenn ein Fehler auftritt, bleibt die Datei geschlossen und 'State'
   * liefert die Fehlernummer.
   *)

PROCEDURE Close (VAR f: File);
  (*
   * Schlieût Datei und aktualisiert die Datums-/Zeitkennung, falls die
   * Datei beschrieben wurde.
   * Die Datei wird auf jeden Fall geschlossen (die File-Variable wird
   * ungÅltig).
   * Es ist unbedingt ratsam, das erfolgreiche Schlieûen mittels 'State'
   * zu prÅfen, da ein evtl. folgendes 'Open' oder 'Create' nicht, wie
   * fast alle Åbrigen Dateifunktionen, selbsttÑtig auf vorangehende
   * Fehler prÅfen!
   *)

PROCEDURE Remove (VAR f: File);
  (*
   * Schlieût Datei, und lîscht sie aus dem Directory, falls sie mit
   * 'Create' angelegt wurde.
   * Die Datei wird auf jeden Fall geschlossen (die File-Variable wird
   * ungÅltig), evtl. aufgetretene Fehler sind Åber 'State' zu ermitteln.
   *)


PROCEDURE Flush (f: File);
  (*
   * Hat nur bei eigenen Anwendungen Sinn, falls die flush-Routinen
   * eigener Unit-Treiber (siehe Handbuch sowie Modul 'FileBase')
   * aufgerufen werden sollen.
   *)


PROCEDURE SetDateTime ( f: File; d: Date; t: Time );
  (*
   * Setzt Datums-/Zeitkennung einer geîffneten Datei.
   *
   * Funktioniert nur bei Dateien, die mit 'Open' - also
   * nicht mit 'Create' - geîffnet wurden!
   *)

PROCEDURE GetDateTime ( f: File; VAR d: Date; VAR t: Time );
  (*
   * Ermittelt Datums-/Zeitkennung einer geîffneten Datei.
   *)


PROCEDURE GetFileName (f: File; VAR name: ARRAY OF CHAR);
  (*
   * Liefert den Dateinamen, unter dem die Datei geîffnet wurde.
   * 'name' sollte vom Typ 'FileStr' sein, damit der Name auf
   * jedenfall hineinpaût.
   *)


PROCEDURE AccessMode (f: File): Access;
  (*
   * Liefert den Zugriffsmodus bei der geîffneten Datei 'f'.
   * Lîst eine Fehlermeldung aus, wenn die Datei nicht offen ist
   * oder ein Fehler (s. State-Funktion) ansteht!
   *)

PROCEDURE DiskAccess (f: File): BOOLEAN;
  (*
   * Liefert TRUE, wenn die geîffnete Datei keine Unit, sondern
   * eine Disk-Datei ist.
   * Lîst eine Fehlermeldung aus, wenn die Datei nicht offen ist
   * oder ein Fehler (s. State-Funktion) ansteht!
   *)


PROCEDURE EOF (f: File): BOOLEAN;
  (*
   * Bei Dateien, die mit 'readSeqTxt' geîffnet sind, wird TRUE geliefert,
   * wenn der letzte Lesezugriff das EOF-Zeichen (CTRL-Z, s.u.) mit einlas,
   * bei Textdateien auf Disk o.Ñ. wird jedoch spÑtestens dann TRUE geliefert,
   * wenn der letzte Lesezugriff Åber das Dateiende hinweg (!) erfolgte.
   *
   * Bei BinÑrdateien wird genau dann TRUE geliefert, wenn der Dateizeiger
   * auf das Ende der Datei zeigt (Length(f)=Pos(f)) (dahinter kann er nicht
   * zeigen; wenn doch, wird's kritisch).
   *)

PROCEDURE SetEOFMode (f: File; checkChar: BOOLEAN; eofChar: CHAR);
  (*
   * Normalerweise wird bei Textdateien das Ende der Datei durch das
   * Zeichen EOF (Ctrl-Z) erkannt oder bei Diskdateien auch durch das
   * physikalische Dateiende.
   * Mit dieser Funktion kann jeweils fÅr die angegebene, offene Datei
   * sowohl das Endezeichen ('eofChar') umdefiniert werden, als auch die
   * Erkennung des Endezeichens ('checkChar') ganz unterdrÅckt werden.
   * In dem Fall wird dann bei Diskdateien die Funktion EOF in jedem Fall
   * nach Åberlesen des Dateiendes TRUE liefern; bei Dateien auf andere
   * Devices, z.B. 'CON:', wird EOF dann nie TRUE liefern.
   *)

PROCEDURE GetEOFMode (f: File; VAR checkChar: BOOLEAN; VAR eofChar: CHAR);
  (* Liefert den gerade eingestellten Modus zum Erkennen des Dateiendes.
   * Darf nur bei Textdateien, die mit 'readSeqTxt' geîffnet wurden,
   * aufgerufen werden, sonst erfolgt Fehlermeldung.
   * Die Voreinstellung, die bei jedem ôffnen einer Textdatei eingestellt
   * wird, ist wie folgt: 'checkChar' = TRUE; 'eofChar' = 32C (=$1A, Ctrl-Z).
   *)


PROCEDURE State (f: File): INTEGER;
  (*
   * Liefert einen positiven Wert, wenn letzte Operation an der Datei keinen
   * Fehler erzeugte, ansonsten eine negative Fehlernummer.
   *
   * Wenn die Datei nicht offen ist (nach Init, Close, Remove), wird
   * 'MOSGlobals.fFileNotOpen' geliefert.
   *)

PROCEDURE GetStateMsg (no: INTEGER; VAR msg: ARRAY OF CHAR);
  (*
   * Liefert in 'msg' einen String (HîchstlÑnge 32 Zeichen), der eine
   * Beschreibung der zugehîrigen Fehlernummer 'no' enthÑlt.
   * Funktion ist identisch mit 'Directory.GetErrMsg'.
   *)

PROCEDURE ResetState (VAR f: File);
  (*
   * Diese Prozedur muû aufgerufen werden, wenn vorher mit Aufruf von
   * 'State' ein Fehler erkannt wurde.
   *)

PROCEDURE Abort (VAR f: File);
  (*
   * Unterbindet alle weiteren Operationen auf dieser Datei.
   * Das bedeutet, daû jegliche weitere Funktionen, bis auf
   * Close, Remove und Init, ignoriert werden - es treten dann
   * auch keine Fehlermeldungen mehr auf.
   * Diese Funktion kann beispielsweise nach Erkennnen eines
   * fatalen Fehlers aufgerufen werden, anstatt weitere im Programmfluû
   * auftretenden Dateioperationen auf andere Weise extra zu vermeiden.
   * Nach Aufruf dieser Funktion wird die Datei wie eine Geschlossene
   * behandelt: Read-Funktionen lesen keine Zeichen, EOF liefert immer
   * TRUE.
   *)

PROCEDURE SysOpen (VAR f: File; REF n: ARRAY OF CHAR; m: Access);
PROCEDURE SysCreate (VAR f: File; REF n: ARRAY OF CHAR; m: Access; r: ReplaceMode);
  (*
   * Diese Funktionen arbeiten z.Zt. wegen Problemen mit dem GEMDOS
   * nicht ordnungsgemÑû und kînnen daher nicht, wie beabsichtigt,
   * verwendet werden.
   *)

    (*****************************************
     * Es folgen Funktionen, die nur system- *
     * intern benutzt werden dÅrfen!         *
     *****************************************)

PROCEDURE @CheckState (f: File): BOOLEAN;

END Files.
