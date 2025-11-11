program checkers;
 label 50;
 const
  {$I GEMCONST.PAS}
  MAX                                 = 20;
  MAX360                              = 7200;
  MAX12P12                            = 252;
  MAXP1                               = 21;
 type
  {$I GEMTYPE.PAS}
 var
  mvlst                               : array[0..MAX360] of integer;
  vixbrd,brd,tkn,sw1,sw2,se1,se2      : array[0..32] of integer;
  nw1,nw2,ne1,ne2,oldbrd,clrbrd,kval  : array[0..32] of integer;
  nx,s,e,wx                           : array[0..32] of integer;
  princ                               : array[12..MAX12P12,1..MAX] of integer;
  oldprinc                            : array[12..MAX12P12] of integer;
  tmv                                 : array[0..12] of integer;
  lm                                  : array[1..12] of integer;
  ii,jj,olc                           : array[12..23] of integer;
  dmax,tpc,plyr,nextm,tmvp,code       : integer;
  top,bug,dv,over,alok,near,jedit,jinit : boolean;
  lij,kk,t,big_window,xmax,ymax,wmax,hmax,mul:integer;
  can_mov,clr_brd,title1,title2,edit_brd,init_brd,strt_gme,quit_edi:integer;
  red_top,red_bot,t_black,t_white,comp_p,quit:integer;
  level:array [0..10] of integer;
  dline:array [1..6] of integer;
  sq,c,m_state,dummy,which,mx,my,bs,ws,bp,wp,i,j,n:integer;
  msg:message_buffer;
  a_menu:menu_ptr;
  a,sonia:string;
  ok,full,mono:boolean;
  timelim                             : long_integer;
  d_color:array[0..3] of integer;
  {$I GEMSUBS.PAS}

  function s_color(a,b:integer):integer;
    XBIOS(7);

  procedure pnt_color(colr:integer);
    begin
      if mono then begin
        if colr=1 then paint_color(0) else paint_color(1);
        if (colr=0) then paint_style(5)
          else paint_style(1);
        if (colr=3) then paint_style(6);
      end
      else paint_color(colr);
    end;

  function gia_read(dum:integer):integer;
   xbios(37);

  procedure rectangle;
    begin
      hide_mouse;
      frame_rect(50*i+150,(20*j-6)*mul,50,20*mul);
      frame_rect(50*i+151,(20*j-6)*mul,48,20*mul);
      frame_rect(50*i+152,(20*j-6)*mul,46,20*mul);
      show_mouse;
    end;

  procedure convert_g(n:integer; var i,j:integer);
    begin
      if not top then n:=33-n;
      j:=(n-1) div 4+1;
      i:=((n-1) mod 4)*2+1;
      if j mod 2=1 then i:=i+1;
    end;

  procedure show_move(b:integer);
    var
      c:integer;
    begin
      for c:=b+1 to b+mvlst[b] do
       if mvlst[c]<>99 then begin
        convert_g(abs(mvlst[c]),i,j);
        line_color(0);
        if mono then line_color(1);
        rectangle;
       end;
      repeat
        which:=get_event( E_Button, 1, 1, 1, 0,
               false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
               dummy, dummy, dummy, mx, my, dummy );
      until which=E_Button;
      my:=trunc(my/mul);
      for c:=b+1 to b+mvlst[b] do
       if mvlst[c]<>99 then begin
        convert_g(abs(mvlst[c]),i,j);
        line_color(3);
        if mono then begin
          hide_mouse;
          paint_color(1);
          paint_style(6);
          paint_rect(50*i+150,(20*j-6)*mul,50,20*mul);
          show_mouse;
        end
        else rectangle;
       end;
       which:=get_event( E_Button, 1, 0, 1, 0,
               false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
               dummy, dummy, dummy, mx, my, dummy );
    end;

