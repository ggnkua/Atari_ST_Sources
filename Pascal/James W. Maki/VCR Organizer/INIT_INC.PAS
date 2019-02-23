  procedure Init_Files;

    var
        i, j      : integer ;
        FileError : integer ;
        PathStr   : c_string ;
        P_String  : Str255 ;
        DefFolder : Path_Name;

   procedure InitOldFiles;

     var
         i, j : integer;

    begin
      Read(InitialFv,VCR_Current);       { Dummy Input for location 0 }

      Read(InitialFv,VCR_Current);
      Read(InitialFv,Tape_Current);

      if VCR_Current > 1 then
         begin
           for i := 0 to Max_Movies do
               Output_Name[i] := 0;

           for i := 1 to 2 do
               for j := 0 to Max_Movies do
                   VCR_Next[i,j] := 0;

           for j := 0 to VCR_Current do
               for i := 1 to 2 do
                   Read(InitialFv,VCR_Next[i,j]);

           for i := 0 to VCR_Current do
               Read(InitialFv,VCR_TapeNo[i]);

           for i := 0 to VCR_Current do
               Read(InitialFv,VCR_Count[i]);

           for j := 0 to VCR_Current do
               for i := 0 to 6 do
                   Read(InitialFv,VCR_Tape[i,j]);

           for j := 1 to 2 do
               for i := 0 to Tape_Current do
                   Read(InitialFv,VCR_Order[j,i]);

           for j := 0 to VCR_Current do
               for i := 1 to 2 do
                   Read(CheckFv,VCR_Check[i,j]);

           for i := 0 to VCR_Current do
               Read(NameFv,VCR_Name[i]);
         end;

       for j := 0 to 26 do
           for i := 1 to 2 do
               Read(InitialFv,VCR_Point[i,j]);

       for i := 1 to VCR_Current do
           Read(DeleteFv,Movie_Delete[i]);

       for i := 1 to Tape_Current do
           Read(DeleteFv,Tape_Delete[i]);
    end;


   procedure InitNewFiles;

     var
         i, j : integer;

    begin
      if (FileError = -33) OR        { No Data Files On Default Disk }
         (FileError = -34) then
         begin
           FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash, InitFn) ;
           Rewrite(InitialFv, FilePath);

           FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash, VCRFn) ;
           Rewrite(NameFv, FilePath);
           Put(NameFv);                    { Dummy Input for 0 }

           FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash,CheckFn) ;
           Rewrite(CheckFv, FilePath);

           FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash,DeleteFn) ;
           Rewrite(DeleteFv, FilePath) ;

           VCR_Current := 1;
           Tape_Current := 1;

           for i := 0 to Max_Movies do
               Output_Name[i] := 0;

           for i := 1 to 2 do
               for j := 0 to Max_Movies do
                   VCR_Next[i,j] := 0;

           for i := 1 to 2 do
               for j := 0 to 26 do
                   VCR_Point[i,j] := 0;

           for i := 0 to Max_Movies do
               VCR_Name[i] := '';

           for i := 0 to Max_Movies do
               VCR_TapeNo[i] := 0;

           for i := 0 to Max_Movies do
               VCR_Count[i] := 0;

           for j := 0 to Max_Movies do
               for i := 0 to 6 do
                   VCR_Tape[i,j] := 0;

           for j := 0 to Max_Movies do
               for i := 1 to 2 do
                   VCR_Check[i,j] := false;

           for j := 1 to 2 do
               for i := 0 to Max_Movies do
                   VCR_Order[j,i] := 0;

           for i := 0 to Max_Movies do
               begin
                 Movie_Delete[i] := false;
                 Tape_Delete[i]  := false;
               end;

         end
      else
         Alert_Box(0,0,9,0,0,'Continue',No_Sp,No_Sp,1,i);
    end;

    function CurDsk : integer ;
       GemDos( $19 );

    procedure GetDefPath( Var BufferStr : c_string ; Drive : integer ) ;  
       GemDos($47);

    begin
     { -- Check for Data Files and Open/Reset if present -- }          
      IO_Check(False);
      i := CurDsk;

      DefDrive := Chr(i + $41);
      GetDefPath(PathStr, 0) ;  
      C_To_PStr(PathStr, P_String) ;
      DefFolder := P_String ;

      FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash, InitFn) ;
      Reset(InitialFv, FilePath);
      FileError := IO_Result;
     
      FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash, VCRFn) ;
      Reset(NameFv, FilePath);
      FileError := IO_Result;

      FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash, CheckFn) ;
      Reset(CheckFv, FilePath);
      FileError := IO_Result;

      FilePath := Concat(DefDrive,Colon,DefFolder,PathSlash, DeleteFn) ;
      Reset(DeleteFv, FilePath);
      FileError := IO_Result;

      IO_Check(True);
      if FileError = 0 then             { Data Files Present }
         InitOldFiles
      else
         InitNewFiles;
    end;


