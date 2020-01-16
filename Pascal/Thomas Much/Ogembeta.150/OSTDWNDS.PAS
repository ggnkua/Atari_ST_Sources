{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *        Unit  O S T D W N D S         *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        03.03.1994  *
 *      letztes Update am:  28.11.1997  *
 ****************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

	ObjectGEM ist Freeware, d.h. jeder darf die Units verwenden, ohne
	fÅr die damit entwickelten Programme Lizenzen o.Ñ. zahlen zu mÅssen,
	so lange alle Dateien _zusammen_ und _unverÑndert_ (!) weitergegeben
	werden.
	
	Ich freue mich natÅrlich trotzdem Åber kleine Aufmerksamkeiten wie
	Belegexemplare, originelle T-Shirts (L oder XL) sowie grÅnen Tee
	aus Japan :-)

  WICHTIG: Wer den Quelltext verÑndert und dann Probleme beim Compilieren,
  AusfÅhren o.Ñ. hat, kann nicht damit rechnen, daû ich den Fehler suche;
  tritt der Fehler allerdings auch mit dem Original-Quelltext auf, wÅrde
  ich mich Åber eine genaue Fehlerbeschreibung freuen. VerÑnderte Quell-
  texte dÅrfen _nicht_ weitergegeben werden, dies wÑre ein Verstoû gegen
  das Copyright!

  Wer beim Durchstîbern des Textes auf vermeintliche Fehler oder verbesse-
  rungswÅrdige Stellen trifft (von letzterem gibt es sicherlich noch viele),
  kann mir dies gerne mitteilen - ich habe auch ich nichts gegen kostenlos
  zur VerfÅgung gestellte optimierte Routinen (sofern sich jemand die MÅhe
  macht). Wer in anderen Projekten, die nicht in direkter Konkurrenz zu
  ObjectGEM stehen, einzelne Routinen verwenden mîchte, wendet sich bitte
  an mich (ein solcher Austausch sollte kein Problem sein).

  Wer sich auf nicht dokumentierte "implementation"- oder "private"-Eigen-
  schaften verlÑût, darf sich nicht Åber InkompatibilitÑten zu spÑteren
  Versionen wundern; wer meint, eine DokumentationslÅcke entdeckt zu haben,
  kann mir dies gerne mitteilen.

  Kleine Info zum Schluû: Als "default tabsize" verwende ich 2. Wer drei
  Punkte ("...") im Quelltext entdeckt, hat eine Stelle gefunden, an der
  ich z.Z. arbeite ;-)

  "Mîge die OOP mit Euch sein!"
}


