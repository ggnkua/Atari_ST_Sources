'===============================================================================
' WebPage.Wizard v3.10 - Copyright ½ 1997-1999 Matthew Bacon
'===============================================================================

DEFINT a-z

'>>Include files<<
REM $include F:\cadenza\webwizrd.31\webpage.wzd\webpage.bh
REM $include F:\enchant\modules\error.bas
REM $include F:\cadenza\webwizrd.31\toolbx_a.bas
REM $include F:\enchant\modules\bubble.bas
REM $include F:\enchant\modules\cursor.bas
REM $include F:\enchant\modules\file.bas
REM $include F:\enchant\modules\protocol.bas
REM $include F:\enchant\modules\st-guide.bas

'===============================================================================

DIM SHARED LANGUAGE$(300)

'>>Global variables<<
MyProgram$="WebPage.Wizard"
reset_dialog=-1
hook_enabled=0
hook_timeout=1000
HowManyButtons=2
loadwzd$=COMMAND$

'>>Import language file<<
CALL import_language
'>>Start<<
CALL StartProgram (CURDIR$+"\WEBPAGE.RSC",FORM_MENU,0,FORM_ICONIFY)

'>>Place strings into vairiables<<
CALL init_STRINGS
CALL init_BUBBLEHELP

'>>Place strings into rersource file<<
CALL init_INSTALL
CALL authorise_user
CALL init_COLOURS
CALL init_POPUPS
CALL init_MAIN
CALL init_MENUBAR : CALL init_Menu (FORM_MENU,-1)
CALL init_ABOUT
CALL initFORM_MAIN

junk=xdialog (FORM_ABOUT,0,0,1,0)
CALL UpdatePage (MAIN_GENERAL,MAIN_MGENERAL,0)
main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,MAIN_SAVE,VARPTRS(closeFORM_MAIN))

SelectTree FORM_MAIN
setobj_text TEX_HEADING,"FF0000"	'>>red<<
setobj_text TEX_BODYTEXT,"000000"	'>>black<<
setobj_text TEX_HYPER,"0000FF"		'>>blue<<
setobj_text TEX_LINK,"00FF00"		'>>green<<
setobj_text TEX_VISITED,"000000"	'>>black<<
setobj_text TEX_COLOUR3,"FFFFFF"	'>>white<<
IF loadwzd$<>"" THEN CALL OpenWizard (loadwzd$)

CALL xENCHANTloop
CALL StopProgram

'===============================================================================

FUNCTION HandleUserClose(BYVAL WindowHandle)
END FUNCTION

SUB HandleUserMessages
SHARED mess(),AreYouSure$
STATIC MessageType,button,message&,id,message$

MessageType=mess(0)
SELECT CASE MessageType
CASE 18193
	message&=VARPTR(mess(0))
	junk=Protocol_recieve (id,message&,message$)
	IF message$<>"" THEN
		button=form_alert(2,AreYouSure$)
		IF button=1 THEN CALL OpenWizard (message$)
	END IF
END SELECT
END SUB

SUB HandleUserHook
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB

SUB	HandleUserMenu (cur_front,item,title)
SHARED main_handle,AreYouSure$,current_wizard$,CopyComplete$
STATIC button

SelectTree FORM_MENU
SELECT CASE item
CASE MENU_ABOUT : junk=xdialog (FORM_ABOUT,0,0,1,0)
CASE MENU_NEW
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN
		CALL UpdatePage (MAIN_GENERAL,MAIN_MGENERAL,0)
		CALL initFORM_MAIN
		IF main_handle THEN CALL init_dialog(FORM_MAIN)
		main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,MAIN_SAVE,VARPTRS(closeFORM_MAIN))
		SelectTree FORM_MAIN
		Object_Redraw main_handle,GEN_INCLUDE
		Object_Redraw main_handle,GEN_LEVEL
		setobj_text TEX_HEADING,"FF0000"	'>>red<<
		setobj_text TEX_BODYTEXT,"000000"	'>>black<<
		setobj_text TEX_HYPER,"0000FF"		'>>blue<<
		setobj_text TEX_LINK,"00FF00"		'>>green<<
		setobj_text TEX_VISITED,"000000"	'>>black<<
		setobj_text TEX_COLOUR3,"FFFFFF"	'>>white<<
		remove_state MAIN_MCOLOURS,mask_disabled
		remove_state MAIN_MIMAGE,mask_disabled
		Object_Redraw main_handle,MAIN_MCOLOURS
		Object_Redraw main_handle,MAIN_MIMAGE
		current_wizard$=""
	END IF
CASE MENU_OPENWZD : CALL OpenWizard ("")
CASE MENU_SAVE : CALL SavePage (current_wizard$)
CASE MENU_SAVEAS : CALL SavePage ("") : junk=form_alert(1,CopyComplete$)
CASE MENU_QUIT
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN Finished_Flag=-1
	IF button=2 THEN Finished_Flag=0
CASE MENU_ABOUTHELP : junk=STGuide (CURDIR$+"\WEBPAGE.HYP","About Help...")
CASE MENU_HELP : junk=STGuide (CURDIR$+"\WEBPAGE.HYP","CONTENTS")
CASE MENU_CYBER : junk=STGuide (CURDIR$+"\WEBPAGE.HYP","CONTACT CYBERSTRIDER")
END SELECT
END SUB

SUB TextWindArrowed(BYVAL WindowHandle,BYVAL which)
END SUB

SUB TextWindLoop (BYVAL key_pressed)
END SUB

'===============================================================================

'>>Import language file<<
SUB import_language
STATIC myfile,dummy$,dummy

dummy=0
IF FEXISTS(CURDIR$+"\WEBPAGE.LNG") THEN
	myfile=FREEFILE
	OPEN CURDIR$+"\WEBPAGE.LNG" FOR INPUT AS #myfile
	DO
		LINE INPUT #myfile,dummy$
		IF dummy$<>"" THEN
			IF LEFT$(dummy$,1)<>";" THEN LANGUAGE$(dummy)=dummy$ : INCR dummy
			IF dummy=UBOUND(LANGUAGE$) THEN
				junk=form_alert(1,"[1][  "+MyProgram$+": |  Error in WEBPAGE.LNG ][Abort]")
				CALL StopProgram
			END IF
		END IF
	LOOP UNTIL EOF(myfile)
	CLOSE #myfile

'	myfile=FREEFILE
'	OPEN CURDIR$+"\LANGUAGE.ASC" FOR OUTPUT AS #myfile
'	FOR dummy=0 TO UBOUND(LANGUAGE$)
'		PRINT #myfile,FORMATI$(dummy,"###")+" "+LANGUAGE$(dummy)
'	NEXT dummy
'	CLOSE #myfile
ELSE
	junk=form_alert(1,"[1][  "+MyProgram$+": |  WEBPAGE.LNG not found! ][Abort]")
	CALL StopProgram
END IF
END SUB

'===============================================================================

FUNCTION CharPos (a$,b$)
STATIC i

FOR i=1 TO LEN(b$)
	IF a$=MID$(b$,i,1) THEN CharPos=i : EXIT FOR
NEXT i
END FUNCTION

'===============================================================================

FUNCTION ENIGMA$ (source$,rotor1$,rotor2$,rotor3$,currot,r1out$,r2out$,r3out$,currotout)
STATIC rot0$,rot1$,rot2$,rot3$,reflector$,i,char$,position,myfile
STATIC rot1pos,rot2pos,rot3pos,a$,CYPHERTEXT$,currot

CYPHERTEXT$=""
r1out$=""
r2out$=""
r3out$=""

rot0$="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
rot1$="RDEF904PQSMAOL3TN2IJH6B5WXCKVUG1YZ78"
rot2$="K780AFGM9VEQRU3BOPC6Z1WXTHSINJ5L2DY4"
rot3$="56H7PQYAWMZXGRFTUVKS4CDIB12ENLJ809O3"
reflector$="TZH9MX6C0OLKEVJQP3YA5N2FSB7WR8UG14DI"

rot1pos=1 : rot2pos=1 : rot3pos=1

FOR i=1 TO LEN(rot1$)
	IF rotor1$=MID$(rot1$,i,1) THEN EXIT FOR
	INCR rot1pos
NEXT i
rot1$=RIGHT$(rot1$,LEN(rot1$)-rot1pos+1)+LEFT$(rot1$,rot1pos)

FOR i=1 TO LEN(rot2$)
	IF rotor2$=MID$(rot2$,i,1) THEN EXIT FOR
	INCR rot2pos
NEXT i
rot2$=RIGHT$(rot2$,LEN(rot2$)-rot2pos+1)+LEFT$(rot2$,rot2pos)

FOR i=1 TO LEN(rot3$)
	IF rotor3$=MID$(rot3$,i,1) THEN EXIT FOR
	INCR rot3pos
NEXT i
rot3$=RIGHT$(rot3$,LEN(rot3$)-rot3pos+1)+LEFT$(rot3$,rot3pos)

FOR i=1 TO LEN(source$)
next_char:
	position=CharPos (MID$(source$,i,1),rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot1$,position,1)
	position=CharPos (char$,rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot2$,position,1)
	position=CharPos (char$,rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot3$,position,1)
	position=CharPos (char$,rot0$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(reflector$,position,1)
	position=CharPos (char$,rot3$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot0$,position,1)
	position=CharPos (char$,rot2$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot0$,position,1)
	position=CharPos (char$,rot1$)
	IF position=0 THEN INCR i : GOTO next_char
	char$=MID$(rot0$,position,1)
	CYPHERTEXT$=CYPHERTEXT$+char$

	SELECT CASE currot
		CASE 1
			IF rot1pos<>LEN(rot1$) THEN
				INCR rot1pos
				rot1$=RIGHT$(rot1$,LEN(rot1$)-1)+LEFT$(rot1$,1)
			ELSE
				rot1$=RIGHT$(rot1$,LEN(rot1$)-1)+LEFT$(rot1$,1)
				rot2$=RIGHT$(rot2$,LEN(rot2$)-1)+LEFT$(rot2$,1)
				rot1pos=1 : INCR rot2pos : currot=2
			END IF
		CASE 2
			IF rot2pos<>LEN(rot2$) THEN
				INCR rot2pos
				rot2$=RIGHT$(rot2$,LEN(rot2$)-1)+LEFT$(rot2$,1)
			ELSE
				rot2$=RIGHT$(rot2$,LEN(rot2$)-1)+LEFT$(rot2$,1)
				rot3$=RIGHT$(rot3$,LEN(rot3$)-1)+LEFT$(rot3$,1)
				rot2pos=1 : INCR rot3pos : currot=3
			END IF
		CASE 3
			IF rot3pos<>LEN(rot3$) THEN
				INCR rot3pos
				rot3$=RIGHT$(rot3$,LEN(rot3$)-1)+LEFT$(rot3$,1)
			ELSE
				rot3$=RIGHT$(rot3$,LEN(rot3$)-1)+LEFT$(rot3$,1)
				rot3pos=1 : currot=1
			END IF
	END SELECT
NEXT i
ENIGMA$=CYPHERTEXT$
r1out$=LEFT$(rot1$,1)
r2out$=LEFT$(rot2$,1)
r3out$=LEFT$(rot3$,1)
currotout=currot
END FUNCTION

'===============================================================================

FUNCTION authorise_keycode (BYVAL keycode$)
STATIC dummy$

IF LEN(keycode$)<>12 THEN authorise_keycode=0 : EXIT FUNCTION
dummy$=ENIGMA$ (RIGHT$(keycode$,6),MID$(keycode$,4,1),MID$(keycode$,5,1),MID$(keycode$,6,1),0,"","","",0)
IF dummy$=LEFT$(keycode$,6) THEN
	authorise_keycode=-1
ELSE
	authorise_keycode=0
END IF
END FUNCTION

'===============================================================================

SUB authorise_user
SHARED user$,keycode$,corruptINF$
STATIC dummy$,myfile

IF FEXISTS(CURDIR$+"\WEBWIZRD.INF") THEN
	myfile=FREEFILE
	OPEN CURDIR$+"\WEBWIZRD.INF" FOR INPUT AS #myfile
	LINE INPUT #myfile,dummy$
	IF dummy$<>"<Web.Wizard v3.10>" THEN junk=form_alert(1,corruptINF$) : CALL install_user
	LINE INPUT #myfile,dummy$
	user$=RIGHT$(dummy$,LEN(dummy$)-6)
	IF LEFT$(dummy$,6)<>"<User>" THEN junk=form_alert(1,corruptINF$) : CALL install_user
	LINE INPUT #myfile,dummy$
	keycode$=RIGHT$(dummy$,LEN(dummy$)-10)
	IF LEFT$(dummy$,10)<>"<Key Code>" THEN junk=form_alert(1,corruptINF$) : CALL install_user
	CLOSE #myfile
ELSE
	CALL install_user
END IF
IF authorise_keycode(keycode$)=0 THEN junk=form_alert(1,corruptINF$) : CALL StopProgram
END SUB

'===============================================================================

SUB install_user
SHARED user$,keycode$,noINF$,corruptINF$
STATIC myfile

junk=form_alert(1,noINF$)
junk=xdialog (FORM_INSTALL,INSTALL_NAME,0,1,0)
SelectTree FORM_INSTALL
user$=getobj_text$(INSTALL_NAME)
keycode$=getobj_text$(INSTALL_KEYCODE)

IF authorise_keycode(keycode$)<>0 THEN
	myfile=FREEFILE
	OPEN CURDIR$+"\WEBWIZRD.INF" FOR OUTPUT AS #myfile
	PRINT #1,"<Web.Wizard v3.10>"
		PRINT #1,"<User>"+user$
	PRINT #1,"<Key Code>"+keycode$
	CLOSE #myfile
ELSE
	junk=form_alert(1,corruptINF$) : CALL StopProgram
END IF
END SUB

'===============================================================================

SUB init_ABOUT
SHARED user$,keycode$

SelectTree FORM_ABOUT
setobj_text ABOUT_TEXT1,LANGUAGE$(99)		'>>Author<<
setobj_text ABOUT_TEXT2,LANGUAGE$(100)		'>>Distribution<<
setobj_text ABOUT_TEXT3,LANGUAGE$(101)		'>>Language<<
setobj_text ABOUT_LANGUAGE,LANGUAGE$(0)
setobj_text ABOUT_TEXT4,LANGUAGE$(102)		'>>Translation<<
setobj_text ABOUT_TRANSLATOR,LANGUAGE$(1)	'>>Translator<<
setobj_text ABOUT_TEXT5,LANGUAGE$(103)		'>>Key Code<<
setobj_text ABOUT_KEYCODE,keycode$
setobj_text ABOUT_TEXT6,LANGUAGE$(104)		'>>Registered to<<
setobj_text ABOUT_USER,user$
setobj_spec_str ABOUT_OK,LANGUAGE$(105)		'>>OK<<
END SUB

'===============================================================================

SUB init_MENUBAR
STATIC cellx,dummy

junk=graf_handle(cellx,junk,junk,junk)
SelectTree FORM_MENU
setobj_spec_str MENU_PROGRAM," "+LANGUAGE$(2)		'>>WebPage.Wizard<<
setobj_spec_str MENU_ABOUT,"  "+LANGUAGE$(3)		'>>Information...<<
setobj_spec_str MENU_FILE," "+LANGUAGE$(4)			'>>File<<
setobj_spec_str MENU_NEW,"  "+LANGUAGE$(5)			'>>New ^N<<
setobj_spec_str MENU_OPENWZD,"  "+LANGUAGE$(6)		'>>Open *.WZD ^O<<
setobj_spec_str MENU_OPENHPP,"  "+LANGUAGE$(7)		'>>Open *.HPP<<
setobj_spec_str MENU_SAVE,"  "+LANGUAGE$(8)			'>>Save ^S<<
setobj_spec_str MENU_SAVEAS,"  "+LANGUAGE$(9)		'>>Save As..<<
setobj_spec_str MENU_QUIT,"  "+LANGUAGE$(10)		'>>Quit ^Q<<
setobj_spec_str MENU_THELP," "+LANGUAGE$(11)		'>>Help<<
setobj_spec_str MENU_ABOUTHELP,"  "+LANGUAGE$(12)	'>>About Help...<<
setobj_spec_str MENU_HELP,"  "+LANGUAGE$(13)		'>>Help  [HELP]<<
setobj_spec_str MENU_CYBER,"  "+LANGUAGE$(14)		'>>CyberSTrider<<

setobj_width MENU_PROGRAM,cellx*(LEN(getobj_spec$(MENU_PROGRAM))+1)
dummy=getobj_x(MENU_PROGRAM)+getobj_width(MENU_PROGRAM)
setobj_x MENU_FILE,dummy
setobj_width MENU_FILE,cellx*(LEN(getobj_spec$(MENU_FILE))+1)
setobj_x MENU_NEW-1,dummy+(2*cellx)
setobj_width MENU_NEW-1,cellx*(LEN(getobj_spec$(MENU_NEW))+1)
FOR dummy=MENU_NEW TO MENU_QUIT
	setobj_width dummy,cellx*(LEN(getobj_spec$(MENU_NEW))+1)
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_NEW))+1)
NEXT dummy

