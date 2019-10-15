(* Unit fÅr den abstrakten Datentyp *)

UNIT Abstrakt;

INTERFACE (* ôffentlicher Teil *)

PROCEDURE Init(VAR Stapel:POINTER);
FUNCTION Empty(Stapel:POINTER):BOOLEAN;
PROCEDURE Push(VAR Stapel:POINTER; NeuWert:INTEGER);
FUNCTION Pop(VAR Stapel:POINTER):INTEGER;

IMPLEMENTATION (* Nicht-îffentlicher Teil *)

TYPE PElement = ^TElement;
     TElement = RECORD
                Wert:INTEGER; (* Eintrag *)
                Naechster:PElement; (* Zeiger auf nÑchstes Element *)
                END;

PROCEDURE Init(VAR Stapel:POINTER);
BEGIN
Stapel:=NIL
END;

(* Test, ob Stapel leer (=TRUE) *)
FUNCTION Empty(Stapel:POINTER):BOOLEAN;
BEGIN
Empty:=(Stapel=NIL); (* Leer, sobald Stapel = NIL *)
END;

(* Wert <NeuWert> auf <Stapel> legen *)
PROCEDURE Push(VAR Stapel:POINTER; NeuWert:INTEGER);
VAR Hilf:PElement;
BEGIN
NEW(Hilf); (* Variable erzeugen *)
Hilf^.Wert:=NeuWert; (* Wert eintragen *)
Hilf^.Naechster:=Stapel; (* Erstes Element wird zum zweiten *)
Stapel:=Hilf; (* Eintrag neues erstes Element *)
END;

(* Wert vom Stapel holen *)
FUNCTION Pop(VAR Stapel:POINTER):INTEGER;
VAR Hilf,Lifo:PElement;
BEGIN
Lifo:=Stapel;
Pop:=Lifo^.Wert; (* Eintrag holen *)
Stapel:=Lifo^.Naechster; (* Zeiger auf 2. Element merken *)
DISPOSE(Lifo); (* Erstes Element lîschen *)
END;

END.
