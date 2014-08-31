program BinToO;

uses Tos;

var header:array[0..13] of word;
	symbol:array[0..13] of byte;

procedure Error;
begin
	Writeln('Error');
	ReadKey;
	Halt;
end;

procedure ToO(n,n2,lab:string);
var	h,flen:longint;
	buf:pointer;
	i:integer;
begin
	Writeln(n);
	h:=Fopen(n,FO_READ);
	if h<0 then Error;
	flen:=Fseek(0,h,2);
	Fseek(0,h,0);
	buf:=Malloc(4*(flen+3) div 4);
	if buf=pointer(0) then Error;
	if Fread(h,flen,buf)<flen then begin
		Fclose(h);
		Error;
	end;
	Fclose(h);

	flen:=((flen+3) div 4)*4;
	header[0]:=$601a;
	header[1]:=0;
	header[2]:=0;
	header[3]:=flen shr 16;
	header[4]:=flen and $ffff;
	header[5]:=0;
	header[6]:=0;
	header[7]:=0;
	header[8]:=14;
	header[9]:=0;
	header[10]:=0;
	header[11]:=0;
	header[12]:=0;
	header[13]:=0;

	h:=Fcreate(n2,0);
	if h<0 then Error;
	if Fwrite(h,28,@header[0])<28 then begin
		Fclose(h);
		Error;
	end;
	if Fwrite(h,flen,buf)<flen then begin
		Fclose(h);
		Error;
	end;

	for i:=0 to 13 do
		symbol[i]:=0;
	if Ord(lab[0])<=8 then begin
		for i:=0 to Ord(lab[0])-1 do
			symbol[i]:=Ord(lab[i+1]);
	end
	else begin
		for i:=0 to 7 do
			symbol[i]:=Ord(lab[i+1]);
	end;
	symbol[8]:=$a4;
	if Fwrite(h,14,@symbol[0])<14 then begin
		Fclose(h);
		Error;
	end;
	FillChar(buf^,flen,0);
	if Fwrite(h,flen,buf)<flen then begin
		Fclose(h);
		Error;
	end;
	Fclose(h);
end;

begin
	ToO('MAINSCR.IMG', 'MAINSCR.O', 'mainscrdat');
	ToO('ICONS.IMG', 'ICONS.O', 'iconsdat');
	ToO('MOUSE.IMG', 'MOUSE.O', 'mousedat');
	ToO('HELP.IMG', 'HELP.O', 'helpdat');
end.