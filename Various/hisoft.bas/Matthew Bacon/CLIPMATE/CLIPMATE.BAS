
' [CLIPMATE.BAS]
' Developed by Matthew Bacon, ½ 1999 Matthew Bacon
' Published by Cadenza Software
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z

REM $include D:\CADENZA\CLIPMATE\clipmate.bh	' Declare *.BH file created from resource file
REM $include D:\ENCHANT\MODULES\error.bas		' Request the file ERROR.BAS
REM $include D:\CADENZA\CLIPMATE\toolbx_a.bas	' Request the file TOOLBX_A.BAS (i.e. GEM Toolkit)
REM $include D:\ENCHANT\TOOLKIT\toolwind.bas	' Request the file TOOLWIND.BAS
REM $include D:\ENCHANT\MODULES\bubble.bas		' Request the file BUBBLE.BAS
REM $include D:\ENCHANT\MODULES\st-guide.bas	' Request the file ST-GUIDE.BAS
REM $include D:\ENCHANT\NEW\OLGA\olga.bas		' Request the file OLGA.BAS

MyProgram$="ClipMate"	' See GEM Toolkit manual
hook_enabled=-1 : hook_timeout=1000	' Every 1 secs

DIM SHARED language$(100),alert$(50),bubble$(50),path$(50),mask$(2,15),view$(50),trash$(50)
DIM SHARED files$(200),dta(22)

' Open resource file and display menu
CALL StartProgram (CURDIR$+"\CLIPMATE.RSC",FORM_MENU,0,FORM_ICONIFY)
ENVIRON "CLIPMATE="+CURDIR$+"\CLIPMATE.PRG"
junk=ole_protocol_init (ol_peer,"",0)	' Initialise OLGA-Protocol

CALL import_language
CALL load_settings
CALL init_settings
CALL init_language
CALL init_Menu (FORM_MENU,MENU_QUIT)
CALL ScanPaths

CALL xENCHANTloop						' Program main loop
junk=ole_protocol_exit					' Exit OLGA-Protocol
ENVIRON "CLIPMATE="
CALL StopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Some of the sub-routines below are not used. However they must remain present
' as they are declared to exist within the GEM Toolkit.

FUNCTION HandleUserClose(BYVAL WindowHandle)
END FUNCTION

SUB HandleUserMessages
SHARED mess()
STATIC message

message=mess(0)
SELECT CASE message
CASE OLGA_INIT		' OLGA-Protocol 
    IF mess(7)=0 THEN olga_enabled=-1
CASE OLGA_RENAMELINK
	junk=olga_protocol_linkrenamed (getaddr_text$(SPEEKL(VARPTR(mess(3)))),getaddr_text$(SPEEKL(VARPTR(mess(5)))),mess(7))
CASE OLGA_LINKBROKEN
	junk=olga_protocol_unlink (getaddr_text$(SPEEKL(VARPTR(mess(3)))),mess(7))
END SELECT
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB

SUB	HandleUserMenu (WindowHandle,item,title)
SHARED info_handle,main_handle,fileinfo_handle,search_handle,mask_handle
SHARED prompt_user,sort_by,celly
STATIC dummy

' If a menu item is selected...
SelectTree FORM_MENU
SELECT CASE item
CASE MENU_ABOUT
	info_handle=OpenFormWindow(MyProgram$+" v0.90 ",FORM_INFO,0,0,VARPTRS(closeFORM_INFO))
CASE MENU_OPEN
	main_handle=OpenToolWindow(MyProgram$+" v0.90 ",&h41EF,FORM_MAIN,VARPTRS(redrawFORM_MAIN),VARPTRS(slidFORM_MAIN),VARPTRS(closeFORM_MAIN),400,300)
CASE MENU_CLOSE
	junk=wind_get(junk,WF_TOP,WindowHandle,junk,junk,junk)
	CALL CloseAWindow (WindowHandle)
CASE MENU_INFO
	fileinfo_handle=OpenFormWindow(MyProgram$,FORM_FILEINFO,FINFO_COMMENT,0,VARPTRS(closeFORM_FILEINFO))
CASE MENU_DELETE
CASE MENU_MERGE
CASE MENU_SEND
CASE MENU_QUIT : Finished_Flag=-1
CASE MENU_CUT
CASE MENU_COPY
CASE MENU_SELECTALL
CASE MENU_SEARCH
	search_handle=OpenFormWindow(MyProgram$,FORM_SEARCH,SEARCH_STRING,SEARCH_SEARCH,VARPTRS(closeFORM_SEARCH))
CASE MENU_SAGAIN
CASE MENU_MASK
	mask_handle=OpenFormWindow(MyProgram$,FORM_MASK,MASK_MASK1,0,VARPTRS(closeFORM_MASK))
