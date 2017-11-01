(*********************************************************************)
(* Implementations-Modul: AbstrakteVokabelliste                      *)
(*-------------------------------------------------------------------*)
(* Abstrakter Datentyp zur Speicherung der Vokabeltypen eines        *)
(* Anfangszeichens zum schnelleren Auffinden.                        *)
(*-------------------------------------------------------------------*)
(*             Datum:      Autor:             Kommentar:             *)
(* Erstellung: 20.10.1991  Frank Mathy        DEFINITION MODULE      *)
(*             20.10.1991  Frank Mathy        IMPLEMENTATION MODULE  *)
(* énderung:                                                         *)
(*********************************************************************)


IMPLEMENTATION MODULE AbstrakteVokabelliste;

FROM Heap IMPORT Allocate,Deallocate;
FROM SYSTEM IMPORT ADR,TSIZE;

TYPE VokabellistenTyp = POINTER TO VokabelsatzTyp; (* Abstr.Datentyp *)
     VokabelsatzTyp = RECORD                 (* Vokabelsatz in Liste *)
                      Eintrag:VokabelTyp;
                      Naechster:VokabellistenTyp;
                      END;

VAR Suchzeiger:VokabellistenTyp;

PROCEDURE InitListe(VAR Liste:VokabellistenTyp);
(* Initialisierung der Åbergebenen Vokabellliste *)
BEGIN
Liste:=NIL
END InitListe;


PROCEDURE LoeschListe(VAR Liste:VokabellistenTyp);
(* Lîschen der Åbergebenen Vokabelliste *)
VAR Naechster:VokabellistenTyp;
BEGIN
WHILE Liste<>NIL DO
   Naechster:=Liste^.Naechster;
   Deallocate(Liste,TSIZE(VokabelsatzTyp));
   Liste:=Naechster
   END
END LoeschListe;


PROCEDURE VokabelInListe(VAR Liste:VokabellistenTyp; Vokabel:VokabelTyp);
(* Einbringen der Vokabel in die Vokabelliste *)
VAR Neuer:VokabellistenTyp;
BEGIN
Allocate(Neuer,TSIZE(VokabelsatzTyp));
Neuer^.Eintrag:=Vokabel;
Neuer^.Naechster:=Liste;
Liste:=Neuer
END VokabelInListe;


PROCEDURE LiesVokabel(Liste:VokabellistenTyp; ErstesElement:BOOLEAN;
                      VAR Vokabel:VokabelTyp):BOOLEAN;
(* Die nÑchste bzw. die erste (bei ErstesElement=TRUE) Vokabel der
   Vokabelliste wird zurÅckgegeben. Liegt keine weitere Vokabel in
   der Liste vor, so wird das Ergebnis FALSE. *)
BEGIN
IF ErstesElement THEN Suchzeiger:=Liste END;
IF Suchzeiger=NIL THEN RETURN(FALSE)
ELSE
   Vokabel:=Suchzeiger^.Eintrag;
   Suchzeiger:=Suchzeiger^.Naechster;
   RETURN(TRUE)
   END
END LiesVokabel;


END AbstrakteVokabelliste.
