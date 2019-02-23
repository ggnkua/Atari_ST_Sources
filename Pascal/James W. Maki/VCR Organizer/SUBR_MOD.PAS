{$M+}
{$E+}

program Module_2;

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

  Const
       {$I B:VCR_Cnst.Pas }

  Type
       {$I B:VCR_Type.Pas }


  Var
       {$I B:VCR_Var.Pas }


{ -- No External Procedures -- }


  procedure WSlide_Size(Max_Scr, Total_Dsply, Wind_Number : integer);

     begin
       if Total_Dsply <= Max_Scr then Slide_Size := 1000
       else
          Slide_Size := (1000 * Max_Scr) DIV Total_Dsply;
       Wind_Set(Wind_Handle[Wind_Number], WF_VSlSize, Slide_Size, Dummy,
                Dummy, Dummy);
     end;


  procedure Paint_Frame( x, y, w, h, color, pattern : integer ) ;

   begin
     Draw_Mode(1);
     Paint_Color(color);
     Paint_Style(pattern);
     Paint_Rect(x, y, w, h);
     Frame_Rect(x, y, w, h);
   end;


  procedure Empty_Line(X, Y, Z : integer);

   var
       i : integer;

   begin
     for i := 0 to Z - 1 do
         Draw_String(X + 8 * i, Y, Sp);
   end;


  procedure Trail_Sp( Var S : Name ) ;

    var
        Last_Char : string;

    begin
      repeat
        Len := Length(S);                 { Remove trailing spaces }
        if Len > 0 then
           Last_Char := Copy(S, Len, 1);
        if Last_Char = Sp then
           Delete(S, Len, 1);
      until Last_Char <> Sp;
    end;


procedure DateStr(Input_Integer : integer; Var Output_String : string);

 Var
         First_Number : integer;
         Input_Save   : integer;
         First_Char   : char;

 begin
   Input_Save := Input_Integer;
   First_Number := 0;
   Output_String := No_Sp;

   if Input_Integer > 999 then
      begin
        First_Number := Input_Integer DIV 1000;
        First_Char   := Chr(First_Number + $30);
        Output_String := Concat(Output_String, First_Char);
        Input_Integer := Input_Integer - (First_Number * 1000);
     end
   else
      if Input_Save > 999 then
         Output_String := Concat(Output_String,'0')
      else
         Output_String := Concat(Output_String,' ');


   if Input_Integer > 99 then
      begin
        First_Number := Input_Integer DIV 100;
        First_Char   := Chr(First_Number + $30);
        Output_String := Concat(Output_String, First_Char);
        Input_Integer := Input_Integer - (First_Number * 100);
      end
   else
      if Input_Save > 99 then
         Output_String := Concat(Output_String,'0')
      else
         Output_String := Concat(Output_String,' ');

   if Input_Integer > 9 then
      begin
        First_Number := Input_Integer DIV 10;
        First_Char   := Chr(First_Number + $30);
        Output_String := Concat(Output_String, First_Char);
        Input_Integer := Input_Integer - (First_Number * 10);
      end
   else
       if Input_Save > 9 then
          Output_String := Concat(Output_String,'0')
       else
          Output_String := Concat(Output_String,' ');


   First_Char  := Chr(Input_Integer + $30);
   Output_String := Concat(Output_String, First_Char);

 end;


 procedure Text_Box(X, Y, Z : integer ; S : string) ;

  var
    Len : integer;

  begin
    Len := Length(S);
    if S = Sp then
       Z := Z + 1
    else
       Z := Len + 1;
    Paint_Frame(X, Y, Z * 8, 10 * Resolution, White, 0);
    Draw_String(X + 4, Y + 8 * Resolution, S);
  end;



 procedure Erase_Cursor;

  var
     Len : integer;

  begin
    if (Module = Wind_Handle[1]) AND (Field > 0) then
        begin
          Len := Length(Input_String[Field]);
          Hide_Mouse;
          Draw_String(x0 + XY_VCR[1,Field] + 8 * Len,
                      y0 + XY_VCR[2,Field] * Resolution, Sp);
          Show_Mouse;
        end;
  end;


 procedure New_Cursor;

  var
     Len : integer;

   begin
     if (Module = Wind_Handle[1]) AND (Field > 0) then
        begin
          Hide_Mouse;
          Len := Length(Input_String[Field]);
          X_Cursor := x0 + XY_VCR[1,Field] + 8 * Len;
          Y_Cursor := y0 + XY_VCR[2,Field] * Resolution;
          Draw_String(X_Cursor, Y_Cursor, UnderLine);
          Show_Mouse;
        end;
   end;


procedure Val(S: String; Var Result : integer; Var Error  : Boolean);

var
     Space_Pos  : string[1];
     Len        : integer;
     S_Result   : String[1];
     LI_Result  : integer;
     Multiplier : integer;
     i, j       : integer;
     minus      : Boolean;
     Minus_Pos  : integer;
     Size_Check : string[1];
     Space      : string;


begin
     Minus_Pos := Pos(Chr($2D), S);
     if Minus_Pos > 0 then
        begin
          Delete(S, Minus_Pos, 1);
          Minus := True;
        end
     else
        Minus := False;

     repeat
       Len := Length(S);
       if Len > 0 then
          begin
            Space := Copy(S,1,1);
            if Space = Sp then
               Delete(S,1,1);
          end;
     Until Space <> Sp;

     Len := Length(S);
     if Len > 0 then
        begin
          Size_Check := Copy(S, 1, 1);
          if (Len < 5) OR ((Len = 5) AND ((Size_Check = '1')
                                      OR (Size_Check = '2'))) then
                Error := False
          else
             Error := True;

          Result := 0;
          for i := 1 to Len do
          if NOT (Error) then
            begin
               S_Result := Copy(S,1,1);
               Delete(S,1,1);
                if S_Result = '0' then LI_Result := 0
                else
                  if S_Result = '1' then LI_Result := 1
                 else
                    if S_Result = '2' then LI_Result := 2
                    else
                      if S_Result = '3' then LI_Result := 3
                      else
                        if S_Result = '4' then LI_Result := 4
                        else
                          if S_Result = '5' then LI_Result := 5
                          else
                            if S_Result = '6' then LI_Result := 6
                            else
                              if S_Result = '7' then LI_Result := 7
                              else
                                if S_Result = '8' then LI_Result := 8
                                else
                                  if S_Result = '9' then LI_Result := 9
                                  else
                                    Error := True;
               if NOT (Error) then
                 begin
                    Multiplier := 1;
                    for j := 1 to Len - i do
                        Multiplier := Multiplier * 10;
                    LI_Result := Multiplier * LI_Result;
                    Result := Result + LI_Result;
                 end;
            end;
          if Minus then Result := Result * (-1);
        end;
end;


BEGIN
END.
