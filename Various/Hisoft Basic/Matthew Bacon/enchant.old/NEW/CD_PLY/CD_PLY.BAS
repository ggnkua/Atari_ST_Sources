
' [CD_PLY.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z
LIBRARY "cdlib"

REM $include F:\CADENZA\CD_PLY\CD_PLY.bh
REM $include F:\CADENZA\CD_PLY\toolbx_a.bas
REM $include F:\ENCHANT\NEW\CDLIB.bas
REM $include F:\ENCHANT\MODULES\cursor.bas
REM $include F:\ENCHANT\MODULES\error.bas

MyProgram$="CD-Player"

CALL StartProgram (CURDIR$+"\CD_PLY.RSC",0,0,FORM_ICONIFY)
result=init_CDLIB (drive_letter$,driver$)
IF result THEN 
	main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,MAIN_QUIT,VARPTRS(closeFORM_MAIN))
	CALL xENCHANTloop
ELSE
	junk=form_alert(1,"[1][  "+MyProgram$+": |  No CD drive available! ][ Abort ]")
END IF
CALL StopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION HandleUserClose(BYVAL WindowHandle)
END FUNCTION

SUB HandleUserMessages
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB

SUB	HandleUserMenu (cur_front,item,title)
END SUB

SUB Init_Menu(BYVAL treeno,BYVAL exititem)
END SUB

FUNCTION CreateShortCut(BYVAL Scancode,BYVAL kstate)
END FUNCTION

SUB TextWindLoop (BYVAL key_pressed)
END SUB

SUB TextWindArrowed(BYVAL WindowHandle,BYVAL which)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB closeFORM_MAIN
STATIC result,first_track,last_track,current_track,pause
STATIC x,y,w,h,x1,y1,x2,y2

SelectTree FORM_MAIN
SELECT CASE CommonObj
CASE MAIN_QUIT : Finished_Flag=-1
CASE MAIN_PLAY,MAIN_PLAY2
	include_state MAIN_PLAY,mask_selected
	redraw_object MAIN_PLAY
	DO
	LOOP UNTIL MOUSE(2)=0
	IF pause=-1 THEN
		result=unpause_CDLIB : pause=0
	ELSE
		result=contents_CDLIB (first_track,last_track)
		IF result THEN
			result=playtracks_CDLIB (first_track,last_track)
			current_track=first_track
		END IF
	END IF
	CommonObj=MAIN_PLAY
CASE MAIN_STOP,MAIN_STOP2
	include_state MAIN_STOP,mask_selected
	redraw_object MAIN_STOP
	DO
	LOOP UNTIL MOUSE(2)=0
	result=pause_CDLIB : pause=-2
	CommonObj=MAIN_STOP
CASE MAIN_PAUSE,MAIN_PAUSE2
	include_state MAIN_PAUSE,mask_selected
	redraw_object MAIN_PAUSE
	DO
	LOOP UNTIL MOUSE(2)=0
	IF pause=0 THEN
		result=pause_CDLIB : pause=-1
	ELSE
		result=unpause_CDLIB : pause=0
	END IF
	CommonObj=MAIN_PAUSE
CASE MAIN_BACK,MAIN_BACK2
	include_state MAIN_BACK,mask_selected
	redraw_object MAIN_BACK
	DO
	LOOP UNTIL MOUSE(2)=0
	IF first_track=0 THEN result=contents_CDLIB (first_track,last_track)
	DECR current_track
	IF current_track<first_track THEN current_track=first_track
	result=playtracks_CDLIB (current_track,last_track)
	CommonObj=MAIN_BACK
CASE MAIN_FORWARD,MAIN_FORWARD2
	include_state MAIN_FORWARD,mask_selected
	redraw_object MAIN_FORWARD
	DO
	LOOP UNTIL MOUSE(2)=0
	IF first_track=0 THEN result=contents_CDLIB (first_track,last_track)
	INCR current_track
	IF current_track>last_track THEN current_track=last_track
	result=playtracks_CDLIB (current_track,last_track)
	CommonObj=MAIN_FORWARD
CASE MAIN_INFO,MAIN_INFO2
	include_state MAIN_INFO,mask_selected
	redraw_object MAIN_INFO
	DO
	LOOP UNTIL MOUSE(2)=0
	junk=xdialog (FORM_ABOUT,0,0,1,0)
	remove_state MAIN_INFO,mask_selected
	redraw_object MAIN_INFO
	CommonObj=MAIN_INFO
CASE MAIN_EJECT,MAIN_EJECT2
	include_state MAIN_EJECT,mask_selected
	redraw_object MAIN_EJECT
	DO
	LOOP UNTIL MOUSE(2)=0
	result=eject_CDLIB
	CommonObj=MAIN_EJECT
CASE MAIN_VOLUME2
	include_state MAIN_VOLUME2,mask_selected
	redraw_object MAIN_VOLUME2

	getobj_xywh MAIN_VOLUME,x,y,w,h
	junk=objc_offset(tree&,MAIN_VOLUME,x1,y1)
	junk=objc_offset(tree&,MAIN_VOLUME2,x2,y2)
	CALL graf_dragbox(getobj_width(MAIN_VOLUME2),getobj_height(MAIN_VOLUME),x2,y2,x1,y1,w,h,x,y)
	junk=objc_offset(tree&,CommonObj-1,x2,y2)
	x=x-x2 : setobj_x CommonObj,x
	redraw_object MAIN_VOLUME 
	result=volume_CDLIB (x*(100/72))
	CommonObj=MAIN_VOLUME2
END SELECT
IF enquire_state(CommonObj,mask_selected) THEN
	remove_state CommonObj,mask_selected
	redraw_object CommonObj
END IF
END SUB

'[*END OF FILE*]

'junk=form_alert(1,"[1][  "+STR$()+" ][ Abort ]")
