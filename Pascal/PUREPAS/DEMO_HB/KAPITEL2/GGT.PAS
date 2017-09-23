program get_ggt;

	var x,y : integer;
	
function ggt(a,b:integer) : integer;
begin
	if b=0 then ggt:=a else ggt:=ggt(b,a mod b)
end;

begin
	writeln('Gib zwei Zahlen ein, deren gr”žter gemeinsamer Teiler');
	writeln('berechnet werden soll!');
	readln(x); readln(y);
	writeln;
	writeln('Der GGT ist : ',ggt(x,y));
end.