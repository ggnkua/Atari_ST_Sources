{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program Resource_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{   **********************  External  **********************************   }
  procedure DrawScreen( CurRec : ScrPtr ) ;
     External ;

  procedure DrawAField( CurRec : ScrPtr ) ;
     External ;

  procedure DrawRecord( CurRec : DataPtr ) ;
     External ;

  procedure DrawDesign ;
     External ;

  procedure DrawDZ_Out ;
     External ;
     
  procedure EraseARec( CurRec : ScrPtr ) ;
     External ;

  procedure PrintRec(DataRec : DataPtr ) ;
     External ;

  procedure M_PrintRec ;
     External ;

  procedure PrintReport ;
     External ;

  procedure DisposeRecs(Var FirstRec, CurRec, LastRec : ScrPtr ) ;
     External ;

  procedure DisposeInt(Var FirstRec, CurRec, LastRec : IntPtr ) ;
     External ;

  procedure UpdateInfoLine ;
     External ;

  procedure IncrementRecord(Var  CurRec : DataPtr ; Value : short_integer ;
                                 DrawFlag : boolean ) ;
     External ;
     
  procedure GoToFirst(Var CurRec : DataPtr ; DrawFlag : boolean ) ;
     External ;
     
  procedure GoToLast(Var CurRec : DataPtr ; DrawFlag : boolean) ;
     External ;
     
  procedure ClearRecord( CurRec : DataPtr ) ;
     External ;

  procedure CreateDataRec(ScrNum : short_integer) ;
     External ;

  procedure DeleteRecord ;
     External ;
     
  procedure DeleteScrRec ;
     External ;

  procedure DeleteARec(CurRec : ScrPtr) ;
     External ;

  procedure DS_DeleteARec(CurRec : DataPtr) ;
     External ;

  procedure DetCurRec(    D_CurRec : DataStorePtr ;
                      Var CurRec   : DataStorePtr ;  
                      Var Location : short_integer ) ;
     External ;

  procedure ModifyStr(CurRec : DataPtr ; Location : short_integer ; 
                      InChar : char) ;
     External ;

  procedure EraseCursor(ScrMode : short_integer) ;
     External ;

  procedure NewCursor(ScrMode : short_integer) ;
     External ;

  procedure CheckCurLoc(Var CurLoc : short_integer ;
                        Var Current : ScrPtr ; 
                            XPos, YPos, ScrMode : short_integer ) ;
     External ;

  procedure CheckOverLap( NewRec : ScrPtr ; X, Y : short_integer ;
                         Var OverLap : boolean ) ;
     External ;

  procedure AddARec(Var FirstRec, CurRec, LastRec, ScrRec : ScrPtr ;
                        TitleStr : Str255 ;
                        XCur, YCur, Size : short_integer ;
                        DataType : char ; ScrNum : short_integer) ;
     External ;

  procedure Int_AddARec(Var FirstRec, CurRec, LastRec : IntPtr ; 
                            Value : short_integer ) ;
     External ;

  procedure CalcOffset(    FirstRec, CurRec : ScrPtr ; 
                       Var Offset : short_integer ) ;
     External ;

  procedure SaveDataBase(ModeNumber : short_integer) ;
     External ;

  procedure GetDataBase ;
     External ;

  procedure MergeDataBase ;
     External ;

  procedure SaveScrnInfo ;
     External ;

  procedure OpenScrnInfo( Var Flag : boolean) ;
     External ;

  procedure GetPrtInfo ;
     External ;

  procedure SavePrtInfo ;
     External ;

  procedure SortRecords(CurRec : DataPtr; Var NewMode : short_integer ) ;
     External ;

  procedure SearchDataBase(Var NewMode : short_integer ) ;
     External ;

  procedure D_DisposeRecs(Var FirstRec, CurRec, LastRec : DataPtr ) ;
     External ;

  procedure ClrHome ;
     External ;

  procedure FormatCheck( CurRec : DataPtr ) ;
     External ;     

  procedure ModifyWName ;
     External ;

  procedure GetStr(CurRec : DataPtr ; Var DisplayStr : Str255 ;
                   Start, Size : short_integer ) ;
     External ;

  procedure FillString(Var SourceStr : Str50 ; FillChar : char ) ;
     External ;

  procedure InitPrinter(PrintInit : Str20) ;
     External ;

  procedure Set_VSlideSize ;
     External ;

  procedure Event_Loop ;
     External ;

  procedure Press_Tab ;
     External ;
     
  procedure DiskError(IO_Result : short_integer ) ;
     EXTERNAL ;
     
{   ********************************************************************   }

{ *************************************************************************
     Save Decision presents an alert box warning of possible loss of data
     due to an open or close request.
************************************************************************* }
  procedure SaveDecision(Var Result : short_integer) ;

     begin
       if D_FirstRec[DataNum] <> nil then
          begin
            if EditFlag[ScrNum] then
               begin
                 AlertStr := '[2][  |You May Lose Modified Data| ' ;
                 AlertStr := Concat(AlertStr, '|     Data Disposition|  ]') ;
                 AlertStr := Concat(AlertStr, '[ Save | Ignore | Cancel ]') ;
                 Result   := Do_Alert(AlertStr,1) ;
                 if Result = 1 then
                    SaveDataBase(DataNum) ;
               end
            else
               Result := 2 ;
          end
       else
          Result := 2 ;
     end ;

{ *************************************************************************
     D_SaveDecision presents an alert box warning of possible loss of data
     due to an open or close request.
************************************************************************* }
  procedure D_SaveDecision(Var Result : short_integer) ;

     begin
       if S_FirstRec[ScrNum] <> nil then
          begin
            if D_EditFlag[ScrNum] then
               begin
                 AlertStr := '[2][             |You May Lose Modified Design| ' ;
                 AlertStr := Concat(AlertStr, '|     Design Disposition? |  ]') ;
                 AlertStr := Concat(AlertStr, '[ Save | Ignore | Cancel ]') ;
                 Result   := Do_Alert(AlertStr,1) ;
                 if Result = 1 then
                    SaveScrnInfo ;
               end
            else
               Result := 2 ;
          end
       else
          Result := 2 ;
     end ;
{ *************************************************************************
     R_SaveDecision presents an alert box warning of possible loss of data
     due to an open or close request.
************************************************************************* }
  procedure R_SaveDecision(Var Result : short_integer) ;

     begin
       AlertStr := '[2][             |You May Lose Report Design| ' ;
       AlertStr := Concat(AlertStr, '|       Disposition? |  ]') ;
       AlertStr := Concat(AlertStr, '[ Save | Ignore | Cancel ]') ;
       Result   := Do_Alert(AlertStr,1) ;
       if Result = 1 then
          SavePrtInfo ;
     end ;

{ *************************************************************************
     Alert box presents decision to merge data base in memory with one
     on disk or replace memory data base with one on disk.
************************************************************************* }
  procedure MergeDecision(Var Result : short_integer) ;

     begin
       if D_FirstRec[DataNum] <> nil then
          begin
            AlertStr := '[2][|    Replace Database or    | ' ;
            AlertStr := Concat(AlertStr, '|      Merge Data Base   |  ]') ;
            AlertStr := Concat(AlertStr, '[ Merge | Replace | Cancel ]') ;
            Result   := Do_Alert(AlertStr,2) ;
          end ;
     end ;

{ *************************************************************************
     Dialog Box to input Report parameters.
************************************************************************* }
  procedure ReportSetUp(Var AbortFlag : boolean ) ;

    Var
       i, 
       SaveMode  : short_integer ;
       Out       : Dialog_Ptr;
       OutScreen : Tree_Index;
       OutItem   : array[1..23] of short_integer;
       LabStr    : array[1..3] of Str20 ;
       RepStr    : Str20 ;
       GetEditStr    : Str255 ;
       DataRec   : DataStorePtr ;
       Result    : short_integer ;

     begin
       WriteV(LabStr[1], LabSpace[1]) ;
       WriteV(LabStr[2], LabLine) ;
       WriteV(LabStr[3], LabSpace[2]) ;
       WriteV(RepStr, RepLine) ;
       SaveMode := P_Mode ;

       Out := New_Dialog(23, 0, 0, 70, 22);
       Center_Dialog(Out);

       OutItem[1] := Add_DItem(Out, G_BoxText, 0, 
                               25, 1, 20, 1, -1, 4096 | 256 | 128);
       Set_DText(Out, OutItem[1], ' Report Parameters ' ,
                 System_Font, TE_Center);

       OutItem[2] := Add_DItem(Out, G_IBox, 0, 
                               1, 3, 48, 9, -1, 4096 | 256 | 128);

       OutItem[3] := Add_DItem(Out, G_IBox, 0, 
                               54, 3, 12, 18, -1, 4096 | 256 | 128);

       OutItem[4] := Add_DItem(Out, G_IBox, 0, 
                               1, 12, 48, 9, -1, 4096 | 256 | 128);

       OutItem[5] := Add_DItem(Out, G_IBox, 0, 
                               1, 12, 48, 9, -1, 4096 | 256 | 128);


       OutItem[6] := Add_DItem(Out, G_FText, Editable,
                                 30, 4, 16, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[6], 'Report Lines   _', 
                                  '9', 
                                  RepStr, System_Font, TE_Center);

       OutItem[7] := Add_DItem(Out, G_FText, Editable,
                                 30, 6, 16, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[7], 'Top Lines     __', 
                                            '99', 
                                   LabStr[1], System_Font, TE_Center);

       OutItem[8] := Add_DItem(Out, G_FText, Editable,
                                 30, 8, 16, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[8], 'Label Lines   __', 
                                                '99', 
                                   LabStr[2], System_Font, TE_Center);

       OutItem[9] := Add_DItem(Out, G_FText, Editable,
                                 30, 10, 16, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[9], 'Bottom Lines  __', 
                                               '99', 
                                   LabStr[3], System_Font, TE_Center);

       OutItem[10] := Add_DItem(Out, G_FText, Editable,
                                 18, 13, 27, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[10], 'Init : ____________________', 
                                          'XXXXXXXXXXXXXXXXXXXX', 
                                          PrtInit[1], System_Font, TE_Center);

       OutItem[11] := Add_DITem(Out, G_BoxText, 
                                   Selectable | Radio_Btn ,
                                   5, 4, 14, 1, -2, 4096 | 256 | 128) ;
       Set_DText(Out, OutItem[11], 'Report', System_Font, TE_Center) ;

       OutItem[12] := Add_DITem(Out, G_BoxText, 
                                   Selectable | Radio_Btn ,
                                   5, 7, 14, 1, -2, 4096 | 256 | 128) ;
       Set_DText(Out, OutItem[12], 'Single Label', System_Font, TE_Center) ;

       OutItem[13] := Add_DITem(Out, G_BoxText, 
                                   Selectable | Radio_Btn ,
                                   5, 9, 14, 1, -2, 4096 | 256 | 128) ;
       Set_DText(Out, OutItem[13], 'Multi Label', System_Font, TE_Center) ;

       OutItem[14] := Add_DItem(Out, G_BoxText, 
                                 Default | Exit_Btn | Selectable,
                                 55, 7, 10, 1, -3, 4096 | 256 | 128);
       Set_DText(Out, OutItem[14], 
                                 'Continue', System_Font, TE_Center);

       OutItem[15] := Add_DItem(Out, G_BoxText, 
                                 Exit_Btn | Selectable,
                                 55, 10, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(Out, OutItem[15], 
                                 'Abort', System_Font, TE_Center);

       OutItem[16] := Add_DItem(Out, G_BoxText, 
                                 Selectable,
                                 3, 13, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(Out, OutItem[16], 
                                 'WIDE', System_Font, TE_Center);

       OutItem[17] := Add_DITem(Out, G_BoxText, 
                                   Selectable | Exit_Btn | Radio_Btn ,
                                   55, 4, 10, 1, -2, 4096 | 256 | 128) ;
       Set_DText(Out, OutItem[17], 'LOAD', System_Font, TE_Center) ;


       OutItem[18] := Add_DItem(Out, G_BoxText, 
                                 Selectable,
                                 3, 15, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(Out, OutItem[18], 
                                 'BOLD', System_Font, TE_Center);

       OutItem[19] := Add_DItem(Out, G_FText, Editable,
                                 18, 15, 27, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[19], 'Bold : ____________________', 
                                          'XXXXXXXXXXXXXXXXXXXX', 
                                          PrtInit[2], System_Font, TE_Center);

       OutItem[20] := Add_DItem(Out, G_BoxText, 
                                 Selectable,
                                 3, 17, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(Out, OutItem[20], 
                                 'ITALICS', System_Font, TE_Center);

       OutItem[21] := Add_DItem(Out, G_FText, Editable,
                                 18, 17, 27, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[21], 'Ital : ____________________', 
                                          'XXXXXXXXXXXXXXXXXXXX', 
                                          PrtInit[3], System_Font, TE_Center);

       OutItem[22] := Add_DItem(Out, G_BoxText, 
                                 Selectable,
                                 3, 19, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(Out, OutItem[22], 
                                 'SPECIAL', System_Font, TE_Center);

       OutItem[23] := Add_DItem(Out, G_FText, Editable,
                                 18, 19, 27, 1, 0, 256 | 128);
       Set_DEdit(Out, OutItem[23], 'Spec : ____________________', 
                                          'XXXXXXXXXXXXXXXXXXXX', 
                                          PrtInit[4], System_Font, TE_Center);

       if P_Mode = 2 then
          Obj_SetState(Out, OutItem[11], Selected, false)
       else
          if P_Mode = 1 then
             Obj_SetState(Out, OutItem[13], Selected, false)
          else
             Obj_SetState(Out, OutItem[12], Selected, false) ;

       for i := 1 to 4 do
           if PrtFlag[i] then
              Obj_SetState(Out, OutItem[14 + i * 2], Selected, false) ;

       OutScreen := Do_Dialog(Out, 6);

       if OutScreen = 17 then
          begin
            Result := 1 ;
            if R_EditFlag then
               R_SaveDecision(Result) ;
            if Result <> 3 then
               GetPrtInfo 
            else
               AbortFlag := true ;
            ShortDraw := true ;
            Event_Loop ;
          end
       else

       if OutScreen <> 15 then
          begin
            AbortFlag := false ;
            for i := 11 to 13 do
                if Obj_State(Out, OutItem[i]) & Selected <> 0 then
                   Case i of
                     11 : P_Mode := 2 ;
                     12 : P_Mode := 0 ;
                     13 : P_Mode := 1 ;
                   end ;
            
            for i := 1 to 4 do
                if Obj_State(Out, OutItem[14 + i * 2]) & Selected <> 0 then
                   PrtFlag[i] := true
                else
                   PrtFlag[i] := false ;
            if Obj_State(Out, OutItem[16]) & Selected <> 0 then
               RepWidth := 132
            else
               RepWidth := 80 ;

            Get_DEdit(Out, OutItem[10], GetEditStr);
            PrtInit[1] := GetEditStr ;
            Get_DEdit(Out, OutItem[19], GetEditStr);
            PrtInit[2] := GetEditStr ;
            Get_DEdit(Out, OutItem[21], GetEditStr);
            PrtInit[3] := GetEditStr ;
            Get_DEdit(Out, OutItem[23], GetEditStr);
            PrtInit[4] := GetEditStr ;
            
            Get_DEdit(Out, OutItem[6], GetEditStr);
            if GetEditStr <> '' then
               begin
                 ReadV(GetEditStr, RepLine) ;
                 if RepLine > 4 then RepLine := 4
                 else
                    if RepLine < 1 then RepLine := 1 ;
               end
            else
               RepLine := 1 ;

            Get_DEdit(Out, OutItem[7], GetEditStr);
            if GetEditStr <> '' then
               ReadV(GetEditStr, LabSpace[1])
            else
               LabSpace[1] := 0 ;

            Get_DEdit(Out, OutItem[8], GetEditStr) ;
            if GetEditStr <> '' then
               begin
                 ReadV(GetEditStr, LabLine) ;
                 if LabLine > 10 then LabLine := 10
                 else
                    if LabLine < 1 then LabLine := 1 ;
               end
            else
               LabLine := 5 ;

            Get_DEdit(Out, OutItem[9], GetEditStr);
            if GetEditStr <> '' then
               ReadV(GetEditStr, LabSpace[2])
            else
               LabSpace[2] := 1 ;
            if P_Mode <> SaveMode then
               begin
                 Result := 1 ;
                 if R_EditFlag then
                    R_SaveDecision(Result) ;
                 if Result <> 3 then
                    begin
                      DataRec := D_CurrentRec[Report]^.Data ;
                      While DataRec <> nil do
                        begin
                          FillString(DataRec^.DataStr, chr($20)) ;
                          DataRec := DataRec^.Next ;
                        end ;
                    end ;
               end
            else
               P_Mode := SaveMode ;
          end
       else
          AbortFlag := true ;

       End_Dialog(Out);
       Delete_Dialog(Out);
       if Mode = 5 then
          DrawDesign ;
       ShortDraw := true ;
     end ;
{ *************************************************************************
     AcceptTitle displays a dialog box to allow entry of pertinent
     information about a new record field.
************************************************************************* }
  procedure AcceptTitle(    DisplayStr : Str255 ; 
                        Var ResultStr  : Window_Title ;
                        Var Size,
                            XPos, 
                            YPos     : short_integer ;
                        Var DataType : char ;
                        Var Result   : boolean  ) ;

    var
       i,
       StartSize     : short_integer ;
       TitleIn       : Dialog_Ptr;
       TitleInScreen : Tree_Index;
       TitleInItem   : array[1..16] of short_integer;
       GetEditStr    : Str255 ;
       XStr, YStr,
       SpStr, DecStr : Str20 ;
       TypeSelect    : boolean ;
       
     begin
       WriteV(XStr, XPos) ;
       WriteV(YStr, YPos) ;
       WriteV(SpStr, Size) ;
       WriteV(DecStr, DecReal) ;
       TitleIn := New_Dialog(16, 0, 0, 50, 18);
       Center_Dialog(TitleIn);

       TitleInItem[1] := Add_DItem(TitleIn, G_BoxText, 0, 
                                 15, 1, 16, 1, -1, 4096 | 256 | 128);
       Set_DText(TitleIn, TitleInItem[1], DisplayStr,
                 System_Font, TE_Center);

       TitleInItem[2] := Add_DItem(TitleIn, G_FBoxText, Editable,
                                 5, 3, 40, 2, 0, 4096 | 256 | 128);
       Set_DEdit(TitleIn, TitleInItem[2], 
                          'Enter Field Label: ____________________', 
                                             'XXXXXXXXXXXXXXXXXXXX', 
                           ResultStr, System_Font, TE_Center);

       TitleInItem[3] := Add_DItem(TitleIn, G_FText, Editable,
                                 4, 6, 14, 1, 0, 256 | 128);
       Set_DEdit(TitleIn, TitleInItem[3], 'X Position: __', 
                                          '99', 
                                           XStr, System_Font, TE_Center);

       TitleInItem[4] := Add_DItem(TitleIn, G_FText, Editable,
                                 4, 8, 14, 1, 0, 256 | 128);
       Set_DEdit(TitleIn, TitleInItem[4], 'Y Position: __', 
                                          '99', 
                                          YStr, System_Font, TE_Center);

       TitleInItem[5] := Add_DItem(TitleIn, G_FText, Editable,
                                 4, 10, 14, 1, 0, 256 | 128);
       Set_DEdit(TitleIn, TitleInItem[5], 'Max Size:   __', 
                                          '99', 
                                           SpStr, System_Font, TE_Center);

       TitleInItem[6] := Add_DItem(TitleIn, G_FText, Editable,
                                 4, 12, 16, 1, 0, 256 | 128);
       Set_DEdit(TitleIn, TitleInItem[6], 'Real Decimal : _', 
                                          '9', 
                                           DecStr, System_Font, TE_Center);

       TitleInItem[7] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   24, 7, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[7], 'String', System_Font, TE_Center) ;

       TitleInItem[8] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   24, 9, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[8], 'Boolean', System_Font, TE_Center) ;

       TitleInItem[9] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   24, 11, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[9], 'Integer', System_Font, TE_Center) ;

       TitleInItem[10] := Add_DITem(TitleIn, G_Text, 
                                   None,
                                   24, 13, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[10], '', System_Font, TE_Center) ;

       TitleInItem[11] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   38, 7, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[11], 'Real', System_Font, TE_Center) ;

       TitleInItem[12] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   38, 9, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[12], '$', System_Font, TE_Center) ;

       TitleInItem[13] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   38, 11, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[13], 'Date', System_Font, TE_Center) ;

       TitleInItem[14] := Add_DITem(TitleIn, G_Button, 
                                   Selectable | Radio_Btn ,
                                   38, 13, 8, 1, -1, 256 | 128) ;
       Set_DText(TitleIn, TitleInItem[14], 'Name', System_Font, TE_Center) ;


       TitleInItem[15] := Add_DItem(TitleIn, G_BoxText, 
                                 Default | Exit_Btn | Selectable,
                                 5, 14, 10, 1, -3, 4096 | 256 | 128);
       Set_DText(TitleIn, TitleInItem[15], 
                                 'Continue', System_Font, TE_Center);

       TitleInItem[16] := Add_DItem(TitleIn, G_BoxText, 
                                 Exit_Btn | Selectable,
                                 5, 16, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(TitleIn, TitleInItem[16], 
                                 'Delete', System_Font, TE_Center);

       TypeSelect := false ;
       for i := $41 to $49 do
           if chr(i) = DataType then
              begin
                Obj_SetState(TitleIn, TitleInItem[i - $3A], Selected, false) ;
                TypeSelect := true ;
              end ;
       if NOT TypeSelect then
          Obj_SetState(TitleIn, TitleInItem[7], Selected, false) ;

       TitleInScreen := Do_Dialog(TitleIn, 2);

       if TitleInScreen <> 16 then
          begin
            Get_DEdit(TitleIn, TitleInItem[2], GetEditStr);
            ResultStr := GetEditStr ;

            Get_DEdit(TitleIn, TitleInItem[3], GetEditStr);
            if GetEditStr <> '' then
               ReadV(GetEditStr, XPos) 
            else
               XPos := 1 ;

            Get_DEdit(TitleIn, TitleInItem[4], GetEditStr);
            if GetEditStr <> '' then
               ReadV(GetEditStr, YPos) 
            else
               YPos := 1 ;

            Get_DEdit(TitleIn, TitleInItem[5], GetEditStr);
            if GetEditStr <> '' then
               ReadV(GetEditStr, Size)
            else
               Size := 1 ;
            
            if ((XPos + Length(ResultStr) + Size > 72) OR (XPos < 1)) AND
               (XPos > 1) then
               begin
                 AlertStr := '[2][|  Modifying X Position | ' ;
                 AlertStr := Concat(AlertStr, '|   Change if Desired|  ]') ;
                 AlertStr := Concat(AlertStr, '[ Continue]') ;
                 i := Do_Alert(AlertStr,1) ;
               end ;
            if XPos < 1 then 
               XPos := 1
            else
               if XPos > 1 then
                  repeat
                    if Size > 72 - Length(ResultStr) - XPos then
                       XPos := XPos - 1 ;
                  until (Size <= 72 - Length(ResultStr) - XPos) OR (XPos < 2)  ;

            if (YPos > 14) OR (YPos < 1) then
               begin
                 AlertStr := '[2][|  Modifying Y Position| ' ;
                 AlertStr := Concat(AlertStr, '|   Change if Desired|  ]') ;
                 AlertStr := Concat(AlertStr, '[ Continue]') ;
                 i := Do_Alert(AlertStr,1) ;
               end ;
            if YPos > 14 then YPos := 14
            else
               if YPos < 1 then YPos := 1 ;

            if Size < 1 then Size := 1
            else
               begin
                 StartSize := Size ;
                 if Size > 72 - Length(ResultStr) - XPos then
                    Size := 72 - Length(ResultStr) - XPos ;
                 if Size < 0 then Size  := 1 ;
                 if Size <> StartSize then
                    begin
                      AlertStr := '[2][  |  Altering Size of Field  | ' ;
                      AlertStr := Concat(AlertStr, '|     Modify if Desired|  ]') ;
                      AlertStr := Concat(AlertStr, '[ Continue]') ;
                      i := Do_Alert(AlertStr,1) ;
                    end ;
               end ;

            Get_DEdit(TitleIn, TitleInItem[6], GetEditStr);
            if GetEditStr <> '' then
               begin
                 ReadV(GetEditStr, DecReal) ;
                 if DecReal < 1 then DecReal := 1 ;
               end
            else
               DecReal := 1 ;

            for i := 7 to 14 do
                if Obj_State(TitleIn, TitleInItem[i]) & Selected <> 0 then
                   DataType := chr(i + $3A) ;

            if (DataType = 'B') OR (DataType = 'D') then
               Size := 1 ;

            Result := true ;
          end
       else
          Result := false ;

       End_Dialog(TitleIn);
       Delete_Dialog(TitleIn);
     end;

{ *************************************************************************
     Displays a dialog box with program and copyright information.
************************************************************************* }
  procedure CopyRight ;

    var
       CR       : Dialog_Ptr;
       CRScreen : Tree_Index;
       CRItem   : array[1..12] of short_integer;
       
     begin
       CR := New_Dialog(13, 0, 0, 42, 18);
       Center_Dialog(CR);

       CRItem[1] := Add_DItem(CR, G_BoxText, 0, 
                                 12, 1, 18, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[1], 'InfoBaseST', 
                                System_Font, TE_Center);

       CRItem[2] := Add_DItem(CR, G_Text, 0, 
                                 1, 3, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[2], 'Copyright (c) 1990', 
                                System_Font, TE_Center);

       CRItem[3] := Add_DItem(CR, G_Text, 0, 
                                 1, 5, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[3], 'Antic Publishing, Inc.', 
                                System_Font, TE_Center);

       CRItem[5] := Add_DItem(CR, G_Text, 0, 
                                 1, 12, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[5], '<><><><><><><><><><><><><><><><><><><><>', 
                                System_Font, TE_Center);

       CRItem[6] := Add_DItem(CR, G_Text, 0, 
                                 1, 13, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[6], '<>    Portions of this program are    <>', 
                                System_Font, TE_Center);

       CRItem[7] := Add_DItem(CR, G_Text, 0, 
                                 1, 14, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[7], '<>Copyright (c) 1986 CCD and OSS, Inc.<>', 
                                System_Font, TE_Center);

       CRItem[8] := Add_DItem(CR, G_Text, 0, 
                                 1, 15, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[8], '<>      Used by permission of OSS     <>', 
                                System_Font, TE_Center);

       CRItem[9] := Add_DItem(CR, G_Text, 0, 
                                 1, 16, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[9], '<><><><><><><><><><><><><><><><><><><><>', 
                                System_Font, TE_Center);

       CRItem[10] := Add_DItem(CR, G_BoxText, 
                                 Default | Exit_Btn | Selectable,
                                 16, 10, 10, 1, -3, 4096 | 256 | 128);
       Set_DText(CR, CRItem[10], 'Continue', System_Font, TE_Center);

       CRItem[11] := Add_DItem(CR, G_Text, 0, 
                                 1, 8, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[11], 'James W. Maki', 
                                System_Font, TE_Center);

       CRItem[12] := Add_DItem(CR, G_Text, 0, 
                                 1, 7, 40, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[12], 'by', 
                                System_Font, TE_Center);


       CRScreen := Do_Dialog(CR, 0);

       End_Dialog(CR);
       Delete_Dialog(CR);
     end;


  procedure HelpScreen ;
  
    TYPE
       HelpLine = STRING[57] ;

    var
       CR       : Dialog_Ptr;
       CRScreen : Tree_Index;
       CRItem   : array[1..35] of short_integer;

       i        : BYTE ;
       OutStr   : HelpLine ;
       HelpFv   : FILE OF HelpLine ;
       SaveIO_Result : SHORT_INTEGER ;
       
    LABEL 1 ;
       
     begin
       CR := New_Dialog(35, 0, 0, 70, 23);
       Center_Dialog(CR);

       CRItem[1] := Add_DItem(CR, G_Text, 0, 
                                 1, 1, 57, 1, -1, 4096 | 256 | 128);
       Set_DText(CR, CRItem[1], 'INFOBASEST HELP FACILITY', 
                                System_Font, TE_Center);

       CRItem[2] := Add_DItem(CR, G_Box,0, 
                                 59, 0, 11, 23, -2, 4096 | 256 | 128);

       CRItem[3] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 1, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[3], 'DataType', System_Font, TE_Center);

       CRItem[4] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 3, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[4], 'Keys', System_Font, TE_Center);

       CRItem[5] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 5, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[5], 'InfoLine', System_Font, TE_Center);

       CRItem[6] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 7, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[6], 'GEM', System_Font, TE_Center);

       CRItem[7] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 9, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[7], 'Cursor', System_Font, TE_Center);

       CRItem[8] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 11, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[8], 'Files', System_Font, TE_Center);

       CRItem[9] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 13, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[9], 'Filter', System_Font, TE_Center);

       CRItem[10] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 15, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[10], '@ Comms', System_Font, TE_Center);

       CRItem[11] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 17, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[11], 'Create', System_Font, TE_Center);

       CRItem[12] := Add_DItem(CR, G_BoxText, 
                                  Exit_Btn | Selectable,
                                 61, 19, 8, 1, -2, 4096 | 256 | 128);
       Set_DText(CR, CRItem[12], 'Mode', System_Font, TE_Center);

       CRItem[13] := Add_DItem(CR, G_BoxText, 
                                 Default | Exit_Btn | Selectable,
                                 61, 21, 8, 1, -3, 4096 | 256 | 128);
       Set_DText(CR, CRItem[13], 'EXIT', System_Font, TE_Center);

       IO_Check(false) ;
       RESET(HelpFv,HelpFileName) ;
       SaveIO_Result := IO_Result ;
       IF SaveIO_Result<>0 THEN GOTO 1 ;

       SEEK(HelpFv,1+(Mode+8)*21) ;
       SaveIO_Result:=IO_Result ;
       IF SaveIO_Result<>0 THEN GOTO 1 ;

       READ(HelpFv,OutStr) ;
       SaveIO_Result:=IO_Result ;
       IF SaveIO_Result<>0 THEN GOTO 1 ;
       
       
       FOR i:=1 TO 20 DO
           BEGIN
             READ(HelpFv,OutStr) ;
             SaveIO_Result:=IO_Result ;
             IF SaveIO_Result<>0 THEN GOTO 1 ;
             CRItem[13+i] := Add_DItem(CR, G_Text, 0,
                                 1, i+1, 57, 1, -3, 4096 | 256 | 128);
             Set_DText(CR, CRItem[13+i], OutStr, System_Font, TE_Left);
           END ;

       CRScreen := Do_Dialog(CR, 0);

       WHILE CRScreen<>13 DO
         BEGIN   
           IF CRScreen>3 THEN
              BEGIN
                IF CrScreen=12 THEN
                   SEEK(HelpFv,1+(Mode+8)*21)
                ELSE 
                   SEEK(HelpFv,1+(CRScreen-3)*21) ;
               END
           ELSE
              SEEK(HelpFv,1) ;
           SaveIO_Result:=IO_Result ;
           IF SaveIO_Result<>0 THEN GOTO 1 ;

           READ(HelpFv,OutStr) ;
           SaveIO_Result:=IO_Result ;
           IF SaveIO_Result<>0 THEN GOTO 1 ;
        
           FOR i:=5 TO 24 DO
               BEGIN
                 READ(HelpFv,OutStr) ;
                 SaveIO_Result:=IO_Result ;
                 IF SaveIO_Result<>0 THEN GOTO 1 ;
                
                 Draw_String(48,((i*8)-5)*RESOLUTION,OutStr) ;
               END ; 

           Obj_SetState(CR,CRScreen,Normal,TRUE) ;           
           CRScreen:=ReDo_Dialog(CR,0) ;
         END ;

