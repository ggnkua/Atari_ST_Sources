{$M+}
{$E+}

program Draw_Module;

     {$I A:GEMSUBS.PAS }
     {$I A:AUXSUBS.PAS }

Const
     {$I B:MOD_CONS.PAS }

Type
     {$I B:MOD_TYPE.PAS }


Var
     {$I B:MOD_VAR.PAS }

  procedure EraseCursor(X, Y, WindNo : short_integer ; CurRec : WordPointer) ;
     External ;

  procedure NewCursor(X, Y, WindNo : short_integer ; CurRec : WordPointer) ;
     External ;

  procedure Draw_VSlide(Wind : short_integer);
     External ;

  procedure Draw_HSlide(Wind : short_integer);
     External ;

  procedure SetPtLabel( WindNo : short_integer );
     External ;

  procedure LevelConvert(CurRec : WordPointer ; Var S : Str255);
     External ;


  procedure Draw_Line(X, Y : short_integer ; S : Str255 ; 
                      CurRec : WordPointer ) ;

    begin
      Hide_Mouse ;
      if CurRec^.Buffer then
         Text_Style(Thickened) ;
      Draw_String(X, Y, S) ;
      Text_Style(Normal) ;
      Show_Mouse ;
    end ;

  procedure UpdatePtLabel(CurRec : WordPointer ;
                          WindMsg, LineNo : short_integer ) ;

   var
       i,
       LevelOffset : short_integer;
       Result,
       FormatStr   : Str255 ;

   begin
     i := LineNo - 1 ;
     While (i <= NumLines) AND (CurRec <> nil) do
        begin
          LevelOffset := CurRec^.Level * 3 + 16 ;
          i := i + 1 ;
          LevelConvert(CurRec, Result) ;
          WriteV(FormatStr, Result:CurRec^.Level * 3 + 17) ;
          Draw_Line(x + 10 - (WindOffset[WindMsg]) * 8,
                      YOffset[WindMsg] + i * 9 * Resolution,
                      FormatStr, CurRec) ;
          CurRec := CurRec^.Next ;
        end ;
   end;

  procedure OverWriteLine(CurRec : WordPointer ; 
                          WindMsg, LineNo : short_integer ) ;
                       
    var
        LevelOffset : short_integer ;
        Result,
        FormatStr   : Str255 ;

    begin
      LevelOffset := CurRec^.Level * 3 + 16 ;
      XOffset[WindMsg] := x + 10 - (WindOffset[WindMsg] - LevelOffset) * 8 ;
      LevelConvert(CurRec, Result) ;
      WriteV(FormatStr, Result:CurRec^.Level * 3 + 17,CurRec^.NewWord) ;

      if CurRec = Current[Module] then
         EraseCursor(XPos[WindMsg], YPos[WindMsg], WindMsg, Current[WindMsg]) ;
      Draw_Line(x + 10 - (WindOffset[WindMsg]) * 8,
                  YOffset[WindMsg] + LineNo * 9 * Resolution,
                  FormatStr, CurRec) ;
      if CurRec = Current[Module] then
         NewCursor(XPos[WindMsg], YPos[WindMsg], WindMsg, Current[WindMsg]) ;
    end ;


  procedure UpdateLine(CurRec : WordPointer ; 
                       WindMsg, LineNo : short_integer ) ;
                       
    var
        LevelOffset : short_integer ;
        Result,
        FormatStr   : Str255 ;

    begin
      Hide_Mouse ;
      Paint_Color(White);
      Paint_Rect(x, y + (LineNo - 1) * 9 * Resolution, 
                 w, 9 * Resolution);
      OverWriteLine(CurRec, WindMsg, LineNo ) ;
      Show_Mouse ;
    end ;

  procedure Draw_Buffer(CurRec : WordPointer ; WindMsg : short_integer ) ;
                        
    var
        Counter : short_integer ;

     begin
       Hide_Mouse ;
       Counter := 1 ;
       While (CurRec <> nil) AND (Counter <= NumLines) do
         begin
           OverWriteLine(CurRec, WindMsg, Counter ) ;
           Counter := Counter + 1 ;
           CurRec := CurRec^.Next ;
         end ;
       Show_Mouse ;
     end ;


  procedure Draw_Window(CurRec : WordPointer ; 
                        WindMsg, LineNo : short_integer ) ;

   var
       i,
       LevelOffset : short_integer;
       Result,
       FormatStr   : Str255 ;

   begin
     Hide_Mouse ;
     i := LineNo - 1 ;
     Work_Rect(WindMsg, x, y, w, h);
     Paint_Color(White);
     Paint_Rect(x, y + i * 9 * Resolution, 
                w, h - i * 9 * Resolution);

     NumLines   := h DIV (9 * Resolution) ;
     NumColumns := w DIV 8 ;
     YOffset[WindMsg] := y - 2 * Resolution ;

     if CurRec = nil then
        begin
          WriteV(FormatStr, 'I. _':18) ;
          Draw_String(x + 10 - (WindOffset[WindMsg]) * 8,
                      YOffset[WindMsg] + 9 * Resolution,
                      FormatStr) ;
        end 
     else
        While (i <= NumLines) AND (CurRec <> nil) do
           begin
             i := i + 1 ;
             OverWriteLine(CurRec, WindMsg, i ) ;
             CurRec := CurRec^.Next ;
           end ;
     Draw_VSlide(WindMsg) ;
     Draw_HSlide(WindMsg) ;
     Show_Mouse ;
   end;

 procedure Do_Redraw( MsgBuf : short_integer ) ;

  var
     x, y,
     w, h : short_integer;

  begin
    Begin_Update;
 
    With Gem_Result do
      begin
        SetPtLabel( MsgBuf );
        First_Rect(msg[3], x, y, w, h);
        while (w <> 0) OR (h <>0) do
            begin
              if Rect_Intersect(msg[4], msg[5], msg[6], msg[7],
                                x, y, w, h) then
                 begin
                   Set_Clip(x,y,w,h);
                   Draw_Window(ScrFirstRec[MsgBuf], MsgBuf, 1);
                 end ;
              Next_Rect(msg[3], x, y, w, h);
            end;
      end;

    End_Update;
  end;


BEGIN
END.
