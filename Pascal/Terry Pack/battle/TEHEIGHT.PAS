{ Text_Height - Set the height in pixels of text, when it is drawn using the
      Draw_String library call. }

PROCEDURE Text_Height( height : Integer );
TYPE  Ctrl_Parms      = ARRAY [ 0..11 ] OF integer ;
      Int_In_Parms    = ARRAY [ 0..15 ] OF integer ;
      Int_Out_Parms   = ARRAY [ 0..45 ] OF integer ;
      Pts_In_Parms    = ARRAY [ 0..11 ] OF integer ;
      Pts_Out_Parms   = ARRAY [ 0..11 ] OF integer ;
VAR   control : Ctrl_Parms ;
      int_in  : Int_In_Parms ;
      int_out : Int_Out_Parms ;
      pts_in  : Pts_In_Parms ;
      pts_out : Pts_Out_Parms ;

PROCEDURE VDI_Call(cmd, sub_cmd : integer ; nints, npts : integer ;
                   VAR ctrl : Ctrl_Parms ;
                   VAR int_in : Int_In_Parms ; VAR int_out : Int_Out_Parms ;
                   VAR pts_in : Pts_In_Parms ; VAR pts_out : Pts_Out_Parms ;
                   translate : boolean ) ;
EXTERNAL;

BEGIN { Text_Height }
   pts_in[0] := 0 ;
   pts_in[1] := height ;
   VDI_Call(12, 0, 0, 2, control, int_in, int_out, pts_in, pts_out, false);
END ;

