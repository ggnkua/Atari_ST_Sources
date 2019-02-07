(*********************************************************************)
(* Implementations-Modul: Datenkapsel                                *)
(*-------------------------------------------------------------------*)
(* Datenkapsel-Modul des šbersetzungsprogrammes: Enth„lt alle Objekte*)
(* zur Verwaltung des W”rterbuches im Speicher/auf Massenspeicher.   *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 08.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             20.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* Žnderung:                                                         *)
(*********************************************************************)

IMPLEMENTATION MODULE Datenkapsel;

FROM AbstrakteVokabelliste IMPORT WortTyp,VokabelTyp,VokabellistenTyp,
     InitListe,LoeschListe,VokabelInListe,LiesVokabel;

FROM FileSystem IMPORT File,Lookup,Close,ReadChar,WriteChar,Response;


VAR Wortschatz:ARRAY[0..255] OF VokabellistenTyp;
    Zaehl:CARDINAL;
    Dateiname:ARRAY[0..40] OF CHAR;

CONST Woerterbuchname = "ENGLISCH.DIC";


PROCEDURE InWoerterbuch(wortdeutsch:WortTyp; laengedeutsch:CARDINAL;
                        wortfremd:WortTyp);
(* Die Vokabel mit dem deutschen Wort >>wortdeutsch<< der L„nge
   >>laengedeutsch<< und der šbersetzung >>wortfremd<< wird in den
   Wortschatz aufgenommen. *)
VAR Vokabel:VokabelTyp;
BEGIN
Vokabel.wortdeutsch:=wortdeutsch;
Vokabel.laengedeutsch:=laengedeutsch;
Vokabel.wortfremd:=wortfremd;
VokabelInListe(Wortschatz[ORD(wortdeutsch[0])],Vokabel)
END InWoerterbuch;


PROCEDURE LiesWoerterbuch;
(* Einlesen des W”rterbuches vom Datentr„ger in den Speicher *)
   PROCEDURE LiesDateiwort(VAR Datei:File; VAR Wort:WortTyp;
                           VAR Laenge:CARDINAL);
   VAR z:CHAR;
   BEGIN
   Laenge:=0;
   LOOP
       ReadChar(Datei,z);
       IF z = CHR(0) THEN EXIT END;
       Wort[Laenge]:=z;
       Laenge:=Laenge+1;
       IF Datei.eof THEN EXIT END
       END; (* LOOP *)
   Wort[Laenge]:=CHR(0)
   END LiesDateiwort;
VAR Datei:File;
    Wortdeutsch,Wortfremd:WortTyp;
    Laengedeutsch,Laengefremd:CARDINAL;
BEGIN
Lookup(Datei,Dateiname,FALSE);
IF Datei.res=done THEN
  WHILE (Datei.eof=FALSE) AND (Datei.res=done) DO
   LiesDateiwort(Datei,Wortdeutsch,Laengedeutsch);
   LiesDateiwort(Datei,Wortfremd,Laengefremd);
   IF Wortdeutsch[0]<>CHR(0) THEN
      InWoerterbuch(Wortdeutsch,Laengedeutsch,Wortfremd);
      END; (* IF *)
   END; (* WHILE *)
  Close(Datei);
  END; (* IF *)
END LiesWoerterbuch;


PROCEDURE SchreibWoerterbuch;
(* Schreiben des W”rterbuches aus dem Speicher auf Datentr„ger *)

   PROCEDURE SchreibDateiwort(VAR Datei:File; Wort:WortTyp);
   VAR Buchstabe:CARDINAL;
   BEGIN
   Buchstabe:=0;
   LOOP
       WriteChar(Datei,Wort[Buchstabe]);
       IF Wort[Buchstabe] = CHR(0) THEN EXIT END;
       Buchstabe:=Buchstabe+1
       END;
   END SchreibDateiwort;

VAR Buchstabe:CARDINAL;
    Datei:File;
    ok:BOOLEAN;
    Vokabel:VokabelTyp;
BEGIN
Lookup(Datei,Dateiname,TRUE);
FOR Buchstabe:=0 TO 255 DO
   ok:=LiesVokabel(Wortschatz[Buchstabe],TRUE,Vokabel);
   WHILE ok DO
       SchreibDateiwort(Datei,Vokabel.wortdeutsch);
       SchreibDateiwort(Datei,Vokabel.wortfremd);
       ok:=LiesVokabel(Wortschatz[Buchstabe],FALSE,Vokabel)
       END; (* WHILE *)
   END; (* FOR *)
Close(Datei)
END SchreibWoerterbuch;

PROCEDURE LoeschWoerterbuch;
(* Entfernen des W”rterbuches aus dem Speicher *)
VAR Buchstabe:CARDINAL;
BEGIN
FOR Buchstabe:=0 TO 255 DO
   LoeschListe(Wortschatz[Buchstabe])
   END
END LoeschWoerterbuch;

PROCEDURE HoleFremdwort(wortdeutsch:WortTyp; laengedeutsch:CARDINAL;
                        VAR wortfremd:WortTyp; VAR ok:BOOLEAN);
(* Fr das deutsche Wort >>wortdeutsch<< mit der L„nge >>laengedeutsch<<
   wird im W”rterbuch nach einer šbersetzung gesucht. Ist diese vorhanden,
   so wird sie in >>wortfremd<< zurckgegeben und >>ok<< auf TRUE gesetzt,
   andernfalls auf FALSE. *)

   PROCEDURE VergleicheWoerter(Wort1,Wort2:WortTyp):BOOLEAN;
   (* Vergleich der W”rter Wort1/2, TRUE wenn identisch *)
   VAR i:CARDINAL;
   BEGIN
   i:=0;
   WHILE(Wort1[i]<>CHR(0)) AND (Wort2[i]<>CHR(0)) DO
       IF Wort1[i]<>Wort2[i] THEN RETURN(FALSE) END;
       i:=i+1;
       END; (* WHILE *)
   IF(Wort1[i]=CHR(0)) AND (Wort2[i]=CHR(0))
       THEN RETURN(TRUE)
       ELSE RETURN(FALSE)
       END;
   END VergleicheWoerter;

VAR Datensatz:VokabelTyp;
    test:BOOLEAN;
BEGIN
test:=FALSE;
ok:=LiesVokabel(Wortschatz[ORD(wortdeutsch[0])],TRUE,Datensatz);
WHILE (NOT test) AND ok DO
   IF Datensatz.laengedeutsch = laengedeutsch THEN
       test:=VergleicheWoerter(wortdeutsch,Datensatz.wortdeutsch);
       END;
   IF test THEN wortfremd:=Datensatz.wortfremd
   ELSE ok:=LiesVokabel(Wortschatz[ORD(wortdeutsch[0])],FALSE,Datensatz)
   END; (* IF *)
   END; (* WHILE *)
END HoleFremdwort;

BEGIN
Dateiname:=Woerterbuchname;
FOR Zaehl:=0 TO 255 DO
   InitListe(Wortschatz[Zaehl]);
   END
END Datenkapsel.
