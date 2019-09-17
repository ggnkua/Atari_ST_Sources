'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Calc IT v4.00  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC ACC Toolkit - Written by Dave Nutkins, (c) HiSoft 1991
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Include ACCTBOX.T

DEFINT a-z
'$option j10,y
'$include E:\CADENZA.97\CALC_IT\CALC_IT.BH

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ON ERROR GOTO ERROR_HANDLER
StartAccessory "  Calc IT v4.00 "
DO
	evnt_mesag VARPTR(mess(0))
	CALL do_message:GOTO start_handler
LOOP

START_HANDLER:
ON ERROR GOTO ERROR_HANDLER
xhgtloop2

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB xHGTloop2
STATIC ev,key_pressed,clicks,x,y,kstate,button
STATIC mclicks,mmask,mstate
SHARED finished_flag,Mess(1),clicks_enabled,keys_enabled,menus_enabled,forms_enabled
REDIM PRESERVE mess(7)
SHARED mouse_detect_both
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
	junk=wind_update(END_UPDATE)
	ev=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON,mclicks,mmask,mstate, _
			0,0,0,0,0,_
			0,0,0,0,0,_
			VARPTR(mess(0)),0,_
			x,y, _
			button,kstate, _
			key_pressed,clicks)
	junk=wind_update(BEG_UPDATE)

	IF ev AND MU_KEYBD THEN	
		KeyboardEvent key_pressed,kstate
		CALL keypressed (key_pressed AND 255)
	END IF

	IF ev AND MU_MESAG THEN
		do_message
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
LOOP UNTIL INKEY$=CHR$(27)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB AccOpened
SHARED commonclose,commonobj,resource_loaded
SHARED main_handle
STATIC i

INCR i
IF resource_loaded=0 THEN
	MOUSE 2
	IF rsrc_load(CURDIR$+"\CALC_IT.RSC")=0 THEN
		junk=form_alert(1,"[1][  Error while loading |  resource file. | ][ Abort ]")
		MOUSE 0:resource_loaded=0:EXIT SUB	
	END IF
	MOUSE 0:resource_loaded=-1
END IF

IF i=1 THEN 
	SelectTree Form_About
	junk=HandleDialog(0)
	SelectTree Form_Main
	Sette_ptext Answer1,""
	Sette_ptext Answer2,""
	Sette_ptext RAnswer1,""
END IF

commonclose=0
IF main_handle THEN
	TopAWindow main_handle
ELSE
	main_handle=openformwindow(" Calc IT v4.00 ",9,FORM_MAIN,0,Quit,VARPTRS(close_dialog))
	Object_Redraw main_handle,commonobj
	IF i>1 THEN FullRedraw main_handle
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_dialog
SHARED dec_exists,digits,multi_status,memory$,mem
SHARED commonclose,commonobj,main_handle,answer#,a1_status,a2_status
STATIC i

