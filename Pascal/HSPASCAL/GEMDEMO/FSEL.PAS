{-------------------------------------------------------------------------
                HighSpeed Pascal GEM-interface demo program

                        FILE SELECTOR LIBRARY DEMO

                      Copyright (c) 1990 by D-House I
                            All rights reserved

                      Programmed by Martin Eskildsen
-------------------------------------------------------------------------}
{$R-,S-,D+}

program FSEL;

uses GemAES, GemVDI, GemDecl, GemInterface;

var
  path          : string;       { the path and file mask        }
  name          : string;       { the name                      }
  title         : string;       { title for fsel_exinput        }
  result        : string;       { resulting file name           }
  ExitValue     : integer;      { fsel_ exit value (OK/CANCEL)  }

procedure Decompose;
begin
  path[0] := #255;  path[0] := chr(pos(#0, path));
  name[0] := #255;  name[0] := chr(pos(#0, name));
  { turn the "C" strings into Pascal strings  ^^^              }
  { the strings above, however, still holds the #0 in the end  }
  { so before you use them, you have to strip the last char,   }
  { i.e. #0, off. This isn't done here, as we intend to use    }
  { both path and name "as is" later on.                       }
  result := path;
  while result[length(result)] <> '\'           { remove file  }
    do result[0] := chr(length(result)-1);      { spec.        }
  result := result + copy(name, 1, pos(#0, name) - 1);
  if ExitValue = 0 then result := result + ' "cancel"';
  Inform('');                           { clear message box    }
  Message(result)
end;

begin { main }
  if Init_Gem then begin
    Message('Welcome to the File Selector library demo!');

    Inform('First, the simple one: Set your own path and name');
    path := '\*.*'#0;           { default path }
    name := #0;                 { no name      }
    graf_mouse(M_ON, NIL);
    fsel_input(path[1], name[1], ExitValue);  { do fsel }
    graf_mouse(M_OFF, NIL);
    Decompose;                  { write result of fsel    }

    Inform('Now reusing your definitions of path and name...');
    graf_mouse(M_ON, NIL);
    fsel_input(path[1], name[1], ExitValue);
    graf_mouse(M_OFF, NIL);
    Decompose;

    if GemDecl.global[0] >= $140 then begin  { TOS 1.4 or higher }
      Inform('We can set our own header, like this :');
      title := 'HighSpeed Pascal!'#0;
      graf_mouse(M_ON, NIL);
      fsel_exinput(path[1], name[1], ExitValue, title[1]);
      graf_mouse(M_OFF, NIL);
      Decompose
    end
    else begin
      Inform('');               { clear message box }
      Message('Can''t show fsel_exinput with this TOS version!')
    end;

    Inform('');
    Message('That''s all folks!');
    Exit_Gem
  end
end.
