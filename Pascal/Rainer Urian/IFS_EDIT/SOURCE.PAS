{* IFS-Editor Version 1.0 (Public Domain) *}
{* geschrieben in CCD-Pascal+ von Rainer Urian und Michael Herrmann *}

program ifs_edit;

const
{$I gemconst.pas}

type arr115 = array[0..11,0..5] of real;
     matrix = array[0..2, 0..2] of real;
{$I gemtype.pas}
     arr511 = array[0..5,0..11] of str255;

var ifscodes,pntcodes : arr115;
    ifsp              : array[0..11] of real;
    s_d,s_k           : arr511;
    ifsmax,pntmax,
    xscale,yscale,
    xoffset,yoffset,
    window,ymax,ytop,
    rec,iter,dummy    : integer;
    menu              : menu_ptr;
    menu_da,w_closed,
    logo_da,ende_da,
    res               : boolean;
    titel             : window_title;
    txt               : str255;

{$I gemsubs.pas}

function get_res:integer;
  xbios(4);

function random:real;
  function randy:char;
    xbios(17);
  begin
    random:=abs(ord(randy)/32777)
  end;

procedure str(z:real;format:integer;var st:str255);
  var i,le : integer;
      zi,j : long_integer;
      vz   : string[1];
  begin
    if format=0 then
      begin
        z:=z*1000;
        if z<0 then vz:='-' else vz:='+'
      end
    else vz:='';
    zi:=trunc(abs(z));
    j:=1;
    le:=0;
    repeat
      le:=le+1;
      j:=j*10;
    until j>zi;
    st:='';
    for i:=1 to le do
      begin
        j:=j div 10;
        st:=concat(st,chr(48+ zi div j));
        if j>0 then zi:=zi-zi div j * j
      end;
    if format=0 then
      begin
        while length(st)<4 do st:=concat('0',st);
        format:=6
      end;
    while length(st)<format do st:=concat(' ',st);
    st:=concat(vz,st)
  end;

function val(st:string):real;
  var zahl           : real;
      i,komma,faktor : integer;
  function pot10(expo:integer):real;
    var i : integer;
        h : real;
    begin
      h:=1;
      if expo>0 then
        for i:=1 to expo do h:=h*10
      else
        if expo<0 then
          for i:=-1 downto expo do h:=h/10;
      pot10:=h
    end;
  begin
    faktor:=1;
    if st[1]='-' then begin faktor:=-1; delete(st,1,1) end;
    if st[1]='+' then delete(st,1,1);
    while pos(' ',st)>0 do delete(st,pos(' ',st),1);
    komma:=pos('.',st);
    if komma<1 then komma:=length(st)+1;
    if komma=1 then begin komma:=2; st:=concat('0',st) end;
    zahl:=0;
    for i:=1 to komma-1 do
      zahl:=zahl+pot10(komma-i-1)*(ord(st[i])-48);
    if komma<length(st) then
      for i:=komma+1 to length(st) do
        zahl:=zahl+pot10(komma-i)*(ord(st[i])-48);
    val:=zahl*faktor
  end;

procedure fenster_zu;
  begin
    if not w_closed then
      begin
        close_window(window);
        w_closed:=true;
      end
  end;

procedure clear_window;
  var xw,yw,ww,hw : integer;
  begin
    hide_mouse;
    if w_closed then
      begin
        open_window(window,0,0,0,0);
        w_closed:=false
      end;
    work_rect(window,xw,yw,ww,hw);
    set_clip(xw,yw,ww,hw);
    begin_update;
    paint_style(solid);
    paint_color(white);
    paint_rect(xw,yw,ww,hw);
    end_update;
    show_mouse;
    if res then paint_color(red) else paint_color(black);
    set_mouse(m_point_hand)
  end;

function ifsdet(t:integer):real;
  var d : real;
      i : integer;
  begin
    d:=abs(ifscodes[t,0]*ifscodes[t,3] - ifscodes[t,1]*ifscodes[t,2]);
    if d=0 then d:=0.01;
    ifsdet:=d
  end;

