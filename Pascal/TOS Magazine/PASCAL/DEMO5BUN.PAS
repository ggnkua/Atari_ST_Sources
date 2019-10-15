(* Unit zum Demo: GeschÅtzte Objektelemente *)

UNIT Demo5BUnit;

INTERFACE

(* Objektdeklaration *)

TYPE TPerson=OBJECT
		PROCEDURE SetzName(NeuName:STRING);
		FUNCTION NamensInfo:STRING;
		PROCEDURE Druckdaten;
	PRIVATE
		Name:STRING;
	END;

(* Implementation der Methoden von TPerson *)

IMPLEMENTATION

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

END.
