PROGRAM psound;

VAR i,w:INTEGER;

PROCEDURE bpoke(adresse:LONG_INTEGER; wert:INTEGER);
C;

FUNCTION bpeek(adresse:LONG_INTEGER):INTEGER;
C;

PROCEDURE pause(zeit:INTEGER);
C;

BEGIN
bpoke($ff8800,0);       { Register 0 anw„hlen }
bpoke($ff8802,188);     { Auf 188 setzen }
bpoke($ff8800,1);       { Register 1 }
bpoke($ff8802,3);       { Auf 3 setzen }

bpoke($ff8800,8);       { Lautst„rkeregister }
bpoke($ff8802,15);      { Auf 15 setzen }

bpoke($ff8800,7);       { Modusregister }
w:=bpeek($ff8800);      { Modusregister lesen }
w:=w|63;                { Alle Kan„le aus }
w:=w&254;               { Bit 0 l”schen }
bpoke($ff8802,w);       { Register setzen }

pause(600);             { 3 Sekunden warten }

bpoke($ff8800,7);       { Modusregister }
w:=bpeek($ff8800);      { Modusregister lesen }
w:=w|1;                 { Bit 0 setzen }
bpoke($ff8802,w);       { Register setzen }

END.

