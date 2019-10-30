REM Display an IMG file
REM By R.A.Waddilove
REM HiSoft Basic
REM 2/4/89

LIBRARY "GEMAES"
LIBRARY "XBIOS"

WINDOW FULLW 2
CLEARW 2

maxy&=2000 : 'assumes width=100 bytes
buffer$=STRING$(100*maxy&+100,0)
file$=FNfilename$
OPEN "I",#1,file$,1
version%=FNword
header%=FNword
planes%=FNword
patlen%=FNword
widthpix%=FNword
heightpix%=FNword
width%=FNword
height%=FNword
IF height%>maxy& THEN height%=maxy&
CLOSE #1

OPEN "I",#1,file$,1
FOR i%=1 TO header%*2
	dummy$=INPUT$(1,#1)
NEXT

buffer&=(SADD(buffer$)+1) AND &HFFFFFFFE
y&=0:repcount%=0
DO
	dummy$=INKEY$
	A&=buffer&+100*y&
	F%=ASC(INPUT$(1,#1))
	IF F%=0 THEN
		F%=ASC(INPUT$(1,#1))
		IF F% THEN CALL pattern_run ELSE dummy$=INPUT$(1,#1):repcount%=ASC(INPUT$(1,#1))
	ELSE
		CALL scanline
		IF repcount% THEN CALL copy:repcount%=0
	END IF
LOOP UNTIL y&>=height%
CLOSE #1
CALL display
CALL picsave
SYSTEM

SUB picsave
SHARED file$
alert$="[2][Save Degas picture][Yes|No]"
MOUSE 0
button%=FNform_alert%(1,alert$)
MOUSE -1
IF button%=2 THEN EXIT SUB
screen&=FNlogbase&
i%=INSTR(file$,".")
file$=LEFT$(file$,i%)+"PI3"
OPEN "R",#1,file$,1
FIELD #1,1 AS pad$
LSET pad$=CHR$(0) : PUT #1
LSET pad$=CHR$(2) : PUT #1
LSET pad$=CHR$(7) : PUT #1
LSET pad$=CHR$(119) : PUT #1
FOR i&=4 to 33
	LSET pad$=CHR$(0) : PUT #1
NEXT
FOR i&=screen& TO screen&+31999
	LSET pad$=CHR$(PEEKB(i&)) : PUT #1
NEXT
CLOSE #1
END SUB

SUB scanline
SHARED x%,F%,width%,y&
x%=0
DO
	IF F%=0 THEN CALL pattern_run
	IF F%=&H80 THEN CALL bit_string
	IF F%>0 AND F%<>&H80 THEN CALL solid_run
	IF (x%<width%\8) THEN F%=ASC(INPUT$(1,#1))
LOOP UNTIL x%>=(width%\8)
INCR y&
END SUB

SUB copy
SHARED y&,repcount%,x%,A&,buffer&,height%
DECR y&
FOR I%=1 TO repcount%
	FOR i&=A& TO A&+99
		POKEB i&+100,PEEKB(i&)
	NEXT
	IF y&<height% THEN INCR y&
	A&=buffer&+100*y&
NEXT
END SUB

SUB pattern_run
SHARED A&,x%
runlen%=ASC(INPUT$(1,#1))
patbyte1%=ASC(INPUT$(1,#1))
patbyte2%=ASC(INPUT$(1,#1))
FOR i%=1 TO runlen%
	POKEB A&+x%,patbyte1%
	POKEB A&+x%+1,patbyte2%
	x%=x%+2
NEXT
END SUB

SUB bit_string
SHARED A&,x%
runlen%=ASC(INPUT$(1,#1))
FOR x%=x% TO x%+runlen%-1
	byte%=ASC(INPUT$(1,#1))
	POKEB A&+x%,byte%
NEXT
END SUB

SUB solid_run
SHARED F%,A&,x%
IF (F% AND &H80) THEN byte%=&HFF ELSE byte%=0
count%=F% AND 127
FOR x%=x% TO x%+count%-1
	POKEB A&+x%,byte%
NEXT
END SUB

DEF FNword
FNword=256*ASC(INPUT$(1,#1))+ASC(INPUT$(1,#1))
END DEF

SUB display
SHARED buffer&,height%,width%
DIM code%(25)
mcode&=VARPTR(code%(0))
FOR i%=0 TO 43
	READ byte$
	POKEB mcode&+i%,VAL("&H"+byte$)
NEXT
y&=0:x&=0
DO
	buf&=buffer&+100*y&+x&
	CALL LOC mcode&,buf&
	key%=INP(2)
	IF key%=200 AND (y&+392)<height% THEN y&=y&+8
	IF key%=208 AND y&>0 THEN y&=y&-8
	IF key%=205 AND x&>0 THEN x&=x&-2
	IF key%=203 AND (x&+80)<(width%\8) THEN x&=x&+2
LOOP UNTIL key%=115 OR key%=83
END SUB

DATA "3F","3C","00","02","4E","4E"
DATA "54","8F","22","40","20","6F"
DATA "00","06","20","50","30","3C"
DATA "01","8F","24","48","32","3C"
DATA "00","13","22","DA","51","C9"
DATA "FF","FC","D1","FC","00","00"
DATA "00","64","51","C8","FF","EC"
DATA "4E","75"

DEF FNfilename$
MOUSE 0
path$="A:\*.*"
name$=""
ok%=0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$=LEFT$(path$,LEN(path$)-1)
WEND
MOUSE -1
CLEARW 2
FNfilename$=path$+name$
END DEF
