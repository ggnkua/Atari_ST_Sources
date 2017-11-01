program game;
{ (c) 1988 by J”rg Ramb               }
{             Potsdamerst.3           }
{             6307 Linden-Leihgestern }

const
      {$I gemconst.pas}

type  sprite=RECORD
      x_spot: integer;
      y_spot: integer;
      format: integer;
      bcolor: integer;
      fcolor: integer;
      mask  : ARRAY [0..15]
         OF RECORD
            back: integer;
            fore: integer
         END
      end;

     save=array [1..133] of integer;
     sound=packed array [1..40] of byte;
     {$I gemtype.pas}

var  bomb,house : sprite;
     plane: array [1..3] of sprite;
     dummy: save;
     build: array[0..40,0..24] of boolean;
     anz: integer;
     noth: integer;
     air,crash,down,sile:sound;
     speed_bomb,speed_plane,speed_down:integer;
     meldung:string[100];

{$I gemsubs.pas}
procedure dosound(var sounds:sound);
        xbios(32);
procedure vsync;
        xbios(37);
function rnd(von,bis:integer):integer;
function random:long_integer;
     xbios(17);
begin
     rnd:=von+(random mod (bis-von+1));
end;

procedure clrscr;
begin write(chr(27),'E'); end;


procedure init_speed;
begin
     noth:=do_alert(
          '[0][ |   Geschwindigkeit der Bomben:    | ][ Langsam | Normal | Schnell ]',2);
     case noth of
          1:speed_bomb:=2;
          2:speed_bomb:=4;
          3:speed_bomb:=6;
     end;
     noth:=do_alert(
          '[0][ |   Geschwindigkeit des Flugzeuges:    | ][ Schnell | Normal | Langsam ]',2);
     case noth of
          1:speed_plane:=5;
          2:speed_plane:=3;
          3:speed_plane:=1;
     end;
     noth:=do_alert(
          '[0][ |    Abstiegsgeschwindigkeit:     | ][ Schnell | Normal | Langsam ]',2);
     case noth of
          1:speed_down:=9;
          2:speed_down:=5;
          3:speed_down:=3;
     end;
end;


procedure set_back;
var t:integer;
begin
     clrscr;
     set_clip(0,0,640,400);
     paint_outline(true);
     paint_style(5); paint_rect(0,0,640,400);
     paint_style(0);
     for t:=1 to rnd(20,50) do
          paint_oval(rnd(0,640),rnd(00,90),rnd(20,80),rnd(15,30));
     paint_style(7); paint_rect(16,384,608,16);
     paint_style(5); paint_outline(false);
end;


