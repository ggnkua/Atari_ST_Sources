(*********************************************************************)
(* IMPLEMENTATION-Modul: Woerterbuch                                 *)
(* W”rterbuch-Modul des šbersetzungsprogrammes: Enth„lt alle Objekte *)
(* zur Verwaltung des W”rterbuches im Speicher/auf Massenspeicher.   *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 08.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             09.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* Žnderung:                                                         *)
(*********************************************************************)


IMPLEMENTATION MODULE Woerterbuch;


FROM FileSystem IMPORT File;


PROCEDURE InWoerterbuch(wortdeutsch:Worttyp; laengedeutsch:CARDINAL;
                        wortfremd:Worttyp);
(* Die Vokabel mit dem deutschen Wort >>wortdeutsch<< der L„nge
   >>laengedeutsch<< und der šbersetzung >>wortfremd<< wird in den
   Wortschatz aufgenommen. *)
BEGIN
END InWoerterbuch;


PROCEDURE LiesDateiwort(VAR datei:File; VAR wort:Worttyp;
                        VAR laenge:CARDINAL);
(* Einlesen des Wortes >>wort<< aus der Datei >>datei<< mit Rckgabe
   der Wortl„nge in >>laenge<<. *)
BEGIN
END LiesDateiwort;


PROCEDURE LiesWoerterbuch;
(* Einlesen des W”rterbuches vom Datentr„ger in den Speicher *)
BEGIN
END LiesWoerterbuch;


PROCEDURE SchreibDateiwort(VAR datei:File; wort:Worttyp);
(* Schreiben des Wortes >>wort<< in die Datei >>datei<<. *)
BEGIN
END SchreibDateiwort;


PROCEDURE SchreibWoerterbuch;
(* Schreiben des W”rterbuches aus dem Speicher auf Datentr„ger *)
BEGIN
END SchreibWoerterbuch;


PROCEDURE LoeschWoerterbuch;
(* Entfernen des W”rterbuches aus dem Speicher *)
BEGIN
END LoeschWoerterbuch;


BEGIN (* W”rterbuch initialisieren *)
Woerterbuchzeiger:=NIL
END Woerterbuch.
