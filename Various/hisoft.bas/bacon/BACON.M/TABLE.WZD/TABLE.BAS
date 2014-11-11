'===============================================================================
' Table.Wizard v3.10 - Copyright ½ 1997-1999 Matthew Bacon
'===============================================================================

DEFINT a-z

'>>Include files<<
REM $include F:\cadenza\webwizrd.31\table.wzd\table.bh
REM $include F:\enchant\modules\error.bas
REM $include F:\cadenza\webwizrd.31\toolbx_a.bas
REM $include F:\enchant\modules\bubble.bas
REM $include F:\enchant\modules\cursor.bas
REM $include F:\enchant\modules\file.bas
REM $include F:\enchant\modules\protocol.bas
REM $include F:\enchant\modules\st-guide.bas

'===============================================================================

DIM SHARED LANGUAGE$(100)
DIM cell$(15),tablecells$(145)

'>>Global variables<<
MyProgram$="Table.Wizard"
reset_dialog=-1
hook_enabled=0
hook_timeout=1000
HowManyButtons=2
loadtbl$=COMMAND$

'>>Import language file<<
CALL import_language
'>>Start<<
CALL StartProgram (CURDIR$+"\TABLE.RSC",FORM_MENU,0,FORM_ICONIFY)

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
CALL init_FORMs
reset_dialog=0

junk=xdialog (FORM_ABOUT,0,0,1,0)
IF loadtbl$<>"" THEN CALL OpenTable (CURDIR$+"\"+loadtbl$)
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
		IF button=1 THEN CALL OpenTable (message$)
	END IF
END SELECT
END SUB

SUB HandleUserHook
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)

SELECT CASE key_pressed
CASE 25088 : junk=STGuide (CURDIR$+"\TABLE.HYP","CONTENTS")
END SELECT
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB

SUB	HandleUserMenu (cur_front,item,title)
SHARED table_handle,cell_handle,AreYouSure$,current_wizard$,commonobj
STATIC button

SelectTree FORM_MENU
SELECT CASE item
CASE MENU_ABOUT : junk=xdialog (FORM_ABOUT,0,0,1,0)
CASE MENU_NEW
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN
		CALL init_FORMs
		table_handle=OpenFormWindow(MyProgram$,FORM_TABLE,TBL_HEADER,0,VARPTRS(closeFORM_TABLE))
	END IF
CASE MENU_OPEN
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN CALL OpenTable ("")
CASE MENU_SAVE : CALL SaveTable(current_wizard$)
CASE MENU_SAVEAS : CALL SaveTable("")
CASE MENU_EXPORT : CALL ExportTable
CASE MENU_QUIT
	button=form_alert(2,AreYouSure$)
	IF button=1 THEN Finished_Flag=-1
	IF button=2 THEN Finished_Flag=0
	CommonObj=0
CASE MENU_TABLEPROP
	table_handle=OpenFormWindow(MyProgram$,FORM_TABLE,TBL_HEADER,0,VARPTRS(closeFORM_TABLE))
CASE MENU_CELLPROP
	cell_handle=OpenFormWindow(MyProgram$,FORM_CELL,CELL_TEXT1,0,VARPTRS(closeFORM_CELL))
CASE MENU_ABOUTHELP : junk=STGuide (CURDIR$+"\TABLE.HYP","About Help...")
CASE MENU_HELP : junk=STGuide (CURDIR$+"\TABLE.HYP","CONTENTS")
CASE MENU_CYBER : junk=STGuide (CURDIR$+"\TABLE.HYP","CONTACT CYBERSTRIDER")
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
IF FEXISTS(CURDIR$+"\TABLE.LNG") THEN
	myfile=FREEFILE
	OPEN CURDIR$+"\TABLE.LNG" FOR INPUT AS #myfile
	DO
		LINE INPUT #myfile,dummy$
		IF dummy$<>"" THEN
			IF LEFT$(dummy$,1)<>";" THEN LANGUAGE$(dummy)=dummy$ : INCR dummy
			IF dummy=UBOUND(LANGUAGE$) THEN
				junk=form_alert(1,"[1][  "+MyProgram$+": |  Error in TABLE.LNG ][Abort]")
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
	junk=form_alert(1,"[1][  "+MyProgram$+": |  TABLE.LNG not found! ][Abort]")
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
setobj_text ABOUT_TEXT1,LANGUAGE$(40)		'>>Author<<
setobj_text ABOUT_TEXT2,LANGUAGE$(41)		'>>Distribution<<
setobj_text ABOUT_TEXT3,LANGUAGE$(42)		'>>Language<<
setobj_text ABOUT_LANGUAGE,LANGUAGE$(0)
setobj_text ABOUT_TEXT4,LANGUAGE$(43)		'>>Translation<<
setobj_text ABOUT_TRANSLATOR,LANGUAGE$(1)	'>>Translator<<
setobj_text ABOUT_TEXT5,LANGUAGE$(44)		'>>Key Code<<
setobj_text ABOUT_KEYCODE,keycode$
setobj_text ABOUT_TEXT6,LANGUAGE$(45)		'>>Registered to<<
setobj_text ABOUT_USER,user$
setobj_spec_str ABOUT_OK,LANGUAGE$(46)		'>>OK<<
END SUB

'===============================================================================

SUB init_MENUBAR
STATIC cellx,dummy

junk=graf_handle(cellx,junk,junk,junk)
SelectTree FORM_MENU
setobj_spec_str MENU_PROGRAM," "+LANGUAGE$(2)		'>>Table.Wizard<<
setobj_spec_str MENU_ABOUT,"  "+LANGUAGE$(3)		'>>Information...<<
setobj_spec_str MENU_FILE," "+LANGUAGE$(4)			'>>File<<
setobj_spec_str MENU_NEW,"  "+LANGUAGE$(5)			'>>New ^N<<
setobj_spec_str MENU_OPEN,"  "+LANGUAGE$(6)		'>>Open *.TBL ^O<<
setobj_spec_str MENU_SAVE,"  "+LANGUAGE$(7)			'>>Save ^S<<
setobj_spec_str MENU_SAVEAS,"  "+LANGUAGE$(8)		'>>Save As..<<
setobj_spec_str MENU_EXPORT,"  "+LANGUAGE$(9)		'>>Export..<<
setobj_spec_str MENU_QUIT,"  "+LANGUAGE$(10)		'>>Quit ^Q<<

setobj_spec_str MENU_WINDOW," "+LANGUAGE$(11)		'>>Window<<
setobj_spec_str MENU_TABLEPROP,"  "+LANGUAGE$(12)	'>>Table Properties<<
setobj_spec_str MENU_CELLPROP,"  "+LANGUAGE$(13)	'>>Cell Properties<<

setobj_spec_str MENU_THELP," "+LANGUAGE$(14)		'>>Help<<
setobj_spec_str MENU_ABOUTHELP,"  "+LANGUAGE$(15)	'>>About Help...<<
setobj_spec_str MENU_HELP,"  "+LANGUAGE$(16)		'>>Help  [HELP]<<
setobj_spec_str MENU_CYBER,"  "+LANGUAGE$(17)		'>>CyberSTrider<<


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
setobj_x MENU_TABLEPROP-1,dummy+(2*cellx)
setobj_width MENU_TABLEPROP-1,cellx*(LEN(getobj_spec$(MENU_TABLEPROP))+1)
FOR dummy=MENU_TABLEPROP TO MENU_CELLPROP
	setobj_width dummy,cellx*(LEN(getobj_spec$(MENU_TABLEPROP))+1)
	setobj_spec_str dummy,LEFT$(getobj_spec$(dummy),LEN(getobj_spec$(MENU_TABLEPROP))+1)
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

SUB init_MAIN
SelectTree FORM_TABLE
setobj_spec_str TBL_THEADER,LANGUAGE$(18)		'>>Header<<
setobj_spec_str TBL_TFOOTER,LANGUAGE$(19)		'>>Footer<<
setobj_spec_str TBL_TALIGN,LANGUAGE$(20)		'>>Align<<
setobj_spec_str TBL_FLOW2," "+LANGUAGE$(21)		'>>Text flow...<<
setobj_spec_str TBL_TBORDER,LANGUAGE$(22)		'>>Border<<
setobj_spec_str TBL_PIXEL1,LANGUAGE$(23)		'>>pixels<<
setobj_spec_str TBL_PIXEL2,LANGUAGE$(23)		'>>pixels<<
setobj_spec_str TBL_PIXEL3,LANGUAGE$(23)		'>>pixels<<
setobj_spec_str TBL_TCELLPAD,LANGUAGE$(24)		'>>Cellpadding<<
setobj_spec_str TBL_TCELLSPAC,LANGUAGE$(25)		'>>Cellspacing<<
setobj_spec_str TBL_TWIDTH,LANGUAGE$(26)		'>>Width<<
setobj_spec_str TBL_PIXELS2," "+LANGUAGE$(23)	'>>pixels<<
setobj_spec_str TBL_OK,LANGUAGE$(27)			'>>OK<<
setobj_spec_str TBL_CANCEL,LANGUAGE$(28)		'>>Cancel<<

