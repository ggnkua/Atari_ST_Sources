{ --- This unit provides fast string search routines --- }
{ --- (c) 1992 Pure Software GmbH.                   --- }

{$R- Range tests would be somewhat silly here... }
{    See declaration of TextIndex.               }

UNIT StrSearch;

INTERFACE

TYPE
	TextIndex		= 0..2000000000;
	CharArray		= ARRAY [TextIndex] OF CHAR;
	CharArrayP	= ^CharArray;
	CharMap			= ARRAY [CHAR] OF CHAR;


FUNCTION BMSearch(pat: STRING; startPos, endPos: TextIndex;
                  VAR text: CharArray) : TextIndex;

FUNCTION BMSearchMap(pat: STRING; startPos, endPos: TextIndex;
                     VAR text: CharArray; VAR chMap: CharMap) : TextIndex;

IMPLEMENTATION

{ --- This is the fast Boyer-Moore string search  --- }
{ --- Adapted from : N. Wirth, Algorithmen und    --- }
{ --- Datenstrukturen mit Modula-2, p. 69         --- }
FUNCTION BMSearch(pat: STRING; startPos, endPos: TextIndex;
                  VAR text: CharArray) : TextIndex;
VAR
	i, k: TextIndex;
	j: INTEGER;
	ch: CHAR;
	d: ARRAY [CHAR] OF INTEGER;

BEGIN
	FOR ch := #0 TO #255 DO
		d[ch] := LENGTH(pat);
	FOR j := 1 TO LENGTH(pat)-1 DO
		d[ pat[j] ] := LENGTH(pat)-j;

	i := startPos + LENGTH(pat);
	endPos := endPos + LENGTH(pat);
	REPEAT
		j := LENGTH(pat);
		k := i;
		REPEAT
			k := k - 1;
			j := j - 1;
		UNTIL (j < 0) OR (pat[j+1] <> text[k]);
		i := i + d[text[i-1]];
	UNTIL (j < 0) OR (i >= endPos);

	BMSearch := i - LENGTH(pat);

END;


{ --- This is a variant of the string search useful --- }
{ --- for case insensitive and whole word searches. --- }
{ --- Before comparing, chars are mapped by a table --- }
FUNCTION BMSearchMap(pat: STRING; startPos, endPos: TextIndex;
                     VAR text: CharArray; VAR chMap: CharMap) : TextIndex;
VAR
	i, k: TextIndex;
	j: INTEGER;
	ch: CHAR;
	d: ARRAY [CHAR] OF INTEGER;

BEGIN
	{ Map the whole pattern }
	FOR j := 1 TO LENGTH(pat) DO
		pat[j] := chMap[ pat[j] ];

	FOR ch := #0 TO #255 DO
		d[ch] := LENGTH(pat);
	FOR j := 1 TO LENGTH(pat)-1 DO
		d[ pat[j] ] := LENGTH(pat)-j;

	i := startPos + LENGTH(pat);
	endPos := endPos + LENGTH(pat);
	REPEAT
		j := LENGTH(pat);
		k := i;
		REPEAT
			k := k - 1;
			j := j - 1;
		UNTIL (j < 0) OR (pat[j+1] <> chMap[text[k]]);
		i := i + d[ chMap[ text[i-1] ] ];
	UNTIL (j < 0) OR (i >= endPos);

	BMSearchMap := i - LENGTH(pat);

END;

END.
