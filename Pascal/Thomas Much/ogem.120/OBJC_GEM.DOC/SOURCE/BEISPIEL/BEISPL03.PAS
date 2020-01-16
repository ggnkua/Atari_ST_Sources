program Beispiel; {$X+} { Beispiel Nr.3 }

uses

	Gem,OTypes,OProcs,OWindows;

type

	TMyApplication = object(TApplication)
		procedure InitMainWindow; virtual;
	end;

	PBeispielWindow = ^TBeispielWindow;
	TBeispielWindow = object(TWindow)
		Veraendert: boolean;
		Dicke,
		Farbe,
		Art       : integer;
		constructor Init(AParent: PWindow; ATitle: string);
		function CanClose: boolean; virtual;
		procedure WMButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
		procedure SetAttr(Width,Color,Style: integer); virtual;
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
		Veraendert:=false;
		SetAttr(3,Blue,LT_SOLID)
	end;


function TBeispielWindow.CanClose: boolean;
	var valid: boolean;

	begin
		valid:=inherited CanClose;
		if valid and Veraendert then
			valid:=(Application^.Alert(@self,1,WAIT,
				' Die Grafik wurde verÑndert!| Wollen Sie sie speichern?',
			  '&Ja|  &Nein  ')=2);
		CanClose:=valid
	end;


procedure TBeispielWindow.WMButton(mX,mY,BStat,KStat,Clicks: integer);
	var xalt,yalt,btn,dummy: integer;
	    pxyarray           : ptsin_ARRAY;

	begin
		if bTst(BStat,1) then
			if GetDC>=0 then
				begin
					wind_update(BEG_MCTRL);
					repeat
						xalt:=mX;
						yalt:=mY;
						repeat
							graf_mkstate(mX,mY,btn,dummy)
						until (mX<>xalt) or (mY<>yalt) or not(bTst(btn,1));
						pxyarray[0]:=xalt;
						pxyarray[1]:=yalt;
						pxyarray[2]:=mX;
						pxyarray[3]:=mY;
						v_pline(vdiHandle,2,pxyarray)
					until not(bTst(btn,1));
					wind_update(END_MCTRL);
					ReleaseDC;
					Veraendert:=true
				end;
		if bTst(BStat,2) then
			begin
				ForceRedraw;
				Veraendert:=false
			end
	end;


procedure TBeispielWindow.SetAttr(Width,Color,Style: integer);
	const farben: array [0..7] of string[7] =
		('weiû','schwarz','rot','grÅn','blau','tÅrkis','gelb','violett');
				arten: array [1..6] of string[16] =
		('durchgehend','langer Strich','Punkte','Strich, Punkt','Strich','Strich, 2 Punkte');

	begin
		Dicke:=Width;
		Farbe:=Color;
		Art:=Style;
		vsl_width(vdiHandle,Dicke);
		vsl_color(vdiHandle,Farbe);
		vsl_type(vdiHandle,Art);
		SetSubTitle(' Dicke: '+ltoa(Dicke)+'  Farbe: '+farben[Farbe]+'   Art: '+arten[Art])
	end;


begin
	MyApp.Init('Beispiel');
	MyApp.Run;
	MyApp.Done
end.