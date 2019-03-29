{$M+}
{$E+}

program Subroutine_Module;

     {$I A:GEMSUBS.PAS }
     {$I A:AUXSUBS.PAS }

Const
     {$I B:MOD_CONST.PAS }

Type
     {$I B:MOD_TYPE.PAS }

Var
     {$I B:MOD_VAR.PAS }


  procedure EraseCursor(X, Y, WindNo : short_integer ; CurRec : WordPointer) ;

   var
       CursorStr   : String[1] ;
       Len,
       LevelOffset : short_integer ;

     begin
       Hide_Mouse ;
       Paint_Rect(XOffset[WindNo] + X * 8, 
                  YOffset[WindNo] + ((Y * 9) - 7) * Resolution, 
                  8, 9 * Resolution) ;
       if CurRec <> nil then
          Len := Length(CurRec^.NewWord)
       else
          Len := 0 ;
       if X <= Len then
          begin
            if CurRec^.Buffer then
               Text_Style(Thickened) ;
            Draw_String(XOffset[WindNo] +  X * 8, 
                        YOffset[WindNo] + (Y * 9) * Resolution, 
                        Copy(CurRec^.NewWord, X, 1)) ;
            Text_Style(Normal) ;
          end ;
       Show_Mouse ;
     end ;


  procedure NewCursor(XP, Y, WindNo : short_integer ; CurRec : WordPointer) ;

   var
       CursorStr   : String[1] ;
       Len,
       LevelOffset : short_integer ;

     begin
       Hide_Mouse ;
       if N_Window > 0 then
          begin

            if CurRec <> nil then
               LevelOffset := (CurRec^.Level * 3) + 16
            else
               LevelOffset := 16 ;
            XOffset[WindNo] := x + 10 - 
                                   (WindOffset[WindNo] - LevelOffset) * 8 ;
          end ;

       if CurRec <> nil then
          Len := Length(CurRec^.NewWord)
       else
          Len := 0 ;
       if (XP <= Len) AND (Len > 0) then
          begin
            Text_Color(White) ;
            Paint_Color(Black) ;
            Paint_Style(1) ;
            Paint_Rect(XOffset[WindNo] + XP * 8, 
                       YOffset[WindNo] + ((Y * 9) - 7) * Resolution, 
                       8, 9 * Resolution) ;
            Draw_Mode(2) ;
            CursorStr := Copy(CurRec^.NewWord, XP, 1) ;
            if CurRec^.Buffer then
               Text_Style(Thickened) ;
            Draw_String(XOffset[WindNo] + XP * 8, 
                        YOffset[WindNo] + (Y * 9) * Resolution, CursorStr) ;
            Text_Style(Normal) ;
            Text_Color(Black) ;
            Paint_Color(White) ;
            Draw_Mode(1) ;
          end
       else
          Draw_String(XOffset[WindNo] + XP * 8, 
                      YOffset[WindNo] + (Y * 9) * Resolution, '_') ;
       Show_Mouse ;
     end ;

  procedure Draw_VSlide(Wind : short_integer);

   var
       Dummy,
       VSlide_Size,
       VSlide_Pos  : short_integer ;
       L_Offset,
       L_SlidePos,
       L_I         : long_integer;

   begin
     Work_Rect(WindHandle[Wind],x,y,w,h);
     if TotalRec[Wind] <= h DIV (9 * Resolution) then
        begin
          VSlide_Size := 1000;
          L_SlidePos  := 1;
        end
     else
        begin
          VSlide_Size := 
                     (1000 * (h DIV (9 * Resolution))) DIV TotalRec[Wind];
          L_I := 1 ;
          L_Offset := VertOffset[Wind] * L_I ;
          L_SlidePos := (L_Offset * 1000) DIV 
                        (TotalRec[Wind] - (h DIV (9 * Resolution)));
        end;

     Wind_Set(WindHandle[Wind], WF_VSlSize, VSlide_Size,Dummy,Dummy,Dummy);
     VSlide_Pos := int(L_SlidePos);

     if VSlide_Pos < 1 then VSlide_Pos := 1;
     Wind_Set(WindHandle[Wind], WF_VSlide, VSlide_Pos, Dummy, Dummy, Dummy)
   end;


  procedure Draw_HSlide(Wind : short_integer);

   const
       MaxWidth = 130 ;

   var
       Dummy,
       HSlide_Size,
       HSlide_Pos   : short_integer ;
       L_Offset,
       L_SlidePos,
       L_SlideSize,
       L_I          : long_integer;

   begin
     Work_Rect(WindHandle[Wind],x,y,w,h);

     L_I := 1;
     L_Offset := w DIV (8 * L_I);
     L_SlideSize := (1000 * L_Offset) DIV  MaxWidth;

     L_Offset := WindOffset[Wind] * L_I;
     L_SlidePos := (L_Offset * 1000) DIV 
                   (MaxWidth - (w DIV 8));

     HSlide_Pos := int(L_SlidePos);
     HSlide_Size := int(L_SlideSize);

     Wind_Set(WindHandle[Wind], WF_HSlSize, HSlide_Size,Dummy,Dummy,Dummy);

     if HSlide_Pos < 1 then HSlide_Pos := 1;
     Wind_Set(WindHandle[Wind], WF_HSlide, HSlide_Pos, Dummy, Dummy, Dummy)
   end;


  procedure SlashMod(     Value, Divisor : short_integer ;
                      Var Result, Remainder : short_integer ) ;

    begin
      Result    := Value DIV Divisor;
      Remainder := Value MOD Divisor;
    end;

    
  procedure ToRoman( IntNumber : short_integer ; Var RomanNum : Str255 ) ;

   var
       i,
       Cs, 
       Rem : integer;
       StrTable : array[1..4,0..9] of string;
  
    begin
      StrTable[1,0]  := '';
      StrTable[1,1]  := 'I';
      StrTable[1,2]  := 'II';
      StrTable[1,3]  := 'III';
      StrTable[1,4]  := 'IV';
      StrTable[1,5]  := 'V';
      StrTable[1,6]  := 'VI';
      StrTable[1,7]  := 'VII';
      StrTable[1,8]  := 'VIII';
      StrTable[1,9]  := 'IX';
      
      StrTable[2,0]  := '';
      StrTable[2,1]  := 'X';
      StrTable[2,2]  := 'XX';
      StrTable[2,3]  := 'XXX';
      StrTable[2,4]  := 'XL';
      StrTable[2,5]  := 'L';
      StrTable[2,6]  := 'LX';
      StrTable[2,7]  := 'LXX';
      StrTable[2,8]  := 'LXXX';
      StrTable[2,9]  := 'XC';
      
      StrTable[3,0]  := '';
      StrTable[3,1]  := 'C';
      StrTable[3,2]  := 'CC';
      StrTable[3,3]  := 'CCC';
      StrTable[3,4]  := 'CD';
      StrTable[3,5]  := 'D';
      StrTable[3,6]  := 'DC';
      StrTable[3,7]  := 'DCC';
      StrTable[3,8]  := 'DCCC';
      StrTable[3,9]  := 'CM';

      StrTable[4,0]  := '';
      StrTable[4,1]  := 'M';
      StrTable[4,2]  := 'MM';
      StrTable[4,3]  := 'MMM';

      SlashMod(IntNumber, 1000, Cs, Rem) ;
      RomanNum := StrTable[4,Cs] ;
      
      IntNumber := Rem ;
      SlashMod(IntNumber, 100, Cs, Rem) ;
      RomanNum := Concat(RomanNum, StrTable[3,Cs]) ;
      
      IntNumber := Rem ;
      SlashMod(IntNumber, 10, Cs, Rem) ;
      RomanNum := Concat(RomanNum, StrTable[2,Cs], StrTable[1,Rem]) ;
    end;


  procedure ToLetter(IntNumber, Start : short_integer ; Var Letter : Str255);    

   var
       Result,
       Remainder : short_integer;

    begin
      Letter := NoSp;
   
      Repeat
        SlashMod(IntNumber, 26, Result, Remainder);
        if Remainder > 0 then
           Letter := Concat(chr(Remainder + Start), Letter)
        else
           begin
             Letter := Concat(chr(26 + Start), Letter);
             if Result > 0 then Result := Result - 1;
           end;
        IntNumber := Result;
      Until IntNumber < 1;
      
    end;

  procedure LevelConvert(CurRec : WordPointer ; Var S : Str255);

    var
        Result    : Str255;

     begin
       case CurRec^.Level of
           0 : ToRoman( CurRec^.PtLabel, Result ) ;
           1 : ToLetter(CurRec^.PtLabel, $40, Result);
           2 : WriteV(Result, CurRec^.PtLabel) ;
           3 : ToLetter(CurRec^.PtLabel, $60, Result );
           4 : begin
                 WriteV(Result,CurRec^.PtLabel);
                 Result := Concat('(', Result);
               end;
           5 : begin
                 ToLetter(CurRec^.PtLabel, $60, Result);
                 Result := Concat('(',Result);
               end;
       end;
       
       if CurRec^.Level < 4 then
          S := Concat(Result, '. ')
       else
          S := Concat(Result, ') ');
     end;

  procedure SetPtLabel( WindNo : short_integer );

    var
        i,
        CurLevel  : short_integer ;
        CurRec    : WordPointer ;
        NextLevel : array[0..5] of short_integer ;

     begin
       CurRec := FirstRec[WindNo];
       for i := 0 to 5 do
           NextLevel[i] := 1;

       While CurRec <> nil do
          begin
            CurLevel := CurRec^.Level ;
            CurRec^.PtLabel := NextLevel[CurLevel];
            NextLevel[CurLevel] := NextLevel[CurLevel] + 1;
            for i := CurLevel + 1 to 5 do
                NextLevel[i] := 1;
            CurRec := CurRec^.Next ;
          end;
     end;


BEGIN
END.
