
' [ACCSHELL.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' NB: When ? is used below, it shows that it should be replaced by a variable
      (numeric or string) which is unique to your program. Please consult the
      manuals provided for further details on calls & commands used below.

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z
' ** Request an amount of memory for your desk accessory **
REM $option j?

' ** Request your programs resource files CONST file **
REM $include ?.bh

' ** Request GEM Toolkit routines & ERROR catchment routines **
REM $include error.bas
REM $include acc_tbox.bas

' ** Make the string variable 'MyProgram$' contain name of your program! **
MyProgram$="ENCHANT"

CALL StartAccessory("?",CURDIR$+"\?.RSC",?)

' ** Your start up code should appear here. Call any routines that setup the **
' ** preset values or strings before the program interacts with the user.    **

' ** Begin the programs main loop **
CALL ENCHANT_ACCloop

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' ** The following routines should always be present when using the GEM Toolkit **

FUNCTION HandleUserClose(BYVAL WindowHandle)
END FUNCTION

SUB HandleUserMessages
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END IF
END SUB

SUB	HandleUserMenu (cur_front,item,title)
END SUB

SUB HandleUserHook
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' ** Any routines unique to your program should follow on here **

SUB ACCOpened
' ** This sub-routine is called EVERY time the desk accesory is started! **
END SUB

'[*END OF FILE*]
