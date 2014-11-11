'===============================================================================
' Frame.Wizard v3.10 - Copyright ½ 1997-1999 Matthew Bacon
'===============================================================================

DEFINT a-z

'>>Include files<<
REM $include F:\cadenza\webwizrd.31\frame.wzd\frame.bh
REM $include F:\enchant\modules\error.bas
REM $include F:\cadenza\webwizrd.31\toolbx_a.bas
REM $include F:\enchant\modules\bubble.bas
REM $include F:\enchant\modules\cursor.bas
REM $include F:\enchant\modules\file.bas
REM $include F:\enchant\modules\protocol.bas
REM $include F:\enchant\modules\st-guide.bas

'===============================================================================

DIM SHARED LANGUAGE$(300)
ON ERROR GOTO ERROR_HANDLER
DIM SHARED frames_array$(10,10)

'>>Global variables<<
MyProgram$="Frame.Wizard"
reset_dialog=-1
hook_enabled=0
hook_timeout=1000
HowManyButtons=2
loadfrm$=COMMAND$

'>>Import language file<<
CALL import_language
'>>Start<<
CALL StartProgram (CURDIR$+"\FRAME.RSC",FORM_MENU,0,FORM_ICONIFY)

'>>Place strings into vairiables<<
CALL init_STRINGS
CALL init_BUBBLEHELP

'>>Place strings into rersource file<<
CALL init_INSTALL
CALL authorise_user
CALL init_COLOURS
CALL init_POPUPS
CALL init_MENUBAR : CALL init_Menu (FORM_MENU,-1)
CALL init_ABOUT
CALL init_FORMPAGE
CALL init_FORMFRAME

CALL init_FORMs
reset_dialog=0
junk=xdialog (FORM_ABOUT,0,0,1,0)
IF loadfrm$<>"" THEN CALL OpenFrame (loadfrm$)
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
		IF button=1 THEN CALL OpenFrame (message$)
	END IF
END SELECT
END SUB

SUB HandleUserHook
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
SELECT CASE key_pressed
CASE 25088 : junk=STGuide (CURDIR$+"\FRAME.HYP","CONTENTS")
END SELECT
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB

SUB	HandleUserMenu (cur_front,item,title)
SHARED frame_handle,page_handle,AreYouSure$,current_wizard$
STATIC button

SelectTree FORM_MENU
SELECT CASE item
CASE MENU_ABOUT : junk=xdialog (FORM_ABOUT,0,0,1,0)
CASE MENU_NEW
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN
		CALL init_FORMs
		page_handle=OpenFormWindow(MyProgram$,FORM_PAGE,FRM_TITLE,FRM_CANCEL,VARPTRS(closeFORM_PAGE))
		current_wizard$=""
	END IF
CASE MENU_OPENFRM
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN CALL OpenFrame ("")
CASE MENU_SAVE : CALL SaveFrame(current_wizard$)
CASE MENU_SAVEAS : CALL SaveFrame("")
CASE MENU_QUIT
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN Finished_Flag=-1
	IF button=2 THEN Finished_Flag=0
CASE MENU_PAGE
	page_handle=OpenFormWindow(MyProgram$,FORM_PAGE,FRM_TITLE,FRM_CANCEL,VARPTRS(closeFORM_PAGE))
CASE MENU_FRAME
	frame_handle=OpenFormWindow(MyProgram$,FORM_FRAME,FRM_NAME,0,VARPTRS(closeFORM_FRAME))
CASE MENU_ABOUTHELP : junk=STGuide (CURDIR$+"\FRAME.HYP","About Help...")
CASE MENU_HELP : junk=STGuide (CURDIR$+"\FRAME.HYP","CONTENTS")
CASE MENU_CYBER : junk=STGuide (CURDIR$+"\FRAME.HYP","CONTACT CYBERSTRIDER")
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
IF FEXISTS(CURDIR$+"\FRAME.LNG") THEN
	myfile=FREEFILE
	OPEN CURDIR$+"\FRAME.LNG" FOR INPUT AS #myfile
	DO
		LINE INPUT #myfile,dummy$
		IF dummy$<>"" THEN
			IF LEFT$(dummy$,1)<>";" THEN LANGUAGE$(dummy)=dummy$ : INCR dummy
			IF dummy=UBOUND(LANGUAGE$) THEN
				junk=form_alert(1,"[1][  "+MyProgram$+": |  Error in FRAME.LNG ][Abort]")
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
	junk=form_alert(1,"[1][  "+MyProgram$+": |  FRAME.LNG not found! ][Abort]")
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
setobj_text ABOUT_TEXT1,LANGUAGE$(42)		'>>Author<<
setobj_text ABOUT_TEXT2,LANGUAGE$(43)		'>>Distribution<<
setobj_text ABOUT_TEXT3,LANGUAGE$(44)		'>>Language<<
setobj_text ABOUT_LANGUAGE,LANGUAGE$(0)
setobj_text ABOUT_TEXT4,LANGUAGE$(45)		'>>Translation<<
setobj_text ABOUT_TRANSLATOR,LANGUAGE$(1)	'>>Translator<<
setobj_text ABOUT_TEXT5,LANGUAGE$(46)		'>>Key Code<<
setobj_text ABOUT_KEYCODE,keycode$
setobj_text ABOUT_TEXT6,LANGUAGE$(47)		'>>Registered to<<
setobj_text ABOUT_USER,user$
setobj_spec_str ABOUT_OK,LANGUAGE$(48)		'>>OK<<
END SUB

'===============================================================================

SUB init_MENUBAR
STATIC cellx,dummy

junk=graf_handle(cellx,junk,junk,junk)
SelectTree FORM_MENU
setobj_spec_str MENU_PROGRAM," "+LANGUAGE$(2)		'>>Frame.Wizard<<
setobj_spec_str MENU_ABOUT,"  "+LANGUAGE$(3)		'>>Information...<<
setobj_spec_str MENU_FILE," "+LANGUAGE$(4)			'>>File<<
setobj_spec_str MENU_NEW,"  "+LANGUAGE$(5)			'>>New ^N<<
setobj_spec_str MENU_OPENFRM,"  "+LANGUAGE$(6)		'>>Open *.FRM ^O<<
setobj_spec_str MENU_SAVE,"  "+LANGUAGE$(7)			'>>Save ^S<<
setobj_spec_str MENU_SAVEAS,"  "+LANGUAGE$(8)		'>>Save As..<<
setobj_spec_str MENU_QUIT,"  "+LANGUAGE$(9)		'>>Quit ^Q<<
setobj_spec_str MENU_WINDOW," "+LANGUAGE$(10)		'>>Window<<
setobj_spec_str MENU_PAGE,"  "+LANGUAGE$(11)		'>>Page Properties<<
setobj_spec_str MENU_FRAME,"  "+LANGUAGE$(12)		'>>Frame Properties<<
setobj_spec_str MENU_THELP," "+LANGUAGE$(13)		'>>Help<<
setobj_spec_str MENU_ABOUTHELP,"  "+LANGUAGE$(14)	'>>About Help...<<
setobj_spec_str MENU_HELP,"  "+LANGUAGE$(15)		'>>Help  [HELP]<<
setobj_spec_str MENU_CYBER,"  "+LANGUAGE$(16)		'>>CyberSTrider<<

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
setobj_x MENU_WINDOW,dummy
setobj_width MENU_WINDOW,cellx*(LEN(getobj_spec$(MENU_WINDOW))+1)
setobj_x MENU_PAGE-1,dummy+(2*cellx)
setobj_width MENU_PAGE-1,cellx*(LEN(getobj_spec$(MENU_PAGE))+1)
FOR dummy=MENU_PAGE TO MENU_FRAME
	setobj_width dummy,cellx*(LEN(getobj_spec$(MENU_PAGE))+1)
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_PAGE))+1)
NEXT dummy

dummy=getobj_x(MENU_WINDOW)+getobj_width(MENU_WINDOW)
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

SUB init_POPUPS
SelectTree FORM_POPUPS
setobj_text P_COL1," "+LANGUAGE$(49)		'>>White<<
setobj_text P_COL2," "+LANGUAGE$(50)		'>>Black<<
setobj_text P_COL3," "+LANGUAGE$(51)		'>>Red<<
setobj_text P_COL4," "+LANGUAGE$(52)		'>>Green<<
setobj_text P_COL5," "+LANGUAGE$(53)		'>>Blue<<
setobj_text P_COL6," "+LANGUAGE$(54)		'>>Cyan<<
setobj_text P_COL7," "+LANGUAGE$(55)		'>>Yellow<<
setobj_text P_COL8," "+LANGUAGE$(56)		'>>Magenta<<
setobj_text P_COL9," "+LANGUAGE$(57)		'>>Light grey<<
setobj_text P_COL10," "+LANGUAGE$(58)		'>>Dark grey<<
setobj_text P_COL11," "+LANGUAGE$(59)		'>>Dark red<<
setobj_text P_COL12," "+LANGUAGE$(60)		'>>Dark green<<
setobj_text P_COL13," "+LANGUAGE$(61)		'>>Dark blue<<
setobj_text P_COL14," "+LANGUAGE$(62)		'>>Dark cyan<<
setobj_text P_COL15," "+LANGUAGE$(63)		'>>Dark yellow<<
setobj_text P_COL16," "+LANGUAGE$(64)		'>>Dark magenta<<
setobj_text P_COLOTHER,"  "+LANGUAGE$(65)	'>>Other<<

