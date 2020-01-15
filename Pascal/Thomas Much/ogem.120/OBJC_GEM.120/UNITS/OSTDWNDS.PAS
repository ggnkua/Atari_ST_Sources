{**************************************
 *  O b j e c t G E M   Version 1.20  *
 *  Copyright 1992-94 by Thomas Much  *
 **************************************
 *       Unit  O S T D W N D S        *
 **************************************
 *    Softdesign Computer Software    *
 *    Thomas Much, Gerwigstraûe 46,   *
 *  76131 Karlsruhe, (0721) 62 28 41  *
 *         Thomas Much @ KA2          *
 *  UK48@ibm3090.rz.uni-karlsruhe.de  *
 **************************************
 *    erstellt am:        03.03.1994  *
 *    letztes Update am:  24.09.1994  *
 **************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

  ObjectGEM wird mit dem _vollstÑndigen_ Quelltext ausgeliefert, d.h.
  jeder kann sich die Unit selbst compilieren, womit die extrem lÑstigen
  KompatibilitÑtsprobleme mit den PP-Releases beseitigt sind.
  ObjectGEM ist und bleibt aber trotzdem SHAREWARE, d.h. wer die Biblio-
  thek regelmÑûig benutzt, muû sich REGISTRIEREN lassen. DafÅr gibt es
  die neueste Version und - gegen einen geringen Aufpreis - auch ein
  gedrucktes Handbuch.

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


{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

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
		SetFont(vqt_name(vdiHandle,1,dummy),10);
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

	var conterm : byte absolute $484;
	    oldct   : byte;
	    oldstack: longint;

	begin
		if Super(pointer(1))=0 then oldstack:=Super(nil)
    else
    	oldstack:=0;
    oldct:=conterm and 2;
    conterm:=conterm and not(2);
    if oldstack<>0 then Super(pointer(oldstack));
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
		if Super(pointer(1))=0 then oldstack:=Super(nil)
    else
    	oldstack:=0;
    conterm:=conterm or oldct;
    if oldstack<>0 then Super(pointer(oldstack))
	end;


procedure TTextWindow.AddLine(NewLine: string);
	var xr: integer;

	begin
		Lines^.AtInsert(Lines^.Count,ChrNew(NewLine));
		{ ... }
		UpdateSubTitle;
		if length(TabXpand(NewLine))>=Scroller^.XRange then xr:=length(TabXpand(NewLine))+1
		else
			xr:=Scroller^.XRange;
		Scroller^.SetRange(xr,Scroller^.YRange+1);
		Scroller^.ScrollTo(0,Lines^.Count);
		ForceRedraw
	end;


procedure TTextWindow.InsertLine(Index: longint; NewLine: string);
	var xr: integer;

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
	var p: PChar;

	begin
		GetLine:='';
		if (LineNumber>=0) and (LineNumber<Lines^.Count) then
			begin
				p:=Lines^.At(LineNumber);
				if p<>nil then GetLine:=StrPas(p)
			end
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
	    xr,yr,op: integer;
	    f       : text;

	begin
		if bTst(Attr.ExStyle,ws_ex_ReadOnly) then
			begin
				ext:=GetTitle;
				if length(ext)>0 then ext:='"'+ext+'"|';
				if (Application^.Attr.Country=FRG) or (Application^.Attr.Country=SWG) then
					Application^.Alert(@self,1,NOTE,ext+'Dieser Text ist schreibgeschÅtzt.','  &OK  ')
				else
					Application^.Alert(@self,1,NOTE,ext+'This text is read-only.','  &OK  ');
				exit
			end;
		if Clipboard=nil then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(false)) then exit;
				ext:=GetPriorityClipboardFormat('TXT.ASC');
				if length(ext)>0 then
					begin
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
		if Application^.Attr.Country in [FRG,SWG] then
			begin
				if Application^.Alert(@self,1,WAIT,ext+'Den ganzen Text ausdrucken?','  &Ja  | &Nein ')<>1 then exit
			end
		else
			if Application^.Alert(@self,1,WAIT,ext+'Print whole text?',' &Yes |  &No  ')<>1 then exit;
		_nochmal:
		if Cprnos=0 then
			begin
				if Application^.Attr.Country in [FRG,SWG] then
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
	    xr,yr,op: integer;

	begin
		if not(Exist(AFileName)) then exit;
		SetMouse(IDC_LOAD,nil);
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
		if Application^.Attr.Country in [FRG,SWG] then
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

end.