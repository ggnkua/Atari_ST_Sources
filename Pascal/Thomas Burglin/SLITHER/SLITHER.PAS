 
PROGRAM slither;
{ By Thomas Burglin, March 1987. 
  Copyright 1988 Antic Publishing.
  Portions of this program are Copyright
  1986, OSS and CCD. Used by permission of OSS. }

LABEL
  2, 4, 5, 10, 80, 90;

CONST
  {$I GEMCONST.PAS }

TYPE
  {$I GEMTYPE.PAS }
  sprite = ARRAY [1..37] OF integer;
  HeadType = Packed Array[0..63] of Integer;

VAR
  i,j,k,l,x,y, dummy, s1,s2,s3 : integer;
  deskcolors : headtype;
  strings : string;
  applesprite : sprite;
  headr, headu, headl, headd : sprite;
  bodyh, bodyv, bodyr, bodyu, bodyl, bodyd : sprite;
  bodytu, bodytr, bodytd, bodytl : sprite;
  tailr, tailu, taill, taild : sprite;
  stars : sprite;
  save : ARRAY [1..133] OF integer; { savearray for sprite }
  xs, ys, xsold, ysold, xe, ye : integer; { array coord. of snakehead }
  pxs, pys, pxsold, pysold, pxe, pye : integer; { paint coord. of snakehead }
  dir, dirold, dire, tail : integer; { direction of snakehead }
  fields : packed ARRAY [1..30,1..5,1..40] OF byte; { field }
  field : ARRAY [1..40,1..40] OF integer;
  level : integer;
  apples, applestart, applesonfield, snakes, time : integer;
  snakeincr, appleincr, maxlevel, scoreincr : integer;
  event : integer;
  ch, note, volume : integer; { soundvariables }
  nocrash : BOOLEAN;
  hiscore, score : long_integer;
  pausestate : long_integer;
  delaystart, delay : integer;
  cwall, csnake, csnakeeye, capple, cfield, cframe, cback : integer; { colors }
  ctext, ctext2 : integer;
  keystate : integer;
  inbuf : file of text;
  path, filename : string;

{*********************************************************************}

  {$I gemsubs}

  PROCEDURE vsync;
    XBIOS (37);

  FUNCTION s_peek_b (adress: LONG_INTEGER): BYTE;
    EXTERNAL;

  PROCEDURE s_poke_b (adress: LONG_INTEGER; value: BYTE);
    EXTERNAL;

  FUNCTION testtast (dummy:integer):integer;
    BIOS (1);

  FUNCTION gettast (dummy:integer):long_integer;
    BIOS (2);

  FUNCTION shifttast (modus:integer):long_integer;
    BIOS (11);

  FUNCTION random:long_integer;
    XBIOS (17);

  FUNCTION getrez : integer;
    XBIOS (4);

  PROCEDURE setcolor(Colornum, Color: Integer);
    Xbios(7);

  FUNCTION readcolor(Colornum, Color: Integer): Integer;
    Xbios(7);

  PROCEDURE set_color_registers(Var Header: HeadType);
    Var I: Integer;
       BEGIN
          For I:=0 to 15 do setcolor(I,Header[I+2])
       END;

  PROCEDURE read_color_registers(Var Header: HeadType);
      Var I: Integer;
         BEGIN
            For I:=0 to 15 do Header[I+2]:=readcolor(I,-1)
         END;

  PROCEDURE readfield;
     VAR
       i, j, k , l, m, start : integer;

   BEGIN
     Show_Mouse;
     IF Get_In_File (path, filename) THEN
      BEGIN
       reset (inbuf,filename);
       read (inbuf,start);
       read (inbuf,i);
       IF start < maxlevel THEN
      BEGIN
       IF (start+i) >= maxlevel THEN i := maxlevel - start;
       FOR j := start to (start+i-1) DO
         BEGIN
           FOR k := 2 to 39 DO
             BEGIN
               FOR l := 1 to 5 DO
                 BEGIN
                 read (inbuf,m);
                 fields[j][l][k] := m;
                 END;
             END;
          END;
      END;
      END;
     Hide_Mouse;
   END;

  PROCEDURE drawfield;
    VAR
      i,j,k,l : integer;

    BEGIN
      Paint_Color(cfield); Paint_Rect (100,5,190,190);
      FOR i := 1 TO 40 DO
        BEGIN
          FOR j := 1 TO 5 DO
            BEGIN
              k := fields [level,j,i];
              FOR l := 8 DOWNTO 1 DO
                BEGIN
                  field [(j-1)*8+l,i] := k MOD 2;
                  k := shr (k,1)
                END;
            END;
        END;
      Paint_Color (cwall);
      FOR i := 2 TO 39 DO
        FOR j := 2 TO 39 DO
          IF field [i,j] > 0 THEN
          BEGIN
            Line_Color (11);
            frame_Rect (5*(i-1)+95,5*(j-1),5,5);
            Line_Color (10);
            frame_rect (5*(i-1)+96,5*(j-1)+1,3,3);
            Line_Color (8);
            Plot (5*(i-1)+97,5*(j-1)+2);
          END;
      Line_Color (8); frame_rect (99,4,192,192);
      Line_Color (9); frame_rect (98,3,194,194);
      Line_Color (10); frame_rect (97,2,196,196);
      Line_Color (11); frame_rect (96,1,198,198);
      Line_Color (12); frame_rect (95,0,200,200);

    END;

  PROCEDURE newdirection;
    BEGIN
        event := 0;
        IF testtast (2) < 0 THEN event := int(shr(gettast(2),16));
        dirold := dir;
        CASE event OF
          75 : dir := (dir + 3) MOD 4;
          77 : dir := (dir + 1) MOD 4;
        END { case };
        xsold := xs; ysold := ys;
        pxsold := pxs; pysold := pys;
        CASE dir OF
          1: BEGIN
               ys := ys - 1;
               pys := pys - 5
             END;
          2: BEGIN
               xs := xs + 1;
               pxs := pxs + 5
             END;
          3: BEGIN
               ys := ys + 1;
               pys := pys + 5
             END;
          0: BEGIN
               xs := xs - 1;
               pxs := pxs - 5
             END;
          END {case};
    END;

  PROCEDURE drawapple;
    VAR
      x,y : integer;
    BEGIN
      REPEAT
      x := Trunc(38*random/$ffffff)+2;
      y := Trunc(38*random/$ffffff)+2;
      UNTIL field [x,y] = 0;
      field [x,y] := -1;
      x := 5*(x-2)+100; y := 5*(y-1)  ;
      draw_sprite (x,y,applesprite,save)
    END;

  PROCEDURE drawsnake;

    VAR
      i : integer;

    BEGIN
        field[xsold,ysold] := dir + 1;
        Paint_Color(csnake);
        CASE dir OF
          1 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodyv,save);
                  2 : draw_sprite (pxsold,pysold,bodytl,save);
                  3 : draw_sprite (pxsold,pysold,bodyv,save);
                  0 : draw_sprite (pxsold,pysold,bodytu,save)
                END;
                draw_sprite (pxs,pys,headu,save);
              END;
          2 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodytr,save);
                  2 : draw_sprite (pxsold,pysold,bodyh,save);
                  3 : draw_sprite (pxsold,pysold,bodytu,save);
                  0 : draw_sprite (pxsold,pysold,bodyh,save)
                END;
                draw_sprite (pxs,pys,headr,save);
              END;
          3 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodyv,save);
                  2 : draw_sprite (pxsold,pysold,bodytd,save);
                  3 : draw_sprite (pxsold,pysold,bodyv,save);
                  0 : draw_sprite (pxsold,pysold,bodytr,save)
                END;
                draw_sprite (pxs,pys,headd,save);
              END;
          0 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodytd,save);
                  2 : draw_sprite (pxsold,pysold,bodyh,save);
                  3 : draw_sprite (pxsold,pysold,bodytl,save);
                  0 : draw_sprite (pxsold,pysold,bodyh,save)
                END;
                draw_sprite (pxs,pys,headl,save);
              END;
        END; { case }
        IF tail <= 0 THEN
          BEGIN
            dire := field[xe,ye] - 1;
            field[xe,ye] := 0;
            Paint_Color(cfield);
            Paint_Rect (pxe,pye,5,5);
            CASE dire OF
              1 : BEGIN
                    ye := ye - 1;
                    pye := pye - 5;
                  END;
              2 : BEGIN
                    xe := xe + 1;
                    pxe := pxe + 5;
                  END;
              3 : BEGIN
                    ye := ye + 1;
                    pye := pye + 5;
                  END;
              0 : BEGIN
                    xe := xe - 1;
                    pxe := pxe - 5;
                  END;
            END; { case }
            dire := field[xe,ye] - 1;
            CASE dire OF
              1 :  draw_sprite (pxe,pye,tailu,save);
              2 :  draw_sprite (pxe,pye,tailr,save);
              3 :  draw_sprite (pxe,pye,taild,save);
              0 :  draw_sprite (pxe,pye,taill,save);
            END; { case }
          END
          ELSE FOR i := 1 to 300 do j :=0;
    END;

FUNCTION gia_read (data, register : integer) : integer;
  XBIOS (28);

PROCEDURE gia_write (data, register : integer);
  XBIOS (28);

PROCEDURE sound_init;

  CONST
    chan_enable = 7;
    cmd_read = 0;
    enable_sound = 7;
    cmd_write = 128;

  VAR
    port_state : integer;

  BEGIN
    port_state := gia_read ( 0, chan_enable+cmd_read );
    gia_write ((port_state&(~enable_sound))|$38, chan_enable+cmd_write);
  END;

