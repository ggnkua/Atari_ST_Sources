(* Demo zu den Grundlagen der objektorientierten Programmierung *)

PROGRAM Demo5A;

(* Objektdeklaration *)

TYPE TPerson=OBJECT
	Name:STRING;
	PROCEDURE SetzName(NeuName:STRING);
	FUNCTION NamensInfo:STRING;
	PROCEDURE Druckdaten;
	END;

(* Implementation der Methoden von TPerson *)

PROCEDURE TPerson.SetzName(NeuName:STRING);
BEGIN
Name:=NeuName
END;

FUNCTION TPerson.NamensInfo:STRING;
BEGIN
NamensInfo:=Name
END;

PROCEDURE TPerson.Druckdaten;
BEGIN
WRITELN('Name: ',Name)
END;

VAR Person:TPerson;
	NeuName:STRING;
	z:CHAR;

BEGIN
WRITE('Name ? ');
READLN(NeuName);
Person.SetzName(NeuName);  (* "Qualifizierter" Zugriff *)
WITH Person DO Druckdaten; (* Wie bei Records          *)

WRITELN('Name: ',Person.Name);

READ(z);
END.