1 :    IF SaveIO_Result<>0 THEN
          DiskError(SaveIO_Result) ;              
       IO_Check(TRUE) ;
          
       End_Dialog(CR);
       Delete_Dialog(CR);
       CLOSE(HelpFv) ;
     end;

{ *************************************************************************
     MenuOption Selects or Deselects menu options that will or will not
     be available for choice at any certain portion of the program.
     Items that will not be available are displayed in shadow text and
     Cannot be choosen with the mouse.
************************************************************************* }
  procedure MenuOption ;

    var
        i,
        CurLoc   : short_integer ;
        CurRec   : ScrPtr ;

     begin
       for i := 1 to 24 do
           Menu_Disable(InfoMenu, MenuItem.Item[i]) ;
        Case Mode of
           1 : begin
                 Menu_Enable(InfoMenu, MenuItem.Item[1]) ;
                 Menu_Enable(InfoMenu, MenuItem.Item[4]) ;
                 Menu_Enable(InfoMenu, MenuItem.Item[5]) ;
                 Menu_Enable(InfoMenu, MenuItem.Item[10]) ;
                 if S_FirstRec[ScrNum] <> nil then
                    begin
                      for i := 2 to 3 do
                          Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                      Menu_Enable(InfoMenu, MenuItem.Item[6]) ;
                      CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
                      if CurLoc >= 0 then
                         begin
                           Menu_Disable(InfoMenu, MenuItem.Item[10]) ;
                           Menu_Enable(InfoMenu, MenuItem.Item[11]) ;
                           Menu_Enable(InfoMenu, MenuItem.Item[19]) ;
                         end ;
                    end ;
               end ;
           2 : begin
                 Menu_Enable(InfoMenu, MenuItem.Item[1]) ;
                 for i := 3 to 6 do
                     Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                 if TotalRec[DataNum] > 1 then
                    begin
                      Menu_Enable(InfoMenu, MenuItem.Item[2]) ;
                      for i := 7 to 9 do
                          Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                      if D_CurrentRec[DataNum] <> D_LastRec[DataNum] then
                         begin
                           Menu_Enable(InfoMenu, MenuItem.Item[14]) ;
                           Menu_Enable(InfoMenu, MenuItem.Item[17]) ;
                         end ;
                      if D_CurrentRec[DataNum] <> D_FirstRec[DataNum] then
                         for i := 15 to 16 do
                             Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                    end ;
                 Menu_Enable(InfoMenu, MenuItem.Item[19]) ;
                 if NOT FullMemory then
                    Menu_Enable(InfoMenu, MenuItem.Item[21]) ;
                 if (D_FirstRec[Report] <> nil) AND
                    (R_EditFlag OR R_LoadFlag) then
                    for i := 22 to 24 do
                        Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
               end ;
           3 : if SearchFlag then
                  begin
                    Menu_Enable(InfoMenu, MenuItem.Item[6]) ;
                    Menu_Enable(InfoMenu, MenuItem.Item[12]) ;
                  end
               else
                  begin
                    Menu_Enable(InfoMenu, MenuItem.Item[2]) ;
                    Menu_Enable(InfoMenu, MenuItem.Item[6]) ;
                    Menu_Enable(InfoMenu, MenuItem.Item[7]) ;
                    Menu_Enable(InfoMenu, MenuItem.Item[9]) ;
                    if F_CurRec <> F_LastRec then
                       begin
                         Menu_Enable(InfoMenu, MenuItem.Item[14]) ;
                         Menu_Enable(InfoMenu, MenuItem.Item[17]) ;
                       end ;
                    if F_CurRec <> F_FirstRec then
                       for i := 15 to 16 do
                           Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                    Menu_Enable(InfoMenu, MenuItem.Item[19]) ;
                    if (D_FirstRec[Report] <> nil) AND
                       (R_EditFlag OR R_LoadFlag) then
                       for i := 22 to 24 do
                           Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                  end ;
           4 : begin
                 Menu_Enable(InfoMenu, MenuItem.Item[6]) ;
                 if F_FirstRec <> nil then
                    Menu_Enable(InfoMenu, MenuItem.Item[13]) ;
               end ;
           5 : begin
                 for i := 1 to 4 do
                     Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
                 if F_FirstRec <> nil then
                    Menu_Enable(InfoMenu, MenuItem.Item[7])
                 else
                    if D_FirstRec[DataNum] <> nil then
                       Menu_Enable(InfoMenu, MenuItem.Item[6])
                    else
                       Menu_Enable(InfoMenu, MenuItem.Item[5]) ;
                 Menu_Enable(InfoMenu, MenuItem.Item[9]) ;
                 if R_EditFlag OR R_LoadFlag then
                    for i := 22 to 24 do
                        Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
               end ;
           6 : begin
                 Menu_Enable(InfoMenu, MenuItem.Item[4]) ;
                 for i := 14 to 15 do
                     Menu_Enable(InfoMenu, MenuItem.Item[i]) ;
               end ;
        end ;
        
       for i := 5 to 9 do
           Menu_Check(InfoMenu, MenuItem.Item[i], false) ;
       Menu_Check(InfoMenu, MenuItem.Item[Mode + 4], true) ;
     end ;

