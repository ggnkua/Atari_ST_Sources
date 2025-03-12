program LodToAsm;

uses Tos;

var
	i:integer;
	t:text;
	b:byte;
	buf:array[0..65535] of byte;
	len:longint;

begin
	len:=Dsp_LodToBinary('DSP.LOD',@buf[0])*3;
	Assign( t, 'DSPBIN.S' );
	Rewrite( t );

	Writeln( t, '		EXPORT dsp_bin, end_of_dspbin' );
	Writeln( t );
	Writeln( t, '		DATA');
	Writeln( t );
	Writeln( t, 'dsp_bin:' );
	for i:=0 to len-1 do begin
		b:=buf[i];
		if (i mod 16)=0 then begin
			Writeln( t );
			Write(t, '		dc.b	',b);
		end
		else
			Write(t,', ',b);
	end;
	Writeln( t );
	Writeln( t, 'end_of_dspbin:' );
	Close( t );
end.