PROCEDURE sound (ch, pitch, vol: integer);

  CONST
    chana_vol = 8;
    chana_lo = 0;
    chana_hi = 1;
    cmd_write = 128;

  BEGIN
    gia_write (vol, chana_vol+ch+cmd_write);
    gia_write (pitch&$ff, chana_lo+ch*2+cmd_write);
    gia_write (shr(pitch,8), chana_hi+ch*2+cmd_write);
  END;

PROCEDURE sound_off;

  CONST
    chan_enable = 7;
    cmd_read = 0;
    enable_sound = 7;
    cmd_write = 128;

  VAR
  port_state : integer;

  BEGIN
    sound (0,0,0);
    sound (1,0,0);
    sound (2,0,0);
    port_state := gia_read ( 0, chan_enable+cmd_read );
    gia_write (port_state|enable_sound, chan_enable+cmd_write);
  END;

  PROCEDURE hurray;
    VAR
      i,j : integer;
    BEGIN
      level := 1;
      sound_init;
      FOR i := 600 DOWNTO 40 DO
        BEGIN
          sound (0,i,15);
          sound (1,i-20,15);
          sound (2,600-(i MOD 90),15);
          FOR j := 1 TO 1200 DO ;
        END;
      sound_off;
    END;

PROCEDURE text_height ( height : integer );

  TYPE
    ctrl_parms = ARRAY [0..11] OF integer;
    int_in_parms = ARRAY [0..15] OF integer;
    int_out_parms = ARRAY [0..45] OF integer;
    pts_in_parms = ARRAY [0..11] OF integer;
    pts_out_parms = ARRAY [0..11] OF integer;

  VAR
    control : ctrl_parms;
    int_in : int_in_parms;
    int_out : int_out_parms;
    pts_in : pts_in_parms;
    pts_out : pts_out_parms;

  PROCEDURE VDI_Call (cmd, sub_cmd, nints, npts : integer;
                      VAR ctrl : ctrl_parms;
                      VAR int_in : int_in_parms;
                      VAR int_out : int_out_parms;
                      VAR pts_in : pts_in_parms;
                      VAR pts_out : pts_out_parms;
                      translate : boolean );
    EXTERNAL;

  BEGIN
    pts_in [0] := 0;
    pts_in [1] := height;
    VDI_Call (12,0,0,2,control, int_in, int_out, pts_in, pts_out, false);
  END;

PROCEDURE startpicture;
  BEGIN
    Paint_Style(1);
    Paint_Color (cback); Paint_Rect (0,0,95,200);
    Paint_Color (cback); Paint_Rect (295,0,25,200);
    Line_Color (1);
    Frame_Rect (304,49,8,102);
    Line_Color (8);
    Frame_Rect (303,48,10,104);
    Line_Color (9);
    Frame_Rect (302,47,12,106);
    Line_Color (10);
    Frame_Rect (301,46,14,108);
    Line_Color (11);
    Frame_Rect (300,45,16,110);
    Line_Color (12);
    Frame_Rect (299,44,18,112);
    draw_mode (2); Text_Color (9);
    Text_Height (4); Text_Style ($10);
    draw_string (305,165,'T');
    draw_string (305,174,'I');
    draw_string (305,183,'M');
    draw_string (305,192,'E');
    Text_Style ($0); Text_Color (1);
    draw_string (305,165,'T');
    draw_string (305,174,'I');
    draw_string (305,183,'M');
    draw_string (305,192,'E');
    Text_Color (ctext);
    Line_Color (0); Frame_Rect (0,0,95,54);
    Line_Color (13); Frame_Rect (1,1,93,52);
    Line_Color (12); Frame_Rect (2,2,91,50);
    Line_Color (11); Frame_Rect (3,3,89,48);
    Line_Color (10); Frame_Rect (4,4,87,46);
    Line_Color (9); Frame_Rect (5,5,85,44);
    Line_Color (8); Frame_Rect (6,6,83,42);
    Line_Color (1); Frame_Rect (7,7,81,40);
    Paint_Color (6); Paint_Rect (8,8,79,38);
    Text_Color (ctext);
    Text_Height (16);
    draw_string (15,35,'SLITHER');
    Line_Color (0); Frame_Rect (0,138,95,62);
    Line_Color (13); Frame_Rect (1,139,93,60);
    Line_Color (12); Frame_Rect (2,140,91,58);
    Line_Color (11); Frame_Rect (3,141,89,56);
    Line_Color (10); Frame_Rect (4,142,87,54);
    Line_Color (9); Frame_Rect (5,143,85,52);
    Line_Color (8); Frame_Rect (6,144,83,50);
    Line_Color (1); Frame_Rect (7,145,81,48);
    Paint_Color (6); Paint_Rect (8,146,79,46);
    Text_Color (15);
    Text_Height (6); Text_Style ($10);
    draw_string (14,156,'HISCORE');
    draw_string (14,178,' SCORE');
    Text_Height (6); Text_Color (3);
    Text_style ($10);
    draw_string (8,75,'LEVEL:   ');
    Text_style ($0);
    draw_string (8,100,'APPLES:   ');
    draw_string (8,120,'SNAKES:   ');
  END;

PROCEDURE definesprites;
  VAR
    i : integer;

  BEGIN

  applesprite [1] := 0; applesprite [2] := 0;
  applesprite [3] := 0; applesprite [4] := capple; applesprite [5] := cback;
  applesprite [6] := $0000; applesprite [7] := $2000;
  applesprite [8] := $7000; applesprite [9] := 0;
  applesprite [10] := $f800; applesprite [11] := 0;
  applesprite [12] := $f800; applesprite [13] := 0;
  applesprite [14] := $7000; applesprite [15] := 0;
  FOR i := 16 TO 37 DO applesprite [i] := 0;

  headr [1] := 0; headr [2] := 0;
  headr [3] := 0; headr [4] := csnake; headr [5] := csnakeeye;
  headr [6] := $6000; headr [7] := 0;
  headr [8] := $b800; headr [9] := $4000;
  headr [10] := $f800; headr [11] := 0;
  headr [12] := $b800; headr [13] := $4000;
  headr [14] := $6000; headr [15] := $0;
  FOR i := 16 TO 37 DO headr [i] := 0;

  headu [1] := 0; headu [2] := 0;
  headu [3] := 0; headu [4] := csnake; headu [5] := csnakeeye;
  headu [6] := $7000; headu [7] := 0;
  headu [8] := $7000; headu [9] := 0;
  headu [10] := $f800; headu [11] := 0;
  headu [12] := $a800; headu [13] := $5000;
  headu [14] := $7000; headu [15] := 0;
  FOR i := 16 TO 37 DO headu [i] := 0;

  headl [1] := 0; headl [2] := 0;
  headl [3] := 0; headl [4] := csnake; headl [5] := csnakeeye;
  headl [6] := $3000; headl [7] := 0;
  headl [8] := $e800; headl [9] := $1000;
  headl [10] := $f800; headl [11] := 0;
  headl [12] := $e800; headl [13] := $1000;
  headl [14] := $3000; headl [15] := $0;
  FOR i := 16 TO 37 DO headl [i] := 0;

  headd [1] := 0; headd [2] := 0;
  headd [3] := 0; headd [4] := csnake; headd [5] := csnakeeye;
  headd [6] := $7000; headd [7] := 0;
  headd [8] := $a800; headd [9] := $5000;
  headd [10] := $f800; headd [11] := $0;
  headd [12] := $7000; headd [13] := 0;
  headd [14] := $7000; headd [15] := 0;
  FOR i := 16 TO 37 DO headd [i] := 0;

  bodyh [1] := 0; bodyh [2] := 0;
  bodyh [3] := 0; bodyh [4] := csnake; bodyh [5] := csnakeeye;
  bodyh [6] := $0000; bodyh [7] := $f800;
  bodyh [8] := $d800; bodyh [9] := $2000;
  bodyh [10] := $a800; bodyh [11] := $5000;
  bodyh [12] := $d800; bodyh [13] := $2000;
  bodyh [14] := $0000; bodyh [15] := $f800;
  FOR i := 16 TO 37 DO bodyh [i] := 0;

  bodyv [1] := 0; bodyv [2] := 0;
  bodyv [3] := 0; bodyv [4] := csnake; bodyv [5] := csnakeeye;
  bodyv [6] := $7000; bodyv [7] := $8800;
  bodyv [8] := $5000; bodyv [9] := $a800;
  bodyv [10] := $2000; bodyv [11] := $d800;
  bodyv [12] := $5000; bodyv [13] := $a800;
  bodyv [14] := $7000; bodyv [15] := $8800;
  FOR i := 16 TO 37 DO bodyv [i] := 0;

  bodytu [1] := 0; bodytu [2] := 0;
  bodytu [3] := 0; bodytu [4] := csnake; bodytu [5] := csnakeeye;
  bodytu [6] := $7000; bodytu [7] := $8800;
  bodytu [8] := $4800; bodytu [9] := $b000;
  bodytu [10] := $4800; bodytu [11] := $b000;
  bodytu [12] := $3800; bodytu [13] := $c000;
  bodytu [14] := $0000; bodytu [15] := $7800;
  FOR i := 16 TO 37 DO bodytu [i] := 0;

  bodytl [1] := 0; bodytl [2] := 0;
  bodytl [3] := 0; bodytl [4] := csnake; bodytl [5] := csnakeeye;
  bodytl [6] := $7000; bodytl [7] := $8800;
  bodytl [8] := $9000; bodytl [9] := $6800;
  bodytl [10] := $9000; bodytl [11] := $6800;
  bodytl [12] := $e000; bodytl [13] := $1800;
  bodytl [14] := $0000; bodytl [15] := $f000;
  FOR i := 16 TO 37 DO bodytl [i] := 0;

  bodytd [1] := 0; bodytd [2] := 0;
  bodytd [3] := 0; bodytd [4] := csnake; bodytd [5] := csnakeeye;
  bodytd [6] := $0000; bodytd [7] := $f000;
  bodytd [8] := $e000; bodytd [9] := $1800;
  bodytd [10] := $9000; bodytd [11] := $6800;
  bodytd [12] := $9000; bodytd [13] := $6800;
  bodytd [14] := $7000; bodytd [15] := $8800;
  FOR i := 16 TO 37 DO bodytd [i] := 0;

  bodytr [1] := 0; bodytr [2] := 0;
  bodytr [3] := 0; bodytr [4] := csnake; bodytr [5] := csnakeeye;
  bodytr [6] := $0000; bodytr [7] := $7800;
  bodytr [8] := $3800; bodytr [9] := $c000;
  bodytr [10] := $4800; bodytr [11] := $b000;
  bodytr [12] := $4800; bodytr [13] := $b000;
  bodytr [14] := $7000; bodytr [15] := $8800;
  FOR i := 16 TO 37 DO bodytr [i] := 0;

  tailr [1] := 0; tailr [2] := 0;
  tailr [3] := 0; tailr [4] := 5; tailr [5] := csnakeeye;
  tailr [6] := $c000; tailr [7] := $2000;
  tailr [8] := $8000; tailr [9] := $4000;
  tailr [10] := $0000; tailr [11] := $8000;
  tailr [12] := $8000; tailr [13] := $4000;
  tailr [14] := $c000; tailr [15] := $2000;
  FOR i := 16 TO 37 DO tailr [i] := 0;

  tailu [1] := 0; tailu [2] := 0;
  tailu [3] := 0; tailu [4] := 5; tailu [5] := csnakeeye;
  tailu [6] := $0000; tailu [7] := $0000;
  tailu [8] := $0000; tailu [9] := $0000;
  tailu [10] := $0000; tailu [11] := $8800;
  tailu [12] := $8800; tailu [13] := $5000;
  tailu [14] := $d800; tailu [15] := $2000;
  FOR i := 16 TO 37 DO tailu [i] := 0;

  taill [1] := 0; taill [2] := 0;
  taill [3] := 0; taill [4] := 5; taill [5] := csnakeeye;
  taill [6] := $1800; taill [7] := $2000;
  taill [8] := $0800; taill [9] := $1000;
  taill [10] := $0000; taill [11] := $0800;
  taill [12] := $0800; taill [13] := $1000;
  taill [14] := $1800; taill [15] := $2000;
  FOR i := 16 TO 37 DO taill [i] := 0;

  taild [1] := 0; taild [2] := 0;
  taild [3] := 0; taild [4] := 5; taild [5] := csnakeeye;
  taild [6] := $d800; taild [7] := $2000;
  taild [8] := $8800; taild [9] := $5000;
  taild [10] := $0000; taild [11] := $8800;
  taild [12] := $0000; taild [13] := $0000;
  taild [14] := $0000; taild [15] := $0000;
  FOR i := 16 TO 37 DO taild [i] := 0;

  stars [1] := 0; stars [2] := 0;
  stars [3] := 0; stars [4] := 13; stars [5] := csnakeeye;
  stars [6] := $0800; stars [7] := $0000;
  stars [8] := $2a24; stars [9] := $0000;
  stars [10] := $1c18; stars [11] := $0000;
  stars [12] := $7f18; stars [13] := $0000;
  stars [14] := $1c24; stars [15] := $0000;
  stars [16] := $2a00; stars [17] := $0000;
  stars [18] := $0808; stars [19] := $0000;
  stars [20] := $002a; stars [21] := $0000;
  stars [22] := $001c; stars [23] := $0000;
  stars [24] := $007f; stars [25] := $0000;
  stars [26] := $281c; stars [27] := $0000;
  stars [28] := $542a; stars [29] := $0000;
  stars [30] := $3808; stars [31] := $0000;
  stars [32] := $5400; stars [33] := $0000;
  stars [34] := $2800; stars [35] := $0000;
  stars [36] := $0000; stars [37] := $0000;

  END;

