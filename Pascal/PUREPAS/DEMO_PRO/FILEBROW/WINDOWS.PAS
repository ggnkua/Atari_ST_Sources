{ ------------------------------------------------------------ }
{ UNIT  WINDOWS                                                }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit windows provides a generic window object that is    }
{ capable to handle some of the daily window routine.          }
{ ------------------------------------------------------------ }

unit Windows;

interface

uses Receiver;

type
	Rect = record
		x, y, w, h :		Integer;
	end;

	TWindowPtr = ^TWindow;
	TWindow = object ( TReceiver )
		winHandle :			Integer;
		innerFrame :		Rect;
		outerFrame :		Rect;
		prevFrame :			Rect;
		fullFrame :			Rect;
		isVisible :			Boolean;
		fullFlag :			Boolean;
		winName :			String;
		horizTotal :		LongInt;
		horizVisible :		LongInt;
		horizStart :		LongInt;
		vertTotal :			LongInt;
		vertVisible :		LongInt;
		vertStart :			LongInt;

		constructor			Init;
		destructor			Done;
		procedure			RedrawMessage( handle : Integer );		virtual;
		procedure			CloseMessage( handle : Integer );		virtual;
		procedure			MoveMessage( handle, x, y : Integer );	virtual;
		procedure			SizeMessage( handle, w, h : Integer );	virtual;
		procedure			FullMessage( handle : Integer );		virtual;
		procedure			LineUpMessage( handle : Integer );		virtual;
		procedure			LineDownMessage( handle : Integer );	virtual;
		procedure			PageUpMessage( handle : Integer );		virtual;
		procedure			PageDownMessage( handle : Integer );	virtual;
		procedure			PageLeftMessage( handle : Integer );	virtual;
		procedure			PageRightMessage( handle : Integer );	virtual;
		procedure			ColumnLeftMessage( handle : Integer );	virtual;
		procedure			ColumnRightMessage( handle : Integer );	virtual;
		procedure			HorizSliderMessage( handle, relPos : Integer );	virtual;
		procedure			VertSliderMessage( handle, relPos : Integer );	virtual;
		procedure			KeyPressedMessage( keycode : Integer );	virtual;
		procedure			SetPosition( x, y : Integer );			virtual;
		procedure			GetPosition( var x, y : Integer );
		procedure			GetSize( var w, h : Integer );
		procedure			SetSize( w, h : Integer ); 				virtual;
		function			GetName : String;
		procedure			SetName( name : String );
		procedure			SetHorizSlider;
		procedure			SetVertSlider;
		function			Open( x, y, w, h : Integer ) : Boolean;	virtual;
		procedure			DrawContents;							virtual;
		function			IsTop : Boolean;
		procedure			Redraw;									virtual;
		function			Close : Boolean;						virtual;
		procedure			LineUp;									virtual;
		procedure			LineDown;								virtual;
		procedure			PageUp;									virtual;
		procedure			PageDown;								virtual;
		procedure			PageLeft;								virtual;
		procedure			PageRight;								virtual;
		procedure			ColumnLeft;								virtual;
		procedure			ColumnRight;							virtual;
		procedure			PosVertSlider( relPos : Integer );		virtual;
		procedure			PosHorizSlider( relPos : Integer );		virtual;
		procedure			KeyPressed( keycode : Integer );		virtual;

	private
		buffer :			String;

	end;


{ ============================================================ }

implementation

{$X+}

uses	Gem, GemInit;

const
	winKind = NAME or CLOSER or FULLER or MOVER or SIZER
				or UPARROW or DNARROW or VSLIDE
				or LFARROW or RTARROW or HSLIDE;
	minWidth = 100;
	minHeight = 100;

var
	maxFrame : Rect;


{ ------------------------------------------------------------ }
{ this procedure converts inner frames to outer frames.        }
{ ------------------------------------------------------------ }

procedure	OuterToInnerFrame( var outerFrame, innerFrame : Rect ); forward;

procedure	InnerToOuterFrame( var innerFrame, outerFrame : Rect );
begin
	wind_calc( WC_BORDER, winKind, innerFrame.x, innerFrame.y, innerFrame.w, innerFrame.h,
				outerFrame.x, outerFrame.y, outerFrame.w, outerFrame.h );
	if outerFrame.x < maxFrame.x then
	begin
		outerFrame.x := maxFrame.x;
		OuterToInnerFrame( outerFrame, innerFrame );
	end;
	if outerFrame.y < maxFrame.y then
	begin
		outerFrame.y := maxFrame.y;
		OuterToInnerFrame( outerFrame, innerFrame );
	end;
