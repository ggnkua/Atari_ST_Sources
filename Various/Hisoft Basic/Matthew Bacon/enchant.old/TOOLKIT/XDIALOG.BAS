
' [xDIALOG.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

' FUNCTION ConvertAlt (ScanCode)		' Can be found in TOOLBX_C.BAS

FUNCTION getobj_just(BYVAL object)
STATIC dummy&

dummy&=getobj_spec&(object)
getobj_just=PEEKW(dummy&+te_just)
END FUNCTION


FUNCTION getobj_font(BYVAL object)
STATIC dummy&

dummy&=getobj_spec&(object)
getobj_font=PEEKW(dummy&+te_font)
END FUNCTION


FUNCTION getobj_parent(BYVAL object)
STATIC dummy

IF object=0 THEN
	getobj_parent=-1
ELSE
	DO
		dummy=getobj_next(object)
		IF getobj_tail(dummy)=object THEN EXIT LOOP
		object=dummy
	LOOP
	getobj_parent=dummy
END IF
END FUNCTION


FUNCTION getobj_child(BYVAL parent,BYVAL child)
STATIC dummy

IF parent=0 THEN
	getobj_child=-1 : EXIT FUNCTION
ELSE
	dummy=child
	DO
		IF dummy=parent THEN
			getobj_child=-1
			EXIT LOOP
		END IF
		dummy=getobj_parent(dummy)
		IF dummy<0 THEN
			getobj_child=0
			EXIT FUNCTION
		END IF
	LOOP
END IF
END FUNCTION


FUNCTION getobj_depth (BYVAL startobj,BYVAL object,BYVAL depth)
STATIC how_deep

IF depth=10 OR depth=0 THEN getobj_depth=0 : EXIT FUNCTION
how_deep=0
DO
	object=getobj_parent(object)
	INCR how_deep
LOOP UNTIL object=-1 OR object=startobj
IF how_deep>depth THEN getobj_depth=-1 ELSE getobj_depth=0
END FUNCTION


FUNCTION HandleKeyboard(BYVAL cur_edit,BYVAL kstate,new_edit,key_pressed,index)
SELECT CASE key_pressed
	CASE=&h4b34
		junk=objc_edit(tree&,cur_edit,key_pressed,index,3)
		index=0
		junk=objc_edit(tree&,cur_edit,key_pressed,index,3)
		key_pressed=0
		HandleKeyboard=1
	CASE=&h4d36
		junk=objc_edit(tree&,cur_edit,key_pressed,index,3)
		junk=objc_edit(tree&,cur_edit,key_pressed,index,1)
		key_pressed=0
		HandleKeyboard=1
	CASE ELSE
		IF key_pressed=&h5032 OR key_pressed=&h4838 THEN key_pressed=key_pressed AND &hFF00
		IF key_pressed=&h0f09 AND (kstate AND 3) THEN key_pressed=&h0f00
		HandleKeyboard=form_keybd(tree&,0,cur_edit,key_pressed,new_edit,key_pressed)
END SELECT
END FUNCTION


FUNCTION formcuts(BYVAL key_pressed,BYVAL undo_obj)
STATIC dummy,dummy$,type,char_ascii

IF key_pressed=&h6100 THEN formcuts=undo_obj : EXIT FUNCTION
IF key_pressed=&h6200 THEN
	FOR dummy=1 TO 255
		type=getobj_type(dummy)
		IF type=G_BUTTON THEN
			dummy$=getobj_spec$(dummy)
			IF INSTR(UCASE$(dummy$),"HELP") THEN
				formcuts=dummy : EXIT FUNCTION
			END IF
		END IF
		IF enquire_flags(dummy,mask_lastob) THEN EXIT FOR
	NEXT dummy
END IF

char_ascii=convertalt(key_pressed AND &hFF00)
FOR dummy=1 TO 255
	type=getobj_type(dummy)\256
	IF char_ascii=type THEN
		formcuts=dummy
		EXIT FOR
	ELSE
		formcuts=0
	END IF
	IF enquire_flags(dummy,mask_lastob) THEN EXIT FOR
NEXT dummy
END FUNCTION


FUNCTION getobj_shortcut(BYVAL object)
	getobj_shortcut=(getobj_type(object)\256)
