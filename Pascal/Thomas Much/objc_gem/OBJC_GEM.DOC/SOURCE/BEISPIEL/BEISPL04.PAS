program Beispiel; {$X+} { Beispiel Nr.4 }

uses

	Gem,OTypes,OProcs,OWindows;

const

	{$I beispiel.i}

type

	TMyApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
	end;

	PBeispielWindow = ^TBeispielWindow;
	TBeispielWindow = object(TWindow)
		Veraendert: boolean;
		Dicke,
		Farbe,
		Art       : integer;
		Pfad,
		Datei     : string;
		constructor Init(AParent: PWindow; ATitle: string);
		function CanClose: boolean; virtual;
		procedure WMButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
		{ neue Methoden: }
		procedure SetAttr(Width,Color,Style: integer); virtual;
		procedure CreateTitle; virtual;
	end;

	PAbout = ^TAbout;
	TAbout = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PNew = ^TNew;
	TNew = object(TKeyMenu)
		procedure Work; virtual;
	end;

	POpen = ^TOpen;
	TOpen = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PSave = ^TSave;
	TSave = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PSaveAs = ^TSaveAs;
	TSaveAs = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PInfo = ^TInfo;
	TInfo = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PAttrib = ^TAttrib;
	TAttrib = object(TKeyMenu)
		procedure Work; virtual;
	end;

var

	MyApp: TMyApplication;


procedure MyResource; external; {$L beispiel.o}


procedure TMyApplication.InitInstance;

	begin
		InitResource(@MyResource,nil);
		LoadMenu(BSPMENU);
		new(PAbout,Init(@self,K_CTRL,Ctrl_A,MABOUT,MTITLE1));
		new(PNew,Init(@self,K_CTRL,Ctrl_N,MNEW,MTITLE2));
		new(POpen,Init(@self,K_CTRL,Ctrl_O,MOPEN,MTITLE2));
		new(PSave,Init(@self,K_CTRL,Ctrl_S,MSAVE,MTITLE2));
		new(PSaveAs,Init(@self,K_CTRL,Ctrl_D,MSAVEAS,MTITLE2));
		new(PInfo,Init(@self,K_CTRL,Ctrl_I,MINFO,MTITLE3));
		new(PAttrib,Init(@self,K_CTRL,Ctrl_T,MATTR,MTITLE3));
		inherited InitInstance;
		SetQuit(MQUIT,MTITLE2)
	end;


procedure TMyApplication.InitMainWindow;

	begin
		new(PBeispielWindow,Init(nil,'Beispiel  [unbenannt]'));
		if (MainWindow=nil) or (ChkError<em_OK) then
			Status:=em_InvalidMainWindow
	end;


constructor TBeispielWindow.Init(AParent: PWindow; ATitle: string);

	begin
		if not(inherited Init(AParent,ATitle)) then fail;
		Veraendert:=false;
		SetAttr(3,Blue,LT_SOLID);
		Datei:='';
		Pfad:=''
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
					Veraendert:=true;
					CreateTitle
				end;
		if bTst(BStat,2) then
			begin
				ForceRedraw;
				Veraendert:=false;
				CreateTitle
			end
	end;


procedure TBeispielWindow.SetAttr(Width,Color,Style: integer);
	const farben: array [0..7] of string[7] =
		('weiû','schwarz','rot','grÅn','blau','tÅrkis','gelb','violett');
				arten: array [1..6] of string[16] =
		('durchgehend','langer Strich','Punkte','Strich, Punkt',
		                             'Strich','Strich, 2 Punkte');

	begin
		Dicke:=Width;
		Farbe:=Color;
		Art:=Style;
		vsl_width(vdiHandle,Dicke);
		vsl_color(vdiHandle,Farbe);
		vsl_type(vdiHandle,Art);
		SetSubTitle(' Dicke: '+ltoa(Dicke)+'  Farbe: '+farben[Farbe]+
								'   Art: '+arten[Art])
	end;


procedure TBeispielWindow.CreateTitle;
	var titel: string;

	begin
		if length(Datei)=0 then titel:='[unbenannt]'
		else
			titel:=Pfad+Datei;
		if Veraendert then titel:='*'+titel;
		titel:='Beispiel  '+titel;
		SetTitle(titel)
	end;


procedure TAbout.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TNew.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TOpen.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TSave.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TSaveAs.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TInfo.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TAttrib.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


begin
	MyApp.Init('Beispiel');
	MyApp.Run;
	MyApp.Done
end.