'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' This is a rather scruffy coded version.  I currently tidying it up!
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' AutoClock v2.61  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' Copyright HiSoft 1991-3
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Include F:\CADENZA\AUTOCLOK\GEMTOOL.T
LIBRARY "falcon","mint","speedo"
'$option q80,y
'$INCLUDE F:\CADENZA\AUTOCLOK\AUTOCLOK.BH
'$INCLUDE F:\ENCHANT\MODULES\DATETIME.BAS
DIM DATA$(45)

CONST wf_iconify=26,wf_uniconify=27,win_icon=&h4000
CONST wm_bottom=33,wm_iconify=34,wm_uniconify=35,wm_alliconify=36
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION get_pop_text$(BYVAL poptree,BYVAL popobj)
STATIC oldtree&
oldtree&=tree&
selecttree poptree
get_pop_text$=RTRIM$(LTRIM$(getob_spec$(popobj)))
tree&=oldtree&
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL(total_items,display_items,top_item,object,background)
STATIC i!,height!,y_position!,x,y,w,h

IF total_items=<display_items THEN
	Setob_y object,0
	Setob_height object,Getob_Height(background)
ELSE
	i!=Getob_Height(background)/total_items
	height!=i!*display_items
	y_position!=i!*top_item
	Setob_y object,y_position!
	Setob_height object,height!
END IF
w=Getob_width(background)
h=Getob_height(background)
junk=objc_offset(tree&,background,x,y)
xobjc_draw background,10,x,y,w,h
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL2(total_items,display_items,top_item,object,background)
STATIC i!,height!,y_position!,x,y,w,h

IF total_items=<display_items THEN
	Setob_y object,0
	Setob_height object,Getob_Height(background)
ELSE
	i!=Getob_Height(background)/total_items
	height!=i!*display_items
	y_position!=i!*top_item
	Setob_y object,y_position!
	Setob_height object,height!
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION verify
SHARED DATA$()
STATIC code1$,code2$,code3$,forename,surname,issue!,code!,code_given$,regname$

SelectTree FORM_REGISTER
regname$=Gette_ptext$(REG_NAME)
code_given$=UCASE$(Gette_ptext$(REG_CODE))
code1$=MID$(code_given$,2,1)+MID$(code_given$,4,1)+MID$(code_given$,6,1)+MID$(code_given$,8,1)+MID$(code_given$,7,1)
code2$=RIGHT$(code_given$,2)
code3$=MID$(code_given$,5,1)+MID$(code_given$,3,1)+MID$(code_given$,1,1)
forename=ASC(LEFT$(code2$,1))
surname=ASC(RIGHT$(code2$,1))
issue!=VAL(code3$)-forename

code!=SQR((((VAL(code1$)-surname)/2)-issue!))
SELECT CASE code!
	CASE=(forename+surname):verify=1
	CASE ELSE:verify=0
END SELECT
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB INITIALISE_CLOCK
STATIC month$,y2k$

y2k$=dateform$ (0,"/")

SelectTree FORM_MAIN
Sette_ptext SET_TIME,LEFT$(TIME$,2)+MID$(TIME$,4,2)
Sette_ptext SET_DAY,MID$(y2k$,4,2)
month$=LEFT$(y2k$,2)
SELECT CASE month$
	CASE=="01":Sette_ptext SET_MONTH,"January"
	CASE=="02":Sette_ptext SET_MONTH,"Febuary"
	CASE=="03":Sette_ptext SET_MONTH,"March"
	CASE=="04":Sette_ptext SET_MONTH,"April"
	CASE=="05":Sette_ptext SET_MONTH,"May"
	CASE=="06":Sette_ptext SET_MONTH,"June"
	CASE=="07":Sette_ptext SET_MONTH,"July"
	CASE=="08":Sette_ptext SET_MONTH,"August"
	CASE=="09":Sette_ptext SET_MONTH,"September"
	CASE=="10":Sette_ptext SET_MONTH,"October"
	CASE=="11":Sette_ptext SET_MONTH,"November"
	CASE=="12":Sette_ptext SET_MONTH,"December"
END SELECT
Sette_ptext SET_YEAR,RIGHT$(y2k$,4)
IF Gette_ptext$(SET_DAY)="00" THEN Sette_ptext SET_DAY,"01"
IF Gette_ptext$(SET_YEAR)="20<8" THEN Sette_ptext SET_YEAR,"1997"
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB INITIALISE
SHARED DATA$(),top_fnt,fnt_high,GDOS_EXIST,total_fnts,dum&,SPEEDO_EXIST
SHARED scrx,scry,scrw,scrh

junk=wind_get(0,wf_workxywh,scrx,scry,scrw,scrh)
CALL initialise_clock
DATA$(2)="12:00":DATA$(3)="01":DATA$(4)="060":DATA$(5)="Welcome to AutoClock v2.61"
DATA$(6)="AutoClock is Freeware!!!!!":DATA$(7)="":DATA$(8)="½ 1996,97 Cadenza Software"
DATA$(9)="Written by Matthew Bacon":DATA$(10)="":DATA$(11)="This release allows AutoClock to":DATA$(12)="only function for 30 mins!"
DATA$(13)="":DATA$(14)="Released 08-06-1997":DATA$(15)="London, GMT":DATA$(16)="0.0"
DATA$(17)="City #2":DATA$(18)="0.0":DATA$(19)="City #3":DATA$(20)="0.0":DATA$(21)="City #4"
DATA$(22)="0.0":DATA$(23)="City #5":DATA$(24)="0.0":DATA$(25)="City #6":DATA$(26)="0.0"
DATA$(27)="City #7":DATA$(28)="0.0":DATA$(29)="City #8":DATA$(30)="0.0":DATA$(31)="1"
DATA$(32)="1":DATA$(33)="24":DATA$(34)="0":DATA$(35)="0":DATA$(36)="1":DATA$(37)="0":DATA$(38)="0"
DATA$(39)="12345678AB":DATA$(40)="Unregistered":DATA$(41)="Unknown Address":DATA$(42)="Unknown Address 2"

GDOS_EXIST=GDOS
IF GDOS_EXIST=0 THEN
	total_fnts=1
ELSE
	total_fnts=vst_load_fonts
	IF GETCOOKIE("FSMC",dum&) THEN SPEEDO_EXIST=1
END IF
SelectTree FORM_FONT
top_fnt=1
FNThigh=FNT1
CALL LOAD_INF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB INITIALISE2
SHARED set_handle,message_handle,font_handle,DATA$(),menutree&,menu_time
SHARED alarm,alarm$,setquit,snooze,FNTid,FNTname$,FNThigh,top_fnt,total_fnts
SHARED verified
STATIC month$,i,chwd,chht,cellwd,cellht

SelectTree FORM_PREF
Sette_ptext SET_ALARM,LEFT$(DATA$(2),2)+RIGHT$(DATA$(2),2)
Sette_ptext SET_SNOOZE,DATA$(3)
Sette_ptext SET_EGG,DATA$(4)

Sette_ptext MES1,DATA$(5)
Sette_ptext MES2,DATA$(6)
Sette_ptext MES3,DATA$(7)
Sette_ptext MES4,DATA$(8)
Sette_ptext MES5,DATA$(9)
Sette_ptext MES6,DATA$(10)
Sette_ptext MES7,DATA$(11)
Sette_ptext MES8,DATA$(12)
Sette_ptext MES9,DATA$(13)
Sette_ptext MES10,DATA$(14)

SelectTree FORM_ALARM
Sette_ptext ALARM_NOW,""
Sette_ptext AMES1,""
Sette_ptext AMES2,""
Sette_ptext AMES3,""
Sette_ptext AMES4,""
Sette_ptext AMES5,""
Sette_ptext AMES6,""
Sette_ptext AMES7,""
Sette_ptext AMES8,""
Sette_ptext AMES9,""
Sette_ptext AMES10,""

