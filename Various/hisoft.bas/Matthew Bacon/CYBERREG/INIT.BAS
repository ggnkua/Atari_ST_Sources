'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DIM orderform$(100),itemfee$(100)

clicks_enabled=-1 : keys_enabled=-1 : userclose_enabled=-1
CALL initFORM_MAIN : CALL initFORM_OTHER : CALL initFORM_PRINT

setobj_text MAIN_PAGE,"Page 1 of 4"
remove_flags MAIN_ABOUT,mask_hidetree
setobj_poptext MAIN_MENU,"Information"
main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,MAIN_CLOSE,VARPTRS(closeFORM_MAIN))

SelectTree FORM_POPUPS
include_state POP_MENU+1,mask_checked
popup_menu=POP_MENU+1
SelectTree FORM_MAIN

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB initFORM_MAIN
SHARED main_handle,popup_country,popup_computer,popup_os,popup_emulation,popup_drive
SHARED MaxTextWindows,MaxTextLines,selected_items,software_handle,summary_handle
SHARED woVSWR(),itemfee$(),TextWindowSystem
STATIC i,dummy

SelectTree FORM_MAIN
setobj_text MAIN_PAGE,"Page 2 of 4"
setobj_text DET_NAME,""
setobj_text DET_STREET,""
setobj_text DET_TOWN,""
setobj_text DET_POSTCODE,""
setobj_text DET_PHONE,""
setobj_text DET_EMAIL,""
setobj_poptext DET_COUNTRY,"  "+getobj_poptext$(FORM_POPUPS,POP_COUNTRY+1)
setobj_poptext DET_COMPUTER,"  "+getobj_poptext$(FORM_POPUPS,POP_COMPUTER+4)
setobj_poptext DET_OS,"  "+getobj_poptext$(FORM_POPUPS,POP_OS+7)
setobj_poptext DET_EMULATION,"  "+getobj_poptext$(FORM_POPUPS,POP_EMULATION+1)
setobj_poptext DET_DRIVE,"  "+getobj_poptext$(FORM_POPUPS,POP_DRIVE+3)
include_state MAIN_BACK,mask_disabled

SelectTree FORM_POPUPS
dummy=0
DO
	remove_state dummy,mask_checked
	IF enquire_flags(dummy,mask_lastob) THEN EXIT LOOP
	INCR dummy
LOOP UNTIL enquire_flags(dummy,mask_lastob)

include_state POP_COUNTRY+1,mask_checked
include_state POP_COMPUTER+4,mask_checked
include_state POP_OS+7,mask_checked
include_state POP_EMULATION+1,mask_checked
include_state POP_DRIVE+3,mask_checked
popup_country=POP_COUNTRY+1
popup_computer=POP_COMPUTER+4
popup_os=POP_OS+7
popup_emulation=POP_EMULATION+1
popup_drive=POP_DRIVE+3

selected_items=0
IF software_handle THEN CALL CloseAWindow(software_handle)
IF summary_handle THEN CALL CloseAWindow(summary_handle)

IF TextWindowSystem=0 THEN InitTextSystem 2,200
FOR i=0 TO MaxTextWindows-1
	FOR dummy=0 TO MaxTextLines-1
		woVSWR(i,dummy)=1
		itemfee$(i)=""
	NEXT
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB initFORM_OTHER
SelectTree FORM_MAIN
setobj_shortcut OTHER_REQUIRED,CHR$(12)
setobj_shortcut OTHER_NREQUIRED,CHR$(11)
setobj_shortcut OTHER_FVERSION,CHR$(14)
setobj_shortcut OTHER_MAIL,CHR$(14)

remove_state OTHER_FVERSION,mask_disabled
remove_state OTHER_FVERSION2,mask_disabled
remove_state OTHER_MAIL,mask_disabled
remove_state OTHER_MAIL2,mask_disabled
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB initFORM_PRINT
SelectTree FORM_MAIN
setobj_text PRINT_LPP,"60"
CALL init_dialog (FORM_MAIN)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