CASE MENU_PROMPT
	IF prompt_user THEN
		CALL menu_icheck (menutree&,item,0)
		SelectTree FORM_POPUP
		CALL remove_state (CONFIG_PROMPT,mask_checked)
		prompt_user=0
	ELSE
		CALL menu_icheck (menutree&,item,1)
		SelectTree FORM_POPUP
		CALL include_state (CONFIG_PROMPT,mask_checked)
		prompt_user=-1
	END IF
CASE MENU_BYNAME,MENU_BYDATE,MENU_BYTYPE,MENU_BYSIZE
	FOR dummy=MENU_BYNAME TO MENU_BYSIZE
		CALL menu_icheck (menutree&,dummy,0)
	NEXT dummy
	CALL menu_icheck (menutree&,item,1)
	sort_by=item

	SelectTree FORM_POPUP
	FOR dummy=CONFIG_BYNAME TO CONFIG_BYSIZE
		CALL remove_state (dummy,mask_checked)
	NEXT dummy
	SELECT CASE sort_by
	CASE MENU_BYNAME : CALL include_state (CONFIG_BYNAME,mask_checked)
	CASE MENU_BYDATE : CALL include_state (CONFIG_BYDATE,mask_checked)
	CASE MENU_BYTYPE : CALL include_state (CONFIG_BYTYPE,mask_checked)
	CASE MENU_BYSIZE : CALL include_state (CONFIG_BYSIZE,mask_checked)
	END SELECT
CASE MENU_LOAD
	CALL load_settings
	CALL init_settings
CASE MENU_SAVE
CASE MENU_HELP
	junk=STGuide ("CLIPMATE.HYP","Contents")
CASE MENU_WHATSNEW
	junk=STGuide ("CLIPMATE.HYP","What's new?")
CASE MENU_SUPPORT
	junk=STGuide ("CLIPMATE.HYP","Support")
CASE MENU_CLIPMATE
	junk=STGuide ("CLIPMATE.HYP","ClipMate Protocol")
CASE MENU_CYBER
	junk=STGuide ("CLIPMATE.HYP","CyberSTrider")
CASE MENU_CADENZA
	junk=STGuide ("CLIPMATE.HYP","Cadenza Software")
END SELECT
END SUB

SUB HandleUserHook
SHARED info_handle,main_handle,fileinfo_handle,search_handle,mask_handle
STATIC time!,handle,object

CALL ScanPaths
IF time!=0 THEN time!=TIMER
IF TIMER-time!<3 THEN EXIT SUB

junk=wind_get(junk,WF_TOP,handle,junk,junk,junk)
SELECT CASE handle
CASE >=0
CASE info_handle
	SelectTree FORM_INFO
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE INFO_LOGO TO INFO_TRANS2 : junk=BubbleGEM (bubble$(1))
	END SELECT
CASE main_handle
	SelectTree FORM_MAIN
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE MAIN_OPEN : junk=BubbleGEM (bubble$(2))
	CASE MAIN_INFO : junk=BubbleGEM (bubble$(3))
	CASE MAIN_DELETE : junk=BubbleGEM (bubble$(4))
	CASE MAIN_SEND : junk=BubbleGEM (bubble$(5))
	CASE MAIN_CUT : junk=BubbleGEM (bubble$(6))
	CASE MAIN_COPY : junk=BubbleGEM (bubble$(7))
	CASE MAIN_SEARCH : junk=BubbleGEM (bubble$(8))
	CASE MAIN_MASK : junk=BubbleGEM (bubble$(9))
	CASE MAIN_LOAD : junk=BubbleGEM (bubble$(10))
	CASE MAIN_SAVE : junk=BubbleGEM (bubble$(11))
	CASE MAIN_CLOSE : junk=BubbleGEM (bubble$(12))
	CASE 0 : junk=BubbleGEM (bubble$(13))
	END SELECT
CASE fileinfo_handle
	SelectTree FORM_FILEINFO
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE FINFO_TFILENAME TO FINFO_TCOMMENT : junk=BubbleGEM (bubble$(14))
	END SELECT
CASE search_handle
	SelectTree FORM_SEARCH
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE SEARCH_STRING : junk=BubbleGEM (bubble$(15))
	CASE SEARCH_HELP : junk=BubbleGEM (bubble$(16))
	CASE SEARCH_SEARCH : junk=BubbleGEM (bubble$(17))
	CASE SEARCH_CANCEL : junk=BubbleGEM (bubble$(18))
	END SELECT
CASE mask_handle
	SelectTree FORM_MASK
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE MASK_M1 TO MASK_MASK10 : junk=BubbleGEM (bubble$(19))
	END SELECT
END SELECT
IF object>=0 THEN time!=0
END SUB

SUB TextWindArrowed(BYVAL WindowHandle,BYVAL which)
END SUB

SUB TextWindLoop (BYVAL key_pressed)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB import_language
STATIC myfile,dummy$,dummy

