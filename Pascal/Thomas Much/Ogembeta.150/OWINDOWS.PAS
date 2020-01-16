{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *        Unit  O W I N D O W S         *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        13.07.1992  *
 *      letztes Update am:  05.03.1999  *
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

unit OWindows;

interface

uses

	Tos,Gem,Objects,OTypes,OProcs;

const

	S_Esc        = gem.Esc;
	S_Undo       = gem.Undo;
	S_Help       = gem.Help;

type

	PEvent       = ^TEvent;
	PWindow      = ^TWindow;
	PDialog      = ^TDialog;
	PKeyMenu     = ^TKeyMenu;

	PEventObject = ^TEventObject;
	TEventObject = object(TObject)
		public
		EventList: PEvent;
		constructor Init;
		destructor Done; virtual;
	end;

	TEvent       = object(TObject)
		public
		Parent: PEventObject;
		Style : word;
		constructor Init(AParent: PEventObject);
		destructor Done; virtual;
		function TestKey(Stat,Key: integer): boolean; virtual;
		function TestButton(mX,mY,BStat,KStat,Clicks: integer): boolean; virtual;
		function TestMouse(M,mX,mY,BStat,KStat: integer): boolean; virtual;
		function TestMessage(Pipe: Pipearray): boolean; virtual;
		function TestMenu(mNum: integer): boolean; virtual;
		procedure Work; virtual;
		function Previous: PEvent;
		function Next: PEvent;
		private
		Prev,
		Nxt : PEvent
	end;

	PValidator   = ^TValidator;
	TValidator   = object(TObject)
		public
		Status,
		Options: Word;
		Window : PDialog;
		constructor Init;
		procedure Error; virtual;
		function IsValid(s: string): boolean; virtual;
		function IsValidInput(var s: string; SuppressFill: boolean): boolean; virtual;
		function Valid(s: string): boolean; virtual;
	end;

	PIcon = ^TIcon;
	TIcon = object(TEvent)
		public
		XPos,
		YPos,
		Click,
		Shift,
		VStat,
		VKey   : integer;
		ADialog: PDialog;
		constructor Init(AParent: PEventObject; ATree,AnIndex,iX,iY: integer; Movable,Selectble: boolean; AName,Hlp: string);
		destructor Done; virtual;
		function TestButton(mX,mY,BStat,KStat,Clicks: integer): boolean; virtual;
		function TestKey(Stat,Key: integer): boolean; virtual;
		function GetOutline(var IcnRect,TxtRect: GRECT): boolean; virtual;
		function IsSelected(r: GRECT): boolean; virtual;
		procedure SetText(AName: string); virtual;
		function GetText: string; virtual;
		procedure SetPos(iX,iY: integer; Redraw: boolean); virtual;
		procedure SetCheck(CheckFlag: integer); virtual;
		function GetCheck: integer; virtual;
		procedure Check; virtual;
		procedure Uncheck; virtual;
		procedure Toggle; virtual;
		procedure Hide(Draw: boolean); virtual;
		procedure Unhide; virtual;
		function IsHidden: boolean; virtual;
		procedure Paint; virtual;
		function IsHelpAvailable: boolean; virtual;
		function GetHelp: string; virtual;
		procedure SetHelp(Hlp: string); virtual;
		procedure IMMoved(X,Y: integer); virtual;
		private
		icontext,
		BHelp       : PString;
		IsMovable,
		IsSelectable,
		rubsel,
		hideflag    : boolean;
		txrel,
		tyrel,
		ObjTree,
		ObjIndx     : integer;
		ObjAddr     : PObj;
		VObj        : AESObject;
		procedure RedrawParent;
	end;

	PClipboard = ^TClipboard;
	TClipboard = object (TObject)
		public
		Parent: PObject;
		constructor Init(AParent: PObject);
		function OpenClipboard(Write: boolean): boolean; virtual;
		function IsOpen: boolean; virtual;
		function GetClipboardFilename: string; virtual;
		function GetPriorityClipboardFormat(PriorityList: string): string; virtual;
		function IsClipboardFormatAvailable(Format: string): boolean; virtual;
		function EmptyClipboard: boolean; virtual;
		procedure SetClipboardFormat(Mask: word; Ext: string); virtual;
		function CloseClipboard: boolean; virtual;
		private
		openflag,
		writeflag: boolean;
		clippath,
		formats  : PString;
		clipext  : string[4];
		clipmask : word
	end;

	PControl     = ^TControl;
	TControl     = object(TObject)
		public
		Parent : PDialog;
		Style  : word;
		Flags  : byte;
		ObjIndx,
		ID     : integer;
		ObjAddr: PObj;
		UsrDef : boolean;
		UsrBlk : USERBLK;
		constructor Init(AParent: PDialog; AnIndx: integer; Hlp: string);
		destructor Done; virtual;
		function TestIndex(AnIndx: integer): boolean; virtual;
		function TestID(AnID: integer): boolean; virtual;
		function TestShortCut(Key: integer): boolean; virtual;
		procedure SetShortCut(Key: char); virtual;
		procedure SetFlags(Mask: byte; OnOff: boolean); virtual;
		function IsFlagSet(Mask: byte): boolean;
		procedure SetState(StateFlag: integer); virtual;
		function GetState: integer; virtual;
		procedure Disable; virtual;
		procedure Enable; virtual;
		procedure SetColor(Color: integer); virtual;
		function GetColor: integer; virtual;
		procedure Hide(Draw: boolean); virtual;
		procedure Unhide; virtual;
		function IsHidden: boolean; virtual;
		procedure DisableTransfer; virtual;
		procedure EnableTransfer; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
		procedure Paint; virtual;
		function IsHelpAvailable: boolean; virtual;
		function GetHelp: string; virtual;
		procedure SetHelp(Hlp: string); virtual;
		function ExtFocusKey(Stat,Key: integer): boolean; virtual;
		procedure ExtFocusPaint(r: GRECT); virtual;
		function Previous: PControl;
		function Next: PControl;
		private
		Prev,
		Nxt     : PControl;
		BHelp   : PString;
		shortcut: integer
	end;

	PButton      = ^TButton;
	TButton      = object(TControl)
		public
		constructor Init(AParent: PDialog; AnIndx,AnID: integer; UserDef: boolean; Hlp: string);
		destructor Done; virtual;
		function Install: boolean; virtual;
		procedure Deinstall; virtual;
		procedure SetShortCut(Key: char); virtual;
		procedure SetText(ATextString: string); virtual;
		function GetText: string; virtual;
		private
		TextLen : integer;
		oldflags,
		oldstate: word;
		function GetRawText: string;
	end;

	PStatic      = ^TStatic;
	TStatic      = object(TControl)
		public
		TextLen: integer;
		constructor Init(AParent: PDialog; AnIndx,ATextLen: integer; UserDef: boolean; Hlp: string);
		destructor Done; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure Paint; virtual;
		procedure SetText(ATextString: string); virtual;
		function GetText: string; virtual;
		function GetTextLen: integer; virtual;
		procedure Clear; virtual;
		private
		oldflags,
		oldtype  : word;
		firstchar,
		usrused  : boolean
	end;

	PEdit        = ^TEdit;
	TEdit        = object(TStatic)
		public
		Validator: PValidator;
		Clipboard: PClipboard;
		constructor Init(AParent: PDialog; AnIndx,ATextLen: integer; Hlp: string);
		destructor Done; virtual;
		function GetState: integer; virtual;
		procedure SetState(StateFlag: integer); virtual;
		procedure SetText(ATextString: string); virtual;
		procedure SetColor(Color: integer); virtual;
		procedure Paint; virtual;
		procedure Clear; virtual;
		procedure Edit; virtual;
		function IsValid(ReportError: boolean): boolean; virtual;
		function CanClose: boolean; virtual;
		function CanUndo: boolean; virtual;
		procedure Undo; virtual;
		procedure Paste; virtual;
		procedure Copy; virtual;
		procedure Cut; virtual;
		procedure Focus; virtual;
		function IsModified: boolean; virtual;
		procedure ClearModify; virtual;
		procedure SetValidator(AValid: PValidator); virtual;
		procedure SetCursor(CPos: integer); virtual;
		function GetCursor: integer; virtual;
		function GetClipboard: PClipboard; virtual;
		private
		Uptr,
		TPtr     : PChar;
		modified : boolean;
		EdIdx    : integer;
		procedure colEnable;
		procedure colDisable;
	end;

	PPopup       = ^TPopup;
	TPopup       = object(TEvent)
		public
		PopTree  : PTree;
		pX,
		pY,
		pIndex,
		pStart,
		pRows,
		pFlag,
		CheckMark: integer;
		Shadow,
		AutoCheck: boolean;
		List     : PStringCollection;
		constructor Init(AParent: PEventObject; tIndx,oIndx,stIndx: integer);
		constructor InitCollection(AParent: PEventObject; ACollection: PStringCollection; DisposeColl: boolean; MinColumns: integer);
		destructor Done; virtual;
		procedure SetPopTree(tree: PTree); virtual;
		procedure FreePopTree; virtual;
		procedure SetCollection(ACollection: PStringCollection); virtual;
		function pMax: integer; virtual;
		function Execute: integer; virtual;
		function ClickExit(Indx,mX,mY,BStat: integer): boolean; virtual;
		function ExitPop(Indx,mX,mY: integer): integer; virtual;
		function KeyExit(Stat,Key: integer): integer; virtual;
		procedure SetSelection(nr: integer); virtual;
		function GetSelection: integer; virtual;
		procedure SetText(nr: integer; ATextString: string); virtual;
		function GetText(nr: integer): string; virtual;
		procedure SetState(nr,StateFlag: integer); virtual;
		function GetState(nr: integer): integer; virtual;
		procedure Disable(nr: integer); virtual;
		procedure Enable(nr: integer); virtual;
		procedure SetCheck(nr,CheckFlag: integer); virtual;
		function GetCheck(nr: integer): integer; virtual;
		procedure Check(nr: integer); virtual;
		procedure Uncheck(nr: integer); virtual;
		procedure Toggle(nr: integer); virtual;
		procedure SetOffset(Offs: integer); virtual;
		function GetOffset: integer; virtual;
		private
		mnusr    : USERBLK;
		wait0,
		active,
		lfrtcrs,
		lstdspose: boolean;
		obj,
		listoffs,
		mincols  : integer;
		popsize  : longint;
		emptylist: PChar;
		procedure MouseSim(sobj: integer);
		function isstring(nr: integer): boolean;
		function isanyenabled: boolean;
		procedure checkoffs;
		procedure filllist(draw: boolean; diff: integer);
		procedure commoninit;
	end;

	PScroller    = ^TScroller;
	TScroller    = object(TObject)
		public
		Window       : PWindow;
		XUnit,
		YUnit        : integer;
		XPos,
		Ypos,
		XRange,
		YRange,
		XLine,
		YLine,
		XPage,
		YPage        : longint;
		Style        : word;
		TrackMode,
		HasHScrollBar,
		HasVScrollBar: boolean;
		constructor Init(TheWindow: PWindow; TheXUnit,TheYUnit: integer; TheXRange,TheYRange: longint);
		destructor Done; virtual;
		procedure HScroll; virtual;
		procedure VScroll; virtual;
		function IsVisibleRect(X,Y,XExt,YExt: longint): boolean; virtual;
		procedure ScrollBy(dX,dY: longint); virtual;
		procedure ScrollTo(X,Y: longint); virtual;
		procedure SetPageSize; virtual;
		procedure SetSBarRange; virtual;
		procedure SetRange(TheXRange,TheYRange: longint); virtual;
		procedure SetUnits(TheXUnit,TheYUnit: integer); virtual;
		function GetXOrg: longint; virtual;
		function GetYOrg: longint; virtual;
		procedure RedrawParent(XDif,YDif: longint); virtual;
		private
		procedure ParentPaint(xdif,ydif: longint);
	end;

	TWindow      = object(TEventObject)
		public
		Attr     : TWindowAttr;
		Class    : TWndClass;
		IconClass: TIconWndClass;
		Parent,
		ChildList: PWindow;
		Scroller : PScroller;
		Icon     : PIcon;
		DlgTree  : PTree;
		Full,
		Curr,
		Work     : GRECT;
		vdiHandle: integer;
		workIn   : workin_ARRAY;
		workOut  : workout_ARRAY;
		Clipboard: PClipboard;
		constructor Init(AParent: PWindow; ATitle: string);
		destructor Done; virtual;
		function GetVDIHandle: integer; virtual;
		procedure SetupVDI; virtual;
		function GetStyle: integer; virtual;
		function GetScroller: PScroller; virtual;
		function GetClipboard: PClipboard; virtual;
		function GetOLGAGroup: integer;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		procedure GetIconWindowClass(var AWndClass: TIconWndClass); virtual;
		function GetClassName: string; virtual;
		function GetIconTitle: string; virtual;
		function GetTitle: string;
		function CanClose: boolean; virtual;
		function IsIconified: boolean;
		function IsShaded: boolean;
		function IsModeless: boolean;
		function IsDialog: boolean; virtual;
		function IsTop: boolean;
		procedure EnableAutoCreate;
		procedure DisableAutoCreate;
		procedure GetFull; virtual;
		procedure GetCurr;
		procedure GetRealCurr(var r: GRECT);
		procedure GetWork; virtual;
		procedure GetVWork(var r: GRECT); virtual;
		procedure SetCurr(r: GRECT); virtual;
		procedure SetWork(r: GRECT); virtual;
		procedure LoadIcon(Icn: PIcon); virtual;
		procedure FreeIcon; virtual;
		procedure LoadMenu(Indx: integer; Tune: boolean); virtual;
		procedure FreeMenu; virtual;
		procedure LoadToolbar(Indx: integer); virtual;
		procedure SwitchToolbar(Indx: integer); virtual;
		procedure FreeToolbar(Indx: integer); virtual;
		procedure SetToolbarPos(Opposite: boolean);
		procedure LoadDialog(Indx: integer); virtual;
		procedure FreeDialog; virtual;
		procedure SetDlgTree(tree: PTree); virtual;
		procedure UpdateDialog; virtual;
		procedure SetupSize; virtual;
		procedure SetupWindow; virtual;
		procedure ShutdownWindow; virtual;
		procedure MakeWindow; virtual;
		procedure Create; virtual;
		procedure CreateChildren; virtual;
		procedure OpenWindow; virtual;
		procedure CloseWindow; virtual;
		procedure Destroy; virtual;
		procedure RawDestroy; virtual;
		procedure Top; virtual;
		procedure FullSize; virtual;
		procedure Size(r: GRECT); virtual;
		procedure Move(r: GRECT); virtual;
		procedure InitPaint; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure IconPaint(var PaintInfo: TPaintStruct); virtual;
		procedure ExitPaint; virtual;
		procedure ForceRedraw; virtual;
		procedure ForceVRedraw; virtual;
		procedure SetTitle(ATitle: string);
		procedure SetSubTitle(AnInfo: string);
		procedure SetGadgets(Style: integer);
		procedure SetGadgetsSize(Style: integer; r: GRECT);
		procedure SetCursor(Crs: HCursor);
		procedure Calc(ctype: integer; ri: GRECT; var ro: GRECT); virtual;
		procedure ChkAlign(var r: GRECT); virtual;
		procedure ChkSize(var r: GRECT); virtual;
		procedure GetWorkMin(var minX,minY: integer); virtual;
		procedure GetWorkMax(var maxX,maxY: integer); virtual;
		function GetDC: integer;
		procedure ReleaseDC;
		procedure MNSelected(meNum,mtNum: integer; Tree: PTree; PrIndx: integer); virtual;
		procedure HandleMenu(meNum: integer); virtual;
		procedure WMRedraw(X,Y,W,H: integer); virtual;
		procedure WMTopped; virtual;
		procedure WMClosed; virtual;
		procedure WMFulled; virtual;
		procedure WMArrowed(waA,SpeedA,waB,SpeedB: integer); virtual;
		procedure WMHSlid(Value: integer); virtual;
		procedure WMVSlid(Value: integer); virtual;
		procedure WMSized(X,Y,W,H: integer); virtual;
		procedure WMMoved(X,Y,W,H: integer); virtual;
		function DoRubbox(mX,mY,KStat: integer): boolean; virtual;
		procedure WMButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
		procedure WMClick(mX,mY,KStat: integer); virtual;
		procedure WMDblClick(mX,mY,KStat: integer); virtual;
		procedure WMRButton(mX,mY,KStat,Clicks: integer); virtual;
		procedure WMRubbox(r: GRECT); virtual;
		procedure WMRBoxChanged(r: GRECT); virtual;
		procedure WMRBoxCheck(x,y,xmin,ymin,xmax,ymax: integer; var mx,my: integer); virtual;
		procedure WMNewTop; virtual;
		procedure WMUntopped; virtual;
		procedure WMOnTop; virtual;
		procedure WMBottomed; virtual;
		procedure WMToolbar(Indx,BStat,KStat,Clicks: integer); virtual;
		function WMKeyDown(Stat,Key: integer): boolean; virtual;
		procedure WMDragDrop(PipeHnd,OrgID,mX,mY,KStat: integer); virtual;
		procedure WMIconify(iX,iY,iW,iH: integer); virtual;
		procedure WMUniconify(oX,oY,oW,oH: integer); virtual;
		procedure WMShaded; virtual;
		procedure WMUnshaded; virtual;
		procedure OLGAUpdated(OrgID,SrvID,InfoNr: integer; Link: string); virtual;
		procedure OLGARenameLink(OrgID: integer; OldLink,NewLink: string); virtual;
		procedure OLGALinkBroken(OrgID: integer; Link: string); virtual;
		function DDGetPreferredTypes: string; virtual;
		function DDGetPath: string; virtual;
		function DDHeaderReply(dType,dName,fName: string; dSize: longint; OrgID,mX,mY,KStat: integer): byte; virtual;
		function DDReadData(dType,dName,fName: string; dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean; virtual;
		function DDReadArgs(dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean; virtual;
		procedure DDFinished(OrgID,mX,mY,KStat: integer); virtual;
		function FontChanged(OrgID,AnID,ASize,AColor,BackColor,Effects,ARotation,ASkew,HorAlign,VertAlign,AWidth,TrackKern: integer; Size31: fix31; PairKern,cWnd: boolean): boolean; virtual;
		procedure ColorID(OrgID,mX,mY,palIndex: integer); virtual;
		procedure Cut; virtual;
		procedure Copy; virtual;
		procedure Paste; virtual;
		procedure Delete; virtual;
		procedure SelectAll; virtual;
		procedure Print; virtual;
		function IsHelpAvailable(mX,mY: integer): boolean; virtual;
		function GetHelp(mX,mY: integer): string; virtual;
		function Previous: PWindow;
		function Next: PWindow;
		function At(Index: integer): PWindow;
		function IndexOf(Item: PWindow): integer;
		function FirstWndThat(Test: PIterationFunc): PWindow;
		procedure ForEachWnd(Action: PIterationProc);
		procedure IconSelect(OnOff: boolean; OffExc: integer); virtual;
		function FirstIcon(OnAll: boolean): PIcon;
		function NextIcon: PIcon;
		function FirstWorkRect(var Rect: GRECT): boolean;
		function NextWorkRect(var Rect: GRECT): boolean;
		private
		Prev,
		Nxt     : PWindow;
		nxticn  : PEvent;
		icnonall,
		ownhndl,
		tunemenu: boolean;
		tbval   : array [0..MAXTOOLBARS] of TToolbarDescr;
		icntitl : PString;
		icnx,
		tbtree,
		icfpos,
		icfstyle,
		mnsize  : integer;
		icfcurr : GRECT;
		procedure EnableCrsWatch;
		procedure DisableCrsWatch;
		procedure Iconify(fade: boolean);
		function CycleTop(start: PWindow; backwrd: boolean): boolean;
	end;

	PApplication = ^TApplication;
	TApplication = object(TEventObject)
		public
		Name,
		apName,
		apPath          : PString;
		Status,
		vdiHandle,
		aesHandle,
		apID,
		menuID          : integer;
		workIn          : workin_ARRAY;
		workOut         : workout_ARRAY;
		Attr            : TGEMAttr;
		XAcc            : TXAccAttr;
		XAccList        : PCollection;
		OLGA            : TOLGAAttr;
		Icon            : PIcon;
		Clipboard       : PClipboard;
		MetaDOS         : PMetaInfo;
		MainWindow      : PWindow;
		RscPtr          : PRsFile;
		MenuTree        : PTree;
		MessageBuffer   : pointer;
		MessageBLen,
		AVServer,
		OLGAManager     : integer;
		apDTA           : DTA;
		SpeedoActive,
		GDOSActive,
		MultiTOS,
		MiNTActive,
		MagiCActive,
		NAESActive,
		ExtObjects,
		CanScaleIMG,
		CanTransferBits,
		HasNewColorFn,
		HasColorIcons,
		BubbleHelpActive,
		IsQSBUsed,
		FPUAvailable,
		OSBAvailable,
		Terminating,
		Multitasking,
		MemoryProtection: boolean;
		constructor Init(AName: string);
		destructor Done; virtual;
		function CanClose: boolean; virtual;
		function IsIconified: boolean;
		procedure LoadResource(FileHiRes,FileLoRes: string); virtual;
		procedure InitResource(AddrHiRes,AddrLoRes: pointer); virtual;
		function GetAddr(Indx: integer): PTree; virtual;
		function GetFImagePtr(Indx: integer): pointer; virtual;
		function GetFStringPtr(Indx: integer): PChar; virtual;
		function GetFString(Indx: integer): string; virtual;
		function GetIconTitle: string; virtual;
		function GetClipboard: PClipboard; virtual;
		procedure GetXAccAttr(var XAccAttr: TXAccAttr); virtual;
		function GetOLGAAttr(var OLGAAttr: TOLGAAttr): boolean; virtual;
		function SendWndMessage(gHnd: integer; Msg: pointer; sID,Icn: boolean): boolean; virtual;
		procedure Broadcast(Msg: pointer; sID: boolean); virtual;
		function FindApplication(AName: string; AnID: integer; var XAccAttr: TXAccAttr): boolean; virtual;
		function FirstApplication(AType: TAppTypeMR; GenName: string; var XAccAttr: TXAccAttr): boolean;
		function NextApplication(var XAccAttr: TXAccAttr): boolean;
		procedure FreeResource; virtual;
		procedure InstallDesktop(tIndx,oIndx: integer); virtual;
		procedure RemoveDesktop; virtual;
		procedure LoadIcon(icnTree,icnIndx: integer); virtual;
		procedure FreeIcon; virtual;
		procedure LoadMenu(Indx: integer); virtual;
		procedure DrawMenu; virtual;
		procedure FreeMenu; virtual;
		function AutoFolder: boolean; virtual;
		procedure InitGEM; virtual;
		procedure ExitGEM; virtual;
		procedure SetupVDI; virtual;
		procedure InitApplication; virtual;
		procedure InitInstance; virtual;
		procedure InitMainWindow; virtual;
		function GetGPWindow(gHnd: integer): PWindow;
		function GetPWindow(Hnd: HWnd): PWindow;
		function GetPTopWindow: PWindow;
		function GetMsTimer: longint; virtual;
		procedure GetCrsRect(var crect: GRECT); virtual;
		function GetEvent(var data: TEventData): integer; virtual;
		procedure MessageLoop; virtual;
		procedure MUKeybd(data: TEventData); virtual;
		procedure MUButton(data: TEventData); virtual;
		procedure MURubbox(r: GRECT); virtual;
		procedure MURBoxChanged(r: GRECT); virtual;
		procedure MUM1(data: TEventData); virtual;
		procedure MUM2(data: TEventData); virtual;
		procedure MUMesag(data: TEventData); virtual;
		procedure MUTimer(data: TEventData); virtual;
		function ReadExtMessage(Pipe: Pipearray): boolean; virtual;
		procedure MNSelected(meNum,mtNum: integer; Tree: PTree; PrIndx: integer); virtual;
		procedure ACOpen(mID: integer); virtual;
		function ACClose(mID,Why: integer): integer; virtual;
		function APTerm(Why: integer): integer; virtual;
		procedure APDragDrop(PipeID,OrgID,WindID,mX,mY,KStat: integer); virtual;
		procedure ShutCompleted(Stat,ErrID,ErrCode: integer); virtual;
		procedure ResChCompleted(Stat: integer); virtual;
		procedure CHExit(ChID,ChRet: integer); virtual;
		procedure SHWDraw(Drive: integer); virtual;
		procedure FileSelected(Window: PWindow; OrgID: integer; Group: byte; Path: string; Files: PChar); virtual;
		procedure SCChanged(OrgID: integer; Bits: word; Ext: string); virtual;
		procedure PRNChanged(OrgID,Device,Action: integer); virtual;
		procedure FNTChanged(OrgID: integer); virtual;
		procedure ColorsChanged(OrgID: integer); virtual;
		procedure ColorID(OrgID,mX,mY,palIndex: integer); virtual;
		procedure XAccID(OrgID,mID: integer; Msg,Ver: byte; pName: PChar); virtual;
		procedure XAccAcc(accID,mID: integer; Msg,Ver: byte; pName: PChar); virtual;
		function XAccInsert(accID,mID: integer; Msg,Ver: byte; pName: PChar): boolean; virtual;
		procedure XAccExit(OrgID: integer); virtual;
		function XAccText(OrgID: integer; pText: pointer): boolean; virtual;
		function XAccKey(OrgID,Stat,Key: integer): boolean; virtual;
		function XAccMeta(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean; virtual;
		function XAccIMG(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean; virtual;
		procedure OLEExit(OrgID: integer); virtual;
		procedure OLENew(OrgID,OLGAMsg,OLGAVer,OEP1,OEP2,ManagerVer: integer); virtual;
		procedure OLGAInit(OrgID,Msg,Ver,eFlag: integer); virtual;
		procedure OLGAUpdated(OrgID,SrvID,InfoNr,Group: integer; Link: string); virtual;
		procedure OLGAGetInfo(OrgID,InfoNr: integer); virtual;
		procedure OLGAInfo(OrgID,InfoNr: integer; InfoFile: string); virtual;
		procedure OLGARenameLink(OrgID,Group: integer; OldLink,NewLink: string); virtual;
		procedure OLGALinkBroken(OrgID,Group: integer; Link: string); virtual;
		procedure OLGAAck(Pipe: Pipearray); virtual;
		procedure OLGAObjects(OrgID,Rest: integer; Ext,Descr: string); virtual;
		procedure OLGAIdle(OrgID,d4,d5,d6,d7: integer); virtual;
		procedure AVProtokoll(OrgID: integer; Msg: word; AName: string); virtual;
		procedure VAProtoStatus(OrgID: integer; Msg: word; AName: string); virtual;
		function AVInsert(accID: integer; SrvMsg,AccMsg: word; AName: string): boolean; virtual;
		procedure AVSendKey(Stat,Key: integer); virtual;
		procedure AVSendClick(mX,mY,BStat,KStat,Clicks: integer); virtual;
		procedure VAStart(OrgID: integer; Cmd: PChar); virtual;
		procedure AVStartProg(OrgID,Ret: integer; Prg,Cmd: string); virtual;
		procedure AVExit(OrgID: integer); virtual;
		function DDGetPreferredTypes(WindID: integer): string; virtual;
		function DDGetPath(WindID: integer): string; virtual;
		function DDHeaderReply(dType,dName,fName: string; dSize: longint; OrgID,WindID,mX,mY,KStat: integer): byte; virtual;
		function DDReadData(dType,dName,fName: string; dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean; virtual;
		function DDReadArgs(dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean; virtual;
		procedure DDFinished(OrgID,WindID,mX,mY,KStat: integer); virtual;
		function StartApp(Path,Cmd: string): integer;
		procedure Cut; virtual;
		procedure Copy; virtual;
		procedure Paste; virtual;
		procedure Delete; virtual;
		procedure SelectAll; virtual;
		procedure HandleDragDrop(PipeHnd,OrgID,WindID,mX,mY,KStat: integer); virtual;
		procedure HandleKeybd(Stat,Key: integer); virtual;
		procedure HandleButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
		procedure HandleM1(mX,mY,BStat,KStat: integer); virtual;
		procedure HandleM2(mX,mY,BStat,KStat: integer); virtual;
		procedure HandleMesag(Pipe: Pipearray); virtual;
		procedure HandleAV(Pipe: Pipearray); virtual;
		procedure HandleXAcc(Pipe: Pipearray); virtual;
		procedure HandleTimer; virtual;
		procedure HandleMenu(meNum: integer); virtual;
		procedure HandleError; virtual;
		procedure Terminate; virtual;
		procedure Run; virtual;
		procedure Quit; virtual;
		procedure Bing; virtual;
		function At(Index: integer): PWindow;
		function IndexOf(Item: PWindow): integer;
		function FirstWndThat(Test: PIterationFunc): PWindow;
		procedure ForEachWnd(Action: PIterationProc);
		function FirstIcon(OnAll: boolean): PIcon;
		function NextIcon: PIcon; virtual;
		procedure IconSelect(OnOff: boolean; OffExc: integer); virtual;
		procedure IconPaint(Work: GRECT; var PaintInfo: TPaintStruct); virtual;
		procedure BubbleHelp(mX,mY: integer; Hlp: string; mouse,demon: boolean); virtual;
		function ExecDialog(ADialog: PDialog): integer; virtual;
		function Alert(AParent: PWindow; DefBtn: integer; Sign: longint; Txt,Btn: string): integer; virtual;
		function Popup(APopup: PPopup; x,y,Flag: integer): integer; virtual;
		function Rubbox(WHnd,x,y,xmin,ymin,xmax,ymax: integer; IconSel: boolean; var r: GRECT): boolean; virtual;
		procedure ReleaseMouseButton(Mask:integer);
		procedure InvalidateRect(Wnd: HWnd; Rect: PGRECT); virtual;
		procedure RestoreModalDialog(p: PWindow);
		procedure DeskRedraw; virtual;
		procedure SetQuit(mNum,tNum: integer); virtual;
		procedure GetMenuEntries(var Entries: TMenuEntries); virtual;
		procedure CheckMenuEntries; virtual;
		procedure SetError(AnError: integer); virtual;
		function ChkError: integer; virtual;
		function ChkSpeedoError: integer; virtual;
		procedure Error(ErrorCode: integer); virtual;
		procedure	FixResource(raddr: pointer; mode,what: boolean);
		function GetObjectParent(tree: PTree; indx: integer): integer;
		function IsTreeHidden(tree: PTree; pobj: integer): boolean;
		private
		Err,
		DlgTop,
		ticn,
		iicn,
		hwratio,
		xaccnlen   : integer;
		cmdlen,
		stewart,
		nxtapp     : longint;
		termflag,
		allicn,
		ddokflag,
		extmagxmenu,
		icnonall   : boolean;
		napptype   : TAppTypeMR;
		nappgen    : PString;
		startcmd   : pointer;
		nxticn     : PEvent;
		HMax       : HWnd;
		xfont      : Pipearray;
		mnusr      : USERBLK;
		pquit      : PKeyMenu;
		pcrswatch,
		icnwnd     : PWindow;
		wmnr       : HCursor;
		wmform     : MFORM;
		bubblebuf,
		xaccname   : PChar;
		menuentries: PMenuEntries;
		procedure MoveIcons(Wnd: PEventObject; Icn: PIcon; gHnd,mX,mY: integer);
		function find_object(tree: PTree; start,which: integer): integer;
		function ini_field(tree: PTree; start: integer): integer;
		function form_keybd(pd: PDialog; fo_ktree: PTree; fo_kobject,fo_kobnext,fo_kchar,fo_kstat: integer; var fo_knxtobject,fo_knxtchar: integer): integer;
		function form_button(pd: PDialog; fo_bobject,fo_bclicks: integer; var fo_bnxtobj: integer): boolean;
		procedure GOErrAlert(sign: integer; msg: string);
		function XAccMR2HR(MR: TAppTypeMR): string;
		function MenuCorrect(mt: PTree; var i: integer): boolean;
		procedure MenuTune;
		procedure TitleSelect(pw: PWindow; indx: integer; select: boolean);
	end;

	TDialog      = object(TWindow)
		public
		CtrlList      : PControl;
		TransferBuffer: pointer;
		IsModal,
		Cont          : boolean;
		Result        : integer;
		constructor Init(AParent: PWindow; ATitle: string; Indx: integer);
		destructor Done; virtual;
		function GetVDIHandle: integer; virtual;
		function GetStyle: integer; virtual;
		procedure GetWindowClass(var AWndClass: TWndClass); virtual;
		function GetClassName: string; virtual;
		function GetKBHandler: PEvent; virtual;
		function IsDialog: boolean; virtual;
		procedure LoadDialog(Indx: integer); virtual;
		procedure FreeDialog; virtual;
		procedure UpdateDialog; virtual;
		procedure SetupSize; virtual;
		procedure SetupWindow; virtual;
		procedure MakeWindow; virtual;
		procedure Create; virtual;
		procedure OpenWindow; virtual;
		procedure CloseWindow; virtual;
		procedure Destroy; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure ObjcPaint(Indx: integer; Lazy: boolean);
		procedure ObjcPaintRect(Indx: integer; const Rect: GRECT; Lazy: boolean); virtual;
		procedure GetWorkMax(var maxX,maxY: integer); virtual;
		procedure WMClosed; virtual;
		procedure WMButton(mX,mY,BStat,KStat,Clicks: integer); virtual;
		function SelectDisabled(AnIndx,KStat,Clicks: integer): boolean; virtual;
		procedure Execute; virtual;
		procedure EndDlg(Indx: integer; DblClick: boolean); virtual;
		procedure TransferData(Direction: word); virtual;
		function ExitDlg(AnIndx: integer): boolean; virtual;
		function OK: boolean; virtual;
		function Cancel: boolean; virtual;
		function Help: boolean; virtual;
		function Undo: boolean; virtual;
		function Esc: boolean; virtual;
		function TestFKey(fNum: integer): integer; virtual;
		procedure Cut; virtual;
		procedure Copy; virtual;
		procedure Paste; virtual;
		procedure Delete; virtual;
		function FirstThat(Test: PIterationFunc): PControl;
		procedure ForEach(Action: PIterationProc);
		procedure SetDefaultButton(Obj: integer); virtual;
		function GetDefaultButton: integer;
		function InsertChar(ch: char): boolean; virtual;
		procedure InitFocus; virtual;
		procedure SetFocus(Obj: integer); virtual;
		function GetFocus: integer;
		procedure SetExtFocus(Obj: integer); virtual;
		function GetExtFocus: integer;
		function HasActiveFocus(obj: integer): boolean;
		procedure CallChanged(Indx: integer; dclk,edt,push: boolean); virtual;
		function GetHelp(mX,mY: integer): string; virtual;
		function GetModalTimer: longint; virtual;
		procedure HandleModalTimer; virtual;
		private
		edit_obj,
		next_obj,
		wmaxw,
		wmaxh,
		idx,
		extfocus,
		dlgsize : integer;
		BValid,
		d0fly,
		bsave,
		magxedit,
		obedinit,
		obedflag: boolean;
		BackGr  : MFDB;
		BLen,
		frwid   : longint;
		kbdh    : PEvent;
		pedt    : PEdit;
		pxfocus : PControl;
		procedure MoveDial(mX,mY: integer);
		procedure SaveBackground;
		procedure RestoreBackground;
		function objc_edit(var ob_edchar: integer; ob_edkind, ob_kstat: integer; clp: ARRAY_4; cclp: boolean): integer;
	end;

	PToolbar     = ^TToolbar;
	TToolbar     = object(TEvent)
		public
		ADialog : PDialog;
		VKey,
		VStat,
		ObjTree,
		ObjIndx : integer;
		ObjAddr : PObj;
		VPipe   : PPipearray;
		VGHnd   : boolean;
		constructor Init(AParent: PWindow; ATree,AnIndx,Stat,Key: integer; Msg: pointer; GetHnd,Switch: boolean; Hlp: string);
		destructor Done; virtual;
		function IsToolbarInstalled: boolean;
		function TestKey(Stat,Key: integer): boolean; virtual;
		function TestMessage(Pipe: Pipearray): boolean; virtual;
		function GetState: integer; virtual;
		procedure SetState(StateFlag: integer); virtual;
		procedure Disable; virtual;
		procedure Enable; virtual;
		procedure SetCheck(CheckFlag: integer); virtual;
		function GetCheck: integer; virtual;
		procedure Check; virtual;
		procedure Uncheck; virtual;
		procedure Toggle; virtual;
		function IsChecked: boolean; virtual;
		procedure Paint; virtual;
		function IsHelpAvailable: boolean; virtual;
		function GetHelp: string; virtual;
		procedure SetHelp(Hlp: string); virtual;
		procedure SetMenuIndex(Indx: byte); virtual;
		function GetMenuIndex: byte; virtual;
		procedure ClearMenuIndex; virtual;
		private
		IsSwitch: boolean;
		BHelp   : PString
	end;

	TKeyMenu     = object(TEvent)
		public
		ADialog: PDialog;
		VStat,
		VKey,
		VMNum,
		VTNum  : integer;
		VPipe  : PPipearray;
		VGHnd  : boolean;
		constructor Init(AParent: PEventObject; Stat,Key,mNum,tNum: integer);
		destructor Done; virtual;
		function TestKey(Stat,Key: integer): boolean; virtual;
		function TestMenu(mNum: integer): boolean; virtual;
		function GetState: integer; virtual;
		procedure SetState(StateFlag: integer); virtual;
		procedure Disable; virtual;
		procedure Enable; virtual;
		function GetText: string; virtual;
		procedure SetText(ATextString: string); virtual;
		function GetCheck: integer; virtual;
		procedure SetCheck(CheckFlag: integer); virtual;
		procedure Check; virtual;
		procedure Uncheck; virtual;
		procedure Toggle; virtual;
		private
		function InitMWrk: boolean;
		procedure ExitMWrk;
		function IsApp: boolean;
		function GetMenuTree: PTree;
	end;

	PSubMenu = ^TSubMenu;
	TSubMenu = object(TKeyMenu)
		Popup: PPopup;
		constructor Init(AParent: PEventObject; mNum,popTree,popIndex: integer);
		destructor Done; virtual;
		procedure Work; virtual;
		procedure HandleMenu(Indx: integer); virtual;
	end;

	PKey         = ^TKey;
	TKey         = object(TKeyMenu)
		public
		constructor Init(AParent: PEventObject; Stat,Key: integer; Msg: pointer; GetHnd: boolean);
		function TestMenu(mNum: integer): boolean; virtual;
	end;

	PMenu        = ^TMenu;
	TMenu        = object(TKeyMenu)
		public
		constructor Init(AParent: PEventObject; mNum: integer; Msg: pointer; GetHnd: boolean);
		function TestKey(Stat,Key: integer): boolean; virtual;
	end;


var

	Application: PApplication;
	pxya       : ptsin_ARRAY;
	SysInfo    : record
		HotKeyCol,
		UsrDefCol,
		BGDefCol   : integer;
		DefCol     : TCOLOR_ENTRY;
		DefColValid: boolean;
		Desktop    : GRECT;
		Font,
		SmallFont  : record
			ID,
			Point,
			Height,
			Width : integer
		end
	end;


function GEMVersion: word;
function IsDesktopActive: boolean;
procedure GetQSB(var p: pointer; var len: longint);
procedure GlobalAlloc(var p: pointer; size: longint);
procedure GlobalFree(var p: pointer; size: longint);
function GetTempDir: string;
function GetHomeDir(RootDefault: boolean): string;
function FilePathSelect(AParent: PWindow; ATitle,AMask: string; var APath,AFile: string; AllowPaths,ForceExist: boolean): boolean;
function FileSelect(AParent: PWindow; ATitle,AMask: string; var APath,AFile: string; ForceExist: boolean): boolean;
function XFileSelect(AParent: PWindow; ATitle,AMask: string; var APath,AFile: string; MaxFiles: integer; Group: byte; ForceExist,Modal: boolean): boolean;
function OpenPrivateProfile(FileName: string): boolean;
function SavePrivateProfile: boolean;
function ClosePrivateProfile: boolean;
function WritePrivateProfileString(AppName,KeyName,Value,FileName: string): boolean;
function WritePrivateProfileBool(AppName,KeyName: string; Value: boolean; FileName: string): boolean;
function WritePrivateProfileInt(AppName,KeyName: string; Value: longint; FileName: string): boolean;
function GetPrivateProfileString(AppName,KeyName,Default,FileName: string): string;
function GetPrivateProfileBool(AppName,KeyName: string; Default: boolean; FileName: string): boolean;
function GetPrivateProfileInt(AppName,KeyName: string; Default: longint; FileName: string): longint;
function GetPrivateProfileIntRange(AppName,KeyName: string; Default,MinVal,MaxVal: longint; FileName: string): longint;
function WriteProfileString(AppName,KeyName,Value: string): boolean;
function WriteProfileBool(AppName,KeyName: string; Value: boolean): boolean;
function WriteProfileInt(AppName,KeyName: string; Value: longint): boolean;
function GetProfileString(AppName,KeyName,Default: string): string;
function GetProfileBool(AppName,KeyName: string; Default: boolean): boolean;
function GetProfileInt(AppName,KeyName: string; Default: longint): longint;
function GetProfileIntRange(AppName,KeyName: string; Default,MinVal,MaxVal: longint): longint;
procedure vr_convert(handle: integer; psrcMFDB: MFDB; format: integer);
procedure vr_trnfm(handle: integer; psrcMFDB,pdesMFDB: MFDB);
procedure vdi_fix(var pfd: MFDB; theAddr: pointer; w,h: integer);
function SetSystemFont(handle: integer; var wc,hc,wb,hb: integer): integer;
function SetSmallSystemFont(handle: integer; var wc,hc,wb,hb: integer): integer;
function SetMouse(Indx: HCursor; Form: MFORMPtr): integer;
procedure GetMouse(var Indx: HCursor; var Form: MFORM);
procedure SetMousePos(mX,mY: integer);
function IsMouseVisible: boolean;
function IsMouseBusy: boolean;
procedure ShowMouse;
procedure HideMouse;
procedure ArrowMouse;
procedure BusyMouse;
procedure SliceMouse;
procedure SliceMouseNext;
procedure LastMouse;
function vst_fg_color(handle,color_space: integer; const fg_color: TCOLOR_ENTRY): integer;
function vst_bg_color(handle,color_space: integer; const bg_color: TCOLOR_ENTRY): integer;
function appl_xgetinfo(ap_gtype: integer; var ap_gout1,ap_gout2,ap_gout3,ap_gout4: integer): boolean;



implementation

uses

	Strings,Dos;

const

	outlwidth          = 3;
	Ctrl_Backdrop      = 25871;
	Ctrl_Fuller        = 26122;
	CtrlAlt_Iconify    = 14592;
	Ctrl_Cycle         = Ctrl_W;
	Ctrl_Close         = Ctrl_U;
	Ctrl_Quit          = Ctrl_Q;
	MAGIX              = $0399;
	GLOBAL             = $20;
	FIXRSC             = true;
	UNFIXRSC           = false;
	FIX_ALL            = true;
	FIX_BBONLY         = false;
	POP_MAXROWS        = 19;
	EDDRAW             = 42;
	EDIDXPOS           = 43;
	EDIDXABS           = 44;
	ED_CRSR            = 100;
	ED_DRAW            = 103;
	FMD_BACKWARD       = -1;
	FMD_FORWARD        = -2;
	FMD_DEFLT          = -3;
	ICF_GETPOS         = $0001;
	ICF_FREEPOS        = $0002;
	ICF_SNAP           = $0003;
	RSC_LOADED         : pointer = pointer(1);
	TEST_BEG_UPDATE    = BEG_UPDATE or $0100;
	WF_WINX            = 22360;
	WF_SHADE           = 22365;
	WM_M_BDROPPED      = 100;
	WinChangeFont      = 30961;
	SYSPROFILE         = 'user.inf';
	XSELMAX            = 18;
	WIN_TOPPED         = $7a22;
	WIN_CLOSED         = $7a23;

type

	INFOVSCRPtr = ^INFOVSCR;
	INFOVSCR    = record
		cookie,
		product: longint;
		version: word;
		x,y,w,h: integer
	end;

	STEW_COOKPtr = ^STEW_COOK;
	STEW_COOK    = record
		menu_on,
		bck_col,
		dis_col: integer
	end;

	PSelectric = ^TSelectric;
	TSelectric = record
		magic  : TCookieID;
		version: word
	end;

	PFdmStr = ^TFdmStr;
	TFdmStr = record
		magic : TCookieID;
		id,
		maxsel: integer;
		flags : longint;
		handle,
		server: integer;
		path  : array [0..255] of char
	end;

	PLTMFLY = ^LTMFLY;
	LTMFLY = record
		version,
		config,
		conf2,
		reserved     : word;
		di_fly,
		obj_clsize,
		do_key,
		init_keys,
		lookup_key,
		di_moveto,
		di_center    : pointer;
		ucol,
		aicol,
		aframe,
		flydelay     : integer;
		hist_insert,
		ins_spcchar,
		init_niceline: pointer
	end;

	PAFNT = ^AFNT;
	AFNT = record
		af_magic    : TCookieID;
		version,
		installed   : integer;
		afnt_getinfo: function(d1,d2: pointer; d3,d4,d5: longint; af_gtype: integer; var af_gout1,af_gout2,af_gout3,af_gout4: integer): integer;
	end;

	TedinfoArrayPtr    = ^TedinfoArray;
	TedinfoArray       = array [0..9999] of TEDINFO;

	AESTreePtrArrayPtr = ^AESTreePtrArray;
	AESTreePtrArray    = array [0..9999] of AESTreePtr;

	FreeStrPtrArrayPtr = ^FreeStrPtrArray;
	FreeStrPtrArray    = array [0..9999] of PChar;

	FreeImgPtrArrayPtr = ^FreeImgPtrArray;
	FreeImgPtrArray    = array [0..9999] of pointer;

	IconBlockArrayPtr  = ^IconBlockArray;
	IconBlockArray     = array [0..9999] of ICONBLK;

	BitBlockArrayPtr   = ^BitBlockArray;
	BitBlockArray      = array [0..9999] of BITBLK;

	PDKey              = ^TDKey;
	TDKey              = object(TEvent)
		function TestKey(Stat,Key: integer): boolean; virtual;
	end;

	PQKey              =  ^TQKey;
	TQKey              =  object(TKeyMenu)
		procedure Work; virtual;
	end;

	PMenuPopup = ^TMenuPopup;
	TMenuPopup = object(TPopup)
		function ExitPop(Indx,mX,mY: integer): integer; virtual;
		function KeyExit(Stat,Key: integer): integer; virtual;
	end;

	PAlrtDialog = ^TAlrtDialog;
	TAlrtDialog = object(TDialog)
		cntbutton,
		firstbutton: integer;
		function TestFKey(fNum: integer): integer; virtual;
	end;

	PIcnWnd            = ^TIcnWnd;
	TIcnWnd            = object(TWindow)
		icx,icy,icw,ich: integer;
		constructor Init(AParent: PWindow; ATitle: string; x,y,w,h: integer);
		procedure SetupWindow; virtual;
		procedure MakeWindow; virtual;
		procedure IconPaint(var PaintInfo: TPaintStruct); virtual;
	end;

	PXAccCollection    = ^TXAccCollection;
	TXAccCollection    = object(TCollection)
		procedure FreeItem(Item: pointer); virtual;
	end;

	PProfileCollection = ^TProfileCollection;
	TProfileCollection = object(TCollection)
		procedure FreeItem(Item: pointer); virtual;
	end;

var

	OldExit,
	icfserver,
	upath      : pointer;
	paf        : PAFNT;
	ltmf       : PLTMFLY;
	defcolfg   : TCOLOR_ENTRY;
	appdone,
	cliplock,
	deskinst,
	has_agi,
	profilechng: boolean;
	d_str      : string;
	d_btn      : string[40];
	d_chr      : PChar;
	d_pxy,
	d_clip     : ARRAY_4;
	d_ty,
	d_tx,
	d_scpos,
	mhstack,
	mfstack,
	spderr,
	bfalcol,
	slmouse,
	poptimer,
	freedom,
	allocmode,
	heaperrcode: integer;
	profkeyat,
	lastfa     : longint;
	profile    : PProfileCollection;
	profilename,
	lastprofkey: PString;
	xselwind   : array [0..XSELMAX+1] of record
		window : PWindow;
		fdmwhnd,
		group  : integer
	end;
	agi        : record
		Gadgets    : integer;
		ExtRsc,
		ApplSearch,
		MenuInq,
		ExtMnSelect,
		SysNiceline,
		WindUpdate,
		Shutdown,
		Broadcast,
		MultiProto,
		MnAttach,
		Iconify,
		Backdrop,
		GShortcut,
		Owner,
		Shading,
		BEvent     : boolean
	end;
	maus       : record
		currnr  ,
		lastnr  : HCursor;
		currform,
		lastform: MFORM
	end;


function DrawTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawStatic(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawMenuRect(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawPushButton(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
procedure SigHandler(dummy1,dummy2,sig: pointer); forward;
procedure IconifyFadeout(p: PWindow); forward;
procedure IconifyFadein(p: PWindow); forward;
procedure SendXaccExit(p: PXAccAttr); forward;
function objc_wedit(ob_edtree: PTree; ob_edobject,ob_edchar: integer; var ob_edidx: integer; ob_edkind,ob_edwnd: integer): integer; forward;
function objc_xedit(ob_edtree: PTree; ob_edobject,ob_edchar: integer; var ob_edidx: integer; ob_edkind: integer; pr: PGRECT): integer; forward;
procedure nop; begin end;


{ *** Objekt TEVENTOBJECT *** }

constructor TEventObject.Init;

  begin
  	if not(inherited Init) then fail;
  	EventList:=nil
  end;


destructor TEventObject.Done;

  begin
		while (EventList<>nil) do EventList^.Free;
		inherited Done
  end;

{ *** TEVENTOBJECT *** }



{ *** Objekt TEVENT *** }

constructor TEvent.Init(AParent: PEventObject);
	var p: PEvent;

	begin
		if not(inherited Init) then fail;
		Parent:=AParent;
		if Parent=nil then Parent:=Application;
		Style:=0;
		Prev:=nil;
		Nxt:=nil;
		if Parent^.EventList=nil then Parent^.EventList:=@self
		else
			begin
				p:=Parent^.EventList;
				while p^.Nxt<>nil do p:=p^.Nxt;
				p^.Nxt:=@self;
				Prev:=p
			end
	end;


destructor TEvent.Done;

	begin
		if (Prev=nil) and (Nxt=nil) then Parent^.EventList:=nil
		else
			begin
				if Prev=nil then Parent^.EventList:=Nxt
					else Prev^.Nxt:=Nxt;
				if Nxt<>nil then Nxt^.Prev:=Prev
			end;
		inherited Done
	end;


function TEvent.TestKey(Stat,Key: integer): boolean;

	begin
		TestKey:=false
	end;


function TEvent.TestButton(mX,mY,BStat,KStat,Clicks: integer): boolean;

	begin
		TestButton:=false
	end;


function TEvent.TestMouse(M,mX,mY,BStat,KStat: integer): boolean;

	begin
		TestMouse:=false
	end;


function TEvent.TestMessage(Pipe: Pipearray): boolean;

	begin
		TestMessage:=false
	end;


function TEvent.TestMenu(mNum: integer): boolean;

	begin
		TestMenu:=false
	end;


procedure TEvent.Work;

	begin
	end;


function TEvent.Previous: PEvent;

	begin
		Previous:=Prev
	end;


function TEvent.Next: PEvent;

	begin
		Next:=Nxt
	end;

{ *** TEVENT *** }



{ *** Objekt TVALIDATOR *** }

constructor TValidator.Init;

	begin
		if not(inherited Init) then fail;
		Window:=nil;
		Status:=vsOK;
		Options:=0
	end;


procedure TValidator.Error;

	begin
		if Application<>nil then
			with Application^ do
				begin
					if Attr.Country=FRA then
						Alert(Window,1,NOTE,'Cette entrÇe ne peut àtre vide!','  &OK  ')
					else if (Attr.Country=FRG) or (Attr.Country=SWG) then
						Alert(Window,1,NOTE,'Die Eingabe darf nicht leer sein!','  &OK  ')
					else
						Alert(Window,1,NOTE,'Input must not be empty!','  &OK  ')
			end
	end;


function TValidator.IsValid(s: string): boolean;

	begin
		if bTst(Options,voNotEmpty) then IsValid:=length(s)>0
		else
			IsValid:=true
	end;


function TValidator.IsValidInput(var s: string; SuppressFill: boolean): boolean;

	begin
		IsValidInput:=true
	end;


function TValidator.Valid(s: string): boolean;

	begin
		if IsValid(s) then Valid:=true
		else
			begin
				Valid:=false;
				Error
			end
	end;

{ *** TVALIDATOR *** }



{ *** Objekt TICON *** }

constructor TIcon.Init(AParent: PEventObject; ATree,AnIndex,iX,iY: integer; Movable,Selectble: boolean; AName,Hlp: string);
	var tp: PTree;

	begin
		if not(inherited Init(AParent)) then fail;
		tp:=Application^.GetAddr(ATree);
		{ freie Images... }
		if tp=nil then
			begin
				inherited Done;
				fail
			end;
		ObjTree:=ATree;
		ObjIndx:=AnIndex;
		ObjAddr:=@tp^[ObjIndx];
		if ObjAddr=nil then
			begin
				inherited Done;
				fail
			end;
		with ObjAddr^ do
			if (ob_type and $ff)<>G_IMAGE then
				begin
					inherited Done;
					fail
				end;
		Style:=Style or es_Icon;
		with VObj do
			begin
				ob_next:=-1;
				ob_head:=-1;
				ob_tail:=-1;
				ob_type:=G_IMAGE;
				ob_flags:=LASTOB;
				ob_state:=NORMAL;
				ob_spec.bit_blk:=ObjAddr^.ob_spec.bit_blk;
				ob_width:=ob_spec.bit_blk^.bi_wb shl 3;
				ob_height:=ob_spec.bit_blk^.bi_hl;
				tyrel:=ob_height+1
			end;
		ADialog:=nil;
		icontext:=nil;
		BHelp:=nil;
		Click:=0;
		Shift:=K_NORMAL;
		VStat:=K_NORMAL;
		VKey:=id_No;
		IsMovable:=Movable;
		IsSelectable:=Selectble;
		hideflag:=true;
		SetPos(iX,iY,false);
		SetText(AName);
		hideflag:=(Parent=PEventObject(Application)); { ... }
		SetHelp(Hlp)
	end;


destructor TIcon.Done;

	begin
		DisposeStr(icontext);
		DisposeStr(BHelp);
		inherited Done
	end;


function TIcon.TestButton(mX,mY,BStat,KStat,Clicks: integer): boolean;
	label _weiter,_move;

	var r: GRECT;

	begin
		TestButton:=false;
		if IsHidden then exit;
		r.X:=mX;
		r.Y:=mY;
		r.W:=1;
		r.H:=1;
		GRtoA2(r);
		if IsSelected(r) then
			begin
				if BStat=1 then
					begin
						TestButton:=true;
						wind_update(BEG_UPDATE);
						if IsMovable and (Clicks=1) and ((GetCheck=bf_Checked) or not(IsSelectable)) then
							begin
								_move:
								if Parent=PEventObject(Application) then Application^.MoveIcons(Parent,@self,DESK,mX,mY)
								else
									Application^.MoveIcons(Parent,@self,PWindow(Parent)^.Attr.gemHandle,mX,mY);
								goto _weiter
							end;
						if IsSelectable then
							begin
								if (KStat and K_SHIFT)>0 then Application^.IconSelect(false,PWindow(Parent)^.Attr.gemHandle)
								else
									Application^.IconSelect(false,id_No);
								Toggle
							end;
						Click:=Clicks;
						Shift:=KStat;
						Work;
						if (GetCheck=bf_Checked) and IsMovable then
							begin
								evnt_timer(20,0);
								graf_mkstate(mX,mY,BStat,KStat);
								if BStat=1 then goto _move
							end;
						wind_update(BEG_MCTRL);
						repeat
							graf_mkstate(mX,mY,BStat,KStat)
						until BStat=0;
						wind_update(END_MCTRL);
						_weiter:
						wind_update(END_UPDATE)
					end
				else
					if (BStat=2) and (Clicks=1) then
						begin
							if IsHelpAvailable then Application^.BubbleHelp(mX,mY,GetHelp,false,false);
							TestButton:=true
						end
			end
	end;


function TIcon.TestKey(Stat,Key: integer): boolean;

	begin
		TestKey:=false;
		if IsHidden then exit;
		if bTst(VStat,K_SHIFT) then
			if (Stat and K_SHIFT)>0 then Stat:=Stat or K_SHIFT;
		if (Stat=VStat) and (Key=VKey) then
			begin
				TestKey:=true;
				if IsSelectable then
					begin
						Application^.IconSelect(false,id_No);
						Check
					end;
				Click:=0;
				Shift:=K_NORMAL;
				Work
			end
	end;


function TIcon.GetOutline(var IcnRect,TxtRect: GRECT): boolean;

	begin
		with PWindow(Parent)^ do
			begin
				IcnRect.X:=XPos+Work.X;
				IcnRect.Y:=YPos+Work.Y;
				IcnRect.W:=VObj.ob_width;
				IcnRect.H:=VObj.ob_height+1
			end;
		if icontext<>nil then
			begin
				TxtRect.X:=IcnRect.X+txrel-1;
				TxtRect.Y:=IcnRect.Y+tyrel-1;
				TxtRect.W:=length(icontext^)*6+2; { ... }
				TxtRect.H:=9; { 6+3... }
				GetOutline:=true
			end
		else
			begin
				TxtRect.X:=Application^.Attr.MaxPX+1;
				TxtRect.Y:=0;
				TxtRect.W:=1;
				TxtRect.H:=1;
				GetOutline:=false
			end;
		GRtoA2(IcnRect);
		GRtoA2(TxtRect)
	end;


function TIcon.IsSelected(r: GRECT): boolean;
	var s,t  : GRECT;
	    valid: boolean;

	begin
		if IsHidden then
			begin
				IsSelected:=false;
				exit
			end;
		if GetOutline(s,t) then valid:=rc_intersect(r,t)
		else
			valid:=false;
		if not(valid) then valid:=rc_intersect(r,s);
		IsSelected:=valid
	end;


procedure TIcon.SetText(AName: string);

	begin
		RedrawParent;
		DisposeStr(icontext);
		icontext:=NewStr(AName);
		if icontext=nil then txrel:=0
		else
			txrel:=(VObj.ob_width-length(icontext^)*6) shr 1; { ... }
		Paint
	end;


function TIcon.GetText: string;

	begin
		if icontext=nil then GetText:=''
		else
			GetText:=icontext^
	end;


procedure TIcon.SetPos(iX,iY: integer; Redraw: boolean);

	begin
		if Redraw then RedrawParent;
		XPos:=iX;
		YPos:=iY;
		if Redraw then Paint
	end;


procedure TIcon.SetCheck(CheckFlag: integer);

	begin
		if GetCheck<>CheckFlag then
			begin
				if CheckFlag=bf_Unchecked then VObj.ob_state:=VObj.ob_state and not(SELECTED)
				else
					VObj.ob_state:=VObj.ob_state or SELECTED;
				Paint
			end
	end;


function TIcon.GetCheck: integer;

	begin
		if bTst(VObj.ob_state,SELECTED) then GetCheck:=bf_Checked
		else
			GetCheck:=bf_Unchecked
	end;


procedure TIcon.Check;

	begin
		SetCheck(bf_Checked)
	end;


procedure TIcon.Uncheck;

	begin
		SetCheck(bf_Unchecked)
	end;


procedure TIcon.Toggle;

	begin
		if GetCheck=bf_Unchecked then SetCheck(bf_Checked)
		else
			SetCheck(bf_Unchecked)
	end;


procedure TIcon.Hide(Draw: boolean);

	begin
		if not(IsHidden) then
			begin
				if Draw then RedrawParent;
				hideflag:=true
			end
	end;


procedure TIcon.Unhide;

	begin
		if IsHidden then
			begin
				hideflag:=false;
				Paint
			end
	end;


function TIcon.IsHidden: boolean;

	begin
		IsHidden:=hideflag
	end;


procedure TIcon.Paint;
	var valid     : boolean;
	    rect      : GRECT;
	    atrb      : ARRAY_10;
	    ipxy,tpxy : ARRAY_4;
	    dummy,vh,
	    icnbc,txbc: integer;

	begin
		if IsHidden then exit;
		if PWindow(Parent)^.Attr.Status<>ws_Open then exit;
		wind_update(BEG_UPDATE);
		with VObj do
			begin
				ob_x:=XPos+PWindow(Parent)^.Work.X;
				ob_y:=YPos+PWindow(Parent)^.Work.Y;
				ob_spec.bit_blk^.bi_x:=0;
				ob_spec.bit_blk^.bi_y:=0;
				ipxy[0]:=ob_x;
				ipxy[1]:=ob_y;
				ipxy[2]:=ob_x+ob_width-1;
				ipxy[3]:=ob_y+ob_height-1
			end;
		vh:=Application^.vdiHandle;
		SetSmallSystemFont(vh,dummy,dummy,dummy,dummy);
		vst_alignment(vh,TA_LEFT,TA_TOP,dummy,dummy);
		vsf_interior(vh,FIS_SOLID);
		vqt_attributes(vh,atrb);
		if icontext<>nil then
			begin
				tpxy[0]:=XPos+PWindow(Parent)^.Work.X+txrel-1;
				tpxy[1]:=YPos+PWindow(Parent)^.Work.Y+tyrel-1;
				tpxy[2]:=tpxy[0]+length(icontext^)*atrb[8]+1;
				tpxy[3]:=tpxy[1]+atrb[9]+2
			end;
		if PWindow(Parent)^.Class.hbrBackground>=1 then icnbc:=PWindow(Parent)^.Class.hbrBackground-1
		else
			icnbc:=White;
		if GetCheck=bf_Checked then txbc:=Black
		else
			txbc:=White;
		HideMouse;
		valid:=PWindow(Parent)^.FirstWorkRect(rect);
		while valid do
			begin
				vs_clip(vh,CLIP_ON,rect.A2);
				vsf_color(vh,icnbc);
				vr_recfl(vh,ipxy);
				with rect do objc_draw(@VObj,0,0,X,Y,W,H);
				if icontext<>nil then
					begin
						vsf_color(vh,txbc);
						vr_recfl(vh,tpxy);
						vswr_mode(vh,MD_XOR);
						v_gtext(vh,VObj.ob_x+txrel,VObj.ob_y+tyrel,icontext^);
						vswr_mode(vh,MD_REPLACE)
					end;
				valid:=PWindow(Parent)^.NextWorkRect(rect)
			end;
		ShowMouse;
		vsf_interior(vh,FIS_HOLLOW);
		vsf_color(vh,Black);
		SetSystemFont(vh,dummy,dummy,dummy,dummy);
		vst_alignment(vh,TA_LEFT,TA_BASELINE,dummy,dummy);
		vs_clip(vh,CLIP_ON,SysInfo.Desktop.A2);
		wind_update(END_UPDATE)
	end;


function TIcon.IsHelpAvailable: boolean;

	begin
		if BHelp=nil then IsHelpAvailable:=false
		else
			IsHelpAvailable:=(length(StrPTrimF(BHelp^))>0)
	end;


function TIcon.GetHelp: string;

	begin
		if BHelp<>nil then GetHelp:=BHelp^ else GetHelp:=''
	end;


procedure TIcon.SetHelp(Hlp: string);

	begin
		DisposeStr(BHelp);
		BHelp:=NewStr(Hlp)
	end;


procedure TIcon.IMMoved(X,Y: integer);

	begin
		SetPos(X,Y,true)
	end;


	{ private }


procedure TIcon.RedrawParent;
	var s,t: GRECT;

	begin
		if IsHidden then exit;
		if Parent=PEventObject(Application) then exit; { ... }
		if GetOutline(s,t) then Application^.InvalidateRect(PWindow(Parent)^.Attr.Handle,@t);
		Application^.InvalidateRect(PWindow(Parent)^.Attr.Handle,@s)
	end;

{ *** TICON *** }



{ *** Objekt TCLIPBOARD *** }

constructor TClipboard.Init(AParent: PObject);

	begin
		if not(inherited Init) then fail;
		if AParent=nil then fail;
		openflag:=false;
		clippath:=nil;
		formats:=nil;
		Parent:=AParent;
		clipmask:=SCF_INDEF;
		clipext:=#0#0#0#0
	end;


function TClipboard.OpenClipboard(Write: boolean): boolean;
	label _raus,_fertig,_path;

	var path,test: string;
	    olddta   : DTAPtr;
	    newdta   : DTA;
	    valid    : boolean;

	function setpath: boolean;
		label _weiter;

		begin
			setpath:=false;
			if bTst(GetDrives,4) then
				begin
					path:='C:\CLIPBRD';
					if PathExist(path) then goto _weiter
					else
						if dcreate(path+#0)=0 then
							if PathExist(path) then goto _weiter
				end;
			if not(BootDevice in ['A','C']) then
				begin
					path:=BootDevice+':\CLIPBRD';
					if PathExist(path) then goto _weiter
					else
						if dcreate(path+#0)=0 then
							if PathExist(path) then goto _weiter
				end;
			if bTst(GetDrives,1) then
				begin
					path:='A:\CLIPBRD';
					if PathExist(path) then goto _weiter
					else
						if dcreate(path+#0)=0 then
							if PathExist(path) then goto _weiter
				end;
			exit;
			_weiter:
			path:=path+'\';
			setpath:=true;
			valid:=true
		end;

	begin
		OpenClipboard:=false;
		if cliplock then exit;
		if not(AppFlag) then wind_update(BEG_UPDATE);
		BusyMouse;
		olddta:=fgetdta;
		fsetdta(@newdta);
		valid:=false;
		if scrp_read(path)=0 then path:='';
		StrPTrim(path);
		if length(path)=0 then
			begin
				path:=GetEnv('CLIPBRD');
				if length(path)=0 then path:=GetEnv('SCRAPDIR');
				if length(path)=0 then goto _path;
				StrPTrim(path)
			end;
		_path:
		if length(path)>0 then
			begin
				if StrPLeft(path,1)='\' then
					begin
						path:=BootDevice+':'+path;
						valid:=true
					end;
				if StrPRight(StrPLeft(path,2),1)<>':' then
					begin
						path:=BootDevice+':\'+path;
						valid:=true
					end;
				if pos('\',path)>0 then
					if RPos('\SCRAP.',StrPUpper(path))=RPos('\',path) then
						begin
							path:=StrPLeft(path,RPos('\',path));
							valid:=true
						end;
				if StrPRight(path,1)<>'\' then
					begin
						path:=path+'\';
						valid:=true
					end;
				if not(PathExist(path)) then
					if not(setpath) then goto _raus
			end
		else
			if not(setpath) then goto _raus;
		if valid then
			if scrp_write(path)=0 then goto _raus;
		clippath:=NewStr(path+'scrap.');
		if clippath=nil then goto _raus;
		openflag:=true;
		writeflag:=false;
		if Write then
			if not(EmptyClipboard) then
				begin
					openflag:=false;
					goto _raus
				end;
		cliplock:=true;
		OpenClipboard:=true;
		goto _fertig;
		_raus:
		ArrowMouse;
		_fertig:
		fsetdta(olddta);
		if not(AppFlag) then wind_update(END_UPDATE)
	end;


function TClipboard.IsOpen: boolean;

	begin
		IsOpen:=openflag
	end;


function TClipboard.GetClipboardFilename: string;

	begin
		if clippath=nil then GetClipboardFilename:=''
		else
			GetClipboardFilename:=clippath^
	end;


function TClipboard.GetPriorityClipboardFormat(PriorityList: string): string;
	var ps: integer;

	begin
		GetPriorityClipboardFormat:='';
		if not(IsOpen) then exit;
		PriorityList:=PriorityList+'.';
		while length(PriorityList)>0 do
			begin
				ps:=pos('.',PriorityList);
				if IsClipboardFormatAvailable(StrPLeft(PriorityList,ps-1)) then
					begin
						GetPriorityClipboardFormat:=StrPLeft(PriorityList,ps-1);
						exit
					end;
				PriorityList:=StrPRight(PriorityList,length(PriorityList)-ps)
			end
	end;


function TClipboard.IsClipboardFormatAvailable(Format: string): boolean;
	label _weiter;

	var olddta : DTAPtr;
	    newdta : DTA;
	    formate,
	    buf    : string;
	    ret    : integer;
	    hdl    : longint;

	begin
		IsClipboardFormatAvailable:=false;
		if not(IsOpen) then exit;
		if formats=nil then
			begin
				formate:='.';
				hdl:=dopendir(GetRawPath(clippath^),0);
				if (hdl and $ff000000)=$ff000000 then
					begin
						if hdl=-32 then
							begin
								if not(AppFlag) then wind_update(BEG_UPDATE);
								olddta:=fgetdta;
								fsetdta(@newdta);
								ret:=fsfirst(clippath^+'*',FA_HIDDEN);
								while ret=0 do
									begin
										if length(newdta.d_fname)>6 then formate:=StrPRight(newdta.d_fname,length(newdta.d_fname)-5)+formate;
										ret:=fsnext
									end;
								fsetdta(olddta);
								if not(AppFlag) then wind_update(END_UPDATE)
							end;
						goto _weiter
					end;
				while dreaddir(255,hdl,buf)=0 do
					if StrPUpper(StrPLeft(StrPPas(@buf[4]),6))='SCRAP.' then
						formate:=StrPRight(StrPPas(@buf[4]),StrLen(@buf[4])-5)+formate;
				dclosedir(hdl);
				_weiter:
				formats:=NewStr(StrPUpper(formate))
			end;
		if (formats=nil) or (length(Format)=0) then exit;
		if StrPLeft(Format,1)<>'.' then Format:='.'+Format;
		IsClipboardFormatAvailable:=(pos(StrPUpper(Format)+'.',formats^)>0)
	end;


function TClipboard.EmptyClipboard: boolean;
	label _raus;

	var olddta  : DTAPtr;
	    newdta  : DTA;
	    path,buf: string;
	    ret     : integer;
	    hdl     : longint;

	begin
		EmptyClipboard:=false;
		if not(IsOpen) then exit;
		path:=StrPLeft(clippath^,RPos('\',clippath^));
		hdl:=dopendir(GetRawPath(clippath^),0);
		if (hdl and $ff000000)=$ff000000 then
			begin
				if hdl=-32 then
					begin
						if not(AppFlag) then wind_update(BEG_UPDATE);
						BusyMouse;
						olddta:=fgetdta;
						fsetdta(@newdta);
						ret:=fsfirst(clippath^+'*',FA_HIDDEN);
						while ret=0 do
							begin
								fdelete(path+newdta.d_fname);
								ret:=fsnext
							end;
						if fsfirst(clippath^+'*',FA_HIDDEN)<>0 then EmptyClipboard:=true;
						fsetdta(olddta);
						ArrowMouse;
						if not(AppFlag) then wind_update(END_UPDATE)
					end;
				goto _raus
			end;
		BusyMouse;
		while dreaddir(255,hdl,buf)=0 do
			if StrPUpper(StrPLeft(StrPPas(@buf[4]),6))='SCRAP.' then fdelete(path+StrPPas(@buf[4]));
		dclosedir(hdl);
		EmptyClipboard:=true;
		ArrowMouse;
		_raus:
		SetClipboardFormat(SCF_INDEF,'')
	end;


procedure TClipboard.SetClipboardFormat(Mask: word; Ext: string);

	begin
		if not(IsOpen) then exit;
		clipmask:=Mask;
		if length(Ext)>0 then
			if StrPLeft(Ext,1)<>'.' then Ext:='.'+Ext;
		while length(clipext)<4 do clipext:=clipext+#0;
		clipext:=StrPLeft(Ext,4);
		writeflag:=true
	end;


function TClipboard.CloseClipboard: boolean;
	var pipe: Pipearray;
	    pfad: string;

	begin
		CloseClipboard:=false;
		if not(IsOpen) then exit;
		cliplock:=false;
		openflag:=false;
		CloseClipboard:=true;
		ArrowMouse;
		if writeflag then
			begin
				pipe[0]:=SC_CHANGED;
				pipe[3]:=integer(clipmask);
				pipe[4]:=integer((ord(clipext[1]) shl 8)+ord(clipext[2]));
				pipe[5]:=integer((ord(clipext[3]) shl 8)+ord(clipext[4]));
				pipe[6]:=0;
				pipe[7]:=0;
				Application^.Broadcast(@pipe,true);
				pipe[0]:=SH_WDRAW;
				pipe[3]:=ord(clippath^[1])-65;
				Application^.Broadcast(@pipe,true);
				if Application^.AVServer>=0 then
					begin
						pfad:=StrPLeft(clippath^,length(clippath^)-6);
						if upath<>nil then GlobalFree(upath,StrLen(upath)+1);
						GlobalAlloc(upath,length(pfad)+1);
						if upath<>nil then
							begin
								StrPCopy(upath,pfad);
								pipe[0]:=AV_PATH_UPDATE;
								pipe[1]:=Application^.apID;
								pipe[2]:=0;
								pipe[3]:=integer(HiWord(upath));
								pipe[4]:=integer(LoWord(upath));
								appl_write(Application^.AVServer,16,@pipe)
							end
					end
			end;
		DisposeStr(clippath);
		DisposeStr(formats);
		clipext:=#0#0#0#0;
		clipmask:=SCF_INDEF
	end;

{ *** TCLIPBOARD *** }



{ *** Objekt TCONTROL *** }

constructor TControl.Init(AParent: PDialog; AnIndx: integer; Hlp: string);
	var p: PControl;

	begin
		if not(inherited Init) then fail;
		Parent:=AParent;
		if Parent=nil then
			begin
				inherited Done;
				fail
			end;
		ObjIndx:=AnIndx;
		ObjAddr:=@Parent^.DlgTree^[ObjIndx];
		if ObjAddr=nil then
			begin
				inherited Done;
				fail
			end;
		BHelp:=nil;
		SetHelp(Hlp);
		ID:=id_No;
		Style:=0;
		Flags:=0;
		Prev:=nil;
		Nxt:=nil;
		SetShortCut(#0);
		UsrDef:=false;
		UsrBlk.ub_code:=nil;
		UsrBlk.ub_parm:=0;
		if Parent^.CtrlList=nil then Parent^.CtrlList:=@self
		else
			begin
				p:=Parent^.CtrlList;
				while p^.Nxt<>nil do p:=p^.Nxt;
				p^.Nxt:=@self;
				Prev:=p
			end
	end;


destructor TControl.Done;

	begin
		if (Prev=nil) and (Nxt=nil) then Parent^.CtrlList:=nil
		else
			begin
				if Prev=nil then Parent^.CtrlList:=Nxt
					else Prev^.Nxt:=Nxt;
				if Nxt<>nil then Nxt^.Prev:=Prev
			end;
		DisposeStr(BHelp);
		inherited Done
	end;


function TControl.TestIndex(AnIndx: integer): boolean;

	begin
		TestIndex:=(AnIndx=ObjIndx)
	end;


function TControl.TestID(AnID: integer): boolean;

	begin
		TestID:=(AnID=ID)
	end;


function TControl.TestShortCut(Key: integer): boolean;

	begin
		TestShortCut:=(Key=shortcut)
	end;


procedure TControl.SetShortCut(Key: char);

	begin
		if Key=#0 then shortcut:=id_No
		else
			shortcut:=ord(upcase(Key))
	end;


procedure TControl.SetFlags(Mask: byte; OnOff: boolean);

	begin
		if OnOff then Flags:=Flags or Mask
		else
			Flags:=Flags and not(Mask)
	end;


function TControl.IsFlagSet(Mask: byte): boolean;

	begin
		IsFlagSet:=bTst(Flags,Mask)
	end;


procedure TControl.SetState(StateFlag: integer);

	begin
		if GetState<>StateFlag then
			begin
				with ObjAddr^ do
					if StateFlag=bf_Disabled then
						ob_state:=ob_state or DISABLED
					else
						ob_state:=ob_state and not(DISABLED);
				Paint
			end
	end;


function TControl.GetState: integer;

	begin
		if bTst(ObjAddr^.ob_state,DISABLED) then GetState:=bf_Disabled
		else
			GetState:=bf_Enabled
	end;


procedure TControl.Disable;

	begin
		SetState(bf_Disabled)
	end;


procedure TControl.Enable;

	begin
		SetState(bf_Enabled)
	end;


procedure TControl.SetColor(Color: integer);
	var ot: integer;

	begin
		if (Color<0) or (Color>15) then Color:=Black;
		if Color<>GetColor then
			begin
				ot:=ObjAddr^.ob_type and $ff;
				with ObjAddr^.ob_spec do
					begin
						if ot in [G_BOX,G_IBOX,G_BOXCHAR] then index:=(index and $fffffff0) or Color
						else
							if ot in [G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT] then ted_info^.te_color:=(ted_info^.te_color and $f0ff) or (Color shl 8)
							else
								if ot=G_ICON then icon_blk^.ib_char:=(icon_blk^.ib_char and $f0ff) or (Color shl 8)
								else
									if ot=G_IMAGE then bit_blk^.bi_color:=Color
					end;
				Paint
			end
	end;


function TControl.GetColor: integer;
	var ot: integer;

	begin
		GetColor:=Black;
		ot:=ObjAddr^.ob_type and $ff;
		if ot in [G_BOX,G_IBOX,G_BOXCHAR] then GetColor:=ObjAddr^.ob_spec.index and $f
		else
			if ot in [G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT] then GetColor:=(ObjAddr^.ob_spec.ted_info^.te_color shr 8) and $0f
			else
				if ot=G_ICON then GetColor:=(ObjAddr^.ob_spec.icon_blk^.ib_char shr 8) and $0f
				else
					if ot=G_IMAGE then GetColor:=ObjAddr^.ob_spec.bit_blk^.bi_color
	end;


procedure TControl.Hide(Draw: boolean);
	var valid: boolean;
	    ox,oy: integer;
	    r    : GRECT;

	begin
		valid:=not(IsHidden) and Draw;
		with ObjAddr^ do ob_flags:=ob_flags or HIDETREE;
		if valid then
			begin
				objc_offset(Parent^.DlgTree,ObjIndx,r.X,r.Y);
				r.W:=ObjAddr^.ob_width;
				r.H:=ObjAddr^.ob_height;
				Parent^.ObjcPaintRect(ROOT,r,bTst(Flags,wb_Lazy))
			end
	end;


procedure TControl.Unhide;

	begin
		with ObjAddr^ do ob_flags:=ob_flags and not(HIDETREE);
		Paint
	end;


function TControl.IsHidden: boolean;

	begin
		IsHidden:=Application^.IsTreeHidden(Parent^.DlgTree,ObjIndx)
	end;


procedure TControl.DisableTransfer;

	begin
		SetFlags(wb_Transfer,false)
	end;


procedure TControl.EnableTransfer;

	begin
		SetFlags(wb_Transfer,true)
	end;


function TControl.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		Transfer:=0
	end;


procedure TControl.Changed(AnIndx: integer; DblClick: boolean);

	begin
	end;


procedure TControl.Paint;

	begin
		if not(IsHidden) then Parent^.ObjcPaint(ObjIndx,bTst(Flags,wb_Lazy))
	end;


function TControl.IsHelpAvailable: boolean;

	begin
		if BHelp=nil then IsHelpAvailable:=false
		else
			IsHelpAvailable:=(length(StrPTrimF(BHelp^))>0)
	end;


function TControl.GetHelp: string;

	begin
		if BHelp<>nil then GetHelp:=BHelp^ else GetHelp:=''
	end;


procedure TControl.SetHelp(Hlp: string);

	begin
		DisposeStr(BHelp);
		BHelp:=NewStr(Hlp)
	end;


function TControl.ExtFocusKey(Stat,Key: integer): boolean;

	begin
		ExtFocusKey:=false
	end;


procedure TControl.ExtFocusPaint(r: GRECT);

	begin
	end;


function TControl.Previous: PControl;

	begin
		Previous:=Prev
	end;


function TControl.Next: PControl;

	begin
		Next:=Nxt
	end;

{ *** TCONTROL *** }



{ *** Objekt TBUTTON *** }

constructor TButton.Init(AParent: PDialog; AnIndx,AnID: integer; UserDef: boolean; Hlp: string);
	var obtype: integer;

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		Style:=cs_PushButton;
		with ObjAddr^ do
			begin
				if bTst(ob_flags,DEFAULT) then Style:=Style or bs_DefPushButton;
				ID:=AnID;
				UsrDef:=UserDef;
				obtype:=ob_type and $ff;
				if (obtype=G_BUTTON) or (obtype=G_STRING) or (obtype=G_TITLE) then TextLen:=StrLen(ob_spec.free_string)+1
				else
					if (obtype=G_TEXT) or (obtype=G_BOXTEXT) or (obtype=G_FTEXT) or (obtype=G_FBOXTEXT) then TextLen:=ob_spec.ted_info^.te_txtlen
					else
						TextLen:=0;
				if UsrDef then
					begin
						oldflags:=ob_flags;
						oldstate:=ob_state;
						if not(Install) then
							begin
								inherited Done;
								fail
							end
					end;
				if not(UsrDef) then
					if (ID>=id_OK) and (ID<=id_Esc) then
						if (ob_type and $ff)=G_BOXTEXT then
							begin
								if Application^.ExtObjects then ob_flags:=ob_flags or FL3DACT
								else
									if Application^.Attr.Colors>=Yellow then
										ob_spec.ted_info^.te_color:=(ob_spec.ted_info^.te_color and $ff00) or $70 or Yellow
							end;
				SetText(GetRawText)
			end
	end;


destructor TButton.Done;

	begin
		if UsrDef then
			begin
				Deinstall;
				with ObjAddr^ do
					begin
						ob_spec.index:=UsrBlk.ub_parm;
						ob_type:=G_BUTTON;
						ob_state:=oldstate;
						ob_flags:=oldflags
					end
			end;
		inherited Done
	end;


function TButton.Install: boolean;

	begin
		with ObjAddr^ do
			if Application^.ExtObjects then
				begin
					UsrDef:=false;
				  ob_type:=G_BUTTON;
				  ob_flags:=(ob_flags and not(RBUTTON or EDITABLE)) or SELECTABLE or FL3DACT;
				  ob_state:=ob_state and $00ff;
				  inc(ob_height)
				end
			else
				if (ob_type and $ff)=G_BUTTON then
					begin
						UsrBlk.ub_parm:=ob_spec.index;
						UsrBlk.ub_code:=@DrawPushButton;
						ob_flags:=(ob_flags and not(RBUTTON or EDITABLE)) or SELECTABLE;
						ob_state:=ob_state and not(CROSSED or CHECKED or OUTLINED or SHADOWED);
						ob_type:=G_USERDEF;
						ob_spec.user_blk:=@UsrBlk;
						dec(ob_x,5);
						dec(ob_y,5);
						inc(ob_width,10);
						inc(ob_height,10)
					end
				else
					UsrDef:=false;
		Install:=true
	end;


procedure TButton.Deinstall;

	begin
		with ObjAddr^ do
			if Application^.ExtObjects then dec(ob_height)
			else
				begin
					inc(ob_x,5);
					inc(ob_y,5);
					dec(ob_width,10);
					dec(ob_height,10)
				end
	end;


procedure TButton.SetShortCut(Key: char);
	var idx: integer;

	begin
		inherited SetShortCut(Key);
		if Application^.ExtObjects and not(UsrDef) then
			with ObjAddr^ do
				begin
					if Key=#0 then ob_state:=ob_state and $00ff
					else
						begin
							idx:=pos(upcase(Key),StrPUpper(GetText));
							if (idx=0) or (idx>8) then ob_state:=ob_state and $00ff
							else
								ob_state:=(ob_state and $00ff) or WHITEBAK or ((idx-1) shl 8)
						end
				end
	end;


procedure TButton.SetText(ATextString: string);
	var typ,scpos: integer;
	    adr      : PChar;
	    scchar   : char;

	begin
		adr:=nil;
		scchar:=#0;
		if length(ATextString)>=TextLen then ATextString:=StrPLeft(ATextString,TextLen-1);
		typ:=ObjAddr^.ob_type and $ff;
		scpos:=pos('&',ATextString);
		if (scpos>0) and (scpos<length(ATextString)) then
			begin
				scchar:=ATextString[scpos+1];
				if not(UsrDef) then
					ATextString:=StrPLeft(ATextString,scpos-1)+StrPRight(ATextString,length(ATextString)-scpos)
			end;
		if UsrDef then adr:=PChar(UsrBlk.ub_parm)
		else
			if (typ=G_BUTTON) or (typ=G_STRING) or (typ=G_TITLE) then
				adr:=ObjAddr^.ob_spec.free_string;
		if adr<>nil then StrPCopy(adr,ATextString)
		else
			if (typ=G_TEXT) or (typ=G_BOXTEXT) or (typ=G_FTEXT) or (typ=G_FBOXTEXT) then
				StrPCopy(ObjAddr^.ob_spec.ted_info^.te_ptext,ATextString);
		SetShortCut(scchar);
		Paint
	end;


function TButton.GetText: string;
	var scpos: integer;
	    txt  : string;

	begin
		txt:=GetRawText;
		scpos:=pos('&',txt);
		if scpos>0 then
			txt:=StrPLeft(txt,scpos-1)+StrPRight(txt,length(txt)-scpos);
		GetText:=txt
	end;


	{ private }


function TButton.GetRawText: string;
	var typ: integer;

	begin
		if UsrDef then GetRawText:=StrPas(PChar(UsrBlk.ub_parm))
		else
			begin
				typ:=ObjAddr^.ob_type and $ff;
				if (typ=G_BUTTON) or (typ=G_STRING) or (typ=G_TITLE) then
					GetRawText:=StrPas(ObjAddr^.ob_spec.free_string)
				else
					if (typ=G_TEXT) or (typ=G_BOXTEXT) or (typ=G_FTEXT) or (typ=G_FBOXTEXT) then
						GetRawText:=StrPas(ObjAddr^.ob_spec.ted_info^.te_ptext)
					else
						GetRawText:=''
			end
	end;

{ *** TBUTTON *** }



{ *** Objekt TSTATIC *** }

constructor TStatic.Init(AParent: PDialog; AnIndx,ATextLen: integer; UserDef: boolean; Hlp: string);

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		Style:=cs_Static or sts_Fill;
		firstchar:=false;
		UsrDef:=false;
		usrused:=false;
		TextLen:=ATextLen;
		if TextLen>256 then TextLen:=256;
		with ObjAddr^ do
			begin
				oldtype:=ob_type and $ff;
				oldflags:=ob_flags;
				ob_flags:=ob_flags and not(RBUTTON or EDITABLE);
				if (oldtype=G_BUTTON) or (oldtype=G_STRING) or (oldtype=G_TITLE) then
					begin
						if TextLen<0 then TextLen:=256;
						if TextLen>StrLen(ObjAddr^.ob_spec.free_string)+1 then TextLen:=StrLen(ObjAddr^.ob_spec.free_string)+1;
						UsrBlk.ub_parm:=ob_spec.index;
						if UserDef=true then
							begin
								if Application^.ExtObjects then
									begin
									  ob_type:=G_STRING;
									  ob_flags:=ob_flags or FL3DACT;
									  ob_state:=ob_state or WHITEBAK or UNDERLINE or XSTATE;
										inc(ob_height,3)
									end
								else
									begin
										UsrDef:=true;
										UsrBlk.ub_code:=@DrawTitle;
										ob_type:=G_USERDEF;
										ob_spec.user_blk:=@UsrBlk
									end
							end
						else
							begin
								usrused:=true;
								UsrBlk.ub_code:=@DrawStatic;
								ob_type:=G_USERDEF;
								ob_spec.user_blk:=@UsrBlk
							end
					end
				else
					if (oldtype<>G_TEXT) and (oldtype<>G_BOXTEXT) and (oldtype<>G_FTEXT) and (oldtype<>G_FBOXTEXT) then
						begin
							ob_flags:=oldflags;
							inherited Done;
							fail
						end
					else
						begin
							if TextLen<0 then TextLen:=256;
							if TextLen>ob_spec.ted_info^.te_txtlen then TextLen:=ob_spec.ted_info^.te_txtlen
						end
			end
	end;


destructor TStatic.Done;

	begin
		with ObjAddr^ do
			begin
				if UsrDef or usrused then
					begin
						ob_spec.index:=UsrBlk.ub_parm;
						ob_type:=oldtype;
					end;
				ob_flags:=oldflags;
			end;
		inherited Done
	end;


function TStatic.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		case TransferFlag of
			tf_SetData: SetText(PString(DataPtr)^);
			tf_GetData: PString(DataPtr)^:=GetText
		end;
		if odd(TextLen) then Transfer:=TextLen+1
		else
			Transfer:=TextLen
	end;


procedure TStatic.Paint;
	var r: GRECT;

	begin
		if (ObjAddr^.ob_type and $ff)=G_STRING then
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


procedure TStatic.SetText(ATextString: string);
	var adr: PChar;

	begin
		adr:=nil;
		if length(ATextString)>=TextLen then ATextString:=StrPLeft(ATextString,TextLen-1)
		else
			if bTst(Style,sts_Fill) then
				ATextString:=ATextString+StrPSpace(TextLen-length(ATextString)-1);
		if UsrDef or usrused then adr:=PChar(UsrBlk.ub_parm)
		else
			if (oldtype=G_BUTTON) or (oldtype=G_STRING) or (oldtype=G_TITLE) then
				adr:=ObjAddr^.ob_spec.free_string;
		if adr<>nil then StrPCopy(adr,ATextString)
		else
			begin
				if ATextString[1]='@' then
					if firstchar then
						begin
							if bTst(Style,sts_Fill) then ATextString:=StrPSpace(TextLen-1)
							else
								ATextString:=''
						end;
				StrPCopy(ObjAddr^.ob_spec.ted_info^.te_ptext,ATextString)
			end;
		Paint
	end;


function TStatic.GetText: string;
	var txt: string;

	begin
		if UsrDef or usrused then txt:=StrPas(PChar(UsrBlk.ub_parm))
		else
			if (oldtype=G_BUTTON) or (oldtype=G_STRING) or (oldtype=G_TITLE) then
				txt:=StrPas(ObjAddr^.ob_spec.free_string)
			else
				begin
					txt:=StrPas(ObjAddr^.ob_spec.ted_info^.te_ptext);
					if txt[1]='@' then
						if firstchar then txt:=''
				end;
		GetText:=StrPLeft(txt,TextLen-1)
	end;


function TStatic.GetTextLen: integer;

	begin
		GetTextLen:=length(GetText)
	end;


procedure TStatic.Clear;

	begin
		if bTst(Style,sts_Fill) then
			begin
				if UsrDef or usrused then StrPCopy(PChar(UsrBlk.ub_parm),StrPSpace(TextLen-1))
				else
					if (oldtype=G_BUTTON) or (oldtype=G_STRING) or (oldtype=G_TITLE) then
						StrPCopy(ObjAddr^.ob_spec.free_string,StrPSpace(TextLen-1))
					else
						setptext(Parent^.DlgTree,ObjIndx,StrPSpace(TextLen-1))
			end
		else
			begin
				if UsrDef or usrused then PChar(UsrBlk.ub_parm)^:=#0
				else
					if (oldtype=G_BUTTON) or (oldtype=G_STRING) or (oldtype=G_TITLE) then
						PChar(ObjAddr^.ob_spec.free_string)^:=#0
					else
						setptext(Parent^.DlgTree,ObjIndx,'')
			end;
		Paint
	end;

{ *** TSTATIC *** }



{ *** Objekt TEDIT *** }

constructor TEdit.Init(AParent: PDialog; AnIndx,ATextLen: integer; Hlp: string);

	begin
		if not(inherited Init(AParent,AnIndx,ATextLen,false,Hlp)) then fail;
		EnableTransfer;
		Style:=cs_Edit or es_Undo;
		if ((oldtype<>G_FTEXT) and (oldtype<>G_FBOXTEXT)) or (TextLen<2) then
			begin
				inherited Done;
				fail
			end;
		with ObjAddr^ do
			begin
				if Application^.Attr.Colors<LBlack then ob_flags:=ob_flags or EDITABLE
				else
					if bTst(ob_state,DISABLED) then colDisable
					else
						colEnable;
				if bTst(Application^.Attr.Style,as_3DFlags) then ob_flags:=ob_flags or FL3DBAK
				else
					ob_flags:=ob_flags and not(FL3DBAK)
			end;
		Validator:=nil;
		Clipboard:=GetClipboard;
		UPtr:=nil;
		TPtr:=ChrNew(GetText);
		ClearModify;
		EdIdx:=id_No
	end;


destructor TEdit.Done;

	begin
		ChrDispose(TPtr);
		ChrDispose(UPtr);
		SetValidator(nil);
		if Clipboard<>nil then
			if Clipboard^.Parent=@self then Clipboard^.Free;
		inherited Done
	end;


function TEdit.GetState: integer;

	begin
		if bTst(ObjAddr^.ob_state,DISABLED) or not(bTst(ObjAddr^.ob_flags,EDITABLE)) then GetState:=bf_Disabled
		else
			GetState:=bf_Enabled
	end;


procedure TEdit.SetState(StateFlag: integer);
	var dummy       : integer;
	    valid,valid2: boolean;

	begin
		valid:=(StateFlag=bf_Disabled) and (GetState<>StateFlag) and not(Parent^.obedflag) and (Parent^.GetFocus=ObjIndx);
		valid2:=(StateFlag=bf_Enabled) and (GetState<>StateFlag) and (Parent^.edit_obj<=0);
		if valid then
			begin
				Parent^.objc_edit(dummy,EDEND,K_NORMAL,Parent^.Work.A2,true);
				Parent^.edit_obj:=0
			end;
		if Application^.Attr.Colors<LBlack then inherited SetState(StateFlag)
		else
			if GetState<>StateFlag then
				begin
					if StateFlag=bf_Disabled then colDisable
					else
						colEnable;
					Paint
				end;
		if valid or valid2 then Parent^.InitFocus
	end;


procedure TEdit.SetText(ATextString: string);
	var dummy: integer;
	    valid: boolean;

	begin
		valid:=Parent^.HasActiveFocus(ObjIndx);
		if valid then Parent^.objc_edit(dummy,EDEND,K_NORMAL,Parent^.Work.A2,true);
		inherited SetText(ATextString);
		if valid then Parent^.objc_edit(dummy,EDINIT,K_NORMAL,Parent^.Work.A2,true);
		ChrDispose(UPtr);
		UPtr:=TPtr;
		TPtr:=ChrNew(GetText);
		modified:=true
	end;


procedure TEdit.SetColor(Color: integer);
	var dummy: integer;
	    valid: boolean;

	begin
		valid:=Parent^.HasActiveFocus(ObjIndx);
		if valid then Parent^.objc_edit(dummy,EDEND,K_NORMAL,Parent^.Work.A2,true);
		inherited SetColor(Color);
		if valid then Parent^.objc_edit(dummy,EDINIT,K_NORMAL,Parent^.Work.A2,true)
	end;


procedure TEdit.Paint;
	var dummy: integer;
	    valid: boolean;

	begin
		valid:=Parent^.HasActiveFocus(ObjIndx);
		if valid then Parent^.objc_edit(dummy,EDEND,K_NORMAL,Parent^.Work.A2,true);
		inherited Paint;
		if valid then Parent^.objc_edit(dummy,EDINIT,K_NORMAL,Parent^.Work.A2,true)
	end;


procedure TEdit.Clear;
	var dummy: integer;
	    valid: boolean;

	begin
		valid:=Parent^.HasActiveFocus(ObjIndx);
		if valid then Parent^.objc_edit(dummy,EDEND,K_NORMAL,Parent^.Work.A2,true);
		inherited Clear;
		if valid then Parent^.objc_edit(dummy,EDINIT,K_NORMAL,Parent^.Work.A2,true)
	end;


procedure TEdit.Edit;
	var valid     : boolean;
	    old,cr,crc: string;

	begin
		valid:=true;
		if Validator<>nil then
			if bTst(Validator^.Options,voOnEdit) then
				begin
					old:=StrPas(TPtr);
					cr:=GetText;
					crc:=cr;
					if not(Validator^.IsValidInput(cr,false)) then
						begin
							inherited SetText(old);
							valid:=false
						end
					else
						if crc<>cr then TStatic.SetText(cr)
				end;
		if valid then
			begin
				ChrDispose(UPtr);
				UPtr:=TPtr;
				TPtr:=ChrNew(GetText);
				modified:=true
			end
	end;


function TEdit.IsValid(ReportError: boolean): boolean;

	begin
		if Validator<>nil then
			begin
				if ReportError then IsValid:=Validator^.Valid(GetText)
				else
					IsValid:=Validator^.IsValid(GetText)
			end
		else
			IsValid:=true
	end;


function TEdit.CanClose: boolean;

	begin
		CanClose:=true;
		if GetState<>bf_Disabled then
			if not(IsValid(true)) then
				begin
					CanClose:=false;
					Focus
				end
	end;


function TEdit.CanUndo: boolean;

	begin
		CanUndo:=(UPtr<>nil) and bTst(Style,es_Undo)
	end;


procedure TEdit.Undo;

	begin
		if CanUndo then SetText(StrLPas(UPtr,TextLen-1))
	end;


procedure TEdit.Paste;
	var buf  : array [0..255] of char;
	    hdl,q,
	    cnt  : integer;
	    res  : longint;

	begin
		if Clipboard=nil then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(false)) then exit;
				if IsClipboardFormatAvailable('txt') then
					begin
						res:=fopen(GetClipboardFilename+'txt',FO_READ);
						if res>=0 then
							begin
								hdl:=integer(res);
								res:=fread(hdl,256,@buf);
								fclose(hdl)
							end
					end
				else
					res:=-1;
				CloseClipboard
			end;
		if res<=0 then exit;
		cnt:=TextLen-1;
		if cnt<1 then exit;
		wind_update(BEG_UPDATE);
		HideMouse;
		q:=0;
		while q<res do
			begin
				if not(buf[q] in [#8,#9,#10,#13,#27]) then
					begin
						if Parent^.InsertChar(buf[q]) then
							begin
								dec(cnt);
								if cnt=0 then break
							end
					end;
				inc(q)
			end;
		ShowMouse;
		wind_update(END_UPDATE)
	end;


procedure TEdit.Copy;
	var buf: array [0..257] of char;
	    hdl: integer;
	    res: longint;

	begin
		if Clipboard=nil then exit;
		if length(GetText)=0 then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(true)) then exit;
				StrPCopy(buf,GetText);
				StrCat(buf,#13#10);
				res:=fcreate(GetClipboardFilename+'txt',0);
				if res>=0 then
					begin
						hdl:=integer(res);
						fwrite(hdl,StrLen(buf),@buf);
						fclose(hdl);
						SetClipboardFormat(SCF_TEXT,'.txt')
					end;
				CloseClipboard
			end
	end;


procedure TEdit.Cut;
	var buf: array [0..257] of char;
	    hdl: integer;
	    res: longint;

	begin
		if Clipboard=nil then exit;
		if length(GetText)=0 then exit;
		with Clipboard^ do
			begin
				if not(OpenClipboard(true)) then exit;
				StrPCopy(buf,GetText);
				StrCat(buf,#13#10);
				res:=fcreate(GetClipboardFilename+'txt',0);
				if res>=0 then
					begin
						hdl:=integer(res);
						if fwrite(hdl,StrLen(buf),@buf)=StrLen(buf) then Clear;
						fclose(hdl);
						SetClipboardFormat(SCF_TEXT,'.txt')
					end;
				CloseClipboard
			end
	end;


procedure TEdit.Focus;

	begin
		Parent^.SetFocus(ObjIndx)
	end;


function TEdit.IsModified: boolean;

	begin
		IsModified:=modified
	end;


procedure TEdit.ClearModify;

	begin
		modified:=false
	end;


procedure TEdit.SetValidator(AValid: PValidator);

	begin
		if Validator<>nil then Validator^.Free;
		Validator:=AValid;
		if Validator<>nil then Validator^.Window:=Parent
	end;


procedure TEdit.SetCursor(CPos: integer);
	var maxidx: integer;

	begin
		maxidx:=StrLen(ObjAddr^.ob_spec.ted_info^.te_ptext);
		if (CPos<0) or (CPos>maxidx) then CPos:=maxidx;
		EdIdx:=CPos;
		with Parent^ do
			if GetFocus=ObjIndx then
				if Attr.Status=ws_Open then
					begin
						maxidx:=EdIdx;
						objc_edit(maxidx,EDIDXABS,K_NORMAL,Work.A2,true)
					end
	end;


function TEdit.GetCursor: integer;

	begin
		GetCursor:=EdIdx
	end;


function TEdit.GetClipboard: PClipboard;

	begin
		GetClipboard:=Parent^.Clipboard
	end;


	{ private }


procedure TEdit.colEnable;

	begin
		with ObjAddr^ do
			begin
				ob_state:=ob_state and not(DISABLED);
				ob_flags:=ob_flags or EDITABLE;
				ob_spec.ted_info^.te_color:=(ob_spec.ted_info^.te_color and $f000) or (Black shl 8) or 128
			end
	end;


procedure TEdit.colDisable;

	begin
		with ObjAddr^ do
			begin
				ob_state:=ob_state and not(DISABLED);
				ob_flags:=ob_flags and not(EDITABLE);
				ob_spec.ted_info^.te_color:=(ob_spec.ted_info^.te_color and $f000) or (LBlack shl 8) or (7 shl 4) or LWhite
			end
	end;

{ *** TEDIT *** }



{ *** Objekt TPOPUP *** }

constructor TPopup.Init(AParent: PEventObject; tIndx,oIndx,stIndx: integer);
	var tp,ntp: PTree;
	    q     : integer;

	begin
		if not(inherited Init(AParent)) then fail;
		commoninit;
		pIndex:=oIndx;
		pStart:=stIndx;
		if pIndex<ROOT then
			begin
				inherited Done;
				fail
			end;
		if tIndx<>id_No then
			begin
				tp:=Application^.GetAddr(tIndx);
				if tp<>nil then tp:=@tp^[pIndex];
				if tp<>nil then
					begin
						popsize:=tp^[ROOT].ob_tail+1-pIndex;
						getmem(ntp,popsize*sizeof(AESOBJECT));
						if ntp<>nil then
							begin
								for q:=0 to popsize-1 do
									begin
										ntp^[q]:=tp^[q];
										with ntp^[q] do
											begin
												if ob_next<>-1 then dec(ob_next,oIndx);
												if ob_head<>-1 then dec(ob_head,oIndx);
												if ob_tail<>-1 then dec(ob_tail,oIndx)
											end
									end;
								with ntp^[popsize-1] do ob_flags:=ob_flags or LASTOB;
								pIndex:=ROOT;
								dec(pStart,oIndx);
								SetPopTree(ntp)
							end
					end;
				if PopTree=nil then
					begin
						inherited Done;
						fail
					end
			end
	end;


constructor TPopup.InitCollection(AParent: PEventObject; ACollection: PStringCollection; DisposeColl: boolean; MinColumns: integer);

	begin
		if not(inherited Init(AParent)) then fail;
		commoninit;
		mincols:=MinColumns;
		SetCollection(ACollection);
		lstdspose:=DisposeColl;
		if (PopTree=nil) or (List=nil) then
			begin
				inherited Done;
				fail
			end
	end;


destructor TPopup.Done;

	begin
		if lstdspose then
			if List<>nil then dispose(List,Done);
		ChrDispose(emptylist);
		FreePopTree;
		inherited Done
	end;


procedure TPopup.SetPopTree(tree: PTree);

	begin
		PopTree:=tree;
		if PopTree=nil then exit;
		if pStart<0 then pStart:=pIndex;
		pRows:=PopTree^[pStart].ob_tail+1-PopTree^[pStart].ob_head;
		if (pRows>POP_MAXROWS) or ((PopTree^[pIndex].ob_type and $ff)<>G_BOX) then PopTree:=nil
	end;


procedure TPopup.FreePopTree;

	begin
		if PopTree<>nil then
			if popsize>0 then freemem(PopTree,popsize*sizeof(AESOBJECT));
		PopTree:=nil;
		popsize:=0
	end;


procedure TPopup.SetCollection(ACollection: PStringCollection);
	const alertref: array [0..6] of AESOBJECT =
					((ob_next:-1;ob_head:1;ob_tail:4;ob_type:G_BOX;ob_flags:NONE;ob_state:NORMAL;ob_spec:(index:$ff1000);ob_x:0;ob_y:0;ob_width:0;ob_height:0),
					 (ob_next:2;ob_head:6;ob_tail:0;ob_type:G_BOX;ob_flags:NONE;ob_state:NORMAL;ob_spec:(index:0);ob_x:0;ob_y:0;ob_width:0;ob_height:0),
					 (ob_next:3;ob_head:-1;ob_tail:-1;ob_type:G_BOXCHAR;ob_flags:NONE;ob_state:NORMAL;ob_spec:(index:$01ff1100);ob_x:0;ob_y:0;ob_width:2;ob_height:1),
					 (ob_next:4;ob_head:5;ob_tail:5;ob_type:G_BOX;ob_flags:NONE;ob_state:NORMAL;ob_spec:(index:$ff1011);ob_x:0;ob_y:1;ob_width:2;ob_height:0),
					 (ob_next:ROOT;ob_head:-1;ob_tail:-1;ob_type:G_BOXCHAR;ob_flags:NONE;ob_state:NORMAL;ob_spec:(index:$02ff1100);ob_x:0;ob_y:0;ob_width:2;ob_height:1),
					 (ob_next:3;ob_head:-1;ob_tail:-1;ob_type:G_BOX;ob_flags:NONE;ob_state:NORMAL;ob_spec:(index:$ff1000);ob_x:0;ob_y:0;ob_width:2;ob_height:1),
					 (ob_next:1;ob_head:-1;ob_tail:-1;ob_type:G_STRING;ob_flags:NONE;ob_state:NORMAL;ob_spec:(free_string:nil);ob_x:0;ob_y:0;ob_width:0;ob_height:1));

				ABACKBOX = 0;
				ALISTBOX = 1;
				AUPARROW = 2;
				ASLIDER  = 3;
				ADNARROW = 4;
				ASLIDBOX = 5;
				ASTRING  = 6;

	var ntp       : PTree;
	    q,
	    maxcolumns,
	    maxrows   : longint;

	begin
		if ACollection=nil then exit;
		FreePopTree;
		List:=ACollection;
		maxcolumns:=0;
		q:=0;
		with List^ do
			while q<Count do
				begin
					if length(PString(KeyOf(At(q)))^)>maxcolumns then maxcolumns:=length(PString(KeyOf(At(q)))^);
					inc(q)
				end;
		dec(maxcolumns);
		maxrows:=List^.Count;
		pIndex:=ROOT;
		pStart:=pIndex+1;
		AutoCheck:=true;
		CheckMark:=id_No;
		listoffs:=0;
		if MaxRows<3 then MaxRows:=3;
		if MaxRows>POP_MAXROWS then MaxRows:=POP_MAXROWS;
		if MaxColumns<Max(4,mincols) then MaxColumns:=Max(4,mincols);
		if MaxColumns>78 then MaxColumns:=78;
		popsize:=6+MaxRows;
		getmem(ntp,popsize*sizeof(AESOBJECT));
		if ntp<>nil then
			begin
				ntp^[ROOT]:=alertref[ABACKBOX];
				with ntp^[ROOT] do
					begin
						ob_width:=MaxColumns+2;
						ob_height:=MaxRows
					end;
				ntp^[1]:=alertref[ALISTBOX];
				with ntp^[1] do
					begin
						ob_width:=MaxColumns;
						ob_height:=MaxRows;
						ob_tail:=popsize-1
					end;
				ntp^[2]:=alertref[AUPARROW];
				ntp^[2].ob_x:=MaxColumns;
				ntp^[3]:=alertref[ASLIDER];
				with ntp^[3] do
					begin
						ob_x:=MaxColumns;
						ob_height:=MaxRows-2
					end;
				ntp^[4]:=alertref[ADNARROW];
				with ntp^[4] do
					begin
						ob_x:=MaxColumns;
						ob_y:=MaxRows-1
					end;
				ntp^[5]:=alertref[ASLIDBOX];
				for q:=6 to popsize-1 do
					begin
						ntp^[q]:=alertref[ASTRING];
						with ntp^[q] do
							begin
								ob_width:=MaxColumns;
								ob_y:=q-6;
								if q<popsize-1 then ob_next:=q+1
								else
									ob_flags:=ob_flags or LASTOB
							end
					end;
				for q:=ROOT to popsize-1 do rsrc_obfix(ntp,q);
				inc(ntp^[ROOT].ob_width);
				dec(ntp^[3].ob_height);
				for q:=2 to 4 do inc(ntp^[q].ob_x);
				with ntp^[5] do
					begin
						if List^.Count<=MaxRows then ob_height:=ntp^[3].ob_height
						else
							ob_height:=round((ntp^[3].ob_height*MaxRows)/List^.Count)
					end;
				SetPopTree(ntp);
				if PopTree<>nil then filllist(false,0)
			end
	end;


function TPopup.pMax: integer;

	begin
		if List=nil then pMax:=pRows
		else
			pMax:=List^.Count
	end;


function TPopup.Execute: integer;
	label _error,_upagain,_dnagain,_raus,_again,_home,_shifthome;

	var scrn,memr    : MFDB;
	    q,mx,my,ms,mc,
	    evnt,key,rt,
	    wflag,wx,wy,
	    ww,wh,kstat,
	    oldobj,oldms,
	    execte       : integer;
	    blen,ql      : longint;
	    qp           : pointer;
	    autoscroll,
	    qused,valid  : boolean;
	    pipe         : Pipearray;
	    vrec         : ARRAY_4;
	    box          : GRECT;
	    spec         : array [0..POP_MAXROWS-1] of OBSPEC;
	    typ          : array [0..POP_MAXROWS-1] of integer;
	    pxy          : record
	                     case integer of
	                       0: (b8     : ARRAY_8);
	                       1: (b41,b42: ARRAY_4)
	                   end;

	procedure objunselect;

		begin
			if obj>0 then
				begin
					PopTree^[obj].ob_state:=PopTree^[obj].ob_state and not(SELECTED);
					objc_offset(PopTree,obj,vrec[0],vrec[1]);
					vrec[2]:=vrec[0]+PopTree^[obj].ob_width-1;
					vrec[3]:=vrec[1]+PopTree^[obj].ob_height-1;
					HideMouse;
					vsf_interior(Application^.vdiHandle,FIS_SOLID);
					vsf_color(Application^.vdiHandle,PopTree^[pIndex].ob_spec.index and $0000000f);
					vr_recfl(Application^.vdiHandle,vrec);
					vsf_interior(Application^.vdiHandle,FIS_HOLLOW);
					vsf_color(Application^.vdiHandle,Black);
					objc_draw(PopTree,obj,MAX_DEPTH,SysInfo.Desktop.X,SysInfo.Desktop.Y,SysInfo.Desktop.W,SysInfo.Desktop.H);
					ShowMouse
				end;
			autoscroll:=true;
			obj:=id_No
		end;

	begin
		Execute:=id_No;
		if PopTree=nil then exit;
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		execte:=id_No;
		active:=true;
		graf_mouse(ARROW,nil);
		mnusr.ub_parm:=0;
		mnusr.ub_code:=@DrawMenuRect;
		for q:=PopTree^[pStart].ob_head to PopTree^[pStart].ob_tail do
			begin
				PopTree^[q].ob_flags:=PopTree^[q].ob_flags or SELECTABLE;
				PopTree^[q].ob_state:=PopTree^[q].ob_state and (DISABLED or CHECKED);
				spec[q-PopTree^[pStart].ob_head]:=PopTree^[q].ob_spec;
				typ[q-PopTree^[pStart].ob_head]:=PopTree^[q].ob_type;
				if bTst(PopTree^[q].ob_state,DISABLED) then
					if StrPLeft(GetText(q-PopTree^[pStart].ob_head),1)='-' then
						begin
							if not(agi.SysNiceline) or not(Application^.NAESActive) then
								begin
									PopTree^[q].ob_type:=G_USERDEF;
									PopTree^[q].ob_spec.user_blk:=@mnusr;
								end;
							continue;
						end;
				if (PopTree^[q].ob_type and $ff)=G_STRING then
					if agi.GShortcut and (List=nil) then PopTree^[q].ob_type:=G_SHORTCUT;
			end;
		with PopTree^[ROOT] do
			begin
				ob_x:=0;
				ob_y:=0;
			end;
		with PopTree^[pIndex] do
			begin
				if Shadow then ob_state:=SHADOWED
				else
					ob_state:=NORMAL;
				ob_x:=pX;
				ob_y:=pY;
				if pFlag=POP_CENTER then
					begin
						dec(ob_x,ob_width shr 1);
						dec(ob_y,ob_height shr 1)
					end;
				if ob_x+ob_width>SysInfo.Desktop.X2 then ob_x:=SysInfo.Desktop.X2-ob_width;
				if ob_y+ob_height>SysInfo.Desktop.Y2 then ob_y:=SysInfo.Desktop.Y2-ob_height;
				if ob_x<=SysInfo.Desktop.X1 then ob_x:=SysInfo.Desktop.X1+1;
				if ob_y<=SysInfo.Desktop.Y1 then ob_y:=SysInfo.Desktop.Y1+1;
				box.X:=ob_x-outlwidth;
				box.Y:=ob_y-outlwidth;
				box.W:=ob_width+(outlwidth shl 1);
				box.H:=ob_height+(outlwidth shl 1)
			end;
		HideMouse;
		if not(rc_intersect(SysInfo.Desktop,box)) then goto _error;
		with memr do
			begin
				fd_w:=box.W;
				fd_h:=box.H;
				fd_stand:=FF_DEVSPEC;
				fd_wdwidth:=(fd_w+15) shr 4;
				fd_nplanes:=Application^.Attr.Planes;
				blen:=(longint(fd_wdwidth)*longint(fd_h)*longint(fd_nplanes)) shl 1
			end;
		if Application^.IsQSBUsed then ql:=-1
		else
			GetQSB(qp,ql);
		qused:=(ql>=blen);
		if qused then
			begin
				memr.fd_addr:=qp;
				Application^.IsQSBUsed:=true
			end
		else
			getmem(memr.fd_addr,blen);
		if memr.fd_addr=nil then goto _error;
		scrn.fd_addr:=nil;
		pxy.b8[0]:=box.X;
		pxy.b8[1]:=box.Y;
		pxy.b8[2]:=box.X+box.W-1;
		pxy.b8[3]:=box.Y+box.H-1;
		pxy.b8[4]:=0;
		pxy.b8[5]:=0;
		pxy.b8[6]:=memr.fd_w-1;
		pxy.b8[7]:=memr.fd_h-1;
		vro_cpyfm(Application^.vdiHandle,S_ONLY,pxy.b8,scrn,memr);
		checkoffs;
		if List<>nil then filllist(false,0);
		if AutoCheck then Check(CheckMark);
		objc_draw(PopTree,pIndex,MAX_DEPTH,SysInfo.Desktop.X,SysInfo.Desktop.Y,SysInfo.Desktop.W,SysInfo.Desktop.H);
		ShowMouse;
		obj:=id_No;
		evnt_timer(10,0);
		graf_mkstate(mx,my,mc,q);
		if bTst(mc,2) then
			repeat
				graf_mkstate(mx,my,mc,q)
			until (mc and 3)=0;
		mc:=mc and 1;
		wflag:=0;
		autoscroll:=false;
		objc_offset(PopTree,pStart,wx,wy);
		with PopTree^[pStart] do
			begin
				ww:=ob_width;
				wh:=ob_height
			end;
		_again:
		repeat
			q:=objc_find(PopTree,pIndex,MAX_DEPTH,mx,my);
			if q<>obj then
				begin
					objunselect;
					if not(Between(q,PopTree^[pStart].ob_head,PopTree^[pStart].ob_tail)) then
						begin
							wflag:=0;
							objc_offset(PopTree,pStart,wx,wy);
							with PopTree^[pStart] do
								begin
									ww:=ob_width;
									wh:=ob_height
								end
						end
					else
						if not(bTst(PopTree^[q].ob_state,DISABLED)) then
							begin
								obj:=q;
								PopTree^[obj].ob_state:=PopTree^[obj].ob_state or SELECTED;
								HideMouse;
								objc_draw(PopTree,obj,MAX_DEPTH,SysInfo.Desktop.X,SysInfo.Desktop.Y,SysInfo.Desktop.W,SysInfo.Desktop.H);
								ShowMouse;
								wflag:=1;
								objc_offset(PopTree,obj,wx,wy);
								with PopTree^[obj] do
									begin
										ww:=ob_width;
										wh:=ob_height
									end
							end
						else
							begin
								wflag:=1;
								objc_offset(PopTree,q,wx,wy);
								with PopTree^[q] do
									begin
										ww:=ob_width;
										wh:=ob_height
									end
							end
				end;
			if not(Between(q,PopTree^[pStart].ob_head,PopTree^[pStart].ob_tail)) then
				begin
					oldobj:=q;
					rt:=ExitPop(oldobj,mx,my);
					if rt<>id_No then
						begin
							execte:=rt;
							goto _raus
						end
				end
			else
				oldobj:=-1;
			evnt:=evnt_multi(MU_KEYBD or MU_TIMER or MU_BUTTON or MU_M1,257,3,0,wflag,wx,wy,ww,wh,0,0,0,0,0,pipe,poptimer,0,mx,my,ms,kstat,key,q);
			if not(bTst(evnt,MU_BUTTON)) then
				begin
					graf_mkstate(q,q,ms,q);
					if List<>nil then
						if autoscroll then
							begin
								if my<PopTree^[pIndex].ob_y then
									begin
										objunselect;
										ClickExit(2,mx,my,1);
										evnt_timer(50,0)
									end
								else
									if my>=(PopTree^[pIndex].ob_y+PopTree^[pIndex].ob_height) then
										begin
											objunselect;
											ClickExit(4,mx,my,1);
											evnt_timer(50,0)
										end
							end
				end;
			oldms:=ms;
			if bTst(ms,2) then
				begin
					evnt:=MU_KEYBD;
					key:=S_Esc
				end;
			if bTst(evnt,MU_KEYBD) then
				begin
					if lfrtcrs then
						case key of
						Cur_Left:
							key:=Cur_Up;
						Cur_Right:
							key:=Cur_Down
						end;
					case key of
					Shift_CU:
						begin
							if listoffs>0 then
								begin
									if AutoCheck then Uncheck(Checkmark);
									objunselect;
									q:=listoffs;
									dec(listoffs,pRows);
									if listoffs<0 then listoffs:=0;
									if AutoCheck then Check(Checkmark);
									if List<>nil then filllist(true,listoffs-q)
								end;
							if isanyenabled then
								begin
									q:=0;
									while GetState(q)=bf_Disabled do inc(q);
									MouseSim(q)
								end
						end;
					Shift_CD:
						begin
							if listoffs+pRows<pMax then
								begin
									if AutoCheck then Uncheck(Checkmark);
									objunselect;
									q:=listoffs;
									inc(listoffs,pRows);
									checkoffs;
									if AutoCheck then Check(Checkmark);
									if List<>nil then filllist(true,listoffs-q)
								end;
							if isanyenabled then
								begin
									q:=pRows-1;
									while GetState(q)=bf_Disabled do dec(q);
									MouseSim(q)
								end
						end;
					Cur_Up:
						if isanyenabled then
							begin
								{ Flackern beseitigen... }
								if obj>0 then
									begin
										q:=obj-PopTree^[pStart].ob_head-1;
										_upagain:
										if q>=0 then
											if GetState(q)=bf_Disabled then
												begin
													dec(q);
													goto _upagain
												end;
										if q<0 then
											begin
												if listoffs>0 then
													begin
														if AutoCheck then Uncheck(Checkmark);
														objunselect;
														dec(listoffs);
														if AutoCheck then Check(Checkmark);
														if List<>nil then filllist(true,-1);
														q:=0
													end
												else
													goto _shifthome
											end;
										MouseSim(q)
									end
								else
									begin
										q:=pRows-1;
										while GetState(q)=bf_Disabled do dec(q);
										MouseSim(q)
									end
							end;
					Cur_Down:
						if isanyenabled then
							begin
								if obj>0 then
									begin
										q:=obj+1-PopTree^[pStart].ob_head;
										_dnagain:
										if q<pRows then
											if GetState(q)=bf_Disabled then
												begin
													inc(q);
													goto _dnagain
												end;
										if q>=pRows then
											begin
												if pRows+listoffs<pMax then
													begin
														if AutoCheck then Uncheck(Checkmark);
														objunselect;
														inc(listoffs);
														if AutoCheck then Check(Checkmark);
														if List<>nil then filllist(true,1);
														q:=pRows-1
													end
												else
													goto _home
											end;
										MouseSim(q)
									end
								else
									begin
										q:=0;
										while GetState(q)=bf_Disabled do inc(q);
										MouseSim(q)
									end
							end;
					Home:
						begin
							_home:
							if listoffs>0 then
								begin
									if AutoCheck then Uncheck(Checkmark);
									objunselect;
									q:=listoffs;
									listoffs:=0;
									if AutoCheck then Check(Checkmark);
									if List<>nil then filllist(true,-q)
								end;
							if isanyenabled then
								begin
									q:=0;
									while GetState(q)=bf_Disabled do inc(q);
									MouseSim(q)
								end
						end;
					Shift_Home:
						begin
							_shifthome:
							if listoffs+pRows<pMax then
								begin
									if AutoCheck then Uncheck(Checkmark);
									objunselect;
									q:=listoffs;
									listoffs:=pMax-pRows;
									if AutoCheck then Check(Checkmark);
									if List<>nil then filllist(true,listoffs-q)
								end;
							if isanyenabled then
								begin
									q:=pRows-1;
									while GetState(q)=bf_Disabled do dec(q);
									MouseSim(q)
								end
						end;
					Return,Enter,$3920:
						ms:=mc xor 1;
					S_Esc,S_Undo:
						begin
							if obj>0 then PopTree^[obj].ob_state:=PopTree^[obj].ob_state and not(SELECTED);
							obj:=id_No;
							ms:=mc xor 1
						end
					else
						if not(TestKey(kstat,key)) then
							begin
								rt:=KeyExit(kstat,key);
								if rt<>id_No then
									begin
										execte:=rt;
										if obj>0 then PopTree^[obj].ob_state:=PopTree^[obj].ob_state and not(SELECTED);
										goto _raus
									end
							end
					end
				end
		until (ms and 1)<>mc;
		if not(ClickExit(oldobj,mx,my,oldms)) then
			begin
				mc:=0;
				goto _again;
			end;
		if obj>0 then
			begin
				PopTree^[obj].ob_state:=PopTree^[obj].ob_state and not(SELECTED);
				execte:=listoffs+obj-PopTree^[pStart].ob_head
			end
		else
			execte:=id_No;
		_raus:
		HideMouse;
		scrn.fd_addr:=nil;
		vrec:=pxy.b41;
		pxy.b41:=pxy.b42;
		pxy.b42:=vrec;
		vro_cpyfm(Application^.vdiHandle,S_ONLY,pxy.b8,memr,scrn);
		if qused then Application^.IsQSBUsed:=false
		else
			freemem(memr.fd_addr,blen);
		if AutoCheck then
			begin
				Uncheck(CheckMark);
				if execte>=0 then CheckMark:=execte
			end;
		_error:
		ShowMouse;
		for q:=PopTree^[pStart].ob_head to PopTree^[pStart].ob_tail do
			begin
				PopTree^[q].ob_spec:=spec[q-PopTree^[pStart].ob_head];
				PopTree^[q].ob_type:=typ[q-PopTree^[pStart].ob_head]
			end;
		graf_mouse(maus.currnr,@maus.currform);
		if wait0 then
			repeat
				graf_mkstate(mx,my,ms,q)
			until ms=0;
		active:=false;
		Execute:=execte;
		wind_update(END_MCTRL);
		wind_update(END_UPDATE)
	end;


function TPopup.ClickExit(Indx,mX,mY,BStat: integer): boolean;
	var x,y,old,ms,dummy: integer;

	begin
		ClickExit:=true;
		if List<>nil then
			if not(bTst(BStat,2)) and (Indx>=ROOT) then
				begin
					ClickExit:=false;
					case Indx of
					2:
						if listoffs>0 then
							begin
								if AutoCheck then Uncheck(CheckMark);
								dec(listoffs);
								if AutoCheck then Check(CheckMark);
								filllist(true,-1)
							end;
					3:
						begin
							objc_offset(PopTree,5,x,y);
							if (mY<y) and (listoffs>0) then
								begin
									if AutoCheck then Uncheck(CheckMark);
									old:=listoffs;
									dec(listoffs,pRows);
									if listoffs<0 then listoffs:=0;
									if AutoCheck then Check(CheckMark);
									filllist(true,listoffs-old)
								end
							else
								if (mY>=y+PopTree^[5].ob_height) and (pRows+listoffs<pMax) then
									begin
										if AutoCheck then Uncheck(CheckMark);
										old:=listoffs;
										inc(listoffs,pRows);
										checkoffs;
										if AutoCheck then Check(CheckMark);
										filllist(true,listoffs-old)
									end;
							evnt_timer(20,0)
						end;
					4:
						if pRows+listoffs<pMax then
							begin
								if AutoCheck then Uncheck(CheckMark);
								inc(listoffs);
								if AutoCheck then Check(CheckMark);
								filllist(true,1)
							end;
					5:
						if pRows<pMax then
							begin
								graf_mouse(FLAT_HAND,nil);
								old:=listoffs;
								repeat
									graf_mkstate(x,y,ms,dummy);
									dummy:=old+round((longint(pMax-pRows)*longint(y-mY))/longint(PopTree^[3].ob_height-PopTree^[5].ob_height));
									if dummy<0 then dummy:=0;
									if pRows+dummy>pMax then dummy:=pMax-pRows;
									if listoffs<>dummy then
										begin
											if AutoCheck then Uncheck(CheckMark);
											x:=dummy-listoffs;
											listoffs:=dummy;
											if AutoCheck then Check(CheckMark);
											filllist(true,x)
										end
								until ms=0;
								graf_mouse(ARROW,nil)
							end
					end
				end
	end;


function TPopup.ExitPop(Indx,mX,mY: integer): integer;

	begin
		ExitPop:=id_No
	end;


function TPopup.KeyExit(Stat,Key: integer): integer;

	begin
		KeyExit:=id_No
	end;


procedure TPopup.SetSelection(nr: integer);

	begin
		if active then
			if isanyenabled then
				begin
					dec(nr,listoffs);
					if (nr>=0) and (nr<pRows) then
						if GetState(nr)<>bf_Disabled then
							if nr<>GetSelection then MouseSim(nr)
				end
	end;


function TPopup.GetSelection: integer;

	begin
		if active then
			begin
				if obj>=0 then GetSelection:=listoffs+obj
				else
					GetSelection:=id_No
			end
		else
			GetSelection:=id_No
	end;


procedure TPopup.SetText(nr: integer; ATextString: string);

	begin
		if (nr>=0) and (nr<pRows) and (PopTree<>nil) and (List=nil) then
			if isstring(nr) then
				StrPCopy(PopTree^[nr+PopTree^[pStart].ob_head].ob_spec.free_string,ATextString)
	end;


function TPopup.GetText(nr: integer): string;

	begin
		GetText:='';
		if (nr>=0) and (nr<pMax) and (PopTree<>nil) then
			begin
				if List<>nil then GetText:=StrPTrimF(PString(List^.KeyOf(List^.At(nr)))^)
				else
					if isstring(nr) then
						GetText:=StrPTrimF(StrPas(PopTree^[nr+PopTree^[pStart].ob_head].ob_spec.free_string))
			end
	end;


procedure TPopup.SetState(nr,StateFlag: integer);

	begin
		if (nr>=0) and (nr<pRows) and (PopTree<>nil) and (List=nil) then
			begin
				if StateFlag=bf_Disabled then PopTree^[nr+PopTree^[pStart].ob_head].ob_state:=PopTree^[nr+PopTree^[pStart].ob_head].ob_state or DISABLED
				else
					PopTree^[nr+PopTree^[pStart].ob_head].ob_state:=PopTree^[nr+PopTree^[pStart].ob_head].ob_state and not(DISABLED)
			end
	end;


function TPopup.GetState(nr: integer): integer;

	begin
		if (nr>=0) and (nr<pMax) and (PopTree<>nil) then
			begin
				if List<>nil then GetState:=bf_Enabled
				else
					if bTst(PopTree^[nr+PopTree^[pStart].ob_head].ob_state,DISABLED) then GetState:=bf_Disabled
					else
						GetState:=bf_Enabled
			end
		else
			GetState:=id_No
	end;


procedure TPopup.Disable(nr: integer);

	begin
		SetState(nr,bf_Disabled)
	end;


procedure TPopup.Enable(nr: integer);

	begin
		SetState(nr,bf_Enabled)
	end;


procedure TPopup.SetCheck(nr,CheckFlag: integer);

	begin
		dec(nr,listoffs);
		if (nr>=0) and (nr<pRows) and (PopTree<>nil) then
			begin
				if CheckFlag=bf_Checked then PopTree^[nr+PopTree^[pStart].ob_head].ob_state:=PopTree^[nr+PopTree^[pStart].ob_head].ob_state or CHECKED
				else
					PopTree^[nr+PopTree^[pStart].ob_head].ob_state:=PopTree^[nr+PopTree^[pStart].ob_head].ob_state and not(CHECKED)
			end
	end;


function TPopup.GetCheck(nr: integer): integer;

	begin
		GetCheck:=id_No;
		if (nr>=0) and (nr<pMax) and (PopTree<>nil) then
			begin
				if AutoCheck then
					begin
						if nr=CheckMark then GetCheck:=bf_Checked
						else
							GetCheck:=bf_Unchecked
					end
				else
					begin
						dec(nr,listoffs);
						if (nr>=0) and (nr<pRows) then
							begin
								if bTst(PopTree^[nr+PopTree^[pStart].ob_head].ob_state,CHECKED) then GetCheck:=bf_Checked
								else
									GetCheck:=bf_Unchecked
							end
						else
							GetCheck:=bf_Unchecked
					end
			end
	end;


procedure TPopup.Check(nr: integer);

	begin
		SetCheck(nr,bf_Checked)
	end;


procedure TPopup.Uncheck(nr: integer);

	begin
		SetCheck(nr,bf_Unchecked)
	end;


procedure TPopup.Toggle(nr: integer);

	begin
		if GetCheck(nr)=bf_Unchecked then SetCheck(nr,bf_Checked)
		else
			SetCheck(nr,bf_Unchecked)
	end;


procedure TPopup.SetOffset(Offs: integer);

	begin
		listoffs:=Offs;
		checkoffs
	end;


function TPopup.GetOffset: integer;

	begin
		GetOffset:=listoffs
	end;


	{ private }


procedure TPopup.MouseSim(sobj: integer);
	var x,y: integer;

	begin
		{ korrektes Cursorverhalten, wenn pMax<pRows... }
		objc_offset(PopTree,pStart,x,y);
		with PopTree^[pStart] do
			SetMousePos(x+PopTree^[ob_head+sobj].ob_x+(PopTree^[ob_head+sobj].ob_width shr 1),y+PopTree^[ob_head+sobj].ob_y+(PopTree^[ob_head+sobj].ob_height shr 1))
	end;


function TPopup.isstring(nr: integer): boolean;

	begin
		isstring:=((PopTree^[nr+PopTree^[pStart].ob_head].ob_type and $ff)=G_STRING)
	end;


function TPopup.isanyenabled: boolean;
	var q: integer;

	begin
		isanyenabled:=false;
		for q:=0 to pRows-1 do
			if GetState(q)=bf_Enabled then
				begin
					isanyenabled:=true;
					exit
				end
	end;


procedure TPopup.checkoffs;

	begin
		if listoffs+pRows>pMax then listoffs:=pMax-pRows;
		if listoffs<0 then listoffs:=0
	end;


procedure TPopup.filllist(draw: boolean; diff: integer);
	var q,n,x,y,wy,wh: integer;
	    pxy          : ARRAY_8;
	    scrn,memr    : MFDB;

	begin
		KeyRepeatOff;
		for q:=6 to popsize-1 do
			with PopTree^[q] do
				begin
					n:=q+listoffs-6;
					if n<List^.Count then
						begin
							ob_state:=ob_state and not(DISABLED);
							ob_spec.free_string:=pointer(longint(List^.KeyOf(List^.At(n)))+1)
						end
					else
						begin
							ob_state:=ob_state or DISABLED;
							ob_spec.free_string:=emptylist
						end
				end;
		with PopTree^[5] do
			if pRows<pMax then ob_y:=round((longint(listoffs)*longint(PopTree^[3].ob_height-ob_height))/longint(pMax-pRows))
			else
				ob_y:=0;
		if draw then
			if diff<>0 then
				begin
					HideMouse;
					objc_offset(PopTree,1,x,y);
					if abs(diff)<pRows then
						begin
							with PopTree^[1] do
								if diff>0 then
									begin
										wh:=diff*PopTree^[6].ob_height;
										pxy[0]:=x;
										pxy[1]:=y+wh;
										pxy[2]:=x+ob_width-1;
										pxy[3]:=y+ob_height-1;
										pxy[4]:=x;
										pxy[5]:=y;
										pxy[6]:=pxy[2];
										pxy[7]:=pxy[3]-wh;
										wy:=pxy[3]-wh
									end
								else
									begin
										wh:=-diff*PopTree^[6].ob_height;
										pxy[0]:=x;
										pxy[1]:=y;
										pxy[2]:=x+ob_width-1;
										pxy[3]:=y+ob_height-wh-1;
										pxy[4]:=x;
										pxy[5]:=y+wh;
										pxy[6]:=pxy[2];
										pxy[7]:=y+ob_height-1;
										wy:=y
									end;
							scrn.fd_addr:=nil;
							memr.fd_addr:=nil;
							vro_cpyfm(Application^.vdiHandle,S_ONLY,pxy,scrn,memr)
						end
					else
						begin
							wy:=y;
							wh:=PopTree^[1].ob_height
						end;
					objc_draw(PopTree,1,MAX_DEPTH,x,wy,PopTree^[1].ob_width,wh);
					objc_draw(PopTree,3,MAX_DEPTH,SysInfo.Desktop.X,SysInfo.Desktop.Y,SysInfo.Desktop.W,SysInfo.Desktop.H);
					ShowMouse
				end;
		KeyRepeatRestore
	end;


procedure TPopup.commoninit;

	begin
		Style:=Style or es_Popup;
		Shadow:=true;
		lfrtcrs:=true;
		wait0:=true;
		active:=false;
		lstdspose:=false;
		popsize:=0;
		PopTree:=nil;
		emptylist:=ChrNew('');
		listoffs:=0;
		List:=nil;
		pFlag:=POP_LEFTOP;
		pRows:=0;
		pX:=0;
		pY:=0;
		AutoCheck:=false;
		CheckMark:=id_No;
		mincols:=0
	end;

{ *** TPOPUP *** }



{ *** Objekt TSCROLLER *** }

constructor TScroller.Init(TheWindow: PWindow; TheXUnit,TheYUnit: integer; TheXRange,TheYRange: longint);

	begin
		if not(inherited Init) then fail;
		Window:=TheWindow;
		if Window=nil then
			begin
				inherited Done;
				fail
			end;
		Window^.Scroller:=@self;
		TrackMode:=true;
		HasVScrollBar:=bTst(Window^.Attr.Style,VSLIDE);
		HasHScrollBar:=bTst(Window^.Attr.Style,HSLIDE);
		Style:=0;
		XLine:=1;
		YLine:=1;
		XPos:=0;
		YPos:=0;
		XUnit:=TheXUnit;
		YUnit:=TheYUnit;
		if XUnit<1 then XUnit:=1;
		if YUnit<1 then YUnit:=1;
		SetPageSize;
		SetRange(TheXRange,TheYRange)
	end;


destructor TScroller.Done;

	begin
		Window^.Scroller:=nil;
		inherited Done
	end;


procedure TScroller.HScroll;
	var dif: longint;

	begin
		if HasHScrollBar then
			begin
				dif:=XRange-XPage-1;
				if dif<1 then dif:=1;
				dif:=round(longint(1000)*XPos/dif);
				if dif>1000 then dif:=1000;
				with Window^.Attr do
					if gemHandle>=0 then
						wind_set(gemHandle,WF_HSLIDE,dif,0,0,0)
			end
	end;


procedure TScroller.VScroll;
	var dif: longint;

	begin
		if HasVScrollBar then
			begin
				dif:=YRange-YPage-1;
				if dif<1 then dif:=1;
				dif:=round(longint(1000)*YPos/dif);
				if dif>1000 then dif:=1000;
				with Window^.Attr do
					if gemHandle>=0 then
						wind_set(gemHandle,WF_VSLIDE,dif,0,0,0)
			end
	end;


function TScroller.IsVisibleRect(X,Y,XExt,YExt: longint): boolean;
	var r,rc: GRECT;

	begin
		Window^.GetVWork(rc);
		r.X:=(X-XPos)*XUnit+rc.X;
		r.Y:=(Y-YPos)*YUnit+rc.Y;
		r.W:=XExt*XUnit;
		r.H:=YExt*YUnit;
		IsVisibleRect:=rc_intersect(rc,r)
	end;


procedure TScroller.ScrollBy(dX,dY: longint);
	var pw,ph,xdif,ydif: longint;
	    r              : GRECT;

	begin
		inc(dX,XPos);
		inc(dY,YPos);
		Window^.GetVWork(r);
		pw:=round(r.W/XUnit);
		ph:=round(r.H/YUnit);
		if dX+pw>=XRange then dX:=XRange-pw-1;
		if dY+ph>=YRange then dY:=YRange-ph-1;
		if dX<0 then dX:=0;
		if dY<0 then dY:=0;
		if (dX<>XPos) or (dY<>YPos) then
			begin
				if dX<>XPos then
					begin
						xdif:=(dX-XPos)*longint(XUnit);
						XPos:=dX;
						HScroll
					end
				else
					xdif:=0;
				if dY<>YPos then
					begin
						ydif:=(dY-YPos)*longint(YUnit);
						YPos:=dY;
						VScroll
					end
				else
					ydif:=0;
				ParentPaint(xdif,ydif)
			end
	end;


procedure TScroller.ScrollTo(X,Y: longint);
	var pw,ph,xdif,ydif: longint;
	    r              : GRECT;

	begin
		Window^.GetVWork(r);
		pw:=round(r.W/XUnit);
		ph:=round(r.H/YUnit);
		if X+pw>=XRange then X:=XRange-pw-1;
		if Y+ph>=YRange then Y:=YRange-ph-1;
		if X<0 then X:=0;
		if Y<0 then Y:=0;
		if (X<>XPos) or (Y<>YPos) then
			begin
				if X<>XPos then
					begin
						xdif:=(X-XPos)*longint(XUnit);
						XPos:=X;
						HScroll
					end
				else
					xdif:=0;
				if Y<>YPos then
					begin
						ydif:=(Y-YPos)*longint(YUnit);
						YPos:=Y;
						VScroll
					end
				else
					ydif:=0;
				ParentPaint(xdif,ydif)
			end
	end;


procedure TScroller.SetPageSize;
	var r: GRECT;

	begin
		Window^.GetVWork(r);
		XPage:=round(r.W/XUnit);
		YPage:=round(r.H/YUnit)
	end;


procedure TScroller.SetSBarRange;
	var dummy,pw,ph,xp,yp: longint;
	    valid            : boolean;
	    r                : GRECT;

	begin
		Window^.GetVWork(r);
		pw:=round(r.W/XUnit);
		ph:=round(r.H/YUnit);
		xp:=XPos;
		yp:=YPos;
		if xp+pw>=XRange then xp:=XRange-pw-1;
		if yp+ph>=YRange then yp:=YRange-ph-1;
		if xp<0 then xp:=0;
		if yp<0 then yp:=0;
		valid:=((xp<>XPos) or (yp<>YPos));
		XPos:=xp;
		YPos:=yp;
		if HasHScrollBar then
			begin
				dummy:=round(longint(1000)*longint(pw+1)/XRange);
				if dummy<1 then dummy:=1;
				if dummy>1000 then dummy:=1000;
				with Window^.Attr do
					if gemHandle>=0 then
						wind_set(gemHandle,WF_HSLSIZE,dummy,0,0,0)
			end;
		if HasVScrollBar then
			begin
				dummy:=round(longint(1000)*longint(ph+1)/YRange);
				if dummy<1 then dummy:=1;
				if dummy>1000 then dummy:=1000;
				with Window^.Attr do
					if gemHandle>=0 then
						wind_set(gemHandle,WF_VSLSIZE,dummy,0,0,0)
			end;
		HScroll;
		VScroll;
		if valid then Window^.ForceVRedraw
	end;


procedure TScroller.SetRange(TheXRange,TheYRange: longint);

	begin
		XRange:=TheXRange;
		YRange:=TheYRange;
		if XRange<1 then XRange:=1;
		if YRange<1 then YRange:=1;
		SetSBarRange
	end;


procedure TScroller.SetUnits(TheXUnit,TheYUnit: integer);

	begin
		if TheXUnit<1 then TheXUnit:=1;
		if TheYUnit<1 then TheYUnit:=1;
		if (XUnit<>TheXUnit) or (YUnit<>TheYUnit) then
			begin
				XUnit:=TheXUnit;
				YUnit:=TheYUnit;
				Window^.ForceVRedraw
			end
	end;


function TScroller.GetXOrg: longint;
	var r: GRECT;

	begin
		Window^.GetVWork(r);
		GetXOrg:=longint(r.X)-XPos*longint(XUnit)
	end;


function TScroller.GetYOrg: longint;
	var r: GRECT;

	begin
		Window^.GetVWork(r);
		GetYOrg:=longint(r.Y)-YPos*longint(YUnit)
	end;


procedure TScroller.RedrawParent(XDif,YDif: longint);

	begin
	end;


	{ private }


procedure TScroller.ParentPaint(xdif,ydif: longint);
	label _fertig;

	var sm,dm  : MFDB;
	    xy     : ARRAY_8;
	    rect,vr,
	    hr,vwk : GRECT;
	    valid  : boolean;
	    pipe   : Pipearray;
	    vh     : integer;

	procedure zeichnen(box: GRECT);
		var PaintInfo: TPaintStruct;

		begin
			vs_clip(vh,CLIP_ON,box.A2);
			vs_clip(Window^.vdiHandle,CLIP_ON,box.A2);
			with PaintInfo do
				begin
					rcPaint:=box;
					feColor:=Window^.Class.hbrBackground-1;
					if feColor>=0 then
						begin
							fErase:=true;
							vsf_interior(vh,FIS_SOLID);
							vsf_color(vh,feColor);
							vr_recfl(vh,rcPaint.A2);
							vsf_interior(vh,FIS_HOLLOW);
							vsf_color(vh,Black)
						end
					else
						fErase:=false
				end;
			Window^.Paint(PaintInfo);
			vs_clip(vh,CLIP_ON,SysInfo.Desktop.A2);
			vs_clip(Window^.vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
		end;

	begin
		if Window^.Attr.Status<>ws_Open then exit;
		if Window^.IsShaded then exit;
		if (xdif=0) and (ydif=0) then exit;
		if not(TrackMode) or Window^.IsIconified then
			begin
				Window^.ForceVRedraw;
				exit
			end;
		wind_update(BEG_UPDATE);
		RedrawParent(xdif,ydif);
		Window^.GetVWork(vwk);
		if not(bTst(Style,scs_BitbltScrolling)) then
			begin
				with vwk do Window^.WMRedraw(X,Y,W,H);
				goto _fertig
			end;
		vh:=Application^.vdiHandle;
		HideMouse;
		valid:=Window^.FirstWorkRect(rect);
		Window^.UpdateDialog;
		Window^.InitPaint;
		while valid do
			begin
				if rc_intersect(vwk,rect) then
					begin
						if (rect.H>=abs(ydif)+YUnit) and (rect.W>=abs(xdif)+XUnit) then
							begin
								with rect do
									begin
										if ydif>0 then
											begin
												xy[1]:=Y1+ydif;
												xy[3]:=Y2;
												xy[5]:=Y1;
												xy[7]:=Y2-ydif;
												vr.Y1:=Y2+1-ydif;
												vr.Y2:=Y2
											end
										else
											begin
												xy[1]:=Y1;
												xy[3]:=Y2+ydif;
												xy[5]:=Y1-ydif;
												xy[7]:=Y2;
												vr.Y1:=Y1;
												vr.Y2:=Y1-ydif-1
											end;
										if xdif>0 then
											begin
												xy[0]:=X1+xdif;
												xy[2]:=X2;
												xy[4]:=X1;
												xy[6]:=X2-xdif;
												hr.X1:=X2+1-xdif;
												hr.X2:=X2
											end
										else
											begin
												xy[0]:=X1;
												xy[2]:=X2+xdif;
												xy[4]:=X1-xdif;
												xy[6]:=X2;
												hr.X1:=X1;
												hr.X2:=X1-xdif-1
											end
									end;
								sm.fd_addr:=nil;
								dm.fd_addr:=nil;
								vro_cpyfm(vh,S_ONLY,xy,sm,dm);
								if ydif<>0 then
									begin
										vr.X1:=rect.X1;
										vr.X2:=rect.X2;
										A2toGR(vr);
										zeichnen(vr)
									end;
								if xdif<>0 then
									begin
										hr.Y1:=rect.Y1;
										hr.Y2:=rect.Y2;
										A2toGR(hr);
										zeichnen(hr)
									end
							end
						else
							zeichnen(rect)
					end;
				valid:=Window^.NextWorkRect(rect)
			end;
		Window^.ExitPaint;
		vs_clip(vh,CLIP_ON,SysInfo.Desktop.A2);
		vs_clip(Window^.vdiHandle,CLIP_ON,SysInfo.Desktop.A2);
		ShowMouse;
		_fertig:
		wind_update(END_UPDATE)
	end;

{ *** TSCROLLER *** }



{ *** Objekt TWINDOW *** }

constructor TWindow.Init(AParent: PWindow; ATitle: string);
	var p : PWindow;
	    pp: ^PWindow;
	    i : integer;

  begin
  	if not(inherited Init) then fail;
  	Parent:=AParent;
  	vdiHandle:=GetVDIHandle;
  	if vdiHandle=id_NewHandle then
  		begin
		  	for i:=1 to 9 do workIn[i]:=1;
		  	workIn[0]:=getrez+2;
				workIn[10]:=RC;
				vdiHandle:=Application^.aesHandle;
				v_opnvwk(workIn,vdiHandle,workOut);
				ownhndl:=true
			end
		else
			begin
				workIn:=Application^.workIn;
				workOut:=Application^.workOut;
				ownhndl:=false
			end;
		if vdiHandle<=0 then
			begin
				inherited Done;
				fail
			end;
		if Application^.SpeedoActive and ownhndl then vst_error(vdiHandle,0,spderr);
    inc(Application^.HMax);
		fillchar(Work,sizeof(Work),0);
    with Attr do
    	begin
    	  Title:=nil;
    		SubTitle:=nil;
    		Handle:=Application^.HMax;
    		gemHandle:=-1;
    		Style:=GetStyle;
    		ExStyle:=ws_ex_Modeless;
				fillchar(VWork,sizeof(VWork),0);
    		Status:=ws_NoWindow;
    		if ownhndl then
    			begin
		   			sysFonts:=workOut[10];
   					addFonts:=0
   				end
   			else
   				begin
   					sysFonts:=Application^.Attr.sysFonts;
   					addFonts:=Application^.Attr.addFonts;
   					charWidth:=Application^.Attr.charWidth;
   					charHeight:=Application^.Attr.charHeight;
   					boxWidth:=Application^.Attr.boxWidth;
   					boxHeight:=Application^.Attr.boxHeight
   				end
    	end;
    ChildList:=nil;
    Scroller:=nil;
    Icon:=nil;
    Prev:=nil;
    Nxt:=nil;
    if Parent<>nil then pp:=@Parent^.ChildList
    else
    	pp:=@Application^.MainWindow;
		if pp^=nil then pp^:=@self
		else
			begin
				p:=pp^;
				while p^.Nxt<>nil do p:=p^.Nxt;
				p^.Nxt:=@self;
				Prev:=p
			end;
		for i:=0 to MAXTOOLBARS do
			with tbval[i] do
				begin
					Size:=0;
					Indx:=-1;
					Tree:=nil
				end;
		DlgTree:=nil;
		tbtree:=-1;
		icntitl:=nil;
		icfpos:=-1;
		nxticn:=nil;
		Application^.ChkError;
    GetWindowClass(Class);
    GetIconWindowClass(IconClass);
    EnableAutoCreate;
    SetTitle(ATitle);
    SetSubTitle('');
    if ownhndl then SetupVDI;
    Scroller:=GetScroller;
    Clipboard:=GetClipboard;
    SetupWindow;
    if (Application^.Err=em_InvalidWindow) or (Application^.Err=em_InvalidMainWindow) or (Application^.Err=em_WOpenFailure) then
    	begin
    		Done;
    		fail
    	end
  end;


destructor TWindow.Done;
	var pp: ^PWindow;
	    q : integer;

	begin
		while (ChildList<>nil) do ChildList^.Free;
		ShutdownWindow;
		if Attr.Status in [ws_Created,ws_Open] then Destroy;
		FreeIcon;
		FreeDialog;
		for q:=MAXTOOLBARS downto 0 do FreeToolbar(tbval[q].Indx);
		FreeMenu;
		if Attr.Handle=Application^.HMax then dec(Application^.HMax);
    if Parent<>nil then pp:=@Parent^.ChildList
    	else pp:=@Application^.MainWindow;
		if (Prev=nil) and (Nxt=nil) then pp^:=nil
		else
			begin
				if Prev=nil then pp^:=Nxt
					else Prev^.Nxt:=Nxt;
				if Nxt<>nil then Nxt^.Prev:=Prev
			end;
		DisposeStr(Attr.Title);
		DisposeStr(Attr.SubTitle);
		DisposeStr(Class.lpszClassName);
		if Scroller<>nil then Scroller^.Free;
		if Clipboard<>nil then
			if Clipboard^.Parent=@self then Clipboard^.Free;
	  if (vdiHandle>0) and ownhndl then
	  	begin
				if bTst(Attr.ExStyle,ws_ex_LoadFonts) then
					if Application^.GDOSActive then vst_unload_fonts(vdiHandle,0);
			  v_clsvwk(vdiHandle)
			end;
		inherited Done
	end;


function TWindow.GetVDIHandle: integer;

	begin
		GetVDIHandle:=id_NewHandle
	end;


procedure TWindow.SetupVDI;
	var dummy: integer;

	begin
		spderr:=0;
		if Application^.GDOSActive then
			if bTst(Attr.ExStyle,ws_ex_LoadFonts) then Attr.addFonts:=vst_load_fonts(vdiHandle,0);
		if spderr<>0 then Application^.Err:=em_SpeedoLoadFailure;
		SetSystemFont(vdiHandle,Attr.charWidth,Attr.charHeight,Attr.boxWidth,Attr.boxHeight);
		vst_alignment(vdiHandle,TA_LEFT,TA_BASELINE,dummy,dummy);
		vsl_udsty(vdiHandle,$5555);
		vsf_interior(vdiHandle,FIS_HOLLOW);
		vsf_style(vdiHandle,4);
		vsm_height(vdiHandle,1);
		vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
	end;


function TWindow.GetStyle: integer;
	var ret: integer;

	begin
		ret:=NAME or INFO or CLOSER or MOVER or FULLER or SIZER;
		if agi.Iconify then
			begin
				if TOSVersion=$0492 then ret:=ret or $1000
				else
					ret:=ret or SMALLER
			end;
		if bTst(agi.Gadgets,2) then ret:=ret or BACKDROP;
		GetStyle:=ret
	end;


function TWindow.GetScroller: PScroller;

	begin
		GetScroller:=nil
	end;


function TWindow.GetClipboard: PClipboard;

	begin
		GetClipboard:=Application^.Clipboard
	end;


function TWindow.GetOLGAGroup: integer;

	begin
		GetOLGAGroup:=integer(Attr.Handle and $7fff)
	end;


procedure TWindow.GetWindowClass(var AWndClass: TWndClass);

	begin
		with AWndClass do
			begin
				Style:=cs_DblClks or cs_CreateOnAccOpen or cs_AutoOpen or cs_QuitOnClose or cs_OLGADocument;
				hCursor:=ARROW;
				hbrBackground:=White+1;
				ToolbarTree:=nil;
				MenuTree:=nil;
				lpszClassName:=NewStr(GetClassName)
			end
	end;


procedure TWindow.GetIconWindowClass(var AWndClass: TIconWndClass);

	begin
		with AWndClass do
			begin
				hCursor:=ARROW;
				hbrBackground:=White+1
			end
	end;


function TWindow.GetClassName: string;

	begin
		GetClassName:='Window'
	end;


function TWindow.GetIconTitle: string;

	begin
		GetIconTitle:=GetTitle
	end;


function TWindow.GetTitle: string;

	begin
		if Attr.Title=nil then GetTitle:=''
		else
			GetTitle:=StrPTrimF(Attr.Title^)
	end;


function TWindow.CanClose: boolean;
	var valid: boolean;
			p    : PWindow;

	begin
		valid:=true;
  	p:=ChildList;
  	while (p<>nil) and valid do
  		with p^ do
	  		begin
  				if Attr.Status=ws_Open then
	  				if not(CanClose) then valid:=false;
  				p:=Nxt
	  		end;
		CanClose:=valid
	end;


function TWindow.IsIconified: boolean;
	var valid,dummy: integer;

	begin
		if agi.Iconify and (Attr.gemHandle>=0) then
			begin
				wind_get(Attr.gemHandle,WF_ICONIFY,valid,dummy,dummy,dummy);
				IsIconified:=(valid<>0)
			end
		else
			IsIconified:=(icfpos>=0)
	end;


function TWindow.IsShaded: boolean;
	var mode,
	    dummy,
	    x,y,w,h: integer;

	begin
		if Application^.MagiCActive then
			begin
				if IsModeless then
					begin
						if Attr.Status=ws_Open then
							begin
								wind_get(Attr.gemHandle,WF_FIRSTXYWH,x,y,w,h);
								IsShaded:=((w<=0) or (h<=0))
							end
						else
							IsShaded:=true
					end
				else
					IsShaded:=false
			end
		else
			begin
				if agi.Shading and (Attr.gemHandle>=0) then
					begin
						wind_get(Attr.gemHandle,WF_SHADE,mode,dummy,dummy,dummy);
						IsShaded:=(mode<>0)
					end
				else
					IsShaded:=false
			end
	end;


function TWindow.IsModeless: boolean;

	begin
		IsModeless:=(Attr.gemHandle>=0)
	end;


function TWindow.IsDialog: boolean;

	begin
		IsDialog:=false
	end;


function TWindow.IsTop: boolean;
	var tw,dummy: integer;

	begin
		wind_get(DESK,WF_TOP,tw,dummy,dummy,dummy);
		IsTop:=((tw=Attr.gemHandle) and (Application^.DlgTop<0))
	end;


procedure TWindow.EnableAutoCreate;

	begin
		Class.Style:=Class.Style or cs_AutoCreate
	end;


procedure TWindow.DisableAutoCreate;

	begin
		Class.Style:=Class.Style and not(cs_AutoCreate)
	end;


procedure TWindow.GetFull;
	var r    : GRECT;
	    mx,my: integer;

	begin
		if Attr.gemHandle<0 then exit;
		wind_get(Attr.gemHandle,WF_FULLXYWH,Full.X,Full.Y,Full.W,Full.H);
		GRtoA2(Full);
		Calc(WC_WORK,Full,r);
		GetWorkMax(mx,my);
		if (r.W>mx) or (r.H>my) then
			begin
				if r.W>mx then r.W:=mx;
				if r.H>my then r.H:=my;
				Calc(WC_BORDER,r,Full);
				Full.X:=Curr.X;
				Full.Y:=Curr.Y;
				if Full.X+Full.W-1>SysInfo.Desktop.X2 then
					begin
						Full.X:=SysInfo.Desktop.X2+1-Full.W;
						if Full.X<SysInfo.Desktop.X then Full.X:=SysInfo.Desktop.X
					end;
				if Full.Y+Full.H-1>SysInfo.Desktop.Y2 then
					begin
						Full.Y:=SysInfo.Desktop.Y2+1-Full.H;
						if Full.Y<SysInfo.Desktop.Y then Full.Y:=SysInfo.Desktop.Y
					end;
				GRtoA2(Full)
			end;
		ChkAlign(Full)
	end;


procedure TWindow.GetCurr;

	begin
		if Attr.gemHandle>=0 then
			begin
				wind_get(Attr.gemHandle,WF_CURRXYWH,Curr.X,Curr.Y,Curr.W,Curr.H);
				GRtoA2(Curr)
			end
	end;


procedure TWindow.GetRealCurr(var r: GRECT);

	begin
		GetCurr;
		if IsIconified then r:=icfcurr
		else
			r:=Curr
	end;


procedure TWindow.GetWork;

	begin
		if Attr.gemHandle>=0 then
			begin
				wind_get(Attr.gemHandle,WF_WORKXYWH,Work.X,Work.Y,Work.W,Work.H);
				if not(IsIconified) then
					begin
						if Class.ToolbarTree<>nil then
							with Class.ToolbarTree^[ROOT] do
								begin
									if ob_width>ob_height then
										begin
											if not(bTst(Class.Style,cs_ToolbarOpposite)) then inc(Work.Y,ob_height-1);
											dec(Work.H,ob_height-1)
										end
									else
										begin
											if not(bTst(Class.Style,cs_ToolbarOpposite)) then inc(Work.X,ob_width-1);
											dec(Work.W,ob_width-1)
										end
								end;
						if Class.MenuTree<>nil then
							with Class.MenuTree^[Class.MenuTree^[ROOT].ob_head] do
								begin
									inc(Work.Y,ob_height+1);
									dec(Work.H,ob_height+1)
								end
					end;
				GRtoA2(Work)
			end
	end;


procedure TWindow.GetVWork(var r: GRECT);

	begin
		r.X1:=Work.X1+Attr.VWork.X1;
		r.Y1:=Work.Y1+Attr.VWork.Y1;
		r.X2:=Work.X2-Attr.VWork.X2;
		r.Y2:=Work.Y2-Attr.VWork.Y2;
		A2toGR(r)
	end;


procedure TWindow.SetCurr(r: GRECT);

	begin
		WMSized(r.X,r.Y,r.W,r.H)
	end;


procedure TWindow.SetWork(r: GRECT);
	var ro: GRECT;

	begin
		Calc(WC_BORDER,r,ro);
		WMSized(ro.X,ro.Y,ro.W,ro.H)
	end;


procedure TWindow.LoadIcon(Icn: PIcon);

	begin
		if (Icon=nil) and (Icn<>nil) then
			begin
				Icon:=Icn;
				Icon^.Hide(false);
				if IsIconified then Icon^.Unhide
			end
	end;


procedure TWindow.FreeIcon;

	begin
		if Icon<>nil then
			begin
				if IsIconified then Icon^.Hide(true);
				Icon^.Free;
				Icon:=nil
			end
	end;


procedure TWindow.LoadMenu(Indx: integer; Tune: boolean);
	var tp : PTree;
	    q,l: integer;

	procedure nextentry(const e,s: string; disable: boolean);

		begin
			with Class do	
				begin
					q:=MenuTree^[q].ob_next;
					with MenuTree^[q] do
						begin
							ob_spec.free_string:=ChrNew('  '+e+StrPSpace(l-3-length(s)-length(e))+s+' ');
							if disable then ob_state:=ob_state or DISABLED
						end
				end
		end;

	begin
		tp:=Application^.GetAddr(Indx);
		if (Class.MenuTree=nil) and (tp<>nil) then
			begin
				if Application^.MenuCorrect(tp,mnsize) then
					begin
						getmem(Class.MenuTree,mnsize*sizeof(AESOBJECT));
						if Class.MenuTree=nil then
							begin
								Application^.Err:=em_InvalidMenu;
								exit
							end;
						for q:=0 to mnsize-1 do Class.MenuTree^[q]:=tp^[q];
						tunemenu:=Tune;
						with Class.MenuTree^[ROOT] do
							begin
								if tunemenu then
									begin
										q:=Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[ob_tail].ob_head].ob_head].ob_next;
										l:=StrLen(Class.MenuTree^[q].ob_spec.free_string);
						  			if Application^.Attr.Country=FRA then
						  				begin
												nextentry('Cycle','^W',false);
												nextentry('Maximiser','^*',not(bTst(Attr.Style,FULLER)));
												nextentry('Iconifier','^3',(icfserver=nil));
												nextentry('Recouvrir','^/',not(agi.Backdrop))
						  				end
						  			else if (Application^.Attr.Country=FRG) or (Application^.Attr.Country=SWG) then
						  				begin
												nextentry('Wechseln','^W',false);
												nextentry('Volle Grîûe','^*',not(bTst(Attr.Style,FULLER)));
												nextentry('Ikonifizieren','^3',(icfserver=nil));
												nextentry('Hintergrund','^/',not(agi.Backdrop))
											end
										else
											begin
												nextentry('Cycle','^W',false);
												nextentry('Maximize','^*',not(bTst(Attr.Style,FULLER)));
												nextentry('Iconify','^3',(icfserver=nil));
												nextentry('Backdrop','^/',not(agi.Backdrop))
											end;
										Class.MenuTree^[Class.MenuTree^[ob_tail].ob_head].ob_tail:=q;
										Class.MenuTree^[q].ob_next:=Class.MenuTree^[ob_tail].ob_head;
										with Class.MenuTree^[Class.MenuTree^[ob_tail].ob_head] do ob_height:=(ob_height shr 3)*6
									end;
								with Class.MenuTree^[Class.MenuTree^[ob_head].ob_head] do ob_width:=Application^.Attr.MaxPX+1;
								with Class.MenuTree^[ob_tail] do
									begin
										ob_x:=0;
										ob_y:=0
									end
							end;
						GetWork;
						if Attr.Status=ws_Open then ForceRedraw
					end
				else
					Application^.Err:=em_InvalidMenu
			end
		else
			Application^.Err:=em_InvalidMenu
	end;


procedure TWindow.FreeMenu;
	var q,i: integer;

	procedure freenext;

		begin
			q:=Class.MenuTree^[q].ob_next;
			ChrDispose(PChar(Class.MenuTree^[q].ob_spec.free_string))
		end;

	begin
		if Class.MenuTree<>nil then
			begin
				if tunemenu then
					begin
						q:=Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[ROOT].ob_tail].ob_head].ob_head].ob_next;
						for i:=0 to 3 do freenext
					end;
				freemem(Class.MenuTree,mnsize*sizeof(AESOBJECT));
				Class.MenuTree:=nil
			end;
		GetWork;
		if Attr.Status=ws_Open then ForceRedraw
	end;


procedure TWindow.LoadToolbar(Indx: integer);
	var tp,ntp      : PTree;
	    tbc,q,tbsize: integer;

	begin
		for q:=0 to MAXTOOLBARS do
			if tbval[q].Indx=Indx then
				begin
					Application^.Err:=em_InvalidToolbar;
					exit
				end;
		tp:=Application^.GetAddr(Indx);
		if (tbval[MAXTOOLBARS].Indx<0) and (tp<>nil) then
			begin
				tbsize:=ROOT;
				while not(bTst(tp^[tbsize].ob_flags,LASTOB)) do inc(tbsize);
				inc(tbsize);
				getmem(ntp,tbsize*sizeof(AESOBJECT));
				if ntp=nil then Application^.Err:=em_InvalidToolbar
				else
					begin
						for q:=0 to tbsize-1 do ntp^[q]:=tp^[q];
						tbc:=0;
						while tbval[tbc].Indx>=0 do inc(tbc);
						tbval[tbc].Size:=tbsize;
						tbval[tbc].Indx:=Indx;
						tbval[tbc].Tree:=ntp;
						with ntp^[ROOT] do
							begin
								if (ob_type and $ff) in [G_BOX,G_IBOX,G_BOXCHAR] then ob_spec.index:=(ob_spec.index and $ff00ffff) or $00010000;
								if bTst(Application^.Attr.Style,as_3DFlags) then ob_flags:=ob_flags or FL3DBAK
								else
									ob_flags:=ob_flags and not(FL3DBAK);
								if ob_height>ob_width then ob_height:=Application^.Attr.MaxPY
								else
									ob_width:=Application^.Attr.MaxPX
							end;
						if tbc=0 then
							begin
								Class.ToolbarTree:=ntp;
								tbtree:=Indx;
								GetWork;
								if Attr.Status=ws_Open then Application^.InvalidateRect(Attr.Handle,nil)
							end
					end
			end
		else
			Application^.Err:=em_InvalidToolbar
	end;


procedure TWindow.SwitchToolbar(Indx: integer);
	var i,q: integer;
	    old: TToolbarDescr;

	begin
		if (Indx=tbtree) or (Indx<0) then exit;
		i:=-1;
		for q:=0 to MAXTOOLBARS do
			if tbval[q].Indx=Indx then
				begin
					i:=q;
					break
				end;
		if i<0 then exit;
		old:=tbval[i];
		for q:=i downto 1 do tbval[q]:=tbval[q-1];
		tbval[0]:=old;
		tbtree:=tbval[0].Indx;
		Class.ToolbarTree:=tbval[0].Tree;
		GetWork;
		if Attr.Status=ws_Open then Application^.InvalidateRect(Attr.Handle,nil)
	end;


procedure TWindow.FreeToolbar(Indx: integer);
	var i,q: integer;

	begin
		if Indx<0 then exit;
		i:=-1;
		for q:=0 to MAXTOOLBARS do
			if tbval[q].Indx=Indx then
				begin
					i:=q;
					break
				end;
		if i<0 then exit;
		with tbval[i] do
			if tree<>nil then
				if size>0 then freemem(tree,size*sizeof(AESOBJECT));
		if i<MAXTOOLBARS then
			for q:=i to MAXTOOLBARS-1 do tbval[q]:=tbval[q+1];
		with tbval[MAXTOOLBARS] do
			begin
				Size:=0;
				Indx:=-1;
				Tree:=nil
			end;
		if i=0 then
			begin
				tbtree:=tbval[0].Indx;
				Class.ToolbarTree:=tbval[0].Tree;
				GetWork;
				if Attr.Status=ws_Open then Application^.InvalidateRect(Attr.Handle,nil)
			end
	end;


procedure TWindow.SetToolbarPos(Opposite: boolean);

	begin
		if Opposite then Class.Style:=Class.Style or cs_ToolbarOpposite or cs_FullRedraw
		else
			Class.Style:=Class.Style and not(cs_ToolbarOpposite);
		if tbtree>=0 then
			begin
				GetWork;
				if Attr.Status=ws_Open then Application^.InvalidateRect(Attr.Handle,nil)
			end
	end;


procedure TWindow.LoadDialog(Indx: integer);
	var tp: PTree;

	begin
		tp:=Application^.GetAddr(Indx);
		if (DlgTree=nil) and (tp<>nil) then
			begin
				SetDlgTree(tp);
				if Attr.Status=ws_Open then ForceRedraw
			end
		else
			Application^.Err:=em_InvalidDialog
	end;


procedure TWindow.FreeDialog;

	begin
		SetDlgTree(nil);
		if Attr.Status=ws_Open then ForceRedraw
	end;


procedure TWindow.SetDlgTree(tree: PTree);

	begin
		DlgTree:=tree
	end;


procedure TWindow.UpdateDialog;
	var x,y,w,h: integer;

	begin
		if not(IsIconified) then
			if IsModeless then
				begin
					wind_get(Attr.gemHandle,WF_WORKXYWH,x,y,w,h);
					if Class.MenuTree<>nil then
						with Class.MenuTree^[Class.MenuTree^[ROOT].ob_head] do
							begin
								ob_x:=x-1;
								ob_y:=y;
								inc(y,ob_height+1);
								dec(h,ob_height+1)
							end;
					if Class.ToolbarTree<>nil then
						with Class.ToolbarTree^[ROOT] do
							if bTst(Class.Style,cs_ToolbarOpposite) then
								begin
									if ob_width>ob_height then
										begin
											ob_x:=x-1;
											ob_y:=y+h+1-ob_height
										end
									else
										begin
											ob_x:=x+w+1-ob_width;
											ob_y:=y-1
										end
								end
							else
								begin
									ob_x:=x-1;
									ob_y:=y-1
								end
				end;
		if DlgTree<>nil then
			with DlgTree^[ROOT] do
				begin
					if bTst(ob_state,OUTLINED) then
						begin
							ob_x:=Work.X+outlwidth;
							ob_y:=Work.Y+outlwidth
						end
					else
						begin
							ob_x:=Work.X;
							ob_y:=Work.Y
						end
				end
	end;


procedure TWindow.SetupSize;

	begin
		Full:=SysInfo.Desktop;
		Curr:=Full;
		Calc(WC_WORK,Curr,Work)
	end;


procedure TWindow.SetupWindow;

	begin
		SetupSize;
		if AppFlag then
			if bTst(Class.Style,cs_AutoOpen) then MakeWindow
	end;


procedure TWindow.ShutdownWindow;

	begin
	end;


procedure TWindow.MakeWindow;

	begin
		Create;
		OpenWindow
	end;


procedure TWindow.Create;

	begin
		if Attr.Status=ws_NoWindow then
			begin
		  	if Parent<>nil then
  				if Parent^.IsDialog then
  					if PDialog(Parent)^.IsModal then exit;
				Attr.gemHandle:=wind_create(Attr.Style,Full.X,Full.Y,Full.W,Full.H);
				if Attr.gemHandle<0 then Application^.Err:=em_InvalidWindow
				else
					begin
						Attr.Status:=ws_Created;
						if bTst(Attr.Style,NAME) then
							wind_set(Attr.gemHandle,WF_NAME,integer(HiWord(@Attr.Title^[1])),integer(LoWord(@Attr.Title^[1])),0,0);
						if bTst(Attr.Style,INFO) then
							wind_set(Attr.gemHandle,WF_INFO,integer(HiWord(@Attr.SubTitle^[1])),integer(LoWord(@Attr.SubTitle^[1])),0,0);
						if agi.BEvent then
							begin
								if bTst(Class.Style,cs_WorkBackground) then
									wind_set(Attr.gemHandle,WF_BEVENT,1,0,0,0)
								else
									wind_set(Attr.gemHandle,WF_BEVENT,0,0,0,0)
							end;
						CreateChildren
					end
			end
		else
			CreateChildren
	end;


procedure TWindow.CreateChildren;
	var p: PWindow;

	begin
		p:=ChildList;
		while (p<>nil) do
			with p^ do
				begin
					if bTst(Class.Style,cs_AutoCreate) then Create;
					p:=Nxt
				end
	end;


procedure TWindow.OpenWindow;
	var p   : PWindow;
	    pipe: Pipearray;

	begin
		if Attr.Status=ws_Created then
			begin
				wind_update(BEG_UPDATE);
				ChkAlign(Curr);
				ChkSize(Curr);
				if bTst(Application^.Attr.Style,as_GrowShrink) then form_box(FMD_GROW,Curr);
				if wind_open(Attr.gemHandle,Curr.X,Curr.Y,Curr.W,Curr.H)=0 then Application^.Err:=em_WOpenFailure
				else
					begin
						Attr.Status:=ws_Open;
						GetWork;
						if Scroller<>nil then
							with Scroller^ do
								begin
									SetPageSize;
									SetSBarRange
								end;
						if bTst(Attr.ExStyle,ws_ex_Disabled) and agi.Backdrop then
							wind_set(Attr.gemHandle,WF_BOTTOM,0,0,0,0)
						else
							EnableCrsWatch;
						if bTst(Class.Style,cs_OLGADocument) then
							if Application^.OLGAManager>=0 then
								begin
									pipe[0]:=OLGA_OPENDOC;
									pipe[1]:=Application^.apID;
									pipe[2]:=0;
									pipe[3]:=0;
									pipe[4]:=0;
									pipe[5]:=GetOLGAGroup;
									pipe[6]:=0;
									pipe[7]:=0;
									appl_write(Application^.OLGAManager,16,@pipe)
								end;
						Application^.CheckMenuEntries;
						p:=ChildList;
						while (p<>nil) do
							with p^ do
								begin
									OpenWindow;
									p:=Nxt
								end
					end;
				wind_update(END_UPDATE)
			end
		else
			if Attr.Status=ws_Open then
				begin
					if IsDialog then if PDialog(@self)^.IsModal then exit;
					if not(bTst(Attr.ExStyle,ws_ex_Disabled)) then Top;
					p:=ChildList;
					while (p<>nil) do
						with p^ do
							begin
								OpenWindow;
								p:=Nxt
							end
				end
	end;


procedure TWindow.CloseWindow;
	var p         : PWindow;
			ICFFreePos: procedure(d1,d2: pointer; d3,d4,d5: longint; fn,posnr: integer);
			pipe      : Pipearray;
			q         : integer;

	begin
		p:=ChildList;
		while (p<>nil) do
			with p^ do
				begin
					CloseWindow;
					p:=Nxt
				end;
		for q:=0 to XSELMAX do
			if xselwind[q].window=@self then
				begin
					xselwind[q].window:=nil;
					pipe[0]:=WIN_CLOSED;
					pipe[1]:=Application^.apID;
					pipe[2]:=0;
					pipe[3]:=xselwind[q].fdmwhnd;
					appl_write(freedom,16,@pipe)
				end;
		if Attr.Status=ws_Open then
			begin
				wind_update(BEG_UPDATE);
				GetCurr;
				if bTst(Application^.Attr.Style,as_GrowShrink) then form_box(FMD_SHRINK,Curr);
				if wind_close(Attr.gemHandle)<>0 then
					begin
						Attr.Status:=ws_Created;
						if bTst(Class.Style,cs_OLGADocument) then
							if Application^.OLGAManager>=0 then
								if not(Application^.Terminating) then
									begin
										pipe[0]:=OLGA_CLOSEDOC;
										pipe[1]:=Application^.apID;
										pipe[2]:=0;
										pipe[3]:=0;
										pipe[4]:=0;
										pipe[5]:=GetOLGAGroup;
										pipe[6]:=0;
										pipe[7]:=0;
										appl_write(Application^.OLGAManager,16,@pipe)
									end
					end
				else
					Application^.Err:=em_WCloseFailure;
				if icfpos>=0 then
					begin
						Curr:=icfcurr;
						SetGadgets(icfstyle);
						ICFFreePos:=icfserver;
						ICFFreePos(nil,nil,0,0,0,ICF_FREEPOS,icfpos);
						icfpos:=-1
					end;
				DisableCrsWatch;
				Application^.CheckMenuEntries;
				wind_update(END_UPDATE)
			end
	end;


procedure TWindow.Destroy;
	var p: PWindow;

	begin
		p:=ChildList;
		while (p<>nil) do
			with p^ do
				begin
					Destroy;
					p:=Nxt
				end;
		if Attr.Status in [ws_Created,ws_Open] then
			begin
				CloseWindow;
				if Attr.Status=ws_Created then
					begin
						if wind_delete(Attr.gemHandle)<>0 then
							with Attr do
								begin
									Status:=ws_NoWindow;
									gemHandle:=-1
								end
						else
							Application^.Err:=em_WDestroyFailure
					end
			end
	end;


procedure TWindow.RawDestroy;
	var p: PWindow;
			ICFFreePos: procedure(d1,d2: pointer; d3,d4,d5: longint; fn,posnr: integer);
			q: integer;

	begin
		p:=ChildList;
		while (p<>nil) do
			with p^ do
				begin
					RawDestroy;
					p:=Nxt
				end;
		for q:=0 to XSELMAX do if xselwind[q].window=@self then xselwind[q].window:=nil;
		with Attr do
			begin
				DisableCrsWatch;
				Status:=ws_NoWindow;
				gemHandle:=-1
			end;
		if icfpos>=0 then
			begin
				Curr:=icfcurr;
				Attr.Style:=icfstyle;
				ICFFreePos:=icfserver;
				ICFFreePos(nil,nil,0,0,0,ICF_FREEPOS,icfpos);
				icfpos:=-1
			end
	end;


procedure TWindow.Top;

	begin
		if Attr.Status=ws_Open then
			begin
				wind_update(BEG_UPDATE);
				wind_set(Attr.gemHandle,WF_TOP,0,0,0,0);
				EnableCrsWatch;
				Application^.CheckMenuEntries;
				wind_update(END_UPDATE)
			end
	end;


procedure TWindow.FullSize;
	var r: GRECT;

	begin
		if Attr.Status=ws_Open then
			if IsModeless then
				begin
					wind_update(BEG_UPDATE);
					GetFull;
					wind_get(Attr.gemHandle,WF_CURRXYWH,r.X,r.Y,r.W,r.H);
					if (Full.X=r.X) and (Full.Y=r.Y) and (Full.W=r.W) and (Full.H=r.H) then
						begin
							if bTst(Application^.Attr.Style,as_GrowShrink) then
								form_dial(FMD_SHRINK,Curr.X,Curr.Y,Curr.W,Curr.H,Full.X,Full.Y,Full.W,Full.H);
							r:=Curr
						end
					else
						begin
							if bTst(Application^.Attr.Style,as_GrowShrink) then
								form_dial(FMD_GROW,Curr.X,Curr.Y,Curr.W,Curr.H,Full.X,Full.Y,Full.W,Full.H);
							r:=Full
						end;
					wind_set(Attr.gemHandle,WF_CURRXYWH,r.X,r.Y,r.W,r.H);
					GetWork;
					UpdateDialog;
					if bTst(Class.Style,cs_FullRedraw) then ForceRedraw;
					wind_update(END_UPDATE)
				end
	end;


procedure TWindow.Size(r: GRECT);

	begin
		if Attr.Status=ws_Open then
			begin
				wind_update(BEG_UPDATE);
				Curr:=r;
				wind_set(Attr.gemHandle,WF_CURRXYWH,r.X,r.Y,r.W,r.H);
				GetWork;
				UpdateDialog;
				if bTst(Class.Style,cs_FullRedraw) then ForceRedraw;
				wind_update(END_UPDATE)
			end
		else
			Curr:=r
	end;


procedure TWindow.Move(r: GRECT);
	var chg: boolean;

	begin
		if Attr.Status=ws_Open then
			begin
				wind_update(BEG_UPDATE);
				chg:=((Curr.W<>r.W) or (Curr.H<>r.H));
				Curr:=r;
				wind_set(Attr.gemHandle,WF_CURRXYWH,r.X,r.Y,r.W,r.H);
				GetWork;
				UpdateDialog;
				if bTst(Class.Style,cs_FullRedraw) and chg then ForceRedraw;
				wind_update(END_UPDATE)
			end
		else
			Curr:=r
	end;


procedure TWindow.InitPaint;

	begin
	end;


procedure TWindow.Paint(var PaintInfo: TPaintStruct);

	begin
		if DlgTree<>nil then
			with PaintInfo.rcPaint do objc_draw(DlgTree,ROOT,MAX_DEPTH,X,Y,W,H)
	end;


procedure TWindow.IconPaint(var PaintInfo: TPaintStruct);

	begin
	end;


procedure TWindow.ExitPaint;

	begin
	end;


procedure TWindow.ForceRedraw;
	var pipe: Pipearray;
	    r   : GRECT;

	begin
		if Attr.Status=ws_Open then
			if IsModeless then
				begin
					wind_update(BEG_UPDATE);
					GetWork;
					if bTst(Class.Style,cs_ToolbarOpposite) then
						wind_get(Attr.gemHandle,WF_WORKXYWH,r.X,r.Y,r.W,r.H)
					else
						r:=Work;
					pipe[0]:=WM_REDRAW;
					pipe[1]:=Application^.apID;
					pipe[2]:=0;
					pipe[3]:=Attr.gemHandle;
					pipe[4]:=r.X;
					pipe[5]:=r.Y;
					pipe[6]:=r.W;
					pipe[7]:=r.H;
					appl_write(pipe[1],16,@pipe);
					wind_update(END_UPDATE)
				end
	end;


procedure TWindow.ForceVRedraw;
	var r   : GRECT;
	    pipe: Pipearray;

	begin
		if Attr.Status=ws_Open then
			if IsModeless then
				begin
					wind_update(BEG_UPDATE);
					GetVWork(r);
					pipe[0]:=WM_REDRAW;
					pipe[1]:=Application^.apID;
					pipe[2]:=0;
					pipe[3]:=Attr.gemHandle;
					pipe[4]:=r.X;
					pipe[5]:=r.Y;
					pipe[6]:=r.W;
					pipe[7]:=r.H;
					appl_write(pipe[1],16,@pipe);
					wind_update(END_UPDATE)
				end
	end;


procedure TWindow.SetTitle(ATitle: string);

	begin
		DisposeStr(Attr.Title);
		ATitle:=StrPLeft(StrPTrimF(ATitle),78);
		if length(Atitle)>0 then ATitle:=' '+ATitle+' ';
		ATitle:=ATitle+#0;
		Attr.Title:=NewStr(ATitle);
	  if (Attr.Status in [ws_Created,ws_Open]) then
	  	if not(IsIconified) then
		  	if bTst(Attr.Style,NAME) then
					wind_set(Attr.gemHandle,WF_NAME,integer(HiWord(@Attr.Title^[1])),integer(LoWord(@Attr.Title^[1])),0,0)
	end;


procedure TWindow.SetSubTitle(AnInfo: string);

	begin
		DisposeStr(Attr.SubTitle);
		AnInfo:=StrPLeft(AnInfo,80)+#0;
		if length(AnInfo)=1 then AnInfo:=' '+AnInfo;
		Attr.SubTitle:=NewStr(AnInfo);
	  if (Attr.Status in [ws_Created,ws_Open]) then
	  	if bTst(Attr.Style,INFO) then
				wind_set(Attr.gemHandle,WF_INFO,integer(HiWord(@Attr.SubTitle^[1])),integer(LoWord(@Attr.SubTitle^[1])),0,0)
	end;


procedure TWindow.SetGadgetsSize(Style: integer; r: GRECT);
	label _error,_open;

	var wasopen: boolean;

	begin
		if Attr.Status=ws_NoWindow then exit;
		if Style<>Attr.Style then
			begin
				wind_update(BEG_UPDATE);
				DisableCrsWatch;
				wasopen:=(Attr.Status=ws_Open);
				if wasopen then
					begin
						GetCurr;
						if wind_close(Attr.gemHandle)=0 then goto _error
					end;
				Attr.Status:=ws_Created;
				if wind_delete(Attr.gemHandle)=0 then goto _open;
				Attr.Style:=Style;
				Attr.gemHandle:=wind_create(Attr.Style,Full.X,Full.Y,Full.W,Full.H);
				if Attr.gemHandle<0 then
					begin
						Attr.Status:=ws_NoWindow;
						Application^.Err:=em_InvalidWindow;
						goto _error
					end;
				if bTst(Attr.Style,NAME) then
					wind_set(Attr.gemHandle,WF_NAME,integer(HiWord(@Attr.Title^[1])),integer(LoWord(@Attr.Title^[1])),0,0);
				if bTst(Attr.Style,INFO) then
					wind_set(Attr.gemHandle,WF_INFO,integer(HiWord(@Attr.SubTitle^[1])),integer(LoWord(@Attr.SubTitle^[1])),0,0);
				if agi.BEvent then
					begin
						if bTst(Class.Style,cs_WorkBackground) then
							wind_set(Attr.gemHandle,WF_BEVENT,1,0,0,0)
						else
							wind_set(Attr.gemHandle,WF_BEVENT,0,0,0,0)
					end;
				_open:
				WMSized(r.X,r.Y,r.W,r.H);
				if wasopen then
					begin
						if wind_open(Attr.gemHandle,Curr.X,Curr.Y,Curr.W,Curr.H)<>0 then
							begin
								Attr.Status:=ws_Open;
								GetWork;
								if Scroller<>nil then
									with Scroller^ do
										begin
											SetPageSize;
											SetSBarRange
										end;
								if bTst(Attr.ExStyle,ws_ex_Disabled) and agi.Backdrop then
									wind_set(Attr.gemHandle,WF_BOTTOM,0,0,0,0)
								else
									EnableCrsWatch
							end
						else
							Application^.Err:=em_WOpenFailure
					end;
				_error:
				wind_update(END_UPDATE)
			end
	end;


procedure TWindow.SetGadgets(Style: integer);

	begin
		SetGadgetsSize(Style,Curr)
	end;


procedure TWindow.SetCursor(Crs: HCursor);
	var cr       : GRECT;
	    x,y,dummy: integer;

	begin
		if IsIconified then
			begin
				Class.hCursor:=Crs;
				exit
			end;
		wind_update(BEG_UPDATE);
		Class.hCursor:=Crs;
		if Application^.pcrswatch=@self then
			if Crs>id_No then
				if not(IsMouseBusy) then
					begin
						graf_mkstate(x,y,dummy,dummy);
						Application^.GetCrsRect(cr);
						if Between(x,cr.X1,cr.X2) and Between(y,cr.Y1,cr.Y2) then
							begin
								if Crs>$7fff then SetMouse(USER_DEF,pointer(Crs))
								else
									SetMouse(Crs,nil)
							end
					end;
		wind_update(END_UPDATE)
	end;


procedure TWindow.Calc(ctype: integer; ri: GRECT; var ro: GRECT);

	begin
		if ctype=WC_BORDER then
			if not(IsIconified) then
				begin
					if Class.MenuTree<>nil then
						inc(ri.H,Class.MenuTree^[Class.MenuTree^[ROOT].ob_head].ob_height+1);
					if Class.ToolbarTree<>nil then
						with Class.ToolbarTree^[ROOT] do
							begin
								if ob_width>ob_height then
									begin
										if not(bTst(Class.Style,cs_ToolbarOpposite)) then dec(ri.Y,ob_height-1);
										inc(ri.H,ob_height-1)
									end
								else
									begin
										if not(bTst(Class.Style,cs_ToolbarOpposite)) then dec(ri.X,ob_width-1);
										inc(ri.W,ob_width-1)
									end
							end
				end;
		wind_calc(ctype,Attr.Style,ri.X,ri.Y,ri.W,ri.H,ro.X,ro.Y,ro.W,ro.H);
		if ctype=WC_WORK then
			if not(IsIconified) then
				begin
					if Class.MenuTree<>nil then
						dec(ro.H,Class.MenuTree^[Class.MenuTree^[ROOT].ob_head].ob_height+1);
					if Class.ToolbarTree<>nil then
						with Class.ToolbarTree^[ROOT] do
							begin
								if ob_width>ob_height then
									begin
										if not(bTst(Class.Style,cs_ToolbarOpposite)) then inc(ro.Y,ob_height-1);
										dec(ro.H,ob_height-1)
									end
								else
									begin
										if not(bTst(Class.Style,cs_ToolbarOpposite)) then inc(ro.X,ob_width-1);
										dec(ro.W,ob_width-1)
									end
							end
				end;
		GRtoA2(ro)
	end;


procedure TWindow.ChkAlign(var r: GRECT);
	label _fertig;

	var ro: GRECT;

	procedure ChkMax(var r: GRECT);

		begin
			if r.X+r.W-1>SysInfo.Desktop.X2 then r.W:=SysInfo.Desktop.X2+1-r.X;
			if r.Y+r.H-1>SysInfo.Desktop.Y2 then r.H:=SysInfo.Desktop.Y2+1-r.Y;
			GRtoA2(r)
		end;

	begin
		if r.Y<SysInfo.Desktop.Y then r.Y:=SysInfo.Desktop.Y;
		if IsIconified then goto _fertig;
		if bTst(Class.Style,cs_ByteAlignClient) then
			begin
				Calc(WC_WORK,r,ro);
				ro.X:=(ro.X shr 3) shl 3;
				Calc(WC_BORDER,ro,r);
				if r.X<SysInfo.Desktop.X then
					begin
						inc(r.X,8);
						ChkMax(r)
					end
			end
		else
			if bTst(Class.Style,cs_ByteAlignWindow) then
				begin
					r.X:=(r.X shr 3) shl 3;
					if r.X<SysInfo.Desktop.X then
						begin
							inc(r.X,8);
							ChkMax(r)
						end
				end;
		if bTst(Class.Style,cs_VerAlignClient) then
			begin
				Calc(WC_WORK,r,ro);
				ro.Y:=(ro.Y shr 1) shl 1;
				Calc(WC_BORDER,ro,r);
				if r.Y<SysInfo.Desktop.Y then
					begin
						while r.Y<SysInfo.Desktop.Y do inc(r.Y,2);
						ChkMax(r)
					end
			end
		else
			if bTst(Class.Style,cs_VerAlignWindow) then
				begin
					r.Y:=(r.Y shr 1) shl 1;
					if r.Y<SysInfo.Desktop.Y then
						begin
							while r.Y<SysInfo.Desktop.Y do inc(r.Y,2);
							ChkMax(r)
						end
				end;
		_fertig:
		GRtoA2(r)
 	end;


procedure TWindow.ChkSize(var r: GRECT);
	var ro             : GRECT;
	    mix,miy,mxx,mxy: integer;

	begin
		Calc(WC_WORK,r,ro);
		if IsIconified then
			begin
				mix:=21;
				miy:=1;
				mxx:=maxint;
				mxy:=maxint
			end
		else
			begin
				GetWorkMin(mix,miy);
				GetWorkMax(mxx,mxy)
			end;
		if (ro.W>mxx) or (ro.H>mxy) then
			begin
				if ro.W>mxx then ro.W:=mxx;
				if ro.H>mxy then ro.H:=mxy;
				Calc(WC_BORDER,ro,r)
			end;
		if (ro.W<mix) or (ro.H<miy) then
			begin
				if ro.W<mix then ro.W:=mix;
				if ro.H<miy then ro.H:=miy;
				Calc(WC_BORDER,ro,r)
			end;
		GRtoA2(r)
	end;


procedure TWindow.GetWorkMin(var minX,minY: integer);
	var r,ro: GRECT;

	begin
		minX:=21;
		minY:=1;
		if Attr.gemHandle>=0 then
			if Application^.MagiCActive then
				if wind_get(Attr.gemHandle,WF_MINXYWH,r.X,r.Y,r.W,r.H)<>0 then
					begin
						Calc(WC_WORK,r,ro);
						minX:=max(minX,ro.W);
						minY:=max(minY,ro.H)
					end
	end;


procedure TWindow.GetWorkMax(var maxX,maxY: integer);

	begin
		maxX:=maxint;
		maxY:=maxint
	end;


function TWindow.GetDC: integer;
	var box: GRECT;

	begin
		GetDC:=-1;
		wind_update(BEG_UPDATE);
		if FirstWorkRect(box) then
			begin
				HideMouse;
				vs_clip(vdiHandle,CLIP_ON,box.A2);
				GetDC:=vdiHandle
			end
		else
			wind_update(END_UPDATE)
	end;


procedure TWindow.ReleaseDC;

	begin
		vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2);
		ShowMouse;
		wind_update(END_UPDATE)
	end;


procedure TWindow.MNSelected(meNum,mtNum: integer; Tree: PTree; PrIndx: integer);
	var found: boolean;
	    p    : PEvent;

	begin
		found:=false;
		p:=EventList;
		while (p<>nil) and not(found) do
			with p^ do
				begin
					found:=TestMenu(meNum);
					p:=Nxt
				end;
		if not(found) then HandleMenu(meNum)
	end;


procedure TWindow.HandleMenu(meNum: integer);

	begin
		if meNum=Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[ROOT].ob_tail].ob_head].ob_head then
			if tunemenu then
				with Application^ do
					if MenuTree<>nil then
						MNSelected(MenuTree^[MenuTree^[MenuTree^[ROOT].ob_tail].ob_head].ob_head,MenuTree^[MenuTree^[MenuTree^[ROOT].ob_head].ob_head].ob_head,nil,0)
	end;


procedure TWindow.WMRedraw(X,Y,W,H: integer);
	var box,area   : GRECT;
	    PaintInfo  : TPaintStruct;
	    icn,visible,
	    fx3d       : boolean;
	    pe         : PEvent;
	    pxy        : ARRAY_4;

	begin
		if Attr.Status<>ws_Open then exit;
		if Attr.gemHandle<0 then exit;
		area.X:=X;
		area.Y:=Y;
		area.W:=W;
		area.H:=H;
		HideMouse;
		icn:=IsIconified;
		UpdateDialog;
		if Class.MenuTree<>nil then
			if not(icn) then
				begin
					wind_get(Attr.gemHandle,WF_WORKXYWH,box.X,box.Y,box.W,box.H);
					pxya[0]:=box.X;
					pxya[1]:=box.Y+Class.MenuTree^[Class.MenuTree^[ROOT].ob_head].ob_height;
					pxya[2]:=box.X+box.W;
					pxya[3]:=pxya[1];
					wind_get(Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
					while (box.W>0) and (box.H>0) do
						begin
							if rc_intersect(SysInfo.Desktop,box) then
								if rc_intersect(area,box) then
									with box do
										begin
											objc_draw(Class.MenuTree,Class.MenuTree^[ROOT].ob_head,MAX_DEPTH,X,Y,W,H);
											vs_clip(Application^.vdiHandle,CLIP_ON,A2);
											v_pline(Application^.vdiHandle,2,pxya)
										end;
							wind_get(Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
						end
				end;
		if Class.ToolbarTree<>nil then
			if not(icn) then
				begin
					fx3d:=(Application^.Attr.Colors>=LBlack) and bTst(Application^.Attr.Style,as_3DFlags);
					with Class.ToolbarTree^[ROOT] do
						if ob_width>ob_height then
							begin
								pxya[0]:=ob_x;
								pxya[1]:=ob_y+1;
								pxya[2]:=ob_x+ob_width;
								pxya[3]:=pxya[1];
								pxy[0]:=pxya[0];
								pxy[1]:=ob_y+ob_height-2;
								pxy[2]:=pxya[2];
								pxy[3]:=pxy[1]
							end
						else
							begin
								pxya[0]:=ob_x+1;
								pxya[1]:=ob_y+1;
								pxya[2]:=pxya[0];
								pxya[3]:=ob_y+ob_height-1;
								pxy[0]:=ob_x+ob_width-2;
								pxy[1]:=pxya[1];
								pxy[2]:=pxy[0];
								pxy[3]:=pxya[3]
							end;
					wind_get(Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
					while (box.W>0) and (box.H>0) do
						begin
							if rc_intersect(SysInfo.Desktop,box) then
								if rc_intersect(area,box) then
									with box do
										begin
											objc_draw(Class.ToolbarTree,ROOT,MAX_DEPTH,X,Y,W,H);
											if fx3d then
												begin
													vs_clip(Application^.vdiHandle,CLIP_ON,A2);
													vsl_color(Application^.vdiHandle,White);
													v_pline(Application^.vdiHandle,2,pxya);
													vsl_color(Application^.vdiHandle,LBlack);
													v_pline(Application^.vdiHandle,2,pxy)
												end
										end;
							wind_get(Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
						end;
					vsl_color(Application^.vdiHandle,Black)
				end;
		visible:=FirstWorkRect(box);
		InitPaint;
		while visible do
			begin
				if rc_intersect(area,box) then
					begin
						vs_clip(Application^.vdiHandle,CLIP_ON,box.A2);
						vs_clip(vdiHandle,CLIP_ON,box.A2);
						with PaintInfo do
							begin
								rcPaint:=box;
								if icn then feColor:=IconClass.hbrBackground
								else
									feColor:=Class.hbrBackground;
								dec(feColor);
								if feColor>=0 then
									begin
										fErase:=true;
										vsf_interior(Application^.vdiHandle,FIS_SOLID);
										vsf_color(Application^.vdiHandle,feColor);
										vr_recfl(Application^.vdiHandle,rcPaint.A2);
										vsf_interior(Application^.vdiHandle,FIS_HOLLOW);
										vsf_color(Application^.vdiHandle,Black)
									end
								else
									fErase:=false
							end;
						if icn then IconPaint(PaintInfo)
						else
							Paint(PaintInfo)
					end;
				visible:=NextWorkRect(box)
			end;
		ExitPaint;
		if not(icn) then
			begin
				pe:=EventList;
				while pe<>nil do
					begin
						if bTst(pe^.Style,es_Icon) then PIcon(pe)^.Paint;
						pe:=pe^.Next
					end
			end
		else
			if Icon<>nil then
				begin
					Icon^.SetPos((Work.W-Icon^.VObj.ob_width) shr 1,(Work.H-Icon^.VObj.ob_height) shr 1,false);
					Icon^.Unhide;
					Icon^.Hide(false)
				end;
		vs_clip(Application^.vdiHandle,CLIP_ON,SysInfo.Desktop.A2);
		vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2);
		ShowMouse
	end;


procedure TWindow.WMTopped;

	begin
		Top
	end;


procedure TWindow.WMClosed;

	begin
		if CanClose then
			begin
				Application^.ChkError;
				Destroy;
				if bTst(Class.Style,cs_QuitOnClose) then
					begin
						with Application^ do if ChkError>=em_OutOfMemory then Quit
					end
				else
					if bTst(Class.Style,cs_FreeOnClose) then Free
			end
	end;


procedure TWindow.WMFulled;

	begin
		FullSize;
		if Scroller<>nil then
			with Scroller^ do
				begin
					SetPageSize;
					SetSBarRange
				end
	end;


procedure TWindow.WMArrowed(waA,SpeedA,waB,SpeedB: integer);
	var scrollx,scrolly: longint;

	begin
		if Scroller=nil then exit;
		scrollx:=0;
		scrolly:=0;
		case waA of
			WA_UPPAGE: scrolly:=-SpeedA*Scroller^.YPage;
			WA_DNPAGE: scrolly:=SpeedA*Scroller^.YPage;
			WA_UPLINE: scrolly:=-SpeedA*Scroller^.YLine;
			WA_DNLINE: scrolly:=SpeedA*Scroller^.YLine;
			WA_LFPAGE: scrollx:=-SpeedA*Scroller^.XPage;
			WA_RTPAGE: scrollx:=SpeedA*Scroller^.XPage;
			WA_LFLINE: scrollx:=-SpeedA*Scroller^.XLine;
			WA_RTLINE: scrollx:=SpeedA*Scroller^.XLine
		end;
		if waB>0 then
			case waB of
				WA_UPPAGE: dec(scrolly,SpeedB*Scroller^.YPage);
				WA_DNPAGE: inc(scrolly,SpeedB*Scroller^.YPage);
				WA_UPLINE: dec(scrolly,SpeedB*Scroller^.YLine);
				WA_DNLINE: inc(scrolly,SpeedB*Scroller^.YLine);
				WA_LFPAGE: dec(scrollx,SpeedB*Scroller^.XPage);
				WA_RTPAGE: inc(scrollx,SpeedB*Scroller^.XPage);
				WA_LFLINE: dec(scrollx,SpeedB*Scroller^.XLine);
				WA_RTLINE: inc(scrollx,SpeedB*Scroller^.XLine)
			end;
		Scroller^.ScrollBy(scrollx,scrolly)
	end;


procedure TWindow.WMHSlid(Value: integer);
	var dif: longint;

	begin
		if Scroller<>nil then
			with Scroller^ do
				begin
					dif:=XRange-XPage-1;
					if dif<1 then dif:=1;
					ScrollTo(round(longint(Value*dif)/1000),YPos)
				end
	end;


procedure TWindow.WMVSlid(Value: integer);
	var dif: longint;

	begin
		if Scroller<>nil then
			with Scroller^ do
				begin
					dif:=YRange-YPage-1;
					if dif<1 then dif:=1;
					ScrollTo(XPos,round(longint(Value*dif)/1000))
				end
	end;


procedure TWindow.WMSized(X,Y,W,H: integer);
	var r: GRECT;

	begin
		r.X:=X;
		r.Y:=Y;
		r.W:=W;
		r.H:=H;
		ChkAlign(r);
		ChkSize(r);
		Size(r);
		if Scroller<>nil then
			if not(IsIconified) then
				with Scroller^ do
					begin
						SetPageSize;
						SetSBarRange
					end
	end;


procedure TWindow.WMMoved(X,Y,W,H: integer);
	var r      : GRECT;
			ICFSnap: procedure(d1,d2: pointer; d3,d4,d5: longint; fn,posnr: integer; px,py: PInteger);

	begin
		r.X:=X;
		r.Y:=Y;
		r.W:=W;
		r.H:=H;
		ChkAlign(r);
		ChkSize(r);
		if icfpos>=0 then
			begin
				ICFSnap:=icfserver;
				ICFSnap(nil,nil,0,0,0,ICF_SNAP,icfpos,@r.X,@r.Y)
			end;
		Move(r);
		if Scroller<>nil then
			if not(IsIconified) then
				with Scroller^ do
					begin
						SetPageSize;
						SetSBarRange
					end
	end;


function TWindow.DoRubbox(mX,mY,KStat: integer): boolean;

	begin
		DoRubbox:=true
	end;


procedure TWindow.WMButton(mX,mY,BStat,KStat,Clicks: integer);
	var r    : GRECT;
	    valid: boolean;

	begin
		if BStat=1 then
			begin
				if Clicks=1 then
					begin
						valid:=true;
						if bTst(Class.Style,cs_Rubbox) then
							begin
								GetVWork(r);
								if (r.W>0) and (r.H>0) then
									if rc_intersect(Work,r) then
										if (mX>=r.X1) and (mX<=r.X2) and (mY>=r.Y1) and (mY<=r.Y2) then
											if DoRubbox(mX,mY,KStat) then
												begin
													valid:=false;
													if (KStat and K_SHIFT)>0 then Application^.IconSelect(false,Attr.gemHandle)
													else
														Application^.IconSelect(false,id_No);
													if Application^.Rubbox(Attr.gemHandle,mX,mY,r.X1,r.Y1,r.X2,r.Y2,true,r) then
														begin
															if (r.W=1) and (r.H=1) then valid:=true
															else
																WMRubbox(r)
														end
												end
							end;
						if valid then WMClick(mX,mY,KStat)
					end
				else
					if Clicks=2 then
						if bTst(Class.Style,cs_DblClks) then WMDblClick(mX,mY,KStat)
			end
		else
			if BStat=2 then
				begin
					if Clicks=2 then Top
					else
						WMRButton(mX,mY,KStat,Clicks)
				end
	end;


procedure TWindow.WMClick(mX,mY,KStat: integer);

	begin
		if (KStat and K_SHIFT)>0 then Application^.IconSelect(false,Attr.gemHandle)
		else
			Application^.IconSelect(false,id_No)
	end;


procedure TWindow.WMDblClick(mX,mY,KStat: integer);

	begin
		if (KStat and K_SHIFT)>0 then Application^.IconSelect(false,Attr.gemHandle)
		else
			Application^.IconSelect(false,id_No)
	end;


procedure TWindow.WMRButton(mX,mY,KStat,Clicks: integer);

	begin
	end;


procedure TWindow.WMRubbox(r: GRECT);

	begin
	end;


procedure TWindow.WMRBoxChanged(r: GRECT);

	begin
	end;


procedure TWindow.WMRBoxCheck(x,y,xmin,ymin,xmax,ymax: integer; var mx,my: integer);

	begin
	end;


procedure TWindow.WMNewTop;

	begin
		WMUntopped
	end;


procedure TWindow.WMUntopped;

	begin
		Application^.CheckMenuEntries;
		DisableCrsWatch
	end;


procedure TWindow.WMOnTop;

	begin
		Application^.CheckMenuEntries;
		EnableCrsWatch
	end;


procedure TWindow.WMBottomed;

	begin
		if (Attr.Status=ws_Open) and agi.Backdrop then
			begin
				wind_set(Attr.gemHandle,WF_BOTTOM,0,0,0,0);
				Application^.CheckMenuEntries;
				DisableCrsWatch
			end
	end;


procedure TWindow.WMToolbar(Indx,BStat,KStat,Clicks: integer);
	label _fertig;

	var p             : PEvent;
	    pe            : PToolbar;
	    oadr          : PObj;
	    pipe          : Pipearray;
	    dummy,bx,by,bs: integer;
	    brect,mrect   : GRECT;
	    onbtn,inrect  : boolean;

	procedure CheckAndDraw(CheckFlag: integer);
		var box,obox: GRECT;

		begin
			with oadr^ do
				if CheckFlag=bf_Unchecked then ob_state:=ob_state and not(SELECTED)
				else
					ob_state:=ob_state or SELECTED;
			wind_update(BEG_UPDATE);
			objc_offset(Class.ToolbarTree,Indx,obox.X,obox.Y);
			obox.W:=oadr^.ob_width;
			obox.H:=oadr^.ob_height;
			HideMouse;
			wind_get(Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
			while (box.W>0) and (box.H>0) do
				begin
					if rc_intersect(SysInfo.Desktop,box) then
						if rc_intersect(obox,box) then
							with obox do objc_draw(Class.ToolbarTree,ROOT,MAX_DEPTH,X,Y,W,H);
					wind_get(Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
				end;
			ShowMouse;
			wind_update(END_UPDATE)
		end;

	begin
		if Class.ToolbarTree=nil then exit;
		if Attr.Status<>ws_Open then exit;
		if Attr.gemHandle<0 then exit;
		if IsIconified then exit;
		pipe[0]:=GO_PRIVATE;
		pipe[1]:=Application^.apID;
		pipe[2]:=0;
		pipe[3]:=GOP_TOOLBAR;
		pipe[4]:=tbtree;
		pipe[5]:=Indx;
		pipe[6]:=KStat;
		pipe[7]:=Clicks;
		pe:=nil;
		p:=EventList;
		while p<>nil do
			if p^.TestMessage(pipe) then
				begin
					pe:=PToolbar(p);
					break
				end
			else
				p:=p^.Next;
		if BStat=2 then
			begin
				if pe<>nil then
					if pe^.IsHelpAvailable then
						begin
							graf_mkstate(bx,by,dummy,dummy);
							Application^.BubbleHelp(bx,by,pe^.GetHelp,false,false)
						end;
				exit
			end;
		if pe=nil then
			begin
				oadr:=@Class.ToolbarTree^[Indx];
				if oadr=nil then exit;
				if not(bTst(oadr^.ob_flags,SELECTABLE)) or bTst(oadr^.ob_state,DISABLED) then exit
			end
		else
			begin
				if pe^.GetState=bf_Disabled then exit;
				if pe^.IsToolbarInstalled then oadr:=pe^.ObjAddr
				else
					exit
			end;
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		onbtn:=true;
		if pe<>nil then
			if pe^.IsSwitch then
				begin
					pe^.Toggle;
					repeat
						graf_mkstate(dummy,dummy,bs,dummy)
					until bs=0;
					goto _fertig
				end;
		if pe<>nil then pe^.Check
		else
			CheckAndDraw(bf_Checked);
		objc_offset(Class.ToolbarTree,Indx,bx,by);
		with brect do
			begin
				X:=bx;
				Y:=by;
				W:=oadr^.ob_width;
				H:=oadr^.ob_height
			end;
		repeat
			graf_mkstate(bx,by,bs,dummy);
			inrect:=false;
			with mrect do wind_get(Attr.gemHandle,WF_FIRSTXYWH,X,Y,W,H);
			while (mrect.W>0) and (mrect.H>0) do
				begin
					if rc_intersect(SysInfo.Desktop,mrect) then
						if rc_intersect(brect,mrect) then
							with mrect do
								if (bx>=X1) and (by>=Y1) and (bx<=X2) and (by<=Y2) then
									begin
										inrect:=true;
										break
									end;
					with mrect do wind_get(Attr.gemHandle,WF_NEXTXYWH,X,Y,W,H)
				end;
			if inrect<>onbtn then
				begin
					if pe<>nil then pe^.Toggle
					else
						if inrect then CheckAndDraw(bf_Checked)
						else
							CheckAndDraw(bf_Unchecked);
					onbtn:=inrect
				end;
		until bs=0;
		_fertig:
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
		if onbtn then
			begin
				if pe<>nil then
					with pe^ do
						begin
							Work;
							if VPipe<>nil then
								begin
									if VGHnd then VPipe^[3]:=Attr.gemHandle;
									appl_write(Application^.apID,16,VPipe)
								end
						end;
				if hi(oadr^.ob_type)>ROOT then
					begin
						if bTst(Class.Style,cs_WindowMenuToolbar) then MNSelected(hi(oadr^.ob_type),0,nil,0)
						else
							Application^.MNSelected(hi(oadr^.ob_type),0,nil,0)
					end;
				if pe=nil then CheckAndDraw(bf_Unchecked)
				else
					if not(pe^.IsSwitch) then pe^.Uncheck
			end
	end;


function TWindow.WMKeyDown(Stat,Key: integer): boolean;

	begin
		WMKeyDown:=false
	end;


procedure TWindow.WMDragDrop(PipeHnd,OrgID,mX,mY,KStat: integer);
	label _readhdr,_prefext;

	var answer           : string;
	    hdrlen,i         : integer;
	    dtype            : string[4];
	    dsize            : longint;
	    dname,ndata,nfile: string[DD_NAMEMAX];

	begin
		answer:=chr(DD_OK);
		if fwrite(PipeHnd,1,@answer[1])<>1 then exit;
		_prefext:
		answer:=StrPLeft(DDGetPreferredTypes,DD_EXTSIZE);
		while length(answer)<DD_EXTSIZE do answer:=answer+#0;
		if fwrite(PipeHnd,DD_EXTSIZE,@answer[1])<>DD_EXTSIZE then exit;
		_readhdr:
		if fread(PipeHnd,2,@hdrlen)<>2 then exit;
		if hdrlen<9 then exit;
		dtype:='    ';
		if fread(PipeHnd,4,@dtype[1])<>4 then exit;
		if fread(PipeHnd,4,@dsize)<>4 then exit;
		dec(hdrlen,8);
		if hdrlen>DD_NAMEMAX then i:=DD_NAMEMAX
		else
			i:=hdrlen;
		fillchar(dname,sizeof(dname),0);
		if fread(PipeHnd,i,@dname[1])<>i then exit;
		dec(hdrlen,i);
		ndata:='';
		nfile:='';
		i:=1;
		while dname[i]<>#0 do
			begin
				ndata:=ndata+dname[i];
				inc(i)
			end;
		inc(i);
		while dname[i]<>#0 do
			begin
				nfile:=nfile+dname[i];
				inc(i)
			end;
		while hdrlen>DD_NAMEMAX+1 do
			begin
				if fread(PipeHnd,DD_NAMEMAX+1,@dname)<>DD_NAMEMAX+1 then exit;
				dec(hdrlen,DD_NAMEMAX+1)
			end;
		if hdrlen>0 then
			if fread(PipeHnd,hdrlen,@dname)<>hdrlen then exit;
		if dtype='PATH' then
			begin
				answer:=DDGetPath;
				if length(answer)=0 then answer:=chr(DD_NAK)
				else
					answer:=StrPLeft(chr(DD_OK)+answer,dsize);
				fwrite(PipeHnd,length(answer),@answer[1]);
				exit
			end;
		if dtype='ARGS' then
			begin
				answer:=chr(DD_OK);
				if fwrite(PipeHnd,1,@answer[1])<>1 then exit;
				if dsize>0 then
					if DDReadArgs(dsize,PipeHnd,OrgID,mX,mY,KStat) then Application^.ddokflag:=true;
				exit
			end;
		answer:=chr(DDHeaderReply(dtype,ndata,nfile,dsize,OrgID,mX,mY,KStat));
		if fwrite(PipeHnd,1,@answer[1])<>1 then exit;
		case ord(answer[1]) of
			DD_OK:  if DDReadData(dtype,ndata,nfile,dsize,PipeHnd,OrgID,mX,mY,KStat) then Application^.ddokflag:=true;
			DD_EXT: goto _readhdr;
			DD_LEN: goto _prefext
		end
	end;


procedure TWindow.WMIconify(iX,iY,iW,iH: integer);
	var valid: boolean;
	    r    : GRECT;

	begin
		if Attr.Status<>ws_Open then exit;
		wind_update(BEG_UPDATE);
		GetCurr;
		icfcurr:=Curr;
		form_dial(FMD_SHRINK,iX,iY,iW,iH,Curr.X,Curr.Y,Curr.W,Curr.H);
		if icfpos>=0 then
			begin
				icfstyle:=Attr.Style;
				with r do
					begin
						X:=iX;
						Y:=iY;
						W:=iW;
						H:=iH
					end;
				SetGadgetsSize(NAME+MOVER,r)
			end
		else
			begin
				if Application^.pcrswatch=@self then
					begin
						DisableCrsWatch;
						valid:=true
					end
				else
					valid:=false;
				if (iX<0) or (iY<0) or (iW<1) or (iH<1) then
					begin
						wind_close(Attr.gemHandle);
						wind_set(Attr.gemHandle,WF_ICONIFY,-1,-1,-1,-1);
						wind_open(Attr.gemHandle,-1,-1,-1,-1)
					end
				else
					wind_set(Attr.gemHandle,WF_ICONIFY,iX,iY,iW,iH);
				if valid then EnableCrsWatch
			end;
		DisposeStr(icntitl);
		if icfpos>=0 then icntitl:=NewStr(StrPLeft(StrPTrimF(GetIconTitle),8)+#0)
		else
			icntitl:=NewStr(StrPLeft(StrPTrimF(GetIconTitle),10)+#0);
  	if bTst(Attr.Style,NAME) then
			wind_set(Attr.gemHandle,WF_NAME,integer(HiWord(@icntitl^[1])),integer(LoWord(@icntitl^[1])),0,0);
		GetCurr;
		GetWork;
		wind_update(END_UPDATE)
	end;


procedure TWindow.WMUniconify(oX,oY,oW,oH: integer);
	var ICFFreePos: procedure(d1,d2: pointer; d3,d4,d5: longint; fn,posnr: integer);
	    valid     : boolean;
	    dummy,ms  : integer;
	    r         : GRECT;

	begin
		if Attr.Status<>ws_Open then exit;
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		if icfpos>=0 then
			begin
				form_dial(FMD_GROW,Curr.X,Curr.Y,Curr.W,Curr.H,oX,oY,oW,oH);
				ICFFreePos:=icfserver;
				ICFFreePos(nil,nil,0,0,0,ICF_FREEPOS,icfpos);
				icfpos:=-1;
				with r do
					begin
						X:=oX;
						Y:=oY;
						W:=oW;
						H:=oH
					end;
				SetGadgetsSize(icfstyle,r)
			end
		else
			begin
				if (oW<1) or (oH<1) then
					with icfcurr do
						begin
							oX:=X;
							oY:=Y;
							oW:=W;
							oH:=H
						end;
				form_dial(FMD_GROW,Curr.X,Curr.Y,Curr.W,Curr.H,oX,oY,oW,oH);
				if Application^.pcrswatch=@self then
					begin
						DisableCrsWatch;
						valid:=true
					end
				else
					valid:=false;
				wind_set(Attr.gemHandle,WF_UNICONIFY,oX,oY,oW,oH);
				if valid then EnableCrsWatch
			end;
  	if bTst(Attr.Style,NAME) then
			wind_set(Attr.gemHandle,WF_NAME,integer(HiWord(@Attr.Title^[1])),integer(LoWord(@Attr.Title^[1])),0,0);
		DisposeStr(icntitl);
		GetCurr;
		GetWork;
		repeat
			graf_mkstate(dummy,dummy,ms,dummy)
		until not(bTst(ms,1));
		wind_update(END_MCTRL);
		wind_update(END_UPDATE)
	end;


procedure TWindow.WMShaded;

	begin
	end;


procedure TWindow.WMUnshaded;

	begin
	end;


procedure TWindow.OLGAUpdated(OrgID,SrvID,InfoNr: integer; Link: string);

	begin
	end;


procedure TWindow.OLGARenameLink(OrgID: integer; OldLink,NewLink: string);

	begin
	end;


procedure TWindow.OLGALinkBroken(OrgID: integer; Link: string);

	begin
	end;


function TWindow.DDGetPreferredTypes: string;

	begin
		DDGetPreferredTypes:=Application^.DDGetPreferredTypes(Attr.gemHandle)
	end;


function TWindow.DDGetPath: string;

	begin
		DDGetPath:=''
	end;


function TWindow.DDHeaderReply(dType,dName,fName: string; dSize: longint; OrgID,mX,mY,KStat: integer): byte;

	begin
		DDHeaderReply:=DD_NAK
	end;


function TWindow.DDReadData(dType,dName,fName: string; dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean;

	begin
		DDReadData:=false
	end;


function TWindow.DDReadArgs(dSize: longint; PipeHnd,OrgID,mX,mY,KStat: integer): boolean;
	var buffer: array [0..127] of byte;

	begin
		DDReadArgs:=false;
		if dSize<=0 then exit;
		while dSize>128 do
			begin
				if fread(PipeHnd,128,@buffer)<>128 then exit;
				dec(dSize,128)
			end;
		fread(PipeHnd,dSize,@buffer)
	end;


procedure TWindow.DDFinished(OrgID,mX,mY,KStat: integer);

	begin
	end;


function TWindow.FontChanged(OrgID,AnID,ASize,AColor,BackColor,Effects,ARotation,ASkew,HorAlign,VertAlign,AWidth,TrackKern: integer; Size31: fix31; PairKern,cWnd: boolean): boolean;
	var p: PWindow;

	begin
		FontChanged:=false;
		if cWnd then
			begin
		  	p:=ChildList;
		  	while p<>nil do
	  			begin
						if p^.FontChanged(OrgId,AnID,ASize,AColor,BackColor,Effects,ARotation,ASkew,HorAlign,VertAlign,AWidth,TrackKern,Size31,PairKern,true) then FontChanged:=true;
  					p:=p^.Nxt
	  			end
			end
	end;


procedure TWindow.ColorID(OrgID,mX,mY,palIndex: integer);

	begin
	end;


procedure TWindow.Cut;

	begin
		Application^.Cut
	end;


procedure TWindow.Copy;

	begin
		Application^.Copy
	end;


procedure TWindow.Paste;

	begin
		Application^.Paste
	end;


procedure TWindow.Delete;

	begin
		Application^.Delete
	end;


procedure TWindow.SelectAll;

	begin
		IconSelect(true,id_No)
	end;


procedure TWindow.Print;

	begin
	end;


function TWindow.IsHelpAvailable(mX,mY: integer): boolean;

	begin
		IsHelpAvailable:=(length(StrPTrimF(GetHelp(mX,mY)))>0)
	end;


function TWindow.GetHelp(mX,mY: integer): string;
	var pipe: Pipearray;
	    indx: integer;
	    pe  : PEvent;

	begin
		GetHelp:='';
		if IsIconified then exit;
		if Class.ToolbarTree<>nil then
			begin
				indx:=objc_find(Class.ToolbarTree,ROOT,MAX_DEPTH,mX,mY);
				if indx>=0 then
					begin
						pipe[0]:=GO_PRIVATE;
						pipe[1]:=Application^.apID;
						pipe[2]:=0;
						pipe[3]:=GOP_TOOLBAR;
						pipe[4]:=tbtree;
						pipe[5]:=indx;
						pipe[6]:=K_NORMAL;
						pipe[7]:=1;
						pe:=EventList;
						while pe<>nil do
							begin
								if pe^.TestMessage(pipe) then
									begin
										if PToolbar(pe)^.IsHelpAvailable then GetHelp:=PToolbar(pe)^.GetHelp;
										exit
									end;
								pe:=pe^.Next
							end
					end
			end
	end;


function TWindow.Previous: PWindow;

	begin
		Previous:=Prev
	end;


function TWindow.Next: PWindow;

	begin
		Next:=Nxt
	end;


function TWindow.At(Index: integer): PWindow;
	var len: integer;
	    p  : PWindow;

	begin
		len:=0;
		p:=ChildList;
		while p<>nil do
			begin
				inc(len);
				p:=p^.Nxt
			end;
		At:=nil;
		if (Index<0) or (len=0) then exit;
		Index:=Index mod len;
		p:=ChildList;
		if Index>0 then
			for len:=0 to Index-1 do p:=p^.Nxt;
		At:=p
	end;


function TWindow.IndexOf(Item: PWindow): integer;
	var count: integer;
	    p    : PWindow;

	begin
		IndexOf:=-1;
		count:=0;
		p:=ChildList;
		while p<>nil do
			begin
				if p=Item then
					begin
						IndexOf:=count;
						exit
					end;
				inc(count);
				p:=p^.Nxt
			end
	end;


function TWindow.FirstWndThat(Test: PIterationFunc): PWindow;
	var p,pc: PWindow;
	    cl  : IterationFunc;

	begin
		FirstWndThat:=nil;
		p:=ChildList;
		cl:=IterationFunc(Test);
		while p<>nil do
			begin
				if cl(p) then
					begin
						FirstWndThat:=p;
						exit
					end;
				pc:=p^.FirstWndThat(Test);
				if pc<>nil then
					begin
						FirstWndThat:=pc;
						exit
					end;
				p:=p^.Nxt
			end;
	end;


procedure TWindow.ForEachWnd(Action: PIterationProc);
	var p : PWindow;
	    cl: IterationProc;

	begin
		p:=ChildList;
		cl:=IterationProc(Action);
		while p<>nil do
			begin
				cl(p);
				p^.ForEachWnd(Action);
				p:=p^.Nxt
			end
	end;


procedure TWindow.IconSelect(OnOff: boolean; OffExc: integer);
	var pe: PEvent;
	    pw: PWindow;

	begin
		pe:=EventList;
		if OnOff then
			while pe<>nil do
				begin
					if bTst(pe^.Style,es_Icon) then PIcon(pe)^.Check;
					pe:=pe^.Next
				end
		else
			begin
				if Attr.gemHandle<>OffExc then
					while pe<>nil do
						begin
							if bTst(pe^.Style,es_Icon) then PIcon(pe)^.Uncheck;
							pe:=pe^.Next
						end;
				pw:=ChildList;
				while pw<>nil do
					begin
						pw^.IconSelect(false,OffExc);
						pw:=pw^.Next
					end
			end
	end;


function TWindow.FirstIcon(OnAll: boolean): PIcon;

	begin
		icnonall:=OnAll;
		nxticn:=EventList;
		FirstIcon:=NextIcon
	end;


function TWindow.NextIcon: PIcon;
	label _weiter;

	begin
		NextIcon:=nil;
		while nxticn<>nil do
			begin
				if bTst(nxticn^.Style,es_Icon) then
					begin
						if icnonall then
							if PIcon(nxticn)^.GetCheck<>bf_Checked then goto _weiter;
						NextIcon:=PIcon(nxticn);
						nxticn:=nxticn^.Next;
						exit
					end;
				_weiter:
				nxticn:=nxticn^.Next
			end
	end;


function TWindow.FirstWorkRect(var Rect: GRECT): boolean;

	begin
		if IsModeless then
			if Attr.Status=ws_Open then
				begin
					GetWork;
					with Rect do wind_get(Attr.gemHandle,WF_FIRSTXYWH,X,Y,W,H);
					while (Rect.W>0) and (Rect.H>0) do
						begin
							if rc_intersect(SysInfo.Desktop,Rect) then
								if rc_intersect(Work,Rect) then
									begin
										FirstWorkRect:=true;
										exit
									end;
							with Rect do wind_get(Attr.gemHandle,WF_NEXTXYWH,X,Y,W,H)
						end
				end;
		FirstWorkRect:=false;
		Rect.W:=0
	end;


function TWindow.NextWorkRect(var Rect: GRECT): boolean;

	begin
		if IsModeless then
			if Attr.Status=ws_Open then
				begin
					with Rect do wind_get(Attr.gemHandle,WF_NEXTXYWH,X,Y,W,H);
					while (Rect.W>0) and (Rect.H>0) do
						begin
							if rc_intersect(SysInfo.Desktop,Rect) then
								if rc_intersect(Work,Rect) then
									begin
										NextWorkRect:=true;
										exit
									end;
							with Rect do wind_get(Attr.gemHandle,WF_NEXTXYWH,X,Y,W,H)
						end
				end;
		NextWorkRect:=false;
		Rect.W:=0
	end;


	{ private }


procedure TWindow.EnableCrsWatch;
	var cursor: HCursor;

	begin
		if Application^.pcrswatch<>@self then
			begin
				if Application^.pcrswatch<>nil then
					with Application^ do
						begin
							pcrswatch:=nil;
							Attr.EventMask:=Attr.EventMask and not(MU_M1 or MU_M2);
							if not(IsMouseBusy) then SetMouse(wmnr,@wmform)
						end;
				if IsIconified then cursor:=IconClass.hCursor
				else
					cursor:=Class.hCursor;
				if cursor>id_No then
					begin
						Application^.pcrswatch:=@self;
						Application^.Attr.EventMask:=Application^.Attr.EventMask or MU_M1
					end
			end
	end;


procedure TWindow.DisableCrsWatch;
	var p: PWindow;

	begin
		if Application^.pcrswatch=@self then
			begin
				with Application^ do
					begin
						pcrswatch:=nil;
						Attr.EventMask:=Attr.EventMask and not(MU_M1 or MU_M2);
						if not(IsMouseBusy) then SetMouse(wmnr,@wmform);
						p:=GetPTopWindow
					end;
				if (p<>nil) and (p<>@self) then p^.EnableCrsWatch
			end
	end;


procedure TWindow.Iconify(fade: boolean);

	begin
		if fade then
			begin
				icnx:=Curr.X;
				WMMoved(SysInfo.Desktop.X+SysInfo.Desktop.W+20,Curr.Y,Curr.W,Curr.H)
			end
		else
			WMMoved(icnx,Curr.Y,Curr.W,Curr.H)
	end;


function TWindow.CycleTop(start: PWindow; backwrd: boolean): boolean;
	var p: PWindow;

	begin
		if IsModeless and (Attr.Status=ws_Open) and (start<>@self) then
			begin
				Top;
				CycleTop:=true;
				exit
			end;
		CycleTop:=false;
		p:=ChildList;
		if backwrd then
			begin
				while p<>nil do
					begin
						if p^.Next=nil then break;
						p:=p^.Next
					end;
				while p<>nil do
					begin
						if p^.CycleTop(start,true) then
							begin
								CycleTop:=true;
								exit
							end;
						p:=p^.Previous
					end
			end
		else
			while p<>nil do
				begin
					if p^.CycleTop(start,false) then
						begin
							CycleTop:=true;
							exit
						end;
					p:=p^.Next
				end
	end;

{ *** TWINDOW *** }



{ *** Objekt TAPPLICATION *** }

constructor TApplication.Init(AName: string);
  var gval   : longint;
  		dummy,
  		fontid,
  		extrsc : integer;
  		rgb    : ARRAY_3;
  		atrb   : ARRAY_10;
  		ffnd,
  		scmd   : string;
  		pipe   : Pipearray;
  		meta   : METAINFO;
  		xdsc   : boolean;
  		eochr  : string[2];
  		dst    : PChar;
  		fontset: AESOBJECT;
  		fontted: TEDINFO;

	function objc_xsysvar(what,ver: integer): integer;
		var objsvar  : boolean;
		    dummy,osv: integer;

		begin
			objc_xsysvar:=White;
			if not(bTst(Attr.Style,as_3DFlags)) then exit;
			if appl_xgetinfo(13,dummy,osv,dummy,dummy) then objsvar:=(osv>0)
			else
				objsvar:=(GEMVersion>=$0340);
			if objsvar then
				begin
					with AES_pb do
						begin
							control^[0]:=48;
							control^[1]:=4;
							control^[2]:=3;
							control^[3]:=0;
							control^[4]:=0;
							intin^[0]:=0;
							intin^[1]:=what;
							intin^[2]:=0;
							intin^[3]:=0
						end;
					_crystal(@AES_pb);
					if AES_pb.intout^[0]>0 then objc_xsysvar:=AES_pb.intout^[1]
					else
						if Attr.Colors>=LWhite then objc_xsysvar:=LWhite
				end
			else
				if (TOSVersion>=ver) and (Attr.Colors>=LWhite) then objc_xsysvar:=LWhite
		end;

	procedure getpoint(height,width,fid: integer; var pt: integer);
		var dummy,w,h,asked,got: integer;

		begin
			pt:=-1;
			vst_font(vdiHandle,fid);
			asked:=99;
			got:=asked;
			while got<=asked do
				begin
					asked:=got-1;
					got:=vst_point(vdiHandle,asked,dummy,h,w,dummy);
					if h=height then
						if w=width then
							begin
								pt:=got;
								exit
							end
				end
		end;

  begin
    if not(inherited Init) then fail;
    termflag:=false;
    Terminating:=false;
    appdone:=true;
    Application:=@self;
    if AppFlag then Fsetdta(@apDTA);
    apName:=nil;
    apPath:=nil;
    pquit:=nil;
    xaccname:=nil;
    XAccList:=nil;
    icnwnd:=nil;
    allicn:=false;
    nxticn:=nil;
    startcmd:=nil;
    Name:=NewStr(AName);
    Status:=em_OK;
    Err:=em_OK;
    cliplock:=false;
    MainWindow:=nil;
    RscPtr:=nil;
    nappgen:=nil;
    MenuTree:=nil;
    MessageBuffer:=nil;
    MessageBLen:=0;
    pcrswatch:=nil;
    icfserver:=nil;
    menuentries:=nil;
    Clipboard:=nil;
    Icon:=nil;
    menuID:=-1;
    apID:=-1;
    vdiHandle:=-1;
    aesHandle:=-1;
    AVServer:=id_No;
    OLGAManager:=id_No;
    xfont[1]:=-1;
    HMax:=-1;
    ticn:=-1;
    spderr:=0;
    deskinst:=false;
    GDOSActive:=false;
    BubbleHelpActive:=true;
    MultiTOS:=false;
    IsQSBUsed:=false;
    DlgTop:=-1;
		MiNTActive:=(MiNTVersion>0);
		MagiCActive:=(MagiCVersion>=$0200);
		NAESActive:=GetCookie('nAES',gval);
		MemoryProtection:=MiNTActive or MagiCActive;
		with Attr do
			begin
				if GetCookie('_AKP',gval) then Country:=gval and $ff
				else
					Country:=PWord(longint(GetOSHeaderPtr)+28)^ shr 1;
				rpCmd:=nil;
				rpTail:=nil;
				PopChar:=#2
			end;
		FPUAvailable:=(Test68881<>0);
		if not(FPUAvailable) then
			if GetCookie('_FPU',gval) then
				FPUAvailable:=((gval and $ffff)<>0) or ((gval and $ffff0000)>$00010000);
		OSBAvailable:=GetCookie('EdDI',gval);
		if GetCookie('FSMC',gval) then SpeedoActive:=(PLongint(gval)^=1599295556)
		else
			SpeedoActive:=false;
		if not(GetCookie('BHLP',gval)) then NewCookie('BHLP',$01f4ffff);
		if GetCookie('LTMF',gval) then ltmf:=PLTMFLY(gval)
		else
			ltmf:=nil;
		stewart:=0;
		GetCookie('STEW',stewart);
		fillchar(meta,sizeof(meta),0);
		metainit(meta);
		if meta.version=nil then MetaDOS:=nil
		else
			begin
				new(MetaDOS);
				MetaDOS^.Drives:=meta.drivemap;
				MetaDOS^.Version:=StrPas(meta.version)
			end;
		GlobalAlloc(pointer(bubblebuf),256);
		pdomain(1);
    InitGem;
    if Status>=em_OK then
    	begin
    		wind_update(BEG_UPDATE);
    		GetDesk(SysInfo.Desktop);
    		scmd:='';
	      with Attr do
  	    	begin
    	  		MaxPX:=workOut[0];
      			MaxPY:=workOut[1];
      			PixW:=workOut[3];
      			PixH:=workOut[4];
      			hwratio:=round(PixH/PixW);
      			Colors:=workOut[13];
      			MaxColors:=workOut[39];
      			sysFonts:=workOut[10];
      			addFonts:=0;
      			Planes:=GEM_pb.global[10];
						EventMask:=MU_MESAG or MU_KEYBD or MU_BUTTON or MU_TIMER;
						if MultiTOS then poptimer:=300
						else
							poptimer:=1;
  	    		Style:=as_GrowShrink or as_MenuSeparator or as_MoveDials or as_HandleShutdown or as_3DFlags or as_UseHomeDir;
  	    		if not(AppFlag) then Style:=Style or as_DesktopWindow;
						extmagxmenu:=(MagiCVersion>=$0514) and (Colors>=LBlack);
						if rpCmd<>nil then
							begin
								scmd:=StrPRight(rpCmd^,length(rpCmd^)-RPos('\',rpCmd^));
								if pos('.',scmd)>0 then scmd:=StrPLeft(scmd,pos('.',scmd)-1);
								scmd:=StrPLeft(scmd,8);
								apPath:=NewStr(StrPLeft(rpCmd^,RPos('\',rpCmd^)))
							end
					end;
				if SpeedoActive then vst_error(vdiHandle,0,spderr);
				apName:=NewStr(scmd+StrPSpace(8-length(scmd))+#0);
				GDOSActive:=(vq_gdos<>0);
				spderr:=0;
				if GDOSActive then Attr.addFonts:=vst_load_fonts(vdiHandle,0);
				if spderr<>0 then Err:=em_SpeedoLoadFailure;
				has_agi:=(GEMVersion>=$0400);
				if not(has_agi) then has_agi:=(appl_find('?AGI')=0);
				if not(has_agi) then has_agi:=MagiCActive;
				if not(has_agi) then has_agi:=(wind_get(0,WF_WINX,dummy,dummy,dummy,dummy)=WF_WINX);
				if not(GetCookie('AFnt',longint(paf))) then paf:=nil;
  		  with fontset do
  		  	begin
  		  		ob_next:=0;
  		  		ob_head:=-1;
  		  		ob_tail:=-1;
  		  		ob_type:=G_TEXT;
  		  		ob_flags:=LASTOB;
  		  		ob_state:=NORMAL;
  		  		ob_spec.ted_info:=@fontted;
  		  		ob_x:=0;
  		  		ob_y:=0;
  		  		ob_width:=Attr.charSWidth;
  		  		ob_height:=Attr.charSHeight
  		  	end;
  		  eochr:=' '#0;
  		  with fontted do
  		  	begin
						te_ptext:=@eochr[1];
						te_ptmplt:=@eochr[2];
						te_pvalid:=@eochr[2];
						te_resvd1:=0;
						te_just:=TE_LEFT;
						te_color:=0;
						te_resvd2:=0;
						te_thickness:=0;
						te_txtlen:=2;
						te_tmplen:=1
  		  	end;
				if appl_xgetinfo(0,SysInfo.Font.Height,fontid,dummy,dummy) then
					begin
						SysInfo.Font.ID:=vst_font(vdiHandle,fontid);
						vst_height(vdiHandle,SysInfo.Font.Height,dummy,SysInfo.Font.Height,SysInfo.Font.Width,dummy);
						with SysInfo.Font do getpoint(Height,Width,ID,Point)
					end
				else
					begin
						fontted.te_font:=IBM;
						objc_draw(@fontset,ROOT,1,0,0,0,0);
						vqt_attributes(aesHandle,atrb);
						SysInfo.Font.ID:=vst_font(vdiHandle,atrb[0]);
						if GetCookie('SMAL',gval) then
							if ((gval shr 16) and $ffff)<>0 then atrb[7]:=(gval shr 16) and $ffff;
						vst_height(vdiHandle,atrb[7],dummy,SysInfo.Font.Height,SysInfo.Font.Width,dummy);
						if SysInfo.Font.Height<5 then
							begin
								if hwratio>1 then SysInfo.Font.Point:=9
								else
									SysInfo.Font.Point:=10;
								vst_point(vdiHandle,SysInfo.Font.Point,dummy,SysInfo.Font.Height,SysInfo.Font.Width,dummy)
							end
						else
							with SysInfo.Font do getpoint(Height,Width,ID,Point)
					end;
				if appl_xgetinfo(1,SysInfo.SmallFont.Height,fontid,dummy,dummy) then
					begin
						SysInfo.SmallFont.ID:=vst_font(vdiHandle,fontid);
						vst_height(vdiHandle,SysInfo.SmallFont.Height,dummy,SysInfo.SmallFont.Height,SysInfo.SmallFont.Width,dummy);
						with SysInfo.SmallFont do getpoint(Height,Width,ID,Point)
					end
				else
					begin
						fontted.te_font:=SMALL;
						objc_draw(@fontset,ROOT,1,0,0,0,0);
						vqt_attributes(aesHandle,atrb);
						SysInfo.SmallFont.ID:=vst_font(vdiHandle,atrb[0]);
						if GetCookie('SMAL',gval) then
							if (gval and $ffff)<>0 then atrb[7]:=gval and $ffff;
						vst_height(vdiHandle,atrb[7],dummy,SysInfo.SmallFont.Height,SysInfo.SmallFont.Width,dummy);
						if SysInfo.SmallFont.Height<3 then
							begin
								SysInfo.SmallFont.Point:=8;
								vst_point(vdiHandle,SysInfo.SmallFont.Point,dummy,SysInfo.SmallFont.Height,SysInfo.SmallFont.Width,dummy)
							end
						else
							with SysInfo.SmallFont do getpoint(Height,Width,ID,Point);
					end;
				if appl_xgetinfo(2,dummy,dummy,fontid,extrsc) then
					begin
						HasColorIcons:=(fontid<>0);
						agi.ExtRsc:=(extrsc<>0);
					end
				else
					begin
						agi.ExtRsc:=((GEMVersion>=$0330) and (GEMVersion<>MAGIX)) or ((GEMVersion=MAGIX) and (MagiCVersion>=$0300));
						HasColorIcons:=false
					end;
				if appl_xgetinfo(13,dummy,dummy,dummy,fontid) then
					begin
						ExtObjects:=bTst(fontid,$0004);
						agi.GShortcut:=bTst(fontid,$0008);
						agi.SysNiceline:={bTst(fontid,$0010) or...} NAESActive or extmagxmenu;
					end
				else
					begin
						ExtObjects:=(MagiCVersion>=$0300);
						agi.GShortcut:=(MagiCDate>=$19971030);
						agi.SysNiceline:=NAESActive or extmagxmenu;
					end;
				if appl_xgetinfo(10,fontid,dummy,dummy,dummy) then
					begin
						agi.Shutdown:=((fontid and $00ff)>=9) or (MagiCVersion>=$0300);
						agi.Broadcast:=((fontid and $00ff)>=7) and not(MagiCActive);
					end
				else
					begin
						agi.Shutdown:=(GEMVersion>=$0400);
						agi.Broadcast:=agi.Shutdown;
					end;
				if appl_xgetinfo(11,extrsc,dummy,agi.Gadgets,fontid) then
					begin
						agi.WindUpdate:=(fontid<>0);
						agi.Owner:=bTst(extrsc,16);
						agi.BEvent:=bTst(extrsc,32);
						agi.Backdrop:=bTst(extrsc,64);
						agi.Iconify:=bTst(extrsc,384) and bTst(agi.Gadgets,1);
					end
				else
					begin
						agi.WindUpdate:=(GEMVersion>=$0400);
						agi.Iconify:=(GEMVersion>=$0410);
						agi.Backdrop:=agi.WindUpdate;
						agi.BEvent:=(GEMVersion>=$0331);
						agi.Owner:=agi.WindUpdate;
						if GEMVersion>=$0410 then agi.Gadgets:=1
						else
							agi.Gadgets:=0;
					end;
				if appl_xgetinfo(4,dummy,dummy,fontid,dummy) then agi.ApplSearch:=(fontid<>0)
				else
					agi.ApplSearch:=(GEMVersion>=$0400);
				if appl_xgetinfo(9,extrsc,dummy,dummy,fontid) then
					begin
						agi.MnAttach:=(extrsc<>0);
						agi.ExtMnSelect:=(fontid<>0);
					end
				else
					begin
						agi.ExtMnSelect:=(GEMVersion>=$0330) and (GEMVersion<>MAGIX);
						agi.MnAttach:=agi.ExtMnSelect;
					end;
				if appl_xgetinfo(6,dummy,dummy,fontid,dummy) then agi.MenuInq:=(fontid<>0)
				else
					agi.MenuInq:=MultiTOS;
				if appl_xgetinfo(3,fontid,dummy,dummy,dummy) then Attr.Country:=fontid;
				if appl_xgetinfo(AGI_WINX,fontid,dummy,dummy,dummy) then agi.Shading:=bTst(fontid,$0008)
				else
					agi.Shading:=false;
    		agi.MultiProto:=(GEM_pb.global[1]<>1) and (agi.ApplSearch or agi.Broadcast);
    		with SysInfo do
    			begin
						BGDefCol:=objc_xsysvar(BACKGRCOL,$0404);
						if ExtObjects then
							begin
								HotKeyCol:=Black;
								UsrDefCol:=Black;
							end
						else
							begin
								HotKeyCol:=Red;
								UsrDefCol:=Blue;
							end;
					end;
				bfalcol:=objc_xsysvar(ACTBUTCOL,$0100);
				if GetCookie('ICFS',gval) and not(agi.Iconify) then icfserver:=pointer(gval);
				Clipboard:=GetClipboard;
    	  SetupVDI;
				if Status>=em_OK then
					begin
						SysInfo.BGDefCol:=objc_xsysvar(BACKGRCOL,$0404);
						bfalcol:=objc_xsysvar(ACTBUTCOL,$0100);
						vq_color(vdiHandle,SysInfo.BGDefCol,1,rgb);
						SysInfo.DefCol.rgb.reserved:=0;
						SysInfo.DefCol.rgb.red:=word(((longint(rgb[0])*longint(65535)) div longint(1000)) and $0000ffff);
						SysInfo.DefCol.rgb.green:=word(((longint(rgb[1])*longint(65535)) div longint(1000)) and $0000ffff);
						SysInfo.DefCol.rgb.blue:=word(((longint(rgb[2])*longint(65535)) div longint(1000)) and $0000ffff);
						defcolfg.rgb.reserved:=0;
						defcolfg.rgb.red:=0;
						defcolfg.rgb.green:=0;
						defcolfg.rgb.blue:=0;
						SysInfo.DefColValid:=HasNewColorFn and (Attr.Colors>=SysInfo.BGDefCol);
						gval:=0;
						GetXAccAttr(XAcc);
						with XAcc do
							begin
								if AppTypeHR=nil then AppTypeHR:=NewStr(XAccMR2HR(AppTypeMR));
								if length(AppTypeMR)>0 then inc(gval,length(AppTypeMR)+2);
								if AppTypeHR<>nil then inc(gval,length(AppTypeHR^)+2);
								if ExtFeatures<>nil then inc(gval,length(ExtFeatures^)+2);
								if GenericName<>nil then inc(gval,length(GenericName^)+2);
							end;
						if gval>0 then inc(gval,5);
						xdsc:=(gval>0);
						inc(gval,length(Name^)+2);
						xaccnlen:=gval;
						GlobalAlloc(pointer(xaccname),xaccnlen);
						if xaccname<>nil then
							begin
								if xdsc then
									begin
										StrPCopy(xaccname,Name^+#0'XDSC');
										dst:=PChar(longint(xaccname)+length(Name^)+6);
										with XAcc do
											begin
												pXDSC:=dst;
												if AppTypeHR<>nil then
													begin
														StrPCopy(dst,'1'+AppTypeHR^);
														dst:=PChar(longint(dst)+length(AppTypeHR^)+2)
													end;
												if length(AppTypeMR)>0 then
													begin
														StrPCopy(dst,'2'+AppTypeMR);
														dst:=PChar(longint(dst)+length(AppTypeMR)+2)
													end;
												if ExtFeatures<>nil then
													begin
														StrPCopy(dst,'X'+ExtFeatures^);
														dst:=PChar(longint(dst)+length(ExtFeatures^)+2)
													end;
												if GenericName<>nil then
													begin
														StrPCopy(dst,'N'+GenericName^);
														dst:=PChar(longint(dst)+length(GenericName^)+2)
													end
											end;
										dst^:=#0
									end
								else
									StrPCopy(xaccname,Name^+#0)
							end;
						if GetOLGAAttr(OLGA) then Attr.Style:=Attr.Style or as_OLGA;
	  	      InitApplication;
    	    	if Status>=em_OK then
    	    		begin
								if bTst(Attr.Style,as_OLGA) then
									begin
										dummy:=appl_find('OLGA    ');
										if dummy<0 then
											begin
												scmd:=GetEnv('OLGAMANAGER');
												if length(scmd)>0 then
													begin
														ffnd:=StrPUpper(GetFilename(scmd,false));
														dummy:=appl_find(ffnd+StrPSpace(8-length(ffnd)));
														if dummy<0 then dummy:=StartApp(scmd,'')
													end
											end;
										if dummy<0 then dummy:=appl_find('OLEMANGR');
										if dummy<0 then
											begin
												scmd:=GetEnv('OLEMANAGER');
												if length(scmd)>0 then
													begin
														ffnd:=StrPUpper(GetFilename(scmd,false));
														dummy:=appl_find(ffnd+StrPSpace(8-length(ffnd)));
														if dummy<0 then dummy:=StartApp(scmd,'')
													end
											end;
										if dummy>=0 then OLENew(dummy,0,0,0,0,0)
									end;
		    	    	InitInstance
    	    		end;
						if Status>=em_OK then
							if agi.MultiProto then
						    begin
									pipe[0]:=ACC_ID;
									pipe[3]:=integer((XAcc.Version shl 8)+XAcc.MsgGroups);
									pipe[4]:=integer(HiWord(xaccname));
									pipe[5]:=integer(LoWord(xaccname));
									pipe[6]:=menuID;
									pipe[7]:=0;
									Broadcast(@pipe,true);
									dummy:=id_No;
									scmd:=GetEnv('AVSERVER');
									if length(scmd)>0 then
										begin
											scmd:=StrPUpper(StrPLeft(StrPTrimF(scmd),8));
											dummy:=appl_find(scmd+StrPSpace(8-length(scmd)))
										end;
									if dummy<0 then dummy:=appl_find('AVSERVER');
									if dummy<0 then dummy:=appl_find('JINNEE  ');
									if dummy<0 then dummy:=appl_find('THING   ');
									if dummy<0 then dummy:=appl_find('GEMINI  ');
									if dummy<0 then dummy:=appl_find('MAGXDESK');
									if dummy<0 then dummy:=appl_find('EASE    ');
									if dummy>=0 then
										begin
											pipe[0]:=AV_PROTOKOLL;
											pipe[1]:=apID;
											pipe[2]:=0;
											pipe[3]:=integer(XAcc.AVAccMsg);
											pipe[4]:=0;
											pipe[5]:=0;
											pipe[6]:=integer((longint(apName)+1) div 65536);
											pipe[7]:=integer((longint(apName)+1) mod 65536);
											appl_write(dummy,16,@pipe)
										end
								end
					end;
				wind_update(END_UPDATE)
      end
  end;


destructor TApplication.Done;
	var ci  : integer;
	    pipe: Pipearray;

	begin
		appdone:=false;
		while (MainWindow<>nil) do MainWindow^.Free;
		if termflag then Terminate;
		ClosePrivateProfile;
		if OLGAManager>=0 then
			begin
				pipe[0]:=OLE_EXIT;
				pipe[1]:=apID;
				pipe[2]:=0;
				pipe[3]:=0;
				pipe[4]:=0;
				pipe[5]:=0;
				pipe[6]:=0;
				pipe[7]:=0;
				appl_write(OLGAManager,16,@pipe)
			end;
		if XAccList<>nil then
			begin
				XAccList^.ForEach(@SendXAccExit);
				dispose(PXAccCollection(XAccList),Done);
				XAccList:=nil
			end;
		if not(AppFlag or MultiTOS) then while true do evnt_timer(0,1);
		if Clipboard<>nil then Clipboard^.Free;
		ExitGem;
		DisposeStr(Attr.rpTail);
		DisposeStr(Attr.rpCmd);
		DisposeStr(XAcc.AppTypeHR);
		DisposeStr(XAcc.ExtFeatures);
		DisposeStr(XAcc.GenericName);
		DisposeStr(apName);
		DisposeStr(apPath);
    DisposeStr(Name);
		GlobalFree(pointer(xaccname),xaccnlen);
		Application:=nil;
    inherited Done;
  end;


function TApplication.CanClose: boolean;
	var p    : PWindow;
	    valid: boolean;

	begin
		if (AppFlag or MultiTOS) then
		  begin
		  	p:=MainWindow;
		  	valid:=true;
		  	while (p<>nil) and valid do
		  		with p^ do
			  		begin
			  			if Attr.Status=ws_Open then
				  			if not(CanClose) then valid:=false;
		  				p:=Nxt
		  			end;
		  	CanClose:=valid
		  end
		else
			CanClose:=false
	end;


function TApplication.IsIconified: boolean;

	begin
		IsIconified:=allicn
	end;


procedure TApplication.LoadResource(FileHiRes,FileLoRes: string);
	var vald: boolean;

	procedure loadrsc(const s: string);
	
		begin
			if length(s)=0 then exit;
			if rsrc_load(s)<>0 then vald:=true
			else
				if rsrc_load(GetFilename(s,true))<>0 then vald:=true
		end;

	begin
		if RscPtr=nil then
			begin
				vald:=false;
				if hwratio<=1 then
					begin
						loadrsc(FileHiRes);
						if not(vald) then loadrsc(FileLoRes)
					end
				else
					begin
						loadrsc(FileLoRes);
						if not(vald) then loadrsc(FileHiRes)
					end;
				if vald then
					begin
						RscPtr:=RSC_LOADED;
						FixResource(Ptr(word(GEM_pb.global[7]),word(GEM_pb.global[8])),FIXRSC,FIX_BBONLY)
					end
				else
					begin
						RscPtr:=nil;
						Status:=em_RscNotFound;
						Err:=Status;
						Error(Err)
					end
			end
	end;


procedure TApplication.InitResource(AddrHiRes,AddrLoRes: pointer);
	var pool: AESTreePtrArrayPtr;

	begin
		if (RscPtr=nil) and ((AddrHiRes<>nil) or (AddrLoRes<>nil)) then
			begin
			  if AddrHiRes=nil then AddrHiRes:=AddrLoRes;
			  if AddrLoRes=nil then AddrLoRes:=AddrHiRes;
			  if hwratio>1 then RscPtr:=AddrLoRes
			  else
			    RscPtr:=AddrHiRes;
				FixResource(RscPtr,FIXRSC,FIX_ALL);
				pool:=@RscPtr^.rsd[RscPtr^.rsh.rsh_trindex];
				with GEM_pb do
					begin
						global[5]:=integer(HiWord(pool));
						global[6]:=integer(LoWord(pool));
						global[7]:=integer(HiWord(RscPtr));
						global[8]:=integer(LoWord(RscPtr));
						global[9]:=integer(RscPtr^.rsh.rsh_rssize)
					end
			end
	end;


function TApplication.GetAddr(Indx: integer): PTree;
	var tree: pointer;

	begin
		if RscPtr<>nil then
			begin
				if RscPtr=RSC_LOADED then
					begin
						if rsrc_gaddr(R_TREE,Indx,tree)<>0 then
							GetAddr:=tree
						else
							GetAddr:=nil
					end
				else
					GetAddr:=AESTreePtrArrayPtr(@RscPtr^.rsd[RscPtr^.rsh.rsh_trindex])^[Indx]
			end
		else
			GetAddr:=nil
	end;


function TApplication.GetFImagePtr(Indx: integer): pointer;
	var imgptr: pointer;

	begin
		if RscPtr<>nil then
			begin
				if RscPtr=RSC_LOADED then
					begin
						if rsrc_gaddr(R_FRIMG,ROOT,imgptr)=0 then GetFImagePtr:=nil
						else
							GetFImagePtr:=FreeImgPtrArrayPtr(imgptr)^[Indx]
					end
				else
					begin
						if (Indx>=0) and (Indx<RscPtr^.rsh.rsh_nimages) then
							GetFImagePtr:=FreeImgPtrArrayPtr(@RscPtr^.rsd[RscPtr^.rsh.rsh_frimg])^[Indx]
						else
							GetFImagePtr:=nil
					end
			end
		else
			GetFImagePtr:=nil
	end;


function TApplication.GetFStringPtr(Indx: integer): PChar;
	var strptr: pointer;

	begin
		if RscPtr<>nil then
			begin
				if RscPtr=RSC_LOADED then
					begin
						if rsrc_gaddr(R_FRSTR,ROOT,strptr)=0 then GetFStringPtr:=nil
						else
							GetFStringPtr:=FreeStrPtrArrayPtr(strptr)^[Indx]
					end
				else
					begin
						if (Indx>=0) and (Indx<RscPtr^.rsh.rsh_nstring) then
							GetFStringPtr:=FreeStrPtrArrayPtr(@RscPtr^.rsd[RscPtr^.rsh.rsh_frstr])^[Indx]
						else
							GetFStringPtr:=nil
					end
			end
		else
			GetFStringPtr:=nil
	end;


function TApplication.GetFString(Indx: integer): string;

	begin
		GetFString:=StrPPas(GetFStringPtr(Indx))
	end;


function TApplication.GetIconTitle: string;

	begin
		GetIconTitle:=Name^
	end;


function TApplication.GetClipboard: PClipboard;

	begin
		GetClipboard:=new(PClipboard,Init(@self))
	end;


procedure TApplication.GetXAccAttr(var XAccAttr: TXAccAttr);

	begin
		with XAccAttr do
			begin
				Version:=0;
				MsgGroups:=3;
				Protocol:=PROTO_XACC or PROTO_AV;
				AVSrvMsg:=MSG_SENDKEY or MSG_STARTPROG or MSG_PATH_UPDATE or MSG_EXIT or MSG_STARTED_4701;
				AVAccMsg:=MSG_START or MSG_STARTED;
				AppTypeMR:='';
				AppTypeHR:=nil;
				ExtFeatures:=NewStr('FontAck');
				GenericName:=nil;
				pXDSC:=nil
			end;
		XAccAttr.apID:=apID;
		XAccAttr.menuID:=menuID;
		XAccAttr.Name:=Name
	end;


function TApplication.GetOLGAAttr(var OLGAAttr: TOLGAAttr): boolean;

	begin
		with OLGAAttr do
			begin
				Msg:=OL_PEER or OL_IDLE;
				Protocol:=0;
				ManagerMsg:=0;
				ManagerProtocol:=0
			end;
		GetOLGAAttr:=true
	end;


function TApplication.SendWndMessage(gHnd: integer; Msg: pointer; sID,Icn: boolean): boolean;
	var aid,dummy,opn: integer;
	    pw           : PWindow;

	begin
		SendWndMessage:=false;
		if Msg=nil then exit;
		if gHnd<=DESK then wind_get(DESK,WF_TOP,gHnd,dummy,dummy,dummy);
		if gHnd<=DESK then exit;
		if sID then PPipearray(Msg)^[1]:=apID;
		PPipearray(Msg)^[2]:=0;
		PPipearray(Msg)^[3]:=gHnd;
		if agi.Owner then wind_get(gHnd,WF_OWNER,aid,dummy,dummy,dummy)
		else
			if GetGPWindow(gHnd)=nil then aid:=-1
			else
				aid:=apID;
		if not(Icn) then
			begin
				if aid=apID then
					begin
						pw:=GetGPWindow(gHnd);
						if pw<>nil then
							if pw^.IsIconified then exit
					end;
				if agi.Iconify then
					begin
						wind_get(gHnd,WF_ICONIFY,opn,dummy,dummy,dummy);
						if opn<>0 then exit
					end
			end;
		if aid<0 then Broadcast(Msg,false)
		else
			appl_write(aid,16,Msg);
		SendWndMessage:=true
	end;


procedure TApplication.Broadcast(Msg: pointer; sID: boolean);
	var p         : PXAccAttr;
	    q,atyp,aid: integer;
	    fname     : string;

	begin
		if Msg=nil then exit;
		if sID then PPipearray(Msg)^[1]:=apID;
		PPipearray(Msg)^[2]:=0;
		if agi.Broadcast then
			begin
				with AES_pb do
					begin
						control^[0]:=121;
						control^[1]:=3;
						control^[2]:=1;
						control^[3]:=2;
						control^[4]:=0;
						intin^[0]:=7;
						intin^[1]:=0;
						intin^[2]:=0;
						addrin^[0]:=Msg;
						addrin^[1]:=nil
					end;
				_crystal(@AES_pb)
			end
		else
			if agi.ApplSearch then
				begin
					q:=appl_search(0,fname,atyp,aid);
					while q=1 do
						begin
							if (atyp<>1) and (aid<>apID) then appl_write(aid,16,Msg);
							q:=appl_search(1,fname,atyp,aid)
						end
				end
			else
				if XAccList<>nil then
					with XAccList^ do
						if Count>0 then
							for q:=0 to Count-1 do
								begin
									p:=At(q);
									if p<>nil then appl_write(p^.apID,16,Msg)
								end
	end;


function TApplication.FindApplication(AName: string; AnID: integer; var XAccAttr: TXAccAttr): boolean;
	var p: PXAccAttr;
	    q: longint;

	begin
		FindApplication:=false;
		lastfa:=-1;
		if (length(AName)=0) and (AnID<0) then exit;
		if XAccList<>nil then
			with XAccList^ do
				if Count>0 then
					for q:=0 to Count-1 do
						begin
							p:=At(q);
							if p<>nil then
								begin
									if length(AName)>0 then
										begin
											if p^.Name^=AName then
												begin
													XAccAttr:=p^;
													FindApplication:=true;
													lastfa:=q;
													exit
												end
										end
									else
										if p^.apID=AnID then
											begin
												XAccAttr:=p^;
												FindApplication:=true;
												lastfa:=q;
												exit
											end
								end
						end
	end;


function TApplication.FirstApplication(AType: TAppTypeMR; GenName: string; var XAccAttr: TXAccAttr): boolean;

	begin
		DisposeStr(nappgen);
		nappgen:=NewStr(GenName);
		nxtapp:=0;
		napptype:=AType;
		FirstApplication:=NextApplication(XAccAttr)
	end;


function TApplication.NextApplication(var XAccAttr: TXAccAttr): boolean;
	label _weiter;

	begin
		NextApplication:=false;
		if XAccList=nil then exit;
		with XAccList^ do
			while nxtapp<Count do
				begin
					if At(nxtapp)=nil then goto _weiter;
					with PXaccAttr(At(nxtapp))^ do
						begin
							if napptype<>'  ' then
								if napptype<>AppTypeMR then goto _weiter;
							if nappgen<>nil then
								if GenericName<>nil then
									if nappgen^<>GenericName^ then goto _weiter;
							NextApplication:=true;
							XAccAttr:=PXaccAttr(At(nxtapp))^;
							inc(nxtapp);
							exit
						end;
					_weiter:
					inc(nxtapp)
				end
	end;


procedure TApplication.FreeResource;
	var q: integer;

	begin
		if RscPtr<>nil then
			begin
				if RscPtr=RSC_LOADED then
					begin
						if rsrc_free<>0 then
							begin
								for q:=5 to 9 do GEM_pb.global[q]:=0;
								RscPtr:=nil
							end
					end
				else
					begin
						FixResource(RscPtr,UNFIXRSC,FIX_ALL);
						for q:=5 to 9 do GEM_pb.global[q]:=0;
						RscPtr:=nil
					end
			end
	end;


procedure TApplication.InstallDesktop(tIndx,oIndx: integer);
	var tp: PTree;

	begin
		tp:=GetAddr(tIndx);
		if (tp<>nil) and AppFlag then
			begin
				with SysInfo.Desktop do
					begin
						tp^[ROOT].ob_x:=X;
						tp^[ROOT].ob_y:=Y;
						tp^[ROOT].ob_width:=W;
						tp^[ROOT].ob_height:=H
					end;
				wind_set(DESK,WF_NEWDESK,integer(HiWord(tp)),integer(LoWord(tp)),oIndx,0);
				deskinst:=true;
				DeskRedraw
			end
	end;


procedure TApplication.RemoveDesktop;

	begin
		if AppFlag and deskinst then
			begin
				wind_set(DESK,WF_NEWDESK,0,0,0,0);
				deskinst:=false;
				DeskRedraw
			end
	end;


procedure TApplication.LoadIcon(icnTree,icnIndx: integer);

	begin
		if (ticn=-1) and (icnTree>=0) and (icnIndx>=ROOT) then
			begin
				ticn:=icnTree;
				iicn:=icnIndx;
				if IsIconified then
					if icnwnd<>nil then
						begin
							new(Icon,Init(icnwnd,ticn,iicn,0,0,false,false,'',''));
							icnwnd^.LoadIcon(Icon)
						end
			end
	end;


procedure TApplication.FreeIcon;

	begin
		if ticn<>-1 then
			begin
				if IsIconified then
					if icnwnd<>nil then icnwnd^.FreeIcon;
				Icon:=nil;
				ticn:=-1
			end
	end;


procedure TApplication.LoadMenu(Indx: integer);
	var tp   : PTree;
	    pipe : Pipearray;
	    dummy: integer;

	begin
		tp:=GetAddr(Indx);
		if (MenuTree=nil) and (tp<>nil) and AppFlag then
			begin
				MenuTree:=tp;
				if MenuCorrect(MenuTree,dummy) then
					begin
						if bTst(Attr.Style,as_MenuSeparator) then MenuTune;
						if menu_bar(MenuTree,ME_DRAW)=0 then
							begin
								MenuTree:=nil;
								Err:=em_InvalidMenu
							end
						else
							begin
								new(menuentries);
								if menuentries<>nil then
									begin
										GetMenuEntries(menuentries^);
										pipe[0]:=GO_PRIVATE;
										pipe[1]:=apID;
										pipe[2]:=0;
										pipe[3]:=GOP_SETQUIT;
										pipe[4]:=menuentries^.Quit.Entry;
										pipe[5]:=menuentries^.Quit.Title;
										appl_write(apID,16,@pipe);
										CheckMenuEntries
									end
							end
					end
				else
					begin
						MenuTree:=nil;
						Err:=em_InvalidMenu
					end
			end
		else
			Err:=em_InvalidMenu
	end;


procedure TApplication.DrawMenu;

	begin
		if MenuTree<>nil then
			begin
				if agi.MenuInq then
					begin
						wind_update(BEG_UPDATE);
						if menu_bar(nil,ME_INQUIRE)=apID then menu_bar(MenuTree,ME_DRAW);
						wind_update(END_UPDATE)
					end
				else
					menu_bar(MenuTree,ME_DRAW)
			end
	end;


procedure TApplication.FreeMenu;

	begin
		if MenuTree<>nil then
			if menu_bar(nil,ME_ERASE)<>0 then MenuTree:=nil;
		if menuentries<>nil then dispose(menuentries);
		menuentries:=nil
	end;


function TApplication.AutoFolder: boolean;

	begin
		AutoFolder:=false
	end;


procedure TApplication.InitGEM;
	label _notempty;

  var i         : integer;
      scmd,stail: string;
      penv,dummy: pointer;

  begin
  	GEM_pb.global[0]:=0;
  	apID:=appl_init;
  	if GEM_pb.global[0]=0 then
  		begin
  			if not(AutoFolder) then
  				begin
		  			if Attr.Country=FRA then
		  				writeln(#27'p'+Name^+#27'q: AES inactif -> Quitter!')
		  			else if (Attr.Country=FRG) or (Attr.Country=SWG) then
  						writeln(#27'p'+Name^+#27'q: AES nicht aktiv -> Abbruch!')
  					else
		  				writeln(#27'p'+Name^+#27'q: AES not active -> quit!')
  				end;
  			apID:=-1;
  			Status:=em_AESNotActive;
  			Err:=Status;
  			exit
  		end;
	  if apID>=0 then
      begin
      	i:=shel_read(scmd,stail);
      	if AppFlag then BusyMouse;
    		MultiTOS:=(GEMVersion>=$0400) and (GEM_pb.global[1]=-1);
    		Multitasking:=(GEM_pb.global[1]<>1);
				Psignal(SIGTERM,@SigHandler);
				Psignal(SIGQUIT,@SigHandler);
      	if i<>0 then
      		begin
      			if paramcount>0 then
      				if length(StrPTrimF(paramstr(0)))<>0 then goto _notempty;
		      	StrPTrim(scmd);
						stail:=StrPTrimF(StrPMid(stail,2,Min(ord(stail[1]),125)))
      		end
      	else
      		begin
      			_notempty:
      			scmd:='';
      			stail:=''
      		end;
      	if length(scmd)=0 then
      		if paramcount>0 then
	      		if length(StrPTrimF(paramstr(0)))>0 then scmd:=StrPTrimF(paramstr(0));
      	if length(stail)=0 then
      		begin
      			if paramcount>0 then
      				begin
      					i:=1;
      					repeat
      						if length(stail)+length(paramstr(i))>=254 then i:=paramcount
      						else
				      			stail:=stail+paramstr(i)+' ';
			      			inc(i)
			      		until (i>=paramcount)
      				end
      			else
      				if AppFlag then
	      				if PByte(longint(BasePage)+$80)^>0 then
  	    					stail:=StrLPas(pointer(longint(BasePage)+$81),Min(PByte(longint(BasePage)+$80)^,125));
      			StrPTrim(stail)
      		end;
				if StrPLeft(scmd,1)='\' then
					begin
						if AppFlag then scmd:=chr(dgetdrv+65)+':'+scmd
						else
							scmd:=BootDevice+':'+scmd
					end;
				if StrPRight(StrPLeft(scmd,2),1)<>':' then
					begin
 						if AppFlag then scmd:=chr(dgetdrv+65)+':\'+scmd
 						else
 							scmd:=BootDevice+':\'+scmd
					end;
				Attr.rpCmd:=NewStr(scmd);
				if length(stail)>0 then Attr.rpTail:=NewStr(stail);
    		aesHandle:=graf_handle(Attr.charSWidth,Attr.charSHeight,Attr.boxSWidth,Attr.boxSHeight);
	    	for i:=1 to 9 do workIn[i]:=1;
	    	workIn[0]:=getrez+2;
    		workIn[10]:=RC;
    		vdiHandle:=aesHandle;
    		v_opnvwk(workIn,vdiHandle,workOut);
    		if vdiHandle<=0 then
      		begin
      			if AppFlag or MultiTOS then
      				begin
					      appl_exit;
					      apID:=-1;
			  		    Status:=em_GEMInitFailure;
			      		Err:=Status
			      	end
			      else
			      	while true do evnt_timer(0,1)
			    end
			  else
			  	begin
						Status:=em_OK;
						menuID:=-1;
						if not(AppFlag) or MultiTOS then
							begin
								menuID:=menu_register(apID,'  '+StrPLeft(Name^,17)+' ');
								if (menuID<0) and not(AppFlag) then
									begin
										Status:=em_AccInitFailure;
										Err:=Status
									end
							end
					end
			end
	  else
	  	begin
	 		  Status:=em_GEMInitFailure;
	 		  Err:=Status
 		  end
  end;


procedure	TApplication.ExitGEM;

  begin
  	if apID>=0 then
  		begin
				RemoveDesktop;
				FreeIcon;
				FreeMenu;
				FreeResource
  		end;
	  if vdiHandle>0 then
	  	begin
				if GDOSActive then vst_unload_fonts(vdiHandle,0);
			  v_clsvwk(vdiHandle);
			  vdiHandle:=-1
			end;
	  if apID>=0 then
	  	begin
				appl_exit;
				apID:=-1
			end
	end;


procedure TApplication.SetupVDI;
	var dummy  : integer;
	    ewrkout: workout_ARRAY;

	begin
		vq_extnd(vdiHandle,1,ewrkout);
		CanScaleIMG:=bTst(ewrkout[30],1);
		CanTransferBits:=bTst(ewrkout[30],2);
		HasNewColorFn:=bTst(ewrkout[32],1);
		SetSystemFont(vdiHandle,Attr.charWidth,Attr.charHeight,Attr.boxWidth,Attr.boxHeight);
		vst_alignment(vdiHandle,TA_LEFT,TA_BASELINE,dummy,dummy);
		vsl_udsty(vdiHandle,$5555);
		vsf_interior(vdiHandle,FIS_HOLLOW);
		vsf_style(vdiHandle,4);
		vsm_height(vdiHandle,1);
		vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
	end;


procedure TApplication.InitApplication;

  begin
  end;


procedure TApplication.InitInstance;

  begin
		if Status>=em_OK then
			begin
				if (AppFlag or MultiTOS) then pquit:=new(PQKey,Init(@self,K_CTRL,Ctrl_Quit,-1,-1));
				if bTst(Attr.Style,as_HandleShutdown) then
					if agi.Shutdown then shel_write(9,1,0,'','');
				wind_update(END_UPDATE);
				InitMainWindow;
				wind_update(BEG_UPDATE)
			end
  end;


procedure TApplication.InitMainWindow;

	begin
		new(PWindow,Init(nil,Name^));
		if (MainWindow=nil) or (Err<em_OK) then Status:=em_InvalidMainWindow
	end;


function TApplication.GetGPWindow(gHnd: integer): PWindow;
	var p,pc,pc2: PWindow;

	begin
		GetGPWindow:=nil;
		if gHnd<0 then exit;
		p:=MainWindow;
		while (p<>nil) do
			begin
				with p^ do
					begin
						if Attr.gemHandle=gHnd then
							begin
								GetGPWindow:=p;
								exit
							end;
						pc:=ChildList
					end;
				if (pc<>nil) then
					begin
						while (pc^.ChildList<>nil) do pc:=pc^.ChildList;
						repeat
							pc2:=pc;
							while (pc2<>nil) do
								with pc2^ do
									begin
										if Attr.gemHandle=gHnd then
											begin
												GetGPWindow:=pc2;
												exit
											end;
										pc2:=Nxt
									end;
							pc:=pc^.Parent
						until pc=p
					end;
				p:=p^.Nxt
			end
	end;


function TApplication.GetPWindow(Hnd: HWnd): PWindow;
	var p,pc,pc2: PWindow;

	begin
		p:=MainWindow;
		while (p<>nil) do
			begin
				with p^ do
					begin
						if Attr.Handle=Hnd then
							begin
								GetPWindow:=p;
								exit
							end;
						pc:=ChildList
					end;
				if (pc<>nil) then
					begin
						while (pc^.ChildList<>nil) do pc:=pc^.ChildList;
						repeat
							pc2:=pc;
							while (pc2<>nil) do
								with pc2^ do
									begin
										if Attr.Handle=Hnd then
											begin
												GetPWindow:=pc2;
												exit
											end;
										pc2:=Nxt
									end;
							pc:=pc^.Parent
						until pc=p
					end;
				p:=p^.Nxt
			end;
		GetPWindow:=nil
	end;


function TApplication.GetPTopWindow: PWindow;
	var top,under,dummy: integer;

	begin
		under:=DESK;
		wind_get(DESK,WF_TOP,top,dummy,under,dummy);
		if top<0 then top:=under;
		GetPTopWindow:=GetGPWindow(top)
	end;


function TApplication.GetMsTimer: longint;

	begin
		GetMsTimer:=1000
	end;


procedure TApplication.GetCrsRect(var crect: GRECT);

	begin
		if pcrswatch<>nil then crect:=pcrswatch^.Work
	end;


function TApplication.GetEvent(var data: TEventData): integer;
	var crect: GRECT;

	begin
		GetCrsRect(crect);
		GetEvent:=evnt_multi(Attr.EventMask,258,3,0,0,crect.X,crect.Y,crect.W,crect.H,
												 1,crect.X,crect.Y,crect.W,crect.H,data.Pipe,GetMsTimer mod 65536,
												 GetMsTimer div 65536,data.mX,data.mY,data.BStat,data.KStat,data.Key,data.Clicks)
	end;


procedure TApplication.MessageLoop;
	var data : TEventData;
			event: integer;

  begin
  	repeat
  		Status:=em_OK;
			while (Status>=em_OK) do
				begin
			  	event:=GetEvent(data);
					if bTst(event,MU_M1) then MUM1(data);
					if bTst(event,MU_M2) then MUM2(data);
					if bTst(event,MU_KEYBD) then MUKeybd(data);
					if bTst(event,MU_BUTTON) then MUButton(data);
					if bTst(event,MU_MESAG) then MUMesag(data);
					if bTst(event,MU_TIMER) then MUTimer(data)
				end;
			if Status=em_Terminate then break;
			HandleError;
			if Status>=em_OK then continue
		until (Status<>em_Quit) or CanClose
  end;


procedure TApplication.MUKeybd(data: TEventData);
	var p    : PEvent;
	    pw   : PWindow;
	    dummy: integer;

	procedure WIconify;
		var ICFGetPos: function(d1,d2: pointer; d3,d4,d5: longint; fn: integer; px,py,pb,ph: pointer): integer;
		    x,y,w,h  : integer;

		begin
			if icfserver<>nil then
				begin
					ICFGetPos:=icfserver;
					pw^.icfpos:=ICFGetPos(nil,nil,0,0,0,ICF_GETPOS,@x,@y,@w,@h);
					if pw^.icfpos>=0 then pw^.WMIconify(x,y,w,h)
				end
			else
				if agi.Iconify then pw^.WMIconify(-1,-1,-1,-1)
		end;

	procedure WCycle;
		label _f_nochmal,_f_suchen,_b_nochmal,_b_suchen;

		var flag: boolean;
		    p,wp: PWindow;

		begin
			flag:=false;
			wp:=pw;
			if (data.KStat and K_SHIFT)>0 then
				begin
					_b_nochmal:
					p:=wp;
					while p<>nil do
						begin
							if p^.CycleTop(pw,true) then exit;
							p:=p^.Previous
						end;
					_b_suchen:
					p:=wp^.Parent;
					if p=nil then
						begin
							if flag then exit;
							wp:=Application^.MainWindow;
							while wp<>nil do
								begin
									if wp^.Next=nil then break;
									wp:=wp^.Next
								end;
							flag:=true;
							goto _b_nochmal
						end;
					wp:=p^.Previous;
					if wp=nil then
						begin
							wp:=p;
							goto _b_suchen
						end
					else
						goto _b_nochmal
				end
			else
				begin
					_f_nochmal:
					p:=wp;
					while p<>nil do
						begin
							if p^.CycleTop(pw,false) then exit;
							p:=p^.Next
						end;
					_f_suchen:
					p:=wp^.Parent;
					if p=nil then
						begin
							if flag then exit;
							wp:=Application^.MainWindow;
							flag:=true;
							goto _f_nochmal
						end;
					wp:=p^.Next;
					if wp=nil then
						begin
							wp:=p;
							goto _f_suchen
						end
					else
						goto _f_nochmal
				end
		end;

	procedure WClose;
		var wert: integer;

		begin
			wert:=pw^.Attr.Style;
			if pw^.IsIconified then
				if pw^.icfpos>=0 then wert:=pw^.icfstyle;
			if bTst(wert,CLOSER) then pw^.WMClosed
		end;

	begin
		if not(allicn) then
			begin
				if data.Key=Ctrl_Cycle then
					if bTst(data.KStat,K_CTRL) then
						begin
							pw:=GetPTopWindow;
							if pw=nil then exit;
							if menuentries<>nil then
								if menuentries^.Cycle.Title>0 then
									if MenuTree<>nil then
										begin
											menu_tnormal(MenuTree,menuentries^.Cycle.Title,ME_INVERT);
											WCycle;
											menu_tnormal(MenuTree,menuentries^.Cycle.Title,ME_NORMAL);
											exit
										end;
							WCycle;
							exit
						end;
				if bTst(Attr.Style,as_XInputMode) then pw:=GetGPWindow(wind_find(data.mX,data.mY))
				else
					pw:=nil;
				if pw=nil then pw:=GetPTopWindow;
				if pw<>nil then
					begin
						if data.KStat=K_CTRL then
							case data.Key of
							Ctrl_Close:
								begin
									if menuentries<>nil then
										if menuentries^.Close.Title>0 then
											if MenuTree<>nil then
												begin
													menu_tnormal(MenuTree,menuentries^.Close.Title,ME_INVERT);
													WClose;
													menu_tnormal(MenuTree,menuentries^.Close.Title,ME_NORMAL);
													exit
												end;
									WClose;
									exit
								end;
							Ctrl_Backdrop:
								begin
									pw^.WMBottomed;
									exit
								end
							end;
						if not(pw^.IsIconified or pw^.IsShaded) then
							begin
								if data.KStat=K_CTRL then
									case data.Key of
									Ctrl_Fuller:
										begin
											if not(bTst(pw^.Attr.Style,FULLER)) then exit;
											if menuentries<>nil then
												if menuentries^.Full.Title>0 then
													if MenuTree<>nil then
														begin
															menu_tnormal(MenuTree,menuentries^.Full.Title,ME_INVERT);
															pw^.WMFulled;
															menu_tnormal(MenuTree,menuentries^.Full.Title,ME_NORMAL);
															exit
														end;
											pw^.WMFulled;
											exit
										end;
									Ctrl_A:
										begin
											pw^.SelectAll;
											exit
										end;
									Ctrl_P:
										begin
											pw^.Print;
											exit
										end;
									Ctrl_X:
										begin
											pw^.Cut;
											exit
										end;
									Ctrl_C:
										begin
											pw^.Copy;
											exit
										end;
									Ctrl_V:
										begin
											pw^.Paste;
											exit
										end
									end
								else
									if data.KStat=K_CTRL+K_ALT then
										begin
											if data.Key=CtrlAlt_Iconify then
												begin
													WIconify;
													exit
												end
										end
									else
										if data.KStat=K_NORMAL then
											if data.Key=S_Delete then
												begin
													pw^.Delete;
													exit
												end;
								p:=pw^.EventList;
								while p<>nil do
									begin
										if p^.TestKey(data.KStat,data.Key) then exit;
										p:=p^.Next
									end
							end
						else
							if ((data.KStat=K_CTRL) and (data.Key=Ctrl_Fuller)) or ((data.KStat=K_CTRL+K_ALT) and (data.Key=CtrlAlt_Iconify)) then
								if (pw^.icfpos>=0) or agi.Iconify then
									begin
										with pw^.icfcurr do pw^.WMUniconify(X,Y,W,H);
										exit
									end
					end
			end;
		if data.KStat=K_CTRL then
			case data.Key of
			Ctrl_A:
				begin
					SelectAll;
					exit
				end;
			Ctrl_X:
				begin
					Cut;
					exit
				end;
			Ctrl_C:
				begin
					Copy;
					exit
				end;
			Ctrl_V:
				begin
					Paste;
					exit
				end
			end
		else
			if data.KStat=K_NORMAL then
				if data.Key=S_Delete then
					begin
						Delete;
						exit
					end;
		p:=EventList;
		while p<>nil do
			begin
				if p^.TestKey(data.KStat,data.Key) then exit;
				p:=p^.Next
			end;
		HandleKeybd(data.KStat,data.Key)
	end;


procedure TApplication.MUButton(data: TEventData);
	label _desktop,_handle,_menu,_noentry;

	var p         : PEvent;
	    pw        : PWindow;
	    r         : GRECT;
	    tbi,pdx,rx,
	    ry,rw,rh,q: integer;
	    ppop      : PMenuPopup;
	    ICFGetPos : function(d1,d2: pointer; d3,d4,d5: longint; fn: integer; px,py,pb,ph: pointer): integer;

	begin
		p:=EventList;
		while p<>nil do
			begin
				if p^.TestButton(data.mX,data.mY,data.BStat,data.KStat,data.Clicks) then exit;
				p:=p^.Next
			end;
		if allicn then pw:=nil
		else
			pw:=GetGPWindow(wind_find(data.mX,data.mY));
		if pw<>nil then
			with pw^ do
				if IsIconified then
					begin
						if (data.BStat=2) and (data.Clicks=2) then Top
						else
							if (data.BStat=1) and (icfpos>=0) then with icfcurr do WMUniconify(X,Y,W,H)
							else
								goto _handle
					end
				else
					begin
						p:=EventList;
						while p<>nil do
							begin
								if p^.TestButton(data.mX,data.mY,data.BStat,data.KStat,data.Clicks) then exit;
								p:=p^.Next
							end;
						GRtoA2(Work);
						if (data.mX>=Work.X1) and (data.mX<=Work.X2) and (data.mY>=Work.Y1) and (data.mY<=Work.Y2) then
							WMButton(data.mX,data.mY,data.BStat,data.KStat,data.Clicks)
						else
							if (Class.ToolbarTree<>nil) or (Class.MenuTree<>nil) then
								begin
									wind_get(Attr.gemHandle,WF_WORKXYWH,rx,ry,rw,rh);
									if (data.mX>=rx) and (data.mX<rx+rw) and (data.mY>=ry) and (data.mY<ry+rh) then
										begin
											if (data.BStat=2) and (data.Clicks=2) then Top
											else
												begin
													tbi:=objc_find(Class.ToolbarTree,ROOT,MAX_DEPTH,data.mX,data.mY);
													if tbi>ROOT then WMToolbar(tbi,data.BStat,data.KStat,data.Clicks)
													else
														if data.BStat=1 then
															begin
																tbi:=objc_find(Class.MenuTree,Class.MenuTree^[ROOT].ob_head,MAX_DEPTH,data.mX,data.mY);
																pdx:=tbi-Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[ROOT].ob_head].ob_head].ob_head;
																if pdx<0 then Top
																else
																	begin
																		wind_update(BEG_UPDATE);
																		wind_update(BEG_MCTRL);
																		_menu:
																		TitleSelect(pw,tbi,true);
																		rh:=Class.MenuTree^[Class.MenuTree^[ROOT].ob_tail].ob_head;
																		while pdx>0 do
																			begin
																				rh:=Class.MenuTree^[rh].ob_next;
																				dec(pdx)
																			end;
																		new(ppop,Init(pw,id_No,rh,id_No));
																		pdx:=id_No;
																		if ppop<>nil then
																			with ppop^ do
																				begin
																					SetPopTree(Class.MenuTree);
																					objc_offset(PopTree,tbi,pX,pY);
																					pY:=PopTree^[PopTree^[ROOT].ob_head].ob_height+ry+1;
																					if PopTree^[pIndex].ob_height+pY>Application^.Attr.MaxPY then pY:=ry-PopTree^[pIndex].ob_height-1;
																					Shadow:=false;
																					lfrtcrs:=false;
																					wait0:=false;
																					pdx:=Execute;
																					Free
																				end;
																		if pdx>=10000 then
																			begin
																				TitleSelect(pw,tbi,false);
																				dec(pdx,10000);
																				tbi:=pdx+Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[ROOT].ob_head].ob_head].ob_head;
																				goto _menu
																			end;
																		if pdx<0 then TitleSelect(pw,tbi,false);
																		repeat
																			graf_mkstate(rx,rx,rw,rx)
																		until rw=0;
																		wind_update(END_MCTRL);
																		if pdx>=0 then
																			begin
																				inc(pdx,Class.MenuTree^[rh].ob_head);
																				if tunemenu then
																					begin
																						q:=Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[Class.MenuTree^[ROOT].ob_tail].ob_head].ob_head].ob_next].ob_next;
																						if pdx=q then
																							begin
																								data.Key:=Ctrl_Cycle;
																								data.KStat:=K_CTRL;
																								MUKeybd(data);
																								goto _noentry
																							end;
																						q:=Class.MenuTree^[q].ob_next;
																						if pdx=q then
																							begin
																								WMFulled;
																								goto _noentry
																							end;
																						q:=Class.MenuTree^[q].ob_next;
																						if pdx=q then
																							begin
																								if icfserver<>nil then
																									begin
																										ICFGetPos:=icfserver;
																										icfpos:=ICFGetPos(nil,nil,0,0,0,ICF_GETPOS,@rx,@ry,@rw,@rh);
																										if icfpos>=0 then WMIconify(rx,ry,rw,rh)
																									end;
																								goto _noentry
																							end;
																						q:=Class.MenuTree^[q].ob_next;
																						if pdx=q then
																							begin
																								WMBottomed;
																								goto _noentry
																							end
																					end;
																				MNSelected(pdx,tbi,Class.MenuTree,rh);
																				_noentry:
																				TitleSelect(pw,tbi,false)
																			end;
																		wind_update(END_UPDATE)
																	end
															end
												end
										end
									else
										goto _desktop
								end
							else
								goto _desktop
					end
		else
			begin
				_desktop:
				if (data.BStat=1) and (data.Clicks=1) and bTst(Attr.Style,as_Rubbox) then
					begin
						if (data.mX>=SysInfo.Desktop.X1) and (data.mX<=SysInfo.Desktop.X2) and (data.mY>=SysInfo.Desktop.Y1) and (data.mY<=SysInfo.Desktop.Y2) then
							begin
								if (data.KStat and K_SHIFT)>0 then IconSelect(false,DESK)
								else
									IconSelect(false,id_No);
								if Rubbox(DESK,data.mX,data.mY,SysInfo.Desktop.X1,SysInfo.Desktop.Y1,SysInfo.Desktop.X2,SysInfo.Desktop.Y2,true,r) then MURubbox(r)
							end
					end
				else
					_handle:
					HandleButton(data.mX,data.mY,data.BStat,data.KStat,data.Clicks)
			end
	end;


procedure TApplication.MURubbox(r: GRECT);

	begin
	end;


procedure TApplication.MURBoxChanged(r: GRECT);

	begin
	end;


procedure TApplication.MUM1(data: TEventData);
	var p         : PEvent;
	    pw        : PWindow;
	    found     : boolean;

	begin
		found:=false;
		p:=EventList;
		while (p<>nil) and not(found) do
			with p^ do
				begin
					found:=TestMouse(MU_M1,data.mX,data.mY,data.BStat,data.KStat);
					p:=Nxt
				end;
		if not(found) and not(allicn) then
			begin
				pw:=GetPTopWindow;
				if pw<>nil then
					if not(pw^.IsIconified) then
						begin
							p:=pw^.EventList;
							while (p<>nil) and not(found) do
								with p^ do
									begin
										found:=TestMouse(MU_M1,data.mX,data.mY,data.BStat,data.KStat);
										p:=Nxt
									end
						end
			end;
		if not(found) then HandleM1(data.mX,data.mY,data.BStat,data.KStat)
	end;


function TApplication.ReadExtMessage(Pipe: Pipearray): boolean;

	begin
		ReadExtMessage:=false
	end;


procedure TApplication.MUM2(data: TEventData);
	var p         : PEvent;
	    pw        : PWindow;
	    found     : boolean;

	begin
		found:=false;
		p:=EventList;
		while (p<>nil) and not(found) do
			with p^ do
				begin
					found:=TestMouse(MU_M2,data.mX,data.mY,data.BStat,data.KStat);
					p:=Nxt
				end;
		if not(found) and not(allicn) then
			begin
				pw:=GetPTopWindow;
				if pw<>nil then
					if not(pw^.IsIconified) then
						begin
							p:=pw^.EventList;
							while (p<>nil) and not(found) do
								with p^ do
									begin
										found:=TestMouse(MU_M2,data.mX,data.mY,data.BStat,data.KStat);
										p:=Nxt
									end
						end
			end;
		if not(found) then HandleM2(data.mX,data.mY,data.BStat,data.KStat)
	end;


procedure TApplication.MUMesag(data: TEventData);
	label _notop,_fsende;

	var p,pw        : PWindow;
	    pg          : PEvent;
	    found,pkrn  : boolean;
	    ret,dummy,ks,
	    rx,ry,rw,rh : integer;
	    fx31        : fix31;
	    slen        : longint;
	    pc,pc2,pc3,
	    ps,pc4      : PChar;
			ICFGetPos   : function(d1,d2: pointer; d3,d4,d5: longint; fn: integer; px,py,pw,ph: pointer): integer;

	procedure shwr_ap_tfail(err: integer);
		var pipe: Pipearray;

		begin
			pipe[0]:=AP_TFAIL;
			pipe[1]:=err;
			with AES_pb do
				begin
					control^[0]:=121;
					control^[1]:=3;
					control^[2]:=1;
					control^[3]:=2;
					control^[4]:=0;
					intin^[0]:=10;
					intin^[1]:=0;
					intin^[2]:=0;
					addrin^[0]:=@pipe;
					addrin^[1]:=nil
				end;
			_crystal(@AES_pb)
		end;

	procedure xaccreply(used: boolean);
		var pipe: Pipearray;

		begin
			pipe[0]:=ACC_ACK;
			pipe[1]:=apID;
			pipe[2]:=0;
			if used then pipe[3]:=1
			else
				pipe[3]:=0;
			appl_write(data.Pipe[1],16,@pipe)
		end;

	procedure goversionreply;
		var pipe: Pipearray;

		begin
			pipe[0]:=GO_PRIVATE;
			pipe[1]:=apID;
			pipe[2]:=0;
			pipe[3]:=GOP_VERSION;
			pipe[4]:=GOVersion;
			pipe[5]:=0;
			pipe[6]:=0;
			pipe[7]:=0;
			appl_write(data.Pipe[1],16,@pipe)
		end;

	procedure olgareply(msg: integer);
		var pipe: Pipearray;
		    q   : integer;

		begin
			pipe[0]:=msg;
			pipe[1]:=apID;
			pipe[2]:=0;
			for q:=3 to 7 do pipe[q]:=data.Pipe[q];
			appl_write(data.Pipe[1],16,@pipe)
		end;

	procedure ackolga(msg: integer);
		var pipe: Pipearray;
		    q   : integer;

		begin
			pipe[0]:=OLGA_ACK;
			pipe[1]:=apID;
			pipe[2]:=0;
			pipe[7]:=msg;
			for q:=3 to 6 do pipe[q]:=data.Pipe[q];
			appl_write(data.Pipe[1],16,@pipe)
		end;
	
	procedure idlereply;
		var pipe: Pipearray;
	
		begin
			pipe[0]:=OLGA_IDLE;
			pipe[1]:=apID;
			pipe[2]:=0;
			pipe[3]:=0;
			pipe[4]:=data.Pipe[4];
			pipe[5]:=data.Pipe[5];
			pipe[6]:=data.Pipe[6];
			pipe[7]:=data.Pipe[7];
			appl_write(data.Pipe[1],16,@pipe)
		end;

	procedure avstarted(oid,p3,p4: integer);
		var pipe: Pipearray;

		begin
			pipe[0]:=AV_STARTED;
			pipe[1]:=apID;
			pipe[2]:=0;
			pipe[3]:=p3;
			pipe[4]:=p4;
			pipe[5]:=0;
			pipe[6]:=0;
			pipe[7]:=0;
			appl_write(oid,16,@pipe)
		end;

	procedure fontack(ret: boolean);
		var pipe: Pipearray;

		begin
			pipe[0]:=FONT_ACK;
			pipe[1]:=apID;
			pipe[2]:=0;
			if ret then pipe[3]:=1
			else
				pipe[3]:=0;
			pipe[4]:=0;
			pipe[5]:=0;
			pipe[6]:=0;
			pipe[7]:=0;
			appl_write(data.Pipe[1],16,@pipe)
		end;

	procedure testexist(pfn: PChar);
		var fname: string;

		begin
			fname:=GetQuotedName(pfn);
			if length(fname)=0 then exit;
			if not(Exist(fname)) then
				begin
					fname:=GetFilename(fname,true);
					if length(fname)=0 then exit;
					if Attr.Country=FRA then
						Alert(nil,1,NOTE,'"'+fname+'" n''existe pas.','  &OK  ')
					else if (Attr.Country=FRG) or (Attr.Country=SWG) then
						Alert(nil,1,NOTE,'"'+fname+'" existiert nicht.','  &OK  ')
					else
						Alert(nil,1,NOTE,'"'+fname+'" does not exist.','  &OK  ')
				end
			else
				begin
					if pc4<>pc2 then
						begin
							pc4^:=' ';
							inc(longint(pc4))
						end;
					pc4:=StrECopy(pc4,pc3)
				end
		end;

	begin
		wind_update(BEG_UPDATE);
		if MessageBuffer<>nil then
			begin
				freemem(MessageBuffer,MessageBLen);
				MessageBuffer:=nil
			end;
		MessageBLen:=data.Pipe[2];
		if MessageBLen<>0 then
			begin
				if MessageBLen<0 then MessageBLen:=0
				else
					if ReadExtMessage(data.Pipe) then
						begin
							getmem(MessageBuffer,MessageBLen);
							if MessageBuffer<>nil then appl_read(apID,MessageBLen,MessageBuffer)
							else
								MessageBLen:=0
						end
					else
						MessageBLen:=0
			end;
		case data.Pipe[0] of
		MN_SELECTED:
			if agi.ExtMnSelect then
				MNSelected(data.Pipe[4],data.Pipe[3],Ptr(word(data.Pipe[5]),word(data.Pipe[6])),data.Pipe[7])
			else
				MNSelected(data.Pipe[4],data.Pipe[3],nil,0);
		WM_REDRAW:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMRedraw(data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
			end;
		WM_TOPPED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then
					begin
						if p^.IsIconified then
							if p^.icfpos>=0 then
								begin
									with p^.icfcurr do p^.WMUniconify(X,Y,W,H);
									goto _notop
								end;
						if bTst(p^.Class.Style,cs_WorkBackground) then
							if not(agi.BEvent) then
								begin
									graf_mkstate(data.mX,data.mY,dummy,data.KStat);
									wind_get(p^.Attr.gemHandle,WF_WORKXYWH,rx,ry,rw,rh);
									if Between(data.mX,rx,rx+rw-1) and Between(data.mY,ry,ry+rh-1) then
										begin
											data.BStat:=1;
											data.Clicks:=1;
											MUButton(data);
											goto _notop
										end
								end;
						p^.WMTopped;
						_notop:
					end
			end;
		WM_CLOSED:
			begin
				graf_mkstate(dummy,dummy,dummy,ks);
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then
					begin
						if (ks and (K_SHIFT or K_ALT or K_CTRL))<>0 then
							begin
								if bTst(ks,K_ALT) and (icfserver<>nil) and not(p^.IsIconified) then
									begin
										ICFGetPos:=icfserver;
										p^.icfpos:=ICFGetPos(nil,nil,0,0,0,ICF_GETPOS,@data.Pipe[4],@data.Pipe[5],@data.Pipe[6],@data.Pipe[7]);
										if p^.icfpos>=0 then p^.WMIconify(data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
									end
							end
						else
							begin
								dummy:=p^.Attr.Style;
								if p^.IsIconified then
									if p^.icfpos>=0 then dummy:=p^.icfstyle;
								if bTst(dummy,CLOSER) then p^.WMClosed
							end
					end
			end;
		WM_FULLED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMFulled
			end;
		WM_ARROWED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then
					begin
						if data.Pipe[5]>=0 then data.Pipe[5]:=-1;
						if data.Pipe[7]>=0 then
							begin
								data.Pipe[6]:=0;
								data.Pipe[7]:=0
							end;
						p^.WMArrowed(data.Pipe[4],-data.Pipe[5],data.Pipe[6],-data.Pipe[7])
					end
			end;
		WM_HSLID:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMHSlid(data.Pipe[4])
			end;
		WM_VSLID:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMVSlid(data.Pipe[4])
			end;
		WM_SIZED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMSized(data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
			end;
		WM_MOVED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMMoved(data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
			end;
		WM_NEWTOP:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMNewTop
			end;
		WM_UNTOPPED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMUntopped
			end;
		WM_ONTOP:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMOnTop
			end;
		WM_SHADED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMShaded
			end;
		WM_UNSHADED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMUnshaded
			end;
		WM_BOTTOMED,WM_M_BDROPPED:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.WMBottomed
			end;
		WM_ICONIFY:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then
					if not(p^.IsIconified) then
						p^.WMIconify(data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
			end;
		WM_UNICONIFY:
			if allicn then
				begin
					allicn:=false;
					ForEachWnd(@IconifyFadein);
					icnwnd^.Free;
					Icon:=nil
				end
			else
				begin
					p:=GetGPWindow(data.Pipe[3]);
					if p<>nil then p^.WMUniconify(data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
				end;
		WM_ALLICONIFY:
			begin
				icnwnd:=new(PIcnWnd,Init(nil,StrPLeft(StrPTrimF(GetIconTitle),10),data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7]));
				allicn:=true;
				ForEachWnd(@IconifyFadeout)
			end;
		WM_PRINT:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.Print
			end;
		WM_CUT:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.Cut
			end;
		WM_COPY:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.Copy
			end;
		WM_PASTE:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.Paste
			end;
		WM_DELETE:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.Delete
			end;
		WM_SELECTALL:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.SelectAll
			end;
		AC_OPEN:
			ACOpen(data.Pipe[4]);
		AC_CLOSE:
			if MultiTOS then
				begin
					ret:=ACClose(data.Pipe[3],data.Pipe[5]);
					if ret<>em_OK then shwr_ap_tfail(ret)
					else
						if not(CanClose) then shwr_ap_tfail(-1)
				end
			else
				ACClose(data.Pipe[3],AC_CLOSE);
		AP_TERM:
			begin
				ret:=APTerm(data.Pipe[5]);
				if ret<>em_OK then shwr_ap_tfail(ret)
				else
					if CanClose then Status:=em_Terminate
					else
						shwr_ap_tfail(-1)
			end;
		AP_DRAGDROP:
			APDragDrop(data.Pipe[7],data.Pipe[1],data.Pipe[3],data.Pipe[4],data.Pipe[5],data.Pipe[6]);
		SHUT_COMPLETED:
			ShutCompleted(data.Pipe[3],data.Pipe[4],data.Pipe[5]);
		RESCH_COMPLETED:
			ResChCompleted(data.Pipe[3]);
		CH_EXIT:
			CHExit(data.Pipe[3],data.Pipe[4]);
		SH_WDRAW:
			SHWDraw(data.Pipe[3]);
		WinChangeFont:
			begin
				p:=GetGPWindow(data.Pipe[3]);
				if p<>nil then p^.FontChanged(data.Pipe[1],data.Pipe[4],data.Pipe[5],data.Pipe[6],-1,data.Pipe[7],-1,-32768,-1,-1,0,0,0,false,false)
			end;
		XFONT_CHANGED:
			xfont:=data.Pipe;
		FONT_CHANGED:
			begin
				found:=false;
				if data.Pipe[1]<>xfont[1] then
					begin
						xfont[3]:=0;
						xfont[4]:=0;
						xfont[5]:=-1;
						xfont[6]:=-32768;
						xfont[7]:=0
					end;
				pkrn:=bTst(word(xfont[7]),32768);
				fx31:=fix31(Ptr(word(xfont[3]),word(xfont[4])));
				if data.Pipe[3]<0 then
					begin
				  	p:=MainWindow;
				  	while p<>nil do
			  			with p^ do
				  			begin
									if FontChanged(data.Pipe[1],data.Pipe[4],data.Pipe[5],data.Pipe[6],-1,data.Pipe[7],xfont[5],xfont[6],-1,-1,xfont[7] and $1fff,(xfont[7] shr 13) and $0003,fx31,pkrn,true) then found:=true;
			  					p:=Nxt
				  			end
					end
				else
					begin
						p:=GetGPWindow(data.Pipe[3]);
						if p<>nil then
							if p^.FontChanged(data.Pipe[1],data.Pipe[4],data.Pipe[5],data.Pipe[6],-1,data.Pipe[7],xfont[5],xfont[6],-1,-1,xfont[7] and $1fff,(xfont[7] shr 13) and $0003,fx31,pkrn,false) then found:=true
					end;
				fontack(found);
				xfont[1]:=-1
			end;
		FILE_SELECTED:
			begin
				dummy:=(data.Pipe[3] shr 8) and $007f;
				if (dummy<0) or (dummy>XSELMAX+1) then dummy:=XSELMAX+1;
				if (data.Pipe[6]<>0) or (data.Pipe[7]<>0) then
					begin
						slen:=StrLen(PChar(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))))+1;
						getmem(pc,slen);
						if pc<>nil then
							begin
								StrCopy(pc,PChar(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))));
								if bTst(word(data.Pipe[3]),32768) then
									begin
										getmem(pc2,slen);
										if pc2=nil then goto _fsende;
										pc3:=pc;
										pc4:=pc2;
										ps:=StrScanQuote(pc3);
										while ps<>nil do
											begin
												ps^:=#0;
												testexist(pc3);
												pc3:=PChar(longint(ps)+1);
												ps:=StrScanQuote(pc3)
											end;
										testexist(pc3);
										if pc4=pc2 then goto _fsende;
										pc3:=pc2
									end
								else
									begin
										pc2:=nil;
										pc3:=pc
									end;
								FileSelected(xselwind[dummy].window,data.Pipe[1],byte(data.Pipe[3] and $00ff),StrPPas(Ptr(word(data.Pipe[4]),word(data.Pipe[5]))),pc3);
								_fsende:
								if pc2<>nil then freemem(pc2,slen);
								freemem(pc,slen)
							end
					end;
				xselwind[dummy].window:=nil
			end;
		SC_CHANGED:
			SCChanged(data.Pipe[1],word(data.Pipe[3]),StrPTrimF(chr((word(data.Pipe[4]) shr 8) and $00ff)+chr(data.Pipe[4] and $00ff)+chr((word(data.Pipe[5]) shr 8) and $00ff)+chr(data.Pipe[5] and $00ff)));
		PRN_CHANGED:
			PRNChanged(data.Pipe[1],data.Pipe[3],data.Pipe[4]);
		FNT_CHANGED:
			FNTChanged(data.Pipe[1]);
		COLORS_CHANGED:
			ColorsChanged(data.Pipe[1]);
		COLOR_ID:
			ColorID(data.Pipe[1],data.Pipe[3],data.Pipe[4],data.Pipe[5]);
		ACC_ID:
			XAccID(data.Pipe[1],data.Pipe[6],byte(data.Pipe[3] and $00ff),byte((data.Pipe[3] and $ff00) shr 8),Ptr(word(data.Pipe[4]),word(data.Pipe[5])));
		ACC_ACC:
			if agi.MultiProto then XAccAcc(data.Pipe[1],data.Pipe[6],byte(data.Pipe[3] and $00ff),byte((data.Pipe[3] and $ff00) shr 8),Ptr(word(data.Pipe[4]),word(data.Pipe[5])))
			else
				XAccAcc(data.Pipe[7],data.Pipe[6],byte(data.Pipe[3] and $00ff),byte((data.Pipe[3] and $ff00) shr 8),Ptr(word(data.Pipe[4]),word(data.Pipe[5])));
		ACC_EXIT:
			XAccExit(data.Pipe[1]);
		ACC_TEXT:
			xaccreply(XAccText(data.Pipe[1],Ptr(word(data.Pipe[4]),word(data.Pipe[5]))));
		ACC_KEY:
			xaccreply(XAccKey(data.Pipe[1],data.Pipe[4],data.Pipe[3]));
		ACC_META:
			xaccreply(XAccMeta(data.Pipe[1],Ptr(word(data.Pipe[4]),word(data.Pipe[5])),longint(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))),data.Pipe[3]=1));
		ACC_IMG:
			xaccreply(XAccIMG(data.Pipe[1],Ptr(word(data.Pipe[4]),word(data.Pipe[5])),longint(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))),data.Pipe[3]=1));
		ACC_OPEN,ACC_CLOSE,ACC_ACK:
			HandleXAcc(data.Pipe);
		AV_PROTOKOLL:
			AVProtokoll(data.Pipe[1],word(data.Pipe[3]),StrPPas(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))));
		VA_PROTOSTATUS:
			VAProtoStatus(data.Pipe[1],word(data.Pipe[3]),StrPPas(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))));
		AV_SENDKEY:
			AVSendKey(data.Pipe[3],data.Pipe[4]);
		AV_SENDCLICK:
			AVSendClick(data.Pipe[3],data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7]);
		VA_START:
			begin
				VAStart(data.Pipe[1],Ptr(word(data.Pipe[3]),word(data.Pipe[4])));
				avstarted(data.Pipe[1],data.Pipe[3],data.Pipe[4])
			end;
		AV_STARTPROG:
			if AppFlag then
				AVStartProg(data.Pipe[1],data.Pipe[7],StrPPas(Ptr(word(data.Pipe[3]),word(data.Pipe[4]))),StrPPas(Ptr(word(data.Pipe[5]),word(data.Pipe[6]))));
		AV_EXIT:
			AVExit(data.Pipe[3]);
		AV_GETSTATUS..VA_SETSTATUS,AV_ASKFILEFONT..VA_WINDOPEN,VA_PROGSTART..VA_DRAG_COMPLETE,AV_STARTED..VA_XOPEN:
			HandleAV(data.Pipe);
		BUBBLEGEM_REQUEST:
			begin
				if DlgTop<0 then
					begin
						p:=GetGPWindow(data.Pipe[3]);
						if p<>nil then
							if p^.Attr.Status=ws_Open then
								if p^.Attr.gemHandle>=0 then
									if not(p^.IsShaded) then
										if p^.IsHelpAvailable(data.Pipe[4],data.Pipe[5]) then
											BubbleHelp(data.Pipe[4],data.Pipe[5],p^.GetHelp(data.Pipe[4],data.Pipe[5]),false,true)
					end
			end;
		GO_PRIVATE:
			case data.Pipe[3] of
			GOP_SETQUIT:
				if pquit<>nil then
					with PQKey(pquit)^ do
						begin
							VMNum:=data.Pipe[4];
							VTNum:=data.Pipe[5]
						end;
			GOP_RELEASEBUTTON:
				begin
					wind_update(BEG_MCTRL);
					repeat
						graf_mkstate(dummy,dummy,ks,dummy)
					until (ks and data.Pipe[4])=0;
					wind_update(END_MCTRL)
				end;
			GOP_GETVERSION:
				goversionreply
			else
				HandleMesag(data.Pipe)
			end
		else
			begin
				if bTst(Attr.Style,as_OLGA) then
					begin
						found:=true;
						case data.Pipe[0] of
						OLGA_UPDATED:
							OLGAUpdated(data.Pipe[1],data.Pipe[6],data.Pipe[5],data.Pipe[7],StrPPas(Ptr(word(data.Pipe[3]),word(data.Pipe[4]))));
						OLGA_GETINFO:
							OLGAGetInfo(data.Pipe[1],data.Pipe[5]);
						OLGA_INFO:
							begin
								OLGAInfo(data.Pipe[1],data.Pipe[5],StrPPas(Ptr(word(data.Pipe[3]),word(data.Pipe[4]))));
								ackolga(OLGA_INFO)
							end;
						OLGA_LINKBROKEN:
							begin
								OLGALinkBroken(data.Pipe[1],data.Pipe[5],StrPPas(Ptr(word(data.Pipe[3]),word(data.Pipe[4]))));
								olgareply(OLGA_UNLINK)
							end;
						OLGA_RENAMELINK:
							begin
								OLGARenameLink(data.Pipe[1],data.Pipe[7],StrPPas(Ptr(word(data.Pipe[3]),word(data.Pipe[4]))),StrPPas(Ptr(word(data.Pipe[5]),word(data.Pipe[6]))));
								olgareply(OLGA_LINKRENAMED)
							end;
						OLGA_ACK:
							OLGAAck(data.Pipe);
						OLGA_OBJECTS:
							OLGAObjects(data.Pipe[1],data.pipe[3],
													StrPTrimF(chr((word(data.Pipe[4]) shr 8) and $00ff)+chr(data.Pipe[4] and $00ff)+chr((word(data.Pipe[5]) shr 8) and $00ff)+chr(data.Pipe[5] and $00ff)),
													StrPPas(Ptr(word(data.Pipe[6]),word(data.Pipe[7]))));
						OLGA_IDLE:
							begin
								if data.Pipe[3]<>0 then idlereply
								else
									OLGAIdle(data.Pipe[1],data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
							end;
						OLGA_INIT:
							OLGAInit(data.Pipe[1],data.Pipe[3],data.Pipe[4],data.Pipe[7]);
						OLE_EXIT:
							OLEExit(data.Pipe[1]);
						OLE_NEW:
							OLENew(data.Pipe[1],data.Pipe[3],data.Pipe[4],data.Pipe[5],data.Pipe[6],data.Pipe[7])
						else
							found:=false
						end
					end
				else
					found:=false;
				if not(found) then
					begin
						pg:=EventList;
						while (pg<>nil) and not(found) do
							with pg^ do
								begin
									found:=TestMessage(data.Pipe);
									pg:=Nxt
								end
					end;
				if not(found) and not(allicn) then
					begin
						pw:=GetPTopWindow;
						if pw<>nil then
							begin
								pg:=pw^.EventList;
								while (pg<>nil) and not(found) do
									with pg^ do
										begin
											found:=TestMessage(data.Pipe);
											pg:=Nxt
										end
							end
					end;
				if not(found) then HandleMesag(data.Pipe)
			end
		end;
		wind_update(END_UPDATE)
	end;


procedure TApplication.MUTimer(data: TEventData);

	begin
		HandleTimer
	end;


procedure TApplication.MNSelected(meNum,mtNum: integer; Tree: PTree; PrIndx: integer);
	label _fertig;

	var p         : PEvent;
	    pw        : PWindow;
	    found     : boolean;
	    ted       : TEventData;

	begin
		if MenuTree<>nil then
			if mtNum>ROOT then menu_tnormal(MenuTree,mtNum,ME_INVERT);
		found:=false;
		if Tree<>nil then
			if Tree<>MenuTree then
				begin
					p:=EventList;
					while (p<>nil) and not(found) do
						begin
							if bTst(p^.Style,es_SubMenu) then
								with PSubMenu(p)^ do
									if Tree=Popup^.PopTree then
										begin
											HandleMenu(meNum-Tree^[Popup^.pStart].ob_head);
											found:=true
										end;
							p:=p^.Nxt
						end;
					if not(found) then
						begin
							pw:=GetPTopWindow;
							if pw<>nil then
								if pw^.Class.MenuTree=nil then
									begin
										p:=pw^.EventList;
										while (p<>nil) and not(found) do
											begin
												if bTst(p^.Style,es_SubMenu) then
													with PSubMenu(p)^ do
														if Tree=Popup^.PopTree then
															begin
																HandleMenu(meNum-Tree^[Popup^.pStart].ob_head);
																found:=true
															end;
												p:=p^.Nxt
											end
									end
						end;
					goto _fertig
				end;
		p:=EventList;
		while (p<>nil) and not(found) do
			with p^ do
				begin
					found:=TestMenu(meNum);
					p:=Nxt
				end;
		if not(found) then
			if menuentries<>nil then
				with menuentries^ do
					begin
						if meNum=Close.Entry then
							begin
								ted.pipe[0]:=WM_CLOSED;
								SendWndMessage(-1,@ted.pipe,true,true);
								goto _fertig
							end;
						if meNum=Print.Entry then
							begin
								ted.pipe[0]:=WM_PRINT;
								found:=true
							end;
						if meNum=Cut.Entry then
							begin
								ted.pipe[0]:=WM_CUT;
								found:=true
							end;
						if meNum=Copy.Entry then
							begin
								ted.pipe[0]:=WM_COPY;
								found:=true
							end;
						if meNum=Paste.Entry then
							begin
								ted.pipe[0]:=WM_PASTE;
								found:=true
							end;
						if meNum=Delete.Entry then
							begin
								ted.pipe[0]:=WM_DELETE;
								found:=true
							end;
						if meNum=SelectAll.Entry then
							begin
								ted.pipe[0]:=WM_SELECTALL;
								found:=true
							end;
						if meNum=Full.Entry then
							begin
								ted.pipe[0]:=WM_FULLED;
								found:=true
							end;
						if found then SendWndMessage(-1,@ted.pipe,true,false)
						else
							if meNum=Cycle.Entry then
								begin
									ted.Key:=Ctrl_Cycle;
									ted.KStat:=K_CTRL;
									MUKeybd(ted);
									goto _fertig
								end
					end;
		if not(found) then
			begin
				pw:=GetPTopWindow;
				if pw<>nil then
					if pw^.Class.MenuTree=nil then
						begin
							p:=pw^.EventList;
							while (p<>nil) and not(found) do
								with p^ do
									begin
										found:=TestMenu(meNum);
										p:=Nxt
									end
						end
			end;
		if not(found) then HandleMenu(meNum);
		_fertig:
		if MenuTree<>nil then
			if mtNum>ROOT then menu_tnormal(MenuTree,mtNum,ME_NORMAL)
	end;


procedure TApplication.ACOpen(mID: integer);
	var p: PWindow;

	begin
		if mID=menuID then
			begin
				ChkError;
				p:=MainWindow;
				while (p<>nil) do
					with p^ do
						begin
							if bTst(Class.Style,cs_CreateOnAccOpen) then Create;
							OpenWindow;
							if IsDialog then
								if (PDialog(p)^.IsModal) and (Err>=em_OutOfMemory) then PDialog(p)^.Execute;
							p:=Nxt
						end;
				if Err<em_OutOfMemory then Error(Err)
			end
	end;


function TApplication.ACClose(mID,Why: integer): integer;
	var p   : PWindow;
	    pipe: Pipearray;

	begin
		if mID=menuID then
			begin
				p:=MainWindow;
				while (p<>nil) do
					with p^ do
						begin
							RawDestroy;
							p:=Nxt;
						end;
				if not(agi.MultiProto) then
					begin
						if XAccList<>nil then dispose(PXAccCollection(XAccList),Done);
						AVServer:=id_No;
						XAccList:=nil;
						pipe[0]:=ACC_ID;
						pipe[1]:=apID;
						pipe[2]:=0;
						pipe[3]:=integer((XAcc.Version shl 8)+XAcc.MsgGroups);
						pipe[4]:=integer(HiWord(xaccname));
						pipe[5]:=integer(LoWord(xaccname));
						pipe[6]:=menuID;
						pipe[7]:=0;
						appl_write(DESK,16,@pipe);
						pipe[0]:=AV_PROTOKOLL;
						pipe[1]:=apID;
						pipe[2]:=0;
						pipe[3]:=integer(XAcc.AVAccMsg);
						pipe[4]:=0;
						pipe[5]:=0;
						pipe[6]:=integer((longint(apName)+1) div 65536);
						pipe[7]:=integer((longint(apName)+1) mod 65536);
						appl_write(DESK,16,@pipe)
					end
			end;
		ACClose:=em_OK
	end;


function TApplication.APTerm(Why: integer): integer;

	begin
		APTerm:=em_OK
	end;


procedure TApplication.APDragDrop(PipeID,OrgID,WindID,mX,mY,KStat: integer);
	label _error;

	var ddp   : PWindow;
	    oldsig: pointer;
	    pname : string[19];
	    res   : longint;

	begin
		ddokflag:=false;
		wind_update(END_UPDATE);
		ddp:=GetGPWindow(WindID);
		pname:='U:\PIPE\DRAGDROP.'+chr((PipeID and $ff00) shr 8)+chr(PipeID and $00ff);
		res:=fopen(pname,FO_RW);
		if res<0 then goto _error;
		oldsig:=Psignal(SIGPIPE,SIG_IGN);
		if ddp=nil then HandleDragDrop(integer(res),OrgID,WindID,mX,mY,KStat)
		else
			ddp^.WMDragDrop(integer(res),OrgID,mX,mY,KStat);
		if longint(oldsig)>0 then Psignal(SIGPIPE,oldsig);
		fclose(integer(res));
		_error:
		evnt_timer(20,0);
		wind_update(BEG_UPDATE);
		if ddokflag then
			begin
				if ddp=nil then DDFinished(OrgID,WindID,mX,mY,KStat)
				else
					ddp^.DDFinished(OrgID,mX,mY,KStat)
			end
	end;


procedure TApplication.ShutCompleted(Stat,ErrID,ErrCode: integer);

	begin
	end;


procedure TApplication.ResChCompleted(Stat: integer);

	begin
		if Stat=1 then Status:=em_Terminate
	end;


procedure TApplication.CHExit(ChID,ChRet: integer);

	begin
	end;


procedure TApplication.SHWDraw(Drive: integer);

	begin
	end;


procedure TApplication.FileSelected(Window: PWindow; OrgID: integer; Group: byte; Path: string; Files: PChar);

	begin
	end;


procedure TApplication.SCChanged(OrgID: integer; Bits: word; Ext: string);

	begin
	end;


procedure TApplication.PRNChanged(OrgID,Device,Action: integer);

	begin
	end;


procedure TApplication.FNTChanged(OrgID: integer);

	begin
	end;


procedure TApplication.ColorsChanged(OrgID: integer);

	begin
	end;


procedure TApplication.ColorID(OrgID,mX,mY,palIndex: integer);
	var pw: PWindow;

	begin
		pw:=GetGPWindow(wind_find(mX,mY));
		if pw<>nil then pw^.ColorID(OrgID,mX,mY,palIndex)
	end;


procedure TApplication.XAccID(OrgID,mID: integer; Msg,Ver: byte; pName: PChar);
	var pipe: Pipearray;
	    q   : integer;

	begin
		if agi.MultiProto then
			begin
				XAccInsert(OrgID,mID,Msg,Ver,pName);
				pipe[0]:=ACC_ACC;
				pipe[1]:=apID;
				pipe[2]:=0;
				pipe[3]:=integer((XAcc.Version shl 8)+XAcc.MsgGroups);
				pipe[4]:=integer(HiWord(xaccname));
				pipe[5]:=integer(LoWord(xaccname));
				pipe[6]:=menuID;
				pipe[7]:=0;
				appl_write(OrgID,16,@pipe)
			end
		else
			if AppFlag then
				begin
					pipe[0]:=ACC_ID;
					pipe[1]:=apID;
					pipe[2]:=0;
					pipe[3]:=integer((XAcc.Version shl 8)+XAcc.MsgGroups);
					pipe[4]:=integer(HiWord(xaccname));
					pipe[5]:=integer(LoWord(xaccname));
					pipe[6]:=-1;
					pipe[7]:=0;
					appl_write(OrgID,16,@pipe);
					pipe[0]:=ACC_ACC;
					pipe[3]:=integer((Ver shl 8)+Msg);
					pipe[4]:=integer(HiWord(pName));
					pipe[5]:=integer(LoWord(pName));
					pipe[6]:=mID;
					pipe[7]:=OrgID;
					if XAccList<>nil then
						with XAccList^ do
							if Count>0 then
								for q:=0 to Count-1 do
									if At(q)<>nil then
										appl_write(PXAccAttr(At(q))^.apID,16,@pipe);
					XAccInsert(OrgID,mID,Msg,Ver,pName)
				end
			else
				XAccInsert(OrgID,mID,Msg,Ver,pName)
	end;


procedure TApplication.XAccAcc(accID,mID: integer; Msg,Ver: byte; pName: PChar);
	var pipe: Pipearray;

	begin
		XAccInsert(accID,mID,Msg,Ver,pName);
		if not(agi.MultiProto) then
			begin
				pipe[0]:=ACC_ID;
				pipe[1]:=apID;
				pipe[2]:=0;
				pipe[3]:=integer((XAcc.Version shl 8)+XAcc.MsgGroups);
				pipe[4]:=integer(HiWord(xaccname));
				pipe[5]:=integer(LoWord(xaccname));
				pipe[6]:=menuID;
				pipe[7]:=0;
				appl_write(accID,16,@pipe)
			end
	end;


function TApplication.XAccInsert(accID,mID: integer; Msg,Ver: byte; pName: PChar): boolean;
	var pxattr: PXAccAttr;
	    xattr : TXAccAttr;
	    dummy : string;

	begin
		XAccInsert:=false;
		if longint(pName)<=$7fff then exit;
		if FindApplication('',accID,xattr) then
			if bTst(xattr.Protocol,PROTO_XACC) then
				begin
					if xattr.menuID=mID then exit
					else
						lastfa:=-1
				end;
		if XAccList=nil then XAccList:=new(PXAccCollection,Init(5,5));
		if XAccList=nil then exit;
		new(pxattr);
		if pxattr<>nil then
			begin
				with pxattr^ do
					begin
						Version:=Ver;
						MsgGroups:=Msg;
						if lastfa<0 then
							begin
								Protocol:=PROTO_XACC;
								AVSrvMsg:=0;
								AVAccMsg:=0
							end
						else
							begin
								Protocol:=xattr.Protocol or PROTO_XACC;
								AVSrvMsg:=xattr.AVSrvMsg;
								AVAccMsg:=xattr.AVAccMsg
							end;
						apID:=accID;
						menuID:=mID;
						AppTypeMR:='';
						AppTypeHR:=nil;
						ExtFeatures:=nil;
						GenericName:=nil;
						pXDSC:=nil;
						Name:=NewStr(StrPas(pName));
						inc(longint(pName),length(Name^)+1);
						if StrPas(pName)='XDSC' then
							begin
								inc(longint(pName),5);
								pXDSC:=pName;
								dummy:=StrPas(pName);
								while length(dummy)>0 do
									begin
										case dummy[1] of
											'1': AppTypeHR:=NewStr(StrPRight(dummy,length(dummy)-1));
											'2': AppTypeMR:=StrPLeft(StrPRight(dummy,length(dummy)-1),2);
											'X': ExtFeatures:=NewStr(StrPRight(dummy,length(dummy)-1));
											'N': GenericName:=NewStr(StrPRight(dummy,length(dummy)-1))
										end;
										inc(longint(pName),length(dummy)+1);
										dummy:=StrPas(pName)
									end;
								if AppTypeHR=nil then AppTypeHR:=NewStr(XAccMR2HR(AppTypeMR))
							end
					end;
				if lastfa>=0 then XAccList^.AtFree(lastfa);
				XAccList^.Insert(pxattr);
				XAccInsert:=true
			end
	end;


procedure TApplication.XAccExit(OrgID: integer);
	label _again;

	var q: longint;

	begin
		if XAccList<>nil then
			with XAccList^ do
				begin
					_again:
					if Count>0 then
						for q:=0 to Count-1 do
							if At(q)<>nil then
								if PXAccAttr(At(q))^.apID=OrgID then
									begin
										AtFree(q);
										goto _again
									end
				end
	end;


function TApplication.XAccText(OrgID: integer; pText: pointer): boolean;

	begin
		XAccText:=false
	end;


function TApplication.XAccKey(OrgID,Stat,Key: integer): boolean;
	var data: TEventData;

	begin
		data.Key:=Key;
		data.KStat:=Stat;
		MUKeybd(data);
		XAccKey:=true
	end;


function TApplication.XAccMeta(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean;

	begin
		XAccMeta:=false
	end;


function TApplication.XAccIMG(OrgID: integer; pData: pointer; lData: longint; Final: boolean): boolean;

	begin
		XAccIMG:=false
	end;


procedure TApplication.OLEExit(OrgID: integer);

	begin
		OLGAManager:=id_No
	end;


procedure TApplication.OLENew(OrgID,OLGAMsg,OLGAVer,OEP1,OEP2,ManagerVer: integer);
	var pipe: Pipearray;

	begin
		if not(bTst(Attr.Style,as_OLGA)) then exit;
		OLGAManager:=OrgID;
		OLGA.ManagerMsg:=OLGAMsg;
		OLGA.ManagerProtocol:=OLGAVer;
		pipe[0]:=OLE_INIT;
		pipe[1]:=apID;
		pipe[2]:=0;
		pipe[3]:=OLGA.Msg;
		pipe[4]:=OLGA.Protocol;
		pipe[5]:=0;
		pipe[6]:=0;
		with XAcc do
			begin
				if length(AppTypeMR)>0 then pipe[7]:=ord(AppTypeMR[1])
				else
					pipe[7]:=0;
				if length(AppTypeMR)=2 then pipe[7]:=integer((pipe[7] shl 8) or ord(AppTypeMR[2]))
			end;
		appl_write(OrgID,16,@pipe)
	end;


procedure TApplication.OLGAInit(OrgID,Msg,Ver,eFlag: integer);

	begin
		if eFlag=0 then
			begin
				OLGAManager:=id_No;
				OLGA.ManagerMsg:=0;
				OLGA.ManagerProtocol:=0
			end
		else
			if bTst(Msg,OL_MANAGER) then
				if bTst(Attr.Style,as_OLGA) then
					begin
						OLGAManager:=OrgID;
						OLGA.ManagerMsg:=Msg;
						OLGA.ManagerProtocol:=Ver
					end
	end;


procedure TApplication.OLGAUpdated(OrgID,SrvID,InfoNr,Group: integer; Link: string);
	var p: PWindow;

	begin
		p:=GetPWindow(Group);
		if p<>nil then p^.OLGAUpdated(OrgID,SrvID,InfoNr,Link)
	end;


procedure TApplication.OLGAGetInfo(OrgID,InfoNr: integer);

	begin
	end;


procedure TApplication.OLGAInfo(OrgID,InfoNr: integer; InfoFile: string);

	begin
	end;


procedure TApplication.OLGARenameLink(OrgID,Group: integer; OldLink,NewLink: string);
	var p: PWindow;

	begin
		p:=GetPWindow(Group);
		if p<>nil then p^.OLGARenameLink(OrgID,OldLink,NewLink)
	end;


procedure TApplication.OLGALinkBroken(OrgID,Group: integer; Link: string);
	var p: PWindow;

	begin
		p:=GetPWindow(Group);
		if p<>nil then p^.OLGALinkBroken(OrgID,Link)
	end;


procedure TApplication.OLGAAck(Pipe: Pipearray);

	begin
	end;


procedure TApplication.OLGAObjects(OrgID,Rest: integer; Ext,Descr: string);

	begin
	end;


procedure TApplication.OLGAIdle(OrgID,d4,d5,d6,d7: integer);

	begin
	end;


procedure TApplication.AVProtokoll(OrgID: integer; Msg: word; AName: string);
	var pipe: Pipearray;

	begin
		AVInsert(OrgID,0,Msg,AName);
		pipe[0]:=VA_PROTOSTATUS;
		pipe[1]:=apID;
		pipe[2]:=0;
		pipe[3]:=integer(XAcc.AVSrvMsg);
		pipe[4]:=0;
		pipe[5]:=0;
		pipe[6]:=integer((longint(apName)+1) div 65536);
		pipe[7]:=integer((longint(apName)+1) mod 65536);
		appl_write(OrgID,16,@pipe)
	end;


procedure TApplication.VAProtoStatus(OrgID: integer; Msg: word; AName: string);

	begin
		AVServer:=OrgID;
		AVInsert(OrgID,Msg,0,AName)
	end;


function TApplication.AVInsert(accID: integer; SrvMsg,AccMsg: word; AName: string): boolean;
	var pxattr: PXAccAttr;
	    xattr : TXAccAttr;

	begin
		AVInsert:=false;
		if FindApplication('',accID,xattr) then
			if bTst(xattr.Protocol,PROTO_AV) then exit;
		if XAccList=nil then XAccList:=new(PXAccCollection,Init(5,5));
		if XAccList=nil then exit;
		new(pxattr);
		if pxattr<>nil then
			begin
				with pxattr^ do
					begin
						AppTypeHR:=nil;
						ExtFeatures:=nil;
						GenericName:=nil;
						AVSrvMsg:=SrvMsg;
						AVAccMsg:=AccMsg;
						apID:=accID;
						if lastfa<0 then
							begin
								Protocol:=PROTO_AV;
								Version:=0;
								MsgGroups:=0;
								menuID:=-1;
								AppTypeMR:='';
								pXDSC:=nil;
								Name:=NewStr(StrPTrimF(AName))
							end
						else
							begin
								Protocol:=xattr.Protocol or PROTO_AV;
								Version:=xattr.Version;
								MsgGroups:=xattr.MsgGroups;
								menuID:=xattr.menuID;
								AppTypeMR:=xattr.AppTypeMR;
								if xattr.Name<>nil then Name:=NewStr(xattr.Name^)
								else
									Name:=nil;
								if xattr.AppTypeHR<>nil then AppTypeHR:=NewStr(xattr.AppTypeHR^);
								if xattr.GenericName<>nil then GenericName:=NewStr(xattr.GenericName^);
								if xattr.ExtFeatures<>nil then ExtFeatures:=NewStr(xattr.ExtFeatures^);
								pXDSC:=xattr.pXDSC
							end
					end;
				if lastfa>=0 then XAccList^.AtFree(lastfa);
				XAccList^.Insert(pxattr);
				AVInsert:=true
			end
	end;


procedure TApplication.AVSendKey(Stat,Key: integer);
	var data: TEventData;

	begin
		data.Key:=Key;
		data.KStat:=Stat;
		MUKeybd(data)
	end;


procedure TApplication.AVSendClick(mX,mY,BStat,KStat,Clicks: integer);
	var data: TEventData;

	begin
		data.mX:=mX;
		data.mY:=mY;
		data.BStat:=BStat;
		data.KStat:=KStat;
		data.Clicks:=Clicks;
		MUButton(data)
	end;


procedure TApplication.VAStart(OrgID: integer; Cmd: PChar);

	begin
		DisposeStr(Attr.rpTail);
		if Cmd<>nil then Attr.rpTail:=NewStr(StrPas(Cmd));
		if not(AppFlag) then ACOpen(menuID)
	end;


procedure TApplication.AVStartProg(OrgID,Ret: integer; Prg,Cmd: string);
	var pipe: Pipearray;
	    pex : longint;

	begin
		pipe[0]:=VA_PROGSTART;
		pipe[1]:=apID;
		pipe[2]:=0;
		pipe[3]:=0;
		pipe[4]:=0;
		pipe[7]:=Ret;
		if length(Prg)>0 then
			begin
				pex:=pexec(0,Prg,Cmd,nil);
				if pex>=0 then
					begin
						pipe[3]:=1;
						pipe[4]:=integer(pex and $ffff)
					end
			end;
		appl_write(OrgID,16,@pipe)
	end;


procedure TApplication.AVExit(OrgID: integer);
	label _again;

	var q: longint;

	begin
		if XAccList<>nil then
			with XAccList^ do
				begin
					_again:
					if Count>0 then
						for q:=0 to Count-1 do
							if At(q)<>nil then
								with PXAccAttr(At(q))^ do
									if apID=OrgID then
										if bTst(Protocol,PROTO_AV) then
											begin
												if apID=AVServer then AVServer:=id_No;
												Protocol:=Protocol and not(PROTO_AV);
												if Protocol=0 then AtFree(q)
												else
													begin
														AVSrvMsg:=0;
														AVAccMsg:=0
													end;
												goto _again
											end
				end
	end;


function TApplication.DDGetPreferredTypes(WindID: integer): string;

	begin
		DDGetPreferredTypes:=''
	end;


function TApplication.DDGetPath(WindID: integer): string;

	begin
		DDGetPath:=''
	end;


function TApplication.DDHeaderReply(dType,dName,fName: string; dSize: longint; OrgID,WindID,mX,mY,KStat: integer): byte;

	begin
		DDHeaderReply:=DD_NAK
	end;


function TApplication.DDReadData(dType,dName,fName: string; dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean;

	begin
		DDReadData:=false
	end;


function TApplication.DDReadArgs(dSize: longint; PipeHnd,OrgID,WindID,mX,mY,KStat: integer): boolean;
	var buffer: array [0..127] of byte;

	begin
		DDReadArgs:=false;
		if dSize<=0 then exit;
		while dSize>128 do
			begin
				if fread(PipeHnd,128,@buffer)<>128 then exit;
				dec(dSize,128)
			end;
		fread(PipeHnd,dSize,@buffer)
	end;


procedure TApplication.DDFinished(OrgID,WindID,mX,mY,KStat: integer);

	begin
	end;


function TApplication.StartApp(Path,Cmd: string): integer;
	var dummy,dpath: string;
	    aid,drv,ret: integer;
	    pipe       : Pipearray;

	procedure ShelWrite(mode,wiscr: integer);

		begin
			with AES_pb do
				begin
					control^[0]:=121;
					control^[1]:=3;
					control^[2]:=1;
					control^[3]:=2;
					control^[4]:=0;
					intin^[0]:=mode;
					intin^[1]:=1;
					intin^[2]:=wiscr;
					addrin^[0]:=@Path[1];
					addrin^[1]:=startcmd;
					_crystal(@AES_pb);
					ret:=intout^[0]
				end
		end;

	begin
		StartApp:=-1;
		dummy:=GetFilename(Path,false);
		if length(dummy)=0 then exit;
		ret:=-1;
		dpath:=GetPath(Path)+#0;
		if startcmd<>nil then GlobalFree(startcmd,cmdlen);
		cmdlen:=length(Cmd)+1;
		dummy:=StrPUpper(dummy)+StrPSpace(8-length(dummy));
		aid:=appl_find(dummy);
		if aid>=0 then
			begin
				if length(Cmd)>0 then
					begin
						GlobalAlloc(startcmd,cmdlen);
						if startcmd=nil then exit;
						StrPCopy(startcmd,Cmd)
					end;
				pipe[0]:=VA_START;
				pipe[1]:=apID;
				pipe[2]:=0;
				pipe[3]:=integer(HiWord(startcmd));
				pipe[4]:=integer(LoWord(startcmd));
				pipe[5]:=0;
				pipe[6]:=0;
				pipe[7]:=0;
				appl_write(aid,16,@pipe);
				ret:=aid
			end
		else
			if MultiTOS or MagiCActive then
				begin
					inc(cmdlen);
					GlobalAlloc(startcmd,cmdlen);
					if startcmd=nil then exit;
					PChar(startcmd)^:=char(length(Cmd));
					StrPCopy(PChar(longint(startcmd)+1),Cmd);
					if not(Exist(Path)) then exit;
					drv:=dgetdrv;
					dgetpath(dummy,drv+1);
					if length(Path)>1 then
						if Path[2]=':' then dsetdrv(ord(upcase(Path[1]))-65);
					dsetpath(dpath);
					Path:=Path+#0;
					if MagiCActive then ShelWrite(1,100)
					else
						ShelWrite(0,1);
					if ret<0 then
						begin
							dsetdrv(drv);
							dsetpath(dummy)
						end
				end;
		StartApp:=ret
	end;


procedure TApplication.Cut;

	begin
	end;


procedure TApplication.Copy;

	begin
	end;


procedure TApplication.Paste;

	begin
	end;


procedure TApplication.Delete;

	begin
	end;


procedure TApplication.SelectAll;

	begin
		IconSelect(true,id_No)
	end;


procedure TApplication.HandleDragDrop(PipeHnd,OrgID,WindID,mX,mY,KStat: integer);
	label _readhdr,_prefext;

	var answer           : string;
	    hdrlen,i         : integer;
	    dtype            : string[4];
	    dsize            : longint;
	    dname,ndata,nfile: string[DD_NAMEMAX];

	begin
		answer:=chr(DD_OK);
		if fwrite(PipeHnd,1,@answer[1])<>1 then exit;
		_prefext:
		answer:=StrPLeft(DDGetPreferredTypes(WindID),DD_EXTSIZE);
		while length(answer)<DD_EXTSIZE do answer:=answer+#0;
		if fwrite(PipeHnd,DD_EXTSIZE,@answer[1])<>DD_EXTSIZE then exit;
		_readhdr:
		if fread(PipeHnd,2,@hdrlen)<>2 then exit;
		if hdrlen<9 then exit;
		dtype:='    ';
		if fread(PipeHnd,4,@dtype[1])<>4 then exit;
		if fread(PipeHnd,4,@dsize)<>4 then exit;
		dec(hdrlen,8);
		if hdrlen>DD_NAMEMAX then i:=DD_NAMEMAX
		else
			i:=hdrlen;
		fillchar(dname,sizeof(dname),0);
		if fread(PipeHnd,i,@dname[1])<>i then exit;
		dec(hdrlen,i);
		ndata:='';
		nfile:='';
		i:=1;
		while dname[i]<>#0 do
			begin
				ndata:=ndata+dname[i];
				inc(i)
			end;
		inc(i);
		while dname[i]<>#0 do
			begin
				nfile:=nfile+dname[i];
				inc(i)
			end;
		while hdrlen>DD_NAMEMAX+1 do
			begin
				if fread(PipeHnd,DD_NAMEMAX+1,@dname)<>DD_NAMEMAX+1 then exit;
				dec(hdrlen,DD_NAMEMAX+1)
			end;
		if hdrlen>0 then
			if fread(PipeHnd,hdrlen,@dname)<>hdrlen then exit;
		if dtype='PATH' then
			begin
				answer:=DDGetPath(WindID);
				if length(answer)=0 then answer:=chr(DD_NAK)
				else
					answer:=StrPLeft(chr(DD_OK)+answer,dsize);
				fwrite(PipeHnd,length(answer),@answer[1]);
				exit
			end;
		if dtype='ARGS' then
			begin
				answer:=chr(DD_OK);
				if fwrite(PipeHnd,1,@answer[1])<>1 then exit;
				if dsize>0 then
					if DDReadArgs(dsize,PipeHnd,OrgID,WindID,mX,mY,KStat) then ddokflag:=true;
				exit
			end;
		answer:=chr(DDHeaderReply(dtype,ndata,nfile,dsize,OrgID,WindID,mX,mY,KStat));
		if fwrite(PipeHnd,1,@answer[1])<>1 then exit;
		case ord(answer[1]) of
			DD_OK:  if DDReadData(dtype,ndata,nfile,dsize,PipeHnd,OrgID,WindID,mX,mY,KStat) then ddokflag:=true;
			DD_EXT: goto _readhdr;
			DD_LEN: goto _prefext
		end
	end;


procedure TApplication.HandleKeybd(Stat,Key: integer);
  var pw         : PWindow;
      mx,my,dummy: integer;
      valid      : boolean;
      pipe       : Pipearray;

	begin
		if bTst(Attr.Style,as_XInputMode) then
			begin
				graf_mkstate(mx,my,dummy,dummy);
				pw:=GetGPWindow(wind_find(mx,my));
				if pw=nil then pw:=GetPTopWindow
			end
		else
			pw:=GetPTopWindow;
		if pw<>nil then
			begin
				if not(pw^.IsIconified or pw^.IsShaded) then valid:=not(pw^.WMKeyDown(Stat,Key))
				else
					valid:=true
			end
		else
			valid:=true;
		if valid then
			if AVServer>=0 then
				begin
					pipe[0]:=AV_SENDKEY;
					pipe[1]:=apID;
					pipe[2]:=0;
					pipe[3]:=Stat;
					pipe[4]:=Key;
					{ ... }
					if Stat=K_ALT+K_LSHIFT then
						if Key=24576 then appl_write(AVServer,16,@pipe)
				end
	end;


procedure TApplication.HandleButton(mX,mY,BStat,KStat,Clicks: integer);

	begin
		if BStat<>1 then exit;
		if (KStat and K_SHIFT)>0 then IconSelect(false,DESK)
		else
			IconSelect(false,id_No)
	end;


procedure TApplication.HandleM1(mX,mY,BStat,KStat: integer);
	var cursor: HCursor;

	begin
		if pcrswatch<>nil then
			if not(IsMouseBusy) then
				if not(pcrswatch^.IsShaded) then
					begin
						wind_update(BEG_UPDATE);
						Attr.EventMask:=(Attr.EventMask and not(MU_M1)) or MU_M2;
						GetMouse(wmnr,wmform);
						if pcrswatch^.IsIconified then cursor:=pcrswatch^.IconClass.hCursor
						else
							cursor:=pcrswatch^.Class.hCursor;
						if cursor>$7fff then SetMouse(USER_DEF,pointer(cursor))
						else
							SetMouse(cursor,nil);
						wind_update(END_UPDATE)
					end
	end;


procedure TApplication.HandleM2(mX,mY,BStat,KStat: integer);

	begin
		if pcrswatch<>nil then
			begin
				wind_update(BEG_UPDATE);
				Attr.EventMask:=(Attr.EventMask and not(MU_M2)) or MU_M1;
				if not(IsMouseBusy) then SetMouse(wmnr,@wmform);
				wind_update(END_UPDATE)
			end
	end;


procedure TApplication.HandleMesag(Pipe: Pipearray);

	begin
	end;


procedure TApplication.HandleAV(Pipe: Pipearray);

	begin
	end;


procedure TApplication.HandleXAcc(Pipe: Pipearray);

	begin
	end;


procedure TApplication.HandleTimer;

	begin
	end;


procedure TApplication.HandleMenu(meNum: integer);

	begin
	end;


procedure TApplication.HandleError;

	begin
		if Status=em_OutOfMemory then Status:=em_OK
	end;


procedure TApplication.Terminate;

	begin
	end;


procedure TApplication.Run;

  begin
    if AppFlag then ArrowMouse;
    if Status>=em_OK then
    	begin
    		termflag:=true;
		    MessageLoop
			end;
		Terminating:=true
  end;


procedure TApplication.Quit;

	begin
		Status:=em_Quit
	end;


procedure TApplication.Bing;

	begin
		Bconout(2,BEL)
	end;


function TApplication.At(Index: integer): PWindow;
	var len: integer;
	    p  : PWindow;

	begin
		len:=0;
		p:=MainWindow;
		while p<>nil do
			begin
				inc(len);
				p:=p^.Nxt
			end;
		At:=nil;
		if (Index<0) or (len=0) then exit;
		Index:=Index mod len;
		p:=MainWindow;
		if Index>0 then
			for len:=0 to Index-1 do p:=p^.Nxt;
		At:=p
	end;


function TApplication.IndexOf(Item: PWindow): integer;
	var count: integer;
	    p    : PWindow;

	begin
		IndexOf:=-1;
		count:=0;
		p:=MainWindow;
		while p<>nil do
			begin
				if p=Item then
					begin
						IndexOf:=count;
						exit
					end;
				inc(count);
				p:=p^.Nxt
			end
	end;


function TApplication.FirstWndThat(Test: PIterationFunc): PWindow;
	var p,pc: PWindow;
	    cl  : IterationFunc;

	begin
		FirstWndThat:=nil;
		p:=MainWindow;
		cl:=IterationFunc(Test);
		while p<>nil do
			begin
				if cl(p) then
					begin
						FirstWndThat:=p;
						exit
					end;
				pc:=p^.FirstWndThat(Test);
				if pc<>nil then
					begin
						FirstWndThat:=pc;
						exit
					end;
				p:=p^.Nxt
			end;
	end;


procedure TApplication.ForEachWnd(Action: PIterationProc);
	var p : PWindow;
	    cl: IterationProc;

	begin
		p:=MainWindow;
		cl:=IterationProc(Action);
		while p<>nil do
			begin
				cl(p);
				p^.ForEachWnd(Action);
				p:=p^.Nxt
			end
	end;


function TApplication.FirstIcon(OnAll: boolean): PIcon;

	begin
		icnonall:=OnAll;
		nxticn:=EventList;
		FirstIcon:=NextIcon
	end;


function TApplication.NextIcon: PIcon;
	label _weiter;

	begin
		NextIcon:=nil;
		while nxticn<>nil do
			begin
				if bTst(nxticn^.Style,es_Icon) then
					begin
						if icnonall then
							if PIcon(nxticn)^.GetCheck<>bf_Checked then goto _weiter;
						NextIcon:=PIcon(nxticn);
						nxticn:=nxticn^.Next;
						exit
					end;
				_weiter:
				nxticn:=nxticn^.Next
			end
	end;


procedure TApplication.IconSelect(OnOff: boolean; OffExc: integer);
	var pe: PEvent;
	    pw: PWindow;

	begin
		pe:=EventList;
		if OnOff then
			while pe<>nil do
				begin
					if bTst(pe^.Style,es_Icon) then PIcon(pe)^.Check;
					pe:=pe^.Next
				end
		else
			begin
				if OffExc<>DESK then
					while pe<>nil do
						begin
							if bTst(pe^.Style,es_Icon) then PIcon(pe)^.Uncheck;
							pe:=pe^.Next
						end;
				pw:=MainWindow;
				while pw<>nil do
					begin
						pw^.IconSelect(false,OffExc);
						pw:=pw^.Next
					end
			end
	end;


procedure TApplication.IconPaint(Work: GRECT; var PaintInfo: TPaintStruct);

	begin
	end;


procedure TApplication.BubbleHelp(mX,mY: integer; Hlp: string; mouse,demon: boolean);
	var bubblegem,
	    bclicks,
	    bmask,
	    bstate,
	    dummy,ms : integer;
	    delay    : longint;
	    pipe     : Pipearray;
	    bgs      : string;

	begin
		if (length(Hlp)=0) or not(BubbleHelpActive) or (bubblebuf=nil) then exit;
		bubblegem:=appl_find('BUBBLE  ');
		if bubblegem<0 then
			begin
				bgs:=GetEnv('BUBBLEGEM');
				if length(bgs)>0 then
					begin
						bubblegem:=StartApp(bgs,'');
						if bubblegem>=0 then evnt_timer(500,0)
					end
			end;
		if bubblegem<0 then exit;
		StrPCopy(bubblebuf,Hlp);
		pipe[0]:=BUBBLEGEM_SHOW;
		pipe[1]:=apID;
		pipe[2]:=0;
		pipe[3]:=mx;
		pipe[4]:=my;
		pipe[5]:=integer(HiWord(bubblebuf));
		pipe[6]:=integer(LoWord(bubblebuf));
		pipe[7]:=0;
		if mouse then pipe[7]:=pipe[7] or BGS7_MOUSE;
		if demon then pipe[7]:=pipe[7] or BGS7_REQBYDEMON;
		if DlgTop<0 then
			begin
				appl_write(bubblegem,16,@pipe);
				evnt_timer(100,0)
			end
		else
			begin
				if not(GetCookie('BGEM',delay)) then Bing
				else
					begin
						pipe[7]:=pipe[7] or BGS7_USRHIDE;
						appl_write(bubblegem,16,@pipe);
						evnt_timer(10,0);
						graf_mkstate(dummy,dummy,ms,dummy);
						if (ms and 3)=0 then
							begin
								bclicks:=258;
								bmask:=3;
								bstate:=0
							end
						else
							begin
								bclicks:=0;
								bmask:=3;
								bstate:=0
							end;
						if not(GetCookie('BHLP',delay)) then delay:=200
						else
							delay:=(delay shr 16) and $0000ffff;
						SetMouse(IDC_HELP,nil);
						evnt_timer(delay,0);
						evnt_multi(MU_KEYBD or MU_BUTTON or MU_M1,bclicks,bmask,bstate,1,mX-6,mY-6,13,13,0,0,0,0,0,pipe,0,0,dummy,dummy,ms,dummy,dummy,dummy);
						pipe[0]:=BUBBLEGEM_HIDE;
						pipe[1]:=apID;
						pipe[2]:=0;
						pipe[3]:=0;
						pipe[4]:=0;
						pipe[5]:=0;
						pipe[6]:=0;
						pipe[7]:=0;
						appl_write(bubblegem,16,@pipe);
						SetMouse(ARROW,nil)
					end;
				repeat
					graf_mkstate(dummy,dummy,ms,dummy)
				until (ms and 3)=0
			end
	end;


function TApplication.ExecDialog(ADialog: PDialog): integer;

	begin
		if ADialog=nil then ExecDialog:=em_InvalidDialog
		else
			begin
				with ADialog^ do
					begin
						Attr.ExStyle:=(Attr.ExStyle and not(ws_ex_TryModeless)) or ws_ex_Center2Parent;
						Result:=em_InvalidDialog;
						MakeWindow;
						ExecDialog:=Result
					end;
				ADialog^.Free
			end
	end;


function TApplication.Alert(AParent: PWindow; DefBtn: integer; Sign: longint; Txt,Btn: string): integer;
	const alertref: array [0..3] of AESOBJECT =
					((ob_next:-1;ob_head:1;ob_tail:4;ob_type:G_BOX;ob_flags:NONE;ob_state:OUTLINED;ob_spec:(index:$11100);ob_x:2;ob_y:1;ob_width:38;ob_height:6),
					 (ob_next:3;ob_head:-1;ob_tail:-1;ob_type:G_BUTTON;ob_flags:SELECTABLE or F_EXIT;ob_state:NORMAL;ob_spec:(free_string:nil);ob_x:27;ob_y:4;ob_width:9;ob_height:1),
					 (ob_next:4;ob_head:-1;ob_tail:-1;ob_type:G_STRING;ob_flags:NONE;ob_state:NORMAL;ob_spec:(free_string:nil);ob_x:27;ob_y:1;ob_width:6;ob_height:1),
					 (ob_next:0;ob_head:-1;ob_tail:-1;ob_type:G_IMAGE;ob_flags:NONE;ob_state:NORMAL;ob_spec:(bit_blk:nil);ob_x:2;ob_y:1;ob_width:4;ob_height:2));

				highres: array [1..3,0..63] of word =
								(($0003,$c000,$0006,$6000,$000d,$b000,$001b,$d800,$0037,$ec00,
									$006f,$f600,$00dc,$3b00,$01bc,$3d80,$037c,$3ec0,$06fc,$3f60,
									$0dfc,$3fb0,$1bfc,$3fd8,$37fc,$3fec,$6ffc,$3ff6,$dffc,$3ffb,
									$bffc,$3ffd,$bffc,$3ffd,$dffc,$3ffb,$6ffc,$3ff6,$37fc,$3fec,
									$1bff,$ffd8,$0dff,$ffb0,$06fc,$3f60,$037c,$3ec0,$01bc,$3d80,
									$00dc,$3b00,$006f,$f600,$0037,$ec00,$001b,$d800,$000d,$b000,
									$0006,$6000,$0003,$c000),
								 ($3fff,$fffc,$c000,$0003,$9fff,$fff9,$bfff,$fffd,$dff8,$3ffb,
									$5fe0,$0ffa,$6fc0,$07f6,$2f83,$83f4,$3787,$c3ec,$1787,$c3e8,
									$1bff,$83d8,$0bff,$07d0,$0dfe,$0fb0,$05fc,$1fa0,$06fc,$3f60,
									$02fc,$3f40,$037c,$3ec0,$017c,$3e80,$01bf,$fd80,$00bf,$fd00,
									$00dc,$3b00,$005c,$3a00,$006c,$3600,$002f,$f400,$0037,$ec00,
									$0017,$e800,$001b,$d800,$000b,$d000,$000d,$b000,$0005,$a000,
									$0006,$6000,$0003,$c000),
								 ($007f,$fe00,$00c0,$0300,$01bf,$fd80,$037f,$fec0,$06ff,$ff60,
									$0dff,$ffb0,$1bff,$ffd8,$37ff,$ffec,$6fff,$fff6,$dfff,$fffb,
									$b181,$860d,$a081,$0205,$a4e7,$3265,$a7e7,$3265,$a3e7,$3265,
									$b1e7,$3205,$b8e7,$320d,$bce7,$327d,$a4e7,$327d,$a0e7,$027d,
									$b1e7,$867d,$bfff,$fffd,$dfff,$fffb,$6fff,$fff6,$37ff,$ffec,
									$1bff,$ffd8,$0dff,$ffb0,$06ff,$ff60,$037f,$fec0,$01bf,$fd80,
									$00c0,$0300,$007f,$fe00));

				ABACKBOX      =  0;
				ABUTTON       =  1;
				ASTRING       =  2;
				ABITBLOCK     =  3;
				ALRT_MAXLINES = 18;
				ALRT_MAXBTN   = 12;
				ALRT_WBORDER  =  2;
				ALRT_HBORDER  =  1;
				ALRT_WBINNER  =  1;
				ALRT_WBITBLK  =  4;
				ALRT_HBITBLK  =  2;
				ALRT_HBUTTON  =  1;
				ALRT_HTEXT    =  1;

	var cnttext,cntbutton,objused    : integer;
	    firstbutton,maxbutton,maxtext: integer;
	    firsttext,obj,i,treecnt      : integer;
	    tree                         : PTree;
	    adlg                         : PAlrtDialog;
	    pbitblk                      : pointer;
	    bbcalc                       : BITBLK;
	    smfdb                        : MFDB;
	    ltmval                       : longint;

	function AlertWrap(txt: string; width: integer): string;
		var ret: string;
		    t  : integer;

		procedure add(s: string);
			label _nochmal;

			var i,l: integer;
			    ext: ARRAY_8;

			begin
				_nochmal:
				StrPTrim(s);
				vqt_extent(vdiHandle,s,ext);
				if ext[2]>width then
					begin
						l:=length(s);
						repeat
							dec(l);
							vqt_extent(vdiHandle,StrPLeft(s,l),ext)
						until ext[2]<=width;
						i:=l;
						while not(s[i] in [' ',',','.',';','?','!',':','-','+',')','\']) and (i>0) do dec(i);
						if i=0 then i:=l;
						ret:=ret+StrPTrimF(StrPLeft(s,i))+'|';
						s:=StrPRight(s,length(s)-i);
						goto _nochmal
					end;
				ret:=ret+s
			end;

		begin
			if width<(SysInfo.Font.Width shl 2) then width:=SysInfo.Font.Width shl 2;
			if width>(Attr.MaxPX-(SysInfo.Font.Width shl 1)) then width:=Attr.MaxPX-(SysInfo.Font.Width shl 1);
			ret:='';
			t:=pos('|',txt);
			while t>0 do
				begin
					add(StrPLeft(txt,t-1));
					ret:=ret+'|';
					txt:=StrPRight(txt,length(txt)-t);
					t:=pos('|',txt)
				end;
			add(txt);
			AlertWrap:=ret
		end;

	procedure filterzero(var s: string);
		var ps: integer;

		begin
			ps:=pos(#0,s);
			while ps>0 do
				begin
					s:=StrPLeft(s,ps-1)+StrPRight(s,length(s)-ps);
					ps:=pos(#0,s)
				end
		end;

	function counttokens(var s: string; manz: integer): integer;
		var ret,c: integer;

		begin
			ret:=1;
			for c:=1 to length(s) do
				begin
					if s[c]='|' then inc(ret);
					if ret>manz then
						begin
							s:=StrPLeft(s,c-1);
							dec(ret);
							break
						end
				end;
			counttokens:=ret
		end;

	procedure createalert;
		var dummy,c  : string;
		    max1,max2,
		    sdif,
		    xpos,i,j : integer;
		    ext      : ARRAY_8;

		function taketoken: string;
			var q,l: integer;
			    tt : string;

			begin
				taketoken:='';
				l:=length(dummy);
				if l=0 then exit;
				q:=1;
				while (dummy[q]<>'|') and (q<l) do inc(q);
				if dummy[q]='|' then
					begin
						tt:=StrPLeft(dummy,q-1);
						if length(tt)=0 then taketoken:=' ' else taketoken:=tt;
						dummy:=StrPRight(dummy,length(dummy)-q);
						if length(dummy)=0 then dummy:=' '
					end
				else
					begin
						taketoken:=dummy;
						dummy:=''
					end
			end;

		begin
			tree^[ROOT]:=alertref[ABACKBOX];
			if MagiCVersion>=$0300 then
				with tree^[ROOT].ob_spec do index:=(index and $ff00ffff) or $00020000;
			treecnt:=1;
			if pbitblk<>nil then
				begin
					tree^[treecnt]:=alertref[ABITBLOCK];
					tree^[treecnt].ob_spec.bit_blk:=pbitblk;
					inc(treecnt)
				end;
			obj:=treecnt;
			firsttext:=treecnt;
			for i:=0 to cnttext-1 do
				begin
					tree^[treecnt]:=alertref[ASTRING];
					inc(treecnt)
				end;
			maxtext:=0;
			dummy:=Txt;
			c:=taketoken;
			while length(c)>0 do
				begin
					if maxtext<length(c) then maxtext:=length(c);
					tree^[obj].ob_spec.free_string:=ChrNew(c);
					inc(obj);
					c:=taketoken
				end;
			obj:=treecnt;
			firstbutton:=treecnt;
			for i:=0 to cntbutton-1 do
				begin
					tree^[treecnt]:=alertref[ABUTTON];
					inc(treecnt)
				end;
			if (DefBtn>=1) and (DefBtn<=cntButton) then
				tree^[obj+DefBtn-1].ob_flags:=tree^[obj+DefBtn-1].ob_flags or DEFAULT;
			maxbutton:=0;
			dummy:=Btn;
			c:=taketoken;
			while length(c)>0 do
				begin
					if pos('&',c)>0 then
						begin
							if maxbutton<length(c)-1 then maxbutton:=length(c)-1
						end
					else
						if maxbutton<length(c) then maxbutton:=length(c);
					tree^[obj].ob_spec.free_string:=ChrNew(c);
					inc(obj);
					c:=taketoken
				end;
			inc(maxbutton);
			tree^[ROOT].ob_next:=-1;
			tree^[ROOT].ob_head:=1;
			tree^[ROOT].ob_tail:=treecnt-1;
			for i:=1 to treecnt-1 do
				begin
					tree^[i].ob_next:=i+1;
					tree^[i].ob_head:=-1;
					tree^[i].ob_tail:=-1
				end;
			tree^[treecnt-1].ob_flags:=tree^[treecnt-1].ob_flags or LASTOB;
			tree^[treecnt-1].ob_next:=ROOT;
			max1:=ALRT_WBORDER+maxtext;
			if pbitblk<>nil then inc(max1,ALRT_WBINNER+ALRT_WBITBLK);
			max2:=cntbutton*(maxbutton+ALRT_WBORDER);
			tree^[ROOT].ob_width:=ALRT_WBORDER+max(max1,max2);
			tree^[ROOT].ob_height:=(3*ALRT_HBORDER+ALRT_HBUTTON)+cnttext;
			obj:=1;
			if pbitblk<>nil then
				begin
					tree^[obj].ob_x:=ALRT_WBORDER;
					tree^[obj].ob_y:=ALRT_HBORDER;
					tree^[obj].ob_width:=ALRT_WBITBLK;
					tree^[obj].ob_height:=ALRT_HBITBLK;
					inc(obj)
				end;
			i:=1;
			while (tree^[obj].ob_type=G_STRING) do
				begin
					tree^[obj].ob_x:=ALRT_WBORDER;
					if pbitblk<>nil then inc(tree^[obj].ob_x,ALRT_WBITBLK+ALRT_WBINNER);
					tree^[obj].ob_y:=i;
					tree^[obj].ob_width:=maxtext;
					tree^[obj].ob_height:=ALRT_HTEXT;
					inc(obj);
					inc(i)
				end;
			inc(i);
			xpos:=tree^[ROOT].ob_width-cntbutton*(maxbutton+ALRT_WBORDER);
			dec(obj);
			repeat
				inc(obj);
				tree^[obj].ob_x:=xpos;
				tree^[obj].ob_y:=i;
				tree^[obj].ob_width:=maxbutton;
				tree^[obj].ob_height:=ALRT_HBUTTON;
				inc(xpos,maxbutton+ALRT_WBORDER)
			until bTst(tree^[obj].ob_flags,LASTOB);
			for i:=ROOT to treecnt-1 do rsrc_obfix(tree,i);
			if tree^[firstbutton].ob_x>(SysInfo.Font.Width shl 1) then
				begin
					sdif:=Attr.MaxPX;
					for i:=ROOT+1 to treecnt-1 do
						if (tree^[i].ob_type=G_STRING) then
							if length(StrPPas(tree^[i].ob_spec.free_string))>0 then
								begin
									vqt_extent(vdiHandle,StrPPas(tree^[i].ob_spec.free_string),ext);
									j:=tree^[ROOT].ob_width-tree^[i].ob_x-ext[2];
									if j<sdif then sdif:=j
								end;
					if sdif<Attr.MaxPX then
						begin
							sdif:=Min(sdif,tree^[firstbutton].ob_x);
							dec(sdif,SysInfo.Font.Width+Attr.charSWidth);
							if sdif>0 then
								begin
									dec(tree^[ROOT].ob_width,sdif);
									for i:=ROOT+1 to treecnt-1 do
										begin
											if (tree^[i].ob_type=G_STRING) then dec(tree^[i].ob_width,sdif)
											else
												if (tree^[i].ob_type=G_BUTTON) then dec(tree^[i].ob_x,sdif)
										end
								end
						end
				end
		end;

	begin
		Alert:=id_No;
		pbitblk:=nil;
		if Sign>$7fff then pbitblk:=pointer(Sign)
		else
			if (Sign>NO_ICON) and (Sign<=STOP) then
				begin
					with bbcalc do
						begin
							bi_pdata:=@highres[Sign];
							bi_wb:=4;
							bi_hl:=32;
							bi_x:=0;
							bi_y:=0;
							case Sign of
								NOTE: if SysInfo.BGDefCol<>White then bi_color:=Yellow
								      else
								      	bi_color:=LBlack;
								WAIT: bi_color:=Blue;
								STOP: bi_color:=Red
							else
								bi_color:=Black
							end
						end;
					pbitblk:=@bbcalc
				end;
		filterzero(Txt);
		filterzero(Btn);
		if length(Txt)=0 then Txt:=' '
		else
			begin
				if pbitblk=nil then Txt:=AlertWrap(Txt,Min(360,Attr.MaxPX-SysInfo.Font.Width*5))
				else
					txt:=AlertWrap(Txt,Min(360,Attr.MaxPX-SysInfo.Font.Width*10))
			end;
		cnttext:=counttokens(Txt,ALRT_MAXLINES);
		if (cnttext=1) and (pbitblk<>nil) then
			begin
				Txt:='|'+StrPLeft(Txt,254);
				cnttext:=2
			end;
		cntbutton:=counttokens(Btn,ALRT_MAXBTN);
		objused:=cnttext+cntbutton+2;
		getmem(tree,objused*sizeof(AESOBJECT));
		if tree=nil then exit;
		createalert;
		new(adlg,Init(AParent,Name^,id_No));
		if adlg=nil then
			begin
				freemem(tree,objused*sizeof(AESOBJECT));
				exit
			end
		else
			with adlg^ do
				begin
					SetDlgTree(tree);
					SetupSize
				end;
		for i:=firstbutton to firstbutton+cntbutton-1 do new(PButton,Init(adlg,i,id_No,true,''));
		i:=Attr.Style and as_GrowShrink;
		if (Sign>NO_ICON) and (Sign<=STOP) then
			begin
				vdi_fix(smfdb,pbitblk,tree^[1].ob_width,tree^[1].ob_height);
				vr_convert(vdiHandle,smfdb,FF_DEVSPEC);
				smfdb.fd_stand:=FF_DEVSPEC
			end;
		Attr.Style:=Attr.Style and not(as_GrowShrink);
		adlg^.cntbutton:=cntbutton;
		adlg^.firstbutton:=firstbutton;
		with adlg^ do
			begin
				Attr.ExStyle:=(Attr.ExStyle and not(ws_ex_TryModeless)) or ws_ex_Center2Parent;
				if ltmf=nil then Attr.ExStyle:=Attr.ExStyle or ws_ex_MoveTransparent;
				Result:=em_InvalidDialog;
				MakeWindow;
				if Result>ROOT then Alert:=Result+1-firstbutton
			end;
		Attr.Style:=Attr.Style or i;
		if (Sign>NO_ICON) and (Sign<=STOP) then vr_convert(vdiHandle,smfdb,FF_STAND);
		adlg^.Free;
		for i:=firsttext to firsttext+cnttext+cntbutton-1 do ChrDispose(PChar(tree^[i].ob_spec.free_string));
		freemem(tree,objused*sizeof(AESOBJECT))
	end;


function TApplication.Popup(APopup: PPopup; x,y,Flag: integer): integer;
	var res: integer;

	begin
		res:=id_No;
		if APopup<>nil then
			begin
				with APopup^ do
					begin
						pX:=x;
						pY:=y;
						pFlag:=Flag;
						res:=Execute
					end;
				APopup^.Free
			end;
		Popup:=res
	end;


function TApplication.Rubbox(WHnd,x,y,xmin,ymin,xmax,ymax: integer; IconSel: boolean; var r: GRECT): boolean;
	var x2,y2,mx,my,mk,dummy: integer;
	    box,cl              : GRECT;
	    pxy2,pxy3,pxy4      : ARRAY_4;
	    wnd                 : PWindow;
	    visible             : boolean;
	    pe,pevnt            : PEvent;

	procedure DrawRubbox;

		begin
			vswr_mode(vdiHandle,MD_XOR);
			vsl_type(vdiHandle,LT_USERDEF);
			if wnd=nil then
				begin
					wind_get(WHnd,WF_FIRSTXYWH,box.X1,box.Y1,box.X2,box.Y2);
					while (box.X2>0) and (box.Y2>0) do
						begin
							inc(box.X2,box.X1-1);
							inc(box.Y2,box.Y1-1);
							vs_clip(vdiHandle,CLIP_ON,box.A2);
							v_pline(vdiHandle,2,pxya);
							v_pline(vdiHandle,2,pxy2);
							v_pline(vdiHandle,2,pxy3);
							v_pline(vdiHandle,2,pxy4);
							wind_get(WHnd,WF_NEXTXYWH,box.X1,box.Y1,box.X2,box.Y2)
						end
				end
			else
				begin
					visible:=wnd^.FirstWorkRect(box);
					while visible do
						begin
							vs_clip(vdiHandle,CLIP_ON,box.A2);
							v_pline(vdiHandle,2,pxya);
							v_pline(vdiHandle,2,pxy2);
							v_pline(vdiHandle,2,pxy3);
							v_pline(vdiHandle,2,pxy4);
							visible:=wnd^.NextWorkRect(box)
						end
					end;
			vsl_type(vdiHandle,LT_SOLID);
			vswr_mode(vdiHandle,MD_REPLACE);
			vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
		end;

	begin
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		graf_mouse(POINT_HAND,nil);
		mx:=x;
		my:=y;
		pxya[0]:=x;
		pxya[1]:=y;
		pxya[3]:=y;
		pxy2[1]:=y;
		pxy3[0]:=x;
		pxy4[0]:=x;
		pxy4[1]:=y;
		pxy4[2]:=x;
		if WHnd=DESK then
			begin
				wnd:=nil;
				pevnt:=EventList
			end
		else
			begin
				wnd:=GetGPWindow(WHnd);
				if wnd<>nil then pevnt:=wnd^.EventList
				else
					pevnt:=nil
			end;
		if pevnt=nil then IconSel:=false
		else
			if IconSel then
				begin
					pe:=pevnt;
					while pe<>nil do
						begin
							if bTst(pe^.Style,es_Icon) then PIcon(pe)^.rubsel:=false;
							pe:=pe^.Next
						end
				end;
		HideMouse;
		repeat
			x2:=mx;
			y2:=my;
			pxya[2]:=x2;
			pxy2[0]:=x2;
			pxy2[2]:=x2;
			pxy2[3]:=y2;
			pxy3[1]:=y2;
			pxy3[2]:=x2;
			pxy3[3]:=y2;
			pxy4[3]:=y2;
			if WHnd=DESK then
				begin
					cl.X1:=Min(x,x2)-SysInfo.Desktop.X1;
					cl.X2:=Max(x,x2)-SysInfo.Desktop.X1;
					cl.Y1:=Min(y,y2)-SysInfo.Desktop.Y1;
					cl.Y2:=Max(y,y2)-SysInfo.Desktop.Y1;
					A2toGR(cl);
					MURBoxChanged(cl)
				end
			else
				if wnd<>nil then
					begin
						cl.X1:=Min(x,x2)-wnd^.Work.X1;
						cl.X2:=Max(x,x2)-wnd^.Work.X1;
						cl.Y1:=Min(y,y2)-wnd^.Work.Y1;
						cl.Y2:=Max(y,y2)-wnd^.Work.Y1;
						A2toGR(cl);
						wnd^.WMRBoxChanged(cl)
					end;
			if IconSel then
				begin
					cl.X:=Min(x,x2);
					cl.Y:=Min(y,y2);
					GRtoA2(cl);
					pe:=pevnt;
					while pe<>nil do
						begin
							if bTst(pe^.Style,es_Icon) then
								with PIcon(pe)^ do
									if IsSelectable then
										begin
											if IsSelected(cl) then
												begin
													if not(rubsel) then
														begin
															Toggle;
															rubsel:=true
														end
												end
											else
												if rubsel then
													begin
														Toggle;
														rubsel:=false
													end
										end;
							pe:=pe^.Next
						end
				end;
			DrawRubbox;
			ShowMouse;
			repeat
				graf_mkstate(mx,my,mk,dummy);
				if mx<xmin then mx:=xmin;
				if mx>xmax then mx:=xmax;
				if my<ymin then my:=ymin;
				if my>ymax then my:=ymax;
				if wnd<>nil then wnd^.WMRBoxCheck(x,y,xmin,ymin,xmax,ymax,mx,my)
			until (x2<>mx) or (y2<>my) or (mk<>1);
			HideMouse;
			DrawRubbox
		until (mk<>1);
		ShowMouse;
		graf_mouse(maus.currnr,@maus.currform);
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
		if mk=0 then
			begin
				r.X1:=Min(x,x2);
				r.X2:=Max(x,x2);
				r.Y1:=Min(y,y2);
				r.Y2:=Max(y,y2);
				if WHnd=DESK then
					begin
						dec(r.X1,SysInfo.Desktop.X1);
						dec(r.X2,SysInfo.Desktop.X1);
						dec(r.Y1,SysInfo.Desktop.Y1);
						dec(r.Y2,SysInfo.Desktop.Y1)
					end
				else
					if wnd<>nil then
						begin
							dec(r.X1,wnd^.Work.X1);
							dec(r.X2,wnd^.Work.X1);
							dec(r.Y1,wnd^.Work.Y1);
							dec(r.Y2,wnd^.Work.Y1)
						end;
				A2toGR(r);
				Rubbox:=true
			end
		else
			Rubbox:=false
	end;


procedure TApplication.ReleaseMouseButton(Mask:integer);
	var pipe: Pipearray;

	begin
		pipe[0]:=GO_PRIVATE;
		pipe[1]:=apID;
		pipe[2]:=0;
		pipe[3]:=GOP_RELEASEBUTTON;
		pipe[4]:=Mask;
		appl_write(apID,16,@pipe)
	end;


procedure TApplication.InvalidateRect(Wnd: HWnd; Rect: PGRECT);
	var p    : PWindow;
	    box,r: GRECT;
	    pipe : Pipearray;

	begin
		wind_update(BEG_UPDATE);
		p:=GetPWindow(Wnd);
		if p<>nil then
			with p^ do
				begin
					if Rect<>nil then box:=Rect^
					else
						begin
							r:=Curr;
							GetWork;
							GetCurr;
							box:=Curr;
							Curr:=r
						end;
					pipe[0]:=WM_REDRAW;
					pipe[1]:=apID;
					pipe[2]:=0;
					pipe[3]:=Attr.gemHandle;
					pipe[4]:=box.X;
					pipe[5]:=box.Y;
					pipe[6]:=box.W;
					pipe[7]:=box.H;
					appl_write(apID,16,@pipe)
				end;
		wind_update(END_UPDATE)
	end;


procedure TApplication.RestoreModalDialog(p: PWindow);
	var pinfo     : TPaintStruct;
	    pipe      : Pipearray;
	    pw        : PWindow;
	    evnt,dummy: integer;

	procedure RestoreParent(pwi: PWindow);

		begin
			if pwi<>nil then
				begin
					if pwi^.IsDialog then
						with PDialog(pwi)^ do
							begin
								if IsModal then
									begin
										RestoreParent(Parent);
										with pinfo do
											begin
												rcPaint:=Curr;
												fErase:=false
											end;
										UpdateDialog;
										InitPaint;
										Paint(pinfo);
										ExitPaint
									end
							end
				end
		end;

	begin
		if p=nil then exit;
		if not(p^.IsDialog) then exit;
		if not(PDialog(p)^.IsModal) then exit;
		wind_update(BEG_UPDATE);
		repeat
			evnt:=evnt_multi(MU_TIMER or MU_MESAG,0,0,0,0,0,0,0,0,0,0,0,0,0,pipe,5,0,dummy,dummy,dummy,dummy,dummy,dummy);
			if bTst(evnt,MU_MESAG) and (pipe[0]=WM_REDRAW) then
				begin
					pw:=GetGPWindow(pipe[3]);
					if pw<>nil then pw^.WMRedraw(pipe[4],pipe[5],pipe[6],pipe[7])
				end
		until evnt=MU_TIMER;
		HideMouse;
		RestoreParent(p);
		ShowMouse;
		wind_update(END_UPDATE)
	end;


procedure TApplication.DeskRedraw;
	var box: GRECT;

	begin
		wind_update(BEG_UPDATE);
		wind_get(DESK,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
		while (box.W>0) and (box.H>0) do
			begin
				form_dial(FMD_FINISH,0,0,0,0,box.X,box.Y,box.W,box.H);
				wind_get(DESK,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
			end;
		wind_update(END_UPDATE)
	end;


procedure TApplication.SetQuit(mNum,tNum: integer);
	var pipe: Pipearray;

	begin
		pipe[0]:=GO_PRIVATE;
		pipe[1]:=apID;
		pipe[2]:=0;
		pipe[3]:=GOP_SETQUIT;
		pipe[4]:=mNum;
		pipe[5]:=tNum;
		appl_write(apID,16,@pipe)
	end;


procedure TApplication.GetMenuEntries(var Entries: TMenuEntries);

	begin
		fillchar(Entries,sizeof(Entries),0)
	end;


procedure TApplication.CheckMenuEntries;

	begin
		if (MenuTree=nil) or (menuentries=nil) then exit;
		if GetPTopWindow=nil then
			begin
				if menuentries^.Close.Entry>0 then menu_ienable(MenuTree,menuentries^.Close.Entry,0);
				if menuentries^.Print.Entry>0 then menu_ienable(MenuTree,menuentries^.Print.Entry,0);
				if menuentries^.Cut.Entry>0 then menu_ienable(MenuTree,menuentries^.Cut.Entry,0);
				if menuentries^.Copy.Entry>0 then menu_ienable(MenuTree,menuentries^.Copy.Entry,0);
				if menuentries^.Paste.Entry>0 then menu_ienable(MenuTree,menuentries^.Paste.Entry,0);
				if menuentries^.Delete.Entry>0 then menu_ienable(MenuTree,menuentries^.Delete.Entry,0);
				if menuentries^.SelectAll.Entry>0 then menu_ienable(MenuTree,menuentries^.SelectAll.Entry,0)
			end
		else
			begin
				if menuentries^.Close.Entry>0 then menu_ienable(MenuTree,menuentries^.Close.Entry,1);
				if menuentries^.Print.Entry>0 then menu_ienable(MenuTree,menuentries^.Print.Entry,1);
				if menuentries^.Cut.Entry>0 then menu_ienable(MenuTree,menuentries^.Cut.Entry,1);
				if menuentries^.Copy.Entry>0 then menu_ienable(MenuTree,menuentries^.Copy.Entry,1);
				if menuentries^.Paste.Entry>0 then menu_ienable(MenuTree,menuentries^.Paste.Entry,1);
				if menuentries^.Delete.Entry>0 then menu_ienable(MenuTree,menuentries^.Delete.Entry,1);
				if menuentries^.SelectAll.Entry>0 then menu_ienable(MenuTree,menuentries^.SelectAll.Entry,1)
			end
	end;


procedure TApplication.SetError(AnError: integer);

	begin
		Err:=AnError
	end;


function TApplication.ChkError: integer;

	begin
		ChkError:=Err;
		Err:=em_OK
	end;


function TApplication.ChkSpeedoError: integer;

	begin
		ChkSpeedoError:=spderr;
		spderr:=0
	end;


procedure TApplication.Error(ErrorCode: integer);
	var olderr,oldstat: integer;

	begin
		oldstat:=Status;
		olderr:=Err;
		Status:=em_OK;
		Err:=em_OK;
		if Attr.Country=FRA then
			case ErrorCode of
				em_OK,em_Quit,em_AESNotActive,em_GEMInitFailure,em_Terminate:;
				em_InvalidWindow: GOErrAlert(NOTE,'Plus assez de fenàtres');
				em_InvalidMainWindow: GOErrAlert(NOTE,'Fenàtre principale invalide');
				em_AccInitFailure: GOErrAlert(STOP,'Initiation des accessoires corrompue');
				em_WOpenFailure: GOErrAlert(NOTE,'Ouverture des fenàtres corrompue');
				em_WCloseFailure: GOErrAlert(NOTE,'Fermeture des fenàtres corrompue');
				em_WDestroyFailure: GOErrAlert(NOTE,'Destruction des fenàtres corrompue');
				em_RscNotFound: GOErrAlert(NOTE,'Fichier ressource introuvable');
				em_InvalidMenu: GOErrAlert(NOTE,'Structure de menu invalide');
				em_InvalidDialog: GOErrAlert(NOTE,'Ressource de dialogue invalide');
				em_OutOfMemory: GOErrAlert(STOP,'Erreur: Pas assez de mÇmoire RAM')
			else
				GOErrAlert(STOP,'Erreur inconnue '+ltoa(ErrorCode))
			end
		else if (Attr.Country=FRG) or (Attr.Country=SWG) then
			case ErrorCode of
				em_OK,em_Quit,em_AESNotActive,em_GEMInitFailure,em_Terminate:;
				em_InvalidWindow: GOErrAlert(NOTE,'Kein Fenster mehr verfÅgbar');
				em_InvalidMainWindow: GOErrAlert(NOTE,'Hauptfenster nicht verfÅgbar');
				em_AccInitFailure: GOErrAlert(STOP,'Kann Accessory nicht installieren');
				em_WOpenFailure: GOErrAlert(NOTE,'Fehler (Fenster îffnen)');
				em_WCloseFailure: GOErrAlert(NOTE,'Fehler (Fenster schlieûen)');
				em_WDestroyFailure: GOErrAlert(NOTE,'Fehler (Fenster freigeben)');
				em_RscNotFound: GOErrAlert(NOTE,'RSC-Datei nicht gefunden');
				em_InvalidMenu: GOErrAlert(NOTE,'Fehler (ungÅltiges MenÅ)');
				em_InvalidDialog: GOErrAlert(NOTE,'Fehler (ungÅltiger Dialog)');
				em_OutOfMemory: GOErrAlert(STOP,'Kein RAM-Speicher mehr frei')
			else
				GOErrAlert(STOP,'Unbekannter Fehler '+ltoa(ErrorCode))
			end
		else
			case ErrorCode of
				em_OK,em_Quit,em_AESNotActive,em_GEMInitFailure,em_Terminate:;
				em_InvalidWindow: GOErrAlert(NOTE,'No more windows');
				em_InvalidMainWindow: GOErrAlert(NOTE,'Invalid main window');
				em_AccInitFailure: GOErrAlert(STOP,'Accessory init Failure');
				em_WOpenFailure: GOErrAlert(NOTE,'Window open failure');
				em_WCloseFailure: GOErrAlert(NOTE,'Window close failure');
				em_WDestroyFailure: GOErrAlert(NOTE,'Window destroy failure');
				em_RscNotFound: GOErrAlert(NOTE,'Resource file not found');
				em_InvalidMenu: GOErrAlert(NOTE,'Invalid menu structure');
				em_InvalidDialog: GOErrAlert(NOTE,'Invalid dialog resource');
				em_OutOfMemory: GOErrAlert(STOP,'Error: Out of RAM memory')
			else
				GOErrAlert(STOP,'Unknown error '+ltoa(ErrorCode))
			end;
		Status:=oldstat;
		Err:=olderr
	end;


function TApplication.GetObjectParent(tree: PTree; indx: integer): integer;
	var p,np: integer;

	begin
		p:=-1;
		np:=tree^[indx].ob_next;
		while (np>-1) and (p=-1) do
			begin
				if tree^[np].ob_tail=indx then p:=np;
				indx:=np;
				np:=tree^[indx].ob_next
			end;
		GetObjectParent:=p
	end;


function TApplication.IsTreeHidden(tree: PTree; pobj: integer): boolean;
	var hid: boolean;

	begin
		hid:=false;
		while not(hid) and (pobj>-1) do
			begin
				hid:=bTst(tree^[pobj].ob_flags,HIDETREE);
				pobj:=GetObjectParent(tree,pobj)
			end;
		IsTreeHidden:=hid
	end;


	{ private }


procedure TApplication.MoveIcons(Wnd: PEventObject; Icn: PIcon; gHnd,mX,mY: integer);
	var bs,ks,x2,y2,dummy,
	    x,y,xl,xr,yo,yu,dest: integer;
	    rs,rt               : GRECT;
	    pe                  : PEvent;

	begin
		wind_update(BEG_MCTRL);
		vswr_mode(vdiHandle,MD_XOR);
		vsl_type(vdiHandle,LT_USERDEF);
		graf_mouse(FLAT_HAND,nil);
		x2:=mX;
		y2:=mY;
		xl:=maxint;
		xr:=-maxint;
		yo:=maxint;
		yu:=-maxint;
		pe:=Wnd^.EventList;
		while pe<>nil do
			begin
				if bTst(pe^.Style,es_Icon) then
					if PIcon(pe)^.GetCheck=bf_Checked then
						begin
							if PIcon(pe)^.GetOutline(rs,rt) then
								begin
									if rt.Y1<yo then yo:=rt.Y1;
									if rt.Y2>yu then yu:=rt.Y2
								end;
							if rs.X1<xl then xl:=rs.X1;
							if rs.X2>xr then xr:=rs.X2;
							if rs.Y1<yo then yo:=rs.Y1;
							if rs.Y2>yu then yu:=rs.Y2
						end;
				pe:=pe^.Next
			end;
		dec(xl,mX);
		dec(xr,mX);
		dec(yo,mY);
		dec(yu,mY);
		HideMouse;
		repeat
			x:=x2;
			y:=y2;
			pe:=Wnd^.EventList;
			while pe<>nil do
				begin
					if bTst(pe^.Style,es_Icon) then
						if PIcon(pe)^.GetCheck=bf_Checked then
							begin
								if PIcon(pe)^.GetOutline(rs,rt) then
									begin
										pxya[0]:=rt.X-mX+x;
										pxya[1]:=rt.Y-mY+y;
										pxya[2]:=pxya[0]+rt.W-1;
										pxya[3]:=pxya[1];
										pxya[4]:=pxya[2];
										pxya[5]:=pxya[1]+rt.H-1;
										pxya[6]:=pxya[0];
										pxya[7]:=pxya[5];
										pxya[8]:=pxya[0];
										pxya[9]:=pxya[1];
										v_pline(vdiHandle,5,pxya)
									end;
								pxya[0]:=rs.X-mX+x;
								pxya[1]:=rs.Y-mY+y;
								pxya[2]:=pxya[0]+rs.W-1;
								pxya[3]:=pxya[1];
								pxya[4]:=pxya[2];
								pxya[5]:=pxya[1]+rs.H-1;
								pxya[6]:=pxya[0];
								pxya[7]:=pxya[5];
								pxya[8]:=pxya[0];
								pxya[9]:=pxya[1];
								v_pline(vdiHandle,5,pxya)
							end;
					pe:=pe^.Next
				end;
			ShowMouse;
			repeat
				graf_mkstate(x2,y2,bs,ks);
				if xr+x2>SysInfo.Desktop.X2 then x2:=SysInfo.Desktop.X2-xr;
				if xl+x2<SysInfo.Desktop.X1 then x2:=SysInfo.Desktop.X1-xl;
				if yu+y2>SysInfo.Desktop.Y2 then y2:=SysInfo.Desktop.Y2-yu;
				if yo+y2<SysInfo.Desktop.Y1 then y2:=SysInfo.Desktop.Y1-yo
			until (x<>x2) or (y<>y2) or (bs<>1);
			HideMouse;
			pe:=Wnd^.EventList;
			while pe<>nil do
				begin
					if bTst(pe^.Style,es_Icon) then
						if PIcon(pe)^.GetCheck=bf_Checked then
							begin
								if PIcon(pe)^.GetOutline(rs,rt) then
									begin
										pxya[0]:=rt.X-mX+x;
										pxya[1]:=rt.Y-mY+y;
										pxya[2]:=pxya[0]+rt.W-1;
										pxya[3]:=pxya[1];
										pxya[4]:=pxya[2];
										pxya[5]:=pxya[1]+rt.H-1;
										pxya[6]:=pxya[0];
										pxya[7]:=pxya[5];
										pxya[8]:=pxya[0];
										pxya[9]:=pxya[1];
										v_pline(vdiHandle,5,pxya)
									end;
								pxya[0]:=rs.X-mX+x;
								pxya[1]:=rs.Y-mY+y;
								pxya[2]:=pxya[0]+rs.W-1;
								pxya[3]:=pxya[1];
								pxya[4]:=pxya[2];
								pxya[5]:=pxya[1]+rs.H-1;
								pxya[6]:=pxya[0];
								pxya[7]:=pxya[5];
								pxya[8]:=pxya[0];
								pxya[9]:=pxya[1];
								v_pline(vdiHandle,5,pxya)
							end;
					pe:=pe^.Next
				end
		until bs<>1;
		ShowMouse;
		vswr_mode(vdiHandle,MD_REPLACE);
		vsl_type(vdiHandle,LT_SOLID);
		graf_mouse(maus.currnr,@maus.currform);
		wind_update(END_MCTRL);
		if (bs=0) and ((x<>mX) or (y<>mY)) then
			begin
				if gHnd=DESK then exit; { ... }
				dest:=wind_find(x,y);
				if (dest=gHnd) and Between(x,PWindow(Wnd)^.Work.X1,PWindow(Wnd)^.Work.X2) and Between(y,PWindow(Wnd)^.Work.Y1,PWindow(Wnd)^.Work.Y2) then
					begin
						pe:=Wnd^.EventList;
						while pe<>nil do
							begin
								if bTst(pe^.Style,es_Icon) then
									with PIcon(pe)^ do
										if GetCheck=bf_Checked then IMMoved(XPos-mX+x,YPos-mY+y);
								pe:=pe^.Next
							end
					end;
				{ ... }
			end
	end;


function TApplication.find_object(tree: PTree; start,which: integer): integer;
	label _again;

	var obj,flag,increment,objmax: integer;

	begin
		obj:=0;
		flag:=EDITABLE;
		increment:=1;
		if which=FMD_BACKWARD then increment:=-1;
		if (which=FMD_BACKWARD) or (which=FMD_FORWARD) then obj:=start+increment;
		if which=FMD_DEFLT then flag:=DEFAULT;
		objmax:=ROOT;
		while not(bTst(tree^[objmax].ob_flags,LASTOB)) do inc(objmax);
		_again:
		while (obj>=0) and (obj<=objmax) do
			begin
				with tree^[obj] do
					if bTst(ob_flags,flag) and not(bTst(ob_state,DISABLED)) and not(IsTreeHidden(tree,obj)) then
						begin
							find_object:=obj;
							exit
						end;
				inc(obj,increment)
			end;
		if (obj<0) and (start>0) then
			begin
				obj:=objmax;
				goto _again
			end;
		if (obj>objmax) and (start>0) then
			begin
				obj:=0;
				goto _again
			end;
		find_object:=start
	end;


function TApplication.ini_field(tree: PTree; start: integer): integer;

	begin
		if start=0 then start:=find_object(tree,0,FMD_FORWARD);
		ini_field:=start
	end;


function TApplication.form_keybd(pd: PDialog; fo_ktree: PTree; fo_kobject,fo_kobnext,fo_kchar,fo_kstat: integer; var fo_knxtobject,fo_knxtchar: integer): integer;
	var pc: PControl;

	begin
		form_keybd:=1;
		fo_knxtchar:=0;
		case fo_kchar of
		Tab:
			begin
				if bTst(fo_kstat,K_CTRL) then
					with pd^ do
						begin
							fo_knxtobject:=fo_kobject;
							if pxfocus=nil then exit;
							pc:=pxfocus;
							repeat
								if (fo_kstat and K_SHIFT)>0 then
									begin
										pc:=pc^.Previous;
										if pc=nil then
											begin
												pc:=CtrlList;
												while pc^.Next<>nil do pc:=pc^.Next
											end
									end
								else
									begin
										pc:=pc^.Next;
										if pc=nil then pc:=CtrlList
									end
							until (pc=pxfocus) or pc^.IsFlagSet(wb_ExtFocus);
							SetExtFocus(pc^.ObjIndx)
						end
				else
					if (fo_kstat and K_SHIFT)>0 then fo_knxtobject:=find_object(fo_ktree,fo_kobject,FMD_BACKWARD)
					else
						fo_knxtobject:=find_object(fo_ktree,fo_kobject,FMD_FORWARD)
			end;
		Return,Enter:
			begin
				fo_knxtobject:=find_object(fo_ktree,-1,FMD_DEFLT);
				if fo_knxtobject=-1 then fo_knxtobject:=fo_kobject
				else
					form_keybd:=0
			end;
		Cur_Up:
			fo_knxtobject:=find_object(fo_ktree,fo_kobject,FMD_BACKWARD);
		Cur_Down:
			fo_knxtobject:=find_object(fo_ktree,fo_kobject,FMD_FORWARD);
		Shift_Home,Shift_CD:
			fo_knxtobject:=find_object(fo_ktree,ini_field(fo_ktree,0),FMD_BACKWARD);
		Home,Shift_CU:
			fo_knxtobject:=ini_field(fo_ktree,0);
		else
			begin
				fo_knxtobject:=fo_kobject;
				fo_knxtchar:=fo_kchar
			end
		end
	end;


function TApplication.form_button(pd: PDialog; fo_bobject,fo_bclicks: integer; var fo_bnxtobj: integer): boolean;
	label _raus;

	var obs,obf,robj,dummy,bx,by: integer;
	    brect,mrect             : GRECT;
	    onbtn,inrect,visible    : boolean;
	    bnxo                    : word;

	begin
		form_button:=true;
		fo_bnxtobj:=0;
		obs:=pd^.DlgTree^[fo_bobject].ob_state;
		obf:=pd^.DlgTree^[fo_bobject].ob_flags;
		if bTst(obs,DISABLED) or IsTreeHidden(pd^.DlgTree,fo_bobject) then exit;
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		if bTst(obf,SELECTABLE) then
			begin
				if bTst(obf,RBUTTON) then
					begin
						if not(bTst(obs,SELECTED)) then
							begin
								robj:=fo_bobject;
								repeat
									dummy:=pd^.DlgTree^[robj].ob_next;
									if pd^.DlgTree^[dummy].ob_tail=robj then
										robj:=pd^.DlgTree^[dummy].ob_head
									else
										robj:=dummy;
									if bTst(pd^.DlgTree^[robj].ob_flags,RBUTTON) then
										if bTst(pd^.DlgTree^[robj].ob_state,SELECTED) then
											begin
												objc_change(pd^.DlgTree,robj,0,0,0,1,1,pd^.DlgTree^[robj].ob_state and not(SELECTED),1);
												pd^.ObjcPaint(robj,false)
											end;
								until robj=fo_bobject;
								objc_change(pd^.DlgTree,fo_bobject,0,0,0,1,1,obs or SELECTED,1);
								pd^.ObjcPaint(fo_bobject,false);
								repeat
									graf_mkstate(dummy,dummy,robj,dummy)
								until not(bTst(robj,1))
							end
					end
				else
					if bTst(obf,F_EXIT) then
						begin
							obs:=obs or SELECTED;
							objc_change(pd^.DlgTree,fo_bobject,0,0,0,1,1,obs,1);
							pd^.ObjcPaint(fo_bobject,false);
							objc_offset(pd^.DlgTree,fo_bobject,bx,by);
							with brect do
								begin
									X:=bx;
									Y:=by;
									W:=pd^.DlgTree^[fo_bobject].ob_width;
									H:=pd^.DlgTree^[fo_bobject].ob_height
								end;
							onbtn:=true;
							repeat
								graf_mkstate(bx,by,robj,dummy);
								if pd^.IsModal then
									inrect:=((bx>=brect.X) and (by>=brect.Y) and (bx<brect.X+brect.W) and (by<brect.Y+brect.H))
								else
									begin
										inrect:=false;
										visible:=pd^.FirstWorkRect(mrect);
										while visible do
											begin
												if rc_intersect(brect,mrect) then
													with mrect do
														if (bx>=X1) and (by>=Y1) and (bx<=X2) and (by<=Y2) then inrect:=true;
												visible:=pd^.NextWorkRect(mrect)
											end
									end;
								if inrect<>onbtn then
									begin
										obs:=obs xor SELECTED;
										objc_change(pd^.DlgTree,fo_bobject,0,0,0,1,1,obs,1);
										pd^.ObjcPaint(fo_bobject,false);
										onbtn:=inrect
									end
							until not(bTst(robj,1));
							if not(onbtn) then goto _raus
						end
					else
						begin
							objc_change(pd^.DlgTree,fo_bobject,0,0,0,1,1,obs xor SELECTED,1);
							pd^.ObjcPaint(fo_bobject,false);
							if not(bTst(obf,TOUCHEXIT)) then
								repeat
									graf_mkstate(dummy,dummy,robj,dummy)
								until not(bTst(robj,1))
						end
			end;
		if (obf and (F_EXIT or TOUCHEXIT or EDITABLE))>0 then
			begin
				fo_bnxtobj:=fo_bobject;
				if (obf and (F_EXIT or TOUCHEXIT))>0 then form_button:=false;
				if bTst(obf,TOUCHEXIT) and (fo_bclicks>1) then
					begin
						bnxo:=fo_bnxtobj or $8000;
						fo_bnxtobj:=integer(bnxo)
					end
			end;
		_raus:
		wind_update(END_MCTRL);
		wind_update(END_UPDATE)
	end;


procedure TApplication.GOErrAlert(sign: integer; msg: string);

	begin
		Alert(nil,1,sign,'"'+StrPLeft(StrPTrimF(Name^),26)+'":|'+msg,'  &OK  ')
	end;


function TApplication.XAccMR2HR(MR: TAppTypeMR): string;
	label _raus;

	const txt : array [0..38] of string[33] =
	       ('word processor',
	        'DTP',
	        'text editor',
	        'database',
	        'spreadsheet',
	        'raster graphics application',
	        'vector graphics application',
	        'general graphics application',
	        'music application',
	        'CAD',
	        'data communication',
	        'desktop',
	        'programming environment',
	        'Textverarbeitung',
	        'DTP',
	        'Texteditor',
	        'Datenbank',
	        'Tabellenkalkulation',
	        'Rastergrafikprogramm',
	        'Vektorgrafikprogramm',
	        'Allgemeines Grafikprogramm',
	        'Musikprogramm',
	        'CAD',
	        'Datenkommunikation',
	        'Desktop',
	        'Programmiersprache',
	        'Traitement de textes',
	        'DTP',
	        'Editeur de textes',
	        'Base de donnÇes',
	        'Tableur',
	        'Application graphique: Raster',
	        'Application graphique vectorielle',
	        'Application graphique gÇnÇrale',
	        'Application musicale',
	        'CAD',
	        'DonnÇes de communication',
	        'Bureau',
	        'Environnement de programmation');

	var ret: integer;

	begin
		ret:=-1;
		if length(MR)<>2 then goto _raus;
		case (ord(MR[1]) shl 8)+ord(MR[2]) of
			22352: ret:=0;
			17488: ret:=1;
			17732: ret:=2;
			17474: ret:=3;
			21331: ret:=4;
			21063: ret:=5;
			22087: ret:=6;
			18247: ret:=7;
			19797: ret:=8;
			17220: ret:=9;
			17475: ret:=10;
			17492: ret:=11;
			20549: ret:=12
		end;
		_raus:
		if ret>=0 then
			begin
				if Attr.Country=FRA then inc(ret,26)
				else
					if (Attr.Country=FRG) or (Attr.Country=SWG) then inc(ret,13);
				XAccMR2HR:=txt[ret]
			end
		else
			XAccMR2HR:=''
	end;


procedure	TApplication.FixResource(raddr: pointer; mode,what: boolean);
	label _bitblks;

	var rsf           : PRsFile;
	    rsh           : RSHDRPtr;
	    tree          : PTree;
	    pool          : AESTreePtrArrayPtr;
	    tedinfo       : TedinfoArrayPtr;
	    iconblk       : IconBlockArrayPtr;
	    bitblk        : BitBlockArrayPtr;
	    fstrpool      : FreeStrPtrArrayPtr;
	    fimgpool      : FreeImgPtrArrayPtr;
	    obj,objCnt,typ: integer;
	    offset        : longint;
	    theMFDB       : MFDB;
	    taddr         : pointer;

	procedure	AbsToRelCoords(var coord: integer; defCharSize: integer);

		begin
			coord:=((coord mod defCharSize) shl 8)+(coord div defCharSize)
		end;

	procedure	RelToAbsCoords(var coord: integer; defCharSize: integer);

		begin
			coord:=((coord and $ff)*defCharSize)+(coord shr 8)
		end;

	procedure FixBitBlks;
		var obj: integer;

		procedure cuthalf(var pfd: MFDB);
			var q,w  : integer;
			    p1,p2: pointer;

			begin
				with pfd do
					if fd_h>2 then
						begin
							w:=fd_wdwidth shl 1;
							p2:=pointer(longint(fd_addr)+w);
							p1:=pointer(longint(p2)+w);
							for q:=0 to ((fd_h-1) shr 1)-1 do
								begin
									move(p1^,p2^,w);
									inc(longint(p1),w shl 1);
									inc(longint(p2),w)
								end
						end;
				pfd.fd_h:=pfd.fd_h shr 1
			end;

		begin
			if rsh^.rsh_nib>0 then
				for obj:=0 to rsh^.rsh_nib-1 do
					with iconblk^[obj] do
						begin
							taddr:=ib_pdata;
							if taddr<>nil then
								begin
									vdi_fix(theMFDB,taddr,ib_wicon,ib_hicon);
									if hwratio>1 then cuthalf(theMFDB);
									vr_convert(vdiHandle,theMFDB,FF_DEVSPEC)
								end;
							taddr:=ib_pmask;
							if taddr<>nil then
								begin
									vdi_fix(theMFDB,taddr,ib_wicon,ib_hicon);
									if hwratio>1 then cuthalf(theMFDB);
									vr_convert(vdiHandle,theMFDB,FF_DEVSPEC)
								end;
							if hwratio>1 then ib_hicon:=ib_hicon shr 1
						end;
			if rsh^.rsh_nbb>0 then
				for obj:=0 to rsh^.rsh_nbb-1 do
					with bitblk^[obj] do
						begin
							taddr:=bi_pdata;
							if taddr<>nil then
								begin
									vdi_fix(theMFDB,taddr,bi_wb shl 3,bi_hl);
									if hwratio>1 then cuthalf(theMFDB);
									vr_convert(vdiHandle,theMFDB,FF_DEVSPEC)
								end;
							if hwratio>1 then bi_hl:=bi_hl shr 1
						end
		end;

	procedure UnfixBitBlks;
		var obj: integer;

		begin
			if rsh^.rsh_nib>0 then
				for obj:=0 to rsh^.rsh_nib-1 do
					with iconblk^[obj] do
						begin
							taddr:=ib_pdata;
							if taddr<>nil then
								begin
									vdi_fix(theMFDB,taddr,ib_wicon,ib_hicon);
									theMFDB.fd_stand:=FF_DEVSPEC;
									vr_convert(vdiHandle,theMFDB,FF_STAND)
								end;
							taddr:=ib_pmask;
							if taddr<>nil then
								begin
									vdi_fix(theMFDB,taddr,ib_wicon,ib_hicon);
									theMFDB.fd_stand:=FF_DEVSPEC;
									vr_convert(vdiHandle,theMFDB,FF_STAND)
								end
						end;
			if rsh^.rsh_nbb>0 then
				for obj:=0 to rsh^.rsh_nbb-1 do
					with bitblk^[obj] do
						begin
							taddr:=bi_pdata;
							if taddr<>nil then
								begin
									vdi_fix(theMFDB,taddr,bi_wb shl 3,bi_hl);
									theMFDB.fd_stand:=FF_DEVSPEC;
									vr_convert(vdiHandle,theMFDB,FF_STAND)
								end
						end
		end;

	begin
		offset:=longint(raddr);
		rsf:=raddr;
		rsh:=@rsf^.rsh;
		tree:=@rsf^.rsd[rsh^.rsh_object];
		tedinfo:=@rsf^.rsd[rsh^.rsh_tedinfo];
		iconblk:=@rsf^.rsd[rsh^.rsh_iconblk];
		bitblk:=@rsf^.rsd[rsh^.rsh_bitblk];
		pool:=@rsf^.rsd[rsh^.rsh_trindex];
		fstrpool:=@rsf^.rsd[rsh^.rsh_frstr];
		fimgpool:=@rsf^.rsd[rsh^.rsh_frimg];
		if mode=UNFIXRSC then
			begin
				offset:=-offset;
				UnfixBitBlks
			end;
		if what=FIX_BBONLY then goto _bitblks;
		if rsh^.rsh_nobs>0 then
			for obj:=0 to rsh^.rsh_nobs-1 do
				with tree^[obj] do
					begin
						if mode=FIXRSC then
							begin
								RelToAbsCoords(ob_x,Attr.charSWidth);
								RelToAbsCoords(ob_y,Attr.charSHeight);
								RelToAbsCoords(ob_width,Attr.charSWidth);
								RelToAbsCoords(ob_height,Attr.charSHeight);
							end
						else
							begin
								AbsToRelCoords(ob_x,Attr.charSWidth);
								AbsToRelCoords(ob_y,Attr.charSHeight);
								AbsToRelCoords(ob_width,Attr.charSWidth);
								AbsToRelCoords(ob_height,Attr.charSHeight);
							end;
						typ:=ob_type and $ff;
						if (typ=G_TEXT) or (typ=G_BOXTEXT) or (typ=G_FTEXT) or
						   (typ=G_FBOXTEXT) or (typ=G_BUTTON) or (typ=G_STRING) or
						   (typ=G_TITLE ) or (typ=G_ICON) or (typ=G_IMAGE) or (typ=G_CICON) then inc(ob_spec.index,offset);
						if typ=G_CICON then
							if not(HasColorIcons) then ob_type:=(ob_type and $ff00) or G_ICON
					end;
		if rsh^.rsh_nted>0 then
			for obj:=0 to rsh^.rsh_nted-1 do
				with tedinfo^[obj] do
					begin
						inc(longint(te_ptext),offset);
						inc(longint(te_ptmplt),offset);
						inc(longint(te_pvalid),offset)
					end;
		if rsh^.rsh_nib>0 then
			for obj:=0 to rsh^.rsh_nib-1 do
				with iconblk^[obj] do
					begin
						inc(longint(ib_pmask),offset);
						inc(longint(ib_pdata),offset);
						inc(longint(ib_ptext),offset)
					end;
		if rsh^.rsh_nbb>0 then
			for obj:=0 to rsh^.rsh_nbb-1 do inc(longint(bitblk^[obj].bi_pdata),offset);
		if rsh^.rsh_ntree>0 then
			for obj:=0 to rsh^.rsh_ntree-1 do inc(longint(pool^[obj]),offset);
		if rsh^.rsh_nstring>0 then
			for obj:=0 to rsh^.rsh_nstring-1 do inc(longint(fstrpool^[obj]),offset);
		if rsh^.rsh_nimages>0 then
			for obj:=0 to rsh^.rsh_nimages-1 do inc(longint(fimgpool^[obj]),offset);
		if bTst(rsh^.rsh_vrsn,4) then
			begin
				{ Farbicons... }
			end;
		_bitblks:
		if mode=FIXRSC then FixBitBlks
	end;


function TApplication.MenuCorrect(mt: PTree; var i: integer): boolean;
	var abs_x,abs_y: integer;

	begin
		if (mt^[mt^[2].ob_tail].ob_x+mt^[mt^[2].ob_tail].ob_width+mt^[2].ob_x)>(SysInfo.Desktop.X+SysInfo.Desktop.W) then MenuCorrect:=false
		else
			begin
				i:=mt^[mt^[ROOT].ob_tail].ob_head-1;
				repeat
					inc(i);
					with mt^[i] do
						if ((ob_type and $ff)=G_BOX) then
							begin
								if ((ob_width>=SysInfo.Desktop.W) or (ob_height>=SysInfo.Desktop.H)) then
									begin
										MenuCorrect:=false;
										exit;
									end;
								objc_offset(mt,i,abs_x,abs_y);
								if (abs_x>=(SysInfo.Desktop.X+SysInfo.Desktop.W-ob_width)) then dec(ob_x,abs_x+1-(SysInfo.Desktop.X+SysInfo.Desktop.W-ob_width));
							end;
				until bTst(mt^[i].ob_flags,LASTOB);
				with mt^[ROOT] do
					begin
						ob_x:=0;
						ob_y:=0;
						ob_width:=Attr.MaxPX+1;
						ob_height:=Attr.MaxPY+1;
						with mt^[ob_head] do ob_width:=mt^[ROOT].ob_width;
					end;
				inc(i);
				MenuCorrect:=true;
			end;
	end;


procedure TApplication.MenuTune;
	var i: integer;

	begin
		if agi.SysNiceline then exit;
		i:=-1;
		mnusr.ub_parm:=0;
		mnusr.ub_code:=@DrawMenuRect;
		repeat
			inc(i);
			with MenuTree^[i] do
				if ((ob_type and $ff)=G_STRING) then
					if bTst(ob_state,DISABLED) and (PChar(ob_spec.free_string)^='-') then
						begin
							ob_type:=G_USERDEF;
							ob_spec.user_blk:=@mnusr;
						end;
		until bTst(MenuTree^[i].ob_flags,LASTOB);
	end;


procedure TApplication.TitleSelect(pw: PWindow; indx: integer; select: boolean);
	var box,mbox: GRECT;
	    start   : integer;

	begin
		with pw^ do
			begin
				wind_update(BEG_UPDATE);
				with Class.MenuTree^[indx] do
					begin
						if select then ob_state:=ob_state or SELECTED
						else
							ob_state:=ob_state and not(SELECTED);
						mbox.W:=ob_width;
						mbox.H:=ob_height
					end;
				objc_offset(Class.MenuTree,indx,mbox.X,mbox.Y);
				start:=Class.MenuTree^[ROOT].ob_head;
				HideMouse;
				wind_get(Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
				while (box.W>0) and (box.H>0) do
					begin
						if rc_intersect(SysInfo.Desktop,box) then
							if rc_intersect(mbox,box) then
								with box do objc_draw(Class.MenuTree,start,MAX_DEPTH,X,Y,W,H);
						wind_get(Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
					end;
				ShowMouse;
				wind_update(END_UPDATE)
			end
	end;

{ *** TAPPLICATION *** }



{ *** Objekt TDIALOG *** }

constructor TDialog.Init(AParent: PWindow; ATitle: string; Indx: integer);

	begin
		if not(inherited Init(AParent,ATitle)) then fail;
		dlgsize:=0;
		magxedit:=(MagiCVersion>=$0510);
		DisableAutoCreate;
		if Indx<>id_No then
			begin
				Application^.ChkError;
				LoadDialog(Indx);
				if Application^.Err<em_OK then
					begin
						inherited Done;
						fail
					end;
				SetupSize
			end;
		if Icon=nil then
			if Application^.ticn>ROOT then
				LoadIcon(new(PIcon,Init(@self,Application^.ticn,Application^.iicn,0,0,false,false,'','')));
		if AppFlag then
			if bTst(Class.Style,cs_AutoOpen) then MakeWindow
	end;


destructor TDialog.Done;
	var dummy: integer;

	begin
		edit_obj:=0;
		next_obj:=0;
		Cont:=false;
		pedt:=nil;
		pxfocus:=nil;
		while (CtrlList<>nil) do CtrlList^.Free;
		inherited Done
	end;


function TDialog.GetVDIHandle: integer;

	begin
		GetVDIHandle:=Application^.vdiHandle
	end;


function TDialog.GetStyle: integer;
	var ret: integer;

	begin
		ret:=NAME or CLOSER or MOVER;
		if agi.Iconify then
			begin
				if TOSVersion=$0492 then ret:=ret or $1000
				else
					ret:=ret or SMALLER
			end;
		if bTst(agi.Gadgets,2) then ret:=ret or BACKDROP;
		GetStyle:=ret
	end;


procedure TDialog.GetWindowClass(var AWndClass: TWndClass);

	begin
		inherited GetWindowClass(AWndClass);
		with AWndClass do
			begin
				Style:=(Style and not(cs_CreateOnAccOpen or cs_AutoOpen or cs_QuitOnClose or cs_OLGADocument)) or cs_SaveBits or cs_WorkBackground;
				if bTst(Application^.Attr.Style,as_CancelOnClose) then Style:=Style or cs_CancelOnClose;
				hbrBackground:=0
			end
	end;


function TDialog.GetClassName: string;

	begin
		GetClassName:='Dialog'
	end;


function TDialog.GetKBHandler: PEvent;

	begin
		GetKBHandler:=kbdh
	end;


function TDialog.IsDialog: boolean;

	begin
		IsDialog:=true
	end;


procedure TDialog.LoadDialog(Indx: integer);
	var tp,ntp: PTree;
	    fehler: boolean;
	    q     : integer;

	begin
		tp:=Application^.GetAddr(Indx);
		if (DlgTree=nil) and (tp<>nil) then
			begin
				dlgsize:=ROOT;
				while not(bTst(tp^[dlgsize].ob_flags,LASTOB)) do inc(dlgsize);
				inc(dlgsize);
				getmem(ntp,dlgsize*sizeof(AESOBJECT));
				if ntp=nil then Application^.Err:=em_InvalidDialog
				else
					begin
						fehler:=false;
						for q:=0 to dlgsize-1 do
							begin
								ntp^[q]:=tp^[q];
								with ntp^[q] do
									case (ob_type and $ff) of
									G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT:
										begin
											getmem(ob_spec.ted_info,sizeof(TEDINFO));
											if ob_spec.ted_info<>nil then
												begin
													ob_spec.ted_info^:=tp^[q].ob_spec.ted_info^;
													with ob_spec.ted_info^ do
														begin
															getmem(te_ptext,te_txtlen);
															if te_ptext<>nil then StrCopy(te_ptext,tp^[q].ob_spec.ted_info^.te_ptext)
															else
																fehler:=true
														end
												end
											else
												fehler:=true
										end;
									G_BUTTON,G_STRING,G_TITLE:
										begin
											getmem(ob_spec.free_string,StrLen(ob_spec.free_string)+1);
											if ob_spec.free_string<>nil then StrCopy(ob_spec.free_string,tp^[q].ob_spec.free_string)
											else
												fehler:=true
										end;
									G_IMAGE:
										begin
											getmem(ob_spec.bit_blk,sizeof(BITBLK));
											if ob_spec.bit_blk<>nil then ob_spec.bit_blk^:=tp^[q].ob_spec.bit_blk^
											else
												fehler:=true
										end;
									G_ICON:
										begin
											getmem(ob_spec.icon_blk,sizeof(ICONBLK));
											if ob_spec.icon_blk<>nil then
												begin
													ob_spec.icon_blk^:=tp^[q].ob_spec.icon_blk^;
													with ob_spec.icon_blk^ do
														begin
															getmem(ib_ptext,StrLen(ib_ptext)+1);
															if ib_ptext<>nil then StrCopy(ib_ptext,tp^[q].ob_spec.icon_blk^.ib_ptext)
															else
																fehler:=true
														end
												end
											else
												fehler:=true
										end
									end
							end;
						SetDlgTree(ntp);
						if fehler then
							begin
								FreeDialog;
								Application^.Err:=em_InvalidDialog
							end
						else
							if Attr.Status=ws_Open then ForceRedraw
					end
			end
		else
			Application^.Err:=em_InvalidDialog
	end;


procedure TDialog.FreeDialog;
	var q: integer;

	begin
		if DlgTree<>nil then
			if dlgsize>0 then
				begin
					for q:=0 to dlgsize-1 do
						with DlgTree^[q] do
							case (ob_type and $ff) of
							G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT:
								if ob_spec.ted_info<>nil then
									begin
										with ob_spec.ted_info^ do
											if te_ptext<>nil then freemem(te_ptext,te_txtlen);
										freemem(ob_spec.ted_info,sizeof(TEDINFO))
									end;
							G_BUTTON,G_STRING,G_TITLE:
								if ob_spec.free_string<>nil then freemem(ob_spec.free_string,StrLen(ob_spec.free_string)+1);
							G_IMAGE:
								if ob_spec.bit_blk<>nil then freemem(ob_spec.bit_blk,sizeof(BITBLK));
							G_ICON:
								if ob_spec.icon_blk<>nil then
									begin
										with ob_spec.icon_blk^ do
											if ib_ptext<>nil then freemem(ib_ptext,StrLen(ib_ptext)+1);
										freemem(ob_spec.icon_blk,sizeof(ICONBLK))
									end
							end;
					freemem(DlgTree,dlgsize*sizeof(AESOBJECT))
				end;
		inherited FreeDialog
	end;


procedure TDialog.UpdateDialog;

	begin
		if IsModal then Work:=Curr;
		inherited UpdateDialog
	end;


procedure TDialog.SetupSize;
	var wmw,wmh: integer;
	    r      : GRECT;

	begin
		inherited SetupSize;
		with DlgTree^[ROOT] do
			begin
				Work.W:=ob_width;
				Work.H:=ob_height
			end;
		wmaxw:=Work.W;
		wmaxh:=Work.H;
		GetWorkMax(wmw,wmh);
		if (wmw>wmaxw) or (wmh>wmaxh) then
			begin
				Calc(WC_WORK,SysInfo.Desktop,r);
				if wmw>wmaxw then Work.W:=Min(wmw,r.W);
				if wmh>wmaxh then Work.H:=Min(wmh,r.H)
			end;
		Calc(WC_BORDER,Work,Curr)
	end;


procedure TDialog.SetupWindow;
	var vp: INFOVSCRPtr;

	begin
		Attr.ExStyle:=ws_ex_TryModeless or ws_ex_CenterOnce;
		if GetCookie('VSCR',longint(vp)) then
			if vp<>nil then
				with vp^ do
					if (cookie=$56534352) and (version>=$0100) then Attr.ExStyle:=(Attr.ExStyle and not(ws_ex_CenterOnce)) or ws_ex_Center;
		if bTst(Application^.Attr.Style,as_MoveTransparent) then
			Attr.ExStyle:=Attr.ExStyle or ws_ex_MoveTransparent
		else
			if bTst(Application^.Attr.Style,as_MoveDials) then
				Attr.ExStyle:=Attr.ExStyle or ws_ex_MoveDial;
		edit_obj:=0;
		next_obj:=0;
		extfocus:=id_No;
		Cont:=false;
		pedt:=nil;
		pxfocus:=nil;
		BValid:=false;
		CtrlList:=nil;
		TransferBuffer:=nil;
		bsave:=true;
		d0fly:=false;
		obedflag:=false;
		obedinit:=false;
		IsModal:=false;
		if Parent<>nil then
			if Parent^.IsDialog then IsModal:=PDialog(Parent)^.IsModal;
		kbdh:=new(PDKey,Init(@self))
	end;


procedure TDialog.MakeWindow;

	begin
		Create;
		OpenWindow;
		if (IsModal) and (Application^.Err>=em_OutOfMemory) then Execute
	end;


procedure TDialog.Create;
	var r : GRECT;
	    vp: INFOVSCRPtr;

	begin
		if Attr.Status=ws_NoWindow then
			begin
				if not(IsModal) then IsModal:=not(bTst(Attr.ExStyle,ws_ex_Modeless));
				if IsModal then Attr.Status:=ws_Created
				else
					begin
						Application^.ChkError;
						inherited Create;
						if Application^.Err<em_OutOfMemory then
							if bTst(Attr.ExStyle,ws_ex_TryModeless) then
								begin
									Application^.ChkError;
									Attr.Status:=ws_Created;
									IsModal:=true
								end
					end;
				if Attr.Status=ws_Created then
					begin
						with DlgTree^[ROOT] do
							begin
								if bTst(Application^.Attr.Style,as_3DFlags) then ob_flags:=ob_flags or FL3DBAK
								else
									ob_flags:=ob_flags and not(FL3DBAK);
								if IsModal then
									begin
										ob_state:=ob_state or OUTLINED;
										Work.W:=ob_width+outlwidth*2;
										Work.H:=ob_height+outlwidth*2;
										wmaxw:=Work.W;
										wmaxh:=Work.H;
										Curr:=Work
									end
								else
									begin
										ob_state:=ob_state and not(OUTLINED);
										frwid:=ob_spec.index and $00ff0000;
										ob_spec.index:=ob_spec.index and $ff00ffff
									end
							end;
						r:=SysInfo.Desktop;
						if bTst(Attr.ExStyle,ws_ex_Center) then
							begin
								if GetCookie('VSCR',longint(vp)) then
									if vp<>nil then
										with vp^ do
											if (cookie=$56534352) and (version>=$0100) then
												begin
													r.X:=x;
													r.Y:=y;
													r.W:=w;
													r.H:=h
												end;
								if bTst(Attr.ExStyle,ws_ex_Center2Parent) then
									if Parent<>nil then
										with Parent^ do
											if Attr.Status=ws_Open then
												begin
													r.X:=Curr.X;
													r.Y:=Curr.Y;
													r.W:=Curr.W;
													r.H:=Curr.H
												end;
								Curr.X:=((r.W-Curr.W) shr 1)+r.X;
								Curr.Y:=((r.H-Curr.H) shr 1)+r.Y;
								if Curr.X+Curr.W-1>SysInfo.Desktop.X2 then Curr.X:=SysInfo.Desktop.X2+1-Curr.W;
								if Curr.Y+Curr.H-1>SysInfo.Desktop.Y2 then Curr.Y:=SysInfo.Desktop.Y2+1-Curr.H;
								if Curr.X<SysInfo.Desktop.X1 then Curr.X:=SysInfo.Desktop.X1;
								if Curr.Y<SysInfo.Desktop.Y1 then Curr.Y:=SysInfo.Desktop.Y1;
								GRtoA2(Curr);
								if bTst(Attr.ExStyle,ws_ex_CenterOnce) then
									Attr.ExStyle:=Attr.ExStyle and not(ws_ex_CenterOnce)
							end;
						if IsModal then CreateChildren
					end
			end
		else
			inherited Create
	end;


procedure TDialog.OpenWindow;
	var mx,my,dummy: integer;
	    p          : PWindow;
	    PaintInfo  : TPaintStruct;
	    pc         : PControl;

	begin
		if Attr.Status<>ws_Created then inherited OpenWindow
		else
			begin
				if bTst(Attr.ExStyle,ws_ex_Popup) then
					begin
						graf_mkstate(mx,my,dummy,dummy);
						Curr.X:=mx-(Curr.W shr 1);
						Curr.Y:=my-(Curr.H shr 1);
						if Curr.X+Curr.W-1>SysInfo.Desktop.X2 then Curr.X:=SysInfo.Desktop.X2+1-Curr.W;
						if Curr.Y+Curr.H-1>SysInfo.Desktop.Y2 then Curr.Y:=SysInfo.Desktop.Y2+1-Curr.H;
						if Curr.X<SysInfo.Desktop.X1 then Curr.X:=SysInfo.Desktop.X1;
						if Curr.Y<SysInfo.Desktop.Y1 then Curr.Y:=SysInfo.Desktop.Y1;
						GRtoA2(Curr)
					end;
				pedt:=nil;
				Cont:=true;
				pxfocus:=nil;
				dummy:=extfocus;
				extfocus:=id_No;
				if dummy<1 then
					begin
						pc:=CtrlList;
						while pc<>nil do
							begin
								if pc^.IsFlagSet(wb_ExtFocus) then
									begin
										dummy:=pc^.ObjIndx;
										break
									end;
								pc:=pc^.Next
							end
					end;
				nop;
				SetExtFocus(dummy);
				if edit_obj=0 then next_obj:=Application^.ini_field(DlgTree,0)
				else
					begin
						next_obj:=edit_obj;
						edit_obj:=0
					end;
				nop;
				TransferData(tf_SetData);
				nop;
				if not(IsModal) then inherited OpenWindow
				else
					begin
						wind_update(BEG_UPDATE);
						wind_update(BEG_MCTRL);
						inc(Application^.DlgTop);
						Attr.Status:=ws_Open;
						SaveBackground;
						if bTst(Application^.Attr.Style,as_GrowShrink) then form_box(FMD_GROW,Curr);
						with PaintInfo do
							begin
								fErase:=false;
								rcPaint:=Curr
							end;
						HideMouse;
						UpdateDialog;
						InitPaint;
						Paint(PaintInfo);
						ExitPaint;
						ShowMouse;
						p:=ChildList;
						while (p<>nil) do
							with p^ do
								begin
									OpenWindow;
									p:=Nxt
								end
					end
			end
	end;


procedure TDialog.CloseWindow;
	var p    : PWindow;
	    dummy: integer;

	begin
		p:=ChildList;
		while (p<>nil) do
			with p^ do
				begin
					CloseWindow;
					p:=Nxt
				end;
		if Attr.Status=ws_Open then
			begin
				if edit_obj>0 then
					begin
						objc_edit(dummy,EDEND,K_NORMAL,Work.A2,true);
						next_obj:=0;
						Cont:=false;
						pxfocus:=nil;
						pedt:=nil
					end;
				if IsModal then
					begin
						if bTst(Application^.Attr.Style,as_GrowShrink) then form_box(FMD_SHRINK,Curr);
						RestoreBackground;
						dec(Application^.DlgTop);
						Attr.Status:=ws_Created;
						wind_update(END_MCTRL);
						wind_update(END_UPDATE)
					end
				else
					inherited CloseWindow
			end
	end;


procedure TDialog.Destroy;
	var p    : PWindow;
	    dummy: integer;

	begin
		p:=ChildList;
		while (p<>nil) do
			with p^ do
				begin
					Destroy;
					p:=Nxt
				end;
		if Attr.Status in [ws_Created,ws_Open] then
			begin
				if IsModal then
					begin
						CloseWindow;
						IsModal:=false;
						Attr.Status:=ws_NoWindow
					end
				else
					begin
						with DlgTree^[ROOT] do
							ob_spec.index:=ob_spec.index or frwid;
						inherited Destroy
					end
			end
	end;


procedure TDialog.Paint(var PaintInfo: TPaintStruct);
	var dummy: integer;

	begin
		with PaintInfo.rcPaint do objc_draw(DlgTree,ROOT,MAX_DEPTH,X,Y,W,H);
		if pxfocus<>nil then
			begin
				vs_clip(vdiHandle,CLIP_ON,PaintInfo.rcPaint.A2);
				pxfocus^.ExtFocusPaint(PaintInfo.rcPaint)
			end;
		if (next_obj>0) and (edit_obj<>next_obj) then
			begin
				edit_obj:=next_obj;
				next_obj:=0;
				CallChanged(edit_obj,false,true,false);
				objc_edit(dummy,EDINIT,K_NORMAL,PaintInfo.rcPaint.A2,false)
			end
		else
			if edit_obj>0 then
				objc_edit(dummy,EDDRAW,K_NORMAL,PaintInfo.rcPaint.A2,false);
		if IsModal then vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
		else
			vs_clip(Application^.vdiHandle,CLIP_ON,PaintInfo.rcPaint.A2)
	end;


procedure TDialog.ObjcPaint(Indx: integer; Lazy: boolean);

	begin
		ObjcPaintRect(Indx,SysInfo.Desktop,Lazy)
	end;


procedure TDialog.ObjcPaintRect(Indx: integer; const Rect: GRECT; Lazy: boolean);
	label _weiter;

	var box    : GRECT;
	    visible: boolean;

	begin
		if Attr.Status=ws_Open then
			if not(IsIconified) then
				begin
					if IsModal then
						begin
							HideMouse;
							with Rect do objc_draw(DlgTree,Indx,MAX_DEPTH,X,Y,W,H);
							if pxfocus<>nil then
								if Indx=extfocus then pxfocus^.ExtFocusPaint(Rect);
							ShowMouse
						end
					else
						begin
							if Lazy then
								if agi.WindUpdate then
									begin
										if wind_update(TEST_BEG_UPDATE)=0 then exit
										else
											goto _weiter
									end;
							wind_update(BEG_UPDATE);
							_weiter:
							HideMouse;
							visible:=FirstWorkRect(box);
							while visible do
								begin
									if rc_intersect(Rect,box) then
										begin
											with box do objc_draw(DlgTree,Indx,MAX_DEPTH,X,Y,W,H);
											if pxfocus<>nil then
												if Indx=extfocus then
													begin
														vs_clip(vdiHandle,CLIP_ON,box.A2);
														pxfocus^.ExtFocusPaint(box)
													end
										end;
									visible:=NextWorkRect(box)
								end;
							vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2);
							ShowMouse;
							wind_update(END_UPDATE)
						end
				end
	end;


procedure TDialog.GetWorkMax(var maxX,maxY: integer);

	begin
		maxX:=wmaxw;
		maxY:=wmaxh
	end;


procedure TDialog.WMClosed;
	var valid   : boolean;
	    tst,indx: integer;
	    p       : PControl;

	begin
		if bTst(Class.Style,cs_CancelOnClose) then tst:=id_Cancel
		else
			tst:=id_OK;
		p:=CtrlList;
		indx:=-1;
		while p<>nil do
			begin
				if p^.TestID(tst) then
					begin
						indx:=p^.ObjIndx;
						break
					end;
				p:=p^.Nxt
			end;
		if indx>=0 then
			begin
				if p^.GetState<>bf_Enabled then exit;
				if bTst(DlgTree^[indx].ob_flags,SELECTABLE) then
					begin
						DlgTree^[indx].ob_state:=DlgTree^[indx].ob_state or SELECTED;
						ObjcPaint(indx,false)
					end
			end;
		valid:=false;
		if CanClose then
			begin
				if tst=id_Cancel then valid:=Cancel
				else
					valid:=OK
			end;
		if valid then
			begin
				if indx>=0 then
					if bTst(DlgTree^[indx].ob_flags,SELECTABLE) then
						DlgTree^[indx].ob_state:=DlgTree^[indx].ob_state and not(SELECTED);
				Destroy;
				if bTst(Class.Style,cs_QuitOnClose) then
					begin
						with Application^ do if ChkError>=em_OutOfMemory then Quit
					end
				else
					if bTst(Class.Style,cs_FreeOnClose) then Free
			end
		else
			if indx>=0 then
				if bTst(DlgTree^[indx].ob_flags,SELECTABLE) then
					begin
						DlgTree^[indx].ob_state:=DlgTree^[indx].ob_state and not(SELECTED);
						ObjcPaint(indx,false)
					end
	end;


procedure TDialog.WMButton(mX,mY,BStat,KStat,Clicks: integer);
	label _fly;

	var nx,dummy,
	    d2,oldtype: integer;
	    pinfo     : TPaintStruct;
	    kbh       : PEvent;
	    ltmove    : function(d1,d2: pointer; d3,d4,d5: longint; tree: PTree; x,y: integer): integer;

	begin
		kbh:=GetKBHandler;
		nx:=objc_find(DlgTree,ROOT,MAX_DEPTH,mX,mY);
		if BStat=2 then
			begin
				if Clicks=2 then
					begin
						Top;
						exit
					end
				else
					if nx>=0 then
						begin
							if IsHelpAvailable(mX,mY) then Application^.BubbleHelp(mX,mY,GetHelp(mX,mY),false,false);
							exit
						end
			end;
		if nx=-1 then
			begin
				if IsModal then
					begin
						if BStat=1 then
							begin
								if ltmf<>nil then
									if ltmf^.version>=$0115 then
										begin
											ltmove:=ltmf^.di_moveto;
											ltmove(nil,nil,0,0,0,DlgTree,mX,mY);
											Curr.X:=DlgTree^[ROOT].ob_x-outlwidth;
											Curr.Y:=DlgTree^[ROOT].ob_y-outlwidth;
											GRtoA2(Curr);
											UpdateDialog;
											exit
										end;
								HideMouse;
								RestoreBackground;
								dummy:=Curr.X;
								d2:=Curr.Y;
								Curr.X:=mX-(DlgTree^[ROOT].ob_width shr 1);
								Curr.Y:=mY-(DlgTree^[ROOT].ob_height shr 1);
								if Curr.X+Curr.W-1>SysInfo.Desktop.X2 then Curr.X:=SysInfo.Desktop.X2+1-Curr.W;
								if Curr.Y+Curr.H-1>SysInfo.Desktop.Y2 then Curr.Y:=SysInfo.Desktop.Y2+1-Curr.H;
								if Curr.X<SysInfo.Desktop.X then Curr.X:=SysInfo.Desktop.X;
								if Curr.Y<SysInfo.Desktop.Y then Curr.Y:=SysInfo.Desktop.Y;
								GRtoA2(Curr);
								graf_movebox(Curr.W,Curr.H,dummy,d2,Curr.X,Curr.Y);
								SaveBackground;
								with pinfo do
									begin
										fErase:=false;
										rcPaint:=Curr
									end;
								UpdateDialog;
								InitPaint;
								Paint(pinfo);
								ExitPaint;
								ShowMouse
							end;
						Application^.Bing
					end
				else
					inherited WMButton(mX,mY,BStat,KStat,Clicks);
				exit
			end;
		if BStat<>1 then exit;
		if DlgTree^[nx].ob_flags and (SELECTABLE or DEFAULT or F_EXIT or EDITABLE or RBUTTON or TOUCHEXIT)=0 then
			begin
				oldtype:=DlgTree^[nx].ob_type and $00ff;
				if (oldtype=G_FTEXT) or (oldtype=G_FBOXTEXT) then
					if SelectDisabled(nx,KStat,Clicks) then exit;
				_fly:
				if not(IsModal) then Top
				else
					if d0fly and (Clicks=1) then MoveDial(mX,mY);
				exit
			end;
		if not(bTst(DlgTree^[nx].ob_state,DISABLED)) then
			begin
				next_obj:=nx;
				Cont:=Application^.form_button(@self,next_obj,Clicks,next_obj);
				if not(Cont) then
					begin
						nx:=next_obj;
						next_obj:=0;
						CallChanged(word(nx) and $7fff,bTst(word(nx),$8000),false,false);
						EndDlg(integer(word(nx) and $7fff),bTst(word(nx),$8000))
					end
				else
					begin
						if (next_obj>0) and (edit_obj<>next_obj) then
							begin
								objc_edit(dummy,EDEND,K_NORMAL,Work.A2,true);
								edit_obj:=next_obj;
								next_obj:=0;
								CallChanged(edit_obj,false,true,false);
								objc_edit(dummy,EDINIT,K_NORMAL,Work.A2,true)
							end
						else
							begin
								if next_obj<=0 then CallChanged(nx,false,false,true)
								else
									objc_edit(mX,EDIDXPOS,K_NORMAL,Work.A2,true)
							end
					end
			end
		else
			if not(SelectDisabled(nx,KStat,Clicks)) then goto _fly
	end;


function TDialog.SelectDisabled(AnIndx,KStat,Clicks: integer): boolean;

	begin
		SelectDisabled:=false
	end;


procedure TDialog.Execute;
	var evnt,mx,my,
	    mb,ks,kr,br,
	    eventmask  : integer;
	    modtimer   : longint;
	    pipe       : Pipearray;
	    gmnr       : HCursor;
	    gmform     : MFORM;
	    kbh        : PEvent;
	    valid      : boolean;

	begin
		if not(IsModal) then exit;
		kbh:=GetKBHandler;
		GetMouse(gmnr,gmform);
		if Class.hCursor>id_No then
			begin
				if Class.hCursor>$7fff then SetMouse(USER_DEF,pointer(Class.hCursor))
				else
					SetMouse(Class.hCursor,nil)
			end
		else
			SetMouse(ARROW,nil);
		if bTst(Attr.ExStyle,ws_ex_MoveDial) then d0fly:=true;
		eventmask:=MU_KEYBD or MU_BUTTON;
		while Cont do
			begin
				if (next_obj>0) and (edit_obj<>next_obj) then
					begin
						edit_obj:=next_obj;
						next_obj:=0;
						CallChanged(edit_obj,false,true,false);
						objc_edit(evnt,EDINIT,K_NORMAL,Work.A2,false)
					end;
				modtimer:=GetModalTimer;
				if modtimer>0 then eventmask:=eventmask or MU_TIMER
				else
					eventmask:=eventmask and not(MU_TIMER);
				evnt:=evnt_multi(eventmask,258,3,0,0,0,0,0,0,0,0,0,0,0,pipe,modtimer mod 65536,modtimer div 65536,mx,my,mb,ks,kr,br);
				if bTst(evnt,MU_KEYBD) then
					begin
						valid:=true;
						if ks=K_CTRL then
							case kr of
							Ctrl_X:
								begin
									Cut;
									valid:=false
								end;
							Ctrl_C:
								begin
									Copy;
									valid:=false
								end;
							Ctrl_V:
								begin
									Paste;
									valid:=false
								end
							end;
						if valid then
							if kbh<>nil then kbh^.TestKey(ks,kr)
					end;
				if bTst(evnt,MU_BUTTON) then WMButton(mx,my,mb,ks,br);
				if bTst(evnt,MU_TIMER) then HandleModalTimer;
				if (next_obj>0) and (next_obj<>edit_obj) then objc_edit(evnt,EDEND,K_NORMAL,Work.A2,false)
			end;
		d0fly:=false;
		SetMouse(gmnr,@gmform)
	end;


procedure TDialog.EndDlg(Indx: integer; DblClick: boolean);
	label _cont;

	var p          : PControl;
	    valid,found: boolean;

	begin
		Result:=Indx;
		found:=false;
		valid:=true;
		p:=CtrlList;
		while (p<>nil) do
			begin
				if p^.TestIndex(Indx) then
					begin
						if p^.TestID(id_OK) then
							begin
								found:=true;
								valid:=OK
							end;
						if p^.TestID(id_Cancel) then
							begin
								found:=true;
								valid:=Cancel
							end;
						if p^.TestID(id_Help) then
							begin
								found:=true;
								valid:=Help
							end;
						if p^.TestID(id_Undo) then
							begin
								found:=true;
								valid:=Undo
							end;
						if p^.TestID(id_Esc) then
							begin
								found:=true;
								valid:=Esc
							end;
						if p^.TestID(id_NoExit) then
							begin
								found:=true;
								valid:=false
							end
					end;
				p:=p^.Nxt
			end;
		if not(found) then valid:=ExitDlg(Indx);
		if not(valid) then goto _cont;
		if CanClose then
			begin
				if bTst(DlgTree^[Indx].ob_flags,SELECTABLE) then DlgTree^[Indx].ob_state:=DlgTree^[Indx].ob_state and not(SELECTED);
				Destroy
			end
		else
			begin
				_cont:
				Cont:=true;
				if bTst(DlgTree^[Indx].ob_flags,SELECTABLE) then
					begin
						DlgTree^[Indx].ob_state:=DlgTree^[Indx].ob_state and not(SELECTED);
						ObjcPaint(Indx,false)
					end
			end
	end;


procedure TDialog.TransferData(Direction: word);
	var p : PControl;
	    tp: pointer;

	begin
		if TransferBuffer<>nil then
			begin
				p:=CtrlList;
				tp:=TransferBuffer;
				while p<>nil do
					with p^ do
						begin
							if IsFlagSet(wb_Transfer) then
								inc(longint(tp),longint(Transfer(tp,Direction)));
							p:=Nxt
						end
			end
	end;


function TDialog.ExitDlg(AnIndx: integer): boolean;

	begin
		ExitDlg:=true
	end;


function TDialog.OK: boolean;
	var vald: boolean;
	    p   : PControl;

	begin
		vald:=true;
		p:=CtrlList;
		while (p<>nil) and vald do
			begin
				if bTst(p^.Style,cs_Edit) then vald:=PEdit(p)^.CanClose;
				p:=p^.Nxt
			end;
		if vald then TransferData(tf_GetData);
		OK:=vald
	end;


function TDialog.Cancel: boolean;

	begin
		Cancel:=true
	end;


function TDialog.Help: boolean;

	begin
		Help:=false
	end;


function TDialog.Undo: boolean;

	begin
		Undo:=false
	end;


function TDialog.Esc: boolean;

	begin
		Esc:=false
	end;


function TDialog.TestFKey(fNum: integer): integer;

	begin
		TestFKey:=id_No
	end;


procedure TDialog.Cut;

	begin
		if pedt<>nil then pedt^.Cut
	end;


procedure TDialog.Copy;

	begin
		if pedt<>nil then pedt^.Copy
	end;


procedure TDialog.Paste;

	begin
		if pedt<>nil then pedt^.Paste
	end;


procedure TDialog.Delete;
	var kbh: PEvent;

	begin
		kbh:=GetKBHandler;
		if kbh<>nil then kbh^.TestKey(K_NORMAL,S_Delete)
	end;


function TDialog.FirstThat(Test: PIterationFunc): PControl;
	var p : PControl;
	    cl: IterationFunc;

	begin
		FirstThat:=nil;
		p:=CtrlList;
		cl:=IterationFunc(Test);
		while p<>nil do
			begin
				if cl(p) then
					begin
						FirstThat:=p;
						exit
					end;
				p:=p^.Nxt
			end
	end;


procedure TDialog.ForEach(Action: PIterationProc);
	var p : PControl;
	    cl: IterationProc;

	begin
		p:=CtrlList;
		cl:=IterationProc(Action);
		while p<>nil do
			begin
				cl(p);
				p:=p^.Nxt
			end
	end;


procedure TDialog.SetDefaultButton(Obj: integer);
	var old    : integer;
	    pxy,box: GRECT;
	    visible: boolean;
	    ctrl   : PControl;

	procedure findobject(indx: integer);
		var p: PControl;

		begin
			ctrl:=nil;
			p:=CtrlList;
			while (p<>nil) do
				begin
					if p^.TestIndex(indx) then
						if bTst(p^.Style,cs_PushButton) then
							begin
								ctrl:=p;
								exit
							end;
					p:=p^.Nxt
				end
		end;

	begin
		old:=GetDefaultButton;
		if old=Obj then exit;
		ctrl:=nil;
		if old>=ROOT then
			begin
				with DlgTree^[old] do
					begin
						ob_flags:=ob_flags and not(DEFAULT);
						objc_offset(DlgTree,old,pxy.X,pxy.Y);
						dec(pxy.X,5);
						dec(pxy.Y,5);
						pxy.W:=ob_width+10;
						pxy.H:=ob_height+10
					end;
				findobject(old);
				if ctrl<>nil then ctrl^.Style:=ctrl^.Style and not(bs_DefPushButton);
				if Attr.Status=ws_Open then
					if not(IsIconified) then
						begin
							if IsModal then
								begin
									HideMouse;
									with pxy do objc_draw(DlgTree,ROOT,MAX_DEPTH,X,Y,W,H);
									ShowMouse
								end
							else
								begin
									wind_update(BEG_UPDATE);
									HideMouse;
									visible:=FirstWorkRect(box);
									while visible do
										begin
											if rc_intersect(pxy,box) then
												with box do objc_draw(DlgTree,ROOT,MAX_DEPTH,X,Y,W,H);
											visible:=NextWorkRect(box)
										end;
									ShowMouse;
									wind_update(END_UPDATE)
								end
						end
			end;
		if Obj>=ROOT then
			begin
				with DlgTree^[Obj] do ob_flags:=ob_flags or DEFAULT;
				findobject(Obj);
				if ctrl<>nil then ctrl^.Style:=ctrl^.Style or bs_DefPushButton;
				ObjcPaint(Obj,false)
			end
	end;


function TDialog.GetDefaultButton: integer;
	var q: integer;

	begin
		GetDefaultButton:=id_No;
		q:=-1;
		repeat
			inc(q);
			if bTst(DlgTree^[q].ob_flags,DEFAULT) then
				begin
					GetDefaultButton:=q;
					exit
				end
		until bTst(DlgTree^[q].ob_flags,LASTOB)
	end;


function TDialog.InsertChar(ch: char): boolean;
	var key: integer;

	begin
		key:=ord(ch);
		objc_edit(key,EDCHAR,K_NORMAL,Work.A2,true);
		InsertChar:=(key=0)
	end;


procedure TDialog.InitFocus;
	var dummy: integer;

	begin
		if edit_obj>0 then objc_edit(dummy,EDEND,K_NORMAL,Work.A2,true);
		edit_obj:=0;
		next_obj:=Application^.ini_field(DlgTree,0);
		if next_obj>0 then
			begin
				edit_obj:=next_obj;
				next_obj:=0;
				CallChanged(edit_obj,false,true,false);
				objc_edit(dummy,EDINIT,K_NORMAL,Work.A2,true)
			end
	end;


procedure TDialog.SetFocus(Obj: integer);
	var dummy: integer;

	begin
		if Obj>0 then
			begin
				if bTst(DlgTree^[Obj].ob_flags,EDITABLE) and not(Application^.IsTreeHidden(DlgTree,Obj)) and not(bTst(DlgTree^[Obj].ob_state,DISABLED)) then
					begin
						if edit_obj>0 then objc_edit(dummy,EDEND,K_NORMAL,Work.A2,true);
						edit_obj:=Obj;
						next_obj:=0;
						CallChanged(edit_obj,false,true,false);
						objc_edit(dummy,EDINIT,K_NORMAL,Work.A2,true)
					end
				else
					InitFocus
			end
		else
			InitFocus
	end;


function TDialog.GetFocus: integer;

	begin
		if edit_obj>0 then GetFocus:=edit_obj
		else
			GetFocus:=id_No
	end;


procedure TDialog.SetExtFocus(Obj: integer);
	var pc,nc: PControl;

	begin
		if Obj<0 then Obj:=id_No;
		if Obj=GetExtFocus then exit;
		nc:=nil;
		if Obj>=0 then
			begin
				pc:=CtrlList;
				while pc<>nil do
					begin
						if pc^.TestIndex(Obj) then
							if pc^.IsFlagSet(wb_ExtFocus) then
								begin
									nc:=pc;
									break
								end;
						pc:=pc^.Next
					end
			end;
		if pxfocus<>nil then
			begin
				pc:=pxfocus;
				pxfocus:=nil;
				pc^.Paint
			end;
		if nc<>nil then
			begin
				pxfocus:=nc;
				extfocus:=Obj;
				pxfocus^.Paint
			end
		else
			extfocus:=id_No
	end;


function TDialog.GetExtFocus: integer;

	begin
		if extfocus<0 then GetExtFocus:=id_No
		else
			GetExtFocus:=extfocus
	end;


function TDialog.HasActiveFocus(obj: integer): boolean;

	begin
		HasActiveFocus:=not(obedflag) and obedinit and (GetFocus=obj)
	end;


procedure TDialog.CallChanged(Indx: integer; dclk,edt,push: boolean);
	var p: PControl;

	begin
		p:=CtrlList;
		if edt then pedt:=nil;
		while (p<>nil) do
			begin
				if p^.TestIndex(Indx) then
					begin
						if edt then pedt:=PEdit(p);
						if not(bTst(p^.Style,cs_PushButton)) or not(push) then p^.Changed(Indx,dclk)
						else
							if bTst(p^.ObjAddr^.ob_state,SELECTED) then p^.Changed(Indx,dclk);
						exit
					end
				else
					p:=p^.Nxt
			end
	end;


function TDialog.GetHelp(mX,mY: integer): string;
	var indx: integer;
	    pc  : PControl;

	begin
		GetHelp:='';
		if IsIconified then exit;
		indx:=objc_find(DlgTree,ROOT,MAX_DEPTH,mX,mY);
		if indx>=0 then
			begin
				pc:=CtrlList;
				while pc<>nil do
					begin
						if pc^.TestIndex(indx) then
							begin
								if pc^.IsHelpAvailable then GetHelp:=pc^.GetHelp;
								exit
							end;
						pc:=pc^.Next
					end
			end;
		GetHelp:=inherited GetHelp(mX,mY)
	end;


function TDialog.GetModalTimer: longint;

	begin
		GetModalTimer:=0
	end;


procedure TDialog.HandleModalTimer;

	begin
	end;


	{ private }


procedure TDialog.MoveDial(mX,mY: integer);
	var nx,ny,w,h: integer;
	    pinfo    : TPaintStruct;
	    ltfly    : procedure(d1,d2: pointer; d3,d4,d5: longint; tree: PTree);

	begin
		if ltmf<>nil then
			begin
				ltfly:=ltmf^.di_fly;
				ltfly(nil,nil,0,0,0,DlgTree);
				Curr.X:=DlgTree^[ROOT].ob_x-outlwidth;
				Curr.Y:=DlgTree^[ROOT].ob_y-outlwidth;
				GRtoA2(Curr);
				UpdateDialog;
				exit
			end;
		if bTst(Attr.ExStyle,ws_ex_MoveTransparent) then RestoreBackground;
		graf_mouse(FLAT_HAND,nil);
		graf_dragbox(Curr.W,Curr.H,Curr.X,Curr.Y,SysInfo.Desktop.X,SysInfo.Desktop.Y,SysInfo.Desktop.W+Curr.X+Curr.W-mX-1,SysInfo.Desktop.H+Curr.Y+Curr.H-mY-1,nx,ny);
		HideMouse;
		if (Curr.X<>nx) or (Curr.Y<>ny) or bTst(Attr.ExStyle,ws_ex_MoveTransparent) then
			begin
				if not(bTst(Attr.ExStyle,ws_ex_MoveTransparent)) then RestoreBackground;
				Curr.X:=nx;
				Curr.Y:=ny;
				GRtoA2(Curr);
				SaveBackground;
				with pinfo do
					begin
						fErase:=false;
						rcPaint:=Curr
					end;
				UpdateDialog;
				InitPaint;
				Paint(pinfo);
				ExitPaint
			end;
		graf_mouse(maus.currnr,@maus.currform);
		ShowMouse
	end;


procedure TDialog.SaveBackground;
	var box : GRECT;
	    scrn: MFDB;
	    pxy : ARRAY_8;

	begin
		if (IsModal) and (bsave) then
			begin
				bsave:=false;
				box:=Curr;
				if rc_intersect(SysInfo.Desktop,box) then
					begin
						if ltmf<>nil then
							begin
								form_dial(FMD_START,0,0,0,0,box.X,box.Y,box.W,box.H);
								exit
							end;
						with BackGr do
							begin
								fd_w:=box.W;
								fd_h:=box.H;
								fd_stand:=FF_DEVSPEC;
								fd_wdwidth:=(fd_w+15) shr 4;
								fd_nplanes:=Application^.Attr.Planes;
								BLen:=(longint(fd_wdwidth)*longint(fd_h)*longint(fd_nplanes)) shl 1
							end;
						if not(bTst(Class.Style,cs_SaveBits)) then BackGr.fd_addr:=nil
						else
							getmem(BackGr.fd_addr,BLen);
						if BackGr.fd_addr=nil then
							form_dial(FMD_START,0,0,0,0,box.X,box.Y,box.W,box.H)
						else
							begin
								scrn.fd_addr:=nil;
								pxy[0]:=box.X;
								pxy[1]:=box.Y;
								pxy[2]:=box.X+box.W-1;
								pxy[3]:=box.Y+box.H-1;
								pxy[4]:=0;
								pxy[5]:=0;
								pxy[6]:=BackGr.fd_w-1;
								pxy[7]:=BackGr.fd_h-1;
								BValid:=true;
								HideMouse;
								vro_cpyfm(Application^.vdiHandle,S_ONLY,pxy,scrn,BackGr);
								ShowMouse
							end
					end
			end
	end;


procedure TDialog.RestoreBackground;
	var box  : GRECT;
	    scrn : MFDB;
	    pxy  : ARRAY_8;

	begin
		if (IsModal) and not(bsave) then
			begin
				bsave:=true;
				box:=Curr;
				if rc_intersect(SysInfo.Desktop,box) then
					begin
						if BValid then
							begin
								scrn.fd_addr:=nil;
								pxy[0]:=0;
								pxy[1]:=0;
								pxy[2]:=BackGr.fd_w-1;
								pxy[3]:=BackGr.fd_h-1;
								pxy[4]:=box.X;
								pxy[5]:=box.Y;
								pxy[6]:=box.X+box.W-1;
								pxy[7]:=box.Y+box.H-1;
								BValid:=false;
								HideMouse;
								vro_cpyfm(Application^.vdiHandle,S_ONLY,pxy,BackGr,scrn);
								ShowMouse;
								freemem(BackGr.fd_addr,BLen)
							end
						else
							begin
								form_dial(FMD_FINISH,0,0,0,0,box.X,box.Y,box.W,box.H);
								if ltmf=nil then Application^.RestoreModalDialog(Parent)
							end
					end
			end
	end;


function TDialog.objc_edit(var ob_edchar: integer; ob_edkind,ob_kstat: integer; clp: ARRAY_4; cclp: boolean): integer;
	label _delline,_edidx;

	var typ,ox,oy,toffs,
	    q,chw,vlen     : integer;
	    pted           : TEDINFOPtr;
	    mgvalid,doedit : boolean;
	    thechar,vchar  : char;
	    mr             : GRECT;

	function getptmplt: pointer;
	
		begin
			if pted^.te_ptmplt<>nil then getptmplt:=pted^.te_ptmplt
			else
				getptmplt:=PXTED(pted^.te_pvalid)^.xte_ptmplt
		end;
	
	function getpvalid: pointer;
	
		begin
			if pted^.te_ptmplt<>nil then getpvalid:=pted^.te_pvalid
			else
				getpvalid:=PXTED(pted^.te_pvalid)^.xte_pvalid
		end;
	
	function ValidChar(mask: char): boolean;

		begin
			if pedt<>nil then
				if bTst(pedt^.Style,es_ASCIIOnly) then
					if not(thechar in [' '..'~']) then
						begin
							ValidChar:=false;
							exit
						end;
			ValidChar:=false;
			case mask of
				'X': ValidChar:=true;
				'9': if thechar in ['0'..'9'] then ValidChar:=true;
				'A': if upcase(thechar) in [' ','A'..'Z'] then
							 begin
								 ValidChar:=true;
								 thechar:=upcase(thechar)
							 end;
				'a': if thechar in [' ','A'..'Z','a'..'z'] then ValidChar:=true;
				'N': if upcase(thechar) in [' ','0'..'9','A'..'Z'] then
							 begin
								 ValidChar:=true;
								 thechar:=upcase(thechar)
							 end;
				'n': if thechar in [' ','0'..'9','A'..'Z','a'..'z'] then ValidChar:=true;
				'F': if thechar in ['!'..'-','0'..'9',';'..'[',']'..'~'] then ValidChar:=true;
				'f': if thechar in ['!'..')','+'..'-',';'..'>','0'..'9','@'..'[',']'..'~'] then ValidChar:=true;
				'P': if thechar in ['!'..'.','0'..'~'] then ValidChar:=true;
				'p': if thechar in ['!'..')','+'..'.','0'..'>','@'..'~'] then ValidChar:=true;
				'H': if upcase(thechar) in ['0'..'9','A'..'F'] then ValidChar:=true;
				'D': if thechar in ['0'..'9','+','-',',','.'] then ValidChar:=true;
				'+': if (thechar='+') or (thechar='-') then ValidChar:=true
			end
		end;

	function getmaxidx: integer;

		begin
			getmaxidx:=StrLen(pted^.te_ptext)
		end;
	
	procedure checkscroll;
	
		begin
			if pted^.te_ptmplt=nil then
				if idx-PXTED(pted^.te_pvalid)^.xte_scroll>PXTED(pted^.te_pvalid)^.xte_vislen then
					PXTED(pted^.te_pvalid)^.xte_scroll:=idx-PXTED(pted^.te_pvalid)^.xte_vislen
		end;
	
	procedure scrollto0;
	
		begin
			idx:=0;
			if pted^.te_ptmplt=nil then PXTED(pted^.te_pvalid)^.xte_scroll:=0;
			if pedt<>nil then pedt^.EdIdx:=0
		end;
	
	procedure scrolltoend;
	
		begin
			idx:=getmaxidx;
			if pted^.te_ptmplt=nil then PXTED(pted^.te_pvalid)^.xte_scroll:=Max(0,idx-PXTED(pted^.te_pvalid)^.xte_vislen);
			if pedt<>nil then pedt^.EdIdx:=idx
		end;
	
	procedure decscroll;
	
		begin
			dec(idx);
			if pted^.te_ptmplt=nil then
				if idx<PXTED(pted^.te_pvalid)^.xte_scroll then PXTED(pted^.te_pvalid)^.xte_scroll:=idx;
			if pedt<>nil then pedt^.EdIdx:=idx
		end;

	procedure eprint(ce: boolean);
		var ot: integer;

		begin
			if ce then if pedt<>nil then pedt^.Edit;
			if idx>getmaxidx then scrolltoend;
			if pedt<>nil then
				if bTst(pedt^.Style,es_Password) then
					StrPCopy(pted^.te_ptext,StrPFill(StrLen(pted^.te_ptext),'*'));
			ot:=DlgTree^[edit_obj].ob_type;
			DlgTree^[edit_obj].ob_type:=G_FTEXT;
			ObjcPaint(edit_obj,false);
			DlgTree^[edit_obj].ob_type:=ot;
			ob_edchar:=0
		end;

	procedure cursor;
		var box    : GRECT;
		    visible: boolean;

		procedure cursor_prnt;
			var anz: integer;

			begin
				q:=toffs;
				anz:=0;
				while anz<idx do
					begin
						if PChar(longint(getptmplt)+q)^='_' then inc(anz);
						inc(q)
					end;
				if idx<pted^.te_txtlen-1 then
					while PChar(longint(getptmplt)+q)^<>'_' do inc(q);
				if pted^.te_ptmplt=nil then dec(q,PXTED(pted^.te_pvalid)^.xte_scroll);
				vswr_mode(Application^.vdiHandle,MD_XOR);
				pxya[0]:=ox+(q-toffs)*chw;
				pxya[1]:=oy;
				pxya[2]:=pxya[0];
				pxya[3]:=oy+SysInfo.Font.Height+2;
				HideMouse;
				v_pline(Application^.vdiHandle,2,pxya);
				ShowMouse;
				vswr_mode(Application^.vdiHandle,MD_REPLACE)
			end;

		begin
			if not(cclp) or IsModal then cursor_prnt
			else
				begin
					visible:=FirstWorkRect(box);
					while visible do
						begin
							vs_clip(Application^.vdiHandle,CLIP_ON,box.A2);
							cursor_prnt;
							visible:=NextWorkRect(box)
						end;
					vs_clip(Application^.vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
				end
		end;
	
	procedure magxcursor;
		var box    : GRECT;
		    visible: boolean;
	
		begin
			if not(cclp) or IsModal then objc_xedit(DlgTree,edit_obj,ob_edchar,idx,ED_DRAW,nil)
			else
				begin
					visible:=FirstWorkRect(box);
					while visible do
						begin
							objc_xedit(DlgTree,edit_obj,ob_edchar,idx,ED_DRAW,@box);
							visible:=NextWorkRect(box)
						end
				end
		end;

	begin
		if magxedit then
			begin
				case ob_edkind of
				EDINIT:
					begin
						obedinit:=true;
						if pedt<>nil then idx:=pedt^.EdIdx
						else
							idx:=-1;
						if IsModal then objc_edit:=Gem.objc_edit(DlgTree,edit_obj,ob_edchar,idx,EDINIT)
						else
							objc_edit:=objc_wedit(DlgTree,edit_obj,ob_edchar,idx,EDINIT,Attr.gemHandle)
					end;
				EDCHAR:
					begin
						obedflag:=true;
						case ob_edchar of
						S_Esc,BackSpace,S_Delete:
							begin
								if pedt<>nil then
									if bTst(pedt^.Style,es_Password) then ob_edchar:=S_Esc;
								mgvalid:=true;
								doedit:=true
							end;
						Cur_Left,Cur_Right,
						Shift_CL,$7300,Shift_CR,$7400:
							begin
								mgvalid:=true;
								doedit:=false
							end;
						S_Undo:
							begin
								if pedt<>nil then
									if pedt^.CanUndo then
										begin
											obedflag:=false;
											pedt^.Undo;
											obedflag:=true
										end;
								ob_edchar:=0;
								mgvalid:=false;
								doedit:=false
							end
						else
							begin
								mgvalid:=lo(ob_edchar)>=32;
								doedit:=mgvalid
							end
						end;
						if mgvalid then
							begin
								if IsModal then objc_edit:=Gem.objc_edit(DlgTree,edit_obj,ob_edchar,idx,EDCHAR)
								else
									objc_edit:=objc_wedit(DlgTree,edit_obj,ob_edchar,idx,EDCHAR,Attr.gemHandle);
								if pedt<>nil then
									begin
										pedt^.EdIdx:=idx;
										if doedit then
											begin
												pedt^.Edit;
												if bTst(pedt^.Style,es_Password) then
													begin
														pted:=DlgTree^[edit_obj].ob_spec.ted_info;
														magxcursor;
														StrPCopy(pted^.te_ptext,StrPFill(StrLen(pted^.te_ptext),'*'));
														ObjcPaint(edit_obj,bTst(pedt^.Flags,wb_Lazy));
														magxcursor
													end
											end
									end;
								ob_edchar:=0
							end
						else
							objc_edit:=1;
						obedflag:=false
					end;
				EDEND:
					begin
						if IsModal then objc_edit:=Gem.objc_edit(DlgTree,edit_obj,ob_edchar,idx,EDEND)
						else
							objc_edit:=objc_wedit(DlgTree,edit_obj,ob_edchar,idx,EDEND,Attr.gemHandle);
						if pedt<>nil then pedt^.EdIdx:=idx;
						obedinit:=false
					end;
				EDDRAW:
					begin
						mr.A2:=clp;
						A2toGR(mr);
						objc_edit:=objc_xedit(DlgTree,edit_obj,ob_edchar,idx,ED_DRAW,@mr)
					end;
				EDIDXPOS:
					begin
						if IsModal then
							begin
								Gem.objc_edit(DlgTree,edit_obj,0,idx,EDEND);
								objc_edit:=Gem.objc_edit(DlgTree,edit_obj,ob_edchar,idx,ED_CRSR)
							end
						else
							begin
								objc_wedit(DlgTree,edit_obj,0,idx,EDEND,Attr.gemHandle);
								objc_edit:=objc_wedit(DlgTree,edit_obj,ob_edchar,idx,ED_CRSR,Attr.gemHandle)
							end;
						if pedt<>nil then pedt^.EdIdx:=idx
					end;
				EDIDXABS:
					begin
						magxcursor;
						idx:=ob_edchar;
						magxcursor;
						if pedt<>nil then pedt^.EdIdx:=idx;
						objc_edit:=1
					end;
				else
					objc_edit:=0;
				end;
				exit
			end;
		typ:=DlgTree^[edit_obj].ob_type and $ff;
		if (typ=G_FTEXT) or (typ=G_FBOXTEXT) then
			begin
				objc_edit:=1;
				pted:=DlgTree^[edit_obj].ob_spec.ted_info;
				objc_offset(DlgTree,edit_obj,ox,oy);
				toffs:=0;
				inc(oy,((DlgTree^[edit_obj].ob_height-SysInfo.Font.Height) shr 1)-1);
				while (PChar(longint(getptmplt)+toffs)^<>'_') and (PChar(longint(getptmplt)+toffs)^<>#0) do inc(toffs);
				if pted^.te_font=SMALL then chw:=6
					else chw:=SysInfo.Font.Width;
				inc(ox,toffs*chw);
				case pted^.te_just of
					TE_RIGHT: ox:=ox+DlgTree^[edit_obj].ob_width-(pted^.te_tmplen-1)*chw;
					TE_CNTR: inc(ox,(DlgTree^[edit_obj].ob_width+1-(pted^.te_tmplen-1)*chw) shr 1)
				end;
				vs_clip(Application^.vdiHandle,CLIP_ON,clp);
				case ob_edkind of
				EDINIT: begin
									obedinit:=true;
									if PChar(pted^.te_ptext)^='@' then
										begin
											if pedt=nil then PChar(pted^.te_ptext)^:=#0
											else
												if pedt^.firstchar then PChar(pted^.te_ptext)^:=#0
										end;
									if pedt<>nil then idx:=pedt^.EdIdx
									else
										idx:=-1;
									if (idx<0) or (idx>getmaxidx) then scrolltoend;
									cursor
								end;
				EDCHAR: begin
									cursor;
									obedflag:=true;
									_delline:
									case ob_edchar of
										S_Esc: begin
														 PChar(pted^.te_ptext)^:=#0;
														 scrollto0;
														 eprint(true)
													 end;
										BackSpace: begin
			                           if pedt<>nil then
			                             if bTst(pedt^.Style,es_Password) then
			                               begin
			                                 ob_edchar:=S_Esc;
			                                 goto _delline
			                               end;
																 if idx>0 then
																	 begin
																	   decscroll;
																		 typ:=getmaxidx-1;
																		 if typ>idx then
																			 for q:=idx to typ-1 do
																				 PChar(longint(pted^.te_ptext)+q)^:=PChar(longint(pted^.te_ptext)+q+1)^;
																		 PChar(longint(pted^.te_ptext)+typ)^:=#0;
																		 eprint(true)
																	 end;
																 ob_edchar:=0
															 end;
										S_Delete: begin
			                          if pedt<>nil then
			                            if bTst(pedt^.Style,es_Password) then
			                              begin
			                                ob_edchar:=S_Esc;
			                                goto _delline
			                              end;
																if (Kbshift(-1) and K_SHIFT)>0 then
																	begin
																		ob_edchar:=S_Esc;
																		goto _delline
																	end;
																if idx<getmaxidx then
																	begin
																		typ:=getmaxidx-1;
																		if typ>idx then
																			for q:=idx to typ-1 do
																				PChar(longint(pted^.te_ptext)+q)^:=PChar(longint(pted^.te_ptext)+q+1)^;
																		PChar(longint(pted^.te_ptext)+typ)^:=#0;
																		eprint(true)
																	end;
																ob_edchar:=0
															end;
										Cur_Left: begin
																if idx>0 then decscroll;
																eprint(false);
																ob_edchar:=0
															end;
										Cur_Right: begin
																 if idx<getmaxidx then
																	 begin
																		 inc(idx);
																		 checkscroll;
																		 if pedt<>nil then pedt^.EdIdx:=idx;
																		 eprint(false)
																	 end;
																 ob_edchar:=0
															 end;
										Shift_CL,$7300:
											if not(bTst(ob_kstat,K_CTRL) and ((ob_kstat and K_SHIFT)>0)) then
												begin
													scrollto0;
													eprint(false);
													ob_edchar:=0
												end;
										Shift_CR,$7400:
											if not(bTst(ob_kstat,K_CTRL) and ((ob_kstat and K_SHIFT)>0)) then
												begin
													scrolltoend;
													eprint(false);
													ob_edchar:=0
												end;
										S_Undo: begin
															if pedt<>nil then
																if pedt^.CanUndo then
																	begin
																		pedt^.Undo;
																		eprint(false)
																	end;
															ob_edchar:=0
														end
									else
										if idx<pted^.te_txtlen-1 then typ:=idx
										else
											typ:=pted^.te_txtlen-2;
										thechar:=chr(lo(ob_edchar));
										if thechar>=' ' then
											begin
												vlen:=StrLen(getpvalid);
												if vlen=0 then vchar:='X'
												else
													if typ+1>vlen then vchar:=PChar(longint(getpvalid)+vlen-1)^
													else
														vchar:=PChar(longint(getpvalid)+typ)^;
												if ValidChar(vchar) then
													begin
														if typ<=(pted^.te_txtlen-3) then
															for q:=(pted^.te_txtlen-3) downto typ do
																PChar(longint(pted^.te_ptext)+q+1)^:=PChar(longint(pted^.te_ptext)+q)^;
														PChar(longint(pted^.te_ptext)+typ)^:=thechar;
														idx:=typ+1;
														checkscroll;
														if pedt<>nil then pedt^.EdIdx:=idx;
														eprint(true)
													end
												else
													begin
														q:=toffs;
														typ:=0;
														while typ<idx do
															begin
																if PChar(longint(getptmplt)+q)^='_' then inc(typ);
																inc(q)
															end;
														while (PChar(longint(getptmplt)+q)^<>thechar) and (PChar(longint(getptmplt)+q)^<>#0) do
															begin
																if PChar(longint(getptmplt)+q)^='_' then inc(typ);
																inc(q)
															end;
														if PChar(longint(getptmplt)+q)^=thechar then
															begin
																if typ>idx then
																	for q:=idx to typ-1 do
																		PChar(longint(pted^.te_ptext)+q)^:=' ';
																PChar(longint(pted^.te_ptext)+typ)^:=#0;
																scrolltoend;
																eprint(true)
															end
													end
											end
									end;
									obedflag:=false;
									cursor
								end;
				EDEND:  begin
									if pedt<>nil then pedt^.EdIdx:=idx;
									cursor;
									obedinit:=false
								end;
				EDDRAW: cursor;
				EDIDXPOS:
					begin
						typ:=(ob_edchar-ox) div chw;
						if pted^.te_ptmplt=nil then inc(typ,PXTED(pted^.te_pvalid)^.xte_scroll);
						goto _edidx
					end;
				EDIDXABS: begin
										typ:=ob_edchar;
										_edidx:
										if typ<0 then typ:=0;
										for q:=0 to typ do if PChar(longint(getptmplt)+toffs+q)^<>'_' then dec(typ);
										if typ>getmaxidx then typ:=getmaxidx;
										if typ<>idx then
											begin
												cursor;
												idx:=typ;
												checkscroll;
												if pedt<>nil then pedt^.EdIdx:=idx;
												eprint(false);
												cursor
											end
									end;
				else
					objc_edit:=0
				end;
				vs_clip(Application^.vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end
		else
			objc_edit:=0
	end;

{ *** TDIALOG *** }



{ *** Objekt TTOOLBAR *** }

constructor TToolbar.Init(AParent: PWindow; ATree,AnIndx,Stat,Key: integer; Msg: pointer; GetHnd,Switch: boolean; Hlp: string);
	var tp: PTree;

	begin
		if not(inherited Init(AParent)) then fail;
		tp:=Application^.GetAddr(ATree);
		if (Parent=PEventObject(Application)) or (tp=nil) then
			begin
				inherited Done;
				fail
			end;
		Style:=Style or es_Toolbar;
		ADialog:=nil;
		IsSwitch:=Switch;
		ObjTree:=ATree;
		ObjIndx:=AnIndx;
		if not(IsToolbarInstalled) then
			begin
				inherited Done;
				fail
			end;
		with ObjAddr^ do
			begin
				ob_flags:=ob_flags or SELECTABLE;
				case (ob_type and $00ff) of
				G_BOX,
				G_BOXTEXT,
				G_BUTTON,
				G_BOXCHAR,
				G_FBOXTEXT:
					begin
						if IsSwitch then ob_flags:=(ob_flags and not(FL3DMASK)) or FL3DIND
						else
							ob_flags:=(ob_flags and not(FL3DMASK)) or FL3DACT
					end;
				G_ICON,
				G_CICON:
					begin
						{ Zeichen verstecken }
					end
				end;
				if (GEMVersion>=$0340) and (GEMVersion<>MAGIX) then
					begin
						if (ob_type and $ff) in [G_BOXTEXT,G_FBOXTEXT] then ob_state:=ob_state and not(SHADOWED or OUTLINED)
					end
				else
					if Application^.Attr.Colors>=LWhite then
						begin
							if (ob_type and $ff) in [G_BOXTEXT,G_FBOXTEXT] then
								ob_spec.ted_info^.te_color:=(ob_spec.ted_info^.te_color and $ff00) or LWhite or $0070
							else
								if (ob_type and $ff) in [G_BOX,G_BOXCHAR] then
									ob_spec.index:=(ob_spec.index and $ffffff00) or LWhite or $0070
						end
			end;
		BHelp:=nil;
		SetHelp(Hlp);
		VKey:=Key;
		VStat:=Stat;
		VGHnd:=GetHnd;
		if Msg<>nil then
			begin
				new(VPipe);
				if VPipe<>nil then
					begin
						VPipe^:=PPipearray(Msg)^;
						VPipe^[1]:=Application^.apID;
						VPipe^[2]:=0
					end
			end
		else
			VPipe:=nil
	end;


destructor TToolbar.Done;

	begin
		if VPipe<>nil then dispose(VPipe);
		DisposeStr(BHelp);
		inherited Done
	end;


function TToolbar.IsToolbarInstalled: boolean;
	var tp : PTree;
	    i,q: integer;

	begin
		ObjAddr:=nil;
		i:=-1;
		for q:=0 to MAXTOOLBARS do
			if PWindow(Parent)^.tbval[q].Indx=ObjTree then
				begin
					i:=q;
					break
				end;
		if i<0 then
			begin
				tp:=Application^.GetAddr(ObjTree);
				if tp<>nil then ObjAddr:=@tp^[ObjIndx]
			end
		else
			ObjAddr:=@PWindow(Parent)^.tbval[i].Tree^[ObjIndx];
		IsToolbarInstalled:=(ObjAddr<>nil)
	end;


function TToolbar.TestKey(Stat,Key: integer): boolean;

	begin
		if bTst(VStat,K_SHIFT) then
			if (Stat and K_SHIFT)>0 then Stat:=Stat or K_SHIFT;
		if (Stat=VStat) and (Key=VKey) and (GetState<>bf_Disabled) then
			begin
				TestKey:=true;
				if IsSwitch then Toggle
				else
					Check;
				Work;
				if VPipe<>nil then
					begin
						if VGHnd then VPipe^[3]:=PWindow(Parent)^.Attr.gemHandle;
						appl_write(Application^.apID,16,VPipe)
					end;
				if IsToolbarInstalled then
					if hi(ObjAddr^.ob_type)>ROOT then
						begin
							if bTst(PWindow(Parent)^.Class.Style,cs_WindowMenuToolbar) then PWindow(Parent)^.MNSelected(hi(ObjAddr^.ob_type),0,nil,0)
							else
								Application^.MNSelected(hi(ObjAddr^.ob_type),0,nil,0)
						end;
				if not(IsSwitch) then Uncheck
			end
		else
			TestKey:=false
	end;


function TToolbar.TestMessage(Pipe: Pipearray): boolean;

	begin
		TestMessage:=false;
		if Pipe[0]=GO_PRIVATE then
			if Pipe[3]=GOP_TOOLBAR then
				if Pipe[4]=ObjTree then
					if Pipe[5]=ObjIndx then TestMessage:=true
	end;


function TToolbar.GetState: integer;

	begin
		if not(IsToolbarInstalled) then GetState:=id_No
		else
			if bTst(ObjAddr^.ob_state,DISABLED) then GetState:=bf_Disabled
			else
				GetState:=bf_Enabled
	end;


procedure TToolbar.SetState(StateFlag: integer);

	begin
		if GetState<>StateFlag then
			if IsToolbarInstalled then
				begin
					with ObjAddr^ do
						if StateFlag=bf_Disabled then
							ob_state:=ob_state or DISABLED
						else
							ob_state:=ob_state and not(DISABLED);
					Paint
				end
	end;


procedure TToolbar.Disable;

	begin
		SetState(bf_Disabled)
	end;


procedure TToolbar.Enable;

	begin
		SetState(bf_Enabled)
	end;


procedure TToolbar.SetCheck(CheckFlag: integer);

	begin
		if GetCheck<>CheckFlag then
			if IsToolbarInstalled then
				begin
					with ObjAddr^ do
						if CheckFlag=bf_Unchecked then ob_state:=ob_state and not(SELECTED)
						else
							ob_state:=ob_state or SELECTED;
					Paint
				end
	end;


function TToolbar.GetCheck: integer;

	begin
		if not(IsToolbarInstalled) then GetCheck:=id_No
		else
			if bTst(ObjAddr^.ob_state,SELECTED) then GetCheck:=bf_Checked
			else
				GetCheck:=bf_Unchecked
	end;


procedure TToolbar.Check;

	begin
		SetCheck(bf_Checked)
	end;


procedure TToolbar.Uncheck;

	begin
		SetCheck(bf_Unchecked)
	end;


procedure TToolbar.Toggle;

	begin
		if GetCheck=bf_Unchecked then SetCheck(bf_Checked)
		else
			SetCheck(bf_Unchecked);
	end;


function TToolbar.IsChecked: boolean;

	begin
		IsChecked:=(GetCheck=bf_Checked);
	end;


procedure TToolbar.Paint;
	var box,obox: GRECT;

	begin
		with PWindow(Parent)^ do
			begin
				if Attr.Status<>ws_Open then exit;
				if IsIconified then exit;
				if (Class.ToolbarTree=nil) or (tbtree<>ObjTree) then exit;
				wind_update(BEG_UPDATE);
				objc_offset(Class.ToolbarTree,ObjIndx,obox.X,obox.Y);
				obox.W:=ObjAddr^.ob_width;
				obox.H:=ObjAddr^.ob_height;
				HideMouse;
				wind_get(Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
				while (box.W>0) and (box.H>0) do
					begin
						if rc_intersect(SysInfo.Desktop,box) then
							if rc_intersect(obox,box) then
								with box do objc_draw(Class.ToolbarTree,ROOT,MAX_DEPTH,X,Y,W,H);
						wind_get(Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
					end;
				ShowMouse;
				wind_update(END_UPDATE)
			end
	end;


function TToolbar.IsHelpAvailable: boolean;

	begin
		if BHelp=nil then IsHelpAvailable:=false
		else
			IsHelpAvailable:=(length(StrPTrimF(BHelp^))<>0)
	end;


function TToolbar.GetHelp: string;

	begin
		if BHelp<>nil then GetHelp:=BHelp^ else GetHelp:=''
	end;


procedure TToolbar.SetHelp(Hlp: string);

	begin
		DisposeStr(BHelp);
		BHelp:=NewStr(Hlp)
	end;


procedure TToolbar.SetMenuIndex(Indx: byte);

	begin
		if IsToolbarInstalled then
			with ObjAddr^ do ob_type:=(ob_type and $00ff) or (Indx shl 8)
	end;


function TToolbar.GetMenuIndex: byte;

	begin
		if IsToolbarInstalled then GetMenuIndex:=hi(ObjAddr^.ob_type)
		else
			GetMenuIndex:=0
	end;


procedure TToolbar.ClearMenuIndex;

	begin
		SetMenuIndex(0)
	end;

{ *** Objekt TTOOLBAR *** }



{ *** Objekt TKEYMENU *** }

constructor TKeyMenu.Init(AParent: PEventObject; Stat,Key,mNum,tNum: integer);

	begin
		if not(inherited Init(AParent)) then fail;
		Style:=Style or es_KeyMenu;
		ADialog:=nil;
		VStat:=Stat;
		VKey:=Key;
		VMNum:=mNum;
		VTNum:=tNum;
		VGHnd:=false;
		VPipe:=nil
	end;


destructor TKeyMenu.Done;

	begin
		if VPipe<>nil then dispose(VPipe);
		inherited Done
	end;


function TKeyMenu.TestKey(Stat,Key: integer): boolean;

	begin
		if bTst(VStat,K_SHIFT) then
			if (Stat and K_SHIFT)>0 then Stat:=Stat or K_SHIFT;
		if (Stat=VStat) and (Key=VKey) and (GetState<>bf_Disabled) then
			begin
				TestKey:=true;
				if (GetMenuTree<>nil) and (VTNum>=0) then
					begin
						if IsApp then menu_tnormal(GetMenuTree,VTNum,ME_INVERT)
						else
							Application^.TitleSelect(PWindow(Parent),VTNum,true)
					end;
				Work;
				if VPipe<>nil then
					begin
						if not(VGHnd) then appl_write(Application^.apID,16,VPipe)
						else
							if IsApp then Application^.SendWndMessage(-1,VPipe,true,false)
							else
								begin
									VPipe^[3]:=PWindow(Parent)^.Attr.gemHandle;
									appl_write(Application^.apID,16,VPipe)
								end
					end;
				if (GetMenuTree<>nil) and (VTNum>=0) then
					begin
						if IsApp then menu_tnormal(GetMenuTree,VTNum,ME_NORMAL)
						else
							Application^.TitleSelect(PWindow(Parent),VTNum,false)
					end
			end
		else
			TestKey:=false
	end;


function TKeyMenu.TestMenu(mNum: integer): boolean;

	begin
		if mNum=VMNum then
			begin
				TestMenu:=true;
				Work;
				if VPipe<>nil then
					begin
						if not(VGHnd) then appl_write(Application^.apID,16,VPipe)
						else
							if IsApp then Application^.SendWndMessage(-1,VPipe,true,false)
							else
								begin
									VPipe^[3]:=PWindow(Parent)^.Attr.gemHandle;
									appl_write(Application^.apID,16,VPipe)
								end
					end
			end
		else
		 TestMenu:=false
	end;


function TKeyMenu.GetState: integer;

	begin
		if (GetMenuTree<>nil) and (VMNum>=0) then
			begin
				if bTst(GetMenuTree^[VMNum].ob_state,DISABLED) then GetState:=bf_Disabled
				else
					GetState:=bf_Enabled
			end
		else
			GetState:=id_No
	end;


procedure TKeyMenu.SetState(StateFlag: integer);

	begin
		if InitMWrk then
			begin
				if IsApp then
					begin
						if StateFlag=bf_Disabled then menu_ienable(GetMenuTree,VMNum,ME_DISABLE)
						else
							menu_ienable(GetMenuTree,VMNum,ME_ENABLE);
					end
				else
					with GetMenuTree^[VMNum] do
						begin
							if StateFlag=bf_Disabled then ob_state:=ob_state or DISABLED
							else
								ob_state:=ob_state and not(DISABLED)
						end;
				ExitMWrk
			end
	end;


procedure TKeyMenu.Disable;

	begin
		SetState(bf_Disabled)
	end;


procedure TKeyMenu.Enable;

	begin
		SetState(bf_Enabled)
	end;


function TKeyMenu.GetText: string;

	begin
		if (GetMenuTree<>nil) and (VMNum>=0) then
			GetText:=StrPas(GetMenuTree^[VMNum].ob_spec.free_string)
		else
			GetText:=''
	end;


procedure TKeyMenu.SetText(ATextString: string);
	var l: integer;

	begin
		if InitMWrk then
			begin
				l:=length(GetText);
				ATextString:=ATextString+StrPSpace(l-length(ATextString));
				if IsApp then menu_text(GetMenuTree,VMNum,ATextString)
				else
					StrPCopy(PChar(GetMenuTree^[VMNum].ob_spec.free_string),ATextString);
				ExitMWrk
			end
	end;


function TKeyMenu.GetCheck: integer;

	begin
		if (GetMenuTree<>nil) and (VMNum>=0) then
			begin
				if bTst(GetMenuTree^[VMNum].ob_state,CHECKED) then GetCheck:=bf_Checked
				else
					GetCheck:=bf_Unchecked
			end
		else
			GetCheck:=id_No
	end;


procedure TKeyMenu.SetCheck(CheckFlag: integer);

	begin
		if InitMWrk then
			begin
				if IsApp then
					begin
						if CheckFlag=bf_Checked then menu_icheck(GetMenuTree,VMNum,ME_CHECK)
						else
							menu_icheck(GetMenuTree,VMNum,ME_UNCHECK)
					end
				else
					with GetMenuTree^[VMNum] do
						begin
							if CheckFlag=bf_Checked then ob_state:=ob_state or CHECKED
							else
								ob_state:=ob_state and not(CHECKED)
						end;
				ExitMWrk
			end
	end;


procedure TKeyMenu.Check;

	begin
		SetCheck(bf_Checked)
	end;


procedure TKeyMenu.Uncheck;

	begin
		SetCheck(bf_Unchecked)
	end;


procedure TKeyMenu.Toggle;

	begin
		if GetCheck=bf_Unchecked then SetCheck(bf_Checked)
		else
			SetCheck(bf_Unchecked)
	end;


	{ private }


function TKeyMenu.InitMWrk: boolean;
	var valid: boolean;

	begin
		valid:=(GetMenuTree<>nil) and (VMNum>=0);
		if valid then wind_update(BEG_UPDATE);
		InitMWrk:=valid
	end;


procedure TKeyMenu.ExitMWrk;

	begin
		wind_update(END_UPDATE)
	end;


function TKeyMenu.IsApp: boolean;

	begin
		IsApp:=(Parent=PEventObject(Application))
	end;


function TKeyMenu.GetMenuTree: PTree;

	begin
		if IsApp then GetMenuTree:=Application^.MenuTree
		else
			GetMenuTree:=PWindow(Parent)^.Class.MenuTree
	end;

{ *** TKEYMENU *** }



{ *** Objekt TSUBMENU *** }

constructor TSubMenu.Init(AParent: PEventObject; mNum,popTree,popIndex: integer);
	var mnu: MENU;
	    p  : PTree;
	    i  : integer;

	begin
		if not(inherited Init(AParent,K_NORMAL,id_No,mNum,-1)) then fail;
		p:=GetMenuTree;
		if p=nil then
			begin
				inherited Done;
				fail
			end;
		new(Popup,Init(AParent,popTree,popIndex,id_No));
		if Popup=nil then
			begin
				inherited Done;
				fail
			end;
		if Application^.stewart<>0 then
			if STEW_COOKPtr(Application^.stewart)^.menu_on<>0 then
				if (Application^.Attr.Colors>=STEW_COOKPtr(Application^.stewart)^.bck_col) and IsApp then
					begin
						Popup^.PopTree^[Popup^.pIndex].ob_spec.index:=(Popup^.PopTree^[Popup^.pIndex].ob_spec.index and $ffffff00) or STEW_COOKPtr(Application^.stewart)^.bck_col or $70;
						i:=Popup^.PopTree^[Popup^.pIndex].ob_head;
						if i>0 then
							while i<>Popup^.pIndex do
								begin
									Popup^.PopTree^[i].ob_flags:=Popup^.PopTree^[i].ob_flags or FL3DBAK;
									i:=Popup^.PopTree^[i].ob_next
								end
					end;
		Style:=Style or es_SubMenu;
		if (agi.MnAttach) and IsApp then
			begin
				if not(agi.SysNiceline) or Application^.extmagxmenu then
					with Popup^ do
						begin
							mnusr.ub_parm:=0;
							mnusr.ub_code:=@DrawMenuRect;
							for i:=PopTree^[pStart].ob_head to PopTree^[pStart].ob_tail do
								if bTst(PopTree^[i].ob_state,DISABLED) then
									if StrPLeft(GetText(i-PopTree^[pStart].ob_head),1)='-' then
										begin
											PopTree^[i].ob_type:=G_USERDEF;
											PopTree^[i].ob_spec.user_blk:=@mnusr;
										end;
						end;
				with mnu do
					begin
						mn_tree:=Popup^.PopTree;
						mn_menu:=Popup^.pIndex;
						mn_item:=Popup^.pStart;
						mn_scroll:=0;
						mn_keystate:=K_NORMAL;
					end;
				menu_attach(MEA_ATTACH,p,VMNum,@mnu);
			end
		else
			with p^[VMNum] do
				if (ob_type and $00ff)=G_STRING then
					PChar(longint(ob_spec.free_string)+StrLen(ob_spec.free_string)-2)^:=#3;
	end;


destructor TSubMenu.Done;

	begin
		if (agi.MnAttach) and IsApp then
			if (GEMVersion=MAGIX) or (GEMVersion>=$0410) then
				if GetMenuTree<>nil then menu_attach(MEA_REMOVE,GetMenuTree,VMNum,nil);
		if Popup<>nil then dispose(Popup,Done);
		inherited Done;
	end;


procedure TSubMenu.Work;
	var ret: integer;

	begin
		if not(agi.MnAttach) or not(IsApp) then
			begin
				graf_mkstate(Popup^.pX,Popup^.pY,ret,ret);
				Popup^.pFlag:=POP_CENTER;
				ret:=Popup^.Execute;
				if ret>=0 then HandleMenu(ret);
			end
	end;


procedure TSubMenu.HandleMenu(Indx: integer);

	begin
	end;

{ *** TSUBMENU *** }



{ *** Objekt TKEY *** }

constructor TKey.Init(AParent: PEventObject; Stat,Key: integer; Msg: pointer; GetHnd: boolean);

	begin
		if not(inherited Init(AParent,Stat,Key,-1,-1)) then fail;
		VGHnd:=GetHnd;
		if Msg<>nil then
			begin
				new(VPipe);
				if VPipe<>nil then
					begin
						VPipe^:=PPipearray(Msg)^;
						VPipe^[1]:=Application^.apID;
						VPipe^[2]:=0
					end
			end
	end;


function TKey.TestMenu(mNum: integer): boolean;

	begin
		TestMenu:=false
	end;

{ *** TKEY *** }



{ *** Objekt TMENU *** }

constructor TMenu.Init(AParent: PEventObject; mNum: integer; Msg: pointer; GetHnd: boolean);

	begin
		if not(inherited Init(AParent,K_NORMAL,id_No,mNum,-1)) then fail;
		VGHnd:=GetHnd;
		if Msg<>nil then
			begin
				new(VPipe);
				if VPipe<>nil then
					begin
						VPipe^:=PPipearray(Msg)^;
						VPipe^[1]:=Application^.apID;
						VPipe^[2]:=0
					end
			end
	end;


function TMenu.TestKey(Stat,Key: integer): boolean;

	begin
		TestKey:=false
	end;

{ *** TMENU *** }



function TDKey.TestKey(Stat,Key: integer): boolean;
	label _weiter;

	var nx,dummy,
	    tx,robj,
	    mx,my,oldkey: integer;
	    valid,found : boolean;
	    kpc         : PControl;
	    pd          : PDialog;

	function invrt(tid: integer): boolean;
		var p: PControl;

		begin
			invrt:=true;
			with PDialog(Parent)^ do
				begin
					kpc:=nil;
					p:=CtrlList;
					while (p<>nil) do
						with p^ do
							begin
								if TestID(tid) then kpc:=p;
								p:=Nxt
							end;
					if kpc<>nil then
						begin
							if kpc^.GetState=bf_Disabled then
								begin
									invrt:=false;
									kpc:=nil
								end
							else
								if bTst(DlgTree^[kpc^.ObjIndx].ob_flags,SELECTABLE) then
									begin
										DlgTree^[kpc^.ObjIndx].ob_state:=DlgTree^[kpc^.ObjIndx].ob_state or SELECTED;
										ObjcPaint(kpc^.ObjIndx,false)
									end
								else
									kpc:=nil
						end
				end
		end;

	begin
		TestKey:=false;
		pd:=PDialog(Parent);
		with pd^ do
			if Cont then
				begin
					dummy:=integer(MapKey(Key));
					if bTst(hi(dummy),KsALT) then
						begin
							Cont:=true;
							oldkey:=Key;
							Key:=0;
							next_obj:=0;
							nx:=0;
							dummy:=ord(upcase(chr(lo(dummy))));
							kpc:=CtrlList;
							while (kpc<>nil) and Cont do
								begin
									if not(kpc^.IsHidden) then
										if kpc^.TestShortCut(dummy) then
											begin
												TestKey:=true;
												if kpc^.GetState<>bf_Disabled then
													begin
														Cont:=false;
														nx:=kpc^.ObjIndx
													end
											end;
									kpc:=kpc^.Nxt
								end;
							if not(Cont) then
								begin
									dummy:=DlgTree^[nx].ob_state;
									if bTst(DlgTree^[nx].ob_flags,SELECTABLE) then
										begin
											if bTst(DlgTree^[nx].ob_flags,RBUTTON) then
												begin
													if not(bTst(dummy,SELECTED)) then
														begin
															robj:=nx;
															repeat
																tx:=DlgTree^[robj].ob_next;
																if DlgTree^[tx].ob_tail=robj then
																	robj:=DlgTree^[tx].ob_head
																else
																	robj:=tx;
																if bTst(DlgTree^[robj].ob_flags,RBUTTON) then
																	if bTst(DlgTree^[robj].ob_state,SELECTED) then
																		begin
																			objc_change(DlgTree,robj,0,0,0,1,1,DlgTree^[robj].ob_state and not(SELECTED),1);
																			ObjcPaint(robj,false)
																		end;
															until robj=nx;
															objc_change(DlgTree,nx,0,0,0,1,1,dummy or SELECTED,1);
															ObjcPaint(nx,false);
															CallChanged(nx,false,false,false)
														end
												end
											else
												begin
													if bTst(DlgTree^[nx].ob_flags,F_EXIT) then dummy:=dummy or SELECTED
														else dummy:=dummy xor SELECTED;
													objc_change(DlgTree,nx,0,0,0,1,1,dummy,1);
													ObjcPaint(nx,false);
													CallChanged(nx,false,false,false)
												end
										end
									else
										CallChanged(nx,false,false,false);
									if (DlgTree^[nx].ob_flags and (F_EXIT or TOUCHEXIT))=0 then Cont:=true
									else
										EndDlg(nx,false);
									exit
								end
							else
								begin
									Key:=oldkey;
									if pxfocus<>nil then
										if pxfocus^.ExtFocusKey(Stat,Key) then
											begin
												Cont:=true;
												TestKey:=true;
												goto _weiter
											end
								end
						end
					else
						begin
							if pxfocus<>nil then
								if pxfocus^.ExtFocusKey(Stat,Key) then
									begin
										Cont:=true;
										TestKey:=true;
										goto _weiter
									end;
							Cont:=(Application^.form_keybd(pd,DlgTree,edit_obj,0,Key,Stat,next_obj,Key)<>0)
						end;
					if not(Cont) then
						begin
							TestKey:=true;
							nx:=next_obj;
							next_obj:=0;
							if bTst(DlgTree^[nx].ob_flags,SELECTABLE) then
								begin
									DlgTree^[nx].ob_state:=DlgTree^[nx].ob_state or SELECTED;
									ObjcPaint(nx,false)
								end;
							CallChanged(nx,false,false,false);
							EndDlg(nx,false);
							exit
						end;
					if Key<>0 then
						begin
							case Key of
							F1:
								dummy:=1;
							F2:
								dummy:=2;
							F3:
								dummy:=3;
							F4:
								dummy:=4;
							F5:
								dummy:=5;
							F6:
								dummy:=6;
							F7:
								dummy:=7;
							F8:
								dummy:=8;
							F9:
								dummy:=9;
							F10:
								dummy:=10;
							else
								dummy:=0;
							end;
							if dummy>0 then
								begin
									dummy:=TestFKey(dummy);
									if dummy>ROOT then
										begin
											Result:=dummy;
											Cont:=false;
											Destroy;
											exit
										end
								end;
							found:=false;
							valid:=false;
							case Key of
							S_Help,F1:
								if Stat=K_NORMAL then
									begin
										TestKey:=true;
										if Key=F1 then
											begin
												graf_mkstate(mx,my,dummy,dummy);
												if IsHelpAvailable(mx,my) then
													begin
														Application^.BubbleHelp(mx,my,GetHelp(mx,my),false,false);
														valid:=true
													end
											end;
										if not(valid) then
											begin
											  if invrt(id_Help) then valid:=Help;
												found:=true
											end
									end;
							else
								if edit_obj>0 then
									begin
										objc_edit(Key,EDCHAR,Stat,Work.A2,true);
										TestKey:=(Key=0)
									end
								else
									if Stat=K_NORMAL then
										case Key of
										S_Esc:
											begin
												TestKey:=true;
												if invrt(id_Esc) then valid:=Esc;
												found:=true
											end;
										S_Undo:
											begin
												TestKey:=true;
												if invrt(id_Undo) then valid:=Undo;
											 	found:=true
											end
										end
							end;
							if found then
								begin
									if valid then
										begin
											Result:=id_No;
											if CanClose then
												begin
													if kpc<>nil then
														DlgTree^[kpc^.ObjIndx].ob_state:=DlgTree^[kpc^.ObjIndx].ob_state and not(SELECTED);
													Cont:=false;
													Destroy;
													exit
												end
											else
												if kpc<>nil then
													begin
														DlgTree^[kpc^.ObjIndx].ob_state:=DlgTree^[kpc^.ObjIndx].ob_state and not(SELECTED);
														ObjcPaint(kpc^.ObjIndx,false)
													end
										end
									else
										if kpc<>nil then
											begin
												DlgTree^[kpc^.ObjIndx].ob_state:=DlgTree^[kpc^.ObjIndx].ob_state and not(SELECTED);
												ObjcPaint(kpc^.ObjIndx,false)
											end
								end
						end;
					_weiter:
					if (next_obj>0) and (edit_obj<>next_obj) then
						begin
							objc_edit(dummy,EDEND,K_NORMAL,Work.A2,true);
							edit_obj:=next_obj;
							next_obj:=0;
							CallChanged(edit_obj,false,true,false);
							objc_edit(dummy,EDINIT,K_NORMAL,Work.A2,true)
						end
				end
	end;


function TAlrtDialog.TestFKey(fNum: integer): integer;

	begin
		if Between(fNum,1,cntbutton) then TestFKey:=firstbutton+fNum-1
		else
			TestFKey:=id_No
	end;


procedure TQKey.Work;

	begin
		Application^.Quit
	end;


function TMenuPopup.ExitPop(Indx,mX,mY: integer): integer;
	label _weiter;

	var objc,pdx,rh,rx,ry: integer;
	    box,maus         : GRECT;

	begin
		wind_get(PWindow(Parent)^.Attr.gemHandle,WF_WORKXYWH,rx,ry,rh,rh);
		if (mY<ry) or (mX<rx) then
			begin
				ExitPop:=-2;
				exit
			end
		else
			ExitPop:=id_No;
		maus.X:=mX;
		maus.Y:=mY;
		maus.W:=1;
		maus.H:=1;
		wind_get(PWindow(Parent)^.Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
		while (box.W>0) and (box.H>0) do
			begin
				if rc_intersect(SysInfo.Desktop,box) then
					if rc_intersect(maus,box) then goto _weiter;
				wind_get(PWindow(Parent)^.Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
			end;
		exit;
		_weiter:
		objc:=objc_find(PopTree,PopTree^[ROOT].ob_head,MAX_DEPTH,mX,mY);
		pdx:=objc-PopTree^[PopTree^[PopTree^[ROOT].ob_head].ob_head].ob_head;
		if pdx>=0 then
			begin
				ExitPop:=pdx+10000;
				rh:=PopTree^[PopTree^[ROOT].ob_tail].ob_head;
				while pdx>0 do
					begin
						rh:=PopTree^[rh].ob_next;
						dec(pdx)
					end;
				if rh=pIndex then ExitPop:=id_No
			end
	end;


function TMenuPopup.KeyExit(Stat,Key: integer): integer;
	var inx,anz,nnum,num,dif,objc: integer;

	function objvisible: boolean;
		label _weiter;

		var q      : integer;
		    mnu,box: GRECT;

		begin
			objvisible:=false;
			q:=nnum;
			objc:=PopTree^[PopTree^[PopTree^[ROOT].ob_head].ob_head].ob_head;
			while q>0 do
				begin
					objc:=PopTree^[objc].ob_next;
					dec(q)
				end;
			objc_offset(PopTree,objc,mnu.X,mnu.Y);
			with PopTree^[objc] do
				begin
					mnu.W:=ob_width;
					mnu.H:=ob_height
				end;
			wind_get(PWindow(Parent)^.Attr.gemHandle,WF_FIRSTXYWH,box.X,box.Y,box.W,box.H);
			while (box.W>0) and (box.H>0) do
				begin
					if rc_intersect(SysInfo.Desktop,box) then
						if rc_intersect(mnu,box) then goto _weiter;
					wind_get(PWindow(Parent)^.Attr.gemHandle,WF_NEXTXYWH,box.X,box.Y,box.W,box.H)
				end;
			exit;
			_weiter:
			objvisible:=true;
			if nnum<>num then SetMousePos(box.X+(box.W shr 1),box.Y+(box.H shr 1))
		end;

	begin
		KeyExit:=id_No;
		dif:=0;
		if Stat=K_NORMAL then
			case Key of
			Cur_Left:
				dif:=-1;
			Cur_Right:
				dif:=1
			end;
		if dif=0 then exit;
		anz:=0;
		num:=0;
		inx:=PopTree^[PopTree^[ROOT].ob_tail].ob_head;
		while PopTree^[inx].ob_next<>PopTree^[ROOT].ob_tail do
			begin
				inc(anz);
				inx:=PopTree^[inx].ob_next;
				if inx=pIndex then num:=anz
			end;
		nnum:=num;
		repeat
			inc(nnum,dif);
			if nnum<0 then nnum:=anz;
			if nnum>anz then nnum:=0
		until objvisible
	end;


constructor TIcnWnd.Init(AParent: PWindow; ATitle: string; x,y,w,h: integer);

	begin
		icx:=x;
		icy:=y;
		icw:=w;
		ich:=h;
		if not(inherited Init(AParent,ATitle)) then fail
	end;


procedure TIcnWnd.SetupWindow;

	begin
		LoadIcon(new(PIcon,Init(@self,Application^.ticn,Application^.iicn,0,0,false,false,'','')));
		Application^.Icon:=Icon;
		inherited SetupWindow
	end;


procedure TIcnWnd.MakeWindow;

	begin
		Create;
		wind_set(Attr.gemHandle,WF_ICONIFY,icx,icy,icw,ich);
		GetCurr;
		GetWork;
		OpenWindow
	end;


procedure TIcnWnd.IconPaint(var PaintInfo: TPaintStruct);

	begin
		Application^.IconPaint(Work,PaintInfo)
	end;


procedure TXAccCollection.FreeItem(Item: pointer);

	begin
		if Item<>nil then
			begin
				with PXAccAttr(Item)^ do
					begin
						DisposeStr(AppTypeHR);
						DisposeStr(ExtFeatures);
						DisposeStr(GenericName);
						DisposeStr(Name)
					end;
				dispose(PXAccAttr(Item));
			end
	end;


procedure TProfileCollection.FreeItem(Item: pointer);

	begin
		ChrDispose(PChar(Item))
	end;


procedure IconifyFadeout(p: PWindow);

	begin
		if p<>Application^.icnwnd then p^.Iconify(true)
	end;


procedure IconifyFadein(p: PWindow);

	begin
		if p<>Application^.icnwnd then p^.Iconify(false)
	end;


procedure SendXaccExit(p: PXAccAttr);
	var pipe: Pipearray;

	begin
		pipe[1]:=Application^.apID;
		pipe[2]:=0;
		if bTst(p^.Protocol,PROTO_XACC) then
			begin
				pipe[0]:=ACC_EXIT;
				appl_write(p^.apID,16,@pipe)
			end;
		if bTst(p^.Protocol,PROTO_AV) then
			begin
				pipe[0]:=AV_EXIT;
				pipe[3]:=pipe[1];
				appl_write(p^.apID,16,@pipe)
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


function vst_fg_color(handle,color_space: integer; const fg_color: TCOLOR_ENTRY): integer;

	begin
		with VDI_pb do
			begin
				control^[0]:=200;
				control^[1]:=0;
				control^[3]:=6;
				control^[5]:=0;
				control^[6]:=handle;
				intin^[0]:=0;
				intin^[1]:=color_space;
				intin^[2]:=fg_color.rgb.reserved;
				intin^[3]:=fg_color.rgb.red;
				intin^[4]:=fg_color.rgb.green;
				intin^[5]:=fg_color.rgb.blue;
				vdi(@VDI_pb);
				vst_fg_color:=intout^[0]
			end
	end;


function vst_bg_color(handle,color_space: integer; const bg_color: TCOLOR_ENTRY): integer;

	begin
		with VDI_pb do
			begin
				control^[0]:=201;
				control^[1]:=0;
				control^[3]:=6;
				control^[5]:=0;
				control^[6]:=handle;
				intin^[0]:=0;
				intin^[1]:=color_space;
				intin^[2]:=bg_color.rgb.reserved;
				intin^[3]:=bg_color.rgb.red;
				intin^[4]:=bg_color.rgb.green;
				intin^[5]:=bg_color.rgb.blue;
				vdi(@VDI_pb);
				vst_bg_color:=intout^[0]
			end
	end;


function DrawMenuRect(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	label _weiter,_raus;

	begin
		with parm^ do
			begin
				d_pxy[0]:=pb_x;
				d_pxy[1]:=pb_y+(pb_h shr 1)-1;
				d_pxy[2]:=pb_x+pb_w-1;
				d_pxy[3]:=pb_y+(pb_h shr 1)
			end;
		with Application^ do
			begin
				if extmagxmenu then
					begin
						d_pxy[1]:=d_pxy[3];
						vsl_color(vdiHandle,LBlack);
						v_pline(vdiHandle,2,d_pxy);
						vsl_color(vdiHandle,Black);
						goto _raus
					end
				else
					if ExtObjects then
						begin
							vsf_interior(vdiHandle,FIS_PATTERN);
							vsf_style(vdiHandle,4);
							vswr_mode(vdiHandle,MD_TRANS)
						end
					else
						begin
							if stewart<>0 then
								if STEW_COOKPtr(stewart)^.menu_on<>0 then
									if Attr.Colors>=STEW_COOKPtr(stewart)^.dis_col then
										begin
											vsf_interior(vdiHandle,FIS_SOLID);
											vsf_color(vdiHandle,STEW_COOKPtr(stewart)^.dis_col);
											goto _weiter
										end;
							if Attr.Colors>=LWhite then
								begin
									vsf_interior(vdiHandle,FIS_SOLID);
									vsf_color(vdiHandle,LWhite)
								end
							else
								vsf_interior(vdiHandle,FIS_PATTERN)
						end;
				_weiter:
				vr_recfl(vdiHandle,d_pxy);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vswr_mode(vdiHandle,MD_REPLACE)
			end;
		_raus:
		DrawMenuRect:=NORMAL
	end;


function DrawTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1
			end;
		with Application^ do
			begin
				vs_clip(vdiHandle,CLIP_ON,d_clip);
				vst_effects(vdiHandle,TF_UNDERLINED);
				d_str[0]:=#0;
				d_chr:=PChar(parm^.pb_parm);
				while d_chr^<>#0 do
					begin
						inc(byte(d_str[0]));
						d_str[byte(d_str[0])]:=d_chr^;
						inc(longint(d_chr))
					end;
				if SysInfo.DefColValid then
					begin
						vst_fg_color(vdiHandle,CSPACE_RGB,defcolfg);
						vst_bg_color(vdiHandle,CSPACE_RGB,SysInfo.DefCol);
						vgText(vdiHandle,parm^.pb_x,parm^.pb_y+SysInfo.Font.Height,d_str);
						vst_color(vdiHandle,Black)
					end
				else
					begin
						vswr_mode(vdiHandle,MD_ERASE);
						vst_color(vdiHandle,SysInfo.BGDefCol);
						vgText(vdiHandle,parm^.pb_x,parm^.pb_y+SysInfo.Font.Height,d_str);
						vswr_mode(vdiHandle,MD_TRANS);
						vst_color(vdiHandle,Black);
						vgText(vdiHandle,parm^.pb_x,parm^.pb_y+SysInfo.Font.Height,d_str);
						vswr_mode(vdiHandle,MD_REPLACE)
					end;
				vst_effects(vdiHandle,TF_NORMAL);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawTitle:=NORMAL
	end;


function DrawStatic(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1
			end;
		with Application^ do
			begin
				vs_clip(vdiHandle,CLIP_ON,d_clip);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				d_str[0]:=#0;
				d_chr:=PChar(parm^.pb_parm);
				while d_chr^<>#0 do
					begin
						inc(byte(d_str[0]));
						d_str[byte(d_str[0])]:=d_chr^;
						inc(longint(d_chr))
					end;
				if SysInfo.DefColValid then
					begin
						vst_fg_color(vdiHandle,CSPACE_RGB,defcolfg);
						vst_bg_color(vdiHandle,CSPACE_RGB,SysInfo.DefCol);
						vgText(vdiHandle,parm^.pb_x,parm^.pb_y+SysInfo.Font.Height,d_str);
						vst_color(vdiHandle,Black)
					end
				else
					begin
						vswr_mode(vdiHandle,MD_ERASE);
						vst_color(vdiHandle,SysInfo.BGDefCol);
						vgText(vdiHandle,parm^.pb_x,parm^.pb_y+SysInfo.Font.Height,d_str);
						vswr_mode(vdiHandle,MD_TRANS);
						vst_color(vdiHandle,Black);
						vgText(vdiHandle,parm^.pb_x,parm^.pb_y+SysInfo.Font.Height,d_str);
						vswr_mode(vdiHandle,MD_REPLACE)
					end;
				vsl_type(vdiHandle,LT_SOLID);
				vst_effects(vdiHandle,TF_NORMAL);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawStatic:=parm^.pr_currstate and not(DISABLED)
	end;


function DrawPushButton(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var q: integer;

	begin
		with parm^ do
			begin
				d_clip[0]:=pb_xc;
				d_clip[1]:=pb_yc;
				d_clip[2]:=pb_xc+pb_wc-1;
				d_clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,d_clip);
				inc(pb_x,5);
				inc(pb_y,5);
				dec(pb_w,10);
				dec(pb_h,10);
				d_clip[0]:=pb_x-1;
				d_clip[1]:=pb_y-1;
				d_clip[2]:=pb_x+pb_w;
				d_clip[3]:=pb_y+pb_h-1
			end;
		with Application^ do
			begin
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,bfalcol);
				v_bar(vdiHandle,d_clip);
				d_chr:=PChar(parm^.pb_parm);
				d_btn[0]:=#0;
				while (d_chr^<>#0) and (byte(d_btn[0])<30) do
					begin
						inc(byte(d_btn[0]));
						d_btn[length(d_btn)]:=d_chr^;
						inc(longint(d_chr))
					end;
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
				d_tx:=parm^.pb_x+((parm^.pb_w-length(d_btn)*Attr.charSWidth) shr 1);
				d_ty:=parm^.pb_y+SysInfo.Font.Height-1;
				if bTst(parm^.pr_currstate,SELECTED) then
					begin
						pxya[0]:=d_clip[0]-1;
						pxya[1]:=d_clip[3];
						pxya[2]:=pxya[0];
						pxya[3]:=d_clip[1]-1;
						pxya[4]:=d_clip[2];
						pxya[5]:=pxya[3];
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya);
						pxya[0]:=d_clip[0];
						pxya[1]:=d_clip[3]+1;
						pxya[2]:=d_clip[2]+1;
						pxya[3]:=pxya[1];
						pxya[4]:=pxya[2];
						pxya[5]:=d_clip[1];
						vsl_color(vdiHandle,White);
						vPline(vdiHandle,3,pxya);
						inc(d_tx);
						inc(d_ty)
					end
				else
					begin
						pxya[0]:=d_clip[0]-1;
						pxya[1]:=d_clip[3];
						pxya[2]:=pxya[0];
						pxya[3]:=d_clip[1]-1;
						pxya[4]:=d_clip[2];
						pxya[5]:=pxya[3];
						vsl_color(vdiHandle,White);
						vPline(vdiHandle,3,pxya);
						pxya[0]:=d_clip[0];
						pxya[1]:=d_clip[3]+1;
						pxya[2]:=d_clip[2]+1;
						pxya[3]:=pxya[1];
						pxya[4]:=pxya[2];
						pxya[5]:=d_clip[1];
						vsl_color(vdiHandle,LBlack);
						vPline(vdiHandle,3,pxya)
					end;
				if Attr.Colors>=LWhite then vsl_color(vdiHandle,LWhite)
				else
					vsl_color(vdiHandle,White);
				pxya[0]:=d_clip[0]-1;
				pxya[1]:=d_clip[3]+1;
				pxya[2]:=pxya[0];
				pxya[3]:=pxya[1];
				vPline(vdiHandle,2,pxya);
				pxya[0]:=d_clip[2]+1;
				pxya[1]:=d_clip[1]-1;
				pxya[2]:=pxya[0];
				pxya[3]:=pxya[1];
				vPline(vdiHandle,2,pxya);
				vsl_color(vdiHandle,Black);
				dec(d_clip[0],2);
				dec(d_clip[1],2);
				inc(d_clip[2],2);
				inc(d_clip[3],2);
				pxya[0]:=d_clip[0];
				pxya[1]:=d_clip[1];
				pxya[2]:=d_clip[2];
				pxya[3]:=d_clip[1];
				pxya[4]:=d_clip[2];
				pxya[5]:=d_clip[3];
				pxya[6]:=d_clip[0];
				pxya[7]:=d_clip[3];
				pxya[8]:=pxya[0];
				pxya[9]:=pxya[1];
				vPline(vdiHandle,5,pxya);
				dec(d_clip[0]);
				dec(d_clip[1]);
				inc(d_clip[2]);
				inc(d_clip[3]);
				pxya[0]:=d_clip[0];
				pxya[1]:=d_clip[1];
				pxya[2]:=d_clip[2];
				pxya[3]:=d_clip[1];
				pxya[4]:=d_clip[2];
				pxya[5]:=d_clip[3];
				pxya[6]:=d_clip[0];
				pxya[7]:=d_clip[3];
				pxya[8]:=pxya[0];
				pxya[9]:=pxya[1];
				vPline(vdiHandle,5,pxya);
				if bTst(parm^.pb_tree^[parm^.pb_obj].ob_flags,DEFAULT) then
					begin
						dec(d_clip[0]);
						dec(d_clip[1]);
						inc(d_clip[2]);
						inc(d_clip[3]);
						pxya[0]:=d_clip[0];
						pxya[1]:=d_clip[1];
						pxya[2]:=d_clip[2];
						pxya[3]:=d_clip[1];
						pxya[4]:=d_clip[2];
						pxya[5]:=d_clip[3];
						pxya[6]:=d_clip[0];
						pxya[7]:=d_clip[3];
						pxya[8]:=pxya[0];
						pxya[9]:=pxya[1];
						vPline(vdiHandle,5,pxya)
					end;
				vswr_mode(vdiHandle,MD_TRANS);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				vgText(vdiHandle,d_tx,d_ty,d_btn);
				if d_scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED or TF_UNDERLINED)
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdihandle,SysInfo.HotKeyCol)
							end;
						d_btn[0]:=#1;
						d_btn[1]:=#32;
						vgText(vdiHandle,d_tx+(d_scpos-1)*Attr.charSWidth,d_ty,d_btn)
					end;
				vsl_type(vdiHandle,LT_SOLID);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vswr_mode(vdiHandle,MD_REPLACE);
				vst_effects(vdiHandle,TF_NORMAL);
				vst_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawPushButton:=NORMAL
	end;


function GEMVersion: word;

	begin
		if Application<>nil then GEMVersion:=GEM_pb.global[0]
		else
			GEMVersion:=0
	end;


function IsDesktopActive: boolean;
	var p     : pointer;
	    fname : string;
	    st,sid: integer;

	begin
		if agi.ApplSearch then
			begin
				wind_update(BEG_UPDATE);
				appl_search(2,fname,st,sid);
				with AES_pb do
					begin
						control^[0]:=13;
						control^[1]:=0;
						control^[2]:=1;
						control^[3]:=1;
						control^[4]:=0;
						addrin^[0]:=nil
					end;
				_crystal(@AES_pb);
				IsDesktopActive:=(sid=AES_pb.intout^[0]);
				wind_update(END_UPDATE)
			end
		else
			begin
				p:=GetOSHeaderPtr;
				if TOSVersion<$0102 then
					begin
						if (PWord(longint(p)+28)^ div 2)=SPA then p:=pointer($873c)
						else
							p:=pointer($602c)
					end
				else
					p:=PPointer(longint(p)+40)^;
				IsDesktopActive:=(PDPtr(PPointer(p)^)^.p_tlen=0)
			end
	end;


procedure GetQSB(var p: pointer; var len: longint);
	var w1,w2,w3,w4: integer;

	begin
		if Application<>nil then
			if Application^.MultiTOS then
				begin
					p:=nil;
					len:=0;
					exit
				end;
		wind_get(DESK,WF_SCREEN,w1,w2,w3,w4);
		p:=Ptr(word(w1),word(w2));
		len:=longint(Ptr(word(w3),word(w4)));
		if (len=0) and (GEMVersion=$0120) then len:=8000
	end;


procedure GlobalAlloc(var p: pointer; size: longint);
	var mp: boolean;

	begin
		if Application<>nil then mp:=Application^.MemoryProtection
		else
			mp:=false;
		if mp then p:=mxalloc(size,allocmode)
		else
			getmem(p,size)
	end;


procedure GlobalFree(var p: pointer; size: longint);
	var mp: boolean;

	begin
		if p=nil then exit;
		if Application<>nil then mp:=Application^.MemoryProtection
		else
			mp:=false;
		if not(mp) then
			begin
				freemem(p,size);
				p:=nil
			end
		else
			if mfree(p)=0 then p:=nil
	end;


function GetTempDir: string;

	function gettemp(fn: string): boolean;

		begin
			gettemp:=false;
			fn:=GetEnv(fn);
			if length(fn)=0 then exit;
			StrPTrim(fn);
			if StrPLeft(fn,1)='\' then fn:=BootDevice+':'+fn;
			if StrPRight(StrPLeft(fn,2),1)<>':' then fn:=BootDevice+':\'+fn;
			if StrPRight(fn,1)<>'\' then fn:=fn+'\';
			if PathExist(fn) then
				begin
					gettemp:=true;
					GetTempDir:=fn
				end
		end;

	begin
		GetTempDir:=BootDevice+':\';
		if gettemp('TMPDIR') then exit;
		if gettemp('TEMPDIR') then exit;
		if gettemp('TMP') then exit;
		if gettemp('TEMP') then exit;
		if gettemp('TRASHDIR') then exit;
		if Application<>nil then
			with Application^ do
				if apPath<>nil then GetTempDir:=apPath^
	end;


function GetHomeDir(RootDefault: boolean): string;
	var fn: string;

	begin
		if RootDefault then GetHomeDir:=BootDevice+':\'
		else
			begin
				GetHomeDir:='';
				if Application<>nil then
					if Application^.apPath<>nil then GetHomeDir:=Application^.apPath^
			end;
		fn:=GetEnv('HOME');
		if length(fn)=0 then exit;
		StrPTrim(fn);
		if StrPLeft(fn,1)='\' then fn:=BootDevice+':'+fn;
		if StrPRight(StrPLeft(fn,2),1)<>':' then fn:=BootDevice+':\'+fn;
		if StrPRight(fn,1)<>'\' then fn:=fn+'\';
		if PathExist(fn) then GetHomeDir:=fn
	end;


function xfilesys(const fsys: string): boolean;
	var maxmode: longint;

	begin
		maxmode:=dpathconf(fsys,-1);
		if maxmode<3 then xfilesys:=(pdomain(-1)=1)
		else
			if maxmode>=6 then xfilesys:=(dpathconf(fsys,6)<>1)
			else
				if maxmode>=5 then xfilesys:=(dpathconf(fsys,5)<>2)
				else
					xfilesys:=(dpathconf(fsys,3)>12)
	end;


function FileSelect(AParent: PWindow; ATitle,AMask: string; var APath,AFile: string; ForceExist: boolean): boolean;

	begin
		FileSelect:=FilePathSelect(AParent,ATitle,AMask,APath,AFile,false,ForceExist)
	end;


function FilePathSelect(AParent: PWindow; ATitle,AMask: string; var APath,AFile: string; AllowPaths,ForceExist: boolean): boolean;
	label _again;

	var fname,fpath,npath,dmy: string;
	    exitButton,ret       : integer;
	    dummy                : longint;
	    olddta               : DTAPtr;
	    newdta               : DTA;
	    fsel,nofsel2,xfs     : boolean;

	begin
		wind_update(BEG_UPDATE);
		nofsel2:=true;
		fsel:=GetCookie('FSEL',dummy);
		if fsel then
			if dummy<>0 then
				with PSelectric(dummy)^ do
					if magic='SLCT' then
						if version>=$0200 then nofsel2:=false;
		if nofsel2 then wind_update(BEG_MCTRL);
		olddta:=FGetdta;
		Fsetdta(@newdta);
		FilePathSelect:=false;
		if length(APath)=0 then dgetpath(fpath,0)
		else
			fpath:=APath;
		if StrPRight(fpath,1)<>'\' then fpath:=fpath+'\';
		if StrPRight(StrPLeft(fpath,2),1)<>':' then fpath:=chr(dgetdrv+65)+':'+fpath;
		if fpath[3]<>'\' then
			fpath:=StrPLeft(fpath,2)+'\'+StrPRight(fpath,length(fpath)-2);
		xfs:=xfilesys(fpath);
		if not(xfs) then fpath:=StrPUpper(fpath);
		if length(AMask)=0 then fpath:=fpath+'*.*'
		else
			begin
				if not(xfs) then AMask:=StrPUpper(AMask);
				fpath:=fpath+AMask
			end;
		if xfs then fname:=AFile
		else
			fname:=StrPUpper(AFile);
		_again:
		{ fslx_do()? }
		if ((GEMVersion>=$0140) and (GEMVersion<$0200)) or (GEMVersion>=$0300) or fsel then
			ret:=fsel_exinput(fpath,fname,exitButton,ATitle)
		else
			ret:=fsel_input(fpath,fname,exitButton);
		if (exitButton=1) and (ret<>0) and ((length(fname)>0) or AllowPaths) then
			begin
				if length(fname)>0 then
					begin
						dummy:=pos('.',AMask);
						if ((pos('.',fname)=0) or (StrPRight(fname,1)='.')) and Between(dummy,1,length(AMask)-1) then
							begin
								dmy:=StrPRight(AMask,length(AMask)-dummy);
								if (pos('?',dmy)=0) and (pos('*',dmy)=0) then
									begin
										if StrPRight(fname,1)='.' then fname:=fname+dmy
										else
											fname:=fname+'.'+dmy
									end
							end
					end;
				npath:=StrPLeft(fpath,RPos('\',fpath));
				if ForceExist then
					if length(fname)>0 then
						if not(Exist(npath+fname)) then
							begin
								if Application<>nil then
									with Application^ do
										begin
											if Attr.Country=FRA then
												Alert(nil,1,NOTE,'"'+fname+'" n''existe pas.','  &OK  ')
											else if (Attr.Country=FRG) or (Attr.Country=SWG) then
												Alert(nil,1,NOTE,'"'+fname+'" existiert nicht.','  &OK  ')
											else
												Alert(nil,1,NOTE,'"'+fname+'" does not exist.','  &OK  ')
										end
								else
									form_alert(1,'[1][ | | |"'+fname+'" existiert nicht.  ][   OK   ]');
								goto _again
							end;
				APath:=npath;
				AFile:=fname;
				FilePathSelect:=true
			end;
		Fsetdta(olddta);
		if nofsel2 then wind_update(END_MCTRL);
		wind_update(END_UPDATE);
		if Application<>nil then
			Application^.RestoreModalDialog(AParent)
	end;


function XFileSelect(AParent: PWindow; ATitle,AMask: string; var APath,AFile: string; MaxFiles: integer; Group: byte; ForceExist,Modal: boolean): boolean;
	label _raus;

	var fdmstr     : TFdmStr;
	    nofsel2,xfs: boolean;
	    indx       : byte;
	    pkt        : integer;
	    dummy      : PSelectric;
	    pisel      : array[0..255] of char;
	    olddta     : DTAPtr;
	    newdta     : DTA;
	    fpath,dmy  : string;
	    pipe       : Pipearray;

	begin
		wind_update(BEG_UPDATE);
		nofsel2:=true;
		if GetCookie('FSEL',longint(dummy)) then
			if dummy<>nil then
				with dummy^ do
					if magic='SLCT' then
						if version>=$0200 then nofsel2:=false;
		if nofsel2 or Modal then XFileSelect:=FileSelect(AParent,ATitle,AMask,APath,AFile,ForceExist)
		else
			begin
				XFileSelect:=false;
				if AParent<>nil then
					for pkt:=0 to XSELMAX do
						if xselwind[pkt].window=AParent then
							if xselwind[pkt].group=Group then
								begin
									pipe[0]:=WIN_TOPPED;
									pipe[1]:=Application^.apID;
									pipe[2]:=0;
									pipe[3]:=xselwind[pkt].fdmwhnd;
									appl_write(freedom,16,@pipe);
									goto _raus
								end;
				olddta:=FGetdta;
				Fsetdta(@newdta);
				if length(APath)=0 then dgetpath(fpath,0)
				else
					fpath:=APath;
				if StrPRight(fpath,1)<>'\' then fpath:=fpath+'\';
				if StrPRight(StrPLeft(fpath,2),1)<>':' then fpath:=chr(dgetdrv+65)+':'+fpath;
				if fpath[3]<>'\' then
					fpath:=StrPLeft(fpath,2)+'\'+StrPRight(fpath,length(fpath)-2);
				xfs:=xfilesys(fpath);
				if not(xfs) then fpath:=StrPUpper(fpath);
				if length(AMask)=0 then fpath:=fpath+'*.*'
				else
					begin
						if not(xfs) then AMask:=StrPUpper(AMask);
						fpath:=fpath+AMask
					end;
				ATitle:=StrPLeft(StrPTrimF(ATitle),254)+#0;
				indx:=XSELMAX+1;
				for pkt:=XSELMAX downto 0 do if xselwind[pkt].window=nil then indx:=pkt;
				with fdmstr do
					begin
						magic:='?Fdm';
						id:=indx;
						if ForceExist then id:=id or 128;
						id:=(id shl 8) or Group;
						if MaxFiles<1 then maxsel:=32767
						else
							maxsel:=MaxFiles;
						flags:=$e0000000;
						StrPCopy(path,fpath)
					end;
				if xfs then StrPCopy(pisel,AFile)
				else
					StrPCopy(pisel,StrPUpper(AFile));
				with AES_pb do
					begin
						control^[0]:=91;
						control^[1]:=0;
						control^[2]:=2;
						control^[3]:=3;
						control^[4]:=0;
						addrin^[0]:=@fdmstr;
						addrin^[1]:=@pisel;
						addrin^[2]:=@ATitle[1];
						_crystal(@AES_pb);
						if fdmstr.magic='!Fdm' then
							begin
								xselwind[indx].window:=AParent;
								xselwind[indx].fdmwhnd:=fdmstr.handle;
								xselwind[indx].group:=Group;
								freedom:=fdmstr.server
							end
						else
							if (intout^[0]<>0) and (intout^[1]=1) and (StrLen(pisel)>0) then
								begin
									pkt:=pos('.',AMask);
									AFile:=StrPas(pisel);
									fpath:=StrPas(PChar(@fdmstr));
									if ((pos('.',AFile)=0) or (StrPRight(AFile,1)='.')) and Between(pkt,1,length(AMask)-1) then
										begin
											dmy:=StrPRight(AMask,length(AMask)-pkt);
											if (pos('?',dmy)=0) and (pos('*',dmy)=0) then
												begin
													if StrPRight(AFile,1)='.' then AFile:=AFile+dmy
													else
														AFile:=AFile+'.'+dmy
												end
										end;
									APath:=StrPLeft(fpath,RPos('\',fpath));
									XFileSelect:=true
								end
					end;
				Fsetdta(olddta)
			end;
		_raus:
		wind_update(END_UPDATE)
	end;


procedure checkinfpath(var FileName: string);
	var pfad: string;

	begin
		if pos('\',FileName)>0 then exit;
		if Application=nil then exit;
		if bTst(Application^.Attr.Style,as_UseHomeDir) then
			if length(GetEnv('HOME'))>0 then
				begin
					pfad:=GetHomeDir(false)+'defaults\';
					if PathExist(pfad) then
						begin
							FileName:=pfad+FileName;
							exit
						end
					else
						begin
							pfad:=GetHomeDir(false);
							if PathExist(pfad) then
								begin
									FileName:=pfad+FileName;
									exit
								end
						end
				end;
		if Application^.apPath<>nil then FileName:=Application^.apPath^+FileName
	end;


function OpenPrivateProfile(FileName: string): boolean;
	label _exit;

	var buf    : PByteArray;
	    bufsize,
	    res,w  : longint;
	    hdl    : integer;
	    txt    : string;

	begin
		OpenPrivateProfile:=false;
		if profile<>nil then exit;
		checkinfpath(FileName);
		if StrPLower(GetHomeDir(true))+SYSPROFILE=StrPLower(FileName) then exit;
		profilename:=NewStr(StrPLower(FileName));
		if profilename=nil then exit;
		new(profile,Init(50,25));
		if profile=nil then
			begin
				DisposeStr(profilename);
				exit
			end;
		lastprofkey:=nil;
		profkeyat:=0;
		profilechng:=false;
		if Exist(FileName) then
			begin
				buf:=GetMemBuffer(16384,128,bufsize);
				if buf=nil then exit;
				wind_update(BEG_UPDATE);
				BusyMouse;
				res:=fopen(FileName,FO_READ);
				if res<0 then goto _exit;
				hdl:=integer(res);
				txt:='';
				repeat
					res:=fread(hdl,bufsize,buf);
					if res>0 then
						for w:=0 to res-1 do
							if buf^[w]=CR then
								begin
									profile^.Insert(ChrNew(StrPTrimF(txt)));
									txt:=''
								end
							else
								if buf^[w]>=32 then txt:=txt+chr(buf^[w])
				until res<>bufsize;
				fclose(hdl);
				OpenPrivateProfile:=true;
				_exit:
				freemem(buf,bufsize);
				ArrowMouse;
				wind_update(END_UPDATE)
			end
	end;


function SavePrivateProfile: boolean;
	label _exit,_error;

	var tfile  : string;
	    q,l,res,
	    bufcnt,
	    bufsize: longint;
	    hdl    : integer;
	    buf    : PByteArray;
	    lend   : string[2];
	    werror : boolean;

	function bwrite(var buffer; count: longint): boolean;
		var rlen: longint;

		begin
			if count>bufsize then
				begin
					werror:=true;
					bwrite:=true;
					exit
				end;
			bwrite:=false;
			if count<1 then
				begin
					if count=0 then exit;
					if bufcnt>0 then
						begin
							rlen:=fwrite(hdl,bufcnt,buf);
							if rlen<>bufcnt then
								begin
									werror:=true;
									bwrite:=true
								end;
							bufcnt:=0
						end;
					exit
				end;
			if bufcnt+count>bufsize then
				begin
					rlen:=fwrite(hdl,bufcnt,buf);
					if rlen<>bufcnt then
						begin
							werror:=true;
							bwrite:=true
						end;
					bufcnt:=0
				end;
			move(buffer,buf^[bufcnt],count);
			inc(bufcnt,count)
		end;

	begin
		SavePrivateProfile:=false;
		if profile<>nil then
			begin
				if profilechng then
					begin
						buf:=GetMemBuffer(16384,512,bufsize);
						if buf=nil then exit;
						wind_update(BEG_UPDATE);
						BusyMouse;
						tfile:=GetPath(profilename^)+GetTempFilename;
						res:=fcreate(tfile,0);
						if res<0 then goto _exit;
						hdl:=integer(res);
						werror:=false;
						bufcnt:=0;
						lend:=#13#10;
						if profile^.Count>0 then
							for q:=0 to profile^.Count-1 do
								if profile^.At(q)<>nil then
									begin
										l:=StrLen(profile^.At(q));
										if l>0 then
											if bwrite(PChar(profile^.At(q))^,l) then goto _error;
										if bwrite(lend[1],2) then goto _error
									end;
						bwrite(lend,-1);
						_error:
						fclose(hdl);
						if werror then fdelete(tfile)
						else
							begin
								fdelete(profilename^);
								if frename(tfile,profilename^)=0 then
									begin
										SavePrivateProfile:=true;
										profilechng:=false
									end
							end;
						_exit:
						freemem(buf,bufsize);
						ArrowMouse;
						wind_update(END_UPDATE)
					end
				else
					SavePrivateProfile:=true
			end
	end;


function ClosePrivateProfile: boolean;

	begin
		if profile<>nil then
			begin
				ClosePrivateProfile:=SavePrivateProfile;
				dispose(profile,Done);
				DisposeStr(lastprofkey);
				DisposeStr(profilename);
				profile:=nil
			end
		else
			ClosePrivateProfile:=false
	end;


function WritePrivateProfileString(AppName,KeyName,Value,FileName: string): boolean;
	label _exit,_error,_closeall,_fertig,_weiter;

	var t,ca,key,aname,
	    kname,tfile,s : string;
	    p,rhdl,whdl   : integer;
	    found,rblk,
	    werror        : boolean;
	    rem           : string[1];
	    lend          : string[2];
	    wbuf,rbuf     : PByteArray;
	    wbufsize,res,
	    rbufsize,
	    wbufcnt,q,w   : longint;

	function bwrite(var buffer; count: longint): boolean;
		var rlen: longint;

		begin
			if count>wbufsize then
				begin
					werror:=true;
					bwrite:=true;
					exit
				end;
			bwrite:=false;
			if count<1 then
				begin
					if count=0 then exit;
					if wbufcnt>0 then
						begin
							rlen:=fwrite(whdl,wbufcnt,wbuf);
							if rlen<>wbufcnt then
								begin
									werror:=true;
									bwrite:=true
								end;
							wbufcnt:=0
						end;
					exit
				end;
			if wbufcnt+count>wbufsize then
				begin
					rlen:=fwrite(whdl,wbufcnt,wbuf);
					if rlen<>wbufcnt then
						begin
							werror:=true;
							bwrite:=true
						end;
					wbufcnt:=0
				end;
			move(buffer,wbuf^[wbufcnt],count);
			inc(wbufcnt,count)
		end;

	begin
		aname:=StrPUpper(StrPTrimF(AppName));
		kname:=StrPUpper(StrPTrimF(KeyName));
		WritePrivateProfileString:=false;
		if (length(aname)=0) or (length(kname)=0) then exit;
		checkinfpath(FileName);
		ca:='';
		found:=false;
		rblk:=false;
		if profile<>nil then
			if profilename^=StrPLower(FileName) then
				begin
					q:=0;
					if lastprofkey<>nil then
						if aname=lastprofkey^ then q:=profkeyat;
					while q<profile^.Count do
						begin
							if profile^.At(q)=nil then
								begin
									inc(q);
									continue
								end;
							t:=StrPTrimF(StrPas(profile^.At(q)));
							if StrPLeft(t,2)='##' then
								begin
									rblk:=not(rblk);
									inc(q);
									continue
								end;
							rem:=StrPLeft(t,1);
							if (rem=';') or (rem='#') or rblk then
								begin
									inc(q);
									continue
								end;
							if (StrPLeft(t,1)='[') and (StrPRight(t,1)=']') then
								begin
									ca:=StrPUpper(copy(t,2,length(t)-2));
									if ca=aname then
										begin
											DisposeStr(lastprofkey);
											lastprofkey:=NewStr(ca);
											profkeyat:=q
										end
								end
							else
								if ca=aname then
									begin
										if length(t)=0 then
											begin
												if length(Value)>0 then
													profile^.AtInsert(q,ChrNew(StrPTrimF(KeyName)+'='+Value));
												found:=true;
												goto _fertig
											end
										else
											begin
												p:=pos('=',t);
												if p>0 then
													if StrPUpper(StrPLeft(t,p-1))=kname then
														begin
															if length(Value)>0 then
																begin
																	profile^.FreeItem(profile^.At(q));
																	profile^.AtPut(q,ChrNew(StrPTrimF(KeyName)+'='+Value))
																end
															else
																profile^.AtFree(q);
															found:=true;
															goto _fertig
														end
											end
									end;
							inc(q)
						end;
					_fertig:
					if not(found) then
						begin
							if rblk then profile^.Insert(ChrNew('##'));
							if ca<>aname then profile^.Insert(ChrNew('['+StrPTrimF(AppName)+']'));
							if length(Value)>0 then profile^.Insert(ChrNew(StrPTrimF(KeyName)+'='+Value));
							profile^.Insert(ChrNew(''))
						end;
					WritePrivateProfileString:=true;
					profilechng:=true;
					exit
				end;
		wbuf:=GetMemBuffer(16384,512,wbufsize);
		if wbuf=nil then exit;
		rbuf:=GetMemBuffer(16384,128,rbufsize);
		if rbuf=nil then
			begin
				freemem(wbuf,wbufsize);
				exit
			end;
		wind_update(BEG_UPDATE);
		tfile:=GetPath(FileName)+GetTempFilename;
		wbufcnt:=0;
		werror:=false;
		if not(Exist(FileName)) then
			begin
				res:=fcreate(FileName,0);
				if res<0 then goto _exit;
				if fclose(integer(res))<0 then goto _exit
			end;
		if frename(FileName,tfile)<0 then goto _exit;
		res:=fcreate(FileName,0);
		if res<0 then goto _exit;
		whdl:=integer(res);
		res:=fopen(tfile,FO_READ);
		if res<0 then goto _error;
		rhdl:=integer(res);
		t:='';
		lend:=#13#10;
		repeat
			res:=fread(rhdl,rbufsize,rbuf);
			if res>0 then
				for w:=0 to res-1 do
					if rbuf^[w]=CR then
						begin
							StrPTrim(t);
							if StrPLeft(t,2)='##' then
								begin
									rblk:=not(rblk);
									if bwrite(t[1],length(t)) then goto _closeall;
									if bwrite(lend[1],2) then goto _closeall;
									goto _weiter
								end;
							rem:=StrPLeft(t,1);
							if found or rblk or (rem=';') or (rem='#') then
								begin
									if bwrite(t[1],length(t)) then goto _closeall;
									if bwrite(lend[1],2) then goto _closeall
								end
							else
								begin
									if (StrPLeft(t,1)='[') and (StrPRight(t,1)=']') then
										begin
											if bwrite(t[1],length(t)) then goto _closeall;
											if bwrite(lend[1],2) then goto _closeall;
											ca:=StrPUpper(copy(t,2,length(t)-2))
										end
									else
										begin
											if ca=aname then
												begin
													if length(t)=0 then
														begin
															if length(Value)>0 then
																begin
																	s:=StrPTrimF(KeyName)+'='+Value+#13#10;
																	if bwrite(s[1],length(s)) then goto _closeall
																end;
															if bwrite(lend[1],2) then goto _closeall;
															found:=true
														end
													else
														begin
															p:=pos('=',t);
															if p>0 then
																begin
																	if StrPUpper(StrPLeft(t,p-1))=kname then
																		begin
																			if length(Value)>0 then
																				begin
																					s:=StrPTrimF(KeyName)+'='+Value+#13#10;
																					if bwrite(s[1],length(s)) then goto _closeall
																				end;
																			found:=true
																		end
																	else
																		begin
																			if bwrite(t[1],length(t)) then goto _closeall;
																			if bwrite(lend[1],2) then goto _closeall
																		end
																end
														end
												end
											else
												begin
													if bwrite(t[1],length(t)) then goto _closeall;
													if bwrite(lend[1],2) then goto _closeall
												end
										end
								end;
							_weiter:
							t:=''
						end
					else
						if rbuf^[w]>=32 then t:=t+chr(rbuf^[w])
		until res<>rbufsize;
		if res<0 then goto _closeall;
		if not(found) then
			begin
				if rblk then
					begin
						s:='##'#13#10;
						if bwrite(s[1],4) then goto _closeall
					end;
				if ca<>aname then
					begin
						s:='['+StrPTrimF(AppName)+']'#13#10;
						if bwrite(s[1],length(s)) then goto _closeall
					end;
				if length(Value)>0 then
					begin
						s:=StrPTrimF(KeyName)+'='+Value+#13#10;
						if bwrite(s[1],length(s)) then goto _closeall
					end;
				if bwrite(lend[1],2) then goto _closeall
			end;
		WritePrivateProfileString:=true;
		_closeall:
		fclose(rhdl);
		_error:
		fclose(whdl);
		fdelete(tfile);
		_exit:
		freemem(wbuf,wbufsize);
		freemem(rbuf,rbufsize);
		wind_update(END_UPDATE)
	end;


function WritePrivateProfileBool(AppName,KeyName: string; Value: boolean; FileName: string): boolean;

	begin
		if Value then WritePrivateProfileBool:=WritePrivateProfileString(AppName,KeyName,'TRUE',FileName)
		else
			WritePrivateProfileBool:=WritePrivateProfileString(AppName,KeyName,'FALSE',FileName)
	end;


function WritePrivateProfileInt(AppName,KeyName: string; Value: longint; FileName: string): boolean;

	begin
		WritePrivateProfileInt:=WritePrivateProfileString(AppName,KeyName,ltoa(Value),FileName)
	end;


function GetPrivateProfileString(AppName,KeyName,Default,FileName: string): string;
	label _exit,_default,_error,_weiter;

	var buf    : PByteArray;
	    bufsize,
	    res,w,q: longint;
	    hdl,p  : integer;
	    t,ca   : string;
	    rem    : string[1];
	    rblk   : boolean;

	begin
		AppName:=StrPUpper(StrPTrimF(AppName));
		KeyName:=StrPUpper(StrPTrimF(KeyName));
		if (length(AppName)=0) or (length(KeyName)=0) then goto _default;
		checkinfpath(FileName);
		ca:='';
		rblk:=false;
		if profile<>nil then
			if profilename^=StrPLower(FileName) then
				begin
					q:=0;
					if lastprofkey<>nil then
						if AppName=lastprofkey^ then q:=profkeyat;
					while q<profile^.Count do
						begin
							if profile^.At(q)=nil then
								begin
									inc(q);
									continue
								end;
							t:=StrPTrimF(StrPas(profile^.At(q)));
							if StrPLeft(t,2)='##' then
								begin
									rblk:=not(rblk);
									inc(q);
									continue
								end;
							if rblk then
								begin
									inc(q);
									continue
								end;
							if (StrPLeft(t,1)='[') and (StrPRight(t,1)=']') then
								begin
									ca:=StrPUpper(copy(t,2,length(t)-2));
									if ca=AppName then
										begin
											DisposeStr(lastprofkey);
											lastprofkey:=NewStr(ca);
											profkeyat:=q
										end
								end
							else
								if ca=AppName then
									begin
										rem:=StrPLeft(t,1);
										if (rem<>';') and (rem<>'#') then
											begin
												p:=pos('=',t);
												if p>0 then
													if StrPUpper(StrPLeft(t,p-1))=KeyName then
														begin
															GetPrivateProfileString:=StrPRight(t,length(t)-p);
															exit
														end
											end
									end;
							inc(q)
						end;
					goto _default
				end;
		wind_update(BEG_UPDATE);
		buf:=GetMemBuffer(16384,128,bufsize);
		if buf=nil then goto _exit;
		res:=fopen(FileName,FO_READ);
		if res<0 then goto _error;
		hdl:=integer(res);
		t:='';
		repeat
			res:=fread(hdl,bufsize,buf);
			if res>0 then
				for w:=0 to res-1 do
					if buf^[w]=CR then
						begin
							StrPTrim(t);
							if StrPLeft(t,2)='##' then
								begin
									rblk:=not(rblk);
									goto _weiter
								end;
							if rblk then goto _weiter;
							if (StrPLeft(t,1)='[') and (StrPRight(t,1)=']') then ca:=StrPUpper(copy(t,2,length(t)-2))
							else
								begin
									rem:=StrPLeft(t,1);
									if (rem<>';') and (rem<>'#') then
										begin
											p:=pos('=',t);
											if p>0 then
												if StrPUpper(StrPLeft(t,p-1))=KeyName then
													if ca=AppName then
														begin
															GetPrivateProfileString:=StrPRight(t,length(t)-p);
															fclose(hdl);
															freemem(buf,bufsize);
															wind_update(END_UPDATE);
															exit
														end
										end
								end;
							_weiter:
							t:=''
						end
					else
						if buf^[w]>=32 then t:=t+chr(buf^[w])
		until res<>bufsize;
		fclose(hdl);
		_error:
		freemem(buf,bufsize);
		_exit:
		wind_update(END_UPDATE);
		_default:
		GetPrivateProfileString:=Default
	end;


function GetPrivateProfileBool(AppName,KeyName: string; Default: boolean; FileName: string): boolean;
	var sval: string;

	begin
		sval:=GetPrivateProfileString(AppName,KeyName,'',FileName);
		if sval='' then GetPrivateProfileBool:=Default
		else
			begin
				StrPUpper(sval);
				if (sval='0') or (sval='FALSE') then GetPrivateProfileBool:=false
				else
					GetPrivateProfileBool:=true
			end
	end;


function GetPrivateProfileInt(AppName,KeyName: string; Default: longint; FileName: string): longint;
	var sval: string;

	begin
		sval:=GetPrivateProfileString(AppName,KeyName,'',FileName);
		if sval='' then GetPrivateProfileInt:=Default
		else
			GetPrivateProfileInt:=atol(sval)
	end;


function GetPrivateProfileIntRange(AppName,KeyName: string; Default,MinVal,MaxVal: longint; FileName: string): longint;
	var ret: longint;

	begin
		if MinVal>MaxVal then
			begin
				ret:=MinVal;
				MinVal:=MaxVal;
				MaxVal:=ret
			end;
		ret:=GetPrivateProfileInt(AppName,KeyName,Default,FileName);
		if ret<MinVal then ret:=MinVal;
		if ret>MaxVal then ret:=MaxVal;
		GetPrivateProfileIntRange:=ret
	end;


function WriteProfileString(AppName,KeyName,Value: string): boolean;

	begin
		WriteProfileString:=WritePrivateProfileString(AppName,KeyName,Value,GetHomeDir(true)+SYSPROFILE)
	end;


function WriteProfileBool(AppName,KeyName: string; Value: boolean): boolean;

	begin
		WriteProfileBool:=WritePrivateProfileBool(AppName,KeyName,Value,GetHomeDir(true)+SYSPROFILE)
	end;


function WriteProfileInt(AppName,KeyName: string; Value: longint): boolean;

	begin
		WriteProfileInt:=WritePrivateProfileInt(AppName,KeyName,Value,GetHomeDir(true)+SYSPROFILE)
	end;


function GetProfileString(AppName,KeyName,Default: string): string;

	begin
		GetProfileString:=GetPrivateProfileString(AppName,KeyName,Default,GetHomeDir(true)+SYSPROFILE)
	end;


function GetProfileBool(AppName,KeyName: string; Default: boolean): boolean;

	begin
		GetProfileBool:=GetPrivateProfileBool(AppName,KeyName,Default,GetHomeDir(true)+SYSPROFILE)
	end;


function GetProfileInt(AppName,KeyName: string; Default: longint): longint;

	begin
		GetProfileInt:=GetPrivateProfileInt(AppName,KeyName,Default,GetHomeDir(true)+SYSPROFILE)
	end;


function GetProfileIntRange(AppName,KeyName: string; Default,MinVal,MaxVal: longint): longint;

	begin
		GetProfileIntRange:=GetPrivateProfileIntRange(AppName,KeyName,Default,MinVal,MaxVal,GetHomeDir(true)+SYSPROFILE)
	end;


function SetMouse(Indx: HCursor; Form: MFORMPtr): integer;
	const CMAX   = IDC_SLICE4;
	      MFORCE = $8000;
				GOCrs : array[IDC_WAIT..CMAX] of MFORM =
	           ((mf_xhot: 8; mf_yhot: 8; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (32767,16385,16385,28667,28027,14006,7020,3544,3416,7148,14006,27995,27307,16385,16385,32767);
	             mf_data: (0,16382,16382,4100,4740,2376,1168,544,672,1040,2376,4772,5460,16382,16382,0)),
	            (mf_xhot: 1; mf_yhot: 1; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (32760,-32764,-28702,-28895,-28895,-28895,-32767,-32767,-24583,-27303,-25943,-27303,-25943,-24583,-32767,32766);
	             mf_data: (0,32760,28700,28894,28894,28894,32766,32766,24582,27302,25942,27302,25942,16390,32766,0)),
	            (mf_xhot: 0; mf_yhot: 0; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (-16130,-24125,-28287,-30311,-31247,-31773,-32313,-32625,-32743,-31871,-27709,-22017,-13849,-31513,1278,896);
	             mf_data: (0,16444,24702,28774,30734,31772,32312,32624,32742,31870,27708,17920,1560,792,768,0)),
	            (mf_xhot: 1; mf_yhot: 14; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (24,36,74,153,309,618,1236,2472,4944,9888,9536,23168,22784,-31232,-26624,-8192);
	             mf_data: (0,24,52,102,202,404,808,1616,3232,6464,6784,9472,9728,30720,24576,0)),
	            (mf_xhot: 1; mf_yhot: 1; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (-512,-32512,-16768,-20672,-18528,23504,11752,5876,3066,1409,701,317,129,127,0,0);
	             mf_data: (0,32256,16640,20608,18496,9248,4624,2312,1028,638,322,194,126,0,0,0)),
	            (mf_xhot: 1; mf_yhot: 1; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (-8192,-28672,-30720,17408,8704,4352,2718,1377,685,333,417,542,720,720,528,480);
	             mf_data: (0,24576,28672,14336,7168,3584,1280,670,338,178,94,480,288,288,480,0)),
	            (mf_xhot: 1; mf_yhot: 1; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
	             mf_mask: (24576,-28672,-20736,20608,11328,11040,10128,10192,5064,2536,1256,620,290,138,98,28);
	             mf_data: (0,24576,20480,12032,4992,5312,6240,6176,3120,1552,784,400,220,116,28,0)),
							(mf_xhot: 7; mf_yhot: 7; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
							 mf_mask: (960,3120,4296,8436,16634,16634,-32515,-32515,-16639,-16639,24322,24322,12036,4872,3120,960);
							 mf_data: (0,960,3888,7944,16132,16132,32514,32514,16638,16638,8444,8444,4344,3312,960,0)),
							(mf_xhot: 7; mf_yhot: 7; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
							 mf_mask: (960,3120,4104,8196,20490,22554,-17347,-16771,-16771,-17347,22554,20490,8196,4104,3120,960);
							 mf_data: (0,960,4080,8184,12276,10212,17346,16770,16770,17346,10212,12276,8184,4080,960,0)),
							(mf_xhot: 7; mf_yhot: 7; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
							 mf_mask: (960,3120,4872,12036,24322,24322,-16639,-16639,-32515,-32515,16634,16634,8436,4296,3120,960);
							 mf_data: (0,960,3312,4344,8444,8444,16638,16638,32514,32514,16132,16132,7944,3888,960,0)),
							(mf_xhot: 7; mf_yhot: 7; mf_nplanes: 1; mf_fg: 0; mf_bg: 1;
							 mf_mask: (960,3120,5064,12276,18402,17346,-32383,-32767,-32767,-32383,17346,18402,12276,5064,3120,960);
							 mf_data: (0,960,3120,4104,14364,15420,32382,32766,32766,32382,15420,14364,4104,3120,960,0)));

	var ret: integer;
	    frc: word;

	begin
		if bTst(Indx,MFORCE) and (GEMVersion>=$0400) then frc:=MFORCE
		else
			frc:=0;
		Indx:=Indx and $7fff;
		if Indx=USER_DEF then
			begin
				if Form<>nil then
					begin
						ret:=graf_mouse(frc or USER_DEF,Form);
						if ret<>0 then
							with maus do
								begin
									lastnr:=currnr;
									lastform:=currform;
									currnr:=USER_DEF;
									currform:=Form^
								end
					end
				else
					ret:=0
			end
		else
			if (Indx>=IDC_WAIT) and (Indx<=CMAX) then
				begin
					ret:=graf_mouse(frc or USER_DEF,@GOCrs[Indx]);
					if (ret<>0) and (longint(Form)<>1) then
						with maus do
							begin
								lastnr:=currnr;
								lastform:=currform;
								currnr:=USER_DEF;
								currform:=GOCrs[Indx]
							end
				end
			else
				if (Indx<0) or (Indx>=M_OFF) then ret:=0
				else
					begin
						ret:=graf_mouse(frc or Indx,nil);
						if (ret<>0) and (longint(Form)<>1) then
							with maus do
								begin
									lastnr:=currnr;
									lastform:=currform;
									currnr:=Indx
								end
					end;
		SetMouse:=ret
	end;


procedure GetMouse(var Indx: HCursor; var Form: MFORM);

	begin
		Indx:=maus.currnr;
		Form:=maus.currform
	end;


procedure vr_trnfm(handle: integer; psrcMFDB,pdesMFDB: MFDB);
	var dest: pointer;
	    len : longint;

	begin
		if (psrcMFDB.fd_addr=pdesMFDB.fd_addr) and (psrcMFDB.fd_addr<>nil) then
			begin
				len:=(longint(psrcMFDB.fd_wdwidth)*longint(psrcMFDB.fd_h)*longint(psrcMFDB.fd_nplanes)) shl 1;
				getmem(dest,len);
				if dest=nil then gem.vr_trnfm(handle,psrcMFDB,pdesMFDB)
				else
					begin
						move(psrcMFDB.fd_addr^,dest^,len);
						pdesMFDB.fd_addr:=psrcMFDB.fd_addr;
						psrcMFDB.fd_addr:=dest;
						gem.vr_trnfm(handle,psrcMFDB,pdesMFDB);
						freemem(dest,len)
					end
			end
		else
			gem.vr_trnfm(handle,psrcMFDB,pdesMFDB)
	end;


procedure vr_convert(handle: integer; psrcMFDB: MFDB; format: integer);
	var pdesMFDB: MFDB;

	begin
		if psrcMFDB.fd_stand<>format then
			begin
				pdesMFDB:=psrcMFDB;
				pdesMFDB.fd_stand:=format;
				vr_trnfm(handle,psrcMFDB,pdesMFDB)
			end
	end;


procedure vdi_fix(var pfd: MFDB; theAddr: pointer; w,h: integer);

	begin
		with pfd do
			begin
				fd_addr:=theaddr;
				fd_wdwidth:=(w+15) shr 4;
				fd_w:=w;
				fd_h:=h;
				fd_nplanes:=1;
				fd_stand:=FF_STAND;
				fd_r1:=0;
				fd_r2:=0;
				fd_r3:=0
			end
	end;


function SetSystemFont(handle: integer; var wc,hc,wb,hb: integer): integer;

	begin
		SetSystemFont:=vst_font(handle,SysInfo.Font.ID);
		if SysInfo.Font.Point>0 then vst_point(handle,SysInfo.Font.Point,wc,hc,wb,hb)
		else
			vst_height(handle,SysInfo.Font.Height,wc,hc,wb,hb)
	end;


function SetSmallSystemFont(handle: integer; var wc,hc,wb,hb: integer): integer;

	begin
		SetSmallSystemFont:=vst_font(handle,SysInfo.SmallFont.ID);
		if SysInfo.SmallFont.Point>0 then vst_point(handle,SysInfo.SmallFont.Point,wc,hc,wb,hb)
		else
			vst_height(handle,SysInfo.SmallFont.Height,wc,hc,wb,hb)
	end;


procedure SetMousePos(mX,mY: integer);
	var arec: APPLRECORD;

	begin
		arec.Typ:=AT_MOUSE;
		arec.What.Hi:=mX;
		arec.What.Lo:=mY;
		appl_tplay(@arec,1,10000)
	end;


function IsMouseVisible: boolean;

	begin
		IsMouseVisible:=(mhstack<=0)
	end;


function IsMouseBusy: boolean;

	begin
		IsMouseBusy:=(mfstack>0)
	end;


procedure ShowMouse;

	begin
		graf_mouse(M_ON,nil);
		dec(mhstack)
	end;


procedure HideMouse;

	begin
		graf_mouse(M_OFF,nil);
		inc(mhstack)
	end;


procedure ArrowMouse;

	begin
		dec(mfstack);
		if mfstack<=0 then
			begin
				SetMouse(ARROW,nil);
				mfstack:=0;
			end
	end;


procedure BusyMouse;

	begin
		SetMouse(BUSYBEE,nil);
		inc(mfstack)
	end;


procedure SliceMouse;

	begin
		inc(mfstack);
		slmouse:=IDC_SLICE1;
		SliceMouseNext
	end;


procedure SliceMouseNext;

	begin
		if IsMouseBusy then
			begin
				SetMouse(slmouse,nil);
				inc(slmouse);
				if slmouse>IDC_SLICE4 then slmouse:=IDC_SLICE1;
				evnt_timer(1,0)
			end
	end;


procedure LastMouse;

	begin
		SetMouse(maus.lastnr,@maus.lastform);
	end;


function appl_xgetinfo(ap_gtype: integer; var ap_gout1,ap_gout2,ap_gout3,ap_gout4: integer): boolean;

	begin
		appl_xgetinfo:=false;
		if has_agi then
			with AES_pb do
				begin
					control^[0]:=130;
					control^[1]:=1;
					control^[2]:=5;
					control^[3]:=0;
					control^[4]:=0;
					intin^[0]:=ap_gtype;
					_crystal(@AES_pb);
					if intout^[0]<>0 then
						begin
							ap_gout1:=intout^[1];
							ap_gout2:=intout^[2];
							ap_gout3:=intout^[3];
							ap_gout4:=intout^[4];
							appl_xgetinfo:=true
						end
				end
		else
			if paf<>nil then
				if paf^.af_magic='AFnt' then
					appl_xgetinfo:=(paf^.afnt_getinfo(nil,nil,0,0,0,ap_gtype,ap_gout1,ap_gout2,ap_gout3,ap_gout4)<>0)
	end;


function objc_wedit(ob_edtree: PTree; ob_edobject,ob_edchar: integer; var ob_edidx: integer; ob_edkind,ob_edwnd: integer): integer;

	begin
		with AES_pb do
			begin
				control^[0]:=65;
				control^[1]:=5;
				control^[2]:=2;
				control^[3]:=1;
				control^[4]:=0;
				addrin^[0]:=ob_edtree;
				intin^[0]:=ob_edobject;
				intin^[1]:=ob_edchar;
				intin^[2]:=ob_edidx;
				intin^[3]:=ob_edkind;
				intin^[4]:=ob_edwnd
			end;
		_crystal(@AES_pb);
		ob_edidx:=AES_pb.intout^[1];
		objc_wedit:=AES_pb.intout^[0]
	end;


function objc_xedit(ob_edtree: PTree; ob_edobject,ob_edchar: integer; var ob_edidx: integer; ob_edkind: integer; pr: PGRECT): integer;

	begin
		with AES_pb do
			begin
				control^[0]:=46;
				control^[1]:=4;
				control^[2]:=2;
				control^[3]:=2;
				control^[4]:=0;
				addrin^[0]:=ob_edtree;
				addrin^[1]:=pr;
				intin^[0]:=ob_edobject;
				intin^[1]:=ob_edchar;
				intin^[2]:=ob_edidx;
				intin^[3]:=ob_edkind
			end;
		_crystal(@AES_pb);
		ob_edidx:=AES_pb.intout^[1];
		objc_xedit:=AES_pb.intout^[0]
	end;


function HeapFunc(size: longint): integer;

  begin
  	if Application<>nil then Application^.Err:=em_OutOfMemory;
    HeapFunc:=heaperrcode;
    dec(heaperrcode);
    if heaperrcode<1 then heaperrcode:=2
  end;


procedure SigHandler(dummy1,dummy2,sig: pointer);

	begin
		if Application<>nil then Application^.Status:=em_Terminate
	end;


procedure GOExit;

	begin
		ExitProc:=OldExit;
		if appdone and (Application<>nil) then Application^.Done
	end;


begin
	ExitCode:=0;
	Application:=nil;
	appdone:=false;
	agi.ApplSearch:=false;
	profile:=nil;
	upath:=nil;
	paf:=nil;
	has_agi:=false;
	randomize;
	heaperrcode:=2;
	OldExit:=ExitProc;
	ExitProc:=@GOExit;
	HeapError:=@HeapFunc;
	allocmode:=GLOBAL;
	if AppFlag then allocmode:=allocmode or 3;
	slmouse:=IDC_SLICE1;
	fillchar(xselwind,sizeof(xselwind),0);
	freedom:=id_No;
	mhstack:=0;
	mfstack:=0
end.