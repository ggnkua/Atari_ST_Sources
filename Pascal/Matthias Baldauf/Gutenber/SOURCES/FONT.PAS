{ Font-Editor ist Teil des Programmpakets      }
{ GUTENBERG-DRUCKER fÅr ATARI ST Computer      }
{                                              }
{ FONT.PRG (c) July 1986 by MKB-Soft M.Baldauf }
{                                              }
{ letzte énderung : 02.05.1987                 }

{$U70}
program FONT_EDIT;

CONST  mu_mesag     = 16;
       mu_button    = 2;

{ Das Include File FONT.I enthÑlt Werte die vom RSC kommen }

{$I FONT.I}

TYPE in_type   = ARRAY[0..10] OF integer;
     out_type  = ARRAY[0..99] OF integer;
     stringtyp = PACKED ARRAY[1..21] OF char;
     zeiltyp   = PACKED ARRAY[1..60] OF char;
     nulldrei  = ARRAY[0..3] OF integer;
     mgbuftyp  = ARRAY[0..7] OF integer;
     text_type = PACKED ARRAY [0..39] OF char;
     pxy_type  = ARRAY[0..7] OF integer;
     grect     = RECORD
                  g_x:integer;
                  g_y:integer;
                  g_w:integer;
                  g_h:integer;
                 END;
     ted1 = PACKED RECORD
                    te_ptext:long_integer;
                    te_ptmplt:long_integer;
                    te_pvalid:long_integer;
                    te_font:integer;
                    te_junk1:integer;
                    te_just:integer;
                    te_color:integer;
                    te_junk2:integer;
                    te_thickness:integer;
                    te_txtlen:integer;
                    te_tmplen:integer
                   END;

     tedinfo = RECORD
                CASE boolean OF
                 FALSE: (ted_tree:long_integer);
                 TRUE : (p_ted:^ted1)
               END;
     ob1 = PACKED RECORD
                   ob_next:integer;
                   ob_head:integer;
                   ob_tail:integer;
                   ob_type:integer;
                   ob_flags:integer;
                   ob_state:integer;
                   ob_spec:long_integer;
                   ob_x:integer;
                   ob_y:integer;
                   ob_width:integer;
                   ob_height:integer
                  END;

     object_typ = RECORD
               CASE boolean OF
                FALSE: (object_tree:long_integer);
                TRUE : (p_obj:^ob1)
              END;

     copy_type = RECORD
                   address:long_integer;
                   wort:array[2..9] of integer;
                 END;

     fs_type   = PACKED ARRAY [1..39] OF char;
     ch_type   = PACKED ARRAY [1..150] OF char;

     spritetyp =  RECORD               { Record in dem Daten fÅr die beiden - }
               x_spot:integer;         { Icons abgelegt werden }
               y_spot:integer;
               format:integer;
               bcolor:integer;
               fcolor:integer;
               mask: ARRAY [0..15]
                      OF RECORD
                           background:integer;
                           foreground:integer;
                         END
             END;

VAR  handle,w_handle,dummy:integer;
     xdesk,ydesk,wdesk,hdesk:integer;
     mausx,mausy,ready:integer;
     modus:integer;
     l_intin:in_type;
     l_out  :out_type;
     mgbuf:mgbuftyp;
     menu_tree:long_integer;
     fs_iexbutton:boolean;
     fs_iinpath,fs_iinsel:fs_type;
     obj_tree:long_integer;
     laenge:integer;
     infozeil:zeiltyp;

     a1: ARRAY [0..100] OF integer;
     sprite1 : spritetyp;
     sprite2 : spritetyp;
     a:char;
     i:integer;
     str:string;
     dateiname:string;
     pxy:pxy_type;
     pos: ARRAY[1..4,1..4] OF integer;

     sourc,dest:copy_type;
     screen_sourc,screen_dest:long_integer;
     select : integer;
     select_x,select_y:integer;
     esc:char;

     font: ARRAY[1..250,1..13] OF long_integer;
     font_pr : ARRAY[1..2,1..250,1..13] OF integer;

     mark_li,mark_re,
     mark_ob,mark_un: integer;
     mark_stat : integer;

     potenz : array[0..15] of long_integer;
     potenz_w : array[0..7] of integer;
     
     pr_init,pr_vor_halb,pr_vor_acht,pr_vor_norm,
     pr_hrg_norm,pr_hrg_dopp:string[10];


procedure vro_cpyfm(handle,mode:integer;var xy:pxy_type;
                    var sourc,dest:copy_type);
C;
procedure appl_init;
C;
procedure appl_exit;
C;
procedure rsrc_free;
C;
function graf_handle(var gl_wchar,gl_hchar,gl_wbox,gl_hbox:integer):integer;
C;
function wind_create(wtype,w1,w2,w3,w4:integer):integer;
C;
function evnt_multi(t,i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12:integer;
                    var mgbuf:mgbuftyp;
                    j1,j2:integer;
                    var k1,k2,k3,k4,k5,k6:integer):integer;
C;
procedure v_opnvwk(var wi:in_type; var handle:integer; var wo:out_type);
C;
procedure graf_mouse(i:integer);
C;
procedure wind_get(i,j:integer; var x,y,w,h:integer);
C;
procedure wind_calc(i,wtype,w1,w2,w3,w4:integer; var j,k,l,m: integer);
C;
procedure wind_set(handle,i:integer;var text:zeiltyp;j,k:integer);
C;
procedure v_gtext(handle,k,l:integer;var t:string);
C;
procedure wind_open(handle,w1,w2,w3,w4:integer);
C;
procedure v_clsvwk(handle:integer);
C;
procedure wind_close(handle:integer);
C;
procedure wind_delete(handle:integer);
C;
procedure vsf_interior(handle,i:integer);
C;
procedure vsf_color(handle,i:integer);
C;
procedure vswr_mode(handle,i:integer);
C;
procedure evnt_button(i,j,k:integer; var mausx,mausy,l,m:integer);
C;
procedure vs_clip(handle,i:integer; var t:nulldrei);
C;
procedure v_bar(handle:integer; var t:nulldrei);
C;
procedure graf_growbox(i,j,k,l,m1,m2,m3,m4:integer);
C;
procedure graf_shrinkbox(i,j,k,l,m1,m2,m3,m4:integer);
C;
procedure vsf_style(handle,i:integer);
C;
function rsrc_load(var title:stringtyp):integer;
C;
function rsrc_gaddr(i,j:integer; var menu_tree:long_integer):integer;
C;
procedure menu_bar(m:long_integer; k:integer);
C;
procedure menu_tnormal(m:long_integer; k,l:integer);
C;
function form_alert(i:integer; var l:ch_type):integer;
C;
procedure form_dial(i,j,k,l,m,m1,m2,m3,m4:integer);
C;
procedure form_center(i:long_integer; var m1,m2,m3,m4:integer);
C;
procedure objc_change(i:long_integer; j,l,m1,m2,m3,m4,m,k:integer);
C;
function form_do(i:long_integer; m:integer):integer;
C;
procedure objc_draw(i:long_integer; k,j,m1,m2,m3,m4:integer);
C;
function rc_intersect(var i,j:grect):integer;
C;
procedure wind_update(i:integer);
C;
function fsel_input(var pfad1:fs_type; var filename1:fs_type;
                     var button1:boolean):boolean;
