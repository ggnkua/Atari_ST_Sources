{-------------------------------------------------------------------------
                    HighSpeed Pascal GEM accessory demo

                         MyCalc RPN CALCULATOR DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+,F-,M 4,1,1,20}

program MyCalc;

uses GemDecl, GemAES, GemVDI, RPN;

CONST
  {$I MyCalc.I}         { get resource file constants }

type
  C_String       = packed array [0..255] of char;
  String_Ptr     = ^C_string;
  Ob_Type        = G_BOX..G_TITLE;
  Spec_Info      = RECORD
                     CASE Ob_Type OF
                       G_Box,
                       G_IBox,
                       G_BoxChar,
                       G_Text,
                       G_BoxText,       { these fields should    }
                       G_FText,         { of course be extended  }
                       G_FBoxText,      { but as the only field  }
                       G_Image,         { needed is G_String,    }
                       G_UserDef,       { this structure is per- }
                       G_Button,        { fectly suitable        }
                       G_Icon,
                       G_String,
                       G_Title          : (str : String_Ptr)
                   END;

  Object         = RECORD
                     ob_next  : Integer;        { next object in tree   }
                     ob_head  : Integer;        { parent object         }
                     ob_tail  : Integer;        { next parent on level  }
                     ob_type  : integer;        { object type           }
                     ob_flags : integer;        { flags                 }
                     ob_state : integer;        { state                 }
                     ob_spec  : Spec_Info;      { color/pointer etc.    }
                     ob_x     : integer;        { obj. rectangle size   }
                     ob_y     : integer;        { and position relative }
                     ob_w     : integer;        { to parent object      }
                     ob_h     : integer
                   END;

  Tree           = ARRAY [ 0..199 ] OF Object;  { the object tree       }
  Tree_Ptr       = ^Tree;                       { pointer to the tree   }

