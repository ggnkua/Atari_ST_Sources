{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program SubRoutine_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{ ************************************************************************ }
{ *************************************************************************
     Subtracts memory from MaxMem to reflect decrease in Heap size due to
     New() calls.  RecSize is the size of a single record, in bytes.
************************************************************************* }
  procedure MinusMemAvail( RecSize : long_integer ) ;

      begin
        MaxMem := MaxMem - RecSize ;
        if MaxMem < 12000 then
           if NOT FullMemory then
              FullMemory := true ;
      end ;
      
{ *************************************************************************
     Adds memory back to MaxMem to reflect increase in Heap size due to
     Dispose() calls.  RecSize is the size of a single record, in bytes.
************************************************************************* }
  procedure PlusMemAvail( RecSize : long_integer ) ;

      begin
        MaxMem := MaxMem + RecSize ;
        if MaxMem > 11999 then
           FullMemory := false ;
      end ;

{ *************************************************************************
     Place the cursor in the first position of the first Screen Info
     Field.
************************************************************************* }
  procedure ClrHome ;
  
     begin
       S_CurrentRec[ScrNum] := S_FirstRec[ScrNum] ;
       S_CurrentRec[ScrNum]^.XInPos := 0 ;
       XCur := S_CurrentRec[ScrNum]^.XPos ;
       YCur := S_CurrentRec[ScrNum]^.YPos ;
       C_CurRec := C_FirstRec ;
     end ;

{ *************************************************************************     
     D_DisposeRecs will remove all Data Records and release the
     memory back to the system.
************************************************************************* }
  procedure D_DisposeRecs(Var FirstRec, CurRec, LastRec : DataPtr ) ;

    var
       DeleteRec    : DataPtr ;
       CurStoreRec,
       DelStoreRec  : DataStorePtr ;
        
     begin
       CurRec := FirstRec ;
       While CurRec <> nil do
          begin
            CurStoreRec := CurRec^.Data ;
            While CurStoreRec <> nil do
               begin
                 DelStoreRec := CurStoreRec ;
                 CurStoreRec := CurStoreRec^.Next ;
                 Dispose(DelStoreRec) ;
                 PlusMemAvail( DataRecSize ) ;
               end ;
            DeleteRec := CurRec ;
            CurRec    := CurRec^.Next ;
            TotalRec[DataNum] := TotalRec[DataNum] - 1 ;
            Dispose(DeleteRec) ;
            PlusMemAvail( PtrRecSize ) ;
          end ;
       CurRec   := nil ;
       FirstRec := nil ;
       LastRec  := nil ;
     end ;

{ *************************************************************************
     DetCurRec is used to calculate the member of the data storage linked
     list that is "Current".  This is accomplished by stepping through the
     list a number of times determined by the variable Location, which
     corresponds to the offset into the logical string.
************************************************************************* }
  procedure DetCurRec(    D_CurRec : DataStorePtr ;
                      Var CurRec   : DataStorePtr ;  
                      Var Location : short_integer ) ;

    Var
       Counter : short_integer ;
       
     begin
       Counter := Location DIV 50 ;
       CurRec := D_CurRec ;

       While Counter > 0 do
          begin
            CurRec := CurRec^.Next ;
            Counter := Counter - 1 ;
            Location := Location - 50 ;
          end ;
     end ;

{ *************************************************************************
     GetChar calls DetCurRec to find the correct Data storage member of
     the linked list, and then extracts the character represented by
     Position, the offset determined by the current cursor location.
************************************************************************* }
  procedure GetChar(      CurRec  : ScrPtr ;
                        D_CurRec  : DataPtr ; 
                    Var Character : StrChar ;
                        Position  : short_integer ) ;

    Var
       DataRec  : DataStorePtr ;

     begin
       if D_CurRec <> nil then
          begin
            DetCurRec(D_CurRec^.Data, DataRec, Position ) ;
            Character := Copy(DataRec^.DataStr, Position + 1, 1) ;
          end
       else
          Character := ' ' ;
     end ;

{ *************************************************************************
     CheckOverLap will check all of the records to make sure that
     no part of record or title will be obscured by two records
     occupying the same area.  OverLap will be returned as true if
     an overlap occurs and false if no overlap is present.
************************************************************************* }
  procedure CheckOverLap( NewRec : ScrPtr ; X, Y : short_integer ; 
                         Var OverLap : boolean ) ;

    var
        CurRec : ScrPtr ;

{ *************************************************************************
     CompareX compares two ScrPtr records to determine if their
     coordinants overlap.
************************************************************************* }
  procedure CompareX( FirstRec, SecondRec : ScrPtr ; 
                      XNew, XOld : short_integer ) ;

      begin
        if ((FirstRec^.Next = SecondRec) AND 
            (FirstRec^.DataType = 'H') AND
            (SecondRec^.DataType = 'D')) OR
           ((SecondRec^.Next = FirstRec) AND 
            (SecondRec^.DataType = 'H') AND
            (FirstRec^.DataType = 'D')) then
           OverLap := false
        else
           if FirstRec^.DataType = 'H' then
              begin
                if (XNew + Length(FirstRec^.LabelStr) + 
                    FirstRec^.Size + 6 > XOld) AND
                    (FirstRec <> SecondRec) then
                    OverLap := true ;
              end 
           else 
              if SecondRec^.DataType = 'H' then
                 begin
                   if (XNew + Length(FirstRec^.LabelStr) + 
                       FirstRec^.Size + 2 > XOld) AND
                      (FirstRec <> SecondRec) then
                      OverLap := true ;
                 end 
              else
                 if (XNew + Length(FirstRec^.LabelStr) + 
                     FirstRec^.Size + 4 > XOld) AND
                    (FirstRec <> SecondRec) then
                    OverLap := true ;
      end ;

     begin
       OverLap := false ;
       CurRec  := S_FirstRec[ScrNum] ;
       While CurRec <> nil do
          if (Y = CurRec^.Y) then
             begin
               if X <= CurRec^.X then
                  CompareX(NewRec, CurRec, X, CurRec^.X)
               else
                  CompareX(CurRec, NewRec, CurRec^.X, X) ;
                  
               if OverLap then
                  CurRec := nil
               else
                  CurRec := CurRec^.Next ;
             end
          else
             CurRec := CurRec^.Next 
     end ;

{ *************************************************************************
     CheckCurLoc will check the current location of the cursor to see if
     it is overlapping another record.  CurLoc will return -1 if no 
     overlap is found and the X offset into the record if the current
     cursor location is within an existing record.
************************************************************************* }
  procedure CheckCurLoc(Var CurLoc : short_integer ;
                        Var Current : ScrPtr ; 
                            XPos, YPos, ScrMode : short_integer ) ;

    var
        CurRec : ScrPtr ;

     begin
       CurLoc := -1 ;
       CurRec := S_FirstRec[ScrMode] ;
       C_CurRec := C_FirstRec ;
       While CurRec <> nil do
          begin
            if YPos = CurRec^.Y then
               if (XPos >= CurRec^.X) AND
                  (XPos <= CurRec^.X + CurRec^.Size + 
                            Length(CurRec^.LabelStr) + 3) then
                  begin
                    CurLoc := XPos - CurRec^.X ;
                    Current := CurRec ;
                    CurRec := nil ;
                  end ;
             
            if CurRec <> nil then
               begin
                 CurRec := CurRec^.Next ;
                 if C_CurRec <> nil then
                    C_CurRec := C_CurRec^.Next ;
               end ;
          end ;
     end ;

{ *************************************************************************     
     DisposeRecs will remove all Screen Data Records and release the
     memory back to the system.
************************************************************************* }
  procedure DisposeRecs(Var FirstRec, CurRec, LastRec : ScrPtr ) ;

    var
       DeleteRec : ScrPtr ;
        
     begin
       CurRec := FirstRec ;
       While CurRec <> nil do
          begin
            DeleteRec := CurRec ;
            CurRec    := CurRec^.Next ;
            Dispose(DeleteRec) ;
            PlusMemAvail( ScrRecSize ) ;
          end ;
       FirstRec := nil ;
       CurRec   := nil ;
       LastRec  := nil ;
     end ;

{ *************************************************************************     
     DisposeInt will remove all Integer Pointer Records and release the
     memory back to the system.
************************************************************************* }
  procedure DisposeInt(Var FirstRec, CurRec, LastRec : IntPtr ) ;

    var
       DeleteRec : IntPtr ;
        
     begin
       CurRec := FirstRec ;
       While CurRec <> nil do
          begin
            DeleteRec := CurRec ;
            CurRec    := CurRec^.Next ;
            Dispose(DeleteRec) ;
            F_TotalRec[DataNum] := F_TotalRec[DataNum] - 1 ;
          end ;
       FirstRec := nil ;
       LastRec  := nil ;
       CurRec   := nil ;
     end ;

{ *************************************************************************
     CalcOffset will calculate the offset value for Screen Data Records.
************************************************************************* }
  procedure CalcOffset(    FirstRec, LastRec : ScrPtr ; 
                       Var OffsetTotal : short_integer ) ;

    var
       CurRec : ScrPtr ;

     begin
       CurRec := FirstRec ;
       While CurRec <> LastRec do
          begin
            OffsetTotal := OffsetTotal + CurRec^.Size ;
            CurRec := CurRec^.Next ;
          end ;
     end ;

{ *************************************************************************
     ModifyStr adds a character, InChar to the proper member of the linked
     Data Storage list, signified by SourceStr.
************************************************************************* }
  procedure ModifyStr(CurRec : DataPtr ; Location : short_integer ; 
                      InChar : char) ;
 
     begin
       DetCurRec(CurRec^.Data, D_DataRec, Location) ;
       Delete(D_DataRec^.DataStr, Location + 1, 1) ;
       Insert(InChar, D_DataRec^.DataStr, Location + 1) ;
     end ;

{ *************************************************************************
     FillString fills the string variable FillStr with chr(FillChar).  This
     distiguishes between a space and an unfilled portion of the 
     data storage string.
************************************************************************* }
  procedure FillString(Var FillStr : Str50 ; FillChar : char ) ;

    var
       i : short_integer ;
       
     begin
       FillStr := FillChar ;
       for i := 1 to 49 do
           FillStr := Concat(FillStr, FillChar) ;
     end ;
{ *************************************************************************
************************************************************************* }
  procedure ModGetStr(Var FormatStr : Str255) ;

   var
      j         : short_integer ;
      CheckChar : char ;

    begin
      for j := 1 to Length(FormatStr) do
          begin
            CheckChar := FormatStr[j] ;
            if ord(CheckChar) > $7F then
               FormatStr[j] := chr(ord(CheckChar) - $80 + $41) ;
          end ; 
    end ;
{ *************************************************************************
     GetStr assembles a record string from the pieces apportioned over
     several data string storage records.
************************************************************************* }
  procedure GetStr(CurRec   : DataPtr ; Var DisplayStr : Str255 ;
                   StartPos, Size : short_integer ) ;

    Var
       DataRec  : DataStorePtr ;
       i,
       EndPos   : short_integer ;

     begin
       DetCurRec(CurRec^.Data, DataRec, StartPos ) ;
       DisplayStr := '' ;
       EndPos := (StartPos + Size) DIV 50 ;
       for i := 1 to EndPos + 1 do
           begin
             DisplayStr := Concat(DisplayStr, DataRec^.DataStr) ;
             DataRec := DataRec^.Next ;
           end ;

       if StartPos > 0 then
          Delete(DisplayStr, 1, StartPos) ;
       EndPos := Pos(chr($01), DisplayStr) ;
       if EndPos > 0 then
          FormatStr := Copy(DisplayStr, 1, EndPos - 1)
       else
          FormatStr := DisplayStr ;

       if Size < Length(FormatStr) then
          DisplayStr := Copy(FormatStr, 1, Size)
       else
          DisplayStr := FormatStr ;

       if Mode = 4 then
          begin
            if DisplayStr[1] = chr($03) then 
               DisplayStr[1] := chr($01) ;
          end ;
     end ;

{ *************************************************************************
     Using the spaces between names as a guide, this routine takes a name
     in the order, FIRST MIDDLE LAST and returns the same name in the
     order : LAST FIRST MIDDLE.  Useful for sorting on a NAME field.
************************************************************************* }
  procedure LastNameFirst( Var Name : Str255) ;
  
    var
       Len1,
       Len2,
       ChkChr   : short_integer ;
       TempChar : StrChar ;
       CommaLimit,
       SaveName : Str255 ;
       
     begin
       ChkChr := Pos(chr($2C), Name) ;
       if (ChkChr > 0) AND (Length(Name) > 0) then
          begin
            CommaLimit := Copy(Name, ChkChr, Length(Name) - ChkChr + 1) ;
            Delete(Name, ChkChr, Length(Name) - ChkChr + 1) ;
          end ;

       SaveName := Name ;
         
       Repeat
         Len1 := Length(Name) ;
         if Len1 > 0 then
            TempChar := Copy(Name, Len1, 1) ;
         if (TempChar = ' ') AND (Len1 > 1) then
            Delete(Name, Len1, 1) ;
         TempChar := Copy(Name, 1, 1) ;
         if (TempChar = ' ') AND (Len1 > 1) then
            Delete(Name, Len1, 1) ;
       Until (TempChar <> ' ') OR (Len1 < 2) ;

       ChkChr := Pos(' ', Name) ;
       if (ChkChr > 0) AND (Length(Name) > 2) then
          begin
            Repeat
              ChkChr := Pos(' ', Name) ;
              if ChkChr > 0 then
                 Delete(Name, 1, ChkChr) ;
            Until ChkChr = 0 ;

            Len1 := Length(SaveName) ;
            Len2 := Length(Name) ;
            Delete(SaveName, Len1 - Len2, Len2 + 1) ;
            Name := Concat(Name, ' ', SaveName) ;
          end ;

       if Length(CommaLimit) > 0 then
          Name := Concat(Name, CommaLimit) ;
     end ;

{ *************************************************************************
     NewCursor will display the cursor, either an underline or an inverse
     letter at the current cursor position as defined by XCur and YCur.
     Usually follows a call to EraseCursor.
************************************************************************* }
  procedure NewCursor(ScrMode : short_integer) ;

    var
       CurLoc    : short_integer ;
       CurRec    : ScrPtr ;
       CurChar   : StrChar ;
       RepeatCheck,
       UnderLine : boolean ;

{ *************************************************************************
************************************************************************* }
    procedure CursorInput ;
     
        begin
          Text_Color(White) ;
          Paint_Color(Black) ;
          Paint_Style(1) ;
  
          if Resolution = 2 then
             Paint_Rect(x + XCur * 8,
                        y + YCur * Spacing - 13, 8, 17)
          else
             Paint_Rect(x + XCur * 8,
                        y + YCur * Spacing - 6, 8, 8) ;

          Draw_Mode(2) ;
          Draw_String(x + XCur * 8, y + YCur * Spacing, 
             CurChar) ;
          Text_Style(Normal) ;
          Text_Color(Black) ;
          Paint_Color(White) ;
          Draw_Mode(1) ;
        end ;

{ *************************************************************************
************************************************************************* }
     procedure CursorLabel ;
     
        begin
          CurChar := Copy(CurRec^.LabelStr, CurLoc + 1, 1) ;
          CursorInput ;
        end ;

{ *************************************************************************
************************************************************************* }
     procedure NC_Update ;
     
        procedure CheckMode( Var Flag : boolean ) ;
     
           begin
             if (Mode = 2) OR (Mode = 3) OR (Mode = 4) then
                begin
                  GetChar(S_CurrentRec[ScrMode], D_CurrentRec[ScrMode], 
                          CurChar, S_CurrentRec[ScrMode]^.XInPos + 
                                   S_CurrentRec[ScrMode]^.Offset) ;
                  if CurChar = chr(1) then
                     UnderLine := true
                  else
                     if (CurChar = '$') AND 
                        (S_CurrentRec[ScrMode]^.DataType = 'F') AND
                        (CurLoc = Length(CurRec^.LabelStr) + 3) then
                        begin
                          XCur := XCur + 1 ;
                          CurLoc := CurLoc + 1 ;
                          S_CurrentRec[ScrMode]^.XInPos := 
                                       S_CurrentRec[ScrMode]^.XInPos + 1 ;
                          Flag := false ;
                        end 
                     else
                        begin
                          if CurChar = chr(3) then
                             CurChar := chr(1) ;
                          CursorInput ;
                        end ;
                end
             else
                UnderLine := true ;
           end ;

        begin
          if (CurLoc > Length(CurRec^.LabelStr) + 2) AND
             (CurLoc < Length(CurRec^.LabelStr) + 3 + CurRec^.Size) then
              Repeat                            { 3 then 2 }
                RepeatCheck := true ;
                CheckMode(RepeatCheck) ;
              Until RepeatCheck
          else
             if CurLoc + 1 > Length(CurRec^.LabelStr) then
                UnderLine := true
             else
                CursorLabel ;
        end ;

{ *************************************************************************
************************************************************************* }
     procedure CheckLines ;
     
        begin
          XCur := XCur + 1 ;
          CurLoc := CurLoc + 1 ;
          UnderLine := true ;
        end ;

{ *************************************************************************
************************************************************************* }
     procedure UpdateCursor ;
     
        begin
          if (CurLoc = Length(CurRec^.LabelStr) + 2) OR
             (CurLoc = Length(CurRec^.LabelStr) + 3 + CurRec^.Size) then
             CheckLines
          else
             NC_Update ;
        end ;

     procedure NewCursor5 ;
     
       var
          HiChar : char ;

        begin
          GetChar(S_CurrentRec[ScrMode], D_CurrentRec[ScrMode], 
                  CurChar, S_CurrentRec[ScrMode]^.Offset + XCur - 1) ;
          HiChar := CurChar[1] ;
          if ord(HiChar) > $7F then 
             CurChar := chr(ord(HiChar) - $80 + $41) ;

          Text_Color(White) ;
          Paint_Color(Black) ;
          Paint_Style(1) ;
          Paint_Rect(x + (XCur - RW_Offset) * 8,
                     y + YCur * Spacing - 10 * Resolution,
                     8, 8 * Resolution) ;  
          Draw_Mode(2) ;
          Draw_String(x + (XCur - RW_Offset) * 8 , 
                      y + YCur * Spacing - 4 * Resolution, 
                      CurChar) ;
          Text_Style(Normal) ;
          Text_Color(Black) ;
          Paint_Color(White) ;
          Draw_Mode(1) ;
        end ;

     begin
       Hide_Mouse ;
       if Mode = 5 then
          NewCursor5
       else
          begin
            UnderLine := false ;
            CheckCurLoc(CurLoc, CurRec, XCur, YCur, ScrMode) ;

            if CurLoc >= 0 then
               UpdateCursor
            else
               UnderLine := true ;

            if UnderLine then
               Draw_String(x + XCur * 8, y + YCur * Spacing, '_') ;
          end ;
       Show_Mouse ;
     end ;

{ *************************************************************************
     EraseCursor will erase the cursor at the current cursor position as
     defined by XCur and YCur.  The display will be redrawn to reflect the
     appearance with no cursor drawn.  Usually preceeds a call to NewCursor.
************************************************************************* }
  procedure EraseCursor(ScrMode : short_integer) ;

    var
       CurLoc  : short_integer ;
       CurRec  : ScrPtr ;
       CurChar : StrChar ;

{ *************************************************************************
************************************************************************* }
     procedure EraseIN ;
     
        begin
          GetChar(S_CurrentRec[ScrMode], D_CurrentRec[ScrMode], CurChar, 
              S_CurrentRec[ScrMode]^.XInPos + S_CurrentRec[ScrMode]^.Offset) ;

          if Resolution = 2 then
             Paint_Rect(x + XCur * 8, y + YCur * Spacing - 12, 8, 16)
          else
             Paint_Rect(x + XCur * 8, y + YCur * Spacing - 6, 8, 8) ;

          if CurChar = chr(1) then
             CurChar := ' ' ;
          if CurChar = chr(3) then
             CurChar := chr(1) ;
        end ;

{ *************************************************************************
************************************************************************* }
     procedure EraseLBL ;
     
        begin
          if CurLoc + 1 > Length(CurRec^.LabelStr) then
             CurChar := ' '
          else
             begin
               CurChar := Copy(CurRec^.LabelStr, CurLoc + 1, 1) ;
               Paint_Rect(x + XCur * 8, y + YCur * Spacing - 7 * Resolution,
                          8, 9 * Resolution) ;
             end ;
        end ;

{ *************************************************************************
************************************************************************* }
     procedure CurrentRecord ;
     
        begin
          if (CurLoc > Length(CurRec^.LabelStr) + 2) AND
             (CurLoc < Length(CurRec^.LabelStr) + 3 + CurRec^.Size) then
             begin
               if (Mode = 2) OR (Mode = 3) OR (Mode = 4) then
                  EraseIN
               else
                  CurChar := ' ' ;
             end
          else
             EraseLBL ;
        end ;

     procedure EraseCursor5 ;

       var
          HiChar : char ;
     
        begin
          GetChar(S_CurrentRec[ScrMode], D_CurrentRec[ScrMode], 
                  CurChar, S_CurrentRec[ScrMode]^.Offset + XCur - 1) ;
          HiChar := CurChar[1] ;
          if ord(HiChar) > $7F then 
             CurChar := chr(ord(HiChar) - $80 + $41) ;

          Paint_Rect(x + (XCur - RW_Offset) * 8, 
                     y + YCur * Spacing - 10 * Resolution,
                     8, 8 * Resolution) ;
          Draw_String(x + (XCur - RW_Offset) * 8, 
                      y + YCur * Spacing - 4 * Resolution, 
                      CurChar) ;
        end ;

     begin
       Hide_Mouse ;
       if Mode = 5 then
          EraseCursor5
       else
          begin
            CheckCurLoc(CurLoc, CurRec, XCur, YCur, ScrMode) ;
 
            if CurLoc >= 0 then
               CurrentRecord
            else
               CurChar := ' ' ;

            Draw_String(x + XCur * 8, y + YCur * Spacing, CurChar) ;
          end ;
       Show_Mouse ;
     end ;

{ *************************************************************************
     DeleteChar is called by KB_InInput when the Delete key or
     Back Space key is pressed.  The procedure is passed the current
     field (CurRec : ScrPtr) to ascertain the Offset, Size and
     XInPos as well as the current Data Storage record 
     (DataRec : DataStorePtr) and the location within DataRec^.DataStr
     of the cursor (Loc).
     
     The procedure calculates which string(s) to modify and then
     deletes the proper character, moving all subsequent characters
     to the left.  If the deletion cause movement over a 50 character
     boundary, the procedure will move the characters over that
     boundary.  
     
     After the deletion and movements are completed, a chr(1) will be
     inserted into the proper DataRec^.DataStr at the logical, rather than
     physical, end of the string.
************************************************************************* }
  procedure DeleteChar(ScrRec  : ScrPtr ; DataRec : DataPtr ; 
                       Loc     : short_integer ) ;

    var
        InsLoc,
        DelLoc,
        Count,
        MaxCount,
        CheckPoint,
        Location : short_integer ;
        NewChar  : char ;
        CurRec   : DataStorePtr ;
        NextFlag : boolean ;

     begin
       Location := Loc + ScrRec^.Offset - 1 ;
       DetCurRec(DataRec^.Data, D_DataRec, Location) ;
       CurRec := D_DataRec ;

       Count := 1 + ((ScrRec^.Offset + Loc) DIV 50) - 
                     (ScrRec^.Offset DIV 50) ;
       MaxCount := ((ScrRec^.Offset + ScrRec^.Size) DIV 50) - 
                    (ScrRec^.Offset DIV 50) ;
       CheckPoint := 1 + ((ScrRec^.Offset DIV 50) + MaxCount) * 50 - 
                           ScrRec^.Offset ;
       if ((ScrRec^.Offset + ScrRec^.Size) MOD 50 = 0) AND
          ((ScrRec^.Offset + CheckPoint - 1) MOD 50 = 0) then
          CheckPoint := 0 ;

       DelLoc := (Loc + ScrRec^.Offset) MOD 50 ;
       if DelLoc = 0 then DelLoc := 50 ;
       Repeat
         if Loc < CheckPoint then
            begin
              InsLoc := 50 ;
              NextFlag := true ;
            end 
         else
            begin
              InsLoc := (ScrRec^.Offset + ScrRec^.Size) MOD 50 ;
              if InsLoc = 0 then InsLoc := 50 ;
              NextFlag := false ;
            end ;

         if NextFlag then
            NewChar := CurRec^.Next^.DataStr[1]
         else
            if Mode = 5 then
               NewChar := chr($20)
            else
               NewChar := chr($01) ;
         Delete(CurRec^.DataStr, DelLoc, 1) ;
         Insert(NewChar, CurRec^.DataStr, InsLoc) ;
         CurRec := CurRec^.Next ;
         Loc := (((ScrRec^.Offset DIV 50) + Count) * 50) - 
                   ScrRec^.Offset + 1 ;
         Count  := Count + 1 ;
         DelLoc := 1 ;
       Until NOT NextFlag ;
     end ;

{ *************************************************************************
     Insert the character NewChar at the desired location in the proper
     data store data string.
************************************************************************* }
  procedure InsertChar(ScrRec  : ScrPtr ; DataRec : DataPtr ; 
                       NewChar : char ;   Loc     : short_integer ) ;

     var
        InsLoc,
        DelLoc,
        Count,
        MaxCount,
        CheckPoint,
        Location : short_integer ;
        NextChar : char ;
        CurRec   : DataStorePtr ;
        NextFlag : boolean ;
        
     begin
       Location := Loc + ScrRec^.Offset - 1 ;
       DetCurRec(DataRec^.Data, D_DataRec, Location) ;
       CurRec := D_DataRec ;

       Count := 1 + ((ScrRec^.Offset + Loc) DIV 50) - 
                     (ScrRec^.Offset DIV 50) ;
       MaxCount := ((ScrRec^.Offset + ScrRec^.Size) DIV 50) - 
                    (ScrRec^.Offset DIV 50) ;
       CheckPoint := 1 + ((ScrRec^.Offset DIV 50) + MaxCount) * 50 - 
                           ScrRec^.Offset ;
       if ((ScrRec^.Offset + ScrRec^.Size) MOD 50 = 0) AND
          ((ScrRec^.Offset + CheckPoint - 1) MOD 50 = 0) then
          CheckPoint := 0 ;

       InsLoc := (Loc + ScrRec^.Offset) MOD 50 ;
       if InsLoc = 0 then InsLoc := 50 ;
       Repeat
           if Loc < CheckPoint then
              begin
                DelLoc := 50 ;
                NextFlag := true ;
              end 
           else
              begin
                DelLoc := (ScrRec^.Offset + ScrRec^.Size) MOD 50 ;
                if DelLoc = 0 then DelLoc := 50 ;
                NextFlag := false ;
              end ;

           NextChar := CurRec^.DataStr[50] ;
           Delete(CurRec^.DataStr, DelLoc, 1) ;
           Insert(NewChar, CurRec^.DataStr, InsLoc) ;
           NewChar := NextChar ;
           CurRec := CurRec^.Next ;
           Loc := (((ScrRec^.Offset DIV 50) + Count) * 50) - 
                     ScrRec^.Offset + 1 ;
           Count  := Count + 1 ;
           InsLoc := 1 ;
       Until NOT NextFlag ;
     end ;
     
{ **************************  Date Routines  **************************** }

{ *************************************************************************
************************************************************************* }
  procedure GetAscii(Character : StrChar ; Var CharInt : short_integer) ;
     
     var
        Counter : short_integer ;
        
      begin
        CharInt := 0 ;
        Counter := $20 ;
        Repeat
          if chr(Counter) = Character then
             CharInt := Counter ;
          Counter := Counter + 1 ;
        Until (Counter > $7E) OR (CharInt > 0) ;
      end ;

{ *************************************************************************
************************************************************************* }     
  procedure LowerCase(Var InputStr : Str255) ;

     var
        CharInt   : short_integer ;
        Character : StrChar ;
        SaveStr   : Str255 ;

      begin
        SaveStr := '' ;
        Repeat
          Character := Copy(InputStr, 1, 1) ;
          GetAscii(Character, CharInt) ;
          if ((CharInt > $40) AND (CharInt < $5B)) then
             { Convert to Lower Case  }
             CharInt := CharInt + $20 ;
          Delete(InputStr, 1, 1) ;
          SaveStr := Concat(SaveStr, chr(CharInt)) ;
        Until Length(InputStr) < 1 ;
        InputStr := SaveStr ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure StripCharacter( Var Date : Str255 ) ;
     
     var
        CharInt  : short_integer ;
        Character: StrChar ;
        ExitChar : boolean ;
   
      begin
        ExitChar := false ;
        Repeat
          Character := Copy(Date, 1, 1) ;
          GetAscii(Character, CharInt) ;
          if  (CharInt = $2A) OR                        {  *  }
             ((CharInt > $2F) AND (CharInt < $3A)) OR   { Number }
             ((CharInt > $40) AND (CharInt < $5B)) OR   { Upper Case }
             ((CharInt > $60) AND (CharInt < $7B)) then { Lower Case }
             ExitChar := true
          else
             Delete(Date, 1, 1) ;
        Until ExitChar OR (Length(Date) < 1) ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure NumCheck(NumStr : Str255 ; Var Flag : boolean ) ;
     
     var
        CharInt  : short_integer ;
        Character: StrChar ;
      
      begin
        Flag := true ;
        Repeat
          Character := Copy(NumStr, 1, 1) ;
          GetAscii(Character, CharInt) ;
          if (CharInt > $2F) AND (CharInt < $3A) then   { Number }
             Delete(NumStr, 1, 1)
          else
             Flag := false ;
        Until NOT Flag OR (Length(NumStr) < 1) ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure ConvMonth(MonthStr : Str255 ; Var Month : short_integer ) ;
     
     var
        i : short_integer ;
        MonthName : array[1..12] of string[3] ;

      begin
        MonthName[1]  := 'jan' ;
        MonthName[2]  := 'feb' ;
        MonthName[3]  := 'mar' ;
        MonthName[4]  := 'apr' ;
        MonthName[5]  := 'may' ;
        MonthName[6]  := 'jun' ;
        MonthName[7]  := 'jul' ;
        MonthName[8]  := 'aug' ;
        MonthName[9]  := 'sep' ;
        MonthName[10] := 'oct' ;
        MonthName[11] := 'nov' ;
        MonthName[12] := 'dec' ;
        if Length(MonthStr) > 0 then
           LowerCase(MonthStr) ;
        Month := 0 ;
        for i := 1 to 12 do
            if Pos(MonthName[i], MonthStr) > 0 then
               begin
                 Month := i ;
                 i := 13 ;
               end ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure ConvDate(Date : Str255 ; Var Month, Day, Year : short_integer) ;
     
      var
         DateStr  : array[1..3] of Str255 ;
         i,
         CharInt  : short_integer ;
         Character: StrChar ;
         NumFlag,
         ExitChar : boolean ;

      begin
        for i := 1 to 3 do
            begin
              DateStr[i] := '' ;
              ExitChar := false ;
              if Length(Date) > 0 then
                 StripCharacter(Date) ;
              if Length(Date) > 0 then
                 Repeat
                   Character := Copy(Date, 1, 1) ;
                   GetAscii(Character, CharInt) ;
                   if  (CharInt = $2A) OR                        {  *  }
                      ((CharInt > $2F) AND (CharInt < $3A)) OR   { Number }
                      ((CharInt > $40) AND (CharInt < $5B)) OR   { Upper Case }
                      ((CharInt > $60) AND (CharInt < $7B)) then { Lower Case }
                      begin
                        if CharInt = $2A then
                           DateStr[i] := Concat(DateStr[i], chr($30))
                        else
                           DateStr[i] := Concat(DateStr[i], Character) ;
                        Delete(Date, 1, 1) ;
                      end
                   else
                      ExitChar := true ;
                 Until ExitChar OR (Length(Date) < 1)
              else
                 DateStr[i] := '0' ;
            end ;

        NumCheck(DateStr[1], NumFlag) ;
        if NumFlag then
           ReadV(DateStr[1], Month)
        else
           ConvMonth(DateStr[1], Month) ;
        ReadV(DateStr[2], Day) ;
        ReadV(DateStr[3], Year) ;

       { Adjust for two digit year input }
        if Year < 100 then
           Year := Year + 1900 ;
      end ;

{ *************************************************************************
EXPLAIN
************************************************************************* }
  procedure AutoDate(    ScrRec : ScrPtr ; DataRec : DataPtr ; 
                     Var DateStr : Str255 ) ;
     
     var
        i,
        Location,
        Month,
        Day,
        Year     : short_integer ;
        TempChar : char ;

      begin
        Get_Date(Month,Day,Year) ;
        WriteV(DateStr, Month,'/',Day,'/', Year) ;

        for i := 1 to Length(DateStr) do
            begin
              TempChar := DateStr[i] ;
              Location := i + ScrRec^.Offset - 1 ;
              ModifyStr(DataRec, Location, TempChar) ;
            end ;

        for i := Length(DateStr) + 1 to ScrRec^.Size do
            begin
              Location := i + ScrRec^.Offset - 1 ;
              ModifyStr(DataRec, Location, chr(1)) ;
            end ;
      end ;
{ **************************  Dollar Routines  *************************** }

{ *************************************************************************
************************************************************************* }
  procedure CheckNumber(Var NumStr : Str255) ;
     
     var
        NewChar  : StrChar ;
        SaveStr  : Str255 ;
        CharInt  : short_integer ;

      begin
        if Length(NumStr) > 0 then
           begin
             SaveStr := '' ;
             Repeat
               NewChar := Copy(NumStr, 1, 1) ;
               GetAscii(NewChar, CharInt) ;
               if  (CharInt = $2E) OR                         {  .  }
                  ((CharInt > $2F) AND (CharInt < $3A)) then  { Number }
                  SaveStr := Concat(SaveStr, NewChar) ;
               Delete(NumStr, 1, 1) ;
             Until Length(NumStr) < 1 ;
           end ;

        if (Length(SaveStr) < 1) OR (SaveStr = '.') then
           NumStr := '0' 
        else
           NumStr := SaveStr ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure FormatInt(ScrRec : ScrPtr ; Var IntStr : Str255 ) ;
     
     var
        IntNumber : real ;
        DecPos    : short_integer ;

      begin
        CheckNumber(IntStr) ;
        ReadV(IntStr, IntNumber) ;
        WriteV(IntStr, IntNumber:ScrRec^.Size + 2:1) ;
        DecPos := Pos('.', IntStr) ;
        if DecPos > 0 then
           Delete(IntStr, DecPos, Length(IntStr) - DecPos + 1) ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure FormatReal(ScrRec  : ScrPtr ; Var RealStr : Str255 ) ;
     
     var
        RealNumber : real ;

      begin
        CheckNumber(RealStr) ;
        ReadV(RealStr, RealNumber) ;
        WriteV(RealStr, RealNumber:ScrRec^.Size:DecReal) ;
      end ;
     
{ *************************************************************************
************************************************************************* }
  procedure FormatDollar(ScrRec : ScrPtr ; Var DollarStr : Str255 ) ;
     
     var
        DollarNumber : real ;

      begin
        CheckNumber(DollarStr) ;
        ReadV(DollarStr, DollarNumber) ;
        WriteV(DollarStr, chr($24), DollarNumber:ScrRec^.Size - 1:2) ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure FormatCheck( CurRec : DataPtr ) ;
     
     var
        ScrRec : ScrPtr ;
        i,
        CharInt,
        Location  : short_integer ;
        NewChar   : StrChar ;
         
      begin
        ScrRec := S_FirstRec[ScrNum] ;
        While ScrRec <> nil do
           begin
             if (ScrRec^.DataType = 'C') OR     { Integer }
                (ScrRec^.DataType = 'E') OR     { Real    }
                (ScrRec^.DataType = 'F') then   { Dollar  }
                begin
                  GetStr(CurRec, FormatStr, ScrRec^.Offset, ScrRec^.Size ) ;
                  NewChar := ScrRec^.DataType ;
                  GetAscii(NewChar, CharInt ) ;
     
                   Case CharInt of
                       $43 : FormatInt(ScrRec, FormatStr) ;
                       $45 : FormatReal(ScrRec, FormatStr) ;
                       $46 : FormatDollar(ScrRec, FormatStr) ;
                   end ;
                  for i := 0 to ScrRec^.Size - 1 do
                      begin
                        Location := ScrRec^.Offset + i ;
                        NewChar := Copy(FormatStr, i + 1, 1) ;
                        GetAscii(NewChar, CharInt) ;
                        ModifyStr(D_CurrentRec[DataNum], Location, 
                                  chr(CharInt)) ;
                      end ;
                  GetStr(CurRec, FormatStr, ScrRec^.Offset, ScrRec^.Size ) ;
                  Draw_String(x + ScrRec^.XPos * 8,
                              y + ScrRec^.YPos * Spacing, FormatStr) ;
                end ;
             ScrRec := ScrRec^.Next ;
           end ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure ConvDollar( RecStr : Str255 ; Var RecNum : real ) ;
     
      begin
        CheckNumber(RecStr) ;
        ReadV(RecStr, RecNum) ;
      end ;

{ *************************************************************************
************************************************************************* }
  procedure InitPrinter(InitStr : Str20) ;

    var
       NumStr,
       ModStr   : Str255 ;
       Flag     : boolean ;
       PrtNum,
       SpacePos : short_integer ;
       SpaceCheck : StrChar ;

     begin
       ModStr := InitStr ;
       While Length(ModStr) > 0 do
          begin
            Repeat
              SpaceCheck := Copy(ModStr,1,1) ;
              if SpaceCheck = chr($20) then
                 Delete(ModStr,1,1) ;
            Until (SpaceCheck <> chr($20)) OR (Length(ModStr) < 1) ;
            
            SpaceCheck := chr($20) ;
            While (Length(ModStr) > 0) AND (SpaceCheck = chr($20)) do
              begin
                SpaceCheck := Copy(ModStr, Length(ModStr),1) ;
                if SpaceCheck = chr($20) then
                   Delete(ModStr, Length(ModStr),1) ;
              end ;
            
            if Length(ModStr) > 0 then
               begin
                 SpacePos := Pos(chr($20), ModStr) ;   
                 if SpacePos > 0 then
                    begin
                      NumStr := Copy(ModStr, 1, SpacePos - 1) ;
                      Delete(ModStr, 1, SpacePos) ;
                    end
                 else
                    begin
                      NumStr := ModStr ;
                      ModStr := '' ;
                    end ;
                 
                 NumCheck(NumStr, Flag) ;
                 if Flag then
                    begin
                      ReadV(NumStr, PrtNum) ;
                      Write(Printer, chr(PrtNum)) ;
                    end ;
               end ;
          end ;
     end ;
  

BEGIN
END .
