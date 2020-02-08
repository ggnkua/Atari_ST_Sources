
' [DATETIME.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION conv$ (value&,size&)
STATIC dummy$
dummy$=BIN$(value&)
IF LEN(dummy$)<size& THEN dummy$=STRING$(size&-LEN(dummy$),"0")+dummy$
conv$=dummy$
END FUNCTION


SUB getform
SHARED datform,timeform,sep
STATIC result,vau$,vau&

result=GETCOOKIE ("_IDT",vau&)
IF result=-1 THEN
	vau$=BIN$(vau&)
	sep=VAL("&B"+MID$(vau$,LEN(vau$)-7,8))
	IF sep=0 THEN sep=ASC("/")
	vau$=conv$ (vau&,31)
	datform=VAL("&B"+MID$(vau$,LEN(vau$)-11,4))
	timeform=VAL("&B"+MID$(vau$,LEN(vau$)-15,4))
ELSE
	sep=ASC("/")
	datform=1 : timeform=0
END IF
END SUB


FUNCTION txtcon$ (value&,size&)
STATIC a$,b$

a$=STR$(value&)
b$=RIGHT$(a$,LEN(a$)-1)
IF LEN(b$)<size& THEN
	txtcon$=STRING$(size&-LEN(b$),"0")+b$
ELSEIF LEN(b$)>size& THEN
	txtcon$=MID$(b$,size&)
ELSE
	txtcon$=b$
END IF
END FUNCTION


FUNCTION dateform$ (form,seperator$)
SHARED datform,sep
STATIC dummy$,day,month,year,dummy

dummy$=BIN$(tgetdate)
day=VAL("&B"+MID$(dummy$,LEN(dummy$)-4,5))
month=VAL("&B"+MID$(dummy$,LEN(dummy$)-8,4))
dummy=LEN(dummy$)-9
year=1980+VAL("&B"+MID$(dummy$,1,dummy))

IF form=-1 THEN
	CALL getform
ELSE
	datform=form
END IF

IF ASC(seperator$)>0 THEN sep=ASC(seperator$)

SELECT CASE datform
	CASE 0
		dateform$=txtcon$(month,2)+CHR$(sep)+txtcon$(day,2)+CHR$(sep)+txtcon$(year,4)
	CASE 1
		dateform$=txtcon$(day,2)+CHR$(sep)+txtcon$(month,2)+CHR$(sep)+txtcon$(year,4)
	CASE 2
		dateform$=txtcon$(year,4)+CHR$(sep)+txtcon$(month,2)+CHR$(sep)+txtcon$(day,2)
	CASE 3
		dateform$=txtcon$(year,4)+CHR$(sep)+txtcon$(day,2)+CHR$(sep)+txtcon$(month,2)
END SELECT
END FUNCTION


FUNCTION timeform$ (form)
SHARED timeform
STATIC hour,minute,second,timeform,dummy$,ampm$

dummy$=TIME$
REM hh:mm:ss

IF form=-1 THEN
	CALL getform
ELSE
	timeform=form
END IF

hour=VAL(MID$(dummy$,1,2))
minute=VAL(MID$(dummy$,4,2))
second=VAL(MID$(dummy$,7,2))

SELECT CASE timeform
	CASE 0
		ampm$="am"
		IF hour>12 THEN hour=hour-12 : ampm$="pm"
		timeform$=txtcon$(hour,2)+":"+txtcon$(minute,2)+":"+txtcon$(second,2)+ampm$
	CASE 1
		timeform$=txtcon$(hour,2)+":"+txtcon$(minute,2)+":"+txtcon$(second,2)
END SELECT
END FUNCTION

'[*END OF FILE*]
