{ ------------------------------------------------------------ }
{ UNIT  BROWSERWINDOWS                                         }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit BROWSERWINDOWS implements windows that display the  }
{ contents of a file.                                          }
{ ------------------------------------------------------------ }

{$R-}

unit BrowserWindows;

interface

uses TextWindows;

type
	CharArrayPtr = ^CharArray;
	CharArray = Array[0..0] of Char;

	Marker = record
		line :	LongInt;
		pos :	LongInt;
	end;

	TBrowserWindowPtr = ^TBrowserWindow;
	TBrowserWindow = object ( TTextWindow )
		textBuffer :		CharArrayPtr;
		textSize :			LongInt;
		currentPosition :	Marker;

		constructor			Init;
		function			Close : Boolean;						virtual;
		procedure			GotoPrevLine;
		procedure			GotoNextLine;
		procedure			AdjustPosition( line : LongInt );
		function			GetLineLength( line : LongInt ) : LongInt;
		function			GetLine( line : LongInt ) : String;		virtual;
		function			GetLineCount : LongInt;
		function			LoadText( path : String ) : Boolean;
	end;


{ ============================================================ }

implementation

uses Gem;

{$X+}


{ ------------------------------------------------------------ }
{ ExpandTabs expands the tab-characters of str. a tab stop is  }
{ set after each tabSize characters.                           }
{ ------------------------------------------------------------ }

function	ExpandTabs( str : String; tabSize : Integer ) : String;
var
	buffer : String;
	i, j, newLen, insBlanks : Integer;
begin
	newLen := 0;
	for i := 1 to Length( str ) do
	begin
		if str[i] <> #9 then
		begin
			Inc( newLen );
			buffer[newLen] := str[i];
		end
		else
		begin
			insBlanks := tabSize - ( newLen mod tabSize );
			for j := 1 to insBlanks do
			begin
				Inc( newLen );
				buffer[newLen] := ' ';
			end;
		end;
	end;
	buffer[0] := Char( newLen );
	ExpandTabs := buffer;
end;


{ ------------------------------------------------------------ }
{ the contructor TBrowserWindow.Init initializes the object    }
{ fields.                                                      }
{ ------------------------------------------------------------ }

constructor		TBrowserWindow.Init;
begin
	TTextWindow.Init;
	currentPosition.line := 0;
	currentPosition.pos := 0;
	textSize := 0;
	textBuffer := nil;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserWindow.Close first calls its ancestor. if }
{ it returns true the window was closed. then the text buffer  }
{ must be freed and the object fields be reset.                }
{ ------------------------------------------------------------ }

function		TBrowserWindow.Close : Boolean;
begin
	if TTextWindow.Close then
	begin
		if textBuffer <> nil then
		begin
			FreeMem( textBuffer, textSize );
			textBuffer := nil;
		end;
		currentPosition.line := 0;
		currentPosition.pos := 0;
		textSize := 0;
		Close := True;
	end
	else
		Close := False;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserWindow.GetLineCount counts the number of  }
{ lines of the current file.                                   }
{ ------------------------------------------------------------ }

function		TBrowserWindow.GetLineCount : LongInt;
var
	lc, cc : LongInt;
begin
	lc := 1;
	for cc := 1 to textSize do
	begin
		if textBuffer^[cc] = #13 then
			Inc( lc );
	end;
	GetLineCount := lc;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserWindow.GotoNextLine places the marker     }
{ currentPosition onto the start of the next line. the marker  }
{ is used to extract the text of a line.                       }
{ ------------------------------------------------------------ }

procedure		TBrowserWindow.GotoNextLine;
var
	p : LongInt;