end;


{ ------------------------------------------------------------ }
{ this procedure converts inner frames to outer frames.        }
{ ------------------------------------------------------------ }

procedure	OuterToInnerFrame( var outerFrame, innerFrame : Rect );
begin
	wind_calc( WC_WORK, winKind, outerFrame.x, outerFrame.y, outerFrame.w, outerFrame.h,
				 innerFrame.x, innerFrame.y, innerFrame.w, innerFrame.h );
	if innerFrame.w < minWidth then
	begin
		innerFrame.w := minWidth;
		InnerToOuterFrame( innerFrame, outerFrame );
	end;
	if innerFrame.h < minHeight then
	begin
		innerFrame.h := minHeight;
		InnerToOuterFrame( innerFrame, outerFrame );
	end;
end;


{ ------------------------------------------------------------ }
{ the contructor TWindow.Init initializes the object fields.   }
{ ------------------------------------------------------------ }

constructor		TWindow.Init;
begin
	TReceiver.Init;
	horizTotal := 0;
	horizVisible := 0;
	horizStart := 0;
	vertTotal := 0;
	vertVisible := 0;
	vertStart := 0;
	fullFlag := False;
	winHandle := -1;
	isVisible := False;
	outerFrame := maxFrame;
	OuterToInnerFrame( outerFrame, innerFrame );
	fullFrame := innerFrame;
end;


{ ------------------------------------------------------------ }
{ the destructor TWindow.Done closes the gem window unless     }
{ already happend and afterwards frees the gem window.         }
{ ------------------------------------------------------------ }

destructor		TWindow.Done;
begin
	if isVisible then
		Close;
	TReceiver.Done;
end;


{ ------------------------------------------------------------ }
{ if the redraw message is for this window a redraw will be    }
{ started. Otherwise pass the message to the next receiver.    }
{ ------------------------------------------------------------ }

procedure		TWindow.RedrawMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.RedrawMessage( handle )
	else
		Redraw;
end;


{ ------------------------------------------------------------ }
{ if the close message is for this window it will be closed.   }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.CloseMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.CloseMessage( handle )
	else
		Close;
end;


{ ------------------------------------------------------------ }
{ if the move message is for this window it will be moved.     }
{ Otherwise pass the message to the next receiver.             }
{ Because x und y are coordinates for the outer frame they     }
{ must be converted to inner frame coordinates, because all    }
{ window methods work relative to the inner frame.             }
{ ------------------------------------------------------------ }

procedure		TWindow.MoveMessage( handle, x, y : Integer );
var
	ro, ri : Rect;
begin
	if handle <> winHandle then
		TReceiver.MoveMessage( handle, x, y )
	else
	begin
		ro.x := x;
		ro.y := y;
		ro.w := outerFrame.w;
		ro.h := outerFrame.h;
		OuterToInnerFrame( ro, ri );
		SetPosition( ri.x, ri.y );
	end;
end;


{ ------------------------------------------------------------ }
{ if the size message is for this window it will be resized.   }
{ Otherwise pass the message to the next receiver.             }
{ Because w und h are the width and height of the outer frame  }
{ they must be converted to inner frame sizes, because all     }
{ window methods work relative to the inner frame.             }
{ ------------------------------------------------------------ }

procedure		TWindow.SizeMessage( handle, w, h : Integer );
var
	ro, ri : Rect;
begin
	if handle <> winHandle then
		TReceiver.SizeMessage( handle, w, h )
	else
	begin
		ro.x := outerFrame.x;
		ro.y := outerFrame.y;
		ro.w := w;
		ro.h := h;
		OuterToInnerFrame( ro, ri );
		SetSize( ri.w, ri.h );
	end;
end;


{ ------------------------------------------------------------ }
{ if the full message is for this window it will be set to its }
{ maximum size. Otherwise pass the message to the next         }
{ receiver.                                                    }
{ ------------------------------------------------------------ }

procedure		TWindow.FullMessage( handle : Integer );
var
	newOuterFrame : Rect;
begin
	if handle <> winHandle then
		TReceiver.FullMessage( handle )
	else
	begin
		if fullFlag then
			newOuterFrame := prevFrame
		else
		begin
			wind_get( handle, WF_FULLXYWH, newOuterFrame.x, newOuterFrame.y, newOuterFrame.w, newOuterFrame.h );
			prevFrame := outerFrame;
		end;
		fullFlag := not fullFlag;
		MoveMessage( handle, newOuterFrame.x, newOuterFrame.y );
		SizeMessage( handle, newOuterFrame.w, newOuterFrame.h );
	end;