function calcprob:boolean;
  var i      : integer;
      sum,pc : real;
       p     : array[0..11] of real;
  begin
    sum:=0;
    for i:=0 to (ifsmax div 6)-1 do sum:=sum+ifsdet(i);
    pc:=0;
    for i:=0 to (ifsmax div 6)-1 do
      begin
        p[i]:=ifsdet(i)/sum;
        pc:=pc+p[i];
        ifsp[i]:=pc
      end;
    calcprob:=true;
    if ifsmax div 6 > 1 then
      for i:=0 to (ifsmax div 6)-2 do
        if abs(p[i]-p[i+1])>0.01 then calcprob:=false
  end;

procedure tab(ifs:boolean;var codes:arr115;var s:arr511;var max:integer);
  var dia                  : dialog_ptr;
      s_h,s_no,s_tit,s_tab : str255;
      s1,s2,s3             : string[3];
      i_nr                 : array[0..11] of integer;
      i_d                  : array[0..5,0..11] of integer;
      i_txt,i_box,i_kopf,
      ok_btn,cancel_btn,
      button,i,j           : integer;
      sum                  : real;
  begin
    fenster_zu;
    if ifs then
      begin
        s_no:=' 1 2 3 4 5 6 7 8 9101112';
        s_tit:='Eingabe der IFS-Koeffizienten';
        s_tab:='T_  ___a____  ___b____  ___c____  ___d____  ___e____  ___f____'
      end
    else
      begin
        s_no:=' 0 1 2 3 4 5 6 7 8 91011';
        s_tit:=' Eingabe der Punkte-Trippel';
        s_tab:='Nr. ___X1___  ___Y1___  ___X2___  ___Y2___  ___X3___  ___Y3___'
      end;
    dia:=new_dialog(90, 0,0,66,20);
    i_box:=add_ditem(dia,g_box,none,1,2,64,15, 2,$1180);
    i_kopf:=add_ditem(dia,g_string,none,19,1,0,0,0,0);
    set_dtext(dia,i_kopf,s_tit,system_font,TE_Left);
    i_txt:=add_ditem(dia,g_string,none,2,3,0,0,0,0);
    set_dtext(dia,i_txt,s_tab,system_font,TE_left);
    for j:=0 to 11 do
      begin
        i_nr[j]:=add_ditem(dia,g_string,none,2,4+j,2,1,0,0);
        s_h:=copy(s_no,1+j*2,2);
        set_dtext(dia,i_nr[j],s_h,system_font,te_left);
      end;
    for j:=0 to 11 do
      for i:=0 to 5 do
        begin
          i_d[i,j]:=add_ditem(dia,G_Ftext,none,6+i*10,4+j,8,1,0,$1180);
          set_dedit(dia,i_d[i,j],'____.___','X999999',s[i,j],
                    system_font,Te_center)
        end;
    ok_btn:=add_ditem(dia,G_Button,Selectable|Exit_Btn|Default,
                      2,18,30,1,2,$1180);
    cancel_btn:=add_ditem(dia,G_button,selectable|Exit_btn,
                      33,18,30,1,2,$1180);
    set_dtext(dia,ok_btn,'Okay',system_font,Te_center);
    set_dtext(dia,cancel_btn,'Abbruch',system_font,Te_center);
    center_dialog(dia);
    button:=do_dialog(dia,i_d[0,0]);
    end_dialog(dia);
    delete_dialog(dia);
    if button=ok_btn then
      begin
        max:=-1;
        for j:=0 to 11 do
          begin
            sum:=0;
            for i:=0 to 5 do
              begin
                get_dedit(dia,i_d[i,j],s[i,j]);
                s3:='+';
                if s[i,j][1]='-' then s3:='-';
                delete(s[i,j],1,1);
                if length(s[i,j])=0 then s[i,j]:='  0000';
                if length(s[i,j])=1 then s[i,j]:=concat(' ',s[i,j]);
                if length(s[i,j])=2 then s[i,j]:=concat(' ',s[i,j]);
                while length(s[i,j])<6 do s[i,j]:=concat(s[i,j],' ');
                if s[i,j][2]=' ' then
                  begin
                    delete(s[i,j],2,1);
                    s[i,j]:=concat(' ',s[i,j])
                  end;
                if s[i,j][3]=' ' then
                  begin
                    delete(s[i,j],3,1);
                    s[i,j]:=concat(' ',s[i,j])
                  end;
                s1:=copy(s[i,j],1,3);
                s2:=copy(s[i,j],4,3);
                codes[j,i]:=val(concat(s3,s1,'.',s2));
                sum:=sum+abs(codes[j,i]);
                s[i,j]:=concat(s3,s[i,j])
              end;
            if (sum=0) and (max=-1) then max:=j*6
          end
      end
  end;

