PROGRAM name ;

  CONST
    {$I GEMCONST.PAS}

  TYPE
    {$I gemtype.pas}

  VAR
    dialog : Dialog_Ptr ;
    button,
    ok_btn,
    cancel_btn,
    prompt_item,
    date_item : integer ;

  {$I gemsubs}

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        dialog := New_Dialog( 4, 0, 0, 26, 8 ) ;
        prompt_item := Add_DItem( dialog, G_String, None, 2, 1, 0, 0, 0, 0 ) ;
        Set_DText( dialog, prompt_item, 'Please enter the date:',
                        System_Font, TE_Left ) ;
        date_item := Add_DItem( dialog, G_FText, None, 2, 3, 10, 1, 0, $1180 );
        Set_DEdit( dialog, date_item, '__/__/__', '999999', '011362',
                        System_Font, TE_Center ) ;
        ok_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn|Default,
                        2, 5, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, ok_btn, 'OK', System_Font, TE_Center ) ;
        cancel_btn := Add_DItem( dialog, G_Button, Selectable|Exit_Btn,
                        16, 5, 8, 2, 2, $1180 ) ;
        Set_DText( dialog, cancel_btn, 'Cancel', System_Font, TE_Center ) ;
        Center_Dialog( dialog ) ;
        button := Do_Dialog( dialog, date_item ) ;
        Exit_Gem ;
      END ;
  END.

