
' [ENCHANT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

DEFINT a-z
REM $include d:\enchant\examples\gem_t.kit\enchant.bh		' Declare *.BH file created from resource file
REM $include d:\enchant\modules\error.bas		' Request the file ERROR.BAS
REM $include toolbx_a.bas	' Request the file TOOLBX_A.BAS (i.e. GEM Toolkit)
REM $include d:\enchant\modules\bubble.bas		' Request the file BUBBLE.BAS
REM $include d:\enchant\modules\cursor.bas		' Request the file CURSOR.BAS
REM $include d:\enchant\modules\st-guide.bas	' Request the file ST-GUIE.BAS

CALL StartProgram (CURDIR$+"\ENCHANT.RSC",FORM_MENU,MENU_QUIT,FORM_ICONIFY)
MyProgram$="ENCHANT"
CALL init_popups	'	Call sub-routines to initiate (set presets) for popups
HowManyButtons=2 : clicks_enabled=-1	' See Toolkit manual for details
junk=xdialog (FORM_ABOUT,0,0,1,0)	' Display 'About' dialog on execution
CALL ENCHANTloop	' Start program loop
CALL StopProgram

' User routines

FUNCTION HandleUserClose(BYVAL WindowHandle)
END FUNCTION

SUB HandleUserMessages
END SUB

SUB HandleUserHook
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
STATIC oldtree&,object,x,y,w,h,outx,outy,find_handle

find_handle=wind_find(mx,my)		' Find out handle under mouse position
IF find_handle<>0 THEN EXIT SUB		' If hanle does not = 0 then exit sub-routine
object=objc_find(desktree&,0,10,mx,my)
IF object=DESK_ICON THEN
	oldtree&=tree& : tree&=desktree&
	IF clicks=1 THEN
		MOUSE 4
		junk=objc_offset(desktree&,object,x,y)
		w=getobj_width(object) : h=getobj_height(object)
		form_dial FMD_START,0,0,0,0,x,y,w,h
		graf_dragbox w,h,x,y,PEEKW(SYSTAB+40)+1,PEEKW(SYSTAB+42)+19,PEEKW(SYSTAB+44),PEEKW(SYSTAB+46)-19,outx,outy
		setobj_x object,outx : setobj_y object,outy-19
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		redraw_object object
		form_dial FMD_FINISH,0,0,0,0,outx,outy,w,h
		MOUSE 0
	ELSE
		IF clicks=2 THEN
			junk=xalert(3,"[1][You double clicked on the|desktop icon!||Cool ;-))][OK]")
		END IF
	END IF
	tree&=oldtree&
END IF
END SUB

' See Toolkit Manual/Modules Manual form further details on the following routine calls!

SUB	HandleUserMenu (WindowHandle,item,title)
SHARED fsmessage$,HowManyWindows,HowManyTextWindows,woTLines(),DialogHandle
STATIC result,checkme,disableme,desktop,file$,dummy$,TotalLines

SELECT CASE item
CASE MENU_ABOUT
	result=xdialog (FORM_ABOUT,0,0,1,0)
CASE MENU_FSELECTOR
	fsmessage$="ENCHANT" : junk$=FileSelect$ ("",2)
CASE MENU_TESTDIALOG
	result=xdialog (FORM_WINDOW,WIND_FTEXT,WIND_CANCEL,1,VARPTRS(closedialog))
CASE MENU_TESTWINDOW
	dummy$="ENCHANT : Window"
	junk=OpenAWindow(dummy$,win_all,1,19,319,181,VARPTRS(dummy_routine),VARPTRS(dummy_routine),VARPTRS(closeform))
CASE MENU_TESTFORM
	dummy$="ENCHANT : Form Window"
	result=OpenFormWindow(dummy$,FORM_ABOUT,0,ABOUT_OK,VARPTRS(closeaboutform))
	DialogHandle=OpenDoubleFormWindow(dummy$,FORM_TOOLBAR,FORM_WINDOW,WIND_FTEXT2,WIND_CANCEL,VARPTRS(closetoolform),VARPTRS(closeform))
	result=OpenFormWindow(dummy$,FORM_PROCESS,PROC_FTEXT,PROC_OK,VARPTRS(closeprocform))
	CALL xENCHANTloop
CASE MENU_EXECUTE
	fsmessage$="Run..." : file$=FileSelect$ ("",2)
	IF file$<>"" THEN CALL execute(file$,"")
