{ --- A Program to find strings in (multiple) files. --- }
{ --- Similar to unix grep or Norton find.           --- }
{ --- (c) 1992 Pure Software GmbH.                   --- }

{$E .TTP}                { This program takes parameters }

PROGRAM Find;

USES StrSearch, DirSearch, Dos;

CONST
	carriageReturn = #13;
	lineFeed = #10;

VAR
	options: SET OF CHAR;   { set of option chars on command line      }
	chMap:   CharMap;       { character map table for case insensitive }
	                        { and whole word search options            }


{ --- Tell people how to use this program --- }
PROCEDURE Usage;
BEGIN
	WRITELN('Usage: FIND [options] pattern filename {filename}');
	WRITELN;
	WRITELN('-C  Only print count of matching lines');
	WRITELN('-D  Search subdirectories');
	WRITELN('-I  Case insensitive search');
	WRITELN('-L  Only list file names');
	WRITELN('-W  Match whole words');
	WRITELN;
	WRITELN('Example: FIND -DIW I PP\*.PAS');
	WRITELN('this finds identifier i in all pascal files');
	WRITELN('in directory PP and its subdirectories.');
END;


{ --- Abort execution with an error message --- }
PROCEDURE Fatal(msg: STRING);
BEGIN
	WRITELN(msg);
	HALT(1);
END;


{ --- Allocate enough space and read whole file into memory --- }
FUNCTION LoadFile(fileName: STRING; VAR size: TextIndex) : CharArrayP;
VAR
	textP : CharArrayP;
	inFile : FILE OF CHAR;
	inSize, readSize: TextIndex;

BEGIN
	{$I-}
	ASSIGN(inFile, fileName);

	RESET(inFile);
	IF IOResult <> 0 THEN
		Fatal('File not found: ' + fileName);

	inSize := FileSize(inFile);

	{ To simplify later processing, dummy line ends     }
	{ are inserted at the beginning and end of the file }

	GETMEM(textP, 2 + inSize + 2);

	textP^[0] := carriageReturn;
	textP^[1] := lineFeed;

	BLOCKREAD(inFile, textP^[2], inSize, readSize);
	IF (IOResult <> 0) OR (insize <> readSize) THEN
		Fatal('Read error on: ' + fileName);

	textP^[inSize+2] := carriageReturn;
	textP^[inSize+3] := lineFeed;

	CLOSE(inFile);
	IF IOResult <> 0 THEN
		Fatal('Close error on: ' + fileName);

	LoadFile := textP;
	size := readSize + 4;

END;


{ --- Copy line containing pos into a string --- }
FUNCTION GetLine(pos: TextIndex; VAR text: CharArray) : STRING;
VAR
  startPos, endPos: TextIndex;
  len: INTEGER;
BEGIN
	startPos := pos;
	endPos := pos;
	WHILE text[startPos-1] <> lineFeed DO
		startPos := startPos - 1;
	WHILE text[endPos] <> carriageReturn DO
		endPos := endPos + 1;
	IF endPos > startPos + 255 THEN
		endPos := startPos + 255;
	len := 0;
	WHILE startPos < endPos DO BEGIN
		len := len + 1;
		GetLine[len] := text[startPos];
		startPos := startPos + 1;
	END;
	GetLine[0] := CHR(len);
END;


{ --- Count number of lines between startPos and endPos --- }
FUNCTION LineCnt(startPos, endPos: TextIndex; VAR text: CharArray): LONGINT;
VAR
  cnt: LONGINT;
BEGIN
	cnt := 0;
	WHILE startPos < endPos DO BEGIN
		IF text[startPos] = carriageReturn THEN
			cnt := cnt + 1;
		startPos := startPos + 1;
	END;
	LineCnt := cnt;
END;


{ --- Initialize the character map table --- }
PROCEDURE InitCharMap(VAR chMap: CharMap);
CONST
	wordChars = ['0'..'9', 'A'..'Z', 'a'..'z', '_',
	             'Ž', '™', 'š', '„', '”', ''];
VAR
	c: CHAR;
