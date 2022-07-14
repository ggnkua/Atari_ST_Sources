{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z+}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z+}
{$ENDIF}

program ClipView; { 09.10.1994 }

uses

	Gem,OTypes,OProcs,OWindows,OStdWnds;

type

	PCVApplication = ^TCVApplication;
	TCVApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		procedure SCChanged(OrgID: integer; Bits: word; Ext: string); virtual;
	end;

	PViewWindow = ^TViewWindow;
	TViewWindow = object(TTextWindow)
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetStyle: integer; virtual;
		procedure UpdateSubTitle; virtual;
	end;

var

	CVApplication   : TCVApplication;
	CVApplicationPtr: PCVApplication;



procedure TCVApplication.InitInstance;

	begin
		CVApplicationPtr:=PCVApplication(Application);
		inherited InitInstance
	end;


procedure TCVApplication.InitMainWindow;
	var p  : PViewWindow;
	    ext: string;

	begin
		new(p,Init(nil,Name^,100,50));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow;
		p^.SetSubTitle(' Keine Textdatei im Klemmbrett vorhanden.');
		if Clipboard=nil then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(false)) then exit;
				ext:=GetPriorityClipboardFormat('TXT.ASC.RTF.TEX.CSV.EPS');
				if length(ext)>0 then
					begin
						p^.Read(GetClipboardFilename+ext);
						p^.SetSubTitle(' '+GetClipboardFilename+ext+'  ('+ltoa(p^.GetNumLines)+' Zeile(n))')
					end;
				CloseClipboard
			end
	end;


procedure TCVApplication.SCChanged(OrgID: integer; Bits: word; Ext: string);
	var ret: string;

	begin
		MainWindow^.SetSubTitle(' Keine Textdatei im Klemmbrett vorhanden.');
		if Clipboard=nil then exit;
		if not(bTst(Bits,SCF_TEXT)) then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(false)) then exit;
				ret:=GetPriorityClipboardFormat('TXT.ASC.RTF.TEX');
				if length(ret)>0 then
					begin
						PViewWindow(MainWindow)^.Clear;
						PViewWindow(MainWindow)^.Read(GetClipboardFilename+ret);
						MainWindow^.SetSubTitle(' '+GetClipboardFilename+ret+'  ('+ltoa(PViewWindow(MainWindow)^.GetNumLines)+' Zeile(n))')
					end;
				CloseClipboard
			end
	end;


procedure TViewWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do Style:=Style or cs_QuitOnClose
	end;


function TViewWindow.GetStyle: integer;

	begin
		GetStyle:=inherited GetStyle or INFO
	end;


procedure TViewWindow.UpdateSubTitle;

	begin
	end;


begin
	CVApplication.Init('ClipView');
	CVApplication.Run;
	CVApplication.Done
end.