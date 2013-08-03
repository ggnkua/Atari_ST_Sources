PROGRAM MakeTab;
USES Tos;
VAR	xtab: 	Array[0..159] OF LongInt;
	ytab: 	Array[0..199] OF LongInt;
	xcnt: 	LongInt;
	ycnt: 	LongInt;
	fh:		LongInt;
	
BEGIN
	
	FOR xcnt:=0 TO 159 DO BEGIN
		xtab[xcnt]:=640*Round(50*sin(xcnt*2*Pi/160));
	END;

	fh:=Fcreate('lava.xtb',0);
	Fwrite(fh,160*4,@xtab);
	Fclose(fh);
	
	FOR ycnt:=0 TO 199 DO BEGIN
		ytab[ycnt]:=2*Round(50*sin(ycnt*2*Pi/200));	
	END;

	fh:=FCreate('lava.ytb',0);
	Fwrite(fh,200*4,@ytab);
	Fclose(fh);
END.