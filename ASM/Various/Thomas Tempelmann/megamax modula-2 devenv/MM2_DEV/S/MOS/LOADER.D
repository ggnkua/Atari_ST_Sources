DEFINITION MODULE Loader;

(* Erstellt 25.10.86 von TT *)

FROM SYSTEM IMPORT ADDRESS;

FROM MOSGlobals IMPORT NameStr;

FROM Lists IMPORT List;

FROM PathCtrl IMPORT PathList;


TYPE    LoaderResults = ( noError,      (* Kein Fehler *)
                          notFound,     (* Datei nicht gefunden *)
                          badFile,      (* Lesefehler der Datei *)
                          badData,      (* Fehler in Dateidaten *)
                          badLayout,    (* Datei ist kein Modul bzw. Prg. *)
                          badVersion,   (* Module haben verschiedene Keys *)
                          notLinkable,  (* Import. Modul ist komprimiert *)
                          outOfMemory,  (* Kein Speicherplatz mehr *)
                          wrongRealForm,(* Falsches Real-Format *)
                          wrongFPUType, (* FPU ist nicht vorhanden *)
                          tooManyCalls, (* Zu viele Programme gestartet *)
                          tooManyMods,  (* Zu viele Module zu starten *)
                          initFault,    (* Fehler wÑhrend Initialisierung *)
                          exitFault,    (* Fehler wÑhrend Deinitialisierung *)
                          notRemoved,   (* Bei Unload: hat noch Klienten *)
                          denied );     (* Bei Call: residentes Modul, *)
                                        (*  bei Unload: Nicht geladen. *)

        LoadingProc = PROCEDURE ( REF (* modName:  *) ARRAY OF CHAR,
                                  REF (* fileName: *) ARRAY OF CHAR,
                                      (* modAddr:  *) ADDRESS,
                                      (* modLen:   *) LONGCARD,
                                      (* varAddr:  *) ADDRESS,
                                      (* varLen:   *) LONGCARD );


VAR DefaultStackSize: LONGCARD;  (* >=1024, default=16384 *)
      (*
       * Stack-Grîûe, die einem Programm zugeteilt wird, das mit
       * 'CallModule' gestartet wird. Allerdings nur bei Programmen,
       * die aus einzelnen Modulen bestehen - bei bereits gelinkten
       * Programmen ist die Stack-Grîûe vorbestimmt und kann nicht mehr
       * beim Starten verÑndert werden. Siehe auch 'LoadModule'.
       *)

    NoPaths: PathList;          (* leere Pfadliste (s.u.) *)
      (*
       * Diese Variable kann bei 'LoadModule' und 'CallModule'
       * angegeben werden, wenn keine Pfadliste benîtigt wird.
       * Das ist der Fall, wenn entweder ein gelinktes Programm
       * geladen/gestartet wird oder wenn die importierten Module
       * schon alle in den Speicher geladen sind (z.B. resident
       * sind) oder wenn sie im aktuellen Verzeichnis liegen.
       *)

    Monitor: PROC;
      (*
       * Wird aufgerufen, bevor das Hauptmodul beim 'CallModule'-Aufruf
       * gestartet wird. Siehe Modul "Monitor" im UTILITY-Ordner.
       *)

    Loading: LoadingProc;
      (*
       * Wird nach dem erfolgreichen Laden eines importierten Moduls
       * aufgerufen. Siehe Modul "ModTrace" im UTILITY-Ordner.
       *)



PROCEDURE IsModule ( REF fileName: ARRAY OF CHAR ): BOOLEAN;
  (*
   * Liefert TRUE, wenn die angegebene Diskdatei ein Modul ist,
   * das von diesem Loader geladen (bzw. gestartet) werden kann.
   * Bei Programmdateien liefert es FALSE, obwohl sie ebenfalls
   * vom Loader geladen/gestartet werden kînnen.
   *)

