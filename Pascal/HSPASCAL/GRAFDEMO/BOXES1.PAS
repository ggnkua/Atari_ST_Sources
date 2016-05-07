{M 10,10,20,20}

Program Boxes1;

Uses EasyGraf;

{ Filename: Boxes1.pas        }
{ Coder   : Jacob V. Pedersen }
{ Coded   : 1-8-1990          }
{ Purpose : Example           }

{ The mouse is not shown if you enter .TOS in the OPTIONS/Linker dialog }

Const
        StepX   = 1;
        StepY   = 1;
Var
        ShiftX  : Byte;
        ShiftY  : Byte;
        Boxes   : Integer;


{ Makes a number of boxes, all filled with smaller boxes. }
Procedure MakeBoxes;
Var
        Xlng,
        Ylng,
        X,Y     : Integer;

Procedure FillBox( X1,Y1, X2,y2 : Integer);
Begin
  If KeyPressed then
    Exit;
  LineColor(Random(MaxColor+1));
  Box(x1,y1,x2,y2);
  
  If (X1+stepx < X2) AND (Y1+stepy < Y2) then
    Fillbox( x1+stepx, y1+stepy, x2-stepx, y2-stepy );
End; { FillBox }


Begin
  Xlng   := (MaxX DIV Boxes)-1;
  Ylng   := (MaxY DIV Boxes)-1;
  ShiftX := (MaxX MOD Boxes) DIV 2;
  ShiftY := (MaxY MOD Boxes) DIV 2;

  For X := 0 to Boxes-1 DO
    For Y := 0 to Boxes-1 do
      Begin
        FillBox(ShiftX+(X*Xlng)+X,
                ShiftY+(Y*Ylng)+Y,
                ShiftX+(Xlng*succ(X))+X,
                ShiftY+(Ylng*succ(Y))+Y);
      End;
End; { MakeBoxes }


BEGIN { main }
  Randomize;
  InitGraphics;
  ClearDevice;
  Boxes := 0;
  Repeat
   Inc(Boxes); 
   MakeBoxes; 
  Until (KeyPressed) OR (Boxes = 400);
  DeInitGraphics;
END.
