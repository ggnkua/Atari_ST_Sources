(* Demo fÅr die Verwendung von VorwÑrtsdeklarationen unter Pure Pascal *)

PROGRAM Prozedurtest2;

VAR wert:INTEGER; (* Globale Variable *)

PROCEDURE Druckzahl(zahl:INTEGER);
FORWARD; (* VorwÑrtsdeklaration *)

PROCEDURE Prozedur;
VAR wert:INTEGER; (* Lokale Variable *)
BEGIN
wert:=2;
Druckzahl(wert);
END;

PROCEDURE Druckzahl(zahl:INTEGER);
BEGIN
WRITELN('Wert = ',zahl);
END;

BEGIN
wert:=1;
Druckzahl(wert);
Prozedur; (* Aufruf der Prozedur *)
Druckzahl(wert);
END.
