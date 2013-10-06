{$U70}

PROGRAM Effect;

TYPE farben = ARRAY[0..15] OF INTEGER;
     fname  = STRING;
     area   = ARRAY[0..15] OF INTEGER;

VAR pic1,pic2,st1,st2,phys:LONG_INTEGER;
    colors,oldcol:farben;
    name:fname;
    res:INTEGER;
    window:area;

FUNCTION Getrez:INTEGER;
XBIOS(4);

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; res:INTEGER);
XBIOS(5);

PROCEDURE Setpalette(VAR colors:farben);
XBIOS(6);

PROCEDURE fadeout;
C;

PROCEDURE fadein(VAR colors:farben);
C;

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

PROCEDURE palget(VAR colors:farben);
C;

FUNCTION getpage:LONG_INTEGER;
C;

PROCEDURE freepage(s:LONG_INTEGER);
C;

FUNCTION sbeg(VAR n:fname):LONG_INTEGER;
C;

FUNCTION cload(n,s,b:LONG_INTEGER; VAR colors:farben):LONG_INTEGER;
C;

PROCEDURE yshrink(q,z:LONG_INTEGER; h,y:INTEGER);
C;

PROCEDURE opscreen(q,z:LONG_INTEGER; y1,y2,op:INTEGER);
C;

PROCEDURE copyscreen(q,z:LONG_INTEGER; y1,y2:INTEGER);
C;

PROCEDURE yin(q,z:LONG_INTEGER; dir:INTEGER);
C;

PROCEDURE xyin(q,z:LONG_INTEGER);
C;

PROCEDURE fallin(q,z:LONG_INTEGER);
C;

PROCEDURE splitin(q,z:LONG_INTEGER);
C;

PROCEDURE rndbcopy(q,z:LONG_INTEGER; pause:INTEGER);
C;

PROCEDURE rndpcopy(q,z:LONG_INTEGER);
C;

PROCEDURE lp_scroll(logbase:LONG_INTEGER; VAR fenster:area);
C;

PROCEDURE overlap(q,z:LONG_INTEGER);
C;

PROCEDURE effect;
VAR i:INTEGER;
BEGIN
window[0]:=3;  window[1]:=50;
window[2]:=16; window[3]:=150;
FOR i:=4 TO 200 DO
    BEGIN
    yshrink(pic2,phys,i,(200-i) DIV 2);
    i:=i+3;
    END;
FOR i:=4 TO 200 DO
    BEGIN
    yshrink(pic1,phys,i,200-i);
    i:=i+3;
    END;
FOR i:=4 TO 200 DO
    BEGIN
    yshrink(pic2,phys,i,0);
    i:=i+3;
    END;
fadeout;
opscreen(pic1,phys,0,199,1);
fadein(colors);
FOR i:=95 DOWNTO 0 DO copyscreen(pic2,phys,i,199-i);
FOR i:=1 TO 230 DO lp_scroll(phys,window);
yin(pic1,phys,0);
yin(pic2,phys,1);
xyin(pic1,phys);
fallin(pic2,phys);
splitin(pic1,phys);
rndbcopy(pic2,phys,1500);
rndpcopy(pic1,phys);
overlap(pic2,phys);
overlap(pic1,phys);
END;

BEGIN
offmouse;
res:=Getrez;
phys:=Physbase;
pic1:=getpage;
pic2:=getpage;
IF (pic1>0) AND (pic2>0) THEN
    BEGIN
    name:='glas.cmp';
    st1:=cload(sbeg(name),pic1,32000,colors);
    name:='station.cmp';
    st2:=cload(sbeg(name),pic2,32000,colors);
    IF (st1>=0) AND (st2>=0) THEN
        BEGIN
        palget(oldcol);
        Setscreen(-1,-1,0);
        Setpalette(colors);

        effect;

        fadeout;
        Setscreen(-1,-1,res);
        fadein(oldcol);
        END;
    freepage(pic2);
    freepage(pic1);
    END;
onmouse;
END.
