
' [MIDIMATE.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

DEFINT a-z
REM $include midimate.bh		' Declare *.BH file created from resource file
REM $include error.bas			' Request the file ERROR.BAS
REM $include toolbx_a.bas		' Request the file TOOLBX_A.BAS (i.e. GEM Toolkit)
REM $include midi.bas			' Request the file MIDI.BAS
REM $include st-guide.bas		' Request the file ST-GUIDE.BAS

CALL StartProgram (CURDIR$+"\MIDIMATE.RSC",FORM_MENU,MENU_QUIT,FORM_ICONIFY)
junk=xdialog (FORM_ABOUT,0,0,1,0)			' Display dialog
CALL initFORM_MAIN
main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,0,VARPTRS(closeFORM_MAIN))
CALL xENCHANTloop							' Call program loop
CALL StopProgram


FUNCTION HandleUserClose(BYVAL WindowHandle)
SHARED main_handle

SELECT CASE WindowHandle
CASE main_handle : Finished_Flag=-1
END SELECT
END FUNCTION

SUB HandleUserMessages
END SUB

SUB HandleUserKeys (ASCII$,key_pressed,kstate)
END SUB

SUB HandleUserClicks (clicks,kstate,mx,my)
END SUB

SUB HandleUserHook
END SUB

SUB TextWindLoop (BYVAL key_pressed)	' These sub-routines are not used, but are required
END SUB									' as they are declared within the GEM Toolkit

SUB TextWindArrowed(BYVAL WindowHandle,BYVAL which)
END SUB


SUB	HandleUserMenu (WindowHandle,item,title)
SHARED MyProgram$,main_handle

SELECT CASE item
CASE MENU_ABOUT : junk=xdialog (FORM_ABOUT,0,0,1,0)
CASE MENU_OPEN
	main_handle=OpenFormWindow(MyProgram$,FORM_MAIN,0,0,VARPTRS(closeFORM_MAIN))
CASE MENU_STG_TITLE : junk=STGuide (CURDIR$+"\MIDIMATE.HYP","Title")
CASE MENU_STG_CONTENT : junk=STGuide (CURDIR$+"\MIDIMATE.HYP","Contents")
CASE MENU_STG_INDEX : junk=STGuide (CURDIR$+"\MIDIMATE.HYP","Index")
END SELECT
END SUB


SUB closeFORM_MAIN
SHARED octave_popup,channel_popup
STATIC channel,octave,velocity,instrument,note,dummy

SelectTree FORM_MAIN
octave=VAL(RIGHT$(getobj_text$(MAIN_OCTAVE),2))		' Extract values from strings
channel=VAL(RIGHT$(getobj_text$(MAIN_CHANNEL),2))
velocity=VAL(getobj_text$(MAIN_VELOCITY))
instrument=VAL(getobj_text$(MAIN_INSTR))

