'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' PlayBACK (Print IT) ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' ½ Copyright HiSoft 1991-3
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'$option j100,y
LIBRARY "bios"
DIM SHARED OPTIONS$(51),CCODES$(51),BOPTIONS$(0),BCCODES$(0)

'$INCLUDE E:\CADENZA.97\PRINT_IT\PLAYBACK\PLAYBACK.BH

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ON ERROR GOTO ERROR_HANDLER
StartAccessory "  PlayBACK "

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB AccOpened
SHARED commonclose,commonobj,resorce_loaded
SHARED Output$,total_pditems,total_batchitems,top_pditem,top_batchitem
SHARED main_handle
STATIC i

INCR i
IF resorce_loaded=0 THEN
	MOUSE 2
	' If resource file does not exist, then display alert message
	IF rsrc_load(CURDIR$+"\PLAYBACK.RSC")=0 THEN
		junk=form_alert(1,"[1][  Error while loading |  resource file. | ][ Abort ]")
		MOUSE 0:resorce_loaded=0:EXIT SUB	
	END IF
	MOUSE 0:resorce_loaded=-1
END IF

IF i=1 THEN 
	SelectTree Form_About
	junk=HandleDialog(0)
	SelectTree Form_Main
	CALL INITIALISE
END IF

SelectTree Form_Main
commonclose=0
IF main_handle THEN
	TopAWindow main_handle
ELSE
	main_handle=openformwindow(" PlayBACK ",&h0B,FORM_MAIN,0,QUIT,VARPTRS(close_maindialog))
	CALL SCROLL2(total_pditems,10,PD_SLIDER,PD_BACKGROUND)
	CALL SCROLL2(total_batchitems,10,B_SLIDER,B_BACKGROUND)
	Object_Redraw main_handle,commonobj
	IF i>1 THEN FullRedraw main_handle
END IF
GOTO MAIN_LOOP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' File selector handler - returns a new pathname
' the global variables fspath$ and fsname$ keep the appropriate
' GEM items.
SUB FileSelect$(fspath$,fsname$,fsmessage$)
SHARED fspath$,fsname$,fsmessage$,FileSelect$
STATIC ok,i,ch
IF fspath$="" THEN CALL InitFileSelector
IF aes_version<&H130 THEN
	fsel_input fspath$,fsname$,ok
ELSE 
	fsel_exinput fspath$,fsname$,ok,fsmessage$
END IF
IF ok THEN
	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 
	FileSelect$=LEFT$(fspath$,i)+fsname$
ELSE
	FileSelect$=""
END IF
END SUB

' initialise the file selector
SUB	InitFileSelector
SHARED fspath$,fsname$
fspath$=CURDIR$+"\*.*"
fsname$=""
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB INITIALISE
SHARED Output$,total_pditems,total_batchitems
SHARED top_pditem,top_batchitem
SHARED fspath$,fsname$,Delete_status
STATIC i

Output$="Direct"
total_pditems=50
total_batchitems=0
top_pditem=0
top_batchitem=0
Delete_status=-1

Sette_ptext OUTPUTtype,Output$

FOR i=PD1 TO PD10
	Sette_ptext i,""
NEXT
FOR i=B1 TO B10
	Sette_ptext i,""
NEXT

FOR i=0 TO 50
	OPTIONS$(i)=""
	CCODES$(i)=""
NEXT

fspath$=CURDIR$+"\*.DRV"
fsname$="PRINTER.DRV"
CALL LOAD_PRINTERDRIVER(CURDIR$+"\PRINTER.DRV")
CALL DISPLAY_PRINTERDRIVER2
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_maindialog
SHARED commonclose,commonobj,main_handle,total_pditems,total_batchitems
SHARED top_pditem,top_batchitem,delete_status,Output$
STATIC w,h,startx,starty,inx,inh,inw,iny,outx,outy,object
STATIC found_over,button,temp_option$,temp_ccode$

