REM READ_ME.PRG
REM By R.A.Waddilove
REM Last altered 2/7/89
REM $OPTION Y+

LIBRARY "GEMAES"
LIBRARY "XBIOS"

REM ------------ Open window ------------------
res% = FNgetrez%
x%=16:y%=24:h%=368:w%=608:linelen%=74:maxline%=18
IF res%<2 THEN y%=16:h%=176:maxline%=16
IF res%=0 THEN x%=2:w%=314:linelen%=38
WINDOW OPEN 7," Atari ST User Disc Information ",x%,y%,w%,h%,1
WINDOW OUTPUT 7

REM ---------- Load INFO.STW ----------------
OPEN "READ_ME.STW" FOR INPUT AS #1
buffer$=INPUT$(LOF(1),#1)
CLOSE #1

REM ------------ Print file ------------------
ptr& = SADD(buffer$)+&H22
lines% = 0
a$=""
DO
	char% = PEEKB(ptr&) : INCR ptr&
	IF char% THEN a$=a$+CHR$(char%) ELSE INCR lines% : PRINT " ";a$ : a$=""
	IF LEN(a$)=linelen% THEN INCR lines% : GOSUB slice
	IF lines%>maxline% THEN lines%=0 : GOSUB pause
LOOP UNTIL ( ptr&-SADD(buffer$)>LEN(buffer$) )
GOSUB pause
WINDOW CLOSE 7
SYSTEM

slice:
i%=LEN(a$)
DO
	DECR i%
	c$=MID$(a$,i%,1)
LOOP UNTIL c$=" " OR c$="-" OR c$="," OR c$="."
PRINT " ";LEFT$(a$,i%)
a$=MID$(a$,i%+1)
RETURN

pause:
PRINT " (Click the mouse...)";
WHILE ( MOUSE(2)=0 ) : WEND
CLEARW 7
RETURN

DEF FNfilename$
path$="A:\*.*"
name$=""
ok%=0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
path$=LEFT$(path$,LEN(path$)-1)
WEND
CHDIR path$
FNfilename$=path$+name$
END DEF
