
' [TOOLBX_A.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

DEFINT a-z
LIBRARY "bios","gemaes","gemdos","gemvdi","xbios"

REM $option q50,y+
REM $DYNAMIC

REM Global variables that should be reset whenever your program is executed.
DIM SHARED junk,junk$,tree&,menutree&,desktree&,MyProgram$,allchange,supress_byte_align
DIM SHARED resource_loaded,Finished_Flag,Finished_DFlag,CommonObj,CommonClose,err_advice$
DIM SHARED menu_exititem,clicks_enabled,keys_enabled,menus_enabled,reset_dialog,debug_enabled
DIM SHARED HowManyButtons,CommonButton,forms_enabled

MyProgram$="" : allchange=0 : supress_byte_align=0
resource_loaded=0 : Finished_Flag=0 : Finished_DFlag=1 : CommonObj=0 : CommonClose=0
err_advice$="" : menu_exititem=0 : clicks_enabled=0 : keys_enabled=0 : menus_enabled=0
reset_dialog=0 : debug_enabled=0 : HowManyButtons=1 : CommonButton=0 : forms_enabled=0

GOTO RETURN_HANDLER
REM $include gemaes.bh
REM $include toolbx_b.bas
REM $include toolbx_c.bas
REM $include toolbx_d.bas
'REM $include menu.bas
'REM $include dialog.bas
REM $include xdialog.bas
'REM $include xalert.bas
'REM $include fselect.bas
'REM $include newdesk.bas
'REM $include exec.bas
REM $include window.bas
'REM $include textwind.bas
REM $include object.bas
REM $include formwind.bas
'REM $include popup.bas

ERROR_HANDLER:
ErrorString$=ReportError$ (ERR)
IF ErrorString$="" THEN ErrorString$="Unknown - Sorry!"
button=form_alert(1,"[1][  "+MyProgram$+": |  ERROR: "+ErrorString$+" |  Try to tolerate or abort |  program? ][ Tolerate | Abort ]")
MOUSE 0
SELECT CASE button
	CASE 1 : ON ERROR GOTO ERROR_HANDLER : CALL ENCHANTloop
	CASE 2 : StopProgram
END SELECT

REM Used as a decoy to make sure none of the sub-routines are executed until required!
RETURN_HANDLER:
ON ERROR GOTO ERROR_HANDLER

'[*END OF FILE*]
