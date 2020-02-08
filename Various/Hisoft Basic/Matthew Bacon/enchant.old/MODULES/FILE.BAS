
' [FILE.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DIM SHARED VerifyCopy,dta(21),FileAttr

FUNCTION CopyFile (source$,dest$,verify)
STATIC howmuch&,result&,mem&,dummy&,myfile,myfile2

IF NOT (FEXISTS(source$)) THEN CopyFile=0 : VerifyCopy=0 : EXIT FUNCTION
IF source$=dest$ THEN CopyFile=0 : VerifyCopy=0 : EXIT FUNCTION

myfile=FREEFILE
OPEN source$ FOR INPUT AS #myfile
howmuch&=LOF(myfile)
result&=malloc&(howmuch&)

IF result&>0 THEN
	BLOAD #myfile,result&,howmuch&
	BSAVE dest$,result&,howmuch&
	CLOSE #myfile
	junk=mfree(result&)
	CopyFile=-1
ELSE
	mem&=malloc&(-1)
	result&=malloc&(mem&)
	dummy&=howmuch&

	myfile2=FREEFILE
	OPEN dest$ FOR OUTPUT AS #myfile2
	DO
		dummy&=dummy&-mem&
		IF dummy&<0 THEN dummy&=dummy&+mem& : mem&=dummy& : dummy&=0
		BLOAD #myfile,result&,mem&
		BSAVE #myfile2,result&,mem&
	LOOP UNTIL dummy&=0
	CLOSE #myfile
	CLOSE #myfile2

	junk=mfree(result&)
	CopyFile=-1
END IF

IF verify<>0 THEN
	IF (FEXISTS(dest$)) THEN
		VerifyCopy=-1
	ELSE
		VerifyCopy=0
	END IF
END IF
END FUNCTION


FUNCTION FileError (toserr)
STATIC button,ErrorString$

MOUSE 0
SELECT CASE toserr
	CASE -2
		button=form_alert (1,"[1][  "+MyProgram$+": |  ERROR: Drive not ready! ][ Try Again | Cancel ]")
		SELECT CASE button
			CASE 1 : FileError=1
			CASE 2 : FileError=0
		END SELECT
	CASE -13
		button=form_alert (1,"[1][  "+MyProgram$+": |  ERROR: Disk 'Write protected!' ][ Try Again | Cancel ]")
		SELECT CASE button
			CASE 1 : FileError=1
			CASE 2 : FileError=0
		END SELECT
	CASE ELSE
		ErrorString$=ReportError$ (toserr)
		junk=form_alert(1,"[1][  "+MyProgram$+": |  ERROR: "+ErrorString$+" ][ Abort ]") : FileError=0
END SELECT
END FUNCTION


FUNCTION DeleteFile (source$)
STATIC toserr,result

redodelete:

toserr=fdelete (source$)
IF toserr<0 THEN
	DeleteFile=0
	result=FileError (toserr)
	IF result=0 THEN EXIT FUNCTION
	GOTO redodelete
END IF
DeleteFile=-1
END FUNCTION


FUNCTION dirback$ (source$)
STATIC i,char

i=LEN(source$)
DO
	char=ASC(MID$(source$,i,1))
	IF char="\"% OR char=":"% THEN EXIT LOOP
	IF i=1 THEN EXIT LOOP
	DECR i
LOOP UNTIL INKEY$=CHR$(27)
dirback$=LEFT$(source$,i)
END FUNCTION


FUNCTION dfolder (source$,dta&,ext$)
STATIC temp$,toserr,dummy$,i,char,result

redodeletef:

IF RIGHT$(source$,1)<>"\" THEN source$=source$+"\"
temp$=source$

toserr=fsfirst (source$+ext$,1+2+4+16+32)
IF toserr=-33 THEN
	IF ext$="*.*" THEN
		GOTO deletef
	ELSE
		dfolder=-1 : EXIT FUNCTION
	END IF
END IF
DO
	IF toserr<0 THEN
		dfolder=0
		IF PEEKB(dta&+21)<>16 THEN
			result=FileError (toserr)
			IF result=0 THEN EXIT FUNCTION
			GOTO redodeletef
		ELSE
			EXIT FUNCTION
		END IF
	ELSE
		dummy$=""
		FOR i=30 TO 43
			char=PEEKB(dta&+i)
			IF char=0 THEN EXIT FOR
			dummy$=dummy$+CHR$(char)
		NEXT i
		IF LEFT$(dummy$,1)<>"." THEN
			source$=temp$+dummy$

			IF PEEKB(dta&+21)<>16 THEN
				result=DeleteFile (source$)
				IF result=0 THEN dfolder=0 : EXIT FUNCTION
				toserr=fsnext
			ELSE
				IF ext$="*.*" THEN
					result=dfolder (source$,dta&,ext$)
					IF result=0 THEN dfolder=0 : EXIT FUNCTION
					IF RIGHT$(source$,1)="\" THEN source$=LEFT$(source$,LEN(source$)-1)
					source$=dirback$ (source$)
					temp$=source$
					IF RIGHT$(source$,1)<>"\" THEN source$=source$+"\"
					toserr=fsfirst (source$+ext$,1+2+4+16+32)
				ELSE
					toserr=fsnext
				END IF
			END IF
		ELSE
			toserr=fsnext
		END IF
	END IF
	IF INKEY$=CHR$(27) THEN SYSTEM
LOOP UNTIL toserr<>0

deletef:

IF RIGHT$(source$,1)<>"\" THEN source$=dirback$ (source$)
IF RIGHT$(source$,2)<>":\" THEN
	IF ext$="*.*" THEN
		toserr=ddelete (source$)
		IF toserr<0 THEN
			dfolder=0
			result=FileError (toserr)
			IF result=0 THEN EXIT FUNCTION
			GOTO redodeletef
		END IF
	END IF
END IF
dfolder=-1
END FUNCTION


FUNCTION DeleteFolder (source$,ext$)
STATIC result,dta&,olddta&

dta&=VARPTR(dta(0))
olddta&=fgetdta&
fsetdta dta&
IF ext$="" THEN ext$="*.*"
IF LEFT$(ext$,2)<>"*." THEN ext$="*."+ext$
result=dfolder (source$,dta&,ext$)
fsetdta olddta&
DeleteFolder=result
END FUNCTION


FUNCTION CreateFolder (source$)
STATIC toserr,result

redocreate:

toserr=dcreate (source$)
IF toserr<0 THEN
	CreateFolder=0
	result=FileError (toserr)
	IF result=0 THEN EXIT FUNCTION
	GOTO redocreate
END IF
CreateFolder=-1
END FUNCTION


FUNCTION RenameFile (source$,dest$)
STATIC toserr,result

redorename:

toserr=frename (source$,dest$)
IF toserr<0 THEN
	RenameFile=0
	result=FileError (toserr)
	IF result=0 THEN EXIT FUNCTION
	GOTO redorename
END IF
RenameFile=-1
END FUNCTION


FUNCTION FileAttributes (source$,attribute,assign)
STATIC toserr,result

redoattr:

IF assign<>0 THEN assign=1
toserr=fattrib (source$,assign,attribute)
IF toserr<0 THEN
	FileAttributes=0
	result=FileError (toserr)
	IF result=0 THEN EXIT FUNCTION
	GOTO redoattr
END IF
FileAttr=toserr
FileAttributes=-1
END FUNCTION


FUNCTION memfree&
	memfree&=malloc& (-1)
END FUNCTION

'[*END OF FILE*]