C;
procedure menu_ienable(m_tree:long_integer; m_item,m_enable:integer);
C;
function getrez:integer;
xbios(4);
function logbase:long_integer;
xbios(3);
function malloc(size:long_integer):long_integer;
gemdos($48);


{********************************************************
 **  Text schreiben mit der LINEA Funktion 'PUT_CHAR'  **
 ********************************************************}
procedure set_text(zeile:string; x,y:integer);
var i:integer;
begin
  for i := 1 to length(zeile) do
    put_char(zeile[i],x+(i*8)-1,y,1);
end;

{*************************************************
 **  Umwandlung STRING -> PACKED ARRAY OF CHAR  **
 *************************************************}
procedure str_to_char(str:string; var pa:ch_type);
var i,len:integer;
begin
  len := length(str);
  for i := 1 to len do pa[i] := str[i];
  pa[len+1] := chr(0);
end;

{*************************************************
 **  Umwandlung PACKED ARRAY OF CHAR -> STRING  **
 *************************************************}
procedure char_to_str(pa:fs_type; var str:string);
var i:integer;
begin
  str := '';
  i := 1;
  while pa[i] <> chr(0) do
    begin
      str := concat(str,pa[i]);
      i := i + 1;
    end;
end;

{*************************************************
 **  LINIE ziehen mit der LINEA Routine 'LINE'  **
 *************************************************}
procedure linef(x1,y1,x2,y2:integer);
begin
  line(x1,y1,x2,y2,1,0,0,0,$FFFF,0);
end;

{**************************************
 **  INFOZEILE in das Window setzen  **
 **************************************}
procedure set_infozeil(st:string);     { Infozeile des Windows setzen }
var i:integer;
  procedure str_to_char(str:string; var pa:zeiltyp);
  var i,len:integer;
  begin
    len := length(str);
    for i := 1 to len do pa[i] := str[i];
    pa[len+1] := chr(0);
  end;
begin
  str_to_char(st,infozeil);
  wind_set(w_handle,3,infozeil,0,0);
end;

{*****************************************
 **  angewÑhltes Feld kenntlich machen  **
 *****************************************}
procedure select_feld(spalte,zeile:integer);
var i,n,flag:integer;
    clip:nulldrei;
begin
  clip[0] := ((spalte-1)*9+pos[1,1])+1;
  clip[1] := ((zeile-1)*9+pos[1,2])+1;
  clip[2] := clip[0] + 7;
  clip[3] := clip[1] + 7;
  vsf_color(handle,modus-1);
  vsf_interior(handle,1);
  v_bar(handle,clip);
end;

{********************************************
 **  angewÑhltes Zeichen kenntlich machen  **
 ********************************************}
procedure select_char(which:integer);
var i,n,spalte,zeile:integer;
    clip:nulldrei;
begin
  zeile := trunc(which/26)+1;
  spalte := which-((zeile-1)*26);
  clip[0] := ((spalte-1)*16+pos[2,1]);
  clip[1] := ((zeile-1)*32+pos[2,2]);
  clip[2] := clip[0] + 16;
  clip[3] := clip[1] + 12;
  select_x := clip[0] +2;
  select_y := clip[1] +14;
  hide_mouse;
  vswr_mode(handle,3);
  vsf_color(handle,1);
  vsf_interior(handle,1);
  v_bar(handle,clip);
  vswr_mode(handle,1);
  show_mouse;
end;

{***********************************
 **  Rechteck mit LINEA zeichnen  **
 ***********************************}
procedure rechteck(x,y,x1,y1:integer);
  procedure linef(x1,y1,x2,y2:integer);
  begin
    line(x1,y1,x2,y2,1,0,0,0,$FFFF,2);
  end;
begin
  linef(x,y,x1,y);
  linef(x1,y,x1,y1);
  linef(x1,y1,x,y1);
  linef(x,y1,x,y);
end;

{*********************************************
 **  Soll gelîscht oder gezeichnet werden?  **
 *********************************************}
procedure set_modus;
var i:integer;
begin
 hide_mouse;
 rechteck(pos[modus+2,1]-1,pos[modus+2,2]-1,pos[modus+2,3]+1,pos[modus+2,4]+1);
 rechteck(pos[modus+2,1]-2,pos[modus+2,2]-2,pos[modus+2,3]+2,pos[modus+2,4]+2);
 show_mouse;
end;

{**************************************************************
 **  Hier wird in der Zeichenmatrix vom Benutzer herumgemalt **
 **************************************************************}
procedure feld(x,y:integer);
var i,n,flag,spalte,zeile,sel,mem,x1,y1:integer;
    clip:nulldrei;
begin
  if ((x>pos[1,1])and(x<pos[1,3])and(y>pos[1,2])and(y<pos[1,4])) then
    begin
      x1 := x - pos[1,1];
      y1 := y - pos[1,2];
      spalte := trunc(x1/9)+1;
      zeile := trunc(y1/9)+1;
      hide_mouse;
      select_feld(spalte,zeile);
      put_pixel(select_x+spalte-1,select_y+zeile-1,modus-1);
      show_mouse;
    end;
  if ((x>pos[2,1])and(x<pos[2,3])and(y>pos[2,2])and(y<pos[2,4])) then
    begin
      x1 := x - pos[2,1];
      y1 := y - pos[2,2];
      spalte := trunc(x1/16)+1;
      zeile := trunc(y1/32)+1;
      select_char(select);
      select := (zeile-1)*26 + spalte;
      select_char(select);
      hide_mouse;
      mem := modus;
      for i := 1 to 16 do
        for n := 1 to 12 do
          begin
            modus := 1;
            select_feld(n,i);
            modus := 2;
            flag := get_pixel(select_x+n-1,select_y+i-1);
            if flag = 1 then
              select_feld(n,i);
          end;
       modus := mem;
       set_infozeil(' ');
       show_mouse;
    end;
  if ((x>pos[3,1])and(x<pos[3,3])and(y>pos[3,2])and(y<pos[3,4])) then
    begin
      if modus = 2 then
         begin
           set_modus;
           modus := 1;
           set_modus;
         end;
    end;
  if ((x>pos[4,1])and(x<pos[4,3])and(y>pos[4,2])and(y<pos[4,4])) then
    begin
      if modus = 1 then
         begin
           set_modus;
           modus := 2;
           set_modus;
         end;
    end;
end;

