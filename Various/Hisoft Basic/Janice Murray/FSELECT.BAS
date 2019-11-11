REM HiSoft BASIC file selector

LIBRARY "GEMAES","GEMDOS"

WINDOW FULLW 2 : CLS
file$ = FNfilename$
PRINT : PRINT "You chose: ";file$
END

DEF FNfilename$
path$ = CHR$(65+FNdgetdrv%) + ":\*.*"
ok% = 0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$ = LEFT$(path$,LEN(path$)-1)
WEND
IF ok% = 0 OR name$="" THEN path$="" : name$=""
CLS
FNfilename$ = path$ + name$
END DEF
