
' [ENCRYPT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones
' Written by Matthew Bacon, ½ 1999 Cadenza Software
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z

REM $include D:\ENCHANT\EXAMPLES\ENCRYPST.ER\ENCRYPT.bh	' Declare *.BH file created from resource file
REM $include D:\ENCHANT\MODUES\ERROR.BAS				' Request the file ERROR.BAS
REM $include D:\ENCHANT\EXAMPLES\ENCRYPST.ER\TOOLBX_A.BAS	' Request the file TOOLBX_A.BAS (i.e. GEM Toolkit)
REM $include D:\ENCHANT\MODUES\BUBBLE.BAS				' Request the file BUBBLE.BAS
REM $include D:\ENCHANT\MODUES\ST-GUIDE.BAS				' Request the file ST-GUIDE.BAS
REM $include D:\ENCHANT\NEW\OLGA\OLGA.BAS				' Request the file OLGA.BAS
REM $include D:\ENCHANT\NEW\CYPHER2\CYPHER2.BAS			' Request the file CYPHER2.BAS

MyProgram$="EncrypSTer"		' See GEM Toolkit manual
HowManyButtons=2

' Open resource file and display menu
CALL StartProgram (CURDIR$+"\ENCRYPT.RSC",FORM_MENU,MENU_QUIT,FORM_ICONIFY)
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

SUB HandleUserMenu (cur_front,item,title)
SHARED main_handle,info_handle

' If a menu item is selected...
SelectTree FORM_MENU
SELECT CASE item
CASE MENU_INFO
	info_handle=OpenFormWindow(MyProgram$+": Information",FORM_INFO,0,INFO_OK,VARPTRS(closeFORM_INFO))
CASE MENU_NEW
	CALL Initialise_Settings
	main_handle=OpenFormWindow(MyProgram$+": AC Preview",FORM_MAIN,MAIN_PASSWORD,MAIN_CANCEL,VARPTRS(closeFORM_MAIN))
CASE MENU_OPEN
	main_handle=OpenFormWindow(MyProgram$+": AC Preview",FORM_MAIN,MAIN_PASSWORD,MAIN_CANCEL,VARPTRS(closeFORM_MAIN))
CASE MENU_HELPTITLE
	junk=STGuide ("ENCRYPT.HYP","Title")
CASE MENU_CONTENTS
	junk=STGuide ("ENCRYPT.HYP","Contents")
CASE MENU_CADENZA
	junk=STGuide ("ENCRYPT.HYP","Cadenza Software")
END SELECT
END SUB

SUB HandleUserHook
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
IF CommonButton=2 THEN
	' If the right mouse button is used, then display BubbleGEM
	SELECT CASE CommonObj
	CASE INFO_HELP : junk=BubbleGEM ("Displays the ST-Guide file for EncrypSTer.")
	CASE INFO_OK : junk=BubbleGEM ("Exits the 'Information' Dialog.")
	END SELECT
ELSE
	SELECT CASE CommonObj
	CASE INFO_HELP
		junk=STGuide ("ENCRYPT.HYP","Information formwindow")
	CASE INFO_OK
		CommonClose=-1
	END SELECT
END IF
END SUB


' If the user interacts with the Main formwindow...
SUB closeFORM_MAIN
SHARED main_handle,fspath$,fsname$,fsmessage$
SHARED sourcefile$,destfile$,security_level,password$,popup_level
STATIC dummy$,button,total_olga_files

SelectTree FORM_MAIN
IF CommonButton=2 THEN
	' If the right mouse button is used, then display BubbleGEM
	SELECT CASE CommonObj
	CASE MAIN_SRCBROWSE : junk=BubbleGEM ("Select a source file to be encyphered/decyphered from the FileSelector.")
	CASE MAIN_DESTBROWSE : junk=BubbleGEM ("Select the destination file for encyphered/decyphered source.")
	CASE MAIN_LEVEL,MAIN_LEVELTICK : junk=BubbleGEM ("Select the level of binary encryption, from 8-bit to 256-bit.")
	CASE MAIN_ENCYPHER : junk=BubbleGEM ("Start encruption of source.")
	CASE MAIN_DECYPHER : junk=BubbleGEM ("Decypher source file.")
	CASE MAIN_HELP : junk=BubbleGEM ("Displays the ST-Guide file for EncrypSTer.")
	CASE MAIN_OK,MAIN_CANCEL : junk=BubbleGEM ("Exits Main Dialog.")
	END SELECT
ELSE
	SELECT CASE CommonObj
	CASE MAIN_SRCBROWSE
		' User selects the source file via the FileSelector
		fspath$=CURDIR$+"\*.*" : fsname$="" : fsmessage$="Source file..."
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
		fspath$=CURDIR$+"\*.*" : fsname$="" : fsmessage$="Destination file..."
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
			CALL cypher_text(sourcefile$,destfile$,security_level,password$)
			junk=olga_protocol_link (destfile$,total_olga_files)
			junk=olga_protocol_update (destfile$,0)
			junk=olga_protocol_closedoc (total_olga_files)
		END IF
	CASE MAIN_HELP
		junk=STGuide ("ENCRYPT.HYP","Main formwindow")
	CASE MAIN_OK,MAIN_CANCEL
		CommonClose=-1
	END SELECT
END IF
END SUB

'[END OF FILE]