{ *************************************************************************
     SetUpMenu creates and then displays the main menu of InfoBaseST.
************************************************************************* }
  procedure SetUpMenu;

     begin
       With MenuItem do
         begin
           InfoMenu := New_Menu(25, '  InfoBase ST  ');
  
           Title[1] := Add_MTitle(InfoMenu, ' File    ');
           Title[2] := Add_MTitle(InfoMenu, ' Mode    ');
           Title[3] := Add_MTitle(InfoMenu, ' Design  ');
           Title[4] := Add_MTitle(InfoMenu, ' Record  ');
           Title[5] := Add_MTitle(InfoMenu, ' Output  ');

           Item[1]  := Add_MItem(InfoMenu, Title[1], ' ^O - Open  ') ;
           Item[2]  := Add_MItem(InfoMenu, Title[1], ' ^S - Save  ') ;
           Item[3]  := Add_MItem(InfoMenu, Title[1], ' ^C - Clear ') ;
           Item[4]  := Add_MItem(InfoMenu, Title[1], ' ^Q - Quit  ') ;
  
           Item[5]  := Add_MItem(InfoMenu, Title[2], '  alt-D: Design ') ;
           Item[6]  := Add_MItem(InfoMenu, Title[2], '  alt-I: Input  ') ;
           Item[7]  := Add_MItem(InfoMenu, Title[2], '  alt-F: Search ') ;
           Item[8]  := Add_MItem(InfoMenu, Title[2], '  alt-S: Sort   ') ;
           Item[9]  := Add_MItem(InfoMenu, Title[2], '  alt-O: Output ') ;

           Item[10] := Add_MItem(InfoMenu, Title[3], ' ^E - Enter  ') ;
           Item[11] := Add_MItem(InfoMenu, Title[3], ' ^M - Modify ') ;

           Item[12] := Add_MItem(InfoMenu, Title[4], ' alt-F  Search   ') ;
           Item[13] := Add_MItem(InfoMenu, Title[4], ' alt-S  Sort     ') ;
           Item[14] := Add_MItem(InfoMenu, Title[4], '  Sh->  Next     ') ;
           Item[15] := Add_MItem(InfoMenu, Title[4], '  Sh<-  Previous ') ;
           Item[16] := Add_MItem(InfoMenu, Title[4], '  ^<-   FirstRec ') ;
           Item[17] := Add_MItem(InfoMenu, Title[4], '  ^->   Last Rec ') ;
           Item[18] := Add_MItem(InfoMenu, Title[4], '-----------------') ;
           Item[19] := Add_MItem(InfoMenu, Title[4], '   ^D   Delete   ') ;
           Item[20] := Add_MItem(InfoMenu, Title[4], '-----------------') ;
           Item[21] := Add_MItem(InfoMenu, Title[4], '   Tab  New Rec  ') ;

           Item[22] := Add_MItem(InfoMenu, Title[5], '   Print  ') ;
           Item[23] := Add_MItem(InfoMenu, Title[5], '   Disk   ') ;
           Item[24] := Add_MItem(InfoMenu, Title[5], '   Screen ') ;

         end;
       MenuOption ;
       Draw_Menu(InfoMenu);
    end;

