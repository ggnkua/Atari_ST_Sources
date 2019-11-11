'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Print IT v2.07  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' ½ Copyright HiSoft 1991-3
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Include GEMTOOL.T

'$option q80,y
LIBRARY "bios"
DIM SHARED OPTIONS$(51),CCODES$(51),BOPTIONS$(0),BCCODES$(0)
'$INCLUDE E:\cadenza.97\PRINT_IT\PRINT_IT.206\PRINT_IT.BH

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

' set a tedinfo record
SUB Sette_ptext_update(BYVAL object,BYVAL newted$,handle)
SHARED edit_handle,main_handle
STATIC t&,chars,i,oldtree&

oldtree&=tree&
IF handle=1 THEN SelectTree FORM_EDIT
IF handle=2 THEN SelectTree FORM_MAIN

t&=Getob_spec&(object)
chars=MIN(PEEKW(t&+te_txtlen)-1,LEN(newted$))		'-1 for the null
t&=PEEKL(t&+te_ptext)
FOR i=1 TO chars
	POKEB t&,ASC(MID$(newted$,i,1))
	INCR t&
NEXT i
POKEB t&,0									'must end in null
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB INITIALISE
SHARED Output$,menutree&,total_edititems,total_mainitems,total_batchitems
SHARED top_edititem,top_mainitem,top_batchitem,edit_handle,main_handle
SHARED fspath$,fsname$,about_handle,edit_handle,main_handle,Delete_status
STATIC i

CALL menu_icheck (menutree&,MENU_DIRECT,1)
Output$="Direct"
total_edititems=50
total_mainitems=50
total_batchitems=0
top_edititem=0
top_mainitem=0
top_batchitem=0
Delete_status=-1

FOR i=O1 TO C12
	Sette_ptext_update i,"",1
NEXT
FOR i=SO1 TO SO12
	Sette_ptext_update i,"",2
NEXT
FOR i=B1 TO B10
	Sette_ptext_update i,"",2
NEXT

FOR i=0 TO 50
	OPTIONS$(i)=""
	CCODES$(i)=""
NEXT

fspath$=CURDIR$+"\*.DRV"
fsname$="PRINTER.DRV"
CALL LOAD_PRINTERDRIVER(CURDIR$+"\PRINTER.DRV")
CALL DISPLAY_PRINTERDRIVER2
edit_handle=openformwindow(" Edit : Print IT ",&h0B,FORM_EDIT,O1,EDIT_QUIT,VARPTRS(close_editdialog))
CALL SCROLL2(total_edititems,12,E_SLIDER,E_BACKGROUND)
main_handle=openformwindow(" Print IT ",&h0B,FORM_MAIN,0,MAIN_QUIT,VARPTRS(close_maindialog))
CALL SCROLL2(total_mainitems,12,S_SLIDER,S_BACKGROUND)
CALL SCROLL2(total_batchitems,10,B_SLIDER,B_BACKGROUND)
about_handle=openformwindow(" About... ",&h0B,FORM_ABOUT,0,ABOUT_OK,VARPTRS(close_aboutdialog))
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB processusermenus(VAL topwin,VAL item,VAL title)
SHARED commonclose,commonobj,menutree&
SHARED about_handle,edit_handle,Output$,total_edititems,total_batchitems
SHARED top_batchitem,delete_status
STATIC test$,i,button

commonclose=0										
IF Delete_status=0 THEN EXIT SUB

