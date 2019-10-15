(* Iterative Fakult„tsberechnung in Pure Pascal *)

PROGRAM Fakultaet;

FUNCTION fak(n:INTEGER):INTEGER;
VAR zaehler,wert:INTEGER;
BEGIN
wert:=1;
IF n>1 THEN FOR zaehler:=2 TO n DO wert:=wert*zaehler;
fak:=wert;
END;

BEGIN
WRITELN('Fak(4)=',fak(4));
END.
