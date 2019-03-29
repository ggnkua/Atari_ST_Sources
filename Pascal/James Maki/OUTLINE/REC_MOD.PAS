{$M+}
{$E+}

program Record_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

  procedure EraseCursor(X, Y, WindNo : short_integer ; CurRec : WordPointer) ;
     External ;

  procedure NewCursor(XP, Y, WindNo : short_integer ; CurRec : WordPointer) ;
     External ;

  procedure Draw_Window(CurRec : WordPointer ; 
                        WindMsg, LineNo : short_integer ) ;
     External ;

  procedure Event_Loop ;
     External ;


  procedure GetWord(Var SearchStr : Str255 ) ;

    var
       GetStr     : Dialog_Ptr;
       GetScreen  : Tree_Index;
       GetItem    : array[1..5] of short_integer;
       GetEditStr : Str255 ;

     begin
       GetStr := New_Dialog(3, 0, 0, 40, 8);
       Center_Dialog(GetStr);

       GetItem[1] := Add_DItem(GetStr, G_BoxText, 0, 
                                 4, 1, 33, 1, -2, 4096 | 256 | 128);
       Set_DText(GetStr, GetItem[1], 'Enter Word to Find', 
                                      System_Font, TE_Center);

       GetItem[2] := Add_DItem(GetStr, G_FBoxText, Editable,
                                 2, 3, 36, 2, -1, 4096 | 256 | 128);
       Set_DEdit(GetStr, GetItem[2], '_________________________________', 
                                     'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                                     SearchStr, System_Font, TE_Center);

       GetItem[3] := Add_DItem(GetStr, G_BoxText,
                                 Default | Touch_Exit | Selectable,
                                 15, 6, 10, 1, -3, 4096 | 256 | 128);
       Set_DText(GetStr, GetItem[3], 'Search', System_Font, TE_Center);

       GetScreen := Do_Dialog(GetStr, 2) ;
  
       Get_DEdit(GetStr, GetItem[2], GetEditStr) ;
       SearchStr := GetEditStr ;

       End_Dialog(GetStr);
       Delete_Dialog(GetStr);
       Event_Loop ;
     end;


    procedure SearchRec( Flag : boolean ) ;
    
      var
         CurRec     : WordPointer ;
         StrFound,
         ExitSearch : boolean ;
         i,
         StrPos,
         Counter    : short_integer ;
         
       begin
         if Flag then
            GetWord(SearchStr) ;
         ExitSearch := false ;
         Counter    := 1 ;
         CurRec := Current[Module] ;
         While (CurRec <> nil) AND NOT ExitSearch do
            begin
              StrFound := false ;
              StrPos := Pos(SearchStr, CurRec^.NewWord) ;
              if CurRec = Current[Module] then
                 begin
                   if StrPos > XPos[Module] then
                      StrFound := true ;
                 end
              else
                 if StrPos > 0 then 
                    StrFound := true ;
              if StrFound then
                 begin
                   Current[Module] := CurRec ;
                   ExitSearch      := true ;
                   if YPos[Module] + Counter <= NumLines then
                      begin
                        YPos[Module] := YPos[Module] + Counter - 1 ;
                        XPos[Module] := StrPos ;
                      end
                   else
                      begin
                        i := 1 ;
                        YPos[Module] := 1 ;
                        ScrFirstRec[Module] := CurRec ;
                        VertOffset[Module]  := VertOffset[Module] + Counter ;
                        While (CurRec^.Prev <> nil) AND 
                              (i < NumLines DIV 2) AND
                              (VertOffset[Module] > 0)  do
                          begin
                            VertOffset[Module] := VertOffset[Module] - 1 ;
                            YPos[Module] := YPos[Module] + 1 ;
                            ScrFirstRec[Module] := 
                                                ScrFirstRec[Module]^.Prev ;
                            CurRec := CurRec^.Prev ;
                            i := i + 1 ;
                          end ;
                        XPos[Module] := StrPos ;
                      end ;
                   Work_Rect(Module,x,y,w,h) ;
                   Set_Clip(x,y,w,h) ;
                   Draw_Window(ScrFirstRec[Module], Module, 1) ;
                 end ;
              CurRec := CurRec^.Next ;
              Counter := Counter + 1 ;
            end ;
       end ;

    procedure InsertARec(Var CurRec : WordPointer ; NewStr : Str255 ) ;

     var
         NewRec : WordPointer ;

      begin
        new(NewRec) ;
        NewRec^.NewWord := NewStr ;
        NewRec^.Buffer  := false ;
        XPos[Module]    := 1 ;
        if CurRec <> nil then
           begin
             if CurRec^.Prev = nil then
                begin
                  NewRec^.Level   := 0 ;
                  NewRec^.PtLabel := 1 ;
                end
             else
                begin
                  NewRec^.Level   := CurRec^.Prev^.Level ;
                  NewRec^.PtLabel := CurRec^.Prev^.PtLabel + 1 ;
                end ;
                
             if CurRec = FirstRec[Module] then
                begin
                  FirstRec[Module]    := NewRec ;
                  ScrFirstRec[Module] := NewRec ;
                end ;

             NewRec^.Next     := CurRec ;
             if CurRec^.Prev <> nil then
                CurRec^.Prev^.Next := NewRec ;
             NewRec^.Prev     := CurRec^.Prev ;
             CurRec^.Prev     := NewRec ;
           end
        else
           begin
             NewRec^.Level   := 0 ;
             NewRec^.PtLabel := 1 ;
             FirstRec[Module]    := NewRec ;
             ScrFirstRec[Module] := NewRec ;

             NewRec^.Next     := nil ;
             NewRec^.Prev     := nil ;
           end ;
        CurRec           := NewRec ;
        TotalRec[Module] := TotalRec[Module] + 1 ;
        TotRec           := TotRec + 1 ;
      end ;


    procedure DeleteARec(Var CurRec : WordPointer) ;
    
     var
         SaveRec : Array[1..2] of WordPointer ;

      begin
        if CurRec <> nil then
           begin
             SaveRec[1] := DelRec ;
             SaveRec[2] := CurRec ;
             if CurRec = ScrFirstRec[Module] then
                begin
                  ScrFirstRec[Module] := ScrFirstRec[Module]^.Next ;
                end ;
             if (CurRec^.Next <> nil) AND (CurRec^.Prev <> nil) then
                begin
                  CurRec^.Prev^.Next := CurRec^.Next ;
                  CurRec^.Next^.Prev := CurRec^.Prev ;
                  CurRec             := CurRec^.Prev^.Next ;
                end
             else
                if CurRec^.Next <> nil then
                   begin
                     CurRec^.Next^.Prev := nil ;
                     FirstRec[Module]   := CurRec^.Next ;
                     CurRec             := CurRec^.Next ;
                   end
                else
                   if CurRec^.Prev <> nil then
                      begin
                        CurRec^.Prev^.Next := nil ;
                        LastRec[Module]    := CurRec^.Prev ;
                        CurRec             := CurRec^.Prev ;
                        YPos[Module]       := YPos[Module] - 1 ;
                      end
                   else
                      begin
                        FirstRec[Module] := nil ;
                        LastRec[Module]  := nil ;
                        CurRec           := nil ;
                      end ;
             TotalRec[Module] := TotalRec[Module] - 1 ;

             DelRec := SaveRec[2] ;
             DelRec^.Next := SaveRec[1] ;
             DelRec^.Prev := nil ;
             if SaveRec[1] <> nil then
                SaveRec[1]^.Prev := DelRec ;
           end ;
      end ;


    procedure AddARec(Var CurRec : WordPointer ; NewWord : Str255 ) ;
    
      begin
        if CurRec = nil then
           begin
             new(CurRec) ;
             CurRec^.NewWord  := NewWord ;
             CurRec^.Next     := nil ;
             CurRec^.Prev     := LastRec[Module] ;
             CurRec^.Buffer   := false ;
             LastRec[Module]  := CurRec ;
             if FirstRec[Module] = CurRec then
                ScrFirstRec[Module] := CurRec ;

             if CurRec^.Prev = nil then
                begin
                  CurRec^.Level   := 0 ;
                  CurRec^.PtLabel := 1 ;
                end                  
             else
                begin
                  CurRec^.Level   := CurRec^.Prev^.Level ;
                  CurRec^.PtLabel := CurRec^.Prev^.PtLabel + 1 ;
                end ;
                
             Current[Module]  := CurRec ;
             TotalRec[Module] := TotalRec[Module] + 1 ;
             TotRec           := TotRec + 1 ;
           end
        else
           AddARec(CurRec^.Next, NewWord) ;
      end ;

BEGIN
END.