FOR i=MENU_CITY1 TO MENU_CITY8
	CALL menu_icheck(menutree&,i,0)
NEXT
CALL menu_text(menutree&,MENU_CITY1,"  "+DATA$(15))
CALL menu_text(menutree&,MENU_CITY2,"  "+DATA$(17))
CALL menu_text(menutree&,MENU_CITY3,"  "+DATA$(19))
CALL menu_text(menutree&,MENU_CITY4,"  "+DATA$(21))
CALL menu_text(menutree&,MENU_CITY5,"  "+DATA$(23))
CALL menu_text(menutree&,MENU_CITY6,"  "+DATA$(25))
CALL menu_text(menutree&,MENU_CITY7,"  "+DATA$(27))
CALL menu_text(menutree&,MENU_CITY8,"  "+DATA$(29))
CALL menu_icheck(menutree&,MENU_CITY1+(VAL(DATA$(31))-1),1)

SelectTree FORM_FONT
IF VAL(DATA$(32))>total_fnts THEN 
	DATA$(32)="1"
	junk=form_alert(1,"[1][  The font selected does not |  exist!  The system font |  will be used instead. ][ OK ]")
END IF

FNTid=vqt_name(VAL(DATA$(32)),FNTname$)
CALL vst_font(FNTid)
junk=vst_arbpt(VAL(DATA$(33)),chwd,chht,cellwd,cellht)
top_fnt=VAL(DATA$(32))
FNThigh=FNT1
IF total_fnts>8 THEN
	IF (top_fnt+7)>total_fnts THEN
		FNThigh=FNT8-(total_fnts-top_fnt)
		top_fnt=(total_fnts-7)
	END IF
END IF

CALL menu_icheck(menutree&,MENU_AMPM,0)
CALL menu_icheck(menutree&,MENU_24HR,0)
CALL menu_icheck(menutree&,MENU_AON,0)
CALL menu_icheck(menutree&,MENU_AOFF,0)
CALL menu_icheck(menutree&,MENU_SNOOZE,0)
IF DATA$(34)="1" THEN CALL menu_icheck(menutree&,MENU_AMPM,1)
IF DATA$(34)="0" THEN CALL menu_icheck(menutree&,MENU_24HR,1)
IF DATA$(35)="1" THEN CALL menu_icheck(menutree&,MENU_AON,1):alarm=-1
IF DATA$(35)="0" THEN CALL menu_icheck(menutree&,MENU_AOFF,1)
IF DATA$(36)="1" THEN CALL menu_icheck(menutree&,MENU_SNOOZE,1):snooze=-1
IF DATA$(36)="0" THEN CALL menu_icheck(menutree&,MENU_SNOOZE,0)
IF DATA$(37)="1" THEN CALL menu_icheck(menutree&,MENU_SETQUIT,1):setquit=-1
IF DATA$(37)="0" THEN CALL menu_icheck(menutree&,MENU_SETQUIT,0)
IF DATA$(38)="1" THEN CALL menu_icheck(menutree&,MENU_DISPLAY,1):menu_time=1
IF DATA$(38)="0" THEN CALL menu_icheck(menutree&,MENU_DISPLAY,0)
alarm$=DATA$(2)

SelectTree FORM_REGISTER
Sette_ptext REG_CODE,DATA$(39)
Sette_ptext REG_NAME,DATA$(40)
Sette_ptext REG_ADDRESS,DATA$(41)
Sette_ptext REG_ADDRESS2,DATA$(42)
verified=verify
IF verified=1 THEN
	SelectTree FORM_ABOUT
	Sette_ptext ABOUT_INFO1,"AutoClock v2.61 (03/06/1997)"
	Sette_ptext ABOUT_INFO2,"Registered by: "+DATA$(40)
	Sette_ptext ABOUT_INFO3,"Do NOT distribute registered copy!!"
END IF

SelectTree FORM_FONT
Sette_ptext FNT1,"__________________________________"
Sette_ptext FNT2,"__________________________________"
Sette_ptext FNT3,"__________________________________"
Sette_ptext FNT4,"__________________________________"
Sette_ptext FNT5,"__________________________________"
Sette_ptext FNT6,"__________________________________"
Sette_ptext FNT7,"__________________________________"
Sette_ptext FNT8,"__________________________________"
Sette_ptext FNT_POINTSIZE,DATA$(33)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LOAD_INF
SHARED DATA$()
STATIC i

MOUSE 2
IF FEXISTS(CURDIR$+"\AUTOCLOK.INF") THEN
	OPEN CURDIR$+"\AUTOCLOK.INF" FOR INPUT AS #1
	i=1
	DO
		INPUT #1,DATA$(i)
		IF i=1 THEN
			IF DATA$(1)<>"AutoClock  ½ 1996,97 Cadenza Software - Written by Matthew Bacon" THEN
				junk=form_alert(1,"[1][  AutoClock: |  Error while loading data |  file into memory. | ][ Abort ]")
				MOUSE 0:EXIT SUB
			END IF
		END IF
		INCR i
	LOOP UNTIL EOF(1)
	CLOSE #1
ELSE
	junk=form_alert(1,"[1][  AutoClock: |  AUTOCLOK.INF does not exist. | ][ OK ]")
END IF
MOUSE 0
CALL INITIALISE2
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SAVE_INF
SHARED DATA$()
STATIC i

MOUSE 2
OPEN CURDIR$+"\AUTOCLOK.INF" FOR OUTPUT AS #1
WRITE #1,"AutoClock  ½ 1996,97 Cadenza Software - Written by Matthew Bacon"
i=2
DO
	WRITE #1,DATA$(i)
	INCR i
LOOP UNTIL i=43
CLOSE #1
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SetClock
SHARED set_handle
STATIC month$

IF NOT Gette_ptext$(set_time)="" THEN
	IF VAL(LEFT$(Gette_ptext$(set_time),2))>23 THEN Sette_ptext set_time,"00"+RIGHT$(Gette_ptext$(set_time),2)
	IF VAL(RIGHT$(Gette_ptext$(set_time),2))>59 THEN Sette_ptext set_time,"0000"
	TIME$=LEFT$(Gette_ptext$(set_time),2)+":"+RIGHT$(Gette_ptext$(set_time),2)+":"+"00"
END IF

month$=LEFT$(Gette_ptext$(set_month),3)
SELECT CASE month$
	CASE=="Jan":MONTH$="01"
	CASE=="Feb":MONTH$="02"
	CASE=="Mar":MONTH$="03"
	CASE=="Apr":MONTH$="04"
	CASE=="May":MONTH$="05"
	CASE=="Jun":MONTH$="06"
	CASE=="Jul":MONTH$="07"
	CASE=="Aug":MONTH$="08"
	CASE=="Sep":MONTH$="09"
	CASE=="Oct":MONTH$="10"
	CASE=="Nov":MONTH$="11"
	CASE=="Dec":MONTH$="12"
END SELECT
IF Gette_ptext$(set_day)="00" THEN junk=form_alert(1,"[1][  Error - Invalid date. | ][ Abort ]"):setob_state ok,0:Object_Redraw set_handle,ok:GOTO retry
IF Gette_ptext$(set_year)="20<8" THEN junk=form_alert(1,"[1][  Error - Invalid date. | ][ Abort ]"):setob_state ok,0:Object_Redraw set_handle,ok:GOTO retry
DATE$=MONTH$+"-"+Gette_ptext$(set_day)+"-"+Gette_ptext$(set_year)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LeapYear
STATIC i,month$,year$

month$=LEFT$(Gette_ptext$(set_month),3)
year$=Gette_ptext$(set_year)

SelectTree Form_Day
FOR i=1 TO 31
	Setob_state i,0