setobj_text P_SCROLL1,"  "+LANGUAGE$(66)	'>>Automatically<<
setobj_text P_SCROLL2,"  "+LANGUAGE$(67)	'>>Yes<<
setobj_text P_SCROLL3,"  "+LANGUAGE$(68)	'>>No<<

setobj_text P_TMP1,"  "+LANGUAGE$(69)	'>>Template #1<<
setobj_text P_TMP2,"  "+LANGUAGE$(70)	'>>Template #2<<
setobj_text P_TMP3,"  "+LANGUAGE$(71)	'>>Template #3<<
setobj_text P_TMP4,"  "+LANGUAGE$(72)	'>>Template #4<<
setobj_text P_TMP5,"  "+LANGUAGE$(73)	'>>Template #5<<
setobj_text P_TMP6,"  "+LANGUAGE$(74)	'>>Template #6<<
setobj_text P_TMP7,"  "+LANGUAGE$(75)	'>>Template #7<<
setobj_text P_TMP8,"  "+LANGUAGE$(76)	'>>Template #8<<
setobj_text P_TMP9,"  "+LANGUAGE$(77)	'>>Template #9<<
setobj_text P_TMP10,"  "+LANGUAGE$(78)	'>>Template #10<<
setobj_text P_TMP11,"  "+LANGUAGE$(79)	'>>Template #11<<
setobj_text P_TMP12,"  "+LANGUAGE$(80)	'>>Template #12<<
setobj_text P_TMP13,"  "+LANGUAGE$(81)	'>>Template #13<<
setobj_text P_TMP14,"  "+LANGUAGE$(82)	'>>Template #14<<
setobj_text P_TMP15,"  "+LANGUAGE$(83)	'>>Template #15<<
setobj_text P_TMP16,"  "+LANGUAGE$(84)	'>>Template #16<<
setobj_text P_TMP17,"  "+LANGUAGE$(85)	'>>Template #17<<
setobj_text P_TMP18,"  "+LANGUAGE$(86)	'>>Template #18<<
setobj_text P_TMP19,"  "+LANGUAGE$(87)	'>>Template #19<<
setobj_text P_TMP20,"  "+LANGUAGE$(88)	'>>Template #20<<
END SUB

'===============================================================================

SUB init_COLOURS
SelectTree FORM_COLOURS
setobj_text RGB_RED,LANGUAGE$(89)			'>>Red<<
setobj_text RGB_GREEN,LANGUAGE$(90)		'>>Green<<
setobj_text RGB_BLUE,LANGUAGE$(91)			'>>Blue<<
setobj_spec_str COL_OK,LANGUAGE$(92)		'>>OK<<
setobj_spec_str COL_CANCEL,LANGUAGE$(93)	'>>Cancel<<
END SUB

'===============================================================================

SUB init_INSTALL
SelectTree FORM_INSTALL
setobj_spec_str INSTALL_WW,LANGUAGE$(94)	'>>Install Frame.Wizard<<
setobj_text INSTALL_USER,LANGUAGE$(95)		'>>User<<
setobj_text INSTALL_KEY,LANGUAGE$(96)		'>>Key Code<<
setobj_spec_str INSTALL_OK,LANGUAGE$(97)	'>>OK<<
END SUB

'===============================================================================

SUB init_FORMPAGE
SelectTree FORM_PAGE
setobj_text FRM_TEXT1,LANGUAGE$(29)		'>>The title of your page...<<
setobj_text FRM_TEXT2,LANGUAGE$(30)
setobj_text FRM_TEXT3,LANGUAGE$(31)
setobj_spec_str FRM_TTITLE,LANGUAGE$(32)	'>>Title<<
setobj_text FRM_TEXT4,LANGUAGE$(33)		'>>Some very old...<<
setobj_text FRM_TEXT5,LANGUAGE$(34)
setobj_text FRM_TEXT6,LANGUAGE$(35)
setobj_spec_str FRM_TALTURL,LANGUAGE$(36)	'>>Alt. URL<<
setobj_text FRM_BACKGRND,LANGUAGE$(37)		'>>Background<<
setobj_spec_str FRM_IMAGE2," "+LANGUAGE$(38)	'>>Image:<<
setobj_spec_str FRM_COLOUR2," "+LANGUAGE$(39)	'>>Colour:<<
setobj_spec_str FRM_OK,LANGUAGE$(40)	'>>OK<<
setobj_spec_str FRM_CANCEL,LANGUAGE$(41)	'>>Cancel<<
END SUB

'===============================================================================

SUB init_FORMFRAME
SelectTree FORM_FRAME
setobj_spec_str FRM_CUTX,LANGUAGE$(17)	'>>Cut X<<
setobj_spec_str FRM_CUTY,LANGUAGE$(18)	'>>Cut Y<<
setobj_spec_str FRM_GLUE,LANGUAGE$(19)	'>>Glue<<
setobj_text FRM_TNAME,LANGUAGE$(20)		'>>Name:<<
setobj_text FRM_TURL,LANGUAGE$(21)		'>>Alt. URL:<<
setobj_text FRM_TBORDER,LANGUAGE$(22)	'>>Border:<<
setobj_text FRM_BORDERYES2," "+LANGUAGE$(23)	'>>Yes<<
setobj_text FRM_BORDERNO2," "+LANGUAGE$(24)		'>>No<<
setobj_text FRM_THEIGHT,LANGUAGE$(25)		'>>Margin Height<<
setobj_text FRM_TWIDTH,LANGUAGE$(26)		'>>Margin Width<<
setobj_text FRM_TSCROLL,LANGUAGE$(27)		'>>Scrolling<<
setobj_spec_str FRM_SELECTFRM,LANGUAGE$(28)	'>>Select a Frame<<
END SUB

'===============================================================================

SUB init_STRINGS
SHARED ChooseFile$,AreYouSure$,SaveAs$,noINF$,corruptINF$
SHARED NotComplete$,KeyIncorrect$,ChangeTemplate$,DeselectFRM$,stopglue$

ChooseFile$=LANGUAGE$(98)
SaveAs$=LANGUAGE$(99)
AreYouSure$=LANGUAGE$(100)
ChangeTemplate$=LANGUAGE$(101)
DeselectFRM$=LANGUAGE$(102)
stopglue$=LANGUAGE$(103)
noINF$=LANGUAGE$(104)
corruptINF$=LANGUAGE$(105)
NotComplete$=LANGUAGE$(106)
KeyIncorrect$=LANGUAGE$(107)
END SUB

'===============================================================================

SUB init_BUBBLEHELP
SHARED BUB_IMAGE3$,BUB_OK$,BUB_CANCEL$
SHARED BUB_TEMPLATE$,BUB_CUTX$,BUB_CUTY$,BUB_GLUE$,BUB_URL$,BUB_SCROLL$,BUB_FRAMES$

BUB_IMAGE3$=LANGUAGE$(108)
BUB_OK$=LANGUAGE$(109)
BUB_CANCEL$=LANGUAGE$(110)
BUB_TEMPLATE$=LANGUAGE$(111)
BUB_CUTX$=LANGUAGE$(112)
BUB_CUTY$=LANGUAGE$(113)
BUB_GLUE$=LANGUAGE$(114)
BUB_URL$=LANGUAGE$(115)
BUB_SCROLL$=LANGUAGE$(116)
BUB_FRAMES$=LANGUAGE$(117)
END SUB

'===============================================================================

SUB init_FORMs
SHARED popup_template,popup_colour,popup_scroll,frame_handle,page_handle
SHARED woEditObj(0),woEditOffset(0),table_image$
STATIC dummy,CommonIndex

SelectTree FORM_FRAME
CALL update_mouse
setobj_poptext FRM_TEMPLATE,"  "+getobj_poptext$(FORM_POPUPS,POP_TEMPLATE+1)
popup_template=POP_TEMPLATE+1
setobj_text FRM_NAME,""
setobj_text FRM_URL,"http://www."
setobj_shortcut FRM_BORDERYES,CHR$(11)
setobj_shortcut FRM_BORDERNO,CHR$(12)
CALL update_mouse
setobj_text FRM_MARGINH,"000"
setobj_text FRM_MARGINW,"000"
setobj_poptext FRM_SCROLL,"  "+getobj_poptext$(FORM_POPUPS,POP_SCROLL+1)
popup_scroll=POP_SCROLL+1
CALL update_mouse

SelectTree FORM_PAGE
setobj_text FRM_TITLE,""
setobj_text FRM_ALTURL,"http://www."
setobj_shortcut FRM_IMAGE,CHR$(11)
table_image$=""
setobj_text FRM_IMAGE3,""
setobj_shortcut FRM_COLOUR,CHR$(12)
CALL update_mouse
setobj_text FRM_COLOUR3,"FFFFFF"
setobj_poptext FRM_COLOUR4,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+2)
popup_colour=POP_COLOUR+2
CALL update_mouse
CALL UpdateTemplate (getobj_poptext$(FORM_POPUPS,POP_TEMPLATE+1))
FOR dummy=1 TO 10
	frames_array$(dummy,1)=""
	frames_array$(dummy,2)="http://www."
	frames_array$(dummy,3)="NO"
	frames_array$(dummy,4)="000"
	frames_array$(dummy,5)="000"
	frames_array$(dummy,6)="  "+getobj_poptext$(FORM_POPUPS,POP_SCROLL+1)
NEXT
CALL update_mouse
include_flags FRM_PROPERTIES,mask_hidetree
remove_flags FRM_SELECTFRM,mask_hidetree
IF frame_handle THEN
	SelectTree FORM_FRAME
	redraw_object FRM_SELECTFRM
	redraw_object FRM_PROPERTIES
