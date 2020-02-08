
' [FORMWIND.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' The files WINDOW.BAS & OBJECT.BAS & XDIALOG.BAS are required to use FORMWIND.BAS

' DECLARE SUB WhichWindow(WindowHandle)				' Can be found in TOOLBX_D.BAS
' DECLARE SUB formcuts(key_pressed,object)			' Can be found in MENU.BAS
' DECLARE SUB CreateShortCut(key_pressed,kstate)	' Can be found in MENU.BAS

SUB InitFormWindows
SHARED woObjectTree&(2),woBaseX(2),woBaseY(2),woCancelObj(1),woEditObj(1),woEditOffset(1)
SHARED woCloseForm&(2),FormWindowSystem,max_windows,woTreeno(2)

DIM woObjectTree&(1,max_windows),woBaseX(1,max_windows),woBaseY(1,max_windows)
DIM woCancelObj(max_Windows),woEditObj(max_windows),woEditOffset(max_windows)
DIM woCloseForm&(1,max_windows),woTreeno(1,max_windows)
FormWindowSystem=-1
END SUB


FUNCTION getobj_ptmplt$(BYVAL object)
STATIC dummy&,dummy$

dummy$=""
dummy&=getobj_spec&(object)
dummy&=PEEKL(dummy&+te_ptmplt)
WHILE PEEKB(dummy&)
	dummy$=dummy$+CHR$(PEEKB(dummy&))
	INCR dummy&
WEND
getobj_ptmplt$=dummy$
END FUNCTION


FUNCTION getcur_offset(BYVAL object,BYVAL index)
STATIC dummy$,curspos

dummy$=(getobj_ptmplt$(object))
curspos=INSTR(dummy$,"_")-1+index
getcur_offset=curspos*8
END FUNCTION


FUNCTION OpenFormWindow(WindowName$,BYVAL treeno,BYVAL edit_obj,BYVAL cancel_obj,BYVAL closeproc&)
SHARED woObjectTree&(2),woBaseX(2),woBaseY(2),woCancelObj(1),woEditObj(1),woEditOffset(1)
SHARED woClose&(1),woCloseForm&(2),WindowSystem,FormWindowSystem,woType(1),HowManyWindows
SHARED woTreeno(2),woHandle(1),forms_enabled
STATIC x,y,w,h,WindowHandle,dummy,dummy$

IF WindowSystem=0 THEN CALL InitWindowSystem
IF FormWindowSystem=0 THEN CALL InitFormWindows

FOR dummy=0 TO HowManyWindows
	IF woTreeno(0,dummy)=treeno THEN OpenFormWindow=woHandle(dummy) : TopAWindow woHandle(dummy) : EXIT FUNCTION
NEXT dummy

SelectTree treeno : form_center tree&,x,y,w,h
junk=wind_calc(0,&h400B,x,y,w,h,x,y,w,h)
IF y<20 THEN y=20

WindowHandle=OpenAWindow(WindowName$,&h400B,x,y,w,h,VARPTRS(dummy_routine),VARPTRS(RedrawFormWind),closeproc&)
IF WindowHandle>=0 THEN
	woType(HowManyWindows)=woTform
	woObjectTree&(0,HowManyWindows)=tree&
	woObjectTree&(1,HowManyWindows)=0
	woTreeno(0,HowManyWindows)=treeno
	woTreeno(1,HowManyWindows)=0
	woBaseX(0,HowManyWindows)=0
	woBaseY(0,HowManyWindows)=0
	woCancelObj(HowManyWindows)=cancel_obj
	woEditObj(HowManyWindows)=edit_obj
	woEditOffset(HowManyWindows)=edit_obj
	IF edit_obj THEN
		dummy$=getobj_text$(edit_obj)
		IF LEFT$(dummy$,1)="@" THEN woEditOffset(HowManyWindows)=0 ELSE	woEditOffset(HowManyWindows)=LEN(dummy$)
	ELSE
		woEditOffset(HowManyWindows)=0
	END IF
	woClose&(HowManyWindows)=VARPTRS(DeleteFormWind)
	woCloseForm&(0,HowManyWindows)=closeproc&
	woCloseForm&(1,HowManyWindows)=0
	init_dialog treeno
	forms_enabled=-1
END IF
OpenFormWindow=WindowHandle
END FUNCTION