commonclose=0										
IF Delete_status=0 THEN 
	SELECT CASE commonobj
		CASE B1 TO B10
		CASE=B_DELETE

		CASE ELSE
			Setob_state commonobj,0:Object_Redraw main_handle,commonobj
			EXIT SUB
	END SELECT
END IF

SELECT CASE commonobj
	CASE PD_LOAD
		CALL LOAD_PRINTERDRIVER("")
		CALL DISPLAY_PRINTERDRIVER
	CASE SWITCHOUTPUT
		SELECT CASE Output$
			CASE="Direct"
				Output$="To Batch"
			CASE="To Batch"
				Output$="Direct"
		END SELECT
		Sette_ptext OUTPUTtype,Output$
		Object_Redraw main_handle,OutputType
	CASE PD1 TO PD10
		CALL Send_to_Output((commonobj-16)+top_pditem,commonobj)
	CASE=PD_ARROWUP
		DECR top_pditem
		IF top_pditem<0 THEN 
			top_pditem=0
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_MAINDISPLAY
	CASE=PD_ARROWDOWN
		INCR top_pditem
		IF top_pditem>total_pditems-10 THEN 
			top_pditem=total_pditems-10
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_MAINDISPLAY

	CASE=B_NEW
		button=form_alert(2,"[2][  Do you really want to create |  a new batch file ? ][ Continue | Cancel ]")
		SELECT CASE button
		CASE 1
			total_batchitems=0
			top_batchitem=0
			REDIM PRESERVE BOPTIONS$(0)
			REDIM PRESERVE BCCODES$(0)
			CALL DISPLAY_BATCH
		END SELECT
	CASE=B_LOAD
		CALL LOAD_BATCH
		CALL DISPLAY_BATCH
	CASE=B_SAVE
		CALL SAVE_BATCH
	CASE=B_DELETE
		IF Delete_status=-1 THEN 
			Delete_status=0
			EXIT SUB
		ELSE
			Delete_status=-1
		END IF
	CASE=B_SEND
		CALL SEND_BATCH(commonobj)
	CASE B1 TO B10
		IF Gette_ptext$(commonobj)="" THEN EXIT SELECT
		IF Delete_status=0 THEN CALL Delete_Batch((commonobj-27)+top_batchitem):EXIT SELECT
		junk=objc_offset(tree&,commonobj,startx,starty)
		w=Getob_width(commonobj)
		h=Getob_height(commonobj)
		junk=objc_offset(tree&,b_backdrop,inx,iny)
		inw=Getob_width(b_backdrop)
		inh=Getob_height(b_backdrop)
		CALL graf_dragbox(w,h,startx,starty,inx,iny,inw,inh,outx,outy)
		found_over=objc_find(tree&,object,10,outx,outy+(h/2))
		IF NOT found_over=commonobj THEN
		IF Gette_ptext$(found_over)="" THEN EXIT SELECT
		SELECT CASE found_over
			CASE B1 TO B10
				temp_option$=BOPTIONS$((commonobj-27)+top_batchitem)
				temp_ccode$=BCCODES$((commonobj-27)+top_batchitem)
				BOPTIONS$((commonobj-27)+top_batchitem)=BOPTIONS$((found_over-27)+top_batchitem)
				BCCODES$((commonobj-27)+top_batchitem)=BCCODES$((found_over-27)+top_batchitem)
				BOPTIONS$((found_over-27)+top_batchitem)=temp_option$
				BCCODES$((found_over-27)+top_batchitem)=temp_ccode$
				CALL UPDATE_BATCHDISPLAY
		END SELECT
		END IF
	CASE=B_ARROWUP
		DECR top_batchitem
		IF top_batchitem<0 THEN 
			top_batchitem=0
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_BATCHDISPLAY
	CASE=B_ARROWDOWN
		INCR top_batchitem
		IF top_batchitem>total_batchitems-10 THEN 
			top_batchitem=total_batchitems-10
			IF top_batchitem<0 THEN top_batchitem=0
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_BATCHDISPLAY
	CASE=QUIT
		commonclose=-1
		main_handle=0