IF FEXISTS(CURDIR$+"\CLIPMATE.LNG") THEN
	MOUSE 2
	myfile=FREEFILE
	OPEN CURDIR$+"\CLIPMATE.LNG" FOR INPUT AS #myfile
	DO
	LINE INPUT #myfile,dummy$
	IF LEFT$(dummy$,5)="#LANG" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		language$(dummy)=MID$(dummy$,10,LEN(dummy$)-9)
	END IF
	IF LEFT$(dummy$,5)="#ALRT" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		alert$(dummy)=MID$(dummy$,10,LEN(dummy$)-9)
	END IF
	IF LEFT$(dummy$,5)="#BUBB" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		bubble$(dummy)=MID$(dummy$,10,LEN(dummy$)-9)
	END IF
	LOOP UNTIL EOF(myfile)
	CLOSE #myfile
	MOUSE 0
ELSE
	junk=form_alert(1,"[1][  "+MyProgram$+": |  CLIPMATE.LNG not found! ][Abort]")
	CALL StopProgram
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB load_settings
SHARED scan_time,sort_by,prompt_user
STATIC myfile,dummy$,dummy

IF FEXISTS(CURDIR$+"\CLIPMATE.LNG") THEN
	MOUSE 2
	myfile=FREEFILE
	OPEN CURDIR$+"\CLIPMATE.LNG" FOR INPUT AS #myfile
	DO
	LINE INPUT #myfile,dummy$
	IF LEFT$(dummy$,5)="#PATH" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		path$(dummy)=MID$(dummy$,10,LEN(dummy$)-9)
	END IF
	IF LEFT$(dummy$,5)="#MASK" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		mask$(0,dummy)=RIGHT$(dummy$,1)
		mask$(1,dummy)=MID$(dummy$,10,LEN(dummy$)-11)
	END IF
	IF LEFT$(dummy$,5)="#VIEW" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		view$(dummy)=MID$(dummy$,10,LEN(dummy$)-9)
	END IF
	IF LEFT$(dummy$,5)="#TRSH" THEN
		dummy=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		trash$(dummy)=MID$(dummy$,10,LEN(dummy$)-9)
	END IF
	IF LEFT$(dummy$,5)="#SCAN" THEN
		scan_time=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
	END IF
	IF LEFT$(dummy$,5)="#SORT" THEN
		sort_by=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
		sort_by=sort_by+(MENU_BYNAME-1)
	END IF
	IF LEFT$(dummy$,5)="#PROM" THEN
		prompt_user=VAL(RIGHT$(dummy$,LEN(dummy$)-5))
	END IF
	LOOP UNTIL EOF(myfile)
	CLOSE #myfile
	MOUSE 0
ELSE
	junk=form_alert(1,"[1][  "+MyProgram$+": |  CLIPMATE.LNG not found! ][Abort]")
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB init_settings
SHARED info_handle,main_handle,fileinfo_handle,search_handle,mask_handle
SHARED prompt_user,sort_by
STATIC dummy

MOUSE 2
'IF info_handle THEN CALL CloseAWindow (info_handle)
'IF main_handle THEN CALL CloseAWindow (main_handle)
'IF fileinfo_handle THEN CALL CloseAWindow (fileinfo_handle)
'IF search_handle THEN CALL CloseAWindow (search_handle)
'IF mask_handle THEN CALL CloseAWindow (mask_handle)

IF prompt_user THEN
	CALL menu_icheck (menutree&,MENU_PROMPT,1)
	SelectTree FORM_POPUP
	CALL include_state (CONFIG_PROMPT,mask_checked)
ELSE
	CALL menu_icheck (menutree&,MENU_PROMPT,0)
	SelectTree FORM_POPUP
	CALL remove_state (CONFIG_PROMPT,mask_checked)
END IF

IF sort_by=0 THEN sort_by=MENU_BYNAME
FOR dummy=MENU_BYNAME TO MENU_BYSIZE
	CALL menu_icheck (menutree&,dummy,0)
NEXT dummy
CALL menu_icheck (menutree&,sort_by,1)

SelectTree FORM_POPUP
FOR dummy=CONFIG_BYNAME TO CONFIG_BYSIZE
	CALL remove_state (dummy,mask_checked)
NEXT dummy
SELECT CASE sort_by
CASE MENU_BYNAME : CALL include_state (CONFIG_BYNAME,mask_checked)
CASE MENU_BYDATE : CALL include_state (CONFIG_BYDATE,mask_checked)
CASE MENU_BYTYPE : CALL include_state (CONFIG_BYTYPE,mask_checked)
CASE MENU_BYSIZE : CALL include_state (CONFIG_BYSIZE,mask_checked)
END SELECT

SelectTree FORM_SEARCH
setobj_text SEARCH_STRING,""