FUNCTION OpenDoubleFormWindow(WindowName$,BYVAL treeno,treeno2,BYVAL edit_obj,BYVAL cancel_obj,BYVAL closeproc&,BYVAL closeproc2&)
SHARED woObjectTree&(2),woBaseX(2),woBaseY(2),woCancelObj(1),woEditObj(1),woEditOffset(1)
SHARED woClose&(1),woCloseForm&(2),WindowSystem,FormWindowSystem,woType(1),HowManyWindows
SHARED woTreeno(2),woHandle(1),forms_enabled
STATIC x,y,w,h,x2,y2,w2,h2,x3,y3,w3,h3,MAXw,WindowHandle,dummy,dummy$

IF WindowSystem=0 THEN CALL InitWindowSystem
IF FormWindowSystem=0 THEN CALL InitFormWindows

FOR dummy=0 TO HowManyWindows
	IF woTreeno(0,dummy)=treeno THEN OpenDoubleFormWindow=woHandle(dummy) : TopAWindow woHandle(dummy) : EXIT FUNCTION
	IF woTreeno(1,dummy)=treeno2 THEN OpenDoubleFormWindow=woHandle(dummy) : TopAWindow woHandle(dummy) : EXIT FUNCTION
NEXT dummy

SelectTree treeno : form_center tree&,x,y,w,h
IF y<20 THEN y=20
SelectTree treeno2 : form_center tree&,x2,y2,w2,h2
IF y2<20 THEN y2=20
MAXw=MAX(w,w2)
junk=wind_calc(0,&h400B,x,y2-(h\2),MAXw,h+h2,x3,y3,w3,h3)

WindowHandle=OpenAWindow(WindowName$,&h400B,x3,y3,w3,h3,VARPTRS(dummy_routine),VARPTRS(RedrawFormWind),closeproc&)
IF WindowHandle>=0 THEN
	woType(HowManyWindows)=woTform
	SelectTree treeno : woObjectTree&(0,HowManyWindows)=tree&
	SelectTree treeno2 : woObjectTree&(1,HowManyWindows)=tree&
	woTreeno(0,HowManyWindows)=treeno
	woTreeno(1,HowManyWindows)=treeno2
	woBaseX(0,HowManyWindows)=0
	woBaseX(1,HowManyWindows)=0
	woBaseY(0,HowManyWindows)=0
	woBaseY(1,HowManyWindows)=h
	woCancelObj(HowManyWindows)=cancel_obj
	woEditObj(HowManyWindows)=edit_obj
	IF edit_obj THEN
		dummy$=getobj_text$(edit_obj)
		IF LEFT$(dummy$,1)="@" THEN woEditOffset(HowManyWindows)=0 ELSE	woEditOffset(HowManyWindows)=LEN(dummy$)
	ELSE
		woEditOffset(HowManyWindows)=0
	END IF
	woClose&(HowManyWindows)=VARPTRS(DeleteFormWind)
	woCloseForm&(0,HowManyWindows)=closeproc&
	woCloseForm&(1,HowManyWindows)=closeproc2&
	init_dialog treeno
	init_dialog treeno2
	forms_enabled=-1
END IF
OpenDoubleFormWindow=WindowHandle
END FUNCTION


FUNCTION ObjectWatch(BYVAL WindowHandle,BYVAL object)
STATIC x,y,w,h,event,flag

junk=objc_offset(tree&,object,x,y)
w=getobj_width(object) : h=getobj_height(object) : flag=1
DO
	event=evnt_multi(MU_BUTTON+MU_M1+MU_TIMER,0,3,0,flag,x,y,w,h,_
			0,x,y,w,h,0,hook_timeout,0,0,0,0,0,0)

	IF event AND MU_BUTTON THEN
		EXIT LOOP
	ELSE
		IF event AND MU_M1 THEN
			IF flag THEN
				remove_state object,mask_selected
			ELSE
				include_state object,mask_selected
			END IF
		END IF
		flag=flag XOR 1
		Object_Redraw WindowHandle,object
	END IF
	IF hook_enabled<>0 THEN CALL HandleUserHook
LOOP
ObjectWatch=enquire_state(object,mask_selected)
END FUNCTION


FUNCTION reset_radio(VAL WindowHandle,VAL object)
STATIC first,last,parent,dummy

