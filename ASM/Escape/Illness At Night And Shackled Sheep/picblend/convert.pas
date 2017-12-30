{KONVERTIERT TRP-IMAGE IN GRAUSTUFEN-BILD (320x240)}
{DIE R,G,B-WERTE WERDEN EINFACH ADDIERT -> 63 GRAUSTUFEN}
PROGRAM Convert;
USES	Tos;
VAR		fh		:LongInt;
		src		:Array[0..240,0..319] OF Word;	{ Sourcebuffer (trp-Daten) }
		dst		:Array[0..240,0..319] OF Byte; { Zielbuffer }
		x,y		:LongInt;
		r,g,b	:Word;
		
BEGIN
	{Load sourcefile}
	fh:=FOpen('napf.xga',FO_READ);
	Fread(fh,8,@src);
	Fread(fh,153600,@src);
	FClose(fh);
	
	
	FOR y:=0 TO 239 DO BEGIN
		GotoXY(1,1);Write('line:',y); 
		FOR x:=0 TO 319 DO BEGIN
			r:=src[y,x] SHR 11;
			g:=(src[y,x] SHR 6) AND $1F;
			b:=src[y,x] AND $1F;
			dst[y,x]:=2*(r+g+b) div 3;			
		END;
	END;
	
	{Save result}
	fh:=FCreate('napf.GRY',0);
	Fwrite(fh,76800,@dst);
	FClose(fh);
END.
	
	