BEGIN
	FOR c := #0 TO #255 DO				{ Default: identity map }
		chMap[c] := c;

	IF 'I' IN options THEN				{ Map lower to upper case }
		FOR c := #0 TO #255 DO
			chMap[c] := UpCase(c);

	IF 'W' IN options THEN				{ Map non word chars to #0 }
		FOR c := #0 TO #255 DO
			IF NOT (c IN wordChars) THEN
				chMap[c] := #0;

END;


{ --- Search file for pattern --- }
PROCEDURE GrepFile(pattern, fileName: STRING; VAR chMap: CharMap);
VAR
	textP : CharArrayP;
	searchStart, searchRes, searchEnd : TextIndex;
	inSize : TextIndex;
	matchCnt: LONGINT;
	lineNum, lCnt: LONGINT;
BEGIN
	textP := LoadFile(fileName, inSize);

	searchStart := 0;
	lineNum := 0;
	searchEnd := inSize - LENGTH(pattern);

	searchRes := BMSearchMap(pattern, searchStart, searchEnd, textP^, chMap);

	IF 'C' IN options THEN BEGIN
		matchCnt := 0;
		WHILE searchRes < searchEnd DO BEGIN
			matchCnt := matchCnt + 1;
			searchStart := searchRes + 1;
			searchRes := BMSearchMap(pattern, searchStart, searchEnd, textP^, chMap);
		END;
		WRITELN(fileName, ' : ', matchCnt);
	END ELSE BEGIN
		IF searchRes < searchEnd THEN BEGIN
			WRITELN(fileName);
			IF NOT ('L' IN options) THEN
				REPEAT
					lCnt := LineCnt(searchStart, searchRes, textP^);
					IF lCnt <> 0 THEN BEGIN
					  lineNum := lineNum + lCnt;
						WRITELN(lineNum:4, '| ', GetLine(searchRes, textP^) );
					END;
					searchStart := searchRes + 1;
					searchRes := BMSearchMap(pattern, searchStart, searchEnd, textP^, chMap);
				UNTIL searchRes >= searchEnd;
		END;
	END;
	FreeMem(textP, inSize);
END;


{ --- Search files described by fileName for pattern --- }
PROCEDURE GrepFiles(pattern, fileName: STRING; VAR chMap: CharMap);
VAR
	matchingFiles, f : FileList;
	dir: DirStr;
	name: NameStr;
	ext: ExtStr;
	d, dList: DirList;

BEGIN
	{ Build list of directories to search }
	FSplit(fileName, dir, name, ext);
	fileName := name + ext;
	IF 'D' IN options THEN
		dList := ReadTree(dir)
	ELSE BEGIN
		NEW(dList);
		dList^.next := NIL;
		dList^.name := dir;
	END;

	{ Search matching files in list of directories }
	d := dList;
	WHILE d <> NIL DO BEGIN
		matchingFiles := ReadDir(d^.name, fileName);

		f := matchingFiles;
		WHILE f <> NIL DO BEGIN
			GrepFile(pattern, d^.name + f^.name, chMap);
			f := f^.next;
		END;

		DisposeDir(matchingFiles);
		d := d^.next;
	END;

	DisposeTree(dList);
END;


CONST
	validOptions = ['C', 'D', 'I', 'L', 'W'];

VAR
	parInx: WORD;
	i: INTEGER;
	optChar: CHAR;
	parStr, pattern: STRING;

BEGIN
	{ Call with no parameters gives usage info }
	IF ParamCount < 2 THEN BEGIN
		Usage;
		HALT;
	END;

	{ First, check all command line parameters for options }
	options := [];
	FOR parInx := 1 TO ParamCount DO BEGIN
		parStr := ParamStr(parInx);
		IF parStr[1] = '-' THEN BEGIN
			FOR i := 2 TO LENGTH(parStr) DO BEGIN
				optChar := UpCase(parStr[i]);
				IF optChar IN validOptions THEN
					options := options + [optChar]
				ELSE
					Fatal('Invalid option: ' + optChar);
			END;
		END;
	END;

	{ Of the non-option parameters, the first one
	  is the pattern, the rest are filenames }
	pattern := '';
	FOR parInx := 1 TO ParamCount DO BEGIN
		parStr := ParamStr(parInx);
		IF parStr[1] <> '-' THEN BEGIN
			IF pattern <> '' THEN
				GrepFiles(pattern, parStr, chMap)
			ELSE BEGIN
				pattern := parStr;
				IF pattern = '' THEN
					Fatal('Pattern is empty')
				ELSE BEGIN
					InitCharMap(chMap);
					IF 'W' IN options THEN
						pattern := ' ' + pattern + ' ';
				END;
			END;
		END;
	END;

END.
