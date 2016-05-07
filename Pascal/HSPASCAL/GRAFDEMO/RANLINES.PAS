Program RanLines;

Uses EasyGraf;
  
{ Filename: RanLines.pas      }
{ Coder   : Jacob V. Pedersen }
{ Coded   : 1-8-1990          }
{ Purpose : Example           }

{ The mouse is not shown if you enter .TOS in the OPTIONS/Linker dialog }

Procedure Make_Lines;
Const Extra=-20;
Begin
  Repeat
    LineColor(Random(MaxColor+1));
    Line( Random(MaxX+Extra*2)-Extra,
          Random(MaxY+Extra*2)-Extra,
          Random(MaxX+Extra*2)-Extra,
          Random(MaxY+Extra*2)-Extra);
  Until (KeyPressed);
End; { Make_Lines }

BEGIN { main }
  Randomize;
  InitGraphics;
  ClearDevice;
  Make_Lines;
  DeInitGraphics;
END.
