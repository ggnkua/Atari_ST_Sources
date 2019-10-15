(*********************************************************************)
(* Hauptmodul des öbersetzungsprogrammes                             *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 09.10.1991  Frank Mathy                               *)
(* énderung:                                                         *)
(*********************************************************************)

MODULE Programm;


FROM Woerterbuch IMPORT LiesWoerterbuch,SchreibWoerterbuch,
                        LoeschWoerterbuch;
FROM Textdatei IMPORT UebersetzeText;


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
Uebersetze;
(* Hier Platz fÅr Aktionen vor dem Programmende. *)
END Programm.
