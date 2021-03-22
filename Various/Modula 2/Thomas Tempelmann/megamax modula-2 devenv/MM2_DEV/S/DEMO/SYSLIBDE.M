
(*
 *      Modul-Skelett zur Verwaltung von System-Ressourcen
 *      --------------------------------------------------
 *                 mit Hilfe von 'ResHandler'
 *                 --------------------------
 *
 * Das folgende Modul 'SysLibSkeleton' ist eine beispielhafte Implementation
 * fÅr das Verwalten von Zugriffen, die erîffnet und wieder geschlossen
 * werden kînnen. Die Module 'Files', 'Excepts' oder 'TextWindows' sind
 * diesbezÅglich Ñhnlich aufgebaut.
 *
 * Problemstellung:
 *   Beim Dateizugriff oder beim Verwenden mehrerer Fenster wird im
 * Allgemeinen ein Zugriff mit einer 'Open'-Funktion erlangt und am
 * Ende mit der entsprechenden 'Close'-Funktion wieder beendet.
 * FÅr dieses Verfahren gibt viele weitere Anwendungen, z.B. fÅr
 * Module, die Stapel (Stacks), Schlangen (Queues) oder Verwenden
 * von Systemvektoren, wie Timer, VBL-Queue, usw., vorsehen.
 *
 *   Im Allgemeinen ist es dabei wÅnschenswert, dem Anwenderprogramm
 * die Arbeit abzunehmen, beim Programmende alle erîffneten Zugriffe
 * wieder zu schlieûen. In der Regel sollte dies zwar am Ende des
 * Programms geschehen aber bei einem Laufzeitfehler oder einfach
 * schlampiger Programmierung sollte das betreffende Modul dies zur
 * Not selbst erledigen kînnen.
 *
 *   Man kann sich nun aber, vor Allem beim Megamax-System, Anwendungen
 * vorstellen, bei denen bei Programmende die Zugriffe erhalten bleiben
 * sollen, so z.B., wenn der Zugriff vom darunter liegenden Prozeû
 * weitergefÅhrt werden soll oder wenn das Programm resident bleiben
 * will und weiterhin die Zugriffe benîtigt.
 *
 *   In den betroffenen MOS-Modulen sind deshalb, wie auch im Handbuch
 * in Kapitel 5.1, unter 'Allg. Hinweise zu den Modulen' vermerkt,
 * 'Sys'-Funktionen vorgesehen. Diese Funktionen dienen dazu, den Zugriff
 * so zu erîffnen, daû er nicht mehr automatisch geschlossen wird.
 * In dem Fall ist dann das Anwenderprogramm wieder ganz und gar selbst
 * fÅr das Schlieûen verantwortlich.
 *
 *   Die folgende Modulimplementation sieht nun alle Funktionen vor, um
 * sowohl das normale, automatische Schlieûen als auch die Sys-Funktion
 * korrekt durchzufÅhren. Das Definitionsmodul muû dazu immer zwei
 * 'Open'-Funktionen (wovon die eine mit 'Sys' beginnt) und eine Close-
 * Funktion enthalten. Weiterhin sind eigene Funktionen zum Zugriff auf
 * die 'Resourcen' implementierbar. Die Namensgebung ist selbstver-
 * stÑndlich beliebig, nur sollte die Sys-Funktion auf jeden Fall mit
 * diesem Prefix ("Sys") beginnen.
 *
 *   Auûerdem ist schon alles vorgesehen, wiederholte, verschiedene
 * Zugriffe zu verwalten, indem fÅr jeden Zugriff ein Record angelegt
 * wird, in dem die spezifischen Daten stehen und alle solche Records
 * in einer Liste verkettet werden. Es ist unumgÑnglich, die Zugriffe
 * untereinander zu verketten, aber sie kînnen natÅrlich auch anders
 * als mit einer Liste realisiert werden.
 *
 *   Die Verwaltung geîffneter Zugriffe in Listen und das automatische
 * Schlieûen wird mit Hilfe des Moduls 'ResHandler' realisiert.
 *
 *   Das Beispielmodul zeigt eine einfache Anwendung, bei der beim
 * ôffnen eines Zugriffs eine Zahl bestimmt werden kann. Mit der
 * Zugriffsfunktion 'DoIt' kann dann eine Textzeile ausgegeben werden,
 * die um soviel Zeichen eingerÅckt ist, wie vorher beim ôffnen bestimmt
 * wurde. FÅr dies einfache Beispiel findet sich ganz am Ende ein Modul,
 * das die Verwendung dieses Systemmoduls demonstiert. Diese gesamte
 * Textdatei kann auf einmal vom Compiler Åbersetzt werden und dann das
 * enthaltene Testmodul mit Ctrl-A von der Shell aus gestartet werden.
 *
 *   Um eigene Systemmodule zu erstellen, sind die Namen im Definitions-
 * text und ggf. die Parameter bei den Open-Funktionen zu Ñndern und
 * eigene Zugriffsroutinen zu deklarieren. Im Implementationsteil mÅssen
 * die Zugriffsroutinen neu programmiert werden (anhand der Beispielrou-
 * tine 'DoIt') und in den Funktionen 'myOpen' und 'myClose' mÅssen ggf.
 * die externen Zugriffe initialisiert bzw. rÅckgesetzt werden. Auûerdem
 * muû das Zugriffs-Record 'MyType' mit den benîtigten Datenfeldern
 * versehen werden.
 *
 *   Alle weiteren énderungsstellen sind im Text mit drei Punkten im
 * Kommentar versehen. Die Kontrollausgaben sollten natÅrlich auch
 * entfernt werden.
 *)