procedure disp_move;
    var
      c:integer;
      same:boolean;
    begin
      same:=true;
      for c:=13 to lij do
       if olc[c]<>abs(princ[c,1]) then
        same:=false;
      if not same then begin

      hide_mouse;
      pnt_color(3);
      for c:=13 to lij do
       if (ii[c]<>0) and (jj[c]<>0) then begin
        i:=ii[c];
        j:=jj[c];
        paint_rect(50*i+150,(20*j-6)*mul,10,4*mul)
       end;
      pnt_color(0);
      for c:=13 to 12+princ[12,1] do
       if princ[c,1]<>99 then begin
        convert_g(abs(princ[c,1]),i,j);
        olc[c]:=abs(princ[c,1]);
        ii[c]:=i;
        jj[c]:=j;
        pnt_color(0);
        paint_rect(50*i+150,(20*j-6)*mul,10,4*mul);
        lij:=c;
       end;
      show_mouse;

      end;
    end;

  procedure init_screen;
    var
      c,c1,x,y,wm,hm,d:integer;
      title:window_title;
    begin
      if ok then init_mouse;
      hide_mouse;
      if ok then begin
        big_window:=new_window(0,title,0,0,0,0);
        open_window(big_window,0,0,0,0);
        set_window(big_window);
        work_rect(0,d,d,wm,hm);
        paint_outline(false);
        for c:=0 to 3 do
          d_color[c]:=s_color(c,-1);
        if hm>210 then begin
          mono:=true;
          mul:=2;
        end;
        if (wm<600) then begin
          d:=do_alert('[1][ |  | Use medium or high res ][ OK ]',1);
          goto 50;
        end;
      end;
      if not mono then begin
        set_color(1,1000,1000,1000);
        set_color(0,0,0,600); {blue}
        set_color(3,0,600,0); {green}
        set_color(2,750,0,0); {red}
      end;
      pnt_color(0);
      paint_rect(0,0,640,200*mul);
      line_color(1);
      if not mono then begin
        frame_rect(-1,-1,640,188*mul);
        frame_rect(0,-1,638,188*mul);
      end;
      pnt_color(2);
      paint_rect(192,10*mul,416,168*mul);
      c1:=0;
      y:=14;
      while (y<174) do begin
        if (c1 mod 2=0) then c:=0 else c:=1;
        x:=200;
        while (x<570) do begin
          if (c mod 2=0) then pnt_color(1) else pnt_color(3);
          paint_rect(x,y*mul,50,20*mul);
          x:=x+50;
          c:=c+1
        end;
      y:=y+20;
      c1:=c1+1;
      end;
    show_mouse;
    end;

  procedure set_menu;
    var
      c:integer;
    begin
      a_menu:=new_menu(30,'  About checkers...  ');
      title1:=add_mtitle(a_menu,' Game ');
      title2:=add_mtitle(a_menu,' Options ');
      init_brd:=add_mitem(a_menu,title1,'  Initialize board  ');
      strt_gme:=add_mitem(a_menu,title1,'  Start game        ');
      edit_brd:=add_mitem(a_menu,title1,'  Edit board        ');
      quit_edi:=add_mitem(a_menu,title1,'  Quit edit         ');
      clr_brd :=add_mitem(a_menu,title1,'  Clear board       ');
      can_mov :=add_mitem(a_menu,title1,'  Cancel move       ');
      dline[1]:=add_mitem(a_menu,title1,'--------------------');
      t_black :=add_mitem(a_menu,title1,'  Computer is red   ');
      t_white :=add_mitem(a_menu,title1,'  Computer is white ');
      dline[2]:=add_mitem(a_menu,title1,'--------------------');
      red_top :=add_mitem(a_menu,title1,'  Red plays top     ');
      red_bot :=add_mitem(a_menu,title1,'  Red plays bottom  ');
      dline[3]:=add_mitem(a_menu,title1,'--------------------');
      quit    :=add_mitem(a_menu,title1,'  Quit              ');
      level[0]:=add_mitem(a_menu,title2,'  Level 0  (5  secs)  ');
      level[1]:=add_mitem(a_menu,title2,'  Level 1  (30 secs)  ');
      level[2]:=add_mitem(a_menu,title2,'  Level 2  (2  mins)  ');
      level[3]:=add_mitem(a_menu,title2,'  Level 3  (5  mins)  ');
      level[4]:=add_mitem(a_menu,title2,'  Level 4  (20 mins)  ');
      level[5]:=add_mitem(a_menu,title2,'  Level 5  (2  hrs )  ');
      level[6]:=add_mitem(a_menu,title2,'  Level 6  (8  hrs )  ');
      for c:=1 to 3 do
        menu_disable(a_menu,dline[c]);
      draw_menu(a_menu);
    end;

  procedure convert_s(i,j:integer; var n:integer);
    begin
      n:=(i-1) div 2+(j-1)*4+1;
      if not top then n:=33-n;
    end;

 procedure print_board;
   var
     i,j,n:integer;
   begin
     hide_mouse;
     for n:=32 downto 1 do
       if (brd[n]<>vixbrd[n]) or full then begin
         case brd[n] of
           -2:pnt_color(2);
           -1:pnt_color(2);
            0:pnt_color(3);
            1:pnt_color(1);
            2:pnt_color(1);
          end;
          convert_g(n,i,j);
          if (brd[n]=0) then
            paint_rect(50*i+150,(20*j-6)*mul,50,20*mul)
          else begin
            paint_oval(50*i+175,(20*j+3)*mul,18,-4);
            paint_oval(50*i+175,(20*j+4)*mul,18,-4);
          end;
          pnt_color(0);
          if abs(brd[n])=2 then begin
            if mono then paint_style(5);
            paint_rect(50*i+171,(20*j-2)*mul,9,12*mul);
            paint_rect(50*i+163,(20*j+2)*mul,25,4*mul);
          end;
       end;
     show_mouse;
   end;

  procedure info;
    var
      dialog : Dialog_Ptr ;
      button,
      ok_btn,
      prompt_item:integer;
    begin
        dialog := New_Dialog( 20, 0, 0, 40, 18 ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 12, 2, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, 'ST CHECKERS 1.0',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 12, 3, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, '---------------',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 11, 5, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, 'by Pascal Parent',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 11, 7, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, 'ST adaptation by',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 10, 9, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, 'Francois Villeneuve',
                        System_Font, TE_Center ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 8, 12, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, 'Montreal, December 1986',
                        System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                        16, 14, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, 0 ) ;
        end_dialog(dialog);
        delete_dialog(dialog);
    end;

  procedure redraw;
    begin
      if (which=E_Message) and (msg[3]=3) then begin
       info;
       menu_normal(a_menu,msg[3]);
       which:=get_event( E_Message, 1, 1, 1, 0,
              false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
              dummy, dummy, dummy, mx, my, dummy );
      end;
      if (which=E_Message) and (msg[0]=WM_Redraw) then begin
        init_screen;
        vixbrd:=clrbrd;
        print_board;
      end;
    end;

  procedure setup;
    label 30;
    var
      i,j,coul:integer;
    begin
      jedit:=true;
      menu_enable(a_menu,quit_edi);
      menu_enable(a_menu,clr_brd);
      menu_disable(a_menu,edit_brd);
      menu_disable(a_menu,strt_gme);
      menu_disable(a_menu,init_brd);
      menu_disable(a_menu,t_black);
      menu_disable(a_menu,t_white);
      menu_disable(a_menu,red_top);
      menu_disable(a_menu,red_bot);
      for i:=0 to 6 do
        menu_disable(a_menu,level[i]);
      repeat
        which:=get_event( E_Message | E_Button, 1, 1, 1, 0,
               false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
               dummy, dummy, dummy, mx, my, dummy );
        menu_normal(a_menu,title1); menu_normal(a_menu,title2);
        my:=trunc(my/mul);
        if (which=E_Message) and (msg[4]=clr_brd) then begin
          vixbrd:=brd;
          brd:=clrbrd;
          print_board;
        end;
        if (which=E_Message) and ((msg[0]=WM_Redraw) or (msg[3]=3))
          then redraw;
        if which=E_Message then goto 30;
        if (which=e_button) and (mx>199) and (mx<601) and (my>13)
           and (my<185) then begin
          my:=my-12;
          i:=((mx-200) div 50)+1;
          j:=((my-14) div 20)+1;
          if ((i mod 2=1) and (j mod 2=0)) or ((i mod 2=0) and (j mod 2=1))
            then begin
           convert_s(i,j,n);
             case (brd[n]) of
                0:brd[n]:=-1;
               -1:brd[n]:= 1;
                1:brd[n]:= 2;
                2:brd[n]:=-2;
               -2:brd[n]:= 0;
             end;
             case (brd[n]) of
               0:coul:=3;
               -1:coul:=2;
                1:coul:=1;
               -2:coul:=2;
                2:coul:=1;
             end;
             hide_mouse;
             pnt_color(coul);
             paint_oval((50*i+175),(20*j+3)*mul,18,-4);
             paint_oval((50*i+175),(20*j+4)*mul,18,-4);
             pnt_color(0);
             if abs(brd[n])=2 then begin
                if mono then paint_style(5);
                paint_rect(50*i+171,(20*j-2)*mul,9,12*mul);
                paint_rect(50*i+163,(20*j+2)*mul,25,4*mul);
             end;
             show_mouse;
            end;
            which:=get_event( E_Button, 1, 0, 1, 0,
                   false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
                   dummy, dummy, dummy, mx, my, dummy );
