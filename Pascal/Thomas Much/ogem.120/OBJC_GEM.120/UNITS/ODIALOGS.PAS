{**************************************
 *  O b j e c t G E M   Version 1.20  *
 *  Copyright 1992-94 by Thomas Much  *
 **************************************
 *       Unit  O D I A L O G S        *
 **************************************
 *    Softdesign Computer Software    *
 *    Thomas Much, Gerwigstraûe 46,   *
 *  76131 Karlsruhe, (0721) 62 28 41  *
 *         Thomas Much @ KA2          *
 *  UK48@ibm3090.rz.uni-karlsruhe.de  *
 **************************************
 *    erstellt am:        13.07.1992  *
 *    letztes Update am:  27.09.1994  *
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

unit ODialogs;

interface

uses

	Strings,Tos,Gem,OTypes,OWindows;

type

	PScrollBar = ^TScrollBar;
	TScrollBar = object(TControl)
		public
		LineMagnitude,
		PageMagnitude,
		Size         : longint;
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
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure SetCheck(CheckFlag: integer); virtual;
		function GetCheck: integer; virtual;
		procedure Check; virtual;
		procedure Uncheck; virtual;
		procedure Toggle; virtual;
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

	PComboBox    = ^TComboBox;
	TComboBox    = object(TControl)
		public
		Popup: PPopup;
		Edit : PEdit;
		constructor Init(AParent: PDialog; AnIndx,CycleIndx,TitleIndx,ptIndx,popIndx: integer; Cycle,Editable: boolean; Hlp: string);
		destructor Done; virtual;
		function TestIndex(AnIndx: integer): boolean; virtual;
		function Transfer(DataPtr: pointer; TransferFlag: word): word; virtual;
		procedure Changed(AnIndx: integer; DblClick: boolean); virtual;
		procedure Work; virtual;
		procedure SetText(ATextString: string); virtual;
		function GetText: string; virtual;
		procedure Paint; virtual;
		function GetSelection: integer; virtual;
		procedure SetSelection(Sel: integer); virtual;
		function GetEdit: PEdit; virtual;
		private
		cindx,
		tindx,
		pindx,
		tpindx,
		select,
		oldtype,
		oldttype  : integer;
		oldtobspec: longint;
		caddr,
		taddr     : PObj;
		cycl,
		initflag  : boolean;
		usrtblk   : USERBLK
	end;

	PNotepad = ^TNotepad;
	TNotepad = object(TControl)
		public
		constructor Init(AParent: PDialog; AnIndx,PadIndx,AGroup: integer; Hlp: string);
		private
		group,
		pad  : integer;
		paddr: PObj
	end;

	PListBox     = ^TListBox;
	TListBox     = object(TControl)
		{ ... }
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
	UDCOL       = Blue;
	HOTCOL      = Red;


function DrawCycleBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawGroupBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawCheckBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawRadioButton(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;
function DrawComboTitle(dummy1,dummy2: pointer; parm: PARMBLKPtr): word; forward;


{ *** Objekt TSCROLLBAR *** }

constructor TScrollBar.Init(AParent: PDialog; SIndx,DIndx,IIndx: integer; TheSize,TheRange: longint; Hlp: string);

	begin
		if not(inherited Init(AParent,SIndx,Hlp)) then fail;
		Style:=cs_ScrollBar;
		ID:=id_NoExit;
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
	var sp,dif           : longint;
	    mx,my,ox,oy,px,py: integer;
	    less             : boolean;

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

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		Style:=cs_GroupBox or gbs_Recessed;
		Title:=NewStr(ATitle);
		if ((ObjAddr^.ob_type and $ff)=G_BOX) and (Title<>nil) then
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
		else
			begin
				DisposeStr(Title);
				inherited Done;
				fail
			end
	end;


destructor TGroupBox.Done;

	begin
		with ObjAddr^ do
			begin
				ob_spec.index:=oldobspec;
				ob_type:=G_BOX;
				ob_flags:=oldflags
			end;
		DisposeStr(Title);
		inherited Done
	end;


procedure TGroupBox.SetText(ATextString: string);
	var nt: PString;

	begin
		nt:=NewStr(ATextString);
		if nt<>nil then
			begin
				DisposeStr(Title);
				Title:=nt;
				UsrBlk.ub_parm:=longint(Title);
				Paint
			end
	end;


function TGroupBox.GetText: string;

	begin
		if Title<>nil then GetText:=Title^ else GetText:=''
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
				UsrDef:=false;
		Install:=true
	end;


procedure TCheckBox.Deinstall;

	begin
	end;


function TCheckBox.Transfer(DataPtr: pointer; TransferFlag: word): word;

	begin
		case TransferFlag of
			tf_SetData: SetCheck(PWord(DataPtr)^);
			tf_GetData: PWord(DataPtr)^:=GetCheck
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

{ *** TCHECKBOX *** }



{ *** Objekt TTRISTATE *** }

constructor TTriState.Init(AParent: PDialog; AnIndx: integer; Hlp: string);

	begin
		if not(inherited Init(AParent,AnIndx,true,Hlp)) then fail;
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
				UsrDef:=false;
		Install:=true
	end;

{ *** TRADIOBUTTON *** }



{ *** Objekt TCOMBOBOX *** }

constructor TComboBox.Init(AParent: PDialog; AnIndx,CycleIndx,TitleIndx,ptIndx,popIndx: integer; Cycle,Editable: boolean; Hlp: string);
	var ot   : integer;
	    txt  : string;

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		initflag:=true;
		if Editable then Edit:=GetEdit
		else
			Edit:=nil;
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
							if (ot=G_BUTTON) or (ot=G_STRING) or (ot=G_TITLE) then
								begin
									txt:=StrPas(ob_spec.free_string);
									usrtblk.ub_parm:=longint(ob_spec.free_string)
								end
							else
								if (ot=G_TEXT) or (ot=G_FTEXT) or (ot=G_BOXTEXT) or (ot=G_FBOXTEXT) then
									begin
										txt:=StrPas(ob_spec.ted_info^.te_ptext);
										usrtblk.ub_parm:=longint(ob_spec.ted_info^.te_ptext)
									end
								else
									begin
										txt:='';
										usrtblk.ub_parm:=0
									end;
							ot:=pos('&',txt);
							if (ot>0) and (ot<length(txt)) then SetShortCut(txt[ot+1]);
							oldttype:=ob_type;
							oldtobspec:=ob_spec.index;
							usrtblk.ub_code:=@DrawComboTitle;
							ob_spec.user_blk:=@usrtblk;
							ob_type:=G_USERDEF
						end
			end
		else
			taddr:=nil;
		pindx:=popIndx;
		tpindx:=ptIndx;
		cycl:=Cycle;
		EnableTransfer;
		Style:=cs_ComboBox;
		ID:=id_NoExit;
		Popup:=nil;
		select:=id_No;
		if Edit=nil then
			with ObjAddr^ do
				ob_flags:=(ob_flags and not(SELECTABLE or F_EXIT)) or TOUCHEXIT;
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
								ob_spec.index:=(ob_spec.index and $00ffffff) or (longint(ord(Application^.Attr.PopChar)) shl 24)
						end
				end;
		SetSelection(0);
		initflag:=false
	end;


destructor TComboBox.Done;

	begin
		if Popup<>nil then
			with Popup^ do
				begin
					Uncheck(select);
					Free
				end;
		if Edit<>nil then Edit^.Free;
		if taddr<>nil then
			with taddr^ do
				begin
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
				inc(longint(DataPtr),offs)
			end
		else
			offs:=0;
		case TransferFlag of
		tf_SetData:
			SetSelection(PWord(DataPtr)^);
		tf_GetData:
			PWord(DataPtr)^:=GetSelection
		end;
		Transfer:=offs+2
	end;


procedure TComboBox.Changed(AnIndx: integer; DblClick: boolean);
	var res,xof,yof: integer;

	begin
		if AnIndx=cindx then
			begin
				if cycl then
					begin
						if (kbshift(-1) and K_SHIFT)>0 then SetSelection(select-1)
						else
							SetSelection(select+1);
						exit
					end
				else
					if caddr<>nil then
						if not(bTst(caddr^.ob_state,SELECTED)) then exit
			end;
		SetSelection(select);
		if Popup=nil then exit;
		if tindx>0 then
			with Parent^ do
				begin
					DlgTree^[tindx].ob_state:=DlgTree^[tindx].ob_state or SELECTED;
					ObjcPaint(tindx,false)
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
				if AnIndx=ObjIndx then pY:=yof-select*PopTree^[PopTree^[ROOT].ob_head].ob_height
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
		if res>=0 then SetSelection(res);
		if tindx>0 then
			begin
				with Parent^.DlgTree^[tindx] do ob_state:=ob_state and not(SELECTED);
				Paint
			end
	end;


procedure TComboBox.Work;

	begin
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
						StrPCopy(ObjAddr^.ob_spec.ted_info^.te_ptext,ATextString)
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


procedure TComboBox.Paint;

	begin
		if tindx>0 then Parent^.ObjcPaint(tindx,false);
		if Edit<>nil then Edit^.Paint
		else
			inherited Paint;
		if cindx>0 then Parent^.ObjcPaint(cindx,false)
	end;


function TComboBox.GetSelection: integer;

	begin
		GetSelection:=select
	end;


procedure TComboBox.SetSelection(Sel: integer);
	var i,direc: integer;

	begin
		if Popup=nil then
			begin
				new(Popup,Init(Parent,tpindx,pindx));
				if Popup=nil then exit
			end;
		if Sel<0 then
			begin
				Sel:=Popup^.pMax-1;
				direc:=-1;
				i:=Sel
			end
		else
			begin
				direc:=1;
				i:=0
			end;
		if Sel>=Popup^.pMax then sel:=0;
		if Popup^.GetState(Sel)=bf_Disabled then
			begin
				Sel:=id_No;
				while (i>=0) and (i<Popup^.pMax) do
					if Popup^.GetCheck(i)=bf_Disabled then inc(i,direc)
					else
						begin
							Sel:=i;
							break
						end
			end;
		if Sel<>select then
			begin
				Popup^.Uncheck(select);
				select:=Sel;
				Popup^.Check(select);
				SetText(Popup^.GetText(select));
				if not(initflag) then Work
			end
	end;


function TComboBox.GetEdit: PEdit;

	begin
		GetEdit:=new(PEdit,Init(Parent,ObjIndx,-1,GetHelp))
	end;

{ *** TCOMBOBOX *** }



{ *** Objekt TNOTEPAD *** }

constructor TNotepad.Init(AParent: PDialog; AnIndx,PadIndx,AGroup: integer; Hlp: string);

	begin
		if not(inherited Init(AParent,AnIndx,Hlp)) then fail;
		pad:=PadIndx;
		if pad>0 then paddr:=@Parent^.DlgTree^[pad]
		else
			paddr:=nil;
		if paddr=nil then
			begin
				inherited Done;
				fail
			end;
		Style:=cs_Notepad;
		group:=AGroup;
		{ ... }
	end;

{ *** TNOTEPAD *** }



{ *** Objekt TLISTBOX *** }

{ ... }

{ *** TLISTBOX *** }




function DrawCycleBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var clip: ARRAY_4;
	    br  : integer;

	begin
		with parm^ do
			begin
				clip[0]:=pb_xc;
				clip[1]:=pb_yc;
				clip[2]:=pb_xc+pb_wc-1;
				clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,clip);
				clip[0]:=pb_x;
				clip[1]:=pb_y;
				clip[2]:=pb_x+pb_w+1;
				clip[3]:=pb_y+pb_h+2
			end;
		with Application^ do
			begin
				vsf_interior(vdiHandle,FIS_SOLID);
				v_bar(vdiHandle,clip);
				dec(clip[2],3);
				dec(clip[3],3);
				vsf_color(vdiHandle,White);
				v_bar(vdiHandle,clip);
				pxya[0]:=clip[0];
				pxya[1]:=clip[1]-1;
				pxya[2]:=clip[2]+1;
				pxya[3]:=pxya[1];
				pxya[4]:=pxya[2];
				pxya[5]:=clip[3]+1;
				pxya[6]:=pxya[0];
				pxya[7]:=pxya[5];
				v_pline(vdiHandle,4,pxya);
				vsf_color(vdiHandle,LBlack);
				br:=clip[2]-clip[0]-5;
				pxya[0]:=clip[0]+3;
				pxya[1]:=((clip[1]+clip[3]) shr 1)-1;
				pxya[2]:=pxya[0]+(br shr 1);
				pxya[3]:=clip[1]+2;
				pxya[4]:=pxya[0]+br-1;
				pxya[5]:=pxya[1];
				pxya[6]:=pxya[0];
				pxya[7]:=pxya[1];
				v_fillarea(vdiHandle,4,pxya);
				inc(pxya[1],3);
				pxya[3]:=clip[3]-2;
				pxya[5]:=pxya[1];
				pxya[7]:=pxya[1];
				v_fillarea(vdiHandle,4,pxya);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vsf_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawCycleBox:=NORMAL
	end;


function DrawGroupBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var clip: ARRAY_4;

	begin
		with parm^ do
			begin
				clip[0]:=pb_xc;
				clip[1]:=pb_yc;
				clip[2]:=pb_xc+pb_wc-1;
				clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,clip);
				clip[0]:=pb_x;
				clip[1]:=pb_y;
				clip[2]:=pb_x+pb_w-1;
				clip[3]:=pb_y+pb_h-1
			end;
		with Application^ do
			begin
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,SysInfo.BGDefCol);
				v_bar(vdiHandle,clip);
				if (SysInfo.BGDefCol<>White) and (Attr.Colors>=LBlack) and bTst(Attr.Style,as_3DFlags) then
					begin
						{ gbs_Recessed... }
						pxya[0]:=clip[0];
						pxya[1]:=clip[3];
						pxya[2]:=clip[0];
						pxya[3]:=clip[1];
						pxya[4]:=clip[2];
						pxya[5]:=clip[1];
						vsl_color(vdiHandle,LBlack);
						v_pline(vdiHandle,3,pxya);
						pxya[0]:=clip[0]+1;
						pxya[1]:=clip[3];
						pxya[2]:=clip[2];
						pxya[3]:=clip[3];
						pxya[4]:=clip[2];
						pxya[5]:=clip[1]+1;
						vsl_color(vdiHandle,White);
						v_pline(vdiHandle,3,pxya);
						vsf_interior(vdiHandle,FIS_HOLLOW);
						vsf_color(vdiHandle,Black)
					end
				else
					begin
						vsf_interior(vdiHandle,FIS_HOLLOW);
						vsf_color(vdiHandle,Black);
						vswr_mode(vdiHandle,MD_TRANS);
						v_bar(vdiHandle,clip)
					end;
				if length(PString(parm^.pb_parm)^)>0 then
					begin
						vswr_mode(vdiHandle,MD_ERASE);
						vst_color(vdiHandle,SysInfo.BGDefCol);
						v_gtext(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.SFHeight shr 1),' '+PString(parm^.pb_parm)^+' ');
						vswr_mode(vdiHandle,MD_TRANS);
						v_gtext(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.SFHeight shr 1),' '+PString(parm^.pb_parm)^+' ');
						vst_color(vdiHandle,Black);
						v_gtext(vdiHandle,parm^.pb_x+Attr.charSWidth,parm^.pb_y+(SysInfo.SFHeight shr 1),' '+PString(parm^.pb_parm)^+' ')
					end;
				vsl_color(vdiHandle,Black);
				vswr_mode(vdiHandle,MD_REPLACE);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawGroupBox:=NORMAL
	end;


