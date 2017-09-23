{ ------------------------------------------------------------ }
{ UNIT  TEXTWINDOWS                                            }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit TextWindows provides a window object that is        }
{ capable to deal with text lines.                             }
{ ------------------------------------------------------------ }

unit TextWindows;

interface

uses Windows;

type
	TTextWindowPtr = ^TTextWindow;
	TTextWindow = object ( TWindow )
		columnCount :		Integer;
		lineCount :			LongInt;
		firstColumn :		Integer;
		firstLine :			LongInt;
		visibleColumns :	Integer;
		visibleLines :		LongInt;

		constructor			Init;
		procedure			ClearRestOfLine( line : LongInt; startCol : Integer );
		procedure			WriteLine( line : LongInt );
		procedure			Scroll( horiz, vert : Integer );
		procedure			SetSlidersAndRedraw;
		function			GetLine( line : LongInt ) : String;		virtual;
		procedure			SetSize( w, h : Integer ); 				virtual;
		procedure			SetFirstLine( newFirstLine : LongInt );	virtual;
		procedure			SetFirstColumn( newFirstColumn : Integer );	virtual;
		procedure			DrawContents;							virtual;
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
	end;


{ ============================================================ }

implementation

uses GemInit, Gem;

{$X+}

var
	dummy : Integer;


{ ------------------------------------------------------------ }
{ the contructor intializes the object fields.                 }
{ ------------------------------------------------------------ }

constructor		TTextWindow.Init;
begin
	TWindow.Init;
	columnCount := 256;
	horizTotal := columnCount;
	lineCount := 0;
	firstColumn := 0;
	firstLine := 0;
	visibleLines := 0;
	visibleColumns := 0;
end;


{ ------------------------------------------------------------ }
{ this is a dummy method that always returns an empty string.  }
{ descendants will override this method to return the text of  }
{ the corresponding line.                                      }
{ ------------------------------------------------------------ }

function		TTextWindow.GetLine( line : LongInt ) : String;
begin
	GetLine := '';
end;


{ ------------------------------------------------------------ }
{ for text windows this method calculates the number of        }
{ visible lines and columns and then calls the ancestor.       }
{ ------------------------------------------------------------ }

procedure		TTextWindow.SetSize( w, h : Integer );
begin
	visibleLines := h div GemInit.charHeight;
	if h mod GemInit.charHeight <> 0 then
		Inc( visibleLines );
	vertVisible := visibleLines;
	visibleColumns := w div GemInit.charWidth;
	if w mod GemInit.charWidth <> 0 then
		Inc( visibleColumns );
	horizVisible := visibleColumns;
	TWindow.SetSize( w, h );
end;


{ ------------------------------------------------------------ }
{ this method clears the rest of line beginning form column    }
{ startCol (if startCol is 0 the whole line will be cleared).  }
{ attention: ClearRestOfLine takes window relative parameters! }
{ ------------------------------------------------------------ }

procedure		TTextWindow.ClearRestOfLine( line : LongInt; startCol : Integer );
var
	pxyarray : ARRAY_4;
begin
	begin
		pxyarray[0] := innerFrame.x + startCol * GemInit.charWidth;
		pxyarray[1] := innerFrame.y + line * GemInit.charHeight;
		pxyarray[2] := innerFrame.x + innerFrame.w - 1;
		pxyarray[3] := pxyarray[1] + GemInit.charHeight - 1;
		vr_recfl( GemInit.vdiHandle, pxyarray );
	end
end;


{ ------------------------------------------------------------ }
{ the method TTextWindow.WriteLine prints a line.              }
{ ------------------------------------------------------------ }

procedure		TTextWindow.WriteLine( line : LongInt );
var
	x, y : Integer;
	len : Integer;
	str : String;
begin
	if line >= lineCount then
		ClearRestOfLine( line - firstLine, 0 )
	else
	begin
		str := Copy( GetLine( line ), firstColumn + 1, visibleColumns );
		len := Length( str );
		if len > 0 then
		begin
			x := innerFrame.x;
			y := innerFrame.y + ( line - firstLine ) * GemInit.charHeight;
			v_gtext( GemInit.vdiHandle, x, y, str );
		end;
		if len < visibleColumns then
			ClearRestOfLine( line - firstLine, len );
	end;
end;


{ ------------------------------------------------------------ }
{ the method TTextWindow.Scroll scrolls the window contents    }
{ horiz columns and vert lines. negative values indicate       }
{ upward respectively left hand movement. the sliders are set  }
{ automatically.                                               }
{ ------------------------------------------------------------ }

procedure		TTextWindow.Scroll( horiz, vert : Integer );
var
	screenMFDB : MFDB;
	pxyarray : ARRAY_8;
	clipArray : ARRAY_4;
	height : Integer;
	l, line : LongInt;