{ *************************************************************************
     ExitProgram closes and deletes all open windows and sets ExitPrompt
     to true to exit the main loop in the main module.
************************************************************************* }
  procedure ExitProgram ;

     begin
       ExitPrompt := true ; 
       SaveDecision(Result) ;
       if Result <> 3 then
          D_SaveDecision(Result) ;
       if (Result <> 3) AND (R_EditFlag) then
          R_SaveDecision(Result) ;
       if Result <> 3 then
          begin
            if D_FirstRec[DataNum] <> nil then
               D_DisposeRecs(D_FirstRec[DataNum], D_CurrentRec[DataNum],
                             D_LastRec[DataNum]) ;
            Close_Window(WindNum) ;
            Delete_Window(WindNum) ;
            WindNum := -1 ;
          end
       else
          ExitPrompt := false ; 
     end ;

{ *************************************************************************
     Allows the user to modify a Screen Info field after it has been 
     Entered.  Called via menu or ^M while cursor is positioned on the
     field to be altered.
************************************************************************* }
  procedure ModifyScrn( Var CurRec : ScrPtr ; Var OverLap : boolean ) ;

    var
        TotalOffset : short_integer ;
        ScrRec      : ScrPtr ;
        NewRec    : ScrPtr ;
        TitleStr  : Str255 ;
        Result,
        ExitFlag  : boolean ;
        i,
        CurLoc    : short_integer ;
        NewMode   : short_integer ;
        Offset    : short_integer ;
        OldDataType,
        NewDataType : char ;

