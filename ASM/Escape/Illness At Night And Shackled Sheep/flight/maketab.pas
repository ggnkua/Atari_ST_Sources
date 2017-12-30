PROGRAM MakeTab;
USES Tos;
VAR	xtab: 	Array[0..159] OF LongInt;
	ytab: 	Array[0..199] OF LongInt;
	xcnt: 	LongInt;
	ycnt: 	LongInt;
	fh:		LongInt;
	
BEGIN
	
	FOR xcnt:=0 TO 159 DO BEGIN
		xtab[xcnt]:=Round(80+((xcnt-79)*0.95))*4;
	END;

	fh:=Fcreate('fast2.xtb',0);
	Fwrite(fh,160*4,@xtab);
	Fclose(fh);
	
	FOR ycnt:=0 TO 199 DO BEGIN
		ytab[ycnt]:=Round(100+((ycnt-99)*0.95))*640;	
	END;

	fh:=FCreate('fast2.ytb',0);
	Fwrite(fh,200*4,@ytab);
	Fclose(fh);
END.