{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

program MakeFast;
  { Copyright (c)1994 by Softdesign Computer Software
                               written by Thomas Much }
  { wer sich eingehender mit den FastLoad-Flags beschÑftigen
    mîchte, sollte sich einmal das ST-STE-TT-Profibuch ansehen! }

uses

	Tos,OTypes,OProcs,OWindows,ODialogs;

const

	MVER         = '1.6';
	MDATE        = '09.10.1994';
	{$I makefast.i}

	PH_FASTLOAD  = 1;
	PH_LOADALT   = 2;
	PH_MALLOCALT = 4;

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

	TMFApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
	end;

	PMFDialog  = ^TMFDialog;
	TMFDialog = object(TDialog)
		ttmem          : integer;
		datei,pfad,
		ddfile         : string;
		st1,st2,st3    : PStatic;
		cb1            : PMFCheckBox;
		cb2,cb3        : PCheckBox;
		pb1,pb2,pb3,pb4,
		pb5,pb6,pb7,pb8: PButton;
		phrec          : PH;
		f              : file of PH;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetIconTitle: string; virtual;
		procedure SetupWindow; virtual;
		function ExitDlg(AnIndx: integer): boolean; virtual;
		function OK: boolean; virtual;
		function Help: boolean; virtual;
		function DDReadArgs(dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean; virtual;
		procedure DDFinished(OrgID,mX,mY,KStat: integer); virtual;
		procedure UpdateAmount;
		procedure DisableAll;
		procedure Load(fname:string);
	end;

var

	MFApplication: TMFApplication;


procedure MFResource; external; {$L makefast.o}


procedure TMFCheckBox.Changed(AnIndx: integer; DblClick: boolean);

	begin
		if GetCheck=bf_Checked then PMFDialog(Application^.MainWindow)^.pb2^.SetText('&MakeFast!')
		else
			PMFDialog(Application^.MainWindow)^.pb2^.SetText('&MakeSlow')
	end;


procedure TMFApplication.InitInstance;

	begin
		InitResource(@MFResource,nil);
		inherited InitInstance
	end;


procedure TMFApplication.InitMainWindow;
	var p: PMFDialog;

	begin
		new(p,Init(nil,'ObjectGEM MakeFast',MFDLG));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
		else
			begin
				new(p^.st1,Init(p,MFMINDT,0,false,'Gibt an, wieviel TT-RAM (Alternate RAM) dem Programm genÅgt, wenn mehr ST-RAM als TT-RAM vorhanden ist.'));
				new(p^.st2,Init(p,MFAMOUNT,8,false,'Gibt an, wieviel TT-RAM (Alternate RAM) dem Programm genÅgt, wenn mehr ST-RAM als TT-RAM vorhanden ist.'));
				p^.st2^.Style:=p^.st2^.Style and not(sts_Fill);
				new(p^.st3,Init(p,MFVER,39,false,'ObjectGEM MakeFast ist Freeware, d.h. Sie dÅrfen das Programm kostenlos kopieren und benutzen. énderungen am Programm sind nicht erlaubt!'));
				new(p^.cb1,Init(p,MFFAST,true,'Bestimmt das FastLoad-Flag. Ist es gesetzt, wird beim Programmstart nur die BSS gelîscht. Das Flag sollte bei mindestens je einem Auto-Ordner-Programm und Accessory NICHT gesetzt sein!'));
				new(p^.cb2,Init(p,MFPROG,true,'Das Programm darf in das (schnelle) TT-RAM geladen werden. Vorsicht, wenn das Programm z.B. den Bildschirmspeicher verschiebt!'));
				new(p^.cb3,Init(p,MFMEM,true,'Malloc()-Anforderungen des Programms dÅrfen aus dem TT-RAM bedient werden. Vorsicht bei Programmen, die z.B. den Bildschirmspeicher verschieben!'));
				new(p^.pb1,Init(p,MFDATEI,id_No,true,'WÑhlt ein neues Programm zum Bearbeiten aus.'));
				new(p^.pb2,Init(p,MFMAKE,id_No,true,'Schreibt die neuen Werte in das ausgewÑhlte Programm.'));
				new(p^.pb3,Init(p,MFOK,id_OK,true,'VerlÑût MakeFast.'));
				new(p^.pb4,Init(p,MFLESS,id_No,false,'Vermindert den TT-RAM-Bedarf um 128 KB.'));
				new(p^.pb5,Init(p,MFMORE,id_No,false,'Erhîht den TT-RAM-Bedarf um 128 KB.'));
				new(p^.pb6,Init(p,MFHELP,id_Help,false,'Zeigt einen allg. Hilfstext an.'));
				new(p^.pb7,Init(p,MFNAME,id_No,false,'Zeigt den Namen des Programms an. Durch Anklicken erhÑlt man den vollen Namen incl. Pfad.'));
				new(p^.pb8,Init(p,MFMINT,id_NoExit,true,'éndert unter MiNT/MultiTOS die Memory-Protection-Flags. Z.Z. noch ohne Wirkung.'));
				{if not(Application^.MiNTActive) then...} p^.pb8^.Disable;
				p^.st3^.SetText('VERSION '+MVER+' VOM '+MDATE+' (FREEWARE!)');
				p^.UpdateAmount;
				p^.DisableAll;
				if AppFlag then p^.MakeWindow
			end
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
		LoadIcon(new(PIcon,Init(@self,MFIcon,MFIFAST,0,0,false,false,'','')));
		ttmem:=0;
		datei:='';
		pfad:=''
	end;


function TMFDialog.ExitDlg(AnIndx: integer): boolean;
	var path,fname: string;

	begin
		case AnIndx of
			MFNAME: Application^.Alert(@self,1,NO_ICON,'Datei:|"'+pfad+datei+'"','  &OK  ');
			MFLESS: if ttmem>0 then
								begin
									dec(ttmem);
									UpdateAmount
								end;
			MFMORE: if ttmem<15 then
								begin
									inc(ttmem);
									UpdateAmount
								end;
			MFDATEI: begin
			           path:=pfad;
			           fname:=datei;
							   if FileSelect(@self,'PRG,ACC,TOS ETC. AUSWéHLEN','',path,fname,true) then Load(path+fname)
							 end;
			MFMAKE: begin
								with phrec do
									begin
										ph_prgflags:=ph_prgflags and $0ffffff8;
										if cb1^.GetCheck=bf_Checked then
											ph_prgflags:=ph_prgflags or PH_FASTLOAD;
										if cb2^.GetCheck=bf_Checked then
											ph_prgflags:=ph_prgflags or PH_LOADALT;
										if cb3^.GetCheck=bf_Checked then
											ph_prgflags:=ph_prgflags or PH_MALLOCALT;
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
		Application^.Alert(@self,1,NOTE,'Bringen Sie den Mauscursor Åber das gewÅnschte Dialogelement und drÅcken Sie die <Help>-Taste (oder die rechte Maustaste...).','  &OK  ');
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


procedure TMFDialog.UpdateAmount;
	const atxt : array [0..15] of string[7] =
							('128 KB','256 KB','384 KB','512 KB','640 KB','768 KB',
							 '896 KB','1 MB','1152 KB','1280 KB','1408 KB','1536 KB',
							 '1664 KB','1792 KB','1920 KB','2 MB');

	begin
		st2^.SetText(atxt[ttmem])
	end;


procedure TMFDialog.DisableAll;

	begin
		pb7^.SetText('');
		pb7^.Disable;
		st1^.Disable;
		st2^.Disable;
		cb1^.Disable;
		cb2^.Disable;
		cb3^.Disable;
		pb2^.Disable;
		pb4^.Disable;
		pb5^.Disable;
		SetDefaultButton(MFDATEI)
	end;


procedure TMFDialog.Load(fname: string);
	var cmp: string[4];

	begin
		cmp:=StrPRight(fname,4);
		if (cmp<>'.PRG') and (cmp<>'.APP') and (cmp<>'.TOS') and (cmp<>'.TTP') and (cmp<>'.ACC') and (cmp<>'.GTP') and (cmp<>'.ACX') and (cmp<>'.PRX') then
			if Application^.Alert(@self,WAIT,2,' Sind Sie sicher, daû| "'+fname+'"| ein ausfÅhrbares Programm ist?','&Ja| &Nein ')<>1 then exit;
		BusyMouse;
		pfad:=GetPath(fname);
		datei:=StrPRight(fname,length(fname)-length(pfad));
		pb7^.Enable;
		pb7^.SetText('Date&i: '+datei);
		assign(f,pfad+datei);
		reset(f);
		read(f,phrec);
		close(f);
		ttmem:=PByte(@phrec.ph_prgflags)^ shr 4;
		st1^.Enable;
		st2^.Enable;
		UpdateAmount;
		cb1^.Enable;
		if bTst(phrec.ph_prgflags,PH_FASTLOAD) then
			begin
				cb1^.Check;
				pb2^.SetText('&MakeFast!')
			end
		else
			begin
				cb1^.Uncheck;
				pb2^.SetText('&MakeSlow')
			end;
		cb2^.Enable;
		if bTst(phrec.ph_prgflags,PH_LOADALT) then cb2^.Check
		else
			cb2^.Uncheck;
		cb3^.Enable;
		if bTst(phrec.ph_prgflags,PH_MALLOCALT) then cb3^.Check
		else
			cb3^.Uncheck;
		pb2^.Enable;
		pb4^.Enable;
		pb5^.Enable;
		SetDefaultButton(MFMAKE);
		ArrowMouse
	end;


begin
  MFApplication.Init('MakeFast');
  MFApplication.Run;
  MFApplication.Done
end.