END IF
IF page_handle THEN
	SelectTree FORM_PAGE
	redraw_object 0
	CommonIndex=WhichWindow(page_handle)
	woEditObj(CommonIndex)=FRM_TITLE
	woEditOffset(CommonIndex)=LEN(getobj_text$(woEditObj(CommonIndex)))
	HandleCursor page_handle,1
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_PAGE
SHARED fspath$,fsmessage$,fsname$,ChooseFile$,ChangeRGB,ChangeRGB$
SHARED popup_template,popup_colour,popup_scroll,page_handle,frame_handle
SHARED BUB_IMAGE3$,BUB_OK$,BUB_CANCEL$,table_image$
STATIC dummy$

SelectTree FORM_PAGE
IF CommonButton=2 THEN
SELECT CASE CommonObj
CASE FRM_IMAGE3 : junk=BubbleGEM (BUB_IMAGE3$)
CASE FRM_OK : junk=BubbleGEM (BUB_OK$)
CASE FRM_CANCEL : junk=BubbleGEM (BUB_CANCEL$)
END SELECT
ELSE
SELECT CASE CommonObj
CASE FRM_ALTURL
	fspath$=CURDIR$+"\*.HTM,*.HTML" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		table_image$=dummy$
		setobj_text FRM_ALTURL,RIGHT$(dummy$,43)
		Object_Redraw page_handle,FRM_ALTURL
	ELSE
		table_image$=""
		setobj_text FRM_ALTURL,""
		Object_Redraw page_handle,FRM_ALTURL
	END IF
CASE FRM_IMAGE3
	fspath$=CURDIR$+"\*.JPG,*.GIF,*.PNG" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		table_image$=dummy$
		setobj_text FRM_IMAGE3,RIGHT$(dummy$,40)
		Object_Redraw page_handle,FRM_IMAGE3
	ELSE
		table_image$=""
		setobj_text FRM_IMAGE3,""
		Object_Redraw page_handle,FRM_IMAGE3
	END IF
CASE FRM_COLOUR4
	popup_colour=popup(page_handle,FRM_COLOUR4,FORM_POPUPS,POP_COLOUR,0)
	IF popup_colour THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_colour)
		setobj_poptext FRM_COLOUR4,"  "+dummy$
		IF dummy$=LANGUAGE$(65) THEN
			CALL initFORM_COLOURS (getobj_text$(FRM_COLOUR3))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_PAGE
			IF ChangeRGB=-1 THEN
				setobj_text FRM_COLOUR3,ChangeRGB$
			END IF
		ELSE
			CALL UpdateRGB (FRM_COLOUR3,dummy$)
		END IF
		Object_Redraw page_handle,FRM_COLOUR3
		Object_Redraw page_handle,FRM_COLOUR4
	END IF
CASE FRM_OK
	page_handle=0 : CommonClose=-1
	DeselectObject FRM_OK
	frame_handle=OpenFormWindow(MyProgram$,FORM_FRAME,FRM_NAME,0,VARPTRS(closeFORM_FRAME))
CASE FRM_CANCEL : page_handle=0 : CommonClose=-1
END SELECT
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
SHARED page_handle

SelectTree FORM_PAGE
SELECT CASE dummy$
	CASE==LANGUAGE$(49) : setobj_text object,"FFFFFF"
	CASE==LANGUAGE$(50) : setobj_text object,"000000"
	CASE==LANGUAGE$(51) : setobj_text object,"FF0000"
	CASE==LANGUAGE$(52) : setobj_text object,"00FF00"
	CASE==LANGUAGE$(53) : setobj_text object,"0000FF"
	CASE==LANGUAGE$(54) : setobj_text object,"00FFFF"
	CASE==LANGUAGE$(55) : setobj_text object,"FFFF00"
	CASE==LANGUAGE$(56) : setobj_text object,"FF00FF"
	CASE==LANGUAGE$(57) : setobj_text object,"C0C0C0"
	CASE==LANGUAGE$(58) : setobj_text object,"808080"
	CASE==LANGUAGE$(59) : setobj_text object,"880000"
	CASE==LANGUAGE$(60) : setobj_text object,"008800"
	CASE==LANGUAGE$(61) : setobj_text object,"000088"
	CASE==LANGUAGE$(62) : setobj_text object,"008888"
	CASE==LANGUAGE$(63) : setobj_text object,"888800"
	CASE==LANGUAGE$(64) : setobj_text object,"880088"
END SELECT
Object_Redraw page_handle,object
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

SUB UpdateHEX (BYVAL object,BYVAL dummy$)
SELECT CASE dummy$
CASE="FFFFFF" : setobj_poptext object,"  "+LANGUAGE$(49)
CASE="000000" : setobj_poptext object,"  "+LANGUAGE$(50)
CASE="FF0000" : setobj_poptext object,"  "+LANGUAGE$(51)
CASE="00FF00" : setobj_poptext object,"  "+LANGUAGE$(52)
CASE="0000FF" : setobj_poptext object,"  "+LANGUAGE$(53)
CASE="00FFFF" : setobj_poptext object,"  "+LANGUAGE$(54)
CASE="FFFF00" : setobj_poptext object,"  "+LANGUAGE$(55)
CASE="FF00FF" : setobj_poptext object,"  "+LANGUAGE$(56)
CASE="C0C0C0" : setobj_poptext object,"  "+LANGUAGE$(57)
CASE="808080" : setobj_poptext object,"  "+LANGUAGE$(58)
CASE="880000" : setobj_poptext object,"  "+LANGUAGE$(59)
CASE="008800" : setobj_poptext object,"  "+LANGUAGE$(60)
CASE="000088" : setobj_poptext object,"  "+LANGUAGE$(61)
CASE="008888" : setobj_poptext object,"  "+LANGUAGE$(62)
CASE="888800" : setobj_poptext object,"  "+LANGUAGE$(63)
CASE="880088" : setobj_poptext object,"  "+LANGUAGE$(64)
CASE ELSE : setobj_poptext object,"  "+LANGUAGE$(65)
END SELECT
END SUB

'===============================================================================

SUB closeFORM_FRAME
SHARED fspath$,fsmessage$,fsname$,ChooseFile$,AreYouSure$,ChangeTemplate$,stopglue$
SHARED popup_template,popup_colour,popup_scroll,page_handle,frame_handle
STATIC dummy$,button,dummy,dummy2,x,y,w,h,x1,y1,w1,h1,x2,y2,w2,h2
STATIC total_frames,unhide_frame,frame_intersects,old_object,selected_frame
STATIC check_1,check_2,check_3,check_4
SHARED BUB_TEMPLATE$,BUB_CUTX$,BUB_CUTY$,BUB_GLUE$,BUB_URL$,BUB_SCROLL$,BUB_FRAMES$

SelectTree FORM_FRAME
IF CommonButton=2 THEN
SELECT CASE CommonObj
CASE FRM_TEMPLATE : junk=BubbleGEM (BUB_TEMPLATE$)
CASE FRM_CUTx : junk=BubbleGEM (BUB_CUTX$)
CASE FRM_CUTy : junk=BubbleGEM (BUB_CUTY$)
CASE FRM_GLUE : junk=BubbleGEM (BUB_GLUE$)
CASE FRM_URL : junk=BubbleGEM (BUB_URL$)
CASE FRM_SCROLL : junk=BubbleGEM (BUB_SCROLL$)
CASE FRM_FRM1 TO FRM_FRM6
	junk=BubbleGEM (BUB_FRAMES$)
	SelectTree FORM_FRAME
	IF enquire_flags(FRM_PROPERTIES,mask_hidetree) THEN
		remove_state CommonObj,mask_selected
	ELSE
		include_state CommonObj,mask_selected
	END IF
	Object_Redraw frame_handle,CommonObj
END SELECT
ELSE
SELECT CASE CommonObj
CASE FRM_TEMPLATE
	popup_template=popup(frame_handle,FRM_TEMPLATE,FORM_POPUPS,POP_TEMPLATE,0)
	IF popup_template THEN
		button=form_alert(2,ChangeTemplate$)
		IF button=1 THEN
			dummy$=getobj_poptext$(FORM_POPUPS,popup_template)
			setobj_poptext FRM_TEMPLATE,"  "+dummy$
			Object_Redraw frame_handle,FRM_TEMPLATE
			CALL UpdateTemplate (dummy$)
			FOR dummy=1 TO 10
				frames_array$(dummy,1)=""
				frames_array$(dummy,2)="http://www."
				frames_array$(dummy,3)="NO"
				frames_array$(dummy,4)="000"
				frames_array$(dummy,5)="000"
				frames_array$(dummy,6)="  "+getobj_poptext$(FORM_POPUPS,POP_SCROLL+1)
			NEXT
		END IF
	END IF
