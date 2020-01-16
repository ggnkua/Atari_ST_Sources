{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

program XAccSpy;

uses

	Gem,OTypes,OProcs,OWindows,OValidat,ODialogs,OStdWnds;

const

	XSVER = '09.10.1994';
	{$I xaccspy.i}

type

	TRNSBUFFER = record
		hlen : string[5];
		hprot,
		wsave: integer
	end;

	PMyTextWindow = ^TMyTextWindow;
	TMyTextWindow = object(TTextWindow)
		procedure SetupSize; virtual;
	end;

	PXAccApplication = ^TXAccApplication;
	TXAccApplication = object(TApplication)
		tbuffer: TRNSBUFFER;
		HWind  : PMyTextWindow;
		function GetIconTitle: string; virtual;
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		function XAccInsert(accID,mID: integer; Msg,Ver: byte; pName: PChar): boolean; virtual;
		procedure XAccExit(OrgID: integer); virtual;
		function AVInsert(accID: integer; SrvMsg,AccMsg: word; AName: string): boolean; virtual;
		procedure AVExit(OrgID: integer); virtual;
		procedure MUMesag(data: TEventData); virtual;
	end;

	PXAccWindow = ^TXAccWindow;
	TXAccWindow = object(TDialog)
		InfoWnd: PDialog;
		destructor Done; virtual;
		function GetVDIHandle: integer; virtual;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		procedure SetupSize; virtual;
		procedure SetupWindow; virtual;
		function GetIconTitle: string; virtual;
		function GetStyle: integer; virtual;
		procedure UpdateDialog; virtual;
		procedure GetWorkMax(var maxX,maxY: integer); virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure IconPaint(var PaintInfo: TPaintStruct); virtual;
		procedure WMRButton(mX,mY,KStat,Clicks: integer); virtual;
		function ExitDlg(AnIndx: integer): boolean; virtual;
		function OK: boolean; virtual;
		function Help: boolean; virtual;
	end;

	PAbout = ^TAbout;
	TAbout = object(TMenu)
		procedure Work; virtual;
	end;

	PHelp = ^THelp;
	THelp = object(TMenu)
		procedure Work; virtual;
	end;

	PQuit = ^TQuit;
	TQuit = object(TMenu)
		procedure Work; virtual;
	end;

	PHistory = ^THistory;
	THistory = object(TMenu)
		procedure Work; virtual;
	end;

	PSetup = ^TSetup;
	TSetup = object(TMenu)
		procedure Work; virtual;
	end;

	PInfButton = ^TInfButton;
	TInfButton = object(TButton)
		tbuf: TRNSBUFFER;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
	end;

var

	XAccApplication: TXAccApplication;


procedure XSResource; external;  {$L xaccspy.o}



procedure TMyTextWindow.SetupSize;

	begin
		inherited SetupSize;
		SliceMouse;
		Curr.X:=GetPrivateProfileInt('History','Window.X',Curr.X,'XACCSPY.INF');
		SliceMouseNext;
		Curr.Y:=GetPrivateProfileInt('History','Window.Y',Curr.Y,'XACCSPY.INF');
		SliceMouseNext;
		Curr.W:=GetPrivateProfileInt('History','Window.W',Curr.W,'XACCSPY.INF');
		SliceMouseNext;
		Curr.H:=GetPrivateProfileInt('History','Window.H',Curr.H,'XACCSPY.INF');
		ArrowMouse;
		GRtoA2(Curr);
		Calc(WC_WORK,Curr,Work);
		Class.Style:=Class.Style and not(cs_AutoOpen);
		DisableAutoCreate
	end;


function TXAccApplication.GetIconTitle: string;

	begin
		GetIconTitle:='XACC-SPY'
	end;


procedure TXAccApplication.InitInstance;

	begin
		HWind:=nil;
		OpenPrivateProfile('XACCSPY.INF');
		InitResource(@XSResource,nil);
		LoadIcon(XSICON,XSICNSPY);
		SliceMouse;
		with tbuffer do
			begin
				hlen:=GetPrivateProfileString('History','Length','50','XACCSPY.INF');
				SliceMouseNext;
				hprot:=GetPrivateProfileInt('History','Save',bf_Checked,'XACCSPY.INF');
				SliceMouseNext;
				wsave:=GetPrivateProfileInt('Setup','Save',bf_Unchecked,'XACCSPY.INF')
			end;
		ArrowMouse;
		inherited InitInstance;
		new(HWind,Init(MainWindow,'HISTORY (XAcc-Spy)',atol(tbuffer.hlen),0))
	end;


procedure TXAccApplication.InitMainWindow;
	var p: PXAccWindow;

	begin
		new(p,Init(nil,'ObjectGEM XAcc-Spy',XSWINDOW));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
		else
			begin
				new(PButton,Init(p,XSWINFO,id_No,true,'Zeigt Informationen Åber XAcc-Spy an.'));
				new(PButton,Init(p,XSWHELP,id_Help,false,'Zeigt einen Hilfstext an.'));
				if AppFlag then p^.MakeWindow
			end
	end;


procedure ZeichneNeu(p: PWindow);

	begin
		p^.ForceRedraw
	end;


function TXAccApplication.XAccInsert(accID,mID: integer; Msg,Ver: byte; pName: PChar): boolean;

	begin
		XAccInsert:=inherited XAccInsert(accID,mID,Msg,Ver,pName);
		ForEachWnd(@ZeichneNeu)
	end;


procedure TXAccApplication.XAccExit(OrgID: integer);

	begin
		inherited XAccExit(OrgID);
		ForEachWnd(@ZeichneNeu)
	end;


function TXAccApplication.AVInsert(accID: integer; SrvMsg,AccMsg: word; AName: string): boolean;

	begin
		AVInsert:=inherited AVInsert(accID,SrvMsg,AccMsg,AName);
		ForEachWnd(@ZeichneNeu)
	end;


procedure TXAccApplication.AVExit(OrgID: integer);

	begin
		inherited AVExit(OrgID);
		ForEachWnd(@ZeichneNeu)
	end;


procedure TXAccApplication.MUMesag(data: TEventData);
	label _add;

	var nline : string;
	    xattr : TXAccAttr;
	    pc    : PChar;
	    finish: integer;

	procedure Add(line: string);

		begin
			if HWind=nil then exit;
			while HWind^.GetNumLines>=atol(tbuffer.hlen) do HWind^.DeleteLine(0);
			HWind^.AddLine(line)
		end;

	begin
		if (data.Pipe[0]=ACC_EXIT) or (data.Pipe[0]=AV_EXIT) then
			if tbuffer.hprot=bf_Checked then
				begin
					xattr.Name:=nil;
					FindApplication('',data.Pipe[1],xattr);
					if xattr.Name<>nil then nline:=xattr.Name^
					else
						nline:='??? Prozeû #'+ltoa(data.Pipe[1]);
					nline:=' '+nline+':'+StrPSpace(16-length(nline))+'  ';
					if data.Pipe[0]=ACC_EXIT then nline:=nline+'ACC_EXIT'
					else
						nline:=nline+'AV_EXIT';
					Add(nline)
				end;
		inherited MUMesag(data);
		if tbuffer.hprot<>bf_Checked then exit;
		case data.Pipe[0] of
		ACC_ID..ACC_ACC,ACC_ACK..ACC_IMG,AV_PROTOKOLL,VA_PROTOSTATUS:
			begin
				xattr.Name:=nil;
				FindApplication('',data.Pipe[1],xattr);
				if xattr.Name<>nil then nline:=xattr.Name^
				else
					nline:='Prozeû '+ltoa(data.Pipe[1]);
				nline:=' '+nline+':'+StrPSpace(16-length(nline))+'  ';
				case data.Pipe[0] of
					ACC_ID:
						nline:=nline+'ACC_ID';
					ACC_OPEN:
						nline:=nline+'ACC_OPEN';
					ACC_CLOSE:
						nline:=nline+'ACC_CLOSE';
					ACC_ACC:
						nline:=nline+'ACC_ACC';
					ACC_ACK:
						nline:=nline+'ACC_ACK';
					ACC_TEXT:
						nline:=nline+'ACC_TEXT';
					ACC_KEY:
						nline:=nline+'ACC_KEY';
					ACC_META:
						nline:=nline+'ACC_META';
					ACC_IMG:
						nline:=nline+'ACC_IMG';
					AV_PROTOKOLL:
						nline:=nline+'AV_PROTOKOLL';
					VA_PROTOSTATUS:
						nline:=nline+'VA_PROTOSTATUS'
				end;
				nline:=nline+StrPSpace(36-length(nline))+'[3]='+ltoa(data.Pipe[3])+' [4]='+ltoa(data.Pipe[4])+' [5]='+ltoa(data.Pipe[5])+' [6]='+ltoa(data.Pipe[6])+' [7]='+ltoa(data.Pipe[7]);
				if (data.Pipe[0]=ACC_ID) or (data.Pipe[0]=ACC_ACC) then
					begin
						nline:=nline+'  ';
						pc:=Ptr(word(data.Pipe[4]),word(data.Pipe[5]));
						if longint(pc)<=$7fff then
							begin
								nline:=nline+'*** fehlerhafter Pointer: '+ltoa(longint(pc));
								goto _add
							end;
						finish:=0;
						while (length(nline)<255) and (finish<2) do
							begin
								if pc^=#0 then
									begin
										nline:=nline+'.';
										inc(finish)
									end
								else
									begin
										nline:=nline+pc^;
										finish:=0
									end;
								inc(longint(pc))
							end
					end;
				_add:
				Add(nline)
			end;
		AC_CLOSE:
			Add(' AES:           *** AC_CLOSE ***')
		end
	end;


destructor TXAccWindow.Done;

	begin
		with PXAccApplication(Application)^ do
			if tbuffer.wsave=bf_Checked then
				begin
					SliceMouse;
					if WritePrivateProfileInt('Setup','Window.X',Curr.X,'XACCSPY.INF') then
						begin
							SliceMouseNext;
							WritePrivateProfileInt('Setup','Window.Y',Curr.Y,'XACCSPY.INF');
							SliceMouseNext;
							WritePrivateProfileInt('Setup','Window.W',Curr.W,'XACCSPY.INF');
							SliceMouseNext;
							WritePrivateProfileInt('Setup','Window.H',Curr.H,'XACCSPY.INF');
							if HWind<>nil then
								begin
									SliceMouseNext;
									WritePrivateProfileInt('History','Window.X',HWind^.Curr.X,'XACCSPY.INF');
									SliceMouseNext;
									WritePrivateProfileInt('History','Window.Y',HWind^.Curr.Y,'XACCSPY.INF');
									SliceMouseNext;
									WritePrivateProfileInt('History','Window.W',HWind^.Curr.W,'XACCSPY.INF');
									SliceMouseNext;
									WritePrivateProfileInt('History','Window.H',HWind^.Curr.H,'XACCSPY.INF')
								end
						end;
					ArrowMouse
				end;
		inherited Done
	end;


function TXAccWindow.GetVDIHandle: integer;

	begin
		GetVDIHandle:=id_NewHandle
	end;


procedure TXAccWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do
			begin
				Style:=Style or cs_CreateOnAccOpen or cs_FullRedraw or cs_WindowMenuToolbar;
				hbrBackground:=White+1
			end
	end;


procedure TXAccWindow.SetupSize;

	begin
		inherited SetupSize;
		SliceMouse;
		Curr.X:=GetPrivateProfileInt('Setup','Window.X',Curr.X,'XACCSPY.INF');
		SliceMouseNext;
		Curr.Y:=GetPrivateProfileInt('Setup','Window.Y',Curr.Y,'XACCSPY.INF');
		SliceMouseNext;
		Curr.W:=GetPrivateProfileInt('Setup','Window.W',Curr.W,'XACCSPY.INF');
		SliceMouseNext;
		Curr.H:=GetPrivateProfileInt('Setup','Window.H',Curr.H,'XACCSPY.INF');
		ArrowMouse;
		GRtoA2(Curr);
		Calc(WC_WORK,Curr,Work)
	end;


procedure TXAccWindow.SetupWindow;
	var p : PToolbar;
	    pq: PQuit;

	begin
		inherited SetupWindow;
		Attr.ExStyle:=Attr.ExStyle and not(ws_ex_CenterOnce);
		LoadMenu(XSMENU);
		LoadToolbar(XSTOOL,false);
		LoadIcon(new(PIcon,Init(@self,XSICON,XSICNSPY,0,0,false,false,'','')));
		new(PAbout,Init(@self,XSMABOUT,nil,false));
		new(PHelp,Init(@self,XSMHONH,nil,false));
		new(pq,Init(@self,XSMQUIT,nil,false));
		if not(AppFlag) then
			if pq<>nil then pq^.Disable;
		new(PHistory,Init(@self,XSMHIST,nil,false));
		new(PSetup,Init(@self,XSMSETUP,nil,false));
		p:=new(PToolbar,Init(@self,XSTOOL,XSTHIST,K_ALT,Alt_H,nil,false,false,'ôffnet ein Fenster, das alle empfangenen XAcc- und AV-Messages auflistet'));
		if p<>nil then p^.SetMenuIndex(XSMHIST);
		p:=new(PToolbar,Init(@self,XSTOOL,XSTSETUP,K_ALT,Alt_S,nil,false,false,'ôffnet das Setup-Fenster fÅr diverse Einstellungen'));
		if p<>nil then p^.SetMenuIndex(XSMSETUP);
		InfoWnd:=nil
	end;


function TXAccWindow.GetIconTitle: string;

	begin
		GetIconTitle:=Application^.GetIconTitle
	end;


function TXAccWindow.GetStyle: integer;

	begin
		GetStyle:=TWindow.GetStyle { _nicht_ von TDialog! }
	end;


procedure TXAccWindow.UpdateDialog;

	begin
		inherited UpdateDialog;
		if DlgTree<>nil then
			with DlgTree^[ROOT] do
				begin
					ob_x:=Work.X2+1-ob_width;
					ob_y:=Work.Y2+1-ob_height
				end
	end;


procedure TXAccWindow.GetWorkMax(var maxX,maxY: integer);

	begin
		maxX:=maxint;
		maxY:=maxint
	end;


procedure TXAccWindow.Paint(var PaintInfo: TPaintStruct);
	label _raus;

	var cnt,x,y,q,w,msk: integer;
	    txt,dummy      : string;

	begin
		if Application^.XAccList<>nil then cnt:=Application^.XAccList^.Count
		else
			cnt:=0;
		if cnt=0 then
			begin
				SetSubTitle(' Keine XAcc-/AV-Applikation gefunden.');
				goto _raus
			end
		else
			SetSubTitle(' '+ltoa(cnt)+' XAcc-/AV-Applikation(en) gefunden.');
		x:=Work.X+Attr.charWidth;
		y:=Work.Y+Attr.boxHeight;
		v_gtext(vdiHandle,x,y,'Name              apID  meID  Ver  Groups  apType + Features + genName');
		inc(y,Attr.boxHeight shl 1);
		for q:=0 to pred(cnt) do
			with PXAccAttr(Application^.XAccList^.At(q))^ do
				begin
					if Name<>nil then txt:=Name^ else txt:='';
					txt:=txt+StrPSpace(16-length(Name^))+'  ';
					dummy:=ltoa(apID);
					txt:=txt+StrPSpace(3-length(dummy))+dummy+'   ';
					dummy:=ltoa(menuID);
					txt:=txt+StrPSpace(3-length(dummy))+dummy+'   ';
					dummy:=ltoa(Version);
					txt:=txt+StrPSpace(3-length(dummy))+dummy+'  ';
					msk:=1;
					if bTst(Protocol,PROTO_AV) then txt:=txt+'a' else txt:=txt+'_';
					if bTst(Protocol,PROTO_XACC) then txt:=txt+'x' else txt:=txt+'_';
					dummy:='';
					for w:=0 to 3 do
						begin
							if bTst(MsgGroups,msk) then dummy:=chr(w+49)+dummy
							else
								dummy:='_'+dummy;
						  msk:=msk shl 1
						end;
					txt:=txt+dummy+'  ';
					txt:=txt+AppTypeMR+' ';
					if AppTypeHR<>nil then txt:=txt+AppTypeHR^+'  ';
					if ExtFeatures<>nil then txt:=txt+ExtFeatures^+'  ';
					if GenericName<>nil then txt:=txt+GenericName^;
					v_gtext(vdiHandle,x,y,txt);
					inc(y,Attr.boxHeight)
				end;
		_raus:
		inherited Paint(PaintInfo)
	end;


procedure TXAccWindow.IconPaint(var PaintInfo: TPaintStruct);
	var cnt: integer;

	begin
		if Icon<>nil then
			begin
				if Application^.XAccList<>nil then cnt:=Application^.XAccList^.Count
				else
					cnt:=0;
				Icon^.SetText(ltoa(cnt)+' APP')
			end
	end;


procedure TXAccWindow.WMRButton(mX,mY,KStat,Clicks: integer);
	var num : integer;
	    answ: string;

	begin
		if Application^.XAccList=nil then exit;
		if mY-Work.Y<=Attr.boxHeight then
			begin
				if Application^.XAccList^.Count=0 then exit;
				num:=(mX-Work.X) div Attr.boxWidth;
				if num<17 then
					answ:='Der Name der Applikation. XAcc-Programme verwenden meist einen gut lesbaren Namen, AV-Programme dagegen den Namen der Programmdatei.'
				else if (num>=18) and (num<=23) then
					answ:='Die AES-Prozeû-ID. Unter "normalem" TOS hat das Hauptprogramm die ID 0.'
				else if (num>=24) and (num<=29) then
					answ:='Die Nummer des MenÅeintrags. Ist bei Accessories wichtig und wird von Programmen normalerweise auf -1 gesetzt.'
				else if (num>=30) and (num<=34) then
					answ:='Eine von der Applikation beliebig zu setzende Versionsnummer. Die Codierung ist nicht festgelegt.'
				else if (num>=35) and (num<=42) then
					answ:='Eine Bitmap der verstandenen XAcc-Message-Gruppen (v.r.n.l.). Eine akzeptierte Gruppe wird durch die entsprechende Zahl gekennzeichnet, sonst wird ein Unterstrich ausgegeben. '
					      +'Links wird auûerdem noch die Art des Protokolls angegeben (a=AV, x=XAcc).'				else if (num>=43) and (num<=50) then
					answ:='Der Applikations-Typ (optional). Die ersten beiden Groûbuchstaben geben den maschinenlesbaren Typ an, dann folgt der "menschenlesbare".'
				else if (num>=51) and (num<=61) then
					answ:='Evtl. vorhandene erweiterte Mîglichkeiten (optional). Der Inhalt ist nicht genormt, daher mÅssen Programme, die darauf zugreifen, das andere Programm kennen.'
				else
					answ:='Der sog. generische Name (optional). Kann verwendet werden, um Ñhnliche oder zusammengehîrende Programme zu kennzeichnen.';
				Application^.BubbleHelp(mX,mY,500,answ)
			end
		else
			begin
				num:=mY-Work.Y-2*Attr.boxHeight-(Attr.boxHeight shr 2);
				if (Clicks<>1) or (num<0) then exit;
				num:=num div Attr.boxHeight;
				if num<Application^.XAccList^.Count then
					begin
						answ:=GetPrivateProfileString('Info',PXAccAttr(Application^.XAccList^.At(num))^.Name^,'','XACCSPY.INF');
						if length(answ)=0 then Application^.BubbleHelp(mX,mY,500,'Keine Informationen vorhanden.')
						else
							Application^.BubbleHelp(mX,mY,500,answ)
					end
			end
	end;


function TXAccWindow.ExitDlg(AnIndx: integer): boolean;
	var p: PStatic;

	begin
		if AnIndx=XSWINFO then
			begin
				if InfoWnd=nil then
					begin
						new(InfoWnd,Init(@self,'INFO (XAcc-Spy)',XSINFO));
						if InfoWnd<>nil then
							begin
								new(p,Init(InfoWnd,XSIVER,28,true,'"Mîge die OOP mit Euch sein!"'));
								if p<>nil then p^.SetText('XACC-SPY Version '+XSVER);
								new(p,Init(InfoWnd,XSIGO,34,false,''));
								if p<>nil then p^.SetText('mit ObjectGEM '+VtoS(GOVersion)+' fÅr PurePascal');
								new(PButton,Init(InfoWnd,XSIOK,id_OK,true,'Schlieût das INFO-Fenster.'))
							end
					end;
				if InfoWnd<>nil then InfoWnd^.MakeWindow
			end;
		ExitDlg:=false
	end;


function TXAccWindow.OK: boolean;

	begin
		Application^.Quit;
		OK:=true
	end;


function TXAccWindow.Help: boolean;

	begin
		Application^.Alert(@self,1,NOTE,'Bringen Sie den Mauscursor Åber das Dialogelement, zu dem Sie Hilfe benîtigen. DrÅcken Sie dann die <Help>- oder die rechte Maustaste.','  &OK  ');
		Help:=false
	end;


procedure TAbout.Work;

	begin
		PDialog(Parent)^.ExitDlg(XSWINFO)
	end;


procedure THelp.Work;

	begin
		PDialog(Parent)^.Help
	end;


procedure TQuit.Work;

	begin
		Application^.Quit
	end;


procedure THistory.Work;

	begin
		with PXAccApplication(Application)^ do if HWind<>nil then HWind^.MakeWindow
	end;


procedure TSetup.Work;
	var ed: PEdit;

	begin
		if ADialog=nil then
			begin
				new(ADialog,Init(PWindow(Parent),'SETUP (XAcc-Spy)',XSSETUP));
				if ADialog<>nil then
					begin
						new(ed,Init(ADialog,XSSHLEN,5,'Legt fest, wieviele Zeilen in der History gespeichert werden kînnen'));
						new(PCheckBox,Init(ADialog,XSSHIST,true,'Bestimmt, ob die empfangenen Messages in der History mitprotokolliert werden sollen'));
						new(PCheckBox,Init(ADialog,XSSWIND,true,'Ist diese Checkbox markiert, wird beim Verlassen vom XAcc-Spy bzw. bei Anwahl von "INF speichern" die aktuelle Fensterposition und -grîûe gespeichert'));
						new(PInfButton,Init(ADialog,XSSINF,id_NoExit,true,'Nach einer Sicherheitsabfrage werden die aktuellen Einstellungen in der Datei XACCSPY.INF gespeichert'));
						new(PButton,Init(ADialog,XSSOK,id_OK,true,'öbernimmt die Einstellungen'));
						new(PButton,Init(ADialog,XSSABBR,id_Cancel,true,'Bricht den Dialog ab, ohne neue Einstellungen zu Åbernehmen'));
						if ed<>nil then
							ed^.SetValidator(new(PRangeValidator,Init(10,1999)));
						ADialog^.TransferBuffer:=@PXAccApplication(Application)^.tbuffer
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


procedure TInfButton.Changed(AnIndx: integer; DblClick: boolean);
	var tb: pointer;

	begin
		if Application^.Alert(Parent,1,WAIT,'Wollen Sie XACCSPY.INF speichern?','  &Ja  | &Nein ')=1 then
			begin
				with Parent^ do
					begin
						tb:=TransferBuffer;
						TransferBuffer:=@tbuf;
						TransferData(tf_GetData);
						TransferBuffer:=tb
					end;
				SliceMouse;
				if WritePrivateProfileString('History','Length',tbuf.hlen,'XACCSPY.INF') then
					begin
						SliceMouseNext;
						WritePrivateProfileInt('History','Save',tbuf.hprot,'XACCSPY.INF');
						SliceMouseNext;
						WritePrivateProfileInt('Setup','Save',tbuf.wsave,'XACCSPY.INF');
						if tbuf.wsave=bf_Checked then
							begin
								SliceMouseNext;
								WritePrivateProfileInt('Setup','Window.X',Parent^.Parent^.Curr.X,'XACCSPY.INF');
								SliceMouseNext;
								WritePrivateProfileInt('Setup','Window.Y',Parent^.Parent^.Curr.Y,'XACCSPY.INF');
								SliceMouseNext;
								WritePrivateProfileInt('Setup','Window.W',Parent^.Parent^.Curr.W,'XACCSPY.INF');
								SliceMouseNext;
								WritePrivateProfileInt('Setup','Window.H',Parent^.Parent^.Curr.H,'XACCSPY.INF');
								if PXAccApplication(Application)^.HWind<>nil then
									with PXAccApplication(Application)^.HWind^ do
										begin
											SliceMouseNext;
											WritePrivateProfileInt('History','Window.X',Curr.X,'XACCSPY.INF');
											SliceMouseNext;
											WritePrivateProfileInt('History','Window.Y',Curr.Y,'XACCSPY.INF');
											SliceMouseNext;
											WritePrivateProfileInt('History','Window.W',Curr.W,'XACCSPY.INF');
											SliceMouseNext;
											WritePrivateProfileInt('History','Window.H',Curr.H,'XACCSPY.INF')
										end
							end
					end;
				SavePrivateProfile;
				ArrowMouse
			end
	end;


begin
  XAccApplication.Init('XAcc-Spy');
  XAccApplication.Run;
  XAccApplication.Done
end.