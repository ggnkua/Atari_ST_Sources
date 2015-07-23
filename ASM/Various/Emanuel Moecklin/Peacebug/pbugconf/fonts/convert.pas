program test;

uses TOS;

var p:array[1..1024] of LONGINT;
	i,t,h1,h2:LONGINT;
	s1,s2,s3,s4:STRING;
begin
	s1:=chr(9)+chr(9)+chr(9)+chr(9)+'dc.l'+chr(9)+chr(9);
	s2:=',';
	s3:=chr(13)+chr(10);
	s4:='12345678901234567890';
	h1:=fopen('g:\peacebug\pbugconf\fonts\debug_16.fnt',0);
	h2:=fcreate('g:\peacebug\pbugconf\fonts\debug_16.s',0);
	fread(h1,4096,@p[1]);
	for i:=1 to 128 do			{ 64 fÅr 8*8 Font }
	begin
		fwrite(h2,Length(s1),@s1[1]);
		for t:=1 to 8 do
		begin
			str(p[(i-1)*8+t],s4);
			fwrite(h2,Length(s4),@s4[1]);
			if t<>8 then fwrite(h2,1,@s2[1]);
		end;
		fwrite(h2,2,@s3[1]);
	end;
	fclose(h1);
	fclose(h2);
end.
