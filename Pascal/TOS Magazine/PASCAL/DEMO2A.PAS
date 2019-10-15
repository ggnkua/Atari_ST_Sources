(* Verwendung von Prozeduren unter Pure Pascal *)

PROGRAM Prozedurtest;

VAR wert,wert2:INTEGER; (* Globale Variablen *)

PROCEDURE Prozedur;
VAR wert:INTEGER; (* Lokale Variable *)
BEGIN
wert:=2;
wert2:=2;
WRITELN('wert in Prozedur: ',wert);
END;

BEGIN
wert:=1;
wert2:=1;
WRITELN('wert im Hauptprogramm vor Prozeduraufruf: ',wert);
Prozedur; (* Aufruf der Prozedur *)
WRITELN('wert im Hauptprogramm nach Prozeduraufruf: ',wert);
WRITELN('wert2 im Hauptprogramm: ',wert2);
END.
