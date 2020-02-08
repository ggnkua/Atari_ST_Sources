
' [ADDRESS.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

DEFINT a-z
REM $include address.bh			' Declare *.BH file created from resource file
REM $include error.bas			' Request the file ERROR.BAS
REM $include toolbx_a.bas		' Request the file TOOLBX_A.BAS (i.e. GEM Toolkit)
REM $include bubble.bas			' Request the file BUBBLE.BAS
REM $include printer.bas		' Request the file PRINTER.BAS
REM $include st-guide.bas		' Request the file ST-GUIDE.BAS

DECLARE FUNCTION OPEN_BOOK		' Declare FUNCTION's that appear later
DECLARE FUNCTION SAVE_BOOK
CONST max_records=1000			' The variable max_records determines the maximum
								' amount of records available

HowManyButtons=2 : clicks_enabled=-1	' See GEM Toolkit manual (ENCHANT)
userclose_enabled=-1					' for an explaination of these variables

CALL StartProgram (CURDIR$+"\ADDRESS.RSC",FORM_MENU,MENU_QUIT,FORM_ICONIFY)
junk=xdialog (FORM_ABOUT,0,0,1,0)			' Display dialog
CALL initFORM_MAIN : CALL initFORM_PRINT	' Call sub-routines to initiate
CALL initFORM_FIND : junk=OPEN_BOOK			' settings within dialogs
CALL xENCHANTloop							' Call program loop
CALL StopProgram


FUNCTION HandleUserClose(BYVAL WindowHandle)
SHARED main_handle

SELECT CASE WindowHandle
CASE main_handle
	HandleUserClose=SAVE_BOOK : main_handle=0
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
SHARED MyProgram$
STATIC button

SELECT CASE item
CASE MENU_ABOUT : junk=xdialog (FORM_ABOUT,0,0,1,0)
CASE MENU_NEW
	IF allchange<>0 THEN
		button=form_alert(2,"[1][  "+MyProgram$+": |  Create a new Address Book? |  All current entries will |  be lost! ][Continue|Cancel]")
		SELECT CASE button
		CASE 1 : CALL NEW_BOOK
		END SELECT
	ELSE
		CALL NEW_BOOK
	END IF
CASE MENU_OPEN
	IF allchange<>0 THEN
		button=form_alert(2,"[1][  "+MyProgram$+": |  Open an Address Book? |  All current entries will |  be lost! ][Continue|Cancel]")
		SELECT CASE button
		CASE 1 : IF OPEN_BOOK THEN CALL redraw_object(MAIN_BACKDROP)
		END SELECT
	ELSE
		IF OPEN_BOOK THEN CALL redraw_object(MAIN_BACKDROP)
	END IF
CASE MENU_SAVE : junk=SAVE_BOOK
CASE MENU_STG_TITLE : junk=STGuide (CURDIR$+"\ADDRESS.HYP","Title")
CASE MENU_STG_CONTENT : junk=STGuide (CURDIR$+"\ADDRESS.HYP","Contents")
CASE MENU_STG_INDEX : junk=STGuide (CURDIR$+"\ADDRESS.HYP","Index")
END SELECT
END SUB


SUB initFORM_MAIN
SelectTree FORM_MAIN
setobj_text MAIN_TITLE,""
setobj_text MAIN_FORENAME,""
setobj_text MAIN_SURNAME,""
setobj_text MAIN_STREET,""
setobj_text MAIN_TOWN,""
setobj_text MAIN_COUNTY,""
setobj_text MAIN_POSTCODE,""
setobj_text MAIN_COUNTRY,""
setobj_text MAIN_PHONE,""
setobj_text MAIN_FAX,""
setobj_text MAIN_EMAIL,""
END SUB


SUB initFORM_PRINT
SelectTree FORM_PRINT
setobj_text PRINT_FROM,""
setobj_text PRINT_TO,""
END SUB


SUB initFORM_FIND
SelectTree FORM_FIND
setobj_text FIND_SEARCHFOR,""
END SUB


SUB closeFORM_MAIN
SHARED MyProgram$
STATIC button

