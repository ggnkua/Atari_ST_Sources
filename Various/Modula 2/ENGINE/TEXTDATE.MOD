(*********************************************************************)
(* Implementation-Modul: Textdatei                                   *)
(*-------------------------------------------------------------------*)
(* Textdateiverwaltungs-Modul des šbersetzungsprogrammes: Enth„lt    *)
(* alle Objekte fr die Verwaltung der zu bersetzenden und der      *)
(* bersetzten Textdatei.                                            *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 08.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             08.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* nderung:                                                         *)
(*********************************************************************)


IMPLEMENTATION MODULE Textdatei;


FROM FileSystem IMPORT File;
FROM Woerterbuch IMPORT Worttyp;


 MODULE Wortaufbau; (* Lokales Modul fr Wortaufbau *)

 IMPORT Worttyp,File;
 EXPORT UeberliesNichtbuchstaben,BaueWortauf; (* Zur Verfgung stellen *)


  MODULE Zeichenverarbeitung; (* Lokales Modul mit Zeichenoperationen  *)

  EXPORT IstBuchstabe,InKleinschrift; (* šbergeordnetem Modul anbieten *)

  PROCEDURE IstBuchstabe(z:CHAR; VAR ok:BOOLEAN);
  (* Testet, ob >>z<< ein Buchstabe/Bindestrich/Hochkomma ist. *)
  BEGIN
  END IstBuchstabe;

  PROCEDURE InKleinschrift(VAR z:CHAR);
  (* Wandelt >>z<< in einen Kleinbuchstaben um, soweit Buchstabe. *)
  BEGIN
  END InKleinschrift;

  END Zeichenverarbeitung;


 PROCEDURE UeberliesNichtbuchstaben(VAR datei,neu:File;
                                    VAR startbuchstabe:CHAR;
                                    VAR ende:BOOLEAN);
 (* Dem Wort vorausgehende Nichtbuchstaben aus der Datei >>datei<<
    berlesen und in Datei >>neu<< bernehmen. Ersten Buchstaben in
    >>startbuchstabe<< zurckgeben. Bei Dateiende >>ende<< auf TRUE
    setzen. *)
 BEGIN
 END UeberliesNichtbuchstaben;


 PROCEDURE BaueWortauf(VAR datei,neu:File; startbuchstabe:CHAR;
                       VAR wortdeutsch:Worttyp;
                       VAR laengedeutsch:CARDINAL; VAR ende:BOOLEAN);
 (* Das Wort komplett einlesen und in Kleinbuchstaben konvertieren.
    In >>wortdeutsch<< und >>laengedeutsch<< wird das Wort und die
    Wortl„nge zurckgegeben, bei Dateiende ist >>ende<< gleich TRUE. *)
 BEGIN
 END BaueWortauf;


 END Wortaufbau;


PROCEDURE LiesTextwort(VAR datei,neu:File; VAR wortdeutsch:Worttyp;
                       VAR laengedeutsch:CARDINAL; VAR ende:BOOLEAN);
(* Einlesen eines neuen Wortes >>wortdeutsch<< aus der zu bersetzenden
   Datei >>datei<<, wobei vorausgehende Sonderzeichen in die bersetzte
   Datei >>neu<< direkt bernommen werden. Die L„nge des gelesenen Wortes
   enth„lt >>laengedeutsch<<, >>ende<< wird bei erreichtem Dateiende auf
   >>TRUE<< gesetzt. *)
BEGIN
END LiesTextwort;


PROCEDURE SchreibTextwort(VAR datei:File; wort:Worttyp);
(* Schreiben des Wortes >>wort<< in die Datei >>datei<<. *)
BEGIN
END SchreibTextwort;


PROCEDURE UebersetzeText;
(* Die vom Benutzer auszuw„hlende Textdatei wird schrittweise eingelesen
   und unter Zuhilfenahme des šbersetzungs-Moduls bersetzt in eine
   zweite, neue Datei geschrieben. *)
BEGIN
END UebersetzeText;


END Textdatei.








END Textdatei.