PROCEDURE CallModule ( REF fileName : ARRAY OF CHAR;
                           paths    : PathList;
                       REF arg      : ARRAY OF CHAR;
                           env      : ADDRESS;
                       VAR exitCode : INTEGER;
                       VAR errMsg   : ARRAY OF CHAR;  (* 80 Zeichen max. *)
                       VAR result   : LoaderResults);
  (*
   * Ruft Modul 'fileName' als Unterprogramm auf. Wenn es sich noch nicht im
   * Speicher befindet, wird versucht, es vom angegebenen Directory-Pfad
   * zu laden. Wird es dort nicht gefunden, werden, sofern 'paths' nicht
   * leer ist, alle Directories, die in 'paths' angegeben sind, in der
   * bestimmten Reihenfolge durchsucht.
   *
   * Werden Module importiert, die sich noch nicht geladen sind, werden
   * sie in allen Directories, die in 'paths' bestimmt sind, gesucht. Da-
   * bei wird der gesuchte Dateiname aus den ersten 8 Zeichen des Modul-
   * namens und der Extension ".IMP" (kann im 'MOSConfig' unbenannt werden)
   * gebildet. Die geladenen Module werden dabei alle unter dem neu erzeug-
   * ten Prozeû gestartet.
   *
   * Wird ein gelinktes Programm gestartet, oder befinden sich alle Module
   * im aktuellen Verzeichnis, kann durch 'NoPaths' bequem eine leere
   * Suchliste angegeben werden.
   *
   * 'arg' ist ein String, der als Argumentstring an das Modul Åbergeben
   * wird. Der String sollte nur aus normal lesbarem Text bestehen, braucht
   * also nicht im ersten Zeichen das LÑngenbyte enthalten, wie es bei der
   * Pexec-Funktion nîtig ist. Nur die ersten 125 Zeichen werden weitergegeben.
   * Wenn allerdings das erste Zeichen im 'arg'-String CHR(127) ist, wird dies
   * als ARGV-Methode (damit kînnen Argumentzeilen mit mehr als 125 Zeichen
   * Åbergeben werden) verstanden und die Zeile wird unverÑndert ans gerufene
   * Programm Åbergeben. Die Argumentzeile muû dann gemÑû dem ARGV-Verfahren
   * zum Teil im Environment Åbergeben werden. Mehr dazu finden Sie in den
   * Dokumentationen von Atari (GEMDOS extended argument (ARGV) specification).
   *
   * 'env' ist ein Zeiger auf ein selbsterzeugtes Environment. Falls Sie
   * nicht wissen, wozu das gut ist, oder kein eigenes erzeugen wollen,
   * Åbergeben Sie NIL!
   *
   * Wenn das Programm normal beendete, enthÑlt 'exitCode' Null. Wenn das
   * Programm mit einem Laufzeitfehler abbrach, enthÑlt 'exitCode' die
   * Fehlernummer (siehe Modul 'MOSConfig'). Wenn das Programm mit der
   * Funktion 'PrgCtrl.TermProcess' endete, enthÑlt 'exitCode' den dort
   * Åbergebenen Wert.
   *
   * 'result' enthÑlt nach Aufruf der Prozedur eine Meldung, ob das
   * Modul ausgefÅhrt werden konnte (dies ist nur der Fall, wenn der Wert
   * 'noError' oder 'exitFault' ist).
   * Wenn 'result' ungleich 'noError' ist, dann wird in 'errMsg' eine
   * Fehlermeldung geliefert.
   *)

