
REM $option q10

LIBRARY "MODPLAY","GEMDOS"

PRINT "HiSoft BASIC DSP MODPLAY Library Demo"
PRINT "Written by Paul Jones"

f$=COMMAND$

' Get the command line.

IF NOT FEXISTS(f$) THEN
	PRINT "File";f$;" does not exist...."
	STOP
END IF

' if the file doesn't exist, report an error.

OPEN f$ FOR INPUT AS 2
a&=LOF(2)
CLOSE 2

b&=malloc& (a&)

' find the file's file and allocates memory.

IF B&=0 THEN
	PRINT "Not enough memory!"
	STOP
END IF

BLOAD f$,b&

' If not enough memory, then print error. Bloads it in.

InitMod a%()

' Initialise the player.

GetModName b&,b$

' Get it's name.

PRINT "Modfile Title:";b$
PRINT
PRINT "Any key to exit....."

PlayMod b&

' play it!

DO WHILE INKEY$=""
LOOP

' want until a button is pressed.

StopMod a%()

' stop the mod file.
STOP -1