END FUNCTION


SUB save_scrdialog (BYVAL x,BYVAL y,BYVAL w,BYVAL h,BYVAL mode)
STATIC dummy,dummy&,quick,dialogarr()

x=MAX(x,0)
IF mode THEN
	dummy=PEEKW(SYSTAB)
	dummy&=2*(h+1)*((w+1)\16+1)+6
	IF dummy&\2*dummy<malloc&(-1) THEN
		quick=-1
		DIM dialogarr(dummy&*dummy)
		GET (x,y)-(x+w,y+h),dialogarr
	ELSE
		quick=0
		form_dial FMD_START,0,0,0,0,x,y,w,h
	END IF
ELSE
	IF quick THEN
		PUT(x,y),dialogarr,PSET
		ERASE dialogarr
	ELSE
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
	END IF
END IF
END SUB


SUB draw_shortcuts (BYVAL object,BYVAL depth)
SHARED sysfont_h,sysfont_w
STATIC dummy,temp,type,flags

graf_mouse 256,0
junk=graf_handle(sysfont_w,sysfont_h,0,0)
dummy=object
DO
	type=getobj_type(dummy)
	flags=getobj_flags(dummy)
	IF type AND &hFF00 THEN
		IF NOT enquire_flags(getobj_parent(dummy),mask_hidetree) THEN
		IF flags AND (mask_selectable OR mask_exit OR mask_touchexit) THEN
			IF (flags AND mask_hidetree)=0 THEN
				IF NOT getobj_depth(object,dummy,depth) THEN
					IF getobj_child(object,dummy) THEN workout_underline dummy,type
				END IF
			END IF
		ELSE
			temp=dummy-1
			SELECT CASE temp
				CASE 10 TO 14
					IF (flags AND mask_hidetree)=0 THEN
						IF NOT getobj_depth(object,dummy,depth) THEN
							IF getobj_child(object,dummy) THEN workout_underline dummy,type
						END IF
					END IF
				CASE ELSE
					IF (flags AND mask_hidetree)=0 THEN
						IF NOT getobj_depth(object,dummy,depth) THEN
							IF getobj_child(object,dummy) THEN workout_underline dummy,type
						END IF
					END IF
			END SELECT
		END IF
		END IF
	END IF
	INCR dummy
LOOP UNTIL depth=0 OR (flags AND mask_lastob)
graf_mouse 257,0
END SUB


SUB workout_underline(BYVAL object,BYVAL type)
SHARED sysfont_h,sysfont_w
STATIC x,y,w,h,text$,char_pos,text_w,char_x,char_w,char_h,just,char_ascii

char_ascii=type\256 : type=type AND &hFF : char_h=sysfont_h : char_w=sysfont_w

IF type=G_BUTTON OR type=G_STRING THEN
	text$=getobj_spec$(object)
ELSEIF type=G_TEXT OR type=G_BOXTEXT THEN
	text$=getobj_text$(object)
	IF getobj_font(object)=5 THEN char_h=6 : char_w=6
ELSE
	EXIT SUB
END IF

junk=objc_offset(tree&,object,x,y)
w=getobj_width(object) : h=getobj_height(object)
text_w=LEN(text$)*char_w
char_pos=INSTR(UCASE$(text$),UCASE$(CHR$(char_ascii)))

IF char_pos THEN
	char_x=(char_pos-1)*char_w
	IF type=G_BUTTON THEN
		x=x+(w-text_w)\2+char_x
	ELSEIF type=G_TEXT OR type=G_BOXTEXT THEN
		just=getobj_just(object)
		SELECT CASE just
			CASE 2 : x=x+(w-text_w)\2+char_x
			CASE 0 : x=x+char_x
			CASE ELSE : x=x+w-text_w+char_x
		END SELECT
	ELSE
		IF type=G_STRING THEN x=x+char_x
	END IF

	y=y+(h-char_h)\2+char_h-1
	IF (getobj_flags(object) AND mask_3d)=fl3dact THEN
		IF aes_version>=&h340 THEN DECR x
	END IF
	draw_underline object,x,y,(x+char_w-1)
END IF
END SUB


SUB draw_underline(BYVAL object,BYVAL x1,BYVAL y1,BYVAL x2)
STATIC drawlines(),x,y,w,h,dummy

