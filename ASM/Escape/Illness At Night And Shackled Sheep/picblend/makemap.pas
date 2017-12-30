{GENERIERT VERZERRUNGSTABELLEN ZUM ERZEUGEN EINER FIXEN TEXTUREMAP}
PROGRAM MakeMap;
USES	Tos;
VAR		fh		:LongInt;
		x,y		:LongInt;
		xtab	:Array[0..319] OF LongInt;
		ytab	:Array[0..239] OF LongInt;
		
BEGIN
	FOR x:=0 TO 319 DO xtab[x]:=(1+320*240)*Round(3+3*sin(8*Pi*x/320)){+320*Round(Sqr(5*sin(2*Pi*x/320)))};
	FOR y:=0 TO 239 DO ytab[y]:=(1+320*240)*Round(3+3*sin(8*Pi*y/240));

	{Save tables}
	fh:=Fcreate('map2x.tab',0);
	FWrite(fh,4*320,@xtab);
	FClose(fh);
	
	fh:=FCreate('map2y.tab',0);
	FWrite(fh,4*240,@ytab);
	FClose(fh);
END.