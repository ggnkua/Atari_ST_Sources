(*********************************************************************)
(* Implementation-Modul: Textdatei                                   *)
(*-------------------------------------------------------------------*)
(* Textdateiverwaltungs-Modul des �bersetzungsprogrammes: Enth�lt    *)
(* alle Objekte f�r die Verwaltung der zu �bersetzenden und der      *)
(* �bersetzten Textdatei.                                            *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 08.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             08.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* �nderung:                                                         *)
(*********************************************************************)


IMPLEMENTATION MODULE Textdatei;

FROM FileSystem IMPORT File,ReadChar,WriteChar,GetPos,SetPos,
                       Lookup,Close,Response;
FROM AbstrakteVokabelliste IMPORT WortTyp;
FROM Uebersetzung IMPORT FindeUebersetzung;
FROM TermWindow IMPORT NewTitle,Redraw,WaitForRedraw;

IMPORT Filename;


 MODULE Wortaufbau; (* Lokales Modul f�r Wortaufbau *)

 IMPORT WortTyp,File,ReadChar,WriteChar,GetPos,SetPos;
 EXPORT UeberliesNichtbuchstaben,BaueWortauf; (* Zur Verf�gung stellen *)


  MODULE Zeichenverarbeitung; (* Lokales Modul mit Zeichenoperationen  *)

  EXPORT IstBuchstabe,InKleinschrift; (* �bergeordnetem Modul anbieten *)

  PROCEDURE IstBuchstabe(z:CHAR; VAR ok:BOOLEAN);
  (* Testet, ob >>z<< ein Buchstabe/Bindestrich/Hochkomma ist. *)
  BEGIN
  ok:=(((z>='a')AND(z<='z')) OR ((z>='A')AND(z<='Z')) OR
       (z='�')OR(z='�')OR(z='�')OR(z='�')OR(z='�')OR(z='�')OR
       (z='�')OR(z="'"))
  END IstBuchstabe;

  PROCEDURE InKleinschrift(VAR z:CHAR);
  (* Wandelt >>z<< in einen Kleinbuchstaben um, soweit Buchstabe. *)
  BEGIN
  CASE z OF
    'A'..'Z':  z:=CHR(ORD(z)+32);
  | '�':       z:='�';
  | '�':       z:='�';
  | '�':       z:='�';
    ELSE
    END; (* CASE *)
  END InKleinschrift;

  END Zeichenverarbeitung;


 PROCEDURE UeberliesNichtbuchstaben(VAR datei,neu:File;
                                    VAR startbuchstabe:CHAR;
                                    VAR ende:BOOLEAN);
 (* Dem Wort vorausgehende Nichtbuchstaben aus der Datei >>datei<<
    �berlesen und in Datei >>neu<< �bernehmen. Ersten Buchstaben in
    >>startbuchstabe<< zur�ckgeben. Bei Dateiende >>ende<< auf TRUE
    setzen. *)
 VAR ok:BOOLEAN;
     z:CHAR;
 BEGIN
 ende:=FALSE;
 ReadChar(datei,z);
 IstBuchstabe(z,ok);
 LOOP
   IF ok THEN EXIT END;
   WriteChar(neu,z);
   IF datei.eof THEN
       ende:=TRUE;
       RETURN;
       END; (* IF *)
   ReadChar(datei,z);
   IstBuchstabe(z,ok);
   END; (* LOOP *)
 startbuchstabe:=z;
 END UeberliesNichtbuchstaben;

 PROCEDURE Rueckschritt(VAR datei:File);
 (* Dateizeiger ein Zeichen zur�ck *)
 VAR Position:LONGINT;
 BEGIN
 GetPos(datei,Position);
 DEC(Position,1);
 SetPos(datei,Position);
 END Rueckschritt;

 PROCEDURE BaueWortauf(VAR datei,neu:File; startbuchstabe:CHAR;
                       VAR wortdeutsch:WortTyp;
                       VAR laengedeutsch:CARDINAL; VAR ende:BOOLEAN);
 (* Das Wort komplett einlesen und in Kleinbuchstaben konvertieren.
    In >>wortdeutsch<< und >>laengedeutsch<< wird das Wort und die
    Wortl�nge zur�ckgegeben, bei Dateiende ist >>ende<< gleich TRUE. *)
 VAR z:CHAR;
     ok:BOOLEAN;
 BEGIN
 ende:=FALSE;
 laengedeutsch:=0;
 z:=startbuchstabe;
 LOOP
   InKleinschrift(z);
   wortdeutsch[laengedeutsch]:=z;
   laengedeutsch:=laengedeutsch+1;
   IF datei.eof THEN
       ende:=TRUE;
       EXIT;
       END; (* IF *)
   ReadChar(datei,z);
   IstBuchstabe(z,ok);
   IF NOT ok THEN
       Rueckschritt(datei);
       EXIT;
       END; (* IF *)
   END; (* LOOP *)
 wortdeutsch[laengedeutsch]:=CHR(0);
 END BaueWortauf;

 END Wortaufbau;


