'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' tictactoe  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' ½ Copyright HiSoft 1991-3
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z
'$option q50,y
'$include D:\HBASIC\HGT\gemaes.bh
'$include D:\HBASIC\HGT\toolbox.bas
'$include D:\HBASIC\HGT\objcext.bas
'$include D:\HBASIC\HGT\xformdo.bas
'$include D:\HBASIC\HGT\window.bas
'$include D:\HBASIC\HGT\objwind.bas
'$include D:\HBASIC\HGT\formwind.bas
'$INCLUDE E:\CADENZA.97\TIC_TAC.TOE\REGISTER.ED\TICTAC.BH

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Initialise
SHARED TL,TC,TR,CL,CC,CR,BL,BC,BR,whos_go$

SelectTree FORM_MAIN
TL=-1:TC=-1:TR=-1:CL=-1:CC=-1:CR=-1:BL=-1:BC=-1:BR=-1
Sette_ptext VS,"Human"
whos_go$="Human"
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_aboutdialog
SHARED commonclose,commonobj,about_handle,main_handle

commonclose=0										
SELECT CASE commonobj
	CASE=ABOUTOK
		Initialise
		main_handle=openformwindow(" tictactoe ",&h0B,FORM_MAIN,0,Quit,VARPTRS(close_maindialog))
		commonclose=-1
		about_handle=0
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_maindialog
SHARED commonclose,commonobj,main_handle,finished_flag
SHARED TL,TC,TR,CL,CC,CR,BL,BC,BR,whos_go$,last_go$,object_go,outx,outy
STATIC button,startx,starty,object,an_object,time!

commonclose=0										
SELECT CASE commonobj
	CASE SWITCH
		IF Gette_ptext$(VS)="Computer" THEN
			Sette_ptext VS,"Human"
		ELSE
			Sette_ptext VS,"Computer"
		END IF
		Object_Redraw main_handle,VS

		Setob_state commonobj,0:Object_Redraw main_handle,commonobj
		GOTO Start_A_New
	CASE NEW_GAME
Start_A_New:
		object_go=0
		TL=-1:TC=-1:TR=-1:CL=-1:CC=-1:CR=-1:BL=-1:BC=-1:BR=-1
		FOR an_object=N1 TO CROSS5
			Inclob_flags an_object,mask_hidetree
		NEXT
		Object_Redraw main_handle,board
		whos_go$="Human"

		IF Gette_ptext$(VS)="Computer" THEN
			button=form_alert(1,"[2][  Do you wish to start? ][ Yes | No ]")
			SELECT CASE button
				CASE 1
					whos_go$="Human"
				CASE 2
					whos_go$="Computer"
					GOTO take_a_go
			END SELECT
		END IF
	CASE=QUIT
		commonclose=-1
		finished_flag=-1
		main_handle=0
	CASE ELSE
		junk=objc_offset(tree&,BOARD,startx,starty)
		outx=MOUSE(0)-startx
		outy=MOUSE(1)-starty
take_a_go:
		INCR object_go
		Workout object,outx,outy
		Draw_Square object,outx,outy
		Object_Redraw main_handle,board
		CALL Check_Board
		IF object_go=9 THEN object_go=10:CALL Game_Over("Noone"):EXIT SUB
		IF whos_go$="Computer" THEN
			whos_go$="Human"
		ELSE
			whos_go$="Computer"
			time!=TIMER
			IF LEFT$(Gette_ptext$(VS),1)="C" THEN
				DO
				LOOP UNTIL TIMER-time!>0.5
				GOTO take_a_go
			END IF
		END IF
END SELECT
IF NOT commonobj=board THEN Setob_state commonobj,0:Object_Redraw main_handle,commonobj
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Draw_Square (object,outx,outy)
SHARED TL,TC,TR,CL,CC,CR,BL,BC,BR,last_go$,object_go

SELECT CASE outx
CASE 3 TO 55
	SELECT CASE outy
	CASE 3 TO 53
		IF TL>-1 THEN DECR object_go:GOTO main_loop
		last_go$="TL"
		Set_Square object,3,3,TL
	CASE 54 TO 104
		IF CL>-1 THEN DECR object_go:GOTO main_loop
		last_go$="CL"
		Set_Square object,3,54,CL
	CASE 105 TO 153
		IF BL>-1 THEN DECR object_go:GOTO main_loop
		last_go$="BL"
		Set_Square object,3,105,BL
	END SELECT
	Exclob_flags object,mask_hidetree
