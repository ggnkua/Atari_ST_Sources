
' [CYPHER.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

SUB cypher_text(BYVAL sourcefile$,BYVAL destfile$,BYVAL security_level,BYVAL password$)
STATIC myfile,myfile2,sourcetext$,desttext$,key$,mask$,binary$
STATIC dummy$,dummy,length&,total_length&,read_length&

IF NOT FEXISTS(sourcefile$) THEN
	junk=form_alert(1,"[1][  "+MyProgram$+": |  The source file does not |  exist! ][ Abort ]")
	EXIT SUB
ELSE
	IF sourcefile$=destfile$ THEN
		junk=form_alert(1,"[1][  "+MyProgram$+": |  The source file cannot be |  the destination file! ][ Abort ]")
		EXIT SUB
	END IF
END IF

MOUSE 2
dummy$=""
password$=LEFT$(password$,security_level/8)

key$=""
FOR dummy=1 TO LEN(password$) 
	key$=key$+BIN$(ASC(MID$(password$,dummy,1)))
NEXT dummy

myfile=FREEFILE
OPEN sourcefile$ FOR INPUT AS #myfile
total_length&=LOF(myfile)

myfile2=FREEFILE
OPEN destfile$ FOR OUTPUT AS #myfile2
length&=0

WHILE length&<total_length&
	IF length&+LEN(password$)>=total_length& THEN
		read_length&=total_length&-length&
	ELSE
		read_length&=LEN(password$)
	END IF
	sourcetext$=INPUT$(read_length&,#myfile)
	length&=length&+LEN(password$)

	binary$=""
	FOR dummy=1 TO LEN(sourcetext$)
		dummy$="00000000"
		MID$(dummy$,9-LEN(BIN$(ASC(MID$(sourcetext$,dummy,1)))),8)=BIN$(ASC(MID$(sourcetext$,dummy,1)))
		binary$=binary$+dummy$
	NEXT dummy

	mask$=""
	FOR dummy=1 TO (LEN(binary$)/LEN(key$))+1
		mask$=mask$+key$
	NEXT dummy
	mask$=LEFT$(mask$,LEN(binary$))

	FOR dummy=1 TO LEN(binary$)
		IF MID$(mask$,dummy,1)="1" THEN
			IF MID$(binary$,dummy,1)="1" THEN
				MID$(binary$,dummy,1)="0"
			ELSE
				MID$(binary$,dummy,1)="1"
			END IF
		END IF
	NEXT dummy

	desttext$=""
	FOR dummy=1 TO LEN(binary$)
		desttext$=desttext$+CHR$(VAL("&b"+MID$(binary$,dummy,8)))
		dummy=dummy+7
	NEXT dummy

	BSAVE #myfile2,VARPTR(desttext$),LEN(desttext$)
	IF INKEY$=CHR$(27) THEN EXIT WHILE
WEND

CLOSE #myfile
CLOSE #myfile2
MOUSE 0
END SUB

'[*END OF FILE*]
