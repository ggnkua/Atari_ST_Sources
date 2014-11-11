' Desktop.inf file activator by Michael Wensley

REM $option y
LIBRARY "gemaes","gemdos","bios"
DEFINT a-z
DECLARE FUNCTION match(BYVAL file$,BYVAL wild$)
c$=COMMAND$

' extract target filename from the path

filename$=MID$(c$,RINSTR(c$,"\")+1)

' the shell buffer contains a RAM copy of DESKTOP.INF/NEWDESK.INF
' it has trailing chr$(0) and may use a trailing eof marker chr$(26)
' we can use it to find out what app's are installed for extensions
' and of course to find out what icons are to be used for what programs


target$="" 'candidate program to start

ln=4192
s$=SPACE$(ln)
' IF old aes THEN smaller shell size passed
IF PEEKW(PEEKL(GB+4))<&H140 THEN ln=1024
' newest aes has a variable shell size
IF PEEKW(PEEKL(GB+4))>=&H400 THEN
	ln=shel_get(SADD(s$),-1)
	s$=SPACE$(ln)
END IF

' fetch aes buffer...
size%=shel_get(SADD(s$),ln%)

' default icons for program and file
myprog=3
myfile=4

' process the shell buffer we loaded
pl=1
DO UNTIL pl=0
	en=INSTR(pl,s$,CHR$(13)+CHR$(10))
	IF en THEN
		l$=MID$(s$,pl,en-pl)
		pl=en+2
	ELSE
		l$=MID$(s$,pl)
		pl=0
	END IF
	'cconws l$+CHR$(13)+CHR$(10)
	IF LEN(l$)>2 THEN
		IF ASC(l$)="#"% THEN
			j%=PEEKB(SADD(l$)+1)
			SELECT CASE j%
'			CASE "a"%,"b"%
'				' modem/printer settings (rsconf, prt)
'			CASE "c"%
'				' desktop (calibrate) palette
'			CASE "d"%
'				' desktop DTA? (fsfirst,fsnext)
'				' try counting the spaces!
'				' after the "#d " there are 44 Just enough for a DTA
'			CASE "K"%
'				' desktop keys
'			CASE "E"%
'				' desktop configuration
'			CASE "Q"%
'				' desktop/window colours for mode's 1, 2 4
'				j=PEEKW(SYSTAB)
'				SELECT CASE j
'				CASE 1
'					' 2 colour mode/(black and white)
'					desktop%=VAL("&H"+MID$(l$,4,2))
'					dwindow%=VAL("&H"+MID$(l$,7,2))
'				CASE 2
'					' 4 colour mode/(white black red green)
'					desktop%=VAL("&H"+MID$(l$,10,2))
'					dwindow%=VAL("&H"+MID$(l$,13,2))
'				CASE ELSE
'					' 16 colour + up
'					desktop%=VAL("&H"+MID$(l$,16,2))
'					dwindow%=VAL("&H"+MID$(l$,19,2))
'				END SELECT
'			CASE "S"%
'				' settings
'			CASE "W"%
'				' directory windows
'			CASE "M"%,"T%,"O"%,"X"%
'				' desktop icons for drives, trash, printer and file/folders
			CASE "N"%,"D"%,"G"%,"Y"%,"P"%,"F"%,"A"%,"I"%
				' default icon for file/directory
				' program declaration for GEM GTP TTP TOS/files ACC
				' window icon declaration
				progicn%=VAL("&H"+MID$(l$,4,2))
				itemicn%=VAL("&H"+MID$(l$,7,2))
				flagdata%=VAL("&H"+MID$(l$,10,3))

				j=INSTR(14,l$,"@ ")
				IF j>0 THEN
					progpath$=MID$(l$,14,j-14)
					j2=INSTR(j+2,l$,"@ ")
					IF j2>0 THEN
						itemwild$=MID$(l$,j+2,j2-(j+2))
						j3=INSTR(j2+2,l$,"@ ")
						IF match(filename$,itemwild$) AND (progpath$<>"") THEN
							target$=progpath$ : targettype$=CHR$(PEEKB(SADD(l$)+1))
							IF j3>0 THEN
								argument$=MID$(l$,j2+2,j3-(j2+2))
							ELSE
								argument$=""
							END IF
						END IF
					END IF
				END IF
				
				' we can now get program/file assignments like this
				' for programs and data - the NEWDESK routine
				' will go from generic to specific? so ensure that it can loop
				' until the end of the file

				' PRINT progicn,itemicn,flagdata
			END SELECT
			' if a line does not begin with # then ignore it
			' as it may be a comment (;) or some other prog specific information
		END IF
	END IF
LOOP

' get full envstring
env&=PEEKL(PEEKL(SYSTAB+54)+&H2C)
enve&=env&
DO UNTIL PEEKB(enve&)=0 AND PEEKB(enve&+1)=0
	INCR enve&
LOOP
l&=enve&-env&
env$=SPACE$(l&+2)
blockmove env&,SADD(env$),l&+2

' cconws "#"+target$+"#"+argument$+c$+"#"+env$

target$=target$+CHR$(0)
argument$=argument$+c$
mode$=ENVIRON$("FILEEXECMODE")

' choose default startup mode
IF (mode$="") AND shel_read(cmd$,tail$) THEN
	IF tail$=c$ THEN
		mode$="INDEPENDENT"
	ELSE
		mode$="DEPENDANT"
	END IF
END IF

SELECT CASE mode$
CASE "DEPENDANT",""
	' use to invoke util (prog to do task [*for* caller prog]) dependantly.
	j&=pexec&(0,target$,argument$,env$)
CASE "INDEPENDENT"
	' shel_write for invoking app (prog for solve problem [by caller on behalf of user's 'request']) independently.
	argument$=CHR$(LEN(argument$))+argument$
	n=1
	SELECT CASE targetmode$ : CASE "G","Y","A" : n=1 : CASE "P","F" : n=0 : END SELECT
	j=shel_write(1,n,1,SADD(target$),SADD(argument$))
