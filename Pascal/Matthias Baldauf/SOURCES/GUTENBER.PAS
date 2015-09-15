{ GUTENBERG-DRUCKER ist Teil des Programmpakets }
{ zum Drucken von NLQ und anderen Schriften auf }
{           EPSON-kompatiblen Druckern.         }
{ Hierzu gehîrt auch FONT.PRG zum editieren der }
{                  ZeichensÑtze                 }
{ GUTENBERG (c) Juli 1986 by MKB-Soft M.Baldauf }
{                                               }
{ letzte énderung am :  16.04.1987              }
{                                               }
{             ** VERSION 1.1  4/87 **           }

{ Jetzt noch 70 kByte des Speichers fÅr eventuelle Malloc-Aufrufe freigeben }

{$U70}

{ und schon kann das Programm beginnen }

program GUTENBERG_DRUCKER;

        { Zuerst sind die Konstanten dran, nur wenige }

CONST  mu_mesag     = 16;
       mu_button    = 2;

{$I GUTENBERG.I}

        { Nach den Konstanten kommen bekannterweise die Typen dran }

TYPE in_type   = ARRAY[0..10] OF integer;
     out_type  = ARRAY[0..99] OF integer;
     stringtyp   = PACKED ARRAY[1..21] OF char;
     nulldrei  = ARRAY[0..3] OF integer;
     mgbuftyp  = ARRAY[0..7] OF integer;
     text_type = PACKED ARRAY [0..39] OF char;
     pxy_type  = ARRAY[0..7] OF integer;
     grect     = RECORD     { Dieser RECORD wird zur Fenster-Restaurierung - }
                  g_x:integer;  { gebraucht }
                  g_y:integer;
                  g_w:integer;
                  g_h:integer;
                 END;
     ted1 = PACKED RECORD   { Wichtig zur Object-Behandlung }
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

     tedinfo = RECORD       { Wichtig zur Object-Behandlung }
                CASE boolean OF
                 FALSE: (ted_tree:long_integer);
                 TRUE : (p_ted:^ted1)
               END;
     ob1 = PACKED RECORD    { Wichtig zur Object-Behandlung }
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

     object_typ = RECORD    { Wichtig zur Object-Behandlung }
               CASE boolean OF
                FALSE: (object_tree:long_integer);
                TRUE : (p_obj:^ob1)
              END;

     copy_type = RECORD     { Dies brauchen wir fÅr das Block-Copy }
                   address:long_integer;
                   wort:array[2..9] of integer;
                 END;

     fs_type   = PACKED ARRAY [1..39] OF char;
     ch_type   = PACKED ARRAY [1..150] OF char;
     str_type = packed array [1..14] of char;

        { Nun folgt die Deklaratione der vielen nîtigen Variablen }

VAR  handle,w_handle,dummy:integer;
     druck_zeile : ARRAY [1..10] OF string;
     xdesk,ydesk,wdesk,hdesk:integer;
     mausx,mausy,ready:integer;
     modus:integer;
     l_intin:in_type;
     l_out  :out_type;
     mgbuf:mgbuftyp;
     menu_tree:long_integer;
     fs_iexbutton:boolean;
     fs_iinpath,fs_iinsel:fs_type;
     f_iinpath,f_iinsel:fs_type;
     obj_tree:long_integer;
     laenge:integer;

     a:char;
     fil:text;
     i:integer;
     str:string;
     dateiname:string;
     pxy:pxy_type;

     sourc,dest:copy_type;
     screen_sourc,screen_dest:long_integer;
     select : integer;
     select_x,select_y:integer;
     esc:char;

     font: ARRAY[1..250,1..13] OF long_integer;
     font_pr : ARRAY[1..2,1..250,1..13] OF integer;

     prop:integer;

     pr_init,pr_vor_halb,pr_vor_acht,pr_vor_norm,
     pr_hrg_norm,pr_hrg_dopp,pr_vor_wahl:string[10];
     pr_vor_halb_nl, pr_zur_halb_nl:string[10];
     nl_10:integer;

     druck:integer;
     stand:integer;
     small:integer;

     rand:integer;
     zsz:integer;

     st:integer;
     seit:integer;

     potenz : array[0..15] of long_integer;
     potenz_w : array[0..7] of integer;
     
     pap_len,pap_tof,pap_head,pap_foot,pap_bof,pap_breit:integer;
     kopf_left,kopf_mid,kopf_right:string;
     fuss_left,fuss_mid,fuss_right:string;

        { Eine Menge Prozedur-Deklarationen fÅr GEM- und Systemaufrufe }

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
procedure menu_icheck(m_tree:long_integer; m_item,m_check:integer);
C;
function getrez:integer;
xbios(4);
function logbase:long_integer;
xbios(3);
function malloc(size:long_integer):long_integer;
gemdos($48);
function fopen(var name:str_type; i:integer):integer;
gemdos($3d);
procedure fclose(handle:integer);
gemdos($3e);
function fread(hande:integer; count,buf:long_integer):integer;
gemdos($3f);


{*********************
 **  Peek und Poke  **
 *********************}
function peek(adr:long_integer):byte;
type word = packed record
                    w:byte
                   end;
var ptr:record
         case boolean of
          false:(i:long_integer);
          true :(p:^word)
         end;
begin
  ptr.i := adr;
  peek := ptr.p^.w
end;

procedure poke(adr:long_integer;val:byte);
type word = packed record
                    w:byte
                   end;
var ptr:record
         case boolean of
          false:(i:long_integer);
          true :(p:^word)
         end;
begin
  ptr.i := adr;
  ptr.p^.w := val
end;

{***************************************************
 **  Wandlung einer INTEGER-Zahl in einen String  **
 ***************************************************}
procedure itoa(n:integer);  {liefert Ergebnis in 'str' zurueck}
var  i,j,sign,n1:integer;
     st:string;
begin
  sign := n;
  if sign < 0 then n := -n;
  i := 0;
  st := '';
  str := '';
  repeat
    i := i + 1;
    n1 := n-(trunc(n/10)*10);
    st := concat(st,chr(48+n1));
    n := trunc(n/10);
  until n <= 0;
  if sign < 0 then st := concat(st,'-');
  j := length(st);
  for i := 1 to j do
    begin
      str := concat(str,st[j]);
      j := j - 1;
    end;
end;

{****************************************
 **         Objecttext holen           **
 ****************************************}
PROCEDURE get_text(baum,index:integer;VAR text:string);
VAR adress,text_tree:long_integer;
    object:object_typ;
    ted_info:tedinfo;
    text_len,i:integer;
    i1:integer;
BEGIN
 dummy:=rsrc_gaddr(0,baum,adress);
 object.object_tree:=adress+index*24;
 ted_info.ted_tree:=object.p_obj^.ob_spec;
 text_tree:=ted_info.p_ted^.te_ptext;
 text_len:=ted_info.p_ted^.te_tmplen-2;
 text:='';
 for i:=0 TO text_len DO text:=concat(text,chr(peek(text_tree+i)));
 if text[1]='@' then text:=''
    else begin
     i1:=1;text:='';
     loop
      exit if (text[i1]=chr(0)) or ((i1>=text_len-2) and (text[i1]=' '));
      text:=concat(text,text[i1]);
      i1:=i1+1;
     end;
    end;
