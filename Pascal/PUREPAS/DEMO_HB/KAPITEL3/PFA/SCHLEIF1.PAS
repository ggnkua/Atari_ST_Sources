PROGRAM Schleife1;

VAR	n	: INTEGER;

BEGIN
	n	:= 0;
	REPEAT
		WRITE(n, ' ');
		n	:= SUCC(n)
	UNTIL	n = 5;
	WRITELN
END.