NEXT

SELECT CASE month$
	CASE=="Feb"
		Setob_state 30,8:Setob_state 31,8
		IF NOT VAL(year$) MOD 4=0 THEN Setob_state 29,8
		IF year$="2000" THEN Setob_state 29,8
	CASE=="Apr":Setob_state 31,8
	CASE=="Jun":Setob_state 31,8
	CASE=="Sep":Setob_state 31,8
	CASE=="Nov":Setob_state 31,8
END SELECT
SelectTree Form_Main
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB processusermenus(VAL topwin,VAL item,VAL title)
SHARED commonclose,commonobj,menutree&,DATA$(),alarm,ALARM$,eggtime!
SHARED set_handle,message_handle,font_handle,eggtimer,snooze,setquit
SHARED menu_time,verified
SHARED total_fnts,top_fnt
STATIC oldtree&,i,dum&,wx,wy,ww,wh,button

commonclose=0										
SELECT CASE item
	CASE MENU_ABOUT
		SelectTree FORM_ABOUT
		button=HandleDialog(0)
		IF button=ABOUT_REGISTER THEN
			SelectTree FORM_REGISTER
			junk=HandleDialog(0)
			verified=verify
			IF verified=1 THEN
				junk=form_alert(1,"[1][  Your registration is successful! |  To register permanently, |  Save Preferences!! Thank you. ][ OK ]")
				SelectTree FORM_REGISTER
				DATA$(39)=Gette_ptext$(REG_CODE):DATA$(40)=Gette_ptext$(REG_NAME)
				DATA$(41)=Gette_ptext$(REG_ADDRESS):DATA$(42)=Gette_ptext$(REG_ADDRESS2)
				SelectTree FORM_ABOUT
				Sette_ptext ABOUT_INFO1,"AutoClock v2.61 (03/06/1997)"
				Sette_ptext ABOUT_INFO2,"Registered by: "+data$(40)
				Sette_ptext ABOUT_INFO3,"Do NOT distribute registered copy!!"
			ELSE
				junk=form_alert(1,"[1][  Your registration has been |  unsuccessful! ][ OK ]")
			END IF
		END IF
	CASE MENU_OPENCLOCK:CALL Start_ClockTimer
	CASE MENU_SET
		IF message_handle THEN
			TopAWindow message_handle
		ELSE
			message_handle=openformwindow(" AutoClock : Set Preferences... ",&h0B+win_icon,FORM_PREF,SET_ALARM,SET_CANCEL,VARPTRS(close_messagedialog))
		END IF
	CASE MENU_CLOCK
		IF set_handle THEN
			TopAWindow set_handle
		ELSE
			CALL initialise_clock
			set_handle=openformwindow(" AutoClock : Set Clock... ",&h0B+win_icon,FORM_MAIN,SET_TIME,CANCEL,VARPTRS(close_setdialog))
		END IF
	CASE MENU_SAVE:CALL SAVE_INF
	CASE MENU_QUIT:CALL QUIT_ME
	CASE MENU_CITY1 TO MENU_CITY8:CALL CITY(item)
	CASE MENU_FONT
		IF NOT GETCOOKIE("MINT",dum&) THEN 
			IF NOT GETCOOKIE("MagX",dum&) THEN
			IF NOT GETCOOKIE("Gnva",dum&) THEN
				EXIT SELECT
			END IF
			END IF
		END IF
		SelectTree FORM_FONT
		CALL UPDATE_SCROLL
		CALL SCROLL2(total_fnts,8,top_fnt,FNT_SLIDER,FNT_BACK)
		IF font_handle THEN
			TopAWindow font_handle
		ELSE
			FOR i=FNT1 TO FNT8:Exclob_state i,mask_selected:NEXT
			i=FNThigh
			SELECT CASE i
				CASE FNT1 TO FNT8:Inclob_state FNThigh,mask_selected
			END SELECT
			font_handle=openformwindow(" AutoClock : Set Font... ",&h0B+win_icon,FORM_FONT,FNT_POINTSIZE,FNT_OK,VARPTRS(close_fontdialog))
		END IF
	CASE MENU_AMPM
		CALL menu_icheck(menutree&,MENU_AMPM,1)
		CALL menu_icheck(menutree&,MENU_24HR,0)
		DATA$(34)="1"
	CASE MENU_24HR
		CALL menu_icheck(menutree&,MENU_AMPM,0)
		CALL menu_icheck(menutree&,MENU_24HR,1)
		DATA$(34)="0"
	CASE MENU_DISPLAY
		IF menu_time=1 THEN
			CALL menu_icheck(menutree&,MENU_DISPLAY,0)
			menu_time=0
			CALL vst_font(1)
			CALL vst_point(8)
			junk=wind_get(junk,wf_fullxywh,wx,wy,ww,wh)
			CALL vs_clip(0,0,0,0,0)
			v_gtext ww-12,7, "           "
			v_gtext ww-12,15,"           "
			DATA$(38)="0"
		ELSE
			CALL menu_icheck(menutree&,MENU_DISPLAY,1)
			menu_time=1
			DATA$(38)="1"
		END IF
	CASE MENU_AON
		CALL menu_icheck(menutree&,MENU_AON,1)
		CALL menu_icheck(menutree&,MENU_AOFF,0)
		DATA$(35)="1"
		alarm=-1
		alarm$=DATA$(2)
	CASE MENU_AOFF
		CALL menu_icheck(menutree&,MENU_AON,0)
		CALL menu_icheck(menutree&,MENU_AOFF,1)
		DATA$(35)="0"
		alarm=0
		alarm$=DATA$(2)
	CASE MENU_SNOOZE
		IF snooze<>0 THEN
			CALL menu_icheck(menutree&,MENU_SNOOZE,0)
			snooze=0
			DATA$(36)="0"
		ELSE
			CALL menu_icheck(menutree&,MENU_SNOOZE,1)
			snooze=-1
			DATA$(36)="1"
		END IF
	CASE MENU_EGGTIMER
		IF eggtimer=0 THEN
			CALL menu_icheck(menutree&,MENU_EGGTIMER,1)
			CALL menu_text(menutree&,MENU_EGGTIMER,"  EggTimer"+CHR$(191)+" Running...")
			CALL Start_EggTimer
			eggtimer=-1
			eggtime!=TIMER
		ELSE
			IF eggtimer=-1 THEN
				eggtimer=0
				CALL CloseEgg
			END IF
		END IF
	CASE MENU_SETQUIT
		IF setquit<>0 THEN
			CALL menu_icheck(menutree&,MENU_SETQUIT,0)
			DATA$(37)="0"
			setquit=0
		ELSE
			CALL menu_icheck(menutree&,MENU_SETQUIT,1)
			DATA$(37)="1"
			setquit=-1
		END IF
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_setdialog
SHARED commonclose,commonobj,set_handle,DATA$(),message_handle,setquit
SHARED finished_flag
STATIC x,y,res,res$

