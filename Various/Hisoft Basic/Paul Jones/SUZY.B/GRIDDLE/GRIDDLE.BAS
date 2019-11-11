REM Griddles
REM By R.A.Waddilove
REM HiSoft Basic

DEFINT a-z

PALETTE 0,&H000
PALETTE 1,&H077
PALETTE 2,&H007
PALETTE 3,&H777
PALETTE 4,&H770
PALETTE 5,&H700
PALETTE 6,&H070
PALETTE 7,&H707

MOUSE -1

DIM s(15,15),b(15,15)

WINDOW FULLW 2

DO
	GOSUB init:
	gen=0
	DO
		CLEARW 2
		FOR y=0 TO 150 STEP 64
			FOR x=0 TO 250 STEP 62
				GOSUB prints
				GOSUB nextgen
				gen=gen+1
			NEXT
		NEXT
		COLOR 3
		GOTOXY 0,21
		PRINT "More? (Y/N)";
		GOSUB readkey
	LOOP UNTIL k$="N" OR k$="n"
	GOTOXY 0,21
	PRINT "New grid? (Y/N)";
	GOSUB readkey
LOOP UNTIL k$="N" OR k$="n"
MOUSE 0
SYSTEM

REM ------ Read the keyboard --------
readkey:
DO
	k$=INKEY$
LOOP UNTIL k$<>""
RETURN

REM --------- Initialise ------------
init:
DO
	CLEARW 2
	COLOR 4
	PRINT "Griddles..."
	PRINT "============"
	PRINT
	COLOR 1
	INPUT "Grid size (4-12)";m
	PRINT
	INPUT "Number of colours (2-8)";c
LOOP UNTIL (m>3 AND m<13) AND (c>1 AND c<9)
FOR i=0 TO 15
	FOR j=0 TO 15
		s(i,j)=0
	NEXT
NEXT
FOR i=1 TO m
	FOR j=1 TO m
		s(i,j)=1
	NEXT
NEXT
RETURN

REM --- Calculate next generation ---
nextgen:
FOR i=1 TO m
	FOR j=1 TO m
		color 0,s(i,j),0,8,2
		bar x+i*4+2*(12-m),y+j*4+2*(12-m),2,2
		t=0
		t=s(i-1,j)+s(i+1,j)+s(i,j-1)+s(i,j+1)+s(i-1,j-1)+s(i+1,j-1)+s(i-1,j+1)+s(i+1,j+1)
		b(i,j)=t MOD c
	NEXT
NEXT
FOR i=1 TO m
	FOR j=1 TO m
		s(i,j)=b(i,j)
	NEXT
NEXT
RETURN

REM --- Print colours/generation ----
prints:
k$=STR$(c)+":"+STR$(gen)
DO
	i=INSTR(k$," ")
	IF i THEN k$=LEFT$(k$,i-1)+MID$(k$,i+1)
LOOP UNTIL i=0
COLOR 4
GOTOXY 1+7*x/62,6+7*y/64
PRINT k$
RETURN