dummy=getobj_x(MENU_FILE)+getobj_width(MENU_FILE)
setobj_x MENU_THELP,dummy
setobj_width MENU_THELP,cellx*(LEN(getobj_spec$(MENU_THELP))+1)
setobj_x MENU_ABOUTHELP-1,dummy+(2*cellx)
setobj_width MENU_ABOUTHELP-1,cellx*(LEN(getobj_spec$(MENU_HELP))+1)
FOR dummy=MENU_ABOUTHELP TO MENU_CYBER
	setobj_width dummy,cellx*(LEN(getobj_spec$(MENU_HELP))+1)
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_HELP))+1)
NEXT dummy

dummy=getobj_x(MENU_THELP)+getobj_width(MENU_THELP)
setobj_width MENU_PROGRAM-1,dummy
END SUB

'===============================================================================

SUB init_MAIN
SelectTree FORM_MAIN
setobj_text MAIN_MGENERAL,LANGUAGE$(15)		'>>General<<
setobj_text MAIN_MTITLE,LANGUAGE$(16)		'>>Title<<
setobj_text MAIN_MCOLOURS,LANGUAGE$(17)		'>>Colours<<
setobj_text MAIN_MHEADINGS,LANGUAGE$(18)	'>>Headings<<
setobj_text MAIN_MTEXT,LANGUAGE$(19)		'>>Text<<
setobj_text MAIN_MIMAGE,LANGUAGE$(20)		'>>Image<<
setobj_text MAIN_MLINKS,LANGUAGE$(21)		'>>Links<<
setobj_text MAIN_MAUTHOR,LANGUAGE$(22)		'>>Author<<

setobj_spec_str MAIN_HELP,LANGUAGE$(23)		'>>Help<<
setobj_spec_str MAIN_SAVE,LANGUAGE$(24)		'>>Save<<
setobj_spec_str MAIN_BACK,LANGUAGE$(25)		'>>Back<<
setobj_spec_str MAIN_NEXT,LANGUAGE$(26)		'>>Next<<

setobj_text GEN_PAGE,LANGUAGE$(27)			'>>Page 1 of 8<<
setobj_spec_str GEN_TEXT1,LANGUAGE$(35)
setobj_spec_str GEN_TEXT2,LANGUAGE$(36)
setobj_spec_str GEN_TEXT3,LANGUAGE$(37)
setobj_spec_str GEN_TEXT4,LANGUAGE$(38)
setobj_spec_str GEN_INCLUDE2," "+LANGUAGE$(39)
setobj_spec_str GEN_TEXT5,LANGUAGE$(40)		'>>Level<<

setobj_text TIT_PAGE,LANGUAGE$(28)			'>>Page 2 of 8<<
setobj_spec_str TIT_TEXT1,LANGUAGE$(41)
setobj_spec_str TIT_TEXT2,LANGUAGE$(42)
setobj_spec_str TIT_TEXT3,LANGUAGE$(43)
setobj_spec_str TIT_TEXT4,LANGUAGE$(44)		'>>Title<<
setobj_spec_str TIT_TEXT5,LANGUAGE$(45)
setobj_spec_str TIT_TEXT6,LANGUAGE$(46)
setobj_spec_str TIT_TEXT7,LANGUAGE$(47)		'>>Keywords<<
setobj_text TIT_TEXT8,LANGUAGE$(48)			'<<Background audio/MIDI<<
setobj_spec_str TIT_TEXT9,LANGUAGE$(49)		'>>Loop<<
setobj_spec_str TIT_TEXT10,LANGUAGE$(50)	'>>Delay<<

setobj_text TEX_PAGE,LANGUAGE$(29)				'>>Page 3 of 8<<
setobj_spec_str TEX_TEXT1,LANGUAGE$(51)
setobj_spec_str TEX_TEXT2,LANGUAGE$(52)
setobj_spec_str TEX_TEXT3,LANGUAGE$(53)			'>>Heading<<
setobj_spec_str TEX_TEXT4,LANGUAGE$(54)			'>>Text<<
setobj_spec_str TEX_TEXT5,LANGUAGE$(55)			'>>Hypertext link<<
setobj_spec_str TEX_TEXT6,LANGUAGE$(56)			'>>Link(s)<<
setobj_spec_str TEX_TEXT7,LANGUAGE$(57)			'>>Visited Link(s)<<
setobj_text TEX_TEXT8,LANGUAGE$(58)				'>>Background<<
setobj_spec_str TEX_IMAGE2," "+LANGUAGE$(59)	'>>Image<<
setobj_spec_str TEX_COLOUR2," "+LANGUAGE$(60)	'>>Colour<<

setobj_text HEAD_PAGE,LANGUAGE$(30)				'>>Page 4 of 8<<
setobj_text HEAD_TEXT1,LANGUAGE$(61)			'>>Heading<<
setobj_spec_str HEAD_TEXT2,LANGUAGE$(62)		'>>Size<<
setobj_spec_str HEAD_RULE2," "+LANGUAGE$(63)	'>>Horizontal bar<<
setobj_text HEAD_TEXT3,LANGUAGE$(64)			'>>Sub-Heading<<
setobj_spec_str HEAD_TEXT4,LANGUAGE$(62)		'>>Size<<
setobj_spec_str HEAD_SRULE2," "+LANGUAGE$(65)	'>>Horizontal bar<<

setobj_text BODY_PAGE,LANGUAGE$(31)			'>>Page 5 of 8<<
setobj_text BODY_TEXT1,LANGUAGE$(66)
setobj_spec_str BODY_TEXT2,LANGUAGE$(67)	'>>Column(s)<<
setobj_spec_str BODY_RETURN2," "+LANGUAGE$(68)
setobj_spec_str BODY_PARAGRAPH2," "+LANGUAGE$(69)
setobj_spec_str BODY_TEXT3,LANGUAGE$(70)
setobj_spec_str BODY_TEXT4,LANGUAGE$(71)
setobj_spec_str BODY_TEXT5,LANGUAGE$(72)	'>>Font<<

setobj_text IMG_PAGE,LANGUAGE$(32)			'>>Page 6 of 8<<
setobj_text IMG_TEXT1,LANGUAGE$(73)
setobj_spec_str IMG_TEXT2,LANGUAGE$(74)
setobj_spec_str IMG_TEXT3,LANGUAGE$(75)		'>>Width<<
setobj_spec_str IMG_TEXT4,LANGUAGE$(76)		'>>Height<<
setobj_spec_str IMG_TEXT5,LANGUAGE$(77)		'>>Border<<
setobj_text IMG_TEXT6,LANGUAGE$(78)
setobj_spec_str IMG_ABOVE2," "+LANGUAGE$(79)
setobj_spec_str IMG_BETWEEN2," "+LANGUAGE$(80)
setobj_spec_str IMG_BELOW2," "+LANGUAGE$(81)
setobj_spec_str IMG_LEFT2," "+LANGUAGE$(82)
setobj_spec_str IMG_CENTRE2," "+LANGUAGE$(83)
setobj_spec_str IMG_RIGHT2," "+LANGUAGE$(84)

setobj_text LNK_PAGE,LANGUAGE$(33)			'>>Page 7 of 8<<
setobj_spec_str LNK_TEXT1,LANGUAGE$(85)
setobj_spec_str LNK_TEXT2,LANGUAGE$(86)
setobj_text LNK_TEXT3,LANGUAGE$(87)
setobj_spec_str LNK_TEXT4,LANGUAGE$(88)
setobj_text LNK_TEXT5,LANGUAGE$(87)
setobj_spec_str LNK_TEXT6,LANGUAGE$(88)
setobj_text LNK_TEXT7,LANGUAGE$(87)
setobj_spec_str LNK_TEXT8,LANGUAGE$(88)

setobj_text AUT_PAGE,LANGUAGE$(34)			'>>Page 8 of 8<<
setobj_spec_str AUT_TEXT1,LANGUAGE$(89)
setobj_spec_str AUT_TEXT2,LANGUAGE$(90)
setobj_spec_str AUT_TEXT3,LANGUAGE$(91)
setobj_spec_str AUT_TEXT4,LANGUAGE$(92)
setobj_spec_str AUT_TEXT5,LANGUAGE$(93)
setobj_spec_str AUT_TEXT6,LANGUAGE$(94)		'>>Name<<
setobj_spec_str AUT_TEXT7,LANGUAGE$(95)		'>>Email<<
setobj_spec_str AUT_TEXT8,LANGUAGE$(96)		'>>Date<<
setobj_text AUT_TEXT9,LANGUAGE$(97)			'>>Please save<<
setobj_spec_str AUT_SAVE,LANGUAGE$(98)		'>>Save<<
END SUB

'===============================================================================

SUB init_POPUPS
SelectTree FORM_POPUPS
setobj_spec_str P_LEVEL1,"  "+LANGUAGE$(106)	'>>Novice<<
setobj_spec_str P_LEVEL2,"  "+LANGUAGE$(107)	'>>Amateur<<
setobj_spec_str P_LEVEL3,"  "+LANGUAGE$(108)	'>>Expert<<

setobj_spec_str P_COL1," "+LANGUAGE$(109)		'>>White<<
setobj_spec_str P_COL2," "+LANGUAGE$(110)		'>>Black<<
setobj_spec_str P_COL3," "+LANGUAGE$(111)		'>>Red<<
setobj_spec_str P_COL4," "+LANGUAGE$(112)		'>>Green<<
setobj_spec_str P_COL5," "+LANGUAGE$(113)		'>>Blue<<
setobj_spec_str P_COL6," "+LANGUAGE$(114)		'>>Cyan<<
setobj_spec_str P_COL7," "+LANGUAGE$(115)		'>>Yellow<<
setobj_spec_str P_COL8," "+LANGUAGE$(116)		'>>Magenta<<
setobj_spec_str P_COL9," "+LANGUAGE$(117)		'>>Light grey<<
setobj_spec_str P_COL10," "+LANGUAGE$(118)		'>>Dark grey<<
setobj_spec_str P_COL11," "+LANGUAGE$(119)		'>>Dark red<<
setobj_spec_str P_COL12," "+LANGUAGE$(120)		'>>Dark green<<
setobj_spec_str P_COL13," "+LANGUAGE$(121)		'>>Dark blue<<
setobj_spec_str P_COL14," "+LANGUAGE$(122)		'>>Dark cyan<<
setobj_spec_str P_COL15," "+LANGUAGE$(123)		'>>Dark yellow<<
setobj_spec_str P_COL16," "+LANGUAGE$(124)		'>>Dark magenta<<
setobj_spec_str P_COLOTHER,"  "+LANGUAGE$(125)	'>>Other<<

setobj_spec_str P_SIZE1,"  "+LANGUAGE$(126)		'>>Huge<<
setobj_spec_str P_SIZE2,"  "+LANGUAGE$(127)		'>>Quite large<<
setobj_spec_str P_SIZE3,"  "+LANGUAGE$(128)		'>>Large<<
setobj_spec_str P_SIZE4,"  "+LANGUAGE$(129)		'>>Normal<<
setobj_spec_str P_SIZE5,"  "+LANGUAGE$(130)		'>>Small<<
setobj_spec_str P_SIZE6,"  "+LANGUAGE$(131)		'>>Very Small<<
END SUB

'===============================================================================

SUB init_COLOURS
SelectTree FORM_COLOURS
setobj_text RGB_RED,LANGUAGE$(132)			'>>Red<<
setobj_text RGB_GREEN,LANGUAGE$(133)		'>>Green<<
setobj_text RGB_BLUE,LANGUAGE$(134)			'>>Blue<<
setobj_spec_str COL_OK,LANGUAGE$(135)		'>>OK<<
setobj_spec_str COL_CANCEL,LANGUAGE$(136)	'>>Cancel<<
END SUB

'===============================================================================

SUB init_INSTALL
SelectTree FORM_INSTALL
setobj_spec_str INSTALL_WW,LANGUAGE$(137)	'>>Install WebPage.Wizard<<
setobj_text INSTALL_USER,LANGUAGE$(138)		'>>User<<
setobj_text INSTALL_KEY,LANGUAGE$(139)		'>>Key Code<<
setobj_spec_str INSTALL_OK,LANGUAGE$(140)	'>>OK<<
END SUB

'===============================================================================

SUB init_STRINGS
SHARED ChooseFile$,AreYouSure$,SaveAs$,CopyComplete$,noINF$,corruptINF$
SHARED NotComplete$,KeyIncorrect$

ChooseFile$=LANGUAGE$(141)
SaveAs$=LANGUAGE$(142)
AreYouSure$=LANGUAGE$(143)
CopyComplete$=LANGUAGE$(144)
noINF$=LANGUAGE$(145)
corruptINF$=LANGUAGE$(146)
NotComplete$=LANGUAGE$(147)
KeyIncorrect$=LANGUAGE$(148)
END SUB

'===============================================================================

SUB init_BUBBLEHELP
SHARED BUB_STGUIDE$,BUB_SAVE$,BUB_BACK$,BUB_NEXT$,BUB_COMMENT$,BUB_LEVEL$
SHARED BUB_MUSIC$,BUB_LOOP$,BUB_DELAY$,BUB_COLOUR$,BUB_HEX$,BUB_IMGORCOLOR$
SHARED BUB_SIZE$,BUB_BUI$,BUB_JUST$,BUB_BAR$,BUB_TEXTFILE$,BUB_RETURN$
SHARED BUB_PARAGRAPH$,BUB_LINK$,BUB_LINKTEXT$,BUB_IMGFILE$,BUB_ALTTEXT$
SHARED BUB_WIDTH$,BUB_BORDER$,BUB_IMGLINK$,BUB_IMGPOSITION$,BUB_BACKIMG$

BUB_STGUIDE$=LANGUAGE$(149)
BUB_SAVE$=LANGUAGE$(150)
BUB_BACK$=LANGUAGE$(151)
BUB_NEXT$=LANGUAGE$(152)
BUB_COMMENT$=LANGUAGE$(153)
BUB_LEVEL$=LANGUAGE$(154)
BUB_MUSIC$=LANGUAGE$(155)
BUB_LOOP$=LANGUAGE$(156)
BUB_DELAY$=LANGUAGE$(157)
BUB_COLOUR$=LANGUAGE$(158)
BUB_HEX$=LANGUAGE$(159)
BUB_IMGORCOLOR$=LANGUAGE$(160)
BUB_SIZE$=LANGUAGE$(161)
BUB_BUI$=LANGUAGE$(162)
BUB_JUST$=LANGUAGE$(163)
BUB_BAR$=LANGUAGE$(164)
BUB_TEXTFILE$=LANGUAGE$(165)
BUB_RETURN$=LANGUAGE$(166)
BUB_PARAGRAPH$=LANGUAGE$(167)
BUB_LINK$=LANGUAGE$(168)
BUB_LINKTEXT$=LANGUAGE$(169)
BUB_IMGFILE$=LANGUAGE$(170)
BUB_ALTTEXT$=LANGUAGE$(171)
BUB_WIDTH$=LANGUAGE$(172)
BUB_BORDER$=LANGUAGE$(173)
BUB_IMGLINK$=LANGUAGE$(174)
BUB_IMGPOSITION$=LANGUAGE$(175)
BUB_BACKIMG$=LANGUAGE$(176)
END SUB

'===============================================================================

SUB initFORM_MAIN
SHARED main_handle,popup_level,popup_hsize,popup_shsize

