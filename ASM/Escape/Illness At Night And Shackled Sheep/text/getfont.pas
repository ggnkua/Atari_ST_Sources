PROGRAM GetFont;
USES Tos;
TYPE screen=Array[1..400,1..40] OF Word;
VAR fh:Integer;
	scradr:^screen;
	key:Char;
	x,y:Integer;
	w:Word;

BEGIN
	GotoXY(20,10);
	fh:=Fopen('e:\alphabet\snap0004.pi3',FO_READ);
	Fread(fh,32+3,logbase);
	Fread(fh,32000,logbase);
	FClose(fh);
	
	scradr:=LogBase;

	fh:=FCreate('SWISS.CHR',0);
	
	REPEAT
		key:=Readkey;
		CASE Upcase(key) OF
			' ': FOR y:=1 TO 400 DO BEGIN
				FOR x:=1 TO 80 Do BEGIN
					scradr^[y,x]:=scradr^[y+1,x];
				END;
			END;	
			'.': FOR y:=1 TO 400 DO BEGIN
				FOR x:=1 TO 80 DO BEGIN
					scradr^[y,x]:=scradr^[y+69,x];
				END;
			END;
			'S': FOR y:=1 TO 36 DO BEGIN
				FOR x:=1 TO 3 DO BEGIN
					w:=scradr^[y,x];
					Fwrite(fh,2,@w);
				END;
			END;	
		END;
	UNTIL key=#27;
	
	Fclose(fh);
END.