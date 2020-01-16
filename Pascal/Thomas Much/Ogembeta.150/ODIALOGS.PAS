{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *        Unit  O D I A L O G S         *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        13.07.1992  *
 *      letztes Update am:  07.10.1998  *
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

unit ODialogs;

interface

uses

	Strings,Tos,Gem,Objects,OTypes,OWindows;

type

	PScrollBar = ^TScrollBar;
	TScrollBar = object(TControl)
		public
		LineMagnitude,
		PageMagnitude,
		Size         : longint;
		TrackMode,
		IsHorizontal : boolean;
		constructor Init(AParent: PDialog; SIndx,DIndx,IIndx: integer; TheSize,TheRange: longint; Hlp: string);
		function TestIndex(AnIndx: integer): boolean; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
		procedure Work; virtual;
		procedure SetPosition(ThumbPos: longint); virtual;
		function GetPosition: longint; virtual;
		function DeltaPos(Delta: longint): longint; virtual;
		procedure SetRange(LoVal,HiVal: longint); virtual;
		function GetRange(var LoVal,HiVal: longint): longint; virtual;
		function GetSBoxMin: integer; virtual;
		private
		lowval,
		highval,
		SPos,
		Range   : longint;
		DecIndx,
		IncIndx : integer;
		initflag: boolean;
		DecAddr,
		IncAddr : PObj
	end;

	PGroupBox = ^TGroupBox;
	TGroupBox = object(TControl)
		public
		constructor Init(AParent: PDialog; AnIndx: integer; ATitle,Hlp: string);
		destructor Done; virtual;
		procedure SetText(ATextString: string); virtual;
		function GetText: string; virtual;
		procedure Paint; virtual;
		private
		Title    : PString;
		oldflags : word;
		oldobspec: longint
	end;

	PCheckBox = ^TCheckBox;
	TCheckBox = object(TButton)
		public
		constructor Init(AParent: PDialog; AnIndx: integer; UserDef: boolean; Hlp: string);
		function Install: boolean; virtual;
		procedure Deinstall; virtual;
		procedure SetShortCut(Key: char); virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure SetCheck(CheckFlag: integer); virtual;
		function GetCheck: integer; virtual;
		procedure Check; virtual;
		procedure Uncheck; virtual;
		procedure Toggle; virtual;
		function IsChecked: boolean; virtual;
	end;

	PTriState = ^TTriState;
	TTriState = object(TCheckBox)
		public
		constructor Init(AParent: PDialog; AnIndx: integer; Hlp: string);
		procedure Gray; virtual;
	end;

	PRadioButton = ^TRadioButton;
	TRadioButton = object(TCheckBox)
		public
		constructor Init(AParent: PDialog; AnIndx: integer; UserDef: boolean; Hlp: string);
		procedure SetState(StateFlag: integer); virtual;
		function Install: boolean; virtual;
	end;

	PScrollEdit = ^TScrollEdit;
	TScrollEdit = object(TEdit)
		public
		constructor Init(AParent: PDialog; AnIndx,ATextLen: integer; Hlp: string);
		destructor Done; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure SetCursor(CPos: integer); virtual;
		private
		optext,
		optmplt,
		opvalid,
		txt,
		tmplt     : pointer;
		VirtualLen,
		otxtlen,
		otmplen,
		ojust     : integer;
		xtedinfo  : XTED;
		function MagiCScrollEditLength: integer;
	end;

	PPasswordEdit = ^TPasswordEdit;
	TPasswordEdit = object(TEdit)
		public
		constructor Init(AParent: PDialog; AnIndx,ATextLen: integer; Hlp: string);
		function GetText: string; virtual;
		procedure SetText(ATextString: string); virtual;
		procedure Clear; virtual;
		procedure Edit; virtual;
		procedure Undo; virtual;
		procedure Paste; virtual;
		procedure Copy; virtual;
		procedure Cut; virtual;
		private
		password: string;
	end;

	PComboBox    = ^TComboBox;
	TComboBox    = object(TControl)
		public
		Popup       : PPopup;
		Edit        : PEdit;
		List        : PStringCollection;
		ChangeAlways,
		CenterX     : boolean;
		constructor Init(AParent: PDialog; AnIndx,CycleIndx,TitleIndx,ptIndx,popIndx,StartIndx: integer; Cycle,Editable: boolean; Hlp: string);
		constructor InitCollection(AParent: PDialog; AnIndx,CycleIndx,TitleIndx,MinColumns: integer; ACollection: PStringCollection; DisposeColl,Cycle,Editable: boolean; Hlp: string);
		destructor Done; virtual;
		function TestIndex(AnIndx: integer): boolean; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
		procedure Work; virtual;
		procedure SetState(StateFlag: integer); virtual;
		procedure SetText(ATextString: string); virtual;
		function GetText: string; virtual;
		procedure SetTitle(ATextString: string); virtual;
		function GetTitle: string; virtual;
		procedure Paint; virtual;
		procedure Hide(Draw: boolean); virtual;
		procedure Unhide; virtual;
		procedure SetShortCut(Key: char); virtual;
		function GetSelection: integer; virtual;
		procedure SetSelection(Sel: integer; Wrk: boolean); virtual;
		procedure ClearSelection(Wrk: boolean); virtual;
		function CreatePopup: boolean; virtual;
		procedure OpenPopup; virtual;
		procedure SetValue(Sel: integer); virtual;
		function GetEdit: PEdit; virtual;
		private
		cindx,
		tindx,
		pindx,
		tpindx,
		select,
		oldtype,
		oldttype,
		startidx,
		mincols   : integer;
		oldtobspec: longint;
		caddr,
		taddr     : PObj;
		cycl,
		initflag,
		lstdispose: boolean;
		usrtblk   : USERBLK;
		procedure commoninit(cycleindx,titleindx: integer; cycle,editable: boolean);
	end;

	PCard = ^TCard;
	TCard = object(TControl)
		public
		constructor Init(AParent: PDialog; CardIdx,TitleIdx,AGroup,AFlag: integer; Hlp: string);
		destructor Done; virtual;
		function TestIndex(AnIndx: integer): boolean; virtual;
		procedure Paint; virtual;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
		procedure HideCard(Draw: boolean); virtual;
		procedure UnhideCard; virtual;
		function IsCardHidden: boolean; virtual;
		procedure SetCheck(CheckFlag: integer); virtual;
		function GetCheck: integer; virtual;
		procedure Check; virtual;
		procedure Uncheck; virtual;
		procedure Toggle; virtual;
		function IsChecked: boolean; virtual;
		private
		oldflags,
		cindx,
		cflag,
		group   : integer;
		caddr   : PObj;
		cusrblk : USERBLK;
		procedure ActivateShortcut;
	end;

	PListBox     = ^TListBox;
	TListBox     = object(TControl)
		public
		List     : PStringCollection;
		ScrollBar: PScrollBar;
		Multiple : boolean;
		constructor Init(AParent: PDialog; AnIndx,SIndx,DIndx,IIndx: integer; ACollection: PStringCollection; DisposeColl: boolean; Hlp: string);
		destructor Done; virtual;
		procedure SetCollection(ACollection: PStringCollection); virtual;
		function TestIndex(AnIndx: integer): boolean; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
		function ExtFocusKey(Stat,Key: integer): boolean; virtual;
		procedure ExtFocusPaint(r: GRECT); virtual;
		procedure Work; virtual;
		function FlagKeyOf(Item: pointer): pointer; virtual;
		function GetSelection: integer; virtual;
		procedure SetSelection(Sel: integer); virtual;
		private
		oldptr    : PItemList;
		lstdispose,
		initflag  : boolean;
		nptr      : byte;
		lastsel   : integer;
		procedure filllist(draw: boolean; diff: integer);
	end;



implementation

uses

	OProcs;

const

	cbUnchecked = $1000;
	cbChecked   = $2000;
	cbGrayed    = $3000;
	cbFlags     = cbUnchecked or cbChecked or cbGrayed;
	cbType      = $4000;
	cbAll       = not(cbFlags or cbType);
	crdFirst    = $1000;
	crdLast     = $2000;
	crdFlags    = crdFirst or crdLast;
	POP_MAXROWS = 19;
	CARD_OFFS   =  2;
	COMBOCOL    = Black;

type

	PLBScrollBar = ^TLBScrollBar;
	TLBScrollBar = object(TScrollbar)
		lbox: PListBox;
		procedure Work; virtual;
	end;

function DrawCycleBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawGroupBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawCheckBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawRadioButton(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawComboTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawCardBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawCardTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;

var

	d_clip  : ARRAY_4;
	extent  : ARRAY_8;
	d_str,
	d_btn   : string;
	d_chr   : PChar;
	d_tx,
	d_ty,
	d_stat,
	d_br,
	d_scpos : integer;
	defcolfg: TCOLOR_ENTRY;


{ *** Objekt TSCROLLBAR *** }

constructor TScrollBar.Init(AParent: PDialog; SIndx,DIndx,IIndx: integer; TheSize,TheRange: longint; Hlp: string);

	begin
		if not(inherited Init(AParent,SIndx,Hlp)) then fail;
		Style:=cs_ScrollBar;
		ID:=id_NoExit;
		TrackMode:=false;
		initflag:=true;
		DecIndx:=DIndx;
		IncIndx:=IIndx;
		DecAddr:=@Parent^.DlgTree^[DecIndx];
		IncAddr:=@Parent^.DlgTree^[IncIndx];
		if (DecAddr=nil) or (IncAddr=nil) then
			begin
				inherited Done;
				fail
			end;
		if ((DecAddr^.ob_type and $ff)<>G_BOXCHAR) or ((IncAddr^.ob_type and $ff)<>G_BOXCHAR) or
		   ((ObjAddr^.ob_type and $ff)<>G_BOX) or (ObjAddr^.ob_head=-1) then
			begin
				inherited Done;
				fail
			end;
		if ObjAddr^.ob_height>ObjAddr^.ob_width then
			begin
				DecAddr^.ob_spec.index:=(DecAddr^.ob_spec.index and $00ffffff) or ($01000000);
				IncAddr^.ob_spec.index:=(IncAddr^.ob_spec.index and $00ffffff) or ($02000000);
				Parent^.DlgTree^[ObjAddr^.ob_head].ob_width:=ObjAddr^.ob_width;
				Parent^.DlgTree^[ObjAddr^.ob_head].ob_x:=0;
				Style:=Style or sbs_Vert;
				IsHorizontal:=false
			end
		else
			begin
				DecAddr^.ob_spec.index:=(DecAddr^.ob_spec.index and $00ffffff) or ($04000000);
				IncAddr^.ob_spec.index:=(IncAddr^.ob_spec.index and $00ffffff) or ($03000000);
				Parent^.DlgTree^[ObjAddr^.ob_head].ob_height:=ObjAddr^.ob_height;
				Parent^.DlgTree^[ObjAddr^.ob_head].ob_y:=0;
				Style:=Style or sbs_Horz;
				IsHorizontal:=true
			end;
		DecAddr^.ob_flags:=(DecAddr^.ob_flags and not(SELECTABLE or DEFAULT or F_EXIT or EDITABLE or RBUTTON)) or TOUCHEXIT;
		IncAddr^.ob_flags:=(IncAddr^.ob_flags and not(SELECTABLE or DEFAULT or F_EXIT or EDITABLE or RBUTTON)) or TOUCHEXIT;
		ObjAddr^.ob_flags:=(ObjAddr^.ob_flags and not(SELECTABLE or DEFAULT or F_EXIT or EDITABLE or RBUTTON)) or TOUCHEXIT;
		Parent^.DlgTree^[ObjAddr^.ob_head].ob_flags:=(Parent^.DlgTree^[ObjAddr^.ob_head].ob_flags and not(SELECTABLE or DEFAULT or F_EXIT or EDITABLE or RBUTTON)) or TOUCHEXIT;
		Size:=Max(1,TheSize);
		PageMagnitude:=Size;
		LineMagnitude:=1;
		SPos:=-1;
		Range:=Max(1,TheRange-1)+2;
		SetRange(0,Range-2);
		initflag:=false
	end;


function TScrollBar.TestIndex(AnIndx: integer): boolean;

	begin
		TestIndex:=((AnIndx=ObjIndx) or (AnIndx=DecIndx) or (AnIndx=IncIndx) or
		            (AnIndx=ObjAddr^.ob_head))
	end;


function TScrollBar.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		case TransferFlag of
			tf_SetData: with PScrollBarTransferRec(DataPtr)^ do
										begin
											SetRange(LowValue,HighValue);
											SetPosition(Position)
										end;
			tf_GetData: with PScrollBarTransferRec(DataPtr)^ do
										begin
											LowValue:=lowval;
											HighValue:=highval;
											Position:=GetPosition
										end
		end;
		Transfer:=sizeof(TScrollBarTransferRec)
	end;


procedure TScrollBar.Changed(AnIndx: integer; DblClick: boolean);
	var sp,old,dif,dummy: longint;
	    mx,my,ox,oy,oldx,
	    px,py,ms,oldy   : integer;
	    less            : boolean;

	begin
		sp:=SPos;
		if AnIndx=DecIndx then
			begin
				if DblClick then sp:=0
				else
					dec(sp,LineMagnitude)
			end
		else
			if AnIndx=IncIndx then
				begin
					if DblClick then sp:=Range
					else
						inc(sp,LineMagnitude)
				end
			else
				if AnIndx=ObjIndx then
					begin
						graf_mkstate(mx,my,ox,ox);
						objc_offset(Parent^.DlgTree,ObjAddr^.ob_head,ox,oy);
						if IsHorizontal then less:=(mx<ox)
						else
							less:=(my<oy);
						if less then
							begin
								if DblClick then sp:=0
								else
									dec(sp,PageMagnitude)
							end
						else
							begin
								if DblClick then sp:=Range
								else
									inc(sp,PageMagnitude)
							end
					end
				else
					if TrackMode then
						begin
							wind_update(BEG_UPDATE);
							wind_update(BEG_MCTRL);
							graf_mouse(FLAT_HAND,nil);
							old:=sp;
							graf_mkstate(oldx,oldy,mx,mx);
							repeat
								graf_mkstate(mx,my,ms,ox);
								if (Range>Size) then
									begin
										if IsHorizontal then dummy:=sp+round((longint(Range-Size)*longint(mx-oldx))/longint(ObjAddr^.ob_width-Parent^.DlgTree^[ObjAddr^.ob_head].ob_width))
										else
											dummy:=sp+round((longint(Range-Size)*longint(my-oldy))/longint(ObjAddr^.ob_height-Parent^.DlgTree^[ObjAddr^.ob_head].ob_height));
										if dummy+Size>Range then dummy:=Range-Size;
										if dummy<0 then dummy:=0;
										if old<>dummy then
											begin
												old:=dummy;
												SetPosition(old+lowval)
											end
									end
							until ms=0;
							graf_mouse(ARROW,nil);
							wind_update(END_MCTRL);
							wind_update(END_UPDATE);
							exit
						end
					else
						begin
							objc_offset(Parent^.DlgTree,ObjAddr^.ob_head,ox,oy);
							objc_offset(Parent^.DlgTree,ObjIndx,px,py);
							wind_update(BEG_UPDATE);
							graf_dragbox(Parent^.DlgTree^[ObjAddr^.ob_head].ob_width,Parent^.DlgTree^[ObjAddr^.ob_head].ob_height,ox,oy,px,py,ObjAddr^.ob_width,ObjAddr^.ob_height,mx,my);
							if (mx<>ox) or (my<>oy) then
								begin
									dif:=Max(0,Range-Size);
									if IsHorizontal then
										begin
											ox:=ObjAddr^.ob_width-Parent^.DlgTree^[ObjAddr^.ob_head].ob_width;
											if ox<1 then sp:=0
											else
												sp:=((mx-px)*dif) div ox;
										end
									else
										begin
											oy:=ObjAddr^.ob_height-Parent^.DlgTree^[ObjAddr^.ob_head].ob_height;
											if oy<1 then sp:=0
											else
												sp:=((my-py)*dif) div oy;
										end
								end;
							wind_update(END_UPDATE)
						end;
		SetPosition(sp+lowval)
	end;


procedure TScrollBar.Work;

	begin
	end;


procedure TScrollBar.SetPosition(ThumbPos: longint);
	var dif: longint;

	begin
		dec(ThumbPos,lowval);
		dif:=Range-Size;
		if ThumbPos+Size>Range then ThumbPos:=dif;
		if ThumbPos<0 then ThumbPos:=0;
		if SPos<>ThumbPos then
			begin
				SPos:=ThumbPos;
				if dif<1 then dif:=1;
				if IsHorizontal then
					Parent^.DlgTree^[ObjAddr^.ob_head].ob_x:=((ObjAddr^.ob_width-Parent^.DlgTree^[ObjAddr^.ob_head].ob_width)*SPos) div dif
				else
					Parent^.DlgTree^[ObjAddr^.ob_head].ob_y:=((ObjAddr^.ob_height-Parent^.DlgTree^[ObjAddr^.ob_head].ob_height)*SPos) div dif;
				if not(initflag) then
					begin
						Paint;
						Work
					end
			end
	end;


function TScrollBar.GetPosition: longint;

	begin
		GetPosition:=SPos+lowval
	end;


function TScrollBar.DeltaPos(Delta: longint): longint;

	begin
		if Delta<>0 then SetPosition(SPos+lowval+Delta);
		DeltaPos:=SPos+lowval
	end;


procedure TScrollBar.SetRange(LoVal,HiVal: longint);
	var sp,s,TheRange: longint;

	begin
		TheRange:=HiVal+1-LoVal;
		if TheRange<1 then
			begin
				HiVal:=LoVal+1;
				TheRange:=1
			end;
		lowval:=LoVal;
		highval:=HiVal;
		if Range<>TheRange then
			begin
				Range:=TheRange;
				if IsHorizontal then
					begin
						s:=(ObjAddr^.ob_width*Size) div Range;
						if s>ObjAddr^.ob_width then s:=ObjAddr^.ob_width;
						if s<GetSBoxMin then s:=GetSBoxMin;
						Parent^.DlgTree^[ObjAddr^.ob_head].ob_width:=s
					end
				else
					begin
						s:=(ObjAddr^.ob_height*Size) div Range;
						if s>ObjAddr^.ob_height then s:=ObjAddr^.ob_height;
						if s<GetSBoxMin then s:=GetSBoxMin;
						Parent^.DlgTree^[ObjAddr^.ob_head].ob_height:=s
					end;
				sp:=SPos;
				SetPosition(SPos+lowval);
				if sp=SPos then
					if not(initflag) then
						begin
							Paint;
							Work
						end
			end
	end;


function TScrollBar.GetRange(var LoVal,HiVal: longint): longint;

	begin
		LoVal:=lowval;
		HiVal:=highval;
		GetRange:=Range+1
	end;


function TScrollBar.GetSBoxMin: integer;

	begin
		GetSBoxMin:=8
	end;

{ *** TSCROLLBAR *** }



{ *** Objekt TGROUPBOX *** }

constructor TGroupBox.Init(AParent: PDialog; AnIndx: integer; ATitle,Hlp: string);
	var nxo,pixdif: integer;

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		Style:=cs_GroupBox or gbs_Recessed;
		Title:=nil;
		if (ObjAddr^.ob_type and $ff)=G_BOX then
			begin
				if Application^.ExtObjects then
					begin
						if length(ATitle)>0 then ATitle:=' '+ATitle+' ';
						pixdif:=Application^.Attr.charSHeight shr 1;
						with ObjAddr^ do
							begin
								ob_type:=G_BUTTON;
								ob_flags:=(ob_flags and not(RBUTTON or EDITABLE or SELECTABLE or DEFAULT or F_EXIT or TOUCHEXIT)) or FL3DBAK;
								ob_state:=(ob_state and $00ff) or WHITEBAK or $fe00;
								ob_spec.free_string:=ChrNew(ATitle);
								dec(ob_y,pixdif);
								inc(ob_height,pixdif);
								nxo:=ob_head
							end;
						if nxo<>-1 then
							while nxo<>ObjIndx do
								begin
									inc(Parent^.DlgTree^[nxo].ob_y,pixdif);
									nxo:=Parent^.DlgTree^[nxo].ob_next
								end
					end
				else
					begin
						Title:=NewStr(ATitle);
						with ObjAddr^ do
							begin
								oldflags:=ob_flags;
								oldobspec:=ob_spec.index;
								UsrBlk.ub_parm:=longint(Title);
								UsrBlk.ub_code:=@DrawGroupBox;
								ob_flags:=ob_flags and not(RBUTTON or EDITABLE or SELECTABLE or DEFAULT or F_EXIT or TOUCHEXIT);
								ob_type:=G_USERDEF;
								ob_spec.user_blk:=@UsrBlk;
								UsrDef:=true
							end
					end
			end
		else
			begin
				inherited Done;
				fail
			end
	end;


destructor TGroupBox.Done;

	begin
		if Application^.ExtObjects then ChrDispose(PChar(ObjAddr^.ob_spec.free_string))
		else
			begin
				with ObjAddr^ do
					begin
						ob_spec.index:=oldobspec;
						ob_type:=G_BOX;
						ob_flags:=oldflags
					end;
				DisposeStr(Title)
			end;
		inherited Done
	end;


procedure TGroupBox.SetText(ATextString: string);

	begin
		if Application^.ExtObjects then
			begin
				if length(ATextString)>0 then ATextString:=' '+ATextString+' ';
				ChrDispose(PChar(ObjAddr^.ob_spec.free_string));
				ObjAddr^.ob_spec.free_string:=ChrNew(ATextString)
			end
		else
			begin
				DisposeStr(Title);
				Title:=NewStr(ATextString);
				UsrBlk.ub_parm:=longint(Title)
			end;
		Paint
	end;


function TGroupBox.GetText: string;

	begin
		if Application^.ExtObjects then GetText:=StrPPas(ObjAddr^.ob_spec.free_string)
		else
			if Title<>nil then GetText:=Title^
			else
				GetText:=''
	end;


procedure TGroupBox.Paint;
	var ox,oy: integer;
	    r    : GRECT;

	begin
		if Application^.ExtObjects and (ObjIndx>0) then
			begin
				if not(IsHidden) then
					begin
						objc_offset(Parent^.DlgTree,ObjIndx,r.X,r.Y);
						r.W:=ObjAddr^.ob_width;
						r.H:=ObjAddr^.ob_height;
						Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
					end
			end
		else
			inherited Paint
	end;

{ *** TGROUPBOX ***}



{ *** Objekt TCHECKBOX *** }

constructor TCheckBox.Init(AParent: PDialog; AnIndx: integer; UserDef: boolean; Hlp: string);

	begin
		if not(inherited Init(AParent,AnIndx,id_No,UserDef,Hlp)) then fail;
		EnableTransfer;
		Style:=cs_CheckBox;
		if UsrDef then
			with ObjAddr^ do
				begin
					ob_type:=ob_type and cbAll;
					if bTst(ob_state,SELECTED) then ob_type:=ob_type or cbChecked
					else
						ob_type:=ob_type or cbUnchecked
				end
	end;


function TCheckBox.Install: boolean;

	begin
		with ObjAddr^ do
			begin
				if Application^.ExtObjects then
					begin
						UsrDef:=false;
					  ob_type:=G_BUTTON;
					  ob_flags:=(ob_flags and not(RBUTTON)) or FL3DBAK;
					  ob_state:=ob_state or WHITEBAK or UNDERLINE or XSTATE;
					end
				else
					begin
						if (ob_type and $ff)=G_BUTTON then
							begin
								UsrBlk.ub_parm:=ob_spec.index;
								UsrBlk.ub_code:=@DrawCheckBox;
								ob_flags:=(ob_flags and not(RBUTTON or EDITABLE)) or SELECTABLE;
								ob_state:=ob_state and not(CHECKED or OUTLINED or SHADOWED);
								ob_type:=G_USERDEF;
								ob_spec.user_blk:=@UsrBlk
							end
						else
							UsrDef:=false
					end
			end;
		Install:=true
	end;


procedure TCheckBox.Deinstall;

	begin
	end;


procedure TCheckBox.SetShortCut(Key: char);
	var idx: integer;

	begin
		inherited SetShortCut(Key);
		if Application^.ExtObjects and not(UsrDef) then
			with ObjAddr^ do
				begin
					if Key=#0 then ob_state:=ob_state or $ff00
					else
						begin
							idx:=pos(upcase(Key),StrPUpper(GetText));
							if idx=0 then ob_state:=ob_state or $ff00
							else
								ob_state:=(ob_state and $00ff) or $8000 or ((idx-1) shl 8)
						end
				end
	end;


function TCheckBox.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		case TransferFlag of
			tf_SetData: SetCheck(PInteger(DataPtr)^);
			tf_GetData: PInteger(DataPtr)^:=GetCheck
		end;
		Transfer:=2
	end;


procedure TCheckBox.SetCheck(CheckFlag: integer);

	begin
		if CheckFlag=bf_Grayed then
			if not(bTst(Style,cs_3State)) then CheckFlag:=bf_Unchecked;
		if GetCheck<>CheckFlag then
			begin
				with ObjAddr^ do
					if UsrDef then
						case CheckFlag of
							bf_Unchecked: begin
															ob_type:=(ob_type and not(cbFlags)) or cbUnchecked;
															ob_state:=ob_state and not(SELECTED)
														end;
							bf_Checked:   begin
															ob_type:=(ob_type and not(cbFlags)) or cbChecked;
															ob_state:=ob_state or SELECTED
														end;
							bf_Grayed:    ob_type:=ob_type or cbGrayed
						end
					else
						case CheckFlag of
							bf_Unchecked: ob_state:=ob_state and not(SELECTED)
						else
							ob_state:=ob_state or SELECTED
						end;
				Paint
			end
	end;


function TCheckBox.GetCheck: integer;

	begin
		with ObjAddr^ do
			if UsrDef then
				case (ob_type and cbFlags) of
					cbUnChecked: GetCheck:=bf_Unchecked;
					cbChecked  : GetCheck:=bf_Checked;
					cbGrayed   : GetCheck:=bf_Grayed
				else
					GetCheck:=bf_Unchecked
				end
			else
				begin
					if bTst(ob_state,SELECTED) then GetCheck:=bf_Checked
					else
						GetCheck:=bf_Unchecked
				end
	end;


procedure TCheckBox.Check;

	begin
		SetCheck(bf_Checked)
	end;


procedure TCheckBox.Uncheck;

	begin
		SetCheck(bf_Unchecked)
	end;


procedure TCheckBox.Toggle;

	begin
		case GetCheck of
			bf_Unchecked: SetCheck(bf_Checked);
			bf_Checked:   SetCheck(bf_Grayed);
			bf_Grayed:    SetCheck(bf_Unchecked)
		end
	end;


function TCheckBox.IsChecked: boolean;

	begin
		IsChecked:=(GetCheck=bf_Checked)
	end;

{ *** TCHECKBOX *** }



{ *** Objekt TTRISTATE *** }

constructor TTriState.Init(AParent: PDialog; AnIndx: integer; Hlp: string);
	var oldext: boolean;

	begin
		oldext:=Application^.ExtObjects;
		Application^.ExtObjects:=false;
		if not(inherited Init(AParent,AnIndx,true,Hlp)) then fail;
		Application^.ExtObjects:=oldext;
		Style:=cs_3State;
		with ObjAddr^ do ob_type:=ob_type or cbType
	end;


procedure TTriState.Gray;

	begin
		SetCheck(bf_Grayed)
	end;

{ *** TTRISTATE ***}



{ *** Objekt TRADIOBUTTON *** }

constructor TRadioButton.Init(AParent: PDialog; AnIndx: integer; UserDef: boolean; Hlp: string);

	begin
		if not(inherited Init(AParent,AnIndx,UserDef,Hlp)) then fail;
		Style:=cs_RadioButton
	end;


procedure TRadioButton.SetState(StateFlag: integer);

	begin
		if GetState<>StateFlag then
			begin
				if StateFlag=bf_Disabled then Uncheck;
				inherited SetState(StateFlag)
			end
	end;


function TRadioButton.Install: boolean;

	begin
		with ObjAddr^ do
			begin
				if Application^.ExtObjects then
					begin
						UsrDef:=false;
					  ob_type:=G_BUTTON;
					  ob_flags:=ob_flags or RBUTTON or FL3DBAK;
			  		ob_state:=ob_state or WHITEBAK or UNDERLINE or XSTATE;
					end
				else
					begin
						if (ob_type and $ff)=G_BUTTON then
							begin
								UsrBlk.ub_parm:=ob_spec.index;
								UsrBlk.ub_code:=@DrawRadioButton;
								ob_flags:=(ob_flags and not(EDITABLE)) or RBUTTON or SELECTABLE;
								ob_state:=ob_state and not(CROSSED or CHECKED or OUTLINED or SHADOWED);
								ob_type:=G_USERDEF;
								ob_spec.user_blk:=@UsrBlk
							end
						else
							UsrDef:=false
					end
			end;
		Install:=true
	end;

{ *** TRADIOBUTTON *** }



{ *** Objekt TSCROLLEDIT *** }

constructor TScrollEdit.Init(AParent: PDialog; AnIndx,ATextLen: integer; Hlp: string);
	var t : TEDINFOPtr;
	    el: integer;

	begin
		if not(inherited Init(AParent,AnIndx,ATextLen,Hlp)) then fail;
		el:=MagiCScrollEditLength;
		VirtualLen:=ATextLen;
		if el=0 then
			begin
				txt:=nil;
				tmplt:=nil
			end
		else
			begin
				TextLen:=Min(Max(ATextLen,TextLen),el);
				getmem(txt,TextLen);
				getmem(tmplt,TextLen);
				if (txt=nil) or (tmplt=nil) then
					begin
						if txt<>nil then freemem(txt,TextLen);
						if tmplt<>nil then freemem(tmplt,TextLen);
						fail
					end;
				t:=ObjAddr^.ob_spec.ted_info;
				ojust:=t^.te_just;
				otxtlen:=t^.te_txtlen;
				otmplen:=t^.te_tmplen;
				optmplt:=t^.te_ptmplt;
				opvalid:=t^.te_pvalid;
				optext:=t^.te_ptext;
				t^.te_just:=TE_LEFT;
				StrCopy(txt,t^.te_ptext);
				t^.te_ptext:=txt;
				fillchar(tmplt^,TextLen,#0);
				fillchar(tmplt^,TextLen-1,'_');
				xtedinfo.xte_ptmplt:=tmplt;
				xtedinfo.xte_pvalid:=t^.te_pvalid;
				xtedinfo.xte_vislen:=t^.te_tmplen-1;
				xtedinfo.xte_scroll:=0;
				t^.te_tmplen:=TextLen;
				t^.te_ptmplt:=nil;
				t^.te_pvalid:=@xtedinfo;
				t^.te_txtlen:=t^.te_tmplen
			end
	end;


destructor TScrollEdit.Done;
	var t: TEDINFOPtr;

	begin
		if MagiCScrollEditLength>0 then
			begin
				t:=ObjAddr^.ob_spec.ted_info;
				t^.te_just:=ojust;
				t^.te_ptext:=optext;
				t^.te_txtlen:=otxtlen;
				t^.te_tmplen:=otmplen;
				t^.te_ptmplt:=optmplt;
				t^.te_pvalid:=opvalid;
				if txt<>nil then freemem(txt,TextLen);
				if tmplt<>nil then freemem(tmplt,TextLen)
			end;
		inherited Done
	end;


function TScrollEdit.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		inherited Transfer(DataPtr,TransferFlag);
		if odd(VirtualLen) then Transfer:=VirtualLen+1
		else
			Transfer:=VirtualLen
	end;


procedure TScrollEdit.SetCursor(CPos: integer);
	var maxidx: integer;

	begin
		maxidx:=StrLen(ObjAddr^.ob_spec.ted_info^.te_ptext);
		if (CPos<0) or (CPos>maxidx) then CPos:=maxidx;
		if CPos<=xtedinfo.xte_vislen then xtedinfo.xte_scroll:=0
		else
			xtedinfo.xte_scroll:=CPos-xtedinfo.xte_vislen;
		inherited SetCursor(CPos)
	end;


	{ private }


function TScrollEdit.MagiCScrollEditLength: integer;

	begin
		if MagiCDate>=$19970926 then MagiCScrollEditLength:=256
		else
			if MagiCDate>=$19950829 then MagiCScrollEditLength:=126
			else
				MagiCScrollEditLength:=0
	end;

{ *** TSCROLLEDIT *** }



{ *** Objekt TPASSWORDEDIT *** }

constructor TPasswordEdit.Init(AParent: PDialog; AnIndx,ATextLen: integer; Hlp: string);

	begin
		password:='';
		if not(inherited Init(AParent,AnIndx,ATextLen,Hlp)) then fail;
		Style:=(Style and not(es_Undo)) or es_Password;
		SetText('')
	end;


function TPasswordEdit.GetText: string;

	begin
		GetText:=password
	end;


procedure TPasswordEdit.SetText(ATextString: string);

	begin
		password:=ATextString;
		inherited SetText(StrPFill(length(password),'*'))
	end;


procedure TPasswordEdit.Clear;

	begin
		inherited Clear;
		password:=''
	end;


procedure TPasswordEdit.Edit;
	var txt: string;
	    q  : integer;

	begin
		txt:=inherited GetText;
		if length(txt)=0 then password:=''
		else
			if length(txt)>length(password) then
				begin
					q:=Max(GetCursor-1,0);
					password:=StrPLeft(password,q)+txt[q+1]+StrPRight(password,length(password)-q)
				end
	end;


procedure TPasswordEdit.Undo;

	begin
		Application^.Bing
	end;


procedure TPasswordEdit.Paste;

	begin
		Application^.Bing
	end;


procedure TPasswordEdit.Copy;

	begin
		Application^.Bing
	end;


procedure TPasswordEdit.Cut;

	begin
		Application^.Bing
	end;

{ *** TPASSWORDEDIT *** }



{ *** Objekt TCOMBOBOX *** }

constructor TComboBox.Init(AParent: PDialog; AnIndx,CycleIndx,TitleIndx,ptIndx,popIndx,StartIndx: integer; Cycle,Editable: boolean; Hlp: string);

	begin
		taddr:=nil;
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		commoninit(CycleIndx,TitleIndx,Cycle,Editable);
		startidx:=StartIndx;
		pindx:=popIndx;
		tpindx:=ptIndx;
		SetSelection(0,false);
		initflag:=false
	end;


constructor TComboBox.InitCollection(AParent: PDialog; AnIndx,CycleIndx,TitleIndx,MinColumns: integer; ACollection: PStringCollection; DisposeColl,Cycle,Editable: boolean; Hlp: string);

	begin
		taddr:=nil;
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		commoninit(CycleIndx,TitleIndx,Cycle,Editable);
		lstdispose:=DisposeColl;
		List:=ACollection;
		mincols:=MinColumns;
		SetSelection(0,false);
		initflag:=false
	end;


destructor TComboBox.Done;

	begin
		if Popup<>nil then Popup^.Free;
		if Edit<>nil then Edit^.Free;
		if taddr<>nil then
			with taddr^ do
				begin
					if Application^.ExtObjects then ChrDispose(PChar(ob_spec.free_string))
					else
						ChrDispose(PChar(usrtblk.ub_parm));
					ob_type:=oldttype;
					ob_spec.index:=oldtobspec
				end;
		if UsrDef then
			with caddr^ do
				begin
					ob_spec.index:=UsrBlk.ub_parm;
					ob_type:=oldtype
				end;
		inherited Done
	end;


function TComboBox.TestIndex(AnIndx: integer): boolean;

	begin
		TestIndex:=(((AnIndx=ObjIndx) and (Edit=nil)) or (AnIndx=cindx) or (AnIndx=tindx))
	end;


function TComboBox.Transfer(DataPtr: pointer; TransferFlag: word): word;
	var offs: word;

	begin
		if Edit<>nil then
			begin
				offs:=Edit^.Transfer(DataPtr,TransferFlag);
				inc(longint(DataPtr),longint(offs))
			end
		else
			offs:=0;
		case TransferFlag of
		tf_SetData:
			SetSelection(PInteger(DataPtr)^,true);
		tf_GetData:
			PInteger(DataPtr)^:=GetSelection
		end;
		Transfer:=offs+2
	end;


procedure TComboBox.Changed(AnIndx: integer; DblClick: boolean);
	var res,xof,
	    yof,q  : integer;
	    r      : GRECT;

	begin
		if AnIndx=cindx then
			begin
				if cycl then
					begin
						if (kbshift(-1) and K_SHIFT)>0 then SetSelection(select-1,true)
						else
							SetSelection(select+1,true);
						exit
					end
				else
					if caddr<>nil then
						if not(bTst(caddr^.ob_state,SELECTED)) then exit
			end;
		if not(CreatePopup) then exit;
		OpenPopup;
		if taddr<>nil then
			begin
				taddr^.ob_state:=taddr^.ob_state or SELECTED;
				objc_offset(Parent^.DlgTree,tindx,r.X,r.Y);
				r.W:=taddr^.ob_width;
				r.H:=taddr^.ob_height;
				Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
			end;
		if not(cycl) then
			if AnIndx=tindx then
				if caddr<>nil then
					begin
						with caddr^ do ob_state:=ob_state or SELECTED;
						Parent^.ObjcPaint(cindx,false)
					end;
		objc_offset(Parent^.DlgTree,ObjIndx,xof,yof);
		with Popup^ do
			begin
				pX:=xof;
				if AnIndx=ObjIndx then
					begin
						pY:=yof;
						q:=select-GetOffset;
						if (q>=0) and (q<pRows) then
							begin
								dec(pY,PopTree^[PopTree^[pStart].ob_head+q].ob_y);
								if CenterX then dec(pX,PopTree^[PopTree^[pStart].ob_head+q].ob_x)
							end
					end
				else
					begin
						pY:=yof+ObjAddr^.ob_height+2;
						if PopTree^[ROOT].ob_height+pY>Application^.Attr.MaxPY then pY:=yof-PopTree^[ROOT].ob_height-2
					end;
				res:=Execute
			end;
		if not(cycl) then
			if AnIndx=tindx then
				if caddr<>nil then
					begin
						with caddr^ do ob_state:=ob_state and not(SELECTED);
						Parent^.ObjcPaint(cindx,false)
					end;
		if res>=0 then SetSelection(res,true);
		if taddr<>nil then
			begin
				taddr^.ob_state:=taddr^.ob_state and not(SELECTED);
				Paint
			end
	end;


procedure TComboBox.Work;

	begin
	end;


procedure TComboBox.SetState(StateFlag: integer);

	begin
		if GetState<>StateFlag then
			begin
				if StateFlag=bf_Disabled then
					begin
						if taddr<>nil then with taddr^ do ob_state:=ob_state or DISABLED;
						if caddr<>nil then with caddr^ do ob_state:=ob_state or DISABLED
					end
				else
					begin
						if taddr<>nil then with taddr^ do ob_state:=ob_state and not(DISABLED);
						if caddr<>nil then with caddr^ do ob_state:=ob_state and not(DISABLED)
					end
			end;
		inherited SetState(StateFlag)
	end;


procedure TComboBox.SetText(ATextString: string);
	var typ: integer;
	    adr: PChar;

	begin
		StrPTrim(ATextString);
		if Edit<>nil then Edit^.SetText(ATextString)
		else
			begin
				adr:=nil;
				typ:=ObjAddr^.ob_type and $ff;
				if (typ=G_BUTTON) or (typ=G_STRING) or (typ=G_TITLE) then adr:=ObjAddr^.ob_spec.free_string;
				if adr<>nil then StrPCopy(adr,ATextString)
				else
					if (typ=G_TEXT) or (typ=G_BOXTEXT) or (typ=G_FTEXT) or (typ=G_FBOXTEXT) then
						StrPCopy(ObjAddr^.ob_spec.ted_info^.te_ptext,StrPLeft(ATextString,ObjAddr^.ob_spec.ted_info^.te_txtlen-1))
			end;
		Paint
	end;


function TComboBox.GetText: string;
	var typ: integer;

	begin
		if Edit<>nil then GetText:=Edit^.GetText
		else
			begin
				typ:=ObjAddr^.ob_type and $ff;
				if (typ=G_BUTTON) or (typ=G_STRING) or (typ=G_TITLE) then GetText:=StrPas(ObjAddr^.ob_spec.free_string)
				else
					if (typ=G_TEXT) or (typ=G_BOXTEXT) or (typ=G_FTEXT) or (typ=G_FBOXTEXT) then
						GetText:=StrPas(ObjAddr^.ob_spec.ted_info^.te_ptext)
					else
						GetText:=''
			end
	end;


procedure TComboBox.SetTitle(ATextString: string);
	var ot : integer;
	    drw: boolean;
	    key: char;

	begin
		if taddr=nil then exit;
		if Application^.ExtObjects then
			begin
				drw:=(taddr^.ob_spec.index<>0);
				ChrDispose(PChar(taddr^.ob_spec.free_string))
			end
		else
			begin
				drw:=(usrtblk.ub_parm<>0);
				ChrDispose(PChar(usrtblk.ub_parm))
			end;
		StrPTrim(ATextString);
		ot:=pos('&',ATextString);
		if (ot>0) and (ot<length(ATextString)) then key:=ATextString[ot+1]
		else
			key:=#0;
		if Application^.ExtObjects then
			begin
				if (ot>0) and (ot<length(ATextString)) then ATextString:=StrPLeft(ATextString,ot-1)+StrPRight(ATextString,length(ATextString)-ot);
				taddr^.ob_spec.free_string:=ChrNew(ATextString)
			end
		else
			usrtblk.ub_parm:=longint(ChrNew(ATextString));
		SetShortCut(key);
		if drw then Paint
	end;


function TComboBox.GetTitle: string;

	begin
		if taddr=nil then GetTitle:=''
		else
			if Application^.ExtObjects then GetTitle:=StrPPas(taddr^.ob_spec.free_string)
			else
				GetTitle:=StrPPas(PChar(usrtblk.ub_parm))
	end;


procedure TComboBox.Paint;
	var r: GRECT;

	begin
		if IsHidden then exit;
		if taddr<>nil then
			begin
				objc_offset(Parent^.DlgTree,tindx,r.X,r.Y);
				r.W:=taddr^.ob_width;
				r.H:=taddr^.ob_height;
				Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
			end;
		if Edit<>nil then Edit^.Paint
		else
			inherited Paint;
		if cindx>0 then Parent^.ObjcPaint(cindx,bTst(Flags,wb_Lazy))
	end;


procedure TComboBox.Hide(Draw: boolean);
	var valid: boolean;
	    ox,oy: integer;
	    r    : GRECT;

	begin
		valid:=not(IsHidden) and Draw;
		with ObjAddr^ do ob_flags:=ob_flags or HIDETREE;
		if taddr<>nil then taddr^.ob_flags:=taddr^.ob_flags or HIDETREE;
		if caddr<>nil then caddr^.ob_flags:=caddr^.ob_flags or HIDETREE;
		if valid then
			begin
				if taddr<>nil then
					begin
						objc_offset(Parent^.DlgTree,tindx,r.X,r.Y);
						r.W:=taddr^.ob_width;
						r.H:=taddr^.ob_height;
						Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
					end;
				objc_offset(Parent^.DlgTree,ObjIndx,r.X,r.Y);
				dec(r.X);
				dec(r.Y);
				r.W:=ObjAddr^.ob_width+3;
				r.H:=ObjAddr^.ob_height+4;
				Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy));
				if caddr<>nil then
					begin
						objc_offset(Parent^.DlgTree,cindx,r.X,r.Y);
						dec(r.X);
						dec(r.Y);
						r.W:=caddr^.ob_width+3;
						r.H:=caddr^.ob_height+4;
						Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
					end
			end
	end;


procedure TComboBox.Unhide;

	begin
		if taddr<>nil then taddr^.ob_flags:=taddr^.ob_flags and not(HIDETREE);
		if caddr<>nil then caddr^.ob_flags:=caddr^.ob_flags and not(HIDETREE);
		inherited Unhide
	end;


procedure TComboBox.SetShortCut(Key: char);
	var idx: integer;

	begin
		inherited SetShortCut(Key);
		if Application^.ExtObjects and (taddr<>nil) then
			with taddr^ do
				begin
					ob_state:=ob_state and not(WHITEBAK) and $00ff;
					if Key<>#0 then
						begin
							idx:=pos(upcase(Key),StrPUpper(GetTitle));
							if (idx>0) and (idx<=$10) then ob_state:=ob_state or ((idx-1) shl 8) or WHITEBAK
						end
				end
	end;


function TComboBox.GetSelection: integer;

	begin
		GetSelection:=select
	end;


procedure TComboBox.SetSelection(Sel: integer; Wrk: boolean);
	var i,q,direc,
	    pmx      : integer;
	    valid    : boolean;

	begin
		if not(CreatePopup) then exit;
		pmx:=Popup^.pMax;
		if Sel<0 then
			begin
				Sel:=pmx-1;
				direc:=-1;
				i:=Sel
			end
		else
			begin
				direc:=1;
				i:=0
			end;
		if Sel>=pmx then sel:=0;
		if Popup^.GetState(Sel)=bf_Disabled then
			begin
				Sel:=id_No;
				valid:=false;
				for q:=0 to pmx-1 do
					if Popup^.GetState(q)=bf_Enabled then
						begin
							valid:=true;
							break
						end;
				if valid then
					begin
						while Popup^.GetState(i)=bf_Disabled do
							begin
								inc(i,direc);
								if i<0 then i:=pmx-1;
								if i>=pmx then i:=0
							end;
						Sel:=i
					end
			end;
		Popup^.CheckMark:=Sel;
		if (Sel<>select) or ChangeAlways then
			begin
				select:=Sel;
				SetValue(select);
				if not(initflag) and Wrk then Work
			end
	end;


procedure TComboBox.ClearSelection(Wrk: boolean);

	begin
		if not(CreatePopup) then exit;
		Popup^.CheckMark:=id_No;
		if (select<>id_No) or ChangeAlways then
			begin
				select:=id_No;
				SetValue(id_No);
				if Wrk then Work
			end
	end;


function TComboBox.CreatePopup: boolean;

	begin
		if Popup=nil then
			begin
				if List=nil then new(Popup,Init(Parent,tpindx,pindx,startidx))
				else
					new(Popup,InitCollection(Parent,List,lstdispose,mincols));
				if Popup<>nil then Popup^.AutoCheck:=true
			end;
		CreatePopup:=(Popup<>nil)
	end;


procedure TComboBox.OpenPopup;

	begin
	end;


procedure TComboBox.SetValue(Sel: integer);

	begin
		if Popup<>nil then SetText(Popup^.GetText(Sel))
	end;


function TComboBox.GetEdit: PEdit;

	begin
		GetEdit:=new(PEdit,Init(Parent,ObjIndx,-1,GetHelp))
	end;


	{ private }


procedure TComboBox.commoninit(cycleindx,titleindx: integer; cycle,editable: boolean);
	var ot   : integer;
	    txt  : string;

	begin
		initflag:=true;
		EnableTransfer;
		Style:=cs_ComboBox;
		ID:=id_NoExit;
		Popup:=nil;
		if editable then
			begin
				Edit:=GetEdit;
				if Edit<>nil then
					begin
						Edit^.DisableTransfer;
						if MagiCVersion>=$0300 then
							with Edit^.ObjAddr^ do ob_flags:=ob_flags and not(FL3DBAK)
					end
			end
		else
			Edit:=nil;
		cycl:=cycle;
		List:=nil;
		startidx:=-1;
		mincols:=0;
		pindx:=-1;
		tpindx:=-1;
		select:=id_No;
		lstdispose:=false;
		ChangeAlways:=false;
		CenterX:=false;
		if Edit=nil then
			with ObjAddr^ do
				ob_flags:=(ob_flags and not(SELECTABLE or F_EXIT)) or TOUCHEXIT;
		cindx:=CycleIndx;
		if cindx>0 then caddr:=@Parent^.DlgTree^[cindx]
		else
			caddr:=nil;
		tindx:=TitleIndx;
		if tindx>0 then
			begin
				taddr:=@Parent^.DlgTree^[tindx];
				if taddr<>nil then
					with taddr^ do
						begin
							ob_flags:=ob_flags or SELECTABLE;
							if bTst(Application^.Attr.Style,as_3DFlags) then ob_flags:=ob_flags or FL3DBAK
							else
								ob_flags:=ob_flags and not(FL3DBAK);
							ot:=ob_type and $ff;
							if (ot=G_BUTTON) or (ot=G_STRING) or (ot=G_TITLE) then txt:=StrPas(ob_spec.free_string)
							else
								if (ot=G_TEXT) or (ot=G_FTEXT) or (ot=G_BOXTEXT) or (ot=G_FBOXTEXT) then
									txt:=StrPas(ob_spec.ted_info^.te_ptext)
								else
									txt:='';
							oldttype:=ob_type;
							oldtobspec:=ob_spec.index;
							usrtblk.ub_parm:=0;
							ob_spec.index:=0;
							SetTitle(txt);
							if Application^.ExtObjects then ob_type:=G_STRING
							else
								begin
									usrtblk.ub_code:=@DrawComboTitle;
									ob_spec.user_blk:=@usrtblk;
									ob_type:=G_USERDEF
								end
						end
			end
		else
			taddr:=nil;
		if caddr<>nil then
			with caddr^ do
				begin
					if cycl then
						begin
							ob_flags:=(ob_flags and not(SELECTABLE or F_EXIT)) or TOUCHEXIT;
							UsrBlk.ub_parm:=ob_spec.index;
							UsrBlk.ub_code:=@DrawCycleBox;
							oldtype:=ob_type;
							ob_type:=G_USERDEF;
							ob_spec.user_blk:=@UsrBlk;
							UsrDef:=true
						end
					else
						begin
							ob_flags:=(ob_flags and not(TOUCHEXIT)) or SELECTABLE or F_EXIT;
							if (ob_type and $ff)=G_BOXCHAR then
								ob_spec.index:=(ob_spec.index and $00fff0ff) or (longint(ord(Application^.Attr.PopChar)) shl 24) or (COMBOCOL shl 8)
						end
				end
	end;

{ *** TCOMBOBOX *** }



{ *** Objekt TCARD *** }

constructor TCard.Init(AParent: PDialog; CardIdx,TitleIdx,AGroup,AFlag: integer; Hlp: string);

	begin
		if not(inherited Init(AParent,TitleIdx,Hlp)) then fail;
		cindx:=CardIdx;
		if cindx>0 then caddr:=@Parent^.DlgTree^[cindx]
		else
			caddr:=nil;
		if caddr=nil then
			begin
				inherited Done;
				fail
			end;
		Style:=cs_Notepad;
		ID:=id_NoExit;
		group:=AGroup;
		cflag:=AFlag;
		if ((ObjAddr^.ob_type and $ff)=G_BUTTON) and ((caddr^.ob_type and $ff)=G_BOX) then
			begin
				with ObjAddr^ do
					begin
						oldflags:=ob_flags;
						UsrBlk.ub_parm:=ob_spec.index;
						UsrBlk.ub_code:=@DrawCardTitle;
						ob_type:=G_USERDEF;
						ob_spec.user_blk:=@UsrBlk;
						UsrDef:=true;
						case cflag of
						crd_First:
							ob_type:=(ob_type and not(crdFlags)) or crdFirst;
						crd_Last:
							ob_type:=(ob_type and not(crdFlags)) or crdLast;
						end
					end;
				with caddr^ do
					begin
						cusrblk.ub_parm:=ob_spec.index;
						cusrblk.ub_code:=@DrawCardBox;
						ob_type:=G_USERDEF;
						ob_spec.user_blk:=@cusrblk
					end;
				if IsChecked then
					begin
						SetShortCut(#0);
						UnhideCard
					end
				else
					begin
						ActivateShortcut;
						HideCard(false)
					end
			end
		else
			begin
				inherited Done;
				fail
			end
	end;


destructor TCard.Done;

	begin
		with caddr^ do
			begin
				ob_spec.index:=cusrblk.ub_parm;
				ob_type:=G_BOX
			end;
		with ObjAddr^ do
			begin
				ob_spec.index:=UsrBlk.ub_parm;
				ob_flags:=oldflags;
				ob_type:=G_BUTTON
			end;
		inherited Done
	end;


function TCard.TestIndex(AnIndx: integer): boolean;

	begin
		TestIndex:=((AnIndx=ObjIndx) or (AnIndx=cindx))
	end;


procedure TCard.Paint;

	begin
		if cindx>0 then Parent^.ObjcPaint(cindx,bTst(Flags,wb_Lazy));
		inherited Paint
	end;


procedure TCard.Changed(AnIndx: integer; DblClick: boolean);
	var pc: PControl;

	begin
		if AnIndx<>ObjIndx then exit;
		if not(IsChecked) then exit;
		pc:=Parent^.CtrlList;
		while pc<>nil do
			begin
				if bTst(pc^.Style,cs_Notepad) then
					if PCard(pc)^.group=group then
						if pc<>@self then
							if PCard(pc)^.IsChecked then PCard(pc)^.HideCard(true);
				pc:=pc^.Next
			end;
		Parent^.InitFocus;
		UnhideCard;
		Parent^.InitFocus
	end;


procedure TCard.HideCard(Draw: boolean);
	var valid: boolean;
	    ox,oy: integer;
	    r    : GRECT;

	begin
		valid:=not(IsHidden) and Draw;
		with caddr^ do ob_flags:=ob_flags or HIDETREE;
		with ObjAddr^ do ob_flags:=ob_flags or SELECTABLE or TOUCHEXIT;
		ActivateShortcut;
		if valid then
			begin
				objc_offset(Parent^.DlgTree,cindx,r.X,r.Y);
				r.W:=caddr^.ob_width;
				r.H:=caddr^.ob_height;
				Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
			end;
		Uncheck
	end;


procedure TCard.UnhideCard;

	begin
		with caddr^ do ob_flags:=ob_flags and not(HIDETREE);
		SetShortCut(#0);
		Check;
		with ObjAddr^ do ob_flags:=ob_flags and not(SELECTABLE or TOUCHEXIT);
		Paint
	end;


function TCard.IsCardHidden: boolean;

	begin
		IsCardHidden:=Application^.IsTreeHidden(Parent^.DlgTree,cindx)
	end;


procedure TCard.SetCheck(CheckFlag: integer);

	begin
		if GetCheck<>CheckFlag then
			begin
				with ObjAddr^ do
					begin
						if CheckFlag=bf_Unchecked then ob_state:=ob_state and not(SELECTED)
						else
							ob_state:=ob_state or SELECTED
					end;
				Paint
			end
	end;


function TCard.GetCheck: integer;

	begin
		if bTst(ObjAddr^.ob_state,SELECTED) then GetCheck:=bf_Checked
		else
			GetCheck:=bf_Unchecked
	end;


procedure TCard.Check;

	begin
		SetCheck(bf_Checked)
	end;


procedure TCard.Uncheck;

	begin
		SetCheck(bf_Unchecked)
	end;


procedure TCard.Toggle;

	begin
		if GetCheck=bf_Checked then Uncheck
		else
			Check
	end;


function TCard.IsChecked: boolean;

	begin
		IsChecked:=(GetCheck=bf_Checked)
	end;


	{ private }


procedure TCard.ActivateShortcut;
	var q: integer;
	    s: string;

	begin
		s:=StrPPas(PChar(UsrBlk.ub_parm));
		q:=pos('&',s);
		if (q>0) and (q<length(s)) then SetShortCut(PChar(UsrBlk.ub_parm+q)^)
	end;

{ *** TCARD *** }



{ *** Objekt TLISTBOX *** }

constructor TListBox.Init(AParent: PDialog; AnIndx,SIndx,DIndx,IIndx: integer; ACollection: PStringCollection; DisposeColl: boolean; Hlp: string);
	var anz,q: integer;

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		initflag:=true;
		anz:=ObjAddr^.ob_tail+1-ObjAddr^.ob_head;
		if anz<1 then
			begin
				inherited Done;
				fail
			end;
		ScrollBar:=new(PLBScrollBar,Init(AParent,SIndx,DIndx,IIndx,anz,0,Hlp));
		if ScrollBar=nil then
			begin
				inherited Done;
				fail
			end;
		ScrollBar^.TrackMode:=true;
		getmem(oldptr,anz shl 2);
		if oldptr<>nil then
			for q:=0 to anz-1 do oldptr^[q]:=Parent^.DlgTree^[ObjAddr^.ob_head+q].ob_spec.free_string;
		PLBScrollBar(ScrollBar)^.lbox:=@self;
		Style:=cs_ListBox;
		ID:=id_NoExit;
		EnableTransfer;
		SetFlags(wb_ExtFocus,true);
		lstdispose:=DisposeColl;
		nptr:=0;
		Multiple:=false;
		for q:=ObjAddr^.ob_head to ObjAddr^.ob_tail do
			Parent^.DlgTree^[q].ob_flags:=(Parent^.DlgTree^[q].ob_flags and not(SELECTABLE)) or TOUCHEXIT;
		SetCollection(ACollection);
		if List=nil then
			begin
				Done;
				fail
			end;
		initflag:=false
	end;


destructor TListBox.Done;
	var anz,q: integer;

	begin
		if oldptr<>nil then
			begin
				anz:=ObjAddr^.ob_tail+1-ObjAddr^.ob_head;
				for q:=0 to anz-1 do Parent^.DlgTree^[ObjAddr^.ob_head+q].ob_spec.free_string:=oldptr^[q];
				freemem(oldptr,anz shl 2)
			end;
		dispose(ScrollBar,Done);
		if lstdispose then
			if List<>nil then dispose(List,Done);
		inherited Done
	end;


procedure TListBox.SetCollection(ACollection: PStringCollection);

	begin
		List:=ACollection;
		if List=nil then exit;
		ScrollBar^.SetRange(0,List^.Count-1);
		lastsel:=id_No;
		filllist(false,0);
		SetSelection(ScrollBar^.GetPosition);
		Paint
	end;


function TListBox.TestIndex(AnIndx: integer): boolean;

	begin
		TestIndex:=((AnIndx>=ObjAddr^.ob_head) and (AnIndx<=ObjAddr^.ob_tail)) or (AnIndx=ObjIndx)
	end;


function TListBox.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		case TransferFlag of
		tf_SetData:
			SetSelection(PInteger(DataPtr)^);
		tf_GetData:
			PInteger(DataPtr)^:=GetSelection
		end;
		Transfer:=2
	end;


procedure TListBox.Changed(AnIndx: integer; DblClick: boolean);

	begin
		Parent^.SetExtFocus(ObjIndx);
		SetSelection(ScrollBar^.GetPosition+AnIndx-ObjAddr^.ob_head)
	end;


function TListBox.ExtFocusKey(Stat,Key: integer): boolean;
	var dummy: longint;

	procedure checkfocus;

		begin
			if lastsel-ScrollBar^.GetPosition<0 then ScrollBar^.DeltaPos(lastsel-ScrollBar^.GetPosition)
			else
				if lastsel-ScrollBar^.GetPosition>=ScrollBar^.Size then ScrollBar^.DeltaPos(lastsel+1-ScrollBar^.GetPosition-ScrollBar^.Size)
		end;

	begin
		ExtFocusKey:=false;
		if not(bTst(Stat,K_CTRL)) then exit;
		KeyRepeatOff;
		if (Stat and K_SHIFT)>0 then
			case (MapKey(Key) and $00ff) of
			50:
				begin
					ExtFocusKey:=true;
					SetSelection(lastsel+ScrollBar^.Size);
					checkfocus
				end;
			56:
				begin
					ExtFocusKey:=true;
					if lastsel>ScrollBar^.Size then SetSelection(lastsel-ScrollBar^.Size)
					else
						SetSelection(0);
					checkfocus
				end;
			55,119:
				begin
					ExtFocusKey:=true;
					SetSelection(List^.Count-1);
					ScrollBar^.SetPosition(ScrollBar^.GetRange(dummy,dummy))
				end
			end
		else
			case Key of
			20480:
				begin
					ExtFocusKey:=true;
					SetSelection(lastsel+1);
					checkfocus
				end;
			18432:
				begin
					ExtFocusKey:=true;
					if lastsel>0 then SetSelection(lastsel-1);
					checkfocus
				end;
			30464:
				begin
					ExtFocusKey:=true;
					SetSelection(0);
					ScrollBar^.SetPosition(0)
				end
			end;
		KeyRepeatRestore
	end;


procedure TListBox.ExtFocusPaint(r: GRECT);
	var indx: integer;

	begin
		indx:=GetSelection+ObjAddr^.ob_head-ScrollBar^.GetPosition;
		if (indx>=ObjAddr^.ob_head) and (indx<=ObjAddr^.ob_tail) then
			begin
				with Parent^.DlgTree^[indx] do
					begin
						if not(bTst(ob_state,SELECTED)) then exit;
						objc_offset(Parent^.DlgTree,indx,pxya[0],pxya[1]);
						pxya[2]:=pxya[0]+ob_width-1;
						pxya[3]:=pxya[1];
						pxya[4]:=pxya[2];
						pxya[5]:=pxya[1]+ob_height-1;
						pxya[6]:=pxya[0];
						pxya[7]:=pxya[5];
						pxya[8]:=pxya[0];
						pxya[9]:=pxya[1]
					end;
				vsl_type(Parent^.vdiHandle,LT_USERDEF);
				v_pline(Parent^.vdiHandle,5,pxya);
				vsl_type(Parent^.vdiHandle,LT_SOLID)
			end
	end;


procedure TListBox.Work;

	begin
	end;


function TListBox.GetSelection: integer;

	begin
		GetSelection:=lastsel
	end;


procedure TListBox.SetSelection(Sel: integer);
	var q,indx: integer;
	    r     : GRECT;

	begin
		if Sel>=List^.Count then Sel:=List^.Count-1;
		if Sel=GetSelection then exit;
		for q:=ObjAddr^.ob_head to ObjAddr^.ob_tail do
			if bTst(Parent^.DlgTree^[q].ob_state,SELECTED) then
				begin
					Parent^.DlgTree^[q].ob_state:=Parent^.DlgTree^[q].ob_state and not(SELECTED);
					objc_offset(Parent^.DlgTree,q,r.X,r.Y);
					r.W:=Parent^.DlgTree^[q].ob_width;
					r.H:=Parent^.DlgTree^[q].ob_height;
					Parent^.ObjcPaintRect(ObjIndx,r,IsFlagSet(wb_Lazy))
				end;
		lastsel:=Sel;
		indx:=lastsel+ObjAddr^.ob_head-ScrollBar^.GetPosition;
		if (indx>=ObjAddr^.ob_head) and (indx<=ObjAddr^.ob_tail) then
			with Parent^.DlgTree^[indx] do
				begin
					ob_state:=ob_state or SELECTED;
					objc_offset(Parent^.DlgTree,indx,r.X,r.Y);
					r.W:=ob_width;
					r.H:=ob_height;
					Parent^.ObjcPaintRect(ObjIndx,r,IsFlagSet(wb_Lazy))
				end;
		if not(initflag) then Work
	end;


function TListBox.FlagKeyOf(Item: pointer): pointer;

	begin
		FlagKeyOf:=nil
	end;


	{ private }


procedure TListBox.filllist(draw: boolean; diff: integer);
	var anf  : longint;
	    q,cmp: integer;

	begin
		anf:=ScrollBar^.GetPosition;
		cmp:=lastsel+ObjAddr^.ob_head-anf;
		for q:=ObjAddr^.ob_head to ObjAddr^.ob_tail do
			with Parent^.DlgTree^[q] do
				begin
					if anf<List^.Count then
						begin
							ob_spec.free_string:=pointer(longint(List^.KeyOf(List^.At(anf)))+1);
							if q=cmp then ob_state:=ob_state or SELECTED
							else
								ob_state:=ob_state and not(SELECTED)
						end
					else
						begin
							ob_spec.free_string:=@nptr;
							ob_state:=ob_state and not(SELECTED)
						end;
					inc(anf)
				end
{		if draw then
			if diff<>0 then
				begin
					HideMouse;
					if abs(diff)<ScrollBar^.Size then
						begin
						end
					else
						begin
						end;
					ShowMouse
				end ... }
	end;

{ *** TLISTBOX *** }




procedure TLBScrollBar.Work;

	begin
		lbox^.filllist(false,0);
		lbox^.Paint
	end;


procedure vFillarea(vdiHandle,Count: integer; const pxyarray: array of integer);
	var i: integer;

	begin
		if Count<2 then exit;
		with VDI_pb do
			begin
				control^[0]:=9;
				control^[1]:=Count;
				control^[3]:=0;
				control^[6]:=vdiHandle;
				for i:=0 to (Count shl 1)-1 do ptsin^[i]:=pxyarray[i];
				vdi(@VDI_pb)
			end
	end;


procedure vgText(vdiHandle,x,y: integer; const outstring: string);
	var l,i: integer;

	begin
		l:=length(outstring);
		if l<=0 then exit;
		with VDI_pb do
			begin
				control^[0]:=8;
				control^[1]:=1;
				control^[3]:=l;
				control^[6]:=vdiHandle;
				ptsin^[0]:=x;
				ptsin^[1]:=y;
				for i:=1 to l do intin^[i-1]:=ord(outstring[i]);
				vdi(@VDI_pb)
			end
	end;


procedure vPline(vdiHandle,Count: integer; const pxyarray: array of integer);
	var i: integer;

	begin
		if Count<2 then exit;
		with VDI_pb do
			begin
				control^[0]:=6;
				control^[1]:=Count;
				control^[3]:=0;
				control^[6]:=vdiHandle;
				for i:=0 to (Count shl 1)-1 do ptsin^[i]:=pxyarray[i];
				vdi(@VDI_pb)
			end
	end;


function DrawCycleBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				d_clip[0]:=pb_x;
				d_clip[1]:=pb_y;
				d_clip[2]:=pb_x+pb_w+1;
				d_clip[3]:=pb_y+pb_h+2
			end;
		with Application^ do
			begin
				vsf_interior(vdiHandle,FIS_SOLID);
				v_bar(vdiHandle,d_clip);
				dec(d_clip[2],3);
				dec(d_clip[3],3);
				vsf_color(vdiHandle,White);
				v_bar(vdiHandle,d_clip);
				pxya[0]:=d_clip[0];
				pxya[1]:=d_clip[1]-1;
				pxya[2]:=d_clip[2]+1;
				pxya[3]:=pxya[1];
				pxya[4]:=pxya[2];
				pxya[5]:=d_clip[3]+1;
				pxya[6]:=pxya[0];
				pxya[7]:=pxya[5];
				vPline(vdiHandle,4,pxya);
				vsf_color(vdiHandle,COMBOCOL);
				d_br:=d_clip[2]-d_clip[0]-5;
				pxya[0]:=d_clip[0]+3;
				pxya[1]:=((d_clip[1]+d_clip[3]) shr 1)-1;
				pxya[2]:=pxya[0]+(d_br shr 1);
				pxya[3]:=d_clip[1]+2;
				pxya[4]:=pxya[0]+d_br-1;
				pxya[5]:=pxya[1];
				pxya[6]:=pxya[0];
				pxya[7]:=pxya[1];
				vFillarea(vdiHandle,4,pxya);
				inc(pxya[1],3);
				pxya[3]:=d_clip[3]-2;
				pxya[5]:=pxya[1];
				pxya[7]:=pxya[1];
				vFillarea(vdiHandle,4,pxya);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawCycleBox:=NORMAL
	end;


function DrawGroupBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var q: integer;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				d_clip[0]:=pb_x;
				d_clip[1]:=pb_y;
				d_clip[2]:=pb_x+pb_w-1;
				d_clip[3]:=pb_y+pb_h-1
			end;
		with Application^ do
			begin
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,SysInfo.BGDefCol);
				v_bar(vdiHandle,d_clip);
				if (SysInfo.BGDefCol<>White) and (Attr.Colors>=LBlack) and bTst(Attr.Style,as_3DFlags) then
					begin
						{ gbs_Recessed... }
						pxya[0]:=d_clip[0];
						pxya[1]:=d_clip[3];
						pxya[2]:=d_clip[0];
						pxya[3]:=d_clip[1];
						pxya[4]:=d_clip[2];
						pxya[5]:=d_clip[1];
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya);
						pxya[0]:=d_clip[0]+1;
						pxya[1]:=d_clip[3];
						pxya[2]:=d_clip[2];
						pxya[3]:=d_clip[3];
						pxya[4]:=d_clip[2];
						pxya[5]:=d_clip[1]+1;
						vsl_color(vdiHandle,White);
						vPline(vdiHandle,3,pxya);
						vsf_interior(vdiHandle,FIS_HOLLOW);
						vsf_color(vdiHandle,Black)
					end
				else
					begin
						vsf_interior(vdiHandle,FIS_HOLLOW);
						vsf_color(vdiHandle,Black);
						vswr_mode(vdiHandle,MD_TRANS);
						v_bar(vdiHandle,d_clip);
						vswr_mode(vdiHandle,MD_REPLACE)
					end;
				if parm^.pb_parm<>0 then
					if PByte(parm^.pb_parm)^>0 then
						begin
							d_str[0]:=chr(PByte(parm^.pb_parm)^+2);
							d_str[1]:=' ';
							d_str[ord(d_str[0])]:=' ';
							d_chr:=PChar(parm^.pb_parm);
							for q:=1 to PByte(parm^.pb_parm)^ do
								begin
									inc(longint(d_chr));
									d_str[q+1]:=d_chr^
								end;
							if SysInfo.DefColValid then
								begin
									vst_fg_color(vdiHandle,CSPACE_RGB,defcolfg);
									vst_bg_color(vdiHandle,CSPACE_RGB,SysInfo.DefCol);
									vgText(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.Font.Height shr 1),d_str);
									vst_color(vdiHandle,Black)
								end
							else
								begin
									vst_color(vdiHandle,SysInfo.BGDefCol);
									vgText(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.Font.Height shr 1),d_str);
									vswr_mode(vdiHandle,MD_ERASE);
									vgText(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.Font.Height shr 1),d_str);
									vswr_mode(vdiHandle,MD_TRANS);
									vgText(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.Font.Height shr 1),d_str);
									vst_color(vdiHandle,Black);
									vgText(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.Font.Height shr 1),d_str);
									vswr_mode(vdiHandle,MD_REPLACE)
								end
						end;
				vsl_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawGroupBox:=NORMAL
	end;


function DrawCheckBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var q: word;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				d_clip[0]:=pb_x+1;
				d_clip[1]:=pb_y+1;
				d_clip[2]:=d_clip[0]+13;
				d_clip[3]:=d_clip[1]+13;
				case (pb_tree^[pb_obj].ob_type and cbFlags) of
				cbChecked:
					d_stat:=bf_Checked;
				cbGrayed:
					d_stat:=bf_Grayed
				else
					d_stat:=bf_Unchecked
				end;
				if pr_currstate<>pr_prevstate then
					begin
						inc(d_stat);
						if bTst(pb_tree^[pb_obj].ob_type,cbType) then q:=3 else q:=2;
						if d_stat>q then d_stat:=1;
						case d_stat of
						bf_Checked:
							q:=cbChecked;
						bf_Grayed:
							q:=cbGrayed
						else
							q:=cbUnchecked
						end;
						pb_tree^[pb_obj].ob_type:=(pb_tree^[pb_obj].ob_type and not(cbFlags)) or q
					end;
				if (d_stat<>bf_Unchecked) or bTst(pr_currstate,CROSSED) then for q:=0 to 3 do inc(d_clip[q])
			end;
		with Application^ do
			begin
				if d_stat=bf_Grayed then
					if Attr.Colors>=LWhite then
						begin
							vsf_interior(vdiHandle,FIS_SOLID);
							vsf_color(vdiHandle,LWhite)
						end;
				v_bar(vdiHandle,d_clip);
				if d_stat<>bf_Unchecked then
					begin
						pxya[0]:=d_clip[0]-1;
						pxya[1]:=d_clip[3]-1;
						pxya[2]:=d_clip[0]-1;
						pxya[3]:=d_clip[1]-1;
						pxya[4]:=d_clip[2]-1;
						pxya[5]:=d_clip[1]-1;
						vsl_color(vdiHandle,SysInfo.BGDefCol);
						vPline(vdiHandle,3,pxya);
						if d_stat=bf_Checked then
							begin
								vsl_color(vdiHandle,LBlack);
								if bTst(parm^.pr_currstate,CROSSED) then
									begin
										pxya[0]:=d_clip[0]+1;
										pxya[1]:=d_clip[1]+1;
										pxya[2]:=d_clip[2]-1;
										pxya[3]:=d_clip[3]-1;
										vPline(vdiHandle,2,pxya);
										pxya[0]:=d_clip[0]+1;
										pxya[1]:=d_clip[3]-1;
										pxya[2]:=d_clip[2]-1;
										pxya[3]:=d_clip[1]+1;
										vPline(vdiHandle,2,pxya)
									end
								else
									begin
										pxya[0]:=d_clip[0]+1;
										pxya[1]:=d_clip[3]-1;
										pxya[2]:=d_clip[0]+1;
										pxya[3]:=d_clip[1]+1;
										pxya[4]:=d_clip[2]-1;
										pxya[5]:=d_clip[1]+1;
										vPline(vdiHandle,3,pxya);
										vsf_interior(vdiHandle,FIS_SOLID);
										vsf_color(vdiHandle,SysInfo.UsrDefCol);
										vsl_color(vdiHandle,SysInfo.UsrDefCol);
										if bTst(parm^.pr_currstate,DISABLED) then
											if Attr.Colors>=LWhite then
												begin
													vsf_color(vdiHandle,LWhite);
													vsl_color(vdiHandle,LWhite)
												end;
										pxya[0]:=d_clip[0]+5;
										pxya[1]:=d_clip[1]+7;
										pxya[2]:=d_clip[0]+4;
										pxya[3]:=d_clip[1]+8;
										pxya[4]:=d_clip[0]+4;
										pxya[5]:=d_clip[1]+11;
										pxya[6]:=d_clip[0]+5;
										pxya[7]:=d_clip[1]+11;
										pxya[8]:=d_clip[0]+11;
										pxya[9]:=d_clip[1]+5;
										pxya[10]:=d_clip[0]+10;
										pxya[11]:=d_clip[1]+5;
										pxya[12]:=d_clip[0]+5;
										pxya[13]:=d_clip[1]+10;
										pxya[14]:=d_clip[0]+5;
										pxya[15]:=d_clip[1]+7;
										vFillarea(vdiHandle,8,pxya)
									end
							end
						else
							begin
								vsl_color(vdiHandle,Black);
								if Attr.Colors>=LWhite then
									begin
										pxya[0]:=d_clip[0];
										pxya[1]:=d_clip[1];
										pxya[2]:=d_clip[2];
										pxya[3]:=d_clip[1];
										pxya[4]:=d_clip[2];
										pxya[5]:=d_clip[3];
										pxya[6]:=d_clip[0];
										pxya[7]:=d_clip[3];
										pxya[8]:=d_clip[0];
										pxya[9]:=d_clip[1];
										vPline(vdiHandle,5,pxya)
									end;
								if d_stat=bf_Grayed then
									begin
										pxya[0]:=d_clip[0]+3;
										pxya[1]:=d_clip[1]+6;
										pxya[2]:=d_clip[2]-3;
										pxya[3]:=pxya[1];
										pxya[4]:=pxya[2];
										pxya[5]:=d_clip[1]+7;
										pxya[6]:=pxya[0];
										pxya[7]:=pxya[5];
										pxya[8]:=pxya[0];
										pxya[9]:=pxya[1];
										vPline(vdiHandle,5,pxya)
									end
							end
					end
				else
					if not(bTst(parm^.pr_currstate,CROSSED)) then
						begin
							pxya[0]:=d_clip[0]+1;
							pxya[1]:=d_clip[3]+1;
							pxya[2]:=d_clip[2]+1;
							pxya[3]:=d_clip[3]+1;
							pxya[4]:=d_clip[2]+1;
							pxya[5]:=d_clip[1]+1;
							vsl_color(vdiHandle,LBlack);
							vPline(vdiHandle,3,pxya)
						end;
				d_tx:=parm^.pb_x+14+Attr.charSWidth;
				d_ty:=parm^.pb_y+SysInfo.Font.Height+1;
				d_chr:=PChar(parm^.pb_parm);
				d_btn[0]:=#0;
				while (d_chr^<>#0) and (byte(d_btn[0])<40) do
					begin
						inc(byte(d_btn[0]));
						d_btn[length(d_btn)]:=d_chr^;
						inc(longint(d_chr))
					end;
				while d_btn[length(d_btn)]=' ' do d_btn[0]:=chr(ord(d_btn[0])-1);
				d_scpos:=0;
				if length(d_btn)>0 then
					for q:=1 to length(d_btn) do
						if d_btn[q]='&' then
							begin
								d_scpos:=q;
								break
							end;
				if d_scpos>0 then
					begin
						for q:=d_scpos to length(d_btn)-1 do d_btn[q]:=d_btn[q+1];
						d_btn[0]:=chr(ord(d_btn[0])-1)
					end;
				vswr_mode(vdiHandle,MD_ERASE);
				vst_color(vdiHandle,SysInfo.BGDefCol);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				vswr_mode(vdiHandle,MD_TRANS);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				if d_scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then
							begin
								vst_effects(vdiHandle,TF_UNDERLINED or TF_LIGHTENED);
								vst_color(vdiHandle,Black)
							end
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdiHandle,SysInfo.HotKeyCol)
							end;
						if d_scpos=1 then extent[2]:=0
						else
							begin
								d_str[0]:=chr(d_scpos-1);
								for q:=1 to d_scpos-1 do d_str[q]:=d_btn[q];
								vqt_extent(vdiHandle,d_str,extent)
							end;
						d_str[0]:=#1;
						d_str[1]:=d_btn[d_scpos];
						vgText(vdiHandle,d_tx+extent[2],d_ty,d_str)
					end;
				vst_color(vdiHandle,Black);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED)
				else
					vst_effects(vdiHandle,TF_NORMAL);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				vsl_type(vdiHandle,LT_SOLID);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vsf_style(vdiHandle,4);
				vsl_color(vdiHandle,Black);
				vswr_mode(vdiHandle,MD_REPLACE);
				vst_color(vdiHandle,Black);
				vst_effects(vdiHandle,TF_NORMAL);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawCheckBox:=NORMAL
	end;


