{---------------------------------------------------------------------
        GEM Interface Procedures, Variables, etc. for GEMDEMO

                Copyright (c) 1990 D-House I ApS
                       All rights reserved

                 Programmed by Martin Eskildsen
---------------------------------------------------------------------}

{$D+}

unit DemoInterface;

INTERFACE

uses GemDecl, GemAES, GemVDI, Bios;

{$I GEMDEMO.H   - read resource constants }

type
  Object   = record   { simple object type - o_spec should be extended }
               o_next, o_start, o_end    : integer;
               o_type, o_flags, o_status : integer;
               o_spec                    : Pointer;
               o_x, o_y, o_w, o_h        : integer
             end;
  Tree     = array [0..50] of Object;       { object tree }
  TreePtr  = ^Tree;

  { Currently selected graphics demo }
  DemoType = (BoxesDemo, LinesDemo, EllipsesDemo, PiesDemo);

  { WINMENU item status setting type }
  SetState = (s_enable, s_disable, s_leave);
  { s_enable  enables  a menu item;
    s_disable disables a menu item;
    s_leave   leaves   a menu item alone (no change)
  }

var
  menu          : TreePtr;      { the MEINMENU tree                 }
  about         : TreePtr;      { the ABOUTBOX dialog tree          }
  selection     : TreePtr;      { the SLCTDEMO dialog tree          }
  VDI_handle    : Integer;      { VDI handle                        }
  AES_handle    : Integer;      { application id                    }
  textwindow    : Integer;      { text window id                    }
  grafwindow    : Integer;      { graphics window id                }
  demo          : DemoType;     { currently selected graphdemo      }
  MinX, MinY    : Integer;      { smallest (x,y) a window can have  }
  MaxW, MaxH    : Integer;      { largest (w,h) a window can have   }
  quit          : boolean;      { TRUE = leave program              }
  CharBoxHeight : Integer;      { height of a character box (pixels)}
  CharHeight    : Integer;      { height of a character (pixels)    }

{ Write the message and halt the program }
procedure FatalError(message : String);

{ Initialize GEM. Returns TRUE if ok }
function Init_Gem : boolean;

{ End GEM usage }
procedure End_Gem;

{ Load and set up resorces }
procedure Init_Resource;

{ Terminate resource usage }
procedure End_Resource;

{ Set new status of an object in a tree :
    t         : object tree
    index     : object tree element
    newstatus : new object status
}
procedure SetObjectStatus(t : TreePtr; index, newstatus : Integer);

{ Set WINMENU's state :
    closecurrent        : set state of WINCLOSE
    opentextwindow      : set state of TXTOPEN
    closetextwindow     : set state of TXTCLOSE
    opengraphicswindow  : set state of GRAOPEN
    closegraphicswindow : set state of GRACLOSE
}
procedure SetMenuState(closecurrent, opentextwindow, closetextwindow,
                       opengraphicswindow, closegraphicswindow
                       : SetState);

{$F+,D-,S-,R-}

IMPLEMENTATION

procedure FatalError;
var ch : char;
begin
  writeln;
  ClrEol;  writeln;
  ClrEol;  writeln('>>> Fatal error condition arised! <<<');
  ClrEol;  writeln(message);
  ClrEol;  write('Press a key to abort...');
  ch := ReadKey;
  halt(0)
end;

function Init_Gem;
var
  workin  : IntIn_Array;   { workstation input parameters  }
  workout : workout_Array; { workstation output parameters }
  dummy   : Integer;
  s       : string;        { string holding a message      }
begin
  if Bios.GetRez < 2 then begin   { low or medium rez.     }
    s := '[0][ |Note! The icons will look a  |bit odd in this resolution.'
       + ' |High res. looks nicest |][   Ok   ]';
    dummy := form_alert(1, s[1])
  end;
  AES_handle := appl_init;        { get AES handle }
  if AES_handle >= 0 then begin   { if legal then go on : }

    { get VDI handle and height of a character and its box : }
    VDI_handle := graf_handle(CharHeight, dummy, CharBoxHeight, dummy);

    { initialize workstation input parameters : }
    for dummy := 0 to 9 do workin[dummy] := 1;
    workin[10] := 2;   { use Raster Coordinates }
    
    v_opnvwk(workin, VDI_handle, workout); { open virtual workstation }

    { get size of free desktop area : }
    wind_get(0, WF_FULLXYWH, MinX, MinY, MaxW, MaxH);
    graf_growbox(0, 0, 0, 0, MinX, MinY, MaxW, MaxH);    { nice! }
    graf_mouse(ARROW, NIL)
  end;
  Init_Gem := AES_handle >= 0           { return TRUE if init ok }
end;

procedure End_Gem;
begin
  graf_shrinkbox(0, 0, 0, 0, MinX, MinY, MaxW, MaxH);
  v_clsvwk(VDI_handle);    { close virtual workstation  }
  appl_exit                { exit application (GEMDEMO) }
end;

procedure Init_Resource;
var ResourceName : string;
begin
  ResourceName := 'GEMDEMO.RSC' + #0;   { Note #0  ! }
  rsrc_load(ResourceName[1]);           { Note [1] ! }
  if GemError = 0 then begin
    ResourceName := 'GEMDEMO\GEMDEMO.RSC'#00;
    rsrc_load(ResourceName[1]);
    if GemError = 0 then begin
      End_Gem;
      FatalError('GEMDEMO.RSC is missing!')
    end
  end;
  rsrc_gaddr(R_TREE, MAINMENU, menu);      { set menu tree ptr      }
  rsrc_gaddr(R_TREE, ABOUTBOX, about);     { set aboutbox tree ptr  }
  rsrc_gaddr(R_TREE, SLCTDEMO, selection); { set selection tree ptr }
  
  { set defaut states : }
  SetMenuState(s_disable, s_enable, s_disable, s_enable, s_disable);
  SetObjectStatus(about,     ABOUTOK,  NORMAL);
  SetObjectStatus(selection, BOXES,    SELECTED);
  SetObjectStatus(selection, LINES,    NORMAL);
  SetObjectStatus(selection, ELLIPSES, NORMAL);
  SetObjectStatus(selection, PIES,     NORMAL);
  menu_bar(menu, 1)    { draw menu }
end;

procedure End_Resource;
begin
  menu_bar(menu, 0);    { remove menu from screen }
  rsrc_free             { release memory          }
end;

procedure SetObjectStatus;
begin
  t^[index].o_status := newstatus   { quite simple... }
end;

procedure SetMenuState(closecurrent, opentextwindow, closetextwindow,
                       opengraphicswindow, closegraphicswindow
                       : SetState);

  { Change a single menu item's state }
  procedure Change(newstate : SetState; index : Integer);
  begin
    case newstate of
      s_enable  : menu_ienable(menu, index, 1);  { enable item  }
      s_disable : menu_ienable(menu, index, 0);  { disable item }
      s_leave   :                                { do nothing   }
    end
  end;

begin { SetMenuState }
  Change(closecurrent,        WINCLOSE);
  Change(opentextwindow,      TXTOPEN);
  Change(closetextwindow,     TXTCLOSE);
  Change(opengraphicswindow,  GRAOPEN);
  Change(closegraphicswindow, GRACLOSE)
end;

begin { of unit }
  demo       := BoxesDemo;   quit       := FALSE;
  textwindow := -1;          grafwindow := -1      { no open windows }
end.
