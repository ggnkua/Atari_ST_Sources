'DEMONSTRATION OF THE HiSOFT Basic MODPLAY Library.
' Coded by Data Uncertain Software.
' 17/5/94.

LIBRARY "MODPLAY"					'Use the MODPLAY library

?"HiSoft Basic DSP MODPLAY Library Demo"
?"Written by Data Uncertain"
?
f$=COMMAND$							'Filename on command line.
IF f$="" THEN
	?"You must give me a filename....."
	STOP
END IF

IF NOT FEXISTS(f$) THEN
	?"File ";f$;" does not exist...."
	STOP
END IF

DIM a%(70000)

InitMod a%()						'Initialise the ModPlay driver.

l&=VARPTR(a%(0))
BLOAD f$,l&							'Load the mod file into the array.

GetModName a%(),b$					'GetModName returns a string giving the title of a mod
?"Modfile Title:";b$
?
?"Any key to exit....."

PlayMod a%()						'Activate the mod player.

DO WHILE INKEY$=""					'Do something to kill time
	LOCATE 5,1						'note:actual processor time used is minimal.
	?TIMER							'You can do anything you want here.
LOOP

StopMod a%()						'Stop the mod player

END									'All done.
