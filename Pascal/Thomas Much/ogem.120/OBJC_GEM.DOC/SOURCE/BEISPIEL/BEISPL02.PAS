program Beispiel; {$X+} { Beispiel Nr.2 }

uses

	Gem,OTypes,OProcs,OWindows;

type

	TMyApplication = object(TApplication)
		procedure InitMainWindow; virtual;
	end;

	PBeispielWindow = ^TBeispielWindow;
	TBeispielWindow = object(TWindow)
		Veraendert: boolean;
		constructor Init(AParent: PWindow; ATitle: string);
		function CanClose: boolean; virtual;
		procedure WMButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
	end;

var

	MyApp: TMyApplication;


procedure TMyApplication.InitMainWindow;

	begin
		new(PBeispielWindow,Init(nil,'ObjectGEM-Beispielprogramm'));
		if (MainWindow=nil) or (ChkError<em_OK) then
			Status:=em_InvalidMainWindow
	end;


constructor TBeispielWindow.Init(AParent: PWindow; ATitle: string);

	begin
		if not(inherited Init(AParent,ATitle)) then fail;
		Veraendert:=false
	end;


function TBeispielWindow.CanClose: boolean;
	var valid: boolean;

	begin
		valid:=inherited CanClose;
		if valid and Veraendert then
			valid:=(Application^.Alert(@self,1,WAIT,
				' Die Grafik wurde ver„ndert!| Wollen Sie sie speichern?',
			  '&Ja|  &Nein  ')=2);
		CanClose:=valid
	end;


procedure TBeispielWindow.WMButton(mX,mY,BStat,KStat,Clicks: integer);

	begin
		if bTst(BStat,1) then
			if GetDC>=0 then
				begin
					v_gtext(vdiHandle,mX,mY,'('+ltoa(mX)+','+ltoa(mY)+')');
					ReleaseDC;
					Veraendert:=true
				end;
		if bTst(BStat,2) then
			begin
				ForceRedraw;
				Veraendert:=false
			end
	end;


begin
	MyApp.Init('Beispiel');
	MyApp.Run;
	MyApp.Done
end.