{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z+}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z+}
{$ENDIF}

program MyApp;

uses

	OTypes,OWindows;

type

	PMyApplication = ^TMyApplication;
	TMyApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
	end;

var

	MyApplication   : TMyApplication;
	MyApplicationPtr: PMyApplication;



procedure TMyApplication.InitInstance;

	begin
		MyApplicationPtr:=PMyApplication(Application);
		inherited InitInstance
	end;


procedure TMyApplication.InitMainWindow;

	begin
		new(PWindow,Init(nil,Name^));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
	end;


begin
	MyApplication.Init('GEM-Wizard MyApp');
	MyApplication.Run;
	MyApplication.Done
end.