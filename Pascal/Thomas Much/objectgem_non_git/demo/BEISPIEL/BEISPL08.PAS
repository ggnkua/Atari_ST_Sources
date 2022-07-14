program Beispiel; {$X+} { Beispiel Nr.8 }

uses

	Gem,Objects,OTypes,OProcs,OWindows,OValidat,ODialogs;

const

	{$I beispiel.i}

type

	PBeispielWindow = ^TBeispielWindow;
	PAttrDialog     = ^TAttrDialog;
	PLineData       = ^TLineData;
	PLinie          = ^TLinie;
	PPunkt          = ^TPunkt;
	PAbout          = ^TAbout;
	PNew            = ^TNew;
	POpen           = ^TOpen;
	PSave           = ^TSave;
	PSaveAs         = ^TSaveAs;
	PInfo           = ^TInfo;
	PAttrib         = ^TAttrib;

	TMyApplication = object(TApplication)
		save  : PSave;
		saveas: PSaveAs;
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
	end;

	TBeispielWindow = object(TWindow)
		Veraendert: boolean;
		Dicke,
		Farbe,
		Art       : integer;
		Pfad,
		Datei     : string;
		Zeichnung : PCollection;
		constructor Init(AParent: PWindow; ATitle: string);
		destructor Done; virtual;
		function CanClose: boolean; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure WMButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
		{ neue Methoden: }
		procedure SetAttr(Width,Color,Style: integer); virtual;
		procedure CreateTitle; virtual;
		procedure Speichern; virtual;
	end;

	TAttrDialog = object(TDialog)
		function OK: boolean; virtual;
		function Help: boolean; virtual;
	end;

	TLineData = record
		Farben: array [0..7] of integer;
		Stile : array [1..6] of integer;
		Breite: string[5]
	end;

	TLinie = object(TObject)
		Punkte: PCollection;
		Dicke,
		Farbe,
		Art   : integer;
		constructor Init(Width,Color,Style: integer);
		destructor Done; virtual;
		procedure NeuerPunkt(AX,AY: integer); virtual;
		procedure Zeichnen; virtual;
		procedure Speichern; virtual;
	end;

	TPunkt = object(TObject)
		X,
		Y: integer;
		constructor Init(AX,AY: integer);
	end;

	TAbout  = object(TKeyMenu)
		procedure Work; virtual;
	end;

	TNew    = object(TKeyMenu)
		procedure Work; virtual;
	end;

	TOpen   = object(TKeyMenu)
		procedure Work; virtual;
	end;

	TSave   = object(TKeyMenu)
		procedure Work; virtual;
	end;

	TSaveAs = object(TKeyMenu)
		procedure Work; virtual;
	end;

	TInfo   = object(TKeyMenu)
		procedure Work; virtual;
	end;

	TAttrib = object(TKeyMenu)
		LineData: TLineData;
		procedure Work; virtual;
	end;

var

	MyApp: TMyApplication;
	f    : file of integer;


procedure MyResource; external; {$L beispiel.o}


procedure TMyApplication.InitInstance;

	begin
		InitResource(@MyResource,nil);
		LoadMenu(BSPMENU);
		new(PAbout,Init(@self,K_CTRL,Ctrl_A,MABOUT,MTITLE1));
		new(PNew,Init(@self,K_CTRL,Ctrl_N,MNEW,MTITLE2));
		new(POpen,Init(@self,K_CTRL,Ctrl_O,MOPEN,MTITLE2));
		save:=new(PSave,Init(@self,K_CTRL,Ctrl_S,MSAVE,MTITLE2));
		saveas:=new(PSaveAs,Init(@self,K_CTRL,Ctrl_D,MSAVEAS,MTITLE2));
		new(PInfo,Init(@self,K_CTRL,Ctrl_I,MINFO,MTITLE3));
		new(PAttrib,Init(@self,K_CTRL,Ctrl_T,MATTR,MTITLE3));
		inherited InitInstance;
		SetQuit(MQUIT,MTITLE2);
		save^.Disable;
		saveas^.Disable
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
		new(Zeichnung,Init(10,10));
		Veraendert:=false;
		SetAttr(3,Blue,LT_SOLID);
		Datei:='';
		Pfad:=''
	end;


destructor TBeispielWindow.Done;

	begin
		dispose(Zeichnung,Done);
		inherited Done
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


procedure ZeichneLinienzug(p: PLinie);

	begin
		p^.Zeichnen
	end;


procedure TBeispielWindow.Paint(var PaintInfo: TPaintStruct);

	begin
		Zeichnung^.ForEach(@ZeichneLinienzug);
		vsl_width(vdiHandle,Dicke);
		vsl_color(vdiHandle,Farbe);
		vsl_type(vdiHandle,Art)
	end;