SelectTree FORM_MAIN
CALL update_mouse
setobj_shortcut GEN_INCLUDE,CHR$(14)
setobj_poptext GEN_LEVEL,"  "+getobj_poptext$(FORM_POPUPS,POP_LEVEL+3)
popup_level=POP_LEVEL+3

CALL update_mouse
setobj_text TIT_MUSIC,""

CALL update_mouse
setobj_shortcut TEX_IMAGE,CHR$(11)
setobj_text TEX_IMAGE3,""
setobj_shortcut TEX_COLOUR,CHR$(12)
setobj_text TEX_HEADING,"FF0000"
setobj_text TEX_BODYTEXT,"000000"
setobj_text TEX_HYPER,"0000FF"
setobj_text TEX_LINK,"00FF00"
setobj_text TEX_VISITED,"000000"
setobj_text TEX_COLOUR3,"FFFFFF"
setobj_poptext TEX_HEADING2,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+6)
setobj_poptext TEX_BODYTEXT2,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+4)
setobj_poptext TEX_HYPER2,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+10)
setobj_poptext TEX_LINK2,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+8)
setobj_poptext TEX_VISITED2,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+4)
setobj_poptext TEX_COLOUR4,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+2)

CALL update_mouse
setobj_poptext HEAD_SIZE,"  "+getobj_poptext$(FORM_POPUPS,POP_FONT+1)
popup_hsize=POP_FONT+1
remove_state HEAD_BOLD,mask_selected
remove_state HEAD_UNDERLINED,mask_selected
remove_state HEAD_ITALIC,mask_selected
include_state HEAD_LEFT,mask_selected
remove_state HEAD_CENTRE,mask_selected
remove_state HEAD_RIGHT,mask_selected
setobj_shortcut HEAD_RULE,CHR$(13)
setobj_poptext HEAD_SSIZE,"  "+getobj_poptext$(FORM_POPUPS,POP_FONT+3)
popup_shsize=POP_FONT+3
remove_state HEAD_SBOLD,mask_selected
remove_state HEAD_SUNDERLINED,mask_selected
remove_state HEAD_SITALIC,mask_selected
include_state HEAD_SLEFT,mask_selected
remove_state HEAD_SCENTRE,mask_selected
remove_state HEAD_SRIGHT,mask_selected
setobj_shortcut HEAD_SRULE,CHR$(14)

CALL update_mouse
setobj_text BODY_TEXTFILE,""
remove_state BODY_BOLD,mask_selected
remove_state BODY_UNDERLINED,mask_selected
remove_state BODY_ITALIC,mask_selected
include_state BODY_LEFT,mask_selected
remove_state BODY_CENTRE,mask_selected
remove_state BODY_RIGHT,mask_selected
setobj_shortcut BODY_COLUMN1,CHR$(12)
setobj_shortcut BODY_COLUMN2,CHR$(11)
setobj_shortcut BODY_RETURN,CHR$(14)
setobj_shortcut BODY_PARAGRAPH,CHR$(14)

CALL update_mouse
setobj_text LNK_LINK1,""
setobj_text LNK_LNKTEXT1,""
setobj_text LNK_LINK2,""
setobj_text LNK_LNKTEXT2,""
setobj_text LNK_LINK3,""
setobj_text LNK_LNKTEXT3,""

CALL update_mouse
setobj_text IMG_FILE,""
setobj_text IMG_LINK,""
setobj_shortcut IMG_ABOVE,CHR$(12)
setobj_shortcut IMG_BETWEEN,CHR$(11)
setobj_shortcut IMG_BELOW,CHR$(11)
setobj_shortcut IMG_LEFT,CHR$(11)
setobj_shortcut IMG_CENTRE,CHR$(12)
setobj_shortcut IMG_RIGHT,CHR$(11)
MOUSE 0
END SUB

'===============================================================================

SUB closeFORM_MAIN
SHARED fspath$,fsmessage$,main_handle,ChooseFile$,ChangeRGB,ChangeRGB$
SHARED popup_level,popup_heading,popup_text,popup_hyper,popup_link
SHARED popup_visited,popup_colour,popup_hsize,popup_shsize,TIT_MUSIC$,TEX_IMAGE$
SHARED BTEXT_FILE$,IMG_FILE$,IMGLNK_FILE$,LNK_FILE1$,LNK_FILE2$,LNK_FILE3$

SHARED BUB_STGUIDE$,BUB_SAVE$,BUB_BACK$,BUB_NEXT$,BUB_COMMENT$,BUB_LEVEL$
SHARED BUB_MUSIC$,BUB_LOOP$,BUB_DELAY$,BUB_COLOUR$,BUB_HEX$,BUB_IMGORCOLOR$
SHARED BUB_SIZE$,BUB_BUI$,BUB_JUST$,BUB_BAR$,BUB_TEXTFILE$,BUB_RETURN$
SHARED BUB_PARAGRAPH$,BUB_LINK$,BUB_LINKTEXT$,BUB_IMGFILE$,BUB_ALTTEXT$
SHARED BUB_WIDTH$,BUB_BORDER$,BUB_IMGLINK$,BUB_IMGPOSITION$,BUB_BACKIMG$

STATIC dummy,dummy$,char,myfile,fsname$

SelectTree FORM_MAIN
IF CommonButton=2 THEN
SELECT CASE CommonObj
CASE MAIN_HELP : junk=BubbleGEM (BUB_STGUIDE$)
CASE MAIN_SAVE,AUT_SAVE : junk=BubbleGEM (BUB_SAVE$)
CASE MAIN_BACK : junk=BubbleGEM (BUB_BACK$)
CASE MAIN_NEXT : junk=BubbleGEM (BUB_NEXT$)

CASE GEN_INCLUDE,GEN_INCLUDE2  : junk=BubbleGEM (BUB_COMMENT$)
CASE GEN_LEVEL,GEN_LEVEL2  : junk=BubbleGEM (BUB_LEVEL$)

CASE TIT_MUSIC : junk=BubbleGEM (BUB_MUSIC$)
CASE TIT_LOOP : junk=BubbleGEM (BUB_LOOP$)
CASE TIT_DELAY : junk=BubbleGEM (BUB_DELAY$)

CASE TEX_HEADING2,TEX_BODYTEXT2,TEX_HYPER2,TEX_LINK2,TEX_VISITED2,TEX_COLOUR4 : junk=BubbleGEM (BUB_COLOUR$)
CASE TEX_HEADING,TEX_BODYTEXT,TEX_HYPER,TEX_LINK,TEX_VISITED,TEX_COLOUR3 : junk=BubbleGEM (BUB_HEX$)
CASE TEX_IMAGE,TEX_IMAGE2,TEX_COLOUR,TEX_COLOUR2 : junk=BubbleGEM (BUB_IMGORCOLOR$)
CASE TEX_IMAGE3 : junk=BubbleGEM (BUB_BACKIMG$)

CASE HEAD_SIZE,HEAD_SIZE2 : junk=BubbleGEM (BUB_SIZE$)
CASE HEAD_BOLD,HEAD_UNDERLINED,HEAD_ITALIC : junk=BubbleGEM (BUB_BUI$)
CASE HEAD_LEFT,HEAD_CENTRE,HEAD_RIGHT : junk=BubbleGEM (BUB_JUST$)
CASE HEAD_RULE,HEAD_RULE2 : junk=BubbleGEM (BUB_BAR$)
CASE HEAD_SSIZE,HEAD_SSIZE2 : junk=BubbleGEM (BUB_SIZE$)
CASE HEAD_SBOLD,HEAD_SUNDERLINED,HEAD_SITALIC : junk=BubbleGEM (BUB_BUI$)
CASE HEAD_SLEFT,HEAD_SCENTRE,HEAD_SRIGHT : junk=BubbleGEM (BUB_JUST$)
CASE HEAD_SRULE,HEAD_SRULE2 : junk=BubbleGEM (BUB_BAR$)

CASE BODY_TEXTFILE : junk=BubbleGEM (BUB_TEXTFILE$)
CASE BODY_BOLD,BODY_UNDERLINED,BODY_ITALIC : junk=BubbleGEM (BUB_BUI$)
CASE BODY_LEFT,BODY_CENTRE,BODY_RIGHT : junk=BubbleGEM (BUB_JUST$)
CASE BODY_RETURN,BODY_RETURN2 : junk=BubbleGEM (BUB_RETURN$)
CASE BODY_PARAGRAPH,BODY_PARAGRAPH2 : junk=BubbleGEM (BUB_PARAGRAPH$)

CASE LNK_LINK1,LNK_LINK2,LNK_LINK3 : junk=BubbleGEM (BUB_LINK$)
CASE LNK_LNKTEXT1,LNK_LNKTEXT2,LNK_LNKTEXT3 : junk=BubbleGEM (BUB_LINKTEXT$)

CASE IMG_FILE : junk=BubbleGEM (BUB_IMGFILE$)
CASE IMG_ALTTEXT : junk=BubbleGEM (BUB_ALTTEXT$)
CASE IMG_WIDTH,IMG_HEIGHT : junk=BubbleGEM (BUB_WIDTH$)
CASE IMG_BORDER : junk=BubbleGEM (BUB_BORDER$)
CASE IMG_LINK : junk=BubbleGEM (BUB_IMGLINK$)
CASE IMG_ABOVE TO IMG_BELOW2 : junk=BubbleGEM (BUB_IMGPOSITION$)
END SELECT
ELSE
SELECT CASE CommonObj
CASE MAIN_HELP
	IF enquire_state(MAIN_MGENERAL,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","General")
	IF enquire_state(MAIN_MTITLE,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Title and Keywords")
	IF enquire_state(MAIN_MCOLOURS,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Colours")
	IF enquire_state(MAIN_MHEADINGS,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Headings")
	IF enquire_state(MAIN_MTEXT,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Body Text")
	IF enquire_state(MAIN_MIMAGE,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Image")
	IF enquire_state(MAIN_MLINKS,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Links")
	IF enquire_state(MAIN_MAUTHOR,mask_selected) THEN junk=STGuide (CURDIR$+"\WEBPAGE.HYP","Author")
CASE MAIN_MGENERAL : CALL UpdatePage (MAIN_GENERAL,MAIN_MGENERAL,0)
CASE MAIN_MTITLE : CALL UpdatePage (MAIN_TITLE,MAIN_MTITLE,TIT_TITLE)
CASE MAIN_MCOLOURS : CALL UpdatePage (MAIN_COLOURS,MAIN_MCOLOURS,TEX_HEADING)
CASE MAIN_MHEADINGS : CALL UpdatePage (MAIN_HEADINGS,MAIN_MHEADINGS,HEAD_HEADING)
CASE MAIN_MTEXT : CALL UpdatePage (MAIN_TEXT,MAIN_MTEXT,BODY_FONTFAMILY)
CASE MAIN_MIMAGE : CALL UpdatePage (MAIN_IMAGE,MAIN_MIMAGE,IMG_ALTTEXT)
CASE MAIN_MLINKS : CALL UpdatePage (MAIN_LINKS,MAIN_MLINKS,LNK_LNKTEXT1)
CASE MAIN_MAUTHOR : CALL UpdatePage (MAIN_AUTHOR,MAIN_MAUTHOR,AUT_NAME)
CASE MAIN_SAVE : CALL SavePage ("")
CASE MAIN_BACK
	FOR dummy=MAIN_MGENERAL TO MAIN_MAUTHOR
		IF enquire_state(dummy,mask_selected) THEN
			SELECT CASE dummy
			CASE MAIN_MTITLE : CALL UpdatePage (MAIN_GENERAL,MAIN_MGENERAL,0)
			CASE MAIN_MCOLOURS : CALL UpdatePage (MAIN_TITLE,MAIN_MTITLE,TIT_TITLE)
			CASE MAIN_MHEADINGS
				IF NOT enquire_state(MAIN_MCOLOURS,mask_disabled) THEN
					CALL UpdatePage (MAIN_COLOURS,MAIN_MCOLOURS,TEX_HEADING)
				ELSE
					CALL UpdatePage (MAIN_TITLE,MAIN_MTITLE,TIT_TITLE)
				END IF
			CASE MAIN_MTEXT : CALL UpdatePage (MAIN_HEADINGS,MAIN_MHEADINGS,HEAD_HEADING)
			CASE MAIN_MIMAGE : CALL UpdatePage (MAIN_TEXT,MAIN_MTEXT,BODY_FONTFAMILY)
			CASE MAIN_MLINKS
				IF NOT enquire_state(MAIN_MIMAGE,mask_disabled) THEN
					CALL UpdatePage (MAIN_IMAGE,MAIN_MIMAGE,IMG_ALTTEXT)
				ELSE
					CALL UpdatePage (MAIN_TEXT,MAIN_MTEXT,BODY_FONTFAMILY)
				END IF
			CASE MAIN_MAUTHOR : CALL UpdatePage (MAIN_LINKS,MAIN_MLINKS,LNK_LNKTEXT1)
			END SELECT
			EXIT FOR
		END IF
	NEXT
CASE MAIN_NEXT
	FOR dummy=MAIN_MGENERAL TO MAIN_MAUTHOR
		IF enquire_state(dummy,mask_selected) THEN
			SELECT CASE dummy
			CASE MAIN_MGENERAL : CALL UpdatePage (MAIN_TITLE,MAIN_MTITLE,TIT_TITLE)
			CASE MAIN_MTITLE
				IF NOT enquire_state(MAIN_MCOLOURS,mask_disabled) THEN
					CALL UpdatePage (MAIN_COLOURS,MAIN_MCOLOURS,TEX_HEADING)
				ELSE
					CALL UpdatePage (MAIN_HEADINGS,MAIN_MHEADINGS,HEAD_HEADING)
				END IF
			CASE MAIN_MCOLOURS : CALL UpdatePage (MAIN_HEADINGS,MAIN_MHEADINGS,HEAD_HEADING)
			CASE MAIN_MHEADINGS : CALL UpdatePage (MAIN_TEXT,MAIN_MTEXT,BODY_FONTFAMILY)
			CASE MAIN_MTEXT
				IF NOT enquire_state(MAIN_MIMAGE,mask_disabled) THEN
					CALL UpdatePage (MAIN_IMAGE,MAIN_MIMAGE,IMG_ALTTEXT)
				ELSE
					CALL UpdatePage (MAIN_LINKS,MAIN_MLINKS,LNK_LNKTEXT1)
				END IF
			CASE MAIN_MIMAGE : CALL UpdatePage (MAIN_LINKS,MAIN_MLINKS,LNK_LNKTEXT1)
			CASE MAIN_MLINKS : CALL UpdatePage (MAIN_AUTHOR,MAIN_MAUTHOR,AUT_NAME)
			END SELECT
			EXIT FOR
		END IF
	NEXT
CASE GEN_LEVEL
	popup_level=popup(main_handle,GEN_LEVEL,FORM_POPUPS,POP_LEVEL,popup_level)
	IF popup_level THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_level)
		setobj_poptext GEN_LEVEL,"  "+dummy$
		SELECT CASE dummy$
		CASE LANGUAGE$(106)
			include_state MAIN_MCOLOURS,mask_disabled
			include_state MAIN_MIMAGE,mask_disabled
			Object_Redraw main_handle,MAIN_MCOLOURS
			Object_Redraw main_handle,MAIN_MIMAGE
		CASE LANGUAGE$(107)
			remove_state MAIN_MCOLOURS,mask_disabled
			include_state MAIN_MIMAGE,mask_disabled
			Object_Redraw main_handle,MAIN_MCOLOURS
			Object_Redraw main_handle,MAIN_MIMAGE
		CASE LANGUAGE$(108)
			remove_state MAIN_MCOLOURS,mask_disabled
			remove_state MAIN_MIMAGE,mask_disabled
			Object_Redraw main_handle,MAIN_MCOLOURS
			Object_Redraw main_handle,MAIN_MIMAGE
		END SELECT
		Object_Redraw main_handle,GEN_LEVEL
	END IF
CASE GEN_LEVEL2
	radio_poptext GEN_LEVEL,FORM_POPUPS,POP_LEVEL,popup_level
	dummy$=LTRIM$(getobj_text$(GEN_LEVEL))
	setobj_poptext GEN_LEVEL,"  "+dummy$
	SELECT CASE dummy$
	CASE LANGUAGE$(106)
		include_state MAIN_MCOLOURS,mask_disabled
		include_state MAIN_MIMAGE,mask_disabled
		Object_Redraw main_handle,MAIN_MCOLOURS
		Object_Redraw main_handle,MAIN_MIMAGE
	CASE LANGUAGE$(107)
		remove_state MAIN_MCOLOURS,mask_disabled
		include_state MAIN_MIMAGE,mask_disabled
		Object_Redraw main_handle,MAIN_MCOLOURS
		Object_Redraw main_handle,MAIN_MIMAGE
	CASE LANGUAGE$(108)
		remove_state MAIN_MCOLOURS,mask_disabled
		remove_state MAIN_MIMAGE,mask_disabled
		Object_Redraw main_handle,MAIN_MCOLOURS
		Object_Redraw main_handle,MAIN_MIMAGE
	END SELECT
	Object_Redraw main_handle,GEN_LEVEL
CASE TIT_MUSIC
	fspath$=CURDIR$+"\*.WAV,*.MID" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		TIT_MUSIC$=dummy$
		setobj_text TIT_MUSIC,RIGHT$(dummy$,35)
		Object_Redraw main_handle,TIT_MUSIC
	ELSE
		TIT_MUSIC$=""
		setobj_text TIT_MUSIC,""
		Object_Redraw main_handle,TIT_MUSIC
	END IF
CASE TEX_HEADING2
	popup_heading=popup(main_handle,TEX_HEADING2,FORM_POPUPS,POP_COLOUR,0)
	IF popup_heading THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_heading)
		setobj_poptext TEX_HEADING2,"  "+dummy$
		IF dummy$=LANGUAGE$(125) THEN
			CALL initFORM_COLOURS (getobj_text$(TEX_HEADING))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_MAIN
			IF ChangeRGB=-1 THEN setobj_text TEX_HEADING,ChangeRGB$ : Object_Redraw main_handle,TEX_HEADING
		ELSE
			CALL UpdateRGB (TEX_HEADING,dummy$)
		END IF
		Object_Redraw main_handle,TEX_HEADING2
	END IF
CASE TEX_BODYTEXT2
	popup_text=popup(main_handle,TEX_BODYTEXT2,FORM_POPUPS,POP_COLOUR,0)
	IF popup_text THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_text)
		setobj_poptext TEX_BODYTEXT2," "+dummy$
		IF dummy$=LANGUAGE$(125) THEN
			CALL initFORM_COLOURS (getobj_text$(TEX_BODYTEXT))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_MAIN
			IF ChangeRGB=-1 THEN setobj_text TEX_BODYTEXT,ChangeRGB$ : Object_Redraw main_handle,TEX_BODYTEXT
		ELSE
			CALL UpdateRGB (TEX_BODYTEXT,dummy$)
		END IF
		Object_Redraw main_handle,TEX_BODYTEXT2
	END IF
CASE TEX_HYPER2
	popup_hyper=popup(main_handle,TEX_HYPER2,FORM_POPUPS,POP_COLOUR,0)
	IF popup_hyper THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_hyper)
		setobj_poptext TEX_HYPER2,"  "+dummy$
		IF dummy$=LANGUAGE$(125) THEN
			CALL initFORM_COLOURS (getobj_text$(TEX_HYPER))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_MAIN
			IF ChangeRGB=-1 THEN setobj_text TEX_HYPER,ChangeRGB$ : Object_Redraw main_handle,TEX_HYPER
		ELSE
			CALL UpdateRGB (TEX_HYPER,dummy$)
		END IF
		Object_Redraw main_handle,TEX_HYPER2
	END IF
CASE TEX_LINK2
	popup_link=popup(main_handle,TEX_LINK2,FORM_POPUPS,POP_COLOUR,0)
	IF popup_link THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_link)
		setobj_poptext TEX_LINK2,"  "+dummy$
		IF dummy$=LANGUAGE$(125) THEN
			CALL initFORM_COLOURS (getobj_text$(TEX_LINK))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_MAIN
			IF ChangeRGB=-1 THEN setobj_text TEX_LINK,ChangeRGB$ : Object_Redraw main_handle,TEX_LINK
		ELSE
			CALL UpdateRGB (TEX_LINK,dummy$)
		END IF
		Object_Redraw main_handle,TEX_LINK2
	END IF
CASE TEX_VISITED2
	popup_visited=popup(main_handle,TEX_VISITED2,FORM_POPUPS,POP_COLOUR,0)
	IF popup_VISITED THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_visited)
		setobj_poptext TEX_VISITED2,"  "+dummy$
		IF dummy$=LANGUAGE$(125) THEN
			CALL initFORM_COLOURS (getobj_text$(TEX_VISITED))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_MAIN
			IF ChangeRGB=-1 THEN setobj_text TEX_VISITED,ChangeRGB$ : Object_Redraw main_handle,TEX_VISITED
		ELSE
			CALL UpdateRGB (TEX_VISITED,dummy$)
		END IF
		Object_Redraw main_handle,TEX_VISITED2
	END IF
CASE TEX_IMAGE3
	fspath$=CURDIR$+"\*.JPG,*.GIF,*.PNG" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		TEX_IMAGE$=dummy$
		setobj_text TEX_IMAGE3,RIGHT$(dummy$,34)
		Object_Redraw main_handle,TEX_IMAGE3
	ELSE
		TEX_IMAGE$=""
		setobj_text TEX_IMAGE3,""
		Object_Redraw main_handle,TEX_IMAGE3
	END IF
CASE TEX_COLOUR4
	popup_colour=popup(main_handle,TEX_COLOUR4,FORM_POPUPS,POP_COLOUR,0)
	IF popup_colour THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_colour)
		setobj_poptext TEX_COLOUR4,"  "+dummy$
		IF dummy$=LANGUAGE$(125) THEN
			CALL initFORM_COLOURS (getobj_text$(TEX_COLOUR3))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_MAIN
			IF ChangeRGB=-1 THEN setobj_text TEX_COLOUR3,ChangeRGB$ : Object_Redraw main_handle,TEX_COLOUR3
		ELSE
			CALL UpdateRGB (TEX_COLOUR3,dummy$)
		END IF
		Object_Redraw main_handle,TEX_COLOUR4
	END IF
