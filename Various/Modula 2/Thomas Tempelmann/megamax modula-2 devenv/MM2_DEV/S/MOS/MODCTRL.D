DEFINITION MODULE ModCtrl;

(*
 * Funktionen des Loadtime-Link-Systems.
 *  - Resident-Machen von Modulen
 *  - Informationen Åber Namen und Adressen von res. Modulen und Prozeduren.
 *  - Starten von Prozeduren als GEMDOS-Prozeû.
 *)

FROM SYSTEM IMPORT LONGWORD, ADDRESS;

FROM MOSGlobals IMPORT MemArea;


PROCEDURE InstallModule (removalInfo: PROC; wsp: MemArea);
  (*
   * Das Modul, von dem aus diese Funktion aufgerufen wird, wird
   * resident gemacht. D.h., daû das Modul, und alle von ihm impor-
   * tierten Module, im Speicher verbleiben, auch wenn sie beendet werden.
   *
   * Dies funktioniert auch bei gelinkten Programmen. Somit ist es sehr
   * einfach, hierÅber residente Programme, z.B. fÅr den AUTO-Ordner,
   * zu erstellen. GegenÅber der Verwendung der GEMDOS-Funktion 'PtermRes'
   * kann hierbei der belegte Speicher spÑter wieder freigegeben werden.
   *
   * Verwaltet das residente Programm irgendwelche Ressourcen (GEM, Speicher,
   * der Åber Storage angefordert wird, usw.), mÅssen statt der normalen
   * Zugriffs-Funktionen (InitGem, ALLOCATE) die zugehîrigen Sys-Funktionen
   * verwendet werden (SysInitGem, SysAlloc)!
   *
   * Ist das Modul, das diesen Aufruf macht, nicht in einem Programm fest
   * eingelinkt, sondern vom Loader (CallModule) gestartet worden, ist
   * es mîglich, daû ohne seine Kontrolle das Grundprogramm, z.B. die Shell,
   * terminiert, sodaû das residente Modul mit freigegeben werden muû.
   * Wird ein Modul also vom Loader dynamisch geladen, kann es nur solange
   * resident bleiben, wie seine Basis, also das Programm, was ihn gestartet
   * hat, im Speicher bleibt.
   *
   * Terminiert also das Basisprogramm, wird das Modul, das InstallModule
   * aufrief, Åber die 'removalInfo'-Routine darÅber informiert ('wsp',
   * der den Stack fÅr diesen Aufruf definiert, kann in der Regel leer
   * sein, dh., 'wsp.bottom' ist NIL zuzuweisen). Die angegebene Prozedur
   * muû dann dafÅr sorgen, daû sie alle Sys-Ressourcen wieder schlieût,
   * damit danach das Basisprogramm ordentlich terminieren kann!
   *
   * Ist das Modul, das InstallModule aufruft, Teil eines gelinkten
   * Programms, bleibt solange im Speicher, wie es will - in diesem
   * Fall gibt es keine Mîglichkeit von auûen, es ohne seine Einwilligung
   * freizugeben (das kann es dann nur selbst mit 'ReleaseModule' erreichen).
   *
   * In den Ordnern des Megamax-Systems befinden sich mehrere Programme,
   * die diese Funktion anschaulich machen:
   *   KbdTest.M  (kurzes Demo-Programm im Ordner DEMO)
   *   ExcDemo.M  (kurzes Demo-Programm im Ordner DEMO)
   *   ModLoad.M  (aufwendiges Hilfs-Programm im Ordner UTILITY)
   *)

PROCEDURE ReleaseModule;
  (*
   * Gibt installiertes Modul wieder frei.
   *
   * Noch geîffnete Resourcen (z.B. Speicher, der mit SysAlloc angefordert
   * wurde) mÅssen vom Programm selbststÑndig wieder freigegeben (hier z.B.
   * DEALLOCATE) werden!
   *
   * Wird diese Funktion von einem gelinkten Programm aufgerufen, wird
   * dabei auch der eigene Speicher des Programms sofort freigegeben.
   * Nach der RÅckkehr aus dieser Funktion lÑuft das Programm eigentlich
   * dann nicht mehr in reserviertem, geschÅtztem Speicher - deshalb sollten
   * die Routinen des Programms auch danach nicht mehr aufgerufen werden -
   * lediglich der RÅcksprung dorthin, von wo aus zum Programmteil gesprungen
   * wurde, der diesen ReleaseModule-Aufruf tÑtigte (z.B. durch eine
   * Interrupt-Routine, die auf das DrÅcken einer bestimmten Tastenkombi-
   * nation zum Freigeben dieses Programms wartete), ist noch sicher.
   *)

PROCEDURE FirstModuleStart (): BOOLEAN;
  (*
   * Liefert TRUE, wenn das Modul, das diese Funktion aufruft,
   * installiert ist und zum ersten Mal gestartet wird.
   *)


TYPE    ModQueryProc= PROCEDURE ( REF (* modName:   *) ARRAY OF CHAR,
                                      (* modAddr:   *) ADDRESS,
                                      (* modLen:    *) LONGCARD,
                                      (* varAddr:   *) ADDRESS,
                                      (* varLen:    *) LONGCARD,
                                  REF (* fileName:  *) ARRAY OF CHAR,
                                      (* module:    *) BOOLEAN,
                                      (* loaded:    *) BOOLEAN,
                                      (* resident:  *) BOOLEAN );

TYPE   ProcQueryProc= PROCEDURE ( REF (* procName: *) ARRAY OF CHAR,
                                      (* procAddr: *) ADDRESS );

(*$H+  erlaubt die öbergabe von lokalen Prozeduren bei den Query-Funktionen *)

