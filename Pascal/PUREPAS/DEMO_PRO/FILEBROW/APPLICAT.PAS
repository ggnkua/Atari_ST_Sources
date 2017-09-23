{ ------------------------------------------------------------ }
{ UNIT  APPLICATION                                            }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit application provides an object that handles all the }
{ bureaucratics a gem program is confronted with, e.g. dis-    }
{ patching gem specific event messages to receiver objects.    }
{ ------------------------------------------------------------ }

unit Application;

interface

uses Receiver;

type
	TApplicationPtr = ^TApplication;
	TApplication = object
		doneFlag :			boolean;
		name :				String;

		constructor			Init( appName : String );
		destructor			Done;
		procedure			Run;
	end;

var
	applicationPtr : TApplicationPtr;


{ ============================================================ }

implementation

{$X+}

uses	GemInit, Gem;

var
	oldExitProc : Pointer;


{ ------------------------------------------------------------ }
{ the contructor TApplication.Init sets up the object fields.  }
{ ------------------------------------------------------------ }

constructor		TApplication.Init( appName : String );
begin
	applicationPtr := @self;
	name := appName;
	doneFlag := false;
	if not appFlag then
		menu_register( GemInit.apID, '  ' + name );
end;


{ ------------------------------------------------------------ }
{ the procedure TApplication.Run dispatches incoming gem       }
{ messages to the appropriate object.                          }
{ the inner procedure EatUpKeyStrokes erases type ahead.       }
{ ------------------------------------------------------------ }

procedure		TApplication.Run;
var
	event, dummy, keycode : Integer;
	pipe : ARRAY_8;

	procedure		EatUpKeyStrokes;
	begin
		repeat
			event := evnt_multi( MU_KEYBD or MU_TIMER,
									0, 0, 0,
									0, 0, 0, 0, 0,
									0, 0, 0, 0, 0,
									pipe, 0, 0,
									dummy, dummy, dummy,
									dummy, dummy, dummy );
		until event = MU_TIMER;
	end;

begin
	while not doneFlag or not appFlag do
	begin
		EatUpKeyStrokes;
		event := evnt_multi( MU_KEYBD or MU_MESAG,
								0, 0, 0,
								0, 0, 0, 0, 0,
								0, 0, 0, 0, 0,
								pipe, 0, 0,
								dummy, dummy, dummy,
								dummy, keycode, dummy );

		if event = MU_MESAG then
		begin
			case pipe[0] of
			WM_CLOSED:
				receiverChain^.CloseMessage( pipe[3] );

			WM_FULLED:
				receiverChain^.FullMessage( pipe[3] );

			WM_HSLID:
				receiverChain^.HorizSliderMessage( pipe[3], pipe[4] );

			WM_VSLID:
				receiverChain^.VertSliderMessage( pipe[3], pipe[4] );

			WM_MOVED:
				receiverChain^.MoveMessage( pipe[3], pipe[4], pipe[5] );

			WM_SIZED:
				receiverChain^.SizeMessage( pipe[3], pipe[6], pipe[7] );

			WM_TOPPED, WM_NEWTOP:
				wind_set( pipe[3], WF_TOP, 0, 0, 0, 0 );

			WM_ARROWED:
				begin
					case pipe[4] of
					WA_UPPAGE:
						receiverChain^.PageUpMessage( pipe[3] );
						
					WA_DNPAGE:
						receiverChain^.PageDownMessage( pipe[3] );

					WA_UPLINE:
						receiverChain^.LineUpMessage( pipe[3] );

					WA_DNLINE:
						receiverChain^.LineDownMessage( pipe[3] );

					WA_LFPAGE:
						receiverChain^.PageLeftMessage( pipe[3] );

					WA_RTPAGE:
						receiverChain^.PageRightMessage( pipe[3] );

					WA_LFLINE:
						receiverChain^.ColumnLeftMessage( pipe[3] );

					WA_RTLINE:
						receiverChain^.ColumnRightMessage( pipe[3] );
					end;
				end;

			WM_REDRAW:
				receiverChain^.RedrawMessage( pipe[3] );

			MN_SELECTED:
				receiverChain^.MenuSelectedMessage( pipe[3], pipe[4] );

			AC_OPEN:
				receiverChain^.AccessoryOpenMessage;

			AC_CLOSE:
				receiverChain^.AccessoryCloseMessage;

			end;
		end
		else if event = MU_KEYBD then
			receiverChain^.KeypressedMessage( keycode );
	end;
end;


{ ------------------------------------------------------------ }
{ the destructor TApplication.Done takes care of the clean     }
{ termination of TApplication objects. Actually it is not      }
{ needed here, but descendants may use it.                     }
{ ------------------------------------------------------------ }

destructor		TApplication.Done;
begin
end;


{ ------------------------------------------------------------ }
{ this is an exit procedure to shut down gem programs          }
{ correctly. but first it restores older exit procedures.      }
{ ------------------------------------------------------------ }

procedure	ExitGemProgram;
begin
	exitProc := oldExitProc;
	ExitGem;
end;


{ ------------------------------------------------------------ }
{ the unit initialization part initializies the gem and sets   }
{ an exit procedure for the termination of gem programs.       }
{ ------------------------------------------------------------ }

begin
	if InitGem then
	begin
		oldExitProc := exitProc;
		exitProc := @ExitGemProgram;
		graf_mouse( ARROW, nil );
	end
	else
		form_alert( 1, '[3][Initialization error.|Program aborted.][OK]' );
end.

{ ============================================================ }
