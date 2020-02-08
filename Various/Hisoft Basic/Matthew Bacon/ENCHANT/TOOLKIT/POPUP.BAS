
' [POPUP.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION getobj_poptext$(BYVAL treeno,BYVAL object)
STATIC oldtree&,type,dummy$

oldtree&=tree&
SelectTree treeno
type=getobj_type(object)
SELECT CASE type
CASE G_STRING
	dummy$=RTRIM$(LTRIM$(getobj_spec$(object)))
CASE G_TEXT
	dummy$=RTRIM$(LTRIM$(getobj_text$(object)))
END SELECT
getobj_poptext$=dummy$
tree&=oldtree&
END FUNCTION


FUNCTION popable(BYVAL object,BYVAL poptreeno)
STATIC disabled,hidden

IF object<>poptreeno THEN
	disabled=enquire_state(object,mask_disabled)	
	hidden=enquire_flags(object,mask_hidetree)		
	IF (disabled OR hidden) THEN 
		popable=0
	ELSE
		popable=-1
	END IF
ELSE
	popable=0
END IF
END FUNCTION


FUNCTION getobj_popparent(BYVAL object)
STATIC dummy

IF object=0 THEN
	getobj_popparent=-1
ELSE
	DO
		dummy=getobj_next(object)
		IF getobj_tail(dummy)=object THEN EXIT LOOP
		object=dummy
	LOOP
	getobj_popparent=dummy
END IF
END FUNCTION


FUNCTION popup_keyboard(BYVAL key_pressed,Finished_PFlag,BYVAL poptreeno)
STATIC last_object,sel_object,dummy

last_object=poptreeno : sel_object=poptreeno : dummy=0
DO
	INCR last_object
	IF enquire_state(last_object,mask_selected) THEN sel_object=last_object
	IF enquire_flags(last_object,mask_lastob) THEN dummy=1 : EXIT LOOP
LOOP UNTIL getobj_popparent(last_object)<>poptreeno
IF dummy<>1 THEN DECR last_object


SELECT CASE key_pressed
	CASE &h5000 ' curser down
		INCR sel_object : IF NOT popable(sel_object,poptreeno) THEN INCR sel_object
	CASE &h4800 ' curser up
		DECR sel_object : IF NOT popable(sel_object,poptreeno) THEN DECR sel_object
	CASE &h1C0D : Finished_PFlag=-1 ' return
	CASE &h6100 : popup_keyboard=-1 : Finished_PFlag=-1 : EXIT FUNCTION
	CASE &h4700 : sel_object=poptreeno+1
	CASE &h4737 : sel_object=last_object
	CASE &h4838 : sel_object=poptreeno+1  ' shift+up
	CASE &h5032 : sel_object=last_object  ' shift+down

	CASE &h4B00 : popup_keyboard=-1 : Finished_PFlag=-1
	CASE &h4D00 : popup_keyboard=-1 : Finished_PFlag=-1
	CASE &h11B  : popup_keyboard=-1 : Finished_PFlag=-1 ' esc
	CASE &h720D : Finished_PFlag=-1 ' enter
END SELECT
sel_object=MAX(poptreeno+1,MIN(sel_object,last_object))
popup_keyboard=sel_object
END FUNCTION


SUB DeselectObject(BYVAL object)
STATIC state

state=getobj_state(object)
IF enquire_flags(object,mask_selectable) THEN
	junk=objc_change(tree&,object,0,0,0,0,state AND (NOT mask_selected),1)
END IF
END SUB


SUB SelectObject(BYVAL object)
STATIC state

state=getobj_state(object)
IF enquire_flags(object,mask_selectable) THEN
	junk=objc_change(tree&,object,0,0,0,0,state OR mask_selected,1)
END IF
END SUB


SUB objc_rect(BYVAL object,x,y,w,h)
junk=objc_offset(tree&,object,x,y)
w=getobj_width(object)
h=getobj_height(object)
END SUB


FUNCTION handlepopup(BYVAL old_object,poptreeno)
STATIC Finished_PFlag,new_object,objectx,objecty,objectw,objecth
STATIC boxx,boxy,boxw,boxh,MU_FLAG,flag,event,mx,my,key_pressed
STATIC type,dummy$

