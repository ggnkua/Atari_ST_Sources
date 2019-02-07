(*********************************************************************)
(* Implementation-Module: Uebersetzung                               *)
(*-------------------------------------------------------------------*)
(* öbersetzungs-Modul des öbersetzungsprogrammes: Modul mit Objekten *)
(* zum Auffinden der öbersetzung eines gegebenen Wortes unter        *)
(* Zuhilfenahme des Wîrterbuches.                                    *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 08.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             08.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* énderung:                                                         *)
(*********************************************************************)


IMPLEMENTATION MODULE Uebersetzung;


FROM Datenkapsel IMPORT HoleFremdwort,InWoerterbuch;
FROM AbstrakteVokabelliste IMPORT WortTyp,VokabelTyp,MaxWort;
FROM TermWindow IMPORT WriteString,WriteLn,Read,Write;

PROCEDURE FindeUebersetzung(wortdeutsch:WortTyp; laengedeutsch:CARDINAL;
                            VAR wortfremd:WortTyp);
(* Sucht die öbersetzung >>wortfremd<< fÅr das deutsche Wort
   >>wortdeutsch<< mit der LÑnge >>laengedeutsch<<. Ist kein Eintrag
   im Wîrterbuch vorhanden, so wird der Benutzer zur Worteingabe
   aufgefordert, die darauf in den Wortschatz aufgenommen wird. Gibt
   der Benutzer kein Wort ein, so wird das Fremdwort direkt Åbernommen. *)
VAR ok:BOOLEAN;

   PROCEDURE Worteingabe(wortdeutsch:WortTyp; VAR wortfremd:WortTyp);
   (* Unbekanntes Wort eingeben *)

      PROCEDURE ReadString(VAR s:ARRAY OF CHAR);
      (* Im Terminalfenster Wort einlesen *)
      VAR p:CARDINAL;
          z:CHAR;
      BEGIN
      p:=0;
       LOOP
          Read(z);
          CASE ORD(z) OF
             13: s[p]:=CHR(0);
                 RETURN;
         |   8:  IF p>0 THEN
                 p:=p-1;
                 Write(z);
                 Write(" ");
                 Write(z);
                 END; (* IF *)
         ELSE IF p<MaxWort THEN
              s[p]:=z;
              p:=p+1;
              Write(z);
              END; (* IF *)
         END; (* CASE *)
       END; (* LOOP *)
      END ReadString;



   BEGIN
   WriteString("Wort unbekannt: ");
   WriteString(wortdeutsch);
   WriteLn;
   WriteString("öbersetzung (Return->Dt. Wort Åbernehmen) : ");
   ReadString(wortfremd);
   WriteLn
   END Worteingabe;
BEGIN
HoleFremdwort(wortdeutsch,laengedeutsch,wortfremd,ok);
IF NOT ok THEN
   Worteingabe(wortdeutsch,wortfremd);
   IF wortfremd[0] <> CHR(0) THEN
       InWoerterbuch(wortdeutsch,laengedeutsch,wortfremd)
   ELSE
       wortfremd:=wortdeutsch
   END; (* IF *)
   END; (* IF *)
END FindeUebersetzung;


END Uebersetzung.
