
' [CYPHER.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION ENCODE_ULTIMO$ (source$,keyword$,range_frm$,range_too$)
STATIC i,dummy,kwrd,cypher$,range_frm,range_too

range_frm=ASC(range_frm$) : range_too=ASC(range_too$) : kwrd=LEN(keyword$)
IF range_frm<1 THEN range_frm=1 : IF range_too>255 THEN range_too=255
IF kwrd<3 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  The keyword should contain |  a minimum of 3 characters. ][ Abort ]")
	ENCODE_ULTIMO$=""
	EXIT FUNCTION
END IF

cypher$="" : kwrd=0
FOR i=1 to LEN(source$)
	incr kwrd : IF kwrd>LEN(keyword$) THEN kwrd=1
	dummy=ASC(MID$(source$,i,1))
	SELECT CASE dummy
		CASE <range_frm : cypher$=cypher$+CHR$(dummy)
		CASE range_frm TO range_too
			dummy=ASC(MID$(source$,i,1))+ASC(MID$(keyword$,kwrd,1))
			DO
			SELECT CASE dummy
				CASE <range_frm : dummy=ASC(MID$(source$,i,1)) : EXIT LOOP
				CASE range_frm TO range_too : EXIT LOOP
				CASE >range_too
					dummy=range_frm+(dummy-range_too)-1
			END SELECT
			LOOP UNTIL INKEY$=CHR$(27)
			cypher$=cypher$+CHR$(dummy)
		CASE >range_too : cypher$=cypher$+CHR$(dummy)
	END SELECT
NEXT i
ENCODE_ULTIMO$=cypher$
END FUNCTION


FUNCTION DECODE_ULTIMO$ (source$,keyword$,range_frm$,range_too$)
STATIC i,dummy,kwrd,cypher$,range_frm,range_too

range_frm=ASC(range_frm$) : range_too=ASC(range_too$) : kwrd=LEN(keyword$)
IF range_frm<1 THEN range_frm=1 : IF range_too>255 THEN range_too=255
IF kwrd<3 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  The keyword should contain |  a minimum of 3 characters. ][ Abort ]")
	DECODE_ULTIMO$=""
	EXIT FUNCTION
END IF

cypher$="" : kwrd=0
FOR i=1 to LEN(source$)
	incr kwrd : IF kwrd>LEN(keyword$) THEN kwrd=1
	dummy=ASC(MID$(source$,i,1))
	SELECT CASE dummy
		CASE <range_frm : cypher$=cypher$+CHR$(dummy)
		CASE range_frm TO range_too
			dummy=ASC(MID$(source$,i,1))-ASC(MID$(keyword$,kwrd,1))
			DO
			SELECT CASE dummy
				CASE <range_frm
					dummy=range_too-(range_frm-dummy)+1
				CASE range_frm TO range_too : EXIT LOOP
				CASE >range_too
					dummy=ASC(MID$(source$,i,1)) : EXIT LOOP
			END SELECT
			LOOP UNTIL INKEY$=CHR$(27)
			cypher$=cypher$+CHR$(dummy)
		CASE >range_too : cypher$=cypher$+CHR$(dummy)
	END SELECT
NEXT i
DECODE_ULTIMO$=cypher$
END FUNCTION

DIM SHARED original$(255),rotor0$(255)

SUB CreateENIGMA (from_char$,too_char$,exceptions$,frequency!)
STATIC rotor1$,rotor2$,rotor3$,reflector$,dummy
STATIC i,char,ok,again,total_exceptions,Rand!,trouble,percent,myfile
STATIC from_char,too_char,temp$,temp,temp2$,temp2,rot,total_entries

i=0 : from_char=ASC(from_char$) : too_char=ASC(too_char$)
IF from_char<14 THEN from_char=14 : IF too_char>255 THEN too_char=255
FOR char=from_char TO too_char
	IF char<>26 THEN INCR i : original$(i)=CHR$(char) : rotor0$(i)=CHR$(char)
NEXT char

