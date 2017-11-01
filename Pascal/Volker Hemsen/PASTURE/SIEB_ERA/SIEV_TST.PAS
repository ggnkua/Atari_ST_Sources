{	Sieb des Eratosthenes - Modul mit Primzahlensuche und Ausgabe	}

{$M+,E+,I+}

program sieve(input,output);

{$Iconsttyp.i}

procedure sieve_tst(wieweit_suchen:integer;var wieviel_primzahlen:integer);
var	teiler,teilervielfach,ii,jj,maxteiler,wieviel_teilbar	:	integer;
		merke,start	:	boolean;
		sieb			:	bool_ar_ty;
begin
	merke:=false;
	start:=true;
	maxteiler:=round(sqrt(wieweit_suchen));
	for ii:=1 to wieweit_suchen do
		sieb[ii]:=true;
	wieviel_teilbar:=0;
	for teiler:=2 to maxteiler do
	begin
		if sieb[teiler] then
		begin
			teilervielfach:=teiler*2;
			while (teilervielfach<=wieweit_suchen) do
			begin
				if sieb[teilervielfach] then
				begin
					sieb[teilervielfach]:=false;
					wieviel_teilbar:=wieviel_teilbar+1;
				end;
				teilervielfach:=teilervielfach+teiler;
			end;
			if start then
				start:=false
			else
			begin
				if (not merke) and (teiler<>maxteiler) then
				begin
					write('Weiter mit <RETURN> ':75);
					readln;
				end;
			end;
			writeln;
			writeln('Zustand des Siebes nach Division durch alle Vielfachen von Teiler = ',teiler:1);
			writeln(' Bis jetzt nicht-teilbare Zahl = "*"    Teilbare Zahl = "-"');
			writeln(' Bis jetzt sind noch ',(wieweit_suchen-wieviel_teilbar):1,' nicht-teilbare Zahlen vorhanden');
			writeln;
			write(' ':8);
			for jj:=1 to 9 do
				write(jj:4);
			writeln('  0':4);
			writeln(' ':11,'-------------------------------------');
			writeln;
			for ii:=1 to (wieweit_suchen div 10) do
			begin
				merke:=false;
				write('[',(10*ii):3,']',' ':6);
				for jj:=1 to 10 do
					if sieb[10*ii+jj] then
						write('*',' ':3)
					else
						write('-',' ':3);
				writeln;
				if ((ii mod 20 = 0) or (ii=15)) then
				begin
					merke:=true;
					write('Weiter mit <RETURN> ':75);
					readln;
					writeln;
					write(' ':8);
					for jj:=1 to 9 do
						write(jj:4);
					writeln('0':4);
					writeln(' ':11,'------------------------------');
				end;
			end;
		end;
	end;
	wieviel_primzahlen:=wieweit_suchen-wieviel_teilbar;
end;
					
begin
	{	Virtuelles Hauptprogramm	}
end.