SelectTree FORM_CELL
setobj_text CELL_TCOLS,LANGUAGE$(29)		'>>Columns:<<
setobj_text CELL_TROWS,LANGUAGE$(30)		'>>Rows:<<
setobj_spec_str CELL_TCOLOUR,LANGUAGE$(31)		'>>Colour:<<
setobj_spec_str CELL_TALIGN,LANGUAGE$(32)		'>>Align:<<
setobj_spec_str CELL_NOWRAP2," "+LANGUAGE$(33)		'>>No wrap<<
setobj_spec_str CELL_TVALIGN,LANGUAGE$(34)		'>>Valign:<<
setobj_spec_str CELL_BIMAGE2," "+LANGUAGE$(35)		'>>Image<<
setobj_spec_str TBL_SELECTCELL,LANGUAGE$(36)	'>>Select a cell<<
setobj_spec_str CELL_CUTX,LANGUAGE$(37)			'>>Cut X<<
setobj_spec_str CELL_CUTY,LANGUAGE$(38)			'>>Cut X<<
setobj_spec_str CELL_GLUE,LANGUAGE$(39)			'>>Glue<<
END SUB

'===============================================================================

SUB init_POPUPS
SelectTree FORM_POPUPS
setobj_spec_str P_COL1," "+LANGUAGE$(47)		'>>White<<
setobj_spec_str P_COL2," "+LANGUAGE$(48)		'>>Black<<
setobj_spec_str P_COL3," "+LANGUAGE$(49)		'>>Red<<
setobj_spec_str P_COL4," "+LANGUAGE$(50)		'>>Green<<
setobj_spec_str P_COL5," "+LANGUAGE$(51)		'>>Blue<<
setobj_spec_str P_COL6," "+LANGUAGE$(52)		'>>Cyan<<
setobj_spec_str P_COL7," "+LANGUAGE$(53)		'>>Yellow<<
setobj_spec_str P_COL8," "+LANGUAGE$(54)		'>>Magenta<<
setobj_spec_str P_COL9," "+LANGUAGE$(55)		'>>Light grey<<
setobj_spec_str P_COL10," "+LANGUAGE$(56)		'>>Dark grey<<
setobj_spec_str P_COL11," "+LANGUAGE$(57)		'>>Dark red<<
setobj_spec_str P_COL12," "+LANGUAGE$(58)		'>>Dark green<<
setobj_spec_str P_COL13," "+LANGUAGE$(59)		'>>Dark blue<<
setobj_spec_str P_COL14," "+LANGUAGE$(60)		'>>Dark cyan<<
setobj_spec_str P_COL15," "+LANGUAGE$(61)		'>>Dark yellow<<
setobj_spec_str P_COL16," "+LANGUAGE$(62)		'>>Dark magenta<<
setobj_spec_str P_COLOTHER,"  "+LANGUAGE$(63)	'>>Other<<
END SUB

'===============================================================================

SUB init_COLOURS
SelectTree FORM_COLOURS
setobj_text RGB_RED,LANGUAGE$(64)			'>>Red<<
setobj_text RGB_GREEN,LANGUAGE$(65)		'>>Green<<
setobj_text RGB_BLUE,LANGUAGE$(66)			'>>Blue<<
setobj_spec_str COL_OK,LANGUAGE$(67)		'>>OK<<
setobj_spec_str COL_CANCEL,LANGUAGE$(68)	'>>Cancel<<
END SUB

'===============================================================================

SUB init_INSTALL
SelectTree FORM_INSTALL
setobj_spec_str INSTALL_WW,LANGUAGE$(69)	'>>Install WebPage.Wizard<<
setobj_text INSTALL_USER,LANGUAGE$(70)		'>>User<<
setobj_text INSTALL_KEY,LANGUAGE$(71)		'>>Key Code<<
setobj_spec_str INSTALL_OK,LANGUAGE$(72)	'>>OK<<
END SUB

'===============================================================================

SUB init_STRINGS
SHARED ChooseFile$,AreYouSure$,SaveAs$,CopyComplete$,noINF$,corruptINF$
SHARED Deselectcell$,stopglue$
SHARED NotComplete$,KeyIncorrect$

ChooseFile$=LANGUAGE$(73)
SaveAs$=LANGUAGE$(74)
AreYouSure$=LANGUAGE$(75)
CopyComplete$=LANGUAGE$(76)
noINF$=LANGUAGE$(77)
corruptINF$=LANGUAGE$(78)
NotComplete$=LANGUAGE$(79)
KeyIncorrect$=LANGUAGE$(80)
Deselectcell$=LANGUAGE$(81)
stopglue$=LANGUAGE$(82)
END SUB

'===============================================================================

SUB init_BUBBLEHELP
SHARED BUB_JUSTHEADER$,BUB_JUSTFOOTER$,BUB_JUSTTABLE$,BUB_FLOW$,BUB_BORDER$
SHARED BUB_CELLPADDING$,BUB_CELLSPACING$,BUB_WIDTH$,BUB_CELL$,BUB_CUTX$
SHARED BUB_CUTY$,BUB_GLUE$,BUB_COLUMN$,BUB_ROW$,BUB_BACKIMG$

BUB_JUSTHEADER$=LANGUAGE$(83)
BUB_JUSTFOOTER$=LANGUAGE$(84)
BUB_JUSTTABLE$=LANGUAGE$(85)
BUB_FLOW$=LANGUAGE$(86)
BUB_BORDER$=LANGUAGE$(87)
BUB_CELLPADDING$=LANGUAGE$(88)
BUB_CELLSPACING$=LANGUAGE$(89)
BUB_WIDTH$=LANGUAGE$(90)
BUB_CELL$=LANGUAGE$(91)
BUB_CUTX$=LANGUAGE$(92)
BUB_CUTY$=LANGUAGE$(93)
BUB_GLUE$=LANGUAGE$(94)
BUB_COLUMN$=LANGUAGE$(95)
BUB_ROW$=LANGUAGE$(96)
BUB_BACKIMG$=LANGUAGE$(97)
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

SELECT CASE dummy$
	CASE==LANGUAGE$(47) : setobj_text object,"FFFFFF"
	CASE==LANGUAGE$(48) : setobj_text object,"000000"
	CASE==LANGUAGE$(49) : setobj_text object,"FF0000"
	CASE==LANGUAGE$(50) : setobj_text object,"00FF00"
	CASE==LANGUAGE$(51) : setobj_text object,"0000FF"
	CASE==LANGUAGE$(52) : setobj_text object,"00FFFF"
	CASE==LANGUAGE$(53) : setobj_text object,"FFFF00"
	CASE==LANGUAGE$(54) : setobj_text object,"FF00FF"
	CASE==LANGUAGE$(55) : setobj_text object,"C0C0C0"
	CASE==LANGUAGE$(56) : setobj_text object,"808080"
	CASE==LANGUAGE$(57) : setobj_text object,"880000"
	CASE==LANGUAGE$(58) : setobj_text object,"008800"
	CASE==LANGUAGE$(59) : setobj_text object,"000088"
	CASE==LANGUAGE$(60) : setobj_text object,"008888"
	CASE==LANGUAGE$(61) : setobj_text object,"888800"
	CASE==LANGUAGE$(62) : setobj_text object,"880088"
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

SUB UpdateHEX (BYVAL object,BYVAL dummy$)
SELECT CASE dummy$
CASE="FFFFFF" : setobj_poptext object,"  "+LANGUAGE$(47)
CASE="000000" : setobj_poptext object,"  "+LANGUAGE$(48)
CASE="FF0000" : setobj_poptext object,"  "+LANGUAGE$(49)
CASE="00FF00" : setobj_poptext object,"  "+LANGUAGE$(50)
CASE="0000FF" : setobj_poptext object,"  "+LANGUAGE$(51)
CASE="00FFFF" : setobj_poptext object,"  "+LANGUAGE$(52)
CASE="FFFF00" : setobj_poptext object,"  "+LANGUAGE$(53)
CASE="FF00FF" : setobj_poptext object,"  "+LANGUAGE$(54)
CASE="C0C0C0" : setobj_poptext object,"  "+LANGUAGE$(55)
CASE="808080" : setobj_poptext object,"  "+LANGUAGE$(56)
CASE="880000" : setobj_poptext object,"  "+LANGUAGE$(57)
CASE="008800" : setobj_poptext object,"  "+LANGUAGE$(58)
CASE="000088" : setobj_poptext object,"  "+LANGUAGE$(59)
CASE="008888" : setobj_poptext object,"  "+LANGUAGE$(60)
CASE="888800" : setobj_poptext object,"  "+LANGUAGE$(61)
CASE="880088" : setobj_poptext object,"  "+LANGUAGE$(62)
CASE ELSE : setobj_poptext object,"  "+LANGUAGE$(63)
END SELECT
END SUB

'===============================================================================