CASE FRM_CUTx
	total_frames=0
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN INCR total_frames
	NEXT
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF total_frames<6 THEN
			IF enquire_state(dummy,mask_selected) THEN
				getobj_xywh dummy,x,y,w,h
				setobj_xywh dummy,x,y,w/2,h
				remove_state dummy,mask_selected

				FOR dummy2=FRM_FRM1 TO FRM_FRM6
					IF enquire_flags(dummy2,mask_hidetree) THEN
						unhide_frame=dummy2
					END IF
				NEXT
				setobj_xywh unhide_frame,x+(w/2),y,w/2,h
				remove_flags unhide_frame,mask_hidetree
				INCR total_frames
			END IF
		END IF
		remove_state dummy,mask_selected
	NEXT
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			IF (x+w)>240 THEN w=240-x
			IF (y+h)>180 THEN h=180-y
			setobj_xywh dummy,x,y,w,h
		END IF
	NEXT dummy
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			FOR dummy2=FRM_FRM1 TO FRM_FRM6
				IF dummy<>dummy2 THEN
					IF NOT enquire_flags(dummy2,mask_hidetree) THEN
						getobj_xywh dummy2,x1,y1,w1,h1
						intersection x1,y1,w1,h1,x,y,w,h,x2,y2,w2,h2
						IF w2>0 THEN
							IF x>x1 THEN
								x=x+w2
								setobj_xywh dummy,x,y,w,h
							ELSE
								w1=w1-w2
								setobj_xywh dummy2,x1,y1,w1,h1
							END IF
						END IF
					END IF
				END IF
			NEXT dummy2
		END IF
	NEXT dummy
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			IF (x+w)>240 THEN w=240-x
			IF (y+h)>180 THEN h=180-y
			setobj_xywh dummy,x,y,w,h
		END IF
	NEXT dummy
	Object_Redraw frame_handle,FRAME_BACK
	remove_flags FRM_SELECTFRM,mask_hidetree
	include_flags FRM_PROPERTIES,mask_hidetree
	Object_Redraw frame_handle,FRM_SELECTFRM
	Object_Redraw frame_handle,FRM_PROPERTIES
CASE FRM_CUTy
	total_frames=0
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN INCR total_frames
	NEXT
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF total_frames<6 THEN
			IF enquire_state(dummy,mask_selected) THEN
				getobj_xywh dummy,x,y,w,h
				setobj_xywh dummy,x,y,w,h/2
				remove_state dummy,mask_selected

				FOR dummy2=FRM_FRM1 TO FRM_FRM6
					IF enquire_flags(dummy2,mask_hidetree) THEN
						unhide_frame=dummy2
					END IF
				NEXT
				setobj_xywh unhide_frame,x,y+(h/2),w,h/2
				remove_flags unhide_frame,mask_hidetree
				INCR total_frames
			END IF
		END IF
		remove_state dummy,mask_selected
	NEXT
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			IF (x+w)>240 THEN w=240-x
			IF (y+h)>180 THEN h=180-y
			setobj_xywh dummy,x,y,w,h
		END IF
	NEXT dummy
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			FOR dummy2=FRM_FRM1 TO FRM_FRM6
				IF dummy<>dummy2 THEN
					IF NOT enquire_flags(dummy2,mask_hidetree) THEN
						getobj_xywh dummy2,x1,y1,w1,h1
						intersection x1,y1,w1,h1,x,y,w,h,x2,y2,w2,h2
						IF h2>0 THEN
							IF y>y1 THEN
								y=y+h2
								setobj_xywh dummy,x,y,w,h
							ELSE
								h1=h1-h2
								setobj_xywh dummy2,x1,y1,w1,h1
							END IF
						END IF
					END IF
				END IF
			NEXT dummy2
		END IF
	NEXT dummy
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			IF (x+w)>240 THEN w=240-x
			IF (y+h)>180 THEN h=180-y
			setobj_xywh dummy,x,y,w,h
		END IF
	NEXT dummy
	Object_Redraw frame_handle,FRAME_BACK
	remove_flags FRM_SELECTFRM,mask_hidetree
	include_flags FRM_PROPERTIES,mask_hidetree
	Object_Redraw frame_handle,FRM_SELECTFRM
	Object_Redraw frame_handle,FRM_PROPERTIES
CASE FRM_GLUE
	x1=240 : y1=180 : w1=0 : h1=0
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF enquire_state(dummy,mask_selected) THEN
			getobj_xywh dummy,x,y,w,h
			IF x<x1 THEN
				IF (x+w)=<x1 THEN
				IF w1<>0 THEN w1=w1+(x1-x)
				END IF
			x1=x
			END IF
			IF y<y1 THEN
				IF (y+h)=<y1 THEN
				IF h1<>0 THEN h1=h1+(y1-y)
				END IF
				y1=y
			END IF
			IF (x+w)>(x1+w1) THEN w1=(x+w)-x1
			IF (y+h)>(y1+h1) THEN h1=(y+h)-y1
		END IF
	NEXT

	check_1=0 : check_2=0 : check_3=0 : check_4=0
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			IF ((x1=x) AND (y1=y)) THEN
				check_1=1
			ELSE
				IF ((x1=0) OR (y1=0)) THEN check_1=1
			END IF
			IF ((x1+w1=x+w) AND (y1=y)) THEN
				check_2=1
			ELSE
				IF ((x1+w1=240) OR (y1=0)) THEN check_2=1
			END IF
			IF ((x1=x) AND (y1+h1=y+h)) THEN
				check_3=1
			ELSE
				IF ((x1=0) OR (y1+h1=180)) THEN check_3=1
			END IF
			IF ((x1+w1=x+w) AND (y1+h1=y+h)) THEN
				check_4=1
			ELSE
				IF ((x1+w1=240) OR (y1+h1=180)) THEN check_4=1
			END IF
		END IF
	NEXT
	IF check_1+check_2+check_3+check_4<>4 THEN
		junk=form_alert(1,stopglue$) : EXIT SELECT
	END IF

	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x,y,w,h
			intersection x1,y1,w1,h1,x,y,w,h,x2,y2,w2,h2
			frame_intersects=0
			IF x2<>0 THEN frame_intersects=-1
			IF y2<>0 THEN frame_intersects=-1
			IF w2<>0 THEN frame_intersects=-1
			IF h2<>0 THEN frame_intersects=-1
			IF frame_intersects<>0 THEN
				include_flags dummy,mask_hidetree
				IF w<>w2 THEN
					w=w-w2 : remove_flags dummy,mask_hidetree
					SELECT CASE x
					CASE x2 TO (x2+w2) : x=x+w2
					END SELECT
				END IF
				IF h<>h2 THEN
					h=h-h2 : remove_flags dummy,mask_hidetree
					SELECT CASE y
					CASE y2 TO (y2+h2) : y=y+h2
					END SELECT
				END IF
				setobj_xywh dummy,x,y,w,h
			END IF
		END IF
	NEXT

	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF enquire_flags(dummy,mask_hidetree) THEN
			setobj_xywh dummy,x1,y1,w1,h1
			remove_flags dummy,mask_hidetree

			getobj_xywh dummy,x,y,w,h
			IF (x+w)>240 THEN w=240-x
			IF (y+h)>180 THEN h=180-y
			setobj_xywh dummy,x,y,w,h
		EXIT FOR
		END IF
	NEXT
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		getobj_xywh dummy,x,y,w,h
		remove_state dummy,mask_selected
		IF (w+h)=0 THEN include_flags dummy,mask_hidetree
	NEXT
	Object_Redraw frame_handle,FRAME_BACK
CASE FRM_URL
	fspath$=CURDIR$+"\*.HTM,*.HTML" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	IF fsname$<>"" THEN
		setobj_text FRM_URL,RIGHT$(dummy$,40)
		FOR dummy=FRM_FRM1 TO FRM_FRM6
			IF enquire_state(dummy,mask_selected) THEN
				frames_array$(dummy,2)=dummy$
			END IF
		NEXT
		Object_Redraw frame_handle,FRM_URL
	ELSE
		setobj_text FRM_URL,""
		Object_Redraw frame_handle,FRM_URL
	END IF
CASE FRM_SCROLL
	popup_scroll=popup(frame_handle,FRM_SCROLL,FORM_POPUPS,POP_SCROLL,0)
	IF popup_scroll THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_scroll)
		setobj_poptext FRM_SCROLL,"  "+dummy$
		Object_Redraw frame_handle,FRM_SCROLL
	END IF
CASE FRM_FRM1 TO FRM_FRM6
	total_frames=0
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		IF enquire_state(dummy,mask_selected) THEN
			INCR total_frames
			selected_frame=dummy
		END IF
	NEXT
	SELECT CASE total_frames
	CASE 1
		setobj_text FRM_NAME,frames_array$(selected_frame,1)
		setobj_text FRM_URL,frames_array$(selected_frame,2)
		IF frames_array$(selected_frame,3)="YES" THEN
			setobj_shortcut FRM_BORDERYES,CHR$(12)
			setobj_shortcut FRM_BORDERNO,CHR$(11)
		ELSE
			setobj_shortcut FRM_BORDERYES,CHR$(11)
			setobj_shortcut FRM_BORDERNO,CHR$(12)
		END IF
		setobj_text FRM_MARGINH,frames_array$(selected_frame,4)
		setobj_text FRM_MARGINW,frames_array$(selected_frame,5)
		setobj_poptext FRM_SCROLL,frames_array$(selected_frame,6)
		remove_flags FRM_PROPERTIES,mask_hidetree
		include_flags FRM_SELECTFRM,mask_hidetree
		old_object=selected_frame
		IF frame_handle THEN CALL init_dialog(FORM_FRAME)
	CASE ELSE
		IF NOT enquire_flags(FRM_PROPERTIES,mask_hidetree) THEN
			frames_array$(old_object,1)=getobj_text$(FRM_NAME)
			IF LEFT$(getobj_text$(FRM_URL),40)<>LEFT$(frames_array$(old_object,2),40) THEN
				frames_array$(old_object,2)=getobj_text$(FRM_URL)
			END IF
			IF getobj_shortcut(FRM_BORDERYES)=12 THEN
				frames_array$(old_object,3)="YES"
			ELSE
				frames_array$(old_object,3)="NO"
			END IF
			frames_array$(old_object,4)=getobj_text$(FRM_MARGINH)
			frames_array$(old_object,5)=getobj_text$(FRM_MARGINW)
			frames_array$(old_object,6)=getobj_text$(FRM_SCROLL)
			remove_flags FRM_SELECTFRM,mask_hidetree
			include_flags FRM_PROPERTIES,mask_hidetree
		END IF
		old_object=CommonObj
	END SELECT
	Object_Redraw frame_handle,FRM_SELECTFRM
	Object_Redraw frame_handle,FRM_PROPERTIES : CALL frame_cursor
