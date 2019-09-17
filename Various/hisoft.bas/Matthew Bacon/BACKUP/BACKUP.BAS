
'[BACKUP.BAS]
' Developed by Matthew Bacon. Copyright ½ 2001 Matthew Bacon
' Published by Cadenza Software.

ON ERROR GOTO error_handler
DEFINT a-z
LIBRARY "xbios"
'$option q100
'$dynamic
'$include F:\CADENZA\ATODAY2\ERROR.BAS
'$include F:\CADENZA\ATODAY2\DISK.BAS

GOTO top
error_handler:
result=DiskError(ERR)

'=========== Introduction screen ===========
top:
CLS
LOCATE 1:PRINT CHR$(27);"p   MyAtari - Cover Disk Copier v1.0   ";CHR$(27);"q"
LOCATE 2:PRINT CHR$(27);"p    Copyright ½ 2001 Matthew Bacon    ";CHR$(27);"q"
LOCATE 4:PRINT "NB; Please make sure that your SOURCE"
LOCATE 5:PRINT "    disk is write-protected!"
LOCATE 7:PRINT "Insert SOURCE disk into Drive A"
LOCATE 8:PRINT "Hit any key to continue (Esc to quit)"
'=========== Wait for key press to start backup ===========
DO
	a$=INKEY$
LOOP UNTIL a$<>""
IF a$=CHR$(27) THEN SYSTEM
IF a$=CHR$(27) THEN SYSTEM

'=========== Double-check how many disk drives attached ===========
diskdrives=howmanydrives
IF diskdrives=1 THEN
	drvsrc$="A"
	drvdest$="A"
ELSE
	drvsrc$="A"
	drvdest$="B"
END IF

result=CopyDisk (drvsrc$,drvdest$,0,1,1)
IF result<>0 THEN
	LOCATE 10:PRINT CHR$(27);"p Backup successful ;-)                ";CHR$(27);"q"
	time!=TIMER
	DO
	LOOP UNTIL TIMER-time!>3
	SYSTEM
ELSE
	LOCATE 10:PRINT CHR$(27);"p Backup unsuccessful :-(              ";CHR$(27);"q"
	time!=TIMER
	DO
	LOOP UNTIL TIMER-time!>3
	GOTO top
END IF

SUB RelayFormatProgress (drvdest$,no_sectors,track,side)
LOCATE 10:PRINT "Formatting track";track;", side";side;"    "
END SUB

SUB RelayDestProgress (drvdest$,no_sectors,track,side,copiesdone)
LOCATE 10:PRINT "Writing    track";track;", side";side;"    "
END SUB

SUB RelaySourceProgress (drvdest$,no_sectors,track,side,copiesdone)
LOCATE 10:PRINT "Reading track";track;", side";side;"    "
END SUB
