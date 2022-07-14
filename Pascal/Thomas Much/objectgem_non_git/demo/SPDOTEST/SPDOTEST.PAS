{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

program SpeedoTest;

uses

	Tos,Gem,OTypes,OProcs,OWindows,ODialogs;

const

	{$I spdotest.i}
	texts: array [0..2] of string =
	         ('ObjectGEM','fÅr PurePascal','Softdesign ''94');

type

	TSpApplication = object(TApplication)
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
	end;

	PSpWindow = ^TSpWindow;
	TSpWindow = object(TWindow)
		fs,
		fy,
		offs    : array [0..3] of integer;
		fntIndx,
		fntColor,
		oldWidth: integer;
		fntName : string;
		function CanClose: boolean; virtual;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetClassName: string; virtual;
		procedure SetupVDI; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure WMClick(mX,mY,KStat: integer); virtual;
		procedure GetWorkMin(var minX,minY: integer); virtual;
	end;

	TTransRec = record
		fc,
		bc: array [0..7] of integer
	end;

	PSpDialog = ^TSpDialog;
	TSpDialog = object(TDialog)
		TransRec: TTransRec;
		okBtn   : PButton;
		function GetStyle: integer; virtual;
		procedure WMClosed; virtual;
		function OK: boolean; virtual;
		function Cancel: boolean; virtual;
		function Help: boolean; virtual;
		procedure CallChanged(Indx: integer; dclk,edt,push: boolean); virtual;
	end;

	PAbout = ^TAbout;
	TAbout = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PAttr = ^TAttr;
	TAttr = object(TKeyMenu)
		procedure Work; virtual;
	end;

	PFont = ^TFont;
	TFont = object(TKeyMenu)
		procedure Work; virtual;
	end;

var

	SpApp: TSpApplication;


function vqtName(handle,element_num: integer; var name: string; var index: integer): boolean;
	var q    : integer;
	    valid: boolean;

	begin
		VDI_pb.control^[0]:=130;
		VDI_pb.control^[1]:=0;
		VDI_pb.control^[3]:=1;
		VDI_pb.control^[6]:=handle;
		VDI_pb.intin^[0]:=element_num;
		vdi(@VDI_pb);
		valid:=(VDI_pb.intout^[33]=1) and Application^.SpeedoActive;
		if valid then index:=VDI_pb.intout^[0];
		name:='';
		for q:=1 to 32 do name:=name+chr(VDI_pb.intout^[q]);
		StrPTrim(name);
		vqtName:=valid
	end;


procedure SpResource; external; {$L spdotest.o}


procedure TSpApplication.InitInstance;

	begin
		InitResource(@SpResource,nil);
		LoadMenu(SPMENU);
		new(PAbout,Init(@self,K_CTRL,Ctrl_A,SPABOUT,SPTITLE1));
		new(PAttr,Init(@self,K_CTRL,Ctrl_T,SPATTR,SPTITLE3));
		new(PFont,Init(@self,K_CTRL,Ctrl_Z,SPFONT,SPTITLE3));
		inherited InitInstance;
		SetQuit(SPQUIT,SPTITLE2)
	end;


procedure TSpApplication.InitMainWindow;

	begin
		if not(SpeedoActive) then
			if Alert(nil,2,STOP,'SpeedoGDOS ist _nicht_ aktiv!','&OK|&Abbruch')<>1 then
				begin
					Quit;
					exit
				end;
		new(PSpWindow,Init(nil,'SpeedoTest'));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
	end;


function TSpWindow.CanClose: boolean;

	begin
		CanClose:=false;
		if inherited CanClose then
			CanClose:=(Application^.Alert(nil,1,WAIT,'Wollen Sie "SpeedoTest" wirklich verlassen?','&Ja| &Nein ')=1)
	end;


procedure TSpWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do Style:=Style or cs_FullRedraw or cs_WorkBackground
	end;


function TSpWindow.GetClassName: string;

	begin
		GetClassName:='SpeedoTestWindow'
	end;


procedure TSpWindow.SetupVDI;
	var q: integer;

	begin
		Attr.ExStyle:=Attr.ExStyle or ws_ex_LoadFonts;
		inherited SetupVDI;
		vswr_mode(vdiHandle,MD_TRANS);
		vst_alignment(vdiHandle,TA_LEFT,TA_ASCENT,q,q);
		fntColor:=Blue;
		vst_color(vdiHandle,fntColor);
		fntIndx:=-1;
		oldWidth:=-1;
		for q:=1 to (Attr.sysFonts+Attr.addFonts) do
			if vqtName(vdiHandle,q,fntName,fntIndx) then break;
		if fntIndx=-1 then SetSubTitle(' Keine Vektorfonts vorhanden.')
		else
			begin
				SetSubTitle(' Aktueller Font: '+fntName);
				vst_font(vdiHandle,fntIndx)
			end
	end;


procedure TSpWindow.Paint(var PaintInfo: TPaintStruct);
	var dummy,q: integer;
	    array8 : ARRAY_8;

	procedure getSize;
		label _fsnew,_fsagain;

		var h,abw,old: integer;

		begin
			SetSubTitle(' Neue Fontgrîûen werden berechnet...');
			BusyMouse;
			ShowMouse;
			fy[0]:=0;
			q:=0;
			repeat
				fy[q+1]:=fy[q];
				abw:=5;
				_fsnew:
				h:=round(Application^.Attr.MaxPX*(Application^.Attr.PixW/1000));
				fs[q]:=h shr 1;
				old:=0;
				_fsagain:
				vst_arbpt(vdiHandle,fs[q],dummy,dummy,dummy,dummy);
				vqt_f_extent(vdiHandle,texts[q],array8);
				dummy:=array8[2]-array8[0];
				if not(Between(dummy,Work.W-abw,Work.W+abw)) and not(bTst(Kbshift(-1),1)) then
					begin
						if fs[q]=old then
							begin
								inc(abw,5);
								goto _fsnew
							end;
						if dummy<Work.W then
							begin
								old:=fs[q];
								fs[q]:=(fs[q]+h) shr 1;
								goto _fsagain
							end
						else
							begin
								old:=fs[q];
								h:=fs[q];
								fs[q]:=fs[q] shr 1;
								goto _fsagain
							end
					end;
				offs[q]:=-array8[0];
				inc(q);
				fy[q]:=fy[q]+array8[7]-array8[1]
			until q>2;
			HideMouse;
			ArrowMouse;
			SetSubTitle(' Aktueller Font: '+fntName);
			oldWidth:=Work.W
		end;

	begin
		if fntIndx=-1 then for q:=0 to 2 do v_gtext(vdiHandle,Work.X+10,Work.Y+q*Attr.boxHeight+20,texts[q])
		else
			begin
				if Work.W<>oldWidth then getSize;
				for q:=0 to 2 do
					begin
						vst_arbpt(vdiHandle,fs[q],dummy,dummy,dummy,dummy);
						v_ftext(vdiHandle,Work.X+offs[q],Work.Y+fy[q],texts[q])
					end
			end
	end;


procedure TSpWindow.WMClick(mX,mY,KStat: integer);
	var pu     : PPopup;
	    q,w,ret: integer;
	    idxs   : array [0..8] of integer;
	    nam    : array [0..8] of string;

	begin
		new(pu,Init(@self,SPPOP,SPPOPUP));
		if pu<>nil then
			begin
				with pu^ do
					begin
						pX:=mX;
						pY:=mY;
						pFlag:=POP_CENTER;
						for q:=0 to 8 do
							begin
								SetText(q,'  -------------------------------- ');
								Uncheck(q);
								Disable(q)
							end;
						w:=0;
						for q:=1 to (Attr.sysFonts+Attr.addFonts) do
							if vqtName(vdiHandle,q,nam[w],ret) then
								begin
									Enable(w);
									SetText(w,'  '+nam[w]+StrPSpace(33-length(nam[w])));
									if ret=fntIndx then Check(w);
									idxs[w]:=ret;
									inc(w);
									if w=9 then break
								end;
						ret:=Execute
					end;
				dispose(pu,Done);
				if ret>=0 then
					if idxs[ret]<>fntIndx then
						begin
							fntIndx:=idxs[ret];
							fntName:=nam[ret];
							oldWidth:=-1;
							vst_font(vdiHandle,idxs[ret]);
							SetSubTitle(' Aktueller Font: '+nam[ret]);
							ForceRedraw
						end
			end
	end;


procedure TSpWindow.GetWorkMin(var minX,minY: integer);

	begin
		inherited GetWorkMin(minX,minY);
		inc(minX,50);
		inc(minY,40)
	end;


function TSpDialog.GetStyle: integer;

	begin
		GetStyle:=inherited GetStyle or SIZER or FULLER
	end;


procedure TSpDialog.WMClosed;

	begin
		if CanClose then
			if Cancel then Destroy
	end;


function TSpDialog.OK: boolean;
	var q: integer;

	begin
		inherited OK;
		OK:=IsModal;
		with PSpWindow(Application^.MainWindow)^ do
			begin
				fntColor:=0;
				while TransRec.fc[fntColor]=bf_Unchecked do inc(fntColor);
				vst_color(vdiHandle,fntColor)
			end;
		q:=0;
		while TransRec.bc[q]=bf_Unchecked do inc(q);
		Application^.MainWindow^.Class.hbrBackground:=succ(q);
		Application^.MainWindow^.ForceRedraw
	end;


function TSpDialog.Cancel: boolean;
	var valid: boolean;

	begin
		valid:=inherited Cancel;
		if valid then okBtn^.Enable;
		Cancel:=valid
	end;


function TSpDialog.Help: boolean;

	begin
		Application^.Alert(@self,1,NO_ICON,'In dieser Dialogbox werden die Schriftattribute eingestellt. Die neuen Werte werden Åbernommen, wenn Sie '#174'Setzen'#175' anklicken. Ist der Dialog nichtmodal, bleibt er auch nach dem Setzen aktiv!','  &OK  ');
		Help:=false
	end;


procedure TSpDialog.CallChanged(Indx: integer; dclk,edt,push: boolean);
	var tr   : TTransRec;
	    op   : pointer;
	    q1,q2: integer;

	begin
		inherited CallChanged(Indx,dclk,edt,push);
		op:=TransferBuffer;
		TransferBuffer:=@tr;
		TransferData(tf_GetData);
		TransferBuffer:=op;
		q1:=0;
		while tr.fc[q1]=bf_Unchecked do inc(q1);
		q2:=0;
		while tr.bc[q2]=bf_Unchecked do inc(q2);
		if q1=q2 then okBtn^.Disable
		else
			okBtn^.Enable
	end;


procedure TAbout.Work;

	begin
		if ADialog=nil then
			begin
				new(ADialog,Init(nil,'öber SpeedoTest',SABOUT));
				if ADialog<>nil then
					begin
						new(PGroupBox,Init(ADialog,IGROUP,'ObjectGEM SpeedoTest','"42"'));
						new(PButton,Init(ADialog,IOK,id_OK,true,'Mit diesem '+
											'Button|kann die Infobox|verlassen werden.'))
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


procedure TAttr.Work;
	var q: integer;

	begin
		if ADialog=nil then
			begin
				ADialog:=new(PSpDialog,Init(nil,'Attribute',SATTR));
				if ADialog<>nil then
					begin
						new(PGroupBox,Init(ADialog,AFGROUP,'Schrift','Bestimmt die Schriftfarbe.'));
						new(PGroupBox,Init(ADialog,ABGROUP,'Hintergrund','Bestimmt die Farbe des|Fenster-Hintergrundes.'));
						new(PRadioButton,Init(ADialog,AFWHITE,true,'Setzt Weiû als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFBLACK,true,'Setzt Schwarz als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFRED,true,'Setzt Rot als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFGREEN,true,'Setzt GrÅn als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFBLUE,true,'Setzt Blau als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFCYAN,true,'Setzt TÅrkis als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFYELLOW,true,'Setzt Gelb als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,AFMAGENT,true,'Setzt Violett als|neue Schriftfarbe'));
						new(PRadioButton,Init(ADialog,ABWHITE,true,'Setzt Weiû als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABBLACK,true,'Setzt Schwarz als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABRED,true,'Setzt Rot als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABGREEN,true,'Setzt GrÅn als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABBLUE,true,'Setzt Blau als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABCYAN,true,'Setzt TÅrkis als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABYELLOW,true,'Setzt Gelb als|neuen Hintergrund'));
						new(PRadioButton,Init(ADialog,ABMAGENT,true,'Setzt Violett als|neuen Hintergrund'));
						new(PButton,Init(ADialog,AHELP,id_Help,true,'Zeigt einen Hilfstext|Åber diesen Dialog an.'));
						new(PSpDialog(ADialog)^.okBtn,Init(ADialog,AOK,id_OK,true,'Setzt die neuen Attribute,|_ohne_ den Dialog zu ver-|lassen.'));
						new(PButton,Init(ADialog,ACANCEL,id_Cancel,true,'Bricht den Dialog ab,|ohne die neuen Werte|zu Åbernehmen.'));
						with PSpDialog(ADialog)^ do
							begin
								TransferBuffer:=@TransRec;
								with TransRec do
									begin
										for q:=0 to 7 do
											begin
												fc[q]:=bf_Unchecked;
												bc[q]:=bf_Unchecked
											end;
										fc[PSpWindow(Application^.MainWindow)^.fntColor]:=bf_Checked;
										bc[pred(Application^.MainWindow^.Class.hbrBackground)]:=bf_Checked
									end
							end
					end
			end;
		if ADialog<>nil then ADialog^.MakeWindow
	end;


procedure TFont.Work;
	var x,y,bs,ks: integer;

	begin
		graf_mkstate(x,y,bs,ks);
		Application^.MainWindow^.WMClick(x,y,ks)
	end;


begin
	SpApp.Init('SpeedoTest');
	SpApp.Run;
	SpApp.Done
end.