DEFINITION MODULE SysLibSkeleton;

TYPE  Handle;

PROCEDURE OpenIt (VAR hdl: Handle; param: CARDINAL; VAR ok: BOOLEAN);
  (*
   * ôffnet einen Zugriff (Ressource).
   * 'param' bestimmt dabei die EinrÅckungsweite (s. 'DoIt').
   * Bei Prozeûende wird der Zugriff automatisch geschlossen
   *)

PROCEDURE SysOpenIt (VAR hdl: Handle; param: CARDINAL; VAR ok: BOOLEAN);
  (*
   * Wie 'OpenIt', jedoch als 'Sys'-Funktion (siehe Handbuch, Kap. 5.1)
   * Bei Prozeûende wird der Zugriff NICHT automatisch geschlossen, sondern
   * muû manuell vom anwendenden Programm geschlossen werden!
   *)

PROCEDURE DoIt (hdl: Handle; data: ARRAY OF CHAR; VAR ok: BOOLEAN);
  (*
   * Gibt Textzeile aus, eingerÅckt um den Wert, der beim ôffnen des
   * Zugriffs f. 'hdl' angegeben wurde.
   *)

PROCEDURE CloseIt (VAR hdl: Handle);
  (*
   * Beendet Zugriff auf 'hdl'
   *)

END SysLibSkeleton.

(* ----------------------------------------------------------------------- *)

IMPLEMENTATION MODULE SysLibSkeleton;

(*$Y+  Kennzeichnung fÅr Systemmodule mit "shared data" (s. Handbuch) *)

FROM SYSTEM IMPORT ADDRESS, ADR;
FROM Storage IMPORT SysAlloc, DEALLOCATE;
FROM ErrBase IMPORT RtnCond, ErrResp, RaiseError;
FROM MOSGlobals IMPORT OutOfMemory;
FROM ResHandler IMPORT Resource, CreateResource,
                       InsertHandle, InsertSysHandle,
                       RemoveHandle, HandleInList;

(* ... werden ggf. nicht benîtigt: *)
  IMPORT TOSIO, InOut, Strings;


TYPE MyType = RECORD
                (* ... hier folgen die eigenen Datenfelder: *)
                  col: CARDINAL;
              END;

TYPE Handle = POINTER TO MyType;      (* Der Opaque Typ wird redeklariert *)

VAR HandleList: Resource;             (* Liste zum Verketten der Zugriffe *)


PROCEDURE myClose (hdlAddr: ADDRESS; user: BOOLEAN);
  (*
   * Diese Prozedur Åbernimmt das Schlieûen eines Zugriffs und wird
   * bei '(Sys)InsertHandle' als Parameter fÅr die Freigabeprozedur
   * Åbergeben.
   *)
  VAR hdl: Handle;
  BEGIN
    hdl:= hdlAddr; (* Initialisierung (Typkonvertierung) *)
    WITH hdl^ DO
      (* ... hier mÅssen ggf. RÅcksetzungen erfolgen, wie *)
      (*     z.B. verÑnderte Vektoren wiederherzustellen. *)
      IF user THEN
        InOut.WriteString( 'Der Benutzer ');
      ELSE
        InOut.WriteString( 'Das System ');
      END;
      InOut.WriteString ('schlieût den Zugriff auf Spalte ');
      InOut.WriteCard (col, 0);
      InOut.WriteLn;
    END;
    DEALLOCATE (hdl, 0)     (* Speicher f. Record freigeben *)
  END myClose;

