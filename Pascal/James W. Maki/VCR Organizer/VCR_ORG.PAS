{$E+}
program VCR_Labeler;
{
*************************************************************************
*                                                                       *
*                            VCR Labeler                                *
*                            --- -------                                *
*                                by                                     *
*                                                                       *
*                           James W. Maki                               *
*                                                                       *
*                     Copyright 1988 Antic Publishing                   *
*                                                                       *
*                                                                       *
*   Started       : April 2, 1987                                       *
*   Last Revision : November 3, 1988                                    *
*                                                                       *
*************************************************************************
}

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

 Const
      {$I B:VCR_CNST.Pas }

 Type
      {$I B:VCR_Type.Pas }


 Var
      {$I B:VCR_Var.Pas }


  procedure New_Cursor;
     External ;

  procedure Open_DO_Wind( i : integer ) ;
     External ;

  procedure Do_Close_Window( Wind_Msg : integer ) ;
     External ;

  procedure Menu_Select;
     External ;

  procedure Draw_Logo( Var Logo_Result : integer );
     External ;

  procedure Draw_SetUp( Var SetUp_Result : integer );
     External ;

  procedure Draw_Names;
     External ;

  procedure Draw_Numbers;
     External ;

  procedure SetUpMenu;
     External ;

  procedure Set_MenuBar(NewWind: integer) ;
     External ;

  procedure MB_Input ;
     External ;

  procedure Keyboard_Input;
     External ;

  procedure Get_MovieRec( Letter : integer ) ;
     External ;

  procedure Get_TapeNo;
     External ;

  procedure SaveSelect;
     External ;

  procedure AbortSelect;
     External ;

  procedure EditSave;
     External ;

  procedure ExitProgram;
     External ;

  procedure ClearSelect;
     External ;

  procedure Make_Folder( NewFolder : string ) ;
     External ;

  procedure Do_Redraw;
     External ;

  procedure Alert_Box(L1, L2, L3, L4, L5 : integer;
                      S1, S2, S3 : string ; n : integer ;
                      Var Result : integer);
     External ;

  procedure MB_Main;
     External ;


