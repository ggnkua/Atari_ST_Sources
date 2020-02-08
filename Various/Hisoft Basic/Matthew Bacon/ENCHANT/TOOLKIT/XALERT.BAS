
' [xALERT.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

' The file xDIALOG.BAS is required to use xALERT.BAS

FUNCTION init_alert (default_button,text$)
SHARED total_button
STATIC dummy,dummy$,cur_pos,old_pos,button,row
STATIC button1$,button2$,button3$,temp,alertarr$()

FOR dummy=WALERT_TEXT1 TO WALERT_BUT3
	IF enquire_flags (dummy,mask_hidetree)=-1 THEN remove_flags dummy,mask_hidetree
	IF enquire_state (dummy,mask_default)=-1 THEN remove_flags dummy,mask_default
	setobj_spec_str dummy,""
NEXT dummy

dummy=VAL(MID$(text$,2,1))
SELECT CASE dummy
CASE 1 : sub_icon form_alertbox,WALERT_ICON,ICONS,ICON_ALERT1
CASE 2 : sub_icon form_alertbox,WALERT_ICON,ICONS,ICON_ALERT2
CASE 3 : sub_icon form_alertbox,WALERT_ICON,ICONS,ICON_ALERT3
CASE ELSE : sub_icon form_alertbox,WALERT_ICON,ICONS,ICON_ALERT0
END SELECT

DIM alertarr$(16)
old_pos=5 : button=0 : row=0
FOR cur_pos=5 TO LEN(text$)
	dummy$=MID$(text$,cur_pos,1)
	SELECT CASE dummy$
	CASE "|"
		INCR row : IF cur_pos=old_pos THEN old_pos=cur_pos+1 : EXIT SELECT
		alertarr$(row)=MID$(text$,old_pos,cur_pos-old_pos)
		old_pos=cur_pos+1 : IF row=7 THEN EXIT FOR
	CASE "]"
		INCR row : IF cur_pos=old_pos THEN EXIT SELECT
		alertarr$(row)=MID$(text$,old_pos,cur_pos-old_pos)
		old_pos=cur_pos : button=1 : IF row>=7 THEN EXIT FOR
	CASE "["
		IF button<>1 THEN ERASE alertarr$ : init_alert=0 : ERASE alertarr$ : EXIT FUNCTION
		row=4 : IF cur_pos=old_pos THEN EXIT SELECT
		old_pos=cur_pos+1
	END SELECT
NEXT cur_pos

temp=0
FOR dummy=WALERT_TEXT1 TO WALERT_TEXT4
	INCR temp
	setobj_spec_str dummy,LEFT$(alertarr$(temp),30)
NEXT dummy

total_button=row-4
SELECT CASE total_button
CASE 1
	setobj_spec_str WALERT_BUT3,LEFT$(alertarr$(5),7)
	IF default_button>=1 THEN include_flags WALERT_BUT3,mask_default
	include_flags WALERT_BUT1,mask_hidetree
	include_flags WALERT_BUT2,mask_hidetree
CASE 2
	setobj_spec_str WALERT_BUT2,LEFT$(alertarr$(5),7)
	setobj_spec_str WALERT_BUT3,LEFT$(alertarr$(6),7)
	include_flags WALERT_BUT1,mask_hidetree
	IF default_button=1 THEN include_flags WALERT_BUT2,mask_default
	IF default_button>=2 THEN include_flags WALERT_BUT3,mask_default
CASE 3
	setobj_spec_str WALERT_BUT1,LEFT$(alertarr$(5),7)
	setobj_spec_str WALERT_BUT2,LEFT$(alertarr$(6),7)
	setobj_spec_str WALERT_BUT3,LEFT$(alertarr$(7),7)
	IF default_button=1 THEN include_flags WALERT_BUT1,mask_default
	IF default_button=2 THEN include_flags WALERT_BUT2,mask_default
	IF default_button>=3 THEN include_flags WALERT_BUT3,mask_default
END SELECT

FOR temp=WALERT_BUT1 TO WALERT_BUT3
	dummy=1
	IF LEN(getobj_spec$(temp))<>0 THEN
		IF temp=WALERT_BUT1 THEN button1$=MID$(getobj_spec$(temp),dummy,1)
		IF temp=WALERT_BUT2 THEN
			button2$=MID$(getobj_spec$(temp),dummy,1)
			DO
				IF button2$=button1$ THEN
					INCR dummy
					IF dummy>LEN(getobj_spec$(temp)) THEN dummy=0 : EXIT LOOP
					button2$=MID$(getobj_spec$(temp),dummy,1)
				END IF
			LOOP UNTIL button2$<>button1$
		END IF
		IF temp=WALERT_BUT3 THEN
			button3$=MID$(getobj_spec$(temp),dummy,1)
			DO
				IF button3$=button1$ THEN
					INCR dummy
					IF dummy>LEN(getobj_spec$(temp)) THEN dummy=0 : EXIT LOOP
					button3$=MID$(getobj_spec$(temp),dummy,1)
				ELSE
					IF button3$=button2$ THEN
						INCR dummy
						IF dummy>LEN(getobj_spec$(temp)) THEN dummy=0 : EXIT LOOP
						button3$=MID$(getobj_spec$(temp),dummy,1)
					ELSE
						EXIT LOOP
					END IF
				END IF
			LOOP
		END IF
		IF dummy<>0 THEN setobj_shortcut temp,MID$(getobj_spec$(temp),dummy,1)
	END IF
