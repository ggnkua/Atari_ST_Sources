DEFINITION MODULE TextLists.
!!!
  > Der Puffer kann dann entweder beim ôffnen auf eine statische Grîûe
    alloziert werden oder ggf auch ein dynamischer Modus aktiviert
    werden.

    Dies Modul kînnte dann von CallModule auch fÅr die 'driver'-Liste
    verwendet werden.

(*
 * Verwaltet Listen von Pfadnamen und bietet Funktionen, um Dateien
 * auf diesen Pfaden zu suchen.
 *)

FROM SYSTEM IMPORT ADDRESS, LOC;
FROM MOSGlobals IMPORT MemArea;

TYPE    TextList;

(* muû opaque sein, damit Kopien des handles immer den selben Desc.
 * verwenden!
 *)
        TextList = RECORD
                     buf : MemArea; (* s. Anmerkung gleich unten *)
                     heap: BOOLEAN; (* TRUE: mit Storage.ALLOCATE angelegt *)
                     seps: ARRAY [0..1] OF CHAR;
                     ptr : ADDRESS; (* Zeiger fÅr div. Zwecke *)
                   END;
          (*
           * Anmerkung: Ist 'buf.length' Null, wird 'buf.bottom'
           * schlicht als Zeiger auf einen Null-terminierten String
           * beliebiger LÑnge verwendet. So kann der String nachtrÑglich
           * verlÑngert werden, allerdings nicht mit den hiesigen, sonst
           * dafÅr vorgesehenen Funktionen, sondern nur durch Direktzugriff
           * auf den String.
           *)


        (*
         * Trennzeichen zwischen den Pfaden:
         *)
        Separator = (dftSep,       (* internes Zeichen, unbestimmt   *)
                     lineSep,      (* CR/LF (zeilenweise)            *)
                     spcSep,       (* Leerzeichen                    *)
                     envSep);      (* ';' (fÅr Environment-Variable) *)

        (*
         * Scanner-Prozedur fÅr 'ScanStrings'
         *)
        ScanProc = PROCEDURE (CARDINAL, VAR ARRAY OF CHAR): BOOLEAN;
                                                   (* RETURN TRUE: continue *)

PROCEDURE InitTextList (VAR handle: TextList);
  (*
   * Setzt 'handle' in einen definierten Zustand:
   * Die Liste enthÑlt keine Pfade.
   *)

PROCEDURE CreateTextList (VAR handle: TextList; size: LONGCARD);
  (*
   * Legt einen Pfad-Puffer mit 'size' Bytes mit hilfe der
   * ALLOCATE-Funktion aus Storage an.
   * Als Separator wird erstmal der interne ('dftSep') definiert.
   * Der Puffer wird gelîscht.
   *
   * Am Ende sollte der Puffer mit 'DeleteTextList' wieder freigegeben
   * werden.
   *)

PROCEDURE DeleteTextList (VAR handle: TextList);
  (*
   * Gibt einen mit 'CreateTextList' reservierten Puffer wieder frei.
   *)

PROCEDURE DefineTextList (VAR handle: TextList; buffer: MemArea);
  (*
   * Alternativ zu 'CreateTextList' kann mit dieser Funktion ein
   * bereits angelegter Puffer (z.B. durch 'SysAlloc' oder eine
   * globale Variable) als Pfadlisten-Puffer initialisiert werden.
   * Als Separator wird erstmal der interne ('dftSep') definiert.
   * Der Puffer wird gelîscht.
   *)

PROCEDURE SetTextList (VAR handle: TextList; buffer: MemArea; sep: Separator);
  (*
   * Wie 'DefineTextList', nur wird davon ausgegangen, daû der
   * angegebene Puffer bereits eine Pfadliste enthÑlt, er wird also
   * nicht gelîscht. Das verwendete Trennzeichen ist in 'sep' anzugeben.
   * Anwendung findet diese Funktion, wenn z.B. die Environment-Variable
   * "PATH" fÅr eine Pfadliste verwendet werden soll (nÑheres im Modul
   * 'Environment', Funktion 'ArgMEM').
   *)

PROCEDURE ClearTextList (VAR handle: TextList);
  (*
   * Lîscht den Puffer
   *)

PROCEDURE Separate (VAR handle: TextList; sep: Separator);
  (*
   * Die Pfade werden mit den in 'sep' angegebenen Trennzeichen
   * getrennt.
   * Dies ist sinnvoll, wenn danach die Liste ausgegeben werden soll,
   * beispielsweise in eine Datei: Wird 'Separate (path, lineSep)'
   * aufgerufen und danach die .............

   *)

PROCEDURE AppendStrings (REF from: TextList; VAR to: TextList);

PROCEDURE AppendString (REF str: ARRAY OF CHAR; VAR to: TextList);

PROCEDURE Reset (VAR handle: TextList);

PROCEDURE GetNext (VAR handle: TextList): BOOLEAN;

PROCEDURE ScanStrings (REF handle: TextList; with: ScanProc);

END TextLists.
