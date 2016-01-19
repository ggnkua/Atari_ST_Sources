PROGRAM gia;

VAR i,w:INTEGER;

FUNCTION giaccess(inhalt,register:INTEGER):INTEGER;
XBIOS(28);

PROCEDURE pause(zeit:INTEGER);
C;

BEGIN
w:=giaccess(188,128);    { Register 0 auf 188 }
w:=giaccess(3,128+1);    { Register 1 auf 3 }
w:=giaccess(15,128+8);   { Register 8 auf 15 }
w:=giaccess(0,7);        { Register 7 lesen }

w:=w|63;                 { Alle Kan„le aus }
w:=w&254;                { Bit 0 l”schen }
w:=giaccess(w,128+7);    { Register setzen }

pause(600);              { 3 Sekunden Pause }

w:=giaccess(0,7);        { Register lesen }
w:=w|1;                  { Bit 0 setzen }
w:=giaccess(w,128+7);    { Register setzen }
END.