DIM drawlines(3)
vsl_color 2
IF enquire_state(object,mask_selected) THEN
	IF (getobj_flags(object) AND mask_3d)=fl3dact THEN
		IF aes_version>=&h340 THEN INCR x1 : INCR x2
	END IF
END IF
drawlines(0)=x1 : drawlines(1)=y1 : drawlines(2)=x2 : drawlines(3)=y1
dummy=getobj_parent(object)
DO
	IF enquire_flags(dummy,mask_hidetree) THEN
		ERASE drawlines : EXIT SUB
	ELSE
		dummy=getobj_parent(dummy)
	END IF
LOOP UNTIL dummy=<0
v_pline 2,drawlines()
ERASE drawlines
END SUB


SUB change_object(BYVAL object,BYVAL x,BYVAL y,BYVAL w,BYVAL h,BYVAL newstate,BYVAL flag)
	junk=objc_change(tree&,object,x,y,w,h,newstate,flag)
	vs_clip 1,x,y,w,h
	IF flag THEN draw_shortcuts object,0
END SUB


SUB draw_object(BYVAL object,BYVAL depth,BYVAL x,BYVAL y,BYVAL w,BYVAL h)
STATIC dummy()

DIM dummy(5)
junk=objc_draw(tree&,object,depth,x,y,w,h)
vql_attributes dummy()
vsl_type 1 : vswr_mode 1 : vsl_ends 0,0 : vsl_width 1

IF x>0 AND y>0 AND w>0 AND h>0 THEN vs_clip 1,x,y,x+w-1,y+h-1
draw_shortcuts object,depth
vsl_type dummy(0) : vsl_color dummy(1) : vswr_mode dummy(2)
vsl_ends dummy(3),dummy(4) : vsl_width dummy(5)
ERASE dummy
END SUB


SUB redraw_object(BYVAL object)
STATIC dummy(),x,y,w,h,depth

DIM dummy(5)
getobj_xywh object,x,y,w,h : depth=10
junk=objc_offset(tree&,object,x,y)

junk=objc_draw(tree&,object,depth,x,y,0,0)
vql_attributes dummy()
vsl_type 1 : vswr_mode 1 : vsl_ends 0,0 : vsl_width 1

IF x>0 AND y>0 AND w>0 AND h>0 THEN vs_clip 1,x,y,x+w-1,y+h-1
draw_shortcuts object,depth
vsl_type dummy(0) : vsl_color dummy(1) : vswr_mode dummy(2)
vsl_ends dummy(3),dummy(4) : vsl_width dummy(5)
ERASE dummy
END SUB


SUB sub_icon (BYVAL treeno,BYVAL object,BYVAL s_treeno,BYVAL s_object)
STATIC oldtree&,s_spec&,s_state,s_flags,s_type

oldtree&=tree&
SelectTree s_treeno
s_spec&=getobj_spec&(s_object)
s_state=getobj_state(s_object)
s_flags=getobj_flags(s_object)
s_type=getobj_type(s_object)
IF aes_version>=&h340 THEN POKEW s_spec&+ib_wtext,0 : POKEW s_spec&+ib_htext,0

SelectTree treeno
setobj_spec object,s_spec&
setobj_state object,s_state
setobj_flags object,s_flags
setobj_type object,s_type
tree&=oldtree&
END SUB


SUB set_grouprbutton (BYVAL treeno,BYVAL parent,BYVAL button)
STATIC dummy,screenh,aes

aes=aes_version : screenh=PEEKW(SYSTAB+46)+1
dummy=getobj_head(parent)
DO
	IF enquire_flags(dummy,mask_rbutton) AND dummy<>button THEN
		IF getobj_shortcut(dummy)=12 THEN
			SELECT CASE aes
			CASE <&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,dummy,ICONS,ICON_RAD_1SM
				CASE >=400 : sub_icon treeno,dummy,ICONS,ICON_RAD_1
				END SELECT
			CASE >=&h340
				SELECT CASE screenh
				CASE <400 : sub_icon treeno,dummy,ICONS,ICON_RAD_4SM
				CASE >=400 : sub_icon treeno,dummy,ICONS,ICON_RAD_4
				END SELECT
			END SELECT
		ELSE
			IF enquire_state(dummy,mask_selected) THEN remove_state dummy,mask_selected
		END IF
		redraw_object dummy
	END IF
	dummy=getobj_next(dummy)
