{	Sieb des Eratosthenes - Hauptmodul	}

{$I+}

program sieb_des_erastostenes(input,output);

{$Iconsttyp.i}

var
	bis_wo_suchen,ergebnis,itest	: integer;
	run,test	: boolean;
	
procedure sieve_tst(wieweit_suchen:integer;var wieviel_primzahlen:integer);
	external;
procedure sieve(wieweit_suchen:integer;var wieviel_primzahlen:integer);
	external;
		


begin
	writeln(chr(27),'p Das Sieb des Eratosthenes. ',chr(27),'q');
	run:=true;
	while run do
	begin
		writeln;
		writeln;
		writeln('Primzahlensuche: bis zu welcher Zahl soll gesucht werden?');
		write('Bitte ganze Zahl eingeben : ');
		readln(bis_wo_suchen);
		if (bis_wo_suchen>suchgrenze) then
		begin
			bis_wo_suchen:=suchgrenze;
			writeln('Die eingegebene Zahl war zu gros, sie wurde korrigiert auf : ',bis_wo_suchen:1);
		end;
		run:=(bis_wo_suchen>0);
		if run then
		begin
			write('Test gewnscht? Dann "1" : ');
			itest:=0;
			if not eoln then
				read(itest);
			readln;
			test:=(itest=1);
			if test then
				sieve_tst(bis_wo_suchen,ergebnis)
			else
				sieve(bis_wo_suchen,ergebnis);
			writeln;
			writeln('Ergebis:');
			write('Im Zahlenbereich [1,');
			if (bis_wo_suchen>2) then
				write('2,');
			if (bis_wo_suchen>3) then
				write('3,');
			if (bis_wo_suchen>4) then
				write('...');
			write(bis_wo_suchen:1,'] wurde');
			if (ergebnis>1) then
				write('n');
			write(' ',ergebnis:1,' Primzahl');
			if (ergebnis>1) then
				write('en');
			writeln(' gefunden.');
			if test then
			begin
				writeln;
				write('Weiter mit <RETURN> ':75);
				readln;
			end;
		end;
	end;
	writeln;
end.