{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit OStdWnds;

interface

uses

	Strings,Tos,Gem,Printer,Objects,OTypes,OProcs,OWindows;

type

	PTextWindow      = ^TTextWindow;
	TTextWindow      = object(TWindow)
		public
		Lines   : PStrCollection;
		FontID,
		FontSize,
		Color,
		TabSize : integer;
		RealTabs: boolean;
		constructor Init(AParent: PWindow; ATitle: string; InitLines,ADelta: integer);
		destructor Done; virtual;
		procedure SetupVDI; virtual;
		function GetStyle: integer; virtual;
		function GetScroller: PScroller; virtual;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetClassName: string; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		function WMKeyDown(Stat,Key: integer): boolean; virtual;
		procedure UpdateWindow; virtual;
		procedure AddLineRaw(NewLine: string); virtual;
		procedure AddLine(NewLine: string); virtual;
		procedure InsertLine(Index: longint; NewLine: string); virtual;
		procedure DeleteLine(LineNumber: integer); virtual;
		function GetLine(LineNumber: integer): string; virtual;
		function GetLineLength(LineNumber: integer): integer; virtual;
		function GetNumLines: integer; virtual;
		procedure Cut; virtual;
		procedure Copy; virtual;
		procedure Paste; virtual;
		procedure SelectAll; virtual;
		procedure Print; virtual;
		procedure InitPrint; virtual;
		procedure ExitPrint; virtual;
		procedure Read(AFileName: string); virtual;
		procedure Clear; virtual;
		procedure SetFont(NewID,NewSize: integer); virtual;
		procedure SetColor(NewColor: integer); virtual;
		procedure UpdateSubTitle; virtual;
		function TabXpand(s: string): string; virtual;
		function PrintFilter(s: string): string; virtual;
	end;

	PEditWindow      = ^TEditWindow;
	TEditWindow      = object(TTextWindow)
		public
		{ ... }
		function GetClassName: string; virtual;
	end;

	PHelpWindow      = ^THelpWindow;
	THelpWindow      = object(TTextWindow)
		public
		{ ... }
		function GetClassName: string; virtual;
	end;

	PIndicatorWindow = ^TIndicatorWindow;
	TIndicatorWindow = object(TDialog)
		public
		{ ... }
		function GetClassName: string; virtual;
	end;

	PSpecialCharactersWindow = ^TSpecialCharactersWindow;
	TSpecialCharactersWindow = object(TWindow)
		public
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetClassName: string; virtual;
		function GetIconTitle: string; virtual;
		function GetStyle: integer; virtual;
		procedure SetupSize; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure WMClick(mX,mY,KStat: integer); virtual;
		procedure WMDblClick(mX,mY,KStat: integer); virtual;
		function FontChanged(OrgID,AnID,ASize,AColor,BackColor,Effects,ARotation,ASkew,HorAlign,VertAlign,AWidth,TrackKern: integer; Size31: fix31; PairKern,cWnd: boolean): boolean; virtual;
		private
		fontID,
		fontPt,
		boxwidth,
		boxheight: integer;
		procedure CalcWidth(ID,Pt: integer; resize: boolean);
		procedure GetSize(var width,height: integer);
	end;


implementation


{ *** Objekt TTEXTWINDOW *** }

constructor TTextWindow.Init(AParent: PWindow; ATitle: string; InitLines,ADelta: integer);

	begin
		if not(inherited Init(AParent,ATitle)) then fail;
		if Scroller=nil then
			begin
				inherited Done;
				fail
			end;
		new(Lines,Init(InitLines,ADelta));
		if Lines=nil then
			begin
				inherited Done;
				fail
			end;
		Attr.ExStyle:=Attr.ExStyle or ws_ex_ReadOnly;
		TabSize:=2;
		RealTabs:=true;
		UpdateSubTitle
	end;


destructor TTextWindow.Done;

	begin
		if Lines<>nil then dispose(Lines,Done);
		inherited Done
	end;


procedure TTextWindow.SetupVDI;
	var dummy: integer;

	begin
		Attr.ExStyle:=Attr.ExStyle or ws_ex_LoadFonts;
		inherited SetupVDI;
		vst_alignment(vdiHandle,TA_LEFT,TA_TOP,dummy,dummy)
	end;


function TTextWindow.GetStyle: integer;

	begin
		GetStyle:=(inherited GetStyle and not(INFO)) or SLIDER
	end;


function TTextWindow.GetScroller: PScroller;
	var dummy: string[33];

	begin
		GetScroller:=new(PScroller,Init(@self,1,1,1,1));
		if Scroller=nil then exit;
		with Scroller^ do Style:=Style or scs_BitbltScrolling;
		SetFont(SysInfo.Font.ID,SysInfo.Font.Point);
		SetColor(Black)
	end;


procedure TTextWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do
			begin
				Style:=Style and not(cs_QuitOnClose) or cs_ByteAlignClient;
				hCursor:=TEXT_CRSR
			end
	end;


function TTextWindow.GetClassName: string;

	begin
		GetClassName:='TextWindow'
	end;


procedure TTextWindow.Paint(var PaintInfo: TPaintStruct);
	var q,bis: longint;

	begin
		if Lines^.Count=0 then exit;
		bis:=Scroller^.YPos+Scroller^.YPage;
		if bis>=Lines^.Count then bis:=Lines^.Count-1;
		for q:=Scroller^.YPos to bis do
			v_gtext(vdiHandle,Scroller^.GetXOrg,Scroller^.GetYOrg+q*Attr.boxHeight,TabXpand(StrPas(Lines^.At(q))))
		{ ... }
	end;


function TTextWindow.WMKeyDown(Stat,Key: integer): boolean;
	label _repon;

	begin
		KeyRepeatOff;
		if Stat=K_NORMAL then
			begin
				WMKeyDown:=true;
				case Key of
				Home:
					Scroller^.ScrollTo(0,0);
				Cur_Up:
					Scroller^.ScrollBy(0,-1);
				Cur_Down:
					Scroller^.ScrollBy(0,1);
				Cur_Left:
					Scroller^.ScrollBy(-1,0);
				Cur_Right:
					Scroller^.ScrollBy(1,0)
				else
					WMKeyDown:=false
				end;
				goto _repon
			end;
		if (Stat and K_SHIFT)>0 then
			begin
				WMKeyDown:=true;
				case Key of
				Shift_Home:
					Scroller^.ScrollTo(0,Scroller^.YRange);
				Shift_CU:
					Scroller^.ScrollBy(0,-Scroller^.YPage);
				Shift_CD:
					Scroller^.ScrollBy(0,Scroller^.YPage);
				Shift_CL:
					Scroller^.ScrollBy(-Scroller^.XPage,0);
				Shift_CR:
					Scroller^.ScrollBy(Scroller^.XPage,0)
				else
					WMKeyDown:=false
				end;
				goto _repon
			end;
		WMKeyDown:=false;
		_repon:
		KeyRepeatRestore
	end;


procedure TTextWindow.UpdateWindow;
	var xr,q: longint;

	begin
		xr:=Scroller^.XRange;
		q:=0;
		while q<Lines^.Count do
			begin
				if length(TabXpand(GetLine(q)))>=xr then xr:=length(TabXpand(GetLine(q)))+1;
				inc(q)
			end;
		Scroller^.SetRange(xr,Lines^.Count+1);
		UpdateSubTitle;
		ForceRedraw
	end;


procedure TTextWindow.AddLineRaw(NewLine: string);

	begin
		Lines^.AtInsert(Lines^.Count,ChrNew(NewLine))
	end;


procedure TTextWindow.AddLine(NewLine: string);
	var xr: longint;

	begin
		AddLineRaw(NewLine);
		UpdateSubTitle;
		if length(TabXpand(NewLine))>=Scroller^.XRange then xr:=length(TabXpand(NewLine))+1
		else
			xr:=Scroller^.XRange;
		Scroller^.SetRange(xr,Scroller^.YRange+1);
		Scroller^.ScrollTo(0,Lines^.Count);
		ForceRedraw
	end;


procedure TTextWindow.InsertLine(Index: longint; NewLine: string);
	var xr: longint;

	begin
		if Index<0 then Index:=0;
		if Index>Lines^.Count then Index:=Lines^.Count;
		Lines^.AtInsert(Index,ChrNew(NewLine));
		{ ... }
		UpdateSubTitle;
		if length(TabXpand(NewLine))>=Scroller^.XRange then xr:=length(TabXpand(NewLine))+1
		else
			xr:=Scroller^.XRange;
		Scroller^.SetRange(xr,Scroller^.YRange+1);
		Scroller^.ScrollTo(0,Index);
		ForceRedraw
	end;


procedure TTextWindow.DeleteLine(LineNumber: integer);

	begin
		if (LineNumber>=0) and (LineNumber<Lines^.Count) then Lines^.AtFree(LineNumber);
		{ ... }
		UpdateSubTitle;
		Scroller^.SetRange(Scroller^.XRange,Scroller^.YRange-1);
		ForceRedraw
	end;


function TTextWindow.GetLine(LineNumber: integer): string;

	begin
		if (LineNumber>=0) and (LineNumber<Lines^.Count) then GetLine:=StrPPas(Lines^.At(LineNumber))
		else
			GetLine:=''
	end;


function TTextWindow.GetLineLength(LineNumber: integer): integer;

	begin
		GetLineLength:=length(GetLine(LineNumber))
	end;


function TTextWindow.GetNumLines: integer;

	begin
		GetNumLines:=Lines^.Count
	end;


procedure TTextWindow.Cut;

	begin
		if Clipboard=nil then exit;
		with Clipboard^ do
			begin
				{ ... }
			end
	end;


procedure TTextWindow.Copy;

	begin
		if Clipboard=nil then exit;
		with Clipboard^ do
			begin
				{ ... }
			end
	end;


procedure TTextWindow.Paste;
	var ext     : string;
	    xr,yr,op: longint;
	    f       : text;

	begin
		if bTst(Attr.ExStyle,ws_ex_ReadOnly) then
			begin
				ext:=GetTitle;
				if length(ext)>0 then ext:='"'+ext+'"|';
				if Application^.Attr.Country=FRA then
					Application^.Alert(@self,1,NOTE,ext+'Ce texte n''est qu''en lecture uniquement.','  &OK  ')
				else if (Application^.Attr.Country=FRG) or (Application^.Attr.Country=SWG) then
					Application^.Alert(@self,1,NOTE,ext+'Dieser Text ist schreibgeschÅtzt.','  &OK  ')
				else
					Application^.Alert(@self,1,NOTE,ext+'This text is read-only.','  &OK  ');
				exit
			end;
		if Clipboard=nil then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(false)) then exit;
				ext:=GetPriorityClipboardFormat('txt.asc');
				if length(ext)>0 then
					begin
						{ ... }
						assign(f,GetClipboardFilename+ext);
						reset(f);
						xr:=Scroller^.XRange;
						yr:=Scroller^.YRange;
						op:=Lines^.Count;
						while not(eof(f)) do
							begin
								readln(f,ext);
								Lines^.AtInsert(Lines^.Count,ChrNew(ext));
								if length(TabXpand(ext))>=xr then xr:=length(TabXpand(ext))+1;
								inc(yr)
							end;
						close(f);
						UpdateSubTitle;
						Scroller^.SetRange(xr,yr);
						Scroller^.ScrollTo(0,op);
						ForceRedraw
					end;
				CloseClipboard
			end
	end;


