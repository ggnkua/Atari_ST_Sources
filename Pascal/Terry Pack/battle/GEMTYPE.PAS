{ gemtype.pas - Common GEM type definitions for Personal Pascal library. }

    Color_Reg = 0..15 ;
    Draw_Modes = Replace_Mode..Rev_Trans_Mode ;
    Line_Types = Solid..DashDotDot ;

    Mouse_Type = ( M_Arrow, M_Text_Curs, M_Bee, M_Point_Hand, M_Flat_Hand,
                   M_Thin_Cross, M_Thick_Cross, M_Outln_Cross ) ;

    Dialog_Ptr      = ^char ;
    Menu_Ptr        = ^char ;
    Word16 = ARRAY [ 0..15 ] OF integer ;
    Mouse_Form = RECORD
                   hot_x : integer ;
                   hot_y : integer ;
                   res : integer ;
                   mask_color : integer ;
                   data_color : integer ;
                   mask : Word16 ;
                   data : Word16 ;
                 END ;

    File_Name    = STRING [ Max_Fn ] ;
    Path_Name    = STRING [ Max_Path ] ;
    Window_Title = STRING [ Max_WTitle ] ;

    Message_Buffer = ARRAY [ 0..15 ] OF integer ;

    Str255 = STRING [ 255 ] ;

  { Editable text justification: }
    TE_Just = ( TE_Left, TE_Right, TE_Center ) ;

  { Possible indices into a tree: }
    Tree_Range = Root..Max_Tree ;
    Tree_Index = Null_Index..Max_Tree ;

{ End of gemtype.pas }
 