PROCEDURE LoadModule ( REF fileName: ARRAY OF CHAR;
                           paths   : PathList;
                       VAR modName : ARRAY OF CHAR;
                       VAR errMsg  : ARRAY OF CHAR;
                       VAR result  : LoaderResults);
  (*
   * LÑdt Modul "fileName" mitsamt aller importierten Module in den Speicher,
   * falls sie sich nicht schon dort befinden. Der Suchvorgang ist derselbe
   * wie bei "CallModule".
   *
   * Das Modul kann dann mit "CallModule" aufgerufen werden, ohne daû es
   * nochmal geladen werden muû. Nachdem das mit "CallModule" aufgerufene
   * Modul beendet ist, bleibt es weiterhin im Speicher, bis es durch
   * "UnLoadModule" freigegeben wird.
   *
   * "modName" liefert nach dem Funktionsaufruf den vollstÑndigen Namen
   * des geladenen Moduls. Er ist z.B. bei "UnloadModule" anzugeben.
   * Werden Module importiert, die noch nicht geladen sind, werden sie
   * sofort mitgeladen aber nicht initialisiert. Wird "fileName" dann mit
   * "CallModule" gestartet, werden die importierten Module initialisiert
   * und bekommen am Ende wieder den Zustand 'nicht initialisiert', damit
   * sie bei erneutem "CallModule"-Aufruf wieder initialisiert werden.
   * "result" enthÑlt nach Aufruf der Prozedur eine Meldung, ob das
   * Modul geladen werden konnte.
   *
   * Wenn "result" ungleich "noError" ist, dann wird in "errMsg" eine
   * Fehlermeldung geliefert.
   *
   * "LoadModule" darf mehrmals hintereinander aufgerufen werden, dann
   * liefert "result" "denied".
   *
   * Wird ein bereits gelinktes Programm (Endungen TOS, PRG usw.) geladen,
   * muû aus technischen GrÅnden der Stack, den das Programm spÑter beim
   * Start benÅtzen wird, schon hier reserviert werden. Da es nicht
   * mîglich ist, die Stackgrîûe des Programms beim Laden zu ermitteln,
   * wird immer soviel reserviert, wie 'DefaultStackSize' (s.o.) angibt.
   * Wenn sich ein geladenes, gelinktes Programm beim Starten anders
   * verhÑlt (wenn z.B. ungewohnte Fehler auftreten), als das gleiche,
   * wenn es vor dem Start nicht mit 'CallModule' geladen wird, dann ist
   * zuerst versuchsweise der Wert in 'DefaultStackSize' zu erhîhen. Der
   * erforderliche Wert kann u.U. auch einige hundert KByte betragen.
   *)

PROCEDURE UnLoadModule ( REF modName : ARRAY OF CHAR;
                         VAR result  : LoaderResults);
  (*
   * Gibt das Modul 'modName' zur Freigabe aus dem Speicher frei.
   * Die Freigabe erfolgt immer unabhÑngig davon, wie oft worher
   * 'LoadModule' aufgerufen wurde. Allerdings kann es sein, daû das
   * Modul nicht sofort aus dem Speicher verschwindet, weil es z.B.
   * noch von anderen Modulen importiert wird oder gerade gestartet
   * wurde und noch nicht endete.
   * 'result' kann die folgenden Werte liefern:
   *   'noError'   : Modul ist entfernt worden.
   *   'notRemoved': Modul bleibt weiterhin im Speicher, da es importiert wird.
   *   'denied'    : Modul war nicht im Speicher vorhanden.
   *)

PROCEDURE SetChain ( REF fileName, arg : ARRAY OF CHAR );
  (*
   * Definiert Modul 'fileName' als Nachfolger nach Modul-Beendigung des
   * aktiven Moduls.
   *
   * 'arg' ist ein String, der als Argumentstring an das nachfolgende
   * Modul Åbergeben wird (nicht mehr als 127 Zeichen !).
   *
   * Diese Funktion kann mehrmals im selben Modullevel aufgerufen werden,
   * jeder Neuaufruf macht dabei den Vorherigen rÅckgÑngig.
   *
   * Ist 'fileName' ein Leerstring, dann wird damit die Funktion wieder
   * rÅckgÑngig gemacht.
   *
   * Das nachfolgende Modul wird in jedem Fall gestartet, auch wenn
   * das bisher aktive mit einem Fehler beendet.
   *
   * Vorsicht: Sollte nach Beendigung des Moduls, das diese Funktion
   * aufrief, das angegebene Nachfolgemodul nicht geladen werden kînnen,
   * wird zum Aufrufer von 'CallMod' mit einer Fehlermeldung in 'result'
   * zurÅckgekehrt, ohne daû dieser erfÑhrt, daû nicht das von ihm aufge-
   * rufene Modul den Fehler verursachte. Lediglich der Fehlermeldungs-
   * text kannn darÅber Aufschluû geben.
   *)

END Loader.