procedure TTextWindow.SelectAll;

	begin
		{ ... }
	end;


procedure TTextWindow.Print;
	label _nochmal;

	var q  : longint;
	    ext: string;

	begin
		if GetNumLines=0 then exit;
		ext:=GetTitle;
		if length(ext)>0 then ext:='"'+ext+'"|';
		if Application^.Attr.Country=FRA then
			begin
				if Application^.Alert(@self,1,WAIT,ext+'Imprimer tout le texte?',' &Oui | &Non ')<>1 then exit
			end
		else if Application^.Attr.Country in [FRG,SWG] then
			begin
				if Application^.Alert(@self,1,WAIT,ext+'Den ganzen Text ausdrucken?','  &Ja  | &Nein ')<>1 then exit
			end
		else
			if Application^.Alert(@self,1,WAIT,ext+'Print whole text?',' &Yes |  &No  ')<>1 then exit;
		_nochmal:
		if Cprnos=0 then
			begin
				if Application^.Attr.Country=FRA then
					begin
						if Application^.Alert(@self,1,STOP,'Imprimante indisponible.','&Encore|&Abandon')=1 then goto _nochmal
					end
				else if Application^.Attr.Country in [FRG,SWG] then
					begin
						if Application^.Alert(@self,1,STOP,'Der Drucker ist nicht bereit.','&Nochmal|&Abbruch')=1 then goto _nochmal
					end
				else
					if Application^.Alert(@self,1,STOP,'Printer not responding.','&Retry|&Cancel')=1 then goto _nochmal;
				exit
			end;
		BusyMouse;
		InitPrint;
		for q:=0 to GetNumLines-1 do writeln(lst,PrintFilter(TabXpand(GetLine(q))));
		ExitPrint;
		ArrowMouse
	end;


