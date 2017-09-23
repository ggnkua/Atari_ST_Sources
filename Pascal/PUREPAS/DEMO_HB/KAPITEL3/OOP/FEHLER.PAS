PROGRAM Fehler;

(* Definition der Objekte *)
(* Zwei h„ngt von Eins und Drei von Zwei ab *)
TYPE	Eins	=	OBJECT
						PROCEDURE ShowTypeName;
						PROCEDURE Meldung;
					END;
		Zwei	=	OBJECT(Eins)
						PROCEDURE ShowTypeName;
					END;
		Drei	=	OBJECT(Zwei)
						PROCEDURE ShowTypeName;
					END;

(* Methoden Objekt Eins *)
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
	One.Meldung;
	Two.Meldung;
	Three.Meldung
END.