SELECT CASE item
	CASE MENU_ABOUT
		IF about_handle THEN
			TopAWindow about_handle
		ELSE
			about_handle=openformwindow(" About... ",9,FORM_ABOUT,0,ABOUT_OK,VARPTRS(close_aboutdialog))
		END IF
	CASE MENU_LOADPD
		CALL LOAD_PRINTERDRIVER("")
		CALL DISPLAY_PRINTERDRIVER
	CASE MENU_SAVEPD
		CALL SAVE_PRINTERDRIVER
	CASE MENU_NEWBATCH
		button=form_alert(2,"[2][  Do you really want to create |  a new batch file ? ][ Continue | Cancel ]")
		SELECT CASE button
		CASE 1
			total_batchitems=0
			top_batchitem=0
			REDIM PRESERVE BOPTIONS$(0)
			REDIM PRESERVE BCCODES$(0)
			CALL DISPLAY_BATCH
		END SELECT
	CASE MENU_LOADBATCH
		CALL LOAD_BATCH
		CALL DISPLAY_BATCH
	CASE MENU_SAVEBATCH
		CALL SAVE_BATCH
	CASE MENU_SENDBATCH
		CALL SEND_BATCH(-1)
	CASE=MENU_QUIT
		CALL QUIT_ME
	CASE MENU_DIRECT
		CALL menu_icheck (Menutree&,MENU_DIRECT,1)
		CALL menu_icheck (Menutree&,MENU_TOBATCH,0)
		Output$="Direct"
	CASE MENU_TOBATCH
		CALL menu_icheck (Menutree&,MENU_DIRECT,0)
		CALL menu_icheck (Menutree&,MENU_TOBATCH,1)
		Output$="To Batch"
	CASE MENU_SENDTEST
		CALL Printer_Status(-1)
		test$=""
		FOR i=65 TO 90
			test$=test$+CHR$(i)
		NEXT
		FOR i=97 TO 122
			test$=test$+CHR$(i)
		NEXT
		FOR i=49 TO 57
			test$=test$+CHR$(i)
		NEXT
		LPRINT test$+"0"
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_aboutdialog
SHARED commonclose,commonobj,about_handle

commonclose=0										
SELECT CASE commonobj
	CASE=ABOUT_OK
		commonclose=-1
		about_handle=0
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_editdialog
SHARED commonclose,commonobj,edit_handle,Output$
SHARED total_edititems,top_edititem,delete_status

commonclose=0										
IF Delete_status=0 THEN 
	Setob_state commonobj,0
	Object_Redraw edit_handle,commonobj
	EXIT SUB
END IF

SELECT CASE commonobj
	CASE EDIT_LOAD
		CALL LOAD_PRINTERDRIVER("")
		CALL DISPLAY_PRINTERDRIVER
	CASE EDIT_SAVE
		CALL SAVE_PRINTERDRIVER
	CASE=E_ARROWUP
		DECR top_edititem
		IF top_edititem<0 THEN
			top_edititem=0
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_EDITDISPLAY
	CASE=E_ARROWDOWN
		INCR top_edititem
		IF top_edititem>total_edititems-12 THEN
			top_edititem=total_edititems-12
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_EDITDISPLAY
	CASE=EDIT_QUIT
		CALL QUIT_ME
END SELECT
Setob_state commonobj,0:Object_Redraw edit_handle,commonobj
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_maindialog
SHARED commonclose,commonobj,main_handle,total_mainitems,total_batchitems
SHARED top_mainitem,top_batchitem,delete_status
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
	CASE SO1 TO SO12
		CALL Send_to_Output((commonobj-9)+top_mainitem,commonobj)
	CASE=S_ARROWUP
		DECR top_mainitem
		IF top_mainitem<0 THEN 
			top_mainitem=0
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_MAINDISPLAY
	CASE=S_ARROWDOWN
		INCR top_mainitem
		IF top_mainitem>total_mainitems-12 THEN 
			top_mainitem=total_mainitems-12
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
	CASE=MAIN_QUIT
		CALL QUIT_ME
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
SHARED total_edititems,total_mainitems,top_edititem,top_mainitem
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
		top_mainitem=0
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

' Save a text file from memory to disk
SUB SAVE_PRINTERDRIVER
SHARED total_edititems
SHARED FileSelect$,fsname$,fspath$
STATIC i