30:     end;
      until (which=E_Message) and ((msg[4]=quit_edi) or (msg[4]=quit));
      menu_disable(a_menu,clr_brd);
      menu_enable(a_menu,edit_brd);
      menu_enable(a_menu,strt_gme);
      menu_enable(a_menu,init_brd);
      menu_enable(a_menu,t_black);
      menu_disable(a_menu,quit_edi);
      menu_enable(a_menu,t_white);
      menu_enable(a_menu,red_top);
      menu_enable(a_menu,red_bot);
      for i:=0 to 6 do
        menu_enable(a_menu,level[i]);
    end;

  procedure quit_prg;
    var
      c:integer;
    begin
      close_window(big_window);
      for c:=0 to 3 do
        dummy:=s_color(c,d_color[c]);
    end;

  procedure print_message(b:string;wait:boolean);
    begin
      hide_mouse;
      pnt_color(0);
      paint_rect(10,17*mul,150,10*mul);
      draw_mode(2);
      if mono then text_color(0) else text_color(1);
      draw_string(10,24*mul,b);
      draw_mode(1);
      show_mouse;
    end;

 procedure skip(ss,pc:integer);
  var
   jfound,k,tmp,s1,s2: integer;
  begin
   tmv[tmvp]:=ss;
   tmp:=tmvp;
   tmvp:=tmvp+1;
   jfound:=0;
   if (sw2[ss]<>0) and (pc<>1) then
    if (tkn[sw1[ss]]<1) and (brd[sw2[ss]]=0) then begin
     if abs(brd[sw1[ss]])=2 then
      tmv[tmp]:=-ss
     else
      tmv[tmp]:=ss;
     tkn[sw1[ss]]:=2;
     jfound:=1;
     skip(sw2[ss],pc)
    end;
   if (se2[ss]<>0) and (pc<>1) then
    if (tkn[se1[ss]]<1) and (brd[se2[ss]]=0) then begin
     if abs(brd[se1[ss]])=2 then
      tmv[tmp]:=-ss
     else
      tmv[tmp]:=ss;
     tkn[se1[ss]]:=2;
     jfound:=1;
     skip(se2[ss],pc)
    end;
   if (nw2[ss]<>0) and (pc<>-1) then
    if (tkn[nw1[ss]]<1) and (brd[nw2[ss]]=0) then begin
     if abs(brd[nw1[ss]])=2 then
      tmv[tmp]:=-ss
     else
      tmv[tmp]:=ss;
     tkn[nw1[ss]]:=2;
     jfound:=1;
     skip(nw2[ss],pc)
    end;
   if (ne2[ss]<>0) and (pc<>-1) then
    if (tkn[ne1[ss]]<1) and (brd[ne2[ss]]=0) then begin
     if abs(brd[ne1[ss]])=2 then
      tmv[tmp]:=-ss
     else
      tmv[tmp]:=ss;
     tkn[ne1[ss]]:=2;
     jfound:=1;
     skip(ne2[ss],pc)
    end;
   if (tmvp>1) and (jfound=0) then begin
    if ((ss>28) and (pc=-1)) or ((ss<5) and (pc=1)) then begin
     tmv[tmvp]:=99;
     tmvp:=tmvp+1
    end;
    mvlst[nextm]:=tmvp;
    for k:=0 to tmvp-1 do
     mvlst[nextm+k+1]:=tmv[k];
    nextm:=nextm+12
   end;
   if tmp>0 then begin
    tmvp:=tmp;
    s1:=abs(tmv[tmp-1]);
    s2:=abs(tmv[tmp]);
    if sw2[s1]=s2 then
     tkn[sw1[s1]]:=0
    else if nw2[s1]=s2 then
     tkn[nw1[s1]]:=0
    else if ne2[s1]=s2 then
     tkn[ne1[s1]]:=0
    else if se2[s1]=s2 then
     tkn[se1[s1]]:=0
   end
  end;

 procedure move(ss,pc:integer);
  begin
   if (sw1[ss]<>0) and (pc<>1) then
    if brd[sw1[ss]]=0 then begin
     mvlst[nextm+1]:=ss;
     mvlst[nextm+2]:=sw1[ss];
     mvlst[nextm]:=2;
     if (sw1[ss]>28) and (pc=-1) then begin
      mvlst[nextm+3]:=99;
      mvlst[nextm]:=3
     end;
     nextm:=nextm+12
    end;
   if (se1[ss]<>0) and (pc<>1) then
    if brd[se1[ss]]=0 then begin
     mvlst[nextm+1]:=ss;
     mvlst[nextm+2]:=se1[ss];
     mvlst[nextm]:=2;
     if (se1[ss]>28) and (pc=-1) then begin
      mvlst[nextm+3]:=99;
      mvlst[nextm]:=3
     end;
     nextm:=nextm+12
    end;
   if (nw1[ss]<>0) and (pc<>-1) then
    if brd[nw1[ss]]=0 then begin
     mvlst[nextm+1]:=ss;
     mvlst[nextm+2]:=nw1[ss];
     mvlst[nextm]:=2;
     if (nw1[ss]<5) and (pc=1) then begin
      mvlst[nextm+3]:=99;
      mvlst[nextm]:=3
     end;
     nextm:=nextm+12
    end;
   if (ne1[ss]<>0) and (pc<>-1) then
    if brd[ne1[ss]]=0 then begin
     mvlst[nextm+1]:=ss;
     mvlst[nextm+2]:=ne1[ss];
     mvlst[nextm]:=2;
     if (ne1[ss]<5) and (pc=1) then begin
      mvlst[nextm+3]:=99;
      mvlst[nextm]:=3
     end;
     nextm:=nextm+12
    end
  end;

 procedure movegen(lvl:integer);
  var
   mbeg,colr,c:integer;
  begin
   tmvp:=0;
   if lvl mod 2=0 then
    colr:=1
   else
    colr:=-1;
   if plyr=-1 then
    colr:=-colr;
   mbeg:=360*lvl;
   nextm:=mbeg;
   for c:=1 to 32 do
    if ((brd[c]<0) and (colr>0)) or ((brd[c]>0) and (colr<0)) then
     tkn[c]:=0
    else
     tkn[c]:=1;
   for c:=1 to 32 do
    if (brd[c]<>0) and (tkn[c]<>0) then begin
     tmvp:=0;
     tpc:=brd[c];
     brd[c]:=0;
     skip(c,tpc);
     brd[c]:=tpc
    end;
   if nextm=mbeg then
    for c:=1 to 32 do
     if (brd[c]<>0) and (tkn[c]<>0) then
      move(c,brd[c]);
   mvlst[nextm]:=0
  end;

 procedure st(i,a,b,c,d,e,f,g,h,v:integer);
  begin
   sw1[i]:=a;
   sw2[i]:=b;
   nw1[i]:=c;
   nw2[i]:=d;
   ne1[i]:=e;
   ne2[i]:=f;
   se1[i]:=g;
   se2[i]:=h;
   kval[i]:=v;
  end;

 procedure initarr;
  var
   c :integer;
  begin
   st(1,5,0,0,0,0,0,6,10,-30);
   st(2,6,9,0,0,0,0,7,11,-30);
   st(3,7,10,0,0,0,0,8,12,-30);
   st(4,8,11,0,0,0,0,0,0,-30);
   st(5,0,0,0,0,1,0,9,14,-30);
   st(6,9,13,1,0,2,0,10,15,-15);
   st(7,10,14,2,0,3,0,11,16,-15);
   st(8,11,15,3,0,4,0,12,0,-15);
   st(9,13,0,5,0,6,2,14,18,-15);
   st(10,14,17,6,1,7,3,15,19,15);
   st(11,15,18,7,2,8,4,16,20,15);
   st(12,16,19,8,3,0,0,0,0,-30);
   st(13,0,0,0,0,9,6,17,22,-30);
   st(14,17,21,9,5,10,7,18,23,15);
   st(15,18,22,10,6,11,8,19,24,30);
   st(16,19,23,11,7,12,0,20,0,-15);
   st(17,21,0,13,0,14,10,22,26,-15);
   st(18,22,25,14,9,15,11,23,27,30);
   st(19,23,26,15,10,16,12,24,28,15);
   st(20,24,27,16,11,0,0,0,0,-30);
   st(21,0,0,0,0,17,14,25,30,-30);
   st(22,25,29,17,13,18,15,26,31,15);
   st(23,26,30,18,14,19,16,27,32,15);
   st(24,27,31,19,15,20,0,28,0,-15);
   st(25,29,0,21,0,22,18,30,0,-15);
   st(26,30,0,22,17,23,19,31,0,-15);
   st(27,31,0,23,18,24,20,32,0,-15);
   st(28,32,0,24,19,0,0,0,0,-30);
   st(29,0,0,0,0,25,22,0,0,-30);
   st(30,0,0,25,21,26,23,0,0,-30);
   st(31,0,0,26,22,27,24,0,0,-30);
   st(32,0,0,27,23,28,0,0,0,-30);
   for c:=1 to 8 do
    nx[c]:=0;
   for c:=9 to 32 do
    nx[c]:=c-8;
   for c:=1 to 24 do
    s[c]:=c+8;
   for c:=25 to 32 do
    s[c]:=0;
   for c:=1 to 32 do
    if (c-1) mod 4=0 then
      wx[c]:=0
    else
      wx[c]:=c-1;
   for c:=1 to 32 do
    if (c-1) mod 4=3 then
      e[c]:=0
    else
      e[c]:=c+1;
  end;

