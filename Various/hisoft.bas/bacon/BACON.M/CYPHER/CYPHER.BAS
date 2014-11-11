
' [CYPHER.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones
' Written by Matthew Bacon, ½ 1999 Cadenza Software
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z

REM $include F:\CADENZA\CYPHER\cypher.bh		' Declare *.BH file created from resource file
REM $include F:\ENCHANT\MODULES\error.bas							' Request the file ERROR.BAS
REM $include F:\CADENZA\CYPHER\toolbx_a.bas	' Request the file TOOLBX_A.BAS (i.e. GEM Toolkit)
REM $include F:\ENCHANT\MODULES\bubble.bas							' Request the file BUBBLE.BAS
REM $include F:\ENCHANT\MODULES\st-guide.bas						' Request the file ST-GUIDE.BAS
REM $include F:\ENCHANT\NEW\OLGA\olga.bas				' Request the file OLGA.BAS

MyProgram$="EncrypSTer r1.11"		' See GEM Toolkit manual
hook_enabled=-1 : hook_timeout=2000	' Every 2 secs

' Open resource file and display menu
CALL StartProgram (CURDIR$+"\CYPHER.RSC",FORM_MENU,MENU_QUIT,FORM_ICONIFY)
CALL Initialise_Settings				' Revert to default settings
junk=ole_protocol_init (ol_peer,"",0)	' Initialise OLGA-Protocol
CALL xENCHANTloop						' Program main loop
junk=ole_protocol_exit					' Exit OLGA-Protocol
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

SUB	HandleUserMenu (cur_front,item,title)
SHARED main_handle,info_handle

' If a menu item is selected...
SelectTree FORM_MENU
SELECT CASE item
CASE MENU_INFO
	info_handle=OpenFormWindow(MyProgram$,FORM_INFO,0,INFO_OK,VARPTRS(closeFORM_INFO))
CASE MENU_NEW
	CALL Initialise_Settings
	main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,MAIN_PASSWORD,MAIN_CANCEL,VARPTRS(closeFORM_MAIN))
CASE MENU_OPEN
	main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,MAIN_PASSWORD,MAIN_CANCEL,VARPTRS(closeFORM_MAIN))
CASE MENU_HELPTITLE
	junk=STGuide (CURDIR$+"\CYPHER.HYP","Title")
CASE MENU_CONTENTS
	junk=STGuide (CURDIR$+"\CYPHER.HYP","Contents")
CASE MENU_CADENZA
	junk=STGuide (CURDIR$+"\CYPHER.HYP","Cadenza Software")
END SELECT
END SUB

SUB HandleUserHook
SHARED main_handle,info_handle,bubble_time!
STATIC time!,handle,object

IF time!=0 THEN time!=TIMER
IF TIMER-time!<3 THEN EXIT SUB
junk=wind_get(junk,WF_TOP,handle,junk,junk,junk)
SELECT CASE handle
CASE info_handle
	SelectTree FORM_INFO
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE INFO_HELP : junk=BubbleGEM ("Displays the ST-Guide file for EncrypSTer.")
	CASE INFO_OK : junk=BubbleGEM ("Exits the 'Information' Dialog.")
	END SELECT
CASE main_handle
	SelectTree FORM_MAIN
	object=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
	SELECT CASE object
	CASE MAIN_SRCBROWSE : junk=BubbleGEM ("Select a source file to be encyphered/decyphered from the FileSelector.")
	CASE MAIN_DESTBROWSE : junk=BubbleGEM ("Select the destination file for encyphered/decyphered source.")
	CASE MAIN_LEVEL,MAIN_LEVELTICK : junk=BubbleGEM ("Select the level of binary encryption, from 8-bit to 256-bit.")
	CASE MAIN_USERPASS,MAIN_USERPASS2 : junk=BubbleGEM ("Determines if EncrypSTer uses the default or User password.")
	CASE MAIN_PASSWORD : junk=BubbleGEM ("User definable password (max. 32 characters)")
	CASE MAIN_ENCYPHER : junk=BubbleGEM ("Start encryption of source.")
	CASE MAIN_DECYPHER : junk=BubbleGEM ("Decypher source file.")
	CASE MAIN_HELP : junk=BubbleGEM ("Displays the ST-Guide file for EncrypSTer.")
	CASE MAIN_OK,MAIN_CANCEL : junk=BubbleGEM ("Exits Main Dialog.")
	END SELECT
