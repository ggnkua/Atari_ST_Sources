{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                             TEXT OUTPUT DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program Texts;

uses GemAES, GemVDI, GemDecl, GemInterface;

const
  NO            = 0;
  YES           = 1;
  CharSpace     = YES;  { use char spacing in v_justified       }
  WordSpace     = YES;  { use word spacing in v_justified       }
  TheText       = 'The Quick Brown Fox Jumps Over The Very Lazy Dog.'#00;

var
  y             : integer;      { current text y coordinate     }
  TextHeight    : integer;      { current height of text        }
  dummy         : integer;

{ Write TheText in the output window }
procedure WriteTheMessage;
begin
  inc(y, TextHeight);
  v_gtext(VDI_handle, OutputWindow.wX, y, TheText)
end;

begin { main }
  if Init_Gem then begin
    Message('Welcome to the text output demonstration!');
    Message('We''ll take a look at some different ways...');
    Message('of putting text on the screen without GDOS.');
    OpenOutputWindow;
    y          := OutputWindow.wY;      { set y coord     }
    TextHeight := CharDefs.h_Char;      { set text height }

    Message('First some normal text');
    WriteTheMessage;

    Message('Then justified to fit window');
    inc(y, TextHeight);
    v_justified(VDI_handle, OutputWindow.wX, y, { x,y           }
                TheText,                        { text to write }
                OutputWindow.wW,                { field width   }
                WordSpace, CharSpace);          { spacing flags }

    Message('Now in another size...');
    vst_height(VDI_handle, 19,                  { new height    }
               dummy, dummy, dummy, TextHeight);
    WriteTheMessage;

    Message('Style...');
    vst_effects(VDI_handle, BOLD + OUTLINE);    { set text effect }
    WriteTheMessage;

    Message('and finally in another size, style and rotation');
    vst_height(VDI_handle, 25, dummy, dummy, dummy, TextHeight);
    vst_effects(VDI_handle, SHADED);
    vst_rotation(VDI_handle, 2700); 
    WriteTheMessage;

    Message('That''s all folks!');
    CloseOutputWindow;
    Exit_Gem
  end
end.