function eval:integer;
  var
   score,n,w,b,bq,wq,cof : integer;
   cond                  : boolean;
  begin
   score:=0;
   w:=0;
   b:=0;
   bq:=0;
   wq:=0;
   for n:=1 to 32 do
     case brd[n] of
      -2: bq:=bq+1;
      -1: b:=b+1;
       1: w:=w+1;
       2: wq:=wq+1;
     end;
   if w+wq=0 then
    score:=-31000
   else if b+bq=0 then
    score:=31000
   else begin
    score:=w*1000+wq*2000-b*1000-bq*2000;
    for n:=5 to 28 do
     if brd[n]>0 then begin
      if brd[sw1[n]]>0 then
       score:=score+8;
      if brd[se1[n]]>0 then
       score:=score+8
     end
     else if brd[n]<0 then begin
      if brd[nw1[n]]<0 then
       score:=score-8;
      if brd[ne1[n]]<0 then
       score:=score-8
     end;
    if bq<2 then
     for n:=29 to 32 do
      if brd[n]=1 then
       score:=score+25;
    if wq<2 then
     for n:=1 to 4 do
      if brd[n]=-1 then
       score:=score-25;
   end;
   if plyr=-1 then
    score:=-score;
   if abs(score)<>31000 then begin
    cof:=1;
    if plyr=-1 then begin
     if b<5 then cof:=10;
     score:=score+(b-wq)*20;
     for w:=5 to 28 do
      if brd[w]=-1 then
       score:=score+((w-1) div 4)*cof
    end;
    if plyr=1 then begin
     if w<5 then cof:=10;
     score:=score+(w-bq)*20;
     for w:=5 to 28 do
      if brd[w]=1 then
       score:=score+((7-(w-1)) div 4)*cof
    end;
    if (wq>0) or (bq>0) then
      for n:=1 to 32 do
       case brd[n] of
        -2 : begin
               if plyr=-1 then
                 score:=score+kval[i]
               else if wq>=bq then begin
                if brd[nw2[n]]=2 then
                 score:=score+50;
                if brd[sw2[n]]=2 then
                 score:=score+50;
                if brd[ne2[n]]=2 then
                 score:=score+50;
                if brd[se2[n]]=2 then
                 score:=score+50;
                if brd[nx[n]]=2 then
                 score:=score+100;
                if brd[s[n]]=2 then
                 score:=score+100;
                if brd[e[n]]=2 then
                 score:=score+100;
                if brd[wx[n]]=2 then
                 score:=score+100;
               end;
             end;
         2 : begin
               if plyr=1 then
                 score:=score+kval[i]
               else if bq>=wq then begin
                if brd[nw2[n]]=-2 then
                 score:=score+50;
                if brd[sw2[n]]=-2 then
                 score:=score+50;
                if brd[ne2[n]]=-2 then
                 score:=score+50;
                if brd[se2[n]]=-2 then
                 score:=score+50;
                if brd[nx[n]]=-2 then
                 score:=score+100;
                if brd[s[n]]=-2 then
                 score:=score+100;
                if brd[e[n]]=-2 then
                 score:=score+100;
                if brd[wx[n]]=-2 then
                 score:=score+100;
               end;
             end;
       end;
   end;
   eval:=score
  end;

 procedure restore(pos:integer);
  var
   cnt,rs,rsc,pc,sq1,sq2 :integer;
  begin
   cnt:=mvlst[pos]+pos;
   if mvlst[cnt]=99 then begin
    cnt:=cnt-1;
    pc:=brd[mvlst[cnt]] div 2
   end
   else
    pc:=brd[mvlst[cnt]];
   if pc<0 then
    rs:=1
   else
    rs:=-1;
   if abs(abs(mvlst[cnt])-abs(mvlst[cnt-1]))<6 then begin
    brd[mvlst[cnt-1]]:=pc;
    brd[mvlst[cnt]]:=0
   end
   else
    while cnt>pos+1 do begin
     sq2:=abs(mvlst[cnt]);
     sq1:=abs(mvlst[cnt-1]);
     if se2[sq2]=sq1 then
      rsc:=se1[sq2]
     else if sw2[sq2]=sq1 then
      rsc:=sw1[sq2]
     else if nw2[sq2]=sq1 then
      rsc:=nw1[sq2]
     else if ne2[sq2]=sq1 then
      rsc:=ne1[sq2];
     brd[sq2]:=0;
     brd[sq1]:=pc;
     if mvlst[cnt-1]>0 then
      brd[rsc]:=rs
     else
      brd[rsc]:=rs*2;
     cnt:=cnt-1
    end
  end;

 procedure update(pos:integer);
  var
   lst,cnt,pc,klc,sq1,sq2 : integer;
  begin
   cnt:=pos+1;
   pc:=brd[abs(mvlst[cnt])];
   lst:=mvlst[pos]+pos;
   if mvlst[lst]=99 then begin
    lst:=lst-1;
    pc:=pc*2
   end;
   if abs(abs(mvlst[cnt])-abs(mvlst[cnt+1]))<6 then begin
    brd[mvlst[cnt]]:=0;
    brd[mvlst[cnt+1]]:=pc
   end
   else
    while cnt<lst do begin
     sq1:=abs(mvlst[cnt]);
     sq2:=abs(mvlst[cnt+1]);
     if ne2[sq1]=sq2 then
      klc:=ne1[sq1]
     else if nw2[sq1]=sq2 then
      klc:=nw1[sq1]
     else if sw2[sq1]=sq2 then
      klc:=sw1[sq1]
     else if se2[sq1]=sq2 then
      klc:=se1[sq1];
     brd[sq1]:=0;
     brd[klc]:=0;
     brd[sq2]:=pc;
     cnt:=cnt+1
    end
   end;

 procedure getmove;
  label 5;
  var
   square,pnt,p              : integer;
   mv                        : array[1..12] of integer;
   fnd,found,fin,first,pr,ok : boolean;
  begin
   alok:=false;
   fnd:=false;
   movegen(1);
   p:=361;
   while not fnd and (mvlst[p-1]<>0) do begin
    if abs(mvlst[p])=code then fnd:=true;
    p:=p+12
   end;
   if fnd then begin

   plyr:=-plyr;
   alok:=true;
   movegen(0);
   first:=true;
   if mvlst[0]<>0 then begin
    repeat
     if first then begin
      mv[1]:=code;
      square:=2
     end
     else
      square:=square-1;
     first:=false;
     fin:=false;
     repeat
      menu_enable(a_menu,can_mov);
      convert_g(mv[square-1],i,j);
      line_color(0);
      if mono then line_color(1);
      rectangle;
      if square>2 then begin
        convert_g(mv[square-2],i,j);
        line_color(3);
        rectangle;
      end;
      repeat
        which:=get_event( E_Message | E_Button, 1, 1, 1, 0,
               false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
               dummy, dummy, dummy, mx, my, dummy );
        my:=trunc(my/mul);
        if (which=E_Message) and (msg[4]=can_mov) then begin
          line_color(3);
          menu_normal(a_menu,msg[3]);
          for p:=1 to square do begin
           convert_g(mv[p],i,j);
           if mono then begin
             hide_mouse;
             paint_style(6);
             paint_rect(50*i+150,(20*j-6)*mul,50,20*mul);
             vixbrd[mv[p]]:=0;
             print_board;
             show_mouse;
           end
           else rectangle;
          end;
          alok:=false;
          plyr:=-plyr;
          goto 5;
        end;
        my:=my-12;
        i:=((mx-200) div 50)+1;
        j:=((my-14) div 20)+1;
        if (which=e_button) and (mx>199) and (mx<601) and (my>1)
           and (my<173) then ok:=true
        else ok:=false;
        if ((i mod 2=0) and (j mod 2=0)) or ((i mod 2=1) and (j mod 2=1))
          then ok:=false;
      until ok and (which=E_Button);
      convert_s(i,j,n);
      mv[square]:=n;
      pr:=false;
      p:=0;
      fnd:=false;
      while (mvlst[p]<>0) and (not fnd) do begin
       found:=true;
       for pnt:=1 to square do
        if abs(mvlst[pnt+p])<>mv[pnt] then
         found:=false;
       if found then
        fnd:=true;
       p:=p+12
      end;
      p:=p-12;
      square:=square+1;
      if ((mvlst[square+p]=99) or (square>mvlst[p])) and (fnd) then
       fin:=true
     until (fin) or (not fnd)
    until fin
   end;
   lm:=mv;
   convert_g(mv[square-2],i,j);
   line_color(3);
   if mono then line_color(0);
   rectangle;
   update(p);
   plyr:=-plyr;
   movegen(0);
   if (eval<-30000) or (mvlst[0]=0) then begin
    print_message('I LOSE...',false);
    over:=true;
    alok:=false;
   end

  end;
  menu_disable(a_menu,can_mov);
  which:=get_event( E_Button, 1, 0, 1, 0,
               false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
               dummy, dummy, dummy, mx, my, dummy );
