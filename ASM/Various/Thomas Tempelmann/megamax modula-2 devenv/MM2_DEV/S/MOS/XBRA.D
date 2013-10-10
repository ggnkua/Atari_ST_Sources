
DEFINITION MODULE XBRA;

(*
 * Universelle XBRA-Funktionen                        Version 1.2  vom 24.10.90
 *
 * Erstellt von Thomas Tempelmann.
 *
 * Die vorhandenen Funktionen bieten alles, um auf einfache Weise installierte
 * Vektoren zu erkunden (wahlweise alle oder einen spezifischen) und sie
 * korrekt ein-, bzw. wieder auszutragen.
 *
 * Wurde eine Funktion installiert, kann durch die Funktion 'PreviousEntry' die
 * vorher installierte Routine ermittelt werden. Damit ist es dann mîglich,
 * den VorgÑnger in der Funktion selbst aufzurufen, falls dies nîtig wÑre.
 * Die zum Aufrufen notwendigen Funktionen sind jedoch nicht Bestandteil
 * dieser XBRA-Library, da sie erstens Compiler-spezifisch und zweitens
 * sie je nach Anwendung sehr unterschiedlich implementiert werden mÅssen.
 *
 * Die Funktionen sind so ausgelegt, daû sie normalerweise im User-Mode
 * aufgerufen werden und selbst beim Zugriff Åber die Vektoren in den Super-
 * visor-Mode wechseln (das Programm darf sich aber auch bereits im Supervi-
 * sor-Mode befinden). Dies erleichtert dem Programmierer die Anwendung der
 * Funktionen. Da die Anwendungen beim Installieren von Vektoren in der Regel
 * nicht zeitkritisch ausgelegt sein brauchen, sollte man diese KomfortabilitÑt
 * dem leichten Zeitverlust durch - meist - zwei statt nur einem Wechsel vom
 * User- in den Supervisor-Mode vorziehen.
 *
 *
 * Hier noch eine allgemeine Beschreibung zur Anwendung der Funktionen:
 *
 * Folgendermaûen sieht eine XBRA-Installation aus:
 *
 *   vector:= 400H; (* z.B. der 'etv_timer'-Vektor *)
 *   IF NOT Installed ('Test', vector, at) THEN
 *     Create (carrier, 'Test', ADDRESS (TestProzedur), entry);
 *     Install (entry, at)
 *   END;
 *
 * 'Installed' prÅft, ob die Funktion schon mit XBRA-Kennung installiert
 * ist. Wenn nicht, wird mit 'Create' ein XBRA-Header erzeugt, der neben
 * der XBRA-Informationen auch eine Sprunganweisung enthÑlt. Der so
 * erzeugte Header wird dann mit 'Install' als erster neuer Vektor
 * eingetragen und die XBRA-Verkettung erzeugt.
 *
 * Da je nach Implementation verschiedene Prozeduren mit beliebigen
 * Parametern verwendet werden kînnten, und der XBRA-Header nur einfach
 * dazwischengesetzt wird, ist die Prozeduradresse 'call' als ADDRESS
 * deklariert. FÅr die korrekte ParameterÅbergabe haben nicht die XBRA-
 * Funktionen zu sorgen, sondern schon die Routine, die zu installierende
 * Funktion Åber den Vektor aufruft.
 *
 * Zum Vergleich obige Installation ohne XBRA:
 *   vector:= 400H;  (* VAR vector: POINTER TO ADDRESS *)
 *   vector^:= ADDRESS (TestProzedur);
 * Falls es Probleme gibt, sollte erst das Programm ohne XBRA zum Laufen
 * gebracht werden, und dann erst die XBRA-Installation eingefÅgt werden.
 * Z.B. ist zu beachten, daû normalerweise Installationen Åber externe
 * Vektoren Åber die Funktionen aus dem Modul 'Calls' vorgenommen werden
 * sollten. Dies bleibt auch so, wenn dann die XBRA-Funktionen zuhilfe
 * genommen werden!
 *
 * Soll die Funktion spÑter wieder aus der Vektor-Kette ausgehÑngt werden,
 * geht das so:
 *
 *   IF Installed ('Test', vector, at) THEN
 *     Remove (at)
 *   END
 *
 * Bei 'PreviousEntry' (s.o.) wird der bei 'Create' erhaltene 'entry'-Wert
 * wieder Åbergeben, um z.B. in 'TestProzedur' den VorgÑnger zu
 * ermitteln und dann ggf. aufzurufen.
 *
 * 'Query' dient dazu, alle installierten XBRA-Kennungen einer Vektor-
 * Kette zu ermitteln. Dabei kînnen auch z.B. mit folgender Routine alle
 * installierten XBRA-Vektoren ausgehÑngt werden:
 *
 *   PROCEDURE RemoveAll (vector: ADDRESS);
 *
 *     PROCEDURE step (at: ADDRESS; name: Str4): BOOLEAN;
 *       (* darf lokal sein *)
 *       BEGIN
 *         (*
 *          * Hier kînnten der jeweilige VorgÑnger mit
 *          *  'PreviousEntry ( Entry (at) )'
 *          * oder die Adr. der aufgerufenen Prozedur mit
 *          *  'Called (at)'  ermittelt und angezeigt werden.
 *          *)
 *         IF prev # NIL THEN (* ist dies ein XBRA-Eintrag? *)
 *           Remove (at)      (* -> nur dann kann er entfernt werden *)
 *         END;
 *         RETURN TRUE        (* weitermachen, solange die Kette weitergeht *)
 *       END step;
 *
 *     BEGIN
 *       Query (vector, step)
 *     END RemoveAll;
 *
 *
 * Die Demo-Programme 'KbdTest' und 'ExcDemo' im UTILITY-Ordner zeigen
 * die Anwendung dieses Moduls.
 *)

