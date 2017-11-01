{$M+,E+}
PROGRAM resource_initialisierung;

{$i gemohne.pas}

function rsrc_anz:integer;
	external;
function rsrc_adr(i:integer):tree_ptr;
	external;

procedure rsrc_init;
var	i,e:integer;
	t:tree_ptr;
begin
	t:=rsrc_adr(0);
	e:=rsrc_anz;
	for i:=0 to e do
		rsrc_obfix(t,i);
end;

begin
end.