SelectTree FORM_MAIN
commonclose=0										
SELECT CASE commonobj
	CASE OK
		CALL setclock
		set_handle=0
		commonclose=-1
		IF setquit=-1 THEN finished_flag=-1:EXIT SELECT
		CALL START_CLOCKTIMER
	CASE CANCEL
		set_handle=0
		commonclose=-1
		IF setquit=-1 THEN finished_flag=-1:EXIT SELECT
		CALL START_CLOCKTIMER
	CASE OPTIONS
		IF message_handle THEN
			TopAWindow message_handle
		ELSE
			message_handle=openformwindow(" AutoClock : Set Preferences... ",&h0B+win_icon,FORM_PREF,SET_ALARM,SET_CANCEL,VARPTRS(close_messagedialog))
		END IF
	CASE SET_DAY
		res=0
		junk=objc_offset(tree&,SET_DAY,x,y)
		res=popup(0,FORM_DAY,res,x,y)
		IF res THEN
			res$=get_pop_text$(FORM_DAY,res)
			Sette_ptext SET_DAY,res$
		END IF
	CASE SET_MONTH
		res=0
		junk=objc_offset(tree&,commonobj,x,y)
		res=popup(0,FORM_MONTH,res,x,y)
		IF res THEN
			res$=get_pop_text$(FORM_MONTH,res)
			Sette_ptext commonobj,res$
			CALL LeapYear
		END IF
	CASE SET_YEAR
		res=0
		junk=objc_offset(tree&,commonobj,x,y)
		res=popup(0,FORM_YEAR,res,x,y)
		IF res THEN
			res$=get_pop_text$(FORM_YEAR,res)
			Sette_ptext commonobj,res$
			CALL LeapYear
		END IF
END SELECT
Object_Redraw set_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_messagedialog
SHARED commonclose,commonobj,message_handle,DATA$(),alarm$
STATIC i

commonclose=0										
SELECT CASE commonobj
	CASE SET_OK
		SelectTree FORM_PREF
		FOR i=mes1 TO mes10
			DATA$(i+3)=Gette_ptext$(i)
		NEXT
		DATA$(2)=LEFT$(Gette_ptext$(SET_ALARM),2)+":"+RIGHT$(Gette_ptext$(SET_ALARM),2)
		DATA$(3)=Gette_ptext$(SET_SNOOZE)
		DATA$(4)=Gette_ptext$(SET_EGG)
		alarm$=DATA$(2)
		message_handle=0
		commonclose=-1
	CASE SET_CANCEL
		message_handle=0
		commonclose=-1
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB CITY(city)
SHARED menutree&,DATA$()
STATIC i

FOR i=MENU_CITY1 TO MENU_CITY8
	CALL menu_icheck(menutree&,i,0)
NEXT
CALL menu_icheck(menutree&,city,1)
DATA$(31)=STR$(city-MENU_CITY1+1)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB win_update
SHARED clock_handle
STATIC x,y,w,h

MOUSE -1
junk=wind_get(clock_handle,WF_WORKXYWH,x,y,w,h)
CALL vswr_mode(0)
CALL vs_clip(1,x,y,w,(h+y)-1)
CALL v_bar(x,y,w,(h+y)-1)
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB win_close
SHARED clock_handle

clock_handle=0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ARROWUP
SHARED total_fnts,top_fnt,FNThigh
STATIC i,k

SelectTree FORM_FONT
IF top_fnt<>1 THEN
IF (top_fnt-8)<1 THEN
	k=top_fnt-1
	top_fnt=1
	FNThigh=FNThigh+k
ELSE
	Exclob_state FNThigh,mask_selected
	top_fnt=top_fnt-8:FNThigh=FNThigh+8
END IF

i=FNThigh
SELECT CASE i
	CASE FNT1 TO FNT8:Inclob_state i,mask_selected
END SELECT
CALL UPDATE_SCROLL:CALL UPDATE_FNTBOX
ELSE
	DO
	LOOP UNTIL MOUSE(2)=0
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ARROWDOWN
SHARED total_fnts,top_fnt,FNThigh
STATIC i,k

SelectTree FORM_FONT
IF top_fnt<>(total_fnts-7) THEN
IF ((top_fnt+8)+8)>total_fnts THEN
	k=(total_fnts-7)-top_fnt
	top_fnt=(total_fnts-7)
	FNThigh=FNThigh-k
ELSE
	Exclob_state FNThigh,mask_selected
	top_fnt=top_fnt+8:FNThigh=FNThigh-8
END IF

i=FNThigh
SELECT CASE i
	CASE FNT1 TO FNT8:Inclob_state i,mask_selected
END SELECT
CALL UPDATE_SCROLL:CALL UPDATE_FNTBOX
ELSE
	DO
	LOOP UNTIL MOUSE(2)=0
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_SCROLL
SHARED total_fnts,top_fnt
STATIC i,Font,name$

SelectTree FORM_FONT
Font=top_fnt
FOR i=FNT1 TO FNT8
	junk=vqt_name(Font,name$)
	Sette_ptext i,name$+"________________________"
	IF Font=total_fnts THEN
		IF Font<8 THEN
			FOR i=i+1 TO FNT8
				Sette_ptext i,"____________________________"
			NEXT
		END IF
		EXIT FOR
	END IF
	INCR Font
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_FNTBOX
SHARED total_fnts,top_fnt
STATIC x1,y1,w1,h1

SelectTree FORM_FONT
junk=objc_offset(tree&,BOX_FNTNAMES,x1,y1)
w1=Getob_width(BOX_FNTNAMES)
h1=Getob_height(BOX_FNTNAMES)
xobjc_draw BOX_FNTNAMES,10,x1,y1,w1,h1
CALL SCROLL(total_fnts,8,top_fnt,FNT_SLIDER,FNT_BACK)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_FNTDISPLAY(handle)
SHARED font_handle,total_fnts,top_fnt,FNTid,FNTpointsize,FNTname$,DATA$()
STATIC x,y,w,h,wx,wy,ww,wh,x1,y1,w1,h1,a,b,c,d,info(),diff

junk=wind_get(font_handle,wf_workxywh,wx,wy,ww,wh)
junk=wind_get(handle,wf_firstxywh,x,y,w,h)
CALL vsf_color(0)
CALL vst_color(1)
REDIM PRESERVE info(9)
FNTid=vqt_name((FNThigh-FNT1)+top_fnt,FNTname$)
CALL vst_font(FNTid)
SelectTree FORM_FONT
junk=vst_arbpt(VAL(Gette_ptext$(FNT_POINTSIZE)),junk,junk,junk,junk)
junk=objc_offset(tree&,FNT_DISPLAY,x1,y1)
w1=x1+Getob_width(FNT_DISPLAY)-2:h1=y1+Getob_height(FNT_DISPLAY)-2
x1=x1+1:y1=y1+1
CALL vqt_attributes(info())
diff=(Getob_height(FNT_DISPLAY)-(info(7)))/2
CALL vswr_mode(0):vst_effects 0:CALL vst_rotation(0)
CALL vst_alignment(0,0)
MOUSE -1
junk=wind_update(beg_update)
WHILE w>0 AND h>0
	a=x:b=y:c=x+w:d=y+h
	IF a<x1 THEN a=x1 	
	IF b<y1 THEN b=y1 	
	IF c>w1 THEN c=w1 	
	IF d>h1 THEN d=h1 	
	IF NOT b>h1 THEN 
	CALL vs_clip(1,a,b,c,d)
	CALL vswr_mode(1)
	CALL v_bar(x,y+1,x+w-1,y+h-2)
	CALL vswr_mode(2)
	CALL v_ftext(x1,h1-diff,FNTname$)
	CALL vs_clip(0,0,0,0,0)
	END IF
	junk=wind_get(handle,wf_nextxywh,x,y,w,h)
WEND
CALL vst_alignment(info(4),0)
junk=wind_update(end_update)
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_fontdialog
SHARED commonclose,commonobj,font_handle,FNThigh,DATA$(),top_fnt
STATIC i