parent=getobj_parent(object)
first=getobj_head(parent) : IF first=-1 THEN EXIT FUNCTION
last=getobj_tail(parent) : dummy=first
DO
	IF dummy<>object AND enquire_state(dummy,mask_selected)<>0 THEN
		remove_state dummy,mask_selected : reset_radio=dummy : EXIT FUNCTION
	END IF
	dummy=getobj_next(dummy)
LOOP UNTIL dummy=parent
reset_radio=0
END FUNCTION


FUNCTION xform_button(BYVAL WindowHandle,BYVAL object,next_object)
STATIC flags,state,selectable,radio,selected,deselect,exitable,touchexit
STATIC dummy,temp

state=getobj_state(object) : flags=getobj_flags(object)
selectable=flags AND mask_selectable : radio=flags AND mask_rbutton
selected=state AND mask_selected : exitable=flags AND mask_exit
touchexit=flags AND mask_touchexit

next_object=0
IF (state AND mask_disabled) OR (flags AND mask_hidetree) THEN
	xform_button=1 : EXIT FUNCTION
END IF

deselect=0 : dummy=-1
IF selectable THEN
	IF selected THEN
		IF radio=0 THEN remove_state object,mask_selected
	ELSE
		include_state object,mask_selected
		IF radio THEN deselect=reset_radio(WindowHandle,object)
	END IF
	Object_Redraw WindowHandle,object
	IF deselect THEN Object_Redraw WindowHandle,deselect
	IF exitable=0 AND touchexit=0 THEN junk=evnt_button(0,3,0,0,0,0,0)
END IF

IF exitable<>0 AND selectable<>0 THEN
	temp=ObjectWatch(WindowHandle,object)
	IF temp=0 THEN xform_button=1 : EXIT FUNCTION
END IF

IF flags AND mask_editable THEN next_object=object
IF exitable OR touchexit THEN next_object=object : dummy=0
xform_button=dummy
END FUNCTION


FUNCTION HandleFormObject (BYVAL treeno,BYVAL object,BYVAL closedialog&,BYVAL mode)
STATIC extension,aes,screenh,result,old_obj,cur_obj,type,dummy

CommonClose=0
extension=getobj_shortcut(object) : aes=aes_version : screenh=PEEKW(SYSTAB+46)+1
SELECT CASE extension
CASE 11
	set_grouprbutton treeno,getobj_parent(object),object
	SELECT CASE aes
	CASE <&h340
		SELECT CASE screenh
		CASE <400 : sub_icon treeno,object,ICONS,ICON_RAD_1SMS
		CASE >=400 : sub_icon treeno,object,ICONS,ICON_RAD_1S
		END SELECT
	CASE >=&h340
		SELECT CASE screenh
		CASE <400 : sub_icon treeno,object,ICONS,ICON_RAD_4SMS
		CASE >=400 : sub_icon treeno,object,ICONS,ICON_RAD_4S
		END SELECT
	END SELECT
	redraw_object object
	DO
	LOOP UNTIL MOUSE(2)=0
	HandleFormObject=1 : EXIT FUNCTION
CASE 13
	old_obj=900
	DO
		cur_obj=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
		IF cur_obj<>old_obj THEN
		IF mode=1 THEN cur_obj=object
		SELECT CASE cur_obj
		CASE object,object+1
			SELECT CASE aes
			CASE <&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_1SMS
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_1S
				END SELECT
			CASE >=&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_4SMS
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_4S
				END SELECT
			END SELECT
		CASE ELSE
			SELECT CASE aes
			CASE <&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_1SM
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_1
				END SELECT
			CASE >=&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_4SM
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_4
				END SELECT
			END SELECT
		END SELECT
		redraw_object object : old_obj=cur_obj
		END IF
	LOOP UNTIL MOUSE(2)=0
	HandleFormObject=1 : EXIT FUNCTION