LOOP UNTIL dummy=parent
include_state button,mask_selected
END SUB


SUB init_dialog (BYVAL treeno)
STATIC oldtree&,object,depth,type,flags,extension,screenh,aes
STATIC sysfont_w,sysfont_h

oldtree&=tree& : SelectTree treeno : object=0 : depth=10
junk=graf_handle(sysfont_w,sysfont_h,0,0)
DO
	type=getobj_type(object) : flags=getobj_flags(object)
	IF reset_dialog THEN
		IF enquire_flags (object,mask_editable) THEN
			IF type=G_FTEXT THEN setobj_text object,""
			IF type=G_STRING THEN setobj_spec_str object,""
		END IF
	END IF

	IF type=G_ICON THEN
		IF aes_version>=&h340 THEN
			POKEW getobj_spec&(object)+ib_wtext,0 : POKEW getobj_spec&(object)+ib_htext,0
		END IF
	END IF

	IF type AND &hFF00 THEN
		extension=type\256
		IF (flags AND mask_hidetree)=0 THEN
		IF NOT getobj_depth(0,object,depth) THEN
			screenh=PEEKW(SYSTAB+46)+1 : aes=aes_version
			SELECT CASE extension
			 CASE 10
				setobj_height object,sysfont_h
				SELECT CASE screenh
					CASE <400 : sub_icon treeno,object,ICONS,ICON_PRAD_SM
					CASE >=400 : sub_icon treeno,object,ICONS,ICON_PRADIO
				END SELECT
			 CASE 11
				setobj_height object,sysfont_h
				SELECT CASE aes
				CASE <&h340
					SELECT CASE screenh
					CASE <400 : sub_icon treeno,object,ICONS,ICON_RAD_1SM
					CASE >=400 : sub_icon treeno,object,ICONS,ICON_RAD_1
					END SELECT
				CASE >=&h340
					SELECT CASE screenh
					CASE <400 : sub_icon treeno,object,ICONS,ICON_RAD_4SM
					CASE >=400 : sub_icon treeno,object,ICONS,ICON_RAD_4
					END SELECT
				END SELECT
			 CASE 12
				setobj_height object,sysfont_h
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
			 CASE 13
				setobj_height object,sysfont_h
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
			 CASE 14
				setobj_height object,sysfont_h
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
		END IF
		END IF
	END IF
	INCR object
LOOP UNTIL depth=0 OR (flags AND mask_lastob)
tree&=oldtree&
END SUB


SUB setobj_shortcut(BYVAL object,BYVAL dummy$)
POKEB ObjectAddr&(object)+ob_type,ASC(UCASE$(dummy$))
END SUB


SUB HandleObject (BYVAL treeno,BYVAL object,BYVAL closedialog&,BYVAL mode)
STATIC extension,aes,screenh,cur_obj,old_obj,dummy,type,dummy

commonclose=0
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
	Finished_DFlag=1
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
	Finished_DFlag=1
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
	Finished_DFlag=1
CASE ELSE
	extension=getobj_shortcut(object-1)
	SELECT CASE extension
	CASE 11 TO 14 : HandleObject treeno,object-1,closedialog&,mode
	CASE ELSE
		IF enquire_flags(object,mask_rbutton) THEN
			set_grouprbutton treeno,getobj_parent(object),object
			Finished_DFlag=1
		ELSE
			IF closedialog&<>0 THEN
				Finished_DFlag=1 : CommonObj=object : CALLS closedialog&
				IF Finished_DFlag<>0 THEN
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
				END IF
			END IF
		END IF
	END SELECT
END SELECT
END SUB


FUNCTION dialog_formdo (BYVAL treeno,x,y,w,h,BYVAL object,BYVAL exit_obj,button,BYVAL closedialog&)
STATIC event,x,y,w,h,outx,outy,old_object,cur_edit,index,dummy,flags
STATIC mclicks,mmask,mstate,mx,my,kstate,key_pressed,clicks,dummy_object