commonclose=0										
SELECT CASE commonobj
	CASE FNT_OK
		DATA$(32)=STR$(top_fnt+(FNThigh-FNT1))
		DATA$(33)=Gette_ptext$(FNT_POINTSIZE)
		font_handle=0
		commonclose=-1
	CASE FNT_AUP:CALL ARROWUP
	CASE FNT_ADOWN:CALL ARROWDOWN
	CASE FNT_REDRAW:CALL UPDATE_FNTDISPLAY(font_handle)
	CASE FNT1 TO FNT8
		IF LEFT$(Gette_ptext$(commonobj),1)<>"_" THEN 
			SelectTree FORM_FONT
			i=FNThigh
			FOR i=FNT1 TO FNT8:Exclob_state i,mask_selected:NEXT
			FNThigh=commonobj:Inclob_state commonobj,mask_selected
			CALL UPDATE_FNTBOX
			CALL UPDATE_FNTDISPLAY(font_handle)
		END IF
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB redrawegg(BYVAL handle,EggTimer$)
SHARED FNTid,DATA$(),eggtime!,eggFNT,eggSIZE
STATIC x,y,w,h,i,wx,wy,ww,wh,info2(),info3()

REDIM PRESERVE info2(10)
REDIM PRESERVE info3(10)
junk=wind_get(handle,wf_workxywh,wx,wy,ww,wh)
junk=wind_get(handle,wf_firstxywh,x,y,w,h)
CALL vsf_color(0)
CALL vst_color(1)
CALL vst_font(eggFNT)
junk=vst_arbpt(eggSIZE,junk,junk,junk,junk)
CALL vst_alignment(0,0)
junk=wind_update(beg_update)
WHILE w>0 AND h>0
	CALL vs_clip(1,x,y,x+w-1,y+h-1)
	CALL vswr_mode(1)
	CALL vqt_fontinfo(junk,junk,info2(),junk,info3())
	v_bar x,y-1,x+w-1,(y+h)-info2(3)
	CALL v_ftext(wx+1,wy+wh-1,MID$(EggTimer$,2,6)+"          ")
	CALL vs_clip(0,0,0,0,0)
	junk=wind_get(handle,wf_nextxywh,x,y,w,h)
WEND
junk=wind_update(end_update)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SliderEgg

END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB CloseEgg
SHARED egg_handle,eggtimer,eggtime!,menutree&

CALL menu_icheck(menutree&,MENU_EGGTIMER,0)
CALL menu_text(menutree&,MENU_EGGTIMER,"  Start EggTimer"+CHR$(191))
eggtimer=0
eggtime!=0
egg_handle=0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Start_EggTimer
SHARED egg_handle,WindW,WindH,eggtime!,data$(),eggFNT,eggSIZE,eggsecs
SHARED scrx,scry,scrw,scrh,WindX,WindY
STATIC info(),info2(),info3()

IF egg_handle THEN
	TopAWindow egg_handle
ELSE
	CALL vst_font(FNTid)
	REDIM PRESERVE info(10)
	REDIM PRESERVE info2(10)
	REDIM PRESERVE info3(10)
	junk=vst_arbpt(VAL(DATA$(33)),junk,junk,junk,junk)
	eggsecs=VAL(DATA$(4))
	CALL vqt_f_extent(MID$(STR$(eggsecs-(TIMER-eggtime!)),2,6),info())
	WindW=info(2)
	CALL vqt_fontinfo(junk,junk,info2(),junk,info3())
	WindH=info2(3)+4
	IF WindW<60 THEN WindW=60
	IF WindH<48 THEN WindH=48
	WindX=(scrw-WindW)/2
	WindY=(scrh-Windh)/2

	eggFNT=FNTid:eggSIZE=VAL(DATA$(33))
	egg_handle=OpenAWindow(" EggTimer"+CHR$(191)+" ",&h0B+win_icon,VARPTRS(RedrawEgg),VARPTRS(SliderEgg),VARPTRS(CloseEgg))
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB redrawclock(BYVAL handle)
SHARED FNTid,DATA$(),clockFNT,clockSIZE
STATIC x,y,w,h,i,wx,wy,ww,wh,info2(),info3()
STATIC newTIME$,timeDIFF,newDATE$,city$,time_of_day$

REDIM PRESERVE info2(10)
REDIM PRESERVE info3(10)
junk=wind_get(handle,wf_workxywh,wx,wy,ww,wh)
junk=wind_get(handle,wf_firstxywh,x,y,w,h)
CALL vsf_color(0)
CALL vst_color(1)
CALL vst_font(clockFNT)
junk=vst_arbpt(clockSIZE,junk,junk,junk,junk)
CALL vst_alignment(0,0)
junk=wind_update(beg_update)
WHILE w>0 AND h>0
	CALL vs_clip(1,x,y,x+w-1,y+h-1)
	CALL vswr_mode(1)
	CALL vqt_fontinfo(junk,junk,info2(),junk,info3())
	v_bar x,y-1,x+w-1,(y+h)-info2(3)
	timeDIFF=VAL(DATA$(31))
	SELECT CASE timeDIFF
		CASE 1:CALL changeTIME(DATA$(16),newTIME$,newDATE$):city$=DATA$(15)
		CASE 2:CALL changeTIME(DATA$(18),newTIME$,newDATE$):city$=DATA$(17)
		CASE 3:CALL changeTIME(DATA$(20),newTIME$,newDATE$):city$=DATA$(19)
		CASE 4:CALL changeTIME(DATA$(22),newTIME$,newDATE$):city$=DATA$(21)
		CASE 5:CALL changeTIME(DATA$(24),newTIME$,newDATE$):city$=DATA$(23)
		CASE 6:CALL changeTIME(DATA$(26),newTIME$,newDATE$):city$=DATA$(25)
		CASE 7:CALL changeTIME(DATA$(28),newTIME$,newDATE$):city$=DATA$(27)
		CASE 8:CALL changeTIME(DATA$(30),newTIME$,newDATE$):city$=DATA$(29)
	END SELECT

	IF DATA$(34)="0" THEN
		IF VAL(LEFT$(newTIME$,2))=24 THEN
			CALL v_ftext(wx,wy+wh-1,"00"+RIGHT$(newTIME$,6)+"     ")
			time_of_day$=""
		ELSE
			time_of_day$=""
			CALL v_ftext(wx,wy+wh-1,newTIME$+"     ")
		END IF
	ELSE
		IF VAL(LEFT$(newTIME$,2))>=22 THEN
			CALL v_ftext(wx,wy+wh-1,RIGHT$(STR$(VAL(LEFT$(newTIME$,2))-12),2)+RIGHT$(newTIME$,6)+"     ")
			time_of_day$=" (PM)"
		ELSE
			IF VAL(LEFT$(newTIME$,2))>=13 THEN
				CALL v_ftext(wx,wy+wh-1,"0"+RIGHT$(STR$(VAL(LEFT$(newTIME$,2))-12),1)+RIGHT$(newTIME$,6)+"     ")
				time_of_day$=" (PM)"
			ELSE
				IF VAL(LEFT$(newTIME$,2))=12 THEN
					time_of_day$=" (PM)"
					CALL v_ftext(wx,wy+wh-1,newTIME$+"     ")
				ELSE
					time_of_day$=" (AM)"
					IF VAL(LEFT$(newTIME$,2))=00 THEN
						CALL v_ftext(wx,wy+wh-1,"12"+RIGHT$(newTIME$,6)+"     ")
					ELSE
						CALL v_ftext(wx,wy+wh-1,newTIME$+"     ")
					END IF
				END IF
			END IF
		END IF
	END IF
	CALL RenameWindow(handle,MID$(newDATE$,4,2)+"-"+LEFT$(newDATE$,2)+"-"+RIGHT$(newDATE$,4)+time_of_day$+" - "+city$)
	CALL vs_clip(0,0,0,0,0)
	junk=wind_get(handle,wf_nextxywh,x,y,w,h)
WEND
junk=wind_update(end_update)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB redrawclock2
SHARED DATA$()
STATIC wx,wy,ww,wh,dum&,y2k$

y2k$=dateform$ (0,"/")

IF NOT GETCOOKIE("Gnva",dum&) THEN
IF NOT GETCOOKIE("MagX",dum&) THEN
	IF NOT GETCOOKIE("MINT",dum&) THEN EXIT SUB