{ *************************************************************************
       Delete a Screen Info field from the current design screen.
************************************************************************* }
     procedure DeleteScrRec ;

       var
          TotalOffset : short_integer ;
          ScrRec      : ScrPtr ;

        begin
          Hide_Mouse ;
          DeleteARec(CurRec) ;
        { Recalculate Offsets  }
          ScrRec := S_FirstRec[ScrNum] ;
          TotalOffset := 0 ;
          While ScrRec <> nil do
            begin
              ScrRec^.Offset := TotalOffset ;
              TotalOffset := TotalOffset + ScrRec^.Size ;
              ScrRec := ScrRec^.Next ;
            end ;
          DrawScreen(S_FirstRec[ScrNum]) ;
          Show_Mouse ;
        end ;


     begin
       ExitFlag := false ;
       D_EditFlag[ScrNum] := true ;
       Repeat
         EraseARec(CurRec) ;
         TitleStr := CurRec^.LabelStr ;
         OldDataType := CurRec^.DataType ;
         if OverLap then
            AcceptTitle('Field Overlap', TitleStr, CurRec^.Size,
                         CurRec^.X, CurRec^.Y, CurRec^.DataType, Result) 
         else
            AcceptTitle('Modify Title', TitleStr, CurRec^.Size,
                         CurRec^.X, CurRec^.Y, CurRec^.DataType, Result) ;
         NewDataType := CurRec^.DataType ;
         if Result then
            begin
              if (NewDataType = 'H') AND (NewDataType <> OldDataType) then
                 begin
                   new(NewRec) ;
                   NewRec^.LabelStr := '' ;
                   NewRec^.DataType := 'D' ;
                   NewRec^.X := 1 + XCur + CurRec^.Size + 
                                    Length(CurRec^.LabelStr) ;
                   NewRec^.Y := YCur ;
                   NewRec^.Size := 1 ;
                   NewRec^.XInPos := 0 ; 
                   NewRec^.XPos   := NewRec^.X + 3 ;
                   NewRec^.YPos   := YCur ;
                   
                   if CurRec^.Next <> nil then
                      CurRec^.Next^.Prev := NewRec ;
                   NewRec^.Next := CurRec^.Next ;
                   CurRec^.Next := NewRec ;
                   NewRec^.Prev := CurRec ;
                   
                 { Recalculate Offsets  }
                   ScrRec := S_FirstRec[ScrNum] ;
                   TotalOffset := 0 ;
                   While ScrRec <> nil do
                     begin
                       ScrRec^.Offset := TotalOffset ;
                       TotalOffset := TotalOffset + ScrRec^.Size ;
                       ScrRec := ScrRec^.Next ;
                     end ;
                 end
              else
                 if (OldDataType = 'H') AND (NewDataType <> 'H') then
                    DeleteARec(CurRec^.Next) ;
              CurRec^.LabelStr := TitleStr ;
              XCur := CurRec^.X ;
              YCur := CurRec^.Y ;
              CurRec^.XInPos := 0 ;
              CurRec^.XPos   := XCur + Length(TitleStr) + 3 ; 
              CurRec^.YPos   := YCur ;
              CalcOffset( S_FirstRec[ScrNum], CurRec, Offset ) ;
              CurRec^.Offset := Offset ;
              CheckOverLap( CurRec, CurRec^.X, CurRec^.Y, OverLap ) ;
            end 
         else
            begin
              ExitFlag := true ;
              OverLap := true ;
              DeleteScrRec ;
            end ;

         if NOT OverLap then
            begin
              Set_Clip(0,0,640,200 * Resolution) ;
              if CurRec^.DataType = 'H' then
                 begin
                   CurRec^.Next^.Y := CurRec^.Y ; 
                   CurRec^.Next^.X :=                                  { 2 }
                           CurRec^.X + CurRec^.Size + Length(TitleStr) + 1 ; 
                   CurRec^.Next^.YPos := CurRec^.YPos ; 
                   CurRec^.Next^.XPos :=                               { 5 }
                           CurRec^.X + CurRec^.Size + Length(TitleStr) + 4 ; 
                 end ;
              DrawScreen(S_FirstRec[ScrNum]) ;
              ShortDraw := true ;
            end
         else
            if Result then
            begin
              if CurRec^.Y < 14 then
                 repeat
                   CurRec^.Y := CurRec^.Y + 1 ; 
                   CheckOverlap( CurRec, CurRec^.X, CurRec^.Y, OverLap ) ;
                 Until NOT OverLap OR (CurRec^.Y > 14) ;
                 
              AlertStr := '[2][  |  Altering Position of Field  | ' ;
              AlertStr := Concat(AlertStr, '|     Modify if Desired|  ]') ;
              AlertStr := Concat(AlertStr, '[ Continue]') ;
              i        := Do_Alert(AlertStr,1) ;
            end ;
       Until NOT OverLap OR ExitFlag ;
     end ;

