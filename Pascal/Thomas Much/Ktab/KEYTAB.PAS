{***************************************
 *        KeyTab by Thomas Much        *
 ***************************************
 *   Dieses Programm ist Freeware!     *
 ***************************************
 *  Copyright 1997-98 by Thomas Much   *
 *       thomas@snailshell.de          *
 ***************************************
 *    erstellt am:        22.08.1997   *
 *    letztes Update am:  21.09.1998   *
 ***************************************}

{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

{$M 4096}
{$E .PRG}

program KeyTab;

uses

	Tos;


type

	PByte    = ^byte;
	PLongint = ^longint;

	TCookieID = array [0..3] of char;

	PCookie = ^TCookie;
	TCookie = record
		ID   : TCookieID;
		Value: longint
	end;

	PKEYT = ^TKEYT;
	TKEYT = record
		Magic             : TCookieID;
		Size              : longint;
		GetExportCount    : function: integer;
		pasGetExportName  : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): PChar;
		GetExportFilter   : function(d1,d2: pointer; d3,d4,d5: longint; eid: integer): integer;
		ExportChar        : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer; echr: char): char;
		GetImportCount    : function: integer;
		pasGetImportName  : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): PChar;
		GetImportFilter   : function(d1,d2: pointer; d3,d4,d5: longint; iid: integer): integer;
		ImportChar        : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ichr: char): char;
		{ ab KEYTAB 03 }
		ExportString      : procedure(d1,d2: pointer; d3,d4,d5: longint; enr: integer; elen: longint; echrs: PChar);
		ImportString      : procedure(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ilen: longint; ichrs: PChar);
		{ ab KEYTAB 98-01-08 }
		GetExportName     : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;
		GetImportName     : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;
		{ ab KEYTAB 98-04-16 }
		GetExportShortName: function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;
		GetImportShortName: function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;
		{ ab KEYTAB 07 }
		GetRelease        : function: integer;
		GetExportFilterID : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): integer;
		GetImportFilterID : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): integer;
	end;