procedure TTextWindow.InitPrint;

	begin
	end;


procedure TTextWindow.ExitPrint;

	begin
		write(lst,chr(FF),chr(BEL))
	end;


procedure TTextWindow.Read(AFileName: string);
	var f       : text;
	    zeile   : string;
	    xr,yr,op: longint;

	begin
		if not(Exist(AFileName)) then exit;
		SetMouse(IDC_LOAD,nil);
		{ ... }
		assign(f,AFileName);
		reset(f);
		xr:=Scroller^.XRange;
		yr:=Scroller^.YRange;
		op:=Lines^.Count;
		while not(eof(f)) do
			begin
				readln(f,zeile);
				Lines^.AtInsert(Lines^.Count,ChrNew(zeile));
				if length(TabXpand(zeile))>=xr then xr:=length(TabXpand(zeile))+1;
				inc(yr)
			end;
		close(f);
		LastMouse;
		UpdateSubTitle;
		Scroller^.SetRange(xr,yr);
		Scroller^.ScrollTo(0,op);
		ForceRedraw
	end;


procedure TTextWindow.Clear;

	begin
		Lines^.FreeAll;
		UpdateSubTitle;
		Scroller^.SetRange(0,0);
		ForceRedraw
	end;


procedure TTextWindow.SetFont(NewID,NewSize: integer);
	var dummy: integer;

	begin
		FontID:=vst_font(vdiHandle,NewID);
		if NewSize<1 then NewSize:=10;
		FontSize:=vst_point(vdiHandle,NewSize,Attr.charWidth,Attr.charHeight,Attr.boxWidth,Attr.boxHeight);
		Scroller^.SetUnits(Attr.boxWidth,Attr.boxHeight)
	end;