{ *************************************************************************
     Calls ModifyScrn if the cursor is positioned on a current Screen
     Info field.  Otherwise displays an error message.
************************************************************************* }
  procedure Select_Modify ;

    var
        CurLoc   : short_integer ;
        CurRec   : ScrPtr ;
        OverLap  : boolean ;

     begin
       OverLap := false ;
       CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
       if CurLoc > -1 then
          if CurRec^.DataType <> 'D' then
             ModifyScrn(CurRec, OverLap) ;
     end ;

{ *************************************************************************
     Allows the creation of a Screen Info field on the screen.  Issues
     and error message if the cursor is overlapping an existing
     field.
************************************************************************* }
  procedure Select_Enter ;

    var
        DataType : char ;
        Size,
        A_Result : short_integer ;
        TitleStr : Str255 ;
        Result   : boolean ;
        Overlap  : boolean ;
        CurLoc   : short_integer ;
        CurRec   : ScrPtr ;

     begin
       CheckCurLoc( CurLoc, CurRec, XCur, YCur, ScrNum ) ;
       if CurLoc < 0 then
          begin
            Size := 10 ;
            AcceptTitle('Enter Title', TitleStr, 
                         Size, XCur, YCur, DataType, Result) ;

            if Result then
               begin
                 Set_Clip(0,0,640,200 * Resolution) ;
                 D_EditFlag[ScrNum] := true ;
                 AddARec(S_FirstRec[ScrNum], S_CurrentRec[ScrNum],
                         S_LastRec[ScrNum], S_LastRec[ScrNum], TitleStr, 
                         XCur, YCur, Size, DataType, ScrNum ) ;
                 CheckOverLap(S_CurrentRec[ScrNum], 
                              S_CurrentRec[ScrNum]^.X,
                              S_CurrentRec[ScrNum]^.Y, OverLap ) ;
                 if Overlap then
                    ModifyScrn(S_CurrentRec[ScrNum], OverLap) ;
                 if DataType = 'H' then
                    AddARec(S_FirstRec[ScrNum], S_CurrentRec[ScrNum],
                            S_LastRec[ScrNum], S_LastRec[ScrNum], '', 
                            XCur + Size + Length(TitleStr) + 1, YCur, 
                            1, 'D', ScrNum) ;
                 DrawScreen(S_FirstRec[ScrNum]) ;
                 ShortDraw := true ;
                 if YCur < 14 then YCur := YCur + 1 ;
               end ;
          end
       else
          begin
            AlertStr := '[1][  |Record Overlap|  ]' ;
            AlertStr := Concat(AlertStr, '[ Continue ]') ;
            A_Result   := Do_Alert(AlertStr,1) ;
          end ;
     end ;

{ *************************************************************************
       Process the changes necessary when changing between modes.
************************************************************************* }
     procedure ChangeMode( Var Mode, NewMode : short_integer ) ;
     
        begin
          if NewMode = 5 then
             begin
               Mode := 5 ;
               Spacing := 10 * Resolution ;
               DrawScreen(S_CurrentRec[ScrNum]) ;
             end ;

          if (NewMode = 1) AND (Mode <> 5) then
             SaveDecision(Result)
          else
             Result := 2 ;
          if Result <> 3 then
             begin
               if (NewMode = 1) AND (Mode <> 5) then
                  begin
                    ClearRecord(D_CurrentRec[DataNum]) ;
                    D_DisposeRecs(D_FirstRec[DataNum], D_CurrentRec[DataNum],
                                  D_LastRec[DataNum]) ;
                    RecNo[DataNum] := 0 ;
                  end
               else
                  if (NewMode = 1) AND (Mode = 5) then
                     begin
                       Mode := 1 ;
                       Spacing := 12 * Resolution ;
                       ClrHome ;
                       DrawScreen(S_FirstRec[ScrNum]) ;
                     end ;

               if (NewMode = 2) AND (Mode = 3) then
                  begin
                    if SearchFlag then
                       begin
                         SearchFlag := false ;
                         DS_DeleteARec(D_CurrentRec[DataNum]) ;
                         D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
                         RecNo[DataNum] := 1 ;
                       end ;
                    FormatCheck(D_CurrentRec[DataNum]) ;
                    DisposeInt(C_FirstRec, C_CurRec, C_LastRec) ;
                    DisposeInt(F_FirstRec, F_CurRec, F_LastRec) ;
                    F_SaveRec := nil ;
                    ClrHome ;
                    DrawRecord(D_CurrentRec[DataNum]) ;
                  end ;

               if (NewMode = 2) AND (Mode = 4) then
                  begin
                    if SortFlag then
                       begin
                         SortFlag := false ;
                         DS_DeleteARec(D_CurrentRec[DataNum]) ;
                         D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
                         RecNo[DataNum] := 1 ;
                       end ;
                    DisposeInt(F_FirstRec, F_CurRec, F_LastRec) ;
                    ClrHome ;
                    DrawRecord(D_CurrentRec[DataNum]) ;
                  end ;

               if ((NewMode = 2) OR (NewMode = 3)) AND (Mode = 5) then
                  begin
                    Mode := 2 ;
                    Spacing := 12 * Resolution ;
                    ClrHome ;
                    DrawScreen(S_FirstRec[ScrNum]) ;
                    DrawRecord(D_CurrentRec[DataNum]) ;
                  end ;


               Mode := NewMode ;
               UpdateFlag := true ; ;
               Set_VSlideSize ;
             end ;
        end ;
{ *************************************************************************
     Process the Input request.
************************************************************************* }
     procedure SelectInput( Var NewMode : short_integer ) ;

        begin
          if S_CurrentRec[ScrNum] <> nil then
             begin
               NewMode := 2 ;
               if Mode = 1 then
                  begin
                    CreateDataRec(DataNum) ;
                    RecNo[DataNum] := 1 ;
                    S_CurrentRec[ScrNum] := S_FirstRec[ScrNum] ;
                    S_CurrentRec[ScrNum]^.XInPos := 0 ;
                    XCur := S_CurrentRec[ScrNum]^.XPos ;
                    YCur := S_CurrentRec[ScrNum]^.YPos ;
                  end ;
             end 
          else
             begin
               AlertStr := '[2][| No Data Base Design | ' ;
               AlertStr := Concat(AlertStr, '|   has been entered  |  ]') ;
               AlertStr := Concat(AlertStr, '[ Continue ]') ;
               Result   := Do_Alert(AlertStr,1) ;
             end ;
        end ;


{ *************************************************************************
       Determines which Open module to call depending upon the 
       current mode.
************************************************************************* }
     procedure Select_Open(Var NewMode : short_integer) ;

       var
          CurRec  : DataPtr ;
          DataRec : DataStorePtr ;
          Flag    : boolean ;

        begin
          Case Mode of
              1 : begin
                    Result := 1 ;
                    if D_EditFlag[ScrNum] then
                       D_SaveDecision(Result) ;
                    if Result <> 3 then
                       begin
                         OpenScrnInfo(Flag) ;
                         if Flag then
                            begin
                              CurRec := D_FirstRec[Report] ;
                              While CurRec <> nil do
                                begin
                                  DataRec := D_FirstRec[Report]^.Data ;
                                  While DataRec <> nil do
                                    begin
                                      FillString(DataRec^.DataStr, chr($20)) ;
                                      DataRec := DataRec^.Next ;
                                    end ;
                                  CurRec := CurRec^.Next ;
                                end ;
                              ClrHome ;
                            end ;
                       end ;
                  end ;
              2 : begin
                    SaveDecision(Result) ;
                    if Result <> 3 then
                       begin
                         if (D_FirstRec[DataNum] <> nil) AND 
                            (D_FirstRec[DataNum] = D_LastRec[DataNum]) AND
                             NOT EditFlag[ScrNum] then
                             Result := 2
                         else
                            MergeDecision(Result) ;
                         if Result = 1 then
                            begin
                              MergeDataBase ;
                              EditFlag[ScrNum] := true ;
                            end 
                         else
                            if Result = 2 then
                               begin
                                 GetDataBase ;
                                 EditFlag[ScrNum] := false ;
                               end ;
                         ClrHome ;
                       end ;
                  end ;
              5 : begin
                    Result := 1 ;
                    if R_EditFlag then
                       R_SaveDecision(Result) ;
                    if Result <> 3 then
                       begin
                         GetPrtInfo ;
                         DrawDesign ;
                         ShortDraw := true ;
                       end ;
                  end ;
          end ;
          if (Mode = 1) AND (Result <> 3) AND (Flag) then
             SelectInput(NewMode) ;
        end ;