{****************************************************
 **  Kopieren eines Blocks : SOURCE -> DESTINATION **
 ****************************************************}
procedure sourc_dest(x,y,w,h:integer);
var i : integer;
begin
  hide_mouse;
  pxy[0] := x;   pxy[1] := y;
  pxy[2] := x+w; pxy[3] := y+h;
  for i := 4 to 7 do
    pxy[i] := pxy[i-4];
  vro_cpyfm(handle,3,pxy,sourc,dest);
  show_mouse;
end;

{******************************************************
 **  Kopieren eines Blocks :  DESTINATION -> SOURCE  **
 ******************************************************}
procedure dest_sourc(x,y,w,h:integer);
var i : integer;
begin
  hide_mouse;
  pxy[0] := x;   pxy[1] := y;
  pxy[2] := x+w; pxy[3] := y+h;
  for i := 4 to 7 do
    pxy[i] := pxy[i-4];
  vro_cpyfm(handle,3,pxy,dest,sourc);
  show_mouse;
end;

{***********************************************************************
 **  Die Folgenden Prozeduren dienen zum Setzen der Markierungslinien **
 ***********************************************************************}
procedure desel_hline(which:integer);
begin
  line(pos[1,1],pos[1,2]+which*9,pos[1,3],pos[1,2]+which*9,1,0,0,0,$AAAA,0);
end;

procedure desel_vline(which:integer);
begin
  line(pos[1,1]+which*9,pos[1,2],pos[1,1]+which*9,pos[1,4],1,0,0,0,$AAAA,0);
end;

procedure sel_hline(which:integer);
begin
  linef(pos[1,1],pos[1,2]+which*9,pos[1,3],pos[1,2]+which*9);
end;

procedure sel_vline(which:integer);
begin
  linef(pos[1,1]+which*9,pos[1,2],pos[1,1]+which*9,pos[1,4]);
end;

{********************************************************************
 **  Vor dem Programmstart muû schon einiges Initialisiert werden  **
 ********************************************************************}
procedure init;
var i,n,l,x,y,error:integer;
    tree:long_integer;
    fil:text;
function getdrv:integer;gemdos($19);
begin
  hide_mouse;
  fs_iinpath := 'A:\*.ZSZ                               ';   { 39 char }
  fs_iinpath[9] := chr(0);
  fs_iinsel := '                                       ';   { 39 char }
  fs_iinsel[1] := chr(0);
  fs_iinpath[1] := chr(getdrv+1+64);
  sourc.address := screen_sourc;
  dest.address := screen_dest;
  sourc.wort[2] := 640;
  sourc.wort[3] := 400;
  sourc.wort[4] := 40;
  sourc.wort[5] := 0;
  sourc.wort[6] := 1;
  sourc.wort[7] := 0;
  sourc.wort[8] := 0;
  sourc.wort[9] := 0;
  for i := 2 to 9 do
    dest.wort[i] := sourc.wort[i];
  { Punkt loeschen }
  pos[3,1] := 20-1;           pos[3,2] := 150-1;
  pos[3,3] := pos[3,1]+18; pos[3,4] := pos[3,2]+18;
  rechteck(pos[3,1],pos[3,2],pos[3,3],pos[3,4]);
  { Punkt setzen }
  pos[4,1] := 20-1;           pos[4,2] := 174-1;
  pos[4,3] := pos[4,1]+18; pos[4,4] := pos[4,2]+18;
  rechteck(pos[4,1],pos[4,2],pos[4,3],pos[4,4]);

  { Jetzt kommen die ICON - Daten fÅr 2 Icons }

  WITH sprite1 DO
    BEGIN
      x_spot := 0;
      y_spot := 0;
      format := 0;
      bcolor := 1;
      fcolor := 1;
      mask[0].foreground := 0;
      mask[0].background := 0;
      mask[1].foreground := $c800;
      mask[1].background := 0;
      mask[2].foreground := $c800;
      mask[2].background := 0;
      mask[3].foreground := 21504;
      mask[3].background := 0;
      mask[4].foreground := 25600;
      mask[4].background := 0;
      mask[5].foreground := 12800;
      mask[5].background := 0;
      mask[6].foreground := 12800;
      mask[6].background := 0;
      mask[7].foreground := 5376;
      mask[7].background := 0;
      mask[8].foreground := 3328;
      mask[8].background := 0;
      mask[9].foreground := 3200;
      mask[9].background := 0;
      mask[10].foreground := 3456;
      mask[10].background := 0;
      mask[11].foreground := 2016;
      mask[11].background := 0;
      mask[12].foreground := 2032;
      mask[12].background := 0;
      mask[13].foreground := 1016;
      mask[13].background := 0;
      mask[14].foreground := 126;
      mask[14].background := 0;
      mask[15].foreground := 0;
      mask[15].background := 0;
    END;
  WITH sprite2 DO
    BEGIN
      x_spot := 0;
      y_spot := 0;
      format := 0;
      bcolor := 1;
      fcolor := 1;
      mask[0].foreground := 0;
      mask[0].background := 0;
      mask[1].foreground := 0;
      mask[1].background := 0;
      mask[2].foreground := 255;
      mask[2].background := 0;
      mask[3].foreground := 475;
      mask[3].background := 0;
      mask[4].foreground := 877;
      mask[4].background := 0;
      mask[5].foreground := 1455;
      mask[5].background := 0;
      mask[6].foreground := 4090;
      mask[6].background := 0;
      mask[7].foreground := 4156;
      mask[7].background := 0;
      mask[8].foreground := 8280;
      mask[8].background := 0;
      mask[9].foreground := $4090;
      mask[9].background := 0;
      mask[10].foreground := $ff20;
      mask[10].background := 0;
      mask[11].foreground := $8140;
      mask[11].background := 0;
      mask[12].foreground := $8180;
      mask[12].background := 0;
      mask[13].foreground := $ff00;
      mask[13].background := 0;
      mask[14].foreground := 0;
      mask[14].background := 0;
      mask[15].foreground := 0;
      mask[15].background := 0;
    END;

  pos[1,1] := 50;             pos[1,2] := 100;
  pos[1,3] := pos[1,1] + 108; pos[1,4] := pos[1,2] + 144;
  x := pos[1,1];  y := pos[1,2];
  for i := 1 to 17 do
    begin
      desel_hline(i-1);
      y := y + 9;
    end;
  x := pos[1,1];  y := pos[1,2];
  for i := 1 to 13 do
    begin
      desel_vline(i-1);
      x := x + 9;
    end;
  pos[2,1] := 200;             pos[2,2] := 65;
  pos[2,3] := pos[2,1] + 400; pos[2,4] := pos[2,2] + 319;
  x := pos[2,1]; y := pos[2,2];
  for i := 1 to 10 do
    begin
      linef(x,y,x+pos[2,3]-pos[2,1],y);
      y := y + 11;
      linef(x,y,x+pos[2,3]-pos[2,1],y);
      y := y + 20;
      linef(x,y,x+pos[2,3]-pos[2,1],y);
      y := y + 1;
    end;
  x := pos[2,1]; y := pos[2,2];
  for i := 1 to 26 do
    begin
      linef(x,y,x,y+pos[2,4]-pos[2,2]);
      x := x + 16;
    end;
  l := 0;
  y := pos[2,2] + 2;
  for i := 1 to 10 do
    begin
      x := pos[2,1] + 4;
      for n := 1 to 25 do
        begin
          l := l + 1;
          put_char(chr(l),x,y,1);
          x := x + 16;
        end;
      y := y + 32;
    end;
  select := 66;
  select_char(select);
  modus := 2;
  show_mouse;
  mark_stat := 0;    { Markierung ist erstmal ausgeschaltet }
  mark_li := 1;
  mark_re := 11;
  mark_ob := 1;
  mark_un := 15;
  reset(fil,'FONT.DAT');    { Mal sehen, ob Markierungsdaten abgesaved sind }
  if not eof(fil) then
    begin
      readln(fil,mark_li);
      readln(fil,mark_re);
      readln(fil,mark_un);
      readln(fil,mark_ob);
      readln(fil,mark_stat);
      close(fil);
    end;
  if mark_stat = 1 then     { Die Markierungen sollen also doch eingeschaltet }
    begin                   { werden }
      sel_vline(mark_re);
      sel_vline(mark_li);
      sel_hline(mark_un);
      sel_hline(mark_ob);
    end;
  error := rsrc_gaddr(0, MARKE, tree);
  objc_change(tree,MARKAUS+mark_stat,0,xdesk,ydesk,wdesk,hdesk,1,0);

                { Druckertreiber }
  pr_init := concat(chr(27),chr(64));
  pr_vor_halb := concat(chr(27),chr(51),chr(1));
  pr_vor_acht := concat(chr(27),chr(65),chr(8));
  pr_hrg_dopp := concat(chr(27),chr(76));
  pr_hrg_norm := concat(chr(27),chr(75));
  pr_vor_norm := concat(chr(27),chr(50));
              { Druckertreiber-Ende }
  potenz[0] := 1;
  potenz[1] := 2;
  potenz[2] := 4;
  potenz[3] := 8;
  potenz[4] := 16;
  potenz[5] := 32;
  potenz[6] := 64;
  potenz[7] := 128;
  potenz[8] := 256;
  potenz[9] := 512;
  potenz[10] := 1024;
  potenz[11] := 2048;
  potenz[12] := 4096;
  potenz[13] := 8192;
  potenz[14] := 16384;
  potenz[15] := 32768;
  potenz_w[0] := 1;
  potenz_w[1] := 2;
  potenz_w[2] := 4;
  potenz_w[3] := 8;
  potenz_w[4] := 16;
  potenz_w[5] := 32;
  potenz_w[6] := 64;
  potenz_w[7] := 128;
