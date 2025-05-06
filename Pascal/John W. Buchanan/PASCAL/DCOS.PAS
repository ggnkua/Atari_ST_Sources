PROGRAM dcos ;

{ Graphics Example - derived from dcos.c --- J. Lohse 20.8.1985 }
{ Modified for new Pascal GEM libraries  --- 27 Dec 1985    MER }

  CONST
    {$I gemconst.pas}

  TYPE
    {$I gemtype.pas}

  VAR
    which,
    dummy,
    handle,
    min_width,
    min_height : integer ;
    msg : Message_Buffer ;
    wind_type : integer ;
    title : Window_Title ;

  {$I gemsubs.pas}

  PROCEDURE draw_sample ;

    TYPE
      zerototwo = ARRAY [ 0..2 ] OF integer;

    VAR
      number, y1, y2 : real ;
      iter, lloop : integer ;
      amp, per : zerototwo ;
      x, y, w, h : integer ;

    FUNCTION random: integer;
      XBIOS(17);

    BEGIN { draw_sample }
      Work_Rect( handle, x, y, w, h ) ;
      Set_Clip( x, y, w, h ) ;
      Paint_Style( Solid ) ;
      Paint_Color( White ) ;
      Paint_Rect( x, y, w, h ) ;
      amp[0] := 3 ;
      amp[1] := 2 + random & 7 ;
      amp[2] := 3 + random & 3 ;
      per[0] := 40 + random & 31 ;
      per[1] := 50 ;
      per[2] := 20 + random & 63 ;

      FOR lloop := 0 TO 2 DO
        BEGIN
          Line_Color( lloop+2 ) ;
          iter := 0;
          WHILE iter < w DO
            BEGIN
              number := iter;
              y1 := sin(number / per[lloop]) ;
              y1 := y1 * (h / amp[lloop]) ;
              y1 := y + y1 + h / 2 ;
              y2 := cos(number / per[lloop]) ;
              y2 := y2 * (h / amp[lloop]) ;
              y2 := y + y2 + h / 2 ;
              Line( x+iter, round(y1), x+w-iter-1, round(y2) ) ;
              iter := iter + 3
            END
        END
    END { draw_sample };

  BEGIN { dcos }
    IF Init_Gem >= 0 THEN
      BEGIN
        Sys_Font_Size( dummy, dummy, min_width, min_height ) ;
        min_width := min_width * 4 ;
        min_height := min_height * 4 ;
        Set_Mouse( M_Arrow ) ;
        wind_type := G_Size|G_Move|G_Close|G_Name ;
        title := ' Pascal Cosine Color Show ' ;
        handle := New_Window( wind_type, title, 0, 0, 0, 0 ) ;
        Open_Window( handle, 0, 0, 0, 0 ) ;
        msg[0] := 0;

        REPEAT
          IF NOT ((msg[0] = WM_Redraw) AND (which = E_Message)) THEN
            BEGIN
              Hide_Mouse ;
              Begin_Update ;
              draw_sample;
              End_Update ;
              Show_Mouse ;
            END;

          which := Get_Event( E_Message|E_Timer, 0, 0, 0, 10000,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, dummy, dummy, dummy, dummy, dummy, dummy ) ;

          IF which & E_Message <> 0 THEN
            IF (msg[0] = WM_Sized) OR (msg[0] = WM_Moved) THEN
              BEGIN
                IF msg[6] < min_width THEN
                  msg[6] := min_width ;
                IF msg[7] < min_height THEN
                  msg[7] := min_height ;
                Set_WSize( handle, msg[4], msg[5], msg[6], msg[7] ) ;
              END

        UNTIL msg[0] = WM_Closed ;

        Close_Window( handle ) ;
        Delete_Window( handle ) ;
        Exit_Gem ;
      END
  END.