procedure TTextWindow.SetColor(NewColor: integer);

	begin
		Color:=NewColor;
		vst_color(vdiHandle,Color)
	end;


procedure TTextWindow.UpdateSubTitle;
	var n: longint;

	begin
		n:=GetNumLines;
		if Application^.Attr.Country=FRA then
			begin
				if n=1 then SetSubTitle(' 1 ligne')
				else
					SetSubTitle(' '+ltoa(n)+' lignes')
			end
		else if Application^.Attr.Country in [FRG,SWG] then
			begin
				if n=1 then SetSubTitle(' 1 Zeile')
				else
					SetSubTitle(' '+ltoa(n)+' Zeilen')
			end
		else
			begin
				if n=1 then SetSubTitle(' 1 line')
				else
					SetSubTitle(' '+ltoa(n)+' lines')
			end
	end;


function TTextWindow.TabXpand(s: string): string;
	var t: integer;

	begin
		if RealTabs then
			begin
				t:=pos(chr(HT),s);
				while t>0 do
					begin
						if TabSize>1 then
							s:=StrPLeft(s,t-1)+StrPSpace(TabSize-((t-1) mod TabSize))+StrPRight(s,length(s)-t)
						else
							s[t]:=' ';
						t:=pos(chr(HT),s)
					end
			end;
		TabXpand:=s
	end;