' Call FileSelector
MOUSE 2
CALL FileSelect$(CURDIR$+"\*.DRV",fsname$,"Save Driver...")
MOUSE 0

MOUSE 2
IF fsname$<>"" THEN
	IF FileSelect$<>"" THEN
	' Open file to channel 1
	OPEN FileSelect$ FOR OUTPUT AS #1
	WRITE #1,"תPrint IT Driverת","ת½ 1996 Cadenza Software - Written by Matthew Baconת"
	WRITE #1,"",""
	WRITE #1,"תStartת",""

	FOR i=0 TO total_edititems
		WRITE #1,OPTIONS$(i),CCODES$(i)
	NEXT

	WRITE #1,"תEndת",""
	CLOSE #1
	junk=form_alert(1,"[0][  Printer Driver has been |  saved to disk. | ][ OK ]")
	END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB GET_DATA
SHARED top_edititem,top_mainitem,main_handle
STATIC i,k,oldtree&

oldtree&=tree&
SelectTree FORM_EDIT
k=top_edititem
OPTIONS$(k+0)=Gette_ptext$(O1)
OPTIONS$(k+1)=Gette_ptext$(O2)
OPTIONS$(k+2)=Gette_ptext$(O3)
OPTIONS$(k+3)=Gette_ptext$(O4)
OPTIONS$(k+4)=Gette_ptext$(O5)
OPTIONS$(k+5)=Gette_ptext$(O6)
OPTIONS$(k+6)=Gette_ptext$(O7)
OPTIONS$(k+7)=Gette_ptext$(O8)
OPTIONS$(k+8)=Gette_ptext$(O9)
OPTIONS$(k+9)=Gette_ptext$(O10)
OPTIONS$(k+10)=Gette_ptext$(O11)
OPTIONS$(k+11)=Gette_ptext$(O12)

CCODES$(k+0)=Gette_ptext$(C1)
CCODES$(k+1)=Gette_ptext$(C2)
CCODES$(k+2)=Gette_ptext$(C3)
CCODES$(k+3)=Gette_ptext$(C4)
CCODES$(k+4)=Gette_ptext$(C5)
CCODES$(k+5)=Gette_ptext$(C6)
CCODES$(k+6)=Gette_ptext$(C7)
CCODES$(k+7)=Gette_ptext$(C8)
CCODES$(k+8)=Gette_ptext$(C9)
CCODES$(k+9)=Gette_ptext$(C10)
CCODES$(k+10)=Gette_ptext$(C11)
CCODES$(k+11)=Gette_ptext$(C12)

SelectTree FORM_MAIN
k=top_mainitem
FOR i=SO1 TO SO12
	Sette_ptext_update i,OPTIONS$(k),2
	INCR k
NEXT
Object_Redraw main_handle,S_BACKDROP
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DISPLAY_PRINTERDRIVER
SHARED total_edititems,total_mainitems
SHARED edit_handle,main_handle
STATIC i,k,oldtree&

oldtree&=tree&
SelectTree FORM_EDIT
k=0
Sette_ptext_update O1,OPTIONS$(k+0),1
Sette_ptext_update O2,OPTIONS$(k+1),1
Sette_ptext_update O3,OPTIONS$(k+2),1
Sette_ptext_update O4,OPTIONS$(k+3),1
Sette_ptext_update O5,OPTIONS$(k+4),1
Sette_ptext_update O6,OPTIONS$(k+5),1
Sette_ptext_update O7,OPTIONS$(k+6),1
Sette_ptext_update O8,OPTIONS$(k+7),1
Sette_ptext_update O9,OPTIONS$(k+8),1
Sette_ptext_update O10,OPTIONS$(k+9),1
Sette_ptext_update O11,OPTIONS$(k+10),1
Sette_ptext_update O12,OPTIONS$(k+11),1

