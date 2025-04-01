Program PaletteDemo;

Uses Graph;

Const
        MulFact = 0.0174532925;
Var
        o,p,m,a,
        Hx,Hy,
        Driver,
        Mode    : Integer;
        Rad     : Extended;
        Pal     : PaletteType;
Begin
  Driver := StColor;
  Mode   := StLow;
  InitGraph(Driver,Mode,'');
  Hx := GetMaxX DIV 2;
  Hy := GetMaxY DIV 2;

  { Draw lines }
  For A := 1 to 360 Do
    Begin
      Rad := MulFact*A;
      MoveTo(Hx,Hy);
      O := A Mod GetMaxColor;
      For P := 1 to 4 Do
        Begin
          SetColor(O);
          M := 8+15*P;
          LineRel(Round(M*Sin(Rad)),Round(M*Cos(Rad)));
          O := GetMaxColor-O;
        End;
    End;

  { Play with palette }
  GetPalette(Pal);
  With Pal Do
   Repeat
    Delay(50);
    M := Colors[1];
    For A := 1 to GetMaxColor-1 do
      Colors[A] := Colors[A+1];
    Colors[GetMaxColor] := M;
    SetAllPalette(Pal);
  Until keypressed;
  CloseGraph;
End.
