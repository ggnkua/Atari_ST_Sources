(*********************************************************************)
(* Hauptmodul des öbersetzungsprogrammes                             *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 09.10.1991  Frank Mathy                               *)
(* énderung:                                                         *)
(*********************************************************************)

MODULE Programm;


FROM Datenkapsel IMPORT LiesWoerterbuch,SchreibWoerterbuch,
                        LoeschWoerterbuch;
FROM Textdatei IMPORT UebersetzeText;

FROM TermWindow IMPORT InitTerminal,OpenTerminal,CloseTerminal,
                       DeleteTerminal,NewTitle;

PROCEDURE Uebersetze;
(* Hauptprozedur des öbersetzungsprogrammes *)
BEGIN
LiesWoerterbuch;
UebersetzeText;
SchreibWoerterbuch;
LoeschWoerterbuch;
END Uebersetze;


BEGIN
(* Hier Platz fÅr eventuelle Initialisierungen.  *)
InitTerminal(TRUE);
OpenTerminal(-1,-1,-1,-1);

Uebersetze;

(* Hier Platz fÅr Aktionen vor dem Programmende. *)
CloseTerminal;
DeleteTerminal;
END Programm.