procedure editifs;
  begin
    tab(true,ifscodes,s_d,ifsmax);
  end;

procedure editpnt;
  begin
    tab(false,pntcodes,s_k,pntmax);
  end;

function det(m:matrix):real;
  begin
    det:= m[0,0] * m[1,1] * m[2,2] + m[0,1] * m[1,2] * m[2,0] +
          m[0,2] * m[1,0] * m[2,1] - m[2,0] * m[1,1] * m[0,2] -
          m[2,1] * m[1,2] * m[0,0] - m[2,2] * m[1,0] * m[0,1]
  end;

procedure setmat(var m:matrix);
  var i : integer;
  begin
    for i:=0 to 2 do
      begin
        m[0,i]:=pntcodes[0,i*2];
        m[1,i]:=pntcodes[0,i*2+1];
        m[2,i]:=1
      end
  end;

function solve(t,c,xy:integer;d:real):real;
  var m : matrix;
      i : integer;
  begin
    setmat(m);
    for i:=0 to 2 do m[c,i]:=pntcodes[t+1,i*2+xy];
    solve:=det(m)/d
  end;

procedure transform;
  var c,t : integer;
      d   : real;
      m   : matrix;
   begin
     setmat(m);
     d:=det(m);
     ifsmax:=pntmax-6;
     for t:=0 to (ifsmax div 6) do
       begin
         ifscodes[t,0]:=solve(t,0,0,d);
         str(ifscodes[t,0],0,s_d[0,t]);
         ifscodes[t,1]:=solve(t,1,0,d);
         str(ifscodes[t,1],0,s_d[1,t]);
         ifscodes[t,2]:=solve(t,0,1,d);
         str(ifscodes[t,2],0,s_d[2,t]);
         ifscodes[t,3]:=solve(t,1,1,d);
         str(ifscodes[t,3],0,s_d[3,t]);
         ifscodes[t,4]:=solve(t,2,0,d);
         str(ifscodes[t,4],0,s_d[4,t]);
         ifscodes[t,5]:=solve(t,2,1,d);
         str(ifscodes[t,5],0,s_d[5,t])
       end
  end;

procedure iterate(var x,y:real);
  var rnd,
      newx,newy : real;
      i         : integer;
  begin
    rnd:=random;
    i:=-1;
    repeat
      i:=i+1;
    until rnd<ifsp[i];
    newx:= ifscodes[i,0]*x + ifscodes[i,1]*y + ifscodes[i,4];
    newy:= ifscodes[i,2]*x + ifscodes[i,3]*y + ifscodes[i,5];
    x:=newx;
    y:=newy
  end;

procedure iterdraw;
  var i,j,dummy,
      i_ite,ok_btn,ext_btn   : integer;
      r,x,y                  : real;
      dia                    : dialog_ptr;
      s_ite                  : str255;
  begin
    dia:=new_dialog(4,0,0,25,5);
    i_ite:=add_ditem(dia,G_Ftext,none,4,1,18,1, 0,$1180);
    ok_btn:=add_ditem(dia,G_Button,Selectable|Exit_Btn|Default,
                      2,3,10,1,2,$1180);
    ext_btn:=add_ditem(dia,G_Button,Selectable|Exit_btn,
                       13,3,10,1,2,$1180);
    str(iter,5,s_ite);
    set_dedit(dia,i_ite,'Iterationen: _____','99999',s_ite,
              system_font,TE_Left);
    set_dtext(dia,ok_btn,'Okay ',System_font,TE_Center);
    set_dtext(dia,ext_btn,'Abbruch',System_font,TE_Center);
    center_dialog(dia);
    if (do_dialog(dia,i_ite)=ok_btn) then
      begin
        get_dedit(dia,i_ite,s_ite);
        iter:=trunc(val(s_ite))
      end;
    end_dialog(dia);
    delete_dialog(dia);
    clear_window;
    x:=0;
    y:=0;
    for i:=0 to 20 do iterate(x,y);
    hide_mouse;
    for i:=0 to iter do
      begin
        iterate(x,y);
        plot(trunc(x*xscale+xoffset),ymax-trunc(y*yscale+yoffset))
      end;
    show_mouse
  end;