procedure init;
begin
     air[1]:=6;   air[2]:=31;  air[3]:=7;    air[4]:=247; air[5]:=8;
     air[6]:=16;  air[7]:=11;  air[8]:=0;    air[9]:=12;  air[10]:=0;
     air[11]:=13; air[12]:=8;  air[13]:=255; air[14]:=0;
     crash[1]:=6;   crash[2]:=25;   crash[3]:=7;    crash[4]:=199; crash[5]:=8;
     crash[6]:=0;   crash[7]:=9;    crash[8]:=0;    crash[9]:=10;  crash[10]:=15;
     crash[11]:=11; crash[12]:=255; crash[13]:=12;  crash[14]:=255;
     crash[15]:=13; crash[16]:=0;   crash[17]:=255; crash[18]:=0;
     down[1]:=2;    down[2]:=0;    down[3]:=3;    down[4]:=0;    down[5]:=6;
     down[6]:=31;   down[7]:=7;    down[8]:=245;  down[9]:=8;    down[10]:=16;
     down[11]:=9;   down[12]:=13;  down[13]:=11;  down[14]:=0;   down[15]:=12;
     down[16]:=0;   down[17]:=13;  down[18]:=8;   down[19]:=128; down[20]:=100;
     down[21]:=129; down[22]:=  2; down[23]:=  1; down[24]:=  0; down[25]:=130;
     down[26]:=0;   down[27]:=255; down[28]:=0;
     sile[1]:=0;    sile[2]:=0;  sile[3]:=1;   sile[4]:=0;    sile[5]:=2;
     sile[6]:=0;    sile[7]:=3;  sile[8]:=0;   sile[9]:=4;    sile[10]:=0;
     sile[11]:=5;   sile[12]:=0; sile[13]:=7;  sile[14]:=248; sile[15]:=8;
     sile[16]:=0;   sile[17]:=9; sile[18]:=0;  sile[19]:=10;  sile[20]:=0;
     sile[21]:=255; sile[22]:=0;

     with bomb do begin
        x_spot:=0; y_spot:=0; format:=0; bcolor:=0; fcolor:=1;
        mask[ 0].fore:= 28956;   mask[ 0].back:= 28956;
        mask[ 1].fore:= 19364;   mask[ 1].back:= 31676;
        mask[ 2].fore:= 17732;   mask[ 2].back:= 32764;
        mask[ 3].fore:=  9544;   mask[ 3].back:= 16376;
        mask[ 4].fore:=  8176;   mask[ 4].back:=  8176;
        mask[ 5].fore:=  4064;   mask[ 5].back:=  4064;
        mask[ 6].fore:=  8176;   mask[ 6].back:=  8176;
        mask[ 7].fore:= 15288;   mask[ 7].back:= 16376;
        mask[ 8].fore:= 15288;   mask[ 8].back:= 16376;
        mask[ 9].fore:= 14392;   mask[ 9].back:= 16376;
        mask[10].fore:= 15288;   mask[10].back:= 16376;
        mask[11].fore:=  7088;   mask[11].back:=  8176;
        mask[12].fore:=  8176;   mask[12].back:=  8176;
        mask[13].fore:=  4064;   mask[13].back:=  4064;
        mask[14].fore:=   896;   mask[14].back:=   896;
        mask[15].fore:=   256;   mask[15].back:=   256;
     end;

     with house do begin
        x_spot:=0; y_spot:=0; format:=0; bcolor:=0; fcolor:=1;
        mask[ 0].fore:= 32766;   mask[ 0].back:= 32766;
        mask[ 1].fore:= 26214;   mask[ 1].back:= 32766;
        mask[ 2].fore:= 26214;   mask[ 2].back:= 32766;
        mask[ 3].fore:= 32766;   mask[ 3].back:= 32766;
        mask[ 4].fore:= 32766;   mask[ 4].back:= 32766;
        mask[ 5].fore:= 26214;   mask[ 5].back:= 32766;
        mask[ 6].fore:= 26214;   mask[ 6].back:= 32766;
        mask[ 7].fore:= 32766;   mask[ 7].back:= 32766;
        mask[ 8].fore:= 32766;   mask[ 8].back:= 32766;
        mask[ 9].fore:= 26214;   mask[ 9].back:= 32766;
        mask[10].fore:= 26214;   mask[10].back:= 32766;
        mask[11].fore:= 32766;   mask[11].back:= 32766;
        mask[12].fore:= 32766;   mask[12].back:= 32766;
        mask[13].fore:= 26214;   mask[13].back:= 32766;
        mask[14].fore:= 26214;   mask[14].back:= 32766;
        mask[15].fore:= 32766;   mask[15].back:= 32766;
     end;

     with plane[1] do begin
        x_spot:=0; y_spot:=0; format:=0; bcolor:=0; fcolor:=1;
        mask[ 0].fore:=     0;   mask[ 0].back:=     0;
        mask[ 1].fore:=     0;   mask[ 1].back:=     0;
        mask[ 2].fore:=     3;   mask[ 2].back:=     3;
        mask[ 3].fore:=     4;   mask[ 3].back:=     7;
        mask[ 4].fore:=   252;   mask[ 4].back:=   255;
        mask[ 5].fore:=  1015;   mask[ 5].back:=  1023;
        mask[ 6].fore:=   -11;   mask[ 6].back:=    -1;
        mask[ 7].fore:=  1013;   mask[ 7].back:=  1023;
        mask[ 8].fore:=   253;   mask[ 8].back:=   255;
        mask[ 9].fore:=     7;   mask[ 9].back:=     7;
        mask[10].fore:=     0;   mask[10].back:=     0;
        mask[11].fore:=     0;   mask[11].back:=     0;
        mask[12].fore:=     0;   mask[12].back:=     0;
        mask[13].fore:=     0;   mask[13].back:=     0;
        mask[14].fore:=     0;   mask[14].back:=     0;
        mask[15].fore:=     0;   mask[15].back:=     0;
     end;

     with plane[2] do begin
        x_spot:=0; y_spot:=0; format:=0; bcolor:=0; fcolor:=1;
        mask[ 0].fore:=     0;   mask[ 0].back:=     0;
        mask[ 1].fore:= 30727;   mask[ 1].back:= 30727;
        mask[ 2].fore:=-18632;   mask[ 2].back:=  -193;
        mask[ 3].fore:= 12543;   mask[ 3].back:=    -1;
        mask[ 4].fore:=-28331;   mask[ 4].back:=    -1;
        mask[ 5].fore:=   -43;   mask[ 5].back:=    -1;
        mask[ 6].fore:= 21813;   mask[ 6].back:=    -1;
        mask[ 7].fore:= 22525;   mask[ 7].back:=    -1;
        mask[ 8].fore:= 22023;   mask[ 8].back:=    -1;
        mask[ 9].fore:=    -1;   mask[ 9].back:=    -1;
        mask[10].fore:=   192;   mask[10].back:=   255;
        mask[11].fore:=    63;   mask[11].back:=    63;
        mask[12].fore:=    12;   mask[12].back:=    15;
        mask[13].fore:=     3;   mask[13].back:=     3;
        mask[14].fore:=     0;   mask[14].back:=     0;
        mask[15].fore:=     0;   mask[15].back:=     0;
     end;

     with plane[3] do begin
        x_spot:=0; y_spot:=0; format:=0; bcolor:=0; fcolor:=1;
        mask[ 0].fore:=    12;   mask[ 0].back:=    12;
        mask[ 1].fore:= -4074;   mask[ 1].back:= -4066;
        mask[ 2].fore:=  2070;   mask[ 2].back:= -2018;
        mask[ 3].fore:= -4074;   mask[ 3].back:= -4066;
        mask[ 4].fore:=  -970;   mask[ 4].back:=  -962;
        mask[ 5].fore:= 22484;   mask[ 5].back:=    -4;
        mask[ 6].fore:= 21844;   mask[ 6].back:=    -4;
        mask[ 7].fore:= 21848;   mask[ 7].back:=    -8;
        mask[ 8].fore:= 21840;   mask[ 8].back:=   -16;
        mask[ 9].fore:=   -32;   mask[ 9].back:=   -32;
        mask[10].fore:=-32768;   mask[10].back:=-32768;
        mask[11].fore:= -2048;   mask[11].back:= -2048;
        mask[12].fore:=  1024;   mask[12].back:= -1024;
        mask[13].fore:= -2048;   mask[13].back:= -2048;
        mask[14].fore:=     0;   mask[14].back:=     0;
        mask[15].fore:=     0;   mask[15].back:=     0;
     end;