Finished_PFlag=0 : new_object=old_object
IF old_object THEN 
	objc_rect old_object,objectx,objecty,objectw,objecth
ELSE
	objectw=0 : objecth=0
END IF
objc_rect poptreeno,boxx,boxy,boxw,boxh : flag=0 : MU_FLAG=MU_M2

DO
	event=evnt_multi(MU_BUTTON+MU_KEYBD+MU_FLAG+MU_TIMER,257,3,0,1,_
		objectx,objecty,objectw,objecth,flag,boxx,boxy,boxw,boxh,_
			0,0,mx,my,0,0,key_pressed,0)

	IF event AND MU_M2 THEN
		flag=flag XOR 1
		MU_FLAG=MU_FLAG XOR MU_M1
		IF flag THEN
			objectw=0 : objecth=0
		ELSE
			IF old_object THEN DeselectObject old_object : old_object=0
		END IF
	END IF

	IF event AND MU_M1 THEN 
		new_object=objc_find(tree&,poptreeno,10,mx,my)
		IF new_object>0 THEN objc_rect new_object,objectx,objecty,objectw,objecth
	END IF

	IF event AND MU_BUTTON THEN
		IF flag=0 THEN new_object=-1
		Finished_PFlag=-1
	END IF

	IF event AND MU_KEYBD THEN
		 new_object=popup_keyboard(key_pressed,Finished_PFlag,poptreeno)
	END IF

	IF new_object<>old_object AND new_object>0 THEN
		IF popable(new_object,poptreeno) THEN
			SelectObject new_object
			IF old_object THEN DeselectObject old_object
			old_object=new_object
		ELSE
			new_object=0
		END IF
	END IF
LOOP UNTIL Finished_PFlag

IF old_object THEN remove_state old_object,mask_selected
IF new_object>poptreeno THEN
	type=getobj_type(new_object)
	SELECT CASE type
	CASE G_STRING
		dummy$=RTRIM$(LTRIM$(getobj_spec$(new_object)))
		IF INSTR(dummy$,CHR$(3)) THEN
			handlepopup=0
		ELSE
			handlepopup=new_object
		END IF
	CASE G_TEXT
		dummy$=RTRIM$(LTRIM$(getobj_text$(new_object)))
		IF INSTR(dummy$,CHR$(3)) THEN
			handlepopup=0
		ELSE
			handlepopup=new_object
		END IF
	CASE ELSE : handlepopup=new_object
	END SELECT
ELSE
	handlepopup=0
END IF
junk=evnt_button(0,3,0,0,0,0,0)
END FUNCTION


FUNCTION do_popup(BYVAL WindowHandle,BYVAL CommonObj,BYVAL treeno,BYVAL poptreeno,BYVAL old_object,BYVAL multi_onoff)
STATIC screenx,screeny,screenh,screenw,WindX,WindY,WindW,WindH
STATIC x,y,w,h,x1,y1,w1,h1,oldtree&,cellh,object,dummy,total_popups_checked

junk=objc_offset(tree&,CommonObj,x,y) : junk=wind_update(1) : junk=wind_update(3)
junk=wind_get(0,WF_WORKXYWH,screenx,screeny,screenw,screenh)

IF WindowHandle THEN
	junk=wind_get(WindowHandle,WF_WORKXYWH,WindX,WindY,WindW,WindH)
	Intersection screenx,screeny,screenw,screenh,WindX,WindY,WindW,WindH,x1,y1,w1,h1
ELSE
	x1=screenx : y1=screeny : w1=screenw : h1=screenh
END IF

oldtree&=tree& : SelectTree treeno
IF old_object THEN 
	IF enquire_flags(old_object,mask_selectable) THEN
		include_state old_object,mask_checked+mask_selected
	END IF
	junk=graf_handle(junk,cellh,junk,junk)
	y=y-((old_object-poptreeno-1)*cellh)
END IF

w=getobj_width(poptreeno)+4 : h=getobj_height(poptreeno)+4
IF (x+w)>(x1+w1) THEN
	x=(x1+w1)-w-1
ELSE
	IF x<x1 THEN x=x1
END IF