END SELECT
'j=form_alert(1,"[3][done][ok]")
SYSTEM



' to see if a file matches the specificationcode
' e.g. if file$="DESKCICN.RSC" wild$="*.RSC"
FUNCTION match(BYVAL file$,BYVAL wild$)
STATIC mat,true,j,p
mat=1

IF wild$<>"" THEN
	DO UNTIL (file$="")
	IF wild$="" THEN mat=0 : EXIT LOOP
	'cconws file$+"   file   "+wild$+"   wild    "+CHR$(13)+CHR$(10)
		j=ASC(wild$)
		SELECT CASE j
		CASE "?"%
			IF LEN(file$)>0 THEN
				p=ASC(file$)
				SELECT CASE p%
				CASE "."%
				mat=0 : 'PRINT "outch"
				END SELECT
				file$=MID$(file$,2)
			ELSE
				mat=0 : 'PRINT "outch2"
			END IF
			wild$=MID$(wild$,2)
		CASE "*"%
			IF LEN(file$)>0 THEN
				j=ASC(file$)
				SELECT CASE j
				CASE "."%
					wild$=MID$(wild$,2)
				CASE ELSE
					file$=MID$(file$,2)
				END SELECT
			END IF
		CASE ELSE
			' "."% would also match for correct
			IF LEN(file$)=0 THEN
				mat=0 : 'PRINT "failout"
			ELSE
				IF j<>ASC(file$) THEN
					mat=0 : 'PRINT "failmatch",CHR$(j),CHR$(ASC(file$))
				ELSE
					file$=MID$(file$,2)
					wild$=MID$(wild$,2)
				END IF
			END IF
		END SELECT
	LOOP UNTIL true OR (mat=0)
	IF true THEN mat=1
	match=mat
ELSE
	match=0
END IF
END FUNCTION


'FUNCTION myshel_write(BYVAL wdoex,BYVAL wisgr,BYVAL wiscr,BYVAL wpcmd&,BYVAL wptail&)
' ct,gb,ii,io,ai,ao
'POKEW PEEKL(GB+0)+2,3
'POKEW PEEKL(GB+8),wdoex
'POKEW PEEKL(GB+8)+2,wisgr
'POKEW PEEKL(GB+8)+4,wiscr

'POKEW PEEKL(GB+00)+6,2
'POKEL PEEKL(GB+16),wpcmd&
'POKEL PEEKL(GB+16)+4,wptail&

'POKEW PEEKL(GB+00)+0,121
'POKEW PEEKL(GB+00)+4,1
'POKEW PEEKL(GB+00)+8,0
'GEMSYS(121)
'myshel_write=PEEKW(PEEKL(GB+12))
'END FUNCTION
