(* Demo fÅr die Verwendung von Konstruktoren und Destruktoren *)
(* sowie die Realisierung von dynamischen Objekten.           *)

PROGRAM Demo5C;

(* Objektdeklaration *)

TYPE PPerson=^TPerson; 
	TPerson=OBJECT
	Name:STRING;
	CONSTRUCTOR Init(NeuName:STRING);
	DESTRUCTOR Done;
	FUNCTION NamensInfo:STRING;
	PROCEDURE Druckdaten;
	END;

(* Implementation der Methoden von TPerson *)

CONSTRUCTOR TPerson.Init(NeuName:STRING);
BEGIN
Name:=NeuName
END;

DESTRUCTOR TPerson.Done;
BEGIN
WRITELN('Destruktor des Objektes mit Namen: ',Name)
END;

FUNCTION TPerson.NamensInfo:STRING;
BEGIN
NamensInfo:=Name
END;

PROCEDURE TPerson.Druckdaten;
BEGIN
WRITELN('Name: ',Name)
END;

VAR Person:PPerson;
	Person2:TPerson;
	NeuName:STRING;
	z:CHAR;

BEGIN
WRITE('Name ? ');
READLN(NeuName);

NEW(Person,Init(NeuName)); (* Instanz erzeugen+initialisieren *)

Person^.Druckdaten;
Person2:=Person^; (* Zuweisung zwischen Objekten *)

DISPOSE(Person,Done); (* Instanz lîschen, vorher Done-Aufruf *)

Person2.Druckdaten;

READ(z);
END.