IF (y+h)>(y1+h1) THEN
	y=(y1+h1)-h-1
ELSE
	IF y<y1 THEN y=y1
END IF

setobj_x poptreeno,x : setobj_y poptreeno,y : DECR x : DECR y
save_popscr x,y,w,h,1 : junk=objc_draw(tree&,poptreeno,10,x,y,w,h)
object=handlepopup(old_object,poptreeno)

IF multi_onoff=0 THEN
	remove_state old_object,mask_checked
ELSE
	IF enquire_state(object,mask_checked) THEN
		dummy=poptreeno : total_popups_checked=0
		DO
			IF enquire_state(dummy,mask_checked) THEN INCR total_popups_checked
			IF NOT getobj_child(poptreeno,dummy) THEN EXIT LOOP
			IF enquire_flags(dummy,mask_lastob) THEN EXIT LOOP
			INCR dummy
		LOOP
		IF total_popups_checked>1 THEN
			remove_state object,mask_checked
			object=poptreeno : dummy=object
			DO
				IF enquire_state(dummy,mask_checked) THEN object=dummy : EXIT LOOP
				IF NOT getobj_child(poptreeno,dummy) THEN EXIT LOOP
				IF enquire_flags(dummy,mask_lastob) THEN EXIT LOOP
				INCR dummy
			LOOP
		END IF
	ELSE
		include_state object,mask_checked
	END IF
END IF

IF object THEN
	remove_state object,mask_selected
ELSE
	object=old_object
END IF
save_popscr x,y,w,h,0 : do_popup=object : tree&=oldtree&
junk=wind_update(2) : junk=wind_update(0)
END FUNCTION


FUNCTION getobj_popshortcut(BYVAL object)
	getobj_popshortcut=(getobj_type(object)\256)
END FUNCTION


SUB save_popscr(BYVAL x,BYVAL y,BYVAL w,BYVAL h,BYVAL mode)
STATIC dummy,size&,dummy(),quick

x=MAX(x,0)
IF mode THEN
	dummy=PEEKW(SYSTAB)
	size&=2*(h+1)*((w+1)\16+1)+6
	IF size&\2*dummy<malloc&(-1) THEN 
		quick=-1
		REDIM dummy(size&*dummy)
		GET (x,y)-(x+w,y+h),dummy
	ELSE
		quick=0
		form_dial FMD_START,0,0,0,0,x,y,w,h
	END IF
ELSE
	IF quick THEN
		PUT(x,y),dummy,PSET
		ERASE dummy
	ELSE
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
	END IF
END IF
END SUB


SUB substitute_image (BYVAL treeno,BYVAL object,BYVAL s_treeno,BYVAL s_object)
STATIC oldtree&,x,y,s_type,s_spec&

oldtree&=tree& : SelectTree s_treeno
s_type=getobj_type(s_object)
s_spec&=getobj_spec&(s_object)
SelectTree treeno
x=getobj_x (object)
y=getobj_y (object)
setobj_x object,x
setobj_y object,y
setobj_type object,s_type
setobj_spec object,s_spec&
tree&=oldtree&
END SUB


SUB setobj_poptext(BYVAL object,BYVAL dummy$)
STATIC dummy,dummy$,temp

setobj_text object,dummy$ : setobj_popshortcut object,CHR$(1)
dummy$=UCASE$(RTRIM$(LTRIM$(dummy$)))
FOR dummy=1 TO LEN(dummy$) 
	temp=1
	DO
		IF ASC(MID$(dummy$,dummy,1))=getobj_popshortcut(temp) THEN EXIT LOOP
		IF enquire_flags(temp,mask_lastob) THEN
			IF MID$(dummy$,dummy,1)<>" " THEN
				setobj_popshortcut object,MID$(dummy$,dummy,1)
				EXIT FOR
			END IF
		END IF
		INCR temp
	LOOP UNTIL temp=255
NEXT dummy
END SUB


SUB setobj_popshortcut(BYVAL object,BYVAL dummy$)
IF dummy$<>" " THEN POKEB ObjectAddr&(object)+ob_type,ASC(UCASE$(dummy$))
END SUB


SUB radio_poptext(BYVAL object,BYVAL poptreeno,BYVAL popparent,popobject)
STATIC oldtree&,first_object,last_object,dummy$,dummy

