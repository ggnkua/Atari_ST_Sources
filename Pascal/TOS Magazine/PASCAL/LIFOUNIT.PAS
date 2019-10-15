(* Unit fÅr eine LIFO-Datenkapsel *)

UNIT LifoUnit;

INTERFACE (* ôffentlicher Teil *)

FUNCTION Empty:BOOLEAN;
PROCEDURE Push(NeuWert:INTEGER);
FUNCTION Pop:INTEGER;

IMPLEMENTATION (* Nicht-îffentlicher Teil *)

TYPE PElement = ^TElement;
     TElement = RECORD
                Wert:INTEGER; (* Eintrag *)
                Naechster:PElement; (* Zeiger auf nÑchstes Element *)
                END;

VAR Lifo:PElement;
    i:INTEGER;

(* Test, ob Stapel leer (=TRUE) *)
FUNCTION Empty:BOOLEAN;
BEGIN
Empty:=(Lifo=NIL); (* Leer, sobald Zeiger = NIL *)
END;

(* Wert <NeuWert> auf Stapel legen *)
PROCEDURE Push(NeuWert:INTEGER);
VAR Hilf:PElement;
BEGIN
NEW(Hilf); (* Variable erzeugen *)
Hilf^.Wert:=NeuWert; (* Wert eintragen *)
Hilf^.Naechster:=Lifo; (* Erstes Element wird zum zweiten *)
Lifo:=Hilf; (* Eintrag neues erstes Element *)
END;

(* Wert vom Stapel holen *)
FUNCTION Pop:INTEGER;
VAR Hilf:PElement;
BEGIN
Pop:=Lifo^.Wert; (* Eintrag holen *)
Hilf:=Lifo^.Naechster; (* Zeiger auf 2. Element merken *)
DISPOSE(Lifo); (* Erstes Element lîschen *)
Lifo:=Hilf; (* 2. Element wird zum ersten *)
END;

BEGIN
Lifo:=NIL; (* Stapel initialisieren *)
END.
