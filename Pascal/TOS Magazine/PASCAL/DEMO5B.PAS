(* Hauptprgramm zum Demo: GeschÅtzte Objektelemente *)

PROGRAM Demo5B;

USES Demo5BUnit;

VAR Person:TPerson;
	NeuName:STRING;
	z:CHAR;

BEGIN
WRITE('Name ? ');
READLN(NeuName);
WITH Person DO
	BEGIN
	SetzName(NeuName);
	Druckdaten;
	END;

(* Folgende Zeile ist nun illegal: *)
(* WRITELN('Name: ',Person.Name);  *)

READ(z);
END.