(*$H+*)

FROM SYSTEM IMPORT ADDRESS;

TYPE

  ID = ARRAY [0..3] OF CHAR;            (* String zur Aufnahme der Kennung *)

  JmpCarrier = RECORD                   (* Interne Datenstruktur!     *)
                 jmpInstr: CARDINAL;    (*  - nicht darauf zugreifen! *)
                 operand: ADDRESS
               END;

  Carrier = RECORD      (* Interne Datenstruktur - nicht darauf zugreifen! *)
              magic: ID;                (* CONST 'XBRA' *)
              name : ID;                (* individuelle Kennung *)
              prev : ADDRESS;           (* voriger Vektor *)
              entry: JmpCarrier;
            END;

  QueryProc = PROCEDURE ( (* at  : *) ADDRESS,
                          (* name: *) ID      ): (* continue: *) BOOLEAN;


(*
 * Funktionen fÅr die XBRA-Installation
 * ------------------------------------
 *)

PROCEDURE Create (VAR use: Carrier; name: ID; call: ADDRESS;
                  VAR entry: ADDRESS);
  (*
   * Erzeugt einen XBRA-Header mit einer Sprunganweisung zur Prozedur 'call'.
   * Achtung: die Carrier-Variable muû global (statisch) deklariert sein -
   *   sie muû so lange erhalten bleiben, wie die XBRA-Einbindung besteht!
   * Der erhaltene 'entry'-Wert kann daraufhin mittels der Prozedur 'Install'
   * in den gewÅnschten Vektor eingetragen werden.
   *)

PROCEDURE Installed (name: ID; vector: ADDRESS; VAR at: ADDRESS): BOOLEAN;
  (*
   * Wird 'name' in Kette ab 'vector' gefunden, enthÑlt 'at' die Adresse
   * des Vektors auf den Funktionseinsprung (welcher Teil von 'Carrier' ist).
   * Wird 'name' nicht gefunden, ist 'at'=vector
   *)

PROCEDURE Install (entry: ADDRESS; at: ADDRESS);
  (*
   * FÅgt einen XBRA-Header 'entry' im Vektor 'at' ein. Der alte Vektorinhalt
   * wird im XBRA-Header gesichert und kann mittels 'PreviousEntry' abgefragt
   * werden.
   *)

PROCEDURE Remove (at: ADDRESS);
  (*
   * FÅgt den XBRA-Header, auf den der Vektor bei 'at' zeigt, aus.
   * In den Vektor wird wieder der VorgÑnger eingetragen.
   *)

(*
 * Funktionen zum Abfragen XBRA-Informationen
 * ------------------------------------------
 *)

PROCEDURE Query (vector: ADDRESS; with: QueryProc);
  (*
   * Ruft 'with' fÅr alle im Vektor 'vector' installierten Funktionen auf,
   * solange sie durch XBRA-Strukturen verbunden sind.
   * Die 'with'-Funktion kann 'FALSE' zurÅckgeben, um die Aufrufe vorzeitig
   * zu beenden.
   * 'with' darf auch eine lokale Prozedur sein.
   *)

PROCEDURE Entry (at: ADDRESS): ADDRESS;
  (*
   * Liefert die Adresse, auf die der Vektor 'at' zeigt.
   * Dies ist der "Entry", vor dem ggf. die XBRA-Struktur steht.
   * Das Ergebnis dieser Funktion kann z.B. fÅr die 'PreviousEntry'-Funktion
   * verwendet werden, sollte jedoch nicht zur rein informativen Ermitttelung
   * der in 'at' installierten Funktion verwendet werden - dafÅr ist 'Called'
   * (s.u.) vorgesehen!
   *)

PROCEDURE PreviousEntry (entry: ADDRESS): ADDRESS;
  (*
   * Liefert den "Entry", der vor dem angegebenen "Entry" installiert ist.
   * Diese Funktion kann z.B. in der eigenen installierten Funktion dazu
   * benutzt werden, den VorgÑnger aufzurufen (hier sollte aus Effizienz-
   * grÅnden nicht 'Called' verwendet werden), um eine Aufrufkette zu reali-
   * sieren (ist z.B. beim 200Hz-Vektor sinnvoll, da hier mehrere Routinen
   * hintereinander installiert werden, die alle sich nacheinander aufrufen).
   * Zu diesem Zweck muû dann der bei 'Create' erhaltene 'entry'-Wert Åber-
   * geben werden. Achtung: Da damit gerechnet werden muû, daû wÑhrend der
   * Lebzeit des Programms im Speicher die XBRA-Verkettung jederzeit ver-
   * Ñndert werden kann, darf nicht einmalig fest die VorgÑngeradr. abgefragt
   * und dann Åber eine Programmlokale Variable adressiert werden, sondern
   * muû immer genau dann, wenn sie benîtigt wird, mit dieser Funktion ab-
   * gefragt werden. Es sind dabei keine nennenswerten Zeitverluste zu be-
   * fÅrchten.
   * Wenn 'entry'=NIL, oder kein VorgÑnger ermittelt werden kann (keine XBRA-
   * Struktur vorhanden), wird NIL geliefert.
   *)

PROCEDURE Called (at: ADDRESS): ADDRESS;
  (*
   * Liefert die korrekte Programmeinsprungstelle, die Åber den Vektor 'at'
   * erreicht wird. Dies wÑre normalerweise identisch mit dem Ergebnis der
   * 'Entry'-Funktion, jedoch wird hier erkannt, wenn diese "Entry"-Stelle
   * nur die von diesem Modul erzeugte Sprunganweisung in die eigentliche
   * Funktion ist, die bei der 'Install'-Funktion angegeben wurde. Dann
   * wird jene Funktionsadresse geliefert.
   *)

END XBRA.