NEXT temp
ERASE alertarr$ : init_alert=-1
END FUNCTION


FUNCTION xalert(BYVAL default_button,BYVAL text$)
SHARED total_button
STATIC x,y,w,h,oldtree&,outx,outy,result,event,index,flags
STATIC Finished_AFlag,mx,my,button,kstate,key_pressed,clicks,object,old_object

IF LEN(text$)=<7 THEN xalert=0 : EXIT FUNCTION
oldtree&=tree& : SelectTree form_alertbox
result=init_alert (default_button,text$)

IF result=-1 THEN
	form_center tree&,x,y,w,h
	CALL save_scralert (x,y,w,h,1)
	junk=wind_update(BEG_MCTRL)
	form_dial FMD_START,0,0,0,0,x,y,w,h
	form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
	CALL draw_object(0,10,x,y,w,h)

	Finished_AFlag=1
	WHILE Finished_AFlag
		event=evnt_multi(MU_KEYBD+MU_BUTTON+MU_TIMER,2,1,1,0,0,0,0,0,_
			0,0,0,0,0,0,hook_timeout,mx,my,button,kstate,key_pressed,clicks)

	IF event AND MU_KEYBD THEN
		IF kstate=8 THEN
			object=formcuts(key_pressed,0) : old_object=object
			IF object THEN Finished_AFlag=form_button(tree&,object,clicks,object)
		ELSE
			Finished_AFlag=HandleKeyboard(0,kstate,object,key_pressed,index)
		END IF
	END IF

	IF event AND MU_BUTTON THEN
		object=objc_find(tree&,0,10,mx,my)
		SELECT CASE object
		CASE -1 : BEEP : object=0
		CASE 0
			MOUSE 4
			graf_dragbox w,h,x,y,PEEKW(SYSTAB+40)+1,PEEKW(SYSTAB+42)+19,PEEKW(SYSTAB+44),PEEKW(SYSTAB+46)-19,outx,outy
			setobj_xywh object,outx+3,outy+3,w-6,h-6
			save_scralert x,y,w,h,0 : x=outx : y=outy : save_scralert x,y,w,h,1
			CALL draw_object(object,10,x,y,w,h)
			MOUSE 0
		CASE ELSE
			flags=getobj_flags(object)
			IF (flags AND mask_hidetree)=0 THEN
				IF flags AND (mask_selectable OR mask_exit OR mask_touchexit OR mask_editable) THEN
					old_object=object
					Finished_AFlag=form_button(tree&,object,clicks,object)
				ELSE
					MOUSE 4
					graf_dragbox w,h,x,y,PEEKW(SYSTAB+40)+1,PEEKW(SYSTAB+42)+19,PEEKW(SYSTAB+44),PEEKW(SYSTAB+46)-19,outx,outy
					setobj_xywh 0,outx+3,outy+3,w-6,h-6
					save_scralert x,y,w,h,0 : x=outx : y=outy : save_scralert x,y,w,h,1
					CALL draw_object(0,10,x,y,w,h)
					MOUSE 0
				END IF
			END IF
		END SELECT
	END IF
	IF old_object THEN
		IF getobj_type(old_object) AND &hFF00 THEN
			IF enquire_flags(old_object,mask_rbutton) THEN
				old_object=getobj_parent(old_object)
			END IF
			draw_shortcuts getobj_parent(old_object),10
		END IF
	END IF
	IF hook_enabled<>0 THEN CALL HandleUserHook
	WEND
	form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
'	form_dial FMD_FINISH,0,0,0,0,x,y,w,h	REM For some reason, when this is not commentted
											REM out, using WINDOW.BAS causes a crash!?
	junk=wind_update(END_MCTRL)
	CALL save_scralert (x,y,w,h,0)
	IF enquire_state(object,mask_selected) THEN remove_state object,mask_selected
	xalert=(object-4)-total_button
ELSE
	xalert=0
END IF
tree&=oldtree&
END FUNCTION


SUB save_scralert (BYVAL x,BYVAL y,BYVAL w,BYVAL h,BYVAL mode)
STATIC dummy,dummy&,quick,alertarr()

x=MAX(x,0)
IF mode THEN
	dummy=PEEKW(SYSTAB)
	dummy&=2*(h+1)*((w+1)\16+1)+6
	IF (dummy&\(2*dummy))<malloc&(-1) THEN
		quick=-1
		DIM alertarr(dummy&*dummy)
		GET (x,y)-(x+w,y+h),alertarr
	ELSE
		quick=0
		form_dial FMD_START,0,0,0,0,x,y,w,h
	END IF
ELSE
	IF quick THEN
		PUT(x,y),alertarr,PSET
		ERASE alertarr
	ELSE
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
	END IF
END IF
END SUB

'[*END OF FILE*]