Sette_ptext_update C1,CCODES$(k+0),1
Sette_ptext_update C2,CCODES$(k+1),1
Sette_ptext_update C3,CCODES$(k+2),1
Sette_ptext_update C4,CCODES$(k+3),1
Sette_ptext_update C5,CCODES$(k+4),1
Sette_ptext_update C6,CCODES$(k+5),1
Sette_ptext_update C7,CCODES$(k+6),1
Sette_ptext_update C8,CCODES$(k+7),1
Sette_ptext_update C9,CCODES$(k+8),1
Sette_ptext_update C10,CCODES$(k+9),1
Sette_ptext_update C11,CCODES$(k+10),1
Sette_ptext_update C12,CCODES$(k+11),1
Object_Redraw edit_handle,E_BACKDROP
CALL SCROLL2(total_edititems,12,E_SLIDER,E_BACKGROUND)
Object_Redraw edit_handle,e_background

SelectTree FORM_MAIN
k=0
FOR i=SO1 TO SO12
	Sette_ptext_update i,OPTIONS$(k),2
	INCR k
NEXT
Object_Redraw main_handle,S_BACKDROP
CALL SCROLL2(total_mainitems,12,S_SLIDER,S_BACKGROUND)
Object_Redraw main_handle,s_background
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DISPLAY_PRINTERDRIVER2
STATIC i,k

k=0
Sette_ptext_update O1,OPTIONS$(k+0),1
Sette_ptext_update O2,OPTIONS$(k+1),1
Sette_ptext_update O3,OPTIONS$(k+2),1
Sette_ptext_update O4,OPTIONS$(k+3),1
Sette_ptext_update O5,OPTIONS$(k+4),1
Sette_ptext_update O6,OPTIONS$(k+5),1
Sette_ptext_update O7,OPTIONS$(k+6),1
Sette_ptext_update O8,OPTIONS$(k+7),1
Sette_ptext_update O9,OPTIONS$(k+8),1
Sette_ptext_update O10,OPTIONS$(k+9),1
Sette_ptext_update O11,OPTIONS$(k+10),1
Sette_ptext_update O12,OPTIONS$(k+11),1

Sette_ptext_update C1,CCODES$(k+0),1
Sette_ptext_update C2,CCODES$(k+1),1
Sette_ptext_update C3,CCODES$(k+2),1
Sette_ptext_update C4,CCODES$(k+3),1
Sette_ptext_update C5,CCODES$(k+4),1
Sette_ptext_update C6,CCODES$(k+5),1
Sette_ptext_update C7,CCODES$(k+6),1
Sette_ptext_update C8,CCODES$(k+7),1
Sette_ptext_update C9,CCODES$(k+8),1
Sette_ptext_update C10,CCODES$(k+9),1
Sette_ptext_update C11,CCODES$(k+10),1
Sette_ptext_update C12,CCODES$(k+11),1

k=0
FOR i=SO1 TO SO12
	Sette_ptext_update i,OPTIONS$(k),2
	INCR k
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_EDITDISPLAY
SHARED total_edititems,top_edititem
SHARED edit_handle
STATIC i,k

k=top_edititem
Sette_ptext_update O1,OPTIONS$(k+0),1
Sette_ptext_update O2,OPTIONS$(k+1),1
Sette_ptext_update O3,OPTIONS$(k+2),1
Sette_ptext_update O4,OPTIONS$(k+3),1
Sette_ptext_update O5,OPTIONS$(k+4),1
Sette_ptext_update O6,OPTIONS$(k+5),1
Sette_ptext_update O7,OPTIONS$(k+6),1
Sette_ptext_update O8,OPTIONS$(k+7),1
Sette_ptext_update O9,OPTIONS$(k+8),1
Sette_ptext_update O10,OPTIONS$(k+9),1
Sette_ptext_update O11,OPTIONS$(k+10),1
Sette_ptext_update O12,OPTIONS$(k+11),1

