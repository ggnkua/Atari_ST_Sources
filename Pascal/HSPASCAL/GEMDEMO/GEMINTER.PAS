{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                              INTERFACE UNIT

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}
unit GemInterface;

INTERFACE

uses GemDecl, GemVDI, GemAES, Bios;

const                   { object tree indices for message box   }
  FRAMEBOX      = 0;    { white, framing rectangle              }
  MSGBOX        = 1;    { white box containing message          }
  MSGSTR        = 2;    { the message string (C format)         }
  OKBUTTON      = 3;    { the "Ok" button                       }

type
  C_String       = packed array [0..255] of char;
  String_Ptr     = ^C_string;
  Ob_Type        = G_BOX..G_TITLE;
  Spec_Info      = RECORD
                     CASE Ob_Type OF
                       G_Box,
                       G_IBox,
                       G_BoxChar  : (thick : integer;
                                     color : integer);
                       G_Text,
                       G_BoxText,       { these fields should    }
                       G_FText,         { of course be extended  }
                       G_FBoxText,      { but as the only fields }
                       G_Image,         { needed are those above }
                       G_UserDef,       { and G_string, this     }
                       G_Button,        { structure is perfectly }
                       G_Icon,          { suitable               }
                       G_String,
                       G_Title    : (str : String_Ptr)
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
  workIn        : IntIn_Array;          { v_opnvwk input parameters     }
  workOut       : WorkOut_Array;        { v_opnvwk output parameters    }
  AES_handle    : Integer;              { application id                }
  VDI_handle    : Integer;              { graphics/VDI handle           }
  CharDefs      : record                { default character definitions }
                    h_char, w_char, h_box, w_box : integer
                  end;
  MinX          : integer;              { desktop area                  }
  MinY          : integer;
  MaxX          : integer;
  MaxY          : integer;
  MaxColors     : integer;
  OutputWindow  : record
                    handle         : integer;   { wind_create return    }
                    bX, bY, bW, bH : integer;   { border area           }
                    wX, wY, wW, wH : integer;   { work area             }
                    midX, midY     : integer    { work area middle      }
                  end;
  MessageBox    : Tree_Ptr;             { the message box               }

function Init_Gem : boolean;    { set up GEM (appl, workstation etc.)   }

procedure Exit_Gem;             { complete GEM usage                    }

procedure Message(s : string);  { write message, wait for Ok            }