CASE MENU_CHECKME
	IF checkme=0 THEN
		result=menu_checkitem (item,1) : IF result=-1 THEN checkme=1
	ELSE
		result=menu_checkitem (item,0) : IF result=-1 THEN checkme=0
	END IF
CASE MENU_DISABLEME
	IF disableme=1 THEN
		result=menu_disableitem (item,1) : IF result=-1 THEN disableme=1
	ELSE
		result=menu_disableitem (item,0) : IF result=-1 THEN disableme=0
	END IF
CASE MENU_DESKTOP
	IF desktop=0 THEN
		CALL SetDesk (FORM_DESKTOP,DESK_LOGO) : desktop=1 : junk=menu_changetext (item,"  Remove Desktop")
	ELSE
		CALL SetDesk (-1,0) : desktop=0 : junk=menu_changetext (item,"  Include Desktop")
	END IF
CASE MENU_CTRL
	junk=xalert(3,"[1][You have selected the|menu item with the control|key shortcut!][OK]")
CASE MENU_SCTRL
	junk=xalert(3,"[1][You have selected the|menu item with the shift &|control keys shortcut!][OK]")
CASE MENU_ALT
	junk=xalert(3,"[1][You have selected the|menu item with the alternate|key shortcut!][OK]")
CASE MENU_SALT
	junk=xalert(3,"[1][You have selected the|menu item with the shift &|alternate keys shortcut!][OK]")
CASE MENU_README
	fsmessage$="ENCHANT" : file$=FileSelect$ ("READ.ME",2)
	IF file$<>"" THEN
	IF FEXISTS(file$) THEN
		IF HowManyTextWindows=0 THEN InitTextSystem 5,200
		LoadTextFile file$,HowManyTextWindows,woTLines(HowManyTextWindows)
		dummy$="ENCHANT : Text Window"
		junk=OpenTextWindow(dummy$,win_all)
	ELSE
		junk=xalert(3,"[1][The file you have chosen does|not exist! - please try again.][OK]")
	END IF
	END IF
CASE MENU_STG_TITLE : junk=STGuide (CURDIR$+"\ENCHANT.HYP","Title")
CASE MENU_STG_CONTENT : junk=STGuide (CURDIR$+"\ENCHANT.HYP","Contents")
CASE MENU_STG_INDEX : junk=STGuide (CURDIR$+"\ENCHANT.HYP","Index")
END SELECT
END SUB


' This sub-routine sets all the popup presets
SUB init_popups
SHARED iobject,cobject,tobject
STATIC oldtree&

oldtree&=tree& : SelectTree FORM_POPUPS
iobject=POPUP_IMAGE2
tobject=POPUP1
cobject=POPUP5

substitute_image FORM_WINDOW,WIND_RADIOIMAGE,FORM_POPUPS,iobject
include_state cobject,mask_checked+mask_selected
include_state tobject,mask_checked+mask_selected

SelectTree FORM_WINDOW
setobj_poptext WIND_RADIOTEXT,"  "+getobj_poptext$(FORM_POPUPS,tobject)
setobj_poptext WIND_CHECKLIST,"  "+getobj_poptext$(FORM_POPUPS,cobject)
tree&=oldtree&
END SUB


SUB closedialog
SHARED iobject,cobject,tobject
STATIC x,y,dummy$

SELECT CASE CommonObj
	CASE WIND_RADIOIMAGE
		iobject=popup(0,WIND_RADIOIMAGE,FORM_POPUPS,POP_IMAGES,iobject)
		IF iobject THEN
			substitute_image FORM_WINDOW,WIND_RADIOIMAGE,FORM_POPUPS,iobject
			redraw_object WIND_RADIOIMAGE
		END IF
	CASE WIND_RI
		radio_popimage FORM_WINDOW,WIND_RADIOIMAGE,FORM_POPUPS,POP_IMAGES,iobject
		redraw_object WIND_RADIOIMAGE
	CASE WIND_RADIOTEXT
		tobject=popup(0,WIND_RADIOTEXT,FORM_POPUPS,POP_TEXT1,tobject)
		IF tobject THEN
			dummy$=getobj_poptext$(FORM_POPUPS,tobject)
			setobj_poptext WIND_RADIOTEXT,"  "+dummy$
			redraw_object WIND_RADIOTEXT
		END IF
	CASE WIND_RT
		radio_poptext WIND_RADIOTEXT,FORM_POPUPS,POP_TEXT1,tobject
		redraw_object WIND_RADIOTEXT
	CASE WIND_CHECKLIST,WIND_CL
		cobject=popup(0,WIND_CHECKLIST,FORM_POPUPS,POP_TEXT2,cobject)
		IF cobject THEN
			dummy$=getobj_poptext$(FORM_POPUPS,cobject)
			setobj_poptext WIND_CHECKLIST,"  "+dummy$
			redraw_object WIND_CHECKLIST
		END IF
	CASE WIND_OK,WIND_CANCEL : Finished_DFlag=0
	CASE WIND_HELP : junk=xalert(3,"[1][There is currently no help|system available - sorry!][OK]")
