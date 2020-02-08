
' [TOOLBX_D.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' The files TOOLBX_B.BAS & TOOLBX_C.BAS are required to use TOOLBX_D.BAS

DECLARE FUNCTION CreateShortCut (key_pressed,kstate)	' Can be found in MENU.BAS
DECLARE SUB WindowMessage								' Can be found in WINDOW.BAS
DECLARE SUB TextWindLoop (key_pressed)					' Can be found in TEXTWIND.BAS
DECLARE SUB HandleUserKeys (ASCII$,key_pressed,kstate)	' Should be written by you
DECLARE SUB HandleUserClicks (clicks,kstate,mx,my)		' Should be written by you
DECLARE SUB HandleUserMenu (WindowHandle,item,title)	' Should be written by you
DECLARE SUB HandleUserMessages							' Should be written by you
DECLARE SUB HandleUserHook								' Should be written by you

FUNCTION WhichWindow(BYVAL AEShandle)
SHARED woHandle(),HowManyWindows
STATIC dummy

dummy=0
IF HowManyWindows>0 THEN
	DO
		INCR dummy
	LOOP WHILE (dummy <= HowManyWindows) AND (woHandle(dummy)<>AEShandle)
	IF woHandle(dummy)<>AEShandle THEN dummy=0
END IF
WhichWindow=dummy
END FUNCTION


FUNCTION IsMyWindow(BYVAL WindowHandle)
	IsMyWindow=WhichWindow(WindowHandle)>0
END FUNCTION


SUB HandleMessage
SHARED mess()
STATIC button,WindowHandle,item,title,MessageType,oldtree&

IF (mess(0)>=WM_REDRAW) AND (mess(0)<=WM_MOVED) THEN
	IF NOT IsMyWindow(mess(3)) THEN EXIT SUB
END IF

MessageType=mess(0)
SELECT CASE MessageType
CASE mn_selected
	title=mess(3) : item=mess(4)
	menu_tnormal menutree&,title,1
	oldtree&=tree& : tree&=menutree&
	IF enquire_state(item,mask_disabled) THEN tree&=oldtree& : EXIT SELECT
	IF item=menu_exititem THEN
		IF allchange THEN
			button=form_alert(2,"[1][  "+MyProgram$+": |  You have not saved all your |  data, do you wish to... ][Continue|Cancel]")
			SELECT CASE button
			CASE 1 : Finished_Flag=-1 : allchange=0
			CASE 2 : CALL ENCHANTloop
			END SELECT
		ELSE
			Finished_Flag=-1
		END IF
	ELSE
		HandleUserMenu WindowHandle,item,title
	END IF
	tree&=oldtree&
CASE wm_redraw TO wm_toolbar : CALL WindowMessage
CASE ap_term
	IF allchange THEN
		button=form_alert(2,"[1][  "+MyProgram$+": |  You have not saved all your |  data, do you wish to... ][Continue|Cancel]")
		SELECT CASE button
		CASE 1 : Finished_Flag=-1 : allchange=0
		CASE 2 : CALL ENCHANTloop
		END SELECT
	ELSE
		Finished_Flag=-1
	END IF
CASE ELSE : CALL HandleUserMessages
END SELECT
END SUB


SUB ENCHANTloop
SHARED mess(),TextWindowSystem
STATIC event,key_pressed,clicks,mx,my,kstate

REDIM PRESERVE mess(20) : Finished_Flag=0
DO
event=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON+MU_TIMER,2,1,1,0,0,0,0,0,0,0,0,0,0,_
	VARPTR(mess(0)),hook_timeout,mx,my,0,kstate,key_pressed,clicks)
IF event AND MU_KEYBD THEN
	IF menus_enabled THEN
		IF TextWindowSystem THEN CALL TextWindLoop (key_pressed)
		IF CreateshortCut (key_pressed,kstate) THEN
			CALL HandleMessage
		ELSE
			IF keys_enabled THEN HandleUserKeys CHR$(key_pressed AND 255),key_pressed,kstate
		END IF
	ELSE
		IF keys_enabled THEN HandleUserKeys CHR$(key_pressed AND 255),key_pressed,kstate
	END IF
END IF
IF event AND MU_MESAG THEN CALL HandleMessage
IF event AND MU_BUTTON THEN	IF clicks_enabled THEN HandleUserClicks clicks,kstate,mx,my
IF hook_enabled<>0 THEN CALL HandleUserHook
LOOP UNTIL Finished_Flag<>0
END SUB

'[*END OF FILE*]
