{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z+}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z+}
{$ENDIF}

program GEMWizard;

uses

	Gem,OTypes,OProcs,OWindows,ODialogs,OStdWnds;

const

	WVERSION   = '0.17';
	WDATE      = '22.11.1994';
	{$I wizard.i}

type

	PWizIcon = ^TWizIcon;
	TWizIcon = object(TIcon)
		function IsAppObject: boolean; virtual;
		procedure IMMoved(X,Y: integer); virtual;
	end;

	PAppIcon = ^TAppIcon;
	TAppIcon = object(TWizIcon)
		function IsAppObject: boolean; virtual;
		procedure Work; virtual;
	end;

	PWndIcon = ^TWndIcon;
	TWndIcon = object(TWizIcon)
		{ ... }
		procedure Work; virtual;
	end;

	PArrangeWindow = ^TArrangeWindow;
	TArrangeWindow = object(TWindow)
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		procedure SetupWindow; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
	end;

	PWizardApplication = ^TWizardApplication;
	TWizardApplication = object(TApplication)
		appbuffer: record  { in TArrangeWindow bzw. TAppIcon einbauen... }
			filename: string[9];
			objname : string[31];
			entry   : string[17];
			cookie  : string[5];
			rsc,
			incl,
			load,
			profile,
			xinp,
			copt,
			rem,
			xtxt,
			xkey,
			xgem,
			ximg,
			iwnd,
			rbox,
			timr,
			gdos,
			auto,
			av,
			drag    : integer
		end;
		optbuffer: record
			pascal,
			binobj,
			rcs     : string[63];
			realtab : integer;
			tabsize : string[1];
			xinput  : integer
		end;
		AppIcon: PAppIcon; { in TArrangeWindow einbauen... }
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		procedure GetMenuEntries(var Entries: TMenuEntries); virtual;
	end;

	PAppDialog = ^TAppDialog;
	TAppDialog = object(TDialog)
		function OK: boolean; virtual;
	end;

	POptDialog = ^TOptDialog;
	TOptDialog = object(TDialog)
		function OK: boolean; virtual;
	end;

	PAbout = ^TAbout;
	TAbout = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PNew = ^TNew;
	TNew = object(TKeyMenu)
		procedure Work; virtual;
	end;

	POpen = ^TOpen;
	TOpen = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PSave = ^TSave;
	TSave = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PSaveAs = ^TSaveAs;
	TSaveAs = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PUndo = ^TUndo;
	TUndo = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PNewWObj = ^TNewWObj;
	TNewWObj = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PGenerate = ^TGenerate;
	TGenerate = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PAppConf = ^TAppConf;
	TAppConf = object(TKeyMenu)
		procedure Work; virtual;
	end;

	POptions = ^TOptions;
	TOptions = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PSaveOpt = ^TSaveOpt;
	TSaveOpt = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PTabCheckBox = ^TTabCheckBox;
	TTabCheckBox = object(TCheckBox)
		pte: PEdit;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
	end;

	PRscCheckBox = ^TRscCheckBox;
	TRscCheckBox = object(TCheckBox)
		pr1,pr2: PRadioButton;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
	end;

	PColButton = ^TColButton;
	TColButton = object(TButton)
		color: integer;
		obj  : PControl;
		constructor Init(AParent: PDialog; AnIndx,AnID: integer; UserDef: boolean; Hlp: string; colr: integer; objct: PControl);
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
	end;

var

	Wizard   : TWizardApplication;
	WizardPtr: PWizardApplication;



procedure WizardResource; external; {$L wizard.o}



procedure TWizIcon.IMMoved(X,Y: integer);

	begin
		SetPos(X,Y,false);
		PWindow(Parent)^.ForceRedraw
	end;


function TWizIcon.IsAppObject: boolean;

	begin
		IsAppObject:=false
	end;


function TAppIcon.IsAppObject: boolean;

	begin
		IsAppObject:=true
	end;


