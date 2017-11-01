{globale Variablen}

type	puffer_typ=packed array[0..20000] of char;
		puffer_typ_ptr=^puffer_typ;

		boot_typ = packed record
			branch	: integer;
			loader	: packed array[1..6] of char;
			ser2,ser1,ser0	: byte;
			bps1,bps0	: byte;
			spc			: byte;
			res1,res0	: byte;
			nfats			: byte;
			ndirs1,ndirs0	: byte;
			nsects1,nsects0	: byte;	{Gesamtzahl der Sektoren}
			media		: byte;
			spf		: integer;	{Sektoren pro FAT auf 3 korrigieren}
			spt		: integer;	{Sektoren pro Track}
			nsides	: integer;
			nhid		: integer;
			booprg	: packed array[1..479] of byte;
			check_summe	: integer;
			
			fat_eintrag	: array[0..127] of long_integer;
		end;
		boot_typ_ptr=^boot_typ;


var
	wind_handle,dummy : integer;
	laufwerk,dichte,format : integer;
	ende : boolean;
	sector_anz : integer;
	track,track_anz : integer;
	disktype : integer;
	format_prozess : boolean;
	pufp : puffer_typ_ptr;