IF CommonButton=2 THEN	' If right mouse button clicked
SELECT CASE CommonObj
	CASE MAIN_PRINT : junk=BubbleGEM ("Print a record or entire book to disk or printer")
	CASE MAIN_SEARCH : junk=BubbleGEM ("Search Address Book for a particular record")
	CASE MAIN_SORT : junk=BubbleGEM ("Sort Address Book alphabetically")
	CASE MAIN_DELETE : junk=BubbleGEM ("Delete current record")
	CASE MAIN_BACK : junk=BubbleGEM ("Display previous record")
	CASE MAIN_FORWARD : junk=BubbleGEM ("Display next record")
	CASE MAIN_FIRST : junk=BubbleGEM ("Display record #1")
	CASE MAIN_LAST : junk=BubbleGEM ("Display last rocord")
	CASE MAIN_UPDATE : junk=BubbleGEM ("Update current record to Address Book")
	CASE MAIN_HELP : junk=BubbleGEM ("Displays ST-Guide online help if available")
END SELECT
ELSE
SELECT CASE CommonObj
	CASE MAIN_PRINT : CALL PRINT_BOOK
	CASE MAIN_SEARCH : CALL FIND_RECORD
	CASE MAIN_SORT : CALL SORT_BOOK
	CASE MAIN_DELETE : CALL DELETE_RECORD
	CASE MAIN_FIRST : CALL RECORD_FIRST
	CASE MAIN_LAST : CALL RECORD_LAST
	CASE MAIN_BACK : CALL RECORD_BACK
	CASE MAIN_FORWARD : CALL RECORD_FORWARD
	CASE MAIN_HELP : junk=STGuide (CURDIR$+"\ADDRESS.HYP","Main")
	CASE MAIN_UPDATE : CALL UPDATE_RECORD
END SELECT
END IF
END SUB


SUB closeFORM_PRINT
SHARED print_handle

IF CommonButton=2 THEN
SELECT CASE CommonObj
	CASE PRINT_PRINT : junk=BubbleGEM ("Carry out Print command")
	CASE PRINT_CANCEL : junk=BubbleGEM ("Cancel")
	CASE PRINT_HELP : junk=BubbleGEM ("Displays ST-Guide online help if available")
END SELECT
ELSE
SELECT CASE CommonObj
	CASE PRINT_PRINT : CALL PRINT_RECORDS
	CASE PRINT_PRINT,PRINT_CANCEL : print_handle=0 : CommonClose=-1
	CASE PRINT_HELP : junk=STGuide (CURDIR$+"\ADDRESS.HYP","Print")
END SELECT
END IF
END SUB


SUB closeFORM_FIND
SHARED find_handle

IF CommonButton=2 THEN
SELECT CASE CommonObj
	CASE FIND_FIND : junk=BubbleGEM ("Search Address Book for...")
	CASE FIND_CANCEL : junk=BubbleGEM ("Cancel")
	CASE FIND_HELP : junk=BubbleGEM ("Displays ST-Guide online help if available")
END SELECT
ELSE
SELECT CASE CommonObj
	CASE FIND_FIND : CALL FindARrecord : find_handle=0 : CommonClose=-1
	CASE FIND_CANCEL : find_handle=0 : CommonClose=-1
	CASE FIND_HELP : junk=STGuide (CURDIR$+"\ADDRESS.HYP","Find")
END SELECT
END IF
END SUB


SUB NEW_BOOK
SHARED book$(2),current_record,total_records,main_handle,MyProgram$
STATIC oldtree&

MOUSE 2
allchange=0 : REDIM book$(10,max_records)	' Reset arrays and variables
current_record=0 : total_records=0
IF main_handle THEN							' If main window displayed, update it
	oldtree&=tree& : SelectTree FORM_MAIN
	CALL UPDATE_DISPLAY : redraw_object MAIN_BACKDROP
	RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
	tree&=oldtree&
END IF
MOUSE 0
END SUB


FUNCTION OPEN_BOOK
SHARED book$(2),current_record,total_records,main_handle
SHARED fsmessage$,fspath$,MyProgram$
STATIC dummy$,myfile,dummy,file$,fsname$