END SELECT
END IF
END SUB

'===============================================================================

SUB UpdateTemplate (dummy$)
SHARED frame_handle
STATIC dummy

SelectTree FORM_FRAME
FOR dummy=FRM_FRM1 TO FRM_FRM6
	CALL update_mouse
	remove_state dummy,mask_selected
	include_flags dummy,mask_hidetree
NEXT
SELECT CASE dummy$
CASE LANGUAGE$(69)
	CALL UpdateFrame (FRM_FRM1,0,0,240,180)
CASE LANGUAGE$(70)
	CALL UpdateFrame (FRM_FRM1,0,0,120,180)
	CALL UpdateFrame (FRM_FRM2,120,0,120,180)
CASE LANGUAGE$(71)
	CALL UpdateFrame (FRM_FRM1,0,0,240,90)
	CALL UpdateFrame (FRM_FRM2,0,90,240,90)
CASE LANGUAGE$(72)
	CALL UpdateFrame (FRM_FRM1,0,0,48,180)
	CALL UpdateFrame (FRM_FRM2,48,0,192,180)
CASE LANGUAGE$(73)
	CALL UpdateFrame (FRM_FRM1,0,0,192,180)
	CALL UpdateFrame (FRM_FRM2,192,0,48,180)
CASE LANGUAGE$(74)
	CALL UpdateFrame (FRM_FRM1,0,0,48,180)
	CALL UpdateFrame (FRM_FRM2,48,0,144,180)
	CALL UpdateFrame (FRM_FRM3,192,0,48,180)
CASE LANGUAGE$(75)
	CALL UpdateFrame (FRM_FRM1,0,0,240,36)
	CALL UpdateFrame (FRM_FRM2,0,36,240,144)
CASE LANGUAGE$(76)
	CALL UpdateFrame (FRM_FRM1,0,0,240,144)
	CALL UpdateFrame (FRM_FRM2,0,144,240,36)
CASE LANGUAGE$(77)
	CALL UpdateFrame (FRM_FRM1,0,0,240,36)
	CALL UpdateFrame (FRM_FRM2,0,36,240,108)
	CALL UpdateFrame (FRM_FRM3,0,144,240,36)
CASE LANGUAGE$(78)
	CALL UpdateFrame (FRM_FRM1,0,0,240,36)
	CALL UpdateFrame (FRM_FRM2,0,36,120,108)
	CALL UpdateFrame (FRM_FRM3,120,36,120,108)
	CALL UpdateFrame (FRM_FRM4,0,144,240,36)
CASE LANGUAGE$(79)
	CALL UpdateFrame (FRM_FRM1,0,0,240,36)
	CALL UpdateFrame (FRM_FRM2,0,36,48,144)
	CALL UpdateFrame (FRM_FRM3,48,36,192,144)
CASE LANGUAGE$(80)
	CALL UpdateFrame (FRM_FRM1,0,0,120,90)
	CALL UpdateFrame (FRM_FRM2,120,0,120,90)
	CALL UpdateFrame (FRM_FRM3,0,90,240,90)
CASE LANGUAGE$(81)
	CALL UpdateFrame (FRM_FRM1,0,0,240,90)
	CALL UpdateFrame (FRM_FRM2,0,90,120,90)
	CALL UpdateFrame (FRM_FRM3,120,90,120,90)
CASE LANGUAGE$(82)
	CALL UpdateFrame (FRM_FRM1,0,0,120,90)
	CALL UpdateFrame (FRM_FRM2,0,90,120,90)
	CALL UpdateFrame (FRM_FRM3,120,0,120,180)
CASE LANGUAGE$(83)
	CALL UpdateFrame (FRM_FRM1,0,0,120,180)
	CALL UpdateFrame (FRM_FRM2,120,0,120,90)
	CALL UpdateFrame (FRM_FRM3,120,90,120,90)
CASE LANGUAGE$(84)
	CALL UpdateFrame (FRM_FRM1,0,0,240,36)
	CALL UpdateFrame (FRM_FRM2,0,36,48,144)
	CALL UpdateFrame (FRM_FRM3,48,36,144,144)
	CALL UpdateFrame (FRM_FRM4,192,36,48,144)
CASE LANGUAGE$(85)
	CALL UpdateFrame (FRM_FRM1,0,0,48,144)
	CALL UpdateFrame (FRM_FRM2,48,0,144,144)
	CALL UpdateFrame (FRM_FRM3,192,0,48,144)
	CALL UpdateFrame (FRM_FRM4,0,144,240,36)
CASE LANGUAGE$(86)
	CALL UpdateFrame (FRM_FRM1,0,0,120,60)
	CALL UpdateFrame (FRM_FRM2,120,0,120,60)
	CALL UpdateFrame (FRM_FRM3,0,60,240,60)
	CALL UpdateFrame (FRM_FRM4,0,120,120,60)
	CALL UpdateFrame (FRM_FRM5,120,120,120,60)
CASE LANGUAGE$(87)
	CALL UpdateFrame (FRM_FRM1,0,0,120,90)
	CALL UpdateFrame (FRM_FRM2,0,90,120,90)
	CALL UpdateFrame (FRM_FRM3,120,0,120,60)
	CALL UpdateFrame (FRM_FRM4,120,60,120,60)
	CALL UpdateFrame (FRM_FRM5,120,120,120,60)
CASE LANGUAGE$(88)
	CALL UpdateFrame (FRM_FRM1,0,0,120,60)
	CALL UpdateFrame (FRM_FRM2,120,0,120,60)
	CALL UpdateFrame (FRM_FRM3,0,60,120,60)
	CALL UpdateFrame (FRM_FRM4,120,60,120,60)
	CALL UpdateFrame (FRM_FRM5,0,120,120,60)
	CALL UpdateFrame (FRM_FRM6,120,120,120,60)
END SELECT
remove_flags FRM_SELECTFRM,mask_hidetree
include_flags FRM_PROPERTIES,mask_hidetree
IF frame_handle THEN Object_Redraw frame_handle,FRAME_BACK
IF frame_handle THEN Object_Redraw frame_handle,FRM_SELECTFRM
IF frame_handle THEN Object_Redraw frame_handle,FRM_PROPERTIES
MOUSE 0
END SUB

'===============================================================================

SUB frame_cursor
SHARED frame_handle,CommonIndex,woEditObj(1),woEditOffset(1)
STATIC object,go_ahead

CommonIndex=WhichWindow(frame_handle)
IF CommonIndex<>0 THEN
	woEditOffset(CommonIndex)=LEN(getobj_text$(woEditObj(CommonIndex)))

	object=woEditObj(CommonIndex)
	go_ahead=0
	DO
		IF enquire_flags(object,mask_hidetree) THEN
			go_ahead=-1 : EXIT LOOP
		ELSE
			object=getobj_parent(object)
		END IF
	LOOP UNTIL object=0
	IF go_ahead<>-1 THEN HandleCursor frame_handle,1
END IF
END SUB

'===============================================================================

SUB UpdateFrame (dummy,x,y,w,h)

CALL update_mouse
SelectTree FORM_FRAME
remove_flags dummy,mask_hidetree
setobj_xywh dummy,x,y,w,h
END SUB

'===============================================================================

SUB OpenFrame (loadfile$)
SHARED fspath$,fsmessage$,fsname$,page_handle,frame_handle,ChooseFile$,current_wizard$
SHARED table_image$
STATIC myfile,dummy$,dummy,i,a$,b$

IF loadfile$="" THEN
	fspath$=CURDIR$+"\*.FRM" : fsmessage$=ChooseFile$ : fsname$=""
	dummy$=FileSelect$ (fsname$,2) : IF fsname$="" THEN EXIT SUB
ELSE
	dummy$=loadfile$
END IF