END IF
END IF

CALL vst_font(1)
CALL vst_point(8)
junk=wind_get(junk,wf_fullxywh,wx,wy,ww,wh)
CALL vs_clip(0,0,0,0,0)
IF DATA$(34)="0" THEN
	IF VAL(LEFT$(TIME$,2))=24 THEN
		v_gtext ww-12,7,"   "+CHR$(9)+"00"+MID$(TIME$,3,3)+"am"
	ELSE
		IF VAL(LEFT$(TIME$,2))>=12 THEN
			v_gtext ww-12,7,"   "+CHR$(9)+LEFT$(TIME$,5)+"pm"
		ELSE
			v_gtext ww-12,7,"   "+CHR$(9)+LEFT$(TIME$,5)+"am"
		END IF
	END IF
ELSE
	IF VAL(LEFT$(TIME$,2))>=22 THEN
		v_gtext ww-12,7,"   "+CHR$(9)+RIGHT$(STR$(VAL(LEFT$(TIME$,2))-12),2)+MID$(TIME$,3,3)+"am"
	ELSE
		IF VAL(LEFT$(TIME$,2))>=13 THEN
			v_gtext ww-12,7,"   "+CHR$(9)+"0"+RIGHT$(STR$(VAL(LEFT$(TIME$,2))-12),1)+MID$(TIME$,3,3)+"pm"
		ELSE
			IF VAL(LEFT$(TIME$,2))=12 THEN
				v_gtext ww-12,7,"   "+CHR$(9)+LEFT$(TIME$,5)+"pm"
			ELSE
				v_gtext ww-12,7,"   "+CHR$(9)+LEFT$(TIME$,5)+"am"
			END IF
		END IF
	END IF
END IF
y2k$=dateform$ (0,"/")
v_gtext ww-12,15,"   "+MID$(y2k$,4,2)+"-"+LEFT$(y2k$,2)+"-"+RIGHT$(y2k$,2)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB changeTIME(timeDIFF$,newTIME$,newDATE$)
STATIC hour,minute,day,month,hour$,minute$,y2k$

y2k$=dateform$ (0,"/")

IF VAL(timeDIFF$)<0 THEN
SELECT CASE timeDIFF$
	CASE="-0.5":hour=VAL(LEFT$(TIME$,2)):minute=VAL(MID$(TIME$,4,2))-30
	CASE="-1.0":hour=VAL(LEFT$(TIME$,2))-1:minute=VAL(MID$(TIME$,4,2))
	CASE="-1.5":hour=VAL(LEFT$(TIME$,2))-1:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-2.0":hour=VAL(LEFT$(TIME$,2))-2:minute=VAL(MID$(TIME$,4,2))
	CASE="-2.5":hour=VAL(LEFT$(TIME$,2))-2:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-3.0":hour=VAL(LEFT$(TIME$,2))-3:minute=VAL(MID$(TIME$,4,2))
	CASE="-3.5":hour=VAL(LEFT$(TIME$,2))-3:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-4.0":hour=VAL(LEFT$(TIME$,2))-4:minute=VAL(MID$(TIME$,4,2))
	CASE="-4.5":hour=VAL(LEFT$(TIME$,2))-4:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-5.0":hour=VAL(LEFT$(TIME$,2))-5:minute=VAL(MID$(TIME$,4,2))
	CASE="-5.5":hour=VAL(LEFT$(TIME$,2))-5:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-6.0":hour=VAL(LEFT$(TIME$,2))-6:minute=VAL(MID$(TIME$,4,2))
	CASE="-6.5":hour=VAL(LEFT$(TIME$,2))-6:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-7.0":hour=VAL(LEFT$(TIME$,2))-7:minute=VAL(MID$(TIME$,4,2))
	CASE="-7.5":hour=VAL(LEFT$(TIME$,2))-7:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-8.0":hour=VAL(LEFT$(TIME$,2))-8:minute=VAL(MID$(TIME$,4,2))
	CASE="-8.5":hour=VAL(LEFT$(TIME$,2))-8:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-9.0":hour=VAL(LEFT$(TIME$,2))-9:minute=VAL(MID$(TIME$,4,2))
	CASE="-9.5":hour=VAL(LEFT$(TIME$,2))-9:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-10.0":hour=VAL(LEFT$(TIME$,2))-10:minute=VAL(MID$(TIME$,4,2))
	CASE="-10.5":hour=VAL(LEFT$(TIME$,2))-10:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-11.0":hour=VAL(LEFT$(TIME$,2))-11:minute=VAL(MID$(TIME$,4,2))
	CASE="-11.5":hour=VAL(LEFT$(TIME$,2))-11:minute=VAL(MID$(TIME$,4,2))-30
	CASE="-12.0":hour=VAL(LEFT$(TIME$,2))-12:minute=VAL(MID$(TIME$,4,2))
END SELECT
day=VAL(MID$(y2k$,4,2))
IF minute<0 THEN DECR hour:minute=minute+60
IF hour<0 THEN hour=hour+24:DECR day
IF hour<10 THEN
	hour$="0"+RIGHT$(STR$(hour),1)
ELSE
	hour$=RIGHT$(STR$(hour),LEN(STR$(hour))-1)
END IF
IF minute<10 THEN
	minute$="0"+RIGHT$(STR$(minute),LEN(STR$(minute))-1)
ELSE
	minute$=RIGHT$(STR$(minute),LEN(STR$(minute))-1)
END IF
newTIME$=hour$+":"+minute$+":"+RIGHT$(TIME$,2)
IF day<10 THEN
	newDATE$=LEFT$(y2k$,2)+"-0"+RIGHT$(STR$(day),1)+"-"+RIGHT$(y2k$,4)
ELSE
	newDATE$=LEFT$(y2k$,2)+"-"+RIGHT$(STR$(day),LEN(STR$(day))-1)+"-"+RIGHT$(y2k$,4)
END IF

month=VAL(LEFT$(y2k$,2))
SELECT CASE month
CASE 1:IF day<1 THEN newDATE$="12-31-"+RIGHT$(STR$(VAL(RIGHT$(y2k$,4))-1),LEN(STR$(VAL(RIGHT$(y2k$,4))-1))-1)
CASE 2:IF day<1 THEN newDATE$="01-31-"+RIGHT$(y2k$,4)
CASE 3
	IF day<1 THEN
		IF NOT VAL(RIGHT$(y2k$,4)) MOD 4=0 THEN
			newDATE$="02-29-"+RIGHT$(y2k$,4)
		ELSE
			newDATE$="02-28-"+RIGHT$(y2k$,4)
		END IF
	END IF
CASE 4:IF day<1 THEN newDATE$="03-31-"+RIGHT$(y2k$,4)
CASE 5:IF day<1 THEN newDATE$="04-30-"+RIGHT$(y2k$,4)
CASE 6:IF day<1 THEN newDATE$="05-31-"+RIGHT$(y2k$,4)
CASE 7:IF day<1 THEN newDATE$="06-30-"+RIGHT$(y2k$,4)
CASE 8:IF day<1 THEN newDATE$="07-31-"+RIGHT$(y2k$,4)
CASE 9:IF day<1 THEN newDATE$="08-31-"+RIGHT$(y2k$,4)
CASE 10:IF day<1 THEN newDATE$="09-30-"+RIGHT$(y2k$,4)
CASE 11:IF day<1 THEN newDATE$="10-31-"+RIGHT$(y2k$,4)
CASE 12:IF day<1 THEN newDATE$="11-30-"+RIGHT$(y2k$,4)
END SELECT
EXIT SUB