SelectTree FORM_MASK
setobj_text MASK_MASK1,mask$(1,1)
setobj_text MASK_MASK2,mask$(1,2)
setobj_text MASK_MASK3,mask$(1,3)
setobj_text MASK_MASK4,mask$(1,4)
setobj_text MASK_MASK5,mask$(1,5)
setobj_text MASK_MASK6,mask$(1,6)
setobj_text MASK_MASK7,mask$(1,7)
setobj_text MASK_MASK8,mask$(1,8)
setobj_text MASK_MASK9,mask$(1,9)
setobj_text MASK_MASK10,mask$(1,10)
setobj_shortcut MASK_M1,CHR$(13)
setobj_shortcut MASK_M2,CHR$(13)
setobj_shortcut MASK_M3,CHR$(13)
setobj_shortcut MASK_M4,CHR$(13)
setobj_shortcut MASK_M5,CHR$(13)
setobj_shortcut MASK_M6,CHR$(13)
setobj_shortcut MASK_M7,CHR$(13)
setobj_shortcut MASK_M8,CHR$(13)
setobj_shortcut MASK_M9,CHR$(13)
setobj_shortcut MASK_M10,CHR$(13)

IF mask$(0,1)="1" THEN setobj_shortcut MASK_M1,CHR$(14)
IF mask$(0,2)="1" THEN setobj_shortcut MASK_M2,CHR$(14)
IF mask$(0,3)="1" THEN setobj_shortcut MASK_M3,CHR$(14)
IF mask$(0,4)="1" THEN setobj_shortcut MASK_M4,CHR$(14)
IF mask$(0,5)="1" THEN setobj_shortcut MASK_M5,CHR$(14)
IF mask$(0,6)="1" THEN setobj_shortcut MASK_M6,CHR$(14)
IF mask$(0,7)="1" THEN setobj_shortcut MASK_M7,CHR$(14)
IF mask$(0,8)="1" THEN setobj_shortcut MASK_M8,CHR$(14)
IF mask$(0,9)="1" THEN setobj_shortcut MASK_M9,CHR$(14)
IF mask$(0,10)="1" THEN setobj_shortcut MASK_M10,CHR$(14)

SelectTree FORM_FILEINFO
setobj_spec_str FINFO_FILENAME,""
setobj_spec_str FINFO_DATE,""
setobj_spec_str FINFO_TIME,""
setobj_spec_str FINFO_SIZE,""
setobj_spec_str FINFO_PROGRAM,""
setobj_text FINFO_COMMENT,""
setobj_text FINFO_COMMENT2,""
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB init_language
SHARED cellx,celly
STATIC dummy

junk=graf_handle(cellx,celly,junk,junk)
MOUSE 2
SelectTree FORM_MENU
setobj_spec_str MENUT_CLIPMATE," "+language$(1)+" "
setobj_spec_str MENU_ABOUT,"  "+language$(6)+" "

setobj_spec_str MENUT_FILE," "+language$(2)+" "
setobj_spec_str MENU_OPEN,"  "+language$(7)+" "
setobj_spec_str MENU_CLOSE,"  "+language$(8)+" "
setobj_spec_str MENU_INFO,"  "+language$(9)+" "
setobj_spec_str MENU_DELETE,"  "+language$(10)+" "
setobj_spec_str MENU_MERGE,"  "+language$(11)+" "
setobj_spec_str MENU_SEND,"  "+language$(12)+" "
setobj_spec_str MENU_QUIT,"  "+language$(13)+" "

setobj_spec_str MENUT_EDIT," "+language$(3)+" "
setobj_spec_str MENU_CUT,"  "+language$(14)+" "
setobj_spec_str MENU_COPY,"  "+language$(15)+" "
setobj_spec_str MENU_SELECTALL,"  "+language$(16)+" "
setobj_spec_str MENU_SEARCH,"  "+language$(17)+" "
setobj_spec_str MENU_SAGAIN,"  "+language$(18)+" "

setobj_spec_str MENUT_CONFIG," "+language$(4)+" "
setobj_spec_str MENU_MASK,"  "+language$(19)+" "
setobj_spec_str MENU_PROMPT,"  "+language$(20)+" "
setobj_spec_str MENU_BYNAME,"  "+language$(21)+" "
setobj_spec_str MENU_BYDATE,"  "+language$(22)+" "
setobj_spec_str MENU_BYTYPE,"  "+language$(23)+" "
setobj_spec_str MENU_BYSIZE,"  "+language$(24)+" "
setobj_spec_str MENU_LOAD,"  "+language$(25)+" "
setobj_spec_str MENU_SAVE,"  "+language$(26)+" "

setobj_spec_str MENUT_HELP," "+language$(5)+" "
setobj_spec_str MENU_HELP,"  "+language$(27)+" "
setobj_spec_str MENU_WHATSNEW,"  "+language$(28)+" "
setobj_spec_str MENU_SUPPORT,"  "+language$(29)+" "
setobj_spec_str MENU_CLIPMATE,"  "+language$(30)+" "
setobj_spec_str MENU_CYBER,"  "+language$(31)+" "
setobj_spec_str MENU_CADENZA,"  "+language$(32)+" "

