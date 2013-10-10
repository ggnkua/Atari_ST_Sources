DEFINITION MODULE Environment;

>>> Um die Def Unix/C-kompat. zu machen, das Modul "Env" von Ulrich Kaiser
  berÅcksichtigen!

(*
 * Zugriff auf Environment-Variablen (Abfrage und Setzen).
 *
 * Eine Env-Var hat immer folgendes Format:
 *     NAME=Argument
 * "NAME" muû dabei immer groû geschrieben sein, das Argument ist ein
 * beliebiger Text-String. Leerzeichen vor und hinter dem Gleichheits-
 * zeichen werden von den hiesigen Funktionen ignoriert/entfernt.
 *)

FROM SYSTEM IMPORT ADDRESS;
FROM MOSGlobals IMPORT MemArea;

(*$H+  >> lokale Prozeduren kînnen bei den Scan-Routinen Åbergeben werden *)

(*
 * Funktionen zum Auswerten der eigenen Env-Variablen
 * --------------------------------------------------
 *)

PROCEDURE GetArg (REF name: ARRAY OF CHAR; VAR arg: ARRAY OF CHAR);
  (*
   * Sucht die Env-Var 'name' im Environment.
   * Wird sie gefunden, wird ihr Argument in 'arg' geliefert,
   * sonst ist 'arg' leer.
   *)

PROCEDURE ArgMEM (REF name: ARRAY OF CHAR): MemArea;
  (*
   * Funktion wie 'GetArg', nur wird lediglich die Adresse des
   * Arguments in 'MemArea.bottom' geliefert (ist NIL, wenn die
   * Var nicht vorhanden ist), 'MemArea.length' ist immer NIL.
   *
   * Diese Funktion ist dafÅr vorgesehen, Pfadlisten im Environment,
   * wie z.B. die Argumente der Variable 'PATH', fÅr eine Pfadliste
   * des Moduls 'Paths' zu verwenden. Beispiel:
   *
   *   VAR path: Paths.PathList;
   *   BEGIN
   *     Paths.SetPathList (path, ArgMEM ('PATH'), envSep);
   *
   * Nun kann 'Paths.SearchFile' zu Suchen von Dateien in den unter
   * der Env-Var "PATH" angegebenen Pfaden benutzt werden:
   *
   *     Paths.SearchFile ('DATEN.TXT', path, Paths.fromStart, found, name);
   *
   * Allerdings ist es dann nicht mîglich, diese Pfadliste 'path' mittels
   * der Funktionen im Modul 'Paths' zu verÑndern.
   *)

TYPE EnvScanProc = PROCEDURE ( REF (* name: *) ARRAY OF CHAR;
                               REF (* arg:  *) ARRAY OF CHAR );

PROCEDURE ScanVars (with: EnvScanProc);
  (*
   * Ruft 'with' mit dem String jeder im Environment vorhandenen
   * Variable und ihrem Wert auf.
   *
   * 'with' darf auch eine lokale Prozedur sein!
   *)

(*
 * Zusammensetzen eines Environments fÅr einen Programmaufruf
 * ----------------------------------------------------------
 *
 * Soll in einem gestarteten Programm nicht das komplette eigene
 * Environment (dann wÑre NIL als Env-Ptr bei 'GEMDOS.Pexec' oder
 * 'Loader.CallModule' zu Åbergeben), sondern ein modifiziertes
 * Åbergeben werden, kann es mit den folgenden Funktionen
 * erzeugt werden.
 *
 * Es ist sogar mîglich, das eigene Environment zu verÑndern,
 * indem als 'env'-Parameter (s.u.) die Variable 'CurrentEnv'
 * Åbergeben wird. Nur muû dann darauf geachtet werden, daû
 * in der Regel kein Erweitern des Environments mîglich ist,
 * weil die Grîûe des eigenen, vom Aufrufer erzeugten,
 * Environment-Puffers nur anhand des aktuellen Inhalts
 * bestimmt werden kann. Und damit ist der Env-Puffer am
 * Anfang praktisch immer voll.
 *
 * Soll der eigene Env-Puffer erweitert werden, ohne daû
 * bestehende Variablen entfernt oder ihre Argumente ver-
 * kÅrzt werden sollen, muû dazu mit Hilfe 'CreateEnv' und
 * 'CopyEnv' eine grîûere Kopie angelegt werden (die alte,
 * Originalgrîûe ist aus 'CurrentEnv.length' zu ermitteln).
 * Damit der neue Env-Puffer auch wirklich als neues
 * Environment benutzt wird, mÅssen in der eigenen Base-Page
 * (Adr. mit 'PrgCtrl.GetBasePageAddr' ermitteln) der Zeiger
 * 'p_env' (s. Modul 'SysTypes') und auch die hiesige Variable
 * 'CurrentEnv' umgesetzt werden. Bei Beendigung des Programms
 * muû aber der alte Env-Ptr in der Base Page wieder hergestellt
 * werden!
 *)

