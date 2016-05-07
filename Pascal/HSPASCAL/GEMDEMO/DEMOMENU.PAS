{---------------------------------------------------------------------
                 GEM Menu Interface for GEMDEMO

                Copyright (c) 1990 D-House I ApS
                       All rights reserved

                 Programmed by Martin Eskildsen
---------------------------------------------------------------------}

{$D+}

unit DemoMenu;

INTERFACE

uses GemDecl, GemAES, DemoInterface, DemoWindows;

{ Handle the menu messages
  title  : drow-down menu's title index
  index  : menu item's index
}
procedure HandleMenu(title, index : Integer);

{$F+,D-,R-,S-}

IMPLEMENTATION

{ Handle the ABOUTBOX }
procedure DoAboutBox;
var
  x, y, w, h : Integer;   { Dialog box outline size                   }
  i          : Integer;   { Item index ending dialog box (ABOUTOK)    }
begin
  form_center(about, x, y, w, h);                { centre on screen   }
  form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);  { reserve RAM        }
  form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);   { draw growing box   }
  objc_draw(about, 0, $7FFF, x, y, w, h);        { draw dialog box    }
  i := form_do(about, -1);                       { do the dialog      }
  form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h); { shrinking box      }
  form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h); { release RAM        }
  SetObjectStatus(about, ABOUTOK, NORMAL)        { reset button state }
end;

{ Not very optimally programmed! But easy to extend, however }
procedure HandleMenu;
begin
  case title of
    DESKMENU : case index of
                 ABOUTBAR : DoAboutBox
               end;
    WINMENU  : case index of
                 WINCLOSE : CloseTopWindow;
                 TXTOPEN  : OpenTextWindow;
                 TXTCLOSE : CloseTextWindow;
                 GRAOPEN  : OpenGraphicsWindow;
                 GRACLOSE : CloseGraphicsWindow;
                 GRASELEC : SelectGraphicsDemo
               end;
    QUITMENU : case index of
                 QUITBAR  : quit := TRUE
               end
  end;
  menu_tnormal(menu, title, 1)    { set menu title back to normal }
end;

end.
