(* Demo: Variante RECORDS unter Pure Pascal *)

PROGRAM RecordDemo2;

TYPE
	TWohntyp =	(Wohnung,Haus); 
	TZuhause =	RECORD
				Strasse,Ort:STRING[60];
				CASE Art:TWohntyp OF
						Wohnung: 	( Miete,Nebenkosten:REAL );
						Haus:		( Kaufpreis:REAL );
				END;

VAR Zuhause:TZuhause;
	Eingabe:CHAR;

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
	UNTIL 	(UPCASE(Eingabe)='W') OR (UPCASE(Eingabe)='H');
	IF (Eingabe='w') OR (Eingabe='W') 
	THEN 	BEGIN
			Art:=Wohnung;
			WRITE('Miete: ');
			READLN(Miete);
			WRITE('Nebenkosten: ');
			READLN(Nebenkosten);
			END
	ELSE	BEGIN
			Art:=Haus;
			WRITE('Kaufpreis: ');
			READLN(Kaufpreis);
			END;

	WRITELN;
	WRITELN('Daten Ihres Zuhauses:'#13#10^G,Strasse,#13#10,Ort);
	IF Art=Wohnung
	THEN	BEGIN
			WRITELN('Wohnung');
			WRITELN('Miete: ',Miete:3:2,' DM');
			WRITELN('Nebenkosten: ',Nebenkosten:3:2,' DM');
			END
	ELSE	BEGIN
			WRITELN('Haus');
			WRITELN('Kaufpreis: ',Kaufpreis:9:2,' DM');
			END;
	END; (* WITH *)

END.