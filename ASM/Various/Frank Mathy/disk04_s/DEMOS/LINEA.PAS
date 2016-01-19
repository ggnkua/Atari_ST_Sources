PROGRAM Linea;

TYPE maus = ARRAY[0..35] OF INTEGER;
     sdb = ARRAY[0..36] OF INTEGER;
     ssb = ARRAY[0..132] OF INTEGER;
     coor = ARRAY[0..7] OF INTEGER;

    MFDB =      RECORD
                start:LONG_INTEGER;
                width:INTEGER;
                height:INTEGER;
                wwidth:INTEGER;
                format:INTEGER;
                planes:INTEGER;
                fut1:INTEGER;
                fut2:INTEGER;
                fut3:INTEGER;
                END;

VAR res,i:INTEGER;
    ms:maus;
    punkte:ARRAY[0..5] OF INTEGER;
    copy:coor;
    r:MFDB;
    sprite:sdb;
    save:ssb;
    muster:ARRAY[0..63] OF INTEGER;

FUNCTION Physbase:LONG_INTEGER;
XBIOS(2);

FUNCTION Getrez:INTEGER;
XBIOS(4);

PROCEDURE Setscreen(log,phys:LONG_INTEGER; res:INTEGER);
XBIOS(5);

PROCEDURE Vsync;
XBIOS(37);

PROCEDURE Waitkey;
GEMDOS(7);

PROCEDURE offmouse;
C;

PROCEDURE onmouse;
C;

PROCEDURE all_init;
C;

PROCEDURE transform(VAR neu:maus);
C;

PROCEDURE set_pixel(x,y,col:INTEGER);
C;

PROCEDURE setsprite(x,y:INTEGER; VAR sprite:sdb; VAR save:ssb);
C;

PROCEDURE clrsprite(VAR save:ssb);
C;

PROCEDURE fpoly(VAR punkte:INTEGER; zahl:INTEGER);
C;

PROCEDURE setcolor(color:INTEGER);
C;

PROCEDURE drawline(x1,y1,x2,y2:INTEGER);
C;

PROCEDURE def_fill(VAR muster:INTEGER; maske,multifill:INTEGER);
C;

PROCEDURE frect(x1,y1,x2,y2:INTEGER);
C;

PROCEDURE settext(hg,vg,scale,effect,rotate:INTEGER);
C;

PROCEDURE setchar(x,y,code,font:INTEGER);
C;

PROCEDURE copy_raster(VAR p:coor; VAR q,z:MFDB; m,a,c0,c1:INTEGER);
C;

BEGIN
sprite[0]:=8;
sprite[1]:=8;
sprite[2]:=1;
sprite[3]:=1;
sprite[4]:=2;

sprite[5]:=$0000;
sprite[6]:=$0000;
sprite[7]:=$0000;
sprite[8]:=$0000;
sprite[9]:=$0000;
sprite[10]:=$0180;
sprite[11]:=$0000;
sprite[12]:=$07E0;
sprite[13]:=$0420;
sprite[14]:=$03C0;
sprite[15]:=$0420;
sprite[16]:=$03C0;
sprite[17]:=$0000;
sprite[18]:=$0180;
sprite[19]:=$0000;
sprite[20]:=$0180;
sprite[21]:=$0000;
sprite[22]:=$03C0;
sprite[23]:=$0000;
sprite[24]:=$03C0;
sprite[25]:=$1818;
sprite[26]:=$07E0;
sprite[27]:=$1998;
sprite[28]:=$0660;
sprite[29]:=$1998;
sprite[30]:=$0660;
sprite[31]:=$0180;
sprite[32]:=$0000;
sprite[33]:=$0000;
sprite[34]:=$0000;
sprite[35]:=$0000;
sprite[36]:=$0000;

muster[0]:=$F0F0;
muster[1]:=$F0F0;
muster[2]:=$FFFF;
muster[3]:=$FFFF;
muster[4]:=$0F0F;
muster[5]:=$0F0F;
muster[6]:=$0000;
muster[7]:=$0000;
muster[8]:=$0F0F;
muster[9]:=$0F0F;
muster[10]:=$3C3C;
muster[11]:=$3C3C;
muster[12]:=$FFFF;
muster[13]:=$FFFF;
muster[14]:=$3C3C;
muster[15]:=$3C3C;

muster[16]:=$F0F0;
muster[17]:=$F0F0;
muster[18]:=$0000;
muster[19]:=$0000;
muster[20]:=$FFFF;
muster[21]:=$FFFF;
muster[22]:=$C3C3;
muster[23]:=$C3C3;
muster[24]:=$F0F0;
muster[25]:=$F0F0;
muster[26]:=$3C3C;
muster[27]:=$3C3C;
muster[28]:=$0000;
muster[29]:=$0000;
muster[30]:=$FFFF;
muster[31]:=$FFFF;

muster[32]:=$F0F0;
muster[33]:=$F0F0;
muster[34]:=$3C3C;
muster[35]:=$3C3C;
muster[36]:=$0000;
muster[37]:=$0000;
muster[38]:=$FFFF;
muster[39]:=$FFFF;
muster[40]:=$0000;
muster[41]:=$0000;
muster[42]:=$3C3C;
muster[43]:=$3C3C;
muster[44]:=$0F0F;
muster[45]:=$0F0F;
muster[46]:=$0000;
muster[47]:=$0000;

muster[48]:=$FFFF;
muster[49]:=$FFFF;
muster[50]:=$0000;
muster[51]:=$0000;
muster[52]:=$0000;
muster[53]:=$0000;
muster[54]:=$C3C3;
muster[55]:=$C3C3;
muster[56]:=$FFFF;
muster[57]:=$FFFF;
muster[58]:=$C3C3;
muster[59]:=$C3C3;
muster[60]:=$0000;
muster[61]:=$0000;
muster[62]:=$FFFF;
muster[63]:=$FFFF;

res:=Getrez;
offmouse;
Setscreen(-1,-1,0);
all_init;
ms[0]:=8; ms[1]:=8; ms[2]:=0; ms[3]:=15;
FOR i:=4 TO 35 DO ms[i]:=$ffff;
transform(ms);
punkte[0]:=10;  punkte[1]:=10;
punkte[2]:=130; punkte[3]:=190;
punkte[4]:=310; punkte[5]:=50;
fpoly(punkte[0],3);
FOR i:=0 TO 319 DO set_pixel(i,190,i&15);
FOR i:=199 DOWNTO 0 DO
        BEGIN
        setsprite(160,i,sprite,save);
        Vsync;
        clrsprite(save);
        END;
FOR i:=0 TO 99 DO
        BEGIN
        setcolor(i&15);
        drawline(10,i*2+1,310,199-i*2);
        END;

def_fill(muster[0],15,1);
frect(0,0,280,40);
settext(1,15,0,4,0);
FOR i:=0 TO 25 DO setchar(20+i*8,20,65+i,1);

r.start:=Physbase;
r.width:=320;
r.height:=200;
r.wwidth:=20;
r.format:=0;
r.planes:=4;
r.fut1:=0;
r.fut2:=0;
r.fut3:=0;

copy[0]:=10; copy[1]:=10; copy[2]:=70; copy[3]:=70;
copy[4]:=200; copy[5]:=100; copy[6]:=260; copy[7]:=160;

copy_raster(copy,r,r,3,0,0,0);

Waitkey;

Setscreen(-1,-1,res);
onmouse;
END.