procedure TBeispielWindow.WMButton(mX,mY,BStat,KStat,Clicks: integer);
	var xalt,yalt,btn,dummy: integer;
	    pxyarray           : ptsin_ARRAY;
	    ALinie             : PLinie;

	begin
		if bTst(BStat,1) then
			if GetDC>=0 then
				begin
					wind_update(BEG_MCTRL);
					ALinie:=new(PLinie,Init(Dicke,Farbe,Art));
					Zeichnung^.Insert(ALinie);
					ALinie^.NeuerPunkt(mX-Work.X,mY-Work.Y);
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
						v_pline(vdiHandle,2,pxyarray);
						ALinie^.NeuerPunkt(mX-Work.X,mY-Work.Y)
					until not(bTst(btn,1));
					wind_update(END_MCTRL);
					ReleaseDC;
					Veraendert:=true;
					CreateTitle;
					MyApp.saveas^.Enable;
					if length(Datei)>0 then MyApp.save^.Enable
				end;
		if bTst(BStat,2) then
			begin
				Zeichnung^.FreeAll;
				ForceRedraw;
				Veraendert:=false;
				CreateTitle;
				MyApp.save^.Disable;
				MyApp.saveas^.Disable
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
		vsl_ends(vdiHandle,LE_ROUNDED,LE_ROUNDED);
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


procedure SpeichereLinienzug(p: PLinie);

	begin
		p^.Speichern
	end;


procedure TBeispielWindow.Speichern;

	begin
		BusyMouse;
		assign(f,Pfad+Datei);
		rewrite(f);
		Zeichnung^.ForEach(@SpeichereLinienzug);
		close(f);
		ArrowMouse;
		Veraendert:=false;
		CreateTitle
	end;


function TAttrDialog.OK: boolean;
	var valid   : boolean;
	    d,f,s,vh: integer;
	    attrb   : ARRAY_4;

	begin
		valid:=inherited OK;
		if valid then
			begin
				vh:=Application^.MainWindow^.vdiHandle;
				with PLineData(TransferBuffer)^ do
					begin
						f:=0;
						while Farben[f]<>bf_Checked do inc(f);
						s:=1;
						while Stile[s]<>bf_Checked do inc(s);
						vsl_width(vh,atol(Breite))
					end;
				vql_attributes(vh,attrb);
				PBeispielWindow(Application^.MainWindow)^.SetAttr(attrb[3],f,s)
			end;
		OK:=valid
	end;


function TAttrDialog.Help: boolean;

	begin
		Application^.Alert(@self,1,NO_ICON,'In dieser Dialogbox werden die|Attribute der Linien eingestellt.|Die neuen Werte gelten ab der|ersten Linie, die nach dem|Schlieûen der Box gezeichnet|wird.','   &OK   ');
		Help:=false
	end;


constructor TLinie.Init(Width,Color,Style: integer);

	begin
		if not(inherited Init) then fail;
		new(Punkte,Init(50,50));
		Dicke:=Width;
		Farbe:=Color;
		Art:=Style
	end;


destructor TLinie.Done;

	begin
		dispose(Punkte,Done);
		inherited Done
	end;


procedure TLinie.NeuerPunkt(AX,AY: integer);

	begin
		Punkte^.Insert(new(PPunkt,Init(AX,AY)))
	end;


procedure TLinie.Zeichnen;
	var q       : longint;
	    vh,dx,dy: integer;
	    pxyarray: ptsin_ARRAY;

	begin
		if Punkte^.Count>1 then
			begin
				with Application^ do
					begin
						vh:=MainWindow^.vdiHandle;
						dx:=MainWindow^.Work.X;
						dy:=MainWindow^.Work.Y
					end;
				vsl_width(vh,Dicke);
				vsl_color(vh,Farbe);
				vsl_type(vh,Art);
				vsl_ends(vh,LE_ROUNDED,LE_ROUNDED);
				with PPunkt(Punkte^.At(0))^ do
					begin
						pxyarray[2]:=X+dx;
						pxyarray[3]:=Y+dy
					end;
				for q:=1 to pred(Punkte^.Count) do
					with PPunkt(Punkte^.At(q))^ do
						begin
							pxyarray[0]:=pxyarray[2];
							pxyarray[1]:=pxyarray[3];
							pxyarray[2]:=X+dx;
							pxyarray[3]:=Y+dy;
							v_pline(vh,2,pxyarray)
						end
			end
	end;


procedure TLinie.Speichern;
	var q  : longint;
	    cnt: integer;

	begin
		cnt:=Punkte^.Count;
		if cnt>0 then
			begin
				write(f,Dicke,Farbe,Art,cnt);
				for q:=0 to pred(cnt) do
					with PPunkt(Punkte^.At(q))^ do
						write(f,X,Y)
			end
	end;


constructor TPunkt.Init(AX,AY: integer);

	begin
		if not(inherited Init) then fail;
		X:=AX;
		Y:=AY
	end;


procedure TAbout.Work;

	begin
		if ADialog=nil then
			begin
				new(ADialog,Init(nil,'öber Beispiel',BSPABOUT));
				if ADialog<>nil then
					begin
						new(PGroupBox,Init(ADialog,IGROUP,'ObjectGEM '+
																'Beispielprogramm','"42"'));
						new(PButton,Init(ADialog,IOK,id_OK,true,'Mit diesem '+
											'Button|kann die Infobox|verlassen werden.'))
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


