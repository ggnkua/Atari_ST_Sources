{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *          Unit  O P R O C S           *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        13.07.1992  *
 *      letztes Update am:  23.06.1998  *
 ****************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

	ObjectGEM ist Freeware, d.h. jeder darf die Units verwenden, ohne
	fÅr die damit entwickelten Programme Lizenzen o.Ñ. zahlen zu mÅssen,
	so lange alle Dateien _zusammen_ und _unverÑndert_ (!) weitergegeben
	werden.
	
	Ich freue mich natÅrlich trotzdem Åber kleine Aufmerksamkeiten wie
	Belegexemplare, originelle T-Shirts (L oder XL) sowie grÅnen Tee
	aus Japan :-)

  WICHTIG: Wer den Quelltext verÑndert und dann Probleme beim Compilieren,
  AusfÅhren o.Ñ. hat, kann nicht damit rechnen, daû ich den Fehler suche;
  tritt der Fehler allerdings auch mit dem Original-Quelltext auf, wÅrde
  ich mich Åber eine genaue Fehlerbeschreibung freuen. VerÑnderte Quell-
  texte dÅrfen _nicht_ weitergegeben werden, dies wÑre ein Verstoû gegen
  das Copyright!

  Wer beim Durchstîbern des Textes auf vermeintliche Fehler oder verbesse-
  rungswÅrdige Stellen trifft (von letzterem gibt es sicherlich noch viele),
  kann mir dies gerne mitteilen - ich habe auch ich nichts gegen kostenlos
  zur VerfÅgung gestellte optimierte Routinen (sofern sich jemand die MÅhe
  macht). Wer in anderen Projekten, die nicht in direkter Konkurrenz zu
  ObjectGEM stehen, einzelne Routinen verwenden mîchte, wendet sich bitte
  an mich (ein solcher Austausch sollte kein Problem sein).

  Wer sich auf nicht dokumentierte "implementation"- oder "private"-Eigen-
  schaften verlÑût, darf sich nicht Åber InkompatibilitÑten zu spÑteren
  Versionen wundern; wer meint, eine DokumentationslÅcke entdeckt zu haben,
  kann mir dies gerne mitteilen.

  Kleine Info zum Schluû: Als "default tabsize" verwende ich 2. Wer drei
  Punkte ("...") im Quelltext entdeckt, hat eine Stelle gefunden, an der
  ich z.Z. arbeite ;-)

  "Mîge die OOP mit Euch sein!"
}


