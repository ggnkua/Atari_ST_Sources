{ Prototyper fÅr ST Pascal plus - VH 1/93
  Hauptprogramm }

PROGRAM prototypes;


type
	strpfad=string[128];
	str80=string[80];
	str255=string[255];

var
	pfad1,pfad2:strpfad;
	s,u:str255;
	i:integer;
	f1,f2:file of text;
	gespraechig:boolean;

{$I protostr.i}    { NatÅrlich direkt von sich selbst erzeugt! }

begin
	IO_CHECK(false);	{ LaufzeitÅberprÅfung fÅr Diskfehler abschalten }
	writeln(chr(27),'pPrototyps fÅr ST Pascal plus - Public Domain - (VH 1/93)',chr(27),'q');
	writeln('Syntax der Kommandozeile: pfad [-v]');
	cmd_getarg(1,pfad1);
	cmd_getarg(2,s);
	gespraechig:=(pos('-v',s)>=1);
	if length(pfad1)>0 then
	begin
		pfad2:=pfad1;
		i:=rpos('.',pfad2);
		delete(pfad2,i,succ(length(pfad2)-i));
		pfad2:=concat(pfad2,'.I');
		reset(f1,pfad1);
		if IO_RESULT=0 then
		begin
			if gespraechig then
				writeln('Untersuche: ',pfad1);
			rewrite(f2,pfad2);
			if IO_RESULT=0 then
			begin
				if gespraechig then
				begin
					writeln('Schreibe: ',pfad2);
					writeln;
				end;
				writeln(f2,'{ Prototypes - ',pfad2,' }');
				writeln(f2);
				repeat
					readln(f1,s);
					u:=s;
					upper(u);
					if (pos('PROCEDURE',u)=1) or (pos('FUNCTION',u)=1) then
					begin
						if gespraechig then
						writeln(s);
						writeln(f2,s);
						writeln(f2,chr(9),'external;');
					end;
				until eof(f1)=true;
				close(f2);
			end	{ FILE 2 îffnen }
			else
				writeln('Fehler beim îffnen der Datei: ',pfad2);
			close(f1);
		end	{ File 1 îffnen }
		else
			writeln('Fehler beim îffnen der Datei: ',pfad1);
	end;	{ Pfad ÅberprÅfen }
end.