end;


{ ------------------------------------------------------------ }
{ if the line up message is for this window the contents will  }
{ be scrolled one line upwards.                                }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.LineUpMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.LineUpMessage( handle )
	else
		LineUp;
end;


{ ------------------------------------------------------------ }
{ if the line down message is for this window the contents     }
{ will be scrolled one line downwards.                         }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.LineDownMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.LineDownMessage( handle )
	else
		LineDown;
end;


{ ------------------------------------------------------------ }
{ if the page up message is for this window the contents will  }
{ be scrolled one page upwards.                                }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.PageUpMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.PageUpMessage( handle )
	else
		PageUp;
end;


{ ------------------------------------------------------------ }
{ if the page down message is for this window the contents     }
{ will be scrolled one page downwards.                         }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.PageDownMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.PageDownMessage( handle )
	else
		PageDown;
end;


{ ------------------------------------------------------------ }
{ if the page left message is for this window the contents     }
{ will be scrolled one page to the left.                       }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.PageLeftMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.PageLeftMessage( handle )
	else
		PageLeft;
end;


{ ------------------------------------------------------------ }
{ if the page right message is for this window the contents    }
{ will be scrolled one page to the right.                      }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.PageRightMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.PageRightMessage( handle )
	else
		PageRight;
end;


{ ------------------------------------------------------------ }
{ if the column left message is for this window the contents   }
{ will be scrolled one column to the left.                     }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.ColumnLeftMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.ColumnLeftMessage( handle )
	else
		ColumnLeft;
end;


{ ------------------------------------------------------------ }
{ if the column right message is for this window the contents  }
{ will be scrolled one column to the right.                    }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.ColumnRightMessage( handle : Integer );
begin
	if handle <> winHandle then
		TReceiver.ColumnRightMessage( handle )
	else
		ColumnRight;
end;


{ ------------------------------------------------------------ }
{ if the horizontal slider moved message is for this window    }
{ the contents will be adjusted to the new slider position.    }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.HorizSliderMessage( handle, relPos : Integer );
begin
	if handle <> winHandle then
		TReceiver.HorizSliderMessage( handle, relPos )
	else
		PosHorizSlider( relPos );
end;


{ ------------------------------------------------------------ }
{ if the vertical slider moved message is for this window      }
{ the contents will be adjusted to the new slider position.    }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.VertSliderMessage( handle, relPos : Integer );
begin
	if handle <> winHandle then
		TReceiver.VertSliderMessage( handle, relPos )
	else
		PosVertSlider( relPos );
end;


{ ------------------------------------------------------------ }
{ if the key pressed message is for this window the method     }
{ KeyPressed method will be called which handles keyboard      }
{ input.                                                       }
{ Otherwise pass the message to the next receiver.             }
{ ------------------------------------------------------------ }

procedure		TWindow.KeyPressedMessage( keycode : Integer );
begin
	if not IsTop then
		TReceiver.KeyPressedMessage( keycode )
	else
		KeyPressed( keycode );
end;


{ ------------------------------------------------------------ }
{ this method returns the coordinates of the upper left        }
{ corner of the inner frame of the window.                     }
{ ------------------------------------------------------------ }

procedure		TWindow.GetPosition( var x, y : Integer );
begin
	x := innerFrame.x;
	y := innerFrame.y;
end;


{ ------------------------------------------------------------ }
{ this method moves a window to the coordinates x and y.       }
{ as usually x and y represent the upper left corner of the    }
{ inner frame of the window.                                   }
{ ------------------------------------------------------------ }

procedure		TWindow.SetPosition( x, y : Integer );
begin
	innerFrame.x := x;
	innerFrame.y := y;
	InnerToOuterFrame( innerFrame, outerFrame );
	if isVisible then
		wind_set( winHandle, WF_CURRXYWH, outerFrame.x, outerFrame.y, outerFrame.w, outerFrame.h );
end;


{ ------------------------------------------------------------ }
{ this method returns the width and height of the inner frame  }
{ of the window. the inner frame is the ractangle used for     }
{ application specific output.                                 }
{ ------------------------------------------------------------ }

procedure		TWindow.GetSize( var w, h : Integer );
begin
	w := innerFrame.w;
	h := innerFrame.h;
end;


{ ------------------------------------------------------------ }
{ this method sets the inner frame width and height of the     }
{ window.                                                      }
{ ------------------------------------------------------------ }

