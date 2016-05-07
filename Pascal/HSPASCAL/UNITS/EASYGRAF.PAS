{$D+}
UNIT EasyGraf;

{ Filename: EasyGraf.pas      }
{ Coder   : Jacob V. Pedersen }
{ Coded   : 1-8-1990          }
{ Purpose : Example           }

{ This unit contains code which makes it easy to draw lines ect. }
{ It is used by the examples in the \GRAFDEMO directory. }


INTERFACE
{$F+,D-,R-,S-}

Uses GemDecl, GemAES, GemVDI;

Var
  ActiveHandle,                 { Handle to graphics screen }
  MaxColor,                     { Max. color index          }
  MinX,                         { Minimum and Maximum       }
  MinY,                         { coordinates               }
  MaxX,
  MaxY         : Integer;
  WorkOut      : WorkOut_array; { Various defaults          }   

Procedure InitGraphics;
Procedure DeInitGraphics;
Procedure Line( X1,Y1, X2,Y2 : Integer );
Procedure LineColor( col : Integer );
Procedure ClearDevice;
Procedure SetClipping( X1,Y1,X2,Y2 : Integer );
Procedure Box(x1,y1,x2,y2 : Integer );

IMPLEMENTATION
{$F+,D-,R-,S-}

Procedure InitGraphics;
Var
  D:      Integer;
  WorkIn: IntIn_array;
Begin
  d:=Appl_Init;
  Activehandle := graf_handle(d,d,d,d);
  For D := 0 to 9 DO
    WorkIn[D] := 1;
  WorkIn[10] := 2;
  WorkIn[11] := 0;
  v_opnvwk(WorkIn,ActiveHandle,WorkOut);  { Open virtual station } 
  MaxX     := WorkOut[0];
  MaxY     := WorkOut[1];
  MaxColor := WorkOut[13]-1;
  MinX := 0;
  MinY := 0;
  SetClipping( MinX, MinY, MaxX, MaxY );
End; { InitGraphics }


Procedure DeInitGraphics;
Begin
  v_clsvwk(ActiveHandle);             { Close virtual station } 
  Appl_Exit;
End; { DeInitGraphics }


Procedure SetClipping( X1,Y1,X2,Y2 : Integer );
Var
  Points : Array_4;
Begin
  Points[0] := X1; Points[1] := y1;
  Points[2] := x2; Points[3] := y2;
  vs_clip( ActiveHandle, 1, Points );
End; { SetClipping }
   

Procedure ClearDevice;
Begin
 v_clrwk( ActiveHandle );
End; { ClearDevice }


Procedure LineColor( col : Integer );
Begin
  vsl_color( ActiveHandle, Col );
End; { LineColor }


Procedure Line( X1,Y1, X2,Y2 : Integer );
Var
  PntArray : PtSin_Array;
Begin
  PntArray[0] := X1; PntArray[1] := Y1; 
  PntArray[2] := X2; PntArray[3] := Y2;
  v_pline( ActiveHandle, 2, PntArray) 
End; { Line }


Procedure Box(x1,y1,x2,y2 : Integer );
Begin
  Line(x1,y1,x2,y1);
  Line(x2,y1,x2,y2);
  Line(x2,y2,x1,y2);
  Line(x1,y2,x1,y1);
End; { Box }

END.
