PROGRAM Korrekt;

(* Definition der Objekte *)
(* Zwei h„ngt von Eins und Drei von Zwei ab *)
TYPE	Eins	=	OBJECT
						CONSTRUCTOR Init;
						PROCEDURE ShowTypeName; VIRTUAL;
						PROCEDURE Meldung;
					END;
		Zwei	=	OBJECT(Eins)
						PROCEDURE ShowTypeName; VIRTUAL;
					END;
		Drei	=	OBJECT(Zwei)
						PROCEDURE ShowTypeName; VIRTUAL;
					END;

(* Methoden Objekt Eins *)
CONSTRUCTOR Eins.Init;
BEGIN
END;

PROCEDURE Eins.ShowTypeName;
BEGIN
	WRITELN('*** Nummer Eins ***')
END;

PROCEDURE Eins.Meldung;
BEGIN
	ShowTypeName
END;

(* Methode Objekt Zwei *)
PROCEDURE Zwei.ShowTypeName;
BEGIN
	WRITELN('*** Nummer Zwei ***')
END;

(* Methode Objekt Drei *)
PROCEDURE Drei.ShowTypeName;
BEGIN
	WRITELN('*** Nummer Drei ***')
END;

(* Deklaration der Instanzen *)
VAR	One		: Eins;
	Two		: Zwei;
	Three	: Drei;

BEGIN
	One.Init;
	Two.Init;
	Three.Init;
	One.Meldung;
	Two.Meldung;
	Three.Meldung
END.