CASE 14
	old_obj=900
	DO
		cur_obj=objc_find(tree&,0,10,MOUSE(0),MOUSE(1))
		IF cur_obj<>old_obj THEN
		IF mode=1 THEN cur_obj=object
		SELECT CASE cur_obj
		CASE object,object+1
			SELECT CASE aes
			CASE <&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_1SM
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_1
				END SELECT
			CASE >=&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_4SM
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_4
				END SELECT
			END SELECT
		CASE ELSE
			SELECT CASE aes
			CASE <&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_1SMS
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_1S
				END SELECT
			CASE >=&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,object,ICONS,ICON_BX_4SMS
				CASE >=400 : sub_icon treeno,object,ICONS,ICON_BX_4S
				END SELECT
			END SELECT
		END SELECT
		redraw_object object : old_obj=cur_obj
		END IF
	LOOP UNTIL MOUSE(2)=0
	HandleFormObject=1 : EXIT FUNCTION
CASE ELSE
	extension=getobj_shortcut(object-1)
	SELECT CASE extension
	CASE 11 TO 14
		result=HandleFormObject(treeno,object-1,closedialog&,mode)
		HandleFormObject=result : EXIT FUNCTION
	CASE ELSE
		IF enquire_flags(object,mask_rbutton) THEN
			set_grouprbutton treeno,getobj_parent(object),object
			HandleFormObject=1 : EXIT FUNCTION
		ELSE
			IF closedialog&<>0 THEN
				CommonObj=object : CALLS closedialog&
				IF enquire_state(object,mask_selected) THEN
					type=getobj_type(object)
					extension=getobj_shortcut(object)
					dummy=((type/256)-extension)*256
					IF type=G_BUTTON THEN
						remove_state object,mask_selected
						redraw_object object
					ELSEIF dummy=G_BUTTON THEN
						remove_state object,mask_selected
						redraw_object object
					END IF
				END IF
				IF CommonClose=0 THEN HandleFormObject=1 : EXIT FUNCTION
			END IF
		END IF
	END SELECT
END SELECT
HandleFormObject=0
END FUNCTION


FUNCTION HandleFormClicks(BYVAL button,BYVAL clicks,BYVAL kstate,BYVAL x,BYVAL y)
SHARED woCancelObj(1),woEditOffset(1),woEditObj(1),woClose&(1),woType(1)
SHARED woObjectTree&(2),CommonObj,woTreeno(2),woCloseForm&(2)
STATIC find_handle,CommonIndex,result,object,oldtree&,top_handle,dummy,HowManyObjects
STATIC cobject,go_ahead,x1,y1,w1,h1

find_handle=wind_find(x,y)
CommonIndex=WhichWindow(find_handle) : IF NOT (woType(CommonIndex)=woTform OR woType(CommonIndex)=woTtool) THEN EXIT FUNCTION
oldtree&=tree&
HowManyObjects=0 : IF woObjecttree&(1,CommonIndex) THEN HowManyObjects=1
FOR dummy=0 TO HowManyObjects
SelectTreeAddr woObjecttree&(dummy,CommonIndex) : result=-1

object=objc_find(tree&,0,10,x,y)
junk=wind_get(find_handle,WF_WORKXYWH,x1,y1,w1,h1)
IF (getobj_x(object)+getobj_width(object))>w1 THEN EXIT FUNCTION
IF (getobj_y(object)+getobj_height(object))>h1 THEN EXIT FUNCTION

IF button=1 OR enquire_flags(object,mask_editable)<>0 THEN
	junk=wind_get(0,WF_TOP,top_handle,junk,junk,junk)
	IF find_handle<>top_handle THEN SelectTreeAddr oldtree& : EXIT FUNCTION
END IF

IF object=-1 THEN
	object=0
ELSE
	result=xform_button(find_handle,object,object)
	IF object=woEditObj(CommonIndex) THEN MoveCursor woEditOffset(CommonIndex),object,x,0
END IF

IF (result<>0) AND (object<>0 AND object<>woEditObj(CommonIndex)) THEN
	IF enquire_flags (woEditObj(CommonIndex),mask_editable) THEN
	cobject=woEditObj(CommonIndex)
	go_ahead=0
	DO
		IF enquire_flags(cobject,mask_hidetree) THEN
			go_ahead=-1 : EXIT LOOP
		ELSE
			cobject=getobj_parent(cobject)
		END IF
	LOOP UNTIL cobject=0
	IF go_ahead<>-1 THEN junk=objc_edit(tree&,woEditObj(CommonIndex),0,woEditOffset(CommonIndex),3)
	END IF
END IF

