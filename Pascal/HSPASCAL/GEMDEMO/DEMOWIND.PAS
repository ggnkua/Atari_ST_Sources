{---------------------------------------------------------------------
                GEM Window Interface for GEMDEMO

                Copyright (c) 1990 D-House I ApS
                       All rights reserved

                 Programmed by Martin Eskildsen
---------------------------------------------------------------------}

{$D+}

unit DemoWindows;

INTERFACE

uses GemDecl, GemAES, GemVDI, DemoInterface, DemoGraphs;

{ Create and open graphics window }
procedure OpenGraphicsWindow;

{ Close and delete graphics window }
procedure CloseGraphicsWindow;

{ Create and open text window }
procedure OpenTextWindow;

{ Close and delete text window }
procedure CloseTextWindow;

{ Select one of the graphics demos }
procedure SelectGraphicsDemo;

{ Redraw a window.
    handle         : window to redraw
    x0, y0, w0, h0 : area to redraw
}
procedure RedrawWindow(handle, x0, y0, w0, h0 : Integer);

{ Top the given window }
procedure TopWindow(handle : Integer);

{ Full the given window }
procedure FullWindow(handle : Integer);

{ Close and delete the given window }
procedure CloseWindow(handle : Integer);

{ Move the given window. New corner (x,y) coordinates are given }
procedure MoveWindow(handle, toX, toY : Integer);

{ Set the given windows size. New width and height are given }
procedure SizeWindow(handle, newW, newH : Integer);

{ Close the currently active window }
procedure CloseTopWindow;

{$F+,D-,S-,R-}

IMPLEMENTATION

