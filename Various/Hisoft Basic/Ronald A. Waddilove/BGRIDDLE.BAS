REM 2D Life
REM By R.A.Waddilove
REM HiSoft Basic

LIBRARY "XBIOS"
DEFINT a-z

res=FNgetrez%

PALETTE 0,&H000
PALETTE 1,&H077
PALETTE 2,&H007
PALETTE 3,&H777
PALETTE 4,&H770
PALETTE 5,&H700
PALETTE 6,&H070
PALETTE 7,&H770
PALETTE 8,&H707

MOUSE -1

IF res=2 THEN size=4 ELSE size=2

DIM s(40,40),b(40,40)
DIM x(50),y(40)
scr$=STRING$(33000,0)

screen2&=256+SADD(scr$) AND &HFFFFFF00
screen1&=FNphysbase&

WINDOW FULLW 2

DO
DO
	CLEARW 2
	COLOR 1
	PRINT "Griddles..."
	PRINT "============"
	PRINT
	INPUT "Grid size (5-40)";m:m=m-1
	PRINT
	INPUT "Number of colours (2-8)";c
LOOP UNTIL (m>3 AND m<40) AND (c>1 AND c<9)
CLEARW 2
FOR i=0 TO 40
IF res THEN
	x(i)=320-(size+2)*m/2+i*(size+2) : y(i)=200-(size+2)*m/2+i*(size+2)
ELSE
	x(i)=160-(size+2)*m/2+i*(size+2) : y(i)=100-(size+2)*m/2+i*(size+2)
END IF
NEXT
' Initialise array to 1st colour
FOR i=0 TO m
FOR j=0 TO m
s(i,j)=1
NEXT
NEXT

flag=0
gen=0
DO
GOSUB flip
FOR i=0 TO m
FOR j=0 TO m
IF res THEN COLOR 0,1,0,2*s(i,j),2 ELSE color 0,s(i,j),0,8,2
bar x(i),y(j),size,size
t=0
IF i>0 AND j>0 AND i<m and j<m THEN
	t=s(i-1,j)+s(i+1,j)+s(i,j-1)+s(i,j+1)+s(i-1,j-1)+s(i+1,j-1)+s(i-1,j+1)+s(i+1,j+1)
ELSE
	GOSUB count
END IF
b(i,j)=t MOD c
NEXT
NEXT

FOR i=0 TO m
FOR j=0 TO m
s(i,j)=b(i,j)
NEXT
NEXT

COLOR 4:GOTOXY 8,0:?"Griddle generation:";gen
COLOR 1:GOTOXY 3,21:?"Press S to stop, Space to restart";
gen=gen+1

k$=INKEY$
LOOP UNTIL k$<>""
CLEARW 2 : GOSUB flip : CLEARW 2
SETSCREEN screen1&,screen1&,-1
LOOP UNTIL k$="S" OR k$="s"
MOUSE 0
SYSTEM

count:
IF i>0 THEN t=t+s(i-1,j) : IF j>0 THEN t=t+s(i-1,j-1)
IF i<m THEN t=t+s(i+1,j) : IF j>0 THEN t=t+s(i+1,j-1)
IF j>0 THEN t=t+s(i,j-1)
IF j<m THEN t=t+s(i,j+1) : IF i>0 THEN t=t+s(i-1,j+1)
IF i<m AND j<m THEN t=t+s(i+1,j+1)
RETURN

flip:
flag=flag XOR 1
IF flag THEN
	SETSCREEN screen2&,screen1&,-1
ELSE
	SETSCREEN screen1&,screen2&,-1
END IF
RETURN
