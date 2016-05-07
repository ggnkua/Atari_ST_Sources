{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                                WINDOW DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}
program Window_Demo;

uses GemInterface, GemDecl, GemAES, GemVDI;

const
  LeftButton    = 0;            { left mouse button             }
  RightButton   = 1;            { right mouse button            }

var
  w1, w2, w3    : integer;      { window handles                }
  x, y, w, h    : integer;      { used for various purposes     }
  Title2        : string;       { window 2's title string       }
  Title3        : string;       { window 3's title string       }
  InfoLine      : string;       { window 3's info line string   }
  AllElements   : integer;      { all window elements           }
  i             : 0..1000;      { slider position index         }
  j             : 0..2;         { FOR index                     }
  mouseX        : integer;      { mouse x pos                   }
  mouseY        : integer;      { mouse y pos                   }
  mouseKeys     : integer;      { mouse button state            }
  window        : integer;      { window handle from wind_find  }
  s             : string;       { message string                }

{ Clear the work rectangle of the given window }
procedure ClearWindow(window : integer);
var
  p : Array_4;                  { rectangle to clear            }
begin
  wind_update(BEG_UPDATE);      { we're working !               }
  wind_get(window, WF_WORKXYWH, x, y, w, h);    { get work area }
  p[0] := x;                    { set up rectangle              }
  p[1] := y;
  p[2] := x + w - 1;
  p[3] := y + h - 1;
  vs_clip(VDI_handle, 1, p);            { set clip rectangle    }
  vsf_color(VDI_handle, WHITE);         { white,                }
  vsf_interior(VDI_handle, SOLID);      { solid                 }
  vr_recfl(VDI_handle, p);              { fill                  }
  v_gtext(VDI_handle, x, y + CharDefs.h_char,
          ' HighSpeed Pascal window demonstration program '#00);
  wind_update(END_UPDATE)               { we're through working }
end;

begin  { main }
  if Init_Gem then begin
    Message('Welcome to the window library demonstration!');

    Message('We will now create and open a simple window...');
    x := MinX + 5;                      { make border size      }
    y := MinY;
    w := MaxW div 2 - 5;
    h := MaxH div 2 - 5;
    w1 := wind_create(0, x, y, w, h);   { create the window     }
    wind_open(w1, x, y, w, h);          { open (display) it     }
    ClearWindow(w1);                    { clear work area       }

    Message('and a second, more complex, one...');
    x := x + w + 5;                     { make x pos            }
    Title2 := ' Window 2 '#00#00;       { create title          }
    { create window #2 }
    w2 := wind_create(NAME + CLOSER + SIZER, MinX + 5, MinY + 5, MaxW - 10, MaxH - 10);
    { set title : }
    wind_set(w2, WF_NAME, HiPtr(Title2[1]), LoPtr(Title2[1]), 0, 0);
    wind_open(w2, x, y, w, h);          { display window        }
    ClearWindow(w2);                    { clear work rectangle  }

    Message('and finally the most advanced available.');
    AllElements := NAME + CLOSER + FULLER + INFO + SIZER + UPARROW +
                   DNARROW + VSLIDE + LFARROW + RTARROW + HSLIDE;
    x := MinX + 5;                      { make border pos, size }
    y := MinY + MaxH div 2;
    w := MaxW - 2*5;
    h := MaxH div 2;
    Title3   := ' Window 3 '#00#00;     { create title          }
    InfoLine := 'This is the window''s'
                 + ' info line'#00#00;  { create info line      }
    w3 := wind_create(AllElements, x, y, w, h);
    { set title : }
    wind_set(w3, WF_NAME, HiPtr(Title3[1]), LoPtr(Title3[1]), 0, 0);
    { set info line : }
    wind_set(w3, WF_INFO, HiPtr(InfoLine[1]), LoPtr(InfoLine[1]), 0, 0);
    wind_open(w3, x, y, w, h);          { display window #3     }
    ClearWindow(w3);                    { clear work area       }

    Message('Now we''ll activate the second window...');
    wind_set(w2, WF_TOP, 0, 0, 0, 0);   { top #2                }

    Message('and change the size of it...');
    wind_get(w2, WF_CURRXYWH, x, y, w, h);     { get curr. size }
    w := w div 2;                              { make half width}
    wind_set(w2, WF_CURRXYWH, x, y, w, h);     { set new size   }
    ClearWindow(w2);                           { clear work area}

    Message('full it...');
    wind_get(w2, WF_FULLXYWH, x, y, w, h);     { get max size   }
    wind_set(w2, WF_CURRXYWH, x, y, w, h);     { set it         }
    ClearWindow(w2);                           { clear work area}

    Message('and restore to previous size.');
    wind_get(w2, WF_PREVXYWH, x, y, w, h);     { get prev. size }
    wind_set(w2, WF_CURRXYWH, x, y, w, h);     { set it         }
    { As window #2 overlaid the other two windows, thereby
      destroying their work areas, they have to be cleared again}
    ClearWindow(w1);                           { clear work #1  }
    ClearWindow(w2);                           {            #2  }
    ClearWindow(w3);                           {            #3  }

    Message('A window can be closed...');
    wind_get(w3, WF_CURRXYWH, x, y, w, h);     { save size      }
    wind_close(w3);                            { remove from VDU}

    Message('and opened again later.');
    wind_open(w3, x, y, w, h);                 { display        }
    ClearWindow(w3);                           { clear work area}

    Message('Let''s change the horizontal slider''s size in #3');
    wind_set(w3, WF_HSLSIZE, 333, 0, 0, 0);    { size = 1/3 of  }
                                               { max. possible  }

    Message('Now we''ll move the vertical slider.');
    i := 0;
    for j := 0 to 2 do begin
      while i < 1000 do begin
        inc(i, 100);
        wind_set(w3, WF_VSLIDE, i, 0, 0, 0)    { set size       }
      end;
      while i > 0 do begin
        dec(i, 100);
        wind_set(w3, WF_VSLIDE, i, 0, 0, 0)    { set size       }
      end
    end;

    Inform('Move and click left mouse button; right completes');
    graf_mouse(M_ON, NIL);
    repeat
      vq_mouse(VDI_handle, mouseKeys, mouseX, mouseY);
      if BitTest(LeftButton, mouseKeys) then begin
        window := wind_find(mouseX, mouseY);
        if window = 0 then s := '-No window-'
        else begin
          str(window, s);
          s := 'Window handle = ' + s
        end;
        s := s + '   Right button completes';
        Inform(s)
      end
    until BitTest(RightButton, mouseKeys);
    graf_mouse(M_OFF, NIL);

    Message('Now all is shown, so let''s close all windows...');
    wind_close(w1);
    wind_close(w2);
    wind_close(w3);

    Message('remove them from memory and terminate!');
    wind_delete(w1);
    wind_delete(w2);
    wind_delete(w3);

    Exit_Gem
  end
end.