begin
	if currentPosition.line < lineCount then
	begin
		Inc( currentPosition.line );
		p := currentPosition.pos;
		while ( p < textSize ) and ( textBuffer^[p] <> #13 ) do
			Inc( p );
		if p < textSize then
		begin
			Inc( p );
			if ( p < textSize ) and ( textBuffer^[p] = #10 ) then
				Inc( p );
		end;
		currentPosition.pos := p;
	end;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserWindow.GotoPrevLine places the marker     }
{ currentPosition onto the start of the previous line. the     }
{ marker is used to extract the text of a line.                }
{ ------------------------------------------------------------ }

procedure		TBrowserWindow.GotoPrevLine;
var
	p : LongInt;
begin
	if currentPosition.line > 0 then
	begin
		Dec( currentPosition.line );
		p := currentPosition.pos;
		Dec( p );
		if ( p > 0 ) and ( textBuffer^[p] = #10 ) then
			Dec( p );
		while ( p > 0 ) and ( textBuffer^[p-1] <> #13 )
				and ( textBuffer^[p-1] <> #10 ) do
			Dec( p );
		currentPosition.pos := p;
	end;
end;


{ ------------------------------------------------------------ }
{ the method TBrowserWindow.AdjustPosition takes care that the }
{ marker currentPosition is placed onto line. the marker is    }
{ used to extract the text of a line.                          }
{ ------------------------------------------------------------ }

procedure		TBrowserWindow.AdjustPosition( line : LongInt );
begin
	while currentPosition.line < line do
		GotoNextLine;

	while currentPosition.line > line do
		GotoPrevLine;
end;


{ ------------------------------------------------------------ }
{ TBrowserWindow.GetLineLength determines the length of line.  }
{ ------------------------------------------------------------ }

function		TBrowserWindow.GetLineLength( line : LongInt ) : LongInt;
var
	pos : LongInt;
begin
	AdjustPosition( line );
	pos := currentPosition.pos;
	while ( pos < textSize ) and ( textBuffer^[pos] <> #13 ) do
		Inc( pos );
	GetLineLength := pos - currentPosition.pos;
end;


{ ------------------------------------------------------------ }
{ TBrowserWindow.GetLine extracts the text of line using the   }
{ marker currentPosition.                                      }
{ ------------------------------------------------------------ }

function		TBrowserWindow.GetLine( line : LongInt ) : String;
var
	resString : String;
	len : LongInt;
	i : Integer;
begin
	len := GetLineLength( line );
	if len > 255 then
		len := 255;
	resString[0] := Char( len );
	for i := 1 to Integer( len ) do
		resString[i] := textBuffer^[currentPosition.pos+i-1];
	GetLine := ExpandTabs( resString, 4 );
end;


{ ------------------------------------------------------------ }
{ TBrowserWindow.LoadText loads the file path into a buffer.   }
{ ------------------------------------------------------------ }

function		TBrowserWindow.LoadText( path : String ) : Boolean;
var
	f : File;
	result : LongInt;
begin
	{$I-}
	Assign( f, path );
	Reset( f, 1 );
	if IOResult <> 0 then
		LoadText := False
	else
	begin
		textSize := FileSize( f );
		if textSize > 0 then
		begin
			GetMem( textBuffer, textSize );
			if textBuffer = nil then
				LoadText := False
			else
			begin
				BlockRead( f, textBuffer^, textSize, result );
				if result <> textSize then
				begin
					FreeMem( textBuffer, textSize );
					LoadText := False;
				end
				else
				begin
					SetName( path );
					lineCount := GetLineCount;
					vertTotal := lineCount;
					currentPosition.line := 0;
					currentPosition.pos := 0;
					LoadText := True;
				end;
			end;
		end
		else
			LoadText := False;
	end;
	{$I+}
end;


{ ------------------------------------------------------------ }
{ because we are using dynamic memory allocation and we don't  }
{ want to abort the program with a runtime error if we are     }
{ running out of memory, the initialization part of the unit   }
{ installs a user defined error handler.                       }
{ the return value 1 signals to continue the program and let   }
{ New and GetMem return a nil pointer.                         }
{ ------------------------------------------------------------ }

function	HeapErrorHandler( size : LongInt ) : Integer;
begin
	form_alert( 1, '[3][Out of memory!][OK]' );
	HeapErrorHandler := 1;
end;


begin
	HeapError := @HeapErrorHandler;
end.

{ ============================================================ }
