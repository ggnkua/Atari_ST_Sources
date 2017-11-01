{$M+,E+}

{ Prototyper fr ST Pascal plus - VH 1/93
  Modul mit zus„tzlichen Stringoperationen }

PROGRAM protostr;

type
	strpfad=string[128];
	str255=string[255];

function rpos(c:char;var s:strpfad):integer;
var	i:integer;
begin
	for i:=1 to length(s) do
		if s[i]=c then
			rpos:=i;
end;

procedure upper(var s:str255);
var	i:integer;
begin
	for i:=1 to length(s) do
		if (s[i]>='a') and (s[i]<='z') then
			s[i]:=chr(ord(s[i]) & 223);
end;


begin
	{ leeres Hauptprogramm }
end.
