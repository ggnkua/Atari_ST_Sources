(* Demo fÅr Vererbung und das öberladen von Objekten *)

PROGRAM Demo5D;

(* Objektdeklaration *)

TYPE TPerson=OBJECT
		Name:STRING;
		CONSTRUCTOR Init(NeuName:STRING);
		FUNCTION NamensInfo:STRING;
		PROCEDURE Druckdaten;
		END;

	TMitarbeiter=OBJECT(TPerson) (* Vererbung *)
		Gehalt:REAL;
		CONSTRUCTOR Init(NeuName:STRING; NeuGehalt:REAL);
		FUNCTION GehaltsInfo:REAL;
		FUNCTION Jahresgehalt:REAL;
		PROCEDURE Druckdaten;
		END;

(* Implementation der Methoden von TPerson *)

CONSTRUCTOR TPerson.Init(NeuName:STRING);
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

(* Implementation der Methoden von TMitarbeiter *)

CONSTRUCTOR TMitarbeiter.Init(NeuName:STRING; NeuGehalt:REAL);
BEGIN
TPerson.Init(NeuName); (* öberladene Prozedur aufrufen *)
Gehalt:=NeuGehalt
END;

FUNCTION TMitarbeiter.GehaltsInfo:REAL;
BEGIN
GehaltsInfo:=Gehalt
END;

FUNCTION TMitarbeiter.Jahresgehalt:REAL;
BEGIN
Jahresgehalt:=13*Gehalt
END;

PROCEDURE TMitarbeiter.Druckdaten;
BEGIN
TPerson.Druckdaten;
WRITELN('Gehalt: DM ',Gehalt:5:0,'  Im Jahr: ',Jahresgehalt:6:0)
END;

VAR Mitarbeiter:TMitarbeiter;
	NeuName:STRING;
	NeuGehalt:REAL;
	z:CHAR;

BEGIN
WRITE('Name ? ');
READLN(NeuName);
WRITE('Monatsgehalt (DM) ? ');
READLN(NeuGehalt);
Mitarbeiter.Init(NeuName,NeuGehalt);
Mitarbeiter.Druckdaten;
READ(z);
END.