{$I B:INIT_INC.PAS }


  procedure Draw_Update( i : integer ) ;

   begin
     if i = 4 then Draw_Names
     else
        if i = 5 then Draw_Numbers;
   end;


 procedure Wind_Arrow(Display : integer ; Var Offset : integer ;
                      Max, Wind_No : integer);

  var
      L_Offset,
      L_Slide_Pos,
      L_I          : long_integer;

   begin
     L_I := 1;
     case Gem_Result.msg[4] of
         0 : Offset := Offset - Display;
         1 : Offset := Offset + Display;
         2 : Offset := Offset - 1;
         3 : Offset := Offset + 1;
     end;

     if Offset + Display > Max then
        Offset := Max - Display ;

     if Offset <= 0 then Offset := 0;

     L_Offset := Offset * L_I;

     if Max <= Display then
        L_Slide_Pos := 1
     else
        L_Slide_Pos := (L_Offset * 1000) DIV (Max - Display);

     Offset    := int(L_Offset);
     Slide_Pos := int(L_Slide_Pos);

     if Slide_Pos < 1 then Slide_Pos := 1;
     Wind_Set(Wind_Handle[Wind_No], WF_VSlide, Slide_Pos, Dummy, Dummy, Dummy);
     Draw_Update(Wind_No);
   end;


 procedure Wind_Slide(Display : integer ; Var Offset : integer ;
                      Max, Wind_No : integer);

  var
      L_Offset,
      L_Slide_Pos,
      L_I          : long_integer;

   begin
     if Max <= Display then
        begin
          Slide_Pos := 1;
          Offset := 0;
        end
     else
        begin
          L_I := 1;
          L_Offset := Gem_Result.msg[4] * L_I;
          L_Offset := (L_Offset * (Max - Display)) DIV 1000;

          if L_Offset + Display > Max then
             L_Offset := (Max - Display) * L_I ;

          if Max <= Display then
             L_Slide_Pos := L_I
          else
             L_Slide_Pos := (L_Offset * 1000) DIV (Max - Display);

          Offset    := int(L_Offset);
          Slide_Pos := int(L_Slide_Pos);
        end;

     if Slide_Pos < 1 then Slide_Pos := 1;
     Wind_Set(Wind_Handle[Wind_No], WF_VSlide, Slide_Pos, Dummy, Dummy, Dummy);
     Draw_Update(Wind_No);
   end;


 procedure Event_Loop;

  var
     i,
     Gem_Event : integer ;
     Timing    : long_integer;

  begin
     if N_Window > 0 then
        begin
          Module := Front_Window;
          Work_Rect(Module, x0, y0, w0, h0);
          Set_Clip(x0, y0, w0, h0);
          if Module <> Prev_Module then
             for i := 1 to 5 do
                 if Module = Wind_Handle[i] then
                    begin
                      Set_MenuBar(i);
                      Case i of
                           1 : Field := 3;
                       else  : Field := 0;
                      end;
                      if Field > 0 then
                         New_Cursor;
                    end;
        end
     else
        begin
          Module := -10;
          Prev_Module := -20;
          for i := 1 to 5 do
              Wind_Handle[i] := -20;
        end;
    Prev_Module := Module;
    With Gem_Result do
    begin
     Gem_Event := Get_Event(
       E_Keyboard | E_Button | E_Timer | E_MRect_1 | E_MRect_2 | E_Message,
       RL_Button, Up_Down, B_Clicks,
       Timing,
       InBox1, X_Pos[1], Y_Pos[1] * Resolution,
       Width[1], Height[1] * Resolution,
       InBox2, X_Pos[2], Y_Pos[2] * Resolution,
       Width[2], Height[2] * Resolution,
       msg,
       Key_Input,
       B_Count, B_State,
       X_Mouse, Y_Mouse,
       Key_State);
     if (Gem_Event & E_Message) <> 0 then
        Case msg[0] of
             MN_Selected : Menu_Select;
             WM_Closed   : begin
                             if msg[3] = Wind_Handle[1] then
                                begin
                                  if VCR_Retrieve then
                                     EditSave
                                  else
                                     begin
                                       Len := Length(Input_String[4]);
                                       if Len > 0 then
                                          SaveSelect;
                                     end;
                                  VCR_Retrieve := false;
                                 end;
                             Do_Close_Window(msg[3]);
                           end;
             WM_Redraw   : Do_Redraw;
             WM_Topped   : if msg[3] = Wind_Handle[3] then
                              MB_Main
                           else
                              begin
                                Bring_To_Front(msg[3]);
                                if msg[3] = Wind_Handle[4] then
                                   Get_MovieRec(Letter)
                                else
                                   if msg[3] = Wind_Handle[5] then
                                      Get_TapeNo;
                              end;
             WM_Sized    : Set_WSize(msg[3], msg[4], msg[5], msg[6], msg[7]);
             WM_Moved    : Set_WSize(msg[3], msg[4], msg[5], msg[6], msg[7]);
             WM_VSlid    : if Module = Wind_Handle[4] then
                              Wind_Slide(5, Name_Offset, Dsply_Name, 4)
                           else
                              if Module = Wind_Handle[5] then
                                 Wind_Slide(15,Tape_Offset, Dsply_Tape, 5);
             WM_Arrowed  : if Module = Wind_Handle[4] then
                              Wind_Arrow(5, Name_Offset, Dsply_Name, 4)
                           else
                              if Module = Wind_Handle[5] then
                                 Wind_Arrow(15,Tape_Offset, Dsply_Tape, 5);
        end
     else
        if (Gem_Event & E_Button) <> 0 then
             MB_Input
        else
           if (Gem_event & E_Keyboard) <> 0 then
              begin
                HiByte    := ShR(Key_Input, 8);
                SaveByte  := ShL(Key_Input, 8);
                LoByte    := ShR(SaveByte, 8);
                Character := chr(LoByte);
                Keyboard_Input;
                HiByte := 0;
                LoByte := 0;
              end;
    end;
  end;


  function Get_Resolution : integer ;
     XBIOS( 4 ) ;

  Begin
    if Init_Gem >= 0 then
    begin
      Resolution := Get_Resolution ;
      if Resolution = 0 then
         Alert_Box(1,0,2,0,3,'Continue',No_Sp,No_Sp,1,i)
      else
         begin
           Init_Mouse;
           Init_Values;
           SetUpMenu;
           Draw_Logo( i );                   { opening screen dialog box }
           Open_DO_Wind(3);
            Event_Loop;
           Open_DO_Wind(4);
            Event_Loop;
           Open_DO_Wind(5);
           repeat
             Event_Loop;
           Until ExitPrompt;

         end;
    end;
    Exit_Gem;
  end.