procedure		TWindow.SetSize( w, h : Integer );
begin
	innerFrame.w := w;
	innerFrame.h := h;
	InnerToOuterFrame( innerFrame, outerFrame );
	if isVisible then
		wind_set( winHandle, WF_CURRXYWH, outerFrame.x, outerFrame.y, outerFrame.w, outerFrame.h );
	SetHorizSlider;
	SetVertSlider;
end;


{ ------------------------------------------------------------ }
{ this method returns the current window name.                 }
{ ------------------------------------------------------------ }

function		TWindow.GetName : String;
begin
	GetName := winName;
end;


{ ------------------------------------------------------------ }
{ this method sets a new window name.                          }
{ ------------------------------------------------------------ }

procedure		TWindow.SetName( name : String );
begin
	winName := name;
	if winHandle > 0 then
		WindSetTitle( winHandle, name, buffer );
end;


{ ------------------------------------------------------------ }
{ the method TWindow.SetHorizSlider sets the size and the      }
{ position of the horizontal slider.                           }
{ ------------------------------------------------------------ }

procedure		TWindow.SetHorizSlider;
var
	siz, pos : LongInt;
begin
	if horizTotal = 0 then
		siz := 1000
	else
	begin
		siz := 1000 * horizVisible div horizTotal;
		if siz > 1000 then
			siz := 1000;
	end;
	if winHandle >= 0 then
		wind_set( winHandle, WF_HSLSIZE, Integer( siz ), 0, 0, 0 );

	pos := horizTotal - horizVisible;
	if pos <> 0 then
	begin
		pos := 1000 * horizStart div pos;
		if pos > 1000 then
			pos := 1000;
	end;
	if winHandle >= 0 then
		wind_set( winHandle, WF_HSLIDE, Integer( pos ), 0, 0, 0 );
end;


{ ------------------------------------------------------------ }
{ the method TWindow.SetVertSlider sets the size and the       }
{ position of the vertical slider.                             }
{ ------------------------------------------------------------ }

procedure		TWindow.SetVertSlider;
var
	siz, pos : LongInt;
begin
	if vertTotal = 0 then
		siz := 1000
	else
	begin
		siz := 1000 * vertVisible div vertTotal;
		if siz > 1000 then
			siz := 1000;
	end;
	if winHandle >= 0 then
		wind_set( winHandle, WF_VSLSIZE, Integer( siz ), 0, 0, 0 );

	pos := vertTotal - vertVisible;
	if pos <> 0 then
	begin
		pos := 1000 * vertStart div pos;
		if pos > 1000 then
			pos := 1000;
	end;
	if winHandle >= 0 then
		wind_set( winHandle, WF_VSLIDE, Integer( pos ), 0, 0, 0 );
end;


{ ------------------------------------------------------------ }
{ this method opens a window at the coordinates x and y with   }
{ the width w and the height h and returns true if the window  }
{ could be opened.                                             }
{ ------------------------------------------------------------ }

function		TWindow.Open( x, y, w, h : Integer ) : Boolean;
begin
	winHandle := wind_create( winKind, maxFrame.x, maxFrame.y, maxFrame.w, maxFrame.h );
	if winHandle >= 0 then
	begin
		innerFrame.x := x;
		innerFrame.y := y;
		InnerToOuterFrame( innerFrame, outerFrame );
		SetSize( w, h );
		WindSetTitle( winHandle, winName, buffer );
		if wind_open( winHandle, outerFrame.x, outerFrame.y, outerFrame.w, outerFrame.h ) = 0 then
			Open := false
		else
		begin
			isVisible := true;
			wind_calc( WC_WORK, winKind, outerFrame.x, outerFrame.y, outerFrame.w, outerFrame.h,
						 innerFrame.x, innerFrame.y, innerFrame.w, innerFrame.h );
			Open := true;
		end;
	end
	else
		Open := false;
end;


{ ------------------------------------------------------------ }
{ the method DrawContents is responsible for drawing the       }
{ contents of the window. it must be overridden by the         }
{ descendants of the TWindow object.                           }
{ ------------------------------------------------------------ }

procedure		TWindow.DrawContents;
begin
end;


{ ------------------------------------------------------------ }
{ this method tests wether the  window is topmost.             }
{ ------------------------------------------------------------ }

function		TWindow.IsTop : Boolean;
var
	handle, dummy : Integer;
begin
	wind_get( 0, WF_TOP, handle, dummy, dummy, dummy );
	IsTop := handle = winHandle;
end;


{ ------------------------------------------------------------ }
{ the TWindow.Redraw method initiates the redraw of the window }
{ contents. it clips the output so that there is no danger of  }
{ destroying the screen contents.                              }
{ ------------------------------------------------------------ }