total_exceptions=LEN(exceptions$)
IF total_exceptions>0 THEN
	FOR char=1 TO total_exceptions
		ok=1
		FOR again=1 TO i
			IF ASC(MID$(exceptions$,char,1))=26 THEN ok=0
			IF ASC(MID$(exceptions$,char,1))<14 THEN ok=0
			IF ASC(MID$(exceptions$,char,1))>255 THEN ok=0
			IF original$(again)=MID$(exceptions$,char,1) THEN ok=0
		NEXT again
		IF ok=1 THEN INCR i : original$(i)=MID$(exceptions$,char,1)
		IF ok=1 THEN rotor0$(i)=MID$(exceptions$,char,1)
	NEXT char
END IF
total_entries=i
IF total_entries<1 THEN EXIT SUB

rotor1$="" : rotor2$="" : rotor3$=""
FOR rot=1 TO 3
char=0
DO
	FOR i=1 TO total_entries
		RANDOMIZE TIMER : Rand!=RND
		IF Rand!>frequency! THEN
			IF original$(i)<>"" THEN
				trouble=ASC(original$(i))
				SELECT CASE trouble
					CASE 14 TO 255
						INCR char : temp$=original$(i) : original$(i)=""
					CASE ELSE
						INCR char : original$(i)=""
				END SELECT

				SELECT CASE rot
				CASE 1: rotor1$=rotor1$+temp$
				CASE 2: rotor2$=rotor2$+temp$
				CASE 3: rotor3$=rotor3$+temp$
				END SELECT
			END IF
			percent=(100/total_entries)*char
			IF char=total_entries THEN EXIT LOOP
			FOR temp=1 TO 2000

			NEXT temp
		END IF
	NEXT i
	IF INKEY$=CHR$(27) THEN EXIT SUB
LOOP
FOR i=1 TO total_entries
	original$(i)=rotor0$(i)
NEXT i
NEXT rot

ok=0 : char=0 : reflector$=STRING$(total_entries,2)
DO
FOR i=1 TO total_entries
	RANDOMIZE TIMER : Rand!=RND
	IF Rand!>frequency! THEN
		IF original$(i)<>"" THEN
			trouble=ASC(original$(i))
			SELECT CASE trouble
				CASE 14 TO 255
					INCR char : temp$=original$(i) : original$(i)=""
				CASE ELSE
					INCR char : original$(i)=""
			END SELECT
			INCR ok
			IF ok=1 THEN temp2$=temp$ : temp2=i
			IF ok=2 THEN
				ok=0 : MID$(reflector$,temp2,1)=temp$
				MID$(reflector$,i,1)=temp2$
			END IF
		END IF
		percent=(100/total_entries)*char
		IF char=total_entries THEN EXIT LOOP
		FOR temp=1 TO 2200

		NEXT temp
	END IF
NEXT i
IF INKEY$=CHR$(27) THEN EXIT SUB
LOOP

FOR i=1 TO total_entries
	rotor0$(0)=rotor0$(0)+rotor0$(i)
NEXT i
FOR i=1 TO total_entries
	IF MID$(reflector$,i,1)=CHR$(2) THEN MID$(reflector$,i,1)=MID$(rotor0$(0),i,1)
NEXT i

myfile=FREEFILE
OPEN CURDIR$+"\ENIGMA.DAT" FOR OUTPUT AS #myfile
	PRINT #myfile,rotor0$(0)
	PRINT #myfile,rotor1$
	PRINT #myfile,rotor2$
	PRINT #myfile,rotor3$
	PRINT #myfile,LEFT$(reflector$,LEN(rotor0$(0)))
CLOSE #myfile
END SUB


FUNCTION CharPos (a$,b$)
STATIC i

FOR i=1 TO LEN(b$)
	IF a$=MID$(b$,i,1) THEN CharPos=i : EXIT FOR
NEXT i
END FUNCTION


FUNCTION ENIGMA$ (source$,rotor1$,rotor2$,rotor3$,currot,r1out$,r2out$,r3out$,currotout)
STATIC rot0$,rot1$,rot2$,rot3$,reflector$,i,char$,position,myfile
STATIC rot1pos,rot2pos,rot3pos,a$,CYPHERTEXT$,currot

