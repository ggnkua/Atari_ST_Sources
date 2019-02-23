{$M+}
{$E+}

program Resource_Module;

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

  Const
       {$I B:VCR_Cnst.Pas }

  Type
       {$I B:VCR_Type.Pas }

  Var
       {$I B:VCR_Var.Pas }


 procedure WSlide_Size(i, j, k : integer);
    External ;

 procedure Get_PhoneRec(Letter : integer);
    External ;

 procedure Erase_Cursor;
    External ;

 procedure EditSave;
    External ;

 procedure SaveSelect;
    External ;

 procedure ExitSelect;
    External ;

 procedure ClearSelect;
    External ;

 procedure AbortSelect;
    External ;

 procedure LetterSelect( i : integer ) ;
    External ;

 procedure Get_MovieRec( Letter : integer );
    External ;

 procedure Get_TapeNo;
    External ;

 procedure DeleteSelect(Delete_Rec : integer);
    External ;

 procedure Init_Files;
    External ;

 procedure Val( S : string ; Var Result : integer ; Var Flag : Boolean ) ;
    External ;

 procedure Alert_Box( i, j, k , l, m : integer ;
                      S1, S2, S3 : string ; 
                      n : integer ; Var Result : integer ) ;
      External ;

  procedure Multi_PrtPhone;
      External ;

  procedure Select_Window(Wind_Number : integer);
      External ;

  procedure Save_Default;
      External ;

  procedure Print_Contents;
      External ;

  procedure Delete_Rec(Tape_No : integer) ;
      External ;


 procedure Draw_Logo( Var Logo_Result : integer );

  var
     Logo        : Dialog_Ptr;
     Logo_Screen : Tree_Index;
     Logo_Item   : array[1..10] of integer;

   begin
       Logo := New_Dialog(10, 0, 0, 40, 15);
       Center_Dialog(Logo);

       Logo_Item[1] := Add_DItem(Logo, G_Text, 0, 0, 1, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[1], 'VCR Organizer',
                 System_Font, TE_Center);

       Logo_Item[2] := Add_DItem(Logo, G_Text, 0, 0, 2, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[2], '=== =========',
                 System_Font, TE_Center);

       Logo_Item[3] := Add_DItem(Logo, G_Text, 0, 0, 3, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[3], 'James Maki', System_Font, TE_Center);

       Logo_Item[4] := Add_DItem(Logo, G_BoxText,
                                 Default | Touch_Exit | Selectable,
                                 14, 7, 12, 1, -3, 4096 | 256 | 128);
       Set_DText(Logo, Logo_Item[4], 'Continue', System_Font, TE_Center);

       Logo_Item[5] := Add_DItem(Logo, G_Text, 0, 0, 9, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[5], '<><><><><><><><><><><><><><><><><>',
                 System_Font, TE_Center);

       Logo_Item[6] := Add_DItem(Logo, G_Text, 0, 0, 10, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[6], '<> Portions of this Program are <>',
                 System_Font, TE_Center);

       Logo_Item[7] := Add_DItem(Logo, G_Text, 0, 0, 11, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[7], '<> Copyright   1986 OSS and CCD <>',
                 System_Font, TE_Center);

       Logo_Item[8] := Add_DItem(Logo, G_Text, 0, 16, 11, 1, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[8], chr($BD), System_Font, TE_Center);

       Logo_Item[9] := Add_DItem(Logo, G_Text, 0, 0, 12, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[9], '<>  Used by Permission of OSS.  <>',
                 System_Font, TE_Center);

       Logo_Item[10] := Add_DItem(Logo, G_Text, 0, 0, 13, 40, 1, 0, 256 | 128);
       Set_DText(Logo, Logo_Item[10], '<><><><><><><><><><><><><><><><><>',
                 System_Font, TE_Center);

       Logo_Screen := Do_Dialog(Logo, 0);
       Logo_Result := Logo_Screen;

       End_Dialog(Logo);
       Delete_Dialog(Logo);
   end;


 procedure Set_MenuBar(NewMenu : integer);

   var
       i : integer;

   begin
     for i := 2 to 11 do
         Menu_Disable(Do_Menu, MenuItem.Item[i]);

     Menu_Enable(Do_Menu, MenuItem.Item[2]);
     Menu_Enable(Do_Menu, MenuItem.Item[3]);
     Menu_Enable(Do_Menu, MenuItem.Item[4]);
     Menu_Enable(Do_Menu, MenuItem.Item[5]);

     if NewMenu = 1 then
        begin
          Menu_Enable(Do_Menu, MenuItem.Item[6]);
          Menu_Enable(Do_Menu, MenuItem.Item[9]);
          if VCR_Retrieve then
             Menu_Enable(Do_Menu, MenuItem.Item[11])
          else
             begin
               Menu_Enable(Do_Menu, MenuItem.Item[7]);
               Menu_Enable(Do_Menu, MenuItem.Item[8]);
             end;
        end;
   end;


 procedure Open_DO_Wind( i : integer ) ;

   var
       Wind_Type : integer;


   begin
     if N_Window < 7 then
        begin
          if NOT VCR_Retrieve and (i = 1) then
             begin
               VCR_Check[1,Tape_Current] := false;
               VCR_Check[2,Tape_Current] := false;
             end;
          if Wind_Handle[i] > 0 then
             begin
               Bring_To_Front(Wind_Handle[i]);
               Work_Rect(Wind_Handle[i], x0, y0, w0, h0);
               Select_Window(Wind_Handle[i]);
             end
          else
             begin
               Slide_Pos := 1;
               if i = 1 then
                  Wind_Type := $01 + $02
               else
                  if (i = 5) OR (i = 4) then
                     Wind_Type := $01 + $40 + $80 + $100
                  else
                     Wind_Type := $01 ;
               Wind_Handle[i] := New_Window(Wind_Type, Wind_Name[i],
                                 Wind_Coor[i,1], Wind_Coor[i,2],
                                 Wind_Coor[i,3], Wind_Coor[i,4]);
               Open_Window(Wind_Handle[i],
                           Wind_Coor[i,1], Wind_Coor[i,2],
                           Wind_Coor[i,3], Wind_Coor[i,4]);
               N_Window := N_Window + 1;
             end;

          if (i = 4) OR (i = 5) then
              Wind_Set(Wind_Handle[i], WF_VSlide, Slide_Pos, Dummy,
                       Dummy, Dummy);
        end
     else
        Alert_Box(6,0,7,0,8,'Continue',No_Sp,No_Sp,1,i);
   end;


  procedure Do_Close_Window( Wind_Msg : integer ) ;

   var  
       i, j  : integer;

   begin
     N_Window := N_Window - 1;
     Set_MenuBar(0);

     Close_Window(Wind_Msg);
     Delete_Window(Wind_Msg);

     for i := 1 to 5 do
         if Wind_Msg = Wind_Handle[i] then
            Wind_Handle[i] := -20;
   end;


 procedure SetUpMenu;

  var
      i : integer ;

   begin
     With MenuItem do
     begin
       DO_Menu := New_Menu(12, '  VCR Organizer  ');

       Title[1] := Add_MTitle(DO_Menu, '  File    ');
       Title[2] := Add_MTitle(DO_Menu, '  Record  ');

       Item[1]  := Add_MItem(DO_Menu, Title[1], '   Enter Data     ');
       Item[2]  := Add_MItem(DO_Menu, Title[1], '   Print Contents ');
       Item[3]  := Add_MItem(DO_Menu, Title[1], '   Print Cards    ');
       Item[4]  := Add_MItem(DO_Menu, Title[1], '------------------');
       Item[4]  := Add_MItem(DO_Menu, Title[1], '   Exit Program   ');

       Item[6]  := Add_MItem(DO_Menu, Title[2], ' ^S - Save      ');
       Item[7]  := Add_MItem(DO_Menu, Title[2], '      Save/Exit ');
       Item[8]  := Add_MItem(DO_Menu, Title[2], '      Clear     ');
       Item[9]  := Add_MItem(DO_Menu, Title[2], '      Exit      ');
       Item[10] := Add_MItem(DO_Menu, Title[2], '----------------');
       Item[11] := Add_MItem(DO_Menu, Title[2], '      Delete    ');

       for i := 2 to 11 do
           Menu_Disable(DO_Menu, Item[i]);

       Menu_Enable(DO_Menu, Item[2]);
       Menu_Enable(DO_Menu, Item[3]);
       Menu_Enable(DO_Menu, Item[5]);

     end;
     Hide_Mouse;
     Draw_Menu(DO_Menu);
     Show_Mouse;
   end;


  procedure ExitProgram;

    var
        i, j : integer;

    begin
      Rewrite(CheckFv);
      Rewrite(InitialFv);
      Rewrite(NameFv);
      Rewrite(DeleteFv);

      Write(InitialFv,VCR_Current);      { Dummy Input for location 0 }
      Write(InitialFv,VCR_Current);

      Write(InitialFv,Tape_Current);

      if VCR_Current > 1 then
         begin
           for j := 0 to VCR_Current do
               for i := 1 to 2 do
                   Write(InitialFv,VCR_Next[i,j]);

           for i := 0 to VCR_Current do
               Write(InitialFv,VCR_TapeNo[i]);

           for i := 0 to VCR_Current do
               Write(InitialFv,VCR_Count[i]);

           for j := 0 to VCR_Current do
               for i := 0 to 6 do
                   Write(InitialFv,VCR_Tape[i,j]);

           for j := 1 to 2 do
               for i := 0 to Tape_Current do
                   Write(InitialFv,VCR_Order[j,i]);

           for j := 0 to VCR_Current do
               for i := 1 to 2 do
                   Write(CheckFv,VCR_Check[i,j]);

           for i := 0 to VCR_Current do
               Write(NameFv,VCR_Name[i]);
         end;

      for j := 0 to 26 do
          for i := 1 to 2 do
              Write(InitialFv,VCR_Point[i,j]);

      for i := 1 to VCR_Current do
          Write(DeleteFv,Movie_Delete[i]);

      for i := 1 to Tape_Current do
          Write(DeleteFv,Tape_Delete[i]);

      Close(CheckFv);
      Close(InitialFv);
      Close(NameFv);
      Close(DeleteFv);
    end;


  procedure SelectSave ;

     begin
       if Module = Wind_Handle[1] then      { Save Selected }
          begin
            if VCR_Retrieve then
               begin
                 EditSave;
                 Do_Close_Window(Wind_Handle[1]);
                 if Name_Select > 0 then
                    Get_MovieRec(Letter);
               end
            else
               SaveSelect;
          end
       else
          SaveSelect;
     end ;
 
 procedure Menu_Select;

  var
      i, j,
      Tape_No,
      Current_Rec : integer;
      SavePath    : Path_Name;

  begin
   With Gem_Result do
   begin
   Case msg[4] of
       8 : Draw_Logo( i );
      18 : begin
             VCR_Retrieve := false;
             Set_MenuBar(1);
             Prev_Module := -25;
             Open_DO_Wind(1);           { Select Address Window }
           end;
      19 : Print_Contents;              {  Select Print Contents  }
      20 : Multi_PrtPhone;              {  Select Print Label  }
      22 : begin
             ExitProgram;                           { Selected Exit  }
             ExitPrompt := true;                    { Set Boolean    }
             for i := 1 to 5 do
                 if Wind_Handle[i] > 0 then         { Close Window   }
                    begin
                      Close_Window(Wind_Handle[i]);
                      Delete_Window(Wind_Handle[i]);
                    end;
           end;
      23 : SelectSave ;
      24 : ExitSelect;
      25 : ClearSelect;
      26 : AbortSelect;
      28 : if Module = Wind_Handle[1] then         { Delete Selected }
              begin
                Hide_Mouse;
                if Name_Select > 0 then
                   Tape_No := VCR_TapeNo[Name_Select]
                else
                   Tape_No := Output_Tape[Tape_Select];
                Delete_Rec(Tape_No);
                Tape_Delete[Tape_No] := True;
                ClearSelect;
                Do_Close_Window(Wind_Handle[1]);
                VCR_Retrieve := false;
                Show_Mouse;
              end;
    end;
    Menu_Normal(DO_Menu, msg[3]);
   end;
  end;


BEGIN
END.