FUNCTION TranslateHEX$ (BYVAL dummy$)
SELECT CASE dummy$
CASE="FFFFFF" : TranslateHEX$=LANGUAGE$(47)
CASE="000000" : TranslateHEX$=LANGUAGE$(48)
CASE="FF0000" : TranslateHEX$=LANGUAGE$(49)
CASE="00FF00" : TranslateHEX$=LANGUAGE$(50)
CASE="0000FF" : TranslateHEX$=LANGUAGE$(51)
CASE="00FFFF" : TranslateHEX$=LANGUAGE$(52)
CASE="FFFF00" : TranslateHEX$=LANGUAGE$(53)
CASE="FF00FF" : TranslateHEX$=LANGUAGE$(54)
CASE="C0C0C0" : TranslateHEX$=LANGUAGE$(55)
CASE="808080" : TranslateHEX$=LANGUAGE$(56)
CASE="880000" : TranslateHEX$=LANGUAGE$(57)
CASE="008800" : TranslateHEX$=LANGUAGE$(58)
CASE="000088" : TranslateHEX$=LANGUAGE$(59)
CASE="008888" : TranslateHEX$=LANGUAGE$(60)
CASE="888800" : TranslateHEX$=LANGUAGE$(61)
CASE="880088" : TranslateHEX$=LANGUAGE$(62)
CASE ELSE : TranslateHEX$=LANGUAGE$(63)
END SELECT
END FUNCTION

'===============================================================================

SUB OpenTable (loadfile$)
SHARED fspath$,fsmessage$,fsname$,table_handle,cell_handle
SHARED ChooseFile$,current_wizard$,tablecells$()
STATIC myfile,dummy$,dummy,i,a$,b$,c$,d$,e$,selected_cell,x,y,w,h,temp$,temp

IF loadfile$="" THEN
	fspath$=CURDIR$+"\*.TBL" : fsmessage$=ChooseFile$ : fsname$=""
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
	CASE "<Table.Wizard>" : dummy=1
	CASE "<begin>" : dummy=2
	CASE "<end>" : dummy=3
	END SELECT
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
		CASE "<header>"
			SelectTree FORM_TABLE : setobj_text TBL_HEADER,b$
		CASE "<header align>"
			SelectTree FORM_TABLE
			remove_state TBL_HLEFT,mask_selected
			remove_state TBL_HRIGHT,mask_selected
			IF b$="LEFT" THEN include_state TBL_HLEFT,mask_selected
			IF b$="RIGHT" THEN include_state TBL_HRIGHT,mask_selected
		CASE "<footer>"
			SelectTree FORM_TABLE : setobj_text TBL_FOOTER,b$
		CASE "<footer align>"
			SelectTree FORM_TABLE
			remove_state TBL_FLEFT,mask_selected
			remove_state TBL_FRIGHT,mask_selected
			IF b$="LEFT" THEN include_state TBL_FLEFT,mask_selected
			IF b$="RIGHT" THEN include_state TBL_FRIGHT,mask_selected
		CASE "<align>"
			SelectTree FORM_TABLE
			remove_state TBL_ALIGNL,mask_selected
			remove_state TBL_ALIGNC,mask_selected
			remove_state TBL_ALIGNR,mask_selected
			IF b$="LEFT" THEN include_state TBL_ALIGNL,mask_selected
			IF b$="CENTER" THEN include_state TBL_ALIGNC,mask_selected
			IF b$="RIGHT" THEN include_state TBL_ALIGNR,mask_selected
		CASE "<text flow?>"
			SelectTree FORM_TABLE
			IF b$="YES" THEN setobj_shortcut TBL_FLOW,CHR$(14)
			IF b$="NO" THEN setobj_shortcut TBL_FLOW,CHR$(13)
		CASE "<border>"
			SelectTree FORM_TABLE : setobj_text TBL_BORDER,b$
		CASE "<border style>"
			SelectTree FORM_TABLE
			remove_state TBL_B1,mask_selected
			remove_state TBL_B2,mask_selected
			remove_state TBL_B3,mask_selected
			remove_state TBL_B4,mask_selected
			remove_state TBL_B5,mask_selected
			remove_state TBL_B6,mask_selected
			remove_state TBL_B7,mask_selected
			remove_state TBL_B8,mask_selected
			SELECT CASE b$
			CASE "1" : include_state TBL_B1,mask_selected
			CASE "2" : include_state TBL_B2,mask_selected
			CASE "3" : include_state TBL_B3,mask_selected
			CASE "4" : include_state TBL_B4,mask_selected
			CASE "5" : include_state TBL_B5,mask_selected
			CASE "6" : include_state TBL_B6,mask_selected
			CASE "7" : include_state TBL_B7,mask_selected
			CASE "8" : include_state TBL_B8,mask_selected
			END SELECT
		CASE "<cellpadding>"
			SelectTree FORM_TABLE : setobj_text TBL_CELLPADDING,b$
		CASE "<cellspacing>"
			SelectTree FORM_TABLE : setobj_text TBL_CELLSPACING,b$
		CASE "<width>"
			SelectTree FORM_TABLE : setobj_text TBL_WIDTH,b$
		CASE "<width percent?>"
			SelectTree FORM_TABLE
			setobj_shortcut TBL_PERCENT,CHR$(11)
			setobj_shortcut TBL_PIXELS,CHR$(11)
			IF b$="YES" THEN setobj_shortcut TBL_PERCENT,CHR$(12)
			IF b$="NO" THEN setobj_shortcut TBL_PIXELS,CHR$(12)
		END SELECT

		IF LEFT$(a$,6)="<cell "
			IF b$<>"HIDDEN" THEN
				temp=VAL(MID$(a$,7,3))
				SELECT CASE temp
				CASE 0 TO 9 : d$=LTRIM$(RIGHT$(a$,LEN(a$)-8))
				CASE 10 TO 99 : d$=LTRIM$(RIGHT$(a$,LEN(a$)-9))
				CASE >99 : d$=LTRIM$(RIGHT$(a$,LEN(a$)-10))
				END SELECT
				SelectTree FORM_CELL
				remove_flags CELL_BACK+VAL(MID$(a$,7,3)),mask_hidetree

				SELECT CASE d$
				CASE "x>" : x=VAL(b$) : CALL update_mouse
				CASE "y>" : y=VAL(b$)
				CASE "w>" : w=VAL(b$)
				CASE "h>" : h=VAL(b$)
				CASE "text>" : e$=b$+CHR$(0)
				CASE "text2>" : e$=e$+b$+CHR$(0)
				CASE "text3>" :	e$=e$+b$+CHR$(0)
				CASE "colour>" : e$=e$+b$+CHR$(0)+TranslateHEX$(b$)+CHR$(0)
				CASE "align>" : e$=e$+b$+CHR$(0)
				CASE "valign>" : e$=e$+b$+CHR$(0) 
				CASE "nowrap>"
					IF b$="YES" THEN e$=e$+"NOWRAP"+CHR$(0)
					IF b$="NO" THEN e$=e$+""+CHR$(0)
				CASE "background image?>"
					IF b$="YES" THEN e$=e$+"IMAGE"+CHR$(0)
					IF b$="NO" THEN e$=e$+""+CHR$(0)
				CASE "background image>" : e$=e$+b$+CHR$(0)
				CASE "background colour>"
					setobj_xywh CELL_BACK+VAL(MID$(a$,7,3)),x,y,w,h
					temp$=TranslateHEX$(b$)
					e$=e$+b$+CHR$(0)+temp$+CHR$(0)
					tablecells$(VAL(MID$(a$,7,3)))=e$
				END SELECT
			END IF
		END IF
	END IF
LOOP UNTIL EOF(myfile)
CLOSE #myfile
MOUSE 0
cell_handle=OpenFormWindow(MyProgram$,FORM_CELL,CELL_TEXT1,0,VARPTRS(closeFORM_CELL))
SelectTree FORM_CELL
CALL init_dialog(FORM_CELL) : CALL Redraw_Object (0)
table_handle=OpenFormWindow(MyProgram$,FORM_TABLE,TBL_HEADER,0,VARPTRS(closeFORM_TABLE))
SelectTree FORM_TABLE
CALL init_dialog(FORM_TABLE) : CALL Redraw_Object (0)
END SUB

'===============================================================================

SUB SaveTable(BYVAL savefile$)
SHARED fspath$,fsmessage$,fsname$,SaveAs$,current_wizard$,DeselectCELL$
SHARED tablecells$(),cell$()
STATIC dummy$,dummy,myfile,selected_cell,i,old_char,x,y,w,h

