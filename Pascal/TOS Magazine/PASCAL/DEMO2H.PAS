(* Demo: Last-In-First-Out-Stapel unter Pure Pascal *)

PROGRAM LifoDemo;

TYPE PElement = ^TElement;
     TElement = RECORD
                Wert:INTEGER; (* Eintrag *)
                Naechster:PElement; (* Zeiger auf n„chstes Element *)
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
DISPOSE(Lifo); (* Erstes Element l”schen *)
Lifo:=Hilf; (* 2. Element wird zum ersten *)
END;


BEGIN
Lifo:=NIL; (* Stapel initialisieren *)
FOR i:=1 TO 20 DO Push(i); (* Werte von 1 bis 20 auf Stapel *)
WHILE NOT Empty DO WRITELN(Pop); (* Werte einlesen *)
END.
