(* Datenkapsel-Demo, von Frank Mathy fÅr TOS 02/92 *)

IMPLEMENTATION MODULE LifoKapsel;

FROM Heap IMPORT Allocate,Deallocate;
FROM SYSTEM IMPORT TSIZE;

TYPE Lifo = POINTER TO Satz; (* Typ der Datenkapsel    *)
     Satz = RECORD           (* Datenkapsel-Element    *)
            Inhalt:Name;     (* Inhalt des DatensÑtzes *)
            Next:Lifo        (* Zeiger auf Folgesatz   *)
            END;

VAR L:Lifo;  (* Gekapselte Variable *)

PROCEDURE InitLifo;
(* Datenkapsel initialisieren *)
BEGIN
L:=NIL (* Zeiger auf NIL (=0), da noch kein Eintrag *)
END InitLifo;

PROCEDURE EmptyLifo():BOOLEAN;
(* Ermittelt, ob Lifo leer (TRUE) oder nicht (FALSE) *)
BEGIN
RETURN L=NIL (* Kein Eintrag vorhanden ? *)
END EmptyLifo;

PROCEDURE Push(Wert:Name);
(* Wert auf den Stapel ablegen *)
VAR hilf:Lifo;
BEGIN
hilf:=L;                 (* 1. Listeneintrag merken *)
Allocate(L,TSIZE(Satz)); (* Speicher reservieren    *)
L^.Inhalt:=Wert;         (* Inhalt setzen           *)
L^.Next:=hilf            (* Element an Listenanfang *)
END Push;

PROCEDURE Pop(VAR Wert:Name);
(* Wert vom Stapel holen *)
VAR hilf:Lifo;
BEGIN
Wert:=L^.Inhalt;           (* Element auslesen           *)
hilf:=L^.Next;             (* 2. Element merken          *)
Deallocate(L,TSIZE(Satz)); (* 1. Element lîschen         *)
L:=hilf;                   (* 2. Element an Listenanfang *)
END Pop;

END LifoKapsel.
