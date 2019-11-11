REM FastDisc Formatter By R.Waddilove
REM Speeds up loading/saving by 50%
REM Makes your discs go twice as fast
REM HiSoft Basic
REM $OPTION Y+

LIBRARY "gemaes"
LIBRARY "XBIOS"

REM ------------ Open window ------------------
button% = FNform_alert%(1,"[2][   Format the disc   |Single or Double sided?][Single|Double| Quit ]")
IF button% = 3 THEN SYSTEM
drive% = FNform_alert%(1,"[2][ Drive A or B ][ A | B ]")-1
dummy% = FNform_alert%(1,"[3][ Insert the disc | to be formatted ][ Format ]")

res% = FNgetrez%
IF res% THEN x%=184:y%=40 ELSE x%=24:y%=32
IF res%=2 THEN h%=120 ELSE h%=64
w% = 272

graf_growbox x%,y%,1,1,x%,y%,w%,h%
WINDOW OPEN 7," FastDisc Formatter ",x%,y%,w%,h%,1
WINDOW OUTPUT 7

REM ------------- Format disc -------------------
buffer$ = STRING$(10000,0)
sides% = button%-1
buffer& = SADD(buffer$)+1 AND &HFFFFFFFE
FOR track% = 0 TO 79
	dummy$ = INKEY$
	FOR side% = 0 TO sides%
		dummy% = FNflopfmt%(buffer&,0,drive%,9,track%,side%,11)
		GOTOXY 0,1:PRINT "   Formatting side";side%;"track";track%
	NEXT
NEXT

REM ---------------- Zero buffer ----------------
FOR i&=0 TO 10000-4 STEP 4
	POKEL buffer&+i&,0
NEXT

REM ---------- Write buffer to track 0 ----------
dummy% = FNflopwr%(buffer&,drive%,1,0,0,9)
IF sides%=1 THEN dummy% = FNflopwr%(buffer&,drive%,1,0,1,9) ELSE dummy% = FNflopwr%(buffer&,drive%,1,1,0,9)

REM ------------ Create boot sector -------------
IF sides%=1 THEN disctype%=1 ELSE disctype% = 2
protobt buffer&,&H1000000,disctype%,0

REM ------------ Write boot sector --------------
dummy% = FNflopwr%(buffer&,drive%,1,0,0,1)

GOTOXY 0,3:PRINT " Disc formatted ..... Click mouse"
WHILE ( MOUSE(2)=0 ) : WEND

WINDOW CLOSE 7
graf_shrinkbox x%,y%,1,1,x%,y%,w%,h%
SYSTEM