const

	RELEASE             = 7;

	KEYTAB_ID_IDENTICAL = 0;
	KEYTAB_ID_ANSI      = 1;
	KEYTAB_ID_ISOLATIN1 = 1;
	KEYTAB_ID_MAC       = 2;
	KEYTAB_ID_PC        = 3;
	KEYTAB_ID_CP437     = 3;
	KEYTAB_ID_CP850     = 4; { TODO }
	KEYTAB_ID_CP1252    = 5; { TODO }
	KEYTAB_ID_PSION3    = 6; { TODO -> CP850 }

	COOKIENAME          = 'KEYT';

	EXPORT_COUNT        = 5;
	IMPORT_COUNT        = 6;

	EXPORT_NAMES        : array [0..EXPORT_COUNT+1] of PChar = ('Atari','ISO Latin 1','Macintosh','MS-DOS Codepage 437','MS-DOS Codepage 850','Windows Codepage 1252','');
	EXPORT_NAMES_SHORT  : array [0..EXPORT_COUNT+1] of PChar = ('Atari','ISO Latin 1','Macintosh','Codepage 437','Codepage 850','Codepage 1252','');

	IMPORT_NAMES        : array [0..IMPORT_COUNT+1] of PChar = ('Atari','ISO Latin 1','Macintosh','MS-DOS Codepage 437','MS-DOS Codepage 850','Windows Codepage 1252','Sinclair QL','');
	IMPORT_NAMES_SHORT  : array [0..IMPORT_COUNT+1] of PChar = ('Atari','ISO Latin 1','Macintosh','Codepage 437','Codepage 850','Codepage 1252','Sinclair QL','');
	
	EXPORT_FILTERS      : array [0..EXPORT_COUNT,0..255] of char =
	                       (#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥ßfáíóúñÑªº¿*¬½¼¡«»ãõØø**ÀÃÕ¨´*¶©®******************************§^**Ï****µ**********±****÷*°*·**²³¯',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'‚Ÿ‰ŠˆŒ‘•”“€ƒ¾®™š˜Ø…†¢£´§Ä‡’—œ–„»¼À*Â**ÁÇÈ‹›¯¿ÏÎËÌÍ¬« ¦©¨ª*****************************¤^°*§*¹·*µ***½¶*****±³²ººÖÅûú¥Ã***ø',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19'**'#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œáŸ ¡¢£¤¥¦§¨©ª«¬­®¯************'#20'*********************************ìàáâãäåæçèéêë*íîïğñòóôõö÷øùúûüı**',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19'**'#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š½œ¾á³ ¡¢£¤¥¦§¨*ª«¬­®¯Æä›**·ÇåùïÅô¸©******************************õ^**á****æ****Ğ****òñ****ö*øîğ**ıü ',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'ÇüéâäàåçêëèïîìÄÅÉæÆôöòûùÿÖÜ¢£¥ßƒáíóúñÑªº¿*¬½¼¡«»ãõØøœŒÀÃÕ¨´†¶©®™*****************************§ˆ******************±****÷*°••**²³¯');

	IMPORT_FILTERS      : array [0..IMPORT_COUNT,0..255] of char =
	                       (#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'*********************************­›œ*|İ¹½¦®ª-¾ÿøñışºæ¼ú,*§¯¬«*¨¶AA·’€EEEIIIID¥OOO¸™*²UUUšY*… ƒ°„†‘‡Š‚ˆ‰¡Œ‹ë¤•¢“±”ö³—£–y*˜',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€¥™š …ƒ„°†‡‚Šˆ‰¡Œ‹¤¢•“”±£—–»ø›œİù¼¾½¿º¹*’²ßñóòæëä*ãô¦§ê‘³¨­ªûŸ÷®¯**¶·Oµ´--""ººö*˜Y/*<>***ú,"*AEAEEIIIIOO*OUUUi^~ÿ*ùø,",*',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19'¼İ'#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œ*Ÿ ¡¢£¤¥¦§¨©ª«¬­®¯***|++++++|+++++++++-++++++++-+++++++++++++*****àáâãäåæçèéêëßíîïğñòóôõö÷øùúûüı* ',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19'¼İ'#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +'€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š³œ²xf ¡¢£¤¥¦§¨¾ª«¬­®¯***Ÿ*AA¶½****›*****-»°·*****=**ëDEEE`III****|I*OOO±¸æpPUUUyYùºúñğ*¼İöÿø¹ù*şı* ',
	                        #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#127
	                        +#128#129''''#159'"_»»^%S®µ'#141#142#143#144'`''""ú--~¿s¯´'#157#158'Y ­›œ*|İ¹½a®ª-¾ÿøñışºæ¼ú 1ø¯¬«*¨¶AA·’€EEEIIIID¥OOO¸™*²UUUšYP… ƒ°„†‘‡Š‚ˆ‰¡Œ‹*¤•¢“±”ö³—£–yp˜',
	                        #0'********'#9#10'**'#13'*************'#27'**** !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'#156'abcdefghijklmnopqrstuvwxyz{|}~'#189
	                        +'„°†‚”±³‡¤‘´ …ƒ‰Šˆ‹¡Œ¢•“£—–›`·™¸²š€¥’µàëéŞæãí­¨?İ¼®¯øö********************************************************************');


var

	kt: TKEYT;



function NewCookie(cookie: TCookieID; wert: longint): boolean;
	var cookiejar: PCookie;
	    anz,maxc : longint;

	begin
		NewCookie:=false;
		cookiejar:=PCookie(setexc(360,pointer(-1)));
		if cookiejar<>nil then
			begin
				anz:=1;
				while PLongint(cookiejar)^<>0 do
					begin
						if cookiejar^.ID=cookie then exit;
						inc(longint(cookiejar),8);
						inc(anz)
					end;
				maxc:=cookiejar^.Value;
				if anz<maxc then
					begin
						with cookiejar^ do
							begin
								ID:=cookie;
								Value:=wert
							end;
						inc(longint(cookiejar),8);
						with cookiejar^ do
							begin
								ID:=#0#0#0#0;
								Value:=maxc
							end;
						NewCookie:=true
					end
			end
	end;


function GetRelease: integer;

	begin
		GetRelease:=RELEASE
	end;


function GetExportCount: integer;

	begin
		GetExportCount:=EXPORT_COUNT
	end;


function GetImportCount: integer;

	begin
		GetImportCount:=IMPORT_COUNT
	end;


function GetExportName(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;

	begin
		if (enr<0) or (enr>EXPORT_COUNT) then enr:=EXPORT_COUNT+1;
		GetExportName:=longint(PChar(EXPORT_NAMES[enr]))
	end;


function GetExportShortName(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;

	begin
		if (enr<0) or (enr>EXPORT_COUNT) then enr:=EXPORT_COUNT+1;
		GetExportShortName:=longint(PChar(EXPORT_NAMES_SHORT[enr]))
	end;


function pasGetExportName(d1,d2: pointer; d3,d4,d5: longint; enr: integer): PChar;

	begin
		pasGetExportName:=PChar(GetExportName(nil,nil,0,0,0,enr))
	end;


function GetImportName(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;

	begin
		if (inr<0) or (inr>IMPORT_COUNT) then inr:=IMPORT_COUNT+1;
		GetImportName:=longint(PChar(IMPORT_NAMES[inr]))
	end;


function GetImportShortName(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;

	begin
		if (inr<0) or (inr>IMPORT_COUNT) then inr:=IMPORT_COUNT+1;
		GetImportShortName:=longint(PChar(IMPORT_NAMES_SHORT[inr]))
	end;


function pasGetImportName(d1,d2: pointer; d3,d4,d5: longint; inr: integer): PChar;

	begin
		pasGetImportName:=PChar(GetImportName(nil,nil,0,0,0,inr))
	end;


function GetExportFilter(d1,d2: pointer; d3,d4,d5: longint; eid: integer): integer;

	begin
		if (eid<0) or (eid>3) then GetExportFilter:=0
		else
			GetExportFilter:=eid
	end;


function GetImportFilter(d1,d2: pointer; d3,d4,d5: longint; iid: integer): integer;

	begin
		if (iid<0) or (iid>3) then GetImportFilter:=0
		else
			GetImportFilter:=iid
	end;


function ExportChar(d1,d2: pointer; d3,d4,d5: longint; enr: integer; echr: char): char;

	begin
		if (enr<0) or (enr>EXPORT_COUNT) then enr:=0;
		ExportChar:=EXPORT_FILTERS[enr,ord(echr)]
	end;


function ImportChar(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ichr: char): char;

	begin
		if (inr<0) or (inr>IMPORT_COUNT) then inr:=0;
		ImportChar:=IMPORT_FILTERS[inr,ord(ichr)]
	end;


procedure ExportString(d1,d2: pointer; d3,d4,d5: longint; enr: integer; elen: longint; echrs: PChar);
	var q: longint;

	begin
		if elen<1 then exit;
		if echrs=nil then exit;
		if (enr<0) or (enr>EXPORT_COUNT) then exit;
		for q:=1 to elen do
			begin
				echrs^:=EXPORT_FILTERS[enr,PByte(echrs)^];
				inc(longint(echrs))
			end
	end;


procedure ImportString(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ilen: longint; ichrs: PChar);
	var q: longint;

	begin
		if ilen<1 then exit;
		if ichrs=nil then exit;
		if (inr<0) or (inr>IMPORT_COUNT) then exit;
		for q:=1 to ilen do
			begin
				ichrs^:=IMPORT_FILTERS[inr,PByte(ichrs)^];
				inc(longint(ichrs))
			end
	end;


function GetExportFilterID(d1,d2: pointer; d3,d4,d5: longint; enr: integer): integer;

	begin
		{ TODO }
		GetExportFilterID:=-1
	end;


function GetImportFilterID(d1,d2: pointer; d3,d4,d5: longint; inr: integer): integer;

	begin
		{ TODO }
		GetImportFilterID:=-1
	end;


procedure SetupKT;

	begin
		kt.Magic:=COOKIENAME;
		kt.Size:=sizeof(TKEYT);
		kt.GetExportCount:=GetExportCount;
		kt.GetImportCount:=GetImportCount;
		kt.pasGetExportName:=pasGetExportName;
		kt.pasGetImportName:=pasGetImportName;
		kt.GetExportFilter:=GetExportFilter;
		kt.GetImportFilter:=GetImportFilter;
		kt.ExportChar:=ExportChar;
		kt.ImportChar:=ImportChar;
		kt.ExportString:=ExportString;
		kt.ImportString:=ImportString;
		kt.GetExportName:=GetExportName;
		kt.GetImportName:=GetImportName;
		kt.GetExportShortName:=GetExportShortName;
		kt.GetImportShortName:=GetImportShortName;
		kt.GetRelease:=GetRelease;
		kt.GetExportFilterID:=GetExportFilterID;
		kt.GetImportFilterID:=GetImportFilterID;
	end;


begin
	writeln;
	write(#27'p KEYTAB 07 (1998-07-05) beta '#27'q ');
	SetupKT;
	if not(NewCookie(COOKIENAME,longint(@kt))) then
		begin
			writeln('*nicht* installiert!');
			writeln;
			halt(1)
		end
	else
		begin
			writeln('installiert.');
			writeln;
			Ptermres(256+basepage^.p_tlen+basepage^.p_dlen+basepage^.p_blen,0)
		end
end.


{ TODO:
  - Setexc() statt Supexec() (?)
  - KEYTAB_ID_ISOLATIN1, KEYTAB_ID_CP437
  - GetRelease
  - incl. Sourcecode
  // Psion Serie 3 / Psion 3 (=CP850)
  // neue IDs fr CPxxx, PSION3
  // Funktionen fr Nr->ID: GetExportFilterID, GetImportFilterID
}