PROCEDURE myOpen ( VAR hdl     : Handle;
                       param   : CARDINAL;
                   VAR ok      : BOOLEAN;
                       sysLevel: BOOLEAN);
  (*
   * Ist sysLevel 'TRUE', dann wird der Zugriff bei Prozessende nicht
   * automatisch geschlossen.
   *)
  VAR strOk, found, error: BOOLEAN;
  BEGIN
    ok:= FALSE;
    (* Nur neu îffnen, wenn Zugriff noch nicht geîffnet ist: *)
    IF NOT HandleInList (HandleList, hdl) THEN
      (*
       * Nun Speicher fÅr Record anfordern. Dazu wird eine 'Sys'-Funktion
       * benutzt (wichtig!!), damit dieser auch 'InsertSysHandle' Åberlebt.
       * Auch, wenn andere Ressourcen (GEM, Vektoren, Prozesse, usw.) hier
       * angelegt werden, sollten mîglichst immer 'Sys'-Funktion dazu ver-
       * wendet werden. Ist dies nicht mîglich, darf hier auch keine Sys-
       * Funktion angeboten werden, damit's nicht schiefgeht!
       * NatÅrlich kann dieses Modul auch Dinge tun, wozu Åberhaupt keine
       * externen Ressourcen (wie der Speicher fÅr das Record) geîffnet werden
       * mÅssen, z.B. wenn hier nur damit ein Daten-Stack aufgebaut wird.
       * Dann kann hier natÅrlich problemlos eine Sys-Funktion angeboten
       * werden.
       *)
      SysAlloc (hdl, SIZE (hdl^));
      IF hdl # NIL THEN
        (* Record in der Resource-Liste HandleList verketten *)
        IF sysLevel THEN
          (* System-Zugriff; nur verwenden, wenn der Rest (Speicher, usw.)
           * auch mit Sys-Funktionen angelegt wurde! *)
          InsertSysHandle (HandleList, hdl, myClose, error);
        ELSE
          (* normaler Zugriff *)
          InsertHandle (HandleList, hdl, myClose, error);
        END;
        IF error THEN
          DEALLOCATE (hdl, 0)
        ELSE
          WITH hdl^ DO
            (* ... hier folgen eigene Initialisierungen *)
            (* ... und Zuweisungen der Record-Felder:   *)
              col:= param;
          END;
          ok:= TRUE
        END
      END
    END
  END myOpen;

PROCEDURE OpenIt (VAR hdl: Handle; param: CARDINAL; VAR ok: BOOLEAN);
  (*
   * Normales Erîffnen eines Zugriffs (einer Ressource).
   *)
  BEGIN
    myOpen (hdl, param, ok, FALSE)
  END OpenIt;

PROCEDURE SysOpenIt (VAR hdl: Handle; param: CARDINAL; VAR ok: BOOLEAN);
  (*
   * Dauerhaftes Erîffnen eines Zugriffs (einer Ressource).
   *)
  BEGIN
    myOpen (hdl, param, ok, TRUE)
  END SysOpenIt;


PROCEDURE DoIt (hdl: Handle; data: ARRAY OF CHAR; VAR ok: BOOLEAN);
  (*
   * Operation auf dem Zugriff (auf der Ressource)
   *)
  BEGIN
    (* Existiert Zugriff Åberhaupt ? *)
    IF HandleInList (HandleList, hdl) THEN
      WITH hdl^ DO                   (* ja, dann ist der 'handle' gÅltig. *)
        (* ...hier wird ein Zugriff durchgefÅhrt: *)
        InOut.WriteString (Strings.Space (col));  (* 'col' aus Record *)
        InOut.WriteString (data);
        InOut.WriteLn;
      END
    END
  END DoIt;