PROCEDURE firstfields;

  VAR
    i,j,k,l : integer;

  BEGIN

  { 2 }
  FOR i := 2 TO 4 DO
    fields [2,i,21] := $ff;

  { 3 }
  FOR i := 12 to 30 DO
    fields [3,3,i] := $08;
  fields [3,3,21] := $ff;
  fields [3,2,21] := $1f;
  fields [3,4,21] := $fc;

  { 4 }
  FOR i := 12 TO 30 DO
    fields [4,2,i] := $08;
  fields [4,2,12] := $0f;
  fields [4,3,12] := $ff;
  fields [4,4,12] := $f0;
  fields [4,2,21] := $0f;
  fields [4,3,21] := $ff;
  fields [4,4,21] := $f0;
  fields [4,2,30] := $0f;
  fields [4,3,30] := $ff;
  fields [4,4,30] := $f0;

  { 5 }
  FOR i := 12 TO 30 DO
    BEGIN
      fields [5,2,i] := $10;
      fields [5,3,i] := $08;
      fields [5,4,i] := $04
    END;
  fields [5,2,21] := $1f;
  fields [5,3,21] := $ff;
  fields [5,4,21] := $fc;

  { 6 }
  FOR i := 14 TO 28 DO
    BEGIN
      fields [6,2,i] := $20;
      fields [6,4,i] := $04
    END;
  fields [6,3,14] := $7f;
  fields [6,4,14] := $fc;
  fields [6,2,21] := $3f;
  fields [6,3,21] := $fe;
  fields [6,3,28] := $7f;
  fields [6,4,28] := $fc;

  { 7 }
  FOR i := 12 TO 30 DO
    BEGIN
      fields [7,2,i] := $20;
      fields [7,4,i] := $04;
    END;
  fields [7,3,12] := $ff;
  fields [7,4,12] := $fc;
  fields [7,2,18] := $3f;
  fields [7,3,18] := $ff;
  fields [7,3,24] := $ff;
  fields [7,4,24] := $fc;
  fields [7,2,30] := $3f;
  fields [7,3,30] := $ff;

  { 8 }
  FOR i := 9 TO 32 DO
    BEGIN
      fields [8,1,i] := $84;
      fields [8,2,i] := $21;
      fields [8,3,i] := $08;
      fields [8,4,i] := $42;
      fields [8,5,i] := $11
    END;

  { 9 }
  fields [9,1,21] := $ff;
  fields [9,2,21] := $ff;
  fields [9,3,21] := $e7;
  fields [9,4,21] := $ff;
  fields [9,5,21] := $ff;

  { 10 }
  FOR i := 11 TO 30 DO
    BEGIN
      fields [10,2,i] := $20;
      fields [10,4,i] := $04;
    END;
  fields [10,2,11] := $3f;
  fields [10,3,11] := $e7;
  fields [10,4,11] := $fc;
  fields [10,2,30] := $3f;
  fields [10,3,30] := $ff;
  fields [10,4,30] := $fc;

  { 11 }
  FOR i := 19 TO 23 DO
      fields [11,3,i] := $08;
  FOR i := 12 TO 30 DO
    BEGIN
      fields [11,2,i] := $20;
      fields [11,4,i] := $04;
    END;
  fields [11,2,21] := $00;
  fields [11,4,21] := $00;
  fields [11,2,12] := $3f;
  fields [11,3,12] := $ff;
  fields [11,4,12] := $fc;
  fields [11,2,30] := $3f;
  fields [11,3,30] := $ff;
  fields [11,4,30] := $fc;

  { 12 }
  FOR i := 11 TO 30 DO
    BEGIN
      fields [12,2,i] := $20;
      fields [12,3,i] := $08;
      fields [12,4,i] := $04;
    END;
  fields [12,2,20] := $00;
  fields [12,4,20] := $00;
  fields [12,2,21] := $00;
  fields [12,4,21] := $00;
  fields [12,2,11] := $3f;
  fields [12,3,11] := $ff;
  fields [12,4,11] := $fc;
  fields [12,2,30] := $3f;
  fields [12,3,30] := $ff;
  fields [12,4,30] := $fc;

  { 13 }
  FOR i := 11 TO 31 DO
    BEGIN
      fields [13,2,i] := $20;
      fields [13,4,i] := $04;
    END;
  fields [13,2,11] := $21;
  fields [13,3,11] := $ff;
  fields [13,4,11] := $fc;
  fields [13,2,16] := $3f;
  fields [13,3,16] := $ff;
  fields [13,4,16] := $84;
  fields [13,2,21] := $21;
  fields [13,3,21] := $ff;
  fields [13,4,21] := $fc;
  fields [13,2,26] := $3f;
  fields [13,3,26] := $ff;
  fields [13,4,26] := $84;
  fields [13,2,31] := $21;
  fields [13,3,31] := $ff;
  fields [13,4,31] := $fc;

  { 14 }
  FOR i := 6 TO 35 DO
    BEGIN
      fields [14,1,i] := $84;
      fields [14,3,i] := $10;
      fields [14,5,i] := $21;
    END;
  fields [14,1,6] := $87;
  fields [14,2,6] := $ff;
  fields [14,3,6] := $f7;
  fields [14,4,6] := $ff;
  fields [14,5,6] := $e1;
  fields [14,3,10] := $00;
  fields [14,1,20] := $87;
  fields [14,2,20] := $bf;
  fields [14,3,20] := $f7;
  fields [14,4,20] := $fd;
  fields [14,5,20] := $e1;
  fields [14,1,21] := $80;
  fields [14,3,21] := $00;
  fields [14,5,21] := $01;
  fields [14,3,31] := $00;
  fields [14,1,35] := $87;
  fields [14,2,35] := $ff;
  fields [14,3,35] := $f7;
  fields [14,4,35] := $ff;
  fields [14,5,35] := $e1;

  { 15 }
  k := $20;
  FOR i := 2 TO 39 DO
    BEGIN
      IF i = 20 THEN k := $04;
      fields [15,3,i] := k;
    END;
  FOR i := 1 TO 3 DO
    BEGIN
      fields [15,3,i*10] := $0;
      fields [15,3,i*10+1] := $0;
    END;
  fields [15,1,19] := $ff;
  fields [15,2,19] := $ff;
  fields [15,3,19] := $e0;
  fields [15,3,22] := $07;
  fields [15,4,22] := $ff;
  fields [15,5,22] := $ff;
  END;