{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit OProcs;

interface

uses

	OTypes;


function NewStr(const s: string): PString;
procedure DisposeStr(var p: PString);
function ChrNew(const s: string): PChar;
procedure ChrDispose(var p: PChar);
function StrLPas(p: PChar; maxc: integer): string;
function StrPPas(p: PChar): string;
function StrPLeft(const s: string; c: integer): string;
function StrPRight(const s: string; c: integer): string;
function StrPMid(const s: string; idx,c: integer): string;
function CutLeftF(const s: string; c: integer): string;
procedure CutLeft(var s: string; c: integer);
function CutRightF(const s: string; c: integer): string;
procedure CutRight(var s: string; c: integer);
function StrPTrimF(s: string): string;
procedure StrPTrim(var s: string);
function StrPTrimNumF(s: string): string;
procedure StrPTrimNum(var s: string);
function StrPSpace(anz: integer): string;
function StrPFill(anz: integer; c: char): string;
function StrPUpper(s: string): string;
function StrPLower(s: string): string;
function StrScanQuote(p: PChar): PChar;
function RPos(subStr,Str: string): byte;
function UpChar(ch: char): char;
function LowChar(ch: char): char;

function ltob(l: longint; anz: integer): string;
function btol(s: string): longint;
function ltoo(l: longint; anz: integer): string;
function otol(s: string): longint;
function ltoh(l: longint; anz: integer): string;
function htol(s: string): longint;
function ltoa(l: longint): string;
function atol(s: string): longint;
function ftoa(f: real): string;
function atof(s: string): real;

function NewCookie(cookie: TCookieID; value: longint): boolean;
function RemoveCookie(cookie: TCookieID): boolean;
function GetCookie(cookie: TCookieID; var value: longint): boolean;
function ChangeCookie(cookie: TCookieID; newval: longint): boolean;

procedure Abstract;
procedure GetDesk(var r: GRECT);
function GetOSHeaderPtr: pointer;
function GetMemBuffer(smax,smin: longint; var size: longint): pointer;
function MapKey(key: word): word;
procedure KeyRepeatOff;
procedure KeyRepeatRestore;
function GetTicks: longint;
function BootDevice: char;
function Exist(const FileName: string): boolean;
function PathExist(PathName: string): boolean;
function GetTempFilename: string;
function CreateUniqueTempFilename(pname: string): string;
function CompressPath(PathName: string; MaxLen: integer): string;
procedure CorrectPath(var PathName: string);
function GetPath(const FileName: string): string;
function GetRawPath(const FileName: string): string;
function GetFilename(FileName: string; Ext: boolean): string;
function GetFileSize(FileName: string; FileHdl: integer): longint;
function GetQuotedName(var p: PChar): string;
function GetExtension(const FileName: string): string;
function GetDrives: longint;
function GetBackupFilename(const FileName: string): string;
function HasLongFileNames(PathName: string): boolean;
function CopyFile(oldname,newname: string): boolean;

function NVDIVersion: word;
function MagiCVersion: word;
function MagiCDate: longint;
function MiNTVersion: word;
function GEMDOSVersion: word;
function TOSVersion: word;
function TOSDate: longint;
function VtoS(w: word): string;
function DtoS(l: longint): string;

function Max(a,b: longint): longint;
function Min(a,b: longint): longint;
function Between(x,min,max: longint): boolean;
function Sgn(x: longint): integer;
function Ptr(hi,lo: word): pointer;
function HiWord(p: pointer): word;
function LoWord(p: pointer): word;
function bTst(value,mask: longint): boolean;
function mm2dpi(mm: integer): integer;
procedure appl_yield;

procedure GRtoA2(var r: GRECT);
procedure A2toGR(var r: GRECT);
function rc_intersect(r1: GRECT; var r2: GRECT): boolean;
procedure form_box(flag: integer; r: GRECT);



implementation

uses

	Strings,Tos,Gem;

type

	PAESVARS = ^AESVARS;
	AESVARS  = record
		magic      : longint;
		membot,
		aes_start  : pointer;
		magic2     : TCookieID;
		date       : longint;
		chgres,
		shel_vector,
		aes_bootdrv,
		vdi_device : pointer;
		reservd1,
		reservd2,
		reservd3   : pointer;
		version,
		release    : integer
	end;

	PNVDIStruct = ^TNVDIStruct;
	TNVDIStruct = record
		version,
		datum  : word
	end;

	PMAGX_COOKIE = ^MAGX_COOKIE;
	MAGX_COOKIE  = record
		config_status: longint;
		dos_vars     : pointer;
		aes_vars     : PAESVARS
	end;

var

	kt     : KEYTABPtr;
	nvdiver,
	mxver  : word;
	mxdate,
	oldct  : longint;
	krcount: integer;
	pmagx  : PMAGX_COOKIE;
	pnvdi  : PNVDIStruct;
	posh   : pointer;

	conterm: byte absolute $484;
	hz200  : longint absolute $4ba;
	sysbase: longint absolute $4f2;



procedure Abstract;

	begin
		write('Call to abstract method ');
		runerror(211)
	end;


function NewStr(const s: string): PString;
  var l: longint;
      p: PString;

  begin
    l:=longint(length(s));
    if (l=0) then NewStr:=nil
    else
      begin
        getmem(p,l+longint(1));
        if p<>nil then p^:=s;
        NewStr:=p
      end
  end;


procedure DisposeStr(var p: PString);

  begin
    if p<>nil then
			begin
				freemem(p,longint(length(p^))+longint(1));
				p:=nil
			end
	end;


function ChrNew(const s: string): PChar;
	var l: longint;
	    p: PChar;

	begin
		l:=longint(length(s));
		if l>0 then
			if pos(#0,s)>0 then l:=longint(pos(#0,s))-longint(1);
		getmem(p,l+longint(1));
		if p<>nil then StrPCopy(p,s);
		ChrNew:=p
	end;


procedure ChrDispose(var p: PChar);

	begin
		if p<>nil then
			begin
				freemem(p,StrLen(p)+longint(1));
				p:=nil
			end
	end;


function StrPLeft(const s: string; c: integer): string;

	begin
		if c<0 then c:=0;
		if c>255 then c:=255;
		StrPLeft:=copy(s,1,c)
	end;


function StrPRight(const s: string; c: integer): string;
	var l: integer;

	begin
		l:=length(s);
		if c<0 then c:=0;
		if c>=l then StrPRight:=s
			else StrPRight:=copy(s,l+1-c,c)
	end;


function StrPMid(const s: string; idx,c: integer): string;

	begin
		if c>0 then StrPMid:=copy(s,idx,c)
		else
			StrPMid:=''
	end;


function CutLeftF(const s: string; c: integer): string;

	begin
		CutLeftF:=StrPRight(s,length(s)-c)
	end;


procedure CutLeft(var s: string; c: integer);

	begin
		s:=CutLeftF(s,c)
	end;


function CutRightF(const s: string; c: integer): string;

	begin
		CutRightF:=StrPLeft(s,length(s)-c)
	end;


procedure CutRight(var s: string; c: integer);

	begin
		s:=CutRightF(s,c)
	end;


function StrPTrimF(s: string): string;
	label _lagain,_ragain;

	var l: integer;

	begin
		_lagain:
		l:=length(s);
		if l>0 then
			if (s[1]=#0) or (s[1]=' ') then
				begin
					s:=StrPRight(s,l-1);
					goto _lagain
				end;
		_ragain:
		l:=length(s);
		if l>0 then
			if (s[l]=#0) or (s[l]=' ') then
				begin
					s:=StrPLeft(s,l-1);
					goto _ragain
				end;
		StrPTrimF:=s
	end;


procedure StrPTrim(var s: string);

	begin
		s:=StrPTrimF(s)
	end;


function StrPTrimNumF(s: string): string;
	label _lagain,_ragain;

	var l: integer;

	begin
		_lagain:
		l:=length(s);
		if l>0 then
			if not(s[1] in ['0'..'9']) then
				begin
					s:=StrPRight(s,l-1);
					goto _lagain
				end;
		_ragain:
		l:=length(s);
		if l>0 then
			if not(s[l] in ['0'..'9']) then
				begin
					s:=StrPLeft(s,l-1);
					goto _ragain
				end;
		StrPTrimNumF:=s
	end;


procedure StrPTrimNum(var s: string);

	begin
		s:=StrPTrimNumF(s)
	end;


function StrPSpace(anz: integer): string;

	begin
		StrPSpace:=StrPFill(anz,' ')
	end;


function StrPFill(anz: integer; c: char): string;
	var s: string;
	    q: integer;

	begin
		s:='';
		if anz>0 then
			begin
				if anz>255 then anz:=255;
				for q:=1 to anz do s:=s+c
			end;
		StrPFill:=s
	end;


function StrPUpper(s: string): string;
	var q: integer;

	begin
		if length(s)>0 then
			for q:=1 to length(s) do s[q]:=UpChar(s[q]);
		StrPUpper:=s
	end;


function StrPLower(s: string): string;
	var q: integer;

	begin
		if length(s)>0 then
			for q:=1 to length(s) do s[q]:=LowChar(s[q]);
		StrPLower:=s
	end;


function StrScanQuote(p: PChar): PChar;
	var quote: boolean;

	begin
		if p=nil then StrScanQuote:=nil
		else
			if p^=#39 then
				begin
					quote:=false;
					while p^<>#0 do
						begin
							if p^=#39 then quote:=not(quote)
							else
								if p^=#32 then
									if not(quote) then break;
							inc(longint(p))
						end;
					if p^=#0 then StrScanQuote:=nil
					else
						StrScanQuote:=p
				end
			else
				StrScanQuote:=StrScan(p,' ')
	end;


function GetQuotedName(var p: PChar): string;
	var ret       : string;
	    quote,
	    mintdomain: boolean;
	    i         : integer;

	begin
		ret:='';
		if p<>nil then
			begin
				mintdomain:=(p^=#39);
				quote:=false;
				while p^<>#0 do
					begin
						case p^ of
						#32:
							if not(quote) then
								begin
									inc(longint(p));
									break
								end
							else
								ret:=ret+#32;
						#39:
							begin
								if mintdomain then quote:=not(quote);
								ret:=ret+#39
							end
						else
							ret:=ret+p^
						end;
						inc(longint(p))
					end;
				if p^=#0 then p:=nil;
				if mintdomain then
					if StrPRight(ret,1)=#39 then
						begin
							ret:=StrPMid(ret,2,length(ret)-2);
							i:=1;
							while i<length(ret) do
								begin
									if ret[i]=#39 then
										if ret[i+1]=#39 then
											ret:=StrPLeft(ret,i)+StrPRight(ret,length(ret)-i-1);
									inc(i)
								end
						end
			end;
		GetQuotedName:=ret
	end;


function RPos(subStr,Str: string): byte;
	label _again;

	var wo,ret: integer;

	begin
		ret:=0;
		_again:
		wo:=pos(subStr,Str);
		if wo>0 then
			begin
				Str:=StrPRight(Str,length(Str)-wo);
				inc(ret,wo);
				goto _again
			end;
		RPos:=ret
	end;


function UpChar(ch: char): char;

	begin
		case ch of
			'Ñ': UpChar:='é';
			'î': UpChar:='ô';
			'Å': UpChar:='ö'
		else
			UpChar:=upcase(ch)
		end
	end;


function LowChar(ch: char): char;

	begin
		case ch of
			'é': LowChar:='Ñ';
			'ô': LowChar:='î';
			'ö': LowChar:='Å'
		else
			if ch in ['A'..'Z'] then LowChar:=chr(ord(ch)+32)
			else
				LowChar:=ch
		end
	end;


function ltob(l: longint; anz: integer): string;
	var h: string;

	begin
		if anz<0 then anz:=32
		else
			if anz>32 then anz:=32;
		h:='';
		while l<>0 do
			begin
				if bTst(l,1) then h:='1'+h
				else
					h:='0'+h;
				l:=(l shr 1) and $7fffffff
			end;
		while length(h)<anz do h:='0'+h;
		ltob:='%'+h
	end;


function btol(s: string): longint;
	var ret: longint;
	    q  : integer;

	begin
		btol:=0;
		StrPTrim(s);
		if length(s)<2 then exit;
		if s[1]<>'%' then exit;
		q:=2;
		ret:=0;
		while q<=length(s) do
			begin
				ret:=ret shl 1;
				if s[q]='1' then ret:=ret or 1
				else
					if s[q]<>'0' then exit;
				inc(q)
			end;
		btol:=ret
	end;


function ltoo(l: longint; anz: integer): string;
	var h: string;

	begin
		if anz<0 then anz:=16
		else
			if anz>16 then anz:=16;
		h:='';
		while l<>0 do
			begin
				h:=chr((l and $00000007)+48)+h;
				l:=(l shr 3) and $1fffffff
			end;
		while length(h)<anz do h:='0'+h;
		ltoo:='&'+h
	end;


function otol(s: string): longint;
	var ret: longint;
	    q  : integer;

	begin
		otol:=0;
		StrPTrim(s);
		if length(s)<2 then exit;
		if s[1]<>'&' then exit;
		s:=StrPUpper(s);
		q:=2;
		ret:=0;
		while q<=length(s) do
			begin
				ret:=ret shl 3;
				if s[q] in ['0'..'7'] then ret:=ret+ord(s[q])-48
				else
					exit;
				inc(q)
			end;
		otol:=ret
	end;


function ltoh(l: longint; anz: integer): string;
	var h: string;

	begin
		if anz<0 then anz:=8
		else
			if anz>8 then anz:=8;
		h:='';
		while l<>0 do
			begin
				h:=HexArray[byte(l and $0000000f)]+h;
				l:=(l shr 4) and $0fffffff
			end;
		while length(h)<anz do h:='0'+h;
		ltoh:='$'+h
	end;


function htol(s: string): longint;
	var ret: longint;
	    q  : integer;

	begin
		htol:=0;
		StrPTrim(s);
		if length(s)<2 then exit;
		if s[1]<>'$' then exit;
		s:=StrPUpper(s);
		q:=2;
		ret:=0;
		while q<=length(s) do
			begin
				ret:=ret shl 4;
				if s[q] in ['0'..'9'] then ret:=ret+ord(s[q])-48
				else
					if s[q] in ['A'..'F'] then ret:=ret+ord(s[q])-55
					else
						exit;
				inc(q)
			end;
		htol:=ret
	end;


function ltoa(l: longint): string;
	var s: string;

	begin
		str(l,s);
		ltoa:=s
	end;


function atol(s: string): longint;
	var l    : longint;
	    dummy: integer;

	begin
		StrPTrim(s);
		if length(s)=0 then
			begin
				atol:=0;
				exit
			end;
		if StrPLeft(s,1)='+' then s:=StrPTrimF(StrPRight(s,length(s)-1));
		val(s,l,dummy);
		if dummy<>0 then atol:=0
		else
			atol:=l
	end;


function ftoa(f: real): string;
	var s: string;

	begin
		str(f:0:10,s);
		while StrPRight(s,1)='0' do s:=StrPLeft(s,length(s)-1);
		if StrPRight(s,1)='.' then s:=s+'0';
		ftoa:=s
	end;


function atof(s: string): real;
	var f      : real;
	    dummy,k: integer;
	    lz     : boolean;

	begin
		StrPTrim(s);
		if length(s)=0 then
			begin
				atof:=0.0;
				exit
			end;
		if s[1]='+' then
			begin
				s:=StrPRight(s,length(s)-1);
				if length(s)=0 then
					begin
						atof:=0.0;
						exit
					end;
				lz:=false
			end
		else
			if s[1]='-' then
				begin
					s:=StrPRight(s,length(s)-1);
					if length(s)=0 then
						begin
							atof:=0.0;
							exit
						end;
					lz:=true
				end
			else
				lz:=false;
		k:=pos(',',s);
		while k>0 do
			begin
				s[k]:='.';
				k:=pos(',',s)
			end;
		if s[length(s)]='.' then s:=s+'0';
		if s[1]='.' then val('0'+s,f,dummy)
		else
			val(s,f,dummy);
		if dummy<>0 then atof:=0.0
		else
			if lz then atof:=-f
			else
				atof:=f
	end;


function Sgn(x: longint): integer;

	begin
		if x>0 then Sgn:=1
		else
			if x<0 then Sgn:=-1
			else
				Sgn:=0
	end;


function Ptr(hi,lo: word): pointer;

	begin
		Ptr:=pointer(longint(hi)*longint(65536)+longint(lo))
	end;


function GetCookieJar: PCookie;

	begin
		GetCookieJar:=PCookie(setexc(360,pointer(-1)))
	end;


function NewCookie(cookie: TCookieID; value: longint): boolean;
	var cookiejar: PCookie;
	    anz,maxc : longint;

	begin
		NewCookie:=false;
		cookiejar:=GetCookieJar;
		if cookiejar<>nil then
			begin
				anz:=1;
				while PLongint(cookiejar)^<>0 do
					begin
						inc(longint(cookiejar),8);
						inc(anz)
					end;
				maxc:=cookiejar^.Val;
				if anz<maxc then
					begin
						with cookiejar^ do
							begin
								ID:=cookie;
								Val:=value
							end;
						inc(longint(cookiejar),8);
						with cookiejar^ do
							begin
								ID:=#0#0#0#0;
								Val:=maxc
							end;
						NewCookie:=true
					end
			end
	end;


function RemoveCookie(cookie: TCookieID): boolean;
	var cookiejar,cjo: PCookie;

	begin
		RemoveCookie:=false;
		cookiejar:=GetCookieJar;
		if cookiejar<>nil then
			begin
				while (PLongint(cookiejar)^<>0) and (cookiejar^.ID<>cookie) do
					inc(longint(cookiejar),8);
				if PLongint(cookiejar)^<>0 then
					begin
						cjo:=cookiejar;
						inc(longint(cookiejar),8);
						repeat
							cjo^.ID:=cookiejar^.ID;
							cjo^.Val:=cookiejar^.Val;
							cjo:=cookiejar;
							inc(longint(cookiejar),8)
						until PLongint(cjo)^=0;
						RemoveCookie:=true
					end
			end
	end;


function GetCookie(cookie: TCookieID; var value: longint): boolean;
  var cookiejar: PCookie;

  begin
  	GetCookie:=false;
    cookiejar:=GetCookieJar;
    if cookiejar<>nil then
			while PLongint(cookiejar)^<>0 do
				with cookiejar^ do
					if ID=cookie then
						begin
							value:=Val;
							GetCookie:=true;
							exit
						end
					else
						inc(longint(cookiejar),8)
  end;


function ChangeCookie(cookie: TCookieID; newval: longint): boolean;
  var cookiejar: PCookie;

  begin
  	ChangeCookie:=false;
    cookiejar:=GetCookieJar;
    if cookiejar<>nil then
			while PLongint(cookiejar)^<>0 do
				with cookiejar^ do
					if ID=cookie then
						begin
							Val:=newval;
							ChangeCookie:=true;
							exit
						end
					else
						inc(longint(cookiejar),8)
  end;


function getosheader: longint;

	begin
		getosheader:=sysbase
	end;


function GetOSHeaderPtr: pointer;

	begin
		GetOSHeaderPtr:=posh
	end;


function MapKey(key: word): word;
	var scancode,ret: word;
	    keystate    : longint;

	begin
		if kt=nil then kt:=Keytbl(pointer(-1),pointer(-1),pointer(-1));
		scancode:=key shr 8;
		keystate:=Kbshift(-1);
		if bTst(keystate,KsALT) and Between(scancode,$78,$83) then dec(scancode,$76);
		if bTst(keystate,KsCAPS) then ret:=PByte(longint(kt^.capslock)+scancode)^
		else
			begin
				if (keystate and KsSHIFT)>0 then
					begin
						if Between(scancode,KbF11,KbF20) then ret:=PByte(longint(kt^.shift)+scancode-$19)^
						else
							ret:=PByte(longint(kt^.shift)+scancode)^
					end
				else
					ret:=PByte(longint(kt^.unshift)+scancode)^
			end;
		if ret=0 then ret:=scancode or KbSCAN
		else
			if ((scancode=$4a) or (scancode=$4e) or Between(scancode,$63,$72)) then ret:=ret or KbNUM;
		MapKey:=ret or (keystate shl 8)
	end;


function BootDevice: char;

	begin
		BootDevice:=chr((longint(setexc(273,pointer(-1))) and $000000ff)+65)
	end;


function NVDIVersion: word;

	begin
		NVDIVersion:=nvdiver
	end;


function MagiCVersion: word;

	begin
		MagiCVersion:=mxver
	end;


function MagiCDate: longint;

	begin
		MagiCDate:=mxdate
	end;


function MiNTVersion: word;
	var mver: longint;

	begin
		if GetCookie('MiNT',mver) then MiNTVersion:=mver
		else
			MiNTVersion:=0
	end;


function GEMDOSVersion: word;

	begin
		GEMDOSVersion:=hi(Sversion)+(lo(Sversion) shl 8)
	end;


function TOSVersion: word;

	begin
		TOSVersion:=PWord(longint(GetOSHeaderPtr)+2)^
	end;


function TOSDate: longint;

	begin
		TOSDate:=PLongint(longint(GetOSHeaderPtr)+24)^
	end;


function Max(a,b: longint): longint;

	begin
		if a>b then Max:=a else Max:=b
	end;
	
	
function Min(a,b: longint): longint;

	begin
		if a<b then Min:=a else Min:=b
	end;


function Between(x,min,max: longint): boolean;

	begin
		Between:=((x>=min) and (x<=max))
	end;


function HiWord(p: pointer): word;

	begin
		HiWord:=word(longint(p) div 65536)
	end;


function LoWord(p: pointer): word;

	begin
		LoWord:=word(longint(p) mod 65536)
	end;


function bTst(value,mask: longint): boolean;

	begin
		bTst:=((value and mask)=mask)
	end;


function mm2dpi(mm: integer): integer;

	begin
		if mm<=0 then mm2dpi:=0
		else
			case mm of
			35:
				mm2dpi:=720;
			42:
				mm2dpi:=600;
			71:
				mm2dpi:=360;
			85:
				mm2dpi:=300;
			117,118:
				mm2dpi:=216;
			130:
				mm2dpi:=196;
			141:
				mm2dpi:=180;
			175,176:
				mm2dpi:=144;
			211,212:
				mm2dpi:=120
			else
				mm2dpi:=trunc(25400/mm)
			end
	end;


procedure GRtoA2(var r: GRECT);

	begin
		with r do
			begin
				X1:=X;
				Y1:=Y;
				X2:=X+W-1;
				Y2:=Y+H-1
			end
	end;


procedure A2toGR(var r: GRECT);

	begin
		with r do
			begin
				X:=X1;
				Y:=Y1;
				W:=X2+1-X;
				H:=Y2+1-Y
			end
	end;


function rc_intersect(r1: GRECT; var r2: GRECT): boolean;
	var x,y,w,h: longint;
	
	begin
		x:=Max(r2.X,r1.X);
		y:=Max(r2.Y,r1.Y);
		w:=Min(longint(r2.X)+longint(r2.W),longint(r1.X)+longint(r1.W));
		h:=Min(longint(r2.Y)+longint(r2.H),longint(r1.Y)+longint(r1.H));
		r2.X:=integer(x);
		r2.Y:=integer(y);
		r2.W:=integer(w-x);
		r2.H:=integer(h-y);
		if (w>x) and (h>y) then
			begin
				GRtoA2(r2);
				rc_intersect:=true
			end
		else
			rc_intersect:=false
	end;


procedure form_box(flag: integer; r: GRECT);

	begin
		form_dial(flag,r.X+(r.W shr 1),r.Y+(r.H shr 1),1,1,r.X,r.Y,r.W,r.H)
	end;


function StrLPas(p: PChar; maxc: integer): string;
	var s: string;

	begin
		s:='';
		if maxc>255 then maxc:=255;
		if p<>nil then
			while (p^<>#0) and (length(s)<maxc) do
				begin
					s:=s+p^;
					inc(longint(p))
				end;
		StrLPas:=s
	end;


function StrPPas(p: PChar): string;

	begin
		if p=nil then StrPPas:=''
		else
			StrPPas:=StrPas(p)
	end;


function VtoS(w: word): string;
	var h,s: string[4];

	begin
		h:='';
		while w>0 do
			begin
				h:=HexArray[byte(w and $000f)]+h;
				w:=w shr 4
			end;
		while length(h)<4 do h:='0'+h;
		s:=h[1];
		if s='0' then s:='';
		VtoS:=s+h[2]+'.'+h[3]+h[4]
	end;


function DtoS(l: longint): string;
	var h: string[8];
	    v: longint;
	    s: char;

	begin
		h:='';
		while l<>0 do
			begin
				h:=HexArray[byte(l and $000f)]+h;
				l:=l shr 4
			end;
		while length(h)<8 do h:='0'+h;
		if GetCookie('_IDT',v) then
			begin
				s:=chr(v and $00ff);
				if s=#0 then s:='/';
				v:=(v and $0f00) shr 8
			end
		else
			begin
				v:=1;
				s:='.'
			end;
		case v of
			0: DtoS:=h[1]+h[2]+s+h[3]+h[4]+s+h[5]+h[6]+h[7]+h[8];
			1: DtoS:=h[3]+h[4]+s+h[1]+h[2]+s+h[5]+h[6]+h[7]+h[8];
			2: DtoS:=h[5]+h[6]+h[7]+h[8]+s+h[1]+h[2]+s+h[3]+h[4];
			3: DtoS:=h[5]+h[6]+h[7]+h[8]+s+h[3]+h[4]+s+h[1]+h[2]
		end
	end;


procedure GetDesk(var r: GRECT);

	begin
		wind_get(DESK,WF_WORKXYWH,r.X,r.Y,r.W,r.H);
		GRtoA2(r)
	end;


function Exist(const FileName: string): boolean;
	var ret: longint;

	begin
		ret:=fopen(FileName,FO_READ);
		if ret>=0 then
			begin
				fclose(integer(ret));
				Exist:=true
			end
		else
			Exist:=false
	end;


function PathExist(PathName: string): boolean;
	label _test;

	var olddta  : DTAPtr;
	    newdta  : DTA;
	    ndrv    : integer;
	    drvs,hdl: longint;

	begin
		PathExist:=false;
		if length(PathName)=0 then exit;
		if StrPRight(PathName,1)='\' then PathName:=StrPLeft(PathName,length(PathName)-1);
		if length(PathName)=2 then
			if PathName[2]=':' then
				begin
					ndrv:=ord(upcase(PathName[1]))-65;
					if (ndrv>=0) and (ndrv<=31) then
						begin
							drvs:=GetDrives;
							while ndrv>0 do
								begin
									drvs:=drvs shr 1;
									dec(ndrv)
								end;
							PathExist:=bTst(drvs,1)
						end;
					exit
				end;
		hdl:=dopendir(PathName,0);
		if (hdl and $ff000000)=$ff000000 then
			begin
				if hdl=-32 then
					begin
						if not(AppFlag) then wind_update(BEG_UPDATE);
						olddta:=FGetdta;
						Fsetdta(@newdta);
						if Fsfirst(PathName,FA_DIREC)=0 then
							begin
								_test:
								if newdta.d_attrib=FA_DIREC then PathExist:=true
								else
									if Fsnext=0 then goto _test
							end;
						Fsetdta(olddta);
						if not(AppFlag) then wind_update(END_UPDATE)
					end;
				exit
			end;
		dclosedir(hdl);
		PathExist:=true
	end;


function GetTempFilename: string;
	var t    : word;
	    fname: string[8];

	begin
		t:=tgettime;
		fname:=HexArray[system.random(16)]+HexArray[system.random(16)]+HexArray[system.random(16)]+HexArray[system.random(16)];
		fname:=fname+HexArray[(t shr 12) and $0f]+HexArray[(t shr 8) and $0f]+HexArray[(t shr 4) and $0f]+HexArray[t and $0f];
		GetTempFilename:=StrPLower(fname)+'.$$$'
	end;


function CreateUniqueTempFilename(pname: string): string;
	var fname: string;

	begin
		if length(pname)>0 then
			if StrPRight(pname,1)<>'\' then pname:=pname+'\';
		repeat
			fname:=pname+GetTempFilename
		until not(Exist(fname));
		CreateUniqueTempFilename:=fname
	end;


function CompressPath(PathName: string; MaxLen: integer): string;

	begin
		StrPTrim(PathName);
		if length(PathName)>MaxLen then
			begin
				if MaxLen>10 then CompressPath:=StrPLeft(PathName,3)+'...'+StrPRight(PathName,MaxLen-6)
				else
					CompressPath:=StrPRight(PathName,MaxLen)
			end
		else
			CompressPath:=PathName
	end;


procedure CorrectPath(var PathName: string);

	begin
		if length(PathName)>1 then
			if PathName[2]=':' then
				begin
					PathName[1]:=upcase(PathName[1]);
					if length(PathName)=2 then PathName:=PathName+'\'
					else
						if PathName[3]<>'\' then
							PathName:=StrPLeft(PathName,2)+'\'+StrPRight(PathName,length(PathName)-2)
				end
	end;


function GetPath(const FileName: string): string;

	begin
		if pos('\',FileName)=0 then GetPath:=''
		else
			GetPath:=StrPLeft(FileName,RPos('\',FileName))
	end;


function GetRawPath(const FileName: string): string;
	var s: string;

	begin
		s:=GetPath(FileName);
		if length(s)=3 then
			if StrPRight(s,2)=':\' then
				begin
					GetRawPath:=s;
					exit
				end;
		GetRawPath:=StrPLeft(s,length(s)-1)
	end;


function GetFilename(FileName: string; Ext: boolean): string;

	begin
		if pos('\',FileName)>0 then FileName:=StrPRight(FileName,length(FileName)-RPos('\',FileName));
		if not(Ext) then
			if pos('.',FileName)>0 then FileName:=StrPLeft(FileName,RPos('.',FileName)-1);
		GetFilename:=FileName
	end;


function GetFileSize(FileName: string; FileHdl: integer): longint;
	var xa : XATTR;
	    ret: longint;

	function hdllen(hdl: integer): longint;
		var oldpos: longint;
	
		begin
			oldpos:=fseek(0,hdl,1);
			hdllen:=fseek(0,hdl,2);
			fseek(oldpos,hdl,0);
		end;

	begin
		GetFileSize:=-1;
		if length(FileName)>0 then
			if fxattr(0,FileName,xa)=0 then
				begin
					GetFileSize:=xa.size;
					exit
				end;
		if FileHdl<>0 then GetFileSize:=hdllen(FileHdl)
		else
			if length(FileName)>0 then
				begin
					ret:=fopen(FileName,FO_READ);
					if ret>=0 then
						begin
							FileHdl:=integer(ret);
							GetFileSize:=hdllen(FileHdl);
							fclose(FileHdl)
						end
				end
	end;


function GetExtension(const FileName: string): string;

	begin
		if RPos('.',FileName)>RPos('\',FileName) then
			GetExtension:=StrPRight(FileName,length(FileName)+1-RPos('.',FileName))
		else
			GetExtension:=''
	end;


function GetDrives: longint;

	begin
		GetDrives:=dsetdrv(dgetdrv)
	end;


function GetBackupFilename(const FileName: string): string;

	begin
		if HasLongFileNames(FileName) then GetBackupFilename:=FileName+'.bak'
		else
			GetBackupFilename:=GetPath(FileName)+GetFilename(FileName,false)+'.bak'
	end;


function HasLongFileNames(PathName: string): boolean;
	var maxmode: longint;

	begin
		PathName:=GetPath(PathName);
		if length(PathName)=0 then HasLongFileNames:=false
		else
			begin
				maxmode:=dpathconf(PathName,-1);
				if maxmode<3 then HasLongFileNames:=false
				else
					HasLongFileNames:=(dpathconf(PathName,3)>12)
			end
	end;


function CopyFile(oldname,newname: string): boolean;
	label _raus,_fehler;

	var buf    : pointer;
	    res,
	    bufsize: longint;
	    oldhdl,
	    newhdl : integer;

	begin
		CopyFile:=false;
		if (length(oldname)=0) or (length(newname)=0) then exit;
		buf:=GetMemBuffer(131072,512,bufsize);
		if buf=nil then goto _raus;
		res:=fopen(oldname,FO_READ);
		if res>=0 then
			begin
				oldhdl:=integer(res);
				res:=fcreate(newname,0);
				if res>=0 then
					begin
						newhdl:=integer(res);
						repeat
							res:=fread(oldhdl,bufsize,buf);
							if res<=0 then goto _fehler;
							if fwrite(newhdl,res,buf)<>res then goto _fehler;
						until res<bufsize;
						CopyFile:=true;
						_fehler:
						fclose(newhdl)
					end;
				fclose(oldhdl)
			end;
		_raus:
		if buf<>nil then freemem(buf,bufsize)
	end;


function GetMemBuffer(smax,smin: longint; var size: longint): pointer;
	label _nochmal;

	var p: pointer;

	begin
		if smin<1 then smin:=1;
		_nochmal:
		size:=smax;
		getmem(p,size);
		GetMemBuffer:=p;
		if p=nil then
			begin
				smax:=smax shr 1;
				if smax<smin then size:=0
				else
					goto _nochmal
			end
	end;


procedure appl_yield;

	begin
		evnt_timer(1,0)
	end;


function repoff: longint;

	begin
		repoff:=conterm and 2;
    conterm:=conterm and not(2)
	end;


function repon: longint;

	begin
    conterm:=conterm or byte(oldct);
    repon:=0
	end;


procedure KeyRepeatOff;

	begin
		if krcount<=0 then
			begin
				oldct:=supexec(repoff);
				krcount:=1
			end
		else
			begin
				supexec(repoff);
				inc(krcount)
			end
	end;


procedure KeyRepeatRestore;

	begin
		dec(krcount);
		if krcount<=0 then oldct:=supexec(repon)
	end;


function gethz200: longint;

	begin
		gethz200:=hz200
	end;


function GetTicks: longint;

	begin
		GetTicks:=supexec(gethz200)
	end;


begin
	kt:=nil;
	krcount:=0;
	oldct:=0;
	mxver:=0;
	mxdate:=0;
	posh:=pointer(PLongint(supexec(getosheader)+8)^);
	if GetCookie('MagX',longint(pmagx)) then
		if pmagx<>nil then
			with pmagx^ do
				if aes_vars<>nil then
					with aes_vars^ do
						if magic=-2023406815 then
							if magic2='MAGX' then
								begin
									mxver:=version;
									mxdate:=(date shl 16) or (date shr 24) or ((date shr 8) and $0000ff00)
								end;
	nvdiver:=0;
	if GetCookie('NVDI',longint(pnvdi)) then
		if pnvdi<>nil then
			nvdiver:=pnvdi^.version;
end.