PROCEDURE LiesTextwort(VAR datei,neu:File; VAR wortdeutsch:WortTyp;
                       VAR laengedeutsch:CARDINAL; VAR ende:BOOLEAN);
(* Einlesen eines neuen Wortes >>wortdeutsch<< aus der zu �bersetzenden
   Datei >>datei<<, wobei vorausgehende Sonderzeichen in die �bersetzte
   Datei >>neu<< direkt �bernommen werden. Die L�nge des gelesenen Wortes
   enth�lt >>laengedeutsch<<, >>ende<< wird bei erreichtem Dateiende auf
   >>TRUE<< gesetzt. *)
VAR startbuchstabe:CHAR;
BEGIN
laengedeutsch:=0;
UeberliesNichtbuchstaben(datei,neu,startbuchstabe,ende);
IF NOT ende THEN
   BaueWortauf(datei,neu,startbuchstabe,wortdeutsch,laengedeutsch,ende);
   END; (* IF *)
END LiesTextwort;


PROCEDURE SchreibTextwort(VAR datei:File; wort:WortTyp);
(* Schreiben des Wortes >>wort<< in die Datei >>datei<<. *)
VAR buchstabe:CARDINAL;
BEGIN
buchstabe:=0;
WHILE wort[buchstabe] <> CHR(0) DO
   WriteChar(datei,wort[buchstabe]);
   buchstabe:=buchstabe+1
   END; (* WHILE *)
END SchreibTextwort;


PROCEDURE UebersetzeText;
(* Die vom Benutzer auszuw�hlende Textdatei wird schrittweise eingelesen
   und unter Zuhilfenahme des �bersetzungs-Moduls �bersetzt in eine
   zweite, neue Datei geschrieben. *)
VAR suchname,dateiname:Filename.filename;
    quellname,neuname:Filename.fullname;
    abbruch,ende:BOOLEAN;
    datei,neu:File;
    wortdeutsch,wortfremd:WortTyp;
    laengedeutsch:CARDINAL;
BEGIN
NewTitle(" �bersetzungsprogramm von F.Mathy/TOS - Bitte Textdatei w�hlen ");
WITH suchname DO
   drv:=CHR(0);
   path:="";
   name:="";
   ext:="";
   END; (* WITH *)
dateiname:=suchname;
Filename.SelectFilename(suchname,dateiname,abbruch);
Filename.compose(dateiname,suchname,quellname);
dateiname.ext:="NEU";
Filename.compose(dateiname,suchname,neuname);
IF NOT abbruch THEN
   NewTitle(" �bersetzungsprogramm von Frank Mathy f�r TOS 2/92 ");
   Redraw;
   WaitForRedraw;
   Lookup(datei,quellname,FALSE);
   Lookup(neu,neuname,TRUE);
   ende:=datei.eof;
   WHILE NOT ende DO
       LiesTextwort(datei,neu,wortdeutsch,laengedeutsch,ende);
       IF NOT ende THEN
         FindeUebersetzung(wortdeutsch,laengedeutsch,wortfremd);
         SchreibTextwort(neu,wortfremd)
         END; (* IF *)
       END; (* WHILE *)
   Close(neu);
   Close(datei);
   END; (* IF *)
END UebersetzeText;


END Textdatei.
