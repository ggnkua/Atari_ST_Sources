program fselect;

uses geminit,gem;

var 	pfad, fname 	: string;
		error, button	: integer;

begin
	if initgem=true then
	begin
		fname:='';
		pfad:='';
		error:=fsel_input( pfad, fname, button);
		if error<>0 then
		writeln('Pfad     : ',pfad);
		writeln('Filename : ',fname);
	end;
end.