IF result=0 THEN
	result=HandleFormObject (woTreeno(dummy,CommonIndex),object,woCloseForm&(dummy,CommonIndex),0)
	IF result=0 THEN CommonObj=object : CloseAWindow find_handle : CommonObj=-1 : EXIT FOR
ELSE
	IF object<>0 AND woEditObj(CommonIndex)<>object THEN
		woEditObj(CommonIndex)=object
		MoveCursor woEditOffset(CommonIndex),object,x,-1
		object=0
	END IF
END IF
NEXT dummy
SelectTreeAddr oldtree&
END FUNCTION


FUNCTION HandleFormKeys(BYVAL key_pressed,BYVAL kstate)
SHARED woType(1),woObjectTree&(2),woCancelObj(1),woEditOffset(1),woEditObj(1)
SHARED CommonObj,woTreeno(2),woCloseForm&(2)
STATIC top_handle,CommonIndex,result,object,oldtree&,old_offset,dummy,HowManyObjects
STATIC old_key_pressed,cobject,go_ahead,dummy2

HandleFormKeys=0
junk=wind_get(0,WF_TOP,top_handle,junk,junk,junk)
CommonIndex=WhichWindow(top_handle) : IF NOT (woType(CommonIndex)=woTform OR woType(CommonIndex)=woTtool) THEN EXIT FUNCTION

old_key_pressed=key_pressed : oldtree&=tree&
HowManyObjects=0 : IF woObjecttree&(1,CommonIndex) THEN HowManyObjects=1
FOR dummy=0 TO HowManyObjects
SelectTreeAddr woObjecttree&(dummy,CommonIndex) : result=-1

key_pressed=old_key_pressed
IF kstate=8 OR key_pressed=&h6100 OR key_pressed=&h6200 THEN
	object=formcuts(key_pressed,woCancelObj(CommonIndex))
	IF object THEN
		dummy2=getobj_parent(object)
		DO
			IF enquire_flags(dummy2,mask_hidetree) THEN
				HandleFormKeys=0 : EXIT FUNCTION
			ELSE
				dummy2=getobj_parent(dummy2)
			END IF
		LOOP UNTIL dummy2=<0

		HandleFormKeys=-1
		result=xform_button(top_handle,object,object)
		IF result=0 THEN
			IF key_pressed=&h6200 THEN
				result=HandleFormObject (woTreeno(dummy,CommonIndex),object,woCloseForm&(dummy,CommonIndex),0)
			END IF
		END IF
	END IF
ELSE
	result=HandleKeyboard(woEditObj(CommonIndex),kstate,object,key_pressed,woEditOffset(CommonIndex))
	IF key_pressed THEN
		old_offset=woEditOffset(CommonIndex)
		IF enquire_flags (woEditObj(CommonIndex),mask_editable) THEN
			cobject=woEditObj(CommonIndex)
			go_ahead=0
			DO
				IF enquire_flags(cobject,mask_hidetree) THEN
					go_ahead=-1 : EXIT LOOP
				ELSE
					cobject=getobj_parent(cobject)
				END IF
			LOOP UNTIL cobject=0
			IF go_ahead<>-1 THEN junk=objc_edit(tree&,woEditObj(CommonIndex),key_pressed,woEditOffset(CommonIndex),2)
		END IF
		IF old_offset<>woEditOffset(CommonIndex) THEN HandleFormKeys=-1
	END IF
END IF

IF (result<>0) AND (object<>0 AND object<>woEditObj(CommonIndex)) THEN
	IF enquire_flags (woEditObj(CommonIndex),mask_editable) THEN
		cobject=woEditObj(CommonIndex)
		go_ahead=0
		DO
			IF enquire_flags(cobject,mask_hidetree) THEN
				go_ahead=-1 : EXIT LOOP
			ELSE
				cobject=getobj_parent(cobject)
			END IF
		LOOP UNTIL cobject=0
		IF go_ahead<>-1 THEN junk=objc_edit(tree&,woEditObj(CommonIndex),0,woEditOffset(CommonIndex),3)
	END IF
END IF

IF result=0 THEN
	result=HandleFormObject (woTreeno(dummy,CommonIndex),object,woCloseForm&(dummy,CommonIndex),1)
	IF result=0 THEN CommonObj=object : CloseAWindow top_handle : CommonObj=-1 : EXIT FOR