PROCEDURE ModQuery (call: ModQueryProc);
  (*
   * Ruft 'call' wiederholt fÅr alle z.Zt. im System vorhandenen Module auf.
   * Damit lassen sich residenten Module anzeigen.
   * Ein Beispiel zeigt das UTILITY-Modul "ModList".
   *)

PROCEDURE QueryImports (REF client: ARRAY OF CHAR; call: ModQueryProc);
  (*
   * Ruft 'call' fÅr alle Importe des residenten Moduls 'client' auf.
   * Ein Beispiel zeigt das UTILITY-Modul "ShowImports".
   *)

PROCEDURE ProcQuery (REF modName: ARRAY OF CHAR;
                         call   : ProcQueryProc;
                     VAR ok     : BOOLEAN);
  (*
   * Ruft 'call' wiederholt fÅr alle globalen Prozeduren des angegebenen
   * Moduls auf.
   * Damit lassen sich alle Prozeduren eines residenten Moduls anzeigen.
   *
   * Liefert 'ok' FALSE, dann ist das Modul entweder nicht vorhanden oder
   * das Modul enthÑlt keine Prozedurnamen (wg. optimiertem Linken oder
   * Verwendung der Direktive $M-). Zur Unterscheidung kann mit "GetProcAddr"
   * ermittelt werden, ob das Modul resident ist.
   *
   * Ein Beispiel zeigt das UTILITY-Modul "ProcList".
   *)

(*$H-*)

PROCEDURE GetModName (     addr    : ADDRESS;
                       VAR modName : ARRAY OF CHAR;
                       VAR relAddr : LONGCARD;
                       VAR procName: ARRAY OF CHAR );
  (*
   * Ermittelt anhand der Adresse in 'addr', in welchem Modul diese
   * Adresse liegt und gibt den Modulnamen in 'modName' zurÅck.
   * Existiert kein Modul an der angegebenen Adresse, wird ein Leer-
   * string in 'modName' geliefert.
   * Ausserdem wird die relative Adresse innerhalb des Moduls in
   * 'relAddr' zurÅckgegeben (relativ zum Code-Beginn).
   * Wenn das Modul eine Prozedur-Namenstabelle (s. M-Direktive)
   * enthÑlt, wird in 'procName' der Name der zugehîrigen Prozedur
   * geliefert, ansonsten ist 'procName' ein Leerstring.
   *)

PROCEDURE GetOwnName (VAR codeName: ARRAY OF CHAR);
  (*
   * Liefert Modulnamen des Moduls, von dem diese Funktion aufgerufen wird.
   *
   * Zur Ermittelung der eigenen rel. Position und des akt. Prozedurnamens
   * siehe die Funktion 'GetScanAddr' im Modul 'SysCtrl'.
   *)

PROCEDURE GetSourceName ( REF codeName  : ARRAY OF CHAR;
                          VAR sourceName: ARRAY OF CHAR;
                          VAR codeOpts  : LONGWORD      );
  (*
   * Liefert den Quelltextnamen des Moduls 'codeName', falls dieses Modul
   * sich z.Zt. eingelinkt (resident) im Speicher befindet.
   * ZusÑtzlich werden die Optionen mitgeteilt, mit denen das Modul
   * compiliert wurde (diese Information ist lediglich f. den Scan-Modus
   * des Compilers interessant).
   *)

PROCEDURE GetProcAddr (name: ARRAY OF CHAR; VAR location: ADDRESS);
  (*
   * Sucht nach einem Modul-/Prozedurnamen in den eingelinkten Modulen
   * und liefert in 'location' dessen Adresse im Speicher.
   * Wird sie nicht gefunden, wird NIL geliefert. Das kann u.A. daran
   * liegen, daû das betroffene Modul mit der $M- Option compiliert
   * wurde, weshalb keine Prozedurnamen vorhanden sind.
   * Die Startadresse des Modul selbst lÑût sich durch alleinige
   * Angabe des Modulnamen ermitteln, Prozedurnamen mÅssen immer
   * durch ihren Modulnamen und einen Punkt zur Trennung angefÅhrt
   * werden.
   * Um die Adresse des Modulkîrpers zu erhalten, muû als Prozedurname
   * wiederum der Modulname angegeben werden.
   * Die Groû-/Kleinschreibung der Namen ist unrelevant.
   * Beispiele:
   *   'Runtime'          liefert Adresse des Runtime-Moduls
   *   'runtime.cap'      liefert Adresse der CAP-Funktion
   *   'mshell.mshell'    liefert Adresse des Initialisierungsteils der Shell
   *)


PROCEDURE CallProcess (    procedure: PROC;
                           workSpace: MemArea;
                       VAR executed : BOOLEAN;
                       VAR exitCode : INTEGER );
  (*
   * Startet eine Prozedur als Prozeû.
   * 'workSpace' bestimmt den Stack fÅr den Prozeû.
   * Von dieser Funktion zusÑtzlich wird ca. 260 - 500 Bytes Speicher
   * angefordert.
   * 'executed' liefert FALSE, wenn der Prozeû nicht gestartet werden konnte
   * (z.B. wegen Speichermangel) - In diesem Fall ist 'exitCode' undefiniert.
   *
   * FÅr diesen neuen Prozeû werden alle Resourcen neu verwaltet (Speicher,
   * GEM-Fenster, usw.). Es werden dazu, ebenso, wie beim Start eines Pro-
   * gramms mittels 'CallModule', die Envelope-/Termination/Removal-Funktionen
   * intern aufgerufen.
   *
   * Achtung: Aufgrund interner Begebenheiten ist es z.Zt. nicht erlaubt,
   *   in solchen als Prozeû gestarteten Prozeduren die Funktion
   *   'InstallModule' aufzurufen - dies kann zu undefinierten Resultaten
   *   fÅhren.
   *)

END ModCtrl.
