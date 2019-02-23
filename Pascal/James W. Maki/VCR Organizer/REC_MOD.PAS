{$M+}
{$E+}

program Search_Module;

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

  Const
       {$I B:VCR_Cnst.Pas }

  Type
       {$I B:VCR_Type.Pas }

  Var
       {$I B:VCR_Var.Pas }



 procedure DateStr(Counter : integer ; Var S : string);
    External ;

 procedure Open_DO_Wind(i : integer);
    External ;

 procedure WSlide_Size(i, j, k : integer);
    External ;

 procedure Do_Close_Window( Module : integer ) ;
    External ;

 procedure Trail_Sp( Var S : Name ) ;
    External ;

 procedure Alert_Box( L1, L2, L3, L4, L5 : integer ;
                      S1, S2, S3 : string ; n : integer ;
                     var Result : integer ) ;
    External ;

 procedure Val(S : string ; Var Result : integer ; Var Flag : Boolean);
    External ;

 procedure Draw_Names;
    External ;

 procedure Draw_Numbers;
    External ;


 procedure Find_Alpha( AlphName : Name ; Var Last_Name_Char : integer ) ;

   var
       Temp      : char;
       Space,
       i,
       letter    : integer ;
       Last_Char,
       Alph_Pos  : string ;
       the, a    : string;


   begin
     Trail_Sp(AlphName);

     the := 'The ';
     a   := 'A ';

     i := Pos(the, AlphName);
     if i = 1 then
        Delete(AlphName,1,4)
     else
        begin
          i := Pos(a, AlphName);
          if i = 1 then
             Delete(AlphName,1,2);
        end;

     letter := -1;
     Alph_Pos := Copy(AlphName, 1, 1);

     for i := $41 to $5A do                       { upper case letter }
         begin
           Temp := chr(i);
           if Temp = Alph_Pos then letter := i - $41;
         end;
     if letter < 0 then
        for i := $61 to $7A do              { lower case letter }
            begin
              Temp := chr(i);
              if Temp = Alph_Pos then letter := i - $61;
             end;
     if letter < 0 then letter := 26;       { non-letter first character }
     Last_Name_Char := letter;
   end;



 procedure Compare_Names(New_Name, File_Name : Name ; Var Add : boolean);

  var
      i : integer;
      the, a : string;

   begin
     the := 'The ';
     a   := 'A ';

     Len := Length(New_Name);
     i   := Pos(the, New_Name);
     if (i = 1) AND (Len > 4) then
        Delete(New_Name,1,4)
     else
        begin
          Len := Length(New_Name);
          i   := Pos(a, New_Name);
          if (i = 1) AND (Len > 2) then
             Delete(New_Name,1,2);
        end;

     Len := Length(File_Name);
     i   := Pos(the, File_Name);
     if (i = 1) AND (Len > 4) then
        Delete(File_Name,1,4)
     else
        begin
          Len := Length(File_Name);
          i   := Pos(a, File_Name);
          if (i = 1) AND (Len > 2) then
             Delete(File_Name,1,2);
        end;

     if New_Name > File_Name then Add := false
     else
        Add := true;
   end;


 procedure Set_Order(Cur_Tape : integer);

  var
     i,
     Next_Rec,
     Prev_Rec,
     Current_Rec : integer ;

  begin
    Tape_Delete[Cur_Tape] := false;
    Next_Rec    := VCR_Order[1,0];
    Prev_Rec    := VCR_Order[2,0];
    Current_Rec := Cur_Tape;

    if Next_Rec = 0 then                  { First Record stored }
       begin
         VCR_Order[1,0] := Cur_Tape;
         VCR_Order[2,0] := Cur_Tape;
       end
    else
       begin
         if VCR_Tape[0,Cur_Tape] < VCR_Tape[0,Next_Rec] then
            begin                                 { Add before first record }
              VCR_Order[1,Cur_Tape] := Next_Rec;
              VCR_Order[1,0]        := Cur_Tape;
              VCR_Order[2,Next_Rec] := Cur_Tape;
            end
         else
            begin
              if VCR_Tape[0,Cur_Tape] >= VCR_Tape[0,Prev_Rec] then
                 begin                             { Add after last record }
                   VCR_Order[1,Prev_Rec] := Cur_Tape;
                   VCR_Order[2,Cur_Tape] := Prev_Rec;
                   VCR_Order[2,0]        := Cur_Tape;
                 end
              else
                 repeat                { Search through list to Sort }
                   Current_Rec := Next_Rec;
                   Next_Rec    := VCR_Order[1,Current_Rec];
                   Prev_Rec    := VCR_Order[2,Current_Rec];
                   if VCR_Tape[0,Cur_Tape] < VCR_Tape[0,Next_Rec] then
                      begin
                        VCR_Order[1,Current_Rec] := Cur_Tape;
                        VCR_Order[2,Next_Rec]    := Cur_Tape;
                        VCR_Order[1,Cur_Tape]    := Next_Rec;
                        VCR_Order[2,Cur_Tape]    := Current_Rec;
                        Next_Rec := 0;
                      end;
                 until Next_Rec = 0;
            end;
       end;
  end;


 procedure Set_Pointer( New_Rec : integer);

  var
     Next_Rec,
     Prev_Rec,
     Current_Rec,
     Offset        : integer;
     Add           : boolean;

  begin
    Movie_Delete[New_Rec] := false;
    Find_Alpha(VCR_Name[New_Rec], Offset);
    Next_Rec    := VCR_Point[1,Offset];
    Prev_Rec    := VCR_Point[2,Offset];
    Current_Rec := VCR_Point[1,Offset];

    if Next_Rec = 0 then                  { First Record stored }
       begin
         VCR_Point[1,Offset] := New_Rec;
         VCR_Point[2,Offset] := New_Rec;
       end
    else
       begin
         Compare_Names(VCR_Name[New_Rec], VCR_Name[Next_Rec], Add);
         if Add then                      { Add before first record }
            begin
              VCR_Next[2,Next_Rec]:= New_Rec;
              VCR_Next[1,New_Rec] := Next_Rec;
              VCR_Point[1,Offset] := New_Rec;
            end
         else
            begin
              Compare_Names(VCR_Name[New_Rec], VCR_Name[Prev_Rec], Add);
              if NOT Add then             { Add after last record }
                 begin
                   VCR_Next[1,Prev_Rec]:= New_Rec;
                   VCR_Next[2,New_Rec] := Prev_Rec;
                   VCR_Point[2,Offset] := New_Rec;
                 end
              else
                 repeat             { Search through list to alphabatize }
                   Current_Rec := Next_Rec;
                   Next_Rec    := VCR_Next[1,Current_Rec];
                   Prev_Rec    := VCR_Next[2,Current_Rec];
                   Compare_Names(VCR_Name[New_Rec],
                                VCR_Name[Current_Rec], Add);
                   if Add then
                      begin
                        VCR_Next[1,Prev_Rec]    := New_Rec;
                        VCR_Next[2,Current_Rec] := New_Rec;
                        VCR_Next[1,New_Rec]     := Current_Rec;
                        VCR_Next[2,New_Rec]     := Prev_Rec;
                      end;
                 until Add OR (Next_Rec = 0);
            end;
       end;
  end;



  procedure Count_Str( Counter : integer ; Var S : string);

    begin
      if (Counter > 0) AND (Counter <= Max_Movies) then
         DateStr(VCR_Count[Counter], S);
    end;


  procedure Ret_Record;

    var
        i,
        Y_Line,
        Y_Limit,
        Tape_No  : integer ;

    begin
      Name_Select := 0;
      Tape_Select := 0;
      if (Gem_Result.X_Mouse > x0) AND
         (Gem_Result.X_Mouse < x0 + w0 - 5) then
         begin
           Y_Line := ((Gem_Result.Y_Mouse - y0 - 2 * Resolution) DIV
                              (9 * Resolution)) + 1;
           if Dsply_Name < 5 then
              Y_Limit := Dsply_Name
           else
              Y_Limit := 5;
           if (Y_Line > 0) and (Y_Line < Y_Limit + 1) then
              begin
                Name_Select := Output_Name[Y_Line + Name_Offset];
                Tape_No := VCR_TapeNo[Name_Select];

                for i := 1 to 2 do
                    if VCR_Check[i,Tape_No] then
                       begin
                         Input_String[i] := Check;
                         VCR_Check[i,Tape_Current] := true;
                       end
                    else
                       begin
                         Input_String[i] := Sp;
                         VCR_Check[i,Tape_Current] := false;
                       end;

                DateStr(VCR_Tape[0,Tape_No], Input_String[3]);

                Input_String[4] := VCR_Name[VCR_Tape[1,Tape_No]];
                Count_Str(VCR_Tape[1,Tape_No], Input_String[5]);

                Input_String[6] := VCR_Name[VCR_Tape[2,Tape_No]];
                Count_Str(VCR_Tape[2,Tape_No], Input_String[7]);

                Input_String[8] := VCR_Name[VCR_Tape[3,Tape_No]];
                Count_Str(VCR_Tape[3,Tape_No], Input_String[9]);

                Input_String[10] := VCR_Name[VCR_Tape[4,Tape_No]];
                Count_Str(VCR_Tape[4,Tape_No],Input_String[11]);

                Input_String[12] := VCR_Name[VCR_Tape[5,Tape_No]];
                Count_Str(VCR_Tape[5,Tape_No],Input_String[13]);

                Input_String[14] := VCR_Name[VCR_Tape[6,Tape_No]];
                Count_Str(VCR_Tape[6,Tape_No],Input_String[15]);

                VCR_Retrieve := True;
                if Wind_Handle[1] < 0 then
                   Open_DO_Wind(1)
                else
                   Bring_To_Front(Wind_Handle[1]);

              end;
         end;
    end;


  procedure Ret_Tape;

    var
        i,
        Y_Limit,
        Tape_No,
        Y_Line  : integer ;

    begin
      Name_Select := 0;
      Tape_Select := 0;
      if (Gem_Result.X_Mouse > x0) AND
         (Gem_Result.X_Mouse < x0 + w0 - 5) then
         begin
           Y_Line := ((Gem_Result.Y_Mouse - y0 - 2 * Resolution) DIV
                              (9 * Resolution)) + 1;
           if Dsply_Tape < 15 then
              Y_Limit := Dsply_Tape
           else
              Y_Limit := 15;
           if (Y_Line > 0) and (Y_Line < Y_Limit + 1) then
              begin
                Tape_Select := Y_Line + Tape_Offset;
                Tape_No     := Output_Tape[Tape_Select];
                Name_Select := VCR_Tape[1,Tape_No];

                for i := 1 to 2 do
                    if VCR_Check[i,Tape_No] then
                       begin
                         Input_String[i] := Check;
                         VCR_Check[i,Tape_Current] := true;
                       end
                    else
                       begin
                         Input_String[i] := Sp;
                         VCR_Check[i,Tape_Current] := false;
                       end;

                DateStr(VCR_Tape[0,Tape_No], Input_String[3]);

                Input_String[4] := VCR_Name[VCR_Tape[1,Tape_No]];
                Count_Str(VCR_Tape[1,Tape_No], Input_String[5]);

                Input_String[6] := VCR_Name[VCR_Tape[2,Tape_No]];
                Count_Str(VCR_Tape[2,Tape_No], Input_String[7]);

                Input_String[8] := VCR_Name[VCR_Tape[3,Tape_No]];
                Count_Str(VCR_Tape[3,Tape_No], Input_String[9]);

                Input_String[10] := VCR_Name[VCR_Tape[4,Tape_No]];
                Count_Str(VCR_Tape[4,Tape_No],Input_String[11]);

                Input_String[12] := VCR_Name[VCR_Tape[5,Tape_No]];
                Count_Str(VCR_Tape[5,Tape_No],Input_String[13]);

                Input_String[14] := VCR_Name[VCR_Tape[6,Tape_No]];
                Count_Str(VCR_Tape[6,Tape_No],Input_String[15]);

                VCR_Retrieve := True;
                if Wind_Handle[1] < 0 then
                   Open_DO_Wind(1)
                else
                   Bring_To_Front(Wind_Handle[1]);
              end;
         end;
    end;


  procedure Get_MovieRec(First_Letter : integer);

    var
        i, Next_Rec  : integer ;
        L_Offset,
        L_Slide      : long_integer;

    begin
       if First_Letter < 0 then
          Dsply_Name := 0
       else
          begin
            Next_Rec := VCR_Point[1,First_Letter];
            i := 0;
            While Next_Rec <> 0 do
                begin
                  i := i + 1;
                  Output_Name[i] := Next_Rec;
                  Next_Rec := VCR_Next[1,Next_Rec];
                end;
            Dsply_Name := i;
          end;

       if Name_Offset + 5 > Dsply_Name then
          Name_Offset := Dsply_Name - 5;
       if Name_Offset < 0 then Name_Offset := 0;

       L_Slide  := Slide_Pos;
       L_Offset := Name_Offset;

       if Dsply_Name <= 5 then
          L_Slide := 1
       else
          L_Slide := (L_Offset * 1000) DIV (Dsply_Name - 5);

       Slide_Pos   := int(L_Slide);
       Name_Offset := int(L_Offset);
       if Slide_Pos < 1 then Slide_Pos := 1;

       WSlide_Size(5, Dsply_Name, 4);
       Wind_Set(Wind_Handle[4], WF_VSlide, Slide_Pos, Dummy, Dummy, Dummy);

       if Module <> Wind_Handle[4] then
          Set_Clip(0,0,640,400);

       Draw_Names;
    end;


  procedure Get_TapeNo;

    var
        i, Next_Rec  : integer ;
        L_Offset,
        L_Slide      : long_integer;

    begin
       Next_Rec := VCR_Order[1,0];
       i := 0;
       While Next_Rec <> 0 do
           begin
             i := i + 1;
             Output_Tape[i] := Next_Rec;
             Next_Rec := VCR_Order[1,Next_Rec];
           end;
       Dsply_Tape  := i;

       if Tape_Offset + 15 > Dsply_Tape then
          Tape_Offset := Dsply_Tape - 15;
       if Tape_Offset < 0 then Tape_Offset := 0;

       L_Slide  := Slide_Pos;
       L_Offset := Tape_Offset;

       if Dsply_Tape <= 15 then
          L_Slide := 1
       else
          L_Slide := (L_Offset * 1000) DIV (Dsply_Tape - 15);

       Slide_Pos   := int(L_Slide);
       Tape_Offset := int(L_Offset);
       if Slide_Pos < 1 then Slide_Pos := 1;

       WSlide_Size(15, Dsply_Tape, 5);
       Wind_Set(Wind_Handle[5], WF_VSlide, Slide_Pos, Dummy, Dummy, Dummy);

       if Module <> Wind_Handle[5] then
          Set_Clip(0,0,640,400);

       Draw_Numbers;
    end;


  procedure LetterSelect(First_Letter : integer ) ;

   var
       i,
       Last_Char,
       Next_Rec  : integer ;
       c         : char;

    begin
      Hide_Mouse;
      Work_Rect(Wind_Handle[3],x0,y0,w0,h0);
      Set_Clip(x0,y0,w0,h0);

      for i := 0 to 26 do
          if VCR_Inverse[i] then
             begin
               if i = 26 then
                  c := chr($2A)
               else
                  c := chr($41 + i);
               VCR_Inverse[i] := false;
               Draw_String(342 - 13 * (25 - i),
                          (56 - i) * Resolution, c);
             end;

      Text_Style($02);
        if First_Letter = 26 then
           c := chr($2A)
        else
           c := chr($41 + First_Letter);
        Draw_String(342 - 13 * (25 - First_Letter),
                   (56 - First_Letter) * Resolution, c);
      Text_Style($00);
      Show_Mouse;

      VCR_Inverse[First_Letter] := true;

      if Module <> Wind_Handle[4] then
         Bring_To_Front(Wind_Handle[4]);

      Get_MovieRec(First_Letter);
  end;


  procedure ClearSelect;

   var
      i, j, k       : integer;
      StartLoop,
      EndLoop       : integer;

    begin
      if Module = Wind_Handle[1] then
         begin
           VCR_Check[1,Tape_Current] := false;
           VCR_Check[2,Tape_Current] := false;
           StartLoop := 1;
           EndLoop   := 15;
        end
      else 
         StartLoop := 0;

      if StartLoop > 0 then
         for i := StartLoop to EndLoop do
             begin
               Input_String[i] := No_Sp;
               for j := 0 to XY_VCR[3,i] do
                   Draw_String(x0 + XY_VCR[1,i] + j * 8,
                               y0 + XY_VCR[2,i] * Resolution, Sp);
             end;
      Prev_Module := -25;
    end;


  procedure Save_VCR;

   var
       i, j,
       Save_Movie,
       Save_Tape   : integer;

    begin
      Len := Length(Input_String[4]);
      if (VCR_Current > Max_Movies - 60) AND (Len > 0) then
         Alert_Box(0,4,0,5,0,'Continue',No_Sp,No_Sp,1,i)
      else
         if Len > 0 then
            begin
              Save_Tape := 0;
              for i := 1 to Tape_Current do
                  if Tape_Delete[i] then
                     begin
                       Save_Tape := Tape_Current;
                       Tape_Current := i;
                       i := Max_Movies;
                     end;

              for i := 1 to 2 do
                  if Input_String[i] = Check then
                     VCR_Check[i,Tape_Current] := true
                  else
                     VCR_Check[i,Tape_Current] := false;

              Val(Input_String[3], VCR_Tape[0,Tape_Current], Flag);
              Set_Order(Tape_Current);
              for i := 0 to 5  do
                  begin
                    Len := Length(Input_String[2 * i + 4]);
                    if Len > 0 then
                       begin
                         Save_Movie := 0;
                         for j := 1 to VCR_Current do
                             if Movie_Delete[j] then
                                begin
                                  Save_Movie := VCR_Current;
                                  VCR_Current := j;
                                  j := Max_Movies;
                                end;
                         VCR_Name[VCR_Current] := Input_String[2 * i + 4];
                         Val(Input_String[2*i+5],VCR_Count[VCR_Current], Flag);
                         VCR_TapeNo[VCR_Current] := Tape_Current;
                         VCR_Tape[i + 1, Tape_Current] := VCR_Current;
                         Set_Pointer(VCR_Current);
                         if Save_Movie > 0 then
                            VCR_Current := Save_Movie
                         else
                            VCR_Current := VCR_Current + 1;
                       end;
                  end;
              if Save_Tape > 0 then
                 Tape_Current := Save_Tape
              else
                 Tape_Current := Tape_Current + 1;
            end;
    end;


  procedure SaveSelect;

   var
       i, j,
       SlashPos : integer;
       FileName : Path_Name;


    begin
      if Module = Wind_Handle[1] then
         begin
           Save_VCR;
           ClearSelect;
         end;
    end;


  procedure AbortSelect;

    var
        i : integer;

    begin
      if Module = Wind_Handle[1] then
         if VCR_Retrieve then
            VCR_Retrieve := false;
      ClearSelect;
      if Module = Wind_Handle[1] then
         Do_Close_Window(Module);
    end;


  procedure ExitSelect;

    begin
      SaveSelect;
      AbortSelect;
    end;


  procedure DeleteSelect(Delete_Rec : integer);
  
    var
        i : integer;
        FirstLetter : integer;

    begin
      if Module = Wind_Handle[1] then
         begin
           Find_Alpha(VCR_Name[Delete_Rec], FirstLetter);

           if VCR_Next[1,Delete_Rec] = 0 then    { Reverse Pointer }
              VCR_Point[2,FirstLetter] := VCR_Next[2,Delete_Rec]
           else
              VCR_Next[2,VCR_Next[1,Delete_Rec]] := VCR_Next[2,Delete_Rec];

           if VCR_Next[2,Delete_Rec] = 0 then          { Forward Pointer }
              VCR_Point[1,FirstLetter] := VCR_Next[1,Delete_Rec]
           else
              VCR_Next[1,VCR_Next[2,Delete_Rec]] := VCR_Next[1,Delete_Rec];

           VCR_Next[1,Delete_Rec] := 0;
           VCR_Next[2,Delete_Rec] := 0;

           Movie_Delete[Delete_Rec] := True;
         end;

    end;


  procedure Delete_Rec(Tape_No : integer);

   var
      i, Current_Rec : integer;

    begin
      Tape_Delete[Tape_No] := true;

      VCR_Check[1,Tape_No] := false;
      VCR_Check[2,Tape_No] := false;

      if VCR_Order[1,Tape_No] = 0 then             { Set Reverse Pointer }
         VCR_Order[2,0] := VCR_Order[2,Tape_No]
      else
         VCR_Order[2,VCR_Order[1,Tape_No]] := VCR_Order[2,Tape_No];

      if VCR_Order[2,Tape_No] = 0 then             { Set Forward Pointer }
         VCR_Order[1,0] := VCR_Order[1,Tape_No]
      else
         VCR_Order[1,VCR_Order[2,Tape_No]] := VCR_Order[1,Tape_No];

      VCR_Order[1,Tape_No] := 0;
      VCR_Order[2,Tape_No] := 0;

      for i := 0 to 5 do
          begin
            Current_Rec := VCR_Tape[i + 1, Tape_No];

            if Current_Rec > 0 then
               DeleteSelect(Current_Rec);
          end;

      for i := 0 to 6 do
          VCR_Tape[i,Tape_No] := 0;
    end;


  procedure EditSave;

   var
      Tape_No : integer;

    begin
      if Name_Select > 0 then
         Tape_No := VCR_TapeNo[Name_Select]
      else
         Tape_No := Output_Tape[Tape_Select];
      Delete_Rec(Tape_No);
      Save_VCR;
      ClearSelect;
      VCR_Retrieve := false;
    end;


BEGIN
END.