ELSE
	STATIC cobject,go_ahead,old_cobject
	IF object<>0 AND woEditObj(CommonIndex)<>object THEN
		old_cobject=woEditObj(CommonIndex)
		woEditObj(CommonIndex)=object
		IF enquire_flags (object,mask_editable) THEN
			cobject=woEditObj(CommonIndex)
			go_ahead=0
			DO
				IF enquire_flags(cobject,mask_hidetree) THEN
					go_ahead=-1 : EXIT LOOP
				ELSE
					cobject=getobj_parent(cobject)
				END IF
			LOOP UNTIL cobject=0
			IF go_ahead<>-1 THEN
				junk=objc_edit(tree&,object,0,woEditOffset(CommonIndex),1)
			ELSE
				object=old_cobject
				woEditObj(CommonIndex)=object
				junk=objc_edit(tree&,object,0,woEditOffset(CommonIndex),1)
			END IF
		END IF
		object=0
	END IF
END IF
NEXT dummy
SelectTreeAddr oldtree&
END FUNCTION


FUNCTION CloseFormWind
SHARED CommonIndex,CommonObj,woCancelObj(1),woCloseForm&(2),woType(1)
SHARED CommonClose,woTreeno(1),woObjectTree&(2),mess()
STATIC oldtree&,dummy,HowManyObjects

IF NOT (woType(CommonIndex)=woTform OR woType(CommonIndex)=woTtool) THEN CloseFormWind=-1 : EXIT FUNCTION
oldtree&=tree&
HowManyObjects=0 : IF woTreeno(1,CommonIndex)<>0 THEN HowManyObjects=1
FOR dummy=0 TO HowManyObjects
	SelectTreeAddr woObjectTree&(dummy,CommonIndex)
	CommonObj=woCancelObj(CommonIndex)
	IF enquire_flags(CommonObj,mask_selected) THEN remove_state CommonObj,mask_selected
	CommonClose=-1
	CALLS woCloseForm&(dummy,CommonIndex)
	CommonObj=-1
	CloseFormWind=CommonClose
NEXT dummy
SelectTreeAddr oldtree&
END FUNCTION


SUB RedrawFormWind
SHARED woObjectTree&(2),woBaseX(2),woBaseY(2),woEditObj(1),woType(1)
SHARED CommonHandle,CommonIndex,CommonX,CommonY,CommonW,CommonH
STATIC oldtree&,x,y,w,h,dummy

oldtree&=tree&
CommonIndex=WhichWindow(CommonHandle) : IF CommonIndex=0 THEN EXIT SUB
SelectTreeAddr woObjectTree&(0,CommonIndex)
junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h)

IF woType(CommonIndex)=woTtool THEN
	IF w<CommonW THEN CommonW=w
	IF h<CommonH THEN CommonH=h
END IF

IF enquire_state(0,mask_outlined) THEN x=x+3 : y=y+3
setobj_x 0,woBaseX(0,CommonIndex)+x
setobj_y 0,woBaseY(0,CommonIndex)+y
CALL draw_object(0,10,CommonX,CommonY,CommonW,CommonH)

IF woEditObj(CommonIndex) THEN
	junk=wind_get(0,WF_TOP,dummy,0,0,0)
	IF dummy=CommonHandle THEN HandleCursor dummy,1
END IF
SelectTreeAddr oldtree&

IF woObjectTree&(1,CommonIndex)<>0 THEN
	SelectTreeAddr woObjectTree&(1,CommonIndex)
	junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h)
	IF enquire_state(0,mask_outlined) THEN x=x+3 : y=y+3
	setobj_x 0,woBaseX(1,CommonIndex)+x
	setobj_y 0,woBaseY(1,CommonIndex)+y
	CALL draw_object(0,10,CommonX,CommonY,CommonW,CommonH)

	IF woEditObj(CommonIndex) THEN
		junk=wind_get(0,WF_TOP,dummy,0,0,0)
		IF dummy=CommonHandle THEN HandleCursor dummy,1
	END IF
	SelectTreeAddr oldtree&
END IF
END SUB


SUB DeleteFormWind
SHARED woObjectTree&(2),woBaseX(2),woBaseY(2),woCancelObj(1),woEditObj(1),woEditOffset(1)
SHARED woCloseForm&(2),woTreeno(2),CommonHandle,CommonIndex,HowManyWindows,woType(1)
STATIC dummy

