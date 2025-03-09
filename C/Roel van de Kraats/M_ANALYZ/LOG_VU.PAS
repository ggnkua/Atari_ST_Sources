program LogVu;

uses GemInit, gem;

var
	t:text;
	buf: array[1..1024] of byte;
	i:integer;
	a:single;
	pxy:array[0..3] of integer;

begin
	if InitGem=false then Halt;

	pxy[0]:=0;
	pxy[1]:=0;
	pxy[2]:=WorkOut[0];
	pxy[3]:=WorkOut[1];
	vsf_color(Vdihandle,0);
	vsf_perimeter(VdiHandle,0);
	v_bar(Vdihandle,ARRAY_4(pxy));

	for i:=1 to 1024 do begin
		a:=20.0 * Ln(i/1024.0)/Ln(10.0);
		a:=90.0+(a*90.0/20.0);
		if a<0.0 then a:=0.0;
		buf[i]:=Round(a);
	end;

	vsl_color(VdiHandle,1);
	for i:=1 to 512 do begin
		pxy[0]:=i+50;
		pxy[1]:=300-buf[i*2];
		pxy[2]:=pxy[0];
		pxy[3]:=pxy[1];
		v_pline(VdiHandle,2,pxy);
	end;

	Assign( t, 'LOG_VU.S' );
	Rewrite( t );
	Writeln(t, '		EXPORT log');
	Writeln( t );
	Writeln( t,'		DATA');
	Writeln( t );
	Write( t, 'log:		;20 dB, for vu');

	for i:=0 to 1023 do begin
		if (i mod 16)=0 then begin
			Writeln( t );
			Write(t, '		dc.b	',buf[i+1]);
		end
		else
			Write(t,',',buf[i+1]);
	end;
	Close( t );

	ExitGem;
end.