END;

{****************************************
 **         Objecttext setzen          **
 ****************************************}
PROCEDURE set_text(baum,index:integer;text:string);
VAR adress,text_tree:long_integer;
    object:object_typ;
    ted_info:tedinfo;
    text_len,i:integer;
BEGIN
 dummy:=rsrc_gaddr(0,baum,adress);
 object.object_tree:=adress+index*24;
 ted_info.ted_tree:=object.p_obj^.ob_spec;
 text_tree:=ted_info.p_ted^.te_ptext;
 text_len:=ted_info.p_ted^.te_txtlen-2;
 text:='';
 FOR i:=0 TO text_len DO poke(text_tree+i,ord(text[i+1]));
END;

{****************************************
 **         Objectstatus holen         **
 ****************************************}
FUNCTION get_state(baum,index:integer):integer;
var  object:object_typ;
     error:integer;
     address:long_integer;
begin
  error := rsrc_gaddr(0,baum,address);
  object.object_tree := address + index*24;
  get_state := object.p_obj^.ob_state;
end;

{**************************************************
 **  Wandlung eines Strings in eine INTEGER-Zahl **
 **************************************************}
function atoi(s:string):integer;
var i,n:integer;
begin
  n := 0;
  i := 1;
  while ((s[i] >= '0') and (s[i] <= '9')) do
    begin
      n := 10*n + (ord(s[i])-48);
      i := i+1;
    end;
  atoi := n;
end;

{*******************************************************
 **  Titelbild wird in den Bildschirm-Puffer geladen  **
 *******************************************************}
procedure load_pic;
var i:integer;
    f_handle:integer;
    pstr:str_type;
begin
  pstr := 'GUTENBER.PIC  ';
  pstr[13] := chr(0);
  f_handle := fopen(pstr,0);
  if f_handle > 0 then
    begin
      i := fread(f_handle,32000,screen_dest);
      fclose(f_handle);
    end;
end;

{**********************************************************
 **  Wandlung eines Strings in ein PACKED ARRAY OF CHAR  **
 **********************************************************}
procedure str_to_char(str:string; var pa:ch_type);
var i,len:integer;
begin
  len := length(str);
  for i := 1 to len do pa[i] := str[i];
  pa[len+1] := chr(0);
end;

{****************************************
 **  und das Ganze auch mal umgekehrt  **
 ****************************************}
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

{*******************************************************************
 **  Kopieren eines Blocks vom SOURC- nach dem DESTINATION-SCREEN **
 *******************************************************************}
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

{****************************************
 **  und das Ganze auch mal umgekehrt  **
 ****************************************}
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

{*********************************************
 **  Zwei Prozeduren zur Object-Behandlung  **
 *********************************************}
procedure desel_obj(tree:long_integer; which:integer);
BEGIN
  objc_change(tree,which,0,xdesk,ydesk,wdesk,hdesk,0,1);
END;

procedure sel_obj(tree:long_integer; which:integer);
BEGIN
  objc_change(tree,which,0,xdesk,ydesk,wdesk,hdesk,1,1);
END;

{***********************************************************************
 **  vor dem Programmstart gibt es auch eine Menge zu initialisieren  **
 ***********************************************************************}
procedure init;
var i,n,l,x,y,error:integer;
    tree:long_integer;
    fil:text;
