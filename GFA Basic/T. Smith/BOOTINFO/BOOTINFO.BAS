LIBRARY "xbios"
DEFINT a-z
DIM message$(4096),options$(80),file_string$(30)

REM************************************************************************
REM                    +++ Main Program Start +++

CALL initialise
CALL flash_and_bell
CALL get_info_file
CALL print_to_screen
CALL wait_for_key_options
CALL reset_low_resolution
STOP -1

REM                    +++ Main Program End +++
REM************************************************************************
REM                    +++ Start Of Subroutines +++

SUB initialise
	SHARED options$,file_string$,resolution
	resolution = FNgetrez
	IF resolution = 0 THEN SCREEN 1
	CLS
	WIDTH 80
	dummy = FNsetcolor(0,&H000)
	dummy = FNsetcolor(3,&H777)
	file_string$ = "A:\AUTO\BOOTINFO.INF"
	options$ = "*** Press RETURN to continue, SPACEBAR to stop / continue, or just wait. ***"
	PRINT "                                BOOT INFORMATION"
	PRINT "                                ****************"
	PRINT
END SUB

SUB flash_and_bell
	FOR X = 1 TO 10
		dummy = FNsetcolor(0,&H700)
		BEEP
		FOR Y = 1 TO 16500:NEXT Y
		dummy = FNsetcolor(0,&H000)
		FOR Z = 1 TO 16500:NEXT Z
	NEXT X
END SUB

SUB get_info_file
	SHARED message$,file_string$
	IF NOT FEXISTS(file_string$) THEN
		message$ = "     +++ NO BOOT INFORMATION FILE PRESENT IN AUTO FOLDER ON DRIVE A +++"
		EXIT SUB
	END IF
	OPEN "I",#1,file_string$
	message$ = INPUT$(LOF(1),#1)
	CLOSE #1
END SUB

SUB print_to_screen
	SHARED message$,options$
	PRINT message$
	PRINT:PRINT options$;
END SUB

SUB wait_for_key_options
	wait! = TIMER+30
	DO
		key$ = INKEY$
		IF key$="" THEN key_pressed = 0 ELSE key_pressed = ASC(key$)
		IF key_pressed = 32 THEN CALL stop_until_spacebar:EXIT DO
	LOOP UNTIL TIMER = wait! OR key_pressed = 13
END SUB

SUB stop_until_spacebar
	DO
		key$ = INKEY$
	LOOP UNTIL key$ = " "		
END SUB

SUB reset_low_resolution
	SHARED resolution
	IF resolution = 2 THEN EXIT SUB
	SCREEN 0
	CLS
	WIDTH 40
END SUB

REM                    +++ End Of Subroutines +++
REM***********************************************************************