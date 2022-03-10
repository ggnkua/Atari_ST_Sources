program self(input, output);
type s = string[255]; n=integer;
var a : array [1..100] of s; i,j : integer;
function t(a:integer):integer; begin if a<7 then t:=a else t:=a+11 end; function q(a:s):s;
 var j:n;begin for j:=strlen(a)downto 1 do if a[j]=#39 then strinsert(#39,a,j);q:=a;end;
begin
   a[1] := 'program self(input, output);';
   a[2] := 'type s = string[255]; n=integer;';
   a[3] := 'var a : array [1..100] of s; i,j : integer;';
   a[4] := 'function t(a:integer):integer; begin if a<7 then t:=a else t:=a+11 end; function q(a:s):s;';
   a[5] := ' var j:n;begin for j:=strlen(a)downto 1 do if a[j]=#39 then strinsert(#39,a,j);q:=a;end;';
   a[6] := 'begin';
   a[18] := '   for i := 1 to 11 do begin setstrlen(a[i+6], 0);';
   a[19] := '      strwrite(a[i+6],1,j,''   a['',t(i):1,''] := '''''', q(a[t(i)]), '''''';'');';
   a[20] := '   end;';
   a[21] := '   for i := 1 to 22 do writeln(a[i]);';
   a[22] := 'end.';
   for i := 1 to 11 do begin setstrlen(a[i+6], 0);
      strwrite(a[i+6],1,j,'   a[',t(i):1,'] := ''', q(a[t(i)]), ''';');
   end;
   for i := 1 to 22 do writeln(a[i]);
end.
