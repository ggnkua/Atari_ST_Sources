'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' AutoLock v1.10  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z
'$option q10
DIM SHARED Pass$(2)

' Check if a password file exists
IF FEXISTS("LOCKOUT.INF") THEN
	OPEN CURDIR$+"\LOCKOUT.INF" FOR INPUT AS #1
	INPUT #1,Pass$(1)
	IF LEN(Pass$(1))>8 THEN Pass$(1)=LEFT$(Pass$(1),8)
	CLOSE #1

	' Display initial screen, to let the user know a password is required
	LOCATE 11,31:PRINT "Password:"
	LOCATE 13,27:PRINT "½ 1996,97 Cadenza Software"
	LOCATE 14,28:PRINT "Written by Matthew Bacon"
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
			LOCATE 11,31:PRINT "Password: "+STRING$ (i,ASC("*"))+" "
			password$=LEFT$(password$,LEN(password$)-1)
		' If return key was pressed, check against given password
		CASE 13
			' If the correct password has been given, quit
			IF password$=UCASE$(Pass$(1)) THEN EXIT LOOP
			' If the override password (159357) has been given, also quit
			IF password$="159357" THEN EXIT LOOP
		' If one of the letter, numerical or spacebar keys was pressed
		CASE 32,65 TO 65+26,48 TO 57
			INCR i
			' i= no. of characters in password
			IF i>8 THEN i=8:EXIT SELECT
			' Print to screen, password is masked
			LOCATE 11,31:PRINT "Password: "+STRING$ (i,ASC("*"))
			password$=password$+try$
	END SELECT
END IF
LOOP
' Quit
SYSTEM