procedure TAppIcon.Work;
	var p : PCheckBox;
	    pc: PRscCheckBox;
	    pe: PEdit;
	    pv: PValidator;

	begin
		if Click=1 then exit;
		if ADialog=nil then
			begin
				ADialog:=new(PAppDialog,Init(PWindow(Parent),GetText,WIZAPP));
				if ADialog<>nil then
					begin
						new(pe,Init(ADialog,WAPPPNAM,9,'Gibt den Namen des Programm-Quelltexts an, der auch fÅr die "program ..."-Klausel verwendet wird'));
						new(pv,Init);
						pv^.Options:=voNotEmpty;
						pe^.SetValidator(pv);
						new(pe,Init(ADialog,WAPPONAM,32,'Bestimmt den Namen des Applikationsobjekts und der globalen statischen Application-Variablen'));
						new(pv,Init);
						pv^.Options:=voNotEmpty;
						pe^.SetValidator(pv);
						new(pe,Init(ADialog,WAPPENTR,18,'Mit diesem Text meldet sich das Programm beim AES an'));
						new(pv,Init);
						pv^.Options:=voNotEmpty;
						pe^.SetValidator(pv);
						new(pe,Init(ADialog,WAPPCOOK,5,'Wird in neuen ObjectGEM-Versionen nicht mehr benîtigt'));
						pe^.Disable; { ... }
						new(pv,Init);
						pv^.Options:=voNotEmpty;
						pe^.SetValidator(pv);
						new(pc,Init(ADialog,WAPPRSC,true,'Bestimmt, ob die Applikation eine Resource-Datei verwendet'));
						new(pc^.pr1,Init(ADialog,WAPPINC,true,'Die Resource-Datei wird in die Programmdatei eingebunden'));
						new(pc^.pr2,Init(ADialog,WAPPLOAD,true,'Die *.RSC-Datei wird zur Laufzeit nachgeladen'));
						new(PCheckBox,Init(ADialog,WAPPPROF,true,'Ist dieses Feld markiert, wird fÅr das Programm die passende .INF-Datei angelegt'));
						new(PCheckBox,Init(ADialog,WAPPXINP,true,'Schaltet den X-Eingabemodus ein, d.h. Tastatureingaben werden an das Fenster unter dem Mauszeiger weitergeleitet (wie unter X/Unix)'));
						new(PCheckBox,Init(ADialog,WAPPOPT,true,'Bestimmt, ob dem Quelltext auûer $X+ noch weitere Compiler-Optionen (auch zum Debuggen) hinzugefÅgt werden'));
						new(p,Init(ADialog,WAPPREM,true,'Gibt an, ob alle Methoden mit Kommentaren gespeichert werden sollen'));
						p^.Disable; { ... }
						new(PGroupBox,Init(ADialog,WAPPXACC,'XAcc-Protokoll','Legt fest, welche Daten per XAcc empfangen werden kînnen'));
						new(PCheckBox,Init(ADialog,WAPPXTXT,true,'XAcc-Text-Daten werden ausgewertet'));
						new(PCheckBox,Init(ADialog,WAPPXKEY,true,'XAcc-Tastatur-Daten werden ausgewertet'));
						new(PCheckBox,Init(ADialog,WAPPXGEM,true,'XAcc-GEM-Metafiles werden ausgewertet'));
						new(PCheckBox,Init(ADialog,WAPPXIMG,true,'XAcc-VDI-(X)IMG-Grafiken werden ausgewertet'));
						new(PCheckBox,Init(ADialog,WAPPIWND,true,'In dem ikonifizierten Fenster der Applikation soll Text, Grafik etc. dargestellt werden'));
						new(PCheckBox,Init(ADialog,WAPPRBOX,true,'Auf dem Desktop kann eine Rubbox aufgezogen werden (wichtig z.B. fÅr Icons)'));
						new(PCheckBox,Init(ADialog,WAPPTIMR,true,'Die Applikation erhÑlt Timer-Events'));
						new(PCheckBox,Init(ADialog,WAPPGDOS,true,'Wenn die Applikation (Speedo)GDOS-ZeichensÑtze verwenden mîchte, mÅssen diese geladen werden'));
						new(PCheckBox,Init(ADialog,WAPPAUTO,true,'Wenn das Programm im AUTO-Ordner gestartet wird, soll eine Aktion durchgefÅhrt werden'));
						new(PCheckBox,Init(ADialog,WAPPAV,true,'Das AV-Protokoll soll ausgewertet werden'));
						new(PCheckBox,Init(ADialog,WAPPDRAG,true,'Unter MultiTOS soll Drag&Drop unterstÅtzt werden'));
						new(PButton,Init(ADialog,WAPPOK,id_OK,true,'öbernimmt die énderungen'));
						new(PButton,Init(ADialog,WAPPABBR,id_Cancel,true,'Schlieût den Dialog, ohne die énderungen zu Åbernehmen'));
						ADialog^.TransferBuffer:=@WizardPtr^.appbuffer;
						if WizardPtr^.appbuffer.rsc=bf_Checked then
							begin
								pc^.pr1^.Enable;
								pc^.pr2^.Enable
							end
						else
							begin
								pc^.pr1^.Disable;
								pc^.pr2^.Disable
							end
					end
			end;
		if ADialog<>nil then
			begin
				ADialog^.SetTitle(GetText);
				ADialog^.MakeWindow
			end
	end;


