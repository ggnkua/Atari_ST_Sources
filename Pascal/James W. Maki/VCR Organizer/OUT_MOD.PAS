{$M+}
{$E+}

program Output_Module;

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

  Const
       {$I B:VCR_Cnst.Pas }

  Type
       {$I B:VCR_Type.Pas }

  Var
       {$I B:VCR_Var.Pas }


  procedure DateStr( Tape_No : integer ; Var Str : string);
     External ;


 procedure Alert_Box( L1, L2, L3, L4, L5 : integer ;
                      S1, S2, S3 : string ; n : integer ;
                     var Result : integer ) ;
     
   var
       i          : integer;
       IndexArray : array[1..5] of integer;
       OutStr     : array[0..9] of string;
       OutLine    : Str255;
       InStr      : array[1..3] of string;
       

   begin
     OutStr[0] := ' ';

     OutStr[1] := '  This Program   ';
     OutStr[2] := '  Will NOT Work  '; 
     OutStr[3] := ' in Low_Res Mode ';

     OutStr[4] := 'Max Number of Entries';
     OutStr[5] := '(740 Entries Allowed)';

     OutStr[6] := '   Must Close A Window   ';
     OutStr[7] := '       To Continue';
     OutStr[8] := 'Limit of Six Open Windows';

     OutStr[9] := ' Error In File Access ';

     IndexArray[1] := L1;
     IndexArray[2] := L2;
     IndexArray[3] := L3;
     IndexArray[4] := L4;
     IndexArray[5] := L5;

     InStr[1] := S1;
     InStr[2] := S2;
     InStr[3] := S3;

     OutLine := '[1][ ';
     for i := 1 to 4 do
         OutLine := Concat(OutLine, OutStr[IndexArray[i]], ' | ');
     OutLine := Concat(OutLine, OutStr[IndexArray[5]],' ][ ', InStr[1]);

     Len := Length(InStr[2]);
     if Len > 0 then
        begin
          OutLine := Concat(OutLine, ' | ', InStr[2]);
          Len := Length(InStr[3]);
          if Len > 0 then
             OutLine := Concat(OutLine, ' | ', InStr[3]);
        end;

     OutLine := Concat(OutLine, ' ]');
     Result := Do_Alert(OutLine, n);
    end;


  procedure Print_Contents;

    var
       i, j,
       Next_Rec,
       Page,
       Line_No,
       Len       : integer ;
       Letter    : boolean ;

     procedure Top_Margin;

       var
          i : integer;

        begin
          Writeln(Printer);
          Writeln(Printer);
          Writeln(Printer, 'Movie':20, 'Tape #':41, 'Index':8);
          for i := 1 to 10 do
              Write(Printer, Sp);
          for i := 1 to 59 do
              Write(Printer, '=');
          Writeln(Printer);
          Writeln(Printer);
          Line_No := 1;
        end;

     procedure Bottom_Margin;

       var
           i : integer;

        begin
          Writeln(Printer);
          for i := 1 to 10 do
              Write(Printer, Sp);
          for i := 1 to 59 do
              Write(Printer, '=');
          Writeln(Printer);
          Writeln(Printer);
          Writeln(Printer, 'Page ':42, Page);
          Writeln(Printer);
          Writeln(Printer);
        end;

     procedure Check_Line;

        begin
          if Line_No > 55 then
             begin
               Bottom_Margin;
               Line_No := 0;
               Page := Page + 1;
             end;
        end;


    begin
      Line_No := 0;
      Page    := 1;

      for i := 0 to 26 do
          begin
            Letter := false;
            Next_Rec := VCR_Point[1,i];
            While Next_Rec <> 0 do
                  begin
                    Letter := true;
                    if Line_No = 0 then Top_Margin;
                    for j := 1 to 10 do
                        Write(Printer, Sp);
                    Write(Printer, VCR_Name[Next_Rec]);
                    Len := Length(VCR_Name[Next_Rec]);
                    Write(Printer,Sp, Sp);
                    for j := Len to 40 do
                        Write(Printer, '-');
                    Write(Printer, VCR_Tape[0,VCR_TapeNo[Next_Rec]]:6);
                    Writeln(Printer, VCR_Count[Next_Rec]:8);
                    Line_No := Line_No + 1;
                    Check_Line;
                    Next_Rec := VCR_Next[1,Next_Rec];
                  end;
            if Letter then
               begin
                 Writeln(Printer);
                 Check_Line;
                 if Line_No = 0 then
                    Top_Margin
                 else
                    Line_No := Line_No + 1;
                 Check_Line;
               end;
          end;
      for i := Line_No to 55 do
          Writeln(Printer);
      Bottom_Margin;
    end;


  procedure Print_VCR( Cur_Rec : integer ) ;

    var
        i, j,
        Len       : integer;
        PrintStr  : array[1..15] of string;
        Tape_No   : integer;

    begin
      Tape_No := Cur_Rec;

      PrintStr[8] := '';

      if VCR_Check[1,Tape_No] then
         PrintStr[8] := Concat(PrintStr[8],'Hi Fi ');

      if VCR_Check[2,Tape_No] then
         PrintStr[8] := Concat(PrintStr[8],' Stereo ');

      DateStr(VCR_Tape[0,Tape_No], PrintStr[1]);
      Len := Length(PrintStr[1]);
      if Len < 5 then
         for j := 1 to 5 - Len do
             PrintStr[1] := Concat(Sp, PrintStr[1]);


      PrintStr[2] := VCR_Name[VCR_Tape[1,Tape_No]];
      DateStr(VCR_Count[VCR_Tape[1,Tape_No]], PrintStr[9]);

      PrintStr[3] := VCR_Name[VCR_Tape[2,Tape_No]];
      DateStr(VCR_Count[VCR_Tape[2,Tape_No]], PrintStr[10]);

      PrintStr[4] := VCR_Name[VCR_Tape[3,Tape_No]];
      DateStr(VCR_Count[VCR_Tape[3,Tape_No]], PrintStr[11]);

      PrintStr[5] := VCR_Name[VCR_Tape[4,Tape_No]];
      DateStr(VCR_Count[VCR_Tape[4,Tape_No]],PrintStr[12]);

      PrintStr[6] := VCR_Name[VCR_Tape[5,Tape_No]];
      DateStr(VCR_Count[VCR_Tape[5,Tape_No]],PrintStr[13]);

      PrintStr[7] := VCR_Name[VCR_Tape[6,Tape_No]];
      DateStr(VCR_Count[VCR_Tape[6,Tape_No]],PrintStr[14]);


      for i := 2 to 7 do
          begin
            Len := Length(PrintStr[i]);
            if Len > 25 then
               PrintStr[i] := Copy(PrintStr[i],1,25);
          end;

      for i := 9 to 14 do
          begin
            Len := Length(PrintStr[i]);
            if Len < 5 then
               for j := 1 to 5 - Len do
                   PrintStr[i] := Concat(Sp, PrintStr[i]);
            Len := Length(PrintStr[i - 7]);
            if (PrintStr[i] = '    0') AND (Len = 0) then
               PrintStr[i] := '     ';
          end;

      Writeln(Printer, '  Tape #', PrintStr[1], Sp, Sp, PrintStr[8]);
      for i := 2 to 4 do
          Writeln(Printer, PrintStr[i + 7], Sp, PrintStr[i]);
      Writeln(Printer);
      Writeln(Printer);

      Len := Length(PrintStr[5]);
      if Len > 0 then
         begin
           Writeln(Printer);
           for i := 5 to 7 do
               Writeln(Printer, PrintStr[i + 7], Sp, PrintStr[i]);
           Writeln(Printer);
           Writeln(Printer);
         end;
    end;


  procedure Multi_PrtVCR;

    var
       i,
       Next_Rec  : integer ;

    begin
      if VCR_Retrieve then
         Print_VCR(VCR_TapeNo[Name_Select])
      else
         begin
           Next_Rec := VCR_Order[1,0];
           while Next_Rec <> 0 do
                 begin
                   Print_VCR(Next_Rec);
                   Next_Rec := VCR_Order[1,Next_Rec];
                 end;
         end;
    end;


BEGIN
END.
