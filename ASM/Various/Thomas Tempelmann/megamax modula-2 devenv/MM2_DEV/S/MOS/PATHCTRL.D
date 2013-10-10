DEFINITION MODULE PathCtrl;

(*
 * Erstellung und Kontrolle von Pfadlisten.
 *)

FROM Lists IMPORT List;
FROM MOSGlobals IMPORT PathStr;

TYPE    PathList  = List;
        PathEntry = POINTER TO PathStr;

(*
 * Zur Zeit werden Pfadlisten Åber das Lists-Modul definiert.
 * LÑngerfristig soll dies aber auf eine bequeme Art mîglich sein,
 * die es auch erlaubt, Pfadlisten zu laden und zu speichern, sowie
 * z.B. die Variable 'PATH' aus dem Environment-String zu verwenden.
 * Deshalb ist dies Modul von 'Paths' getrennt, das lediglich die
 * Auswertung der Pfadlisten vornimmt und daher dort keine Definitions-
 * Ñnderungen nîtig werden.
 *
 * Ein Beispiel fÅr eine Pfadlisten-Initialisierung findet sich im
 * Modul 'InitPathList' im DEMO-Ordner.
 *)

END PathCtrl.
