{***************************************
 *      BubbleGEM by Thomas Much       *
 ***************************************
 *   Dieses Programm ist Freeware!     *
 ***************************************
 *  Copyright 1997-98 by Thomas Much   *
 *       thomas@snailshell.de          *
 ***************************************
 *    erstellt am:        23.02.1997   *
 *    letztes Update am:  04.08.1998   *
 ***************************************}

{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

{$M 12288}

program BubbleGEM;

uses

	Strings,Dos,Tos,Gem;

const

	RELEASE           = 8;

	BUBBLEGEM_REQUEST = integer($baba);
	BUBBLEGEM_SHOW    = integer($babb);
	BUBBLEGEM_ACK     = integer($babc);
	BUBBLEGEM_ASKFONT = integer($babd);
	BUBBLEGEM_FONT    = integer($babe);
	BUBBLEGEM_HIDE    = integer($babf);

	BGS7_USRHIDE      = $0001;
	BGS7_MFDB         = $0002; { TODO }
	BGS7_MOUSE        = $0004;
	BGS7_2STRINGS     = $0008;
	BGS7_REQBYDEMON   = $0010; { TODO }
	BGS7_ERROR        = $8000;

	BGC_FONTCHANGED   = $0001;
	BGC_NOWINSTYLE    = $0002;
	BGC_SENDKEY       = $0004;
	BGC_DEMONACTIVE   = $0008;
	BGC_TOPONLY       = $0010;
	BGC_AUTOSTYLE     = $0020; { TODO }

	GS_REQUEST        = $1350;
	GS_REPLY          = $1351;
	AV_SENDCLICK      = $4709;
	AV_SENDKEY        = $4710;
	VA_START          = $4711;
	AV_STARTED        = $4738;
	FONT_CHANGED      = $7a18;
	FONT_ACK          = $7a1a;
	SC_CHANGED        = $0050;
	COLORS_CHANGED    = $0054;
	SCF_TEXT          = $0002;
	GLOBAL            = $20;
	RC                = 2;
	CLIP_ON           = 1;
	FF_DEVSPEC        = 0;
	DESK              = 0;
	BUBBLETEXT        = 'BubbleGEM Release 08-beta (04.08.98).|Copyright '#189'1997/98/99 by Thomas.Much@snailshell.de, http://www.snailshell.de/BubbleGEM/';
	HELPCURSOR     : MFORM = 
		(mf_xhot: 0; mf_yhot: 0; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
		 mf_mask: (-16130,-24125,-28287,-30311,-31247,-31773,-32313,-32625,-32743,-31871,-27709,-22017,-13849,-31513,1278,896);
		 mf_data: (0,16444,24702,28774,30734,31772,32312,32624,32742,31870,27708,17920,1560,792,768,0));
	emptyfill : array [0..15] of integer = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	WRAPCHAR  : char = #27;
	TWOSTRCHAR: char = #31;
	BRACKETS  : set of char = [')',']','}'];
	WRAPCHARS : set of char = [' ',',','.',';','?','!',':','-',')',']','}','\','/'];

type

	PLongint = ^longint;

	TCookieID = array [0..3] of char;

	PCookie = ^TCookie;
	TCookie = record
		ID   : TCookieID;
		Value: longint
	end;

	PBGEM = ^TBGEM;
	TBGEM = record
		magic  : array [0..3] of char;
		size   : longint;
		release: integer;
		active : integer;
		mhelp  : MFORMPtr;
		dtimer : integer;
		{ private }
		helpcrs: MFORM;
	end;

	GRECT   = record
		case integer of
			0: (g_x,g_y,g_w,g_h    : integer);
			1: (X,Y,W,H,X1,Y1,X2,Y2: integer);
			2: (A1,A2              : ARRAY_4)
	end;

	PAESVARS = ^AESVARS;
	AESVARS  = record
		magic      : longint;
		membot,
		aes_start  : pointer;
		magic2     : array [0..3] of char;
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

	PMAGX_COOKIE = ^MAGX_COOKIE;
	MAGX_COOKIE  = record
		config_status: longint;
		dos_vars     : pointer;
		aes_vars     : PAESVARS
	end;

var

	apID,
	vdiHandle,
	oldX,
	oldY,
	userApp,
	allocmode,
	eventmask,
	hellgelb,
	avFontPt,
	avFontID : integer;
	blen     : longint;
	memprot,
	oldvalid,
	broadcast,
	checkupd,
	wfowner,
	dactive,
	toponly,
	has_agi  : boolean;
	pipe     : ARRAY_8;
	workOut  : workout_ARRAY;
	Desktop  : GRECT;
	scrn,
	backgr   : MFDB;
	bgem     : PBGEM;
	bpxy     : record
		case integer of
		0: (b8     : ARRAY_8);
		1: (b41,b42: ARRAY_4)
	end;
	olddata  : record
		mX,
		mY: integer;
	end;


function appl_xgetinfo(ap_gtype: integer; var ap_gout1,ap_gout2,ap_gout3,ap_gout4: integer): boolean;

	begin
		appl_xgetinfo:=false;
		if has_agi then
			with AES_pb do
				begin
					control^[0]:=130;
					control^[1]:=1;
					control^[2]:=5;
					control^[3]:=0;
					control^[4]:=0;
					intin^[0]:=ap_gtype;
					_crystal(@AES_pb);
					if intout^[0]=1 then
						begin
							ap_gout1:=intout^[1];
							ap_gout2:=intout^[2];
							ap_gout3:=intout^[3];
							ap_gout4:=intout^[4];
							appl_xgetinfo:=true
						end
				end
	end;


function HeapFunc(size: longint): integer;

  begin
    HeapFunc:=1
  end;


function GetCookieJar: PCookie;

	begin
		GetCookieJar:=PCookie(setexc(360,pointer(-1)))
	end;


function GetCookie(cookie: TCookieID; var wert: longint): boolean;
  var cookiejar: PCookie;

  begin
  	GetCookie:=false;
    cookiejar:=GetCookieJar;
    if cookiejar<>nil then
			while PLongint(cookiejar)^<>0 do
				with cookiejar^ do
					if ID=cookie then
						begin
							wert:=Value;
							GetCookie:=true;
							exit
						end
					else
						inc(longint(cookiejar),8);
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
							cjo^.Value:=cookiejar^.Value;
							cjo:=cookiejar;
							inc(longint(cookiejar),8)
						until PLongint(cjo)^=0;
						RemoveCookie:=true
					end
			end
	end;


function NewCookie(cookie: TCookieID; wert: longint): boolean;
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


procedure GlobalAlloc(var p: pointer; size: longint);

	begin
		if MemProt then p:=mxalloc(size,allocmode)
		else
			getmem(p,size)
	end;


function bestcolor_gelb: integer;
	var col      : ARRAY_3;
	    bestabst,
	    abst,diff: longint;
	    i,best   : integer;

	begin
		best:=-1;
		bestabst:=0;
		i:=0;
		while i<workOut[13] do
			begin
				vq_color(vdiHandle,i,1,col);
				if col[0]=1000 then
					if col[1]=1000 then
						begin
							abst:=abs(500-col[2]);
			        if (best<0) or (abst<bestabst) or ((abst=bestabst) and (col[2]<500)) then
			        	begin
			        		best:=i;
			        		bestabst:=abst
			        	end
						end;
				inc(i)
			end;
		if best<0 then
			begin
				i:=Yellow;
				while i<workOut[13] do
					begin
						vq_color(vdiHandle,i,1,col);
		        diff:=1000-col[0];
		        abst:=sqr(diff);
		        diff:=1000-col[1];
		        inc(abst,sqr(diff));
		        diff:=500-col[2];
		        inc(abst,sqr(diff));
		        if (best<0) or (abst<bestabst) then
		        	begin
		        		best:=i;
		        		bestabst:=abst
		        	end;
						if i=Yellow then i:=15;
						inc(i)
					end;
				if best<0 then best:=White;
			end;
		bestcolor_gelb:=best
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
					s:=copy(s,2,l-1);
					goto _lagain
				end;
		_ragain:
		l:=length(s);
		if l>0 then
			if (s[l]=#0) or (s[l]=' ') then
				begin
					s:=copy(s,1,l-1);
					goto _ragain
				end;
		StrPTrimF:=s
	end;


procedure GSRequest;
	var answ: ARRAY_8;

	begin
		answ[0]:=GS_REPLY;
		answ[1]:=apID;
		answ[2]:=0;
		answ[3]:=0;
		answ[4]:=0;
		answ[5]:=0;
		answ[6]:=1;
		answ[7]:=pipe[7];
		appl_write(pipe[1],16,@answ)
	end;


procedure ChangeDemon;
	var cval: longint;

	begin
		cval:=0;
		if not(GetCookie('BHLP',cval)) then
			if dactive then cval:=BGC_DEMONACTIVE;
		dactive:=((cval and BGC_DEMONACTIVE)>0) and wfowner;
		toponly:=((cval and BGC_TOPONLY)>0);
		if dactive then eventmask:=eventmask or MU_TIMER
		else
			eventmask:=eventmask and not(MU_TIMER)
	end;


procedure VAStart;
	var answ: ARRAY_8;
	    p,p2: PChar;

	procedure demonOn;
		var cval: longint;

		begin
			if dactive then exit;
			if GetCookie('BHLP',cval) then
				begin
					cval:=cval or BGC_DEMONACTIVE;
					RemoveCookie('BHLP');
					NewCookie('BHLP',cval)
				end;
			dactive:=true;
			ChangeDemon
		end;

	procedure demonOff;
		var cval: longint;
	
		begin
			if not(dactive) then exit;
			if GetCookie('BHLP',cval) then
				begin
					cval:=cval and not(BGC_DEMONACTIVE);
					RemoveCookie('BHLP');
					NewCookie('BHLP',cval)
				end;
			dactive:=false;
			ChangeDemon
		end;

	begin
		p:=PChar((longint(pipe[3]) shl 16) or longint(pipe[4]));
		while p<>nil do
			begin
				while p^=' ' do inc(longint(p));
				p2:=strscan(p,' ');
				if strlcomp(p,'-demon',6)=0 then
					begin
						inc(longint(p),6);
						if strlcomp(p,'on',2)=0 then demonOn
						else if strlcomp(p,'1',1)=0 then demonOn
						else if strlcomp(p,'off',3)=0 then demonOff
						else if strlcomp(p,'0',1)=0 then demonOff
					end;
				p:=p2
			end;
		answ[0]:=AV_STARTED;
		answ[1]:=apID;
		answ[2]:=0;
		answ[3]:=pipe[3];
		answ[4]:=pipe[4];
		answ[5]:=0;
		answ[6]:=0;
		answ[7]:=0;
		appl_write(pipe[1],16,@answ)
	end;


procedure CloseWorkstation;

	begin
		if vq_gdos<>0 then vst_unload_fonts(vdiHandle,0);
		v_clsvwk(vdiHandle);
		if bgem<>nil then bgem^.active:=0;
		vdiHandle:=0;
		userApp:=-1
	end;


procedure RestoreBackground;
	var dummy: integer;

	begin
		graf_mouse(M_OFF,nil);
		if backgr.fd_addr<>nil then
			begin
				scrn.fd_addr:=nil;
				vro_cpyfm(vdiHandle,S_ONLY,bpxy.b8,backgr,scrn);
				freemem(backgr.fd_addr,blen)
			end;
		vst_alignment(vdiHandle,TA_LEFT,TA_BASELINE,dummy,dummy);
		vswr_mode(vdiHandle,MD_REPLACE);
		vs_clip(vdiHandle,CLIP_ON,Desktop.A2);
		graf_mouse(M_ON,nil);
		graf_mouse(ARROW,nil)
	end;


procedure FontChanged;
	var answ: ARRAY_8;
	    bval: longint;

	begin
		if not(GetCookie('BHLP',bval)) then bval:=BGC_FONTCHANGED;
		answ[0]:=FONT_ACK;
		answ[1]:=apID;
		answ[2]:=0;
		answ[3]:=0;
		answ[4]:=0;
		answ[5]:=0;
		answ[6]:=0;
		answ[7]:=0;
		if (bval and BGC_FONTCHANGED)>0 then
			if pipe[3]<0 then
				begin
					answ[3]:=1;
					if pipe[4]<>0 then avFontID:=pipe[4];
					if pipe[5]>0 then avFontPt:=pipe[5]
				end;
		appl_write(pipe[1],16,@answ)
	end;


procedure HideBubble;

	begin
		if (vdiHandle<>0) and (userApp=pipe[1]) then
			begin
				RestoreBackground;
				CloseWorkstation
			end
	end;


procedure ShowBubble;
	var Hlp       : string;
	    answ      : ARRAY_8;
	    i,
	    fontid,
	    fontheight,
	    boxWidth,
	    boxHeight : integer;
	    bval      : longint;
	    workIn    : workin_ARRAY;
	    sendkey,
	    usemouse,
	    winstyle,
	    userhide,
	    ismfdb    : boolean;
	    hpc,pwc   : PChar;

	procedure BubbleWrap(var txt: string);
		var ret    : string;
		    t,width: integer;

		procedure add(s: string);
			label _nochmal;

			var i,l: integer;
			    ext: ARRAY_8;

			begin
				_nochmal:
				s:=StrPTrimF(s);
				vqt_extent(vdiHandle,s,ext);
				if ext[2]>width then
					begin
						l:=length(s);
						repeat
							dec(l);
							vqt_extent(vdiHandle,copy(s,1,l),ext)
						until ext[2]<=width;
						i:=l;
						if s[i+1] in (WRAPCHARS-[' ']) then
							while (s[i] in BRACKETS) and (i>0) do dec(i);
						while not(s[i] in WRAPCHARS) and (i>0) do dec(i);
						if i=0 then i:=l;
						ret:=ret+StrPTrimF(copy(s,1,i))+WRAPCHAR;
						s:=copy(s,i+1,length(s)-i);
						goto _nochmal
					end;
				ret:=ret+s
			end;

		begin
			width:=workOut[0]-3*boxWidth;
			if width>340 then width:=340;
			ret:='';
			t:=pos(WRAPCHAR,txt);
			while t>0 do
				begin
					add(copy(txt,1,t-1));
					ret:=ret+WRAPCHAR;
					txt:=copy(txt,t+1,length(txt)-t);
					t:=pos(WRAPCHAR,txt)
				end;
			add(txt);
			txt:=ret
		end;

	procedure ReplaceWrapChar(var txt: string);
		var q: integer;
	
		begin
			q:=1;
			while q<=length(txt) do
				begin
					if txt[q]='|' then
						begin
							if q<length(txt) then
								if txt[q+1]='|' then
									begin
										txt:=copy(txt,1,q)+copy(txt,q+2,length(txt)-q-1);
										inc(q);
										continue
									end;
							txt[q]:=WRAPCHAR
						end;
					inc(q)
				end
		end;

	function BubbleHelp(mX,mY: integer; ishelp: boolean): boolean;
		label _evntagain,_nosendkey;

		var pxy              : ARRAY_4;
		    evnt,kstate,key,
		    mox,moy,mobut,
		    bclicks,bmask,
		    bret,bstate,
		    nmx,nmy,
		    dummy,cw,lanz,xc,
		    xpos,ypos,yc,mlen: integer;
		    pxya             : ARRAY_8;
		    rawhlp           : string;

		procedure SetHelpCursor;
		
			begin
				if GEM_pb.global[0]>=$0400 then graf_mouse(integer(USER_DEF or $8000),@HELPCURSOR)
				else
					graf_mouse(USER_DEF,@HELPCURSOR)
			end;
		
		procedure GetMax;
			var s  : string;
			    i  : integer;
			    ext: ARRAY_8;
		
			begin
				lanz:=1;
				mlen:=0;
				s:=Hlp;
				i:=pos(WRAPCHAR,s);
				while i>0 do
					begin
						vqt_extent(vdiHandle,copy(s,1,i-1),ext);
						if ext[2]>mlen then mlen:=ext[2];
						s:=copy(s,i+1,length(s)-i);
						inc(lanz);
						i:=pos(WRAPCHAR,s)
					end;
				vqt_extent(vdiHandle,s,ext);
				if ext[2]>mlen then mlen:=ext[2]
			end;

		procedure toClipboard;
			var path  : string;
			    olddta: DTAPtr;
			    newdta: DTA;
			    hdl   : integer;
			    ret   : longint;
			    pipe  : ARRAY_8;
		
			begin
				if ismfdb then exit;
				graf_mouse(BUSYBEE,nil);
				if scrp_read(path)=0 then path:='';
				path:=StrPTrimF(path);
				if length(path)=0 then
					begin
						path:=GetEnv('CLIPBRD');
						if length(path)=0 then path:=GetEnv('SCRAPDIR');
						path:=StrPTrimF(path)
					end;
				if length(path)>0 then
					begin
						if path[length(path)]<>'\' then path:=path+'\';
						olddta:=fgetdta;
						fsetdta(@newdta);
						hdl:=fsfirst(path+'scrap.*',FA_HIDDEN);
						while hdl=0 do
							begin
								fdelete(path+newdta.d_fname);
								hdl:=fsnext
							end;
						fsetdta(olddta);
						ret:=fcreate(path+'scrap.txt',0);
						if ret>=0 then
							begin
								hdl:=integer(ret);
								fwrite(hdl,length(rawhlp),@rawhlp[1]);
								fclose(hdl);
								if broadcast then
									begin
										pipe[0]:=SC_CHANGED;
										pipe[1]:=apID;
										pipe[2]:=0;
										pipe[3]:=SCF_TEXT;
										pipe[4]:=integer((ord('.') shl 8)+ord('t'));
										pipe[5]:=integer((ord('x') shl 8)+ord('t'));
										pipe[6]:=0;
										pipe[7]:=0;
										with AES_pb do
											begin
												control^[0]:=121;
												control^[1]:=3;
												control^[2]:=1;
												control^[3]:=2;
												control^[4]:=0;
												intin^[0]:=7;
												intin^[1]:=0;
												intin^[2]:=0;
												addrin^[0]:=@pipe;
												addrin^[1]:=nil
											end;
										_crystal(@AES_pb)
									end
							end
					end;
				SetHelpCursor
			end;

		begin
			BubbleHelp:=false;
			if (length(Hlp)=0) and not(ismfdb) then exit;
			evnt:=0;
			rawhlp:=Hlp;
			pxy[0]:=0;
			pxy[1]:=0;
			pxy[2]:=workOut[0];
			pxy[3]:=workOut[1];
			vs_clip(vdiHandle,CLIP_ON,pxy);
			vst_alignment(vdiHandle,TA_LEFT,TA_TOP,dummy,dummy);
			if not(ismfdb) then
				begin
					ReplaceWrapChar(Hlp);
					BubbleWrap(Hlp)
				end;
			GetMax;
			if winstyle then
				begin
					xpos:=mX-(mlen shr 2);
					ypos:=mY+(boxHeight shr 2)-(lanz+1)*boxHeight;
					if xpos+mlen+boxWidth>workOut[0] then xpos:=workOut[0]-mlen-boxWidth;
					if ypos<=(boxHeight shr 1) then
						begin
							ypos:=(boxHeight shr 1)+1;
							if ypos+(lanz+1)*boxHeight>mY then
								begin
									ypos:=mY+boxHeight;
									xpos:=mX-(mlen shr 2)*3;
									if xpos+mlen+boxWidth>workOut[0] then xpos:=workOut[0]-mlen-boxWidth
								end
						end;
					if xpos<=boxWidth then xpos:=boxWidth+1;
					pxy[0]:=xpos-(boxWidth shr 1);
					pxy[1]:=ypos-(boxHeight shr 2);
					pxy[2]:=pxy[0]+mlen+boxWidth;
					pxy[3]:=pxy[1]+lanz*boxHeight+(boxHeight shr 1)
				end
			else
				begin
					xpos:=mX-(mlen shr 2);
					ypos:=mY-(lanz+2)*boxHeight;
					if xpos+mlen+boxWidth>workOut[0] then xpos:=workOut[0]-mlen-boxWidth;
					if ypos<=(boxHeight shr 1) then
						begin
							ypos:=(boxHeight shr 1)+1;
							if ypos+(lanz+2)*boxHeight>mY then
								begin
									ypos:=mY+((boxHeight*3) shr 1);
									xpos:=mX-(mlen shr 2)*3;
									if xpos+mlen+boxWidth>workOut[0] then xpos:=workOut[0]-mlen-boxWidth
								end
						end;
					if xpos<=boxWidth then xpos:=boxWidth+1;
					pxy[0]:=xpos-boxWidth;
					pxy[1]:=ypos-(boxHeight shr 1);
					pxy[2]:=pxy[0]+mlen+(boxWidth shl 1);
					pxy[3]:=pxy[1]+(lanz+1)*boxHeight
				end;
			xc:=xpos+(mlen shr 1);
			bpxy.b8[0]:=pxy[0]-2;
			bpxy.b8[2]:=pxy[2]+1;
			if pxy[1]<mY then
				begin
					yc:=pxy[3];
					bpxy.b8[1]:=pxy[1]-2;
					bpxy.b8[3]:=mY+4
				end
			else
				begin
					yc:=pxy[1];
					bpxy.b8[1]:=mY-4;
					bpxy.b8[3]:=pxy[3]+1
				end;
			if bpxy.b8[0]<0 then bpxy.b8[0]:=0;
			if bpxy.b8[1]<0 then bpxy.b8[1]:=0;
			if bpxy.b8[2]>workOut[0] then bpxy.b8[2]:=workOut[0];
			if bpxy.b8[3]>workOut[1] then bpxy.b8[3]:=workOut[1];
			with backgr do
				begin
					fd_w:=bpxy.b8[2]+1-bpxy.b8[0];
					fd_h:=bpxy.b8[3]+1-bpxy.b8[1];
					fd_stand:=FF_DEVSPEC;
					fd_wdwidth:=(fd_w+15) shr 4;
					fd_nplanes:=GEM_pb.global[10];
					blen:=(longint(fd_wdwidth)*longint(fd_h)*longint(fd_nplanes)) shl 1
				end;
			getmem(backgr.fd_addr,blen);
			if backgr.fd_addr=nil then exit;
			if not(userhide) then
				begin
					wind_update(BEG_UPDATE);
					wind_update(BEG_MCTRL)
				end;
			graf_mouse(M_OFF,nil);
			scrn.fd_addr:=nil;
			bpxy.b8[4]:=0;
			bpxy.b8[5]:=0;
			bpxy.b8[6]:=backgr.fd_w-1;
			bpxy.b8[7]:=backgr.fd_h-1;
			vro_cpyfm(vdiHandle,S_ONLY,bpxy.b8,scrn,backgr);
			if winstyle then
				begin
					vsf_color(vdiHandle,hellgelb);
					vsf_interior(vdiHandle,FIS_SOLID);
					v_bar(vdiHandle,pxy);
					vswr_mode(vdiHandle,MD_TRANS);
					vsf_color(vdiHandle,Black);
					vsf_interior(vdiHandle,FIS_HOLLOW);
					v_bar(vdiHandle,pxy)
				end
			else
				begin
					vsf_color(vdiHandle,Black);
					vsf_interior(vdiHandle,FIS_SOLID);
					v_rfbox(vdiHandle,pxy);
					for dummy:=0 to 3 do dec(pxy[dummy]);
					vsf_udpat(vdiHandle,@emptyfill,1);
					vsf_interior(vdiHandle,FIS_USER);
					v_rfbox(vdiHandle,pxy);
					dummy:=integer(round(sqrt(sqr(longint(mX-xc))+sqr(longint(mY-yc)))/6.0));
					pxya[0]:=xc-dummy;
					pxya[1]:=yc-1;
					pxya[2]:=xc+dummy;
					pxya[3]:=pxya[1];
					pxya[4]:=mX;
					pxya[5]:=mY;
					pxya[6]:=pxya[0];
					pxya[7]:=pxya[1];
					v_fillarea(vdiHandle,4,pxya);
					inc(pxya[0]);
					dec(pxya[2]);
					vsl_color(vdiHandle,White);
					v_pline(vdiHandle,2,pxya);
					vsl_color(vdiHandle,Black);
					pxya[4]:=pxya[2];
					pxya[5]:=pxya[3];
					pxya[2]:=mX;
					pxya[3]:=mY;
					v_pline(vdiHandle,3,pxya)
				end;
			dummy:=pos(WRAPCHAR,Hlp);
			while dummy>0 do
				begin
					v_gtext(vdiHandle,xpos,ypos,copy(Hlp,1,dummy-1));
					Hlp:=copy(Hlp,dummy+1,length(Hlp)-dummy);
					inc(ypos,boxHeight);
					dummy:=pos(WRAPCHAR,Hlp)
				end;
			v_gtext(vdiHandle,xpos,ypos,Hlp);
			pxy:=bpxy.b41;
			bpxy.b41:=bpxy.b42;
			bpxy.b42:=pxy;
			graf_mouse(M_ON,nil);
			SetHelpCursor;
			if not(userhide) then
				begin
					evnt_timer(10,0);
					graf_mkstate(nmx,nmy,cw,dummy);
					if (cw and 3)=0 then
						begin
							bclicks:=258;
							bmask:=3;
							bstate:=0
						end
					else
						begin
							bclicks:=0;
							bmask:=3;
							bstate:=0
						end;
					if usemouse then
						begin
							mX:=nmx;
							mY:=nmy
						end;
					evnt_timer(word((bval shr 16) and $0000ffff),0);
					_evntagain:
					evnt:=evnt_multi(MU_KEYBD or MU_BUTTON or MU_M1,bclicks,bmask,bstate,1,mX-6,mY-6,13,13,0,0,0,0,0,pxya,0,0,mox,moy,mobut,kstate,key,bret);
					if (evnt and MU_KEYBD)>0 then
						begin
							case kstate of
							0:
								if key=25088 then
									begin
										if ishelp then goto _evntagain
										else
											begin
												BubbleHelp:=true;
												goto _nosendkey
											end
									end;
							4:
								case key of
								11544:
									begin
										toClipboard;
										goto _nosendkey
									end;
								11779:
									begin
										toClipboard;
										goto _evntagain
									end
								end
							end;
							if sendkey then
								begin
									answ[0]:=AV_SENDKEY;
									answ[1]:=apID;
									answ[2]:=0;
									answ[3]:=kstate;
									answ[4]:=key;
									answ[5]:=0;
									answ[6]:=0;
									answ[7]:=0;
									appl_write(pipe[1],16,@answ)
								end
						end;
					_nosendkey:
					RestoreBackground;
					repeat
						graf_mkstate(dummy,dummy,cw,dummy)
					until (cw and 3)=0;
					wind_update(END_MCTRL);
					wind_update(END_UPDATE);
					if (evnt and MU_BUTTON)>0 then
						if ((mobut and 3)>0) and (bret>0) then
							begin
								answ[0]:=AV_SENDCLICK;
								answ[1]:=apID;
								answ[2]:=0;
								answ[3]:=mox;
								answ[4]:=moy;
								answ[5]:=mobut;
								answ[6]:=kstate;
								answ[7]:=bret;
								appl_write(pipe[1],16,@answ)
							end
				end
		end;

	begin
		if vdiHandle<>0 then pipe[7]:=pipe[7] or BGS7_ERROR
		else
			if (pipe[5]<>0) or (pipe[6]<>0) then
				begin
			  	for i:=1 to 9 do workIn[i]:=1;
			  	workIn[0]:=getrez+2;
					workIn[10]:=RC;
					vdiHandle:=graf_handle(i,i,i,i);
					v_opnvwk(workIn,vdiHandle,workOut);
					if vdiHandle>0 then
						begin
							if bgem<>nil then bgem^.active:=1;
							if vq_gdos<>0 then vst_load_fonts(vdiHandle,0);
							if avFontPt>0 then
								begin
									vst_font(vdiHandle,avFontID);
									vst_point(vdiHandle,avFontPt,i,i,boxWidth,boxHeight)
								end
							else if appl_xgetinfo(0,fontheight,fontid,i,i) then
								begin
									fontid:=vst_font(vdiHandle,fontid);
									vst_height(vdiHandle,fontheight,i,i,boxWidth,boxHeight)
								end
							else
								begin
									vst_font(vdiHandle,vqt_name(vdiHandle,1,Hlp));
									vst_point(vdiHandle,10,i,i,boxWidth,boxHeight)
								end;
							with Desktop do
								begin
									wind_get(DESK,WF_WORKXYWH,X,Y,W,H);
									X1:=X;
									Y1:=Y;
									X2:=X+W-1;
									Y2:=Y+H-1
								end;
							ismfdb:=((pipe[7] and BGS7_MFDB)>0);
							userhide:=((pipe[7] and BGS7_USRHIDE)>0);
							usemouse:=((pipe[7] and BGS7_MOUSE)>0);
							userApp:=pipe[1];
							if not(GetCookie('BHLP',bval)) then bval:=$00c8ffff;
							winstyle:=((bval and BGC_NOWINSTYLE)=0);
							sendkey:=((bval and BGC_SENDKEY)>0);
							if ismfdb then Hlp:=''
							else
								begin
									hpc:=PChar(longint(word(pipe[5]))*longint(65536)+longint(word(pipe[6])));
									if (pipe[7] and BGS7_2STRINGS)>0 then
										begin
											if winstyle then hpc:=PChar(longint(StrEnd(hpc))+1);
										end
									else
										begin
											pwc:=strscan(hpc,TWOSTRCHAR);
											if (pwc<>nil) then
												begin
													if winstyle then hpc:=PChar(longint(pwc)+1)
													else
														pwc^:=#0;
												end
										end;
									Hlp:=StrPas(hpc)
								end;
							if winstyle then
								if hellgelb=-1 then hellgelb:=bestcolor_gelb;
							if not(ismfdb) then
								if BubbleHelp(pipe[3],pipe[4],false) then
									begin
										ismfdb:=false;
										Hlp:=BUBBLETEXT;
										BubbleHelp(pipe[3],pipe[4],true)
									end;
							if not(userhide) then CloseWorkstation
						end
				end;
		answ[0]:=BUBBLEGEM_ACK;
		answ[1]:=apID;
		answ[2]:=0;
		answ[3]:=0;
		answ[4]:=0;
		answ[5]:=pipe[5];
		answ[6]:=pipe[6];
		answ[7]:=pipe[7];
		appl_write(pipe[1],16,@answ)
	end;


procedure InitBubble;
	var dummy,
	    check,
	    mgxver,
	    avid,ag4: integer;
	    cval    : longint;
	    valid   : boolean;
	    answ    : ARRAY_8;
	    avserver: string;

	begin
		HeapError:=@HeapFunc;
		GEM_pb.global[0]:=0;
		apID:=appl_init;
		if GEM_pb.global[0]=0 then halt;
	  if apID<0 then halt;
	  if (GEM_pb.global[0]>=$0400) and AppFlag then menu_register(apID,'  BubbleGEM ');
    menu_register(-1,'BUBBLE  ');
    if GetCookie('MiNT',cval) then memprot:=true
    else
    	begin
		    memprot:=false;
		    if GetCookie('MagX',cval) then
		    	begin
		    		mgxver:=0;
						with PMAGX_COOKIE(cval)^ do
							if aes_vars<>nil then
								with aes_vars^ do
									if (magic=-2023406815) and (magic2='MAGX') then mgxver:=version;
						if mgxver>=$0200 then memprot:=true
		    	end
    	end;
		allocmode:=GLOBAL;
		if AppFlag then allocmode:=allocmode or 3;
		bgem:=nil;
		if not(GetCookie('BGEM',cval)) then
			begin
				GlobalAlloc(pointer(bgem),sizeof(TBGEM));
				if bgem<>nil then
					begin
						bgem^.helpcrs:=HELPCURSOR;
						bgem^.magic:='BGEM';
						bgem^.size:=18;
						bgem^.release:=RELEASE;
						bgem^.active:=0;
						bgem^.mhelp:=@bgem^.helpcrs;
						bgem^.dtimer:=200;
						if not(NewCookie('BGEM',longint(bgem))) then form_alert(1,'[1][(BubbleGEM:)|Der CookieJar ist voll. |Konnte BGEM-Cookie nicht anlegen. ][  OK  ]');
					end
			end;
		has_agi:=(GEM_pb.global[0]>=$0400) or (appl_find('?AGI')=0);
		if appl_xgetinfo(10,check,dummy,dummy,dummy) then
			begin
				valid:=((check and $00ff)>=9) or (GEM_pb.global[0]=$0399);
				broadcast:=((check and $00ff)>=7) or (GEM_pb.global[0]=$0399)
			end
		else
			begin
				valid:=(GEM_pb.global[0]>=$0400);
				broadcast:=valid
			end;
		if appl_xgetinfo(11,check,dummy,dummy,ag4) then
			begin
				wfowner:=((check and $0010)>0);
				checkupd:=(ag4<>0)
			end
		else
			begin
				wfowner:=false;
				checkupd:=false
			end;
		if valid then shel_write(9,1,0,'','');
		oldX:=-1;
		oldY:=-1;
		oldvalid:=false;
		hellgelb:=-1;
		vdiHandle:=0;
		userApp:=-1;
		avFontPt:=0;
		avserver:=GetEnv('AVSERVER');
		if (length(avserver)=0) or (length(avserver)>8) then avid:=0
		else
			begin
				while length(avserver)<8 do avserver:=avserver+' ';
				avid:=appl_find(avserver);
				if avid<0 then avid:=0
			end;
		answ[0]:=BUBBLEGEM_ASKFONT;
		answ[1]:=apID;
		answ[2]:=0;
		answ[3]:=0;
		answ[4]:=0;
		answ[5]:=0;
		answ[6]:=0;
		answ[7]:=0;
		appl_write(avid,16,@answ);
		eventmask:=MU_MESAG;
		dactive:=true;
		ChangeDemon
	end;


procedure ExitBubble;

	begin
		if bgem<>nil then RemoveCookie('BGEM');
		appl_exit
	end;


procedure BubbleLoop;
	label _weiter;

	var event,dummy,
	    mX,mY,BStat,
	    KStat,winID,
	    ownerID,timer: integer;
	    answ         : ARRAY_8;

	begin
		timer:=30000;
		repeat
			if bgem<>nil then timer:=bgem^.dtimer;
			event:=evnt_multi(eventmask,0,0,0,0,0,0,0,0,0,0,0,0,0,pipe,timer,0,dummy,dummy,dummy,dummy,dummy,dummy);
			if (event and MU_MESAG)>0 then
				case pipe[0] of
				BUBBLEGEM_SHOW:
					ShowBubble;
				BUBBLEGEM_HIDE:
					HideBubble;
				BUBBLEGEM_FONT:
					begin
						avFontID:=pipe[3];
						avFontPt:=pipe[4]
					end;
				VA_START:
					VAStart;
				GS_REQUEST:
					GSRequest;
				FONT_CHANGED:
					FontChanged;
				BUBBLEGEM_REQUEST:
					ChangeDemon;
				COLORS_CHANGED:
					hellgelb:=-1;
				AP_TERM:
					break;
				end;
			if (event and MU_TIMER)>0 then
				if bgem<>nil then
					begin
						if checkupd then
							if wind_update(BEG_UPDATE or $0100)=0 then continue;
						graf_mkstate(mX,mY,BStat,KStat);
						if (BStat and 3)=0 then
							if (mX=oldX) then
								if (mY=oldY) then
									begin
										winID:=wind_find(mX,mY);
										if winID>=0 then
											begin
												if toponly then
													begin
														wind_get(0,WF_TOP,ownerID,dummy,dummy,dummy);
														if winID<>ownerID then goto _weiter;
													end;
												wind_get(winID,WF_OWNER,ownerID,dummy,dummy,dummy);
												if ownerID>=0 then
													if bgem^.active=0 then
														begin
															if oldvalid then
																if (olddata.mX=mX) then
																	if (olddata.mY=mY) then goto _weiter;
															answ[0]:=BUBBLEGEM_REQUEST;
															answ[1]:=apID;
															answ[2]:=0;
															answ[3]:=winID;
															answ[4]:=mX;
															answ[5]:=mY;
															answ[6]:=KStat;
															answ[7]:=0;
															appl_write(ownerID,16,@answ);
															olddata.mX:=mX;
															olddata.mY:=mY;
															oldvalid:=true
														end
											end
									end;
						_weiter:
						oldX:=mX;
						oldY:=mY;
						if checkupd then wind_update(END_UPDATE);
					end;
		until false
	end;


begin
	InitBubble;
	BubbleLoop;
	ExitBubble
end.


{ TODO:
	- '|' im Text durch '||' kodierbar, wird vlnr ersetzt
	- BGS7_2STRINGS
	- alternativ Trennung durch ASCII-31 (BGS7_2STRING dann *nicht* gesetzt)
	- ASCII-27 wird intern verwendet und darf in den Hilfstexten nicht vorkommen
	- supexec() -> setexc() (?)
	- bei COLORS_CHANGED hellgelb:=-1
	// BGS7_REQBYDEMON, BGC_AUTOSTYLE
	// nach C portieren
}