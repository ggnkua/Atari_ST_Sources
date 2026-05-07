{Multitasking Copy and Format V1.0 von Jrgen Hollfelder}
{$S20,A+,D-}
program CF;
 {$i cf.i}
 {$i gemconst.pas}
 magic=$87654321;
 virgin=$0000;
type
 {$i gemtype.pas}
 fmtbuf=packed array[0..10000]of byte;
 botbuf=packed array[0..511]of byte;
var
 lw,sk,tr,sp,md,
 sdal,d,apno,al,
 meno,sod,sd,
 rlw,wlw        :integer;
 fil            :long_integer;
 cbuf1          :array [1..10] of botbuf;
 cbuf2          :array [1..10] of botbuf;
 fbuf           :fmtbuf;
 bbuf           :botbuf;
 aname,hstr     :str255;
 hptr           :dialog_ptr;
 mld            :message_buffer;
{$i gemsubs.pas}

function ftr(var b:fmtbuf;f:long_integer;lw,sc,tr,sd,lv:integer;
             mg:long_integer;vg:integer):integer;
xbios(10);

function mbs(var b:botbuf;sn:long_integer;t,e:integer):integer;
xbios(18);

function wr(var b:botbuf;f:long_integer;lw,sc,tr,sd,co:integer):integer;
xbios(9);

function rd(var b:botbuf;f:long_integer;lw,sc,tr,sd,co:integer):integer;
xbios(8);

procedure bootsector;
var
 s:integer;
begin
 al:=mbs(bbuf,0,sd+2,0);
 if tr=79 then
 begin
   if sk=10 then
   begin
     if sd=0 then
     begin
       bbuf[$13]:=$20;
       bbuf[$14]:=$03;
     end
     else
     begin
       bbuf[$13]:=$40;
       bbuf[$14]:=$06;
     end;
   end;
 end;
 if tr=80 then
 begin
   if sk=9 then
   begin
     if sd=0 then
     begin
       bbuf[$13]:=$D9;
       bbuf[$14]:=$02;
     end
     else
     begin
       bbuf[$13]:=$B2;
       bbuf[$14]:=$05;
     end
   end
   else
   begin
     if sd=0 then
     begin
       bbuf[$13]:=$2A;
       bbuf[$14]:=$03;
     end
     else
     begin
       bbuf[$13]:=$54;
       bbuf[$14]:=$06;
     end;
   end;
 end;
 if tr=81 then
 begin
   if sk=9 then
   begin
     if sd=0 then
     begin
       bbuf[$13]:=$e2;
       bbuf[$14]:=$02;
     end
     else
     begin
       bbuf[$13]:=$c4;
       bbuf[$14]:=$05;
     end
   end
   else
   begin
     if sd=0 then
     begin
       bbuf[$13]:=$34;
       bbuf[$14]:=$03;
     end
     else
     begin
       bbuf[$13]:=$68;
       bbuf[$14]:=$06;
     end;
   end;
 end;
 if sk=10 then
 begin
  bbuf[24]:=10;
 end;
 al:=wr(bbuf,fil,lw,1,0,0,1);
 for s:=0 to 511 do bbuf[al]:=0;
 bbuf[0]:=$F7;
 bbuf[1]:=$ff;
 bbuf[2]:=$ff;
 al:=wr(bbuf,fil,lw,2,0,0,1);
 al:=wr(bbuf,fil,lw,7,0,0,1);
end;

procedure hole_event;
begin
 al:=get_event(e_message,0,0,0,0,false,0,0,0,0,false,0,0,0,0,mld,d,d,d,d,d,d);
end;

procedure hole_c_einstellung;
begin
 if obj_state(hptr,cfa)=1 then
  rlw:=0
 else
  rlw:=1;
 if obj_state(hptr,cta)=1 then
  wlw:=0
 else
  wlw:=1;
 if obj_state(hptr,cs9)=1 then
  sk:=9
 else
  sk:=10;
 if obj_state(hptr,ct79)=1 then
  tr:=79
 else
  if obj_state(hptr,ct80)=1 then
   tr:=80
  else
   tr:=81;
 if obj_state(hptr,csp1)=1 then
  sp:=1000
 else
  if obj_state(hptr,csp2)=1 then
   sp:=750
  else
   if obj_state(hptr,csp3)=1 then
    sp:=500
   else
    if obj_state(hptr,csp4)=1 then
     sp:=250
    else
     if obj_state(hptr,csp5)=1 then
      sp:=50
     else
      sp:=5;
 if obj_state(hptr,csingle)=1 then
  sd:=0
 else
  sd:=1;
 if obj_state(hptr,cmyes)=1 then
  md:=1
 else
  md:=0;