begin
	if ( horiz <> 0 ) and ( vert <> 0 ) then
		SetSlidersAndRedraw
	else if horiz <> 0 then
	begin
		Redraw;
		SetHorizSlider;
	end
	else if vert <> 0 then
	begin
		if ( not IsTop ) or ( abs( vert ) >= visibleLines ) then
			Redraw
		else
		begin
			pxyarray[0] := innerFrame.x;
			pxyarray[2] := innerFrame.x + innerFrame.w - 1;
			pxyarray[4] := innerFrame.x;
			pxyarray[6] := innerFrame.x + innerFrame.w - 1;
			height := abs( vert ) * GemInit.charHeight;
			if vert > 0 then
			begin
				line := firstLine + visibleLines - vert - 1;
				pxyarray[1] := innerFrame.y + height;
				pxyarray[3] := innerFrame.y + innerFrame.h - 1;
				pxyarray[5] := innerFrame.y;
				pxyarray[7] := innerFrame.y + innerFrame.h - 1 - height;
			end
			else
			begin
				line := firstLine;
				pxyarray[1] := innerFrame.y;
				pxyarray[3] := innerFrame.y + innerFrame.h - 1 - height;
				pxyarray[5] := innerFrame.y + height;
				pxyarray[7] := innerFrame.y + innerFrame.h - 1;
			end;
			wind_update( BEG_UPDATE );
			graf_mouse( M_OFF, nil );
			screenMFDB.fd_addr := nil;
			vro_cpyfm( GemInit.vdiHandle, 3, pxyarray, screenMFDB, screenMFDB );
			clipArray[0] := innerFrame.x;
			clipArray[1] := innerFrame.y;
			clipArray[2] := innerFrame.x + innerFrame.w - 1;
			clipArray[3] := innerFrame.y + innerFrame.h - 1;
			vs_clip( GemInit.vdiHandle, 1, clipArray );
			for l := line to line + abs( vert ) do
				WriteLine( l );
			vs_clip( GemInit.vdiHandle, 0, clipArray );
			graf_mouse( M_ON, nil );
			wind_update( END_UPDATE );
		end;
		SetVertSlider;
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one line upwards.   }
{ ------------------------------------------------------------ }

procedure		TTextWindow.LineUp;
begin
	if firstLine > 0 then
	begin
		SetFirstLine( firstLine - 1 );
		Scroll( 0, -1 );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one line downwards. }
{ ------------------------------------------------------------ }

procedure		TTextWindow.LineDown;
begin
	if firstLine < lineCount - visibleLines then
	begin
		SetFirstLine( firstLine + 1 );
		Scroll( 0, 1 );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one page upwards.   }
{ ------------------------------------------------------------ }

procedure		TTextWindow.PageUp;
var
	oldFirstLine : LongInt;
begin
	if firstLine > 0 then
	begin
		oldFirstLine := firstLine;
		SetFirstLine( firstLine - visibleLines );
		if firstLine < 0 then
			SetFirstLine( 0 );
		Scroll( 0, firstLine - oldFirstLine );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one page downwards. }
{ ------------------------------------------------------------ }

procedure		TTextWindow.PageDown;
var
	oldFirstLine : LongInt;
begin
	if firstLine < lineCount - visibleLines then
	begin
		oldFirstLine := firstLine;
		SetFirstLine( firstLine + visibleLines );
		if firstLine > lineCount - visibleLines then
			SetFirstLine( lineCount - visibleLines );
		Scroll( 0, firstLine - oldFirstLine );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one column to the   }
{ left.                                                        }
{ ------------------------------------------------------------ }

procedure		TTextWindow.ColumnLeft;
begin
	if firstColumn > 0 then
	begin
		SetFirstColumn( firstColumn - 1 );
		Scroll( -1, 0 );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one column to the   }
{ right.                                                       }
{ ------------------------------------------------------------ }

procedure		TTextWindow.ColumnRight;
begin
	if firstColumn < columnCount - visibleColumns then
	begin
		SetFirstColumn( firstColumn + 1 );
		Scroll( 1, 0 );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one page to the     }
{ left.                                                        }
{ ------------------------------------------------------------ }

procedure		TTextWindow.PageLeft;
var
	oldFirstColumn : Integer;
begin
	if firstColumn > 0 then
	begin
		oldFirstColumn := firstColumn;
		SetFirstColumn( firstColumn - visibleColumns );
		if firstColumn < 0 then
			SetFirstColumn( 0 );
		Scroll( firstColumn - oldFirstColumn, 0 );
	end;
end;


{ ------------------------------------------------------------ }
{ this methods scrolls the window contents one page to the     }
{ right.                                                       }
{ ------------------------------------------------------------ }

procedure		TTextWindow.PageRight;
var
	oldFirstColumn : Integer;