SelectTree FORM_CELL
IF NOT enquire_flags(CELL_PROPERTIES,mask_hidetree) THEN
	junk=form_alert(1,DeselectCELL$) : EXIT SUB
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
OPEN LEFT$(current_wizard$,LEN(current_wizard$)-3)+"TBL" FOR OUTPUT AS #myfile
	PRINT #myfile,"<Table.Wizard>"
	PRINT #myfile,"<begin>"
	SelectTree FORM_TABLE
	CALL update_mouse
	PRINT #myfile,"<header>"+getobj_text$(TBL_HEADER)
	IF enquire_state(TBL_HLEFT,mask_selected) THEN
		PRINT #myfile,"<header align>LEFT"
	ELSE
		PRINT #myfile,"<header align>RIGHT"
	END IF
	PRINT #myfile,"<footer>"+getobj_text$(TBL_FOOTER)
	IF enquire_state(TBL_FLEFT,mask_selected) THEN
		PRINT #myfile,"<footer align>LEFT"
	ELSE
		PRINT #myfile,"<footer align>RIGHT"
	END IF
	CALL update_mouse
	IF enquire_state(TBL_ALIGNL,mask_selected) THEN PRINT #myfile,"<align>LEFT"
	IF enquire_state(TBL_ALIGNC,mask_selected) THEN PRINT #myfile,"<align>CENTER"
	IF enquire_state(TBL_ALIGNR,mask_selected) THEN PRINT #myfile,"<align>RIGHT"
	IF getobj_shortcut(TBL_FLOW)=14 THEN PRINT #myfile,"<text flow?>YES"
	IF getobj_shortcut(TBL_FLOW)=13 THEN PRINT #myfile,"<text flow?>NO"
	PRINT #myfile,"<border>"+getobj_text$(TBL_BORDER)
	CALL update_mouse
	IF enquire_state(TBL_B1,mask_selected) THEN PRINT #myfile,"<border style>1"
	IF enquire_state(TBL_B2,mask_selected) THEN PRINT #myfile,"<border style>2"
	IF enquire_state(TBL_B3,mask_selected) THEN PRINT #myfile,"<border style>3"
	IF enquire_state(TBL_B4,mask_selected) THEN PRINT #myfile,"<border style>4"
	IF enquire_state(TBL_B5,mask_selected) THEN PRINT #myfile,"<border style>5"
	IF enquire_state(TBL_B6,mask_selected) THEN PRINT #myfile,"<border style>6"
	IF enquire_state(TBL_B7,mask_selected) THEN PRINT #myfile,"<border style>7"
	IF enquire_state(TBL_B8,mask_selected) THEN PRINT #myfile,"<border style>8"
	CALL update_mouse
	PRINT #myfile,"<cellpadding>"+getobj_text$(TBL_CELLPADDING)
	PRINT #myfile,"<cellspacing>"+getobj_text$(TBL_CELLSPACING)
	PRINT #myfile,"<width>"+getobj_text$(TBL_WIDTH)
	IF getobj_shortcut(TBL_PERCENT)=12 THEN PRINT #myfile,"<width percent?>YES"
	IF getobj_shortcut(TBL_PERCENT)=11 THEN PRINT #myfile,"<width percent?>NO"
	CALL update_mouse

	SelectTree FORM_CELL
	FOR selected_cell=1 TO 144
		CALL update_mouse
		IF NOT enquire_flags(CELL_BACK+selected_cell,mask_hidetree) THEN
			getobj_xywh CELL_BACK+selected_cell,x,y,w,h
			PRINT #myfile,"<cell"+STR$(selected_cell)+" x>"+LTRIM$(STR$(x))
			PRINT #myfile,"<cell"+STR$(selected_cell)+" y>"+LTRIM$(STR$(y))
			PRINT #myfile,"<cell"+STR$(selected_cell)+" w>"+LTRIM$(STR$(w))
			PRINT #myfile,"<cell"+STR$(selected_cell)+" h>"+LTRIM$(STR$(h))
			dummy=1 : old_char=1 : i=0
			DO
				IF ASC(MID$(tablecells$(selected_cell),dummy,1))=0 THEN
					cell$(i)=MID$(tablecells$(selected_cell),old_char,dummy-old_char)
					INCR i : old_char=dummy+1
				END IF
				IF dummy=LEN(tablecells$(selected_cell)) THEN EXIT LOOP
				INCR dummy
			LOOP
			PRINT #myfile,"<cell"+STR$(selected_cell)+" text>"+cell$(0)
			PRINT #myfile,"<cell"+STR$(selected_cell)+" text2>"+cell$(1)
			PRINT #myfile,"<cell"+STR$(selected_cell)+" text3>"+cell$(2)
			PRINT #myfile,"<cell"+STR$(selected_cell)+" colour>"+cell$(3)
			PRINT #myfile,"<cell"+STR$(selected_cell)+" align>"+cell$(5)
			PRINT #myfile,"<cell"+STR$(selected_cell)+" valign>"+cell$(6)
			IF cell$(7)="NOWRAP" THEN
				PRINT #myfile,"<cell"+STR$(selected_cell)+" nowrap>YES"
			ELSE
				PRINT #myfile,"<cell"+STR$(selected_cell)+" nowrap>NO"
			END IF
			IF cell$(8)="IMAGE" THEN
				PRINT #myfile,"<cell"+STR$(selected_cell)+" background image?>YES"
			ELSE
				PRINT #myfile,"<cell"+STR$(selected_cell)+" background image?>NO"
			END IF
			PRINT #myfile,"<cell"+STR$(selected_cell)+" background image>"+cell$(9)
			PRINT #myfile,"<cell"+STR$(selected_cell)+" background colour>"+cell$(10)
		ELSE
			PRINT #myfile,"<cell"+STR$(selected_cell)+">HIDDEN"
		END IF
	NEXT selected_cell
	PRINT #myfile,"<end>"
CLOSE #myfile

myfile=FREEFILE
OPEN LEFT$(current_wizard$,LEN(current_wizard$)-3)+"HTM" FOR OUTPUT AS #myfile
	PRINT #myfile,"<!DOCTYPE HTML PUBLIC "+CHR$(34)+"-//W3C//DTD HTML 3.2 Draft//EN"+CHR$(34)+">"
	PRINT #myfile,"<!-- This table was created using Table.Wizard v3.10>"
	PRINT #myfile,"<!-- Copyright 1997-1999 Cadenza Software - http://www.cadenza.cyberstrider.org -->"
	PRINT #myfile,"<HTML>"
	PRINT #myfile,"<HEAD><TITLE></TITLE></HEAD>"
	PRINT #myfile,"<BODY>"
		CALL update_mouse
		CALL generate_table(current_wizard$,myfile)
	PRINT #myfile,"</BODY>"
	PRINT #myfile,"</HTML>"
CLOSE #myfile
MOUSE 0
END SUB

'===============================================================================

SUB ExportTable
SHARED fspath$,fsmessage$,fsname$,SaveAs$,DeselectCELL$
STATIC dummy$,myfile

SelectTree FORM_CELL
IF NOT enquire_flags(CELL_PROPERTIES,mask_hidetree) THEN
	junk=form_alert(1,DeselectCELL$) : EXIT SUB
END IF

fspath$=CURDIR$+"\*.*" : fsmessage$=SaveAs$ : fsname$=""
dummy$=FileSelect$ (fsname$,2) : IF fsname$="" THEN EXIT SUB

myfile=FREEFILE
OPEN dummy$ FOR OUTPUT AS #myfile
	CALL generate_table(dummy$,myfile)
CLOSE #myfile
MOUSE 0
END SUB

'===============================================================================

SUB init_FORMs
SHARED popup_cellcolour,popup_cellbackcolour,tablecells$()
SHARED table_handle,cell_handle,woEditObj(0),woEditOffset(0)
SHARED current_wizard$,popup_columns,popup_rows
STATIC dummy,CommonIndex,top_handle

SelectTree FORM_TABLE
CALL update_mouse
current_wizard$=""
setobj_text TBL_HEADER,""
include_state TBL_HLEFT,mask_selected
remove_state TBL_HRIGHT,mask_selected
setobj_text TBL_FOOTER,""
include_state TBL_FLEFT,mask_selected
remove_state TBL_FRIGHT,mask_selected
CALL update_mouse
include_state TBL_ALIGNL,mask_selected
remove_state TBL_ALIGNC,mask_selected
remove_state TBL_ALIGNR,mask_selected
setobj_shortcut TBL_FLOW,CHR$(13)
CALL update_mouse
setobj_text TBL_BORDER,"00"
include_state TBL_B1,mask_selected
remove_state TBL_B2,mask_selected
remove_state TBL_B3,mask_selected
remove_state TBL_B4,mask_selected
remove_state TBL_B5,mask_selected
remove_state TBL_B6,mask_selected
remove_state TBL_B7,mask_selected
remove_state TBL_B8,mask_selected
CALL update_mouse
setobj_text TBL_CELLPADDING,"00"
setobj_text TBL_CELLSPACING,"00"
CALL update_mouse
setobj_text TBL_WIDTH,"100"
setobj_shortcut TBL_PERCENT,CHR$(12)
setobj_shortcut TBL_PIXELS,CHR$(11)
CALL update_mouse

SelectTree FORM_CELL
CALL update_mouse
include_flags CELL_PROPERTIES,mask_hidetree
remove_flags TBL_SELECTCELL,mask_hidetree
setobj_poptext CELL_ACROSS,"  "+getobj_poptext$(FORM_POPUPS,POP_CELLS+1)
setobj_poptext CELL_DOWN,"  "+getobj_poptext$(FORM_POPUPS,POP_CELLS+1)
popup_columns=POP_CELLS+1
popup_rows=POP_CELLS+1

