PROGRAM BreakPointTest;

PROCEDURE ausgabe(wert : INTEGER);
BEGIN
	WRITE(wert);
	WRITE('. Durchlauf');
END;	

PROCEDURE schleife;
	VAR i : INTEGER;
BEGIN
	FOR i:=1 TO 20 DO
	BEGIN	
		ausgabe(i);
		WRITELN;
	END;
END;

BEGIN
	schleife;
END.
