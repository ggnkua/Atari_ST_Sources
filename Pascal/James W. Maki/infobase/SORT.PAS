{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program SearchAndSort_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{  ******************************  External ***************************** }
  procedure GetStr(CurRec : DataPtr ; Var DisplayStr : Str255 ;
                   Start, Size : short_integer ) ;
     External ;

  procedure Int_AddARec(Var FirstRec, CurRec, LastRec : IntPtr ; 
                            Value : short_integer ) ;
     External ;
     
  procedure DS_DeleteARec(CurRec : DataPtr) ;
     External ;

  procedure DispDataRec( CurRec : DataPtr ) ;
     External ;
     
  procedure DrawRecord(CurRec : DataPtr ) ;
     External ;

  procedure LastNameFirst( Var Name : Str255) ;
     External ;

  procedure DisposeInt(Var FirstRec, CurRec, LastRec : IntPtr ) ;
     External ;

  procedure MinusMemAvail(RecSize : long_integer ) ;
     External ;

  procedure ConvDate(    Date : Str255 ; 
                        Var Month, Day, Year : short_integer ) ;
     External ;

  procedure ConvDollar( RecStr : Str255 ; Var RecNum : real ) ;
     External ;

  procedure CheckNumber(Var NumStr : Str255) ;
     External ;

  procedure GetAscii(    Character : StrChar ;
                     Var CharInt : short_integer) ;
     External ;

  procedure GetChar(      CurRec  : ScrPtr ; D_CurRec  : DataPtr ; 
                    Var Character : StrChar ; Position  : short_integer ) ;
     External ;

  procedure ClrHome ;
     External ;
{  ************************* COMPARE ROUTINES *************************** }
{ *************************************************************************
     Compare two strings.
************************************************************************* }
  procedure CompStr(RecStr, SearchStr : Str255 ; Var Flag : byte ) ;

     begin
       if RecStr > SearchStr then 
          Flag := 0
       else
          if SearchStr > RecStr then 
             Flag := 1
          else
             Flag := 2 ;
     end ;

{ *************************************************************************
     Compare two boolean expressions.
************************************************************************* }
  procedure CompBoolean(RecStr, SearchStr : Str255 ; Var Flag : byte ) ;

     begin
       if RecStr > SearchStr then 
          Flag := 0
       else
          if SearchStr > RecStr then 
             Flag := 1
          else
             Flag := 2 ;
     end ;

{ *************************************************************************
     Compare two numbers, integer or real.
************************************************************************* }
  procedure CompNum(RecStr, SearchStr : Str255 ; Var Flag : byte ) ;

    var
       RecNum,
       SearchNum : real ;

     begin
       CheckNumber(RecStr) ;
       CheckNumber(SearchStr) ;
       ReadV(RecStr, RecNum) ;
       ReadV(SearchStr, SearchNum) ;

       if RecNum > SearchNum then 
          Flag := 0
       else
          if RecNum < SearchNum then 
             Flag := 1
          else
             Flag := 2 ;
     end ;

{ *************************************************************************
     Compare two dates.
************************************************************************* }
  procedure CompDate(RecStr, SearchStr : Str255 ; Var Flag : byte ) ;

    var
       i, j : short_integer ;
       Date : array[1..2,1..3] of short_integer ;
         
     begin
       ConvDate(SearchStr, Date[1,1], Date[1,2], Date[1,3] ) ;
       ConvDate(RecStr, Date[2,1], Date[2,2], Date[2,3] ) ;

       for i := 1 to 3 do
           begin
             if Date[1,i] = 0 then
                Date[1,i] := Date[2,i] ;
            end ;
       if Date[1,3] > Date[2,3] then   { Compare Years }
          Flag := 1
       else
          if Date[1,3] < Date[2,3] then
             Flag := 0
          else
             if Date[1,1] > Date[2,1] then   { Compare Months }
                Flag := 1
             else
                if Date[1,1] < Date[2,1] then
                   Flag := 0
                else
                   if Date[1,2] > Date[2,2] then   { Compare Days }
                      Flag := 1
                   else
                      if Date[1,2] < Date[2,2] then
                         Flag := 0
                      else
                         Flag := 2 ;
     end ;
       
{ *************************************************************************
     Compare two dollar amounts.
************************************************************************* }
  procedure CompDollar(RecStr, SearchStr : Str255 ; Var Flag : byte ) ;

    var
       RecNum,
       SearchNum : real ;

     begin
       ConvDollar(SearchStr, SearchNum) ;
       ConvDollar(RecStr, RecNum) ;

       if RecNum > SearchNum then
          Flag := 0
       else
          if RecNum < SearchNum then
             Flag := 1
          else
             Flag := 2 ;
     end ;

{ **************************** SEARCH ROUTINES ************************** }
{ *************************************************************************
     Prepare names by removing extra spaces and calling LastNameFirst
     of necessary.
************************************************************************* }
  procedure PrepName(ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ; 
                     Flag : boolean ; Var RecStr, SearchStr : Str255 ) ;

    var
       SpacePos : short_integer ;
       BoolChar : StrChar ;
   
     begin
       if Flag then
          begin
            LastNameFirst(RecStr) ;
            SpacePos := Pos(' ', RecStr) ;
            if SpacePos > 0 then
               Delete(RecStr, SpacePos, Length(RecStr) - SpacePos + 1) ;
          end
       else
          begin
            GetChar(ScrRec^.Next, CurRec, BoolChar, 
                    ScrRec^.Next^.Offset) ;
            if BoolChar <> 'T' then
               LastNameFirst(RecStr) ;
                    
            GetChar(ScrRec^.Next, SearchRec, BoolChar, 
                    ScrRec^.Next^.Offset) ;
            if BoolChar <> 'T' then
               LastNameFirst(SearchStr) ;
         end ;
     end ;

{ *************************************************************************
     Check for astericks at beginning and end of a search string.
     The asterick is the wildcard designator for searchs.
************************************************************************* }
  procedure AsterikChk(Var SearchStr : Str255 ; 
                       Var StarPos1, StarPos2 : boolean) ;

     var
        Asterik : short_integer ;

      begin
        if SearchStr[1] = chr($2A) then 
           StarPos1 := true
        else
           StarPos1 := false ;
            
        if SearchStr[Length(SearchStr)] = chr($2A) then 
           StarPos2 := true
        else
           StarPos2 := false ;

        Asterik := 1 ;
        While Asterik > 0 do
           begin
             Asterik := Pos(chr($2A), SearchStr) ;
             if Asterik > 0 then
                Delete(SearchStr,Asterik,1) ;
           end ;
      end ;            
      
{ *************************************************************************
     Select correct comparison routine depending upon DataType.
************************************************************************* }
  procedure Do_Comparison( ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                           StarPos1, StarPos2 : boolean ;
                           RecStr, SearchStr : Str255 ; 
                          Var Flag : byte) ;

    var
       Character : StrChar ;
       CharInt   : short_integer ;

     begin
       Character := ScrRec^.DataType ;
       GetAscii(Character, CharInt ) ;
       if StarPos2 AND (CharInt = $48) then
          CharInt := $41 ;

       Case CharInt of
           $41 : CompStr(RecStr, SearchStr, Flag) ;
           $42 : CompBoolean(RecStr, SearchStr, Flag) ;
           $43,
           $44,
           $45 : CompNum(RecStr, SearchStr, Flag) ;
           $46 : CompDollar(RecStr, SearchStr, Flag) ;
           $47 : CompDate(RecStr, SearchStr, Flag) ;
           $48 : begin
                   PrepName(ScrRec, CurRec, SearchRec, 
                            StarPos1, RecStr, SearchStr) ;
                   CompStr(RecStr, SearchStr, Flag) ;
                 end ;
       end ;
     end ;

{ *************************************************************************
     Check equality of two records.
************************************************************************* }
  procedure ChkEqual(    ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                         SearchStr, RecStr : Str255 ;
                     Var Match : boolean ) ;

    var
       StarPos : array[1..2] of boolean ;
       Flag    : byte ;

     begin
       if ScrRec^.DataType <> 'G' then
          AsterikChk(SearchStr, StarPos[1], StarPos[2]) ;

       if  (ScrRec^.DataType = 'A') OR
          ((ScrRec^.DataType = 'H') AND (StarPos[2])) then
          begin
            Match := true ;
              
            if NOT StarPos[1] AND NOT StarPos[2] then
               begin
                 if SearchStr <> RecStr then
                    Match := false ;
               end
            else
               if StarPos[1] AND NOT StarPos[2] then
                  begin
                    if Pos(SearchStr, RecStr) <> 
                           Length(RecStr) - Length(SearchStr) + 1 then
                       Match := false ;
                  end
               else
                  if NOT StarPos[1] AND StarPos[2] then
                     begin
                       if Pos(SearchStr, RecStr) <> 1 then
                          Match := false ;
                     end
                  else
                     if Pos(SearchStr, RecStr) = 0 then
                        Match := false ;
          end
       else
          begin
            Do_Comparison( ScrRec, CurRec, SearchRec,
                           StarPos[1],StarPos[2], RecStr, SearchStr, Flag ) ;
            if Flag = 2 then
               Match := true
            else
               Match := false ;
          end ;
      end ;

{ *************************************************************************
     Check if Record value is larger than Search value.
************************************************************************* }
  procedure ChkGreater(    ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                           SearchStr, RecStr : Str255 ;
                       Var Match : boolean ) ;

    var
       StarPos  : array[1..2] of boolean ;
       Flag     : byte ;

     begin
       if ScrRec^.DataType <> 'G' then
          AsterikChk(SearchStr, StarPos[1], StarPos[2]) ;
    
       Do_Comparison(ScrRec, CurRec, SearchRec, 
                     StarPos[1],StarPos[2], RecStr, SearchStr, Flag ) ;

       if Flag = 0 then
          Match := true
       else
          Match := false ;
     end ;
     
{ *************************************************************************
     Check if Record value is less than Search value.
************************************************************************* }
  procedure ChkLess(    ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                        SearchStr, RecStr : Str255 ;
                    Var Match : boolean ) ;

    var
       StarPos : array[1..2] of boolean ;
       Flag    : byte ;

     begin
       if ScrRec^.DataType <> 'G' then
          AsterikChk(SearchStr, StarPos[1], StarPos[2]) ;
           
       Do_Comparison(ScrRec, CurRec, SearchRec,
                     StarPos[1],StarPos[2], RecStr, SearchStr, Flag ) ;

       if Flag = 1 then
          Match := true
       else
          Match := false ;
     end ;

{ *************************************************************************
     Check if Record is not equal to Search value.
************************************************************************* }
  procedure ChkNotEqual(  ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                          SearchStr, RecStr : Str255 ;
                        Var Match : boolean ) ;

    var
       NotEqual : array[1..2] of boolean ;
                           
     begin
       NotEqual[1] := true ;
       NotEqual[2] := true ;
       ChkGreater(ScrRec, CurRec, SearchRec, SearchStr, RecStr, NotEqual[1] ) ;
       ChkLess(ScrRec, CurRec, SearchRec, SearchStr, RecStr, NotEqual[2] ) ;

       if NotEqual[1] OR NotEqual[2] then 
          Match := true
       else 
          Match := false ;
     end ;
     
{ *************************************************************************
     Check if Record is less than or equal to Search Value.
************************************************************************* }
  procedure ChkLessEqual(  ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                           SearchStr, RecStr : Str255 ;
                         Var Match : boolean ) ;

    var
       NotEqual : array[1..2] of boolean ;
                            
     begin
       NotEqual[1] := true ;
       NotEqual[2] := true ;
       ChkLess(ScrRec, CurRec, SearchRec, SearchStr, RecStr, NotEqual[1] ) ;
       ChkEqual(ScrRec, CurRec, SearchRec, SearchStr, RecStr, NotEqual[2] ) ;

       if NotEqual[1] OR NotEqual[2] then 
          Match := true
       else 
          Match := false ;
     end ;

{ *************************************************************************
     Check if Record is greater than or equal to Search Value.
************************************************************************* }
  procedure ChkGreatEqual( ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                           SearchStr, RecStr : Str255 ;
                          Var Match : boolean ) ;

    var
       NotEqual : array[1..2] of boolean ;
                            
     begin
       NotEqual[1] := true ;
       NotEqual[2] := true ;
       ChkGreater(ScrRec, CurRec, SearchRec, SearchStr, RecStr, NotEqual[1] ) ;
       ChkEqual(ScrRec, CurRec, SearchRec, SearchStr, RecStr, NotEqual[2] ) ;

       if NotEqual[1] OR NotEqual[2] then 
          Match := true
       else 
          Match := false ;
     end ;

{ *************************************************************************
     Search the data base.
************************************************************************* }
  procedure SearchDataBase(Var NewMode : short_integer ) ;

    var
       InputStr: Str255 ;
       i,
       Counter : short_integer ;
       RecStr  : array[1..2] of Str255 ;
       ScrRec  : ScrPtr ;
       CurRec,
       SearchRec : DataPtr ;
       Match,
       CompareFlag : boolean ;

     begin
       CurRec := D_FirstRec[DataNum] ;
       Counter := 1 ;
       SearchRec := D_LastRec[DataNum] ;
       While CurRec <> D_LastRec[DataNum] do
          begin
            ScrRec := S_FirstRec[ScrNum] ;
            C_CurRec := C_FirstRec ;
            Match := true ;
            While ScrRec <> nil do
               begin
                 GetStr(SearchRec, RecStr[1], 
                        ScrRec^.Offset, ScrRec^.Size) ;
                 CompareFlag := false ;
                 if ScrRec^.DataType = 'F' then
                    begin
                      if Length(RecStr[1]) > 1 then
                         CompareFlag := true ;
                    end
                 else
                    if Length(RecStr[1]) > 0 then
                       CompareFlag := true ;
                 if CompareFlag then
                    begin
                      GetStr(CurRec, RecStr[2], ScrRec^.Offset, 
                             ScrRec^.Size) ;
                      Case C_CurRec^.Match of
                              { MemRec  =  SearchRec }
                          1 : ChkEqual(ScrRec, CurRec, SearchRec,
                                       RecStr[1], RecStr[2], Match) ;
                              { MemRec  >  SearchRec }
                          2 : ChkGreater(ScrRec, CurRec, SearchRec,
                                         RecStr[1], RecStr[2], Match ) ;
                              { MemRec  <  SearchRec }
                          3 : ChkLess(ScrRec, CurRec, SearchRec,
                                      RecStr[1], RecStr[2], Match ) ;
                              { MemRec  <>  SearchRec }
                          4 : ChkNotEqual(ScrRec, CurRec, SearchRec,
                                          RecStr[1], RecStr[2], Match ) ;
                              { MemRec  <=  SearchRec }
                          5 : ChkLessEqual(ScrRec, CurRec, SearchRec,
                                           RecStr[1], RecStr[2], Match ) ;
                              { MemRec  >=  SearchRec }
                          6 : ChkGreatEqual(ScrRec, CurRec, SearchRec,
                                            RecStr[1], RecStr[2], Match ) ;
                      end ;
                    end ;
                 if Match then
                    begin
                      ScrRec := ScrRec^.Next ;
                      C_CurRec := C_CurRec^.Next ;
                    end
                 else
                    ScrRec := nil ;
               end ;
            if Match then
               Int_AddARec(F_FirstRec,F_CurRec,F_LastRec, Counter) ;
            Counter := Counter + 1 ;
            CurRec := CurRec^.Next ;
          end ;

       Mode := 2 ;
       DS_DeleteARec(D_LastRec[DataNum]) ;
       Mode := 3 ;
       D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
       if F_FirstRec <> nil then
          begin
            F_CurRec := F_FirstRec ;
            F_RecNo[DataNum] := 1 ;
            for i := 2 to F_CurRec^.Match do
                D_CurrentRec[DataNum] := 
                             D_CurrentRec[DataNum]^.Next ;
            RecNo[DataNum] := i - 1 ;
          end
       else
          begin
            NewMode := 2 ;
            RecNo[DataNum] := 1 ;
            AlertStr := '[2][  |No Records Match|]' ;
            AlertStr := Concat(AlertStr, '[ Continue ]') ;
            Result   := Do_Alert(AlertStr,1) ;
          end ;
            
       F_CurRec := F_FirstRec ;
       F_TotalRec[DataNum] := 0 ;
       While F_CurRec <> nil do
          begin
            F_TotalRec[DataNum] := F_TotalRec[DataNum] + 1 ;
            F_CurRec := F_CurRec^.Next ;
          end ;
       F_CurRec := F_FirstRec ;
       F_RecNo[DataNum] := 1 ;
     end ;

{ *************************  SORTING ROUTINES  *************************** }
{ *************************************************************************
     Compare records for sort.
************************************************************************* }
  procedure Compare( ScrRec : ScrPtr ; CurRec, SearchRec : DataPtr ;
                    Var Flag : byte) ;

    var
       i         : short_integer ;
       RecStr,
       SearchStr : Str255 ;
       Character : StrChar ;
       CharInt   : short_integer ;
       BoolChar  : StrChar ;
                         
     begin
       GetStr(CurRec, RecStr, ScrRec^.Offset, ScrRec^.Size) ;
       GetStr(SearchRec, SearchStr, ScrRec^.Offset, ScrRec^.Size) ;
       if ScrRec^.DataType = 'H' then
          begin
            GetChar(ScrRec^.Next, CurRec, BoolChar, ScrRec^.Next^.Offset) ;
            if BoolChar <> 'T' then
               LastNameFirst(RecStr) ;
            GetChar(ScrRec^.Next, SearchRec, BoolChar, ScrRec^.Next^.Offset) ;
            if BoolChar <> 'T' then
               LastNameFirst(SearchStr) ;
          end ;

       Character := ScrRec^.DataType ;
       GetAscii(Character, CharInt ) ;

       Case CharInt of
           $41, 
           $48 : CompStr(RecStr, SearchStr, Flag) ;
           $42 : CompBoolean(RecStr, SearchStr, Flag) ;
           $43,
           $44,
           $45 : CompNum(RecStr, SearchStr, Flag) ;
           $46 : CompDollar(RecStr, SearchStr, Flag) ;
           $47 : CompDate(RecStr, SearchStr, Flag) ;
       end ;
     end ;

{ *************************************************************************
     Sort Records Subroutine.
************************************************************************* }
  procedure QuickSort(    Start, Finish : short_integer ; 
                      Var TempRec, CheckRec : DataPtr ; ScrRec : ScrPtr ;
                          Ascend : boolean) ;
  
    var
       i,
       StartValue,
       Left,
       Right      : short_integer ;
       LeftRec,
       RightRec,
       StartRec   : DataPtr ;
       LeftStr,
       RightStr,
       StartStr   : Str255 ;
       Flag       : byte ;

     procedure DecRec(Var Index : short_integer ;
                      Var CurStr : Str255 ; 
                      Var CurRec : DataPtr ;
                          ScrRec : ScrPtr ) ;

        begin
          Index := Index - 1 ;
          if CurRec <> nil then
             CurRec := CurRec^.Prev ;
        end ;

     procedure IncRec(Var Index : short_integer ;
                      Var CurStr : Str255 ; 
                      Var CurRec : DataPtr ;
                          ScrRec : ScrPtr ) ;

        begin
          Index := Index + 1 ;
          if CurRec <> nil then
             CurRec := CurRec^.Next ;
        end ;

     procedure SortNextLevel(    FirstRec, SecondRec : DataPtr ;
                             Var Flag : byte ) ;
     
       Var
          i        : short_integer ;
          NextRec  : ScrPtr ;
          ExitFlag : boolean ;
          Ascend   : array[1..2] of boolean ;
     
        begin
          ExitFlag := false ;
          repeat 
            if F_CurRec^.Next <> nil then
               begin
                 C_CurRec := C_CurRec^.Next ;
                 if C_FirstRec^.Match = 1 then
                    Ascend[1] := true
                 else
                    Ascend[1] := false ;
                 if C_CurRec^.Match = 1 then
                    Ascend[2] := true
                 else
                    Ascend[2] := false ;
                 NextRec := S_FirstRec[ScrNum] ;
                 F_CurRec := F_CurRec^.Next ;
                 for i := 2 to F_CurRec^.Match do
                     NextRec := NextRec^.Next ;
                 Compare(NextRec, FirstRec, SecondRec, Flag) ;
                 if Flag <> 2 then
                    begin
                      if Ascend[1] <> Ascend[2] then
                         begin
                           if Flag = 1 then
                              Flag := 0
                           else
                              if Flag = 0 then
                                 Flag := 1 ;
                         end ;
                      ExitFlag := true ;
                    end ;
               end 
            else
               begin
                 Flag := 2 ;
                 ExitFlag := true ;
               end ;
          until ExitFlag ;
          F_CurRec := F_FirstRec ;
          C_CurRec := C_FirstRec ;
        end ;


     begin
       Left := Start ;
       LeftRec := D_FirstRec[DataNum] ;
       for i := 2 to Left do
           LeftRec := LeftRec^.Next ;

       Right := Finish ;
       RightRec := D_FirstRec[DataNum] ;
       for i := 2 to Right do
           RightRec := RightRec^.Next ;

       StartValue := (Start + Finish) DIV 2 ;
       StartRec := D_FirstRec[DataNum] ;
       for i := 2 to StartValue do
           StartRec := StartRec^.Next ;
       CheckRec^ := StartRec^ ;

       repeat
         Compare(ScrRec, LeftRec, CheckRec, Flag) ;
         if (Flag = 2) AND (LeftRec <> CheckRec) then
            SortNextLevel(LeftRec, CheckRec, Flag) ;
         while ((Flag = 1) AND Ascend) OR
               ((Flag = 0) AND NOT Ascend) do
            begin
              Left := Left + 1 ;
              LeftRec := LeftRec^.Next ;
              Compare(ScrRec, LeftRec, CheckRec, Flag) ;
              if (Flag = 2) AND (LeftRec <> CheckRec) then
                 SortNextLevel(LeftRec, CheckRec, Flag) ;
            end ;

         Compare(ScrRec, CheckRec, RightRec, Flag) ;
         if (Flag = 2) AND (CheckRec <> RightRec) then
            SortNextLevel(CheckRec, RightRec, Flag) ;
         while ((Flag = 1) AND Ascend) OR
               ((Flag = 0) AND NOT Ascend) do
            begin
              Right := Right - 1 ;
              RightRec := RightRec^.Prev ;
              Compare(ScrRec, CheckRec, RightRec, Flag) ;
              if (Flag = 2) AND (CheckRec <> RightRec) then
                 SortNextLevel(CheckRec, RightRec, Flag) ;
            end ;

         if Left <= Right then 
            begin
              TempRec^.Data  := LeftRec^.Data ;
              LeftRec^.Data  := RightRec^.Data ;
              RightRec^.Data := TempRec^.Data ;
              IncRec(Left, LeftStr, LeftRec, ScrRec) ;
              DecRec(Right, RightStr, RightRec, ScrRec) ;
            end ; 
       until Right <= Left ;

       if Start < Right then QuickSort(Start, Right, TempRec, CheckRec,
                                       ScrRec, Ascend) ;
       if Left < Finish then QuickSort(Left, Finish, TempRec, CheckRec,
                                       ScrRec, Ascend) ;
     end ;


  procedure SortRecords(CurRec : DataPtr ; Var NewMode : short_integer ) ;

    var
      i : short_integer ;
      TempRec,
      CheckRec: DataPtr ;
      ScrRec  : ScrPtr ;
      Ascend  : boolean ;
      Value   : short_integer ;
      CurChar : StrChar ;

     begin
       F_CurRec := F_FirstRec ;
       while F_CurRec <> nil do
         begin
           ScrRec := S_FirstRec[ScrNum] ;
           for i := 2 to F_CurRec^.Match do
               ScrRec := ScrRec^.Next ;
           GetChar(ScrRec, D_LastRec[DataNum], CurChar, ScrRec^.Offset) ;
           
           if CurChar = chr(3) then
              Value := 1
           else
              Value := 0 ;
           Int_AddARec(C_FirstRec, C_CurRec, C_LastRec, Value ) ;
           F_CurRec := F_CurRec^.Next ;
         end ;
       
       C_CurRec := C_FirstRec ;
       F_CurRec := F_FirstRec ;
       ScrRec := S_FirstRec[ScrNum] ;
       for i := 2 to F_CurRec^.Match do
           ScrRec := ScrRec^.Next ;
       
       if C_CurRec^.Match = 1 then
          Ascend := true
       else
          Ascend := false ;

       DS_DeleteARec(D_LastRec[DataNum]) ;

       new(TempRec) ;
       new(CheckRec) ;
       QuickSort(1, TotalRec[DataNum], TempRec, CheckRec, ScrRec, Ascend) ;
       RecNo[DataNum] := 1 ;
       D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
       NewMode := 2 ;
     end ;

BEGIN
END .

