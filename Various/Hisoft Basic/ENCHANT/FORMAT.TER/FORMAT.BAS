
' [FORMAT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

DEFINT a-z
REM $option j150			' Declare that you want to keep 150k of memory for ACC
REM $include format.bh		' Declare *.BH file created from resource file
REM $include acc_tbox.bas	' Request the file ACC_TBOX.BAS (DA version of TOOLBX_A.BAS)
REM $include disk.bas		' Request the file DISK.BAS
REM $include curser.bas		' Request the file CURSER.BAS
REM $include error.bas		' Request the file ERROR.BAS

CALL StartAccessory("Formatter v1.2",CURDIR$+"\FORMAT.RSC",0)
CALL ENCHANT_ACCloop	' Main program loop

' These sub-routines are not used, but are required as they are declared
' within the GEM Toolkit

FUNCTION HandleFormClicks(BYVAL button,BYVAL clicks,BYVAL kstate,BYVAL x,BYVAL y)
END FUNCTION

SUB WindowMessage
END SUB

SUB HandleKeyboardEvent (BYVAL key_pressed,BYVAL kstate)
END SUB

SUB TextWindLoop (keypressed)
END SUB

FUNCTION HandleUserClose(BYVAL WindowHandle)
END FUNCTION

SUB HandleUserMessages
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB


SUB RelaySourceProgress (drive$,no_sectors,track,side)
END SUB

SUB RelayDestProgress (drive$,no_sectors,track,side,copy)
END SUB


SUB ACCOpened	' This sub-routine is used each time the DA is opened
STATIC dummy

INCR dummy : IF dummy=1 THEN junk=xdialog (FORM_ABOUT,0,0,1,0)	' Display dialog 1st time only
junk=xdialog (FORM_MAIN,0,MAIN_QUIT,1,VARPTRS(closeFORM_MAIN))	' Display dialog
END SUB


SUB closeFORM_MAIN
STATIC drive$,sides,tracks,sectors,verify,button,result

SelectTree FORM_MAIN
IF enquire_state(MAIN_A,mask_selected) THEN	' This workdout which drive has been selected
	drive$="A"
ELSE
	drive$="B"
END IF
IF getobj_shortcut(MAIN_1)=12 THEN
	sides=1
ELSE
	sides=2
END IF
IF getobj_shortcut(MAIN_80)=12 THEN
	tracks=80
ELSE
	tracks=81
END IF
IF getobj_shortcut(MAIN_9)=12 THEN
	sectors=9
ELSE
	sectors=10
END IF
IF getobj_shortcut(MAIN_VERIFY)=14 THEN
	verify=1
ELSE
	verify=0
END IF

SELECT CASE CommonObj
CASE MAIN_FORMAT 
	' Double check the user wants to format the disk!
	button=form_alert(2,"[1][  "+MyProgram$+": |  Format disk in drive "+drive$+"? ][Continue|Cancel]")
	SELECT CASE button
	CASE 1
		' Using what we have worked out (how many sides etc.), format the disk! :)
		result=FormatDisk (drive$,sectors,tracks,sides,verify)
	END SELECT
CASE MAIN_QUIT : Finished_DFlag=0	' Exit the dialog loop
END SELECT
END SUB

'[*END OF FILE*]
