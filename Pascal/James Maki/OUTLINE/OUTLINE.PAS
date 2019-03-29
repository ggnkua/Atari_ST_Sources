{$E+}
program OutLinePlus;
{
*************************************************************************
*                                                                       *
*                           Outline Plus                                *
*                           ------- ----                                *
*                                by                                     *
*                                                                       *
*                           James W. Maki                               *
*                                                                       *
*                           4409 London Court                           *
*                           Indianapolis, IN   46254                    *
*                           317-299-5816                                *
*                                                                       *
*                                                                       *
*   Started       : September 21, 1987                                  *
*   Last Revision : July 31, 1988                                       *
*                                                                       *
*************************************************************************
}
      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }


  procedure KB_Input( HiByte, LoByte : short_integer);
     External ;

  procedure MB_Input ;
     External ;

  procedure Do_OpenWind;
     External ;

  procedure Do_CloseWind(WindMsg : short_integer) ;
     External ;

  procedure SetUpMenu ;
     External ;

  procedure Menu_Select ;
     External ;

  procedure Do_Redraw(WindMsg : short_integer) ;
     External ;

  procedure SetPtLabel( WindNo : short_integer );
     External ;

  procedure Draw_Window(CurRec : WordPointer ; 
                        WindMsg, LineNo : short_integer ) ;
     External ;

  procedure Draw_VSlide(Wind : short_integer);
     External ;

  procedure Draw_HSlide(Wind : short_integer);
     External ;

  procedure NewCursor(XP, Y, WindNo : short_integer ; CurRec : WordPointer) ;
     External ;

  procedure Set_MenuBar ;
     External ;


 procedure ChkCursorPos ;

   var
       i        : short_integer ;
       DrawFlag : boolean ;

   procedure HorizScroll(Var DrawFlag : boolean) ;

    var
        LevelOffset : short_integer ;

     begin
       if Current[Module] = nil then
          LevelOffset := 16
       else
          LevelOffset := Current[Module]^.Level * 3 + 16 ;
       if XPos[Module] + LevelOffset > WindOffset[Module] + NumColumns - 2 then
          begin
            XPos[Module] := XPos[Module] - 1 ;
            if XPos[Module] < 1 then
               begin
                 XPos[Module] := 1 ;
                 WindOffset[Module] := WindOffset[Module] + 1 ;
               end ;
            HorizScroll(DrawFlag) ;
            DrawFlag := true ;
          end ;
     end ;


    begin
      if Current[Module] <> nil then
         begin
           Work_Rect(Module, x, y, w, h) ;
           Set_Clip(x,y,w,h) ;
           NumLines   := h DIV (9 * Resolution) ;
           NumColumns := w DIV 8 ;

           DrawFlag := false ;
           HorizScroll(DrawFlag) ;
           if DrawFlag then 
              begin
                SetPtLabel( Module );
                Draw_Window(ScrFirstRec[Module], Module, 1) ;
              end ;

           if YPos[Module] > NumLines then
              for i := NumLines to YPos[Module] - 1 do
                  begin
                    YPos[Module] := YPos[Module] - 1 ;
                    Current[Module] := Current[Module]^.Prev ;
                  end ;
           if XPos[Module] > Length(Current[Module]^.NewWord) then
              XPos[Module] := Length(Current[Module]^.NewWord) + 1 ;
           NewCursor(XPos[Module], YPos[Module], 
                     Module, Current[Module] ) ;
         end ;
    end ;

 procedure Wind_VSlide( WindNo, SlidePos : short_integer ) ;

   var
       i,
       StartRec : short_integer ;
       CurRec   : WordPointer ;
       L_I,
       L_Rec,
       L_Offset,
       L_SlidePos : long_integer ;

    begin
      L_I := 1 ;
      L_SlidePos := L_I * SlidePos;
      L_Rec      := L_I * TotalRec[WindNo] ;
      L_Offset := ((L_Rec - (h DIV (9 * Resolution))) * L_SlidePos) DIV 1000 ;
      StartRec := Int(L_Offset) ;
      VertOffset[WindNo] := StartRec ;

      CurRec := FirstRec[WindNo] ;
      for i := 1 to StartRec do
          CurRec := CurRec^.Next ;

      ScrFirstRec[WindNo] := CurRec ;
      for i := 1 to YPos[WindNo] - 1 do
          CurRec := CurRec^.Next ;
      Current[WindNo]     := CurRec ;
      if XPos[WindNo] > Length(Current[WindNo]^.NewWord) then
         XPos[WindNo] := Length(Current[WindNo]^.NewWord) ;
      Draw_Window(ScrFirstRec[WindNo], WindNo, 1) ;
    end ;

 procedure Wind_VArrow(Var CurRec : WordPointer ; Display : short_integer ; 
                       Var Offset : short_integer ;
                           Max, WindNo : short_integer);

  var
      i : short_integer ;

   procedure DecWindow ;

     begin
       if ScrFirstRec[WindNo]^.Prev <> nil then
          begin
            ScrFirstRec[WindNo] := ScrFirstRec[WindNo]^.Prev ;
            if CurRec^.Prev <> nil then
               CurRec := CurRec^.Prev ;
            Offset := Offset - 1 ;
          end ;
      end ;

   procedure AdvanWindow ;

      begin
        if (ScrFirstRec[WindNo]^.Next <> nil) AND
           (Offset + Display < Max) then
           begin
             ScrFirstRec[WindNo] := ScrFirstRec[WindNo]^.Next ;
             if CurRec^.Next <> nil then
                CurRec := CurRec^.Next ;
             Offset := Offset + 1 ;
           end ;
      end ;

   begin
     case Gem_Result.msg[4] of
         0 : for i := 1 to Display do
                 DecWindow ;
         1 : for i := 1 to Display do
                 AdvanWindow ;
         2 : DecWindow ;
         3 : AdvanWindow ;
     end;
     if XPos[WindNo] > Length(CurRec^.NewWord) then
        XPos[WindNo] := Length(CurRec^.NewWord) + 1 ;
     Draw_Window(ScrFirstRec[WindNo], WindNo, 1) ;
   end;


 procedure Wind_HSlide( WindNo, SlidePos : short_integer ) ;

  var
      L_I,
      L_Offset,
      L_SlidePos : long_integer ;

    begin
      L_I := 1 ;
      L_SlidePos := L_I * SlidePos;
      L_Offset := ((130 - (w DIV 8)) * L_SlidePos) DIV 1000 ;
      WindOffset[WindNo] := Int(L_Offset) ;
      Draw_Window(ScrFirstRec[WindNo], WindNo, 1) ;
    end ;


 procedure Wind_HArrow(Display : short_integer ; Var Offset : short_integer ;
                       Max, WindNo : short_integer);

   begin
     case Gem_Result.msg[4] of
         4 : Offset := Offset - Display;   
         5 : Offset := Offset + Display;   
         6 : Offset := Offset - 1;    
         7 : Offset := Offset + 1;    
     end;

     if Offset + Display > Max then
        Offset := Max - Display ;

     if Offset <= 0 then Offset := 0;

     Draw_Window(ScrFirstRec[WindNo], WindNo, 1) ;
   end;


 procedure Event_Loop;

  var
     Gem_Event,
     LevelOffset,
     SaveByte    : short_integer ;

  begin
    Module := Front_Window ;
    Work_Rect(Module, x, y, w, h) ;
    Set_Clip(x, y, w, h) ;
    if N_Window > 0 then
       begin
         if Current[Module] = nil then
            LevelOffset := 16
         else
            LevelOffset := Current[Module]^.Level * 3 + 16 ;
         XOffset[Module] := x + 10 - (WindOffset[Module] - LevelOffset) * 8 ;
         YOffset[Module] := y - 2 * Resolution ;
         NumLines        := h DIV (9 * Resolution) ;
         NumColumns      := w DIV 8 ;
       end ;
    with Gem_Result do
         begin
           Gem_Event := Get_Event(
                        E_Keyboard | E_Button | E_Timer | E_Message,
                        RL_Button, Up_Down, B_Clicks,
                        Timing,
                        false,0,0,0,0,
                        false,0,0,0,0,
                        msg,
                        Key_Input,
                        B_Count, B_State,
                        X_Mouse, Y_Mouse,
                        Key_State);
     if (Gem_Event & E_Message) <> 0 then
        Case msg[0] of
             MN_Selected : Menu_Select ;
             WM_Closed   : Do_CloseWind(msg[3]) ;
             WM_Redraw   : Do_Redraw(msg[3]) ;
             WM_Topped   : Bring_To_Front(msg[3]) ;
             WM_Fulled   : Set_WSize(msg[3], 0  ,  9 * Resolution,
                                             640,191 * Resolution) ;
             WM_Sized    : begin
                             Set_WSize(msg[3], msg[4], msg[5], msg[6], msg[7]) ;
                             ChkCursorPos ;
                             Draw_VSlide(Module) ;
                             Draw_HSlide(Module) ;
                           end ;
             WM_Moved    : Set_WSize(msg[3], msg[4], msg[5], msg[6], msg[7]);
             WM_VSlid    : if Current[Module] <> nil then
                              Wind_VSlide(msg[3],msg[4]) ;
             WM_HSlid    : if Current[Module] <> nil then
                              Wind_HSlide(msg[3],msg[4]) ;
             WM_Arrowed  : if Current[Module] <> nil then
                              case msg[4] of
                                 0,1,2,3 : Wind_VArrow(Current[Module],
                                                       h DIV (9 * Resolution),
                                                       VertOffset[Module],
                                                       TotalRec[Module], 
                                                       Module);
                                 4,5,6,7 : Wind_HArrow(w DIV 8,
                                                       WindOffset[Module],
                                                       130, Module);
                              end ;
        end
     else
        if (Gem_Event & E_Button) <> 0 then
           begin
             if Up_Down = $01 then
                Up_Down := $00
             else
                begin
                  Up_Down := $01;
                  MB_Input;
                end;
           end
        else
           if (Gem_event & E_Keyboard) <> 0 then
              begin
                HiByte    := ShR(Key_Input, 8);
                SaveByte  := ShL(Key_Input, 8);
                LoByte    := ShR(SaveByte, 8);
                KB_Input(HiByte, LoByte);
                HiByte := 0;
                LoByte := 0;
              end;
    end;
  end;

  procedure Res_Alert ;

    var
        AlertStr : Str255 ;
        Result   : short_integer ;

     begin
       AlertStr := '[3][ Program Does NOT Work |    In Low Resolution   ]' ;
       AlertStr := Concat(AlertStr,'[ Continue ]') ;
       Result := Do_Alert(AlertStr, 1) ;
     end ;

  procedure GetMemBlocks ;

    var
        NumRec : long_integer ;
        InStr  : Str255 ;

     begin
       NumRec := MemAvail DIV SizeOf(WordRecord) ;
       MaxRec := (Int(NumRec) - 1) * 2 ;
     end ;

  function Get_Resolution : short_integer ;
     XBIOS( 4 ) ;

  procedure Get_DefPath(Var buf:c_string; DriveNo : short_integer) ;  
     GEMDOS( $47 ) ;

  function Get_DriveNo : short_integer ;
     GEMDOS( $19 ) ;

  begin
    if Init_Gem >= 0 then
       begin
         Init_Mouse;
         ExitPrompt := false ;
         Resolution := Get_Resolution ;
         SetUpMenu ;

         with Gem_Result do
          begin
            RL_Button := $01 ; 
            Up_Down   := $01 ; 
            B_Clicks  := 1 ;
            Timing    := 1 ;
          end ;

         N_Window  := 0 ;
         Module    := 0 ;
         BlkModule := 0 ;
         TotRec    := 0 ;
         SearchStr := '' ;

        { Set Default Directory to Current Drive and Path }
         i := Get_DriveNo ;
         Get_DefPath(C_PathStr, 0) ;
         C_To_PStr(C_PathStr, P_PathStr) ;
         DefaultFn := Concat(chr(i + 65),':',P_PathStr, '\*.OLP') ;

         for i := 1 to MaxWind do
             begin
               XOffset[i]    := 0 ;
               YOffset[i]    := 0 ;
               WindHandle[i] := 0 ;
               WindOffset[i] := 0 ;
               FirstRec[i]   := nil ;
               Current[i]    := nil ;
               LastRec[i]    := nil ;
               TotalRec[i]   := 0 ;
               EditFlag[i]   := false ;
             end ;

         if Resolution = 0 then
            Res_Alert
         else
            begin
              GetMemBlocks ;
              Do_OpenWind;
              Set_MenuBar ;
              repeat
                 Event_Loop;
              Until ExitPrompt;
            end ;
       end;
    Exit_Gem;
  end.