END SELECT
IF object>0 THEN time!=0
END SUB

SUB TextWindArrowed(BYVAL WindowHandle,BYVAL which)
END SUB

SUB TextWindLoop (BYVAL key_pressed)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' EncrypSTer's default settings (reset strings, display cursor etc.)
SUB Initialise_Settings
SHARED woEditObj(0),woEditOffset(0)
STATIC CommonIndex
SHARED main_handle,sourcefile$,destfile$
SHARED security_level,password$,popup_level

MOUSE 2
SelectTree FORM_MAIN
setobj_text MAIN_SRCFILE,""
setobj_text MAIN_DESTFILE,""
setobj_poptext MAIN_LEVEL,"  "+getobj_poptext$(FORM_POPUP,POP_LEVEL+6)
popup_level=POP_LEVEL+6
setobj_shortcut MAIN_USERPASS,CHR$(14)
setobj_text MAIN_PASSWORD,""
sourcefile$=""
destfile$=""
security_level=VAL(getobj_text$(MAIN_LEVEL))
password$=""
IF main_handle>0 THEN
	Object_Redraw main_handle,0
	CommonIndex=WhichWindow(main_handle)
	woEditObj(CommonIndex)=MAIN_PASSWORD
	woEditOffset(CommonIndex)=LEN(getobj_text$(woEditObj(CommonIndex)))
	HandleCursor main_handle,1
END IF
MOUSE 0
END SUB


' If the user interacts with the Information formwindow...
SUB closeFORM_INFO
SHARED info_handle

SelectTree FORM_INFO
SELECT CASE CommonObj
CASE INFO_HELP
	junk=STGuide (CURDIR$+"\CYPHER.HYP","Information formwindow")
CASE INFO_OK
		CommonClose=-1
	info_handle=0
END SELECT
END SUB


' If the user interacts with the Main formwindow...
SUB closeFORM_MAIN
SHARED main_handle,fspath$,fsname$,fsmessage$
SHARED sourcefile$,destfile$,security_level,password$,popup_level
STATIC dummy$,button,total_olga_files

SelectTree FORM_MAIN
SELECT CASE CommonObj
CASE MAIN_SRCBROWSE
	' User selects the source file via the FileSelector
	IF fspath$="" THEN fspath$=CURDIR$+"\*.*"
	fsname$="" : fsmessage$="Source file..."
	fspath$=FileSelect$ (fsname$,1)
	sourcefile$=fspath$+fsname$
	IF fsname$<>"" THEN
		' If the source file exists, update user display
		IF FEXISTS(sourcefile$) THEN
			setobj_text MAIN_SRCFILE,fsname$
			Object_Redraw main_handle,MAIN_SRCFILE
		ELSE
			' If the source file does not exists, display error
			junk=form_alert(1,"[1][  "+MyProgram$+": |  The source file does not |  exist! ][ Abort ]")
			sourcefile$=""
		END IF
	ELSE
		sourcefile$=""
	END IF
CASE MAIN_DESTBROWSE
	' User selects the destination file via the FileSelector
	IF fspath$="" THEN fspath$=CURDIR$+"\*.*"
	fsname$="" : fsmessage$="Destination file..."
	fspath$=FileSelect$ (fsname$,1)
	destfile$=fspath$+fsname$
	IF fsname$<>"" THEN
		' If the source file exists, update user display
		IF FEXISTS(destfile$) THEN
			' If the source file does not exists, display error
			button=form_alert(1,"[1][  "+MyProgram$+": |  Replace file, "+fsname$+"? ][ Yes | No ]")
			IF button=2 THEN destfile$="" : EXIT SELECT
		END IF
		setobj_text MAIN_DESTFILE,fsname$
		Object_Redraw main_handle,MAIN_DESTFILE
	ELSE
		destfile$=""
	END IF
CASE MAIN_LEVEL,MAIN_LEVELTICK
	' If popup menu selected, allow user interaction
	popup_level=popup(main_handle,MAIN_LEVEL,FORM_POPUP,POP_LEVEL,popup_level)
	IF popup_level THEN
		dummy$=getobj_poptext$(FORM_POPUP,popup_level)
		setobj_poptext MAIN_LEVEL,"  "+dummy$
		Object_Redraw main_handle,MAIN_LEVEL
	END IF