FOR dummy=CommonIndex TO HowManyWindows
	woObjectTree&(0,dummy)=woObjectTree&(0,dummy+1)
	woObjectTree&(1,dummy)=woObjectTree&(1,dummy+1)
	woTreeno(0,dummy)=woTreeno(0,dummy+1)
	woTreeno(1,dummy)=woTreeno(1,dummy+1)
	woBaseX(0,dummy)=woBaseX(0,dummy+1)
	woBaseX(1,dummy)=woBaseX(1,dummy+1)
	woBaseY(0,dummy)=woBaseY(0,dummy+1)
	woBaseY(1,dummy)=woBaseY(1,dummy+1)
	woCancelObj(dummy)=woCancelObj(dummy+1)
	woEditObj(dummy)=woEditObj(dummy+1)
	woEditOffset(dummy)=woEditOffset(dummy+1)
	woCloseForm&(0,dummy)=woCloseForm&(0,dummy+1)
	woCloseForm&(1,dummy)=woCloseForm&(1,dummy+1)
NEXT dummy
woObjectTree&(0,HowManyWindows+1)=0
woObjectTree&(1,HowManyWindows+1)=0
woTreeno(0,HowManyWindows+1)=0
woTreeno(1,HowManyWindows+1)=0
woBaseX(0,HowManyWindows+1)=0
woBaseX(1,HowManyWindows+1)=0
woBaseY(0,HowManyWindows+1)=0
woBaseY(1,HowManyWindows+1)=0
woCancelObj(HowManyWindows+1)=0
woEditObj(HowManyWindows+1)=0
woEditOffset(HowManyWindows+1)=0
woCloseForm&(0,HowManyWindows+1)=0
woCloseForm&(1,HowManyWindows+1)=0
END SUB


SUB xENCHANTloop
SHARED mess()
STATIC mclicks,mmask,mstate,mx,my,kstate,key_pressed,clicks,event

REDIM PRESERVE mess(20) : Finished_Flag=0 : CommonClose=0
IF HowManyButtons=1 THEN
	mclicks=2 : mmask=1 : mstate=1
ELSE
	mclicks=258 : mmask=3 : mstate=0
END IF

DO
	event=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON+MU_TIMER,mclicks,mmask,mstate,0,0,0,0,0,0,0,0,0,0,_
		VARPTR(mess(0)),hook_timeout,mx,my,CommonButton,kstate,key_pressed,clicks)

	IF event AND MU_KEYBD THEN HandleKeyboardEvent key_pressed,kstate
	IF event AND MU_MESAG THEN CALL HandleMessage

	IF event AND MU_BUTTON THEN
		IF forms_enabled=-1	THEN
			IF NOT HandleFormClicks(CommonButton,clicks,kstate,mx,my) THEN
				IF clicks_enabled THEN HandleUserClicks clicks,kstate,mx,my
			END IF
		ELSE
			IF clicks_enabled THEN HandleUserClicks clicks,kstate,mx,my
		END IF
	END IF
	IF hook_enabled<>0 THEN CALL HandleUserHook
LOOP UNTIL Finished_Flag<>0
END SUB


SUB HandleCursor(BYVAL WindowHandle,BYVAL mode)
SHARED woEditObj(1),woEditOffset(1),woObjectTree&(2)
STATIC x,y,w,h,CommonIndex,oldtree&,cobject

oldtree&=tree&
CommonIndex=WhichWindow(WindowHandle)
IF woEditObj(CommonIndex) THEN
	cobject=woEditObj(CommonIndex)
	DO
		IF enquire_flags(cobject,mask_hidetree) THEN
			EXIT SUB
		ELSE
			cobject=getobj_parent(cobject)
		END IF
	LOOP UNTIL cobject=0

	IF NOT enquire_flags (woEditObj(CommonIndex),mask_editable) THEN
		IF woObjectTree&(1,CommonIndex)<>0 THEN SelectTreeAddr woObjectTree&(1,CommonIndex)
		IF NOT enquire_flags (woEditObj(CommonIndex),mask_editable) THEN EXIT SUB
	END IF
	ObjectExtent woEditObj(CommonIndex),x,y,w,h
	x=x+getcur_offset(woEditObj(CommonIndex),woEditOffset(CommonIndex))
	junk=objc_draw(tree&,0,10,x,y-3,1,h+6)

	IF mode=1 THEN
		IF enquire_flags (woEditObj(CommonIndex),mask_editable) THEN
			junk=objc_edit(tree&,woEditObj(CommonIndex),0,woEditOffset(CommonIndex),3)
		END IF
	END IF