setobj_width MENU_ABOUT-1,cellx*LEN(getobj_spec$(MENU_ABOUT))
FOR dummy=MENU_ABOUT TO MENU_ABOUT+7
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_ABOUT)))
	setobj_width dummy,cellx*LEN(getobj_spec$(MENU_ABOUT))
NEXT dummy

setobj_width MENUT_CLIPMATE,cellx*LEN(getobj_spec$(MENUT_CLIPMATE))
setobj_x MENUT_FILE,getobj_x(MENUT_CLIPMATE)+getobj_width(MENUT_CLIPMATE)
setobj_width MENUT_FILE,cellx*LEN(getobj_spec$(MENUT_FILE))
setobj_x MENU_OPEN-1,getobj_x(MENUT_FILE)+(2*cellx)
setobj_width MENU_OPEN-1,cellx*LEN(getobj_spec$(MENU_OPEN))
FOR dummy=MENU_OPEN TO MENU_QUIT
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_OPEN)))
	setobj_width dummy,cellx*LEN(getobj_spec$(MENU_OPEN))
NEXT dummy

setobj_x MENUT_EDIT,getobj_x(MENUT_FILE)+getobj_width(MENUT_FILE)
setobj_width MENUT_EDIT,cellx*LEN(getobj_spec$(MENUT_EDIT))
setobj_x MENU_CUT-1,getobj_x(MENUT_EDIT)+(2*cellx)
setobj_width MENU_CUT-1,cellx*LEN(getobj_spec$(MENU_CUT))
FOR dummy=MENU_CUT TO MENU_SAGAIN
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_CUT)))
	setobj_width dummy,cellx*LEN(getobj_spec$(MENU_CUT))
NEXT dummy

setobj_x MENUT_CONFIG,getobj_x(MENUT_EDIT)+getobj_width(MENUT_EDIT)
setobj_width MENUT_CONFIG,cellx*LEN(getobj_spec$(MENUT_CONFIG))
setobj_x MENU_MASK-1,getobj_x(MENUT_CONFIG)+(2*cellx)
setobj_width MENU_MASK-1,cellx*LEN(getobj_spec$(MENU_MASK))
FOR dummy=MENU_MASK TO MENU_SAVE
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_MASK)))
	setobj_width dummy,cellx*LEN(getobj_spec$(MENU_MASK))
NEXT dummy

setobj_x MENUT_HELP,getobj_x(MENUT_CONFIG)+getobj_width(MENUT_CONFIG)
setobj_width MENUT_HELP,cellx*LEN(getobj_spec$(MENUT_HELP))
setobj_x MENU_HELP-1,getobj_x(MENUT_HELP)+(2*cellx)
setobj_width MENU_HELP-1,cellx*LEN(getobj_spec$(MENU_HELP))
FOR dummy=MENU_HELP TO MENU_CADENZA
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_HELP)))
	setobj_width dummy,cellx*LEN(getobj_spec$(MENU_HELP))
NEXT dummy

setobj_width MENUT_CLIPMATE-1,getobj_x(MENUT_HELP)+getobj_width(MENUT_HELP)

SelectTree FORM_INFO
setobj_text INFO_AUTHOR,language$(33)
setobj_text INFO_DIST,language$(34)
setobj_text INFO_LANG,language$(35)
setobj_text INFO_LANG2,language$(36)
setobj_text INFO_TRANS,language$(37)
setobj_text INFO_TRANS2,language$(38)

SelectTree FORM_MAIN
setobj_text MAIN_FILE," "+language$(2)+" "
setobj_text MAIN_EDIT," "+language$(3)+" "
setobj_text MAIN_CONFIG," "+language$(4)+" "
setobj_text MAIN_HELP," "+language$(5)+" "

setobj_width MAIN_FILE,cellx*LEN(getobj_text$(MAIN_FILE))
setobj_x MAIN_EDIT,getobj_x(MAIN_FILE)+getobj_width(MAIN_FILE)
setobj_width MAIN_EDIT,cellx*LEN(getobj_text$(MAIN_EDIT))
setobj_x MAIN_CONFIG,getobj_x(MAIN_EDIT)+getobj_width(MAIN_EDIT)
setobj_width MAIN_CONFIG,cellx*LEN(getobj_text$(MAIN_CONFIG))
setobj_x MAIN_HELP,getobj_x(MAIN_CONFIG)+getobj_width(MAIN_CONFIG)
setobj_width MAIN_HELP,cellx*LEN(getobj_text$(MAIN_HELP))
	
SelectTree FORM_FILEINFO
setobj_spec_str FINFO_TFILENAME,language$(47)
setobj_spec_str FINFO_TTIME,language$(48)
setobj_spec_str FINFO_TDATE,language$(49)
setobj_spec_str FINFO_TSIZE,language$(50)
setobj_spec_str FINFO_TPROGRAM,language$(51)
setobj_spec_str FINFO_TCOMMENT,language$(52)

