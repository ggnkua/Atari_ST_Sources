'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Password v1.1  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z
'$option q10
DIM SHARED Pass$(2)

' Check if a password file exists, if not create one
IF FEXISTS("AUTO.PI1") THEN
	OPEN CURDIR$+"\AUTO.PI1" FOR INPUT AS #1
	INPUT #1,Pass$(1)
	IF LEN(Pass$(1))>8 THEN Pass$(1)=LEFT$(Pass$(1),8)
	CLOSE #1

	' Display initial screen, to let the user know a password is required
	LOCATE 11,31:PRINT "Password:"
	LOCATE 13,27:PRINT "½ 1996,97 Cadenza Software"
	LOCATE 14,28:PRINT "Written by Matthew Bacon"
	Create=0
ELSE
	' Display 'Create Password' screen, to let the user know to
	' enter a new password
	LOCATE 11,27:PRINT "Create Password:"
	LOCATE 13,27:PRINT "½ 1996,97 Cadenza Software"
	LOCATE 14,28:PRINT "Written by Matthew Bacon"
	Create=1
END IF

DO
' Read key pressed, make the letter upper casing
try$=UCASE$(INKEY$)

' Make sure a letter exists
IF NOT try$="" THEN
	try=ASC(try$)
	SELECT CASE try
		' If backspace key was pressed
		CASE 8
			DECR i
			IF i<0 THEN i=0:EXIT SELECT
			' Print to screen, password is masked
			IF create=1 THEN LOCATE 11,27:PRINT "Create Password: "+STRING$ (i,ASC("*"))+" "
			IF create=0 THEN LOCATE 11,31:PRINT "Password: "+STRING$ (i,ASC("*"))+" "
			password$=LEFT$(password$,LEN(password$)-1)
'			LOCATE 10,31:PRINT "Password: "+password$+" "
		' If return key was pressed, check against given password
		CASE 13
			' If Create is ON create new password file
			IF Create=1 THEN 
				OPEN CURDIR$+"\AUTO.PI1" FOR OUTPUT AS #1
				PRINT #1,password$
				CLOSE #1
				EXIT LOOP
			ELSE
				' If the correct password has been given, quit
				IF password$=UCASE$(Pass$(1)) THEN EXIT LOOP
				' If the override password (159357) has been given, also quit
				IF password$="159357" THEN EXIT LOOP
			END IF
		' If one of the letter, numerical or spacebar keys was pressed
		CASE 32,65 TO 65+26,48 TO 57
			INCR i
			' i= no. of characters in password
			IF i>8 THEN i=8:EXIT SELECT
			' Print to screen, password is masked
			IF create=1 THEN LOCATE 11,27:PRINT "Create Password: "+STRING$ (i,ASC("*"))
			IF create=0 THEN LOCATE 11,31:PRINT "Password: "+STRING$ (i,ASC("*"))
'			LOCATE 1,1:PRINT "Password: "+password$+try$
			password$=password$+try$
	END SELECT
END IF
LOOP
' Quit
SYSTEM