IF popobject=0 THEN popobject=popparent
oldtree&=tree& : SelectTree poptreeno
first_object=getobj_head(popparent)
last_object=getobj_tail(popparent)
dummy=popobject
DO
	IF (popobject+1)>last_object THEN
		popobject=first_object
	ELSE
		INCR popobject
	END IF
	IF popable(popobject,poptreeno) THEN
		remove_state dummy,mask_checked
		IF dummy THEN remove_state dummy,mask_selected

		dummy$=getobj_spec$(popobject)
		tree&=oldtree&
		setobj_poptext object,dummy$
		EXIT LOOP
	END IF
	IF enquire_flags(popobject,mask_lastob) THEN EXIT LOOP
LOOP 
END SUB


SUB radio_popimage(BYVAL treeno,BYVAL object,BYVAL poptreeno,BYVAL popparent,popobject)
STATIC oldtree&,first_object,last_object,dummy$

IF popobject=0 THEN popobject=popparent
oldtree&=tree& : SelectTree poptreeno
first_object=getobj_head(popparent)
last_object=getobj_tail(popparent)

DO
	IF (popobject+1)>last_object THEN
		popobject=first_object
	ELSE
		INCR popobject
	END IF
	IF popable(popobject,poptreeno) THEN
		tree&=oldtree&
		substitute_image treeno,object,poptreeno,popobject
		EXIT LOOP
	END IF
	IF enquire_flags(popobject,mask_lastob) THEN EXIT LOOP
LOOP
END SUB


FUNCTION multi_popup(BYVAL WindowHandle,BYVAL CommonObj,BYVAL treeno,BYVAL poptreeno,BYVAL old_object)
STATIC dummy,multi_onoff

multi_onoff=-1
dummy=do_popup(WindowHandle,CommonObj,treeno,poptreeno,old_object,multi_onoff)
multi_popup=dummy
END FUNCTION


FUNCTION popup(BYVAL WindowHandle,BYVAL CommonObj,BYVAL treeno,BYVAL poptreeno,BYVAL old_object)
STATIC dummy,multi_onoff

multi_onoff=0
dummy=do_popup(WindowHandle,CommonObj,treeno,poptreeno,old_object,multi_onoff)
popup=dummy
END FUNCTION


FUNCTION do_menupopup(BYVAL WindowHandle,BYVAL CommonObj,BYVAL treeno,BYVAL poptreeno)
STATIC screenx,screeny,screenh,screenw,WindX,WindY,WindW,WindH
STATIC x,y,w,h,x1,y1,w1,h1,oldtree&,cellh,object,dummy

junk=objc_offset(tree&,CommonObj,x,y)
y=y+getobj_height(CommonObj)+1
junk=wind_update(1) : junk=wind_update(3)
junk=wind_get(0,WF_WORKXYWH,screenx,screeny,screenw,screenh)

IF WindowHandle THEN
	junk=wind_get(WindowHandle,WF_WORKXYWH,WindX,WindY,WindW,WindH)
	Intersection screenx,screeny,screenw,screenh,WindX,WindY,WindW,WindH,x1,y1,w1,h1
ELSE
	x1=screenx : y1=screeny : w1=screenw : h1=screenh
END IF

oldtree&=tree& : SelectTree treeno
w=getobj_width(poptreeno)+4 : h=getobj_height(poptreeno)+4

setobj_x poptreeno,x : setobj_y poptreeno,y : DECR x : DECR y
save_popscr x,y,w,h,1 : junk=objc_draw(tree&,poptreeno,10,x,y,w,h)
object=handlepopup(0,poptreeno)
IF object THEN remove_state object,mask_selected
save_popscr x,y,w,h,0 : do_menupopup=object : tree&=oldtree&
junk=wind_update(2) : junk=wind_update(0)
END FUNCTION


FUNCTION popup_menu(BYVAL WindowHandle,BYVAL CommonObj,BYVAL treeno,BYVAL poptreeno)
STATIC dummy

dummy=do_menupopup(WindowHandle,CommonObj,treeno,poptreeno)
popup_menu=dummy
END FUNCTION

'[*END OF FILE*]