IF NOT FEXISTS(dummy$) THEN EXIT SUB
CALL init_FORMs
current_wizard$=dummy$ : myfile=FREEFILE : dummy=0
OPEN current_wizard$ FOR INPUT AS #myfile
DO
	LINE INPUT #myfile,dummy$
	SELECT CASE dummy$
	CASE "<Frame.Wizard>" : dummy=1
	CASE "<begin>" : dummy=2
	CASE "<end>" : dummy=3
	END SELECT
	CALL update_mouse
	IF dummy=2 THEN
		i=LEN(dummy$)
		DO
			IF MID$(dummy$,i,1)=">" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP
		a$=LEFT$(dummy$,i)
		b$=RIGHT$(dummy$,LEN(dummy$)-i)

		SELECT CASE a$
		CASE "<title>"
			SelectTree FORM_PAGE
			setobj_text FRM_TITLE,b$
		CASE "<alturl>"
			SelectTree FORM_PAGE
			setobj_text FRM_ALTURL,b$
		CASE "<background image?>"
			SelectTree FORM_PAGE
			setobj_shortcut FRM_IMAGE,CHR$(11)
			setobj_shortcut FRM_COLOUR,CHR$(11)
			IF b$="YES" THEN setobj_shortcut FRM_IMAGE,CHR$(12)
			IF b$="NO" THEN setobj_shortcut FRM_COLOUR,CHR$(12)
		CASE "<background image>"
			SelectTree FORM_PAGE
			table_image$=b$
			setobj_text FRM_IMAGE3,RIGHT$(b$,42)
		CASE "<background colour>"
			SelectTree FORM_PAGE
			CALL UpdateHEX (FRM_COLOUR4,b$)
			setobj_text FRM_COLOUR3,b$
		CASE "<frame 1>"
			SelectTree FORM_FRAME
			IF b$="HIDDEN" THEN include_flags FRM_FRM1,mask_hidetree
			IF b$="NOT HIDDEN" THEN remove_flags FRM_FRM1,mask_hidetree
		CASE "<frame 2>"
			SelectTree FORM_FRAME
			IF b$="HIDDEN" THEN include_flags FRM_FRM2,mask_hidetree
			IF b$="NOT HIDDEN" THEN remove_flags FRM_FRM2,mask_hidetree
		CASE "<frame 3>"
			SelectTree FORM_FRAME
			IF b$="HIDDEN" THEN include_flags FRM_FRM3,mask_hidetree
			IF b$="NOT HIDDEN" THEN remove_flags FRM_FRM3,mask_hidetree
		CASE "<frame 4>"
			SelectTree FORM_FRAME
			IF b$="HIDDEN" THEN include_flags FRM_FRM4,mask_hidetree
			IF b$="NOT HIDDEN" THEN remove_flags FRM_FRM4,mask_hidetree
		CASE "<frame 5>"
			SelectTree FORM_FRAME
			IF b$="HIDDEN" THEN include_flags FRM_FRM5,mask_hidetree
			IF b$="NOT HIDDEN" THEN remove_flags FRM_FRM5,mask_hidetree
		CASE "<frame 6>"
			SelectTree FORM_FRAME
			IF b$="HIDDEN" THEN include_flags FRM_FRM6,mask_hidetree
			IF b$="NOT HIDDEN" THEN remove_flags FRM_FRM6,mask_hidetree
		CASE "<frame 1 x>" : SelectTree FORM_FRAME : setobj_x FRM_FRM1,VAL(b$)
		CASE "<frame 1 y>" : SelectTree FORM_FRAME : setobj_y FRM_FRM1,VAL(b$)
		CASE "<frame 1 w>" : SelectTree FORM_FRAME : setobj_width FRM_FRM1,VAL(b$)
		CASE "<frame 1 h>" : SelectTree FORM_FRAME : setobj_height FRM_FRM1,VAL(b$)
		CASE "<frame 2 x>" : SelectTree FORM_FRAME : setobj_x FRM_FRM2,VAL(b$)
		CASE "<frame 2 y>" : SelectTree FORM_FRAME : setobj_y FRM_FRM2,VAL(b$)
		CASE "<frame 2 w>" : SelectTree FORM_FRAME : setobj_width FRM_FRM2,VAL(b$)
		CASE "<frame 2 h>" : SelectTree FORM_FRAME : setobj_height FRM_FRM2,VAL(b$)
		CASE "<frame 3 x>" : SelectTree FORM_FRAME : setobj_x FRM_FRM3,VAL(b$)
		CASE "<frame 3 y>" : SelectTree FORM_FRAME : setobj_y FRM_FRM3,VAL(b$)
		CASE "<frame 3 w>" : SelectTree FORM_FRAME : setobj_width FRM_FRM3,VAL(b$)
		CASE "<frame 3 h>" : SelectTree FORM_FRAME : setobj_height FRM_FRM3,VAL(b$)
		CASE "<frame 4 x>" : SelectTree FORM_FRAME : setobj_x FRM_FRM4,VAL(b$)
		CASE "<frame 4 y>" : SelectTree FORM_FRAME : setobj_y FRM_FRM4,VAL(b$)
		CASE "<frame 4 w>" : SelectTree FORM_FRAME : setobj_width FRM_FRM4,VAL(b$)
		CASE "<frame 4 h>" : SelectTree FORM_FRAME : setobj_height FRM_FRM4,VAL(b$)
		CASE "<frame 5 x>" : SelectTree FORM_FRAME : setobj_x FRM_FRM5,VAL(b$)
		CASE "<frame 5 y>" : SelectTree FORM_FRAME : setobj_y FRM_FRM5,VAL(b$)
		CASE "<frame 5 w>" : SelectTree FORM_FRAME : setobj_width FRM_FRM5,VAL(b$)
		CASE "<frame 5 h>" : SelectTree FORM_FRAME : setobj_height FRM_FRM5,VAL(b$)
		CASE "<frame 6 x>" : SelectTree FORM_FRAME : setobj_x FRM_FRM6,VAL(b$)
		CASE "<frame 6 y>" : SelectTree FORM_FRAME : setobj_y FRM_FRM6,VAL(b$)
		CASE "<frame 6 w>" : SelectTree FORM_FRAME : setobj_width FRM_FRM6,VAL(b$)
		CASE "<frame 6 h>" : SelectTree FORM_FRAME : setobj_height FRM_FRM6,VAL(b$)
		CASE "<frame 1 name>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM1,1)=b$
		CASE "<frame 1 url>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM1,2)=b$
		CASE "<frame 1 border>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM1,3)=b$
		CASE "<frame 1 marginh>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM1,4)=b$
		CASE "<frame 1 marginw>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM1,5)=b$
		CASE "<frame 1 scroll>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM1,6)="  "+b$
		CASE "<frame 2 name>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM2,1)=b$
		CASE "<frame 2 url>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM2,2)=b$
		CASE "<frame 2 border>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM2,3)=b$
		CASE "<frame 2 marginh>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM2,4)=b$
		CASE "<frame 2 marginw>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM2,5)=b$
		CASE "<frame 2 scroll>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM2,6)="  "+b$
		CASE "<frame 3 name>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM3,1)=b$
		CASE "<frame 3 url>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM3,2)=b$
		CASE "<frame 3 border>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM3,3)=b$
		CASE "<frame 3 marginh>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM3,4)=b$
		CASE "<frame 3 marginw>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM3,5)=b$
		CASE "<frame 3 scroll>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM3,6)="  "+b$
		CASE "<frame 4 name>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM4,1)=b$
		CASE "<frame 4 url>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM4,2)=b$
		CASE "<frame 4 border>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM4,3)=b$
		CASE "<frame 4 marginh>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM4,4)=b$
		CASE "<frame 4 marginw>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM4,5)=b$
		CASE "<frame 4 scroll>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM4,6)="  "+b$
		CASE "<frame 5 name>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM5,1)=b$
		CASE "<frame 5 url>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM5,2)=b$
		CASE "<frame 5 border>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM5,3)=b$
		CASE "<frame 5 marginh>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM5,4)=b$
		CASE "<frame 5 marginw>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM5,5)=b$
		CASE "<frame 5 scroll>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM5,6)="  "+b$
		CASE "<frame 6 name>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM6,1)=b$
		CASE "<frame 6 url>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM6,2)=b$
		CASE "<frame 6 border>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM6,3)=b$
		CASE "<frame 6 marginh>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM6,4)=b$
		CASE "<frame 6 marginw>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM6,5)=b$
		CASE "<frame 6 scroll>" : SelectTree FORM_FRAME : frames_array$(FRM_FRM6,6)="  "+b$
		END SELECT
	END IF
LOOP UNTIL EOF(myfile)
CLOSE #myfile
MOUSE 0
CALL init_dialog(FORM_FRAME)
frame_handle=OpenFormWindow(MyProgram$,FORM_FRAME,FRM_NAME,0,VARPTRS(closeFORM_FRAME))
SelectTree FORM_FRAME : CALL Redraw_Object (0)
CALL init_dialog(FORM_PAGE)
page_handle=OpenFormWindow(MyProgram$,FORM_PAGE,FRM_TITLE,FRM_CANCEL,VARPTRS(closeFORM_PAGE))
SelectTree FORM_PAGE : CALL Redraw_Object (0)
END SUB

'===============================================================================

SUB SaveFrame(BYVAL savefile$)
SHARED fspath$,fsmessage$,fsname$,SaveAs$,current_wizard$,DeselectFRM$
SHARED cols_array(2),rows_array(2),percent(2),gen_start,current_path$,table_image$
STATIC dummy$,dummy,myfile,x,y,w,h

SelectTree FORM_FRAME
IF NOT enquire_flags(FRM_PROPERTIES,mask_hidetree) THEN
	junk=form_alert(1,DeselectFRM$) : EXIT SUB
END IF

IF savefile$="" THEN
	fspath$=CURDIR$+"\*.HTM" : fsmessage$=SaveAs$ : fsname$=""
	dummy$=FileSelect$ (fsname$,2) : IF fsname$="" THEN EXIT SUB
	current_wizard$=dummy$
ELSE
	current_wizard$=savefile$
END IF
dummy=LEN(current_wizard$)
DO
	IF MID$(current_wizard$,dummy,1)="." THEN EXIT LOOP
	IF MID$(current_wizard$,dummy,1)="\" THEN dummy=1 : EXIT LOOP
	IF dummy=1 THEN EXIT LOOP
	DECR dummy