TYPE    EnvBuffer = MemArea;  (* Dies ist der Env-Puffer-Zeiger *)

PROCEDURE CreateEnv (VAR env: EnvBuffer; size: LONGCARD; VAR ok: BOOLEAN);
  (*
   * Legt einen Env-Puffer der Grîûe 'size' (in Bytes) an.
   * Alloziert dazu den Speicher mit 'Storage.ALLOCATE'.
   * 'ok' liefert FALSE, wenn nicht mehr ausreichend Speicherplatz
   * vorhanden ist.
   * ZusÑtzlich wird noch der Env-Puffer definiert gelîscht.
   * Am Ende sollte mit 'DeleteEnv' der Puffer wieder freigegeben werden.
   *)

PROCEDURE DeleteEnv (VAR env: EnvBuffer);
  (*
   * Gibt den mit 'CreateEnv' angelegten Puffer wieder frei.
   *)

PROCEDURE DefineEnv (VAR env: EnvBuffer; buffer: MemArea);
  (*
   * Falls Puffer-Adresse und -LÑnge eines Env-Puffers schon bekannt
   * sind, oder der Puffer mit 'SysAlloc' angelegt wurde, kann hiermit
   * die Initialisierung des Puffer-Zeigers erfolgen.
   * (Zwar kînnte dies auch durch direkte Zuweisung auf das Record
   * geschehen, aber "sauberer" ist es, dazu diese Funktion zu benutzen.)
   * ZusÑtzlich wird noch der Env-Puffer definiert gelîscht.
   *)

PROCEDURE ClearEnv (env: EnvBuffer);
  (*
   * Lîscht den Env-Puffer (braucht nicht nach 'CreateEnv' oder 'DefineEnv'
   * aufgerufen werden).
   *)

PROCEDURE AddEnv (fromEnv, toEnv: EnvBuffer; VAR ok: BOOLEAN);
  (*
   * öbernimmt alle Env-Vars von 'fromEnv' nach 'toEnv'. Beide Env-Puffer
   * mÅssen selbstverstÑndlich bereits angelegt bzw. initialisiert sein.
   * Eine hÑufige Anwendung ist, das aktuelle Env. (in 'CurrentEnv')
   * in ein neues zu kopieren, um dort dann Modifikationen vorzunehmen.
   * Kommt eine zu kopierende Env-Var bereits im Ziel-Puffer vor, wird
   * ihr Argument dort von der Neuen Åberschrieben.
   * Ist der Ziel-Puffer zu klein, werden nur soviel Env-Vars kopiert,
   * wie _vollstÑndig_ hineinpassen und 'ok' liefert dann FALSE.
   *)

PROCEDURE SetVar (env: EnvBuffer; name, arg: ARRAY OF CHAR; VAR ok: BOOLEAN);
  (*
   * Falls die Env-Var 'name' noch nicht existiert, wird sie mitsamt
   * ihrem Argument 'arg' und dem erforderlichen Gleichheitszeichen
   * eingefÅgt. Existiert 'name' schon, wird lediglich das Argument
   * 'arg' erneuert.
   * Ist 'arg' leer, wird die Var nicht eingefÅgt, bzw. eine vorhandene
   * Var wird entfernt.
   * 'name' wird vor dem EinfÅgen in Groûbuchstaben umgewandelt.
   * 'ok' liefert FALSE, wenn der Puffer nicht mehr ausreicht. Dann bleibt
   * der Puffer auch unverÑndert.
   *)

VAR CurrentEnv: EnvBuffer;
  (*
   * Zeiger auf das eigene Environment.
   * 'GetArg', 'ArgMEM', 'ScanVars' verwenden immer dieses Environment.
   *
   * Er wird von diesem Modul anfangs automatisch initialisiert
   * (mit dem Env-Zeiger des aktuellen GEMDOS-Prozesses bzw. Programms),
   * kann aber zum Zugriff auf fremde Environments umgesetzt werden.
   *)

END Environment.