begin
	if firstColumn < columnCount - visibleColumns then
	begin
		oldFirstColumn := firstColumn;
		SetFirstColumn( firstColumn + visibleColumns );
		if firstColumn > columnCount - visibleColumns then
			SetFirstColumn( columnCount - visibleColumns );
		Scroll( firstColumn - oldFirstColumn, 0 );
	end;
end;


{ ------------------------------------------------------------ }
{ the DrawContents method says what is to be done to draw the  }
{ window contents. here all visible lines are printed.         }
{ ------------------------------------------------------------ }

procedure		TTextWindow.DrawContents;
var
	line : LongInt;
begin
	for line := firstLine to firstLine + visibleLines do
		WriteLine( line );
end;


{ ------------------------------------------------------------ }
{ the method TTextWindow.PosVertSlider sets the vertical       }
{ slider to the relative position relPos (range from 1 to      }
{ 1000). It calculates the new first visible line and then     }
{ calls the ancestor.                                          }
{ ------------------------------------------------------------ }

procedure		TTextWindow.PosVertSlider( relPos : Integer );
var
	newFirstLine : LongInt;
	h : LongInt;
begin
	h := LongInt( relPos ) * ( lineCount - visibleLines );
	newFirstLine := h div 1000;
	if h mod 1000 >= 500 then
		Inc( newFirstLine );
	if newFirstLine <> firstLine then
	begin
		SetFirstLine( newFirstLine );
		TWindow.PosVertSlider( relPos );
	end;
end;


{ ------------------------------------------------------------ }
{ the method TTextWindow.PosHorizSlider sets the horizontal    }
{ slider to the relative position relPos (range from 1 to      }
{ 1000). It calculates the new first visible column and then   }
{ calls the ancestor.                                          }
{ ------------------------------------------------------------ }

procedure		TTextWindow.PosHorizSlider( relPos : Integer );
var
	newFirstCol : Integer;
	h : LongInt;
begin
	h := LongInt( relPos ) * ( columnCount - visibleColumns );
	newFirstCol := h div 1000;
	if h mod 1000 >= 500 then
		Inc( newFirstCol );
	if newFirstCol <> firstColumn then
	begin
		SetFirstColumn( newFirstCol );
		TWindow.PosHorizSlider( relPos );
	end;
end;


{ ------------------------------------------------------------ }
{ the method TTextWindow.KeyPressed handles keyboard input.    }
{ ------------------------------------------------------------ }

procedure		TTextWindow.KeyPressed( keycode : Integer );
begin
	case keyCode of
	Home:
		begin
			SetFirstLine( 0 );
			SetFirstColumn( 0 );
			SetSlidersAndRedraw;
		end;

	Shift_Home:
		begin
			SetFirstLine( lineCount - visibleLines );
			SetFirstColumn( 0 );
			SetSlidersAndRedraw;
		end;

	Cur_Up:
		LineUp;

	Cur_Down:
		LineDown;

	Shift_CU:
		PageUp;

	Shift_CD:
		PageDown;

	Cur_Left:
		ColumnLeft;

	Cur_Right:
		ColumnRight;

	Shift_CL:
		PageLeft;

	Shift_CR:
		PageRight;

	else
		TReceiver.KeyPressedMessage( keycode );

	end;
end;


{ ------------------------------------------------------------ }
{ this method redraws the window contents and sets both        }
{ sliders.                                                     }
{ ------------------------------------------------------------ }

procedure		TTextWindow.SetSlidersAndRedraw;
begin
	Redraw;
	SetHorizSlider;
	SetVertSlider;
end;


{ ------------------------------------------------------------ }
{ this method assigns a new value to the firstLine field. it   }
{ also changes the vertStart field of the TWindow object. this }
{ is a good example for data encapsulation.                    }
{ ------------------------------------------------------------ }

procedure		TTextWindow.SetFirstLine( newFirstLine : LongInt );
begin
	firstLine := newFirstLine;
	vertStart := firstLine;
end;


{ ------------------------------------------------------------ }
{ this method assigns a new value to the firstColumn field. it }
{ also changes the horizStart field of the TWindow object.     }
{ this is another good example for data encapsulation.         }
{ ------------------------------------------------------------ }

procedure		TTextWindow.SetFirstColumn( newFirstColumn : Integer );
begin
	firstColumn := newFirstColumn;
	horizStart := firstColumn;
end;


{ ------------------------------------------------------------ }
{ the unit initializes the vdi output for its own purposes.    }
{ ------------------------------------------------------------ }

begin
	vsf_interior( GemInit.vdiHandle, 0 );
	vsf_style( GemInit.vdiHandle, 0 );
	vst_alignment( GemInit.vdiHandle, 0, 5, dummy, dummy );
end.

{ ============================================================ }
