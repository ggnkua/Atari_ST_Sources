{InfoBase ST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program Input_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{   **********************  External  **********************************   }
  PROCEDURE HelpScreen ;
    EXTERNAL ;

  procedure ClrHome ;
     External ;
     
  procedure NewCursor(ScrMode : short_integer) ;
     External ;
     
  procedure EraseCursor(ScrMode : short_integer) ;
     External ;

  procedure CheckCurLoc(Var CurLoc : short_integer ;
                        Var Current : ScrPtr ; 
                            XPos, YPos, ScrMode : short_integer ) ;
     External ;

  procedure DetCurRec(    D_CurRec : DataStorePtr ;
                      Var CurRec   : DataStorePtr ; 
                      Var Location : short_integer ) ;
     External ;

  procedure GetChar(      CurRec  : ScrPtr ;
                        D_CurRec  : DataPtr ; 
                    Var Character : StrChar ;
                        Position  : short_integer ) ;
     External ;

  procedure GetStr(CurRec   : DataPtr ; Var DisplayStr : Str255 ;
                   StartPos, Size : short_integer ) ;
     External ;

  procedure CheckOverLap( NewRec : ScrPtr ; X, Y : short_integer ; 
                         Var OverLap : boolean ) ;
     External ;

  procedure ChangeMode( Var Mode, NewMode : short_integer ) ;
     External ;

  procedure MenuOption ;
     External ;

  procedure Select_Open( Var NewMode : short_integer ) ;
     External ;
     
  procedure Select_Close ;
     External ;

  procedure Select_Save ;
     External ;
     
  procedure ExitProgram ;
     External ;

  procedure Paint_Frame( x, y, w : short_integer ) ;
     External ;

  procedure EraseARec( CurRec : ScrPtr ) ;
     External ;

  procedure DrawAField( CurRec : ScrPtr ) ;
     External ;

  procedure DrawScreen( CurRec : ScrPtr ) ;
     External ;

  procedure DrawRecord(CurRec : DataPtr) ;
     External ;

  procedure DrawDZ_In ;
     External ;
     
  procedure DrawDZ_Out ;
     External ;
          
  procedure ModifyStr(CurRec : DataPtr ; Location : short_integer ; 
                      InChar : char) ;
     External ;

  procedure DeleteChar(ScrRec  : ScrPtr ; DataRec : DataPtr ; 
                       Loc     : short_integer ) ;
     External ;

  procedure InsertChar(CurRec  : ScrPtr ; DataRec : DataPtr ; 
                       NewChar : char ;   Loc     : short_integer ) ;
     External ;
     
  procedure Select_Modify ;
     External ;

  procedure Select_Enter ;
     External ;

  procedure SelectSearch( Var NewMode : short_integer ) ;
     External ;

  procedure SelectInput( Var NewMode : short_integer ) ;
     External ;

  procedure SelectOutput( Var NewMode : short_integer ) ;
     External ;

  procedure SelectSort( Var NewMode : short_integer ) ;
     External ;

  procedure DeleteARec(CurRec : ScrPtr) ;
     External ;
     
  procedure DS_DeleteARec(CurRec : DataPtr) ;
     External ;

  procedure ClearRecord( CurRec : DataPtr ) ;
     External ;

  procedure CreateDataRec(DataNum : short_integer) ;
     External ;

  procedure Int_AddARec(Var FirstRec, CurRec, LastRec : IntPtr ; 
                            Value : short_integer ) ;
     External ;

  procedure IncrementRec(Var  CurRec : DataPtr ; Value : short_integer ;
                              DrawFlag : boolean ) ;
     External ;

  procedure GoToFirst( Var CurRec : DataPtr ; DrawFlag : boolean ) ;
     External ;
     
  procedure GoToLast(Var CurRec : DataPtr ; DrawFlag : boolean) ;
     External ;
     
  procedure FormatCheck( CurRec : DataPtr ) ;
     External ;
     
  procedure AutoDate(    ScrRec : ScrPtr ; DataRec : DataPtr ;
                     Var DateStr : Str255 ) ;
     External ;

  procedure GetAscii(    Character : StrChar ;
                     Var CharInt : short_integer) ;
     External ;

{   ***********************  Routines **********************************   }

{  ********************************************************************
     Input Info returns a string containing a description of the Data Type
     of the current field (i.e., translates DataType to a description).
************************************************************************* }
  procedure InputInfo(Var FormatStr : Str255)  ;

    var
        i, Count  : byte ;
        TypeStr   : Str20 ;
 
     begin
       for i := $41 to $48 do
           if chr(i) = S_CurrentRec[ScrNum]^.DataType then
              begin
                case i of
                    $41 : TypeStr := 'String' ;
                    $42 : TypeStr := 'Boolean' ;
                    $43 : TypeStr := 'Integer' ;
                    $44 : TypeStr := 'Company' ;
                    $45 : TypeStr := 'Real' ;
                    $46 : TypeStr := 'Dollar' ;
                    $47 : TypeStr := 'Date' ;
                    $48 : TypeStr := 'Name' ;
                end ;
                i := $50 ;
              end ;

       WriteV(FormatStr, ' DataType :', TypeStr:8, chr($7C):3, 
                         'Record #':12, RecNo[DataNum]:5,
                         ' of', TotalRec[DataNum]:5, chr($7C):3) ; 
     end ;

{ *************************************************************************
     Search Info returns a string containing a description of the search
     criteria for the current field (i.e., translates a short_integer 
     to a formula description).
************************************************************************* }
  procedure SearchInfo(    S_Int : short_integer ;
                       Var S_Str : Str20) ;

     begin
       Case S_Int of
           1 : S_Str := '=' ;
           2 : S_Str := '>' ;
           3 : S_Str := '<' ;
           4 : S_Str := '<>' ;
           5 : S_Str := '<=' ;
           6 : S_Str := '>=' ;
       end ;
     end ;

{ *************************************************************************
     Update Info Line creates a string to be displayed on the Info Line.
     The information displayed depends upon the current mode and search
     or sort criteria.
************************************************************************* }
  procedure UpdateInfoLine ;

    var
       MatchStr  : Str20 ;
       SearchStr : Str255 ;
       L_I,
       L_SlidePos : long_integer ;

     begin
       UpdateFlag := false ;
       L_SlidePos := 1 ;
       L_I := 1 ;
       Case Mode of
           1 : WriteV(FormatStr,' Cursor : Line', YCur:3,
                                '   Column', XCur:3) ;
           2 : begin
                 InputInfo(FormatStr) ;
                 if TotalRec[DataNum] > 1 then
                    L_SlidePos := (L_I * 1000 * (RecNo[DataNum] - 1)) DIV 
                                  (TotalRec[DataNum] - 1) ;
               end ;
           3 : if SearchFlag then
                  begin
                    SearchInfo(C_CurRec^.Match, MatchStr) ;
                    WriteV(FormatStr,
                       '| F1 =  | F2 >  | F3 <  | F4 <> | F5 <= | F6 >= |',
                       'Search Criteria :':18, MatchStr:3) ;
                  end
               else
                  begin
                    InputInfo(SearchStr) ;
                    WriteV(FormatStr, SearchStr, 'Search Rec #':13,
                                      F_RecNo[DataNum]:5, ' of ',
                                      F_TotalRec[DataNum]:5) ;
                    if F_TotalRec[DataNum] > 1 then
                       L_SlidePos := (L_I * 1000 * (F_RecNo[DataNum] - 1)) 
                                      DIV (F_TotalRec[DataNum] - 1) ;
                  end ;
           4 : if SortFlag then
                  WriteV(FormatStr,' Sort Mode : Shift-UpArrow | Shift-DownArrow')
               else
                  WriteV(FormatStr,' Sorting -- Please Wait .......') ;
           5 : begin
                 WriteV(FormatStr, ' Report Design : Line', (YCur - 7):5,
                                   '   Column ', XCur:5) ;
                 if TotScrRec > 10 then
                    L_SlidePos := (L_I * 1000 * PL_Offset) 
                                    DIV (TotScrRec - 10) ;
               end ;
       end ;
       WindInfo[WindNum] := FormatStr ;
       Set_WInfo(WindNum, WindInfo[WindNum]) ;

       Wind_Set(WindNum, WF_VSlide, L_SlidePos, 0, 0, 0) ;
     end ;

{ *************************************************************************
     Delete Record deletes the current data record and redraws the new
     current record.
************************************************************************* }
  procedure DeleteRecord ;

     begin 
       EditFlag[ScrNum] := true ;
       Hide_Mouse ;
       DS_DeleteARec(D_CurrentRec[DataNum]) ;
       ClrHome ;
       DrawRecord(D_CurrentRec[DataNum]) ;
       UpdateFlag := true ; ;
       Show_Mouse ;
     end ;

{ *************************************************************************
       Delete a Screen Info field from the current design screen.
************************************************************************* }
     procedure DeleteScrRec ;

       var
          CurLoc : short_integer ;
          CurRec : ScrPtr ;
          TotalOffset : short_integer ;

        begin
          if S_CurrentRec[ScrNum] <> nil then
             begin
               CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
               if CurLoc > -1 then
                  begin
                    Hide_Mouse ;
                    D_EditFlag[ScrNum] := true ;
                    DeleteARec(CurRec) ;
                  { Recalculate Offsets  }
                    CurRec := S_FirstRec[ScrNum] ;
                    TotalOffset := 0 ;
                    While CurRec <> nil do
                      begin
                        CurRec^.Offset := TotalOffset ;
                        TotalOffset := TotalOffset + CurRec^.Size ;
                        CurRec := CurRec^.Next ;
                      end ;
                   DrawScreen(S_FirstRec[ScrNum]) ;
                   Show_Mouse ;
                 end ;
             end ;
        end ;

{ *************************************************************************
       CharInInput either inserts the character or modifies the string,
       depending upon the cursor location, then displays the modified
       string.
************************************************************************* }
     procedure CharInInput(LoByte : short_integer) ;

       var
           NewChar    : StrChar ;
           Location   : short_integer ;
           DisplayStr : Str255 ;

        begin
          EditFlag[ScrNum] := true ;
          if (S_CurrentRec[ScrNum]^.DataType = 'B') OR
             (S_CurrentRec[ScrNum]^.DataType = 'D') then
             begin
               if (LoByte = $54) OR (LoByte = $74) then
                  LoByte := $54
               else
                  if (LoByte = $46) OR (LoByte = $66) then
                     LoByte := $46
                  else
                     if (LoByte <> $02) AND (LoByte <> $03) then
                        LoByte := $01 ;
             end ;

          if LoByte <> $01 then
             begin
               Location := S_CurrentRec[ScrNum]^.XInPos +
                           S_CurrentRec[ScrNum]^.Offset ;
               DetCurRec(D_CurrentRec[DataNum]^.Data, D_DataRec, Location) ;
               GetChar(S_CurrentRec[ScrNum],D_CurrentRec[DataNum], NewChar, 
                   S_CurrentRec[ScrNum]^.XInPos + S_CurrentRec[ScrNum]^.Offset) ;
               Location := S_CurrentRec[ScrNum]^.XInPos +
                           S_CurrentRec[ScrNum]^.Offset ;
               if NewChar = chr(1) then
                  ModifyStr(D_CurrentRec[DataNum], Location, chr(LoByte))
               else
                  InsertChar(S_CurrentRec[ScrNum], D_CurrentRec[DataNum], 
                             chr(LoByte), S_CurrentRec[ScrNum]^.XInPos + 1) ;
               GetStr(D_CurrentRec[DataNum], DisplayStr, 
                      S_CurrentRec[DataNum]^.Offset, 
                      S_CurrentRec[DataNum]^.Size ) ;
                      
               Hide_Mouse ;
               Draw_String(x + S_CurrentRec[ScrNum]^.XPos * 8,
                           y + YCur * Spacing, DisplayStr) ;
               Show_Mouse ;

               if S_CurrentRec[ScrNum]^.XInPos + 1 < 
                  S_CurrentRec[ScrNum]^.Size then
                  begin
                    XCur := XCur + 1 ;
                    S_CurrentRec[ScrNum]^.XInPos := 
                      S_CurrentRec[ScrNum]^.XInPos + 1 ; 
                  end ;
             end ;
        end ;
{ *************************************************************************
     DrawGetStr will correctly position the output strings to the scrolling
     Report Design screen.  The string will be correctly modified for
     the field strings which are displayed as ASCII but stored as modified
     ASCII to differential during report formatting.
************************************************************************* }
  procedure DrawGetStr ;

    var
       i         : short_integer ;
       CheckChar : char ;

     begin
       Hide_Mouse ;
       if RW_Offset > 0 then
          GetStr(D_CurrentRec[Report], FormatStr,
                 S_CurrentRec[Report]^.Offset + 56, 76)
       else
          GetStr(D_CurrentRec[Report], FormatStr,
                 S_CurrentRec[Report]^.Offset, 80);

       for i := 1 to Length(Formatstr) do
           begin
             CheckChar := FormatStr[i] ;
             if ord(CheckChar) > $7F then
                FormatStr[i] := chr(ord(CheckChar) - $80 + $41) ;
           end ;

       if RW_Offset > 0 then
          Draw_String(x, y + YCur * Spacing - 4 * Resolution, FormatStr)
       else
          Draw_String(x + 8, y + YCur * Spacing - 4 * Resolution, FormatStr) ;
       Show_Mouse ;
     end ;

{ *************************************************************************
       CharRPInput either inserts the character or modifies the string,
       depending upon the cursor location, then displays the modified
       string.
************************************************************************* }
     procedure CharRPInput(LoByte : short_integer) ;

       var
           Location : short_integer ;
           NewChar  : StrChar ;

        begin
          R_EditFlag := true ;
          InsertChar(S_CurrentRec[Report], D_CurrentRec[Report], 
                     chr(LoByte), XCur) ;
          DrawGetStr ;
          XCur := XCur + 1 ;
          UpdateFlag := true ; ;
        end ;

{ *************************************************************************
       Creates a new DataStore Rec at the end of the current list and
       makes the new record the current record.  For adding new information
       to the database.
************************************************************************* }
     procedure Press_Tab ;
     
        begin
          if NOT FullMemory then
             begin
               EditFlag[ScrNum] := true ;
               FormatCheck(D_CurrentRec[DataNum]) ;
               ClearRecord(D_CurrentRec[DataNum]) ;
               CreateDataRec(DataNum) ;
               RecNo[DataNum] := TotalRec[DataNum] ;
             end
          else
             begin
               AlertStr := '[2][-Memory is Full- | |' ;
               AlertStr := Concat(AlertStr, 'You May Not Add | |') ;
               AlertStr := Concat(AlertStr, 'Any More Records]') ;
               AlertStr := Concat(AlertStr, '[ Continue ]') ;
               Result   := Do_Alert(AlertStr,1) ;
             end ;
          UpdateFlag := true ; ;
        end ;

{ ********************** Keyboard Input Routines ************************* }
{ *************************************************************************
     This procedure is called by the procedure Keyboard_Input module
     below. Event_Loop passes the variable KeyValue, the keyboard scan
     code, to Keyboard_Input.  KB_InReport seperates KeyValue
     into HiByte and LoByte components and then scans the values to 
     determine the outcome.  The old cursor position is cleared at the 
     beginning of the procedure and the new cursor position is drawn
     at the end of the procedure.  KB_InReport is really a cursor control
     procedure.
************************************************************************* }
  procedure KB_InReport( HiByte, LoByte, NewMode : short_integer ;
                        Var KeyIn : boolean ) ;

    var
       i,
       CurLoc,
       Location,
       TotalOffset,
       SaveCur     : short_integer ;
       CurRec      : ScrPtr ;
       ReDrawScr   : boolean ;

     begin
       ReDrawScr := false ;

       if LoByte = $00 then 
          Case HiByte of
              $3B : begin
                      PL_Offset := PL_Offset - 10 ;
                      if PL_Offset < 0 then PL_Offset := 0 ;
                      DrawDZ_In ;
                    end ;
              $3C : begin
                      PL_Offset := PL_Offset + 10 ;
                      if PL_Offset + 10 > TotScrRec then
                         PL_Offset := TotScrRec - 9 ;
                      if PL_Offset < 0 then PL_Offset := 0 ;
                      DrawDZ_In ;
                    end ;
                    
              $47 : begin                  { Clr Home }
                      XCur := 1 ;
                      YCur := 8 ;
                      RW_Offset := 0 ;
                      S_CurrentRec[Report] := S_FirstRec[Report] ;
                      DrawDZ_Out ;
                    end ;
              $48 : if YCur > 8 then
                       begin
                         KeyIn := true ;
                         YCur := YCur - 1 ;  { up }
                         S_CurrentRec[Report] := S_CurrentRec[Report]^.Prev ;
                       end ;
              $4B : begin
                      KeyIn := true ;
                      if XCur - RW_Offset > 1 then
                         XCur := XCur - 1    { left }
                      else
                         if XCur > 1 then
                            begin
                              XCur := XCur - 1 ;
                              RW_Offset := 0 ;
                              ReDrawScr := true ;
                            end ;
                    end ;
              $4D : begin
                      KeyIn := true ;
                      if (XCur - RW_Offset < 75) AND
                         (XCur < RepWidth) then
                          XCur := XCur + 1    { right }
                      else
                         if XCur < RepWidth - 1 then
                            begin
                              XCur := XCur + 1 ;
                              RW_Offset := 57 ;
                              ReDrawScr := true ;
                            end ;
                    end ;
              $50 : if ((YCur < h DIV Spacing) AND (P_Mode = 2)) OR 
                       ((YCur < 7 + LabLine) AND (P_Mode <> 2))  then
                       begin
                         KeyIn := true ;
                         YCur := YCur + 1 ;  { down }
                         S_CurrentRec[Report] := S_CurrentRec[Report]^.Next ;
                       end ;
          end 
       else
  
          if (HiByte = $01) AND (LoByte = $1B) then           { ESC }
             begin
               R_EditFlag := true ;
               for i := 0 to 131 do
                   begin
                     Location := S_CurrentRec[Report]^.Offset + i ;
                     ModifyStr(D_CurrentRec[Report], Location, chr($20)) ;
                   end ;
               DrawGetStr ;
             end 
          else

         if (HiByte = $0E) AND (LoByte = $08) then      { backspace }
            begin
              SaveCur := XCur ;
              if XCur - RW_Offset > 1 then
                 XCur := XCur - 1
              else
                 if XCur > 1 then
                    begin
                      XCur := XCur - 1 ;
                      RW_Offset := 0 ;
                      ReDrawScr := true ;
                    end ;
              if XCur < SaveCur then
                 begin
                   R_EditFlag := true ;
                   Location := XCur ;
                   DeleteChar(S_CurrentRec[Report], D_CurrentRec[Report], 
                              Location ) ;
                   DrawGetStr ;
                 end ;
            end 
          else

          if (HiByte = $53) AND (LoByte = $7F) then           { delete }
             begin
               R_EditFlag := true ;
               Location := XCur ;
               DeleteChar(S_CurrentRec[Report], D_CurrentRec[Report], Location ) ;
               DrawGetStr ;
             end
          else

          if ((HiByte = $1C) AND (LoByte = $0D) OR
              (HiByte = $72) AND (LoByte = $0D)) AND         { return }
              (((YCur < h DIV Spacing) AND (P_Mode = 2)) OR 
              ((YCur < 7 + LabLine) AND (P_Mode <> 2)))  then
              begin
                KeyIn := true ;
                YCur := YCur + 1 ;
                XCur := 1 ;
                if RW_Offset > 0 then
                   begin
                     RW_Offset := 0 ;
                     ReDrawScr := true ;
                   end ;
                S_CurrentRec[Report] := S_CurrentRec[Report]^.Next ;
              end ;

       if ReDrawScr then
          DrawDZ_Out ;
       UpdateFlag := true ; ;
     end;

{ *************************************************************************
     This procedure is called by the procedure Keyboard_Input module
     below. Event_Loop passes the variable KeyValue, the keyboard scan
     code, to Keyboard_Input.  KB_InDesign seperates KeyValue
     into HiByte and LoByte components and then scans the values to 
     determine the outcome.  The old cursor position is cleared at the 
     beginning of the procedure and the new cursor position is drawn
     at the end of the procedure.  KB_InDesign is really a cursor control
     procedure.
************************************************************************* }
  procedure KB_InDesign( HiByte, LoByte, NewMode : short_integer ;
                        Var KeyIn : boolean ) ;
    var
       Dummy,
       CurLoc,
       TotalOffset : short_integer ;
       CurRec      : ScrPtr ; 
       OverLap     : Boolean ;

{ *************************************************************************
     Modified pertinent variables for a cursor change ;
************************************************************************* }
     procedure ChangeCurPos(    CurRec : ScrPtr ; XFlag : Boolean ;
                            Var XY, Pos, InPos, Cur : short_integer ;
                                Value : short_integer) ;
     
        begin
          D_EditFlag[ScrNum] := true ;
          XY := XY + Value ;
          Pos := Pos + Value ;
          if XFlag then
             InPos := InPos + Value ;
          Cur := Cur + Value ;
          DrawAField(CurRec) ;
        end ;
{ *************************************************************************
       Move the current Screen Info field up one line -- if possible.
************************************************************************* }
     procedure ShiftUp ;

        begin
          CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
          if CurLoc > -1 then
             if (CurRec^.Y > 1) AND (CurRec^.DataType <> 'D') then
                begin
                  CheckOverLap(CurRec, CurRec^.X, CurRec^.Y - 1, OverLap) ;
                  if NOT OverLap then
                     begin
                       EraseARec(CurRec) ;
                       ChangeCurPos(CurRec, false, CurRec^.Y, CurRec^.YPos,
                                    CurRec^.XInPos, YCur, -1) ;
                       if CurRec^.DataType = 'H' then
                          ChangeCurPos(CurRec^.Next, false, CurRec^.Next^.Y, 
                                       CurRec^.Next^.YPos, 
                                       CurRec^.Next^.XInPos, Dummy, -1) ;
                     end ;
                end ;
        end ;
{ *************************************************************************
       Move the current Screen Info field one space left -- if possible.
************************************************************************* }
     procedure ShiftLeft ;
     
        begin
          CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
          if CurLoc > -1 then
             if (CurRec^.X > 1) AND (CurRec^.DataType <> 'D') then
                begin
                  CheckOverLap(CurRec, CurRec^.X - 1, CurRec^.Y, OverLap) ;
                  if NOT OverLap then
                     begin
                       EraseARec(CurRec) ;
                       ChangeCurPos(CurRec, true, CurRec^.X, CurRec^.XPos,
                                    CurRec^.XInPos, XCur, -1) ;
                       if CurRec^.DataType = 'H' then
                          ChangeCurPos(CurRec^.Next, false, CurRec^.Next^.X, 
                                       CurRec^.Next^.XPos, 
                                       CurRec^.Next^.XInPos, Dummy, -1) ;
                     end ;
                end ; 
        end ;
{ *************************************************************************
       Move the current Screen Info field one space right -- if possible.
************************************************************************* }
     procedure ShiftRight ;
     
        begin
          CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
          if CurLoc > -1 then
             if (CurRec^.X + Length(CurRec^.LabelStr) + CurRec^.Size < 
                 w DIV 8 - 5) AND (CurRec^.DataType <> 'D') then
                begin
                  CheckOverLap(CurRec, CurRec^.X + 1, CurRec^.Y, OverLap) ;
                  if NOT OverLap then
                     begin
                       EraseARec(CurRec) ;
                       ChangeCurPos(CurRec, true, CurRec^.X, CurRec^.XPos,
                                    CurRec^.XInPos, XCur, 1) ;
                       if CurRec^.DataType = 'H' then
                          ChangeCurPos(CurRec^.Next, false, CurRec^.Next^.X, 
                                       CurRec^.Next^.XPos, 
                                       CurRec^.Next^.XInPos, Dummy, 1) ;
                     end ;
                end ; 
        end ;
{ *************************************************************************
       Move the current Screen Info field down one line -- if possible.
************************************************************************* }
     procedure ShiftDown ;
     
        begin
          CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
          if CurLoc > -1 then
             if (CurRec^.Y < h DIV Spacing) AND
                (CurRec^.DataType <> 'D') then
                begin
                  CheckOverLap(CurRec, CurRec^.X, CurRec^.Y + 1, OverLap) ;
                  if NOT OverLap then
                     begin
                       EraseARec(CurRec) ;
                       ChangeCurPos(CurRec, false, CurRec^.Y, CurRec^.YPos,
                                    CurRec^.XInPos, YCur, 1) ;
                       if CurRec^.DataType = 'H' then
                          ChangeCurPos(CurRec^.Next, false, CurRec^.Next^.Y, 
                                       CurRec^.Next^.YPos, 
                                       CurRec^.Next^.XInPos, Dummy, 1) ;
                     end ;
                end ;
        end ;

     begin
       if LoByte = $00 then 
          Case HiByte of
              $47 : begin                  { Clr Home }
                      XCur := 1 ;
                      YCur := 1 ;
                    end ;
              $48 : if YCur > 1 then
                       YCur := YCur - 1 ;  { up }
              $4B : if XCur > 1 then
                       XCur := XCur - 1 ;  { left }
              $4D : if XCur < w DIV 8 - 2 then
                       XCur := XCur + 1 ;  { right }
              $50 : if YCur < h DIV Spacing  then
                       YCur := YCur + 1 ;  { down }
          end
       else
          Case HiByte of
{ ^E }       $12 : if LoByte = $05 then
                      Select_Enter ;
{ ^D }       $20 : if LoByte = $04 then
                      DeleteScrRec ;
{ ^M }       $32 : if LoByte = $0D then
                      Select_Modify ;
             $48 : if LoByte = $38 then  { Shift-Up }
                      ShiftUp ;
             $4B : if LoByte = $34 then  { Shift-Left }
                      ShiftLeft ;
             $4D : if LoByte = $36 then  { Shift-Right }
                      ShiftRight ;
             $50 : if LoByte = $32 then  { Shift-Down }
                      ShiftDown ;
          end ;
       UpdateFlag := true ; ;
     end;

{ ********************** Keyboard Input Routines ************************* }
{ *************************************************************************
     KB_InInput is called by the Keyboard_Input module below.  It handles
     keyboard input for the Input phase of the program.  KeyValue is 
     passed from Keyboard_Input and the code is separated into HiByte and
     LoByte components.  Cursor control and character input are handled
     by this module.
************************************************************************* }
  procedure KB_InInput( HiByte, LoByte, NewMode : short_integer ;
                       Var KeyIn : boolean ) ;
    var
       Location,
       CurLoc   : short_integer ;
       CurRec   : ScrPtr ; 
       OverLap  : Boolean ;
       DisplayStr : Str255 ;
       NewChar  : StrChar ;

{ *************************************************************************
       Select Date automatically inserts the current system date into
       a Date DataType field.
************************************************************************* }
     procedure SelectDate(ScrRec : ScrPtr ; DataRec : DataPtr ; 
                          DisplayStr : Str255 ) ;

       var
          i : short_integer ;

        begin
          if (ScrRec^.DataType = 'G') AND 
             ((Mode = 2) OR (Mode = 3)) then
             begin
               EditFlag[ScrNum] := true ;
               Hide_Mouse ;
               AutoDate(ScrRec, DataRec, DisplayStr) ;
               for i := 1 to ScrRec^.Size - Length(DisplayStr) do
                   DisplayStr := Concat(DisplayStr, chr($20)) ;
               Draw_String(x + ScrRec^.XPos * 8, 
                           y + ScrRec^.YPos * Spacing, DisplayStr) ;
               Show_Mouse ;
             end ;
        end ;

{ *************************************************************************
       Moves the Cursor to the next field, or to the first field if the
       current field is the last field.
************************************************************************* }
     procedure Press_Ret ;

        begin
          KeyIn := true ;
          if S_CurrentRec[ScrNum]^.Next <> nil then
             S_CurrentRec[ScrNum] := S_CurrentRec[ScrNum]^.Next
          else
             S_CurrentRec[ScrNum] := S_FirstRec[ScrNum] ;
             XCur := S_CurrentRec[ScrNum]^.XPos ;
             YCur := S_CurrentRec[ScrNum]^.YPos ;
             S_CurrentRec[ScrNum]^.XInPos := 0 ;
             UpdateFlag := true ; ;
        end ;

{ *************************************************************************
       Deletes the character at the current cursor location.
************************************************************************* }
     procedure Press_Del ;

        begin
          KeyIn := true ;
          EditFlag[ScrNum] := true ;
          Location := S_CurrentRec[ScrNum]^.XInPos + 1 ;
          DeleteChar(S_CurrentRec[ScrNum], D_CurrentRec[DataNum], Location ) ;
          GetStr(D_CurrentRec[DataNum], DisplayStr, 
                 S_CurrentRec[ScrNum]^.Offset, S_CurrentRec[ScrNum]^.Size ) ;
          DisplayStr := Concat(DisplayStr, chr($20)) ;
          Hide_Mouse ;
          Draw_String(x + S_CurrentRec[ScrNum]^.XPos * 8,
                      y + YCur * Spacing, DisplayStr) ;
          Show_Mouse ;
        end ;

{ *************************************************************************
       Deletes the character to the left of the current cursor location.
************************************************************************* }
     procedure Press_BS ;

        begin
          KeyIn := true ;
          EditFlag[ScrNum] := true ;
          S_CurrentRec[ScrNum]^.XInPos := S_CurrentRec[ScrNum]^.XInPos - 1 ;
          XCur := XCur - 1 ;
                           
          Location := S_CurrentRec[ScrNum]^.XInPos + 1 ;
          DeleteChar(S_CurrentRec[ScrNum], D_CurrentRec[DataNum], Location ) ;
          GetStr(D_CurrentRec[DataNum], DisplayStr,
                 S_CurrentRec[ScrNum]^.Offset, S_CurrentRec[ScrNum]^.Size) ;
          DisplayStr := Concat(DisplayStr, chr($20)) ;
          Hide_Mouse ;
          Draw_String(x + S_CurrentRec[ScrNum]^.XPos * 8,
                      y + YCur * Spacing, DisplayStr) ;
          Show_Mouse ;
        end ;

{ *************************************************************************
       Clears the current field of all previous information.
************************************************************************* }
     procedure Press_ESC ;

       var
           i      : short_integer ;
           ScrRec : ScrPtr ;
           Start  : short_integer ;

        begin
          KeyIn := true ;
          EditFlag[ScrNum] := true ;
          ScrRec := S_CurrentRec[ScrNum] ;

          if ScrRec^.DataType = 'F' then
             Start := 1
          else
             Start := 0 ;
          for i := Start to ScrRec^.Size - 1 do
              begin
                Location := ScrRec^.Offset + i ;
                ModifyStr(D_CurrentRec[DataNum], Location, chr(1)) ;
             end ;

          Paint_Frame(x + (ScrRec^.X + Length(ScrRec^.LabelStr) + 2) * 8 + 4, 
                      y + (ScrRec^.Y - 1) * Spacing + (4 * Resolution), 
                      ScrRec^.Size * 8 ) ;

          Hide_Mouse ;
          if ScrRec^.DataType = 'F' then
             Draw_String(x + ScrRec^.XPos * 8,
                         y + ScrRec^.YPos * Spacing, chr($24)) ;
          Show_Mouse ;

          XCur := ScrRec^.XPos ;
          ScrRec^.XInPos := 0 ;
        end ;

{ *************************************************************************
       Move the cursor to the previous Screen Info field.
************************************************************************* }
     procedure UpArrow(Var CurRec : ScrPtr) ;
 
        begin
          KeyIn := true ;
          if CurRec^.Prev <> nil then
             CurRec := CurRec^.Prev
          else
             CurRec := S_LastRec[ScrNum] ;

          if Mode = 3 then
             begin
               if C_CurRec^.Prev <> nil then
                  C_CurRec := C_CurRec^.Prev
               else
                  C_CurRec := C_LastRec ;
             end ;

          XCur := CurRec^.XPos ;
          YCur := CurRec^.YPos ;
          CurRec^.XInPos := 0 ;
          UpdateFlag := true ; ;
        end ;

{ *************************************************************************
       Move the cursor to the left one character.
************************************************************************* }
     procedure LeftArrow(Var CurRec : ScrPtr) ;
       
        begin
          KeyIn := true ;
          if CurRec^.XInPos - 1 >= 0 then
             begin
               CurRec^.XInPos := CurRec^.XInPos - 1 ;
               XCur := XCur - 1 ;
             end ;
        end ;

{ *************************************************************************
       Move the cursor to the rigth one character.
************************************************************************* }
     procedure RightArrow(Var CurRec : ScrPtr) ;
     
        begin
          KeyIn := true ;     { <= }
          if CurRec^.XInPos + 1 < CurRec^.Size then
             begin
               GetChar(CurRec,D_CurrentRec[DataNum], NewChar, 
                       CurRec^.XInPos + CurRec^.Offset) ;
               if NewChar <> chr(1) then
                  begin
                    CurRec^.XInPos := CurRec^.XInPos + 1 ;
                    XCur := XCur + 1 ;
                  end ;
             end ;
        end ;

{ *************************************************************************
       Move the cursor to the next Screen Pointer field.
************************************************************************* }
     procedure DownArrow(Var CurRec : ScrPtr) ;
     
        begin
          KeyIn := true ;
          if CurRec^.Next <> nil then
             CurRec := CurRec^.Next
          else
             CurRec := S_FirstRec[ScrNum] ;

          if Mode = 3 then
             begin
               if C_CurRec^.Next <> nil then
                  C_CurRec := C_CurRec^.Next
               else
                  C_CurRec := C_FirstRec ; 
             end ;

          XCur := CurRec^.XPos ;
          YCur := CurRec^.YPos ;
          CurRec^.XInPos := 0 ;
          UpdateFlag := true ; ;
        end ;

{ *************************************************************************
        Select Ascending Sort for the current field.
************************************************************************* }
      procedure ShiftUpArrow(ScrRec : ScrPtr ; DataRec : DataPtr) ;

        var
           CurRec     : ScrPtr ;
           DisplayStr : Str255 ;
           i          : short_integer ;
           NewChar    : StrChar ;
           CharInt    : short_integer ;

         begin
           GetStr(DataRec, DisplayStr, ScrRec^.Offset, ScrRec^.Size ) ;
           IF (ScrRec^.DataType='F') AND (LENGTH(DisplayStr)=1) THEN
                Press_BS ;
{ * }      if (Length(DisplayStr) < 1) 
                OR 
              ((LENGTH(DisplayStr)=1) AND (ScrRec^.DataType='F')) then
              begin
                LoByte := 3 ;
                CharInInput(LoByte) ;
                
                CurRec := S_FirstRec[ScrNum] ;
                i := 1 ;
                While CurRec <> nil do
                   begin
                     if CurRec = ScrRec then
                        CurRec := nil
                     else
                        begin
                          CurRec := CurRec^.Next ;
                          i := i + 1 ;
                        end ;
                   end ;
                   
                Int_AddARec(F_FirstRec,F_CurRec,F_LastRec, i) ;
                WriteV(DisplayStr, SortCount) ;
                for i := 1 to Length(DisplayStr) do
                    begin
                      NewChar := Copy(DisplayStr,1,1) ;
                      GetAscii(NewChar, CharInt) ;
                      LoByte := CharInt ;
                      CharInInput(LoByte) ;
                      Delete(DisplayStr,1,1) ;
                    end ;
                SortCount := SortCount + 1 ;
              end ;
         end ;

{ *************************************************************************
        Select descending sort for the current field.
************************************************************************* }
      procedure ShiftDownArrow(ScrRec : ScrPtr ; DataRec : DataPtr) ;

        var
           CurRec     : ScrPtr ;
           DisplayStr : Str255 ;
           i          : short_integer ;
           NewChar    : StrChar ;
           CharInt    : short_integer ;

         begin
           GetStr(DataRec, DisplayStr, ScrRec^.Offset, ScrRec^.Size ) ;
           IF (ScrRec^.DataType='F') AND (LENGTH(DisplayStr)=1) THEN
                Press_BS ;
{ * }      if (Length(DisplayStr) < 1) 
                OR 
              ((LENGTH(DisplayStr)=1) AND (ScrRec^.DataType='F')) then
              begin
                LoByte := 2 ;
                CharInInput(LoByte) ;

                CurRec := S_FirstRec[ScrNum] ;
                i := 1 ;
                While CurRec <> nil do
                   begin
                     if CurRec = ScrRec then
                        CurRec := nil
                     else
                        begin
                          CurRec := CurRec^.Next ;
                          i := i + 1 ;
                        end ;
                   end ;

                Int_AddARec(F_FirstRec,F_CurRec,F_LastRec, i) ;
                WriteV(DisplayStr, SortCount) ;
                for i := 1 to Length(DisplayStr) do
                    begin
                      NewChar := Copy(DisplayStr,1,1) ;
                      GetAscii(NewChar, CharInt) ;
                      LoByte := CharInt ;
                      CharInInput(LoByte) ;
                      Delete(DisplayStr,1,1) ;
                    end ;
                SortCount := SortCount + 1 ;
              end ;
         end ;

       procedure PressUndo ;

         var
            CurRec : DataPtr ;
            
          begin
            if DelItem <> nil then
               begin
                 TotalRec[DataNum] := TotalRec[DataNum] + 1 ;
                 if DelItem^.Prev <> nil then
                    DelItem^.Prev^.Next := DelItem ;
                 if DelItem^.Next <> nil then
                    DelItem^.Next^.Prev := DelItem ;
                 if DelItem^.Prev = D_LastRec[DataNum] then
                    D_LastRec[DataNum] := DelItem ;
                 if DelItem^.Next = D_FirstRec[DataNum] then
                    D_FirstRec[DataNum] := DelItem ;
                 D_CurrentRec[ScrNum] := DelItem ;
                 DelItem := nil ;
                 DrawRecord(D_CurrentRec[DataNum]) ;
                 
                 RecNo[DataNum] := 1 ;
                 CurRec := D_FirstRec[DataNum] ;
                 While CurRec <> nil do
                    begin
                      if CurRec = D_CurrentRec[DataNum] then
                         CurRec := nil
                      else
                         begin
                           CurRec := CurRec^.Next ;
                           RecNo[DataNum] := RecNo[DataNum] + 1 ;
                         end ;
                    end ;

                 UpdateFlag := true ; ;
               end ;
          end ;

{ *************************************************************************
        Keyboard parser for input mode : MODE = 2.
************************************************************************* }
      procedure InMode ;

         begin
           if (HiByte = $4D) AND (LoByte = $36) then      { Shift-Right }
              IncrementRec(D_CurrentRec[DataNum], 1, true)
           else
              if (HiByte = $4B) AND (LoByte = $34) then   { Shift-Left  }
                 IncrementRec(D_CurrentRec[DataNum], -1, true)
              else
                     case HiByte of
                         $01 : if LoByte = $1B then           { ESC }
                                  Press_ESC ;
                         $0E : if (LoByte = $08) AND          { backspace }
                                  (S_CurrentRec[ScrNum]^.XInPos - 1 >= 0) then
                                  Press_BS ;
                         $0F : if LoByte = $09 then
                                  Press_Tab ;                 { TAB }
                         $1C : if LoByte = $0D then           { return }
                                  Press_Ret ;
                         $20 : if LoByte = $04 then           { ^D }
                                  DeleteRecord ;

                         $53 : if LoByte = $7F then           { delete }
                                  Press_Del ;
                         $72 : if LoByte = $0D then           { enter  }
                                  Press_Ret ;
                     end ;
         end ;

{ *************************************************************************
        Keyboard parser for search mode : MODE = 3.
************************************************************************* }
      procedure SearchMode ;
 
         begin
           if (HiByte = $4B) AND (LoByte = $34) then        { Shift-Left }
              IncrementRec(D_CurrentRec[DataNum], -1, true)
           else
              if (HiByte = $4D) AND (LoByte = $36) then    { Shift-Right }
                 IncrementRec(D_CurrentRec[DataNum], 1, true)
              else
                    case HiByte of
                       $01 : if LoByte = $1B then           { ESC }
                                Press_ESC ;
                       $0E : if (LoByte = $08) AND          { backspace }
                                (S_CurrentRec[ScrNum]^.XInPos - 1 >= 0) then
                                Press_BS ;
                       $1C : if LoByte = $0D then           { return }
                                Press_Ret ;
                       $20 : if LoByte = $04 then           { ^D }
                                DeleteRecord ;
                       $53 : if LoByte = $7F then           { delete }
                                Press_Del ;
                       $72 : if LoByte = $0D then           { enter  }
                                Press_Ret ;
                   end ;
         end ;

{ *************************************************************************
        Keyboard parser for input mode : MODE = 4.
************************************************************************* }
      procedure SortMode ;

         begin
           if (HiByte = $48) AND (LoByte = $38) then       { Shift-Up    }
              ShiftUpArrow(S_CurrentRec[ScrNum],D_CurrentRec[DataNum])
           else
              if (HiByte = $50) AND (LoByte = $32) then    { Shift-Down  }
                 ShiftDownArrow(S_CurrentRec[ScrNum],D_CurrentRec[DataNum])
              else
                 if (LoByte = $0D) AND 
                   ((HiByte = $1C) OR (HiByte = $72)) then
                     Press_Ret ;
         end ;

  begin
      if LoByte = $00 then 
         begin
           Case HiByte of
              $44 : SelectDate(S_CurrentRec[ScrNum], 
                               D_CurrentRec[ScrNum], DisplayStr) ;
              $47 : ClrHome ;
              $48 : UpArrow(S_CurrentRec[ScrNum]) ;
              $4B : LeftArrow(S_CurrentRec[ScrNum]) ;
              $4D : RightArrow(S_CurrentRec[ScrNum]) ;
              $50 : DownArrow(S_CurrentRec[ScrNum]) ;
              $61 : IF (Mode = 2) OR (Mode=3) THEN PressUndo ;
              $73 : GoToFirst(D_CurrentRec[DataNum],true) ;
              $74 : GoToLast(D_CurrentRec[DataNum], true) ;
             else : if Mode = 3 then
                       begin
                          Case HiByte of
                              $3B : C_CurRec^.Match := 1 ;
                              $3C : C_CurRec^.Match := 2 ;
                              $3D : C_CurRec^.Match := 3 ;
                              $3E : C_CurRec^.Match := 4 ;
                              $3F : C_CurRec^.Match := 5 ;
                              $40 : C_CurRec^.Match := 6 ;
                          end ;
                         if (HiByte > $3A) AND (HiByte < $41) then
                            UpdateFlag := true ; ;
                       end ;
           end ;
         end
      else
         Case Mode of
             2 : InMode ;
             3 : SearchMode ;
             4 : SortMode ;
         end ;
    end;

{ *************************************************************************
     Keyboard_Input is called by Event_Loop whenever a keyboard event
     is detected.  Depending on the current mode, one of the scanning
     modules is called to interpret the keyboard input.
************************************************************************* }
  procedure Keyboard_Input( KeyValue : short_integer);

    var
       NewMode,
       HiByte,
       LoByte : short_integer ;
       KeyParse,
       KeyIn  : boolean ;

     begin
       KeyIn   := false ;
       KeyParse := false ;
       NewMode := Mode ;
       HiByte  := ShR(KeyValue, 8);
       LoByte  := ShR(ShL(KeyValue, 8),8);

       if Mode = 5 then
          EraseCursor(Report)
       else
          EraseCursor(ScrNum) ;

       if LoByte = $00 then 
          Case HiByte of
              $17 : if ((Mode = 1) AND (S_FirstRec[ScrNum] <> nil)) OR
                        (Mode = 2) OR (Mode = 3) OR (Mode = 4) OR
                       ((Mode = 5) AND (D_FirstRec[DataNum] <> nil) AND 
                                       (F_FirstRec = nil)) then
                       SelectInput(NewMode) ;    { alt-I : Input }
              $18 : if ((Mode = 2) OR (Mode = 3) OR (Mode=5)) AND
                       (TotalRec[DataNum] > 1) then
                       SelectOutput(NewMode) ;   { alt-O : Output }
              $20 : if  (Mode = 2) OR 
                       ((Mode = 5) AND (D_FirstRec[DataNum] = nil) AND 
                                       (F_FirstRec = nil)) then
                       NewMode := 1 ;            { alt-D : Design }
              $21 : if ((Mode = 2) OR (Mode = 3) OR
                       ((Mode = 5) AND (F_FirstRec <> nil))) AND
                       (TotalRec[DataNum] > 1) then
                       SelectSearch(NewMode) ;   { alt-F : Search }
              $1F : if ((Mode = 2) OR (Mode = 4)) AND
                        (TotalRec[DataNum] > 1) then
                       SelectSort(NewMode) ;     { alt-S : Sort   }
              $62 : HelpScreen ;
             else : KeyParse := true ;
          end
       else
          if ((LoByte > $1F) AND (LoByte < $7F)) AND
             ((HiByte < $40) OR  (HiByte > $62) OR 
              (HiByte = $4A) OR  (HiByte = $4E)) then
             Case Mode of
              2,3 : if S_CurrentRec[ScrNum]^.XInPos < 
                       S_CurrentRec[ScrNum]^.Size then
                       begin
                         KeyIn := true ;
                         CharInInput(LoByte) ;
                       end ;
                5 : if ((XCur < 80) AND NOT PrtFlag[1]) OR
                       ((XCur < 132) AND PrtFlag[1]) then
                       begin 
                         CharRPInput(LoByte) ;
                         if (XCur > 75) AND (RW_Offset = 0) then
                            begin
                              RW_Offset := 57 ;
                              DrawDZ_Out ;
                           end ;
                       end ;
             end
          else
             KeyParse := true ;
       
       if KeyParse then
          Case HiByte of
{ ^Q }       $10 : if (LoByte = $11) AND (Mode <> 3) AND (Mode <> 4) then
                      ExitProgram
                   else
                      KeyParse := true ;
{ ^O }       $18 : if (LoByte = $0F) AND ((Mode = 1) OR (Mode = 2)) then
                      Select_Open(NewMode)
                   else
                      KeyParse := true ;
{ ^S }       $1F : if (LoByte = $13) AND
                      (((Mode = 1) AND (S_FirstRec[ScrNum] <> nil)) OR
                       ((Mode = 3) AND NOT (SearchFlag)) OR
                       ((Mode = 2)) AND (TotalRec[DataNum] > 1)) then
                        Select_Save
                   else
                      KeyParse := true ;
{ ^C }       $2E : if (LoByte = $03) AND
                      (((Mode = 1) AND (S_FirstRec[ScrNum] <> nil)) OR
                        (Mode = 2)) then
                      Select_Close
                   else
                      KeyParse := true ;
          end ;

       if KeyParse then
          Case Mode of
              1 : KB_InDesign( HiByte, LoByte, NewMode, KeyIn );
             2,3,
              4 : KB_InInput( HiByte, LoByte, NewMode, KeyIn );
              5 : KB_InReport( HiByte, LoByte, NewMode, KeyIn );
          end ;    

       if NOT KeyIn then
          begin
            if Mode <> NewMode then
               ChangeMode(Mode, NewMode) ;
            MenuOption ;
          end ;

       if WindNum > 0 then
          begin
            if Mode = 5 then
               NewCursor(Report)
            else
               NewCursor(ScrNum) ;
          end ;
     end ;

{ *************************************************************************
     MB_InDesign is called by MB_Input below whenever a mouse button event
     is detected while in the Design mode.  This procedure evaluates a 
     left button event to relocate the position of the cursor.  The old 
     cursor position is redrawn at the beginning of the procedure and 
     the new cursor position drawn at the end of the procedure.
************************************************************************* }
  procedure MB_InDesign( M_XPos, M_YPos : short_integer );

   var
      XTemp,
      YTemp : short_integer ;

    begin
      XTemp := (M_XPos - x) DIV 8 ;
      if (XTemp > 0) AND (XTemp < w DIV 8 - 1) then
         XCur := XTemp ;   { 7 }
      YTemp := (M_YPos - y + 9 * Resolution) DIV Spacing ;
      if (YTemp > 0) AND (YTemp < h DIV Spacing + 1) then
         YCur := YTemp ;
    end;

{ *************************************************************************
     MB_InReport is called by MB_Input below whenever a mouse button event
     is detected while in the Output mode.  This procedure evaluates a 
     left button event to relocate the position of the cursor.  The old 
     cursor position is redrawn at the beginning of the procedure and 
     the new cursor position drawn at the end of the procedure.
************************************************************************* }
  procedure MB_InReport( M_XPos, M_YPos : short_integer );

   var
      Location,
      i,
      CurLoc,
      Counter,
      XTemp,
      YTemp   : short_integer ;
      ScrRec  : ScrPtr ;
      NewChar : StrChar ;

      Start,
      Count   : short_integer ;

    begin
      if M_YPos > y + h DIV 2 - 23 * Resolution then
         begin
           XTemp := (M_XPos - x) DIV 8 ;
           if XTemp < 1 then XTemp := 1
           else
              if XTemp > 76 then XTemp := 76 ;
           XCur := XTemp + RW_Offset ;

           YTemp := (M_YPos - y + 12 * Resolution) DIV Spacing ;
           if YTemp < 8 then YTemp := 8
           else
              if YTemp > 17 then YTemp := 17 ;
           YCur := YTemp ;
           if XCur > RepWidth then XCur := RepWidth ;

           CheckCurLoc(CurLoc, ScrRec, XCur, YCur, Report ) ;
           S_CurrentRec[Report] := ScrRec ;
         end
      else
        if M_YPos > 29 * Resolution then
        begin
          Case RepLine of
             1 : begin
                   Start := 5 ;
                   Count := 2 ;
                 end ;
             2 : begin
                   Start := 5 ;
                   Count := 3 ;
                 end ;
             3 : begin
                   Start := 5 ;
                   Count := 4 ;
                 end ;
             4 : begin
                   Start := 4 ;
                   Count := 5 ;
                 end ;
          end ;

        if ((P_Mode = 2) AND
            (YCur > 7 + Start) AND (YCur < 7 + Start + Count)) OR
            (P_Mode = 1) OR (P_Mode = 0) then
         begin
           R_EditFlag := true ;
           if (M_XPos > 71) AND (M_XPos < 275) then XTemp := 0
           else
              if (M_XPos > 350) AND (M_XPos < 556) then XTemp := 1
                 else XTemp := 2 ;
           if XTemp < 2 then
              begin
                YTemp := (M_YPos - y - 2 * Resolution) DIV 
                         (12 * Resolution) ;
                if YTemp < 0 then YTemp := 0 ;
                if YTemp > 4 then YTemp := 4 ;
                Counter := YTemp + PL_Offset + (XTemp * 5) ;
                ScrRec := S_FirstRec[ScrNum] ;
                for i := 1 to Counter do
                    begin
                      ScrRec := ScrRec^.Next ;
                      if ScrRec = nil then i := Counter + 1 ;
                    end ;
    
                if ScrRec <> nil then
                   begin
                     if XCur + ScrRec^.Size < RepWidth + 2 then
                        begin
                          FormatStr := '' ;
                          for i := XCur - 1 to XCur + ScrRec^.Size - 2 do
                              begin
                                Location := S_CurrentRec[Report]^.Offset + i ;
                                ModifyStr(D_CurrentRec[Report], Location, 
                                          chr(Counter + $80)) ;
                                FormatStr := Concat(FormatStr, chr(Counter + $41) ) ;
                              end ;
                          Draw_String(x + (XCur - RW_Offset) * 8,
                                      y + YCur * Spacing - 4 * Resolution, 
                                      FormatStr) ;
                        end
                     else
                        begin
                          AlertStr := '[2][Insufficient Room for | |' ;
                          AlertStr := Concat(AlertStr, '   Selected Field | ]') ;
                          AlertStr := Concat(AlertStr, '[ Continue ]') ;
                          Result   := Do_Alert(AlertStr,1) ;
                        end ;
                   end ;
              end ;
         end ;
        end ;
    end;

{ *************************************************************************
     MB_InInput is called by MB_Input whenever a mouse event is detected
     while the program is in the Input mode.  The mouse position is
     checked to see if it is in a legitimate input box and relocates the
     cursor if the position is valid.  The old cursor is erased and the
     new cursor draw.
************************************************************************* }
  procedure MB_InInput( M_XPos, M_YPos : short_integer );

   Var
      XTemp,
      YTemp   : short_integer ;
      CurLoc  : short_integer ;
      CurRec  : ScrPtr ;
      NewChar : StrChar ;

    begin
      XTemp := (M_XPos - x) DIV 8 ;
      YTemp := (M_YPos - y + 8 * Resolution) DIV Spacing ;
{
      if (M_YPos > 18 * Resolution) AND (M_YPos < 28 * Resolution) AND
         (M_XPos > 4) AND (M_XPos < 388) AND SearchFlag then
         C_CurRec^.Match := (M_XPos + 60) DIV 64 ;
}
      CheckCurLoc(CurLoc, CurRec, XTemp, YTemp, ScrNum ) ;
      if CurLoc > -1 then
         GetChar(CurRec, D_CurrentRec[DataNum], NewChar, CurRec^.Offset) 
      else
         NewChar := chr(2) ;

      if NewChar = chr(1) then
         begin
           XCur := CurRec^.XPos ;
           YCur := YTemp ;
           S_CurrentRec[ScrNum]^.XInPos := 0 ;
           S_CurrentRec[ScrNum] := CurRec ;
           S_CurrentRec[ScrNum]^.XInPos := 0 ;
         end
      else
         Repeat
           CheckCurLoc(CurLoc, CurRec, XTemp, YTemp, ScrNum ) ;
           if CurLoc > -1 then
              begin
                if (CurRec^.X + CurLoc >= CurRec^.XPos) AND 
                   (CurRec^.X + CurLoc <  CurRec^.XPos + CurRec^.Size) then
                   begin
                     GetChar(CurRec, D_CurrentRec[DataNum], NewChar, 
                             CurRec^.Offset + CurLoc - CurRec^.XPos + CurRec^.X) ;
                     if NewChar <> chr(1) then
                        begin
                          S_CurrentRec[ScrNum] := CurRec ;
                          CurRec^.XInPos := CurLoc + CurRec^.X - CurRec^.XPos ; 
                          XCur := XTemp ;
                          YCur := YTemp ;
                          CurLoc := -1 ;
                        end
                     else
                        XTemp := XTemp - 1 ;
                   end
                else
                   if CurLoc < CurRec^.XPos - CurRec^.X then
                      XTemp := XTemp + 1
                   else
                      XTemp := XTemp - 1 ;
              end 
           else
              CurLoc := -1;

         Until CurLoc < 0 ;
    end;

{ *************************************************************************
     MB_Input is called by Event_Loop in the Main program module.  This
     procedure decides which of the decision procedures to call depending
     upon the current program mode.
************************************************************************* }
  procedure MB_Input( M_XPos, M_YPos : short_integer );

     begin
       Hide_Mouse ;
       if Mode = 5 then
          EraseCursor(Report)
       else
          EraseCursor(ScrNum) ;

       Case Mode of
            1 : MB_InDesign( M_XPos, M_YPos );
          2,3,
          4,6 : MB_InInput( M_XPos, M_YPos );
            5 : MB_InReport( M_XPos, M_YPos );
       end ;    

       if WindNum > 0 then
          begin
            if Mode = 5 then
               NewCursor(Report)
            else
               NewCursor(ScrNum) ;
          end ;

      MenuOption ;
      UpdateFlag := true ; ;
      Show_Mouse ;
     end ;

BEGIN
END .


