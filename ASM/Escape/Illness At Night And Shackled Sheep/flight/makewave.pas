PROGRAM MakeWave;
USES Tos;
VAR wave:Array[0..250] OF LongInt;
	fh:LongInt;
	i:LongInt;
	x,y:LongInt;	
	
BEGIN

	FOR i:=0 TO 250 DO BEGIN
		x:=Round(7*sin(i*2*Pi/50+3));
		y:=Round(5*cos(i*2*Pi/100+0.4));
		wave[i]:=2*x+640*y;
	END;
	
	fh:=Fcreate('FLIGHT.WVE',0);
	Fwrite(fh,250*4,@wave);
	Fclose(fh);
END.