SelectTree FORM_SEARCH
setobj_spec_str SEARCH_HELP,language$(39)
setobj_spec_str SEARCH_SEARCH,language$(40)
setobj_spec_str SEARCH_CANCEL,language$(41)

SelectTree FORM_POPUP
setobj_spec_str FILE_OPEN,"  "+language$(7)+" "
setobj_spec_str FILE_CLOSE,"  "+language$(8)+" "
setobj_spec_str FILE_INFO,"  "+language$(9)+" "
setobj_spec_str FILE_DELETE,"  "+language$(10)+" "
setobj_spec_str FILE_MERGE,"  "+language$(11)+" "
setobj_spec_str FILE_SEND,"  "+language$(12)+" "
setobj_spec_str FILE_QUIT,"  "+language$(13)+" "

setobj_width FILE_OPEN-1,cellx*LEN(getobj_spec$(FILE_OPEN))
FOR dummy=FILE_OPEN TO FILE_QUIT
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(FILE_OPEN)))
	setobj_width dummy,cellx*LEN(getobj_spec$(FILE_OPEN))
NEXT dummy

setobj_spec_str EDIT_CUT,"  "+language$(14)+" "
setobj_spec_str EDIT_COPY,"  "+language$(15)+" "
setobj_spec_str EDIT_SELECTALL,"  "+language$(16)+" "
setobj_spec_str EDIT_SEARCH,"  "+language$(17)+" "
setobj_spec_str EDIT_SAGAIN,"  "+language$(18)+" "

setobj_width EDIT_CUT-1,cellx*LEN(getobj_spec$(EDIT_CUT))
FOR dummy=EDIT_CUT TO EDIT_SAGAIN
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(EDIT_CUT)))
	setobj_width dummy,cellx*LEN(getobj_spec$(EDIT_CUT))
NEXT dummy

setobj_spec_str CONFIG_MASK,"  "+language$(19)+" "
setobj_spec_str CONFIG_PROMPT,"  "+language$(20)+" "
setobj_spec_str CONFIG_BYNAME,"  "+language$(21)+" "
setobj_spec_str CONFIG_BYDATE,"  "+language$(22)+" "
setobj_spec_str CONFIG_BYTYPE,"  "+language$(23)+" "
setobj_spec_str CONFIG_BYSIZE,"  "+language$(24)+" "
setobj_spec_str CONFIG_LOAD,"  "+language$(25)+" "
setobj_spec_str CONFIG_SAVE,"  "+language$(26)+" "

setobj_width CONFIG_MASK-1,cellx*LEN(getobj_spec$(CONFIG_MASK))
FOR dummy=CONFIG_MASK TO CONFIG_SAVE
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(CONFIG_MASK)))
	setobj_width dummy,cellx*LEN(getobj_spec$(CONFIG_MASK))
NEXT dummy

setobj_spec_str HELP_HELP,"  "+language$(27)+" "
setobj_spec_str HELP_WHATSNEW,"  "+language$(28)+" "
setobj_spec_str HELP_SUPPORT,"  "+language$(29)+" "
setobj_spec_str HELP_CLIPMATE,"  "+language$(30)+" "
setobj_spec_str HELP_CYBER,"  "+language$(31)+" "
setobj_spec_str HELP_CADENZA,"  "+language$(32)+" "

setobj_width HELP_HELP,cellx*LEN(getobj_spec$(HELP_HELP))
FOR dummy=HELP_HELP TO HELP_CADENZA
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(HELP_HELP)))
	setobj_width dummy,cellx*LEN(getobj_spec$(HELP_HELP))
NEXT dummy
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_INFO
SHARED info_handle

SELECT CASE CommonObj
CASE ELSE : info_handle=0
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_MAIN
SHARED main_handle
STATIC dummy,popup_file,popup_edit,popup_config,popup_help

SelectTree FORM_MAIN
SELECT CASE CommonObj
CASE MAIN_FILE
	popup_file=popup_menu(main_handle,MAIN_FILE,FORM_POPUP,POP_FILE)
	dummy=(MENU_OPEN-1)+(popup_file-POP_FILE)
	remove_state CommonObj,mask_selected
	Object_Redraw main_handle,CommonObj
	IF popup_file THEN CALL HandleUserMenu (main_handle,dummy,MENUT_FILE)
CASE MAIN_EDIT
	popup_edit=popup_menu(main_handle,MAIN_EDIT,FORM_POPUP,POP_EDIT)
	dummy=(MENU_CUT-1)+(popup_edit-POP_EDIT)
	remove_state CommonObj,mask_selected
	Object_Redraw main_handle,CommonObj
	IF popup_edit THEN CALL HandleUserMenu (main_handle,dummy,MENUT_EDIT)
