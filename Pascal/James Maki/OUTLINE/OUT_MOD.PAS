{$M+}
{$E+}

program Output_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }


 Var
      {$I B:MOD_VAR.PAS }


   procedure SetPtLabel( WindNo : short_integer );
      External ;

   procedure Draw_Window(CurRec : WordPointer ; 
                           WindMsg, LineNo : short_integer ) ;
      External ;

   procedure Draw_Buffer(CurRec : WordPointer ; WindMsg : short_integer ) ;
      External ;

   procedure AddARec(Var CurRec : WordPointer ; NewWord : Str255 ) ;
      External ;

   procedure LevelConvert(CurRec : WordPointer ; Var S : Str255);
      External ;

   procedure DiskFreeMem(Var DiskInfo : DiskRec ; Drive : short_integer ) ;   
      GemDos( $36 ) ;


  procedure ResetWindow(DrawFlag : boolean ) ;

   var
       i,
       Counter : short_integer ;
       CurRec  : WordPointer ;

    procedure ChkCursorPos ;

     var
         i : short_integer ;
         FormatStr : Str255 ;

      begin
        if YPos[Module] + VertOffset[Module] > TotalRec[Module] then
           begin
             VertOffset[Module] := TotalRec[Module] - NumLines ;
             if VertOffset[Module] < 0 then 
                begin
                  VertOffset[Module] := 0 ;
                  YPos[Module] := TotalRec[Module] ;
                end ;
           end ;
      end ;

    begin
      ChkCursorPos ;
      if TotalRec[Module] = 0 then
         begin
           ScrFirstRec[Module] := nil ;
           FirstRec[Module]    := nil ;
           LastRec[Module]     := nil ;
           Current[Module]     := nil ;
           YPos[Module]        := 1 ;
           XPos[Module]        := 1 ;
         end
      else
         if DrawFlag then
            begin
              Counter := 0 ;
              CurRec := Current[Module] ;
              While CurRec^.Prev <> nil do
                 begin
                   Counter := Counter + 1 ;
                   CurRec := CurRec^.Prev ;
                 end ;
              VertOffset[Module]  := Counter ;
              YPos[Module]        := 1 ;
              ScrFirstRec[Module] := Current[Module] ;
              Counter := NumLines DIV 2 ;
              While (Counter > 0) AND (VertOffset[Module] > 1) AND
                    (ScrFirstRec[Module]^.Prev <> nil) do
                 begin
                   VertOffset[Module] := VertOffset[Module] - 1 ;
                   Counter := Counter - 1 ;
                   YPos[Module] := YPos[Module] + 1 ;
                   ScrFirstRec[Module] := ScrFirstRec[Module]^.Prev ;
                 end ;
              if XPos[Module] > Length(Current[Module]^.NewWord) then
                 XPos[Module] := Length(Current[Module]^.NewWord) + 1 ;
              if XPos[Module] = 0 then XPos[Module] := 1 ;
            end
         else
            begin
              CurRec := FirstRec[Module] ;
              for i := 1 to VertOffset[Module] do
                  CurRec := CurRec^.Next ;

              ScrFirstRec[Module] := CurRec ;
              for i := 1 to YPos[Module] - 1 do
                  CurRec := CurRec^.Next ;
              Current[Module] := CurRec ;
              if XPos[Module] > Length(Current[Module]^.NewWord) then
                 XPos[Module] := Length(Current[Module]^.NewWord) + 1 ;
              if XPos[Module] = 0 then XPos[Module] := 1 ;
            end ;

      SetPtLabel( Module ) ;
      if DrawFlag then
         Draw_Window(ScrFirstRec[Module], Module, 1)
      else
         Draw_Window(Current[Module], Module, YPos[Module]) ;
    end ;

  procedure HideBlk ;
  
   var
       EndRec,
       CurRec : WordPointer ;

     begin
       if BlkMark[1] <> nil then
          begin
            CurRec := BlkMark[1] ;

             repeat
               CurRec^.Buffer := false ;
               EndRec := CurRec ;
               CurRec := CurRec^.Next ;
             Until EndRec = BlkMark[2] ;

            BlkMark[1] := nil ;
            Draw_Buffer(ScrFirstRec[Module], Module ) ;
          end ;
     end ;

  procedure DisposeBuffer ;
  
   var
       NextRec,
       CurRec : WordPointer ;

     begin
       if BlkBuffer <> nil then
          begin
            CurRec := BlkBuffer ;

             repeat
               NextRec := CurRec ;
               Dispose(CurRec) ;
               CurRec := NextRec^.Next ;
               TotRec := TotRec - 1 ;
             Until NextRec = BlkLast ;

            BlkBuffer := nil ;
            BlkLast   := nil ;
            BlkSize   := 0 ;
          end ;
     end ;

  procedure DisposeBlk ;
  
   var
       NextRec,
       CurRec : WordPointer ;

     begin
       if BlkMark[1] <> nil then
          begin
            CurRec := BlkMark[1] ;

             repeat
               NextRec := CurRec ;
               Dispose(CurRec) ;
               CurRec := NextRec^.Next ;
               TotRec := TotRec - 1 ;
               TotalRec[BlkModule] := TotalRec[BlkModule] - 1 ;
             Until NextRec = BlkMark[2] ;

           BlkMark[1] := nil ;
          end ;
     end ;

    procedure BlockOrder(FirstRec, SecondRec : WordPointer ;
                         Var BlkSize, Order : short_integer ) ;

      var
         CurRec   : WordPointer ;
         BlkFound : boolean ;
      
       begin
         CurRec := FirstRec ;
         BlkSize := 0 ;
         BlkFound := false ;
         While CurRec <> nil do
           begin
             if CurRec = SecondRec then
                begin
                  CurRec := nil ;
                  BlkFound := true ;
                  Order := 1 ;
                end
             else
                CurRec := CurRec^.Next ;
             BlkSize := BlkSize + 1 ;
           end ;
         if NOT BlkFound then
            begin
              CurRec := SecondRec ;
              BlkSize := 0 ;
              
              While CurRec <> nil do
                begin
                  if CurRec = FirstRec then
                     begin
                       CurRec := nil ;
                       BlkFound := true ;
                       Order := 2 ;
                     end
                  else
                     CurRec := CurRec^.Next ;
                  BlkSize := BlkSize + 1 ;
                end ;
              if NOT BlkFound then
                 Order := 3 ;
            end ;
       end ;

   procedure MoveBlkBuffer(FirstRec, SecondRec : WordPointer) ;
   
     var
          SaveRec,
          CurRec,
          NewRec  : WordPointer ;
     
       begin
         CurRec := FirstRec ;
         if BlkSize + TotRec < MaxRec then
            repeat
               new(NewRec) ;
               if BlkBuffer  = nil then
                  BlkBuffer := NewRec ;
               NewRec^.NewWord := CurRec^.NewWord ;
               NewRec^.Next    := nil ;
               NewRec^.Prev    := BlkLast ;
               NewRec^.Level   := CurRec^.Level ;
               NewRec^.PtLabel := CurRec^.PtLabel ;
               NewRec^.Buffer  := false ;
               CurRec^.Buffer  := true ;
               if NewRec^.Prev <> nil then
                  NewRec^.Prev^.Next := NewRec ;
               BlkLast := NewRec ;
               TotRec  := TotRec + 1 ;
               SaveRec := CurRec ;
               if CurRec <> nil then
                  CurRec := CurRec^.Next ;
            Until SaveRec = SecondRec ;
       end ;

  procedure MarkBlk ;
  
    var
         SaveRec  : WordPointer ;
         Order    : short_integer ;

     begin
       if (BlkMark[1] = nil) OR
          (BlkMark[2] <> nil) OR
          (BlkModule <> Module) then
          begin
            HideBlk ;
            DisposeBuffer ;
            BlkMark[1] := Current[Module];
            BlkMark[2] := nil ;
            BlkModule  := Module ;
          end
       else
          begin
            BlkMark[2] := Current[Module] ;
            BlockOrder(BlkMark[1], BlkMark[2],
                       BlkSize, Order) ;
            if Order = 2 then
               begin
                 SaveRec := BlkMark[1] ;
                 BlkMark[1] := BlkMark[2] ;
                 BlkMark[2] := SaveRec ;
               end ;

            if Order <> 3 then
               MoveBlkBuffer(BlkMark[1], BlkMark[2])
            else
               Write('Error in Block Mark Routine') ;
            Draw_Buffer(ScrFirstRec[Module], Module ) ;
          end ;
     end ;

  procedure CutBlk ;
  
     begin
       if (BlkMark[1] <> nil) AND (Module = BlkModule) then
          begin
            if FirstRec[BlkModule] = BlkMark[1] then
               FirstRec[BlkModule] := BlkMark[2]^.Next 
            else
               BlkMark[1]^.Prev^.Next := BlkMark[2]^.Next ;
          
            if LastRec[BlkModule] = BlkMark[2] then
               LastRec[BlkModule] := BlkMark[1]^.Prev
            else
               BlkMark[2]^.Next^.Prev := BlkMark[1]^.Prev ;

            if Current[Module]^.Buffer then
               begin
                 if BlkMark[1]^.Prev <> nil then
                    Current[Module] := BlkMark[1]^.Prev
                 else
                    Current[Module] := BlkMark[2]^.Next ;
               end ;
            DisposeBlk ;
            ResetWindow(true) ;

            EditFlag[BlkModule]  := true ;
          end ;
     end ;

  procedure PasteBlk ;
  
   var
       BeginBuf,
       EndBuf,
       SaveRec,
       CurRec : WordPointer ;
  
     begin
       if BlkBuffer <> nil then
          begin
            if FirstRec[Module] = nil then
               AddARec(FirstRec[Module], '' ) ;
            if Current[Module] = FirstRec[Module] then
               begin
                 FirstRec[Module] := BlkBuffer ;
                 BlkBuffer^.Prev := nil ;
               end
            else
               begin
                 Current[Module]^.Prev^.Next := BlkBuffer ;
                 BlkBuffer^.Prev := Current[Module]^.Prev ;
               end ;

           { BlkLast Pointer }
            BlkLast^.Next := Current[Module] ;
            Current[Module]^.Prev := BlkLast ;
            TotalRec[Module] := TotalRec[Module] + BlkSize ;

            BeginBuf  := BlkBuffer ;
            EndBuf    := BlkLast ;
            BlkBuffer := nil ;
            BlkLast   := nil ;
            MoveBlkBuffer(BeginBuf, EndBuf ) ;
 
            CurRec := BeginBuf ;
             Repeat
               SaveRec := CurRec ;
               CurRec^.Buffer := false ;
               CurRec := CurRec^.Next ;
             Until SaveRec = EndBuf ;
          
            ResetWindow(false) ;
            EditFlag[Module] := true ;
          end ;
     end ;

  procedure DeleteBlk ;
  
     begin
       if Module = BlkModule then
          begin
            CutBlk ;
            DisposeBuffer ;
            EditFlag[Module] := true ;
          end ;
     end ;
     
  procedure PrintOutline ;

   var
       i         : short_integer ;
       CurRec    : WordPointer ;
       ResultStr,
       FormatStr : Str255 ;
       LineNo,
       PageNo    : short_integer ;
       CurSpace  : short_integer ;
  
  procedure PageTop ;

    var
        i : short_integer ;

     begin
       for i := 1 to 2 do
           Writeln ;
       if PageNo = 1 then
          Writeln('':(40 - Length(FileTitle[Module]) DIV 2),
                  FileTitle[Module])
       else
          Writeln ;
       for i := 1 to 2 do
           Writeln ;
       LineNo := 1 ;
     end ;
    
  procedure PageBottom ;
  
    var
        i : short_integer ;

     begin
       for i := 1 to 2 do
           Writeln ;
       Writeln(PageNo:41) ;
       for i := 1 to 2 do
           Writeln ;
       PageNo := PageNo + 1 ;
       LineNo := 0 ;
     end ;

  procedure SplitLine(Var OrigStr, NewStr : Str255 ;
                      Var Len : short_integer ) ;

    var
        i,
        SpPos   : short_integer ;
        SaveStr : Str255 ;
        SpChk   : string[1] ;

     begin
       SaveStr := OrigStr ;
       SpPos   := 0 ;
       for i := 0 to CurSpace do
           begin
             SpChk := Copy(SaveStr,80 - i,1) ;
             if SpChk = chr($20) then
                begin
                  SpPos := 80 - i ;
                  i := 80 ;
                end ;
           end ;
       if SpPos = 0 then SpPos := 80 ;
       OrigStr := Copy(SaveStr,1,SpPos) ;
       NewStr  := Copy(SaveStr,SpPos + 1, Len - SpPos) ;
       SaveStr := NewStr ;
       WriteV(NewStr, ' ':CurSpace, SaveStr) ;
       Len     := Length(NewStr) ;
     end ;

  procedure PrintLine ;

    var
        Len      : short_integer ;
        LineTwo  : Str255 ;
  
     begin
       LineNo := LineNo + 1 ;
       LevelConvert(CurRec, ResultStr) ;
       CurSpace := CurRec^.Level * 3 + 17 ;
       WriteV(FormatStr, ResultStr:CurSpace,CurRec^.NewWord) ;
       Len := Length(FormatStr) ;
       if Len > 80 then
          begin
            Repeat
              SplitLine(FormatStr, LineTwo, Len) ;
              Writeln(FormatStr) ;
              FormatStr := LineTwo ;
              LineNo := LineNo + 1 ;
            Until Len < 80 ;
            Writeln(LineTwo) ;
          end
       else
          Writeln(FormatStr) ;
       CurRec := CurRec^.Next ;
     end ;
       
    begin
       if Module > 0 then
          begin
            PageNo := 1 ;
            LineNo := 0 ;
            Rewrite(OUTPUT, 'LST:') ;
            CurRec := FirstRec[Module] ;
            While CurRec <> nil do
              begin
                if LineNo = 0 then
                   PageTop
                else
                   if LineNo > 56 then
                      PageBottom
                   else
                      PrintLine ;
              end ;
            for i := LineNo to 56 do
                Writeln ;
            PageBottom ;
            Rewrite(OUTPUT, 'CON:') ;
          end ;
     end ;
     
  procedure DiskPrint ;

    var
        i,
        PeriodPos  : short_integer ;
        FileName   : Path_Name ;
        SaveFv     : text ;
        CurRec     : WordPointer ;
        DiskState  : DiskRec ;
        DiskMemory : long_integer ;
        FormatStr  : Str255 ;
        FileSize   : long_integer ;
        ResultStr,
        AlertStr   : Str255 ;
        Result     : short_integer ;
        DiskDrive  : string[1] ;
        DriveNo    : short_integer ;
        ResultFlag : boolean ;

  
     begin
       Set_Mouse(M_Bee) ;
       PeriodPos := Pos('.', WindName[Module]) ;
       if PeriodPos > 0 then
          FileName := Copy(WindName[Module],2,PeriodPos - 2 ) ;
       FileName := Concat(FileName, '.TXT') ;

       DiskDrive := Copy(FileName,1,1) ;
       for i := $41 to $5A do
           if Chr(i) = DiskDrive then
              DriveNo := i - $40 ;
                   
        DiskFreeMem(DiskState, DriveNo) ;
        With DiskState do
             DiskMemory := FreeCluster * (SectorSize * ClusterSize) ;
        FileSize := SizeOf(WordRecord) * TotalRec[Module] ;

        if FileSize < DiskMemory then
           begin
             Rewrite(SaveFv, FileName) ;
             CurRec := FirstRec[Module] ;
             While CurRec <> nil do
               begin
                 LevelConvert(CurRec, ResultStr) ;
                 WriteV(FormatStr, ResultStr:CurRec^.Level * 3 + 17,
                        CurRec^.NewWord) ;
                 Writeln(SaveFv, FormatStr) ;
                 CurRec := CurRec^.Next ;
               end ;
           end
        else
           With DiskState do
               begin
                 AlertStr := '[1][ Insufficient Disk Space |' ;
                 AlertStr := Concat(AlertStr,'       to Save File ]') ;
                 AlertStr := Concat(AlertStr, '[ Continue ]') ;
                 Result := Do_Alert(AlertStr,1) ;
               end ;
        Set_Mouse(M_Arrow) ;
     end ;
     

BEGIN
END.