procedure recurs(i:integer;x,y:real);
  var newx,newy  : real;
      j          : integer;
  begin
    if i>0 then
      begin
        for j:=0 to ifsmax div 6 do
          begin
            newx:= ifscodes[j,0]*x + ifscodes[j,1]*y + ifscodes[j,4];
            newy:= ifscodes[j,2]*x + ifscodes[j,3]*y + ifscodes[j,5];
            plot(trunc(newx*xscale+xoffset),ymax-trunc(newy*yscale+yoffset));
            recurs(i-1,newx,newy)
          end
      end
  end;

procedure recdraw;
  var i,dummy,
      i_rek,ok_btn,ext_btn : integer;
      x,y                  : real;
      dia                  : dialog_ptr;
      s_rek                : str255;
  begin
    x:=0;
    y:=0;
    dia:=new_dialog(4,0,0,25,5);
    i_rek:=add_ditem(dia,G_Ftext,none,6,1,16,1, 0,$1180);
    ok_btn:=add_ditem(dia,G_Button,Selectable|Exit_Btn|Default,
                      2,3,10,1, 2,$1180);
    ext_btn:=add_ditem(dia,G_Button,Selectable|Exit_btn,
                      13,3,10,1,2,$1180);
    str(rec,2,s_rek);
    set_dedit(dia,i_rek,'Rekursionen: __','99',s_rek,system_font,TE_Left);
    set_dtext(dia,ok_btn,'Okay ',System_font,TE_Center);
    set_dtext(dia,ext_btn,'Abbruch',System_font,TE_Center);
    center_dialog(dia);
    if (do_dialog(dia,i_rek)=ok_btn) then
      begin
        get_dedit(dia,i_rek,s_rek);
        if s_rek<>'' then rec:=trunc(val(s_rek))
      end;
    end_dialog(dia);
    delete_dialog(dia);
    clear_window;
    for i:=0 to 20 do iterate(x,y);
    hide_mouse;
    recurs(rec,x,y);
    show_mouse;
  end;