Sette_ptext_update C1,CCODES$(k+0),1
Sette_ptext_update C2,CCODES$(k+1),1
Sette_ptext_update C3,CCODES$(k+2),1
Sette_ptext_update C4,CCODES$(k+3),1
Sette_ptext_update C5,CCODES$(k+4),1
Sette_ptext_update C6,CCODES$(k+5),1
Sette_ptext_update C7,CCODES$(k+6),1
Sette_ptext_update C8,CCODES$(k+7),1
Sette_ptext_update C9,CCODES$(k+8),1
Sette_ptext_update C10,CCODES$(k+9),1
Sette_ptext_update C11,CCODES$(k+10),1
Sette_ptext_update C12,CCODES$(k+11),1
CALL SCROLL(total_edititems,12,top_edititem,E_SLIDER,E_BACKGROUND,edit_handle)
Object_Redraw edit_handle,E_BACKDROP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_MAINDISPLAY
SHARED total_mainitems,top_mainitem
SHARED main_handle
STATIC i,k

k=top_mainitem
FOR i=SO1 TO SO12
	Sette_ptext_update i,OPTIONS$(k),2
	INCR k
NEXT
CALL SCROLL(total_mainitems,12,top_mainitem,S_SLIDER,S_BACKGROUND,main_handle)
Object_Redraw main_handle,S_BACKDROP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_BATCHDISPLAY
SHARED total_batchitems,top_batchitem
SHARED main_handle
STATIC i,k

k=top_batchitem
FOR i=B1 TO B10
	Sette_ptext_update i,BOPTIONS$(k),2
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

SUB QUIT_ME
SHARED finished_flag,commonclose
STATIC button

MOUSE 2
button=form_alert(2,"[2][  Do you really want to quit ? |  All unsaved data will be |  lost! ][ Continue | Cancel ]")
SELECT CASE button
	CASE 1
		commonclose=-1
		finished_flag=-1
END SELECT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ON ERROR GOTO ERROR_HANDLER
startprogram CURDIR$+"\PRINT_IT.RSC",Menu,-1
CALL INITIALISE
Main_Loop:
xHGTloop2
stopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'The New Toolbox's main loop
SUB xHGTloop2
STATIC ev,key_pressed,clicks,x,y,kstate,button
STATIC mclicks,mmask,mstate,data_changed,time!
SHARED finished_flag,Mess(1),clicks_enabled,keys_enabled,menus_enabled,forms_enabled
 REDIM mess(7)
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
 data_changed=-1
 DO
	junk=wind_update(END_UPDATE)
	ev=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON+MU_TIMER,mclicks,mmask,mstate, _
			0,0,0,0,0,_
			0,0,0,0,0,_
			VARPTR(mess(0)),250,_
			x,y, _
			button,kstate, _
			key_pressed,clicks)
	junk=wind_update(BEG_UPDATE)

	IF data_changed=0 THEN IF TIMER-time!<1 THEN data_changed=-1:CALL GET_DATA

	IF ev AND MU_KEYBD THEN	
		KeyboardEvent key_pressed,kstate
		IF (key_pressed AND 255)=<13 THEN
			IF (key_pressed AND 255)=8 THEN
				time!=TIMER
				data_changed=0
			END IF
		ELSE
			time!=TIMER
			data_changed=0
		END IF
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
STATIC i,k,oldtree&

oldtree&=tree&
SelectTree FORM_MAIN
k=0
SELECT CASE total_batchitems
	CASE 0
		FOR i=B1 TO B10
			Sette_ptext_update i,"",2
		NEXT
	CASE ELSE
		FOR i=B1 TO B10
			IF k>total_batchitems THEN
				Sette_ptext_update i,"",2
			ELSE
				Sette_ptext_update i,BOPTIONS$(k),2
			END IF
			INCR k
		NEXT
END SELECT
Object_Redraw main_handle,B_BACKDROP
CALL SCROLL2(total_batchitems,10,B_SLIDER,B_BACKGROUND)
Object_Redraw main_handle,b_background
tree&=oldtree&
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