ELSE
SELECT CASE timeDIFF$
	CASE="0.0":newTIME$=TIME$:newDATE$=y2k$:EXIT SUB
	CASE="0.5":hour=VAL(LEFT$(TIME$,2)):minute=VAL(MID$(TIME$,4,2))+30
	CASE="1.0":hour=VAL(LEFT$(TIME$,2))+1:minute=VAL(MID$(TIME$,4,2))
	CASE="1.5":hour=VAL(LEFT$(TIME$,2))+1:minute=VAL(MID$(TIME$,4,2))+30
	CASE="2.0":hour=VAL(LEFT$(TIME$,2))+2:minute=VAL(MID$(TIME$,4,2))
	CASE="2.5":hour=VAL(LEFT$(TIME$,2))+2:minute=VAL(MID$(TIME$,4,2))+30
	CASE="3.0":hour=VAL(LEFT$(TIME$,2))+3:minute=VAL(MID$(TIME$,4,2))
	CASE="3.5":hour=VAL(LEFT$(TIME$,2))+3:minute=VAL(MID$(TIME$,4,2))+30
	CASE="4.0":hour=VAL(LEFT$(TIME$,2))+4:minute=VAL(MID$(TIME$,4,2))
	CASE="4.5":hour=VAL(LEFT$(TIME$,2))+4:minute=VAL(MID$(TIME$,4,2))+30
	CASE="5.0":hour=VAL(LEFT$(TIME$,2))+5:minute=VAL(MID$(TIME$,4,2))
	CASE="5.5":hour=VAL(LEFT$(TIME$,2))+5:minute=VAL(MID$(TIME$,4,2))+30
	CASE="6.0":hour=VAL(LEFT$(TIME$,2))+6:minute=VAL(MID$(TIME$,4,2))
	CASE="6.5":hour=VAL(LEFT$(TIME$,2))+6:minute=VAL(MID$(TIME$,4,2))+30
	CASE="7.0":hour=VAL(LEFT$(TIME$,2))+7:minute=VAL(MID$(TIME$,4,2))
	CASE="7.5":hour=VAL(LEFT$(TIME$,2))+7:minute=VAL(MID$(TIME$,4,2))+30
	CASE="8.0":hour=VAL(LEFT$(TIME$,2))+8:minute=VAL(MID$(TIME$,4,2))
	CASE="8.5":hour=VAL(LEFT$(TIME$,2))+8:minute=VAL(MID$(TIME$,4,2))+30
	CASE="9.0":hour=VAL(LEFT$(TIME$,2))+9:minute=VAL(MID$(TIME$,4,2))
	CASE="9.5":hour=VAL(LEFT$(TIME$,2))+9:minute=VAL(MID$(TIME$,4,2))+30
	CASE="10.0":hour=VAL(LEFT$(TIME$,2))+10:minute=VAL(MID$(TIME$,4,2))
	CASE="10.5":hour=VAL(LEFT$(TIME$,2))+10:minute=VAL(MID$(TIME$,4,2))+30
	CASE="11.0":hour=VAL(LEFT$(TIME$,2))+11:minute=VAL(MID$(TIME$,4,2))
	CASE="11.5":hour=VAL(LEFT$(TIME$,2))+11:minute=VAL(MID$(TIME$,4,2))+30
	CASE="12.0":hour=VAL(LEFT$(TIME$,2))+12:minute=VAL(MID$(TIME$,4,2))
END SELECT
day=VAL(MID$(y2k$,4,2))
IF minute>60 THEN INCR hour:minute=minute-60
IF hour>=24 THEN INCR day
IF hour>24 THEN hour=hour-24
IF hour<10 THEN
	hour$="0"+RIGHT$(STR$(hour),LEN(STR$(hour))-1)
ELSE
	hour$=RIGHT$(STR$(hour),LEN(STR$(hour))-1)
END IF
IF minute<10 THEN
	minute$="0"+RIGHT$(STR$(minute),LEN(STR$(minute))-1)
ELSE
	minute$=RIGHT$(STR$(minute),LEN(STR$(minute))-1)
END IF
newTIME$=hour$+":"+minute$+":"+RIGHT$(TIME$,2)
IF day<10 THEN
	newDATE$=LEFT$(y2k$,2)+"-0"+RIGHT$(STR$(day),1)+"-"+RIGHT$(y2k$,4)
ELSE
	newDATE$=LEFT$(y2k$,2)+"-"+RIGHT$(STR$(day),LEN(STR$(day))-1)+"-"+RIGHT$(y2k$,4)
END IF

month=VAL(LEFT$(y2k$,2))
SELECT CASE month
CASE 1:IF day>31 THEN newDATE$="02-01-"+RIGHT$(y2k$,4)
CASE 2
	IF NOT VAL(RIGHT$(y2k$,4)) MOD 4=0 THEN
		IF day>29 THEN newDATE$="03-01-"+RIGHT$(y2k$,4)
	ELSE
		IF day>28 THEN newDATE$="03-01-"+RIGHT$(y2k$,4)
	END IF
CASE 3:IF day>31 THEN newDATE$="04-01-"+RIGHT$(y2k$,4)
CASE 4:IF day>30 THEN newDATE$="05-01-"+RIGHT$(y2k$,4)
CASE 5:IF day>31 THEN newDATE$="06-01-"+RIGHT$(y2k$,4)
CASE 6:IF day>30 THEN newDATE$="07-01-"+RIGHT$(y2k$,4)
CASE 7:IF day>31 THEN newDATE$="08-01-"+RIGHT$(y2k$,4)
CASE 8:IF day>31 THEN newDATE$="09-01-"+RIGHT$(y2k$,4)
CASE 9:IF day>30 THEN newDATE$="10-01-"+RIGHT$(y2k$,4)
CASE 10:IF day>31 THEN newDATE$="11-01-"+RIGHT$(y2k$,4)
CASE 11:IF day>30 THEN newDATE$="12-01-"+RIGHT$(y2k$,4)
CASE 12:IF day>31 THEN newDATE$="01-01-"+RIGHT$(STR$(VAL(RIGHT$(y2k$,4))+1),LEN(STR$(VAL(RIGHT$(y2k$,4))-1))+1)
END SELECT
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Sliderclock

END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Closeclock
SHARED clock_handle,clockid,clocktimer,menutree&,commonclose

clocktimer=0
clock_handle=0
commonclose=-1
junk=wind_close(clock_handle)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Start_ClockTimer
SHARED clock_handle,WindW,WindH,data$(),clockFNT,clockSIZE
SHARED clocktimer,scrx,scry,scrw,scrh,WindX,WindY,finished_flag
STATIC info(),info2(),info3(),dum&,y2k$

y2k$=dateform$ (0,"/")

IF NOT GETCOOKIE("Gnva",dum&) THEN
IF NOT GETCOOKIE("MagX",dum&) THEN
	IF NOT GETCOOKIE("MINT",dum&) THEN finished_flag=-1:EXIT SUB
END IF
END IF

IF clock_handle THEN
	TopAWindow clock_handle
ELSE
	clocktimer=-1
	CALL vst_font(FNTid)
	REDIM PRESERVE info(10)
	REDIM PRESERVE info2(10)
	REDIM PRESERVE info3(10)
	junk=vst_arbpt(VAL(DATA$(33)),junk,junk,junk,junk)
	CALL vqt_f_extent("00:00:00",info())
	WindW=info(2)
	CALL vqt_fontinfo(junk,junk,info2(),junk,info3())
	WindH=info2(3)+(info2(2)/8)
	IF WindW<72 THEN WindW=72
	IF WindH<48 THEN WindH=48
	WindX=(scrw-WindW)/2
	WindY=(scrh-Windh)/2
	clockFNT=FNTid:clockSIZE=VAL(DATA$(33))
	clock_handle=OpenAWindow(MID$(y2k$,4,2)+"-"+LEFT$(y2k$,2)+"-"+RIGHT$(y2k$,4),&h0B+win_icon,VARPTRS(Redrawclock),VARPTRS(Sliderclock),VARPTRS(Closeclock))
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB QUIT_ME
SHARED finished_flag,commonclose
STATIC button