CASE 56 TO 108
	SELECT CASE outy
	CASE 3 TO 53
		IF TC>-1 THEN DECR object_go:GOTO main_loop
		last_go$="TC"
		Set_Square object,56,3,TC
	CASE 54 TO 104
		IF CC>-1 THEN DECR object_go:GOTO main_loop
		last_go$="CC"
		Set_Square object,56,54,CC
	CASE 105 TO 153
		IF BC>-1 THEN DECR object_go:GOTO main_loop
		last_go$="BC"
		Set_Square object,56,105,BC
	END SELECT
	Exclob_flags object,mask_hidetree
CASE 109 TO 157
	SELECT CASE outy
	CASE 3 TO 53
		IF TR>-1 THEN DECR object_go:GOTO main_loop
		last_go$="TR"
		Set_Square object,109,3,TR
	CASE 54 TO 104
		IF CR>-1 THEN DECR object_go:GOTO main_loop
		last_go$="CR"
		Set_Square object,109,54,CR
	CASE 105 TO 153
		IF BR>-1 THEN DECR object_go:GOTO main_loop
		last_go$="BR"
		Set_Square object,109,105,BR
	END SELECT
	Exclob_flags object,mask_hidetree
CASE ELSE
	DECR object_go
	GOTO main_loop
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Set_Square (object,x,y,square)
SHARED Computer,Human,whos_go$

Setob_x object,x
Setob_y object,y
IF whos_go$="Computer" THEN
	square=Computer
ELSE
	square=Human
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Workout(object,outx,outy)
SHARED main_handle,TL,TC,TR,CL,CC,CR,BL,BC,BR
SHARED Computer,Human,object_go,whos_go$,last_go$
STATIC button,an_object,Random_Go

SELECT CASE object_go
	CASE>=11
		object_go=1
		TL=-1:TC=-1:TR=-1:CL=-1:CC=-1:CR=-1:BL=-1:BC=-1:BR=-1
		FOR an_object=N1 TO CROSS5
			Inclob_flags an_object,mask_hidetree
		NEXT
		Object_Redraw main_handle,board
		whos_go$="Human"

		IF Gette_ptext$(VS)="Computer" THEN
			button=form_alert(1,"[2][  Do you wish to start? ][ Yes | No ]")
			SELECT CASE button
				CASE 1
					object_go=0
					whos_go$="Human"
					GOTO main_loop
				CASE 2
					whos_go$="Computer"
			END SELECT
		END IF
		object=Cross1
		GOTO First_go
	CASE 1