setobj_text CELL_TEXT1,""
setobj_text CELL_TEXT2,""
setobj_text CELL_TEXT3,""
CALL update_mouse
setobj_text CELL_COLOUR,"000000"
setobj_poptext CELL_COLOUR2,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+4)
SelectTree FORM_CELL
popup_cellcolour=POP_COLOUR+4
CALL update_mouse
include_state CELL_ALIGNL,mask_selected
remove_state CELL_ALIGNC,mask_selected
remove_state CELL_ALIGNR,mask_selected
CALL update_mouse
remove_state CELL_VALIGNT,mask_selected
include_state CELL_VALIGNM,mask_selected
remove_state CELL_VALIGNB,mask_selected
remove_state CELL_VALIGNBASE,mask_selected
CALL update_mouse
setobj_shortcut CELL_NOWRAP,CHR$(13)
CALL update_mouse
setobj_shortcut CELL_BIMAGE,CHR$(11)
setobj_text CELL_BIMAGE3,""
setobj_shortcut CELL_BCOLOUR,CHR$(12)
setobj_text CELL_BCOLOUR3,"FFFFFF"
setobj_poptext CELL_BCOLOUR4,"  "+getobj_poptext$(FORM_POPUPS,POP_COLOUR+2)
popup_cellbackcolour=POP_COLOUR+2
CALL update_mouse
FOR dummy=C1 TO C144
	include_flags dummy,mask_hidetree
	remove_state dummy,mask_selected
NEXT dummy
remove_flags C1,mask_hidetree
setobj_xywh C1,0,0,192,192
CALL update_mouse
FOR dummy=0 TO 144
	tablecells$(dummy)=""+CHR$(0)+""+CHR$(0)+""+CHR$(0)+"000000"+CHR$(0)+LANGUAGE$(48)+CHR$(0)+"LEFT"+CHR$(0)+"MIDDLE"+CHR$(0)+""+CHR$(0)+"COLOUR"+CHR$(0)+""+CHR$(0)+"FFFFFF"+CHR$(0)+LANGUAGE$(47)+CHR$(0)
NEXT dummy

IF cell_handle THEN
	SelectTree FORM_CELL
	Object_Redraw cell_handle,0
END IF
IF table_handle THEN
	SelectTree FORM_TABLE
	CommonIndex=WhichWindow(table_handle)
	woEditObj(CommonIndex)=TBL_HEADER
	woEditOffset(CommonIndex)=LEN(getobj_text$(woEditObj(CommonIndex)))
	Object_Redraw table_handle,0
	junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
	IF top_handle=table_handle THEN HandleCursor table_handle,1
END IF
MOUSE 0
END SUB

'===============================================================================

SUB closeFORM_CELL
SHARED BUB_CELL$,BUB_CUTX$,BUB_CUTY$,BUB_GLUE$,BUB_COLUMN$,BUB_ROW$,BUB_BACKIMG$
SHARED fspath$,fsmessage$,fsname$,ChooseFile$,tablecells$(),cell$()
SHARED cell_handle,woEditObj(0),woEditOffset(0),popup_columns,popup_rows
SHARED popup_cellcolour,popup_cellbackcolour,ChangeRGB,ChangeRGB$,AreYouSure$
STATIC dummy,total_cells,old_object,selected_cell,CommonIndex,dummy$
STATIC old_char,i,temp$,button,top_handle

SelectTree FORM_CELL
IF CommonButton=2 THEN
SELECT CASE CommonObj
CASE C1 TO C144
	dummy=1 : old_char=1 : i=0
	DO
		IF ASC(MID$(tablecells$(CommonObj-1),dummy,1))=0 THEN
			cell$(i)=MID$(tablecells$(CommonObj-1),old_char,dummy-old_char)
			INCR i : old_char=dummy+1
		END IF
		IF dummy=LEN(tablecells$(CommonObj-1)) THEN EXIT LOOP
		INCR dummy
	LOOP
	junk=BubbleGEM (cell$(0)+cell$(1)+cell$(2))
CASE CELL_CUTX : junk=BubbleGEM (BUB_CUTx$)
CASE CELL_CUTY : junk=BubbleGEM (BUB_CUTy$)
CASE CELL_GLUE : junk=BubbleGEM (BUB_GLUE$)
CASE CELL_ACROSS : junk=BubbleGEM (BUB_COLUMN$)
CASE CELL_DOWN : junk=BubbleGEM (BUB_ROW$)
CASE CELL_BIMAGE3 : junk=BubbleGEM (BUB_BACKIMG$)
END SELECT
ELSE
SELECT CASE CommonObj
CASE CELL_ACROSS
	popup_columns=popup(cell_handle,CELL_ACROSS,FORM_POPUPS,POP_CELLS,0)
	IF popup_columns THEN
		button=form_alert(2,AreYouSure$)
		IF button<>1 THEN EXIT SELECT
		dummy$=getobj_poptext$(FORM_POPUPS,popup_columns)
		setobj_poptext CELL_ACROSS,"  "+dummy$
		Object_Redraw cell_handle,CELL_ACROSS
		CALL UpdateCells(VAL(getobj_text$(CELL_ACROSS)),VAL(getobj_text$(CELL_DOWN)))
	END IF
CASE CELL_DOWN
	popup_rows=popup(cell_handle,CELL_DOWN,FORM_POPUPS,POP_CELLS,0)
	IF popup_rows THEN
		button=form_alert(2,AreYouSure$)
		IF button<>1 THEN EXIT SELECT
		dummy$=getobj_poptext$(FORM_POPUPS,popup_rows)
		setobj_poptext CELL_DOWN,"  "+dummy$
		Object_Redraw cell_handle,CELL_DOWN
		CALL UpdateCells(VAL(getobj_text$(CELL_ACROSS)),VAL(getobj_text$(CELL_DOWN)))
	END IF
CASE C1 TO C144
	total_cells=0
	FOR dummy=C1 TO C144
		IF enquire_state(dummy,mask_selected) THEN
			INCR total_cells
			selected_cell=dummy
		END IF
	NEXT
	SELECT CASE total_cells
	CASE 1
		selected_cell=CELL_BACK+selected_cell-2
		dummy=1 : old_char=1 : i=0
		DO
			IF ASC(MID$(tablecells$(selected_cell),dummy,1))=0 THEN
				cell$(i)=MID$(tablecells$(selected_cell),old_char,dummy-old_char)
				INCR i : old_char=dummy+1
			END IF
			IF dummy=LEN(tablecells$(selected_cell)) THEN EXIT LOOP
			INCR dummy
		LOOP
		setobj_text CELL_TEXT1,cell$(0)
		setobj_text CELL_TEXT2,cell$(1)
		setobj_text CELL_TEXT3,cell$(2)
		setobj_text CELL_COLOUR,cell$(3)
		setobj_poptext CELL_COLOUR2,"  "+cell$(4)
		remove_state CELL_ALIGNL,mask_selected
		remove_state CELL_ALIGNC,mask_selected
		remove_state CELL_ALIGNR,mask_selected
		IF cell$(5)="LEFT" THEN include_state CELL_ALIGNL,mask_selected
		IF cell$(5)="CENTER" THEN include_state CELL_ALIGNC,mask_selected
		IF cell$(5)="RIGHT" THEN include_state CELL_ALIGNR,mask_selected
		IF cell$(6)="TOP" THEN
			include_state CELL_VALIGNT,mask_selected
			remove_state CELL_VALIGNM,mask_selected
			remove_state CELL_VALIGNB,mask_selected
			remove_state CELL_VALIGNBASE,mask_selected
		END IF
		IF cell$(6)="MIDDLE" THEN
			remove_state CELL_VALIGNT,mask_selected
			include_state CELL_VALIGNM,mask_selected
			remove_state CELL_VALIGNB,mask_selected
			remove_state CELL_VALIGNBASE,mask_selected
		END IF
		IF cell$(6)="BOTTOM" THEN
			remove_state CELL_VALIGNT,mask_selected
			remove_state CELL_VALIGNM,mask_selected
			include_state CELL_VALIGNB,mask_selected
			remove_state CELL_VALIGNBASE,mask_selected
		END IF
		IF cell$(6)="BASE" THEN
			remove_state CELL_VALIGNT,mask_selected
			remove_state CELL_VALIGNM,mask_selected
			remove_state CELL_VALIGNB,mask_selected
			include_state CELL_VALIGNBASE,mask_selected
		END IF
		IF cell$(7)="NOWRAP" THEN
			setobj_shortcut CELL_NOWRAP,CHR$(14)
		ELSE
			setobj_shortcut CELL_NOWRAP,CHR$(13)
		END IF
		IF cell$(8)="IMAGE" THEN
			setobj_shortcut CELL_BIMAGE,CHR$(12)
			setobj_shortcut CELL_BCOLOUR,CHR$(11)
		ELSE
			setobj_shortcut CELL_BIMAGE,CHR$(11)
			setobj_shortcut CELL_BCOLOUR,CHR$(12)
		END IF
		setobj_text CELL_BIMAGE3,RIGHT$(cell$(9),27)
		setobj_text CELL_BCOLOUR3,cell$(10)
		setobj_poptext CELL_BCOLOUR4,"  "+cell$(11)

		remove_flags CELL_PROPERTIES,mask_hidetree
		include_flags TBL_SELECTCELL,mask_hidetree
		old_object=selected_cell
		CALL init_dialog(FORM_CELL)
	CASE ELSE
		IF NOT enquire_flags(CELL_PROPERTIES,mask_hidetree) THEN
			dummy=1 : old_char=1 : i=0
			DO
				IF ASC(MID$(tablecells$(old_object),dummy,1))=0 THEN
					cell$(i)=MID$(tablecells$(old_object),old_char,dummy-old_char)
					INCR i : old_char=dummy+1
				END IF
				IF dummy=LEN(tablecells$(old_object)) THEN EXIT LOOP
				INCR dummy
			LOOP

			dummy$=""
			dummy$=dummy$+getobj_text$(CELL_TEXT1)+CHR$(0)
			dummy$=dummy$+getobj_text$(CELL_TEXT2)+CHR$(0)
			dummy$=dummy$+getobj_text$(CELL_TEXT3)+CHR$(0)
			dummy$=dummy$+getobj_text$(CELL_COLOUR)+CHR$(0)
			dummy$=dummy$+LTRIM$(getobj_text$(CELL_COLOUR2))+CHR$(0)
			IF enquire_state(CELL_ALIGNL,mask_selected) THEN dummy$=dummy$+"LEFT"+CHR$(0)
			IF enquire_state(CELL_ALIGNC,mask_selected) THEN dummy$=dummy$+"CENTER"+CHR$(0)
			IF enquire_state(CELL_ALIGNR,mask_selected) THEN dummy$=dummy$+"RIGHT"+CHR$(0)
			IF enquire_state(CELL_VALIGNT,mask_selected) THEN dummy$=dummy$+"TOP"+CHR$(0)
			IF enquire_state(CELL_VALIGNM,mask_selected) THEN dummy$=dummy$+"MIDDLE"+CHR$(0)
			IF enquire_state(CELL_VALIGNB,mask_selected) THEN dummy$=dummy$+"BOTTOM"+CHR$(0)
			IF enquire_state(CELL_VALIGNBASE,mask_selected) THEN dummy$=dummy$+"BASE"+CHR$(0)
			IF getobj_shortcut(CELL_NOWRAP)=14 THEN dummy$=dummy$+"NOWRAP"+CHR$(0)
			IF getobj_shortcut(CELL_NOWRAP)=13 THEN dummy$=dummy$+""+CHR$(0)
			IF getobj_shortcut(CELL_BIMAGE)=12 THEN dummy$=dummy$+"IMAGE"+CHR$(0)
			IF getobj_shortcut(CELL_BCOLOUR)=12 THEN dummy$=dummy$+"COLOUR"+CHR$(0)
			dummy$=dummy$+cell$(9)+CHR$(0)
			dummy$=dummy$+getobj_text$(CELL_BCOLOUR3)+CHR$(0)
			dummy$=dummy$+LTRIM$(getobj_text$(CELL_BCOLOUR4))+CHR$(0)
			tablecells$(old_object)=dummy$
			include_flags CELL_PROPERTIES,mask_hidetree
			remove_flags TBL_SELECTCELL,mask_hidetree
		END IF
		old_object=CommonObj
	END SELECT
	Object_Redraw cell_handle,TBL_SELECTCELL
	Object_Redraw cell_handle,CELL_PROPERTIES
	CommonIndex=WhichWindow(cell_handle)
	woEditObj(CommonIndex)=CELL_TEXT1
	woEditOffset(CommonIndex)=LEN(getobj_text$(woEditObj(CommonIndex)))
	junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
	IF top_handle=cell_handle THEN HandleCursor cell_handle,1