function getdrv:integer;gemdos($19);
begin
  menu_ienable(menu_tree, PRINTFIL,0);
  hide_mouse;
  fs_iinpath := 'A:\*.ZSZ                               ';   { 39 char }
  fs_iinpath[9] := chr(0);
  fs_iinsel := '                                       ';   { 39 char }
  fs_iinsel[1] := chr(0);
  f_iinpath := 'A:\*.DOC                               ';   { 39 char }
  f_iinpath[9] := chr(0);
  f_iinsel := '                                       ';   { 39 char }
  f_iinsel[1] := chr(0);
  f_iinpath[1] := chr(getdrv+1+64);
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
{##############################################################################}
                            {Druckertreiber}
  pr_init := concat(chr(27),chr(64));              { Drucker-Initialisierung }
  pr_vor_halb := concat(chr(27),chr(51),chr(1));   { Vorschub auf 1/144 Inch }
  pr_vor_wahl := concat(chr(27),chr(65),chr(11));  { Vorschub auf 11/72 Inch }
  pr_vor_acht := concat(chr(27),chr(65),chr(8));   { Vorschub auf 8/72 Inch }
  pr_hrg_dopp := concat(chr(27),chr(76));          { Graphik doppelte Dichte }
  pr_hrg_norm := concat(chr(27),chr(75));          { Graphik einfache Dichte }
  pr_vor_norm := concat(chr(27),chr(50));          { Vorschub 1/6 Inch }
                   { Folgendes nur fÅr ** NL-10 ** }
  pr_vor_halb_nl := concat(chr(27),chr(51),chr(2));{ Vorschub auf 2/216 Inch }
  pr_zur_halb_nl := concat(chr(27),chr(106),chr(4));{ 4/216 Inch zurÅck }
                      {Druckertreiber bis hierher}
{##############################################################################}

  druck := 1 ;   { Voreinstellung Druck-Art auf NLQ }
  prop  := 0 ;   { Voreinstellung keine Proportionalschrift }
  stand := 1 ;
  small := 1 ;
  rand  := 8 ;   { Voreinstellung Rand auf 8 }
  zsz   := 0 ;   { kein Zeichensatz compiliert }
  st := 1;       { 1st Word }
  nl_10 := 1; { NL-10 Drucker ausgewÑhlt }

        { Nachschauen ob Standard-Einstellung auf Diskette }
  reset(fil,'GUTENBER.INF');
  if not eof(fil) then
    begin
      readln(fil,st);     { Textart }
      readln(fil,prop);   { Proportional }
      readln(fil,nl_10);  { Druckertyp }
      readln(fil,druck);  { Druck-Art }
      readln(fil,small);  { NLQ-Art }
      readln(fil,stand);  { Standard-Art }
      close(fil);
    end;

        { Alle Einstellungen vornehmen }
  if small = 1 then
    begin
      menu_icheck(menu_tree,NLQNORM,1);
      menu_icheck(menu_tree,NLQBREIT,0);
    end
  else
    begin
      menu_icheck(menu_tree,NLQNORM,0);
      menu_icheck(menu_tree,NLQBREIT,1);
    end;
  if stand = 3 then
    begin
      menu_icheck(menu_tree,STANDHER,1);
      menu_icheck(menu_tree,STANDSCH,0);
      menu_icheck(menu_tree,STANDNOR,0);
    end;
  if stand = 2 then
    begin
      menu_icheck(menu_tree,STANDHER,0);
      menu_icheck(menu_tree,STANDSCH,1);
      menu_icheck(menu_tree,STANDNOR,0);
    end;
  if stand = 1 then
    begin
      menu_icheck(menu_tree,STANDHER,0);
      menu_icheck(menu_tree,STANDSCH,0);
      menu_icheck(menu_tree,STANDNOR,1);
    end;
  if druck = 1 then
    begin
      menu_icheck(menu_tree,NORMAL,0);
      menu_icheck(menu_tree,NLQ,1);
      menu_ienable(menu_tree, NLQBREIT,1);
      menu_ienable(menu_tree, NLQNORM,1);
      menu_ienable(menu_tree, STANDHER,0);
      menu_ienable(menu_tree, STANDSCH,0);
      menu_ienable(menu_tree, STANDNOR,0);
    end
  else
    begin
      menu_icheck(menu_tree,NORMAL,1);
      menu_icheck(menu_tree,NLQ,0);
      menu_ienable(menu_tree, NLQBREIT,0);
      menu_ienable(menu_tree, NLQNORM,0);
      menu_ienable(menu_tree, STANDHER,1);
      menu_ienable(menu_tree, STANDSCH,1);
      menu_ienable(menu_tree, STANDNOR,1);
    end;
  if prop = 1 then
    menu_icheck(menu_tree,PROPORT,1)
  else
    menu_icheck(menu_tree,PROPORT,0);
  error := rsrc_gaddr(0, PRINTER, tree);
  if nl_10 = 1 then
    sel_obj(tree,NL10)
  else
    sel_obj(tree,GEMINI);
  if st = 1 then   { 1st-Word }
    begin
      menu_icheck(menu_tree,STWORD,1);
      menu_icheck(menu_tree,ASCII,0);
      menu_icheck(menu_tree,TEXTOMAT,0);
    end;
  if st = -1 then   { ASCII-Texte }
    begin
      menu_icheck(menu_tree,STWORD,0);
      menu_icheck(menu_tree,ASCII,1);
      menu_icheck(menu_tree,TEXTOMAT,0);
    end;
  if st = 0 then  { Textomat }
    begin
      menu_icheck(menu_tree,STWORD,0);
      menu_icheck(menu_tree,ASCII,0);
      menu_icheck(menu_tree,TEXTOMAT,1);
    end;
  seit := 1;    { Voreinstellung SeitenzÑhler }
  itoa(seit);
  if length(str)<2 then str := concat(str,chr(0));
  set_text(DRUCKE, SEITE,str);
  itoa(rand);
  if length(str)<2 then str := concat(str,chr(0));
  set_text(DRUCKE, DRUCKRND,str);
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

{*************************************************
 **  Diverse Prozeduren zur Window-Darstellung  **
 *************************************************}
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
  clip[1] := ydesk;
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
  wi_kind := 1;  (* Namenszeile *)
  hide_mouse;
  wind_get(0,4,xdesk,ydesk,wdesk,hdesk);
  w_handle := wind_create(wi_kind,xdesk,ydesk,wdesk,hdesk);
  wi_title := ' GUTENBERG - DRUCKER  ';
  wi_title[22] := chr(0);
  wind_set(w_handle,2,wi_title,0,0);
  graf_growbox(xdesk+wdesk DIV 2,ydesk+hdesk DIV 2,
                      0,0,xdesk,ydesk,wdesk,hdesk);
  clear_window;
  wind_open(w_handle,xdesk,ydesk,wdesk,hdesk);
  init;
  wind_get(w_handle,4,xdesk,ydesk,wdesk,hdesk);
  dest_sourc(xdesk,ydesk,wdesk,hdesk);
  show_mouse;
 end;

{**************************************************
 **  auch ALERT-BOXEN werden manchmal gebraucht  **
 **************************************************}
function alert(art:integer; text:string):integer;
var al_txt:ch_type;
begin
  str_to_char(text,al_txt);
  alert := form_alert(art,al_txt);
end;

{********************************************************
 **  eine Resource-Datei will auch mal geladen werden  **
 ********************************************************}
function load_rsc:integer;
var error:integer;
    title:stringtyp;
begin
 load_rsc := 0;
 title := 'GUTENBER.RSC         ';
 title[13] := chr(0);
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
     str:='[1][Es ist ein Fehler|mit dem .RSC-File|aufgetreten !!][ SCHADE ]';
     ready:=alert(1,str);
     load_rsc := 1;
   end;
end;

{**********************************************
 **  Diese Function stellt Dialog-Boxen dar  **
 **********************************************}
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

{******************************************
 **  auch der Autor will genannt werden  **
 ******************************************}
procedure about_prg;
var tree:long_integer;
    error,obj:integer;
begin
  error := rsrc_gaddr(0, UEBER, tree);
  obj := hndl_dial(tree,0,320,200,1,1);
end;

{*********************************************
 ** Welchen Drucker haben Sie doch gleich ? **
 *********************************************}
procedure sel_printer_type;
var tree:long_integer;
    error,obj,stat:integer;
begin
  error := rsrc_gaddr(0, PRINTER, tree);
  obj := hndl_dial(tree,0,320,200,1,1);
  stat := get_state(PRINTER,NL10);
  if stat = 0 then
    nl_10 := 0
  else
    nl_10 := 1;
end;

{*****************************************************************
 **  Eine Steuerung einer File-Select-Box ist auch interessant  **
 *****************************************************************}
procedure show_file(mode:integer; iinsel,iinpath:fs_type);
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
      if mode = 1 then
        begin
          fs_iinpath := iinpath;
          fs_iinsel := iinsel;
          error := setdrv(ord(fs_iinpath[1])-64-1);
        end
      else
        begin
          f_iinpath := iinpath;
          f_iinsel := iinsel;
          error := setdrv(ord(f_iinpath[1])-64-1);
        end;
      fn:=('\\                                     ');
      fn[3]:=chr(0);
      error:=chdir(fn);
      i:=3;
      if mode = 1 then
        begin
          while fs_iinpath[i]<>'*' do
            begin
              fn[i-2]:=fs_iinpath[i];
              i:=i+1;
            end;
        end
      else
        begin
          while f_iinpath[i]<>'*' do
            begin
              fn[i-2]:=f_iinpath[i];
              i:=i+1;
            end;
        end;
      fn[i-2]:=chr(0);
      error:=chdir(fn);
    end;
  dest_sourc(xdial,ydial,wdial,hdial);
end;

{*********************************************
 **  Ein Pixel will erstmal gesetzt werden  **
 *********************************************}
procedure set_pixel(mode,x,y,art:integer);
var i,n:integer;
begin
  for n := 0 to mode do
    for i := 0 to mode do
      begin
        put_pixel(x+n,y+i,art);
      end;
end;

{**********************************************************
 **  wird gebraucht um Font auf dem Screen darzustellen  **
 **********************************************************}
procedure recompile(mode,x,y:integer; str:string);
var i,n,z:integer;
    zaehler,status:integer;
    flag,flag1 : long_integer;
begin
  hide_mouse;
    for z := 1 to length(str) do
      begin
        zaehler := ord(str[z]);
        for n := 1 to 12 do
          begin
            flag1 := font[zaehler,n];
            for i := 1 to 16 do
              begin
                flag := flag1 - potenz[16-i];
                if flag >= 0 then
                  begin
                    flag1 := flag;
                    set_pixel(mode,x+n-1+mode*n,y+i-1+mode*i,1);
                  end
                else
                  set_pixel(mode,x+n-1+mode*n,y+i-1+mode*i,0);
              end;
          end;
        x := x + 12+mode*12;
      end;
  show_mouse;
end;

{****************************************
 **  Einlesen einer Zeichensatz-Datei  **
 ****************************************}
procedure load_font(mode:integer);
var i,n,mem,flag:integer;
    datei:file of long_integer;
begin
  if mode = 1 then
    show_file(1,fs_iinsel,fs_iinpath)
  else fs_iexbutton := TRUE;
  if fs_iexbutton then
    begin
      graf_mouse(2);
      reset(datei,dateiname);
      if not eof(datei) then
        begin
          for i := 1 to 250 do
            for n := 1 to 12 do
              begin
                font[i,n] := datei^;
                get(datei);
              end;
          zsz := 0;
          menu_ienable(menu_tree, PRINTFIL,1);
          str := 'ABCDEFGHIJ';
          recompile(0,474,138,str);
          str := 'KLMNOPQRST';
          recompile(0,474,160,str);
          str := 'UVWXYZéôö';
          recompile(0,474,182,str);
          str := 'abcdefghij';
          recompile(0,474,204,str);
          str := 'klmnopqrst';
          recompile(0,474,226,str);
          str := 'uvwxyzÑîÅû';
          recompile(0,474,248,str);
          str := '0123456789';
          recompile(0,474,270,str);
          graf_mouse(0);
        end
      else
        if mode = 1 then
          begin
            str:='[1][Diesen Zeichensatz|habe ich nicht|gefunden !][ABBRUCH]';
            ready:=alert(1,str);
          end;
      close(datei);
      graf_mouse(0);
    end;
end;

{**********************************************************
 **  Der Zeichensatz wird fÅr den NLQ-Druck vorbereitet  **
 **********************************************************}
procedure convert_nlq;
var i,n,g,z,za:integer;
    flag,flag1:long_integer;
begin
  zsz := 1;
  for i := 1 to 250 do
    for n := 1 to 12 do
      begin
        flag1 := font[i,n];
        font_pr[1,i,n] := 0;
        font_pr[2,i,n] := 0;
        za := 0;
        for z := 1 to 8 do
          begin
            za := za + 1;
            flag := flag1 - potenz[16-za];
            if flag >= 0 then
              begin
                flag1 := flag;
                g := 8-z;
                font_pr[1,i,n] := font_pr[1,i,n] +
                      potenz_w[g];
              end;
            za := za + 1;
            flag := flag1 - potenz[16-za];
            if flag >= 0 then
              begin
                flag1 := flag;
                g := 8-z;
                font_pr[2,i,n] := font_pr[2,i,n] +
                      potenz_w[g];
              end;
          end;
      end;
end;

{**************************************************************
 **  Der Zeichensatz wird fÅr den Einfach-Druck vorbereitet  **
 **************************************************************}
procedure convert_norm;
var i,n,g,z:integer;
    flag,flag1:long_integer;
begin
  zsz := 2;
  for i := 1 to 250 do
    for n := 1 to 12 do
      begin
        flag1 := font[i,n];
        font_pr[1,i,n] := 0;
        font_pr[2,i,n] := 0;
        for z := 1 to 8 do
          begin
            flag := flag1 - potenz[16-z];
            if flag >= 0 then
              begin
                flag1 := flag;
                g := 8-z;
                font_pr[1,i,n] := font_pr[1,i,n] +
                      potenz_w[g];
              end;
          end;
        for z := 9 to 16 do
          begin
            flag := flag1 - potenz[16-z];
            if flag >= 0 then
              begin
                flag1 := flag;
                g := 16-z;
                font_pr[2,i,n] := font_pr[2,i,n] +
                      potenz_w[g];
              end;
          end;
      end;
end;

{***************************************************************************
 **  Wenn eine Zeile nur aus Leerzeichen besteht wird sie nicht gedruckt  **
 ***************************************************************************}
procedure cut_line(line:string);
var i:integer;
begin
  i := 0;
  repeat
    if line[length(line)] = chr(32) then
      line := copy(line,1,length(line)-1)
    else i := 1;
  until (( i = 1 ) or (length(line) < 1));
  str := line;
end;

{**************************************************
 **  Druck-Routine fÅr Proportionalen NLQ-Druck  **
 **************************************************}
procedure prop_nlq(line:string);
var i,z,z1,zei,lang,ra:integer;
    g,count:integer;
    zeile,zeile1:packed array [1..1920] of char;
begin
  ra := rand;
  if line <> '' then
    begin
      cut_line(line);
      line := str;
      if small = 2 then ra := ra * 2;
      lang := ra*12;
      z1 := 0;
      if ra <> 0 then
        for i := 1 to ra do
          for z := 1 to 12 do
            begin
              if z1 < 1920 then
                begin
                  z1 := z1 + 1;
                  zeile[z1] :=  chr(0);
                  zeile1[z1] := chr(0);
                end;
            end;
      for i := 1 to length(line) do
        begin
          zei := ord(line[i]);
          if zei = 32 then
            begin
              for count := 1 to 12 do
                begin
                  if lang < 1920 then
                    begin
                      lang := lang + 1;
                      zeile[lang] :=  chr(0);
                      zeile1[lang] := chr(0);
                    end;
                  if small = 2 then
                    begin
                      if lang < 1920 then
                        begin
                          lang := lang + 1;
                          zeile[lang] :=  chr(0);
                          zeile1[lang] := chr(0);
                        end;
                    end
                end;
            end
          else
            begin
              if lang < 1920 then
                begin
                  lang := lang + 1;
                  zeile[lang] := chr(0);
                  zeile1[lang] := chr(0);
                end;
              for count := 1 to 12 do
                begin
                  if ((font_pr[1,zei,count]) | (font_pr[2,zei,count]))
                    <> 0 then
                    begin
                      if lang < 1920 then
                        begin
                          lang := lang + 1;
                          zeile[lang] := chr(font_pr[1,zei,count]);
                          zeile1[lang] := chr(font_pr[2,zei,count]);
                        end;
                      if small = 2 then
                        begin
                          if lang < 1920 then
                            begin
                              lang := lang + 1;
                              zeile[lang] := chr(font_pr[1,zei,count]);
                              zeile1[lang] := chr(font_pr[2,zei,count]);
                            end;
                        end;
                    end;
                end;
            end;
        end;
      z := lang div 256;
      z1 := lang mod 256;
      if nl_10 = 0 then
        write(pr_vor_halb)      { STAR Gemini 10 x  etc. }
      else
        write(pr_vor_halb_nl);  { STAR NL-10, Epson-FX etc. }
      write(concat(pr_hrg_dopp,chr(z1),chr(z)));
      for i := 1 to lang do
        write(zeile[i]);
      writeln;
      write(concat(pr_hrg_dopp,chr(z1),chr(z)));
      for i := 1 to lang do
        write(zeile1[i]);
      writeln;
      if nl_10 = 0 then
        writeln(pr_vor_wahl)    { STAR Geminie 10 x etc. }
      else
        begin
          write(pr_zur_halb_nl);{ STAR NL-10, Epson-FX etc. }
          writeln(pr_vor_norm);
        end;
    end
  else
    begin
      if nl_10 = 0 then
        begin
          write(pr_vor_halb);   { STAR Gemini 10 x  etc. }
          writeln;
          writeln;
          writeln(pr_vor_wahl);
        end
      else
        writeln(pr_vor_norm);   { STAR NL-10, Epson-FX etc. }
    end;
end;

{******************************************************
 **  Druck-Routine fÅr Proportionalen Einfach-Druck  **
 ******************************************************}
procedure prop_norm(line:string);
var i,z,z1,zei,lang,ra:integer;
    g,count:integer;
    zeile,zeile1:packed array [1..1920] of char;
begin
  ra := rand;
  if line <> '' then
    begin
      cut_line(line);
      line := str;
      if stand = 3 then ra := ra * 2;
      lang := ra*12;
      z1 := 0;
      if ra <> 0 then
        for i := 1 to ra do
          for z := 1 to 12 do
            begin
              if z1<1920 then
                begin
                  z1 := z1 + 1;
                  zeile[z1] :=  chr(0);
                  zeile1[z1] := chr(0);
                end;
            end;
      for i := 1 to length(line) do
        begin
          zei := ord(line[i]);
          if zei = 32 then
            begin
              for count := 1 to 12 do
                begin
                  if lang < 1920 then
                    begin
                      lang := lang + 1;
                      zeile[lang] :=  chr(0);
                      zeile1[lang] := chr(0);
                    end;
                  if stand = 3 then
                    if lang < 1920 then
                      begin
                        lang := lang + 1;
                        zeile[lang] :=  chr(0);
                        zeile1[lang] := chr(0);
                      end;
                end;
            end
          else
            begin
              if lang < 1920 then
                begin
                  lang := lang + 1;
                  zeile[lang] := chr(0);
                  zeile1[lang] := chr(0);
                end;
              if stand = 3 then
                if lang < 1920 then
                  begin
                    lang := lang + 1;
                    zeile[lang] := chr(0);
                    zeile1[lang] := chr(0);
                  end;
              for count := 1 to 12 do
                begin
                  if ((font_pr[1,zei,count]) | (font_pr[2,zei,count]))
                    <> 0 then
                    begin
                      if lang < 1920 then
                        begin
                          lang := lang + 1;
                          zeile[lang] := chr(font_pr[1,zei,count]);
                          zeile1[lang] := chr(font_pr[2,zei,count]);
                        end;
                      if stand = 3 then
                        if lang < 1920 then
                          begin
                            lang := lang + 1;
                            zeile[lang] := chr(font_pr[1,zei,count]);
                            zeile1[lang] := chr(font_pr[2,zei,count]);
                          end;
                    end;
                end;
            end;
        end;
      z := lang div 256;
      z1 := lang mod 256;
      write(pr_vor_acht);
      if ((stand = 2) or (stand = 3)) then
        write(concat(pr_hrg_dopp,chr(z1),chr(z)))
      else
        write(concat(pr_hrg_norm,chr(z1),chr(z)));
      for i := 1 to lang do
        write(zeile[i]);
      writeln;
      if ((stand = 2) or (stand = 3)) then
        write(concat(pr_hrg_dopp,chr(z1),chr(z)))
      else
        write(concat(pr_hrg_norm,chr(z1),chr(z)));
      for i := 1 to lang do
        write(zeile1[i]);
      writeln(pr_vor_wahl);
    end
  else
    begin
      write(pr_vor_acht);
      writeln;
      writeln(pr_vor_wahl);
    end;
end;

{***********************************
 **  Druck-Routine fÅr NLQ-Druck  **
 ***********************************}
procedure print_nlq(line:string);
var i,z,z1,zei,lang,ra:integer;
    g,count:integer;
begin
  ra := rand;
  if line <> '' then
    begin
      cut_line(line);
      line := str;
      lang := length(line)*12;
      lang := lang+ra*12;
      if small = 2 then
        begin
          lang := lang * 2;
          ra := ra * 2;
        end;
      if nl_10 = 0 then
        write(pr_vor_halb)      { STAR Gemini 10 x  etc. }
      else
        write(pr_vor_halb_nl);  { STAR NL-10, Epson-FX etc. }
      z := lang div 256;
      z1 := lang mod 256;
      for g := 1 to 2 do
        begin
          write(concat(pr_hrg_dopp,chr(z1),chr(z)));
          if ra > 0 then
            for i := 1 to ra*12 do write(chr(0));
          for i := 1 to length(line) do
            begin
              zei := ord(line[i]);
              for count := 1 to 12 do
                begin
                  write(chr(font_pr[g,zei,count]));
                  if small = 2 then
                  write(chr(font_pr[g,zei,count]));
                end;
            end;
          writeln;
        end;
      if nl_10 = 0 then
        writeln(pr_vor_wahl)    { STAR Geminie 10 x etc. }
      else
        begin
          write(pr_zur_halb_nl);{ STAR NL-10, Epson-FX etc. }
          writeln(pr_vor_norm);
        end;
    end
  else
    begin
      if nl_10 = 0 then
        begin
          write(pr_vor_halb);   { STAR Gemini 10 x  etc. }
          writeln;
          writeln;
          writeln(pr_vor_wahl);
        end
      else
        writeln(pr_vor_norm);   { STAR NL-10, Epson-FX etc. }
    end;
end;

{***************************************
 **  Druck-Routine fÅr Einfach-Druck  **
 ***************************************}
procedure print_norm(line:string);
var i,z,z1,zei,lang,ra:integer;
    g,count:integer;
begin
  ra := rand;
  if line <> '' then
    begin
      cut_line(line);
      line := str;
      lang := length(line)*12;
      lang := lang+ra*12;
      if stand = 3 then
        begin
          ra := ra * 2;
          lang := lang * 2;
        end;
      write(pr_vor_acht);
      z := lang div 256;
      z1 := lang mod 256;
      for g := 1 to 2 do
        begin
          if ((stand = 2) or (stand = 3)) then
            write(concat(pr_hrg_dopp,chr(z1),chr(z)))
         else
           write(concat(pr_hrg_norm,chr(z1),chr(z)));
         if ra > 0 then
           for i := 1 to ra*12 do write(chr(0));
         for i := 1 to length(line) do
           begin
             zei := ord(line[i]);
             for count := 1 to 12 do
               begin
                 write(chr(font_pr[g,zei,count]));
                 if stand = 3 then
                 write(chr(font_pr[g,zei,count]));
              end;
           end;
         if g = 1 then writeln;
        end;
      writeln(pr_vor_wahl);
    end
  else
    begin
      write(pr_vor_acht);
      writeln;
      writeln(pr_vor_wahl);
    end;
end;

{***************************************************
 **  1st-Word Konvertier Routine (c) by MKB-Soft  **
 **                                               **
 **  Diese Routine kann abgeÑndert auch fÅr       **
 **  eigene Entwicklungen benutzt werden.         **
 **                                               **
 **************************************************}
procedure st_word_print;
var i,ii,lang,zeile,zeich,flag:integer;
    fil:text;
    line,zei,ganz_zeil:string;
    esc:char;
    pap_zeil:integer;
    xdial,ydial,wdial,hdial:integer;
    x,y,w,h,z,error,obj:integer;
    tree:long_integer;
    quit:boolean;
    poit:integer;
    seite:integer;
    anzahl,zaehler:integer;

  procedure print_line(line:string);    { Ausdrucken einer Zeile je nach }
  begin                                 { eingestellten SchriftwÅnschen }
    if prop = 0 then
      if druck = 1 then print_nlq(line)
    else print_norm(line);
    if prop = 1 then
      if druck = 1 then prop_nlq(line)
    else prop_norm(line);
  end;

  procedure kopf;                       { Erzeugen der Kopfzeile }
  var line,left,mid,right,zahl_str,zw:string;
      i,poit,zahl:integer;
  begin
    line := '';
    if pap_tof > 0 then
      for i := 1 to pap_tof do
          print_line(line);
    { Zusammenstellen der Kopf-Zeile }
    poit := pos('#',kopf_left);  { Suche nach dem SeitenzÑhler }
    if poit <> 0 then
      begin
        itoa(seite);
        zahl_str := str;
        left := copy(kopf_left,1,poit - 1);
        left := concat(left,zahl_str);
        if length(kopf_left) > poit+1 then
          begin
            zw := copy(kopf_left,poit+1,length(kopf_left)-poit-1);
            left := concat(left,zw);
          end;
      end
    else left := kopf_left;
    line := left;
    poit := pos('#',kopf_mid);   { Suche nach dem SeitenzÑhler }
    if poit <> 0 then
      begin
        itoa(seite);
        zahl_str := str;
        mid := copy(kopf_mid,1,poit - 1);
        mid := concat(mid,zahl_str);
        if length(kopf_mid) > poit+1 then
          begin
            zw := copy(kopf_mid,poit+1,length(kopf_mid)-poit-1);
            mid := concat(mid,zw);
          end;
      end
    else mid := kopf_mid;
    zahl := (pap_breit div 2) - (length(left)) - (length(mid) div 2);
    if zahl <> 0 then
      for i := 1 to zahl do
        line := concat(line,' ');
    line := concat(line,mid);
    poit := pos('#',kopf_right); { Suche nach dem SeitenzÑhler }
    if poit <> 0 then
      begin
        itoa(seite);
        zahl_str := str;
        right := copy(kopf_right,1,poit - 1);
        right := concat(right,zahl_str);
        if length(kopf_right) > poit+1 then
          begin
            zw := copy(kopf_right,poit+1,length(kopf_right)-poit-1);
            right := concat(right,zw);
          end;
      end
    else right := kopf_right;
    zahl := (pap_breit) - (length(line)) - (length(right));
    if zahl <> 0 then
      for i := 1 to zahl do
        line := concat(line,' ');
    line := concat(line,right);
    if pap_head > 0 then
      begin
        print_line(line);
      end;
    line := '';
    if pap_head > 1 then
      for i := 1 to pap_head-1 do
        print_line(line);
  end;

  procedure fuss;                      { Zusammenstellen der Fuûzeile }
  var line,left,mid,right,zahl_str,zw:string;
      i,poit,zahl:integer;
  begin
    line := '';
    if pap_foot > 1 then
      for i := 1 to pap_foot-1 do
          print_line(line);
    { Zusammenstellen der Fuû-Zeile }
    poit := pos('#',fuss_left);  { Suche nach dem SeitenzÑhler }
    if poit <> 0 then
      begin
        itoa(seite);
        zahl_str := str;
        left := copy(fuss_left,1,poit - 1);
        left := concat(left,zahl_str);
        if length(fuss_left) > poit+1 then
          begin
            zw := copy(fuss_left,poit+1,length(fuss_left)-poit-1);
            left := concat(left,zw);
          end;
      end
    else left := fuss_left;
    line := left;
    poit := pos('#',fuss_mid);   { Suche nach dem SeitenzÑhler }
    if poit <> 0 then
      begin
        itoa(seite);
        zahl_str := str;
        mid := copy(fuss_mid,1,poit - 1);
        mid := concat(mid,zahl_str);
        if length(fuss_mid) > poit+1 then
          begin
            zw := copy(fuss_mid,poit+1,length(fuss_mid)-poit-1);
            mid := concat(mid,zw);
          end;
      end
    else
      mid := fuss_mid;
    zahl := (pap_breit div 2) - (length(left)) - (length(mid) div 2);
    if zahl <> 0 then
      for i := 1 to zahl do
        line := concat(line,' ');
    line := concat(line,mid);
    poit := pos('#',fuss_right); { Suche nach dem SeitenzÑhler }
    if poit <> 0 then
      begin
        itoa(seite);
        zahl_str := str;
        right := copy(fuss_right,1,poit - 1);
        right := concat(right,zahl_str);
        if length(fuss_right) > poit+1 then
          begin
            zw := copy(fuss_right,poit+1,length(fuss_right)-poit-1);
            right := concat(right,zw);
          end;
      end
    else right := fuss_right;
    zahl := (pap_breit) - (length(line)) - (length(right));
    if zahl <> 0 then
      for i := 1 to zahl do
        line := concat(line,' ');
    line := concat(line,right);
    if pap_foot > 0 then
      print_line(line);
    line := '';
    if pap_bof > 0 then
      for i := 1 to pap_bof do
          print_line(line);
  end;

  procedure read_zeile;               { 10 Zeilen von Diskette einlesen }
  var i:integer;
  begin
    i := 0;
    repeat
      i := i + 1;
      line := '';
      readln(fil,druck_zeile[i]);
    until ((eof(fil)) or (i = 10));
    anzahl := i;
  end;

begin      { Begin von st_word_print }
  fuss_left := '';
  fuss_mid := '';
  fuss_right := '';
  kopf_left := '';
  kopf_mid := '';
  kopf_right := '';
  esc := chr(27);
  seite := seit;
  pap_zeil := 0;
  ganz_zeil := '';
  reset(fil,dateiname);   { oeffne Datei }
  rewrite(output,'PRN:');  { Leite Ausgaben auf Drucker }
  write(pr_init);
  x := 320;  y := 200;
  w := 1;    h := 1;
  error := rsrc_gaddr(0, WAIT, tree);
  form_center(tree, xdial,ydial,wdial,hdial);
  sourc_dest(xdial,ydial,wdial,hdial);
  form_dial(0,x,y,w,h,xdial,ydial,wdial,hdial);
  objc_draw(tree,0,30,xdial,ydial,wdial,hdial);
  quit := false;
  repeat
    read_zeile;
    zaehler := 0;
    while ((zaehler < anzahl) and (keypress = false)) do
      begin
        line := '';
        zaehler := zaehler + 1;
        line := druck_zeile[zaehler];
        if ((length(line) > 1) and (ord(line[1]) = 31)) then
          begin
            case line[2] of
              '0' : begin   { Layout Daten }
                      str := copy(line,3,2);
                      pap_len := atoi(str);
                      str := copy(line,5,2);
                      pap_tof := atoi(str);
                      str := copy(line,7,2);
                      pap_head := atoi(str);
                      str := copy(line,9,2);
                      pap_foot := atoi(str);
                      str := copy(line,11,2);
                      pap_bof := atoi(str);
                      str := copy(line,13,2);
                      pap_breit := atoi(str);
                      { Beschreibbare SeitenlÑnge berechnen }
                    end;
              '1' : begin   { Kopfzeile, eventuell mit # als SeitenzÑhler }
                      line := copy(line,3,length(line)-2);
                      poit := pos(chr(31),line);
                      if poit <> 1 then
                        kopf_left := copy(line,1,poit);
                      line := copy(line,poit+1,length(line)-poit);
                      poit := pos(chr(31),line);
                      if poit <> 1 then
                        kopf_mid := copy(line,1,poit);
                      kopf_right := copy(line,poit+1,length(line)-poit);
                    end;
              '2' : begin   { Fusszeile, eventuell mit # als Seitenzaehler }
                      line := copy(line,3,length(line)-2);
                      poit := pos(chr(31),line);
                      if poit <> 1 then
                        fuss_left := copy(line,1,poit);
                      line := copy(line,poit+1,length(line)-poit);
                      poit := pos(chr(31),line);
                      if poit <> 1 then
                        fuss_mid := copy(line,1,poit);
                      fuss_right := copy(line,poit+1,length(line)-poit);
                    end;
              '9' : begin   { Formatzeile mit Tabulator-Zeichen }
                      pap_breit := pos(']',line) - 2;
                    end;
            end;
          end
        else
          begin
            if ((length(line) > 0) and (ord(line[1]) = 12)) then
              begin                           { Formfeed -> Vorschub }
                for ii := pap_zeil to pap_len-pap_foot-pap_bof-1 do
                  print_line('');
                pap_zeil := 0;
                fuss;
                seite := seite + 1;
              end;
            if pap_zeil = pap_len-pap_foot-pap_bof then
              begin                           { Seite voll -> Vorschub }
                pap_zeil := 0;
                fuss;
                seite := seite + 1;
              end;
            if pap_zeil < 1 then              { Es ist wohl Zeit einen - }
              begin                           { Kopf auszudrucken }
                kopf;
                pap_zeil := pap_tof+pap_head;  { Kopf gedruckt }
              end;
            ganz_zeil := '';
            lang:=length(line);        { Wie lang ist denn die Zeile ? }
            for i := 1 to lang do
              begin
                zei:=copy(line,i,1);   { Aktuelles zeichen holen }
                zeich := ord(zei[1]);
                if flag = 1 then       { Aha, jetzt kommt ein Style change }
                  flag := 0
                else
                  if zeich > 31 then   { Alles in Ordnung, also hinzufÅgen }
                    ganz_zeil := concat(ganz_zeil,chr(zeich))
                  else                 { Ansonsten mal testen was anliegt }
                    case zeich of
                      25 :    { Variable Trennung }
                           ganz_zeil := concat(ganz_zeil,'-');
                      27 : flag := 1;       { Style change }
                      28 :    { Stretch space }
                           ganz_zeil := concat(ganz_zeil,chr(32));
                      29 :    { Indent space }
                           ganz_zeil := concat(ganz_zeil,chr(32));
                      30 :    { Variable space }
                           ganz_zeil := concat(ganz_zeil,chr(32));
                    end;
              end;
            { jetzt die Zeile ausgeben }
            print_line(ganz_zeil);
            pap_zeil := pap_zeil + 1;  { Wieder eine Zeile gedruckt }
          end;
      end;
    if eof(fil) then                   { Was, Text schon zu Ende ? }
      begin                            { Noch schnell Vorschub bis Fuû  - }
        for ii := pap_zeil to pap_len-pap_foot-pap_bof-1 do
          print_line('');
        fuss;                          { Fuûzeile ausdrucken - }
        quit := true;                  { und jetzt Feierabend }
      end;
    if keypress then                   { Was soll der Quatsch - }
      begin                            { Abbrechen wo es gerade Spaû macht? }
        str := '[1][Sind Sie sicher,|daû Sie abbrechen|wollen?][JA|NEIN]';
        ready:=alert(2,str);
        if ready = 1 then quit := true; { Okay, Åberzeugt }
      end;
  until quit = true;                   { solange weiter bis Abbruch oder Ende }
  close(fil);                          { Datei schliesen }
  form_dial(3,x,y,w,h,xdial,ydial,wdial,hdial);
  dest_sourc(xdial,ydial,wdial,hdial); { Hintergrund restaurieren }
  write(pr_init);
  rewrite(output,'CON:');    { Standart-Ausgabe auf Konsole lenken }
  graf_mouse(0);             { Maus-Cursor = Pfeil }
end;      { end von st_word_print }

{***************************************
 **  Jetzt soll wohl gedruckt werden  **
 ***************************************}
procedure print_text;
VAR xdial,ydial,wdial,hdial:integer;
    x,y,w,h,i,z,error,obj:integer;
    line:string;
    tree:long_integer;
    quit : boolean;
  function bcostat(dev:integer):integer;bios(8);
begin
  show_file(2,f_iinsel,f_iinpath);
  if fs_iexbutton = TRUE then
    begin
      error := rsrc_gaddr(0, DRUCKE, tree);
      obj := hndl_dial(tree,0,320,200,1,1);
      get_text(DRUCKE, DRUCKRND,str);
      rand := atoi(str);
      get_text(DRUCKE, SEITE,str);
      seit := atoi(str);
      if obj = DRUCKDRU then
        begin
          i := bcostat(0);
          if i = -1 then
            begin
              graf_mouse(2);
              if zsz  <> druck then
                begin
                  x := 320;  y := 200;
                  w := 1;    h := 1;
                  error := rsrc_gaddr(0, WARTE, tree);
                  form_center(tree, xdial,ydial,wdial,hdial);
                  sourc_dest(xdial,ydial,wdial,hdial);
                  form_dial(0,x,y,w,h,xdial,ydial,wdial,hdial);
                  objc_draw(tree,0,30,xdial,ydial,wdial,hdial);
                  if druck = 1 then convert_nlq
                  else convert_norm;
                  form_dial(3,x,y,w,h,xdial,ydial,wdial,hdial);
                  dest_sourc(xdial,ydial,wdial,hdial);
                end;
              if st <> 1 then
                begin  { normale ASCII-Dateien drucken }
                  reset(fil,dateiname);   { oeffne Datei }
                  rewrite(output,'PRN:');  { Leite Ausgaben auf Drucker }
                  write(pr_init);
                  x := 320;  y := 200;
                  w := 1;    h := 1;
                  error := rsrc_gaddr(0, WAIT, tree);
                  form_center(tree, xdial,ydial,wdial,hdial);
                  sourc_dest(xdial,ydial,wdial,hdial);
                  form_dial(0,x,y,w,h,xdial,ydial,wdial,hdial);
                  objc_draw(tree,0,30,xdial,ydial,wdial,hdial);
                  quit := false;
                  repeat
                    while ((not eof(fil)) and (keypress <> true)) do
                      begin
                        readln(fil,line);
                        if prop = 0 then
                          if druck = 1 then print_nlq(line)
                        else print_norm(line);
                        if prop = 1 then
                          if druck = 1 then prop_nlq(line)
                          else prop_norm(line);
                      end;
                    if eof(fil) then quit := true;
                    if keypress = true then
                      begin
                        str:=
                   '[1][Sind Sie sicher,|dass Sie abbrechen|wollen?][JA|NEIN]';
                        ready:=alert(2,str);
                        if ready = 1 then quit := true;
                      end;
                  until quit = true;
                  close(fil);
                  form_dial(3,x,y,w,h,xdial,ydial,wdial,hdial);
                  dest_sourc(xdial,ydial,wdial,hdial);
                  write(pr_init);
                  rewrite(output,'CON:');
                  graf_mouse(0);
                end
              else
                st_word_print;
            end
          else
            begin
              str := '[1][Bitte Drucker und|Kabel ÅberprÅfen !!][ Abbruch ]';
              i := alert(1,str);
            end;
        end;
    end;
end;

{***********************************************
 **  Was wurde im DROP-DOWN-MENÅ angeclickt?  **
 ***********************************************}
procedure select_menu(menu,item:integer);
var tree:long_integer;
    error:integer;
    x:char;
begin
  CASE menu OF
    DESK :
        case item of
          INFO : about_prg;
        end;
    AUSGABE :
        case item of
          LADEFONT : load_font(1);
          PRINTFIL : print_text;
          ASCII    : begin
                       x := f_iinpath[1];
                       f_iinpath := 'A:\*.*                                 ';
                       f_iinpath[7] := chr(0);
                       f_iinpath[1] := x;
                       str := concat('0',chr(0));
                       set_text(DRUCKE, DRUCKRND,str);
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,TEXTOMAT,0);
                       menu_icheck(menu_tree,STWORD,0);
                       st := -1;
                     end;
          TEXTOMAT : begin
                       x := f_iinpath[1];
                       f_iinpath := 'A:\*.OUT                               ';
                       f_iinpath[9] := chr(0);
                       f_iinpath[1] := x;
                       str := concat('0',chr(0));
                       set_text(DRUCKE, DRUCKRND,str);
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,ASCII,0);
                       menu_icheck(menu_tree,STWORD,0);
                       st := 0;
                     end;
          STWORD   : begin
                       x := f_iinpath[1];
                       f_iinpath := 'A:\*.DOC                               ';
                       f_iinpath[9] := chr(0);
                       f_iinpath[1] := x;
                       str := concat('8',chr(0));
                       set_text(DRUCKE, DRUCKRND,str);
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,ASCII,0);
                       menu_icheck(menu_tree,TEXTOMAT,0);
                       st := 1;
                     end;
        end;
    FONTI :
        case item of
          NLQ      : begin
                       menu_icheck(menu_tree,NORMAL,0);
                       menu_icheck(menu_tree,NLQ,1);
                       menu_ienable(menu_tree, NLQBREIT,1);
                       menu_ienable(menu_tree, NLQNORM,1);
                       menu_ienable(menu_tree, STANDHER,0);
                       menu_ienable(menu_tree, STANDSCH,0);
                       menu_ienable(menu_tree, STANDNOR,0);
                       druck := 1;
                     end;
          NLQNORM  : begin
                       small := 1;  { normal }
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,NLQBREIT,0);
                     end;
          NLQBREIT : begin
                       small := 2;  { breit }
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,NLQNORM,0);
                     end;
          NORMAL   : begin
                       menu_icheck(menu_tree,NORMAL,1);
                       menu_icheck(menu_tree,NLQ,0);
                       menu_ienable(menu_tree, STANDHER,1);
                       menu_ienable(menu_tree, STANDSCH,1);
                       menu_ienable(menu_tree, STANDNOR,1);
                       menu_ienable(menu_tree, NLQBREIT,0);
                       menu_ienable(menu_tree, NLQNORM,0);
                       druck := 2;
                     end;
          STANDHER : begin
                       stand := 3;  { Hervorgehoben }
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,STANDSCH,0);
                       menu_icheck(menu_tree,STANDNOR,0);
                     end;
          STANDSCH : begin
                       stand := 2;  { Schmal }
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,STANDHER,0);
                       menu_icheck(menu_tree,STANDNOR,0);
                     end;
          STANDNOR : begin
                       stand := 1;  { Normal }
                       menu_icheck(menu_tree,item,1);
                       menu_icheck(menu_tree,STANDSCH,0);
                       menu_icheck(menu_tree,STANDHER,0);
                     end;
        end;
    SPECIAL :
        case item of
          PROPORT  : begin
                       if prop = 0 then   { Proportional einstellen }
                         begin
                           prop := 1;
                           menu_icheck(menu_tree,PROPORT,1);
                         end
                       else    { Proportional loeschen }
                         begin
                           prop := 0;
                           menu_icheck(menu_tree,PROPORT,0);
                         end;
                     end;
          SAVEPREV : begin     { Preverences abspeichern }
                       str:=
     '[1][Bitte Start-Diskette|ins aktuelle|Laufwerk legen !][ OK | ABBRUCH ]';
                       error := alert(1,str);
                       if error = 1 then
                         begin
                           rewrite(fil,'GUTENBER.INF');
                           writeln(fil,st);     { Textart }
                           writeln(fil,prop);   { Proportional }
                           writeln(fil,nl_10);  { Druckertyp }
                           writeln(fil,druck);  { Druck-Art }
                           writeln(fil,small);  { NLQ-Art }
                           writeln(fil,stand);  { Standard-Art }
                           close(fil);
                         end;
                     end;
          PRINTTYP : begin     { Druckertyp wÑhlen }
                       sel_printer_type;
                     end;
        end;
  END;  { CASE OF }
