{**************************************
 *  O b j e c t G E M   Version 1.20  *
 *  Copyright 1992-94 by Thomas Much  *
 **************************************
 *         Unit  O P R O C S          *
 **************************************
 *    Softdesign Computer Software    *
 *    Thomas Much, Gerwigstraûe 46,   *
 *  76131 Karlsruhe, (0721) 62 28 41  *
 *         Thomas Much @ KA2          *
 *  UK48@ibm3090.rz.uni-karlsruhe.de  *
 **************************************
 *    erstellt am:        13.07.1992  *
 *    letztes Update am:  27.08.1994  *
 **************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

  ObjectGEM wird mit dem _vollstÑndigen_ Quelltext ausgeliefert, d.h.
  jeder kann sich die Unit selbst compilieren, womit die extrem lÑstigen
  KompatibilitÑtsprobleme mit den PP-Releases beseitigt sind.
  ObjectGEM ist und bleibt aber trotzdem SHAREWARE, d.h. wer die Biblio-
  thek regelmÑûig benutzt, muû sich REGISTRIEREN lassen. DafÅr gibt es
  die neueste Version und - gegen einen geringen Aufpreis - auch ein
  gedrucktes Handbuch.

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


{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

unit OProcs;

interface

uses

	OTypes;


function NewStr(s: string): PString;
procedure DisposeStr(var p: PString);
function ChrNew(s: string): PChar;
procedure ChrDispose(var p: PChar);
function StrLPas(p: PChar; maxc: integer): string;
function StrPLeft(s: string; c: integer): string;
function StrPRight(s: string; c: integer): string;
function StrPTrimF(s: string): string;
procedure StrPTrim(var s: string);
function StrPSpace(anz: integer): string;
function StrPUpper(s: string): string;
function StrPLower(s: string): string;
function RPos(subStr,Str: string): byte;
function UpChar(ch: char): char;
function LowChar(ch: char): char;

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
function MapKey(key: word): word;
function BootDevice: char;
function Exist(FileName: string): boolean;
function PathExist(PathName: string): boolean;
function GetTempFilename: string;
function GetPath(FileName: string): string;
function GetFilename(FileName: string; Ext: boolean): string;
function GetExtension(FileName: string): string;
function GetDrives: longint;

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

procedure GRtoA2(var r: GRECT);
procedure A2toGR(var r: GRECT);
function rc_intersect(r1: GRECT; var r2: GRECT): boolean;
procedure form_box(flag: integer; r: GRECT);



implementation

uses

	Strings,Tos,Gem;

const

	_bootdev   = $446;
	_sysbase   = $4f2;
	_p_cookies = $5a0;

var

	kt: KEYTABPtr;


procedure Abstract;

	begin
		write('Call to abstract method ');
		runerror(211)
	end;


function NewStr(s: string): PString;
  var l: integer;
      p: PString;

  begin
    l:=length(s);
    if (l=0) then NewStr:=nil
    else
      begin
        getmem(p,l+1);
        if p<>nil then p^:=s;
        NewStr:=p
      end
  end;


procedure DisposeStr(var p: PString);

  begin
    if p<>nil then
			begin
				freemem(p,length(p^)+1);
				p:=nil
			end
	end;


function ChrNew(s: string): PChar;
	var l: integer;
	    p: PChar;

	begin
		l:=length(s);
		if l>0 then
			if pos(#0,s)>0 then l:=pos(#0,s)-1;
		getmem(p,l+1);
		if p<>nil then StrPCopy(p,s);
		ChrNew:=p
	end;


procedure ChrDispose(var p: PChar);

	begin
		if p<>nil then
			begin
				freemem(p,StrLen(p)+1);
				p:=nil
			end
	end;


function StrPLeft(s: string; c: integer): string;

	begin
		if c<0 then c:=0;
		if c>255 then c:=255;
		StrPLeft:=copy(s,1,c)
	end;


function StrPRight(s: string; c: integer): string;
	var l: integer;

	begin
		l:=length(s);
		if c<0 then c:=0;
		if c>=l then StrPRight:=s
			else StrPRight:=copy(s,l+1-c,c)
	end;


function StrPTrimF(s: string): string;
	label _lagain,_ragain;

	var s1: string[1];

	begin
		_lagain:
		s1:=StrPLeft(s,1);
		if (s1=#0) or (s1=' ') then
			begin
				s:=StrPRight(s,length(s)-1);
				goto _lagain
			end;
		_ragain:
		s1:=StrPRight(s,1);
		if (s1=#0) or (s1=' ') then
			begin
				s:=StrPLeft(s,length(s)-1);
				goto _ragain
			end;
		StrPTrimF:=s
	end;


procedure StrPTrim(var s: string);

	begin
		s:=StrPTrimF(s)
	end;


function StrPSpace(anz: integer): string;
	var s: string;
	    q: integer;

	begin
		s:='';
		if anz>0 then
			begin
				if anz>255 then anz:=255;
				for q:=1 to anz do s:=s+' '
			end;
		StrPSpace:=s
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
		if StrPLeft(s,1)='+' then s:=StrPTrimF(StrPRight(s,length(s)-1));
		val(s,l,dummy);
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
	var f    : real;
	    dummy: integer;

	begin
		StrPTrim(s);
		if StrPLeft(s,1)='+' then s:=StrPTrimF(StrPRight(s,length(s)-1));
		val(s,f,dummy);
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
		Ptr:=pointer(hi*65536+lo)
	end;


function GetCookieJar: PCookie;
	var oldstack: longint;

	begin
		if Super(pointer(1))=0 then oldstack:=Super(nil)
    else
    	oldstack:=0;
    GetCookieJar:=PCookie(pointer(_p_cookies)^);
    if oldstack<>0 then Super(pointer(oldstack))
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


function GetOSHeaderPtr: pointer;
	var oldstack: longint;
	    p       : pointer;

	begin
		if Super(pointer(1))=0 then oldstack:=super(nil)
		else
			oldstack:=0;
		p:=pointer(PLongint(_sysbase)^);
		if oldstack<>0 then super(pointer(oldstack));
		GetOSHeaderPtr:=pointer(PLongint(longint(p)+8)^)
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
	var oldstack: longint;

	begin
		if Super(pointer(1))=0 then oldstack:=super(nil)
		else
			oldstack:=0;
		BootDevice:=chr(PWord(_bootdev)^+65);
		if oldstack<>0 then super(pointer(oldstack))
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
	var x,y,w,h: integer;
	
	begin
		x:=Max(r2.X,r1.X);
		y:=Max(r2.Y,r1.Y);
		w:=Min(r2.X+r2.W,r1.X+r1.W);
		h:=Min(r2.Y+r2.H,r1.Y+r1.H);
		r2.X:=x;
		r2.Y:=y;
		r2.W:=w-x;
		r2.H:=h-y;
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


function Exist(FileName: string): boolean;
	var olddta: DTAPtr;
	    newdta: DTA;

	begin
		if not(AppFlag) then wind_update(BEG_UPDATE);
		olddta:=FGetdta;
		Fsetdta(@newdta);
		Exist:=(Fsfirst(FileName,FA_RDONLY or FA_HIDDEN or FA_SYSTEM)=0);
		Fsetdta(olddta);
		if not(AppFlag) then wind_update(END_UPDATE)
	end;


function PathExist(PathName: string): boolean;
	label _test,_fertig;

	var olddta: DTAPtr;
	    newdta: DTA;
	    ndrv  : integer;
	    drvs  : longint;

	begin
		PathExist:=false;
		if not(AppFlag) then wind_update(BEG_UPDATE);
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
					goto _fertig
				end;
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
		_fertig:
		if not(AppFlag) then wind_update(END_UPDATE)
	end;


function GetTempFilename: string;
	var d,t  : word;
	    fname: string[8];

	begin
		d:=tgetdate;
		t:=tgettime;
		fname:=HexArray[(d shr 12) and $0f]+HexArray[(d shr 8) and $0f]+HexArray[(d shr 4) and $0f]+HexArray[d and $0f];
		fname:=fname+HexArray[(t shr 12) and $0f]+HexArray[(t shr 8) and $0f]+HexArray[(t shr 4) and $0f]+HexArray[t and $0f];
		GetTempFilename:=StrPLower(fname)+'.$$$'
	end;


function GetPath(FileName: string): string;

	begin
		if pos('\',FileName)=0 then GetPath:=''
		else
			GetPath:=StrPLeft(FileName,RPos('\',FileName))
	end;


function GetFilename(FileName: string; Ext: boolean): string;

	begin
		if pos('\',FileName)>0 then FileName:=StrPRight(FileName,length(FileName)-RPos('\',FileName));
		if not(Ext) then
			if pos('.',FileName)>0 then FileName:=StrPLeft(FileName,RPos('.',FileName)-1);
		GetFilename:=FileName
	end;


function GetExtension(FileName: string): string;

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


procedure appl_yield;

	begin
		evnt_timer(1,0)
	end;


begin
	kt:=nil
end.