LOOP
IF dummy=1 THEN
	current_wizard$=current_wizard$+".HTM"
ELSE
	current_wizard$=LEFT$(current_wizard$,dummy-1)+".HTM"
END IF

myfile=FREEFILE
OPEN LEFT$(current_wizard$,LEN(current_wizard$)-3)+"FRM" FOR OUTPUT AS #myfile
	CALL update_mouse
	PRINT #myfile,"<Frame.Wizard>"
	PRINT #myfile,"<begin>"
	SelectTree FORM_PAGE
	CALL update_mouse
	PRINT #myfile,"<title>"+getobj_text$(FRM_TITLE)
	PRINT #myfile,"<alturl>"+getobj_text$(FRM_ALTURL)
	IF getobj_shortcut(FRM_IMAGE)=11 THEN PRINT #myfile,"<background image?>NO"
	IF getobj_shortcut(FRM_IMAGE)=12 THEN PRINT #myfile,"<background image?>YES"
	PRINT #myfile,"<background image>"+table_image$
	PRINT #myfile,"<background colour>"+getobj_text$(FRM_COLOUR3)
	CALL update_mouse
	SelectTree FORM_FRAME
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		CALL update_mouse
		IF enquire_flags(dummy,mask_hidetree) THEN
			PRINT #myfile,"<frame"+STR$(dummy-1)+">HIDDEN"
		ELSE
			PRINT #myfile,"<frame"+STR$(dummy-1)+">NOT HIDDEN"
			PRINT #myfile,"<frame"+STR$(dummy-1)+" x>"+LTRIM$(STR$(getobj_x(dummy)))
			PRINT #myfile,"<frame"+STR$(dummy-1)+" y>"+LTRIM$(STR$(getobj_y(dummy)))
			PRINT #myfile,"<frame"+STR$(dummy-1)+" w>"+LTRIM$(STR$(getobj_width(dummy)))
			PRINT #myfile,"<frame"+STR$(dummy-1)+" h>"+LTRIM$(STR$(getobj_height(dummy)))
			CALL update_mouse
			PRINT #myfile,"<frame"+STR$(dummy-1)+" name>"+frames_array$(dummy,1)
			PRINT #myfile,"<frame"+STR$(dummy-1)+" url>"+frames_array$(dummy,2)
			PRINT #myfile,"<frame"+STR$(dummy-1)+" border>"+frames_array$(dummy,3)
			PRINT #myfile,"<frame"+STR$(dummy-1)+" marginh>"+frames_array$(dummy,4)
			PRINT #myfile,"<frame"+STR$(dummy-1)+" marginw>"+frames_array$(dummy,5)
			PRINT #myfile,"<frame"+STR$(dummy-1)+" scroll>"+LTRIM$(frames_array$(dummy,6))
			CALL update_mouse
		END IF
	NEXT dummy
	PRINT #myfile,"<end>"
CLOSE #myfile
FOR dummy=FRM_FRM1 TO FRM_FRM6
	getobj_xywh dummy,x,y,w,h
	setobj_xywh dummy,x,y,w-1,h-1
NEXT dummy

dummy=LEN(current_wizard$)
DO
	IF MID$(current_wizard$,dummy,1)="\" THEN EXIT LOOP
	IF dummy=1 THEN EXIT LOOP
	DECR dummy
LOOP
current_path$=LEFT$(current_wizard$,dummy)

myfile=FREEFILE
OPEN current_wizard$ FOR OUTPUT AS #myfile
	CALL update_mouse
	SelectTree FORM_PAGE
	PRINT #myfile,"<!DOCTYPE HTML PUBLIC "+CHR$(34)+"-//W3C//DTD HTML 3.2 Draft//EN"+CHR$(34)+">"
	PRINT #myfile,"<!-- This page was created using Frame.Wizard v3.10 -->"
	PRINT #myfile,"<!-- Copyright 1997-1999 Cadenza Software - http://www.cadenza.cyberstrider.org -->"
	PRINT #myfile,"<HTML>"
	PRINT #myfile,"<HEAD>"
	PRINT #myfile,CHR$(9)+"<TITLE>"+getobj_text$(FRM_TITLE)+"</TITLE>"
	PRINT #myfile,"</HEAD>"
		SelectTree FORM_FRAME
		DIM cols(20,20),rows(20,20),percent(20,20)
		gen_start=0 : CALL x_frame(0,0,240,180,myfile)
		ERASE cols,rows,percent
	PRINT #myfile,"</HTML>"
	CALL update_mouse
CLOSE #myfile
FOR dummy=FRM_FRM1 TO FRM_FRM6
	getobj_xywh dummy,x,y,w,h
	setobj_xywh dummy,x,y,w+1,h+1
NEXT dummy
MOUSE 0
END SUB

'===============================================================================

SUB x_frame(BYVAL x,BYVAL y,BYVAL w,BYVAL h,myfile)
SHARED cols(2),percent(2),gen_start,current_path$,table_image$
STATIC x1,y1,w1,h1,object,dummy,dummy$,x2,y2,w2,h2
STATIC pagex,pagey,pagew,pageh,dummy2$,i,path$,image$
LOCAL dummy2,total_cols,px,py,pw,ph

pagex=x : pagey=y : pagew=w : pageh=h
SelectTree FORM_FRAME : junk=objc_offset(tree&,FRAME_BACK,x2,y2)
w=pagew-x : h=pageh-y : x=pagex+x2 : y=pagey+y2 : INCR gen_start : total_cols=0
FOR x1=x+1 TO x+w
	object=objc_find(tree&,FRAME_BACK,100,x1,y+1)
	IF object=FRAME_BACK THEN
		FOR y1=y+1 TO y+h
			object=objc_find(tree&,FRAME_BACK,100,x1,y1)
			IF y1=y+h THEN
				cols(gen_start,0)=pagex
				INCR total_cols : cols(gen_start,total_cols)=x1-x2+1
				percent(gen_start,total_cols)=((cols(gen_start,total_cols)-cols(gen_start,total_cols-1))/w)*100
				IF percent(gen_start,total_cols)>100 THEN percent(gen_start,total_cols)=percent(gen_start,total_cols)-100
				EXIT FOR
			END IF
			IF object<>FRAME_BACK THEN EXIT FOR
		NEXT y1
	END IF
NEXT x1
x=pagex : y=pagey : w=pagew : h=pageh

IF percent(gen_start,1)=0 THEN total_cols=1
IF total_cols=1 THEN
	IF gen_start=1 THEN
		PRINT #myfile,"<FRAMESET COLS="+CHR$(34)+"100%"+CHR$(34)+">"
		px=cols(gen_start,0)
		py=y
		pw=cols(gen_start,1)
		ph=h
		CALL y_frame(px,py,pw,ph,myfile)
	ELSE
		FOR dummy=FRM_FRM1 TO FRM_FRM6
			getobj_xywh dummy,x2,y2,w2,h2
			IF ((x=x2) AND (w=x2+w2+1) AND (h=y2+h2+1)) THEN
			IF NOT enquire_flags(dummy,mask_hidetree) THEN
				dummy$="<FRAME "
				IF frames_array$(dummy,3)="YES" THEN
					dummy$=dummy$+"FRAMEBORDER=1 "
				ELSE
					dummy$=dummy$+"FRAMEBORDER=0 "
				END IF
				dummy$=dummy$+"MARGINHEIGHT="+frames_array$(dummy,4)+" "
				dummy$=dummy$+"MARGINWIDTH="+frames_array$(dummy,5)+" "
				dummy$=dummy$+"NAME="+CHR$(34)+frames_array$(dummy,1)+CHR$(34)+" "
				IF LTRIM$(frames_array$(dummy,6))=getobj_poptext$(FORM_POPUPS,POP_SCROLL+2) THEN
					dummy$=dummy$+"SCROLLING="+CHR$(34)+"YES"+CHR$(34)+" "
				END IF
				IF LTRIM$(frames_array$(dummy,6))=getobj_poptext$(FORM_POPUPS,POP_SCROLL+3) THEN
					dummy$=dummy$+"SCROLLING="+CHR$(34)+"NO"+CHR$(34)+" "
				END IF
				IF LTRIM$(frames_array$(dummy,6))=getobj_poptext$(FORM_POPUPS,POP_SCROLL+1) THEN
					dummy$=dummy$+"SCROLLING="+CHR$(34)+"AUTO"+CHR$(34)+" "
				END IF

				IF UCASE$(LEFT$(frames_array$(dummy,2),4))<>"HTTP" THEN
					IF frames_array$(dummy,2)<>"" THEN
						i=LEN(frames_array$(dummy,2))
						DO
							IF MID$(frames_array$(dummy,2),i,1)="\" THEN EXIT LOOP
							IF i=1 THEN i=0 : EXIT LOOP
							DECR i
						LOOP
						dummy2$=RIGHT$(frames_array$(dummy,2),LEN(frames_array$(dummy,2))-i)
						IF FEXISTS(frames_array$(dummy,2)) THEN
							junk=CopyFile (frames_array$(dummy,2),current_path$+dummy2$,1)
							CALL update_mouse
						END IF
						dummy$=dummy$+"SRC="+CHR$(34)+LCASE$(dummy2$)+CHR$(34)+">"
					ELSE
						dummy$=dummy$+"SRC="+CHR$(34)+CHR$(34)+">"
					END IF
				ELSE
					dummy$=dummy$+"SRC="+CHR$(34)+LCASE$(frames_array$(dummy,2))+CHR$(34)+">"
				END IF

				PRINT #myfile,dummy$
			END IF
			END IF
		NEXT dummy
	END IF
