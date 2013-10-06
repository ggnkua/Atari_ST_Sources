PROGRAM fractal;

VAR h:ARRAY[0..65,0..65] OF INTEGER;
    colors:ARRAY[0..16] OF INTEGER;
    sw,aw,l,yg,xz,yz,res,zl,wp,taste:INTEGER;
    log,key:LONG_INTEGER;
    pot:ARRAY[0..6] OF INTEGER;
    p0,p1,p2,p3,p4,p5:INTEGER;

FUNCTION Random:INTEGER;
XBIOS(17);

FUNCTION Logbase:LONG_INTEGER;
XBIOS(3);

PROCEDURE Color(a,b:INTEGER);
XBIOS(7);

PROCEDURE Setpalette(VAR colors:INTEGER);
XBIOS(6);

FUNCTION Getrez:INTEGER;
XBIOS(4);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; res:INTEGER);
XBIOS(5);

PROCEDURE clearscreen(log:LONG_INTEGER; y1,y2:INTEGER);
C;

PROCEDURE all_init;
C;

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

PROCEDURE setcolor(col:INTEGER);
C;

PROCEDURE drawline(x1,y1,x2,y2:INTEGER);
C;

PROCEDURE palget(VAR col:INTEGER);
C;

FUNCTION Getkey:LONG_INTEGER;
GEMDOS(7);

FUNCTION zufall(stufe:INTEGER):INTEGER;
BEGIN
zufall:=Random&pot[stufe-1]-pot[stufe];
END;

PROCEDURE mache_fractal;
VAR l,yg,yz,sw,xz,aw:INTEGER;
BEGIN
h[0,0]:=0;
h[0,64]:=0;
h[64,0]:=0;

sw:=32; aw:=64;
FOR l:=1 TO 6 DO
  BEGIN
  yz:=0; yg:=0;
  REPEAT
    IF (yg MOD 2 = 0) THEN
      BEGIN
      xz:=sw;
      REPEAT
        h[xz,yz]:=(h[xz-sw,yz]+h[xz+sw,yz]) DIV 2+zufall(l);
        xz:=xz+aw;
      UNTIL xz>=64-yz;
      END
    ELSE
      BEGIN
      xz:=0;
      REPEAT
        h[xz,yz]:=(h[xz,yz-sw]+h[xz,yz+sw]) DIV 2+zufall(l);
        xz:=xz+sw;
        h[xz,yz]:=(h[xz-sw,yz+sw]+h[xz+sw,yz-sw]) DIV 2+zufall(l);
        xz:=xz+sw;
      UNTIL xz>64-yz;
      END;
    yg:=yg+1;
    yz:=yz+sw;
  UNTIL yz>=64;
aw:=aw DIV 2;
sw:=sw DIV 2;
END;
END;

PROCEDURE zeichne_fractal(stufe,pegel:INTEGER);
VAR x,y,farbe:INTEGER;
BEGIN
sw:=pot[stufe+1]+1;
clearscreen(log,0,199);
y:=0;
REPEAT
  x:=0;
  REPEAT
    farbe:=2;
    p0:=x*10+y*5;
    p1:=y*2+70;
    IF h[x,y]>pegel THEN
      BEGIN
      p1:=p1-h[x,y];
      farbe:=3;
      END
    ELSE
      p1:=p1-pegel;
    p2:=p0+10*sw;
    p3:=y*2+70;
    IF h[x+sw,y]>pegel THEN
      BEGIN
      p3:=p3-h[x+sw,y];
      farbe:=3;
      END
    ELSE
      p3:=p3-pegel;
    p4:=p0+5*sw;
    p5:=(y+sw)*2+70;
    IF h[x,y+sw]>pegel THEN
      BEGIN
      p5:=p5-h[x,y+sw];
      farbe:=3;
      END
    ELSE
      p5:=p5-pegel;
    setcolor(farbe);
    drawline(p0,p1,p2,p3);
    drawline(p2,p3,p4,p5);
    drawline(p4,p5,p0,p1);
    x:=x+sw;
  UNTIL x>63-y;
  y:=y+sw;
UNTIL y>63;
END;

BEGIN
pot[0]:=63; pot[1]:=31; pot[2]:=15; pot[3]:=7; pot[4]:=3;
pot[5]:=1; pot[6]:=0;
wp:=0; zl:=5;
palget(colors[0]);
res:=Getrez;
Setscreen(-1,-1,1);
Color(0,0);
Color(2,7);
Color(3,$70);
log:=Logbase;
all_init;
offmouse;
mache_fractal;
zeichne_fractal(zl,wp);

REPEAT
  key:=Getkey;
  key:=ShR(key,16);
  taste:=INT(key);
  CASE taste OF
    $48:        IF wp<50 THEN
                  BEGIN
                  wp:=wp+3;
                  zeichne_fractal(zl,wp);
                  END;
    $50:        IF wp>-50 THEN
                  BEGIN
                  wp:=wp-3;
                  zeichne_fractal(zl,wp);
                  END;
    $4d:        IF zl<5 THEN
                  BEGIN
                  zl:=zl+1;
                  zeichne_fractal(zl,wp);
                  END;
    $4b:        IF zl>0 THEN
                  BEGIN
                  zl:=zl-1;
                  zeichne_fractal(zl,wp);
                  END;
    $62:        BEGIN
                mache_fractal;
                zeichne_fractal(zl,wp);
                END;
  END;
UNTIL key=$61;
Setscreen(-1,-1,res);
Setpalette(colors[0]);
onmouse;
END.

