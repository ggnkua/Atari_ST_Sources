{$M+}
{$E+}

program Main_Module;

{$I A:GEMSUBS.PAS }
{$I A:AUXSUBS.PAS }

Const
     {$I B:VCR_Cnst.Pas }

Type
     {$I B:VCR_Type.Pas }

Var
     {$I B:VCR_Var.Pas }


 procedure Paint_Frame( x, y, w, h, color, pattern : integer ) ;
    External ;

 procedure Text_Box(X, Y, Z : integer ; S : string) ;
    External ;

 procedure DateStr( Out_No : integer ; Var S : string );
    External ;

 procedure Get_TapeNo;
    External ;

 procedure Get_MovieRec( Letter : integer );
    External ;


 procedure Draw_Card(X, Y, Z : integer) ;

  var
      c : char;

  begin
    Paint_Frame(X + 6, Y * Resolution, 252 + $41 - Z,
                72 * Resolution + $41 - Z, White, 0);

    if Z <> $40 then       
       begin
         Paint_Frame(X + (Z - $40) * 8, (Y - 9) * Resolution,
                    16, 10 * Resolution, White, 0);
         if Z = $5B then
            c := chr($2A)
         else
            c := chr(Z);
         Draw_String(X + (Z - $3F) * 8 - 4, (Y - 1) * Resolution, c);
       end;
  end;


 procedure Draw_Main;

  var
     i : integer;
     c : char;

  begin
    Work_Rect(Wind_Handle[3],x0,y0,w0,h0);
    Paint_Color(White);
    Paint_Rect(0, 0, 640, 200 * Resolution);
    Paint_Color(Black);
    Paint_Style(4);
    Paint_Rect(0, 0, 640, 200 * Resolution);
    Paint_Style(1);
    for i := -1 to 26 do
        Draw_Card(130 - (i * 5), 32 + (i * 1), $5A - i);
    for i := 0 to 26 do
        if VCR_Inverse[i] then
           begin
             if i = 26 then
                c := chr($2A)
             else
                c := chr($41 + i);
             Text_Style($02);
             Draw_String(342 - 13 * (25 - i), (56 - i) * Resolution, c);
             Text_Style($00);
           end;
  end;


 procedure Draw_Movie;

  var
     i : integer;

  begin
    Work_Rect(Wind_Handle[1], x0, y0, w0, h0);
    Paint_Frame(x0, y0, w0, h0, White,1);
    Paint_Frame(x0, y0, w0, h0, Black,6);

    Text_Box(x0 +  20, y0 +  4 * Resolution,  6, 'Tape #');
    Text_Box(x0 + 192, y0 +  4 * Resolution,  5, 'Hi-Fi');
    Text_Box(x0 + 320, y0 +  4 * Resolution,  6, 'Stereo');

    Text_Box(x0 + 60,  y0 + 16 * Resolution, 13, ' Movie Title ');
    Text_Box(x0 + 364, y0 + 16 * Resolution, 5, 'Index');

    for i := 1 to 6 do
        begin
          Paint_Frame(x0 + 4, y0 + (16 + 12 * i) * Resolution,
                      14, 10 * Resolution, White, 1);
          Draw_String(x0 + 7, y0 + (24 + 12 * i) * Resolution,
                      chr(i + $30));
        end;

    for i := 1 to 15 do
        Paint_Frame(x0 + XY_VCR[1,i] - 4, y0 + (XY_VCR[2,i] - 8) * Resolution,
                    (XY_VCR[3,i] + 2) * 8, 10 * Resolution, White, 1);

    for i := 1 to 15 do
        Draw_String(x0 + XY_VCR[1,i],y0 + XY_VCR[2,i] * Resolution,
                    Input_String[i]);

  end;


 procedure Draw_Names;

  var
      i,
      End_Name : integer;

   begin
     Hide_Mouse;
     Work_Rect(Wind_Handle[4], x0, y0, w0, h0);
     Set_Clip(x0,y0,w0,h0);
     Paint_Color(White);
     Text_Color(Black);
     Draw_Mode(1);

     Paint_Rect(x0, y0, w0, h0);

     End_Name := Name_Offset + 5;
     if End_Name > Dsply_Name then
        End_Name := Dsply_Name;

     for i := Name_Offset + 1 to End_Name do
         Draw_String(x0 + 12, y0 + (9 * (i - Name_Offset)) * Resolution,
                     VCR_Name[Output_Name[i]]);
     Show_Mouse;
   end;


 procedure Draw_Numbers;

  var
      i,
      End_Tape      : integer ;
      Output_String : String ;

   begin
     Hide_Mouse;
     Work_Rect(Wind_Handle[5], x0, y0, w0, h0);
     Paint_Color(White);
     Text_Color(Black);
     Draw_Mode(1);

     Paint_Rect(x0, y0, w0, h0);

     End_Tape := Tape_Offset + 15;
     if End_Tape > Dsply_Tape then
        End_Tape := Dsply_Tape;

     for i := Tape_Offset + 1 to End_Tape do
         begin
           DateStr(VCR_Tape[0,Output_Tape[i]], Output_String);
           Draw_String(x0 + 12, y0 + (9 * (i - Tape_Offset)) * Resolution,
                       Output_String);
         end;
     Show_Mouse;
   end;


  procedure Select_Window(Wind_Number : integer);

    var
        i : integer;

    begin
      Set_Clip(x0, y0, w0, h0);
      for i := 1 to 5 do
          if Wind_Number = Wind_Handle[i] then
             case i of
                1 : Draw_Movie;
                3 : Draw_Main;
                4 : Get_MovieRec(Letter);
                5 : Get_TapeNo;
             end;
    end;


 procedure Do_Redraw;

  var
     i : integer;

  begin
    Begin_Update;
    Hide_Mouse;

    With Gem_Result do
    begin
      First_Rect(msg[3], x0, y0, w0, h0);
      while (w0 <> 0) OR (h0 <>0) do
          begin
            if Rect_Intersect(msg[4], msg[5], msg[6], msg[7],
                              x0, y0, w0, h0) then
               Select_Window(msg[3]);
            Next_Rect(msg[3], x0, y0, w0, h0);
          end;
    end;
    Prev_Module := -20;
    Show_Mouse;
    End_Update;
  end;

BEGIN
END.