PROCEDURE CloseIt (VAR hdl: Handle);
  BEGIN
    (*
     * Falls der angegebene Zugriff noch existiert, wird der
     * belegte Speicher freigegeben und der Zugriff aus der Liste
     * 'HandleList' gelîscht.
     *)
    RemoveHandle (HandleList, hdl)
  END CloseIt;


VAR error: BOOLEAN;

BEGIN
  CreateResource (HandleList, error);
  IF error THEN
    RaiseError (OutOfMemory, '', selfCaused, mustAbort)
  END;
END SysLibSkeleton.

(* ----------------------------------------------------------------------- *)

MODULE SysLibDemo;

(*
 * Dies Modul demonstiert die Anwendung des obigen Beispielmoduls.
 *
 * Es îffnet erst zwei Zugriffe, dann wendet es die Zugriffsfunktionen an,
 * dann startet es einen Tochterprozeû, welcher ebenfalls zwei Zugriffe
 * erîffnet. Einer der Zugriffe wird mit der Sys-Funktion geîffnet. Der
 * Prozeû gibt auch mit 'DoIt' Text aus und endet dann, ohne die Zugriffe
 * zu schlieûen. Der eine Zugriff wird sodann vom Systemmodul geschlossen,
 * wÑhrend der Sys-Zugriff erhalten bleibt. Dann werden im ersten Prozeû
 * wieder Ausgaben mit 'DoIt' gemacht, wobei auch der noch vorhandene
 * Sys-Zugriff benutzt wird. Am Ende wird dann einer der beiden ersten
 * Zugriffe ordnungsgemÑû geschlossen, sodaû das Systemmodul den anderen
 * wiederum automatisch schlieût.
 *
 * Der Sys-Zugriff muû (immer) explizit geschlossen werden, was in der
 * 'Termination'-Funktion geschieht, die zuvor mit 'CatchProcessTerm'
 * einen Aufruf bei Prozeûende angefordert hat. Dies ist besser, als am
 * Ende des Programmtextes diesen Aufruf durchzufÅhren, weil bei einem
 * Laufzeitfehler diese Programmstelle nicht mehr erreicht werden wÅrde
 * und der Zugriff fÅr immer (bis zum Reset des Rechners) als "Leiche"
 * im Speicher verleiben wÅrde.
 *
 * Die Fehlerabfragen ('ok') wurden absichtlich weggelassen, da hier sowieso
 * alles funktionieren sollte (Speicher sollte ausreichen).
 *)

IMPORT GEMDOSIO; (*$E MOS ..machen wir ein TOS-Programm draus. *)

FROM SYSTEM IMPORT ADR;
FROM SysLibSkeleton IMPORT Handle, OpenIt, SysOpenIt, DoIt, CloseIt;
FROM MOSGlobals IMPORT MemArea;
FROM ModCtrl IMPORT CallProcess;
FROM ResCtrl IMPORT CatchRemoval, RemovalCarrier;
FROM PrgCtrl IMPORT CatchProcessTerm, TermCarrier;
IMPORT InOut;

MODULE local;

  (*
   * Dies lokale Modul enthÑlt eine Prozedur, die als neuer Prozeû unter
   * dem Hauptprogramm gestartet wird.
   * Ebenso kînnte zur Demonstration mit 'Loader.CallModule' ein anderes
   * Modul als Tochterprozeû gestartet werden, das dann 'SysLibSkeleton'
   * importiert und die im Folgenden gezeigten Funktionen aufruft.
   *)

  IMPORT Handle, OpenIt, SysOpenIt, DoIt, CloseIt;
  IMPORT InOut;

  EXPORT otherProgram, sysHdl;

  VAR sysHdl: Handle;

  PROCEDURE otherProgram;
    VAR ok: BOOLEAN;
        hdl: Handle;
    BEGIN
      (* Normalen Zugriff zu diesem Prozeû îffnen *)
      OpenIt (hdl, 12, ok);
        InOut.WriteString ('ôffne Zugriff auf Spalte 12');
        InOut.WriteLn;

      (* Dauerhaften Zugriff îffnen *)
      SysOpenIt (sysHdl, 14, ok);
        InOut.WriteString ('ôffne Sys-Zugriff 2 auf Spalte 14');
        InOut.WriteLn;

      DoIt (hdl,    'Dies ist 2. Prozeû, normaler Zugriff', ok);
      DoIt (sysHdl, 'Dies ist 2. Prozeû, Sys-Zugriff', ok)

      (* Der Sys-Zugriff soll nicht geschlossen werden, da im *)
      (* Vaterprozeû noch darauf zugegriffen werden wird..    *)
      (* Der andere Prozeû wird einfach vergessen - er wird   *)
      (* vom Systemmodul geschlossen werden.                  *)
    END otherProgram;

  END local;