CASE HEAD_SIZE
	popup_hsize=popup(main_handle,HEAD_SIZE,FORM_POPUPS,POP_FONT,popup_hsize)
	IF popup_hsize THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_hsize)
		setobj_poptext HEAD_SIZE,"  "+dummy$
		Object_Redraw main_handle,HEAD_SIZE
	END IF
CASE HEAD_SIZE2
	radio_poptext HEAD_SIZE,FORM_POPUPS,POP_FONT,popup_hsize
	dummy$=LTRIM$(getobj_text$(HEAD_SIZE))
	setobj_text HEAD_SIZE,"  "+dummy$ : Object_Redraw main_handle,HEAD_SIZE
CASE HEAD_SSIZE
	popup_shsize=popup(main_handle,HEAD_SSIZE,FORM_POPUPS,POP_FONT,popup_shsize)
	IF popup_shsize THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_shsize)
		setobj_poptext HEAD_SSIZE,"  "+dummy$
		Object_Redraw main_handle,HEAD_SSIZE
	END IF
CASE HEAD_SSIZE2
	radio_poptext HEAD_SSIZE,FORM_POPUPS,POP_FONT,popup_shsize
	dummy$=LTRIM$(getobj_text$(HEAD_SSIZE))
	setobj_text HEAD_SSIZE,"  "+dummy$ : Object_Redraw main_handle,HEAD_SSIZE
CASE BODY_TEXTFILE
	fspath$=CURDIR$+"\*.*" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		BTEXT_FILE$=dummy$
		setobj_text BODY_TEXTFILE,LEFT$(dummy$,55)
		Object_Redraw main_handle,BODY_TEXTFILE
	ELSE
		BTEXT_FILE$=""
		setobj_text BODY_TEXTFILE,""
		Object_Redraw main_handle,BODY_TEXTFILE
	END IF
CASE IMG_FILE
	fspath$=CURDIR$+"\*.JPG,*.GIF,*.PNG" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
	IF FEXISTS(dummy$) THEN
		IMG_FILE$=dummy$
		setobj_text IMG_FILE,LEFT$(dummy$,55)
		Object_Redraw main_handle,IMG_FILE

		STATIC l&,mem&,x1,x2,x$,y1,y2,y$
		IF RIGHT$(IMG_FILE$,4)=".GIF" THEN
			myfile=FREEFILE
			OPEN dummy$ FOR INPUT AS #myfile
				l&=LOF(myfile)
			CLOSE #myfile
			mem&=malloc&(l&)
			IF mem& THEN
				BLOAD dummy$,mem&
				x1=SPEEKB(mem&+6) : x2=SPEEKB(mem&+7)
				x$="&H"+HEX$(x2)+HEX$(x1)
				IF x1=0 THEN x$=x$+"0"
				setobj_text IMG_WIDTH,RTRIM$(LTRIM$(STR$(VAL(x$))))
				y1=SPEEKB(mem&+8)
				y2=SPEEKB(mem&+9)
				y$="&H"+HEX$(y2)+HEX$(y1)
				IF y1=0 THEN y$=y$+"0"
				setobj_text IMG_HEIGHT,RTRIM$(LTRIM$(STR$(VAL(y$))))
				Object_Redraw main_handle,IMG_WIDTH
				Object_Redraw main_handle,IMG_HEIGHT
			END IF
			junk=mfree(mem&)
		END IF
	END IF
	ELSE
		IMG_FILE$=""
		setobj_text IMG_FILE,""
		setobj_text IMG_WIDTH,""
		setobj_text IMG_HEIGHT,""
		setobj_text IMG_BORDER,""
		Object_Redraw main_handle,IMG_FILE
		Object_Redraw main_handle,IMG_WIDTH
		Object_Redraw main_handle,IMG_HEIGHT
		Object_Redraw main_handle,IMG_BORDER
	END IF
CASE IMG_LINK
	fspath$=CURDIR$+"\*.HTM,*.HTML" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		IMGLNK_FILE$=dummy$
		setobj_text IMG_LINK,LEFT$(dummy$,55)
		Object_Redraw main_handle,IMG_LINK
	ELSE
		IMGLNK_FILE$=""
		setobj_text IMG_LINK,""
		Object_Redraw main_handle,IMG_LINK
	END IF
CASE LNK_LINK1
	fspath$=CURDIR$+"\*.HTM,*.HTML" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		LNK_FILE1$=dummy$
		setobj_text LNK_LINK1,LEFT$(dummy$,44)
		Object_Redraw main_handle,LNK_LINK1
	ELSE
		LNK_FILE1$=""
		setobj_text LNK_LINK1,""
		Object_Redraw main_handle,LNK_LINK1
	END IF
CASE LNK_LINK2
	fspath$=CURDIR$+"\*.HTM,*.HTML" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		LNK_FILE2$=dummy$
		setobj_text LNK_LINK2,LEFT$(dummy$,44)
		Object_Redraw main_handle,LNK_LINK2
	ELSE
		LNK_FILE2$=""
		setobj_text LNK_LINK2,""
		Object_Redraw main_handle,LNK_LINK2
	END IF
CASE LNK_LINK3
	fspath$=CURDIR$+"\*.HTM,*.HTML" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		LNK_FILE3$=dummy$
		setobj_text LNK_LINK3,LEFT$(dummy$,44)
		Object_Redraw main_handle,LNK_LINK3
	ELSE
		LNK_FILE3$=""
		setobj_text LNK_LINK3,""
		Object_Redraw main_handle,LNK_LINK3
	END IF
CASE AUT_SAVE : CALL SavePage ("")
END SELECT
END IF
END SUB

'===============================================================================

SUB UpdatePage (BYVAL object,BYVAL title,BYVAL cursor)
SHARED main_handle,CommonIndex,woEditObj(1),woEditOffset(1)
STATIC dummy

SelectTree FORM_MAIN
IF enquire_state(title,mask_selected) THEN EXIT SUB
include_flags MAIN_GENERAL,mask_hidetree
include_flags MAIN_TITLE,mask_hidetree
include_flags MAIN_COLOURS,mask_hidetree
include_flags MAIN_HEADINGS,mask_hidetree
include_flags MAIN_TEXT,mask_hidetree
include_flags MAIN_IMAGE,mask_hidetree
include_flags MAIN_LINKS,mask_hidetree
include_flags MAIN_AUTHOR,mask_hidetree

FOR dummy=MAIN_MGENERAL TO MAIN_MAUTHOR
	IF dummy<>title THEN
		IF enquire_state (dummy,mask_selected) THEN
			remove_state dummy,mask_selected
			IF main_handle>0 THEN Object_Redraw main_handle,dummy
		END IF
	END IF
NEXT
remove_flags object,mask_hidetree
include_state title,mask_selected

IF title<>MAIN_MGENERAL THEN
	remove_state MAIN_BACK,mask_disabled
ELSE
	include_state MAIN_BACK,mask_disabled
END IF

IF title<>MAIN_MAUTHOR THEN
	remove_state MAIN_NEXT,mask_disabled
ELSE
	include_state MAIN_NEXT,mask_disabled
END IF

IF main_handle>0 THEN
	Object_Redraw main_handle,MAIN_BACK
	Object_Redraw main_handle,MAIN_NEXT
	Object_Redraw main_handle,title
	Object_Redraw main_handle,MAIN_BACKDROP
	CommonIndex=WhichWindow(main_handle)
	IF CommonIndex<>0 THEN
		IF cursor<>0 THEN
			woEditObj(CommonIndex)=cursor
			woEditOffset(CommonIndex)=LEN(getobj_text$(cursor))
			HandleCursor main_handle,1
		END IF
	END IF
END IF
END SUB

'===============================================================================

FUNCTION hex2dec(dummy$)
	hex2dec=VAL("&h"+dummy$)
END FUNCTION

'===============================================================================

SUB initFORM_COLOURS (dummy$)
SHARED rgb(),r,g,b

DIM rgb(4)
SelectTree FORM_COLOURS
CALL update_mouse
dummy$=dummy$+"000000"
rgb(0)=hex2dec(MID$(dummy$,1,2))
rgb(1)=hex2dec(MID$(dummy$,3,2))
rgb(2)=hex2dec(MID$(dummy$,5,2))
setobj_text COL_RED2,LTRIM$(STR$(rgb(0)))
setobj_text COL_GREEN2,LTRIM$(STR$(rgb(1)))
setobj_text COL_BLUE2,LTRIM$(STR$(rgb(2)))
setobj_text COL_RGB,dummy$
setobj_x COL_RED2,rgb(0)
setobj_x COL_GREEN2,rgb(1)
setobj_x COL_BLUE2,rgb(2)
vq_color 14,0,rgb()

r=(1000/255)*VAL(getobj_text$(COL_RED2))
g=(1000/255)*VAL(getobj_text$(COL_GREEN2))
b=(1000/255)*VAL(getobj_text$(COL_BLUE2))
vs_color 14,r,g,b
MOUSE 0
END SUB

'===============================================================================

SUB UpdateRGB (BYVAL object,BYVAL dummy$)
SHARED main_handle

SelectTree FORM_MAIN
SELECT CASE dummy$
	CASE==LANGUAGE$(109) : setobj_text object,"FFFFFF"
	CASE==LANGUAGE$(110) : setobj_text object,"000000"
	CASE==LANGUAGE$(111) : setobj_text object,"FF0000"
	CASE==LANGUAGE$(112) : setobj_text object,"00FF00"
	CASE==LANGUAGE$(113) : setobj_text object,"0000FF"
	CASE==LANGUAGE$(114) : setobj_text object,"00FFFF"
	CASE==LANGUAGE$(115) : setobj_text object,"FFFF00"
	CASE==LANGUAGE$(116) : setobj_text object,"FF00FF"
	CASE==LANGUAGE$(117) : setobj_text object,"C0C0C0"
	CASE==LANGUAGE$(118) : setobj_text object,"808080"
	CASE==LANGUAGE$(119) : setobj_text object,"880000"
	CASE==LANGUAGE$(120) : setobj_text object,"008800"
	CASE==LANGUAGE$(121) : setobj_text object,"000088"
	CASE==LANGUAGE$(122) : setobj_text object,"008888"
	CASE==LANGUAGE$(123) : setobj_text object,"888800"
	CASE==LANGUAGE$(124) : setobj_text object,"880088"
