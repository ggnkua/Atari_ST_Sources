LIBRARY "gemdos"
DEFINT a-z

REM $option k10

c$="D:\GEMMALOG.GIF"

OPEN c$ FOR INPUT AS #1
l&=LOF(1)
CLOSE #1

x&=malloc&(l&)

BLOAD c$,x&

REM 7-6=x 9-8=y (swap around)

PRINT "File:"+c$

x1=SPEEKB(x&+6)
x2=SPEEKB(x&+7)

x$="&H"+HEX$(x2)+HEX$(x1)
IF x1=0 THEN x$=x$+"0"
PRINT "X size:";VAL(x$)

y1=SPEEKB(x&+8)
y2=SPEEKB(x&+9)
y$="&H"+HEX$(y2)+HEX$(y1)
IF y1=0 THEN y$=y$+"0"
PRINT "Y size:";VAL(y$)