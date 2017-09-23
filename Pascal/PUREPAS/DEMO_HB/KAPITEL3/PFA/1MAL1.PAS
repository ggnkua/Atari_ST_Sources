PROGRAM EinMalEins;

TYPE	EinsBisZehn	=	1..10;

VAR	x	:	EinsBisZehn;
	y	:	INTEGER;

	FUNCTION Berechne(a, b : EinsBisZehn) : INTEGER;

	BEGIN
		Berechne := a * b
	END;

BEGIN
	WRITELN('Das Einmaleins');
	FOR x:=1 TO 10 DO
	BEGIN
		FOR y:=1 TO 10 DO
		BEGIN
			WRITELN(x, ' * ', y, ' = ', Berechne(x, y))
		END
	END
END.