procedure TWndIcon.Work;
	var pc: PControl;
	    p : PCheckBox;

	begin
		if Click=1 then exit;
		{ ... }
		Application^.Alert(PWindow(Parent),1,NOTE,'Dieses Icon funktioniert in der Vorversion vom GEM-Wizard noch nicht.','  &OK  ');
		exit;
		{ ... }
		if ADialog=nil then
			begin
				new(ADialog,Init(PWindow(Parent),GetText,WIZWND));
				if ADialog<>nil then
					begin
						new(PEdit,Init(ADialog,WWNDONAM,32,'Bestimmt den Namen des Fensterobjekts'));
						new(PEdit,Init(ADialog,WWNDTITL,61,''));
						new(PEdit,Init(ADialog,WWNDCLAS,61,''));
						new(PGroupBox,Init(ADialog,WWNDCURS,'Mauscursor',''));
						new(PRadioButton,Init(ADialog,WWNDNONE,true,''));
						new(PRadioButton,Init(ADialog,WWNDARRW,true,''));
						new(PRadioButton,Init(ADialog,WWNDTEXT,true,''));
						new(PRadioButton,Init(ADialog,WWNDHOUR,true,''));
						new(PRadioButton,Init(ADialog,WWNDHAND,true,''));
						new(PRadioButton,Init(ADialog,WWNDTCRS,true,''));
						new(PRadioButton,Init(ADialog,WWNDFCRS,true,''));
						new(PRadioButton,Init(ADialog,WWNDOCRS,true,''));
						new(PRadioButton,Init(ADialog,WWNDPEN,true,''));
						new(PRadioButton,Init(ADialog,WWNDRUB,true,''));
						new(PRadioButton,Init(ADialog,WWNDSCIS,true,''));
						new(PRadioButton,Init(ADialog,WWNDPAST,true,''));
						new(PGroupBox,Init(ADialog,WWNDPOS,'Position beim ôffnen',''));
						new(PComboBox,Init(ADialog,WWNDZENT,WWNDPZEN,0,WIZPOP,WPOPPOS,true,false,'Bestimmt die Position eines neuen Fensters'));
						new(PCheckBox,Init(ADialog,WWNDONCE,true,'Gibt an, ob die Position nur beim ersten ôffnen berechnet werden soll'));
						new(PGroupBox,Init(ADialog,WWNDGADG,'Komponenten','Legt fest, welche Komponenten das Fenster besitzt. Ein Titel ist immer vorhanden, und das Fenster kann grundsÑtzlich bewegt werden.'));
						new(PCheckBox,Init(ADialog,WWNDINFO,true,''));
						new(PCheckBox,Init(ADialog,WWNDCLOS,true,''));
						new(PCheckBox,Init(ADialog,WWNDFULL,true,''));
						new(PCheckBox,Init(ADialog,WWNDSIZE,true,''));
						new(PCheckBox,Init(ADialog,WWNDHOR,true,''));
						new(PCheckBox,Init(ADialog,WWNDVERT,true,''));
						new(PGroupBox,Init(ADialog,WWNDCOLR,'Farbe',''));
						new(pc,Init(ADialog,WWNDCCOL,''));
						new(PColButton,Init(ADialog,WWNDCOL0,id_NoExit,false,'',0,pc));
						new(PColButton,Init(ADialog,WWNDCOL1,id_NoExit,false,'',1,pc));
						new(PColButton,Init(ADialog,WWNDCOL2,id_NoExit,false,'',2,pc));
						new(PColButton,Init(ADialog,WWNDCOL3,id_NoExit,false,'',3,pc));
						new(PColButton,Init(ADialog,WWNDCOL4,id_NoExit,false,'',4,pc));
						new(PColButton,Init(ADialog,WWNDCOL5,id_NoExit,false,'',5,pc));
						new(PColButton,Init(ADialog,WWNDCOL6,id_NoExit,false,'',6,pc));
						new(PColButton,Init(ADialog,WWNDCOL7,id_NoExit,false,'',7,pc));
						new(PColButton,Init(ADialog,WWNDCOL8,id_NoExit,false,'',8,pc));
						new(PColButton,Init(ADialog,WWNDCOL9,id_NoExit,false,'',9,pc));
						new(PColButton,Init(ADialog,WWNDCOLA,id_NoExit,false,'',10,pc));
						new(PColButton,Init(ADialog,WWNDCOLB,id_NoExit,false,'',11,pc));
						new(PColButton,Init(ADialog,WWNDCOLC,id_NoExit,false,'',12,pc));
						new(PColButton,Init(ADialog,WWNDCOLD,id_NoExit,false,'',13,pc));
						new(PColButton,Init(ADialog,WWNDCOLE,id_NoExit,false,'',14,pc));
						new(PColButton,Init(ADialog,WWNDCOLF,id_NoExit,false,'',15,pc));
						new(PCheckBox,Init(ADialog,WWNDIWND,true,''));
						new(PCheckBox,Init(ADialog,WWNDRBOX,true,''));
						new(PCheckBox,Init(ADialog,WWNDDRAG,true,''));
						new(PCheckBox,Init(ADialog,WWNDQUIT,true,''));
						new(PCheckBox,Init(ADialog,WWNDBACK,true,''));
						new(PCheckBox,Init(ADialog,WWNDREDR,true,''));
						new(PCheckBox,Init(ADialog,WWNDBYTE,true,''));
						new(p,Init(ADialog,WWNDOPEN,true,''));
						p^.Disable; { ... }
						new(PButton,Init(ADialog,WWNDOK,id_OK,true,'öbernimmt die énderungen'));
						new(PButton,Init(ADialog,WWNDABBR,id_Cancel,true,'Schlieût den Dialog, ohne die énderungen zu Åbernehmen'));
						{ ... }
					end
			end;
		if ADialog<>nil then
			begin
				ADialog^.SetTitle(GetText);
				ADialog^.MakeWindow
			end
	end;


