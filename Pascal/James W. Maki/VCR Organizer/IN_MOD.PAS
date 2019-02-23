{$M+}
{$E+}

program Input_Module;

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

  Const
       {$I B:VCR_Cnst.Pas }

  Type
       {$I B:VCR_Type.Pas }

  Var
       {$I B:VCR_Var.Pas }


  procedure Empty_Line(X, Y, Z : integer);
     External ;

  procedure Ret_Record;
     External ;

  procedure Ret_Tape;
     External ;

  procedure New_Cursor;
     External ;

  procedure Erase_Cursor;
     External ;

  procedure LetterSelect(i : integer);
     External ;

  procedure SelectSave ;
     External ;


 procedure Keyboard_Input;

  var
     i : integer ;

  begin
    if Module = Wind_Handle[1] then
        begin
          Hide_Mouse;
          Len := Length(Input_String[Field]);
          X_Cursor := x0 + XY_VCR[1,Field] + 8 * Len;
          Y_Cursor := y0 + XY_VCR[2,Field] * Resolution;

          if (Gem_Result.LoByte = $13) AND        { ^S -- Save }
             (Gem_Result.HiByte = $1F) then
             SelectSave ;

          if (Gem_Result.LoByte > $1F) AND        { Printable Characters }
             (Gem_Result.LoByte < $7F) then
             begin
               if Len < XY_VCR[3,Field] then
                  begin
                    Draw_String(X_Cursor, Y_Cursor, Gem_Result.character);
                    Input_String[Field] := Concat(Input_String[Field],
                                                  Gem_Result.character);
                    X_Cursor := X_Cursor + 8;
                end
             end
          else

             if (Gem_Result.LoByte = $7F) OR      { Delete or Backspace }
                (Gem_Result.LoByte = $08) then
                begin
                  if Len > 0 then
                     begin
                       Empty_Line(X_Cursor - 8, Y_Cursor, 2);
                       Delete(Input_String[Field], Len, 1);
                       X_Cursor := X_Cursor - 8;
                     end;
                end
             else

                if (Gem_Result.LoByte = $0D) OR          { Return }
                   ((Gem_Result.LoByte = 0) AND          { Down Arrow }
                    (Gem_Result.HiByte = $50)) OR  
                   ((Gem_Result.LoByte = $09) AND        {  TAB  }
                    (Gem_Result.HiByte = $0F))   then
                   begin
                     Erase_Cursor;
                     Field := Field + 1;
                     if Module = Wind_Handle[1] then
                        if Field > 15 then Field := 3;
                     New_Cursor;
                   end
                else

                   if ((Gem_Result.LoByte = 0) AND       { Up Arrow }
                       (Gem_Result.HiByte = $48)) then
                       begin
                         Erase_Cursor;
                         Field := Field - 1;
                         if Module = Wind_Handle[1] then
                            if Field <  3 then Field := 15;
                         New_Cursor;
                       end
                   else

                      if (Gem_Result.LoByte = $1B) AND    { ESC -- Clear Line }
                         (Gem_Result.HiByte = $01) then
                           if Len > 0 then
                              begin
                                Erase_Cursor;
                                for i := 1 to Len do
                                    Draw_String(x0 + XY_VCR[1,Field] + 8 * i,
                                        y0 + XY_VCR[2,Field] * Resolution, Sp);
                                Input_String[Field] := No_Sp;
                                X_Cursor := x0 + XY_VCR[1,Field];
                              end;

          if NOT (Gem_Result.LoByte = $13) AND        { ^S -- Save }
             NOT (Gem_Result.HiByte = $1F) then
             Draw_String(X_Cursor, Y_Cursor, UnderLine);
          Show_Mouse;
        end;
  end;


  procedure MB_Main;

   var
       i : integer;

    begin
      with Gem_Result do
           begin
             for i := 0 to 26 do
                 if (X_Mouse > 16 + i * 13) AND (X_Mouse < 27 + i * 13) AND
                    (Y_Mouse > (48 - i) * Resolution) AND
                    (Y_Mouse < (57 - i) * Resolution) then
                       begin
                         Letter := i;
                         LetterSelect(i);
                       end;
           end;
    end;


 procedure MB_Movie;

  var
      c : char;

  begin
    with Gem_Result do
       begin
         if (Y_Mouse > y0 +  4 * Resolution) AND
            (Y_Mouse < y0 + 14 * Resolution) then
            begin
              if (X_Mouse > x0 + 192) AND (X_Mouse < x0 + 264) then
                 begin
                   if VCR_Check[1,Tape_Current] then
                      begin
                        VCR_Check[1,Tape_Current] := false;
                        Input_String[1] := chr($20);
                      end
                   else
                      begin
                        VCR_Check[1,Tape_Current] := true;
                        Input_String[1] := chr($08);
                      end;
                   Hide_Mouse;
                   Draw_String(x0 + XY_VCR[1,1],
                               y0 + XY_VCR[2,1] * Resolution, Input_String[1]);
                   Show_Mouse;
                 end
              else
                 if (X_Mouse > x0 + 320) AND (X_Mouse < x0 + 412) then
                     begin
                       if VCR_Check[2,Tape_Current] then
                          begin
                            VCR_Check[2,Tape_Current] := false;
                            Input_String[2] := chr($20);
                          end
                       else
                          begin
                            VCR_Check[2,Tape_Current] := true;
                            Input_String[2] := chr($08);
                          end;
                       Hide_Mouse;
                       Draw_String(x0 + XY_VCR[1,2],
                                   y0 + XY_VCR[2,2] * Resolution,
                                   Input_String[2]);
                       Show_Mouse;
                     end;
            end;
       end;
  end;


 procedure MB_Input;

   var
       Rec_Name : integer;

  begin
    if Module = Wind_Handle[1] then
       MB_Movie
    else
       if Module = Wind_Handle[2] then
       else
          if Module = Wind_Handle[3] then
             MB_Main
          else
             if Module = Wind_Handle[4] then
                Ret_Record
             else
                if Module = Wind_Handle[5] then
                   Ret_Tape;
  end;


BEGIN
END.
