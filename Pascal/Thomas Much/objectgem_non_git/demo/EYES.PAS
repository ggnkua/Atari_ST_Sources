program ObjectGEMEyes; {$X+} {$E .ACC }

uses

	Gem,OTypes,OWindows;

type

	TMyApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		function GetMsTimer: longint; virtual;
		procedure MUTimer(data: TEventData); virtual;
		procedure ACOpen(mID: integer); virtual;
		function ACClose(mID,Why: integer): integer; virtual;
	end;

	PMyWindow = ^TMyWindow;
	TMyWindow = object(TWindow)
		oldx,
		oldy,
		pmx,
		pmy     : integer;
		paintall: boolean;
		function GetStyle: integer; virtual;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		procedure SetupSize; virtual;
		procedure SetupWindow; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		{ neue Routinen }
		procedure TimerRedraw(x,y: integer); virtual;
	end;

	PSpace = ^TSpace;
	TSpace = object(TKey)
		procedure Work; virtual;
	end;


var

	MyApplication: TMyApplication;



procedure TMyApplication.InitInstance;

	begin
		Attr.EventMask:=MU_MESAG;
		if AppFlag then Attr.EventMask:=Attr.EventMask or MU_TIMER or MU_KEYBD;
		vsl_color(vdiHandle,LBlack);
		vsf_perimeter(vdiHandle,PER_OFF);
		vsf_interior(vdiHandle,FIS_SOLID);
		vsf_color(vdiHandle,White);
		inherited InitInstance
	end;


procedure TMyApplication.InitMainWindow;

	begin
		new(PMyWindow,Init(nil,'Eyes'));
		if (MainWindow=nil) then Status:=em_InvalidMainWindow
	end;


function TMyApplication.GetMsTimer: longint;

	begin
		GetMsTimer:=100
	end;


procedure TMyApplication.MUTimer(data: TEventData);
	var p: PMyWindow;

	begin
		p:=PMyWindow(MainWindow);
		if (data.mX<>p^.oldx) or (data.mY<>p^.oldy) then
			begin
				wind_update(BEG_UPDATE);
				p^.TimerRedraw(data.mX,data.mY);
				wind_update(END_UPDATE)
			end
	end;


procedure TMyApplication.ACOpen(mID: integer);

	begin
		inherited ACOpen(mID);
		if mID=menuID then
			if ChkError>=em_OK then Attr.EventMask:=Attr.EventMask or MU_TIMER or MU_KEYBD
	end;


function TMyApplication.ACClose(mID,Why: integer): integer;

	begin
		if mID=menuID then Attr.EventMask:=Attr.EventMask and (not(MU_TIMER or MU_KEYBD));
		ACClose:=inherited ACClose(mID,Why)
	end;


function TMyWindow.GetStyle: integer;

	begin
		GetStyle:=NAME or CLOSER or FULLER or MOVER or SIZER
	end;


procedure TMyWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do
			begin
				Style:=Style or cs_FullRedraw or cs_WorkBackground;
				hbrBackground:=0
			end
	end;


procedure TMyWindow.SetupSize;

	begin
		inherited SetupSize;
		with Work do
			begin
				X:=100;
				Y:=100;
				W:=100;
				H:=80
			end;
		Calc(WC_BORDER,Work,Curr)
	end;


procedure TMyWindow.SetupWindow;

	begin
		paintall:=true;
		oldx:=-1;
		oldy:=-1;
		pmx:=0;
		pmy:=0;
		new(PSpace,Init(@self,0,14624,nil,false));
		inherited SetupWindow
	end;


procedure TMyWindow.Paint(var PaintInfo: TPaintStruct);
	var lr,ou,breite,hoehe: integer;

	procedure pupil(mx,my,x,y: integer);
		var xx,yy,zz,f,ff: real;

		begin
			xx:=mx-(Work.X+x);
			yy:=my-(Work.Y+y);
			zz:=sqrt(sqr(xx)+sqr(yy));
			if zz<>0 then
				begin
					f:=(Work.W/11.12)*xx/zz;
					ff:=(Work.H/4.22)*yy/zz
				end
			else
				begin
					f:=0;
					ff:=0
				end;
			v_ellipse(vdiHandle,Work.X+x+trunc(f),Work.Y+y+trunc(ff),
			                                Work.W div 10,Work.H div 8)
		end;

	begin
		lr:=Work.W shr 2;
		ou:=Work.H shr 1;
		breite:=Work.W div 5;
		hoehe:=ou-(Work.H div 16);
		if paintall then
			begin
				vr_recfl(vdiHandle,PaintInfo.rcPaint.A2);
				vsf_color(vdiHandle,Black);
				vsf_perimeter(vdiHandle,PER_ON);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				v_ellipse(vdiHandle,Work.X+lr,Work.Y+ou,breite,hoehe);
				v_ellipse(vdiHandle,Work.X+Work.W-lr,Work.Y+ou,breite,hoehe);
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_perimeter(vdiHandle,PER_OFF)
			end
		else
			begin
				pupil(oldx,oldy,lr,ou);
				pupil(oldx,oldy,Work.W-lr,ou)
			end;
		vsf_color(vdiHandle,Blue);
		pupil(pmx,pmy,lr,ou);
		pupil(pmx,pmy,Work.W-lr,ou);
		vsf_color(vdiHandle,White)
	end;


procedure TMyWindow.TimerRedraw(x,y: integer);

	begin
		pmx:=x;
		pmy:=y;
		paintall:=false;
		HideMouse;
		WMRedraw(Work.X,Work.Y,Work.W,Work.H);
		ShowMouse;
		oldx:=pmx;
		oldy:=pmy;
		paintall:=true
	end;


procedure TSpace.Work;
	var rect: GRECT;
	    p   : PWindow;

	begin
		p:=PWindow(Parent);
		with p^ do
			begin
				Work.W:=100;
				Work.H:=80;
				Calc(WC_BORDER,Work,rect);
				WMSized(rect.X,rect.Y,rect.W,rect.H)
			end
	end;


begin
	MyApplication.Init('ObjectGEM Eyes');
	MyApplication.Run;
	MyApplication.Done
end.