END SELECT
Setob_state commonobj,0:Object_Redraw main_handle,commonobj
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL(total_items,display_items,top_item,object,background,handle)
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
junk=objc_draw(tree&,background,10,x,y,w,h)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL2(total_items,display_items,object,background)
STATIC i!,height!

IF total_items=<display_items THEN
	Setob_y object,0
	Setob_height object,Getob_Height(background)
ELSE
	i!=Getob_Height(background)/total_items
	height!=i!*display_items
	Setob_y object,0
	Setob_height object,height!
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Load a text file from disk into memory
SUB LOAD_PRINTERDRIVER(FileSelected$)
SHARED total_edititems,total_pditems,top_edititem,top_pditem
SHARED FileSelect$,fsname$,fspath$,FileSelected$
STATIC i,check,current_option$

' Call FileSelector
IF FileSelected$="" THEN 
	MOUSE 2
	CALL FileSelect$(CURDIR$+"\*.DRV",fsname$,"Choose a Driver...")
	MOUSE 0
ELSE
	FileSelect$=FileSelected$
END IF

MOUSE 2
IF fsname$<>"" THEN
	IF FileSelect$<>"" THEN
	IF FEXISTS(FileSelect$) THEN
		OPEN FileSelect$ FOR INPUT AS #1
		i=0
		check=-1
		DO
			INPUT #1,OPTIONS$(i),CCODES$(i)

			IF check=-1 THEN
				IF OPTIONS$(0)="תPrint IT Driverת" THEN
					IF NOT CCODES$(0)="ת½ 1996 Cadenza Software - Written by Matthew Baconת" THEN
						junk=form_alert(1,"[1][  This is not a valid |  Printer Driver. | ][ Abort ]")
						FOR i=0 TO 50
							OPTIONS$(i)=""
							CCODES$(i)=""
						NEXT
						EXIT LOOP
					END IF
				ELSE
					junk=form_alert(1,"[1][  This is not a valid |  Printer Driver. | ][ Abort ]")
					FOR i=0 TO 50
						OPTIONS$(i)=""
						CCODES$(i)=""
					NEXT
					EXIT LOOP
				END IF
				check=0
			END IF

			IF OPTIONS$(i)="" AND CCODES$(i)="" THEN 

			ELSE
			current_option$=OPTIONS$(i)
			SELECT CASE current_option$
				CASE="תStartת"
					i=0
				CASE="תEndת"
					OPTIONS$(i)=""
					CCODES$(i)=""
					EXIT LOOP
				CASE ELSE
					INCR i
			END SELECT
			END IF
		LOOP UNTIL EOF(1)
		CLOSE #1
		top_edititem=0
		top_pditem=0
	ELSE
		' If the filename passed does not exists then display error
		IF FileSelected$<>"" THEN
			junk=form_alert(1,"[1][  Error while loading Driver |  file into memory. | ][ Abort ]")
			FileSelected$=""
		END IF
	END IF
	END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DISPLAY_PRINTERDRIVER
SHARED total_pditems
SHARED main_handle
STATIC i,k

k=0
FOR i=PD1 TO PD10
	Sette_ptext i,OPTIONS$(k)
	INCR k
NEXT
Object_Redraw main_handle,S_BACKDROP
CALL SCROLL2(total_pditems,10,pd_SLIDER,pd_BACKGROUND)
Object_Redraw main_handle,pd_background
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DISPLAY_PRINTERDRIVER2
STATIC i,k

k=0
FOR i=PD1 TO PD10
	Sette_ptext i,OPTIONS$(k)
	INCR k
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_MAINDISPLAY
SHARED total_pditems,top_pditem
SHARED main_handle
STATIC i,k

k=top_pditem
FOR i=PD1 TO PD10
	Sette_ptext i,OPTIONS$(k)
	INCR k