CASE CELL_BIMAGE3
	fspath$=CURDIR$+"\*.JPG,*.GIF,*.PNG" : fsmessage$=ChooseFile$
	fsname$=""
	dummy$=FileSelect$ (fsname$,2)
	temp$=dummy$
	IF fsname$<>"" THEN
		setobj_text CELL_BIMAGE3,RIGHT$(dummy$,27)
		Object_Redraw cell_handle,CELL_BIMAGE3
	ELSE
		setobj_text CELL_BIMAGE3,""
		Object_Redraw cell_handle,CELL_BIMAGE3
	END IF

	dummy=1 : old_char=1 : i=0
	DO
		IF ASC(MID$(tablecells$(selected_cell),dummy,1))=0 THEN
			cell$(i)=MID$(tablecells$(selected_cell),old_char,dummy-old_char)
			INCR i : old_char=dummy+1
		END IF
		IF dummy=LEN(tablecells$(selected_cell)) THEN EXIT LOOP
		INCR dummy
	LOOP
	dummy$=""
	FOR dummy=0 TO 8
		dummy$=dummy$+cell$(dummy)+CHR$(0)
	NEXT dummy
	dummy$=dummy$+temp$+CHR$(0)
	FOR dummy=10 TO 11
		dummy$=dummy$+cell$(dummy)+CHR$(0)
	NEXT dummy
	tablecells$(selected_cell)=dummy$
CASE CELL_BCOLOUR4
	popup_cellbackcolour=popup(cell_handle,CELL_BCOLOUR4,FORM_POPUPS,POP_COLOUR,0)
	IF popup_cellbackcolour THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_cellbackcolour)
		setobj_poptext CELL_BCOLOUR4,"  "+dummy$
		IF dummy$=LANGUAGE$(63) THEN
			CALL initFORM_COLOURS (getobj_text$(CELL_BCOLOUR3))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_CELL
			IF ChangeRGB=-1 THEN setobj_text CELL_BCOLOUR3,ChangeRGB$
		ELSE
			CALL UpdateRGB (CELL_BCOLOUR3,dummy$)
		END IF
		Object_Redraw cell_handle,CELL_BCOLOUR3
		Object_Redraw cell_handle,CELL_BCOLOUR4
	END IF
CASE CELL_COLOUR2
	popup_cellcolour=popup(cell_handle,CELL_COLOUR2,FORM_POPUPS,POP_COLOUR,0)
	IF popup_cellcolour THEN
		dummy$=getobj_poptext$(FORM_POPUPS,popup_cellcolour)
		setobj_poptext CELL_COLOUR2,"  "+dummy$
		IF dummy$=LANGUAGE$(63) THEN
			CALL initFORM_COLOURS (getobj_text$(CELL_COLOUR))
			junk=xdialog (FORM_COLOURS,0,COL_CANCEL,1,VARPTRS(closeFORM_COLOURS))
			SelectTree FORM_CELL
			IF ChangeRGB=-1 THEN setobj_text CELL_COLOUR,ChangeRGB$
		ELSE
			CALL UpdateRGB (CELL_COLOUR,dummy$)
		END IF
		Object_Redraw cell_handle,CELL_COLOUR
		Object_Redraw cell_handle,CELL_COLOUR2
	END IF
CASE CELL_CUTx : CALL cutx
CASE CELL_CUTy : CALL cuty
CASE CELL_GLUE : CALL gluecell
END SELECT
END IF
END SUB

'===============================================================================

SUB closeFORM_TABLE
SHARED table_handle,cell_handle
SHARED BUB_JUSTHEADER$,BUB_JUSTFOOTER$,BUB_JUSTTABLE$,BUB_FLOW$,BUB_BORDER$
SHARED BUB_CELLPADDING$,BUB_CELLSPACING$,BUB_WIDTH$

SelectTree FORM_TABLE
IF CommonButton=2 THEN
SELECT CASE CommonObj
CASE TBL_HLEFT : junk=BubbleGEM (BUB_JUSTHEADER$)
CASE TBL_HRIGHT : junk=BubbleGEM (BUB_JUSTHEADER$)
CASE TBL_FLEFT : junk=BubbleGEM (BUB_JUSTFOOTER$)
CASE TBL_FRIGHT : junk=BubbleGEM (BUB_JUSTFOOTER$)
CASE TBL_ALIGNL : junk=BubbleGEM (BUB_JUSTTABLE$)
CASE TBL_ALIGNC : junk=BubbleGEM (BUB_JUSTTABLE$)
CASE TBL_ALIGNR : junk=BubbleGEM (BUB_JUSTTABLE$)
CASE TBL_FLOW : junk=BubbleGEM (BUB_FLOW$)
CASE TBL_BORDER : junk=BubbleGEM (BUB_BORDER$)
CASE TBL_CELLPADDING : junk=BubbleGEM (BUB_CELLPADDING$)
CASE TBL_CELLSPACING : junk=BubbleGEM (BUB_CELLSPACING$)
CASE TBL_WIDTH : junk=BubbleGEM (BUB_WIDTH$)
END SELECT
ELSE
SELECT CASE CommonObj
CASE TBL_OK
	remove_state CommonObj,mask_selected
	table_handle=0 : CommonClose=-1
	cell_handle=OpenFormWindow(MyProgram$,FORM_CELL,CELL_TEXT1,0,VARPTRS(closeFORM_CELL))
CASE TBL_CANCEL : table_handle=0 : CommonClose=-1
END SELECT
END IF
END SUB

'===============================================================================

SUB cutx
SHARED cell_handle
STATIC total_cells,dummy,dummy2,unhide_cell,x,y,w,h
STATIC cells_contained,x1,y1,w1,h1,x2,y2,w2,h2,x3,y3,w3,h3

total_cells=0
FOR dummy=C1 TO C144
	IF NOT enquire_flags(dummy,mask_hidetree) THEN INCR total_cells
