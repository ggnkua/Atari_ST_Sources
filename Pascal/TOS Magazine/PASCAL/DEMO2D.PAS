(* Demoprogramm: Verwendung von RECORDS unter Pure Pascal *)

PROGRAM RecordDemo;

TYPE
	TWohntyp =	(Wohnung,Haus); 
	TZuhause =	RECORD
				Strasse,Ort:STRING[60];
				Art:TWohntyp;
				END;

VAR Zuhause:TZuhause;
	Eingabe:STRING;

BEGIN

WRITELN('Daten Ihres Zuhauses: ');

WRITE('Strasse: ');
READLN(Zuhause.Strasse);
WITH Zuhause DO
	BEGIN
	WRITE('Ort: ');
	READLN(Ort);
	REPEAT
		WRITE('Wohnung oder Haus (W/H): ');
		READLN(Eingabe);
	UNTIL 	(Eingabe='w') OR (Eingabe='W') OR 
			(Eingabe='h') OR (Eingabe='H');
	IF (Eingabe='w') OR (Eingabe='W')	THEN Art:=Wohnung
										ELSE Art:=Haus;

	WRITELN('Daten Ihres Zuhauses:'#13#10^G,Strasse,#13#10,Ort);
	IF Art=Wohnung	THEN WRITELN('Wohnung')
					ELSE WRITELN('Haus');
	END; (* WITH *)

END.