function DrawCheckBox(dummy1,dummy2: pointer; parm: PARMBLKPtr): word;
	var clip            : ARRAY_4;
	    tx,ty,scpos,stat: integer;
	    q               : word;
	    btn             : string[40];

	begin
		with parm^ do
			begin
				clip[0]:=pb_xc;
				clip[1]:=pb_yc;
				clip[2]:=pb_xc+pb_wc-1;
				clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,clip);
				clip[0]:=pb_x+1;
				clip[1]:=pb_y+1;
				clip[2]:=clip[0]+13;
				clip[3]:=clip[1]+13;
				case (pb_tree^[pb_obj].ob_type and cbFlags) of
					cbChecked:   stat:=bf_Checked;
					cbGrayed:    stat:=bf_Grayed
				else
					stat:=bf_Unchecked
				end;
				if pr_currstate<>pr_prevstate then
					begin
						inc(stat);
						if bTst(pb_tree^[pb_obj].ob_type,cbType) then q:=3 else q:=2;
						if stat>q then stat:=1;
						case stat of
							bf_Checked:   q:=cbChecked;
							bf_Grayed:    q:=cbGrayed
						else
							q:=cbUnchecked
						end;
						pb_tree^[pb_obj].ob_type:=(pb_tree^[pb_obj].ob_type and not(cbFlags)) or q
					end;
				if (stat<>bf_Unchecked) or bTst(pr_currstate,CROSSED) then for q:=0 to 3 do inc(clip[q])
			end;
		with Application^ do
			begin
				if stat=bf_Grayed then
					begin
						if Attr.Colors>=LWhite then
							begin
								vsf_interior(vdiHandle,FIS_SOLID);
								vsf_color(vdiHandle,LWhite)
							end
						else
							begin
								vsf_interior(vdiHandle,FIS_PATTERN);
								vsf_style(vdiHandle,1)
							end
					end;
				v_bar(vdiHandle,clip);
				if stat<>bf_Unchecked then
					begin
						pxya[0]:=clip[0]-1;
						pxya[1]:=clip[3]-1;
						pxya[2]:=clip[0]-1;
						pxya[3]:=clip[1]-1;
						pxya[4]:=clip[2]-1;
						pxya[5]:=clip[1]-1;
						vsl_color(vdiHandle,SysInfo.BGDefCol);
						v_pline(vdiHandle,3,pxya);
						if stat=bf_Checked then
							begin
								vsl_color(vdiHandle,LBlack);
								if bTst(parm^.pr_currstate,CROSSED) then
									begin
										pxya[0]:=clip[0]+1;
										pxya[1]:=clip[1]+1;
										pxya[2]:=clip[2]-1;
										pxya[3]:=clip[3]-1;
										v_pline(vdiHandle,2,pxya);
										pxya[0]:=clip[0]+1;
										pxya[1]:=clip[3]-1;
										pxya[2]:=clip[2]-1;
										pxya[3]:=clip[1]+1;
										v_pline(vdiHandle,2,pxya)
									end
								else
									begin
										pxya[0]:=clip[0]+1;
										pxya[1]:=clip[3]-1;
										pxya[2]:=clip[0]+1;
										pxya[3]:=clip[1]+1;
										pxya[4]:=clip[2]-1;
										pxya[5]:=clip[1]+1;
										v_pline(vdiHandle,3,pxya);
										vsf_interior(vdiHandle,FIS_SOLID);
										vsf_color(vdiHandle,UDCOL);
										vsl_color(vdiHandle,UDCOL);
										if bTst(parm^.pr_currstate,DISABLED) then
											if Attr.Colors>=LWhite then
												begin
													vsf_color(vdiHandle,LWhite);
													vsl_color(vdiHandle,LWhite)
												end;
										pxya[0]:=clip[0]+5;
										pxya[1]:=clip[1]+7;
										pxya[2]:=clip[0]+4;
										pxya[3]:=clip[1]+8;
										pxya[4]:=clip[0]+4;
										pxya[5]:=clip[1]+11;
										pxya[6]:=clip[0]+5;
										pxya[7]:=clip[1]+11;
										pxya[8]:=clip[0]+11;
										pxya[9]:=clip[1]+5;
										pxya[10]:=clip[0]+10;
										pxya[11]:=clip[1]+5;
										pxya[12]:=clip[0]+5;
										pxya[13]:=clip[1]+10;
										pxya[14]:=clip[0]+5;
										pxya[15]:=clip[1]+7;
										v_fillarea(vdiHandle,8,pxya)
									end
							end
						else
							if Attr.Colors>=LWhite then
								begin
									pxya[0]:=clip[0];
									pxya[1]:=clip[1];
									pxya[2]:=clip[2];
									pxya[3]:=clip[1];
									pxya[4]:=clip[2];
									pxya[5]:=clip[3];
									pxya[6]:=clip[0];
									pxya[7]:=clip[3];
									pxya[8]:=clip[0];
									pxya[9]:=clip[1];
									vsl_color(vdiHandle,Black);
									v_pline(vdiHandle,5,pxya)
								end
					end
				else
					if not(bTst(parm^.pr_currstate,CROSSED)) then
						begin
							pxya[0]:=clip[0]+1;
							pxya[1]:=clip[3]+1;
							pxya[2]:=clip[2]+1;
							pxya[3]:=clip[3]+1;
							pxya[4]:=clip[2]+1;
							pxya[5]:=clip[1]+1;
							vsl_color(vdiHandle,LBlack);
							v_pline(vdiHandle,3,pxya)
						end;
				tx:=parm^.pb_x+14+Attr.charSWidth;
				ty:=parm^.pb_y+SysInfo.SFHeight+1;
				btn:=StrLPas(PChar(parm^.pb_parm),40);
				while btn[length(btn)]=' ' do btn[0]:=chr(ord(btn[0])-1);
				scpos:=pos('&',btn);
				if scpos>0 then
					begin
						for q:=scpos to length(btn)-1 do btn[q]:=btn[q+1];
						btn[0]:=chr(ord(btn[0])-1)
					end;
				vswr_mode(vdiHandle,MD_ERASE);
				vst_color(vdiHandle,SysInfo.BGDefCol);
				v_gtext(vdiHandle,tx,ty,btn);
				vswr_mode(vdiHandle,MD_TRANS);
				v_gtext(vdiHandle,tx,ty,btn);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				vst_color(vdiHandle,Black);
				v_gtext(vdiHandle,tx,ty,btn);
				if scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_UNDERLINED or TF_LIGHTENED)
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdiHandle,HOTCOL)
							end;
						v_gtext(vdiHandle,tx+(scpos-1)*Attr.charSWidth,ty,' ')
					end;
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
	var clip            : ARRAY_4;
	    stat,tx,ty,scpos: integer;
	    q               : word;
	    btn             : string[40];

	begin
		with parm^ do
			begin
				clip[0]:=pb_xc;
				clip[1]:=pb_yc;
				clip[2]:=pb_xc+pb_wc-1;
				clip[3]:=pb_yc+pb_hc-1;
				if (pb_tree^[pb_obj].ob_type and cbFlags)=cbChecked then stat:=bf_Checked
				else
					stat:=bf_Unchecked;
				if pr_currstate<>pr_prevstate then
					begin
						stat:=stat xor 3;
						if stat=bf_Checked then q:=cbChecked
						else
							q:=cbUnchecked;
						pb_tree^[pb_obj].ob_type:=(pb_tree^[pb_obj].ob_type and not(cbFlags)) or q
					end;
				vs_clip(Application^.vdiHandle,CLIP_ON,clip);
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
		if stat=bf_Checked then for q:=0 to 4 do inc(pxya[q shl 1]);
		with Application^ do
			begin
				v_fillarea(vdiHandle,5,pxya);
				if stat=bf_Checked then
					begin
						pxya[0]:=parm^.pb_x+8;
						pxya[1]:=parm^.pb_y+1;
						pxya[2]:=parm^.pb_x+1;
						pxya[3]:=parm^.pb_y+8;
						pxya[4]:=parm^.pb_x+8;
						pxya[5]:=parm^.pb_y+15;
						vsl_color(vdiHandle,SysInfo.BGDefCol);
						v_pline(vdiHandle,3,pxya);
						pxya[0]:=parm^.pb_x+9;
						pxya[1]:=parm^.pb_y+2;
						pxya[2]:=parm^.pb_x+3;
						pxya[3]:=parm^.pb_y+8;
						pxya[4]:=parm^.pb_x+9;
						pxya[5]:=parm^.pb_y+14;
						vsl_color(vdiHandle,LBlack);
						v_pline(vdiHandle,3,pxya);
						vsf_interior(vdiHandle,FIS_SOLID);
						vsf_color(vdiHandle,UDCOL);
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
						v_fillarea(vdiHandle,5,pxya)
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
						v_pline(vdiHandle,3,pxya)
					end;
				tx:=parm^.pb_x+14+Attr.charSWidth;
				ty:=parm^.pb_y+SysInfo.SFHeight+1;
				btn:=StrLPas(PChar(parm^.pb_parm),40);
				while btn[length(btn)]=' ' do btn[0]:=chr(ord(btn[0])-1);
				scpos:=pos('&',btn);
				if scpos>0 then
					begin
						for q:=scpos to length(btn)-1 do btn[q]:=btn[q+1];
						btn[0]:=chr(ord(btn[0])-1)
					end;
				vswr_mode(vdiHandle,MD_ERASE);
				vst_color(vdiHandle,SysInfo.BGDefCol);
				v_gtext(vdiHandle,tx,ty,btn);
				vswr_mode(vdiHandle,MD_TRANS);
				v_gtext(vdiHandle,tx,ty,btn);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				vst_color(vdiHandle,Black);
				v_gtext(vdiHandle,tx,ty,btn);
				if scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_UNDERLINED or TF_LIGHTENED)
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdiHandle,HOTCOL)
							end;
						v_gtext(vdiHandle,tx+(scpos-1)*Attr.charSWidth,ty,' ')
					end;
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
	var clip         : ARRAY_4;
	    btn          : string[40];
	    tx,ty,scpos,q: integer;

	begin
		with parm^ do
			begin
				clip[0]:=pb_xc;
				clip[1]:=pb_yc;
				clip[2]:=pb_xc+pb_wc-1;
				clip[3]:=pb_yc+pb_hc-1;
				vs_clip(Application^.vdiHandle,CLIP_ON,clip);
				clip[0]:=pb_x;
				clip[1]:=pb_y;
				clip[2]:=pb_x+pb_w-1;
				clip[3]:=pb_y+pb_h-1
			end;
		with Application^ do
			begin
				tx:=parm^.pb_x+1;
				ty:=parm^.pb_y+SysInfo.SFHeight;
				btn:=StrLPas(PChar(parm^.pb_parm),40);
				while btn[length(btn)]=' ' do btn[0]:=chr(ord(btn[0])-1);
				scpos:=pos('&',btn);
				if scpos>0 then
					begin
						for q:=scpos to length(btn)-1 do btn[q]:=btn[q+1];
						btn[0]:=chr(ord(btn[0])-1)
					end;
				vsf_perimeter(vdiHandle,PER_OFF);
				vsf_interior(vdiHandle,FIS_SOLID);
				vsf_color(vdiHandle,SysInfo.BGDefCol);
				v_bar(vdiHandle,clip);
				vswr_mode(vdiHandle,MD_TRANS);
				if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_LIGHTENED);
				vst_color(vdiHandle,Black);
				v_gtext(vdiHandle,tx,ty,btn);
				if scpos>0 then
					begin
						if bTst(parm^.pr_currstate,DISABLED) then vst_effects(vdiHandle,TF_UNDERLINED or TF_LIGHTENED)
						else
							begin
								vst_effects(vdiHandle,TF_UNDERLINED);
								vst_color(vdiHandle,HOTCOL)
							end;
						v_gtext(vdiHandle,tx+(scpos-1)*Attr.charSWidth,ty,' ')
					end;
				vsf_color(vdiHandle,Black);
				if bTst(parm^.pr_currstate,SELECTED) then
					begin
						vswr_mode(vdiHandle,MD_XOR);
						v_bar(vdiHandle,clip)
					end;
				vsf_perimeter(vdiHandle,PER_ON);
				vsf_interior(vdiHandle,FIS_HOLLOW);
				vswr_mode(vdiHandle,MD_REPLACE);
				vst_effects(vdiHandle,TF_NORMAL);
				vst_color(vdiHandle,Black);
				vs_clip(vdiHandle,CLIP_ON,SysInfo.Desktop.A2)
			end;
		DrawComboTitle:=NORMAL
	end;

end.