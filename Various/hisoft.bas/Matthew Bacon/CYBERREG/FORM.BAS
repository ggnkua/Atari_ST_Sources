'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_MAIN
SHARED main_handle,popup_country,popup_computer,popup_os,popup_emulation,popup_drive,popup_menu
SHARED OS_OTHER$,EMULATION_OTHER$,whichcountry$
STATIC dummy$

SelectTree FORM_MAIN
SELECT CASE CommonObj
CASE ABOUT_INFO : junk=xdialog (FORM_INFO,0,0,1,0)
CASE DET_COUNTRY
	popup_country=popup(main_handle,DET_COUNTRY,FORM_POPUPS,POP_COUNTRY,popup_country)
	IF popup_country THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_country)
		setobj_poptext DET_COUNTRY,"  "+dummy$
		Object_Redraw main_handle,DET_COUNTRY

		whichcountry$=dummy$
		SELECT CASE dummy$
		CASE "Europe","ROW"
			SelectTree FORM_COUNTRY : setobj_text COUNTRY_COUNTRY,""
			junk=xdialog (FORM_COUNTRY,COUNTRY_COUNTRY,0,1,0)
			dummy$=getobj_text$(COUNTRY_COUNTRY)
			SelectTree FORM_MAIN
			setobj_poptext DET_COUNTRY,"  "+dummy$
			Object_Redraw main_handle,DET_COUNTRY
		END SELECT
	END IF
CASE DET_COMPUTER
	popup_computer=multi_popup(main_handle,DET_COMPUTER,FORM_POPUPS,POP_COMPUTER,popup_computer)
	IF popup_computer THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_computer)
		setobj_poptext DET_COMPUTER,"  "+dummy$
		Object_Redraw main_handle,DET_COMPUTER
	END IF
CASE DET_OS
	popup_os=multi_popup(main_handle,DET_OS,FORM_POPUPS,POP_OS,popup_os)
	IF popup_os THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_os)
		setobj_poptext DET_OS,"  "+dummy$
		Object_Redraw main_handle,DET_OS

		SELECT CASE dummy$
		CASE "Other"
			SelectTree FORM_OTHER : setobj_text OTHER_OTHER,OS_OTHER$
			junk=xdialog (FORM_OTHER,OTHER_OTHER,0,1,0)
			OS_OTHER$=getobj_text$(OTHER_OTHER)
			SelectTree FORM_MAIN
		END SELECT
	END IF
CASE DET_EMULATION
	popup_emulation=popup(main_handle,DET_EMULATION,FORM_POPUPS,POP_EMULATION,popup_emulation)
	IF popup_emulation THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_emulation)
		setobj_poptext DET_EMULATION,"  "+dummy$
		Object_Redraw main_handle,DET_EMULATION

		SELECT CASE dummy$
		CASE "Other"
			SelectTree FORM_OTHER : setobj_text OTHER_OTHER,EMULATION_OTHER$
			junk=xdialog (FORM_OTHER,OTHER_OTHER,0,1,0)
			EMULATION_OTHER$=getobj_text$(OTHER_OTHER)
			SelectTree FORM_MAIN
		END SELECT
	END IF
CASE DET_DRIVE
	popup_drive=popup(main_handle,DET_DRIVE,FORM_POPUPS,POP_DRIVE,popup_drive)
	IF popup_drive THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_drive)
		setobj_poptext DET_DRIVE,"  "+dummy$
		Object_Redraw main_handle,DET_DRIVE
	END IF
CASE MAIN_MENU
	popup_menu=popup(main_handle,MAIN_MENU,FORM_POPUPS,POP_MENU,popup_menu)
	IF popup_menu THEN
		dummy$=LTRIM$(getobj_poptext$(FORM_POPUPS,popup_menu))
		setobj_poptext MAIN_MENU,dummy$ : Object_Redraw main_handle,MAIN_MENU
		dummy$=LTRIM$(getobj_text$(MAIN_MENU))
		SELECT CASE dummy$
		CASE "Information" : CALL topMENU (MAIN_ABOUT,"Information")
		CASE "Personal Details" : CALL topMENU (MAIN_DETAILS,"Personal Details")
		CASE "Other..." : CALL topMENU (MAIN_OTHER,"Other...")
		CASE "Print Registration" : CALL topMENU (MAIN_PRINT,"Print Registration")
		END SELECT
	END IF
CASE MAIN_MENU2
	radio_poptext MAIN_MENU,FORM_POPUPS,POP_MENU,popup_menu
	dummy$=LTRIM$(getobj_text$(MAIN_MENU))
	setobj_text MAIN_MENU,dummy$ : Object_Redraw main_handle,MAIN_MENU
	SELECT CASE dummy$
	CASE "Information" : CALL topMENU (MAIN_ABOUT,"Information")
	CASE "Personal Details" : CALL topMENU (MAIN_DETAILS,"Personal Details")
	CASE "Other..." : CALL topMENU (MAIN_OTHER,"Other...") : CALL software
	CASE "Print Registration" : CALL topMENU (MAIN_PRINT,"Print Registration") : CALL summary
	END SELECT
CASE PRINT_OK : CALL print_registration
CASE MAIN_HELP : CALL STGUIDE_ONLINEHELP
CASE MAIN_BACK
	dummy$=LTRIM$(getobj_text$(MAIN_MENU))
	SELECT CASE dummy$
	CASE "Personal Details"
		setobj_poptext MAIN_MENU,"Information"
		CALL topMENU (MAIN_ABOUT,"Information")
	CASE "Other..."
		setobj_poptext MAIN_MENU,"Personal Details"
		CALL topMENU (MAIN_DETAILS,"Personal Details")
	CASE "Print Registration"
		setobj_poptext MAIN_MENU,"Other..."
		CALL topMENU (MAIN_OTHER,"Other...")
	END SELECT
	Object_Redraw main_handle,MAIN_MENU
