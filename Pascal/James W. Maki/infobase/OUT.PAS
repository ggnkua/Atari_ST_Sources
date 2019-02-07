{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program Output_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{  ******************************  External ***************************** }
  procedure GetStr(CurRec   : DataPtr ; Var DisplayStr : Str255 ;
                   StartPos, Size : short_integer ) ;
     External ;

  procedure AddARec(Var FirstRec, CurRec, LastRec, ScrRec : ScrPtr ;
                        TitleStr : Str255 ;
                        XCur, YCur, Size : short_integer ;
                        DataType : char ; ScrNum : short_integer) ;
     External ;

  procedure DisposeRecs(Var FirstRec, CurRec, LastRec : ScrPtr ) ;
     External ;

  procedure IncrementRec(Var  CurRec : DataPtr ; Value : short_integer ;
                              DrawFlag : boolean ) ;
     External ;
{ ********************************  Output  ***************************** }

  procedure FormatOutput ;

    var
       i, j, 
       ScrOffset,
       LastLetter : short_integer ;
       ScrRec    : ScrPtr ;
       ScrRecI   : ScrPtr ;
       DataRec   : DataPtr ;
       CheckChar : char ;
       CollectStr: Str255 ;
  
     begin
       ScrRec := S_FirstRec[Report] ;
       DataRec := D_FirstRec[Report] ;
       While ScrRec <> nil do
          begin
            GetStr(DataRec, FormatStr, ScrRec^.Offset, ScrRec^.Size ) ;
            CollectStr := '' ;

            for j := 1 to RepWidth do
                if FormatStr[j] <> chr($20) then
                   LastLetter := j ;

            for j := 1 to LastLetter do
                begin
                  CheckChar := FormatStr[j] ;
                  if ord(CheckChar) > $7F then
                     begin
                       AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                               S_LastRec[Import], S_LastRec[Import], 
                               CollectStr, 0, 0, 1, 'A', Import) ;
                       CollectStr := '' ;

                       ScrOffset := ord(CheckChar) - $7F ;
                       ScrRecI := S_FirstRec[ScrNum] ;
                       for i := 2 to ScrOffset do
                           ScrRecI := ScrRecI^.Next ;
                       j := j + ScrRecI^.Size - 1 ;
                                                  
                       AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                               S_LastRec[Import], S_LastRec[Import], 
                               '', ScrOffset, 0, 1, 'A', Import) ;
                     end 
                  else
                  
                     if ord(CheckChar) = $40 then
                        begin
                          AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                                  S_LastRec[Import], S_LastRec[Import], 
                                  CollectStr, 0, 0, 1, 'A', Import) ;
                          CollectStr := CheckChar ;
                        end
                     else
                     
                     begin
                       CollectStr := Concat(CollectStr, CheckChar) ;
                       if Length(CollectStr) > 19 then
                          begin
                            AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                                    S_LastRec[Import], S_LastRec[Import], 
                                    CollectStr, 0, 0, 1, 'A', Import) ;
                            CollectStr := '' ;
                          end ;
                     end ;          
                end ;
            if Length(CollectStr) > 0 then
               AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                       S_LastRec[Import], S_LastRec[Import], 
                       CollectStr, 0, 0, 1, 'A', Import) ;

            ScrRec := ScrRec^.Next ;
            AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                    S_LastRec[Import], S_LastRec[Import], 
                    '', 0, 1, 1, 'A', Import) ;
          end ;
     end ;

  procedure FormatOutput1( Var Start, Count : short_integer) ;

    var
       i, j, k,
       ScrOffset,
       LastLetter : short_integer ;
       ScrRec    : ScrPtr ;
       ScrRecI   : ScrPtr ;
       DataRec   : DataPtr ;
       CheckChar : char ;
       CollectStr: Str255 ;
       BlankFlag : boolean ;
       

     begin
       Case RepLine of
           1 : begin
                 Start := 5 ;  { 4 }
                 Count := 1 ;
               end ;
           2 : begin
                 Start := 5 ;  { 4 }
                 Count := 2 ;
               end ;
           3 : begin
                 Start := 5 ;  { 4 }
                 Count := 3 ;
               end ;
           4 : begin
                 Start := 4 ;  { 3 }
                 Count := 4 ;
               end ;
       end ;
       
       ScrRec := S_FirstRec[Report] ;
       for i := 1 to Start do
           ScrRec := ScrRec^.Next ;
       DataRec := D_FirstRec[Report] ;
       for i := 1 to Count do
          begin
            GetStr(DataRec, FormatStr, ScrRec^.Offset, ScrRec^.Size ) ;
            BlankFlag := false ;
            for j := 1 to RepWidth do
                if FormatStr[j] <> chr($20) then
                   begin
                     BlankFlag := true ;
                     LastLetter := j ;
                   end ;
            CollectStr := '' ;
            if BlankFlag then
               for j := 1 to LastLetter do
                   begin
                     CheckChar := FormatStr[j] ;
                     if ord(CheckChar) > $7F then
                        begin
                          if Length(CollectStr) > 0 then
                            begin
                             AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                                     S_LastRec[Import], S_LastRec[Import], 
                                     CollectStr, 0, 0, 1, 'A', Import) ;
                             CollectStr := '' ;
                            end ;

                          ScrOffset := ord(CheckChar) - $7F ;
                          ScrRecI := S_FirstRec[ScrNum] ;
                          k := 2 ;
                          while (k <= ScrOffset) AND (ScrRecI <> nil) do
                             begin
                               ScrRecI := ScrRecI^.Next ;
                               k := k + 1 ;
                             end ;
                          if ScrRecI <> nil then
                             begin
                               j := j + ScrRecI^.Size - 1 ;
                               AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                                       S_LastRec[Import], S_LastRec[Import], 
                                       '', ScrOffset, 0, 1, 'A', Import) ;
                             end
                          else
                             begin
                               CollectStr := Concat(CollectStr, ' ') ;
                               j := j + 1 ;
                             end ;
                        end 
                     else
                  
                     if ord(CheckChar) = $40 then
                        begin
                          AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                                  S_LastRec[Import], S_LastRec[Import], 
                                  CollectStr, 0, 0, 1, 'A', Import) ;
                          CollectStr := CheckChar ;
                        end
                     else
                     
                        begin
                          CollectStr := Concat(CollectStr, CheckChar) ;
                          if Length(CollectStr) > 19 then
                             begin
                               AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                                       S_LastRec[Import], S_LastRec[Import], 
                                       CollectStr, 0, 0, 1, 'A', Import) ;
                               CollectStr := '' ;
                             end ;
                        end ;          
                   end ;
            if Length(CollectStr) > 0 then
               AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                       S_LastRec[Import], S_LastRec[Import], 
                       CollectStr, 0, 0, 1, 'A', Import) ;
            ScrRec := ScrRec^.Next ;
            if BlankFlag then
               AddARec(S_FirstRec[Import], S_CurrentRec[Import],
                       S_LastRec[Import], S_LastRec[Import], 
                       '', 0, 1, 1, 'A', Import) ;
          end ;
     end ;


  procedure PrintARec(DataRec : DataPtr ; 
                      Var LineNo, PageNo, RecNo : short_integer) ;
  
    var
       CurRec,
       ScrRec : ScrPtr ;

       i, j,
       CommandPos : short_integer ;
       PrintStr,
       CommandStr : Str255 ;
       ComStr     : array[1..2] of Str255 ;
       Month,
       Day,
       Year       : short_integer ;

       Start,
       Count      : short_integer ;
       NoSpace    : boolean ;
       
       StopValue  : short_integer ;

     begin
       for i := 1 to LabSpace[1] do
           Writeln(Printer) ;
       ScrRec := S_FirstRec[Import] ;
       NoSpace := false ;
       LineNo := 1 ;
       While ScrRec <> nil do
         begin
           PrintStr := ScrRec^.LabelStr ;
           if ScrRec^.X <> 0 then
              begin
                CurRec := S_FirstRec[ScrNum] ;
                for i := 2 to ScrRec^.X do
                    CurRec := CurRec^.Next ;
                GetStr(DataRec, FormatStr, CurRec^.Offset, CurRec^.Size ) ;
                Write(Printer, FormatStr) ;
                if NOT NoSpace then
                   begin
                     for i := Length(FormatStr) to CurRec^.Size - 1 do
                         Write(Printer, ' ') ;
                   end ;
              end
           else
              if ScrRec^.Y <> 0 then
                 begin
                   Writeln(Printer) ;
                   LineNo := LineNo + 1 ;
                   if LineNo > LabLine then
                      ScrRec := nil ;
                 end 
              else
                 repeat
                   CommandPos := Pos('@', PrintStr) ;
                   if CommandPos > 0 then
                      begin
                        CommandStr := Copy(PrintStr, 
                                           CommandPos + 1, 4) ; 
                        ComStr[1]  := Copy(PrintStr, 1, 
                                           CommandPos - 1) ;
                        ComStr[2]  := Copy(PrintStr, 
                                           CommandPos + 5, 
                                           Length(PrintStr) 
                                                  - CommandPos + 5) ;
                        Write(Printer, ComStr[1]) ;
                        if CommandStr = 'Page' then
                           Write(Printer, PageNo:5)
                        else

                        if CommandStr = 'Line' then
                           Write(Printer, LineNo:5)
                        else
                           if CommandStr = 'Date' then
                              begin
                                Get_Date(Month,Day,Year) ;
                                WriteV(FormatStr, Month,'/',Day,'/', Year) ;
                                for j := 1 to (10 - Length(FormatStr)) DIV 2 do
                                    Write(Printer, chr($20)) ;
                                Write(Printer, FormatStr) ;
                             end
                          else
                             if CommandStr = 'Rec#' then
                                Write(Printer, RecNo:5)
                             else
                                if CommandStr = 'Null' then
                                   NoSpace := true
                                else
                                   Write(Printer, '    ') ;
                        PrintStr := ComStr[2] ;
                      end
                   else
                      begin
                        Write(Printer, PrintStr) ;
                        PrintStr := '' ;
                      end ;
                 Until Length(PrintStr) < 1 ;

           if ScrRec <> nil then
              ScrRec := ScrRec^.Next ;
         end ;
       for i := 1 to LabSpace[2] do
           Writeln(Printer) ;
     end ;

  procedure PrintRec(DataRec : DataPtr ) ;

    var
       LineNo,
       PageNo,
       RecNo  : short_integer ;

     begin
       LineNo := 1 ;
       PageNo := 1 ;
       RecNo  := 1 ;
       FormatOutput ;
       PrintARec(DataRec, LineNo, PageNo, RecNo) ;
       DisposeRecs(S_FirstRec[Import], S_CurrentRec[Import],
                   S_LastRec[Import]) ;
     end ;

  procedure M_PrintRec ;

    var
       i       : short_integer ;
       DataRec : DataPtr ;
       LineNo,
       PageNo,
       RecNum     : short_integer ;
       SaveIntPtr : IntPtr ;
       SaveRecNo  : short_integer ;
       SaveFRecNo : short_integer ;

     begin
       LineNo := 1 ;
       PageNo := 1 ;
       RecNum := 1 ;
       FormatOutput ;
       SaveIntPtr := F_CurRec ;
       F_CurRec := F_FirstRec ;
       SaveFRecNo := F_RecNo[DataNum] ;
       SaveRecNo  := RecNo[DataNum] ;
       DataRec := D_FirstRec[DataNum] ;
       if F_FirstRec <> nil then
          for i := 2 to F_FirstRec^.Match do
              DataRec := DataRec^.Next ;

       While DataRec <> nil do
         begin
           PrintARec(DataRec, LineNo, PageNo, RecNum) ;
           IncrementRec(DataRec, 1, true) ;
           PageNo := PageNo + 1 ;
           RecNum := RecNum + 1 ;
         end ;

       DisposeRecs(S_FirstRec[Import], S_CurrentRec[Import],
                   S_LastRec[Import]) ;
       F_CurRec := SaveIntPtr ;
       F_RecNo[DataNum] := SaveFRecNo ;
       RecNo[DataNum]   := SaveRecNo ;
     end ;

  procedure PrintReport ;
  
    var
       DataRec    : DataPtr ;
       ScrRec,
       CurRec     : ScrPtr ;
       i, j,
       LineNo,
       PageNo,
       RecNum,
       CommandPos : short_integer ;
       PrintStr,
       CommandStr : Str255 ;
       ComStr     : array[1..2] of Str255 ;
       Month,
       Day,
       Year       : short_integer ;
       SaveIntPtr : IntPtr ;
       SaveRecNo  : short_integer ;
       SaveFRecNo : short_integer ;

       Start,
       Count      : short_integer ;
       NoSpace    : boolean ;
       
       StopValue  : short_integer ;

     procedure CommandLine(ModStr : Str255) ;
     
       var
          j : short_integer ;
          
        begin
         repeat
          CommandPos := Pos('@', ModStr) ;
          if CommandPos > 0 then
             begin
               CommandStr := Copy(ModStr, CommandPos + 1, 4) ;
               ComStr[1] := Copy(ModStr, 1, CommandPos - 1) ;
               ComStr[2] := Copy(ModStr, CommandPos + 5, 
                                 Length(ModStr) - CommandPos + 5) ;
               Write(Printer, ComStr[1]) ;
               if CommandStr = 'Page' then
                  Write(Printer, PageNo:5)
               else
                  if CommandStr = 'Date' then
                     begin
                       Get_Date(Month,Day,Year) ;
                       WriteV(ModStr, Month,'/',Day,'/', Year) ;
                       for j := 1 to (10 - Length(ModStr)) DIV 2 do
                           Write(Printer, chr($20)) ;
                       Write(Printer, ModStr) ;
                       Delete(ComStr[2], Length(ComStr[2]) - 5, 5) ;
                     end
                  else
                     if CommandStr = 'Line' then
                        Write(Printer, LineNo + (PageNo - 1) * 54:5)
                     else
                        if CommandStr = 'Rec#' then
                           Write(Printer, RecNum:5)
                        else
                           Write(Printer, '    ') ;
               ModStr := ComStr[2] ;
             end 
          else
             begin
               Writeln(Printer, ModStr) ;
               ModStr := '' ;
             end ;
         Until Length(ModStr) < 1 ;
        end ;

     procedure PageTop ;

       var
          i, j    : short_integer ;
          CurRec  : ScrPtr ;
          DataRec : DataPtr ;

        begin
          for i := 1 to 2 do
              Writeln(Printer) ;
          CurRec := S_FirstRec[Report] ;
          DataRec := D_FirstRec[Report] ;
          for i := 1 to Start do
              begin
                GetStr(DataRec, FormatStr, CurRec^.Offset, CurRec^.Size ) ;
                if RepWidth = 80 then
                   Delete(FormatStr, 78, 54) ;
                CommandLine(FormatStr) ;
                CurRec := CurRec^.Next ;
              end ;
        end ;

     procedure PageBottom ;

       var
          i, j    : short_integer ;
          CurRec  : ScrPtr ;
          DataRec : DataPtr ;

        begin
          CurRec := S_FirstRec[Report] ;
          for i := 1 to Start + Count do
              CurRec := CurRec^.Next ;
          DataRec := D_FirstRec[Report] ;
          for i := 1 to (10 - Count - Start) do
              begin
                GetStr(DataRec, FormatStr, CurRec^.Offset, CurRec^.Size ) ;
                if RepWidth = 80 then
                   Delete(FormatStr, 78, 54) ;
                CommandLine(FormatStr) ;
                CurRec := CurRec^.Next ;
              end ;
          for i := 1 to 2 do
              Writeln(Printer) ;
        end ;


     begin
       FormatOutput1(Start, Count) ;
       SaveIntPtr := F_CurRec ;
       SaveFRecNo := F_RecNo[DataNum] ;
       SaveRecNo  := RecNo[DataNum] ;
       DataRec := D_FirstRec[DataNum] ;
       F_CurRec := F_FirstRec ;
       if F_FirstRec <> nil then
          for i := 2 to F_FirstRec^.Match do
              DataRec := DataRec^.Next ;
       LineNo := 1 ;
       PageNo := 1 ;
       RecNum := 1 ;
       PageTop ;
       While DataRec <> nil do
          begin
            ScrRec := S_FirstRec[Import] ;
            NoSpace := false ;
            While ScrRec <> nil do
               begin
                 PrintStr := ScrRec^.LabelStr ;
                 if ScrRec^.X <> 0 then
                    begin
                      CurRec := S_FirstRec[ScrNum] ;
                      for i := 2 to ScrRec^.X do
                          CurRec := CurRec^.Next ;
                      GetStr(DataRec, FormatStr, 
                             CurRec^.Offset, CurRec^.Size ) ;
                      Write(Printer, FormatStr) ;
                      if NOT NoSpace then
                         for i := Length(FormatStr) to CurRec^.Size - 1 do
                             Write(Printer, ' ') ;
                    end
                 else
                    if ScrRec^.Y <> 0 then
                       begin
                         Writeln(Printer) ;
                         LineNo := LineNo + 1 ;
                         if ((LineNo > 54) AND (RepLine < 4)) OR
                            ((LineNo > 56) AND (RepLine = 4)) then
                            begin
                              PageBottom ;
                              PageNo := PageNo + 1 ;
                              PageTop ;
                              LineNo := 1 ;
                            end ;
                       end 
                    else
                       repeat
                         CommandPos := Pos('@', PrintStr) ;
                         if CommandPos > 0 then
                            begin
                              CommandStr := Copy(PrintStr, 
                                                 CommandPos + 1, 4) ; 
                              ComStr[1]  := Copy(PrintStr, 1, 
                                                 CommandPos - 1) ;
                              ComStr[2]  := Copy(PrintStr, 
                                                 CommandPos + 5, 
                                                 Length(PrintStr) 
                                                        - CommandPos + 5) ;
                              if CommandStr = 'Line' then
                                 Write(Printer, LineNo + (PageNo - 1) * 54:5)
                              else
                                 if CommandStr = 'Rec#' then
                                    Write(Printer, RecNum:5)
                                 else
                                    if CommandStr = 'Null' then
                                       NoSpace := true
                                    else
                                       Write(Printer, '    ') ;
                              PrintStr := ComStr[2] ;
                            end
                         else
                            begin
                              Write(Printer, PrintStr) ;
                              PrintStr := '' ;
                            end ;
                       Until Length(PrintStr) < 1 ;
                 ScrRec := ScrRec^.Next ;
              end ;
            IncrementRec(DataRec, 1, true) ;
            RecNum:= RecNum+ 1 ;
          end ;

       Case RepLine of
          1 : j := 54 ;
          2 : j := 54 ;
          3 : j := 55 ;
          4 : j := 56 ;
       end ;

       for i := LineNo to j do
           Writeln(Printer) ;
       PageBottom ;
       DisposeRecs(S_FirstRec[Import], S_CurrentRec[Import], 
                   S_LastRec[Import]) ;
       F_CurRec := SaveIntPtr ;
       F_RecNo[DataNum] := SaveFRecNo  ;
       RecNo[DataNum] := SaveRecNo  ;
     end ;


BEGIN
END .