MOUSE 2
button=form_alert(2,"[2][  Do you really want to quit? |  All unsaved data will be |  lost! ][ Continue | Cancel ]")
SELECT CASE button
	CASE 1
		commonclose=-1
		finished_flag=-1
END SELECT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB MainLoop
SHARED finished_flag,Mess(1),clicks_enabled,keys_enabled,menus_enabled,forms_enabled
SHARED commonclose,mouse_detect_both,data$(),alarm,alarm$,snooze,eggtimer
SHARED eggtime,font_handle,clock_handle,egg_handle,eggtime!,eggsecs
SHARED clocktimer,menu_time,start_time&,verified
STATIC ev,key_pressed,clicks,x,y,kstate,button,mclicks,mmask,mstate,a$,but
STATIC minute$,hour$,handle,message,wx,wy,ww,wh,i

REDIM PRESERVE mess(7)
IF mouse_detect_both THEN
	mclicks=258
	mmask=3
	mstate=0
ELSE
	mclicks=2
	mmask=1
	mstate=1
END IF

 finished_flag=0
 DO
	IF NOT verified=1 THEN
	IF TIMER-start_time&>=(60*30) THEN
		finished_flag=-1
		junk=form_alert(1,"[1][  AutoClock v2.61 has now expired! |  Please see documentation about |  registering!  Thanks. ][ I will! ]")
		CALL vst_font(1)
		CALL vst_point(8)
		junk=wind_get(junk,wf_fullxywh,wx,wy,ww,wh)
		CALL vs_clip(0,0,0,0,0)
		v_gtext ww-12,7, "           "
		v_gtext ww-12,15,"           "
		EXIT LOOP
	END IF
	END IF
	IF eggtimer=-1 THEN
		i=50
	ELSE
		i=2000
	END IF

	junk=wind_update(END_UPDATE)
	ev=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON+MU_TIMER,mclicks,mmask,mstate, _
			0,0,0,0,0,_
			0,0,0,0,0,_
			VARPTR(mess(0)),i,_
			x,y, _
			button,kstate, _
			key_pressed,clicks)
	junk=wind_update(BEG_UPDATE)

' Start of AutoClock specific code

	IF eggtimer=-1 THEN
		IF eggsecs-(TIMER-eggtime!)<0 THEN CALL redrawegg(egg_handle," 0.00000"):BEEP:eggtimer=-2:EXIT IF
		IF eggsecs-(TIMER-eggtime!)>=0 THEN CALL redrawegg(egg_handle,STR$(eggsecs-(TIMER-eggtime!)))
	END IF
	IF clocktimer=-1 THEN CALL redrawclock(clock_handle)
	IF menu_time=1 THEN CALL redrawclock2

	IF alarm<>0 THEN
STATIC y2k$
y2k$=dateform$ (0,"/")

		IF alarm$=LEFT$(TIME$,5) THEN
			SelectTree FORM_ALARM
			Sette_ptext ALARM_NOW,CHR$(9)+LEFT$(TIME$,5)+" - "+MID$(y2k$,4,2)+"-"+LEFT$(y2k$,2)+"-"+RIGHT$(y2k$,4)
			Sette_ptext Ames1,DATA$(5)
			Sette_ptext Ames2,DATA$(6)
			Sette_ptext Ames3,DATA$(7)
			Sette_ptext Ames4,DATA$(8)
			Sette_ptext Ames5,DATA$(9)
			Sette_ptext Ames6,DATA$(10)
			Sette_ptext Ames7,DATA$(11)
			Sette_ptext Ames8,DATA$(12)
			Sette_ptext Ames9,DATA$(13)
			Sette_ptext Ames10,DATA$(14)
			but=HandleDialog(0)
			IF alarm=-2 THEN
				alarm=0
			ELSE
				IF snooze=-1 THEN 
					SelectTree FORM_PREF
					IF VAL(RIGHT$(DATA$(2),2))+VAL(Gette_ptext$(SET_SNOOZE))>59 THEN  
						minute$=STR$(60-(VAL(RIGHT$(DATA$(2),2))+VAL(Gette_ptext$(SET_SNOOZE))))
						minute$=RIGHT$(minute$,2)
						hour$=RIGHT$(STR$(VAL(LEFT$(DATA$(2),2))+1),2)
						IF VAL(hour$)+1>23 THEN hour$="00"
					ELSE
						minute$=STR$(VAL(RIGHT$(DATA$(2),2))+VAL(Gette_ptext$(SET_SNOOZE)))
						minute$=RIGHT$(minute$,2)
						hour$=LEFT$(DATA$(2),2)
					END IF
					IF VAL(minute$)<10 THEN minute$="0"+RIGHT$(minute$,1)
					alarm$=hour$+":"+minute$
					alarm=-2
				END IF
			END IF
		END IF
	END IF

' End of AutoClock specific code

	IF ev AND MU_KEYBD THEN	KeyboardEvent key_pressed,kstate
	IF ev AND MU_MESAG THEN
		do_message
		message=mess(0)
		SELECT CASE message 
			CASE wm_redraw
				handle=mess(3)
				SELECT CASE handle
					CASE font_handle:CALL UPDATE_FNTDISPLAY(mess(3))
					CASE egg_handle:CALL redrawegg(egg_handle,STR$(eggsecs-(TIMER-eggtime!)))
					CASE clock_handle:CALL redrawclock(clock_handle)
				END SELECT
			CASE wm_iconify
				junk=wind_set(mess(3),wf_iconify,mess(4),mess(5),mess(6),mess(7))
			CASE wm_uniconify
				junk=wind_set(mess(3),wf_uniconify,mess(4),mess(5),mess(6),mess(7))
		END SELECT
	END IF

	IF ev AND MU_BUTTON THEN
		IF forms_enabled THEN
			IF NOT ProcessFormClicks(button,clicks,kstate,x,y) THEN
				IF clicks_enabled THEN 	ProcessClicks clicks,kstate,x,y
			END IF
		ELSE
			IF clicks_enabled THEN 	ProcessClicks clicks,kstate,x,y
		END IF
	END IF
	IF finished_flag=-1 THEN EXIT LOOP
 LOOP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

start_time&=TIMER
RETURN_HANDLER:
ON ERROR GOTO ERROR_HANDLER
Startprogram CURDIR$+"\AUTOCLOK.RSC",MENU1,-1
IF NOT GETCOOKIE("MINT",dum&) THEN 
	IF NOT GETCOOKIE("Gnva",dum&) THEN
	IF NOT GETCOOKIE("MagX",dum&) THEN
		CALL menu_ienable(menutree&,MENU_OPENCLOCK,0)
		CALL menu_ienable(menutree&,MENU_CITYT,0)
		CALL menu_ienable(menutree&,MENU_OPTIONST,0)
	END IF
	END IF
END IF
CALL menu_bar(menutree&,1)
CALL Initialise
set_handle=openformwindow(" AutoClock : Set Clock... ",&h0B+win_icon,FORM_MAIN,SET_TIME,CANCEL,VARPTRS(close_setdialog))

retry:
CALL Mainloop
IF total_fnts>1 THEN CALL vst_unload_fonts
StopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ERROR_HANDLER:
MOUSE 1
IF ERR=68 THEN CALL NoMoreWindows:SYSTEM
button=form_alert(1,"[1][  An ERROR"+STR$(ERR)+" has occurred ! |  Try to tolerate or abort |  program? | ][ Tolerate | Abort ]")
SELECT CASE button
	CASE 2
		junk=rsrc_free
		SYSTEM
END SELECT
GOTO RETURN_HANDLER

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