commonclose=0										
SELECT CASE commonobj
	CASE=ONE:CALL display("1")
	CASE=TWO:CALL display("2")
	CASE=THREE:CALL display("3")
	CASE=FOUR:CALL display("4")
	CASE=FIVE:CALL display("5")
	CASE=SIX:CALL display("6")
	CASE=SEVEN:CALL display("7")
	CASE=EIGHT:CALL display("8")
	CASE=NINE:CALL display("9")
	CASE=ZERO:CALL display("0")
	CASE=DECIMAL
		IF a1_status<>-1
		IF dec_exists=0 THEN
			dec_exists=-1
			INCR digits
			Sette_ptext Answer2,Gette_ptext$(Answer2)+"."
			IF LEFT$(Gette_ptext$(Answer2),1)="." THEN Sette_ptext Answer2,"0"+Gette_ptext$(Answer2)
			Object_Redraw main_handle,Answer2
		END IF
		END IF
	CASE=C
		dec_exists=0:digits=0:a1_status=0:a2_status=0
		Sette_ptext Answer2,""
		Object_Redraw main_handle,Answer2
	CASE=AC
		dec_exists=0:digits=0:multi_status=0:a1_status=0:a2_status=0
		Sette_ptext Answer1,"":Sette_ptext Answer2,""
		Sette_ptext RAnswer1,""
		Object_Redraw main_handle,Answer1:Object_Redraw main_handle,RAnswer1
		Object_Redraw main_handle,Answer2
	CASE=PLUSORMINUS
		IF a1_status<>-1
		IF Gette_ptext$(Answer2)="" THEN
			Sette_ptext Answer1,STR$(VAL(Gette_ptext$(Answer1))-(2*VAL(Gette_ptext$(Answer1))))
			Object_Redraw main_handle,Answer1
		ELSE
			Sette_ptext Answer2,STR$(VAL(Gette_ptext$(Answer2))-(2*VAL(Gette_ptext$(Answer2))))
			Object_Redraw main_handle,Answer2
		END IF
		END IF
	CASE=BACK:CALL backspace
	CASE=MC
		mem=0
		memory$=""
		Setob_state Memory,8:Object_Redraw main_handle,Memory
	CASE 19
		IF mem THEN
			Sette_ptext Answer2,memory$
			Object_Redraw main_handle,Answer2
			mem=0
			memory$=""
			Setob_state Memory,8:Object_Redraw main_handle,Memory
		END IF
	CASE=MR
		IF mem THEN
			Sette_ptext Answer2,memory$
			digits=LEN(memory$)
			i=LEN(memory$)
			DO
			IF MID$(memory$,i)="." THEN dec_exists=-1:EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
			LOOP	
			Object_Redraw main_handle,Answer2
		END IF
	CASE=MS
		IF NOT Gette_ptext$(Answer2)="" THEN
			mem=-1
			memory$=Gette_ptext$(Answer2)
			Setob_state Memory,0:Object_Redraw main_handle,Memory
		ELSE
			IF NOT Gette_ptext$(Answer1)="" THEN
				mem=-1
				memory$=Gette_ptext$(Answer1)
				Setob_state Memory,0:Object_Redraw main_handle,Memory
			END IF
		END IF
	CASE=MADD
		IF NOT Gette_ptext$(Answer2)="" THEN
			mem=-1
			memory$=STR$(VAL(memory$)+VAL(Gette_ptext$(Answer2)))
			Setob_state Memory,0:Object_Redraw main_handle,Memory
		ELSE
			IF NOT Gette_ptext$(Answer1)="" THEN
				mem=-1
				memory$=STR$(VAL(memory$)+VAL(Gette_ptext$(Answer1)))
				Setob_state Memory,0:Object_Redraw main_handle,Memory
			END IF
		END IF
	CASE=LBRACKET:CALL OpenBracket
	CASE=RBRACKET:CALL CloseBracket

	CASE=DIVIDE:CALL Multi(CHR$(246))
	CASE=MULTIPLY:CALL Multi("X")
	CASE=MINUS:CALL Multi("-")
	CASE=ADD:CALL Multi("+")
	CASE=EQUALS:CALL WorkOUT("=")

	CASE=PERCENT:CALL Functions("%")
	CASE=ROOT:CALL Functions(CHR$(251))

	CASE=SINN:CALL Functions("SIN")
	CASE=COSS:CALL Functions("COS")
	CASE=TANN:CALL Functions("TAN")
	CASE=LOGS:CALL Functions("LOG")
	CASE=INV_LOG:CALL Functions("10N")
	CASE=LN:CALL Functions("LN")
	CASE=INV_LN:CALL Functions("EN")

	CASE=OVERX:CALL Functions("1/x")
	CASE=16:CALL Functions("x2")
	CASE=X3:CALL Functions("x3")
	CASE=XN:CALL Multi("x"+CHR$(252))
	CASE=PIE
		IF a1_status<>-1 THEN
		Sette_ptext Answer2,STR$(4*ATN(1#))
		Object_Redraw main_handle,Answer2
		digits=17:dec_exists=-1
		END IF
	CASE=INFO:SelectTree Form_About:junk=HandleDialog(0):SelectTree Form_Main
	CASE=QUIT:commonclose=-1:main_handle=0
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB display(ascii$)
SHARED main_handle,digits

INCR digits
IF digits>25 THEN digits=25:EXIT SUB
Sette_ptext Answer2,Gette_ptext$(Answer2)+ascii$
Object_Redraw main_handle,Answer2
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB backspace
SHARED main_handle,digits,dec_exists,a1_status

DECR digits
IF digits<0 THEN digits=0:EXIT SUB
IF RIGHT$(Gette_ptext$(Answer2),1)="." THEN dec_exists=0
IF RIGHT$(Gette_ptext$(Answer2),1)="(" THEN IF a1_status=-1 THEN a1_status=0
IF RIGHT$(Gette_ptext$(Answer2),1)=")" THEN IF a1_status=0 THEN a1_status=-1
Sette_ptext Answer2,LEFT$(Gette_ptext$(Answer2),digits)
Object_Redraw main_handle,Answer2
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Multi(type$)
SHARED dec_exists,digits,multi_status,memory$,mem
SHARED main_handle,a1_status

IF a1_status<>-1 THEN
IF Gette_ptext$(Answer2)="" THEN
	IF Gette_ptext$(Answer1)<>"" THEN
		multi_status=-1
		Sette_ptext RAnswer1,type$
		Object_Redraw main_handle,RAnswer1
	ELSE
		EXIT SUB	
	END IF
END IF

IF NOT Gette_ptext$(RAnswer1)="=" THEN
	IF NOT Gette_ptext$(RAnswer1)="" THEN
		CALL WorkOUT(type$)
		EXIT SUB
	END IF
END IF

dec_exists=0
digits=0
multi_status=-1
Sette_ptext Answer1,Gette_ptext$(Answer2)
Sette_ptext Answer2,""
Sette_ptext RAnswer1,type$
Object_Redraw main_handle,Answer1
Object_Redraw main_handle,RAnswer1
Object_Redraw main_handle,Answer2
ELSE
EXIT SUB
SELECT CASE type$
	CASE=="=":EXIT SUB
	CASE ELSE
		INCR digits
		IF digits>25 THEN digits=25:EXIT SUB
		Sette_ptext Answer2,Gette_ptext$(Answer2)+type$
		Object_Redraw main_handle,Answer2
END SELECT
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB WorkOUT(Choice$)
SHARED dec_exists,digits,multi_status,memory$,mem
SHARED main_handle,a1_status
STATIC Chose$,answer#,i,k,answer1#,answer2#

IF a1_status<>-1 THEN
IF Gette_ptext$(Answer2)="" THEN EXIT SUB

answer#=0
Chose$=Gette_ptext$(RAnswer1)
SELECT CASE Chose$
	CASE="%"
		answer#=VAL(Gette_ptext$(Answer1))*VAL("0."+Gette_ptext$(Answer2)) 
		Sette_ptext Answer1,STR$(answer#)
	CASE=CHR$(246)
		answer#=VAL(Gette_ptext$(Answer1))/VAL(Gette_ptext$(Answer2)) 
		Sette_ptext Answer1,STR$(answer#)
	CASE="X"
		answer#=VAL(Gette_ptext$(Answer1))*VAL(Gette_ptext$(Answer2)) 
		Sette_ptext Answer1,STR$(answer#)
	CASE="-"
		answer#=VAL(Gette_ptext$(Answer1))-VAL(Gette_ptext$(Answer2)) 
		Sette_ptext Answer1,STR$(answer#)
	CASE="+"
		answer#=VAL(Gette_ptext$(Answer1))+VAL(Gette_ptext$(Answer2)) 
		Sette_ptext Answer1,STR$(answer#)
	CASE=="="
		EXIT SUB
	CASE=="x"+CHR$(252)
		answer#=VAL(Gette_ptext$(Answer1))^VAL(Gette_ptext$(Answer2)) 
		Sette_ptext Answer1,STR$(answer#)
END SELECT

dec_exists=0
digits=0
multi_status=0
Sette_ptext Answer2,""
Sette_ptext RAnswer1,Choice$
Object_Redraw main_handle,Answer1
Object_Redraw main_handle,RAnswer1
Object_Redraw main_handle,Answer2
ELSE
CALL CloseBracket
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Functions(Chose$)
SHARED dec_exists,digits,multi_status,memory$,mem
SHARED main_handle,a1_status
STATIC answer#,i

IF a1_status<>-1 THEN
IF Gette_ptext$(Answer2)="" THEN
SELECT CASE Chose$
	CASE=="1/x"
		answer#=1/VAL(Gette_ptext$(Answer1)) 
	CASE="x2"
		answer#=(VAL(Gette_ptext$(Answer1))*VAL(Gette_ptext$(Answer1))) 
	CASE="x3"
		answer#=VAL(Gette_ptext$(Answer1))*VAL(Gette_ptext$(Answer1))*VAL(Gette_ptext$(Answer1)) 
	CASE=CHR$(251)
		Sette_ptext Answer1,Gette_ptext$(Answer1)
		Sette_ptext Answer2,""
		Sette_ptext RAnswer1,CHR$(251)
		Object_Redraw main_handle,Answer1
		Object_Redraw main_handle,RAnswer1
		Object_Redraw main_handle,Answer2
		answer#=SQR(VAL(Gette_ptext$(Answer1)))
	CASE="LOG"
		answer#=LOG10(VAL(Gette_ptext$(Answer1)))
	CASE="10N"
		answer#=VAL(Gette_ptext$(Answer1)) 
		answer#=10^answer#
	CASE="LN"
		answer#=LOG(VAL(Gette_ptext$(Answer1)))
	CASE="EN"
		answer#=EXP(VAL(Gette_ptext$(Answer1)))
	CASE="SIN"
		answer#=SIN(VAL(Gette_ptext$(Answer1))/57.2957795152)
	CASE="COS"
		answer#=COS(VAL(Gette_ptext$(Answer1))/57.2957795152)
	CASE="TAN"
		answer#=TAN(VAL(Gette_ptext$(Answer1))/57.2957795152)
END SELECT

dec_exists=0
digits=0
multi_status=0
Sette_ptext Answer1,STR$(answer#)
Sette_ptext Answer2,""
Sette_ptext RAnswer1,"="
Object_Redraw main_handle,Answer1
Object_Redraw main_handle,RAnswer1
Object_Redraw main_handle,Answer2
ELSE
SELECT CASE Chose$
	CASE=="%"
		IF Gette_ptext$(RAnswer1)=CHR$(246) THEN answer#=(VAL(Gette_ptext$(Answer1))/VAL(Gette_ptext$(Answer2)))*100
		IF Gette_ptext$(RAnswer1)="X" THEN answer#=(VAL(Gette_ptext$(Answer1))*VAL(Gette_ptext$(Answer2)))/100
		IF Gette_ptext$(RAnswer1)="-" THEN EXIT SUB
		IF Gette_ptext$(RAnswer1)="+" THEN EXIT SUB
		Sette_ptext Answer2,Gette_ptext$(Answer2)
		Sette_ptext Answer1,""
		Sette_ptext RAnswer1,"%"
		Object_Redraw main_handle,Answer1
		Object_Redraw main_handle,RAnswer1
		Object_Redraw main_handle,Answer2
	CASE=="1/x"
		answer#=1/VAL(Gette_ptext$(Answer2)) 
	CASE="x2"
		answer#=(VAL(Gette_ptext$(Answer2))*VAL(Gette_ptext$(Answer2))) 
	CASE="x3"
		answer#=VAL(Gette_ptext$(Answer2))*VAL(Gette_ptext$(Answer2))*VAL(Gette_ptext$(Answer2)) 
	CASE=CHR$(251)
		Sette_ptext Answer1,Gette_ptext$(Answer2)
		Sette_ptext Answer2,""
		Sette_ptext RAnswer1,CHR$(251)
		Object_Redraw main_handle,Answer1
		Object_Redraw main_handle,RAnswer1
		Object_Redraw main_handle,Answer2
		answer#=SQR(VAL(Gette_ptext$(Answer1)))
	CASE="LOG"
		answer#=LOG10(VAL(Gette_ptext$(Answer2)))
	CASE="10N"
		answer#=VAL(Gette_ptext$(Answer2)) 
		answer#=10^answer#
	CASE="LN"
		answer#=LOG(VAL(Gette_ptext$(Answer2)))
	CASE="EN"
		answer#=EXP(VAL(Gette_ptext$(Answer2)))
	CASE="SIN"
		answer#=SIN(VAL(Gette_ptext$(Answer2))/57.2957795152)
	CASE="COS"
		answer#=COS(VAL(Gette_ptext$(Answer2))/57.2957795152)
	CASE="TAN"
		answer#=TAN(VAL(Gette_ptext$(Answer2))/57.2957795152)
END SELECT

dec_exists=0
digits=0
multi_status=0
Sette_ptext Answer1,STR$(answer#)
Sette_ptext Answer2,""
Sette_ptext RAnswer1,"="
Object_Redraw main_handle,Answer1
Object_Redraw main_handle,RAnswer1
Object_Redraw main_handle,Answer2
END IF
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB OpenBracket
SHARED dec_exists,digits,main_handle,answer1#,a1_status,a1_len,bracket_type
SHARED type_status

IF a1_status<>-1 THEN
bracket_type=2
IF LEN(Gette_ptext$(Answer2))>0 THEN
	answer1#=VAL(Gette_ptext$(Answer2))
	a1_len=LEN(Gette_ptext$(Answer2))
	type_status=1
	bracket_type=1
ELSE
	IF Gette_ptext$(RAnswer1)="=" THEN EXIT SUB
	answer1#=VAL(Gette_ptext$(Answer1))
	a1_len=LEN(Gette_ptext$(Answer1))
	IF Gette_ptext$(RAnswer1)="X" THEN bracket_type=1
	IF Gette_ptext$(RAnswer1)=CHR$(246) THEN bracket_type=2
	IF Gette_ptext$(RAnswer1)="-" THEN bracket_type=3
	IF Gette_ptext$(RAnswer1)="+" THEN bracket_type=4
	type_status=2
END IF

INCR digits
IF digits>25 THEN digits=25:EXIT SUB
a1_status=-1
dec_exists=0
Sette_ptext Answer2,Gette_ptext$(Answer2)+"("
Object_Redraw main_handle,Answer2
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB CloseBracket
SHARED dec_exists,digits,main_handle,answer2#,a1_status,a1_len,answer1#
SHARED bracket_type,type_status
STATIC i

IF a1_status=-1 THEN
INCR digits
IF digits>25 THEN digits=25:EXIT SUB

IF type_status=1 THEN answer2#=VAL(RIGHT$(Gette_ptext$(Answer2),(LEN(Gette_ptext$(Answer2))-a1_len)-1))
IF type_status=2 THEN answer2#=VAL(MID$(Gette_ptext$(Answer2),2,(LEN(Gette_ptext$(Answer2))-1)))
a1_status=0
dec_exists=0
Sette_ptext Answer2,Gette_ptext$(Answer2)+")"
Object_Redraw main_handle,Answer2
i=0
DO
INCR i
LOOP UNTIL i>2000
IF type_status=1 THEN
	SELECT CASE bracket_type
		CASE 1:Sette_ptext Answer2,STR$(answer1#*(answer2#))
		CASE 2:Sette_ptext Answer2,STR$(answer1#/(answer2#))
		CASE 3:Sette_ptext Answer2,STR$(answer2#-(answer1#))
		CASE 4:Sette_ptext Answer2,STR$(answer1#+(answer2#))
	END SELECT
	Object_Redraw main_handle,Answer2
ELSE
	SELECT CASE bracket_type
		CASE 1:Sette_ptext Answer1,STR$(answer1#*(answer2#))
		CASE 2:Sette_ptext Answer1,STR$(answer1#/(answer2#))
		CASE 3:Sette_ptext Answer1,STR$(answer2#-(answer1#))
		CASE 4:Sette_ptext Answer1,STR$(answer1#+(answer2#))
	END SELECT
	Sette_ptext RAnswer1,"="
	Sette_ptext Answer2,""
	Object_Redraw main_handle,Answer2
	Object_Redraw main_handle,RAnswer1
	Object_Redraw main_handle,Answer1
END IF
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB keypressed(i)
SHARED dec_exists,digits,multi_status,memory$,mem
SHARED main_handle,commonobj
STATIC key$

key$=CHR$(i)
SELECT CASE key$
	CASE="0":CALL display(key$)
	CASE="1":CALL display(key$)
	CASE="2":CALL display(key$)
	CASE="3":CALL display(key$)
	CASE="4":CALL display(key$)
	CASE="5":CALL display(key$)
	CASE="6":CALL display(key$)
	CASE="7":CALL display(key$)
	CASE="8":CALL display(key$)
	CASE="9":CALL display(key$)
	CASE="."
		IF dec_exists=0 THEN
			dec_exists=-1
			INCR digits
			Sette_ptext Answer2,Gette_ptext$(Answer2)+"."
			IF LEFT$(Gette_ptext$(Answer2),1)="." THEN Sette_ptext Answer2,"0"+Gette_ptext$(Answer2)
			Object_Redraw main_handle,Answer2
		END IF
	CASE="/":CALL Multi(CHR$(246))
	CASE="*":CALL Multi("X")
	CASE="-":CALL Multi("-")
	CASE="+":CALL Multi("+")
	CASE="=":CALL WorkOUT("=")
	CASE=CHR$(13):CALL WorkOUT("=")
	CASE=CHR$(8):CALL backspace
	CASE="(":CALL OpenBracket
	CASE=")":CALL CloseBracket
END SELECT
END SUB

' Error Sub-programs תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Find out error occurred
ERROR_HANDLER:
error_no=ERR
SELECT CASE error_no
	CASE 5 
		Sette_ptext Answer2,"Error"
		Object_Redraw main_handle,Answer2
		ON ERROR GOTO ERROR_HANDLER
		GOTO START_HANDLER
	CASE 6 
		Sette_ptext Answer2,"Error"
		Object_Redraw main_handle,Answer2
		ON ERROR GOTO ERROR_HANDLER
		GOTO START_HANDLER
	CASE 11 
		Sette_ptext Answer2,"Error"
		Object_Redraw main_handle,Answer2
		ON ERROR GOTO ERROR_HANDLER
		GOTO START_HANDLER
	CASE 68 
		CALL NoMoreWindows
		SYSTEM
END SELECT

JUNK=form_alert(1,"[1][  An ERROR"+STR$(ERR)+" has occurred ! |  Abort to main program |  loop. | ][ Abort ]")
SelectTree FORM_MAIN
ON ERROR GOTO ERROR_HANDLER
GOTO START_HANDLER

' End תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