PROCEDURE Removal;
  VAR wait: CHAR;
  BEGIN
    InOut.WriteLn;
    InOut.WriteString ('Taste...');
    InOut.Read (wait);
  END Removal;

PROCEDURE Termination;
  VAR wait: CHAR;
  BEGIN
    (* Der Sys-Zugriff muû spÑtestens hier geschlossen werden, sonst bleibt
     * er fÅr immer geîffnet (und belegt damit unnîtig Speicher). *)
    InOut.WriteString ('Schlieûe manuell Sys-Zugriff auf Spalte 14:');
    InOut.WriteLn;
    CloseIt (sysHdl);
    InOut.WriteLn;
    (* ... hier kînnten eigene Ressourcen geschlossen werden. *)
  END Termination;

VAR ok: BOOLEAN;
    exitCode: INTEGER;                  (* Exit-Code von 2. Prozeû *)
    stack: ARRAY [1..4096] OF CARDINAL; (* Stack fÅr 2. Prozeû: 8 KB *)
    wsp: MemArea;
    rCarrier: RemovalCarrier;
    tCarrier: TermCarrier;

    hdl: ARRAY [1..2] OF Handle;        (* 'Handles' fÅr zwei Zugriffe *)

BEGIN
  (* Bei Programmende soll 'Removal' aufgerufen werden, um auf einen
   * Tastendruck zu warten: *)
  wsp.bottom:= NIL; (* Damit wird der Stack des Hauptprozesses benutzt *)
  CatchRemoval (rCarrier, Removal, wsp);

  (* Bei Prozeûende soll 'Termination' aufgerufen werden *)
  wsp.bottom:= NIL;  (* Damit wird der Stack des Hauptprozesses benutzt *)
  CatchProcessTerm ( tCarrier, Termination, wsp );
    (* Hier hÑtte auch 'CatchRemoval' verwendet werden  *)
    (* kînnen, da dies beim Hauptmodul, sofern es nicht *)
    (* resident ist, keinen Unterschied macht.          *)

  (* Ersten Zugriff îffnen *)
  OpenIt (hdl [1], 2, ok);
    InOut.WriteString ('ôffne Zugriff 1 auf Spalte 2');
    InOut.WriteLn;
  (* Zweiten Zugriff îffnen *)
  OpenIt (hdl [2], 4, ok);
    InOut.WriteString ('ôffne Zugriff 2 auf Spalte 4');
    InOut.WriteLn;

  (* Funktionen auf die beiden Zugriffe durchfÅhren *)
  DoIt (hdl [1], 'Dies ist 1. Prozeû, Zugriff 1', ok);
  DoIt (hdl [2], 'Dies ist 1. Prozeû, Zugriff 2', ok);

  (* Tochterprozeû starten *)
  InOut.WriteLn;
  wsp.bottom:= ADR (stack);
  wsp.length:= SIZE (stack);
  CallProcess (otherProgram, wsp, ok, exitCode);
  InOut.WriteLn;

  (* Funktionen auf die beiden Zugriffe dieses Prozesses und des    *)
  (* residenten, vom Tochterprozeû geîffneten, Zugriffs durchfÅhren *)
  DoIt (hdl [2], 'Dies ist wieder 1. Prozeû, Zugriff 2', ok);
  DoIt (hdl [1], 'Dies ist wieder 1. Prozeû, Zugriff 1', ok);
  DoIt (sysHdl,  'Dies ist der Sys-Zugriff', ok);

  (* Einen der hier geîffneten Zugriffe selber schlieûen,  *)
  (* der andere wird testweise vom Systemmodul geschlossen *)
  InOut.WriteLn;
  InOut.WriteString ('Schlieûe manuell Zugriff 2 auf Spalte 4:');
  InOut.WriteLn;
  CloseIt (hdl [2]);

  InOut.WriteLn

END SysLibDemo.