END IF
SelectTreeAddr oldtree&
END SUB


SUB MoveCursor(index,BYVAL object,BYVAL x_position,BYVAL mode)
SHARED woEditObj(1),CommonIndex
STATIC cursor_position,chars,dummy$,x,old_object,new_index,cobject

IF enquire_flags(object,mask_editable) THEN
cobject=object
DO
	IF enquire_flags(cobject,mask_hidetree) THEN
		EXIT SUB
	ELSE
		cobject=getobj_parent(cobject)
	END IF
LOOP UNTIL cobject=0

IF enquire_flags(object,mask_editable)=0 THEN EXIT SUB
junk=objc_offset(tree&,object,x,junk)
cursor_position=x+getcur_offset(object,index)
new_index=index+(x_position-cursor_position)/8

dummy$=getobj_text$(object)
IF LEFT$(dummy$,1)="@" THEN chars=0 ELSE chars=LEN(dummy$)
new_index=MAX(0,MIN(new_index,chars))
IF object=old_object AND index=new_index THEN
	EXIT SUB
ELSE
	old_object=object
END IF
IF enquire_flags (object,mask_editable) THEN
	IF NOT mode THEN junk=objc_edit(tree&,object,0,index,3)
	index=new_index : junk=objc_edit(tree&,object,0,index,3)
END IF
END IF
END SUB


SUB Object_Redraw(WindowHandle,BYVAL object)
SHARED CommonX,CommonY,CommonW,CommonH
STATIC x1,y1,w1,h1,x,y,w,h,top_handle

ObjectExtent object,x,y,w,h : junk=wind_get(0,WF_TOP,top_handle,0,0,0)
IF WindowHandle=top_handle THEN
	junk=objc_draw(tree&,0,10,x,y,w,h)
	vs_clip 1,x,y,x+w-1,y+h-1 : draw_shortcuts object,10
ELSE
	junk=wind_get(WindowHandle,WF_FIRSTXYWH,x1,y1,w1,h1)
	WHILE (w1<>0) AND (h1<>0)
		IF WindInter(x,y,w,h,x1,y1,w1,h1,CommonX,CommonY,CommonW,CommonH) THEN
			vs_clip 1,CommonX,CommonY,CommonX+CommonW-1,CommonY+CommonH-1
			junk=objc_draw(tree&,0,10,CommonX,CommonY,CommonW,CommonH)
			draw_shortcuts object,10
		END IF
		junk=wind_get(WindowHandle,WF_NEXTXYWH,x1,y1,w1,h1)
	WEND
END IF
END SUB


SUB MultiObject_Redraw(BYVAL WindowHandle,BYVAL object)
STATIC x,y,w,h

ObjectExtent object,x,y,w,h : Redraw WindowHandle,x,y,w,h
END SUB


SUB HandleKeyboardEvent(BYVAL key_pressed,BYVAL kstate)
SHARED menus_enabled,keys_enabled,forms_enabled,TextWindowSystem

IF menus_enabled THEN
	IF TextWindowSystem THEN CALL TextWindLoop (key_pressed)
	IF CreateShortCut(key_pressed,kstate) THEN
		HandleMessage
	ELSE
		IF forms_enabled THEN
			IF HandleFormKeys(key_pressed,kstate) THEN
				IF keys_enabled THEN HandleUserKeys CHR$(key_pressed AND 255),key_pressed,kstate
				EXIT SUB
			END IF
		END IF
		IF keys_enabled THEN HandleUserKeys CHR$(key_pressed AND 255),key_pressed,kstate
	END IF
ELSE
	IF forms_enabled THEN
		IF HandleFormKeys(key_pressed,kstate) THEN
			IF keys_enabled THEN HandleUserKeys CHR$(key_pressed AND 255),key_pressed,kstate
			EXIT SUB
		END IF
	END IF
	IF keys_enabled THEN HandleUserKeys CHR$(key_pressed AND 255),key_pressed,kstate
END IF
END SUB

'[*END OF FILE*]
