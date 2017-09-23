PROGRAM stacktest;

FUNCTION Fakultaet( n : INTEGER ) : INTEGER;
BEGIN
	IF n <= 0 THEN
		Fakultaet := 1
	ELSE
		Fakultaet := Fakultaet( n - 1 ) * n;
END;

PROCEDURE ebene4;
	VAR i : INTEGER;
BEGIN
	i := 5;
	WRITELN('Ebene Nummer 4');
	WRITELN(Fakultaet(i));
END;

PROCEDURE ebene3;
BEGIN
	WRITELN('Ebene Nummer 3');
	ebene4;
END;

PROCEDURE ebene2;
BEGIN
	WRITELN('Ebene Nummer 2');
	ebene3;
END;

PROCEDURE ebene1;
BEGIN
	WRITELN('Ebene Nummer 1');
	ebene2;
END;


BEGIN
	ebene1;
END.