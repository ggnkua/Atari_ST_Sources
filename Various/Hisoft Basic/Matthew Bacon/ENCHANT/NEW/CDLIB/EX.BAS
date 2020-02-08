DEFINT a-z
LIBRARY "cdlib","gemaes"

DIM SHARED err_advice$,junk,MyProgram$

REM $include F:\enchant\new\cdlib.bas
REM $include F:\enchant\modules\error.bas

MyProgram$="CD-Player"
result=init_CDLIB (drive_letter$,driver$)
IF result THEN
	PRINT "CD drive:",drive_letter$
	PRINT "CD driver:",driver$
	PRINT "---------------------------"
	PRINT "1. Start audio CD"
	PRINT "2. Pause audio CD"
	PRINT "3. Unpause audio CD"
	PRINT "4. Eject CD"
	PRINT "5. Display CD unique id"
	PRINT "6. Turn up volume to max."
	PRINT "7. Turn down volume to min."
	PRINT "---------------------------"
	PRINT "Q. Quit"
	DO
	dummy$=UCASE$(INKEY$)
	SELECT CASE dummy$
	CASE "1"
		result=contents_CDLIB (first_track,last_track)
		IF result THEN result=playtracks_CDLIB (first_track,last_track)
	CASE "2" : result=pause_CDLIB
	CASE "3" : result=unpause_CDLIB
	CASE "4" : result=eject_CDLIB
	CASE "5" : result=catalog_CDLIB (catalog$) : LOCATE 14 : PRINT "CD's ID: "+catalog$ 
	CASE "6" : result=volume_CDLIB (100)
	CASE "7" : result=volume_CDLIB (0)
	CASE "Q" : EXIT LOOP
	END SELECT
	LOOP UNTIL result=0
	result=close_CDLIB
END IF
STOP

error_handler:
PRINT "An error has occurred, this program will not terminate!"
STOP

'[*END OF FILE*]