CASE MAIN_CONFIG
	popup_config=popup_menu(main_handle,MAIN_CONFIG,FORM_POPUP,POP_CONFIG)
	dummy=(MENU_MASK-1)+(popup_config-POP_CONFIG)
	remove_state CommonObj,mask_selected
	Object_Redraw main_handle,CommonObj
	IF popup_config THEN CALL HandleUserMenu (main_handle,dummy,MENUT_CONFIG)
CASE MAIN_HELP
	popup_help=popup_menu(main_handle,MAIN_HELP,FORM_POPUP,POP_HELP)
	dummy=(MENU_HELP-1)+(popup_help-POP_HELP)
	remove_state CommonObj,mask_selected
	Object_Redraw main_handle,CommonObj
	IF popup_help THEN CALL HandleUserMenu (main_handle,dummy,MENUT_HELP)
CASE MAIN_OPEN : CALL HandleUserMenu (main_handle,MENU_OPEN,MENUT_FILE)
CASE MAIN_INFO : CALL HandleUserMenu (main_handle,MENU_INFO,MENUT_FILE)
CASE MAIN_DELETE : CALL HandleUserMenu (main_handle,MENU_DELETE,MENUT_FILE)
CASE MAIN_SEND : CALL HandleUserMenu (main_handle,MENU_SEND,MENUT_FILE)
CASE MAIN_CUT : CALL HandleUserMenu (main_handle,MENU_CUT,MENUT_EDIT)
CASE MAIN_COPY : CALL HandleUserMenu (main_handle,MENU_COPY,MENUT_EDIT)
CASE MAIN_SEARCH : CALL HandleUserMenu (main_handle,MENU_SEARCH,MENUT_EDIT)
CASE MAIN_MASK : CALL HandleUserMenu (main_handle,MENU_MASK,MENUT_CONFIG)
CASE MAIN_LOAD : CALL HandleUserMenu (main_handle,MENU_LOAD,MENUT_CONFIG)
CASE MAIN_SAVE : CALL HandleUserMenu (main_handle,MENU_SAVE,MENUT_CONFIG)
CASE MAIN_CLOSE : CALL HandleUserMenu (main_handle,MENU_CLOSE,MENUT_FILE)
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_FILEINFO
SHARED fileinfo_handle

SELECT CASE CommonObj
CASE ELSE : fileinfo_handle=0
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_SEARCH
SHARED search_handle

SELECT CASE CommonObj
CASE SEARCH_HELP : junk=STGuide ("CLIPMATE.HYP","Search Dialog")
CASE SEARCH_SEARCH
CASE SEARCH_CANCEL
	search_handle=0
	CommonClose=-1
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_MASK
SHARED mask_handle
STATIC dummy

SELECT CASE CommonObj
CASE ELSE
	mask$(1,1)=getobj_text$(MASK_MASK1)
	mask$(1,2)=getobj_text$(MASK_MASK2)
	mask$(1,3)=getobj_text$(MASK_MASK3)
	mask$(1,4)=getobj_text$(MASK_MASK4)
	mask$(1,5)=getobj_text$(MASK_MASK5)
	mask$(1,6)=getobj_text$(MASK_MASK6)
	mask$(1,7)=getobj_text$(MASK_MASK7)
	mask$(1,8)=getobj_text$(MASK_MASK8)
	mask$(1,9)=getobj_text$(MASK_MASK9)
	mask$(1,10)=getobj_text$(MASK_MASK10)
	FOR dummy=1 TO 10
		mask$(0,dummy)="0"
	NEXT dummy
	IF getobj_shortcut(MASK_M1)=14 THEN mask$(0,1)="1"
	IF getobj_shortcut(MASK_M2)=14 THEN mask$(0,2)="1"
	IF getobj_shortcut(MASK_M3)=14 THEN mask$(0,3)="1"
	IF getobj_shortcut(MASK_M4)=14 THEN mask$(0,4)="1"
	IF getobj_shortcut(MASK_M5)=14 THEN mask$(0,5)="1"
	IF getobj_shortcut(MASK_M6)=14 THEN mask$(0,6)="1"
	IF getobj_shortcut(MASK_M7)=14 THEN mask$(0,7)="1"
	IF getobj_shortcut(MASK_M8)=14 THEN mask$(0,8)="1"
	IF getobj_shortcut(MASK_M9)=14 THEN mask$(0,9)="1"
	IF getobj_shortcut(MASK_M10)=14 THEN mask$(0,10)="1"
	mask_handle=0
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION ReadFilename$ (dta&)
STATIC dummy$,dummy,char

dummy$=""
FOR dummy=30 TO 43
	char=PEEKB(dta&+dummy)
	IF char=0 THEN EXIT FOR
	dummy$=dummy$+CHR$(char)
NEXT dummy
ReadFilename$=dummy$
END FUNCTION

FUNCTION calcTIME$(a,b)
STATIC hour,mins,sec