procedure Inform(s : string);   { write message, don't wait for Ok      }

procedure ErrorCloseDown(s : string);   { fatal error, abort program    }

function MaxW : integer;        { max. width of desktop area            }

function MaxH : integer;        { max. height of desktop area           }

function Binary(s : string) : integer;  { convert s into a binary value }

procedure OpenOutputWindow;     { open predefined output window         }

procedure CloseOutputWindow;    { close output window                   }

procedure ClearOutputWindow;    { clear output window                   }

IMPLEMENTATION

var
  WindowName : string;          { name of output window (must be global)}

{ The below proc sets up the message box shown on top of the screen by
  creating an object tree with the following objects :

        FRAMEBOX        - the white box containing the message and the
                          Ok button
        MSGBOX          - a white box containing the message to output
        MSGSTR          - the message string to output (C format)
        OKBUTTON        - the Ok button

  The above fields construct a level-tree as shown below :


        FRAMEBOX
           |
           |
           v
        MSGBOX ----------> OKBUTTON
           |
           |
           v
        MSGSTR

  We havn't shown all pointers involved, but only the ones relevant for
  clarifying the tree structure.
}
procedure SetUpMessageBox;
begin
  getmem(MessageBox, 4 * SizeOf(Object));       { get memory for 4 objects }

  with MessageBox^[FRAMEBOX] do begin  { box }
    ob_w     := 50 * CharDefs.w_char;           { 50 * 4.5 chars wide box }
    ob_h     :=  4 * CharDefs.h_char + CharDefs.h_char DIV 2;
    ob_x     := (MaxX - MinX - ob_w) div 2;     { center on X axis }
    ob_y     := MinY + CharDefs.h_char div 2;   { a bit down on the Y axis }
    ob_next  := -1;     { these three fields must be set to -1, as the }
    ob_head  := -1;     { objc_add procedure used later will get con-  }
    ob_tail  := -1;     { fused otherwise! }
    ob_type  := G_BOX;  { this object is a box }
    ob_flags := NONE;           { no flags are set }
    ob_state := OUTLINED;       { it's outlined }
    ob_spec.color := WHITE;     { white background }
    MinY := ob_y + ob_h + 4     { protect message box }
  end;

  with MessageBox^[MSGBOX] do begin  { white box containing message string }
    ob_x     := 0;      { rel. position to parent (FRAMEBOX) = upper }
    ob_y     := 0;      { left corner                                }
    ob_w     := 50 * CharDefs.w_char;   { 50 * 2 chars wide }
    ob_h     :=  2 * CharDefs.h_char;
    ob_next  := -1;
    ob_head  := -1;
    ob_tail  := -1;
    ob_type  := G_BOX;
    ob_flags := NONE;
    ob_state := NORMAL;
    ob_spec.color := WHITE
  end;
  objc_add(MessageBox, FRAMEBOX, MSGBOX);

        { the objc_add makes the MSGBOX a child of the FRAMEBOX }

  with MessageBox^[MSGSTR] do begin  { message string }
    ob_x     := CharDefs.w_char div 2;
    ob_y     := 0;
    ob_w     := 50 * CharDefs.w_char;
    ob_h     :=  2 * CharDefs.h_char;
    ob_next  := -1;
    ob_head  := -1;
    ob_tail  := -1;
    ob_type  := G_STRING;
    ob_flags := NONE;
    ob_state := NORMAL;
    getmem(ob_spec.str, 50);
    ob_spec.str^[0] := #0
  end;
  objc_add(MessageBox, MSGBOX, MSGSTR);

        { objc_add makes the MSGSTR a child of MSGBOX, which is again }
        { a child of the FRAMEBOX }

  with MessageBox^[OKBUTTON] do begin  { OK button }
    ob_x     := 40 * CharDefs.w_char;
    ob_y     :=  3 * CharDefs.h_char;
    ob_w     :=  8 * CharDefs.w_char;
    ob_h     := CharDefs.h_char;
    ob_next  := -1;
    ob_head  := -1;
    ob_tail  := -1;
    ob_type  := G_BUTTON;
    ob_flags := SELECTABLE + DEFAULT + F_EXIT + LASTOB;
    ob_state := NORMAL;
    getmem(ob_spec.str, 2 + 1);         { reserve space for the string }
    ob_spec.str^[0] := 'O';             { make the string }
    ob_spec.str^[1] := 'k';
    ob_spec.str^[2] := #0
  end;
  objc_add(MessageBox, FRAMEBOX, OKBUTTON);

        { objc_add makes the OKBUTTON a child of the FRAMEBOX }

  objc_draw(MessageBox, FRAMEBOX, $7FFF, 0, 0, 0, 0)

        { objc_draw draws the FRAMEBOX with all levels ($7FFF = more
          levels than a 520 ST would have room for in its memory -
          when using a such big number, we make 101% sure that all
          of the object tree really IS drawn). The four 0's tell that
          no clipping should be used
        }

end;

function Init_Gem : boolean;
var
  i : integer;
  s : string;
begin
  AES_handle := appl_init;      { get AES id }

  if AES_handle >= 0 then begin
    for i := 0 to 9 do WorkIn[i] := 1;  { set some defaults }
    WorkIn[10] := 2;                    { use Raster Coordinates (RC) }

    with CharDefs do    { get a VDI handle and font information }
      VDI_handle := graf_handle(w_char, h_char, w_box, h_box);

    v_opnvwk(WorkIn, VDI_handle, WorkOut);      { open virtual workstation }

    graf_mouse(ARROW, NIL);             { make mouse cursor an arrow }

    { now we determine the available desktop area at our disposal }
    wind_get(0, WF_FULLXYWH, MinX, MinY, MaxX, MaxY);
    { the 0 makes wind_get return FULLXYWH information about the desktop }

    inc(MaxX, MinX);  inc(MaxY, MinY);  { adjust MaxX and MaxY }

    if MaxX - MinX < 51 * CharDefs.w_char then begin
      s := '[3][ | The demo won''t run on screens | with less than 51 characters | per line ][  Sorry  ]'#00;
      i := form_alert(1, s[1]);
      Exit_Gem;
      halt(0)
    end;

    if GetRez < 2 then begin
      s := '[1][|The demo looks best in |high resolution, but can |run in medium too][   Ok   ]'#00;
      i := form_alert(1, s[1])
    end;

    MaxColors := WorkOut[39];
    graf_mouse(M_OFF, NIL);
    Init_Gem := TRUE
  end
  else Init_Gem := FALSE
end;

procedure Exit_Gem;
begin
  if MessageBox <> NIL          { remove the message box }
    then FreeMem(MessageBox, 4 * SizeOf(Object));
  graf_mouse(M_ON, NIL);
  v_clsvwk(VDI_handle);         { close virtual workstation }
  appl_exit                     { end AES usage }
end;

procedure Message(s : string);
var
  SelectedItem : Integer;       { the item that the user selected  }
begin                           { (here, it equals OKBUTTON)       }
  if MessageBox = NIL then SetUpMessageBox;
  MessageBox^[OKBUTTON].ob_state := NORMAL;      { deselect button }
  objc_draw(MessageBox, OKBUTTON, $7FFF, 0, 0, 0, 0); { redraw button }
  s := copy(s, 1, 49);                           { truncate string }
  s := s + #0;                                   { make "C" string }
  move(s[1], MessageBox^[MSGSTR].ob_spec.str^, length(s));  { move it   }
  objc_draw(MessageBox, MSGBOX, $7FFF, 0, 0, 0, 0); { draw message }
  graf_mouse(M_ON, NIL);
  SelectedItem := form_do(MessageBox, 0);        { wait for "Ok"   }
  graf_mouse(M_OFF, NIL)
end;

procedure Inform(s : string);
var
  SelectedItem : integer;
begin
  if MessageBox = NIL then SetUpMessageBox;
  objc_draw(MessageBox, FRAMEBOX, 0, 0, 0, 0, 0);      { draw white box   }
  s := copy(s, 1, 49) + #0;
  move(s[1], MessageBox^[MSGSTR].ob_spec.str^, length(s));
  objc_draw(MessageBox, MSGBOX, $7FFF, 0, 0, 0, 0)     { draw all of message (box and str) }
end;

procedure ErrorCloseDown(s : string);
var i : integer;
begin
  s := '[3][ ' + s + '][ Abort ]'#00;
  graf_mouse(M_OFF, NIL);
  i := form_alert(1, s[1]);
  graf_mouse(M_ON, NIL);
  Exit_Gem;
  halt(0)
end;

function MaxW : integer;
begin
  MaxW := MaxX - MinX
end;

function MaxH : integer;
begin
  MaxH := MaxY - MinY
end;

function Binary(s : string) : integer;
var
  n, i : integer;
begin
  n := 0;
  for i := 1 to length(s) do
    if s[i] in ['0', '1'] then n := n*2 + ord(s[i]) - ord('0');
  Binary := n
end;

procedure OpenOutputWindow;
var p : Array_4;
begin
  with OutputWindow do begin
    bX := MinX + 10;  bY := MinY + 10;
    bW := MaxW - 20;  bH := MaxH - 20;
    handle := wind_create(NAME, bX, bY, bW, bH);
    wind_set(handle, WF_NAME, HiPtr(WindowName[1]), LoPtr(WindowName[1]), 0, 0);
    wind_open(handle, bX, bY, bW, bH);
    wind_calc(WC_WORK, NAME, bX, bY, bW, bH, wX, wY, wW, wH);
    midX := wX + wW div 2;
    midY := wY + wH div 2
  end;
  ClearOutputWindow
end;

procedure CloseOutputWindow;
begin
  with OutputWindow do begin
    wind_close(handle);
    wind_delete(handle)
  end
end;

procedure ClearOutputWindow;
var
  p : Array_4;
  a : Array_5;
begin
  vqf_attributes(VDI_handle, a);
  with OutputWindow do begin
    p[0] := wX;
    p[1] := wY;
    p[2] := wX + wW - 1;
    p[3] := wY + wH - 1;
    vs_clip(VDI_handle, 1, p);
    vsf_color(VDI_handle, White);
    vsf_interior(VDI_handle, Solid);
    vr_recfl(VDI_handle, p)
  end;
  vsf_color(VDI_handle, a[1]);
  vsf_interior(VDI_handle, a[0])
end;

begin { of unit }
  MessageBox := NIL;            { no message box made yet }
  WindowName := ' Output '#00#00
end.
