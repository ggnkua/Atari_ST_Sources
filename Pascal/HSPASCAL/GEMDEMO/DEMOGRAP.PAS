{---------------------------------------------------------------------
              Graphic demo procedures for GEMDEMO

                Copyright (c) 1990 D-House I ApS
                       All rights reserved

                 Programmed by Martin Eskildsen
---------------------------------------------------------------------}

{$D+}
unit DemoGraphs;

INTERFACE

uses GemDecl, GemAES, GemVDI, DemoInterface;

{ Set up a local array of coordinates, fill styles etc. used for
  speedy graphics window update }
procedure MakeGraphData;

{ Make sure the entire graphics window is redrawn. This is required
  when the user selected demo type }
procedure ForceGraphicsRedraw;

{ Do BOXES demo }
procedure DoBoxes;

{ Do LINES demo }
procedure DoLines;

{ Do ELLIPSES demo }
procedure DoEllipses;

{ Do PIES demo }
procedure DoPies;

{$F+,D-,R-,S-}   { <--- note this if you are experimenting }

IMPLEMENTATION

const
  DataSize       = 80;    { size of graphics data array }

var
  wX, wY, wW, wH : Integer;   { Size of graphics window work area }
  GraphData      : array [1..DataSize] of record  { the array : }
                     x, y,
                     x_rad, y_rad,              { radius x and y      }
                     beg_ang, end_ang,          { start and end angle }
                     fill_style, fill_index : Integer
                   end;

procedure MakeGraphData;
var i : integer;
begin
  Randomize;
  for i := 1 to DataSize do with GraphData[i] do begin
    x          := Random(MinX + MaxW - 1);
    y          := Random(MinY + MaxH - 1);
    x_rad      := Random(MaxW DIV 5);
    y_rad      := Random(MaxH DIV 5);
    beg_ang    := Random(3600);        { GEM uses 1/10 degrees }
    end_ang    := Random(3600);
    fill_style := Random(1) + 2;
    fill_index := Random(12) + 1
  end
end;

{ Return current size of the graphics window work area }
procedure GetWindowSize;
begin
  wind_get(grafwindow, WF_WORKXYWH, wX, wY, wW, wH)
end;

{ This is advanced! The trick is, however, quite simple : Let the
  procedure put a message into the event pipe saying that a redraw
  is requested. In this way, we let the GEMDEMO application write a
  message to... the GEMDEMO application! }
procedure ForceGraphicsRedraw;
var
  mypipe : array [0..7] of integer;
begin
  GetWindowSize;                { Redraw all of window  }
  mypipe[0] := WM_REDRAW;       { The message           }
  mypipe[3] := grafwindow;      { The window            }
  mypipe[4] := wX;              { x                     }
  mypipe[5] := wY;              { y                     }
  mypipe[6] := wW;              { width                 }
  mypipe[7] := wH;              { height                }
  appl_write(AES_handle, sizeof(mypipe), mypipe)  { write message }
end;

{ Draw a line from (x,y) to (x1,y1) }
procedure Line(x,y,x1,y1 : Integer);
var p : ptsin_Array;
begin
  p[0] := x;  p[1] := y;  p[2] := x1;  p[3] := y1;
  v_pline(VDI_handle, 2, p)
end;

procedure DoBoxes;
var
  i : Integer;   { index }
  a : Array_4;   { coordinates of two diagonally opposite corners }
begin
  GetWindowSize;
  vsf_color(VDI_handle, black);           { fill color is black }
  for i := 1 to DataSize do with GraphData[i] do begin
    vsf_style(VDI_handle, fill_style);    { set fill style }
    vsf_interior(VDI_handle, fill_index); { set fill type  }
    a[0] := x + wX;              a[1] := y + wY;
    a[2] := x + wX + x_rad - 1;  a[3] := y + wY + y_rad - 1;
    v_bar(VDI_handle, a)                  { make the box   }
  end
end;

procedure DoLines;
var
  i             : Integer;
  Xstep, Ystep  : Integer;      { step sizes in x and y direction }
begin
  GetWindowSize;                { get window size }
  Xstep := wW div 30;           { step 1/30 of its width in x dir }
  Ystep := wH div 30;           { and 1/30 of its height in y dir }
  for i := 0 to 39 do begin     { draw 40 times                   }
    line(wX, wY + i*Ystep, wX + i*Xstep, wY + wH);
    line(wX + wW, wY + i*Ystep, wX + wW - i*Xstep, wY + wH);
    line(wX, wY + wH - i*Ystep, wX + i*Xstep, wY);
    line(wX + wW, wY + wH - i*Ystep, wX + wW - i*Xstep, wY)
  end
end;

procedure DoEllipses;
var i : Integer;
begin
  GetWindowSize;
  vsf_color(VDI_handle, black);                 { fill color : black }
  for i := 1 to DataSize do with GraphData[i] do begin
    vsf_style(VDI_handle, fill_style);          { set fill style     }
    vsf_interior(VDI_handle, fill_index);       { set fill type      }
    v_ellipse(VDI_handle, x + wX, y + wY, x_rad, y_rad)
                                                { draw the ellipse   }
  end
end;

procedure DoPies;
var i : Integer;
begin
  GetWindowSize;
  vsf_color(VDI_handle, black);                 { fill is black  }
  for i := 1 to DataSize do with GraphData[i] do begin
    vsf_style(VDI_handle, fill_style);          { set fill style }
    vsf_interior(VDI_handle, fill_index);       { set fill type  }
    v_ellpie(VDI_handle, x + wX, y + wY, x_rad, y_rad, beg_ang, end_ang)
  end                                           { ^ : draw the pie }
end;

end.