menu_tnormal(menu_tree,menu,1);
end;

{****************************************
 **  Event-Handling muû auch mal sein  **
 ****************************************}
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
     end;

 UNTIL ((((evnt & mu_mesag)=mu_mesag) and (mgbuf[3] = AUSGABE)
             and (mgbuf[4] = QUIT)));
end;


{***************************************************************
 **  Und dies, meine Damen?? und Herrn, ist das Hauptrogramm  **
 ***************************************************************}
BEGIN
 open_work;
 screen_sourc := logbase;         { Wo isser denn, der Bildschirm }
 screen_dest := malloc(32768);    { Mal eben 32 kByte reservieren }
 i := load_rsc;    { Wie lief denn das Laden der Resource-Datei? }
 if i = 0 then     { wenn alles O.K. dann mal los }
   begin
     i := getrez;   { Welche Auflîsung haben wir denn eingestellt }
     if i = 2 then  { LÑuft nur in der hohen Auflîsung (bei der Grafik, haha)}
       begin
         load_pic;  { Einen schînen Hintergrund brauchen wir auch noch }
         menu_bar(menu_tree,1);  { MenÅzeile einschalten }
         open_window;
         graf_mouse(0);
         dateiname := 'GUTENBER.ZSZ';
         load_font(2);           { Ist denn der Lieblingszeichensatz da? }
         do_menu;                { Auf zur MenÅsteuerung }
       end
     else
       begin
         graf_mouse(0);
         str:=                   { So spielt das Leben!  }
          '[1][Dieses Programm lÑuft|nur auf dem Mono-Screen|SM124!][SCHADE]';
         ready:=alert(1,str);
       end;
   end;
 close_window;
END.  { Ende Main }              { Das wars, Tscheerio }
