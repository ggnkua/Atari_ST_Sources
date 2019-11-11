'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION HandleUserClose(BYVAL WindowHandle)
SHARED software_handle,summary_handle

SELECT CASE WindowHandle
CASE software_handle : software_handle=0
CASE summary_handle : summary_handle=0
END SELECT
END FUNCTION

SUB HandleUserMessages
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
SHARED main_handle
STATIC find_handle

junk=wind_get(0,WF_TOP,find_handle,0,0,0)
SELECT CASE find_handle
CASE main_handle
	SelectTree FORM_MAIN
	IF NOT enquire_flags(MAIN_OTHER,mask_hidetree) THEN
		SELECT CASE key_pressed
		CASE 7680
			include_state OTHER_FVERSION,mask_disabled
			include_state OTHER_FVERSION2,mask_disabled
			include_state OTHER_MAIL,mask_disabled
			include_state OTHER_MAIL2,mask_disabled
			Object_Redraw main_handle,OTHER_FVERSION
			Object_Redraw main_handle,OTHER_FVERSION2
			Object_Redraw main_handle,OTHER_MAIL
			Object_Redraw main_handle,OTHER_MAIL2
		CASE 12800
			remove_state OTHER_FVERSION,mask_disabled
			remove_state OTHER_FVERSION2,mask_disabled
			remove_state OTHER_MAIL,mask_disabled
			remove_state OTHER_MAIL2,mask_disabled
			Object_Redraw main_handle,OTHER_FVERSION
			Object_Redraw main_handle,OTHER_FVERSION2
			Object_Redraw main_handle,OTHER_MAIL
			Object_Redraw main_handle,OTHER_MAIL2
		END SELECT
	END IF
	IF NOT enquire_flags(MAIN_PRINT,mask_hidetree) THEN
		SELECT CASE key_pressed
		CASE 7680
			include_state PRINT_LPP,mask_disabled
			include_state PRINT_FF,mask_disabled
			include_state PRINT_FORMFEED,mask_disabled
			Object_Redraw main_handle,PRINT_LPP
			Object_Redraw main_handle,PRINT_FF
			Object_Redraw main_handle,PRINT_FORMFEED
		CASE 4864
			remove_state PRINT_LPP,mask_disabled
			remove_state PRINT_FF,mask_disabled
			remove_state PRINT_FORMFEED,mask_disabled
			Object_Redraw main_handle,PRINT_LPP
			Object_Redraw main_handle,PRINT_FF
			Object_Redraw main_handle,PRINT_FORMFEED
		END SELECT
	END IF
END SELECT
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
SHARED main_handle,software_handle
STATIC find_handle,object

find_handle=wind_find(mx,my)
SELECT CASE find_handle
CASE software_handle : IF clicks=1 THEN CALL SelectSoftware (mx,my)
CASE main_handle
	SelectTree FORM_MAIN
	object=objc_find(tree&,0,10,mx,my)
	IF NOT enquire_flags(MAIN_OTHER,mask_hidetree) THEN
		SELECT CASE object
		CASE OTHER_REQUIRED,OTHER_REQUIRED2
			remove_state OTHER_FVERSION,mask_disabled
			remove_state OTHER_FVERSION2,mask_disabled
			remove_state OTHER_MAIL,mask_disabled
			remove_state OTHER_MAIL2,mask_disabled
			Object_Redraw main_handle,OTHER_FVERSION
			Object_Redraw main_handle,OTHER_FVERSION2
			Object_Redraw main_handle,OTHER_MAIL
			Object_Redraw main_handle,OTHER_MAIL2
		CASE OTHER_NREQUIRED,OTHER_NREQUIRED2
			include_state OTHER_FVERSION,mask_disabled
			include_state OTHER_FVERSION2,mask_disabled
			include_state OTHER_MAIL,mask_disabled
			include_state OTHER_MAIL2,mask_disabled
			Object_Redraw main_handle,OTHER_FVERSION
			Object_Redraw main_handle,OTHER_FVERSION2
			Object_Redraw main_handle,OTHER_MAIL
			Object_Redraw main_handle,OTHER_MAIL2
		END SELECT
	END IF
	IF NOT enquire_flags(MAIN_PRINT,mask_hidetree) THEN
		SELECT CASE object
		CASE PRINT_ASCII,PRINT_ASCII2
			include_state PRINT_LPP,mask_disabled
			include_state PRINT_FF,mask_disabled
			include_state PRINT_FORMFEED,mask_disabled
			Object_Redraw main_handle,PRINT_LPP
			Object_Redraw main_handle,PRINT_FF
			Object_Redraw main_handle,PRINT_FORMFEED
		CASE PRINT_PRINTER,PRINT_PRINTER2
			remove_state PRINT_LPP,mask_disabled
			remove_state PRINT_FF,mask_disabled
			remove_state PRINT_FORMFEED,mask_disabled
			Object_Redraw main_handle,PRINT_LPP
			Object_Redraw main_handle,PRINT_FF
			Object_Redraw main_handle,PRINT_FORMFEED
		END SELECT
	END IF
END SELECT
END SUB

SUB	HandleUserMenu (cur_front,item,title)
SHARED main_handle
STATIC button

SELECT CASE item
CASE MENU_ABOUT
	CALL topMENU (MAIN_ABOUT,"Information")
	setobj_poptext MAIN_MENU,"Information"
	Object_Redraw main_handle,MAIN_MENU
CASE MENU_NEW
	button=form_alert(2,"[2][  "+MyProgram$+": |  Are you sure? |  All current registration |  details will be lost! ][ OK | Cancel ]")
	SELECT CASE button
	CASE 1
		CALL initFORM_MAIN : CALL initFORM_OTHER : CALL initFORM_PRINT
		CALL topMENU (MAIN_DETAILS,"Personal Details")
		setobj_poptext MAIN_MENU,"Personal Details"
		Object_Redraw main_handle,MAIN_MENU
	END SELECT
CASE MENU_PRINT
	CALL topMENU (MAIN_PRINT,"Print Registration")
	setobj_poptext MAIN_MENU,"Print Registration"
	Object_Redraw main_handle,MAIN_MENU
CASE MENU_PDETAILS
	CALL topMENU (MAIN_DETAILS,"Personal Details")
	setobj_poptext MAIN_MENU,"Personal Details"
	Object_Redraw main_handle,MAIN_MENU
CASE MENU_SOFTWARE : CALL software
CASE MENU_ODETAILS
	CALL topMENU (MAIN_OTHER,"Other...")
	setobj_poptext MAIN_MENU,"Other..."
	Object_Redraw main_handle,MAIN_MENU
CASE MENU_SUMMARY : CALL summary
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