end;

procedure set_scrn;
var  t,u,high:integer;
begin
     write(chr(27),'f');
     anz:=0;
     for t:=0 to 40 do for u:=0 to 24 do build[t,u]:=false;
     for t:=2 to 37 do begin
          high:=rnd(2,16);
          for u:=high downto 1 do begin
               draw_sprite(16*t,16*(24-u),house,dummy);
               anz:=succ(anz);
               build[t,u]:=true;
          end;
     end;
end;

function pushdown:boolean;
var  mess:message_buffer;
     event:integer;
begin
     event:=get_event(E_TIMER|E_KEYBOARD,
                    0,0,0,
                    0,
                    false,0,0,0,0,
                    false,0,0,0,0,
                    mess,
                    noth,
                    noth,
                    noth,
                    noth,noth,noth);
     pushdown:=(event&E_KEYBOARD)<>0;
end;

procedure game;
var  pl:array [1..3] of save;
     bo:save;
     bomb_down:boolean;
     t,x,y,bx,by:integer;
     flip:boolean;
begin
     x:=607; y:=75; bomb_down:=true;
     for t:=1 to 3 do draw_sprite(x+16*pred(t),y,plane[t],pl[t]);
     repeat
          if bomb_down then begin
            dosound(air);
            if pushdown then begin
               bx:=(x div 16)+1; by:=y+15-speed_bomb; bomb_down:=false;
               if anz=0 then bomb_down:=true
               else if not (bx in [2..37]) then bomb_down:=true
               else if build[bx,23-((y+10-speed_bomb) div 16)] then bomb_down:=true
               else if by<=383 then draw_sprite(bx*16,by,bomb,bo)
               else begin bomb_down:=true; paint_rect(bx*16,383,16,16); end;
               if not bomb_down then dosound(down);
            end;
          end else begin
               undraw_sprite(bo);
               if build[bx,24-(by div 16)] then begin
                    dosound(crash);
                    build[bx,24-(by div 16)]:=false;
                    paint_rect(16*bx,16*(by div 16),16,16);
                    anz:=pred(anz);
               end;
               by:=by+speed_bomb;
               if by<=383 then draw_sprite(bx*16,by,bomb,bo)
               else bomb_down:=true;
          end;
          if (anz<=0) and flip then y:=y+1;
          flip:=not flip;
          x:=x-speed_plane;
          if x<0 then begin x:=607; y:=y+speed_down; end;
          if build[(x div 16)+2,24-((y+10) div 16)] then begin
               dosound(crash);
               for y:=1 to 70 do vsync; {Verz”gerung}
               dosound(sile);
               noth:=do_alert('[0][ | |   *** C R A S H ***    | | ][ Mist! ]',1);
               y:=384;
          end;
          vsync;
          if y<=383 then begin
               for t:=3 downto 1 do undraw_sprite(pl[t]);
               for t:=1 to 3 do draw_sprite(x+16*pred(t),y,plane[t],pl[t]);
          end;
     until y>372;
     dosound(sile);
     if anz<=0 then
          noth:=do_alert('[0][ | -> Geschafft! <-  | | ][ Toll ! ]',1);