' Call FileSelector
fspath$=CURDIR$+"\*.DAT" : fsmessage$="Open Book" : file$=FileSelect$ (fsname$,2)
IF FEXISTS(file$) THEN
	allchange=1 : REDIM book$(10,max_records)		' Reset array and variables before loading
	current_record=0 : total_records=0 : dummy=0
	MOUSE 2
	myfile=FREEFILE
	OPEN file$ FOR INPUT AS #myfile		' Open file and load into array
	DO
		INCR dummy
		INPUT #myfile,book$(0,dummy),book$(1,dummy),book$(2,dummy),book$(3,dummy),book$(4,dummy),book$(5,dummy)
		INPUT #myfile,book$(6,dummy),book$(7,dummy),book$(8,dummy),book$(9,dummy),book$(10,dummy)
		IF dummy=max_records THEN EXIT LOOP
	LOOP UNTIL EOF(myfile)
	CLOSE #myfile
	MOUSE 0
	total_records=dummy : current_record=1		' Determine total amount of records loaded

	' Update display
	dummy$=MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
	main_handle=OpenFormWindow(dummy$,FORM_MAIN,MAIN_TITLE,0,VARPTRS(closeFORM_MAIN))
	CALL UPDATE_DISPLAY
	RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
	OPEN_BOOK=-1
ELSE
	junk=xalert(3,"[1]["+MyProgram$+":|The file you requested does|not exist - sorry!][OK]")
	OPEN_BOOK=0
END IF
END FUNCTION


SUB UPDATE_DISPLAY
SHARED book$(2),current_record

SelectTree FORM_MAIN
setobj_text MAIN_TITLE,book$(0,current_record)
setobj_text MAIN_FORENAME,book$(1,current_record)
setobj_text MAIN_SURNAME,book$(2,current_record)
setobj_text MAIN_STREET,book$(3,current_record)
setobj_text MAIN_TOWN,book$(4,current_record)
setobj_text MAIN_COUNTY,book$(5,current_record)
setobj_text MAIN_POSTCODE,book$(6,current_record)
setobj_text MAIN_COUNTRY,book$(7,current_record)
setobj_text MAIN_PHONE,book$(8,current_record)
setobj_text MAIN_FAX,book$(9,current_record)
setobj_text MAIN_EMAIL,book$(10,current_record)
END SUB


SUB UPDATE_RECORD
SHARED book$(2),current_record

SelectTree FORM_MAIN
book$(0,current_record)=getobj_text$(MAIN_TITLE)
book$(1,current_record)=getobj_text$(MAIN_FORENAME)
book$(2,current_record)=getobj_text$(MAIN_SURNAME)
book$(3,current_record)=getobj_text$(MAIN_STREET)
book$(4,current_record)=getobj_text$(MAIN_TOWN)
book$(5,current_record)=getobj_text$(MAIN_COUNTY)
book$(6,current_record)=getobj_text$(MAIN_POSTCODE)
book$(7,current_record)=getobj_text$(MAIN_COUNTRY)
book$(8,current_record)=getobj_text$(MAIN_PHONE)
book$(9,current_record)=getobj_text$(MAIN_FAX)
book$(10,current_record)=getobj_text$(MAIN_EMAIL)
allchange=1
END SUB


FUNCTION SAVE_BOOK
SHARED book$(2),current_record,total_records,main_handle
SHARED fsmessage$,fspath$
STATIC myfile,dummy,file$,button,fsname$

IF allchange=0 THEN SAVE_BOOK=-1 : EXIT FUNCTION		' If nothing has been changed don't save
fsmessage$="Save Book" : file$=FileSelect$ (fsname$,2)
IF fsname$="" THEN SAVE_BOOK=0 : EXIT SUB
IF FEXISTS(file$) THEN
	button=form_alert(2,"[1][  "+MyProgram$+": |  The filename requested already|  exists! ][Continue|Cancel]")
	SELECT CASE button
	CASE 2 : SAVE_BOOK=0 : EXIT SUB
	END SELECT
END IF

myfile=FREEFILE
MOUSE 2
OPEN file$ FOR OUTPUT AS #myfile
FOR dummy=1 TO total_records
	WRITE #myfile,book$(0,dummy),book$(1,dummy),book$(2,dummy),book$(3,dummy),book$(4,dummy),book$(5,dummy)
	WRITE #myfile,book$(6,dummy),book$(7,dummy),book$(8,dummy),book$(9,dummy),book$(10,dummy)
NEXT dummy
CLOSE #myfile
MOUSE 0
allchange=0 : SAVE_BOOK=-1
END FUNCTION


SUB FIND_RECORD
SHARED find_handle
STATIC dummy$