end;

{************************************************************
 **  Nun kommen ein paar Routinen fÅr das WINDOW-Handling  **
 ************************************************************}
procedure set_clip(x,y,w,h:integer);
var clip:nulldrei;
begin
  clip[0] := x;
  clip[1] := y;
  clip[2] := x+w;
  clip[3] := y+h;
  vs_clip(handle,1,clip);
end;

procedure clear_window;
var clip:nulldrei;
begin
  hide_mouse;
  clip[0] := xdesk;
  clip[1] := ydesk+36;
  clip[2] := xdesk+wdesk;
  clip[3] := ydesk+hdesk;
  vsf_color(handle,0);
  vsf_interior(handle,1);
  v_bar(handle,clip);
  show_mouse;
end;

procedure open_work;
 var i,gr_1,gr_2,gr_3,gr_4:integer;
 begin
  appl_init;
  handle := graf_handle(gr_1,gr_2,gr_3,gr_4);
  for i:=0 to 9 do
    l_intin[i] := 1;
  l_intin[10] := 2;
  v_opnvwk(l_intin, handle, l_out);
 end;

procedure close_window;
begin
  menu_bar(menu_tree,0);
  rsrc_free;
  wind_close(w_handle);
  graf_shrinkbox(xdesk+wdesk DIV 2,ydesk+hdesk DIV 2,
                   0,0,xdesk,ydesk,wdesk,hdesk);
  wind_delete(w_handle);
  v_clsvwk(handle);
  appl_exit;
end;

procedure open_window;
type titletyp = packed array[1..22] of char;
var wi_title:titletyp;
    wi_kind:integer;
     procedure wind_set(x,i:integer;var title:titletyp;j,k:integer);
     C;
 begin
  wi_kind := 1+16;  (* Namens + Infozeile *)
  hide_mouse;
  wind_get(0,4,xdesk,ydesk,wdesk,hdesk);
  w_handle := wind_create(wi_kind,xdesk,ydesk,wdesk,hdesk);
  wi_title := ' FONT - EDITOR        ';
  wi_title[16] := chr(0);
  wi_title[17] := chr(0);
  wind_set(w_handle,2,wi_title,0,0);
  graf_growbox(xdesk+wdesk DIV 2,ydesk+hdesk DIV 2,
                      0,0,xdesk,ydesk,wdesk,hdesk);
  clear_window;
  wind_open(w_handle,xdesk,ydesk,wdesk,hdesk);
  set_infozeil(' (c) Juli 1986 by Matthias Baldauf, Version 1.0  3/87');
  show_mouse;
 end;

{***********************************************************
 **  Warten bis Maustaste gedrÅckt bzw. losgelassen wird  **
 ***********************************************************}
procedure click;     (* wartet bis linke Maustaste gedrueckt wird *)
begin
  evnt_button(1,1,1,mausx,mausy,dummy,dummy);
end;

procedure un_click;     (* wartet bis linke Maustaste losgelassen wird *)
begin
  evnt_button(1,1,0,mausx,mausy,dummy,dummy);
end;

{**************************************************
 **  Manchmal ist auch eine ALERT-Box notwendig  **
 **************************************************}
function alert(art:integer; text:string):integer;
var al_txt:ch_type;
begin
  str_to_char(text,al_txt);
  alert := form_alert(art,al_txt);
end;

{**********************************************************
 **  Auch das RESOURCE-FILE will extra eingeladen werden **
 **********************************************************}
function load_rsc:integer;
var error:integer;
    title:stringtyp;
begin
 load_rsc := 0;
 title := 'FONT.RSC             ';
 title[9] := chr(0);
 error := rsrc_load(title);
 if error = 0 then
   begin
     graf_mouse(0);
     str:='[1][Raubkopierer, was?|Ohne .RSC lÑuft das|Programm nicht.][ PECH ]';
     ready:=alert(1,str);
     load_rsc := 1;
   end;
 error := rsrc_gaddr(0,0,menu_tree);
 if error = 0 then
   begin
     graf_mouse(0);
     str:='[1][Es ist ein Fehler|mit dem .RSC-File|aufgetreten !!][SCHADE]';
     ready:=alert(1,str);
     load_rsc := 1;
   end;
