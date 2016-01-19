PROGRAM Object;

VAR star:ARRAY[0..16] OF INTEGER;
    i,res:INTEGER;
    log:LONG_INTEGER;

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

FUNCTION Getrez:INTEGER;
XBIOS(4);

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

PROCEDURE Setscreen(phys,log:LONG_INTEGER; res:INTEGER);
XBIOS(5);

PROCEDURE all_init;
C;

PROCEDURE def_clip(x1,y1,x2,y2,mode:INTEGER);
C;

PROCEDURE clearscreen(log:LONG_INTEGER; y1,y2:INTEGER);
C;

PROCEDURE setcolor(color:INTEGER);
C;

PROCEDURE object(x,y,zoom:INTEGER; VAR ob:INTEGER);
C;

PROCEDURE waitkey;
GEMDOS(7);

BEGIN
star[0]:=8;
star[1]:=0;  star[2]:=-50; star[3]:=10; star[4]:=-10;
star[5]:=50; star[6]:=0;   star[7]:=10; star[8]:=10;
star[9]:=0;  star[10]:=50; star[11]:=-10; star[12]:=10;
star[13]:=-50; star[14]:=0; star[15]:=-10; star[16]:=-10;

offmouse;
res:=Getrez;
log:=Physbase;
Setscreen(-1,-1,0);
all_init;
def_clip(0,0,319,199,1);
clearscreen(log,0,199);
FOR i:=1 TO 15 DO
  BEGIN
  setcolor(i);
  object(i*19,5+i*10,22+i*7,star[0]);
  END;
waitkey;
Setscreen(-1,-1,res);
onmouse;
END.