procedure drawifs;
  var dia                     : dialog_ptr;
      s_xos,s_yos,s_xsc,s_ysc : str255;
      i_xos,i_yos,i_xsc,i_ysc ,
      button,rek_btn,ite_btn  ,
      i_txt,i_box             : integer;
  begin
    fenster_zu;
    dia:=new_dialog(9,0,0,30,11);
    i_txt:=add_ditem(dia,G_string,none,7,1,24,1,0,0);
    set_dtext(dia,i_txt,'Zeichenparameter',System_font,Te_left);
    i_box:=add_ditem(dia,G_Ibox, none,2,3,26,4, 1,$1180);
    i_xos:=add_ditem(dia,G_ftext,none,3,4,12,1, 0,$1180);
    i_yos:=add_ditem(dia,G_ftext,none,3,5,12,1, 0,$1180);
    i_xsc:=add_ditem(dia,G_ftext,none,16,4,12,1,0,$1180);
    i_ysc:=add_ditem(dia,G_ftext,none,16,5,12,1,0,$1180);
    rek_btn:=add_ditem(dia,G_Button,Selectable|Exit_btn|Outlined,
                       4,8,10,2, 2,$1180);
    ite_btn:=add_ditem(dia,G_button,Selectable|Exit_btn|Outlined,
                       16,8,10,2, 2,$1180);
    str(xoffset,3,s_xos);
    str(yoffset,3,s_yos);
    str(xscale,3,s_xsc);
    str(yscale,3,s_ysc);
    set_dedit(dia,i_xos,'x-Offset:___','999',s_xos,System_font,Te_left);
    set_dedit(dia,i_yos,'y-Offset:___','999',s_yos,System_font,Te_left);
    set_dedit(dia,i_xsc,'x-Scale:___' ,'999',s_xsc,System_font,Te_left);
    set_dedit(dia,i_ysc,'y-Scale:___' ,'999',s_ysc,System_font,Te_left);
    set_dtext(dia,rek_btn,'rekursiv',System_font,Te_center);
    set_dtext(dia,ite_btn,'iterativ',System_font,Te_center);
    obj_setstate(dia,i_box,Shadowed,false);
    center_dialog(dia);
    if calcprob then obj_setstate(dia,rek_btn,Normal,false)
                else obj_setstate(dia,rek_btn,Disabled,false);
    button:=do_dialog(dia,i_xos);
    get_dedit(dia,i_xos,s_xos); xoffset:=trunc(val(s_xos));
    get_dedit(dia,i_yos,s_yos); yoffset:=trunc(val(s_yos));
    get_dedit(dia,i_xsc,s_xsc); xscale :=trunc(val(s_xsc));
    get_dedit(dia,i_ysc,s_ysc); yscale :=trunc(val(s_ysc));
    obj_setstate(dia,button,0,true);
    end_dialog(dia);
    delete_dialog(dia);
    if res then paint_color(red)
           else paint_color(black);
    if button=ite_btn then iterdraw
                      else recdraw;
    set_clip(0,0,719,ymax)
  end;

procedure def_frak(welchen:integer);
  begin
    case welchen of
      1: begin
           titel:='   Die Sierspinsky-Pfeilspitze   ';
           xoffset:=20; yoffset:=25; xscale:=300; yscale:=320;
           iter:=7500; rec:=7;
           s_d[0,0]:='+  0500'; s_d[3,0]:=s_d[0,0]; s_d[0,1]:=s_d[0,0];
           s_d[3,1]:=s_d[0,0];  s_d[0,2]:=s_d[0,0]; s_d[3,2]:=s_d[0,0];
           s_d[4,2]:=s_d[0,0];  s_d[5,2]:=s_d[0,0]; s_d[4,1]:='+  1000'
         end;
      2: begin
           titel:='   Die DrachenflÑche   ';
           xoffset:=470; yoffset:=115; xscale:=320; yscale:=135;
           iter:=9000; rec:=10;
           s_d[0,0]:='+  0500'; s_d[2,0]:=s_d[0,0]; s_d[3,0]:=s_d[0,0];
           s_d[0,1]:=s_d[0,0];  s_d[2,1]:=s_d[0,0]; s_d[3,1]:=s_d[0,0];
           s_d[1,0]:='-  0500'; s_d[1,1]:=s_d[1,0]; s_d[5,1]:='+  1000'
         end;
      3: begin
           titel:='   Eine Schneeflocke   ';
           xoffset:=35; yoffset:=100; xscale:=95; yscale:=80;
           iter:=9000; rec:=5;
           s_d[0,0]:='+  0333'; s_d[3,0]:=s_d[0,0];  s_d[0,1]:=s_d[0,0];
           s_d[3,1]:=s_d[0,0];  s_d[0,4]:=s_d[0,0];  s_d[3,4]:=s_d[0,0];
           s_d[0,5]:='-  0333'; s_d[3,5]:=s_d[0,5];  s_d[0,2]:='+  0167';
           s_d[2,2]:=s_d[0,2];  s_d[3,2]:=s_d[0,2];  s_d[0,3]:=s_d[0,2];
           s_d[3,3]:=s_d[0,2];  s_d[2,3]:='-  0167'; s_d[1,2]:='-  0500';
           s_d[1,3]:='+  0500'; s_d[4,2]:='+  1000'; s_d[5,2]:=s_d[4,2];
           s_d[4,4]:='+  2000'; s_d[5,4]:=s_d[4,4];  s_d[5,3]:=s_d[4,4];
           s_d[4,1]:='+  4000'; s_d[4,3]:=s_d[4,1];  s_d[4,5]:=s_d[4,1]
         end;
      4: begin
           titel:='   Das Farnblatt   ';
           xoffset:=270; yoffset:=15; xscale:=100; yscale:=31;
           iter:=9000;
           s_d[3,0]:='+  0160'; s_d[0,1]:='+  0200'; s_d[1,1]:='-  0260';
           s_d[2,1]:='+  0230'; s_d[3,1]:='+  0220'; s_d[5,1]:='+  1600';
           s_d[5,3]:=s_d[5,1];  s_d[0,2]:='-  0150'; s_d[1,2]:='+  0280';
           s_d[2,2]:='+  0260'; s_d[3,2]:='+  0240'; s_d[5,2]:='+  0440';
           s_d[0,3]:='+  0850'; s_d[3,3]:=s_d[0,3];  s_d[1,3]:='+  0040';
           s_d[2,3]:='-  0040'
         end;
      5: begin
           titel:='   Die Spirale   ';
           xoffset:=0; yoffset:=0; xscale:=55; yscale:=30;
           iter:=7500;
           s_d[0,0]:='+  0779'; s_d[1,0]:='-  0294'; s_d[1,1]:=s_d[1,0];
           s_d[2,0]:='+  0257'; s_d[3,0]:='+  0824'; s_d[4,0]:='+  3148';
           s_d[5,0]:='+  0342'; s_d[0,1]:='-  0273'; s_d[2,1]:='+  0079';
           s_d[3,1]:='-  0235'; s_d[4,1]:='+ 11716'; s_d[5,1]:='+  2599'
         end
    end;
    if res then
      begin
        yoffset:=yoffset div 2;
        yscale:=yscale div 2
      end;
    set_wname(window,titel);
    editifs
  end;