Finished_DFlag=1 : old_object=0 : cur_edit=0
IF button=1 THEN
	mclicks=2 : mmask=1 : mstate=1
ELSE
	mclicks=258 : mmask=3 : mstate=0
END IF

WHILE Finished_DFlag
	IF object<>0 AND cur_edit<>object THEN
		IF enquire_flags(object,mask_editable) THEN
			cur_edit=object : object=0
			junk=objc_edit(tree&,cur_edit,0,index,1)
		END IF
	END IF
	event=evnt_multi(MU_KEYBD+MU_BUTTON+MU_TIMER,mclicks,mmask,mstate,0,0,0,0,0,_
			0,0,0,0,0,0,hook_timeout,mx,my,button,kstate,key_pressed,clicks)

	IF event AND MU_KEYBD THEN
		IF kstate=8 OR key_pressed=&h6100 OR key_pressed=&h6200 THEN
			object=formcuts(key_pressed,exit_obj)
			old_object=object
			IF object THEN Finished_DFlag=form_button(tree&,object,clicks,object)
			CALL HandleObject (treeno,object,closedialog&,1)
		ELSE
			Finished_DFlag=HandleKeyboard(cur_edit,kstate,object,key_pressed,index)
			IF object THEN CALL HandleObject (treeno,object,closedialog&,1)
			IF key_pressed THEN junk=objc_edit(tree&,cur_edit,key_pressed,index,2)
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
			save_scrdialog x,y,w,h,0 : x=outx : y=outy : save_scrdialog x,y,w,h,1
			CALL draw_object(object,10,x,y,w,h)
			object=cur_edit : cur_edit=0
			MOUSE 0
		CASE ELSE
			flags=getobj_flags(object)
			IF (flags AND mask_hidetree)=0 THEN
				IF flags AND (mask_selectable OR mask_exit OR mask_touchexit OR mask_editable) THEN
					old_object=object
					IF clicks>=2 THEN clicks=1
					Finished_DFlag=form_button(tree&,object,clicks,object)
					IF object THEN CALL HandleObject (treeno,object,closedialog&,0)
				ELSE
					MOUSE 4
					graf_dragbox w,h,x,y,PEEKW(SYSTAB+40)+1,PEEKW(SYSTAB+42)+19,PEEKW(SYSTAB+44),PEEKW(SYSTAB+46)-19,outx,outy
					setobj_xywh 0,outx+3,outy+3,w-6,h-6
					save_scrdialog x,y,w,h,0 : x=outx : y=outy : save_scrdialog x,y,w,h,1
					CALL draw_object(0,10,x,y,w,h)
					object=cur_edit : cur_edit=0
					MOUSE 0
				END IF
			END IF
		END SELECT
	END IF

	IF (NOT Finished_DFlag AND (object<>0 AND object<>cur_edit)) THEN
		IF enquire_flags(object,mask_editable) THEN junk=objc_edit(tree&,cur_edit,0,index,3)
	END IF

	IF old_object THEN
		IF getobj_type(old_object) AND &hFF00 THEN
			vs_clip 0,junk,junk,junk,junk
			IF enquire_flags(old_object,mask_rbutton) THEN
				old_object=getobj_parent(old_object)
			END IF
			draw_shortcuts getobj_parent(old_object),10
		END IF
	END IF
	IF hook_enabled<>0 THEN CALL HandleUserHook
WEND
dialog_formdo=object
END FUNCTION


FUNCTION xdialog(BYVAL treeno,BYVAL edit_obj,BYVAL exit_obj,button,BYVAL closedialog&)
STATIC x,y,w,h,but,oldtree&

oldtree&=tree& : SelectTree treeno
CALL init_dialog (treeno)
form_center tree&,x,y,w,h
CALL save_scrdialog (x,y,w,h,1)
junk=wind_update(BEG_MCTRL)
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
CALL draw_object(0,10,x,y,w,h)
but=dialog_formdo (treeno,x,y,w,h,edit_obj,exit_obj,button,closedialog&) AND &h7fff
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
junk=wind_update(END_MCTRL)
CALL save_scrdialog (x,y,w,h,0)
IF enquire_state(but,mask_selected) THEN remove_state but,mask_selected
xdialog=but : tree&=oldtree&
END FUNCTION

'[*END OF FILE*]
