{$M+,E+} PROGRAM string_library;

{ V2.2, Hartmut Thordsen, Dezember 1987 }

PROCEDURE ltrim (VAR s : STRING);
BEGIN
WHILE (length(s) > 0) AND (s[1] = ' ') DO delete (s, 1, 1);
END; { ltrim }

PROCEDURE rtrim (VAR s : STRING);
BEGIN
WHILE (length(s) > 0) AND (s[length(s)] = ' ') DO delete (s, length(s), 1);
END; { rtrim }

PROCEDURE trim (VAR s : STRING);
BEGIN
ltrim (s);
rtrim (s);
END; { trim }


PROCEDURE lformat (VAR s : STRING; width : INTEGER);
BEGIN
IF length (s) > width THEN
    s := copy (s, 1, width)
ELSE WHILE (length (s) < width) DO
    s := concat (s, ' ');
END; { lformat }

PROCEDURE rformat (VAR s : STRING; width : INTEGER);
BEGIN
IF length (s) > width THEN
    s := copy (s, length(s) - width + 1, width)
ELSE WHILE (length (s) < width) DO
    s := concat (' ', s);
END; { rformat }

PROCEDURE cformat (VAR s : STRING; width : INTEGER);
VAR	i	: INTEGER;
BEGIN
IF length (s) > width THEN
    s := copy (s, (length(s) - width) DIV 2, width)
ELSE WHILE (length (s) < width) DO
    BEGIN
    s := concat (s, ' ');
    IF length (s) < width THEN
	s := concat (' ', s);
    END;
END; { cformat }


FUNCTION verify (s, in_chars : STRING) : INTEGER;
VAR	i, p	: INTEGER;

	FUNCTION zzzschar_in (c : CHAR; VAR in_chars : STRING) : BOOLEAN;
	VAR	i	: INTEGER;
		found	: BOOLEAN;
	BEGIN
	found := FALSE;
	i := 1;
	WHILE NOT found AND (i <= length (in_chars)) DO
	    IF c = in_chars[i] THEN found := TRUE
	    ELSE i := i + 1;
	zzzschar_in := found;
	END; { zzzschar_in }
BEGIN
p := 0;
i := 1;
WHILE (i <= length (s)) AND (p = 0) DO
    IF zzzschar_in (s[i], in_chars) THEN i := i + 1
    ELSE p := i;
verify := p;
END; { verify }


PROCEDURE clean_in  (VAR s : STRING; in_chars  : STRING);
VAR	p	: INTEGER;
BEGIN
p := verify (s, in_chars);
WHILE p <> 0 DO
    BEGIN
    delete (s, p, 1);
    p := verify (s, in_chars);
    END;
END; { clean_in }

PROCEDURE clean_out (VAR s : STRING; out_chars : STRING);
VAR	i	: INTEGER;
BEGIN
FOR i := length(s) DOWNTO 1 DO
    IF verify (copy (s, i, 1), out_chars) = 0 THEN delete (s, i, 1);
END; { clean_out }


FUNCTION pos_end (look, source : STRING) : INTEGER;
VAR	p, lastp: INTEGER;
	hilf	: STRING;
BEGIN
lastp := 0;
p := pos (look, source);
WHILE p <> 0 DO
    BEGIN
    lastp := lastp + p;
    hilf :=  copy (source, lastp+1, length(source)-lastp);
    p := pos (look, hilf);
    END;
pos_end := lastp;
END; { pos_end }


PROCEDURE str_end (look,source:STRING; include_look:BOOLEAN; VAR dest:STRING);
VAR p	: INTEGER;
BEGIN
dest := '';
p := pos_end (look, source);
IF p <> 0 THEN
    IF include_look THEN dest := copy (source, p, length(source)-p+1)
    ELSE dest := copy (source, p+length(look),length(source)-length(look)-p+1);
END; { str_end }


FUNCTION str_greater (s1, s2 : STRING) : BOOLEAN;
VAR	i	: INTEGER;

	PROCEDURE zzzszeichen_pruefen (VAR s : STRING);
	BEGIN
	CASE ord(s[i]) OF
	    142, 132	: s[i] := chr($41);   { Ž, „ => A }
	    153, 148	: s[i] := chr($4F);   { ™, ” => O }
	    154, 129	: s[i] := chr($55);   { š,  => U }
	    158 	: s[i] := chr($53);   { ž    => S }
	    OTHERWISE	: IF ord(s[i]) IN [$61..$7A] { Kleinb. => Grossb. }
		THEN s[i] := chr(ord(s[i])-$20);
	    END;
	END; { zzzszeichen_pruefen }
BEGIN
FOR i := 1 TO length (s1) DO zzzszeichen_pruefen (s1);
FOR i := 1 TO length (s2) DO zzzszeichen_pruefen (s2);
str_greater := (s1 > s2);
END; { str_greater }

BEGIN { leeres Hauptprogramm } END.