var
  GrafName      : String;       { Graphics window name                  }
  TextName      : String;       { Text window name                      }
  TextLine      : String;       { The line written in the text window   }
  GrafElements  : Integer;      { Graphics window border elements       }
  TextElements  : Integer;      { Text window border elements           }
  TextX         : Integer;      { Initial positions and sizes of the    }
  TextY         : Integer;      { two windows. Y, W and H are the same  }
  TextW         : Integer;      { for both, but are dublated in order   }
  TextH         : Integer;      { to allow for easy modification and to }
  GrafX         : Integer;      { clearify what's going on              }
  GrafY         : Integer;
  GrafW         : Integer;
  GrafH         : Integer;

{ This procedure calculates the correct sizes and positions of the windows
  from the available desktop space }
procedure CalcWindowPositions;
begin
  TextX := 8;
  TextY := CharBoxHeight + CharBoxHeight DIV 2;
  TextW := (MaxW - 2*TextX - 20) DIV 2;
  TextH := MaxH - CharBoxHeight;
  GrafX := TextX + TextW + 20;
  GrafY := TextY;
  GrafW := TextW;
  GrafH := TextH
end;

procedure OpenGraphicsWindow;
begin
  { create window : }
  CalcWindowPositions;
  grafwindow := wind_create(GrafElements, MinX, MinY, MaxW, MaxH);
  if grafwindow >= 0 then begin   { created ok... }
    wind_update(BEG_UPDATE);      { AES : leave us alone! }
    
    { set window name : }
    wind_set(grafwindow, WF_NAME, HiPtr(GrafName[1]), LoPtr(GrafName[1]), 0, 0);
    
    { draw a nice expanding box and open window }
    graf_growbox(GrafX + GrafW DIV 2 - 5, GrafY + GrafH DIV 2 - 5, 10, 10, GrafX, GrafY, GrafW, GrafH);
    wind_open(grafwindow, GrafX, GrafY, GrafW, GrafH);
    
    { set WINMENU's state }
    SetMenuState(s_enable, s_leave, s_leave, s_disable, s_enable);
    wind_update(END_UPDATE)        { let the AES rule again }
  end
end;

procedure CloseGraphicsWindow;
var x, y, w, h : Integer;       { window border area }
begin
  if grafwindow >= 0 then begin
    wind_update(BEG_UPDATE);    { leave us alone }
    
    { get border size and draw a shrinking box : }
    wind_get(grafwindow, WF_CURRXYWH, x, y, w, h);
    graf_shrinkbox(x + w DIV 2 - 5, y + h DIV 2 - 5, 10, 10, x, y, w, h);
    wind_close(grafwindow);     { remove window from screen }
    wind_delete(grafwindow);    { and memory too            }
    grafwindow := -1;           { set handle = -1 to prevent mistakes }
    if textwindow >= 0 then     { update WINMENU            }
      SetMenuState(s_leave, s_leave, s_leave, s_enable, s_disable)
    else
      SetMenuState(s_disable, s_leave, s_leave, s_enable, s_disable);
    wind_update(END_UPDATE)     { let AES rule }
  end
end;

{ Consult OpenGraphicsWindow - they're similar }
procedure OpenTextWindow;
begin
  CalcWindowPositions;
  textwindow := wind_create(TextElements, MinX, MinY, MaxW, MaxH);
  if textwindow >= 0 then begin
    wind_update(BEG_UPDATE);
    wind_set(textwindow, WF_NAME, HiPtr(TextName[1]), LoPtr(TextName[1]), 0, 0);
    graf_growbox(TextX + TextW DIV 2 - 5, TextY + TextH DIV 2 - 5, 10, 10, TextX, TextY, TextW, TextH);
    wind_open(textwindow, TextX, TextY, TextW, TextH);
    SetMenuState(s_enable, s_disable, s_enable, s_leave, s_leave);
    wind_update(END_UPDATE)
  end;
end;

{ Consult CloseGraphicsWindow - they're similar }
procedure CloseTextWindow;
var x, y, w, h : Integer;
begin
  if textwindow >= 0 then begin
    wind_update(BEG_UPDATE);
    wind_get(textwindow, WF_CURRXYWH, x, y, w, h);
    graf_shrinkbox(x + w DIV 2 - 5, y + h DIV 2 - 5, 10, 10, x, y, w, h);
    wind_close(textwindow);
    wind_delete(textwindow);
    textwindow := -1;
    if grafwindow >= 0 then
      SetMenuState(s_leave, s_enable, s_disable, s_leave, s_leave)
    else
      SetMenuState(s_disable, s_enable, s_disable, s_leave, s_leave);
    wind_update(END_UPDATE)
  end
end;

procedure SelectGraphicsDemo;
var
  x, y, w, h : Integer;   { dialog border size       }
  selected   : Integer;   { selected demo icon index }
begin
  form_center(selection, x, y, w, h);            { centre of screen }
  form_dial(FMD_START,  0, 0, 0, 0, x, y, w, h); { reserve RAM      }
  form_dial(FMD_GROW,   0, 0, 0, 0, x, y, w, h); { grow box         }
  objc_draw(selection,  0, $7FFF,   x, y, w, h); { draw dialog box  }
  selected := form_do(selection, -1);            { do the dialog    }
  form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h); { shrink box       }
  form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h); { release RAM      }
  case selected of                       { set currect demo state : }
    BOXES    : demo := BoxesDemo;
    LINES    : demo := LinesDemo;
    ELLIPSES : demo := EllipsesDemo;
    PIES     : demo := PiesDemo
  end;
  ForceGraphicsRedraw        { make sure graphics window is redrawn }
end;

procedure RedrawWindow(handle, x0, y0, w0, h0 : Integer);
var
  R1, R2     : Grect;     { used for conversion purposes }
  x, y, w, h : Integer;   { rectangle to redraw          }
  a          : Array_4;   { used for conversion purposes }

  { Redraw text window }
  procedure DoTextRedraw;
  var
    x, y, w, h : Integer;    { work area size }
    i          : Integer;
  begin
    wind_get(textwindow, WF_WORKXYWH, x, y, w, h);
    i := CharBoxHeight;         { y-offset to start writing at }
    while i <= (y + h - 1 + CharBoxHeight) do begin
      v_gtext(VDI_handle, x, y + i, TextLine);
      inc(i, CharBoxHeight)     { one line written }
    end
  end;

  { Redraw graphics window }
  procedure DoGraphicsRedraw;
  begin
    case demo of
      BoxesDemo    : DoBoxes;
      LinesDemo    : DoLines;
      EllipsesDemo : DoEllipses;
      PiesDemo     : DoPies
    end
  end;

begin { RedrawWindow }
  R1.x := x0;  R1.y := y0;  R1.w := w0;  R1.h := h0; { set up R1 }
  wind_update(BEG_UPDATE);            { we're updating!          }
  graf_mouse(M_OFF, NIL);             { and want no mice around! }
  
  { get first rectangle from the window rectangle list : }
  wind_get(handle, WF_FIRSTXYWH, x, y, w, h);
  
  while (w <> 0) and (h <> 0) do begin { there IS a rectangle :  }
    R2.x := x;  R2.y := y;  R2.w := w;  R2.h := h; { set up R2   }
    if intersect(R1, R2) then begin    { is area destroyed?      }
      x    := R2.x;  y    := R2.y;  w    := R2.w;       h    := R2.h;
      a[0] := x;     a[1] := y;     a[2] := x + w - 1;  a[3] := y + h - 1;
      vs_clip(VDI_handle, 1, a);       { set clipping            }
      vsf_color(VDI_handle, White);    { clear work area styles :}
      vsf_interior(VDI_handle, SOLID); {   solid, white fill     }
      v_bar(VDI_handle, a);            { and clear messy rect.   }
      if handle = textwindow then DoTextRedraw else DoGraphicsRedraw
    end;
    
    { one rectangle done, the rest to go! }
    wind_get(handle, WF_NEXTXYWH, x, y, w, h)
  end;
  graf_mouse(M_ON, NIL);    { allright, let's see the mouse again }
  wind_update(END_UPDATE)   { now we're through updating anyway...}
end;

procedure TopWindow(handle : Integer);
begin
  wind_set(handle, WF_TOP, 0, 0, 0, 0)  { set handle to top window }
end;

{ The philosophy is : If window is fulled already, then set it to its
  old size and position, else full it }
procedure FullWindow(handle : Integer);
var
  x,  y,  w,  h  : Integer;   { current size      }
  x0, y0, w0, h0 : Integer;   { max (fulled) size }
  x1, y1, w1, h1 : Integer;   { old size          }
begin
  wind_get(handle, WF_CURRXYWH, x,  y,  w,  h);
  wind_get(handle, WF_FULLXYWH, x0, y0, w0, h0);
  wind_get(handle, WF_PREVXYWH, x1, y1, w1, h1);
  if (x <> x0) or (y <> y0) or (w <> w0) or (h <> h0) then
    wind_set(handle, WF_CURRXYWH, x0, y0, w0, h0)  { full it }
  else
    wind_set(handle, WF_CURRXYWH, x1, y1, w1, h1); { set to previous }
  if handle = grafwindow then ForceGraphicsRedraw
end;

procedure CloseWindow(handle : Integer);
begin
  if handle = textwindow then CloseTextWindow else CloseGraphicsWindow
end;

procedure CloseTopWindow;
var
  tophandle, dummy : Integer;
begin
  wind_get(0, WF_TOP, tophandle, dummy, dummy, dummy); { get top window }
  CloseWindow(tophandle)                               { close it       }
end;

{ This could easily be made smarter as GEM puts all four window size
  parameters in the pipe, but for the sake of example... }
procedure MoveWindow(handle, toX, toY : Integer);
var x, y, w, h, dummy : Integer;   { border area size }
begin
  wind_get(handle, WF_CURRXYWH, x, y, w, h); { get x, y, w and h   }
  graf_movebox(w, h, x, y, toX, toY);
  wind_set(handle, WF_CURRXYWH, toX, toY, w, h);     { set new (x,y) }
  if handle = grafwindow then ForceGraphicsRedraw
end;

{ As above, this also could be made smarter! }
procedure SizeWindow(handle, newW, newH : Integer);
var x, y, w, h : Integer;
begin
  wind_get(handle, WF_CURRXYWH, x, y, w, h);         { get x and y  }
  wind_set(handle, WF_CURRXYWH, x, y, newW, newH);   { set new w, h }
  if handle = grafwindow then ForceGraphicsRedraw
end;

begin { of unit DemoWindows }
  GrafName := ' HighSpeed graphics window '#00#00;   { Note! }
  TextName := ' HighSpeed text window '#00#00;
  TextLine := 'The Quick Brown Fox Jumps Over The Very Lazy Dog - a GEM text window'#00;
  TextElements := NAME + CLOSER + FULLER + MOVER + SIZER;
  GrafElements := NAME + CLOSER + FULLER + MOVER + SIZER
end.