end;

{**************************************************
 **  Object-Button wird angewÑhlt bzw. gelîscht  **
 **************************************************}
procedure desel_obj(tree:long_integer; which:integer);
BEGIN
  objc_change(tree,which,0,xdesk,ydesk,wdesk,hdesk,0,1);
END;

procedure sel_obj(tree:long_integer; which:integer);
BEGIN
  objc_change(tree,which,0,xdesk,ydesk,wdesk,hdesk,1,1);
END;

{************************************************
 **  Diese Routine regelt das OBJECT-Handling  **
 ************************************************}
function hndl_dial(tree:long_integer; def, x,y,w,h:integer):integer;
VAR obj,xdial,ydial,wdial,hdial:integer;
BEGIN
  form_center(tree, xdial,ydial,wdial,hdial);
  sourc_dest(xdial,ydial,wdial,hdial);
  form_dial(0,x,y,w,h,xdial,ydial,wdial,hdial);
  objc_draw(tree,0,30,xdial,ydial,wdial,hdial);
  obj := form_do(tree,def);
  hndl_dial := obj;
  form_dial(3,x,y,w,h,xdial,ydial,wdial,hdial);
  desel_obj(tree,obj);
  dest_sourc(xdial,ydial,wdial,hdial);
END;

procedure about_prg;
var tree:long_integer;
    error,obj:integer;
begin
  set_infozeil(' Informationen');
  error := rsrc_gaddr(0, UEBER, tree);
  obj := hndl_dial(tree,0,320,200,1,1);
  set_infozeil(' ');
end;

{*****************************************************************
 **  Eine Steuerung einer File-Select-Box ist auch interessant  **
 *****************************************************************}
procedure show_file(iinsel,iinpath:fs_type);
var ende:boolean;
    tree:long_integer;
    xdial,ydial,wdial,hdial:integer;
    error,i:integer;
    fn:fs_type;
  function setdrv(drv:integer):integer;gemdos($0e);
  function chdir(var fn:fs_type):integer;
  gemdos($3b);
begin
  xdial := 100; ydial := 50;
  wdial := 400; hdial := 330;
  sourc_dest(xdial,ydial,wdial,hdial);
  ende := fsel_input(iinpath, iinsel, fs_iexbutton);
  if fs_iexbutton = TRUE then
    begin
      char_to_str(iinsel,str);
      dateiname := str;
      fs_iinpath := iinpath;
      fs_iinsel := iinsel;
      error := setdrv(ord(fs_iinpath[1])-64-1);
      fn:=('\\                                     ');
      fn[3]:=chr(0);
      error:=chdir(fn);
      i:=3;
      while fs_iinpath[i]<>'*' do
        begin
          fn[i-2]:=fs_iinpath[i];
          i:=i+1;
        end;
      fn[i-2]:=chr(0);
      error:=chdir(fn);
    end;
  dest_sourc(xdial,ydial,wdial,hdial);
end;

{******************************************************************
 **  Der Zeichensatz muû auch auf den Bildschirm gebracht werden **
 ******************************************************************}
procedure recompile_font;
var i,n,zeile,spalte:integer;
    zaehler,status:integer;
    flag : long_integer;
begin
  hide_mouse;
  zaehler := 0;
    for zeile := 1 to 10 do
     for spalte := 1 to 25 do
       begin
        zaehler := zaehler + 1;
        select_x := ((spalte-1)*16+pos[2,1])+2;
        select_y := ((zeile-1)*32+pos[2,2])+14;
        for n := 1 to 12 do
          begin
            for i := 1 to 16 do
              begin
                flag := font[zaehler,n] - potenz[16-i];
                if flag >= 0 then
                  begin
                    font[zaehler,n] := flag;
                    put_pixel(select_x+n-1,select_y+i-1,1);
                  end
                else
                  put_pixel(select_x+n-1,select_y+i-1,0);
              end;
          end;
      end;
  show_mouse;
end;

{*********************************************************************
 **  Der Zeichensatz wird vom Bildschirm geholt und fÅr das Absaven **
 **  oder Ausdrucken vorbereitet                                    **
 *********************************************************************}
procedure compile_font;
var i,n,zeile,spalte:integer;
    zaehler,status:integer;
begin
  hide_mouse;
  zaehler := 0;
    for zeile := 1 to 10 do
     for spalte := 1 to 25 do
       begin
        zaehler := zaehler + 1;
        select_x := ((spalte-1)*16+pos[2,1])+2;
        select_y := ((zeile-1)*32+pos[2,2])+14;
        for n := 1 to 12 do
          begin
            font[zaehler,n] := 0;
            for i := 16 downto 1 do
              begin
                status := get_pixel(select_x+n-1,select_y+i-1);
                if status = 1 then
                  begin
                    font[zaehler,n] := font[zaehler,n] + potenz[16-i];
                  end;
              end;
          end;
      end;
  show_mouse;
end;

{***************************************************
 **  Einladen eines Zeichensatzes in den Speicher **
 ***************************************************}
procedure load_font;
var i,n,mem,flag:integer;
    datei:file of long_integer;
begin
  show_file(fs_iinsel,fs_iinpath);
  set_infozeil(' Zeichensatz... laden  --Bitte warten--');
  if fs_iexbutton = TRUE then
    begin
      select_char(select);
      graf_mouse(2);
      reset(datei,dateiname);
      if not eof(datei) then
        begin
          menu_ienable(menu_tree,SAVE,1);
          for i := 1 to 250 do
            for n := 1 to 12 do
              begin
                font[i,n] := datei^;
                get(datei);
              end;
          graf_mouse(0);
          set_infozeil(' Zeichensatz... konvertieren  --Bitte warten--');
          recompile_font;
          select_char(select);
          mem := modus;
          hide_mouse;
          for i := 1 to 16 do
            for n := 1 to 12 do
              begin
                modus := 1;
                select_feld(n,i);
                modus := 2;
                flag := get_pixel(select_x+n-1,select_y+i-1);
                if flag = 1 then
                  select_feld(n,i);
              end;
          show_mouse;
          modus := mem;
        end
      else
        begin
          str:='[1][Diesen Zeichensatz|habe ich nicht|gefunden !][ ABBRUCH ]';
          ready:=alert(1,str);
        end;
      close(datei);
    end;
  set_infozeil(' ');
end;

{***************************************
 **  Abspeichern eines Zeichensatzes  **
 ***************************************}
procedure save_font;
var i,n,mem,flag:integer;
    datei:file of long_integer;