END SELECT
Object_Redraw main_handle,object
END SUB

'===============================================================================

SUB closeFORM_COLOURS
SHARED ChangeRGB,ChangeRGB$,rgb()
STATIC x,y,w,h,x1,y1,x2,y2

SELECT CASE CommonObj
CASE COL_RED2,COL_GREEN2,COL_BLUE2
	MOUSE 4
	getobj_xywh CommonObj-1,x,y,w,h
	junk=objc_offset(tree&,CommonObj-1,x1,y1)
	junk=objc_offset(tree&,CommonObj,x2,y2)
	CALL graf_dragbox(getobj_width(CommonObj),getobj_height(CommonObj),x2,y2,x1,y1,w,h,x,y)
	junk=objc_offset(tree&,CommonObj-1,x2,y2)
	x=x-x2
	setobj_x CommonObj,x : setobj_text CommonObj,LTRIM$(STR$(x))
	IF x>255 THEN setobj_text CommonObj,"255"
	redraw_object CommonObj-1
	CALL UpdateColour
	MOUSE 0
CASE COL_RED3,COL_GREEN3,COL_BLUE3
	IF (VAL(getobj_text$(CommonObj-1))-1)>=0 THEN
		setobj_x CommonObj-1,getobj_x(CommonObj-1)-1
		setobj_text CommonObj-1,LTRIM$(STR$(VAL(getobj_text$(CommonObj-1))-1))
		redraw_object CommonObj-2
		CALL UpdateColour
	END IF
CASE COL_RED4,COL_GREEN4,COL_BLUE4
	IF (VAL(getobj_text$(CommonObj-2))+1)=<255 THEN
		setobj_x CommonObj-2,getobj_x(CommonObj-2)+1
		setobj_text CommonObj-2,LTRIM$(STR$(VAL(getobj_text$(CommonObj-2))+1))
		redraw_object CommonObj-3
		CALL UpdateColour
	END IF
CASE COL_OK
	vs_color 14,rgb(0),rgb(1),rgb(2)
	ERASE rgb
	ChangeRGB=-1 : ChangeRGB$=getobj_text$(COL_RGB)
	Finished_DFlag=0
CASE COL_CANCEL
	vs_color 14,rgb(0),rgb(1),rgb(2)
	ERASE rgb
	ChangeRGB=0 : Finished_DFlag=0
END SELECT
END SUB

'===============================================================================

SUB UpdateColour
STATIC dummy$,r,g,b

dummy$=HEX$(VAL(getobj_text$(COL_RED2)))
IF VAL(getobj_text$(COL_RED2))<16 THEN dummy$=LEFT$(dummy$,LEN(dummy$)-1)+"0"+RIGHT$(dummy$,1)
dummy$=dummy$+HEX$(VAL(getobj_text$(COL_GREEN2)))
IF VAL(getobj_text$(COL_GREEN2))<16 THEN dummy$=LEFT$(dummy$,LEN(dummy$)-1)+"0"+RIGHT$(dummy$,1)
dummy$=dummy$+HEX$(VAL(getobj_text$(COL_BLUE2)))
IF VAL(getobj_text$(COL_BLUE2))<16 THEN dummy$=LEFT$(dummy$,LEN(dummy$)-1)+"0"+RIGHT$(dummy$,1)
setobj_text COL_RGB,dummy$
redraw_object COL_RGB

r=(1000/255)*VAL(getobj_text$(COL_RED2))
g=(1000/255)*VAL(getobj_text$(COL_GREEN2))
b=(1000/255)*VAL(getobj_text$(COL_BLUE2))
vs_color 14,r,g,b
END SUB

'===============================================================================

SUB OpenWizard (loadfile$)
SHARED fspath$,fsmessage$,main_handle,ChooseFile$,TIT_MUSIC$,TEX_IMAGE$
SHARED popup_level,popup_hsize,popup_shsize,current_wizard$
STATIC fsname$,myfile,wzd$,dummy$,dummy,i,a$,b$,char

IF loadfile$="" THEN
	fspath$=CURDIR$+"\*.WZD" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$="" THEN EXIT SUB
ELSE
	dummy$=loadfile$
END IF

IF NOT FEXISTS(dummy$) THEN EXIT SUB
current_wizard$=dummy$
myfile=FREEFILE : dummy=0
OPEN dummy$ FOR INPUT AS #myfile
DO
	LINE INPUT #myfile,wzd$

	SELECT CASE wzd$
	CASE "<WebPage.Wizard>" : dummy=1
	CASE "<begin>" : dummy=2
	CASE "<end>" : dummy=3
	END SELECT
	CALL update_mouse
	IF dummy=2 THEN
		i=LEN(wzd$)
		DO
			IF MID$(wzd$,i,1)=">" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP
		a$=LEFT$(wzd$,i)
		b$=RIGHT$(wzd$,LEN(wzd$)-i)

		SELECT CASE a$
		CASE "<include comments>"
			setobj_shortcut GEN_INCLUDE,CHR$(13)
			IF b$="YES" THEN setobj_shortcut GEN_INCLUDE,CHR$(14)
			IF b$="NO" THEN setobj_shortcut GEN_INCLUDE,CHR$(13)
		CASE "<user level>"
			setobj_poptext GEN_LEVEL,"  "+b$
			SELECT CASE b$
			CASE "Novice"
				popup_level=POP_LEVEL+1
				include_state MAIN_MCOLOURS,mask_disabled
				include_state MAIN_MIMAGE,mask_disabled
			CASE "Amateur"
				popup_level=POP_LEVEL+2
				remove_state MAIN_MCOLOURS,mask_disabled
				include_state MAIN_MIMAGE,mask_disabled
			CASE "Expert"
				popup_level=POP_LEVEL+3
				remove_state MAIN_MCOLOURS,mask_disabled
				remove_state MAIN_MIMAGE,mask_disabled
			END SELECT
		CASE "<title>" : setobj_text TIT_TITLE,b$
		CASE "<keywords>" : setobj_text TIT_KEYWORDS,b$
		CASE "<background sound/music>"
			TIT_MUSIC$=b$
			IF b$<>"" THEN
				i=LEN(b$)
				DO
					IF MID$(b$,i,1)="\" THEN EXIT LOOP
					IF i=1 THEN EXIT LOOP
					DECR i
				LOOP
				setobj_text TIT_MUSIC,RIGHT$(b$,LEN(b$)-i)
			ELSE
				setobj_text TIT_MUSIC,""
			END IF
		CASE "<background sound/music - loop>" : setobj_text TIT_LOOP,b$
		CASE "<background sound/music - delay>" : setobj_text TIT_DELAY,b$
		CASE "<colour - heading>"
			CALL UpdateHEX (TEX_HEADING2,b$)
			setobj_text TEX_HEADING,b$
		CASE "<colour - text>"
			CALL UpdateHEX (TEX_BODYTEXT2,b$)
			setobj_text TEX_BODYTEXT,b$
		CASE "<colour - hyperlink text>"
			CALL UpdateHEX (TEX_HYPER2,b$)
			setobj_text TEX_HYPER,b$
		CASE "<colour - link>"
			CALL UpdateHEX (TEX_LINK2,b$)
			setobj_text TEX_LINK,b$
		CASE "<colour - visited link>"
			CALL UpdateHEX (TEX_VISITED2,b$)
			setobj_text TEX_VISITED,b$
		CASE "<colour - background>"
			CALL UpdateHEX (TEX_COLOUR4,b$)
			setobj_text TEX_COLOUR3,b$
		CASE "<background image?>"
			setobj_shortcut TEX_IMAGE,CHR$(11)
			setobj_shortcut TEX_COLOUR,CHR$(11)
			IF b$="YES" THEN setobj_shortcut TEX_IMAGE,CHR$(12)
			IF b$="NO" THEN setobj_shortcut TEX_COLOUR,CHR$(12)
		CASE "<background image>"
			TEX_IMAGE$=b$
			IF b$<>"" THEN
				i=LEN(b$)
				DO
					IF MID$(b$,i,1)="\" THEN EXIT LOOP
					IF i=1 THEN EXIT LOOP
					DECR i
				LOOP
				setobj_text TEX_IMAGE3,RIGHT$(b$,LEN(b$)-i)
			ELSE
				setobj_text TEX_IMAGE3,""
			END IF
		CASE "<heading>" : setobj_text HEAD_HEADING,b$
		CASE "<heading - font size>"
			setobj_poptext HEAD_SIZE,"  "+b$
			SELECT CASE b$
			CASE "Huge" : popup_hsize=POP_FONT+1
			CASE "Quite Large" : popup_hsize=POP_FONT+2
			CASE "Fairly Large" : popup_hsize=POP_FONT+3
			CASE "Normal" : popup_hsize=POP_FONT+4
			CASE "Small" : popup_hsize=POP_FONT+5
			CASE "Very Small" : popup_hsize=POP_FONT+6
			END SELECT
		CASE "<heading - bold>"
			remove_state HEAD_BOLD,mask_selected
			IF b$="YES" THEN include_state HEAD_BOLD,mask_selected
		CASE "<heading - underlined>"
			remove_state HEAD_UNDERLINED,mask_selected
			IF b$="YES" THEN include_state HEAD_UNDERLINED,mask_selected
		CASE "<heading - italic>"
			remove_state HEAD_ITALIC,mask_selected
			IF b$="YES" THEN include_state HEAD_ITALIC,mask_selected
		CASE "<heading - justification>"
			remove_state HEAD_LEFT,mask_selected
			remove_state HEAD_CENTRE,mask_selected
			remove_state HEAD_RIGHT,mask_selected
			IF b$="LEFT" THEN include_state HEAD_LEFT,mask_selected
			IF b$="CENTRE" THEN include_state HEAD_CENTRE,mask_selected
			IF b$="RIGHT" THEN include_state HEAD_RIGHT,mask_selected
		CASE "<heading - horizontal rule>"
			setobj_shortcut HEAD_RULE,CHR$(13)
			IF b$="YES" THEN setobj_shortcut HEAD_RULE,CHR$(14)
			IF b$="NO" THEN setobj_shortcut HEAD_RULE,CHR$(13)
		CASE "<sub-heading>" : setobj_text HEAD_SUBHEADING,b$
		CASE "<sub-heading - font size>"
			setobj_poptext HEAD_SSIZE,"  "+b$
			SELECT CASE b$
			CASE "Huge" : popup_shsize=POP_FONT+1
			CASE "Quite Large" : popup_shsize=POP_FONT+2
			CASE "Fairly Large" : popup_shsize=POP_FONT+3
			CASE "Normal" : popup_shsize=POP_FONT+4
			CASE "Small" : popup_shsize=POP_FONT+5
			CASE "Very Small" : popup_shsize=POP_FONT+6
			END SELECT
		CASE "<sub-heading - bold>"
			remove_state HEAD_SBOLD,mask_selected
			IF b$="YES" THEN include_state HEAD_SBOLD,mask_selected
		CASE "<sub-heading - underlined>"
			remove_state HEAD_SUNDERLINED,mask_selected
			IF b$="YES" THEN include_state HEAD_SUNDERLINED,mask_selected
		CASE "<sub-heading - italic>"
			remove_state HEAD_SITALIC,mask_selected
			IF b$="YES" THEN include_state HEAD_SITALIC,mask_selected
		CASE "<sub-heading - justification>"
			remove_state HEAD_SLEFT,mask_selected
			remove_state HEAD_SCENTRE,mask_selected
			remove_state HEAD_SRIGHT,mask_selected
			IF b$="LEFT" THEN include_state HEAD_SLEFT,mask_selected
			IF b$="CENTRE" THEN include_state HEAD_SCENTRE,mask_selected
			IF b$="RIGHT" THEN include_state HEAD_SRIGHT,mask_selected
		CASE "<sub-heading - horizontal rule>"
			setobj_shortcut HEAD_SRULE,CHR$(13)
			IF b$="YES" THEN setobj_shortcut HEAD_SRULE,CHR$(14)
			IF b$="NO" THEN setobj_shortcut HEAD_SRULE,CHR$(13)
		CASE "<text file>" : setobj_text BODY_TEXTFILE,b$
		CASE "<text file - bold>"
			remove_state BODY_BOLD,mask_selected
			IF b$="YES" THEN include_state BODY_BOLD,mask_selected
		CASE "<text file - underlined>"
			remove_state BODY_UNDERLINED,mask_selected
			IF b$="YES" THEN include_state BODY_UNDERLINED,mask_selected
		CASE "<text file - italic>"
			remove_state BODY_ITALIC,mask_selected
			IF b$="YES" THEN include_state BODY_ITALIC,mask_selected
		CASE "<text file - justification>"
			remove_state BODY_LEFT,mask_selected
			remove_state BODY_CENTRE,mask_selected
			remove_state BODY_RIGHT,mask_selected
			IF b$="LEFT" THEN include_state BODY_LEFT,mask_selected
			IF b$="CENTRE" THEN include_state BODY_CENTRE,mask_selected
			IF b$="RIGHT" THEN include_state BODY_RIGHT,mask_selected
		CASE "<text file - columns>"
			setobj_shortcut BODY_COLUMN1,CHR$(11)
			setobj_shortcut BODY_COLUMN2,CHR$(11)
			IF b$="1" THEN setobj_shortcut BODY_COLUMN1,CHR$(12)
			IF b$="2" THEN setobj_shortcut BODY_COLUMN2,CHR$(12)
		CASE "<text file - force carriage return>"
			setobj_shortcut BODY_RETURN,CHR$(13)
			IF b$="YES" THEN setobj_shortcut BODY_RETURN,CHR$(14)
			IF b$="NO" THEN setobj_shortcut BODY_RETURN,CHR$(13)
		CASE "<text file - force paragraph>"
			setobj_shortcut BODY_PARAGRAPH,CHR$(13)
			IF b$="YES" THEN setobj_shortcut BODY_PARAGRAPH,CHR$(14)
			IF b$="NO" THEN setobj_shortcut BODY_PARAGRAPH,CHR$(13)
		CASE "<text file - font>" : setobj_text BODY_FONTFAMILY,b$
		CASE "<image file>" : setobj_text IMG_FILE,b$
		CASE "<image file - alt. text>" : setobj_text IMG_ALTTEXT,b$
		CASE "<image file - width>" : setobj_text IMG_WIDTH,b$
		CASE "<image file - height>" : setobj_text IMG_HEIGHT,b$
		CASE "<image file - border>" : setobj_text IMG_BORDER,b$
		CASE "<image file - link>" : setobj_text IMG_LINK,b$
		CASE "<image file - position>"
			setobj_shortcut IMG_ABOVE,CHR$(11)
			setobj_shortcut IMG_BETWEEN,CHR$(11)
			setobj_shortcut IMG_BELOW,CHR$(11)
			IF b$="ABOVE" THEN setobj_shortcut IMG_ABOVE,CHR$(12)
			IF b$="BETWEEN" THEN setobj_shortcut IMG_BETWEEN,CHR$(12)
			IF b$="BELOW" THEN setobj_shortcut IMG_BELOW,CHR$(12)
		CASE "<image file - justification>"
			setobj_shortcut IMG_LEFT,CHR$(11)
			setobj_shortcut IMG_CENTRE,CHR$(11)
			setobj_shortcut IMG_RIGHT,CHR$(11)
			IF b$="LEFT" THEN setobj_shortcut IMG_LEFT,CHR$(12)
			IF b$="CENTRE" THEN setobj_shortcut IMG_CENTRE,CHR$(12)
			IF b$="RIGHT" THEN setobj_shortcut IMG_RIGHT,CHR$(12)
		CASE "<link 1>" : setobj_text LNK_LINK1,b$
		CASE "<text 1>" : setobj_text LNK_LNKTEXT1,b$
		CASE "<link 2>" : setobj_text LNK_LINK2,b$
		CASE "<text 2>" : setobj_text LNK_LNKTEXT2,b$
		CASE "<link 3>" : setobj_text LNK_LINK3,b$
		CASE "<text 3>" : setobj_text LNK_LNKTEXT3,b$
		CASE "<author>" : setobj_text AUT_NAME,b$
		CASE "<email>" : setobj_text AUT_EMAIL,b$
		CASE "<date>" : setobj_text AUT_DATE,b$
		END SELECT
	END IF