procedure TWizardApplication.InitInstance;
	var pkm: PKeyMenu;

	begin
		WizardPtr:=PWizardApplication(Application);
		InitResource(@WizardResource,nil);
		OpenPrivateProfile('WIZARD.INF');
		LoadMenu(WIZMENU);
		new(PAbout,Init(@self,K_CTRL,Ctrl_I,WMNABOUT,WMNDESK));
		pkm:=new(PNew,Init(@self,-1,-1,WMNNEW,WMNFILE));
		pkm^.Disable; { ... }
		pkm:=new(POpen,Init(@self,-1,-1,WMNOPEN,WMNFILE));
		pkm^.Disable; { ... }
		pkm:=new(PSave,Init(@self,-1,-1,WMNSAVE,WMNFILE));
		pkm^.Disable; { ... }
		pkm:=new(PSaveAs,Init(@self,-1,-1,WMNSAVAS,WMNFILE));
		pkm^.Disable; { ... }
		pkm:=new(PUndo,Init(@self,-1,-1,WMNUNDO,WMNEDIT));
		pkm^.Disable; { ... }
		pkm:=new(PNewWObj,Init(@self,-1,-1,WMNNWOBJ,WMNEDIT));
		pkm^.Disable; { ... }
		new(PGenerate,Init(@self,K_CTRL,Ctrl_G,WMNPCREA,WMNPROJC));
		new(PAppConf,Init(@self,K_CTRL,Ctrl_E,WMNPCONF,WMNPROJC));
		new(POptions,Init(@self,K_SHIFT+K_CTRL,Ctrl_E,WMNOCONF,WMNOPT));
		new(PSaveOpt,Init(@self,K_SHIFT+K_CTRL,Ctrl_S,WMNOSAVE,WMNOPT));
		with appbuffer do
			begin
				filename:='MyApp';
				objname:='MyApplication';
				entry:='GEM-Wizard MyApp';
				cookie:='????';
				rsc:=bf_Unchecked;
				incl:=bf_Checked;
				load:=bf_Unchecked;
				profile:=bf_Unchecked;
				xinp:=bf_Unchecked;
				copt:=bf_Checked;
				rem:=bf_Unchecked;
				xtxt:=bf_Unchecked;
				xkey:=bf_Unchecked;
				xgem:=bf_Unchecked;
				ximg:=bf_Unchecked;
				iwnd:=bf_Unchecked;
				rbox:=bf_Unchecked;
				timr:=bf_Unchecked;
				gdos:=bf_Unchecked;
				auto:=bf_Unchecked;
				av:=bf_Unchecked;
				drag:=bf_Unchecked
			end;
		SliceMouse;
		with optbuffer do
			begin
				pascal:=GetPrivateProfileString('Options','PPascal','PPASCAL.PRG','WIZARD.INF');
				SliceMouseNext;
				binobj:=GetPrivateProfileString('Options','Binobj','BINOBJ.TTP','WIZARD.INF');
				SliceMouseNext;
				rcs:=GetPrivateProfileString('Options','RCS','','WIZARD.INF');
				SliceMouseNext;
				realtab:=GetPrivateProfileInt('Options','RealTab',bf_Checked,'WIZARD.INF');
				SliceMouseNext;
				tabsize:=GetPrivateProfileString('Options','TabSize','2','WIZARD.INF');
				SliceMouseNext;
				xinput:=GetPrivateProfileInt('Options','XInputMode',bf_Unchecked,'WIZARD.INF');
				if xinput=bf_Checked then Attr.Style:=Attr.Style or as_XInputMode
			end;
		ArrowMouse;
		inherited InitInstance
	end;


procedure TWizardApplication.InitMainWindow;

	begin
		new(PArrangeWindow,Init(nil,'GEM-Wizard  [unbenannt]'));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
	end;


