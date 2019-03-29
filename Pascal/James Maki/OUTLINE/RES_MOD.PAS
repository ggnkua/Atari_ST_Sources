{$M+}
{$E+}

 program Resource_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

  procedure Event_Loop;
     External ;

  procedure DoMaxLine ;
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

  procedure RecallWindow(WindNo : short_integer ; Var CommFlag : boolean) ;
     External ;

  procedure Set_MenuBar ;

    var
        i : short_integer;

     begin
       With MenuItem do
         begin
           for i := 1 to 16 do
               Menu_Disable(OP_Menu, Item[i]) ;

           for i := 13 to 16 do
               if WindHandle[i - 12] > 0 then
                  Menu_Enable(OP_Menu, Item[i]) ; 

           Menu_Enable(OP_Menu, Item[4]) ;
           if N_Window < MaxWind then 
              Menu_Enable(OP_Menu, Item[1]) ;
              
           if N_Window > 0 then
              begin
                Menu_Enable(OP_Menu, Item[2]) ;
                Menu_Enable(OP_Menu, Item[3]) ;
                Menu_Enable(OP_Menu, Item[5]) ;
                Menu_Enable(OP_Menu, Item[11]) ;
                Menu_Enable(OP_Menu, Item[12]) ;
                if (BlkMark[1] <> nil) AND (Module = BlkModule) then
                   begin
                     Menu_Enable(OP_Menu, Item[7]) ;
                     Menu_Enable(OP_Menu, Item[9]) ;
                   end ;
                if BlkBuffer <> nil then
                   Menu_Enable(OP_Menu, Item[8]) ;
                if BlkMark[1] <> nil then
                   Menu_Enable(OP_Menu, Item[10]) ;
              end ;
         end;
    end;

  procedure SetUpMenu;
  
    var
        i : short_integer;

     begin
       With MenuItem do
         begin
           OP_Menu := New_Menu(13, '  OutLine Plus  ');
  
           Title[1] := Add_MTitle(OP_Menu, '  File    ');
           Title[2] := Add_MTitle(OP_Menu, '  Block   ');
           Title[3] := Add_MTitle(OP_Menu, '  Output  ');
           Title[4] := Add_MTitle(OP_Menu, '  Menu    ');

           Item[1]  := Add_MItem(OP_Menu, Title[1], ' ^O - Open  ') ;
           Item[2]  := Add_MItem(OP_Menu, Title[1], ' ^S - Save  ') ;
           Item[3]  := Add_MItem(OP_Menu, Title[1], ' ^C - Close ') ;
           Item[4]  := Add_MItem(OP_Menu, Title[1], ' ^Q - Quit  ') ;
  
           Item[5]   := Add_MItem(OP_Menu, Title[2], ' M - Mark   ') ;
           Item[6]   := Add_MItem(OP_Menu, Title[2], '------------') ;
           Item[7]   := Add_MItem(OP_Menu, Title[2], ' C - Cut    ') ;
           Item[8]   := Add_MItem(OP_Menu, Title[2], ' P - Paste  ') ;
           Item[9]   := Add_MItem(OP_Menu, Title[2], ' D - Delete ') ;
           Item[10]  := Add_MItem(OP_Menu, Title[2], ' H - Hide   ') ;

           Item[11]  := Add_MItem(OP_Menu, Title[3], ' ^P - Print ') ;
           Item[12]  := Add_MItem(OP_Menu, Title[3], ' ^D - Disk  ') ;

           Item[13]   := Add_MItem(OP_Menu, Title[4], ' F1 -- Window 1     ') ;
           Item[14]   := Add_MItem(OP_Menu, Title[4], ' F2 -- Window 2     ') ;
           Item[15]   := Add_MItem(OP_Menu, Title[4], ' F3 -- Window 3     ') ;
           Item[16]   := Add_MItem(OP_Menu, Title[4], ' F4 -- Window 4     ') ;

         end;
       Draw_Menu(OP_Menu);
    end;


  procedure GetFile(Var OpenFlag : boolean) ;

    var
        i,
        Result,
        SlashPos,
        NumOfRecs  : short_integer ;
        CurRec     : WordPointer ;
        NewRec     : Str255 ;
        RetrieveFv : text ;
        KeyString  : String[8] ;
        AlertStr   : Str255 ;
       
     begin
       WindName[Module] := '';
       if Get_In_File(DefaultFn, WindName[Module]) then
          begin
            IO_Check(False) ;
            OpenFlag := true ;
            Reset(RetrieveFv, WindName[Module]) ;
            WindTitle[Module] := WindName[Module] ;
            FileTitle[Module] := WindName[Module] ;

            Repeat
              SlashPos := Pos('\', WindTitle[Module]) ;
              if SlashPos > 0 then
                 Delete(WindTitle[Module], 1, SlashPos) ;
            Until SlashPos = 0 ;
             Case Module of
                1 : KeyString := ' F1 -- ' ;
                2 : KeyString := ' F2 -- ' ;
                3 : KeyString := ' F3 -- ' ;
                4 : KeyString := ' F4 -- ' ;
             end ;
            WindTitle[Module] := Concat(KeyString, WindTitle[Module]) ;
            for i := Length(WindTitle[Module]) to 20 do
                WindTitle[Module] := Concat(WindTitle[Module], ' ') ;
            Menu_Text(OP_Menu, MenuItem.Item[Module + 12], 
                      WindTitle[Module]) ;

            if IO_Result <> 0 then
               begin
                 AlertStr := '[1][ | This File Does Not Exist |' ;
                 AlertStr := Concat(AlertStr, ' |      Open New File?  ]') ;
                 AlertStr := Concat(AlertStr, '[ Yes | No ]') ;
                 Result := Do_Alert(AlertStr, 1) ;
                 if Result <> 1 then
                    OpenFlag := false ;
               end ;
            IO_Check(true) ;

            Set_Mouse(M_Bee) ;
            if NOT EOF(RetrieveFv) AND (OpenFlag) then
               begin
                 { Get Number Of Records }
                 Readln(RetrieveFv, NewRec) ;
                 ReadV(NewRec, NumOfRecs) ;
               end
            else
               NumOfRecs := 0 ;

            if (NumOfRecs + TotRec < MaxRec) AND OpenFlag then
               begin
                 OpenFlag := true ;
                 While NOT EOF(RetrieveFv) do
                  begin
                    new(Current[Module]) ;
                    Readln(RetrieveFv, NewRec) ;
                    ReadV(NewRec, Current[Module]^.Level) ;
                    if NOT EOF(RetrieveFv) then
                       Readln(RetrieveFv, NewRec)
                    else
                       NewRec := '' ;
                    if FirstRec[Module]  = nil then
                       FirstRec[Module] := Current[Module] ;
                    Current[Module]^.NewWord  := NewRec ;
                    Current[Module]^.Next     := nil ;
                    Current[Module]^.Prev     := LastRec[Module] ;

                    Current[Module]^.Buffer   := false ;
                    if Current[Module]^.Prev <> nil then
                       Current[Module]^.Prev^.Next := Current[Module] ;
                    LastRec[Module]  := Current[Module] ;
                    TotalRec[Module] := TotalRec[Module] + 1 ;
                    TotRec           := TotRec + 1 ;
                  end ;
               end 
            else
               if OpenFlag then
                  begin
                    OpenFlag := false ;
                    AlertStr := '[1][ Insufficient memory |     to load file ]' ;
                    AlertStr := Concat(AlertStr, '[ Continue ]') ;
                    Result := Do_Alert(AlertStr,1) ;
                  end ;
            Set_Mouse(M_Arrow) ;
          end;
     end ;

  procedure Do_OpenWind;

    var
        i          : short_integer ;
        DefaultFn  : Path_Name ;
        OpenFlag   : boolean ;
        FormatStr,
        AlertStr   : Str255 ;
        Result     : short_integer ;

     begin
       if N_Window < MaxWind then
          begin
            if TotRec + 1 < MaxRec then
               begin
                 for i := 1 to MaxWind do
                     if WindHandle[i] = 0 then
                        begin
                          Module := i ;
                          XPos[Module] := 1 ;
                          YPos[Module] := 1 ;
                          VertOffset[Module] := 0 ;
                          WindOffset[Module] := 0 ;
                          EditFlag[Module]   := false ;
                          i := MaxWind + 1 ;
                        end ;
                 GetFile(OpenFlag) ;
                 if OpenFlag then
                    begin
                      Current[Module]     := FirstRec[Module] ;
                      ScrFirstRec[Module] := FirstRec[Module] ;
                      N_Window := N_Window + 1;
                      WriteV(FormatStr,' |',Module,'| ') ;
                      WindName[Module]   := Concat(' ', WindName[Module], 
                                                   ' ',FormatStr);
                      WindHandle[Module] := New_Window(G_All, WindName[Module],
                                                       0,0,0,0);
                      Open_Window(WindHandle[Module],0,0,0,0) ;
                    end ;
               end
            else
               DoMaxLine ;
          end
       else
          begin
            AlertStr := '[1][ | No More Windows | ]' ;
            AlertStr := Concat(AlertStr, '[ Continue ]') ;
            Result := Do_Alert(AlertStr,1) ;
          end ;
     end;

  procedure Do_SaveFile(Var ResultFlag : boolean ) ;

    var
        FileName   : Path_Name ;
        WindowName : Path_Name ;
        SaveFv     : text ;
        CurRec     : WordPointer ;
        AlertStr   : Str255 ;
        Result     : short_integer ;
        SaveStr    : Str255 ;

     begin
       FileName := FileTitle[Module] ;
       ResultFlag := true ;
       IO_Check(False) ;
       Reset(SaveFv, FileName) ;
       IO_Check(True) ;

       if IO_Result = 0 then
          begin
            AlertStr := '[1][ |    Overwrite File?   | ]' ;
            AlertStr := Concat(AlertStr, '[ Yes |  No  | Cancel ]') ;
            Result := Do_Alert(AlertStr,1) ;
            if Result = 2 then
               begin
                 WindowName := '';
                 ResultFlag := Get_In_File(DefaultFn, WindowName) ;
                 if ResultFlag then
                    FileName := WindowName ;
               end
            else
               if Result = 3 then
                  ResultFlag := false
               else
                  ResultFlag := true ;
          end ; 

       if ResultFlag then
          begin
            Set_Mouse(M_Bee) ;
            Rewrite(SaveFv, FileName) ;
           { Store File Size in first record }
            WriteV(SaveStr, TotalRec[Module]) ;
            Writeln(SaveFv, SaveStr) ;

            IO_Check(False) ;
            CurRec := FirstRec[Module] ;
            While CurRec <> nil do
              begin
                WriteV(SaveStr, CurRec^.Level) ;
                Writeln(SaveFv, SaveStr) ;
                if IO_Result = 0 then
                   Writeln(SaveFv, CurRec^.NewWord) ;
                if IO_Result = 0 then
                   CurRec := CurRec^.Next
                else
                   begin
                     Set_Mouse(M_Arrow) ;
                     if IO_Result = -39 then
                        begin
                          AlertStr := '[1][ Insufficient Disk Space |' ;
                          AlertStr := Concat(AlertStr,'       to Save File ]') ;
                          AlertStr := Concat(AlertStr, '[ Continue ]') ;
                        end 
                     else
                        begin
                          WriteV(SaveStr, IO_Result) ;
                          AlertStr := '[1][  Disk Access Error ' ;
                          AlertStr := Concat(AlertStr, SaveStr, ' |') ;
                          AlertStr := Concat(AlertStr,' During Save Operation |') ;
                          AlertStr := Concat(AlertStr,'     File NOT Saved ]') ;
                          AlertStr := Concat(AlertStr, '[ Continue ]') ;
                        end ;
                     Result := Do_Alert(AlertStr,1) ;
                     CurRec := nil ;
                   end ;
              end ;
            Close(SaveFv) ;
            Set_Mouse(M_Arrow) ;
            IO_Check(True) ;
            EditFlag[Module] := false ;
          end ;
     end ;

  procedure Do_CloseWind(Var CloseFlag : boolean ; WindMsg : short_integer ) ;

    var
        i,
        Result    : short_integer ;
        CurRec,
        NextRec   : WordPointer ;
        AlertStr  : Str255 ;

     begin
       CloseFlag := true ;
       if EditFlag[WindMsg] then
          begin
            AlertStr := '[2][ |       Save File?      | ]' ;
            AlertStr := Concat(AlertStr, '[ Yes |  No  | Cancel ]') ;
            Result := Do_Alert(AlertStr,1) ;
            if Result = 1 then
               Do_SaveFile(CloseFlag)
            else
               if Result = 3 then
                  CloseFlag := false ;
          end ;

       if CloseFlag then
          begin
            if FirstRec[WindMsg] <> nil then
               begin
                 CurRec := FirstRec[WindMsg] ;
                 While CurRec <> nil do
                    begin
                      NextRec := CurRec^.Next ;
                      Dispose(CurRec) ;
                      TotRec := TotRec - 1 ;
                      CurRec := NextRec ;
                    end ;
                 FirstRec[WindMsg] := nil ;
                 Current[WindMsg]  := nil ;
                 LastRec[WindMsg]  := nil ;
                 if WindMsg = BlkModule then
                    for i := 1 to 2 do
                        BlkMark[i] := nil ;
                 TotalRec[WindMsg] := 0 ;
               end ;
            N_Window := N_Window - 1;
            Close_Window(WindMsg);
            Delete_Window(WindMsg);

            Case Module of
                1 : WindTitle[WindMsg] := ' F1 -- Window 1     ' ;
                2 : WindTitle[WindMsg] := ' F2 -- Window 2     ' ;
                3 : WindTitle[WindMsg] := ' F3 -- Window 3     ' ;
                4 : WindTitle[WindMsg] := ' F4 -- Window 4     ' ;
            end ;

            Menu_Text(OP_Menu, MenuItem.Item[WindMsg + 12], 
                      WindTitle[WindMsg]) ;

            for i := 1 to MaxWind do
                if WindHandle[i] = WindMsg then
                   begin
                     WindHandle[i] := 0 ;
                     i := MaxWind + 1 ;
                   end ;
            Event_Loop;
            Set_MenuBar ;
          end ;
     end;

   procedure Do_Exit ;

    var
        i : short_integer ;
        Flag : boolean ;

     begin
       Flag := true ;
       While Flag AND (N_Window > 0) do
             Do_CloseWind(Flag, Front_Window) ;
       if Flag then
          ExitPrompt := true ;
     end ;

  procedure Menu_Select;

    var
        i    : short_integer ;
        Flag : boolean ;

     begin

       With Gem_Result do
         begin
           Menu_Normal(OP_Menu, msg[3]);
           Case msg[4] of
               10 : ;
               22 : Do_OpenWind ;
               23 : Do_SaveFile(Flag) ;
               24 : Do_CloseWind(Flag, Front_Window) ;
               25 : Do_Exit ;

               26 : MarkBlk ;
               28 : CutBlk ;
               29 : PasteBlk ;
               30 : DeleteBlk ;
               31 : HideBlk ;

               32 : PrintOutline ;
               33 : DiskPrint ;
            34,35,
            36,37 : RecallWindow(msg[4] - 33, Flag) ;
           end;
         end;
       Set_MenuBar ;
    end;    


BEGIN
END.

