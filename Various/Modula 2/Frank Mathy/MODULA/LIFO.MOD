(* Abstrakter Datentyp-Demo, von Frank Mathy fÅr TOS 02/92 *)

IMPLEMENTATION MODULE Lifo;

FROM Heap IMPORT Allocate,Deallocate;
FROM SYSTEM IMPORT TSIZE;

TYPE Lifo = POINTER TO Satz; (* Abstrakter Datentyp    *)
     Satz = RECORD           (* Inhalt der DatensÑtze  *)
            Inhalt:Name;     (* Inhalt des Datensatzes *)
            Next:Lifo        (* Zeiger auf Folgesatz   *)
            END;

PROCEDURE InitLifo(VAR L:Lifo);
(* Lifo-Datentyp initialisieren *)
BEGIN
L:=NIL  (* Zeiger auf NIL (=0), da noch kein Eintrag *)
END InitLifo;

PROCEDURE EmptyLifo(L:Lifo):BOOLEAN;
(* Ermittelt, ob Lifo leer (TRUE) oder nicht (FALSE) *)
BEGIN
RETURN L=NIL (* Kein Eintrag vorhanden ? *)
END EmptyLifo;

PROCEDURE Push(VAR L:Lifo; Wert:Name);
(* Wert auf dem Stapel L ablegen *)
VAR hilf:Lifo;
BEGIN
hilf:=L;                 (* 1. Listeneintrag merken *)
Allocate(L,TSIZE(Satz)); (* Speicher reservieren    *)
L^.Inhalt:=Wert;         (* Inhalt setzen           *)
L^.Next:=hilf            (* Element an Listenanfang *)
END Push;

PROCEDURE Pop(VAR L:Lifo; VAR Wert:Name);
(* Wert vom Stapel L holen *)
VAR hilf:Lifo;
BEGIN
Wert:=L^.Inhalt;           (* Element auslesen           *)
hilf:=L^.Next;             (* 2. Element merken          *)
Deallocate(L,TSIZE(Satz)); (* 1. Element lîschen         *)
L:=hilf;                   (* 2. Element an Listenanfang *)
END Pop;

END Lifo.