First_go:
		IF whos_go$="Computer" THEN
			Computer=1:Human=0
			INCR Random_Go
			DO
			SELECT CASE Random_Go
				CASE 1:outx=56:outy=54:EXIT LOOP
				CASE 2:outx=3:outy=105:EXIT LOOP
				CASE 3:outx=3:outy=3:EXIT LOOP
				CASE 4:outx=109:outy=105:EXIT LOOP
				CASE 5:outx=109:outy=54:EXIT LOOP
				CASE 6:outx=56:outy=105:EXIT LOOP
				CASE 7:outx=56:outy=3:EXIT LOOP
				CASE 8:outx=3:outy=54:EXIT LOOP
				CASE 9:outx=109:outy=3:EXIT LOOP
				CASE 10
					Random_Go=1
			END SELECT	
			LOOP		
		ELSE
			Computer=0:Human=1
		END IF
		object=Cross1
	CASE 2
		IF whos_go$="Computer" THEN
			IF LEFT$(Gette_ptext$(VS),1)="C" THEN
				INCR Random_Go
				DO
				SELECT CASE Random_Go
					CASE 1
						IF last_go$="CC" THEN INCR Random_Go:EXIT SELECT
						outx=56:outy=54:EXIT LOOP
					CASE 2
						IF last_go$="BL" THEN INCR Random_Go:EXIT SELECT
						outx=3:outy=105:EXIT LOOP
					CASE 3
						IF last_go$="TL" THEN INCR Random_Go:EXIT SELECT
						outx=3:outy=3:EXIT LOOP
					CASE 4
						IF last_go$="BR" THEN INCR Random_Go:EXIT SELECT
						outx=109:outy=105:EXIT LOOP
					CASE 5
						IF last_go$="CR" THEN INCR Random_Go:EXIT SELECT
						outx=109:outy=54:EXIT LOOP
					CASE 6
						IF last_go$="BR" THEN INCR Random_Go:EXIT SELECT
						outx=56:outy=105:EXIT LOOP
					CASE 7
						IF last_go$="TC" THEN INCR Random_Go:EXIT SELECT
						outx=56:outy=3:EXIT LOOP
					CASE 8
						IF last_go$="CL" THEN INCR Random_Go:EXIT SELECT
						outx=3:outy=54:EXIT LOOP
					CASE 9
						IF last_go$="TR" THEN INCR Random_Go:EXIT SELECT
						outx=109:outy=3:EXIT LOOP
					CASE 10
						Random_Go=1
				END SELECT	
				LOOP		
			END IF
		END IF
		object=N1
	CASE 3
		object=Cross2
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
	CASE 4
		object=N2
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
	CASE 5
		object=Cross3
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
	CASE 6
		object=N3
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
	CASE 7
		object=Cross4
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
	CASE 8
		object=N4
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
	CASE 9
		object=Cross5
		IF whos_go$="Computer" THEN IF LEFT$(Gette_ptext$(VS),1)="C" THEN CALL A_I
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB A_I
SHARED TL,TC,TR,CL,CC,CR,BL,BC,BR,object_go,Computer,Human
STATIC possibility,S1,S2,S3,mode$

mode$="win"
once_again:
FOR possibility=1 TO 24
SELECT CASE possibility
	CASE 1:S1=TL:S2=CC:S3=BR
	CASE 2:S1=BR:S2=CC:S3=TL
	CASE 3:S1=TR:S2=CC:S3=BL
	CASE 4:S1=BL:S2=CC:S3=TR
	CASE 5:S1=CC:S2=BR:S3=TL
	CASE 6:S1=CC:S2=BL:S3=TR
	CASE 7:S1=TL:S2=TC:S3=TR
	CASE 8:S1=CL:S2=CC:S3=CR
	CASE 9:S1=BL:S2=BC:S3=BR
	CASE 10:S1=TR:S2=TC:S3=TL
	CASE 11:S1=CR:S2=CC:S3=CL
	CASE 12:S1=BR:S2=BC:S3=BL
	CASE 13:S1=TC:S2=TR:S3=TL
	CASE 14:S1=CC:S2=CR:S3=CL
	CASE 15:S1=BC:S2=BR:S3=BL
	CASE 16:S1=TL:S2=CL:S3=BL
	CASE 17:S1=TC:S2=CC:S3=BC
	CASE 18:S1=TR:S2=CR:S3=BR
	CASE 19:S1=BL:S2=CL:S3=TL
	CASE 20:S1=BC:S2=CC:S3=TC
	CASE 21:S1=BR:S2=CR:S3=TR
	CASE 22:S1=CL:S2=BL:S3=TL
	CASE 23:S1=CC:S2=BC:S3=TC
	CASE 24:S1=CR:S2=BR:S3=TR
END SELECT

IF S1=-1 THEN
	IF mode$="any" THEN Match_Up 1,possibility:EXIT SUB
ELSE
SELECT CASE mode$
CASE=="win"
	IF S1=Computer THEN
	IF S2=S1 THEN
		IF S3=-1 THEN
			Match_Up 3,possibility:EXIT SUB
		END IF
	ELSE
		IF S3=S1 THEN
			IF S2=-1 THEN
				Match_Up 2,possibility:EXIT SUB
			END IF
		END IF
	END IF
	END IF
CASE=="block"
	IF S1=Human THEN
	IF S2=S1 THEN
		IF S3=-1 THEN
			Match_Up 3,possibility:EXIT SUB
		END IF
	ELSE
		IF S3=S1 THEN
			IF S2=-1 THEN
				Match_Up 2,possibility:EXIT SUB
			END IF
		END IF
	END IF
	END IF