procedure Init_Values;

 var
       i, j         : integer;

  procedure Init_XYPB;

  begin
   { VCR Input }
    XY_VCR[1,1] := 250; { X }  { Hi-Fi }
    XY_VCR[2,1] := 12;  { Y }
    XY_VCR[3,1] := 1;   { Len }

    XY_VCR[1,2] := 392;        { Stereo }
    XY_VCR[2,2] := 12;
    XY_VCR[3,2] := 1;

    XY_VCR[1,3] := 88;        { Tape # }
    XY_VCR[2,3] := 12;
    XY_VCR[3,3] := 4;

    XY_VCR[1,4] := 24;         { Movie 1 }
    XY_VCR[2,4] := 36;
    XY_VCR[3,4] := 40;

    XY_VCR[1,5] := 368;        { Counter 1 }
    XY_VCR[2,5] := 36;
    XY_VCR[3,5] := 4;

    XY_VCR[1,6] := 24;         { Movie 2 }
    XY_VCR[2,6] := 48;
    XY_VCR[3,6] := 40;

    XY_VCR[1,7] := 368;        { Counter 2 }
    XY_VCR[2,7] := 48;
    XY_VCR[3,7] := 4;

    XY_VCR[1,8] := 24;         { Movie 3 }
    XY_VCR[2,8] := 60;
    XY_VCR[3,8] := 40;

    XY_VCR[1,9] := 368;        { Counter 3 }
    XY_VCR[2,9] := 60;
    XY_VCR[3,9] := 4;

    XY_VCR[1,10] := 24;        { Movie 4 }
    XY_VCR[2,10] := 72;
    XY_VCR[3,10] := 40;

    XY_VCR[1,11] := 368;       { Counter 4 }
    XY_VCR[2,11] := 72;
    XY_VCR[3,11] := 4;

    XY_VCR[1,12] := 24;        { Movie 5 }
    XY_VCR[2,12] := 84;
    XY_VCR[3,12] := 40;

    XY_VCR[1,13] := 368;       { Counter 5 }
    XY_VCR[2,13] := 84;
    XY_VCR[3,13] := 4;

    XY_VCR[1,14] := 24;        { Movie 6 }
    XY_VCR[2,14] := 96;
    XY_VCR[3,14] := 40;

    XY_VCR[1,15] := 368;       { Counter 6 }
    XY_VCR[2,15] := 96;
    XY_VCR[3,15] := 4;

   { Tape Number Output }
    XY_VCR[1,17] := 32;
    XY_VCR[2,17] := 12;
    XY_VCR[3,17] := 32;

    XY_VCR[1,18] := 4;
    XY_VCR[2,18] := 23;
    XY_VCR[3,18] := 28;

    XY_VCR[1,19] := 4;
    XY_VCR[2,19] := 31;
    XY_VCR[3,19] := 28;

    XY_VCR[1,20] := 4;
    XY_VCR[2,20] := 39;
    XY_VCR[3,20] := 28;

 end;


 procedure Init_Coor;
  
  begin
    Wind_Coor[1,1] :=  98;                      { Movie Input Screen }
    Wind_Coor[1,2] :=  42 * Resolution;
    Wind_Coor[1,3] := 444;
    Wind_Coor[1,4] := 116 * Resolution;

    Wind_Coor[3,1] := 0;                       { Main Screen }
    Wind_Coor[3,2] := 0;
    Wind_Coor[3,3] := 0;
    Wind_Coor[3,4] := 0;

    Wind_Coor[4,1] :=   6;                      { File Names }
    Wind_Coor[4,2] :=  58 * Resolution;
    Wind_Coor[4,3] := 252;
    Wind_Coor[4,4] :=  72 * Resolution;

    Wind_Coor[5,1] := 500;                      { Tape Numbers }
    Wind_Coor[5,2] :=  24 * Resolution;
    Wind_Coor[5,3] :=  80;
    Wind_Coor[5,4] := 150 * Resolution;

    Wind_Name[1]  := ' VCR Movie File Input ';
    Wind_Name[3]  := ' VCR Tape Organizer ';
    Wind_Name[4]  := ' Movie Titles ';
    Wind_Name[5]  := ' Tape # ';
 end;


 begin
   Set_Mouse(M_Bee);
   With Gem_Result do
         begin
           RL_Button := $01;
           Up_Down   := $01;
           B_Clicks  := $01;
           InBox1    := true;
           X_Pos[1]  := 0;
           Y_Pos[1]  := 0;
           Width[1]  := 640;
           Height[1] := 200;
           InBox2    := true;
           X_Pos[2]  := 0;
           Y_Pos[2]  := 0;
           Width[2]  := 640;
           Height[2] := 200;
           B_Count   := 0;
           B_State   := 0;
           Timing    := 75;
           ExitPrompt:= false;
         end;

    Name_Offset   := 0;
    Tape_Offset   := 0;
    Letter        := -1;
    N_Window      := 0;
    Module        := -10;
    Prev_Module   := -20;
    Field         := 0;
    Letter        := -1;
    VCR_Retrieve  := false;
    Check         := chr($08);
    PathSlash     := chr($5C);
    Slash         := chr($2F);
    Colon         := chr($3A);
    Sp            := chr($20);
    Comma         := chr($2C);
    UnderLine     := chr($5F);

    for i := 0 to 26 do
        VCR_Inverse[i] := false;
    for i := 1 to 60 do
        Input_String[i] := No_Sp;

    for i := 1 to 5 do
        Wind_Handle[i] := -20;

    Rewrite(Printer, 'LST:');
    Init_XYPB;
    Init_Coor;
    Init_Files;
    Set_Mouse(M_Arrow);
 end;
