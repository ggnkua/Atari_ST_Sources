PROGRAM wind_test ;

  CONST
    {$I gemconst.pas}

  TYPE
    {$I gemtype.pas}

  VAR
    menu : Menu_Ptr ;
    wind_name : Window_Title ;

  {$I gemsubs.pas}

  { Do_Redraw - Redraw an area of a single window by drawing a rectangle with
      an X through it in the area GEM wants us to redraw (not very useful, but
      kind of interesting). }

  PROCEDURE Do_Redraw( window, x0, y0, w0, h0 : integer ) ;

    VAR
      x, y, w, h : integer ;

    BEGIN
      Paint_Color( White ) ;
      Begin_Update ;
      Hide_Mouse ;
      First_Rect( window, x, y, w, h ) ;
      WHILE (w <> 0) OR (h <> 0) DO
        BEGIN
          IF Rect_Intersect( x0, y0, w0, h0, x, y, w, h ) THEN
            BEGIN
              Set_Clip( x, y, w, h ) ;
              Paint_Rect( x, y, w, h ) ;        { First blank the area... }
              Frame_Rect( x, y, w, h ) ;        { The frame it with a box. }
              Line( x, y, x+w-1, y+h-1 ) ;      { Now draw an X in the box. }
              Line( x+w-1, y, x, y+h-1 ) ;
            END ;
          Next_Rect( window, x, y, w, h ) ;
        END ;
      Show_Mouse ;
      End_Update ;
    END ;

  { Get events and open windows, redraw them, and move them around, until the
      last one is closed by the user.  Because GEM only lets us have seven
      windows, that's our maximum number! }

  PROCEDURE Event_Loop ;

    VAR
      wind_count, window, event, junk : integer ;
      msg : Message_Buffer ;

    BEGIN
      wind_count := 0 ;         { We start our with no windows. }
      wind_name := ' Window Sample ' ;
      REPEAT
        event := Get_Event( E_Message, 0, 0, 0, 0,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, junk, junk, junk, junk, junk, junk ) ;
        CASE msg[0] OF
          MN_Selected:
            BEGIN
              window := New_Window( G_Name|G_Size|G_Close|G_Move, wind_name,
                                        0, 0, 0, 0 ) ;
              IF window = No_Window THEN
                junk := Do_Alert( '[3][Out of windows!][  OK  ]', 0 )
              ELSE
                BEGIN
                  Open_Window( window, 0, 0, 0, 0 ) ;
                  wind_count := wind_count + 1 ;
                END ;
              Menu_Normal( menu, msg[3] ) ;
            END ;
          WM_Topped:
            Bring_To_Front( msg[3] ) ;
          WM_Redraw:
            Do_Redraw( msg[3], msg[4], msg[5], msg[6], msg[7] ) ;
          WM_Sized, WM_Moved:
            Set_WSize( msg[3], msg[4], msg[5], msg[6], msg[7] ) ;
          WM_Closed:
            BEGIN
              Close_Window( msg[3] ) ;
              Delete_Window( msg[3] ) ;
              wind_count := wind_count - 1 ;
            END ;
        END ;
      UNTIL (msg[0] = WM_Closed) AND (wind_count = 0) ;
    END ;

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        { We only have a "Desk" menu.  The first item will cause us to open
            a new window. }
        menu := New_Menu( 0, '  New window!' ) ;
        Draw_Menu( menu ) ;
        Event_Loop ;
        Erase_Menu( menu ) ;
        Exit_Gem ;
      END ;
  END.
