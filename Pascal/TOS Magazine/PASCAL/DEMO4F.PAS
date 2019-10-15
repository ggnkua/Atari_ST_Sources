(* Demoprogramm fÅr die Verwendung der CRT-Unit *)

PROGRAM Demo4F;

USES CRT;

VAR x,y,i:INTEGER;
	hilf:CHAR;

BEGIN
Textmode(BW80);
GOTOXY(20,12);
HighVideo;
WRITE('Fett und ');
NormVideo;
WRITELN('normal gedruckt.');

GOTOXY(1,1);
FOR i:=12 TO 24 DO
	BEGIN
	InsLine;
	Sound(400+i*100);
	DELAY(100);
	END;

FOR i:=24 DOWNTO 1 DO
	BEGIN
	DelLine;
	Sound(400+i*100);
	DELAY(100);
	END;

DELAY(100);
NoSound;
Hilf:=ReadKey;

GOTOXY(35,1);
ClrEol;
x:=WhereX;
y:=WhereY;

GOTOXY(1,2);
WRITELN('Ende von Zeile 1 bei (',x,',',y,')');

Hilf:=ReadKey;

FOR x:=1 TO 80 DO
	IF ODD(x)	THEN FOR y:=1 TO 25 DO
							BEGIN
							GOTOXY(x,y);
							WRITE('*');
							DELAY(10);
							END
				ELSE FOR y:=25 DOWNTO 1 DO
							BEGIN
							GOTOXY(x,y);
							WRITE('*');
							DELAY(10);
							END;

Window(30,8,50,12);
ClrScr;
FOR i:=1 TO 5 DO
	BEGIN
	WRITE('Dieser Text passt nicht in eine Zeile. ');
	Delay(500);
	END;


Window(1,1,80,25);
Hilf:=ReadKey;

Textmode(Lastmode);

END.