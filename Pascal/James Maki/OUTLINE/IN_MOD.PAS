{$M+}
{$E+}

program Input_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

   procedure SearchRec( Flag : boolean) ;
      External ;
      
   procedure InsertARec(Var CurRec : WordPointer ; NewStr : Str255 ) ;
      External ;

   procedure DeleteARec(Var CurRec : WordPointer) ;
      External ;

   procedure AddARec(Var CurRec : WordPointer ; NewWord : Str255 ) ;
      External ;

   procedure EraseCursor(X, Y, WindNo : short_integer ; CurRec : WordPointer) ;
      External ;

   procedure NewCursor(X, Y, WindNo : short_integer ; CurRec : WordPointer) ;
      External ;

  procedure Wind_VArrow(Var CurRec : WordPointer ; Display : short_integer ; 
                        Var Offset : short_integer ;
                            Max, WindNo : short_integer);
      External ;

   procedure Draw_Window(CurRec : WordPointer ; 
                           WindMsg, LineNo : short_integer ) ;
      External ;

  procedure SetPtLabel( WindNo : short_integer );
     External ;

  procedure UpdateLine(CurRec : WordPointer ; 
                       WindMsg, LineNo : short_integer ) ;
      External ;

  procedure UpdatePtLabel( CurRec : WordPointer ;
                            WindMsg, LineNo : short_integer ) ;
      External ;

  procedure Do_OpenWind ;
      External ;

  procedure Do_SaveFile(Var Flag : boolean) ;
      External ;

  procedure Do_CloseWind(Var Flag : boolean ; WindNo : short_integer) ;
      External ;

  procedure Set_MenuBar ;
      External ;

  procedure HideBlk ;
     External ;

  procedure MarkBlk ;
     External ;
  
  procedure CutBlk ;
     External ;
  
  procedure PasteBlk ;
     External ;
  
  procedure DeleteBlk ;
     External ;

  procedure PrintOutline ;
     External ;
     
  procedure DiskPrint ;
     External ;

  procedure Do_Exit ;
     External ;


  procedure DoMaxLine ;

    var
        AlertStr : Str255 ;
        Result   : short_integer ;

     begin
       AlertStr := '[3][ Maximum Number of |   Records Stored  ]' ;
       AlertStr := Concat(AlertStr,'[ Continue ]') ;
       Result := Do_Alert(AlertStr, 1) ;
     end ;

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
            WindOffset[Module] := WindOffset[Module] + NumColumns DIV 2 ;
            HorizScroll(DrawFlag) ;
            DrawFlag := true ;
          end
       else
          if XPos[Module] + LevelOffset < WindOffset[Module] - 1 then
             begin
               WindOffset[Module] := WindOffset[Module] - NumColumns DIV 2 ;
               if WindOffset[Module] < 0 then WindOffset[Module] := 0 ;
               HorizScroll(DrawFlag) ;
               DrawFlag := true ;
             end ;
     end ;

   procedure CheckBoundary ;

    var
        i,
        Counter  : short_integer ;
        DrawFlag : boolean ;

     begin
       if Current[Module] <> nil then

          if XPos[Module] < 1 then
             begin
               if Current[Module]^.Prev <> nil then
                  begin
                    Current[Module] := Current[Module]^.Prev ;
                    YPos[Module] := YPos[Module] - 1 ;
                    XPos[Module] := Length(Current[Module]^.NewWord) + 1 ;
                  end
               else
                  XPos[Module] := 1 ;
             end
          else
             if Current[Module] <> nil then
                if XPos[Module] > Length(Current[Module]^.NewWord) + 1 then 
                   begin
                     if Current[Module]^.Next <> nil then
                        begin
                          XPos[Module] := 1 ;
                          YPos[Module] := YPos[Module] + 1 ;
                          Current[Module] := Current[Module]^.Next ;
                        end
                     else
                        XPos[Module] := Length(Current[Module]^.NewWord) + 1 ;
                   end ;

       if (NumLines DIV 2) = (NumLines / 2) then
           Counter := NumLines DIV 2
       else
          Counter := NumLines DIV 2 + 1 ;

       DrawFlag := false ;
       HorizScroll(DrawFlag) ;
       if DrawFlag then 
          begin
            SetPtLabel( Module );
            Draw_Window(ScrFirstRec[Module], Module, 1) ;
          end ;

       if YPos[Module] < 1 then         { DECLINE Window Procedure }
          begin
            if ScrFirstRec[Module] <> nil then
               begin
                 for i := 1 to Counter do
                     if ScrFirstRec[Module]^.Prev <> nil then
                        begin
                          ScrFirstRec[Module] := ScrFirstRec[Module]^.Prev ;
                          YPos[Module] := YPos[Module] + 1 ;
                          VertOffset[Module] := VertOffset[Module] - 1 ;
                        end ;
               end
            else
               begin
                 ScrFirstRec[Module] := Current[Module] ;
                 YPos[Module] := 1 ;
                 VertOffset[Module] := VertOffset[Module] - 1 ;
               end ;
            SetPtLabel( Module );
            Draw_Window(ScrFirstRec[Module], Module, 1) ;
          end
       else
          if YPos[Module] > NumLines then     { ADVAN Window Procedure }
             begin
               for i := 1 to Counter do
                   begin
                     ScrFirstRec[Module] := ScrFirstRec[Module]^.Next ;
                     VertOffset[Module]  := VertOffset[Module] + 1 ;
                   end ;
               YPos[Module] := NumLines DIV 2 + 1 ;
               SetPtLabel( Module );
               Draw_Window(ScrFirstRec[Module], Module, 1) ;
             end ;
     end ;

 procedure RecallWindow(WindNo : short_integer ; Var CommFlag : boolean) ;

    begin
      if WindHandle[WindNo] > 0 then
         Bring_To_Front(WindNo) ;
      CommFlag := true ;
    end ;

 procedure KB_Input( HiByte, LoByte : short_integer);

  var
     i         : short_integer ;
     FormatStr : Str255 ;
     BlockEdit,
     DrawFlag,
     CommFlag  : boolean ;
     SaveRec   : boolean ;
     SaveFlag  : boolean ;
     CurRec    : WordPointer ;

   procedure IndentLine(Var CurRec : WordPointer) ;

      begin
        if CurRec <> nil then
           if CurRec^.Level < 5 then
              begin
                CurRec^.Buffer := false ;
                CurRec^.Level := CurRec^.Level + 1 ;
                XOffset[Module] := x + 10 - (WindOffset[Module] - 
                                  (CurRec^.Level * 3 + 16)) * 8 ;
                SetPtLabel( Module );
                UpdateLine(CurRec, Module, YPos[Module]) ; 
                UpdatePtLabel(CurRec, Module, YPos[Module] ) ;
                EditFlag[Module] := true ;
                BlockEdit := true ;
              end ;
      end ;                      

   procedure UnIndentLine(Var CurRec : WordPointer) ;

      begin
        if CurRec <> nil then
           if CurRec^.Level > 0 then
              begin
                CurRec^.Buffer := false ;
                CurRec^.Level := CurRec^.Level - 1 ;
                XOffset[Module] := x + 10 - (WindOffset[Module] - 
                                  (CurRec^.Level * 3 + 16)) * 8 ;
                SetPtLabel( Module );
                UpdateLine(CurRec, Module, YPos[Module]) ; 
                UpdatePtLabel(CurRec, Module, YPos[Module] ) ;
                BlockEdit := true ;
                EditFlag[Module] := true ;
              end ;
      end ;                      

   procedure PrintChar( IntChar : short_integer ) ;

     var
         Len : short_integer ;

      begin
        if Current[Module] <> nil then
           begin
             Current[Module]^.Buffer := false ;
             Len := Length(Current[Module]^.NewWord) ;
           end
        else
           Len := 0 ;
        if XPos[Module] <= Len then
           begin
             Insert(Chr(IntChar), Current[Module]^.NewWord, XPos[Module]) ;
             XPos[Module] := XPos[Module] + 1 ;
             Hide_Mouse ;
             Draw_String(XOffset[Module] + 8, 
                         YOffset[Module] + YPos[Module] * 9 * Resolution, 
                         Current[Module]^.NewWord) ;
             Show_Mouse ;
           end
        else
           begin
             if FirstRec[Module] = nil then
                begin
                  if TotRec < MaxRec then
                     begin
                       AddARec(FirstRec[Module], Chr(IntChar) ) ;
                       XPos[Module] := XPos[Module] + 1 ;
                       UpdateLine(FirstRec[Module], Module, YPos[Module] ) ;
                     end
                  else
                     DoMaxLine ;
                end
             else
                begin
                  Current[Module]^.NewWord :=
                          Concat(Current[Module]^.NewWord, Chr(IntChar)) ;
                  Hide_Mouse ;
                  Draw_String(XOffset[Module] + XPos[Module] * 8, 
                            YOffset[Module] + YPos[Module] * 9 * Resolution, 
                            Chr(IntChar) ) ;
                  XPos[Module] := XPos[Module] + 1 ;
                  Show_Mouse ;
                end ;
           end ;
        EditFlag[Module] := true ;
        BlockEdit := true ;
      end ;

   procedure BackSpace ;
   
     begin
       if Current[Module] <> nil then
          begin
            if (XPos[Module] > 1) AND 
               (XPos[Module] < Length(Current[Module]^.NewWord) + 2) then
               begin
                 Current[Module]^.Buffer := false ;
                 Delete(Current[Module]^.NewWord, XPos[Module] - 1, 1) ;
                 WriteV(FormatStr,Current[Module]^.NewWord, ' ') ;
                 Hide_Mouse ;
                 Draw_String(XOffset[Module] + 8, 
                             YOffset[Module] + YPos[Module] * 9 * Resolution, 
                             FormatStr) ;
                 Show_Mouse ;
                 XPos[Module] := XPos[Module] - 1 ;
                 EditFlag[Module] := true ;
                 BlockEdit := true ;
               end ;
          end ;
     end ;

   procedure DeleteLine ;

     begin
       if Current[Module] <> nil then
          begin
            XPos[Module] := 1 ;
            Current[Module]^.Buffer := false ;
            DeleteARec(Current[Module]) ;
            SetPtLabel( Module );
            Draw_Window(Current[Module], Module, YPos[Module]) ;
            EditFlag[Module] := true ;
            BlockEdit := true ;
          end ;
     end ;

   procedure DeleteKey ;

     begin
       if Current[Module] <> nil then
          begin
            if (XPos[Module] > 0) AND 
               (XPos[Module] < Length(Current[Module]^.NewWord) + 1) then
               begin
                 Current[Module]^.Buffer := false ;
                 Delete(Current[Module]^.NewWord, XPos[Module], 1) ;
                 WriteV(FormatStr,Current[Module]^.NewWord, ' ') ;
                 Hide_Mouse ;
                 Draw_String(XOffset[Module] + 8, 
                             YOffset[Module] + YPos[Module] * 9 * Resolution, 
                             FormatStr) ;
                 Show_Mouse ;
                 EditFlag[Module] := true ;
                 BlockEdit := true ;
               end ;
          end ;
     end ;

   procedure UpArrow ;

    var
        XDif : short_integer ;

     begin
       if Current[Module] <> nil then
          if Current[Module]^.Prev <> nil then
             begin
               XDif := Current[Module]^.Level - Current[Module]^.Prev^.Level ;
               if XDif < 0 then
                  XPos[Module] := XPos[Module] + XDif * 3
               else
                  if XDif > 0 then
                     XPos[Module] := XPos[Module] + XDif * 3 ;

               YPos[Module] := YPos[Module] - 1 ;
               Current[Module] := Current[Module]^.Prev ;

               if XPos[Module] > Length(Current[Module]^.NewWord) then
                  XPos[Module] := Length(Current[Module]^.NewWord) + 1
               else
                  if XPos[Module] < 1 then XPos[Module] := 1 ;
              end ;
     end ;

   procedure DownArrow ;

    var
        XDif : short_integer ;

     begin
       if Current[Module] <> nil then
          if Current[Module]^.Next <> nil then
             begin
               XDif := Current[Module]^.Level - Current[Module]^.Next^.Level ;
               if XDif < 0 then
                  XPos[Module] := XPos[Module] + XDif * 3
               else
                  if XDif > 0 then
                     XPos[Module] := XPos[Module] + XDif * 3 ;

               YPos[Module] := YPos[Module] + 1 ;
               Current[Module] := Current[Module]^.Next ;

               if XPos[Module] > Length(Current[Module]^.NewWord) then
                  XPos[Module] := Length(Current[Module]^.NewWord) + 1
               else
                  if XPos[Module] < 1 then XPos[Module] := 1 ;
          end ;
     end ;

   procedure UndoKey ;

     begin
       InsertARec(Current[Module], DelRec^.NewWord ) ;
       SetPtLabel( Module );
       Draw_Window(Current[Module], Module, YPos[Module]) ;
       CurRec := DelRec ;
       DelRec := DelRec^.Next ;
       if DelRec <> nil then
          DelRec^.Prev := nil ;
       Dispose(CurRec) ;
       TotRec := TotRec - 1 ;
     end ;

   procedure InsertLine ;

     begin
       if TotRec < MaxRec then
          begin
            if Current[Module] <> nil then
               Current[Module]^.Buffer := false ;
            InsertARec(Current[Module], NoSp) ;
            SetPtLabel( Module );
            Draw_Window(Current[Module], Module, YPos[Module]) ;
            EditFlag[Module] := true ;
            BlockEdit := true ;
          end
       else
          DoMaxLine ;
     end ;

   procedure ReturnKey ;

     begin
       if (Current[Module] <> nil) AND (TotRec < MaxRec) then
          begin
            Current[Module]^.Buffer := false ;
            if Current[Module]^.Next = nil then
               begin
                 YPos[Module] := YPos[Module] + 1 ;
                 XPos[Module] := 1 ;
                 AddARec(FirstRec[Module], NoSp) ;
                 UpdateLine(Current[Module], Module, YPos[Module] ) ;
               end
            else
               begin
                 YPos[Module] := YPos[Module] + 1 ;
                 Current[Module] := Current[Module]^.Next ;
                 InsertARec(Current[Module], NoSp) ;
                 SetPtLabel( Module );
                 Draw_Window(Current[Module], Module, YPos[Module]) ;
                 XPos[Module] := Length(Current[Module]^.NewWord) + 1 ;
               end ;
            BlockEdit := true ;
          end
       else
          begin
            if TotRec >= MaxRec then
               DoMaxLine ;
          end ;
       EditFlag[Module] := true ;
     end ;

   procedure ClearDelBuf ;
   
     var
         CurRec,
         SaveRec : WordPointer ;
   
      begin
        CurRec := DelRec ;
        While CurRec <> nil do
          begin
            SaveRec := CurRec ;
            Dispose(CurRec) ;
            TotRec := TotRec - 1 ;
            CurRec := SaveRec^.Next ;
          end ;
        DelRec := nil ;
      end ;

   procedure ClearLine ;

    var
        FormatStr : Str255 ;

     begin
       Hide_Mouse ;
       Current[Module]^.Buffer := false ;
       WriteV(FormatStr, ' ':Length(Current[Module]^.NewWord)) ;
       Draw_String(XOffset[Module] + 8, 
                   YOffset[Module] + YPos[Module] * 9 * Resolution,
                   FormatStr) ;
       XPos[Module] := 1 ;
       Current[Module]^.NewWord := '' ;
       EditFlag[Module] := true ;
       BlockEdit := true ;
       Show_Mouse ;
     end ;

  begin
    CommFlag  := false ;
    BlockEdit := false ;
    if Module > 0 then
       begin
         if Current[Module] <> nil then
            SaveRec := Current[Module]^.Buffer
         else
            SaveRec := false ;
       end ;
    Case HiByte of                   { Keyboard input of Menu Items }
        $10 : if LoByte = $11 then     { ^Q }
                 begin
                   Do_Exit ;
                   CommFlag := true ;
                 end ;
        $18 : if LoByte = $0F then
                 begin
                   Do_OpenWind ;
                   CommFlag := true ;
                 end ;
        $19 : if LoByte = $00 then
                 begin
                   PasteBlk ;
                   CommFlag := true ;
                 end
              else
                 if LoByte = $10 then
                    begin
                      PrintOutline ;
                      CommFlag := true ;
                    end ;
        $1F : if LoByte = $13 then
                 begin
                   Do_SaveFile(SaveFlag) ;
                   CommFlag := true ;
                 end ;
        $20 : if LoByte = $00 then
                 begin
                   DeleteBlk ;
                   CommFlag := true ;
                 end
              else
                 if LoByte = $04 then
                    begin
                      DiskPrint ;
                      CommFlag := true ;
                    end ;
        $23 : if LoByte = $00 then
                 begin
                   HideBlk ;
                   CommFlag := true ;
                 end ;
        $2E : if LoByte = $00 then
                 begin
                   CutBlk ;
                   CommFlag := true ;
                 end
              else
                 if LoByte = $03 then
                    begin
                      Do_CloseWind(CommFlag, Front_Window) ;
                      CommFlag := true ;
                    end ;
        $32 : if LoByte = $00 then
                 begin
                   MarkBlk ;
                   CommFlag := true ;
                 end ;
    $3B,$3C,  { F1 - F4 }
    $3D,$3E : if LoByte = $00 then
                 RecallWindow(HiByte - $3A, CommFlag) ;
              { F9 }
        $43 : if LoByte = $00 then
                 begin
                   SearchRec( False ) ;
                   CommFlag := true ;
                 end ;
              { F10 }
        $44 : if LoByte = $00 then
                 begin
                   SearchRec( true ) ;
                   CommFlag := true ;
                 end ;
              { Shift-UpArrow }
        $48 : if LoByte = $38 then
                 if N_Window > 0 then
                    begin
                      if ScrFirstRec[Module] = FirstRec[Module] then
                         begin
                           EraseCursor(XPos[Module], YPos[Module], 
                                       Module, Current[Module]) ;
                           Current[Module] := ScrFirstRec[Module] ;
                           YPos[Module] := 1 ;
                           XPos[Module] := 1 ;
                           NewCursor(XPos[Module], YPos[Module],
                                     Module, Current[Module]) ;
                         end
                      else
                         begin
                           Gem_Result.msg[4] := 0 ;
                           Wind_VArrow(Current[Module], 
                                       h DIV (9 * Resolution),
                                       VertOffset[Module],TotalRec[Module], 
                                       Module);
                         end ;
                      CommFlag := true ;
                    end ;
              { Shift-DownArrow }
        $50 : if LoByte = $32 then
                 if N_Window > 0 then 
                    if TotalRec[Module] > VertOffset[Module] + NumLines then
                       begin
                         Gem_Result.msg[4] := 1 ;
                         Wind_VArrow(Current[Module], h DIV (9 * Resolution),
                                     VertOffset[Module], TotalRec[Module], 
                                     Module);
                         CommFlag := true ;
                       end ;
     end ;

    if (N_Window > 0) AND NOT CommFlag then
       begin
         EraseCursor(XPos[Module], YPos[Module], Module, Current[Module]) ;
         Case HiByte of
{ ESC }      $01 : if LoByte = $1B then ClearLine ;
{ BS  }      $0E : if LoByte = $08 then BackSpace ;
{ TAB }      $0F : if LoByte = $09 then IndentLine(Current[Module]) ;
{ Shft}      $47 : if LoByte = $37 then 
 {Home}               ClearDelBuf 
{ Clr }            else
 {Home}               if LoByte = $00 then
                         DeleteLine ;
{ UP  }      $48 : if LoByte = $00 then
                      UpArrow ;
{ Shft}      $4B : if LoByte = $34 then 
 {Left}               UnIndentLine(Current[Module])
{ Left}            else
                     if (LoByte = $00) then
                        if Current[Module] <> nil then
                           XPos[Module] := XPos[Module] - 1 ;
{ Shft}      $4D : if LoByte = $36 then
 {Rght}               IndentLine(Current[Module])
                   else
{ Rght}               if (LoByte = $00) then
                         if Current[Module] <> nil then
                            XPos[Module] := XPos[Module] + 1 ;
{ Down}      $50 : if LoByte = $00 then
                      DownArrow ;
{ Inst}      $52 : if LoByte = $00 then
                      InsertLine ;
{ UNDO}      $61 : if LoByte = $00 then
                      if DelRec <> nil then
                         UndoKey ;
            else : Case LoByte of
{ RETURN }             $0D : if (HiByte = $1C) OR (HiByte = $72) then
                                ReturnKey ;
{ DEL }                $7F : if HiByte = $53 then DeleteKey ;
{ Characters }        else : if (LoByte > $1F) AND (LoByte < $7F) then
                                begin
                                  if Current[Module] = nil then
                                     PrintChar(LoByte)
                                  else
                                     if Length(Current[Module]^.NewWord) 
                                        < 96 then
                                        PrintChar(LoByte) ;
                                end ;
                    end;
         end ;
         CheckBoundary ;
         NewCursor(XPos[Module], YPos[Module], Module, Current[Module]) ;
       end ;

     if BlockEdit AND SaveRec then
        HideBlk ;
     Set_MenuBar ;
  end;


 procedure MB_Input ;

   var
       i,
       X_Line,
       Y_Line,
       CharPos,
       Len     : short_integer;
       CurRec  : WordPointer ;
       FormatStr : Str255 ;

    begin
      if N_Window > 0 then
      with Gem_Result do
        if Current[Module] <> nil then
           begin
             CurRec := Current[Module] ;
             X_Line := (X_Mouse - x - 10) DIV 8;
             Y_Line := ((Y_Mouse - y) DIV (9 * Resolution)) + 1;

             if (Y_Line > 0) AND (Y_Line < h DIV (9 * Resolution) + 1) AND
                (X_Line > -2) AND (X_Line < w DIV 8 - 1) AND
                (Y_Mouse > y) then
                begin
                  EraseCursor(XPos[Module], YPos[Module],
                              Module, Current[Module]) ;
                  if Y_Line > 19 then Y_Line := 19 ;
                  if Y_Line > YPos[Module] then
                     begin
                       for i := YPos[Module] to Y_Line - 1 do
                           if CurRec^.Next <> nil then
                              begin
                                CurRec := CurRec^.Next ;
                                YPos[Module] := YPos[Module] + 1 ;
                              end ;
                     end
                  else
                     begin
                       if Y_Line < YPos[Module] then
                         for i := Y_Line to YPos[Module] - 1 do
                             if CurRec^.Prev <> nil then
                                begin
                                  CurRec := CurRec^.Prev ;
                                  YPos[Module] := YPos[Module] - 1 ;
                                end ;          
                     end ;
                  CharPos := X_Line + WindOffset[Module] - 
                             (CurRec^.Level * 3 + 16) ;
                             
                  if CharPos > Length(CurRec^.NewWord) then
                     CharPos := Length(CurRec^.NewWord) + 1
                  else
                     if CharPos < 1 then CharPos := 1 ;
                     
                  XPos[Module] := CharPos ;
                  Current[Module] := CurRec ;
                  NewCursor(XPos[Module], YPos[Module],
                            Module, Current[Module]) ;
                end;
           end;
    end;


BEGIN
END.
