{ gemconst.pas - Personal Pascal GEM library constant definitions. }

    No_Window  = -1 ;
    Root       = 0 ;            { Index of root w/in object tree }
    Max_Tree   = 100 ;
    Null_Index = -1 ;           { Index of a non-existent item }
    Max_Depth  = 8 ;            { Max depth of search or draw }

    Max_Fn     = 12 ;           { Max length of file and path names }
    Max_Path   = 80 ;
    Max_WTitle = 80 ;

  { Event values: }
    E_Keyboard = $01 ;
    E_Button   = $02 ;
    E_MRect_1  = $04 ;
    E_MRect_2  = $08 ;
    E_Message  = $10 ;
    E_Timer    = $20 ;

  { Graphics command constants: }
    { Drawing modes: }
    Replace_Mode   = 1 ;
    Trans_Mode     = 2 ;
    XOR_Mode       = 3 ;
    Rev_Trans_Mode = 4 ;

  { Line styles: }
    Solid      = 1 ;
    LongDash   = 2 ;
    Dotted     = 3 ;
    DashDot    = 4 ;
    Dashed     = 5 ;
    DashDotDot = 6 ;

  { Text effects: }
    Normal     = 0 ;
    Thickened  = 1 ;
    Lightened  = 2 ;
    Slanted    = 4 ;
    Underlined = 8 ;
    Outlined   = 16 ;
    Shadowed   = 32 ;

  { Font types: }
    System_Font = 3 ;
    Small_Font  = 5 ;

  { Graphic types of obs: }
    G_Box       = 20 ;
    G_Text      = 21 ;
    G_BoxText   = 22 ;
    G_IBox      = 25 ;
    G_Button    = 26 ;
    G_String    = 28 ;
    G_FText     = 29 ;
    G_FBoxText  = 30 ;

  { Object flags: }
    None        = $000 ;    { Also used for fill pattern and text effects. }
    Selectable  = $001 ;
    Default     = $002 ;
    Exit_Btn    = $004 ;
    Editable    = $008 ;
    Radio_Btn   = $010 ;
    Last_Ob     = $020 ;
    Touch_Exit  = $040 ;
    Hide_Tree   = $080 ;

  { Object states }
    { Use Normal for no special state }
    Selected    = $01 ;
    Crossed     = $02 ;
    Checked     = $04 ;
    Disabled    = $08 ;
    { Outlined and Shadowed are defined under text effects }

  { Window elements: }
    G_Name    = $001 ;
    G_Close   = $002 ;
    G_Full    = $004 ;
    G_Move    = $008 ;
    G_Info    = $010 ;
    G_Size    = $020 ;
    G_UpArrow = $040 ;
    G_DnArrow = $080 ;
    G_VSlide  = $100 ;
    G_LArrow  = $200 ;
    G_RArrow  = $400 ;
    G_HSlide  = $800 ;
    G_All     = $FEF ;          { All elements, except info line }

  { Color register shorthands: }
    White       = 0 ;
    Black       = 1 ;
    Red         = 2 ;
    Green       = 3 ;
    Blue        = 4 ;
    Cyan        = 5 ;
    Yellow      = 6 ;
    Magenta     = 7 ;
    L_White     = 8 ;
    L_Black     = 9 ;
    L_Red       = 10 ;
    L_Green     = 11 ;
    L_Blue      = 12 ;
    L_Cyan      = 13 ;
    L_Yellow    = 14 ;
    L_Magenta   = 15 ;

  { Predefined GEM messages: }
    MN_Selected         = 10 ;
    WM_Redraw           = 20 ;
    WM_Topped           = 21 ;
    WM_Closed           = 22 ;
    WM_Fulled           = 23 ;
    WM_Arrowed          = 24 ;
    WM_HSlid            = 25 ;
    WM_VSlid            = 26 ;
    WM_Sized            = 27 ;
    WM_Moved            = 28 ;

  { Wind_Get/Set field values: }
    WF_PrevXYWH         = 6 ;
    WF_FullXYWH         = 7 ;
    WF_HSlide           = 8 ;
    WF_VSlide           = 9 ;
    WF_HSlSize          = 15 ;
    WF_VSlSize          = 16 ;

{ End of gemconst.pas }
 