5:end;

 procedure alphbet;
  label
   20;
  var
   score                              : array[-1..MAXP1] of integer;
   mp                                 : array[0..MAXP1] of integer;
   ply,c,d,f,r1,r2,h,maxsr            : integer;
   tt                                 : integer;
   xt,any,prdone,diff                 : boolean;
  function t_settime(time:integer):integer;
   gemdos($2d);
  begin
   sonia:='                              ';
   set_mouse(M_Bee);
   oldbrd:=brd;
   tt:=t_settime(0);
   score[1]:=eval;
   movegen(0);
   if (mvlst[12]=0) and not near then begin
    for c:=0 to 11 do
     princ[c+12,1]:=mvlst[c];
    set_mouse(M_Arrow);
    show_move(0);
    update(0);
    goto 20
   end;
   maxsr:=1;
   if timelim=0 then
    maxsr:=4;

   repeat

   sonia[maxsr]:='.';
   if timelim<>0 then
    print_message(sonia,false);
   score[-1]:=-32000;
   score[0]:=32000;
   ply:=0;
   prdone:=false;
   if timelim=0 then
    prdone:=true;
   repeat
    any:=true;
    while (ply<>maxsr) and any do begin
     movegen(ply);
     if (not prdone) and (maxsr<>1) then begin
       d:=ply*360;
       diff:=true;
       while (mvlst[d]<>0) and (diff) do begin
        diff:=false;
        for c:=0 to mvlst[d] do
         if mvlst[d+c]<>princ[12*ply+12+c,1] then
          diff:=true;
        d:=d+12
       end;
       if not diff then begin
        d:=d-12;
        for c:=0 to 11 do begin
         mvlst[d+c]:=mvlst[360*ply+c];
         mvlst[360*ply+c]:=princ[12*ply+12+c,1]
        end
       end
       else
        prdone:=true;
       if ply=maxsr-1 then
        prdone:=true
      end;
     if mvlst[ply*360]=0 then
      any:=false;
     if any then begin
      score[ply+1]:=score[ply-1];
      mp[ply+1]:=360*ply;
      ply:=ply+1;
      update(mp[ply]);
     end
    end;
    if not any then
     if ply mod 2=0 then
      score[ply+1]:=-31000
     else
      score[ply+1]:=31000
    else
      score[ply+1]:=eval;
    xt:=false;
    repeat
     if ((ply mod 2=0) and (score[ply+1]<=score[ply-1])) or
        ((ply mod 2=1) and (score[ply+1]>=score[ply-1])) then begin
      restore(mp[ply]);
      ply:=ply-1
     end
     else if ((ply mod 2=0) and (score[ply+1]<score[ply])) or
             ((ply mod 2=1) and (score[ply+1]>score[ply])) then begin
      score[ply]:=score[ply+1];
      if ply<maxsr then begin
       r1:=(ply+1)*12;
       r2:=maxsr*12+11;
       for h:=r1 to r2 do
        princ[h,ply]:=princ[h,ply+1]
      end;
      r1:=ply*12;
      for h:=0 to 11 do
       princ[r1+h,ply]:=mvlst[mp[ply]+h];
      if ply=1 then
       disp_move;
     end;
     restore(mp[ply]);
     ply:=ply-1;
     if mvlst[mp[ply+1]+12]<>0 then
      xt:=true
    until (xt) or (ply=0);
    if (ply<>0) or xt then begin
     mp[ply+1]:=mp[ply+1]+12;
     ply:=ply+1;
     update(mp[ply]);
    end;
   until (ply=0) and (not xt);

   maxsr:=maxsr+1;
   until (maxsr=dmax+1) or (score[1]=31000)
    or ((clock>timelim) and (maxsr>6));

   hide_mouse;
   pnt_color(3);
   for c:=13 to lij do
    if (ii[c]<>0) and (jj[c]<>0) then begin
     i:=ii[c];
     j:=jj[c];
     paint_rect(50*i+150,(20*j-6)*mul,10,4*mul)
    end;
   pnt_color(0);
   show_mouse;
   brd:=oldbrd;
   hide_mouse;
   paint_rect(10,17*mul,170,10*mul);
   show_mouse;
   for d:=12 to 23 do
    mvlst[d]:=princ[d,1];
   if (score[1]=31000) and ((maxsr-2) div 2<>0) and (timelim<>0) then begin
    sonia:='I win in   ... ';
    near:=true;
    sonia[10]:=chr((maxsr-2) div 2+ord('0'));
    print_message(sonia,false);
   end;
   set_mouse(M_arrow);
   show_move(12);
   update(12);