END SELECT
END SUB


SUB closeaboutform
SELECT CASE CommonObj
	CASE ABOUT_OK : CommonClose=-1
END SELECT
END SUB


SUB closeform
SHARED CommonHandle,iobject,cobject,tobject,DialogHandle
STATIC x,y,dummy$

SelectTree FORM_WINDOW
IF CommonButton=2 THEN	' If right mouse button clicked
SELECT CASE CommonObj
	CASE WIND_OK : junk=BubbleGEM ("OK")
	CASE WIND_CANCEL : junk=BubbleGEM ("Cancel")
	CASE WIND_HELP : junk=BubbleGEM ("Help")
END SELECT
ELSE
SELECT CASE CommonObj
	CASE WIND_RADIOIMAGE
		iobject=popup(DialogHandle,WIND_RADIOIMAGE,FORM_POPUPS,POP_IMAGES,iobject)
		IF iobject THEN
			substitute_image FORM_WINDOW,WIND_RADIOIMAGE,FORM_POPUPS,iobject
			redraw_object WIND_RADIOIMAGE
		END IF
	CASE WIND_RI
		radio_popimage FORM_WINDOW,WIND_RADIOIMAGE,FORM_POPUPS,POP_IMAGES,iobject
		redraw_object WIND_RADIOIMAGE
	CASE WIND_RADIOTEXT
		tobject=popup(DialogHandle,WIND_RADIOTEXT,FORM_POPUPS,POP_TEXT1,tobject)
		IF tobject THEN
			dummy$=getobj_poptext$(FORM_POPUPS,tobject)
			setobj_poptext WIND_RADIOTEXT,"  "+dummy$
			redraw_object WIND_RADIOTEXT
		END IF
	CASE WIND_RT
		radio_poptext WIND_RADIOTEXT,FORM_POPUPS,POP_TEXT1,tobject
		redraw_object WIND_RADIOTEXT
	CASE WIND_CHECKLIST,WIND_CL
		cobject=popup(DialogHandle,WIND_CHECKLIST,FORM_POPUPS,POP_TEXT2,cobject)
		IF cobject THEN
			dummy$=getobj_poptext$(FORM_POPUPS,cobject)
			setobj_poptext WIND_CHECKLIST,"  "+dummy$
			redraw_object WIND_CHECKLIST
		END IF
	CASE WIND_OK,WIND_CANCEL : CommonClose=-1
	CASE WIND_HELP : junk=xalert(3,"[1][There is currently no help|system available - sorry!][OK]")
END SELECT
END IF
END SUB


SUB closetoolform
IF CommonButton=2 THEN
SELECT CASE CommonObj
	CASE TOOL_NEW : junk=BubbleGEM ("New document")
	CASE TOOL_LOAD : junk=BubbleGEM ("Load document")
	CASE TOOL_SAVE : junk=BubbleGEM ("Save document")
	CASE TOOL_PRINT : junk=BubbleGEM ("Print document")
	CASE TOOL_SEARCH : junk=BubbleGEM ("Search document")
	CASE TOOL_INFO : junk=BubbleGEM ("Info.")
	CASE TOOL_CUT : junk=BubbleGEM ("Cut")
	CASE TOOL_COPY : junk=BubbleGEM ("Copy")
	CASE TOOL_PASTE : junk=BubbleGEM ("Paste")
	CASE TOOL_QUIT : junk=BubbleGEM ("Exit")
END SELECT
ELSE
SELECT CASE CommonObj
	CASE TOOL_QUIT : CommonClose=-1
END SELECT
END IF
END SUB


SUB closeprocform
SELECT CASE CommonObj
	CASE PROC_OK : CommonClose=-1
END SELECT
END SUB

'[*END OF FILE*]