NEXT
FOR dummy=C1 TO C144
	IF total_cells<144 THEN
		IF enquire_state(dummy,mask_selected) THEN
			getobj_xywh dummy,x,y,w,h
			w1=(w/2)+x
			w2=(w/2)+x
			DO
				CALL update_mouse
				FOR dummy2=C1 TO C144
					IF NOT enquire_flags(dummy2,mask_hidetree) THEN
						getobj_xywh dummy2,x3,y3,w3,h3
						IF ((w1=x3) OR (w2=x3)) THEN
							IF ((x+w=w1) OR (x=w2)) THEN
								setobj_xywh dummy,x,y,w/2,h
								remove_state dummy,mask_selected
								FOR dummy2=C1 TO C144
									IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
								NEXT dummy2
								setobj_xywh unhide_cell,x+(w/2),y,w/2,h
								remove_flags unhide_cell,mask_hidetree
								EXIT LOOP
							ELSE
								setobj_xywh dummy,x,y,(x3-x),h
								remove_state dummy,mask_selected
								FOR dummy2=C1 TO C144
									IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
								NEXT dummy2
								setobj_xywh unhide_cell,x3,y,((x+w)-x3),h
								remove_flags unhide_cell,mask_hidetree
								EXIT LOOP
							END IF
						END IF
					END IF
				NEXT dummy2
				INCR w1 : DECR w2
				IF ((x+w=w1) OR (x=w2)) THEN
					setobj_xywh dummy,x,y,w/2,h
					remove_state dummy,mask_selected
					FOR dummy2=C1 TO C144
						IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
					NEXT dummy2
					setobj_xywh unhide_cell,x+(w/2),y,w/2,h
					remove_flags unhide_cell,mask_hidetree
					EXIT LOOP
				END IF
			LOOP
			INCR total_cells
		END IF
	END IF
	remove_state dummy,mask_selected
NEXT
MOUSE 0
Object_Redraw cell_handle,CELL_BACK
remove_flags TBL_SELECTCELL,mask_hidetree
include_flags CELL_PROPERTIES,mask_hidetree
Object_Redraw cell_handle,TBL_SELECTCELL
Object_Redraw cell_handle,CELL_PROPERTIES
END SUB

'===============================================================================

SUB cuty
SHARED cell_handle
STATIC total_cells,dummy,dummy2,unhide_cell,x,y,w,h
STATIC cells_contained,x1,y1,w1,h1,x2,y2,w2,h2,x3,y3,w3,h3

total_cells=0
FOR dummy=C1 TO C144
	IF NOT enquire_flags(dummy,mask_hidetree) THEN INCR total_cells
NEXT
FOR dummy=C1 TO C144
	IF total_cells<144 THEN
		IF enquire_state(dummy,mask_selected) THEN
			getobj_xywh dummy,x,y,w,h
			h1=(h/2)+y
			h2=(h/2)+y
			DO
				CALL update_mouse
				FOR dummy2=C1 TO C144
					IF NOT enquire_flags(dummy2,mask_hidetree) THEN
						getobj_xywh dummy2,x3,y3,w3,h3
						IF ((h1=y3) OR (h2=y3)) THEN
							IF ((y+h=h1) OR (y=h2)) THEN
								setobj_xywh dummy,x,y,w,h/2
								remove_state dummy,mask_selected
								FOR dummy2=C1 TO C144
									IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
								NEXT dummy2
								setobj_xywh unhide_cell,x,y+(h/2),w,h/2
								remove_flags unhide_cell,mask_hidetree
								EXIT LOOP
							ELSE
								setobj_xywh dummy,x,y,w,(y3-y)
								remove_state dummy,mask_selected
								FOR dummy2=C1 TO C144
									IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
								NEXT dummy2
								setobj_xywh unhide_cell,x,y3,w,((y+h)-y3)
								remove_flags unhide_cell,mask_hidetree
								EXIT LOOP
							END IF
						END IF
					END IF
				NEXT dummy2
				INCR h1 : DECR h2
				IF ((y+h=h1) OR (y=h2)) THEN
					setobj_xywh dummy,x,y,w,h/2
					remove_state dummy,mask_selected
					FOR dummy2=C1 TO C144
						IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
					NEXT dummy2
					setobj_xywh unhide_cell,x,y+(h/2),w,h/2
					remove_flags unhide_cell,mask_hidetree
					EXIT LOOP
				END IF
			LOOP
			INCR total_cells
		END IF
	END IF
	remove_state dummy,mask_selected
NEXT
MOUSE 0
Object_Redraw cell_handle,CELL_BACK
remove_flags TBL_SELECTCELL,mask_hidetree
include_flags CELL_PROPERTIES,mask_hidetree
Object_Redraw cell_handle,TBL_SELECTCELL
Object_Redraw cell_handle,CELL_PROPERTIES
END SUB

'===============================================================================

SUB gluecell
SHARED stopglue$,cell_handle
STATIC x,y,w,h,x1,y1,w1,h1,dummy,check_1,check_2,check_3,check_4
STATIC cell_intersects,x2,y2,w2,h2,dummy2,unhide_cell

x1=192 : y1=192 : w1=0 : h1=0
FOR dummy=C1 TO C144
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
FOR dummy=C1 TO C144
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
			IF ((x1+w1=192) OR (y1=0)) THEN check_2=1
		END IF
		IF ((x1=x) AND (y1+h1=y+h)) THEN
			check_3=1
		ELSE
			IF ((x1=0) OR (y1+h1=192)) THEN check_3=1
		END IF
		IF ((x1+w1=x+w) AND (y1+h1=y+h)) THEN
			check_4=1
		ELSE
			IF ((x1+w1=192) OR (y1+h1=192)) THEN check_4=1
		END IF
	END IF
NEXT
IF check_1+check_2+check_3+check_4<>4 THEN
	junk=form_alert(1,stopglue$) : EXIT SUB
END IF

FOR dummy=C1 TO C144
	IF NOT enquire_flags(dummy,mask_hidetree) THEN
		getobj_xywh dummy,x,y,w,h
		intersection x1,y1,w1,h1,x,y,w,h,x2,y2,w2,h2
		cell_intersects=0
		IF x2<>0 THEN cell_intersects=-1
		IF y2<>0 THEN cell_intersects=-1
		IF w2<>0 THEN cell_intersects=-1
		IF h2<>0 THEN cell_intersects=-1

		IF cell_intersects<>0 THEN
			include_flags dummy,mask_hidetree
			IF w<>w2 THEN
				remove_flags dummy,mask_hidetree
				SELECT CASE x
				CASE x2 TO (x2+w2) : x=x+w2 : w=w-w2
				CASE ELSE
					IF (x1+w1)<>192 THEN
						FOR dummy2=C1 TO C144
							IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
						NEXT dummy2
						setobj_xywh unhide_cell,x1+w1,y,(x+w)-(x1+w1),h
						remove_flags unhide_cell,mask_hidetree
					END IF
					w=x1-x
				END SELECT
			END IF
			IF h<>h2 THEN
				remove_flags dummy,mask_hidetree
				SELECT CASE y
				CASE y2 TO (y2+h2) : y=y+h2 : h=h-h2
				CASE ELSE
					FOR dummy2=C1 TO C144
						IF enquire_flags(dummy2,mask_hidetree) THEN unhide_cell=dummy2 : EXIT FOR
					NEXT dummy2
					IF (y1+h1)<>192 THEN
						setobj_xywh unhide_cell,x,y1+h1,w,(y+h)-(y1+h1)
						remove_flags unhide_cell,mask_hidetree
					END IF
					h=y1-y
				END SELECT
			END IF
			setobj_xywh dummy,x,y,w,h
		END IF
	END IF
NEXT

FOR dummy=C1 TO C144
	IF enquire_flags(dummy,mask_hidetree) THEN
		setobj_xywh dummy,x1,y1,w1,h1
		remove_flags dummy,mask_hidetree
		getobj_xywh dummy,x,y,w,h
		IF (x+w)>192 THEN w=192-x
		IF (y+h)>192 THEN h=192-y
		setobj_xywh dummy,x,y,w,h
		EXIT FOR
	END IF
NEXT
FOR dummy=C1 TO C144
	getobj_xywh dummy,x,y,w,h
	remove_state dummy,mask_selected
	IF (w+h)=0 THEN include_flags dummy,mask_hidetree
NEXT
Object_Redraw cell_handle,CELL_BACK
END SUB

'===============================================================================

FUNCTION readcell$(BYVAL path$,BYVAL selected_cell,BYVAL total_cols,BYVAL total_rows)
SHARED tablecells$(),cell$()
STATIC dummy$,dummy,old_char,i,image$,path$

SelectTree FORM_CELL
dummy=1 : old_char=1 : i=0
DO
	IF ASC(MID$(tablecells$(selected_cell),dummy,1))=0 THEN
		cell$(i)=MID$(tablecells$(selected_cell),old_char,dummy-old_char)
		INCR i : old_char=dummy+1
	END IF
	IF dummy=LEN(tablecells$(selected_cell)) THEN EXIT LOOP
	INCR dummy
LOOP