PROCEDURE definefields;
  VAR
    i,j,k,l : integer;

  BEGIN

  FOR i := 1 TO 30 DO
    BEGIN
      FOR j := 1 TO 5 DO
        FOR k := 1 TO 40 DO fields [i,j,k] := 0;
    END;

  firstfields;

  { 16 }
  FOR i := 2 TO 39 DO
      fields [16,3,i] := $10;
  FOR i := 19 TO 23 DO
      fields [16,3,i] := $0;
  fields [16,1,21] := $ff;
  fields [16,2,21] := $ff;
  fields [16,3,21] := $83;
  fields [16,4,21] := $ff;
  fields [16,5,21] := $ff;

  { 17 }
  k:= $20;
  FOR i := 2 TO 39 DO
    BEGIN
      IF i = 20 THEN k := $04;
      fields [17,3,i] := k;
    END;
  fields [17,3,20] := $0;
  fields [17,3,21] := $0;
  fields [17,1,22] := $ff;
  fields [17,2,22] := $ff;
  fields [17,3,22] := $e4;
  fields [17,3,19] := $27;
  fields [17,4,19] := $ff;
  fields [17,5,19] := $ff;

  { 18 }
  FOR i := 2 TO 39 DO
      fields [18,3,i] := $10;
  fields [18,1,21] := $ff;
  fields [18,2,21] := $df;
  fields [18,3,21] := $ff;
  fields [18,4,21] := $fb;
  fields [18,5,21] := $ff;
  fields [18,3,11] := $00;
  fields [18,3,31] := $00;

  { 19 }
  FOR i := 6 TO 35 DO
    BEGIN
      fields [19,1,i] := $84;
      fields [19,5,i] := $21;
    END;
  fields [19,1,21] := $0;
  fields [19,5,21] := $0;
  FOR i := 11 TO 30 DO
    BEGIN
      fields [19,2,i] := $20;
      fields [19,4,i] := $04;
    END;
  fields [19,2,21] := $0;
  fields [19,4,21] := $0;
  fields [19,1,06] := $87;
  fields [19,2,06] := $ff;
  fields [19,3,06] := $f7;
  fields [19,4,06] := $ff;
  fields [19,5,06] := $e1;
  fields [19,1,35] := $87;
  fields [19,2,35] := $ff;
  fields [19,3,35] := $f7;
  fields [19,4,35] := $ff;
  fields [19,5,35] := $e1;
  fields [19,2,11] := $3f;
  fields [19,3,11] := $f7;
  fields [19,4,11] := $fc;
  fields [19,2,30] := $3f;
  fields [19,3,30] := $f7;
  fields [19,4,30] := $fc;

  { 20 }
  FOR i := 6 TO 35 DO
    BEGIN
      fields [20,1,i] := $84;
      fields [20,5,i] := $21;
    END;
  FOR i := 11 TO 30 DO
    BEGIN
      fields [20,2,i] := $20;
      fields [20,4,i] := $04;
    END;
  fields [20,4,20] := $0;
  fields [20,4,21] := $0;
  fields [20,1,06] := $87;
  fields [20,2,06] := $ff;
  fields [20,3,06] := $e7;
  fields [20,4,06] := $ff;
  fields [20,5,06] := $e1;
  fields [20,1,35] := $87;
  fields [20,2,35] := $ff;
  fields [20,3,35] := $e7;
  fields [20,4,35] := $ff;
  fields [20,5,35] := $e1;
  fields [20,2,11] := $3f;
  fields [20,3,11] := $ff;
  fields [20,4,11] := $fc;
  fields [20,2,30] := $3f;
  fields [20,3,30] := $ff;
  fields [20,4,30] := $fc;

  { 21 }
  k := $02; l := $40;
  FOR i := 2 TO 39 DO
    BEGIN
      IF i = 13 THEN BEGIN k := 0; l := 0 END;
      IF i = 15 THEN BEGIN k := $10; l := $08 END;
      IF i = 20 THEN BEGIN k := $00; l := $00 END;
      IF i = 22 THEN BEGIN k := $10; l := $08 END;
      IF i = 27 THEN BEGIN k := $00; l := $00 END;
      IF i = 29 THEN BEGIN k := $02; l := $40 END;
      fields [21,2,i] := k;
      fields [21,4,i] := l;
    END;
  fields [21,2,12] := $03;
  fields [21,3,12] := $e7;
  fields [21,4,12] := $c0;
  fields [21,1,15] := $ff;
  fields [21,2,15] := $f0;
  fields [21,4,15] := $0f;
  fields [21,5,15] := $ff;
  fields [21,1,26] := $ff;
  fields [21,2,26] := $f0;
  fields [21,4,26] := $0f;
  fields [21,5,26] := $ff;
  fields [21,2,29] := $03;
  fields [21,3,29] := $e7;
  fields [21,4,29] := $c0;

  { 22 }
  FOR i := 12 TO 29 DO
    BEGIN
      fields [22,2,i] := $20;
      fields [22,3,i] := $08;
      fields [22,4,i] := $02;
    END;
  fields [22,3,11] := $08;
  fields [22,3,30] := $08;
  fields [22,3,20] := $00;
  fields [22,3,22] := $00;
  fields [22,2,10] := $0f;
  fields [22,3,10] := $ff;
  fields [22,4,10] := $f8;
  fields [22,2,31] := $0f;
  fields [22,3,31] := $ff;
  fields [22,4,31] := $f8;
  fields [22,2,21] := $3f;
  fields [22,3,21] := $e3;
  fields [22,4,21] := $fe;

  { 23 }
  FOR i := 2 TO 39 DO
      fields [23,3,i] := $24;
  fields [23,3,09] := $04;
  fields [23,3,10] := $04;
  fields [23,3,31] := $20;
  fields [23,3,32] := $20;

  { 24 }
  j := 1;
  FOR i := 1 TO 19 DO
    BEGIN
      IF (i <> 9) AND (I <> 10) AND (I <> 11) THEN
        BEGIN
          fields [24,1,(i*2)+j] := $03;
          fields [24,2,(i*2)+j] := $ff;
          fields [24,3,(i*2)+j] := $f7;
          fields [24,4,(i*2)+j] := $ff;
          fields [24,5,(i*2)+j] := $c0;
        END
        ELSE j := 0;
    END;
  FOR i := 17 TO 24 DO
    fields [24,3,i] := fields [24,3,i] | $14;

  { 25 }
  FOR i := 8 TO 35 DO
      fields [25,1,i] := $12;
  fields [25,1,07] := $02;
  fields [25,1,06] := $02;
  fields [25,1,05] := $1f;
  FOR i := 14 TO 35 DO
      fields [25,2,i] := $49;
  fields [25,2,13] := $48;
  fields [25,2,12] := $48;
  fields [25,2,11] := $4f;
  fields [25,2,10] := $40;
  fields [25,2,09] := $40;
  fields [25,2,08] := $7f;
  fields [25,2,05] := $ff;
  FOR i := 21 TO 35 DO
      fields [25,3,i] := $24;
  fields [25,3,20] := $27;
  fields [25,3,19] := $20;
  fields [25,3,18] := $20;
  fields [25,3,17] := $3f;
  fields [25,3,14] := $ff;
  fields [25,3,11] := $ff;
  fields [25,3,08] := $ff;
  fields [25,3,05] := $ff;
  FOR i := 30 TO 35 DO
      fields [25,4,i] := $92;
  fields [25,4,29] := $93;
  fields [25,4,28] := $90;
  fields [25,4,27] := $90;
  fields [25,4,26] := $9f;
  fields [25,4,25] := $80;
  fields [25,4,24] := $80;
  fields [25,4,23] := $ff;
  fields [25,4,20] := $ff;
  fields [25,4,17] := $ff;
  fields [25,4,14] := $ff;
  fields [25,4,11] := $ff;
  fields [25,4,08] := $ff;
  fields [25,4,05] := $ff;
  fields [25,5,35] := $49;
  fields [25,5,34] := $41;
  fields [25,5,33] := $41;
  fields [25,5,32] := $79;
  fields [25,5,29] := $f9;
  fields [25,5,26] := $f9;
  fields [25,5,23] := $f9;
  fields [25,5,20] := $f9;
  fields [25,5,17] := $f9;
  fields [25,5,14] := $f9;
  fields [25,5,11] := $f9;
  fields [25,5,08] := $f9;
  fields [25,5,05] := $f9;

  { 26 }
  FOR i := 9 TO 31 DO
    BEGIN
      fields [26,1,i] := $a0;
      fields [26,3,i] := $14;
      fields [26,5,i] := $05
    END;
  fields [26,1,20] := $00;
  fields [26,3,20] := $00;
  fields [26,5,20] := $00;
  fields [26,1,19] := $bf;
  fields [26,2,19] := $ff;
  fields [26,3,19] := $f7;
  fields [26,4,19] := $ff;
  fields [26,5,19] := $fd;
  fields [26,1,21] := $bf;
  fields [26,2,21] := $ff;
  fields [26,3,21] := $f7;
  fields [26,4,21] := $ff;
  fields [26,5,21] := $fd;
  fields [26,1,09] := $bf;
  fields [26,2,09] := $cf;
  fields [26,3,09] := $f7;
  fields [26,4,09] := $f3;
  fields [26,5,09] := $fd;
  fields [26,1,31] := $bf;
  fields [26,2,31] := $cf;
  fields [26,3,31] := $f7;
  fields [26,4,31] := $f3;
  fields [26,5,31] := $fd;
  fields [26,2,10] := $48;
  fields [26,2,11] := $48;
  fields [26,2,32] := $48;
  fields [26,2,33] := $48;
  fields [26,4,07] := $12;
  fields [26,4,08] := $12;
  fields [26,4,29] := $12;
  fields [26,4,30] := $12;

  { 27 }
  FOR i := 2 TO 39 DO
    BEGIN
      fields [27,2,i] := $40;
      fields [27,3,i] := $10;
      fields [27,4,i] := $04
    END;
  FOR j := 1 TO 4 DO
    FOR i := 2 TO 4 DO
      fields [27,i,(j*10)-5] := $00;
  FOR i := 1 TO 3 DO
    BEGIN
      fields [27,1,i*10] := $f7;
      fields [27,2,i*10] := $fd;
      fields [27,3,i*10] := $ff;
      fields [27,4,i*10] := $7f;
      fields [27,5,i*10] := $df
    END;

  { 28 }
  FOR i := 2 TO 39 DO
    BEGIN
      fields [28,2,i] := $01;
      fields [28,3,i] := $55
    END;
  fields [28,2,20] := $00;
  fields [28,3,20] := $00;
  fields [28,3,19] := $ff;
  fields [28,3,21] := $ff;
  fields [28,3,02] := $11;
  fields [28,3,39] := $11;
  fields [28,2,18] := $00;
  fields [28,2,22] := $00;
  fields [28,3,18] := $44;
  fields [28,3,22] := $44;

  { 29 }
  FOR i := 2 TO 39 DO
    BEGIN
      fields [29,2,i] := $04;
      fields [29,4,i] := $20
    END;
  fields [29,2,02] := $11;
  fields [29,2,39] := $11;
  fields [29,4,02] := $88;
  fields [29,4,39] := $88;

  { 30 }
  FOR i := 1 TO 18 DO
    BEGIN
      fields [30,1,2*i+1] := $aa;
      fields [30,2,2*i+1] := $aa;
      fields [30,3,2*i+1] := $a5;
      fields [30,4,2*i+1] := $55;
      fields [30,5,2*i+1] := $55;
    END;

  { make frame }
  FOR i := 1 TO 30 DO
    BEGIN
      FOR j := 1 TO 5 DO
        BEGIN
          fields [i,j,1] := $ff;
          fields [i,j,40] := $ff
        END;
      FOR j := 2 TO 39 DO
        BEGIN
          dummy := fields [i,1,j];
          fields [i,1,j] := $80 | dummy;
          dummy := fields [i,5,j];
          fields [i,5,j] := $01 | dummy
        END;
    END;
  END; {procedure}


