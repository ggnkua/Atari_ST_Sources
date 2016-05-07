{A skeleton program for a Desk  ACCessory}
{You may change it into whatever you like, by rewriting RedrawWindow}

Program ACCDemo;
{$R-,S-,D-}
{$M 4,1,1,20} {4KByte stack, 1KByte heap, unused, unused}

Uses GemDecl,GemAes,GemVdi,Dos;

Var
  ACCtitle,Title: String[15];
  DeskTop: GRect;
  MyWindow, VdiHandle, appl_id, deskId, LastTime: Integer;
  QuitFlag: Boolean;

Procedure OpenWork;
var
  i, WSysChar,HSysChar,WSysCharBox,HSysCharBox: Integer;
  work_in:  intin_ARRAY;
  work_out: workout_ARRAY;
begin
  for i:=0 to 9 do work_in[i]:=1;
  work_in[10]:=2;
  VdiHandle:=graf_handle(WSysChar, HSysChar, WSysCharBox, HSysCharBox);
  v_opnvwk(work_in, VdiHandle, work_out);
  with DeskTop do begin
    x:=0; y:=0; w:=work_out[0]; h:=work_out[1];
  end;
end;

Procedure OpenWindow;
begin
  if MyWindow = 0 then begin
    with DeskTop do
      MyWindow:=wind_create(NAME+CLOSER+MOVER, 0, 0, w, h);
    if MyWindow <= 0 then Exit;
    wind_set(MyWindow, WF_NAME, HiPtr(Title[1]), LoPtr(Title[1]), 0, 0);
    wind_open(MyWindow, 30, 30, 150, 80);
  end else
    wind_set(MyWindow, WF_TOP,0,0,0,0);
end;

Procedure RedrawWindow(DrawAll: Boolean);
var
  WindowRect,MyArea: GRect;   {Using x,y,w,h system}
  Clip: ARRAY_4;              {Using x1,y1,x2,y2 system}
  S: String[9];
  Year, Month, Day, Hour, Minute, Sec, S100, DayOfWeek: integer;
begin
  if MyWindow = 0 then exit;
  GetDate(Year, Month, Day, DayOfWeek); GetTime(Hour, Minute, Sec, s100);
  if (Sec <> LastTime)  or DrawAll  then
  begin
    LastTime:=Sec;
    Str(Sec:3,S);                      {Make something to write}
    graf_mouse(M_OFF, NIL);            {Hide the cursor while drawing}
    vsf_color(VdiHandle, White);
    vswr_mode(VdiHandle, MD_REPLACE);

    with MyArea do wind_get(MyWindow, WF_WORKXYWH, x, y, w, h);
    with WindowRect do wind_get(MyWindow, WF_FIRSTXYWH, x, y, w, h);

    if intersect(DeskTop, MyArea) then {Stay inside the screen. Updates MyArea!}
      while not EmptyRect(WindowRect) do begin
        if intersect(MyArea, WindowRect) then begin
          MakeXYXY(WindowRect, Clip);
          vs_clip(VdiHandle, 1, Clip);    {Unused, but better safe than sorry!}
          if DrawAll then vr_recfl(VdiHandle, Clip); {Clear whole area}
          with MyArea do
            v_gtext(VdiHandle, x+(w div 2)-20, y+(h div 2), s);
        end;
        with WindowRect do wind_get(MyWindow, WF_NEXTXYWH, x, y, w, h);
      end;
    graf_mouse(M_ON, NIL);
  end
end;

Procedure HandleMsg(Var MsgBuf: array_8);
begin
  case MsgBuf[0] of
  AC_OPEN:    if MsgBuf[4] = deskId then OpenWindow;
  AC_CLOSE:   if MsgBuf[3] = deskId then MyWindow:=0;
  WM_REDRAW:  RedrawWindow(True);
  WM_TOPPED:  wind_set(MyWindow, WF_TOP,0,0,0,0 );
  WM_CLOSED:  begin
                if MsgBuf[3] = MyWindow then begin
                  wind_close(MyWindow); wind_delete(MyWindow); MyWindow:=0;
                end;
                if AppFlag then QuitFlag:=True; { Stop }
              end;
  WM_MOVED,
  WM_SIZED:   if MsgBuf[3] = MyWindow then
                wind_set(MyWindow, WF_CURRXYWH,
                         MsgBuf[4], MsgBuf[5], MsgBuf[6], MsgBuf[7]);
  end;
end;

Procedure EventLoop;
var
  event, mx, my, mbutton, kstate, key, clicks: Integer;
  MsgBuf: array_8;
begin
  event:=evnt_multi(MU_MESAG  or  MU_TIMER or MU_KEYBD,
                    1, $0001, $0001, {clicks, mask, state}
                    0, 0, 0, 0, 0,   {M1 data}
                    0, 0, 0, 0, 0,   {M2 data}
                    MsgBuf,
                    250, 0,     {Timer. HiWord first. LoWord almost always 0}
                    mx, my, mbutton, kstate, key, clicks);
  wind_update(BEG_UPDATE);
  if (event and MU_MESAG) <> 0 then HandleMsg(MsgBuf);
  if (event and MU_TIMER) <> 0 then RedrawWindow(False);
  if AppFlag and ((event and MU_KEYBD) <>0 ) and (key = Ctrl_Q) then
    QuitFlag:=True;
  wind_update(END_UPDATE);
end;

{ Main part of program}
begin
  QuitFlag:=false;
  Title    := ' My first ACC '#0;        { Window title. (C string)}
  ACCtitle := '  My own ACC'#0;          { Menu title.   (C string)}
  appl_id:=appl_init;
  if appl_id <> -1 then begin
    OpenWork;
    if VdiHandle <> 0 then begin
      if AppFlag then begin
        OpenWindow;
        repeat EventLoop until QuitFlag;
      end else begin
        deskId:=menu_register(appl_id,ACCtitle[1]);
        repeat EventLoop until FALSE; {Stay here forever}
      end;
      v_clsvwk(VdiHandle);
    end;
    appl_exit;
  end
end.
