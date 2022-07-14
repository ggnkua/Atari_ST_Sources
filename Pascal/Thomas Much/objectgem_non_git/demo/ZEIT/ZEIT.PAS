{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z+}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z+}
{$ENDIF}

program Zeit;

uses

	Tos,Gem,OTypes,OProcs,OWindows;

const

	{$I zeit.i}

type

	PZeitApplication = ^TZeitApplication;
	TZeitApplication = object(TApplication)
		icn1,icn2: PControl;
		edt      : PEdit;
		oldtime  : string;
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		procedure HandleTimer; virtual;
	end;

	PZeitDialog = ^TZeitDialog;
	TZeitDialog = object(TDialog)
		edz,edd: PEdit;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetStyle: integer; virtual;
		function OK: boolean; virtual;
		function Cancel: boolean; virtual;
		function Help: boolean; virtual;
	end;

var

	ZeitApplication: TZeitApplication;


procedure ZeitResource; external; {$L zeit.o}


procedure TZeitApplication.InitInstance;

	begin
		InitResource(@ZeitResource,nil);
		Attr.EventMask:=Attr.EventMask or MU_TIMER;
		inherited InitInstance
	end;


procedure TZeitApplication.InitMainWindow;
	var p   : PZeitDialog;
	    wert: word;

	begin
		new(p,Init(nil,'Zeit+Datum',DIALOG));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
		else
			begin
				new(PButton,Init(p,OK,id_OK,true,'Setzt die neue Zeit und das Datum'));
				new(PButton,Init(p,ABBRUCH,id_Cancel,true,'Bricht den Dialog ab, ohne die neuen Werte zu setzen'));
				new(PButton,Init(p,HILFE,id_Help,true,'Zeigt einen Hilfstext an'));
				new(p^.edz,Init(p,EDZEIT,7,'In diesem Feld wird die Zeit im Format mm:hh:ss angegeben. Die Sekunden brauchen nicht angegeben zu werden, es wird'
				                            +' dann 00 verwendet. Die Zeit wird so lange automatisch aktualisiert, bis der Text vom Benutzer verÑndert wird.'));
				new(p^.edd,Init(p,EDDATUM,9,'In diesem Feld wird das Datum im Format tt:mm:jj bzw. tt:mm:jjjj eingegeben'));
				edt:=p^.edz;
				new(icn1,Init(p,ICON1,'ObjectGEM "Zeit+Datum"|geschrieben von Thomas Much|Version 04.10.1994'));
				new(icn2,Init(p,ICON2,'ObjectGEM "Zeit+Datum"|geschrieben von Thomas Much|Version 04.10.1994'));
				wert:=tgetdate and $001f;
				if wert<10 then oldtime:='0' else oldtime:='';
				oldtime:=oldtime+ltoa(wert);
				wert:=(tgetdate and $01e0) shr 5;
				if wert<10 then oldtime:=oldtime+'0';
				p^.edd^.SetText(oldtime+ltoa(wert)+ltoa((tgetdate shr 9)+1980));
				wert:=tgettime shr 11;
				if wert<10 then oldtime:='0' else oldtime:='';
				oldtime:=oldtime+ltoa(wert);
				wert:=(tgettime and $07e0) shr 5;
				if wert<10 then oldtime:=oldtime+'0';
				oldtime:=oldtime+ltoa(wert);
				wert:=(tgettime and $001f) shl 1;
				if wert<10 then oldtime:=oldtime+'0';
				oldtime:=oldtime+ltoa(wert);
				edt^.SetText(oldtime);
				icn2^.Hide(true);
				icn1^.Unhide;
				if AppFlag then p^.MakeWindow
			end
	end;


procedure TZeitApplication.HandleTimer;
	var wert   : word;
	    newtime: string;

	begin
		if edt^.GetText=oldtime then
			begin
				wert:=tgettime shr 11;
				if wert<10 then newtime:='0' else newtime:='';
				newtime:=newtime+ltoa(wert);
				wert:=(tgettime and $07e0) shr 5;
				if wert<10 then newtime:=newtime+'0';
				newtime:=newtime+ltoa(wert);
				wert:=(tgettime and $001f) shl 1;
				if wert<10 then newtime:=newtime+'0';
				newtime:=newtime+ltoa(wert);
				if oldtime<>newtime then edt^.SetText(newtime);
				oldtime:=newtime
			end;
		if icn1^.IsHidden then
			begin
				if Attr.Colors>2 then
					icn1^.SetColor((icn2^.GetColor+1) mod Min(16,Attr.Colors));
				icn2^.Hide(true);
				icn1^.Unhide
			end
		else
			begin
				if Attr.Colors>2 then
					icn2^.SetColor((icn1^.GetColor+1) mod Min(16,Attr.Colors));
				icn1^.Hide(true);
				icn2^.Unhide
			end
	end;


procedure TZeitDialog.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do Style:=Style or cs_CreateOnAccOpen
	end;


function TZeitDialog.GetStyle: integer;

	begin
		GetStyle:=inherited GetStyle or SIZER or FULLER
	end;


function TZeitDialog.OK: boolean;
	var valid   : boolean;
	    td      : string;
	    hr,mn,sk,
	    tg,mo,jr: word;

	begin
		valid:=inherited OK;
		hr:=0; { damit der Compiler nicht meckert... }
		mn:=0;
		sk:=0;
		tg:=0;
		mo:=0;
		jr:=0;
		if valid then
			begin
				td:=edz^.GetText;
				if (length(td)<>4) and (length(td)<>6) then valid:=false
				else
					begin
						if length(td)=4 then td:=td+'00';
						hr:=atol(StrPLeft(td,2));
						mn:=atol(System.copy(td,3,2));
						sk:=atol(StrPRight(td,2));
						valid:=Between(hr,0,23) and Between(mn,0,59) and Between(sk,0,59)
					end;
				if not(valid) then Application^.Alert(@self,1,STOP,'Bitte geben Sie eine korrekte Zeit ein!','  &OK  ')
			end;
		if valid then
			begin
				td:=edd^.GetText;
				if (length(td)<>6) and (length(td)<>8) then valid:=false
				else
					begin
						if length(td)=6 then td:=StrPLeft(td,4)+'19'+StrPRight(td,2);
						jr:=atol(StrPRight(td,4));
						mo:=atol(System.copy(td,3,2));
						tg:=atol(StrPLeft(td,2));
						valid:=Between(jr,1980,2099) and Between(mo,1,12) and Between(tg,1,31)
					end;
				if not(valid) then Application^.Alert(@self,1,STOP,'Bitte geben Sie ein korrektes Datum ein!','  &OK  ')
			end;
		if valid then
			begin
				tsettime((hr shl 11) or (mn shl 5) or (sk shr 1));
				tsetdate(((jr-1980) shl 9) or (mo shl 5) or tg);
				Application^.Quit
			end;
		OK:=valid
	end;


function TZeitDialog.Cancel: boolean;
	var valid: boolean;

	begin
		valid:=inherited Cancel;
		if valid then Application^.Quit;
		Cancel:=valid
	end;


function TZeitDialog.Help: boolean;

	begin
		Application^.Alert(@self,1,NOTE,'Bringen Sie den Mauscursor auf das Dialogelement, fÅr das Sie Hilfe benîtigen. DrÅcken Sie dann die <Help>- oder die rechte Maus-Taste.','  &OK  ');
		Help:=false
	end;


begin
  { if ((tgetdate shr 9)>=14) and AppFlag then halt; ... }
  ZeitApplication.Init('Zeit+Datum');
  ZeitApplication.Run;
  ZeitApplication.Done
end.