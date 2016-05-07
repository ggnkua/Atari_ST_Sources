{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                                MENU DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}
program Menu_Demo;

uses GemInterface, GemAES, GemVDI;

{$I MENUS.H}

var
  RSC_name      : string;       { string containing RSC file's name     }
  MenuTree      : Tree_Ptr;     { object tree containing menu           }
  NewText       : string;       { string containing an item's new text  }

{ Let the user move around with the mouse and select menu items }
procedure MoveAround;
const
  Title         = 3;            { pipe index holding menu title no.     }
  Item          = 4;            { pipe index holding menu item no.      }
var
  pipe          : array [ 0..15 ] of integer;   { message pipe          }
  TitleStr      : string;       { text describing menu title selected   }
  ItemStr       : string;       {                      item             }
  done          : boolean;      { done = TRUE = completed moving        }
begin
  graf_mouse(M_ON, NIL);        { show the cursor (mouse)               }
  done := FALSE;
  repeat
    evnt_mesag(pipe);                   { wait for an event             }
    if pipe[0] = MN_SELECTED then begin { if it's a menu event :        }
      case pipe[Title] of
        DESK_T   : begin                { Desk title                    }
                     TitleStr := 'Desk';
                     case pipe[Item] of
                       ABOUT_I : ItemStr := 'About'     { about item    }
                     end
                   end;
        FILE_T   : begin                { File title                    }
                     TitleStr := 'File';
                     case pipe[Item] of
                       QUIT : ItemStr := 'Quit'         { quit item     }
                     end
                   end;
        EXAMPL_T : begin                { Examples title                }
                     TitleStr := 'Examples';
                     case pipe[Item] of
                       ITEM1 : ItemStr := 'Item 1';     { item 1        }
                       ITEM2 : ItemStr := 'Item 2';     { item 2        }
                       ITEM3 : ItemStr := 'Item 3';     { item 3        }
                       ITEM4 : ItemStr := 'Item 4'      { item 4        }
                     end
                   end;
      end { case }
    end;
    done := (pipe[Title] = FILE_T) and (pipe[Item] = QUIT);
    graf_mouse(M_OFF, NIL);                              { hide mouse    }
    if not done then Inform('You selected ' + TitleStr + ', ' + ItemStr);
    menu_tnormal(MenuTree, pipe[Title], 1);             { reset title   }
    graf_mouse(M_ON, NIL)                               { show mouse    }
  until done;
  graf_mouse(M_OFF, NIL)                                { hide mouse    }
end;

begin { main }
  if Init_Gem then begin
    Message('Welcome to the Menu library demonstration!');
    Message('First, we''ll have to load the MENUS.RSC file');
    RSC_name := 'MENUS.RSC'#00;                         { note the #00  }
    rsrc_load(RSC_name[1]);                             { try to load   }
    if GemError = 0 then 
      begin
        RSC_name := 'GEMDEMO\MENUS.RSC'#00;
        rsrc_load(RSC_name[1]);
        if GemError = 0 then
          ErrorCloseDown('MENUS.RSC could not be found');
      end;
      
    Message('Then determine the address of the menu tree');
    rsrc_gaddr(R_TREE, MAINMENU, MenuTree);     { get addr of main menu }

    Message('So now we''re ready to draw the menu');
    menu_bar(MenuTree, 1);                      { 1 = draw menu         }

    Inform ('Now you''re on your own! File item Quit completes');
    MoveAround;

    Message('Hope you noticed the Examples menu layout?');
    Inform ('We''ll modify it slightly now... Examine!');
    menu_icheck(MenuTree, ITEM1, 0);            { clear                 }
    menu_icheck(MenuTree, ITEM4, 1);            { set                   }
    menu_ienable(MenuTree, ITEM2, 0);           { disable               }
    menu_ienable(MenuTree, ITEM3, 1);           { enable                }
    NewText := '  Great!'#0;                    { note #0               }
    menu_text(MenuTree, ITEM1, NewText[1]);     { set new text          }
    MoveAround;

    Message('That''s all folks!');
    menu_bar(MenuTree, 0);                      { clear menu bar line   }
    rsrc_free;                          { release resource file memory  }
    Exit_Gem
  end
end.