PROCEDURE convert ( value : long_integer; word : integer;
                   VAR text : string);

  BEGIN
    IF value = 0 THEN value := word;
    text := '';
    REPEAT
      BEGIN
        text := concat (chr((value MOD 10)+48),text);
        value := value DIV 10
      END;
    UNTIL value <= 0;
  END;

PROCEDURE titletext;
  BEGIN
    draw_mode (2);
    Text_Height(6);
    draw_string (160,15,'Slither');
    strings := concat ('by Thomas R. B',CHR(129),'rglin');
    draw_string (112,25,strings);
    strings := concat ( CHR(189),' 1988 Antic Publishing');
    draw_string (105,35,strings);
    Text_Height (4);
    strings := concat ('Portions of this product are');
    draw_string (105,50,strings);
    draw_string (105,58,'Copyright 1986 OSS and CCD.');
    draw_string (105,66,'Used by permission of OSS.');

    text_color(6);
    draw_string (105,82,'Eat all the apples to get to');
    strings := concat ('the next level, using ',CHR(4),' and ',CHR(3));
    draw_string (105,90,strings);
    draw_string (105,98,'to control Spencer the snake.');
    draw_string (105,106,'The right Shift key pauses the');
    draw_string (105,114,'game; Alternate returns to the');
    draw_string (105,122,'main menu.');
    
    text_color(15);
    draw_string (105,138,'Press  1 for practice');
    draw_string (105,146,'       2 for slow game');
    draw_string (105,154,'       5 to load new playfield');
    draw_string (105,162,'       6 to restore playfield');
    
    draw_string (105,178,'Press Space for normal game or');
    draw_string (105,186,'Escape to quit.');
    Text_Height (6);
  END;

  PROCEDURE totalscreen;
   BEGIN
    startpicture;
    draw_mode (4); Text_Height (6);
    text_Color (6);
    draw_string (16,166,'       '); draw_mode (2);
    Text_Color (3); convert (hiscore,0,strings);
    j := length (strings);
    draw_string (72-8*j,166,strings); draw_mode (1);
    drawfield;
    titletext;
   END;

{********************MONOCHROME SECTION*********************}

PROCEDURE mono;

LABEL
  2, 4, 5, 10;

VAR
  i,j,k,l,x,y, dummy, s1,s2,s3 : integer;


  PROCEDURE newdirection;
    BEGIN
        event := 0;
        IF testtast (2) < 0 THEN event := int(shr(gettast(2),16));
        dirold := dir;
        CASE event OF
          75 : dir := (dir + 3) MOD 4;
          77 : dir := (dir + 1) MOD 4;
        END { case };
        xsold := xs; ysold := ys;
        pxsold := pxs; pysold := pys;
        CASE dir OF
          1: BEGIN
               ys := ys - 1;
               pys := pys - 10
             END;
          2: BEGIN
               xs := xs + 1;
               pxs := pxs + 10
             END;
          3: BEGIN
               ys := ys + 1;
               pys := pys + 10
             END;
          0: BEGIN
               xs := xs - 1;
               pxs := pxs - 10
             END;
          END {case};
    END;

  PROCEDURE drawsnake;

    VAR
      i : integer;

    BEGIN
        field[xsold,ysold] := dir + 1;
        Paint_Color(csnake);
        CASE dir OF
          1 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodyv,save);
                  2 : draw_sprite (pxsold,pysold,bodytl,save);
                  3 : draw_sprite (pxsold,pysold,bodyv,save);
                  0 : draw_sprite (pxsold,pysold,bodytu,save)
                END;
                draw_sprite (pxs,pys,headu,save);
              END;
          2 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodytr,save);
                  2 : draw_sprite (pxsold,pysold,bodyh,save);
                  3 : draw_sprite (pxsold,pysold,bodytu,save);
                  0 : draw_sprite (pxsold,pysold,bodyh,save)
                END;
                draw_sprite (pxs,pys,headr,save);
              END;
          3 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodyv,save);
                  2 : draw_sprite (pxsold,pysold,bodytd,save);
                  3 : draw_sprite (pxsold,pysold,bodyv,save);
                  0 : draw_sprite (pxsold,pysold,bodytr,save)
                END;
                draw_sprite (pxs,pys,headd,save);
              END;
          0 : BEGIN
                CASE dirold OF
                  1 : draw_sprite (pxsold,pysold,bodytd,save);
                  2 : draw_sprite (pxsold,pysold,bodyh,save);
                  3 : draw_sprite (pxsold,pysold,bodytl,save);
                  0 : draw_sprite (pxsold,pysold,bodyh,save)
                END;
                draw_sprite (pxs,pys,headl,save);
              END;
        END; { case }
        IF tail <= 0 THEN
          BEGIN
            dire := field[xe,ye] - 1;
            field[xe,ye] := 0;
            Paint_Color(cfield);
            Paint_Rect (pxe,pye,10,10);
            CASE dire OF
              1 : BEGIN
                    ye := ye - 1;
                    pye := pye - 10;
                  END;
              2 : BEGIN
                    xe := xe + 1;
                    pxe := pxe + 10;
                  END;
              3 : BEGIN
                    ye := ye + 1;
                    pye := pye + 10;
                  END;
              0 : BEGIN
                    xe := xe - 1;
                    pxe := pxe - 10;
                  END;
            END; { case }
            dire := field[xe,ye] - 1;
            CASE dire OF
              1 :  draw_sprite (pxe,pye,tailu,save);
              2 :  draw_sprite (pxe,pye,tailr,save);
              3 :  draw_sprite (pxe,pye,taild,save);
              0 :  draw_sprite (pxe,pye,taill,save);
            END; { case }
          END
          ELSE FOR i := 1 to 300 do j :=0;
    END;


  PROCEDURE drawfield;
    VAR
      i,j,k,l : integer;

    BEGIN
      Paint_Style(1); Paint_Color(cback);
      Paint_Rect (190,00,400,400);
      draw_mode(1); Paint_Color(cwall); Paint_Outline( True );
      Paint_Style(5);
      Paint_Rect (190,0,400,400);
      Line_Color (0); frame_rect (199,9,382,382);
      frame_rect (190,0,400,400);
      Paint_Style(1); Paint_Color(cback);
      Paint_Rect (200,10,380,380);
      draw_mode(2);
      FOR i := 1 TO 40 DO
        BEGIN
          FOR j := 1 TO 5 DO
            BEGIN
              k := fields [level,j,i];
              FOR l := 8 DOWNTO 1 DO
                BEGIN
                  field [(j-1)*8+l,i] := k MOD 2;
                  k := shr (k,1)
                END;
            END;
        END;
      Paint_Color (0);
      FOR i := 2 TO 39 DO
        FOR j := 2 TO 39 DO
          IF field [i,j] > 0 THEN
          BEGIN
            Paint_Style (5);
            Paint_Rect (10*(i-1)+190,10*(j-1),10,10);
          END;
      Paint_Style(1);
    END;

  PROCEDURE drawapple;
    VAR
      x,y : integer;
    BEGIN
      REPEAT
      x := Trunc(38*random/$ffffff)+2;
      y := Trunc(38*random/$ffffff)+2;
      UNTIL field [x,y] = 0;
      field [x,y] := -1;
      x := 10*(x-2)+200; y := 10*(y-1)  ;
      draw_sprite (x,y,applesprite,save)
    END;

