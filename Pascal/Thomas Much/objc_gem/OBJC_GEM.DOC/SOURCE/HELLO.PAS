program Hello;
	{ this is a complete GEM application, which opens a
	  window to print the 'Hello world' message; things
	  like iconifications are supported automatically   }

uses

	Gem,OTypes,OWindows;

type

	TMyApplication = object(TApplication)
		procedure InitMainWindow; virtual;
	end;

	PMyWindow = ^TMyWindow;
	TMyWindow = object(TWindow)
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
	end;

var

	MyApplication: TMyApplication;


procedure TMyApplication.InitMainWindow;

	begin
		new(PMyWindow,Init(nil,''));
		if (MainWindow=nil) or (ChkError<em_OK) then
			Status:=em_InvalidMainWindow
	end;


procedure TMyWindow.Paint(var PaintInfo: TPaintStruct);

	begin
		v_gtext(vdiHandle,Work.X+Attr.charWidth,Work.Y+Attr.boxHeight,
		                               'Hello, ObjectGEM-world...')
		{ this method uses the rectangle list _automatically_ }
	end;


begin
  MyApplication.Init('Hello world');
  MyApplication.Run;
  MyApplication.Done
end.