NEXT
CALL SCROLL(total_pditems,10,top_pditem,PD_SLIDER,PD_BACKGROUND,main_handle)
Object_Redraw main_handle,S_BACKDROP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_BATCHDISPLAY
SHARED total_batchitems,top_batchitem
SHARED main_handle
STATIC i,k

k=top_batchitem
FOR i=B1 TO B10
	Sette_ptext i,BOPTIONS$(k)
	INCR k
	IF k>total_batchitems THEN EXIT FOR
NEXT
CALL SCROLL(total_batchitems,10,top_batchitem,B_SLIDER,B_BACKGROUND,main_handle)
Object_Redraw main_handle,B_BACKDROP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Send_to_Output(command,object)
SHARED Output$,total_batchitems

MOUSE 2
SELECT CASE Output$
	CASE="Direct"
		IF ccodes$(command)="" THEN EXIT SELECT
		CALL Printer_Status(object)
		CALL Send_Command(ccodes$(command))
	CASE="To Batch"
		IF ccodes$(command)="" THEN EXIT SELECT
		REDIM PRESERVE BOPTIONS$(total_batchitems+1)
		REDIM PRESERVE BCCODES$(total_batchitems+1)
		BOPTIONS$(total_batchitems)=OPTIONS$(command)
		BCCODES$(total_batchitems)=CCODES$(command)
		INCR total_batchitems
		CALL UPDATE_BATCHDISPLAY
END SELECT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Check printer is ready to receive data
SUB Printer_Status(object)
SHARED main_handle
STATIC time!,button

MOUSE 2
' Is the printer ready to receive data
IF bcostat(0)=0 THEN
	time!=TIMER
	DO
		IF INKEY$=CHR$(27) THEN EXIT SUB
	LOOP UNTIL TIMER-time!>2
	button=form_alert(1,"[1][  Please turn your printer |  ON LINE! ][ Try Again | Cancel ]")
	SELECT CASE button
		CASE 1
			CALL Printer_Status(object)
		CASE 2
			IF NOT object=-1 THEN Setob_state object,0:Object_Redraw main_handle,object
			MOUSE 0
			GOTO Main_Loop
	END SELECT
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Send_Command(Code$)
STATIC i,original$

original$=code$
DO
	i=0
	DO
		INCR i
		IF MID$(Code$,i,1)="," THEN EXIT LOOP
		IF i>LEN(Code$) THEN EXIT LOOP
	LOOP 
	OUT 0,VAL(LEFT$(Code$,i-1))
	IF i+1>LEN(Code$) THEN EXIT LOOP
	Code$=RIGHT$(Code$,LEN(Code$)-i)
LOOP
code$=original$
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LOAD_BATCH
SHARED total_batchitems,top_batchitem
SHARED FileSelect$,fsname$,fspath$
STATIC i,check,current_option$

' Call FileSelector
MOUSE 2
CALL FileSelect$(CURDIR$+"\*.BAT",fsname$,"Batch File...")
MOUSE 0