function DrawRadioButton(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var q: word;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				if (pb_tree^[pb_obj].ob_type and cbFlags)=cbChecked then d_stat:=bf_Checked
				else
					d_stat:=bf_Unchecked;
				if pr_currstate<>pr_prevstate then
					begin
						d_stat:=d_stat xor 3;
						if d_stat=bf_Checked then q:=cbChecked
						else
							q:=cbUnchecked;
						pb_tree^[pb_obj].ob_type:=(pb_tree^[pb_obj].ob_type and not(cbFlags)) or q
					end;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				pxya[0]:=pb_x+1;
				pxya[1]:=pb_y+8;
				pxya[2]:=pb_x+8;
				pxya[3]:=pb_y+15;
				pxya[4]:=pb_x+15;
				pxya[5]:=pb_y+8;
				pxya[6]:=pb_x+8;
				pxya[7]:=pb_y+1;
				pxya[8]:=pb_x+1;
				pxya[9]:=pb_y+8
			end;
		if d_stat=bf_Checked then for q:=0 to 4 do inc(pxya[q shl 1]);
		with Application^ do
			begin
				vFillarea(vdiHandle,5,pxya);
				if d_stat=bf_Checked then
					begin
						pxya[0]:=parm^.pb_x+8;
						pxya[1]:=parm^.pb_y+1;
						pxya[2]:=parm^.pb_x+1;
						pxya[3]:=parm^.pb_y+8;
						pxya[4]:=parm^.pb_x+8;
						pxya[5]:=parm^.pb_y+15;
						vsl_color(vdiHandle,SysInfo.BGDefCol);
						vPline(vdiHandle,3,pxya);
						pxya[0]:=parm^.pb_x+9;
						pxya[1]:=parm^.pb_y+2;
						pxya[2]:=parm^.pb_x+3;
						pxya[3]:=parm^.pb_y+8;
						pxya[4]:=parm^.pb_x+9;
						pxya[5]:=parm^.pb_y+14;
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya);
						vsf_interior(vdiHandle,FIS_SOLID);
						vsf_color(vdiHandle,SysInfo.UsrDefCol);
						if bTst(parm^.pr_currstate,DISABLED) then
							if Attr.Colors>=LWhite then
								begin
									vsf_color(vdiHandle,LWhite);
									vsl_color(vdiHandle,LWhite)
								end;
						pxya[0]:=parm^.pb_x+7;
						pxya[1]:=parm^.pb_y+8;
						pxya[2]:=parm^.pb_x+9;
						pxya[3]:=parm^.pb_y+10;
						pxya[4]:=parm^.pb_x+11;
						pxya[5]:=parm^.pb_y+8;
						pxya[6]:=parm^.pb_x+9;
						pxya[7]:=parm^.pb_y+6;
						pxya[8]:=parm^.pb_x+7;
						pxya[9]:=parm^.pb_y+8;
						vFillarea(vdiHandle,5,pxya)
					end
				else
					begin
						pxya[0]:=parm^.pb_x+9;
						pxya[1]:=parm^.pb_y+1;
						pxya[2]:=parm^.pb_x+16;
						pxya[3]:=parm^.pb_y+8;
						pxya[4]:=parm^.pb_x+9;
						pxya[5]:=parm^.pb_y+15;
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya)
					end;
				d_tx:=parm^.pb_x+14+Attr.charSWidth;
				d_ty:=parm^.pb_y+SysInfo.Font.Height+1;
				d_chr:=PChar(parm^.pb_parm);
				d_btn[0]:=#0;
				while (d_chr^<>#0) and (byte(d_btn[0])<40) do
					begin
						inc(byte(d_btn[0]));
						d_btn[length(d_btn)]:=d_chr^;
						inc(longint(d_chr))
					end;
				while d_btn[length(d_btn)]=' ' do d_btn[0]:=chr(ord(d_btn[0])-1);
				d_scpos:=0;
				if length(d_btn)>0 then
					for q:=1 to length(d_btn) do
						if d_btn[q]='&' then
							begin
								d_scpos:=q;
								break
							end;
				if d_scpos>0 then
					begin
						for q:=d_scpos to length(d_btn)-1 do d_btn[q]:=d_btn[q+1];
						d_btn[0]:=chr(ord(d_btn[0])-1)
					end;
				vswr_mode(vdiHandle,MD_ERASE);
				vst_color(vdiHandle,SysInfo.BGDefCol);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				vswr_mode(vdiHandle,MD_TRANS);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				vst_color(vdiHandle,Black);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				if d_scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_UNDERLINED or TF_LIGHTENED)
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdiHandle,SysInfo.HotKeyCol)
							end;
						d_btn[0]:=#1;
						d_btn[1]:=#32;
						vgText(vdiHandle,d_tx+(d_scpos-1)*Attr.charSWidth,d_ty,d_btn)
					end;
				vsl_type(vdiHandle,LT_SOLID);
				vsl_color(vdiHandle,Black);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vswr_mode(vdiHandle,MD_REPLACE);
				vst_color(vdiHandle,Black);
				vst_effects(vdiHandle,TF_NORMAL);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawRadioButton:=NORMAL
	end;


function DrawComboTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var q: integer;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				d_clip[0]:=pb_x;
				d_clip[1]:=pb_y;
				d_clip[2]:=pb_x+pb_w-1;
				d_clip[3]:=pb_y+pb_h-1
			end;
		with Application^ do
			begin
				d_tx:=parm^.pb_x+1;
				d_ty:=parm^.pb_y+SysInfo.Font.Height;
				d_chr:=PChar(parm^.pb_parm);
				d_btn[0]:=#0;
				while (d_chr^<>#0) and (byte(d_btn[0])<40) do
					begin
						inc(byte(d_btn[0]));
						d_btn[length(d_btn)]:=d_chr^;
						inc(longint(d_chr))
					end;
				while d_btn[length(d_btn)]=' ' do d_btn[0]:=chr(ord(d_btn[0])-1);
				d_scpos:=0;
				if length(d_btn)>0 then
					for q:=1 to length(d_btn) do
						if d_btn[q]='&' then
							begin
								d_scpos:=q;
								break
							end;
				if d_scpos>0 then
					begin
						for q:=d_scpos to length(d_btn)-1 do d_btn[q]:=d_btn[q+1];
						d_btn[0]:=chr(ord(d_btn[0])-1)
					end;
				vsf_perimeter(vdiHandle,PER_OFF);
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,SysInfo.BGDefCol);
				v_bar(vdiHandle,d_clip);
				vswr_mode(vdiHandle,MD_TRANS);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				vst_color(vdiHandle,Black);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				if d_scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_UNDERLINED or TF_LIGHTENED)
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdiHandle,SysInfo.HotKeyCol)
							end;
						d_btn[0]:=#1;
						d_btn[1]:=#32;
						vgText(vdiHandle,d_tx+(d_scpos-1)*Attr.charSWidth,d_ty,d_btn)
					end;
				vsf_color(vdiHandle,Black);
				if bTst(parm^.pr_currstate,SELECTED) then
					begin
						vswr_mode(vdiHandle,MD_XOR);
						v_bar(vdiHandle,d_clip)
					end;
				vsl_type(vdiHandle,LT_SOLID);
				vsf_perimeter(vdiHandle,PER_ON);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vswr_mode(vdiHandle,MD_REPLACE);
				vst_effects(vdiHandle,TF_NORMAL);
				vst_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawComboTitle:=NORMAL
	end;


function DrawCardBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				d_clip[0]:=pb_x;
				d_clip[1]:=pb_y+1;
				d_clip[2]:=pb_x+pb_w-1;
				d_clip[3]:=pb_y+pb_h-2
			end;
		with Application^ do
			begin
				vswr_mode(vdiHandle,MD_REPLACE);
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,SysInfo.BGDefCol);
				v_bar(vdiHandle,d_clip);
				pxya[0]:=parm^.pb_x;
				pxya[1]:=parm^.pb_y;
				pxya[2]:=pxya[0];
				pxya[3]:=pxya[1]+parm^.pb_h-1;
				pxya[4]:=pxya[2]+parm^.pb_w-CARD_OFFS-1;
				if Attr.Colors<16 then dec(pxya[3],CARD_OFFS);
				pxya[5]:=pxya[3];
				pxya[6]:=pxya[4];
				pxya[7]:=pxya[1];
				vsl_color(vdiHandle,Black);
				vPline(vdiHandle,4,pxya);
				if Attr.Colors<16 then
					begin
						pxya[0]:=parm^.pb_x+CARD_OFFS;
						pxya[1]:=parm^.pb_y+parm^.pb_h-2;
						pxya[2]:=parm^.pb_x+parm^.pb_w-2;
						pxya[3]:=pxya[1];
						pxya[4]:=pxya[2];
						pxya[5]:=parm^.pb_y+CARD_OFFS;
						vPline(vdiHandle,3,pxya);
						inc(pxya[1]);
						inc(pxya[2]);
						pxya[3]:=pxya[1];
						pxya[4]:=pxya[2];
						vPline(vdiHandle,3,pxya)
					end
				else
					begin
						inc(pxya[0]);
						pxya[2]:=pxya[0];
						pxya[3]:=pxya[1]+parm^.pb_h-5;
						vsl_color(vdiHandle,White);
						vPline(vdiHandle,2,pxya);
						pxya[0]:=parm^.pb_x+1;
						pxya[1]:=parm^.pb_y+parm^.pb_h-2;
						pxya[2]:=parm^.pb_x+parm^.pb_w-2-2;
						pxya[3]:=pxya[1];
						pxya[4]:=pxya[2];
						pxya[5]:=parm^.pb_y;
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya)
					end;
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vsl_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawCardBox:=NORMAL
	end;


function DrawCardTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var dummy,
	    teff,q,l,
	    hkpos,i,
	    xpos,ypos: integer;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				d_clip[0]:=pb_x;
				d_clip[1]:=pb_y;
				d_clip[2]:=pb_x+pb_w-1;
				d_clip[3]:=pb_y+pb_h-1
			end;
		with Application^ do
			begin
				vswr_mode(vdiHandle,MD_REPLACE);
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,SysInfo.BGDefCol);
				v_bar(vdiHandle,d_clip);
				vst_alignment(vdiHandle,TA_LEFT,TA_TOP,dummy,dummy);
				vsl_color(vdiHandle,Black);
				hkpos:=-1;
				if parm^.pb_parm<>0 then
					begin
						d_chr:=PChar(parm^.pb_parm);
						l:=min(StrLen(d_chr),127);
						d_str[0]:=chr(l);
						if l>0 then
							begin
								i:=1;
								for q:=1 to l do
									begin
										if d_chr^='&' then
											if hkpos<0 then
												if PChar(longint(d_chr)+1)^<>#0 then
													begin
														hkpos:=q-1;
														dec(d_str[0]);
														inc(longint(d_chr));
														continue
													end;
										d_str[i]:=d_chr^;
										inc(longint(d_chr));
										inc(i)
									end
							end
					end
				else
					d_str[0]:=#0;
				vqt_extent(vdiHandle,d_str,extent);
				xpos:=parm^.pb_x+((parm^.pb_w-extent[4]-extent[6]) shr 1);
				ypos:=parm^.pb_y+((parm^.pb_h-extent[1]-extent[7]) shr 1);
				if Attr.Colors<16 then
					begin
						pxya[0]:=parm^.pb_x;
						pxya[1]:=parm^.pb_y+parm^.pb_h-1;
						pxya[2]:=pxya[0];
						pxya[3]:=parm^.pb_y;
						pxya[4]:=parm^.pb_x+parm^.pb_w-CARD_OFFS-2;
						pxya[5]:=pxya[3];
						pxya[6]:=pxya[4];
						pxya[7]:=pxya[1];
						if bTst(parm^.pr_currstate,SELECTED) then
							begin
								pxya[8]:=pxya[0]+parm^.pb_w-1;
								pxya[9]:=pxya[1];
								vPline(vdiHandle,5,pxya);
								vsf_color(vdiHandle,Black);
								d_clip[0]:=parm^.pb_x+parm^.pb_w-3;
								d_clip[1]:=parm^.pb_y+2;
								d_clip[2]:=d_clip[0]+1;
								d_clip[3]:=parm^.pb_y+parm^.pb_h-1;
								v_bar(vdiHandle,d_clip)
							end
						else
							begin
								inc(pxya[0],3);
								pxya[2]:=pxya[0];
								inc(pxya[3],3);
								inc(pxya[4]);
								pxya[5]:=pxya[3];
								pxya[6]:=pxya[4];
								vPline(vdiHandle,4,pxya);
								pxya[0]:=parm^.pb_x;
								pxya[1]:=parm^.pb_y+parm^.pb_h-1;
								pxya[2]:=pxya[0]+parm^.pb_w-1;
								pxya[3]:=pxya[1];
								vPline(vdiHandle,2,pxya)
							end
					end
				else
					begin
						pxya[0]:=parm^.pb_x;
						pxya[1]:=parm^.pb_y+parm^.pb_h-2;
						pxya[3]:=parm^.pb_y+3;
						pxya[6]:=pxya[0]+parm^.pb_w-1-3;
						pxya[8]:=pxya[0]+parm^.pb_w-1;
						if not(bTst(parm^.pr_currstate,SELECTED)) then
							begin
								inc(pxya[0],2);
								dec(pxya[1]);
								inc(pxya[3],3);
								dec(pxya[6],2);
								dec(pxya[8],2)
							end;
						pxya[2]:=pxya[0];
						pxya[4]:=pxya[2]+3;
						pxya[5]:=pxya[3]-3;
						pxya[7]:=pxya[5];
						pxya[9]:=pxya[3];
						pxya[10]:=pxya[8];
						pxya[11]:=pxya[1];
						vsl_color(vdiHandle,Black);
						vPline(vdiHandle,6,pxya);
						inc(pxya[0]);
						inc(pxya[2]);
						inc(pxya[5]);
						dec(pxya[6]);
						inc(pxya[7]);
						vsl_color(vdiHandle,White);
						vPline(vdiHandle,4,pxya);
						pxya[0]:=pxya[6]+1;
						pxya[1]:=pxya[7];
						pxya[2]:=pxya[8]-1;
						pxya[3]:=pxya[9];
						pxya[4]:=pxya[10]-1;
						pxya[5]:=pxya[11];
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya);
						if not(bTst(parm^.pr_currstate,SELECTED)) then
							begin
								pxya[0]:=parm^.pb_x;
								pxya[1]:=parm^.pb_y+parm^.pb_h-2;
								pxya[2]:=pxya[0]+parm^.pb_w-1;
								pxya[3]:=pxya[1];
								pxya[4]:=pxya[2];
								pxya[5]:=pxya[3]+1;
								vsl_color(vdiHandle,Black);
								vPline(vdiHandle,2,pxya);
								if (parm^.pb_tree^[parm^.pb_obj].ob_type and crdFlags)=crdFirst then inc(pxya[0]);
								if (parm^.pb_tree^[parm^.pb_obj].ob_type and crdFlags)=crdLast then dec(pxya[2]);
								pxya[1]:=parm^.pb_y+parm^.pb_h-1;
								pxya[3]:=pxya[1];
								vsl_color(vdiHandle,White);
								vPline(vdiHandle,2,pxya)
							end
						else
							begin
								if (parm^.pb_tree^[parm^.pb_obj].ob_type and crdFlags)=crdFirst then
									begin
										vsl_color(vdiHandle,White);
										d_clip[0]:=parm^.pb_x+1;
										d_clip[1]:=parm^.pb_y+parm^.pb_h-1;
										d_clip[2]:=d_clip[0];
										d_clip[3]:=d_clip[1];
										vPline(vdiHandle,2,d_clip)
									end;
								if (parm^.pb_tree^[parm^.pb_obj].ob_type and crdFlags)=crdLast then
									begin
										vsl_color(vdiHandle,LBlack);
										d_clip[0]:=parm^.pb_x+parm^.pb_w-2;
										d_clip[1]:=parm^.pb_y+parm^.pb_h-1;
										d_clip[2]:=d_clip[0];
										d_clip[3]:=d_clip[1];
										vPline(vdiHandle,2,d_clip)
									end;
							end
					end;
				vsl_color(vdiHandle,Black);
				if (parm^.pb_tree^[parm^.pb_obj].ob_type and crdFlags)=crdFirst then
					begin
						d_clip[0]:=parm^.pb_x;
						d_clip[1]:=parm^.pb_y+parm^.pb_h-1;
						d_clip[2]:=d_clip[0];
						d_clip[3]:=d_clip[1];
						vPline(vdiHandle,2,d_clip)
					end;
				if (parm^.pb_tree^[parm^.pb_obj].ob_type and crdFlags)=crdLast then
					begin
						d_clip[0]:=parm^.pb_x+parm^.pb_w-1;
						d_clip[1]:=parm^.pb_y+parm^.pb_h-1;
						d_clip[2]:=d_clip[0];
						d_clip[3]:=d_clip[1];
						vPline(vdiHandle,2,d_clip)
					end;
				if not(bTst(parm^.pr_currstate,SELECTED)) then
					begin
						inc(xpos);
						inc(ypos,2)
					end;
				vswr_mode(vdiHandle,MD_TRANS);
				if bTst(parm^.pr_currstate,DISABLED) then teff:=TF_LIGHTENED
				else
					teff:=TF_NORMAL;
				if (hkpos>=0) and (parm^.pb_parm<>0) then
					begin
						vst_effects(vdiHandle,teff or TF_UNDERLINED);
						if not(bTst(parm^.pr_currstate,DISABLED)) and (Attr.Colors>=16) then
							vst_color(vdiHandle,SysInfo.HotKeyCol)
						else
							vst_color(vdiHandle,Black);
						if hkpos=0 then extent[2]:=0
						else
							begin
								d_btn[0]:=chr(hkpos);
								for q:=1 to hkpos do d_btn[q]:=d_str[q];
								vqt_extent(vdiHandle,d_btn,extent)
							end;
						d_btn[0]:=#1;
						d_btn[1]:=PChar(parm^.pb_parm+hkpos+1)^;
						vgText(vdiHandle,xpos+extent[2],ypos,d_btn)
					end;
				vst_effects(vdiHandle,teff);
				vst_color(vdiHandle,Black);
				vgText(vdiHandle,xpos,ypos,d_str);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vst_effects(vdiHandle,TF_NORMAL);
				vst_alignment(vdiHandle,TA_LEFT,TA_BASELINE,dummy,dummy);
				vswr_mode(vdiHandle,MD_REPLACE);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawCardTitle:=NORMAL
	end;


begin
	defcolfg.rgb.reserved:=0;
	defcolfg.rgb.red:=0;
	defcolfg.rgb.green:=0;
	defcolfg.rgb.blue:=0;
end.