20:
   movegen(1);
   if (eval>30000) or (mvlst[360]=0) then begin
    print_message('*** I WIN! ***',false);
    over:=true
   end
 end;

 procedure init;
  var
   ans     : char;
   ac      : array[1..4] of char;
   row,i,sq: integer;
  begin
    for sq:=1 to 12 do
     brd[sq]:=-1;
    for sq:=13 to 20 do
     brd[sq]:=0;
    for sq:=21 to 32 do
     brd[sq]:=1;
  end;

 begin
   if init_gem>=0 then begin
     init_mouse;
     mono:=false; mul:=1;
     for c:=1 to 32 do
       brd[c]:=0;
     vixbrd:=brd;
     clrbrd:=brd;
     jedit:=false;
     jinit:=false;
     near:=false;
     full:=false;
     brd[0]:=0;
     ok:=true;
     init_screen;
     set_menu;
     menu_disable(a_menu,quit_edi);
     menu_disable(a_menu,clr_brd);
     menu_disable(a_menu,strt_gme);
     menu_disable(a_menu,can_mov);
     menu_check(a_menu,t_white,true);
     menu_check(a_menu,red_bot,true);
     menu_check(a_menu,level[0],true);
     initarr;
     lij:=13;
     ii[13]:=2;
     jj[13]:=1;
     over:=true;
     plyr:=1;
     top:=false;
     timelim:=0;
     dmax:=4;
     repeat
       which:=get_event( E_Message | E_Button, 1, 1, 1, 0,
              false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
              dummy, dummy, dummy, mx, my, dummy );
       my:=trunc(my/mul);
       if ok then begin
         which:=E_Timer;
         ok:=false;
       end;
       if (which=E_Message) and ((msg[0]=WM_Redraw) or (msg[3]=3))
         then redraw;
       if (which=e_button) and (mx>199) and (mx<601) and (my>13)
           and (my<185) and not over then begin
         my:=my-12;
         i:=((mx-200) div 50)+1;
         j:=((my-14) div 20)+1;
         if ((i mod 2=1) and (j mod 2=0)) or ((i mod 2=0) and (j mod 2=1))
           then begin
             convert_s(i,j,code);
             vixbrd:=brd;
             getmove;
             print_board;
             if alok then begin
              vixbrd:=brd;
              if not jinit then
               alphbet
              else begin
               jinit:=false;
               mvlst[0]:=2;
               if (lm[1]=9) and (lm[2]=13) then begin
                 mvlst[1]:=22;
                 mvlst[2]:=18;
               end;
               if (lm[1]=9) and (lm[2]=14) then begin
                 mvlst[1]:=22;
                 mvlst[2]:=18;
               end;
               if (lm[1]=10) and (lm[2]=14) then begin
                 mvlst[1]:=22;
                 mvlst[2]:=17;
               end;
               if (lm[1]=10) and (lm[2]=15) then begin
                 mvlst[1]:=21;
                 mvlst[2]:=17;
               end;
               if (lm[1]=11) and (lm[2]=15) then begin
                 mvlst[1]:=23;
                 mvlst[2]:=18;
               end;
               if (lm[1]=11) and (lm[2]=16) then begin
                 mvlst[1]:=22;
                 mvlst[2]:=18;
               end;
               if (lm[1]=12) and (lm[2]=16) then begin
                 mvlst[1]:=24;
                 mvlst[2]:=20;
               end;
               show_move(0);
               vixbrd:=brd;
               update(0);
               print_board;
              end;
              print_board
             end;
           end;
         end;
       if (msg[3]=title1) and (which=E_Message) then begin
         menu_normal(a_menu,msg[3]);
         if (msg[4]=edit_brd) then begin
           jinit:=false;
           hide_mouse;
           pnt_color(0);
           paint_rect(10,17*mul,150,10*mul);
           show_mouse;
           setup;
           for c:=1 to 32 do
             if (brd[c]<>0) then
               menu_enable(a_menu,strt_gme);
           over:=true;
           near:=false;
         end
         else if msg[4]=strt_gme then begin
           which:=get_event( E_Button, 1, 0, 1, 0,
               false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
               dummy, dummy, dummy, mx, my, dummy );
           over:=false;
           if jedit then begin
            jedit:=false;
            vixbrd:=brd;
            movegen(0);
            if mvlst[0]<>0 then begin
             alphbet;
             print_board;
            end
            else begin
             print_message('I LOSE...',false);
             over:=true;
             print_board;
            end
           end
           else if plyr=-1 then begin
             jinit:=false;
             sq:=abs(gia_read(0) mod 100);
             mvlst[0]:=2;
             mvlst[1]:=11;
             mvlst[2]:=15;
             if sq<50 then begin
               mvlst[0]:=2;
               mvlst[1]:=9;
               mvlst[2]:=14
             end;
             show_move(0);
             vixbrd:=brd;
             update(0);
             print_board;
           end;
           menu_disable(a_menu,strt_gme);
         end
         else if (msg[4]=init_brd) then begin
           jinit:=true;
           jedit:=false;
           hide_mouse;
           pnt_color(0);
           paint_rect(10,17*mul,150,10*mul);
           show_mouse;
           vixbrd:=brd;
           init;
           near:=false;
           over:=true;
           full:=true;
           print_board;
           full:=false;
           menu_enable(a_menu,strt_gme);
         end
         else if (msg[4]=red_top) then begin
               top:=true;
               menu_check(a_menu,red_bot,false);
               menu_check(a_menu,red_top,true);
               vixbrd:=clrbrd;
               full:=true;
               print_board;
               full:=false;
         end
         else if (msg[4]=red_bot) then begin
               menu_check(a_menu,red_bot,true);
               menu_check(a_menu,red_top,false);
               top:=false;
               vixbrd:=clrbrd;
               full:=true;
               print_board;
               full:=false;
         end
         else if (msg[4]=t_black) then begin
           menu_check(a_menu,t_black,true);
           menu_check(a_menu,t_white,false);
           jinit:=false;
           if plyr=1 then begin
             plyr:=-1;
             if not over then begin
               vixbrd:=brd;
               alphbet;
               print_board;
             end;
           end;
         end
         else if (msg[4]=t_white) then begin
           jinit:=false;
           menu_check(a_menu,t_black,false);
           menu_check(a_menu,t_white,true);
           if plyr=-1 then begin
             plyr:=1;
             if not over then begin
               vixbrd:=brd;
               alphbet;
               print_board;
             end;
           end;
         end;
       end;
       if (which=E_Message) and (msg[3]=title2) then begin
         menu_normal(a_menu,msg[3]);
         for c:=0 to 6 do begin
           menu_check(a_menu,level[c],false);
           if (msg[4]=level[c]) then begin
             case c of
               0:timelim:=0;
               1:timelim:=15;
               2:timelim:=60;
               3:timelim:=150;
               4:timelim:=600;
               5:timelim:=3600;
               6:timelim:=14400;
             end;
             if c=0 then
              dmax:=4
             else
              dmax:=MAX;
             menu_check(a_menu,level[c],true);
           end;
         end;
       end;
       until (which=E_Message) and (msg[4]=quit);
     end;
50:  quit_prg;
   end.