LOOP UNTIL EOF(myfile)
CLOSE #myfile
MOUSE 0
CALL UpdatePage (MAIN_GENERAL,MAIN_MGENERAL,0)
reset_dialog=0
main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,MAIN_SAVE,VARPTRS(closeFORM_MAIN))
IF main_handle THEN CALL init_dialog(FORM_MAIN)
reset_dialog=-1
Object_Redraw main_handle,GEN_INCLUDE
Object_Redraw main_handle,GEN_LEVEL
Object_Redraw main_handle,MAIN_MCOLOURS
Object_Redraw main_handle,MAIN_MIMAGE
END SUB

'===============================================================================

SUB UpdateHEX (BYVAL object,BYVAL dummy$)
SELECT CASE dummy$
CASE="FFFFFF" : setobj_poptext object,"  "+LANGUAGE$(109)
CASE="000000" : setobj_poptext object,"  "+LANGUAGE$(110)
CASE="FF0000" : setobj_poptext object,"  "+LANGUAGE$(111)
CASE="00FF00" : setobj_poptext object,"  "+LANGUAGE$(112)
CASE="0000FF" : setobj_poptext object,"  "+LANGUAGE$(113)
CASE="00FFFF" : setobj_poptext object,"  "+LANGUAGE$(114)
CASE="FFFF00" : setobj_poptext object,"  "+LANGUAGE$(115)
CASE="FF00FF" : setobj_poptext object,"  "+LANGUAGE$(116)
CASE="C0C0C0" : setobj_poptext object,"  "+LANGUAGE$(117)
CASE="808080" : setobj_poptext object,"  "+LANGUAGE$(118)
CASE="880000" : setobj_poptext object,"  "+LANGUAGE$(119)
CASE="008800" : setobj_poptext object,"  "+LANGUAGE$(120)
CASE="000088" : setobj_poptext object,"  "+LANGUAGE$(121)
CASE="008888" : setobj_poptext object,"  "+LANGUAGE$(122)
CASE="888800" : setobj_poptext object,"  "+LANGUAGE$(123)
CASE="880088" : setobj_poptext object,"  "+LANGUAGE$(124)
CASE ELSE : setobj_poptext object,"  "+LANGUAGE$(125)
END SELECT
END SUB

'===============================================================================

SUB SavePage (savefile$)
SHARED fspath$,fsmessage$,SaveAs$,CopyComplete$,TIT_MUSIC$,TEX_IMAGE$
SHARED current_wizard$
SHARED BTEXT_FILE$,IMG_FILE$,IMGLNK_FILE$,LNK_FILE1$,LNK_FILE2$,LNK_FILE3$
STATIC myfile,myfile2,dummy$,fsname$,dummy,a$,b$,c$,d$,e$,textfile$()
STATIC totallines,i,comments,halfway,misc$

IF savefile$="" THEN
	fspath$=CURDIR$+"\*.HTM" : fsmessage$=SaveAs$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2) : IF fsname$="" THEN EXIT SUB
	savefile$=dummy$
ELSE
	dummy$=savefile$
END IF

current_wizard$=dummy$
dummy=LEN(dummy$)
DO
	IF MID$(dummy$,dummy,1)="." THEN EXIT LOOP
	IF MID$(dummy$,dummy,1)="\" THEN dummy=1 : EXIT LOOP
	IF dummy=1 THEN EXIT LOOP
	DECR dummy
LOOP

IF dummy=1 THEN
	dummy$=dummy$+".HTM"
ELSE
	dummy$=LEFT$(dummy$,dummy-1)+".HTM"
END IF

SelectTree FORM_MAIN
IF BTEXT_FILE$="" THEN BTEXT_FILE$=getobj_text$(BODY_TEXTFILE)
IF IMG_FILE$="" THEN IMG_FILE$=getobj_text$(IMG_FILE)
IF IMGLNK_FILE$="" THEN IMGLNK_FILE$=getobj_text$(IMG_LINK)
IF LNK_FILE1$="" THEN LNK_FILE1$=getobj_text$(LNK_LINK1)
IF LNK_FILE2$="" THEN LNK_FILE2$=getobj_text$(LNK_LINK2)
IF LNK_FILE3$="" THEN LNK_FILE3$=getobj_text$(LNK_LINK3)

