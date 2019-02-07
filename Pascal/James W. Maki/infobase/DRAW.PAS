{InfoBaseST by James W. Maki (c) Copyright 1990 by Antic Publishing, Inc.}
{$M+}
{$E+}

Program Draw_Module;

      {$I A:GEMSUBS.PAS }
      {$I A:AUXSUBS.PAS }

 Const
      {$I B:MOD_CONS.PAS }

 Type
      {$I B:MOD_TYPE.PAS }

 Var
      {$I B:MOD_VAR.PAS }

{   **************************  External ******************************   }

  procedure GetStr(CurRec : DataPtr ; Var DisplayStr : Str255 ;
                   Start, Size : short_integer ) ;
     External ;

  procedure NewCursor(ScrMode : short_integer) ;
     External ;

{   *************************  Procedures *****************************   }

{ ************************************************************************
     Erase_Frame will erase an input frame and contents by drawing a 
     rectangle of color white with width w and height of 11 at 
     location x and y.
************************************************************************* }
  procedure Erase_Frame( x, y, w : short_integer ) ;

     begin                       { 19 }
       Paint_Rect(x - 1, y - 1, w + 11, 12 * Resolution);
     end;

{ *************************************************************************
     EraseARec will erase a Input Label and Input rectangle for
     the ScrPtr record CurRec.  This is used for the modify procedure
     of the design procedure to erase the record before the modified
     record is drawn.
************************************************************************* }
  procedure EraseARec( CurRec : ScrPtr ) ;

     begin
       Hide_Mouse ;
       Erase_Frame(x +  CurRec^.X * 8, 
                   y + (CurRec^.Y - 1) * Spacing + (4 * Resolution), 
                   (Length(CurRec^.LabelStr) + 2) * 8 ) ;
       Erase_Frame(x + (CurRec^.X + Length(CurRec^.LabelStr) + 2) * 8 + 4, 
                   y + (CurRec^.Y - 1) * Spacing + (4 * Resolution), 
                   CurRec^.Size * 8 ) ;
       if CurRec^.DataType = 'H' then
          EraseARec(CurRec^.Next) ;
       Show_Mouse ;
     end ;

{ *************************************************************************
     Paint_Frame draws a white rectangle at location x,y and width w.  The
     height of the rectangle is always 10.
************************************************************************* }
  procedure Paint_Frame( x, y, w : short_integer ) ;

     begin
       if Resolution = 1 then
          begin             { 16 / 18 }
            Paint_Rect(x, y, w +  8, 10) ;
            Frame_Rect(x, y, w + 10, 11) ;
          end
       else
          begin              { 16 / 16 / 18 }
            Paint_Rect(x, y + 1, w +  8, 20) ;
            Frame_Rect(x, y + 1, w +  8, 20) ;
            Frame_Rect(x - 1, y, w + 10, 22) ;
          end ;
     end ;

{ *************************************************************************
     DrawRecord displays the information about the current record
     to the screen.  The labels are not drawn.
************************************************************************* }
  procedure DrawRecord(CurRec : DataPtr) ;

    var
       ScrRec  : ScrPtr ;
       DisplayStr : Str255 ;

      begin
       Hide_Mouse ;
       ScrRec := S_FirstRec[ScrNum] ;
       While ScrRec <> nil do
         begin
           if CurRec = nil then
              DisplayStr := ''
           else
              GetStr(CurRec, DisplayStr, ScrRec^.Offset, ScrRec^.Size ) ;

           Paint_Frame(x + (ScrRec^.X + Length(ScrRec^.LabelStr) + 2) * 8 + 4, 
                       y + (ScrRec^.Y - 1) * Spacing + (4 * Resolution), 
                       ScrRec^.Size * 8 ) ;
           Draw_String(x + ScrRec^.XPos * 8,
                       y + ScrRec^.YPos * Spacing, DisplayStr) ;
           ScrRec := ScrRec^.Next ;
         end ;
      Show_Mouse ;
     end ;