procedure		TWindow.Redraw;

	procedure	RectIntersect( r1 : Rect; var r2 : Rect );

		function	Min( a, b : Integer ) : Integer;
		begin
			if a < b then
				Min := a
			else
				Min := b;
		end;


		function	Max( a, b : Integer ) : Integer;
		begin
			if a > b then
				Max := a
			else
				Max := b;
		end;


	var
		x, y, w, h : Integer;
	begin
		x := Max( r1.x, r2.x );
		y := Max( r1.y, r2.y );
		w := Min( r1.x + r1.w, r2.x + r2.w ) - x;
		h := Min( r1.y + r1.h, r2.y + r2.h ) - y;

		r2.x := x;
		r2.y := y;
		r2.w := w;
		r2.h := h;
	end;

var
	r : Rect;
	pxyarray : ARRAY_4;
begin
	wind_update( BEG_UPDATE );
	wind_get( winHandle, WF_FIRSTXYWH, r.x, r.y, r.w, r.h );
	while ( r.w > 0 ) and ( r.h > 0 ) do
	begin
		RectIntersect( maxFrame, r );
		if ( r.w > 0 ) and ( r.h > 0 ) then
		begin
			pxyarray[0] := r.x;
			pxyarray[1] := r.y;
			pxyarray[2] := r.x + r.w - 1;
			pxyarray[3] := r.y + r.h - 1;
			vs_clip( GemInit.vdiHandle, 1, pxyarray );
			graf_mouse( M_OFF, nil );
			DrawContents;
			graf_mouse( M_ON, nil );
			vs_clip( GemInit.vdiHandle, 0, pxyarray );
		end;
		wind_get( winHandle, WF_NEXTXYWH, r.x, r.y, r.w, r.h );
	end;
	wind_update( END_UPDATE );
end;


{ ------------------------------------------------------------ }
{ this method closes a visible window and returns true if the  }
{ window was already closed or it could be closed by now. It   }
{ also resets some of the object fields for further use of the }
{ TWindow object.                                              }
{ ------------------------------------------------------------ }

function		TWindow.Close : Boolean;
begin
	wind_close( winHandle );
	wind_delete( winHandle );
	isVisible := false;
	horizTotal := 0;
	horizVisible := 0;
	horizStart := 0;
	vertTotal := 0;
	vertVisible := 0;
	vertStart := 0;
	fullFlag := False;
	Close := True;
end;


{ ------------------------------------------------------------ }
{ here are some dummy methods that will be overridden by the   }
{ descendants of TWindow.                                      }
{ ------------------------------------------------------------ }

procedure		TWindow.LineUp;
begin
end;


procedure		TWindow.LineDown;
begin
end;


procedure		TWindow.PageUp;
begin
end;


procedure		TWindow.PageDown;
begin
end;


procedure		TWindow.PageLeft;
begin
end;


procedure		TWindow.PageRight;
begin
end;


procedure		TWindow.ColumnLeft;
begin
end;


procedure		TWindow.ColumnRight;
begin
end;


{ ------------------------------------------------------------ }
{ the method TWindow.PosHorizSlider sets the horizontal slider }
{ to the relative position relPos (range from 1 to 1000) and   }
{ redraws the window contents.                                 }
{ ------------------------------------------------------------ }

procedure		TWindow.PosHorizSlider( relPos : Integer );
begin
	wind_set( winHandle, WF_HSLIDE, relPos, 0, 0, 0 );
	Redraw;
end;


{ ------------------------------------------------------------ }
{ the method TWindow.PosVertSlider sets the vertical slider    }
{ to the relative position relPos (range from 1 to 1000) and   }
{ redraws the window contents.                                 }
{ ------------------------------------------------------------ }

procedure		TWindow.PosVertSlider( relPos : Integer );
begin
	wind_set( winHandle, WF_VSLIDE, relPos, 0, 0, 0 );
	Redraw;
end;


{ ------------------------------------------------------------ }
{ this dummy method passes key strokes to the next receiver.   }
{ it may be overridden be descendants.                         }
{ ------------------------------------------------------------ }

procedure		TWindow.KeyPressed( keycode : Integer );
begin
	TReceiver.KeyPressedMessage( keycode );
end;


{ ------------------------------------------------------------ }
{ the initialization part of the unit inquires the maximum     }
{ size a window can take.                                      }
{ ------------------------------------------------------------ }

begin
	wind_get( 0, WF_WORKXYWH, maxFrame.x, maxFrame.y, maxFrame.w, maxFrame.h );
end.

{ ============================================================ }