function TTextWindow.PrintFilter(s: string): string;

	procedure replace(i,o: char);
		var p: integer;

		begin
			p:=pos(i,s);
			while p>0 do
				begin
					s[p]:=o;
					p:=pos(i,s)
				end
		end;

	begin
		replace('û',#225);
		replace('›',#21);
		replace('|',#179);
{		replace('~',#);
		replace('[',#);
		replace(']',#);
		replace('@',#);
		replace(#123,#);
		replace(#125,#);
		replace('\',#); ... }
		PrintFilter:=s
	end;

{ *** TTEXTWINDOW *** }



{ *** Objekt TEDITWINDOW *** }

function TEditWindow.GetClassName: string;

	begin
		GetClassName:='EditWindow'
	end;

{ *** TEDITWINDOW *** }



{ *** Objekt THELPWINDOW *** }

function THelpWindow.GetClassName: string;

	begin
		GetClassName:='HelpWindow'
	end;

{ *** THELPWINDOW *** }



{ *** Objekt TINDICATORWINDOW *** }

function TIndicatorWindow.GetClassName: string;

	begin
		GetClassName:='IndicatorWindow'
	end;

{ *** TINDICATORWINDOW *** }



{ *** Objekt TSPECIALCHARACTERSWINDOW *** }

function TSpecialCharactersWindow.GetClassName: string;

	begin
		GetClassName:='SpecialCharactersWindow'
	end;


function TSpecialCharactersWindow.GetIconTitle: string;

	begin
		if Application^.Attr.Country=FRA then
			GetIconTitle:='Caractäres spÇciaux'
		else if (Application^.Attr.Country=FRG) or (Application^.Attr.Country=SWG) then
			GetIconTitle:='Sonderzeichen'
		else
			GetIconTitle:='Special Characters'
	end;


function TSpecialCharactersWindow.GetStyle: integer;

	begin
		GetStyle:=inherited GetStyle and not(INFO or FULLER or SIZER)
	end;


procedure TSpecialCharactersWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do
			begin
				Style:=Style and not(cs_QuitOnClose) or cs_WorkBackground;
				hCursor:=POINT_HAND
			end
	end;


procedure TSpecialCharactersWindow.SetupSize;

	begin
		inherited SetupSize;
		CalcWidth(SysInfo.Font.ID,SysInfo.Font.Point,false);
		GetSize(Work.W,Work.H);
		Work.X:=(Full.W-Work.W) shr 1;
		Work.Y:=(Full.H-Work.H) shr 1;
		Calc(WC_BORDER,Work,Curr)
	end;


procedure TSpecialCharactersWindow.Paint(var PaintInfo: TPaintStruct);
	var x,y,c,
	    dummy,
	    cx,cy: integer;

	begin
		inherited Paint(PaintInfo);
		vst_alignment(vdiHandle,TA_LEFT,TA_TOP,dummy,dummy);
		cy:=Work.Y+(boxheight shr 1);
		c:=32;
		for y:=0 to 13 do
			begin
				cx:=Work.X+(boxwidth shl 1);
				for x:=0 to 15 do
					begin
						v_gtext(vdiHandle,cx,cy,chr(c));
						inc(cx,boxwidth shl 1);
						inc(c)
					end;
				inc(cy,boxheight)
			end
	end;


procedure TSpecialCharactersWindow.WMClick(mX,mY,KStat: integer);
	var o1,g1,
	    u1,
	    dummy,
	    key,
	    x,y  : integer;
	    p    : PWindow;
	    pe   : PEvent;

	begin
		wind_update(BEG_UPDATE);
		u1:=DESK;
		wind_get(Attr.gemHandle,WF_TOP,o1,dummy,u1,dummy);
		if o1<0 then o1:=u1;
		p:=nil;
		if not(appl_xgetinfo(11,g1,dummy,dummy,dummy)) then g1:=0;
		repeat
			if o1<>Attr.gemHandle then p:=Application^.GetGPWindow(o1);
			if p=nil then
				if bTst(g1,16) then wind_get(o1,WF_OWNER,dummy,dummy,dummy,o1)
		until (p<>nil) or (o1=DESK) or not(bTst(g1,16));
		wind_update(END_UPDATE);
		if p=nil then Application^.Bing
		else
			begin
				dec(mX,Work.X+(boxwidth shr 1)+boxwidth);
				dec(mY,Work.Y+(boxheight shr 1));
				x:=mX div (boxwidth shl 1);
				y:=mY div boxheight;
				if (x<0) or (y<0) or (x>15) or (y>13) then
					begin
						Application^.Bing;
						exit
					end;
				key:=32+x+(y shl 4);
				pe:=p^.EventList;
				while pe<>nil do
					begin
						if pe^.TestKey(K_NORMAL,key) then exit;
						pe:=pe^.Next
					end;
				p^.WMKeyDown(K_NORMAL,key)
			end
	end;


procedure TSpecialCharactersWindow.WMDblClick(mX,mY,KStat: integer);

	begin
		WMClick(mX,mY,KStat);
		WMClosed
	end;


function TSpecialCharactersWindow.FontChanged(OrgID,AnID,ASize,AColor,BackColor,Effects,ARotation,ASkew,HorAlign,VertAlign,AWidth,TrackKern: integer; Size31: fix31; PairKern,cWnd: boolean): boolean;

	begin
		inherited FontChanged(OrgID,AnID,ASize,AColor,BackColor,Effects,ARotation,ASkew,HorAlign,VertAlign,AWidth,TrackKern,Size31,PairKern,cWnd);
		FontChanged:=true;
		CalcWidth(AnID,ASize,true);
		ForceRedraw
	end;


	{ private }


procedure TSpecialCharactersWindow.CalcWidth(ID,Pt: integer; resize: boolean);
	var cw,dummy,q: integer;
	    r         : GRECT;

	begin
		if ID<>0 then fontID:=ID;
		if Pt>0 then fontPt:=Max(4,Pt);
		vst_font(vdiHandle,fontID);
		vst_point(vdiHandle,fontPt,Attr.charWidth,Attr.charHeight,Attr.boxWidth,Attr.boxHeight);
		boxwidth:=0;
		for q:=33 to 126 do
			if vqt_width(vdiHandle,q,cw,dummy,dummy)=q then
				if cw>boxwidth then boxwidth:=cw;
		if boxwidth=0 then boxwidth:=Attr.boxWidth;
		boxheight:=Attr.boxheight;
		if resize then
			begin
				GetWork;
				r:=Work;
				GetSize(r.W,r.H);
				SetWork(r)
			end
	end;


procedure TSpecialCharactersWindow.GetSize(var width,height: integer);

	begin
		width:=35*boxwidth;
		height:=15*boxheight
	end;

{ *** TSPECIALCHARACTERSWINDOW *** }

end.