SELECT CASE CommonObj
	CASE MAIN_C : note=0
	CASE MAIN_C_SHARP : note=1
	CASE MAIN_D : note=2
	CASE MAIN_E_FLAT : note=3
	CASE MAIN_E : note=4
	CASE MAIN_F : note=5
	CASE MAIN_F_SHARP : note=6
	CASE MAIN_G : note=7
	CASE MAIN_A_FLAT : note=8
	CASE MAIN_A : note=9
	CASE MAIN_B_FLAT : note=10
	CASE MAIN_B : note=11
	CASE MAIN_OCTAVE
		octave_popup=popup(0,MAIN_OCTAVE,FORM_POPUPS,POP_OCTAVE,octave_popup)
		IF octave_popup THEN
			setobj_poptext MAIN_OCTAVE,"  "+getobj_poptext$(FORM_POPUPS,octave_popup)
			redraw_object MAIN_OCTAVE : octave=VAL(RIGHT$(getobj_text$(MAIN_OCTAVE),2))
		END IF
	CASE MAIN_OCTAVE1
		radio_poptext MAIN_OCTAVE,FORM_POPUPS,POP_OCTAVE,octave_popup
		redraw_object MAIN_OCTAVE : octave=VAL(RIGHT$(getobj_text$(MAIN_OCTAVE),2))
	CASE MAIN_CHANNEL
		channel_popup=popup(0,MAIN_CHANNEL,FORM_POPUPS,POP_CHANNEL,channel_popup)
		IF channel_popup THEN
			setobj_poptext MAIN_CHANNEL,"  "+getobj_poptext$(FORM_POPUPS,channel_popup)
			redraw_object MAIN_CHANNEL : channel=VAL(RIGHT$(getobj_text$(MAIN_CHANNEL),2))
		END IF
	CASE MAIN_CHANNEL1
		radio_poptext MAIN_CHANNEL,FORM_POPUPS,POP_CHANNEL,channel_popup
		redraw_object MAIN_CHANNEL : channel=VAL(RIGHT$(getobj_text$(MAIN_CHANNEL),2))
	CASE MAIN_VUP
		dummy=VAL(getobj_text$(MAIN_VELOCITY))
		INCR dummy : IF dummy>127 THEN dummy=127
		setobj_text MAIN_VELOCITY,LTRIM$(STR$(dummy))
		redraw_object MAIN_VELOCITY
		velocity=VAL(getobj_text$(MAIN_VELOCITY)) : CALL cntrl_volume (channel,velocity)
	CASE MAIN_VDOWN
		dummy=VAL(getobj_text$(MAIN_VELOCITY))
		DECR dummy : IF dummy<0 THEN dummy=0
		setobj_text MAIN_VELOCITY,LTRIM$(STR$(dummy))
		redraw_object MAIN_VELOCITY
		velocity=VAL(getobj_text$(MAIN_VELOCITY)) : CALL cntrl_volume (channel,velocity)
	CASE MAIN_INSTRUP
		dummy=VAL(getobj_text$(MAIN_INSTR))
		INCR dummy : IF dummy>127 THEN dummy=127
		setobj_text MAIN_INSTR,LTRIM$(STR$(dummy))
		redraw_object MAIN_INSTR
		instrument=VAL(getobj_text$(MAIN_INSTR)) : CALL program_change (channel,instrument)
	CASE MAIN_INSTRDOWN
		dummy=VAL(getobj_text$(MAIN_INSTR))
		DECR dummy : IF dummy<0 THEN dummy=0
		setobj_text MAIN_INSTR,LTRIM$(STR$(dummy))
		redraw_object MAIN_INSTR
		instrument=VAL(getobj_text$(MAIN_INSTR)) : CALL program_change (channel,instrument)
	CASE MAIN_ALLNOTESOFF : CALL all_notes_off
END SELECT

SELECT CASE CommonObj
	CASE MAIN_C TO MAIN_B_FLAT
		note_on channel,36+(12*(octave-1))+note,velocity	' Play note
		DO													' Wait for mouse button to be released
		LOOP UNTIL MOUSE(2)=0
		note_off channel,36+(12*(octave-1))+note,0			' Turn note off
END SELECT
END SUB


SUB initFORM_MAIN							' set-up initial values in dialog
SHARED octave_popup,channel_popup
STATIC oldtree&

oldtree&=tree& : SelectTree FORM_POPUPS
octave_popup=POP_O1
channel_popup=POP_C1

include_state octave_popup,mask_checked+mask_selected
include_state channel_popup,mask_checked+mask_selected

SelectTree FORM_MAIN
setobj_poptext MAIN_OCTAVE,"  "+getobj_poptext$(FORM_POPUPS,octave_popup)
setobj_poptext MAIN_CHANNEL,"  "+getobj_poptext$(FORM_POPUPS,channel_popup)

setobj_text MAIN_VELOCITY,"64"
setobj_text MAIN_INSTR,"0"
tree&=oldtree&
END SUB

'[*END OF FILE*]