procedure loeschen;
  var i,j : integer;
  begin
    for j:=0 to 11 do
      for i:=0 to 5 do
        begin
          s_d[i,j]:='+  0000';
          ifscodes[j,i]:=0
        end;
    ifsmax:=0;
    iter:=5000; rec:=5;
    xoffset:=350; yoffset:=180;
    xscale :=100; yscale :=100;
    if res then
      begin
        yoffset:=90;
        yscale:=50
      end;
    titel:='';
    set_wname(window,titel);
    fenster_zu
  end;

procedure about_logo;
  var dia               : dialog_ptr;
      i,dummy,
      i_btn,i_box,i_tit : integer;
      ibla              : array[1..4] of integer;
      sbla              : array[1..4] of str255;
  begin
    fenster_zu;
    sbla[1]:=' Ein Public Domain Programm von ';
    sbla[2]:='Rainer Urian und Michael Herrmann';
    sbla[3]:='Mit freundlicher Genehmigung des ';
    sbla[4]:=' Heinz Heise Verlages, Hannover  ';
    dia:=new_dialog(8,0,0,41,12);
    i_box:=add_ditem(dia,g_ibox,none, 2,1,37,2, 1,$1180);
    i_tit:=add_ditem(dia,G_String,None,6,2,0,0, 0,0);
    Set_DText(dia,i_tit,'I F S - E d i t o r   V 1 . 0',System_Font,TE_Left);
    for i:=1 to 4 do
    begin
      ibla[i]:=add_ditem(dia,G_string,none,4,4+i,0,0, 2,$1180);
      set_dtext(dia,ibla[i],sbla[i],system_font,Te_left)
    end;
    i_btn:=Add_DItem(dia,G_Button,Selectable|Exit_Btn|Default|Touch_exit,
          29,10,9,1, 2,$1180);
    Set_DText(dia,i_btn,'soso...',System_Font,TE_Center);
    Center_Dialog(dia);
    dummy:=do_dialog(dia,0);
    end_dialog(dia);
    delete_dialog(dia)
  end;