procedure TNew.Work;

	begin
		with PBeispielWindow(Application^.MainWindow)^ do
			begin
				Zeichnung^.FreeAll;
				ForceRedraw;
				Veraendert:=false;
				Pfad:='';
				Datei:='';
				CreateTitle;
				MyApp.save^.Disable;
				MyApp.saveas^.Disable
			end
	end;


procedure TOpen.Work;
	var ALinie          : PLinie;
	    width,color,styl: integer;
	    cnt,x,y         : integer;
	    q               : longint;

	begin
		with PBeispielWindow(Application^.MainWindow)^ do
			if FileSelect(nil,'BEISPIEL-LINIEN LADEN','*.BLN',
											Pfad,Datei,true) then
				begin
					BusyMouse;
					Zeichnung^.FreeAll;
					assign(f,Pfad+Datei);
					reset(f);
					while not(eof(f)) do
						begin
							read(f,width,color,styl,cnt);
							ALinie:=new(PLinie,Init(width,color,styl));
							Zeichnung^.Insert(ALinie);
							for q:=1 to cnt do
								begin
									read(f,x,y);
									ALinie^.NeuerPunkt(x,y)
								end
						end;
					close(f);
					ArrowMouse;
					Veraendert:=false;
					CreateTitle;
					ForceRedraw;
					MyApp.save^.Enable;
					MyApp.saveas^.Enable
				end
	end;


procedure TSave.Work;

	begin
		PBeispielWindow(Application^.MainWindow)^.Speichern
	end;


procedure TSaveAs.Work;

	begin
		with PBeispielWindow(Application^.MainWindow)^ do
			if FileSelect(nil,'BEISPIEL-LINIEN SPEICHERN','*.BLN',
											Pfad,Datei,false) then
				begin
					Speichern;
					MyApp.save^.Enable
				end
	end;


procedure TInfo.Work;

	begin
		Application^.Alert(nil,1,NOTE,'Die Funktion ist noch|'+
													'nicht implementiert.',' &Schade ')
	end;


procedure TAttrib.Work;
	var ed: PEdit;
	    q : integer;

	begin
		if ADialog=nil then
			begin
				ADialog:=new(PAttrDialog,Init(nil,'Attribute',BSPATTR));
				if ADialog<>nil then
					begin
						new(PGroupBox,Init(ADialog,ACGROUP,'Farbe',
														'Bestimmt die|Linienfarbe'));
						new(PGroupBox,Init(ADialog,ASGROUP,'Stil',
														'Bestimmt den|Linienstil'));
						new(PRadioButton,Init(ADialog,AWHITE,true,
														'Setzt Weiû als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,ABLACK,true,
														'Setzt Schwarz als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,ARED,true,
														'Setzt Rot als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,AGREEN,true,
														'Setzt GrÅn als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,ABLUE,true,
														'Setzt Blau als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,ACYAN,true,
														'Setzt TÅrkis als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,AYELLOW,true,
														'Setzt Gelb als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,AMAGENTA,true,
														'Setzt Violett als|neue Linienfarbe'));
						new(PRadioButton,Init(ADialog,ASOLID,true,
														'Setzt LT_SOLID als|neuen Linienstil'));
						new(PRadioButton,Init(ADialog,ALONG,true,
														'Setzt LT_LONGDASH als|neuen Linienstil'));
						new(PRadioButton,Init(ADialog,ADOTS,true,
														'Setzt LT_DOTTED als|neuen Linienstil'));
						new(PRadioButton,Init(ADialog,ALINEDOT,true,
														'Setzt LT_DASHDOT als|neuen Linienstil'));
						new(PRadioButton,Init(ADialog,ALINE,true,
														'Setzt LT_DASHED als|neuen Linienstil'));
						new(PRadioButton,Init(ADialog,ALIN2DOT,true,
														'Setzt LT_DASHDOTDOT|als neuen Linienstil'));
						ed:=new(PEdit,Init(ADialog,AWIDTH,5,
									'Gibt die Linien-|stÑrke an (1,3,..).|Immer UNgerade!'));
						new(PButton,Init(ADialog,ACANCEL,id_Cancel,true,
							'Bricht den Dialog ab,|ohne die neuen Werte|zu Åbernehmen'));
						new(PButton,Init(ADialog,AOK,id_OK,true,
													'Beendet den Dialog und|setzt die neuen Werte'));
						new(PButton,Init(ADialog,AHELP,id_Help,false,
							'Zeigt einen allgemeinen|Hilfstext Åber diesen|Dialog an.'));
						with PBeispielWindow(Application^.MainWindow)^ do
							with LineData do
								begin
									for q:=0 to 7 do Farben[q]:=bf_Unchecked;
									for q:=1 to 6 do Stile[q]:=bf_Unchecked;
									Farben[Farbe]:=bf_Checked;
									Stile[Art]:=bf_Checked;
									Breite:=ltoa(Dicke)
								end;
						ADialog^.TransferBuffer:=@LineData;
						ed^.SetValidator(new(PRangeValidator,Init(1,99)))
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


begin
	MyApp.Init('Beispiel');
	MyApp.Run;
	MyApp.Done
end.