MOUSE 2
IF fsname$<>"" THEN
	IF FileSelect$<>"" THEN
	IF FEXISTS(FileSelect$) THEN
		OPEN FileSelect$ FOR INPUT AS #1
		i=0
		check=-1
		DO
			REDIM PRESERVE BOPTIONS$(i)
			REDIM PRESERVE BCCODES$(i)
			INPUT #1,BOPTIONS$(i),BCCODES$(i)

			IF check=-1 THEN
				IF BOPTIONS$(0)="תPrint IT Batch Fileת" THEN
					IF NOT BCCODES$(0)="ת½ 1996 Cadenza Software - Written by Matthew Baconת" THEN
						junk=form_alert(1,"[1][  This is not a valid |  Print IT Batch File. | ][ Abort ]")
						i=0
						EXIT LOOP
					END IF
				ELSE
					junk=form_alert(1,"[1][  This is not a valid |  Print IT Batch File. | ][ Abort ]")
					i=0
					EXIT LOOP
				END IF
				check=0
			END IF

			IF BOPTIONS$(i)="" AND BCCODES$(i)="" THEN 

			ELSE
			current_option$=BOPTIONS$(i)
			SELECT CASE current_option$
				CASE="תStartת"
					i=0
				CASE="תEndת"
					BOPTIONS$(i)=""
					BCCODES$(i)=""
					EXIT LOOP
				CASE ELSE
					INCR i
			END SELECT
			END IF
		LOOP UNTIL EOF(1)
		CLOSE #1
		total_batchitems=i
		top_batchitem=0
	ELSE
		' If the filename passed does not exists then display error
		junk=form_alert(1,"[1][  Error while loading Driver |  file into memory. | ][ Abort ]")
	END IF
	END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Save a text file from memory to disk
SUB SAVE_BATCH
SHARED total_batchitems
SHARED FileSelect$,fsname$,fspath$
STATIC i

' Call FileSelector
MOUSE 2
CALL FileSelect$(CURDIR$+"\*.BAT",fsname$,"Save Batch...")
MOUSE 0

MOUSE 2
IF fsname$<>"" THEN
IF FileSelect$<>"" THEN
	' Open file to channel 1
	OPEN FileSelect$ FOR OUTPUT AS #1
	WRITE #1,"תPrint IT Batch Fileת","ת½ 1996 Cadenza Software - Written by Matthew Baconת"
	WRITE #1,"",""
	WRITE #1,"תStartת",""

	FOR i=0 TO total_batchitems-1
		WRITE #1,BOPTIONS$(i),BCCODES$(i)
	NEXT

	WRITE #1,"תEndת",""
	CLOSE #1
	junk=form_alert(1,"[0][  Batch File has been saved |  to disk. | ][ OK ]")
END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DISPLAY_BATCH
SHARED total_batchitems,main_handle
STATIC i,k

k=0
SELECT CASE total_batchitems
	CASE 0
		FOR i=B1 TO B10
			Sette_ptext i,""
		NEXT
	CASE ELSE
		FOR i=B1 TO B10
			IF k>total_batchitems THEN
				Sette_ptext i,""
			ELSE
				Sette_ptext i,BOPTIONS$(k)
			END IF
			INCR k
		NEXT
END SELECT
Object_Redraw main_handle,B_BACKDROP
CALL SCROLL2(total_batchitems,10,B_SLIDER,B_BACKGROUND)
Object_Redraw main_handle,b_background
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SEND_BATCH(object)
SHARED total_batchitems
STATIC i

MOUSE 2
FOR i=0 TO (total_batchitems-1)
	IF BCCODES$(i)<>"" THEN 
		CALL Printer_Status(object)
		CALL Send_Command(BCCODES$(i))
	END IF
NEXT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Delete_Batch(Object)
SHARED total_batchitems,top_batchitem
STATIC i

FOR i=object TO total_batchitems-1
	IF i>=total_batchitems THEN EXIT SUB
	BOPTIONS$(i)=BOPTIONS$(i+1)
	BCCODES$(i)=BCCODES$(i+1)
NEXT

BOPTIONS$(total_batchitems)=""
BCCODES$(total_batchitems)=""

DECR total_batchitems
IF total_batchitems=<10 THEN top_batchitem=0
CALL UPDATE_BATCHDISPLAY
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

Main_Loop:
xHGTloop2

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'The New Toolbox's main loop
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
	ev=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON+MU_TIMER,mclicks,mmask,mstate, _
			0,0,0,0,0,_
			0,0,0,0,0,_
			VARPTR(mess(0)),150,_
			x,y, _
			button,kstate, _
			key_pressed,clicks)
	junk=wind_update(BEG_UPDATE)

	IF ev AND MU_KEYBD THEN	KeyboardEvent key_pressed,kstate

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
