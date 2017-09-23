{ ------------------------------------------------------------ }
{ PROGRAM  FILEBROWSER                                         }
{ (c) 1992 Pure Software GmbH.                                 }
{                                                              }
{ this program demonstrates how to build gem applications      }
{ using object oriented pure pascal.                           }
{ the program implements a file browser. it shows how deal     }
{ with more than one window, handle shortcuts for menu         }
{ entries, do dialogs, write accessories, etc.                 }
{ ------------------------------------------------------------ }

{$X+}

program FileBrowser;

uses Application, BrowserWindows, Menu, Dialog, Resources, Files, Gem;

const
	maxBrowsers = 4;

	{$I BROWSER.I }

type
	TBrowserMenu = object ( TMenu )
		procedure			MenuHandleItem( item : Integer );	virtual;
		procedure			KeyPressed( keycode : Integer );	virtual;
		procedure			AccessoryOpenMessage;				virtual;
		procedure			AccessoryCloseMessage;				virtual;
	end;

	TBrowserApplication = object ( TApplication )
		browserList :		Array[1..maxBrowsers] of TBrowserWindow;
		browserAvail :		Array[1..maxBrowsers] of Boolean;
		browserMenu :		TBrowserMenu;
		resourcePool :		TResourcePoolPtr;
		constructor			Init;
		destructor			Done;
		function			GetAvailableBrowser : Integer;
		function			GetTopBrowser : Integer;
		procedure			BrowserOpen;
		procedure			BrowserInfo;
		procedure			BrowserClose;
	end;

var
	browserApplication : TBrowserApplication;


{ ------------------------------------------------------------ }
{ this is the external start address of the resource file.     }
{ resource file was converted into an object file using the    }
{ utility BINOBJ, so it can be linked to the program.          }
{ BINOBJ was invoked with the commandline                      }
{     browser.rsc browser.o browserResources                   }
{ ------------------------------------------------------------ }

	procedure	browserResources; external;
	{$L BROWSER }


{ ------------------------------------------------------------ }
{ the method TBrowserMenu.MenuHandleItem switches over the     }
{ menu items and executes the corresponding action.            }
{ ------------------------------------------------------------ }

procedure	TBrowserMenu.MenuHandleItem( item : Integer );
begin
	case item of
	Menufileopen:
		browserApplication.BrowserOpen;

	Menufileclose:
		browserApplication.BrowserClose;

	Menufileinfo:
		browserApplication.BrowserInfo;

	Menufilequit:
		browserApplication.doneFlag := true;
	end;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserMenu.KeyPressed handles shortcuts for     }
{ menu items.                                                  }
{ ------------------------------------------------------------ }

procedure		TBrowserMenu.KeyPressed( keycode : Integer );
begin
	case keycode of
	Ctrl_I:
		browserApplication.BrowserInfo;

	Ctrl_O:
		browserApplication.BrowserOpen;

	Ctrl_Q:
		browserApplication.doneFlag := true;

	Ctrl_U:
		browserApplication.BrowserClose;

	else
		TReceiver.KeyPressedMessage( keycode );

	end;
end;


{ ------------------------------------------------------------ }
{ if the program runs as an accessory the method               }
{ TBrowserMenu.AccessoryOpenMessage is called when you click   }
{ the menu item of the accessory in the accessory menu.        }
{ ------------------------------------------------------------ }

procedure		TBrowserMenu.AccessoryOpenMessage;
begin
	browserApplication.BrowserOpen;
end;


{ ------------------------------------------------------------ }
{ if the program runs as an accessory the method               }
{ TBrowserMenu.AccessoryCloseMessage is called when a main     }
{ program is finished.                                         }
{ ------------------------------------------------------------ }

procedure		TBrowserMenu.AccessoryCloseMessage;
var
	i : Integer;
begin
	for i := 1 to maxBrowsers do
	begin
		browserApplication.browserList[i].Close;
		browserApplication.browserAvail[i] := true;
	end;
end;


{ ------------------------------------------------------------ }
{ the constructor TBrowserApplication.Init initializes the     }
{ ancestor application object, the linked-in resource file,    }
{ the menu and the browser windows.                            }
{ ------------------------------------------------------------ }

constructor		TBrowserApplication.Init;
var
	i : Integer;
	rs : TResource;
