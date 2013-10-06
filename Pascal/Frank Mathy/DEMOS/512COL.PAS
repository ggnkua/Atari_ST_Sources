PROGRAM color512;

TYPE clip = ARRAY[0..3] OF INTEGER;

VAR r,g,b,va,res,i:INTEGER;
    colors:ARRAY[0..15] OF INTEGER;
    phys:LONG_INTEGER;
    clp:clip;
    col:ARRAY[0..2000] OF INTEGER;

PROCEDURE offmouse;
C;

PROCEDURE palget(VAR colors:INTEGER);
C;

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

FUNCTION Getrez:INTEGER;
XBIOS(4);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; rez:INTEGER);
XBIOS(5);

PROCEDURE Setcolor(topf,inhalt:INTEGER);
XBIOS(7);

PROCEDURE ondlist(VAR liste:INTEGER; lines:INTEGER);
C;

PROCEDURE fbox(x1,y1,x2,y2,farbe:INTEGER; log:LONG_INTEGER;
               VAR clipping:clip);
C;

PROCEDURE waitkey;
GEMDOS(7);

PROCEDURE offdlist;
C;

PROCEDURE Setpalette(VAR colors:INTEGER);
XBIOS(6);

PROCEDURE onmouse;
C;

BEGIN
clp[0]:=0; clp[1]:=0; clp[2]:=319; clp[3]:=199;
i:=0; va:=0;
FOR r:=7 DOWNTO 0 DO
  FOR g:=0 TO 7 DO
    BEGIN
    FOR b:=0 TO 7 DO
      BEGIN
      col[va]:=(8-b)*2;
      col[va+1]:=(r*256)+(g*16)+b;
      va:=va+2;
      END;
    col[va]:=-1;
    va:=va+1;
    END;
FOR i:=0 TO 10 DO col[va+i]:=-1;

offmouse;
palget(colors[0]);
phys:=Physbase;
res:=Getrez;
Setscreen(-1,-1,0);
Setcolor(0,$555);

ondlist(col[0],3);

FOR i:=0 TO 7 DO fbox(40*i,0,40*i+39,191,i+1,phys,clp);

waitkey;

offdlist;
Setscreen(-1,-1,res);
Setpalette(colors[0]);
onmouse;
END.

