program TPXTest;

uses

	OTypes,OWindows,OValidat;

{$I tpxtest.i}

type

	TTPXApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
	end;

	PTPXDialog = ^TTPXDialog;
	TTPXDialog = object(TDialog)
		function OK: boolean; virtual;
		function Cancel: boolean; virtual;
	end;

var

	TPXApplication: TTPXApplication;


procedure TPXResource; external; {$L tpxtest.o}


procedure TTPXApplication.InitInstance;

	begin
		InitResource(@TPXResource,nil);
		inherited InitInstance
	end;


procedure TTPXApplication.InitMainWindow;
	var p  : PTPXDialog;
	    pe : PEdit;
	    ppx: PPXPictureValidator;

	begin
		new(p,Init(nil,'ObjectGEM TPXTest',TPXDIAL));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
		else
			begin
				new(PButton,Init(p,TPXOK,id_OK,true,''));
				new(PButton,Init(p,TPXABBR,id_Cancel,true,''));
				new(pe,Init(p,TPXEDIT,39,''));
				pe^.SetText('');
				ppx:=new(PPXPictureValidator,Init('(*#;,##),*#;,##,{20,40,60,75,100}W,*{&[*?][@][ ]}',true));
				ppx^.Options:=ppx^.Options or voNotEmpty;
				pe^.SetValidator(ppx);
				if AppFlag then p^.MakeWindow
			end
	end;


function TTPXDialog.OK: boolean;
	var valid: boolean;

	begin
		valid:=inherited OK;
		if valid then Application^.Quit;
		OK:=valid
	end;


function TTPXDialog.Cancel: boolean;
	var valid: boolean;

	begin
		valid:=inherited Cancel;
		if valid then Application^.Quit;
		Cancel:=valid
	end;


begin
  TPXApplication.Init('TPXTest');
  TPXApplication.Run;
  TPXApplication.Done
end.