CASE MAIN_ENCYPHER,MAIN_DECYPHER
	IF sourcefile$=destfile$ THEN
		junk=form_alert(1,"[1][  "+MyProgram$+": |  The source file cannot be |  the destination file! ][ Abort ]")
	ELSE
		security_level=VAL(getobj_text$(MAIN_LEVEL))
		password$="ABCDEFGHIJKLMNOPQRSTUVWXYZ123456"
		' If user password is selected
		IF getobj_shortcut(MAIN_USERPASS)=14 THEN MID$(password$,1)=getobj_text$(MAIN_PASSWORD)
		' OLGA-Protocol, see OLGA.TXT
		INCR total_olga_files
		junk=olga_protocol_opendoc (total_olga_files)
		' Cypher text
		junk=olga_manager_id
		CALL cypher_text(sourcefile$,destfile$,security_level,password$)
		junk=olga_protocol_link (destfile$,total_olga_files)
		junk=olga_protocol_update (destfile$,0)
		junk=olga_protocol_closedoc (total_olga_files)
	END IF
CASE MAIN_HELP
	junk=STGuide (CURDIR$+"\CYPHER.HYP","Main formwindow")
	CASE MAIN_OK,MAIN_CANCEL
	CommonClose=-1
	main_handle=0
END SELECT
END SUB


SUB cypher_text(BYVAL sourcefile$,BYVAL destfile$,BYVAL security_level,BYVAL password$)
STATIC myfile,myfile2,sourcetext$,desttext$,key$,mask$,binary$
STATIC dummy$,dummy,length&,total_length&,read_length&
STATIC x,y,w,h,old_tree&

IF NOT FEXISTS(sourcefile$) THEN
	junk=form_alert(1,"[1][  "+MyProgram$+": |  The source file does not |  exist! ][ Abort ]")
	EXIT SUB
ELSE
	IF sourcefile$=destfile$ THEN
		junk=form_alert(1,"[1][  "+MyProgram$+": |  The source file cannot be |  the destination file! ][ Abort ]")
		EXIT SUB
	END IF
END IF

MOUSE 2
dummy$=""
password$=LEFT$(password$,security_level/8)

key$=""
FOR dummy=1 TO LEN(password$) 
	key$=key$+BIN$(ASC(MID$(password$,dummy,1)))
NEXT dummy

myfile=FREEFILE
OPEN sourcefile$ FOR INPUT AS #myfile
total_length&=LOF(myfile)

myfile2=FREEFILE
OPEN destfile$ FOR OUTPUT AS #myfile2
length&=0

old_tree&=tree& : SelectTree FORM_WAIT
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)

WHILE length&<total_length&
	IF length&+LEN(password$)>=total_length& THEN
		read_length&=total_length&-length&
	ELSE
		read_length&=LEN(password$)
	END IF
	sourcetext$=INPUT$(read_length&,#myfile)
	length&=length&+LEN(password$)

	binary$=""
	FOR dummy=1 TO LEN(sourcetext$)
		dummy$="00000000"
		MID$(dummy$,9-LEN(BIN$(ASC(MID$(sourcetext$,dummy,1)))),8)=BIN$(ASC(MID$(sourcetext$,dummy,1)))
		binary$=binary$+dummy$
	NEXT dummy

	mask$=""
	FOR dummy=1 TO (LEN(binary$)/LEN(key$))+1
		mask$=mask$+key$
	NEXT dummy
	mask$=LEFT$(mask$,LEN(binary$))

	FOR dummy=1 TO LEN(binary$)
		IF MID$(mask$,dummy,1)="1" THEN
			IF MID$(binary$,dummy,1)="1" THEN
				MID$(binary$,dummy,1)="0"
			ELSE
				MID$(binary$,dummy,1)="1"
			END IF
		END IF
	NEXT dummy

	desttext$=""
	FOR dummy=1 TO LEN(binary$)
		desttext$=desttext$+CHR$(VAL("&b"+MID$(binary$,dummy,8)))
		dummy=dummy+7
	NEXT dummy

	BSAVE #myfile2,VARPTR(desttext$),LEN(desttext$)
	IF INKEY$=CHR$(27) THEN EXIT WHILE

	dummy=INT((length&/total_length&)*100)
	IF dummy>100 THEN dummy=100
	setobj_text WAIT_PERCENT,FORMATI$(dummy,"###")+"% Done"
	junk=objc_draw(tree&,WAIT_PERCENT,10,x,y,w,h)
WEND
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
tree&=old_tree&

CLOSE #myfile
CLOSE #myfile2
MOUSE 0
END SUB

'[END OF FILE]
