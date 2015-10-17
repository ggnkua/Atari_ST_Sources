DEFINITION MODULE Paths;

!!!
  > vielleicht ein Modul "TextLists" erstellen, das speziell fÅr Listen
    von Strings ausgelegt ist.
    Der Puffer kann dann entweder beim ôffnen auf eine statische Grîûe
    alloziert werden oder ggf auch ein dynamischer Modus aktiviert
    werden.
    Dies Modul kînnte dann von CallModule auch fÅr die 'driver'-Liste
    verwendet werden.
    Vielleicht lÑût sich das auch mit den STR-Dateien, wie bei HÑnisch,
    kombinieren?

(*
 * Verwaltet Listen von Pfadnamen und bietet Funktionen, um Dateien
 * auf diesen Pfaden zu suchen.
 *)

FROM SYSTEM IMPORT ADDRESS, LOC;
FROM MOSGlobals IMPORT MemArea;

TYPE    PathList = RECORD
                     buf : MemArea; (* s. Anmerkung gleich unten *)
                     heap: BOOLEAN;
                     seps: ARRAY [0..1] OF CHAR
                   END;
          (*
           * Anmerkung: Ist 'mem.length' Null, wird 'mem.bottom'
           * schlicht als Zeiger auf einen Null-terminierten String
           * beliebiger LÑnge verwendet. So kann der String nachtrÑglich
           * verlÑngert werden, allerdings nicht mit den hiesigen, sonst
           * dafÅr vorgesehenen, Funktionen, sondern durch Direktzugriff
           * auf den String.
           *)

(*
 * Auswerten der Pfadlisten
 * ------------------------
 *)

problem:
  die pfadlisten sind nun extern, beim aufrufer, gespeichert. dort werden
  ggf. mehrere pro prozeû angelegt.
(*
 * Verwalten der Pfadlisten
 * ------------------------
 *)

        (*
         * Trennzeichen zwischen den Pfaden:
         *)
        Separator = (dftSep,       (* internes Zeichen, unbestimmt   *)
                     lineSep,      (* CR/LF (zeilenweise)            *)
                     spcSep,       (* Leerzeichen                    *)
                     envSep);      (* ';' (fÅr Environment-Variable) *)

PROCEDURE InitPathList (VAR handle: PathList);
  (*
   * Setzt 'handle' in einen definierten Zustand:
   * Die Liste enthÑlt keine Pfade.
   *)

PROCEDURE CreatePathList (VAR handle: PathList; size: LONGCARD);
  (*
   * Legt einen Pfad-Puffer mit 'size' Bytes mithilfe der
   * ALLOCATE-Funktion aus Storage an.
   * Als Separator wird erstmal der Interne ('dftSep') definiert.
   * Der Puffer wird gelîscht.
   *
   * Am Ende sollte der Puffer mit 'DeletePathList' wieder freigegeben
   * werden.
   *)

PROCEDURE DeletePathList (VAR handle: PathList);
  (*
   * Gibt einen mit 'CreatePathList' reservierten Puffer wieder frei.
   *)

PROCEDURE DefinePathList (VAR handle: PathList; buffer: MemArea);
  (*
   * Alternativ zu 'CreatePathList' kann mit dieser Funktion ein
   * bereits angelegter Puffer (z.B. durch 'SysAlloc' oder eine
   * globale Variable) als Pfadlisten-Puffer initialisiert werden.
   * Als Separator wird erstmal der Interne ('dftSep') definiert.
   * Der Puffer wird gelîscht.
   *)

PROCEDURE SetPathList (VAR handle: PathList; buffer: MemArea; sep: Separator);
  (*
   * Wie 'DefinePathList', nur wird davon ausgegangen, daû der
   * angegebene Puffer bereits eine Pfadliste enthÑlt, er wird also
   * nicht gelîscht. Das verwendete Trennzeichen ist in 'sep' anzugeben.
   * Anwendung findet diese Funktion, wenn z.B. die Environment-Variable
   * "PATH" fÅr eine Pfadliste verwendet werden soll (nÑheres im Modul
   * 'Environment', Funktion 'ArgMEM'.
   *)

PROCEDURE ClearPathList (VAR handle: PathList);
  (*
   * Lîscht den Puffer
   *)

PROCEDURE Separate (handle: PathList; sep: Separator);
  (*
   * Die Pfade werden mit den in 'sep' angegebenen Trennzeichen
   * getrennt.
   * Dies ist sinnvoll, wenn danach die Liste ausgegeben werden soll,
   * beispielsweise in eine Datei: Wird 'Separate (path, lineSep)'
   * aufgerufen und danach die .............

   *)

PROCEDURE AppendPaths (from: PathList; VAR to: PathList);

PROCEDURE AppendPath (path: ARRAY OF CHAR; VAR to: PathList);

END Paths.
