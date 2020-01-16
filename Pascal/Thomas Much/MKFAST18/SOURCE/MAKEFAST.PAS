{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

{$M 65536}

program MakeFast;

uses

	Tos,OTypes,OProcs,OWindows,ODialogs;

const

	MVER         = '1.8';
	MDATE        = '02.10.1998';
	{$I makefast.i}

	PH_FASTLOAD  = 1;
	PH_LOADALT   = 2;
	PH_MALLOCALT = 4;
	PH_MALLOCMIN = 8;

type

	PH = record
		ph_branch  : word;
		ph_tlen,
		ph_dlen,
		ph_blen,
		ph_slen,
		ph_res1,
		ph_prgflags: longint;
		ph_absflag : word
	end;

	PMFCheckBox = ^TMFCheckBox;
	TMFCheckBox = object(TCheckBox)
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
	end;

	PMFDialog  = ^TMFDialog;
	TMFDialog = object(TDialog)
		datei,pfad,
		ddfile     : string;
		cb1        : PMFCheckBox;
		cb2,cb3,cb4: PCheckBox;
		pb1,pb2    : PButton;
		pcb        : PComboBox;
		phrec      : PH;
		f          : file of PH;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetIconTitle: string; virtual;
		procedure SetupWindow; virtual;
		function ExitDlg(AnIndx: integer): boolean; virtual;
		function OK: boolean; virtual;
		function Help: boolean; virtual;
		function DDReadArgs(dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean; virtual;
		procedure DDFinished(OrgID,mX,mY,KStat: integer); virtual;
		procedure DisableAll;
		procedure Load(fname:string);
	end;

	TMFApplication = object(TApplication)
		pmf: PMFDialog;
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		procedure VAStart(OrgID: integer; Cmd: PChar); virtual;
	end;

var

	MFApplication: TMFApplication;



procedure TMFCheckBox.Changed(AnIndx: integer; DblClick: boolean);

	begin
		if GetCheck=bf_Checked then PMFDialog(Application^.MainWindow)^.pb1^.SetText('&MakeFast!')
		else
			PMFDialog(Application^.MainWindow)^.pb1^.SetText('&MakeSlow')
	end;


procedure TMFApplication.InitInstance;

	begin
		LoadResource('makefast.rsc','');
		inherited InitInstance
	end;


procedure TMFApplication.InitMainWindow;
	var st: PStatic;

	begin
		new(pmf,Init(nil,'MakeFast',MFDLG));
		if (pmf=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
		else
			begin
				new(st,Init(pmf,MFVERSION,39,false,'ObjectGEM MakeFast ist Freeware, d.h. Sie dÅrfen das Programm kostenlos kopieren und benutzen. énderungen am Programm sind nicht erlaubt!'));
				if st<>nil then st^.SetText('VERSION '+MVER+' VOM '+MDATE+' (FREEWARE!)');
				new(pmf^.cb1,Init(pmf,MFFAST,true,'Bestimmt das FastLoad-Flag. Ist es gesetzt, wird beim Programmstart nur die BSS gelîscht. Das Flag sollte bei mindestens je einem Auto-Ordner-Programm und Accessory NICHT gesetzt sein!'));
				new(pmf^.cb2,Init(pmf,MFPROG,true,'Das Programm darf in das (schnelle) TT-RAM geladen werden. Vorsicht, wenn das Programm z.B. den Bildschirmspeicher verschiebt!'));
				new(pmf^.cb3,Init(pmf,MFMEM,true,'Malloc()-Anforderungen des Programms dÅrfen aus dem TT-RAM bedient werden. Vorsicht bei Programmen, die z.B. den Bildschirmspeicher verschieben!'));
				new(pmf^.cb4,Init(pmf,MFMEMMIN,true,'Beim Laden wird nur soviel Speicher alloziert, daû Platz fÅr Text+Daten+Symbol+Bss vorhanden ist. Bei MagiC-SharedLibraries zwingend notwendig!'));
				new(pmf^.pcb,Init(pmf,MFAMOUNT,MFAMOUNTCYC,MFMINDT,MFPOPUPS,MFPMEMORY,-1,true,false,'Gibt an, wieviel TT-RAM (Alternate RAM) dem Programm genÅgt, wenn mehr ST-RAM als TT-RAM vorhanden ist.'));
				new(pmf^.pb1,Init(pmf,MFMAKE,id_No,true,'Schreibt die neuen Werte in das ausgewÑhlte Programm.'));
				new(pmf^.pb2,Init(pmf,MFNAME,id_No,false,'Zeigt den Namen des Programms an. Durch Anklicken erhÑlt man den vollen Namen incl. Pfad.'));
				new(PButton,Init(pmf,MFDATEI,id_No,true,'WÑhlt ein neues Programm zum Bearbeiten aus.'));
				new(PButton,Init(pmf,MFHELP,id_Help,false,'Zeigt einen allg. Hilfstext an.'));
				new(PButton,Init(pmf,MFOK,id_OK,true,'VerlÑût MakeFast.'));
				pmf^.DisableAll;
				if AppFlag then pmf^.MakeWindow;
				if ParamCount>0 then pmf^.Load(ParamStr(1))
			end
	end;


procedure TMFApplication.VAStart(OrgID: integer; Cmd: PChar);

	begin
		inherited VAStart(OrgID,Cmd);
		if Cmd<>nil then pmf^.Load(GetQuotedName(Cmd))
	end;


procedure TMFDialog.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do Style:=Style or cs_CreateOnAccOpen
	end;


function TMFDialog.GetIconTitle: string;

	begin
		GetIconTitle:='MAKEFAST'
	end;


procedure TMFDialog.SetupWindow;

	begin
		inherited SetupWindow;
		LoadIcon(new(PIcon,Init(@self,MFICONS,MFIFAST,0,0,false,false,'','')));
		datei:='';
		pfad:=''
	end;


function TMFDialog.ExitDlg(AnIndx: integer): boolean;
	var path,fname: string;
	    ttmem     : integer;

	begin
		case AnIndx of
		MFNAME:
			Application^.Alert(@self,1,NO_ICON,'Datei:|"'+pfad+datei+'"','  &OK  ');
		MFDATEI:
			begin
				path:=pfad;
				fname:=datei;
				if FileSelect(@self,'PRG,ACC,TOS,SLB ETC. AUSWéHLEN','',path,fname,true) then Load(path+fname)
			end;
		MFMAKE:
			begin
				with phrec do
					begin
						ph_prgflags:=ph_prgflags and $0ffffff8;
						if cb1^.GetCheck=bf_Checked then
							ph_prgflags:=ph_prgflags or PH_FASTLOAD;
						if cb2^.GetCheck=bf_Checked then
							ph_prgflags:=ph_prgflags or PH_LOADALT;
						if cb3^.GetCheck=bf_Checked then
							ph_prgflags:=ph_prgflags or PH_MALLOCALT;
						if cb4^.GetCheck=bf_Checked then
							ph_prgflags:=ph_prgflags or PH_MALLOCMIN;
						if pcb<>nil then ttmem:=Max(pcb^.GetSelection,0)
						else
							ttmem:=0;
						PByte(@ph_prgflags)^:=PByte(@ph_prgflags)^ or (ttmem shl 4)
					end;
				reset(f);
				write(f,phrec);
				close(f);
				DisableAll
			end
		end;
		ExitDlg:=false
	end;


function TMFDialog.OK: boolean;

	begin
		Application^.Quit;
		OK:=true
	end;


function TMFDialog.Help: boolean;

	begin
		Application^.Alert(@self,1,NOTE,'Bringen Sie den Mauscursor Åber das gewÅnschte Dialogelement und drÅcken Sie die rechte Maustaste.','  &OK  ');
		Help:=false
	end;


function TMFDialog.DDReadArgs(dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean;
	var dummy: string;
	    zch  : char;

	begin
		DDReadArgs:=false;
		dummy:='';
		while (dSize>0) and (length(dummy)<255) do
			begin
				if fread(PipeHnd,1,@zch)<>1 then exit;
				dec(dSize);
				if zch=' ' then break
				else
					dummy:=dummy+zch
			end;
		inherited DDReadArgs(dSize,PipeHnd,OrgID,mX,mY,KStat);
		ddfile:=dummy;
		DDReadArgs:=true
	end;


procedure TMFDialog.DDFinished(OrgID,mX,mY,KStat: integer);

	begin
		Load(ddfile)
	end;


procedure TMFDialog.DisableAll;

	begin
		pb1^.Disable;
		pb2^.SetText('');
		pb2^.Disable;
		cb1^.Disable;
		cb2^.Disable;
		cb3^.Disable;
		cb4^.Disable;
		pcb^.Disable;
		SetDefaultButton(MFDATEI)
	end;


procedure TMFDialog.Load(fname: string);
	var cmp: string[4];

	begin
		cmp:=StrPUpper(StrPRight(fname,4));
		if (cmp<>'.PRG') and (cmp<>'.APP') and (cmp<>'.TOS') and (cmp<>'.TTP') and
		   (cmp<>'.ACC') and (cmp<>'.GTP') and (cmp<>'.ACX') and (cmp<>'.PRX') and
		   (cmp<>'.APX') and (cmp<>'.SLB') then
			if Application^.Alert(@self,WAIT,2,' Sind Sie sicher, daû| "'+fname+'"| ein ausfÅhrbares Programm ist?','&Ja| &Nein ')<>1 then exit;
		BusyMouse;
		pfad:=GetPath(fname);
		datei:=StrPRight(fname,length(fname)-length(pfad));
		pb2^.Enable;
		pb2^.SetText('Date&i: '+CompressPath(fname,25));
		assign(f,pfad+datei);
		reset(f);
		read(f,phrec);
		close(f);
		pcb^.Enable;
		pcb^.SetSelection(PByte(@phrec.ph_prgflags)^ shr 4,false);
		cb1^.Enable;
		if bTst(phrec.ph_prgflags,PH_FASTLOAD) then
			begin
				cb1^.Check;
				pb1^.SetText('&MakeFast!')
			end
		else
			begin
				cb1^.Uncheck;
				pb1^.SetText('&MakeSlow')
			end;
		cb2^.Enable;
		if bTst(phrec.ph_prgflags,PH_LOADALT) then cb2^.Check
		else
			cb2^.Uncheck;
		cb3^.Enable;
		if bTst(phrec.ph_prgflags,PH_MALLOCALT) then cb3^.Check
		else
			cb3^.Uncheck;
		cb4^.Enable;
		if bTst(phrec.ph_prgflags,PH_MALLOCMIN) then cb4^.Check
		else
			cb4^.Uncheck;
		pb1^.Enable;
		SetDefaultButton(MFMAKE);
		ArrowMouse
	end;


begin
  MFApplication.Init('MakeFast');
  MFApplication.Run;
  MFApplication.Done
end.