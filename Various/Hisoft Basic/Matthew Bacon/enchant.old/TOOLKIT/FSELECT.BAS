
' [FSELECT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' Developed from an idea by Gary Bell - ½ 1998 Gary Bell

CONST nameonly=0,pathonly=1,fullname=2

FUNCTION FileSelect$ (fsname$,BYVAL fsmode)
SHARED fspath$,fsmessage$
STATIC ok,dummy,char

IF fspath$="" THEN CALL InitFileSelector
IF PEEKW(PEEKL(GB+4))<&h130 THEN
	fsel_input fspath$,fsname$,ok
ELSE
	fsel_exinput fspath$,fsname$,ok,fsmessage$
END IF
IF ok THEN
	dummy=LEN(fspath$)
	DO
		char=ASC(MID$(fspath$,dummy,1))
		IF char="\"% OR char=":"% THEN EXIT LOOP
		IF dummy=1 THEN EXIT LOOP
		DECR dummy
	LOOP
	fspath$=LEFT$(fspath$,dummy)
	SELECT CASE fsmode
		CASE NAMEONLY : FileSelect$=fsname$
		CASE PATHONLY : FileSelect$=fspath$
		CASE FULLNAME : FileSelect$=fspath$+fsname$
		CASE ELSE : FileSelect$=fspath$+fsname$
	END SELECT
ELSE
	FileSelect$=""
END IF
END FUNCTION


SUB InitFileSelector
SHARED fspath$,fsname$,fsmode
fspath$=CURDIR$+"\*.*" : fsname$=""
fsmode=-1
END SUB

'[*END OF FILE*]