procedure TWizardApplication.GetMenuEntries(var Entries: TMenuEntries);

	begin
		with Entries do
			begin
				Quit.Entry:=WMNQUIT;
				Quit.Title:=WMNFILE;
				Close.Entry:=WMNCLOSE;
				Close.Title:=WMNFILE;
				Print.Entry:=WMNPRINT;
				Print.Title:=WMNFILE;
				Cut.Entry:=WMNCUT;
				Cut.Title:=WMNEDIT;
				Copy.Entry:=WMNCOPY;
				Copy.Title:=WMNEDIT;
				Paste.Entry:=WMNPASTE;
				Paste.Title:=WMNEDIT;
				SelectAll.Entry:=WMNSELAL;
				SelectAll.Title:=WMNEDIT
			end
	end;


procedure TArrangeWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do Style:=(Style and not(cs_QuitOnClose)) or cs_WorkBackground or cs_Rubbox
	end;


procedure TArrangeWindow.SetupWindow;

	begin
		inherited SetupWindow;
		new(WizardPtr^.AppIcon,Init(@self,WIZFREE,WICNAPP,(Work.W shr 1)-16,20,true,true,'MyApplication','Das Applikationsobjekt'));
		new(PWndIcon,Init(@self,WIZFREE,WICNWND,(Work.W shr 1)-90,90,true,true,'MyWindow','Das Hauptfenster-Objekt'))
		{ ... }
	end;


procedure TArrangeWindow.Paint(var PaintInfo: TPaintStruct);
	var pi1,pi2: PIcon;

	begin
		pi1:=FirstIcon(false);
		pi2:=NextIcon;
		if (pi1=nil) or (pi2=nil) then exit;
		vsl_ends(vdiHandle,LE_SQUARED,LE_ARROWED);
		pxya[0]:=pi2^.XPos+Work.X+34;
		pxya[1]:=pi2^.YPos+Work.Y+16;
		pxya[2]:=pi1^.XPos+Work.X+10;
		pxya[3]:=pi1^.YPos+Work.Y+40;
		v_pline(vdiHandle,2,pxya)
		{ ... }
	end;


function TAppDialog.OK: boolean;
	var valid: boolean;

	begin
		valid:=inherited OK;
		if valid then WizardPtr^.AppIcon^.SetText(WizardPtr^.appbuffer.objname); { ... }
		OK:=valid
	end;


function TOptDialog.OK: boolean;
	var valid: boolean;

	begin
		valid:=inherited OK;
		if valid then
			begin
				if WizardPtr^.optbuffer.xinput=bf_Checked then
					Application^.Attr.Style:=Application^.Attr.Style or as_XInputMode
				else
					Application^.Attr.Style:=Application^.Attr.Style and not(as_XInputMode)
			end;
		OK:=valid
	end;


procedure TAbout.Work;
	var p: PStatic;

	begin
		if ADialog=nil then
			begin
				new(ADialog,Init(nil,'öber Wizard...',WIZINFO));
				if ADialog<>nil then
					begin
						new(PStatic,Init(Adialog,WINFTITL,21,true,'"Mîge die OOP mit Euch sein!"'));
						new(p,Init(ADialog,WINFVER,28,false,''));
						if p<>nil then p^.SetText('Version '+WVERSION+' vom '+WDATE);
						new(PButton,Init(ADialog,WINFOK,id_OK,true,'Schlieût das "öber..."-Fenster.'))
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


procedure TNew.Work;

	begin
		{ ... }
	end;


procedure TOpen.Work;

	begin
		{ ... }
	end;


procedure TSave.Work;

	begin
		{ ... }
	end;


procedure TSaveAs.Work;

	begin
		{ ... }
	end;


procedure TUndo.Work;

	begin
		{ ... }
	end;


procedure TNewWObj.Work;

	begin
		{ ... }
	end;


