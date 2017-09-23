program mem_avail;

uses crt;

var avail:longint;

begin
	clrscr;
	avail:=memavail;
	write(avail);
	readln;
end.