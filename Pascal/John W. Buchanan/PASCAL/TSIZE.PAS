
PROGRAM name ;

  CONST
    {$I gemconst.pas}

  TYPE
    {$I gemtype.pas}

  VAR
    height : integer ;
    s : Str255 ;

  {$I gemsubs.pas}

  { Text_Height - Set the height in pixels of text, when it is drawn using the
      Draw_String library call. }

  PROCEDURE Text_Height( height : integer ) ;

    TYPE
      Ctrl_Parms      = ARRAY [ 0..11 ] OF integer ;
      Int_In_Parms    = ARRAY [ 0..15 ] OF integer ;
      Int_Out_Parms   = ARRAY [ 0..45 ] OF integer ;
      Pts_In_Parms    = ARRAY [ 0..11 ] OF integer ;
      Pts_Out_Parms   = ARRAY [ 0..11 ] OF integer ;

    VAR
      control : Ctrl_Parms ;
      int_in  : Int_In_Parms ;
      int_out : Int_Out_Parms ;
      pts_in  : Pts_In_Parms ;
      pts_out : Pts_Out_Parms ;

    PROCEDURE VDI_Call( cmd, sub_cmd : integer ; nints, npts : integer ;
                VAR ctrl : Ctrl_Parms ;
                VAR int_in : Int_In_Parms ; VAR int_out : Int_Out_Parms ;
                VAR pts_in : Pts_In_Parms ; VAR pts_out : Pts_Out_Parms ;
                translate : boolean ) ;
      EXTERNAL ;

    BEGIN
      pts_in[0] := 0 ;
      pts_in[1] := height ;
      VDI_Call(12, 0, 0, 2, control, int_in, int_out, pts_in, pts_out, false);
    END ;

  { Get_Height - Get the height in pixels of text, when it is drawn using the
      Draw_String library call. }

  FUNCTION Get_Height : integer ;

    TYPE
      Ctrl_Parms      = ARRAY [ 0..11 ] OF integer ;
      Int_In_Parms    = ARRAY [ 0..15 ] OF integer ;
      Int_Out_Parms   = ARRAY [ 0..45 ] OF integer ;
      Pts_In_Parms    = ARRAY [ 0..11 ] OF integer ;
      Pts_Out_Parms   = ARRAY [ 0..11 ] OF integer ;

    VAR
      control : Ctrl_Parms ;
      int_in  : Int_In_Parms ;
      int_out : Int_Out_Parms ;
      pts_in  : Pts_In_Parms ;
      pts_out : Pts_Out_Parms ;

    PROCEDURE VDI_Call( cmd, sub_cmd : integer ; nints, npts : integer ;
                VAR ctrl : Ctrl_Parms ;
                VAR int_in : Int_In_Parms ; VAR int_out : Int_Out_Parms ;
                VAR pts_in : Pts_In_Parms ; VAR pts_out : Pts_Out_Parms ;
                translate : boolean ) ;
      EXTERNAL ;

    BEGIN
      VDI_Call(131, 0, 0, 0, control, int_in, int_out, pts_in, pts_out, false);
      Get_Height := pts_out[9] ;
    END ;



  PROCEDURE wait_button ;

    VAR
      msg : Message_Buffer ;
      junk : integer ;

    BEGIN
      junk := Get_Event( E_Button, 1, 1, 1, 0,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, junk, junk, junk, junk, junk, junk ) ;
      junk := Get_Event( E_Button, 1, 0, 1, 0,
                        false, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        msg, junk, junk, junk, junk, junk, junk ) ;
    END ;

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        s := 'nn mm This is a test-- xyzlq' ;
        s[4] := chr( Get_Height DIV 10 + ord( '0' ) ) ;
        s[5] := chr( Get_Height MOD 10 + ord( '0' ) ) ;
        Draw_String( 20, 190, s ) ;
        wait_button ;
        FOR height := 2 TO 99 DO
          BEGIN
            Text_Height( height ) ;
            s[1] := chr( height DIV 10 + ord( '0' ) ) ;
            s[2] := chr( height MOD 10 + ord( '0' ) ) ;
            s[4] := chr( Get_Height DIV 10 + ord( '0' ) ) ;
            s[5] := chr( Get_Height MOD 10 + ord( '0' ) ) ;
            Draw_String( 20, 190, s ) ;
            wait_button ;
          END ;
        Exit_Gem ;
      END ;
  END.


