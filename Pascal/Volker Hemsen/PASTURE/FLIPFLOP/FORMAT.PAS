{$M+,E+}
PROGRAM formatieren;


{$i vars.i}


 function intel(m:integer):integer;
begin
	intel:= shl(m,8) + shr(m,8);
end;


 function flopfmt(buf:puffer_typ_ptr;filler:long_integer;
		devno,spt,trackno,sideno,interlv:integer;
		magic:long_integer;virgin:integer):integer;
	xbios(10);

 procedure Protobt(buf:boot_typ_ptr;serialno:long_integer;
						disktype,execflag:integer);
	xbios(18);

 procedure Flopwr_boot(buf:boot_typ_ptr;filler:long_integer;
						devno,sectno,trackno,sideno,count:integer);
	xbios(9);


procedure format_init;
begin
	pufp:=NIL;
	format_prozess:=true;
	if (dichte=0) then	{DD}
	begin
		disktype:=3;
		case format of
			0:	begin
					track_anz:=80;
					sector_anz:=9;
				end;
			1:	begin
					track_anz:=82;
					sector_anz:=10;
				end;
			2:	begin
					track_anz:=82;
					sector_anz:=11;
				end;
		end
	end
	else						{HD}
	begin
		disktype:=4;
		case format of
			0:	begin
					track_anz:=80;
					sector_anz:=18;
				end;
			1:	begin
					track_anz:=82;
					sector_anz:=19;
				end;
			2:	begin
					track_anz:=82;
					sector_anz:=20;
				end;
		end;
	end;
	new(pufp:16000);
	track:=track_anz-1;
end;


procedure format_ende;
var sec_ges : integer;
	bootp : boot_typ_ptr;
begin
	dispose(pufp:16000);
	pufp:=NIL;
	bootp:=NIL;
	if (format_prozess=true) then
	begin
		{$C+} new(bootp:127);	{$C-}
		if (bootp<>NIL) then
		begin
			Protobt(bootp,$01000000,disktype,0);	{Bootsektor erstellen und etwas manipulieren}
			sec_ges:=sector_anz*track_anz*2;	{Gesamtzahl der Sektoren}
			bootp^.nsects0:=(sec_ges & $FF);	{unteres Byte}
			bootp^.nsects1:=shr(sec_ges,8);	{oberes Byte}
			bootp^.spt:=intel(sector_anz);
			bootp^.fat_eintrag[0]:=$F9FFFF00;	{erster FAT-Eintrag}
			Flopwr_boot(bootp,0,laufwerk,1,0,0,2);	{die ersten beiden Sektoren schreiben}
			dispose(bootp);
			bootp:=NIL;
		end;
		format_prozess:=false;
	end;
end;


procedure formatieren;
var	side,virgin : integer;
begin
	if (pufp<>NIL) then
	begin
		if (track<=1) then
			virgin:=$0000
		else
			virgin:=$e5e5;
		for side:=0 to 1 do
			if (Flopfmt(pufp,0,laufwerk,sector_anz,track,side,1,$87654321,virgin)<>0) then
			begin
				format_prozess:=false;
				dispose(pufp:16000);
				pufp:=NIL;
			end;
		track:=track-1;
		if ((format_prozess=true) and (track<0)) then
			format_ende;
	end;
end;


begin
end.
