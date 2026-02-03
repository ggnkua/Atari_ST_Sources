PROGRAM Hello ;

  CONST
    {$I gemconst}

  TYPE
    {$I gemtype}

  {$I gemsubs}

  PROCEDURE Event_Loop ;

    VAR
      which,
      dummy,
      key_state,
      x,
      y : integer ;
      msg : Message_Buffer ;

    BEGIN
      REPEAT
        { Get a mouse button event. }
        which := Get_Event( E_Button, 1, 1, 1, 0,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, dummy, dummy, dummy, x, y, key_state ) ;
        { We don't test "which" to tell what event occurred, since we only
          asked for button events! }
        Hide_Mouse ;
        Draw_String( x, y, 'hello, world' ) ;
        Show_Mouse ;
      UNTIL key_state & $03 <> 0 ;
    END ;

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        Hide_Mouse ;
        Clear_Screen ;
        Draw_String( 0, 15,
         ' "hello, world" demo-- press mouse button, SHIFT-button exits.' ) ;
        Text_Style( Slanted ) ;
        Set_Mouse( M_Arrow ) ;
        Show_Mouse ;
        Draw_Mode( Trans_Mode ) ;
        Event_Loop ;
        Exit_Gem ;
      END ;
  END.