begin
  select_char(select);
  set_infozeil(' Zeichensatz konvertieren    --Bitte warten--');
  compile_font;
  graf_mouse(2);
  set_infozeil(' Zeichensatz abspeichern    --Bitte warten--');
  rewrite(datei,dateiname);
  for i := 1 to 250 do
    for n := 1 to 12 do
      begin
        datei^ := font[i,n];
        put(datei);
      end;
  close(datei);
  set_infozeil(' ');
  graf_mouse(0);
  select_char(select);
  mem := modus;
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 1;
        select_feld(n,i);
        modus := 2;
        flag := get_pixel(select_x+n-1,select_y+i-1);
        if flag = 1 then
          select_feld(n,i);
      end;
   modus := mem;
end;

procedure save_as;
begin
  set_infozeil(' Zeichensatz abspeichern unter dem Namen ...');
  show_file(fs_iinsel,fs_iinpath);
  if fs_iexbutton = TRUE then
    begin
      save_font;
    end;
  set_infozeil(' ');
end;

{***************************************************
 **  Zeichensatzes fÅr den NLQ-Druck vorbereiten  **
 ***************************************************}
procedure convert_nlq;
var i,n,g,z,za:integer;
    flag:long_integer;
begin
  set_infozeil(' Zeichensatz ausdrucken  --Convert to NLQ--');
  for i := 1 to 250 do
    for n := 1 to 12 do
      begin
        font_pr[1,i,n] := 0;
        font_pr[2,i,n] := 0;
        za := 0;
        for z := 1 to 8 do
          begin
            za := za + 1;
            flag := font[i,n] - potenz[16-za];
            if flag >= 0 then
              begin
                font[i,n] := flag;
                g := 8-z;
                font_pr[1,i,n] := font_pr[1,i,n] +
                      potenz_w[g];
              end;
            za := za + 1;
            flag := font[i,n] - potenz[16-za];
            if flag >= 0 then
              begin
                font[i,n] := flag;
                g := 8-z;
                font_pr[2,i,n] := font_pr[2,i,n] +
                      potenz_w[g];
              end;
          end;
      end;
end;

{*******************************************************
 **  Zeichensatzes fÅr den Einfach-Druck vorbereiten  **
 *******************************************************}
procedure convert_norm;
var i,n,g,z:integer;
    flag:long_integer;
begin
  set_infozeil(' Zeichensatz ausdrucken  --Convert to NORMAL--');
  for i := 1 to 250 do
    for n := 1 to 12 do
      begin
        font_pr[1,i,n] := 0;
        font_pr[2,i,n] := 0;
        for z := 1 to 8 do
          begin
            flag := font[i,n] - potenz[16-z];
            if flag >= 0 then
              begin
                font[i,n] := flag;
                g := 8-z;
                font_pr[1,i,n] := font_pr[1,i,n] +
                      potenz_w[g];
              end;
          end;
        for z := 9 to 16 do
          begin
            flag := font[i,n] - potenz[16-z];
            if flag >= 0 then
              begin
                font[i,n] := flag;
                g := 16-z;
                font_pr[2,i,n] := font_pr[2,i,n] +
                      potenz_w[g];
              end;
          end;
      end;
end;

{*****************************************
 **  Kompletten Zeichensatz ausdrucken  **
 *****************************************}
procedure print_font;
var tree:long_integer;
    error,obj,ready,i,n,z,g,count:integer;
    zaehler:integer;
 function bcostat(dev:integer):integer;bios(8);
begin
  esc := chr(27);
  set_infozeil(' Zeichensatz ausdrucken');
  error := rsrc_gaddr(0, DRUCKE, tree);
  obj := hndl_dial(tree,0,320,200,1,1);
  if obj <> ABBRUCH then
    begin
      str:='[1][Bitte schalten|Sie Ihren Drucker|ein !][OK|ABBRUCH]';
      ready:=alert(2,str);
      if ready = 1 then
        begin
          i := bcostat(0);
          if i = -1 then
            begin
              set_infozeil(' Zeichensatz ausdrucken  --Compile Font--');
              compile_font;
              graf_mouse(2);
              if obj = NLQ then convert_nlq
              else convert_norm;
              zaehler := 0;
              rewrite(output,'PRN:');
              write(pr_init);         { Drucker - Reset }
              set_infozeil(' Jetzt wird gedruckt  --Taste zum abbrechen--');
              i := 0;
              while ((i < 10) and (keypress <> true)) do
                begin
                  i := i + 1;
                  if obj = NLQ then
                    write(pr_vor_halb)   {Zeilenvorschub 1/2 Pixel}
                  else
                    write(pr_vor_acht);  { Zeilenvorschub 8 Pixel }
                  for g := 1 to 2 do
                    begin
                      if obj = NLQ then         {HRG 300 Spalten}
                        write(concat(pr_hrg_dopp,chr(44),chr(1))) {HRG doppelt}
                      else
                        write(concat(pr_hrg_norm,chr(44),chr(1)));{HRG einfach}
                      for n := 1 to 25 do
                        begin
                          zaehler := zaehler + 1;
                            for count := 1 to 12 do
                          write(chr(font_pr[g,zaehler,count]));
                        end;
                      if g = 1 then
                        begin
                          zaehler := zaehler - 25;
                          writeln;
                        end;
                    end;
                  writeln(pr_vor_norm);    {normal-Vorschub}
                end;
              rewrite(output,'CON:');
              graf_mouse(0);
            end
          else
            begin
              str:='[1][Bitte Drucker und|Kabel ÅberprÅfen !!][ABBRUCH]';
              ready:=alert(1,str);
            end;
        end;
    end;
  set_infozeil(' ');
end;

{*************************************************************************
 **  Die folgenden Prozeduren verÑndern (entsprechend ihrem Namen) die  **
 **  Zeichenmatrix entsprechend Ihren WÅnschen                          **
 *************************************************************************}
procedure v_spiegel;
var i,n,flag,mem:integer;
begin
  hide_mouse;
  mem := modus;
  set_infozeil(' Zeichen vertikal Spiegeln');
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 1;
        flag := get_pixel(select_x+n-1,select_y+i-1);
        if flag = 1 then modus := 2;
        put_pixel(100+n-1,300+i-1,modus-1);
      end;
  for i := 1 to 16 do
    for n := 12 downto 1 do
      begin
        modus := 1;
        flag := get_pixel(100+n-1,300+i-1);
        if flag = 1 then modus := 2;
        select_feld(13-n,i);
        put_pixel(select_x+13-n-1,select_y+i-1,modus-1);
      end;
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 1;
        put_pixel(100+n-1,300+i-1,modus-1);
      end;
  set_infozeil(' ');
  show_mouse;
  modus := mem;
end;