CASE MAIN_NEXT 
	dummy$=LTRIM$(getobj_text$(MAIN_MENU))
	SELECT CASE dummy$
	CASE "Information"
		setobj_poptext MAIN_MENU,"Personal Details"
		CALL topMENU (MAIN_DETAILS,"Personal Details")
	CASE "Personal Details"
		setobj_poptext MAIN_MENU,"Other..."
		CALL topMENU (MAIN_OTHER,"Other...")
		CALL software
	CASE "Other..."
		setobj_poptext MAIN_MENU,"Print Registration"
		CALL topMENU (MAIN_PRINT,"Print Registration")
		CALL summary
	END SELECT
	Object_Redraw main_handle,MAIN_MENU
CASE MAIN_CLOSE : main_handle=0 : CommonClose=-1
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB topMENU (BYVAL treeno,BYVAL dummy$)
SHARED main_handle,summary_handle,popup_menu,CommonIndex,woTindex(),total_order
SHARED WindTLines$(),woTLines(),orderform$()
STATIC dummy,top_handle,file

include_flags MAIN_ABOUT,mask_hidetree
include_flags MAIN_DETAILS,mask_hidetree
include_flags MAIN_OTHER,mask_hidetree
include_flags MAIN_PRINT,mask_hidetree
remove_flags treeno,mask_hidetree

dummy=main_handle
IF dummy>0 THEN
	junk=wind_get(0,WF_TOP,top_handle,0,0,0)
	IF top_handle<>main_handle THEN dummy=0
END IF
main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,MAIN_CLOSE,VARPTRS(closeFORM_MAIN))
IF dummy>0 THEN Object_Redraw main_handle,treeno

SelectTree FORM_POPUPS
remove_state POP_MENU+1,mask_checked
remove_state POP_MENU+2,mask_checked
remove_state POP_MENU+3,mask_checked
remove_state POP_MENU+4,mask_checked
remove_state POP_MENU+5,mask_checked
SelectTree FORM_MAIN

SELECT CASE dummy$
CASE "Information"
	setobj_text MAIN_PAGE,"Page 1 of 4"
	IF enquire_state(MAIN_NEXT,mask_disabled) THEN
		remove_state MAIN_NEXT,mask_disabled
		IF dummy>0 THEN Object_Redraw main_handle,MAIN_NEXT
	END IF
	include_state MAIN_BACK,mask_disabled
	IF dummy>0 THEN Object_Redraw main_handle,MAIN_BACK
	SelectTree FORM_POPUPS
	include_state POP_MENU+1,mask_checked
	popup_menu=POP_MENU+1
	SelectTree FORM_MAIN
CASE "Print Registration"
	setobj_text MAIN_PAGE,"Page 4 of 4"
	IF enquire_state(MAIN_BACK,mask_disabled) THEN
		remove_state MAIN_BACK,mask_disabled
		IF dummy>0 THEN Object_Redraw main_handle,MAIN_BACK
	END IF
	include_state MAIN_NEXT,mask_disabled
	IF dummy>0 THEN Object_Redraw main_handle,MAIN_NEXT
	SelectTree FORM_POPUPS
	include_state POP_MENU+5,mask_checked
	popup_menu=POP_MENU+5
	SelectTree FORM_MAIN
CASE ELSE
	IF enquire_state(MAIN_BACK,mask_disabled) THEN
		remove_state MAIN_BACK,mask_disabled
		IF dummy>0 THEN Object_Redraw main_handle,MAIN_BACK
	END IF
	IF enquire_state(MAIN_NEXT,mask_disabled) THEN
		remove_state MAIN_NEXT,mask_disabled
		IF dummy>0 THEN Object_Redraw main_handle,MAIN_NEXT
	END IF
	SELECT CASE dummy$
	CASE "Personal Details"
		setobj_text MAIN_PAGE,"Page 2 of 4"
		SelectTree FORM_POPUPS
		include_state POP_MENU+2,mask_checked
		popup_menu=POP_MENU+2
		SelectTree FORM_MAIN
	CASE "Other..."
		setobj_text MAIN_PAGE,"Page 3 of 4"
		SelectTree FORM_POPUPS
		include_state POP_MENU+3,mask_checked
		popup_menu=POP_MENU+3
		SelectTree FORM_MAIN
	END SELECT
END SELECT
IF dummy>0 THEN Object_Redraw main_handle,MAIN_PAGE
IF summary_handle<>0 THEN
	CALL generate_summary
	CommonIndex=WhichWindow(summary_handle) : file=woTindex(CommonIndex)
	FOR dummy=0 TO total_order
		WindTLines$(file,dummy)=orderform$(dummy)
	NEXT
	woTLines(file)=total_order+1
	CALL FullRedraw (summary_handle)
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB STGUIDE_ONLINEHELP
IF NOT enquire_flags(MAIN_ABOUT,mask_hidetree) THEN junk=STGuide (CURDIR$+"\CYBERREG.HYP","Information")
IF NOT enquire_flags(MAIN_DETAILS,mask_hidetree) THEN junk=STGuide (CURDIR$+"\CYBERREG.HYP","Personal Details")
IF NOT enquire_flags(MAIN_OTHER,mask_hidetree) THEN junk=STGuide (CURDIR$+"\CYBERREG.HYP","Other...")
IF NOT enquire_flags(MAIN_PRINT,mask_hidetree) THEN junk=STGuide (CURDIR$+"\CYBERREG.HYP","Print Registration")
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