END SELECT
END IF
NEXT

SELECT CASE mode$
CASE=="win"
	mode$="block"
	GOTO once_again
CASE=="block"
	mode$="any"
	GOTO once_again
END SELECT
junk=form_alert(1,"[0][ Nothing matched! | Error!][ OK ]")
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Match_Up(Square,possibility)
SHARED outx,outy

SELECT CASE possibility
	CASE 1
		IF Square=1 THEN outx=3:outy=3
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=109:outy=105
	CASE 2
		IF Square=1 THEN outx=109:outy=105
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=3:outy=3
	CASE 3
		IF Square=1 THEN outx=109:outy=3
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=3:outy=105
	CASE 4
		IF Square=1 THEN outx=3:outy=105
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=109:outy=3
	CASE 5
		IF Square=1 THEN outx=56:outy=54
		IF Square=2 THEN outx=109:outy=105
		IF Square=3 THEN outx=3:outy=3
	CASE 6
		IF Square=1 THEN outx=56:outy=54
		IF Square=2 THEN outx=3:outy=105
		IF Square=3 THEN outx=109:outy=3
	CASE 7
		IF Square=1 THEN outx=3:outy=3
		IF Square=2 THEN outx=56:outy=3
		IF Square=3 THEN outx=109:outy=3
	CASE 8
		IF Square=1 THEN outx=3:outy=54
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=109:outy=54
	CASE 9
		IF Square=1 THEN outx=3:outy=105
		IF Square=2 THEN outx=56:outy=105
		IF Square=3 THEN outx=109:outy=105
	CASE 10
		IF Square=1 THEN outx=109:outy=3
		IF Square=2 THEN outx=56:outy=3
		IF Square=3 THEN outx=3:outy=3
	CASE 11
		IF Square=1 THEN outx=109:outy=54
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=3:outy=54
	CASE 12
		IF Square=1 THEN outx=109:outy=105
		IF Square=2 THEN outx=56:outy=105
		IF Square=3 THEN outx=3:outy=105
	CASE 13
		IF Square=1 THEN outx=56:outy=3
		IF Square=2 THEN outx=109:outy=3
		IF Square=3 THEN outx=3:outy=3
	CASE 14
		IF Square=1 THEN outx=56:outy=54
		IF Square=2 THEN outx=109:outy=54
		IF Square=3 THEN outx=3:outy=54
	CASE 15
		IF Square=1 THEN outx=56:outy=105
		IF Square=2 THEN outx=109:outy=105
		IF Square=3 THEN outx=3:outy=105
	CASE 16
		IF Square=1 THEN outx=3:outy=3
		IF Square=2 THEN outx=3:outy=54
		IF Square=3 THEN outx=3:outy=105
	CASE 17
		IF Square=1 THEN outx=56:outy=3
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=56:outy=105
	CASE 18
		IF Square=1 THEN outx=109:outy=3
		IF Square=2 THEN outx=109:outy=54
		IF Square=3 THEN outx=109:outy=105
	CASE 19
		IF Square=1 THEN outx=3:outy=105
		IF Square=2 THEN outx=3:outy=54
		IF Square=3 THEN outx=3:outy=3
	CASE 20
		IF Square=1 THEN outx=56:outy=105
		IF Square=2 THEN outx=56:outy=54
		IF Square=3 THEN outx=56:outy=3
	CASE 21
		IF Square=1 THEN outx=109:outy=105
		IF Square=2 THEN outx=109:outy=54
		IF Square=3 THEN outx=109:outy=3
	CASE 22
		IF Square=1 THEN outx=3:outy=54
		IF Square=2 THEN outx=3:outy=105
		IF Square=3 THEN outx=3:outy=3
	CASE 23
		IF Square=1 THEN outx=56:outy=54
		IF Square=2 THEN outx=56:outy=105
		IF Square=3 THEN outx=56:outy=3
	CASE 24
		IF Square=1 THEN outx=109:outy=54
		IF Square=2 THEN outx=109:outy=105
		IF Square=3 THEN outx=109:outy=3
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Check_Board
SHARED TL,TC,TR,CL,CC,CR,BL,BC,BR,object_go,Human,Computer	
STATIC possibility,S1,S2,S3