procedure TGenerate.Work;
	var f                 : text;
	    fname,dummy,appobj: string;
	    ptw               : PTextWindow;

	function tab(cnt: integer): string;
		var q    : integer;
		    dummy: string;

		begin
			if WizardPtr^.optbuffer.realtab=bf_Checked then
				begin
					dummy:='';
					if cnt>0 then
						for q:=1 to cnt do dummy:=dummy+chr(HT);
					tab:=dummy
				end
			else
				tab:=StrPSpace(cnt*atol(WizardPtr^.optbuffer.tabsize))
		end;

	begin
		fname:=StrPUpper(WizardPtr^.appbuffer.filename)+'.PAS';
		if Exist(fname) then
			case Application^.Alert(nil,3,WAIT,'Die Datei '+fname+' existiert bereits!','&öberschreiben|&Backup|&Abbruch') of
			1: BusyMouse;
			2:
				begin
					BusyMouse;
					if Exist(GetPath(fname)+GetFilename(fname,false)+'.BAK') then
						begin
							assign(f,GetPath(fname)+GetFilename(fname,false)+'.BAK');
							erase(f)
						end;
					assign(f,fname);
					rename(f,GetPath(fname)+GetFilename(fname,false)+'.BAK')
				end
			else
				exit
			end;
		assign(f,fname);
		rewrite(f);
		if WizardPtr^.appbuffer.copt=bf_Checked then
			begin
				writeln(f,'{$IFDEF DEBUG}');
				writeln(f,tab(1),'{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z+}');
				writeln(f,'{$ELSE}');
				writeln(f,tab(1),'{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z+}');
				writeln(f,'{$ENDIF}');
				writeln(f)
			end;
		write(f,'program ',WizardPtr^.appbuffer.filename,';');
		if WizardPtr^.appbuffer.copt=bf_Checked then writeln(f)
		else
			writeln(f,' {$X+}');
		writeln(f);
		writeln(f,'uses');
		writeln(f);
		dummy:='OTypes,OWindows;';
		if WizardPtr^.appbuffer.timr=bf_Checked then dummy:='Gem,'+dummy;
		writeln(f,tab(1),dummy);
		if WizardPtr^.appbuffer.rsc=bf_Checked then
			if WizardPtr^.appbuffer.incl=bf_Checked then
				begin
					writeln(f);
					writeln(f,'const');
					writeln(f);
					writeln(f,tab(1),'{$I ',WizardPtr^.appbuffer.filename,'.i}')
				end;
		writeln(f);
		writeln(f,'type');
		writeln(f);
		appobj:='T'+WizardPtr^.appbuffer.objname;
		writeln(f,tab(1),'P',WizardPtr^.appbuffer.objname,' = ^',appobj,';');
		writeln(f,tab(1),appobj,' = object(TApplication)');
		if WizardPtr^.appbuffer.auto=bf_Checked then
			writeln(f,tab(2),'function AutoFolder: boolean; virtual;');
		if WizardPtr^.appbuffer.gdos=bf_Checked then
			writeln(f,tab(2),'procedure SetupVDI; virtual;');
		writeln(f,tab(2),'procedure InitInstance; virtual;');
		writeln(f,tab(2),'procedure InitMainWindow; virtual;');
		if WizardPtr^.appbuffer.iwnd=bf_Checked then
			writeln(f,tab(2),'procedure IconPaint(Work: GRECT; var PaintInfo: TPaintStruct); virtual;');
		if WizardPtr^.appbuffer.timr=bf_Checked then
			writeln(f,tab(2),'function GetMsTimer: longint; virtual;');
		if WizardPtr^.appbuffer.rbox=bf_Checked then
			writeln(f,tab(2),'procedure MURubbox(r: GRECT); virtual;');
		if WizardPtr^.appbuffer.xtxt=bf_Checked then
			writeln(f,tab(2),'function XAccText(OrgID: integer; pText: pointer): boolean; virtual;');
		if WizardPtr^.appbuffer.xkey=bf_Checked then
			writeln(f,tab(2),'function XAccKey(OrgID,Stat,Key: integer): boolean; virtual;');
		if WizardPtr^.appbuffer.xgem=bf_Checked then
			writeln(f,tab(2),'function XAccMeta(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean; virtual;');
		if WizardPtr^.appbuffer.ximg=bf_Checked then
			writeln(f,tab(2),'function XAccIMG(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean; virtual;');
		if WizardPtr^.appbuffer.drag=bf_Checked then
			begin
				writeln(f,tab(2),'function DDHeaderReply(dType,dName,fName: string; dSize: longint; OrgID,WindID,mX,mY,KStat: integer): byte; virtual;');
				writeln(f,tab(2),'function DDReadData(dType,dName,fName: string; dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean; virtual;');
				writeln(f,tab(2),'function DDReadArgs(dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean; virtual;');
				writeln(f,tab(2),'procedure DDFinished(OrgID,WindID,mX,mY,KStat: integer); virtual;')
			end;
		if WizardPtr^.appbuffer.av=bf_Checked then
			writeln(f,tab(2),'procedure HandleAV(Pipe: Pipearray); virtual;');
		if WizardPtr^.appbuffer.timr=bf_Checked then
			writeln(f,tab(2),'procedure HandleTimer; virtual;');
		writeln(f,tab(1),'end;');
		writeln(f);
		writeln(f,'var');
		writeln(f);
		writeln(f,tab(1),WizardPtr^.appbuffer.objname,'   : ',appobj,';');
		writeln(f,tab(1),WizardPtr^.appbuffer.objname,'Ptr: P',WizardPtr^.appbuffer.objname,';');
		writeln(f);
		writeln(f);
		writeln(f);
		if WizardPtr^.appbuffer.rsc=bf_Checked then
			if WizardPtr^.appbuffer.incl=bf_Checked then
				begin
					writeln(f,'procedure ',WizardPtr^.appbuffer.filename,'Resource; external; {$L ',WizardPtr^.appbuffer.filename,'.o}');
					writeln(f);
					writeln(f)
				end;
		if WizardPtr^.appbuffer.auto=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.AutoFolder: boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'AutoFolder:=false');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.gdos=bf_Checked then
			begin
				writeln(f,'procedure ',appobj,'.SetupVDI;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'Attr.Style:=Attr.Style or as_LoadFonts;');
				writeln(f,tab(2),'inherited SetupVDI');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		writeln(f,'procedure ',appobj,'.InitInstance;');
		writeln(f);
		writeln(f,tab(1),'begin');
		writeln(f,tab(2),WizardPtr^.appbuffer.objname,'Ptr:=P',WizardPtr^.appbuffer.objname,'(Application);');
		if WizardPtr^.appbuffer.profile=bf_Checked then
			writeln(f,tab(2),'OpenPrivateProfile(''',StrPUpper(WizardPtr^.appbuffer.filename),'.INF'');');
		if WizardPtr^.appbuffer.rsc=bf_Checked then
			begin
				if WizardPtr^.appbuffer.load=bf_Checked then writeln(f,tab(2),'LoadResource(''',StrPUpper(WizardPtr^.appbuffer.filename),'.RSC'','''');')
				else
					writeln(f,tab(2),'InitResource(@',WizardPtr^.appbuffer.filename,'Resource,'''');')
			end;
		if WizardPtr^.appbuffer.timr=bf_Checked then
			writeln(f,tab(2),'Attr.EventMask:=Attr.EventMask or MU_TIMER;');
		if (WizardPtr^.appbuffer.rbox=bf_Checked) or (WizardPtr^.appbuffer.xinp=bf_Checked) then
			begin
				if WizardPtr^.appbuffer.rbox=bf_Checked then dummy:=' or as_Rubbox'
				else
					dummy:='';
				if WizardPtr^.appbuffer.xinp=bf_Checked then dummy:=dummy+' or as_XInputMode';
				writeln(f,tab(2),'Attr.Style:=Attr.Style',dummy,';')
			end;
		writeln(f,tab(2),'inherited InitInstance');
		writeln(f,tab(1),'end;');
		writeln(f);
		writeln(f);
		writeln(f,'procedure ',appobj,'.InitMainWindow;');
		writeln(f);
		writeln(f,tab(1),'begin');
		writeln(f,tab(2),'new(PWindow,Init(nil,Name^));');
		writeln(f,tab(2),'if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow');
		writeln(f,tab(1),'end;');
		writeln(f);
		writeln(f);
		if WizardPtr^.appbuffer.iwnd=bf_Checked then
			begin
				writeln(f,'procedure ',appobj,'.IconPaint(Work: GRECT; var PaintInfo: TPaintStruct);');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.timr=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.GetMsTimer: longint;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'GetMsTimer:=1000');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.rbox=bf_Checked then
			begin
				writeln(f,'procedure ',appobj,'.MURubbox(r: GRECT);');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.xtxt=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.XAccText(OrgID: integer; pText: pointer): boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'XAccText:=false');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.xkey=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.XAccKey(OrgID,Stat,Key: integer): boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'XAccKey:=false');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.xgem=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.XAccMeta(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'XAccMeta:=false');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.ximg=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.XAccIMG(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'XAccIMG:=false');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.drag=bf_Checked then
			begin
				writeln(f,'function ',appobj,'.DDHeaderReply(dType,dName,fName: string; dSize: longint; OrgID,WindID,mX,mY,KStat: integer): byte;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'DDHeaderReply:=DD_NAK');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f);
				writeln(f,'function ',appobj,'.DDReadData(dType,dName,fName: string; dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'DDReadData:=false');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f);
				writeln(f,'function ',appobj,'.DDReadArgs(dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(2),'DDReadArgs:=false;');
				writeln(f,tab(2),'{ ... }');
				writeln(f,tab(2),'inherited DDReadArgs(dSize,PipeHnd,OrgID,WindID,mX,mY,KStat)');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f);
				writeln(f,'procedure ',appobj,'.DDFinished(OrgID,WindID,mX,mY,KStat: integer);');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.av=bf_Checked then
			begin
				writeln(f,'procedure ',appobj,'.HandleAV(Pipe: Pipearray);');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		if WizardPtr^.appbuffer.timr=bf_Checked then
			begin
				writeln(f,'procedure ',appobj,'.HandleTimer;');
				writeln(f);
				writeln(f,tab(1),'begin');
				writeln(f,tab(1),'end;');
				writeln(f);
				writeln(f)
			end;
		{ ... }
		writeln(f,'begin');
		writeln(f,tab(1),WizardPtr^.appbuffer.objname,'.Init(''',WizardPtr^.appbuffer.entry,''');');
		writeln(f,tab(1),WizardPtr^.appbuffer.objname,'.Run;');
		writeln(f,tab(1),WizardPtr^.appbuffer.objname,'.Done');
		write(f,'end.');
		close(f);
		ArrowMouse;
		new(ptw,Init(nil,fname,100,50));
		ptw^.RealTabs:=(WizardPtr^.optbuffer.realtab=bf_Checked);
		ptw^.TabSize:=atol(WizardPtr^.optbuffer.tabsize);
		ptw^.Read(fname)
	end;


procedure TAppConf.Work;

	begin
		if WizardPtr^.AppIcon<>nil then
			with WizardPtr^.AppIcon^ do
				begin
					Click:=2;
					Work
				end;
	end;


procedure TOptions.Work;
	var pc: PTabCheckBox;
	    pe: PEdit;

	begin
		if ADialog=nil then
			begin
				ADialog:=new(POptDialog,Init(nil,'Einstellungen',WIZOPT));
				if ADialog<>nil then
					begin
						new(pe,Init(ADialog,WOPTPP,64,'Gibt den kompletten Pfad (mit Dateinamen) fÅr PPASCAL.PRG an'));
						pe^.Disable; { ... }
						new(pe,Init(ADialog,WOPTBIN,64,'Gibt den Pfad incl. Datei fÅr BINOBJ.TTP an, mit dem RSC-Dateien in Objekte umgewandelt werden kînnen'));
						pe^.Disable; { ... }
						new(pe,Init(ADialog,WOPTRCS,64,'EnthÑlt den Zugriffspfad fÅr das Resource Construction Set'));
						pe^.Disable; { ... }
						new(pc,Init(ADialog,WOPTRTAB,true,'Ist dieses Feld angekreuzt, werden beim Speichern echte Tabulatoren verwendet, ansonsten die entsprechende Anzahl von Spaces'));
						new(pc^.pte,Init(ADialog,WOPTTSIZ,2,'Gibt an, wieviele Spaces pro Tabulator gespeichert werden, wenn keine echten Tabulatoren verwendet werden'));
						new(PCheckBox,Init(ADialog,WOPTXINP,true,'Mit diesem Feld kann die Eingabe auf das Fenster unter dem Mauscursor umgelenkt werden (wie unter X/Unix)'));
						{ sofort Ñndern... }
						new(PButton,Init(ADialog,WOPTOK,id_OK,true,'öbernimmt die énderungen'));
						new(PButton,Init(ADialog,WOPTABBR,id_Cancel,true,'Schlieût den Dialog, ohne die énderungen zu Åbernehmen'));
						ADialog^.TransferBuffer:=@WizardPtr^.optbuffer;
						if WizardPtr^.optbuffer.realtab=bf_Checked then pc^.pte^.Disable
						else
							pc^.pte^.Enable
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


procedure TSaveOpt.Work;

	begin
		SliceMouse;
		if WritePrivateProfileString('Options','PPascal',WizardPtr^.optbuffer.pascal,'WIZARD.INF') then
			begin
				SliceMouseNext;
				WritePrivateProfileString('Options','Binobj',WizardPtr^.optbuffer.binobj,'WIZARD.INF');
				SliceMouseNext;
				WritePrivateProfileString('Options','RCS',WizardPtr^.optbuffer.rcs,'WIZARD.INF');
				SliceMouseNext;
				WritePrivateProfileInt('Options','RealTab',WizardPtr^.optbuffer.realtab,'WIZARD.INF');
				SliceMouseNext;
				WritePrivateProfileString('Options','TabSize',WizardPtr^.optbuffer.tabsize,'WIZARD.INF');
				SliceMouseNext;
				WritePrivateProfileInt('Options','XInputMode',WizardPtr^.optbuffer.xinput,'WIZARD.INF')
			end;
		ArrowMouse
	end;


procedure TTabCheckBox.Changed(AnIndx: integer; DblClick: boolean);

	begin
		if GetCheck=bf_Checked then pte^.Disable
		else
			pte^.Enable
	end;


procedure TRscCheckBox.Changed(AnIndx: integer; DblClick: boolean);

	begin
		if GetCheck=bf_Checked then
			begin
				pr1^.Enable;
				pr2^.Enable
			end
		else
			begin
				pr1^.Disable;
				pr2^.Disable
			end
	end;


constructor TColButton.Init(AParent: PDialog; AnIndx,AnID: integer; UserDef: boolean; Hlp: string; colr: integer; objct: PControl);

	begin
		if not(inherited Init(AParent,AnIndx,AnID,UserDef,Hlp)) then fail;
		if objct=nil then fail;
		color:=colr;
		obj:=objct
	end;


procedure TColButton.Changed(AnIndx: integer; DblClick: boolean);

	begin
		obj^.ObjAddr^.ob_spec.ted_info^.te_color:=(obj^.ObjAddr^.ob_spec.ted_info^.te_color and $fff0) or color;
		obj^.Paint
	end;


begin
	Wizard.Init('GEM-Wizard');
	Wizard.Run;
	Wizard.Done
end.