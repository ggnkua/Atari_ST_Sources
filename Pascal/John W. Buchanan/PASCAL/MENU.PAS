PROGRAM Menu_Example ;

  CONST
    {$I GEMCONST.PAS}
    Desk_Title = 3 ;    { The index of the "desk" item in the menu bar }

  TYPE
    {$I gemtype.pas}

  VAR
    menu : Menu_Ptr ;
    dummy,
    file_title,
    edit_title,
    open_item,
    close_item,
    cut_item,
    paste_item : integer ;

  {$I gemsubs}          { and that ".PAS" is default }

  PROCEDURE Do_Menu( title, item : integer ) ;

    VAR
      alert : Str255 ;

    BEGIN
      IF title = Desk_Title THEN
        alert := '[1][You chose the "Desk" menu.][ OK ]'
      ELSE IF title = file_title THEN
        alert := '[1][You chose the "File" menu.][ OK ]'
      ELSE IF title = edit_title THEN
        alert := '[1][You chose the "Edit" menu.][ OK ]' ;
      dummy := Do_Alert( alert, 1 ) ;
      Menu_Normal( menu, title ) ;
    END ;

  PROCEDURE Event_Loop ;

    VAR
      which : integer ;
      msg : Message_Buffer ;

    BEGIN
      REPEAT
        which := Get_Event( E_Message, 0, 0, 0, 0,
                false, 0, 0, 0, 0, false, 0, 0, 0, 0, msg,
                dummy, dummy, dummy, dummy, dummy, dummy ) ;
        { Since we only asked for message events, we don't need to check that
          we did, indeed, get a message event. }
        Do_Menu( msg[3], msg[4] ) ;
      UNTIL msg[3] = Desk_Title ;
    END ;

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        menu := New_Menu( 6, '  Simple Menu Test' ) ;
        file_title := Add_MTitle( menu, ' File ' ) ;
        edit_title := Add_MTitle( menu, ' Edit ' ) ;
        open_item  := Add_MItem( menu, file_title, '  Open   ' ) ;
        close_item := Add_MItem( menu, file_title, '  Close  ' ) ;
        cut_item   := Add_MItem( menu, edit_title, '  Cut    ' ) ;
        paste_item := Add_MItem( menu, edit_title, '  Paste  ' ) ;
        Draw_Menu( menu ) ;
        Event_Loop ;
        Erase_Menu( menu ) ;
        Exit_Gem ;
      END ;
  END.

