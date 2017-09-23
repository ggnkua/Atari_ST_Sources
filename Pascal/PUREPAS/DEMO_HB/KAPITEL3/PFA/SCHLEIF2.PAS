PROGRAM Schleife2;

VAR	n	: INTEGER;

BEGIN
	n	:= 0;
	WHILE n <> 5 DO
	BEGIN
		WRITE(n, ' ');
		n	:= SUCC(n)
	END;
	WRITELN
END. 