myfile=FREEFILE
OPEN dummy$ FOR OUTPUT AS #myfile
	CALL update_mouse
	SelectTree FORM_MAIN
	IF getobj_shortcut(GEN_INCLUDE)=14 THEN
		comments=-1
	ELSE
		comments=0
	END IF
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(179)
	IF comments THEN PRINT #myfile,LANGUAGE$(180)
	IF comments THEN PRINT #myfile,LANGUAGE$(181)
	IF comments THEN PRINT #myfile,LANGUAGE$(182)
	IF comments THEN PRINT #myfile,LANGUAGE$(183)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)

	PRINT #myfile,"<!DOCTYPE HTML PUBLIC "+CHR$(34)+"-//W3C//DTD HTML 3.2 Draft//EN"+CHR$(34)+">"
	PRINT #myfile,"<HTML>"
	PRINT #myfile,"<HEAD>"
	PRINT #myfile,CHR$(9)+"<TITLE>"+getobj_text$(TIT_TITLE)+"</TITLE>"
	PRINT #myfile,CHR$(9)+"<META NAME="+CHR$(34)+"GENERATOR"+CHR$(34)+" CONTENT="+CHR$(34)+"WebPage.Wizard v3.10 (Atari)"+CHR$(34)+">"
	PRINT #myfile,CHR$(9)+"<META HTTP-EQUIV="+CHR$(34)+"Content-Type"+CHR$(34)+" CONTENT="+CHR$(34)+"text/html; charset=iso-8859-1"+CHR$(34)+">"
	PRINT #myfile,CHR$(9)+"<META NAME="+CHR$(34)+"AUTHOR"+CHR$(34)+" CONTENT="+CHR$(34)+getobj_text$(AUT_NAME)+CHR$(34)+">"
	PRINT #myfile,CHR$(9)+"<META NAME="+CHR$(34)+"DESCRIPTION"+CHR$(34)+" CONTENT="+CHR$(34)+getobj_text$(TIT_TITLE)+CHR$(34)+">"
	PRINT #myfile,CHR$(9)+"<META NAME="+CHR$(34)+"KEYWORDS"+CHR$(34)+" CONTENT="+CHR$(34)+getobj_text$(TIT_KEYWORDS)+CHR$(34)+">"
	IF TIT_MUSIC$<>"" THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(184)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		misc$=TIT_MUSIC$
		i=LEN(misc$)
		DO
			IF MID$(misc$,i,1)="\" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP
		PRINT #myfile,CHR$(9)+"<BGSOUND SRC="+CHR$(34)+LCASE$(RIGHT$(misc$,LEN(misc$)-i))+CHR$(34)+" LOOP="+getobj_text$(TIT_LOOP)+" DELAY="+getobj_text$(TIT_DELAY)+">"
	END IF
	PRINT #myfile,"</HEAD>"
	CALL update_mouse

	PRINT #myfile,""
	a$="#"+getobj_text$(TEX_BODYTEXT)
	b$="#"+getobj_text$(TEX_HYPER)
	c$="#"+getobj_text$(TEX_LINK)
	d$="#"+getobj_text$(TEX_VISITED)
	e$="#"+getobj_text$(TEX_COLOUR3)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(185)
	IF comments THEN PRINT #myfile,LANGUAGE$(186)
	IF comments THEN PRINT #myfile,LANGUAGE$(187)
	IF comments THEN PRINT #myfile,LANGUAGE$(188)
	IF comments THEN PRINT #myfile,LANGUAGE$(189)
	IF comments THEN PRINT #myfile,LANGUAGE$(190)
	IF comments THEN PRINT #myfile,LANGUAGE$(191)
	IF comments THEN PRINT #myfile,LANGUAGE$(192)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF getobj_shortcut(TEX_IMAGE)=12 THEN
		misc$=TEX_IMAGE$
		i=LEN(misc$)
		DO
			IF MID$(misc$,i,1)="\" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP
		PRINT #myfile,"<BODY BACKGROUND="+CHR$(34)+LCASE$(RIGHT$(misc$,LEN(misc$)-i))+CHR$(34)+" ALINK="+CHR$(34)+b$+CHR$(34)+" LINK="+CHR$(34)+c$+CHR$(34)+" VLINK="+CHR$(34)+d$+CHR$(34)+" TEXT="+CHR$(34)+a$+CHR$(34)+">"
	ELSE
		PRINT #myfile,"<BODY BGCOLOR="+CHR$(34)+e$+CHR$(34)+" ALINK="+CHR$(34)+b$+CHR$(34)+" LINK="+CHR$(34)+c$+CHR$(34)+" VLINK="+CHR$(34)+d$+CHR$(34)+" TEXT="+CHR$(34)+a$+CHR$(34)+">"
	END IF
	PRINT #myfile,""
	IF TIT_MUSIC$<>"" THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(193)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		misc$=TIT_MUSIC$
		i=LEN(misc$)
		DO
			IF MID$(misc$,i,1)="\" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP
		PRINT #myfile,"<EMBED SRC="+CHR$(34)+LCASE$(RIGHT$(misc$,LEN(misc$)-i))+CHR$(34)+" WIDTH=0 HEIGHT=0 LOOP=true AUTOSTART=true>"
	END IF
	CALL update_mouse

	PRINT #myfile,""
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(194)
	IF comments THEN PRINT #myfile,LANGUAGE$(195)
	IF comments THEN PRINT #myfile,LANGUAGE$(196)
	IF comments THEN PRINT #myfile,LANGUAGE$(197)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	PRINT #myfile,"<FONT COLOR="+CHR$(34)+"#"+getobj_text$(TEX_HEADING)+CHR$(34)+">"
	a$=""
	IF enquire_state(HEAD_BOLD,mask_selected) THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(198)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		a$=a$+"<B>"
	END IF
	IF enquire_state(HEAD_UNDERLINED,mask_selected) THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(199)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		a$=a$+"<U>"
	END IF
	IF enquire_state(HEAD_ITALIC,mask_selected) THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(200)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		a$=a$+"<I>"
	END IF
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(201)
	IF comments THEN PRINT #myfile,LANGUAGE$(202)
	IF comments THEN PRINT #myfile,LANGUAGE$(203)
	IF comments THEN PRINT #myfile,LANGUAGE$(204)
	IF comments THEN PRINT #myfile,LANGUAGE$(205)
	IF comments THEN PRINT #myfile,LANGUAGE$(206)
	IF comments THEN PRINT #myfile,LANGUAGE$(207)
	IF comments THEN PRINT #myfile,LANGUAGE$(208)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	b$=LTRIM$(getobj_text$(HEAD_SIZE))
	SELECT CASE b$
	CASE LANGUAGE$(126) : a$=a$+"<H1"
	CASE LANGUAGE$(127) : a$=a$+"<H2"
	CASE LANGUAGE$(128) : a$=a$+"<H3"
	CASE LANGUAGE$(129) : a$=a$+"<H4"
	CASE LANGUAGE$(130) : a$=a$+"<H5"
	CASE LANGUAGE$(131) : a$=a$+"<H6"
	CASE ELSE : a$=a$+"<H4"
	END SELECT
	IF enquire_state(HEAD_LEFT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"LEFT"+CHR$(34)+">"
	IF enquire_state(HEAD_CENTRE,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"CENTER"+CHR$(34)+">"
	IF enquire_state(HEAD_RIGHT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)+">"
	a$=a$+getobj_text$(HEAD_HEADING)
	SELECT CASE b$
	CASE LANGUAGE$(126) : a$=a$+"</H1>"
	CASE LANGUAGE$(127) : a$=a$+"</H2>"
	CASE LANGUAGE$(128) : a$=a$+"</H3>"
	CASE LANGUAGE$(129) : a$=a$+"</H4>"
	CASE LANGUAGE$(130) : a$=a$+"</H5>"
	CASE LANGUAGE$(131) : a$=a$+"</H6>"
	CASE ELSE : a$=a$+"</H4>"
	END SELECT
	IF enquire_state(HEAD_BOLD,mask_selected) THEN a$=a$+"</B>"
	IF enquire_state(HEAD_UNDERLINED,mask_selected) THEN a$=a$+"</U>"
	IF enquire_state(HEAD_ITALIC,mask_selected) THEN a$=a$+"</I>"
	IF a$<>"" THEN PRINT #myfile,a$
	IF getobj_shortcut(HEAD_RULE)=14 THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(209)
		IF comments THEN PRINT #myfile,LANGUAGE$(210)
		IF comments THEN PRINT #myfile,LANGUAGE$(211)
		IF comments THEN PRINT #myfile,LANGUAGE$(212)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		PRINT #myfile,"<HR SIZE=2 WIDTH=100%>"
	END IF
	CALL update_mouse

	IF getobj_text$(HEAD_SUBHEADING)<>"" THEN
		a$=""
		IF enquire_state(HEAD_SBOLD,mask_selected) THEN
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(198)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			a$=a$+"<B>"
		END IF
		IF enquire_state(HEAD_SUNDERLINED,mask_selected) THEN
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(199)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			a$=a$+"<U>"
		END IF
		IF enquire_state(HEAD_SITALIC,mask_selected) THEN
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(200)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			a$=a$+"<I>"
		END IF
		b$=LTRIM$(getobj_text$(HEAD_SSIZE))
		SELECT CASE b$
		CASE LANGUAGE$(126) : a$=a$+"<H1"
		CASE LANGUAGE$(127) : a$=a$+"<H2"
		CASE LANGUAGE$(128) : a$=a$+"<H3"
		CASE LANGUAGE$(129) : a$=a$+"<H4"
		CASE LANGUAGE$(130) : a$=a$+"<H5"
		CASE LANGUAGE$(131) : a$=a$+"<H6"
		CASE ELSE : a$=a$+"<H4"
		END SELECT
		IF enquire_state(HEAD_SLEFT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"LEFT"+CHR$(34)+">"
		IF enquire_state(HEAD_SCENTRE,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"CENTER"+CHR$(34)+">"
		IF enquire_state(HEAD_SRIGHT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)+">"
		a$=a$+getobj_text$(HEAD_SUBHEADING)
		SELECT CASE b$
		CASE LANGUAGE$(126) : a$=a$+"</H1>"
		CASE LANGUAGE$(127) : a$=a$+"</H2>"
		CASE LANGUAGE$(128) : a$=a$+"</H3>"
		CASE LANGUAGE$(129) : a$=a$+"</H4>"
		CASE LANGUAGE$(130) : a$=a$+"</H5>"
		CASE LANGUAGE$(131) : a$=a$+"</H6>"
		CASE ELSE : a$=a$+"</H4>"
		END SELECT
		IF enquire_state(HEAD_SBOLD,mask_selected) THEN a$=a$+"</B>"
		IF enquire_state(HEAD_SUNDERLINED,mask_selected) THEN a$=a$+"</U>"
		IF enquire_state(HEAD_SITALIC,mask_selected) THEN a$=a$+"</I>"
		IF a$<>"" THEN PRINT #myfile,a$
		IF getobj_shortcut(HEAD_SRULE)=14 THEN
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(209)
			IF comments THEN PRINT #myfile,LANGUAGE$(210)
			IF comments THEN PRINT #myfile,LANGUAGE$(211)
			IF comments THEN PRINT #myfile,LANGUAGE$(212)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			PRINT #myfile,"<HR SIZE=2 WIDTH=100%>"
		END IF
	END IF
	PRINT #myfile,"</FONT>"
	CALL update_mouse

	DIM textfile$(1000)
	myfile2=FREEFILE : totallines=0
	a$=BTEXT_FILE$
	IF FEXISTS(a$) THEN
	IF a$<>"" THEN
	OPEN a$ FOR INPUT AS #myfile2
		DO
			IF totallines=999 THEN EXIT LOOP
			LINE INPUT #myfile2,textfile$(totallines)
			IF textfile$(totallines)="" THEN
				IF getobj_shortcut(BODY_PARAGRAPH)=14 THEN
					textfile$(totallines)="<P>"
				ELSE
					IF getobj_shortcut(BODY_RETURN)=14 THEN textfile$(totallines)=textfile$(totallines)+"<BR>"
				END IF
			ELSE
				IF getobj_shortcut(BODY_RETURN)=14 THEN textfile$(totallines)=textfile$(totallines)+"<BR>"
			END IF
			INCR totallines
		LOOP UNTIL EOF(myfile2)
	CLOSE #myfile2
	END IF
	END IF

	IF IMG_FILE$<>"" THEN
		IF getobj_shortcut(IMG_ABOVE)=12 THEN
			PRINT #myfile,""
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(213)
			IF comments THEN PRINT #myfile,LANGUAGE$(214)
			IF comments THEN PRINT #myfile,LANGUAGE$(215)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(217)
			IF comments THEN PRINT #myfile,LANGUAGE$(218)
			IF comments THEN PRINT #myfile,LANGUAGE$(219)
			IF comments THEN PRINT #myfile,LANGUAGE$(220)
			IF comments THEN PRINT #myfile,LANGUAGE$(221)
			IF comments THEN PRINT #myfile,LANGUAGE$(222)
			IF comments THEN PRINT #myfile,LANGUAGE$(223)
			IF comments THEN PRINT #myfile,LANGUAGE$(224)
			IF comments THEN PRINT #myfile,LANGUAGE$(225)
			IF comments THEN PRINT #myfile,LANGUAGE$(226)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)

			IF UCASE$(LEFT$(IMGLNK_FILE$,4))<>"HTTP" THEN
				b$=IMGLNK_FILE$
				IF b$<>"" THEN
					i=LEN(b$)
					DO
						IF MID$(b$,i,1)="\" THEN EXIT LOOP
						IF i=1 THEN i=0 : EXIT LOOP
						DECR i
					LOOP
					b$=RIGHT$(b$,LEN(b$)-i)
					PRINT #myfile,"<A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"
				END IF
			ELSE
				b$=IMGLNK_FILE$
				PRINT #myfile,"<A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"
			END IF

			b$=IMG_FILE$
			IF b$<>"" THEN
				i=LEN(b$)
				DO
					IF MID$(b$,i,1)="\" THEN EXIT LOOP
					IF i=1 THEN EXIT LOOP
					DECR i
				LOOP
				b$=RIGHT$(b$,LEN(b$)-i)
			END IF

			a$=""
			a$=a$+"<IMG SRC="+CHR$(34)+LCASE$(b$)+CHR$(34)
			IF getobj_text$(IMG_ALTTEXT)<>"" THEN a$=a$+" ALT="+CHR$(34)+getobj_text$(IMG_ALTTEXT)+CHR$(34)
			a$=a$+" ALIGN="+CHR$(34)+"MIDDLE"+CHR$(34)
			IF getobj_text$(IMG_WIDTH)<>"" THEN a$=a$+" WIDTH="+getobj_text$(IMG_WIDTH)
			IF getobj_text$(IMG_HEIGHT)<>"" THEN a$=a$+" HEIGHT="+getobj_text$(IMG_HEIGHT)
			IF getobj_text$(IMG_BORDER)<>"" THEN a$=a$+" BORDER="+getobj_text$(IMG_BORDER)

			IF getobj_shortcut(IMG_LEFT)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"LEFT"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
			IF getobj_shortcut(IMG_CENTRE)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"CENTER"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
			IF getobj_shortcut(IMG_RIGHT)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
			IF IMGLNK_FILE$<>"" THEN PRINT #myfile,"</A>"
		END IF
	END IF

	PRINT #myfile,""
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(227)
	IF comments THEN PRINT #myfile,LANGUAGE$(228)
	IF comments THEN PRINT #myfile,LANGUAGE$(229)
	IF comments THEN PRINT #myfile,LANGUAGE$(230)
	IF comments THEN PRINT #myfile,LANGUAGE$(231)
	IF comments THEN PRINT #myfile,LANGUAGE$(232)
	IF comments THEN PRINT #myfile,LANGUAGE$(233)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF getobj_shortcut(BODY_COLUMN1)=12 THEN
		PRINT #myfile,"<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 WIDTH=100%>"
	ELSE
		PRINT #myfile,"<TABLE BORDER=0 CELLPADDING=8 CELLSPACING=0 WIDTH=100%>"
	END IF
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(234)
	IF comments THEN PRINT #myfile,LANGUAGE$(235)
	IF comments THEN PRINT #myfile,LANGUAGE$(236)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	a$="<TD"
	IF enquire_state(BODY_LEFT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"LEFT"+CHR$(34)
	IF enquire_state(BODY_CENTRE,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"CENTER"+CHR$(34)
	IF enquire_state(BODY_RIGHT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)
	IF a$<>"" THEN PRINT #myfile,a$+">"

	PRINT #myfile,"<FONT FACE="+CHR$(34)+getobj_text$(BODY_FONTFAMILY)+CHR$(34)+" COLOR="+CHR$(34)+"#"+getobj_text$(TEX_BODYTEXT)+CHR$(34)+">"
	a$=""
	IF enquire_state(BODY_BOLD,mask_selected) THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(198)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		a$=a$+"<B>"
	END IF
	IF enquire_state(BODY_UNDERLINED,mask_selected) THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(199)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		a$=a$+"<U>"
	END IF
	IF enquire_state(BODY_ITALIC,mask_selected) THEN
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(200)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		a$=a$+"<I>"
	END IF

	IF a$<>"" THEN PRINT #myfile,a$

	halfway=(totallines/2)
	FOR dummy=0 TO totallines
		CALL update_mouse
		PRINT #myfile,textfile$(dummy)
		IF dummy=halfway THEN
			IF getobj_shortcut(BODY_COLUMN2)=12 THEN
				PRINT #myfile,"</FONT>"
				a$="<TD"
				IF enquire_state(BODY_LEFT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"LEFT"+CHR$(34)
				IF enquire_state(BODY_CENTRE,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"CENTER"+CHR$(34)
				IF enquire_state(BODY_RIGHT,mask_selected) THEN a$=a$+" ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)
				IF a$<>"" THEN PRINT #myfile,a$+">"
				PRINT #myfile,"<FONT FACE="+CHR$(34)+getobj_text$(BODY_FONTFAMILY)+CHR$(34)+" COLOR="+CHR$(34)+"#"+getobj_text$(TEX_BODYTEXT)+CHR$(34)+">"
			END IF

			IF IMG_FILE$<>"" THEN
				IF getobj_shortcut(IMG_BETWEEN)=12 THEN
					PRINT #myfile,""
					IF comments THEN PRINT #myfile,LANGUAGE$(178)
					IF comments THEN PRINT #myfile,LANGUAGE$(213)
					IF comments THEN PRINT #myfile,LANGUAGE$(214)
					IF comments THEN PRINT #myfile,LANGUAGE$(215)
					IF comments THEN PRINT #myfile,LANGUAGE$(178)
					IF comments THEN PRINT #myfile,LANGUAGE$(217)
					IF comments THEN PRINT #myfile,LANGUAGE$(218)
					IF comments THEN PRINT #myfile,LANGUAGE$(219)
					IF comments THEN PRINT #myfile,LANGUAGE$(220)
					IF comments THEN PRINT #myfile,LANGUAGE$(221)
					IF comments THEN PRINT #myfile,LANGUAGE$(222)
					IF comments THEN PRINT #myfile,LANGUAGE$(223)
					IF comments THEN PRINT #myfile,LANGUAGE$(224)
					IF comments THEN PRINT #myfile,LANGUAGE$(225)
					IF comments THEN PRINT #myfile,LANGUAGE$(226)
					IF comments THEN PRINT #myfile,LANGUAGE$(178)

					IF UCASE$(LEFT$(IMGLNK_FILE$,4))<>"HTTP" THEN
						b$=IMGLNK_FILE$
						IF b$<>"" THEN
							i=LEN(b$)
							DO
								IF MID$(b$,i,1)="\" THEN EXIT LOOP
								IF i=1 THEN i=0 : EXIT LOOP
								DECR i
							LOOP
							b$=RIGHT$(b$,LEN(b$)-i)
							PRINT #myfile,"<A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"
						END IF
					ELSE
						b$=IMGLNK_FILE$
						PRINT #myfile,"<A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"
					END IF

					b$=IMG_FILE$
					IF b$<>"" THEN
						i=LEN(b$)
						DO
							IF MID$(b$,i,1)="\" THEN EXIT LOOP
							IF i=1 THEN EXIT LOOP
							DECR i
						LOOP
						b$=RIGHT$(b$,LEN(b$)-i)
					END IF

					a$=""
					a$=a$+"<IMG SRC="+CHR$(34)+LCASE$(b$)+CHR$(34)
					IF getobj_text$(IMG_ALTTEXT)<>"" THEN a$=a$+" ALT="+CHR$(34)+getobj_text$(IMG_ALTTEXT)+CHR$(34)
					a$=a$+" ALIGN="+CHR$(34)+"MIDDLE"+CHR$(34)
					IF getobj_text$(IMG_WIDTH)<>"" THEN a$=a$+" WIDTH="+getobj_text$(IMG_WIDTH)
					IF getobj_text$(IMG_HEIGHT)<>"" THEN a$=a$+" HEIGHT="+getobj_text$(IMG_HEIGHT)
					IF getobj_text$(IMG_BORDER)<>"" THEN a$=a$+" BORDER="+getobj_text$(IMG_BORDER)

					IF getobj_shortcut(IMG_LEFT)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"LEFT"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
					IF getobj_shortcut(IMG_CENTRE)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"CENTER"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
					IF getobj_shortcut(IMG_RIGHT)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
					IF IMGLNK_FILE$<>"" THEN PRINT #myfile,"</A>"
				END IF
			END IF
		END IF
	NEXT dummy

	a$=""
	IF enquire_state(BODY_BOLD,mask_selected) THEN a$=a$+"</B>"
	IF enquire_state(BODY_UNDERLINED,mask_selected) THEN a$=a$+"</U>"
	IF enquire_state(BODY_ITALIC,mask_selected) THEN a$=a$+"</I>"
	IF a$<>"" THEN PRINT #myfile,a$
	PRINT #myfile,"</FONT>"
	PRINT #myfile,"</TABLE>"

	IF IMG_FILE$<>"" THEN
		IF getobj_shortcut(IMG_BELOW)=12 THEN
			PRINT #myfile,""
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(213)
			IF comments THEN PRINT #myfile,LANGUAGE$(214)
			IF comments THEN PRINT #myfile,LANGUAGE$(215)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)
			IF comments THEN PRINT #myfile,LANGUAGE$(217)
			IF comments THEN PRINT #myfile,LANGUAGE$(218)
			IF comments THEN PRINT #myfile,LANGUAGE$(219)
			IF comments THEN PRINT #myfile,LANGUAGE$(220)
			IF comments THEN PRINT #myfile,LANGUAGE$(221)
			IF comments THEN PRINT #myfile,LANGUAGE$(222)
			IF comments THEN PRINT #myfile,LANGUAGE$(223)
			IF comments THEN PRINT #myfile,LANGUAGE$(224)
			IF comments THEN PRINT #myfile,LANGUAGE$(225)
			IF comments THEN PRINT #myfile,LANGUAGE$(226)
			IF comments THEN PRINT #myfile,LANGUAGE$(178)

			IF UCASE$(LEFT$(IMGLNK_FILE$,4))<>"HTTP" THEN
				b$=IMGLNK_FILE$
				IF b$<>"" THEN
					i=LEN(b$)
					DO
						IF MID$(b$,i,1)="\" THEN EXIT LOOP
						IF i=1 THEN i=0 : EXIT LOOP
						DECR i
					LOOP
					b$=RIGHT$(b$,LEN(b$)-i)
					PRINT #myfile,"<A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"
				END IF
			ELSE
				b$=IMGLNK_FILE$
				PRINT #myfile,"<A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"
			END IF

			b$=IMG_FILE$
			IF b$<>"" THEN
				i=LEN(b$)
				DO
					IF MID$(b$,i,1)="\" THEN EXIT LOOP
					IF i=1 THEN EXIT LOOP
					DECR i
				LOOP
				b$=RIGHT$(b$,LEN(b$)-i)
			END IF

			a$=""
			a$=a$+"<IMG SRC="+CHR$(34)+LCASE$(b$)+CHR$(34)
			IF getobj_text$(IMG_ALTTEXT)<>"" THEN a$=a$+" ALT="+CHR$(34)+getobj_text$(IMG_ALTTEXT)+CHR$(34)
			a$=a$+" ALIGN="+CHR$(34)+"MIDDLE"+CHR$(34)
			IF getobj_text$(IMG_WIDTH)<>"" THEN a$=a$+" WIDTH="+getobj_text$(IMG_WIDTH)
			IF getobj_text$(IMG_HEIGHT)<>"" THEN a$=a$+" HEIGHT="+getobj_text$(IMG_HEIGHT)
			IF getobj_text$(IMG_BORDER)<>"" THEN a$=a$+" BORDER="+getobj_text$(IMG_BORDER)

			IF getobj_shortcut(IMG_LEFT)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"LEFT"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
			IF getobj_shortcut(IMG_CENTRE)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"CENTER"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
			IF getobj_shortcut(IMG_RIGHT)=12 THEN PRINT #myfile,"<P ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)+">"+a$+" HSPACE=4 VSPACE=4></P>"
			IF IMGLNK_FILE$<>"" THEN PRINT #myfile,"</A>"
		END IF
	END IF

	PRINT #myfile,""
	CALL update_mouse
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		IF comments THEN PRINT #myfile,LANGUAGE$(237)
		IF comments THEN PRINT #myfile,LANGUAGE$(238)
		IF comments THEN PRINT #myfile,LANGUAGE$(213)
		IF comments THEN PRINT #myfile,LANGUAGE$(214)
		IF comments THEN PRINT #myfile,LANGUAGE$(215)
		IF comments THEN PRINT #myfile,LANGUAGE$(178)
		PRINT #myfile,"<UL>"
		IF LNK_FILE1$<>"" THEN
			IF UCASE$(LEFT$(LNK_FILE1$,4))<>"HTTP" THEN
				b$=LNK_FILE1$
				IF b$<>"" THEN
					i=LEN(b$)
					DO
						IF MID$(b$,i,1)="\" THEN EXIT LOOP
						IF i=1 THEN i=0 : EXIT LOOP
						DECR i
					LOOP
					b$=RIGHT$(b$,LEN(b$)-i)
					PRINT #myfile,"<LI><A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"+getobj_text$(LNK_LNKTEXT1)+"</A>"
				END IF
			ELSE
				b$=LNK_FILE1$
				PRINT #myfile,"<LI><A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"+getobj_text$(LNK_LNKTEXT1)+"</A>"
			END IF
		END IF
		IF LNK_FILE2$<>"" THEN
			IF UCASE$(LEFT$(LNK_FILE2$,4))<>"HTTP" THEN
				b$=LNK_FILE2$
				IF b$<>"" THEN
					i=LEN(b$)
					DO
						IF MID$(b$,i,1)="\" THEN EXIT LOOP
						IF i=1 THEN i=0 : EXIT LOOP
						DECR i
					LOOP
					b$=RIGHT$(b$,LEN(b$)-i)
					PRINT #myfile,"<LI><A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"+getobj_text$(LNK_LNKTEXT2)+"</A>"
				END IF
			ELSE
				b$=LNK_FILE2$
				PRINT #myfile,"<LI><A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"+getobj_text$(LNK_LNKTEXT2)+"</A>"
			END IF
		END IF
		IF LNK_FILE3$<>"" THEN
			IF UCASE$(LEFT$(LNK_FILE3$,4))<>"HTTP" THEN
				b$=LNK_FILE3$
				IF b$<>"" THEN
					i=LEN(b$)
					DO
						IF MID$(b$,i,1)="\" THEN EXIT LOOP
						IF i=1 THEN i=0 : EXIT LOOP
						DECR i
					LOOP
					b$=RIGHT$(b$,LEN(b$)-i)
					PRINT #myfile,"<LI><A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"+getobj_text$(LNK_LNKTEXT3)+"</A>"
				END IF
			ELSE
				b$=LNK_FILE3$
				PRINT #myfile,"<LI><A HREF="+CHR$(34)+LCASE$(b$)+CHR$(34)+">"+getobj_text$(LNK_LNKTEXT3)+"</A>"
			END IF
		END IF
		PRINT #myfile,"</UL>"

	PRINT #myfile,""
	CALL update_mouse
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(209)
	IF comments THEN PRINT #myfile,LANGUAGE$(210)
	IF comments THEN PRINT #myfile,LANGUAGE$(211)
	IF comments THEN PRINT #myfile,LANGUAGE$(212)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(242)
	IF comments THEN PRINT #myfile,LANGUAGE$(243)
	IF comments THEN PRINT #myfile,LANGUAGE$(244)
	IF comments THEN PRINT #myfile,LANGUAGE$(213)
	IF comments THEN PRINT #myfile,LANGUAGE$(214)
	IF comments THEN PRINT #myfile,LANGUAGE$(215)
	IF comments THEN PRINT #myfile,LANGUAGE$(216)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	IF comments THEN PRINT #myfile,LANGUAGE$(245)
	IF comments THEN PRINT #myfile,LANGUAGE$(246)
	IF comments THEN PRINT #myfile,LANGUAGE$(178)
	PRINT #myfile,"<HR SIZE=2 WIDTH=100%>"
	PRINT #myfile,"<ADDRESS>"
	PRINT #myfile,"Please direct any comments to <PERSON>"+getobj_text$(AUT_NAME)+"</PERSON> at:"
	PRINT #myfile,"<A HREF="+CHR$(34)+"MAILTO:"+getobj_text$(AUT_EMAIL)+CHR$(34)+">"+getobj_text$(AUT_EMAIL)+"</A><BR>"
	PRINT #myfile,"Copyright &copy; "+getobj_text$(AUT_NAME)+" - Last updated on: "+LEFT$(getobj_text$(AUT_DATE),2)+"-"+MID$(getobj_text$(AUT_DATE),3,2)+"-"+RIGHT$(getobj_text$(AUT_DATE),2)
	PRINT #myfile,"</ADDRESS>"
	CALL update_mouse
	PRINT #myfile,"<HR SIZE=2 WIDTH=100%>"
	PRINT #myfile,"<CITE>This page was created using <A HREF="+CHR$(34)+"http://www.cadenza.cyberstrider.org/"+CHR$(34)+">Web.Wizard v3.10</A> &copy 1997-1999 Cadenza Software</CITE>"
	CALL update_mouse
	PRINT #myfile,"</BODY>"
	PRINT #myfile,"</HTML>"
CLOSE #myfile
ERASE textfile$

'===============================================================================

CALL update_mouse : myfile=FREEFILE
OPEN LEFT$(dummy$,LEN(dummy$)-3)+"WZD" FOR OUTPUT AS #myfile
	PRINT #myfile,"<WebPage.Wizard>"
	PRINT #myfile,"<begin>"
	CALL update_mouse
	IF getobj_shortcut(GEN_INCLUDE)=14 THEN PRINT #myfile,"<include comments>YES"
	IF getobj_shortcut(GEN_INCLUDE)=13 THEN PRINT #myfile,"<include comments>NO"
	PRINT #myfile,"<user level>"+LTRIM$(getobj_text$(GEN_LEVEL))
	PRINT #myfile,"<title>"+getobj_text$(TIT_TITLE)
	PRINT #myfile,"<keywords>"+getobj_text$(TIT_KEYWORDS)
	PRINT #myfile,"<background sound/music>"+TIT_MUSIC$
	PRINT #myfile,"<background sound/music - loop>"+getobj_text$(TIT_LOOP)
	PRINT #myfile,"<background sound/music - delay>"+getobj_text$(TIT_DELAY)
	CALL update_mouse
	PRINT #myfile,"<colour - heading>"+getobj_text$(TEX_HEADING)
	PRINT #myfile,"<colour - text>"+getobj_text$(TEX_BODYTEXT)
	PRINT #myfile,"<colour - hyperlink text>"+getobj_text$(TEX_HYPER)
	PRINT #myfile,"<colour - link>"+getobj_text$(TEX_LINK)
	PRINT #myfile,"<colour - visited link>"+getobj_text$(TEX_VISITED)
	IF getobj_shortcut(TEX_IMAGE)=12 THEN PRINT #myfile,"<background image?>YES"
	IF getobj_shortcut(TEX_IMAGE)=11 THEN PRINT #myfile,"<background image?>NO"
	PRINT #myfile,"<background image>"+TEX_IMAGE$
	PRINT #myfile,"<colour - background>"+getobj_text$(TEX_COLOUR3)
	CALL update_mouse
	PRINT #myfile,"<heading>"+getobj_text$(HEAD_HEADING)
	PRINT #myfile,"<heading - font size>"+LTRIM$(getobj_text$(HEAD_SIZE))
	IF enquire_state(HEAD_BOLD,mask_selected) THEN PRINT #myfile,"<heading - bold>YES"
	IF NOT enquire_state(HEAD_BOLD,mask_selected) THEN PRINT #myfile,"<heading - bold>NO"
	IF enquire_state(HEAD_UNDERLINED,mask_selected) THEN PRINT #myfile,"<heading - underlined>YES"
	IF NOT enquire_state(HEAD_UNDERLINED,mask_selected) THEN PRINT #myfile,"<heading - underlined>NO"
	IF enquire_state(HEAD_ITALIC,mask_selected) THEN PRINT #myfile,"<heading - italic>YES"
	IF NOT enquire_state(HEAD_ITALIC,mask_selected) THEN PRINT #myfile,"<heading - italic>NO"
	IF enquire_state(HEAD_LEFT,mask_selected) THEN PRINT #myfile,"<heading - justification>LEFT"
	IF enquire_state(HEAD_CENTRE,mask_selected) THEN PRINT #myfile,"<heading - justification>CENTRE"
	IF enquire_state(HEAD_RIGHT,mask_selected) THEN PRINT #myfile,"<heading - justification>RIGHT"
	IF getobj_shortcut(HEAD_RULE)=14 THEN PRINT #myfile,"<heading - horizontal rule>YES"
	IF getobj_shortcut(HEAD_RULE)=13 THEN PRINT #myfile,"<heading - horizontal rule>NO"
	PRINT #myfile,"<sub-heading>"+getobj_text$(HEAD_SUBHEADING)
	PRINT #myfile,"<sub-heading - font size>"+LTRIM$(getobj_text$(HEAD_SSIZE))
	IF enquire_state(HEAD_SBOLD,mask_selected) THEN PRINT #myfile,"<sub-heading - bold>YES"
	IF NOT enquire_state(HEAD_SBOLD,mask_selected) THEN PRINT #myfile,"<sub-heading - bold>NO"
	IF enquire_state(HEAD_SUNDERLINED,mask_selected) THEN PRINT #myfile,"<sub-heading - underlined>YES"
	IF NOT enquire_state(HEAD_SUNDERLINED,mask_selected) THEN PRINT #myfile,"<sub-heading - underlined>NO"
	IF enquire_state(HEAD_SITALIC,mask_selected) THEN PRINT #myfile,"<sub-heading - italic>YES"
	IF NOT enquire_state(HEAD_SITALIC,mask_selected) THEN PRINT #myfile,"<sub-heading - italic>NO"
	IF enquire_state(HEAD_SLEFT,mask_selected) THEN PRINT #myfile,"<sub-heading - justification>LEFT"
	IF enquire_state(HEAD_SCENTRE,mask_selected) THEN PRINT #myfile,"<sub-heading - justification>CENTRE"
	IF enquire_state(HEAD_SRIGHT,mask_selected) THEN PRINT #myfile,"<sub-heading - justification>RIGHT"
	IF getobj_shortcut(HEAD_SRULE)=14 THEN PRINT #myfile,"<sub-heading - horizontal rule>YES"
	IF getobj_shortcut(HEAD_SRULE)=13 THEN PRINT #myfile,"<sub-heading - horizontal rule>NO"
	CALL update_mouse
	PRINT #myfile,"<text file>"+BTEXT_FILE$
	IF enquire_state(BODY_BOLD,mask_selected) THEN PRINT #myfile,"<text file - bold>YES"
	IF NOT enquire_state(BODY_BOLD,mask_selected) THEN PRINT #myfile,"<text file - bold>NO"
	IF enquire_state(BODY_UNDERLINED,mask_selected) THEN PRINT #myfile,"<text file - underlined>YES"
	IF NOT enquire_state(BODY_UNDERLINED,mask_selected) THEN PRINT #myfile,"<text file - underlined>NO"
	IF enquire_state(BODY_ITALIC,mask_selected) THEN PRINT #myfile,"<text file - italic>YES"
	IF enquire_state(BODY_ITALIC,mask_selected) THEN PRINT #myfile,"<text file - italic>NO"
	IF enquire_state(BODY_LEFT,mask_selected) THEN PRINT #myfile,"<text file - justification>LEFT"
	IF enquire_state(BODY_CENTRE,mask_selected) THEN PRINT #myfile,"<text file - justification>CENTRE"
	IF enquire_state(BODY_RIGHT,mask_selected) THEN PRINT #myfile,"<text file - justification>RIGHT"
	IF getobj_shortcut(BODY_COLUMN1)=12 THEN PRINT #myfile,"<text file - columns>1"
	IF getobj_shortcut(BODY_COLUMN2)=12 THEN PRINT #myfile,"<text file - columns>2"
	IF getobj_shortcut(BODY_RETURN)=14 THEN PRINT #myfile,"<text file - force carriage return>YES"
	IF getobj_shortcut(BODY_RETURN)=13 THEN PRINT #myfile,"<text file - force carriage return>NO"
	IF getobj_shortcut(BODY_PARAGRAPH)=14 THEN PRINT #myfile,"<text file - force paragraph>YES"
	IF getobj_shortcut(BODY_PARAGRAPH)=13 THEN PRINT #myfile,"<text file - force paragraph>NO"
	PRINT #myfile,"<text file - font>"+getobj_text$(BODY_FONTFAMILY)
	CALL update_mouse
	PRINT #myfile,"<image file>"+IMG_FILE$
	PRINT #myfile,"<image file - alt. text>"+getobj_text$(IMG_ALTTEXT)
	PRINT #myfile,"<image file - width>"+getobj_text$(IMG_WIDTH)
	PRINT #myfile,"<image file - height>"+getobj_text$(IMG_HEIGHT)
	PRINT #myfile,"<image file - border>"+getobj_text$(IMG_BORDER)
	PRINT #myfile,"<image file - link>"+IMGLNK_FILE$
	IF getobj_shortcut(IMG_ABOVE)=12 THEN PRINT #myfile,"<image file - position>ABOVE"
	IF getobj_shortcut(IMG_BETWEEN)=12 THEN PRINT #myfile,"<image file - position>BETWEEN"
	IF getobj_shortcut(IMG_BELOW)=12 THEN PRINT #myfile,"<image file - position>BELOW"
	IF getobj_shortcut(IMG_LEFT)=12 THEN PRINT #myfile,"<image file - justification>LEFT"
	IF getobj_shortcut(IMG_CENTRE)=12 THEN PRINT #myfile,"<image file - justification>CENTRE"
	IF getobj_shortcut(IMG_RIGHT)=12 THEN PRINT #myfile,"<image file - justification>RIGHT"
	CALL update_mouse
	PRINT #myfile,"<link 1>"+LNK_FILE1$
	PRINT #myfile,"<text 1>"+getobj_text$(LNK_LNKTEXT1)
	PRINT #myfile,"<link 2>"+LNK_FILE2$
	PRINT #myfile,"<text 2>"+getobj_text$(LNK_LNKTEXT2)
	PRINT #myfile,"<link 3>"+LNK_FILE3$
	PRINT #myfile,"<text 3>"+getobj_text$(LNK_LNKTEXT3)
	CALL update_mouse
	PRINT #myfile,"<author>"+getobj_text$(AUT_NAME)
	PRINT #myfile,"<email>"+getobj_text$(AUT_EMAIL)
	PRINT #myfile,"<date>"+getobj_text$(AUT_DATE)
	PRINT #myfile,"<end>"
	CALL update_mouse
CLOSE #myfile

i=LEN(savefile$)
DO
	IF MID$(savefile$,i,1)="\" THEN EXIT LOOP
	IF i=1 THEN EXIT LOOP
	DECR i
LOOP
dummy$=LEFT$(savefile$,i)

IF TIT_MUSIC$<>"" THEN
IF FEXISTS(TIT_MUSIC$) THEN
	i=LEN(TIT_MUSIC$)
	DO
		IF MID$(TIT_MUSIC$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP
	IF TIT_MUSIC$<>dummy$+RIGHT$(TIT_MUSIC$,LEN(TIT_MUSIC$)-i) THEN
		junk=CopyFile (TIT_MUSIC$,dummy$+RIGHT$(TIT_MUSIC$,LEN(TIT_MUSIC$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF

IF TEX_IMAGE$<>"" THEN
IF FEXISTS(TEX_IMAGE$) THEN
	i=LEN(TEX_IMAGE$)
	DO
		IF MID$(TEX_IMAGE$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP
	IF TEX_IMAGE$<>dummy$+RIGHT$(TEX_IMAGE$,LEN(TEX_IMAGE$)-i) THEN
		junk=CopyFile (TEX_IMAGE$,dummy$+RIGHT$(TEX_IMAGE$,LEN(TEX_IMAGE$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF

IF IMG_FILE$<>"" THEN
IF FEXISTS(IMG_FILE$) THEN
	i=LEN(IMG_FILE$)
	DO
		IF MID$(IMG_FILE$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP
	IF IMG_FILE$<>dummy$+RIGHT$(IMG_FILE$,LEN(IMG_FILE$)-i) THEN
		junk=CopyFile (IMG_FILE$,dummy$+RIGHT$(IMG_FILE$,LEN(IMG_FILE$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF

IF UCASE$(LEFT$(IMGLNK_FILE$,4))<>"HTTP" THEN
IF FEXISTS(IMGLNK_FILE$) THEN
	i=LEN(IMGLNK_FILE$)
	DO
		IF MID$(IMGLNK_FILE$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN i=0 : EXIT LOOP
		DECR i
	LOOP
	IF IMGLNK_FILE$<>dummy$+RIGHT$(IMGLNK_FILE$,LEN(IMGLNK_FILE$)-i) THEN
		junk=CopyFile (IMGLNK_FILE$,dummy$+RIGHT$(IMGLNK_FILE$,LEN(IMGLNK_FILE$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF

IF UCASE$(LEFT$(LNK_FILE1$,4))<>"HTTP" THEN
IF FEXISTS(LNK_FILE1$) THEN
	i=LEN(LNK_FILE1$)
	DO
		IF MID$(LNK_FILE1$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN i=0 : EXIT LOOP
		DECR i
	LOOP
	IF LNK_FILE1$<>dummy$+RIGHT$(LNK_FILE1$,LEN(LNK_FILE1$)-i) THEN
		junk=CopyFile (LNK_FILE1$,dummy$+RIGHT$(LNK_FILE1$,LEN(LNK_FILE1$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF

IF UCASE$(LEFT$(LNK_FILE2$,4))<>"HTTP" THEN
IF FEXISTS(LNK_FILE2$) THEN
	i=LEN(LNK_FILE2$)
	DO
		IF MID$(LNK_FILE2$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN i=0 : EXIT LOOP
		DECR i
	LOOP
	IF LNK_FILE2$<>dummy$+RIGHT$(LNK_FILE2$,LEN(LNK_FILE2$)-i) THEN
		junk=CopyFile (LNK_FILE2$,dummy$+RIGHT$(LNK_FILE2$,LEN(LNK_FILE2$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF

IF UCASE$(LEFT$(LNK_FILE3$,4))<>"HTTP" THEN
IF FEXISTS(LNK_FILE3$) THEN
	i=LEN(LNK_FILE3$)
	DO
		IF MID$(LNK_FILE3$,i,1)="\" THEN EXIT LOOP
		IF i=1 THEN i=0 : EXIT LOOP
		DECR i
	LOOP
	IF LNK_FILE3$<>dummy$+RIGHT$(LNK_FILE3$,LEN(LNK_FILE3$)-i) THEN
		junk=CopyFile (LNK_FILE3$,dummy$+RIGHT$(LNK_FILE3$,LEN(LNK_FILE3$)-i),1)
		CALL update_mouse
	END IF
END IF
END IF
MOUSE 0
END SUB

'===============================================================================
'[END OF FILE]

'junk=form_alert(1,"[1][  "+STR$()+" ][ Abort ]")
