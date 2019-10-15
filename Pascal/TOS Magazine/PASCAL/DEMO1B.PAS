PROGRAM Demo2;

LABEL weiter;

VAR auto:(Fiat,VW,Audi);
	kleinwert:0..9;
	zeichen:CHAR;
	zahl,zahl2:INTEGER;

BEGIN

GOTO weiter;
WRITELN('Diese Zeile wird nie ausgegeben.');
weiter:

FOR kleinwert:=9 DOWNTO 0 DO (* Zahlen von 9 bis 0 ausgeben *)
	BEGIN
	WRITELN('Wert = ',kleinwert);
	WRITELN('********');
	END;

zeichen:='Z';
WHILE zeichen>='A' DO (* Alphabet ausgeben *)
	BEGIN
	WRITE(zeichen);
	zeichen:=PRED(zeichen);
	END;

WRITELN;
WRITELN;

zahl:=$10;
zahl2:=zahl SHR 1;
WRITELN(zahl,' SHR 1 = ',zahl2);
WRITELN('2 OR  3 = ',2 OR  3);
WRITELN('2 XOR 3 = ',2 XOR 3);
WRITELN('2 AND 3 = ',2 AND 3);
WRITELN('NOT 2 = ',NOT 2);

REPEAT
	WRITE('Zahl zwischen 1950 und 1999 eingeben: ');
	READLN(zahl);
UNTIL (zahl>=1950) AND (zahl<=1999);

WRITELN;

auto:=Fiat;

CASE auto OF
	Fiat: WRITELN('Fiat');
	VW: WRITELN('VW');
	Audi: WRITELN('Audi');
	END;

END.