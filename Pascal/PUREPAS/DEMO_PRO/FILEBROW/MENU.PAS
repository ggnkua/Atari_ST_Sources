{ ------------------------------------------------------------ }
{ UNIT  MENU                                                   }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit menu provides a generic menu object.                }
{ ------------------------------------------------------------ }

unit Menu;

interface

uses Receiver, Resources;

type
	TMenuPtr = ^TMenu;
	TMenu = object ( TReceiver )
		menuTree :		TResource;

		constructor		Init( tree : TResource );
		destructor		Done;
		procedure		MenuHandleItem( item : Integer );				virtual;
		procedure		KeyPressedMessage( keycode : Integer );			virtual;
		procedure		MenuSelectedMessage( title, item : Integer );	virtual;
		procedure		KeyPressed( keycode : Integer );				virtual;
	end;


{ ============================================================ }

implementation

uses Gem;

{$X+}

{ ------------------------------------------------------------ }
{ the constructor TMenu.Init shows the menu tree if the        }
{ program is an application or registers it in the accessory   }
{ menu.                                                        }
{ ------------------------------------------------------------ }

constructor		TMenu.Init( tree : TResource );
begin
	TReceiver.Init;
	if appFlag then
	begin
		menuTree := tree;
		menu_bar( menuTree, 1 );
	end
end;


{ ------------------------------------------------------------ }
{ the destructor removes menu tree if the program is an        }
{ application.                                                 }
{ ------------------------------------------------------------ }

destructor		TMenu.Done;
begin
	if appFlag then
		menu_bar( menuTree, 0 );
	TReceiver.Done;
end;


{ ------------------------------------------------------------ }
{ the descandants of the generic menu object will use the      }
{ method TMenu.MenuHandleItem to react on the selection of     }
{ menu items.                                                  }
{ ------------------------------------------------------------ }

procedure		TMenu.MenuHandleItem( item : Integer );
begin
end;


{ ------------------------------------------------------------ }
{ the method TMenu.KeyPressedMessage calls the KeyPressed      }
{ method, which reacts an key strokes, if the program is an    }
{ application.                                                 }
{ ------------------------------------------------------------ }

procedure		TMenu.KeyPressedMessage( keycode : Integer );
begin
	if appFlag then
		KeyPressed( keycode )
	else
		TReceiver.KeyPressedMessage( keycode );
end;


{ ------------------------------------------------------------ }
{ the method TMenu.MenuSelectedMessage calls the               }
{ MenuHandleItem method which handles the selection of the     }
{ menu items.                                                  }
{ ------------------------------------------------------------ }

procedure		TMenu.MenuSelectedMessage( title, item : Integer );
begin
	menu_tnormal( menuTree, title, 0 );
	MenuHandleItem( item );
	menu_tnormal( menuTree, title, 1 );
end;


{ ------------------------------------------------------------ }
{ the default is to ignore key strokes. therefore the method   }
{ TMenu.KeyPressed passes key strokes to the next receiver.    }
{ descendants of TMenu may override this method.               }
{ ------------------------------------------------------------ }

procedure		TMenu.KeyPressed( keycode : Integer );
begin
	TReceiver.KeyPressedMessage( keycode );
end;


end.

{ ============================================================ }
