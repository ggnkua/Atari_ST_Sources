{ ------------------------------------------------------------ }
{ UNIT  RECEIVER                                               }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit receiver provides a mechanism to distribute arisen  }
{ events.                                                      }
{ the concept is to build a chain of receivers. if an event    }
{ arises the message will be given to the first receiver in    }
{ the chain. the receiver absorbes the message if it is for it }
{ or passes it to the next receiver.                           }
{ ------------------------------------------------------------ }

unit Receiver;

interface

type
	TReceiverPtr = ^TReceiver;
	TReceiver = object
		nextReceiver :	TReceiverPtr;

		constructor		Init;
		destructor		Done;
		procedure		RedrawMessage( handle : Integer );		virtual;
		procedure		CloseMessage( handle : Integer );		virtual;
		procedure		MoveMessage( handle, x, y : Integer );	virtual;
		procedure		SizeMessage( handle, w, h : Integer );	virtual;
		procedure		FullMessage( handle : Integer );		virtual;
		procedure		LineUpMessage( handle : Integer );		virtual;
		procedure		LineDownMessage( handle : Integer );	virtual;
		procedure		PageUpMessage( handle : Integer );		virtual;
		procedure		PageDownMessage( handle : Integer );	virtual;
		procedure		PageLeftMessage( handle : Integer );	virtual;
		procedure		PageRightMessage( handle : Integer );	virtual;
		procedure		ColumnLeftMessage( handle : Integer );	virtual;
		procedure		ColumnRightMessage( handle : Integer );	virtual;
		procedure		HorizSliderMessage( handle, relPos : Integer );	virtual;
		procedure		VertSliderMessage( handle, relPos : Integer );	virtual;
		procedure		KeyPressedMessage( keycode : Integer );	virtual;
		procedure		MenuSelectedMessage( title, item : Integer ); virtual;
		procedure		AccessoryOpenMessage;					virtual;
		procedure		AccessoryCloseMessage;					virtual;
	end;

var
	receiverChain : TReceiverPtr;


{ ============================================================ }

implementation

{$X+}

{ ------------------------------------------------------------ }
{ the contructor enters the receiver into the receiver chain   }
{ so that it will get messages by the application.             }
{ ------------------------------------------------------------ }

constructor		TReceiver.Init;
begin
	self.nextReceiver := receiverChain;
	receiverChain := @self;
end;


{ ------------------------------------------------------------ }
{ the destructor removes the receiver from the receiver chain. }
{ the receiver will get no more messages by the application.   }
{ assertion: receiver is definitely registered!                }
{ ------------------------------------------------------------ }

destructor		TReceiver.Done;
var
	n, r : TReceiverPtr;
begin
	r := @self;
	if receiverChain = r then
		receiverChain := r^.nextReceiver
	else
	begin
		n := receiverChain;
		while n^.nextReceiver <> r do
			n := n^.nextReceiver;
		n^.nextReceiver := r^.nextReceiver;
	end;
end;


{ ------------------------------------------------------------ }
{ the following methods are kind of dummy procedures that      }
{ pass the message to the next receiver until there is one.    }
{ descendants may overide the methods the are interested in.   }
{ ------------------------------------------------------------ }

procedure		TReceiver.RedrawMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.RedrawMessage( handle );
end;


procedure		TReceiver.CloseMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.CloseMessage( handle );
end;


procedure		TReceiver.MoveMessage( handle, x, y : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.MoveMessage( handle, x, y );
end;


procedure		TReceiver.SizeMessage( handle, w, h : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.SizeMessage( handle, w, h );
end;


procedure		TReceiver.FullMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.FullMessage( handle );
end;


procedure		TReceiver.LineUpMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.LineUpMessage( handle );
end;


procedure		TReceiver.LineDownMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.LineDownMessage( handle );
end;


procedure		TReceiver.PageUpMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.PageUpMessage( handle );
end;


procedure		TReceiver.PageDownMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.PageDownMessage( handle );
end;


procedure		TReceiver.PageLeftMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.PageLeftMessage( handle );
end;


procedure		TReceiver.PageRightMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.PageRightMessage( handle );
end;


procedure		TReceiver.ColumnLeftMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.ColumnLeftMessage( handle );
end;


procedure		TReceiver.ColumnRightMessage( handle : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.ColumnRightMessage( handle );
end;


procedure		TReceiver.HorizSliderMessage( handle, relPos : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.HorizSliderMessage( handle, relPos );
end;


procedure		TReceiver.VertSliderMessage( handle, relPos : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.VertSliderMessage( handle, relPos );
end;


procedure		TReceiver.KeyPressedMessage( keycode : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.KeyPressedMessage( keycode );
end;


procedure		TReceiver.MenuSelectedMessage( title, item : Integer );
begin
	if nextReceiver <> nil then
		nextReceiver^.MenuSelectedMessage( title, item );
end;


procedure		TReceiver.AccessoryOpenMessage;
begin
	if nextReceiver <> nil then
		nextReceiver^.AccessoryOpenMessage;
end;


procedure		TReceiver.AccessoryCloseMessage;
begin
	if nextReceiver <> nil then
		nextReceiver^.AccessoryCloseMessage;
end;


{ ------------------------------------------------------------ }
{ initialize the empty receiver chain.                         }
{ ------------------------------------------------------------ }

begin
	receiverChain := nil;
end.

{ ============================================================ }