PROCEDURE startpicture;
  BEGIN
    draw_mode(1);
    Paint_Color (cback); Paint_Rect (0,0,640,400);
    draw_mode(2); Paint_Color(0); Paint_Outline( True );
    Line_Color (0);
    Frame_Rect (608,98,16,204);
    Line_Color (0);
    Frame_Rect (606,96,20,208);
    Line_Color (0);
    Frame_Rect (604,94,24,212);
    Line_Color (0);
    Frame_Rect (602,92,28,216);
    Line_Color (0);
    Frame_Rect (600,90,32,220);
    Line_Color (0);
    Frame_Rect (598,88,36,224);
    draw_mode (2); Text_Color (0);
    Text_Height (9); Text_Style ($10);
    draw_string (610,330,'T');
    draw_string (610,348,'I');
    draw_string (610,366,'M');
    draw_string (610,384,'E');
    Line_Color (0); Frame_Rect (0,0,190,108);
    Line_Color (0); Frame_Rect (2,2,186,104);
    Line_Color (0); Frame_Rect (4,4,182,100);
    Line_Color (0); Frame_Rect (6,6,178,96);
    Line_Color (0); Frame_Rect (8,8,174,92);
    Line_Color (0); Frame_Rect (10,10,170,88);
    Line_Color (0); Frame_Rect (12,12,166,84);
    Line_Color (0); Frame_Rect (14,14,162,80);
    Paint_Color (1); Paint_Rect (16,16,158,76);
    Text_Color (ctext);
    Text_Style ($0);
    Text_Height (32);
    draw_string (40,65,'SLITHER');
    Line_Color (0); Frame_Rect (0,276,190,124);
    Line_Color (0); Frame_Rect (2,278,186,120);
    Line_Color (0); Frame_Rect (4,280,182,116);
    Line_Color (0); Frame_Rect (6,282,178,112);
    Line_Color (0); Frame_Rect (8,284,174,108);
    Line_Color (0); Frame_Rect (10,286,170,104);
    Line_Color (0); Frame_Rect (12,288,166,100);
    Line_Color (0); Frame_Rect (14,290,162,96);
    Paint_Color (1); Paint_Rect (16,292,158,92);
    Text_Color (0);
    Text_Height (12); Text_Style ($10);
    draw_string (28,312,'HISCORE');
    draw_string (28,356,' SCORE');
    Text_Height (12); Text_Color (0);
    Text_style ($10);
    draw_string (16,150,'LEVEL:   ');
    Text_style ($0);
    draw_string (16,200,'APPLES:   ');
    draw_string (16,240,'SNAKES:   ');
  END;


PROCEDURE definesprites;
  VAR
    i : integer;

  BEGIN

  headr [1] := 0; headr [2] := 0;
  headr [3] := 0; headr [4] := csnake; headr [5] := csnakeeye;
  headr [6] := $ffc0; headr [7] := $7000;
  headr [8] := $ffc0; headr [9] := $fc00;
  headr [10] := $ffc0; headr [11] := $cf80;
  headr [12] := $ffc0; headr [13] := $ffc0;
  headr [14] := $ffc0; headr [15] := $ffc0;
  headr [16] := $ffc0; headr [17] := $ffc0;
  headr [18] := $ffc0; headr [19] := $ffc0;
  headr [20] := $ffc0; headr [21] := $cf80;
  headr [22] := $ffc0; headr [23] := $fc00;
  headr [24] := $ffc0; headr [25] := $7000;
  FOR i := 26 TO 37 DO headr [i] := 0;

  FOR i := 1 TO 37 DO headu [i] := headr [i];
  headu [7] := $1e00;
  headu [9] := $3f00;
  headu [11] := $3f00;
  headu [13] := $3f00;
  headu [15] := $7f80;
  headu [17] := $7f80;
  headu [19] := $dec0;
  headu [21] := $dec0;
  headu [23] := $ffc0;
  headu [25] := $7f80;

  FOR i := 1 TO 37 DO headl [i] := headr [i];
  headl [7] := $0380;
  headl [9] := $0fc0;
  headl [11] := $7cc0;
  headl [13] := $ffc0;
  headl [15] := $ffc0;
  headl [17] := $ffc0;
  headl [19] := $ffc0;
  headl [21] := $7cc0;
  headl [23] := $0fc0;
  headl [25] := $0380;

  FOR i := 1 TO 37 DO headd [i] := headr [i];
  headd [7] := $7f80;
  headd [9] := $ffc0;
  headd [11] := $dec0;
  headd [13] := $dec0;
  headd [15] := $7f80;
  headd [17] := $7f80;
  headd [19] := $3f00;
  headd [21] := $3f00;
  headd [23] := $3f00;
  headd [25] := $1e00;

  FOR i := 1 TO 37 DO bodyh [i] := headr [i];
  bodyh [7] := $6d80;
  bodyh [9] := $ffc0;
  bodyh [11] := $f3c0;
  bodyh [13] := $edc0;
  bodyh [15] := $dec0;
  bodyh [17] := $dec0;
  bodyh [19] := $edc0;
  bodyh [21] := $f3c0;
  bodyh [23] := $ffc0;
  bodyh [25] := $6d80;

  FOR i := 1 TO 37 DO bodyv [i] := headr [i];
  bodyv [7] := $7f80;
  bodyv [9] := $ffc0;
  bodyv [11] := $f3c0;
  bodyv [13] := $6d80;
  bodyv [15] := $dec0;
  bodyv [17] := $dec0;
  bodyv [19] := $6d80;
  bodyv [21] := $f3c0;
  bodyv [23] := $ffc0;
  bodyv [25] := $7f80;

  FOR i := 1 TO 37 DO bodytu [i] := headr [i];
  bodytu [7] := $7f80;
  bodytu [9] := $ffc0;
  bodytu [11] := $e3c0;
  bodytu [13] := $6dc0;
  bodytu [15] := $6ec0;
  bodytu [17] := $6ec0;
  bodytu [19] := $71c0;
  bodytu [21] := $3fc0;
  bodytu [23] := $1fc0;
  bodytu [25] := $0180;

  FOR i := 1 TO 37 DO bodytl [i] := headr [i];
  bodytl [7] := $7f80;
  bodytl [9] := $ffc0;
  bodytl [11] := $f3c0;
  bodytl [13] := $ed80;
  bodytl [15] := $dd80;
  bodytl [17] := $dd80;
  bodytl [19] := $e380;
  bodytl [21] := $ff00;
  bodytl [23] := $fe00;
  bodytl [25] := $6000;

  FOR i := 1 TO 37 DO bodytd [i] := headr [i];
  bodytd [7] := $6000;
  bodytd [9] := $fe00;
  bodytd [11] := $ff00;
  bodytd [13] := $e380;
  bodytd [15] := $dd80;
  bodytd [17] := $dd80;
  bodytd [19] := $ed80;
  bodytd [21] := $f3c0;
  bodytd [23] := $ffc0;
  bodytd [25] := $7f80;

  FOR i := 1 TO 37 DO bodytr [i] := headr [i];
  bodytr [7] := $0180;
  bodytr [9] := $1fc0;
  bodytr [11] := $3fc0;
  bodytr [13] := $71c0;
  bodytr [15] := $6ec0;
  bodytr [17] := $6ec0;
  bodytr [19] := $6dc0;
  bodytr [21] := $f3c0;
  bodytr [23] := $ffc0;
  bodytr [25] := $7f80;

  FOR i := 1 TO 37 DO tailr [i] := headr [i];
  tailr [7] := $0180;
  tailr [9] := $03c0;
  tailr [11] := $1bc0;
  tailr [13] := $dec0;
  tailr [15] := $fd40;
  tailr [17] := $fd40;
  tailr [19] := $dec0;
  tailr [21] := $1bc0;
  tailr [23] := $03c0;
  tailr [25] := $0180;

  FOR i := 1 TO 37 DO tailu [i] := headr [i];
  tailu [7] := $7f80;
  tailu [9] := $f3c0;
  tailu [11] := $edc0;
  tailu [13] := $7380;
  tailu [15] := $1e00;
  tailu [17] := $3f00;
  tailu [19] := $3f00;
  tailu [21] := $0c00;
  tailu [23] := $1e00;
  tailu [25] := $1e00;

  FOR i := 1 TO 37 DO taill [i] := headr [i];
  taill [7] := $6000;
  taill [9] := $f000;
  taill [11] := $f600;
  taill [13] := $dec0;
  taill [15] := $afc0;
  taill [17] := $afc0;
  taill [19] := $dec0;
  taill [21] := $f600;
  taill [23] := $f000;
  taill [25] := $6000;

  FOR i := 1 TO 37 DO taild [i] := headr [i];
  taild [7] := $1e00;
  taild [9] := $1e00;
  taild [11] := $0c00;
  taild [13] := $3f00;
  taild [15] := $3f00;
  taild [17] := $1e00;
  taild [19] := $7380;
  taild [21] := $edc0;
  taild [23] := $f3c0;
  taild [25] := $7f80;

  FOR i := 1 TO 37 DO applesprite [i] := headr [i];
  applesprite [7] := $0200;
  applesprite [9] := $0400;
  applesprite [11] := $3b00;
  applesprite [13] := $7f80;
  applesprite [15] := $ffc0;
  applesprite [17] := $ffc0;
  applesprite [19] := $ffc0;
  applesprite [21] := $ffc0;
  applesprite [23] := $7f80;
  applesprite [25] := $3700;

  stars [1] := 0; stars [2] := 0;
  stars [3] := 0; stars [4] := 1; stars [5] := 0;
  stars [6] := $7f7e; stars [7] := $0800;
  stars [8] := $7f7e; stars [9] := $2a24;
  stars [10] := $fffe; stars [11] := $1c18;
  stars [12] := $fffe; stars [13] := $7f18;
  stars [14] := $fffe; stars [15] := $1c24;
  stars [16] := $7f7e; stars [17] := $2a00;
  stars [18] := $7f7f; stars [19] := $0808;
  stars [20] := $1c7f; stars [21] := $002a;
  stars [22] := $00ff; stars [23] := $001c;
  stars [24] := $7cff; stars [25] := $007f;
  stars [26] := $feff; stars [27] := $281c;
  stars [28] := $fe7f; stars [29] := $542a;
  stars [30] := $fe7f; stars [31] := $3808;
  stars [32] := $fe1c; stars [33] := $5400;
  stars [34] := $fe00; stars [35] := $2800;
  stars [36] := $7c00; stars [37] := $0000;

  END;

