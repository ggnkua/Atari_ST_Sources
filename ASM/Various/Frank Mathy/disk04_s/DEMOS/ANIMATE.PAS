PROGRAM Animate;

TYPE clip = ARRAY[0..3] OF INTEGER;
     farben = ARRAY[0..15] OF INTEGER;
     dlist = ARRAY[0..23] OF INTEGER;

VAR res,i:INTEGER;
    clp:clip;
    phys:LONG_INTEGER;
    colors:farben;
    l:dlist;

PROCEDURE fbox(x1,y1,x2,y2,col:INTEGER; log:LONG_INTEGER; VAR clp:clip);
C;

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

PROCEDURE palget(VAR colors:farben);
C;

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

FUNCTION Getrez:INTEGER;
XBIOS(4);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; res:INTEGER);
XBIOS(5);

PROCEDURE Setpalette(VAR colors:farben);
XBIOS(6);

PROCEDURE ondlist(VAR liste:dlist; z:INTEGER);
C;

PROCEDURE oncycle(t1,t2,d,s:INTEGER);
C;

PROCEDURE offcycle;
C;

PROCEDURE offdlist;
C;

PROCEDURE waitkey;
GEMDOS(7);

BEGIN
offmouse;
palget(colors);
phys:=Physbase;
res:=Getrez;
Setscreen(-1,-1,0);

l[0]:=0; l[1]:=$000; l[2]:=-1;
l[3]:=0; l[4]:=$111; l[5]:=-1;
l[6]:=0; l[7]:=$222; l[8]:=-1;
l[9]:=0; l[10]:=$333; l[11]:=-1;
l[12]:=0; l[13]:=$444; l[14]:=-1;
l[15]:=0; l[16]:=$555; l[17]:=-1;
l[18]:=0; l[19]:=$666; l[20]:=-1;
l[21]:=0; l[22]:=$777; l[23]:=-1;
clp[0]:=0; clp[1]:=0;
clp[2]:=319; clp[3]:=199;
ondlist(l,26);
FOR i:=1 TO 14 DO fbox(20*i,95,19+20*i,105,i,phys,clp);

oncycle(1,14,0,7);

waitkey;

offcycle;

offdlist;

Setscreen(-1,-1,res);
Setpalette(colors);
onmouse;
END.

