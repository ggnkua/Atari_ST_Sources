{ ------------------------------------------------------------ }
{ UNIT  FILES                                                  }
{ (c) 1992 Pure Software GmbH                                  }
{                                                              }
{ the unit FILES provides some basic file operations like      }
{ executing a file selector and inquiring file parameters.     }
{ ------------------------------------------------------------ }

unit Files;

interface

function	SelectFile : String;
function	GetFilename( path : String ) : String;
function	GetFilesize( path : String ) : String;
function	GetFiledate( path : String ) : String;
function	GetFiletime( path : String ) : String;


{ ============================================================ }

implementation

uses Dos, Gem, Tos;

{$X+,V-}

{ ------------------------------------------------------------ }
{ the function SelectFile executes a file selector. the result }
{ string is the path of the selected file or an empty string.  }
{ ------------------------------------------------------------ }

function	SelectFile : String;
var
	dir, path, filename : DirStr;
	name : NameStr;
    ext : ExtStr;
	exitButton : Integer;
begin
	Dgetpath( path, 0 );
	path := FExpand( path ) + '\*.*';
	filename := '';
	fsel_input( path, filename, exitButton );
	if exitButton = 0 then
		SelectFile := ''
	else
	begin
		FSplit( path, dir, name, ext );
		SelectFile := dir + filename;
	end;
end;


{ ------------------------------------------------------------ }
{ the function GetFilename separates the file name out of the  }
{ path.                                                        }
{ ------------------------------------------------------------ }

function	GetFilename( path : String ) : String;
var
	dir : DirStr;
	name : NameStr;
    ext : ExtStr;
begin
	FSplit( path, dir, name, ext );
	GetFilename := name + ext;
end;


{ ------------------------------------------------------------ }
{ the function GetFilesize returns the size of the file        }
{ specified by path as a string.                               }
{ ------------------------------------------------------------ }

function	GetFilesize( path : String ) : String;
var
	fileRec : SearchRec;
	s : String;
begin
	Findfirst( path, AnyFile, fileRec );
	if DosError <> 0 then
		GetFilesize := ''
	else
	begin
		str( fileRec.size, s );
		GetFilesize := s;
	end;
end;


{ ------------------------------------------------------------ }
{ the function GetFiledate returns the date stamp of the file  }
{ specified by path as a string.                               }
{ ------------------------------------------------------------ }

function	GetFiledate( path : String ) : String;
var
	fileRec : SearchRec;
	ys, ms, ds : String[6];
	dt : DateTime;
begin
	Findfirst( path, AnyFile, fileRec );
	if DosError <> 0 then
		GetFiledate := ''
	else
	begin
		UnpackTime( fileRec.time, dt );
		str( dt.year, ys );
		str( dt.month, ms );
		str( dt.day, ds );
		GetFiledate := ds + '.' + ms + '.' + ys;
	end;
end;


{ ------------------------------------------------------------ }
{ the function GetFiletime returns the time stamp of the file  }
{ specified by path as a string.                               }
{ ------------------------------------------------------------ }

function	GetFiletime( path : String ) : String;
var
	fileRec : SearchRec;
	hs, ms : String[4];
	dt : DateTime;
begin
	Findfirst( path, AnyFile, fileRec );
	if DosError <> 0 then
		GetFiletime := ''
	else
	begin
		UnpackTime( fileRec.time, dt );
		str( dt.hour, hs );
		str( dt.min, ms );
		GetFiletime := hs + ':' + ms;
	end;
end;


end.

{ ============================================================ }