FOR possibility=1 TO 24
SELECT CASE possibility
	CASE 1:S1=TL:S2=CC:S3=BR
	CASE 2:S1=BR:S2=CC:S3=TL
	CASE 3:S1=TR:S2=CC:S3=BL
	CASE 4:S1=BL:S2=CC:S3=TR
	CASE 5:S1=CC:S2=BR:S3=TL
	CASE 6:S1=CC:S2=BL:S3=TR
	CASE 7:S1=TL:S2=TC:S3=TR
	CASE 8:S1=CL:S2=CC:S3=CR
	CASE 9:S1=BL:S2=BC:S3=BR
	CASE 10:S1=TR:S2=TC:S3=TL
	CASE 11:S1=CR:S2=CC:S3=CL
	CASE 12:S1=BR:S2=BC:S3=BL
	CASE 13:S1=TC:S2=TR:S3=TL
	CASE 14:S1=CC:S2=CR:S3=CL
	CASE 15:S1=BC:S2=BR:S3=BL
	CASE 16:S1=TL:S2=CL:S3=BL
	CASE 17:S1=TC:S2=CC:S3=BC
	CASE 18:S1=TR:S2=CR:S3=BR
	CASE 19:S1=BL:S2=CL:S3=TL
	CASE 20:S1=BC:S2=CC:S3=TC
	CASE 21:S1=BR:S2=CR:S3=TR
	CASE 22:S1=CL:S2=BL:S3=TL
	CASE 23:S1=CC:S2=BC:S3=TC
	CASE 24:S1=CR:S2=BR:S3=TR
END SELECT

IF NOT S1=-1 THEN 
	IF S2=S1 THEN
		 IF S3=S1 THEN 
			object_go=10
'			junk=form_alert(1,"[0][ Poss:"+STR$(possibility)+" | S1:"+STR$(S1)+"  | S2:"+STR$(S2)+"  | S3:"+STR$(S3)+" ][ OK ]")
			IF S1=Human THEN
				IF Gette_ptext$(VS)="Human" THEN CALL Game_Over("Player 1"):GOTO main_loop
				IF Gette_ptext$(VS)="Computer" THEN CALL Game_Over("You"):GOTO main_loop
			END IF
			IF S1=Computer THEN 
				IF Gette_ptext$(VS)="Human" THEN CALL Game_Over("Player 2"):GOTO main_loop
				IF Gette_ptext$(VS)="Computer" THEN CALL Game_Over("Computer"):GOTO main_loop
			END IF
		END IF
	END IF
END IF
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Game_Over(Winner$)
STATIC x,y,w,h,but,time!,winner

SelectTree FORM_GAMEOVER
SELECT CASE winner$
	CASE=="Player 1"
		Sette_ptext GAMEOVER,"Player 1 WINS!!"
	CASE=="You"
		Sette_ptext GAMEOVER,"YOU WIN!!"
	CASE=="Player 2"
		Sette_ptext GAMEOVER,"Player 2 WINS!!"
	CASE=="Computer"
		Sette_ptext GAMEOVER,"Sorry - Computer WINS!!"
	CASE=="Noone"
		Sette_ptext GAMEOVER,"No-one won this game!!"
END SELECT

form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
time!=TIMER
DO

LOOP UNTIL TIMER-time!>1
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
SelectTree FORM_MAIN
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ON ERROR GOTO ERROR_HANDLER
startprogram CURDIR$+"\TICTAC.RSC",0,0
about_handle=openformwindow(" About... ",&h0B,FORM_ABOUT,0,ABOUTOK,VARPTRS(close_aboutdialog))
Main_Loop:
xHGTloop
stopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' If an error has occurred...
ERROR_HANDLER:
' Display alert and abort to main loop
' Quit
IF ERR=68 THEN 
	CALL NoMoreWindows:SYSTEM
ELSE
	button=form_alert(1,"[1][  An ERROR"+STR$(ERR)+" has occurred ! |  Please contact Cadenza |  Software with Error No.  |  and symptoms. ][ Abort ]")
	junk=rsrc_free
	SYSTEM
END IF

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