CYPHERTEXT$=""
r1out$=""
r2out$=""
r3out$=""
IF FEXISTS (CURDIR$+"\ENIGMA.DAT") THEN
	myfile=FREEFILE
	OPEN CURDIR$+"\ENIGMA.DAT" FOR INPUT AS #myfile
		LINE INPUT #myfile,rot0$
		LINE INPUT #myfile,rot1$
		LINE INPUT #myfile,rot2$
		LINE INPUT #myfile,rot3$
		LINE INPUT #myfile,reflector$
	CLOSE #myfile
ELSE
	ENIGMA$="" : EXIT FUNCTION
END IF

IF rot0$="" THEN ENIGMA$="" : EXIT FUNCTION
IF rot1$="" THEN ENIGMA$="" : EXIT FUNCTION
IF rot2$="" THEN ENIGMA$="" : EXIT FUNCTION
IF rot3$="" THEN ENIGMA$="" : EXIT FUNCTION
IF reflector$="" THEN ENIGMA$="" : EXIT FUNCTION

rot1pos=1 : rot2pos=1 : rot3pos=1

FOR i=1 TO LEN(rot1$)
	IF rotor1$=MID$(rot1$,i,1) THEN EXIT FOR
	INCR rot1pos
NEXT i
rot1$=RIGHT$(rot1$,LEN(rot1$)-rot1pos+1)+LEFT$(rot1$,rot1pos)

FOR i=1 TO LEN(rot2$)
	IF rotor2$=MID$(rot2$,i,1) THEN EXIT FOR
	INCR rot2pos
NEXT i
rot2$=RIGHT$(rot2$,LEN(rot2$)-rot2pos+1)+LEFT$(rot2$,rot2pos)

FOR i=1 TO LEN(rot3$)
	IF rotor3$=MID$(rot3$,i,1) THEN EXIT FOR
	INCR rot3pos
NEXT i
rot3$=RIGHT$(rot3$,LEN(rot3$)-rot3pos+1)+LEFT$(rot3$,rot3pos)

FOR i=1 TO LEN(source$)
next_char:
	position=CharPos (MID$(source$,i,1),rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot1$,position,1)
	position=CharPos (char$,rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot2$,position,1)
	position=CharPos (char$,rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot3$,position,1)
	position=CharPos (char$,rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(reflector$,position,1)
	position=CharPos (char$,rot3$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot0$,position,1)
	position=CharPos (char$,rot2$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot0$,position,1)
	position=CharPos (char$,rot1$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot0$,position,1)
	CYPHERTEXT$=CYPHERTEXT$+char$

	SELECT CASE currot
		CASE 1
			IF rot1pos<>LEN(rot1$) THEN
				INCR rot1pos
				rot1$=RIGHT$(rot1$,LEN(rot1$)-1)+LEFT$(rot1$,1)
			ELSE
				rot1$=RIGHT$(rot1$,LEN(rot1$)-1)+LEFT$(rot1$,1)
				rot2$=RIGHT$(rot2$,LEN(rot2$)-1)+LEFT$(rot2$,1)
				rot1pos=1 : INCR rot2pos : currot=2
			END IF
		CASE 2
			IF rot2pos<>LEN(rot2$) THEN
				INCR rot2pos
				rot2$=RIGHT$(rot2$,LEN(rot2$)-1)+LEFT$(rot2$,1)
			ELSE
				rot2$=RIGHT$(rot2$,LEN(rot2$)-1)+LEFT$(rot2$,1)
				rot3$=RIGHT$(rot3$,LEN(rot3$)-1)+LEFT$(rot3$,1)
				rot2pos=1 : INCR rot3pos : currot=3
			END IF
		CASE 3
			IF rot3pos<>LEN(rot3$) THEN
				INCR rot3pos
				rot3$=RIGHT$(rot3$,LEN(rot3$)-1)+LEFT$(rot3$,1)
			ELSE
				rot3$=RIGHT$(rot3$,LEN(rot3$)-1)+LEFT$(rot3$,1)
				rot3pos=1 : currot=1
			END IF
	END SELECT
NEXT i
ENIGMA$=CYPHERTEXT$
r1out$=LEFT$(rot1$,1)
r2out$=LEFT$(rot2$,1)
r3out$=LEFT$(rot3$,1)
currotout=currot
END FUNCTION

'[*END OF FILE*]