{ *************************************************************************
     ClearRecord clears all fields of the current record screen.
************************************************************************* }
  procedure ClearRecord(CurRec : DataPtr) ;

    var
       ScrRec  : ScrPtr ;
       DisplayStr : Str255 ;
        
     begin
       Hide_Mouse ;
       ScrRec := S_FirstRec[ScrNum] ;
       While ScrRec <> nil do
         begin
           Paint_Frame(x + (ScrRec^.X + Length(ScrRec^.LabelStr) + 2) * 8 + 4, 
                       y + (ScrRec^.Y - 1) * Spacing + (4 * Resolution), 
                       ScrRec^.Size * 8 ) ;
           if ScrRec^.DataType = 'F' then
              Draw_String(x + ScrRec^.XPos * 8,
                          y + ScrRec^.YPos * Spacing, '$') ;

           ScrRec := ScrRec^.Next ;
         end ;
       S_CurrentRec[ScrNum] := S_FirstRec[ScrNum] ;
       S_CurrentRec[ScrNum]^.XInPos := 0 ;
       XCur := S_CurrentRec[ScrNum]^.XPos ;
       YCur := S_CurrentRec[ScrNum]^.YPos ;
       Show_Mouse ;
     end ;


{ *************************************************************************
     DrawDZ_In will draw the Design screen for output.
************************************************************************* }
  procedure DrawDZ_In ;

    var
       Spacing,
       i, j    : short_integer ;
       ScrRec  : ScrPtr ;
       DataRec : DataPtr ;

     begin
       Hide_Mouse ;
       Spacing := 12 * Resolution ;
       Paint_Color(1) ;
       Paint_Style(6) ; 
       Paint_Rect(x, y, w, h DIV 2 - 21 * Resolution);
       Frame_Rect(x, y, w, h DIV 2 - 21 * Resolution);
       Frame_Rect(x, y, w, h DIV 2 + 1 - 21 * Resolution);
       Paint_Color(0) ;
       Paint_Style(1) ;
       ScrRec := S_FirstRec[ScrNum] ;
       for i := 1 to PL_Offset do
           ScrRec := ScrRec^.Next ;

       i := 0 ;
       j := 0 ;
       While ScrRec <> nil do
          begin
            Paint_Frame( x + 70 + j * 280,
                         y + i * Spacing + 2 * Resolution, 8 ) ;
            Draw_String(x + 74 + j * 280, y + i * Spacing + 10 * Resolution,
                        chr(i + j * 5 + PL_Offset + $41)) ;

            Paint_Frame( x + 100 + j * 280,
                         y + i * Spacing + 2 * Resolution, 160 ) ;
            if ScrRec^.LabelStr <> '' then
               Draw_String(x + 104 + j * 280, 
                      y + i * Spacing + 10 * Resolution, ScrRec^.LabelStr) ;
            ScrRec := ScrRec^.Next ;
            i := i + 1 ;
            if i > 4 then
               begin
                 i := 0 ;
                 j := j + 1 ;
                 if j > 1 then
                    ScrRec := nil ;
               end ;
          end ;
       Show_Mouse ;
     end ;

