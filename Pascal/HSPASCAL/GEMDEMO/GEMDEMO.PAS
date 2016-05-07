{----------------------------------------------------------------------
                     HighSpeed Pascal GEM Demo Program

                              version 1.24a

                     Copyright (c) 1990 D-House I Aps
                             Transformervej 29
                              DK-2730 Herlev
                                  Denmark
                          Phone (+45) 44 53 99 84
                          Fax   (+45) 44 53 95 44

                      Programmed by Martin Eskildsen
----------------------------------------------------------------------}

{$D+}

program GEM_Demo;

uses GemDecl, GemAES, GemVDI, DemoInterface, DemoMenu, DemoWindows,
     DemoGraphs;

{ Wait for events to be present and take appropriate action }
{ pipe[3] holds the handle in case of window events         }
procedure Dispatch;
var
  pipe : array [0..15] of integer;   { message pipe }
begin
  repeat
    evnt_mesag(pipe);         { wait for an event... }
    case pipe[0] of           { take action          }
      MN_SELECTED  : HandleMenu   (pipe[3], pipe[4]);
      WM_REDRAW    : RedrawWindow (pipe[3], pipe[4], pipe[5], pipe[6], pipe[7]);
      WM_TOPPED    : TopWindow    (pipe[3]);
      WM_CLOSED    : CloseWindow  (pipe[3]);
      WM_FULLED    : FullWindow   (pipe[3]);
      WM_SIZED     : SizeWindow   (pipe[3], pipe[6], pipe[7]);
      WM_MOVED     : MoveWindow   (pipe[3], pipe[4], pipe[5])
    end
  until quit;
  CloseTopWindow;    { make sure, the windows are closed }
  CloseTopWindow
end;

begin  { main program }
  if Init_Gem then begin        { initialize                    }
    graf_mouse(ARROW, NIL);     { arrow mouse form              }
    Init_Resource;              { load and set up resources     }
    MakeGraphData;              { set up data for graphics demo }
    Dispatch;                   { handle the events until quit  }
    End_Resource;               { remove resources              }
    End_Gem                     { end GEM usage                 }
  end
  else FatalError('Could not initialize GEM properly!')
end.