PROCEDURE titletext;
  BEGIN
    text_color(0);
    draw_mode (2);
    draw_string (350,35,'Slither');
    strings := concat ('by Thomas R. B',CHR(129),'rglin');
    draw_string (234,55,strings);
    strings := concat ( CHR(189),' 1988 Antic Publishing');
    draw_string (210,75,strings);
    Text_Height (6);
    strings := concat ('Portions of this product are Copyright 1986,');
    draw_string (210,95,strings);
    draw_string (210,110,'OSS and CCD, Inc.  Used by permission of OSS.');
    Text_Height (9);
    draw_string (210,135,'Eat all the apples to get to');
    strings := concat ('the next level, using ',CHR(4),' and ',CHR(3));
    draw_string (210,155,strings);
    draw_string (210,175,'to control Spencer the snake.');
    draw_string (210,195,'The right Shift key pauses the');
    draw_string (210,215,'game; Alternate returns to the');
    draw_string (210,235,'main menu.');
    
    draw_string (210,270,'Press  1 for practice');
    draw_string (210,290,'       2 for slow game');
    draw_string (210,310,'       5 to load new playfield');
    draw_string (210,330,'       6 to restore playfield');
    
    draw_string (210,360,'Press Space for normal game or');
    draw_string (210,380,'Escape to quit.');
    Text_Height (12);
  END;

  PROCEDURE totalscreen;
   BEGIN
    startpicture;
    draw_mode (4); Text_Height (12);
    text_Color (1);
    draw_string (32,332,'       '); draw_mode (2);
    Text_Color (0); convert (hiscore,0,strings);
    j := length (strings);
    draw_string (144-16*j,332,strings); draw_mode (1);
    drawfield;
    titletext;
   END;

{************ main part of monochrome section *}

  BEGIN

  Set_Clip(0,0,640,400);
  cback := 1; {background}
  cframe := 0;
  cfield := 1; {fieldcolor}
  csnake := 1;
  csnakeeye := 0;
  capple := 0; {applecolor}
  cwall := 1; {walls of field}
  ctext := 0;
  ctext2 := 0;

  definesprites;
  definefields;
  score := 0; hiscore := 0;

 2: level := 1 ; snakes := 3;
    delaystart := 12850; maxlevel := 31;
    snakeincr := 1; appleincr := 3;
    scoreincr := 10;
    IF score > hiscore THEN hiscore := score ;
    score := 0;
    totalscreen;
 4: WHILE testtast (2) < 0 DO event := int(gettast(2)); {empty buffer}
    REPEAT UNTIL testtast (2) < 0;
    event := int(gettast(2));
    IF event = 27 THEN GOTO 80;
    IF event = 50 THEN
       BEGIN
       delaystart := 15950;
       maxlevel := 29;
       GOTO 5;
       END;
    IF event = 49 THEN
       BEGIN
       snakeincr := 0;
       appleincr := 0;
       scoreincr := 0;
       maxlevel := 29;
       GOTO 5;
       END;
    IF event = 53 THEN
       BEGIN
         readfield;
         totalscreen;
       END;
    IF event = 54 THEN definefields;
    IF event <> 32 THEN GOTO 4;

 5: applestart := 10 ; nocrash := true;
    IF level >= maxlevel THEN hurray;
    Text_Style($10);
    draw_mode (4); Text_Color (1);
    draw_string (140,150,'  ');
    draw_mode (2); Text_Color (0);
    convert (0,level,strings);
    draw_string (140,150,strings);
    Text_Style (0);

10: drawfield;
    apples := applestart; delay := delaystart;
    drawapple ;
    applesonfield := 1;
    time := 100;
    Paint_color (cback); Paint_Rect (610,100,12,200);
    draw_mode (4); Text_Color (1);
    draw_string (130,240,'   ');
    draw_mode (2);
    Text_Color (0); convert (0,snakes,strings);
    draw_string (130,240,strings);
    draw_mode (4); Text_Color (1);
    draw_string (130,200,'   ');
    draw_mode (2);
    Text_Color (0); convert (0,apples,strings);
    draw_string (130,200,strings);
    Text_Color (1); draw_mode (4);
    draw_string (32,376,'       '); draw_mode (2);
    Text_Color (0); convert (score,0,strings);
    j := length (strings);
    draw_string (144-16*j,376,strings);
    draw_mode (2);

    WHILE testtast (2) < 0 DO
      BEGIN
        event := int(gettast(2));
        IF event = 110 THEN BEGIN level := level + 1; GOTO 5 END;
      END; { while }
    xs := 21; ys := 39; {start of snake} xsold := 21; ysold := 40;
    pxs := 10*(xs-2)+200; pys := 10*(ys-2)+10;
    pxsold := pxs; pysold := pys;
    xe := 21; ye := 39;
    pxe := pxs; pye := pys;
    tail := 11;
    dir := 1; dirold := 1; {direction of snake at start}

    WHILE field[xs,ys] <= 0 DO { check for free field }

      BEGIN
        IF field [xs,ys] = 0 THEN field [xs,ys] := dir+1;
        IF field [xs,ys] = -10 THEN { check for exitfield }
          BEGIN
            drawsnake;
            snakes := snakes + snakeincr;
            IF nocrash AND (scoreincr = 10) THEN
              BEGIN
                score := score + level*20;
                draw_mode(1);
                Text_Height (48); Text_Color (1);
                draw_string (350,100,'BONUS');
                Text_Height (12);
              END;
            sound_init;
            FOR i := 400 DOWNTO 150 DO
              BEGIN
                FOR j := 1 TO 300 DO k:=0;
                sound (1,i,15);
                sound (2,i-20,15);
              END;
            sound_off;
            IF nocrash AND (scoreincr = 10) THEN
              BEGIN
                s1 := 564; s2 := 400; s3 := 476;
                FOR j := 1 TO 5 DO
                  BEGIN
                    sound_init;
                    s1 := round (s1/1.19);
                    s2 := round (s2/1.19);
                    s3 := round (s3/1.19);
                    sound (0,s1,15);
                    sound (1,s2,15);
                    sound (2,s3,15);
                    Text_Height (48); Text_Color (1);
                    FOR l := 1 TO 8 DO
                      BEGIN
                        draw_string (350,100+j*38,'BONUS');
                        FOR i := 1 TO 1200 DO ;
                        END;
                    sound_off;
                  END;
              Text_Height (12); draw_mode (1);
              END;
            level := level + 1;
            GOTO 5
          END;
        If field[xs,ys] = -1 THEN  { check for field with apple }
          BEGIN
            tail := tail + 11;

            apples := apples - 1;
            applesonfield := applesonfield - 1;
            draw_mode (4);
            Text_Color (1); draw_string (130,200,'   ');
            draw_mode (2);
            Text_Color (0); convert (0,apples,strings);
            draw_string (130,200,strings);

            score := score + level*scoreincr;
            Text_Color (1); draw_mode (4);
            draw_string (32,376,'       '); draw_mode (2);
            Text_Color (0); convert (score,0,strings);
            j := length (strings);
            draw_string (144-16*j,376,strings);
            draw_mode (1);

            delay := delay - delay DIV 52;

            time := 100;
            Paint_color (cback); Paint_Rect (610,100,12,200);

            IF apples <= 0 THEN
              BEGIN
                field [21,1] := -10;
                Paint_Color (cfield);
                Paint_Rect (10*(19)+200,0,10,10)
              END
            ELSE
                IF applesonfield <= 0 THEN
                 BEGIN
                   drawapple;
                   applesonfield := applesonfield + 1
                 END;
          END;
        sound_init;
        sound (0,300,13);
        drawsnake;
        sound_off;
        IF tail > 0 THEN tail := tail - 1;

        for y:= 1 to delay do;

        pausestate := shifttast(-1)&9;
        IF pausestate > 0 THEN     {pause game, exit game}
           BEGIN
              IF pausestate = 1 THEN
                 BEGIN
                   REPEAT
                   UNTIL Keypress;
                 END;
              IF pausestate = 8 THEN GOTO 2;
           END;

        newdirection;
        IF apples > 0 THEN
          BEGIN
            time := time - 1;
            Line_color (0); Line (610,2*time+100,621,2*time+100);
            Line (610,2*time+101,621,2*time+101);
            IF time <= 0 THEN
              BEGIN
                drawapple; drawapple; drawapple;
                apples := apples + 3;
                applestart := applestart + appleincr;
                time := 100;
                draw_mode (4); Text_Color (1);
                draw_string (130,200,'   ');
                draw_mode (2); Text_Color (0);
                convert (0,apples,strings);
                draw_string (130,200,strings);
                Paint_color (cback); Paint_Rect (610,100,12,200);
                applesonfield := applesonfield + 3;
              END;
          END;
      END; {while}
      i := 10*(xsold-2)+198; j := 10*(ysold-2)+7;
      IF j < 0 THEN j := 0;
      IF j > 384 THEN j := 384;
      draw_sprite (i,j,stars,save);
      nocrash := false;
      snakes := snakes - snakeincr;
            sound_init;
            FOR i := 100 TO 200 DO
              BEGIN
                  FOR l := 1 to 10 DO
                    BEGIN
                      sound (1,4*(i+l),15);
                      sound (2,4*(i-30),15);
                    END;
              END;
            sound_off;
      undraw_sprite (save);
      IF snakes > 0 THEN GOTO 10;
      GOTO 2;