calcTIME$="00:00:00"
hour=FIX((a*8)/64)
mins=((((a*8)/64)-FIX((a*8)/64))*64)+FIX(b/32)
sec=((b/32)-FIX(b/32))*64
IF hour<10 THEN
	MID$(calcTIME$,1,2)="0"+FORMATI$(hour,"#")
ELSE
	MID$(calcTIME$,1,2)=FORMATI$(hour,"##")
END IF
IF mins<10 THEN
	MID$(calcTIME$,4,2)="0"+FORMATI$(mins,"#")
ELSE
	MID$(calcTIME$,4,2)=FORMATI$(mins,"##")
END IF
IF sec<10 THEN
	MID$(calcTIME$,7,2)="0"+FORMATI$(sec,"#")
ELSE
	MID$(calcTIME$,7,2)=FORMATI$(sec,"##")
END IF
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION calcDATE$(a,b)
STATIC day,month

calcDATE$="00-00-0000"
SELECT CASE b
CASE 1 TO 32 : day=b-0 : month=0
CASE 33 TO 64 : day=b-32 : month=1
CASE 65 TO 96 : day=b-64 : month=2
CASE 97 TO 128 : day=b-96 : month=3
CASE 129 TO 160 : day=b-128 : month=4
CASE 161 TO 192 : day=b-160 : month=5
CASE 193 TO 224 : day=b-192 : month=6
CASE 225 TO 255 : day=b-224 : month=7
END SELECT
IF a MOD 2 THEN month=month+8
IF day<10 THEN
	MID$(calcDATE$,1,2)="0"+FORMATI$(day,"#")
ELSE
	MID$(calcDATE$,1,2)=FORMATI$(day,"##")
END IF
IF month<10 THEN
	MID$(calcDATE$,4,2)="0"+FORMATI$(month,"#")
ELSE
	MID$(calcDATE$,4,2)=FORMATI$(month,"##")
END IF
MID$(calcDATE$,7,4)=FORMATI$(FIX(a/2)+1980,"####")
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ScanPaths
SHARED main_handle,total_files,scan_time
STATIC dta&,olddta&,dummy,toserr,time!
STATIC filename$,timestamp$,datestamp$,filesize$

IF time!=0 THEN time!=TIMER
IF TIMER-time!<scan_time THEN EXIT SUB

MOUSE 2
dta&=VARPTR(dta(0))
olddta&=fgetdta&
fsetdta dta&
total_files=0
FOR dummy=1 TO UBOUND(path$)
	IF path$(dummy)<>"" THEN
	toserr=fsfirst (path$(dummy),1+2+4+32)
	DO
		SELECT CASE toserr
		CASE 0
			filename$="              "
			MID$(filename$,1,12)=ReadFilename$(dta&)
			timestamp$="        "
			MID$(timestamp$,1,8)=calcTIME$(PEEKB(dta&+22),PEEKB(dta&+23))
			datestamp$="          "
			MID$(datestamp$,1,10)=calcDATE$(PEEKB(dta&+24),PEEKB(dta&+25))
			filesize$=LTRIM$(STR$(PEEKL(dta&+26)))
			files$(total_files)=filename$+"  "+timestamp$+"  "+datestamp$+"  "+filesize$
			INCR total_files
		CASE ELSE : EXIT LOOP
		END SELECT
		toserr=fsnext
	LOOP UNTIL toserr<>0
	END IF
NEXT dummy
files$(total_files)=LTRIM$(STR$(total_files))+" files listed."
INCR total_files : INCR total_files
fsetdta olddta&
IF main_handle THEN CALL FullRedraw (main_handle)
time!=0
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB redrawFORM_MAIN
SHARED CommonIndex,CommonHandle,cellx,celly,woOffy()
SHARED total_files
STATIC x,y,w,h,x1,y1,w1,h1,dummy,y_pos

CALL RedrawFormWind
CommonIndex=WhichWindow(CommonHandle) : IF CommonIndex=0 THEN EXIT SUB
junk=wind_get(CommonHandle,WF_WORKXYWH,x1,y1,w1,h1)
SelectTree FORM_MAIN
CALL getobj_xywh (MAIN_ICONBAR,x,y,w,h)
y_pos=y1+y+h+celly
FOR dummy=woOffy(CommonIndex)\celly TO total_files
	v_gtext x1+cellx,y_pos,files$(dummy)
	y_pos=y_pos+celly
NEXT dummy
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB slidFORM_MAIN
SHARED CommonIndex,CommonHandle,CommonMAXx,CommonMAXy,cellx,celly
SHARED total_files
STATIC x,y,w,h,x1,y1,w1,h1,dummy

CommonIndex=WhichWindow(CommonHandle) : IF CommonIndex=0 THEN EXIT SUB
junk=wind_get(CommonHandle,WF_WORKXYWH,x1,y1,w1,h1)
CALL getobj_xywh (MAIN_ICONBAR,x,y,w,h)
CommonMAXx=0
CommonMAXy=CINT(total_files+(h/celly))*celly
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'[END OF FILE]
