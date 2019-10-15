(* Demoprogramm: VAR-Parameter unter Pure Pascal *)

PROGRAM VertauschDemo;

PROCEDURE Vertausche(VAR wert1,wert2:INTEGER);
VAR hilf:INTEGER;
BEGIN
hilf:=wert1;
wert1:=wert2;
wert2:=hilf;
END;

VAR zahl1,zahl2:INTEGER;
BEGIN
zahl1:=1;
zahl2:=2;
WRITELN('zahl1 = ',zahl1);
WRITELN('zahl2 = ',zahl2);
WRITELN('Rufe >>Vertausche<<-Funktion auf.');
Vertausche(zahl1,zahl2);
WRITELN('zahl1 = ',zahl1);
WRITELN('zahl2 = ',zahl2);
END.