{ *************************************************************************
       Determine the proper save module to call depending upon the
       current mode.
************************************************************************* }
     procedure Select_Save ;

        begin
          Case Mode of
              1 : SaveScrnInfo ;
            2,3 : begin
                    FormatCheck(D_CurrentRec[DataNum]) ;
                    SaveDataBase(DataNum) ;
                  end ;
              5 : SavePrtInfo ;
          end ;
        end ;

{ *************************************************************************
     Process the Close request.  Different results depending upon MODE.
************************************************************************* }
     procedure Select_Close ;

       var
          CurRec  : DataPtr ;
          DataRec : DataStorePtr ;

        begin
          Case Mode of
              1 : begin
                    Result := 1 ;
                    if D_EditFlag[ScrNum] then
                       D_SaveDecision(Result) ;
                    if Result <> 3 then
                       begin
                         DisposeRecs(S_FirstRec[ScrNum], S_CurrentRec[ScrNum],
                                     S_LastRec[ScrNum]) ;
                         DrawScreen(S_FirstRec[ScrNum]) ;
                         XCur := 1 ;
                         YCur := 1 ;
                       end ;
                  end ;
              2 : begin
                    SaveDecision(Result) ;
                    if Result <> 3 then
                       begin
                         EditFlag[ScrNum] := false ;
                         D_DisposeRecs(D_FirstRec[DataNum], 
                              D_CurrentRec[DataNum], D_LastRec[DataNum]) ;
                         RecNo[DataNum] := 0 ;
                         TotalRec[DataNum] := 0 ;
                         CreateDataRec(DataNum) ;
                         ClrHome ;
                         DrawScreen(S_FirstRec[ScrNum]) ;
                       end ;
                  end ;
              5 : begin
                    Result := 1 ;
                    if R_EditFlag then
                       R_SaveDecision(Result) ;
                    if Result <> 3 then
                       begin
                         CurRec := D_FirstRec[Report] ;
                         While CurRec <> nil do
                           begin
                             DataRec := D_FirstRec[Report]^.Data ;
                             While DataRec <> nil do
                               begin
                                 FillString(DataRec^.DataStr, chr($20)) ;
                                 DataRec := DataRec^.Next ;
                               end ;
                             CurRec := CurRec^.Next ;
                           end ;
                         R_LoadFlag := false ;
                         DrawDZ_Out ;
                       end ;
                  end ;
          end ;
          ModifyWName ;
          UpdateFlag := true ; ;
        end ;

{ *************************************************************************
     Process the Search Request.
************************************************************************* }
     procedure SelectSearch( Var NewMode : short_integer ) ;

       var
          ScrRec : ScrPtr ;
          Result : short_integer ;

        procedure SearchSetUp ;

           begin 
             FormatCheck(D_CurrentRec[DataNum]) ;
             SearchFlag := true ;
             if F_FirstRec = nil then
                begin
                  F_TotalRec[DataNum] := 0 ;
                  F_RecNo[DataNum] := 0 ;
                    
                  ScrRec := S_FirstRec[ScrNum] ;
                  While ScrRec <> nil do
                     begin
                       Int_AddARec(C_FirstRec,C_CurRec,C_LastRec, 1) ;
                       ScrRec := ScrRec^.Next ;
                     end ;
                  C_CurRec := C_FirstRec ;
                  
                  NewMode := 3 ;
               end ;
             ClearRecord(D_CurrentRec[DataNum]) ;
             CreateDataRec(DataNum) ;
             ClrHome ;
           end ;

     procedure DeleteDupRecs ; 

       var
          CurRec_1,
          CurRec_2,
          NilRec_1,
          NilRec_2,
          NewListFirst,
          NewListCur,
          NewListLast   : IntPtr ;
          
       begin
          CurRec_1   := F_FirstRec ;
          CurRec_2   := F_SaveRec^.Next ;
          NewListFirst := nil ;
          NewListCur   := nil ;
          NewListLast  := nil ;
          
          new(NilRec_1) ;
          NilRec_1^.Match := MaxInt ;
          new(NilRec_2) ;
          NilRec_2^.Match := MaxInt ;
          
          While (CurRec_1 <> NilRec_1) OR (CurRec_2 <> NilRec_2) do
            begin
              if CurRec_1^.Match < CurRec_2^.Match then
                 begin
                   Int_AddARec(NewListFirst, NewListCur, NewListLast, 
                               CurRec_1^.Match) ;
                   CurRec_1 := CurRec_1^.Next ;
                 end
              else
                 if CurRec_1^.Match > CurRec_2^.Match then
                    begin
                      Int_AddARec(NewListFirst, NewListCur, NewListLast, 
                                  CurRec_2^.Match) ;
                      CurRec_2 := CurRec_2^.Next ;
                    end
                 else
                    begin
                      Int_AddARec(NewListFirst, NewListCur, NewListLast, 
                                  CurRec_1^.Match) ;
                      CurRec_1 := CurRec_1^.Next ;
                      CurRec_2 := CurRec_2^.Next ;
                    end ;
              if CurRec_1 = F_SaveRec^.Next then
                 CurRec_1 := NilRec_1 ;
              if CurRec_2 = nil then
                 CurRec_2 := NilRec_2 ;
            end ;
            
          DisposeInt(F_FirstRec, F_CurRec, F_LastRec) ;
          
          F_FirstRec := NewListFirst ;
          F_CurRec   := NewListFirst ;
          F_LastRec  := NewListLast ;
          F_SaveRec  := NewListLast ;

          F_TotalRec[DataNum] := 0 ;
          While F_CurRec <> nil do
             begin
               F_TotalRec[DataNum] := F_TotalRec[DataNum] + 1 ;
               F_CurRec := F_CurRec^.Next ;
             end ;
          F_CurRec := F_FirstRec ;
          
          CurRec_1 := nil ;
          CurRec_2 := nil ;
          NilRec_1 := nil ;
          NilRec_2 := nil ;
          
          NewListFirst := nil ;
          NewListCur   := nil ;
          NewListLast  := nil ;

          F_CurRec := F_LastRec ;
          GoToFirst(D_CurrentRec[DataNum], false ) ;
       end ;

        begin
          F_SaveRec := F_LastRec ;
          if Mode <> 5 then
             begin
               if NOT SearchFlag then
                  begin
                    if Mode <> 3 then
                       SearchSetUp
                    else
                       begin
                         AlertStr := '[2][  |        Search         | ' ;
                         AlertStr := Concat(AlertStr, 
                                          ' |      Disposition      |  ]') ;
                         AlertStr := Concat(AlertStr, 
                                     '[  OR  |  NEW  | Cancel ]') ;
                         Result   := Do_Alert(AlertStr,2) ;
                         if Result = 1 then
                            SearchSetUp            { OR SEARCH }
                         else
                            if Result = 2 then
                               begin
                                 NewMode := 2 ;
                                 ChangeMode(Mode, NewMode) ;
                                 SearchSetUp ;    { NEW SEARCH }
                                 Mode := 3 ;
                               end ;
                       end ;
                  end
               else
                  begin
                    SearchDataBase(NewMode) ;
                    SearchFlag := false ;
                    if F_SaveRec <> nil then
                       DeleteDupRecs ; 
                    ClrHome ;
                    DrawRecord(D_CurrentRec[DataNum]) ;
                    UpdateFlag := true ; ;
                    Set_VSlideSize ;
                  end ;
             end 
          else
             begin
               NewMode := 3 ;
               ClrHome ;
             end ;
        end ;

{ *************************************************************************
     Process the Sort Request.
************************************************************************* }
     procedure SelectSort( Var NewMode : short_integer ) ;

        begin
          if NOT SortFlag then
             begin
               FormatCheck(D_CurrentRec[DataNum]) ;
               SortFlag := true ;
               SortCount := 1 ;
               NewMode := 4 ;
               ClearRecord(D_CurrentRec[DataNum]) ;
               CreateDataRec(DataNum) ;
               ClrHome ;
             end
          else
             if F_FirstRec <> nil then
                begin
                  SortFlag := false ;
                  UpdateInfoLine ;
                  SortRecords(D_FirstRec[DataNum], NewMode) ;
                  DisposeInt(F_FirstRec, F_CurRec, F_LastRec) ;
                  DisposeInt(C_FirstRec, C_CurRec, C_LastRec) ;
                end ;
        end ;