begin
	TApplication.Init( 'File browser' );
	resourcePool := InitResourcePool( @BrowserResources );
	rs := GetResource( resourcePool, Browsermenutree );
	browserMenu.Init( rs );
	for i := 1 to maxBrowsers do
	begin
		browserList[i].Init;
		browserAvail[i] := true;
	end;
end;


{ ------------------------------------------------------------ }
{ the destructor TBrowserApplication.Done initiates the        }
{ cleanups for the menu, the linked-in resource file and the   }
{ browser windows, as well as calling the destructor of the    }
{ ancestor.                                                    }
{ ------------------------------------------------------------ }

destructor		TBrowserApplication.Done;
var
	i : Integer;
begin
	browserMenu.Done;
	FreeResourcePool( resourcePool );
	for i := 1 to maxBrowsers do
	begin
		browserList[i].Done;
		browserAvail[i] := true;
	end;
	TApplication.Done;
end;


{ ------------------------------------------------------------ }
{ the methode TBrowserApplication.GetAvailableBrowser returns  }
{ the index of an unused window in the browser window list or  }
{ 0 if no more browsers are available.                         }
{ ------------------------------------------------------------ }

function		TBrowserApplication.GetAvailableBrowser : Integer;
var
	i : Integer;
begin
	GetAvailableBrowser := 0;
	for i := 1 to maxBrowsers do
	begin
		if browserAvail[i] then
		begin
			GetAvailableBrowser := i;
			Exit;
		end;
	end;
end;


{ ------------------------------------------------------------ }
{ the methode TBrowserApplication.GetTopBrowser returns the    }
{ index of the topmost browser window or 0 if no browsers are  }
{ opened.                                                      }
{ ------------------------------------------------------------ }

function		TBrowserApplication.GetTopBrowser : Integer;
var
	i : Integer;
begin
	GetTopBrowser := 0;
	for i := 1 to maxBrowsers do
	begin
		if ( browserList[i].winHandle >= 0 ) and browserList[i].IsTop then
		begin
			GetTopBrowser := i;
			Exit;
		end;
	end;
end;


{ ------------------------------------------------------------ }
{ TBrowserApplication.BrowserOpen opens a new browser if there }
{ is one available. it first opens a file selector to choose a }
{ file. if a file is selected a browser window will be opened. }
{ ------------------------------------------------------------ }

procedure		TBrowserApplication.BrowserOpen;
var
	index, w : Integer;
	path : String;
begin
	index := GetAvailableBrowser;
	if index > 0 then
	begin
		path := SelectFile;
		if Length( path ) > 0 then
		begin
			w := browserList[index].fullFrame.w - maxBrowsers * 30;
			if w > 600 then
				w := 600;
			if browserList[index].LoadText( path ) and
					browserList[index].Open( 20 * index, 40 * index, w,
						browserList[index].fullFrame.h - maxBrowsers * 50 ) then
			begin
				browserAvail[index] := false;
			end;
		end;
	end;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserApplication.BrowserInfo displays a dialog }
{ box showing informations about the topmost browser window.   }
{ ------------------------------------------------------------ }

procedure		TBrowserApplication.BrowserInfo;
var
	nameStr : String;
	tree : TResource;
	index : Integer;
begin
	index := GetTopBrowser;
	if index > 0 then
	begin
		tree := GetResource( resourcePool, InfoDialog );
		nameStr := browserList[index].GetName;
		DialogSetString( tree, IdFilename, GetFilename( nameStr ));
		DialogSetString( tree, IdFilesize, GetFilesize( nameStr ));
		DialogSetString( tree, IdFiledate, GetFiledate( nameStr ));
		DialogSetString( tree, IdFiletime, GetFiletime( nameStr ));
		DialogExecute( tree );
	end;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserApplication.BrowserClose closes the       }
{ topmost browser window.                                      }
{ ------------------------------------------------------------ }

procedure		TBrowserApplication.BrowserClose;
var
	index : Integer;
begin
	index := GetTopBrowser;
	if index > 0 then
	begin
		browserList[index].Close;
		browserAvail[index] := true;
	end;
end;


{ ------------------------------------------------------------ }
{ the body of the program first intializes all program         }
{ parameters and then calls the run method that performs a     }
{ loop that dispatches the occuring events. Finally it         }
{ initiates necessary cleanups.                                }
{ ------------------------------------------------------------ }

begin
	browserApplication.Init;
	browserApplication.Run;
	browserApplication.Done;
end.

{ ============================================================ }
