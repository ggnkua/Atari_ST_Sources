program jagpad_example;

{Dieses kleine Programm soll die Einbindung und Auswertung der
 JAGPAD-Unit zeigen. Es werden alle derzeit mîglichen RÅckgabewerte
 angezeigt. Man kann mit diesem Programm schnell mal testen, ob das
 Jaguarpad Åberhaupt funktioniert.}

uses crt,jagpad;

var was_gedrueckt:teststring;		{von der Unit definierter Ergebnistyp}
	zeig:string;

begin
 clrscr;
repeat
 was_gedrueckt:=test(0);			{Abfrage von Port A
									(fÅr Port B einfach 1 öbergeben)}
 case was_gedrueckt of
	up		:zeig:='up        ';
	down	:zeig:='down      ';
	left	:zeig:='left      ';
	right	:zeig:='right     ';
	one		:zeig:='1         ';
	two		:zeig:='2         ';
	three	:zeig:='3         ';
	four	:zeig:='4         ';
	five	:zeig:='5         ';
	six		:zeig:='6         ';
	seven	:zeig:='7         ';
	eight	:zeig:='8         ';
	nine	:zeig:='9         ';
	zero	:zeig:='0         ';
	cross	:zeig:='#         ';
	star	:zeig:='*         ';
	A		:zeig:='A         ';
	P		:zeig:='P         ';
	AP		:zeig:='AP        ';
	B		:zeig:='B         ';
	C		:zeig:='C         ';
	O		:zeig:='O         ';
	upleft	:zeig:='upleft    ';
	upright	:zeig:='upright   ';
	downleft:zeig:='downleft  ';
	downright:zeig:='downright ';
	nothing :zeig:='          ';
  end;
  gotoxy(1,1);
  write(zeig);
until keypressed;
end.