procedure h_spiegel;
var i,n,flag,mem:integer;
begin
  hide_mouse;
  mem := modus;
  set_infozeil(' Zeichen horizontal Spiegeln');
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 1;
        flag := get_pixel(select_x+n-1,select_y+i-1);
        if flag = 1 then modus := 2;
        put_pixel(100+n-1,300+i-1,modus-1);
      end;
  for i := 16 downto 1 do
    for n := 1 to 12 do
      begin
        modus := 1;
        flag := get_pixel(100+n-1,300+i-1);
        if flag = 1 then modus := 2;
        select_feld(n,17-i);
        put_pixel(select_x+n-1,select_y+17-i-1,modus-1);
      end;
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 1;
        put_pixel(100+n-1,300+i-1,modus-1);
      end;
  set_infozeil(' ');
  show_mouse;
  modus := mem;
end;

procedure fill_prg;
var i,n,mem:integer;
begin
  hide_mouse;
  mem := modus;
  set_infozeil(' Zeichenmatrix mit Punkte fÅllen');
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 2;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  set_infozeil(' ');
  show_mouse;
  modus := mem;
end;

procedure erase_prg;
var i,n,mem:integer;
begin
  hide_mouse;
  mem := modus;
  set_infozeil(' Zeichenmatrix lîschen');
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 1;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  set_infozeil(' ');
  show_mouse;
  modus := mem;
end;

procedure toggle_prg;
var i,n,flag,mem:integer;
begin
  hide_mouse;
  mem := modus;
  set_infozeil(' Zeichenmatrix invertieren');
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := 2;
        flag := get_pixel(select_x+n-1,select_y+i-1);
        if flag = 1 then modus := 1;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  set_infozeil(' ');
  show_mouse;
  modus := mem;
end;

procedure copy_prg;
var x1,y1,quit,i,n,mem:integer;
    von,von_x,von_y,nach,nach_x,nach_y:integer;
    x,y,spalte,zeile:integer;
begin
  quit := 0;
  mem := modus;
  select_char(select);
  set_infozeil(' Matrix kopieren von:');
  repeat
    click;
    x := mausx;
    y := mausy;
    if ((x>pos[2,1])and(x<pos[2,3])and(y>pos[2,2])and(y<pos[2,4])) then
      begin
        quit := 1;
        x1 := x - pos[2,1];
        y1 := y - pos[2,2];
        spalte := trunc(x1/16)+1;
        zeile := trunc(y1/32)+1;
        von := (zeile-1)*26 + spalte;
        select_char(von);
        von_x := select_x;
        von_y := select_y;
      end;
  until quit = 1;
  quit := 0;
  set_infozeil(' Matrix kopieren von .. nach:');
  un_click;
  repeat
    click;
    x := mausx;
    y := mausy;
    if ((x>pos[2,1])and(x<pos[2,3])and(y>pos[2,2])and(y<pos[2,4])) then
      begin
        quit := 1;
        x1 := x - pos[2,1];
        y1 := y - pos[2,2];
        spalte := trunc(x1/16)+1;
        zeile := trunc(y1/32)+1;
        nach := (zeile-1)*26 + spalte;
        select_char(nach);
        nach_x := select_x;
        nach_y := select_y;
      end;
  until quit = 1;
  hide_mouse;
  for i := 1 to 16 do
    for n := 1 to 12 do
      begin
        modus := get_pixel(von_x+n-1,von_y+i-1)+1;
        put_pixel(nach_x+n-1,nach_y+i-1,modus-1);
      end;
  show_mouse;
  set_infozeil(' ');
  modus := mem;
  select_char(von);
  select_char(nach);
  select_char(select);
end;

procedure move_up;
var i,n,mem:integer;
begin
  mem := modus;
  hide_mouse;
  set_infozeil(' Matrix nach oben verschieben');
  for i := 1 to 15 do
    for n := 1 to 12 do
      begin
        modus := get_pixel(select_x+n-1,select_y+i)+1;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  modus := 1;
  for n := 1 to 12 do
    begin
      select_feld(n,16);
      put_pixel(select_x+n-1,select_y+16-1,modus-1);
    end;
  set_infozeil(' ');
  modus := mem;
  show_mouse;
end;

procedure move_down;
var i,n,mem:integer;
begin
  mem := modus;
  hide_mouse;
  set_infozeil(' Matrix nach unten verschieben');
  for i := 16 downto 2 do
    for n := 1 to 12 do
      begin
        modus := get_pixel(select_x+n-1,select_y+i-2)+1;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  modus := 1;
  for n := 1 to 12 do
    begin
      select_feld(n,1);
      put_pixel(select_x+n-1,select_y+1-1,modus-1);
    end;
  set_infozeil(' ');
  modus := mem;
  show_mouse;
end;

procedure move_left;
var i,n,mem:integer;
begin
  mem := modus;
  hide_mouse;
  set_infozeil(' Matrix nach links verschieben');
  for i := 1 to 16 do
    for n := 1 to 11 do
      begin
        modus := get_pixel(select_x+n,select_y+i-1)+1;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  modus := 1;
  for i := 1 to 16 do
    begin
      select_feld(12,i);
      put_pixel(select_x+12-1,select_y+i-1,modus-1);
    end;
  set_infozeil(' ');
  modus := mem;
  show_mouse;
end;

procedure move_right;
var i,n,mem:integer;
begin
  mem := modus;
  hide_mouse;
  set_infozeil(' Matrix nach rechts verschieben');
  for i := 1 to 16 do
    for n := 12 downto 2 do
      begin
        modus := get_pixel(select_x+n-2,select_y+i-1)+1;
        select_feld(n,i);
        put_pixel(select_x+n-1,select_y+i-1,modus-1);
      end;
  modus := 1;
  for i := 1 to 16 do
    begin
      select_feld(1,i);
      put_pixel(select_x+1-1,select_y+i-1,modus-1);
    end;
  set_infozeil(' ');
  modus := mem;
  show_mouse;
end;

{***************************************
 **  Zeichensatz im Speicher lîschen  **
 ***************************************}
procedure erase_font;
var i,n,mem,which,zeile,spalte:integer;
begin
  set_infozeil(' Zeichensatz lîschen');
  mem := modus;
  str:=
'[1][Sind Sie sicher,|daû Sie den Zeichen-|satz lîschen wollen?][ JA | NEIN ]';
  ready := alert(2,str);
  if ready = 1 then
    begin
      set_infozeil(' Zeichensatz lîschen   --Bitte warten--');
      hide_mouse;
      for i := 1 to 16 do
        for n := 1 to 12 do
          begin
            modus := 1;
            select_feld(n,i);
          end;
    for zeile := 1 to 10 do
     for spalte := 1 to 25 do
       begin
        select_x := ((spalte-1)*16+pos[2,1])+2;
        select_y := ((zeile-1)*32+pos[2,2])+14;
        for i := 1 to 16 do
          for n := 1 to 12 do
            begin
              modus := 1;
              put_pixel(select_x+n-1,select_y+i-1,modus-1);
            end;
      end;
      show_mouse;
      select_char(select);
      select_char(select);
    end;
  set_infozeil(' ');
  modus := mem;
