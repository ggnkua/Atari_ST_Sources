(*********************************************************************)
(* Implementation-Module: Uebersetzung                               *)
(*-------------------------------------------------------------------*)
(* šbersetzungs-Modul des šbersetzungsprogrammes: Modul mit Objekten *)
(* zum Auffinden der šbersetzung eines gegebenen Wortes unter        *)
(* Zuhilfenahme des W”rterbuches.                                    *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 08.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             08.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* Žnderung:                                                         *)
(*********************************************************************)


IMPLEMENTATION MODULE Uebersetzung;


FROM Woerterbuch IMPORT Worttyp,Vokabelsatz,Woerterbuchzeiger;


PROCEDURE HoleFremdwort(wortdeutsch:Worttyp; laengedeutsch:BOOLEAN;
                        VAR wortfremd:Worttyp; VAR ok:BOOLEAN);
(* Fr das deutsche Wort >>wortdeutsch<< mit der L„nge >>laengedeutsch<<
   wird im W”rterbuch nach einer šbersetzung gesucht. Ist diese vorhanden,
   so wird sie in >>wortfremd<< zurckgegeben und >>ok<< auf TRUE gesetzt,
   andernfalls auf FALSE. *)
BEGIN
END HoleFremdwort;


PROCEDURE VergleicheWoerter(wort1,wort2:Worttyp; VAR ok:BOOLEAN);
(* Die zwei W”rter >>wort1<< und >>wort2<< werden verglichen. Bei
   Gleichheit liefert die Prozedur in >>ok<< TRUE zurck. *)
BEGIN
END VergleicheWoerter;


PROCEDURE FindeUebersetzung(wortdeutsch:Worttyp; laengedeutsch:CARDINAL;
                            VAR wortfremd:Worttyp);
(* Sucht die šbersetzung >>wortfremd<< fr das deutsche Wort
   >>wortdeutsch<< mit der L„nge >>laengedeutsch<<. Ist kein Eintrag
   im W”rterbuch vorhanden, so wird der Benutzer zur Worteingabe
   aufgefordert, die darauf in den Wortschatz aufgenommen wird. Gibt
   der Benutzer kein Wort ein, so wird das Fremdwort direkt bernommen. *)
BEGIN
END FindeUebersetzung;


END Uebersetzung.