dummy$="<TD"
dummy$=dummy$+" ALIGN="+CHR$(34)+cell$(5)+CHR$(34)
dummy$=dummy$+" COLSPAN="+LTRIM$(STR$(total_cols))+" ROWSPAN="+LTRIM$(STR$(total_rows))
IF cell$(7)="NOWRAP" THEN dummy$=dummy$+" NOWRAP"
dummy$=dummy$+" VALIGN="+CHR$(34)+cell$(6)+CHR$(34)
IF cell$(8)="IMAGE" THEN
	image$=cell$(9)
	IF image$<>"" THEN
		dummy=LEN(image$)
		DO
			IF MID$(image$,dummy,1)="\" THEN EXIT LOOP
			IF dummy=1 THEN EXIT LOOP
			DECR dummy
		LOOP
		image$=RIGHT$(image$,LEN(image$)-dummy)
		dummy$=dummy$+" BACKGROUND="+CHR$(34)+LCASE$(image$)+CHR$(34)
	
		IF FEXISTS(cell$(9)) THEN
			dummy=LEN(path$)
			DO
				IF MID$(path$,dummy,1)="\" THEN EXIT LOOP
				IF dummy=1 THEN EXIT LOOP
				DECR dummy
			LOOP
			path$=LEFT$(path$,dummy)
	
			IF cell$(9)<>path$+image$ THEN
				junk=CopyFile (cell$(9),path$+image$,1)
				CALL update_mouse
			END IF
		END IF
	END IF
ELSE
	dummy$=dummy$+" BGCOLOR="+CHR$(34)+"#"+cell$(10)+CHR$(34)
END IF
dummy$=dummy$+">"
dummy$=dummy$+"<FONT COLOR="+CHR$(34)+"#"+cell$(3)+CHR$(34)+">"
dummy$=dummy$+cell$(0)+cell$(1)+cell$(2)
dummy$=dummy$+"</FONT>"
dummy$=dummy$+"</TD>"
readcell$=dummy$
END FUNCTION

'===============================================================================

SUB generate_table(BYVAL path$,BYVAL myfile)
SHARED table_cells$()
STATIC dummy$,header$,footer$,dummy

CALL update_mouse
SelectTree FORM_TABLE
IF enquire_state(TBL_ALIGNL,mask_selected) THEN dummy$="<TABLE ALIGN="+CHR$(34)+"LEFT"+CHR$(34)
IF enquire_state(TBL_ALIGNC,mask_selected) THEN dummy$="<TABLE ALIGN="+CHR$(34)+"CENTER"+CHR$(34)
IF enquire_state(TBL_ALIGNR,mask_selected) THEN dummy$="<TABLE ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)
dummy$=dummy$+" BORDER="+getobj_text$(TBL_BORDER)
dummy$=dummy$+" CELLPADDING="+getobj_text$(TBL_CELLPADDING)
dummy$=dummy$+" CELLSPACING="+getobj_text$(TBL_CELLSPACING)
IF enquire_state(TBL_B1,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"VOID"+CHR$(34)
IF enquire_state(TBL_B2,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"ABOVE"+CHR$(34)
IF enquire_state(TBL_B3,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"BELOW"+CHR$(34)
IF enquire_state(TBL_B4,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"HSIDES"+CHR$(34)
IF enquire_state(TBL_B5,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"LHS"+CHR$(34)
IF enquire_state(TBL_B6,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"RHS"+CHR$(34)
IF enquire_state(TBL_B7,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"VSIDES"+CHR$(34)
IF enquire_state(TBL_B8,mask_selected) THEN dummy$=dummy$+" FRAME="+CHR$(34)+"BOX"+CHR$(34)
dummy$=dummy$+" WIDTH="+getobj_text$(TBL_WIDTH)
IF getobj_shortcut(TBL_PERCENT)=12 THEN dummy$=dummy$+"%"
PRINT #myfile,dummy$+">"

IF getobj_text$(TBL_HEADER)<>"" THEN
	header$="<THEAD"
	IF enquire_state(TBL_HLEFT,mask_selected) THEN
		header$=header$+" ALIGN="+CHR$(34)+"LEFT"+CHR$(34)
	ELSE
		header$=header$+" ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)
	END IF
	PRINT #myfile,header$+">"
	PRINT #myfile,getobj_text$(TBL_HEADER)
	PRINT #myfile,"</THEAD>"
END IF

IF getobj_text$(TBL_FOOTER)<>"" THEN
	footer$="<TFOOT"
	IF enquire_state(TBL_FLEFT,mask_selected) THEN
		footer$=footer$+" ALIGN="+CHR$(34)+"LEFT"+CHR$(34)
	ELSE
		footer$=footer$+" ALIGN="+CHR$(34)+"RIGHT"+CHR$(34)
	END IF
	PRINT #myfile,footer$+">"
	PRINT #myfile,getobj_text$(TBL_FOOTER)
	PRINT #myfile,"</TFOOT>"
END IF
PRINT #myfile,"<TBODY>"
PRINT #myfile,"<TR>"

SelectTree FORM_CELL
STATIC x,y,w,h,x1,y1,x2,y2,w2,h2,x3,y3,x4,y4,w4,h4
STATIC object,old_object,total_cols,total_rows

junk=objc_offset(tree&,CELL_BACK,x,y)
FOR y1=0 TO 192
	FOR dummy=C1 TO C144
		IF NOT enquire_flags(dummy,mask_hidetree) THEN
			getobj_xywh dummy,x2,y2,w2,h2
			IF y1=y2 THEN
				old_object=CELL_BACK
				FOR x1=0 TO 192
					object=objc_find(tree&,CELL_BACK,200,x+x1,y+y1)
					IF object<>old_object THEN
						IF object=-1 THEN
							PRINT #myfile,"<TR>"
						ELSE
							old_object=object : CALL update_mouse
							getobj_xywh object,x2,y2,w2,h2
							IF y1=y2 THEN
								total_cols=1 : total_rows=1
								FOR y3=y2+1 TO y2+h2-1
									FOR dummy=C1 TO C144
										IF NOT enquire_flags(dummy,mask_hidetree) THEN
											getobj_xywh dummy,x4,y4,w4,h4
											IF y3=y4 THEN INCR total_rows : EXIT FOR
										END IF
									NEXT dummy
								NEXT y3
								FOR x3=x2+1 TO x2+w2-1
									FOR dummy=C1 TO C144
										IF NOT enquire_flags(dummy,mask_hidetree) THEN
											getobj_xywh dummy,x4,y4,w4,h4
											IF x3=x4 THEN INCR total_cols : EXIT FOR
										END IF
									NEXT dummy
								NEXT x3
								dummy$=readcell$(path$,object-1,total_cols,total_rows)
								PRINT #myfile,dummy$
							END IF
						END IF
					END IF
				NEXT x1
				EXIT FOR
			END IF
		END IF
	NEXT dummy
NEXT y1

PRINT #myfile,"</TBODY>"
PRINT #myfile,"</TABLE>"
SelectTree FORM_TABLE
IF getobj_shortcut(TBL_FLOW)<>14 THEN
	IF enquire_state(TBL_ALIGNL,mask_selected) THEN PRINT #myfile,"<BR CLEAR="+CHR$(34)+"LEFT"+CHR$(34)+">"
	IF enquire_state(TBL_ALIGNC,mask_selected) THEN PRINT #myfile,"<BR CLEAR="+CHR$(34)+"CENTER"+CHR$(34)+">"
	IF enquire_state(TBL_ALIGNR,mask_selected) THEN PRINT #myfile,"<BR CLEAR="+CHR$(34)+"RIGHT"+CHR$(34)+">"
END IF
END SUB

'===============================================================================

SUB UpdateCells(BYVAL columns,BYVAL rows)
SHARED cell_handle
STATIC total_cells,x,y,w,h,x1,y1,w1,h1,dummy,no_cols,no_rows

SelectTree FORM_CELL
FOR dummy=C1 TO C144
	CALL update_mouse
	include_flags dummy,mask_hidetree
	remove_state dummy,mask_selected
NEXT dummy

x1=0 : y1=0 : w1=(192/columns) : h1=(192/rows)
total_cells=0 : no_cols=1 : no_rows=1
FOR dummy=C1 TO C144
	CALL update_mouse
	INCR total_cells
	IF (columns*rows)>=total_cells THEN
		remove_flags dummy,mask_hidetree
		getobj_xywh dummy,x,y,w,h
		setobj_xywh dummy,x1,y1,w1,h1
		IF no_cols=columns THEN
			IF (x1+w1)<192 THEN setobj_xywh dummy,x1,y1,192-x1,h1
		END IF
		IF no_rows=rows THEN
			IF (y1+h1)<192 THEN setobj_xywh dummy,x1,y1,w1,192-y1
		END IF

		IF no_cols<columns THEN
			x1=x1+w1
			INCR no_cols
		ELSE
			IF no_rows=rows THEN
				IF no_cols=columns THEN
					IF (x1+w1)<192 THEN setobj_xywh dummy,x1,y1,192-x1,h1
					w1=192-x1
				END IF
				IF (y1+h1)<192 THEN setobj_xywh dummy,x1,y1,w1,192-y1
				EXIT FOR
			END IF
			x1=0 : y1=y1+h1
			INCR no_rows : no_cols=1
		END IF
	END IF
NEXT dummy
include_flags CELL_PROPERTIES,mask_hidetree
remove_flags TBL_SELECTCELL,mask_hidetree
CALL update_mouse
Object_Redraw cell_handle,CELL_PROPERTIES
Object_Redraw cell_handle,TBL_SELECTCELL
Object_Redraw cell_handle,CELL_BACK
MOUSE 0
END SUB

'===============================================================================
'[END OF FILE]

'junk=form_alert(1,"[1][  "+STR$()+" ][ Abort ]")