END;

{***********************************************************************}

BEGIN { main program }
  IF Init_Gem < 0 THEN GOTO 90;
  read_color_registers(deskcolors);
  Init_Mouse; Hide_Mouse;
  keystate := s_peek_b ($484);
  s_poke_b ($484,keystate&$fe); {switch off keyclick}
  path := '\*.*';
  IF getrez = 2 THEN mono;
  IF getrez <> 0 THEN
    BEGIN
      x := Do_Alert ('[3][   SORRY!| |LOW REZ ONLY][ OK ]',1);
      GOTO 80
    END;
  Set_Clip(0,0,320,200);
  sound_off;
  Set_Color (0,0,0,0); { 0 : black }
  Set_Color (1,1000,1000,1000); { 1 : white }
  Set_Color (2,1000,0000,0000); { 2 : red   }
  Set_Color (3,0000,1000,0000); { 3 : green }
  Set_Color (4,0800,600,300); { 4 : light brown }
  Set_Color (5,600,400,200);  { 5 : dark brown }
  Set_Color (6,000,000,1000);  { 6 : blue       }
  Set_Color (7,0000,0600,0000); { 7 : dark green }
  Set_Color (8,800,800,800);  { 8 : grey 6     }
  Set_Color (9,700,700,700);  { 9 : grey 5     }
  Set_Color (10,600,600,600);  {10 : grey 4     }
  Set_Color (11,400,400,400);  {11 : grey 3     }
  Set_Color (12,300,300,300);  {12 : grey 2     }
  Set_Color (13,100,100,100);  {13 : grey 1     }
  Set_Color (14,1000,0,0); {14 : red start for bonus }
  Set_Color (15,1000,800,0);  {15 : yellow}
  cback := 0; {background}
  cframe := 4;
  cfield := 7; {fieldcolor}
  csnake := 4;
  csnakeeye := 6;
  capple := 1; {applecolor}
  cwall := 10; {walls of field}
  ctext := 2;
  ctext2 := 3;

  definesprites;
  definefields;
  score := 0; hiscore := 0;

 2: level := 1 ; snakes := 3;
    delaystart := 10350; maxlevel := 31;
    snakeincr := 1; appleincr := 3;
    scoreincr := 10;
    IF hiscore < score THEN hiscore := score ;
    score := 0;
    totalscreen;
 4: WHILE testtast (2) < 0 DO event := int(gettast(2)); {empty buffer}
    REPEAT UNTIL testtast (2) < 0;
    event := int(gettast(2));
    IF event = 27 THEN GOTO 80;
    IF event = 50 THEN
       BEGIN
       delaystart := 13100;
       maxlevel := 29;
       GOTO 5;
       END;
    IF event = 49 THEN
       BEGIN
       snakeincr := 0;
       appleincr := 0;
       scoreincr := 0;
       maxlevel := 29;
       GOTO 5;
       END;
    IF event = 53 THEN
      BEGIN
        readfield;
        totalscreen;
      END;
    IF event = 54 THEN definefields;
    IF event <> 32 THEN GOTO 4;

 5: applestart := 10 ; nocrash := true;
    IF level >= maxlevel THEN hurray;
    Text_Style($10);
    draw_string (70,75,'  ');
    Text_Color (3);
    convert (0,level,strings);
    draw_string (70,75,strings);
    Text_Style (0);

10: drawfield;
    apples := applestart; delay := delaystart;
    drawapple ;
    applesonfield := 1;
    time := 100;
    Paint_color (cback); Paint_Rect (305,50,6,100);
    draw_string (65,120,'   ');
    Text_Color (4); convert (0,snakes,strings);
    draw_string (65,120,strings);

    draw_string (65,100,'   ');
    Text_Color (2); convert (0,apples,strings);
    draw_string (65,100,strings);
    Text_Color (6); draw_mode (4);
    draw_string (16,188,'       '); draw_mode (2);
    Text_Color (3); convert (score,0,strings);
    j := length (strings);
    draw_string (72-8*j,188,strings);
    draw_mode (1);

    WHILE testtast (2) < 0 DO
      BEGIN
        event := int(gettast(2));
        IF event = 110 THEN BEGIN level := level + 1; GOTO 5 END;
      END; { while }
    xs := 21; ys := 39; {start of snake} xsold := 21; ysold := 40;
    pxs := 5*(xs-2)+100; pys := 5*(ys-2)+5;
    pxsold := pxs; pysold := pys;
    xe := 21; ye := 39;
    pxe := pxs; pye := pys;
    tail := 11;
    dir := 1; dirold := 1; {direction of snake at start}

    WHILE field[xs,ys] <= 0 DO { check for free field }

      BEGIN
        IF field [xs,ys] = 0 THEN field [xs,ys] := dir+1;
        IF field [xs,ys] = -10 THEN { check for exitfield }
          BEGIN
            drawsnake;
            snakes := snakes + snakeincr;
            IF nocrash AND (scoreincr = 10) THEN
              BEGIN
                score := score + level*20;
                draw_mode(2);
                Text_Height (12); Text_Color (14);
                draw_string (156,108,'BONUS');
                Text_Height (6); draw_mode (1);
              END;
            sound_init;
            FOR i := 400 DOWNTO 150 DO
              BEGIN
                FOR j := 1 TO 300 DO k:=0;
                sound (1,i,15);
                sound (2,i-20,15);
                sound (0,0,0)
              END;
            sound_off;
            IF nocrash AND (scoreincr = 10) THEN
              BEGIN
                s1 := 564; s2 := 400; s3 := 476;
                FOR j := 1 TO 5 DO
                  BEGIN
                    sound_init;
                    s1 := round (s1/1.19);
                    s2 := round (s2/1.19);
                    s3 := round (s3/1.19);
                    sound (0,s1,15);
                    sound (1,s2,15);
                    sound (2,s3,15);
                    draw_mode(2);
                    Text_Height (12); Text_Color (14);
                    FOR l := 1 TO 8 DO
                      BEGIN
                        Set_Color(14,1000,l*123,0);
                        draw_string (156,108,'BONUS');
                        FOR i := 1 TO 1200 DO ;
                        END;
                    sound_off;
                  END;
              Text_Height (6); draw_mode (1);
              Set_Color(14,1000,0,0);
              END;
            level := level + 1;
            GOTO 5
          END;
        If field[xs,ys] = -1 THEN  { check for field with apple }
          BEGIN
            tail := tail + 11;

            apples := apples - 1;
            applesonfield := applesonfield - 1;
            draw_string (65,100,'   ');
            Text_Color (2); convert (0,apples,strings);
            draw_string (65,100,strings);

            score := score + level*scoreincr;
            Text_Color (6); draw_mode (4);
            draw_string (16,188,'       '); draw_mode (2);
            Text_Color (3); convert (score,0,strings);
            j := length (strings);
            draw_string (72-8*j,188,strings);
            draw_mode (1);

            delay := delay - delay DIV 50;

            time := 100;
            Paint_color (cback); Paint_Rect (305,50,6,100);

            IF apples <= 0 THEN
              BEGIN
                field [21,1] := -10;
                Paint_Color (cfield);
                Paint_Rect (5*(19)+100,0,5,5)
              END
            ELSE
                IF applesonfield <= 0 THEN
                 BEGIN
                   drawapple;
                   applesonfield := applesonfield + 1
                 END;
          END;
        sound_init;
        sound (0,300,13);
        sound (1,0,0);
        sound (2,0,0);
        drawsnake;
        sound_off;
        IF tail > 0 THEN tail := tail - 1;
        for y:= 1 to delay do ;

        pausestate := shifttast(-1)&9;
        IF pausestate > 0 THEN     {pause game, exit game}
           BEGIN
              IF pausestate = 1 THEN
                 BEGIN
                   REPEAT
                   UNTIL Keypress;
                 END;
              IF pausestate = 8 THEN GOTO 2;
           END;

        newdirection;
        IF apples > 0 THEN
          BEGIN
            time := time - 1;
            Line_color (2); Line (305,time+50,310,time+50);
            IF time <= 0 THEN
              BEGIN
                drawapple; drawapple; drawapple;
                apples := apples + 3;
                applestart := applestart + appleincr;
                time := 100;
                Text_Color (cback);
                draw_string (65,100,'   ');
                Text_Color (2); convert (0,apples,strings);
                draw_string (65,100,strings);
                Paint_color (cback); Paint_Rect (305,50,6,100);
                applesonfield := applesonfield + 3;
              END;
          END;
      END; {while}
      i := 5*(xsold-2)+95; j := 5*(ysold-2)-1;
      IF j < 0 THEN j := 0;
      IF j > 184 THEN j := 184;
      draw_sprite (i,j,stars,save);
      nocrash := false;
      snakes := snakes - snakeincr;
            sound_init;
            FOR i := 100 TO 200 DO
              BEGIN
                  FOR l := 1 to 10 DO
                    BEGIN
                      sound (0,0,0);
                      sound (1,4*(i+l),15);
                      sound (2,4*(i-30),15);
                    END;
              END;
            sound_off;
      undraw_sprite (save);
      IF snakes > 0 THEN GOTO 10;
      GOTO 2;

  80: Show_Mouse;
      s_poke_b ($484,(keystate&$ff)); {switch on keyklick}
      set_color_registers(deskcolors);
      Exit_Gem ;
  90: ;
END.
