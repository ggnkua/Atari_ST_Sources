{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                                RASTER DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program Rasters;

uses GemAES, GemVDI, GemDecl, GemInterface, Bios;

const
  Nsteps        = 16;           { number of steps, the circle is divided into }
  mode          = S_ONLY;       { vro_cpyfm copy mode - toy around with it    }

var
  sourceMFDB    : MFDB;         { source MFDB - where to get image from }
  destMFDB      : MFDB;         { destination - where to put image      }
  Rectangles    : Array_8;      { source and destination rectangles     }
  BoxRect       : GRect;        { image coordinates                     }
  i             : Integer;      { FOR index                             }
  x, y          : LongInt;      { destination x and y coordinates       }
  angle         : real;         { current angle in circle               }
  stepsize      : real;         { stepsize for circle                   }
  radius        : Integer;      { circle's radius                       }
  colors        : Array_2;      { colors used for vrt_cpyfm             }

{ Draw a line from (x,y) to (x1, y1) }
procedure Line(x, y, x1, y1 : Integer);
var p : ptsin_array;  { coordinate sets }
begin
  p[0] := x;  p[1] := y;  p[2] := x1;  p[3] := y1;
  v_pline(VDI_handle, 2, p)   { 2 = number of coordinate sets }
end;

{ Draw a box with the coordinates given by BoxRect and draw a polymarker
  in it }
procedure Box;
var p : ptsin_array;
begin
  vsm_type(VDI_handle, 3);              { star shape            }
  vsm_color(VDI_handle, BLACK);         { black                 }
  vsm_height(VDI_handle, BoxRect.h);    { height = box's height }
  with BoxRect do begin
    Line(x, y, x + w - 1, y);           { draw the borders      }
    Line(x+w-1, y, x+w-1, y+h-1);
    Line(x+w-1, y+h-1, x, y+h-1);
    Line(x, y+h-1, x, y);
    p[0] := x + w div 2;                { set up polymarker     }
    p[1] := y + h div 2;
    v_pmarker(VDI_handle, 1, p)         { set the marker        }
  end
end;

begin
  if Init_Gem then begin
    Message('Welcome to the raster demonstration!');
    OpenOutputWindow;

    Message('First, we''ll draw a rectangle...');
    with OutputWindow, Boxrect do begin
      x := midX - 30;
      y := midY - 30;
      w := 2*30;
      h := 2*30;
      Box
    end;

    Inform('By the way, this is a contour fill...');
    vsf_color(VDI_handle, BLACK);       { set points are black }
    vsf_interior(VDI_handle, HATCH);    { use cross-hatch...   }
    vsf_style(VDI_handle, 3);           { ... type 3           }
    with OutputWindow
      do v_contourfill(VDI_handle, wX, wY, BLACK);
    { fill the area containing the point (wX, wY) until the color black }
    { is met (the border color) }

    Message('Now we''ll make some opaque copies of that rect...');
    with sourceMFDB do begin
      mptr       := NIL;                { use screen memory             }
      formwidth  := BoxRect.w;          { width of image                }
      formheight := BoxRect.h;          { height of image               }
      widthword  := BoxRect.w div 16;   { number of entire words        }
      formatflag := 0;                  { device specific form          }
      memplanes  := 1                   { two colors (monochrome)       }
    end;
    destMFDB := sourceMFDB;             { destination = source          }

    Rectangles[0] := BoxRect.x;         { source rectangle =            }
    Rectangles[1] := BoxRect.y;         { two diagonally opposite corner}
    Rectangles[2] := BoxRect.x + BoxRect.w - 1;         { points        }
    Rectangles[3] := BoxRect.y + BoxRect.h - 1;

    { we''ll form a circle with the help of vro_cpyfm, so we need a bit }
    { of geometry in order to calculate where to put the images :       }
    angle := 0.0;                               { circle angle = 0.0    }
    stepsize := (2*pi) / Nsteps;                { circle step size      }
    radius := BoxRect.w + BoxRect.w div 2;      { circle radius         }
    for i := 0 to Nsteps do begin
      x := OutputWindow.midX + round(cos(angle) * radius) - BoxRect.w div 2;
      y := OutputWindow.midY + round(sin(angle) * radius) - BoxRect.h div 2;
      angle := angle + stepsize;
      Rectangles[4] := x;               { destination rectangle         }
      Rectangles[5] := y;
      Rectangles[6] := x + BoxRect.w - 1;
      Rectangles[7] := y + BoxRect.h - 1;
      vro_cpyfm(VDI_handle, mode, Rectangles, sourceMFDB, destMFDB)
    end;

    Message('Now we''ll reverse the rectangle...');
    for i := 0 to 3 do Rectangles[i+4] := Rectangles[i];  { dest rect = source }
    colors[0] := WHITE;  { set points shall turn into white   }
    colors[1] := BLACK;  { clear points shall turn into black }
    vrt_cpyfm(VDI_handle, MD_REPLACE, Rectangles, sourceMFDB, destMFDB, colors);

    Message('... and reverse again, but with another method...');
    vro_cpyfm(VDI_handle, NOT_D, Rectangles, sourceMFDB, destMFDB);

    Message('That''s all folks!');
    CloseOutputWindow;     
    Exit_Gem
  end
end.