procedure menue;
  var event,junk,item,i,j,
      i_abo,i_inkoo,i_inifs,
      i_graf,i_ende,i_loesh,
      i_f1,i_f2,i_f3,i_f4,i_f5,
      i_tit4,i_tit1,i_tit2,i_tit3 : integer;
      msg                         : message_buffer;
  begin
    for i:=0 to 5 do
      for j:=0 to 11 do
        s_k[i,j]:='+  0000';
    repeat
      set_mouse(m_point_hand);
      if not menu_da then
      begin
        menu:=new_menu( 13,'  Åber "IFS-Editor" ');
        i_tit1:=add_mtitle(menu,' Eingabe ');
        i_tit2:=add_mtitle(menu,' Grafik ');
        i_tit3:=add_mtitle(menu,' Fraktale ');
        i_tit4:=add_mtitle(menu,' Ende ');
        i_inkoo:=add_mitem(menu,i_tit1,'  Koordinaten ');
        i_inifs:=add_mitem(menu,i_tit1,'  IFS-Daten   ');
        i_loesh:=add_mitem(menu,i_tit1,'  Reset       ');
        i_graf :=add_mitem(menu,i_tit2,'  IFS zeichnen ');
        i_f1   :=add_mitem(menu,i_tit3,'  Pfeilspitze   ');
        i_f2   :=add_mitem(menu,i_tit3,'  DrachenflÑche ');
        i_f3   :=add_mitem(menu,i_tit3,'  Schneeflocke  ');
        i_f4   :=add_mitem(menu,i_tit3,'  Farnblatt     ');
        i_f5   :=add_mitem(menu,i_tit3,'  Spirale       ');
        i_ende :=add_mitem(menu,i_tit4,'  Programm beenden ');
        menu_da:=true;
      end;
      msg[0]:=0;
      if ifsmax=0 then
        begin
          menu_disable(menu,i_graf);
          for i:=i_f1 to i_f5 do menu_check(menu,i,false);
        end
      else menu_enable(menu,i_graf);
      draw_menu(menu);
      if res then text_color(red) else text_color(black);
      text_style(17);
      draw_string(425,ytop,'I F S - E d i t o r');
      event:=get_event( E_Message, 0, 0, 0, 0,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, junk, junk, junk, junk, junk, junk);
      erase_menu(menu);
      item:=msg[4];
      if (event=E_message) then
        begin
          if msg[3]=i_tit3 then
            begin
              for i:=i_f1 to i_f5 do menu_check(menu,i,false);
              menu_check(menu,item,true);
              loeschen;
              def_frak(item-i_f1+1)
            end
          else if (item<12) and (item>5) then
            about_logo
          else if item=i_inkoo then
            begin
              editpnt;
              transform;
              editifs;
            end
          else if item=i_inifs then
            editifs
          else if item=i_loesh then
            loeschen
          else if item=i_graf then
            drawifs
          else if item=i_ende then
            ende_da:=(do_alert(
             '[2][Soll der Editor|wirklich beendet|werden ?][ Ja |Nein]',2)=1);
          menu_normal(menu,msg[3]);
        end;
    until ende_da
  end;

begin
  dummy:=get_res;
  if dummy=2 then
    begin
      res:=false;
      ymax:=399;
      ytop:=14
    end
  else
    begin
      res:=true;
      ymax:=199;
      ytop:=7
    end;
  txt:=concat('[1][ |Der "IFS-Editor" lÑuft|',
              'nur in mittlerer oder|hoher Auflîsung !][  Achso ! ]');
  if dummy=0 then
    dummy:=do_alert(txt,1)
  else
 begin
  ifsmax:=-1;
  pntmax:=-1;
  menu_da:=false;
  ende_da:=false;
  logo_da:=false;
  if init_gem >=0 then
    begin
      set_color(3,333,444,777);
      draw_string(20,ytop,
'                                                                           ');
      set_mouse(m_point_hand);
      titel:='';
      window:=new_window(G_Name,titel,0,0,0,0);
      w_closed:=true;
      loeschen;
      menue;
      if not w_closed then close_window(window);
      delete_window(window);
      erase_menu(menu);
    end;
  exit_gem
 end
end.