end;

{*************************************
 **  Markierung nach Wunsch setzen  **
 *************************************}
procedure mark_prg;
VAR obj,xdial,ydial,wdial,hdial:integer;
    x,y,w,h:integer;
    tree:long_integer;
    error,i:integer;
    fil:text;
BEGIN
  set_infozeil(' Matrix markieren');
  error := rsrc_gaddr(0, MARKE, tree);
  x := 320;   y := 200;
  w := 1;     h := 1;
  form_center(tree, xdial,ydial,wdial,hdial);
  sourc_dest(xdial,ydial,wdial,hdial);
  form_dial(0,x,y,w,h,xdial,ydial,wdial,hdial);
  objc_draw(tree,0,30,xdial,ydial,wdial,hdial);
  repeat
    obj := form_do(tree,0);
    case obj of
       OBENGR  : begin
                   if mark_stat = 1 then
                     begin
                       if mark_ob > 0 then
                         begin
                           desel_hline(mark_ob);
                           mark_ob := mark_ob -1;
                           sel_hline(mark_ob);
                         end;
                     end;
                 end;
       OBENKL  : begin
                   if mark_stat = 1 then
                     begin
                       if mark_ob < mark_un - 1 then
                         begin
                           desel_hline(mark_ob);
                           mark_ob := mark_ob + 1;
                           sel_hline(mark_ob);
                         end;
                     end;
                 end;
       UNTENGR : begin
                   if mark_stat = 1 then
                     begin
                       if mark_un > mark_ob + 1 then
                         begin
                           desel_hline(mark_un);
                           mark_un := mark_un - 1;
                           sel_hline(mark_un);
                         end;
                     end;
                 end;
       UNTENKL : begin
                   if mark_stat = 1 then
                     begin
                       if mark_un < 16 then
                         begin
                           desel_hline(mark_un);
                           mark_un := mark_un +1;
                           sel_hline(mark_un);
                         end;
                     end;
                 end;
       LINKSGR : begin
                   if mark_stat = 1 then
                     begin
                       if mark_li > 0 then
                         begin
                           desel_vline(mark_li);
                           mark_li := mark_li - 1;
                           sel_vline(mark_li);
                         end;
                     end;
                 end;
       LINKSKL : begin
                   if mark_stat = 1 then
                     begin
                       if mark_li < mark_re - 1 then
                         begin
                           desel_vline(mark_li);
                           mark_li := mark_li + 1;
                           sel_vline(mark_li);
                         end;
                     end;
                 end;
       RECHTSGR: begin
                   if mark_stat = 1 then
                     begin
                       if mark_re > mark_li+1 then
                         begin
                           desel_vline(mark_re);
                           mark_re := mark_re - 1;
                           sel_vline(mark_re);
                         end;
                     end;
                 end;
       RECHTSKL: begin
                   if mark_stat = 1 then
                     begin
                       if mark_re < 12 then
                         begin
                           desel_vline(mark_re);
                           mark_re := mark_re + 1;
                           sel_vline(mark_re);
                         end;
                     end;
                 end;
       MARKAUS : begin
                   mark_stat := 0;
                   desel_vline(mark_re);
                   desel_vline(mark_li);
                   desel_hline(mark_un);
                   desel_hline(mark_ob);
                 end;
       MARKEIN : begin
                   mark_stat := 1;
                   sel_vline(mark_re);
                   sel_vline(mark_li);
                   sel_hline(mark_un);
                   sel_hline(mark_ob);
                 end;
       MARKSAVE: begin
                   rewrite(fil,'FONT.DAT');
                   writeln(fil,mark_li);
                   writeln(fil,mark_re);
                   writeln(fil,mark_un);
                   writeln(fil,mark_ob);
                   writeln(fil,mark_stat);
                   close(fil);
                   desel_obj(tree,obj);
                 end;
    end;   { case of }
  until obj = MARKFERT;
  form_dial(3,x,y,w,h,xdial,ydial,wdial,hdial);
  desel_obj(tree,obj);
  dest_sourc(xdial,ydial,wdial,hdial);
  set_infozeil(' ');
END;

procedure select_menu(menu,item:integer);
begin
  CASE menu OF
    DESK :
        case item of
                ABOUT : about_prg;
        end;
    AUSGABE :
        case item of
                LOAD     : load_font;
                SAVE     : save_font;
                SAVEAS   : save_as;
                ERASEFON : erase_font;
                PRINTFON : print_font;
        end;
    EDIT :
        case item of
                VSPIEGEL: v_spiegel;
                HSPIEGEL: h_spiegel;
                FILL    : fill_prg;
                ERASE   : erase_prg;
                TOGGLE  : toggle_prg;
                COPY    : copy_prg;
        end;
    MOVE :
        case item of
                MOVEUP  : move_up;
                MOVEDOWN: move_down;
                MOVELEFT: move_left;
                MOVERIGH: move_right;
        end;
    MARK :
        case item of
                SETMARK : mark_prg;
        end;
  END;  { CASE OF }
menu_tnormal(menu_tree,menu,1);
end;

procedure do_menu;
var evnt:integer;
begin
 REPEAT

   evnt := evnt_multi(mu_mesag | mu_button,
                       1,1,dummy,0,0,0,0,0,0,0,0,0,0,
                       mgbuf,0,0,mausx,mausy,dummy,
                                     dummy,dummy,dummy);
   if (evnt & mu_mesag)= mu_mesag then
     begin
       if mgbuf[0] = 10 then
         select_menu(mgbuf[3],mgbuf[4]);   { MN_SELECTED }
     end
   else
     feld(mausx,mausy);

 UNTIL ((((evnt & mu_mesag)=mu_mesag) and (mgbuf[3] = AUSGABE)
             and (mgbuf[4] = QUIT)));
end;


(* HAUPTPROGRAMM *)
BEGIN
 open_work;
 screen_sourc := logbase;
 screen_dest := malloc(32768);
 i := load_rsc;
 if i = 0 then
 begin
 i := getrez;
 if i = 2 then
  begin
   menu_bar(menu_tree,1);
   open_window;
   graf_mouse(0);
   init;
   draw_sprite(pos[3,1]+1,pos[3,2]+1,sprite2,a1);
   draw_sprite(pos[4,1]+1,pos[4,2]+1,sprite1,a1);
   set_modus;
   repeat
    do_menu;
    set_infozeil(' Programm beenden');
    str:='[1][Sind Sie sicher,|daû alle Daten|gespeichert sind?][NEIN|JA]';
    ready := alert(1,str);
    set_infozeil(' ');
   until ready = 2;
  end
 else
   begin
    graf_mouse(0);
    str:='[1][Dieses Programm lÑuft|nur auf dem Mono-Screen|SM124!][SCHADE]';
    ready:=alert(1,str);
   end;
 end;
 close_window;
END.
