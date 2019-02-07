{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program Record_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{   *********************  External  ***********************************   }
  procedure CalcOffset(    FirstRec, CurRec : ScrPtr ; 
                       Var Offset : short_integer ) ;
     External ;

  procedure FillString(Var SourceStr : Str50 ; FillChar : char ) ;
     External ;

  procedure DrawDesign ;
     External ;

  procedure DrawScreen( CurRec : ScrPtr ) ;
     External ;

  procedure DrawRecord(CurRec : DataPtr ) ;
     External ;

  procedure Do_Redraw(msg : Message_Buffer ) ;
     External ;

  procedure GetStr(CurRec : DataPtr ; Var DisplayStr : Str255 ;
                   Start, Size : short_integer ) ;
     External ;

  procedure DetCurRec(    D_CurRec : DataStorePtr ;
                      Var CurRec   : DataStorePtr ;  
                      Var Location : short_integer ) ;
     External ;

  procedure ModifyStr(CurRec : DataPtr ; Location : short_integer ; 
                      InChar : char) ;
     External ;

  procedure DisposeRecs(Var FirstRec, CurRec, LastRec : ScrPtr ) ;
     External ;

  procedure DisposeInt(Var FirstRec, CurRec, LastRec : IntPtr ) ;
     External ;

  procedure ClearRecord( CurRec : DataPtr ) ;
     External ;

  procedure D_DisposeRecs(Var FirstRec, CurRec, LastRec : DataPtr ) ;
     External ;

  procedure PlusMemAvail(RecSize : long_integer) ;
     External ;
     
  procedure MinusMemAvail(RecSize : long_integer ) ;
     External ;

  procedure FormatCheck( CurRec : DataPtr ) ;
     External ;     

  procedure UpdateInfoLine ;
     External ;

  procedure MB_Input(X_Mouse, Y_Mouse : short_integer) ;
     External ;

  procedure ClrHome ;
     External ;

  procedure NewCursor(ScrMode : short_integer) ;
     External ;

  procedure ChangeMode( Var Mode, NewMode : short_integer ) ;
     External ;

  procedure MenuOption ;
     External ;

  procedure CopyRight ;
     External ;
{   ********************************************************************   }

{ *************************************************************************
     Display Verticle slider in proper position and size.
************************************************************************* }
  procedure Set_VSlideSize ;

    var
       SlideSize : short_integer ;

     begin     
       Case Mode of
        1,4 : SlideSize := 1000 ;
          2 : begin
                if D_FirstRec[DataNum] <> nil then
                   SlideSize := 1000 DIV TotalRec[DataNum]
                else
                   SlideSize := 1000 ;
              end ;
          3 : begin
                if F_FirstRec <> nil then
                   SlideSize := 1000 DIV F_TotalRec[DataNum]
                else
                   SlideSize := 1000 ;
              end ;
          5 : SlideSize := 10000 DIV TotScrRec
       end ;

       if SlideSize < 1 then SlideSize := 1
       else
          if SlideSize > 1000 then SlideSize := 1000 ;
       Wind_Set(WindNum, WF_VSlSize, SlideSize, 0, 0, 0) ;
     end ;

{ *************************************************************************
     Modify the name displayed in the title section of the GEM Window.
************************************************************************* }
  procedure ModifyWName ;

    var
       i,
       Position : short_integer ;
       FileName : array[1..2] of Window_Title ;
        
     begin
       if S_FirstRec[ScrNum] <> nil then
          FileName[1] := DefFileScr
       else
          FileName[1] := ' empty ' ;

       if ( D_FirstRec[ScrNum] = nil) OR
          ((D_FirstRec[ScrNum] = D_LastRec[ScrNum]) AND 
            NOT EditFlag[ScrNum]) then
            FileName[2] := ' empty '
       else
          FileName[2] := DefFileDat ;
       
       for i := 1 to 2 do
           begin
             Repeat
               Position := Pos(chr($5C), FileName[i]) ;
               if Position > 0 then
                  Delete(FileName[i], 1, Position) ;
             Until Position = 0 ;

             Position := Pos(chr($2E), FileName[i]) ;
             if Position > 0 then
                Delete(FileName[i], Position,
                       Length(FileName[i]) - Position + 1) ;
          end ;
                
       WindName[1] := Concat(' Design: ', FileName[1], 
                             '  Database: ', FileName[2], chr($20)) ;
       Set_WName(ScrNum, WindName[1]) ;
     end ;
      
{ *************************************************************************
     Define the DiskError encountered during Save and Retrieve routines.
************************************************************************* }
  procedure DiskError(IO_Result : short_integer ) ;

    var
       SaveStr     : Str255 ;

     begin
       if IO_Result = -39 then
          begin
            AlertStr := '[1][ Insufficient Disk Space |' ;
            AlertStr := Concat(AlertStr,'       to Save File | ]') ;
          end 
       else
          if IO_Result = -33 then
             AlertStr := '[1][ File Not Found | ]'
          else
             if IO_Result = 9 then
                AlertStr := '[1][ File Name Error | ]'
             else
                if IO_Result = 1 then
                   begin
                     AlertStr := '[1][  Incorrect File Structure |' ;
                     AlertStr := Concat(AlertStr, '      Encountered |') ;
                     AlertStr := Concat(AlertStr,' During File Operation | ]') ;
                   end
                else
                   begin
                     WriteV(SaveStr, IO_Result) ;
                     AlertStr := '[1][  Disk Access Error ' ;
                     AlertStr := Concat(AlertStr, SaveStr, ' |') ;
                     AlertStr := Concat(AlertStr,' During File Operation | ]') ;
                   end ;
       AlertStr := Concat(AlertStr, '[ Continue ]') ;
       Result := Do_Alert(AlertStr,1) ;
     end ;

{ *************************************************************************
     AddARec adds a new ScrPtr record to the list.  It starts at the
     position of CurRec (usually the first record) and searches until
     the end of the list is found.  At that point, a new record is created
     and the appropriate information stored.
************************************************************************* }
  procedure AddARec(Var FirstRec, CurRec, LastRec, ScrRec : ScrPtr ;
                        TitleStr : Str255 ;
                        XCur, YCur, Size : short_integer ;
                        DataType : char ; ScrNum : short_integer ) ;

    var
       T_Offset : short_integer ;
      
     begin
       if ScrRec = nil then
          begin
            MinusMemAvail(ScrRecSize) ;
            new(ScrRec) ;

            ScrRec^.Next := nil ;
            ScrRec^.Prev := LastRec ;
            LastRec := ScrRec ;
            CurRec  := ScrRec ;

            if FirstRec = nil then 
               begin
                 FirstRec := ScrRec ;
                 FirstRec^.Prev := nil ;
               end ;

            ScrRec^.LabelStr := TitleStr ;
            ScrRec^.DataType := DataType ;
            ScrRec^.X        := XCur ;
            ScrRec^.Y        := YCur ;
            ScrRec^.Size     := Size ;
            ScrRec^.XInPos   := 0 ;
            ScrRec^.XPos     := XCur + Length(TitleStr) + 3 ; 
            ScrRec^.YPos     := YCur ;

            CalcOffset(FirstRec, ScrRec, T_Offset ) ;
            ScrRec^.Offset   := T_Offset ;
          end
       else
          AddARec(FirstRec, CurRec, LastRec, ScrRec^.Next, TitleStr, 
                  XCur, YCur, Size, DataType, ScrNum ) ;
     end ;

{ *************************************************************************
     DS_AddARec adds a new DataStorePtr record.
************************************************************************* }
  procedure DS_AddARec(Var CurRec : DataStorePtr ; 
                           Size, DataNum : short_integer ) ;

     begin
       if Size > 0 then
          begin
            Size := Size - 1 ;
            MinusMemAvail(DataRecSize) ;
            new(CurRec) ;
            if DataNum = Report then
               FillString(CurRec^.DataStr, chr($20))
            else
               FillString(CurRec^.DataStr, chr(1)) ;
            DS_AddARec(CurRec^.Next, Size, DataNum) ;
          end ;
     end ;


{ *************************************************************************
     D_AddARec sets up the DataPtr record that points to the first
     Data Record and then calls DS_AddARec to set up the necessary 
     number of DataStorage records as a linked list.
************************************************************************* }
  procedure D_AddARec(Var FirstRec, CurRec, LastRec, DataRec  : DataPtr ; 
                          Size, DataNum : short_integer ) ;
   
     begin
       if DataRec = nil then
          begin
            MinusMemAvail(PtrRecSize) ;
            new(DataRec) ;

            DataRec^.Next := nil ;
            DataRec^.Prev := LastRec ;
            LastRec := DataRec ;
            CurRec := DataRec ;

            if FirstRec = nil then 
               begin
                 FirstRec := DataRec ;
                 FirstRec^.Prev := nil ;
               end ;

            DataRec^.OrderMore := nil ;
            DataRec^.OrderLess := nil ;
            DS_AddARec(DataRec^.Data, Size, DataNum) ;
            TotalRec[DataNum] := TotalRec[DataNum] + 1 ;
          end
       else
          D_AddARec(FirstRec,CurRec,LastRec,DataRec^.Next,Size,DataNum) ;
     end ;

{ *************************************************************************
     InputeDataRec determines the number of Str50 records that will be
     required and then creates the necessary records by calling
     D_AddARec. Used for loading a pre-existing Database from disk.
************************************************************************* }
  procedure InputDataRec(DataNum : short_integer) ;
   
    var
       TotalSize,
       NumRecs    : short_integer ;
   
     begin
       TotalSize := S_LastRec[DataNum]^.Offset + S_LastRec[DataNum]^.Size ;
       NumRecs   := (TotalSize DIV 50) + 1 ;
       D_AddARec(D_FirstRec[DataNum], D_CurrentRec[DataNum],
                 D_LastRec[DataNum], D_LastRec[DataNum], NumRecs, DataNum) ;
     end ;

{ *************************************************************************
     CreateDataRec determines the number of Str50 records that will be
     required and then creates the necessary records by calling
     D_AddARec.
************************************************************************* }
  procedure CreateDataRec(DataNum : short_integer) ;

    var
       Location : short_integer ;
       ScrRec   : ScrPtr ;
   
     begin
       InputDataRec(DataNum) ;
       ScrRec := S_FirstRec[DataNum] ;
       WHILE ScrRec <> nil do
         BEGIN
           if ScrRec^.DataType = 'F' then
              begin
                Location := ScrRec^.Offset ;
                ModifyStr(D_CurrentRec[DataNum], Location, chr($24)) ;
                DrawRecord(D_CurrentRec[DataNum]) ;
              end ;
            ScrRec := ScrRec^.Next ;
         END ;
       Set_VSlideSize ;
     end ;

{ *************************************************************************
     Adds to the list of integers which describe the order of a
     Merge function of dissimilar database and design form, or
     the index for search records.
************************************************************************* }
  procedure Int_AddARec(Var FirstRec, CurRec, LastRec : IntPtr ; 
                            Value : short_integer ) ;
  
     begin
       if CurRec = nil then
          begin
            new(CurRec) ;
            if FirstRec = nil then
               FirstRec := CurRec ;
            CurRec^.Match := Value ;
            CurRec^.Next := nil ;
            CurRec^.Prev := LastRec ;
            LastRec := CurRec ;
          end
       else
          Int_AddARec(FirstRec, CurRec^.Next, LastRec, Value) ;
     end ;

{ *************************************************************************
     IncrementRec moves the D_CurrentRec pointer to the next or previous
     record of the linked list depending on the value of Value.
************************************************************************* }
  procedure IncrementRec(Var  CurRec : DataPtr ; Value : short_integer ;
                              DrawFlag : boolean ) ;

    var
       i,
       Count,
       NewCount,
       OldCount : short_integer ;
       DrawRec  : boolean ;
       ScrRec   : ScrPtr ;

     procedure ChangeRec(Value : short_integer) ;

        begin
          RecNo[DataNum] := RecNo[DataNum] + Value ;
          DrawRec := true ;
        end ;

     procedure I_NextRec ;
     
        begin
          CurRec := CurRec^.Next ;
          ChangeRec(Value) ;
        end ;

     procedure I_PrevRec ;

        begin
          CurRec := CurRec^.Prev ;
          ChangeRec(Value) ;
       end ;


     procedure S_NextRec ;

       var
          i : short_integer ;

        begin
          OldCount := F_CurRec^.Match ;
          F_CurRec := F_CurRec^.Next ;
          F_RecNo[DataNum] := F_RecNo[DataNum] + 1 ;
          NewCount := F_CurRec^.Match ;
          Count := NewCount - OldCount ;
          for i := 1 to Count do
              CurRec := CurRec^.Next ;
          RecNo[DataNum] := F_CurRec^.Match ;
          DrawRec := true ;
        end ;

     procedure S_PrevRec ;

       var
          i : short_integer ;

        begin
          OldCount := F_CurRec^.Match ;
          F_CurRec := F_CurRec^.Prev ;
          F_RecNo[DataNum] := F_RecNo[DataNum] - 1 ;
          NewCount := F_CurRec^.Match ;
          Count := OldCount - NewCount ;
          for i := 1 to Count do
              CurRec := CurRec^.Prev ;
          RecNo[DataNum] := F_CurRec^.Match ;
          DrawRec := true ;
        end ;

     begin
       if CurRec <> nil then
          begin
             DrawRec := false ;
             FormatCheck(CurRec) ;
             Case Mode of
               2 : if (Value = 1) AND (CurRec^.Next <> nil) then
                      I_NextRec
                   else
                      if (Value = -1) AND (CurRec^.Prev <> nil) then
                         I_PrevRec ;
               3 : if NOT SearchFlag then
                      begin
                        if (Value = 1) AND (F_CurRec^.Next <> nil) then
                           S_NextRec
                        else
                           if (Value = -1) AND (F_CurRec^.Prev <> nil) then
                              S_PrevRec ;
                      end ;
               5 : if F_FirstRec <> nil then
                      begin
                        if F_CurRec^.Next <> nil then
                           S_NextRec
                        else
                           CurRec := nil ;
                      end 
                   else
                      begin
                        if CurRec^.Next <> nil then
                           I_NextRec
                        else
                           CurRec := nil ;
                      end ;
             end ;

             if DrawRec AND DrawFlag AND (Mode <> 5) then
                begin
                  UpdateFlag := true ; ;
                  ClrHome ;
                  DrawRecord(CurRec) ;
                end ;
          end ;
     end ;


{ *************************************************************************
     Move to the First DataRec record if in Input Mode or the first Search
     record if in Record Mode.
************************************************************************* }
  procedure GoToFirst( Var CurRec : DataPtr ; DrawFlag : boolean ) ;

    var
       DrawRec : boolean ;
       i       : short_integer ;

     begin
       DrawRec := false ;
       if CurRec <> nil then
          begin
             FormatCheck(CurRec) ;
             Case Mode of
               2 : if CurRec <> D_FirstRec[DataNum] then
                      begin
                        CurRec := D_FirstRec[DataNum] ;
                        RecNo[DataNum] := 1 ;
                        DrawRec := true ;
                      end ;
               3 : if NOT SearchFlag AND (F_CurRec <> F_FirstRec) then
                      begin
                        F_CurRec := F_FirstRec ;
                        F_RecNo[DataNum] := 1 ;
                        CurRec := D_FirstRec[DataNum] ;
                        for i := 2 to F_CurRec^.Match do
                            CurRec := CurRec^.Next ;
                        RecNo[DataNum] := i - 1 ;
                        DrawRec := true ;
                      end ;
             end ;
          
             if DrawRec AND DrawFlag then
                begin
                  UpdateFlag := true ; ;
                  ClrHome ;
                  DrawRecord(CurRec) ;
                end ;
          end ;
     end ;
     
{ *************************************************************************
     Go to the last record.  Different for Search and Input Mode.
************************************************************************* }
  procedure GoToLast(Var CurRec : DataPtr ; DrawFlag : boolean) ;

    var
       i       : short_integer ;
       DrawRec : boolean ;
       ScrRec  : ScrPtr ;

     begin
       DrawRec := false ;
       if CurRec <> nil then
          begin
             FormatCheck(CurRec) ;
             Case Mode of
               2 : if CurRec <> D_LastRec[DataNum] then
                      begin
                        CurRec := D_LastRec[DataNum] ;
                        RecNo[DataNum] := TotalRec[DataNum] ;
                        DrawRec := true ;
                      end ;
               3 : if NOT SearchFlag AND (F_CurRec <> F_LastRec) then
                      begin
                        F_CurRec := F_LastRec ;
                        F_RecNo[DataNum] := F_TotalRec[DataNum] ;
                        CurRec := D_FirstRec[DataNum] ;
                        for i := 2 to F_CurRec^.Match do
                            CurRec := CurRec^.Next ;
                        RecNo[DataNum] := i - 1 ;
                        DrawRec := true ;
                      end ;
             end ;

             if DrawRec AND DrawFlag then
                begin
                  UpdateFlag := true ; ;
                  ClrHome ;
                  DrawRecord(CurRec) ;
                end ;
          end ;
     end ;

{ *************************************************************************
     DeleteARec removes a field from the current record design.
************************************************************************* }
  procedure DeleteARec(CurRec : ScrPtr) ;

    var
       NextRec : ScrPtr ;

     begin
       if CurRec^.DataType = 'H' then
          NextRec := CurRec^.Next
       else
          NextRec := nil ;
       if (CurRec = S_FirstRec[ScrNum]) AND 
          (CurRec = S_LastRec[ScrNum]) then
          begin
            { Delete Only Record }
            S_FirstRec[ScrNum]   := nil ;
            S_LastRec[ScrNum]    := nil ;
            S_CurrentRec[ScrNum] := nil ;
          end
       else
          if CurRec = S_FirstRec[ScrNum] then
             { Delete First Record  }
             begin
               S_FirstRec[ScrNum]   := CurRec^.Next ;
               CurRec^.Next^.Prev   := nil ;
               S_CurrentRec[ScrNum] := S_FirstRec[ScrNum] ;
             end
          else
             if CurRec = S_LastRec[ScrNum] then
                { Delete Last Record }
                begin
                  S_LastRec[ScrNum]    := CurRec^.Prev ;
                  CurRec^.Prev^.Next   := nil ;
                  S_CurrentRec[ScrNum] := S_LastRec[ScrNum] ;
                end
             else
                { Delete a Middle Record }
                begin
                  CurRec^.Prev^.Next   := CurRec^.Next ;
                  CurRec^.Next^.Prev   := CurRec^.Prev ;
                  S_CurrentRec[ScrNum] := CurRec^.Next ;
                end ;
       Dispose(CurRec) ;
       PlusMemAvail(ScrRecSize) ;
       if NextRec <> nil then
          DeleteARec(NextRec) ;
     end ;

{ *************************************************************************
     DisposeData Disposes the DataStore records associated with
     the DataPtr record CurRec.  DispRec is a saved pointer while
     NextRec stores the location of the next pointer in the linked
     list of data store locations.
************************************************************************* }
  procedure DisposeData( CurRec : DataPtr ) ;

    var
       DispRec,
       NextRec : DataStorePtr ;
      
     begin
       NextRec := CurRec^.Data ;
       While NextRec <> nil do
          begin
            DispRec := NextRec ;
            NextRec := NextRec^.Next ;
            Dispose(DispRec) ;
            PlusMemAvail(DataRecSize) ;
          end ;
     end ;

{ *************************************************************************
     Int_DeleteARec removes a Integer Record from the current list.
     FOR SEARCH MODE ONLY!!!
************************************************************************* }
  procedure Int_DeleteARec(    CurRec : IntPtr ; 
                           Var F_DataRec, DataRec : DataPtr) ;

    var
       NewMode,
       i       : short_integer ;
       ModRec  : IntPtr ;

     begin
       ModRec := CurRec ;
       While ModRec <> nil do
          begin
            ModRec^.Match := ModRec^.Match - 1 ;
            ModRec := ModRec^.Next ;
          end ;
          
       F_TotalRec[DataNum] := F_TotalRec[DataNum] - 1 ;
       if (CurRec = F_FirstRec) AND 
          (CurRec = F_LastRec) then
          begin
            { Delete Only Record }
            F_FirstRec := nil ;
            F_LastRec  := nil ;
            F_CurRec   := nil ;
            NewMode := 2 ;
            ChangeMode(Mode, NewMode) ;
            MenuOption ;
          end
       else
          if CurRec = F_FirstRec then
             { Delete First Record  }
             begin
               F_FirstRec := CurRec^.Next ;
               CurRec^.Next^.Prev  := nil ;
               F_CurRec := F_FirstRec ;
             end
          else
             if CurRec = F_LastRec then
                { Delete Last Record }
                begin
                  F_LastRec := CurRec^.Prev ;
                  CurRec^.Prev^.Next := nil ;
                  F_CurRec := F_LastRec ;
                  F_RecNo[DataNum] := F_RecNo[DataNum] - 1 ;
                end
             else
                { Delete a Middle Record }
                begin
                  CurRec^.Prev^.Next   := CurRec^.Next ;
                  CurRec^.Next^.Prev   := CurRec^.Prev ;
                  F_CurRec := CurRec^.Next ;
                end ;

       Dispose(CurRec) ;
       DataRec := F_DataRec ;
       RecNo[DataNum] := 1 ;
       if F_CurRec <> nil then
          begin
            for i := 2 to F_CurRec^.Match do
                DataRec := DataRec^.Next ;
            RecNo[DataNum] := i - 1 ;
          end ;
     end ;

{ *************************************************************************
     Dispose of the DataPtr record and call the routine to Dispose of
     the related DataStoreRecords.
************************************************************************* }
  procedure DispDataRec( CurRec : DataPtr ) ;

     begin
       if DelItem <> nil then
          begin
            DisposeData(DelItem) ;
            Dispose(DelItem) ;
            PlusMemAvail(PtrRecSize) ;
          end ;
          
       TotalRec[DataNum] := TotalRec[DataNum] - 1 ;
       DelItem := CurRec ;
     end ;

{ *************************************************************************
     DS_DeleteARec removes a Record from the current data base.
************************************************************************* }
  procedure DS_DeleteARec(CurRec : DataPtr) ;

     begin
       DispDataRec(CurRec) ;
       if (CurRec = D_FirstRec[DataNum]) AND 
          (CurRec = D_LastRec[DataNum]) then
          begin
            { Delete Only Record }
            D_FirstRec[DataNum]   := nil ;
            D_LastRec[DataNum]    := nil ;
            D_CurrentRec[DataNum] := nil ;
            CreateDataRec(DataNum) ;
          end
       else
          if CurRec = D_FirstRec[DataNum] then
             { Delete First Record  }
             begin
               D_FirstRec[DataNum]   := CurRec^.Next ;
               CurRec^.Next^.Prev   := nil ;
               D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
               RecNo[DataNum] := 1 ;
             end
          else
             if CurRec = D_LastRec[DataNum] then
                { Delete Last Record }
                begin
                  D_LastRec[DataNum]    := CurRec^.Prev ;
                  CurRec^.Prev^.Next   := nil ;
                  D_CurrentRec[DataNum] := D_LastRec[DataNum] ;
                  RecNo[DataNum] := TotalRec[DataNum] ;
                end
             else
                { Delete a Middle Record }
                begin
                  CurRec^.Prev^.Next   := CurRec^.Next ;
                  CurRec^.Next^.Prev   := CurRec^.Prev ;
                  D_CurrentRec[DataNum] := CurRec^.Next ;
                end ;

       if (Mode = 3) AND (F_CurRec <> nil) then
          Int_DeleteARec(F_CurRec, 
                         D_FirstRec[DataNum], D_CurrentRec[DataNum]) ;
       Set_VSlideSize ;
     end ;

{ *************************************************************************
     Get necessary information to open a Screen Info file and
     paint screen with proper form.
************************************************************************* }
  procedure OpenScrnInfo( Var Flag : boolean) ;
     
    var
       i             : short_integer ;
       CurRec        : ScrPtr ;
       NewRecFlag    : boolean ;
       SaveIO_Result : short_integer ;

    Label
       1 ;

     begin
       SaveIO_Result := 1 ;
       NewRecFlag := false ;
       Flag := false ;
       if Get_In_File(DefPathScr, DefFileScr) then
          begin
            IO_Check(false) ;

            Reset(ScrnStore,DefFileScr) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            MinusMemAvail(ScrRecSize) ;
            new(CurRec) ;
            NewRecFlag := true ;

            Read(ScrnStore, CurRec^) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            if CurRec^.LabelStr <> 'ScreenDesign' then
               begin
                 SaveIO_Result := 1 ;
                 GoTo 1 ;
               end ;

            DisposeRecs(S_FirstRec[ScrNum], S_CurrentRec[ScrNum], 
                        S_LastRec[ScrNum] ) ;

            for i := 1 to 4 do
                begin
                  Read(ScrnStore, CurRec^) ;
                  SaveIO_Result := IO_Result ;
                  if SaveIO_Result <> 0 then GoTo 1 ;
                  PrtInit[i] := CurRec^.LabelStr ;
                  DecReal    := CurRec^.X ;
                end ;

            While NOT EOF(ScrnStore) do
               begin
                 Read(ScrnStore, CurRec^) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 AddARec(S_FirstRec[ScrNum],S_CurrentRec[ScrNum],
                         S_LastRec[ScrNum], S_LastRec[ScrNum],
                         CurRec^.LabelStr, CurRec^.X, CurRec^.Y, 
                         CurRec^.Size, CurRec^.DataType, ScrNum)
               end ;

1 :         if SaveIO_Result <> 0 then
               DiskError(SaveIO_Result) ;              
               
            if NewRecFlag then
               begin
                 Dispose(CurRec) ;
                 PlusMemAvail(ScrRecSize) ;
               end ;

            if SaveIO_Result = 0 then
               begin
                 CurRec := S_FirstRec[ScrNum] ;
                 ModifyWName ;
                 D_EditFlag[ScrNum] := False ;
                 Flag := true
               end 
            else
               Flag := false ;

            Close(ScrnStore) ;
            DrawScreen( S_FirstRec[ScrNum] ) ;
            ShortDraw := true ;

            IO_Check(true) ;
          end ;
     end ;

{ *************************************************************************
     Save the current screen form design to a disk file.
************************************************************************* }
  procedure SaveScrnInfo ;
     
    var
       i           : short_integer ;
       CurRec      : ScrPtr ;
       BakFile     : text ;
       BakFileName : Path_Name ;
       SaveIO_Result,
       Position    : short_integer ;

    Label
       1 ;

     begin
       if Get_In_File(DefPathScr, DefFileScr) then
          begin
            IO_Check(false) ;
            Reset(ScrnStore, DefFileScr) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result = 0 then
               begin
                 BakFileName := DefFileScr ;
                 Position := Pos('.SCR', BakFileName) ;
                 if Position > 0 then
                    begin
                      Delete(BakFileName, Position, 4) ;
                      BakFileName := Concat(BakFileName, '.BSC') ;
                    end 
                 else
                    BakFileName := 'A:SCREEN.BSC' ;
                 
                  Reset(BakFile,BakFileName) ;
                  SaveIO_Result := IO_Result ;
                  if (SaveIO_Result <> -33) AND 
                     (SaveIO_Result <> 0) then GoTo 1 ;
                  Rename(ScrnStore, BakFile) ;
                  SaveIO_Result := IO_Result ;
                  if SaveIO_Result <> 0 then GoTo 1 ;
               end ;

            Rewrite(ScrnStore, DefFileScr) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            New(CurRec) ;
            CurRec^.LabelStr := 'ScreenDesign' ;

            Write(ScrnStore, CurRec^) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            for i := 1 to 4 do
                begin
                  CurRec^.LabelStr := PrtInit[i] ;
                  CurRec^.X := DecReal ;
                  Write(ScrnStore, CurRec^) ;
                  SaveIO_Result := IO_Result ;
                  if SaveIO_Result <> 0 then GoTo 1 ;
                end ;
            Dispose(CurRec) ;
            
            CurRec := S_FirstRec[ScrNum] ;

            While CurRec <> nil do
               begin
                 Write(ScrnStore, CurRec^) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 CurRec := CurRec^.Next ;
               end ;

1 :         if SaveIO_Result <> 0 then
               DiskError(SaveIO_Result) ;              
               
            Close(ScrnStore) ;
            IO_Check(true) ;
            ModifyWName ;
            D_EditFlag[ScrNum] := False ;
          end ;
     end ;

{ *************************************************************************
     Save the current database to the disk in order.
************************************************************************* }
  procedure SaveDataBase ;

    var
       CurRec      : DataPtr ;
       ScrRec      : ScrPtr ;
       DisplayStr  : Str255 ;
       SaveFv      : text ;
       BakFile     : text ;
       BakFileName : Path_Name ;
       i,
       SaveIO_Result,
       Position    : short_integer ;
       F_SaveRec   : IntPtr ;
       SaveRecNo   : short_integer ;
       
     Label
       1 ;

     begin
       if F_FirstRec <> nil then
          begin
            F_SaveRec := F_CurRec ;
            SaveRecNo := F_RecNo[DataNum] ;
          end ;
       if Get_In_File(DefPathDat, DefFileDat) then
          begin
            IO_Check(false) ;
            Reset(SaveFv, DefFileDat) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result = 0 then 
               begin
                 BakFileName := DefFileDat ;
                 Position := Pos('.DAT', BakFileName) ;
                 if Position > 0 then
                    begin
                      Delete(BakFileName, Position, 4) ;
                      BakFileName := Concat(BakFileName, '.BDT') ;
                    end 
                 else
                    BakFileName := 'A:DATA.BSC' ;
            
                 Reset(BakFile,BakFileName) ;
                 SaveIO_Result := IO_Result ;
                 if (SaveIO_Result <> -33) AND 
                    (SaveIO_Result <> 0) then GoTo 1 ;
                 Rename(SaveFv, BakFile) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
               end ;  
               
            Rewrite(SaveFv, DefFileDat) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            
            Writeln(SaveFv, 'DataBase') ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            
            ScrRec := S_FirstRec[ScrNum] ;
            While ScrRec <> nil do
               begin
                 Writeln(SaveFv, ScrRec^.LabelStr) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 
                 Writeln(SaveFv, ScrRec^.DataType) ;
                 SaveIO_Result := IO_Result ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 
                 WriteV(DisplayStr, ScrRec^.Size) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 Writeln(SaveFv, DisplayStr) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 ScrRec := ScrRec^.Next ;
               end ;
            
            Writeln(SaveFv, chr($01)) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
             
            CurRec := D_FirstRec[DataNum] ;
            F_CurRec := nil ;
            if Mode = 3 then
               GoToFirst(CurRec, false) ;
                  
            While CurRec <> nil do
               begin
                 ScrRec := S_FirstRec[ScrNum] ;
                 While ScrRec <> nil do
                    begin
                      GetStr(CurRec, DisplayStr, 
                             ScrRec^.Offset, ScrRec^.Size ) ;
                      Writeln(SaveFv, DisplayStr) ;
                      SaveIO_Result := IO_Result ;
                      if SaveIO_Result <> 0 then GoTo 1 ;
                      ScrRec := ScrRec^.Next ;
                    end ;
                     
                 if Mode = 3 then
                    begin
                      if F_CurRec^.Next = nil then
                         CurRec := nil
                      else
                         IncrementRec(CurRec, 1, false) ;
                    end
                 else
                    CurRec := CurRec^.Next ;
               end ;
            
1 :         if SaveIO_Result <> 0 then
               DiskError(SaveIO_Result) ;
               
            Close(SaveFv) ;
            if Mode = 2 then
               ModifyWName ;
            EditFlag[ScrNum] := false ;
            if NOT ExitPrompt then
               begin
                 DrawScreen(S_FirstRec[ScrNum]) ;
                 DrawRecord(D_CurrentRec[DataNum]) ;
                 ShortDraw := true ;
               end ;
          end ;
       if F_FirstRec <> nil then
          begin
            F_CurRec := F_SaveRec ;
            F_RecNo[DataNum] := SaveRecNo ;
          end ;
     end ;
{ *************************************************************************
     Prompts for information on how the data on disk is to be Merged
     with a design form in memory which are dissimilar.
************************************************************************* }
  procedure FindMatch(DiskRec : ScrPtr ; Compare : IntPtr) ;

    var
       MatchRec,
       CurRec    : ScrPtr ;
       NextRec   : IntPtr ;
       i         : byte ;
       TypeStr   : array[1..2] of Str20 ;
       QuitFlag,
       Match,
       RMB_Event : boolean ;
       UpDown    : array[1..2] of byte ;

   const
      Down1 = 1 ;
      Down2 = 2 ;
      Up    = 0 ;

{ *************************************************************************
     Covert the DataType to a String description.
************************************************************************* }
     procedure DT_To_Str(DataType : char ; Var DT_Str : Str20) ;

       var
          i : byte ;

        begin
          for i := $41 to $48 do
              if chr(i) = DataType then
                 begin
                   case i of
                       $41 : DT_Str := 'String' ;
                       $42 : DT_Str := 'Boolean' ;
                       $43 : DT_Str := 'Integer' ;
                       $44 : DT_Str := 'Company' ;
                       $45 : DT_Str := 'Real' ;
                       $46 : DT_Str := 'Dollar' ;
                       $47 : DT_Str := 'Date' ;
                       $48 : DT_Str := 'Name' ;
                   end ;
                   i := $50 ;
                 end ;
        end ;

{ *************************************************************************
     Modify the information displayed on the Info Line.
************************************************************************* }
     procedure UpdateInfoLine ;

        begin
          DT_To_Str(CurRec^.DataType, TypeStr[1]) ;
          DT_To_Str(S_CurrentRec[ScrNum]^.DataType, TypeStr[2]) ;
          WriteV(FormatStr,' Disk :',TypeStr[1]:8, chr($2F), CurRec^.Size:3,
                   chr($7C):3, 'Label :':9, chr($20), CurRec^.LabelStr, 
                   chr($20):22 - Length(CurRec^.LabelStr), chr($7C):3, 
                   chr($7C), ' Design :', TypeStr[2]:8, chr($2F),
                   S_CurrentRec[ScrNum]^.Size:3) ;
          WindInfo[WindNum] := FormatStr ;
          Set_WInfo(WindNum, WindInfo[WindNum]) ;
        end ;

{ *************************************************************************
     Determine routine selected via the dropdown menu.
************************************************************************* }
     procedure Menu_Select( msg : Message_Buffer) ;

        begin
          Case msg[4] of
             11 : CopyRight ;
             27 : begin
                    QuitFlag := true ;
                    RMB_Event := true ;
                    Match     := false ;
                    While CurRec^.Next <> nil do
                       CurRec := CurRec^.Next ;
                  end ;
             37 : if CurRec^.Next <> nil then
                     begin
                       CurRec := CurRec^.Next ;
                       NextRec := NextRec^.Next ;
                     end ;
             38 : if CurRec^.Prev <> nil then
                     begin
                       CurRec := CurRec^.Prev ;
                       NextRec := NextRec^.Prev ;
                     end ;
          end ;           

          Menu_Normal(InfoMenu, msg[3]);
          UpdateInfoLine ;
       end;

{ *************************************************************************
     Traffic Manager for input during disk import operations of non-equal
     files.
************************************************************************* }
     procedure Event_Loop ;

       var
          GemEvent  : short_integer ;
          msg       : Message_Buffer ;
          HiByte,
          LoByte,
          Key_Input,
          B_State,
          B_Count,
          X_Mouse, 
          Y_Mouse,
          Key_State : short_integer ;

        begin
          Work_Rect(WindNum, x, y, w, h);
          Set_Clip(x, y, w, h);

          GemEvent := Get_Event(E_Button | E_Keyboard | E_Timer | E_Message,
             1, UpDown[1], 1, 1,
             true, 0, 0, 0, 0,
             true, 0, 0, 0, 0,
             msg,
             Key_Input,
             B_State, B_Count,
             X_Mouse, Y_Mouse,
             Key_State);

          if (GemEvent & E_Message) <> 0 then
             Case msg[0] of
                MN_Selected : Menu_Select(msg) ;
                WM_Redraw   : Do_Redraw(msg) ;
             end
          else
             if (GemEvent & E_Button) <> 0 then
                begin
                  if UpDown[1] = Down1 then
                     begin
                       MB_Input(X_Mouse, Y_Mouse) ;
                       UpdateInfoLine ;
                       UpDown[1] := Up ;
                     end
                  else
                     UpDown[1] := Down1 ;
                end
             else
                if (GemEvent & E_Keyboard) <> 0 then
                   begin
                     HiByte  := ShR(Key_Input, 8);
                     LoByte  := ShR(ShL(Key_Input, 8),8);
                     if (HiByte = $4D) AND (LoByte = $36) then { +-Right }
                        begin
                          if CurRec^.Next <> nil then
                             begin
                               CurRec := CurRec^.Next ;
                               NextRec := NextRec^.Next ;
                             end ;
                        end
                     else
                        if (HiByte = $4B) AND (LoByte = $34) then { +-Left }
                           begin
                             if CurRec^.Prev <> nil then
                                begin
                                  CurRec := CurRec^.Prev ;
                                  NextRec := NextRec^.Prev ;
                                end ;
                           end
                        else
                           if (HiByte = $10) AND (LoByte = $11) then
                              begin
                                QuitFlag := true ;
                                RMB_Event := true ;
                                Match     := false ;
                                While CurRec^.Next <> nil do
                                  CurRec := CurRec^.Next ;
                              end ;
                     UpdateInfoLine ;
                   end 
                else
                  begin
                    GemEvent := Get_Event(E_Button | E_Timer,
                       2, UpDown[2], 1, 1,
                       true, 0, 0, 0, 0,
                       true, 0, 0, 0, 0,
                       msg,
                       Key_Input,
                       B_State, B_Count,
                       X_Mouse, Y_Mouse,
                       Key_State);
                    
                    if (GemEvent & E_Button) <> 0 then
                       if UpDown[2] = Down2 then
                          UpDown[2] := Up
                       else
                          begin
                            RMB_Event := true ;
                            UpDown[2] := Down2 ;
                            Draw_String(x + (S_CurrentRec[ScrNum]^.X + 
                                  Length(S_CurrentRec[ScrNum]^.LabelStr) + 1) * 8,
                                  y + (S_CurrentRec[ScrNum]^.Y) * Spacing, '*') ;
                          end ;
                  end ;
        end;

     begin
       Mode := 6 ;
       MenuOption ;
       DrawScreen(S_FirstRec[ScrNum]) ;
       ClrHome ;
       NewCursor(ScrNum) ;

       NextRec := Compare ;
       While NextRec <> nil do
          begin
            NextRec^.Match := 0 ;
            NextRec := NextRec^.Next ;
          end ;

       CurRec := DiskRec ;
       NextRec := Compare ;

       QuitFlag := false ;
       While NOT QuitFlag do
          begin
            UpdateInfoLine ;

            RMB_Event := false ;
            Match := true ;
            UpDown[1] := Down1 ;
            UpDown[2] := Down2;
            Repeat
              Event_Loop ;
            Until RMB_Event ;

            if Match then
               begin
                 i := 1 ;
                 MatchRec := S_FirstRec[ScrNum] ;
                 While MatchRec <> nil do
                    if MatchRec = S_CurrentRec[ScrNum] then
                       MatchRec := nil
                    else
                       begin
                         MatchRec := MatchRec^.Next ;
                         i := i + 1 ;
                       end ;
                 NextRec^.Match := i ;
               end ;

            if CurRec <> nil then
               if CurRec^.Next <> nil then
                  begin
                    CurRec := CurRec^.Next ;
                    NextRec := NextRec^.Next ;
                  end ;
          end ;
       Mode := 2 ;
       ClrHome ;
     end ;

{ *************************************************************************
     Retrieve a disk base database.
************************************************************************* }
  procedure RetrieveFile(DispFlag : boolean) ;

    var
       CurRec     : DataPtr ;
       ScrRec     : array[1..2] of ScrPtr ;
       TitleStr,
       TypeStr,
       SizeStr    : Str255 ;
       InputStr   : Str255 ;
       SaveFv     : text ;
       TempChar   : char ;
       Location,
       i,
       MaxLength,
       NumFields  : short_integer ;
       NoMatch    : boolean ;
       Compare,
       NextRec    : IntPtr ;
       SaveIO_Result : short_integer ;
       Size       : short_integer ;
       
     Label
       1 ;
       
     begin
       IO_Check(false) ;
       Reset(SaveFv, DefFileDat) ;
       SaveIO_Result := IO_Result ;
       if SaveIO_Result <> 0 then GoTo 1 ;
       NumFields := 0 ;
       
       TitleStr := '' ;
       i := 1 ;
       
       Readln(SaveFv, InputStr) ;
       if InputStr <> 'DataBase' then
          begin
            SaveIO_Result := 1 ;
            GoTo 1 ;
          end ;
               
       if DispFlag then
          D_DisposeRecs(D_FirstRec[DataNum], D_CurrentRec[DataNum], 
                        D_LastRec[DataNum]) ;
          
       Repeat
         Readln(SaveFv, InputStr) ;
         SaveIO_Result := IO_Result ;
         if SaveIO_Result <> 0 then GoTo 1 ;
         { Read ^A -- End of Screen Data }
         Case i of
            1 : TitleStr := InputStr ;
            2 : TypeStr  := InputStr ;
            3 : begin
                  SizeStr  := InputStr ;
                  ReadV(SizeStr, Size) ;
                end ;
          end ;
            
         i := i + 1 ;
         if i > 3 then
            begin
              AddARec(S_FirstRec[Import],S_CurrentRec[Import],
                      S_LastRec[Import], S_LastRec[Import], TitleStr, 
                      0, 0, Size, TypeStr[1], Import ) ;
              NumFields := NumFields + 1 ;
              Int_AddARec(C_FirstRec, C_CurRec, C_LastRec, NumFields) ;
              i := 1 ;
            end ;
       Until TitleStr = chr($01) ;
          
       NoMatch := false ;
       ScrRec[ScrNum] := S_FirstRec[ScrNum] ;
       ScrRec[Import] := S_FirstRec[Import] ;
       While (ScrRec[ScrNum] <> nil) AND 
             (ScrRec[Import] <> nil) AND NOT NoMatch do
          begin
            if ScrRec[Import]^.LabelStr <> ScrRec[ScrNum]^.LabelStr then 
               NoMatch := true ;
 
            if ScrRec[Import]^.DataType <> ScrRec[ScrNum]^.DataType then 
               NoMatch := true ;

            if ScrRec[Import]^.Size <> ScrRec[ScrNum]^.Size then 
               NoMatch := true ;

            ScrRec[ScrNum] := ScrRec[ScrNum]^.Next ;
            ScrRec[Import] := ScrRec[Import]^.Next ;
          end ;
                
       if ((ScrRec[Import] <> ScrRec[ScrNum]) OR NoMatch) AND
          (SaveIO_Result = 0) then
          begin
            for i := 1 to 2 do
                Menu_Disable(InfoMenu, MenuItem.Item[i]) ;
            FindMatch(S_FirstRec[Import], C_FirstRec ) ;
            MenuOption ;
          end ;

       While NOT EOF(SaveFv) AND NOT FullMemory do
          begin
            InputDataRec(DataNum) ;
            ScrRec[Import] := S_FirstRec[Import] ;
            CurRec := D_CurrentRec[DataNum] ;
            NextRec := C_FirstRec ;
             
            While ScrRec[Import] <> nil do
               begin
                 Readln(SaveFv, InputStr) ;
                 SaveIO_Result := IO_Result ;
                 if SaveIO_Result <> 0 then GoTo 1 ;
                 ScrRec[ScrNum] := S_FirstRec[ScrNum] ;
                 if NextRec^.Match > 0 then
                    begin
                      if NextRec^.Match > 1 then
                         for i := 2 to NextRec^.Match do
                             ScrRec[ScrNum] := ScrRec[ScrNum]^.Next ;
                      MaxLength := ScrRec[ScrNum]^.Size ;
                      if MaxLength > Length(InputStr) then
                         MaxLength := Length(InputStr) ;
                      for i := 1 to MaxLength do
                          begin
                            TempChar := InputStr[i] ;
                            Location := i + ScrRec[ScrNum]^.Offset - 1 ;
                            ModifyStr(CurRec, Location, TempChar) ;
                          end ;
                    end ;
                 NextRec := NextRec^.Next ;
                 ScrRec[Import] := ScrRec[Import]^.Next ;
               end ;
          end ;

1 :     if SaveIO_Result <> 0 then 
           DiskError(SaveIO_Result) ;

        if FullMemory then
           begin
             AlertStr := '[1][  Insufficient Memory to | ' ;
             AlertStr := Concat(AlertStr,' |   Load Entire DataBase ]') ;
             AlertStr := Concat(AlertStr, '[ Continue ]') ;
             Result := Do_Alert(AlertStr,1) ;
           end ;

       Close(SaveFv) ;
       if SaveIO_Result = 0 then
          begin
            D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
            RecNo[DataNum] := 1 ;

            ModifyWName ;
            UpdateFlag := true ; ;
            Set_VSlideSize ;
          end ;

       if D_FirstRec[DataNum] = nil then
          CreateDataRec(DataNum) ;
       DisposeRecs(S_FirstRec[Import], S_CurrentRec[Import], 
                   S_LastRec[Import]) ;
       DisposeInt(C_FirstRec, C_CurRec, C_LastRec) ;

       DrawScreen(S_FirstRec[ScrNum]) ;
       DrawRecord(D_CurrentRec[DataNum]) ;
       ShortDraw := true ;
       IO_Check(true) ;
     end ;

{ *************************************************************************
     Retrieve a database from the disk.
************************************************************************* }
  procedure MergeDataBase ;

     begin
       if Get_In_File(DefPathDat, DefFileDat) then
          RetrieveFile(False) ;
     end ;


{ *************************************************************************
     Retrieve a database from the disk.
************************************************************************* }
  procedure GetDataBase ;

     begin
       if Get_In_File(DefPathDat, DefFileDat) then
          RetrieveFile(True) ;
     end ;

{ *************************************************************************
************************************************************************* }
  procedure GetPrtInfo ;
     
    var
       ScrRec    : ScrPtr ;
       ReportRec : DataPtr ;
       PrintFv   : text ;
       i, 
       Location  : short_integer ;
       TempChar  : char ;
       SaveIO_Result : short_integer ;
       
     Label
       1 ;
       
     begin
       IO_Check(false) ;
       if Get_In_File(DefPathPrt, DefFilePrt) then
          begin
            Reset(PrintFv, DefFilePrt) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            
            Readln(PrintFv, FormatStr) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            if FormatStr <> 'ReportDesign' then
               begin
                 SaveIO_Result := 1 ;
                 GoTo 1 ;
               end ;
               
            ReportRec := D_FirstRec[Report] ;
            ScrRec := S_FirstRec[Report] ;
            While ScrRec <> nil do
              begin
                Readln(PrintFv, FormatStr) ;
                SaveIO_Result := IO_Result ;
                if SaveIO_Result <> 0 then GoTo 1 ;
                for i := 1 to Length(FormatStr) do
                    begin
                      TempChar := FormatStr[i] ;
                      Location := i + ScrRec^.Offset - 1 ;
                      ModifyStr(ReportRec, Location, TempChar) ;
                    end ;
                ScrRec := ScrRec^.Next ;
              end ;
              
            Readln(PrintFv, P_Mode) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            Readln(PrintFv, RepWidth) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            for i := 1 to 4 do
                begin
                  Readln(PrintFv, PrtInit[i]) ;
                  SaveIO_Result := IO_Result ;
                  if SaveIO_Result <> 0 then GoTo 1 ;
                end ;
                
            Readln(PrintFv, RepLine) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
             
            Readln(PrintFv, LabSpace[1]) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            
            Readln(PrintFv, LabLine) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
             
            Readln(PrintFv, LabSpace[2]) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            R_EditFlag := false ;
            R_LoadFlag := true ;
            
1 :         if SaveIO_Result <> 0 then   
               DiskError(SaveIO_Result) ;
            Close(PrintFv) ;
          end ;
       IO_Check(true) ;
     end ;

{ *************************************************************************
************************************************************************* }
  procedure SavePrtInfo ;
     
    var
       i         : short_integer ;
       ScrRec    : ScrPtr ;
       ReportRec : DataPtr ;
       PrintFv   : text ;
       SaveIO_Result : short_integer ;
       
     Label
       1 ;
       
     begin
       IO_Check(FALSE) ;
       if Get_In_File(DefPathPrt, DefFilePrt) then
          begin
            Rewrite(PrintFv, DefFilePrt) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            Writeln(PrintFv, 'ReportDesign') ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            ReportRec := D_FirstRec[Report] ;
            ScrRec := S_FirstRec[Report] ;
            While ScrRec <> nil do
              begin
                GetStr(ReportRec,FormatStr,ScrRec^.Offset,ScrRec^.Size ) ;
                Writeln(PrintFv, FormatStr) ;
                SaveIO_Result := IO_Result ;
                if SaveIO_Result <> 0 then GoTo 1 ;
                ScrRec := ScrRec^.Next ;
              end ;
              
            Writeln(PrintFv, P_Mode) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            Writeln(PrintFv, RepWidth) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;

            for i := 1 to 4 do
                begin
                  Writeln(PrintFv, PrtInit[i]) ;
                  SaveIO_Result := IO_Result ;
                  if SaveIO_Result <> 0 then GoTo 1 ;
                end ;
                  
            Writeln(PrintFv, RepLine) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            Writeln(PrintFv, LabSpace[1]) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            Writeln(PrintFv, LabLine) ;
            SaveIO_Result := IO_Result ;
            if SaveIO_Result <> 0 then GoTo 1 ;
            Writeln(PrintFv, LabSpace[2]) ;
            SaveIO_Result := IO_Result ;
            
1 :         if SaveIO_Result <> 0 then 
               DiskError(SaveIO_Result) ;
            
            R_EditFlag := false ;
            R_LoadFlag := true ;
            Close(PrintFv) ;
          end ;
       IO_Check(true) ;
     end ;

BEGIN
END .