end;

procedure hole_f_einstellung;
begin
 if obj_state(hptr,laufa)=1 then
  lw:=0
 else
  lw:=1;
 if obj_state(hptr,s9)=1 then
  sk:=9
 else
  sk:=10;
 if obj_state(hptr,t79)=1 then
  tr:=79
 else
  if obj_state(hptr,t80)=1 then
   tr:=80
  else
   tr:=81;
 if obj_state(hptr,sp1)=1 then
  sp:=2000
 else
  if obj_state(hptr,sp2)=1 then
   sp:=1500
  else
   if obj_state(hptr,sp3)=1 then
    sp:=1000
   else
    if obj_state(hptr,sp4)=1 then
     sp:=750
    else
     if obj_state(hptr,sp5)=1 then
      sp:=500
     else
      sp:=50;
 if obj_state(hptr,single)=1 then
  sd:=0
 else
  sd:=1;
 if obj_state(hptr,myes)=1 then
  md:=1
 else
  md:=0;
end;

procedure zeitevent;
begin
 al:=get_event(e_timer,0,0,0,sp,false,0,0,0,0,false,0,0,0,0,mld,d,d,d,d,d,d);
end;

procedure cnkill;
begin
 write(chr(27),'Y',chr(32),chr(93),'                    ');
end;

procedure cnachricht(t,s,e:integer);
begin
 write(chr(27),'Y',chr(32),chr(93),'Copy:',s:2,'/',t:2,' Err.:',e:3);
end;

procedure nkill;
begin
 write(chr(27),'Y',chr(32),chr(90),'                      ');
end;

procedure nachricht(t,e:integer);
begin
 write(chr(27),'Y',chr(32),chr(90),'Format Tr.:',t:2,' Err.:',e:3);
end;

procedure format;
var
 trn:integer;
begin
 hole_f_einstellung;
 for trn:=0 to tr do
 begin
  zeitevent;
  al:=ftr(fbuf,fil,lw,sk,trn,0,1,magic,virgin);
  if sd=1 then
  begin
   zeitevent;
   al:=ftr(fbuf,fil,lw,sk,trn,1,1,magic,virgin);
  end;
  if md=1 then
   nachricht(trn,al);
 end;
 zeitevent;
 bootsector;
 nkill;
end;

procedure copy;
var
 trn,scn,er:integer;
begin
 hole_c_einstellung;
 for trn:=0 to tr do
 begin
  for scn:=1 to sk do
  begin
   er:=rd(cbuf1[scn],fil,rlw,scn,trn,0,1);
   zeitevent;
   if md=1 then
    cnachricht(trn,scn,er);
   if sd=1 then
   begin
    er:=rd(cbuf2[scn],fil,rlw,scn,trn,1,1);
    zeitevent;
   end;
   if md=1 then
    cnachricht(trn,scn,er);
  end;
  for scn:=1 to sk do
  begin
   er:=wr(cbuf1[scn],fil,wlw,scn,trn,0,1);
   zeitevent;
   if md=1 then
    cnachricht(trn,scn,er);
   if sd=1 then
   begin
    er:=wr(cbuf2[scn],fil,wlw,scn,trn,1,1);
    zeitevent;
   end;
   if md=1 then
    cnachricht(trn,scn,er);
  end;
 end;
 cnkill;
end;

procedure hauptmenu;
begin
 center_dialog(hptr);
 al:=do_dialog(hptr,0);
 end_dialog(hptr);
 obj_setstate(hptr,al,0,false);
 if al=start then
  format;
 if al=cstart then
  copy;
end;

begin
 apno:=init_gem;
 if apno>=0 then
 begin
  if not load_resource('cf.rsc') then
  begin
   al:=do_alert('[3][Where is the Resourcefile|for Copy & Format ?][Where]',1);
   while true do
   begin
    hole_event;
   end;
  end
  else
  begin
   find_dialog(Haupt,hptr);
   aname:='  Format & Copy';
   meno:=menu_register(apno,aname);
   while true do
   begin
    hole_event;
    if mld[0]=ac_open then hauptmenu;
   end;
  end;
 end;
 exit_gem;
end.

