{*****************************************************************************}
{*****************************************************************************}
{                                                                             }
{                     Fractal Topographical Maps v0.2                         }
{                   Copyright (c) 1987 by Robert Adam II.                     }
{                         All rights reserved.                                }
{                                                                             }
{*****************************************************************************}
{*****************************************************************************}
{                                                                             }
{      WARNING:  This code is mostly uncommented and may be hazardous to      }
{               your mental health.                                           }
{                Don't blame me,  I warned you.                               }
{                                                                             }
{*****************************************************************************}
{*****************************************************************************}

program TOPMAP;

  const
    COPYRIGHT1 = ' Fractal Topographical Maps v0.2 ';
    COPYRIGHT2 = ' Copyright (c) 1987 by Robert Adam II. ';
    COPYRIGHT3 = ' All rights reserved. ';

    {$I A:\GEMCONST}
    {$I A:\VDICONST}

    PI = 3.1415936535;

    WSX = 10;
    WSY = 10;

    SCALEX = 290;
    SCALEY = WSY;
    SCALEW = 15;
    SCALEH = 130;

    MAXXTILES = 3;
    MAXYTILES = 2;

    MAXALTITUDE = 25000;
    RMAXALTITUDE = 25000.0;

    NUMLEVELS  = 7;
    FIRSTLEVEL = 1;

    PIXEL_SIZE = 1;
    MAP_SIZE = 65;
    PMAP_SIZE = 65;          { = MAP_SIZE * PIXEL_SIZE }
    PMAP_SIZE2 = 28;

    DESK_TITLE = 3;

    NUM_PLANES = 4;

{*****************************************************************************}

  type
    {$I A:\GEMTYPE}
    {$I A:\VDITYPE}

    SHADOWREGION = record
                     OHEIGHT,
                     OX, OY,
                     SLENGTH : integer
                   end;

    POINT3      = record
                    X, Y, Z : real
                  end;
    TRANSFORM = record
                  U, V, W : POINT3;
                  UE, VE, WE : real
                end;


    COLOR_VECTOR = array[ 0..15 ] of integer;

    MEMAREA     = array[ 1..16000 ] of integer;
    MEMPTR      = ^MEMAREA;

    LONGITUDE   = array[ 1..MAP_SIZE ] of integer;
    TILE_TYPE   = array[ 1..MAP_SIZE ] of LONGITUDE;
    TILETYPE    = ^TILE_TYPE;
    MAPTYPE     = array[ 1..MAXXTILES, 1..MAXYTILES ] of TILETYPE;

    POINT       = record
                    X, Y : integer
                  end;

{*****************************************************************************}


  var
    {$I A:\VDIVARS}

    SIDE,
    MAXX,
    MAXY  : integer;

    SUNANGLE,
    TANGENT : real;

    DEF_PATH,
    FILENAME : path_name;

    BRAND_NEW,
    WATCH_ON,
    SHADOW_ON : boolean;

    WX, WY : integer;

    MAP   : MAPTYPE;

    DUMMY : integer;

    QUANTUM : integer;

    XSCRN,
    YSCRN,
    WSCRN,
    HSCRN : integer;

  { Window variables }
    INFO_LINE,
    MAIN_TITLE : window_title;
    GRAPHICS_WINDOW : integer;


  { Menu variables }
    MENU : menu_ptr ;

    FILE_TITLE,
    OPTIONS_TITLE,
    VIEW_TITLE,
    WIDTH_ITEM,
    HEIGHT_ITEM,
    RESET_ITEM,
    WATCH_ITEM,
    WATER_ITEM,
    SHADOW_ITEM,
    NULL_ITEM,
    NULL2_ITEM,
    OLD_ITEM,
    NEW_ITEM,
    LOAD_ITEM,
    SAVE_ITEM,
    PERSPEC_ITEM,
    SIDE_ITEM,
    TOP_ITEM,
    QUIT_ITEM : integer ;

    OSS_DIALOG,
    ABOUT_DIALOG : dialog_ptr;


  { mfdb variables }
    PXY    : PXYARRAY;
    MEMORY : MEMPTR;
    S_MFDB,
    D_MFDB : mfdbptr;

    NUMXTILES,
    NUMYTILES : integer;

  { old color vector }
    OLD_COLOR : COLOR_VECTOR;

    WATER_LINE,
    WATER_LEVEL : integer;
    WATER_ON : boolean;
    LEVELS : array[ 1..NUMLEVELS ] of integer;

    SCALE_ON : boolean;

    LIGHT,
    SHADOW : array[ 1..7 ] of integer;

  {$I A:\GEMSUBS}
  {$I A:\VDIPROC}

{*****************************************************************************}
{*****************************************************************************}
{*****************************************************************************}

  function QUICK_EXIT : boolean;
    begin
      AES_CALL( 79, INT_IN, INT_OUT, ADDR_IN, ADDR_OUT );
      if (INT_OUT[ 3 ] & 3) <> 0
      then
        QUICK_EXIT := 1 = do_alert('[2][| Cancel?     |][Yes|No]',2)
      else
        QUICK_EXIT := false;
    end;

{*****************************************************************************}

  function setcolor( COLORNUM, COLOR : integer ) : integer;
    xbios( 7 );

  function GET_XCOLOR( COLORNUM : integer ) : integer;
    begin
      GET_XCOLOR := setcolor( COLORNUM, -1 );
    end;


  procedure SET_XCOLOR( COLORNUM, COLOR : integer);
    var
      DUMMY : integer;
    begin
      DUMMY := setcolor( COLORNUM, COLOR );
    end;


  procedure SAVE_COLORS;
    var
      COLORNUM : integer;
    begin
      for COLORNUM := 0 to 15 do
        OLD_COLOR[ COLORNUM ] := GET_XCOLOR( COLORNUM );
    end;


  procedure RESTORE_COLORS;
    var
      COLORNUM : integer;
    begin
      for COLORNUM := 0 to 15 do
        SET_XCOLOR( COLORNUM, OLD_COLOR[ COLORNUM ] );
    end;


  procedure SET_GEM_COLOR( COLORNUM, RED, GREEN, BLUE : integer );
    begin
      set_color( COLORNUM, RED*125, GREEN*125, BLUE*125 );
    end;

{*****************************************************************************}

  procedure DRAW_SCALE;
    var
      I,
      Y,
      HEIGHT : integer;
    begin
      paint_color( 1 );
      paint_rect( SCALEX-2, SCALEY-2, SCALEW+4, SCALEH+8 );
      Y := SCALEY;
      for I := NUMLEVELS downto 1 do
        begin
          HEIGHT := trunc( LEVELS[ I ] * 1.0 * SCALEH / MAXALTITUDE );
          paint_color( LIGHT[ I ] );
          paint_rect( SCALEX, Y, (SCALEW div 2), HEIGHT );
          paint_color( SHADOW[ I ] );
          paint_rect( SCALEX+(SCALEW div 2), Y, (SCALEW div 2), HEIGHT );
          Y := Y + HEIGHT + 1;
        end;
    end;


  procedure SPECIAL_COLORS;
    begin
      SET_GEM_COLOR(  0, 7, 7, 7 );
      SET_GEM_COLOR(  1, 0, 0, 0 );
      SET_GEM_COLOR(  2, 5, 0, 0 );
      SET_GEM_COLOR(  3, 0, 2, 0 );

      SET_GEM_COLOR(  5, 4, 7, 7 );   { COLOR OF SIDES IN PERSPEC }

      SET_GEM_COLOR(  8, 0, 0, 5 );   SHADOW[ 1 ] :=  8;
                                      SHADOW[ 2 ] := 11;
                                      SHADOW[ 3 ] := 12;
      SET_GEM_COLOR(  7, 1, 2, 0 );   SHADOW[ 4 ] :=  7;
      SET_GEM_COLOR(  6, 3, 2, 0 );   SHADOW[ 5 ] :=  6; { INSIDE OF EARTH }
                                      SHADOW[ 6 ] := 13;
      SET_GEM_COLOR(  4, 5, 5, 5 );   SHADOW[ 7 ] :=  4;

      SET_GEM_COLOR(  9, 0, 0, 7 );   LIGHT[ 1 ]  :=  9;
      SET_GEM_COLOR( 10, 0, 6, 0 );   LIGHT[ 2 ]  := 10;
      SET_GEM_COLOR( 11, 0, 4, 0 );   LIGHT[ 3 ]  := 11;
      SET_GEM_COLOR( 12, 2, 3, 0 );   LIGHT[ 4 ]  := 12;
      SET_GEM_COLOR( 13, 5, 3, 1 );   LIGHT[ 5 ]  := 13;
      SET_GEM_COLOR( 14, 6, 4, 1 );   LIGHT[ 6 ]  := 14;
      SET_GEM_COLOR( 15, 6, 6, 6 );   LIGHT[ 7 ]  := 15;
    end;


  procedure SET_SPECIAL_COLORS;
    var
      I : integer;
    begin
      SPECIAL_COLORS;
      WATER_LEVEL := 1;
      QUANTUM := MAXALTITUDE div (NUMLEVELS + 2);
      for I := 2 to NUMLEVELS do LEVELS[ I ] := QUANTUM;
      LEVELS[ 1 ] := 3*QUANTUM;
      WATER_LINE := QUANTUM*3;
    end;

{*****************************************************************************}

  function min( INT1, INT2 : integer ) : integer;
    begin
      if INT1 > INT2
      then
        min := INT2
      else
        min := INT1;
    end;


  function max( INT1, INT2 : integer ) : integer;
    begin
      if INT1 >= INT2
      then
        max := INT1
      else
        max := INT2;
    end;


{*****************************************************************************}
{  The following routines are used to save the graphics window and then       }
{ restore portions of it during window redraw.                                }
{*****************************************************************************}

  function MEMPTR_TO_LINT( PNTR : MEMPTR ) : long_integer;
    var
      COERCE : record
                 case boolean of
                   false : ( PTR : MEMPTR );
                   true  : ( ADR : long_integer );
               end;
    begin
      COERCE.PTR := PNTR;
      MEMPTR_TO_LINT := COERCE.ADR;
    end;


  procedure READY_MFDB;
    begin
      S_MFDB^.MP  := MEMPTR_TO_LINT( MEMORY );
      S_MFDB^.FWP := WSCRN;
      S_MFDB^.FH  := HSCRN;
      S_MFDB^.FWW := (WSCRN div 16);
      S_MFDB^.FF  := 0;
      S_MFDB^.NP  := NUM_PLANES;
      S_MFDB^.R1  := 0;
      S_MFDB^.R2  := 0;
      S_MFDB^.R3  := 0;

      D_MFDB^.MP  := 0;
    end;


  procedure SAVE_AREA( X, Y, W, H : integer );
    begin
      begin_update; hide_mouse;

      PXY[ 0 ] := X;            PXY[ 1 ] := Y;
      PXY[ 2 ] := X+W-1;        PXY[ 3 ] := Y+H-1;
      PXY[ 4 ] := X;            PXY[ 5 ] := Y;
      PXY[ 6 ] := X+W-1;        PXY[ 7 ] := Y+H-1;

      vro_cpyform( 3, PXY, D_MFDB, S_MFDB );

      show_mouse;   end_update;
    end;


  procedure RESTORE_AREA( X, Y, W, H : integer );
    begin
      begin_update; hide_mouse;

      PXY[ 0 ] := X;            PXY[ 1 ] := Y;
      PXY[ 2 ] := X+W-1;        PXY[ 3 ] := Y+H-1;
      PXY[ 4 ] := X;            PXY[ 5 ] := Y;
      PXY[ 6 ] := X+W-1;        PXY[ 7 ] := Y+H-1;

      vro_cpyform( 3, PXY, S_MFDB, D_MFDB );

      show_mouse;   end_update;
    end;


  procedure COPY_AREA( XF, YF, WF, HF, XT, YT, WT, HT : integer );
    begin
      PXY[ 0 ] := XF;           PXY[ 1 ] := YF;
      PXY[ 2 ] := WF;           PXY[ 3 ] := HF;
      PXY[ 4 ] := XT;           PXY[ 5 ] := YT;
      PXY[ 6 ] := WT;           PXY[ 7 ] := HT;
      D_MFDB^.MP := 0;
      vro_cpyform( 3, PXY, D_MFDB, D_MFDB );
    end;

{*****************************************************************************}

  function RANDOM24 : long_integer;
    XBIOS( 17 );


  function RANDOM( MINR, MAXR : integer ) : integer;
    begin
      RANDOM := trunc( RANDOM24 * (MAXR - MINR + 1.0) / $00FFFFFF ) + MINR;
    end;

{*****************************************************************************}

  procedure CLEAR_MAP_AREA;
    begin
      set_window( GRAPHICS_WINDOW );
      paint_color( 1 );
      paint_rect( WSX-2, WSY-2,
                  (NUMXTILES*PMAP_SIZE)+4-(NUMXTILES-1),
                  (NUMYTILES*PMAP_SIZE)+4-(NUMYTILES-1)
                );
      paint_color( 0 );
      paint_rect( WSX, WSY,
                  (NUMXTILES*PMAP_SIZE)-(NUMXTILES-1),
                  (NUMYTILES*PMAP_SIZE)-(NUMYTILES-1)
                );

    end;


  procedure FLATTEN_MAP( var MAP : MAPTYPE );
  {                                                                           }
  { Fill the map with an illegal value (-1) so that you can later distinguish }
  { between a used and unused location.                                       }
  {                                                                           }
    var
      TILEX, TILEY,
      X, Y : integer;
    begin
      for TILEX := 1 to NUMXTILES do
        for TILEY := 1 to NUMYTILES do
          for X := 1 to MAP_SIZE do
            for Y := 1 to MAP_SIZE do
              MAP[ TILEX, TILEY ]^[ X, Y ] := -1;
    end;


  function ALT_TO_COL( ALT : integer ): integer;
  {                                                                           }
  { this function maps an altitude to a color                                 }
  {                                                                           }
    var
      I,
      COL : integer;
    begin
      I := 1;
      loop
        ALT := ALT - LEVELS[ I ]
      exit if (ALT <= 0) or (I >= NUMLEVELS);
        I := I + 1
      end;
      COL := (I-1) + FIRSTLEVEL;

      if WATER_ON
      then
        ALT_TO_COL := max( WATER_LEVEL, COL )
      else
        ALT_TO_COL := COL;
    end;


  procedure PLOT_LOCATION( var MAP : TILETYPE;
                           LOCATION : POINT
                         );
  {                                                                    }
  { Plots a pixel during the creation of the map if WATCH is turned on }
  {                                                                    }
    begin
      if WATCH_ON
      then
        with LOCATION do
          begin
            paint_color( LIGHT[ALT_TO_COL( MAP^[ X, Y ] )] );
            paint_rect( WX+PIXEL_SIZE*(X-1), WY+PIXEL_SIZE*(Y-1),
                        PIXEL_SIZE, PIXEL_SIZE
                      );
          end;
    end;


  function USED_LOCATION( var MAP : TILETYPE;
                          LOCATION : POINT
                        ) : boolean;
  {                                                                           }
  { returns true if the location has been assigned an altitude                }
  { returns false otherwise                                                   }
  {                                                                           }
    begin
      USED_LOCATION := MAP^[ LOCATION.X, LOCATION.Y ] >= 0;
    end;


  procedure RANDOM_POINT( var MAP : TILETYPE;   { one tile of the map         }
                              LOCATION : POINT; { location to assign altitude }
                              LOWER,            { lower bound of region       }
                              UPPER : integer   { upper bound of region       }
                        );
  { assign a random altitude within the specified range to the location on }
  { the map specified if the location has not yet been used                }
    begin
      if not USED_LOCATION( MAP, LOCATION )
      then
        with LOCATION do
          MAP^[ X, Y ] := RANDOM( LOWER, UPPER );
    end;


  procedure DEFINE_START( var MAP : MAPTYPE;
                              TILEX, TILEY : integer;
                          var TL, TR, BR, BL : POINT
                        );
  {                                                                           }
  { assigns values to the seed points of a tile (the corners)                 }
  {                                                                           }
    var
      I,
      LOW_BOUND, HI_BOUND : integer;
    begin
      if (TILEY-1) >= 1
      then
        for I := 1 to MAP_SIZE do
          MAP[ TILEX, TILEY ]^[ I, 1 ]
               := MAP[ TILEX, TILEY-1 ]^[ I, MAP_SIZE ];

      if (TILEX-1) >= 1
      then
        for I := 1 to MAP_SIZE do
          MAP[ TILEX, TILEY ]^[ 1, I ]
               := MAP[ TILEX-1, TILEY ]^[ MAP_SIZE, I ];


      TL.X := 1;        TL.Y := 1;
      TR.X := MAP_SIZE; TR.Y := 1;
      BR.X := MAP_SIZE; BR.Y := MAP_SIZE;
      BL.X := 1;        BL.Y := MAP_SIZE;
      LOW_BOUND := trunc( QUANTUM * 2.00 );
      HI_BOUND  := MAXALTITUDE - LOW_BOUND;
      RANDOM_POINT( MAP[ TILEX, TILEY ], TL, LOW_BOUND, HI_BOUND );
      RANDOM_POINT( MAP[ TILEX, TILEY ], TR, LOW_BOUND, HI_BOUND );
      RANDOM_POINT( MAP[ TILEX, TILEY ], BR, LOW_BOUND, HI_BOUND );
      RANDOM_POINT( MAP[ TILEX, TILEY ], BL, LOW_BOUND, HI_BOUND );
    end;


  procedure NEW_HORIZONTAL( var MAP : TILETYPE; { one tile of the map }
                                LEFT,           { Left point of top or bottom }
                                RIGHT : POINT;  { Right point of top or bottom}
                            var MID : POINT     { Middle point of line }
                          );
    var
      DIFF,
      LEFT_ALT, RIGHT_ALT, MID_ALT
       : integer;
    begin
      MID.Y := LEFT.Y;
      MID.X := LEFT.X + ((RIGHT.X - LEFT.X) div 2);

      if not USED_LOCATION( MAP, MID )
      then
        begin
          LEFT_ALT  := MAP^[ LEFT.X, LEFT.Y ];
          RIGHT_ALT := MAP^[ RIGHT.X, RIGHT.Y ];
          DIFF := abs( LEFT_ALT - RIGHT_ALT );
          MID_ALT := min( LEFT_ALT, RIGHT_ALT ) + (DIFF div 2);
          DIFF := trunc( (RIGHT.X - LEFT.X) * RMAXALTITUDE / MAP_SIZE);
          DIFF := (DIFF div 2) - RANDOM( 0, DIFF );
          if (DIFF > 0) and
             ((MAXALTITUDE-MID_ALT) < DIFF)
          then
            DIFF := MAXALTITUDE - MID_ALT;

          MAP^[ MID.X, MID.Y ] := max( 0, (MID_ALT + DIFF) );
        end;
    end;


  procedure NEW_VERTICAL( var MAP : TILETYPE;  { one tile of the map      }
                              TOP,             { Top point of a side      }
                              BOT : POINT;     { Bottom point of a side   }
                          var MID : POINT      { Middle point of the side }
                        );
    var
      DIFF,
      TOP_ALT, BOT_ALT, MID_ALT : integer;
    begin
      MID.X := TOP.X;
      MID.Y := TOP.Y + ((BOT.Y - TOP.Y) div 2);

      if not USED_LOCATION( MAP, MID )
      then
        begin
          TOP_ALT := MAP^[ TOP.X, TOP.Y ];
          BOT_ALT := MAP^[ BOT.X, BOT.Y ];
          DIFF := abs( TOP_ALT - BOT_ALT );
          MID_ALT := min( TOP_ALT, BOT_ALT ) + (DIFF div 2);
          DIFF := trunc( (BOT.Y - TOP.Y) * RMAXALTITUDE / MAP_SIZE );
          DIFF := (DIFF div 2) - RANDOM( 0, DIFF );
          if (DIFF > 0) and
             ((MAXALTITUDE-MID_ALT) < DIFF)
          then
            DIFF := MAXALTITUDE - MID_ALT;

          MAP^[ MID.X, MID.Y ] := max( 0, (MID_ALT + DIFF) );
        end;
    end;


  procedure NEW_CENTER( var MAP : TILETYPE;  { one tile of the map      }
                            TM,              { Top Middle point         }
                            RM,              { Right Middle point       }
                            BM,              { Bottom Middle point      }
                            LM : POINT;      { Left Middle point        }
                        var CENTER : POINT   { Center point             }
                      );
    var
      DIFF,
      TOP_ALT, BOT_ALT, RIGHT_ALT, LEFT_ALT, MAX_ALT, MIN_ALT,
      AVERAGE1, AVERAGE2, AVERAGE : integer;
    begin
      CENTER.X := TM.X;
      CENTER.Y := LM.Y;

      if not USED_LOCATION( MAP, CENTER )
      then
        begin
          TOP_ALT := MAP^[ TM.X, TM.Y ];
          BOT_ALT := MAP^[ BM.X, BM.Y ];
          RIGHT_ALT := MAP^[ RM.X, RM.Y ];
          LEFT_ALT := MAP^[ LM.X, LM.Y ];
          AVERAGE1 := trunc( (TOP_ALT*1.0 + BOT_ALT) / 2 );
          AVERAGE2 := trunc( (RIGHT_ALT*1.0 + LEFT_ALT) / 2 );
          AVERAGE := trunc( (AVERAGE1*1.0 + AVERAGE2) / 2 );
          DIFF := trunc( (BM.Y - TM.Y) * RMAXALTITUDE / MAP_SIZE );
          DIFF := (DIFF div 2) - RANDOM( 0, DIFF );
          if (DIFF > 0) and
             ((MAXALTITUDE-AVERAGE) < DIFF)
          then
            DIFF := MAXALTITUDE - (AVERAGE+1);

          MAP^[ CENTER.X, CENTER.Y ] := max( 0, (AVERAGE + DIFF) );
        end;
    end;


  procedure EVOLVE_LANDSCAPE( var MAP : TILETYPE; { one tile of the map }
                                  TL,             { Top Left     corner }
                                  TR,             { Top Right    corner }
                                  BR,             { Bottom Right corner }
                                  BL : POINT      { Bottom Left  corner }
                            );
    var
      TM, RM, BM, LM, CENTER : POINT;
      I, TMP, TWIDDLE : integer;
      SPLAY : array[ 1..4 ] of 1..4;
    begin
      if ((TR.X - TL.X) > 1) or
         ((BR.Y - TR.Y) > 1)
      then
        begin
          NEW_HORIZONTAL( MAP, TL, TR, TM );
          NEW_HORIZONTAL( MAP, BL, BR, BM );
          NEW_VERTICAL( MAP, TL, BL, LM );
          NEW_VERTICAL( MAP, TR, BR, RM );
          NEW_CENTER( MAP, TM, RM, BM, LM, CENTER );

{ randomize the splay array }
          for I := 1 to 4 do SPLAY[ I ] := I;
          for I := 1 to 10 do
            begin
              TMP := SPLAY[ 1 ];
              TWIDDLE := RANDOM( 1, 4 );
              SPLAY[ 1 ] := SPLAY[ TWIDDLE ];
              SPLAY[ TWIDDLE ] := TMP;
            end;

{ evolve the four subrectangles }
          for I := 1 to 4 do
            case SPLAY[ I ] of
              1 : EVOLVE_LANDSCAPE( MAP, TL, TM, CENTER, LM );
              2 : EVOLVE_LANDSCAPE( MAP, TM, TR, RM, CENTER );
              3 : EVOLVE_LANDSCAPE( MAP, LM, CENTER, BM, BL );
              4 : EVOLVE_LANDSCAPE( MAP, CENTER, RM, BR, BM )
            end
        end;

{ show the points }
      PLOT_LOCATION( MAP, TL );
      PLOT_LOCATION( MAP, TR );
      PLOT_LOCATION( MAP, BR );
      PLOT_LOCATION( MAP, BL );

    end;


  procedure INIT_GWINDOW;
    var
      X, Y, H, W : integer;

    begin
      hide_mouse;
      bring_to_front( GRAPHICS_WINDOW );
      draw_mode( 1 );
      paint_color( 0 );
      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      set_clip( X, Y, W, H );
      set_window( GRAPHICS_WINDOW );
      paint_rect( 0, 0, W, H );
      FLATTEN_MAP( MAP );
      CLEAR_MAP_AREA;
      DRAW_SCALE;
      SAVE_AREA( X, Y, W, H );
      show_mouse;
    end;


  procedure REDRAW_MAP( var MAP : MAPTYPE );
  forward;


  procedure DRAW_MAP( var MAP : MAPTYPE );
    var
      TL, TR, BR, BL : POINT;
      TILEX, TILEY : integer;
    begin
      bring_to_front( GRAPHICS_WINDOW );
      INIT_GWINDOW;
      begin_update; hide_mouse;
      for TILEX := 1 to NUMXTILES do
        for TILEY := 1 to NUMYTILES do
          begin
            WX := WSX + ((TILEX-1) * (PMAP_SIZE-PIXEL_SIZE));
            WY := WSY + ((TILEY-1) * (PMAP_SIZE-PIXEL_SIZE));
            DEFINE_START( MAP, TILEX, TILEY, TL, TR, BR, BL );
            EVOLVE_LANDSCAPE( MAP[ TILEX, TILEY ], TL, TR, BR, BL );
          end;
      SAVE_AREA( XSCRN, YSCRN, WSCRN, HSCRN );
      show_mouse; end_update;
      BRAND_NEW := true;
      if SHADOW_ON
      then
        if do_alert('[2][| Add shadows?  |][Yes|No]',1) = 1
        then
          REDRAW_MAP( MAP );
      BRAND_NEW := false;
    end;

{*****************************************************************************}

  procedure ENLIGHTEN( var SHADOW_REGION : SHADOWREGION );
  { sets the shadow to the shadow of an object of zero height }
    begin
      with SHADOW_REGION do
        begin
           OHEIGHT := 0;
           OX := 1;  OY := 1;
           SLENGTH := 0;
        end;
    end;


  procedure PLOT_SRECT( var MAP : MAPTYPE;
                            IX, IY, TX, TY, XX, YY,
                            XPNT, YPNT, MAXX, MAXY : integer;
                        var SHADOW_REGION : SHADOWREGION
                      );
  { Plot a shadowed rectangle                                                 }
    var
      SHADOW_LENGTH,
      SHADOW_HEIGHT,
      OBJECT_HEIGHT,
      COLOR : integer;
      HEIGHT : real;
    begin
      with SHADOW_REGION do
        begin
          HEIGHT := MAP[TX,TY]^[XX,YY];
          if WATER_ON
          then
            if HEIGHT < WATER_LINE
            then
              HEIGHT := WATER_LINE;

          COLOR := ALT_TO_COL( round(HEIGHT) );
          SHADOW_LENGTH := round( (HEIGHT * PMAP_SIZE2)
                                  / (RMAXALTITUDE * TANGENT)
                                );
          OBJECT_HEIGHT := round( HEIGHT * PMAP_SIZE2 / RMAXALTITUDE );

          if (IX + SHADOW_LENGTH) <= (OX + SLENGTH)
          then
            begin
              if ( (IX = MAXX) or
                   (IY = MAXY)
                 )
              then
                paint_color( 6 )
              else
                paint_color( SHADOW[ COLOR ] );

              paint_rect( XPNT+IX,       YPNT-OBJECT_HEIGHT,
                          PIXEL_SIZE,    OBJECT_HEIGHT
                        );
            end
          else
            begin
              if SLENGTH <= 0
              then
               SHADOW_HEIGHT := 0
              else
               SHADOW_HEIGHT := round( (0.0+SLENGTH-(IX-OX))*OHEIGHT/SLENGTH );
              if ( (IX = MAXX) or
                   (IY = MAXY)
                 )
              then
                paint_color( 6 )
              else
                paint_color( LIGHT[ COLOR ] );
              paint_rect( XPNT+IX,    YPNT-OBJECT_HEIGHT,
                          PIXEL_SIZE, OBJECT_HEIGHT
                        );
              if ( (IX = MAXX) or
                   (IY = MAXY)
                 )
              then
                paint_color( 6 )
              else
                paint_color( SHADOW[ COLOR ] );
              paint_rect( XPNT+IX,    YPNT-SHADOW_HEIGHT,
                          PIXEL_SIZE, SHADOW_HEIGHT
                        );

              SLENGTH := SHADOW_LENGTH;
              OHEIGHT := OBJECT_HEIGHT;
              OX := IX;  OY := IY;
            end;

        end;
    end;


  function DEG_TO_RAD( DEGREES : real ) : real;
    begin
      DEG_TO_RAD := DEGREES * PI / 180.0;
    end;


  function GET_TANGENT : real;
  {                                                                          }
  { this function gets the angle of the sun and returns the tangent          }
  {                                                                          }
    var
      ANSWER : integer;
    begin
      ANSWER := do_alert('[0][| Sun Angle?   |][L|M|H]',2);
      case ANSWER of
        1 : SUNANGLE := 15.0;
        2 : SUNANGLE := 45.0;
        3 : SUNANGLE := 75.0
      end;

      SUNANGLE := DEG_TO_RAD( SUNANGLE );
      GET_TANGENT := sin( SUNANGLE ) / cos( SUNANGLE );
    end;


  procedure SIDE_MAP( var MAP : MAPTYPE );
  {                                                                         }
  { this procedure draw an isometric view of the map                        }
  {                                                                         }
    var
      DONE : boolean;
      HEIGHT,
      COLOR,
      XPNT, YPNT,
      TX, TY, XX, YY,
      IX, IY,
      X, Y, W, H : integer;
      SHADOW_REGION : SHADOWREGION;
    begin
      bring_to_front( GRAPHICS_WINDOW );
      draw_mode( 1 );
      paint_style( 1 );
      paint_color( 1 );
      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      set_clip( X, Y, W, H );
      set_window( GRAPHICS_WINDOW );
      begin_update; hide_mouse;
      paint_rect( 0, 0, W, H );
      DRAW_SCALE;
      if SHADOW_ON
      then
        TANGENT := GET_TANGENT;

      line_style( 1 );
      XPNT := WSX + PMAP_SIZE - 1;
      YPNT := WSY + PMAP_SIZE2 + 2;
      IY := 0;
      loop
        IX := 0;
        ENLIGHTEN( SHADOW_REGION );
        TY := (IY div SIDE) + 1;
        YY := (IY mod SIDE) + 1;
        if IY = MAXY
        then
          begin
            TY := TY - 1;
            YY := MAP_SIZE;
          end;

        loop
          TX := (IX div SIDE) + 1;
          XX := (IX mod SIDE) + 1;

          if IX = MAXX
          then
            begin
              TX := TX - 1;
              XX := MAP_SIZE;
            end;

          if SHADOW_ON
          then
            PLOT_SRECT( MAP, IX, IY, TX, TY, XX, YY,
                        XPNT, YPNT, MAXX, MAXY,
                        SHADOW_REGION
                      )
          else
            begin
              HEIGHT := MAP[TX,TY]^[XX,YY];

              if WATER_ON
              then
                if (HEIGHT <= WATER_LINE)
                then
                  HEIGHT := WATER_LINE;

              if ( (IX = MAXX) or
                   (IY = MAXY)
                 )
              then
                begin
                  COLOR := 0;
                  paint_color( 6 );
                end
              else
                begin
                  COLOR := ALT_TO_COL( HEIGHT );
                  paint_color( LIGHT[ COLOR ] );
                end;

              HEIGHT := trunc((1.0*HEIGHT*PMAP_SIZE2)/RMAXALTITUDE);

              paint_rect( XPNT+IX,
                          YPNT-HEIGHT,
                          PIXEL_SIZE,
                          HEIGHT
                        );
            end;

          DONE := QUICK_EXIT;   { check for the mouse button }

        exit if (IX >= MAXX) or DONE;
          IX := IX + 1;
        end;

        YPNT := YPNT + 1;
        if (YPNT mod 2) = 0
        then
          XPNT := XPNT - PIXEL_SIZE;

      exit if (IY >= MAXY) or DONE;
        IY := IY + 1;
      end;


      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      SAVE_AREA( X, Y, W, H );
      show_mouse; end_update;
    end;

{*****************************************************************************}

  procedure PLOT_SHADOWED( var MAP : MAPTYPE;
                               IX, IY, TX, TY, XX, YY : integer;
                           var SHADOW_REGION : SHADOWREGION
                         );
    var
      COLOR,
      SHADOW_HEIGHT,
      SHADOW_LENGTH : integer;
      HEIGHT : real;
    begin
      with SHADOW_REGION do
        begin
          if SHADOW_ON
          then
            begin
              HEIGHT := MAP[TX,TY]^[XX,YY];
              if WATER_ON
              then
                if HEIGHT < WATER_LINE
                then
                  HEIGHT := WATER_LINE;

              COLOR := ALT_TO_COL( round(HEIGHT) );
              SHADOW_LENGTH := round( (HEIGHT * MAP_SIZE)
                                      / (RMAXALTITUDE * TANGENT)
                                    );
              if (IX + SHADOW_LENGTH) <= (OX + SLENGTH)
              then
                paint_color( SHADOW[ COLOR ] )
              else
                begin
                  paint_color( LIGHT[ COLOR ] );
                  SLENGTH := SHADOW_LENGTH;
                  OHEIGHT := round(HEIGHT);
                  OX := IX;  OY := IY;
                end;
            end
          else
            paint_color( LIGHT[ALT_TO_COL( round(HEIGHT) )] );

          paint_rect( WSX+PIXEL_SIZE*IX,
                      WSY+PIXEL_SIZE*IY,
                      PIXEL_SIZE, PIXEL_SIZE
                    );
        end;
    end;


  procedure REDRAW_MAP;
    var
      DONE,
      SAVE_WATCH : boolean;
      X, Y, W, H,
      IX, IY, TX, TY, XX, YY : integer;
      LOCATION : POINT;
      SHADOW_REGION : SHADOWREGION;
    begin
      SAVE_WATCH := WATCH_ON; WATCH_ON := true;
      bring_to_front( GRAPHICS_WINDOW );
      line_style( 1 );
      draw_mode( 1 );
      paint_style( 1 );
      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      set_clip( X, Y, W, H );
      set_window( GRAPHICS_WINDOW );
      begin_update; hide_mouse;
      if not BRAND_NEW
      then
        begin
          paint_color( 0 );
          paint_rect( 0, 0, W, H );
          DRAW_SCALE;
          paint_color( 1 );
          paint_rect( WSX-2, WSY-2,
                      (NUMXTILES*PMAP_SIZE)+4-(NUMXTILES-1),
                      (NUMYTILES*PMAP_SIZE)+4-(NUMYTILES-1)
                    );
          paint_color( 0 );
          paint_rect( WSX, WSY,
                      (NUMXTILES*PMAP_SIZE)-(NUMXTILES-1),
                      (NUMYTILES*PMAP_SIZE)-(NUMYTILES-1)
                    );
          paint_color( 0 );
        end;

      if SHADOW_ON
      then
        TANGENT := GET_TANGENT;

      IY := 0;
      loop
        TY := (IY div SIDE) + 1;
        YY := (IY mod SIDE) + 1;
        if IY = MAXY
        then
          begin
            TY := TY - 1;
            YY := MAP_SIZE;
          end;

        IX := 0;
        ENLIGHTEN( SHADOW_REGION );
        loop
          TX := (IX div SIDE) + 1;
          XX := (IX mod SIDE) + 1;

          if IX = MAXX
          then
            begin
              TX := TX - 1;
              XX := MAP_SIZE;
            end;

          if SHADOW_ON
          then
            PLOT_SHADOWED( MAP, IX, IY, TX, TY, XX, YY, SHADOW_REGION )
          else
            begin
              WX := WSX + ((TX-1) * SIDE);
              WY := WSY + ((TY-1) * SIDE);
              LOCATION.X := XX;       LOCATION.Y := YY;
              PLOT_LOCATION( MAP[TX,TY], LOCATION );
            end;

          DONE := QUICK_EXIT;      { check for the mouse button }

        exit if (IX >= MAXX) or DONE;
          IX := IX + 1;
        end;

      exit if (IY >= MAXY) or DONE;
        IY := IY + 1
      end;

      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      SAVE_AREA( X, Y, W, H );
      WATCH_ON := SAVE_WATCH;
      show_mouse; end_update;
    end;

{*****************************************************************************}

  procedure GET_SCALE_HEIGHT( var SCALE_HEIGHT : integer );
    begin
      SCALE_HEIGHT := do_alert('[0][| Height?    |][L|M|H]',3);
      case SCALE_HEIGHT of
        1 : SCALE_HEIGHT := PMAP_SIZE2;
        2 : SCALE_HEIGHT := MAP_SIZE div 2;
        3 : SCALE_HEIGHT := MAP_SIZE;
      end;
    end;


  procedure PERSPECTIVE( var MAP : MAPTYPE );
    var
      IX, IY,
      VHEIGHT, VPERCENT,
      LASTX,
      THISX,
      ALTITUDE,
      SCALE_HEIGHT,
      COLOR,
      OBJECT_HEIGHT,
      SHADOW_LENGTH,
      SHADOW_HEIGHT,
      TX, TY, XX, YY,
      X, Y, W, H : integer;
      XORIGIN, YORIGIN, WORIGIN,
      TPERCENT,
      HEIGHT : real;
      DONE,
      FIRST : boolean;
      SHADOW_REGION : SHADOWREGION;
    begin
      bring_to_front( GRAPHICS_WINDOW );
      GET_SCALE_HEIGHT( SCALE_HEIGHT );
      TANGENT := GET_TANGENT;
      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      set_clip( X, Y, W, H );
      set_window( GRAPHICS_WINDOW );
      begin_update; hide_mouse;
      paint_color( 1 );
      paint_rect( 0, 0, W, H );
      line_style( 1 );
      draw_mode( 1 );
      VHEIGHT := H;
      VPERCENT := 50;
      IY := 0;
      loop
        TPERCENT := (100.0 - VPERCENT) * (MAXY - IY) / MAXY;
        XORIGIN  := ((W/2.0) * TPERCENT / 100.0 ) + 1;
        YORIGIN  := (H+1.0) - (TPERCENT * VHEIGHT / 100.0);
        WORIGIN  := (100.0 - TPERCENT) * W / 100.0;

        TY := (IY div SIDE) + 1;
        YY := (IY mod SIDE) + 1;
        if IY = MAXY
        then
          begin
            TY := TY - 1;
            YY := MAP_SIZE;
          end;

        ENLIGHTEN( SHADOW_REGION );
        FIRST := true;
        IX := 0;
        loop
          TX := (IX div SIDE) + 1;
          XX := (IX mod SIDE) + 1;

          if IX = MAXX
          then
            begin
              TX := TX - 1;
              XX := MAP_SIZE;
            end;

          ALTITUDE := MAP[TX,TY]^[XX,YY];
          if WATER_ON and (ALTITUDE < WATER_LINE)
          then
            HEIGHT := WATER_LINE
          else
            HEIGHT := ALTITUDE;

          THISX := round( XORIGIN + (WORIGIN * IX / MAXX) );
          if FIRST
          then
            begin
              FIRST := not FIRST;
              LASTX := round(XORIGIN);
            end;

          if SHADOW_ON
          then
            with SHADOW_REGION do
              begin
                COLOR := ALT_TO_COL( ALTITUDE );

                { scale altitude to some convenient value, say, SCALE_HEIGHT }
                SHADOW_LENGTH := round( HEIGHT * SCALE_HEIGHT
                                        / (RMAXALTITUDE * TANGENT)
                                      );

                OBJECT_HEIGHT := round( HEIGHT * SCALE_HEIGHT / RMAXALTITUDE );

                if (IX + SHADOW_LENGTH) <= (OX + SLENGTH)
                then
                  begin
                    if ( (IX = MAXX) or
                         (IY = MAXY)
                       )
                    then
                      paint_color( 6 )
                    else
                      paint_color( SHADOW[ COLOR ] );

                    { scale for distance if enabled }
                    if SCALE_ON
                    then
                      OBJECT_HEIGHT := round(OBJECT_HEIGHT * (100.0 - TPERCENT)
                                             / 100.0
                                            );

                    paint_rect( LASTX,            round(YORIGIN-OBJECT_HEIGHT),
                                (THISX-LASTX),    OBJECT_HEIGHT
                              );
                  end
                else
                  begin
                    if SLENGTH <= 0
                    then
                      SHADOW_HEIGHT := 0
                    else
                      SHADOW_HEIGHT :=
                                round( (0.0+SLENGTH-(IX-OX))*OHEIGHT/SLENGTH );

                    if ( (IX = MAXX) or
                         (IY = MAXY)
                       )
                    then
                      paint_color( 6 )
                    else
                      paint_color( LIGHT[ COLOR ] );

                    SLENGTH := SHADOW_LENGTH;
                    OHEIGHT := OBJECT_HEIGHT;
                    if SCALE_ON
                    then
                      begin
                      OBJECT_HEIGHT := round(OBJECT_HEIGHT * (100.0 - TPERCENT)
                                             / 100.0
                                            );
                      SHADOW_HEIGHT := round(SHADOW_HEIGHT * (100.0 - TPERCENT)
                                             / 100.0
                                            );
                      end;

                    paint_rect( LASTX,         round(YORIGIN-OBJECT_HEIGHT),
                                (THISX-LASTX), OBJECT_HEIGHT
                              );

                    if ( (IX = MAXX) or
                         (IY = MAXY)
                       )
                    then
                      paint_color( 6 )
                    else
                      paint_color( SHADOW[ COLOR ] );
                    paint_rect( LASTX,         round(YORIGIN-SHADOW_HEIGHT),
                                (THISX-LASTX), SHADOW_HEIGHT
                              );

                    OX := IX;  OY := IY;
                  end;
              end
          else
            begin
              { scale altitude to some convenient value, say, SCALE_HEIGHT }
              HEIGHT := HEIGHT * SCALE_HEIGHT / RMAXALTITUDE ;

              { scale for distance if enabled }
              if SCALE_ON
              then
                HEIGHT := HEIGHT * (100.0 - TPERCENT) / 100.0;

              if (IY = MAXY)
              then
                begin
                  paint_color( 6 );
                end
              else
                begin
                  COLOR := ALT_TO_COL( ALTITUDE );
                  paint_color( LIGHT[ COLOR ] );
                end;

              paint_rect( LASTX,         round(YORIGIN-HEIGHT),
                          (THISX-LASTX), round(HEIGHT)
                        );
            end;

          LASTX := THISX;
          DONE := QUICK_EXIT;  { check for mouse button pressed }

        exit if (IX >= MAXX) or DONE;
          IX := IX + 1;
        end;

      exit if (IY >= MAXY) or DONE;
        IY := IY + 1
      end;

      work_rect( GRAPHICS_WINDOW, X, Y, W, H );
      SAVE_AREA( X, Y, W, H );
      show_mouse; end_update;
    end;

{*****************************************************************************}

  procedure SAVE_MAP( var MAP : MAPTYPE );
    var
      I,
      XX, YY, TX, TY, IX, IY : integer;
      PATHNAME  : path_name;
      FPTR      : file of integer; { LONGITUDE; }
    begin
      if get_out_file( 'Write to ...', PATHNAME )
      then
        begin
          rewrite( FPTR, PATHNAME );
          set_mouse( m_bee );
          if true
          then
            begin
              FPTR^ := NUMXTILES; put( FPTR );
              FPTR^ := NUMYTILES; put( FPTR );

              for I := 0 to 15 do
                begin
                  FPTR^ := GET_XCOLOR( I );
                  put( FPTR );
                end;

              for IY := 0 to MAXY do
                begin
                  TY := (IY div SIDE) + 1;
                  YY := (IY mod SIDE) + 1;
                  if IY = MAXY
                  then
                    begin
                      TY := TY - 1;
                      YY := MAP_SIZE;
                    end;

                  for IX := 0 to MAXX do
                    begin
                      TX := (IX div SIDE) + 1;
                      XX := (IX mod SIDE) + 1;

                      if IX = MAXX
                      then
                        begin
                          TX := TX - 1;
                          XX := MAP_SIZE;
                        end;

                      FPTR^ := MAP[TX,TY]^[XX,YY];
                      put( FPTR );
                    end;
                end;

              close( FPTR );
              INFO_LINE := concat( PATHNAME, '         ' );
              set_winfo( GRAPHICS_WINDOW,
                         INFO_LINE
                       );
            end
          else
            I := do_alert('[2][  I can''t write  |  to that file.  ][oh]',1);

          set_mouse( m_arrow );
        end;
    end;


  procedure LOAD_MAP( var MAP : MAPTYPE );
    var
      I,
      IX, IY, TX, TY, XX, YY : integer;
      FPTR : file of integer;
    begin
      if get_in_file( DEF_PATH, FILENAME )
      then
        begin
          reset( FPTR, FILENAME );
          set_mouse( m_bee );
          NUMXTILES := FPTR^;
          MAXX := NUMXTILES * SIDE;
          get( FPTR );
          NUMYTILES := FPTR^;
          MAXY := NUMYTILES * SIDE;
          for I := 0 to 15 do
            begin
              get( FPTR );
              SET_XCOLOR( I, FPTR^ );
            end;

          for IY := 0 to MAXY do
            begin
              TY := (IY div SIDE) + 1;
              YY := (IY mod SIDE) + 1;
              if IY = MAXY
              then
                begin
                  TY := TY - 1;
                  YY := MAP_SIZE;
                end;

              for IX := 0 to MAXX do
                begin
                  TX := (IX div SIDE) + 1;
                  XX := (IX mod SIDE) + 1;
                  if IX = MAXX
                  then
                    begin
                      TX := TX - 1;
                      XX := MAP_SIZE;
                    end;

                  get( FPTR );
                  MAP[TX,TY]^[XX,YY] := FPTR^;

                  if XX = 1
                  then
                    if TX <> 1
                    then
                      MAP[TX-1,TY]^[MAP_SIZE,YY] := FPTR^;

                  if YY = 1
                  then
                    if TY <> 1
                    then
                      MAP[TX,TY-1]^[XX,MAP_SIZE] := FPTR^;

                end;
            end;

          close( FPTR );

          INFO_LINE := concat( FILENAME, '         ' );
          set_winfo( GRAPHICS_WINDOW,
                     INFO_LINE
                   );
          set_mouse( m_arrow );
        end;
    end;


  procedure OLD_LOAD_MAP( var MAP : MAPTYPE );
    var
      I,
      TILEX, TILEY,
      X, Y : integer;
      FPTR : file of LONGITUDE;
    begin
      if get_in_file( DEF_PATH, FILENAME )
      then
        begin
          reset( FPTR, FILENAME );
          set_mouse( m_bee );
          NUMXTILES := FPTR^[ 1 ];
          MAXX := NUMXTILES * SIDE;
          NUMYTILES := FPTR^[ 2 ];
          MAXY := NUMYTILES * SIDE;
          for I := 0 to 15 do SET_XCOLOR( I, FPTR^[ I + 3 ] );
          for TILEX := 1 to NUMXTILES do
            for TILEY := 1 to NUMYTILES do
              for X := 1 to MAP_SIZE do
                begin
                  get( FPTR );
                  MAP[TILEX,TILEY]^[X] := FPTR^;
                end;
          close( FPTR );
          INFO_LINE := concat( FILENAME, '  (old format)' );
          set_winfo( GRAPHICS_WINDOW,
                     INFO_LINE
                   );
          set_mouse( m_arrow );
        end;
    end;

{*****************************************************************************}

  procedure DO_VIEW_MENU( ITEM : integer );
    var
      CHOICE : integer;
    begin
      if ITEM = TOP_ITEM
      then
        begin
          REDRAW_MAP( MAP );
        end
      else
        if ITEM = SIDE_ITEM
        then
          SIDE_MAP( MAP )
        else
          if ITEM = PERSPEC_ITEM
          then
            begin
              CHOICE := do_alert('[0][|  Scale?    |][Yes|No]',1);
              SCALE_ON := CHOICE = 1;
              PERSPECTIVE( MAP );
            end;
    end;


  procedure DO_FILE_MENU( ITEM : integer );
    begin
      if ITEM = QUIT_ITEM
      then
        begin
          close_window( GRAPHICS_WINDOW );
          delete_window( GRAPHICS_WINDOW );
        end
      else
        if ITEM = NEW_ITEM
        then
          begin
            if do_alert('[2][| Are you sure?  |][YES|NO]',2) = 1
            then
              begin
                INFO_LINE := ' Unnamed map. ';
                set_winfo( GRAPHICS_WINDOW,
                           INFO_LINE
                         );
                DRAW_MAP( MAP );
                menu_enable( MENU, SIDE_ITEM );
                menu_enable( MENU, TOP_ITEM  );
                menu_enable( MENU, PERSPEC_ITEM );
              end
          end
        else
          if ITEM = OLD_ITEM
          then
            begin
              OLD_LOAD_MAP( MAP );
              menu_enable( MENU, SIDE_ITEM );
              menu_enable( MENU, TOP_ITEM  );
              menu_enable( MENU, PERSPEC_ITEM );
            end
          else
            if ITEM = SAVE_ITEM
            then
              SAVE_MAP( MAP )
            else
              if ITEM = LOAD_ITEM
              then
                begin
                  LOAD_MAP( MAP );
                  menu_enable( MENU, SIDE_ITEM );
                  menu_enable( MENU, TOP_ITEM  );
                  menu_enable( MENU, PERSPEC_ITEM );
                end;
    end;


  procedure DO_OPTIONS_MENU( ITEM : integer );
    begin
      if ITEM = WATER_ITEM
      then
        begin
          WATER_ON := not WATER_ON;
          menu_check( MENU, WATER_ITEM, WATER_ON );
        end
      else
        if ITEM = WATCH_ITEM
        then
          begin
            WATCH_ON := not WATCH_ON;
            menu_check( MENU, WATCH_ITEM, WATCH_ON );
          end
        else
          if ITEM = SHADOW_ITEM
          then
            begin
              SHADOW_ON := not SHADOW_ON;
              menu_check( MENU, SHADOW_ITEM, SHADOW_ON );
            end
          else
            if ITEM = WIDTH_ITEM
            then
              begin
                NUMXTILES := do_alert('[0][| Width?    |][1|2|3]',NUMXTILES);
                MAXX := NUMXTILES * SIDE;
              end
            else
              if ITEM = HEIGHT_ITEM
              then
                begin
                  NUMYTILES := do_alert('[0][| Height?   |][1|2]',NUMYTILES);
                  MAXY := NUMYTILES * SIDE;
                end
              else
                if ITEM = RESET_ITEM
                then
                  SPECIAL_COLORS;
    end;


  procedure do_redraw( WINDOW, X0, Y0, W0, H0 : integer );
    var
      X, Y, W, H : integer;
    begin
      set_window(0);
      begin_update;
      hide_mouse;
      first_rect( WINDOW, X, Y, W, H );
      while (W <> 0) or (H <> 0) do
        begin
          if rect_intersect( X0, Y0, W0, H0, X, Y, W, H )
          then
            begin
              RESTORE_AREA( X, Y, W, H );
            end;
          next_rect( WINDOW, X, Y, W, H );
        end;
      show_mouse;
      end_update;
    end;


  procedure DO_ABOUT;
    var
      X, Y, H, W,
      BUTTON_PRESSED : integer;
    begin
      BUTTON_PRESSED := do_dialog( ABOUT_DIALOG, 0 );
      end_dialog( ABOUT_DIALOG );
      BUTTON_PRESSED := do_dialog( OSS_DIALOG, 0 );
      end_dialog( OSS_DIALOG );
    end;


  procedure do_menu( TITLE, ITEM : integer );
    begin
      if TITLE = VIEW_TITLE
      then
        DO_VIEW_MENU( ITEM )
      else
        if TITLE = FILE_TITLE
        then
          DO_FILE_MENU( ITEM )
        else
          if TITLE = OPTIONS_TITLE
          then
            DO_OPTIONS_MENU( ITEM )
          else
            if TITLE = DESK_TITLE
            then
              DO_ABOUT;

      menu_normal( MENU, TITLE );
    end;


 procedure CREATE_MENU;
    begin
      MENU := new_menu( 6, '  About TOPMAP  ' );
      FILE_TITLE    := add_mtitle( MENU, ' File ' );
      VIEW_TITLE    := add_mtitle( MENU, ' View ' );
      OPTIONS_TITLE := add_mtitle( MENU, ' Options ' );
      SHADOW_ITEM   := add_mitem( MENU, OPTIONS_TITLE, '  SHADOW ' );
      WATCH_ITEM    := add_mitem( MENU, OPTIONS_TITLE, '  WATCH  ' );
      WATER_ITEM    := add_mitem( MENU, OPTIONS_TITLE, '  WATER  ' );
      NULL2_ITEM    := add_mitem( MENU, OPTIONS_TITLE, '~~~~~~~~~' );
      HEIGHT_ITEM   := add_mitem( MENU, OPTIONS_TITLE, '  HEIGHT ' );
      WIDTH_ITEM    := add_mitem( MENU, OPTIONS_TITLE, '  WIDTH  ' );
      RESET_ITEM    := add_mitem( MENU, OPTIONS_TITLE, '  RESET  ' );
      SIDE_ITEM     := add_mitem( MENU, VIEW_TITLE, '  ISOMETETRIC   ' );
      TOP_ITEM      := add_mitem( MENU, VIEW_TITLE, '  OVERHEAD      ' );
      PERSPEC_ITEM  := add_mitem( MENU, VIEW_TITLE, '  PERSPECTIVE   ' );
      LOAD_ITEM     := add_mitem( MENU, FILE_TITLE, '  LOAD... ' );
      NEW_ITEM      := add_mitem( MENU, FILE_TITLE, '  NEW     ' );
      OLD_ITEM      := add_mitem( MENU, FILE_TITLE, '  OLD...  ' );
      SAVE_ITEM     := add_mitem( MENU, FILE_TITLE, '  SAVE... ' );
      NULL_ITEM     := add_mitem( MENU, FILE_TITLE, '==========' );
      QUIT_ITEM     := add_mitem( MENU, FILE_TITLE, '  QUIT    ' );
      menu_disable( MENU, NULL_ITEM    );
      menu_disable( MENU, NULL2_ITEM   );
      menu_disable( MENU, SIDE_ITEM    );
      menu_disable( MENU, TOP_ITEM     );
      menu_disable( MENU, PERSPEC_ITEM );
      WATER_ON  := true;  menu_check( MENU, WATER_ITEM,  WATER_ON  );
      WATCH_ON  := true;  menu_check( MENU, WATCH_ITEM,  WATCH_ON  );
      SHADOW_ON := true; menu_check( MENU, SHADOW_ITEM, SHADOW_ON );
    end;


  procedure CREATE_DIALOGS;
    var
      DUMMY : integer;
      BUFFER : STR255;
    begin
      ABOUT_DIALOG := new_dialog(10, 0,0,30,10 );
      DUMMY  := add_ditem( ABOUT_DIALOG,
                           g_text, none,
                           1,1,28,1,
                           0, $0180
                         );
      set_dtext( ABOUT_DIALOG, DUMMY,
                 'Fractal Topographical Maps', system_font, te_center
               );

      DUMMY := add_ditem( ABOUT_DIALOG,
                          g_text, none,
                          1,2,28,1,
                          0, $0180
                        );
      BUFFER := 'Copyright   1987';
      BUFFER[ 11 ] := chr(189);
      set_dtext( ABOUT_DIALOG, DUMMY,
                 BUFFER, system_font, te_center
               );

      DUMMY := add_ditem( ABOUT_DIALOG,
                          g_text, none,
                          1,3,28,1,
                          0, $0180
                        );
      set_dtext( ABOUT_DIALOG, DUMMY,
                 'by Robert Adam II.', system_font, te_center
               );

      DUMMY := add_ditem( ABOUT_DIALOG,
                          g_text, none,
                          1,4,28,1,
                          0, $0180
                        );
      set_dtext( ABOUT_DIALOG, DUMMY,
                 'All rights reserved.', system_font, te_center
               );

      DUMMY := add_ditem( ABOUT_DIALOG,
                          g_text, none,
                          1,5,28,1,
                          0, $0180
                        );
      set_dtext( ABOUT_DIALOG, DUMMY,
                 'You may give it away,', system_font, te_center
               );

      DUMMY := add_ditem( ABOUT_DIALOG,
                          g_text, none,
                          1,6,28,1,
                          0, $0180
                        );
      set_dtext( ABOUT_DIALOG, DUMMY,
                 'but not sell it.', system_font, te_center
               );

      DUMMY        := add_ditem( ABOUT_DIALOG,
                                 g_button, touch_exit | default,
                                 14,8,2,1,
                                 0, $0180
                               );
      set_dtext( ABOUT_DIALOG, DUMMY,
                 'ok', system_font, te_center
               );
      center_dialog( ABOUT_DIALOG );


      OSS_DIALOG := new_dialog(10, 0,0,30,10 );

      DUMMY := add_ditem( OSS_DIALOG,
                          g_text, none,
                          1,1,28,1,
                          0, $0180
                        );
      set_dtext( OSS_DIALOG, DUMMY,
                 'Portions of this product are',
                 system_font, te_center
               );
      DUMMY := add_ditem( OSS_DIALOG,
                          g_text, none,
                          1,2,28,1,
                          0, $0180
                        );
      BUFFER := 'Copyright   1986';
      BUFFER[ 11 ] := chr(189);
      set_dtext( OSS_DIALOG, DUMMY,
                 BUFFER,
                 system_font, te_center
               );
      DUMMY := add_ditem( OSS_DIALOG,
                          g_text, none,
                          1,3,28,1,
                          0, $0180
                        );
      set_dtext( OSS_DIALOG, DUMMY,
                 'OSS and CDD.',
                 system_font, te_center
               );
      DUMMY := add_ditem( OSS_DIALOG,
                          g_text, none,
                          1,4,28,1,
                          0, $0180
                        );
      set_dtext( OSS_DIALOG, DUMMY,
                 'Used by permission of OSS.',
                 system_font, te_center
               );
      DUMMY        := add_ditem( OSS_DIALOG,
                                 g_button, touch_exit | default,
                                 14,8,2,1,
                                 0, $0180
                               );
      set_dtext( OSS_DIALOG, DUMMY,
                 'ok', system_font, te_center
               );
      center_dialog( OSS_DIALOG );
    end;


  procedure CREATE_GWINDOW;
    begin
      MAIN_TITLE := COPYRIGHT1;
      GRAPHICS_WINDOW := new_window( g_name | g_info,
                                     MAIN_TITLE,
                                     0, 0, 0, 0
                                   );
      open_window( GRAPHICS_WINDOW,
                   0, 0, 0, 0
                 );
      INFO_LINE := ' No map.  ';
      set_winfo( GRAPHICS_WINDOW,
                 INFO_LINE
               );

      INIT_GWINDOW;

    end;


  procedure EVENT_LOOP;

    var
      WHICH : integer ;
      MSG   : message_buffer ;

    begin
      repeat
        WHICH := get_event( e_message, 0, 0, 0, 0,
                false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
                dummy, dummy, dummy, dummy, dummy, dummy ) ;
        case msg[0] of
          mn_selected: DO_MENU( msg[3], msg[4] );
          wm_topped:
            bring_to_front( msg[3] ) ;
          wm_redraw:
             do_redraw( msg[3], msg[4], msg[5], msg[6], msg[7] ) ;
          wm_sized, wm_moved:
            set_wsize( msg[3], msg[4], msg[5], msg[6], msg[7] ) ;
          wm_closed:
            begin
              close_window( msg[3] ) ;
              delete_window( msg[3] ) ;
            end;
        end;
      until (msg[3] = FILE_TITLE) and (msg[4] = QUIT_ITEM)
    end;


  procedure ALLOCATE;
  { Allocate the space for the saved screen, the MFDBs and the map        }
    var
      TILEX, TILEY : integer;
    begin
      new( MEMORY );
      new( S_MFDB );
      new( D_MFDB );
      for TILEX := 1 to MAXXTILES do
        for TILEY := 1 to MAXYTILES do
          new( MAP[ TILEX, TILEY ] );
      READY_MFDB;
    end;

{}
{ ... The main program ... }
{}

  begin
    if init_gem >= 0
    then
      begin
      { set up the global parameter variables }
        SAVE_COLORS;
        DEF_PATH := 'B:\*.MAP';
        WX := WSX;  WY := WSY;
        NUMXTILES := MAXXTILES;
        NUMYTILES := MAXYTILES;
        SIDE := MAP_SIZE - 1;
        MAXX := NUMXTILES * SIDE;
        MAXY := NUMYTILES * SIDE;
        BRAND_NEW := false;
        border_rect( 0, XSCRN, YSCRN, WSCRN, HSCRN );
        ALLOCATE;

      { create the dialogs and menu }
        set_mouse( m_bee );
        init_mouse;
        CREATE_MENU;
        CREATE_DIALOGS;
        hide_mouse;

      {   set the colors that are used to display the maps and initialize the }
      {  the global parameter variables that are associated with the colors   }
        SET_SPECIAL_COLORS;

      { create the window to be used to display the maps }
        CREATE_GWINDOW;

        set_mouse( m_bee );
        show_mouse;

      { display the menu.  This seems to take a few seconds to do. }
        draw_menu( MENU ) ;

        set_mouse( m_arrow );

      { wait for an event }
        EVENT_LOOP;

      { dispose of the menu }
        erase_menu( MENU ) ;

      { return the colors to the what they were before I changed them }
        RESTORE_COLORS;
        exit_gem;
      end;
  end.
