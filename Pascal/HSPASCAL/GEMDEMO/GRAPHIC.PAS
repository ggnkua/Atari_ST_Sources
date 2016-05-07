{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                             VDI GRAPHICS DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program VDI_graphics;

uses GemInterface, GemDecl, GemVDI, GemAES;

var
  i : integer;          { FOR index                }
  j : integer;          { FOR index                }
  p : PtsIn_Array;      { v_pline coordinate array }
  a : Array_4;          { v_bar coordinate array   }
  y : integer;          { y coordinates            }

begin
  if Init_Gem then begin
    Message('Welcome to the VDI graphics demonstration!');
    OpenOutputWindow;

    Message('First, we''ll look at some lines...');
    vsl_color(VDI_handle, Black);       { black lines           }
    vsl_width(VDI_handle, 1);           { line width := 1 pixel }
    with OutputWindow do begin
      p[0] := wX + 5;                   { set line's left X     }
      p[2] := wX + wW - 10;             { and right X           }
      y    := wY + 5                    { first line's Y        }
    end;
    vsl_udsty(VDI_handle, Binary('1100110011001100'));  { set user line style }

    for i := Solid to DashDotDot + 1 do begin   { let's see all styles  }
      vsl_type(VDI_handle, i);          { set current style             }
      p[1] := y;  p[3] := y;            { set line start, end Y         }
      v_pline(VDI_handle, 2, p);        { draw the line, 2 coords       }
      inc(y, 10)                        { new y                         }
    end;

    vsl_type(VDI_handle, Solid);        { set solid line style          }
    for i := 0 to 4 do begin            { let's look at line widths     }
      inc(y, 10);
      vsl_width(VDI_handle, 1 + i * 2); { set line width (should be odd)}
      p[1] := y;  p[3] := y;
      v_pline(VDI_handle, 2, p)
    end;

    Message('markers...');
    ClearOutputWindow;
    for i := 1 to 6 do
      p[(i-1)*2] := OutputWindow.wX + i * 80;   { set up v_pmarker  }
    p[1] := OutputWindow.wY + 20;               { coordinates       }
    vsm_height(VDI_handle, 38);                 { set marker height }
    for i := 1 to 6 do begin
      for j := 1 to 5 do p[j*2+1] := p[1];      { set same y coord  }
      vsm_type(VDI_handle, i);                  { set marker type   }
      v_pmarker(VDI_handle, 6, p);              { make the markers  }
      inc(p[1], 40)                             { update y pos      }
    end;

    Message('then at some arcs...');
    vsl_width(VDI_handle, 1);                   { line width := 1       }
    ClearOutputWindow;
    with OutputWindow do y := wY + wH div 2;    { window mid Y          }
    for i := 0 to 5 do 
      v_arc(VDI_handle, OutputWindow.wX + 50 + i * 100, y,      { x, y  }
            45,                                 { radius                }
            0, (i + 1) * 600);                  { start, end angle      }

    Message('not to mention the pies...');
    ClearOutputWindow;
    vsf_interior(VDI_handle, PATTERN);  { use a pattern fill            }
    vsf_color(VDI_handle, BLACK);       { make set points black         }
    for i := 0 to 5 do begin
      vsf_style(VDI_handle, i + 1);     { set fill style                }
      v_pieslice(VDI_handle, OutputWindow.wX + 50 + i * 100, y,
                 45,
                 0, (i + 1) * 600)      { parameters same as for v_arc  }
    end;                                { above                         }

    Message('circles...');
    ClearOutputWindow;
    for i := 0 to 5 do begin
      vsf_style(VDI_handle, i + 1);
      v_circle(VDI_handle, OutputWindow.wX + 50 + i * 100, y,   { x, y   }
              (i+1) * 8)                                        { radius }
    end;

    Message('and bars.');
    ClearOutputWindow;
    for i := 0 to 19 do begin
      vsf_style(VDI_handle, i + 1);
      a[0] := OutputWindow.wX + 5 + i * 30;
      a[2] := a[0] + 25;
      a[1] := OutputWindow.wY + OutputWindow.wH - 5;
      a[3] := a[1] - (i + 1) * 10;
      v_bar(VDI_handle, a)
    end;

    Message('That''s all folks!');
    CloseOutputWindow;
    Exit_Gem
  end
end.
