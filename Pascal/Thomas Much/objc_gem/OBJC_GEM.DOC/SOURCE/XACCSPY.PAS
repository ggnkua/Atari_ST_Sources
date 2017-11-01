{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z+}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z+}
{$ENDIF}

program XAccSpy;

uses

	Gem,OTypes,OProcs,OWindows;

type

	TXAccApplication = object(TApplication)
		function GetIconTitle: string; virtual;
		procedure InitMainWindow; virtual;
		procedure IconPaint(Work: GRECT; var PaintInfo: TPaintStruct); virtual;
		function XAccInsert(accID,mID: integer; Msg,Ver: byte; pName: PChar): boolean; virtual;
		procedure XAccExit(OrgID: integer); virtual;
	end;

	PXAccWindow = ^TXAccWindow;
	TXAccWindow = object(TWindow)
		function GetIconTitle: string; virtual;
		procedure Paint(var PaintInfo: TPaintStruct); virtual;
		procedure IconPaint(var PaintInfo: TPaintStruct); virtual;
	end;

var

	XAccApplication: TXAccApplication;


function TXAccApplication.GetIconTitle: string;

	begin
		GetIconTitle:='XACC-SPY'
	end;


procedure TXAccApplication.InitMainWindow;

	begin
		new(PXAccWindow,Init(nil,'ObjectGEM XAcc-Spy (04.02.94) von Thomas Much @ KA2'));
		if (MainWindow=nil) or (ChkError<em_OK) then Status:=em_InvalidMainWindow
	end;


procedure TXAccApplication.IconPaint(Work: GRECT; var PaintInfo: TPaintStruct);
	var dummy,cnt: integer;

	begin
		if XAccList<>nil then cnt:=XAccList^.Count
		else
			cnt:=0;
		vst_point(vdiHandle,8,dummy,dummy,dummy,dummy);
		v_gtext(vdiHandle,Work.X,Work.Y+(Work.H shr 1),'  '+ltoa(cnt)+' APP.');
		vst_height(vdiHandle,SysInfo.SFHeight,dummy,dummy,dummy,dummy)
	end;


function TXAccApplication.XAccInsert(accID,mID: integer; Msg,Ver: byte; pName: PChar): boolean;

	begin
		XAccInsert:=inherited XAccInsert(accID,mID,Msg,Ver,pName);
		MainWindow^.ForceRedraw
	end;


procedure TXAccApplication.XAccExit(OrgID: integer);

	begin
		inherited XAccExit(OrgID);
		MainWindow^.ForceRedraw
	end;


function TXAccWindow.GetIconTitle: string;

	begin
		GetIconTitle:=Application^.GetIconTitle
	end;


procedure TXAccWindow.Paint(var PaintInfo: TPaintStruct);
	var cnt,x,y,q,w,msk: integer;
	    txt,dummy      : string;

	begin
		if Application^.XAccList<>nil then cnt:=Application^.XAccList^.Count
		else
			cnt:=0;
		if cnt=0 then
			begin
				SetSubTitle(' Keine XAcc-Applikation gefunden.');
				exit
			end
		else
			SetSubTitle(' '+ltoa(cnt)+' XAcc-Applikation(en) gefunden.');
		x:=Work.X+Attr.charWidth;
		y:=Work.Y+Attr.boxHeight;
		v_gtext(vdiHandle,x,y,'Name              apID  meID  Ver  Groups  apType + Features + genName');
		inc(y,Attr.boxHeight shl 1);
		for q:=0 to pred(cnt) do
			with PXAccAttr(Application^.XAccList^.At(q))^ do
				begin
					if Name<>nil then txt:=Name^ else txt:='';
					txt:=txt+StrPSpace(16-length(Name^))+'  ';
					dummy:=ltoa(apID);
					txt:=txt+StrPSpace(3-length(dummy))+dummy+'   ';
					dummy:=ltoa(menuID);
					txt:=txt+StrPSpace(3-length(dummy))+dummy+'   ';
					dummy:=ltoa(Version);
					txt:=txt+StrPSpace(3-length(dummy))+dummy+'  ';
					msk:=1;
					dummy:='';
					for w:=0 to 5 do
						begin
							if bTst(MsgGroups,msk) then dummy:=chr(w+49)+dummy
							else
								dummy:='_'+dummy;
						  msk:=msk shl 1
						end;
					txt:=txt+dummy+'  ';
					txt:=txt+AppTypeMR+' ';
					if AppTypeHR<>nil then txt:=txt+AppTypeHR^+'  ';
					if ExtFeatures<>nil then txt:=txt+ExtFeatures^+'  ';
					if GenericName<>nil then txt:=txt+GenericName^;
					v_gtext(vdiHandle,x,y,txt);
					inc(y,Attr.boxHeight)
				end
	end;


procedure TXAccWindow.IconPaint(var PaintInfo: TPaintStruct);

	begin
		Application^.IconPaint(Work,PaintInfo)
	end;


begin
  XAccApplication.Init('XAcc-Spy');
  XAccApplication.Run;
  XAccApplication.Done
end.