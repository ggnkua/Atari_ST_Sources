{***************************************
 * Object Linking for GEM Applications *
 *       written by Thomas Much        *
 ***************************************
 *      O L G A - M a n a g e r        *
 *   Dieses Programm ist Freeware!     *
 ***************************************
 *    Softdesign Computer Software     *
 *    Thomas Much, Gerwigstraže 46,    *
 *  76131 Karlsruhe, (0721) 62 28 41   *
 *         Thomas Much @ KA2           *
 *  uk48@ibm3090.rz.uni-karlsruhe.de   *
 ***************************************
 *    erstellt am:        07.03.1995   *
 *    letztes Update am:  08.03.1995   *
 ***************************************}

{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

{$M 4096}

program OLGA;

uses

	Strings,Dos,Tos,Gem;

const

	OLGAVersion      = '1.00';
	OLGARevision     = '0.5';
	OLGADate         = '08.03.95';
	OLGAProtocol     = 0;

	OLGA_INIT        = $1236;
	OLGA_EXIT        = $1237;
	OLGA_UPDATE      = $1238;
	OLGA_ACK         = $1239;
	OLGA_RENAME      = $123a;
	OLGA_OPENDOC     = $123b;
	OLGA_CLOSEDOC    = $123c;
	OLGA_LINK        = $123d;
	OLGA_UNLINK      = $123e;
	OLGA_UPDATED     = $123f;
	OLGA_RENAMELINK  = $1240;
	OLGA_LINKRENAMED = $1241;
	OLGA_BLOCK       = $1242;
	OLGA_UNBLOCK     = $1243;
	OLGA_BREAKLINK   = $1244;
	OLGA_LINKBROKEN  = $1245;
	OLGA_START       = $1246;

	OL_SERVER        = $0001;
	OL_CLIENT        = $0002;
	OL_PIPES         = $1000;
	OL_START         = $2000;
	OL_MANAGER       = $4000;

	OLS_TYPE         =     1;
	OLS_EXTENSION    =     2;
	OLS_NAME         =     3;

	AP_DRAGDROP      =    63;
	VA_START         = $4711;
	AV_PATH_UPDATE   = $4730;
	GLOBAL           =   $20;
	_p_cookies       =  $5a0;

type

	PLongint = ^longint;

	PCookie = ^TCookie;
	TCookie = record
		ID:  array[0..3] of char;
		Val: longint
	end;

	PLink = ^TLink;
	TLink = record
		apID,
		Group: integer;
		Path : pointer;
		Prev,
		Next : PLink
	end;

	PDocument = ^TDocument;
	TDocument = record
		apID,
		Group: integer;
		Name : PChar;
		Prev,
		Next : PDocument
	end;

	PApp = ^TApp;
	TApp = record
		apID,
		Protocol,
		Flags,
		XAccType,
		CmdLen  : integer;
		Name    : PChar;
		StartCmd: pointer;
		Prev,
		Next    : PApp
	end;

	PType = ^TType;
	TType = record
		typ : integer;
		path: string;
		next: PType
	end;

	PExtension = ^TExtension;
	TExtension = record
		ext4,
		ext5: integer;
		path: string;
		next: PExtension
	end;

label

	_again,_exit,_started;

var

	apID,
	menuID,
	LinkCount,
	AppCount,
	DocCount,
	tmp_drive,
	stid      : integer;
	MultiTOS,
	Multitask,
	MemProt,
	MagiX,
	found     : boolean;
	pipe,
	answ      : ARRAY_8;
	OlgaName,
	p2        : pointer;
	Apps,
	pa,
	pad       : PApp;
	Links,
	pl,
	pld       : PLink;
	Docs,
	pdoc,
	pdocd     : PDocument;
	Types,
	pt,
	ptd       : PType;
	Extensions,
	pe,
	ped       : PExtension;
	pc,
	pc2       : PChar;
	stname    : NameStr;
	fname,
	tmp_cwd,
	dummy     : string;
	cookiejar : PCookie;
	f         : text;



function ltoa(x: longint): string;
	var dummy: string;

	begin
		str(x,dummy);
		ltoa:=dummy
	end;


function StrPPas(p: PChar): string;

	begin
		if p=nil then StrPPas:=''
		else
			StrPPas:=StrPas(p)
	end;


function Ptr(hi,lo: word): pointer;

	begin
		Ptr:=pointer(hi*65536+lo)
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


procedure GlobalAlloc(var p: pointer; size: longint);

	begin
		if MemProt then p:=mxalloc(size,GLOBAL)
		else
			getmem(p,size)
	end;


procedure GlobalFree(var p: pointer; size: longint);

	begin
		if p=nil then exit;
		if not(MemProt) then
			begin
				freemem(p,size);
				p:=nil
			end
		else
			if mfree(p)=0 then p:=nil
	end;


procedure OpenDoc(nv: boolean);

	begin
		new(pdoc);
		if pdoc<>nil then
			begin
				pdoc^.apID:=pipe[1];
				pdoc^.Group:=pipe[5];
				if nv then pdoc^.Name:=PChar(Ptr(word(pipe[3]),word(pipe[4])))
				else
					pdoc^.Name:=nil;
				pdoc^.Prev:=nil;
				pdoc^.Next:=nil;
				if Docs=nil then Docs:=pdoc
				else
					begin
						pdocd:=Docs;
						while pdocd^.Next<>nil do pdocd:=pdocd^.Next;
						pdocd^.Next:=pdoc;
						pdoc^.Prev:=pdocd
					end;
				inc(DocCount)
			end
	end;


procedure Unlink(pv,gv: boolean);
	label _unlink,_weiter;

	begin
		if pv then
			begin
				answ[6]:=0;
				pc:=PChar(Ptr(word(pipe[3]),word(pipe[4])))
			end;
		_unlink:
		pld:=Links;
		while pld<>nil do
			with pld^ do
				begin
					if apID=pipe[1] then
						begin
							if gv then
								if Group<>pipe[5] then goto _weiter;
							if pv then
								if StrIComp(pc,Path)<>0 then goto _weiter;
							GlobalFree(Path,StrLen(Path)+1);
							if (Prev=nil) and (Next=nil) then Links:=nil
							else
								begin
									if Prev=nil then Links:=Next
									else
										Prev^.Next:=Next;
									if Next<>nil then Next^.Prev:=Prev
								end;
							dispose(pld);
							dec(LinkCount);
							if pv then inc(answ[6]);
							goto _unlink
						end;
					_weiter:
					pld:=Next
				end
	end;


procedure CloseDoc(gv: boolean);
	label _closedoc,_weiter;

	begin
		_closedoc:
		pdocd:=Docs;
		while pdocd<>nil do
			with pdocd^ do
				begin
					if apID=pipe[1] then
						begin
							if gv then
								if Group<>pipe[5] then goto _weiter;
							if (Prev=nil) and (Next=nil) then Docs:=nil
							else
								begin
									if Prev=nil then Docs:=Next
									else
										Prev^.Next:=Next;
									if Next<>nil then Next^.Prev:=Prev
								end;
							dispose(pdocd);
							dec(DocCount);
							goto _closedoc
						end;
					_weiter:
					pdocd:=Next
				end
	end;


procedure ShelWrite(mode,wisgr,wiscr: integer; cmd,tail: pointer);

	begin
		with AES_pb do
			begin
				control^[0]:=121;
				control^[1]:=3;
				control^[2]:=1;
				control^[3]:=2;
				control^[4]:=0;
				intin^[0]:=mode;
				intin^[1]:=wisgr;
				intin^[2]:=wiscr;
				addrin^[0]:=cmd;
				addrin^[1]:=tail;
				_crystal(@AES_pb);
				if intout^[0]<>0 then answ[6]:=1
			end
	end;


function getjar: longint;

	begin
		getjar:=PLongint(_p_cookies)^
	end;


begin
	MemProt:=false;
	MagiX:=false;
  cookiejar:=PCookie(supexec(getjar));
  if cookiejar<>nil then
		while PLongint(cookiejar)^<>0 do
			with cookiejar^ do
				begin
					if ID='MiNT' then MemProt:=true
					else
						if ID='MagX' then MagiX:=true;
					inc(longint(cookiejar),8);
				end;
	GEM_pb.global[0]:=0;
	apID:=appl_init;
	if GEM_pb.global[0]=0 then halt;
  if apID<0 then halt;
  wind_update(BEG_UPDATE);
	MultiTOS:=(GEM_pb.global[0]>=$0400) and (GEM_pb.global[1]=-1);
	Multitask:=(GEM_pb.global[1]<>1);
	menuID:=-1;
	Links:=nil;
	Apps:=nil;
	Docs:=nil;
	if not(AppFlag) or MultiTOS then
		begin
			menuID:=menu_register(apID,'  OLGA-Manager ');
			if menuID<0 then
				begin
					wind_update(END_UPDATE);
					if MultiTOS then
						begin
							appl_exit;
							halt
						end
					else
						repeat
							evnt_timer(0,1)
						until false
				end;
		end;
	if AppFlag and not(Multitask) then
		begin
			form_alert(1,'[0][OLGA v'+OLGAVersion+'  Rev '+OLGARevision+' ('+OLGADate+') | |Bitte als Accessory oder unter|einem Multitasking-Betriebs-|system verwenden.][   OK   ]');
			wind_update(END_UPDATE);
			appl_exit;
			halt
		end;
	LinkCount:=0;
	AppCount:=0;
	DocCount:=0;
	GlobalAlloc(OlgaName,13);
	if OlgaName<>nil then StrPCopy(OlgaName,'OLGA-Manager');
	Types:=nil;
	Extensions:=nil;
	stid:=0;
	assign(f,'OLGA.INF');
	reset(f);
	if ioresult=0 then
		begin
			while not(eof(f)) do
				begin
					readln(f,dummy);
					if length(dummy)>0 then
						if dummy[1]<>';' then
							begin
								if dummy[1]='[' then
									begin
										if dummy='[Extensions]' then stid:=1
										else
											if dummy='[Types]' then stid:=2
											else
												stid:=0
									end
								else
									if stid=1 then
										begin
											new(pe);
											if pe=nil then continue;
											tmp_drive:=pos('=',dummy);
											pe^.ext4:=integer((ord(dummy[1]) shl 8) or ord(dummy[2]));
											if tmp_drive=3 then pe^.ext5:=0
											else
												if tmp_drive=4 then pe^.ext5:=integer((ord(dummy[3]) shl 8))
												else
													pe^.ext5:=integer((ord(dummy[3]) shl 8) or ord(dummy[4]));
											pe^.path:=copy(dummy,tmp_drive+1,length(dummy)-tmp_drive);
											pe^.next:=nil;
											if Extensions=nil then Extensions:=pe
											else
												begin
													ped:=Extensions;
													while ped^.next<>nil do ped:=ped^.next;
													ped^.next:=pe
												end
										end
									else
										if stid=2 then
											begin
												new(pt);
												if pt=nil then continue;
												pt^.typ:=integer((ord(dummy[1]) shl 8) or ord(dummy[2]));
												pt^.path:=copy(dummy,4,length(dummy)-3);
												pt^.next:=nil;
												if Types=nil then Types:=pt
												else
													begin
														ptd:=Types;
														while ptd^.next<>nil do ptd:=ptd^.next;
														ptd^.next:=pt
													end
											end
							end
				end;
			close(f)
		end;
	wind_update(END_UPDATE);
	repeat
		evnt_mesag(pipe);
		_again:
		case pipe[0] of
		AC_OPEN:
			form_alert(1,'[0][OLGA v'+OLGAVersion+'  Rev '+OLGARevision+' ('+OLGADate+') |    by Thomas Much (FREEWARE!)|'+ltoa(AppCount)+' OLGA-Application(s)|'+ltoa(DocCount)+' Document(s)|'+ltoa(LinkCount)+' Link(s)][   OK   ]');
		AV_PATH_UPDATE:
			begin
				pad:=Apps;
				while pad<>nil do
					with pad^ do
						begin
							if apID=pipe[1] then
								begin
									if not(bTst(Flags,OL_SERVER)) then
										begin
											pipe[0]:=OLGA_UPDATE;
											goto _again
										end;
									break
								end;
							pad:=Next
						end
			end;
		OLGA_INIT:
			begin
				new(pa);
				if pa<>nil then
					begin
						pa^.apID:=pipe[1];
						pa^.Flags:=pipe[3];
						pa^.Protocol:=pipe[4];
						pa^.XAccType:=pipe[7];
						pa^.Name:=Ptr(word(pipe[5]),word(pipe[6]));
						pa^.StartCmd:=nil;
				    pa^.Prev:=nil;
				    pa^.Next:=nil;
						if Apps=nil then Apps:=pa
						else
							begin
								pad:=Apps;
								while pad^.Next<>nil do pad:=pad^.Next;
								pad^.Next:=pa;
								pa^.Prev:=pad
							end;
						inc(AppCount);
						answ[7]:=1
					end
				else
					answ[7]:=0;
				answ[0]:=OLGA_INIT;
				answ[1]:=apID;
				answ[2]:=0;
				answ[3]:=OL_MANAGER or OL_START;
				answ[4]:=OLGAProtocol;
				answ[5]:=integer(HiWord(OlgaName));
				answ[6]:=integer(LoWord(OlgaName));
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_EXIT:
			begin
				Unlink(false,false);
				CloseDoc(false);
				_exit:
				pad:=Apps;
				while pad<>nil do
					with pad^ do
						begin
							if apID=pipe[1] then
								begin
									if StartCmd<>nil then GlobalFree(StartCmd,CmdLen);
									if (Prev=nil) and (Next=nil) then Apps:=nil
									else
										begin
											if Prev=nil then Apps:=Next
											else
												Prev^.Next:=Next;
											if Next<>nil then Next^.Prev:=Prev
										end;
									dispose(pad);
									dec(AppCount);
									goto _exit
								end;
							pad:=Next
						end
			end;
		OLGA_UPDATE:
			begin
				answ[0]:=OLGA_UPDATED;
				answ[1]:=apID;
				answ[2]:=0;
				answ[5]:=0;
				answ[6]:=0;
				pc:=PChar(Ptr(word(pipe[3]),word(pipe[4])));
				pld:=Links;
				while pld<>nil do
					with pld^ do
						begin
							if StrIComp(pc,Path)=0 then
								begin
									answ[3]:=integer(HiWord(Path));
									answ[4]:=integer(LoWord(Path));
									answ[7]:=Group;
									appl_write(apID,16,@answ)
								end;
							pld:=Next
						end;
				answ[0]:=OLGA_ACK;
				answ[3]:=pipe[3];
				answ[4]:=pipe[4];
				answ[7]:=OLGA_UPDATE;
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_RENAME:
			begin
				pld:=Links;
				answ[0]:=OLGA_RENAMELINK;
				answ[1]:=apID;
				answ[2]:=0;
				answ[5]:=pipe[5];
				answ[6]:=pipe[6];
				pc:=PChar(Ptr(word(pipe[3]),word(pipe[4])));
				while pld<>nil do
					with pld^ do
						begin
							if StrIComp(pc,Path)=0 then
								begin
									answ[3]:=integer(HiWord(Path));
									answ[4]:=integer(LoWord(Path));
									answ[7]:=Group;
									appl_write(apID,16,@answ)
								end;
							pld:=Next
						end;
				answ[0]:=OLGA_ACK;
				answ[3]:=pipe[3];
				answ[4]:=pipe[4];
				answ[7]:=OLGA_RENAME;
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_LINKRENAMED:
			begin
				pld:=Links;
				pc:=PChar(Ptr(word(pipe[3]),word(pipe[4])));
				while pld<>nil do
					with pld^ do
						begin
							if Group=pipe[7] then
								if pc=Path then
									begin
										pc2:=PChar(Ptr(word(pipe[5]),word(pipe[6])));
										GlobalAlloc(p2,StrLen(pc2)+1);
										if p2<>nil then
											begin
												StrCopy(p2,pc2);
												GlobalFree(Path,StrLen(Path)+1);
												Path:=p2
											end
									end;
							pld:=Next
						end
			end;
		OLGA_OPENDOC:
			OpenDoc(true);
		OLGA_CLOSEDOC:
			begin
				Unlink(false,true);
				CloseDoc(true);
				answ[0]:=OLGA_ACK;
				answ[1]:=apID;
				answ[2]:=0;
				answ[3]:=0;
				answ[4]:=0;
				answ[5]:=pipe[5];
				answ[6]:=0;
				answ[7]:=OLGA_CLOSEDOC;
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_LINK:
			begin
				found:=false;
				pdocd:=Docs;
				while pdocd<>nil do
					with pdocd^ do
						begin
							if apID=pipe[1] then
								begin
									found:=true;
									break
								end;
							pdocd:=Next
						end;
				if not(found) then OpenDoc(false);
				if (pipe[3]=0) and (pipe[4]=0) then answ[6]:=0
				else
					begin
						new(pl);
						if pl<>nil then
							begin
								pl^.apID:=pipe[1];
								pl^.Group:=pipe[5];
								pc:=PChar(Ptr(word(pipe[3]),word(pipe[4])));
								GlobalAlloc(pl^.Path,StrLen(pc)+1);
								if pl^.Path=nil then
									begin
										dispose(pl);
										answ[6]:=0
									end
								else
									begin
										StrCopy(pl^.Path,pc);
										pl^.Prev:=nil;
										pl^.Next:=nil;
										if Links=nil then Links:=pl
										else
											begin
												pld:=Links;
												while pld^.Next<>nil do pld:=pld^.Next;
												pld^.Next:=pl;
												pl^.Prev:=pld
											end;
										answ[6]:=1;
										inc(LinkCount)
									end
							end
						else
							answ[6]:=0
					end;
				answ[0]:=OLGA_ACK;
				answ[1]:=apID;
				answ[2]:=0;
				answ[3]:=pipe[3];
				answ[4]:=pipe[4];
				answ[5]:=pipe[5];
				answ[7]:=OLGA_LINK;
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_UNLINK:
			begin
				Unlink(true,true);
				answ[0]:=OLGA_ACK;
				answ[1]:=apID;
				answ[2]:=0;
				answ[3]:=pipe[3];
				answ[4]:=pipe[4];
				answ[5]:=pipe[5];
				answ[7]:=OLGA_UNLINK;
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_BREAKLINK:
			begin
				pld:=Links;
				answ[0]:=OLGA_LINKBROKEN;
				answ[1]:=apID;
				answ[2]:=0;
				answ[6]:=0;
				answ[7]:=0;
				pc:=PChar(Ptr(word(pipe[3]),word(pipe[4])));
				while pld<>nil do
					with pld^ do
						begin
							if StrIComp(pc,Path)=0 then
								begin
									answ[3]:=integer(HiWord(Path));
									answ[4]:=integer(LoWord(Path));
									answ[5]:=Group;
									appl_write(apID,16,@answ)
								end;
							pld:=Next
						end;
				answ[0]:=OLGA_ACK;
				answ[3]:=pipe[3];
				answ[4]:=pipe[4];
				answ[5]:=0;
				answ[7]:=OLGA_BREAKLINK;
				appl_write(pipe[1],16,@answ)
			end;
		OLGA_START:
			begin
				answ[6]:=0;
				pa:=Apps;
				while pa<>nil do
					with pa^ do
						begin
							if apID=pipe[1] then break;
							pa:=Next
						end;
				if pa=nil then goto _started;
				fname:='';
				case pipe[3] of
				OLS_TYPE:
					begin
						pt:=Types;
						while pt<>nil do
							with pt^ do
								begin
									if typ=pipe[5] then
										begin
											fname:=path;
											break
										end;
									pt:=next
								end
					end;
				OLS_EXTENSION:
					begin
						pe:=Extensions;
						while pe<>nil do
							with pe^ do
								begin
									if ext4=pipe[4] then
										if ext5=pipe[5] then
											begin
												fname:=path;
												break
											end;
									pe:=next
								end
					end;
				OLS_NAME:
					fname:=StrPPas(Ptr(word(pipe[4]),word(pipe[5])))
				end;
				if length(fname)=0 then goto _started;
				if pa^.StartCmd<>nil then GlobalFree(pa^.StartCmd,pa^.CmdLen);
				pa^.CmdLen:=length(StrPPas(Ptr(word(pipe[6]),word(pipe[7]))))+1;
				fsplit(fname,dummy,stname,tmp_cwd);
				while length(stname)<8 do stname:=stname+' ';
				stid:=appl_find(stname);
				if stid>=0 then
					begin
						GlobalAlloc(pa^.StartCmd,pa^.CmdLen);
						if pa^.StartCmd=nil then goto _started;
						StrPCopy(pa^.StartCmd,StrPPas(Ptr(word(pipe[6]),word(pipe[7]))));
						answ[0]:=VA_START;
						answ[1]:=apID;
						answ[2]:=0;
						answ[3]:=integer(HiWord(pa^.StartCmd));
						answ[4]:=integer(LoWord(pa^.StartCmd));
						answ[5]:=0;
						answ[6]:=0;
						answ[7]:=0;
						appl_write(stid,16,@answ);
						answ[6]:=1
					end
				else
					if MultiTOS or MagiX then
						begin
							inc(pa^.CmdLen);
							GlobalAlloc(pa^.StartCmd,pa^.CmdLen);
							if pa^.StartCmd=nil then goto _started;
							PChar(pa^.StartCmd)^:=chr(pa^.CmdLen);
							StrPCopy(PChar(longint(pa^.StartCmd)+1),StrPPas(Ptr(word(pipe[6]),word(pipe[7]))));
							fname:=fname+#0;
							tmp_drive:=dgetdrv;
							dgetpath(tmp_cwd,tmp_drive+1);
							if length(fname)>1 then
								if fname[2]=':' then dsetdrv(ord(upcase(fname[1]))-65);
							dsetpath(dummy+#0);
							if MultiTOS then ShelWrite(0,1,1,@fname[1],pa^.StartCmd)
							else
								ShelWrite(1,1,100,@fname[1],pa^.StartCmd);
							if answ[6]=0 then
								begin
									dsetdrv(tmp_drive);
									dsetpath(tmp_cwd)
								end
						end;
				_started:
				answ[0]:=OLGA_ACK;
				answ[1]:=apID;
				answ[2]:=0;
				answ[3]:=pipe[3];
				answ[4]:=pipe[4];
				answ[5]:=pipe[5];
				answ[7]:=OLGA_START;
				appl_write(pipe[1],16,@answ);
				if (pipe[6]<>0) or (pipe[7]<>0) then
					begin
						answ[3]:=0;
						answ[4]:=pipe[6];
						answ[5]:=pipe[7];
						answ[6]:=0;
						appl_write(pipe[1],16,@answ)
					end
			end;
		OLGA_BLOCK:
			{ ... };
		OLGA_UNBLOCK:
			{ ... }
		end
	until false
end.