ELSE
	dummy$="<FRAMESET COLS="+CHR$(34)+LTRIM$(STR$(percent(gen_start,1)))+"%"
	IF total_cols>1 THEN
		FOR dummy=2 TO total_cols
			dummy$=dummy$+","+LTRIM$(STR$(percent(gen_start,dummy)))+"%"
		NEXT dummy
	END IF
	PRINT #myfile,dummy$+CHR$(34)+">"

	IF total_cols>1 THEN
		FOR dummy2=0 TO total_cols-1
			px=cols(gen_start,dummy2)
			py=y
			pw=cols(gen_start,dummy2+1)
			ph=h
			CALL y_frame(px,py,pw,ph,myfile)
		NEXT dummy2
	END IF
	PRINT #myfile,"</FRAMESET>"
END IF
IF gen_start=1 THEN
	SelectTree FORM_PAGE
	PRINT #myfile,"<NOFRAMES>"
	IF getobj_shortcut(FRM_IMAGE)=12 THEN
		image$=table_image$
		IF image$<>"" THEN
			dummy=LEN(image$)
			DO
				IF MID$(image$,dummy,1)="\" THEN EXIT LOOP
				IF dummy=1 THEN EXIT LOOP
				DECR dummy
			LOOP
			image$=RIGHT$(image$,LEN(image$)-dummy)
			PRINT #myfile,"<BODY BACKGROUND="+CHR$(34)+LCASE$(image$)+CHR$(34)+">"

			IF FEXISTS(table_image$) THEN
				dummy=LEN(table_image$)
				DO
					IF MID$(table_image$,dummy,1)="\" THEN EXIT LOOP
					IF dummy=1 THEN EXIT LOOP
					DECR dummy
				LOOP
				path$=LEFT$(table_image$,dummy)

				IF table_image$<>path$+image$ THEN
					junk=CopyFile (table_image$,path$+image$,1)
					CALL update_mouse
				END IF
			END IF
		ELSE
			PRINT #myfile,"<BODY>"
		END IF
	ELSE
		PRINT #myfile,"<BODY BGCOLOR="+CHR$(34)+"#"+getobj_text$(FRM_COLOUR3)+CHR$(34)+">"
	END IF
	PRINT #myfile,"Unfortunately, your browser is not capable of displaying frames."

	IF UCASE$(LEFT$(getobj_text$(FRM_ALTURL),4))<>"HTTP" THEN
		IF getobj_text$(FRM_ALTURL)<>"" THEN
			i=LEN(getobj_text$(FRM_ALTURL))
			DO
				IF MID$(getobj_text$(FRM_ALTURL),i,1)="\" THEN EXIT LOOP
				IF i=1 THEN i=0 : EXIT LOOP
				DECR i
			LOOP
			dummy2$=RIGHT$(getobj_text$(FRM_ALTURL),LEN(getobj_text$(FRM_ALTURL))-i)
			IF FEXISTS(getobj_text$(FRM_ALTURL)) THEN
				junk=CopyFile (getobj_text$(FRM_ALTURL),current_path$+dummy2$,1)
				CALL update_mouse
			END IF
			PRINT #myfile,"Click <A HREF="+CHR$(34)+LCASE$(dummy2$)+CHR$(34)+">here</A> to view a frame-free alternative."
		ELSE
			PRINT #myfile,"Click <A HREF="+CHR$(34)+LCASE$(getobj_text$(FRM_ALTURL))+CHR$(34)+">here</A> to view a frame-free alternative."
		END IF
	ELSE
		PRINT #myfile,"Click <A HREF="+CHR$(34)+LCASE$(getobj_text$(FRM_ALTURL))+CHR$(34)+">here</A> to view a frame-free alternative."
	END IF

	PRINT #myfile,"<P>Thank you."
	PRINT #myfile,"</BODY>"
	PRINT #myfile,"</NOFRAMES>"
	PRINT #myfile,"</FRAMESET>"
	SelectTree FORM_FRAME
END IF
DECR gen_start
END SUB

'===============================================================================

SUB y_frame(BYVAL x,BYVAL y,BYVAL w,BYVAL h,myfile)
SHARED rows(2),percent(2),gen_start,current_path$
STATIC x1,y1,w1,h1,object,dummy,dummy$,x2,y2,w2,h2
STATIC pagex,pagey,pagew,pageh,dummy2$,i
LOCAL dummy2,total_rows,px,py,pw,ph

pagex=x : pagey=y : pagew=w : pageh=h
SelectTree FORM_FRAME : junk=objc_offset(tree&,FRAME_BACK,x2,y2)
w=pagew-x : h=pageh-y : x=pagex+x2 : y=pagey+y2 : INCR gen_start : total_rows=0
FOR y1=y+1 TO y+h
	object=objc_find(tree&,FRAME_BACK,100,x+1,y1)
	IF object=FRAME_BACK THEN
		FOR x1=x+1 TO x+w
			object=objc_find(tree&,FRAME_BACK,100,x1,y1)
			IF x1=x+w THEN
				rows(gen_start,0)=pagey
				INCR total_rows : rows(gen_start,total_rows)=y1-y2+1
				percent(gen_start,total_rows)=((rows(gen_start,total_rows)-rows(gen_start,total_rows-1))/h)*100
				IF percent(gen_start,total_rows)>100 THEN percent(gen_start,total_rows)=percent(gen_start,total_rows)-100
				EXIT FOR
			END IF
			IF object<>FRAME_BACK THEN EXIT FOR
		NEXT x1
	END IF
NEXT y1
x=pagex : y=pagey : w=pagew : h=pageh

IF percent(gen_start,1)=0 THEN total_rows=1
IF total_rows=1 THEN
	IF gen_start=2 THEN PRINT #myfile,"<FRAMESET ROWS="+CHR$(34)+"100%"+CHR$(34)+">"
	FOR dummy=FRM_FRM1 TO FRM_FRM6
		getobj_xywh dummy,x2,y2,w2,h2
		IF ((y=y2) AND (w=x2+w2+1) AND (h=y2+h2+1)) THEN
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			dummy$="<FRAME "
			IF frames_array$(dummy,3)="YES" THEN
				dummy$=dummy$+"FRAMEBORDER=1 "
			ELSE
				dummy$=dummy$+"FRAMEBORDER=0 "
			END IF
			dummy$=dummy$+"MARGINHEIGHT="+frames_array$(dummy,4)+" "
			dummy$=dummy$+"MARGINWIDTH="+frames_array$(dummy,5)+" "
			dummy$=dummy$+"NAME="+CHR$(34)+frames_array$(dummy,1)+CHR$(34)+" "
			IF LTRIM$(frames_array$(dummy,6))="Yes" THEN
				dummy$=dummy$+"SCROLLING="+CHR$(34)+"YES"+CHR$(34)+" "
			END IF
			IF LTRIM$(frames_array$(dummy,6))="No" THEN
				dummy$=dummy$+"SCROLLING="+CHR$(34)+"NO"+CHR$(34)+" "
			END IF
			IF LTRIM$(frames_array$(dummy,6))="Automatically" THEN
				dummy$=dummy$+"SCROLLING="+CHR$(34)+"AUTO"+CHR$(34)+" "
			END IF

			IF UCASE$(LEFT$(frames_array$(dummy,2),4))<>"HTTP" THEN
				IF frames_array$(dummy,2)<>"" THEN
					i=LEN(frames_array$(dummy,2))
					DO
						IF MID$(frames_array$(dummy,2),i,1)="\" THEN EXIT LOOP
						IF i=1 THEN i=0 : EXIT LOOP
						DECR i
					LOOP
					dummy2$=RIGHT$(frames_array$(dummy,2),LEN(frames_array$(dummy,2))-i)
					IF FEXISTS(frames_array$(dummy,2)) THEN
						junk=CopyFile (frames_array$(dummy,2),current_path$+dummy2$,1)
						CALL update_mouse
					END IF
					dummy$=dummy$+"SRC="+CHR$(34)+LCASE$(dummy2$)+CHR$(34)+">"
				ELSE
					dummy$=dummy$+"SRC="+CHR$(34)+CHR$(34)+">"
				END IF
			ELSE
				dummy$=dummy$+"SRC="+CHR$(34)+LCASE$(frames_array$(dummy,2))+CHR$(34)+">"
			END IF

			PRINT #myfile,dummy$
		END IF
		END IF
	NEXT dummy
	IF gen_start=2 THEN PRINT #myfile,"</FRAMESET>"
ELSE
	dummy$="<FRAMESET ROWS="+CHR$(34)+LTRIM$(STR$(percent(gen_start,1)))+"%"
	IF total_rows>1 THEN
		FOR dummy=2 TO total_rows
			dummy$=dummy$+","+LTRIM$(STR$(percent(gen_start,dummy)))+"%"
		NEXT dummy
	END IF
	PRINT #myfile,dummy$+CHR$(34)+">"

	IF total_rows>1 THEN
		FOR dummy2=0 TO total_rows-1
			px=x
			py=rows(gen_start,dummy2)
			pw=w
			ph=rows(gen_start,dummy2+1)
			CALL x_frame(px,py,pw,ph,myfile)
		NEXT dummy2
	END IF
	PRINT #myfile,"</FRAMESET>"
END IF
DECR gen_start
END SUB

'===============================================================================
'[END OF FILE]

'junk=form_alert(1,"[1][  "+STR$()+" ][ Abort ]")
