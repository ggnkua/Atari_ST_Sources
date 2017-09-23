{ ------------------------------------------------------------ }
{ UNIT  DIALOG                                                 }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit DIALOG provides some basic routines to handle       }
{ dialogs.                                                     }
{ ------------------------------------------------------------ }

unit Dialog;

interface

uses Resources;

procedure	DialogSetString( tree : TResource; index : Integer; str : String );
procedure	DialogSetText( tree : TResource; index : Integer; str : String );
function	DialogGetText( tree : TResource; index : Integer ) : String;
function	DialogExecute( tree : TResource ) : Integer;


{ ============================================================ }

implementation

uses Gem;

{$X+}

{ ------------------------------------------------------------ }
{ the procedure DialogSetString copies str into the object     }
{ index of tree. the object must be of the type G_STRING or    }
{ G_TITLE and the length of the string in the resource file    }
{ must be greater or equal the length of str.                  }
{ ------------------------------------------------------------ }

procedure	DialogSetString( tree : TResource; index : Integer; str : String );
begin
	SetFreeString( tree, index, str );
end;


{ ------------------------------------------------------------ }
{ the procedure DialogSetText copies str into the object       }
{ index of tree. the object must be of the type G_TEXT,        }
{ G_BOXTEXT, G_FTEXT or G_FBOXTEXT and the length of the       }
{ string in the resource file must be greater or equal the     }
{ length of str.                                               }
{ ------------------------------------------------------------ }

procedure	DialogSetText( tree : TResource; index : Integer; str : String );
begin
	SetPtext( tree, index, str );
end;


{ ------------------------------------------------------------ }
{ the function DialogGetText returns the text of the object    }
{ index of tree. the object must be of the type G_TEXT,        }
{ G_BOXTEXT, G_FTEXT or G_FBOXTEXT.                            }
{ ------------------------------------------------------------ }

function	DialogGetText( tree : TResource; index : Integer ) : String;
var
	resStr : String;
begin
	GetPtext( tree, index, resStr );
	DialogGetText := resStr;
end;


{ ------------------------------------------------------------ }
{ the function DialogExecute executes the dialog described by  }
{ tree. that means it shows the dialog box, handles input and  }
{ finally hides the dialog box. the index of the exit button   }
{ will be returned.                                            }
{ ------------------------------------------------------------ }

function	DialogExecute( tree : TResource ) : Integer;
var
	cx, cy, cw, ch : Integer;
	exitButton : Integer;
begin
	form_center( tree, cx, cy, cw, ch );
	form_dial( FMD_START, 0, 0, 0, 0, cx, cy, cw, ch );
	objc_draw( tree, 0, MAX_DEPTH, cx, cy, cw, ch );
	exitButton := form_do( tree, 0 );
	form_dial( FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch );
	tree^[exitButton].ob_state := tree^[exitButton].ob_state and not SELECTED;
	DialogExecute := exitButton;
end;


end.

{ ============================================================ }
