Program Boxes2;

Uses EasyGraf;

{ Filename: BOXES2.PAS                  }
{ Coder   : JVP.                        }
{ Coded   : 1-8-1990                    }
{ Purpose : Example                     }

{ The mouse is not shown if you enter .TOS in the OPTIONS/Linker dialog }

Const
        XStep    =  2;  { Step value for horizontal lines. }
        YStep    =  3;  { Step value for vertical lines. }
        MaxTimes =  3;  { How many screens will be made? }
Var
        Times    : Byte;        { Screen counter. }
        Direc    : Boolean;     { Direction indicator. }


{ Make boxes, by using resursive calls. }
Procedure Recursive_Boxes( X1,Y1, X2,Y2 : Integer );
Begin
  If (KeyPressed) then
    Exit;
  
  LineColor(Random(MaxColor+1));
  Box(X1,Y1,X2,Y2);

  If (Y1 >= MaxY DIV 2) OR (X1 >= MaxX DIV 2) then
    Inc(Times);

  If (Times < MaxTimes) then
    Begin
      If (X1 >= MaxX DIV 2) OR (Y1 >= MaxY DIV 2) then
        Direc := FALSE
      ELSE
      If (X1 <= 0) OR (Y1 <= 0) then
        Direc := TRUE;

      If (Direc = TRUE) then
        Recursive_Boxes( X1+XStep, Y1+YStep, X2-XStep, Y2-YStep )
      ELSE
        Recursive_Boxes( X1-XStep, Y1-YStep, X2+XStep, Y2+YStep );
    End;
End; { Recursive_Boxes }


BEGIN { main }
  Randomize;
  InitGraphics;
  ClearDevice;
  Repeat
    Times := 0; 
    Direc := True;
    Recursive_Boxes(0,0,MaxX,MaxY);
  Until KeyPressed;
  DeInitGraphics;
END.