{ *************************************************************************
     Process the Report Design Request.
************************************************************************* }
  procedure SelectOutput(Var NewMode : short_integer) ;
  
    var
       i      : short_integer ;
       ScrRec : ScrPtr ;
       AbortFlag : boolean ;

     begin
       NewMode := 5 ;
       if D_FirstRec[Report] = nil then
          begin
            for i := 1 to 10 do
                AddARec(S_FirstRec[Report], S_CurrentRec[Report],
                        S_LastRec[Report], S_LastRec[Report], 
                        '', 1, i + 7, 132, 'A', Report) ;
            CreateDataRec(Report) ;
          end ;
       S_CurrentRec[Report] := S_FirstRec[Report] ;

       ScrRec := S_FirstRec[ScrNum] ;
       TotScrRec := 0 ;
       While ScrRec <> nil do
          begin
            TotScrRec := TotScrRec + 1 ;
            ScrRec := ScrRec^.Next ;
          end ;

       XCur := 1 ;
       YCur := 8 ;
       RW_Offset := 0 ;
       ReportSetUp(AbortFlag) ;
       if AbortFlag AND (Mode <> 5) then
          begin
            if F_FirstRec <> nil then
               NewMode := 3
            else
               NewMode := 2 ;
            ClrHome ;
            DrawScreen(S_CurrentRec[ScrNum]) ;
            DrawRecord(D_CurrentRec[DataNum]) ;
          end ;
     end ;

{ *************************************************************************
************************************************************************* }
   procedure SelectDelete ;
      
      begin
        if Mode = 1 then
           DeleteScrRec
        else
           DeleteRecord ;
      end ;
{ *************************************************************************
************************************************************************* }
  procedure SelectPrint( PrintMode : short_integer ) ;

  procedure PrintRep(Var PrintXs : short_integer ;
                     Var AbortFlag : boolean ) ;

    Var
       Print       : Dialog_Ptr;
       PrintScreen : Tree_Index;
       PrintItem   : array[1..23] of short_integer;
       GetEditStr  : Str255 ;

     begin
       Print := New_Dialog(3, 0, 0, 30, 10);
       Center_Dialog(Print);

       PrintItem[1] := Add_DItem(Print, G_BoxText, 0, 
                               5, 1, 22, 1, -1, 4096 | 256 | 128);
       Set_DText(Print, PrintItem[1], ' Report Repetitions ' ,
                 System_Font, TE_Center);

       PrintItem[2] := Add_DItem(Print, G_FText, Editable,
                                 7, 4, 16, 1, 0, 256 | 128);
       Set_DEdit(Print, PrintItem[2], 'Repetetions  ___', 
                                  '999', 
                                  '  1', System_Font, TE_Center);

       PrintItem[3] := Add_DItem(Print, G_BoxText,
                                 Default | Exit_Btn | Selectable,
                                 3, 7, 10, 1, -3, 4096 | 256 | 128);
       Set_DText(Print, PrintItem[3], 
                                 'Continue', System_Font, TE_Center);

       PrintItem[4] := Add_DItem(Print, G_BoxText, 
                                 Exit_Btn | Selectable,
                                 17, 7, 10, 1, -2, 4096 | 256 | 128);
       Set_DText(Print, PrintItem[4], 
                                 'Abort', System_Font, TE_Center);

       PrintScreen := Do_Dialog(Print, 2);

       if PrintScreen = 4 then
          AbortFlag := true
       else
          begin
            Get_DEdit(Print, PrintItem[2],  GetEditStr);
            if GetEditStr <> '' then
               ReadV(GetEditStr, PrintXs)
            else
               PrintXs := 1 ;
          end ;

       End_Dialog(Print);
       Delete_Dialog(Print);
     end ;

   
     var
        i,
        PrintXs    : short_integer ;
        OutputFile : Path_Name ;
        AbortFlag,
        PrintFlag  : boolean ;
        SaveMode   : short_integer ;

      Label 
        1 ;

      begin
        AbortFlag := false ;
        PrintRep(PrintXs, AbortFlag) ;
        if AbortFlag then GoTo 1 ;
        SaveMode := Mode ;
        Mode := 5 ;
        PrintFlag := true ;
        if PrintMode = 45 then
           Rewrite(Printer, 'LST:')
        else
           if PrintMode = 47 then
              begin
                Hide_Mouse ;
                Close_Window(WindNum) ;
                Set_Clip(0,0,640,200 * Resolution) ;
                Paint_Rect(0, 0, 640, 200 * Resolution) ;
                Rewrite(Printer, 'CON:') ;
                GoToXY(24,1) ;
                Writeln ;
                Writeln ;
                GoToXY(1,1) ;
              end 
        else
           if Get_In_File(DefPathTxt, DefFileTxt) then
              Rewrite(Printer, DefFileTxt)
           else
              PrintFlag := false ;

        if PrintMode <> 47 then
           for i := 1 to 4 do
               if PrtFlag[i] then
                  InitPrinter(PrtInit[i]) ;

        if PrintFlag then
           begin
             for i := 1 to PrintXs do
                 begin
                   if P_Mode = 1 then
                      M_PrintRec                       { MULTIPLE LABELS }
                   else
                      if P_Mode = 2 then               { REPORT }
                         PrintReport 
                      else
                         PrintRec(D_CurrentRec[DataNum]) ; { SINGLE LABEL }
                 end ;
             Close(Printer) ;
           end ;
        Mode := SaveMode ;
           
        if PrintMode = 47 then
           begin
             Writeln('PRESS RETURN TO CONTINUE') ;
             Readln ;
             Open_Window(WindNum,0,0,0,0) ;
             Work_Rect(WindNum, x, y, w, h);
             Set_Clip(x, y, w, h);
             Draw_Menu(InfoMenu) ;
             Show_Mouse ;
           end ;
1 :    end ;

{ *************************************************************************
     Menu_Select interprets menu items selection from Event_Loop and
     calls the appropriate module.
************************************************************************* }
  procedure Menu_Select( msg : Message_Buffer) ;

    var
        NewMode   : short_integer ;

     begin
       if Mode = 5 then
          EraseCursor(Report)
       else
          EraseCursor(ScrNum) ;
       NewMode := Mode ;

       Menu_Normal(InfoMenu, msg[3]);
       Case msg[4] of
          11 : CopyRight ;
          24 : Select_Open(NewMode) ;
          25 : Select_Save ;
          26 : Select_Close ;
          27 : ExitProgram ;
          28 : NewMode := 1 ;
          29 : SelectInput(NewMode) ;
          30 : SelectSearch(NewMode) ;
          31 : SelectSort(NewMode) ;
          32 : SelectOutput(NewMode) ;
          33 : Select_Enter ;
          34 : Select_Modify ;
          35 : SelectSearch(NewMode) ;
          36 : SelectSort(NewMode) ;
          37 : IncrementRecord(D_CurrentRec[DataNum], 1, true) ;
          38 : IncrementRecord(D_CurrentRec[DataNum], -1, true) ;
          39 : GoToFirst(D_CurrentRec[DataNum], true) ;
          40 : GoToLast(D_CurrentRec[DataNum], true) ;
          42 : SelectDelete ;
          44 : Press_Tab ;
          45,
          46,
          47 : SelectPrint(msg[4]) ;
       end ;           

       if (Mode <> NewMode) AND(msg[4] <> 42) then
          ChangeMode(Mode, NewMode) ;

       if WindNum > 0 then
          begin
            if Mode = 5 then
               NewCursor(Report)
            else
               NewCursor(ScrNum) ;
          end ;
    end;    


BEGIN
END .

{
   MAIN MENU 

DESK        File      Mode      Design    Record     Output
----        ----      ----      ------    ------     ------
 InfoBase    Open      Design    Enter     Search     Print
             Save      Input     Modify    Sort       Disk
             Clear     Search              Next       Screen
             Quit      Sort                Previous  
                       Output              FirstRec  
                                           Last Rec  
                                          ----------
                                           DeleteRec
                                          ----------
                                           New Rec
==============================================================
  Numerical values for Menu_Select :
Top Item      <24>      <28>      <33>      <35>       <45>
Bottom Item   <27>      <32>      <34>      <44>       <47>
==============================================================
DESIGN MENU ITEM
------ ---- ----

    File
    ----
     Open   -- Depending on the value of Mode, Open will open a 
               Design file or open a database file.
     Save   -- Depending on the value of Mode, Save will save a
               Design file or save a database file.
     Close  -- Close the current window and release memory to system.
     Quit   -- Close all windows and exit program.

    Mode
    ----
     Design -- Change the value of Mode to allow modification of
               the screen for database design.
     Input  -- Change the value of Mode to allow input of record
               information.
     Search -- Change Value of Mode to allow search pattern to be
               entered.
     Sort   -- Call Sort Routine.
     Output -- Enter Output Design Mode.

    Design
    ------
     Enter  -- Open dialog box to enter pertainent information for 
               inclusion at current cursor position.
     Modify -- Change label information at the current position by 
               re-opening dialog box.

    Record
    ------
     Search -- Process Search request.
     Sort   -- Process Sort Instructions.
     Next   -- Makes next record the current data record.
     Previous- Makes previous record the current data record.
     FirstRec- Move to First Record.
     Last Rec- Move to Last Record.
     Delete -- Delete Current Record (Same as ^D) .
     New Rec-- Create a new Record at end of list (Same as TAB) .

    Output
    ------
     Print -- Print report to printer.
     Disk  -- Print report to disk.
     Screen-- Print report to screen.
}
