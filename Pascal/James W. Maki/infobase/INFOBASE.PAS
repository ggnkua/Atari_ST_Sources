{$E+}
Program InfoBaseST ;
{
*************************************************************************
*                                                                       *
*                            InfoBaseST                                 *
*                            ----------                                 *
*                        Atari ST Data Base                             *
*                                                                       *
*           (c) Copyright 1990 by Antic Publishing, Inc.                *
*                                                                       *
*                     Written by:                                       *
*                           James W. Maki                               *
*                           3701 S. Orchard Street, #I7                 *
*                           Tacoma, WA   98466-7912                     *
*                           (206) 5656-4167                             *
*                                                                       *
*                                                                       *
*   Started       : August 8, 1988                                      *
*   Last Revision : January 29, 1990                                    *
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

  LABEL 1 ;

{   ********************* External *************************************   }     

  procedure CopyRight ;
     External ;

  procedure Keyboard_Input( Key_Input : short_integer ) ;
     External ;

  procedure MB_Input( X, Y : short_integer ) ;
     External ;

  procedure SetUpMenu ;
     External ;

  procedure MenuOption ;
     External ;

  procedure Menu_Select( msg : Message_Buffer) ;
     External ;

  procedure DrawRecord(CurRec : DataPtr) ;
     External ;

  procedure Do_Redraw( Msg : Message_Buffer ) ; 
     External ;

  procedure NewCursor(ScrMode : short_integer) ;
     External ;

  procedure ModifyWName ;
     External ;

  procedure UpdateInfoLine ;
     External ;

  procedure Select_Close ;
     External ;

  procedure IncrementRec(Var  CurRec : DataPtr ; Value : short_integer ;
                              DrawFlag : boolean ) ;
     External ;

  procedure ClrHome ;
     External ;

  procedure Set_VSlideSize ;
     External ;

  procedure DrawDZ_In ;
     External ;
{   ********************************************************************   }     
 procedure Wind_VSlide( WindNo, SlidePos : short_integer ) ;

   var
       L_I,
       L_Rec,
       L_Offset,
       L_SlidePos : long_integer ;
       i,
       Value,
       MoveRec,
       Dummy,
       StartRec   : short_integer ;

    begin
      L_I := 1 ;
      L_SlidePos := L_I * SlidePos;

      case Mode of
          2 : begin
                L_Rec := L_I * (TotalRec[ScrNum] - 1) ;
                L_Offset := (L_Rec * L_SlidePos) DIV 1000 ;
                MoveRec := (RecNo[DataNum] - 1) - Int(L_Offset) ;
                if MoveRec < 0 then
                   for i := 1 to ABS(MoveRec) do
                       begin
                         D_CurrentRec[DataNum] := 
                           D_CurrentRec[DataNum]^.Next ;
                         RecNo[DataNum] := RecNo[DataNum] + 1 ;
                      end 
                else
                   if MoveRec > 0 then
                      for i := 1 to MoveRec do
                          begin
                            D_CurrentRec[DataNum] := 
                              D_CurrentRec[DataNum]^.Prev ;
                            RecNo[DataNum] := RecNo[DataNum] - 1 ;
                          end ;
                ClrHome ;
                DrawRecord(D_CurrentRec[DataNum]) ;
              end ;
          3 : begin
                L_Rec := L_I * F_TotalRec[ScrNum] ;
                L_Offset := (L_Rec * L_SlidePos) DIV 1000 ;
                StartRec := Int(L_Offset) ;
                D_CurrentRec[DataNum] := D_FirstRec[DataNum] ;
                RecNo[DataNum] := 1 ;
                F_RecNo[DataNum] := 1 ;
                F_CurRec := F_FirstRec ;
                if StartRec >= F_TotalRec[DataNum] then
                   StartRec := F_TotalRec[DataNum] - 1 ;
                 
                if StartRec > 0 then
                   for i := 1 to StartRec do
                       begin
                         F_CurRec := F_CurRec^.Next ;
                         F_RecNo[DataNum] := F_RecNo[DataNum] + 1 ;
                       end ;
                MoveRec := F_CurRec^.Match ;
                
                if MoveRec > 1 then
                   for i := 2 to MoveRec do
                       begin
                         D_CurrentRec[DataNum] := D_CurrentRec[DataNum]^.Next ;
                         RecNo[DataNum] := RecNo[DataNum] + 1 ;
                       end ;
                ClrHome ;
                DrawRecord(D_CurrentRec[DataNum]) ;
              end ;
          5 : if TotScrRec > 10 then
                 begin
                   L_Rec := L_I * (TotScrRec - 10) ;
                   PL_Offset := Int((L_Rec * L_SlidePos) DIV 1000) ;
                   DrawDZ_In ;
                 end ;
      end ;

      UpdateInfoLine ;
      if Mode = 5 then
         NewCursor(Report)
      else
         NewCursor(ScrNum) ;
    end ;

 procedure Wind_VArrow(Var CurRec : DataPtr ; msg : short_integer) ;

   var
      Count,
      SaveOffset : short_integer ;
      L_I,
      L_SlidePos : long_integer ;

    begin
      case Mode of
         1,2, 
          3  : case msg of
                 0,2 : IncrementRec(CurRec, -1, true) ;
                 1,3 : IncrementRec(CurRec, 1, true) ;
               end;
          5  : begin
                 SaveOffset := PL_Offset ;
                  case msg of
                     0 : Count := -10 ;
                     1 : Count :=  10 ;
                     2 : Count :=  -1 ;
                     3 : Count :=   1 ;
                  end ;
                  
                 PL_Offset := PL_Offset + Count ;
                 if PL_Offset < 0 then 
                    PL_Offset := 0
                 else
                    if PL_Offset + 10 > TotScrRec then
                       PL_Offset := TotScrRec - 9 ;
                 if SaveOffset <> PL_Offset then      
                    begin
                      DrawDZ_In ;
                      L_I := 1 ;
                      if TotScrRec > 10 then
                         L_SlidePos := (L_I * 1000 * PL_Offset) 
                                        DIV (TotScrRec - 10)
                      else
                         L_SlidePos := 1 ;
                      Wind_Set(WindNum, WF_VSlide, L_SlidePos, 0, 0, 0) ;
                    end ;
               end ;
      end ;
      if Mode = 5 then
         NewCursor(Report)
      else
         NewCursor(ScrNum) ;
    end;

  procedure Event_Loop ;
{
     Event_Loop is the "Traffic Manager" of InfoBaseST.  All input is 
     processed through this routine.  GEM system messages are also
     evaluated and acted upon.
}
    var
       GemEvent  : short_integer ;
       msg       : Message_Buffer ;
       Key_Input,
       B_State,
       B_Count,
       X_Mouse, 
       Y_Mouse,
       Key_State : short_integer ;

     begin
       Work_Rect(WindNum, x, y, w, h);
       Set_Clip(x, y, w, h);

       GemEvent := Get_Event(
          E_Keyboard | E_Button | E_Timer | E_Message,
          1, 1, 1, 1,
          true, 0, 0, 0, 0,
          true, 0, 0, 0, 0,
          msg,
          Key_Input,
          B_State, B_Count,
          X_Mouse, Y_Mouse,
          Key_State);

       if (GemEvent & E_Message) <> 0 then
         begin
          Case msg[0] of
             MN_Selected : Menu_Select(msg) ;
             WM_Closed   : Select_Close ;
             WM_Redraw   : if ShortDraw then
                              ShortDraw := false
                           else
                              Do_Redraw( msg ) ;
             WM_VSlid    : if D_CurrentRec[DataNum] <> nil then
                              Wind_VSlide(msg[3],msg[4]) ;
             WM_Arrowed  : if D_CurrentRec[DataNum] <> nil then
                              case msg[4] of
                                 0,1,
                                 2,3 : Wind_VArrow(D_CurrentRec[DataNum], msg[4]) ;
                              end ;
          end ;
          MenuOption ;
          
         end
       else
          if (GemEvent & E_Keyboard) <> 0 then
             Keyboard_Input(Key_Input)
          else
             if ((GemEvent & E_Button) <> 0) AND
                 (X_Mouse < w) then
                MB_Input(X_Mouse, Y_Mouse)
             else
                if UpdateFlag then
                   UpdateInfoLine ;
     end; 

  procedure DrawNewWindow ;
{
     DrawNewWindow makes the necessary calls to display a GEM window on the
     Screen.
}
     begin
       WindName[1] := '' ;
       WindNum := New_Window(
            G_Name | G_Close | G_Info | G_UpArrow | G_DnArrow | G_VSlide, 
            WindName[1],0,0,0,0) ;
       WindInfo[WindNum] := chr($20) ;
       Set_WInfo(WindNum, WindInfo[WindNum]) ;
       Open_Window(WindNum,0,0,0,0) ;
       ModifyWName ;
     end ;

  procedure GetMemBlocks ;
{
     Determine amount of free memory available and the memory requirements
     of the pointer variables used during the program.
}
     begin
       MaxMem := MemAvail * 2 ;
       DataRecSize := SizeOf(DataStore) ;
       PtrRecSize := SizeOf(DataInfo) ;
       ScrRecSize := SizeOf(ScrInfo) ;
     end ;

     
  procedure GetCurPath(Var C_PathStr : C_String ; 
                           DriveNo : short_integer) ;
     GEMDOS($47);
      
  function GetCurDrive : short_integer;  
     GEMDOS($19);

  function Get_Resolution : short_integer ;
     XBIOS( 4 ) ;

  procedure GetDrivePath ;
{
Get the default Path name and create default file names for four types of
files associated with InfoBaseST.
     .SCR  :  Screen Design file.
     .DAT  :  Data Base file.
     .PRT  :  Report Design file.
     .TXT  :  Report Output to Disk file.
     .HLP  :  Help File.
}   
    var
       DriveNo   : short_integer ;
       C_PathStr : C_String ;
       P_PathStr : Str255 ;
   
     begin
       DriveNo := GetCurDrive ;
       GetCurPath(C_PathStr, 0) ;
       C_To_PStr(C_PathStr, P_PathStr) ;
       DefPathScr := Concat(chr(DriveNo + 65),':',P_PathStr, '\*.SCR') ;
       DefPathDat := Concat(chr(DriveNo + 65),':',P_PathStr, '\*.DAT') ;
       DefPathTxt := Concat(chr(DriveNo + 65),':',P_PathStr, '\*.TXT') ;
       DefPathPrt := Concat(chr(DriveNo + 65),':',P_PathStr, '\*.PRT') ;
       HelpFileName:=Concat(CHR(DriveNo + 65),':',P_PathStr, '\INFOBASE.HLP') ;
     end ;

  procedure InitValues ;
{
Initialize variables.
}
     var
        i : short_integer ;

      begin
        DefFileScr := '' ;
        DefFileDat := '' ;
        DefFileTxt := '' ;
        R_EditFlag := false ;
        R_LoadFlag := false ;
        ExitPrompt := false ;
        ShortDraw  := false ;
        SearchFlag := false ;
        FullMemory := false ;
        SortFlag   := false ;
        OR_Search  := false ;
        UpdateFlag := true ;

        XCur := 1 ;
        YCur := 1 ;
        Mode := 1 ;
        P_Mode := 1 ;
        RW_Offset := 0 ;
        PL_Offset := 0 ;
        LabLine := 5 ;
        RepLine := 2 ;
        RepWidth := 80 ;
        LabSpace[1] := 0 ;
        LabSpace[2] := 1 ;
        DecReal := 5 ;
        for i := 1 to 5 do
            begin
              PrtInit[i] := '' ;
              PrtFlag[i] := false ;
            end ;
        Spacing := 12 * Resolution ;
        TotScrRec := 0 ;
        for i := 1 to MaxWind do
            begin
              RecNo[i] := 0 ;
              TotalRec[i] := 0 ;
              D_EditFlag[i] := false ;
            end ;
     end ;

  PROCEDURE CheckHelpFile(VAR Result : SHORT_INTEGER) ;

    TYPE
       HelpLine = STRING[57] ;
  
    VAR
       CheckFv : FILE OF HelpLine ;
       SaveIO_Result : SHORT_INTEGER ;
       AlertStr : STR255 ;
       
    LABEL 1 ;

     BEGIN
       IO_Check(FALSE) ;
       RESET(CheckFv,HelpFileName) ;
       SaveIO_Result := IO_Result ;
1:     IF SaveIO_Result<>0 THEN
          BEGIN
            IF SaveIO_Result = -33 then
               AlertStr := '[1][ Help File Not Found. | Must reside in same | directory as program | ]'
            ELSE
               BEGIN
                 AlertStr := '[1][ Error with Help File Access |' ;
                 AlertStr := Concat(AlertStr,'           ABORT?? | ]') ;
               END ;
            AlertStr := Concat(AlertStr, '[ ABORT | Continue ]') ;
            Result := Do_Alert(AlertStr,1) ;
          END 
       ELSE
          Result:=2 ;
       CLOSE(CheckFv) ;
       IO_Check(TRUE) ;
     END ;

{
MAIN PROGRAM
}
   BEGIN
     if Init_Gem >= 0 then
        begin
          Resolution := Get_Resolution ;
           if Resolution = 0 then
             begin
                AlertStr := '[2][|This Program Will Not | ' ;
                AlertStr := Concat(AlertStr, '|  Operate in Low Res | ]') ;
                AlertStr := Concat(AlertStr, '[ Exit ]') ;
                Result   := Do_Alert(AlertStr,1) ;
             end
          else
             begin
               GetDrivePath ;
               CheckHelpFile(Result) ;
               IF Result <> 2 THEN GOTO 1 ;
               GetMemBlocks ;
               InitValues ;
               SetUpMenu;
               Init_Mouse ;
               CopyRight ;
               DrawNewWindow ;
               Event_Loop ;
               NewCursor(ScrNum) ;
               Set_VSlideSize ;

               repeat
                  Event_Loop ;
               Until ExitPrompt;
1 :          end;
        end;
     Exit_Gem;
   END.