{ *************************************************************************
     DrawDZ_Out will draw the Design screen for output.
************************************************************************* }
  procedure DrawDZ_Out ;

    var
       i, j,
       Start   : short_integer ;
       ScrRec  : ScrPtr ;
       DataRec : DataPtr ;
       CheckChar  : char ;

     begin
       Hide_Mouse ;
       Paint_Rect(x, y + h DIV 2 - 21 * Resolution, w, h DIV 2 + 20 * Resolution);
       i := 1 ;
       ScrRec := S_FirstRec[Report] ;
       DataRec := D_FirstRec[Report] ;
       While ScrRec <> nil do
          begin
            GetStr(DataRec, FormatStr, ScrRec^.Offset, ScrRec^.Size ) ;

            if RW_Offset = 0 then
               Start := 1 
            else 
               Start := RW_Offset ;

            for j := Start to RW_Offset + 78 do
                begin
                  CheckChar := FormatStr[j] ;
                  if ord(CheckChar) > $7F then
                     FormatStr[j] := chr(ord(CheckChar) - $80 + $41) ;
                end ;

            if RW_Offset > 0 then
               begin
                 Delete(FormatStr, 1, 56) ;
                 Draw_String(x, y + (7 + i) * Spacing - 4 * Resolution, 
                 FormatStr) ;
               end
            else
               begin
                 Delete(FormatStr, 78, 54) ;
                 Draw_String(x + 8, y + (7 + i) * Spacing - 4 * Resolution,
                             FormatStr) ;
               end ;
               
            ScrRec := ScrRec^.Next ;
            i := i + 1 ;
          end ;

       Case RepLine of
         1 : begin
               i := 3 ;
               j := 4 ;
             end ;
         2 : begin
               i := 3 ;
               j := 5 ;
             end ;
         3 : begin
               i := 3 ;
               j := 6 ;
             end ;
         4 : begin
               i := 2 ;
               j := 6 ;
             end ;

       end ;
       if P_Mode = 2 then
          if Resolution = 2 then
             begin
               Line(x,     y + h DIV 2 + i * Spacing + 6, 
                    x + w, y + h DIV 2 + i * Spacing + 6) ;
               Line(x,     y + h DIV 2 + j * Spacing + 6, 
                    x + w, y + h DIV 2 + j * Spacing + 6) ;
             end
          else
             begin
               Line(x,     y + h DIV 2 + i * Spacing + 4, 
                    x + w, y + h DIV 2 + i * Spacing + 4) ;
               Line(x,     y + h DIV 2 + j * Spacing + 4, 
                    x + w, y + h DIV 2 + j * Spacing + 4) ;
             end ;
       Show_Mouse ;
     end ;
{ *************************************************************************
     DrawADesign will draw the Design screen for output.
************************************************************************* }
  procedure DrawDesign ;

     begin
       DrawDZ_In ;
       DrawDZ_Out ;
     end ;

{ *************************************************************************
     DrawAField will draw the ScrPtr Record, CurRec.  The location is 
     determined by the values CurRec^.X and CurRec^.Y.
************************************************************************* }
  procedure DrawAField( CurRec : ScrPtr ) ;

     begin
       Hide_Mouse ;
       FormatStr := Concat(CurRec^.LabelStr, '  ') ;
       Draw_String(x + CurRec^.X * 8, y + CurRec^.Y * Spacing,
                       FormatStr ) ;
       Paint_Frame(x + (CurRec^.X + Length(CurRec^.LabelStr) + 2) * 8 + 4, 
                   y + (CurRec^.Y - 1) * Spacing + (4 * Resolution), 
                   CurRec^.Size * 8 ) ;
       Show_Mouse ;
     end ;
     
{ *************************************************************************
     DrawScreen will update the entire screen, redrawing all labels.
************************************************************************* }
  procedure DrawScreen( CurRec : ScrPtr ) ;

     begin
       Hide_Mouse ;
       Paint_Color(White) ;
       Paint_Rect(x,y,w,h) ;

       if Mode = 5 then
          DrawDesign
       else
          While CurRec <> nil do
             begin
               DrawAField(CurRec) ;
               CurRec := CurRec^.Next ;
             end ;
       Show_Mouse ;
     end ;

{ *************************************************************************
     Do_Redraw will redraw the screen to GEM specifications.
************************************************************************* }
  procedure Do_Redraw(msg : Message_Buffer ) ;

    var
       x0, y0,
       w0, h0 : short_integer;

     begin
       Hide_Mouse ;
       Begin_Update;

       First_Rect(msg[3], x0, y0, w0, h0);
       while (w0 <> 0) OR (h0 <>0) do
          begin
            if Rect_Intersect(msg[4], msg[5], msg[6], msg[7],
                              x0, y0, w0, h0) then
               begin
                 Set_Clip(x0,y0,w0,h0);
                 DrawScreen( S_FirstRec[ScrNum] );
                 if (D_CurrentRec[DataNum] <> nil) AND (Mode <> 5) then
                    DrawRecord(D_CurrentRec[DataNum]) ;
               end ;
            Next_Rect(msg[3], x0, y0, w0, h0);
          end;

       if Mode = 5 then
          NewCursor(Report)
       else
          NewCursor(ScrNum) ;
       End_Update;
       Show_Mouse ;
     end;


BEGIN
END .

