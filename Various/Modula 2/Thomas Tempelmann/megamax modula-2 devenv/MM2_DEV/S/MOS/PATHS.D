DEFINITION MODULE Paths;

(*
 * Dateisuchfunktionen
 * -------------------
 *)

FROM MOSGlobals IMPORT FileStr;
FROM PathCtrl   IMPORT PathList;

CONST   FSelSymbol = '?';
          (*
           * Steht dieses Zeichen am Anfang eines Pfadnamen,
           * rufen 'SearchFile' und 'FullName' den File-Selektor
           * (PathEnv.SelectFile) auf.
           *)

TYPE    ListPos = ( fromStart, fromNext );

PROCEDURE SearchFile ( REF fileName: ARRAY OF CHAR; VAR pathList: PathList;
                       startOfSearch: ListPos;
                       VAR found: BOOLEAN; VAR resultName: ARRAY OF CHAR );
 (*
  * Sucht nach der in 'fileName' angegebenen Datei auf den in 'pathList'
  * aufgelisteten Pfade.
  *
  * 'pathList' muû Åber die Funktionen/Definitionen des Moduls 'PathCtrl'
  * initialisiert werden (z.Zt. als Liste Åber das Modul 'Lists').
  *
  * Wenn 'startOfSearch'='fromStart', dann wird zuerst der im Dateinamen
  * bestimmte Pfad versucht (nicht, wenn kein Pfad angegeben), dann die
  * Pfade der Liste von Beginn an.
  * Wenn als erstes der Defaultpfad des Defaultlaufwerks geprÅft werden
  * soll, muû vor dem Dateinamen ".\" als Pfadbezeichnung stehen.
  *
  * Wenn 'startOfSearch'='fromNext', wird ab dem Listenelement versucht,
  * das dem Augenblicklichen von 'pathList' (siehe Lists-Modul) folgt.
  *
  * Der Suchname kann auch "Wildcards" (z.B. "*.TXT") enthalten, dann
  * wird nach dem Verzeichnis gesucht, in dem mindestens eine dazu
  * passende Datei vorkommt. In 'resultName' wird in diesem Fall aus
  * SichheitsgrÅnden der erste reel existierende Name in dem Verzeichnis
  * geliefert. Soll der gefundene Pfad mit dem Wildcard-Namen weiter-
  * verwendet, werden, um beispielsweise mit Directory.DirQuery alle
  * Dateien auf diesem Pfad zu finden, muû der Name neu aus dem gefundenen
  * Pfad und dem Wildcard zusammengesetzt werden.
  * Beispiel:
  *   suchName:= '*.TXT'
  *   SearchFile ( suchName, pathList, fromStart, found, resultName );
  *   IF found THEN
  *     Directory.ConcatPath (resultName, suchName, resultName);
  * Nun steht in 'resultName' der gefundene Pfad mit dem Wildcard-Namen.
  *
  * 'pathList' zeigt nach dem Aufruf immer auf das zuletzt verwendete Listen-
  * element. Wenn 'found'=TRUE, wurde die Datei unter dem in 'fileName'
  * angegebenen Pfadnamen gefunden; in diesem Fall enthÑlt 'resultName'
  * den Dateinamen mit ggf. vorangehendem Pfadnamen, so wie er in der Pfadliste
  * steht. Wird ein vollstÑndiger Pfadnamen incl. Laufwerks- und Pfad vom
  * Hauptverzeichnis ausgehend benîtigt, ist danach 'Directory.MakeFullPath'
  * aufzurufen.
  *
  * 'found' ist immer TRUE, wenn die Datei auffindbar ist, auch wenn
  * 'resultName' zu klein ist, um den gesamten Namen zu fassen.
  *
  * Wenn ein Pfadname in der Liste '?' (FSelSymbol) ist, dann wird dafÅr
  * die FileSelect-Routine aufgerufen.
  *
  * EnthÑlt ein Pfadname (auch der in 'filename' Åbergebene) als erstes
  * Zeichen das 'HomeSymbol', wird es automatisch durch den 'HomePath'
  * (s.o.) ersetzt.
  * Zu Beachten ist dabei aber, daû immer der zum Zeitpunkt des SearchFile-
  * Aufrufs aktuelle 'HomePath' eingesetzt wird. Der 'HomePath' wird bei
  * jedem Programmstart neu ermittelt!
  *
  * Beispielaufruf zum Suchen eines einmaligen Vorkommens:
  *
  *   filename:= 'D:\TERMINA.TOR'; (* so wird zuerst auf D:\ gesucht *)
  *   SearchFile ( filename, pathList, fromStart, found, filename );
  *   IF found THEN
  *     Files.Open ( f, filename,
  *     ...
  *   END;
  *
  * Beispielaufruf zum Suchen aller Vorkommen in der Pfadliste:
  *
  *   SearchFile ( 'TERMINA.TOR', pathList, fromStart, found, resultname );
  *   WHILE found DO
  *     Files.Open ( f, resultname,
  *     ...
  *     SearchFile ( 'TERMINA.TOR', pathList, fromNext, found, resultname );
  *   END;
  *)

PROCEDURE MakeFullName ( VAR name: ARRAY OF CHAR; maySelect: BOOLEAN;
                         VAR ok: BOOLEAN );
PROCEDURE FullName     ( REF name: ARRAY OF CHAR; maySelect: BOOLEAN ): FileStr;
  (*
   * Wandeln einen Dateinamen (reine Pfadnamen sind hier nicht sinnvoll)
   * in Groûbuchstaben und ersetzen ggf. den 'HomePath'.
   *
   * Ist 'maySelect=TRUE' und 'name[0]' das 'FSelSymbol', wird die
   * File-Selektor-Routine aufgerufen, um den Dateinamen zu erfragen.
   * Ist dies nicht erwÅnscht, muû FALSE fÅr 'maySelect' Åbergeben werden.
   *
   * Geliefert wird immer ein vollstÑndiger Pfadname incl. Laufwerk und
   * Pfad vom Root-Dir ausgehend (es wird dazu 'Directory.MakeFullPath'
   * aufgerufen). Wenn der Pfad nicht existiert, oder wenn bei Aufruf des
   * FileSelektors abgebrochen wurde, wird trotzdem der sich ergebende
   * Name geliefert; 'MakeFullName' setzt dazu entsprechend 'ok'.
   *
   * Diese Funktionen kînnen benutzt werden, um Pfadnamen einer Pfadliste
   * selbst auszuwerten.
   *)

END Paths.
