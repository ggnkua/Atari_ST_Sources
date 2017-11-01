{	Sieb des Eratosthenes - Modul mit Primzahlensuche ohne Ausgabe	}

{$M+,E+,I+}

program sieve_tst(input,output);

{$Iconsttyp.i}

procedure sieve(wieweit_suchen:integer;var wieviel_primzahlen:integer);
var	gefunden,maxteiler,teiler,vielf,jj	:	integer;
		sieb	:	bool_ar_ty;

begin
	for jj:=1 to wieweit_suchen do
		sieb[jj]:=true;
	maxteiler:=round(sqrt(wieweit_suchen));
	for teiler:=2 to maxteiler do
	begin
		if sieb[teiler] then
		begin
			vielf:=teiler*2;
			while (vielf<=wieweit_suchen) do
			begin
				if sieb[vielf] then
					sieb[vielf]:=false;
				vielf:=vielf+teiler;
			end;
		end;
	end;
	gefunden:=1;
	for teiler:=2 to wieweit_suchen do
		if sieb[teiler] then
			gefunden:=gefunden+1;
	wieviel_primzahlen:=gefunden;
end;

begin
	{	Virtuelles Hauptprogramm	}
end.
