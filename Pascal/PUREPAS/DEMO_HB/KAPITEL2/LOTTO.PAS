PROGRAM lotto;

USES CRT;

CONST maxzahlen = 6;

TYPE 	zahlenarray = ARRAY[1..maxzahlen] OF INTEGER;

VAR	Lottozahlen	: zahlenarray;
		ende			: BOOLEAN;

PROCEDURE init(VAR feld : zahlenarray);
	VAR i : INTEGER;
BEGIN
	FOR i:=1 TO maxzahlen DO
		feld[i]:=0;
END;

PROCEDURE sort(VAR feld : zahlenarray);
	VAR i, j, temp : INTEGER;
BEGIN
	FOR i:=maxzahlen DOWNTO 2 DO
	BEGIN
		FOR j:=2 TO i DO
		BEGIN
			IF feld[j-1]>feld[j] THEN
			BEGIN
		        	temp:=feld[j];
					feld[j]:=feld[j-1];
   		     	feld[j-1]:=temp;
			END;
		END;
	END;
END;

PROCEDURE berechnezahlen(VAR feld : zahlenarray);
	VAR i, j 	: INTEGER;
		 nochmal	: BOOLEAN;
BEGIN
	FOR i:=1 TO maxzahlen DO
	BEGIN
	   nochmal:=FALSE;
    	REPEAT
        	feld[i]:=Random(49)+1;
          	IF i>1 THEN
				BEGIN
	            nochmal:=FALSE;
	            FOR j:=1 TO i-1 DO
						IF feld[i]=feld[j] THEN nochmal:=TRUE;
          	END;
		UNTIL (nochmal=FALSE);
	END;
END;

PROCEDURE writezahlen(VAR feld : zahlenarray);
	VAR i : INTEGER;
		str: STRING;
		c  : CHAR;
BEGIN
	str:=' ';
	ClrScr;
	WRITELN('Das Programm schlÑgt 6 Zahlen fÅr das Samstag-Lotto vor');
	WRITELN;
	FOR i:=1 TO maxzahlen DO
		WRITELN(feld[i]);
	WRITELN;
	WRITELN('Weiter mit Taste, Eingabe von ''e'' beendet');
	c:=readkey;
	IF (c='e') OR (c='E') THEN ende:=TRUE;
END;


(* HAUPTPROGRAMM *)

BEGIN
	ende:=FALSE;
	Randomize;
	REPEAT	
		init(Lottozahlen);
		berechnezahlen(Lottozahlen);
		sort(Lottozahlen);
		writezahlen(Lottozahlen);
	UNTIL ende;
END.