dummy$=MyProgram$+" : Find"
find_handle=OpenFormWindow(dummy$,FORM_FIND,FIND_SEARCHFOR,FIND_CANCEL,VARPTRS(closeFORM_FIND))
END SUB


SUB FindARrecord
SHARED find_handle,book$(2),total_records,current_record
STATIC dummy$,dummy

SelectTree FORM_FIND
dummy$=UCASE$(getobj_text$(FIND_SEARCHFOR))
IF dummy$="" THEN EXIT SUB
FOR dummy=1 TO total_records	' Search all records using chosen fields for a match!
	IF getobj_shortcut(FIND_TITLE)=14 THEN IF INSTR(UCASE$(book$(0,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_FORENAME)=14 THEN IF INSTR(UCASE$(book$(1,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_SURNAME)=14 THEN IF INSTR(UCASE$(book$(2,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_STREET)=14 THEN IF INSTR(UCASE$(book$(3,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_TOWN)=14 THEN IF INSTR(UCASE$(book$(4,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_COUNTY)=14 THEN IF INSTR(UCASE$(book$(5,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_POSTCODE)=14 THEN IF INSTR(UCASE$(book$(6,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_COUNTRY)=14 THEN IF INSTR(UCASE$(book$(7,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_PHONE)=14 THEN IF INSTR(UCASE$(book$(8,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_FAX)=14 THEN IF INSTR(UCASE$(book$(9,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
	IF getobj_shortcut(FIND_EMAIL)=14 THEN IF INSTR(UCASE$(book$(10,dummy)),dummy$) THEN CALL UPDATE_FIND(dummy) : EXIT SUB
NEXT dummy
junk=xalert(3,"[1]["+MyProgram$+":|Search unsuccessful - sorry!][OK]")
END SUB


SUB UPDATE_FIND (BYVAL record)
SHARED current_record,total_records,main_handle,MyProgram$

SelectTree FORM_MAIN
current_record=record
CALL UPDATE_DISPLAY : redraw_object MAIN_BACKDROP
RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
END SUB


SUB RECORD_BACK
SHARED current_record,total_records,main_handle,MyProgram$

SelectTree FORM_MAIN
IF (current_record-1)>0 THEN
	DECR current_record : CALL UPDATE_DISPLAY
	redraw_object MAIN_BACKDROP
	RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
END IF
END SUB


SUB RECORD_FORWARD
SHARED current_record,total_records,main_handle,MyProgram$

IF (current_record+1)<max_records THEN
	allchange=1
	INCR current_record : IF current_record>total_records THEN total_records=current_record
	CALL UPDATE_DISPLAY : redraw_object MAIN_BACKDROP
	RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
ELSE
	junk=xalert(3,"[1]["+MyProgram$+":|No more records may be |created - sorry!][OK]")
END IF
END SUB


SUB RECORD_FIRST
SHARED current_record,total_records,main_handle,MyProgram$

SelectTree FORM_MAIN
IF total_records>0 THEN
	current_record=1 : CALL UPDATE_DISPLAY
	redraw_object MAIN_BACKDROP
	RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
END IF
END SUB


SUB RECORD_LAST
SHARED current_record,total_records,main_handle,MyProgram$

SelectTree FORM_MAIN
IF total_records>0 THEN
	current_record=total_records : CALL UPDATE_DISPLAY
	redraw_object MAIN_BACKDROP
	RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
END IF
END SUB


SUB PRINT_BOOK
SHARED print_handle
STATIC dummy$

dummy$=MyProgram$+" : Print"
print_handle=OpenFormWindow(dummy$,FORM_PRINT,PRINT_FROM,PRINT_CANCEL,VARPTRS(closeFORM_PRINT))
END SUB


SUB DELETE_RECORD
SHARED book$(2),current_record,total_records,main_handle
STATIC dummy,record

SelectTree FORM_MAIN
IF total_records=0 THEN EXIT SUB
MOUSE 2
IF current_record<total_records THEN			' Delete current record
	FOR record=current_record TO total_records
		FOR dummy=MAIN_TITLE TO MAIN_EMAIL
			book$(dummy-MAIN_TITLE,record)=book$(dummy-MAIN_TITLE,record+1)
		NEXT dummy
	NEXT record
ELSE
	FOR dummy=MAIN_TITLE TO MAIN_EMAIL
		book$(dummy-MAIN_TITLE,total_records)=""
	NEXT dummy
	DECR current_record
END IF
DECR total_records		' Workout new total and update display
CALL UPDATE_DISPLAY : redraw_object MAIN_BACKDROP
RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
DO
LOOP UNTIL MOUSE(2)=0		' Wait for mouse button to be released to make sure only
MOUSE 0						' a single record is deleted at a time!
END SUB


SUB SORT_BOOK
SHARED book$(2),current_record,total_records,main_handle
STATIC dummy,record,dummy$(),i

SelectTree FORM_MAIN
MOUSE 2
DIM dummy$(10,max_records)
FOR record=1 TO total_records
	FOR dummy=MAIN_TITLE TO MAIN_EMAIL
		dummy$(dummy-MAIN_TITLE,record)=book$(dummy-MAIN_TITLE,record)
	NEXT dummy
	FOR i=record-1 TO 1 STEP -1
		IF UCASE$(book$(MAIN_SURNAME-MAIN_TITLE,i)+book$(MAIN_FORENAME-MAIN_TITLE,i))<UCASE$(dummy$(MAIN_SURNAME-MAIN_TITLE,record)+dummy$(MAIN_FORENAME-MAIN_TITLE,record)) THEN EXIT FOR
		FOR dummy=MAIN_TITLE TO MAIN_EMAIL
			book$(dummy-MAIN_TITLE,i+1)=book$(dummy-MAIN_TITLE,i)
		NEXT dummy
	NEXT i
	FOR dummy=MAIN_TITLE TO MAIN_EMAIL
		book$(dummy-MAIN_TITLE,i+1)=dummy$(dummy-MAIN_TITLE,record)
	NEXT dummy
NEXT record
ERASE dummy$
CALL UPDATE_DISPLAY : redraw_object MAIN_BACKDROP
RenameWindow main_handle,MyProgram$+" : Record"+STR$(current_record)+" of"+STR$(total_records)
MOUSE 0
END SUB


SUB PRINT_RECORDS
SHARED book$(2),current_record,total_records
SHARED fspath$,fsmessage$
STATIC from_record,to_record,myfile,record,dummy,file$,fsname$

SelectTree FORM_PRINT
from_record=VAL(getobj_text$(PRINT_FROM))
to_record=VAL(getobj_text$(PRINT_TO))
IF (from_record OR to_record)<1 THEN EXIT SUB
IF to_record=0 THEN to_record=total_records
IF to_record>total_records THEN to_record=total_records

IF getobj_shortcut(PRINT_DISK)=12 THEN		' If output to disk, open file first
	fspath$=CURDIR$+"\*.PRT" : fsmessage$="Print..." : file$=FileSelect$ (fsname$,2)
	IF fsname$="" THEN EXIT SUB
	myfile=FREEFILE
	OPEN file$ FOR OUTPUT AS #myfile
END IF

FOR record=from_record TO to_record
	IF getobj_shortcut(PRINT_TITLE)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(0,record)
		ELSE
			PRINT #myfile,book$(0,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_FORENAME)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(1,record)
		ELSE
			PRINT #myfile,book$(1,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_SURNAME)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(2,record)
		ELSE
			PRINT #myfile,book$(2,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_STREET)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(3,record)
		ELSE
			PRINT #myfile,book$(3,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_TOWN)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(4,record)
		ELSE
			PRINT #myfile,book$(4,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_COUNTY)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(5,record)
		ELSE
			PRINT #myfile,book$(5,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_POSTCODE)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(6,record)
		ELSE
			PRINT #myfile,book$(6,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_COUNTRY)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(7,record)
		ELSE
			PRINT #myfile,book$(7,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_PHONE)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(8,record)
		ELSE
			PRINT #myfile,book$(8,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_FAX)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(9,record)
		ELSE
			PRINT #myfile,book$(9,record)
		END IF
	END IF
	IF getobj_shortcut(PRINT_EMAIL)=14 THEN
		IF getobj_shortcut(PRINT_DISK)<>12 THEN
			IF ONLINE=0 THEN EXIT SUB
			LPRINT book$(10,record)
		ELSE
			PRINT #myfile,book$(10,record)
		END IF
	END IF
NEXT record
IF getobj_shortcut(PRINT_DISK)=12 THEN CLOSE #myfile
END SUB

'[*END OF FILE*]
