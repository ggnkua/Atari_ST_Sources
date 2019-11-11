REM Word Counter
REM Written in HiSoft Basic
REM By R.A.Waddilove

LIBRARY "GEMAES"

WINDOW CLOSE
alert$="[0][Enter file | to count][Ok]" : button%=FNform_alert%(1,alert$)
file$=FNfilename$
OPEN file$ FOR INPUT AS #1
buffer$=INPUT$(LOF(1),#1)
CLOSE #1

count%=0
ptr&=SADD(buffer$)
buffend&=ptr&+LEN(buffer$)
WHILE ptr&<buffend&
	IF (PEEKB(ptr&)>32 AND PEEKB(ptr&)<127) THEN INCR count% : CALL inword
	INCR ptr&
WEND
alert$="[0][ "+file$+"="+STR$(count%)+" words][Quit|Another]"
button%=FNform_alert%(1,alert$)
IF button%=2 THEN RUN
SYSTEM

SUB inword
SHARED ptr&,buffend&,byte%
DO
	INCR ptr&
LOOP UNTIL PEEKB(ptr&)<33 OR PEEKB(ptr&)>126 OR ptr&>buffend&
END SUB

DEF FNfilename$
path$="A:\*.*"
name$=""
ok%=0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$=LEFT$(path$,LEN(path$)-1)
WEND
FNfilename$=path$+name$
END DEF