var
  VDI_handle    : Integer;              { GEM VDI handle (graf_handle)  }
  AES_handle    : Integer;              { GEM AES handle (appl_init)    }
  ACC_handle    : Integer;              { GEM acc. id (menu_tregister)  }
  Title         : string[14];           { '  MyCalc  '#0#0              }
  Window        : Integer;              { window handle                 }
  Quit          : Boolean;              { TRUE = exit application       }
  noRSC         : Boolean;              { TRUE = no resource file       }
  Dialog        : Tree_Ptr;             { the calculator dialog tree    }
  LastSelected  : Integer;              { index of last selected button }

                                        { event manager variables :     }
  x, y          : Integer;              { mouse x,y coordinate          }
  key           : Integer;              { keyboard key scan code        }
  button        : Integer;              { mouse button state            }
  clicks        : Integer;              { mouse button clicks           }
  kbdstate      : Integer;              { keyboard state (CTRL, ALT etc)}
  pipe          : array_16;             { GEM message pipe              }
  Xres          : Integer;              { screen x resolution (pixels)  }
  eventflags    : Integer;              { flags for evnt_multi          }
  evnt_flag     : record                { different evnt_multi flag ... }
                    wait        : Integer;      { ... setups            }
                    active      : Integer
                  end;

{ Initialize GEM (application and workstation. Accessory detection not until
  later }
procedure Init;
var
  workIn        : intin_Array;
  workOut       : workout_Array;
  i             : integer;
begin
  AES_handle := appl_init;
  if AES_handle <> -1 then begin                { -1 = error }
    VDI_handle := graf_handle(i, i, i, i);
    for i := 0 to 9 do workIn[i] := 1;  workIn[10] := 2;
    v_opnvwk(workIn, VDI_handle, workOut);
    Xres := workOut[0]
  end
  else begin
    writeln('MyCalc could not be installed');
    Halt(0)
  end
end;

procedure DeInit;
begin
  rsrc_free;                    { remove RSC file                         }
  v_clsvwk(VDI_handle);         { close workstation                       }
  appl_exit                     { exit application (no AES usage allowed) }
end;

{ Try to load the resource file. If unsuccessful, then write error message }
procedure LoadRSC;
var
  title : string;               { name of RSC file }
  i     : integer;              { dummy            }
begin
  title := 'MYCALC.RSC'#0;
  rsrc_load(title[1]);
  noRSC := GemError <= 0;
  if noRSC then 
    begin
      Insert('MYCALC\',title,1);
      rsrc_load(title[1]);
      noRSC := GemError <= 0;    
      if noRSC then
        begin
          title := '[3][MYCALC.RSC could not be found |and MyCalc can hence '
                 + 'not be |activated unless you copy the |RSC file into the'
                 + ' currently |active directory.][  Too bad!  ]'#0;
          i := form_alert(1, title[1]);
          if AppFlag then 
            begin               { terminate if application }
              v_clsvwk(VDI_handle);
              appl_exit;
              halt(0)
            end
        end
    end;    
   rsrc_gaddr(R_TREE, CALCULAT, Dialog)     { get Dialog's address }
end;


{ Open calculator window }
procedure OpenWindow;
var
  s             : String;       { alert message string  }
  i             : Integer;      { dummy                 }
  elements      : Integer;      { window elements       }
  x, y, w, h    : Integer;      { window bordr x,y,w,h  }
begin
  if noRSC then LoadRSC;  { try to load resource file again }
  if not noRSC then begin
    elements := NAME or MOVER or CLOSER;        { window elements }

{ the below is a tricky thing : All objects in an object tree are located
  relative to their parent object, i.e. the calculator dialog box (CALCULAT).
  Now, the window is ment to show itself at the middle of the screen, so we
  make a form_center to place the dialog box there, and then use wind_calc
  with the CALCULAT objects size parameters as work area input to calculate
  the window's border dimensions which we require in order to do a nice
  wind_create
}
    form_center(dialog, i, i, i, i);
    with Dialog^[CALCULAT] do wind_calc(WC_BORDER, elements, ob_x, ob_y, ob_w, ob_h, x, y, w, h);

    window := wind_create(elements, x, y, w, h);
    if window < 0 then begin    { if the AES has no more windows : }
      s := '[3][|No window for MyCalc |Close one and retry ][  Ok  ]'#0;
      i := form_alert(1, s[1])
    end
    else begin                  { a window was created successfully }
      eventflags := evnt_flag.active;

      { set window title }
      wind_set(window, WF_NAME, HiPtr(Title[1]), LoPtr(Title[1]), 0, 0);
      graf_growbox(0,0,0,0, x,y,w,h);
      wind_open(window, x, y, w, h)
    end
  end
end;

{ Redraw our window. The procedure is : If our window is not open, then exit
  otherwise get the total work area into MyArea. After this, get the first
  rectangle from the rectangle list and see if it intersects with our window.
  If it does then redraw the CALCULAT dialog with the intersecting rectangle
  as active (non-clipped) area
}
Procedure RedrawWindow;
var
  WindowRect, MyArea    : GRect;        { Using x,y,w,h system          }
  Clip                  : Array_4;      { Using x1,y1,x2,y2 system      }
begin
  if Window = -1 then exit;     { can't redraw if no window! }
  with MyArea do wind_get(Window, WF_WORKXYWH, x, y, w, h);
  with WindowRect do wind_get(Window, WF_FIRSTXYWH, x, y, w, h);
  while not EmptyRect(WindowRect) do
  begin
    if intersect(MyArea, WindowRect) then with WindowRect do
      objc_draw(Dialog, CALCULAT, $7FFF, x, y, w, h);
    with WindowRect do wind_get(Window, WF_NEXTXYWH, x, y, w, h)
  end
end;

{ Close our window }
procedure CloseWindow;
var x, y, w, h : Integer;
begin
  eventflags := evnt_flag.wait;                 { go into "wait-state"  }
  wind_get(window, WF_CURRXYWH, x, y, w, h);    { get current position  }
  graf_shrinkbox(0,0,0,0, x,y,w,h);             { shrink a box          }
  wind_close(window);                           { remove from screen    }
  wind_delete(window);                          { and RAM               }
  window := -1                                  { and indicate as closed}
end;

{ Top our window }
procedure TopWindow;
begin
  wind_set(window, WF_TOP, 0, 0, 0, 0);
  eventflags := evnt_flag.active
end;

{ Put something in the display. If in an error condition, then write the
  error message, else if inputting (Result = FALSE) then write input string
  unformatted, else write the top-of-stack value formatted }
procedure WriteDisplay(Result : boolean);
var
  s : string;
begin
  if Error <> -1 then s := ' Error ' + chr(Error + ord('0')) + #0
  else
    if result then begin
      str(TopOfStack:width:digits, s);
      s := copy(s, 1, width) + #0
    end
    else s := InputString + #0;
  move(s[1], Dialog^[SEGMENTS].ob_spec.str^, length(s));
  objc_draw(Dialog, DISPLAY, $7FFF, 0, 0, 0, 0)
end;

{ Show the help screens }
procedure ShowHelp;
var
  ScreenIndex   : 1..2;         { screen 1 or 2 is being shown          }
  Choice        : Integer;      { OK, MORE or BACK selected             }
  Dialog        : Tree_Ptr;     { the current help screen dialog tree   }
  x, y, w, h    : Integer;      { its x,y,w,h                           }

  function TestWidth : boolean;         { can't show help in low res. }
  var
    w1, w2 : integer;
    a      : Tree_Ptr;
    s      : string;
  begin
    rsrc_gaddr(R_TREE, HELPSCR1, a);    { get screen 1's width }
    w1 := a^[0].ob_w;
    rsrc_gaddr(R_TREE, HELPSCR2, a);    { and screen 2's width }
    w2 := a^[0].ob_w;
    if (w1 >= Xres) or (w2 >= Xres) then begin  { if larger than screen : }
      TestWidth := FALSE;
      s := '[3][|MyCalc can''t show any help |information in this reso- |lution. Try a higher.][ Sorry ]'#0;
      w1 := form_alert(1, s[1])
    end
    else TestWidth := TRUE
  end;

begin { ShowHelp }
  if TestWidth then begin               { only exec. if screen wide enough }
    ScreenIndex := 1;                   { first screen first            }
    repeat
      if ScreenIndex = 1                { get proper dialog address     }
        then rsrc_gaddr(R_TREE, HELPSCR1, Dialog)
        else rsrc_gaddr(R_TREE, HELPSCR2, Dialog);
      form_center(Dialog, x, y, w, h);  { center on screen              }
      with Dialog^[0] do begin
        form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
        form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);
        objc_draw(Dialog, 0, $7FFF, 0, 0, 0, 0);
        Choice := form_do(Dialog, 0);
        form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h);
        form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h)
      end;
      { deselect the button : }
      with Dialog^[Choice] do ob_state := ob_state - SELECTED;
      if ScreenIndex = 1 then ScreenIndex := 2 else ScreenIndex := 1
          { MORE and BACK are not needed and hence not used }
    until ( (ScreenIndex = 1) and (Choice = HELPOK1) ) or ( (ScreenIndex = 2) and (Choice = HELPOK2) )
  end
end;

{ Convert from a GEM resource tree index to a char value usable by the RPN
  unit }
function FormChar(index : Integer) : Char;
begin
  case index of
    ZERO        : FormChar := '0';
    ONE         : FormChar := '1';
    TWO         : FormChar := '2';
    THREE       : FormChar := '3';
    FOUR        : FormChar := '4';
    FIVE        : FormChar := '5';
    SIX         : FormChar := '6';
    SEVEN       : FormChar := '7';
    EIGHT       : FormChar := '8';
    NINE        : FormChar := '9';
    RADIX       : FormChar := '.';
    ENTERKEY    : FormChar := CR;
    DELKEY      : FormChar := BS;
    ADDKEY      : FormChar := '+';
    SUBKEY      : FormChar := '-';
    MULTKEY     : FormChar := '*';
    DIVKEY      : FormChar := '/';
    SWAPKEY     : FormChar := ')';
    SIGNKEY     : FormChar := '('
  else
    FormChar := #0      { bad value }
  end
end;

{ This is exactly the reverse to FormChar above : Convert from a character
  to a GEM resource index value }
function FormIndex(ch : Char) : Integer;
begin
  case ch of
    '0' : FormIndex := ZERO;
    '1' : FormIndex := ONE;
    '2' : FormIndex := TWO;
    '3' : FormIndex := THREE;
    '4' : FormIndex := FOUR;
    '5' : FormIndex := FIVE;
    '6' : FormIndex := SIX;
    '7' : FormIndex := SEVEN;
    '8' : FormIndex := EIGHT;
    '9' : FormIndex := NINE;
    '.' : FormIndex := RADIX;
    '+' : FormIndex := ADDKEY;
    '-' : FormIndex := SUBKEY;
    '*' : FormIndex := MULTKEY;
    '/' : FormIndex := DIVKEY;
    '(' : FormIndex := SIGNKEY;
    ')' : FormIndex := SWAPKEY;
    CR  : FormIndex := ENTERKEY;
    BS  : FormIndex := DELKEY
  else
    FormIndex := -1     { bad value }
  end
end;

procedure Handle(KBDevent : boolean);
var
  index         : Integer;      { GEM object index                      }
  dummy         : Integer;
  topwindow     : Integer;      { currently topped window's handle      }
  SetButton     : boolean;      { TRUE = a mouse button is pressed      }
begin
  SetButton := button = 1;      { determine if button was pressed       }
  if SetButton then             { if so, then wait until it's released  }
    repeat
      graf_mkstate(x, y, button, kbdstate)
    until button = 0;

  { see if it's our window that's on the top : }
  wind_get(0, WF_TOP, topwindow, dummy, dummy, dummy);

  { if it isn't then go into wait-state and exit }
  if (window = -1) or (window <> topwindow) then eventflags := evnt_flag.wait
  else begin

    { if a key was pressed then make a GEM object index from it, otherwise
      determine (via objc_find) at which object the mouse is currently
      pointing
    }
    if KbdEvent
      then index := FormIndex(chr(lo(key)))
      else index := objc_find(Dialog, KEYBOARD, $7FFF, x, y);

    { if the mouse points at the box containing the buttons, then ignore!
      (if you don't understand why, then try to put a comment around the
       following line and move the mouse past a button)
    }
    if index = KEYBOARD then index := -1;

    { if the mouse has changed its position : }
    if (index <> LastSelected) then begin

      { deselect previously selected object }
      if LastSelected <> -1 then objc_change(Dialog, LastSelected, 0, 0, 0, 0, 0, NORMAL or SHADOWED, 1);

      { select the object at which the mouse is pointing }
      if index        <> -1 then objc_change(Dialog, index, 0, 0, 0, 0, 0, SELECTED or SHADOWED, 1);

      LastSelected := index
    end;

    { if, after all the preceeding actions, the we have a legal index and
      either a pressed key or a pressed mouse button, then see if the choice
      was the HELP soft-button. If so then show the help screen, else try
      to make a nice input to the RPN unit (FormChar) and update the display
    }
    if (index <> -1) and (SetButton or KBDevent) then begin
      if index = HELPKEY then ShowHelp
      else begin
        CharInput(FormChar(index));
        WriteDisplay(InputString = '')
      end
    end
  end
end;

{ This is the GEM pipe message handler. It takes appropriate action when the
  AES has placed a message in our pipe
}
Procedure HandleMsg;
var x, y, w, h : Integer;       { temporary coordinates         }
begin
  case Pipe[0] of
    AC_OPEN   : if Pipe[4] = ACC_handle then
                  if window = -1 then OpenWindow else TopWindow;
    AC_CLOSE  : if Pipe[3] = ACC_handle then Window := -1;
    WM_REDRAW : RedrawWindow;
    WM_TOPPED : TopWindow;
    WM_CLOSED : begin
                  if Pipe[3] = Window then CloseWindow;
                  Quit := AppFlag       { don't quit if an accessory }
                end;
    WM_MOVED  : if Pipe[3] = Window then begin
                  wind_get(window, WF_CURRXYWH, x, y, w, h);
                  graf_movebox(w, h, x, y, Pipe[4], Pipe[5]);
                  wind_set(Window, WF_CURRXYWH,
                           Pipe[4], Pipe[5], Pipe[6], Pipe[7]);
                  { update the dialog box' position in accordance with the
                    window's new position
                  }
                  with Dialog^[CALCULAT]
                    do wind_get(window, WF_WORKXYWH, ob_x, ob_y, ob_w, ob_h)
                end
    end
end;

{ This is the main loop, where MyCalc waits for something to happen.
  evnt_multi looks for two different sets of events, depending on the current
  state of the program. If it is in "wait-state" it only waits for a message
  via the pipe. In its second, active, state it waits for message events,
  mouse events and keyboard events. The below defines the state depending on
  the environment :

  GEM environment                       state
  -------------------------------------------
  MyCalc window closed                  wait
  window opened and on top              active
  window open, but not on top           wait
  window topped                         active

  This scheme is implemented to minimize MyCalc's request for CPU time. If
  it wasn't you would experience "slow" - sometimes none at all - response
  to mouse button activations
}
Procedure EventLoop;
var event : Integer;    { Coded value containing event flags    }
begin
  event := evnt_multi(eventflags,
                    0, 0, 0,
                    0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0,
                    Pipe,
                    0, 0,
                    x, y, button, kbdstate, key, clicks);

  { at this point, something has happened, so we tell GEM that we're updating
    the screen (disregarding the fact that we just might not after all) }
  wind_update(BEG_UPDATE);

  { determine which events had happned. By using an if...then...else if...
    structure like the below, only one type of (perhaps concurrent) events
    are allowed to influence MyCalc. Furthermore, this implements a priority
    scheme in which ordinary messages (MU_MESAG) are at the highest level,
    after which we look at the keyboard (MU_KEYBD) and finally at the mouse
    (MU_BUTTON)
  }
  if (event and MU_MESAG) <> 0 then HandleMsg
  else if (event and MU_KEYBD) <> 0
       then if key = Esc then begin
              Quit := AppFlag;
              CloseWindow
            end
            else Handle(TRUE)   { TRUE = keyboard event }
       else if (event and MU_BUTTON) <> 0 then Handle(FALSE);
  wind_update(END_UPDATE)       { done updating }
end;

{ And then to the main program! It inits the some of the global variables
  and - if the program was started as ACC - tries to install MyCalc.
  Otherwise the program runs as application, i.e. opens the window, waits
  for the user to operate, and upon ESC, closes the window and exits
}
begin { main }
  Title            := '  MyCalc  '#0#0;
  Quit             := FALSE;
  noRSC            := FALSE;
  LastSelected     := -1;
  window           := -1;
  evnt_flag.wait   := MU_MESAG;
  evnt_flag.active := MU_MESAG or MU_KEYBD or MU_BUTTON;
  Init;
  if AppFlag then begin                 { application (.PRG) }
    LoadRSC;
    wind_update(BEG_UPDATE);
    graf_mouse(ARROW, NIL);
    OpenWindow;
    wind_update(END_UPDATE);
    eventflags := evnt_flag.active;
    repeat
      EventLoop
    until Quit;
    DeInit
  end
  else begin                            { accessory (.ACC) }
    ACC_handle := menu_register(AES_handle, Title[1]);
    if ACC_handle > -1 then begin
      LoadRSC;
      eventflags := evnt_flag.wait;
      repeat
        EventLoop
      until false
    end
    else begin
      writeln('No accessory slot for MyCalc');
      v_clsvwk(VDI_handle);
      appl_exit
    end
  end
end.
