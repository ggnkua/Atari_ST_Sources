Program Animate;

uses Graph;

Const
  Snow=false;
Var 
  n,driver,mode : Integer;
  P1,P2,P3      : PaletteType;

begin
  FillChar(P1,SizeOf(P1)*3,0);
  With P1 Do begin
    Size := 16;
    Colors[1]:=9;Colors[2]:=2;Colors[3]:=3;Colors[5]:=9;Colors[6]:=2;
    Colors[7]:=3;Colors[9]:=9;Colors[10]:=2;Colors[11]:=3;Colors[13]:=9;
    Colors[14]:=2;Colors[15]:=3;
  End;
  With P2 Do begin
    Size := 16;
    Colors[4]:=9;Colors[5]:=9;Colors[6]:=9;Colors[7]:=9;Colors[8]:=2;
    Colors[9]:=2;Colors[10]:=2;Colors[11]:=2;Colors[12]:=3;Colors[13]:=3;
    Colors[14]:=3;Colors[15]:=3;
  End;
  With P3 Do begin
    Size := 16;
    Colors[1]:=9;Colors[2]:=2;Colors[3]:=3;Colors[4]:=2;Colors[5]:=9;
    Colors[6]:=2;Colors[7]:=3;Colors[8]:=2;Colors[9]:=9;Colors[10]:=2;
    Colors[11]:=3;Colors[13]:=9;Colors[14]:=2;Colors[15]:=3;
  End;

  Driver := StColor;
  Mode   := StMedium;
  InitGraph(Driver,Mode,'');

  SetWriteMode(XORPut);
  SetColor(2); Rectangle(220,10,250,40);                   {Control boxes}
  SetColor(8); Rectangle(220+50,10,250+50,40);
  repeat
    n:=1-1; SetColor(8); Rectangle(n+1,n+1,n+181,n+181);
    for n:=1 to 20 do begin
      SetColor(2); Rectangle(n,n,n+180,n+180);
      if not Snow then SetAllPalette(P3);              {Show both}
      SetAllPalette(P1); Delay(10);
      SetColor(8); Rectangle(n,n,n+180,n+180);
      SetColor(8); Rectangle(n+1,n+1,n+181,n+181);
      if not Snow then SetAllPalette(P3);        {Prevent "holes"}
      SetAllPalette(P2); Delay(10);
      SetColor(2); Rectangle(n,n,n+180,n+180);
    end;
    n:=20+1; SetColor(8); Rectangle(n,n,n+180,n+180);
  until keypressed;
  closegraph;
end.