end;


begin
     if init_gem>=0 then begin
          init; init_mouse;
          hide_mouse; set_back; set_scrn; show_mouse;
          noth:=do_alert(
               '[0][ |          Was sind Sie ?:           | ][ Pazifist | Killer | Russe ]',1);
          case noth of
               1: meldung:=
                    '[0][ Sie mssen eine  | leere Stadt abreižen  | ][ Friede!  Friede! ]';
               2: meldung:=
                    '[0][ Vernichten Sie  | die feindliche Stadt!  | ][ Nieder mit ihr!! ]';
               3: meldung:=
                    '[0][ Bek„mpfen Sie die  | kapitalistische Bauwut  | ][ Jawohl, Genosse! ]';
          end;
          repeat
               hide_mouse;
               set_back;
               show_mouse; init_speed; hide_mouse;
               set_scrn; show_mouse; noth:=do_alert(meldung,1); hide_mouse;
               game;
               show_mouse;
               noth:=do_alert('[0][ |  Nochmal spielen ?   | ][ Yeah ! | N”... ]',1);
          until noth=2;
          noth:=do_alert(
'[0][1988 geschrieben von |  -> J”rg Ramb <-| |  *Public Domain*| ][  Alles klar!  ]',1);
          exit_gem;
     end;
end.
